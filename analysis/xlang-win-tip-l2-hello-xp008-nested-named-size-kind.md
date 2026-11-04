# Win tip L2 hello XP008 nested named size／kind（刀 11.66）

> Gate：`tests/run-win-tip-l2-hello-xp008-nested-named-size-kind-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_nested_named_size_kind`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59–**11.65** 绿族／HOLD 勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE **`6772521c…`**（本刀无 PE 修；与 11.63–11.65 同）。

## CLOSE residual HOLD（11.66）

- **真残钉死**：nested named value field 的 tip `type_ref` kind＝**17（TYPE_DYN）**，不是 8（TYPE_NAMED）。
- tip 产品 size 路径＝**`typeck_x_type_size`＠`0x140441758`**（经 **`typeck_struct_layout_metrics`＠`0x140442fdd`**），**不是** 先前以为的 W/T/t `glue_type_size_simple`（int3 证明 W／T_metrics／t_metrics／t_size **未命中**；bad_size＠`0x1401b1914`／typeck metrics **命中**）。
- `typeck_x_type_size` 对 ko∉已知表 **fallthrough return 0**＠`0x140441a13` → metrics T001；**无 ko==17 臂**（living `runtime_pipeline_abi` F7：`ko==17→16`；tip `typeck_gen.c` 亦缺）。
- `typeck_type_is_empty_struct` **要求 ko==8**；Empty 若呈 DYN 则 is_empty=0。
- 探针：fallthrough→4／force kind=8／stub `pipeline_type_kind_ord_at`→8／dyn→named／ko17→16 均可清 fixture T001；**无一可诚实产品注**——(a) return4／force8 掩盖错 kind；(b) ko17→16 对齐 living DYN 肥指针，但会把误标 DYN 的 `Slot`／`Empty` 做成 16B（≠ SC 真布局）；(c) dyn→named 对真 `dyn Trait` 错误。
- Soft Cap **check** nested OK（同构 size 开关亦无 0x11）⇒ SC **不**把 Slot／Empty 打成 17；假 DYN／kind 序根在 tip 上游（wrap／reg／type 槽），非本刀可注 size 小修。
- **无 PE 修**；PE `6772521c…`；移交 **11.67** DIG kind=17 来源。

## DIG 证据（本刀）

1. int3：W_size／T_metrics／typeck_metrics(thin)／t_metrics／t_size **不**进 nested T001；`typeck_struct_layout_metrics` T＠`0x140442fdd`＋bad_size **进**。
2. size 调用＝`typeck_x_type_size`＠`0x140441758`（非 W＠`0x140278dc6`）；stub 整函数→4 则 nested／empty／arr_named OK。
3. kind 扫描：fallthrough 仅当 **kind==0x11(17)** 时 nested／empty 可被「return4」救起；named 臂 cmpl$8 到达后 jne→fallthrough。
4. Force kind=8 后走 named→`find_layout`＋`size_from_layout`＠`0x140212b41` 成功（名仍为 Slot／Empty）⇒ 类型槽有名＋布局，**kind 字节／序为 17**。
5. sfl stub→4 **不能**单独清 T001（未进 named 臂）；先前 11.65 归咎 W_size／sfl＝路径误判。
6. gate63／62 fixture（slice_ret／`*IoBatchBuf`）与单 Slot 仍 OK；PE 已从 bak 恢复 `6772521c…`。

## Residual（关刀时）

- tip nested／arr_named／empty_field T001；field type_ref **kind=17 DYN**；hello XP008／context；L2 1/5＠`58e34910f`；PE `6772521c…`；tip gdb BP 债仍在。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48–11.65；CloudAgent；CheckSubscriptionUsage；假绿；把 ko17→16／fallthrough→4 当产品 ACCEPT。
