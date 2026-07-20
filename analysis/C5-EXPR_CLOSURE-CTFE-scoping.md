# C5 EXPR_CLOSURE CTFE 排期与拆分（2026-07-19）

> **状态**：规划稿（scoping only），未启动实现
> **来源**：[cap-candidates-2026-07-19.md](../.trae/documents/cap-candidates-2026-07-19.md):151-163 C5 子项「closure / lambda CTFE（前置 closure 支持）」
> **铁律锚点**：[../AGENTS.md](../AGENTS.md)（根源 · G.7「禁止功能重复实现」· G.8 平台边界）· skill `shux-selfhost-product-gate` · [自举方法.md](自举方法.md)（Cap/R/L/M）
> **当波 tip**：`d7a2388e`（C5 EXPR_ENUM_VARIANT CTFE 收口；前 `a8a67708` / `229708f1`）
> **作者结论**：**不启动**。C5 EXPR_CLOSURE 非单纯 fold 扩展，需先建 4 个前置层（fn 类型 / AST 节点 / typeck capture / codegen lowering），多波独立工程；建议本日转向更小 fold 扩展（EXPR_TERNARY / EXPR_IF / EXPR_BLOCK），closure 顺延至自举完成后或单开 RFC 立项。

---

## 0. 一句话结论

SHUX 当前**无任何 closure 支持**（无 parser 语法、无 AST 节点、无类型系统支持、无 typeck、无 codegen、无 std、无测试、无 RFC）。C5 EXPR_CLOSURE CTFE 不是"加一个 fold handler"，而是"从零造 closure 子系统"，预计 4-6 波独立工程，**非本日可启动**。

---

## 1. 现状核查（权威证据）

### 1.1 类型系统（`compiler/include/ast.h` L24-41）

```
AST_TYPE_I32 / BOOL / U8 / U32 / U64 / I64 / USIZE / ISIZE
AST_TYPE_NAMED       // 用户类型
AST_TYPE_PTR         // 裸指针 *T
AST_TYPE_ARRAY       // T[N]
AST_TYPE_SLICE       // T[]
AST_TYPE_LINEAR      // Linear(T) — M-4
AST_TYPE_OWNED       // owned(T) — MEM-B1
AST_TYPE_VECTOR      // i32x4
AST_TYPE_F32 / F64
AST_TYPE_VOID
```

**无 `AST_TYPE_FN` / 函数类型 / 一等函数值类型**。

### 1.2 表达式 AST（`compiler/include/ast.h` L56-115）

完整 ExprKind 枚举：LIT / FLOAT_LIT / BOOL_LIT / VAR / ADD..LOGOR / NEG/BITNOT/LOGNOT / IF / BLOCK / TERNARY / ASSIGN / *_ASSIGN / BREAK / CONTINUE / RETURN / PANIC / MATCH / FIELD_ACCESS / STRUCT_LIT / ARRAY_LIT / INDEX / CALL / METHOD_CALL / **ENUM_VARIANT（已废弃）** / ADDR_OF / DEREF / AS / AWAIT / RUN / SPAWN / TRY_PROPAGATE / STRING_LIT / ASM。

**无 `EXPR_CLOSURE` / `EXPR_LAMBDA` / `EXPR_FN_VAL`**。

### 1.3 "closure" 字眼在 codebase 的真实含义

`grep -rn "closure" compiler/` 全部命中是 **dependency transitive closure**（依赖图传递闭包），与语言级闭包无关：

- `compiler/codegen_gen.c:9538` — "multi-import closure"（模块依赖闭包）
- `compiler/typeck_gen.c:6732` — "multi-import closure (ndep > n_imports)"
- `compiler/pipeline_glue.c:24767` — "closure seed may order deps differently"
- `compiler/seeds/rt_run_*` — `n_closure` / `shux_collect_deps_transitive` 全是依赖图

### 1.4 函数指针现状（C-style，非一等函数）

SHUX 通过 `*u8` 裸指针 + `extern "C"` ABI 实现 C-style 函数指针：

