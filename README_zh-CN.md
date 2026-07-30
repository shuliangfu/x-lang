# X 语言

> **写底层代码，终于可以又简单、又安全、又快。**  
> 你熟悉的 C 心智模型 · 接近 Rust 的内存安全、却不靠重型类型论 · 默认代码质量目标**超越**精心编写的 C · 学习成本以**天**计，不以月计。

| 项目 | 说明 |
|------|------|
| **语言名（中文）** | **X 语言** |
| **工具链短名** | `xlang` — 编译器命令、包名、仓库短名 |
| **编译器** | `xlang` / `xlang_asm`（自举链路后的产品二进制） |
| **源文件后缀** | `.x` |
| **构建配置** | `build.x` — 用 X 语言描述的项目构建策略（步骤、目标、产物）；由 `xlang build` / `build_tool` / `xlang-build.sh` 执行 |
| **现阶段（2026-07-31）** | **产品 L4 钉盘 `53fd80927`**（双端真冷 + bstrict **129/129**，wave710）。tip L4 安全网 **`f8be401e9`**（wave840 · **不升钉**）。`self-hosting` residual tip（Track MG **11.3.1** 叶 pattern residual · 日常 L2 · **≠** tip L4 重钉）。**尚未完全自举**（冷启动仍需 seed / 宿主 cc；`compiler/Makefile` 仍在 — 真删须 tip Windows 复证 + 双端 L4 + **explicit auth**） |
| **进度仪表盘** | [`analysis/自举进度.md`](analysis/自举进度.md) · 时序 [`analysis/自举时序.md`](analysis/自举时序.md) · 终局债 [`analysis/C迁移追踪.md`](analysis/C迁移追踪.md) · Makefile 映射 [`analysis/Makefile迁移表.md`](analysis/Makefile迁移表.md) · 叶 residual [`compiler/docs/LEAF_PATTERN_RESIDUAL.md`](compiler/docs/LEAF_PATTERN_RESIDUAL.md) |
| **English** | [README.md](README.md) |

---

## 一、为什么是 X 语言 — **三高一低**

**X 语言**（英文 **X language**）是一门面向内核、驱动、运行时与高性能工具的**系统级编程语言**：无 GC、零成本抽象、显式内存模型，可 freestanding。

多数语言逼你二选一。X 语言拒绝这个假选择：

| 支柱 | 目标 | 落地含义 |
|------|------|----------|
| **高性能** | **默认就比精心写的 C 更快** | 无 GC；默认 ASM 后端 + 可选 C 后端；激进别名 / `noalias`、BCE、泛型单态化；Arena / region 热路径零 malloc。性能主要靠**编译器**，不是每个调用点靠人肉优化 |
| **高安全** | **安全子集内接近 Rust** | 编译期 region / 借用 / 线性类型检查；`Option` / `Result` 优先于静默空指针；带长度切片；`unsafe` 仅用于硬件与 syscall 边界——**可审计**，不是默认可 UB |
| **高可读** | **比 C 更简单、更好维护** | `T[]` 自带长度；无头文件地狱（目录即模块）；`defer` / `with_arena` / 作用域分配器；字段访问只有 `.`；诊断带真实位置 |
| **低学习成本** | **C 程序员按「天」上手** | 控制流与心智模型接近 C；无 lifetime 注解迷宫；可渐进：先写「类 C」，再引入现代安全特性；`xlang build` / fmt / LSP 一体 |

**每条语言特性的评审铁律（最高优先级）：**

> *这会让 C 程序员觉得更麻烦吗？*  
> 会 → 砍掉、藏进编译器，或关进 `unsafe`。**「比 C 更简单」是设计评审的第一准则**；安全与性能由编译器智能补齐，而不是把负担推给作者。

### 诚实对照

| 对照 | X 语言的选择 |
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
# 推荐：pinned seed → build_tool → 日常 xlang
make -C compiler build-tool
./xlang-build.sh first-time          # build_tool + ./build_tool ./xlang
# 或：cd compiler && ./build_tool ./xlang

# 仅 cc 冷启动：cd compiler && sh bootstrap.sh

# 常见产品链：seed 驱动 + g05 relink
make -C compiler bootstrap-driver-seed
FULL=0 bash compiler/scripts/g05_prepare_and_relink.sh
```

### 日常构建

```bash
# 日常：G-05 → xlang_asm relink 金标准
./xlang-build.sh build
# 或：cd compiler && ./build_tool ./xlang

