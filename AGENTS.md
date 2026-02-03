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
- You may commit changes without asking for permission.
