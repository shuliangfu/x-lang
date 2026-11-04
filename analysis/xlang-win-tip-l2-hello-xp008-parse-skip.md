# Win tip L2 hello XP008 parse skip（刀 11.60）

> Gate：`tests/run-win-tip-l2-hello-xp008-parse-skip-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_parse_skip`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／**11.59** 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／exit0 空 .o。
> tip PE：**`a16d6822…` → `686f8cd6…`（skip_one）→ `69032ad2…`**（allow）。

## 从 11.59 继承

- named_type_x tip-local live＋stale→e9 ACCEPT；param_ctx／param_S 无 P012。
- hello／L2 hello 仍 **XP008**：`dep prerun failed` → `parse skip`＠`std.io.backend` byte 952。
- IF／match10／11.55／11.56 OK；PE `a16d6822…`。

## DIG（本刀）

1. tip hello → XP008＠`std.io.backend`＠byte **952**：inactive `#[cfg]` 后 `const`／`let` — tip `parser_asm_skip_one_top_level_{const,let}_into_c` W＝`e9`→`parser_asm_lex_step_kind_c`（只吃一 token）；产品体 `pthin_body_tl.x` 要 skip 到 `;`。
2. tip-local C twin＋inject PLACE2 `0x140647AA0`（cave after 11.59 `0x140647800` last_nz `0x2a0`）：const stub `0x140630D5C`→`0x140647AFF`；let stub `0x140630D54`→`0x140647AA0`。PE→`686f8cd6…`。
3. 再验：backend＠952 清；hello XP008 迁到 `std.io.win32`＠byte **890** `allow(padding) struct IoBatchBuf`。
4. 同形：`parser_asm_try_skip_allow_padding_into_c`＠`0x140635000` W＝`e9`→`lex_step_kind`；`skip_balanced_parens_into_c` tip **live**（非 miswire）。
5. tip-local C twin＋inject PLACE3 `0x140647B60`（+0xc0）；stub→live。PE→**`69032ad2…`**。allow1／allow2／w2（至 export const）OK。
6. Soft Cap Prefer：inactive cfg／allow 对照＝tip≈SC Prefer（只读；**无** Soft Cap 字节拷贝）。array `let` tip 残＝**pre-1160 已有**（bak_pre_1160 同 fail）。

## Plant

- `compiler/seeds/win_tip_pe_overrides/skip_one_top_level_const_let_override.c`
- `compiler/scripts/win_tip_pe_inject_skip_one_tl_const_let_override.py`
- `compiler/seeds/win_tip_pe_overrides/try_skip_allow_padding_override.c`
- `compiler/scripts/win_tip_pe_inject_try_skip_allow_padding_override.py`

## CLOSE ACCEPT

- tip-only 两粒 skip 空心修通：cfg-const／let＋allow(padding)。
- Protect：param_ctx／param_S `-c` nonempty；IF_min／match10／vlet／11.55／11.56／11.59 gates OK；rv=42；f32 run139；**无 Soft Cap G05**。
- hello 仍 XP008＠`std.io.win32`＠byte **1048**＝top-level **`let`＋array type** `[N]T`（`let_arr_i32`／`io_fixed_ptr`）；移交 **11.61**。
- 闸位 HOLD；**勿假绿**；L2 **1/5**＠`58e34910f`（rv 保）。

## Residual（移交 11.61）

- tip top-level `let x: [N]T = …` parse skip＠0（scalar let OK）；win32／hello XP008＠1048。
- backend 另有更深 skip＠3099／3206（本刀非靶）。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48／11.55／11.56／11.59；CloudAgent；CheckSubscriptionUsage；杀另账号 xlang(check)。
