# Win tip L2 vlet Win64 many-arg ABI（刀 11.48）· **CLOSE ACCEPT**

> Gate：`tests/run-win-tip-l2-vlet-win64-manyarg-abi-gate.sh`。
> Beat：`win_tip_l2_vlet_win64_manyarg_abi`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；空数组／dual_ptr_empty OK；e_fmtstyle **勿退回 P012**。
> 闸位 HOLD：Soft Cap／钉／tiphead／Cap tip **不升**；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> 只 LAN `windows-server`。

## 根因（钉死）

tip PE egg 对 `vlet_nested_body`→`vlet_scalar_one`（10 参）与上游 `pipeline_asm_emit_vector_let_init_elf_c`→`vlet_nested_body`（6 参）用假 SysV／Win 杂交：

1. Call site：先把 `init`／`elem`（或 `init`／`ctx`）写入 r8／r9，再**覆盖**为后续参；栈只 push 4／0 槽，无 MSVC shadow＋home。
2. Callee：把 r8／r9 再存一遍当「第 5／6」，**从不**读 `[rbp+0x30…]` → `stack_slot_off=0`、`ta=1`（或 lit ref）→ `backend_enc_lea_rbp_to_rax_arch` −1 → CG002。
3. 非 stale `primary_array`；esz=1／field_mag=32 已证（11.47）；Darwin tip 同 fixture OK。

## ABI 修法（tip-only）

1. Host-gcc `-O2` 编译已有权威种子 `compiler/seeds/vector_let_init_nested_override.c`（MSVC 真四寄存器＋栈 home；标量环**内联**，不经 tip `vlet_scalar_one`）。
2. `compiler/scripts/win_tip_pe_inject_vlet_nested_override.py`：把 `.o` `.text`（0x4d0）写入 tip 死蛋 `vlet_scalar_one` VA `0x14013ac24`，按 tip `nm` 解析 `IMAGE_REL_AMD64_REL32`；对 short／mangled／stubdead／W 入口打 `jmp rel32` → override export＠`0x14013b0c4`。
3. **禁** Soft Cap G05 混 tip／整 dig_slim／升 tiphead／钉／Soft Cap。

### 复现（LAN windows-server）

```bash
# from tip bak md5 e1b269dc…
gcc -c -O2 -ffreestanding -fno-stack-protector \
  -o vlet_ov.o compiler/seeds/vector_let_init_nested_override.c
python3 compiler/scripts/win_tip_pe_inject_vlet_nested_override.py \
  compiler/xlang_asm.exe vlet_ov.o
# tip PE md5 → cb03960b29c40504f578f3eee1405c66
```

## 收刀矩阵（tip PE `cb03960b…`）

| fixture | 结果 |
|---------|------|
| empty dual `u8[10]=[]` | **OK** |
| dual_ptr_empty | **OK** |
| match10／one_arr nonempty | **OK**（原 CG002 `code_len≈12…22` **已消**） |
| e_fmtstyle nonempty dual | **OK**（无 P012、无 CG002） |
| hello／core.fmt | 仍 **P012**（fail-leave／while 另刀；**非假绿**） |
| Darwin match10 | OK（未 regress） |
| Soft Cap／钉／tiphead | **未升** |

## Residual／移交

- **CLOSE ACCEPT** 11.48：nonempty CG002 由 tip-only vlet override 解开；empty／dual／e_fmtstyle 无 P012。
- 下一刀 **OPEN 11.49**：hello／`core.fmt` **P012**（fail-leave／while／body soft-skip 链）。
