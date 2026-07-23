# TU Contract: backend_seed_mega_fallback

## 1. 当前权威源
- x 源：`src/asm/backend_seed_mega_fallback.x`
- seed 源：`seeds/backend_seed_mega_fallback.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/backend_seed_mega_fallback`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 本次目标：已证明该 TU 具备 L1/L2/L3 闭环（含 ld -r 合并）
- 当前角色判断：
  - `thin/.x provider`：src/asm/backend_seed_mega_fallback.x（pipeline_seed_mega_ctx_reset + pipeline_dep_ctx_target_arch_local）
  - `seed/rest provider`：seeds/backend_seed_mega_fallback.from_x.c（backend_asm_codegen_* / backend_emit_* 14 函数）

## 3. 导出符号合同
- thin/.x 当前导出数：2
- seed/rest 当前导出数：14
- thin/.x 独有导出：4（内部 helper + doc anchor）
- seed/rest 残余导出：14

### 3.1 必须由 thin/.x 提供
- `pipeline_seed_mega_ctx_reset`
- `pipeline_dep_ctx_target_arch_local`

### 3.2 当前仍由 seed/rest 提供
- `backend_asm_codegen_ast`
- `backend_asm_codegen_ast_seed_mega`
- `backend_asm_codegen_ast_to_elf`
- `backend_asm_codegen_ast_to_elf_seed_mega`
- `backend_emit_block_body`
- `backend_emit_block_inits`
- `backend_emit_expr`
- `backend_emit_expr_call`
- `backend_emit_expr_elf`
- `backend_emit_expr_method_call`
- `backend_emit_for_loop`
- `backend_emit_if_then_block_body_text`
- `backend_emit_loop_body_content`
- `backend_emit_while_loop`

### 3.3 thin/.x 独有导出（若非空，后续需审计）
- `mega_load_i32_le`（内部 helper，无 #[no_mangle]）
- `mega_store_i32_le`（内部 helper，无 #[no_mangle]）
- `mega_store_ptr_le`（内部 helper，无 #[no_mangle]）
- `backend_seed_mega_fallback_x_doc_anchor`（doc anchor）

## 4. ABI Manifest（试点版）
- 当前阶段先锁定：
  - symbol 集
  - thin/.x 与 seed/rest 的 provider 边界
  - _impl 残余列表：N/A（本 TU 使用 #ifndef/extern 模式，非 _impl 模式）
  - thin+rest 宏边界：`XLANG_BACKEND_SEED_MEGA_FALLBACK_FROM_X`
  - 实现差异：.x pipeline_dep_ctx_target_arch_local 调用 extern pipeline_dep_ctx_target_arch；seed 直接访问 ctx->target_arch。两者语义等价。
  - rest 跨调用依赖：backend_asm_codegen_ast_seed_mega 调用 pipeline_seed_mega_ctx_reset + pipeline_dep_ctx_target_arch_local（thin 提供，rest 模式下 extern 声明）
- 下一步补充：
  - arg_count / arg_shapes
  - ret_shape
  - struct_size_snapshot（AsmFuncCtxLayout size=1336, label_counter@12, module_ref@16）
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
