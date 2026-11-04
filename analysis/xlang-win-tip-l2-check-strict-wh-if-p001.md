# Win tip L2 check-strict WH＋IF P001（刀 11.54）

> Gate：`tests/run-win-tip-l2-check-strict-wh-if-p001-gate.sh`。
> Beat：`win_tip_l2_check_strict_wh_if_p001`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE **`cb03960b…`**。

## 从 11.53 继承

- realign W tip≠SC；solo SC 形对 check／`-c` IF **均非充分**（已恢复）。
- tip `check`：**IF** P001＠byte 0/6；**WH** P001＠byte 38；NOIF OK。
- tip `-c`：IF CG002；WH／NOIF OK。
- if／while／strict／check 主路径 **maskEq** SC；根不在 realign 独差。
- SC-only primary／type_ref W 族 vs tip slice／`__stale_*` ——待钉。

## 本刀 DIG／修靶

1. 钉 check-strict 为何 WH＋IF 均 parse_skip（byte 38 vs 0/6）而代码≈SC：数据／全局／fail-leave／skip_commit 运行时 hits；对照 Soft Cap **只读**。
2. tip 缺 live `parser_asm_primary_*_x_into_c` W（SC 有）是否导致 strict 路径分叉；诚实 tip-only 小修仅当证据充分。
3. 验收：WH0＋IF_min `check` 过且 IF_min `-c` 非空；match10／NOIF 不 regress。
4. 禁假绿／升闸／Soft Cap 混 tip／杀另账号 check。

## Residual（开刀时）

- tip IF CG002／check P001；tip WH check P001；P012；PE `cb03960b…`；L2 1/5＠`58e34910f`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48；CloudAgent；CheckSubscriptionUsage。
