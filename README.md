# Shux

> **用现代化语言写高性能、强安全代码** — 参考 C 的类型与执行模型，语法与语义尽量简单、易读、易维护；不靠复杂类型论，而靠「显式 + 少未定义 + 默认安全」达成性能与内存安全。

| 项目 | 说明 |
|------|------|
| **语言名** | Shux |
| **编译器** | `shux` |
| **源文件后缀** | `.sx` |
| **构建配置** | `build.sx`（对标 Zig 的 `build.zig`） |
| **当前主线** | 完全自举（编译器 + 标准库逐步去 C） |

---

## 一、项目定位

Shux 是一门**系统级编程语言**：无 GC、零成本抽象、显式内存模型，目标生成代码质量**比肩 C 甚至超越 C**。与 C 相比，开发体验更简单——语法简洁、错误带位置与建议、工具链一体化；与 Rust 相比，类型系统刻意保持克制，在关键处（可空、边界、所有权/借用、别名）**足够显式**，让编译器能静态证明安全并放心优化。

### 核心目标

| 目标 | 含义 |
|------|------|
| **极致性能** | 无 GC、零成本抽象、ASM/LLVM 后端；别名与 noalias 驱动自动向量化 |
| **内存安全** | 安全子集内无泄漏、无悬垂、无越界、无数据竞争；`unsafe` 边界清晰可审计 |
| **轻量级** | 依赖少、可执行文件小、支持 freestanding 与嵌入式；标准库按需链接 |
| **标准库丰富** | `core/` + `std/` 全量模块，一套 API 全平台 |
| **易于上手** | 比 C 简单太多；学习曲线平缓，工具链顺手 |
| **编译自举** | 编译器与标准库最终 100% `.sx`，宿主 C 仅作冷启动种子 |

### 设计宗旨

- **目的**：极致压榨性能。
- **宗旨**：代码可维护性强、开发简单易上手；**内存安全**（无泄漏、不崩溃、绝对安全）。

详细设计见 [`analysis/语法与类型设计-高性能与内存安全.md`](analysis/语法与类型设计-高性能与内存安全.md)、[`analysis/需求分析.md`](analysis/需求分析.md)。

---

## 二、语言特性概览

### 类型与语义

- **基础类型**：`i8`/`i16`/`i32`/`i64`、`u8`/`u16`/`u32`/`u64`、`f32`/`f64`、`bool`、`usize`/`isize`
- **结构体与泛型**：泛型函数/结构体 + 单态化；trait / impl 接口
- **可空与错误**：`Option<T>`、`Result<T, E>`；显式处理，避免 C 式裸指针可空
- **切片**：`[]T` 携带长度，越界可编译期排除或运行期检查
- **模块**：`import("core.mem")` / `import("std.io")`；目录即模块，入口为 `mod.sx`

### 内存与安全

- **无 GC**：栈 + 堆 + Arena；编译期 region / linear / borrow 拒错
- **编译期自动内存管理**：`defer`、`owned`、作用域 `Allocator`（`with_arena`）、SROA、BCE
- **分级安全**：默认 Safe；仅 `unsafe { ... }` 内允许裸指针与底层 syscall
- **别名分析**：`noalias`、scope borrow gate，为 autovec 与 DCE 提供依据

详见 [`analysis/编译时自动内存管理和自动向量化.md`](analysis/编译时自动内存管理和自动向量化.md)、[`analysis/安全与性能.md`](analysis/安全与性能.md)。

### 条件编译与平台

- 条件编译（`#if` / target 分支）支持多目标
- **全平台一套 API**：平台差异封装在 `std/sys` 内部
- 支持 **freestanding**（`-freestanding`、nostdlib 静态链）
- 多目标：`x86_64-linux`、`arm64-macos` 等（`-target`）

---

## 三、快速开始

### 环境要求

- Linux 或 macOS（Windows 自举链推进中）
- 系统 C 编译器与链接器（`cc` / `clang`），用于链接阶段与冷启动
- 可选：Docker（Linux x86_64 回归与 Stage2 哈希门禁）

### 首次构建

```bash
# 推荐：从零产出 shux-c、build_tool、shux
make -C compiler build-tool

# 或进入 compiler 目录
cd compiler && sh bootstrap.sh
```

### 日常构建与自举

```bash
# 用 build_tool 重新编译 shux（不依赖 Makefile 规则环）
cd compiler && ./build_tool ./shux

# 语义自举烟测
make -C compiler bootstrap-verify

# B-strict 生产链（ASM 主链，Linux/macOS）
make -C compiler bootstrap-driver-bstrict
```

### Hello World

```sx
// examples/hello.sx
const io = import("std.io");

function main(): i32 {
  let msg: [12]u8 = [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 10];
  let n: i32 = io.print_str(msg, 12);
  return if (n >= 0) { 0 } else { 1 };
}
```

```bash
shux examples/hello.sx          # 编译并运行
shux build examples/hello.sx -o hello && ./hello
```

更多示例见 [`examples/`](examples/)（含 cookbook：io、net、async、json、compress 等）。