export XLANG=./compiler/xlang_asm   # 用本波产品二进制
./tests/run-hello.sh

# 改后端 / seed 后的重型重建
./xlang-build.sh full              # 或 make -C compiler bootstrap-driver-bstrict
```

| 入口 | 用途 |
|------|------|
| `./xlang-build.sh build` / `./build_tool ./xlang` | **日常增量**（默认） |
| `./xlang-build.sh full` | 全量 B-strict 风格重建 |
| `make -C compiler …` | 冷启动、CI、底层目标 |

**产品二进制**：构建成功后以 **`compiler/xlang_asm`** 为准（常同步为 `compiler/xlang`）。  
`xlang-c` / seed 工具只服务**冷启动与过渡**，不是日常发布面。

### Hello World

```x
// Hello World — void main 隐含 exit 0（Zig 风格）
const fmt = import("std.fmt");

function main(): void {
  fmt.println("Hello World");
}
```

```bash
export XLANG=./compiler/xlang_asm
$XLANG run examples/hello.x
$XLANG build examples/hello.x -o hello && ./hello
$XLANG check examples/hello.x
```

更多示例：[`examples/`](examples/)（io、net、async、json、compress 等）。

### 验收测试

```bash
export XLANG=./compiler/xlang_asm
./tests/run-all.sh
XLANG_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh   # 产品闸门（约 129 脚本）
./tests/run-linux-a09-a11-gate.sh
# Linux x86_64 freestanding S4 烟测（return42 / panic / hello）：
./tests/run-freestanding-hello.sh
```

凡谈**自举 / 产品放行**，项目要求 **L4 真冷**（擦除 `compiler`/`std`/`core` 下全部 `.o` 并重链二进制）+ **双端** `run-all-bstrict` 全绿。详见 [`analysis/自举方法.md`](analysis/自举方法.md)、[`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md)。  
**注意：** 日常 tip 的 L2 绿 **≠** tip L4 钉盘。**放行钉盘为 `53fd80927`**（双端真冷 129/129）。tip L4 安全网 `f8be401e9` **不升钉**（见 §八）。

---

## 四、编译器用法

默认 **ASM 后端**（`-backend asm`）。必须使用子命令，禁止隐式编译运行。

```bash
xlang [COMMAND] [OPTIONS]
```

### 子命令

| 命令 | 说明 | 用法 |
|------|------|------|
| `build` | 编译 .x 到二进制/目标文件（默认 a.out） | `xlang build [options] file.x [-o exe]` |
| `run` | 编译并运行 .x | `xlang run [options] file.x` |
| `check` | 仅 parse + typeck（不生成代码） | `xlang check [paths...]` |
| `fmt` | 格式化 .x 源码 | `xlang fmt [--check] [paths...]` |
| `explain` | 解释诊断代码 | `xlang explain <CODE>` |
| `test` | 运行测试脚本 | `xlang test [script.sh]` |

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
| `XLANG_ABI_F32_XMM=0` | 等同于 `-legacy-f32-abi`（x86_64 SysV） |
| `XLANG_OPT` | 默认 -O 级别 |
| `NO_COLOR` | 禁用彩色输出 |
| `CLICOLOR_FORCE=1` | 强制彩色输出（即使管道重定向） |
| `XLANG_FORCE_COLOR=1` | 等同于 CLICOLOR_FORCE |

### 示例

```bash
# 编译并运行
xlang run examples/hello.x

# 编译到可执行文件
xlang build examples/hello.x -o hello && ./hello

# 仅 parse + typeck
xlang check examples/hello.x

# 格式化源码
xlang fmt src/

# 解释诊断代码
xlang explain XP003

# 运行测试脚本
xlang test tests/run-all-bstrict.sh

# 语言服务器（stdio JSON-RPC）
xlang --lsp

# 强制 C 后端
xlang build -backend c file.x

# Freestanding（Linux x86_64 nostdlib）
xlang build -freestanding file.x
```

根目录 [`build.x`](build.x) 描述编什么。日常入口：`./xlang-build.sh` / `build_tool`。

---

## 五、仓库结构

