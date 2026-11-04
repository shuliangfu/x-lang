# Win tip L2 hello XP008 std.context parse（刀 11.64）

> Gate：`tests/run-win-tip-l2-hello-xp008-std-context-parse-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_std_context_parse`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59–**11.63** 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 起点 **`6772521c…`**（post-11.63）。

## 从 11.63 继承

- tip-local postfix_slice＠`.c63slc`／PLACE `0x14a259000` ACCEPT；`u8[]<io_read_ptr>`／gate63 清；backend＠7561 清。
- hello 仍 **XP008** dep prerun → `std.context` parse skip＠≈**1973**／**2059**（name=background 归位）。
- 旁注：win32／backend typeck batch_buf／`bufs.ptr` T001。

## 本刀 DIG／修靶

1. DIG tip-only：hello／`std.context`＠≈1973／2059（vs Soft Cap Prefer 只读）。
2. 诚实 tip-only 小修若证据够；否则 residual HOLD＋OPEN 下一粒。
3. 验收：context／hello 过该 locus 或诚实新残；保 11.63 slice／11.62 ptr／11.61 array-let；拒假绿。

## Residual（开刀时）

- tip hello XP008＠`std.context` parse skip≈1973／2059；win32／backend typeck 旁注；L2 1/5＠`58e34910f`；PE `6772521c…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48–11.63；CloudAgent；CheckSubscriptionUsage。