### 验收测试

```bash
./tests/run-all.sh              # 全量回归（仓库根目录）
./tests/run-all-bstrict.sh      # B-strict 链等价 CI
```

---

## 四、编译器用法（`shux`）

默认走 **ASM 后端**直出机器码（`-backend asm`）。常用命令：

| 命令 | 说明 |
|------|------|
| `shux file.sx` | 编译并运行（等同 `shux run file.sx`） |
| `shux build` | 读取当前目录 `build.sx`，编译并运行 `build_runner` |
| `shux build file.sx` | 仅编译，默认产物 `a.out` |
| `shux build file.sx -o exe` | 编译到指定可执行文件 |
| `shux run file.sx` | 编译并运行 |
| `shux check file.sx` | 仅 parse + typeck（含 import），不链接 |
| `shux fmt file.sx` | 格式化源文件（与 LSP 一致） |
| `shux test [script.sh]` | 运行测试脚本（默认 `tests/run-all.sh`） |
| `shux -E file.sx` | 输出 C 源码（调试用） |
| `shux -backend c file.sx` | 强制走 C 后端 |
| `shux -O2 file.sx -o app` | 优化级别（**默认 -O2**） |
| `shux -freestanding … -o app` | Linux x86_64 nostdlib 静态链 |
| `shux -h` / `shux --help` | 打印用法摘要 |

构建配置入口为根目录 [`build.sx`](build.sx)：对标 Zig 的 `build.zig`，描述「怎么编、编什么」；顶层 Makefile 仅做委托，长期由 `build.sx` 完全替代。

---

## 五、仓库结构

```
shux/
├── README.md                 # 本文件
├── build.sx                  # 构建配置（对标 build.zig）
├── NEXT.md                   # 完全自举路线图与当前站位
├── analysis/                 # 需求、架构、RFC、性能与安全分析
├── compiler/                 # 编译器（C + .sx 混合，向 100% .sx 迁移）
│   ├── src/
│   │   ├── lexer/            # 词法
│   │   ├── parser/           # 语法 → AST
│   │   ├── ast/              # AST 定义
│   │   ├── typeck/           # 类型检查、泛型单态化、borrow
│   │   ├── codegen/          # 代码生成（C / ASM）
│   │   ├── asm/              # 自研 ASM 后端
│   │   ├── pipeline/         # 流水线 glue
│   │   └── driver/           # CLI、多文件、链接
│   ├── docs/                 # SELFHOST、ABI、运维文档
│   └── scripts/              # build_shux_asm.sh 等
├── core/                     # 标准库 core（无 OS 依赖）
│   ├── types/ mem/ option/ result/ slice/ str/ fmt/ …
├── std/                      # 标准库 std（依赖 OS）
│   ├── io/ fs/ net/ heap/ vec/ json/ http/ async/ sys/ …
├── runtime/                  # 最小运行时（可选）
├── tests/                    # 回归测试与 gate 脚本
├── examples/                 # 示例与 cookbook
├── tools/                    # 格式化、测试运行器等
├── editors/                  # VS Code 等 IDE 插件
└── mcp/                      # MCP 服务（开发辅助）
```