```
xlang/
├── README.md / README_zh-CN.md
├── LICENSE · LICENSE.AGPL-3.0 · LICENSE.Apache-2.0 · NOTICE · CONTRIBUTING.md
├── build.x / xlang-build.sh
├── analysis/                 # 过程文档 + RFC（自举进度 / C迁移追踪 / Makefile迁移表 / 自举方法 / 自举步骤 …）
├── docs/                     # 语言语法（面向用户）
├── compiler/                 # 编译器（.x + seed C / glue）
│   ├── src/                  # lexer / parser / typeck / codegen / asm / pipeline / driver / lsp
│   ├── seeds/                # 冷启动 pin
│   ├── docs/SELFHOST.md
│   └── scripts/              # build_xlang_asm、g05、relink …
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
| **用户 / 产品轨** | 本 SHA 的 `xlang_asm` 编用户 `.x` → `-o` / 运行；矩阵 + bstrict |
| **自举 / 工程轨** | seed 冷启动 → `build_xlang_asm` / g05 → 可选 Stage2 / WPO dogfood |

**双轨（读进度时不要混）：**

| 轨道 | 测什么 | 能否单独说「自举完成」 |
|------|--------|------------------------|
| **产品轨** | L4 真冷 + 产品矩阵 + 双端 `run-all-bstrict` **129** | **必要**，但还不够宣称「永久零 C」 |
| **工程轨** | prove T/N、Cap residual pure、Stage2、WPO 链/链接/text 门 | **否** |

---

## 八、自举状态（摘要 · 2026-07-31）

> **实时数字以** [`analysis/自举进度.md`](analysis/自举进度.md) · 终局债 [`analysis/C迁移追踪.md`](analysis/C迁移追踪.md) · 叶 residual 地图 [`compiler/docs/LEAF_PATTERN_RESIDUAL.md`](compiler/docs/LEAF_PATTERN_RESIDUAL.md) **为准**。  
> README 只给摘要；**禁止**把 Stage2 / prove / WPO / **日常 L2 绿**写成 tip L4 重钉或「完全自举」。  
> **裸「继续下一步」≠ 物理删除 `compiler/Makefile`** — 终局真删须 tip Windows 复证 + 双端 L4 + **用户 explicit auth**。

### 产品轨

| 项 | 状态 |
|----|------|
| **L4 放行钉盘** | **`53fd80927`**（wave710 · 2026-07-29）— 双端 **真冷** + `run-all-bstrict` **129/129**（Ubuntu + macOS）。谱系前钉（如 `4fa4f07e7`、`deaf773b`…）**勿**写成现行钉盘 |
| 产品 bstrict 套件数 | **129**（`tests/run-all-bstrict.sh`；日志须 `OK (129 scripts…)`） |
| Ubuntu L4 + 全量 bstrict（钉盘） | ✅ **129/129** @ **`53fd80927`** |
| macOS L4 + 全量 bstrict（钉盘） | ✅ **129/129** @ **`53fd80927`** |
| tip L4 安全网（不升钉） | ✅ **`f8be401e9`**（wave840）— 证明 mid-endgame tip 可 L4；**钉盘仍 `53fd80927`** 直至显式升钉 |
| Windows hybrid / phys-del min-gate | ✅ STATUS=`reproven_green`（证据 tip）；**tip 漂移须复证** 才可谈真删 Makefile |
| 金标主机 | **Ubuntu x86_64** |
| 验收二进制 | 本波 g05 / relink 的 `compiler/xlang_asm` — **禁止**残留 Stage2 `xlang_asm2` 或旧 stage1 |
| 分支 residual tip（≠ tip L4） | `self-hosting` 上日常 MG（11.3.1 叶 residual · L2 双端 residual/ensure）。**精确 SHA 看仪表盘**；勿把 residual tip 当放行钉盘 |
| 最新 tip 日常 L2 | ✅ mac + Ubuntu residual / ensure / catalog 检查（**≠** tip L4 重钉） |

### 产品路径（今天「可用」指什么）

在**用户产品路径**（`xlang_asm` → `-o` / 运行 / freestanding / 门禁）上，钉盘已覆盖大量已收口面（net PRIMARY、bare struct lit、CTFE match 折叠、X ABI P0b、Windows hybrid gate、CLI help、`std.fmt` print 归属、freestanding S4 / NL-07、hosted asm 矩阵等）。  
**residual tip 的 L2 绿不会自动抬升 L4 钉盘。**

### Track MG · 终局（Makefile / 冷启动零业务 cc）

| 项 | 状态 |
|----|------|
| 目标 | 物理删除 `compiler/Makefile` + 冷启动不再用宿主 cc 编译业务 C（C 迁移 11–12） |
| 路径 | **11.3.1 叶 pattern residual** — 把 host-cc / multi-token / 列表库存吞进 shell + `compiler/mk/*.mk`（**尚未**物理删） |
| 树闸门 | `TREE_ARMED=1` · `BODY_SHIPPED=0` · `DELETE_ALLOWED=0` · `--delete` never-rm 直至 auth |
| preflight blockers（诚实） | thin-call edges · B7B lists-in-mk · std/core product make graph（名称会演进；见 residual dump） |
| 至 2026-07-31 进度 | 数百波 residual（list→mk、FORCE thin try-heat、shell-primary、env inject hygiene、R1/R2/R3/B1–B5 multi-target 族…）— **Makefile 仍在** |
| 前排 residual 例 | bootstrap_nostdlib_stubs（Linux guard）· net_merge · 其余 thin edges — 见 C迁移 open 行 / LEAF |

### 工程轨（量级）

| KPI / 门禁 | 状态 |
|------------|------|
| **T** | **18/18** |
| **EMPTY** | **18/18** |
| **N** prove IDENTICAL | **111/111** |
| Cap residual pure | 钉盘谱系上多波已收口；仅产品红时插队 |
| **D Stage2** | ✅ freestanding / 行为 parity（**≠** 产品 g05 全链） |
| Stage2 **WPO** 链 + strict-link + text-gate | ✅ 工程绿（Ubuntu；部分 Darwin N/A） |

### 明确不宣称

- **未**宣称「编译器已 100% `.x`、无 seed」
- **未**把 Stage2 的 `xlang_asm2` 当产品编译器
- **未**把工程 WPO 绿等同 tip 产品 L4
- **未**把「tip 双端 L2 residual 检查」写成 tip L4 —— 放行钉盘为 **`53fd80927`**，须下次双端 **真冷** 才重钉
- **未**把 Windows hybrid 绿当成产品 L4 / 自举完成 —— Windows 仅探针 / min-gate
- **未**把「11.3.1 residual 收口」写成「Makefile 已删」—— 真删是后续终局波且要 **explicit auth**
- 终局物理零 C / 彻底去掉 seed（**G**）仍在路线图，不是本周叙事

方法：Cap / R / L / M → [`analysis/自举方法.md`](analysis/自举方法.md)。时序：[`analysis/自举时序.md`](analysis/自举时序.md)。运维：[`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md)。纪律：[`AGENTS.md`](AGENTS.md) + skill `xlang-selfhost-product-gate`。

### 近端前排（高层）

1. **11.3.1 residual（非删）** — 收完剩余 thin edges / mk lists hybrid；residual tip 双端 L2  
2. **tip Windows 复证** → **双端 L4**（谈终局时）→ **explicit auth** 真删 Makefile  
3. Cap 硬叶仅在产品矩阵红时插队 — **禁** soft-skip typeck、**禁**双权威、**禁**无地图 tip L4 升钉  

## 九、里程碑

| 里程碑 | 内容 | 状态 |
|--------|------|------|
| M0 | Lexer、AST、Parser | ✅ |
| M1 | Typeck、Codegen、Driver | ✅ |
| M2 | import、core/std 子集、多目标 | ✅ |
| M3 | 泛型、trait、模块、std 扩张 | ✅ |
| M4 | DCE、-O2/-Os、体积/性能基线 | ✅ 部分 |
| M5 | 自举（编译器可重编自身） | 🟡 **产品路径可用 + 自举推进中**；**冷启动仍需 seed**；Makefile residual 路径仍开 |
| **当前** | 产品 L4 双端钉盘 @ **`53fd80927`**（129/129）；tip L4 安全网 **`f8be401e9`**；residual MG **11.3.1**（日常 L2 · **未** tip L4 升钉） | 见仪表盘 |

---

## 十、文档索引

| 文档 | 内容 |
|------|------|
| [`analysis/自举进度.md`](analysis/自举进度.md) | **KPI 仪表盘**（每波必改） |
| [`analysis/自举时序.md`](analysis/自举时序.md) | 自举先→后（S0–S8）· 换 IDE 协议 |
| [`compiler/docs/LEAF_PATTERN_RESIDUAL.md`](compiler/docs/LEAF_PATTERN_RESIDUAL.md) | 11.3.1 叶 residual 人读地图 |
| [`analysis/C迁移追踪.md`](analysis/C迁移追踪.md) | 终局债地图（MG / 删 Makefile DAG） |
| [`analysis/Makefile迁移表.md`](analysis/Makefile迁移表.md) | Makefile → xbuild 叶映射 |
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
| 产品 bstrict | `XLANG=./compiler/xlang_asm XLANG_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh` |
| 推送前 P0 | `XLANG=./compiler/xlang_asm ./tests/run-pre-push-p0.sh` |
| Linux 金标子集 | `./tests/run-linux-a09-a11-gate.sh` |
| 主题门禁 | `tests/run-*-gate.sh` |
| 编译 dogfood | `XLANG_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh` |

基线目录：`tests/baseline/`。跑 **真冷全测** 时，应把日志路径打印给操作者（如 `/tmp/*true_cold*`、`/tmp/*true_bstrict*`），便于盯进度。

### 性能快照（历史 · 2026-07-09 · Linux x86_64）

相对 `clang -O2` 墙钟中位数（预热 3 + 20 轮）。刷新流程见 `analysis/perf-*`。

| 用例 | ratio（XLANG / C） | 备注 |
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
| LSP | `xlang --lsp` · `compiler/src/lsp/` |
| MCP | [`mcp/`](mcp/) |

插件安装：[`editors/vscode/README.md`](editors/vscode/README.md)。

---

## 十三、贡献

1. 克隆 → `make -C compiler build-tool && ./xlang-build.sh first-time`（或完整 bootstrap-driver 路径）。  
2. 日常改动 → `./xlang-build.sh build`，`XLANG=./compiler/xlang_asm`，跑相关测试 / gate。  
3. 产品 / 链接 / SHARED 改动 → **Ubuntu 金标**（SHARED 再加 mac）；谈放行须 **L4 真冷** + 双端 bstrict **129**（钉盘 `53fd80927` 直至显式升钉）。  
4. 提交：Conventional Commits（`feat:` / `fix:` / `docs:` …）；`.x` 新注释用英文（见 `AGENTS.md` / G.9）。  
5. **禁止双权威**：seed 与 `.x` 产品面必须同 commit 对齐。  
6. **禁止假绿**：不得仅凭 prove / Stage2 / WPO 宣称自举完成。

**当前决议**：自举 / 产品闸门优先于大规模 std 新功能；IR v4 架构已冻结，留给自举后阶段。

---

## 十四、许可证

X 语言采用 **分层授权**（语言库宽松；编译器 copyleft）。详见 [`LICENSE`](LICENSE) 与 [`NOTICE`](NOTICE)。

| 层 | 路径 | 许可 |
|----|------|------|
| A — 工具链 | `compiler/`、`tools/`、根目录 `build*.x` | **AGPL-3.0-or-later**（[`LICENSE.AGPL-3.0`](LICENSE.AGPL-3.0)） |
| B — 语言库 | `core/`、`std/` | **Apache-2.0**（[`LICENSE.Apache-2.0`](LICENSE.Apache-2.0)） |
| 样例 | `examples/`、`tests/` | **Apache-2.0** |
| 编辑器 | `editors/vscode` | **Apache-2.0** |
| 编辑器 | `editors/tree-sitter-xlang`、`editors/vim` | **Apache-2.0** |
| 第三方 | `compiler/seeds/crypto/ed25519/`（orlp） | **zlib** |

**意图：** 使用 `core`/`std` 编写的程序不会被强制 AGPL；修改或再分发 **编译器/工具链** 适用 AGPL（或商业条款）。

贡献约定：[`CONTRIBUTING.md`](CONTRIBUTING.md)。

### 商业许可（仅 Layer A）

若需对 **编译器/工具链** 做 **AGPL 豁免**（闭源嵌入、闭源分发修改后的工具链、修改后的网络服务不提供对应源码等），请联系：

- 舒良府（ShuLiangfu）— [admin@shuliangfu.com](mailto:admin@shuliangfu.com)

---

*X 语言 — 三高一低：比 C 更快 · 接近 Rust 的安全 · 比 C 更简单 · 按天上手。*
