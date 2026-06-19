#!/usr/bin/env bash
# STBL-004：import std.* 解析与 -L 布局门禁
#
# 用法：./tests/run-stbl-004-import-std-layout-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STBL_IMPORT_STD_DOC:-analysis/stbl-import-std-layout-v1.md}"
MANIFEST="${SHUX_STBL_IMPORT_STD_TSV:-tests/baseline/stbl-import-std-layout.tsv}"
LIB="tests/lib/stbl-import-std-layout.sh"
PKG_LIB="tests/lib/tool-pkgmgr.sh"
SMOKE_SU="tests/import-std-layout/check_imports.sx"
MIN_RESOLVE=12
LIB_ROOT="."

# shellcheck source=tests/lib/tool-pkgmgr.sh
. "$PKG_LIB"
# shellcheck source=tests/lib/stbl-import-std-layout.sh
. "$LIB"

echo "=== STBL-004: import std layout manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$PKG_LIB" "$SMOKE_SU"; do
  if [ ! -f "$f" ]; then
    echo "stbl-import-std gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STBL-004 import std -L TOOL-007 TOOL-008 mod.sx; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "stbl-import-std gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_resolve) MIN_RESOLVE="$c2" ;; esac
done < "$MANIFEST"

sec_miss="$(stbl_import_std_sections_ok "$DOC" "$MANIFEST" || true)"
if [ "${sec_miss:-0}" -gt 0 ]; then
  stbl_import_std_emit_report "fail" 0 0 0
  echo "stbl-import-std gate FAIL: sec_miss=${sec_miss}" >&2
  exit 1
fi

RESOLVE_OK=0
while IFS=$'\t' read -r item_id kind import_path expected _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    resolve)
      if ! stbl_import_std_resolve_probe "$LIB_ROOT" "$import_path" "$expected"; then
        stbl_import_std_emit_report "fail" "$RESOLVE_OK" 0 0
        exit 1
      fi
      RESOLVE_OK=$((RESOLVE_OK + 1))
      ;;
  esac
done < "$MANIFEST"

if [ "$RESOLVE_OK" -lt "$MIN_RESOLVE" ]; then
  echo "stbl-import-std gate FAIL: resolve $RESOLVE_OK < min $MIN_RESOLVE" >&2
  stbl_import_std_emit_report "fail" "$RESOLVE_OK" 0 0
  exit 1
fi
echo "stbl-import-std resolve OK (${RESOLVE_OK}/${MIN_RESOLVE})"

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

CHECK_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STBL-004: typeck smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "stbl-import-std gate FAIL: check $SMOKE_SU" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    stbl_import_std_emit_report "fail" "$RESOLVE_OK" 0 0
    exit 1
  fi
  CHECK_OK=1
  SKIP=0
else
  echo "stbl-import-std gate SKIP typeck (no native shux-c)" >&2
fi

stbl_import_std_emit_report "ok" "$RESOLVE_OK" "$CHECK_OK" "$SKIP"
echo "stbl-import-std-layout gate OK"
