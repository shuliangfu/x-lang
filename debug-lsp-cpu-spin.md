# Debug Session: lsp-cpu-spin [OPEN]

## 用户症状
- `ubuntu-server` 上运行 `./shux.good --lsp` 后 CPU 近满载，导致风扇狂转。
- 手动 `kill` 该进程后负载恢复正常。

## 当前约束
- 步骤 1-4 不修改业务逻辑。
- 先收集运行时证据，再判断根因。

## 可证伪假设
1. `--lsp` 主循环在 EOF/读失败后没有阻塞，进入 busy loop。
2. LSP 空闲态仍持续触发诊断/解析工作，导致无输入时高 CPU。
3. `io_read`/timeout 路径在 Linux 上立刻返回，循环没有 sleep/backoff。
4. 仅 `shux.good` 命中，说明是构建链或桥接差异，不是所有 `--lsp` 都会复现。

## 证据计划
- 远端复现 `./shux.good --lsp` 的 CPU 行为。
- 用 `strace`/`ps`/`top` 级证据确认是否在 `read/poll` 空转。
- 对照仓库中的 LSP 主循环与 `io_read` 实现。

## 当前状态
- 已采集到运行时证据，确认问题存在。

## 已采集证据
- 远端执行 `timeout 3 ./shux.good --lsp </dev/null` 会立刻退出，说明 EOF 路径本身不是死循环。
- 远端执行 `tail -f /dev/null | ./shux.good --lsp` 时，`ps` 观察到进程 CPU 持续约 49%~89%。
- 线程级 `ps -L` 结果显示：
  - 主线程：`futex_do_wait`
  - 一条线程：`io_cqring_wait`
  - 一条线程：`io_sq_thread`，CPU 约 49.5%
- 这说明高 CPU 不是主线程 `lsp_main_impl()` 直接自旋，而是 `io_uring` 的 SQPOLL 线程在空闲态持续占用 CPU。

## 假设结论
1. `--lsp` 主循环在 EOF/读失败后忙等：
   - 否。EOF 下 `./shux.good --lsp </dev/null` 直接退出。
2. LSP 空闲态仍持续触发诊断/解析：
   - 暂无证据支持为主因。高 CPU 线程不在主线程，而在 `io_sq_thread`。
3. `io_read`/timeout 路径立即返回导致自旋：
   - 暂无直接 syscall 证据，但现象不符合主线程自旋，更像 runtime/io 初始化带起的 polling 线程。
4. 构建链或 bridge 差异导致：
   - 部分成立。`shux.good` 链入了 `liburing`，并带有 `SHUX_IO_URING_SQPOLL` 相关字符串；问题与其 runtime/io 初始化路径强相关。

## 当前判断
- 根因大概率不在 LSP 请求处理本身，而在 `shux.good --lsp` 进程空闲运行时仍启用了 `io_uring` SQPOLL 路径。
- 需要继续定位 runtime/io 初始化里谁在默认拉起 SQPOLL，以及为什么 LSP 进程未禁用该路径。
