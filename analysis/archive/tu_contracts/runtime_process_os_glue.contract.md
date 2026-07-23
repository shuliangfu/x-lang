# TU Contract: runtime_process_os_glue

## 1. 当前权威源
- x 源：`src/asm/runtime_process_os_glue.x`（G-02f-18 文档锚点 + G-02f-103 门闩）
- seed 源：`seeds/runtime_process_os_glue.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 2 个 IMPL wrapper + 1 doc_anchor，seed/rest 提供 2 个 `_impl` + 19 个 rest 函数

## 3. 导出符号合同
- thin/.x 导出：3（doc_anchor + 2 wrapper）
- seed/rest 导出：21（2 `_impl` + 19 个 process_*_c 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_process_os_glue_x_doc_anchor`
- `process_nop_sigchld`（IMPL，调用 `_impl`，POSIX only）
- `process_dup_stdio_posix`（IMPL，调用 `_impl`，POSIX only）

### 3.2 当前仍由 seed/rest 提供
- `process_nop_sigchld_impl`（空 SIGCHLD handler，POSIX only）
- `process_dup_stdio_posix_impl`（dup2 stdio 重定向，POSIX only）
- `process_getenv_c` / `process_setenv_c` / `process_unsetenv_c`（环境变量）
- `process_getpid_c` / `process_getppid_c`（进程 ID）
- `process_getcwd_c` / `process_getcwd_ptr_c` / `process_getcwd_cached_len_c` / `process_chdir_c`（工作目录，含缓存）
- `process_self_exe_path_c` / `process_self_exe_path_ptr_c` / `process_self_exe_path_cached_len_c`（可执行路径，含缓存）
- `process_spawn_c` / `process_spawn_simple_c` / `process_spawn_io_c`（子进程创建，调用 `process_nop_sigchld` + `process_dup_stdio_posix`）
- `process_exec_c` / `process_exec_simple_c`（进程替换）
- `process_waitpid_c`（等待子进程）
- `process_pipe_c`（创建管道）

## 4. ABI Manifest
- _impl 残余列表：`process_nop_sigchld_impl`、`process_dup_stdio_posix_impl`
- thin+rest 宏边界：`XLANG_RUNTIME_PROCESS_OS_GLUE_FROM_X`
- 前向声明：2 个 thin wrapper（`process_nop_sigchld` / `process_dup_stdio_posix`），rest 模式下供 rest 函数调用
- 内部调用更新：`process_spawn_c` 取 `process_nop_sigchld` 地址传给 `signal()`；`process_spawn_io_c` 调用 `process_nop_sigchld` + `process_dup_stdio_posix`

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过，macOS 完整流程含 merged.o）
- ld -r：ok（macOS merged 完整符号集；Ubuntu merged 24 T/W，U 仅 libc/POSIX 符号）
- smoke/probe：pending

## 6. 备注
- IMPL 模式：2 个 thin wrapper 调用对应 `_impl`
- 平台条件：两个 thin wrapper 和 `_impl` 都在 `#if !defined(_WIN32) && !defined(_WIN64)` 块内（POSIX only）；Windows 下不编译，不切割
- `process_nop_sigchld` 被 `signal(SIGCHLD, process_nop_sigchld)` 取地址（函数指针），rest 模式下为 U 由 thin.o 提供
- `process_dup_stdio_posix` 被 `process_spawn_io_c` 直接调用，rest 模式下为 U 由 thin.o 提供
- 已知预存行为：Linux 上 thin wrapper 为 W（weak）符号——prove_x_o.sh 默认 G05_X_O_WEAK=1，macOS Mach-O 忽略 weak 均为 T。非本次切割引入
- 依赖：libc（getenv/setenv/unsetenv/getpid/getppid/getcwd/chdir/fork/execve/waitpid/pipe/dup2/signal/readlink）+ macOS `_NSGetExecutablePath`
