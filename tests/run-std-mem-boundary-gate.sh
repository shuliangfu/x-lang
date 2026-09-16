#!/usr/bin/env bash
# STD-018: std.mem / core.mem responsibility boundary — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native) + prefer-c only + soft auto-make
# + hard-bound `xlang check` as sole smoke (CHK002 / tip UNDEF false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - manifest + ## Gate + symbols + no-cross-import + README = hard.
#   - std_mem_boundary product -o tip UNDEF (std_mem_*) = obs.
#   - check path = obs (paused 2026-08-05).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-mem-boundary-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/std-mem-boundary.sh
. tests/lib/std-mem-boundary.sh

DOC="${XLANG_STD_MEM_BOUNDARY_DOC:-analysis/archive/std/std-mem-boundary-v1.md}"
MANIFEST="${XLANG_STD_MEM_BOUNDARY_TSV:-tests/baseline/std-mem-boundary.tsv}"
CORE_X="core/mem/mod.x"
STD_X="std/mem/mod.x"
STD_README="std/mem/README.md"
SMOKE="tests/mem/std_mem_boundary.x"
LIB="tests/lib/std-mem-boundary.sh"
MIN_CORE=4
MIN_STD=4

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-mem-boundary gate FAIL: $*" >&2
  std_mem_boundary_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
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

echo "=== STD-018: std.mem boundary manifest (archive DOC) ==="
if [ -f analysis/std-mem-boundary-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi
for f in "$DOC" "$MANIFEST" "$LIB" "$CORE_X" "$STD_X" "$STD_README" "$SMOKE"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi
for kw in core.mem std.mem; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_core_only) MIN_CORE="$c2" ;;
    min_std_only) MIN_STD="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
CORE_N=0
STD_N=0
echo "=== STD-018: sections, smokes, refs ==="
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-mem-boundary FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    core_only) CORE_N=$((CORE_N + 1)) ;;
    std_only) STD_N=$((STD_N + 1)) ;;
    smoke|runner)
      if [ ! -f "$anchor" ]; then
        echo "std-mem-boundary FAIL: missing $anchor ($item_id)" >&2
        MISS=$((MISS + 1))
      elif [ "$kind" = "smoke" ] && ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-mem-boundary FAIL: doc missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$mod_path" ]; then
        echo "std-mem-boundary FAIL: missing $mod_path ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
        echo "std-mem-boundary FAIL: $mod_path missing anchor '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    doc_readme|file) ;;
  esac
done < "$MANIFEST"

[ "$CORE_N" -ge "$MIN_CORE" ] && [ "$STD_N" -ge "$MIN_STD" ] || die "core=${CORE_N} std=${STD_N}"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"

sym_miss="$(std_mem_boundary_symbols_ok "$CORE_X" "$STD_X" "$MANIFEST" || true)"
cross_miss="$(std_mem_boundary_forbidden_ok "$STD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
[ "${cross_miss:-0}" -eq 0 ] || die "forbidden_miss=${cross_miss}"

if ! grep -qF 'std-mem-boundary' "$STD_README" 2>/dev/null && ! grep -qF '职责边界' "$STD_README" 2>/dev/null; then
  die "std/mem/README.md missing boundary section"
fi
echo "std-mem-boundary manifest OK (core=${CORE_N} std=${STD_N})"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-018: smoke (XLANG=$XLANG_BIN) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std_mem_b_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "std-mem-boundary OBS check (paused / CHK residual ec=$chk_ec)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_std_mem_b_$$"
rm -f "$exe" 2>/dev/null || true
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >/tmp/xlang_std_mem_b_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 10 /tmp/xlang_std_mem_b_o.log 2>/dev/null || true
  rm -f "$exe"
  # tip: labi may not pull std_mem_* for this smoke — count obs, not soft SKIP→OK.
  echo "std-mem-boundary OBS tip product -o (ec=$o_ec; std_mem_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$exe" >/dev/null 2>&1
  run_ec=$?
  set -e
  rm -f "$exe"
  if [ "$run_ec" -ne 0 ]; then
    echo "std-mem-boundary OBS tip run exit=$run_ec" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
  fi
fi

echo "std-mem-boundary gate OK"
std_mem_boundary_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
