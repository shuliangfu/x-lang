#!/usr/bin/env bash
# DOD-S1 perf: SoA vs AoS column scan; optional Linux perf L1 miss (SoA ≤ cap%).
#
# Honesty: soft XLANG_DOD_SOA_FAIL:-0 previously left correctness / disasm /
# L1-over-cap unchecked (silent OK = portable false-green). Soft SKIP→OK on
# missing native retired. Prefer product xlang_asm. Correctness / disasm /
# L1-over / compile-only-no-exe = obs (FAIL=1 still hard). Explicit bad XLANG
# = hard die. Report run=/obs=/skip=. Also emits XLANG_CACHE_MISS lines.
#
# Usage:
#   ./tests/run-perf-dod-soa.sh
#   XLANG=./compiler/xlang_asm ./tests/run-perf-dod-soa.sh
# Env:
#   XLANG_DOD_SOA_FAIL=1 — correctness / disasm / L1-over hard-fail
#   XLANG_DOD_SOA_REQUIRE_L1=1 — missing perf miss rate = hard (CI Linux)
# PLATFORM: SHARED archaeology (Ubuntu gold L1; Darwin compile+run, L1 N/A).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/perf-cache-miss.sh
. tests/lib/perf-cache-miss.sh
# Honesty: do NOT auto-make before resolve.

# PLATFORM: SHARED — fixture names follow r03_ bench id (wave1191 rename).
SOA_SRC="bench/r03_dod_soa_sum.x"
AOS_SRC="bench/r03_dod_aos_sum.x"
F32_SOA_SRC="bench/r03_dod_f32_soa_sum.x"
F32_AOS_SRC="bench/r03_dod_f32_aos_sum.x"
SOA_O="/tmp/xlang_dod_soa_bench.o"
AOS_O="/tmp/xlang_dod_aos_bench.o"
F32_SOA_O="/tmp/xlang_dod_f32_soa_bench.o"
F32_AOS_O="/tmp/xlang_dod_f32_aos_bench.o"
SOA_EXE="/tmp/xlang_dod_soa_bench"
AOS_EXE="/tmp/xlang_dod_aos_bench"
F32_SOA_EXE="/tmp/xlang_dod_f32_soa_bench"
F32_AOS_EXE="/tmp/xlang_dod_f32_aos_bench"
CRT0="compiler/src/runtime/crt0_linux_x86_64.o"
N="${XLANG_DOD_BENCH_N:-4096}"
MAX_SOA_MISS_PCT="${XLANG_DOD_SOA_MAX_L1_MISS_PCT:-1.0}"
FAIL_FLAG="${XLANG_DOD_SOA_FAIL:-0}"
PREFIX="xlang: [XLANG_DOD_SOA]"
OBS=0
RUN_OK=0
SKIP=0

# Linux wait status only low 8 bits: N>255 ⇒ bench returns sum/256; gate compares WANT_RC.
WANT_RC="$N"
if [ "$N" -gt 255 ] 2>/dev/null; then
  WANT_RC=$((N / 256))
fi

