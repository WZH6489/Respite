import ActivityKit
import Foundation
import RespiteFocusKit

@MainActor
enum FocusSessionLiveActivityManager {
    private static var activity: Activity<FocusSessionLiveAttributes>?

    /// After relaunch, the in-memory `activity` is nil even if a Live Activity is still on-screen — reconnect or start a new one.
    static func syncWithRestoredSession(startedAt: Date, endsAt: Date, quote: String) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        if let activity, activity.activityState == .active {
            await pushContent(startedAt: startedAt, endsAt: endsAt, quote: quote, to: activity)
            return
        }
        if let existing = Activity<FocusSessionLiveAttributes>.activities.first(where: { $0.activityState == .active }) {
            activity = existing
            await pushContent(startedAt: startedAt, endsAt: endsAt, quote: quote, to: existing)
            return
        }
        await startIfPossible(startedAt: startedAt, endsAt: endsAt, quote: quote)
    }

    static func startIfPossible(startedAt: Date, endsAt: Date, quote: String) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            #if DEBUG
            print("Respite focus: Live Activities disabled in Settings.")
            #endif
            return
        }
        await endEveryFocusLiveActivity()
        let attributes = FocusSessionLiveAttributes()
        let state = FocusSessionLiveAttributes.ContentState(
            startedAt: startedAt,
            endsAt: endsAt,
            quote: quote
        )
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: endsAt),
                pushType: nil
            )
        } catch {
            #if DEBUG
            print("Respite focus: Live Activity request failed: \(error.localizedDescription)")
            #endif
            activity = nil
        }
    }

    static func update(startedAt: Date, endsAt: Date, quote: String) async {
        if let activity, activity.activityState == .active {
            await pushContent(startedAt: startedAt, endsAt: endsAt, quote: quote, to: activity)
            return
        }
        if let existing = Activity<FocusSessionLiveAttributes>.activities.first(where: { $0.activityState == .active }) {
            activity = existing
            await pushContent(startedAt: startedAt, endsAt: endsAt, quote: quote, to: existing)
        }
    }

    static func endIfNeeded() async {
        await endEveryFocusLiveActivity()
    }

    private static func pushContent(
        startedAt: Date,
        endsAt: Date,
        quote: String,
        to activity: Activity<FocusSessionLiveAttributes>
    ) async {
        let state = FocusSessionLiveAttributes.ContentState(startedAt: startedAt, endsAt: endsAt, quote: quote)
        await activity.update(ActivityContent(state: state, staleDate: endsAt))
    }

    private static func endEveryFocusLiveActivity() async {
        for act in Activity<FocusSessionLiveAttributes>.activities {
            await act.end(nil, dismissalPolicy: .immediate)
        }
        activity = nil
    }
}
