# TU Contract: diag_thin

## 1. 当前权威源
- x 源：`src/diag_thin.x`
- seed 源：`seeds/diag.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/diag_thin`

## 2. 当前目标
- 当前阶段：Phase 0 试点
- 本次目标：先证明该 TU 已具备最小 L1/L2 闭环
- 当前角色判断：
  - `thin/.x provider`
  - `seed/rest provider`

## 3. 导出符号合同
- thin/.x 当前导出数：78
- seed/rest 当前导出数：106
- thin/.x 独有导出：11
- seed/rest 残余导出：39

### 3.1 必须由 thin/.x 提供
- `diag_bytes_match_at`
- `diag_code_details`
- `diag_code_eq`
- `diag_code_is_known`
- `diag_code_kind`
- `diag_code_suggest`
- `diag_code_summary`
- `diag_code_table_code_at`
- `diag_code_table_details_at`
- `diag_code_table_has`
- `diag_code_table_kind_at`
- `diag_code_table_len`
- `diag_code_table_summary_at`
- `diag_color_prefix`
- `diag_color_reset`
- `diag_cstr_len_bounded`
- `diag_ctx_get_file`
- `diag_ctx_get_source`
- `diag_ctx_get_source_len`
- `diag_ctx_get_use_color`
- `diag_ctx_set_all`
- `diag_entry_code`
- `diag_entry_details`
- `diag_entry_kind`
- `diag_entry_summary`
- `diag_extract_line`
- `diag_get_file`
- `diag_get_source`
- `diag_get_source_len`
- `diag_io_fflush`
- `diag_io_fprint_caret_mark`
- `diag_io_fprint_code_table_hdr`
- `diag_io_fprint_code_table_row`
- `diag_io_fprint_gutter_bar`
- `diag_io_fprint_gutter_blank`
- `diag_io_fprint_line_col`
- `diag_io_fprint_loc_file`
- `diag_io_fprint_loc_file_line`
- `diag_io_fprint_loc_file_line_col`
- `diag_io_fprint_loc_line_col`
- `diag_io_fprint_src_line`
- `diag_io_fprint_unknown_code`
- `diag_io_fputc`
- `diag_io_fputs`
- `diag_io_fputs_u04x`
- `diag_json_enabled`
- `diag_json_get_state`
- `diag_json_set_state`
- `diag_json_severity`
- `diag_json_write_str`
- `diag_kind_contains`
- `diag_kind_is_exact`
- `diag_levenshtein_ci`
- `diag_line_digits`
- `diag_print_code_explain`
- `diag_print_code_table`
- `diag_print_header`
- `diag_print_known_codes`
- `diag_push_file`
- `diag_push_snap_save`
- `diag_report`
- `diag_report_human`
- `diag_report_json`
- `diag_report_with_code`
- `diag_restore`
- `diag_set_file`
- `diag_set_json_mode`
- `diag_should_color`
- `diag_snap_load_i32`
- `diag_snap_load_ptr`
- `diag_snap_load_usize`
- `diag_snap_store_i32`
- `diag_snap_store_ptr`
- `diag_snap_store_usize`
- `diag_stderr`
- `diag_stdout`
- `diag_store_ptr_le`
- `diag_store_usize_le`

### 3.2 当前仍由 seed/rest 提供
- `diag_code_table_code_at_impl`
- `diag_code_table_details_at_impl`
- `diag_code_table_has_impl`
- `diag_code_table_kind_at_impl`
- `diag_code_table_len_impl`
- `diag_code_table_summary_at_impl`
- `diag_ctx_get_file_impl`
- `diag_ctx_get_source_impl`
- `diag_ctx_get_source_len_impl`
- `diag_ctx_get_use_color_impl`
- `diag_ctx_set_all_impl`
- `diag_entry_code_impl`
- `diag_entry_details_impl`
- `diag_entry_kind_impl`
- `diag_entry_summary_impl`
- `diag_io_fflush_impl`
- `diag_io_fprint_caret_mark_impl`
- `diag_io_fprint_code_table_hdr_impl`
- `diag_io_fprint_code_table_row_impl`
- `diag_io_fprint_gutter_bar_impl`
- `diag_io_fprint_gutter_blank_impl`
- `diag_io_fprint_line_col_impl`
- `diag_io_fprint_loc_file_impl`
- `diag_io_fprint_loc_file_line_col_impl`
- `diag_io_fprint_loc_file_line_impl`
- `diag_io_fprint_loc_line_col_impl`
- `diag_io_fprint_src_line_impl`
- `diag_io_fprint_unknown_code_impl`
- `diag_io_fputc_impl`
- `diag_io_fputs_impl`
- `diag_io_fputs_u04x_impl`
- `diag_json_get_state_impl`
- `diag_json_set_state_impl`
- `diag_reportf`
- `diag_reportf_with_code`
- `diag_stderr_impl`
- `diag_stdout_impl`
- `diag_vreportf`
- `diag_vreportf_with_code`

### 3.3 thin/.x 独有导出（若非空，后续需审计）
- `diag_bytes_match_at`
- `diag_cstr_len_bounded`
- `diag_push_snap_save`
- `diag_snap_load_i32`
- `diag_snap_load_ptr`
- `diag_snap_load_usize`
- `diag_snap_store_i32`
- `diag_snap_store_ptr`
- `diag_snap_store_usize`
- `diag_store_ptr_le`
- `diag_store_usize_le`

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