```shux
// compiler/src/runtime_driver_abi_thin.x:50
export extern "C" function shux_driver_call_fn_void_arg(fn: *u8, arg: *u8): void;
```

- 这只是把函数地址当 `*u8` 传，**无 capture、无 environment、无类型签名**
- `std/ffi/ffi.x:220` `ffi_struct_callback_smoke_c` 同样走 FFI 路径
- 无 `fn(i32) -> i32` 类型表达式；调用方须 `extern "C"` 强转 + unsafe

### 1.5 文档与 RFC 状态

- `docs/01-关键字.md` … `docs/10-内核级特性.md` 全部无闭包 / lambda / 捕获 / fn 类型章节
- `analysis/` 下无任何 closure / lambda / first-class-function RFC（仅有 `safe-ffi-contract-v1.md` 等围绕 FFI 边界，非闭包）
- 唯一 "capture" 字眼在 `docs/07-内置与标准库.md:64` 是 `std.backtrace` "capture + symbolicate"（栈帧捕获，非语言闭包）

---

## 2. 前置依赖（4 层独立工程，顺序硬约束）

C5 EXPR_CLOSURE CTFE 不可能在「无 closure 基建」时直接做。完整前置链：

```
Wave 1: fn 类型系统 (TYPE_FN)        ← 必须，无类型则无法 typeck
   ↓
Wave 2: EXPR_CLOSURE AST + parser    ← 依赖 Wave 1 类型表达
   ↓
Wave 3: typeck capture analysis      ← 依赖 Wave 2 AST 节点
   ↓
Wave 4: codegen closure lowering     ← 依赖 Wave 3 capture 信息
   ↓
Wave 5: EXPR_CLOSURE CTFE fold       ← 本 Cap C5 子项，依赖前 4 波
```

**铁律约束（G.7 禁止功能重复实现 / G.4 禁止双权威）**：每一波只能有**一个权威实现**，禁止在 glue 与 seed 之间分叉；fn 类型表示必须在 ast.h 唯一定义，parser/typeck/codegen 三处消费同一池下标。

---

## 3. 多波拆分（含估时与产生点）

### Wave 1: fn 类型系统（`TYPE_FN`）— 估时 1.5 波

**目标**：让 SHUX 能表达 `fn(i32, i32) -> i32` 类型；仅类型层，不含闭包。

产生点（最小集）：
1. `compiler/include/ast.h` TypeKind 加 `AST_TYPE_FN`
2. `compiler/include/ast.h` ASTType 加 `param_types[]` / `n_params` / `return_type` 字段（或池下标方案）
3. `compiler/src/parser/parser.x` 类型表达式 parser 加 `fn(...) -> ...` 语法
4. `compiler/src/typeck/typeck.x` `resolve_type` 识别 TYPE_FN；与 PTR/ARRAY 互转规则
5. `compiler/src/codegen/codegen.x` TYPE_FN → C `(*)` 函数指针类型发射
6. `compiler/seeds/parser_gen.linux.x86_64.c` + `seeds/typeck_gen.*` 镜像同步
7. 加 lang-fn-type bstrict：`run-fn-type-basic-gate.sh`（声明 + 赋值 + 互转）

**验收**：`let f: fn(i32) -> i32 = some_fn;` 编译过；mac+Ubuntu 双端 L2 + bstrict 全绿。

**风险**：fn 类型与 PTR 互转规则需明确定义（C `void(*)(void)` 与 `*u8` 是否等价）；ABI 边界（extern "C" fn vs X ABI fn）需借 P0b `extern "C"` 标注对齐。

---

### Wave 2: EXPR_CLOSURE AST + parser 语法 — 估时 1.5 波

**目标**：让 SHUX 能 parse `|x, y| expr` 或 `fn(x, y) expr` 闭包字面量；AST 节点落库但 typeck/codegen 暂不实装（编译报 "closures not yet supported"）。

