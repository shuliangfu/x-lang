# Win tip L2 named_type_x live missing（刀 11.59）

> Gate：`tests/run-win-tip-l2-named-type-x-live-missing-gate.sh`。
> Beat：`win_tip_l2_named_type_x_live_missing`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56 绿族＋11.58 DIG 勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／exit0 空 .o。
> tip PE 起点 **`cf0d6200…`**。

## 从 11.58 继承

- 用户 struct **值参** tip P012／CG002；SC Prefer OK。
- 钉死：tip `__stale_parser_asm_parse_named_type_x_into_c` 空心（无 `e9`）；**无** live `parser_asm_parse_named_type_x_into_c`；SC stale trampoline→live。
- IF／match10 tip OK；PE `cf0d6200…`。

## 本刀 DIG／修靶

1. tip-local 找／种 **live** `parser_asm_parse_named_type_x_into_c`（或等价 tip-only 体），使 stale→`e9` live；**禁** Soft Cap 大体拷贝／G05。
2. 验收：`param_ctx`／`param_S` `-c` 非空 .o＋无 P012；IF／match10／11.56 不 regress；拒 exit0 空 .o。
3. 证据不够 → residual HOLD＋OPEN 下一粒。
4. 禁假绿／升闸／Soft Cap 混 tip／杀另账号 check／CloudAgent。

## Residual（开刀时）

- tip param_ctx／param_S P012／CG002；hello P012；缺 live named_type_x；PE `cf0d6200…`；L2 1/5＠`58e34910f`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48／11.55／11.56／11.57／11.58 DIG；CloudAgent；CheckSubscriptionUsage。
