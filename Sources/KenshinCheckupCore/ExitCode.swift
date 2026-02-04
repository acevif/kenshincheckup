import Tagged

/// Represents a process termination status (exit code).
///
/// This type is for exit codes observed from external processes.
/// It should not be used to model the app’s own check outcomes or status.
public typealias ExitCode = Tagged<ExitCodeTag, Int32>

public enum ExitCodeTag {}

public extension ExitCode {
    static let EXIT_SUCCESS: ExitCode = 0
    static let EXIT_FAILURE: ExitCode = 1
}

extension ExitCode: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        "ExitCode(\(rawValue))"
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: ExitCode?) {
        appendLiteral(value?.description ?? "nil")
    }
}
