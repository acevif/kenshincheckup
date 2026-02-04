import Foundation
import Testing
@testable import KenshinCheckupCore

@Suite("Chezmoi Unmanaged Plugin")
struct ChezmoiUnmanagedPluginTests {
    private static let expectedSingleEntryCount = 1
    private static let warnDetailsCount = 2
    private static let failDetailsCount = 3
    private static let repoDetailIndex = 0
    private static let fileDetailIndex = 1
    private static let errorDetailIndex = 2

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

    @Test("skip when ghq missing")
    func skipWhenGhqMissing() {
        let runner = FakeCommandRunner()
        runner.available = ["chezmoi"]
        let plugin = ChezmoiUnmanagedPlugin(patterns: [".claude/config.toml"], commandRunner: runner, fileManager: .default)

        let result = plugin.run()

        #expect(result.entries.count == Self.expectedSingleEntryCount)
        #expect(result.entries.first?.status == .skip)
    }

    @Test("warn when unmanaged")
    func warnWhenUnmanaged() throws {
        let runner = FakeCommandRunner()
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

        runner.stub(["ghq", "root"], cwd: nil, result: CommandResult(exitCode: .EXIT_SUCCESS, stdout: tempRoot.path + "\n", stderr: ""))
        runner.stub(["chezmoi", "source-path", expectedFilePath], cwd: nil, result: CommandResult(exitCode: .EXIT_FAILURE, stdout: "", stderr: ""))

        let plugin = ChezmoiUnmanagedPlugin(patterns: [".claude/config.toml"], commandRunner: runner, fileManager: .default)
        let result = plugin.run()

        #expect(result.entries.first?.status == .warn)
        #expect(result.entries.first?.message == "unmanaged file")
        let details = result.entries.first?.details ?? []
        #expect(details.count == Self.warnDetailsCount)
        #expect(canonicalPath(extractPath(details[Self.repoDetailIndex], prefix: "repo: ")) == expectedRepoPath)
        #expect(canonicalPath(extractPath(details[Self.fileDetailIndex], prefix: "file: ")) == expectedFilePath)
    }

    @Test("fail when chezmoi command fails")
    func failWhenChezmoiCommandFails() throws {
        let runner = FakeCommandRunner()
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

        runner.stub(["ghq", "root"], cwd: nil, result: CommandResult(exitCode: .EXIT_SUCCESS, stdout: tempRoot.path + "\n", stderr: ""))
        runner.stub(
            ["chezmoi", "source-path", expectedFilePath],
            cwd: nil,
            result: CommandResult(exitCode: nil, stdout: "", stderr: "boom")
        )

        let plugin = ChezmoiUnmanagedPlugin(patterns: [".claude/config.toml"], commandRunner: runner, fileManager: .default)
        let result = plugin.run()

        #expect(result.entries.count == Self.expectedSingleEntryCount)
        #expect(result.entries.first?.status == .fail)
        #expect(result.entries.first?.message == "chezmoi command failed")
        let details = result.entries.first?.details ?? []
        #expect(details.count == Self.failDetailsCount)
        #expect(canonicalPath(extractPath(details[Self.repoDetailIndex], prefix: "repo: ")) == expectedRepoPath)
        #expect(canonicalPath(extractPath(details[Self.fileDetailIndex], prefix: "file: ")) == expectedFilePath)
        #expect(details[Self.errorDetailIndex] == "error: boom")
    }

    @Test("ok when managed")
    func okWhenManaged() throws {
        let runner = FakeCommandRunner()
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

        runner.stub(["ghq", "root"], cwd: nil, result: CommandResult(exitCode: .EXIT_SUCCESS, stdout: tempRoot.path + "\n", stderr: ""))
        runner.stub(["chezmoi", "source-path", expectedFilePath], cwd: nil, result: CommandResult(exitCode: .EXIT_SUCCESS, stdout: "", stderr: ""))

        let plugin = ChezmoiUnmanagedPlugin(patterns: [".claude/config.toml"], commandRunner: runner, fileManager: .default)
        let result = plugin.run()

        #expect(result.entries.first?.status == .ok)
    }
}
