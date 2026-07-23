# TU Contract: runtime_thread_glue

## 1. 当前权威源
- x 源：`src/asm/runtime_thread_glue.x`（G-02f-18 文档锚点 + G-02f-102 门闩）
- seed 源：`seeds/runtime_thread_glue.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 2 个 IMPL wrapper + 1 doc_anchor，seed/rest 提供 2 个 `_impl` + 23 个 rest 函数

## 3. 导出符号合同
- thin/.x 导出：3（doc_anchor + 2 wrapper）
- seed/rest 导出：25（2 `_impl` + 23 个 thread_*_c / std_thread_*_c 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_thread_glue_x_doc_anchor`（only_x）
- `shu_cpu_zero`（IMPL，调用 `_impl`，Linux only）
- `shu_cpu_set`（IMPL，调用 `_impl`，Linux only）

### 3.2 当前仍由 seed/rest 提供
- `shu_cpu_zero_impl`（cpu_set_t 清零，Linux only）
- `shu_cpu_set_impl`（cpu_set_t 置位，Linux only）
- 线程基础：`thread_self_c` / `thread_create_c` / `thread_create_with_stack_c` / `thread_join_c`
- 亲和性：`thread_set_affinity_self_c`（调用 `shu_cpu_zero` + `shu_cpu_set`）/ `thread_set_affinity_c`（调用 `shu_cpu_zero` + `shu_cpu_set`）
- QoS：`thread_set_qos_class_self_c`（macOS only）
- 测试入口：`thread_dummy_entry` / `thread_dummy_entry_ptr_c`
- std_thread 转发：`std_thread_thread_self_c` / `std_thread_thread_create_c` / `std_thread_thread_create_with_stack_c` / `std_thread_thread_join_c` / `std_thread_thread_set_affinity_self_c` / `std_thread_thread_set_affinity_c` / `std_thread_thread_set_qos_class_self_c` / `std_thread_thread_dummy_entry_ptr_c`
- 线程池：`thread_set_name_self_c` / `thread_pool_start_c` / `thread_pool_submit_c` / `thread_pool_drain_c` / `thread_pool_stop_c` / `thread_pool_pending_c`

## 4. ABI Manifest
- _impl 残余列表：`shu_cpu_zero_impl`、`shu_cpu_set_impl`
- thin+rest 宏边界：`XLANG_RUNTIME_THREAD_GLUE_FROM_X`
- 前向声明：2 个 thin wrapper（`shu_cpu_zero` / `shu_cpu_set`），rest 模式下供 rest 函数调用
- 内部调用更新：`thread_set_affinity_self_c` / `thread_set_affinity_c` 调用 `shu_cpu_zero` + `shu_cpu_set`（在 `#elif defined(__linux__)` 块内）
- 类型擦除：.x 侧 `shu_cpu_zero`/`shu_cpu_set` 参数为 `*u8`（cpu_set_t 是 Linux 特有类型，.x 无法表达）；seed 侧前向声明与定义用 `cpu_set_t *`，C 链接器只看符号名不看类型，ABI 兼容（均为 64 位指针）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过，macOS 完整流程含 merged.o）
- ld -r：ok（macOS merged 3 T + 2 U `_impl` [Linux only，预期]；Ubuntu merged 28 T/W，U 仅 libc/pthread 符号）
- smoke/probe：pending

## 6. 备注
- IMPL 模式：2 个 thin wrapper 调用对应 `_impl`
- 平台条件：`shu_cpu_zero` / `shu_cpu_set` 及其 `_impl` 都在 `#if defined(__linux__)` 块内（Linux only）；macOS 上不编译 `_impl`，merged.o 有 2 个 U 符号（预期行为，Linux 最终链接时解析）
- 类型擦除：`cpu_set_t` 是 Linux 特有类型，.x 用 `*u8` 擦除；seed 前向声明用 `cpu_set_t *` 与调用处一致，thin.o 实际签名 `uint8_t *`，C 链接器不看类型，ABI 兼容
- 已知预存行为：Linux 上 thin wrapper 为 W（weak）符号——prove_x_o.sh 默认 G05_X_O_WEAK=1，macOS Mach-O 忽略 weak 均为 T。非本次切割引入
- 依赖：libc（memset/__stack_chk_fail）+ pthread（pthread_create/join/attr/mutex/cond/self/setname_np/setaffinity_np）+ macOS `pthread_set_qos_class_self_np`
