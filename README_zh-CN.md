# X 语言

> **写底层代码，终于可以又简单、又安全、又快。**
>
> 熟悉的命令式风格 · 接近 Rust 的内存安全、却不靠重型类型论 · 默认代码质量目标**超越**精心编写的 C · 学习成本以**天**计，不以月计。

| | |
|--|--|
| **语言名** | **X 语言**（英文 **X language**） |
| **工具链短名** | `xlang` — 编译器命令、包名、仓库短名 |
| **编译器二进制** | `xlang` / `xlang_asm`（完整构建后的产品二进制） |
| **源文件后缀** | `.x` |
| **项目构建** | `build.x` — 用 X 语言描述构建策略（`xlang build` / `build_tool` / `xlang-build.sh`） |
| **现阶段（2026-07-31）** | **产品 L4 钉盘 `77b334842`**（MG Makefile 已删 · 双端真冷血缘）。历史双端 bstrict 钉 **`9bb7a757c`**（129/129）在显式升钉前仍作历史金标。tip residual 在 `self-hosting`（MG **编排层已删 Makefile** · 0-make hub wave944 · 文档 residual wave945）。**尚未完全自举** — 冷启动仍需 seed / 宿主 `cc`。 |
| **进度仪表盘** | [自举进度](analysis/自举进度.md) · [自举时序](analysis/自举时序.md) · [C 迁移债](analysis/C迁移追踪.md) · [Makefile 映射](analysis/Makefile迁移表.md) · [叶 residual](compiler/docs/LEAF_PATTERN_RESIDUAL.md) |
| **English** | [README.md](README.md) |

---

## 目录

