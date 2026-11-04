# Win tip L2 CG002 nonempty array（刀 11.47）

> Gate：`tests/run-win-tip-l2-cg002-nonempty-array-gate.sh`。
> Beat：`win_tip_l2_cg002_nonempty_array`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；空数组／dual_ptr_empty OK；e_fmtstyle **勿退回 P012**。
> 闸位 HOLD：Soft Cap／钉／tiphead／Cap tip **不升**；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> 只 LAN `windows-server`；tip PE＝`compiler/xlang_asm.exe`；bak `/c/xlang_tmp/p1145/xlang_asm.exe.bak_pre_1145`。

## 从 11.46 继承

| 项 | 状态 |
|----|------|
| `is_pointee` rcx→ebx tip patch＋override 种子 | 已种；`*T` dual empty OK |
| e_fmtstyle nonempty 双 fn | **CG002**（无 P012） |
| hello→core.fmt | **仍 P012**（非空 lit／while） |
| dual empty／dual_ptr_empty | OK |

## 机制 DIG（本刀）

1. `__stale_prim_parser_asm_primary_array_x_into_c`＠tip PE 仍是 **5B `jmp` → primary_suffix_loop**（不吃 `[...]`）。
2. `parse_primary` LBRACKET 臂 `call` 该 stub → nonempty `[48,…,57]` 解析失败／软跳 → 单 fn **CG002**；双 fn／fmt while 仍可 **P012**（与 11.46 soft-skip 泄漏同族）。
3. Empty `[]` 走 body_lets 浅扫，不进 stale primary_array（基线 OK）。
4. 已有 tip-only 种子：`compiler/seeds/win_tip_pe_overrides/stale_primary_array_x_into_override.c`（强 T ABI twin）。11.45 dig_slim+override 在 **无 is_pointee 修** 时 e_fmtstyle 仍 P012；本刀＝**override 盖 stub + 保留 is_pointee patch**，禁 Soft Cap G05。

## 非目标／禁

- Soft Cap G05 整链塞 tip；假绿／unique-rename fmt；升 tiphead／钉／Soft Cap。

## Residual／验收

- ACCEPT：hello 无 P012 且 empty／dual_ptr_empty／e_fmtstyle 不退 P012；L2 不 regress 空数组基线。
- 否则 residual HOLD：写清 one_arr／e_fmtstyle／hello 矩阵＋下一诚实粒。

## 现场矩阵（11.47 tiponly 试种）

LAN tip-only relink＠`/c/xlang_tmp/p1147`：override **T** `primary_array`＋`is_pointee` 先于 dig_slim（**无** Soft Cap G05）；md5 tiponly `a71e6e20…`。

| fixture | tiponly | 备注 |
|---------|---------|------|
| dual empty `[]` | OK | 基线勿 regress |
| dual_ptr_empty | OK | 基线勿 regress |
| e_fmtstyle nonempty 双 fn | **CG002**（无 P012） | 保 11.46 收获 |
| one_arr／match10／`u8[1]=[48]` | **CG002** `code_len≈12` | 解析已过；emit 失败 |
| hello→core.fmt | **仍 P012**＠fmt:76 `digits` | while／index 族未吃净 |
| Soft Cap PROD（只读对照，未混 tip） | 同 CG002／e_fmtstyle 仍 P012 | 非 tip 升档 |

### 读数

1. 盖 stale primary_array 后，typed let nonempty 多走 **emit** 而非 soft-skip P012（e_fmtstyle 无 P012）。
2. CG002 粒＝`glue_emit_fixed_array_type_let_init_elf_c`／bake／body_sync 族；Win tip／Soft Cap 对照同红 → 非仅 stub。
3. tiponly 装机后须重跑 `scripts/win_patch_body_sync_jmp.py`（leftover→tip jmp）；未确认 patch 前勿当 ACCEPT。
4. hello P012 ≠ 本刀假绿路径；下一诚实粒或本刀 residual＝**fail-leave／while** 或 **fixed_array emit＋win_patch**。
