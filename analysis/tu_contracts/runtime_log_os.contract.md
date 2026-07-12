# TU Contract: runtime_log_os

## 1. 当前权威源
- x 源：`src/asm/runtime_log_os.x`（G-02f-19 文档锚点 + G-02f-105/112 门闩）
- seed 源：`seeds/runtime_log_os.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 7 个 IMPL wrapper + 1 doc_anchor，seed/rest 提供 7 个 `_impl` + 12 个 rest 函数

## 3. 导出符号合同
- thin/.x 导出：8（doc_anchor + 7 IMPL wrapper）
- seed/rest 导出：19（7 `_impl` + 12 个 log_*_c 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_log_os_x_doc_anchor`（only_x）
- `log_apply_env_once`（IMPL，调用 `_impl`）
- `log_do_rotate`（IMPL，调用 `_impl`）
- `log_write_file_sync`（IMPL，调用 `_impl`）
- `log_write_sync`（IMPL，调用 `_impl`）
- `log_async_enqueue`（IMPL，调用 `_impl`）
- `log_emit_bytes`（IMPL，调用 `_impl`）
- `log_write_fd`（IMPL，调用 `_impl`，平台条件 Windows `_write` / POSIX `write`）

### 3.2 当前仍由 seed/rest 提供
- `log_write_fd_impl`（平台条件写 fd：Windows `_write` / POSIX `write`）
- `log_apply_env_once_impl`（首次读取 SHUX_LOG_MIN_LEVEL 环境变量）
- `log_do_rotate_impl`（文件轮转，调用 `log_close_file_sink_c`）
- `log_write_file_sync_impl`（同步写文件 sink，调用 `log_do_rotate` + `log_write_fd`）
- `log_write_sync_impl`（同步写所有活跃 sink，调用 `log_write_fd` + `log_write_file_sync`）
- `log_async_enqueue_impl`（入队异步缓冲，调用 `log_async_flush_c`）
- `log_emit_bytes_impl`（写一行，调用 `log_async_enqueue` 或 `log_write_sync`）
- 配置：`log_set_min_level_c` / `log_set_sink_mask_c` / `log_set_file_sink_c` / `log_close_file_sink_c` / `log_set_rotate_c` / `log_set_async_enabled_c`
- 刷出：`log_async_flush_c`（调用 `log_write_sync`）
- 导出桥：`log_apply_env_once_c`（调用 `log_apply_env_once`）/ `log_get_min_level_c`（调用 `log_apply_env_once`）/ `log_emit_bytes_c`（调用 `log_emit_bytes`）
- 烟测：`log_multi_sink_smoke_c` / `log_rotate_async_smoke_c`

## 4. ABI Manifest
- _impl 残余列表：`log_write_fd_impl`、`log_apply_env_once_impl`、`log_do_rotate_impl`、`log_write_file_sync_impl`、`log_write_sync_impl`、`log_async_enqueue_impl`、`log_emit_bytes_impl`
- DIRECT 符号列表：（无）
- thin+rest 宏边界：`SHUX_RUNTIME_LOG_OS_FROM_X`
- 前向声明：7 个 thin wrapper（`log_write_fd` / `log_do_rotate` / `log_write_file_sync` / `log_write_sync` / `log_async_enqueue` / `log_apply_env_once` / `log_emit_bytes`），rest 模式下供 rest 函数调用
- 内部调用更新：
  - `log_write_file_sync_impl` 调用 `log_do_rotate` + `log_write_fd`（IMPL thin wrapper）
  - `log_write_sync_impl` 调用 `log_write_fd` + `log_write_file_sync`（IMPL thin wrapper）
  - `log_async_enqueue_impl` 调用 `log_async_flush_c`（rest 函数）
  - `log_emit_bytes_impl` 调用 `log_async_enqueue` + `log_write_sync`（IMPL thin wrapper）
  - `log_async_flush_c` 调用 `log_write_sync`（IMPL thin wrapper）
  - `log_apply_env_once_c` / `log_get_min_level_c` 调用 `log_apply_env_once`（IMPL thin wrapper）
  - `log_emit_bytes_c` 调用 `log_emit_bytes`（IMPL thin wrapper）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过，macOS 完整流程含 merged.o）
- ld -r：ok（macOS merged 8 x_symbols + 7 _impl + 12 rest + doc_anchor；Ubuntu merged 27 T/W，U 仅 libc + log_write_c/log_write_structured_kv_c 外部 TU 依赖）
- smoke/probe：pending

## 6. 备注
- 纯 IMPL 模式：7 个 IMPL wrapper（全部调用对应 `_impl`）
- `log_write_fd` 平台条件处理：seed 中 Windows（`_write`）和 POSIX（`write`）两个分支各有一个 `log_write_fd_impl` 定义（编译时仅一个生效），wrapper 在 `#endif` 之后统一一次 `#ifndef` 保护
- 类型擦除：.x 侧 `log_write_fd` 签名 `(fd: i32, buf: *u8, n: i64): i64`，seed 签名 `(int fd, const void *buf, size_t len): int`（返回值 int vs i64，参数 size_t vs i64）；C 链接器不看类型，ABI 兼容
- 已知预存行为：Linux 上 thin wrapper 为 W（weak）符号——prove_x_o.sh 默认 G05_X_O_WEAK=1，macOS Mach-O 忽略 weak 均为 T。非本次切割引入
- 依赖：外部 TU `log_write_c` / `log_write_structured_kv_c`（log.x），libc（atoi/getenv/open/close/write/...）
