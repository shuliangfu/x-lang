# [OPEN] Debug Session: shux-check-segv

## 背景

- 目标：定位 `ubuntu-server` 上 `./compiler/shux-c check ...` 的 `SIGSEGV` 根因。
- 现象：
  - `./compiler/shux-c check -L . tests/memory-contract/arena_align.sx` 崩溃
  - `./compiler/shux-c check -L ../.. std/sys/mod.sx` 崩溃
  - `./compiler/shux-c check -L ../.. std/path/mod.sx` 崩溃
- 环境：
  - 服务器：`ubuntu-server`
  - 项目路径：`/home/shuliangfu/worker/shu/shux`
  - 当前工具链：`cc/gcc/clang/make` 已安装

## 假设

1. 导入解析阶段存在空指针或空路径访问，多个入口只是复现同一崩溃点。
2. `shux-c` 与当前源码/seed 产物 ABI 漂移，导致 AST 或 typeck 结构读取越界。
3. `check` 专属路径存在初始化缺失，诊断或模块缓存状态未构造即被访问。
4. 服务器环境触发平台相关 UB，例如未初始化内存、栈布局或对齐问题。
5. 公共依赖模块在递归导入或符号表构建时破坏内存，多个入口统一表现为 `SIGSEGV`。

## 已获证据

- `run-checklist-fast.sh` 在 `§3 L9`、`§4 S7` 上失败。
- 直接执行 `shux-c check` 时，stderr 显示 `段错误（核心已转储）`。
- `gdb` 调用栈在 `arena_align.sx` 与 `std/sys/mod.sx` 上一致收敛到：
  - `driver_check_set_current_file()`
  - `check_one_file()`
  - `driver_run_compiler_check()`
  - `driver_cmd_check()`
- 崩溃点位于 `driver_check_set_current_file()` 内对 `s_check_current_file` 的 `snprintf(...)` 调用。
- `s_check_current_file` 位于可写 `.bss`，进入函数前缓冲区内容全 0，说明不是缓冲区提前被踩坏。
- 远端 `compiler/shux.good` 对相同输入不会 `SIGSEGV`，而是正常返回 `check failed: <path>`。
- 远端 `compiler/bootstrap_shuxc`、`compiler/shux-c` 与 `compiler/seeds/bootstrap_shuxc.linux.x86_64` 字节完全一致。
- 远端 `compiler/seeds/bootstrap_shuxc.linux.x86_64` 满足当前脚本的 `-h` 可运行判据，但在：
  - `check -L .. /tmp/canrun.sx`
  - `-c /tmp/canrun.sx`
  两条路径上都会直接 `SIGSEGV`。

## 假设验证状态

| ID | 假设 | 状态 | 证据摘要 |
|----|------|------|----------|
| 1 | 导入解析阶段存在空指针或空路径访问 | ❌ 否 | 多个入口统一崩在 `driver_check_set_current_file()`，早于模块级 typeck 细节。 |
| 2 | `shux-c` 与当前源码/seed 产物 ABI 漂移，导致运行时读错结构 | ✅ 是 | 当前被选中的 tracked seed 二进制固定崩溃，而 `shux.good` 不崩。 |
| 3 | `check` 专属路径初始化缺失 | ✅ 部分成立 | 崩溃仅稳定出现在 `check` / `-c` 热路径，`-h` 仍可通过。 |
| 4 | 服务器环境触发平台相关 UB | ❌ 否 | 安装工具链后仍复现；同机上 `shux.good` 正常工作。 |
| 5 | 公共依赖模块递归导入破坏内存 | ❌ 否 | 最小 `/tmp/canrun.sx` 也能稳定触发坏 seed 的 `check/-c` 崩溃。 |

## 当前结论

- 当前主阻塞不是具体业务源码 `arena_align.sx` / `std/sys` / `std/path` 本身。
- 根因是：仓库当前 Linux tracked seed `compiler/seeds/bootstrap_shuxc.linux.x86_64` 本身坏掉，被复制为 `bootstrap_shuxc` / `shux-c` 后进入 `check` 与 `-c` 路径即崩。
- 当前 `select_bootstrap_shuxc.sh` 的 `can_run()` 判据偏弱：`-h` / `--help` / `-E` 可以通过，但不足以发现 `check/-c` 路径已坏。

## 下一步

- 在本地仓库制定修复方案：
  1. 强化 seed 选择/验活判据，避免坏 seed 仅凭 `-h` 被接受。
  2. 正式刷新 Linux tracked seed，替换当前坏掉的 `compiler/seeds/bootstrap_shuxc.linux.x86_64`。
- 修复动作只在本地进行；提交并推送后，再让 `ubuntu-server` 拉取最新代码复验。
