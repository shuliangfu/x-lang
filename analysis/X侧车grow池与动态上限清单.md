# X 侧车 grow 池与动态上限清单

本文档说明编译器 X 自举路径上 **「动态上限」** 的实现方式（**侧车 grow 池**），并列出：**已完成**、**不宜池化**、**可选 C 镜像同步** 三类项，供逐项修改与验收。

**关联实现**：`compiler/ast_pool.c`（grow 向量 + sidecar 键）、`compiler/pipeline_glue.c`（`#include "ast_pool.c"` 参与链接）、`compiler/src/ast/ast.x`（瘦 struct + `pipeline_*` extern）。

**验收**：

```bash
cd compiler && make bootstrap-pipeline && make shux-sx && sh ./verify-selfhost-stage2.sh
```

**最后验收**：2026-05-20 — `verify-selfhost-stage2.sh` 通过（shux-sx / shux-sx2 exit 42）。

---

## 一、术语：「动态上限」与「池化」

| 说法 | 含义 |
|------|------|
| **动态上限** | 不再写死「最多 16 个形参 / 256 个函数 / 96 条 stmt」这类**个数**顶；需要多少 grow 多少。 |
| **侧车 grow 池（本文简称池化）** | 把原先嵌在 struct 里的**定长数组**挪到 C 侧 `GrowVec`，用 **父对象指针作键**（如 `PipelineDepCtx*`、`DriverXEmitState*`）挂接 sidecar；X 通过 `pipeline_*` / `driver_emit_*` / `asm_qual_sym_*` 读写。 |
| **语义长度上限** | 标识符最长 64 字节、形参名 32 字节、单段路径 scratch 256 字节等——属于 **ABI/语言设计**，不是「列表个数」问题，一般**不池化**。 |

二者关系：**动态上限 = 目标；侧车 grow 池 = 在本仓库里的主要实现手段。**

---

## 二、性能影响（是否值得全改）

| 场景 | 影响 |
|------|------|
| 典型小模块（形参/import/函数数量正常） | 多一次 sidecar 查找 + 偶尔 `realloc`，相对 parse/typeck/codegen **可忽略**。 |
| 超大模块（函数 >256、import 层很深） | 去硬顶是**正确性**收益；迭代次数增加，但 per-element 无额外间接成本。 |
| **AsmFuncCtx 局部槽**（已池化为 `asm_ctx_local_*`） | emit 热路径多一次 sidecar 查表；后续可换函数级 bump，当前已去 24 顶。 |
| 标识符 u8[64] 等 | 池化几乎无收益，还会让每次读名更慢 → **不建议**。 |

结论：**列表个数类上限** 应去顶或池化；**字符串/指令行缓冲** 保持定长即可。

---

## 三、已完成（X 自举主链路）✅

### 3.1 AST / Module 持久数据（ast_pool + ast.x）

| ID | 原限制 | 现实现 | 主要 API |
|----|--------|--------|----------|
| P-DONE-01 ✅ | Module 内嵌 func/import/struct 等固定数组 | ModuleSidecar grow 池 | `pipeline_module_func_*`、`pipeline_module_import_*`、`pipeline_module_struct_layout_*` |
| P-DONE-02 ✅ | ASTArena 内嵌 types/exprs/blocks/funcs | ArenaSidecar grow 池 | `pipeline_arena_*_alloc`、`*_cap()` → `AST_POOL_NO_LIMIT` |
| P-DONE-03 ✅ | Block 内 const/let/if/stmt_order 等 | Block 侧车池 | `pipeline_block_append_*`、`ast_block_num_*` |
| P-DONE-04 ✅ | Expr call/match/struct_lit/array_lit 附属 | Expr 侧车池 | `pipeline_expr_append_call_arg`、`pipeline_expr_match_arm_*`、`pipeline_expr_struct_lit_*` |
| P-DONE-05 ✅ | Func 形参内嵌 Param[16] | func param grow 池 | `pipeline_module_func_param_*`、`pipeline_arena_func_param_write` |
| P-DONE-06 ✅ | StructLayout 字段 ≤64 | field grow 池 | `pipeline_module_struct_layout_set_field`、`*_num_fields` |

### 3.2 Parser / PipelineDepCtx / Driver scratch

| ID | 原限制 | 现实现 | 主要文件 |
|----|--------|--------|----------|
| P-DONE-07 ✅ | OneFuncResult 内 param_names/type_refs/call_args | OneFuncSidecar | `parser.x` + `pipeline_onefunc_*` |
| P-DONE-08 ✅ | ExternParseResult 同上 | 共用 OneFuncSidecar | `parser.x` |
| P-DONE-09 ✅ | `current_func_empty_param_indices[16]` | DepCtxSidecar | `codegen.x` + `pipeline_dep_ctx_empty_param_*` |
| P-DONE-10 ✅ | DepCtx lib_root / dep 槽 | DepCtxSidecar | `pipeline_dep_ctx_*`、`ast_pipeline_ctx_append_lib_root` |
| P-DONE-11 ✅ | `DriverXEmitState.lib_root_bufs[16]` | DriverEmitSidecar | `main.x` + `driver_emit_*` |
| P-DONE-12 ✅ | PipelineDepCtx 布局与 LSP sizeof | 去掉 `i32[16]` | `lsp_diag_pipeline_sizes.c` |

