import ActivityKit
import RespiteFocusKit
import SwiftUI
import WidgetKit

/// Live Activity UI for a Respite focus session.
///
/// Colour palette matches the in-app session (cyan primary, warm orange accent).
/// Both the in-app countdown and this widget derive fraction/time-left from the same
/// `startedAt` / `endsAt` pair in `FocusSessionLiveAttributes.ContentState`, so the
/// Lock Screen card, Dynamic Island, and sheet timer are always in sync.
private extension Color {
    static let respiteCyan = Color(red: 0.35, green: 0.85, blue: 0.95)
    static let respiteOrange = Color(red: 1.0, green: 0.55, blue: 0.2)
    static let respiteBackground = Color(red: 0.05, green: 0.08, blue: 0.12)
}

private func sessionFraction(startedAt: Date, endsAt: Date, now: Date) -> Double {
    let span = endsAt.timeIntervalSince(startedAt)
    guard span > 0 else { return 1 }
    return min(1, max(0, now.timeIntervalSince(startedAt) / span))
}

private struct SessionProgressBar: View {
    let fraction: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.14))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.respiteCyan, .respiteOrange.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(4, geo.size.width * fraction))
            }
        }
        .frame(height: 9)
    }
}

private struct LiveActivityCard: View {
    let context: ActivityViewContext<FocusSessionLiveAttributes>

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let state = context.state
            let fraction = sessionFraction(startedAt: state.startedAt, endsAt: state.endsAt, now: timeline.date)
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Label("Respite Focus", systemImage: "leaf.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.respiteCyan)
                    Spacer()
                    Text(state.endsAt, style: .timer)
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .foregroundStyle(Color.respiteCyan)
                        .multilineTextAlignment(.trailing)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Session progress")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.55))
                        Spacer()
                        Text("\(Int((fraction * 100).rounded()))%")
                            .font(.caption2.monospacedDigit().weight(.medium))
                            .foregroundStyle(Color.respiteOrange)
                    }
                    SessionProgressBar(fraction: CGFloat(fraction))
                }

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "quote.opening")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.respiteCyan.opacity(0.9))
                        .padding(.top, 2)
                    Text(state.quote)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(3)
                        .minimumScaleFactor(0.85)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct RespiteFocusLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusSessionLiveAttributes.self) { context in
            LiveActivityCard(context: context)
                .padding(.horizontal, 4)
                .activityBackgroundTint(Color.respiteBackground)
                .activitySystemActionForegroundColor(Color.respiteCyan)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("Focus", systemImage: "leaf.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.respiteCyan)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.endsAt, style: .timer)
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundStyle(Color.respiteCyan)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    expandedBottom(context: context)
                }
            } compactLeading: {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(Color.respiteCyan)
            } compactTrailing: {
                Text(context.state.endsAt, style: .timer)
                    .font(.caption2.monospacedDigit().weight(.semibold))
                    .foregroundStyle(Color.respiteOrange)
                    .frame(maxWidth: 44)
            } minimal: {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(Color.respiteCyan)
            }
            .widgetURL(URL(string: "regulate://focus"))
            .keylineTint(Color.respiteCyan)
        }
    }

    private func expandedBottom(context: ActivityViewContext<FocusSessionLiveAttributes>) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let state = context.state
            let fraction = sessionFraction(startedAt: state.startedAt, endsAt: state.endsAt, now: timeline.date)
            VStack(alignment: .leading, spacing: 10) {
                SessionProgressBar(fraction: CGFloat(fraction))
                Text(state.quote)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .padding(.top, 4)
        }
    }
}

@main
struct RespiteFocusLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        RespiteFocusLiveActivityWidget()
    }
}
