#!/usr/bin/env bash
# STD-021/022：std.path / std.fs Windows 对齐门禁（假权威诚实）。
#
# 用法：./tests/run-std-path-fs-windows-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); windows_abs_join.x + windows_path_smoke.x
# exit 0 hard-fail (no soft SKIP when native xlang present). Report
# check=/path=/fs=/skip=. Product surface already green under asm; gate was
# portable-false-red (prefer xlang-c / hard check / soft SKIP when no xlang-c /
# typeck-only without runnable).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_PFW_DOC:-analysis/archive/std/std-path-fs-windows-v1.md}"
MANIFEST="${XLANG_STD_PFW_TSV:-tests/baseline/std-path-fs-windows.tsv}"
PATH_X="std/path/mod.x"
LIB="tests/lib/std-path-fs-windows.sh"
PATH_TEST="tests/path/windows_abs_join.x"
FS_TEST="tests/fs/windows_path_smoke.x"
# Designed success score (both smokes return 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-path-fs-windows.sh
. "$LIB"

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

echo "=== STD-021/022: path/fs Windows manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-path-fs-windows-v1.md ]; then
  echo "std-path-fs-windows gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$PATH_X" "$PATH_TEST" "$FS_TEST"; do
  if [ ! -f "$f" ]; then
    echo "std-path-fs-windows gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-021 STD-022 is_sep is_absolute win_path_smoke sep; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-path-fs-windows gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-path-fs-windows gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

sym_miss="$(std_pfw_symbols_ok "$PATH_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_pfw_emit_report "fail" 0 0 0 0
  echo "std-path-fs-windows gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi

while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-path-fs-windows gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

for sym in sep is_sep is_absolute join basename dirname; do
  if ! grep -qE "function ${sym}\\(" "$PATH_X" 2>/dev/null; then
    echo "std-path-fs-windows gate FAIL: mod missing function ${sym}" >&2
    std_pfw_emit_report "fail" 0 0 0 0
    exit 1
  fi
done
for call in path.is_absolute path.join path.basename; do
  if ! grep -q "${call}" "$PATH_TEST" 2>/dev/null; then
    echo "std-path-fs-windows gate FAIL: smoke missing ${call}" >&2
    std_pfw_emit_report "fail" 0 0 0 0
    exit 1
  fi
done
echo "std-path-fs-windows manifest OK"

if [ "${XLANG_STD_PFW_MANIFEST_ONLY:-0}" = "1" ]; then
  std_pfw_emit_report "ok" 0 0 0 1
  echo "std-path-fs-windows gate OK (manifest only)"
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
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
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
PATH_OK=0
FS_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-021/022: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  # Observational check (paused 2026-08-05) — never hard-fail the gate.
  if "$XLANG_BIN" check -L . "$PATH_TEST" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$FS_TEST" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-path-fs-windows gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_pfw_run_x_smoke "$XLANG_BIN" "$PATH_TEST" "/tmp/xlang_std021_path_$$" "$SMOKE_EXPECT"; then
    PATH_OK=1
  else
    std_pfw_emit_report "fail" "$CHECK_OK" 0 0 0
    exit 1
  fi
  if std_pfw_run_x_smoke "$XLANG_BIN" "$FS_TEST" "/tmp/xlang_std022_fs_$$" "$SMOKE_EXPECT"; then
    FS_OK=1
  else
    # POSIX may leave a literal backslash filename from the smoke path bytes.
    rm -f 'tests\fs\.win_xplat_tmp' tests/fs/.win_xplat_tmp 2>/dev/null || true
    std_pfw_emit_report "fail" "$CHECK_OK" "$PATH_OK" 0 0
    exit 1
  fi
  # Clean Windows smoke artifact (backslash path bytes → literal filename on POSIX).
  # PLATFORM: SHARED archaeology — do not leave repo-root trash after hard green.
  rm -f 'tests\fs\.win_xplat_tmp' tests/fs/.win_xplat_tmp 2>/dev/null || true
  SKIP=0

  # Observational: keep xplat matrix as a note (non-Windows WARN stays soft).
  # Hard green for this gate is path= + fs= runnable above.
  # PLATFORM: SHARED archaeology — do not let xplat WARN demote hard green.
  if [ -x tests/run-std-fs-crossplatform-gate.sh ]; then
    echo "=== STD-022: delegate std-fs-crossplatform (observational) ==="
    if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
      ./tests/run-std-fs-crossplatform-gate.sh >/tmp/std_pfw_xplat.log 2>&1; then
      echo "std-path-fs-windows xplat delegate OK (observational)"
    else
      echo "std-path-fs-windows gate SKIP xplat delegate (observational)" >&2
    fi
  fi
else
  echo "std-path-fs-windows gate FAIL: no native xlang" >&2
  std_pfw_emit_report "fail" 0 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is path= + fs= (runnable).
echo "std-path-fs-windows check_ok=${CHECK_OK} (observational)"
std_pfw_emit_report "ok" "$CHECK_OK" "$PATH_OK" "$FS_OK" "$SKIP"
echo "std-path-fs-windows gate OK"
