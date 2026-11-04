# Win tip L2 if_stmt_x／fail-leave brace（刀 11.50）

> Gate：`tests/run-win-tip-l2-if-x-fail-leave-brace-gate.sh`。
> Beat：`win_tip_l2_if_x_fail_leave_brace`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；match10／e_fmtstyle／empty／dual **勿 regress**（11.48）；本刀继承 11.49 DIG。
> 闸位 HOLD：Soft Cap／钉／tiphead／Cap tip **不升**；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> 只 LAN `windows-server`；tip PE md5 **`cb03960b…`**（11.48）为起点／终点（未改产品 tip）。

## 正式 CLOSE residual HOLD

- tip-only **未**解开 IF 成功路径；**未**落地 fail-leave brace-consume；hello／fmt **仍 P012**；Z10 **仍 P012**。
- tip PE 保持 **`cb03960b…`**（inject 后均恢复 bak）；**无** Soft Cap G05 混 tip；**无**假绿；**无**升钉／tiphead。
- 移交 11.51：`win_tip_l2_if_vs_while_block_path`（IF `parse_block_ptr`／`type_ref=0` vs WHILE `into_slice`＋`ret_type_ref`）。

## 从 11.49 继承（钉死）

| 项 | 状态 |
|----|------|
| tip `if` 单 fn | CG002 `code_len=0` |
| tip `while`／NOIF | OK |
| Soft Cap `if` | OK（正确 fixture） |
| if_stmt_x vs SC masked | 同构；realign 非充分 |
| fail-leave 无 brace skip | Z10 → P012 |
| hello／fmt | 仍 P012＠num_digits |

## 本刀 DIG 证据（2026-11-04）

### Fixture（纠正假失败）

- Soft Cap／tip 均须 **`export function`＋`if (true)`**。早期 `fn`／`if(1)` 是 fixture 错，不是 Soft Cap 真失败。
- Soft Cap `IF_ex.x` → **OK sz=183**；tip 同文件 → **CG002**。
- tip `WH0` while → OK sz=171；tip `IF3e` 双 fn → drop if-fn 留另一 fn（~149B）；tip `Z10` → **P012**。

### PE／路径对照（tip vs Soft Cap Prefer lab）

| 符号 | tip vs SC |
|------|-----------|
| `parser_asm_parse_if_stmt_x_into_c` | len 同；**masked 同构**；raw 仅 rel32 |
| `parser_asm_parse_if_stmt_into_c` | raw **相同** |
| `parser_asm_advance_past_cond_rparen_into_c` | 双方皆 **8B** `jmp lex_step_kind` stub |
| `parser_parse_cond_expr_ptr_into_c` | masked 同；均调 `parse_cond_expr_into_glue` |
| `parser_asm_parse_cond_expr_x_into_c`／`into_slice_c` | raw **相同** |
| `parser_asm_set_onefunc_fail_c`／`skip_balanced_braces_into_c` | raw **相同** |

### tip-only inject（均不足 → 已恢复 bak）

1. `advance_past` cave（真身／NOP／STEP）→ tip IF_ex 仍 CG002。
2. `realign_finish_peek` 相关尝试 → 仍不足。
3. Soft Cap 与 tip 共用 broken `advance_past` stub 但 Soft Cap IF OK → **advance_past 非 tip≠SC 根因**。

### 排除：`ast_ast_block_num_if_stmts` W stub

- tip／SC 皆有 **T（真身读 `+0x28`）**＋**W（恒返 0 stub）**。
- `.text` 内 `call` 落点：**tip T=31 W=0**；**SC T=31 W=0**。W stub **不在** IF 调用路径 → **非**本刀 tip≠SC 缺口。

### 仍开的 tip≠SC／路径残差（移交 11.51）

1. **IF** 走 `parse_block_ptr_into_c`（`type_ref=0`）；**WHILE** 走 glue／`into_slice`＋`ret_type_ref` — tip IF 失败而 WHILE OK 的最硬结构差。
2. fail-leave：`set_onefunc_fail_c` **无 source**，无法在此单点 `skip_balanced_braces`；需 IF fail **call site** 侧 inject（未落地）。
3. 其它命名残差（pipeline／grow_vec 等）未证为充分条件；**勿** Soft Cap 整链混 tip。

## Residual（锁形）

- tip `IF_min`／`IF_ex`：CG002／`code_len=0`。
- tip hello／`core.fmt`：P012。
- tip Z10：P012（body `let` 泄漏 top-level）。
- tip PE：`cb03960b…`。
- 基线 Win tip L2 **1/5**＠`58e34910f` 勿 regress。

## 非目标／禁

- 升钉／tiphead／Soft Cap；回滚 11.48 vlet inject；CloudAgent；CheckSubscriptionUsage；假绿；Soft Cap G05 混 tip。
