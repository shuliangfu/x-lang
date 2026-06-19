# 完全脱离 C 与 Makefile 路线图

> 目标：**编译器逻辑全部在 .sx 中实现**，**构建不再依赖 Makefile**，C 仅保留最小运行时（或最终仅 CRT）。  
> 本文档列出分阶段步骤，按表格逐项实现并打勾。

---

## 一、目标定义

| 目标 | 含义 |
|------|------|
| **完全不依赖 C（业务逻辑）** | 词法、语法、类型检查、代码生成、构建编排等全部由 .sx 实现；C 仅提供「最小运行时」（如 malloc/abort/文件 IO / pipeline 原语），或最终仅保留程序入口与 CRT。 |
| **不再需要 Makefile** | 从「宿主编译器」到「新 shuc」的完整构建由 **build.sx → build_tool** 或等价 .sx 流程完成，不调用 `make`；可选保留 Makefile 仅作兜底或最终删除。 |

---

## 二、当前状态简要

- **构建**：build_tool（build.sx）可完成 0～6 步全流程，step 1 用 shuc 生成 pipeline_gen.c（不依赖 make）；Makefile 保留为兜底。
- **前端**：parser/typeck/codegen/lexer/ast 已由 .sx 产出（ast_su.o、token_su.o、lexer_su.o、parser_sx.o、typeck_su.o、codegen_su.o）并参与链接，-sx 路径下业务逻辑在 .sx 中。
- **仍依赖 C 的原因**：main.sx、build.sx、typeck.sx、pipeline.sx 通过 **extern** 调用 runtime.c、build_runtime.c；codegen.sx 通过 **extern** 调用 codegen.c 中大量 `codegen_sx_*`（控制流与表达式生成）（见**第七节**）。因此**尚不能删除** runtime.c、build_runtime.c、codegen.c；要实现「**全部逻辑完整迁到 .sx**、完全自举、可删除 C 文件」需完成**第八节阶段 6**（含 6.0 codegen 完全迁 .sx）。

---

## 2.5 何时能「完全自举、不再依赖 C」？

路线图里「不再依赖 C」有两层含义，对应不同时间点：

| 层次 | 含义 | 当前状态 | 何时达成 |
|------|------|----------|----------|
| **业务逻辑不依赖 C** | 词法、语法、类型检查、代码生成、驱动、pipeline、构建、预处理等**全部在 .sx 实现**；C 只提供「最小运行时」（argv 取参、exec、文件 IO、malloc、CRT）。 | **已达成**（6.0～6.4 ✅）。main.sx / build.sx / pipeline.sx / preprocess.sx 等已承载业务；仍通过 **extern** 调用的只有：`driver_get_argv_i`、`run_compiler_sx_path`（-o 等复杂路径）、`pipeline_run_sx_pipeline_impl`（实现来自 pipeline.sx→C 生成）、build 的 exec/patch、libc 的 open/read/write。 | 现在。自举已是「用 build_tool + 上一代 shuc 产出新 shuc，运行逻辑在 .sx」。 |
| **C 仅极薄层 / 可删除 C 文件** | 把上述 extern 对应的 C 实现**收口到极薄 shim**（或极少数无法用 .sx 表达的如 argv），其余 C 文件可删除或仅剩 main+CRT。 | 未做（6.5 暂不执行）。当前仍保留 runtime.c、build_runtime.c、main.c、preprocess.c 等完整文件。 | **做完 6.5 即可**：在 6.0～6.4 验收通过后，执行「删除/最小化 C 文件」，只保留 main 调 main_entry、driver_get_argv_i、build_exec_cmd/build_patch、以及 libc。时间上可安排在 6.0～6.4 稳定后 1～2 个迭代。 |

**结论**：

- **「完全自举」**：已经实现。构建用 build_tool + shuc，新 shuc 的编译与驱动逻辑在 .sx，不依赖我们自己的 C 业务代码。
- **「不再依赖 C（业务逻辑）」**：已实现。剩余 C 均为最小运行时或无法在 .sx 中表达的边界（argv、exec、生成出的 pipeline_gen.c）。
- **「什么时候才能不再依赖 C」**：若指「业务逻辑不依赖 C」→ **现在**。若指「C 只保留极薄层、可删 C 文件」→ **做完 6.5**（建议 6.0～6.4 稳定后执行，约 1～2 个迭代）。若指「零 C 源码、连 main 都没有」→ 需换后端（.sx 直接出机器码或 LLVM IR）或接受长期保留「main + CRT + 极薄 shim」，路线图当前不以此为必达目标。

