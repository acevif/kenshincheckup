# kenshincheckup Spec (v1.0)

Goal: Check the PC state and notify only (no fixes).

Main flow:
- main calls: doctor_nix_config, doctor_brew_doctor, doctor_chezmoi_unmanaged.
- doctor_mole_dry_run is TODO and not called yet.

Output:
- Each check prints a header line: `== <check_name> ==`.
- After the header, print a short description (1-2 lines, fewer than 5 lines total).
- Prefix each detail line with one of `[OK]  `, `[WARN]`, `[FAIL]`, `[SKIP]`.
- Keep the prefix width at 6 characters by using two trailing spaces for `[OK]  `.
- Do not interleave outputs from different checks (serial execution only).
 - Output format example:
   - `== doctor_nix_config ==`
   - `Nix config sanity check.`
   - `[OK]  nix config check passed`

Exit codes:
- `0`: all checks are OK or SKIP.
- `1`: any WARN or FAIL occurs.

Functions:
- doctor_nix_config: run `nix config check`. If exit non-zero, report output; otherwise print OK.
  - Output example:
    - `== doctor_nix_config ==`
    - `Nix config sanity check.`
    - `[OK]  nix config check passed`
- doctor_brew_doctor: run `brew doctor`. If exit non-zero, report output; otherwise print OK.
  - Output example:
    - `== doctor_brew_doctor ==`
    - `Homebrew health check.`
    - `[WARN] brew doctor reported issues`
- doctor_mole_dry_run: TODO: run `mole --dry-run` and show estimated reclaimable space.
  - Details will be finalized immediately before implementation.
- doctor_chezmoi_unmanaged:
  - Output example:
    - `== doctor_chezmoi_unmanaged ==`
    - `Detect ignored but unmanaged config files.`
    - `[WARN] unmanaged ignored file`
    - `  - repo: /path/to/repo`
    - `  - file: /path/to/repo/.codex/config.toml`
  - Determine `<ROOT>` from `$(ghq root)`.
  - If `ghq` / `ghq root` is unavailable, output `SKIP`.
  - Find git repos under `<ROOT>` (all repos with `.git`).
  - Do not traverse into a repo once its `.git` is found.
  - For each repo, check these paths if they exist:
    - `.codex/rules/*.rules`
    - `.codex/config.toml`
    - `.claude/settings.local.json`
  - `.codex/config.toml` must be managed by git or by chezmoi.
  - For each existing file:
    1. Check ignored via `git check-ignore`.
    2. Check managed via `chezmoi source-path <absolute_path>`.
    3. If ignored AND not managed, report it.
    4. `git check-ignore` is expected to return only 0 or 1.
    5. Any other exit status is treated as an unexpected error: report `FAIL` and stop this function.
  - "git managed" is defined as: the path is not ignored by `git check-ignore`.

Constraints:
- POSIX sh.
- Notify only; do not modify anything.

Notes:
- If `nix` / `brew` / `chezmoi` / `git` is not installed, output `SKIP` and end that check.
- The existence check for each command is done inside each function; do not perform a single upfront check at the start of the script.
- Unexpected errors in a check (e.g., command execution errors) should report `FAIL` and stop that function.

Implementation direction (draft):
- App name: kenshincheckup.
- Language: Swift.
- Notifications:
  - macOS: use native Swift code for desktop notifications/dialogs.
  - Linux: invoke `notify-send` via shell.
- Architecture:
  - Use a plugin-based structure instead of monolithic functions.

Future:
- Candidate plugin: `doctor_git_remind` to detect push/commit omissions using `git-remind` (out of v1.0 scope).
- Candidate plugin: `doctor_brew_outdated` to report `brew outdated` results (out of v1.0 scope).
- Candidate plugin: `doctor_mise_doctor` to report `mise doctor` results (out of v1.0 scope).
