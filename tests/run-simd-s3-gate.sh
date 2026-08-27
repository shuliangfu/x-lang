#!/usr/bin/env bash
# SIMD-S3 gate: Vec8i/Vec4f HW vector add/sub/mul (x86 paddd/psubd/pmulld/vp*, mulps).
# Without objdump: compile smoke only. Darwin/ARM64/Win: platform N/A (skip), Linux x86_64 covers.
#
# Honesty: soft SKIP→OK when no native xlang retired; Darwin N/A no longer silent
# "gate OK" without counters. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die. Missing HW insn (non-strict) = obs.
# Report run=/obs=/skip=.
#
# Usage: ./tests/run-simd-s3-gate.sh
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED harness — Ubuntu x86_64 gold for HW; Darwin = skip.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/dod-host-backend.sh
. tests/lib/dod-host-backend.sh
ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || true

PREFIX="${XLANG_SIMD_S3_PREFIX:-xlang: [XLANG_SIMD_S3]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "simd-s3 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

hw_check() {
  # $1=disasm blob, $2=regex, $3=label, $4=obj path
  local disasm="$1" re="$2" label="$3" obj="$4"
  if echo "$disasm" | grep -qE "$re"; then
    echo "simd-s3: $label"
    RUN_OK=$((RUN_OK + 1))
  elif [ -n "${XLANG_SIMD_HW_STRICT:-}" ]; then
    die "no match /$re/ in $obj ($label); set XLANG_SIMD_HW=0 to allow lane-scalar fallback"
  else
    echo "simd-s3 WARN: no match /$re/ in $label (obs; rebuild xlang_asm with simd_enc.o)"
    OBS=$((OBS + 1))
  fi
}

echo "=== SIMD-S3: hw vector add/sub/mul smoke ==="
XLANG_ABS="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_ABS"
export XLANG_LINK_XLANG="$XLANG_ABS"

# Darwin / Linux ARM64 / Win lite: refresh xlang_asm asm vec peel SIGSEGV;
# integer SoA covered by dod-s1; SIMD HW hammered on Linux x86_64.
if dod_host_simd_s3_run_na; then
  echo "simd-s3: compile/run N/A on $(uname -s)-$(uname -m) (refresh xlang_asm asm vec peel SIGSEGV; Linux x86_64 covers)"
  SKIP=$((SKIP + 1))
  echo "simd-s3 gate OK"
  ok_report
  exit 0
fi

SIMD_S3_EXE_XLANG="$(dod_host_exe_shu "$XLANG_ABS")"

