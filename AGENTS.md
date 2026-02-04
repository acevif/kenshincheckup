# AGENTS.md

NOTE: This project is under development; see `DESIGN.md` for the current specification. Remove this note before release.

## Project Rules

- Follow `DESIGN.md` and `README.md`.
- Use Swift + SPM only (no Xcode dependency).
- This project follows twada-style TDD:
  - Write a failing test first (Red).
  - Implement the minimum change to pass (Green).
  - Refactor while keeping tests green (Refactor).
- Prefer small, focused unit tests over complex integration tests.
- Run `swift test` after every code change.
- Tests must use Swift Testing (`Testing` module); do not use `XCTestCase`.
- Do not put developer-facing details in `README.md`; keep them in `AGENTS.md`.
- Commit changes without asking for permission; decide on your own when to commit.

## Coding Style

- One type per file.
  - This is a guiding principle, not a hard rule.
  - Extensions are not types and do not count against this rule.
  - Small helper types (e.g., `PluginIDTag`) may live alongside their primary type.
- Prefer explicit type annotations on the left-hand side when the right-hand side can omit the type.
  - Example: `static let EXIT_SUCCESS: ExitCode = 0` (instead of `static let EXIT_SUCCESS = ExitCode(rawValue: 0)`).
  - Example: `let rootURL: URL = .init(fileURLWithPath: rootPath)` (instead of `let rootURL = URL(fileURLWithPath: rootPath)`).