因此**不是「要搞很久才能自举」**，而是**自举和业务逻辑迁 .sx 已完成**；剩下的是**可选收口 6.5**（把 C 收到极薄层），以及是否把「零 C」定为下一阶段目标。

---

## 三、实现步骤表（按顺序打勾）

以下步骤按依赖顺序排列；完成一项即将该行「状态」列的 ⬜ 改为 ✅。

### 阶段 1：构建不依赖 Makefile（build_tool 自洽）

| 序号 | 内容 | 验收 | 状态 |
|------|------|------|------|
| 1.1 | build_run_step(1) 不再调用 `make pipeline_gen.c` | step 1 改为：用 shuc 生成 pipeline_gen.c（命令与 Makefile 中 bootstrap-pipeline + pipeline_gen.c 的 sed 修正等价），不执行 make | ✅ |
| 1.2 | pipeline_gen.c 的修正逻辑迁入 build_runtime 或 .sx 可配置 | 包装/重命名、(data,len) 包装、size getters、debug_module_funcs、parser_get_module_import_path 等修正在 build_tool 内完成，不依赖 Makefile 规则 | ✅ |
| 1.3 | 全流程仅用 build_tool：`cd compiler && ./build_tool ./shuxc` 产出 shuc，且无需 make | 删除或注释 Makefile 后，仅靠「已有 shuc + build_tool」能完成一次完整构建 | ✅ |

**阶段 1 完成标志**：不再需要执行任何 `make` 即可完成编译器构建。

---

### 阶段 2：生成 pipeline 用 .sx 流水线（脱离 C 前端生成 pipeline_gen.c）

| 序号 | 内容 | 验收 | 状态 |
|------|------|------|------|
| 2.1 | -sx -E 支持 -L 与多库根 | driver 解析 -sx -E 时接受前面出现的 -L path，并传入 pipeline/resolve，使「shuc -L .. -L src/lexer ... -sx -E src/pipeline/pipeline.sx」能解析 import | ✅ |
| 2.2 | 用 -sx -E 生成 pipeline_gen.c | build_tool 的「生成 pipeline_gen.c」步骤优先调用 `shuc -sx -E -L ... src/pipeline/pipeline.sx`；若失败则回退到 C 前端 `shuc ... pipeline.sx -E`，保证构建可完成 | ✅ |
| 2.3 | 上述生成的 pipeline_gen.c 经现有修正后能正常编出 pipeline_sx.o，且 bootstrap/build_tool 全流程通过 | 与当前 Makefile 构建产出的 shuc 行为一致（如 run-all 或 return-value 42） | ✅ |

**阶段 2 完成标志**：生成 pipeline_gen.c 时优先使用 .sx 流水线（-sx -E）；当前若 .sx 解析 pipeline.sx 失败则自动回退 C -E，全流程通过。

**说明**：当前 `parser_parse_into` 对 pipeline.sx 会失败，step 1 实际走回退 C -E；待 .sx 解析器能稳定解析 pipeline.sx 后，将自动走 -sx -E 路径。

---

### 阶段 3：链接用 .sx 版 parser/typeck/codegen（可选）

| 序号 | 内容 | 验收 | 状态 |
|------|------|------|------|
| 3.1 | shuxc 支持「-E 仅展开入口、import 用 extern」或等价机制 | 生成「瘦」pipeline_gen.c（只含 pipeline 自身 + extern parse_into/typeck_su_ast/codegen_sx_ast 等），不内联 parser/typeck/codegen | ✅ |
| 3.2 | build_tool 链入 parser_sx.o、typeck_su.o、codegen_su.o，不再链 parser.o、typeck.o、codegen.o | 链接命令用 parser_sx.o 等；step 0 不再编 parser/typeck/codegen 的 C，或仅保留 lexer/ast/preprocess/runtime/main 等 C | ✅ |
| 3.3 | 全构建通过且测试套件与当前一致 | run-all 或 bootstrap-verify 等价验收通过 | ✅ |

**阶段 3 完成标志**：可执行中的「parser/typeck/codegen」全部来自 .sx 编译产物，C 不再包含这三块业务。

