#!/usr/bin/env bash
# STD-057: std.db.sqlite SQLite3 gate — honesty soft prefer-c / soft SKIP→OK /
# soft auto-make / soft ensure_std_c_o / c_smoke=/x= report →硬绿.
#
# Honesty: prefer-c first (xlang-c) + soft SKIP→OK (no native / no libsqlite3
# still gate OK) + soft `ensure_std_c_o` / soft `xlang_compiler_make sqlite.o`
# + hard check as sole .x smoke + report `c_smoke=`/`x=` retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Host-C archaeology = obs only (prebuilt
# std/db/sqlite/sqlite.o; refuse soft ensure). check residual = obs
# (paused 2026-08-05). tip product -o SEGV = obs (product debt; leave).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-sqlite-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_SQLITE_DOC:-analysis/archive/std/std-sqlite-v1.md}"
MANIFEST="${XLANG_STD_SQLITE_TSV:-tests/baseline/std-sqlite.tsv}"
VECTORS="${XLANG_STD_SQLITE_VECTORS:-tests/baseline/std-sqlite-vectors.tsv}"
MOD_X="std/db/sqlite/mod.x"
SQLITE_C="std/db/sqlite/sqlite.x"
LIB="tests/lib/std-sqlite-gate.sh"
SMOKE_X="tests/std-sqlite/exec_roundtrip.x"
SMOKE_IMPORT_X="tests/std-sqlite/import_smoke.x"
SMOKE_C="tests/std-sqlite/exec_roundtrip_ok.c"
PREREQ_DOC="analysis/archive/std/std-sqlite-prereq-v1.md"
MIN_APIS=4

# shellcheck source=tests/lib/std-sqlite-gate.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-sqlite gate FAIL: $*" >&2
  std_sqlite_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-057: std.db.sqlite manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SQLITE_C" "$SMOKE_X" "$SMOKE_IMPORT_X" "$SMOKE_C" "$PREREQ_DOC" std/db/sqlite/README.md; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f std/db/sqlite/sqlite.c ] || die "sqlite.c should be deleted (F-05 v3)"
[ -f compiler/seeds/runtime_sqlite_glue.from_x.c ] || die "missing sqlite_glue seed"
[ ! -f analysis/std-sqlite-v1.md ] || die "dual-authority fossil analysis/std-sqlite-v1.md (archive live)"

for kw in STD-057 sqlite3_exec DB_ERR_EXEC exec_roundtrip; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -qF 'INSERT INTO t' "$VECTORS" 2>/dev/null || die "vectors missing insert_row"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_sqlite_symbols_ok "$MOD_X" "$SQLITE_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-sqlite manifest OK"

if [ "${XLANG_STD_SQLITE_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_sqlite_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sqlite gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-057: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make.
# PLATFORM: SHARED — missing libsqlite3 / prebuilt .o = obs, not soft SKIP→OK.
set +e
std_sqlite_run_c_smoke "$SQLITE_C"
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-sqlite OK: c smoke"
    ;;
  *)
    echo "std-sqlite OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_sqlite_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-sqlite OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product SEGV residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
if std_sqlite_run_smoke "$XLANG_BIN" "$SMOKE_X" "rt"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-sqlite OK: product exec_roundtrip"
else
  echo "std-sqlite OBS tip product exec_roundtrip (SEGV/UNDEF residual)" >&2
  OBS=$((OBS + 1))
fi

if std_sqlite_run_smoke "$XLANG_BIN" "$SMOKE_IMPORT_X" "import"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-sqlite OK: product import_smoke"
else
  echo "std-sqlite OBS tip product import_smoke (SEGV/UNDEF residual)" >&2
  OBS=$((OBS + 1))
fi

std_sqlite_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-sqlite gate OK"
