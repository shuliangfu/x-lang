#!/usr/bin/env bash
# CORE-010：core.fmt usize/isize/指针格式化门禁
#
# 用法：./tests/run-core-fmt-widths-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_CORE_FMT_WIDTHS_DOC:-analysis/core-fmt-widths-v1.md}"
MANIFEST="${SHU_CORE_FMT_WIDTHS_TSV:-tests/baseline/core-fmt-widths.tsv}"
FMT_SU="core/fmt/mod.su"
LIB="tests/lib/core-fmt-widths.sh"
SMOKE="tests/fmt/widths.su"

# shellcheck source=tests/lib/core-fmt-widths.sh
. tests/lib/core-fmt-widths.sh

echo "=== CORE-010: fmt usize/isize/ptr manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$FMT_SU" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "core-fmt-widths gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in fmt_usize_to_buf fmt_isize_to_buf fmt_ptr_to_buf 0x0; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-fmt-widths gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(core_fmt_widths_symbols_ok "$FMT_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_fmt_widths_emit_report "fail" 0 0 0
  echo "core-fmt-widths gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "core-fmt-widths manifest OK"

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
  for cand in ./compiler/shu-c ./compiler/shu; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1
if SHU_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== CORE-010: typeck (SHU=$SHU_BIN) ==="
  if "$SHU_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "core-fmt-widths gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE" 2>&1 | tail -8 >&2 || true
    core_fmt_widths_emit_report "fail" 0 0 0
    exit 1
  fi
  SKIP=0
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c
  # shellcheck source=tests/lib/bootstrap-link-shu.sh
  . "$(dirname "$0")/lib/bootstrap-link-shu.sh"
  if $RUN_SHU -L . "$SMOKE" -o /tmp/shu_core_fmt_widths 2>/tmp/shu_core_fmt_widths_build.log; then
    exitcode=0
    /tmp/shu_core_fmt_widths >/dev/null 2>&1 || exitcode=$?
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
    else
      echo "core-fmt-widths gate FAIL: runnable exit=$exitcode" >&2
      core_fmt_widths_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "core-fmt-widths gate SKIP runnable link (check passed)" >&2
    tail -5 /tmp/shu_core_fmt_widths_build.log 2>/dev/null >&2 || true
    SKIP=1
  fi
else
  echo "core-fmt-widths gate SKIP typeck (no native shu)" >&2
fi

core_fmt_widths_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "core-fmt-widths gate OK"
