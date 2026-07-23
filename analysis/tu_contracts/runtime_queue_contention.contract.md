# TU Contract: runtime_queue_contention

## 1. 当前权威源
- x 源：`src/asm/runtime_queue_contention.x`
- seed 源：`seeds/runtime_queue_contention.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 3 个 IMPL wrapper，seed/rest 提供 3 个 `_impl` + 7 个 rest 函数

## 3. 导出符号合同
- thin/.x 导出：4（doc_anchor + 3 wrapper）
- seed/rest 导出：10（3 `_impl` + 4 mutex 函数 + worker_push + run_two_workers + smoke）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_queue_contention_x_doc_anchor`
- `queue_smoke_at`（IMPL，调用 `_impl`）
- `queue_smoke_push_back`（IMPL，调用 `_impl`）
- `queue_os_worker_trampoline`（IMPL，调用 `_impl`，Unix 版本）

### 3.2 当前仍由 seed/rest 提供
- `queue_smoke_at_impl`（环形队列物理下标计算）
- `queue_smoke_push_back_impl`（队尾插入，调用 `queue_smoke_at` thin wrapper）
- `queue_os_worker_trampoline_impl`（worker 线程入口，Unix 版本；Windows 版本为 static 不导出）
- `queue_contention_worker_push_c`（每 worker push 500 次，调用 `queue_smoke_push_back` thin wrapper）
- `queue_os_mutex_create_c`（创建 mutex）
- `queue_os_mutex_destroy_c`（销毁 mutex）
- `queue_os_mutex_lock_c`（加锁）
- `queue_os_mutex_unlock_c`（解锁）
- `queue_os_run_two_workers_c`（启动两个 worker 线程并 join，取 `queue_os_worker_trampoline` thin wrapper 地址）
- `sync_queue_contention_smoke_c`（双线程并发 push 烟测入口）

## 4. ABI Manifest
- _impl 残余列表：`queue_smoke_at_impl`、`queue_smoke_push_back_impl`、`queue_os_worker_trampoline_impl`
- thin+rest 宏边界：`XLANG_RUNTIME_QUEUE_CONTENTION_FROM_X`
- 前向声明：3 个 thin wrapper（`queue_smoke_at` / `queue_smoke_push_back` / `queue_os_worker_trampoline`），rest 模式下供 rest 函数调用
- 内部调用更新：无（rest 函数调用 thin wrapper 符号，rest 模式下为 U 由 thin.o 解析）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过，macOS 完整流程）
- ld -r：ok（macOS merged 14 T 0 U + Ubuntu merged 10 T + 4 W，U 仅 libc/libpthread）
- smoke/probe：pending

## 6. 备注
- IMPL 模式：3 个 thin wrapper 调用对应 `_impl`
- `queue_smoke_push_back_impl` 内部调用 `queue_smoke_at`（thin wrapper），rest 模式下为 U 由 thin.o 提供
- `queue_contention_worker_push_c` 调用 `queue_smoke_push_back`（thin wrapper），rest 模式下为 U 由 thin.o 提供
- `queue_os_run_two_workers_c` 取 `queue_os_worker_trampoline`（thin wrapper）地址传给 pthread_create/_beginthreadex，rest 模式下为 U 由 thin.o 提供
- 平台条件：`queue_os_worker_trampoline` Windows 版本为 `static unsigned __stdcall`（不导出，不切割）；Unix 版本为 `void *`（导出，切割为 `_impl` + thin wrapper）。thin wrapper 在 `#else`（非 Windows）块内
- 已知预存行为：所有 4 个 thin wrapper 在 Linux 上为 W（weak）符号——xlang-c 编译器对 `#[no_mangle]` 属性处理不完整（3 个 wrapper 有 `#[no_mangle]` 但 gen.c 仍标记 weak；doc_anchor 无 `#[no_mangle]` 故 weak 正确）。macOS Mach-O 不支持 weak，均为 T 符号。非本次切割引入
- 依赖：pthread（Unix）/ Win32（Windows）；malloc/free/memset（libc）