候选语法（**未决，需 RFC 立项**）：
- A. Rust 风格：`|x, y| expr` / `|x, y| { stmts; expr }`
- B. Swift 风格：`{ x, y in expr }`
- C. Zig 风格：`fn(x: i32, y: i32) i32 { ... }`（匿名函数字面量）

产生点：
1. `compiler/include/ast.h` ExprKind 加 `AST_EXPR_CLOSURE`
2. ASTExpr 加 closure 字段：`param_names[]` / `param_types[]` / `n_params` / `body_ref` / `capture_caps[]` / `n_captures`（capture 字段此波留空，Wave 3 填）
3. `compiler/src/lexer/lexer.x` 加 `|` 上下文敏感 token（与位或 `|` 区分）
4. `compiler/src/parser/parser.x` 加 closure 字面量 parser
5. `compiler/seeds/parser_gen.*` 镜像
6. 加 lang-closure-parse bstrict：仅测 parser 接受语法（typeck/codegen 暂返回 unsupported diagnostic）

**验收**：`let f = |x| x + 1;` 解析成功（AST 落库）；语义阶段报 "closure unsupported"；不影响现有 `|` 位或语义。

**风险**：语法选择需 RFC（A/B/C 三选一）；与 lambda 区分（是否支持 `return` / `break` / 多语句）；与 EXPR_BLOCK 语法歧义（`{ ... }` 既可是 block 也可是闭包体）。

---

### Wave 3: typeck capture analysis — 估时 2 波

**目标**：解析闭包捕获的自由变量；确定每个 capture 是 by-value / by-ref / by-move；生成捕获列表。

产生点：
1. `compiler/src/typeck/typeck.x` 加 closure scope walker（与 block scope 区分：闭包体可访问外层自由变量）
2. capture 分类算法：
   - by-value：基础类型（i32/bool/u8/u32/u64/i64/usize/isize/f32/f64）
   - by-ref：复合类型（struct/array）只读借用
   - by-move：owned(T) / Linear(T) 必须移动语义
3. capture 类型解析 + 推断 closure 整体类型为 `fn(Params) -> Ret`（依赖 Wave 1）
4. 与现有 `type-borrow-conflict-v1-rfc.md` / `type-linear-v1-rfc.md` / `type-region-v1-rfc.md` 对齐（闭包 capture 与借用/线性/生命周期交叉）
5. `compiler/seeds/typeck_gen.*` 镜像
6. 加 lang-closure-capture bstrict：测捕获正确性（by-value / by-ref / by-move 三场景）

**验收**：`let n = 10; let f = |x| x + n;` 编译过，`f(5)` 返回 15；capture=`n` by-value i32。

**风险**：与借用检查交叉可能产生大量新 diagnostic；by-move 语义与现有 owned(T) 解构顺序冲突；region 推断（生命周期）若不开 P1 可能限制闭包只能 capture `'static`。

---

### Wave 4: codegen closure lowering — 估时 2 波

**目标**：把闭包 lowering 为「函数 + 捕获结构体」对（C-style 转译），与现有 codegen 对齐。

Lowering 策略：
- 每个 closure 生成一个内部函数 `__closure_<id>(env: *CaptureStruct, params...) -> Ret`
- capture 列表打包成 `CaptureStruct`，闭包字面量发射为 `&CaptureStruct` + 函数指针二元组
- 调用点 `f(args)` desugar 为 `f.fn_ptr(f.env, args)`

产生点：
1. `compiler/src/codegen/codegen.x` 加 closure emit
2. `compiler/pipeline_glue.c` glue 层 closure emit（X pipeline）
3. `compiler/seeds/codegen_gen.*` 镜像
4. 与 `shux_driver_call_fn_void_arg` 模型对齐（避免造第二套函数指针 ABI — G.7 铁律）
5. ELF emit（asm_backend）路径：closure → 静态函数 + 静态捕获结构
6. 加 lang-closure-codegen bstrict：by-value / by-ref / by-move 三 capture 模式的运行期验收

