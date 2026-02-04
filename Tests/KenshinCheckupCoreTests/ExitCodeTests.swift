import Testing
import KenshinCheckupCore

#if canImport(Darwin)
import Darwin
#endif

#if canImport(Glibc)
import Glibc
#endif

@Suite("ExitCode")
struct ExitCodeTests {
    @Test("EXIT_SUCCESS matches C stdlib constants")
    func exitSuccessMatchesCStdlib() {
        #if canImport(Darwin)
        #expect(Int32(Darwin.EXIT_SUCCESS) == ExitCode.EXIT_SUCCESS.rawValue)
        #endif
        #if canImport(Glibc)
        #expect(Int32(Glibc.EXIT_SUCCESS) == ExitCode.EXIT_SUCCESS.rawValue)
        #endif
        #if canImport(Darwin) && canImport(Glibc)
        #expect(Darwin.EXIT_SUCCESS == Glibc.EXIT_SUCCESS)
        #endif
    }

    @Test("EXIT_FAILURE matches C stdlib constants")
    func exitFailureMatchesCStdlib() {
        #if canImport(Darwin)
        #expect(Int32(Darwin.EXIT_FAILURE) == ExitCode.EXIT_FAILURE.rawValue)
        #endif
        #if canImport(Glibc)
        #expect(Int32(Glibc.EXIT_FAILURE) == ExitCode.EXIT_FAILURE.rawValue)
        #endif
        #if canImport(Darwin) && canImport(Glibc)
        #expect(Darwin.EXIT_FAILURE == Glibc.EXIT_FAILURE)
        #endif
    }
}
