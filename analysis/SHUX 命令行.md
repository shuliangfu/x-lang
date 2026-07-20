# SHUX CLI 子命令化改造分析

> **文档目的**：评估将 `shux` 命令行从「隐式推断」改为「强制子命令」的可行性、爆炸半径与迁移路径。
>
> **最后更新**：2026-07-20

---

## 1. 当前 CLI 形式（`shux --help` 实测）

```
Usage:
  shux [options] file.x          compile and run        ← 隐式（要删）
  shux build [file.x] [-o exe]   compile (default a.out)
  shux run file.x                compile and run
  shux check [paths...]           parse + typeck only
  shux fmt [--check] [paths...]   format .x sources
  shux explain <CODE>             explain a diagnostic code
  shux test [script.sh]           run test script

Common options:
  -backend asm|c    backend (default asm)
  -O <0|1|2|3|s>    optimization (default 2)
  -o <path>         output binary or .o
  -L <dir>          library search path
  -target <triple>  target (e.g. aarch64-linux-gnu)
  -target-cpu <cpu> native|generic|avx2|...
  --print-target-cpu  print host CPU features and exit
  --explain <CODE>  print diagnostic code explanation and exit
  -freestanding     nostdlib static link (Linux x86_64 ELF)
  -legacy-f32-abi   legacy SysV f32 CALL (f64 widen; default xmm ABI)
  -E                emit C (debug)
  -flto             link-time optimization (C backend)
  -h, --help        show this help

Environment:
  SHUX_ABI_F32_XMM=0  same as -legacy-f32-abi (x86_64 SysV)
  SHUX_OPT            default -O level if omitted

Release default: shux_asm -backend asm -O2 (f32 xmm ABI on unless legacy).
```

**当前三类入口**：

| 形式 | 语义 | 示例 |
|------|------|------|
| `shux file.x` | 编译并运行（隐式） | `shux main.x` |
| `shux [options] file.x` | 编译（隐式，有 `-o` 时）或运行 | `shux -backend asm -o out.o main.x` |
| `shux <subcmd> ...` | 显式子命令 | `shux build main.x -o out` |

---

## 2. 改造目标

**强制子命令模式**，删除所有隐式入口：

- ❌ 禁止 `shux file.x`（隐式运行）
- ❌ 禁止 `shux --参数 file.x`（隐式编译）
- ✅ 编译必须用 `shux build file.x [-o exe]`
- ✅ 运行 `.x` 源文件必须用 `shux run file.x`
- ✅ 其他子命令（`check` / `fmt` / `explain` / `test`）保持不变

无子命令时输出错误并退出：
```
Error: missing subcommand. Use 'shux build ...', 'shux run ...', 'shux check ...', 'shux fmt ...', 'shux explain ...', or 'shux test ...'.
```

---

## 3. 改造价值

### 3.1 语义清晰

`shux file.x` 当前歧义：到底是「编译」还是「解释执行」？强制子命令后，`build` 与 `run` 职责分离，CLI 成为纯路由层。

### 3.2 启动路径唯一化

`shux run` 可建立独立的极简入口（零 libc 加载器），跳过 Linker 与 File I/O，直接 `Backend → PROT_EXEC 内存 → 执行`。`shux build` 专注代码生成，不耦合运行时逻辑。

### 3.3 符合现代编译工具链惯例

`cargo build/run`、`go build/run`、`rustc`、`zig build/run` 均采用显式子命令。SHUX 对齐主流。

### 3.4 错误更早暴露

裸 `shux file.x` 打错参数时仍可能「误打误撞」走隐式路径；强制子命令后参数错误立即报错。

---

## 4. 爆炸半径评估（基于全库 grep）

### 4.1 CLI 入口代码位置

`compiler/src/main.x`：

| 行号 | 函数 | 角色 |
|------|------|------|
| L824 | `main_cmd_build(argc, argv)` | `build` 子命令分发 |
| L827 | `main_cmd_run(argc, argv)` | `run` 子命令分发 |
| L830 | `driver_cmd_fmt(...)` | `fmt` 子命令分发 |
| L833 | `driver_cmd_check(...)` | `check` 子命令分发 |
| L836 | `driver_cmd_test(...)` | `test` 子命令分发 |
| **L838** | **裸 `.x` 路径无子命令 → "compile and run"** | **← 要删除的隐式入口** |

`driver_argv_drop_subcommand`（L156 声明）已实现「剥离子命令后转发 argv」，子命令路径已就绪。**改动核心是删除 L838 的 fallback 分支**，改为报错退出。

### 4.2 隐式调用统计

| 位置 | 形式 | 数量 |
|------|------|------|
| `compiler/makefile` | `./shux -backend asm ... file.x -o ...` | ~2 处实际编译（L250, L266），其余为 `shux=./shux` 变量赋值 |
| `compiler/scripts/shux_compile_std_module.sh` | `"$SHUX_BIN" -x -E ...` / `"$SHUX_BIN" -backend c ...` | ~8 处（L82, L121, L124, L236, L251, L252, L259, L260） |
| `compiler/scripts/smoke_asm_peephole_metric.sh` | `eval "$SHUX -backend asm -o ..."` | 1 处（L18） |
| `compiler/scripts/build_shux_asm.sh` | `$SHUX -backend asm ...` | 数处（含 echo/info，需筛实际调用） |
| `compiler/scripts/g05_*.sh` / `relink_*.sh` / `driver_leaf_x_to_o.sh` | `shux -O3 ...` / `shux -E ...` / `shux -freestanding ...` | ~10-15 处 |
| `tests/run-*.sh` | `$SHUX ... file.x` 或 `$SHUX -backend ... file.x` | 需单独统计（gate 脚本） |

