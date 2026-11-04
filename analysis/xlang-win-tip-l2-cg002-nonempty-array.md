# Win tip L2 CG002 nonempty array（刀 11.47）· **CLOSE residual HOLD**

> Gate：`tests/run-win-tip-l2-cg002-nonempty-array-gate.sh`。
> Beat：`win_tip_l2_cg002_nonempty_array`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；空数组／dual_ptr_empty OK；e_fmtstyle **勿退回 P012**。
> 闸位 HOLD：Soft Cap／钉／tiphead／Cap tip **不升**；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> 只 LAN `windows-server`；tip PE＝`compiler/xlang_asm.exe` md5 **`e1b269dc…`**（is_pointee-patched bak）。

## 从 11.46 继承

| 项 | 状态 |
|----|------|
| `is_pointee` rcx→ebx tip patch＋override 种子 | 已种；`*T` dual empty OK |
| e_fmtstyle nonempty 双 fn | **CG002**（无 P012） |
| hello→core.fmt | **仍 P012**（非空 lit／while） |
| dual empty／dual_ptr_empty | OK |

## 机制 DIG（钉死）

### A. 非 stale primary_array（本刀已证）

1. `__stale_prim_parser_asm_primary_array_x_into_c` 仍 5B jmp stub；盖 override／tiponly 后 typed nonempty **仍 CG002**（解析已过）。
2. Empty `[]` 不进 vector_let_init → 基线 OK。
3. Soft Cap PROD 只读对照同 CG002 → 非 tip-only stub 独症；**勿** Soft Cap G05 混 tip。

### B. Emit 链（gdb＠match10 `u8[10]=[48…57]`）

| 步 | 结果 |
|----|------|
| `glue_struct_lit_store_fixed_array_field_elf_c` | 入；`field_mag=32`／`ta=0` |
| `pipeline_asm_emit_vector_let_init_elf_c` → `vlet_nested_body` | ENTRY；`init_ref` OK |
| `pipeline_asm_array_lit_elem_byte_sz_c` | **RET eax=1**（u8 esz 正确；W 已 jmp→T） |
| `vlet_scalar_one` | **RET eax=-1** |
| `backend_enc_lea_rbp_to_rax_arch` | **首呼即 -1**；`code_len≈12` |

### C. 真根因＝tip PE Win64 many-arg ABI 搅乱（`vlet_nested_body`→`vlet_scalar_one`）

objdump＠`vlet_nested_body+…` call site（`0x14013bdf0…0x14013be11`）：

1. 先 `mov r8, init_ref`／`mov r9, elem_ref`；
2. **再** `mov r8, ctx`／`mov r9, ta` → **覆盖** 第 3／4 形参；
3. 仅 `push` 两栈参后 `call`；`add rsp,0x20` 与 MSVC 6 栈参不成对。

callee `vlet_scalar_one`＠`0x14013ac24`：

1. 存 rcx／rdx／r8／r9 后 **再次**把 r8／r9 当第 5／6 参写入 `-0x30/-0x38`（SysV 残影）；
2. `stack_slot_off` 读自 **未装载** 的 `-0x40(%rbp)`；
3. 首呼 lea：**rdx=0／r8=1（当 ta=arm64）** → 走 `arch_arm64_enc_enc_lea_rbp_to_rax` → **-1**。

Darwin tip 同 fixture **OK**（arm64／不同 ABI 产物）。禁 dig_slim tiponly 整链（空数组曾 SEGV）；禁 Soft Cap 混 tip。

## 收刀矩阵（tip PE `e1b269dc…`）

| fixture | 结果 |
|---------|------|
| dual empty `[]` | OK |
| dual_ptr_empty | OK |
| e_fmtstyle nonempty 双 fn | **CG002**（无 P012） |
| match10／one_arr nonempty | **CG002** `code_len≈12` |
| hello→core.fmt | **仍 P012**＠fmt `digits` |
| Darwin match10 | OK |

## Residual／下一步诚实粒

- **CG002 nonempty：已钉死为 tip PE `vlet_scalar_one`／`vlet_nested_body` Win64 many-arg call／callee 错**；非 primary_array stub、非 esz、非 Soft Cap 独差。
- tip-only 安全修＝**定点 call-site／callee 二进制补丁**或 egg 重生该两符号（**勿** Soft Cap G05 整链／dig_slim 盲 relink）。
- hello P012＝另粒 **fail-leave／while**（本刀不假绿清）。
- → **OPEN 11.48** `win_tip_l2_vlet_win64_manyarg_abi`。

## 非目标／禁

- Soft Cap G05 整链塞 tip；假绿／unique-rename fmt；升 tiphead／钉／Soft Cap；`_dig` 入 git。
