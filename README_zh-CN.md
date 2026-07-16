# 舒克斯

> **用现代化语言写高性能、强安全代码 ** — 参考 C 的类型与执行模型，语法与语义尽量简单、易读、易维护 ；不靠复杂类型论 ，而靠「显式 + 少未定义 + 默认安全」达成性能与内存安全。

| 项目 | 说明 |
|------|------|
| **语言名 ** | 舒克斯 |
| **编译器 ** | `shux` |
| **源文件后缀 ** | `.x` |
| **构建配置 ** | `build.x` （对标 Zig 的 `build.zig` ） |
| **当前主线 ** | **阶段B + C 并行** （ Cap 能力解锁 → R2 真迁 → M mega 去 pin ； D + E-soft + F v1 已闭合） |
| **进度视图 ** | [`analysis/自举进度.md`] (analysis/自举进度.md) （分析/.md单一事实来源 ） |

----

## 一、项目定位

Shux 是一门**系统级编程语言 ** ：无 GC、零成本抽象、显式内存模型 ，目标生成代码质量 **比肩 C 甚至超越 C **。与 C 相比，开发体验更简单 ——语法简洁、错误带位置与建议、工具链一体化 ；与 Rust 相比，类型系统刻意保持克制 ，在关键处 （可空、边界、所有权/借用、别名） **足够显式 ** ，让编译器能静态证明安全并放心优化。

### 核心目标

| Goals | 含义 |
|------|------|
| **极致性能 ** | 无 GC、零成本抽象、 ASM 直出 + 可选 C 后端；别名与 noalias 驱动自动向量化 |
| **内存安全 ** | 安全子集内无泄漏、无悬垂、无越界、无数据竞争； `unsafe` 边界清晰可审计 |
| **轻量级 ** | 依赖少、可执行文件小、支持 独立式 与嵌入式；标准库按需链接 |
| **标准库丰富 ** | `core/` + `std/` 全量模块，一套 API 全平台 |
| **易于上手 ** | 比 C 简单太多学习曲线平缓；工具链顺手 |
| **编译自举 ** | 编译器与标准库最终 100% `.x` ；宿主 C/粒 仅冷启动与清场过渡期 |

### 设计宗旨

- **目的 ** ：极致压榨性能。
- **宗旨 ** ：代码可维护性强、开发简单易上手 ； **内存安全 ** （无泄漏、不崩溃、绝对安全 ）。

详细设计见 [`analysis/语法与类型设计-高性能与内存安全.md`] (analysis/语法与类型设计-高性能与内存安全 .md)、 [`analysis/需求分析.md`] (analysis/需求分析.md)。

----

## 二、语言特性概览

### 类型与语义

- **基础类型 ** ： `i8`/`i16`/`i32`/`i64`、 `u8`/`u16`/`u32`/`u64`、 `f32`/`f64`、 `bool`、 `usize`/`isize`
- **结构体与泛型 ** ：泛型函数/结构体+ 单态化；特质/含义 接口
- **可空与错误 ** ： `Option<T>`、 {{MD1}显式处理}避免 ； 式裸指针可空
- **切片 ** ： `T[]` 携带长度；域标注 `T[]<label>` 与 **区域** 借用域（类型拒逃逸）
- **模块 ** ： `import("std.io")`/`import("core.mem")` ；目录即模块 ，入口为 `mod.x`

### 内存与安全

- **无 GC ** ：栈 + 堆 +竞技场；编译期区域/线性/借用 拒错
- **编译期自动内存管理 ** ： `defer`、 `owned`、作用域 `Allocator` （ `with_arena` ）、 SROA、 BCE
- **分级安全 ** ：默认安全；仅 `unsafe { ... }`内允许裸指针与底层系统调用
- **别名分析 ** ： `noalias`、范围借用门，为 autovec 与 DCE 提供依据

详见 [`analysis/编译时自动内存管理和自动向量化.md`] (analysis/编译时自动内存管理和自动向量化.md)、 [`analysis/安全与性能.md`] (analysis/安全与性能.md)。

### 条件编译与平台

- 条件编译（ `#if`/目标 分支）支持多目标
- **全平台一套 API ** ：平台差异封装在 `std/sys` 内部
- 支持 **独立式** （ `-freestanding`、 nostdlib 静态链）
- 多目标： `x86_64-linux`、 `arm64-macos` 等（ `-target` ）

