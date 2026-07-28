#!/usr/bin/env bash
# 阶段 3 类型检查测试：正例含 typeck OK；负例（边界）须报 typeck error 且退出码非 0
# 当 XLANG 已设置（test_x/run-all-x）时仅用 compiler/xlang（xlang_x），不构建 xlang-c，并跳过依赖「typeck OK」输出的正例。
#
# xlang_x 默认须加 -x 才走 .x 流水线；return_implicit.x 在 .x typeck 与 C 对齐时，对 xlang_x 自动加 -x。
# 若将来 .x typeck 覆盖全部负例，可设 TYPECK_X=all 使所有负例均带 -x（未覆盖前部分用例可能误通过）。

set -e
cd "$(dirname "$0")/.."

XLANG_TYPECK_TIMEOUT="${XLANG_TYPECK_TIMEOUT:-20}"

run_typeck_timeout() {
  local runner=""
  local ec=0
  if command -v timeout >/dev/null 2>&1; then
    runner=timeout
  elif command -v gtimeout >/dev/null 2>&1; then
    runner=gtimeout
  fi
  if [ -n "$runner" ]; then
    "$runner" --signal=TERM --kill-after=5 "$XLANG_TYPECK_TIMEOUT" "$@" || {
      ec=$?
      [ "$ec" -eq 124 ] && echo "typeck timeout after ${XLANG_TYPECK_TIMEOUT}s: $*" >&2
      return "$ec"
    }
    return 0
  fi
  if command -v perl >/dev/null 2>&1; then
    perl -e '
      use strict;
      use warnings;
      my $timeout = shift @ARGV;
      my $pid = fork();
      die "fork failed\n" unless defined $pid;
      if ($pid == 0) {
        exec @ARGV;
        die "exec failed: $!\n";
      }
      local $SIG{ALRM} = sub {
        kill "TERM", $pid;
        select undef, undef, undef, 1.0;
        kill "KILL", $pid;
        waitpid($pid, 0);
        exit 124;
      };
      alarm $timeout;
      waitpid($pid, 0);
      alarm 0;
      my $status = $?;
      if (($status & 127) != 0) {
        exit 128 + ($status & 127);
      }
      exit($status >> 8);
    ' "$XLANG_TYPECK_TIMEOUT" "$@" || {
      ec=$?
      [ "$ec" -eq 124 ] && echo "typeck timeout after ${XLANG_TYPECK_TIMEOUT}s: $*" >&2
      return "$ec"
    }
    return 0
  fi
  "$@"
}

expect_typeck_error() {
  local file="$1" msg="$2"
  local xlang="${3:-./compiler/xlang}"
  local use_x=0
  if [ "${TYPECK_X:-}" = "all" ]; then
    use_x=1
  elif [ "${xlang##*/}" = "xlang_x" ] && [ "$file" = "tests/typeck/return_implicit.x" ]; then
    use_x=1
  fi
  local err
  # NOTE: `build` path emits "typeck error[XT001]: ..." prefix; `check` path emits
  # "error[XT001]" without the "typeck" prefix. Use `build -o /tmp/...` so the
  # grep "typeck error" matches consistently across xlang / xlang-c / xlang_asm.
  err=$(run_typeck_timeout "$xlang" build "$file" -o /tmp/xlang_typeck_neg_$(basename "$file" .x).o 2>&1) || true
  echo "$err" | grep -q "typeck error" || { echo "expected typeck error in $file (e.g. $msg), got: $err"; exit 1; }
}

