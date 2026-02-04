import Tagged

public enum ExitCodeTag {}

public typealias ExitCode = Tagged<ExitCodeTag, Int32>

public extension ExitCode {
    static let success = ExitCode(rawValue: 0)
    static let failure = ExitCode(rawValue: 1)
}
