# Win tip L2 user-struct param soft-fail → P012（刀 11.58）

> Gate：`tests/run-win-tip-l2-user-struct-param-softfail-gate.sh`。
> Beat：`win_tip_l2_user_struct_param_softfail`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56 绿族＋11.57 DIG 勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／exit0 空 .o。
> tip PE 起点 **`cf0d6200…`**。

## 从 11.57 继承

- IF／WH／match10／paren／ident OK；`check core/fmt` tip EXIT0。
- hello 仍 P012／XP008；真位点钉 **`Context` 值参** soft-fail → body let top_level → P012（SC OK）。
- mirror_p2 类 **exit0＋.o=0**＝假绿陷阱，本刀验收必须查产物大小。

## 本刀 DIG／修靶

1. tip-local 钉用户 struct 形参（值／\*T）soft-fail／fail-leave 未吃体 → P012；找可 tip-only 的 trampoline／ABI 小修（类 11.46 pointee），**禁** Soft Cap 字节。
2. 验收：`param_ctx` `-c` 非空 .o＋无 P012；IF／WH／match10／11.56 不 regress；hello 尽量跟进。
3. 证据不够 → residual HOLD＋OPEN 下一粒。
4. 禁假绿／升闸／Soft Cap 混 tip／杀另账号 check／CloudAgent。

## Residual（开刀时）

- tip param_ctx P012／CG002；hello P012；PE `cf0d6200…`；L2 1/5＠`58e34910f`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48／11.55／11.56／11.57 DIG；CloudAgent；CheckSubscriptionUsage。