expect_return_breadcrumb_error() {
  local file="$1"
  local xlang="${2:-./compiler/xlang-x}"
  local err
  # 产品 -o/默认编译路径稳定出 typeck 诊断；`check` 对 import 模块曾假绿（exit 0 无输出）。
  err=$(run_typeck_timeout "$xlang" build -L . "$file" -o /tmp/xlang_typeck_breadcrumb_fail 2>&1) || true
  if ! echo "$err" | grep -q "typeck error"; then
    err=$(run_typeck_timeout "$xlang" build -L . "$file" -o /tmp/xlang_typeck_breadcrumb_fail 2>&1) || true
  fi
  # 允许 result.Result_i32 或短名 Result_i32（qualified type 诊断为正确形态）
  echo "$err" | grep -qE "return expression type mismatch: expected i32, found (result\.)?Result_i32" || {
    echo "expected return mismatch breadcrumb base error in $file; got: $err"
    exit 1
  }
  if echo "$err" | grep -q "return subexpression:"; then
    echo "$err" | grep -q "return subexpression: result.ok_i32()" || {
      echo "expected return subexpression breadcrumb in $file; got: $err"
      exit 1
    }
  fi
}
if [ -n "$XLANG" ]; then
  TYPECK_XLANG="$XLANG"
  # X 宿主（xlang_x / xlang-x）：赋值 for-step 负例须在本地 -x 流水线上报与 xlang-c 同源的行（grep 短语）；其余负例走 .x typeck（与 xlang-c 对齐，不再回退 C 前端）。
  case "${XLANG##*/}" in
    xlang_asm*)
      # xlang_asm strict 链 typecheck 桩与 seed xlang 不一致；X 负例与 assign 短语仍用 seed 链验收。
      # run-all-bstrict 会把 xlang_asm 拷到 ./compiler/xlang，勿用 xlang 作负例（空输出）。
      if [ -x ./compiler/xlang-x ]; then
        TYPECK_NEG_XLANG=./compiler/xlang-x
      elif [ -x ./compiler/xlang-c ]; then
        TYPECK_NEG_XLANG=./compiler/xlang-c
      else
        TYPECK_NEG_XLANG=./compiler/xlang
      fi
      if [ ! -x "$TYPECK_NEG_XLANG" ]; then
        TYPECK_NEG_XLANG="$XLANG"
      fi
      err_assign_x=$(run_typeck_timeout "$TYPECK_NEG_XLANG" build tests/typeck/type_mismatch_assign.x -o /tmp/xlang_typeck_assign_fail.o 2>&1) || true
      echo "$err_assign_x" | grep -q "assignment type mismatch: expected i32, found bool" || {
        echo "expected X 'assignment type mismatch: expected i32, found bool' in type_mismatch_assign.x; got: $err_assign_x"
        exit 1
      }
      err_ret_x=$(run_typeck_timeout "$TYPECK_NEG_XLANG" build tests/typeck/return_operand_type_mismatch.x -o /tmp/xlang_typeck_ret_fail.o 2>&1) || true
      echo "$err_ret_x" | grep -q "typeck error" || {
        echo "expected $TYPECK_NEG_XLANG build pipeline typeck error on return_operand_type_mismatch.x (bool vs i32 return); got: $err_ret_x"
        exit 1
      }
      # strict 链负例仍借 seed 宿主拿稳定报错短语；正例直接验当前 XLANG，
      # 否则会被旧宿主 parser/typeck 能力上限掩盖掉 strict 链已修复的真实进度。
      TYPECK_XLANG="$XLANG"
      ;;
    xlang|xlang-x|xlang_x)
      # seed -o 在非 x86_64 常无 typeck stderr；负例与 expect_typeck 回退 xlang-c（与 run-hello/run-io 一致）。
      TYPECK_NEG_XLANG="$XLANG"
      case "$(uname -m 2>/dev/null)" in
        x86_64|amd64) ;;
        *)
          if [ -x ./compiler/xlang-c ]; then
            TYPECK_NEG_XLANG=./compiler/xlang-c
          fi
          ;;
      esac
      err_assign_x=$(run_typeck_timeout "$TYPECK_NEG_XLANG" build tests/typeck/type_mismatch_assign.x -o /tmp/xlang_typeck_assign_fail.o 2>&1) || true
      echo "$err_assign_x" | grep -q "assignment type mismatch: expected i32, found bool" || {
        echo "expected typeck 'assignment type mismatch: expected i32, found bool' in type_mismatch_assign.x; got: $err_assign_x"
        exit 1
      }
      err_ret_x=$(run_typeck_timeout "$TYPECK_NEG_XLANG" build tests/typeck/return_operand_type_mismatch.x -o /tmp/xlang_typeck_ret_fail.o 2>&1) || true
      echo "$err_ret_x" | grep -q "typeck error" || {
        echo "expected $TYPECK_NEG_XLANG build pipeline typeck error on return_operand_type_mismatch.x (bool vs i32 return); got: $err_ret_x"
        exit 1
      }
      TYPECK_XLANG="$TYPECK_NEG_XLANG"
      ;;
  esac
  expect_typeck_error tests/typeck/type_mismatch_assign.x "assignment type mismatch" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/if_condition_not_bool.x "if condition must be bool" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/undefined_name.x "undefined name" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/return_implicit.x "explicit return statement" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/ternary_condition_not_bool.x "ternary condition must be bool" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/ternary_branches_mismatch.x "ternary branches must have the same type" "$TYPECK_XLANG"
  # wave312 product: u64↔usize integer widen is intentional (LP64 same-width store).
  # Former negatives u64_to_usize_needs_as*.x are now positive (see for-loop below).
  expect_typeck_error tests/typeck/struct_repr_compatible_fail.x "no matching overload" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/result_try_bad.x "enclosing function to return the same Result type" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/import_const_bare_fail.x "must be qualified" "$TYPECK_XLANG"
  for f in tests/typeck/contextual_typing_p0.x tests/typeck/contextual_typing_p1.x tests/typeck/postfix_call_index.x tests/typeck/postfix_array_slice_type.x tests/typeck/ptr_arith_i32.x tests/typeck/ternary_u8_context.x tests/typeck/struct_field_shorthand.x tests/typeck/match_guard.x tests/typeck/match_struct_destructure.x tests/typeck/range_for.x tests/typeck/result_try.x tests/typeck/result_try_catch.x tests/typeck/return_struct_field_shorthand.x tests/typeck/struct_repr_compatible.x tests/typeck/type_alias.x tests/typeck/import_const_qualified_ok.x tests/typeck/u64_to_usize_needs_as.x tests/typeck/u64_to_usize_needs_as_lit_lhs.x; do
    # 60811830: default mode 走 compile+run（不再输出 typeck OK）；
    # typeck 正例改用 -E（烟测路径，typeck only），关注分离：-E 测 typeck / run 运行程序。
    # 注意：_main undefined（parser struct-lit + unsafe-block 组合 bug，P1 待办）不阻塞 -E 路径。
    out_pos=$(run_typeck_timeout "$TYPECK_XLANG" build -E "$f" 2>&1) || true
    echo "$out_pos" | grep -q "typeck OK" || { echo "missing typeck OK for $f: $out_pos"; exit 1; }
  done
