public enum CheckupResult: Equatable {
    /// The check ran to completion and produced a domain outcome.
    /// This does not represent execution failures; use `failed` for those.
    case outcome(CheckupOutcome)
    /// The check did not run, but skipping is acceptable and not a problem.
    case skipped
    /// The check could not be executed or crashed; this is a problem in the check itself.
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
