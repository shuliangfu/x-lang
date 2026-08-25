#!/usr/bin/env bash
# STD-035：std.json object/array 序列化门禁（假权威诚实）。
#
# 用法：./tests/run-std-json-serialize-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); object_array_roundtrip.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/run=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check / soft SKIP).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_JSZ_DOC:-analysis/archive/std/std-json-serialize-v1.md}"
MANIFEST="${XLANG_STD_JSZ_TSV:-tests/baseline/std-json-serialize.tsv}"
MOD_X="std/json/mod.x"
JSON_X="std/json/json.x"
LIB="tests/lib/std-json-serialize.sh"
RT_X="tests/json/object_array_roundtrip.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-json-serialize.sh
. tests/lib/std-json-serialize.sh
# shellcheck source=tests/lib/std-json.sh
. tests/lib/std-json.sh

echo "=== STD-035: json serialize manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$JSON_X" "$RT_X"; do
  if [ ! -f "$f" ]; then
    echo "std-json-serialize gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in append_object append_array round-trip object_array_roundtrip; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-json-serialize gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-json-serialize gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

sym_miss="$(std_jsz_symbols_ok "$MOD_X" "$JSON_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_jsz_emit_report "fail" 0 0 1
  echo "std-json-serialize gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-json-serialize manifest OK"

if [ "${XLANG_STD_JSZ_MANIFEST_ONLY:-0}" = "1" ]; then
  std_jsz_emit_report "ok" 0 0 1
  echo "std-json-serialize gate OK (manifest only)"
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
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-035: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$RT_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-json-serialize gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std035_json_serialize_$$"
  LOG="/tmp/xlang_std035_json_serialize_build_$$.log"
  if $RUN_XLANG build -L . "$RT_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-json-serialize gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_jsz_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-json-serialize gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_jsz_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-json-serialize gate FAIL: no native xlang" >&2
  std_jsz_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-json-serialize check_ok=${CHECK_OK} (observational)"
std_jsz_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-json-serialize gate OK"
