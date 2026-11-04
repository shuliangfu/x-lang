# Win tip L2 IF typeck／codegen tip≠SC（刀 11.52）

> Gate：`tests/run-win-tip-l2-if-typeck-codegen-gap-gate.sh`。
> Beat：`win_tip_l2_if_typeck_codegen_gap`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> 只 LAN `windows-server`；tip PE **`cb03960b…`**。

## 从 11.51 继承

- IF vs WHILE 结构差（type_ref=0／block_ptr vs slice＋ret_type_ref）已钉；tip-only type_ref／advance inject **非充分**。
- if_x／block_ptr／IF emit **maskEq** SC；tip≠SC 在 **typeck_check_block_stmt_order_one**（802 vs 2356）／backend codegen mega 等。
- tip IF→CG002；SC IF OK；WHILE／NOIF OK；P012 未解。

## 本刀 DIG／修靶

1. tip-only 对照 typeck stmt_order／IF 臂与 SC 真身差；定位 tip IF→空 codegen 的 typeck 或 backend 入口。
2. tip-only 小修（stub→真身／cave／seed）使 IF_min 非空；勿 Soft Cap 整链混 tip。
3. 验收：IF_min OK；match10／WH0 不 regress；hello P012 可 residual。
4. 禁假绿／升闸。

## Residual（开刀时）

- tip IF_* CG002；P012；PE `cb03960b…`；L2 1/5＠`58e34910f`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48；CloudAgent；CheckSubscriptionUsage。
