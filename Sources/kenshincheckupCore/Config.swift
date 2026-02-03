import Foundation
import TOMLDecoder

public struct AppConfig: Equatable {
    public let patterns: [String]

    public init(patterns: [String]) {
        self.patterns = patterns
    }
}

public enum ConfigError: Error, Equatable {
    case missingFile
    case missingSection
    case missingPatterns
    case invalidFormat
}

public struct ConfigLoader {
    public static func load(from url: URL) throws -> AppConfig {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else {
            throw ConfigError.missingFile
        }
        return try parse(text)
    }

    public static func parse(_ text: String) throws -> AppConfig {
        let data = Data(text.utf8)
        let decoder = TOMLDecoder()
        let root: RootConfig
        do {
            root = try decoder.decode(RootConfig.self, from: data)
        } catch {
            throw ConfigError.invalidFormat
        }

        guard let plugins = root.plugins, let chezmoi = plugins.chezmoi_unmanaged else {
            throw ConfigError.missingSection
        }
        guard let patterns = chezmoi.patterns else {
            throw ConfigError.missingPatterns
        }

        return AppConfig(patterns: patterns)
    }
}

private struct RootConfig: Decodable {
    struct Plugins: Decodable {
        struct ChezmoiUnmanaged: Decodable {
            let patterns: [String]?
        }

        let chezmoi_unmanaged: ChezmoiUnmanaged?
    }

    let plugins: Plugins?
}