else
  if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
    make -C compiler -q 2>/dev/null || make -C compiler
    make -C compiler xlang-c 2>/dev/null || true
  fi
  if [ -f ./compiler/xlang-c ]; then
    TYPECK_XLANG=./compiler/xlang-c
  else
    TYPECK_XLANG=./compiler/xlang
  fi
  # 60811830: default mode 走 compile+run；typeck 正例用 -E（typeck only）。
  out=$(run_typeck_timeout "$TYPECK_XLANG" build -E tests/lexer/main.x 2>&1)
  echo "$out" | grep -q "typeck OK" || { echo "missing 'typeck OK' in output"; exit 1; }
  expect_typeck_error tests/typeck/type_mismatch_assign.x "assignment type mismatch" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/if_condition_not_bool.x "if condition must be bool" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/undefined_name.x "undefined name" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/return_implicit.x "explicit return statement" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/ternary_condition_not_bool.x "ternary condition must be bool" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/ternary_branches_mismatch.x "ternary branches must have the same type" "$TYPECK_XLANG"
  # wave312 product: u64↔usize integer widen is intentional (see positive list below).
  expect_typeck_error tests/typeck/struct_repr_compatible_fail.x "no matching overload" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/result_try_bad.x "enclosing function to return the same Result type" "$TYPECK_XLANG"
  expect_typeck_error tests/typeck/import_const_bare_fail.x "must be qualified" "$TYPECK_XLANG"
  # 负例宿主：优先当前 TYPECK_XLANG/产品链；避免 pin xlang-x 空诊断
  _ret_host="${TYPECK_XLANG:-${XLANG:-./compiler/xlang}}"
  if [ -x "$_ret_host" ]; then
    err_ret_x=$(run_typeck_timeout "$_ret_host" build tests/typeck/return_operand_type_mismatch.x -o /tmp/xlang_typeck_ret_fail_defaults.o 2>&1) || true
    echo "$err_ret_x" | grep -q "typeck error" || {
      echo "expected $_ret_host return_operand_type_mismatch typeck error; got: $err_ret_x"
      exit 1
    }
  fi
  for f in tests/typeck/contextual_typing_p0.x tests/typeck/contextual_typing_p1.x tests/typeck/postfix_call_index.x tests/typeck/postfix_array_slice_type.x tests/typeck/ptr_arith_i32.x tests/typeck/ternary_u8_context.x tests/typeck/struct_field_shorthand.x tests/typeck/match_guard.x tests/typeck/match_struct_destructure.x tests/typeck/range_for.x tests/typeck/result_try.x tests/typeck/result_try_catch.x tests/typeck/return_struct_field_shorthand.x tests/typeck/struct_repr_compatible.x tests/typeck/type_alias.x tests/typeck/import_const_qualified_ok.x tests/typeck/u64_to_usize_needs_as.x tests/typeck/u64_to_usize_needs_as_lit_lhs.x; do
    # 60811830: default mode 走 compile+run（不再输出 typeck OK）；
    # typeck 正例改用 -E（烟测路径，typeck only），关注分离：-E 测 typeck / run 运行程序。
    # 注意：_main undefined（parser struct-lit + unsafe-block 组合 bug，P1 待办）不阻塞 -E 路径。
    out_pos=$(run_typeck_timeout "$TYPECK_XLANG" build -E "$f" 2>&1) || true
    echo "$out_pos" | grep -q "typeck OK" || { echo "missing typeck OK for $f: $out_pos"; exit 1; }
  done
fi
# breadcrumb 负例：优先产品 XLANG/xlang_asm（真 typeck 诊断）。
# 旧逻辑硬绑 pin xlang-x：冷启动后 xlang-x 常为 seed 拷贝，空 stderr → 假红/空 got。
_bc_host=""
if [ -n "${XLANG:-}" ] && [ -x "$XLANG" ]; then
  _bc_host="$XLANG"
elif [ -x ./compiler/xlang_asm ]; then
  _bc_host=./compiler/xlang_asm
elif [ -x ./compiler/xlang ]; then
  _bc_host=./compiler/xlang
elif [ -x ./compiler/xlang-x ]; then
  _bc_host=./compiler/xlang-x
fi
if [ -n "$_bc_host" ]; then
  expect_return_breadcrumb_error tests/typeck/return_import_call_type_mismatch.x "$_bc_host"
fi
echo "typeck test OK"