**估算总数**：约 **30-50 处**隐式调用需迁移为 `shux build`。

### 4.3 bootstrap 链影响

`bootstrap_shuxc_create.sh` / `bootstrap_shux_create.sh` 等核心 bootstrap 脚本**已使用 `shux build`** 显式形式（Explore 确认）。bootstrap 链爆炸半径小，但需复核所有 `bootstrap_*.sh`。

### 4.4 自举完整性影响（关键）

SHUX 处于自举关键期。若 `shux` 二进制改了 CLI，则：
- **seed bootstrap_shuxc**：如果 seed 代码内部用旧形式调用 `shux`（通过 `system()` 或 exec），自举链会断
- **必须检查** `compiler/seeds/*.from_x.c` 中是否有 `system("shux ...")` 或类似调用
- **必须检查** `compiler/seeds/runtime_link_abi.from_x.c` 中的 `system("make ...")` 是否间接触发旧形式

---

## 5. 根源分析（上帝视角）

### 5.1 问题地图

```
用户输入 argv
  → main.x dispatch
       ├ argv[1] == "build"  → main_cmd_build     ✓ 保留
       ├ argv[1] == "run"    → main_cmd_run       ✓ 保留
       ├ argv[1] == "check"  → driver_cmd_check   ✓ 保留
       ├ argv[1] == "fmt"    → driver_cmd_fmt     ✓ 保留
       ├ argv[1] == "test"   → driver_cmd_test    ✓ 保留
       └ argv[1] == "*.x" 或 "-flag"  → 隐式 compile-and-run  ✗ 删除
```

### 5.2 五问（AGENTS.md §2 强制）

| 问 | 答 |
|----|----|
| 谁产生 | `compiler/src/main.x` L838 的 fallback 分支（裸 `.x` 路径无子命令 → "compile and run"） |
| 谁存储 | 无（运行时 dispatch） |
| 谁消费 | 30-50 处脚本 + Makefile + 可能的 seed system() 调用 |
| 同模式爆炸半径 | 所有 `shux <非子命令>` 调用都会走隐式路径 |
| 最小回归集 | macOS + Ubuntu `bootstrap-driver-seed` + `run-all-bstrict.sh` + 产品矩阵 |

### 5.3 风险点

1. **gate 脚本批量失败**：`tests/run-*.sh` 若用旧形式，bstrict 全红
2. **自举链断裂**：seed 内部若用旧形式调用 shux，冷编译失败
3. **跨平台**：Windows gate 脚本（`run-bootstrap-bstrict-windows-gate.sh`）需同步迁移
4. **shux-c vs shux**：shux-c（LEGACY C 前端）是否也走同一 dispatch？需确认 shux-c 是否支持 `build`/`run` 子命令

---

## 6. 迁移方案

### 6.1 分层迁移（推荐，符合「小步提交 + 单步验证」）

**Phase 1：脚本迁移（不动 CLI 代码）**

把所有脚本中的隐式调用改为 `shux build`：

```bash
# 旧：
shux -backend asm -o out.o main.x
shux -O3 file.x -o file.o
shux -E -freestanding file.x -o file.o
"$SHUX_BIN" -x -E -lib-name "" file.x

# 新：
shux build -backend asm -o out.o main.x
shux build -O3 file.x -o file.o
shux build -E -freestanding file.x -o file.o
shux build -x -E -lib-name "" file.x
```

涉及文件：
- `compiler/makefile`（L250, L266 等）
- `compiler/scripts/shux_compile_std_module.sh`
- `compiler/scripts/smoke_asm_peephole_metric.sh`
- `compiler/scripts/build_shux_asm.sh`
- `compiler/scripts/g05_*.sh`、`relink_*.sh`、`driver_leaf_x_to_o.sh`
- `tests/run-*.sh`（gate 脚本）
- `tests/run-all-bstrict.sh`、`tests/run-bootstrap-bstrict-windows-gate.sh`

**Phase 1 验证**：迁移后跑 `bootstrap-driver-seed` + `run-all-bstrict.sh`，全绿才进 Phase 2。

**Phase 2：CLI 代码改造**

修改 `compiler/src/main.x`：

1. 删除 L838 的隐式 fallback 分支
2. 改为报错退出：
   ```c
   /* No subcommand matched: reject hard. */
   fprintf(stderr,
     "Error: missing subcommand. Use 'shux build ...', 'shux run ...', "
     "'shux check ...', 'shux fmt ...', 'shux explain ...', or 'shux test ...'.\n");
   return 2;
   ```
3. 同步修改 seed 镜像（`compiler/seeds/main.from_x.c` 等），保证 `.x` 与 seed C 同语义（AGENTS.md §4 禁止双权威）

