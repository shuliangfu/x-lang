#!/usr/bin/env bash
# STD-010：std.db.sqlite 预研 runner（草案 API + typeck）
#
# 用法：./tests/run-std-sqlite.sh
set -e
cd "$(dirname "$0")/.."

MANIFEST="${SHUX_STD_SQLITE_MANIFEST:-tests/baseline/std-sqlite-manifest.tsv}"
MOD_SX="${SHUX_STD_SQLITE_MOD:-std/db/sqlite/mod.sx}"

# shellcheck source=tests/lib/std-sqlite.sh
. tests/lib/std-sqlite.sh

echo "=== STD-010: std.db.sqlite prereq runner ==="

API_N=0
LAYER_N=0
TYPECK_STATUS="skip"
FAIL=0

while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! std_sqlite_has_api "$MOD_SX" "$anchor"; then
        echo "std-sqlite FAIL: missing API $anchor" >&2
        FAIL=$((FAIL + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      ;;
  esac
done < "$MANIFEST"

SHUX_BIN=""
if SHUX_BIN="$(std_sqlite_resolve_shu 2>/dev/null)"; then
  make -C compiler -q 2>/dev/null || make -C compiler
  if std_sqlite_run_typeck "$SHUX_BIN" tests/std-sqlite/draft_typeck.sx draft_typeck; then
    TYPECK_STATUS="ok"
  else
    TYPECK_STATUS="fail"
    FAIL=$((FAIL + 1))
  fi
else
  echo "std-sqlite SKIP typeck (no native shux)" >&2
fi

if [ "$FAIL" -gt 0 ]; then
  std_sqlite_emit_report "fail" "$API_N" "$LAYER_N" "$TYPECK_STATUS"
  echo "std-sqlite FAIL" >&2
  exit 1
fi

std_sqlite_emit_report "ok" "$API_N" "$LAYER_N" "$TYPECK_STATUS"
echo "std-sqlite OK"
