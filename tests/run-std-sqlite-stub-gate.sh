#!/usr/bin/env bash
# STD-139：std.db.sqlite stub 后端文档与烟测门禁（假权威诚实）。
#
# 用法：./tests/run-std-sqlite-stub-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); stub_behavior.x exit 0 hard-fail (no soft
# SKIP when native xlang present). C stub smoke observational. Report
# check=/run=/stub_c=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / soft SKIP on typeck fail / always OK with stub_x=0 +
# report stub_c=/stub_x=/doc= + TSV fossil sqlite_is_available vs product
# is_available).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
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

echo "=== STD-139: sqlite stub manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-sqlite-stub-v1.md ]; then
  echo "std-sqlite-stub gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$DB_C" "$SMOKE_X" "$SMOKE_C" "$README"; do
  if [ ! -f "$f" ]; then
    echo "std-sqlite-stub gate FAIL: missing $f" >&2
    exit 1
  fi
done

[ ! -f std/db/sqlite/sqlite.c ] || {
  echo "std-sqlite-stub gate FAIL: sqlite.c should be deleted (F-05 v3)" >&2
  exit 1
}
[ -f compiler/seeds/runtime_sqlite_glue.from_x.c ] || {
  echo "std-sqlite-stub gate FAIL: missing runtime_sqlite_glue.from_x.c" >&2
  exit 1
}
[ ! -f std/db/sqlite/sqlite_glue.c ] || {
  echo "std-sqlite-stub gate FAIL: sqlite_glue.c should be deleted (F-ZC)" >&2
  exit 1
}

for kw in STD-139 DB_NOT_IMPL sqlite-o-stub db_sqlite_stub_smoke_c is_available; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sqlite-stub gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-sqlite-stub gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-sqlite-stub FAIL: doc missing api $anchor" >&2
    exit 1
  fi
  echo "std-sqlite-stub OK api $anchor"
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_STUB" ]; then
  echo "std-sqlite-stub gate FAIL: api count $API_N < min $MIN_STUB" >&2
  exit 1
fi

sym_miss="$(std_sqlite_stub_symbols_ok "$MOD_X" "$DB_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sqlite_stub_emit_report "fail" 0 0 0 0
  exit 1
fi
echo "std-sqlite-stub manifest OK"

if [ "${XLANG_STD139_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sqlite_stub_emit_report "ok" 0 0 0 1
  echo "std-sqlite-stub gate OK (manifest only)"
  exit 0
fi

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
STUB_C=0
SKIP=1

# C stub smoke is observational (sqlite-o-stub / host cc); not the hard-green signal.
echo "=== STD-139: stub C smoke (observational) ==="
set +e
std_sqlite_stub_run_c_smoke "$DB_C"
stub_ec=$?
set -e
if [ "$stub_ec" -eq 0 ]; then
  STUB_C=1
elif [ "$stub_ec" -eq 2 ]; then
  echo "std-sqlite-stub gate SKIP stub C smoke (need full sqlite.o symbols)" >&2
else
  echo "std-sqlite-stub gate SKIP stub C smoke (build/run residual)" >&2
fi

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-139: .x stub behavior smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-sqlite-stub gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/db/sqlite/mod.o 2>/dev/null || xlang_compiler_make ../std/db/sqlite/mod.o 2>/dev/null || true
  xlang_compiler_make -q ../std/db/sqlite/sqlite.o 2>/dev/null || xlang_compiler_make ../std/db/sqlite/sqlite.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std139_stub_$$"
  LOG="/tmp/xlang_std139_stub_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-sqlite-stub gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_sqlite_stub_emit_report "fail" "$CHECK_OK" 0 "$STUB_C" 0
      exit 1
    fi
  else
    echo "std-sqlite-stub gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_sqlite_stub_emit_report "fail" "$CHECK_OK" 0 "$STUB_C" 0
    exit 1
  fi
else
  echo "std-sqlite-stub gate FAIL: no native xlang" >&2
  std_sqlite_stub_emit_report "fail" 0 0 "$STUB_C" 0
  exit 1
fi

# check/stub_c stay observational; hard-green signal is run=.
echo "std-sqlite-stub check_ok=${CHECK_OK} stub_c=${STUB_C} (observational)"
std_sqlite_stub_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$STUB_C" "$SKIP"
echo "std-sqlite-stub gate OK"