**Phase 2 验证**：
- macOS + Ubuntu 双端冷编译（L4：删全部 .o 重编 shux/shux_asm/shux-c/bootstrap_shuxc）
- `run-all-bstrict.sh` 全绿
- Windows gate（`SHUX_WIN_BSTRICT=1 ./tests/run-bootstrap-bstrict-windows-gate.sh`）全绿
- 手测 `shux file.x` 报错退出码 2

**Phase 3：seed 内部调用复核**

grep `compiler/seeds/*.from_x.c` 中所有 `system("shux ...")` 调用，确认无旧形式。若有，迁为 `system("shux build ...")`。

### 6.2 `shux run` 性能优化（可选，Phase 2 之后）

当前 `shux run file.x` 可能仍走「编译到临时文件 → 执行」流程。可优化为：

```
shux run file.x
  → Backend → 内存机器码流
  → mmap PROT_EXEC | PROT_READ | PROT_WRITE
  → 跳转执行
```

跳过 Linker 与 File I/O，目标启动延迟 ≤ 0.05s。但这属于独立优化，不应与 CLI 改造混在一个 commit。

---

## 7. 验证检查清单

- [ ] Phase 1：所有脚本迁移完成，`grep -rn 'shux \$\|shux -' compiler/scripts/*.sh compiler/makefile tests/*.sh` 无旧形式残留
- [ ] Phase 1：`bootstrap-driver-seed` macOS + Ubuntu 双端绿
- [ ] Phase 1：`run-all-bstrict.sh` 全绿（125 脚本 OK）
- [ ] Phase 2：`compiler/src/main.x` L838 隐式分支已删除
- [ ] Phase 2：seed 镜像 `compiler/seeds/main.from_x.c` 同步修改（同 commit）
- [ ] Phase 2：`shux file.x` 输出错误并 exit 2
- [ ] Phase 2：`shux --help` 更新 Usage（删除 `shux [options] file.x` 行）
- [ ] Phase 2：L4 冷编译双端绿（macOS arm64 + Ubuntu x86_64）
- [ ] Phase 2：Windows gate 全绿
- [ ] Phase 3：`grep -rn 'system("shux ' compiler/seeds/` 无旧形式
- [ ] 全程：一条债一层一个 commit；SHARED 改动双端验证；.x 注释英文

---

## 8. 决策建议

**推荐分三层 commit**：

1. `refactor(scripts): migrate implicit shux invocations to explicit build subcommand`
   - 仅改脚本 + Makefile + tests，不改 CLI 代码
   - 验证：bstrict 全绿

2. `feat(cli): require explicit subcommand; reject bare shux file.x`
   - 改 `main.x` L838 + seed 镜像 + `--help` 文本
   - 验证：L4 双端冷编译 + 全量 bstrict + Windows gate

3.（可选）`perf(run): in-memory exec path for shux run`
   - `shux run` 跳过 File I/O，直接 mmap 执行
   - 独立优化，单独验证

**禁止**：把脚本迁移 + CLI 改造 + 性能优化堆在一个 commit。一旦连锁破坏，无法定位归因（违反 AGENTS.md §2「小步提交 + 单步验证」）。

---

## 9. 决策权衡：为何选 B（强制子命令）而非 A（保留隐式运行）

曾考虑折中方案 A：**保留 `shux file.x` 隐式运行，只禁止 `shux --参数 file.x` 隐式编译**。经分析否决，选 B。

### 9.1 选项 A 的内部矛盾

若保留 `shux file.x` 隐式运行，则 `shux run file.x` 如何处置：

| 处置 | 后果 |
|------|------|
| 保留 `shux run` | `shux file.x` 与 `shux run file.x` 做同一件事 = **双权威**，违反 AGENTS.md §3「禁止功能重复实现」 |
| 删掉 `shux run` | Usage 不对称：`shux file.x`（隐式）+ `shux build`（显式）混用，违反一致性 |

→ 选项 A 要么违反 §3，要么造成 Usage 不对称，**比选项 B 更别扭**。

### 9.2 维度对比

| 维度 | 选项 A（保留隐式运行） | 选项 B（统一强制子命令） |
|------|----------------------|------------------------|
| AGENTS.md §3 | ❌ 双权威或不对称 | ✅ 单一权威 |
| 语言定位 | 对标 Python/Node（脚本语言） | 对标 Zig/Rust/Go（系统语言） |
| 扩展性 | `shux file.x --args` 与 shux flag 冲突 | `shux run file.x -- --args` 用 `--` 分隔 |
| 错误暴露 | 打错参数可能误走隐式路径 | 立即报错 |
| 爆炸半径 | 迁移 ~30-50 处隐式编译 | 迁移 ~30-50 处 + 少量隐式运行 |

### 9.3 「手感」论不成立

「保留 `shux file.x` 跑起来更快」这个直觉**只对脚本语言成立**。SHUX 是系统语言（no GC, zero-copy, 自举, 对标 C/Zig/Rust），对标的不该是 `python file.py` / `node file.js`，而是：