**验收**：`let f = |x| x * 2; let r = f(21); return r;` → exit=42；mac+Ubuntu 双端 L2 + bstrict 全绿。

**风险**：捕获结构体布局需对齐 SHUX ABI（与 X ABI P0b 同步）；递归闭包 / 互引闭包需 cycle 检测；与 WPO（whole-program optimize）的交互（closure 是否内联展开）。

---

### Wave 5: EXPR_CLOSURE CTFE fold（本 Cap C5 子项）— 估时 0.5 波

**目标**：让 `const F = |x| x + 1; const R = F(2);` 编译期折叠为 3。

产生点：
1. `compiler/pipeline_glue.c` `glue_is_const_expr_ref` 加 EXPR_CLOSURE case：捕获列表全部 const → const
2. `compiler/pipeline_glue.c` `glue_typeck_fold_expr_ref` 加 EXPR_CLOSURE case：构建 capture env → fold body → stamp result
3. `compiler/seeds/pipeline_glue_strict_minimal.from_x.c` 镜像（Darwin filtered pipeline 下生效）
4. 加 lang-const case `c_closure_const`（want=3）

**验收**：`const F = |x| x * 2; const R = F(21); return R;` → exit=42；mac+Ubuntu 双端 L2 + lang-const 15/15。

**前置**：Wave 1-4 全部完成。

---

## 4. 总估时与排期

| 波 | 内容 | 估时 | 累计 | 阻塞 |
|----|------|------|------|------|
| Wave 1 | fn 类型系统 | 1.5 波 | 1.5 | 类型层基建 |
| Wave 2 | EXPR_CLOSURE AST + parser | 1.5 波 | 3.0 | 语法 RFC 立项 |
| Wave 3 | typeck capture analysis | 2.0 波 | 5.0 | 借用/线性/region 交叉 |
| Wave 4 | codegen closure lowering | 2.0 波 | 7.0 | ABI / WPO 交互 |
| Wave 5 | EXPR_CLOSURE CTFE fold（本 Cap） | 0.5 波 | 7.5 | Wave 1-4 完成 |

**总计 ≈ 7.5 波（约 7-8 个工作日，每波含双端 L2 + bstrict）**。本日（2026-07-19）剩余时间不足以启动 Wave 1。

---

## 5. 建议执行路径

### 5.1 短期（本日剩余 + 1-2 波）

转向更小的 C5 fold 扩展，快速收尾 lang-const 矩阵：

- **C5 EXPR_TERNARY CTFE**（`cond ? a : b`）：fold cond → 选 a/b → stamp；估时 0.3 波
- **C5 EXPR_IF CTFE**（`if cond { a } else { b }` 表达式形式）：同 ternary，估时 0.3 波
- **C5 EXPR_BLOCK CTFE**（`{ const x = ...; x }` block 表达式）：fold 末尾 expr，估时 0.4 波

三项合计 ≈ 1 波，可快速并入 lang-const 矩阵。

### 5.2 中期（自举完成前）

closure 整体顺延至自举完成后（per [自举进度.md](自举进度.md) §3 "不在前排" 的 RFC 排期原则；与 IR 优化器、signal/event 模块同期立项）。

理由：
- closure lowering 需要稳定的 codegen ABI（X ABI P2 完成后）
- capture 借用分析需要 region 推断（与 `type-region-v1-rfc.md` 同期）
- 自举前 SHUX 自身代码不依赖闭包（现有 std/fs/net 等都用 C-style `*u8` 函数指针）

### 5.3 长期（自举完成后）

立项 `lang-closure-v1-rfc.md` RFC，明确：
- 语法选择（A/B/C 三选一）
- capture 默认策略（by-value 优先 / by-ref 显式标注）
- 与 Linear(T) / owned(T) 的 move 语义
- 与 region 推断的交互
- CTFE 范围（仅 `'static` capture / 全 capture）

RFC 通过后再按 Wave 1-5 顺序推进。

---

## 6. 本波结论与决策点

