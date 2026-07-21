# Shux（舒克斯）

> **写底层代码，终于可以又简单、又安全、又快。**  
> 你熟悉的 C 心智模型 · 接近 Rust 的内存安全、却不靠重型类型论 · 默认代码质量目标**超越**精心编写的 C · 学习成本以**天**计，不以月计。

| 项目 | 说明 |
|------|------|
| **语言名** | Shux（舒克斯） |
| **编译器** | `shux` / `shux_asm`（自举链路后的产品二进制） |
| **源文件后缀** | `.x` |
| **构建配置** | `build.x` — 用 Shux 描述的项目构建策略（步骤、目标、产物）；由 `shux build` / `build_tool` / `shux-build.sh` 执行 |
| **现阶段（2026-07-20）** | **产品 L4 钉盘 `deaf773b`**（双端真冷 + bstrict **125/125** + Windows hybrid gate）。tip **`0c9458ed`**：CLI help 美化（Deno 风格），双端 L2 绿（**≠** tip L4 升钉）。**尚未完全自举**（冷启动仍需 seed / 过渡 C） |
| **进度仪表盘** | [`analysis/自举进度.md`](analysis/自举进度.md) · 当天快照 [`analysis/当前进度.md`](analysis/当前进度.md) |
| **English** | [README.md](README.md) |

---

## 一、为什么是 Shux — **三高一低**

Shux 是一门面向内核、驱动、运行时与高性能工具的**系统级编程语言**：无 GC、零成本抽象、显式内存模型，可 freestanding。

多数语言逼你二选一。Shux 拒绝这个假选择：

| 支柱 | 目标 | 落地含义 |
|------|------|----------|
| **高性能** | **默认就比精心写的 C 更快** | 无 GC；默认 ASM 后端 + 可选 C 后端；激进别名 / `noalias`、BCE、泛型单态化；Arena / region 热路径零 malloc。性能主要靠**编译器**，不是每个调用点靠人肉优化 |
| **高安全** | **安全子集内接近 Rust** | 编译期 region / 借用 / 线性类型检查；`Option` / `Result` 优先于静默空指针；带长度切片；`unsafe` 仅用于硬件与 syscall 边界——**可审计**，不是默认可 UB |
| **高可读** | **比 C 更简单、更好维护** | `T[]` 自带长度；无头文件地狱（目录即模块）；`defer` / `with_arena` / 作用域分配器；字段访问只有 `.`；诊断带真实位置 |
| **低学习成本** | **C 程序员按「天」上手** | 控制流与心智模型接近 C；无 lifetime 注解迷宫；可渐进：先写「类 C」，再引入现代安全特性；`shux build` / fmt / LSP 一体 |

**每条语言特性的评审铁律（最高优先级）：**

> *这会让 C 程序员觉得更麻烦吗？*  
> 会 → 砍掉、藏进编译器，或关进 `unsafe`。**「比 C 更简单」是设计评审的第一准则**；安全与性能由编译器智能补齐，而不是把负担推给作者。

### 诚实对照

| 对照 | Shux 的选择 |
|------|-------------|
| **相对 C** | 同样贴近机器 —— 语法更干净、更少脚枪、工具链一体，在 C 常有 UB 的地方给出安全证明 |
| **相对 Rust** | 同样追求内存安全 —— **不必**过「重型 borrow checker 生活方式」；region + 推断 + 线性类型扛重活 |
| **相对 Zig** | 同样崇尚简单与显式 —— 再加默认安全子集与更强的静态安全叙事 |

### 支撑目标

| 目标 | 含义 |
|------|------|
| **轻量** | 依赖少、二进制小、可 freestanding / 嵌入式；标准库按需入链 |
| **标准库** | 完整 `core/` + `std/`；跨平台一套 API（差异收在 `std.sys`） |
| **编译自举** | 终局：编译器与标准库 100% `.x`；宿主 C / seed 仅冷启动（**进行中，未宣称完成**） |

### 设计宗旨

