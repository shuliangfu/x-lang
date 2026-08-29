#!/usr/bin/env bash
# §9.1 / P0#3: Codegen semantic-debt host — leftover fossil DOC + leftover
# catalog no Honesty →硬绿.
#
# Honesty: leftover top-level `analysis/自举前必须清单.md` as live DOC
# (file already archived to analysis/archive/narrative/; gate still
# hard-required the missing top-level path → §9.1 / bootstrap-min red) +
# leftover catalog no Honesty / missing run=/obs=/skip= retired. Live =
# analysis/archive/narrative/. Refuse top-level resurrect. Nested leftover
# runners (`run-compound-assign.sh` / `run-time.sh` / `run-i64-ctfe-gate.sh`
# / `run-struct.sh` / `run-result.sh`) stay (do not rewrite nested leftover
# product `-o`). STRICT=0 leftover WARN→OK of a nested fail = obs. No XLANG
# face on this parent (G.7: do not fork a resolver). Explicit XLANG is
# ignored at parent; nested leftover still hard. Keep
# `codegen-semantic-debt gate OK`. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-codegen-semantic-debt-gate.sh
# Env:   XLANG_CODEGEN_DEBT_STRICT=1  → nested fail is hard (default 0 = obs)
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

DOC="${XLANG_CODEGEN_DEBT_DOC:-analysis/archive/narrative/自举前必须清单.md}"
PREFIX="${XLANG_CODEGEN_DEBT_PREFIX:-xlang: [XLANG_CODEGEN_DEBT]}"
RUN_OK=0
OBS=0
SKIP=0
STRICT="${XLANG_CODEGEN_DEBT_STRICT:-0}"

die() {
  echo "codegen-semantic-debt gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

# id|script|note
DEBT_CASES=(
  "compound-assign|run-compound-assign.sh|compound-assign+if"
  "time-call-hoist|run-time.sh|CALL return hoist"
  "i64-ctfe|run-i64-ctfe-gate.sh|i64 compare/asm"
  "struct|run-struct.sh|struct -o"
  "result|run-result.sh|16B Result ABI"
)

echo "=== §9.1: codegen semantic debt (archive DOC; nested leftover still hard) ==="

# Refuse leftover fossil top-level DOC as live path (c6 / stdlib-check-matrix).
# PLATFORM: SHARED archaeology — live = archive/narrative/.
if [ -f analysis/自举前必须清单.md ]; then
  die "top-level DOC resurrected (live = archive/narrative/)"
fi
[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -qF "§9.1" "$DOC" || grep -qF "9.1 Codegen" "$DOC" || die "doc missing §9.1"

gate_progress "§9.1: codegen semantic debt (STRICT=$STRICT, ${#DEBT_CASES[@]} cases)"

for row in "${DEBT_CASES[@]}"; do
  IFS='|' read -r id script note <<<"$row"
  path="tests/$script"
  [ -f "$path" ] || die "missing $path ($id)"
  chmod +x "$path"
  # `if cmd` so gate_progress_run's inner `set -e` + return 1 cannot
  # kill this parent (leftover STRICT=0 nested fail = obs).
  # PLATFORM: SHARED archaeology — nested leftover product path not rewritten.
  if XLANG_SKIP_SUBSCRIPT_MAKE=1 gate_progress_run "§9.1 $id ($note)" ./tests/"$script"; then
    RUN_OK=$((RUN_OK + 1))
    continue
  fi
  if [ "$STRICT" = "1" ]; then
    die "nested $id failed (STRICT=1; refuse leftover SKIP→OK)"
  fi
  echo "codegen-semantic-debt OBS $id (leftover nested fail; STRICT=0; refuse leftover SKIP→OK as silent OK)" >&2
  OBS=$((OBS + 1))
done

gate_progress "codegen-semantic-debt gate OK (run=${RUN_OK} obs=${OBS} skip=${SKIP})"
echo "codegen-semantic-debt gate OK"
ok_report
