# Win tip L2 hello XP008 user-struct ptr param（刀 11.62）

> Gate：`tests/run-win-tip-l2-hello-xp008-user-struct-ptr-param-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_user_struct_ptr_param`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59／11.60／**11.61** 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 起点 **`453c9b1e…`**（post-11.61）。

## 从 11.61 继承

- tip-local stale primary_array override＠PLACE `0x140647C20` ACCEPT；top-level array-lit let／win32:1048 清。
- hello 仍 **XP008**＠`std.io.win32`＠`io_read_batch_buf`≈byte **5774**：`bufs: *IoBatchBuf`（user-struct **pointer** 形参）。
- 隔离：`*IoBatchBuf` 形参 tip parse skip；值参 `IoBatchBuf` OK；`isize` 返回 OK。

## 本刀 DIG／修靶

1. DIG tip-only：`*UserStruct` 形参 parse skip（vs 值参 OK；vs Soft Cap Prefer 只读）。
2. 诚实 tip-only 小修若证据够；否则 residual HOLD＋OPEN 下一粒。
3. 验收：win32／hello／backend 过 `*IoBatchBuf` 或诚实新残；保 11.61 array-lit／11.60 allow／11.59 param；拒假绿。

## Residual（开刀时）

- tip user-struct ptr 形参 parse skip；hello XP008＠win32:5774；L2 1/5＠`58e34910f`；PE `453c9b1e…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48–11.61；CloudAgent；CheckSubscriptionUsage。
