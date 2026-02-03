import XCTest
@testable import kenshincheckupCore

final class ConfigLoaderTests: XCTestCase {
    func testParseConfigPatterns() throws {
        let text = """
        [plugins.chezmoi_unmanaged]
        patterns = [".claude/config.toml", ".codex/rules/*.rules"]
        """

        let config = try ConfigLoader.parse(text)
        XCTAssertEqual(config.patterns, [".claude/config.toml", ".codex/rules/*.rules"])
    }

    func testMissingSectionThrows() {
        let text = """
        [other.section]
        patterns = [".claude/config.toml"]
        """

        XCTAssertThrowsError(try ConfigLoader.parse(text)) { error in
            XCTAssertEqual(error as? ConfigError, .missingSection)
        }
    }
}
