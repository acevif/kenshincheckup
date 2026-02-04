import Foundation
@testable import KenshinCheckupCLI
import KenshinCheckupCore
import Testing

@Suite("Kenshin Integration")
struct KenshinIntegrationTests {
    @Test("version: --version")
    func versionLongOption() throws {
        let result = try runKenshin(["--version"])
        #expect(result.exitCode == .EXIT_SUCCESS)
        #expect(result.stdout.trimmed() == VersionSubcommand.versionOutput())
    }

    @Test("version: -v")
    func versionShortOption() throws {
        let result = try runKenshin(["-v"])
        #expect(result.exitCode == .EXIT_SUCCESS)
        #expect(result.stdout.trimmed() == VersionSubcommand.versionOutput())
    }

    @Test("version: subcommand")
    func versionSubcommand() throws {
        let result = try runKenshin(["version"])
        #expect(result.exitCode == .EXIT_SUCCESS)
        #expect(result.stdout.trimmed() == VersionSubcommand.versionOutput())
    }

    @Test("help: --help")
    func helpLongOption() throws {
        let result = try runKenshin(["--help"])
        #expect(result.exitCode == .EXIT_SUCCESS)
        #expect(result.stdout.lowercased().contains("usage"))
    }

    @Test("help: -h")
    func helpShortOption() throws {
        let result = try runKenshin(["-h"])
        #expect(result.exitCode == .EXIT_SUCCESS)
        #expect(result.stdout.lowercased().contains("usage"))
    }

    @Test("help: subcommand")
    func helpSubcommand() throws {
        let result = try runKenshin(["help"])
        #expect(result.exitCode == .EXIT_SUCCESS)
        #expect(result.stdout.lowercased().contains("usage"))
    }

    private func runKenshin(_ args: [String]) throws -> (stdout: String, stderr: String, exitCode: ExitCode) {
        let executableURL = try productsDirectory().appendingPathComponent("kenshin")
        let process: Process = .init()
        process.executableURL = executableURL
        process.arguments = args
        let stdout: Pipe = .init()
        let stderr: Pipe = .init()
        process.standardOutput = stdout
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let stdoutData = stdout.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderr.fileHandleForReading.readDataToEndOfFile()

        let stdoutText: String = .init(data: stdoutData, encoding: .utf8) ?? ""
        let stderrText: String = .init(data: stderrData, encoding: .utf8) ?? ""

        return (stdoutText, stderrText, ExitCode(rawValue: process.terminationStatus))
    }

    private func productsDirectory() throws -> URL {
        #if os(macOS)
            let bundle: Bundle = .init(for: TestBundleHelper.self)
            return bundle.bundleURL.deletingLastPathComponent()
        #else
            return Bundle.main.bundleURL
        #endif
    }
}