1. [语言特性概览](#一语言特性概览)
2. [快速开始](#二快速开始)
3. [编译器用法](#三编译器用法)
4. [仓库结构](#四仓库结构)
5. [标准库](#五标准库)
6. [编译器架构](#六编译器架构)
7. [自举状态](#七自举状态摘要--2026-07-31)
8. [里程碑](#八里程碑)
9. [测试与质量](#九测试与质量)
10. [工具链生态](#十工具链生态)
11. [为什么是 X 语言 — 三高一低](#十一为什么是-x-语言--三高一低)
12. [贡献](#十二贡献)
13. [许可证](#十三许可证)

---

## 一、语言特性概览

### 类型与语义

- **基础类型** — `i8`/`i16`/`i32`/`i64`，`u8`/`u16`/`u32`/`u64`，`f32`/`f64`，`bool`，`usize`/`isize`
- **结构体与泛型** — 泛型单态化；trait / impl
- **可空与错误** — `Option<T>`、`Result<T, E>`（优先于 C 式裸可空指针）
- **切片** — `T[]` 带长度；域标注 `T[]<label>` + 逃逸检查
- **模块** — `import("std.io")` / `import("core.mem")`；**目录即模块**，入口 `mod.x`
- **字段访问** — 源语言**只有 `.`**，没有 `->`（指针上的 C `->` 由 codegen 按类型决定）

### 内存与安全

- **无 GC** — 栈 + 堆 + Arena；编译期 region / 线性 / 借用拒错
- **编译期辅助** — `defer`、`owned`、作用域分配器（`with_arena`）、SROA、BCE
- **分级安全** — 默认安全；裸指针与底层 syscall 仅在 `unsafe { ... }`
- **别名分析** — `noalias` 与借用门控，服务 autovec / DCE

详见 [编译时内存与自动向量化](analysis/编译时自动内存管理和自动向量化.md) · [安全与性能](analysis/安全与性能.md)。

### 平台

- 条件编译（`#if` / target 分支）
- **一套 API，多 OS** — Linux / macOS 为主产品路径；Windows hybrid / 探针
- Freestanding：`-freestanding`（Linux x86_64 nostdlib 静态路径）
- 目标如 `x86_64-linux`、`arm64-macos`（`-target`）

语法索引：[docs/README.md](docs/README.md)。

#### 支持等级（策略）

**不为每个 OS 小版本都准备必测虚拟机。** 用清晰等级管理预期，只对「官方支持」做严格测试：

| 等级 | 含义 | 我们怎么做 |
|------|------|------------|
| **Tier 1 — 官方支持** | 文档保证、CI 覆盖、出问题优先修 | 只覆盖下表中的**代表性**主机 |
| **Tier 2 — 尽力支持** | 能编能跑即可，不保证 | 成本低或有用户反馈时再修 |
| **Tier 3 — 不支持** | 不测试、不承诺 | 文档写明，避免不切实际期望 |

**与工程金标的关系（和等级正交）：**

| 角色 | 主机 | 说明 |
|------|------|------|
| **金标实验室宿主** | **Ubuntu x86_64** | 可复现的 L4 / 产品门禁真值；禁止单靠 macOS 绿结案 SHARED 债 |
| **产品双端** | Ubuntu x86_64 + **macOS** | 放行钉盘须 L4 真冷 + 全量 `run-all-bstrict` |
| **Windows** | MSYS2 / MinGW **hybrid** 探针 | hybrid 绿 ≠ 产品 L4 / 自举完成 |

**产品 vs 宿主（不要混）：**

| 层次 | 政策 |
|------|------|
| **用户产品二进制** | 目标是路径上的 **去 libc / freestanding**（`-freestanding`、crt0、syscall / `std.sys`、Linux x86_64 nostdlib 静态等）。**X 不是「依赖 glibc 的语言」。** 金标选 Ubuntu **不等于**「发货程序依赖 glibc」。 |
| **宿主 OS 实验室** | 仍需要**代表性机器**来编工具链、跑 CI、钉 L4。实验室优先 **Ubuntu x86_64**——为的是可复现，**不是**把 glibc 当成永久产品 ABI。 |
| **自举残留** | 在自举未完成前，部分**编译器构建 / hybrid / seed** 步骤仍可能碰到宿主 `cc`/`ld` 或系统 C 库。那是**工程残留**，不是终态产品契约。问「我的程序要不要 libc？」请优先看 freestanding 门禁。 |

Linux 宿主更关心 **内核年代 + 架构 + 目标格式（ELF）** 以及**用什么宿主工具编出了编译器**，不是「每个 glibc 点版本」。发行版上的 libc（glibc vs musl）仍可能影响**宿主 bootstrap 怪癖**与残留 hosted 链接——**不是**我们对外宣传的产品 ABI。macOS 看 **Darwin 大版本 + 架构**（arm64 优先）。Windows 看 **Win10/11 + x64 工具链**，不是每个 build 号。

**Alpine 是支持的宿主**（CI Docker 烟测、musl 宿主事实）。它**不是**金标**实验室**宿主：放行钉 / L4 真值仍是 **Ubuntu x86_64**。Alpine 上完整 B-strict / L4 自举对齐走自举后轨道（A-13），**不是**「不修」。产品 freestanding 在 Alpine 上与 Ubuntu 一样走 **产品无 libc** 目标，前提是宿主工具链路径本身是绿的。

#### 官方矩阵 — Linux（实验室宿主：Ubuntu + Alpine …）

| 平台 | 架构 | 等级 | 说明 |
|------|------|------|------|
| **Ubuntu 24.04 LTS** | x86_64 | **1** | 当前主流 LTS 实验室；CI（`ubuntu-latest` / 24.04 线） |
| **Ubuntu 22.04 LTS** | x86_64 | **1** | 金标邻近 LTS 实验室；CI `ubuntu-22.04`；Docker gate 常钉 22.04 |
| **Ubuntu 26.04 LTS**（作为主机使用时） | x86_64 | **1** | 新 LTS 纳入主实验室后与 22.04/24.04 同级 |
| **Alpine Linux** | x86_64 | **2** | **支持宿主**；CI `docker-distro`（`alpine:3.x`）；本地 `scripts/docker-ci-local.sh alpine`；宿主事实见 `XLANG_HOST_ALPINE` / platform linker 文档。宿主 bootstrap 可能不同（musl 时代工具、默认栈等）；产品 freestanding 仍目标 **无 libc**。**非金标实验室**：L4 / 放行钉仍 Ubuntu x86_64；Alpine 上完整 B-strict 自举延后（A-13），**不是不支持** |
| **Ubuntu 24.04 / 当前** | aarch64 | **2** | CI 探针（`ubuntu-24.04-arm`）；非产品金标实验室 |
| **Ubuntu 20.04 LTS** | x86_64 | **2** | 后期 LTS；宿主工具链够新时多半可跑 |
| 其他 Linux 发行版（Debian、Fedora、Arch 等） | x86_64 | **2** | 尽力实验室宿主。报 bug 请带：**发行版 + 架构 + 内核**、构建模式（**freestanding vs hosted**）、若是**编编译器**失败再附 **宿主工具链**（`cc`/`ld` 版本）——**不要**把「glibc 版本」当成产品 ABI 必备字段 |
| **Ubuntu 18.04 及更早** / 过旧宿主用户态 | * | **3** | 已 EOL；实验室软件包 / 工具链过旧 |

#### 官方矩阵 — macOS

| 平台 | 架构 | 等级 | 说明 |
|------|------|------|------|
| **macOS 14 Sonoma** | **arm64**（Apple Silicon） | **1** | CI `macos-14` |
| **macOS 15 Sequoia** 与 **macOS 26.x**（当前 Apple 大版本线） | **arm64** | **1** | CI `macos-latest` 跟随 runner 镜像；主要 mac 开发机 |
| macOS 14+ | **x86_64**（Intel） | **2** | 可能可用；非 CI 主路径；Intel Mac 在收缩 |
| **macOS 13 Ventura** | arm64 / x86_64 | **2** | 尽力支持；无专用 CI 钉 |
| **macOS 12 Monterey 及更早** | * | **3** | 不支持（Xcode / SDK / 链接器预期过旧） |
| iOS / iPadOS / tvOS 作为**宿主**构建 OS | * | **3** | 非宿主平台（交叉目标另论） |

**macOS 一句话策略：** 官方支持 = **Apple Silicon + 近 2～3 个大版本（14+）**。更旧 macOS 与 Intel 为尽力或不支持——不为它们长期堆虚拟机。

#### 官方矩阵 — Windows

| 平台 | 架构 | 等级 | 说明 |
|------|------|------|------|
| **Windows 11** | x64 | **1** | 优先 Windows 宿主；CI `windows-latest`；MSYS2 / MinGW hybrid 路径 |
| **Windows 10 22H2+** | x64 | **2** | 用户基数仍大；按需本地/云复现，不保证与 Win11 同级 |
| Windows 10 22H2 之前 | x64 | **3** | 不纳入目标 |
| **Windows 7 / 8 / 8.1** | * | **3** | **明确不支持**（EOL、安全与现代工具链均不成立） |
| Windows 11 / 10 | ARM64 | **2** | 实验 / 尽力；非 CI 主路径 |
| 纯 MSVC PE 产品路径 | * | **2** | 当前门禁锻炼的是 MinGW hybrid |

Windows 现状是**产品路径上的 hybrid / min-gate 绿**，不是「完整自举 L4 金标」。详见 [自举状态](#七自举状态摘要--2026-07-31)；有文档时见 [Windows 平台限制与测试指南](analysis/Windows平台限制与测试指南.md)。

#### 明确不支持（Tier 3 — 勿默认会修）

| 项 | 原因 |
|----|------|
| Windows 7 / 8 / 8.1 | 长期 EOL；无现代安全 / 工具链故事 |
| Windows 10 早于 22H2 | 超出本项目支持窗口 |
| macOS 12 及更早 | SDK / ld64 / 系统预期过旧 |
| Ubuntu 18.04 及更早 | LTS 已 EOL；过旧宿主用户态 / 软件包 |
| 「每个 Ubuntu / Windows / macOS 小版本都要独立 VM」 | **政策明确不做** — 用等级 + 代表性**实验室**宿主 |

**不是 Tier 3：** Alpine — **Tier 2 支持宿主**（见 Linux 矩阵）。金标是 **Ubuntu x86_64 作为 L4 实验室**，不是「产品必须 glibc / musl 不支持」。

#### 测试资源怎么安排（性价比）

| 层级 | 覆盖 |
|------|------|
| **CI 为主** | Ubuntu 22.04 + 当前 Ubuntu LTS 线；**Alpine + Debian slim**（`docker-distro`）；macOS 14 + `macos-latest`；Windows 最新（hybrid gate） |
| **本地 / 实验室（少量即可）** | 1× Ubuntu LTS（金标）、1× macOS arm64、可选 1× Win11（仅在确有 Win10 用户压力时再加 Win10）；Alpine 用 Docker 即可，不必常备 Alpine 虚拟机 |
| **云实例按需** | 出现可疑平台问题再临时开对应版本复现，比长期囤旧 VM 划算 |

**不会**为 Win7/Win8 或每个 Ubuntu 中间版本长期维护官方虚拟机。Tier 2/3 用户不应默认获得与放行钉盘同级的质量承诺。

---

## 二、快速开始

### 环境要求

- 优先使用上文[支持等级与平台矩阵](#支持等级策略)中的 **Tier 1** 主机（Tier 2 请接受「尽力」）：**Ubuntu x86_64（金标）** 或 **macOS arm64（14+）**；Windows 11 x64 用于 hybrid 探针
- 宿主 C 工具链（`cc` / `clang`；Windows 上 hybrid 路径用 MSYS2 / MinGW）
- 可选：Docker 跑 Linux gate（常见 `ubuntu:22.04`；Alpine 用 `scripts/docker-ci-local.sh alpine` / CI `docker-distro`）

### 首次构建

```bash
# 推荐产品入口（Makefile 已删 — wave942；0-make hub wave944）
./xbuild build-tool                  # pinned seeds → build_tool
./xbuild first-time                  # build_tool + 日常 g05
# 或：./xlang-build.sh first-time

# 仅 cc 冷启动（最小）：
#   cd compiler && sh bootstrap.sh

# 完整 seed 驱动（常用产品 / LSP 路径）：
./xbuild bootstrap-driver-seed
FULL=0 bash compiler/scripts/g05_prepare_and_relink.sh
```

### 日常构建

```bash
# 日常：G-05 → xlang_asm relink
./xbuild build
# 或：./xlang-build.sh build

export XLANG=./compiler/xlang_asm   # 本波产品二进制
./tests/run-hello.sh

# 改后端 / seed 后的重型重建
./xbuild full                        # bootstrap-driver-bstrict 路径
```

| 入口 | 用途 |
|------|------|
| `./xbuild build` / `./xlang-build.sh build` | **日常增量**（默认） |
| `./xbuild full` | 全量 B-strict 风格重建 |
| `./xbuild bootstrap-driver-seed` | 冷启动 seed 驱动 / LSP 二进制 |
| `./xbuild compiler-make <target>` | 残余叶 `.o` / CI hub（0-make） |

**产品二进制** — 构建成功后以 **`compiler/xlang_asm`** 为准（常同步为 `compiler/xlang`）。  
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

更多示例：[examples/](examples/)（io、net、async、json、compress 等）。

### 验收测试

```bash
export XLANG=./compiler/xlang_asm
./tests/run-all.sh
XLANG_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh   # 产品闸门（约 129 脚本）
./tests/run-linux-a09-a11-gate.sh
./tests/run-freestanding-hello.sh  # Linux x86_64 freestanding S4 烟测
```

凡谈**自举 / 产品放行**，项目要求 **L4 真冷**（擦除 `compiler` / `std` / `core` 下**全部** `.o` 并重链二进制）+ **双端** `run-all-bstrict` 全绿。

详见 [自举方法](analysis/自举方法.md) · [SELFHOST.md](compiler/docs/SELFHOST.md)。

> **日常 tip 的 L2 绿 ≠ tip L4 钉盘。**  
> 放行钉盘仍为 **`9bb7a757c`**（双端真冷 129/129），须显式升钉才会变。  
> tip 双端 L4 候选 **`eef4d7743`** 与安全网 **`ec773fe95`** **不会自动升钉**（见 [§七](#七自举状态摘要--2026-07-31)）。

---

## 三、编译器用法

默认 **ASM 后端**（`-backend asm`）。

```bash
xlang [COMMAND] [OPTIONS]
```

### 子命令

| 命令 | 说明 | 用法 |
|------|------|------|
| `build` | 编译 `.x` 到二进制 / 目标文件（默认 `a.out`） | `xlang build [options] file.x [-o exe]` |
| `run` | 编译并运行 `.x` | `xlang run [options] file.x` |
| `check` | 仅 parse + typeck（不生成代码） | `xlang check [paths...]` |
| `fmt` | 格式化 `.x` 源码 | `xlang fmt [--check] [paths...]` |
| `explain` | 解释诊断代码 | `xlang explain <CODE>` |
| `test` | 运行测试脚本 | `xlang test [script.sh]` |

### 构建选项（`build` / `run`）

| 选项 | 说明 |
|------|------|
| `-backend asm\|c` | 后端（默认 `asm`） |
| `-O <0\|1\|2\|3\|s>` | 优化级别（默认 `2`） |
| `-o <path>` | 输出二进制或 `.o` |
| `-L <dir>` | 库搜索路径 |
| `-target <triple>` | 目标三元组（如 `aarch64-linux-gnu`） |
| `-target-cpu <cpu>` | `native` \| `generic` \| `avx2` \| … |
| `-freestanding` | Nostdlib 静态链接（Linux x86_64 ELF） |
| `-legacy-f32-abi` | 传统 SysV f32 CALL（f64 扩展；默认 xmm ABI） |
| `-E` | 输出 C（调试） |
| `-flto` | 链接时优化（C 后端） |

### 全局选项

| 选项 | 说明 |
|------|------|
| `--print-target-cpu` | 打印宿主 CPU 特性并退出 |
| `--explain <CODE>` | 打印诊断代码解释并退出 |
| `--help`、`-h` | 显示帮助 |

### 环境变量

| 变量 | 效果 |
|------|------|
| `XLANG_ABI_F32_XMM=0` | 等同于 `-legacy-f32-abi`（x86_64 SysV） |
| `XLANG_OPT` | 默认 `-O` 级别 |
| `NO_COLOR` | 禁用彩色输出 |
| `CLICOLOR_FORCE=1` | 强制彩色输出（即使管道重定向） |
| `XLANG_FORCE_COLOR=1` | 等同于 `CLICOLOR_FORCE` |

### 示例

```bash
xlang run examples/hello.x
xlang build examples/hello.x -o hello && ./hello
xlang check examples/hello.x
xlang fmt src/
xlang explain XP003
xlang test tests/run-all-bstrict.sh
xlang --lsp                              # 语言服务器（stdio JSON-RPC）
xlang build -backend c file.x
xlang build -freestanding file.x         # Linux x86_64 nostdlib
```

根目录 [build.x](build.x) 描述编什么。日常入口：`./xlang-build.sh` / `build_tool`。

---

## 四、仓库结构

```
xlang/
├── README.md · README_zh-CN.md
├── LICENSE · LICENSE.AGPL-3.0 · LICENSE.Apache-2.0 · NOTICE · CONTRIBUTING.md
├── build.x · xlang-build.sh · xbuild/
├── analysis/                 # 过程文档、RFC、自举仪表盘
├── docs/                     # 语言语法（面向用户）
├── compiler/                 # 编译器（.x + seed C / glue）
│   ├── src/                  # lexer · parser · typeck · codegen · asm · pipeline · driver · lsp
│   ├── seeds/                # 冷启动 pin
│   ├── mk/                   # driver-seed 列表权威（叶 residual 路径）
│   ├── docs/SELFHOST.md
│   └── scripts/              # build_xlang_asm、g05、relink …
├── core/                     # 无 OS 依赖的核心库
├── std/                      # 面向 OS 的标准库（产品 .x；std 下无手写 .c）
├── tests/                    # 回归与产品闸门
├── examples/
├── tools/ · scripts/
├── runtime/                  # freestanding / 底层运行时支持
└── editors/                  # vscode · vim · tree-sitter
    └── vscode/               # VS Code / Cursor / Trae + LSP 客户端
```

- **`core/`** 不依赖 **`std/`**；**`std/`** 可依赖 **`core/`**
- 模块规则：**目录即模块**，入口 `mod.x`

架构说明（历史叙事）：[构架分析.md](analysis/archive/narrative/构架分析.md)。

---

## 五、标准库

### `core`（无 OS）

| 模块 | 职责 |
|------|------|
| `core.types` | `size_of` / `align_of`、布局 |
| `core.mem` | 内存操作 |
| `core.option` / `core.result` | 可空 / 错误 |
| `core.slice` / `core.str` | 切片与字符串视图 |
| `core.fmt` / `core.debug` | 格式化 / 调试 |
| `core.builtin` / `core.iterator` / `core.cmp` | 内置、迭代、比较 |

完整列表：[docs/07-内置与标准库.md](docs/07-内置与标准库.md)。

### `std`（面向 OS）

`std/` 产品源为 **`.x`**（阶段 F：`std/` 下无手写 `.c` / `.h`）。覆盖面包括：

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

**按需入链** — 尽量不把未用模块拖进最终链接。

---

## 六、编译器架构

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
| **用户 / 产品轨** | 本 SHA 的 `xlang_asm` 编用户 `.x` → `-o` / 运行；产品矩阵 + bstrict |
| **自举 / 工程轨** | seed 冷启动 → `build_xlang_asm` / g05 → 可选 Stage2 / WPO dogfood |

### 双轨（读进度时不要混）

| 轨道 | 测什么 | 能否单独说「自举完成」 |
|------|--------|------------------------|
| **产品轨** | L4 真冷 + 产品矩阵 + 双端 `run-all-bstrict` **129** | **必要**，但还不够宣称「永久零 C」 |
| **工程轨** | prove T/N、Cap residual pure、Stage2、WPO 链 / 链接 / text 门 | **否** |

---

## 七、自举状态（摘要 · 2026-07-31）

> **实时数字以** [自举进度.md](analysis/自举进度.md) · [C迁移追踪.md](analysis/C迁移追踪.md) · [LEAF_PATTERN_RESIDUAL.md](compiler/docs/LEAF_PATTERN_RESIDUAL.md) **为准**。  
> README 只给摘要；**禁止**把 Stage2 / prove / WPO / **日常 L2 绿**写成 tip L4 重钉或「完全自举」。  
> **Makefile 物理删除已完成**（wave941/942 · 钉盘谱系 **`77b334842`**）。裸「继续下一步」指 post-delete residual（0-make hub、文档、gate）— **不是**再 auth 真删。

### 产品轨

| 项 | 状态 |
|----|------|
| **L4 放行钉盘（post-MG）** | **`77b334842`**（wave942）— Makefile 删除 + catalog CFLAGS；tip residual 继续在 `self-hosting` |
| 历史双端 bstrict 钉 | **`9bb7a757c`**（wave710）— 双端真冷 + **129/129**；显式升钉前不自动替换 |
| 产品 bstrict 套件 | **129**（`tests/run-all-bstrict.sh`；日志须 `OK (129 scripts…)`） |
| Ubuntu L4 + 全量 bstrict（历史钉） | ✅ **129/129** @ **`9bb7a757c`** |
| macOS L4 + 全量 bstrict（历史钉） | ✅ **129/129** @ **`9bb7a757c`** |
| tip L4 安全网（不升钉） | ✅ **`ec773fe95`**（wave840） |
| tip 双端 L4 候选（不升钉） | ✅ **`eef4d7743`**（wave923）— 升钉须显式决定 |
| Windows hybrid / phys-del min-gate | ✅ 已复证绿（wave922 谱系）；tip 漂移仍须复证 |
| 金标主机 | **Ubuntu x86_64** |
| 验收二进制 | 本波 g05 / relink 的 `compiler/xlang_asm` — **禁止**残留 Stage2 `xlang_asm2` 或旧 stage1 |
| 分支 residual tip（≠ 放行钉盘） | post-delete MG residual（0-make hub · 文档）。**精确 SHA 看仪表盘** |

### 今天「可用」指什么

在**用户产品路径**（`xlang_asm` → `-o` / 运行 / freestanding / 门禁）上，放行钉盘已覆盖大量已收口面——net PRIMARY、bare struct lit、CTFE match 折叠、X ABI P0b、Windows hybrid gate、CLI help、`std.fmt` print 归属、freestanding S4 / NL-07、hosted asm 矩阵等。

**residual tip 的 L2 绿不会自动抬升 L4 钉盘。**

### Track MG · 终局（Makefile / 冷启动零业务 cc）

| 项 | 状态 |
|----|------|
| 目标 | 物理删除 `compiler/Makefile` + 冷启动不再用宿主 cc 编译业务 C（C 迁移 11–12） |
| Makefile | ✅ **已删**（wave941/942）— 产品入口仅为 **`./xbuild`** / `./xlang-build.sh` |
| 0-make hub | ✅ `tests/lib/compiler-make.sh`（wave944）· 文档/hint（wave945） |
| 仍开 | BC/PC 零 host-cc · 去 seed · 升钉 · 阶段 12 冷启动重设计 |

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
- **未**把「tip 双端 L2 residual 检查」写成 tip L4 —— 放行钉盘为 **`9bb7a757c`**，须下次双端 **真冷** 才重钉
- **未**把 Windows hybrid 绿当成产品 L4 / 自举完成
- **未**把「Makefile 已删」写成「自举 / 零 host-cc 完成」— seed + BC/PC 仍在
- 终局物理零 C / 彻底去掉 seed（**G**）仍在路线图，不是本周叙事

方法：[自举方法.md](analysis/自举方法.md) · 时序：[自举时序.md](analysis/自举时序.md) · 运维：[SELFHOST.md](compiler/docs/SELFHOST.md) · 纪律：[AGENTS.md](AGENTS.md) + skill `xlang-selfhost-product-gate`。

### 近端前排

1. **post-delete residual** — 保持 0-make hub + 文档诚实；禁止再引入 `make -C`  
2. **SHARED 波后谈产品绿** → Ubuntu 金标 L4  
3. **升钉** 须显式决定 + 双端真冷 — **禁** soft-skip typeck、**禁**双权威

---

## 八、里程碑

| 里程碑 | 内容 | 状态 |
|--------|------|------|
| M0 | Lexer、AST、Parser | ✅ |
| M1 | Typeck、Codegen、Driver | ✅ |
| M2 | import、core/std 子集、多目标 | ✅ |
| M3 | 泛型、trait、模块、std 扩张 | ✅ |
| M4 | DCE、`-O2`/`-Os`、体积 / 性能基线 | ✅ 部分 |
| M5 | 自举（编译器可重编自身） | 🟡 **产品路径可用 + 自举推进中**；**冷启动仍需 seed**；MG Makefile **已删**（0-make） |
| **当前** | post-MG 钉 **`77b334842`**；历史双端 bstrict **`9bb7a757c`**（129/129）；tip 双端 L4 候选 **`eef4d7743`** | 见 [仪表盘](analysis/自举进度.md) |

---

## 九、测试与质量

| 套件 | 命令 |
|------|------|
| 全量回归 | `./tests/run-all.sh` |
| 产品 bstrict | `XLANG=./compiler/xlang_asm XLANG_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh` |
| 推送前 P0 | `XLANG=./compiler/xlang_asm ./tests/run-pre-push-p0.sh` |
| Linux 金标子集 | `./tests/run-linux-a09-a11-gate.sh` |
| 主题门禁 | `tests/run-*-gate.sh` |
| 编译 dogfood | `XLANG_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh` |

基线目录：`tests/baseline/`。跑 **真冷全测** 时，应把日志路径打印给操作者（如 `/tmp/*true_cold*`、`/tmp/*true_bstrict*`）。

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

## 十、工具链生态

| 组件 | 路径 |
|------|------|
| VS Code / Cursor / Trae | [editors/vscode/](editors/vscode/) |
| Vim | [editors/vim/](editors/vim/) |
| Tree-sitter | [editors/tree-sitter-xlang/](editors/tree-sitter-xlang/) |
| LSP | `xlang --lsp` · `compiler/src/lsp/` |

插件安装：[editors/vscode/README.md](editors/vscode/README.md)。

---

## 十一、为什么是 X 语言 — **三高一低**

**X 语言**是一门面向内核、驱动、运行时、嵌入式与高性能工具的**系统级编程语言**：无 GC、零成本抽象、显式内存模型，可 freestanding。

多数语言逼你二选一。X 语言拒绝这个假选择：

| 支柱 | 目标 | 落地含义 |
|------|------|----------|
| **高性能** | **默认就比精心写的 C 更快** | 无 GC；默认 ASM 后端（+ 可选 C 后端）；激进别名 / `noalias`、BCE、泛型单态化；Arena / region 热路径零 malloc。性能主要靠**编译器**，不是每个调用点靠人肉优化。 |
| **高安全** | **安全子集内接近 Rust** | 编译期 region / 借用 / 线性类型检查；`Option` / `Result` 优先于静默空指针；带长度切片；`unsafe` 仅用于硬件与 syscall 边界——**可审计**，不是默认可 UB。 |
| **高可读** | **比 C 更简单、更好维护** | `T[]` 自带长度；无头文件地狱（目录即模块）；`defer` / `with_arena` / 作用域分配器；字段访问只有 `.`；诊断带真实位置。 |
| **低学习成本** | **有编程基础，按「天」上手** | 不要求先啃类型论：有一门命令式语言基础（C / C++ / Java / Go / **JS / TS** / …）即可。控制流直观，无 lifetime 注解迷宫；可渐进——先写「类 C」风格，再引入现代安全特性；`xlang build` / `fmt` / LSP 一体。 |

**每条语言特性的评审铁律：**

> *这会让 C 程序员觉得更麻烦吗？*  
> 会 → 砍掉、藏进编译器，或关进 `unsafe`。  
> **「比 C 更简单」是设计评审的第一准则**；安全与性能由编译器智能补齐，而不是把负担推给作者。

### 诚实对照

| 对照 | X 语言的选择 |
|------|-------------|
| **相对 C** | 同样贴近机器 —— 语法更干净、更少脚枪、工具链一体，在 C 常有 UB 的地方给出安全证明。 |
| **相对 Rust** | 同样追求内存安全 —— **不必**过「重型 borrow checker 生活方式」；region + 推断 + 线性类型扛重活。 |
| **相对 Zig** | 同样崇尚简单与显式 —— 再加默认安全子集与更强的静态安全叙事。 |

### 支撑目标

| 目标 | 含义 |
|------|------|
| **轻量** | 依赖少、二进制小、可 freestanding / 嵌入式；标准库按需入链 |
| **标准库** | 完整 `core/` + `std/`；跨平台一套 API（差异收在 `std.sys`） |
| **编译自举** | 终局：编译器与标准库 100% `.x`；宿主 C / seed 仅冷启动（**进行中，未宣称完成**） |

### 设计宗旨

- **目的** — 在关键路径极致压榨性能：**默认代码质量优于「普通认真写的 C」**，而不是「你够小心才一样快」。
- **原则** — 可维护、开发简单、**内存安全**（安全子集无静默 UB）。
- **方法** — region 内存 + 借用门控 + 线性类型；别名分析服务 autovec / DCE；`unsafe` 保持薄且可审。

设计长文：[语法与安全](analysis/语法与类型设计-高性能与内存安全.md) · [需求分析](analysis/需求分析.md) · [安全与性能](analysis/安全与性能.md)。

---

## 十二、贡献

1. 克隆 → `./xbuild build-tool && ./xbuild first-time`（或 `./xbuild bootstrap-driver-seed`）。  
2. 日常改动 → `./xbuild build`，`XLANG=./compiler/xlang_asm`，跑相关测试 / gate。  
3. 产品 / 链接 / **SHARED** 改动 → **Ubuntu 金标**（SHARED 再加 mac）；谈放行须 **L4 真冷** + 双端 bstrict **129**（钉盘 `77b334842` / 历史 `9bb7a757c` 直至显式升钉）。  
4. 提交：Conventional Commits（`feat:` / `fix:` / `docs:` …）；`.x` 新注释用**英文**（见 `AGENTS.md` / G.9）。  
5. **禁止双权威** — seed 与 `.x` 产品面必须**同 commit**对齐。  
6. **禁止假绿** — 不得仅凭 prove / Stage2 / WPO 宣称自举完成。

**当前决议** — 自举 / 产品闸门优先于大规模 std 新功能；IR v4 架构已冻结，留给自举后阶段。

---

## 十三、许可证

X 语言采用 **分层授权**（语言库宽松；编译器 copyleft）。详见 [LICENSE](LICENSE) 与 [NOTICE](NOTICE)。

| 层 | 路径 | 许可 |
|----|------|------|
| A — 工具链 | `compiler/`、`tools/`、根目录 `build*.x` | **AGPL-3.0-or-later**（[LICENSE.AGPL-3.0](LICENSE.AGPL-3.0)） |
| B — 语言库 | `core/`、`std/` | **Apache-2.0**（[LICENSE.Apache-2.0](LICENSE.Apache-2.0)） |
| 样例 | `examples/`、`tests/` | **Apache-2.0** |
| 编辑器 | `editors/vscode`、`editors/tree-sitter-xlang`、`editors/vim` | **Apache-2.0** |
| 第三方 | `compiler/seeds/crypto/ed25519/`（orlp） | **zlib** |

**意图：** 使用 `core` / `std` 编写的程序**不会**被强制 AGPL；修改或再分发 **编译器 / 工具链** 适用 AGPL（或商业条款）。

贡献约定：[CONTRIBUTING.md](CONTRIBUTING.md)。

### 商业许可（仅 Layer A）

若需对 **编译器 / 工具链** 做 **AGPL 豁免**（闭源嵌入、闭源分发修改后的工具链、修改后的网络服务不提供对应源码等），请联系：

- 舒良府（ShuLiangfu）— [admin@shuliangfu.com](mailto:admin@shuliangfu.com)

---

*X 语言 — 三高一低：比 C 更快 · 接近 Rust 的安全 · 比 C 更简单 · 按天上手。*
