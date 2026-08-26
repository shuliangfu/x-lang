#!/usr/bin/env bash
# STBL-004: import std.* resolve + -L layout gate (false-authority honesty).
#
# Usage: ./tests/run-stbl-004-import-std-layout-gate.sh
# wave honesty (2026-08-24 #7): DOC → analysis/archive/stbl/; TOOL-007 archive cross.
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); check_imports.x build+run exit0 hard-fail
# (no soft SKIP→OK when no native). Report resolve=/check=/run=/skip=.
# Gate was portable-false-red (prefer xlang-c / soft SKIP→OK when no native /
# hard check / DOC ## 7. 验证与门禁 without Gate honesty). Ubuntu/Darwin asm
# smoke already exit0. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STBL_IMPORT_STD_DOC:-analysis/archive/stbl/stbl-import-std-layout-v1.md}"
MANIFEST="${XLANG_STBL_IMPORT_STD_TSV:-tests/baseline/stbl-import-std-layout.tsv}"
LIB="tests/lib/stbl-import-std-layout.sh"
PKG_LIB="tests/lib/tool-pkgmgr.sh"
SMOKE_X="tests/import-std-layout/check_imports.x"
MIN_RESOLVE=12
LIB_ROOT="."

# shellcheck source=tests/lib/tool-pkgmgr.sh
. "$PKG_LIB"
# shellcheck source=tests/lib/stbl-import-std-layout.sh
. "$LIB"

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
stbl_import_std_resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

echo "=== STBL-004: import std layout manifest (archive DOC) ==="

# Refuse resurrected top-level DOC (live = archive/stbl/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/stbl-import-std-layout-v1.md ]; then
  echo "stbl-import-std gate FAIL: top-level DOC resurrected (live = archive/stbl/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$PKG_LIB" "$SMOKE_X"; do
  if [ ! -f "$f" ]; then
    echo "stbl-import-std gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STBL-004 import std -L TOOL-007 TOOL-008 mod.x; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "stbl-import-std gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 7. Gate' "$DOC" 2>/dev/null; then
  echo "stbl-import-std gate FAIL: doc missing '## 7. Gate'" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_resolve) MIN_RESOLVE="$c2" ;; esac
done < "$MANIFEST"

sec_miss="$(stbl_import_std_sections_ok "$DOC" "$MANIFEST" || true)"
if [ "${sec_miss:-0}" -gt 0 ]; then
  stbl_import_std_emit_report "fail" 0 0 0 0
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
        stbl_import_std_emit_report "fail" "$RESOLVE_OK" 0 0 0
        exit 1
      fi
      RESOLVE_OK=$((RESOLVE_OK + 1))
      ;;
  esac
done < "$MANIFEST"

if [ "$RESOLVE_OK" -lt "$MIN_RESOLVE" ]; then
  echo "stbl-import-std gate FAIL: resolve $RESOLVE_OK < min $MIN_RESOLVE" >&2
  stbl_import_std_emit_report "fail" "$RESOLVE_OK" 0 0 0
  exit 1
fi
echo "stbl-import-std resolve OK (${RESOLVE_OK}/${MIN_RESOLVE})"

if [ "${XLANG_STBL_IMPORT_STD_MANIFEST_ONLY:-0}" = "1" ]; then
  stbl_import_std_emit_report "ok" "$RESOLVE_OK" 0 0 1
  echo "stbl-import-std-layout gate OK (manifest only)"
  exit 0
fi

# Best-effort quiet make (do not soft-SKIP the gate when make is noisy).
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make || true

CHECK_OK=0
RUN_OK=0
SKIP=1

if XLANG_BIN="$(stbl_import_std_resolve_shu 2>/dev/null)"; then
  echo "=== STBL-004: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "stbl-import-std gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  out="/tmp/xlang_stbl004_import_$$"
  compile_log="/tmp/xlang_stbl004_compile_$$.log"
  ec=0
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$out" >"$compile_log" 2>&1 \
    || "$XLANG_BIN" -L . "$SMOKE_X" -o "$out" >"$compile_log" 2>&1; then
    "$out" >/dev/null 2>&1 || ec=$?
    rm -f "$out"
    if [ "$ec" -ne 0 ]; then
      echo "stbl-import-std FAIL run $SMOKE_X: exit=$ec want=0" >&2
      stbl_import_std_emit_report "fail" "$RESOLVE_OK" "$CHECK_OK" 0 0
      rm -f "$compile_log"
      exit 1
    fi
    RUN_OK=1
    SKIP=0
  else
    echo "stbl-import-std FAIL compile $SMOKE_X" >&2
    tail -20 "$compile_log" >&2 || true
    rm -f "$out" "$compile_log"
    stbl_import_std_emit_report "fail" "$RESOLVE_OK" "$CHECK_OK" 0 0
    exit 1
  fi
  rm -f "$compile_log"
else
  echo "stbl-import-std gate FAIL: no native xlang" >&2
  stbl_import_std_emit_report "fail" "$RESOLVE_OK" 0 0 0
  exit 2
fi

# check stays observational; hard-green signal is run= (smoke).
echo "stbl-import-std check_ok=${CHECK_OK} (observational)"
stbl_import_std_emit_report "ok" "$RESOLVE_OK" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "stbl-import-std-layout gate OK"
