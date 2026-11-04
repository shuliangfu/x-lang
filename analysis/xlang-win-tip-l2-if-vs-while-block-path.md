# Win tip L2 IF vs WHILE block path（刀 11.51）

> Gate：`tests/run-win-tip-l2-if-vs-while-block-path-gate.sh`。
> Beat：`win_tip_l2_if_vs_while_block_path`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；match10／e_fmtstyle／empty／dual **勿 regress**（11.48）；继承 11.50 residual。
> 闸位 HOLD：Soft Cap／钉／tiphead／Cap tip **不升**；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> 只 LAN `windows-server`；tip PE 起点 **`cb03960b…`**。

## 从 11.50 继承（钉死）

| 项 | 状态 |
|----|------|
| tip `if`（export function＋if(true)） | CG002 |
| tip `while`／NOIF | OK |
| Soft Cap 同 fixture `if` | OK sz≈183 |
| if_stmt_x／advance_past／cond_ptr masked | ≈SC；advance inject **非充分** |
| `ast_ast_block_num_if_stmts` W stub | call_hits W=0（tip+SC）→ **已排除** |
| fail-leave brace | 未落地；Z10／hello **仍 P012** |

## 本刀 DIG／修靶

1. tip-only 对照 **IF** `parse_block_ptr`（`type_ref=0`）vs **WHILE** `into_slice`＋`ret_type_ref`／cond glue；定位 tip IF 失败点。
2. tip-only 修使 `IF_ex`／`IF_min` codegen 非空；尽量清 Z10／hello P012（可并列 fail-leave call-site brace）。
3. 验收：IF_min OK；match10／WH0 不 regress；hello 无 P012 或 residual 锁形更新。
4. **禁** Soft Cap G05 混 tip；禁假绿。

## 非目标／禁

- 升钉／tiphead／Soft Cap；回滚 11.48；CloudAgent；CheckSubscriptionUsage。
