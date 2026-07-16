#!/usr/bin/env bash
# 向量 i32x4/u32x4：0 初始化、数组字面量、逐分量加法
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
# vec_add_verify 引用 shux_string_memcmp_c；purge 后须显式编 std/string/string.o。
make -C compiler -q ../std/string/string.o 2>/dev/null \
  || make -C compiler ../std/string/string.o

# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
SHUX=${SHUX:-./compiler/shux}
LINK_SHUX="${RUN_SHUX:-$SHUX}"
# 产品冷链：优先 SHUX/shux_asm + -backend c；禁止 pin wrap 静默失败
case "$(basename "${SHUX:-}")" in
  shux|shux_asm|shux_asm2|shux_asm_stage1)
    LINK_SHUX="$SHUX"
    ;;
esac
case "$(basename "$LINK_SHUX")" in
  shux-backend-wrap.sh|shux-min-link.sh)
    LINK_SHUX="${SHUX_BACKEND_WRAP_REAL:-${SHUX_MIN_LINK_REAL:-./compiler/shux}}"
    ;;
esac
VEC_BACKEND=""
case "$(basename "$LINK_SHUX")" in
  shux|shux_asm|shux_asm2|shux_asm_stage1)
    if [ -n "${SHUX_FORCE_LINK_BACKEND:-}" ]; then
      VEC_BACKEND="-backend ${SHUX_FORCE_LINK_BACKEND}"
    else
      VEC_BACKEND="-backend c"
    fi
    ;;
esac

vector_link_o() {
  local x="$1" out="$2" label="$3"
  set +e
  $LINK_SHUX $VEC_BACKEND "$x" -o "$out" >"/tmp/shux_vec_${label}_build.log" 2>&1
  local ec=$?
  set -e
  if [ "$ec" -ne 0 ] || [ ! -x "$out" ]; then
    echo "run-vector FAIL: compile $label (via $(basename "$LINK_SHUX") $VEC_BACKEND)" >&2
    tail -12 "/tmp/shux_vec_${label}_build.log" 2>/dev/null >&2 || true
    return 1
  fi
  local exitcode=0
  "$out" >/dev/null 2>&1 || exitcode=$?
  if [ "$exitcode" -ne 0 ]; then
    echo "run-vector FAIL: $label expected exit 0, got $exitcode" >&2
    return 1
  fi
  return 0
}

vector_link_o tests/vector/i32x4.x /tmp/shux_vec_i32x4 i32x4
vector_link_o tests/vector/u32x4_lit.x /tmp/shux_vec_u32 u32x4_lit
vector_link_o tests/vector/vec_add.x /tmp/shux_vec_add vec_add
vector_link_o tests/vector/vec_add_check.x /tmp/shux_vec_add_check vec_add_check
vector_link_o tests/vector/vec_add_lit.x /tmp/shux_vec_add_lit vec_add_lit
vector_link_o tests/vector/vec_copy.x /tmp/shux_vec_copy vec_copy
vector_link_o tests/vector/vec_add_verify.x /tmp/shux_vec_add_verify vec_add_verify
vector_link_o tests/vector/i32x16.x /tmp/shux_vec_i32x16 i32x16

echo "vector test OK"
