#!/usr/bin/env bash
# STD-028：std.runtime panic 钩子跨平台门禁
#
# 用法：./tests/run-std-runtime-panic-hook-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_RUNTIME_PANIC_DOC:-analysis/std-runtime-panic-hook-v1.md}"
MANIFEST="${SHUX_STD_RUNTIME_PANIC_TSV:-tests/baseline/std-runtime-panic-hook.tsv}"
RUNTIME_X="std/runtime/mod.x"
RUNTIME_IMPL="std/runtime/runtime.x"
README="std/runtime/README.md"
LIB="tests/lib/std-runtime-panic-hook.sh"
HOOK_X="tests/exc/panic_hook_align.x"
READY_X="tests/exc/runtime_ready.x"
EXC_GATE="tests/run-exc-panic-abort-gate.sh"

# shellcheck source=tests/lib/std-runtime-panic-hook.sh
. tests/lib/std-runtime-panic-hook.sh

echo "=== STD-028: runtime panic hook manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$RUNTIME_X" "$RUNTIME_IMPL" "$README" \
  "$HOOK_X" "$READY_X" analysis/exc-panic-abort-v1-rfc.md \
  compiler/src/asm/runtime_panic.c compiler/src/asm/runtime_panic_arm64.c \
  compiler/src/asm/runtime_panic_x86_64.s; do
  if [ ! -f "$f" ]; then
    echo "std-runtime-panic gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in panic_hook_collect shux_crash_evidence_collect_c EXC-002 abort; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-runtime-panic gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

miss="$(std_runtime_panic_manifest_ok "$DOC" "$README" "$RUNTIME_X" "$MANIFEST" || true)"
if [ "${miss:-0}" -gt 0 ]; then
  std_runtime_panic_emit_report "fail" 0 0 0 0
  echo "std-runtime-panic gate FAIL: manifest_miss=${miss}" >&2
  exit 1
fi
echo "std-runtime-panic manifest OK"

stdlib_cm_native_shu() {
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
  for cand in ./compiler/shux-c ./compiler/shux; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
EXC_OK=0
SKIP=1
if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-028: typeck (SHUX=$SHUX_BIN) ==="
  if "$SHUX_BIN" check -L . "$HOOK_X" >/dev/null 2>&1 && \
     "$SHUX_BIN" check -L . "$READY_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-runtime-panic gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$HOOK_X" 2>&1 | tail -6 >&2 || true
    std_runtime_panic_emit_report "fail" 1 0 0 0
    exit 1
  fi
  SKIP=0
  if [ -x "$EXC_GATE" ]; then
    echo "=== STD-028: delegate EXC-002 panic/abort gate ==="
    if SHUX="$SHUX_BIN" "$EXC_GATE" >/tmp/std_runtime_exc_panic.log 2>&1; then
      EXC_OK=1
    elif grep -qE 'library .zstd. not found|exc-panic-abort gate SKIP' /tmp/std_runtime_exc_panic.log 2>/dev/null; then
      echo "std-runtime-panic gate SKIP EXC-002 runnable (link/zstd)" >&2
      EXC_OK=0
      SKIP=1
    else
      cat /tmp/std_runtime_exc_panic.log >&2 || true
      std_runtime_panic_emit_report "fail" 1 "$CHECK_OK" 0 "$SKIP"
      exit 1
    fi
  fi
else
  echo "std-runtime-panic gate SKIP typeck (no native shux)" >&2
fi

std_runtime_panic_emit_report "ok" 1 "$CHECK_OK" "$EXC_OK" "$SKIP"
echo "std-runtime-panic gate OK"
