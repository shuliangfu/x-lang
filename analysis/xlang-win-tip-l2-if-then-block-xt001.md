# Win tip L2 IF then-block XT001（刀 11.56）

> Gate：`tests/run-win-tip-l2-if-then-block-xt001-gate.sh`。
> Beat：`win_tip_l2_if_then_block_xt001`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55 paren＋ident 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 产品 **`e879bac3…`**（bak `cb03960b…`）。

## 从 11.55 继承

- tip-local paren＋ident stale_primary override 已注入；WH／paren／ident／match10／call_main `check` 已绿。
- IF_min 仍 **XT001** implicit tail（`if (true) { return 1; } return 0;`）；Soft Cap IF OK。
- `if (1)` → T001 bool＝IF 入口／条件 typeck 在；残＝then-block 覆盖或 IF stmt 附着（非 primary P001）。

## 本刀 DIG／修靶

1. tip-local 钉 IF then／else block 附着与 return 覆盖（parser_asm IF stmt／block；禁 Soft Cap 字节）。
2. 验收：IF_min `check`＋`-c` 过；WH／paren／ident／match10／NOIF／11.48 不 regress。
3. 诚实 tip-only 小修仅当 tip 本地目标齐；否则 residual HOLD＋OPEN 下一粒。
4. 禁假绿／升闸／Soft Cap 混 tip／杀另账号 check／CloudAgent。

## Residual（开刀时）

- tip IF_min XT001；P012；L2 1/5＠`58e34910f`；PE `e879bac3…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48／11.55 trampoline；CloudAgent；CheckSubscriptionUsage。
