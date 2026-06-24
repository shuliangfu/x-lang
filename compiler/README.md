# compiler/ — 编译器实现

本目录为 **shux 编译器** 的源码与构建入口。

- **阶段**：自举前用 **C** 实现（`src/*.c`、`include/*.h`），自举后逐步改为 **.sx**（`src/*.sx`）。
- **产出**：可执行文件 **shux**（.sx 流水线），将 .sx 源码编译为目标码/IR。
- **子目录**：
  - `src/` — 编译器源码（lexer、parser、ast、typeck、ir、codegen、driver）
  - `include/` — C 头文件（若用 C 实现时使用）

### 构建（与根目录 README 一致）

| 场景 | 命令 |
|------|------|
| **首次 / 从零** | `make build-tool` 或 `make first-time`（先链出 **shux-c**，再用其生成 **build_tool**；无需先有带 driver 的完整 shux）。 |
| **日常与自举** | `./build_tool ./shux`（本目录下执行，产出 shux，不依赖 Makefile）。 |

Makefile 仅作从零构建/首次；`make all` 默认同时产出 **shux** 与 **shux-c**。日常推荐仅用 `./build_tool ./shux`。生成 C（pipeline_gen.c / driver_gen.c）后无补丁，由 runtime/codegen 从根源产出。验收：仓库根执行 `./tests/run-all.sh`。

详见项目根目录下 `analysis/architecture.md` 第三章「编译器架构」。

## shux 可执行文件用法（默认 ASM 后端）

产出 `shux` 后，在 PATH 或本目录下直接调用。默认 **ASM 后端**直出机器码；可选 **C 后端**。

| 命令 | 说明 |
|------|------|
| `shux file.sx` | 编译并运行（等同 `shux run file.sx`） |
| `shux build` | 读取当前目录 `build.sx`，编译并运行 `build_runner` |
| `shux build file.sx` | 仅编译，默认产物 `a.out` |
| `shux build file.sx -o exe` | 编译到指定可执行文件 |
| `shux run file.sx` | 编译并运行 |
| `shux -E file.sx` | 输出 C 源码（调试用） |
| `shux -backend c file.sx` | 强制走 C 路径 |
| `shux -O2 file.sx -o app` | 默认 **-O2**；release 推荐 `shux_asm -backend asm -O2` |
| `shux -legacy-f32-abi …` | x86_64 legacy f32 CALL（默认 xmm；见 `docs/F32_XMM_ABI.md`） |
| `shux --help` | 用法摘要 |

更全的子命令表（含 `-backend asm`、`shux fmt` / `check` / `test`）见仓库根目录 `README.md`「shux 编译器用法」。
