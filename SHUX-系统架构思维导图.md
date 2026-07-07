# SHUX 系统架构思维导图

> 范围：系统架构级别骨架，覆盖编译流水线、核心子系统、构建系统、测试体系、CI、项目文档与辅助资源。**不深入每个函数**，仅给「文件路径 + 顶层入口函数 + 一句话职责」。目标读者：要修复 codegen/typeck bug 的工程师。
>
> 更新时间：2026-07-05（补全优化版）

---

## 0. 顶层全景图

```
SHUX 项目
├── 双编译器架构（同源不同代码路径）
│   ├── shux-c       C 前端考古冷启动二进制（SHUX_LEGACY_C_FRONTEND=1）
│   ├── shux         bootstrap-driver-seed（.x pipeline 自举路径）
│   └── shux_asm     asm 后端编译 .x 为 .o 后链接得到的 shux
├── 编译流水线（main.x 编排，pipeline.x 主体）
│   └── preprocess → lexer → parser → typeck → codegen/asm → ld
├── 核心子系统（compiler/src/）
│   ├── ast         AST 数据结构（ASTArena/Module/Func/Expr/Type）
│   ├── lexer       词法
│   ├── parser      语法
│   ├── typeck      类型检查 + 泛型单态化
│   ├── codegen     C 后端（codegen.c，出 C 文本调 cc）
│   ├── asm         asm 后端（直出 .s/.o 不调 cc，130 文件分 7 类）
│   ├── ir          IR 层（计划中，未实现）
│   ├── async       async/await CPS 状态机
│   ├── lsp         LSP JSON-RPC
│   ├── preprocess  条件编译预处理（#if/#else/#endif）
│   ├── driver/pipeline  CLI 子命令 + 流水线编排
│   ├── runtime_*   C 侧 driver/pipeline/ABI 薄壳系列（13 个文件）
│   └── 散落桥接/桩   x_bridge / x_seed_bridge / win32_stubs / shims 等（~17 个文件）
├── 语言核心库 core/    12 个模块（assert/builtin/cmp/debug/fmt/iterator/mem/option/result/slice/str/types）
├── 标准库 std/         64 个模块，每个模块用 mod.x 作对外门面
├── 构建系统（三层入口）
│   ├── 根 Makefile       薄包装，委托 compiler/Makefile
│   ├── compiler/Makefile 单文件 ~2500 行，覆盖所有 target（传统入口，CI 主用）
│   ├── build.x 系列      根目录 build.x / build_runner.x / build_runtime.x / build_runtime_x.x / build.sh / shux-build.sh（build_tool 二进制驱动，G-05 目标替代 Makefile）
│   ├── compiler/scripts/  55 个构建辅助脚本（build_shux_asm.sh 等）
│   ├── scripts/         根目录 18 个迁移/工具脚本（shux-deps-*.sh、migrate_*.pl 等）
│   └── tools/           18 个一次性迁移脚本（add_*_license_header.sh、audit_import_migration.py 等）
├── 文档与编辑器集成
│   ├── docs/            12 个文档（01-关键字 ~ 10-内核级特性 + README + 语法文档与实现对照.md）
│   ├── analysis/        566 个架构分析/阶段总结文档（phase*/std*/boot*/comp*/core*/perf*/lang*/safe* 等）
│   ├── editors/         vim + vscode 编辑器集成（含 LSP client、语法高亮、snippets）
│   ├── examples/        示例程序（hello.x + cookbook/ 59 个 .x 示例）
│   ├── runtime/         最小运行时（仅 README，嵌入式 crt0/栈/panic/backtrace 预留位）
│   └── 顶层散落文档     NEXT.md（路线图）、当前进度.md、架构分析.md、问题分析文档.md、9 个 debug-*.md
├── 测试体系
│   ├── tests/run-all.sh       全量回归入口（C 流水线默认），调用 ~109 个脚本
│   ├── tests/run-all-bstrict.sh B-strict 严格门禁（shux_asm），~120 项固定列表
│   ├── tests/run-*.sh         tests/ 下共 884 个脚本（含子测试），run-all.sh 串联其中 ~109 个
│   └── tests/docs/            测试文档（run-all-l5-whitelist.md 等）
├── CI（.github/workflows/）
│   ├── ci.yml                    多平台全量 + asm smoke
│   ├── ci-nightly.yml            夜跑 SAFE/PERF/ENG
│   ├── selfhost-stage2.yml       自举二阶段验证
│   └── bootstrap-seeds-capture.yml 种子 capture（多平台）
└── 辅助目录
    ├── .dbg/             43 个调试日志/输出文件（asm-seed-full-* 等）
    ├── .devcontainer/    dev container 配置
    ├── mcp/              MCP 预留（.gitkeep）
    ├── .vscode/          VS Code 工作区配置
    ├── .clangd           clangd 配置
    └── .cursor/          Cursor IDE 配置
```

---

## 1. 双编译器架构

```
SHUX 双编译器
├── shux-c（C 前端）
│   ├── 构建：make SHUX_LEGACY_C_FRONTEND=1 shux-c
│   ├── 链入完整 C 前端：lexer.c/parser.c/typeck.c/codegen.c
│   ├── 不支持 -backend asm（runtime.c:1219 报 BLD001）
│   ├── 用于冷启动、生成 seeds/
│   └── shux-c target 默认是 cp bootstrap_shuxc（须 -B + SHUX_LEGACY_C_FRONTEND=1 才真编译）
├── shux（bootstrap-driver-seed，.x pipeline）
│   ├── 构建产物：make bootstrap-driver-seed
│   ├── 不 include C 前端头（SHUX_NO_C_FRONTEND，runtime.c:4-6,178）
│   ├── 走 .x pipeline（SHUX_USE_X_PIPELINE 宏控制）
│   ├── 默认走 ASM 后端（driver_run_asm_backend, runtime.c:3238）
│   └── 用于自举验证、CI asm smoke
└── shux_asm（asm 后端构建的 shux）
    ├── 构建：scripts/build_shux_asm.sh
    ├── 用 shux -backend asm 把 compiler 的 .x 模块逐个编译为 .o
    ├── 与最小 C 桩 runtime_asm_build.c 链接得到 shux_asm
    ├── M7 release 默认路径（make bootstrap-driver-bstrict）
    └── 行为等价 shux，但构建路径不同
```

### 关键宏开关

| 宏 | 位置 | 控制 |
|---|---|---|
| `SHUX_LEGACY_C_FRONTEND` | Makefile | =1 链 C 前端构建 shux-c |
| `SHUX_NO_C_FRONTEND` | runtime.c:4,6,178,4176 | 不 include C 前端头（shux/shux_asm） |
| `SHUX_USE_X_PIPELINE` | runtime.c:365,614,654,817 | 启用 .x pipeline 路径 |
| `SHUX_USE_X_FRONTEND` | runtime.c:1098 | run_compiler_c 报错强制走 .x |
| `SHUX_USE_X_DRIVER` | runtime.c:993 | 禁用 dce_ctx（.x driver 自管） |
| `SHUX_USE_X_CODEGEN` | codegen.c:27,206,2924+（30+ 处） | 用 .x codegen 入口替换 C 整/bool 字面量格式化 |
| `SHUX_SKIP_SUBSCRIPT_MAKE` | Makefile:705,708 | 跳过 cp -f bootstrap_shuxc shux-c（防覆盖） |
| `SHUX_FORCE_REGEN_GEN` | Makefile:1097+ | 强制重新生成 *_gen.c（pinned 默认跳过） |

### 1.1 -E-extern → _gen.c → _x.o 桥接模式（自举核心机制）

SHUX 自举的关键路径：**逐模块用 .x 实现替换 .c 实现**，通过 `-E -extern` 模式将 .x 源码导出为 C 文件再编译为 .o，替代原有 C 前端的 .o。

```
parser.x  → shux -E -extern → parser_gen.c  → cc -c → parser_x.o  （替代 parser.o）
typeck.x  → shux -E -extern → typeck_gen.c  → cc -c → typeck_x.o  （替代 typeck.o）
codegen.x → shux -E -extern → codegen_gen.c → cc -c → codegen_x.o （替代 codegen.o）
```