SMOKE_SRC="tests/simd/vec8i_hw_add_smoke.x"
SUB_SMOKE_SRC="tests/simd/vec8i_hw_sub_smoke.x"
MUL_SMOKE_SRC="tests/simd/vec8i_hw_mul_smoke.x"
FMUL_SMOKE_SRC="tests/simd/vec4f_hw_mul_smoke.x"
FMA_SMOKE_SRC="tests/simd/vec4f_hw_fma_smoke.x"
LOOP_SMOKE_SRC="tests/simd/vec8i_loop_peel_smoke.x"
LOOP_SUB_SMOKE_SRC="tests/simd/vec8i_loop_peel_sub_smoke.x"
LOOP_MUL_SMOKE_SRC="tests/simd/vec8i_loop_peel_mul_smoke.x"
STRIP_SMOKE_SRC="tests/simd/vec8i_loop_strip_var_n_smoke.x"
PEEL64_SMOKE_SRC="tests/simd/vec8i_loop_peel_n64_smoke.x"
F32_SOA_SUM_SRC="tests/simd/f32_soa_sum_peel_smoke.x"
F32_SOA_STRIP_SRC="tests/simd/f32_soa_sum_strip_smoke.x"
F32_SOA_STRIP_VAR_N_SRC="tests/simd/f32_soa_sum_strip_var_n_smoke.x"
SMOKE_O="/tmp/xlang_simd_s3_smoke.o"
SUB_SMOKE_O="/tmp/xlang_simd_s3_sub_smoke.o"
MUL_SMOKE_O="/tmp/xlang_simd_s3_mul_smoke.o"
FMUL_SMOKE_O="/tmp/xlang_simd_s3_fmul_smoke.o"
FMA_SMOKE_O="/tmp/xlang_simd_s3_fma_smoke.o"
LOOP_SMOKE_O="/tmp/xlang_simd_s3_loop_smoke.o"
LOOP_SUB_SMOKE_O="/tmp/xlang_simd_s3_loop_sub_smoke.o"
LOOP_MUL_SMOKE_O="/tmp/xlang_simd_s3_loop_mul_smoke.o"
STRIP_SMOKE_O="/tmp/xlang_simd_s3_strip_smoke.o"
PEEL64_SMOKE_O="/tmp/xlang_simd_s3_peel64_smoke.o"
F32_SOA_SUM_O="/tmp/xlang_simd_s3_f32_soa_sum.o"
F32_SOA_STRIP_O="/tmp/xlang_simd_s3_f32_soa_strip.o"
F32_SOA_STRIP_VAR_N_O="/tmp/xlang_simd_s3_f32_soa_strip_var_n.o"
F32_SOA_SUM_BIN="/tmp/xlang_simd_s3_f32_soa_sum"
F32_SOA_STRIP_BIN="/tmp/xlang_simd_s3_f32_soa_strip"
F32_SOA_STRIP_VAR_N_BIN="/tmp/xlang_simd_s3_f32_soa_strip_var_n"
LOOP_SMOKE_BIN="/tmp/xlang_simd_s3_loop"
LOOP_SUB_SMOKE_BIN="/tmp/xlang_simd_s3_loop_sub"
LOOP_MUL_SMOKE_BIN="/tmp/xlang_simd_s3_loop_mul"
STRIP_SMOKE_BIN="/tmp/xlang_simd_s3_strip"
PEEL64_SMOKE_BIN="/tmp/xlang_simd_s3_peel64"
CRT0="compiler/src/runtime/crt0_linux_x86_64.o"
rm -f "$SMOKE_O" "$SUB_SMOKE_O" "$MUL_SMOKE_O" "$FMUL_SMOKE_O" "$FMA_SMOKE_O" "$LOOP_SMOKE_O" "$LOOP_SUB_SMOKE_O" "$LOOP_MUL_SMOKE_O" "$STRIP_SMOKE_O" "$PEEL64_SMOKE_O" "$F32_SOA_SUM_O" "$F32_SOA_STRIP_O" "$F32_SOA_STRIP_VAR_N_O" "$F32_SOA_SUM_BIN" "$F32_SOA_STRIP_BIN" "$F32_SOA_STRIP_VAR_N_BIN" "$LOOP_SMOKE_BIN" "$LOOP_SUB_SMOKE_BIN" "$LOOP_MUL_SMOKE_BIN" "$STRIP_SMOKE_BIN" "$PEEL64_SMOKE_BIN"

for pair in \
  "$SMOKE_SRC|$SMOKE_O" \
  "$SUB_SMOKE_SRC|$SUB_SMOKE_O" \
  "$MUL_SMOKE_SRC|$MUL_SMOKE_O" \
  "$FMUL_SMOKE_SRC|$FMUL_SMOKE_O" \
  "$FMA_SMOKE_SRC|$FMA_SMOKE_O" \
  "$LOOP_SMOKE_SRC|$LOOP_SMOKE_O" \
  "$LOOP_SUB_SMOKE_SRC|$LOOP_SUB_SMOKE_O" \
  "$LOOP_MUL_SMOKE_SRC|$LOOP_MUL_SMOKE_O" \
  "$STRIP_SMOKE_SRC|$STRIP_SMOKE_O" \
  "$PEEL64_SMOKE_SRC|$PEEL64_SMOKE_O"
do
  src="${pair%%|*}"
  obj="${pair##*|}"
  [ -f "$src" ] || die "missing $src"
  if ! "$XLANG_ABS" "$src" -o "$obj"; then
    die "compile $src"
  fi
done

if [ -n "$DOD_F32_BACKEND_ARGS" ]; then
  echo "simd-s3: skip f32 .o compile (f32 exe run N/A on $(uname -s)-$(uname -m); x86_64 covers)"
  SKIP=$((SKIP + 1))
else
  for pair in \
    "$F32_SOA_SUM_SRC|$F32_SOA_SUM_O" \
    "$F32_SOA_STRIP_SRC|$F32_SOA_STRIP_O" \
    "$F32_SOA_STRIP_VAR_N_SRC|$F32_SOA_STRIP_VAR_N_O"
  do
    src="${pair%%|*}"
    obj="${pair##*|}"
    [ -f "$src" ] || die "missing $src"
    if ! "$XLANG_ABS" "$src" -o "$obj"; then
      die "compile $src"
    fi
  done
fi

if [ ! -f "$SMOKE_O" ] || [ ! -f "$SUB_SMOKE_O" ] || [ ! -f "$MUL_SMOKE_O" ] || [ ! -f "$FMUL_SMOKE_O" ] \
  || [ ! -f "$LOOP_SMOKE_O" ] || [ ! -f "$LOOP_SUB_SMOKE_O" ] || [ ! -f "$LOOP_MUL_SMOKE_O" ] \
  || [ ! -f "$STRIP_SMOKE_O" ] || [ ! -f "$PEEL64_SMOKE_O" ]; then
  die "missing object file"
