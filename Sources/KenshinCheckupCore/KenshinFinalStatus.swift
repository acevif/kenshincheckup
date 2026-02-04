public enum KenshinFinalStatus: Equatable {
    /// All checks completed without warnings.
    case ok
    /// At least one check completed with warnings.
    case hasWarnings
    /// At least one check failed to produce a valid outcome.
    case failed
}

public extension KenshinFinalStatus {
    static func from(_ results: [CheckResult]) -> KenshinFinalStatus {
        let entries = results.flatMap(\.entries)
        if entries.contains(where: { $0.result == .failed }) {
            return .failed
        }
        if entries.contains(where: { if case .outcome(.warn) = $0.result { true } else { false } }) {
            return .hasWarnings
        }
        return .ok
    }
}
