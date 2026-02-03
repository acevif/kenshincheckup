import Foundation
import Testing
@testable import KenshinCheckupCLI

@Suite("Kenshin Integration")
struct KenshinIntegrationTests {
    @Test("version: --version")
    func versionLongOption() throws {
        let result = try runKenshin(["--version"])
        #expect(result.exitCode == 0)
        #expect(result.stdout.trimmed() == VersionSubcommand.versionOutput())
    }

    @Test("version: -v")
    func versionShortOption() throws {
        let result = try runKenshin(["-v"])
        #expect(result.exitCode == 0)
        #expect(result.stdout.trimmed() == VersionSubcommand.versionOutput())
    }

    @Test("version: subcommand")
    func versionSubcommand() throws {
        let result = try runKenshin(["version"])
        #expect(result.exitCode == 0)
        #expect(result.stdout.trimmed() == VersionSubcommand.versionOutput())
    }

    @Test("help: --help")
    func helpLongOption() throws {
        let result = try runKenshin(["--help"])
        #expect(result.exitCode == 0)
        #expect(result.stdout.lowercased().contains("usage"))
    }

    @Test("help: -h")
    func helpShortOption() throws {
        let result = try runKenshin(["-h"])
        #expect(result.exitCode == 0)
        #expect(result.stdout.lowercased().contains("usage"))
    }

    @Test("help: subcommand")
    func helpSubcommand() throws {
        let result = try runKenshin(["help"])
        #expect(result.exitCode == 0)
        #expect(result.stdout.lowercased().contains("usage"))
    }

    private func runKenshin(_ args: [String]) throws -> (stdout: String, stderr: String, exitCode: Int32) {
        let executableURL = try productsDirectory().appendingPathComponent("kenshin")
        let process = Process()
        process.executableURL = executableURL
        process.arguments = args
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let stdoutData = stdout.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderr.fileHandleForReading.readDataToEndOfFile()

        let stdoutText = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderrText = String(data: stderrData, encoding: .utf8) ?? ""

        return (stdoutText, stderrText, process.terminationStatus)
    }

    private func productsDirectory() throws -> URL {
        #if os(macOS)
        let bundle = Bundle(for: TestBundleHelper.self)
        return bundle.bundleURL.deletingLastPathComponent()
        #else
        return Bundle.main.bundleURL
        #endif
    }
}
