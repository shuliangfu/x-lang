# Win tip L2 IF then-block XT001（刀 11.56）

> Gate：`tests/run-win-tip-l2-if-then-block-xt001-gate.sh`。
> Beat：`win_tip_l2_if_then_block_xt001`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55 paren＋ident 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 产品 **`cf0d6200…`**（pre-realign `e879bac3…`；bak_pre_1155 `cb03960b…`）。

## 从 11.55 继承

- tip-local paren＋ident stale_primary override 已注入；WH／paren／ident／match10／call_main `check` 已绿。
- IF_min 曾 **XT001** implicit tail（kind=-6）；Soft Cap IF OK。
- `if (1)` → T001 bool＝IF 入口／条件 typeck 在。

## DIG（本刀钉死）

| 项 | tip | Soft Cap |
|----|-----|----------|
| `parser_asm_parse_if_stmt_x_into_c` | ~2192；call graph 同形 | maskEq（仅 rel32） |
| `pipeline_block_append_if`／typeck_one_if **T** | maskEq | maskEq |
| `parser_asm_advance_past_cond_rparen_into_c` W | jmp `lex_step_kind` | **同** |
| **`parser_asm_realign_lex_after_if_arm_into_c` W** | **`jmp lex_set_pos_c`**（错） | **`mov eax,1; ret`** |
| WH／paren／ident／match10 | OK | OK |
| IF_min／IF_ret_only／IF_else／IF_empty／IF_bool_let | tip0 **XT001／XP003** | OK |

根因：IF 臂结束后 tip 误把 realign stub 接到 `lex_set_pos_c`，搅乱游标／`final_expr`／stmt_order → `func_body_has_implicit_return_tail`（-6）。WH 不调该 stub ⇒ WH 绿、IF 红。11.51／11.52 曾试 realign→SC 形但当时 primary 仍 stale（P001）→「非充分」；**11.55 解锁 primary 后本修充分**。

## 产品修（tip-only）

- Script：`compiler/scripts/win_tip_pe_inject_if_arm_realign_stub.py`
- 8B：`e909fc00…` → `b801000000c39090`（`mov eax,1; ret; nop; nop`）
- **无** Soft Cap 字节混入；语义＝IF arm 后 return-success no-op。
- PE md5：`e879bac3…` → **`cf0d6200f15f962a4a5e039bbc17a5be`**（local only；gitignore）。

## 验收

- Gate EXIT0：IF_min `check`＋`-c`；WH／paren／ident／match10／NOIF OK。
- 矩阵：IF_else／IF_empty_then／IF_ret_only／IF_bool_let／call_main／ret_paren／ret_x／vlet／wh_false `check`＋`-c` OK。
- hello／`core.fmt` 仍 **P012**（XP008 dep prerun）；L2 未重跑（仍基线 1/5＠`58e34910f`）。

## 正式 CLOSE ACCEPT

IF then-block XT001 tip-only realign stub 已解；11.55 绿族不 regress；**无** Soft Cap G05；**无**假绿；移交 11.57 hello／fmt **P012**。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48／11.55 trampoline；CloudAgent；CheckSubscriptionUsage；假绿。
