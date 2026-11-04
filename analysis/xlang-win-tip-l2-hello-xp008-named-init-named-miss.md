# Win tip L2 hello XP008 named init_named miss（刀 11.71）

> Gate：`tests/run-win-tip-l2-hello-xp008-named-init-named-miss-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_named_init_named_miss`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.59–**11.70** 绿族／HOLD 勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 起点 **`059417e5772c…`**（post-11.67；11.68–11.70 无修）。

## 从 11.70 继承

- 真残钉＝type-ref 以 kind ARG＝8 进 `equal_named`，但 type-table slot **未** `init_named_at`（slot kind＠0＝0；L84＝1；name＝`)`／` `）→ diag `expected  , found )`；A_val／`*A`／ctx_ptr／cast；field T001 级联。
- Prefer name_into／init_named／same_kind／equal_named 与 Soft Cap **结构对齐**；无 tip-peel e9。
- 11.70 订正：本 fixture **非**经典 len＠0x84≤0；name_into 忠实读未初始化／错 kind 槽。
- 11.67 wrap 保留；勿回滚；force name／always-eq 假绿禁入 tip。

## 本刀 DIG／修靶

1. DIG tip-local：**为何** struct `A`／NAMED 注册跳过 `init_named_at`＠`0x1402A9CA1`（调用点 `0x1405c9040`／`0x1405ca62a`／`0x1405cb803`／`0x1405d6a57` 等未命中；仅 path-builder `0x140647a67` 见）。
2. 对照 Soft Cap Prefer 只读：同 fixture 下 init_named 调用序／IDENT type-ref 何时写 kind8＋name。
3. 诚实 tip-only 小修若证据够（e9／live／单点 writer）；否则 residual HOLD＋OPEN 下一粒。
4. 验收：A_val／`*A`／ctx_ptr 进一格或诚实新残；保 11.67 nested／slice／`*IoBatchBuf`／array-let／IF greens。

## Residual（开刀时）

- init_named miss → kind-arg8／slot-kind0 → equal_named 垃圾名；L2 1/5＠`58e34910f`；PE `059417e5…`；P012 未新开。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；force equal／force name 假绿；CloudAgent；CheckSubscriptionUsage 空转；`_dig` 入 git。
