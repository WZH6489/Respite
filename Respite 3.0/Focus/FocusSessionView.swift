import SwiftUI

/// Focus countdown with a live-filling session progress bar, wall-clock timing,
/// and an end-session confirmation styled like the calm breathing gate.
///
/// Timing semantics:
/// * All timing reads come from `FocusSessionStore`, which persists `startedAt`/`endsAt`
///   in the shared app group, so tab switches, sheet dismissal, or backgrounding never
///   reset the clock.
/// * The visible countdown, progress bar, and Lock Screen / Dynamic Island Live Activity
///   derive their values from the same `startedAt`/`endsAt` pair, so they stay in lockstep.
struct FocusSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var store: FocusSessionStore

    @State private var selectedMinutes = 25
    @State private var showEndConfirmation = false

    private let durationOptions = [5, 10, 15, 25, 45, 60]

    var body: some View {
        NavigationStack {
            ZStack {
                sessionBackground
                    .ignoresSafeArea()

                if store.hasActiveSession {
                    activeSessionContent
                } else {
                    setupContent
                }

                if showEndConfirmation {
                    endSessionConfirmationOverlay
                        .transition(.opacity)
                }
            }
            .navigationTitle("Focus session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            store.reloadFromDisk()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                store.reloadFromDisk()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showEndConfirmation)
    }

    private var sessionBackground: some View {
        LinearGradient(
            colors: [
                Color.cyan.opacity(store.hasActiveSession ? 0.14 : 0.08),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var setupContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Pick a duration and stay with one intention until the timer completes. Your progress keeps running in the background — on the Lock Screen and in the Dynamic Island — and is saved if you leave the app or switch tabs.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Duration")
                        .font(.subheadline.weight(.semibold))
                    Picker("Minutes", selection: $selectedMinutes) {
                        ForEach(durationOptions, id: \.self) { m in
                            Text("\(m) min").tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: 160)
                }

                Button {
                    store.startSession(plannedMinutes: selectedMinutes)
                } label: {
                    Text("Start focus")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Color.cyan))
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
    }

    /// `.animation` gives us smooth, frame-paced redraws so the progress bar fills
    /// fluidly as the remaining time shrinks — same clock that feeds the Live Activity.
    private var activeSessionContent: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 12)

            TimelineView(.animation(minimumInterval: 0.1)) { timeline in
                let now = timeline.date
                let progress = store.sessionProgress(at: now)
                VStack(spacing: 28) {
                    Text(store.formattedRemaining(at: now))
                        .font(.system(size: 56, weight: .thin, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.cyan)
                        .contentTransition(.numericText())

                    sessionProgressBar(progress: progress)
                }
            }

            Text(store.activeQuote)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Spacer()

            Button {
                showEndConfirmation = true
            } label: {
                Text("End session")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.orange.opacity(0.92)))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .padding(.horizontal, 8)
    }

    private func sessionProgressBar(progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Session progress")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.caption.monospacedDigit().weight(.medium))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.15))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.cyan, Color.orange.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * CGFloat(progress)))
                }
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 16)
    }

    /// Same structure as `TikTokBreathGateView` (dark scrim + white copy + bottom material bar with cyan primary / orange secondary).
    private var endSessionConfirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.88)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 24)

                VStack(spacing: 20) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 56, weight: .light))
                        .foregroundStyle(Color.cyan)
                        .padding(.bottom, 4)

                    Text("End session?")
                        .font(.title.bold())
                        .foregroundStyle(.white)

                    Text("Are you sure you want to end this focus session early? Time you have already completed still counts toward your daily goal and streak.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 28)

                Spacer()

                endSessionBottomBar
            }
        }
    }

    private var endSessionBottomBar: some View {
        VStack(spacing: 12) {
            Button {
                showEndConfirmation = false
            } label: {
                Text("Keep focusing")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Color.cyan))
            }

            Button {
                showEndConfirmation = false
                store.endSessionManually()
            } label: {
                Text("End session")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.orange)
                    )
            }

            Text("The Lock Screen timer stops when you end early.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .padding(.top, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