**3.1 已实现**：新增 `-E-extern` 与 `codegen_emit_dep_types_only()`，`run_compiler_c` 在 `emit_c_only && emit_extern_imports` 时仅输出依赖类型 + 入口模块（extern 由 codegen 生成）。`build_patch_pipeline_gen_c` 在瘦 pipeline_gen.c 缺 `parser_parse_into` 声明时会补上。

**3.2/3.3 部分就绪、暂未启用**：已实现 `run_compiler_sx_path`（runtime.c）、main.sx 改调 `run_compiler_sx_path`、build_tool 的 step 6（生成并编 parser_su/typeck_su/codegen_su）及 `build_patch_parser_export`（parser_* ABI 包装）。当前仍用 C 的 parser/typeck/codegen 与完整 -E 生成自包含 pipeline_gen.c，原因：parser_sx.o/typeck_su.o/codegen_su.o 由 `shuc -E` 生成时带齐 ast/lexer/main，链接会重复符号。待实现「-E 库模式」（仅导出 parser_*/typeck_*/codegen_*、无 main/ast/lexer 内联）后，可切 step 0 不编 C parser/typeck/codegen、step 5 链 _su.o 并加 -DSHUC_USE_SU_FRONTEND。

---

### 阶段 4：C 仅最小运行时（lexer/ast/preprocess 迁出或保留最小）

| 序号 | 内容 | 验收 | 状态 |
|------|------|------|------|
| 4.1 | lexer 迁到 .sx 或由 .sx 生成并链入 | 可执行中词法逻辑来自 lexer.sx 产出，或仍用 C lexer 但约定为「最小 C 层」 | ✅ |
| 4.2 | ast 迁到 .sx 或由 .sx 生成并链入 | 可执行中 AST 结构/分配来自 ast.sx 产出，或仍用 C ast 作为最小层 | ✅ |
| 4.3 | preprocess 迁到 .sx 或保留 C 最小层 | 预处理逻辑在 .sx 中，或仍用 preprocess.c 作为最小 C 层（与 4.1/4.2 约定一致） | ✅ |
| 4.4 | runtime.c 最小化 | 仅保留 pipeline 原语（resolve_path、read_file、get_dep_* 等）、malloc/abort、必要文件 IO；其余删除或迁到 .sx | ✅ |
| 4.5 | main.c 最小化 | 仅保留「调用 driver 入口」或由 .sx 生成 main 桩，无业务逻辑 | ✅ |

**阶段 4 完成标志**：C 代码仅剩「最小运行时 + 程序入口」，业务逻辑全部在 .sx。  
**4.3 说明**：6.4 已完成：preprocess.sx 已链入（ndefines==0 时走 typeck_preprocess_su）；preprocess.c 保留为 preprocess_c_fallback 供 ndefines>0 或回退。  
**4.4 说明**：SU 构建下 `run_compiler_c` 已为桩、不执行 C 前端；`run_compiler_sx_path` + pipeline 原语 + read_file/resolve/get_dep_* 为实际路径。`find_loaded_index` 等仍被 SU 路径使用，故保留在 runtime.c。

---

### 阶段 5：完全脱离 Makefile 与构建收尾

| 序号 | 内容 | 验收 | 状态 |
|------|------|------|------|
| 5.1 | 文档标明「唯一构建方式：build_tool」 | README 或 自举开发时序表 写明：构建仅需 `cd compiler && ./build_tool ./shuxc`（或等价），不再需要 make | ✅ |
| 5.2 | Makefile 改为可选/兜底或删除 | 若保留 Makefile，仅作「无 build_tool 时的兜底」并注明；或完全删除 Makefile | ✅ |
| 5.3 | 自举验证不依赖 make | `bootstrap-verify` 等价流程由 build_tool 或 .sx 脚本完成（如两代 shuc 均由 build_tool 产出并跑 run-all） | ✅ |

**阶段 5 完成标志**：日常与自举均不依赖 Makefile，实现「不再需要 Makefile」。

**5.2 说明**：compiler/Makefile 顶部已注明「兜底/可选」，仅用于从零构建得到 shuc/build_tool 或执行 test、bootstrap-verify 等目标。

---

## 四、依赖关系简图

```
阶段 1（build_tool 不调 make）
    ↓
阶段 2（pipeline_gen.c 用 -sx -E 生成）
    ↓
阶段 3（可选：链入 parser/typeck/codegen 的 .sx 版）
    ↓
阶段 4（lexer/ast/preprocess/runtime 最小化）
    ↓
阶段 5（文档 + 删除/兜底 Makefile）
```

