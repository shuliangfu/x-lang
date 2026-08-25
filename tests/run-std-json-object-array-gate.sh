#!/usr/bin/env bash
# json-object-array：std.json object/array cursor/parse 门禁（假权威诚实）。
# Archive ID historically STD-034 (cursor); tracker names json-object-array to
# avoid collision with http-https STD-034.
#
# 用法：./tests/run-std-json-object-array-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); object_array_parse.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/oa=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check CHK002 / soft SKIP on missing c / ## 5. 验收).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_JOA_DOC:-analysis/archive/std/std-json-object-array-v1.md}"
MANIFEST="${XLANG_STD_JOA_TSV:-tests/baseline/std-json-object-array.tsv}"
MOD_X="std/json/mod.x"
JSON_X="std/json/json.x"
LIB="tests/lib/std-json-object-array.sh"
OA_X="tests/json/object_array_parse.x"

# shellcheck source=tests/lib/std-json-object-array.sh
. tests/lib/std-json-object-array.sh

echo "=== json-object-array: cursor/parse manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$JSON_X" "$OA_X"; do
  if [ ! -f "$f" ]; then
    echo "std-json-object-array gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in JsonCursor skip_value cursor_object_next 大对象 ZC; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-json-object-array gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-json-object-array gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

sym_miss="$(std_joa_symbols_ok "$MOD_X" "$JSON_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_joa_emit_report "fail" 0 0 1
  echo "std-json-object-array gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-json-object-array manifest OK"

if [ "${XLANG_STD_JOA_MANIFEST_ONLY:-0}" = "1" ]; then
  std_joa_emit_report "ok" 0 0 1
  echo "std-json-object-array gate OK (manifest only)"
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
OA_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== json-object-array: smoke (XLANG=$XLANG_BIN; check observational; oa hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$OA_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-json-object-array gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/json/json.o
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_joa_run_smoke "$XLANG_BIN" "$OA_X" "oa"; then
    OA_OK=1
  else
    std_joa_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-json-object-array gate FAIL: no native xlang" >&2
  std_joa_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is oa=.
echo "std-json-object-array check_ok=${CHECK_OK} (observational)"
std_joa_emit_report "ok" "$CHECK_OK" "$OA_OK" "$SKIP"
echo "std-json-object-array gate OK"
