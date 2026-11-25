# Win tip L2 import-call-to-let CG002（matrix beat `win_tip_l2_product_matrix_5_5`）· **WIP grain**

> Beat：`win_tip_l2_product_matrix_5_5`。本粒：`let x = import.fn()` tip CG002 `code_len≈19`。
> tip PE **`fe82d4a49235…`→`a91c1b92c31e…`**（`.c76sli` struct_let_init import-call override）。
> 禁 Soft Cap G05／Prefer 体拷；禁假绿；禁 CloudAgent／升钉／自 CLOSE。

## DIG（诚实根因）

- 钉：`let a: i32 = types.placeholder()` → **CG002** `code_len≈19` num_labels=1 num_patches=0（parse／typeck OK）。
- 对照：`return types.placeholder()` 绿；`types.placeholder();` stmt 绿；`let a = local_fn()` 绿。
- Soft Cap Prefer `09fe` **同款 CG002**（只读；≠ tip-only Prefer 差；Prefer 非绿 oracle）。
- tip PE／Prefer host leftover `glue_emit_struct_type_let_init_elf_c`＠`0x14011ab20`（指纹 `mov eax,0x1ca8` stack-probe）对 CALL／METHOD let-init **在 emit 前返 −1**。
- tip.x Mac 权威：CALL 臂 `emit_expr`＋`store_retval_pair`；Mac／Ubuntu L2 5/5。

## 修（tip-only）

- seed：`compiler/seeds/win_tip_pe_overrides/struct_type_let_init_import_call_override.c`
  - STRUCT_LIT → `pipeline_asm_emit_struct_let_init_elf_c`
  - INT／FLOAT／BOOL／VAR／CALL／METHOD → `emit_expr`＋`store_retval_pair`（失败则 `store_rax`）
  - else −2（vector／array 等 Specialized face）
- inject：`compiler/scripts/win_tip_pe_inject_struct_let_import_call_override.py` → `.c76sli`；stub＠`0x14011ab20`→live。
- 附：Win `core/option/option.o`／`core/result/result.o` 曾为 175B stub-anchor；用 **本 tip PE** `-backend asm -c` 自编（gitignore；reproduce 见下）。

## 验收（本粒）

- `let a: i32 = types.placeholder()` tip build0 run0。
- Win `product_l2_matrix`：**仍 pass=3**（rv／hello／f32）；**si build0 run139**；**opt 仍 CG002** `code_len≈5345`。
- Mac／Ubuntu tip L2 仍 **5/5**（本粒只改 Win PE＋可再编 core .o）。

## Residual（移交同 beat）

- **Win64 `Option_i32`／`Result_*` 值参 import call ABI**：caller 只把 Option 低 8B 进 rcx、default 进 rdx；callee tip 自编体亦只收 rcx 8B 却读 `+8` value → 错值／SEGV。
  - 表象：`return option.unwrap_or_i32(s, 0)` exit≠42；full `tests/stdlib-import` build0 **run139**；`tests/option` 仍 CG002（后段）。
  - Soft Cap Prefer 对 full opt／si 停在 typeck T001（对照，非 oracle）。
  - **≠** 本粒 let-init store；勿假绿改 std 源布局。

## Reproduce

```bash
# from fe82 bak (store_retval slot_off already applied)
gcc -c -O2 -o /tmp/ov.o compiler/seeds/win_tip_pe_overrides/struct_type_let_init_import_call_override.c
python3 compiler/scripts/win_tip_pe_inject_struct_let_import_call_override.py compiler/xlang_asm.exe /tmp/ov.o
# refresh Win core objs with the patched tip:
./compiler/xlang_asm.exe -backend asm -c -o core/option/option.o core/option/mod.x
./compiler/xlang_asm.exe -backend asm -c -o core/result/result.o core/result/mod.x
```

## 非目标／禁

- Soft Cap 体拷；假绿删 option API；CloudAgent；`_dig` 入 git；升钉；自 CLOSE 11.77／本 beat。
