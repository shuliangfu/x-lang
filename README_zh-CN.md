# Shux（舒克斯）

> **用现代化语言写高性能、强安全代码** — 参考 C 的类型与执行模型，语法尽量简单、易读、易维护；不靠重型类型论，而靠「显式约定 + 少未定义行为 + 默认安全」拿到性能与内存安全。

| 项目 | 说明 |
|------|------|
| **语言名** | Shux（舒克斯） |
| **编译器** | `shux` / `shux_asm`（自举链路后的产品二进制） |
| **源文件后缀** | `.x` |
| **构建配置** | `build.x`（角色类似 Zig 的 `build.zig`） |
| **现阶段（2026-07-18）** | **产品 L4 钉盘** 双端绿（macOS + Ubuntu 真冷 + `run-all-bstrict` **123/123** @ `5c8204ae`）；freestanding S4 / vec / 软 typeck 等日常 L2 residual 已大部收口；**尚未宣称完全自举**（冷启动仍依赖 seed / 过渡 C） |
| **进度仪表盘** | [`analysis/自举进度.md`](analysis/自举进度.md) · 当天快照 [`当前进度.md`](当前进度.md) |
| **English** | [README.md](README.md) |

---

## 一、项目定位

Shux 是一门**系统级编程语言**：无 GC、零成本抽象、显式内存模型，目标生成代码质量比肩乃至超过精心编写的 C。相对 C：语法更干净、诊断带位置、工具链一体；相对 Rust：类型系统刻意克制，只在可空、边界、所有权/借用、别名等关键处**足够显式**，让编译器能静态证明安全并放心优化。

### 核心目标

| 目标 | 含义 |
|------|------|
| **极致性能** | 无 GC；默认 ASM 后端 + 可选 C 后端；别名 / `noalias` 服务 autovec 与 DCE |
| **内存安全** | 安全子集内默认无泄漏、悬垂、越界、数据竞争；`unsafe` 可审计 |
| **轻量** | 依赖少、可执行文件小、可 freestanding / 嵌入式；标准库按需入链 |
| **标准库** | 完整 `core/` + `std/`；跨平台一套 API（差异收在 `std.sys`） |
| **易上手** | 学习曲线远低于「大型 C 工程」；工具链顺手 |
| **编译自举** | 终局：编译器与标准库 100% `.x`；宿主 C / seed 仅冷启动（**进行中，未宣称完成**） |

### 设计宗旨

- **目的**：在关键路径上极致压榨性能。  
- **原则**：可维护、开发简单、**内存安全**（安全子集无静默 UB）。

设计长文：[`analysis/语法与类型设计-高性能与内存安全.md`](analysis/语法与类型设计-高性能与内存安全.md)、[`analysis/需求分析.md`](analysis/需求分析.md)。

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
// examples/hello.x
const fmt = import("std.fmt");

function main(): i32 {
  let n: i32 = fmt.println("Hello World");
  return if (n >= 0) { 0 } else { 1 };
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
SHUX_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh   # 产品闸门（约 123 脚本）
./tests/run-linux-a09-a11-gate.sh
# Linux x86_64 freestanding S4 烟测（return42 / panic / hello）：
./tests/run-freestanding-hello.sh
```

凡谈**自举 / 产品放行**，项目要求 **L4 真冷**（擦除 `compiler`/`std`/`core` 下全部 `.o` 并重链二进制）+ **双端** `run-all-bstrict` 全绿。详见 [`自举方法.md`](自举方法.md)、[`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md)。  
**注意：** 日常 tip 的 L2 绿 **≠** tip L4 钉盘；当前放行钉盘为 **`5c8204ae`**，直到下次双端真冷重钉（见仪表盘）。

---

## 四、编译器用法

默认 **ASM 后端**（`-backend asm`）。

| 命令 | 说明 |
|------|------|
| `shux file.x` | 编译并运行 |
| `shux build` | 读 `build.x`，跑构建 runner |
| `shux build file.x -o exe` | 编译到可执行文件 |
| `shux check file.x` | 仅 parse + typeck |
| `shux fmt file.x` | 格式化 |
| `shux test [script]` | 跑测试（默认 `tests/run-all.sh`） |
| `shux --lsp` | 语言服务器（stdio JSON-RPC） |
| `shux -E file.x` | 输出 C（调试） |
| `shux -backend c file.x` | 强制 C 后端 |
| `shux -O2 file.x -o app` | 优化（默认 **-O2**） |
| `shux -freestanding …` | Linux x86_64 nostdlib 静态 |
| `shux -h` | 帮助 |

根目录 [`build.x`](build.x) 描述编什么。日常入口：`./shux-build.sh` / `build_tool`。

---

## 五、仓库结构

