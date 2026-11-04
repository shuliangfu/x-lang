# Win tip L2 if_stmt_x／fail-leave brace（刀 11.50）

> Gate：`tests/run-win-tip-l2-if-x-fail-leave-brace-gate.sh`。
> Beat：`win_tip_l2_if_x_fail_leave_brace`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；match10／e_fmtstyle／empty／dual **勿 regress**（11.48）；本刀继承 11.49 DIG。
> 闸位 HOLD：Soft Cap／钉／tiphead／Cap tip **不升**；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> 只 LAN `windows-server`；tip PE md5 **`cb03960b…`**（11.48）为起点。

## 从 11.49 继承（钉死）

| 项 | 状态 |
|----|------|
| tip `if` 单 fn | CG002 `code_len=0` |
| tip `while`／NOIF | OK |
| Soft Cap `if` | OK |
| if_stmt_x vs SC masked | 同构；realign stub tip≠SC（非充分） |
| fail-leave 无 brace skip | Z10 → P012 |
| hello／fmt | 仍 P012＠num_digits |

## 本刀 DIG／修靶

1. tip-only 使 `parser_asm_parse_if_stmt_x_into_c`（或 into_c／advance_past／realign 真身）在 Win tip 上对 `if (true) {…}` **返回成功**并 codegen 非空。
2. 并行／随后：`set_onefunc_fail_c` 后 **`skip_balanced_braces`**，消除 body local → top_level P012 泄漏。
3. 验收：IF_min OK；hello 无 P012；match10／e_fmtstyle／empty 不 regress。
4. **禁** Soft Cap G05 混 tip；禁假绿。

## 非目标／禁

- 升钉／tiphead／Soft Cap；回滚 11.48 vlet inject；CloudAgent；CheckSubscriptionUsage。