- **core/** 不依赖 **std/**；**std/** 依赖 **core/**
- 模块布局：**目录即模块**，入口为 `mod.sx`（如 `std/io/mod.sx`）
- 用户引用：`import("core.mem")`、`import("std.io")`

架构详解：[`analysis/构架分析.md`](analysis/构架分析.md)。

---

## 六、标准库

### core（11 个模块，无 OS）

| 模块 | 职责 |
|------|------|
| `core.types` | `size_of` / `align_of`、布局查询 |
| `core.mem` | 内存操作、对齐、拷贝 |
| `core.option` / `core.result` | 可空与错误类型 |
| `core.slice` / `core.str` | 切片与字符串视图 |
| `core.fmt` / `core.debug` | 格式化与调试 |
| `core.builtin` / `core.iterator` / `core.cmp` | 内建与迭代、比较 |

### std（70+ 模块，依赖 OS）

覆盖 I/O、文件系统、网络、并发、压缩、编解码、数据库、HTTP、异步、加密、正则、配置等。代表性模块：

| 类别 | 模块 |
|------|------|
| 基础 | `std.io`、`std.fs`、`std.path`、`std.process`、`std.env` |
| 容器 | `std.vec`、`std.map`、`std.set`、`std.queue` |
| 内存 | `std.heap`（Allocator、Arena）、`std.mem` |
| 并发 | `std.thread`、`std.sync`、`std.channel`、`std.async` |
| 网络 | `std.net`、`std.http`、`std.websocket` |
| 数据 | `std.json`、`std.csv`、`std.compress`、`std.db` |
| 系统 | `std.sys`（Linux syscall / macOS libSystem / Win32 规划中） |
| 工具 | `std.test`、`std.fmt`、`std.log`、`std.cli` |

标准库按需链接，不引入未引用模块，满足「轻量级、一切都要小」。

---

## 七、编译器架构

### 流水线

```
.sx 源码
  → [预处理] → #if / import 展开
  → [词法 Lexer] → Token 流
  → [语法 Parser] → AST
  → [类型检查 Typeck] → 泛型单态化、borrow、region
  → [代码生成 Codegen] → C 或 ASM
  → [链接] → 可执行文件 / .o
```

### 两条构建路径

| 路径 | 说明 |
|------|------|
| **用户编译（目标 A）** | `.sx` → driver → asm/c 后端 → ld → 可执行文件 |
| **自举构建（目标 B）** | seed（shux-c）→ `build_shux_asm.sh` → `shux_asm` → Stage2 验证 |

### 自举状态（2026-06）

| 维度 | 状态 |
|------|------|
| 语义自举 | ✅ `make -C compiler bootstrap-verify` |
| B-strict ASM 主链 | ✅ Linux / macOS arm64 |
| Stage2 行为一致 | ✅ `verify-selfhost-stage2-bstrict.sh` |
| Stage2 哈希金标准 | 🟡 Docker Linux x86_64 已 SHA256 一致 |
| 编译器去 C | 🟡 前端主体已 `.sx`，仍有 `runtime.c` 等 |
| 全仓库 std 无 C | ⬜ 终局必达（阶段 F） |

源码规模约 **52% `.sx` / 48% C**；lexer、parser、ast 以 `.sx` 为主，codegen 仍在迁移。

全景与验收：[`analysis/doc-selfhost-architecture-v1.md`](analysis/doc-selfhost-architecture-v1.md)、[`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md)、[`NEXT.md`](NEXT.md)。

---

## 八、里程碑

| 里程碑 | 内容 | 状态 |
|--------|------|------|
| M0 | Lexer、AST、Parser | ✅ |
| M1 | Typeck、Codegen、Driver，首版可运行 | ✅ |
| M2 | import、core/std 最小子集、多目标 | ✅ |
| M3 | 泛型、trait、模块系统、标准库扩展 | ✅ |
| M4 | DCE、-O2/-Os、体积与性能基线 | ✅（部分） |
| M5 | 自举（.sx 编译器可编译自身） | ✅ 语义自举；🟡 完全自举（去 C） |
| **下一阶段** | 完全自举 + 全仓库 std 无 C | 见 [`NEXT.md`](NEXT.md) |

---

## 九、文档索引

| 文档 | 内容 |
|------|------|
| [`analysis/需求分析.md`](analysis/需求分析.md) | 总体目标、性能与安全策略 |
| [`analysis/构架分析.md`](analysis/构架分析.md) | 仓库结构、编译器模块划分 |
| [`analysis/语法与类型设计-高性能与内存安全.md`](analysis/语法与类型设计-高性能与内存安全.md) | 类型与语义设计原则 |
| [`analysis/编译时自动内存管理和自动向量化.md`](analysis/编译时自动内存管理和自动向量化.md) | Arena、SROA、autovec 路线 |
| [`analysis/安全与性能.md`](analysis/安全与性能.md) | 编译器与语言安全防线 |
| [`analysis/自举方案-当前状态.md`](analysis/自举方案-当前状态.md) | 自举进度与模块迁移 |
| [`NEXT.md`](NEXT.md) | 完全自举路线图与门禁命令 |
| [`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md) | 自举运维与验收命令 |

`analysis/` 下另有大量 RFC 与模块级设计（std-http、std-async、perf 等），按模块名检索即可。

---

## 十、测试与质量

- **全量回归**：`./tests/run-all.sh`
- **B-strict CI**：`SHUX=./compiler/shux_asm ./tests/run-bootstrap-bstrict-ci.sh`
- **Push 前 P0**：`SHUX=./compiler/shux_asm ./tests/run-pre-push-p0.sh`
- **Gate 脚本**：`tests/run-*-gate.sh`（borrow、arena、sroa、autovec、allocator 等专项门禁）
- **性能基线**：`tests/baseline/`、`analysis/perf-*.md`

---

## 十一、工具链生态

| 组件 | 路径 | 说明 |
|------|------|------|
| VS Code 插件 | `editors/vscode/` | 语法高亮、诊断、格式化 |
| MCP Server | `mcp/` | IDE/AI 通过 MCP 调用解析与诊断 |
| LSP | `compiler/lsp_gen.c` | 补全与诊断（向 `.sx` 迁移中） |

---

## 十二、参与开发

1. 克隆仓库后执行 `make -C compiler build-tool` 构建编译器。
2. 修改代码后运行 `./tests/run-all.sh` 或相关 gate 脚本。
3. 自举相关改动需额外跑 `make -C compiler bootstrap-verify`。
4. 提交规范：Conventional Commits（`feat:` / `fix:` / `perf:` 等），英文描述；详见 `.cursor/rules/03-操作规则.mdc`。

**当前决议**（见 [`NEXT.md`](NEXT.md)）：标准库新功能暂停；**下一阶段唯一主线 = 完全自举**（含全仓库 std 无 C 终局）。

---

*Shux — 极致压榨性能，简单、易读、易维护，内存安全。*
