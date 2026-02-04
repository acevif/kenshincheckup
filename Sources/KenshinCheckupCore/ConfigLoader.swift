import Foundation
import TOMLDecoder

public struct ConfigLoader {
    public static func load(from url: URL) throws -> AppConfig {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else {
            throw ConfigError.missingFile
        }
        return try parse(text)
    }

    public static func parse(_ text: String) throws -> AppConfig {
        let data: Data = .init(text.utf8)
        let decoder: TOMLDecoder = .init()
        let root: RootConfigDecoding
        do {
            root = try decoder.decode(RootConfigDecoding.self, from: data)
        } catch {
            throw ConfigError.invalidFormat
        }

        guard let plugins = root.plugins, let chezmoi = plugins.chezmoi_unmanaged else {
            throw ConfigError.missingSection
        }
        guard let patterns = chezmoi.patterns else {
            throw ConfigError.missingPatterns
        }

        return AppConfig(chezmoiUnmanaged: ChezmoiUnmanagedConfig(patterns: patterns))
    }
}
