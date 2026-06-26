#!/usr/bin/env bash
# 结构体：定义、字面量、字段访问、allow(padding)；负例：未 allow 的隐式 padding 报错
set -e
cd "$(dirname "$0")/.."
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
fi
SHUX=${SHUX:-./compiler/shux}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
LINK_SHUX="$RUN_SHUX"
STRUCT_LINK_BACKEND_ARGS="${SHUX_LINK_BACKEND_ARGS:--backend asm}"

# struct -o：bstrict 强制 SHUX_LINK_SHUX=shux-c 时 shux-c 对 simple.sx 易 SIGSEGV；
# W3/lang-unsafe 已验证 shux_asm2 可绿（与 lang-unsafe-gate SHUX_BIN 策略一致）。
# bootstrap-min：保留 RUN_SHUX（shux-min-link gcc 回退），勿覆盖为裸 shux_asm。
if [ -z "${SHUX_BOOTSTRAP_MIN:-}" ]; then
  if [ -x ./compiler/shux_asm2 ] && ci_native_shu ./compiler/shux_asm2; then
    LINK_SHUX=./compiler/shux_asm2
    STRUCT_LINK_BACKEND_ARGS=""
  elif [ -x ./compiler/shux_asm ] && ci_native_shu ./compiler/shux_asm; then
    LINK_SHUX=./compiler/shux_asm
    STRUCT_LINK_BACKEND_ARGS=""
  fi
fi

# 封装 -o 链接：shux_asm2 失败时回退 shux-c（无 asm 时）。
struct_link_o() {
  local sx="$1" out="$2"
  set +e
  $LINK_SHUX $STRUCT_LINK_BACKEND_ARGS -L . "$sx" -o "$out" 2>&1
  local ec=$?
  set -e
  if [ "$ec" -ne 0 ] && [ -z "${SHUX_BOOTSTRAP_MIN:-}" ] \
      && [ "$LINK_SHUX" != "./compiler/shux-c" ] \
      && [ -x ./compiler/shux-c ] && ci_native_shu ./compiler/shux-c; then
    ./compiler/shux-c -L . "$sx" -o "$out" 2>&1
    ec=$?
  fi
  return "$ec"
}

struct_link_o tests/struct/simple.sx /tmp/shux_struct_simple
exitcode=0; /tmp/shux_struct_simple >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "expected 1 (struct simple p.x), got $exitcode"; exit 1; }

struct_link_o tests/struct/padding_allow.sx /tmp/shux_struct_pad
exitcode=0; /tmp/shux_struct_pad >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 2 ] && { echo "expected 2 (padding_allow x.b), got $exitcode"; exit 1; }

if ${TYPECK_SHUX:-$SHUX} check tests/struct/padding_no_allow.sx 2>&1 | grep -q "implicit padding"; then
  : # 预期 typeck 报错
else
  echo "expected typeck error for struct without allow(padding)"
  exit 1
fi

# packed 结构体（memory-contract）：无隐式 padding
struct_link_o tests/memory-contract/packed_struct.sx /tmp/shux_struct_packed
exitcode=0; /tmp/shux_struct_packed >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected 0 (packed struct), got $exitcode"; exit 1; }

# add_pair 字段求和 CALL 内联（可变 struct 字段，return 12）
struct_link_o tests/boundary/struct_add_pair_inline.sx /tmp/shux_struct_add_pair_inline
exitcode=0; /tmp/shux_struct_add_pair_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 12 ] && { echo "expected 12 (struct_add_pair_inline), got $exitcode"; exit 1; }

# get_a 单字段 CALL 内联（可变 struct 字段，return 0+1+2+3+4=10）
struct_link_o tests/boundary/struct_get_field_inline.sx /tmp/shux_struct_get_field_inline
exitcode=0; /tmp/shux_struct_get_field_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 10 ] && { echo "expected 10 (struct_get_field_inline), got $exitcode"; exit 1; }

# get_a(mk(i,2)) 嵌套内联（struct 按值返回 + 单字段，return 10）
struct_link_o tests/boundary/struct_mk_field_inline.sx /tmp/shux_struct_mk_field_inline
exitcode=0; /tmp/shux_struct_mk_field_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 10 ] && { echo "expected 10 (struct_mk_field_inline), got $exitcode"; exit 1; }

# add_pair(mk(i,2)) 嵌套内联（struct 按值返回 + 字段求和，return 20）
struct_link_o tests/boundary/struct_mk_pair_sum_inline.sx /tmp/shux_struct_mk_pair_sum_inline
exitcode=0; /tmp/shux_struct_mk_pair_sum_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 20 ] && { echo "expected 20 (struct_mk_pair_sum_inline), got $exitcode"; exit 1; }

# let p = mk(...) 独立内联 + 字段读（return 1+2+3+4=10）
struct_link_o tests/boundary/struct_mk_let_inline.sx /tmp/shux_struct_mk_let_inline
exitcode=0; /tmp/shux_struct_mk_let_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 10 ] && { echo "expected 10 (struct_mk_let_inline), got $exitcode"; exit 1; }

# while 体内 let p = mk(...); 累加字段（return 0+2 + 1+3 + 2+4 = 9）
struct_link_o tests/boundary/struct_mk_while_let_inline.sx /tmp/shux_struct_mk_while_let_inline
exitcode=0; /tmp/shux_struct_mk_while_let_inline >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 9 ] && { echo "expected 9 (struct_mk_while_let_inline), got $exitcode"; exit 1; }

# while 体内 if-then 嵌套 let + 赋值（return 10）
struct_link_o tests/boundary/while_if_nested_let.sx /tmp/shux_while_if_nested_let
exitcode=0; /tmp/shux_while_if_nested_let >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 10 ] && { echo "expected 10 (while_if_nested_let), got $exitcode"; exit 1; }

echo "struct test OK"
