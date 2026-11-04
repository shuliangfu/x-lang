# Win tip L2 IF vs WHILE block path（刀 11.51）

> Gate：`tests/run-win-tip-l2-if-vs-while-block-path-gate.sh`。
> Beat：`win_tip_l2_if_vs_while_block_path`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；match10／e_fmtstyle／empty／dual **勿 regress**（11.48）；继承 11.50 residual。
> 闸位 HOLD：Soft Cap／钉／tiphead／Cap tip **不升**；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> 只 LAN `windows-server`；tip PE 起点／终点 **`cb03960b…`**（inject 均恢复 bak）。

## 从 11.50 继承（钉死）

| 项 | 状态 |
|----|------|
| tip `if`（export function＋if(true)） | CG002 |
| tip `while`／NOIF | OK |
| Soft Cap 同 fixture `if` | OK |
| if_stmt_x／advance／cond_ptr／block_ptr masked | ≈SC |
| `ast_ast_block_num_if_stmts` W stub | call_hits W=0 → **已排除** |
| fail-leave brace | 未落地；Z10／hello **仍 P012** |

## DIG（本刀钉死）

### 结构差 IF vs WHILE（seed／PE 同形）

| | IF | WHILE |
|--|----|-------|
| onefunc 入口 | `parser_asm_parse_if_stmt_into_c(..., type_ref=**0**)`＠`0x1405cf159` `mov r9d,0` | glue advance → `parser_parse_block_into(..., **ret_type_ref**=[rbp+0xf94])` |
| 条件后同步 | if_x 直调 W `advance_past_cond_rparen_into_c`（jmp `lex_step`） | `parser_advance_past_cond_rparen_into_glue` → **slice_c**（C 重做 `lexer_next`；W 游标丢弃） |
| 块解析 | `parser_parse_block_ptr_into_c`（契约：advance 成功后 cursor **已过 `{`**） | `parser_parse_block_into`，lex **已过 `{`**（glue `lex_from_next`） |

Soft Cap **同** `mov r9d,0`＋同 W advance stub；onefunc／if_x／block_ptr **maskEq** tip＝SC。故 type_ref=0／W advance **不是** tip≠SC 充分条件（仅 seed 结构差）。

### tip-only inject（均非充分；已恢复 `cb03960b…`）

1. **advance → 真 .x 体**（peek／step／RPAREN 再 step／返 1|0；cave＠死 stub 簇）：IF 仍 CG002；WHILE／NOIF OK。
2. **type_ref 0 → `[rbp+0xf94]` ret_type_ref**（IF call 前 jmp cave：`mov r9d,[rbp+0xf94]; mov rcx,rax`）：IF 仍 CG002；WHILE／NOIF OK。

### tip≠SC 仍开（禁 Soft Cap 混 tip）

- `typeck_check_block_stmt_order_one` tip **802B** vs SC **2356B**（mask≠）。
- `typeck_check_block_one_while` tip **256B** vs SC **~4KB**。
- `pipeline_backend_asm_codegen_ast_to_elf_*`／`backend_asm_codegen_ast_seed_mega` mask≠。
- IF **emit** 符号（`emit_block_if_stmt_elf` 等）maskEq — 缺口更偏 **typeck／backend 入口**，非 if_x／block_ptr 本体。

## Residual（锁形）

- tip `IF_min`／`IF_ex`／`IF_empty`／`IF_ret`：CG002／`code_len=0`。
- tip hello／`core.fmt`／Z10：P012。
- tip PE：`cb03960b…`（无产品 tip 修）。
- 基线 Win tip L2 **1/5**＠`58e34910f` 未重跑（无解锁）。

## 正式 CLOSE residual HOLD

结构差钉死；type_ref／advance tip-only 小修 **非充分**；**无** Soft Cap G05；**无**假绿；移交 11.52 typeck／codegen tip≠SC（禁混 tip）。

## 非目标／禁

- 升钉／tiphead／Soft Cap；回滚 11.48；CloudAgent；CheckSubscriptionUsage；假绿；Soft Cap G05 混 tip。
