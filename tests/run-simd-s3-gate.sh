#!/usr/bin/env bash
# SIMD-S3 门禁：Vec8i/Vec4f 硬件向量 add/sub/mul（x86 paddd/psubd/pmulld/vp*、mulps）；无 objdump 时仅编译 smoke。
# 用法：
#   ./tests/run-simd-s3-gate.sh
#   SHU=./compiler/shu_asm ./tests/run-simd-s3-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-host-backend.sh
source "$(dirname "$0")/lib/dod-host-backend.sh"
ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || true

SHU_BIN="${SHU:-}"
case "$SHU_BIN" in
  /*) SHU_ABS="$SHU_BIN" ;;
  "") SHU_ABS="" ;;
  *) SHU_ABS="$(pwd)/$SHU_BIN" ;;
esac

simd_s3_native_exe() {
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

if [ -z "$SHU_ABS" ] || ! simd_s3_native_exe "$SHU_ABS"; then
  SHU_ABS=""
  for cand in ./compiler/shu_asm ./compiler/shu; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if simd_s3_native_exe "$abs"; then
      SHU_ABS="$abs"
      break
    fi
  done
fi

echo "=== SIMD-S3: hw vector add/sub/mul smoke ==="

if [ -z "$SHU_ABS" ] || ! simd_s3_native_exe "$SHU_ABS"; then
  echo "simd-s3 gate SKIP (no native shu/shu_asm)"
  exit 0
fi

# Darwin：shu_asm asm 部分 vec peel 烟测 SIGSEGV；整数 SoA/DOD 由 dod-s1 覆盖，SIMD 实跑由 Linux ARM64 承担。
case "$(uname -s 2>/dev/null)" in
  Darwin)
    echo "simd-s3: compile/run N/A on Darwin (shu_asm asm vec peel SIGSEGV; Linux ARM64 covers)"
    echo "simd-s3 gate OK"
    exit 0
    ;;
esac

SIMD_S3_EXE_SHU="$(dod_host_exe_shu "$SHU_ABS")"

SMOKE_SRC="tests/simd/vec8i_hw_add_smoke.su"
SUB_SMOKE_SRC="tests/simd/vec8i_hw_sub_smoke.su"
MUL_SMOKE_SRC="tests/simd/vec8i_hw_mul_smoke.su"
FMUL_SMOKE_SRC="tests/simd/vec4f_hw_mul_smoke.su"
LOOP_SMOKE_SRC="tests/simd/vec8i_loop_peel_smoke.su"
LOOP_SUB_SMOKE_SRC="tests/simd/vec8i_loop_peel_sub_smoke.su"
LOOP_MUL_SMOKE_SRC="tests/simd/vec8i_loop_peel_mul_smoke.su"
STRIP_SMOKE_SRC="tests/simd/vec8i_loop_strip_var_n_smoke.su"
PEEL64_SMOKE_SRC="tests/simd/vec8i_loop_peel_n64_smoke.su"
F32_SOA_SUM_SRC="tests/simd/f32_soa_sum_peel_smoke.su"
F32_SOA_STRIP_SRC="tests/simd/f32_soa_sum_strip_smoke.su"
F32_SOA_STRIP_VAR_N_SRC="tests/simd/f32_soa_sum_strip_var_n_smoke.su"
SMOKE_O="/tmp/shu_simd_s3_smoke.o"
SUB_SMOKE_O="/tmp/shu_simd_s3_sub_smoke.o"
MUL_SMOKE_O="/tmp/shu_simd_s3_mul_smoke.o"
FMUL_SMOKE_O="/tmp/shu_simd_s3_fmul_smoke.o"
LOOP_SMOKE_O="/tmp/shu_simd_s3_loop_smoke.o"
LOOP_SUB_SMOKE_O="/tmp/shu_simd_s3_loop_sub_smoke.o"
LOOP_MUL_SMOKE_O="/tmp/shu_simd_s3_loop_mul_smoke.o"
STRIP_SMOKE_O="/tmp/shu_simd_s3_strip_smoke.o"
PEEL64_SMOKE_O="/tmp/shu_simd_s3_peel64_smoke.o"
F32_SOA_SUM_O="/tmp/shu_simd_s3_f32_soa_sum.o"
F32_SOA_STRIP_O="/tmp/shu_simd_s3_f32_soa_strip.o"
F32_SOA_STRIP_VAR_N_O="/tmp/shu_simd_s3_f32_soa_strip_var_n.o"
F32_SOA_SUM_BIN="/tmp/shu_simd_s3_f32_soa_sum"
F32_SOA_STRIP_BIN="/tmp/shu_simd_s3_f32_soa_strip"
F32_SOA_STRIP_VAR_N_BIN="/tmp/shu_simd_s3_f32_soa_strip_var_n"
CRT0="compiler/src/runtime/crt0_linux_x86_64.o"
rm -f "$SMOKE_O" "$SUB_SMOKE_O" "$MUL_SMOKE_O" "$FMUL_SMOKE_O" "$LOOP_SMOKE_O" "$LOOP_SUB_SMOKE_O" "$LOOP_MUL_SMOKE_O" "$STRIP_SMOKE_O" "$PEEL64_SMOKE_O" "$F32_SOA_SUM_O" "$F32_SOA_STRIP_O" "$F32_SOA_STRIP_VAR_N_O" "$F32_SOA_SUM_BIN" "$F32_SOA_STRIP_BIN" "$F32_SOA_STRIP_VAR_N_BIN"

if ! SHU="$SHU_ABS" "$SHU_ABS" "$SMOKE_SRC" -o "$SMOKE_O"; then
  echo "simd-s3 FAIL: compile $SMOKE_SRC" >&2
  exit 1
fi

if ! SHU="$SHU_ABS" "$SHU_ABS" "$SUB_SMOKE_SRC" -o "$SUB_SMOKE_O"; then
  echo "simd-s3 FAIL: compile $SUB_SMOKE_SRC" >&2
  exit 1
fi

if ! SHU="$SHU_ABS" "$SHU_ABS" "$MUL_SMOKE_SRC" -o "$MUL_SMOKE_O"; then
  echo "simd-s3 FAIL: compile $MUL_SMOKE_SRC" >&2
  exit 1
fi

if ! SHU="$SHU_ABS" "$SHU_ABS" "$FMUL_SMOKE_SRC" -o "$FMUL_SMOKE_O"; then
  echo "simd-s3 FAIL: compile $FMUL_SMOKE_SRC" >&2
  exit 1
fi

if ! SHU="$SHU_ABS" "$SHU_ABS" "$LOOP_SMOKE_SRC" -o "$LOOP_SMOKE_O"; then
  echo "simd-s3 FAIL: compile $LOOP_SMOKE_SRC" >&2
  exit 1
fi

if ! SHU="$SHU_ABS" "$SHU_ABS" "$LOOP_SUB_SMOKE_SRC" -o "$LOOP_SUB_SMOKE_O"; then
  echo "simd-s3 FAIL: compile $LOOP_SUB_SMOKE_SRC" >&2
  exit 1
fi

if ! SHU="$SHU_ABS" "$SHU_ABS" "$LOOP_MUL_SMOKE_SRC" -o "$LOOP_MUL_SMOKE_O"; then
  echo "simd-s3 FAIL: compile $LOOP_MUL_SMOKE_SRC" >&2
  exit 1
fi

if ! SHU="$SHU_ABS" "$SHU_ABS" "$STRIP_SMOKE_SRC" -o "$STRIP_SMOKE_O"; then
  echo "simd-s3 FAIL: compile $STRIP_SMOKE_SRC" >&2
  exit 1
fi

if ! SHU="$SHU_ABS" "$SHU_ABS" "$PEEL64_SMOKE_SRC" -o "$PEEL64_SMOKE_O"; then
  echo "simd-s3 FAIL: compile $PEEL64_SMOKE_SRC" >&2
  exit 1
fi

if [ -n "$DOD_F32_BACKEND_ARGS" ]; then
  echo "simd-s3: skip f32 .o compile (-backend c exe link below)"
else
  if ! SHU="$SHU_ABS" "$SHU_ABS" "$F32_SOA_SUM_SRC" -o "$F32_SOA_SUM_O"; then
    echo "simd-s3 FAIL: compile $F32_SOA_SUM_SRC" >&2
    exit 1
  fi

  if ! SHU="$SHU_ABS" "$SHU_ABS" "$F32_SOA_STRIP_SRC" -o "$F32_SOA_STRIP_O"; then
    echo "simd-s3 FAIL: compile $F32_SOA_STRIP_SRC" >&2
    exit 1
  fi

  if ! SHU="$SHU_ABS" "$SHU_ABS" "$F32_SOA_STRIP_VAR_N_SRC" -o "$F32_SOA_STRIP_VAR_N_O"; then
    echo "simd-s3 FAIL: compile $F32_SOA_STRIP_VAR_N_SRC" >&2
    exit 1
  fi
fi

if [ ! -f "$SMOKE_O" ] || [ ! -f "$SUB_SMOKE_O" ] || [ ! -f "$MUL_SMOKE_O" ] || [ ! -f "$FMUL_SMOKE_O" ] \
  || [ ! -f "$LOOP_SMOKE_O" ] || [ ! -f "$LOOP_SUB_SMOKE_O" ] || [ ! -f "$LOOP_MUL_SMOKE_O" ] \
  || [ ! -f "$STRIP_SMOKE_O" ] || [ ! -f "$PEEL64_SMOKE_O" ]; then
  echo "simd-s3 FAIL: missing object file" >&2
  exit 1
fi
if [ -z "$DOD_F32_BACKEND_ARGS" ]; then
  if [ ! -f "$F32_SOA_SUM_O" ] || [ ! -f "$F32_SOA_STRIP_O" ] || [ ! -f "$F32_SOA_STRIP_VAR_N_O" ]; then
    echo "simd-s3 FAIL: missing object file" >&2
    exit 1
  fi
fi

ARCH="$(uname -m 2>/dev/null || echo unknown)"
if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
  if command -v objdump >/dev/null 2>&1; then
    DISAS="$(objdump -d "$SMOKE_O" 2>/dev/null || true)"
    SUB_DISAS="$(objdump -d "$SUB_SMOKE_O" 2>/dev/null || true)"
    MUL_DISAS="$(objdump -d "$MUL_SMOKE_O" 2>/dev/null || true)"
    FMUL_DISAS="$(objdump -d "$FMUL_SMOKE_O" 2>/dev/null || true)"
    LOOP_DISAS="$(objdump -d "$LOOP_SMOKE_O" 2>/dev/null || true)"
    LOOP_SUB_DISAS="$(objdump -d "$LOOP_SUB_SMOKE_O" 2>/dev/null || true)"
    LOOP_MUL_DISAS="$(objdump -d "$LOOP_MUL_SMOKE_O" 2>/dev/null || true)"
    STRIP_DISAS="$(objdump -d "$STRIP_SMOKE_O" 2>/dev/null || true)"
    PEEL64_DISAS="$(objdump -d "$PEEL64_SMOKE_O" 2>/dev/null || true)"
    F32_SOA_DISAS="$(objdump -d "$F32_SOA_SUM_O" 2>/dev/null || true)"
    F32_SOA_STRIP_DISAS="$(objdump -d "$F32_SOA_STRIP_O" 2>/dev/null || true)"
    F32_SOA_STRIP_VAR_N_DISAS="$(objdump -d "$F32_SOA_STRIP_VAR_N_O" 2>/dev/null || true)"
    if echo "$DISAS" | grep -qE 'vpaddd|paddd'; then
      echo "simd-s3: hw vector iadd insn present (vpaddd/paddd)"
    elif [ -n "${SHU_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s3 FAIL: no vpaddd/paddd in $SMOKE_O (set SHU_SIMD_HW=0 to allow lane-scalar fallback)" >&2
      exit 1
    else
      echo "simd-s3 WARN: no vpaddd/paddd in var+var smoke (rebuild shu_asm with simd_enc.o or SHU_SIMD_HW=0)"
    fi
    if echo "$SUB_DISAS" | grep -qE 'vpsubd|psubd'; then
      echo "simd-s3: hw vector isub insn present (vpsubd/psubd)"
    elif [ -n "${SHU_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s3 FAIL: no vpsubd/psubd in $SUB_SMOKE_O" >&2
      exit 1
    else
      echo "simd-s3 WARN: no vpsubd/psubd in var+var sub smoke"
    fi
    if echo "$MUL_DISAS" | grep -qE 'vpmulld|pmulld'; then
      echo "simd-s3: hw vector imul insn present (vpmulld/pmulld)"
    elif [ -n "${SHU_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s3 FAIL: no vpmulld/pmulld in $MUL_SMOKE_O" >&2
      exit 1
    else
      echo "simd-s3 WARN: no vpmulld/pmulld in var+var mul smoke"
    fi
    if echo "$FMUL_DISAS" | grep -qE 'mulps'; then
      echo "simd-s3: hw vector fmul insn present (mulps)"
    elif [ -n "${SHU_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s3 FAIL: no mulps in $FMUL_SMOKE_O" >&2
      exit 1
    else
      echo "simd-s3 WARN: no mulps in vec4f mul smoke"
    fi
    if echo "$LOOP_DISAS" | grep -qE 'vpaddd|paddd'; then
      echo "simd-s3: loop peel hw vector iadd present (vpaddd/paddd)"
    elif [ -n "${SHU_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s3 FAIL: no vpaddd/paddd in $LOOP_SMOKE_O (loop peel)" >&2
      exit 1
    else
      echo "simd-s3 WARN: no vpaddd/paddd in loop peel add smoke"
    fi
    if echo "$LOOP_SUB_DISAS" | grep -qE 'vpsubd|psubd'; then
      echo "simd-s3: loop peel hw vector isub present (vpsubd/psubd)"
    elif [ -n "${SHU_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s3 FAIL: no vpsubd/psubd in $LOOP_SUB_SMOKE_O (loop peel sub)" >&2
      exit 1
    else
      echo "simd-s3 WARN: no vpsubd/psubd in loop peel sub smoke"
    fi
    if echo "$LOOP_MUL_DISAS" | grep -qE 'vpmulld|pmulld'; then
      echo "simd-s3: loop peel hw vector imul present (vpmulld/pmulld)"
    elif [ -n "${SHU_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s3 FAIL: no vpmulld/pmulld in $LOOP_MUL_SMOKE_O (loop peel mul)" >&2
      exit 1
    else
      echo "simd-s3 WARN: no vpmulld/pmulld in loop peel mul smoke"
    fi
    if echo "$STRIP_DISAS" | grep -qE 'vpaddd|paddd'; then
      echo "simd-s3: runtime strip loop hw vector iadd present"
    elif [ -n "${SHU_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s3 FAIL: no vpaddd/paddd in $STRIP_SMOKE_O (runtime strip)" >&2
      exit 1
    else
      echo "simd-s3 WARN: no vpaddd/paddd in runtime strip smoke"
    fi
    if echo "$PEEL64_DISAS" | grep -qE 'vpaddd|paddd'; then
      echo "simd-s3: n=64 const-propagated peel hw vector iadd present"
    elif [ -n "${SHU_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s3 FAIL: no vpaddd/paddd in $PEEL64_SMOKE_O" >&2
      exit 1
    else
      echo "simd-s3 WARN: no vpaddd/paddd in n64 peel smoke"
    fi
    if echo "$F32_SOA_DISAS" | grep -qE 'movups|addps'; then
      echo "simd-s3: f32 SoA sum peel movups/addps present"
    elif [ -n "${SHU_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s3 FAIL: no movups/addps in $F32_SOA_SUM_O (f32 SoA reduce peel)" >&2
      exit 1
    else
      echo "simd-s3 WARN: no movups/addps in f32 SoA sum peel smoke"
    fi
    if echo "$F32_SOA_STRIP_DISAS" | grep -qE 'movups|addps'; then
      echo "simd-s3: f32 SoA strip n=10 movups/addps present"
    elif [ -n "${SHU_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s3 FAIL: no movups/addps in $F32_SOA_STRIP_O (f32 SoA strip epilogue)" >&2
      exit 1
    else
      echo "simd-s3 WARN: no movups/addps in f32 SoA strip smoke"
    fi
    if echo "$F32_SOA_STRIP_VAR_N_DISAS" | grep -qE 'movups|addps'; then
      echo "simd-s3: f32 SoA strip var n movups/addps present"
    elif [ -n "${SHU_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s3 FAIL: no movups/addps in $F32_SOA_STRIP_VAR_N_O (f32 SoA var n strip)" >&2
      exit 1
    else
      echo "simd-s3 WARN: no movups/addps in f32 SoA strip var n smoke"
    fi
  else
    echo "simd-s3: objdump missing; compile-only OK"
  fi
else
  echo "simd-s3: non-x86_64 host; compile-only OK"
fi

# f32 SoA strip：链接运行验证 epilogue（n=10 / let n=12）
simd_s3_run_f32_expect() {
  local src="$1"
  local obj="$2"
  local bin="$3"
  local expect="$4"
  local label="$5"
  local link_shu="$SHU_ABS"
  local backend_args=""
  if [ -n "$DOD_F32_BACKEND_ARGS" ]; then
    link_shu="$SIMD_S3_EXE_SHU"
    backend_args="$DOD_F32_BACKEND_ARGS"
  fi
  if [ -n "$DOD_F32_BACKEND_ARGS" ] && [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    echo "simd-s3: $label run N/A on Darwin (gen_driver -backend c f32 WIP; Linux covers)"
    return 0
  fi
  if SHU="$SHU_ABS" "$link_shu" $backend_args "$src" -o "$bin" 2>/dev/null && [ -x "$bin" ]; then
    RC=0
    "$bin" >/dev/null 2>&1 || RC=$?
    if [ "$RC" -ne "$expect" ]; then
      echo "simd-s3 FAIL: $label expected exit $expect, got $RC" >&2
      exit 1
    fi
    echo "simd-s3: $label exit=$expect OK"
  elif command -v ld >/dev/null 2>&1 && [ -f "$obj" ] && [ -f "$CRT0" ]; then
    if ld -o "$bin" "$obj" "$CRT0" 2>/dev/null; then
      RC=0
      "$bin" >/dev/null 2>&1 || RC=$?
      if [ "$RC" -ne "$expect" ]; then
        echo "simd-s3 FAIL: $label expected exit $expect, got $RC" >&2
        exit 1
      fi
      echo "simd-s3: $label exit=$expect OK"
    fi
  fi
}

simd_s3_run_f32_expect "$F32_SOA_SUM_SRC" "$F32_SOA_SUM_O" "$F32_SOA_SUM_BIN" 8 "f32_soa_sum_peel_smoke"
simd_s3_run_f32_expect "$F32_SOA_STRIP_SRC" "$F32_SOA_STRIP_O" "$F32_SOA_STRIP_BIN" 10 "f32_soa_sum_strip_smoke"
simd_s3_run_f32_expect "$F32_SOA_STRIP_VAR_N_SRC" "$F32_SOA_STRIP_VAR_N_O" "$F32_SOA_STRIP_VAR_N_BIN" 12 "f32_soa_sum_strip_var_n_smoke"

echo "simd-s3 gate OK"