- **目的**：在关键路径极致压榨性能 —— **默认代码质量优于「普通认真写的 C」**，而不是「你够小心才一样快」。
- **原则**：可维护、开发简单、**内存安全**（安全子集无静默 UB）。
- **方法**：region 内存 + 借用门控 + 线性类型；别名分析服务 autovec / DCE；`unsafe` 保持薄且可审。

设计长文：[`analysis/语法与类型设计-高性能与内存安全.md`](analysis/语法与类型设计-高性能与内存安全.md)、[`analysis/需求分析.md`](analysis/需求分析.md)、[`analysis/安全与性能.md`](analysis/安全与性能.md)。

---

## 二、语言特性概览

### 类型与语义

- **基础类型**：`i8`/`i16`/`i32`/`i64`，`u8`/`u16`/`u32`/`u64`，`f32`/`f64`，`bool`，`usize`/`isize`
- **结构体与泛型**：泛型单态化；trait / impl
- **可空与错误**：`Option<T>`、`Result<T, E>`（优先于 C 式裸可空指针）
- **切片**：`T[]` 带长度；域标注 `T[]<label>` + 逃逸检查
- **模块**：`import("std.io")` / `import("core.mem")`；目录即模块，入口 `mod.x`
- **字段访问**：源语言**只有 `.`**，没有 `->`（指针上的 C `->` 由 codegen 按类型决定）

### 内存与安全

- **无 GC**：栈 + 堆 + Arena；编译期 region / 线性 / 借用拒错
- **编译期辅助**：`defer`、`owned`、作用域分配器（`with_arena`）、SROA、BCE
- **分级安全**：默认安全；裸指针与底层 syscall 仅在 `unsafe { ... }`
- **别名分析**：`noalias` 与借用门控，服务 autovec / DCE

详见 [`analysis/编译时自动内存管理和自动向量化.md`](analysis/编译时自动内存管理和自动向量化.md)、[`analysis/安全与性能.md`](analysis/安全与性能.md)。

### 平台

- 条件编译（`#if` / target 分支）
- **一套 API，多 OS**（Linux / macOS 主路径；Windows 探针 / B-hybrid）
- Freestanding：`-freestanding`（Linux x86_64 nostdlib 静态路径）
- 目标如 `x86_64-linux`、`arm64-macos`（`-target`）

语法索引：[`docs/README.md`](docs/README.md)。

---

## 三、快速开始

### 环境要求

- **Linux**（x86_64 为金标准）或 **macOS**
- 宿主 C 工具链（`cc` / `clang`）：链接阶段与冷启动 seed
- 可选：Docker（Linux gate）

### 首次构建

```bash
# 推荐：pinned seed → build_tool → 日常 shux
make -C compiler build-tool
./shux-build.sh first-time          # build_tool + ./build_tool ./shux
# 或：cd compiler && ./build_tool ./shux

# 仅 cc 冷启动：cd compiler && sh bootstrap.sh

# 常见产品链：seed 驱动 + g05 relink
make -C compiler bootstrap-driver-seed
FULL=0 bash compiler/scripts/g05_prepare_and_relink.sh
```

### 日常构建

```bash
# 日常：G-05 → shux_asm relink 金标准
./shux-build.sh build
# 或：cd compiler && ./build_tool ./shux

export SHUX=./compiler/shux_asm   # 用本波产品二进制
./tests/run-hello.sh

# 改后端 / seed 后的重型重建
./shux-build.sh full              # 或 make -C compiler bootstrap-driver-bstrict
```

| 入口 | 用途 |
|------|------|
| `./shux-build.sh build` / `./build_tool ./shux` | **日常增量**（默认） |
| `./shux-build.sh full` | 全量 B-strict 风格重建 |
| `make -C compiler …` | 冷启动、CI、底层目标 |

**产品二进制**：构建成功后以 **`compiler/shux_asm`** 为准（常同步为 `compiler/shux`）。  
`shux-c` / seed 工具只服务**冷启动与过渡**，不是日常发布面。

### Hello World

```x
// Hello World — void main 隐含 exit 0（Zig 风格）
const fmt = import("std.fmt");

function main(): void {
  fmt.println("Hello World");
}
```

