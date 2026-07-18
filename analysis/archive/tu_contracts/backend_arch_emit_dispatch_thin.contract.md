# TU Contract: backend_arch_emit_dispatch_thin

## 1. 当前权威源
- x 源：`src/asm/backend_arch_emit_dispatch_thin.x`
- seed 源：`seeds/backend_arch_emit_dispatch.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/backend_arch_emit_dispatch_thin`

## 2. 当前目标
- 当前阶段：Phase 0 试点
- 本次目标：先证明该 TU 已具备最小 L1/L2 闭环
- 当前角色判断：
  - `thin/.x provider`
  - `seed/rest provider`

## 3. 导出符号合同
- thin/.x 当前导出数：47
- seed/rest 当前导出数：47
- thin/.x 独有导出：0
- seed/rest 残余导出：0

### 3.1 必须由 thin/.x 提供
- `backend_arch_emit_add_imm_to_rax`
- `backend_arch_emit_add_rax_rbx`
- `backend_arch_emit_add_sp_imm`
- `backend_arch_emit_and_rbx_rax`
- `backend_arch_emit_call`
- `backend_arch_emit_cmp_rbx_rax`
- `backend_arch_emit_cmp_setcc`
- `backend_arch_emit_epilogue`
- `backend_arch_emit_globl`
- `backend_arch_emit_imul_rbx_rax`
- `backend_arch_emit_jeq`
- `backend_arch_emit_jmp`
- `backend_arch_emit_jnz`
- `backend_arch_emit_jz`
- `backend_arch_emit_label`
- `backend_arch_emit_ldr_sp_offset_to_wi`
- `backend_arch_emit_lea_rbp_to_rax`
- `backend_arch_emit_load_32_from_rax`
- `backend_arch_emit_load_64_from_rax`
- `backend_arch_emit_load_rbp_to_rax`
- `backend_arch_emit_load_zext8_from_rax`
- `backend_arch_emit_mov_imm32_to_rbx`
- `backend_arch_emit_mov_imm64_to_rax`
- `backend_arch_emit_mov_rax_to_arg_reg`
- `backend_arch_emit_mov_rax_to_rbx`
- `backend_arch_emit_mov_rbx_to_ecx`
- `backend_arch_emit_mov_rbx_to_rax`
- `backend_arch_emit_neg_eax`
- `backend_arch_emit_not_eax`
- `backend_arch_emit_or_rbx_rax`
- `backend_arch_emit_pop_rax`
- `backend_arch_emit_pop_rbx`
- `backend_arch_emit_prologue`
- `backend_arch_emit_push_rax`
- `backend_arch_emit_rax_plus_rbx_scale1`
- `backend_arch_emit_rax_plus_rbx_scale4`
- `backend_arch_emit_rax_plus_rbx_scale8`
- `backend_arch_emit_ret_imm32`
- `backend_arch_emit_sar_cl_eax`
- `backend_arch_emit_section_text`
- `backend_arch_emit_shl_cl_eax`
- `backend_arch_emit_shr_cl_eax`
- `backend_arch_emit_store_rax_to_rbp`
- `backend_arch_emit_store_rax_to_rbx_indirect`
- `backend_arch_emit_store_rax_to_rbx_offset`
- `backend_arch_emit_sub_rbx_rax_then_mov`
- `backend_arch_emit_xor_rbx_rax`

### 3.2 当前仍由 seed/rest 提供
- （空）

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
