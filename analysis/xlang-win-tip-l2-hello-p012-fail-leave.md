# Win tip L2 hello／fmt P012 fail-leave（刀 11.49）

> Gate：`tests/run-win-tip-l2-hello-p012-fail-leave-gate.sh`。
> Beat：`win_tip_l2_hello_p012_fail_leave`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；empty／dual_ptr_empty／match10／e_fmtstyle **勿 regress**（11.48 ACCEPT）。
> 闸位 HOLD：Soft Cap／钉／tiphead／Cap tip **不升**；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> 只 LAN `windows-server`；tip PE＝`compiler/xlang_asm.exe` md5 **`cb03960b…`**（11.48 vlet inject）。

## 从 11.48 继承

| 项 | 状态 |
|----|------|
| nonempty match10／e_fmtstyle | **OK**（vlet Win64 override） |
| empty／dual_ptr_empty | OK |
| hello／core.fmt P012＠`num_digits` | **仍 P012**（本刀） |
| is_pointee rcx→ebx | 已修（11.46） |

## 本刀 DIG 靶

1. hello／`core/fmt` P012：body `let`／`while`／fail-leave 是否仍把 local 泄漏为 module top-level（相对 11.45／11.46 soft-skip 链）。
2. tip-only 小步；禁 Soft Cap G05；禁假绿清 P012。
3. 验收：hello tip `-c` 无 P012；empty／match10／e_fmtstyle 不 regress。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48 vlet inject；CloudAgent。
