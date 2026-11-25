# Win tip L2 f32 store_retval slot_off（matrix beat `win_tip_l2_product_matrix_5_5`）· **ACCEPT grain**

> Beat：`win_tip_l2_product_matrix_5_5`（经理裁定；11.77 DIG residual HOLD／pause，勿 tip-peel 空转）。
> 本粒：抬 **f32** SEGV → run0；Win tip L2 **2/5→3/5**。
> tip PE **`c6f6fb583b70…`→`fe82d4a49235…`**（store_retval slot_off prologue patch）。
> 禁 Soft Cap G05／Prefer 体拷；禁假绿删 f64；禁 CloudAgent／升钉／自 CLOSE 自举刀。

## DIG（诚实根因）

- 表象：`tests/float/f32_f64.x` tip `-o` build0 → run **SEGV 139**；产物 `mov %rax, 0x7c….c0(%rbp)`（高位不定）。
- Soft Cap Prefer `09fe`：`mov %rax, -0x20(%rbp)` run0（只读对照）。
- tip `glue_block_body_emit_let_init` 有 Prefer-M2 clamp；f64 终态走 **`glue_store_retval_pair_to_rbp_elf_c`** smash T＠`0x14012ae98`（frame `0x1368`）。
- smash 序言把 **r8（elf_ctx）再写进 `-0x30(%rbp)`**，**从不读第 5 参 slot_off＠`[rbp+0x30]`**；随后 `enc_store` 用 `elf_ctx±8` 当帧偏移 → 砸 disp。
- Soft Cap Prefer 同款 smash 序言，但 Prefer **F10 enc_store clamp**（`|off|>0x1000→0x18`）掩盖；**≠** tip 可抄 Prefer 节。

## 修（tip-only）

- 脚本：`compiler/scripts/win_tip_pe_patch_store_retval_slot_off.py`
- ＠`0x14012aec0`：`4c89c0488945d0` → `8b4530488945d0`（`mov eax,[rbp+0x30]; mov [rbp-0x30],rax`）。
- 产物：`x/y/z` → `-0x18/-0x20/-0x28`（与 Soft Cap Prefer 同形）；f32 matrix **OK run0**。

## 验收

- Win `product_l2_matrix.sh`：**pass=3**（rv／hello／**f32**）；opt／si 仍 CG002（另粒）。
- Mac／Ubuntu tip L2 仍 **5/5**（本粒只改 Win PE）。
- 无 Soft Cap 体拷；未升钉；未自 CLOSE 11.77。

## Residual

- opt CG002 `code_len≈5031` labels／patches；si CG002 `code_len≈71`；移交同 beat 续抬。
