import Combine
import Foundation
import SwiftUI

private enum FocusSessionDefaultsKey {
    static let activeSession = "respite.focus.activeSession.v1"
    static let history = "respite.focus.sessionHistory.v1"
}

/// Wall-clock focus session persisted in the app group so tab switches and backgrounding do not reset the timer.
@MainActor
final class FocusSessionStore: ObservableObject {
    static let shared = FocusSessionStore()

    /// Minutes of focus logged today that count toward the daily goal (completed session time, capped per session).
    @Published private(set) var sessionHistory: [RecordedFocusSession] = []

    private let defaults: UserDefaults
    private let calendar = Calendar.current
    private var tickTimer: Timer?

    private init() {
        defaults = UserDefaults(suiteName: RegulationAppGroup.id) ?? .standard
        reloadFromDisk()
        startTickerIfNeeded()
    }

    // MARK: - Active session

    /// Publishes so SwiftUI updates the focus clock when the session starts, ends, or restores from disk.
    @Published private(set) var active: ActiveFocusSession?

    var hasActiveSession: Bool { active != nil }

    var activeQuote: String { active?.quote ?? "" }

    /// Remaining time in the current focus session (wall clock).
    var remainingTimeInterval: TimeInterval {
        remainingTimeInterval(at: Date())
    }

    /// Remaining seconds from a fixed clock (use `TimelineView`’s date so the UI stays correct across tabs and backgrounding).
    func remainingTimeInterval(at referenceDate: Date) -> TimeInterval {
        guard let active else { return 0 }
        return max(0, active.endsAt.timeIntervalSince(referenceDate))
    }

    /// 0…1 — fills toward 1 as wall-clock time elapses toward `endsAt` (same basis as Live Activity progress).
    var activeSessionProgress: Double {
        sessionProgress(at: Date())
    }

    func sessionProgress(at referenceDate: Date) -> Double {
        guard let active else { return 0 }
        let total = Double(max(1, active.plannedSeconds))
        let remaining = remainingTimeInterval(at: referenceDate)
        return min(1, max(0, 1 - (remaining / total)))
    }

    func formattedRemaining() -> String {
        formattedRemaining(at: Date())
    }

    func formattedRemaining(at referenceDate: Date) -> String {
        let sec = Int(ceil(remainingTimeInterval(at: referenceDate)))
        let m = sec / 60
        let s = sec % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: - Lifecycle

    func reloadFromDisk() {
        sessionHistory = loadHistory()
        if let data = defaults.data(forKey: FocusSessionDefaultsKey.activeSession),
           let decoded = try? JSONDecoder().decode(ActiveFocusSession.self, from: data) {
            if Date() >= decoded.endsAt {
                active = decoded
                finalizeActiveSession(endedNaturally: true, at: decoded.endsAt)
                active = nil
                defaults.removeObject(forKey: FocusSessionDefaultsKey.activeSession)
                Task { await FocusSessionLiveActivityManager.endIfNeeded() }
            } else {
                active = decoded
            }
        } else {
            active = nil
        }
        startTickerIfNeeded()
        objectWillChange.send()
        if let active {
            Task {
                await FocusSessionLiveActivityManager.syncWithRestoredSession(
                    startedAt: active.startedAt,
                    endsAt: active.endsAt,
                    quote: active.quote
                )
            }
        } else {
            Task { await FocusSessionLiveActivityManager.endIfNeeded() }
        }
    }

    func startSession(plannedMinutes: Int) {
        let clamped = min(180, max(1, plannedMinutes))
        let now = Date()
        let plannedSeconds = clamped * 60
        let endsAt = now.addingTimeInterval(TimeInterval(plannedSeconds))
        let quote = FocusSessionQuotes.randomQuote()
        let session = ActiveFocusSession(startedAt: now, endsAt: endsAt, plannedSeconds: plannedSeconds, quote: quote)
        active = session
        persistActive()
        startTickerIfNeeded()
        objectWillChange.send()
        Task {
            await FocusSessionLiveActivityManager.startIfPossible(startedAt: now, endsAt: endsAt, quote: quote)
        }
    }

    /// User confirmed ending early.
    func endSessionManually() {
        guard let active else { return }
        let now = Date()
        finalizeActiveSession(endedNaturally: false, at: now)
        self.active = nil
        defaults.removeObject(forKey: FocusSessionDefaultsKey.activeSession)
        stopTicker()
        objectWillChange.send()
        Task {
            await FocusSessionLiveActivityManager.endIfNeeded()
        }
    }

    // MARK: - Daily goal & streak

    func focusMinutesCompleted(on day: Date) -> Int {
        let start = calendar.startOfDay(for: day)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return 0 }
        return sessionHistory.reduce(0) { partial, session in
            guard session.endedAt >= start, session.endedAt < end else { return partial }
            return partial + session.creditedMinutes
        }
    }

