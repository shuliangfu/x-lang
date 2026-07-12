# TU Contract: runtime_asm_io_stubs

## 1. 当前权威源
- x 源：`src/asm/runtime_asm_io_stubs.x`（G-02f-20 文档锚点 + G-02f-100 门闩）
- seed 源：`seeds/runtime_asm_io_stubs.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 3 个 IMPL wrapper + 1 doc_anchor，seed/rest 提供 3 个 `_impl` + 38 个 rest 函数

## 3. 导出符号合同
- thin/.x 导出：4（doc_anchor + 3 IMPL wrapper）
- seed/rest 导出：41（3 `_impl` + 38 个 io/std_io/shux_io/io_uring 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_asm_io_stubs_x_doc_anchor`（only_x）
- `seed_io_syscall_write`（IMPL，调用 `_impl`，Linux x86_64 only）
- `seed_io_syscall_read`（IMPL，调用 `_impl`，Linux x86_64 only）
- `seed_io_write_fd1`（IMPL，调用 `_impl`，跨平台）

### 3.2 当前仍由 seed/rest 提供
- `seed_io_syscall_write_impl`（Linux x86_64 裸 syscall write，inline asm）
- `seed_io_syscall_read_impl`（Linux x86_64 裸 syscall read，inline asm）
- `seed_io_write_fd1_impl`（stdout 写，调用 `io_write`）
- io 读写：`io_write` / `io_read` / `io_read_ptr` / `io_read_ptr_len` / `io_register_buffer`
- shux_io 注册：`shux_io_register` / `shux_io_register_buf` / `shux_io_submit_read` / `shux_io_submit_write`
- std_io 句柄：`std_io_handle_stdin` / `std_io_handle_stdout` / `std_io_handle_stderr`
- std_io 读写：`std_io_write` / `std_io_read`
- std_io 打印：`std_io_print_i32` / `std_io_print_u32` / `std_io_print_i64` / `std_io_write_stdout`(W) / `std_io_write_with_timeout`(W) / `std_io_print_u8_ptr_usize`(W) / `std_io_print_str`(W)
- fmt/print：`std_fmt_println` / `print_str`
- stdin 读：`std_io_read_stdin_ptr` / `std_io_ptr_len` / `std_io_read_ptr_len` / `std_io_read_stdin_ptr_slice` / `std_io_read_ptr_slice`
- 批量 io：`io_read_batch` / `io_write_batch` / `io_read_batch_buf` / `io_write_batch_buf` / `io_read_batch_provided`(W)
- io_uring 弱桩：`io_uring_connect`(W) / `io_uring_accept`(W) / `io_uring_accept_many`(W) / `io_uring_connect_many`(W) / `io_uring_prefetch_fd`(W)

## 4. ABI Manifest
- _impl 残余列表：`seed_io_syscall_write_impl`、`seed_io_syscall_read_impl`、`seed_io_write_fd1_impl`
- DIRECT 符号列表：（无）
- thin+rest 宏边界：`SHUX_RUNTIME_ASM_IO_STUBS_FROM_X`
- 前向声明：3 个 thin wrapper（`seed_io_syscall_write` / `seed_io_syscall_read` / `seed_io_write_fd1`），rest 模式下供 rest 函数调用
- 内部调用更新：
  - `io_write` 调用 `seed_io_syscall_write`（IMPL thin wrapper，Linux x86_64 分支）
  - `io_read` 调用 `seed_io_syscall_read`（IMPL thin wrapper，Linux x86_64 分支）
  - `std_io_write_stdout`(W) / `std_io_write_with_timeout`(W) 调用 `seed_io_write_fd1`（IMPL thin wrapper）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过，macOS 完整流程含 merged.o）
- ld -r：ok（macOS merged 4 x_symbols + 1 _impl + 2 U `_impl` [Linux only 预期] + rest + libc U；Ubuntu merged 53 T/W [含 #include runtime_net_udp_batch 的 8 个函数]，U 仅 libc/网络库符号）
- smoke/probe：pending

## 6. 备注
- 纯 IMPL 模式：3 个 IMPL wrapper（全部调用对应 `_impl`）
- 平台条件：`seed_io_syscall_write` / `seed_io_syscall_read` 及其 `_impl` 仅在 `#if defined(__linux__) && defined(__x86_64__)` 块内定义（Linux x86_64 only）；wrapper 也仅在该平台 emit。macOS merged 有 2 U `_impl`（Linux only 预期，与 runtime_thread_glue 模式一致）
- `seed_io_write_fd1` 跨平台：`_impl` 调用 `io_write`，wrapper 用 `#ifndef` 保护
- seed 末尾 `#include "runtime_net_udp_batch.from_x.c"`（Linux glibc only）引入 8 个额外函数（4 impl + 4 wrapper），这些是 runtime_net_udp_batch TU 的符号，不计入本 TU 合同
- 已知预存行为：Linux 上 thin wrapper 为 W（weak）符号——prove_x_o.sh 默认 G05_X_O_WEAK=1，macOS Mach-O 忽略 weak 均为 T。非本次切割引入
- 依赖：libc（printf/read/write/__errno_location/__stack_chk_fail），网络库（htonl/htons/ntohl/ntohs/poll/recvmmsg/sendmmsg，来自 #include runtime_net_udp_batch）
