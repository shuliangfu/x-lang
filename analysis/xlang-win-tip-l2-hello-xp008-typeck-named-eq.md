# Win tip L2 hello XP008 typeck named eq（刀 11.69）

> Gate：`tests/run-win-tip-l2-hello-xp008-typeck-named-eq-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_typeck_named_eq`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.59–**11.68** 绿族／HOLD 勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 起点 **`059417e5772c…`**（post-11.67；11.68 无修）。

## 从 11.68 继承

- context／hello 真残钉＝tip typeck **TYPE_NAMED／`*UserStruct` return／field**（SC OK；`*i32` tip OK）。
- 11.67 wrap 保留（nested T001＝0）；A_val 为 NAMED 旁退（勿回滚 wrap 冒充修）。
- parse skip＠1973／2059＝dep 包装（非文本根）。

## 本刀 DIG／修靶

1. DIG tip-local：`type_refs_equal_named`／`type_refs_equal_impl`／`field_layout_named`／`field_known_ptr` vs Soft Cap Prefer（只读）；是否 stale e9／缺 live／ABI。
2. 诚实 tip-only 小修若证据够；否则 residual HOLD＋OPEN 下一粒。
3. 验收：`id(x:A):A`／`id(p:*A):*A`／`ctx_ptr`／field 进一格或诚实新残；保 11.67 nested／slice／`*IoBatchBuf` param／array-let greens。

## Residual（开刀时）

- context `ctx_ptr` XT001；hello XP008；user-struct field T001；L2 1/5＠`58e34910f`；PE `059417e5…`；P012 未新开。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；CloudAgent；假绿；CheckSubscriptionUsage 空转。
