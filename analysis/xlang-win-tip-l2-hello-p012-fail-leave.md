# Win tip L2 hello／fmt P012 fail-leave（刀 11.49）· **CLOSE residual HOLD**

> Gate：`tests/run-win-tip-l2-hello-p012-fail-leave-gate.sh`。
> Beat：`win_tip_l2_hello_p012_fail_leave`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；empty／dual_ptr_empty／match10／e_fmtstyle **勿 regress**（11.48 ACCEPT）。
> 闸位 HOLD：Soft Cap／钉／tiphead／Cap tip **不升**；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> 只 LAN `windows-server`；tip PE＝`compiler/xlang_asm.exe` md5 **`cb03960b…`**（11.48 vlet inject；本刀未改产品链）。

## 从 11.48 继承

| 项 | 状态 |
|----|------|
| nonempty match10／e_fmtstyle | **OK**（vlet Win64 override） |
| empty／dual_ptr_empty | OK |
| hello／core.fmt P012＠`num_digits` | **仍 P012**（本刀未解） |
| is_pointee rcx→ebx | 已修（11.46） |

## 根因（钉死）

1. **Win tip 单 fn `if` → CG002 `code_len=0`**；`while`／无控制流 **OK**。Soft Cap Prefer 同 fixture `if (true)` **OK**（.o≈183B）。Darwin tip if／while／cfm OK（既有）。
2. **onefunc 路径分叉**：`TOKEN_WHILE` 走 by-value `parser_parse_cond_expr_into_glue`＋`parser_parse_block_into`（tip OK）；`TOKEN_IF` 走 `parser_asm_parse_if_stmt_into_c` → **`parser_asm_parse_if_stmt_x_into_c`（7 参 W）**。
3. **fail-leave 泄漏 → P012**：`set_onefunc_fail_c` **不** `skip_balanced_braces`；if soft-fail 后 body 残 token 当 module top-level。探针 `Z10`（module `let k`＋fn 内 `if { let k }`）→ **P012**；`IF3`／`IF3b` dual 只保留无 if 的那一侧 fn。
4. **tip vs Soft Cap 代码面**：`if_stmt_x`／`into_c`／cond／block ptr／append_if／onefunc_buf（masked rel）**同构**；非 11.48 vlet 覆盖区。
5. **tip-only stub 差**：`parser_asm_realign_lex_after_if_arm_into_c` tip＝`jmp parser_asm_lex_set_pos_c`，Soft Cap＝`mov eax,1; ret`。试 patch tip→SC 字节后 **IF 仍 CG002**（非充分修）。`advance_past_cond_rparen_into_c` tip／SC 皆 `jmp lex_step_kind`（同错）；retarget→`into_slice_c` **未**清 IF，且扰动试验已 **恢复** tip PE `cb03960b…`。
6. hello／`core/fmt`：`fmt_u32_to_buf` 内 `while`／`if`＋local `num_digits` 等 → if／while soft-fail 链 → **P012＠num_digits**（locus 相对 prior 一致）。

## 本刀未落地的诚实修（移交 11.50）

- tip-only：修好 `parse_if_stmt_x` 成功路径（或 W stub／`advance_past`／realign 真身），**且／或** `set_onefunc_fail` 后 `skip_balanced_braces`（防 P012 泄漏；单修 fail-leave **不够**清 hello——if 仍须成功）。
- **禁** Soft Cap G05 混 tip；禁假绿 rename／去 if。

## 收刀矩阵（tip PE `cb03960b…`）

| fixture | 结果 |
|---------|------|
| NOIF／empty dual | **OK** |
| WH0 `while (false)` | **OK**（tip＝SC＝171B） |
| IF_min／IF_else／IF_empty | tip **CG002** `code_len=0`；SC **OK** |
| IF3／IF3b dual | tip 丢掉含 if 的 fn |
| Z10 if＋module let 撞名 | **P012**（fail-leave） |
| match10／e_fmtstyle | **OK**（11.48 未 regress） |
| hello／core.fmt | **仍 P012** |
| Soft Cap／钉／tiphead | **未升**；无 G05 混 tip |

## Residual／移交

- **CLOSE residual HOLD** 11.49：机制钉死（if-x 路径 fail → fail-leave → P012）；无 tip-only 产品修；PE 保持 `cb03960b…`。
- 下一刀 **OPEN 11.50**：`win_tip_l2_if_x_fail_leave_brace` — tip-only if_stmt_x 成功路径 **或** fail-leave brace-consume 定点；勿 regress 11.48。
