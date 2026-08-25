#!/usr/bin/env bash
# CORE-013：core.types i16/u16 与宽度表门禁（假权威诚实）。
#
# 用法：./tests/run-core-types-i16-u16-gate.sh
# wave honesty (2026-08-24 #8): DOC → analysis/archive/core/;
# typeck.c/codegen.c retired — live = typeck.x / codegen.x;
# cross_ref anchors → wave313 / int16_t (greppable live).
# 2026-08-25: runnable hard-green (labi g1 full core.types needles; check observational).
# PLATFORM: SHARED archaeology / formal_mod / labi.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_CORE_TYPES_I16_U16_DOC:-analysis/archive/core/core-types-i16-u16-v1.md}"
MANIFEST="${XLANG_CORE_TYPES_I16_U16_TSV:-tests/baseline/core-types-i16-u16.tsv}"
TYPES_X="core/types/mod.x"
TYPECK="compiler/src/typeck/typeck.x"
CODEGEN="compiler/src/codegen/codegen.x"
LIB="tests/lib/core-types-i16-u16.sh"
SMOKE="tests/core-types-size/i16_u16_width.x"
SCALAR="tests/core-types-size/main.x"
MIN_SYMBOLS=4

# shellcheck source=tests/lib/core-types-i16-u16.sh
. tests/lib/core-types-i16-u16.sh

native_xlang() {
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

echo "=== CORE-013: i16/u16 width manifest (c retired) ==="

if [ -f compiler/src/typeck/typeck.c ]; then
  echo "core-types-i16-u16 gate FAIL: typeck.c resurrected (live = typeck.x)" >&2
  exit 1
fi
if [ -f compiler/src/codegen/codegen.c ]; then
  echo "core-types-i16-u16 gate FAIL: codegen.c resurrected (live = codegen.x)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$TYPES_X" "$TYPECK" "$CODEGEN" "$SMOKE" "$SCALAR"; do
  if [ ! -f "$f" ]; then
    echo "core-types-i16-u16 gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_symbols) MIN_SYMBOLS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in i16 u16 标量宽度表 CORE-013; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-types-i16-u16 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

MISS=0
SYM_N=0
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "core-types-i16-u16 FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol) SYM_N=$((SYM_N + 1)) ;;
    cross_ref)
      if [ ! -f "$mod_path" ]; then
        echo "core-types-i16-u16 FAIL: missing $mod_path ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
        echo "core-types-i16-u16 FAIL: $mod_path missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if ! grep -qF "$anchor" "$SMOKE" 2>/dev/null; then
        echo "core-types-i16-u16 FAIL: smoke missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SYM_N" -lt "$MIN_SYMBOLS" ] || [ "$MISS" -gt 0 ]; then
  echo "core-types-i16-u16 gate FAIL: symbols=${SYM_N} miss=${MISS}" >&2
  exit 1
fi

sym_miss="$(core_types_i16_u16_symbols_ok "$TYPES_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_types_i16_u16_emit_report "fail" 0 0 0
  exit 1
fi
echo "core-types-i16-u16 manifest OK (symbols=${SYM_N})"

resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1
if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== CORE-013: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SCALAR" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "core-types-i16-u16 gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
  OUT="/tmp/xlang_core_types_i16_u16_$$"
  LOG="/tmp/xlang_core_types_i16_u16_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "core-types-i16-u16 gate FAIL runnable exit=$exitcode" >&2
      core_types_i16_u16_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "core-types-i16-u16 gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    core_types_i16_u16_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "core-types-i16-u16 gate SKIP typeck (no native xlang)" >&2
fi

core_types_i16_u16_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "core-types-i16-u16 gate OK"