阶段 1、2 是「不依赖 Makefile」和「生成 pipeline 脱离 C 前端」的关键；阶段 3～5 在此基础上逐步减少 C、去掉 Makefile。

---

## 五、与《自举开发时序表》的关系

- **自举开发时序表**：侧重「自举能否走通、阶段 1～8 打勾」。
- **本文档**：侧重「如何做到完全不依赖 C、不再需要 Makefile」，并拆成可执行的 1.1～5.3。
- 两表可并行推进：自举已通（阶段 8 ✅）后，按本路线图从阶段 1 起逐项实现即可。

---

## 六、说明

- **打勾**：完成一项即将该项「状态」列的 ⬜ 改为 ✅，建议同时提交当次改动。
- **遇阻**：若某步依赖「shuc 尚不支持的能力」（如 -sx -E 支持 -L），先在该步下注明，再在 C 或 shuc 中做最小扩展后继续。
- **验收**：每步「验收」列给出可验证标准，便于 CI 或人工检查。

---

## 七、当前 .sx 对 C 的 extern 依赖（尽量不依赖，.sx 全部写自己逻辑）

目标：**.sx 内实现全部业务逻辑，尽量不依赖 C**；仅保留最小运行时（如 libc 的 open/read/write/close、malloc/free）时再考虑删除我们自己的 C 文件。当前仍有下列 .sx 通过 **extern** 调用我们自己的 C，需按阶段 6 逐项迁到 .sx 自写逻辑。

| .sx 文件 | extern 函数 | 提供方（C 文件/库） | 迁移目标（6.x） |
|----------|-------------|----------------------|-----------------|
| build.sx | `build_get_argv_i`, `build_append_literal`, `build_exec_cmd`, `build_patch_after_step`（极薄原语） | build_runtime.c | 6.3 ✅：拼命令与编排在 build.sx，C 仅提供 exec/patch |
| main.sx | `run_compiler_c`, `run_compiler_sx_path`, `driver_get_argv_i`, `pipeline_run_sx_pipeline`（极薄原语） | runtime.c | 6.2 ✅：-sx -E 解析与执行全在 main.sx，仅保留上述 extern |
| typeck.sx | `get_dep_module`, `get_dep_arena`, `get_ndep` | runtime.c | 6.1：dep 在 .sx 内 |
| pipeline.sx | `pipeline_resolve_path`, `pipeline_read_file`, `pipeline_parse_into_loaded_import`, `pipeline_*_slot`, `pipeline_set_dep`/`set_ndep`, `get_dep_*`, `get_ndep` | runtime.c | 6.1：原语在 .sx 内 |
| codegen.sx（及 -E 生成的 pipeline 内联） | 无（原 codegen_sx_* 已全部在 codegen.sx 内实现） | — | 6.0 ✅ |
| preprocess.sx | 无 | — | 6.4 ✅ 已无 C 依赖 |
| std/fs/mod.sx | `open`, `read`, `write`, `close` | libc | 最小运行时，保留 |
| tests/ffi/putchar.sx | `putchar` | libc | 最小运行时，保留 |

- **结论**：**尽量不依赖 C**；6.0～6.4 将上表「我们自己的 C」提供的接口**全部在 .sx 中实现**。6.5 暂不执行删除 C 文件；libc 的 open/read/write/close/putchar 视为最小运行时保留。

---

## 八、阶段 6（可选）：走向完全自举，.sx 全部写自己的逻辑

**原则**：**.sx 内实现全部业务逻辑，尽量不依赖 C**；仅当 6.0～6.4 全部完成、.sx 逻辑自洽后，再考虑 6.5（删除/最小化 C 文件）。阶段 6 不执行「删除 C 文件」直到明确验收通过。

要实现「**所有逻辑完整迁到 .sx**、完全自举」，需要把第七节表中**我们自己的 C** 提供的接口，**全部在 .sx 中实现**，或收口到极薄 C 层（仅系统调用/CRT）。建议按下列顺序推进。

