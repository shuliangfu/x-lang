# Win tip L2 hello XP008 named name_into empty（刀 11.70）

> Gate：`tests/run-win-tip-l2-hello-xp008-named-name-into-empty-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_named_name_into_empty`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.59–**11.69** 绿族／HOLD 勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 起点 **`059417e5772c…`**（post-11.67；11.68–11.69 无修）。

## 从 11.69 继承

- 真残钉＝tip `pipeline_type_named_name_into` 对 NAMED 槽返回 **空名**（len＠0x84≤0）→ `typeck_type_refs_equal_named` 失败 → A_val／`*A`／ctx_ptr／cast；field T001 大半级联。
- Prefer：name_into／init_named／same_kind／equal_named 与 Soft Cap **结构对齐**；无 tip-peel e9。
- dig probe：force name_into／always-equal 可假绿 A_val／ctx_ptr／min_ptr_field — **禁入 tip**。
- 11.67 wrap 保留；勿回滚。

## 本刀 DIG／修靶

1. DIG tip-local：**为何** NAMED 槽＠0x84 运行时为 0（init_named 未写／写错槽／IDENT type-ref 指向空 stub／arena elem_sz／grow_vec／sidecar／错 type index 入 equal_named）。
2. 对照 Soft Cap Prefer 只读：同 fixture 下 name 槽填充路径／调用序。
3. 诚实 tip-only 小修若证据够（e9／live／单点 writer）；否则 residual HOLD＋OPEN 下一粒。
4. 验收：A_val／`*A`／ctx_ptr 进一格或诚实新残；保 11.67 nested／slice／`*IoBatchBuf`／array-let／IF greens。

## Residual（开刀时）

- tip empty name_into → named-eq／field／hello XP008／context；L2 1/5＠`58e34910f`；PE `059417e5…`；P012 未新开。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；force equal／force name 假绿；CloudAgent；CheckSubscriptionUsage 空转；`_dig` 入 git。