```bash
export SHUX=./compiler/shux_asm
$SHUX examples/hello.x
$SHUX build examples/hello.x -o hello && ./hello
$SHUX check examples/hello.x
```

更多示例：[`examples/`](examples/)（io、net、async、json、compress 等）。

### 验收测试

```bash
export SHUX=./compiler/shux_asm
./tests/run-all.sh
SHUX_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh   # 产品闸门（约 125 脚本）
./tests/run-linux-a09-a11-gate.sh
# Linux x86_64 freestanding S4 烟测（return42 / panic / hello）：
./tests/run-freestanding-hello.sh
```

凡谈**自举 / 产品放行**，项目要求 **L4 真冷**（擦除 `compiler`/`std`/`core` 下全部 `.o` 并重链二进制）+ **双端** `run-all-bstrict` 全绿。详见 [`analysis/自举方法.md`](analysis/自举方法.md)、[`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md)。  
**注意：** 日常 tip 的 L2 绿 **≠** tip L4 钉盘。**放行钉盘为 `deaf773b`**（双端真冷 125/125 + Windows hybrid gate）。tip 日常工作（如 CLI help 美化）可双端 L2 绿而不升 L4 钉盘（见 §八）。

---

## 四、编译器用法

默认 **ASM 后端**（`-backend asm`）。必须使用子命令，禁止隐式编译运行。

```bash
shux [COMMAND] [OPTIONS]
```

### 子命令

| 命令 | 说明 | 用法 |
|------|------|------|
| `build` | 编译 .x 到二进制/目标文件（默认 a.out） | `shux build [options] file.x [-o exe]` |
| `run` | 编译并运行 .x | `shux run [options] file.x` |
| `check` | 仅 parse + typeck（不生成代码） | `shux check [paths...]` |
| `fmt` | 格式化 .x 源码 | `shux fmt [--check] [paths...]` |
| `explain` | 解释诊断代码 | `shux explain <CODE>` |
| `test` | 运行测试脚本 | `shux test [script.sh]` |

### 构建选项（build / run）

| 选项 | 说明 |
|------|------|
| `-backend asm\|c` | 后端（默认 asm） |
| `-O <0\|1\|2\|3\|s>` | 优化级别（默认 2） |
| `-o <path>` | 输出二进制或 .o |
| `-L <dir>` | 库搜索路径 |
| `-target <triple>` | 目标三元组（如 `aarch64-linux-gnu`） |
| `-target-cpu <cpu>` | `native\|generic\|avx2\|...` |
| `-freestanding` | Nostdlib 静态链接（Linux x86_64 ELF） |
| `-legacy-f32-abi` | 传统 SysV f32 CALL（f64 扩展；默认 xmm ABI） |
| `-E` | 输出 C（调试） |
| `-flto` | 链接时优化（C 后端） |

### 全局选项

| 选项 | 说明 |
|------|------|
| `--print-target-cpu` | 打印宿主 CPU 特性并退出 |
| `--explain <CODE>` | 打印诊断代码解释并退出 |
| `--help, -h` | 显示帮助 |

### 环境变量

| 变量 | 效果 |
|------|------|
| `SHUX_ABI_F32_XMM=0` | 等同于 `-legacy-f32-abi`（x86_64 SysV） |
| `SHUX_OPT` | 默认 -O 级别 |
| `NO_COLOR` | 禁用彩色输出 |
| `CLICOLOR_FORCE=1` | 强制彩色输出（即使管道重定向） |
| `SHUX_FORCE_COLOR=1` | 等同于 CLICOLOR_FORCE |

### 示例

```bash
# 编译并运行
shux run examples/hello.x

# 编译到可执行文件
shux build examples/hello.x -o hello && ./hello

# 仅 parse + typeck
shux check examples/hello.x

# 格式化源码
shux fmt src/

# 解释诊断代码
shux explain XP003

# 运行测试脚本
shux test tests/run-all-bstrict.sh

# 语言服务器（stdio JSON-RPC）
shux --lsp

# 强制 C 后端
shux build -backend c file.x

# Freestanding（Linux x86_64 nostdlib）
shux build -freestanding file.x
```

根目录 [`build.x`](build.x) 描述编什么。日常入口：`./shux-build.sh` / `build_tool`。

---

## 五、仓库结构

```
shux/
├── README.md / README_zh-CN.md
├── LICENSE · LICENSE.AGPL-3.0 · LICENSE.Apache-2.0 · NOTICE · CONTRIBUTING.md
├── build.x / shux-build.sh
├── analysis/                 # 过程文档 + RFC（当前进度 / 自举方法 / 自举步骤 / 问题分析 / 自举进度 …）
├── docs/                     # 语言语法（面向用户）
├── compiler/                 # 编译器（.x + seed C / glue）
│   ├── src/                  # lexer / parser / typeck / codegen / asm / pipeline / driver / lsp
│   ├── seeds/                # 冷启动 pin
│   ├── docs/SELFHOST.md
│   └── scripts/              # build_shux_asm、g05、relink …
├── core/                     # 无 OS 依赖的核心库
├── std/                      # 面向 OS 的标准库（产品 .x；std 下无手写 .c）
├── tests/
├── examples/
├── tools/
├── editors/vscode/           # VS Code / Cursor / Trae + LSP 客户端
└── mcp/
```

- **core/** 不依赖 **std/**；**std/** 可依赖 **core/**
- 模块规则：**目录即模块**，入口 `mod.x`

架构：[`analysis/构架分析.md`](analysis/构架分析.md)。

---

## 六、标准库

### core（无 OS）

| 模块 | 职责 |
|------|------|
| `core.types` | `size_of` / `align_of`、布局 |
| `core.mem` | 内存操作 |
| `core.option` / `core.result` | 可空 / 错误 |
| `core.slice` / `core.str` | 切片与字符串视图 |
| `core.fmt` / `core.debug` | 格式化 / 调试 |
| `core.builtin` / `core.iterator` / `core.cmp` | 内置、迭代、比较 |

完整列表：[`docs/07-内置与标准库.md`](docs/07-内置与标准库.md)。

### std（面向 OS）

`std/` 产品源为 **`.x`**（阶段 F：`std/` 下无手写 `.c`/`.h`）。覆盖面包括：

| 类别 | 示例 |
|------|------|
| 基础 | `std.io`、`std.fs`、`std.path`、`std.process`、`std.env` |
| 容器 | `std.vec`、`std.map`、`std.set`、`std.queue` |
| 内存 | `std.heap`、`std.mem` |
| 并发 | `std.thread`、`std.sync`、`std.channel`、`std.async` |
| 网络 | `std.net`、`std.http`、`std.websocket` |
| 数据 | `std.json`、`std.csv`、`std.compress`、`std.db` |
| 系统 | `std.sys`（Linux / macOS；Windows 推进中） |
| 工具 | `std.test`、`std.fmt`、`std.log`、`std.cli`、`std.crypto` 等 |

**按需入链**，尽量不把未用模块拖进最终链接。

---

## 七、编译器架构

```
.x 源
  → 预处理（#if / import）
  → lexer → parser → AST
  → typeck（泛型、借用、region …）
  → codegen（默认 ASM，或 -E / -backend c）
  → 宿主链接 → 可执行文件 / .o
```

| 路径 | 含义 |
|------|------|
| **用户 / 产品轨** | 本 SHA 的 `shux_asm` 编用户 `.x` → `-o` / 运行；矩阵 + bstrict |
| **自举 / 工程轨** | seed 冷启动 → `build_shux_asm` / g05 → 可选 Stage2 / WPO dogfood |

**双轨（读进度时不要混）：**

| 轨道 | 测什么 | 能否单独说「自举完成」 |
|------|--------|------------------------|
| **产品轨** | L4 真冷 + 产品矩阵 + 双端 `run-all-bstrict` **125** | **必要**，但还不够宣称「永久零 C」 |
| **工程轨** | prove T/N、Cap residual pure、Stage2、WPO 链/链接/text 门 | **否** |

---

## 八、自举状态（摘要 · 2026-07-20）

> **实时数字以** [`analysis/自举进度.md`](analysis/自举进度.md) · 当天 [`analysis/当前进度.md`](analysis/当前进度.md) **为准**。  
> README 只给摘要；**禁止**把 Stage2 / prove / WPO / **日常 L2 绿**写成 tip L4 重钉或「完全自举」。

### 产品轨

| 项 | 状态 |
|----|------|
| **L4 放行钉盘** | **`deaf773b`** — 双端 **真冷** + `run-all-bstrict` **125/125**（Ubuntu + macOS）+ Windows hybrid gate。当日升钉序列：`305cfbe1` → `deaf773b`；更早含 `5cc73d54` / `a74e25a1` / `c51759eb` — **勿**把旧 SHA 写成现行钉盘 |
| 产品 bstrict 套件数 | **125**（`tests/run-all-bstrict.sh`；日志须 `OK (125 scripts…)`） |
| Ubuntu L4 + 全量 bstrict（钉盘） | ✅ **125/125** @ **`deaf773b`** |
| macOS L4 + 全量 bstrict（钉盘） | ✅ **125/125** @ **`deaf773b`** |
| Windows hybrid gate（钉盘） | ✅ warm 绿 @ **`deaf773b`** |
| 金标主机 | **Ubuntu x86_64** |
| 验收二进制 | 本波 g05 / relink 的 `compiler/shux_asm` — **禁止**残留 Stage2 `shux_asm2` 或旧 stage1 |
| 分支 tip（≠ tip L4） | **`0c9458ed`**（`self-hosting`）— CLI help 美化（Deno 风格），双端 L2 绿。**仅**双端真冷 + bstrict **125** 后才升 tip L4 钉盘 |
| 最新 tip 日常 L2 | ✅ mac + Ubuntu 矩阵 + bstrict **125/125** @ `0c9458ed`（**≠** tip L4 重钉；CLI help 美化非 ABI/链接） |

### 产品面 2026-07-20 已收口

属**用户产品路径**（`shux_asm` / freestanding / 门禁）。L2 绿 **不会**自动抬 L4 钉盘：

| 面 | 状态 |
|----|------|
| **C2 · `std.net` PRIMARY UNDEF** | ✅ `net.o` 合入 `mod.x`；`use_line` 真调用识别；cookbook `net_listen_bind.x -o` 绿 — 已入钉盘谱系 |
| **C3=C4 · bare `{…}` 结构体字面量** | ✅ parser `LBRACE` let-init handler；bare struct-lit + `unsafe`/`while` 不再丢 let → P001 |
| **C8 · vec/set/map/queue 重复符号** | ✅ `c_provides` 守卫 `mem.o`+`heap.o` 推入（fk0 GAP）— 已入钉盘谱系 |
| **Backtrace C 后端 heap 链** | ✅ 补推 `page_mmap.o` + asm IO stubs — 已入钉盘谱系 |
| **C5 · `EXPR_MATCH` CTFE** | ✅ const subject + const arms 折成 imm32（`lang-const` 13/13）；tip `229708f1`，双端 L2，**未**升 L4 |
| **C6 · X ABI P0b** | ✅ wave 1 unsafe 包裹（9 处）+ wave 2 ABI 一致性（3 处）— **升钉 `deaf773b`** |
| **Windows hybrid gate** | ✅ MSYS2/MinGW bootstrap-driver-bstrict + return-value 42 + win32-write-gate + win32-read-file-gate + C-03 — **升钉 `deaf773b`** |
| **CLI help 美化** | ✅ Deno 风格绿色配色 + 子命令独立分组 + `shux [COMMAND] [OPTIONS]` 顺序 |
| **std.print 架构** | ✅ 统一归属 `std.fmt`（stdout）+ `std.debug`（stderr）；`std.io` 仅保留底层 write 原语 |
| **强制子命令** | ✅ 删除 `shux file.x` 隐式 fallback，必须使用 `shux run` / `shux build` |
| Freestanding S4 / NL-07 零 libc / Hosted asm 矩阵 | ✅ 产品钉盘上仍成立 |

### 工程轨（量级）

| KPI / 门禁 | 状态 |
|------------|------|
| **T** | **18/18** |
| **EMPTY** | **18/18** |
| **N** prove IDENTICAL | **54/54** |
| Cap residual pure | 钉盘谱系上多波已收口 |
| **D Stage2** | ✅ freestanding / 行为 parity（**≠** 产品 g05 全链） |
| Stage2 **WPO** 链 + strict-link + text-gate | ✅ 工程绿（Ubuntu；部分 Darwin N/A） |

### 明确不宣称

- **未**宣称「编译器已 100% `.x`、无 seed」
- **未**把 Stage2 的 `shux_asm2` 当产品编译器
- **未**把工程 WPO 绿等同 tip 产品 L4
- **未**把「tip 双端 L2 bstrict」写成 tip L4 —— 钉盘为 **`5cc73d54`**，须下次双端 **真冷** 才重钉
- 终局物理零 C / 彻底去掉 seed（**G**）仍在路线图，不是本周叙事

方法：Cap / R / L / M → [`analysis/自举方法.md`](analysis/自举方法.md)。运维：[`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md)。纪律：[`AGENTS.md`](AGENTS.md) + skill `shux-selfhost-product-gate`。

