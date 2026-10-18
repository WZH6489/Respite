import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var interventions: InterventionManager
    @ObservedObject private var focusStore = FocusSessionStore.shared
    @State private var showFocusSession = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    focusSessionCard

                    FocusDashboardSummaryCard()

                    interventionCard(
                        icon: "logo.tiktok",
                        systemIcon: "wind",
                        title: "Breathing gate",
                        description: "Five slow breaths (2s in, 3s out) — the same flow as Screen Time and idle prompts.",
                        accentColor: .black,
                        action: { interventions.presentBreathingGate(.externalLaunch) }
                    )

                    interventionCard(
                        icon: "🧩",
                        systemIcon: nil,
                        title: "Puzzle Break",
                        description: "Solve a quick math puzzle to engage your brain instead of scrolling.",
                        accentColor: .purple,
                        action: { interventions.triggerPuzzleBreak() }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .navigationTitle("Respite")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showFocusSession) {
                FocusSessionView()
                    .environmentObject(FocusSessionStore.shared)
            }
            .onAppear {
                focusStore.reloadFromDisk()
            }
        }
    }

    /// When a session is active, show a live-updating "Resume focus session" card so the user
    /// can jump back into the sheet to see the countdown. Otherwise show the standard start card.
    @ViewBuilder
    private var focusSessionCard: some View {
        if focusStore.hasActiveSession {
            Button { showFocusSession = true } label: {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let remaining = focusStore.formattedRemaining(at: context.date)
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.cyan.opacity(0.15))
                                .frame(width: 56, height: 56)
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(Color.cyan)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Focus session in progress")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("\(remaining) left — tap to return.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(.secondarySystemGroupedBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(Color.cyan.opacity(0.45), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                    )
                }
            }
            .buttonStyle(.plain)
        } else {
            interventionCard(
                icon: "leaf.fill",
                systemIcon: "timer",
                title: "Focus session",
                description: "A quiet countdown that keeps running in the background and on your Lock Screen.",
                accentColor: .cyan,
                action: { showFocusSession = true }
            )
        }
    }

    @ViewBuilder
    private func interventionCard(
        icon: String,
        systemIcon: String?,
        title: String,
        description: String,
        accentColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(accentColor.opacity(accentColor == .black ? 1.0 : 0.12))
                        .frame(width: 56, height: 56)

                    if let sys = systemIcon {
                        Image(systemName: sys)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(accentColor == .black ? .white : accentColor)
                    } else {
                        Text(icon)
                            .font(.system(size: 28))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
            )
        }
        .buttonStyle(.plain)
    }
}
