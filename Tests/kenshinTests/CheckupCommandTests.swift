import ArgumentParser
import Testing
@testable import kenshin

@Suite("Checkup Command")
struct CheckupCommandTests {
    @Test("default config path")
    func defaultConfigPath() {
        let home = "/Users/example"
        let path = CheckupCommand.defaultConfigPath(homePath: home)
        #expect(path == "/Users/example/.config/kenshin/config.toml")
    }

    @Test("parse --config")
    func parseConfigLongOption() throws {
        let options = try CheckupCommand.parse(["--config", "/tmp/config.toml"])
        #expect(options.config == "/tmp/config.toml")
    }

    @Test("parse -c")
    func parseConfigShortOption() throws {
        let options = try CheckupCommand.parse(["-c", "/tmp/config.toml"])
        #expect(options.config == "/tmp/config.toml")
    }

    @Test("resolve tilde path")
    func resolveTildePath() {
        let resolved = CheckupCommand.resolvePath("~/kenshin/config.toml", homePath: "/Users/example")
        #expect(resolved == "/Users/example/kenshin/config.toml")
    }

    @Test("missing config value is error")
    func missingConfigValueIsError() {
        #expect(throws: Error.self) {
            _ = try CheckupCommand.parse(["--config"])
        }
    }
}
