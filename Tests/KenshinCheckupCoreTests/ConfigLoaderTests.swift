import Testing
@testable import KenshinCheckupCore

@Suite("Config Loader")
struct ConfigLoaderTests {
    @Test("parse config patterns")
    func parseConfigPatterns() throws {
        let text = """
        [plugins.chezmoi_unmanaged]
        patterns = [".claude/config.toml", ".codex/rules/*.rules"]
        """

        let config = try ConfigLoader.parse(text)
        #expect(config.chezmoiUnmanaged.patterns == [".claude/config.toml", ".codex/rules/*.rules"])
    }

    @Test("missing section throws")
    func missingSectionThrows() {
        let text = """
        [other.section]
        patterns = [".claude/config.toml"]
        """

        #expect(throws: ConfigError.self) {
            _ = try ConfigLoader.parse(text)
        }
    }
}
