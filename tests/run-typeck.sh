#!/usr/bin/env bash
# 阶段 3 类型检查测试：正例含 typeck OK；负例（边界）须报 typeck error 且退出码非 0
# 当 SHU 已设置（test_sx/run-all-sx）时仅用 compiler/shux（shux_sx），不构建 shux-c，并跳过依赖「typeck OK」输出的正例。
#
# shux_sx 默认须加 -sx 才走 .sx 流水线；return_implicit.sx 在 .sx typeck 与 C 对齐时，对 shux_sx 自动加 -sx。
# 若将来 .sx typeck 覆盖全部负例，可设 TYPECK_SX=all 使所有负例均带 -sx（未覆盖前部分用例可能误通过）。

set -e
cd "$(dirname "$0")/.."
expect_typeck_error() {
  local file="$1" msg="$2"
  local shux="${3:-./compiler/shux}"
  local use_sx=0
  if [ "${TYPECK_SX:-}" = "all" ]; then
    use_sx=1
  elif [ "${shux##*/}" = "shux_sx" ] && [ "$file" = "tests/typeck/return_implicit.sx" ]; then
    use_sx=1
  fi
  local err
  if [ "$use_sx" = 1 ]; then
    err=$("$shux" -sx "$file" -o /tmp/shux_typeck_fail 2>&1) || true
  else
    err=$("$shux" "$file" -o /tmp/shux_typeck_fail 2>&1) || true
  fi
  echo "$err" | grep -q "typeck error" || { echo "expected typeck error in $file (e.g. $msg), got: $err"; exit 1; }
}
if [ -n "$SHUX" ]; then
  TYPECK_SHUX="$SHUX"
  # SX 宿主（shux_sx / shux-sx）：赋值 for-step 负例须在本地 -sx 流水线上报与 shux-c 同源的行（grep 短语）；其余负例走 .sx typeck（与 shux-c 对齐，不再回退 C 前端）。
  case "${SHUX##*/}" in
    shux_asm*)
      # shux_asm strict 链 typecheck 桩与 seed shux 不一致；SX 负例与 assign 短语仍用 seed 链验收。
      # run-all-bstrict 会把 shux_asm 拷到 ./compiler/shux，勿用 shux 作负例（空输出）。
      if [ -x ./compiler/shux-sx ]; then
        TYPECK_NEG_SHUX=./compiler/shux-sx
      elif [ -x ./compiler/shux-c ]; then
        TYPECK_NEG_SHUX=./compiler/shux-c
      else
        TYPECK_NEG_SHUX=./compiler/shux
      fi
      if [ ! -x "$TYPECK_NEG_SHUX" ]; then
        TYPECK_NEG_SHUX="$SHUX"
      fi
      err_assign_sx=$("$TYPECK_NEG_SHUX" tests/typeck/type_mismatch_assign.sx -o /tmp/shux_typeck_assign_fail.o 2>&1) || true
      echo "$err_assign_sx" | grep -q "assignment type mismatch: expected i32, found bool" || {
        echo "expected SX 'assignment type mismatch: expected i32, found bool' in type_mismatch_assign.sx; got: $err_assign_sx"
        exit 1
      }
      err_ret_sx=$("$TYPECK_NEG_SHUX" tests/typeck/return_operand_type_mismatch.sx -o /tmp/shux_typeck_ret_fail.o 2>&1) || true
      echo "$err_ret_sx" | grep -q "typeck error" || {
        echo "expected $TYPECK_NEG_SHUX pipeline typeck error on return_operand_type_mismatch.sx (bool vs i32 return); got: $err_ret_sx"
        exit 1
      }
      # gen2 strict 链对用户 .sx 常 skip typeck；负例与正例 typeck 短语均用 seed 链（与 run-all-bstrict 一致）。
      TYPECK_SHUX="$TYPECK_NEG_SHUX"
      ;;
    shux|shux-sx|shux_sx)
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
      err_assign_sx=$("$TYPECK_NEG_SHUX" tests/typeck/type_mismatch_assign.sx -o /tmp/shux_typeck_assign_fail.o 2>&1) || true
      echo "$err_assign_sx" | grep -q "assignment type mismatch: expected i32, found bool" || {
        echo "expected typeck 'assignment type mismatch: expected i32, found bool' in type_mismatch_assign.sx; got: $err_assign_sx"
        exit 1
      }
      err_ret_sx=$("$TYPECK_NEG_SHUX" tests/typeck/return_operand_type_mismatch.sx -o /tmp/shux_typeck_ret_fail.o 2>&1) || true
      echo "$err_ret_sx" | grep -q "typeck error" || {
        echo "expected $TYPECK_NEG_SHUX pipeline typeck error on return_operand_type_mismatch.sx (bool vs i32 return); got: $err_ret_sx"
        exit 1
      }
      TYPECK_SHUX="$TYPECK_NEG_SHUX"
      ;;
  esac
  expect_typeck_error tests/typeck/type_mismatch_assign.sx "assignment type mismatch" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/if_condition_not_bool.sx "if condition must be bool" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/undefined_name.sx "undefined name" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/return_implicit.sx "explicit return statement" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/ternary_condition_not_bool.sx "ternary condition must be bool" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/ternary_branches_mismatch.sx "ternary branches must have the same type" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/u64_to_usize_needs_as.sx "expected usize, found u64" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/struct_repr_compatible_fail.sx "no matching overload" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/result_try_bad.sx "enclosing function to return the same Result type" "$TYPECK_SHUX"
  for f in tests/typeck/contextual_typing_p0.sx tests/typeck/contextual_typing_p1.sx tests/typeck/postfix_call_index.sx tests/typeck/postfix_array_slice_type.sx tests/typeck/ptr_arith_i32.sx tests/typeck/ternary_u8_context.sx tests/typeck/struct_field_shorthand.sx tests/typeck/match_guard.sx tests/typeck/match_struct_destructure.sx tests/typeck/range_for.sx tests/typeck/result_try.sx tests/typeck/result_try_catch.sx tests/typeck/return_struct_field_shorthand.sx tests/typeck/struct_repr_compatible.sx tests/typeck/type_alias.sx; do
    out_pos=$("$TYPECK_SHUX" "$f" 2>&1) || true
    echo "$out_pos" | grep -q "typeck OK" || { echo "missing typeck OK for $f: $out_pos"; exit 1; }
  done
