import Foundation
import Testing
@testable import kenshincheckupCore

@Suite("Chezmoi Unmanaged Plugin")
struct ChezmoiUnmanagedPluginTests {
    private func canonicalPath(_ path: String) -> String {
        if path.hasPrefix("/var/") {
            return "/private" + path
        }
        return path
    }

    private func extractPath(_ detail: String, prefix: String) -> String {
        guard detail.hasPrefix(prefix) else { return detail }
        return String(detail.dropFirst(prefix.count))
    }

    private final class TestCommandRunner: CommandRunning {
        struct Call: Equatable {
            let command: [String]
            let cwd: URL?
        }

        var available: Set<String> = []
        private var stubs: [String: CommandResult] = [:]
        private(set) var calls: [Call] = []

        func which(_ name: String) -> Bool {
            available.contains(name)
        }

        func stub(_ command: [String], cwd: URL?, result: CommandResult) {
            stubs[key(for: command, cwd: cwd)] = result
        }

        func run(_ command: [String], cwd: URL?) -> CommandResult {
            let call = Call(command: command, cwd: cwd)
            calls.append(call)
            if let result = stubs[key(for: command, cwd: cwd)] {
                return result
            }
            return CommandResult(exitCode: 1, stdout: "", stderr: "")
        }

        private func key(for command: [String], cwd: URL?) -> String {
            let cwdPart = cwd?.path ?? "<nil>"
            return command.joined(separator: "\u{0}") + "\u{1}" + cwdPart
        }
    }

    @Test("skip when ghq missing")
    func skipWhenGhqMissing() {
        let runner = TestCommandRunner()
        runner.available = ["chezmoi"]
        let plugin = ChezmoiUnmanagedPlugin(patterns: [".claude/config.toml"], commandRunner: runner, fileManager: .default)

        let result = plugin.run()

        #expect(result.entries.count == 1)
        #expect(result.entries.first?.status == .skip)
    }

    @Test("warn when unmanaged")
    func warnWhenUnmanaged() throws {
        let runner = TestCommandRunner()
        runner.available = ["ghq", "chezmoi"]

        let tempRoot = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let repoRoot = tempRoot.appendingPathComponent("repo")
        let gitDir = repoRoot.appendingPathComponent(".git")
        let targetDir = repoRoot.appendingPathComponent(".claude")
        let targetFile = targetDir.appendingPathComponent("config.toml")
        let expectedRepoPath = canonicalPath(repoRoot.path)
        let expectedFilePath = canonicalPath(targetFile.path)

        try FileManager.default.createDirectory(at: gitDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: targetDir, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: targetFile.path, contents: Data(), attributes: nil)

        runner.stub(["ghq", "root"], cwd: nil, result: CommandResult(exitCode: 0, stdout: tempRoot.path + "\n", stderr: ""))
        runner.stub(["chezmoi", "source-path", expectedFilePath], cwd: nil, result: CommandResult(exitCode: 1, stdout: "", stderr: ""))

        let plugin = ChezmoiUnmanagedPlugin(patterns: [".claude/config.toml"], commandRunner: runner, fileManager: .default)
        let result = plugin.run()

        #expect(result.entries.first?.status == .warn)
        #expect(result.entries.first?.message == "unmanaged file")
        let details = result.entries.first?.details ?? []
        #expect(details.count == 2)
        #expect(canonicalPath(extractPath(details[0], prefix: "repo: ")) == expectedRepoPath)
        #expect(canonicalPath(extractPath(details[1], prefix: "file: ")) == expectedFilePath)
    }

    @Test("ok when managed")
    func okWhenManaged() throws {
        let runner = TestCommandRunner()
        runner.available = ["ghq", "chezmoi"]

        let tempRoot = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let repoRoot = tempRoot.appendingPathComponent("repo")
        let gitDir = repoRoot.appendingPathComponent(".git")
        let targetDir = repoRoot.appendingPathComponent(".claude")
        let targetFile = targetDir.appendingPathComponent("config.toml")
        let expectedFilePath = canonicalPath(targetFile.path)

        try FileManager.default.createDirectory(at: gitDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: targetDir, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: targetFile.path, contents: Data(), attributes: nil)

        runner.stub(["ghq", "root"], cwd: nil, result: CommandResult(exitCode: 0, stdout: tempRoot.path + "\n", stderr: ""))
        runner.stub(["chezmoi", "source-path", expectedFilePath], cwd: nil, result: CommandResult(exitCode: 0, stdout: "", stderr: ""))

        let plugin = ChezmoiUnmanagedPlugin(patterns: [".claude/config.toml"], commandRunner: runner, fileManager: .default)
        let result = plugin.run()

        #expect(result.entries.first?.status == .ok)
    }
}