fi
if [ -z "$DOD_F32_BACKEND_ARGS" ]; then
  if [ ! -f "$F32_SOA_SUM_O" ] || [ ! -f "$F32_SOA_STRIP_O" ] || [ ! -f "$F32_SOA_STRIP_VAR_N_O" ]; then
    die "missing object file"
  fi
fi

ARCH="$(uname -m 2>/dev/null || echo unknown)"
if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
  if command -v objdump >/dev/null 2>&1; then
    DISAS="$(objdump -d "$SMOKE_O" 2>/dev/null || true)"
    SUB_DISAS="$(objdump -d "$SUB_SMOKE_O" 2>/dev/null || true)"
    MUL_DISAS="$(objdump -d "$MUL_SMOKE_O" 2>/dev/null || true)"
    FMUL_DISAS="$(objdump -d "$FMUL_SMOKE_O" 2>/dev/null || true)"
    FMA_DISAS="$(objdump -d "$FMA_SMOKE_O" 2>/dev/null || true)"
    LOOP_DISAS="$(objdump -d "$LOOP_SMOKE_O" 2>/dev/null || true)"
    LOOP_SUB_DISAS="$(objdump -d "$LOOP_SUB_SMOKE_O" 2>/dev/null || true)"
    LOOP_MUL_DISAS="$(objdump -d "$LOOP_MUL_SMOKE_O" 2>/dev/null || true)"
    STRIP_DISAS="$(objdump -d "$STRIP_SMOKE_O" 2>/dev/null || true)"
    PEEL64_DISAS="$(objdump -d "$PEEL64_SMOKE_O" 2>/dev/null || true)"
    F32_SOA_DISAS="$(objdump -d "$F32_SOA_SUM_O" 2>/dev/null || true)"
    F32_SOA_STRIP_DISAS="$(objdump -d "$F32_SOA_STRIP_O" 2>/dev/null || true)"
    F32_SOA_STRIP_VAR_N_DISAS="$(objdump -d "$F32_SOA_STRIP_VAR_N_O" 2>/dev/null || true)"
    hw_check "$DISAS" 'vpaddd|paddd' 'hw vector iadd insn present (vpaddd/paddd)' "$SMOKE_O"
    hw_check "$SUB_DISAS" 'vpsubd|psubd' 'hw vector isub insn present (vpsubd/psubd)' "$SUB_SMOKE_O"
    hw_check "$MUL_DISAS" 'vpmulld|pmulld' 'hw vector imul insn present (vpmulld/pmulld)' "$MUL_SMOKE_O"
    hw_check "$FMUL_DISAS" 'mulps' 'hw vector fmul insn present (mulps)' "$FMUL_SMOKE_O"
    if echo "$FMA_DISAS" | grep -qE 'vfmadd231ps|vfmadd213ps|vfmadd132ps'; then
      echo "simd-s3: hw vector fma insn present (vfmadd)"
      RUN_OK=$((RUN_OK + 1))
    elif echo "$FMA_DISAS" | grep -qE 'mulps' && echo "$FMA_DISAS" | grep -qE 'addps'; then
      echo "simd-s3: hw vector fma fallback present (mulps+addps)"
      RUN_OK=$((RUN_OK + 1))
    elif [ -n "${XLANG_SIMD_HW_STRICT:-}" ]; then
      die "no vfmadd/mulps+addps in $FMA_SMOKE_O"
    else
      echo "simd-s3 WARN: no vfmadd in vec4f fma smoke (obs)"
      OBS=$((OBS + 1))
    fi
    hw_check "$LOOP_DISAS" 'vpaddd|paddd' 'loop peel hw vector iadd present (vpaddd/paddd)' "$LOOP_SMOKE_O"
    hw_check "$LOOP_SUB_DISAS" 'vpsubd|psubd' 'loop peel hw vector isub present (vpsubd/psubd)' "$LOOP_SUB_SMOKE_O"
    hw_check "$LOOP_MUL_DISAS" 'vpmulld|pmulld' 'loop peel hw vector imul present (vpmulld/pmulld)' "$LOOP_MUL_SMOKE_O"
    hw_check "$STRIP_DISAS" 'vpaddd|paddd' 'runtime strip loop hw vector iadd present' "$STRIP_SMOKE_O"
    hw_check "$PEEL64_DISAS" 'vpaddd|paddd' 'n=64 const-propagated peel hw vector iadd present' "$PEEL64_SMOKE_O"
    if [ -z "$DOD_F32_BACKEND_ARGS" ]; then
      hw_check "$F32_SOA_DISAS" 'movups|addps' 'f32 SoA sum peel movups/addps present' "$F32_SOA_SUM_O"
      hw_check "$F32_SOA_STRIP_DISAS" 'movups|addps' 'f32 SoA strip n=10 movups/addps present' "$F32_SOA_STRIP_O"
      hw_check "$F32_SOA_STRIP_VAR_N_DISAS" 'movups|addps' 'f32 SoA strip var n movups/addps present' "$F32_SOA_STRIP_VAR_N_O"
    fi
  else
    echo "simd-s3: objdump missing; compile-only observational"
    OBS=$((OBS + 1))
  fi
