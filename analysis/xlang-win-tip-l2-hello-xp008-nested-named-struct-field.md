# Win tip L2 hello XP008 nested named struct field（刀 11.65）

> Gate：`tests/run-win-tip-l2-hello-xp008-nested-named-struct-field-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_nested_named_struct_field`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59–**11.64** 绿族／HOLD 文档勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 起点 **`6772521c…`**（post-11.63；11.64 无 PE 变）。

## 从 11.64 继承

- hello／`std.context` 表象 parse skip＠1973／2059＝dep 包装；真残＝**T001** `CtxNode.values`（`CtxValueSlot[8]`）。
- DIG：tip 不能 size **嵌套 user-struct 值字段**（`S { s: Slot }`）；`*Slot`／`Slot[]`／builtin 数组字段／单 Slot／`let Slot[N]` OK；SC Prefer OK。
- 11.64 无 tip-peel e9 靶 → residual HOLD；本刀继续 tip-only DIG／小修若证据够。

## 本刀 DIG／修靶

1. DIG tip-only：nested named field type_ref／layout metrics／`glue_type_size_simple` named 臂（vs Soft Cap Prefer 只读）；勿混 tip。
2. 诚实 tip-only 小修若钉到可注 stub／twin；否则再 residual HOLD＋OPEN 下一粒。
3. 验收：`S { s: Slot }`／context `CtxNode` 过 T001 或诚实新残；保 11.63–11.62／array-let；拒假绿。

## Residual（开刀时）

- tip nested named value field T001；hello XP008／context；win32 batch 旁注；L2 1/5＠`58e34910f`；PE `6772521c…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48–11.64；CloudAgent；CheckSubscriptionUsage。
