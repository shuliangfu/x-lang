# TU Contract: runtime_panic_arm64

## 1. 当前权威源
- x 源：`src/asm/runtime_panic_arm64.x`
- seed 源：`seeds/runtime_panic_arm64.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/runtime_panic_arm64`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 本次目标：已证明该 TU 具备 L1/L2/L3 闭环（含 ld -r 合并）
- 当前角色判断：
  - `thin/.x provider`：src/asm/runtime_panic_arm64.x（shux_crash_evidence_minimal public wrapper）
  - `seed/rest provider`：seeds/runtime_panic_arm64.from_x.c（_impl 实现 + 2 个残余符号）

## 3. 导出符号合同
- thin/.x 当前导出数：2
- seed/rest 当前导出数：3
- thin/.x 独有导出：1
- seed/rest 残余导出：3

### 3.1 必须由 thin/.x 提供
- `runtime_panic_arm64_x_doc_anchor`
- `shux_crash_evidence_minimal`

### 3.2 当前仍由 seed/rest 提供
- `shux_crash_evidence_collect_c`
- `shux_crash_evidence_minimal_impl`
- `shux_panic_`

### 3.3 thin/.x 独有导出（若非空，后续需审计）
- `runtime_panic_arm64_x_doc_anchor`

## 4. ABI Manifest（试点版）
- 当前阶段先锁定：
  - symbol 集
  - thin/.x 与 seed/rest 的 provider 边界
  - _impl 残余列表：`shux_crash_evidence_minimal_impl`
  - thin+rest 宏边界：`SHUX_RUNTIME_PANIC_ARM64_FROM_X`
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
  - ld -r thin+rest 合并：✅ 已通过（macOS arm64 5 T 符号 + Ubuntu x86_64 rest.o 编译通过）
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
- IMPL 模式切割：.x wrapper 调用 `_impl`，seed 提供 `_impl` 实现
- 与 runtime_panic TU 互斥（平台条件链接）：runtime_panic 通用平台，runtime_panic_arm64 ARM64/macOS
- 内部调用点 `shux_crash_evidence_collect_c` 改为调用 `_impl`（避免循环调用 thin wrapper）