else
  make -C compiler -q 2>/dev/null || make -C compiler
  make -C compiler shux-c 2>/dev/null || true
  if [ -f ./compiler/shux-c ]; then
    TYPECK_SHUX=./compiler/shux-c
  else
    TYPECK_SHUX=./compiler/shux
  fi
  out=$("$TYPECK_SHUX" tests/lexer/main.sx 2>&1)
  echo "$out" | grep -q "typeck OK" || { echo "missing 'typeck OK' in output"; exit 1; }
  expect_typeck_error tests/typeck/type_mismatch_assign.sx "assignment type mismatch" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/if_condition_not_bool.sx "if condition must be bool" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/undefined_name.sx "undefined name" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/return_implicit.sx "explicit return statement" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/ternary_condition_not_bool.sx "ternary condition must be bool" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/ternary_branches_mismatch.sx "ternary branches must have the same type" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/u64_to_usize_needs_as.sx "expected usize, found u64" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/struct_repr_compatible_fail.sx "no matching overload" "$TYPECK_SHUX"
  expect_typeck_error tests/typeck/result_try_bad.sx "enclosing function to return the same Result type" "$TYPECK_SHUX"
  if [ -x ./compiler/shux-sx ]; then
    err_ret_sx=$(./compiler/shux-sx -sx tests/typeck/return_operand_type_mismatch.sx -o /tmp/shux_typeck_ret_fail_defaults.o 2>&1) || true
    echo "$err_ret_sx" | grep -q "typeck error" || {
      echo "expected ./compiler/shux-sx -sx return_operand_type_mismatch typeck error; got: $err_ret_sx"
      exit 1
    }
  fi
  for f in tests/typeck/contextual_typing_p0.sx tests/typeck/contextual_typing_p1.sx tests/typeck/postfix_call_index.sx tests/typeck/postfix_array_slice_type.sx tests/typeck/ptr_arith_i32.sx tests/typeck/ternary_u8_context.sx tests/typeck/struct_field_shorthand.sx tests/typeck/match_guard.sx tests/typeck/match_struct_destructure.sx tests/typeck/range_for.sx tests/typeck/result_try.sx tests/typeck/result_try_catch.sx tests/typeck/return_struct_field_shorthand.sx tests/typeck/struct_repr_compatible.sx tests/typeck/type_alias.sx; do
    out_pos=$("$TYPECK_SHUX" "$f" 2>&1) || true
    echo "$out_pos" | grep -q "typeck OK" || { echo "missing typeck OK for $f: $out_pos"; exit 1; }
  done
fi
echo "typeck test OK"