| 序号 | 内容 | 验收 | 状态 |
|------|------|------|------|
| 6.0 | **codegen 完全迁 .sx** | codegen.sx 内实现所有 `codegen_sx_*` 的等价逻辑（emit、block、match、if_expr、for/while、call、index、field_access、struct_lit、array_lit 等）；.sx 与 -E 生成的 pipeline 内联**不再 extern** codegen.c 的符号；逻辑全部在 .sx，不依赖 C 业务代码 | ✅（codegen.sx 已无 extern 调 C；STRUCT_LIT/ARRAY_LIT/ENUM_VARIANT 等均在 .sx 内 emit_expr 实现） |
| 6.1 | **pipeline 原语迁 .sx** | `pipeline_resolve_path`、`pipeline_read_file`、`pipeline_set_dep`、`get_dep_*` 等**在 .sx 内用 std.fs + .sx 自己的 dep 存储实现**；pipeline.sx / typeck.sx **不再 extern** 这些符号；仅允许 extern malloc/free 与 std.fs（open/read/close）等最小运行时 | ✅（resolve_path_su/read_file_su 纯 .sx+std.fs；preprocess_sx_buf 在 preprocess.sx；ctx 用固定数组；**仅保留 1 个 C 桥接** pipeline_parse_into_buf：因 .sx 暂无 (buf,len)→[]u8 语法） |
| 6.2 | **driver 入口迁 .sx** | `run_compiler_sx_path`、`driver_argv_parse_su_emit_c`、`driver_run_sx_emit_c` 的**全部逻辑在 main.sx（或 driver.sx）中实现**；.sx 不再通过 extern 调 runtime.c 的上述函数；C 仅保留「调用 main_entry」的 main 桩（不删 C 文件，仅收口） | ✅（main.sx 实现 driver_argv_parse_su、driver_run_sx_emit_sx；-sx -E 解析与执行全在 .sx；仅 extern driver_get_argv_i、run_compiler_sx_path、pipeline_run_sx_pipeline） |
| 6.3 | **build_tool 原语迁 .sx** | `build_get_shuc_path`、`build_run_step` 的「拼命令、调 shuc/cc、写 pipeline_gen.c」等**逻辑在 build.sx 中实现**；.sx 不再 extern build_runtime.c；可基于 std.fs + 新 std.process（或极薄 C：exec/spawn）在 .sx 内完成子进程与文件读写 | ✅（build.sx 实现 entry/run_all_steps/run_step，拼命令用 build_append_literal、执行用 build_exec_cmd、修正用 build_patch_after_step；C 仅保留上述极薄原语 + patch 实现） |
| 6.4 | **preprocess 迁 .sx** | 预处理**逻辑全部在 preprocess.sx**，无 extern 读/写字节；链入 preprocess_su.o，runtime 在 ndefines==0 时调 .sx 实现 | ✅（preprocess.sx 已无 C 依赖；preprocess.c 仅作 ndefines>0 回退，不删文件） |
| 6.5 | **删除/最小化 C 文件（暂不执行）** | 仅在 6.0～6.4 全部完成且验收通过后**再考虑**；不执行删除 runtime.c、build_runtime.c、codegen.c、preprocess.c，仅保留「main 调 main_entry + CRT」等极薄 C 时再动 | 🔶 暂不执行（先完成 6.0～6.4，.sx 逻辑全部写好后再议） |

**阶段 6 完成标志（不含 6.5）**：**语法、控制流、代码生成、驱动、pipeline、构建、预处理**等业务逻辑**全部在 .sx 中实现**，**.sx 不依赖我们自己的 C 业务代码**（仅允许最小运行时如 libc/open/read/close、malloc/free）。**完全自举**：用「build_tool + 上一代 shuc」产出新一代 shuc，新一代 shuc 的运行逻辑由 .sx 承担。**6.5 暂不执行**：不删除 C 文件，仅在做完 6.0～6.4 并确认 .sx 自洽后再考虑是否删除/最小化 C。

