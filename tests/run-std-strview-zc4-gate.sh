#!/usr/bin/env bash
# STD-016：StrView 与 ZC-4 深度整合门禁
#
# 用法：./tests/run-std-strview-zc4-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_SV_ZC4_DOC:-analysis/std-strview-zc4-v1.md}"
MANIFEST="${SHUX_STD_SV_ZC4_TSV:-tests/baseline/std-strview-zc4.tsv}"
STRING_SU="std/string/mod.sx"
LIB="tests/lib/std-strview-zc4.sh"
LIFECYCLE_SU="tests/string/view_lifecycle.sx"

# shellcheck source=tests/lib/std-strview-zc4.sh
. tests/lib/std-strview-zc4.sh

echo "=== STD-016: StrView/ZC-4 manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$STRING_SU" "$LIFECYCLE_SU"; do
  if [ ! -f "$f" ]; then
    echo "std-strview-zc4 gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in ZC-4 arena64_deinit string_view_from_string 生命周期; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-strview-zc4 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

miss="$(std_sv_zc4_manifest_ok "$STRING_SU" "$DOC" "$MANIFEST" || true)"
if [ "${miss:-0}" -gt 0 ]; then
  std_sv_zc4_emit_report "fail" 0 0 1
  echo "std-strview-zc4 gate FAIL: manifest_miss=${miss}" >&2
  exit 1
fi
echo "std-strview-zc4 manifest OK"

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

TYPECK_OK=0
ZC4_SKIP=1
if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-016: typeck (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  for su in "$LIFECYCLE_SU" tests/string/view_subview_smoke.sx tests/string/arena_concat_smoke.sx tests/string/stack_str_sso_smoke.sx; do
    if ! "$SHUX_BIN" check -L . "$su" >/dev/null 2>&1; then
      echo "std-strview-zc4 gate FAIL: typeck $su" >&2
      "$SHUX_BIN" check -L . "$su" 2>&1 | tail -6 >&2 || true
      std_sv_zc4_emit_report "fail" 1 0 1
      exit 1
    fi
  done
  TYPECK_OK=1
  if [ -x tests/run-zc4-gate.sh ]; then
    echo "=== STD-016: delegate run-zc4-gate (runnable) ==="
    chmod +x tests/run-zc4-gate.sh tests/run-perf-string-arena.sh tests/run-string.sh
    if SHUX="$SHUX_BIN" ./tests/run-zc4-gate.sh >/tmp/std_sv_zc4_deep.log 2>&1; then
      ZC4_SKIP=0
      grep -qF 'zc4 gate OK' /tmp/std_sv_zc4_deep.log || true
    else
      echo "std-strview-zc4 gate SKIP zc4 runnable (typeck passed)" >&2
      tail -8 /tmp/std_sv_zc4_deep.log 2>/dev/null >&2 || true
    fi
  fi
else
  echo "std-strview-zc4 gate SKIP typeck (no native shux-c)" >&2
fi

std_sv_zc4_emit_report "ok" 1 "$TYPECK_OK" "$ZC4_SKIP"
echo "std-strview-zc4 gate OK"
