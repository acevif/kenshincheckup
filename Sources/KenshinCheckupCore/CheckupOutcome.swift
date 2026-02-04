public enum CheckupOutcome: String, Equatable {
    /// The check ran and found no issues.
    case ok
    /// The check ran and found issues that are not fatal.
    case warn
}
