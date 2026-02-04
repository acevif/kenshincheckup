public enum CheckupResult: Equatable {
    /// The check ran to completion and produced a domain outcome.
    /// This does not represent execution failures; use `failed` for those.
    case outcome(CheckupOutcome)
    /// The check did not run, but skipping is acceptable and not a problem.
    case skipped
    /// The check did not produce a valid outcome due to an error.
    /// This includes failures before execution, during execution,
    /// or after execution when the outcome is invalid or unclassifiable.
    case failed
}

public extension CheckupResult {
    var isIssue: Bool {
        switch self {
        case .outcome(.warn), .failed:
            return true
        case .outcome(.ok), .skipped:
            return false
        }
    }
}