**说明**：  
- **6.0 codegen 完全迁 .sx**：codegen.sx **已不 extern** codegen.c，整条 -sx 路径只调 codegen_sx_ast；emit_expr/emit_block 等均在 .sx 内用 ast.sx 自写。未覆盖的仅剩 STRUCT_LIT/ARRAY_LIT/EXPR_ENUM_VARIANT 等少量分支，补全即可达标。  
- **6.1 pipeline 原语**：**无需模块级 var**。做法：定义「dep 上下文」结构体（如 `PipelineDepCtx { dep_modules, dep_arenas, ndep }`），由调用方分配并传入 `run_sx_pipeline(..., ctx)` 与 `typeck_su_ast(module, arena, ctx)`，.sx 内用 ctx 读写 dep，不再调用 get_dep_*/pipeline_set_dep 等 extern。resolve_path/read_file 在 .sx 内用 std.fs（open/read/close）+ 自写路径拼接实现。  
- **6.2 driver**：run_compiler_sx_path、driver_argv_parse_su_emit_c、driver_run_sx_emit_c 的**实现逻辑迁到 main.sx**，C 只留 main 调 main_entry，不删 runtime.c 文件直至 6.5 明确执行。  
- **6.3 build_tool**：build_get_shuc_path、build_run_step 的**实现逻辑迁到 build.sx**（拼命令、调子进程、写文件），不依赖 build_runtime.c 业务逻辑；不删 build_runtime.c 直至 6.5。  
- **6.4 preprocess**：已达成；preprocess.sx 无 extern，逻辑全在 .sx。  
- **6.5**：**暂不执行删除文件**；仅当 6.0～6.4 全部写好并验收后，再讨论是否删除或最小化 C 文件。  
- std/fs 与 tests/ffi 的 open/read/write/close/putchar 依赖 **libc**，视为最小运行时，不阻碍「.sx 全部写自己逻辑」；若需零 C 源码可再议入口与 CRT。

**6.0～6.4 限制与可做**：  
- **6.0**：无语言限制；codegen.sx 已自洽，补全未实现的 ExprKind/Block 分支即可。  
- **6.1**：无语言限制；dep 用「上下文结构体」传入即可，resolve/read_file 用 std.fs 在 .sx 内实现。  
- **6.2**：需在 .sx 内解析 argv、读文件、调 pipeline、写 stdout；调 cc 子进程可暂保留极薄 C（exec/spawn）或后续做 std.process。  
- **6.3**：需在 .sx 内拼命令、执行子进程、读写文件；无 spawn 时可保留极薄 C 提供「执行命令」接口。  
- **6.4**：已达成。

---

## 九、.sx 直接出机器码/LLVM 后端（工作量与路径）

若目标为「**不再依赖 C 编译器**」（.sx 不生成 C、不调 cc），则需增加**原生后端**：.sx 直接产出**机器码**或 **LLVM IR**，再经系统工具生成可执行文件。两种方案对比如下。

### 9.1 方案对比

| 方案 | 做法 | 工作量 | 依赖 | 适用 |
|------|------|--------|------|------|
| **LLVM IR 后端** | 在现有 codegen 旁增加「AST → LLVM IR」发射；写 .ll 文件或调 LLVM C API；用 `llc` 生成 .o，再 `ld` 链接。寄存器分配、指令选择、优化由 LLVM 完成。 | **中等**（见下） | 系统安装 LLVM（llc/lld 或 libLLVM） | **推荐先做**：可复用 LLVM 的优化与多架构支持，实现「零 C 源码」时不再需要系统 cc。 |
| **直接出机器码** | 自研指令编码、基本块、重定位、ELF/Mach-O 目标文件、链接器调用或自研链接。相当于实现一个完整后端。 | **大**（见下） | 无（或仅 binutils 的 as/ld） | 适合追求「无 LLVM 依赖」或嵌入式/极小工具链；周期长。 |

### 9.2 工作量估算（量级）

- **LLVM IR 后端**
  - **内容**：类型/函数/全局 → LLVM 类型与声明；每个 AST 表达式/语句 → LLVM IR 指令序列（alloca/load/store/br/call/ret/phi 等）；处理 ABI（如 C 调用约定）、多模块/链接；driver 里用 llc + ld 替代 cc。
  - **量级**：约 **2～5 人月**（1 人全职）。若只支持当前 .sx 子集（无泛型/无复杂标准库）、先出文本 IR 再调 llc，可压在 **2～3 人月**；若用 LLVM C API、支持完整语言特性与 LTO，则接近 5 人月。
  - **已有基础**：现有 codegen.sx 已是「AST → 线性输出」，逻辑可复用到「AST → IR 指令序列」；类型系统与 AST 已稳定，主要工作是建「AST 结点 ↔ LLVM IR」的映射与驱动集成。

