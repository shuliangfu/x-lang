#!/usr/bin/env bash
# 阶段 3 类型检查测试：正例含 typeck OK；负例（边界）须报 typeck error 且退出码非 0
# 当 SHU 已设置（test_x/run-all-x）时仅用 compiler/shux（shux_x），不构建 shux-c，并跳过依赖「typeck OK」输出的正例。
#
# shux_x 默认须加 -x 才走 .x 流水线；return_implicit.x 在 .x typeck 与 C 对齐时，对 shux_x 自动加 -x。
# 若将来 .x typeck 覆盖全部负例，可设 TYPECK_X=all 使所有负例均带 -x（未覆盖前部分用例可能误通过）。

set -e
cd "$(dirname "$0")/.."

SHUX_TYPECK_TIMEOUT="${SHUX_TYPECK_TIMEOUT:-20}"

run_typeck_timeout() {
  local runner=""
  local ec=0
  if command -v timeout >/dev/null 2>&1; then
    runner=timeout
  elif command -v gtimeout >/dev/null 2>&1; then
    runner=gtimeout
  fi
  if [ -n "$runner" ]; then
    "$runner" --signal=TERM --kill-after=5 "$SHUX_TYPECK_TIMEOUT" "$@" || {
      ec=$?
      [ "$ec" -eq 124 ] && echo "typeck timeout after ${SHUX_TYPECK_TIMEOUT}s: $*" >&2
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
    ' "$SHUX_TYPECK_TIMEOUT" "$@" || {
      ec=$?
      [ "$ec" -eq 124 ] && echo "typeck timeout after ${SHUX_TYPECK_TIMEOUT}s: $*" >&2
      return "$ec"
    }
    return 0
  fi
  "$@"
}

expect_typeck_error() {
  local file="$1" msg="$2"
  local shux="${3:-./compiler/shux}"
  local use_x=0
  if [ "${TYPECK_X:-}" = "all" ]; then
    use_x=1
  elif [ "${shux##*/}" = "shux_x" ] && [ "$file" = "tests/typeck/return_implicit.x" ]; then
    use_x=1
  fi
  local err
  if [ "$use_x" = 1 ]; then
    err=$(run_typeck_timeout "$shux" -x "$file" 2>&1) || true
  else
    err=$(run_typeck_timeout "$shux" "$file" 2>&1) || true
  fi
  echo "$err" | grep -q "typeck error" || { echo "expected typeck error in $file (e.g. $msg), got: $err"; exit 1; }
}

expect_return_breadcrumb_error() {
  local file="$1"
  local shux="${2:-./compiler/shux-x}"
  local err
  if "$shux" --help 2>/dev/null | grep -q 'check \[paths\.\.\.\]'; then
    err=$(run_typeck_timeout "$shux" check -L . "$file" 2>&1) || true
  else
    err=$(run_typeck_timeout "$shux" -x -L . "$file" -o /tmp/shux_typeck_breadcrumb_fail 2>&1) || true
  fi
  echo "$err" | grep -q "return expression type mismatch: expected i32, found Result_i32" || {
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
if [ -n "$SHUX" ]; then
  TYPECK_SHUX="$SHUX"
  # X 宿主（shux_x / shux-x）：赋值 for-step 负例须在本地 -x 流水线上报与 shux-c 同源的行（grep 短语）；其余负例走 .x typeck（与 shux-c 对齐，不再回退 C 前端）。
  case "${SHUX##*/}" in
    shux_asm*)
      # shux_asm strict 链 typecheck 桩与 seed shux 不一致；X 负例与 assign 短语仍用 seed 链验收。
      # run-all-bstrict 会把 shux_asm 拷到 ./compiler/shux，勿用 shux 作负例（空输出）。
      if [ -x ./compiler/shux-x ]; then
        TYPECK_NEG_SHUX=./compiler/shux-x
      elif [ -x ./compiler/shux-c ]; then
        TYPECK_NEG_SHUX=./compiler/shux-c
      else
        TYPECK_NEG_SHUX=./compiler/shux
      fi
      if [ ! -x "$TYPECK_NEG_SHUX" ]; then
        TYPECK_NEG_SHUX="$SHUX"
      fi
      err_assign_x=$(run_typeck_timeout "$TYPECK_NEG_SHUX" tests/typeck/type_mismatch_assign.x -o /tmp/shux_typeck_assign_fail.o 2>&1) || true
      echo "$err_assign_x" | grep -q "assignment type mismatch: expected i32, found bool" || {
        echo "expected X 'assignment type mismatch: expected i32, found bool' in type_mismatch_assign.x; got: $err_assign_x"
        exit 1
      }
      err_ret_x=$(run_typeck_timeout "$TYPECK_NEG_SHUX" tests/typeck/return_operand_type_mismatch.x -o /tmp/shux_typeck_ret_fail.o 2>&1) || true
      echo "$err_ret_x" | grep -q "typeck error" || {
        echo "expected $TYPECK_NEG_SHUX pipeline typeck error on return_operand_type_mismatch.x (bool vs i32 return); got: $err_ret_x"
        exit 1
      }
      # strict 链负例仍借 seed 宿主拿稳定报错短语；正例直接验当前 SHUX，
      # 否则会被旧宿主 parser/typeck 能力上限掩盖掉 strict 链已修复的真实进度。
      TYPECK_SHUX="$SHUX"
      ;;
    shux|shux-x|shux_x)
      # seed -o 在非 x86_64 常无 typeck stderr；负例与 expect_typeck 回退 shux-c（与 run-hello/run-io 一致）。
      TYPECK_NEG_SHUX="$SHUX"
      case "$(uname -m 2>/dev/null)" in
        x86_64|amd64) ;;
        *)
          if [ -x ./compiler/shux-c ]; then
            TYPECK_NEG_SHUX=./compiler/shux-c
          fi
          ;;
      esac
      err_assign_x=$(run_typeck_timeout "$TYPECK_NEG_SHUX" tests/typeck/type_mismatch_assign.x -o /tmp/shux_typeck_assign_fail.o 2>&1) || true
      echo "$err_assign_x" | grep -q "assignment type mismatch: expected i32, found bool" || {
        echo "expected typeck 'assignment type mismatch: expected i32, found bool' in type_mismatch_assign.x; got: $err_assign_x"
        exit 1
      }
      err_ret_x=$(run_typeck_timeout "$TYPECK_NEG_SHUX" tests/typeck/return_operand_type_mismatch.x -o /tmp/shux_typeck_ret_fail.o 2>&1) || true
      echo "$err_ret_x" | grep -q "typeck error" || {
        echo "expected $TYPECK_NEG_SHUX pipeline typeck error on return_operand_type_mismatch.x (bool vs i32 return); got: $err_ret_x"
        exit 1
      }
      TYPECK_SHUX="$TYPECK_NEG_SHUX"
      ;;
  esac
  expect_typeck_error tests/typeck/type_mismatch_assign.x "assignment type mismatch" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/if_condition_not_bool.x "if condition must be bool" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/undefined_name.x "undefined name" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/return_implicit.x "explicit return statement" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/ternary_condition_not_bool.x "ternary condition must be bool" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/ternary_branches_mismatch.x "ternary branches must have the same type" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/u64_to_usize_needs_as.x "expected usize, found u64" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/u64_to_usize_needs_as_lit_lhs.x "expected usize, found u64" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/struct_repr_compatible_fail.x "no matching overload" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/result_try_bad.x "enclosing function to return the same Result type" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/import_const_bare_fail.x "must be qualified" "$TYPECK_SHUX"
  for f in tests/typeck/contextual_typing_p0.x tests/typeck/contextual_typing_p1.x tests/typeck/postfix_call_index.x tests/typeck/postfix_array_slice_type.x tests/typeck/ptr_arith_i32.x tests/typeck/ternary_u8_context.x tests/typeck/struct_field_shorthand.x tests/typeck/match_guard.x tests/typeck/match_struct_destructure.x tests/typeck/range_for.x tests/typeck/result_try.x tests/typeck/result_try_catch.x tests/typeck/return_struct_field_shorthand.x tests/typeck/struct_repr_compatible.x tests/typeck/type_alias.x tests/typeck/import_const_qualified_ok.x; do
    out_pos=$(run_typeck_timeout "$TYPECK_SHUX" "$f" 2>&1) || true
    echo "$out_pos" | grep -q "typeck OK" || { echo "missing typeck OK for $f: $out_pos"; exit 1; }
  done
