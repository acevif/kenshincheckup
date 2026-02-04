@testable import KenshinCheckupCore
import Testing

@Suite("Kenshin Final Status")
struct KenshinFinalStatusTests {
    @Test("ok when only ok outcomes")
    func okWhenOnlyOkOutcomes() {
        let status = KenshinFinalStatus.from([makeResult([.outcome(.ok)])])
        #expect(status == .ok)
    }

    @Test("hasWarnings when any warning outcome")
    func hasWarningsWhenAnyWarningOutcome() {
        let status = KenshinFinalStatus.from([makeResult([.outcome(.ok), .outcome(.warn)])])
        #expect(status == .hasWarnings)
    }

    @Test("failed when any failed result")
    func failedWhenAnyFailedResult() {
        let status = KenshinFinalStatus.from([makeResult([.outcome(.warn), .failed])])
        #expect(status == .failed)
    }

    @Test("ok when only skipped results")
    func okWhenOnlySkippedResults() {
        let status = KenshinFinalStatus.from([makeResult([.skipped])])
        #expect(status == .ok)
    }

    @Test("hasWarnings when skipped and warn")
    func hasWarningsWhenSkippedAndWarn() {
        let status = KenshinFinalStatus.from([makeResult([.skipped, .outcome(.warn)])])
        #expect(status == .hasWarnings)
    }

    @Test("failed when skipped and failed")
    func failedWhenSkippedAndFailed() {
        let status = KenshinFinalStatus.from([makeResult([.skipped, .failed])])
        #expect(status == .failed)
    }

    @Test("aggregates across multiple results")
    func aggregatesAcrossMultipleResults() {
        let results = [
            makeResult([.outcome(.ok)]),
            makeResult([.outcome(.warn)]),
        ]
        let status = KenshinFinalStatus.from(results)
        #expect(status == .hasWarnings)
    }

    @Test("failed across multiple results")
    func failedAcrossMultipleResults() {
        let results = [
            makeResult([.outcome(.warn)]),
            makeResult([.failed]),
        ]
        let status = KenshinFinalStatus.from(results)
        #expect(status == .failed)
    }

    private func makeResult(_ results: [CheckupResult]) -> CheckResult {
        let entries = results.map { CheckEntry(result: $0, message: "x") }
        return CheckResult(id: "doctor_chezmoi_unmanaged", description: "x", entries: entries)
    }
}