语言语法速查： [`docs/README.md`] (docs/README.md关键字、类型、控制流、模块等)。

----

## 三、快速开始

### 环境要求

- Linux 或 macOS （ Windows 自举链推进中， B-hybrid ）
- 系统 C 编译器与链接器（ `cc`/`clang` ） ，用于链接阶段与冷启动种子
- 可选： Docker （ Linux x86_64金标准门户，如 `run-linux-a09-a11-gate.sh` ）

### 首次构建

```bash
# 推荐：pinned seeds 产出 build_tool，再日常 relink 出 shux
make -C compiler build-tool
./shux-build.sh first-time          # = build_tool + ./build_tool ./shux
# 或：cd compiler && ./build_tool ./shux

# 冷启动（仅 cc，无 Makefile）：cd compiler && sh bootstrap.sh

# 需要 LSP（--lsp）时：
make -C compiler bootstrap-driver-seed
```

### 日常构建与自举

```bash
# 【推荐日常】G-05：build_tool → g05_build_shux_asm.sh → make shux_asm（relink 金标准）
./shux-build.sh build                 # 仓库根（根 make 亦委托本脚本）
# 或：cd compiler && ./build_tool ./shux

SHUX=./compiler/shux ./tests/run-hello.sh

# 全量 B-strict（改后端/seed 后；较慢）
./shux-build.sh full                  # 或 make -C compiler bootstrap-driver-bstrict

# 语义自举烟测
make -C compiler bootstrap-verify     # Makefile 兜底 / CI
```

| 入口 | 用途 |
|------|------|
| `./shux-build.sh build`/`./build_tool ./shux` | **日常增量 ** （默认 ） |
| `./shux-build.sh full` | 全量 B-strict |
| `make -C compiler …` | 冷启动细节、历史 CI、测试目标（ **兜底 ** ） |

`shux-c` 仅用于**首次冷启动 **或 MSYS2/非x86_64 链接回退； **不是 **日常发布二进制。日常以 `compiler/shux` （ relink/B-strict 定稿）为准。

### 你好世界

```x
// examples/hello.x
const fmt = import("std.fmt");

function main(): i32 {
  let n: i32 = fmt.println("Hello World");
  return if (n >= 0) { 0 } else { 1 };
}
```

```bash
./compiler/shux examples/hello.x          # 编译并运行（需已构建 shux）
./compiler/shux build examples/hello.x -o hello && ./hello
./compiler/shux check examples/hello.x      # 仅 parse + typeck
```

更多示例见 [`examples/`] (examples/) （含食谱： io、 net、 async、 json、 compress 等）。

### 验收测试

```bash
./tests/run-all.sh              # 全量回归（仓库根目录）
./tests/run-all-bstrict.sh      # B-strict 链等价 CI
./tests/run-linux-a09-a11-gate.sh   # Linux 金标准自举 gate（Docker 推荐）
```

----

## 四、编译器用法（ `shux` ）

默认走 ** ASM 后端**直出机器码 （ `-backend asm` ）。常用命令 ：

| 命令 | 说明 |
|------|------|
| `shux file.x` | 编译并运行（等同 `shux run file.x` ） |
| `shux build` | 读取当前目录 `build.x` ，编译并运行 `build_runner` |
| `shux build file.x` | 仅编译，默认产物 `a.out` |
| `shux build file.x -o exe` | 编译到指定可执行文件 |
| `shux run file.x` | 编译并运行 |
| `shux check file.x` | 仅 parse + typeck （含 import ） ，不链接 |
| `shux fmt file.x` | 格式化 `.x` 源文件 |
| `shux test [script.sh]` | 运行测试脚本（默认 `tests/run-all.sh` ） |
| `shux --lsp` | 语言服务器（ stdio JSON-RPC ； IDE 插件调用） |
| `shux -E file.x` | 输出 C 源码（中文调试用） |
| `shux -backend c file.x` | 强制走 C 后端 |
| `shux -O2 file.x -o app` | 优化级别（ **默认 -O2 ** ） |
| `shux -freestanding … -o app` | Linux x86_64 nostdlib 静态链 |
| `shux -h`/`shux --help` | 打印用法摘要 |