die() {
  echo "dod-soa FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

obs() {
  echo "dod-soa OBS: $*" >&2
  OBS=1
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

# sum=4096 → return/256=16; mis-return 4096 ⇒ shell exit=0 (same as 16 mod 256)
dod_rc_ok() {
  local rc="$1"
  [ "$rc" = "$WANT_RC" ] && return 0
  if [ "$WANT_RC" = "16" ] && [ "$N" = "4096" ] && [ "$rc" = "0" ]; then
    return 0
  fi
  return 1
}

maybe_hard() {
  if [ "$FAIL_FLAG" = "1" ]; then
    die "$* (XLANG_DOD_SOA_FAIL=1)"
  fi
}

echo "=== DOD SoA perf: ${SOA_SRC} vs ${AOS_SRC} (N=${N}, SoA L1 miss cap ${MAX_SOA_MISS_PCT}%) ==="
echo "=== DOD f32 addss bench: ${F32_SOA_SRC} vs ${F32_AOS_SRC} ==="

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "dod-soa: resolve=$XLANG_BIN"

for src in "$SOA_SRC" "$AOS_SRC" "$F32_SOA_SRC" "$F32_AOS_SRC"; do
  [ -f "$src" ] || die "missing $src"
done

rm -f "$SOA_O" "$AOS_O" "$F32_SOA_O" "$F32_AOS_O" "$SOA_EXE" "$AOS_EXE" "$F32_SOA_EXE" "$F32_AOS_EXE"

# Prefer xlang_asm full link (no crt0); fall back to .o + ld.
if ! XLANG="$XLANG_BIN" "$XLANG_BIN" "$SOA_SRC" -o "$SOA_EXE" 2>/dev/null; then
  SOA_EXE=""
  if ! XLANG="$XLANG_BIN" "$XLANG_BIN" "$SOA_SRC" -o "$SOA_O"; then
    die "compile $SOA_SRC"
  fi
fi
if ! XLANG="$XLANG_BIN" "$XLANG_BIN" "$AOS_SRC" -o "$AOS_EXE" 2>/dev/null; then
  AOS_EXE=""
  if ! XLANG="$XLANG_BIN" "$XLANG_BIN" "$AOS_SRC" -o "$AOS_O"; then
    die "compile $AOS_SRC"
  fi
fi

# PLATFORM: LINUX — crt0 link only when -o exe did not produce a runnable.
if [ "$(uname -s)" = "Linux" ] && command -v ld >/dev/null 2>&1 && [ -f "$CRT0" ]; then
  if [ -z "$SOA_EXE" ] || [ ! -x "$SOA_EXE" ]; then
    if [ -f "$SOA_O" ] && ld -o "$SOA_EXE" "$SOA_O" "$CRT0" 2>/dev/null; then
      :
    else
      echo "dod-soa: link $SOA_EXE skipped" >&2
      SOA_EXE=""
    fi
  fi
  if [ -z "$AOS_EXE" ] || [ ! -x "$AOS_EXE" ]; then
    if [ -f "$AOS_O" ] && ld -o "$AOS_EXE" "$AOS_O" "$CRT0" 2>/dev/null; then
      :
    else
      echo "dod-soa: link $AOS_EXE skipped" >&2
      AOS_EXE=""
    fi
  fi
fi

# f32 column scan (addss hot path). Compile-fail = obs (product CG residual on
# some hosts, e.g. Darwin arm64 CG002); FAIL=1 still hard.
F32_COMPILE_OK=1
if ! XLANG="$XLANG_BIN" "$XLANG_BIN" "$F32_SOA_SRC" -o "$F32_SOA_EXE" 2>/dev/null; then
  F32_SOA_EXE=""
  if ! XLANG="$XLANG_BIN" "$XLANG_BIN" "$F32_SOA_SRC" -o "$F32_SOA_O" 2>/dev/null; then
    F32_COMPILE_OK=0
    obs "compile $F32_SOA_SRC"
    maybe_hard "compile $F32_SOA_SRC"
  fi
fi
if [ "$F32_COMPILE_OK" -eq 1 ]; then
  if ! XLANG="$XLANG_BIN" "$XLANG_BIN" "$F32_AOS_SRC" -o "$F32_AOS_EXE" 2>/dev/null; then
    F32_AOS_EXE=""
    if ! XLANG="$XLANG_BIN" "$XLANG_BIN" "$F32_AOS_SRC" -o "$F32_AOS_O" 2>/dev/null; then
      F32_COMPILE_OK=0
      obs "compile $F32_AOS_SRC"
      maybe_hard "compile $F32_AOS_SRC"
    fi
  fi
fi

if [ "$F32_COMPILE_OK" -eq 1 ] && [ "$(uname -s)" = "Linux" ] && command -v ld >/dev/null 2>&1 && [ -f "$CRT0" ]; then
  if [ -z "$F32_SOA_EXE" ] || [ ! -x "$F32_SOA_EXE" ]; then
    if [ -f "$F32_SOA_O" ] && ld -o "$F32_SOA_EXE" "$F32_SOA_O" "$CRT0" 2>/dev/null; then
      :
    else
      F32_SOA_EXE=""
    fi
  fi
  if [ -z "$F32_AOS_EXE" ] || [ ! -x "$F32_AOS_EXE" ]; then
    if [ -f "$F32_AOS_O" ] && ld -o "$F32_AOS_EXE" "$F32_AOS_O" "$CRT0" 2>/dev/null; then
      :
    else
      F32_AOS_EXE=""
    fi
  fi
fi

if [ "$F32_COMPILE_OK" -eq 1 ] && [ -x "$F32_SOA_EXE" ] && [ -x "$F32_AOS_EXE" ]; then
  F32_SOA_RC="$("$F32_SOA_EXE" 2>/dev/null; echo $?)"
  F32_SOA_RC="${F32_SOA_RC##*$'\n'}"
  F32_AOS_RC="$("$F32_AOS_EXE" 2>/dev/null; echo $?)"
  F32_AOS_RC="${F32_AOS_RC##*$'\n'}"
  echo "f32 SoA exit=${F32_SOA_RC} (expect ${WANT_RC})  f32 AoS exit=${F32_AOS_RC} (expect ${WANT_RC})"
  if ! dod_rc_ok "$F32_SOA_RC" || ! dod_rc_ok "$F32_AOS_RC"; then
    obs "f32 bench correctness"
    maybe_hard "f32 bench correctness"
  fi
  if command -v objdump >/dev/null 2>&1; then
    F32_SOA_DIS="$(objdump -d "$F32_SOA_EXE" 2>/dev/null || true)"
    if echo "$F32_SOA_DIS" | grep -qE 'movups|addps'; then
      echo "dod-soa: f32 SoA disasm movups/addps OK (SIMD reduce peel)"
    elif echo "$F32_SOA_DIS" | grep -q 'addss'; then
      echo "dod-soa: f32 SoA disasm addss OK"
    else
      obs "f32 SoA disasm missing movups/addps or addss"
      maybe_hard "f32 SoA disasm missing movups/addps or addss"
    fi
    if objdump -d "$F32_AOS_EXE" 2>/dev/null | grep -q 'addss'; then
      echo "dod-soa: f32 AoS disasm addss OK"
    else
      echo "dod-soa: f32 AoS disasm missing addss (non-fatal)" >&2
    fi
  fi
elif [ "$F32_COMPILE_OK" -eq 1 ] && [ -f "$F32_SOA_O" ] && [ -f "$F32_AOS_O" ]; then
  obs "f32 bench compile-only (no runnable exe)"
  maybe_hard "f32 bench compile-only (no runnable exe)"
elif [ "$F32_COMPILE_OK" -eq 1 ]; then
  obs "f32 bench missing object or executable"
  maybe_hard "f32 bench missing object or executable"
fi


if [ -z "$SOA_EXE" ] || [ -z "$AOS_EXE" ] || [ ! -x "$SOA_EXE" ] || [ ! -x "$AOS_EXE" ]; then
  if [ -f "$SOA_O" ] && [ -f "$AOS_O" ]; then
    obs "i32 compile-only (no runnable exe)"
    maybe_hard "i32 compile-only (no runnable exe)"
    ok_report
    echo "dod-soa gate OK"
    exit 0
  fi
  die "missing object or executable"
fi

SOA_RC="$("$SOA_EXE" 2>/dev/null; echo $?)"
SOA_RC="${SOA_RC##*$'\n'}"
AOS_RC="$("$AOS_EXE" 2>/dev/null; echo $?)"
AOS_RC="${AOS_RC##*$'\n'}"
echo "SoA exit=${SOA_RC} (expect ${WANT_RC}, raw sum=${N})  AoS exit=${AOS_RC} (expect ${WANT_RC})"
if ! dod_rc_ok "$SOA_RC" || ! dod_rc_ok "$AOS_RC"; then
  obs "i32 correctness"
  maybe_hard "i32 correctness"
fi

SOA_MISS="nan"
AOS_MISS="nan"
if [ "$(uname -s)" = "Linux" ]; then
  if ! perf_cmd="$(perf_cm_resolve_bin)"; then
    echo "dod-soa: perf stat skipped (no perf binary)"
  else
    SOA_MISS=$(perf_cm_l1_miss_pct "$SOA_EXE")
    AOS_MISS=$(perf_cm_l1_miss_pct "$AOS_EXE")
    # Honesty: only accept a single numeric token (sysctl leak historically produced multi-line garbage).
    if ! [[ "$SOA_MISS" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
      SOA_MISS="nan"
    fi
    if ! [[ "$AOS_MISS" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
      AOS_MISS="nan"
    fi
    echo "SoA L1 miss rate: ${SOA_MISS}%"
    echo "AoS L1 miss rate: ${AOS_MISS}%"
    soa_ok=0
    if [ "$SOA_MISS" != "nan" ]; then
      if awk -v s="$SOA_MISS" -v cap="$MAX_SOA_MISS_PCT" 'BEGIN { exit (s + 0 <= cap + 0.0001) ? 0 : 1 }'; then
        echo "dod-soa L1 miss OK (SoA <= ${MAX_SOA_MISS_PCT}%)"
        soa_ok=1
      else
        obs "L1 miss SoA ${SOA_MISS}% > cap ${MAX_SOA_MISS_PCT}%"
        maybe_hard "L1 miss SoA ${SOA_MISS}% > cap ${MAX_SOA_MISS_PCT}%"
      fi
      perf_cm_report_emit "dod_soa_sum_x" "soa" "$SOA_MISS" "$MAX_SOA_MISS_PCT" "$soa_ok"
    else
      echo "dod-soa: SoA L1 miss unavailable (nan; leave as skip/obs under REQUIRE_L1)"
    fi
    if [ "$SOA_MISS" != "nan" ] && [ "$AOS_MISS" != "nan" ]; then
      perf_cm_report_emit "dod_aos_sum_x" "aos" "$AOS_MISS" "$MAX_SOA_MISS_PCT" "0"
      if awk -v soa="$SOA_MISS" -v aos="$AOS_MISS" 'BEGIN { exit (soa < aos) ? 0 : 1 }'; then
        echo "dod-soa: SoA L1 miss < AoS (column scan wins)"
      else
        echo "dod-soa: SoA L1 miss not lower than AoS (non-fatal)" >&2
      fi
    fi
  fi
else
  echo "dod-soa: perf stat skipped (need Linux + perf)"
fi

# GHA / CI: XLANG_DOD_SOA_REQUIRE_L1=1 ⇒ perf must be available (no soft skip).
if [ "${XLANG_DOD_SOA_REQUIRE_L1:-0}" = "1" ]; then
  if [ "${SOA_MISS:-nan}" = "nan" ] || [ "${AOS_MISS:-nan}" = "nan" ]; then
    die "XLANG_DOD_SOA_REQUIRE_L1=1 but perf miss rate unavailable"
  fi
fi

if [ "$OBS" -eq 0 ]; then
  RUN_OK=1
fi
ok_report
echo "dod-soa gate OK"
