import XCTest
import ArgumentParser
@testable import kenshincheckup

final class CheckupCommandTests: XCTestCase {
    func testDefaultConfigPath() {
        let home = "/Users/example"
        let path = CheckupCommand.defaultConfigPath(homePath: home)
        XCTAssertEqual(path, "/Users/example/.config/kenshin/config.toml")
    }

    func testParseConfigLongOption() throws {
        let options = try CheckupCommand.parse(["--config", "/tmp/config.toml"])
        XCTAssertEqual(options.config, "/tmp/config.toml")
    }

    func testParseConfigShortOption() throws {
        let options = try CheckupCommand.parse(["-c", "/tmp/config.toml"])
        XCTAssertEqual(options.config, "/tmp/config.toml")
    }

    func testResolveTildePath() {
        let resolved = CheckupCommand.resolvePath("~/kenshin/config.toml", homePath: "/Users/example")
        XCTAssertEqual(resolved, "/Users/example/kenshin/config.toml")
    }

    func testMissingConfigValueIsError() {
        XCTAssertThrowsError(try CheckupCommand.parse(["--config"]))
    }
}
