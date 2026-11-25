# Win tip L2 hello XP008 std.context parse（刀 11.64）· **CLOSE residual HOLD**

> Gate：`tests/run-win-tip-l2-hello-xp008-std-context-parse-gate.sh`（HOLD exit2 until context green）。
> Beat：`win_tip_l2_hello_xp008_std_context_parse`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59–**11.63** 绿族勿 regress。
> tip PE **`6772521c…`**（unchanged；无 tip PE 修）。

## DIG（诚实）

- hello XP008「parse skip＠≈1973／2059 name=background」＝**dep prerun 包装**；直接 `check std/context/context.x` 真残＝**T001** `struct 'CtxNode' field 'values' has unknown or invalid type size`（Soft Cap Prefer `check` OK）。
- 隔离矩阵（tip vs Soft Cap Prefer 只读）：
  - `struct S { xs: i32[8]; }`／`u8[8]`／`*Slot`／`Slot[]` 字段：**tip OK**
  - `struct S { s: Slot; }`／`Slot[N]` 字段／`CtxNode.values: CtxValueSlot[8]`：**tip T001**；SC OK
  - `let g: Slot[N] = []`／单 struct Slot：**tip OK**
  - `Slot { a: … }` struct lit：**tip parse skip**（旁注；非本刀足够 plant）
- 真根粒＝**嵌套 user-struct 值字段**（named struct as value field / array-of-named field 依赖其 size）→ layout metrics `glue_type_size_simple` 对字段 type_ref 得 0；非 `std.context` 文本＠1973／2059 本身，亦非 11.63 postfix_slice regress。
- Prefer peel：tip `T_metrics`→`W_size` 有 `name_eq`＋`size_from_layout`；未见本刀可注的 tip-peel **e9 误线／缺 live twin**（对比 11.59–11.63 类 stub）。**无诚实 tip-only 小修靶** → residual HOLD。
- 旁注：win32／backend `bufs.ptr`／batch_buf T001 族；param 值参字段 unknown field；L2 未重跑。

## 修

- **无 PE 修**；未 Soft Cap 混 tip；未动 11.59–11.63 plants。

## 验收

- gate64 HOLD exit2（context 仍 T001）；11.63 slice／11.62 ptr／array-let 夹具不 regress。
- 移交 **11.65** nested named struct field size／T001。

## Residual（移交 11.65）

- tip nested `struct Outer { inner: Inner; }`／`T[N]`-of-named 字段 → T001 bad size；hello XP008／context 同残；PE `6772521c…`；L2 1/5＠`58e34910f`；P012 未新开。

## 非目标／禁

- Soft Cap G05 混 tip；假绿／CloudAgent；升钉／tiphead；回滚 11.48–11.63。
