# Win tip L2 vlet Win64 many-arg ABI（刀 11.48）

> Gate：`tests/run-win-tip-l2-vlet-win64-manyarg-abi-gate.sh`。
> Beat：`win_tip_l2_vlet_win64_manyarg_abi`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；空数组／dual_ptr_empty OK；e_fmtstyle **勿退回 P012**。
> 闸位 HOLD：Soft Cap／钉／tiphead／Cap tip **不升**；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> 只 LAN `windows-server`；tip PE＝`compiler/xlang_asm.exe` md5 **`e1b269dc…`**。

## 从 11.47 继承（已钉）

| 项 | 状态 |
|----|------|
| nonempty → `vlet_nested_body`；esz=1 | OK |
| `vlet_scalar_one` 首呼 lea rdx=0／ta=1 | **CG002** |
| tip PE call site 覆盖 r8／r9；callee 未读栈 home | **根因** |
| empty／dual_ptr_empty | OK |
| e_fmtstyle | CG002 无 P012 |
| hello | 仍 P012（**非本刀**；fail-leave 另开） |

## 本刀 DIG 靶

1. **Call site** `vlet_nested_body`→`vlet_scalar_one`（≈`0x14013bdf0`）：按 MSVC 四寄存器＋栈参重排／补 push；验证进入 scalar 时 `init_ref`／`elem_ref`／`ctx`／`ta`／`stack_slot_off=32`／`esz=1`。
2. **Callee prologue** `vlet_scalar_one`＠`0x14013ac24`：停用假 SysV 第 5／6 从 r8／r9；从 `[rbp+0x30…]`（或等价 shadow 后槽）装 `ctx…store_sz`。
3. tip-only：**最小字节补丁**或 **override .o 仅两符号**＋确认 empty 不 SEGV；**禁** Soft Cap G05／整 dig_slim 盲链。
4. 复验：match10／one_arr 无 CG002；empty／dual／e_fmtstyle 不退 P012；L2 1/5 空数组基线。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；假绿清 hello P012；CloudAgent。

## Residual／验收

- ACCEPT：match10／one_arr tip `-c` OK；empty／dual_ptr_empty／e_fmtstyle 无 P012；基线不 regress。
- 否则 residual HOLD：写清 patch 试次＋下一诚实粒（egg 重生／fail-leave while）。
