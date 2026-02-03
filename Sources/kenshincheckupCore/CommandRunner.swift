import Foundation

public struct CommandResult: Equatable {
    public let exitCode: Int32?
    public let stdout: String
    public let stderr: String

    public init(exitCode: Int32?, stdout: String, stderr: String) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}

public protocol CommandRunning {
    func which(_ name: String) -> Bool
    func run(_ command: [String], cwd: URL?) -> CommandResult
}

public struct SystemCommandRunner: CommandRunning {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func which(_ name: String) -> Bool {
        guard let pathValue = ProcessInfo.processInfo.environment["PATH"] else {
            return false
        }
        let parts = pathValue.split(separator: ":").map { String($0) }
        for part in parts {
            let candidate = URL(fileURLWithPath: part).appendingPathComponent(name)
            if fileManager.isExecutableFile(atPath: candidate.path) {
                return true
            }
        }
        return false
    }

    public func run(_ command: [String], cwd: URL?) -> CommandResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = command
        process.currentDirectoryURL = cwd

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        do {
            try process.run()
        } catch {
            return CommandResult(exitCode: nil, stdout: "", stderr: String(describing: error))
        }

        process.waitUntilExit()
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""

        return CommandResult(exitCode: process.terminationStatus, stdout: stdout, stderr: stderr)
    }
}
