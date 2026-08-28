#!/usr/bin/env bash
# STD-010: std.db.sqlite prereq runner (honesty prefer-asm).
#
# Honesty: residual soft auto-make (`xlang_compiler_make -q` then
# `xlang_compiler_make`) + prefer-c resolve + soft SKIP typeck + hard
# `xlang check` retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die. Product draft_typeck.x
# -o SEGV = obs (product debt; leave). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-sqlite.sh
set -euo pipefail
cd "$(dirname "$0")/.."

MANIFEST="${XLANG_STD_SQLITE_MANIFEST:-tests/baseline/std-sqlite-manifest.tsv}"
MOD_X="${XLANG_STD_SQLITE_MOD:-std/db/sqlite/mod.x}"
SMOKE_X="tests/std-sqlite/draft_typeck.x"

# shellcheck source=tests/lib/std-sqlite.sh
. tests/lib/std-sqlite.sh

echo "=== STD-010: std.db.sqlite prereq runner ==="

API_N=0
LAYER_N=0
RUN_OK=0
OBS=0
SKIP=0
FAIL=0

while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! std_sqlite_has_api "$MOD_X" "$anchor"; then
        echo "std-sqlite FAIL: missing API $anchor" >&2
        FAIL=$((FAIL + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      ;;
  esac
done < "$MANIFEST"

XLANG_BIN="$(std_sqlite_resolve_shu)" || {
  echo "std-sqlite FAIL: no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)" >&2
  std_sqlite_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sqlite FAIL" >&2
  exit 1
}
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# G.7: std_sqlite_run_smoke in tests/lib/std-sqlite-gate.sh.
# tip product SEGV = obs, not FAIL (same contract as the prereq gate).
if std_sqlite_run_smoke "$XLANG_BIN" "$SMOKE_X" "draft_typeck"; then
  RUN_OK=$((RUN_OK + 1))
else
  echo "std-sqlite OBS tip product draft_typeck (SEGV/UNDEF residual)" >&2
  OBS=$((OBS + 1))
fi

if [ "$FAIL" -gt 0 ]; then
  std_sqlite_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sqlite FAIL" >&2
  exit 1
fi

std_sqlite_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-sqlite OK"
