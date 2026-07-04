#!/usr/bin/env bash
# STD-147：std.backtrace Darwin/Windows/Linux 符号质量门禁
#
# 用法：./tests/run-std-backtrace-xplat-gate.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/std-backtrace-xplat-v1.md"
MANIFEST="tests/baseline/std-backtrace-xplat-manifest.tsv"
VECTORS="tests/baseline/std-backtrace-xplat.tsv"
BT_RUNTIME="compiler/src/asm/runtime_backtrace_platform.c"
BT_X="std/backtrace/backtrace.x"
LIB="tests/lib/std-backtrace-xplat.sh"
SMOKE_C="tests/backtrace/xplat_quality.c"

# shellcheck source=tests/lib/std-backtrace-xplat.sh
. "$LIB"

echo "=== STD-147: backtrace xplat quality manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$BT_X" "$BT_RUNTIME" "$SMOKE_C" std/backtrace/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-backtrace-xplat gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-147 SHUX_BT_XPLAT export_dynamic DbgHelp; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-backtrace-xplat gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "backtrace_xplat_quality_c" std/backtrace/README.md 2>/dev/null; then
  echo "std-backtrace-xplat gate FAIL: README missing xplat quality" >&2
  exit 1
fi

sym_miss="$(std_backtrace_xplat_symbols_ok "$BT_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_backtrace_xplat_emit_report "fail" 0 0 "$(ci_host_summary)"
  exit 1
fi
echo "std-backtrace-xplat registry OK"

QUAL_OK=0
SKIP=0
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
SHUX_BIN=""
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi

if [ -z "$SHUX_BIN" ]; then
  echo "std-backtrace-xplat gate SKIP quality smoke (no native shux-c)" >&2
  SKIP=1
  std_backtrace_xplat_emit_report "ok" 0 1 "$(ci_host_summary)"
  echo "std-backtrace-xplat gate OK (skip)"
  exit 0
fi

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/backtrace/backtrace.o
ensure_runtime_backtrace_platform_o

if vec="$(std_backtrace_xplat_pick_vector "$VECTORS" 2>/dev/null)"; then
  :
else
  echo "std-backtrace-xplat gate SKIP (no vector for host $(ci_host_summary))" >&2
  SKIP=1
  std_backtrace_xplat_emit_report "ok" 0 1 "$(ci_host_summary)"
  echo "std-backtrace-xplat gate OK (skip)"
  exit 0
fi

if std_backtrace_xplat_run_smoke "$BT_RUNTIME"; then
  QUAL_OK=1
else
  std_backtrace_xplat_emit_report "fail" 0 0 "$(ci_host_summary)"
  exit 1
fi

std_backtrace_xplat_emit_report "ok" "$QUAL_OK" "$SKIP" "$(ci_host_summary)"
echo "std-backtrace-xplat gate OK"
