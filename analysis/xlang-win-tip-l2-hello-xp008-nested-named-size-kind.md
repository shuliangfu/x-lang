# Win tip L2 hello XP008 nested named size／kind（刀 11.66）

> Gate：`tests/run-win-tip-l2-hello-xp008-nested-named-size-kind-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_nested_named_size_kind`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59–**11.65** 绿族／HOLD 勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 起点 **`6772521c…`**（post-11.63；11.64–11.65 无 PE 变）。

## 从 11.65 继承

- T001 nested named value field 钉死；`*Slot`／`Slot[]`／单 Slot OK；SC Prefer OK。
- tip W_size＠`0x140278dc6` named 臂应 ≥4；实跑 fsize=0。
- tip gdb 无法 break W_size／bad_size（PE dig 债）；须 tip-local DIG twin／probe 或其它 tip-only 读路径。

## 本刀 DIG／修靶

1. DIG tip-only：field `type_ref` kind（是否 8）／`size_from_layout` 返回／`glue_type_is_empty_struct_c`（Empty 例）；允许 tip-local DIG twin（写文件／不假绿），禁 Soft Cap 字节混 tip。
2. 诚实 tip-only 小修若钉到可注 stub；否则再 residual HOLD＋OPEN 下一粒。
3. 验收：`S { s: Slot }`／context 过 T001 或诚实新残；保 11.63–11.61／array-let／slice／`*IoBatchBuf`。

## Residual（开刀时）

- tip nested named value field T001；hello XP008／context；tip gdb BP 插入失败；L2 1/5＠`58e34910f`；PE `6772521c…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48–11.65；CloudAgent；CheckSubscriptionUsage。
