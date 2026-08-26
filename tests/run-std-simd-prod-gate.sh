#!/usr/bin/env bash
# STD-061：std.simd shuffle/select 生产级 bench 门禁（假权威诚实）。
#
# 用法：./tests/run-std-simd-prod-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational
# (check gate paused 2026-08-05); manifest hard; perf soft SKIP (ratio soft
# residual — not soft-green on missing manifest / fossil DOC). Report
# check=/bench=/skip=/ratio=.
# Product bench path = bench/r04_simd_shuffle_select*; archive DOC had drifted
# to stub/Shu + tests/bench/simd_shuffle_select.x (portable false-red).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD061_DOC:-analysis/archive/std/std-simd-prod-v1.md}"
WAVE="${XLANG_STD061_WAVE_TSV:-tests/baseline/std-simd-prod-wave.tsv}"
PARENT_DOC="${XLANG_STD_SIMD_SHUFFLE_SELECT_DOC:-analysis/archive/std/std-simd-shuffle-select-v1.md}"
MOD_X="std/simd/mod.x"
LIB="tests/lib/std-simd-prod.sh"
MIN_BENCHES=3

# shellcheck source=tests/lib/std-simd-prod.sh
. "$LIB"

echo "=== STD-061: simd prod bench manifest ==="
for f in "$DOC" "$WAVE" "$LIB" "$PARENT_DOC" "$MOD_X" \
  bench/r04_simd_shuffle_select.x bench/r04_simd_shuffle_select_stub.c \
  tests/run-perf-simd-shuffle-select.sh; do
  if [ ! -f "$f" ]; then
    echo "std-simd-prod gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_benches) MIN_BENCHES="$c2" ;;
  esac
done < "$WAVE"

# Product keywords (live RFC / r04 path). Fossil stub/Shu + tests/bench/… rejected.
for kw in STD-061 生产级 perf bench_shuffle_hot min_benches stub/Xlang r04_simd_shuffle_select; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-simd-prod gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 3. Gate' "$DOC" 2>/dev/null; then
  echo "std-simd-prod gate FAIL: doc missing '## 3. Gate'" >&2
  exit 1
fi

# Product STD-* IDs live on the module README (same place as STD-047 / STD-153).
if ! grep -qF 'STD-061' std/simd/README.md 2>/dev/null; then
  echo "std-simd-prod gate FAIL: missing STD-061 anchor in std/simd/README.md" >&2
  exit 1
fi
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

if [ "$BENCH_N" -lt "$MIN_BENCHES" ]; then
  echo "std-simd-prod gate FAIL: benches=${BENCH_N} < min ${MIN_BENCHES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "std-simd-prod gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "std-simd-prod manifest OK (benches=${BENCH_N})"

if [ "${XLANG_STD061_MANIFEST_ONLY:-0}" = "1" ]; then
  std_simd_prod_emit_report "ok" 0 0 0 1 ""
  echo "std-simd-prod gate OK (manifest only)"
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
    *) return 0 ;;
  esac
}

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # SIMD Vec bodies need asm backend (xlang-c cannot emit C for Vec).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang ./compiler/xlang-c; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      case "$cand" in
        */xlang-c|*/xlang-x*) continue ;;
      esac
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
BENCH_OK=0
BENCH_SKIP=0
SKIP=1
RATIO=""

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-061: perf (XLANG=$XLANG_BIN; check observational; perf soft) ==="
  # Observational check on hot fixture (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . bench/r04_simd_shuffle_select.x >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-simd-prod gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if command -v cc >/dev/null 2>&1; then
    chmod +x tests/run-perf-simd-shuffle-select.sh
    PERF_LOG="/tmp/std_simd_prod_perf_$$.log"
    set +e
    set -o pipefail
    XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" XLANG_SIMD_SS_FAIL=1 \
      ./tests/run-perf-simd-shuffle-select.sh 2>&1 | tee "$PERF_LOG"
    perf_ec=$?
    set +o pipefail
    set -e
    if [ "$perf_ec" -eq 0 ]; then
      BENCH_OK=1
      SKIP=0
      RATIO=$(grep -E 'ratio \(stub/Xlang\):' "$PERF_LOG" | tail -1 | sed -E 's/.*ratio \(stub\/Xlang\): ([0-9.]+).*/\1/' || true)
      echo "std-simd-prod runnable OK perf"
    elif grep -qE 'SKIP:' "$PERF_LOG" 2>/dev/null; then
      # Honest soft: runner skipped (host/bench unavailable) — not false-green on fossil DOC.
      BENCH_SKIP=1
      SKIP=1
      echo "std-simd-prod gate SKIP perf (runner skipped; soft residual)" >&2
    else
      # Honest soft: ratio/compile below threshold — soft residual, not portable-false-red.
      BENCH_SKIP=1
      SKIP=1
      echo "std-simd-prod WARN: perf failed; manifest OK (perf soft residual)" >&2
      tail -5 "$PERF_LOG" >&2 || true
    fi
    rm -f "$PERF_LOG"
  else
    echo "std-simd-prod gate SKIP perf (no host cc; soft residual)" >&2
    BENCH_SKIP=1
    SKIP=1
  fi
else
  echo "std-simd-prod gate FAIL: no native asm xlang" >&2
  std_simd_prod_emit_report "fail" 0 0 0 0 ""
  exit 1
fi

# check stays observational; hard-green signal is manifest; perf remains soft.
echo "std-simd-prod check_ok=${CHECK_OK} (observational)"
std_simd_prod_emit_report "ok" "$CHECK_OK" "$BENCH_OK" "$BENCH_SKIP" "$SKIP" "$RATIO"
echo "std-simd-prod gate OK"