构建配置入口为根目录 [`build.x`] (build.x) ：对标 Zig 的 `build.zig` ，描述「怎么编、编什么」。日常入口为 `./shux-build.sh`/`build_tool` （ G-05 ~ 95% ） ； `compiler/Makefile`仅作重新链接 依赖图与冷启动实现层。

----

## 五、仓库结构

```
shux/
├── README.md                 # 本文件
├── LICENSE                   # AGPL-3.0-or-later 完整许可文本
├── NOTICE                    # 版权、SPDX 标识与第三方声明
├── build.x                  # 构建配置（对标 build.zig）
├── NEXT.md                   # 完全自举路线图与 gate 命令
├── analysis/                 # 需求、架构、RFC、性能与安全分析
├── docs/                     # 语言语法文档（面向用户）
├── compiler/                 # 编译器（.x 主链 + C seed / glue，向物理零 C）
│   ├── src/
│   │   ├── lexer/ parser/ ast/ typeck/ codegen/
│   │   ├── asm/              # 自研 ASM 后端
│   │   ├── pipeline/ driver/ lsp/
│   │   └── …
│   ├── seeds/                # bootstrap_shuxc、*_gen 冷启动 seed
│   ├── docs/SELFHOST.md      # 自举验收命令
│   └── scripts/              # build_shux_asm.sh 等
├── core/                     # 标准库 core（无 OS 依赖）
├── std/                      # 标准库 std（F-ZC：已无手写 .c/.h）
├── runtime/                  # 最小运行时（可选）
├── tests/                    # 回归测试与 gate 脚本
├── examples/                 # 示例与 cookbook
├── tools/                    # 格式化、测试运行器等
├── editors/vscode/           # VS Code / Cursor / Trae 插件（LSP 客户端）
└── mcp/                      # MCP 服务（开发辅助）
```