- **直接出机器码**
  - **内容**：指令编码（如 x86-64/ARM 的每条指令）、寄存器分配、指令选择、基本块与 CFG、重定位与符号表、目标文件格式（ELF/Mach-O）、与系统 ld 对接或自研简单链接。
  - **量级**：约 **6～12 人月**（单架构、无优化）。多架构、优化 pass 会再放大。
  - **结论**：**工作量大**，适合作为 LLVM 之后的长期选项或「无 LLVM」的专门路线。

### 9.3 推荐路径（要实现「不依赖 C 编译器」时）

1. **先做 LLVM IR 后端**（2～3 人月可出可用版本）  
   - 在 codegen 层增加「后端选择」：现有 C 输出保留；新增「LLVM IR」路径：AST → 生成 .ll 或内存中的 IR → 调 llc 生成 .o → 调 ld 链接。  
   - 验收：`shuc -backend llvm file.sx -o a.out` 不调 cc，仅用 llc + ld，产出可执行文件且行为与 C 后端一致。  
   - 完成后即可实现「零 C 源码」：宿主编译器只需能跑 .sx，新 shuc 用 LLVM 后端即可不再依赖系统 C 编译器。

2. **直接机器码**：在 LLVM 后端稳定、且确有「不依赖 LLVM」需求时再立项；或作为独立长期目标（如 9.2 量级）。

**总结**：**要实现「.sx 直接出机器码/LLVM」才行的目标，工作量是可接受的**——优先做 **LLVM IR 后端**（约 2～5 人月），即可不再依赖 C 编译器；**直接出机器码**工作量大（6～12+ 人月），适合作为后续阶段或单独路线。

### 9.4 LLVM IR vs 直接机器码：优劣对比

| 维度 | LLVM IR 后端 | 直接出机器码 |
|------|----------------|----------------|
| **开发成本** | 低～中：只做「AST→IR」映射 + 调 llc/ld；2～5 人月可上线。 | 高：指令编码、寄存器分配、指令选择、目标文件、链接全自研；6～12+ 人月。 |
| **运行时依赖** | 需要系统安装 LLVM（llc/lld 或 libLLVM）。体积/部署受 LLVM 影响。 | 无 LLVM 依赖；可只依赖 binutils（as/ld）或自研链接，工具链更「干净」。 |
| **优化与性能** | 优：直接复用 LLVM 的 -O0/-O2/-O3、向量化、内联、LTO 等，质量接近 Clang。 | 中～差：需自写优化（寄存器分配、指令选择、窥孔等），否则性能易落后；做好要大量投入。 |
| **多架构/可移植** | 优：LLVM 支持 x86/ARM/RISC-V/WebAssembly 等，加目标主要是前端传 triple。 | 差：每多一个架构都要写一套指令编码与 ABI，工作量成倍增加。 |
| **调试与生态** | 优：可输出 .ll 文本、用 opt/llc 调试；与 LLVM 生态（sanitizer、profile）兼容。 | 中：需自备反汇编/调试信息；和现有工具链的集成要自己做。 |
| **可控性/可预测性** | 中：行为由 LLVM 版本与选项决定；定制或「极小二进制」要摸清 LLVM 选项。 | 高：每条指令、每个段完全可控，适合对体积/行为有极端要求的场景（如 bootloader、嵌入式）。 |
| **自举与分发** | 中：自举时需宿主机有 LLVM，或把 llc 打进发布包（体积大）。 | 优：不依赖 LLVM，发布一个 shuc 即可；适合「单二进制」或嵌入式分发。 |

**简要结论**：

- **LLVM IR**：**更适合先做**——开发快、性能好、多架构省心；代价是依赖 LLVM 和一定的体积/分发成本。适合「尽快不依赖 C 编译器、且要性能和可移植性」的目标。
- **直接机器码**：**更适合对依赖与可控性有强需求时再做**——无 LLVM、工具链干净、行为完全可控；代价是工作量大、优化难、多架构成本高。适合「不能带 LLVM」的嵌入式、极小镜像、或长期做「自有后端」的路线。

**没有绝对更好的一个**：要**快上线、高性能、多架构**选 LLVM；要**零 LLVM、完全可控、单二进制分发**选直接机器码（并接受周期与人力）。多数语言先上 LLVM（或类似 IR 后端），再视需要做自研后端。

**直接出机器码的完整实现分析**（阶段划分、是否要 IR、指令编码、目标文件、工作量）：见 **analysis/直接出机器码后端分析.md**。
