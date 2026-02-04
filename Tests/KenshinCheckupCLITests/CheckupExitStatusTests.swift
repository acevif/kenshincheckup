import Testing
@testable import KenshinCheckupCLI
import KenshinCheckupCore

@Suite("Checkup Exit Status")
struct CheckupExitStatusTests {
    @Test("ok when only ok outcomes")
    func okWhenOnlyOkOutcomes() {
        let result = makeResult([.outcome(.ok)])
        let status: CheckupExitStatus = .from([result])
        #expect(status == .ok)
        #expect(status.exitCode == 0)
    }

    @Test("ok when only skipped results")
    func okWhenOnlySkippedResults() {
        let result = makeResult([.skipped])
        let status: CheckupExitStatus = .from([result])
        #expect(status == .ok)
        #expect(status.exitCode == 0)
    }

    @Test("warn when any warning outcome")
    func warnWhenAnyWarningOutcome() {
        let result = makeResult([.outcome(.ok), .outcome(.warn)])
        let status: CheckupExitStatus = .from([result])
        #expect(status == .warn)
        #expect(status.exitCode == 1)
    }

    @Test("failed when any failure")
    func failedWhenAnyFailure() {
        let result = makeResult([.outcome(.warn), .failed])
        let status: CheckupExitStatus = .from([result])
        #expect(status == .failed)
        #expect(status.exitCode == 70)
    }

    private func makeResult(_ results: [CheckupResult]) -> CheckResult {
        let entries: [CheckEntry] = results.map { .init(result: $0, message: "x") }
        return CheckResult(id: "doctor_chezmoi_unmanaged", description: "x", entries: entries)
    }
}