### 近端前排（高层）

1. 下一产品 Cap 仅在有明确候选时开地图（C5 guard / struct-lit / enum-variant fold；C6 X ABI P0b；C7 plan 瘦身）— **禁**无地图 tip L4  
2. **tip L4 重钉**仅当 ABI / 链接 / seed 面变动且双端真冷 + bstrict 125  
3. residual 仅在挡产品面时开 — **禁** soft-skip typeck、**禁**双权威

---

## 九、里程碑

| 里程碑 | 内容 | 状态 |
|--------|------|------|
| M0 | Lexer、AST、Parser | ✅ |
| M1 | Typeck、Codegen、Driver | ✅ |
| M2 | import、core/std 子集、多目标 | ✅ |
| M3 | 泛型、trait、模块、std 扩张 | ✅ |
| M4 | DCE、-O2/-Os、体积/性能基线 | ✅ 部分 |
| M5 | 自举（编译器可重编自身） | 🟡 **产品路径可用 + 自举推进中**；**冷启动仍需 seed** |
| **当前** | 产品 L4 双端钉盘 @ **`5cc73d54`**（125/125）；tip **`229708f1`**（C5 CTFE 双端 L2）— **未** tip L4 升钉 | 见仪表盘 |

---

## 十、文档索引

| 文档 | 内容 |
|------|------|
| [`analysis/自举进度.md`](analysis/自举进度.md) | **KPI 仪表盘**（每波必改） |
| [`analysis/当前进度.md`](analysis/当前进度.md) | 当天快照 / 前排 |
| [`analysis/自举方法.md`](analysis/自举方法.md) | Cap / R / L / M 方法 |
| [`analysis/自举步骤.md`](analysis/自举步骤.md) | 可执行闸门 |
| [`docs/README.md`](docs/README.md) | 语言文档目录 |
| [`analysis/需求分析.md`](analysis/需求分析.md) | 总目标、性能与安全策略 |
| [`analysis/构架分析.md`](analysis/构架分析.md) | 仓库与编译器划分 |
| [`analysis/性能压榨.md`](analysis/性能压榨.md) | 性能分层 / dogfood |
| [`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md) | 自举运维 |
| [`editors/vscode/README.md`](editors/vscode/README.md) | 编辑器插件与 LSP |
| [`AGENTS.md`](AGENTS.md) | 协作铁律（根源、双权威、平台） |

更多 RFC 见 `analysis/`（http、async、WPO 等）。

---

## 十一、测试与质量

| 套件 | 命令 |
|------|------|
| 全量回归 | `./tests/run-all.sh` |
| 产品 bstrict | `SHUX=./compiler/shux_asm SHUX_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh` |
| 推送前 P0 | `SHUX=./compiler/shux_asm ./tests/run-pre-push-p0.sh` |
| Linux 金标子集 | `./tests/run-linux-a09-a11-gate.sh` |
| 主题门禁 | `tests/run-*-gate.sh` |
| 编译 dogfood | `SHUX_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh` |

基线目录：`tests/baseline/`。跑 **真冷全测** 时，应把日志路径打印给操作者（如 `/tmp/*true_cold*`、`/tmp/*true_bstrict*`），便于盯进度。

### 性能快照（历史 · 2026-07-09 · Linux x86_64）

相对 `clang -O2` 墙钟中位数（预热 3 + 20 轮）。刷新流程见 `analysis/perf-*`。

| 用例 | ratio（SHUX / C） | 备注 |
|------|-------------------|------|
| `loop_i32` | ~0.87 | ✅ |
| `mem_copy` | ~0.87 | ✅ |
| `struct_param` | ~0.08 | ✅ |
| `call_boundary`（fold） | ~0.00 | 编译期仿射折叠 |
| `call_boundary`（真跑） | ~1.77 | ❌ — 栈压重；寄存器分配仍弱 |

差分 D1–D6：5/6 通过；float D4 仍为已知 P2 占位。

---

## 十二、工具链生态

| 组件 | 路径 |
|------|------|
| VS Code / Cursor / Trae | [`editors/vscode/`](editors/vscode/) |
| LSP | `shux --lsp` · `compiler/src/lsp/` |
| MCP | [`mcp/`](mcp/) |

插件安装：[`editors/vscode/README.md`](editors/vscode/README.md)。

---

## 十三、贡献

1. 克隆 → `make -C compiler build-tool && ./shux-build.sh first-time`（或完整 bootstrap-driver 路径）。  
2. 日常改动 → `./shux-build.sh build`，`SHUX=./compiler/shux_asm`，跑相关测试 / gate。  
3. 产品 / 链接 / SHARED 改动 → **Ubuntu 金标**（SHARED 再加 mac）；谈放行须 **L4 真冷** + 双端 bstrict。  
4. 提交：Conventional Commits（`feat:` / `fix:` / `docs:` …）；`.x` 新注释用英文（见 `AGENTS.md` / G.9）。  
5. **禁止双权威**：seed 与 `.x` 产品面必须同 commit 对齐。  
6. **禁止假绿**：不得仅凭 prove / Stage2 / WPO 宣称自举完成。

**当前决议**：自举 / 产品闸门优先于大规模 std 新功能；IR v4 架构已冻结，留给自举后阶段。

---

## 十四、许可证

Shux 采用 **分层授权**（语言库宽松；编译器 copyleft）。详见 [`LICENSE`](LICENSE) 与 [`NOTICE`](NOTICE)。

| 层 | 路径 | 许可 |
|----|------|------|
| A — 工具链 | `compiler/`、`tools/`、根目录 `build*.x` | **AGPL-3.0-or-later**（[`LICENSE.AGPL-3.0`](LICENSE.AGPL-3.0)） |
| B — 语言库 | `core/`、`std/` | **Apache-2.0**（[`LICENSE.Apache-2.0`](LICENSE.Apache-2.0)） |
| 样例 | `examples/`、`tests/` | **Apache-2.0** |
| 编辑器 | `editors/vscode` | **Apache-2.0** |
| 编辑器 | `editors/tree-sitter-shux`、`editors/vim` | **Apache-2.0** |
| 第三方 | `compiler/seeds/crypto/ed25519/`（orlp） | **zlib** |

**意图：** 使用 `core`/`std` 编写的程序不会被强制 AGPL；修改或再分发 **编译器/工具链** 适用 AGPL（或商业条款）。

贡献约定：[`CONTRIBUTING.md`](CONTRIBUTING.md)。

### 商业许可（仅 Layer A）

若需对 **编译器/工具链** 做 **AGPL 豁免**（闭源嵌入、闭源分发修改后的工具链、修改后的网络服务不提供对应源码等），请联系：

- 舒良府（ShuLiangfu）— [admin@shuliangfu.com](mailto:admin@shuliangfu.com)

---

*Shux — 三高一低：比 C 更快 · 接近 Rust 的安全 · 比 C 更简单 · 按天上手。*
