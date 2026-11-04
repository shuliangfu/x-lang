# Win tip L2 hello XP008 array let type（刀 11.61）

> Gate：`tests/run-win-tip-l2-hello-xp008-array-let-type-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_array_let_type`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59／**11.60** 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 起点 **`69032ad2…`**（post-11.60）。

## 从 11.60 继承

- skip_one_tl const／let＋try_skip_allow_padding tip-local lives ACCEPT；backend＠952／allow＠890 清。
- hello 仍 **XP008**＠`std.io.win32`＠byte **1048**：top-level `let`＋`[N]T` array type。
- scalar let／export const／allow1／param_ctx／IF／match10／vlet OK；PE `69032ad2…`。

## 本刀 DIG／修靶

1. DIG tip-only：`let x: [N]T = …` parse skip＠0（vs scalar let OK；vs Soft Cap Prefer 只读）。
2. 诚实 tip-only 小修若证据够；否则 residual HOLD＋OPEN 下一粒。
3. 验收：win32／hello 过 array lets 或诚实新残；保 11.60 allow／cfg／11.59；拒假绿。

## Residual（开刀时）

- tip array-typed top-level let parse skip；hello XP008＠win32:1048；L2 1/5＠`58e34910f`；PE `69032ad2…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48–11.60；CloudAgent；CheckSubscriptionUsage。
