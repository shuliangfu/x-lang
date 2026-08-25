#!/usr/bin/env bash
# STD-140：std.path 极端路径规范化门禁（假权威诚实）。
#
# 用法：./tests/run-std-path-extreme-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); extreme_clean.x exit 0 hard-fail (no soft SKIP
# when native xlang present). Report check=/run=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD140_DOC:-analysis/archive/std/std-path-extreme-v1.md}"
MANIFEST="${XLANG_STD140_MANIFEST:-tests/baseline/std-path-extreme-manifest.tsv}"
VECTORS="${XLANG_STD140_VECTORS:-tests/baseline/std-path-extreme.tsv}"
MOD_X="std/path/mod.x"
LIB="tests/lib/std-path-extreme.sh"
SMOKE_X="tests/path/extreme_clean.x"
MIN_VECTORS=8
# Designed success score (extreme_clean.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-path-extreme.sh
. "$LIB"

echo "=== STD-140: std.path extreme manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SMOKE_X" std/path/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-path-extreme gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-140 clean resolve extension_and_stem foo//baz; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-path-extreme gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-path-extreme gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

sym_miss="$(std_path_extreme_symbols_ok "$MOD_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_path_extreme_emit_report "fail" 0 0 0
  echo "std-path-extreme gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi

if ! std_path_extreme_vectors_ok "$VECTORS" "$MIN_VECTORS"; then
  std_path_extreme_emit_report "fail" 0 0 0
  exit 1
fi

for sym in clean resolve extension_and_stem join sep is_absolute; do
  if ! grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null; then
    echo "std-path-extreme gate FAIL: mod missing function ${sym}" >&2
    std_path_extreme_emit_report "fail" 0 0 0
    exit 1
  fi
done
for call in path.clean path.resolve path.extension_and_stem; do
  if ! grep -q "${call}" "$SMOKE_X" 2>/dev/null; then
    echo "std-path-extreme gate FAIL: smoke missing ${call}" >&2
    std_path_extreme_emit_report "fail" 0 0 0
    exit 1
  fi
done
echo "std-path-extreme registry OK"

if [ "${XLANG_STD140_MANIFEST_ONLY:-0}" = "1" ]; then
  std_path_extreme_emit_report "ok" 0 0 1
  echo "std-path-extreme gate OK (manifest only)"
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
  echo "=== STD-140: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-path-extreme gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std140_path_extreme_$$"
  LOG="/tmp/xlang_std140_path_extreme_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-path-extreme gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_path_extreme_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-path-extreme gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_path_extreme_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-path-extreme gate FAIL: no native xlang" >&2
  std_path_extreme_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-path-extreme check_ok=${CHECK_OK} (observational)"
std_path_extreme_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-path-extreme gate OK"
