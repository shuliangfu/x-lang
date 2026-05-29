#!/usr/bin/env bash
# 阶段 3 类型检查测试：正例含 typeck OK；负例（边界）须报 typeck error 且退出码非 0
# 当 SHU 已设置（test_su/run-all-su）时仅用 compiler/shu（shu_su），不构建 shu-c，并跳过依赖「typeck OK」输出的正例。
#
# shu_su 默认须加 -su 才走 .su 流水线；return_implicit.su 在 .su typeck 与 C 对齐时，对 shu_su 自动加 -su。
# 若将来 .su typeck 覆盖全部负例，可设 TYPECK_SU=all 使所有负例均带 -su（未覆盖前部分用例可能误通过）。

set -e
cd "$(dirname "$0")/.."
expect_typeck_error() {
  local file="$1" msg="$2"
  local shu="${3:-./compiler/shu}"
  local use_su=0
  if [ "${TYPECK_SU:-}" = "all" ]; then
    use_su=1
  elif [ "${shu##*/}" = "shu_su" ] && [ "$file" = "tests/typeck/return_implicit.su" ]; then
    use_su=1
  fi
  local err
  if [ "$use_su" = 1 ]; then
    err=$("$shu" -su "$file" -o /tmp/shu_typeck_fail 2>&1) || true
  else
    err=$("$shu" "$file" -o /tmp/shu_typeck_fail 2>&1) || true
  fi
  echo "$err" | grep -q "typeck error" || { echo "expected typeck error in $file (e.g. $msg), got: $err"; exit 1; }
}
if [ -n "$SHU" ]; then
  TYPECK_SHU="$SHU"
  # SU 宿主（shu_su / shu-su）：赋值 for-step 负例须在本地 -su 流水线上报与 shu-c 同源的行（grep 短语）；其余负例走 .su typeck（与 shu-c 对齐，不再回退 C 前端）。
  case "${SHU##*/}" in
    shu_asm)
      # shu_asm strict 链 typecheck 桩与 seed shu 不一致；SU 负例与 assign 短语仍用 seed 链验收。
      # run-all-bstrict 会把 shu_asm 拷到 ./compiler/shu，勿用 shu 作负例（空输出）。
      if [ -x ./compiler/shu-su ]; then
        TYPECK_NEG_SHU=./compiler/shu-su
      elif [ -x ./compiler/shu-c ]; then
        TYPECK_NEG_SHU=./compiler/shu-c
      else
        TYPECK_NEG_SHU=./compiler/shu
      fi
      if [ ! -x "$TYPECK_NEG_SHU" ]; then
        TYPECK_NEG_SHU="$SHU"
      fi
      err_assign_su=$("$TYPECK_NEG_SHU" tests/typeck/type_mismatch_assign.su -o /tmp/shu_typeck_assign_fail.o 2>&1) || true
      echo "$err_assign_su" | grep -q "assignment type mismatch: expected i32, found bool" || {
        echo "expected SU 'assignment type mismatch: expected i32, found bool' in type_mismatch_assign.su; got: $err_assign_su"
        exit 1
      }
      err_ret_su=$("$TYPECK_NEG_SHU" tests/typeck/return_operand_type_mismatch.su -o /tmp/shu_typeck_ret_fail.o 2>&1) || true
      echo "$err_ret_su" | grep -q "typeck error" || {
        echo "expected $TYPECK_NEG_SHU pipeline typeck error on return_operand_type_mismatch.su (bool vs i32 return); got: $err_ret_su"
        exit 1
      }
      ;;
    shu|shu-su|shu_su)
      err_assign_su=$("$SHU" tests/typeck/type_mismatch_assign.su -o /tmp/shu_typeck_assign_fail.o 2>&1) || true
      echo "$err_assign_su" | grep -q "assignment type mismatch: expected i32, found bool" || {
        echo "expected SU 'assignment type mismatch: expected i32, found bool' in type_mismatch_assign.su; got: $err_assign_su"
        exit 1
      }
      err_ret_su=$("$SHU" tests/typeck/return_operand_type_mismatch.su -o /tmp/shu_typeck_ret_fail.o 2>&1) || true
      echo "$err_ret_su" | grep -q "typeck error" || {
        echo "expected $SHU pipeline typeck error on return_operand_type_mismatch.su (bool vs i32 return); got: $err_ret_su"
        exit 1
      }
      ;;
  esac
  expect_typeck_error tests/typeck/type_mismatch_assign.su "assignment type mismatch" "$TYPECK_SHU"
  expect_typeck_error tests/typeck/if_condition_not_bool.su "if condition must be bool" "$TYPECK_SHU"
  expect_typeck_error tests/typeck/undefined_name.su "undefined name" "$TYPECK_SHU"
  expect_typeck_error tests/typeck/return_implicit.su "explicit return statement" "$TYPECK_SHU"
  expect_typeck_error tests/typeck/ternary_condition_not_bool.su "ternary condition must be bool" "$TYPECK_SHU"
  expect_typeck_error tests/typeck/ternary_branches_mismatch.su "ternary branches must have the same type" "$TYPECK_SHU"
else
  make -C compiler -q 2>/dev/null || make -C compiler
  make -C compiler shu-c 2>/dev/null || true
  if [ -f ./compiler/shu-c ]; then
    TYPECK_SHU=./compiler/shu-c
  else
    TYPECK_SHU=./compiler/shu
  fi
  out=$("$TYPECK_SHU" tests/lexer/main.su 2>&1)
  echo "$out" | grep -q "typeck OK" || { echo "missing 'typeck OK' in output"; exit 1; }
  expect_typeck_error tests/typeck/type_mismatch_assign.su "assignment type mismatch" "$TYPECK_SHU"
  expect_typeck_error tests/typeck/if_condition_not_bool.su "if condition must be bool" "$TYPECK_SHU"
  expect_typeck_error tests/typeck/undefined_name.su "undefined name" "$TYPECK_SHU"
  expect_typeck_error tests/typeck/return_implicit.su "explicit return statement" "$TYPECK_SHU"
  expect_typeck_error tests/typeck/ternary_condition_not_bool.su "ternary condition must be bool" "$TYPECK_SHU"
  expect_typeck_error tests/typeck/ternary_branches_mismatch.su "ternary branches must have the same type" "$TYPECK_SHU"
  if [ -x ./compiler/shu-su ]; then
    err_ret_su=$(./compiler/shu-su -su tests/typeck/return_operand_type_mismatch.su -o /tmp/shu_typeck_ret_fail_defaults.o 2>&1) || true
    echo "$err_ret_su" | grep -q "typeck error" || {
      echo "expected ./compiler/shu-su -su return_operand_type_mismatch typeck error; got: $err_ret_su"
      exit 1
    }
  fi
fi
echo "typeck test OK"
