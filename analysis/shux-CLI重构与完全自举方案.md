# shux CLI 重构与完全自举实施方案

> 目标：`shux` 命令对标 Zig CLI —— `shux run`、`shux test`、`shux build (--exe|--lib|--obj)`，同时实现编译器核心逻辑 100% .sx 源码自举。

---

## 一、现状全景

### 1.1 当前 CLI

```
shux [ -L <lib> ] [ -target <triple> ] [ -D <sym> ] [ -O 0|1|2|3|s ] [ -flto ] <file.sx> [ -o <out> ]
shux -E <file.sx>                          # 仅生成 C 到 stdout
shux -E-extern <file.sx>                   # 生成瘦 C（import 用 extern）
shux -sx -E <file.sx>                      # 用 .sx pipeline 生成 C
shux --lsp                                 # LSP 模式
```

**问题**：扁平的参数风格，没有子命令，不像现代编译器工具链。

### 1.2 编译器源码分布

| 模块 | C 源码 | .sx 源码 | 说明 |
|------|--------|----------|------|
| **入口** | main.c (13行) | main.sx (528行) | main.c 仅调 main_entry |
| **驱动** | runtime.c (4898行) | main.sx | 驱动+invoke_cc+resolve+读文件全在 C |
| **词法** | lexer.c (679行) | lexer.sx (1422行) | .sx 版更全但 C 版仍在用 |
| **AST** | ast.c (413行) | ast.sx (462行) | 结构体定义 + 分配 |
| **解析** | parser.c (4154行) | parser.sx (6561行) | .sx 版已写但未独立链入 |
| **类型检查** | typeck.c (2629行) | typeck.sx (877行) | C 版仍有大量逻辑 |
| **代码生成** | codegen.c (6308行) | codegen.sx (2757行) | 表达式/控制流生成在 C |
| **汇编后端** | — | asm/*.sx (~4.5k行) | 仅 Linux x86_64 可用 |
| **预处理** | preprocess.c (226行) | preprocess.sx (299行) | 两者都存在 |

**关键数据**：C 合计 ~19k行，.sx 合计 ~22k行。业务逻辑约 60% 在 .sx，40% 仍在 C。

### 1.3 当前自举路径

```
C 编译器 cc
    ↓ 编译 main.c + runtime.c + parser.c + typeck.c + codegen.c + ...
shux / shux-c（C 编译器二进制）
    ↓ -E 编译 build.sx → build_gen.c + build_runtime.c → cc
build_tool（构建工具）
    ↓ 执行构建步骤
    ↓ -E 编译 parser.sx → parser_gen.c 等
    ↓ cc 编译生成 C + link
shux（新编译器）
```

**自举验证**：`./build_tool verify` → bootstrap-self + check-7.2 全通过 ✅

---

## 二、目标 CLI 设计

对标 Zig：

```
shux run <file.sx> [args...]         编译并运行 .sx 源文件
shux test [file.sx]                  编译并运行测试（自动发现 test 函数）
shux build --exe <file.sx>           编译为可执行文件
shux build --lib <file.sx>           编译为静态库 (.a / .lib)
shux build --obj <file.sx>           编译为对象文件 (.o / .obj)
shux build --dy lib <file.sx>        编译为动态库 (.so / .dylib / .dll)
shux build-obj <file.sx>             编译为 .o（别名）
shux build-exe <file.sx>             编译为可执行（别名）
shux build-lib <file.sx>             编译为静态库（别名）
shux translate-c <file.c>            C → .sx 翻译（远期）
shux fmt <file.sx>                   格式化源码
shux lsp                             启动 LSP 服务
shux version                         打印版本
```

### 2.1 第一阶段（当前可实现）

```
shux run <file.sx>       → 等价于 shux <file.sx> -o /tmp/shux_run_xxx && /tmp/shux_run_xxx
shux build <file.sx>     → 等价于 shux <file.sx> -o a.out
shux build-obj <file.sx> → 等价于 shux -E <file.sx> > file.c && cc -c file.c -o file.o
shux test                → 等价于 ./build_tool test
shux version             → 打印版本信息
```

### 2.2 第二阶段（迁移驱动到 .sx 后）

```
shux run / test / build 全部由 .sx 驱动实现，不依赖 C 的 run_compiler_c
```

---

## 三、完全自举路线图（分 7 步）

### 步骤 1：CLI 子命令化 ✅ 可立即开始

**内容**：在 main.sx 中增加子命令解析，`entry()` 函数识别 `run`/`build`/`test`/`version` 等。

**改动文件**：
- `compiler/src/main.sx`：增加子命令解析函数
- 各子命令转调现有 `run_compiler_c_impl` 或 build_tool

**验收**：`./shux run examples/hello.sx` 输出 "Hello World"

### 步骤 2：驱动逻辑迁 .sx（核心）

**内容**：把 runtime.c 中的以下逻辑迁到 .sx：

| C 函数 | 行数 | .sx 替代方式 |
|--------|------|-------------|
| `run_compiler_c` (CLI解析+主流程) | ~180行 | main.sx 新 driver.sx |
| `invoke_cc` (调 cc 链接) | ~280行 | std.process spawn |
| `read_file` | ~30行 | std.fs.read |
| `resolve_import_file_path_multi` | ~60行 | .sx path/fs |
| `load_one_import` + `resolve_and_load_imports` | ~200行 | .sx 递归 |
| `get_*_o_path` 等 std 路径 | ~100行 | .sx path/fs |
| pipeline 原语（resolve/read/load） | ~100行 | 驱动在 .sx，ctx 在 .sx |

**合计可迁出**：约 950+ 行 C → .sx

**验收**：`./shux run examples/hello.sx` 仍正常，且不再依赖 C 的 run_compiler_c

### 步骤 3：parser 独立链入

**内容**：用 .sx 版 parser（parser.sx 6561行）替代 C 版（parser.c 4154行）。

**做法**：
1. 生成 `parser_gen.c`（瘦模式，无 main/ast 内联）
2. 链接时用 `parser_sx.o` 替代 `parser.o`
3. 修复符号冲突（`parser_*` vs `parse`、`parser_parse_into` 等）

**关键**：需要 arm64 ABI 修复——parser.sx 中 LexerResult/OneFuncResult 全部改用 _into API（见 analysis/自举-生成C与ABI问题-重构分析.md 方案A）。

**验收**：`./shux -E parser.sx > parser_gen.c` 生成的 C 不含结构体值返回

### 步骤 4：typeck 独立链入

**内容**：typeck.sx (877行) 替代 typeck.c (2629行)。

**注意**：当前 typeck.sx 仍通过 extern 调用 C 的 typeck_module，需补全 .sx 内逻辑。

**验收**：全量测试套件通过

### 步骤 5：codegen 独立链入（最大难点）

**内容**：codegen.sx (2757行) 替代 codegen.c (6308行)。

codegen.c 中的核心函数：
- `codegen_module_to_c` — 整个模块 → C
- `codegen_emit_func` — 单个函数 → C  
- `codegen_emit_expr` — 表达式 → C（最复杂，~3000行）
- `codegen_library_module_to_c` — 库模块 → C
- DCE（死代码消除）：`codegen_compute_used`、`codegen_compute_used_types`

当前 codegen.sx 通过大量 extern 调用 codegen.c：
- `codegen_sx_import_path_to_c_prefix`
- `codegen_sx_path_is_std_io_core`
- `driver_get_current_dep_prefix_for_codegen`
- `driver_force_param_*`
- 等 ~20 个 extern

**做法**：逐步把 extern → .sx 内部实现或 ctx 字段。

**验收**：link 时不依赖 codegen.c，全量测试通过

### 步骤 6：ARM64 ABI 修复

**根因**：parser.sx 中的 `LexerResult`、`OneFuncResult` 等结构体按值返回/赋值在 ARM64 上不可靠。

**方案 A（推荐）**：.sx 源侧改用 _into API
- `r = lexer_next(lex, source)` → `lexer_next_into(&r, lex, source)`
- `return OneFuncResult { ... }` → void 函数 + _into(out, ...)

**方案 B**：codegen 层自动转 _into（改动大）

**方案 C**：用 asm 后端直接出机器码，跳过 C（仅 Linux x86_64 可用）

当前采取务实策略：ARM64 走 C 编译路径，x86_64 走 SX pipeline。

### 步骤 7：删除 C 源文件

当 parser/typeck/codegen/driver 全部由 .sx 实现后：
- 可删除：parser.c、typeck.c、codegen.c
- 可大幅缩减：runtime.c（仅保留极薄 C 原语）
- 保留：main.c（1行调 main_entry）、build_runtime.c（build_tool 运行时）

---

## 四、立即可执行的任务

### 4.1 shux CLI 子命令（今天可完成）

修改 `compiler/src/main.sx`：
1. `entry()` 中检测 `argv[1]`
2. `run` → 编译到临时文件 + exec
3. `build` → 编译到 a.out
4. `build-obj` → -E + cc -c
5. `test` → 调 build_tool test
6. `version` → 打印版本

### 4.2 驱动迁 .sx（本周）

新建 `compiler/src/driver.sx`：
- 实现 CLI 解析 + 编译主流程
- 用 std.fs/std.process 替代 C 的 read_file/invoke_cc
- ctx 全在 .sx 分配

---

## 五、文件清单

| 文件 | 动作 | 说明 |
|------|------|------|
| `compiler/src/main.sx` | **修改** | 增加子命令解析 |
| `compiler/src/driver.sx` | **新建** | .sx 版驱动编排 |
| `compiler/src/build_runtime.c` | 不变 | build_tool 运行时 |
| `compiler/src/runtime.c` | **逐步缩减** | 迁移到 .sx 后删函数 |
| `compiler/src/parser/parser.c` | **逐步删除** | parser.sx 替代后 |
| `compiler/src/typeck/typeck.c` | **逐步删除** | typeck.sx 完全替代后 |
| `compiler/src/codegen/codegen.c` | **逐步删除** | codegen.sx 完全替代后 |
| `compiler/src/main.c` | **保留** | main() → main_entry (1行) |
| `build.sx` | **修改** | 增加步骤配置 |
