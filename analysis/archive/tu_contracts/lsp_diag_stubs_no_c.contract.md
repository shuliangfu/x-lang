# TU Contract: lsp_diag_stubs_no_c

## 1. 当前权威源
- x 源：`src/lsp/lsp_diag_stubs_no_c.x`
- seed 源：`seeds/lsp_diag_stubs_no_c.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/lsp_diag_stubs_no_c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 本次目标：已证明该 TU 具备 L1/L2/L3 闭环（含 ld -r 合并）
- 当前角色判断：
  - `thin/.x provider`：src/lsp/lsp_diag_stubs_no_c.x（lsp_diag_copy_text + json_escape_str public wrapper）
  - `seed/rest provider`：seeds/lsp_diag_stubs_no_c.from_x.c（_impl 实现 + 31 个残余符号）

## 3. 导出符号合同
- thin/.x 当前导出数：3
- seed/rest 当前导出数：33
- thin/.x 独有导出：1
- seed/rest 残余导出：33

### 3.1 必须由 thin/.x 提供
- `json_escape_str`
- `lsp_diag_copy_text`
- `lsp_diag_stubs_no_c_x_doc_anchor`

### 3.2 当前仍由 seed/rest 提供
- `json_escape_str_impl`
- `lsp_build_completion_response`
- `lsp_build_definition_response`
- `lsp_build_document_symbol_response`
- `lsp_build_formatting_response`
- `lsp_build_hover_response`
- `lsp_build_initialize_result`
- `lsp_build_references_response`
- `lsp_build_rename_response`
- `lsp_build_response_with_result`
- `lsp_debug_ptr`
- `lsp_debug_u32`
- `lsp_diag_add`
- `lsp_diag_add_code`
- `lsp_diag_clear`
- `lsp_diag_collect_begin`
- `lsp_diag_collect_end`
- `lsp_diag_count_severity`
- `lsp_diag_copy_text_impl`
- `lsp_diag_format_diagnostics_json`
- `lsp_diag_invalidate_cache`
- `lsp_diag_prepare_pipeline_ctx`
- `lsp_diag_print_stderr_human`
- `lsp_diag_report_typeck`
- `lsp_diag_report_typeck_code`
- `lsp_diag_x_arena_ptr`
- `lsp_diag_x_ctx_ptr`
- `lsp_diag_x_module_ptr`
- `lsp_diag_x_reset_parse_buffers`
- `lsp_get_document_len`
- `lsp_get_document_ptr`
- `lsp_set_document_from_body`
- `shu_format_x_document`

### 3.3 thin/.x 独有导出（若非空，后续需审计）
- `lsp_diag_stubs_no_c_x_doc_anchor`

## 4. ABI Manifest（试点版）
- 当前阶段先锁定：
  - symbol 集
  - thin/.x 与 seed/rest 的 provider 边界
  - _impl 残余列表：`json_escape_str_impl`、`lsp_diag_copy_text_impl`
  - thin+rest 宏边界：`XLANG_LSP_DIAG_STUBS_NO_C_FROM_X`
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
  - ld -r thin+rest 合并：✅ 已通过（macOS arm64 + Ubuntu x86_64 双平台验证）
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
