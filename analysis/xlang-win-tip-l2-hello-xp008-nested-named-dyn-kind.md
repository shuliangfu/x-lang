# Win tip L2 hello XP008 nested named DYN kind（刀 11.67）

> Gate：`tests/run-win-tip-l2-hello-xp008-nested-named-dyn-kind-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_nested_named_dyn_kind`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59–**11.66** 绿族／HOLD 勿 regress。
> **CLOSE ACCEPT**；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE **`059417e5772c…`**（pre `6772521c…`）。

## 从 11.66 继承

- T001 根＝field type_ref **kind=17（TYPE_DYN）** 非 NAMED=8；size 路径＝`typeck_x_type_size`＠`0x140441758` via metrics＠`0x140442fdd` fallthrough0。
- 禁用 fallthrough→4／ko17→16／dyn→named 假绿产品注。

## DIG（诚实根因）

- tip IDENT type-ref 解析尾 **无条件** `call` trampoline＠`0x1405c7b00` → `alloc_dyn`＠`0x1405c78d0`（caller＝`0x1405cb172`＋死 helper＠`0x1405c3ea4`）。
- Living `parser_asm_wrap_registered_trait_as_dyn_into_c` 先 `kind==NAMED`＋`xlang_skip_trait_is_registered_c` 再 alloc_dyn；tip 上 `trait_is_registered`＠`0x140604513` **零 E8/E9 代码引用**（死符号），故一切 named（含 `Slot`／`Empty`）被打成 TYPE_DYN。
- Soft Cap Prefer 保 trait 门（nested check OK）；**未** Soft Cap 混 tip。
- Probe：跳过 `0x1405cb172` wrap → nested／empty／arr 立即绿（证实根因＝无条件 wrap，非 size 缺臂）。

## ACCEPT 修（tip-only）

- Inject：`compiler/scripts/win_tip_pe_inject_wrap_registered_trait_dyn.py`。
- PLACE cave `0x140647bb0`（11.60 allow_padding 与 11.61 primary_array 之间零隙；stub 105B ＜ limit `0x140647c20`）。
- 活体对齐 stub：kind_ord→name_into→trait_is_registered→（注册则）alloc_dyn，否则返回 named_tr。
- Retarget trampoline `0x1405c7b00` E9 → cave（两处 caller 同获门控）。
- **未**改 kind／size fallthrough／假绿。

## 验收

- gate67 nested／slice_ret／*IoBatchBuf OK；empty_field／arr_named OK。
- gate63／62／61／60／59／56／55 绿未 regress。
- `tests/boundary/dyn_builtin.x` tip check 仍 0（Clone 注册路径仍 wrap）。
- L2 仍 **1/5**＠`58e34910f`（rv=42；hello/opt/si/f32 基线红未抬）。
- context.x：T001 nested size **已清**；新残＝`ctx_ptr` return type mismatch（移交 11.68）。

## Residual（关刀后）

- hello／std.context：`ctx_ptr` 返回类型 mismatch；hello `-c` 仍 segfault（与 bak 同形）。
- L2 1/5＠`58e34910f`；PE `059417e5…`。
