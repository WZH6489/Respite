import ActivityKit
import Foundation

/// Shared by the app and the Live Activity widget extension (must be one module for ActivityKit).
public struct FocusSessionLiveAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var startedAt: Date
        public var endsAt: Date
        public var quote: String

        public init(startedAt: Date, endsAt: Date, quote: String) {
            self.startedAt = startedAt
            self.endsAt = endsAt
            self.quote = quote
        }
    }

    public init() {}
}