### 3.3 下游 pass 已去硬顶 / 池化

| ID | 原限制 | 现实现 | 文件 |
|----|--------|--------|------|
| P-DONE-13 ✅ | typeck expr_stmt 扫描 `idx < 32` | 仅 `idx < nes` | `typeck.x` |
| P-DONE-14 ✅ | backend stmt_order `i < 96` | 仅 `i < ast_block_num_stmt_order(...)` | `backend.x` |
| P-DONE-15 ✅ | backend/typeck import 限定符号层 `[16][64]` | 全局 scratch 池 | `asm_qual_sym_layer_*`（`ast_pool.c` + `backend.x` / `typeck.x`） |
| P-DONE-16 ✅ | preprocess `#if` 嵌套 `stack[32]` | grow 池 | `preprocess_if_stack_*`（`ast_pool.c` + `preprocess.x`） |
| P-DONE-17 ✅ | `AsmFuncCtx.locals[24]` | sidecar 池 | `asm_ctx_local_*`（`ast_pool.c` + `backend.x`） |
| P-DONE-18 ✅ | loop 标签栈 4 层 | 8 层（512 字节栈） | `backend.x` |

### 3.4 阶段 A — 去循环硬顶 ✅

| ID | 文件 | 改法 | 状态 |
|----|------|------|------|
| P-A01 ✅ | `codegen.x` | 去掉 `&& fi < 256` | 完成 |
| P-A02 ✅ | `backend.x` | 去掉 `&& i < 256` | 完成 |
| P-A03 ✅ | `asm/arch/arm64.x` | 去掉 `&& i < 256` | 完成 |
| P-A04 ✅ | `typeck.x` | import 层 → `asm_qual_sym_layer_*` | 完成 |
| P-A05 ✅ | `backend.x` | `imp_slot < module.num_imports` | 完成 |
| P-A06 ✅ | `typeck.x` | struct_lit / import select 去 8 顶 | 完成 |
| P-A07 ✅ | `codegen.x` | import select 去 `k < 8` | 完成 |

### 3.5 阶段 B — 新增 sidecar / scratch ✅

| ID | 文件 | 原限制 | 现实现 | 状态 |
|----|------|--------|--------|------|
| P-B01 ✅ | `parser.x` | `arg_i < 64` | 仅 `arg_i < call_num_args` | 完成 |
| P-B02 ✅ | `parser.x` | `ii < 32` callee 拷贝 | 仅 `ii < call_callee_len` | 完成 |
| P-B03 ✅ | `preprocess.x` | `#if depth >= 32` | `preprocess_if_stack_*` grow 池 | 完成 |
| P-B04 ✅ | `backend.x` | `locals[24]` | `asm_ctx_local_*` sidecar | 完成 |
| P-B05 ✅ | `backend.x` | loop 栈 4 层 | 8 层 | 完成 |

**Stage2 自举**：`verify-selfhost-stage2.sh` 已通过（shux-sx / shux-sx2 exit 42）。

---

## 四、不宜池化（设计上限 / ABI / scratch）🚫

以下 `[N]` 是 **单条字符串、指令模板、路径缓冲、调用约定寄存器数**，不是「列表个数」；保持定长或常量即可。

| ID | 类别 | 典型位置 | 上限 | 原因 |
|----|------|----------|------|------|
| P-B06 🚫 | 调用约定 reg 临时 | `backend.x` / `x86_64.x` / `arm64.x` 中 `k < 8` | 8 | **ABI** 最大通用寄存器实参数；非 AST 列表 |
| — | 标识符/字段名 | `ast.x` Expr/Func/Type `name: u8[64]` | 64 | 语言与 C ABI 约定 |
| — | 形参名 | `Param.name: u8[32]` | 32 | 与 codegen `_pN`、C 声明一致 |
| — | goto/label | `Block.label/goto_target: u8[32]` | 32 | 标签名长度 |
| — | 路径 scratch | `main.x` path `[512]`、`-L` copy `[256]` | 512/256 | OS 路径惯例 |
| — | 源码/预处理缓冲 | `PipelineDepCtx.loaded/preprocess_buf` | 4MiB | 文件大小顶，非 grow 列表 |
| — | codegen 符号拼接 | `codegen.x` `buf: u8[96]` | 96 | 单符号 C 名 scratch |
| — | asm 指令行 | `x86_64.x` / `arm64.x` 等字面量 | 16–32 | 汇编文本模板 |
| — | Mach-O/ELF/COFF | `platform/*.x` 文件头字节数组 | 固定布局 | 对象文件格式 |
| — | typeck 反射 | `ensure_array_type_ref_named_elem(..., 256)` | 256 | 类型描述常量，非 ast 池 |
| — | LSP I/O | `lsp.x` line_buf `[256]` | 256 | 协议行缓冲 |

