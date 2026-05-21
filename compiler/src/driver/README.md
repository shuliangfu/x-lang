# driver/ — 编译器驱动（命令入口说明）

**职责**：解析命令行、串联 lexer → parser → typeck → codegen、多文件与 `build.su` 项目构建、链接与运行。默认 **ASM 后端**直出机器码。

**实现位置**：程序入口与驱动编排在 **`src/main.su`**（自举后与 C 侧 `main.c` 对应）；C 侧仅保留极简 `main()` 调用 `main_entry()`；通用运行时逻辑在 **`src/runtime.c`**。

## 子命令与默认行为

| 形式 | 行为 |
|------|------|
| `shu build` | 无源文件参数时：读取当前目录 **`build.su`**，编译并运行 **`build_runner`**（项目级构建脚本）。 |
| `shu build file.su` | 仅编译；默认输出 **`a.out`**。 |
| `shu build file.su -o exe` | 仅编译到指定可执行文件。 |
| `shu run file.su` | 编译并运行给定源文件。 |
| `shu file.su` | 无子命令时：与 **`shu run file.su`** 相同（编译并运行）。 |
| `shu fmt` | **未实现**：[`fmt.su`](fmt.su) 定义 `cmd_fmt`（链接符号 `driver_cmd_fmt`），经 `-E-extern` → `driver_fmt_su.o`。 |
| `shu check` | **未实现**：[`check.su`](check.su) 定义 `cmd_check` → `driver_cmd_check`。 |
| `shu test` | **未实现**：[`test.su`](test.su) 定义 `cmd_test` → `driver_cmd_test`。 |

**模块前缀约定**：`src/driver/*.su` 内函数名不要重复写 `driver_` 前缀（与 [`run.su`](run.su) 中 `exec_compiled` → `driver_exec_compiled` 相同）；否则 `-E-extern` 会生成 `driver_driver_*` 导致链接失败。

调试输出 C 与后端切换（`-E`、`-backend asm` / `-backend c`）见仓库根目录 **`README.md`**「shu 编译器用法」表。
