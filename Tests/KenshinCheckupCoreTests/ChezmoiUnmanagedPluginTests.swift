import Foundation
import Testing
@testable import KenshinCheckupCore

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

    @Test("skip when ghq missing")
    func skipWhenGhqMissing() {
        let runner: FakeCommandRunner = .init()
        runner.available = ["chezmoi"]
        let plugin: ChezmoiUnmanagedPlugin = .init(
            patterns: [".claude/config.toml"],
            commandRunner: runner,
            fileManager: .default
        )

        let result = plugin.run()

        let expectedEntryCount = 1
        #expect(result.entries.count == expectedEntryCount)
        #expect(result.entries.first?.result == .skipped)
    }

    @Test("warn when unmanaged")
    func warnWhenUnmanaged() throws {
        let runner: FakeCommandRunner = .init()
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

        runner.stub(
            ["ghq", "root"],
            cwd: nil,
            result: CommandResult(
                exitCode: .EXIT_SUCCESS,
                stdout: tempRoot.path + "\n",
                stderr: ""
            )
        )
        runner.stub(
            ["chezmoi", "source-path", expectedFilePath],
            cwd: nil,
            result: CommandResult(
                exitCode: .EXIT_FAILURE,
                stdout: "",
                stderr: ""
            )
        )

        let plugin: ChezmoiUnmanagedPlugin = .init(
            patterns: [".claude/config.toml"],
            commandRunner: runner,
            fileManager: .default
        )
        let result = plugin.run()

        #expect(result.entries.first?.result == .outcome(.warn))
        #expect(result.entries.first?.message == "unmanaged file")
        let details = result.entries.first?.details ?? []
        let expectedDetailsCount = 2
        let repoDetailIndex = 0
        let fileDetailIndex = 1
        #expect(details.count == expectedDetailsCount)
        let repoDetailPath = canonicalPath(extractPath(details[repoDetailIndex], prefix: "repo: "))
        let fileDetailPath = canonicalPath(extractPath(details[fileDetailIndex], prefix: "file: "))
        #expect(repoDetailPath == expectedRepoPath)
        #expect(fileDetailPath == expectedFilePath)
    }

    @Test("fail when chezmoi command fails")
    func failWhenChezmoiCommandFails() throws {
        let runner: FakeCommandRunner = .init()
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

        runner.stub(
            ["ghq", "root"],
            cwd: nil,
            result: CommandResult(
                exitCode: .EXIT_SUCCESS,
                stdout: tempRoot.path + "\n",
                stderr: ""
            )
        )
        runner.stub(
            ["chezmoi", "source-path", expectedFilePath],
            cwd: nil,
            result: CommandResult(exitCode: nil, stdout: "", stderr: "boom")
        )

        let plugin: ChezmoiUnmanagedPlugin = .init(
            patterns: [".claude/config.toml"],
            commandRunner: runner,
            fileManager: .default
        )
        let result = plugin.run()

        let expectedEntryCount = 1
        #expect(result.entries.count == expectedEntryCount)
        #expect(result.entries.first?.result == .failed)
        #expect(result.entries.first?.message == "chezmoi command failed")
        let details = result.entries.first?.details ?? []
        let expectedDetailsCount = 3
        let repoDetailIndex = 0
        let fileDetailIndex = 1
        let errorDetailIndex = 2
        #expect(details.count == expectedDetailsCount)
        let repoDetailPath = canonicalPath(extractPath(details[repoDetailIndex], prefix: "repo: "))
        let fileDetailPath = canonicalPath(extractPath(details[fileDetailIndex], prefix: "file: "))
        #expect(repoDetailPath == expectedRepoPath)
        #expect(fileDetailPath == expectedFilePath)
        #expect(details[errorDetailIndex] == "error: boom")
    }

    @Test("ok when managed")
    func okWhenManaged() throws {
        let runner: FakeCommandRunner = .init()
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

        runner.stub(
            ["ghq", "root"],
            cwd: nil,
            result: CommandResult(
                exitCode: .EXIT_SUCCESS,
                stdout: tempRoot.path + "\n",
                stderr: ""
            )
        )
        runner.stub(
            ["chezmoi", "source-path", expectedFilePath],
            cwd: nil,
            result: CommandResult(
                exitCode: .EXIT_SUCCESS,
                stdout: "",
                stderr: ""
            )
        )

        let plugin: ChezmoiUnmanagedPlugin = .init(
            patterns: [".claude/config.toml"],
            commandRunner: runner,
            fileManager: .default
        )
        let result = plugin.run()

        #expect(result.entries.first?.result == .outcome(.ok))
    }
}
