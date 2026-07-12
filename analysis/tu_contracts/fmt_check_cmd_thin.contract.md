# TU Contract: fmt_check_cmd_thin

## 1. 当前权威源
- x 源：`src/driver/fmt_check_cmd_thin.x`
- seed 源：`seeds/fmt_check_cmd.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/fmt_check_cmd_thin`

## 2. 当前目标
- 当前阶段：Phase 0 试点
- 本次目标：先证明该 TU 已具备最小 L1/L2 闭环
- 当前角色判断：
  - `thin wrapper / partial provider`
  - `rest provider (_impl residual present)`

## 3. 导出符号合同
- thin/.x 当前导出数：42
- seed/rest 当前导出数：75
- thin/.x 独有导出：0
- seed/rest 残余导出：33

### 3.1 必须由 thin/.x 提供
- `check_append_repo_lib_roots`
- `check_argv_append_default_libs_for_path`
- `check_collect_default_product_dirs`
- `check_init_user_lib_flags`
- `check_lint_fail_on_warnings`
- `check_one_file`
- `check_one_finalize_rc`
- `check_one_need_fallback_diag`
- `check_try_append_lib_root`
- `check_user_passed_L_get`
- `collect_paths_from_arg`
- `driver_check_print_collected_diagnostics`
- `driver_check_quiet_ok_get`
- `driver_check_set_current_file`
- `driver_collect_error_kind`
- `driver_collect_missing_path_code`
- `driver_collect_mode_is_check`
- `driver_fmt_check_lit_check_error`
- `driver_fmt_check_lit_chk002`
- `driver_fmt_check_lit_fmt001`
- `driver_fmt_check_lit_fmt_error`
- `driver_run_compiler_check`
- `driver_run_fmt`
- `file_list_clear`
- `file_list_push`
- `fmt_builtin_ignore_at`
- `fmt_check_dep_clear`
- `fmt_check_invoke_compile`
- `fmt_default_product_sub_at`
- `fmt_file_list_n`
- `fmt_path_ends_with_dot_x`
- `fmt_path_resolve_abs`
- `fmt_path_stat_kind`
- `fmt_try_walk_if_product_subdir`
- `fmt_user_ignore_at`
- `fmt_user_ignore_count`
- `fmt_walk_skip_dot_name`
- `parse_ignore_opt`
- `path_should_ignore`
- `shux_path_is_absolute`
- `walk_dir_collect`
- `walk_dir_collect_process_child`

### 3.2 当前仍由 seed/rest 提供
- `check_append_repo_lib_roots_impl`
- `check_argv_append_default_libs_for_path_impl`
- `check_collect_default_product_dirs_impl`
- `check_init_user_lib_flags_impl`
- `check_lint_fail_on_warnings_impl`
- `check_one_file_body_impl`
- `check_one_file_impl`
- `check_try_append_lib_root_impl`
- `check_user_passed_L_get_impl`
- `collect_paths_from_arg_impl`
- `collect_paths_missing_diag_impl`
- `driver_check_print_collected_diagnostics_impl`
- `driver_check_set_current_file_impl`
- `driver_collect_mode_is_check_impl`
- `driver_run_compiler_check_impl`
- `driver_run_fmt_impl`
- `file_list_clear_impl`
- `file_list_push_impl`
- `fmt_check_dep_clear_impl`
- `fmt_check_invoke_compile_impl`
- `fmt_file_list_n_impl`
- `fmt_file_list_store_impl`
- `fmt_path_ends_with_dot_x_impl`
- `fmt_path_resolve_abs_impl`
- `fmt_path_stat_kind_impl`
- `fmt_try_walk_if_product_subdir_impl`
- `fmt_user_ignore_at_impl`
- `fmt_user_ignore_count_impl`
- `fmt_walk_cwd_fallback_impl`
- `parse_ignore_opt_impl`
- `path_should_ignore_impl`
- `walk_dir_collect_impl`
- `walk_dir_collect_process_child_impl`

### 3.3 thin/.x 独有导出（若非空，后续需审计）
- （空）

## 4. ABI Manifest（试点版）
- 当前阶段先锁定：
  - symbol 集
  - thin/.x 与 seed/rest 的 provider 边界
  - _impl 残余列表
  - thin+rest 宏边界：N/A
- 下一步补充：
  - arg_count / arg_shapes
  - ret_shape
  - struct_size_snapshot
  - critical_field_offsets

## 5. 验证状态
- prove_x_o.sh：已跑通最小 L1/L2
- 已完成：
  - bootstrap-safe lint
  - .x -> -E
  - cc -c
  - nm
  - seed 符号对照
  - ld -r thin+rest 合并：pending
- 待补：
  - smoke / probe：pending
  - canonical snapshot compare：pending

## 6. 删除 seed 的门槛
- 当前阶段：**不允许删 seed**
- 必须补齐：
  - provider 边界稳定
  - ld -r 闭环
  - smoke / probe 一致
  - 连续构建不回退 seed

## 7. 备注
- 本文件由 compiler/scripts/gen_tu_contract.sh 生成
- 当前只作为试点 TU 的最小合同，不代表最终 ABI 审计已完成
