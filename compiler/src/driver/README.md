# driver/ — 编译器驱动（命令入口说明）

**职责**：解析命令行、串联 lexer → parser → typeck → codegen、多文件与 `build.sx` 项目构建、链接与运行。默认 **ASM 后端**直出机器码。

**实现位置**：程序入口与驱动编排在 **`src/main.sx`**（自举后与 C 侧 `main.c` 对应）；C 侧仅保留极简 `main()` 调用 `main_entry()`；通用运行时逻辑在 **`src/runtime.c`**。

## 子命令与默认行为

| 形式 | 行为 |
|------|------|
| `shux build` | 无源文件参数时：读取当前目录 **`build.sx`**，编译并运行 **`build_runner`**（项目级构建脚本）。 |
| `shux build file.sx` | 仅编译；默认输出 **`a.out`**。 |
| `shux build file.sx -o exe` | 仅编译到指定可执行文件。 |
| `shux run file.sx` | 编译并运行给定源文件。 |
| `shux file.sx` | 无子命令时：与 **`shux run file.sx`** 相同（编译并运行）。 |
| `shux fmt [path...]` | **已实现**（对标 `deno fmt`）：无路径时递归当前目录 `*.sx`；**仅在实际写回时**打印 `fmt OK: path`，已规范文件无输出；`SHUX_FMT_VERBOSE=1` 可打印统计。 |
| `shux fmt --check [path...]` | **已实现**（对标 `deno fmt --check`）：不写回；全通过时**无输出** exit 0；否则列出未格式化文件并 exit 1。支持 `--fail-fast`、`--ignore=子串`。 |
| `shux check [path...]` | **已实现**（对标 `deno check`）：**无路径时递归产品目录**（`compiler/src`、`core`、`std`、`examples`）；多文件/目录；**全通过时无输出**；失败为 `path:line:col - error: msg`；warning/info 为 `- warning:` / `- info:`；支持 `-L`、`--ignore=`、`--fail-fast`；`SHUX_PAD_FIELDS`/`SHUX_HOT_REORDER`/`SHUX_UNUSED_HINT` 环境开关；`SHUX_LINT_CI_FAIL_ON=warn` 令 warning 也失败。 |
| `shux test [script.sh]` | **已实现**：[`test.sx`](test.sx) 定义 `cmd_test` → `driver_cmd_test`；默认执行 `tests/run-all.sh`，可指定脚本路径。 |

**模块前缀约定**：`src/driver/*.sx` 内函数名不要重复写 `driver_` 前缀（例如 `cmd_check` → `driver_cmd_check`）。**例外**：根目录另有 `build.sx` 时，`src/driver/build.sx` 的模块前缀为 `build_`（`cmd_build` → `build_cmd_build`），`main.sx` 须 `extern build_cmd_build`。C 侧 `extern` 须写全链接名（如 `driver_exec_compiled`）。

调试输出 C 与后端切换（`-E`、`-backend asm` / `-backend c`）见仓库根目录 **`README.md`**「shux 编译器用法」表。

## 常用编译开关

| 开关 | 说明 |
|------|------|
| `-O2` | **默认**优化级别（release 推荐 `shux_asm -backend asm -O2`） |
| `-legacy-f32-abi` | x86_64 SysV legacy f32 实/形参（f64 widen）；默认 xmm ABI，等价 `SHUX_ABI_F32_XMM=0` |
| `-freestanding` | Linux x86_64 ELF nostdlib 静态链 |
| `-h` / `--help` | 打印用法摘要（`driver_print_usage_c`） |

f32 ABI 与 legacy 弃用时间表见 **`compiler/docs/F32_XMM_ABI.md`**。
