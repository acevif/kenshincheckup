public struct CommandResult: Equatable {
    public let exitCode: ExitCode?
    public let stdout: String
    public let stderr: String

    public init(exitCode: ExitCode?, stdout: String, stderr: String) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}
