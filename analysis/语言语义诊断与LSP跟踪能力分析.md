# 语言语义诊断与 LSP 跟踪能力分析

> **文档目的**：盘点 parser/typeck 语义校验（分号终止、重复定义、未使用警告）与 LSP 编辑器跟踪能力（definition/references/hover）的现状、根因与修复边界；**地图已建，实施默认挂自举后**。
> **交办**：grok（实施窗口见 §0.1 / §5.4，**不抢 residual / pin / BC 主航道**）
> **建立日期**：2026-08-05
> **决策日期**：2026-08-05
> **状态**：**已决策** · 默认 **自举完成后完善** · 仅 D-references 有条件可插队 · **非当前 backlog**
> **配套**：[当前问题分析.md](./当前问题分析.md) · [自举验证.md](./自举验证.md) · [自举方法.md](./自举方法.md) · [自举完成后功能完善及优化时序表.md](./自举完成后功能完善及优化时序表.md)（P2a 语言+诊断） · [自举进度.md](./自举进度.md)

---

## 0. 摘要

四个问题的现状一览：

| 问题 | 现状 | 根因层 | 影响自举 | **时机（已决策）** |
|------|------|--------|---------|-------------------|
| A. 分号 ASI 过度容错 | `return`/`let` 等省分号被接受 | parser | 🔴 高 | **自举后专门窗口** · **现在禁止** |
| B. 重复定义检测 | 参数/字段/局部变量已检测；**模块级函数/变量/类型未检测** | parser/typeck | 🟡 中 | **升钉 / 自举后** · 冲刺期不主动开 |
| C. 未使用警告 | 报告函数已实现，**但无调用点（检测逻辑未接）** | typeck | 🟡 中 | **升钉 / 自举后** · 冲刺期不主动开 |
| D. 变量方法跟踪 | definition 只支持函数；references 有 bug；hover 只返回类型名 | LSP glue | 🟢 低 | **全套完善自举后**；**仅 references 顺序 bug** 可在主航道空窗极小插队 |

**关键结论**：
- A 是 wave361+ 有意引入的 keyword ASI，与设计意图（"只 `}` 结尾可省分号"）冲突，触及 parser 主路径。
- B/C 是"半实现"——部分能力到位但关键链路缺失，修复在 typeck/parser，中等风险。
- D 完全在 LSP glue 层，不影响自举；**但 IDE 体验不挡 pin/L4/BC**，不因「可独立」就抢 residual 带宽。
- C 的"vscode 没波浪线"**不是 LSP 传输问题**，是 typeck 根本没产生未使用诊断。

### 0.1 总决策：现在完善 vs 自举后完善

| 选项 | 结论 |
|------|------|
| **现在全面完善 A–D？** | **否。** 文档当**问题地图 / 交办底稿**，**不当**当前实施 backlog；主航道仍是 **自举 / pin / BC residual / L4 金标**。 |
| **默认完善窗口** | **自举完成后**，挂入 [自举完成后功能完善及优化时序表.md](./自举完成后功能完善及优化时序表.md) **P2a 语言 + 诊断**（及配套 LSP 体验），与产品化/语言债同波收口。 |
| **现在唯一可考虑的代码改动** | **可选**：D 的 **references 收集/定位顺序倒置**（纯 LSP glue、不碰 parser/typeck/IR）。须：**单 commit、不动主路径、双端不扩 scope**；主航道有 pin/BC/L4 任务时 **让路**。 |
| **现在明确禁止** | **A 整批**（parser ASI 收紧 + 存量 `.x` 爆红风险）；**B/C 整批**（typeck/parser 符号与 unused 链路，与 residual 回归面重叠）；**D 的 definition 变量 / hover 签名 / documentHighlight** 等「体验扩面」（自举后一次做全）。 |
| **为何不「现在顺手做 B/C」** | 半实现≠自举阻塞；接 typeck 引用计数或模块级重名会动符号登记与 check 路径，易与 glue 瘦身 / seed 镜像纠缠，**违背「一条债一层一个 commit、不抢 residual」**。 |
| **与假绿纪律** | 本文项 **不** 用 soft-skip / 改测试期望糊绿；实施时按 §5.2 / §7，批 2/3 须 L4（矩阵+bstrict）。**自举期暂停 check 闸门**（2026-08-05）；实施窗口再恢复 bare check 验收。 |