else
  if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
    make -C compiler -q 2>/dev/null || make -C compiler
    make -C compiler shux-c 2>/dev/null || true
  fi
  if [ -f ./compiler/shux-c ]; then
    TYPECK_SHUX=./compiler/shux-c
  else
    TYPECK_SHUX=./compiler/shux
  fi
  out=$(run_typeck_timeout "$TYPECK_SHUX" tests/lexer/main.x 2>&1)
  echo "$out" | grep -q "typeck OK" || { echo "missing 'typeck OK' in output"; exit 1; }
  expect_typeck_error tests/typeck/type_mismatch_assign.x "assignment type mismatch" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/if_condition_not_bool.x "if condition must be bool" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/undefined_name.x "undefined name" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/return_implicit.x "explicit return statement" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/ternary_condition_not_bool.x "ternary condition must be bool" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/ternary_branches_mismatch.x "ternary branches must have the same type" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/u64_to_usize_needs_as.x "expected usize, found u64" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/u64_to_usize_needs_as_lit_lhs.x "expected usize, found u64" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/struct_repr_compatible_fail.x "no matching overload" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/result_try_bad.x "enclosing function to return the same Result type" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/import_const_bare_fail.x "must be qualified" "$TYPECK_SHUX"
  if [ -x ./compiler/shux-x ]; then
    err_ret_x=$(run_typeck_timeout ./compiler/shux-x -x tests/typeck/return_operand_type_mismatch.x -o /tmp/shux_typeck_ret_fail_defaults.o 2>&1) || true
    echo "$err_ret_x" | grep -q "typeck error" || {
      echo "expected ./compiler/shux-x -x return_operand_type_mismatch typeck error; got: $err_ret_x"
      exit 1
    }
  fi
  for f in tests/typeck/contextual_typing_p0.x tests/typeck/contextual_typing_p1.x tests/typeck/postfix_call_index.x tests/typeck/postfix_array_slice_type.x tests/typeck/ptr_arith_i32.x tests/typeck/ternary_u8_context.x tests/typeck/struct_field_shorthand.x tests/typeck/match_guard.x tests/typeck/match_struct_destructure.x tests/typeck/range_for.x tests/typeck/result_try.x tests/typeck/result_try_catch.x tests/typeck/return_struct_field_shorthand.x tests/typeck/struct_repr_compatible.x tests/typeck/type_alias.x tests/typeck/import_const_qualified_ok.x; do
    out_pos=$(run_typeck_timeout "$TYPECK_SHUX" "$f" 2>&1) || true
    echo "$out_pos" | grep -q "typeck OK" || { echo "missing typeck OK for $f: $out_pos"; exit 1; }
  done
fi
if [ -x ./compiler/shux-x ]; then
  expect_return_breadcrumb_error tests/typeck/return_import_call_type_mismatch.x ./compiler/shux-x
fi
echo "typeck test OK"
