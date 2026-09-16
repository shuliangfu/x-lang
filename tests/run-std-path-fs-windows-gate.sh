#!/usr/bin/env bash
# STD-021/022: std.path / std.fs Windows — honesty leftover wrap →硬绿.
#
# Honesty: leftover bootstrap-link wrap + lib RUN_XLANG remap / fossil
# `$runner build` in std_pfw_run_x_smoke retired (product path is
# `"$xlang" -L . -o`). Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover wrap /
# RUN_XLANG remap / fossil build / soft SKIP→OK / soft auto-make / prefer-c).
# Product windows_abs_join + windows_path_smoke exit0 = hard run (run=2).
# check + fs-crossplatform delegate = obs. Report: run=/obs=/skip=.
# G.7: complete existing run_smoke; drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-path-fs-windows-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_PFW_DOC:-analysis/archive/std/std-path-fs-windows-v1.md}"
MANIFEST="${XLANG_STD_PFW_TSV:-tests/baseline/std-path-fs-windows.tsv}"
PATH_X="std/path/mod.x"
LIB="tests/lib/std-path-fs-windows.sh"
PATH_TEST="tests/path/windows_abs_join.x"
FS_TEST="tests/fs/windows_path_smoke.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-path-fs-windows.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-path-fs-windows gate FAIL: $*" >&2
  std_pfw_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-021/022: path/fs Windows manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-path-fs-windows-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$PATH_X" "$PATH_TEST" "$FS_TEST"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-021 STD-022 is_sep is_absolute win_path_smoke sep; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

sym_miss="$(std_pfw_symbols_ok "$PATH_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"

while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

for sym in sep is_sep is_absolute join basename dirname; do
  grep -qE "function ${sym}\\(" "$PATH_X" 2>/dev/null || die "mod missing function ${sym}"
done
for call in path.is_absolute path.join path.basename; do
  grep -q "${call}" "$PATH_TEST" 2>/dev/null || die "smoke missing ${call}"
done
echo "std-path-fs-windows manifest OK"

if [ "${XLANG_STD_PFW_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_pfw_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-path-fs-windows gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-021/022: smoke (XLANG=$XLANG_BIN; check/xplat obs; path+fs product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$PATH_TEST" >/tmp/xlang_std021_chk_path.log 2>&1
chk1=$?
"$XLANG_BIN" check -L . "$FS_TEST" >/tmp/xlang_std022_chk_fs.log 2>&1
chk2=$?
set -e
if [ "$chk1" -ne 0 ] || [ "$chk2" -ne 0 ]; then
  echo "std-path-fs-windows OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover wrap / RUN_XLANG remap / fossil `$runner build`
# (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
if std_pfw_run_x_smoke "$XLANG_BIN" "$PATH_TEST" "/tmp/xlang_std021_path_$$" "$SMOKE_EXPECT"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-path-fs-windows OK: path"
else
  die "windows_abs_join.x exit!=0 (refuse soft SKIP→OK)"
fi
if std_pfw_run_x_smoke "$XLANG_BIN" "$FS_TEST" "/tmp/xlang_std022_fs_$$" "$SMOKE_EXPECT"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-path-fs-windows OK: fs"
else
  # POSIX may leave a literal backslash filename from the smoke path bytes.
  rm -f 'tests\fs\.win_xplat_tmp' tests/fs/.win_xplat_tmp 2>/dev/null || true
  die "windows_path_smoke.x exit!=0 (refuse soft SKIP→OK)"
fi
# Clean Windows smoke artifact (backslash path bytes → literal filename on POSIX).
# PLATFORM: SHARED archaeology — do not leave repo-root trash after hard green.
rm -f 'tests\fs\.win_xplat_tmp' tests/fs/.win_xplat_tmp 2>/dev/null || true

# Observational: fs-crossplatform delegate (do not demote hard green).
# PLATFORM: SHARED archaeology.
if [ -x tests/run-std-fs-crossplatform-gate.sh ]; then
  echo "=== STD-022: delegate std-fs-crossplatform (observational) ==="
  set +e
  XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
    ./tests/run-std-fs-crossplatform-gate.sh >/tmp/std_pfw_xplat.log 2>&1
  xrc=$?
  set -e
  if [ "$xrc" -ne 0 ]; then
    echo "std-path-fs-windows OBS xplat delegate (see /tmp/std_pfw_xplat.log)" >&2
    OBS=$((OBS + 1))
  fi
fi

std_pfw_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-path-fs-windows gate OK (host=$(ci_host_summary))"