**一句话**：地图写清、时机钉死后，**全面完善在自举后**；现在只保留「D-references 有空可修」的极窄例外，**禁止**把本文件当成冲刺期并行工程轨。

---

## 1. 问题 A：分号 ASI（语句终止过度容错）

### 1.1 现象

`std/async/mod.x` 的 `drain_idle`（[L268-272](../std/async/mod.x#L268)）中 `return _rc` 去掉分号后，`xlang check` 与 LSP 均**不报错**：

```x
export function drain_idle(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_async_run_drain_until_idle(); }
  return _rc        // ← 缺少分号，设计上应报错，parser 接受
}
```

### 1.2 设计意图

**只有以 `}` 结尾的语句/声明可省分号**；其余语句（`return` / `let` / `const` / 表达式语句 / `break` / `continue` / `goto` / `panic` / `defer` 等）必须以 `;` 终止。

允许省分号（以 `}` 结尾）：块语句 `{ ... }`、`unsafe { ... }`、`if/while/for/loop/match (...) { ... }`、`struct/enum/type` 声明、`function` 定义、`impl/trait/region` 块。

### 1.3 根因

**ASI 权威实现** [parser_asm_helpers_slice.inc:345-365](../compiler/seeds/parser_asm/parser_asm_helpers_slice.inc#L345) — `parser_asm_advance_past_stmt_semicolon_into_slice_c`：

```c
if (r_out->tok.kind == TOKEN_SEMICOLON) return 1;           // 有分号：OK
if (parser_asm_ident_is_unsafe_stmt_slice_c(...)) return 1;  // unsafe block：OK
k = r_out->tok.kind;
if (k == TOKEN_LET || k == TOKEN_CONST || k == TOKEN_RETURN ||
    k == TOKEN_IF || k == TOKEN_WHILE || k == TOKEN_FOR ||
    k == TOKEN_RBRACE || k == TOKEN_IDENT || k == TOKEN_BREAK ||
    k == TOKEN_CONTINUE || k == TOKEN_MATCH || k == TOKEN_LOOP ||
    k == TOKEN_PANIC || k == TOKEN_DEFER || k == TOKEN_GOTO ||
    k == TOKEN_STAR || k == TOKEN_SELF)
  return 1;                                                  // keyword ASI：下一 token 是这些即省分号
```

注释证据（[L342-343](../compiler/seeds/parser_asm/parser_asm_helpers_slice.inc#L342)）：

```
// parse ASI; docs/08 still recommends `;` mid-block;
// product accepts keyword ASI (wave361+) and IDENT/control heads here.
```

→ **wave361+ 有意引入**的 keyword ASI，非意外 bug。

**parser.x block 内终止判定**：十几处用 `tok != SEMICOLON && tok != RBRACE` 作"未终止"判据，把 `}` 当通用终止符：[2479](../compiler/src/parser/parser.x#L2479)/[2488](../compiler/src/parser/parser.x#L2488)（return）、[2551](../compiler/src/parser/parser.x#L2551)、[5777](../compiler/src/parser/parser.x#L5777)/[6074](../compiler/src/parser/parser.x#L6074) 等。

### 1.4 实测复现

```bash
# 最小用例 /tmp/test_semi.x：
#   export function f_a(): i32 { return 1 }      ← 不加分号
#   export function f_c(): i32 { let x: i32 = 1; return x; }  ← let 不加分号
./compiler/xlang check /tmp/test_semi.x
# 结果：Case A/C 不报错（应报错），Case B（return 1;）通过
```

### 1.5 修复方向

- ASI 权威：移除 keyword 列表 + `TOKEN_RBRACE` 作为省分号理由；保留 `;` 与 unsafe block 识别；补"语句以 `}` 结尾"的识别（block/if/while/for/match/loop 等控制流，确认其 `}` 已消费后允许无分号）。
- parser.x：`return`/`let`/`const`/表达式语句等"必须分号"语句的 `!= SEMI && != RBRACE` 改为 `!= SEMI`。
- seed 与逻辑源同 commit 同语义（G.7/G.4）。

### 1.6 风险

🔴 高。触及 parser 主路径（typeck/IR/codegen 全依赖 AST）；存量 `.x` 源码可能依赖省分号写法，收紧后批量爆红。**已决策：现在禁止；自举完成后专门窗口**（见 §0.1 / §5.4 D2）。

---

## 2. 问题 B：重复定义检测

### 2.1 已实现 ✅

| 范围 | 层 | 诊断 | 证据 |
|------|----|------|------|
| 函数参数重名 | parser | P012 | [parser.x:5592-5597](../compiler/src/parser/parser.x#L5592) — `parser_report_duplicate_name_p012_c` |
| struct 字段重名 | parser | P012 | [parser.x:8751](../compiler/src/parser/parser.x#L8751) / [10908](../compiler/src/parser/parser.x#L10908) |
| 同 block let/const 重声明 | typeck | BLD001 | [typeck.x:9248-9264](../compiler/src/typeck/typeck.x#L9248)（const）/ [9338-9354](../compiler/src/typeck/typeck.x#L9338)（let）— `driver_diagnostic_typeck_duplicate_local` + `pipeline_block_local_name_redecl_c`（wave680） |

### 2.2 未实现 ❌

| 范围 | 现状 | 证据 |
|------|------|------|
| 模块级 function 重名 | 静默覆盖（后注册覆盖先注册） | grep "duplicate/redef/already defined" 在 parser/typeck 仅命中 param/field/local；模块级函数注册路径无重名检查 |
| 模块级 let/const 重名 | 待确认（很可能未检测） | 同上 |
| type/struct/enum 重名 | 待确认（很可能未检测） | 同上 |

> grok 实施时需在 module 符号注册路径（parser function/decl 定义解析后、`module->num_funcs` 增量处）最终确认，并补重名报错。

### 2.3 修复方向

- parser/typeck 在模块级符号注册时检查重名，报 error（建议复用 P012 或新增 `E_DUP_DECL`）。
- 影响面：parser/typeck 符号登记路径，属自举核心但改动局部（注册点加检查），风险 🟡 中。
- 注意：跨 module 的同名（不同文件同名 function）是合法的，**只检测同 module 同作用域重名**。
- **时机**：默认升钉后 / 自举后（P2a）；冲刺期不主动开（§5.4 D3）。

---

## 3. 问题 C：未使用警告

### 3.1 用户观察

"未使用警告已经实现了，但是 vscode 没有报波浪线警告。"

### 3.2 现状：报告函数已实现，检测逻辑未接

**报告函数** [runtime_driver_diagnostic_thin.x:1871-1876](../compiler/src/runtime_driver_diagnostic_thin.x#L1871)：

```x
/** L6 unused-binding hint (info). Message: "unused binding 'name'". LSP severity 3; else */
export function driver_diagnostic_hint_unused_binding(line: i32, col: i32, name: *u8, name_len: i32): void {
  ...
  let at: i32 = driver_diag_append_cstr(&msg[0], 160, 0, "unused binding '");
  ...
}
```

- 消息：`unused binding 'name'`
- severity = 3（Info）—— 注释自承 "LSP severity 3"

**关键缺陷**：grep 全 compiler（`.x`/`.c`/`.h`）排除声明/定义后，**`driver_diagnostic_hint_unused_binding` 没有任何调用点**。即 typeck 没有变量使用追踪逻辑去调用它。报告函数是孤立空壳。

### 3.3 LSP 传输链路（通的，不是根因）

诊断缓冲 `s_diag[]` + `s_diag_count`（[runtime_lsp_glue.from_x.c:152-153](../compiler/seeds/runtime_lsp_glue.from_x.c#L152)）：

- severity 归一化 [L474](../compiler/seeds/runtime_lsp_glue.from_x.c#L474)：`e->severity = (severity == 2) ? 2 : ((severity == 3) ? 3 : 1);` —— 保留 2(Warning)/3(Info)
- 格式化 [L1886-1897](../compiler/seeds/runtime_lsp_glue.from_x.c#L1886)：遍历全部 `s_diag`，输出 `"severity":%d` —— **不过滤 severity**，Info 也会传到 client

→ LSP 链路本身能传 Info 级诊断。**根因不是传输，是检测逻辑没产生诊断**。

### 3.4 根因

typeck 没有"变量使用计数 / 未使用判定"逻辑。`driver_diagnostic_hint_unused_binding` 实现了报告入口，但无人调用。

### 3.5 修复方向

1. typeck 增加变量使用追踪：在 check_block 遍历 expr 时，对 let/const 绑定记录"被引用次数"。
2. block 退出时，对引用次数为 0 的绑定调用 `driver_diagnostic_hint_unused_binding(line, col, name, name_len)`。
3. 确认 LSP 路径（`pipeline_lsp_diag_parse_typeck_buf` / `lsp_diag_run_pipeline_on_buf`）跑同一 typeck，会触发未使用检测。
4. **severity 决策**：当前报告函数硬编码 severity=3 (Info)。VSCode 对 Info 编辑器内波浪线为淡蓝色，若用户期望"警告级黄波浪线"，需将 unused 提升为 severity=2 (Warning)。建议改为 Warning（符合主流语言习惯 + 用户"波浪线警告"预期）。

### 3.6 风险

🟡 中。typeck 主路径增加使用追踪，但属增量逻辑（不改变现有判定），回归面可控。需注意：`_` 前缀绑定（`_rc`）应豁免——这是显式"故意不用"的约定，否则 std/编译器自身源码会批量爆 unused 警告。**时机**：默认升钉后 / 自举后（P2a）；冲刺期不主动开（§5.4 D3）。

---

## 4. 问题 D：变量方法跟踪

### 4.1 Server capabilities

[runtime_lsp_glue.from_x.c:2260-2281](../compiler/seeds/runtime_lsp_glue.from_x.c#L2260) advertise：definition / references / hover / completion / diagnosticProvider(pull) / semanticTokens / rename / documentSymbol / formatting / signatureHelp。

**未 advertise**：`documentHighlightProvider`、`foldingRangeProvider`、`codeLensProvider`、`codeActionProvider`、`workspaceSymbolProvider`。

### 4.2 go-to-definition（半实现）

[lsp_diag_empty_surface.from_x.c:435-505](../compiler/seeds/lsp_diag_empty_surface.from_x.c#L435) — `lsp_diag_definition_at`：

- ✅ 函数定义：遍历 `module->funcs`，用 `lsp_source_find_function_def`（源码文本扫描 `function name`）定位 def 位置
- ✅ 函数调用站点反查：arena exprs 里找 call expr → func_index → 再定位 def
- ❌ **变量（let/const 绑定）不支持**：无 var expr 的定义反查逻辑
- ⚠️ 实现脆弱：靠源码文本扫描 `function ` + name，非 AST 位置权威

### 4.3 references（有 bug）

[lsp_diag_empty_surface.from_x.c:279-345](../compiler/seeds/lsp_diag_empty_surface.from_x.c#L279) — `lsp_diag_references_at`：

```c
int32_t func_index = -1;
int32_t n = lsp_collect_call_refs(arena, func_index, ...);  // ← L294: func_index 还是 -1 就收集
int32_t out_n = n;
...
// 后面才在 arena 里循环定位 func_index（L321-331）
```

**bug**：`lsp_collect_call_refs` 在 `func_index = -1` 时调用（[L294](../compiler/seeds/lsp_diag_empty_surface.from_x.c#L294)），收集在前、定位在后，顺序倒置。结果 `tmp_lines/tmp_cols` 是用 -1 收集的（空或全匹配 fri=-1 的 expr），后面定位到 func_index 也没用。→ **引用跟踪失效**。

### 4.4 hover（半实现）

[lsp_diag_empty_surface.from_x.c:129-255](../compiler/seeds/lsp_diag_empty_surface.from_x.c#L129) — `lsp_diag_hover_at`：

- ✅ 返回表达式类型名（i32/bool/u8/u32/u64/i64/usize/isize/f32/f64/void/`*T`/named type）
- ❌ 不返回函数签名（`fn foo(a: i32, b: i32): i32`）
- ❌ 不返回文档注释（docblock）

### 4.5 documentHighlight（客户端自实现，可用但非语义级）

[documentHighlight.ts:1-10](../editors/vscode/src/documentHighlight.ts#L1) — 注释明确"本地正则实现，不依赖 LSP"：

- ✅ 同文件相同标识符高亮（文本匹配，跳过注释/字符串）
- ⚠️ 非语义级：不区分同名不同作用域变量（如两个函数都有 `i` 局部变量会全部高亮）
- 不依赖 server advertise

### 4.6 修复方向（LSP glue 层，不影响自举）

1. **references bug**：调换 `lsp_diag_references_at` 里收集/定位顺序——先在 arena 找 call expr 的 func_index，再 `lsp_collect_call_refs(arena, func_index, ...)`。
2. **definition 变量支持**：在 `lsp_diag_definition_at` 加 var expr 反查——光标在变量引用上时，定位到其 let/const 声明位置（arena 里有 var expr 的 line/col + 声明信息）。
3. **hover 签名**：光标在函数名/调用上时，返回 `fn name(params): ret` 签名（从 module func 表取参数类型 + 返回类型）。
4. **documentHighlightProvider**：可选——server advertise + 实现 `textDocument/documentHighlight`，做语义级同符号高亮（区分作用域）。或保持客户端正则版。

### 4.7 风险

🟢 低。全在 `compiler/src/lsp/` + `compiler/seeds/lsp_diag*.from_x.c`，不碰 parser/typeck/IR 主路径。**不挡自举 ≠ 现在必做**；全套体验默认自举后；仅 references 顺序 bug 可主航道空窗插队（见 §0.1 / §5.4 D4）。

---

## 5. 综合修复策略与时机

### 5.1 按风险分批（**2026-08-05 决策版**）

| 批次 | 问题 | 风险 | 时机（已决策） | 备注 |
|------|------|------|----------------|------|
| 批 1a（极窄可选） | **仅** D references 顺序 bug | 🟢 低 | **主航道空窗可插队**；有 pin/BC/L4 则 **不做** | 单 commit；禁止顺手扩 definition/hover |
| 批 1b（体验扩面） | D definition 变量 + hover 签名 + 可选 documentHighlight | 🟢 低 | **自举后** 与批 1a 若未做则一并收口 | 不挡自举，但 **不抢 residual** |
| 批 2（中风险） | B 模块级重复定义 + C 未使用警告 | 🟡 中 | **升钉稳定后 / 自举后**（默认挂 **P2a**） | **冲刺期不主动开**；禁止与 glue 瘦身混 commit |
| 批 3（高风险） | A 分号 ASI 收紧 | 🔴 高 | **自举完成后专门窗口** | **现在禁止**；需存量 `.x` 回归矩阵 |

> 旧稿曾写「批 1 随时 / 批 2 冲刺期可做」——**已废止**。见 §0.1 / §5.4。

### 5.2 共同前置

- 每批建 git 锚点（`git stash`/独立分支），小步 commit + 单步全量验证；**一条债一层一个 commit**。
- 批 2/3 改 parser/typeck 后，L4 真冷全测（删 `compiler`/`std`/`core` 下全部 `.o`，重编 `xlang`/`xlang_asm`/`xlang-c`/`bootstrap_xlangc`，`bootstrap-driver-seed` + g05 → 产品矩阵 → 全量 bstrict），双端（macOS + Ubuntu）验证。
- **实施窗口**（自举后或用户重开 check）：仓库根 bare `./compiler/xlang check`（不带路径）须 0 errors。**自举冲刺期（2026-08-05 起）默认不跑 check 闸门**。
- seed 与 `.x` 逻辑源同 commit 同语义；改 seed 后重建对应 `.o` + g05。
- 批 1a 最低闸门：改 LSP seed/glue 后重建相关 `.o` + 产品矩阵可解析路径；**勿**冒充已做 L4 宣称。

### 5.3 与自举的关系

- **主航道优先级**：BC residual / pin / L4 金标（矩阵+bstrict）≫ 本文任何批次；**check 闸门自举期暂停**（2026-08-05）。
- **D 不挡自举** ≠ **现在必须做**；仅 1a 在空窗可修，1b 默认自举后。
- **B/C** 属 typeck/parser 增量，与冲刺期符号表/迁移/回归面重叠 → **默认自举后**；不得以「局部增量」为由插入 residual 波次。
- **A** 触及 parser 主路径 + 全库省分号存量 → **必须自举后专门窗口**；禁止「顺手收紧」。
- 整体推进时：独立波次（如 wave13xx+），**不**与 C 迁移 / typeck 迁移 / glue 吞体 混 commit。
- 时序挂靠：[自举完成后功能完善及优化时序表.md](./自举完成后功能完善及优化时序表.md) **P2a 语言 + 诊断**（references/definition/hover 可同波或紧随 P2a 的 LSP 子项）。

### 5.4 正式决策记录（2026-08-05）

**问题**：本文件四项能力，是**现在完善**，还是**自举以后再完善**？

**结论**：**以自举后全面完善为默认**；现在只维护地图与禁令，**不**把 A–D 拉进 residual 并行轨。

| # | 决策 | 理由 |
|---|------|------|
| D1 | 本文 = **地图 / 交办底稿**，**≠** 当前必须完成的 backlog | 自举主航道带宽有限；IDE/语义体验不阻塞 pin 与冷链 |
| D2 | **A 现在禁止**；窗口 = 自举后 + 存量回归矩阵 | parser 主路径 + keyword ASI 有意引入；收紧会批量爆红 |
| D3 | **B/C 默认升钉后或自举后（P2a）**；冲刺期不主动开 | 半实现不挡自举；接调用点会动 typeck 与 check 路径 |
| D4 | **D 全套体验默认自举后**；**仅 references 顺序 bug** 可空窗插队 | glue 层低风险，但扩面仍耗验证与上下文，让路主航道 |
| D5 | 实施时仍遵守根源治理 / 单权威 / L4 矩阵+bstrict（批 2/3）；check 闸门在**实施窗口**再开 | 禁止 soft-skip、改期望糊绿、双权威 seed 漂移；自举期不绑 bare check |
| D6 | 进度仪表盘不把本文标成「本波必做」 | 避免假进度；真进度仍写 [自举进度.md](./自举进度.md) 的 residual/pin |

**何时重新打开本文实施轨**（满足任一即可排期，仍建议独立波）：

1. **自举完成**（或至少产品 pin 升钉稳定、residual 主债收口）→ 按 P2a 排 B/C，再排 A 专门窗口；D 1a/1b 可同波或先做。
2. **主航道空窗且仅改 LSP** → 可只做 **D-1a references 顺序**，做完即停，不扩 scope。
3. **用户显式点名**「现在修 B/C/A/D-全套」→ 按 §5.2/§7 闸门单开波次，并在本 § 追加决策修订日期。

**明确不做的现在行为**：

- 不在 BC/glue 瘦身 commit 里「顺便」改 ASI / unused / 模块重名。
- 不以 vscode 波浪线缺失为由插入 typeck 大改。
- 不把「D 可独立」解读成「必须现在把 LSP 做到语言服务器级完整」。

---

## 6. 代码位置清单（实施入口）

### 问题 A（分号 ASI）

| 位置 | 作用 | 改动 |
|------|------|------|
| [parser_asm_helpers_slice.inc:345-365](../compiler/seeds/parser_asm/parser_asm_helpers_slice.inc#L345) | ASI 权威 | 移除 keyword 列表 + RBRACE 省分号理由；保留 `;` 与 unsafe block |
| [parser.x:2479-2495](../compiler/src/parser/parser.x#L2479) | return 终止 | `!= SEMI && != RBRACE` → `!= SEMI` |
| [parser.x:2551](../compiler/src/parser/parser.x#L2551) / [5777](../compiler/src/parser/parser.x#L5777) / [6074](../compiler/src/parser/parser.x#L6074) | block 内 stmt 终止 | 核对每处，移除非 `}` 结尾语句的 RBRACE 例外 |
| [parser.x:2738-2801](../compiler/src/parser/parser.x#L2738) / [3369](../compiler/src/parser/parser.x#L3369) / [6257-6290](../compiler/src/parser/parser.x#L6257) | 声明/语句终止 | 核对，确保以 `}` 结尾的声明保留省分号 |

### 问题 B（重复定义）

| 位置 | 作用 | 改动 |
|------|------|------|
| parser function 定义解析后（注册到 module 处） | 模块级函数重名 | 补重名检查 + 报 error |
| parser type/struct/enum 定义解析后 | 类型重名 | 补重名检查 |
| parser 模块级 let/const | 模块级变量重名 | 补重名检查（确认现状后） |
| [parser.x:3626](../compiler/src/parser/parser.x#L3626) | P012 报告函数 | 复用或新增诊断码 |

### 问题 C（未使用警告）

| 位置 | 作用 | 改动 |
|------|------|------|
| typeck check_block（let/const 检查路径，[typeck.x:9240+](../compiler/src/typeck/typeck.x#L9240)） | 变量使用追踪 | 增加引用计数；block 退出时对未使用绑定调报告函数 |
| [runtime_driver_diagnostic_thin.x:1871](../compiler/src/runtime_driver_diagnostic_thin.x#L1871) | 报告函数 | severity 3→2（Info→Warning），符合"波浪线警告"预期 |
| typeck expr 遍历 | 记录变量引用 | 引用时累加计数 |

### 问题 D（跟踪能力）

| 位置 | 作用 | 改动 |
|------|------|------|
| [lsp_diag_empty_surface.from_x.c:279-345](../compiler/seeds/lsp_diag_empty_surface.from_x.c#L279) | references | 调换收集/定位顺序（先定位 func_index 再收集） |
| [lsp_diag_empty_surface.from_x.c:435-505](../compiler/seeds/lsp_diag_empty_surface.from_x.c#L435) | definition | 加 var expr 反查（变量定义定位） |
| [lsp_diag_empty_surface.from_x.c:129-255](../compiler/seeds/lsp_diag_empty_surface.from_x.c#L129) | hover | 加函数签名（从 module func 表取参数/返回类型） |
| [runtime_lsp_glue.from_x.c:2260-2281](../compiler/seeds/runtime_lsp_glue.from_x.c#L2260) | capabilities | 可选补 advertise documentHighlightProvider |

---

## 7. 验证清单（实施后）

### 问题 A
- [ ] `/tmp/test_semi.x` Case A（`return 1` 无分号）报 missing-semicolon
- [ ] Case C（`let x` 无分号）报 missing-semicolon
- [ ] `return 1;` 仍通过
- [ ] `unsafe { ... }` / `if {...}` / `while {...}` 等以 `}` 结尾语句仍可省分号
- [ ] （实施窗口）仓库根 bare `./compiler/xlang check` → 0 errors
- [ ] L4 双端真冷全测绿（矩阵+bstrict；自举期不强制 check）

### 问题 B
- [ ] 同 module 两个 `function foo()` 报重复定义错
- [ ] 同 module 两个 `struct Foo {}` 报错
- [ ] 跨 module 同名 function 不报错（合法）
- [ ] 函数参数/字段/局部变量重复检测仍工作（不回归）

### 问题 C
- [ ] `let x: i32 = 0;` 未使用 → Problems 面板显示 "unused binding 'x'"
- [ ] 编辑器内显示黄色波浪线（severity=2）
- [ ] `let _rc: i32 = 0;`（`_` 前缀）不报警告
- [ ] 被引用的变量不报警告
- [ ] LSP 路径与 CLI `check` 路径都报

### 问题 D
- [ ] 光标在函数调用上 → 跳转到函数定义
- [ ] 光标在变量引用上 → 跳转到 let/const 声明
- [ ] 右键"查找所有引用"返回正确引用列表（非空）
- [ ] 光标在函数名上 → hover 显示 `fn name(params): ret` 签名
- [ ] 光标在变量上 → hover 显示变量类型

---

## 附录 A：documentHighlight 现状

VSCode 扩展有 [documentHighlight.ts](../editors/vscode/src/documentHighlight.ts)，客户端本地正则实现（不依赖 LSP），同文件相同标识符高亮（跳过注释/字符串）。非语义级（不区分作用域）。server 未 advertise `documentHighlightProvider`。若需语义级同符号高亮，需 server 端实现 `textDocument/documentHighlight`（基于 AST 作用域分析）。

## 附录 B：LSP 其他能力速览

| 能力 | 状态 |
|------|------|
| 诊断（pull） | 真实现，覆盖度取决于 parser/typeck |
| completion | 真实现（trigger `. : (`） |
| semanticTokens | 真实现 |
| documentSymbol | 真实现 |
| formatting | 真实现 |
| signatureHelp | advertise 但实现深度未确认 |
| rename | advertise 但实现深度未确认 |
| foldingRange / codeLens / codeAction / workspaceSymbol | 未 advertise（部分客户端自实现） |