```
shux/
├── README.md / README_zh-CN.md
├── LICENSE · LICENSE.AGPL-3.0 · LICENSE.Apache-2.0 · NOTICE · CONTRIBUTING.md
├── build.x / shux-build.sh
├── 当前进度.md / 自举方法.md / 自举步骤.md
├── analysis/                 # 架构、RFC、进度仪表盘
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
| **产品轨** | L4 真冷 + 产品矩阵 + 双端 `run-all-bstrict` 123 | **必要**，但还不够宣称「永久零 C」 |
| **工程轨** | prove T/N、Cap residual pure、Stage2、WPO 链/链接/text 门 | **否** |

---

## 八、自举状态（摘要 · 2026-07-18）

> **实时数字以** [`analysis/自举进度.md`](analysis/自举进度.md) · 当天 [`当前进度.md`](当前进度.md) **为准**。  
> README 只给摘要；**禁止**把 Stage2 / prove / WPO / **日常 L2 绿**单独写成 tip 产品 L4 或完全自举。

### 产品轨

| 项 | 状态 |
|----|------|
| **L4 放行钉盘** | **`5c8204ae`** — 双端真冷 + `run-all-bstrict` **123/123**（Ubuntu + macOS） |
| Ubuntu L4 + 全量 bstrict | ✅ **123/123** @ 钉盘（日志 `/tmp/ubuntu_true_*_5c8204ae.log`） |
| macOS L4 + 全量 bstrict | ✅ **123/123** @ 钉盘（日志 `/tmp/mac_true_*_5c8204ae.log`） |
| 金标主机 | **Ubuntu x86_64** |
| 验收二进制 | **本波** L2/L3/L4 产出的 `compiler/shux_asm`，**禁止**旧 stage1 |
| 日常 tip（≠ 自动 tip L4） | 分支 tip 会随日常 L2 产品修复前进；**只有**双端真冷 + bstrict 后才升 tip L4 钉盘 |

### 产品面近期已收口（日常 L2 · 钉盘仍为 `5c8204ae`）

下列属于**用户产品路径**（`-backend asm` / freestanding），详见仪表盘；**不能**单独当作 tip L4 已升：

| 面 | 状态（量级） |
|----|--------------|
| Freestanding S4 闸门 | ✅ `run-freestanding-hello`（return42 / panic_div / hello） |
| Freestanding `std.vec` push | ✅ SysV MEMORY by-value 形参 home（push/boundary/cookbook 无 SIGSEGV） |
| Freestanding hello CG002 | ✅ 多参 `METHOD_CALL` 栈路径（`submit_read_batch` residual 关） |
| Freestanding 软 XT001 噪声 | ✅ dep prerun 探测 typeck soft-suppress（cookbook `new` / `heap_mem_set_c`） |
| NL-07 零 libc 轨 | ✅ **L1–L10 + v5** 已在产品钉盘收口（crt0 / soft libm / pure static 矩阵） |
| Hosted asm 矩阵 | ✅ return-value / hello / option / stdlib-import 等 Ubuntu 金标 L2 绿 |

### 工程轨（量级）

| KPI / 门禁 | 状态 |
|------------|------|
| **T** | **18/18** |
| **EMPTY** | **18/18** |
| **N** prove IDENTICAL | **54/54** |
| Cap residual pure（driver_abi / fmt_check 等） | 产品 tip L4 上多波 residual pure 已收口 |
| **D Stage2** | ✅ freestanding / 行为 parity（**≠** 产品 g05 全链） |
| Stage2 **WPO** 链 + strict-link + text-gate | ✅ 工程绿（Ubuntu；部分链接门 Darwin N/A） |

### 明确不宣称

- **未**宣称「编译器已 100% `.x`、无 seed」
- **未**把 Stage2 的 `shux_asm2` 当产品编译器
- **未**把工程 WPO 绿等同 tip 产品 L4
- **未**把「每个日常 L2 commit」写成 tip L4 —— 钉盘只在下次双端真冷 + bstrict 后更新
- 终局物理零 C / 彻底去掉 seed（**G**）仍在路线图，不是本周叙事

方法：Cap / R / L / M → [`自举方法.md`](自举方法.md)。运维：[`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md)。纪律：[`AGENTS.md`](AGENTS.md) + skill `shux-selfhost-product-gate`。

### 近端前排（高层）

1. （可选）**9–16B Allocator** 双 GP SysV home 与 formal C 对齐  
2. （旁）`vec_u16` BLD001 mangle、f64 let-init、cfg-extern / `.bss` / labi `len_empty`（挡产品面再开）  
3. SHARED 产品面变更后：**双端 tip L4 真冷 + bstrict** 重钉；禁止双权威、禁止 soft-skip typeck 糊绿  

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
| **当前** | 产品 L4 双端钉盘 @ `5c8204ae` + freestanding/asm 日常 L2 residual + ABI 余债 | 见仪表盘 |

---

## 十、文档索引

| 文档 | 内容 |
|------|------|
| [`analysis/自举进度.md`](analysis/自举进度.md) | **KPI 仪表盘**（每波必改） |
| [`当前进度.md`](当前进度.md) | 当天快照 / 前排 |
| [`自举方法.md`](自举方法.md) | Cap / R / L / M 方法 |
| [`自举步骤.md`](自举步骤.md) | 可执行闸门 |
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
| 编辑器 | `editors/vscode` | **MIT** |
| 编辑器 | `editors/tree-sitter-shux`、`editors/vim` | **Apache-2.0** |
| 第三方 | `compiler/seeds/crypto/ed25519/`（orlp） | **zlib** |

**意图：** 使用 `core`/`std` 编写的程序不会被强制 AGPL；修改或再分发 **编译器/工具链** 适用 AGPL（或商业条款）。

贡献约定：[`CONTRIBUTING.md`](CONTRIBUTING.md)。

### 商业许可（仅 Layer A）

若需对 **编译器/工具链** 做 **AGPL 豁免**（闭源嵌入、闭源分发修改后的工具链、修改后的网络服务不提供对应源码等），请联系：

- 舒良府（ShuLiangfu）— [admin@shuliangfu.com](mailto:admin@shuliangfu.com)

---

*Shux — 极致性能取向，简单、可读、可维护、内存安全。*
