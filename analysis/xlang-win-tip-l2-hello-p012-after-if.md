# Win tip L2 hello／fmt P012 after IF unlock（刀 11.57）

> Gate：`tests/run-win-tip-l2-hello-p012-after-if-gate.sh`。
> Beat：`win_tip_l2_hello_p012_after_if`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 起点 **`cf0d6200…`**（11.56 realign）。

## 从 11.56 继承

- IF_min／IF_else／IF_ret_only `check`＋`-c` 已绿（realign stub tip-only）。
- WH／paren／ident／match10／call_main／vlet OK。
- hello／`examples/hello.x` 仍 **P012**（XP008 dep prerun／parse skip strict＠fmt）。

## 本刀 DIG／修靶

1. tip-local 钉 hello／`core.fmt` P012（scope／fail-leave／primary_lbrace 缺 live 等）；禁 Soft Cap 字节。
2. 验收：hello `check` 过或诚实 residual；IF／WH／paren／ident／match10／11.56 不 regress。
3. 诚实 tip-only 小修仅当证据够；否则 residual HOLD＋OPEN 下一粒。
4. 禁假绿／升闸／Soft Cap 混 tip／杀另账号 check／CloudAgent。

## Residual（开刀时）

- tip hello P012；L2 1/5＠`58e34910f`；PE `cf0d6200…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48／11.55／11.56；CloudAgent；CheckSubscriptionUsage。
