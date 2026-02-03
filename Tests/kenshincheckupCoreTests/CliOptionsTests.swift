import XCTest
@testable import kenshincheckupCore

final class CliOptionsTests: XCTestCase {
    func testDefaultConfigPath() {
        let home = "/Users/example"
        let path = CliOptions.defaultConfigPath(homePath: home)
        XCTAssertEqual(path, "/Users/example/.config/kenshin/config.toml")
    }

    func testParseConfigLongOption() {
        let options = CliOptions.parse(["--config", "/tmp/config.toml"])
        XCTAssertEqual(options.configPath, "/tmp/config.toml")
        XCTAssertFalse(options.hasError)
    }

    func testParseConfigShortOption() {
        let options = CliOptions.parse(["-c", "/tmp/config.toml"])
        XCTAssertEqual(options.configPath, "/tmp/config.toml")
        XCTAssertFalse(options.hasError)
    }

    func testResolveTildePath() {
        let resolved = CliOptions.resolvePath("~/kenshin/config.toml", homePath: "/Users/example")
        XCTAssertEqual(resolved, "/Users/example/kenshin/config.toml")
    }

    func testMissingConfigValueIsError() {
        let options = CliOptions.parse(["--config"])
        XCTAssertTrue(options.hasError)
    }
}
