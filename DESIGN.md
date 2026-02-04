# KenshinCheckup Spec

## Principles
- Shift left. Detect problems early and fix them early.
- Make it easy to fully leverage AI/coding agents.
- Practice twada-style TDD.

Goal: Check the PC state and notify only (no fixes).
Current scope: only the `chezmoi-unmanaged` plugin (first milestone).

Main flow:
- main loads config from `~/.config/kenshin/config.toml`.
- main runs only the `chezmoi-unmanaged` plugin.
- Other plugins are out of scope for the first milestone.

Output:
- Each check prints a header line: `== <check_name> ==`.
- After the header, print a short description (1-2 lines, fewer than 5 lines total).
- Prefix each detail line with one of `[OK]  `, `[WARN]`, `[FAIL]`, `[SKIP]`.
- Keep the prefix width at 6 characters by using two trailing spaces for `[OK]  `.
- Do not interleave outputs from different checks (serial execution only).
 - Output format example:
   - `== doctor_chezmoi_unmanaged ==`
   - `Detect ignored but unmanaged config files.`
   - `[OK]  no unmanaged files`

Exit codes:
- `0`: all checks are OK or SKIP.
- `1`: any WARN or FAIL occurs.

Config:
- Load from `~/.config/kenshin/config.toml`.
- The config defines file glob patterns to scan.
  - Example:
    - `[[plugins.chezmoi_unmanaged]]` is not used; use a table.
    - `[plugins.chezmoi_unmanaged]`
    - `patterns = [".claude/config.toml", ".codex/rules/*.rules"]`

Functions / Plugins:
- doctor_chezmoi_unmanaged (plugin: `chezmoi-unmanaged`):
  - Output example:
    - `== doctor_chezmoi_unmanaged ==`
    - `Detect unmanaged config files.`
    - `[WARN] unmanaged file`
    - `  - repo: /path/to/repo`
    - `  - file: /path/to/repo/.codex/config.toml`
  - Determine `<ROOT>` from `$(ghq root)`.
  - If `ghq` / `ghq root` is unavailable, output `SKIP`.
  - Find git repos under `<ROOT>` (all repos with `.git`).
  - Do not traverse into a repo once its `.git` is found.
  - For each repo, check the paths that match the configured patterns.
    - Patterns are relative to the repo root.
    - Use glob matching for patterns (e.g. `.codex/rules/*.rules`).
  - For each matching file:
    1. Check managed via `chezmoi source-path <absolute_path>`.
    2. If not managed, report it.
  - NOTE (current behavior): git-managed files are eligible for notification.
  - TODO (future): add a git-managed ignore option so git-managed files can be excluded from notification.
    - "git managed" is defined as: the path is not ignored by `git check-ignore`.
  - TODO (future): add a pattern-based ignore list so matched files can be excluded from notification.

Constraints:
- Swift + SPM only (no Xcode dependency).
- Notify only; do not modify anything.

Notes:
- If `ghq` / `chezmoi` is not installed, output `SKIP` and end that check.
- The existence check for each command is done inside each function; do not perform a single upfront check at the start of the script.
- Unexpected errors in a check (e.g., command execution errors) should report `FAIL` and stop that function.

Implementation direction (draft):
- App/command name: kenshin.
- Language: Swift (SPM project; no Xcode dependency).
- Versioning:
  - Use `PackageBuildInfo` to embed git build metadata into the binary.
  - Git tags are the source of truth for the version string.
- Configuration:
  - Use `dduan/TOMLDecoder` to parse TOML.
- Types:
  - Use `pointfreeco/swift-tagged` for branded/phantom types to prevent mixing IDs and raw values (e.g., `ExitCode`, `PluginID`).
- Logging:
  - Use `apple/swift-log`.
  - If a backend is needed, use `sushichop/Puppy` (should run on macOS and Linux).
- Notifications:
  - macOS: use native Swift code for desktop notifications/dialogs.
  - Linux: invoke `notify-send` via shell.
- Architecture:
  - Use a plugin-based structure instead of monolithic functions.

Future:
- Candidate plugin: `doctor_git_remind` to detect push/commit omissions using `git-remind` (out of v1.0 scope).
- Candidate plugin: `doctor_brew_outdated` to report `brew outdated` results (out of v1.0 scope).
- Candidate plugin: `doctor_mise_doctor` to report `mise doctor` results (out of v1.0 scope).
- Future: adopt `swift-configuration` as the core configuration API and add a provider adapter for `dduan/TOMLDecoder`, keeping TOML working while enabling YAML and other formats later.
