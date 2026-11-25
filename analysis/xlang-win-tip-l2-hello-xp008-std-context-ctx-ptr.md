# Win tip L2 hello XP008 std.context ctx_ptr（刀 11.68）· **CLOSE residual HOLD**

> Gate：`tests/run-win-tip-l2-hello-xp008-std-context-ctx-ptr-gate.sh`（HOLD exit2 until context green）。
> Beat：`win_tip_l2_hello_xp008_std_context_ctx_ptr`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59–**11.67** 绿族勿 regress。
> tip PE **`059417e5772c…`**（unchanged；无 tip PE 修）。

## DIG（诚实）

- hello XP008「parse skip＠≈1973／2059 name=background」＝**dep prerun 包装**（同 11.64）；直接 `check std/context/context.x` 真残＝**return expression type mismatch** ＠`ctx_ptr`（XT001 fn#8）；Soft Cap Prefer `check` OK。
- 诊断噪声：`expected * { i, found *; }`＝fmt 把函数体 `{`／`if` 拼进 expected／found（非结构字面量根因）。
- 隔离矩阵（tip plant `059417e5…` vs bak_pre_1167 `6772521c…` vs Soft Cap Prefer 只读）：
  - `*i32` id／cast：**tip OK**
  - `id(x: A): A { return x; }`：**bak OK**／**tip FAIL**（11.67 wrap 后 TYPE_NAMED 路径；unconditional `alloc_dyn` 复现 bak 则 A_val 回绿但 nested size 回红）
  - `id(p: *A): *A`／`h as *A`／`0 as *A`／`ctx_ptr`：**tip+bak FAIL**；SC OK（`*Named` return／cast 为 tip 预存残，非 11.67 新引入）
  - `p.a`／`x.a` user-struct field：**tip+bak T001 unknown field**；SC OK（与 11.62 旁注 win32 `bufs.ptr` 同族）
  - nested size-only／gate67／63／62／61：**tip OK**（勿 regress）
- 真根粒＝**tip typeck 对 TYPE_NAMED／`*UserStruct` 的 type_refs_equal／field_layout 与 Soft Cap 不对齐**（SC 有 `typeck_type_refs_equal_named`／`typeck_field_layout_named`／`typeck_field_known_ptr`）。非 context 文本＠1973／2059；非 11.67 wrap 逻辑错误（nested DYN 门仍必需）。
- Prefer peel：未见本刀可注的 tip-peel **e9 误线／缺 live twin**（对比 11.59–11.67 类 stub）。**无诚实 tip-only 小修靶** → residual HOLD。
- 旁注：11.67 ACCEPT 保留；A_val 为 NAMED vs DYN 权衡下的已知旁退（闸位未覆盖）；禁回滚 wrap／禁 Soft Cap 混 tip。

## 修

- **无 PE 修**；未 Soft Cap 混 tip；未动 11.59–11.67 plants；PE 仍 `059417e5…`。

## 验收

- gate68 HOLD exit2（context 仍 ctx_ptr mismatch）；gate67／63／62／61 OK；nested T001＝0 不 regress。
- 移交 **11.69** tip typeck named eq／`*UserStruct` return／field。

## Residual（移交 11.69）

- tip `*Named`／NAMED return mismatch＋user-struct field T001；hello XP008／context 同残；PE `059417e5…`；L2 1/5＠`58e34910f`；P012 未新开。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；假绿／CloudAgent；升钉／tiphead；CheckSubscriptionUsage 空转。
