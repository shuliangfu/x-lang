#!/usr/bin/env bash
# STD-138: Windows/macOS deep-boundary — honesty leftover wrap →硬绿.
#
# Honesty: leftover bootstrap-link wrap + lib RUN_XLANG remap in
# xplat_deep_run_smoke retired (product path is `"$xlang" -L . -o`).
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse leftover wrap / RUN_XLANG remap /
# soft SKIP→OK / soft auto-make / prefer-c). must-policy .x exit0 = hard
# run (run+=). check = obs; optional-policy fail = obs.
# Report: run=/obs=/skip=. G.7: complete existing run_smoke; drop unused
# compiler-make.sh. PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-xplat-deep-boundary-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="analysis/archive/std/std-xplat-deep-boundary-v1.md"
MANIFEST="tests/baseline/std-xplat-deep-boundary.tsv"
LIB="tests/lib/std-xplat-deep-boundary.sh"
SMOKE="tests/xplat/deep_boundary.x"
MIN_ROWS=8
MIN_SMOKE_CASES=6

# shellcheck source=tests/lib/std-xplat-deep-boundary.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "xplat-deep-boundary gate FAIL: $*" >&2
  xplat_deep_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-138: xplat deep-boundary manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-xplat-deep-boundary-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$SMOKE"; do
  [ -f "$f" ] || die "missing $f"
done

grep -qF STD-138 "$DOC" || die "doc"
grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_rows) MIN_ROWS="$c2" ;; min_smoke_cases) MIN_SMOKE_CASES="$c2" ;; esac
done < "$MANIFEST"

path_miss="$(xplat_deep_verify_paths "$MANIFEST" "$MIN_ROWS" || true)"
[ "${path_miss:-0}" -eq 0 ] || die "path_miss=${path_miss}"
echo "xplat-deep-boundary registry OK"

# Count // case N markers in aggregate smoke (do not append || echo 0 — that
# yields "0\n0" when grep -c exits 1 on zero matches).
# PLATFORM: SHARED archaeology.
n_cases=$(grep -cE '// case [0-9]+' "$SMOKE" 2>/dev/null || true)
n_cases=${n_cases:-0}
[ "$n_cases" -ge "$MIN_SMOKE_CASES" ] || die "deep_boundary cases=${n_cases} < ${MIN_SMOKE_CASES}"

if [ "${XLANG_STD_XPLAT_DEEP_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  xplat_deep_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "xplat-deep-boundary gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-138: smoke (XLANG=$XLANG_BIN; check obs; must runnable hard) ==="

# Observational check on aggregate smoke (paused 2026-08-05).
set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_xplat_deep_chk.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "xplat-deep-boundary OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover wrap / RUN_XLANG remap (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
MUST_RAN=0
while IFS=$'\t' read -r case_id kind path linux pol_mac pol_win _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "smoke" ] || continue
  pol="$(xplat_deep_platform_policy "$linux" "$pol_mac" "$pol_win")"
  case "$pol" in
    skip) echo "xplat-deep SKIP $case_id"; continue ;;
  esac
  MUST_RAN=$((MUST_RAN + 1))
  # Per-smoke check stays observational (paused); never hard-fail on CHK.
  # PLATFORM: SHARED — check gate paused 2026-08-05.
  set +e
  "$XLANG_BIN" check -L . "$path" >/dev/null 2>&1
  pchk=$?
  set -e
  if [ "$pchk" -ne 0 ]; then
    echo "xplat-deep OBS check $case_id (paused 2026-08-05)" >&2
    OBS=$((OBS + 1))
  fi
  if xplat_deep_run_smoke "$XLANG_BIN" "$path"; then
    RUN_OK=$((RUN_OK + 1))
    echo "xplat-deep OK $case_id"
  else
    if [ "$pol" = "optional" ]; then
      echo "xplat-deep OBS $case_id (optional fail; refuse soft SKIP→OK)" >&2
      OBS=$((OBS + 1))
    else
      die "run $path (refuse soft SKIP→OK)"
    fi
  fi
done < "$MANIFEST"

[ "$MUST_RAN" -gt 0 ] || die "no must/optional smoke ran"

xplat_deep_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "xplat-deep-boundary gate OK (host=$(ci_host_summary))"
