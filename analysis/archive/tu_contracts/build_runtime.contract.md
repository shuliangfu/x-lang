# TU Contract: build_runtime

## 1. 当前权威源
- x 源：`src/build_runtime.x`（G-02f-105/111 薄门闩）
- seed 源：`seeds/build_runtime.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 5 个 IMPL wrapper，seed/rest 提供 5 个 _impl + 8 个 rest 函数 + main/entry

## 3. 导出符号合同
- thin/.x 导出：6（5 IMPL wrapper + 1 doc_anchor）
- seed/rest 导出：13（5 _impl + 8 rest 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- IMPL wrapper（5）：`build_runtime_info`、`build_runtime_warn`、`build_patch_pipeline_gen_c`、`build_patch_driver_gen_c`、`build_run_legacy_steps`

### 3.2 当前仍由 seed/rest 提供
- _impl（5）：`build_runtime_info_impl`、`build_runtime_warn_impl`、`build_patch_pipeline_gen_c_impl`、`build_patch_driver_gen_c_impl`、`build_run_legacy_steps_impl`
- rest（8）：`build_get_argv_i`、`build_append_literal`、`build_exec_cmd`、`build_patch_after_step`、`build_get_shu_path`、`build_run_step`、`build_run_asm_build`、`main`/`entry`

## 4. ABI Manifest
- _impl 残余列表：5 个
- DIRECT 符号列表：无
- thin+rest 宏边界：`XLANG_BUILD_RUNTIME_FROM_X`
- 前向声明：5 个（`build_runtime_info`、`build_runtime_warn`、`build_patch_pipeline_gen_c`、`build_patch_driver_gen_c`、`build_run_legacy_steps`）

## 5. 验证状态
- prove_x_o：ok
- ld -r：ok（macOS merged 19 T + libc/外部 U；Ubuntu merged 19 T/W，U=0）
- smoke/probe：pending

## 6. 备注
- IMPL 模式切割：5 个 wrapper 由 .x 提供，调用 seed 中的 _impl
- 签名修复：.x 中 `build_patch_pipeline_gen_c`/`build_patch_driver_gen_c` 原为 `(path: *u8)`，seed 为 `(void)`，已修复 .x 为无参数；`build_run_legacy_steps` 原为 `()`，seed 为 `(const char *shu_path)`，已修复 .x 为 `(shu_path: *u8)`
- main/entry 保留 seed：argv 语言限制（.x 无法表达 `char **argv`），且有 `#ifdef BUILD_TOOL_X_ENTRY` 条件编译
- 调用处保持调用 thin wrapper 名（`build_patch_pipeline_gen_c()` 等），不直接调用 _impl
- 类型擦除：.x 侧 `*u8` 表达 `const char*` 参数，ABI 兼容