- `zig run file.zig`（Zig 强制子命令，无裸 `zig file.zig`）
- `cargo run` / `go run file.go`（Rust/Go 都强制子命令）
- `rustc file.rs`（只编译，运行靠 cargo）

`shux run main.x` 比 `shux main.x` 只多 4 字符，换来：单一权威（§3 合规）+ Usage 对称（build/run/check/fmt/test 全显式）+ 未来 `shux run file.x -- --program-arg=1` 可分隔参数。

### 9.4 爆炸半径对比

脚本里「直接 `shux file.x` 跑」**很少**——脚本通常要控制输出（编译成 .o / .exe），不会直接跑。大部分隐式调用是带 `-o` / `-backend` 的**编译**。全库 grep 确认 `shux file.x` 裸运行形式在 scripts/ 和 makefile 里几乎没有。所以 A 和 B 爆炸半径差距很小，**多改几处换长期清晰值得**。

---

## 10. 时机决策：自举前 vs 自举后

### 10.1 结论

**推荐自举后再做**。CLI 改造是工程优化，非自举阻塞项。

### 10.2 自举前做的成本

| 成本 | 说明 |
|------|------|
| seed 镜像同步（§4 硬约束） | 改 `main.x` L838 必须**同 commit 同步** `compiler/seeds/main.from_x.c`。自举前 seed C 是手动维护镜像，双线作业易错；自举后 seed 可从 .x 自动生成，成本骤降 |
| bootstrap_shuxc seed 兼容性未知 | `bootstrap_shuxc` seed（6月30日 pin）可能用旧形式调用 shux。改 CLI 后若 seed 内部 `system("shux file.x")` 失败，**自举链断**，需先验证 seed 兼容性，分散冲刺精力 |
| 破坏已建立的自举基线 | 当前 macOS + Ubuntu bstrict L4 全绿（125 脚本 OK）是自举基线。改 CLI 触发 tests/run-*.sh 批量迁移 + bstrict 125 脚本重新验证 + Windows gate 同步迁移（当前 Windows 问题尚未解决），基线重建成本高 |
| 违反「上帝视角纪律」开新战线 | AGENTS.md §2 强调「探针 + 邻域矩阵绿后才扩全量 bstrict」「一条债一层一个 commit」。当前 Windows 测试问题未闭环 + 自举冲刺期，再开 CLI 改造战线 = 多线作战，违反纪律 |

### 10.3 自举后做的优势

| 维度 | 自举前 | 自举后 |
|------|--------|--------|
| seed 同步 | 手动改 .x + seed C（双线） | .x 自动生成 seed（单线） |
| 自举链风险 | bootstrap_shuxc 兼容性未知 | 已自举完成，无风险 |
| 基线 | 破坏 bstrict L4 基线 | 有完整测试基线可验证 |
| 精力 | 与 Windows 问题 + 自举冲刺冲突 | 专注工程优化 |
| `shux run` mmap 优化 | 无法同期做 | 可一次性完成 |

### 10.4 唯一例外的判断标准

**若当前 CLI 形式直接阻塞自举**，必须自举前改。但当前 CLI 工作正常，bstrict 全绿，自举链通畅。CLI 改造是**工程优化**，不是**自举阻塞项**。

### 10.5 过渡期建议（现在可做，零风险）

不改正文，但**新写的脚本/测试尽量用显式形式**，减少未来迁移量：

```bash
# 新脚本推荐写法（现在就能用，旧 CLI 也兼容）：
shux build main.x -o out
shux run main.x

# 而非：
shux main.x
shux -backend asm main.x -o out
```

自举后做 CLI 改造时，需要迁移的旧形式调用更少。

### 10.6 执行时机

- **现在**：本文档作为「自举后第一项工程优化」存档
- **自举完成后**：按 §6 三阶段方案执行（Phase 1 脚本迁移 → Phase 2 CLI 改造 → Phase 3 `shux run` mmap 优化）
- **过渡期**：新脚本用显式形式，旧脚本不动

---

## 11. `--help` 信息架构优化

### 11.1 当前 `--help` 的问题

当前 `Common options` 把 12 个 flag 堆在一起，未标注适用子命令，存在三个信息架构问题：

**问题 1：flag 适用范围不明**

按实际语义，12 个 flag 可分三类：

| 类别 | flag | 适用子命令 |
|------|------|-----------|
| 编译/运行通用 | `-backend` `-O` `-target` `-target-cpu` `-L` | build, run |
| 仅编译 | `-o` `-freestanding` `-legacy-f32-abi` `-E` `-flto` | build |
| 顶层 action（非 flag） | `--print-target-cpu` `--explain` | 全局（执行后退出） |

用户看 `Common options` 不知道 `-o` 对 `run` 无意义、`-freestanding` 只对 `build` 有效。

**问题 2：`--print-target-cpu` 和 `--explain` 不是 flag**

这两个是**顶层 action**（执行后立即退出），不是传给子命令的 flag：

- `shux --print-target-cpu` → 打印 CPU 特性后退出
- `shux --explain XP003` → 解释诊断码后退出

它们应该和 `build`/`run`/`check` 等**子命令并列**或单独列为「全局 action」。当前混在 options 里会让用户误以为要 `shux build --print-target-cpu file.x`。

