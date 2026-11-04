# Win tip L2 hello XP008 std.context ctx_ptr（刀 11.68）

> Gate：`tests/run-win-tip-l2-hello-xp008-std-context-ctx-ptr-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_std_context_ctx_ptr`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.67 nested DYN ACCEPT 后新露残。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 起点 **`059417e5772c…`**（post-11.67）。

## 从 11.67 继承

- nested／Empty／arr_named T001（TYPE_DYN 无条件 wrap）已 ACCEPT 清。
- `std/context/context.x` tip check：不再报 `CtxNode.values` unknown size；改为 **`ctx_ptr` return expression type mismatch**（`expected * { i, found *; }`／XT001 fn#8）。
- hello `-c` 仍 segfault（bak 同形）；L2 hello build=139。

## 本刀 DIG／修靶

1. DIG tip-local：`ctx_ptr` 返回类型 mismatch 真位点（parse type_ref／pointee／named／dyn 残？与 11.64 context parse 关系）。
2. 诚实 tip-only 小修若证据够；否则 residual HOLD＋OPEN 下一粒。
3. 验收：context.x check 进一格或诚实新残；保 11.67–11.55 greens；**勿** Soft Cap 混 tip。

## Residual（开刀时）

- context `ctx_ptr` XT001；hello XP008／segfault；L2 1/5＠`58e34910f`；PE `059417e5…`。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap 门；CloudAgent；假绿。
