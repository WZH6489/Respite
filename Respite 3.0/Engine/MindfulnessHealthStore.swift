import Combine
import Foundation
import HealthKit

/// Writes mindful-session samples to Apple Health after the user completes
/// a Respite breathing intervention.
///
/// HealthKit is a share-only integration here: Respite only *writes* mindful
/// sessions; it never reads other health data. Authorization is opt-in and
/// driven from `SettingsView`. If the user has not enabled HealthKit we
/// simply no-op so the rest of the regulation flow is never blocked.
@MainActor
final class MindfulnessHealthStore: ObservableObject {
    static let shared = MindfulnessHealthStore()

    enum AuthState: Equatable {
        case unknown
        case unavailable
        case notDetermined
        case denied
        case authorized
    }

    @Published private(set) var authState: AuthState = .unknown
    @Published private(set) var lastErrorMessage: String?

    private let store: HKHealthStore?
    private let mindfulType: HKCategoryType?

    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.store = HKHealthStore()
            self.mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession)
        } else {
            self.store = nil
            self.mindfulType = nil
        }
        refreshAuthState()
    }

    /// Whether we can meaningfully request or persist mindful samples.
    var isAvailable: Bool { store != nil && mindfulType != nil }

    /// Refresh `authState` from HealthKit. iOS never reports "authorized" for
    /// share-only types (privacy), so we treat `notDetermined` and `denied`
    /// as the real signal and anything else as effectively enabled.
    func refreshAuthState() {
        guard let store, let mindfulType else {
            authState = .unavailable
            return
        }
        let status = store.authorizationStatus(for: mindfulType)
        switch status {
        case .notDetermined:
            authState = .notDetermined
        case .sharingDenied:
            authState = .denied
        case .sharingAuthorized:
            authState = .authorized
        @unknown default:
            authState = .notDetermined
        }
    }

    /// Presents the HealthKit share-sheet for `.mindfulSession` write access.
    ///
    /// iOS will show the permission sheet only once per type; after that the
    /// user has to toggle access in Settings > Health > Data Access & Devices.
    /// We surface that nuance to the caller via `lastErrorMessage`.
    func requestAuthorization() async {
        guard let store, let mindfulType else {
            lastErrorMessage = "HealthKit isn't available on this device."
            authState = .unavailable
            return
        }
        do {
            try await store.requestAuthorization(toShare: [mindfulType], read: [])
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }
        refreshAuthState()
    }

    /// Writes a mindful session spanning `[start, end]` to HealthKit. Called
    /// from `BreathworkTimerView` when the user finishes all breathing cycles.
    /// Silently no-ops if HealthKit is unavailable or the user has denied
    /// sharing; errors are reported through `lastErrorMessage`.
    func logMindfulSession(start: Date, end: Date) async {
        guard let store, let mindfulType else { return }
        guard end > start else { return }
        guard store.authorizationStatus(for: mindfulType) == .sharingAuthorized else { return }

        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end
        )
        do {
            try await store.save(sample)
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }
}