**问题 3：子命令自身 options 未展开**

`shux fmt [--check]` 的 `--check` 是 fmt 专属 flag，只在 Usage 行带过，没在 options 区展开。`shux build [-o exe]` 同理。每个子命令应支持 `shux <subcmd> --help` 查看自己的 flag。

### 11.2 推荐 `--help` 结构

```
Usage:
  shux <subcommand> [options] [args]

Subcommands:
  shux build [options] file.x [-o exe]   Compile .x to binary/object
  shux run   [options] file.x            Compile and run .x
  shux check [paths...]                  Parse + typeck only
  shux fmt   [--check] [paths...]        Format .x sources
  shux explain <CODE>                    Explain a diagnostic code
  shux test  [script.sh]                 Run test script

Global actions (no subcommand):
  shux --print-target-cpu                Print host CPU features and exit
  shux --explain <CODE>                  Print diagnostic code explanation and exit
  shux -h, --help                        Show this help

Compile options (build, run):
  -backend asm|c    Backend (default asm)
  -O <0|1|2|3|s>    Optimization (default 2)
  -target <triple>  Target (e.g. aarch64-linux-gnu)
  -target-cpu <cpu> native|generic|avx2|...
  -L <dir>          Library search path

Build-only options:
  -o <path>         Output binary or .o
  -freestanding     Nostdlib static link (Linux x86_64 ELF)
  -legacy-f32-abi   Legacy SysV f32 CALL (f64 widen; default xmm ABI)
  -E                Emit C (debug)
  -flto             Link-time optimization (C backend)

Environment:
  SHUX_ABI_F32_XMM=0  same as -legacy-f32-abi (x86_64 SysV)
  SHUX_OPT            default -O level if omitted

Run 'shux <subcommand> --help' for subcommand-specific details.

Release default: shux_asm -backend asm -O2 (f32 xmm ABI on unless legacy).
See compiler/docs/F32_XMM_ABI.md for f32 ABI and deprecation timeline.
```

### 11.3 改动要点

| 改动 | 说明 |
|------|------|
| `Common options` 拆分 | 拆为 `Compile options (build, run)` + `Build-only options` 两组 |
| `--print-target-cpu` / `--explain` 提升为 Global actions | 与子命令并列，明确「无需子命令，直接执行」 |
| 新增 `Run 'shux <subcommand> --help'` 提示 | 引导用户查看子命令专属 flag |
| 删除 `shux [options] file.x` 行 | 配合 §6 Phase 2 删除隐式入口 |
| `-h, --help` 归入 Global actions | 明确它是顶层 action，非子命令 flag |

### 11.4 时机

`--help` 重构与 §6 Phase 2 CLI 改造**同 commit**：

- Phase 2 删除隐式 fallback 后，Usage 第一行 `shux [options] file.x` 要删
- flag 分组是 CLI 改造的自然组成部分
- `--help` 文本与 dispatch 逻辑同源，分开改容易漂移（AGENTS.md §4 禁止双权威）

不建议独立成 commit——`--help` 文本与 CLI dispatch 强耦合，分开改违反「一条债一层一个 commit」的本意（这里「一层」= CLI 入口层，包含 dispatch + help 文本）。

### 11.5 子命令专属 `--help` 的实现

`shux <subcommand> --help` 需要 dispatch 层支持：在 `main_cmd_build` / `main_cmd_run` / `driver_cmd_check` 等函数入口检测 `--help` flag，输出子命令专属 help 后退出。

这是 Phase 2 的子任务，工作量小（每个子命令 help 模板 ~10 行），但需在 Phase 2 同 commit 完成。

---

## 12. flag 命名规范与 `--version` 新增

### 12.1 当前问题

| 问题 | 现状 | 规范 |
|------|------|------|
| 简写在前 | `-h, --help` | 应为 `--help, -h`（全写在前） |
| 缺版本查询 | 无 `--version` | 主流 CLI 标配，应新增 |
| flag 风格混合 | 单横线长选项 `-backend` + 双横线长选项 `--explain` 并存 | 本次不改（破坏性大，单独议题） |

### 12.2 规范：全写在前，简写在后

对齐 **Rust clap / GNU coreutils** 惯例：

```
--help, -h        ✓（全写在前）
-h, --help        ✗（简写在前，当前现状）
--version, -v     ✓（新增）
```

主流工具链参考：

| 工具 | help 输出 | version 输出 |
|------|----------|-------------|
| `cargo` (Rust clap) | `--help, -h` | `--version, -V` |
| `gcc` (GNU) | `--help, -h` | `--version, -v` |
| `go` | `-h` / `--help` 都接受 | `version`（子命令） |
| `zig` | `--help, -h` | `version`（子命令） |

SHUX 选 `--help, -h` + `--version, -v`（对齐 GNU gcc，简写小写 v）。

### 12.3 `--version` 设计

**用法**：

```
shux --version
shux -v
```

**输出格式建议**：

```
shux 0.1.0-alpha (self-hosting, build <git-short-hash>)
```

**版本号来源**（推荐方案）：

- 编译时从 `git describe --tags --always` 自动生成，注入 `SHUX_VERSION` 宏
- Makefile 构建时通过 `-DSHUX_VERSION="..."` 传入
- main.x 读取宏并输出

