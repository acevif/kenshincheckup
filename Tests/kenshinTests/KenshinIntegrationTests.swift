import XCTest
@testable import kenshin

final class KenshinIntegrationTests: XCTestCase {
    func testVersionLongOption() throws {
        let result = try runKenshin(["--version"])
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout.trimmed(), KenshinCheckupCommand.versionOutput())
    }

    func testVersionShortOption() throws {
        let result = try runKenshin(["-v"])
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout.trimmed(), KenshinCheckupCommand.versionOutput())
    }

    func testVersionSubcommand() throws {
        let result = try runKenshin(["version"])
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertEqual(result.stdout.trimmed(), KenshinCheckupCommand.versionOutput())
    }

    func testHelpLongOption() throws {
        let result = try runKenshin(["--help"])
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.stdout.lowercased().contains("usage"))
    }

    func testHelpShortOption() throws {
        let result = try runKenshin(["-h"])
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.stdout.lowercased().contains("usage"))
    }

    func testHelpSubcommand() throws {
        let result = try runKenshin(["help"])
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.stdout.lowercased().contains("usage"))
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
        let bundle = Bundle(for: type(of: self))
        return bundle.bundleURL.deletingLastPathComponent()
        #else
        return Bundle.main.bundleURL
        #endif
    }
}

private extension String {
    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
