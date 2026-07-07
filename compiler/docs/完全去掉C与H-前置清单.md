# 完全去掉 C 和 H 文件 — 前置清单

本文档说明：**要到哪个程度**才能在整个编译器（含 LSP）中完全去掉手写 C 和 H 文件。按依赖顺序列出，便于排期。

---

## 一、当前还剩哪些 C/H

### 编译器主体（Makefile OBJS）

| 文件 | 作用 | 去掉条件 |
|------|------|----------|
| src/main.c | 入口 main() 转调 main_entry | 已有 main.x；用 SHUX_USE_X_DRIVER 时已走 driver，main.c 仅剩薄包装 |
| src/runtime.c | run_compiler_c、pipeline 桥接、-E 流程 | 逻辑逐步迁 runtime_driver + .x，剩极薄 C 或全迁 .x |
| src/preprocess.c | 预处理 | 有 preprocess.x 则生成 preprocess_gen.c 替代，链入时不再链 preprocess.o |
| src/lexer/lexer.c | 词法 | 有 lexer.x 且构建链 lexer_x.o 替代 lexer.o |
| src/ast/ast.c | AST 分配/释放等 | 有 ast.x 且构建链 ast_x.o 替代 ast.o |
| src/parser/parser.c | parse(lex, &mod) | 见下节「LSP 与 parser/typeck 双 API」 |
| src/typeck/typeck.c | typeck_module 等 | 同上 |
| src/codegen/codegen.c | 代码生成 | 有 codegen.x 且构建链 codegen_x.o 替代 |
| src/lsp/lsp_diag.c | LSP 诊断/definition/hover/文档缓冲/JSON | 见下节 |

### LSP 相关 H（生成 C 时仍需）

| 文件 | 作用 | 去掉条件 |
|------|------|----------|
| src/lsp/lsp_io_extern.h | std_io_* / std_heap_* 声明 + 符号映射 | 见下节「生成 C 自带 extern」 |
| src/lsp/lsp_gen_extern.h | typeck_* 与 lsp_io_* 映射 | 同上或 lsp 全 .x 后不再生成 C |

### 其他 C/H

