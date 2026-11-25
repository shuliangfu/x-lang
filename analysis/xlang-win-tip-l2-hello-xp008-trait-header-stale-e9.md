# Win tip L2 hello XP008 trait header stale e9（刀 11.73）· **CLOSE ACCEPT**

> Gate：`tests/run-win-tip-l2-hello-xp008-trait-header-stale-e9-gate.sh`（OK exit0）。
> Beat：`win_tip_l2_hello_xp008_trait_header_stale_e9`
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；保绿 gate72＋71／67／63–55。
> tip PE **`2e92a66da052…`→`3dd483308a46…`**（.c73thdr header inject）；**正式 CLOSE ACCEPT**＠docs `84614efe7`。
> 禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／回滚 11.67 wrap／升钉。

## DIG（诚实根因）

- `examples/hello.x` tip `check` 曾 **EXIT 139 SEGV**；链 hello→`std.fmt`→`std.io`（`export trait Reader/Writer`）。
- 崩＠`p12g_store_i32`＠`0x1406227df`；调用自 `parser_asm_skip_one_trait_into_slice_c`→**`parser_asm_skip_one_trait_header_into_c`＠`0x1406087c4`**。
- **真残**：header stub **`e9`→`p12g_store_i32`＠`0x140622780`**；三参 `(lex,source,ent_img)` 被当成 store `(base,off,val)`。
- Soft Cap Prefer `09fe` 只读：同款误靶；最小 trait 亦 SEGV；Prefer hello 更早 XP008＠core.fmt；**≠混 tip**。

## 修

- tip-only host-gcc twin：`compiler/seeds/win_tip_pe_overrides/stale_skip_one_trait_header_into_override.c`
  （`pthin_skip_tl.x` header ABI；调 tip lex／copy／`p12g_store_i32`）。
- inject：`compiler/scripts/win_tip_pe_inject_skip_one_trait_header_override.py` → 新节 **`.c73thdr`** PLACE `0x14a25b000`；stub＠`0x1406087c4`→live；`--nm-exe` bak_pre1149。
- **无 Soft Cap 体拷**；未回滚 11.67；未升钉。

## 验收

- gate73 OK exit0（header 不再 e9→store；Reader＋context）。
- 保绿：gate72／71／67／63／62／61／60／59／56／55 OK。
- 附：`examples/hello.x`／`std/fmt/mod.x`／`std/context/mod.x` tip `check` **EXIT0**。
- L2 1/5＠`58e34910f` 未抬分宣称；**勿自 CLOSE**。

## Residual

- 直接 `check std/io/mod.x` 仍 T001 `no impl for type with method submit_read`（hello 路径绿）→ **移交 11.74** DIG residual HOLD（真残＝import 模块 enum→module.dot）。
- L2 1/5＠`58e34910f`。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；假绿；CloudAgent；`_dig` 入 git；勿自 CLOSE。
