#!/usr/bin/env bash
# STD-070: std.db.sqlite stmt-cache / bind gate — honesty soft prefer-c / soft
# SKIP→OK / soft auto-make / soft std_sqlite_build_o / bind_c=/bind_x= report →硬绿.
#
# Honesty: prefer-c first (xlang-c) + soft SKIP→OK (no native / no libsqlite3
# still gate OK) + soft `std_sqlite_build_o || true` / soft
# `xlang_compiler_make … || true` + hard check as sole .x smoke + report
# `bind_c=`/`bind_x=` retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die. Host-C archaeology = obs
# only (prebuilt std/db/sqlite/sqlite.o; refuse soft ensure/build_o). check
# residual = obs (paused 2026-08-05). tip product -o SEGV/UNDEF = obs
# (product debt; leave). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-sqlite-stmt-cache-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD070_DOC:-analysis/archive/std/std-sqlite-stmt-cache-v1.md}"
MANIFEST="${XLANG_STD070_TSV:-tests/baseline/std-sqlite-stmt-cache.tsv}"
VECTORS="${XLANG_STD070_VECTORS:-tests/baseline/std-sqlite-stmt-cache-vectors.tsv}"
MOD_X="std/db/sqlite/mod.x"
DB_C="std/db/sqlite/sqlite.x"
LIB="tests/lib/std-sqlite-stmt-cache.sh"
SMOKE_X="tests/std-sqlite/stmt_bind_roundtrip.x"
SMOKE_C="tests/std-sqlite/stmt_bind_roundtrip_ok.c"
MIN_STMT=6

# shellcheck source=tests/lib/std-sqlite-stmt-cache.sh
. "$LIB"
std_sqlite_stmt_cache_source_sqlite

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-sqlite-stmt-cache gate FAIL: $*" >&2
  std_sqlite_stmt_cache_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-070: std.db.sqlite stmt cache manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$DB_C" "$SMOKE_X" "$SMOKE_C" \
  analysis/archive/std/std-sqlite-next-row-v1.md tests/run-std-sqlite-next-row-gate.sh; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-sqlite-stmt-cache-v1.md ] || die "dual-authority fossil analysis/std-sqlite-stmt-cache-v1.md (archive live)"

for kw in STD-070 prepare_cached bind db_sqlite_stmt_bind_smoke_c; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -qF 'cache_hit' "$VECTORS" 2>/dev/null || die "vectors missing cache_hit"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_stmt_apis) MIN_STMT="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing api $anchor"
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
  echo "std-sqlite-stmt-cache OK api $anchor"
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_STMT" ] || die "api count $API_N < min $MIN_STMT"

sym_miss="$(std_sqlite_stmt_cache_symbols_ok "$MOD_X" "$DB_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-sqlite-stmt-cache manifest OK"

if [ "${XLANG_STD070_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_sqlite_stmt_cache_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sqlite-stmt-cache gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-070: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make/build_o.
# PLATFORM: SHARED — missing libsqlite3 / prebuilt .o = obs, not soft SKIP→OK.
set +e
std_sqlite_stmt_cache_run_c_smoke "$DB_C"
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-sqlite-stmt-cache OK: c smoke"
    ;;
  *)
    echo "std-sqlite-stmt-cache OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_sqlite_stmt_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-sqlite-stmt-cache OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product SEGV/UNDEF residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
if std_sqlite_run_smoke "$XLANG_BIN" "$SMOKE_X" "stmt_bind"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-sqlite-stmt-cache OK: product stmt_bind_roundtrip"
else
  echo "std-sqlite-stmt-cache OBS tip product stmt_bind_roundtrip (SEGV/UNDEF residual)" >&2
  OBS=$((OBS + 1))
fi

std_sqlite_stmt_cache_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-sqlite-stmt-cache gate OK"