```x
/* Build-time injected version string from git describe. */
/* PLATFORM: SHARED — same on all hosts. */
#ifndef SHUX_VERSION
#define SHUX_VERSION "0.1.0-dev"
#endif
const SHUX_VERSION_CSTR: *u8 = SHUX_VERSION;
```

### 12.4 规范化后的 Global actions

```
Global actions (no subcommand):
  shux --help, -h                Show this help
  shux --version, -v             Show version and exit
  shux --print-target-cpu        Print host CPU features and exit
  shux --explain <CODE>          Print diagnostic code explanation and exit
```

### 12.5 `-v` 冲突风险

`-v` 在很多工具里是 `--verbose`。SHUX 当前未用 `-v`，可给 `--version`。若未来需要 verbose 模式：

- 选项 A：`--verbose`（无简写，保留 `-v` 给 version）
- 选项 B：`-V`（大写，对齐 Rust clap，`-v` 保留给 version）

**推荐选项 A**——SHUX 是编译器，verbose 模式可用环境变量 `SHUX_VERBOSE=1` 替代，无需占用 `-v` flag。

### 12.6 时机

与 §6 Phase 2 CLI 改造、§11 `--help` 重构**同 commit**：

- `--help` 文本规范是 §11 重构的子任务
- `--version` 实现需在 `main.x` dispatch 加新分支（顶层 action），属 CLI 入口层
- 同 commit 避免 help 文本与 dispatch 漂移（AGENTS.md §4 禁止双权威）
- seed 镜像同步（`compiler/seeds/main.from_x.c`）

### 12.7 实现要点

1. **main.x dispatch 新增分支**：在 `main` 函数 argv[1] 匹配处加 `--version` / `-v` 分支，输出版本后 `return 0`
2. **Makefile 注入版本宏**：构建 shux 时 `SHUX_VERSION="$(shell git describe --tags --always --dirty)"` 传入 `-DSHUX_VERSION`
3. **--help 文本规范**：所有「全写+简写」组合统一为 `--long, -short` 顺序
4. **seed 镜像同步**：`compiler/seeds/main.from_x.c` 同 commit 加 `--version` 分支（§4 禁止双权威）
5. **bootstrap_shuxc seed 兼容性**：6月30日 pin 的 seed 不支持 `--version`，但 `--version` 是新增分支不影响旧调用（向后兼容）

### 12.8 验证

- [ ] `shux --version` 和 `shux -v` 输出版本号，exit 0
- [ ] `shux --help` 和 `shux -h` 输出 help，exit 0
- [ ] `--help` 文本中所有 flag 组合为 `--long, -short` 顺序
- [ ] `SHUX_VERSION` 宏在 Makefile 构建时正确注入
- [ ] seed 镜像同步（同 commit）
- [ ] macOS + Ubuntu 双端 L4 冷编译绿

---

## 13. `--help` 彩色输出美化

### 13.1 设计原则

