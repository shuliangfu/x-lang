# Win tip L2 Option/Result by-value import-call ABI（matrix beat `win_tip_l2_product_matrix_5_5`）· **WIP grain**

> Beat：`win_tip_l2_product_matrix_5_5`。本粒：Win64 `Option_i32`／`Result_*` 值参／值返 ABI。
> tip PE **`a91c1b92c31e…`→`a57b37b01eed…`**（`.c77nlay` named_layout floor＋mid_named nop＋mid-class 24→16）。
> 禁 Soft Cap 体拷／假绿／CloudAgent／升钉／自 CLOSE。

## DIG（诚实根因）

- Win tip `Option_i32` 字段 **value@+8**（align），但 `glue_type_named_layout_size_any_module_elf_c` **soft-floor→8**。
- Mac ARM64 **value@+4／size8** 单 GP → L2 绿；Win 8B 打包丢 value → `unwrap_or_i32`≠42／SEGV。
- tip.x **w1545** 规定 9–16 named **byref／sret**；tip PE `glue_sysv_arg_byte_size_c` 有 mid→24，但 **`pipeline_asm_emit_param_home_elf_c` 无 mid byref／sret**（仅 dual-GP）。
- 抬 size→16 且走 mid byref 时：**caller byref／sret ≠ callee dual-GP** → 仍错／SEGV。
- Soft Cap Prefer 对 full opt／si 停 typeck（对照，非 oracle）。

## 修（tip-only）

1. seed：`compiler/seeds/win_tip_pe_overrides/named_layout_option_result_size_override.c`  
   - 调 orig named_layout；`Option_*`／`Result_*` soft≤8 → **16**。
2. inject：`compiler/scripts/win_tip_pe_inject_named_layout_option_result_override.py` → `.c77nlay`  
   - JMP named_layout＠`0x1402955a1`；tramp 回 orig。  
   - **`w1545_win_mid_named_sz`＠`0x1405643d0` → `xor eax,eax; ret`**（禁 mid byref／sret，与 tip param_home dual-GP 对齐）。  
   - glue_sysv mid-class **24→16**（双保险）。
3. 用本 tip 重编 `core/option/option.o`／`core/result/result.o`（gitignore）。

## 验收

- `return option.unwrap_or_i32(s,0)` → **42**；si_b／si_full／matrix **si 绿**。
- Win `product_l2_matrix`：**pass=4**（rv／hello／f32／**si**）；**opt 仍 CG002** `code_len≈6361` first patch `.Lf0_1`。
- Mac／Ubuntu tip L2 仍 **5/5**（本粒只改 Win PE＋可再编 core .o）。

## Residual（移交同 beat）

- **opt CG002** `tests/option/main.x`：`code_len≈6361` num_labels=33 num_patches=69；first patch **`.Lf0_1`**（label match＠idx=1 offset=2074 仍失败）。opt_min／or 短探针可 build；全量仍红。
- 长线：tip PE `emit_param_home` 补齐 w1545 mid byref／sret 后可恢复 mid_named（真 MS ABI），撤 dual-GP 权宜。

## Reproduce

```bash
# from a91c (import-let) bak
gcc -c -O2 -o /tmp/nlay.o compiler/seeds/win_tip_pe_overrides/named_layout_option_result_size_override.c
python3 compiler/scripts/win_tip_pe_inject_named_layout_option_result_override.py compiler/xlang_asm.exe /tmp/nlay.o
./compiler/xlang_asm.exe -backend asm -c -o core/option/option.o core/option/mod.x
./compiler/xlang_asm.exe -backend asm -c -o core/result/result.o core/result/mod.x
```

## 非目标／禁

- Soft Cap 体拷；假绿改 std API／布局；CloudAgent；`_dig` 入 git；升钉；自 CLOSE。
