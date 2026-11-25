# Win tip L2 hello XP008 array let type（刀 11.61）· **CLOSE ACCEPT**

> Gate：`tests/run-win-tip-l2-hello-xp008-array-let-type-gate.sh` → **OK**。
> Beat：`win_tip_l2_hello_xp008_array_let_type`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59／**11.60** 绿族勿 regress。
> 禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE **`453c9b1e…`**（pre **`69032ad2…`**／pre a16d6822）。

## DIG（纠正）

- 表象：top-level `let x: [N]T = […];` parse skip＠0；scalar let／`type A=[N]T`／fn-local array let OK。
- Soft Cap Prefer（`w2060_bak`）array-lit let EXIT0；tip≠SC。
- **真根**：array **type** 注解 tip 已通（`let x: [4]i32 = 0` EXIT0）；失败在 top-level **array-lit primary**。
- tip `__stale_prim_parser_asm_primary_array_x_into_c`＠`0x1405e4d48`＝`e9`→`primary_suffix_loop`（不消费 `[`）；SC 有 live `parser_asm_primary_array_x_into_c`（≈0x5d8）。
- fn-local 走 `body_let_bracket_compound_init` 旁路故绿；top-level expr→`parse_primary_into_slice`→stale parse_primary→坏 trampoline。
- XP008＠win32:1048＝`let io_fixed_ptr: [8]*u8 = [];`／`io_fixed_len: [8]usize = […]`。

## 修（tip-only）

- 既有种子 `compiler/seeds/win_tip_pe_overrides/stale_primary_array_x_into_override.c`（刀 11.45 ABI twin）。
- 新 inject：`compiler/scripts/win_tip_pe_inject_primary_array_override.py` PLACE4 **`0x140647C20`**（11.60 PLACE3 后零洞）。
- host-gcc → tip cave；stub＠`0x1405e4d48`→`e9` live＠PLACE4；payload `0x1f0`；**无 Soft Cap 字节拷**。

## 验收

- Gate OK：`let_arr`／allow1／param_ctx。
- tip：`let_arr`／`const_arr`／empty `[]`／`[8]*u8`／usize 表／fn_prefix／let_i32／type_only／allow1／param_ctx `-c` OK。
- win32／hello：原＠1048 清；**新残** XP008＠win32 **`io_read_batch_buf`**≈byte **5774**（`bufs: *IoBatchBuf` user-struct **ptr** 形参；值参 OK）→移交 **11.62**。
- backend 同形 `*IoBatchBuf` 残（非 11.60＠952 regress）。

## Residual（移交 11.62）

- hello／win32／backend XP008＠`*IoBatchBuf` 形参 parse skip；L2 1/5＠`58e34910f`；PE `453c9b1e…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48–11.60；CloudAgent；CheckSubscriptionUsage。
