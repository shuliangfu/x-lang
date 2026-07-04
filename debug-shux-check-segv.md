# [OPEN] Debug Session: shux-check-segv

## 背景

- 目标：定位 `ubuntu-server` 上 `./compiler/shux-c check ...` 的 `SIGSEGV` 根因。
- 现象：
  - `./compiler/shux-c check -L . tests/memory-contract/arena_align.x` 崩溃
  - `./compiler/shux-c check -L ../.. std/sys/mod.x` 崩溃
  - `./compiler/shux-c check -L ../.. std/path/mod.x` 崩溃
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
- `gdb` 调用栈在 `arena_align.x` 与 `std/sys/mod.x` 上一致收敛到：
  - `driver_check_set_current_file()`
  - `check_one_file()`
  - `driver_run_compiler_check()`
  - `driver_cmd_check()`
- 崩溃点位于 `driver_check_set_current_file()` 内对 `s_check_current_file` 的 `snprintf(...)` 调用。
- `s_check_current_file` 位于可写 `.bss`，进入函数前缓冲区内容全 0，说明不是缓冲区提前被踩坏。
- 远端 `compiler/shux.good` 对相同输入不会 `SIGSEGV`，而是正常返回 `check failed: <path>`。
- 远端 `compiler/bootstrap_shuxc`、`compiler/shux-c` 与 `compiler/seeds/bootstrap_shuxc.linux.x86_64` 字节完全一致。
- 远端 `compiler/seeds/bootstrap_shuxc.linux.x86_64` 满足当前脚本的 `-h` 可运行判据，但在：
  - `check -L .. /tmp/canrun.x`
  - `-c /tmp/canrun.x`
  两条路径上都会直接 `SIGSEGV`。
- 本地修复并刷新 Linux tracked seed 后，远端 `check` 路径已恢复：
  - `compiler/seeds/bootstrap_shuxc.linux.x86_64 check -L . /tmp/canrun.x` 不再崩溃，仅正常返回 `check failed`
- 但 `V6` fresh seed smoke 仍在真实 Linux 上失败，且已收敛到新的固定崩点：
  - `./compiler/shux-c -c /tmp/v6_smoke.x`
  - `gdb` 栈：
    - `driver_argv_collect_defines()`
    - `driver_run_asm_backend()`
    - `driver_run_asm_backend_impl_c()`
    - `driver_run_compiler_full_x_post_parse_impl_c()`
  - 具体在 `snprintf(shu_os_def, sizeof shu_os_def, "SHUX_OS_%s", u.sysname)` 处 `SIGSEGV`
- 同一台真实 Linux 上，`./compiler/shux.good -c /tmp/v6_smoke.x` 正常返回 0。
- 这说明：
  - 真实 Linux 确实暴露了当前 `shux-c` 二进制在 `-c` 路径上的额外崩溃；
  - 但不是“这台 Linux 环境普遍有问题”，因为同机 `shux.good` 正常。
- 对 `V6` 继续下钻后发现：
  - `./compiler/shux.good -backend c -o /tmp/good_v6_bin /tmp/v6_smoke.x` 在真实 Linux 上几乎未进入读文件/cc 阶段；
  - `gdb` 显示执行链到 `main_run_compiler_x_path_impl()` → `main_run_compiler_c()` → `driver_run_compiler_full()` → `driver_run_compiler_full_su()`；
  - `driver_compile_parse_argv()` 返回 `1`，且 `driver_compile_argv_copy_path_c()` 根本未被调用；
  - `driver_compile_parse_argv_finalize()` 的失败条件收敛为 `state->path_len <= 0`；
  - 进一步反汇编 `driver_path_ends_su()` 可见其末字节仅比较 `0x75`（`'u'`），即当前 seed / `shux.good` 二进制只识别 `.su`，不识别 `.x`。
- 当前仓库源码 [`compile.x`](file:///home/shu/shux/compiler/src/driver/compile.x) 中 `path_ends_x()` 已允许 `'u'` 或 `'x'`，说明问题已从“源码逻辑错误”收敛为“当前 Linux seed / shux.good 二进制落后于源码，仍携带旧的 `.su` only 实现”。

## 假设验证状态

| ID | 假设 | 状态 | 证据摘要 |
|----|------|------|----------|
| 1 | 导入解析阶段存在空指针或空路径访问 | ❌ 否 | 多个入口统一崩在 `driver_check_set_current_file()`，早于模块级 typeck 细节。 |
| 2 | `shux-c` 与当前源码/seed 产物 ABI 漂移，导致运行时读错结构 | ✅ 是 | 当前被选中的 tracked seed 二进制固定崩溃，而 `shux.good` 不崩。 |
| 3 | `check` 专属路径初始化缺失 | ✅ 部分成立 | 崩溃仅稳定出现在 `check` / `-c` 热路径，`-h` 仍可通过。 |
| 4 | 服务器环境触发平台相关 UB | ❌ 否 | 安装工具链后仍复现；同机上 `shux.good` 正常工作。 |
| 5 | 公共依赖模块递归导入破坏内存 | ❌ 否 | 最小 `/tmp/canrun.x` 也能稳定触发坏 seed 的 `check/-c` 崩溃。 |

## 当前结论

- 当前主阻塞不是具体业务源码 `arena_align.x` / `std/sys` / `std/path` 本身。
- 根因是：仓库当前 Linux tracked seed `compiler/seeds/bootstrap_shuxc.linux.x86_64` 本身坏掉，被复制为 `bootstrap_shuxc` / `shux-c` 后进入 `check` 与 `-c` 路径即崩。
- 当前 `select_bootstrap_shuxc.sh` 的 `can_run()` 判据偏弱：`-h` / `--help` / `-E` 可以通过，但不足以发现 `check/-c` 路径已坏。
- 第一层根因修复后，真实 Linux 继续暴露出第二层问题：
  - 当前 `compiler/shux-c` 的 `-c` 路径在 `driver_argv_collect_defines()` 上仍会崩溃；
  - 同机 `shux.good` 正常，说明更像“当前生成产物错误/潜在 UB 被真实 Linux 触发”，而不是纯环境缺陷。
- 再进一步确认后，`V6` 的核心失败已改写为：
  - stale `shux-c/bootstrap_shuxc` 会在 `-c` 路径崩溃；
  - fresh seed / `shux.good` 不再崩溃，但因仍携带旧版 `driver_path_ends_su()`，`-backend c -o *.x` 时无法识别 `.x` 输入路径，静默返回 1。

## 下一步

- 在本地仓库制定修复方案：
  1. 强化 seed 选择/验活判据，避免坏 seed 仅凭 `-h` 被接受。
  2. 正式刷新 Linux tracked seed，替换当前坏掉的 `compiler/seeds/bootstrap_shuxc.linux.x86_64`。
- 修复动作只在本地进行；提交并推送后，再让 `ubuntu-server` 拉取最新代码复验。
- 下一调试目标：
  1. 修正本地 seed 选择脚本的 smoke 判据，恢复远端重建能力；
  2. 在真实 Linux 上用当前源码重建新编译器，验证新产物是否已包含 `path_ends_x(.x)` 修复；
  3. 若验证通过，再正式刷新 Linux tracked seed，并继续回到 `L9/S7/V7` 真实阻塞面。
