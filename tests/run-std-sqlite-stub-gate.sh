#!/usr/bin/env bash
# STD-139: std.db.sqlite stub — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary /
# prefer-c) + soft auto-make (`xlang-c` / product .o) + check=/stub_c=/skip=
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# Product stub_behavior.x -o exit0 = hard run (run+=). check + C stub smoke =
# obs (no soft rebuild). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-sqlite-stub-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD139_DOC:-analysis/archive/std/std-sqlite-stub-v1.md}"
MANIFEST="${XLANG_STD139_TSV:-tests/baseline/std-sqlite-stub.tsv}"
MOD_X="std/db/sqlite/mod.x"
DB_C="std/db/sqlite/sqlite.x"
LIB="tests/lib/std-sqlite-stub.sh"
SMOKE_X="tests/std-sqlite/stub_behavior.x"
SMOKE_C="tests/std-sqlite/stub_behavior_ok.c"
README="std/db/sqlite/README.md"
SMOKE_EXPECT=0
MIN_STUB=2

# shellcheck source=tests/lib/std-sqlite-stub.sh
. "$LIB"
std_sqlite_stub_source_sqlite

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-sqlite-stub gate FAIL: $*" >&2
  std_sqlite_stub_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
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

echo "=== STD-139: sqlite stub manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-sqlite-stub-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$DB_C" "$SMOKE_X" "$SMOKE_C" "$README"; do
  [ -f "$f" ] || die "missing $f"
done

[ ! -f std/db/sqlite/sqlite.c ] || die "sqlite.c should be deleted (F-05 v3)"
[ -f compiler/seeds/runtime_sqlite_glue.from_x.c ] || die "missing runtime_sqlite_glue.from_x.c"
[ ! -f std/db/sqlite/sqlite_glue.c ] || die "sqlite_glue.c should be deleted (F-ZC)"

for kw in STD-139 DB_NOT_IMPL sqlite-o-stub db_sqlite_stub_smoke_c is_available; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing api $anchor"
  echo "std-sqlite-stub OK api $anchor"
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_STUB" ] || die "api count $API_N < min $MIN_STUB"

sym_miss="$(std_sqlite_stub_symbols_ok "$MOD_X" "$DB_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-sqlite-stub manifest OK"

if [ "${XLANG_STD139_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_sqlite_stub_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sqlite-stub gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-139: smoke (XLANG=$XLANG_BIN; check/C stub obs; stub_behavior product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std139_chk.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-sqlite-stub OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Hard path: restore product sqlite.o (face-less stub must not hide std_db_*).
# Refuse soft auto-make of xlang-c / ensure_std.
# PLATFORM: SHARED — Ubuntu UNDEF when stub .o hides face.
std_sqlite_stub_restore_product_o
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

OUT="/tmp/xlang_std139_stub_$$"
LOG="/tmp/xlang_std139_stub_build_$$.log"
if "$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
  exitcode=0
  "$OUT" >/dev/null 2>&1 || exitcode=$?
  rm -f "$OUT"
  [ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "stub_behavior.x exit=$exitcode (expect $SMOKE_EXPECT; refuse soft SKIP→OK)"
  RUN_OK=$((RUN_OK + 1))
  echo "std-sqlite-stub OK: stub_behavior"
else
  tail -20 "$LOG" 2>/dev/null >&2 || true
  die "stub_behavior.x link (refuse soft SKIP→OK)"
fi

# C stub smoke observational only (existing stub .o; no soft sqlite-o-stub make).
# PLATFORM: SHARED archaeology — hard-green signal is stub_behavior.x.
echo "=== STD-139: stub C smoke (observational; no soft rebuild) ==="
set +e
std_sqlite_stub_run_c_smoke "$DB_C"
stub_ec=$?
set -e
if [ "$stub_ec" -eq 0 ]; then
  echo "std-sqlite-stub C stub smoke OK (observational)"
else
  echo "std-sqlite-stub OBS C stub smoke (archaeology residual ec=$stub_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

std_sqlite_stub_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-sqlite-stub gate OK (host=$(ci_host_summary))"
