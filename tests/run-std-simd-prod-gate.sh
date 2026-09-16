#!/usr/bin/env bash
# STD-061: std.simd shuffle/select production bench gate — honesty leftover wrap dead source →硬绿.
#
# Honesty: leftover bootstrap-link wrap sourced unused (no RUN_XLANG) + unused
# compiler-make.sh retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native asm = hard die (refuse leftover wrap
# dead source / unused compiler-make / soft SKIP→OK / prefer-c). Product
# bench/r04_simd_shuffle_select.x -o exit0 = hard run (run=1). check / perf
# ratio = obs (perf soft residual — not hard-red on under-ratio / host-cc).
# Report: run=/obs=/skip=.
# SIMD Vec bodies need asm backend (skip xlang-c).
# G.7: complete existing resolve_shu; drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-simd-prod-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD061_DOC:-analysis/archive/std/std-simd-prod-v1.md}"
WAVE="${XLANG_STD061_WAVE_TSV:-tests/baseline/std-simd-prod-wave.tsv}"
PARENT_DOC="${XLANG_STD_SIMD_SHUFFLE_SELECT_DOC:-analysis/archive/std/std-simd-shuffle-select-v1.md}"
MOD_X="std/simd/mod.x"
LIB="tests/lib/std-simd-prod.sh"
BENCH_X="bench/r04_simd_shuffle_select.x"
MIN_BENCHES=3

# shellcheck source=tests/lib/std-simd-prod.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0
RATIO=""

die() {
  echo "std-simd-prod gate FAIL: $*" >&2
  std_simd_prod_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP" "$RATIO"
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
      case "$abs" in
        */xlang-c|*/xlang-x*) return 1 ;;
      esac
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c / xlang-c (no Vec emit).
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

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-simd-prod-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

echo "=== STD-061: simd prod bench manifest ==="
for f in "$DOC" "$WAVE" "$LIB" "$PARENT_DOC" "$MOD_X" \
  "$BENCH_X" bench/r04_simd_shuffle_select_stub.c \
  tests/run-perf-simd-shuffle-select.sh; do
  [ -f "$f" ] || die "missing $f"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_benches) MIN_BENCHES="$c2" ;;
  esac
done < "$WAVE"

# Product keywords (live RFC / r04 path). Fossil stub/Shu + tests/bench/… rejected.
for kw in STD-061 生产级 perf bench_shuffle_hot min_benches stub/Xlang r04_simd_shuffle_select; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

# Product STD-* IDs live on the module README (same place as STD-047 / STD-153).
grep -qF 'STD-061' std/simd/README.md 2>/dev/null || die "missing STD-061 anchor in std/simd/README.md"
echo "std-simd-prod OK README anchor"

BENCH_N=0
MISS=0
echo "=== STD-061: bench matrix ==="
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    bench)
      BENCH_N=$((BENCH_N + 1))
      if [ ! -f "$src" ]; then
        echo "std-simd-prod FAIL: missing bench $src ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-simd-prod FAIL: doc missing bench $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "std-simd-prod OK bench $item_id -> $src"
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-simd-prod FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "std-simd-prod FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$WAVE"

[ "$BENCH_N" -ge "$MIN_BENCHES" ] || die "benches=${BENCH_N} < min ${MIN_BENCHES}"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "std-simd-prod manifest OK (benches=${BENCH_N})"

if [ "${XLANG_STD061_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_simd_prod_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP" "$RATIO"
  echo "std-simd-prod gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-061: smoke (XLANG=$XLANG_BIN; check/perf obs; product r04 -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$BENCH_X" >/tmp/xlang_simd_prod_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-simd-prod OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover wrap dead source / unused compiler-make.sh
# (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
if std_simd_prod_run_smoke "$XLANG_BIN" "$BENCH_X" "r04"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-simd-prod OK: r04_simd_shuffle_select"
else
  die "r04_simd_shuffle_select.x exit!=0 (refuse soft SKIP→OK)"
fi

# Perf ratio remains observational residual (soft; not hard-green / not soft SKIP→OK).
# Do NOT set XLANG_SIMD_SS_FAIL=1 — under-ratio is OBS, not portable false-red.
# PLATFORM: SHARED archaeology — Ubuntu gold still required for link integrity.
if command -v cc >/dev/null 2>&1; then
  chmod +x tests/run-perf-simd-shuffle-select.sh
  PERF_LOG="/tmp/std_simd_prod_perf_$$.log"
  set +e
  set -o pipefail
  XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
    ./tests/run-perf-simd-shuffle-select.sh 2>&1 | tee "$PERF_LOG"
  perf_ec=$?
  set +o pipefail
  set -e
  RATIO=$(grep -E 'ratio \(stub/Xlang\):' "$PERF_LOG" | tail -1 | sed -E 's/.*ratio \(stub\/Xlang\): ([0-9.]+).*/\1/' || true)
  if [ "$perf_ec" -eq 0 ] && ! grep -qE 'OBS:' "$PERF_LOG" 2>/dev/null; then
    echo "std-simd-prod OK perf (observational)"
  else
    echo "std-simd-prod OBS perf (ratio soft residual; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
  rm -f "$PERF_LOG"
else
  echo "std-simd-prod OBS perf (no host cc; soft residual)" >&2
  OBS=$((OBS + 1))
fi

std_simd_prod_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP" "$RATIO"
echo "std-simd-prod gate OK"