    /// Total focused *seconds* today, including partial progress of the currently running session. Basis for a live-filling goal bar.
    func focusSecondsTodayIncludingActive(at referenceDate: Date) -> Double {
        let start = calendar.startOfDay(for: referenceDate)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return 0 }
        var seconds: Double = sessionHistory.reduce(0) { partial, session in
            guard session.endedAt >= start, session.endedAt < end else { return partial }
            return partial + Double(session.creditedMinutes * 60)
        }
        if let active, active.startedAt < end, active.startedAt >= start {
            let elapsed = max(0, min(referenceDate.timeIntervalSince(active.startedAt), TimeInterval(active.plannedSeconds)))
            seconds += elapsed
        }
        return seconds
    }

    /// Whole minutes credited today including the currently running session — used for the numeric counter on the dashboard.
    func focusMinutesTodayIncludingActive(at referenceDate: Date) -> Int {
        Int(focusSecondsTodayIncludingActive(at: referenceDate) / 60)
    }

    func dailyGoalProgress(goalMinutes: Int, now: Date = .now) -> Double {
        let goal = max(1, goalMinutes)
        let minutes = focusMinutesCompleted(on: now)
        return min(1, Double(minutes) / Double(goal))
    }

    /// 0…1 goal fill that advances smoothly as the live session runs (basis for the dashboard bar that fills toward “Goal achieved”).
    func dailyGoalProgressLive(goalMinutes: Int, at referenceDate: Date) -> Double {
        let goalSeconds = Double(max(1, goalMinutes) * 60)
        let seconds = focusSecondsTodayIncludingActive(at: referenceDate)
        return min(1, max(0, seconds / goalSeconds))
    }

    func currentStreak(goalMinutes: Int, now: Date = .now) -> Int {
        let goal = max(1, goalMinutes)
        let today = calendar.startOfDay(for: now)
        var day = today
        // Today counts toward the streak as soon as the live-including-active total meets the goal.
        let todayMinutes = focusMinutesTodayIncludingActive(at: now)
        if todayMinutes < goal {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = calendar.startOfDay(for: yesterday)
        }
        var streak = 0
        while true {
            let minutes = calendar.isDate(day, inSameDayAs: today)
                ? todayMinutes
                : focusMinutesCompleted(on: day)
            guard minutes >= goal else { break }
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = calendar.startOfDay(for: prev)
        }
        return streak
    }

    // MARK: - Private

    private func persistActive() {
        guard let active, let data = try? JSONEncoder().encode(active) else {
            defaults.removeObject(forKey: FocusSessionDefaultsKey.activeSession)
            return
        }
        defaults.set(data, forKey: FocusSessionDefaultsKey.activeSession)
    }

    private func loadHistory() -> [RecordedFocusSession] {
        guard let data = defaults.data(forKey: FocusSessionDefaultsKey.history),
              let list = try? JSONDecoder().decode([RecordedFocusSession].self, from: data) else {
            return []
        }
        return list.sorted { $0.endedAt > $1.endedAt }
    }

    private func saveHistory(_ list: [RecordedFocusSession]) {
        sessionHistory = list.sorted { $0.endedAt > $1.endedAt }
        if let data = try? JSONEncoder().encode(sessionHistory) {
            defaults.set(data, forKey: FocusSessionDefaultsKey.history)
        }
    }

    private func finalizeActiveSession(endedNaturally: Bool, at endDate: Date) {
        guard let active else { return }
        let elapsed = max(0, min(endDate.timeIntervalSince(active.startedAt), TimeInterval(active.plannedSeconds)))
        let seconds = Int(elapsed.rounded())
        let credited = max(0, seconds / 60)
        let record = RecordedFocusSession(
            id: UUID(),
            startedAt: active.startedAt,
            endedAt: endDate,
            plannedSeconds: active.plannedSeconds,
            creditedMinutes: credited,
            endedNaturally: endedNaturally
        )
        var list = loadHistory()
        list.append(record)
        saveHistory(list)
    }

    private func completeNaturallyIfNeeded() {
        guard let active, Date() >= active.endsAt else { return }
        finalizeActiveSession(endedNaturally: true, at: active.endsAt)
        self.active = nil
        defaults.removeObject(forKey: FocusSessionDefaultsKey.activeSession)
        stopTicker()
        objectWillChange.send()
        Task {
            await FocusSessionLiveActivityManager.endIfNeeded()
        }
    }

    private func startTickerIfNeeded() {
        tickTimer?.invalidate()
        tickTimer = nil
        guard active != nil else { return }
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        tickTimer = timer
    }

    private func stopTicker() {
        tickTimer?.invalidate()
        tickTimer = nil
    }

    private func tick() {
        completeNaturallyIfNeeded()
        guard active != nil else { return }
        objectWillChange.send()
        Task {
            guard let active else { return }
            await FocusSessionLiveActivityManager.update(
                startedAt: active.startedAt,
                endsAt: active.endsAt,
                quote: active.quote
            )
        }
    }
}

// MARK: - Models

struct ActiveFocusSession: Codable, Equatable {
    var startedAt: Date
    var endsAt: Date
    var plannedSeconds: Int
    var quote: String
}

struct RecordedFocusSession: Codable, Identifiable, Equatable {
    var id: UUID
    var startedAt: Date
    var endedAt: Date
    var plannedSeconds: Int
    /// Minutes counted toward the daily goal (floored whole minutes of focused time).
    var creditedMinutes: Int
    var endedNaturally: Bool
}