- **桥接文件**：[compiler/src/x_bridge.c](file:///home/shu/shux/compiler/src/x_bridge.c) — 将 runtime.c 调用的 C 原版符号桥接到 .x 生成的实现；与上述 .o 一起链接，替代 parser.o / typeck.o / codegen.o
- **运行时仍通过 C 的 ast.o / lexer.o 分配 Module/Arena**，.x 实现只做解析/类型检查/代码生成
- **seed 链补齐**：[compiler/src/x_seed_bridge.c](file:///home/shu/shux/compiler/src/x_seed_bridge.c) — bootstrap-driver-seed 分 TU 链接桥：preprocess 名前缀、asm 桩、ast 辅助、heap 桩；补齐 pipeline_x.o / parser_x.o / typeck_x.o / codegen_x.o 经 -E-extern 分模块后 runtime/driver/lsp 仍引用的 C 路径或 import 前缀符号缺口
- **_gen.c 产物**：如 `fmt_main_gen.c`（根目录，22KB）即为 fmt 模块经 -E-extern 生成的 C 中间产物

> 修 bug 时注意：如果问题出在 .x 路径但 C 路径正常（或反之），先确认当前链接的是 `_x.o` 还是原 `.o`——桥接层是分水岭。

---

## 2. 编译流水线（一个 .x 到可执行文件）

### 主链路（默认 asm 后端）

```
$ shux file.x
  └── main.c: main() → shux_forward_main_to_main_entry  [runtime_abi.c]
       └── main.x: entry(argc, argv)  [compiler/src/main.x:668]
           └── main_run_compiler_x_path_impl  [main.x:611]
               └── run_compiler_c_impl → driver_run_compiler_full  [runtime.c:6033]
                   └── driver_run_asm_backend  [runtime.c:3238]
                       ├── [读文件]  runtime_io_abi.c: runtime_read_file_malloc
                       ├── [预处理]  preprocess.x: preprocess_x_buf  (经 preprocess_shim.c 桥接)
                       ├── [pipeline] pipeline.x: run_x_pipeline_impl  [pipeline.x:656]
                       │   ├── parse:    run_x_pipeline_parse_entry_if_needed  [pipeline.x:515]
                       │   ├── load deps: run_x_pipeline_load_deps_after_parse  [pipeline.x:531]
                       │   ├── typecheck: run_x_pipeline_typecheck_after_load  [pipeline.x:547]
                       │   └── codegen:  run_x_pipeline_codegen_deps + run_x_pipeline_codegen_entry  [pipeline.x:603,639]
                       │                 → asm/backend.x: asm_codegen_ast  [asm/backend.x:2310]
                       │                   → arch/{x86_64,arm64,riscv64}.x emit_*（文本 .s）
                       │                   → arch/*_enc.x enc_* + platform/{elf,macho,coff}.x write_*_o_to_buf（直出 .o）
                       └── [链接]    runtime_link_abi.c: shux_invoke_ld_for_exe / invoke_cc → 可执行文件
```

> **main.c vs main_x.c**：
> - `main.c`：标准入口，调用 `main_entry(argc, argv)` 后正常 return
> - `main_x.c`：X 自举构建专用入口，调用 `main_entry` 后用 `_exit(r)` 绕过 atexit/global-dtor 崩溃

### C 后端路径（-backend c 或 shux-c）

```
$ shux-c file.x
  └── main.c: main() → main_entry
      └── runtime.c: RUN_CC_FUNC  [runtime.c:1097]
          ├── 解析 argv：emit_c_only / emit_extern_imports 标志  [runtime.c:1115-1156]
          ├── [typeck]    typeck_module  [typeck/typeck.c:4521]
          ├── [codegen]   codegen_codegen_entry_module_to_c  [codegen.c]
          │                （-E 模式时只写 C 到 stdout，不调 cc）
          └── [链接]      shux_invoke_cc  [runtime_link_abi.c:2940]
                          （-E 时跳过，仅写出 .c 文件）
```

### 关键边界

- **C 后端**：`codegen.c: codegen_module_to_c / codegen_library_module_to_c` → 出 C 文本 → 调 cc
- **asm 后端**：`asm/backend.x: asm_codegen_ast` → 出 .s 或直出 .o（不调 cc）
- pipeline 通过 `ctx.use_asm_backend` 切换两条路径
- **`-E` 模式**（emit C 不链接）：`runtime.c: driver_run_x_emit_c`（line 6247）+ `RUN_CC_FUNC` 内 `emit_c_only` 标志
- **`-E -extern` 模式**：导出 extern 声明供桥接（见 §1.1）

---

## 3. 核心子系统

### 3.1 ast（AST 数据结构）

- [compiler/src/ast/ast.x](file:///home/shu/shux/compiler/src/ast/ast.x) — 核心结构定义
  - `struct ASTArena`（行 367）— 全局 AST 池（num_types/num_exprs/num_blocks/num_funcs...）
  - `struct Module`（行 337）— 模块（num_funcs/main_func_index/num_imports...）
- [compiler/src/ast/ast.c](file:///home/shu/shux/compiler/src/ast/ast.c) — C 侧 AST 操作

### 3.2 lexer（词法）

- [compiler/src/lexer/lexer.c](file:///home/shu/shux/compiler/src/lexer/lexer.c) + [lexer.x](file:///home/shu/shux/compiler/src/lexer/lexer.x) — 词法分析器
  - 入口：`lexer_new(source)` → `lexer_next(l, out)`
- [compiler/src/lexer/token.x](file:///home/shu/shux/compiler/src/lexer/token.x) — Token 定义
- [compiler/src/lexer/cfg_eval.x](file:///home/shu/shux/compiler/src/lexer/cfg_eval.x) — `#[cfg(...)]` 表达式求值（与 preprocess 共享）

### 3.3 parser（语法）

- [compiler/src/parser/parser.c](file:///home/shu/shux/compiler/src/parser/parser.c) + [parser.x](file:///home/shu/shux/compiler/src/parser/parser.x) — 语法分析器（~5000+ 行 .x）
  - C 入口：`parse(lex, out)`
  - .x 入口：`parse_into_*` 系列
- **注意**：`compiler/src/asm/parser_asm_*_slice.c`（约 20 个）是 asm EMIT_HEAVY 切片，**不属于 parser 目录**

### 3.4 typeck（类型检查 + 泛型单态化）

- [compiler/src/typeck/typeck.c](file:///home/shu/shux/compiler/src/typeck/typeck.c) + [typeck.x](file:///home/shu/shux/compiler/src/typeck/typeck.x)
  - 入口：`typeck_module(m, dep_mods, num_deps, all_dep_mods, n_all_deps)`（typeck.c:4521）
  - 懒 typeck：`typeck_one_function`（LSP 用）
- [compiler/src/typeck/typeck_f64_bits.c](file:///home/shu/shux/compiler/src/typeck/typeck_f64_bits.c) — double 位模式拆分
- [compiler/src/typeck/typeck_generic_struct.c](file:///home/shu/shux/compiler/src/typeck/typeck_generic_struct.c) — 泛型结构体单态化

### 3.5 codegen（C 后端）

- [compiler/src/codegen/codegen.c](file:///home/shu/shux/compiler/src/codegen/codegen.c)（~9200 行）+ [codegen.h](file:///home/shu/shux/compiler/src/codegen/codegen.h)（含 DCE/WPO 接口声明）
  - C 后端入口：`codegen_module_to_c` / `codegen_library_module_to_c`
  - .x 入口：`codegen_x_ast`（codegen.x:6520）
- [compiler/src/codegen/codegen.x](file:///home/shu/shux/compiler/src/codegen/codegen.x) — 自举重写
- [compiler/src/codegen/codegen_mini.x](file:///home/shu/shux/compiler/src/codegen/codegen_mini.x)
- [compiler/src/codegen/codegen_pipeline_stubs.c](file:///home/shu/shux/compiler/src/codegen/codegen_pipeline_stubs.c) — pipeline 桩
- [compiler/src/codegen/autovec.c](file:///home/shu/shux/compiler/src/codegen/autovec.c) — 自动向量化

### 3.6 asm（asm 后端，130 文件分 7 类）

- **对外入口**：[asm.x](file:///home/shu/shux/compiler/src/asm/asm.x)、[backend.x](file:///home/shu/shux/compiler/src/asm/backend.x)、[types.x](file:///home/shu/shux/compiler/src/asm/types.x)、[peephole.x](file:///home/shu/shux/compiler/src/asm/peephole.x)
- **架构后端**：`arch/`（8 文件）— `arch/x86_64.x`、`arch/arm64.x`、`arch/riscv64.x`（文本 asm）；`arch/*_enc.x`（机器码编码）
- **对象文件格式**：`platform/`（4 文件）— `platform/elf.x`（Linux ELF64）、`platform/macho.x`（macOS Mach-O）、`platform/coff.x`（Windows PE/COFF）
- **dispatch C 胶水**：`backend_arch_emit_dispatch.c`、`backend_call_dispatch.c`、`backend_enc_dispatch.c`、`backend_try_inline_dispatch.c`、`backend_seed_mega_fallback.c`、`asm_backend_v2.c`、`asm_backend_min.c`、`asm_backend_compat_stubs.c`
- **pipeline 切片**：`pipeline_asm_*.c`、`pipeline_glue_*.c`、`pipeline_wpo_*.c`、`pipeline_run_*.c`
- **asm parser 切片**：`parser_asm_*_slice.c`（约 20 个，按 AST 节点类型切片，EMIT_HEAVY 防大函数）
- **runtime glue**：`runtime_asm_build.c`（shux_asm 自举 main 桩）、`runtime_panic.c`、`runtime_panic_arm64.c`、`runtime_net_*.c`、`runtime_atomic_glue.c`、`runtime_channel_glue.c`、`simd_enc.c`、`simd_loop.c`、`runtime_dynlib_os.c`、`runtime_env_os.c`、`runtime_time_os.c`、`runtime_sync_os.c`

### 3.7 ir（计划中）

- [compiler/src/ir/README.md](file:///home/shu/shux/compiler/src/ir/README.md) — **未实现**，计划自定义 SSA 或 LLVM IR，位置在 typeck 之后、codegen 之前

### 3.8 async（async/await）

- [compiler/src/async/async_liveness.c](file:///home/shu/shux/compiler/src/async/async_liveness.c) — 跨 await liveness 分析
- [compiler/src/async/async_cps_codegen.c](file:///home/shu/shux/compiler/src/async/async_cps_codegen.c) — CPS switch 状态机 emit（`__shux_frame.__phase`）
- [compiler/src/async/async_asm_pool.c](file:///home/shu/shux/compiler/src/async/async_asm_pool.c) — pool AST async CPS 帧 layout（WPO-S3 / asm 后端）

### 3.9 lsp（LSP 子系统）

- [compiler/src/lsp/lsp.x](file:///home/shu/shux/compiler/src/lsp/lsp.x) — JSON-RPC 主循环（initialize/didOpen/diagnostic/definition/hover/completion）
  - 入口：`lsp_main_impl()`（lsp.x:502）
- [compiler/src/lsp/lsp_state.c](file:///home/shu/shux/compiler/src/lsp/lsp_state.c) — `typeck_lsp_main` 在 256MiB 栈 pthread 上跑（避免默认栈溢出）
- [compiler/src/lsp/lsp_diag.c](file:///home/shu/shux/compiler/src/lsp/lsp_diag.c) + `lsp_diag_pipeline_*.c` — 诊断缓存
- [compiler/src/lsp/lsp_codegen_extern.c](file:///home/shu/shux/compiler/src/lsp/lsp_codegen_extern.c) — LSP 用 codegen extern

### 3.10 preprocess（条件编译预处理）

- [compiler/src/preprocess/preprocess.x](file:///home/shu/shux/compiler/src/preprocess/preprocess.x) — 纯 .x 条件编译（`#if`/`#else`/`#elseif`/`#endif`），导出 `preprocess_x_buf`
- [compiler/src/preprocess.c](file:///home/shu/shux/compiler/src/preprocess.c) — C 侧 legacy 实现（`SHUX_LEGACY_C_FRONTEND_ABI` 宏切换）
- [compiler/src/preprocess_shim.c](file:///home/shu/shux/compiler/src/preprocess_shim.c) — 符号桥接：`preprocess_x_buf` → `typeck_preprocess_x_buf`
- [compiler/src/preprocess_if_stack_bridge.c](file:///home/shu/shux/compiler/src/preprocess_if_stack_bridge.c) — `#if` 嵌套栈 grow 池桥接

### 3.11 driver / pipeline（CLI 与编排）

- [compiler/src/driver/](file:///home/shu/shux/compiler/src/driver/) — CLI 子命令实现
  - `build.x` / `run.x` / `fmt.x` / `check.x` / `test.x` — 子命令
  - `compile.x` / `emit.x` — 编译/emit 辅助
  - `fmt_check_cmd.c` / `target_cpu.c` — C 辅助
- [compiler/src/pipeline/pipeline.x](file:///home/shu/shux/compiler/src/pipeline/pipeline.x) — 编译流水线主体
  - 入口：`run_x_pipeline_impl(module, arena, source_data, source_len, out_buf, ctx)`（pipeline.x:656）
  - 四阶段：parse → load deps → typecheck → codegen

### 3.12 runtime_*（C 侧 driver/ABI 薄壳系列）

| 文件 | 职责 | 关键函数 |
|---|---|---|
| [runtime.c](file:///home/shu/shux/compiler/src/runtime.c) (~6700 行) | C 侧 driver/pipeline 主体 | `RUN_CC_FUNC` (line 1097)、`driver_run_compiler_full` (line 6033)、`driver_run_asm_backend` (line 3238)、`driver_run_x_emit_c` (line 6247, -E 模式) |
| [runtime_abi.c](file:///home/shu/shux/compiler/src/runtime_abi.c) | argv/target 极薄原语 | `driver_get_argv_i`、`driver_resolve_target_arch`、`shux_forward_main_to_main_entry` |
| [runtime_link_abi.c](file:///home/shu/shux/compiler/src/runtime_link_abi.c) | cc/ld 链接辅助 | `shux_invoke_cc` (line 2940)、`shux_rel_o_path_from_argv0` (line 3638)、`invoke_cc_argv_push_existing` (line 2514)、`shux_invoke_ld_for_exe` |
| [runtime_driver_abi.c](file:///home/shu/shux/compiler/src/runtime_driver_abi.c) | driver CLI 跳过标志/check 输出/大栈 pthread | `driver_check_only_set/get`、`driver_freestanding_flag` |
| [runtime_io_abi.c](file:///home/shu/shux/compiler/src/runtime_io_abi.c) | POSIX 文件 I/O 原语 | `runtime_read_file_malloc`、`shux_read_file_into_path` |
| [runtime_proc_abi.c](file:///home/shu/shux/compiler/src/runtime_proc_abi.c) | 进程/链接前 .o 存在性探测 | `shu_waitpid_retry` (line 27)、`asm_link_obj_skip_missing` (line 53) |
| [runtime_pipeline_abi.c](file:///home/shu/shux/compiler/src/runtime_pipeline_abi.c) | import 路径解析、dep 全局槽、预处理/typeck/asm ELF 辅助 | `shux_resolve_import_file_path_multi`、`driver_dep_*` |
| [runtime_c_import.c](file:///home/shu/shux/compiler/src/runtime_c_import.c) | **shux-c 专用**：递归加载 import | `load_one_import`、`resolve_and_load_imports` |
| [runtime_heap_user.c](file:///home/shu/shux/compiler/src/runtime_heap_user.c) | 用户 asm 程序链接 heap_*_c 符号（转调 libc）；co-emit std.heap 薄模块时 call redirect 指向本 TU | — |
| [runtime_driver_diagnostic.c](file:///home/shu/shux/compiler/src/runtime_driver_diagnostic.c) | driver 诊断 | — |

### 3.13 桥接 / 桩 / shim 散落文件

#### 自举桥接（见 §1.1 桥接模式）

| 文件 | 职责 |
|---|---|
| [x_bridge.c](file:///home/shu/shux/compiler/src/x_bridge.c) | C 符号 → .x 生成实现桥接（parser/typeck/codegen 的 _gen.o 替代原 .o） |
| [x_seed_bridge.c](file:///home/shu/shux/compiler/src/x_seed_bridge.c) | bootstrap-driver-seed 分 TU 链接桥：preprocess 前缀、asm 桩、ast 辅助、heap 桩 |
| [x_stubs.c](file:///home/shu/shux/compiler/src/x_stubs.c) / [x_stubs.h](file:///home/shu/shux/compiler/src/x_stubs.h) | X 管线链接桩：ASM 后端/IO 批处理/LSP 等未在 X 路径实现模块的空实现 + 模块前缀命名不一致桥接 |
| [x_stubs.c](file:///home/shu/shux/compiler/src/x_stubs.c) / [x_stubs.h](file:///home/shu/shux/compiler/src/x_stubs.h) | X 管线链接桩（同 x_stubs 语义，X 路径版本） |

#### 平台适配

| 文件 | 职责 |
|---|---|
| [win32_pipeline_stubs.c](file:///home/shu/shux/compiler/src/win32_pipeline_stubs.c) | **Windows 专用**（`#ifdef _WIN32`）：.x 管道/AST/driver 函数空实现，使 C 前端 shux-c 可在 Windows 链接 |
| [std_fs_shim.c](file:///home/shu/shux/compiler/src/std_fs_shim.c) | 提供 `std_fs_fs_*` 符号供 -E-extern 生成的 pipeline/driver 链接；调用 libc open/read/write/close（Windows 用 _open/_read/_write） |
| [std_sys_shim.c](file:///home/shu/shux/compiler/src/std_sys_shim.c) | 提供 `std_sys_os_read_file_into` 供 -E-extern pipeline/driver 链接；open + 循环 read 语义 |

#### 构建 / 诊断 / 兼容

| 文件 | 职责 |
|---|---|
| [main.c](file:///home/shu/shux/compiler/src/main.c) | 标准进程入口：`main()` → `main_entry(argc, argv)` → return |
| [main_x.c](file:///home/shu/shux/compiler/src/main_x.c) | X 自举构建专用入口：`main()` → `main_entry` → `_exit(r)`（绕过 atexit/global-dtor 崩溃） |
| [diag.c](file:///home/shu/shux/compiler/src/diag.c) / [diag.h](file:///home/shu/shux/compiler/src/diag.h) | 诊断输出模块 |
| [build_tool_main.c](file:///home/shu/shux/compiler/src/build_tool_main.c) | build_tool 极薄 main（G-05）：转调 `build_entry(argc, argv)`（build_runner.x） |
| [build_tool_libc_bridge.c](file:///home/shu/shux/compiler/src/build_tool_libc_bridge.c) | build_tool 宿主 libc 桥：提供 `build_exec_system` 等 C 签名包装（避免 .x extern 与 Darwin stdlib 类型冲突） |
| [build_runtime.c](file:///home/shu/shux/compiler/src/build_runtime.c) | build.x 的 C 执行后端：按 `build_get_step_count()` / `build_get_step_at()` 顺序执行；`build_run_step` 跑默认路径（.x → *_gen.c → cc）；`build_run_asm_build` 调 build_shux_asm.sh |
| [build_obj_stubs.c](file:///home/shu/shux/compiler/src/build_obj_stubs.c) | 为 build-obj 生成的 .o 提供最小运行时符号桩（shux_io_* 等） |
| [ast_pool_l5_bridge.c](file:///home/shu/shux/compiler/src/ast_pool_l5_bridge.c) | B-strict 链补链：preprocess -D 与 labeled 名写入（从 ast_pool.c 抽出，避免整 TU 编 glue_standalone） |
| [seed_link_compat.c](file:///home/shu/shux/compiler/src/seed_link_compat.c) | seed 链接兼容：LSP IO 符号 extern 声明 + weak 桩（lsp_diag_*/hover_at/references_at 等） |

#### 其他胶水

| 文件 | 职责 |
|---|---|
| [runtime_driver_strict_glue_stubs.c](file:///home/shu/shux/compiler/src/runtime_driver_strict_glue_stubs.c) | strict 链（无 C 前端）时为 codegen/lexer/parser/typeck 提供 SHUX_WEAK 空桩 |
| [compiler/src/asm/runtime_crypto_inc_glue.c](file:///home/shu/shux/compiler/src/asm/runtime_crypto_inc_glue.c) | std.crypto C 胶层（SHA-512/HMAC/seed asm 辅助） |
| [runtime_pipeline_abi_shux_c_stubs.c](file:///home/shu/shux/compiler/src/runtime_pipeline_abi_shux_c_stubs.c) | shux-c 路径下 pipeline ABI 桩 |

---

## 4. WPO / DCE 子系统

### WPO（全程序优化）

- 入口函数（均在 [codegen.c](file:///home/shu/shux/compiler/src/codegen/codegen.c)，声明在 codegen.h）：
  - `codegen_wpo_reach_compute(out, entry, all_mods, n_all)`（codegen.c:8936）— **reach 分析主入口**
  - `codegen_wpo_reach_is_reachable(wpo, mod, func)`（codegen.c:8955）
  - `codegen_dump_wpo_callgraph_json(out, entry, entry_path, all_mods, all_paths, n_all)`（codegen.c:8985）— call graph JSON
  - `codegen_wpo_collect_mono_thunks(out, entry, dep_mods, ndep, entry_path)`（codegen.c:9153）— 单态 thunk 收集
- 触发开关（环境变量）：
  - `SHUX_WPO_DCE=1` — 跨模块 dead export 剔除
  - `SHUX_WPO_DUMP_CALLGRAPH=<path>` — dump call graph
  - `SHUX_WPO_MONO=1` — 单态 thunk 收集
  - `SHUX_WPO_NO_FOLD=1` — 禁止折叠
- pipeline glue：[pipeline_wpo_strict_link_alias.c](file:///home/shu/shux/compiler/src/asm/pipeline_wpo_strict_link_alias.c)、[pipeline_wpo_typecheck_emit_bridge.c](file:///home/shu/shux/compiler/src/asm/pipeline_wpo_typecheck_emit_bridge.c)

### DCE（死代码消除）

- 入口函数（[codegen.c](file:///home/shu/shux/compiler/src/codegen/codegen.c)）：
  - `codegen_compute_used(entry, dep_mods, ndep, used_funcs_out, n_used_out, max_used, used_mono)`（codegen.c:7168）— **DCE 主入口**：从 main 起算可达性
  - `codegen_compute_used_types(...)`（codegen.c:7341）— 收集被引用类型名
  - 回调类型：`codegen_is_func_used_fn` / `codegen_is_mono_used_fn` / `codegen_is_type_used_fn`（codegen.h:20-23）
- `dce_ctx` 数据结构：定义在 [runtime.c:993](file:///home/shu/shux/compiler/src/runtime.c#L993)（在 `#if !defined(SHUX_USE_X_DRIVER)` 内）
  ```c
  struct dce_ctx {
      ASTFunc **used;              // 可达函数数组
      int n;                      // 可达函数个数
      int (*mono)[64];            // 单态化实例可达表（每行 64 实例）
      int mono_rows;              // 行数 = 1 + n_all_deps
      const char **used_type_names;
      int n_used_types;
      ASTModule *entry;
      ASTModule **deps;
      int nd;
      const CodegenWpoReach *wpo;
  };
  ```
- 填充：`runtime_prepare_dce_ctx(...)`（runtime.c:1008）
- 使用：作为 `dce_ctx` 参数传给 `codegen_module_to_c` / `codegen_library_module_to_c` 的 `is_func_used` / `is_mono_used` / `is_type_used` 回调上下文
- **库模块 -E 必须禁用 DCE**：无 main_func 时把 `dce_ctx_arg = NULL`（runtime.c:1910 n_all>0 分支 + 本轮修复的 line 2155 n_all==0 分支）

---

## 5. 构建系统

### 5.0 三层构建入口关系

SHUX 存在三条构建入口路径，反映从传统 Makefile 向 build_tool 迁移的过渡状态：

```
┌─────────────────────────────────────────────────────────────────┐
│  入口 1：根 Makefile（薄包装）                                    │
│  make all / make test / make test_c / make test_x               │
│  └── 委托 → compiler/Makefile（~2500 行，传统入口，CI 主用）       │
│                                                                   │
│  入口 2：shux-build.sh（G-05 统一构建入口，目标替代 Makefile）      │
│  ./shux-build.sh all / clean / test / bootstrap-* / kernel       │
│  ├── 编译器构建 → 委托 build_tool                                 │
│  └── 测试与内核 gate → 本脚本处理                                 │
│                                                                   │
│  入口 3：build.sh + build.x 系列（build_tool 二进制驱动）           │
│  ./build.sh → 选择编译器路径 → 调用 build_tool                     │
│  build_tool = build_tool_main.c + build_runtime.c + build.x      │
│  └── build_runner.x / build_runtime.x / build_runtime_x.x        │
└─────────────────────────────────────────────────────────────────┘
```

- **当前状态**：CI 主用 compiler/Makefile；build.x 系列 + shux-build.sh 是「朝 Zig/Build 系统对齐」的现代构建驱动，长期目标 Makefile 可删除
- **compiler/Makefile 注释**明确说明：日常以 `./build_tool ./shux` 与 `./build_tool ./shux asm` 为准

### 5.1 根 Makefile

主入口：[Makefile](file:///home/shu/shux/Makefile)（薄包装，委托 compiler 目录）

| Target | 职责 |
|---|---|
| `all` | 委托 `make -C compiler` |
| `clean` | 委托 `make -C compiler clean` |
| `test` | 委托 `make -C compiler test`（先 test_c 再 test_x） |
| `test_c` | 委托 `make -C compiler test_c` |
| `test_x` | 委托 `make -C compiler test_x` |
| `bootstrap-lexer` | 用当前 shux 编译 .x 词法分析器并运行验证 |
| `bootstrap-token` | 用当前 shux 编译 token.x 并运行 |

### 5.2 compiler/Makefile 核心 target

主入口：[compiler/Makefile](file:///home/shu/shux/compiler/Makefile)（~2500 行，单文件）

| Target | 行号 | 职责 |
|---|---|---|
| `all` | 660-663 | 默认构建 shux + shux-c；SHUX_RUN_ALL_BOOTSTRAP_SHUX=1 时改为 bootstrap-driver-seed |
| `shux` | 666-667 | 链接 $(OBJS) 出可执行 shux |
| `shux-c` | 707-708 | 默认 cp -f bootstrap_shuxc；SHUX_LEGACY_C_FRONTEND=1 时真编译 |
| `bootstrap-driver-seed` | 2052, 2062-2117 | G-06 两阶段 seed（shux-seed-phase1 → asm.x -E 出 asm_backend_partial.o → 终链 shux） |
| `bootstrap-driver-bstrict` | 2223-2232 | 调 build_shux_asm.sh 走 strict 链；末尾 cp shux_asm shux |
| `bootstrap-driver` | 2250 | 别名 → bootstrap-driver-bstrict |
| `bootstrap-driver-crt0` | 2257-2263 | Linux crt0 + full_asm .o 链 |
| `shux_asm` | 2149-2151 | relink-shux 后 cp -f shux shux_asm |
| `relink-shux` | 2153-2164 | 快速重链 shux（不跑 asm.x -E），日常快路径 |
| `shux-x` | 2193-2196 | 仅重链 ./shux-x |
| `bootstrap_shuxc` | 670-672 | 跑 scripts/select_bootstrap_shuxc.sh 拷种子 |
| `build-tool` / `build-tool-x` / `build-via-tool` | 2289-2310 | 用 shux-c 跑 build.x 出 build_tool 二进制 |
| `std-objs` | 663 | 构建 $(STD_AND_PANIC_O)（约 50+ 个 std/*.o + glue + panic） |
| `test_c` | 1056-1058 | 依赖 shux + shux-c + STD_AND_PANIC_O，跑 tests/run-all-c.sh |
| `test_x` | 1061-1064 | 依赖 bootstrap-driver-seed，跑 run-lsp.sh + run-all-x.sh |
| `test` | 1067-1068 | 先 test_c 再 test_x |

### 5.3 关键构建脚本

| 脚本 | 路径 | 职责 |
|---|---|---|
| `shux_compile_std_x.sh` | [scripts/shux_compile_std_x.sh](file:///home/shu/shux/compiler/scripts/shux_compile_std_x.sh) | std/*.x → .o 统一包装器；auto 模式按 shux_asm → shux → shux-c 优先级；asm 失败回退 shux-c -E + cc -c |
| `build_shux_asm.sh` | [scripts/build_shux_asm.sh](file:///home/shu/shux/compiler/scripts/build_shux_asm.sh) (247KB) | 用 asm 后端构建 shux；关键函数 `compile_x` (line 198)、`ld_partial_export` (line 305)、`rebuild_pipeline_o_second_pass` (line 329) 等 |
| `bootstrap_shuxc_create.sh` | [scripts/bootstrap_shuxc_create.sh](file:///home/shu/shux/compiler/scripts/bootstrap_shuxc_create.sh) | 从 shux_asm/shux 生成冷启动种子 bootstrap_shuxc；Darwin 上 codesign 重签名 |
| `bootstrap_shux_create.sh` | [scripts/bootstrap_shux_create.sh](file:///home/shu/shux/compiler/scripts/bootstrap_shux_create.sh) | cp ./shux ./bootstrap_shux |
| `select_bootstrap_shuxc.sh` | [scripts/select_bootstrap_shuxc.sh](file:///home/shu/shux/compiler/scripts/select_bootstrap_shuxc.sh) | 选择可用种子：当前 ./bootstrap_shuxc → seeds/bootstrap_shuxc.<os>.<arch> → 回退 shux-c/shux-seed-phase1/shux/shux_asm |
| `build_seed_asm_host.sh` | [scripts/build_seed_asm_host.sh](file:///home/shu/shux/compiler/scripts/build_seed_asm_host.sh) | 用 shux-seed-phase1 跑 asm.x -E 生成 build_asm/seed_host/asm_backend_partial.o |
| `bootstrap_driver_seed_smoke.sh` | [scripts/bootstrap_driver_seed_smoke.sh](file:///home/shu/shux/compiler/scripts/bootstrap_driver_seed_smoke.sh) | seed 链成功后跑烟测（被 Makefile:2109 调用） |
| `capture_bootstrap_seeds.sh` | [scripts/capture_bootstrap_seeds.sh](file:///home/shu/shux/compiler/scripts/capture_bootstrap_seeds.sh) | CI 中跑 capture（被 bootstrap-seeds-capture.yml 调用） |

> compiler/scripts/ 共 **55** 个脚本，上面列出最关键的 8 个。

### 5.4 根目录 build.x 系列 + shux-build.sh（build_tool 二进制驱动）

| 文件 | 路径 | 职责 |
|---|---|---|
| `shux-build.sh` | [shux-build.sh](file:///home/shu/shux/shux-build.sh) | **G-05 统一构建入口**（5KB），目标替代 Makefile；编译器构建委托 build_tool，测试与内核 gate 本脚本处理 |
| `build.sh` | [build.sh](file:///home/shu/shux/build.sh) | 顶层 shell 构建入口（2KB），选择编译器路径后调用 build_tool |
| `build.x` | [build.x](file:///home/shu/shux/build.x) | build_tool 主驱动 .x（9KB），解析 build 命令并调度 build_runner/build_runtime |
| `build_runner.x` | [build_runner.x](file:///home/shu/shux/build_runner.x) | 编译 .x 源为 .o 的 runner（4KB），调用 shux/shux_asm/shux-c 按依赖顺序编译 |
| `build_runtime.x` | [build_runtime.x](file:///home/shu/shux/build_runtime.x) | 构建 runtime 模块（18KB），含 runtime 库的 .x 编译/链接编排 |
| `build_runtime_x.x` | [build_runtime_x.x](file:///home/shu/shux/build_runtime_x.x) | build_runtime 的 .x pipeline 版本变体（18KB），供 self-host stage2 用 |
| `fmt_main_gen.c` | [fmt_main_gen.c](file:///home/shu/shux/fmt_main_gen.c) | fmt 模块经 -E-extern 生成的 C 中间产物（22KB），_gen.c 产物示例 |

**build_tool 二进制构成**：
```
build_tool = build_tool_main.c（薄 main）
           + build_tool_libc_bridge.c（libc 桥）
           + build_runtime.c（C 执行后端）
           + build.x / build_runner.x / build_runtime.x（.x 驱动逻辑）
```

### 5.5 根目录 scripts/ 与 tools/

| 目录 | 路径 | 职责 |
|---|---|---|
| `scripts/`（根目录，18 个） | [scripts/](file:///home/shu/shux/scripts) | 迁移/工具脚本：`shux-deps-lock.sh`/`shux-deps-resolve.sh`/`shux-deps-verify.sh`（依赖锁定）、`shux-new.sh`（创建新模块骨架）、`shux-lang-edition.sh`（语言版本管理）、`migrate_*.pl`/`strip_*.pl`（语法迁移：array_slice、bare_strings、socketio、redundant_casts、usize_index 等） |
| `tools/`（18 个） | [tools/](file:///home/shu/shux/tools) | 一次性 Python/Shell 迁移脚本：`audit_import_migration.py`、`add_x_license_header.sh`/`add_x_license_header.sh`（License 头添加）、`c2x_socketio.py`/`c2x_socketio.py`（C→X/X 迁移）、`fix_*.py`（修复脚本） |
| `bin/` | [bin/](file:///home/shu/shux/bin) | `audit-std-extern-unsafe.ts`（TS 脚本：审计 std 模块 extern unsafe 声明） |

---

## 6. std 标准库 .o 构建机制

### 6.1 模块入口模式

- `mod.x` 是模块的**对外门面/导入入口**，`import <module>` 时定位到 `mod.x`
- **简单模块**（如 std/sort、std/simd、std/channel）：仅 mod.x，直接 `shux_compile_std_x.sh auto mod.x mod.o`
- **多文件模块**（如 std/crypto、std/net、std/io）：mod.x + 多个 `<feature>.x`，各自编译为 .o 再 `ld -r` 合并
- **C provider 模式**（如 std/string、std/process、std/path、std/runtime）：mod.x 仅作源码锚点，实际 .o 由 C provider (`src/asm/runtime_*_fast.c`) + `*_import_alias.c` 组成

### 6.2 std .o 合并模式汇总（Makefile 中所有 `ld -r`）

| 模块 | 路径 | 合并的 .o |
|---|---|---|
| 单 .x → 单 .o（无合并） | std/simd、std/sort 等 | — |
| 多 .x → ld -r 合并 | [std/crypto/crypto.o](file:///home/shu/shux/compiler/Makefile) (line 296-312) | core.o + aes_gcm.o + chacha20_poly1305.o + chacha20_aead.o + ed25519.o |
| 多 .x → ld -r 合并 | [std/net/net.o](file:///home/shu/shux/compiler/Makefile) (line 145-169) | alpn/udp/tcp/udp_batch/workers + 5 个 fast C .o + import_alias |
| .x + C provider + alias | [std/string/string.o](file:///home/shu/shux/compiler/Makefile) (line 88-92) | .x impl + runtime_string_fast.o + import_alias |
| .x + C provider + alias | [std/process/process.o](file:///home/shu/shux/compiler/Makefile) (line 81-84) | 同上模板 |
| .x + C provider + alias | [std/path/path.o](file:///home/shu/shux/compiler/Makefile) (line 96-99) | 同上模板 |
| .x + C provider + alias | [std/runtime/runtime.o](file:///home/shu/shux/compiler/Makefile) (line 139-142) | 同上模板 |
| .x + C provider + alias | [std/atomic/atomic.o](file:///home/shu/shux/compiler/Makefile) (line 338-343) | 同上模板 |
| .x + C alias | [std/ffi/ffi.o](file:///home/shu/shux/compiler/Makefile) (line 395-405) | ffi_core.o（来自 ffi.x -E）+ ffi_import_alias.o |
| .x + C alias | [std/base64/base64.o](file:///home/shu/shux/compiler/Makefile) (line 290-293) | 同 ffi 模板 |

### 6.3 端到端链路（修 codegen bug 时关注）

```
1. 源文件：std/<mod>/<feature>.x
2. Makefile 规则触发：make -C compiler std-objs 或单条 make ../std/crypto/crypto.o
3. 编译器选择：shux_asm → shux → shux-c（Makefile if-elif 链）
4. 调用 shux_compile_std_x.sh auto <src>.x <out>.o
   ├── auto 模式按 shux_asm → shux → shux-c 优先级
   └── asm 失败回退 shux-c -E + cc -c（macOS seed_mega 桩根因）
5. shux 内部走 codegen：
   ├── runtime.c:RUN_CC_FUNC（line 1097，正常模式）
   └── runtime.c:driver_run_x_emit_c（line 6247，-E 模式）
       → codegen_codegen_entry_module_to_c 把 .x 转 C
6. 多 .o 合并：ld -r -o crypto.o core.o aes_gcm.o ...（Makefile ld -r 规则）
7. 测试链接：测试 make -o /tmp/foo 时
   ├── runtime_link_abi.c:shux_invoke_cc（line 2940）调起 cc
   ├── shux_rel_o_path_from_argv0（line 3638）解析 std/*.o 路径
   └── invoke_cc_argv_push_existing（line 2514）按需追加（缺失用 asm_link_obj_skip_missing 跳过）
```

### 6.4 std 完整模块清单（64 个）

```
async atomic backtrace base64 bytes cache channel cli codec compress config
context crypto csv datetime db debug dynlib elf encoding env error ffi fmt
fs hash heap http io json log map math mem metrics net option path process
queue random regex result runtime schema security set simd socketio sort
string sync sys tar task test thread time trace unicode url uuid vec websocket
```

> 每个模块用 `mod.x` 作对外门面；`std/标准库api命名规范.md` 为 API 命名规范文档。

---

## 7. 测试体系

### 7.1 全量回归 [tests/run-all.sh](file:///home/shu/shux/tests/run-all.sh)

> tests/ 目录下共 **884** 个 `run-*.sh` 脚本（含子测试/专项测试）；run-all.sh 串联其中 **~109** 个核心脚本。

整体流程：
1. 顶部编译器选择（line 1-77）：
   - 设了 `SHUX`：B-strict 模式 export `SHUX_LINK_SHUX=$SHUX`；否则跑 `make bootstrap-driver-seed` + `SHUX_LEGACY_C_FRONTEND=1 make -B shux-c`，设 `SHUX_LINK_SHUX=./compiler/shux-c`
   - 未设 `SHUX`：`make all` + `SHUX_LEGACY_C_FRONTEND=1 make -B shux-c`，最终 `export SHUX=./compiler/shux-c`（C 流水线默认）
2. `run_required run-no-legacy-shux-gate.sh`（line 215）— CI 必过门禁
3. 依次 `run` ~109 个 `run-*.sh`（line 216-342）：词法/类型/hello → 语言特性 → std 库 → asm disasm（仅 x86_64，line 295-321）
4. CI 模式下统计失败数，末尾 exit 1 if any failed（line 344-351）

关键环境变量：

| 变量 | 语义 |
|---|---|
| `SHUX` | 编译器路径（如 ./compiler/shux-c、./compiler/shux） |
| `SHUX_LINK_SHUX` | 链接用编译器（B-strict 模式为 ./compiler/shux-c） |
| `SHUX_RUN_ALL_BOOTSTRAP_SHUX=1` | 标记当前 shux 是 bootstrap seed；子脚本 make 走 bootstrap-driver-seed |
| `SHUX_BSTRICT_RUN_ALL=1` | B-strict 模式（shux_asm 已构建）；触发 run_all_l5_whitelist_case 门禁 |
| `SHUX_SKIP_SUBSCRIPT_MAKE=1` | 阻止子脚本各自 make（避免长回归反复链接 shux 竞态） |
| `RUN_ALL_USE_C=1` | 默认 C 流水线（无 SHUX 时设） |
| `RUN_ALL_PORTABLE=1` | 跳过 asm/自举专测（全平台可移植子集） |
| `GITHUB_ACTIONS` / `CI` | 触发 CI 行为（失败累计不立即 exit；run-asm 跳过；非白名单 B-strict 失败仅 SKIP） |

### 7.2 B-strict 严格门禁 [tests/run-all-bstrict.sh](file:///home/shu/shux/tests/run-all-bstrict.sh)

与 run-all.sh 差异：
1. 前置 `make -C compiler bootstrap-driver-bstrict` 构 shux_asm（line 27-29）
2. 设 `SHUX_BSTRICT_RUN_ALL=1` + `SHUX_LINK_SHUX=./compiler/shux-c`（line 31-40）
3. 用固定脚本列表 `BSTRICT_SCRIPTS`（line 94-218，约 120 项，与 L5 白名单核心项对齐）
4. W3 best-effort 模式（line 314-355）：`SHUX_W3_BSTRICT_BEST_EFFORT=1` 时单脚本失败仅 WARN + retry 3 次 + per-script timeout
5. 跨脚本重置：每次脚本前 `cp -f shux_asm2 shux`（line 318-323）
6. Darwin 冷却：`sleep` 在 run-types-gate.sh 后强制 5s（line 242-249），避免 OOM Killed:9

### 7.3 专项测试覆盖点

- [tests/run-typeck.sh](file:///home/shu/shux/tests/run-typeck.sh) — typeck 正负例（line 65-81 负例：type_mismatch_assign.x、if_condition_not_bool.x、undefined_name.x、return_implicit.x、ternary_*、u64_to_usize_needs_as.x、struct_repr_compatible_fail.x、result_try_bad.x、import_const_bare_fail.x；line 169-172 正例：contextual_typing_p0/p1.x、postfix_call_index.x、range_for.x、result_try.x、struct_repr_compatible.x、type_alias.x）
- [tests/run-check.sh](file:///home/shu/shux/tests/run-check.sh) — `shux check` 子命令（合法静默；非法打印 path:line:col - error:）；包含 run-comment-prefix.sh + run-fmt-wrap.sh + cwd check + return-value + stdlib-import + typeck/return_operand_type_mismatch 必报错 + run-types-gate.sh
- [tests/run-hello.sh](file:///home/shu/shux/tests/run-hello.sh) — 编译 examples/hello.x → 运行 → grep "Hello World"；MSYS2/ARM64 优先 shux-c；非 TTY stdout 重定向会挂起，须 tee|cat Drain

### 7.4 L5 白名单（[run-all.sh:93-100](file:///home/shu/shux/tests/run-all.sh#L93-L100)）

- 作用：判定哪些测试脚本在 B-strict 模式下**必须用 shux_asm 跑**且**失败必须 fail-fast**；非白名单脚本在 B-strict 模式下走 shux-c，失败仅 SKIP
- 列表（约 100 项）：
  - 核心语言特性 + std 库：lexer/typeck/check/hello/io/http/tar/json/csv/net/process/set/queue/vec/heap/fs/path/map/error/compress/thread/fmt/fmt-std/debug/io-driver/multi-file-generic/env/crypto/log/stdtest/channel/backtrace/hash/math/sort/unicode/dynlib/random/runtime/abi-layout/ub
  - safe gate：safe-leak-nightly/signed-overflow/lexer-bounds/layout-overflow/link-hardening/std-mem-safe/lang-unsafe/scope-borrow/type-borrow-conflict/i64-ctfe/safe-unsafe-audit
  - asm 微测：asm-binop-var/asm-assign-index-lit 等约 18 项
- 文档：[tests/docs/run-all-l5-whitelist.md](file:///home/shu/shux/tests/docs/run-all-l5-whitelist.md)

---

## 8. CI / GitHub Actions

[.github/workflows/](file:///home/shu/shux/.github/workflows/) 下 4 个 workflow：

### 8.1 [ci.yml](file:///home/shu/shux/.github/workflows/ci.yml)

- `linux` job（line 17-70）：matrix [ubuntu-22.04, ubuntu-latest]，跑 make -C compiler OPT=1 all + tests/run-ci-full-suite.sh
- `linux-asm-smoke` job（line 72-101）：make bootstrap-driver-seed + SHUX_CI_FORCE_ASM=1 ./tests/run-asm.sh + run_shux_asm_smoke.sh
- `linux-arm64` job（line 103-143）：ubuntu-24.04-arm，full suite
- `mac` job（line 145-189）：matrix [macos-14, macos-latest]，full suite
- `windows` job（line 191-245）：MSYS2 + make all CC=gcc + run-bootstrap-bstrict-windows-gate.sh + full suite
- `linux-option-asan` job（line 247-272）：ASan 复现 run-option
- `docker-distro` job（line 274-306）：matrix [alpine:3.23, debian:bookworm-slim]，容器内 full suite
- **目前 on: 块只保留 workflow_dispatch，push/PR 触发已注释掉**（bootstrap-gold 调试中）

### 8.2 [ci-nightly.yml](file:///home/shu/shux/.github/workflows/ci-nightly.yml)

夜跑（cron 已注释，仅 workflow_dispatch）：
- `nightly-linux`：full suite + SAFE-005 leak（ASAN）+ SAFE-006 race（TSAN）+ ENG-007 security audit + PERF-169 weekly perf baseline
- `nightly-macos` / `nightly-windows`：full suite

### 8.3 [selfhost-stage2.yml](file:///home/shu/shux/.github/workflows/selfhost-stage2.yml)

- `stage2` job：跑 [compiler/verify-selfhost-stage2.sh](file:///home/shu/shux/compiler/verify-selfhost-stage2.sh)（shux-x -x -E 生成 _gen2.c 链 shux-x2，与 shux-x 行为对比）
- `stage2-bstrict` job：跑 verify-selfhost-stage2-bstrict.sh（M5：B-strict 两遍 build_shux_asm，shux_asm → shux_asm2）

### 8.4 [bootstrap-seeds-capture.yml](file:///home/shu/shux/.github/workflows/bootstrap-seeds-capture.yml)

多平台冷启动种子 capture + artifact 上传（手动 / 每周 schedule，目前 schedule 已注释）：
- jobs：capture-linux-amd64、capture-linux-arm64、capture-macos、capture-alpine-musl、capture-freebsd-amd64、freebsd-bridge
- 每个 capture job 跑 [compiler/scripts/capture_bootstrap_seeds.sh](file:///home/shu/shux/compiler/scripts/capture_bootstrap_seeds.sh) + scripts/preflight_g06_coldstart.sh
- 产出 `seeds/bootstrap_shuxc.<os>.<arch>` + `seeds/asm_backend_partial.<os>.<arch>.o` 上传 artifact（90 天保留）

### 8.5 CI 环境变量对 run-all.sh 的影响

- `CI=1`：
  - run-all.sh line 155-161：run-asm*.sh 在 CI 上 SKIP（除非 SHUX_CI_FORCE_ASM=1）
  - run-all.sh line 170-200：CI 模式下失败累计 RUN_FAILED_COUNT，单脚本失败不立即 exit
  - runtime_link_abi.c line 2503-2507：invoke_cc_skip_native_tuning() 在 CI 或 SHUX_CI_DOCKER 或 SHUX_NO_MARCH_NATIVE 设时返回 1，跳过 -march=native
- `GITHUB_ACTIONS`：与 CI 同等处理
- `SHUX_CI_DOCKER=1`：Docker job 设置，触发 invoke_cc_skip_native_tuning + 识别为 Docker 环境
- `SHUX_CI_FULL_SUITE=1`：Docker job 设置，触发 full suite 模式
- `SHUX_CC_EXTRA="-std=gnu11"`：Docker job 设置，传给 make 影响编译标准

---

## 9. 修 codegen bug 的关键关注点

### 9.1 调试入口

- **-E 模式调试**：直接 `./compiler/shux-c -E -L .. std/crypto/aes_gcm.x` 把生成的 C 写到 stdout，对比预期
- **-E -extern 模式**：导出 extern 声明，用于排查桥接层符号缺失（见 §1.1）
- **链接 argv 构造**：[runtime_link_abi.c:shux_invoke_cc](file:///home/shu/shux/compiler/src/runtime_link_abi.c) (line 2940) 和 [invoke_cc_argv_push_existing](file:///home/shu/shux/compiler/src/runtime_link_abi.c) (line 2514) — 若 .o 未正确生成或路径解析失败，会在此暴露为 undefined symbol
- **路径解析根因注释**：[runtime_link_abi.c:3639-3644](file:///home/shu/shux/compiler/src/runtime_link_abi.c#L3639-L3644) 说明为何返回堆分配内存（避免 30+ 次调用覆盖同一静态缓冲导致 crypto_o 指向 test.o）

### 9.2 codegen 入口

- **C 后端**：`runtime.c:RUN_CC_FUNC`（line 1097）→ `codegen_codegen_entry_module_to_c`（extern 声明 line 208）
- **asm 后端**：`runtime.c:driver_run_asm_backend`（line 3238）→ `pipeline.x:run_x_pipeline_codegen_entry` → `asm/backend.x:asm_codegen_ast`
- **-E 库模块**：`runtime.c:driver_run_x_emit_c`（line 6247）→ `codegen_library_module_to_c`（无 main_func 时走此路径，必须 dce_ctx_arg=NULL）

### 9.3 关键不变量

1. **库模块 -E 必须禁用 DCE**：`dce_ctx_arg = NULL` 当 `!mod->main_func || !mod->main_func->body`
   - n_all>0 分支：runtime.c:1910
   - n_all==0 分支：runtime.c:2155（本轮修复）
2. **shux_rel_o_path_from_argv0 必须返回堆分配内存**：连续 30+ 次调用，静态缓冲会让所有指针指向同一槽
3. **asm_link_obj_skip_missing 过滤**：仅当 path 指向已存在且非空（st.st_size > 0）常规文件时返回 path
4. **Makefile shux-c 不支持 -backend 参数**：Makefile line 183、201、397 用 `shux-c -backend c` 是 bug（待修）
5. **main_x.c 用 _exit 而非 return**：X 自举构建中 atexit/global-dtor 会崩溃，必须 _exit 绕过

### 9.4 桥接层排障（新增）

- **C 路径正常但 .x 路径异常**：先查 `x_bridge.c` / `x_seed_bridge.c` 是否正确桥接了对应符号
- **undefined symbol 但 .o 存在**：查 `x_stubs.c` / `x_stubs.c` 是否提供了空桩（-1 返回值可能表现为运行时错误）
- **Windows 链接失败**：查 `win32_pipeline_stubs.c` 是否覆盖了缺失符号（仅 _WIN32 编译）
- **build_tool 链接失败**：查 `build_tool_libc_bridge.c`（Darwin 上 .x extern 与 stdlib 类型冲突）

### 9.5 当前已知失败点（与思维导图对应）

| 模块 | 错误 | 推测根因 | 对应架构位置 |
|---|---|---|---|
| context.o | `&((cast)bytes[0])` rvalue 取地址 | codegen 取地址运算符 emit 顺序错 | §3.5 codegen.c |
| hash.o | `uint64_t ← uint8_t*` int-conversion | codegen 类型推导丢指针 | §3.5 codegen.c |
| regex.o | `uint8_t* ← int32_t` 双向 int-conversion | 同 hash.o 同源 | §3.5 codegen.c |
| net.o | `udp_ERR_EAGAIN` 重定义 | codegen 跨平台常量 emit 重复 | §3.5 codegen.c |
| trace.o | `*pos` requires unsafe block | typeck 门禁：函数体缺 unsafe 标记 | §3.4 typeck.c |
| test.o | `get_expr_type unhandled kind 4` | typeck AST kind 4 未处理 | §3.4 typeck.c |
| ffi.o | 链接错误（待查） | 可能 -backend c 参数问题 | §5.2 Makefile / §6.2 ffi.o |

---

## 10. 项目文档与辅助资源

### 10.1 analysis/ — 架构分析与阶段文档（566 个）

[analysis/](file:///home/shu/shux/analysis) 是项目文件数第二多的目录，存放开发过程中的架构分析、阶段总结、模块分析文档：

| 分类前缀 | 数量 | 内容 |
|---|---|---|
| `phase*` | 181 | 阶段分析/总结（phase3、phase2 等） |
| `std*` | 146 | std 标准库模块分析 |
| `boot*` | 23 | 自举分析（boot-015 ~ boot-028、boot-crossplatform 等） |
| `comp*` | 21 | 编译器分析（codegen 回归、增量编译等） |
| `core*` | 17 | core 核心库分析 |
| `doc*` | 16 | 架构文档（doc-selfhost-architecture-v1 等） |
| `perf*` | 15 | 性能分析 |
| `lang*` | 11 | 语言特性分析 |
| `tool*` | 9 | 工具分析 |
| `safe*` | 6 | 安全分析 |
| 其他 | ~40 | exc/type/tst/stbl/obs/zc/自举 等 |

> 修 bug 时可搜索 `analysis/` 中的相关模块文档，常有根因分析和修复记录。

### 10.2 examples/ — 示例程序

[examples/](file:///home/shu/shux/examples) — 示例 .x 程序，便于上手与回归测试：

- `hello.x` — Hello World（run-hello.sh 测试目标）
- `cookbook/` — **59 个 .x 示例**，覆盖各模块用法：
  - async：`async_channel_ping.x`、`async_drain_idle.x`、`async_net_fs.x` 等
  - std 库：`compress_gzip_roundtrip.x`、`csv_write_row.x`、`http_chunked_decode.x`、`db_kv_arrow.x` 等
  - core：`core_str_index.x`、`builtin_bitops.x` 等
  - 语言特性：`context_cancel_deadline.x`、`error_semantic_class.x`、`fmt_template_i32.x` 等
- `README.md` — 使用说明

### 10.3 runtime/ — 最小运行时（预留）

[runtime/](file:///home/shu/shux/runtime) — 仅含 `README.md`，描述最小运行时设计：
- 与 std 解耦的极薄一层，用于启动、栈、panic、backtrace
- 嵌入式目标需 crt0、栈初始化
- Shux IO 桩已移至 std.io.core（`std/io/core.x`）

### 10.4 顶层散落文档

| 文件 | 内容 |
|---|---|
| [NEXT.md](file:///home/shu/shux/NEXT.md)（53KB） | **完全自举路线图**：阶段 G 清场 + F-no-libc 硬绿 + FFI 隔离；含 ✅/🟡/⬜/⏭ 状态标记 |
| [当前进度.md](file:///home/shu/shux/当前进度.md) | 当前进度 |
| [架构分析.md](file:///home/shu/shux/架构分析.md) | 架构分析 |
| [问题分析文档.md](file:///home/shu/shux/问题分析文档.md) | 问题分析 |
| `debug-*.md`（9 个） | 调试记录：debug-memory-spike.md、debug-shux-check-segv.md、debug-darwin-emit-oom.md、debug-lsp-cpu-spin.md、debug-regex-asm-crash.md、debug-result-try-typeck.md、debug-context-cg002.md、debug-hello-stage1-segv.md、debug-check-command-hang.md |
| [VERSION](file:///home/shu/shux/VERSION) | 版本号：`0.2.0` |
| [LICENSE](file:///home/shu/shux/LICENSE) | 许可证 |
| [NOTICE](file:///home/shu/shux/NOTICE) | 声明 |

### 10.5 编辑器集成

[editors/](file:///home/shu/shux/editors) — vim + vscode 编辑器集成：

- **vim/**：语法文件
- **vscode/**：完整 VS Code 扩展
  - `src/`（19 个 .ts）— LSP client、completion、hover、definition、references、formatting、folding、codelens、tasks 等
  - `grammars/` — `sx.tmLanguage.json` + `x.tmLanguage.json`（语法高亮）
  - `snippets/` — `sx.json` + `x.json`（代码片段）
  - `out/` — 编译产物
  - `vscode-shux-0.1.0.vsix` — 打包扩展
  - 依赖：vscode-languageclient、vscode-jsonrpc、vscode-languageserver-protocol

### 10.6 .dbg/ — 调试日志

[.dbg/](file:///home/shu/shux/.dbg) — 43 个调试日志/输出文件（asm-seed-full-*.{err,out,monitor.log,txt} 等），开发过程中产生的调试捕获，非架构组件但排查 asm seed 问题时可参考。

---

## 附录：与原版差异对照

| 修改项 | 原版 | 补全版 |
|---|---|---|
| asm 文件数 | 139 | **130**（arch 8 + platform 4 + 顶层 104 + 其他 14） |
| compiler/scripts | 54 | **55** |
| std 模块 | ~60 | **64**（新增完整清单 §6.4） |
| docs 文档 | 11 | **12** |
| tests/run-*.sh | "~100 个专项测试" | tests/ 下 **884** 个；run-all.sh 调用 **~109** 个 |
| analysis/ 目录 | ❌ 缺失 | ✅ 新增 §10.1 |
| examples/ 目录 | ❌ 缺失 | ✅ 新增 §10.2 |
| runtime/ 目录 | ❌ 缺失 | ✅ 新增 §10.3 |
| 根 Makefile | ❌ 缺失 | ✅ 新增 §5.1 |
| shux-build.sh | ❌ 缺失 | ✅ 新增 §5.4 |
| -E-extern 桥接模式 | ❌ 缺失 | ✅ 新增 §1.1 |
| x_bridge.c / x_seed_bridge.c | ❌ 缺失 | ✅ 新增 §3.13 |
| win32_pipeline_stubs.c | ❌ 缺失 | ✅ 新增 §3.13 |
| main_x.c vs main.c | ❌ 未区分 | ✅ §2 + §3.13 |
| 其他散落 .c 文件（~14 个） | ❌ 缺失 | ✅ 新增 §3.13 |
| 三层构建入口关系 | ❌ 缺失 | ✅ 新增 §5.0 |
| 顶层散落文档 | ❌ 缺失 | ✅ 新增 §10.4 |
| 编辑器集成详情 | 仅提"vim + vscode" | ✅ 新增 §10.5 |
| .dbg/ 目录 | ❌ 缺失 | ✅ 新增 §10.6 |
| build_tool 构成 | ❌ 缺失 | ✅ 新增 §5.4 |
| 桥接层排障 | ❌ 缺失 | ✅ 新增 §9.4 |
| core 12 模块 | ✅ 准确 | 保持 |
| WPO/DCE 子系统 | ✅ 详尽 | 保持 |
| CI 4 个 workflow | ✅ 准确 | 保持 |