**parser.x 中大量 `while (i < 64)`**：多数是 **拷贝到 Expr 的 u8[64] 字段** 的边界，属于语义长度，不是「第 65 个 func」问题。

---

## 五、C 路径 / 镜像同步 ✅

X 自举与 C driver 镜像已对齐 **ast.x 瘦布局 + ast_pool.c sidecar**。

| ID | 文件 | 说明 | 状态 |
|----|------|------|------|
| P-C01 ✅ | `compiler/src/runtime.c` | `PipelineDepCtx` 瘦布局；`lib_root`/`dep` 改 `ast_pipeline_*` sidecar | 完成 |
| P-C02 ✅ | `compiler/include/ast.h`、`parser.c` | 形参/实参改 `realloc` grow，无 16 个数硬顶 | 完成 |
| P-C03 ✅ | `fix_slim_arena_gen_c.pl` | gen2 补 `preprocess_if_stack_*` / `asm_qual_sym_*` / `asm_ctx_local_*` / `driver_emit_*` extern | 完成 |

**原则**：以 **ast.x 瘦布局 + ast_pool.c** 为真源；C 镜像与 X 共用 sidecar API（`ast_pipeline_*` / grow 池）。

---

## 六、执行清单（归档）

```
批次 1（阶段 A）✅
  ✅ P-A01 ~ P-A03   去掉 func 遍历 256 顶
  ✅ P-A04           typeck import 层 → asm_qual_sym_*
  ✅ P-A05           imp_slot 与 num_imports 对齐
  ✅ P-A06 ~ P-A07   typeck/codegen import select、struct_lit 去 8 顶
  ✅ 验收 bootstrap-pipeline + shux-sx + verify-selfhost-stage2

批次 2（阶段 B）✅
  ✅ P-B01 ~ P-B02   parser 简化 call 路径
  ✅ P-B03           preprocess #if 深度 → preprocess_if_stack_*
  ✅ P-B04           AsmFuncCtx locals → asm_ctx_local_*
  ✅ P-B05           loop 栈 4→8 层
  🚫 P-B06           reg 临时 k<8（ABI，文档化，不改）
  ✅ 验收同上

批次 3（阶段 C）✅
  ✅ P-C01 ~ P-C03   runtime.c / ast.h+parser.c / perl 别名同步
  ✅ 验收 bootstrap-pipeline + shux-sx + verify-selfhost-stage2
```

---

## 七、ast_pool 侧车一览（便于查 API）

| Sidecar 键 | 用途 | 代表 API |
|------------|------|----------|
| `ASTArena*` | types/exprs/blocks/funcs + expr 附属 | `pipeline_arena_*`、`pipeline_expr_*` |
| `Module*` | func 槽、import、struct、enum、top_level | `pipeline_module_*` |
| `OneFuncResult*` / 指针 | parser 单函数 scratch | `pipeline_onefunc_*` |
| `PipelineDepCtx*` | dep、lib_root、empty_param | `pipeline_dep_ctx_*`、`pipeline_ctx_*` |
| `DriverXEmitState*`（`*u8`） | `-L` 库根 | `driver_emit_*` |
| （无键，单线程 scratch） | import 限定符号 field 层 | `asm_qual_sym_layer_*` |
| （无键，单线程 scratch） | preprocess `#if` 嵌套栈 | `preprocess_if_stack_*` |
| `AsmFuncCtx*`（`*u8` 键） | emit 局部变量槽 | `asm_ctx_local_*` |

`*_cap()` 四类 arena 槽位已返回 `AST_POOL_NO_LIMIT`（`ast_pool.c`）。

---

## 八、文档维护

| 变更类型 | 同步更新 |
|----------|----------|
| 修改 `ast.x` 中 PipelineDepCtx / Module / ASTArena 布局 | `lsp_diag_pipeline_sizes.c` |
| 新增 `pipeline_*` 供多模块 extern 调用 | `pipeline_glue.c` 转发、`fix_slim_arena_gen_c.pl`（若 gen2 需要） |
| 完成清单 ID | 本文档第三节打 ✅ 或第五节标注 🚫/⏳ |

**最后更新**：2026-05-20（阶段 A/B/C 全部完成；Stage2 已通过；P-B06 标注 ABI 不宜池化）。
