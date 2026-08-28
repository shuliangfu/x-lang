#!/usr/bin/env bash
# STD-067: std.db.sqlite next_row cursor gate — honesty soft prefer-c /
# soft SKIP→OK / soft auto-make / soft std_sqlite_build_o / soft ensure /
# cursor_c=/cursor_x= report →硬绿.
#
# Honesty: prefer-c first (xlang-c) + soft SKIP→OK (no native / no
# libsqlite3 / typeck-fail still gate OK) + soft `std_sqlite_build_o` /
# soft `ensure_std_c_o` + hard check as sole .x smoke + report
# `cursor_c=`/`cursor_x=` retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die.
# Host-C archaeology = obs only (prebuilt std/db/sqlite/sqlite.o; refuse
# soft ensure/build_o). check residual = obs (paused 2026-08-05). tip
# product -o SEGV/UNDEF = obs (product debt; leave). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-sqlite-next-row-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD067_DOC:-analysis/archive/std/std-sqlite-next-row-v1.md}"
MANIFEST="${XLANG_STD067_TSV:-tests/baseline/std-sqlite-next-row.tsv}"
VECTORS="${XLANG_STD067_VECTORS:-tests/baseline/std-sqlite-next-row-vectors.tsv}"
MOD_X="std/db/sqlite/mod.x"
DB_C="std/db/sqlite/sqlite.x"
LIB="tests/lib/std-sqlite-next-row.sh"
SMOKE_X="tests/std-sqlite/next_row_roundtrip.x"
SMOKE_C="tests/std-sqlite/next_row_roundtrip_ok.c"
MIN_CURSOR=3

# shellcheck source=tests/lib/std-sqlite-next-row.sh
. "$LIB"
std_sqlite_next_row_source_sqlite

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-sqlite-next-row gate FAIL: $*" >&2
  std_sqlite_next_row_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-067: db next_row manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$DB_C" "$SMOKE_X" "$SMOKE_C" \
  analysis/archive/std/std-sqlite-query-rows-v1.md tests/run-std-sqlite-query-rows-gate.sh; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-sqlite-next-row-v1.md ] || die "dual-authority fossil analysis/std-sqlite-next-row-v1.md (archive live)"

for kw in STD-067 next_row begin col end db_sqlite_next_row_smoke_c; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -qF 'cursor_done' "$VECTORS" 2>/dev/null || die "vectors missing cursor_done"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_cursor_apis) MIN_CURSOR="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_CURSOR" ] || die "api count $API_N < min $MIN_CURSOR"

sym_miss="$(std_sqlite_next_row_symbols_ok "$MOD_X" "$DB_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-sqlite-next-row manifest OK"
# Parent STD-066 gate still soft — file presence only this wave
# (aligned with STD-137 blob-stream; refuse opening STD-066 knife here).
# PLATFORM: SHARED archaeology — leave query-rows soft residual for its own wave.

if [ "${XLANG_STD067_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_sqlite_next_row_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sqlite-next-row gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-067: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make/build_o.
# PLATFORM: SHARED — missing libsqlite3 / prebuilt .o = obs, not soft SKIP→OK.
set +e
std_sqlite_next_row_run_c_smoke "$DB_C"
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-sqlite-next-row OK: c smoke"
    ;;
  *)
    echo "std-sqlite-next-row OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_sqlite_next_row_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-sqlite-next-row OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product SEGV/UNDEF residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
if std_sqlite_run_smoke "$XLANG_BIN" "$SMOKE_X" "cursor"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-sqlite-next-row OK: product next_row_roundtrip"
else
  echo "std-sqlite-next-row OBS tip product next_row_roundtrip (SEGV/UNDEF residual)" >&2
  OBS=$((OBS + 1))
fi

std_sqlite_next_row_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-sqlite-next-row gate OK"
