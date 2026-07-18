# TU Contract: runtime_heap_user

## 1. 当前权威源
- x 源：`src/runtime_heap_user.x`
- seed 源：`seeds/runtime_heap_user.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/runtime_heap_user`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 本次目标：已证明该 TU 具备 L1/L2/L3 闭环（含 ld -r 合并）
- 当前角色判断：
  - `thin/.x provider`：src/runtime_heap_user.x（heap_alloc/free/realloc/zeroed_c 薄 libc 转发）
  - `seed/rest provider`：seeds/runtime_heap_user.from_x.c（heap_alloc_aligned_c + Arena64 三函数 C 尾段）

## 3. 导出符号合同
- thin/.x 当前导出数：4
- seed/rest 当前导出数：4
- thin/.x 独有导出：0
- seed/rest 残余导出：4

### 3.1 必须由 thin/.x 提供
- `heap_alloc_c`
- `heap_free_c`
- `heap_realloc_c`
- `heap_alloc_zeroed_c`

### 3.2 当前仍由 seed/rest 提供
- `heap_alloc_aligned_c`
- `heap_arena_init_c`
- `heap_arena64_alloc_c`
- `heap_arena64_deinit_c`

### 3.3 thin/.x 独有导出（若非空，后续需审计）
- （空）

## 4. ABI Manifest（试点版）
- 当前阶段先锁定：
  - symbol 集
  - thin/.x 与 seed/rest 的 provider 边界
  - _impl 残余列表：N/A（本 TU 使用 #ifndef/extern 模式，非 _impl 模式）
  - thin+rest 宏边界：`SHUX_RUNTIME_HEAP_USER_FROM_X`
  - rest 跨调用依赖：`heap_arena64_deinit_c` 调用 `heap_free_c`（thin 提供，rest 模式下 extern 声明）
- 下一步补充：
  - arg_count / arg_shapes
  - ret_shape
  - struct_size_snapshot（ShuxHeapArena64: chunk/cap/off 各 8B）
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
