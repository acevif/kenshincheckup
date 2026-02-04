import Foundation

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
            let candidate: URL = .init(fileURLWithPath: part).appendingPathComponent(name)
            if fileManager.isExecutableFile(atPath: candidate.path) {
                return true
            }
        }
        return false
    }

    public func run(_ command: [String], cwd: URL?) -> CommandResult {
        let process: Process = .init()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = command
        process.currentDirectoryURL = cwd

        let stdoutPipe: Pipe = .init()
        let stderrPipe: Pipe = .init()
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

        let stdout: String = .init(data: stdoutData, encoding: .utf8) ?? ""
        let stderr: String = .init(data: stderrData, encoding: .utf8) ?? ""

        return CommandResult(exitCode: ExitCode(rawValue: process.terminationStatus), stdout: stdout, stderr: stderr)
    }
}
