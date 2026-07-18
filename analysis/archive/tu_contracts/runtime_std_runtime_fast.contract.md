# TU Contract: runtime_std_runtime_fast

## 1. 当前权威源
- x 源：`src/asm/runtime_std_runtime_fast.x`（G-02f-23 真迁 .x，包含完整实现）
- seed 源：`seeds/runtime_std_runtime_fast.from_x.c`（.x 的 C 翻译，rest 模式下为空）

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 6 个函数完整实现，seed/rest 在 rest 模式下为空（DIRECT 模式）

## 3. 导出符号合同
- thin/.x 导出：6（全部函数完整实现）
- seed/rest 导出：0（DIRECT 模式，rest 模式下 seed #ifndef 保护所有函数，为空）
- only_x：6（所有函数都由 .x 提供）

### 3.1 必须由 thin/.x 提供
- `std_runtime_crash_evidence_collect`（转发到 shux_crash_evidence_collect_c）
- `runtime_crash_evidence_collect_c`（转发到 std_runtime_crash_evidence_collect）
- `std_runtime_runtime_panic`（转发到 shux_panic_）
- `runtime_panic`（转发到 shux_panic_）
- `std_runtime_runtime_abort`（转发到 shux_panic_）
- `runtime_abort`（转发到 shux_panic_）

### 3.2 当前仍由 seed/rest 提供
- 无（DIRECT 模式，seed 在 rest 模式下为空）

## 4. ABI Manifest
- _impl 残余列表：无（DIRECT 模式无 _impl）
- thin+rest 宏边界：`SHUX_RUNTIME_STD_RUNTIME_FAST_FROM_X`
- 前向声明：无（DIRECT 模式不需要，seed 在 rest 模式下为空，rest 函数不存在）
- 内部调用更新：无（所有函数体调用外部 TU 符号 shux_panic_ / shux_crash_evidence_collect_c）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过，macOS 完整流程含 merged.o）
- ld -r：ok（macOS merged 6 T + 2 U；Ubuntu merged 6 W + 2 U，U 仅 shux_panic_ / shux_crash_evidence_collect_c 外部 TU 依赖）
- smoke/probe：pending

## 6. 备注
- DIRECT 模式（G-02f-23 真迁 .x）：.x 文件包含所有 6 个函数完整实现（非文档锚点），seed 是 .x 的 C 翻译
- rest 模式下 seed 为空（#ifndef 保护所有 6 个函数），所有符号由 thin.o 提供
- 外部 TU 依赖：`shux_panic_` / `shux_crash_evidence_collect_c`（由其他 TU 提供，merged 后为 U 符号）
- 已知预存行为：Linux 上 thin.o 的 6 个函数为 W（weak）符号——prove_x_o.sh 默认 G05_X_O_WEAK=1 给函数加 __attribute__((weak))，Linux 产生 W 符号；macOS Mach-O 忽略 weak 属性，均为 T 符号。非本次切割引入
- 依赖：无 libc 依赖（纯转发函数）
