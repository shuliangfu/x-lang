# Win tip L2 hello XP008 parse skip（刀 11.60）

> Gate：`tests/run-win-tip-l2-hello-xp008-parse-skip-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_parse_skip`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／**11.59** 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／exit0 空 .o。
> tip PE 起点 **`a16d6822…`**（post-11.59）。

## 从 11.59 继承

- named_type_x tip-local live＋stale→e9 ACCEPT；param_ctx／param_S 无 P012。
- hello／L2 hello 仍 **XP008**：`dep prerun failed` → `parse skip at byte 952 (num_funcs=0)`＠`std.io.backend`。
- IF／match10／11.55／11.56 OK；PE `a16d6822…`。

## 本刀 DIG／修靶

1. DIG tip-only：`std.io.backend` parse skip＠byte 952 — 缺哪条 tip parser／stale hollow／trampoline（对照 Soft Cap Prefer 只读）。
2. 诚实 tip-only 小修若证据够；否则 residual HOLD＋OPEN 下一粒。
3. 验收：hello `-c`／L2 hello 非 XP008 假路径；保 param_ctx／IF／11.59；拒假绿。
4. 禁 Soft Cap 混 tip／升钉／CloudAgent／杀另账号 check。

## Residual（开刀时）

- hello XP008 parse skip；consume_qualified tip stale 误 jmp；param_S 字段 T001；L2 1/5＠`58e34910f`；PE `a16d6822…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48／11.55／11.56／11.59；CloudAgent；CheckSubscriptionUsage。