| 原则 | 说明 |
|------|------|
| 语义着色 | 每种颜色对应一种语义元素，非装饰性着色 |
| TTY 检测 | 管道/重定向时自动禁用颜色（避免 `\033[` 污染日志） |
| `NO_COLOR` 支持 | 尊重 `NO_COLOR` 环境变量（[no-color.org](https://no-color.org/) 标准） |
| `CLICOLOR_FORCE` | 支持 `CLICOLOR_FORCE=1` 强制启用（CI/日志场景） |
| Windows VT | Windows 10 1607+ 需 `SetConsoleMode` 启用 `ENABLE_VIRTUAL_TERMINAL_PROCESSING` |
| 颜色有限 | 3-5 种足够，太多反而混乱 |
| 加粗对位 | 标题/命令名加粗，描述不加粗 |

### 13.2 颜色语义分配

| 元素 | 颜色 | ANSI 码 | 理由 |
|------|------|---------|------|
| 区块标题（Usage / Subcommands / Options / Environment） | 加粗 + 下划线 | `\033[1;4m` | 视觉锚点，分隔区块 |
| 子命令名（build / run / check / fmt / explain / test） | 青色加粗 | `\033[1;36m` | 突出可执行动作 |
| flag 名（`--help` / `-h` / `-O`） | 黄色 | `\033[33m` | 突出参数 |
| flag 参数（`<file.x>` / `<path>` / `<triple>`） | 黄色加粗 | `\033[1;33m` | 区分 flag 和参数 |
| 描述文本 | 默认 | 无 | 主体可读 |
| 默认值 / 示例（`(default: asm)` / `(e.g. aarch64-linux-gnu)`） | 灰色 | `\033[90m` | 次要信息弱化 |
| 文件路径引用（`compiler/docs/F32_XMM_ABI.md`） | 蓝色下划线 | `\033[4;34m` | 链接感 |

### 13.3 彩色输出示例（渲染效果）

终端实际渲染效果（用 `[B]`=加粗、`[U]`=下划线、`[C]`=青色、`[Y]`=黄色、`[G]`=灰色、`[BU]`=蓝色下划线标记）：

```
[U][B]Usage:[0]
  shux <subcommand> [options] [args]

[U][B]Subcommands:[0]
  shux [C][B]build[0] [Y][B][options] file.x [-o exe][0]   Compile .x to binary/object
  shux [C][B]run[0]   [Y][B][options] file.x[0]            Compile and run .x
  shux [C][B]check[0] [Y][B][paths...][0]                  Parse + typeck only
  shux [C][B]fmt[0]   [Y][B][--check] [paths...][0]        Format .x sources
  shux [C][B]explain[0] [Y][B]<CODE>[0]                    Explain a diagnostic code
  shux [C][B]test[0]  [Y][B][script.sh][0]                 Run test script

[U][B]Global actions (no subcommand):[0]
  shux [Y]--help, -h[0]                Show this help
  shux [Y]--version, -v[0]             Show version and exit
  shux [Y]--print-target-cpu[0]        Print host CPU features and exit
  shux [Y]--explain[0] [Y][B]<CODE>[0]          Print diagnostic code explanation and exit

[U][B]Compile options (build, run):[0]
  [Y]--backend[0] [Y][B]<asm|c>[0]    Backend [G](default: asm)[0]
  [Y]-O[0] [Y][B]<0|1|2|3|s>[0]       Optimization [G](default: 2)[0]
  [Y]--target[0] [Y][B]<triple>[0]    Target [G](e.g. aarch64-linux-gnu)[0]
  [Y]--target-cpu[0] [Y][B]<cpu>[0]   native|generic|avx2|...
  [Y]-L[0] [Y][B]<dir>[0]             Library search path

[U][B]Build-only options:[0]
  [Y]-o[0] [Y][B]<path>[0]            Output binary or .o
  [Y]--freestanding[0]       Nostdlib static link [G](Linux x86_64 ELF)[0]
  [Y]--legacy-f32-abi[0]     Legacy SysV f32 CALL [G](f64 widen; default xmm ABI)[0]
  [Y]-E[0]                   Emit C [G](debug)[0]
  [Y]--flto[0]               Link-time optimization [G](C backend)[0]

[U][B]Environment:[0]
  SHUX_ABI_F32_XMM=0   same as -legacy-f32-abi [G](x86_64 SysV)[0]
  SHUX_OPT             default -O level if omitted

Run 'shux <subcommand> --help' for subcommand-specific details.

Release default: shux_asm -backend asm -O2 [G](f32 xmm ABI on unless legacy)[0].
See [BU]compiler/docs/F32_XMM_ABI.md[0] for f32 ABI and deprecation timeline.
```

### 13.4 实现方案

#### 13.4.1 TTY 检测函数

```x
/* Detect if stdout supports color output.
 * Why: respect NO_COLOR (https://no-color.org/) and CLICOLOR_FORCE;
 *      pipe/redirect must NOT emit ANSI codes (would corrupt logs).
 * PLATFORM: SHARED — POSIX uses isatty(); Windows uses _isatty + GetConsoleMode.
 * Invariant: returns 0 if NO_COLOR set or stdout not TTY.
 * Asm/Perf: called once at help entry, <1ms overhead.
 */
function cli_should_use_color(): i32 {
  /* 1. NO_COLOR env (any non-empty value disables color). */
  if (env_get_nonempty("NO_COLOR")) return 0;
  /* 2. CLICOLOR_FORCE=0 explicitly disables. */
  if (env_get_eq("CLICOLOR_FORCE", "0")) return 0;
  /* 3. SHUX_FORCE_COLOR=1 explicitly enables (CI / log capture). */
  if (env_get_eq("SHUX_FORCE_COLOR", "1")) return 1;
  /* 4. TTY check. */
  return cli_stdout_is_tty();
}
```

#### 13.4.2 Windows VT 启用

```x
/* Enable ANSI VT processing on Windows 10 1607+.
 * Why: Windows console needs SetConsoleMode(ENABLE_VIRTUAL_TERMINAL_PROCESSING)
 *      to interpret \033[ escape sequences; without it, raw codes leak.
 * PLATFORM: WINDOWS — no-op on POSIX (terminals natively support ANSI).
 */
function cli_enable_windows_vt(): i32 {
  /* Windows-specific: GetStdHandle + GetConsoleMode + SetConsoleMode.
   * Returns 1 if VT enabled, 0 if unsupported (fallback to plain text). */
  ...
}
```

#### 13.4.3 颜色常量

```x
/* ANSI color codes for help output.
 * PLATFORM: SHARED — ANSI VT codes are universal on modern terminals
 *           (Linux/macOS native; Windows 10 1607+ via VT processing).
 */
const CLI_COLOR_RESET: *u8 = "\033[0m";
const CLI_COLOR_BOLD: *u8 = "\033[1m";
const CLI_COLOR_UNDERLINE: *u8 = "\033[4m";
const CLI_COLOR_BOLD_UNDERLINE: *u8 = "\033[1;4m";
const CLI_COLOR_YELLOW: *u8 = "\033[33m";
const CLI_COLOR_BOLD_YELLOW: *u8 = "\033[1;33m";
const CLI_COLOR_CYAN: *u8 = "\033[36m";
const CLI_COLOR_BOLD_CYAN: *u8 = "\033[1;36m";
const CLI_COLOR_GRAY: *u8 = "\033[90m";
const CLI_COLOR_BLUE_UNDERLINE: *u8 = "\033[4;34m";
```

#### 13.4.4 辅助函数（运行时着色，单一数据源）

```x
/* Print section title (bold + underline if color, plain otherwise).
 * Why: single help data source; color decision at runtime avoids
 *      maintaining two help text versions (DRY principle).
 */
function cli_print_title(text: *u8, use_color: i32): void {
  if (use_color) {
    fprintf(stdout, "%s%s%s\n", CLI_COLOR_BOLD_UNDERLINE, text, CLI_COLOR_RESET);
  } else {
    fprintf(stdout, "%s\n", text);
  }
}

/* Print subcommand line: name (cyan bold) + args (yellow bold) + desc (default).
 * Invariant: column alignment preserved in both color and plain modes.
 */
function cli_print_subcmd(name: *u8, args: *u8, desc: *u8, use_color: i32): void {
  if (use_color) {
    fprintf(stdout, "  %s%s%s %s%s%s   %s\n",
      CLI_COLOR_BOLD_CYAN, name, CLI_COLOR_RESET,
      CLI_COLOR_BOLD_YELLOW, args, CLI_COLOR_RESET,
      desc);
  } else {
    fprintf(stdout, "  %s %s   %s\n", name, args, desc);
  }
}

/* Print flag line: flag (yellow) + arg (yellow bold) + desc (default) + default (gray). */
function cli_print_flag(flag: *u8, arg: *u8, desc: *u8, default_val: *u8, use_color: i32): void {
  ...
}
```

### 13.5 对齐参考

| 工具 | 标题 | 子命令 | flag | 描述 | 默认值 |
|------|------|--------|------|------|--------|
| `cargo --help` | 加粗 | 绿色 | 黄色 | 默认 | 灰色 |
| `npm --help` | 青色加粗 | 默认 | 默认 | 灰色 | — |
| `docker --help` | 加粗 | 绿色 | 黄色 | 默认 | — |
| `gh --help` | 加粗 | 蓝色 | 黄色 | 默认 | — |
| `bat --help` | 加粗 | 绿色 | 黄色 | 默认 | 灰色 |
| **SHUX 方案** | **加粗+下划线** | **青色加粗** | **黄色** | **默认** | **灰色** |

SHUX 方案与 `cargo`/`bat` 接近，符合 Rust 现代工具链惯例（SHUX 对标系统语言）。

### 13.6 风险与权衡

| 风险 | 说明 | 缓解 |
|------|------|------|
| Windows 兼容性 | 旧 Windows 不支持 ANSI VT | SHUX 已要求 Win11，假定 VT 可用；检测失败时 fallback 纯文本 |
| seed 镜像同步 | main.x 加颜色逻辑 → seed 同步（§4 禁止双权威） | 同 commit 改 seed main.from_x.c |
| 测试基线 | bstrict 脚本可能 grep help 输出做断言，颜色码干扰 | 脚本用 `NO_COLOR=1 shux --help` 强制纯文本 |
| 代码量 | 颜色宏 + 辅助函数 + TTY 检测 ~100 行 | 可接受，属 CLI 入口层必要基础设施 |
| 性能 | help 是一次性输出，无性能敏感 | TTY 检测 <1ms，零影响 |

### 13.7 时机

与 §6 Phase 2 + §11 `--help` 重构 + §12 flag 规范**同 commit**：

- 颜色逻辑是 help 输出的组成部分，分开改违反 §4 禁止双权威
- 辅助函数 + TTY 检测属 CLI 入口层
- help 文本重写时一并加颜色逻辑，避免重复改

**不推荐**单独 commit 做颜色——会让 Phase 2 的 help 文本与最终彩色版本漂移，违反「一条债一层一个 commit」（这里「一层」= CLI help 层，含文本 + 颜色 + dispatch）。

### 13.8 验证

- [ ] `shux --help` 终端输出彩色，管道 `shux --help | cat` 输出纯文本
- [ ] `NO_COLOR=1 shux --help` 输出纯文本
- [ ] `SHUX_FORCE_COLOR=1 shux --help | cat` 输出彩色（强制）
- [ ] Windows 11 终端彩色正常（VT 启用）
- [ ] Windows `NO_COLOR=1` 纯文本正常
- [ ] macOS Terminal / iTerm 彩色正常
- [ ] Ubuntu xterm / gnome-terminal 彩色正常
- [ ] bstrict 脚本不因颜色码失败（`NO_COLOR=1` 兜底）
- [ ] seed 镜像同步（同 commit）
- [ ] L4 双端冷编译绿

---

*文档更新：2026-07-20 — 基于全库 grep 评估爆炸半径（30-50 处隐式调用），给出 3 阶段迁移方案 + 决策权衡（§9 选 B 而非 A）+ 时机决策（§10 自举后再做）+ `--help` 信息架构优化（§11 flag 按子命令分组）+ flag 命名规范与 `--version` 新增（§12 全写在前 + `--version, -v`）+ `--help` 彩色输出美化（§13 语义着色 + TTY 检测 + Windows VT）+ 验证清单。*
