# Win tip L2 hello XP008 nested named struct field（刀 11.65）

> Gate：`tests/run-win-tip-l2-hello-xp008-nested-named-struct-field-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_nested_named_struct_field`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59–**11.64** 绿族／HOLD 文档勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE **`6772521c…`**（本刀无 PE 修；与 11.63／11.64 同）。

## CLOSE residual HOLD（11.65）

- 表象：hello／`std.context` XP008 parse skip＝dep 包装（11.64）。
- 真残钉死：**T001** nested named **value** field（`S { s: Slot }`／`Slot[N]` field／`Empty` field／`CtxNode.values`）。
- tip 矩阵（p1165）：FAIL nested／arr_named／empty_field＝T001；OK slot／ptr_named／slice_named／only_i32／ret_slot／param_slot／slice_ret；Soft Cap Prefer nested OK。
- 绿族未 regress：gate63／62／61 OK。
- 源／tip 对照：`typeck` metrics→W_size＠`0x140278dc6`；named 臂 kind==8→name_eq＋`size_from_layout`＠`0x140212b41`→metrics；miss／fallback **return 4**；非 named 末臂 **return 0**→T001。
- tip gdb 无法 insert W_size／T_size／bad_size BP（string table／Cannot access；`.c63slc` 后 nm 亦坏；SC Prefer gdb OK）。
- **无诚实 tip-only 可注 stub**：未钉死 kind≠8 vs `size_from_layout`→0 vs `is_empty` 哪条；禁 Soft Cap 混 tip／假绿。
- 移交 **11.66** tip-local DIG probe（field type_ref kind／size_from_layout／is_empty）。

## DIG 证据（本刀）

1. Soft Cap Prefer 只读：nested W_size ty=3 depth=1×2→OK；tip 同 fixture T001。
2. tip W_size named 臂与 SC 同构（含 size_from_layout／fallback 4）；T001 ⇒ 实跑返回 0（kind 非 8／array esize0／layout metrics 失败）或 Empty＋is_empty=0。
3. `*Slot`／`Slot[]` 字段 OK（不经 named value size）；单 Slot 布局校验 OK（字段 i32）。
4. next_field_offset_ex 有 fsize==0→4 软填，**不**经 typeck T001 路径；metrics 仍严判。

## Residual（关刀时）

- tip nested named value field T001；hello XP008／context；win32 batch 旁注；L2 1/5＠`58e34910f`；PE `6772521c…`；tip gdb BP 插入失败（DIG 债）。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48–11.64；CloudAgent；CheckSubscriptionUsage；假绿。