- **核心/** 不依赖 **标准/** ； **标准/** 依赖 **核心/**
- 模块布局： **目录即模块 ** ，入口为 `mod.x` （如 `std/io/mod.x` ）
- 用户引用： `import("core.mem")`、 `import("std.io")`

架构详解： [`analysis/构架分析.md`] (analysis/构架分析.md)。

----

## 六、标准库

### 核心（无 OS ）

| 模块 | 职责 |
|------|------|
| `core.types` | `size_of`/`align_of`、布局查询 |
| `core.mem` | 内存操作、对齐、拷贝 |
| `core.option`/`core.result` | 可空与错误类型 |
| `core.slice`/`core.str` | 切片与字符串视图 |
| `core.fmt`/`core.debug` | 格式化与调试 |
| `core.builtin`/`core.iterator`/`core.cmp` | 内建与迭代、比较 |

（ 完整列表见 [`docs/07-内置与标准库.md`] (docs/07-内置与标准库 .md)。 ）

### std （依赖 OS ， F-ZC ✅）

`std/` 下手写 ** `.c`/`.h` 已为 0 ** （阶段 F 闭合）。覆盖 I/O、文件系统、网络、并发、压缩、编解码、数据库、 HTTP、异步、加密、正则、配置等。代表性模块 ：

| 类别 | 模块 |
|------|------|
| 基础 | `std.io`、 `std.fs`、 `std.path`、 `std.process`、 `std.env` |
| 容器 | `std.vec`、 `std.map`、 `std.set`、 `std.queue` |
| 内存 | `std.heap`（分配器、竞技场）、`std.mem` |
| 并发 | `std.thread`、 `std.sync`、 `std.channel`、 `std.async` |
| Network | `std.net`、 `std.http`、 `std.websocket` |
| 数据 | `std.json`、 `std.csv`、 `std.compress`、 `std.db` |
| 系统 | `std.sys` （ Linux syscall/macOS libSystem/Win32 规划中） |
| 工具 | `std.test`、 `std.fmt`、 `std.log`、 `std.cli` |

标准库按需链接，不引入未引用模块 ，满足「轻量级、一切都要小」。

----

## 七、编译器架构

### 流水线

```
.x 源码
  → [预处理] → #if / import 展开
  → [词法 Lexer] → Token 流
  → [语法 Parser] → AST
  → [类型检查 Typeck] → 泛型单态化、borrow、region
  → [代码生成 Codegen] → ASM 或 C
  → [链接] → 可执行文件 / .o
```

### 两条构建路径

| 路径 | 说明 |
|------|------|
| **用户编译 ** | `.x`→司机→asm/c 后端 → ld → 可执行文件 |
| **自举构建 ** | 种子（ `shux-c`/`bootstrap_shuxc` + `*_gen` ）→ `build_shux_asm.sh` → `shux_asm`阶段→2 验证 |

### 自举状态（ 2026-07-14 ）

> 详细数字与待办以 [`analysis/自举进度.md`] (analysis/自举进度.md) 为准；下表为 README 摘要。

#### 近一个月进展（ 2026-06-14 → 2026-07-14 ）

一个月前本仓库尚未建立自举进度跟踪体系（无 `analysis/自举进度.md`、无 Cap/R/L/M 方法论、README 仍是"开发时序文档" ）。一个月内 （ 4163次提交）关键变化 ：

| 维度 | 一个月前 | 现在！ | 变化 |
|------|----------|------|------|
| **方法论 ** | 阶段 G 清场 ~ 20% | CAP/R/L/M 四轨 + 四 KPI （ T/N/R2/H/S/G ） | 建立 [`自举方法.md`] (自举方法.md)、 [`自举步骤.md`] (自举步骤.md)、 [`自举进度.md`] (analysis/自举进度.md)、 [`当前进度.md`] (当前进度.md) |
| **T**（类型） | 部分模块失败 | ** 18/18 满** | W-lsp-diag-expr/W-lexer-timeout/W-tail/W-isize 等 12 个根因波次全清 |
| **N**（证明相同） | 0 （名体系未建） | ** 49 ** | 9 个 labi_* + 12 个 rt_* + 7个后端/诊断薄证明 全绿 |
| ** R2 ** （真迁 H = 0 ） | 0 | **15**已满 | `rt_util`/`rt_lib_root`/`rt_emit_flags`/`rt_emit_state`/`rt_content`/`rt_fs_open`/`rt_parse_diag`/`rt_fmt_one`/`rt_diag_errno`/`rt_stack`/`rt_argv`/`rt_entry`/`rt_pipeline_elf_diag`/`rt_compile`/`rt_run_exec` |
| ** W 波次** | 0 | ** 12 ✅** | W字符串/W-关键字参数/W-不安全-expr/W-外部不安全/W尾/W-isize/W-堆过载/W-escape/W-lexer-超时/W-lsp-diag-expr/W字符串-let/W字符串-nul |
| **上限** | 0 解锁 | ** 1 ** ✅ | Cap-empty-str ；⬜ Cap-string-pool/Cap-global-bss/Cap-va-reportf/Cap-regen-sync |
| **门禁 G ** | — | ✅ mac + Ubuntu 全绿 | seed冷启动 /G-FFI-5 |

> **核心结论 ** ：一个月内完成了 "从无进度跟踪体系 → 建立四轨方法论+ 四 KPI + 12 根因波次全清 + 15 切片 R2 full真迁"。剩余瓶颈收敛到 ** 4 条 Cap + 3 个 mega pin ** ，不再是无序清场。

#### 阶段总览

| 阶段 | 含义 | 状态 |
|------|------|------|
| ** D ** | 阶段黄金自举 2 | V1 |
| ** E ** | 编译器去 C （软） | 🟡 默认 no_c ；固定种子+补丁仍在 ←**当前主线 ** |
| ** F ** | 标准无 C （ F-ZC ） | ✅ `std/` 0 `.c` + 0 `.h` |
| ** G ** | 终局物理零 C/nostdlib 硬绿 | 🟡 非本周主线（先 E 三轨） |

#### 四 KPI （ Ubuntu x86_64 ， 2026-07-14 ）

| 关键绩效指标 | 含义 | 当前 | 健康方向 |
|-----|------|------|----------|
| ** T ** | 打字OK / 18 | ** 18/18 ** ✅ | 满 |
| ** N ** | 证明相同 模块数 | ** 49 ** （附注 ） | 不再冲刺 |
| ** R2 ** | 产品 rest 业务符号已真迁（ H = 0 ） | **15**已满 | ↑ 主指标 |
| **小时** | 混合REST 仍含业务 C 体的切片数 | 上述 15 切片 H = 0 ；其余运行时多切片仍休息C | ↓ 主指标 |
| ** S ** | 构建链硬依赖的 钉住的种子 面 | R2 × 15产品首选Full .x ；其余 Hybrid 多 Thin + REST ； Mega 仍 Pin | ↓ |
| ** G ** | 门禁种子冷启动/G-FFI-5 | ✅ Mac + Ubuntu | 全绿 |

#### 当前主线（ B + C期 并行）

```
当前 ──► Phase B 出口 ──► Phase C 出口 ──► v2==v3 ──► 自举语义完成
  │           │                │
  │           │                └─ mega pin 全关（typeck M4 + codegen + parser）
  │           └─ Cap 4 条 + 批量 R2（H→0，除 syscall/crt 壳）
  └─ T=18/18 ✅ / N=49 附注 / R2=15
```

| 轨 | 当前状态 | 下一步 |
|----|----------|--------|
| **上限** （能力解锁 ） | ✅ Cap-empty-str ；⬜ Cap-string-pool/Cap-global-bss/Cap-va-reportf/Cap-regen-sync | Cap-global-bss → rt_arena_buf |
| ** R ** （真迁退役 ） | R2 = 15满（ H = 0 ） ；其余混合多切片仍REST C | 批量 R2 ：运行时其它休息 |
| ** M ** （ MEGA 去 PIN ） | 3个仍 针（ typeck/codegen/parser ） | typeck M2试替换烟雾 |
| ** L ** （叶子证明） | N = 49 IDENTICAL （辅轨相同不再冲刺） | 仅回归锁 |

#### 当前阻塞

1. ** B期出口未达** ：产品 `runtime_driver_no_c`/LABI 仍有业务 REST C （ H 未降） — 根因： 4条帽 未解锁
2. **阶段C 出口未达** ： 3个兆仍引脚— 根因： typeck M2试替换尚未烟雾 验证
3. **类型独立变量解析** ： `shux-c -E src/runtime_driver_diagnostic.x` 仍报 `expected *u8, found ?`

全景与验收： [`compiler/docs/SELFHOST.md`] (compiler/docs/SELFHOST.md)、 [`NEXT.md`] (NEXT.md) § 10 阶段 G、 [`analysis/doc-selfhost-architecture-v1.md`] (analysis/doc-selfhost-architecture-v1.md)。

----

## 八、里程碑

| 里程碑 | 内容 | 状态 |
|--------|------|------|
| 莫0 | 词法分析器、AST、解析器 | ✅ |
| M1 | Typeck 、Codegen、 Driver ，首版可运行 | ✅ |
| 什么 | import 、core/std 最小子集、多目标 | ✅ |
| 和 | 泛型、特征、模块系统、标准库扩展 | ✅ |
| 麦克赫 | DCE 、-O2/-Os、体积与性能基线 | ✅（部分 ） |
| M5 | 自举（ `.x` 编译器可编译自身） | ✅ D + E + F v1 ； B + C🟡相并行（ Cap→ R2→ M 去 pin ） |
| **当前主线 ** | **阶段B + C 并行** （自举语义完成 ） | 见 [`自举进度.md`] (自举进度.md) |

----

## 九、文档索引

| 文档 | 内容 |
|------|------|
| [`自举进度.md`] (自举进度.md) | **自举/终局G 进度（优先维护 ） ** |
| [`当前进度.md`] (当前进度.md) | 当天工程阻塞与复现命令 |
| [`自举方法.md`] (自举方法.md) | CAP/R/L/M 方法论 |
| [`NEXT.md`] (NEXT.md) | 路线图、阶段 G 任务、门 命令 |
| [`docs/README.md`](文档/README.md) | 语言语法文档索引 |
| [`analysis/自举进度.md`] (analysis/自举进度.md) | 自举进度仪表盘（ KPI/前排/ 三轨） |
| [`analysis/需求分析.md`] (analysis/需求分析.md) | 总体目标、性能与安全策略 |
| [`analysis/构架分析.md`] (analysis/构架分析.md) | 仓库结构、编译器模块划分 |
| [`analysis/语法与类型设计-高性能与内存安全.md`] (analysis/语法与类型设计-高性能与内存安全 .md) | 类型与语义设计原则 |
| [`analysis/编译时自动内存管理和自动向量化.md`] (analysis/编译时自动内存管理和自动向量化.md) | Arena 、SROA、 autovec 路线 |
| [`analysis/安全与性能.md`] (analysis/安全与性能.md) | 编译器与语言安全防线 |
| [`analysis/性能压榨.md`] (analysis/性能压榨.md) | 性能分层与自举前 perf 底线 |
| [`analysis/IR核心设计.md`] (analysis/IR核心设计 .md) | 五层 IR 架构（ Architecture Freeze v4.0自举后启动 ） |
| [`compiler/docs/SELFHOST.md`]（编译器/文档/SELFHOST.md） | 自举运维与验收命令 |
| [`editors/vscode/README.md`]（编辑器/vscode/README.md） | VS代码/光标/Trae 插件与 LSP 配置 |

`analysis/` 下另有大量 RFC 与模块级设计（ std-http、 std-async、 perf 等） ，按模块名检索即可。

----

## 十、测试与质量

- **全量回归 ** ： `./tests/run-all.sh`
- ** B-strict CI ** ： `SHUX=./compiler/shux ./tests/run-bootstrap-bstrict-ci.sh` （或 `shux_asm` ）
- **推送前P0 ** ： `SHUX=./compiler/shux ./tests/run-pre-push-p0.sh`
- ** Linux 金标准** ： `./tests/run-linux-a09-a11-gate.sh`
- **登机口脚本** ： `tests/run-*-gate.sh` （借用、竞技场、区域、线性、自动等）
- **编译路径不回退 ** ： `SHUX_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh`
- **性能基线 ** ： `tests/baseline/`、 `analysis/perf-*.md`

### 性能基准结果（ 2026-07-09 ， Linux x86_64 ，反作弊修复后公平数据 ）

> 测试机Ubuntu x86_64 ；对照编译器 `clang -O2 -std=c11` ； SHUX 编译器 `./compiler/shux` （ seed ， ASM 后端，默认 `-O2` ）。
> 门禁标准（开发规范 v1 § 4 ） ： SHUX 自研后端 wall time 中位数 ≤ C `-O2` 中位数。采样：预热3 +回合20 ，取中位数。
> 反作弊：所有 C 源码均含 `__asm__ volatile` 阻止常量折叠（ `call_boundary.c`/`struct_param.c` 已修复，见提交567bea0a ）。

#### 差分测试 D1–D6 （退出行为正确性码+标准输出与C 同源一致）

| 用例 | 验证内容 | Result |
|------|---------|------|
| D1 `int_arith` | u32溢出回绕 /有符号除法向零截断/取模符号/移位/ 位运算 | ✅ 通过 (rc=242) |
| Dq {{D0}} | repr (C)布局/packed无填充/嵌套struct/ 字段读写 | ✅ 通过 (rc=50) |
| D3 `call_conv` | 多参数传递（ > 6 寄存器溢出栈）/struct 返回值/ 递归调用 | ✅ 通过 (rc=178) |
| 直流 `float` | IEEE 754浮点运算/ 浮点比较 | ❌ FAIL （ P2 占位， ASM 后端浮点 codegen 待实现） |
| D5 `bit_ops` | 负数算术右移 /无符号逻辑右移/ 位域提取/ 位设置清除 | ✅ 通过 (rc=130) |
| D6 `mem_ops` | 手写 memset/memcpy/ 数组下标访问/ 循环填充拷贝 | ✅ 通过 (rc=8) |

** D1–D6 小结： 5/6合格**。 D4 浮点为 P2 占位项（ `tests/bench/diff/d4_float.x` 注释明确） ，待 ASM 后端浮点支持完善后激活。

#### PERF-001 性能门禁（壁挂时间中位数比对，公平比较 ）

| 基准 | 循环规模 | C 中位数 | SHUX中位数 | 比率 | 门禁 |
|------|---------|----------|-------------|-------|------|
| `loop_i32` | 1 亿次 LCG 累加循环 | 45.7 毫秒 | 39.9 毫秒 | 0.87 | ✅ 通过 |
| `mem_copy` | 8192 轮 × 4096 字节填充+求和 | 7.5毫秒 | 6.5毫秒 | 0.87 | ✅ 通过 |
| `struct_param` | 1亿次按值传 对（ 2 × i32 ） | 67.6 毫秒 | 5.7 毫秒 | 0.08 | ✅ 通过 |
| `call_boundary`（折叠） | 2 亿次 5 层深调用链 | 81.1 毫秒 | 0.3毫秒 | 0.00 | ✅ 通过 |
| `call_boundary` (真跑) | 2 亿次 5 层深调用链 | 81.2 毫秒 | 143.4 毫秒 | 1.77 | ❌失败 |

> ratio = SHUX median/C median ； < 1.0 SHUX 更快。采样：表示预热3 +回合20 ，取中位数（ Python `perf_counter` 精确计时）。
> `call_boundary` 提供两组数据： ** fold ** =编译期仿射循环消除（识别 `while(i<n){s=s+f(i);i++}` 模式， f0-f4 为 `x+K` 链 K = 5 ，闭式求值 `n(n-1)/2 + K·n` ， 2 亿次循环折叠为 2 条指令 `mov $total,%eax; store` ） ； **真跑 ** = 禁用 fold 公平比较运行时性能，差距来自 ASM 后端无寄存器分配（循环变量 s/i 全存栈，每轮 load/store ， clang `-O2` 留在寄存器）。自举后实现寄存器分配可让真跑比率趋近1.0。

> macOS arm64 因 CG002 （ ASM 后端 `code_len=0` 限制）无法运行 ASM 后端基准，请在 Linux x86_64 上执行（可用 `ssh ubuntu-server` ）。

----

## 十一、工具链生态

| Component | 路径 | 说明 |
|------|------|------|
| VS代码/光标/Trae 插件 | [`editors/vscode/`]（编辑器/vscode/） | 语法高亮、LSP （ `shux --lsp` ）、格式化、任务、诊断 ； 32 项配置、14 种 UI 语言、36个片段 |
| 语言服务器 | `compiler/src/lsp/` | `lsp.x`、 `lsp_diag.x` 等；需 `compiler/shux` 支持 `--lsp` |
| MCP服务器 | [`mcp/`] (mcp/) | IDE/AI 通过 MCP 调用解析与诊断 |

安装插件：见 [`editors/vscode/README.md`] (editors/vscode/README.md) （ VSIX 或开发模式） ；工作区需打开文件夹 以启动LSP。

----

## 十二、参与开发

1. 克隆后： `make -C compiler build-tool && ./shux-build.sh first-time` （或 `make -C compiler bootstrap-driver-bstrict` ）。
2. 日常改 `.x` 后： `./shux-build.sh build` （或 `cd compiler && ./build_tool ./shux` ） ，再跑 `./tests/run-all.sh`/ 相关门。
3. 自举相关改动： `make -C compiler bootstrap-verify` ；终局项对照 [`analysis/自举进度.md`] (analysis/自举进度.md)。
4. 提交规范：常规提交（ `feat:`/`fix:`/`perf:` 等） ，英文描述。

**当前决议 ** ：标准库 **新功能 **暂停 ； **唯一主线 = 自举语义完成** （阶段B + C 并行： Cap 能力解锁 → R2 真迁退役 → M mega 去 pin ）。自举完成后启动 IR阶段0 （架构已冻结 v4.0 ）。

----

## 十三、许可证

本项目采用 ** GNU Affero通用公共许可证v3.0 或更高版本** （ AGPL-3.0或更高版本）授权。

- 完整许可文本： [`LICENSE`] （许可证）
- 版权与第三方声明： [`NOTICE`] (NOTICE)

### 商业授权

若你的使用场景需要**不受 AGPL-3.0 copyleft 约束** （例如将 Shux 编译器、工具链或衍生作品嵌入闭源产品，或作为网络服务运行修改版而不向远程用户提供对应源码 ） ，请联系作者洽谈 **商业许可 ** ：

- Shuliang Fu — [admin@shuliangfu.com] (mailto: admin@shuliangfu.com)

----

* Shux — 极致压榨性能，简单、易读、易维护 ，内存安全。 *
