# Win tip L2 hello XP008 nested named DYN kind（刀 11.67）

> Gate：`tests/run-win-tip-l2-hello-xp008-nested-named-dyn-kind-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_nested_named_dyn_kind`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59–**11.66** 绿族／HOLD 勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 起点 **`6772521c…`**（post-11.63；11.64–11.66 无 PE 变）。

## 从 11.66 继承

- T001 根＝field type_ref **kind=17（TYPE_DYN）** 非 NAMED=8；size 路径＝`typeck_x_type_size`＠`0x140441758` via metrics＠`0x140442fdd`。
- tip 缺 ko==17 size 臂；is_empty 仅 ko==8；SC check nested OK（无 17）。
- 禁用 fallthrough→4／ko17→16／dyn→named 假绿产品注。

## 本刀 DIG／修靶

1. DIG tip-only：为何 `Slot`／`Empty` 字段 type_ref 呈 TYPE_DYN——`wrap_registered_trait_as_dyn`／`xlang_skip_trait_is_registered_c`／layout field type_ref 槽／`pipeline_type_kind_ord_at` 读口；对照 SC。
2. 诚实 tip-only 小修若钉到可注（假注册／错 wrap／错序）；否则 residual HOLD＋OPEN 下一粒。
3. 验收：`S { s: Slot }` kind=8 且过 T001，或诚实新残；保 11.63–11.61；**勿**仅补 size(17)=16 冒充 ACCEPT。

## Residual（开刀时）

- tip nested named value field T001（kind=17）；hello XP008／context；L2 1/5＠`58e34910f`；PE `6772521c…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48–11.66；CloudAgent；CheckSubscriptionUsage；假绿。
