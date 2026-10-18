import SwiftUI

/// Focus streak, live-filling daily goal bar, and full session history — shared by Home and Dashboard.
///
/// The goal bar advances second-by-second while a focus session is running so the dashboard
/// matches the countdown on screen and the Lock Screen Live Activity.
struct FocusDashboardSummaryCard: View {
    @ObservedObject private var focusStore = FocusSessionStore.shared
    @AppStorage("respite.focus.dailyGoalMinutes") private var dailyFocusGoalMinutes = 25

    var body: some View {
        let goal = max(5, min(180, dailyFocusGoalMinutes))

        VStack(alignment: .leading, spacing: 20) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                dailyGoalSection(goal: goal, now: context.date)
            }

            Divider()
                .opacity(0.35)

            historySection
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .onAppear {
            focusStore.reloadFromDisk()
        }
    }

    // MARK: - Goal + streak

    @ViewBuilder
    private func dailyGoalSection(goal: Int, now: Date) -> some View {
        let todayMinutes = focusStore.focusMinutesTodayIncludingActive(at: now)
        let progress = focusStore.dailyGoalProgressLive(goalMinutes: goal, at: now)
        let streak = focusStore.currentStreak(goalMinutes: goal, now: now)
        let goalMet = progress >= 1
        let sessionsToday = sessionsCompletedToday(on: now)

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Focus streak")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("Streak: \(streak) day\(streak == 1 ? "" : "s")")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Stepper(value: $dailyFocusGoalMinutes, in: 5...180, step: 5) {
                Text("Daily goal: \(goal) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if goalMet {
                goalAchievedBadge
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(goalMet ? "Goal achieved today" : "Today’s focus")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(goalMet ? Color.green : .secondary)
                    Spacer()
                    Text(goalMet ? "\(todayMinutes) min logged" : "\(todayMinutes) / \(goal) min")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: goalMet
                                        ? [Color.green.opacity(0.9), Color.mint]
                                        : [.cyan, Color.orange.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(8, geo.size.width * CGFloat(min(1, progress))))
                            .animation(.linear(duration: 1), value: progress)
                    }
                }
                .frame(height: 10)
            }

            HStack(spacing: 16) {
                summaryChip(
                    icon: "timer",
                    title: "Sessions today",
                    value: "\(sessionsToday)"
                )
                summaryChip(
                    icon: "checkmark.seal.fill",
                    title: "Total recorded",
                    value: "\(focusStore.sessionHistory.count)"
                )
            }
        }
    }

    private var goalAchievedBadge: some View {
        HStack(spacing: 10) {
            Image(systemName: "trophy.fill")
                .font(.headline)
                .foregroundStyle(Color.yellow)
            Text("Goal achieved")
                .font(.title3.bold())
                .foregroundStyle(Color.green)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.12))
        )
    }

    private func summaryChip(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.cyan)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
    }

    private func sessionsCompletedToday(on referenceDate: Date) -> Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: referenceDate)
        guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return 0 }
        return focusStore.sessionHistory.filter { $0.endedAt >= start && $0.endedAt < end }.count
    }

    // MARK: - Session history

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Previous focus sessions")
                .font(.subheadline.weight(.semibold))
            Text("Includes sessions that finished on their own and ones you ended early.")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            if focusStore.sessionHistory.isEmpty {
                Text("Nothing here yet — complete or end a focus session and it will show up.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                let sessions = focusStore.sessionHistory
                VStack(spacing: 0) {
                    ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                        focusHistoryRow(session)
                        if index < sessions.count - 1 {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
            }
        }
    }

    private func focusHistoryRow(_ session: RecordedFocusSession) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: session.endedNaturally ? "checkmark.circle.fill" : "stop.circle.fill")
                .font(.title3)
                .foregroundStyle(session.endedNaturally ? Color.green : Color.orange)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.endedNaturally ? "Completed (timer)" : "Ended early")
                    .font(.subheadline.weight(.semibold))
                Text(session.endedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(session.creditedMinutes) min toward goal · planned \(session.plannedSeconds / 60) min")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
    }
}