| 项 | 决策 |
|----|------|
| **本日启动 closure？** | ❌ 不启动。前置 4 波工程，本日时间不足以 Wave 1 |
| **下一波前排调整** | ✅ C5 EXPR_CLOSURE 顺延至自举后；下一波转向 EXPR_TERNARY / EXPR_IF / EXPR_BLOCK 三个小 fold 扩展 |
| **是否立项 RFC？** | ⏳ 暂不立项。自举完成后再立 `lang-closure-v1-rfc.md`，避免分散精力 |
| **是否更新 cap-candidates？** | ✅ C5 子项「closure / lambda CTFE」标注「前置依赖 4 波基建，顺延自举后」 |
| **L4 真冷全测？** | ✅ 见独立决策（下方 §7） |
| **Windows 门禁？** | ❌ C5 fold 波非 ABI / 非 link 改动，Windows 门禁按规则可推迟至下一波 ABI/link 大改 |

---

## 7. L4 真冷全测决策（独立项）

**触发条件回顾**（[AGENTS.md](../AGENTS.md) 执行纪律）：

> 日终兜底（当天动过产品面却未 L4）

**本日（2026-07-19）已动过的产品面波**：
- `229708f1` C5 EXPR_MATCH CTFE（pipeline_glue.c + seed 镜像）
- `a8a67708` C5 EXPR_STRUCT_LIT 字段 CTFE 扩全（pipeline_glue.c + seed 镜像）
- `d7a2388e` C5 EXPR_ENUM_VARIANT CTFE（pipeline_glue.c + seed 镜像 + active_module getter）

三波均**触达 pipeline_glue.c + seed 副本**（产品面；Darwin filtered pipeline 下 seed 弱版是真实生效路径），但仅做 L2 日常验证（rm .o + make + g05 relink + lang-const + 矩阵）。**未做 L4 真冷全测**。

**决策**：**本波 scoping 完成后立即跑日终 L4 真冷全测**（mac + Ubuntu 双端）。

- mac：`rm compiler/compiler/*.o compiler/std/*.o compiler/core/*.o` + `make` 重建 `shux`/`shux_asm`/`shux-c`/`bootstrap_shuxc` + `bootstrap-driver-seed` + g05 → `run-all-bstrict`
- Ubuntu：`git pull` → 同上 + g05 → `run-all-bstrict`
- 验收：双端 `run-all-bstrict OK (125 scripts)` exit=0；lang-const 14/14

**升钉**：若双端 L4 全绿，可考虑升钉 `5cc73d54` → 新 tip（含本日 3 波 C5 fold + scoping 文档）；若升钉需同步更新 [自举进度.md](自举进度.md) §2.1 / §6。

**Windows 门禁**：本日 3 波均非 ABI / 非 link 改动（CTFE fold 在 typeck 期，emit 路径仅 `mov imm` 替换 cmp/jmp 分发），按 [Windows兼容时序-删种子前后.md](Windows兼容时序-删种子前后.md) §5.1 策略可推迟至下次 ABI/link 大改（C6 X ABI P0b 推进或删种子阶段触发）。

---

## 8. 权威锚点

- 类型系统：[compiler/include/ast.h](../compiler/include/ast.h):24-41 (TypeKind) / :56-115 (ExprKind)
- 函数指针现状：[compiler/src/runtime_driver_abi_thin.x:50](../compiler/src/runtime_driver_abi_thin.x) `shux_driver_call_fn_void_arg`
- FFI callback RFC：[std-ffi-struct-callback-v1.md](std-ffi-struct-callback-v1.md)（FFI 路径，非语言闭包）
- 本 Cap 来源：[.trae/documents/cap-candidates-2026-07-19.md:151-163](../.trae/documents/cap-candidates-2026-07-19.md) C5 子项
- 当前 fold 状态：[compiler/pipeline_glue.c:13541-13622](../compiler/pipeline_glue.c) (whitelist) / :13709-14276 (fold handlers)
- 本日 tip：`d7a2388e`（C5 EXPR_ENUM_VARIANT CTFE 收口）
