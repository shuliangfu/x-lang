#!/usr/bin/env bash
# STD-003: std.fs cross-platform gate — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft auto-make + check=/x=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse soft
# SKIP→OK / soft auto-make / prefer-c / soft ensure). Must-policy .x / run-fs.sh
# exit0 = hard run (run=1). check = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-fs-crossplatform-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_FS_XPLAT_DOC:-analysis/archive/std/std-fs-api-v1.md}"
BASELINE="tests/baseline/std-fs-crossplatform.tsv"
MATRIX="${XLANG_STD_FS_CROSSPLATFORM_TSV:-$BASELINE}"
LIB="tests/lib/std-fs-crossplatform.sh"
SMOKE_X="tests/fs/crossplatform_core.x"

# shellcheck source=tests/lib/std-fs-crossplatform.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-fs-crossplatform gate FAIL: $*" >&2
  std_fs_xplat_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

platform_policy() {
  local linux="$1"
  local macos="$2"
  local windows="$3"
  if ci_is_linux; then
    echo "$linux"
  elif ci_is_darwin; then
    echo "$macos"
  elif ci_is_windows_msys; then
    echo "$windows"
  else
    echo "must"
  fi
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
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

echo "=== STD-003: std.fs cross-platform manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-fs-api-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MATRIX" "$LIB" "$SMOKE_X" tests/run-fs.sh; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-003 crossplatform must skip; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

# DOC §4 = 兼容矩阵; Gate honesty lives under §5 (do not collide with §4).
# PLATFORM: SHARED archaeology — section anchor must match archive DOC.
grep -qF '## 5. Gate' "$DOC" 2>/dev/null || die "doc missing '## 5. Gate'"

echo "std-fs-crossplatform manifest OK"

if [ "${XLANG_STD_FS_XPLAT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_fs_xplat_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-fs-crossplatform gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-003: smoke (XLANG=$XLANG_BIN; check obs; must runnable hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std003_fs_xplat_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-fs-crossplatform OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make / soft ensure (product must cases are the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

FAILS=0
MUST_RAN=0
while IFS=$'\t' read -r case_id script linux pol_mac pol_win notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in
    \#*) continue ;;
  esac
  pol=$(platform_policy "$linux" "$pol_mac" "$pol_win")
  case "$pol" in
    skip)
      echo "std-fs xplat SKIP $case_id ($notes)"
      continue
      ;;
  esac

  if [ "$script" = "run-fs.sh" ]; then
    echo "── case $case_id: $script ──"
    MUST_RAN=$((MUST_RAN + 1))
    chmod +x tests/run-fs.sh
    if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-fs.sh; then
      echo "std-fs xplat OK $case_id"
    else
      if [ "$pol" = "optional" ]; then
        echo "std-fs xplat WARN $case_id (optional)" >&2
        OBS=$((OBS + 1))
      else
        echo "std-fs xplat FAIL $case_id" >&2
        FAILS=$((FAILS + 1))
      fi
    fi
    continue
  fi

  if [ ! -f "tests/fs/${script}" ]; then
    echo "std-fs xplat FAIL $case_id: missing tests/fs/${script}" >&2
    FAILS=$((FAILS + 1))
    continue
  fi

  echo "── case $case_id: tests/fs/${script} ──"
  MUST_RAN=$((MUST_RAN + 1))
  if std_fs_xplat_run_x_smoke "$XLANG_BIN" "tests/fs/${script}" \
    "/tmp/xlang_fs_xplat_${script%.x}_$$"; then
    echo "std-fs xplat OK $case_id"
  else
    if [ "$pol" = "optional" ]; then
      echo "std-fs xplat WARN $case_id (optional exit!=0)" >&2
      OBS=$((OBS + 1))
    else
      echo "std-fs xplat FAIL $case_id (exit!=0)" >&2
      FAILS=$((FAILS + 1))
    fi
  fi
done < "$MATRIX"

[ "$FAILS" -eq 0 ] || die "${FAILS} case(s) (refuse soft SKIP→OK)"
[ "$MUST_RAN" -gt 0 ] || die "no must-policy cases ran"

RUN_OK=1
std_fs_xplat_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-fs-crossplatform gate OK"
