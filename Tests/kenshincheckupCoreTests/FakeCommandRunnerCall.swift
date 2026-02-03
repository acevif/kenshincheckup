import Foundation

struct FakeCommandRunnerCall: Equatable {
    let command: [String]
    let cwd: URL?
}
