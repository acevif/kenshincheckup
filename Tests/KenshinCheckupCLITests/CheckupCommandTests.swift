import ArgumentParser
import Testing
@testable import KenshinCheckupCLI

@Suite("Checkup Command")
struct CheckupCommandTests {
    @Test("default config path")
    func defaultConfigPath() {
        let home = "/Users/example"
        let path = CheckupSubcommand.defaultConfigPath(homePath: home)
        #expect(path == "/Users/example/.config/kenshin/config.toml")
    }

    @Test("parse --config")
    func parseConfigLongOption() throws {
        let options = try CheckupSubcommand.parse(["--config", "/tmp/config.toml"])
        #expect(options.config == "/tmp/config.toml")
    }

    @Test("parse -c")
    func parseConfigShortOption() throws {
        let options = try CheckupSubcommand.parse(["-c", "/tmp/config.toml"])
        #expect(options.config == "/tmp/config.toml")
    }

    @Test("resolve tilde path")
    func resolveTildePath() {
        let resolved = CheckupSubcommand.resolvePath("~/kenshin/config.toml", homePath: "/Users/example")
        #expect(resolved == "/Users/example/kenshin/config.toml")
    }

    @Test("missing config value is error")
    func missingConfigValueIsError() {
        #expect(throws: Error.self) {
            _ = try CheckupSubcommand.parse(["--config"])
        }
    }
}
