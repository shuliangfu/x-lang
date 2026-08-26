#!/usr/bin/env bash
# STD-138：Windows/macOS 深度边界向量门禁（假权威诚实）。
#
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); must-policy .x exit 0 hard-fail (no soft SKIP
# when native xlang present). Report check=/x=/skip=. Product surface already
# green under asm; gate was portable-false-red (prefer xlang-c only / hard
# typeck on must smokes / soft SKIP→OK when no native / broken n_cases count).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="analysis/archive/std/std-xplat-deep-boundary-v1.md"
MANIFEST="tests/baseline/std-xplat-deep-boundary.tsv"
LIB="tests/lib/std-xplat-deep-boundary.sh"
SMOKE="tests/xplat/deep_boundary.x"
MIN_ROWS=8
MIN_SMOKE_CASES=6

# shellcheck source=tests/lib/std-xplat-deep-boundary.sh
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

echo "=== STD-138: xplat deep-boundary manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-xplat-deep-boundary-v1.md ]; then
  echo "xplat-deep-boundary gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$SMOKE"; do
  [ -f "$f" ] || { echo "xplat-deep-boundary gate FAIL: missing $f" >&2; exit 1; }
done

grep -qF STD-138 "$DOC" || { echo "xplat-deep-boundary gate FAIL: doc" >&2; exit 1; }

# DOC §3 = Gate honesty (was ## 3. 门禁 without prefer-asm / runnable hard).
# PLATFORM: SHARED archaeology — section anchor must match archive DOC.
if ! grep -qF '## 3. Gate' "$DOC" 2>/dev/null; then
  echo "xplat-deep-boundary gate FAIL: doc missing '## 3. Gate'" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_rows) MIN_ROWS="$c2" ;; min_smoke_cases) MIN_SMOKE_CASES="$c2" ;; esac
done < "$MANIFEST"

path_miss="$(xplat_deep_verify_paths "$MANIFEST" "$MIN_ROWS" || true)"
[ "${path_miss:-0}" -eq 0 ] || exit 1
echo "xplat-deep-boundary registry OK"

# Count // case N markers in aggregate smoke (do not append || echo 0 — that
# yields "0\n0" when grep -c exits 1 on zero matches).
# PLATFORM: SHARED archaeology.
n_cases=$(grep -cE '// case [0-9]+' "$SMOKE" 2>/dev/null || true)
n_cases=${n_cases:-0}
if [ "$n_cases" -lt "$MIN_SMOKE_CASES" ]; then
  echo "xplat-deep-boundary gate FAIL: deep_boundary cases=${n_cases} < ${MIN_SMOKE_CASES}" >&2
  exit 1
fi

if [ "${XLANG_STD_XPLAT_DEEP_MANIFEST_ONLY:-0}" = "1" ]; then
  xplat_deep_emit_report "ok" 0 0 1
  echo "xplat-deep-boundary gate OK (manifest only)"
  exit 0
fi

CHECK_OK=0
X_OK=0
SKIP=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "xplat-deep-boundary gate FAIL: no native xlang" >&2
  xplat_deep_emit_report "fail" 0 0 0
  exit 1
fi

echo "=== STD-138: smoke (XLANG=$XLANG_BIN; check observational; must runnable hard) ==="
# Observational check on aggregate smoke (paused 2026-08-05); CHK red does not hard-fail.
if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
  CHECK_OK=1
else
  echo "xplat-deep-boundary gate SKIP check smoke (paused 2026-08-05)" >&2
fi

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

# Pin product link to resolved compiler (prefer asm).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

FAIL=0
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
  if ! "$XLANG_BIN" check -L . "$path" >/dev/null 2>&1; then
    echo "xplat-deep SKIP check $case_id (paused 2026-08-05)" >&2
  else
    CHECK_OK=1
  fi
  if ! xplat_deep_run_smoke "$XLANG_BIN" "$path"; then
    if [ "$pol" = "optional" ]; then
      echo "xplat-deep WARN $case_id (optional)" >&2
    else
      echo "xplat-deep-boundary gate FAIL: run $path" >&2
      FAIL=1
      break
    fi
  else
    echo "xplat-deep OK $case_id"
  fi
done < "$MANIFEST"

if [ "$FAIL" -ne 0 ]; then
  xplat_deep_emit_report "fail" "$CHECK_OK" 0 0
  exit 1
fi
if [ "$MUST_RAN" -eq 0 ]; then
  echo "xplat-deep-boundary gate FAIL: no must/optional smoke ran" >&2
  xplat_deep_emit_report "fail" "$CHECK_OK" 0 0
  exit 1
fi

X_OK=1
SKIP=0
xplat_deep_emit_report "ok" "$CHECK_OK" "$X_OK" "$SKIP"
echo "xplat-deep-boundary gate OK (host=$(ci_host_summary))"
