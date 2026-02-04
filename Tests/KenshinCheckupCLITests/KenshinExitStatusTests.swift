@testable import KenshinCheckupCLI
import KenshinCheckupCore
import Testing

@Suite("Kenshin Exit Status")
struct KenshinExitStatusTests {
    @Test("ok maps to exit code 0")
    func okMapsToZero() {
        let status = KenshinExitStatus.from(.ok)
        #expect(status == .ok)
        #expect(status.exitCode == 0)
    }

    @Test("hasWarnings maps to exit code 1")
    func hasWarningsMapsToOne() {
        let status = KenshinExitStatus.from(.hasWarnings)
        #expect(status == .hasWarnings)
        #expect(status.exitCode == 1)
    }

    @Test("failed maps to exit code 70")
    func failedMapsToSeventy() {
        let status = KenshinExitStatus.from(.failed)
        #expect(status == .failed)
        #expect(status.exitCode == 70)
    }
}
