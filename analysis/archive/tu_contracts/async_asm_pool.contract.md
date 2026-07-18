# TU Contract: async_asm_pool

## 1. 当前权威源
- x 源：`src/asm/async_asm_pool.x`
- seed 源：`seeds/async_asm_pool.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/async_asm_pool`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 本次目标：已证明该 TU 具备 L1/L2/L3 闭环（含 ld -r 合并）
- 当前角色判断：
  - `thin/.x provider`：src/asm/async_asm_pool.x（9 个 asm_pool_*/async_asm_pool_* pure helpers）
  - `seed/rest provider`：seeds/async_asm_pool.from_x.c（async_asm_pool_build_layout）

## 3. 导出符号合同
- thin/.x 当前导出数：9
- seed/rest 当前导出数：1
- thin/.x 独有导出：3（内部 helper + doc anchor）
- seed/rest 残余导出：1

### 3.1 必须由 thin/.x 提供
- `asm_pool_expr_is_await`
- `asm_pool_expr_has_await`
- `asm_pool_expr_is_var_named`
- `asm_pool_expr_refs_name`
- `asm_pool_block_rest_refs_name`
- `asm_pool_type_size_bytes`
- `asm_pool_live_add`
- `async_asm_pool_fn_id_from_name`
- `async_asm_pool_func_needs_cps`

### 3.2 当前仍由 seed/rest 提供
- `async_asm_pool_build_layout`

### 3.3 thin/.x 独有导出（若非空，后续需审计）
- `asm_pool_load_i32_le`（内部 helper，无 #[no_mangle]）
- `asm_pool_store_i32_le`（内部 helper，无 #[no_mangle]）
- `async_asm_pool_x_doc_anchor`（doc anchor）

## 4. ABI Manifest（试点版）
- 当前阶段先锁定：
  - symbol 集
  - thin/.x 与 seed/rest 的 provider 边界
  - _impl 残余列表：N/A（本 TU 使用 #ifndef/extern 模式，非 _impl 模式）
  - thin+rest 宏边界：`SHUX_ASYNC_ASM_POOL_FROM_X`
  - rest 跨调用依赖：async_asm_pool_build_layout 调用 6 个 thin 函数（func_needs_cps/fn_id_from_name/expr_has_await/block_rest_refs_name/live_add/type_size_bytes）
- 下一步补充：
  - arg_count / arg_shapes
  - ret_shape
  - struct_size_snapshot（AsyncAsmPoolLayout: num_live@8 live@12 stride 76）
  - critical_field_offsets

## 5. 验证状态
- prove_x_o.sh：已跑通最小 L1/L2
- 已完成：
  - bootstrap-safe lint
  - .x -> -E
  - cc -c
  - nm
  - seed 符号对照
  - ld -r thin+rest 合并：✅ 已通过（macOS arm64 + Ubuntu x86_64 双平台验证，13 T 符号）
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
