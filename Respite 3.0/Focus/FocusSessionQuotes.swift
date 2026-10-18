import Foundation

enum FocusSessionQuotes {
    static func randomQuote() -> String {
        all.randomElement() ?? all[0]
    }

    private static let all: [String] = [
        "Small steps still move you forward.",
        "Your attention is a gift—spend it on purpose.",
        "Breathe. One minute of real focus beats an hour of drift.",
        "Progress lives in the quiet between distractions.",
        "You chose this moment; let it count.",
        "Clarity comes from staying a little longer than you want to.",
        "The scroll can wait. You cannot.",
        "Focus is kindness to your future self.",
        "What you practice grows stronger.",
        "Stillness is not wasted time.",
    ]
}
