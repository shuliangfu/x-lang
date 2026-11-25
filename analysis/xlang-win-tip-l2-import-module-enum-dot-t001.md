# Win tip L2 import_module_enum_dot T001（刀 11.75）· **CLOSE ACCEPT**

> Gate：`tests/run-win-tip-l2-import-module-enum-dot-t001-gate.sh`（OK exit0）。
> Beat：`win_tip_l2_import_module_enum_dot_t001`
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；保绿 gate74（HOLD 位可随绿改）＋gate73＋72／71／67／63–55。
> tip PE **`3dd483308a46…`→`c6f6fb583b70…`**（`.c75enum` skip_one_enum_register inject）。
> 禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／回滚 11.67 wrap／升钉／删 enum。

## DIG（诚实根因）

- 表象：被 import 模块含 `enum`／`export enum` 时，`import_alias.fn()` → **T001** `no impl for type with method`（submit_read／driver.* 为 11.74 表象）。
- 缩小钉死：
  - `only_fn`／`+struct`／`+trait` 绿；**enum 在 fn 前** → T001；**fn 在 enum 前** → 绿；enum 后 fn 不可见于 import.dot；enum 前 fn 仍绿。
  - Soft Cap Prefer `09fe` **同款**（只读；≠混 tip；Prefer 非绿 oracle）。
- **真残**：tip W stub `parser_asm_skip_one_enum_register_into_c`＠`0x140618898` 为 **`e9`→`parser_asm_module_append_enum_variants_and_skip_body_into_c`＠`0x140618374`**。
  - 调用方传 `(lex, source, module, name_buf, var_buf)`；append 把 `name_buf` 当 `enum_idx`，且未消费 `enum Name`／`{` → 后续 top-level `export function` 对 dep／import.dot 查找失败。
  - Soft Cap Prefer 同款误靶；**≠** 禁 tip-only twin（同 11.73 header）。

## 修

- tip-only host-gcc twin：`compiler/seeds/win_tip_pe_overrides/stale_skip_one_enum_register_into_override.c`
  （`pthin_skip_tl.x` skip_one_enum_register ABI；调 tip lex／copy／`try_register_enum_name`／`append_enum_variants`）。
- inject：`compiler/scripts/win_tip_pe_inject_skip_one_enum_register_override.py` → 新节 **`.c75enum`**；stub＠`0x140618898`→live；`--nm-exe` bak_pre1149。
- **无 Soft Cap 体拷**；未回滚 11.67；未升钉；未删 enum。

## 验收

- gate75 OK exit0（+enum 绿；only_fn／+struct／core.submit_read 保绿；stub 不再 e9→append）。
- 保绿：gate74（随绿可改）／gate73／72／71／67／63–55 OK。
- hello tip `check` 仍 EXIT0（不 regress 11.73）。
- 附：`std/io/mod.x` tip `check` **EXIT0**（submit_read 表象清）。
- L2 1/5＠`58e34910f` 未抬分宣称；经理已 CLOSE ACCEPT；移交 11.76。

## Residual

- 移交下刀由经理裁定（本刀 ACCEPT-ready 停）。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；假绿（删 enum／改 std 源）；CloudAgent；`_dig` 入 git；已 CLOSE；11.76 另开。
