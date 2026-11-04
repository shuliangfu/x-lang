# Win tip L2 hello XP008 slice generic return（刀 11.63）

> Gate：`tests/run-win-tip-l2-hello-xp008-slice-generic-return-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_slice_generic_return`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59–**11.62** 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 起点 **`867330ba…`**（post-11.62）。

## 从 11.62 继承

- tip-local consume_qualified_into＠PLACE5 `0x140647E10` ACCEPT；`*IoBatchBuf` 形参 parse／gate62 清。
- hello 仍 **XP008**＠`std.io.backend`＠`io_read_ptr_slice`≈byte **7561**：返回型 **`u8[]<io_read_ptr>`**。
- 旁注：win32 tip typeck `bufs.ptr` T001（`*UserStruct` 字段；parse 已绿）。

## 本刀 DIG／修靶

1. DIG tip-only：`u8[]<Named>`／postfix-array generic 返回（vs Soft Cap Prefer 只读）。
2. 诚实 tip-only 小修若证据够；否则 residual HOLD＋OPEN 下一粒。
3. 验收：backend／hello 过 `io_read_ptr_slice` 或诚实新残；保 11.62 `*IoBatchBuf`／11.61 array-lit／11.60 allow；拒假绿。

## Residual（开刀时）

- tip `u8[]<io_read_ptr>` 返回 parse skip；hello XP008＠backend:7561；win32 typeck T001 旁注；L2 1/5＠`58e34910f`；PE `867330ba…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48–11.62；CloudAgent；CheckSubscriptionUsage。
