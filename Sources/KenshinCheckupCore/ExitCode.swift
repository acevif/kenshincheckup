import Tagged

/// Represents a process termination status (exit code).
///
/// Use this type only for exit codes returned by running external processes,
/// not for internal app logic or domain results.
///
/// To terminate this CLI with a specific exit code, throw
/// `ArgumentParser.ExitCode` from a `ParsableCommand`.
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