- include/*.h、parser/parser.h、typeck/typeck.h、ast.h 等：实现全迁 .x 后，仅保留与系统/ABI 互操作必需的头文件（若有）。
- std/*.c：标准库实现，与「编译器本体」去 C 可分开；完全无 C 需 std 也 .x 或通过 FFI 调系统。

---

## 二、完全去掉 C/H 需要达到的程度

### 1. 生成 C 时自带 extern，不再依赖手写 .h（去掉 lsp_io_extern.h / lsp_gen_extern.h）

- **现状**：`-E-extern` 走 .x codegen，生成的 lsp_io_gen.c 里**没有**为 std_io_read、std_heap_alloc 等生成 `extern` 声明，编译时靠 `-include lsp_io_extern.h`。
- **需要**：在 codegen（.x 或 C）中，对「本模块引用但未定义的符号」在生成 C 时自动输出 `extern` 声明（与 C codegen 里对 lib_dep 生成 extern 的行为一致）。
- **可选**：导出名可控（如某模块导出 `std_heap_alloc` 无前缀），则不再需要 lsp_io_extern.h 里的 `#define std_heap_alloc typeck_std_heap_alloc`。

达到后：可删除 lsp_io_extern.h、lsp_gen_extern.h，或仅保留极少量与系统互操作的声明。

---

### 2. parser/typeck/ast 对 LSP 提供「可被 .x 或 C 调」的同一套能力（再去掉 lsp_diag.c）

- **现状**：  
  - **C API**：`parse(Lexer*, ASTModule**)`、`typeck_module(...)`、`ast_module_free`，供 **lsp_diag.c** 用。  
  - **.x API**：`parse_into(arena, module, source)` 等，供 **pipeline.x** 用。  
  两套 API，构建默认链 parser.o/typeck.o/ast.o，LSP 只用 C 那套。
- **需要**（二选一或组合）：
  - **方案 A**：在 **parser.x/typeck.x/ast.x** 里暴露与 C 兼容的入口（如 `parse(lex, &mod)` 的等价实现，或 C 可调用的薄包装），构建改为链 parser_x.o/typeck_x.o/ast_x.o，lsp_diag.c 仍可调用同一套声明（来自 .x 生成 C 的导出名或少量保留的 .h）。
  - **方案 B**：**lsp_diag 迁到 .x**（lsp_diag.x），直接调用现有 .x 的 parse_into / typeck 入口，使用 arena、module、slice 等 .x 数据结构；不再需要 `parse(Lexer*, ASTModule**)` 这套 C API。

达到后：可删除 lsp_diag.c（以及若采用方案 A，最终也可逐步删 parser.c/typeck.c/ast.c，仅保留 .x 实现）。

---

### 3. 构建默认只链 .x 产出的 .o，不再链编译器主体的 .c 产物

- **现状**：OBJS 含 main.o、runtime.o、preprocess.o、lexer.o、ast.o、parser.o、typeck.o、codegen.o、lsp_diag.o；bootstrap 也链 parser.o、typeck.o 等。
- **需要**：
  - 所有上述模块均有 .x 实现，且生成的 C（或 asm）能提供与当前 C 相同的符号或明确替代的入口。
  - Makefile / build.x 中默认使用 parser_x.o、typeck_x.o、ast_x.o、codegen_x.o、preprocess_x.o、lexer_x.o 等，**不再**链 parser.o、typeck.o、ast.o 等（或仅保留极薄 C 包装如 main.c 的 `int main() { return main_entry(...); }`）。

达到后：编译器主体可视为「无 C 实现」，仅剩可选极薄 C 包装或系统互操作。

---

### 4. runtime / main 的 C 仅剩「最小入口」（可选）

- **现状**：runtime.c 含 -E 流程、pipeline 桥接、run_compiler_c 等；main.c 含 main()。
- **需要**：  
  - 所有「怎么编、怎么链」的逻辑迁到 .x 或 build.x；  
  - runtime 仅保留：进程入口、与系统/ABI 相关的少量 C（若有）；  
  - main.c 可收成一行：`int main(int argc, char **argv) { return main_entry(argc, (void*)argv); }`，或由 build 工具生成。

达到后：C 仅用于「必须用 C 的边界」（入口、ABI、系统调用），不再承载业务逻辑。

---

### 5. 标准库（std）与 include（**必达**，完全自举终局）

- **现状**：std 下大量 .c（io、fs、heap、net 等）；include 下 ast.h、token.h 等。
- **需要**：  
  - **阶段 E 完成后**（编译器本体无 C）仍**不足以**宣称完全自举。  
  - **完全自举**（见 `NEXT.md` 阶段 F）：std/core 也需 `.x` 实现或通过 FFI 调系统；include 仅保留 ABI/FFI 需要的头文件（理想为零）。  
  - 中间态「编译器无 C、std 仍 .c」仅作过渡，**不是终局**。

---

## 三、按「程度」归纳

| 程度 | 可去掉的 C/H | 需满足的前置 |
|------|--------------|--------------|
| **仅 LSP 的 H** | lsp_io_extern.h、lsp_gen_extern.h | 1. 生成 C 时自动输出 extern；可选：导出名可控 |
| **LSP 的 C** | lsp_diag.c | 2. parser/typeck/ast 对 LSP 提供 .x 可用的 API（或 lsp_diag 迁 .x 用 parse_into 等） |
| **编译器主体 C** | parser.c、typeck.c、ast.c、codegen.c、lexer.c、ast.c、preprocess.c | 3. 构建默认链 .x 产物；2. 已满足（LSP 用 .x 或 C 兼容 API） |
| **入口/运行时 C** | main.c、runtime.c 绝大部分 | 4. 逻辑迁 .x/build.x，C 仅剩最小入口与 ABI |
| **全仓库无 C** | 含 std/*.c、include/*.h | 5. std 与 include 也迁 .x 或 FFI（**完全自举必达**，见 `NEXT.md` §9） |

---

## 四、建议顺序

1. **先做 1**：codegen 在 -E-extern 时对未定义符号自动生成 extern → 去掉 LSP 的 .h 依赖。  
2. **再做 2**：在 .x 中暴露 C 兼容的 parse/typeck 入口，或把 lsp_diag 迁到 .x 用 parse_into → 去掉 lsp_diag.c。  
3. **再做 3**：默认构建只链 .x 产物，不再链 parser.o/typeck.o 等 → 去掉编译器主体 .c。  
4. **再做 4**：runtime/main 收到最小入口与 ABI。  
5. **必做 5**（阶段 F）：std/core 清 C + 构建链禁止 `cc -c std` → **完全自举**终局。

达到 **1+2+3** 即可在**编译器本体（含 LSP）**中完全去掉手写 C 和 H 文件（仅保留与系统/ABI 必需的极薄 C 或头文件时，可视为「编译器无 C」）。  
达到 **1+2+3+4+5** 方可宣称 **完全自举**（全仓库无手写 C/H）。