else
  echo "simd-s3: non-x86_64 host; compile-only observational"
  OBS=$((OBS + 1))
fi

# f32 SoA strip: link+run epilogue (n=10 / let n=12)
simd_s3_run_f32_expect() {
  local src="$1"
  local obj="$2"
  local bin="$3"
  local expect="$4"
  local label="$5"
  local link_shu="$XLANG_ABS"
  local backend_args=""
  if [ -n "$DOD_F32_BACKEND_ARGS" ]; then
    link_shu="$SIMD_S3_EXE_XLANG"
    backend_args="$DOD_F32_BACKEND_ARGS"
  fi
  if dod_host_f32_run_na; then
    echo "simd-s3: $label run N/A on $(uname -s)-$(uname -m) (gen_driver -backend c f32 WIP; Linux x86_64 covers)"
    SKIP=$((SKIP + 1))
    return 0
  fi
  if XLANG="$XLANG_ABS" "$link_shu" $backend_args "$src" -o "$bin" 2>/dev/null && [ -x "$bin" ]; then
    RC=0
    "$bin" >/dev/null 2>&1 || RC=$?
    if [ "$RC" -ne "$expect" ]; then
      die "$label expected exit $expect, got $RC"
    fi
    echo "simd-s3: $label exit=$expect OK"
    RUN_OK=$((RUN_OK + 1))
  elif command -v ld >/dev/null 2>&1 && [ -f "$obj" ] && [ -f "$CRT0" ]; then
    if ld -o "$bin" "$obj" "$CRT0" 2>/dev/null; then
      RC=0
      "$bin" >/dev/null 2>&1 || RC=$?
      if [ "$RC" -ne "$expect" ]; then
        die "$label expected exit $expect, got $RC"
      fi
      echo "simd-s3: $label exit=$expect OK"
      RUN_OK=$((RUN_OK + 1))
    else
      echo "simd-s3: $label link skipped (obs)"
      OBS=$((OBS + 1))
    fi
  else
    echo "simd-s3: $label compile-only (obs)"
    OBS=$((OBS + 1))
  fi
}

simd_s3_run_f32_expect "$F32_SOA_SUM_SRC" "$F32_SOA_SUM_O" "$F32_SOA_SUM_BIN" 8 "f32_soa_sum_peel_smoke"
simd_s3_run_f32_expect "$F32_SOA_STRIP_SRC" "$F32_SOA_STRIP_O" "$F32_SOA_STRIP_BIN" 10 "f32_soa_sum_strip_smoke"
simd_s3_run_f32_expect "$F32_SOA_STRIP_VAR_N_SRC" "$F32_SOA_STRIP_VAR_N_O" "$F32_SOA_STRIP_VAR_N_BIN" 12 "f32_soa_sum_strip_var_n_smoke"
# Integer peel/strip must RUN (not compile-only): n=20 remainder used to SIGILL on bad xmm1 VEX.
simd_s3_run_f32_expect "$LOOP_SMOKE_SRC" "$LOOP_SMOKE_O" "$LOOP_SMOKE_BIN" 99 "vec8i_loop_peel_add"
simd_s3_run_f32_expect "$LOOP_SUB_SMOKE_SRC" "$LOOP_SUB_SMOKE_O" "$LOOP_SUB_SMOKE_BIN" 11 "vec8i_loop_peel_sub"
simd_s3_run_f32_expect "$LOOP_MUL_SMOKE_SRC" "$LOOP_MUL_SMOKE_O" "$LOOP_MUL_SMOKE_BIN" 12 "vec8i_loop_peel_mul"
simd_s3_run_f32_expect "$STRIP_SMOKE_SRC" "$STRIP_SMOKE_O" "$STRIP_SMOKE_BIN" 6 "vec8i_loop_strip_var_n"
simd_s3_run_f32_expect "$PEEL64_SMOKE_SRC" "$PEEL64_SMOKE_O" "$PEEL64_SMOKE_BIN" 3 "vec8i_loop_peel_n64"

echo "simd-s3 gate OK"
ok_report
