# Win tip L2 hello XP008 struct lit parse（刀 11.72）· **CLOSE ACCEPT**

> Gate：`tests/run-win-tip-l2-hello-xp008-struct-lit-parse-gate.sh`（OK exit0）。
> Beat：`win_tip_l2_hello_xp008_struct_lit_parse`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；保绿 gate71＋67／63–55 族。
> tip PE **`6a0f73a8656f…`→`2e92a66da052…`**（.c72lbr lbrace inject）；**正式 CLOSE ACCEPT**＠docs `2b398e1b7`。
> 禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／回滚 11.67 wrap／升钉。

## DIG（诚实根因）

- Fixture `let _rc: A = { a: 0 }`／`return { a: 0 }`：tip `check` 曾红 **P001 parse skip**；SC Prefer 同 fixture 绿（SC≠抬 tip）。
- tip 符号表坏（nm 失败）；VA＝xlang−`0x1240`（array stub 校验）。
- tip mapped：`parse_primary_x`＠`0x1405e4d58` 满体；**唯一** e8→`primary_lbrace` stub＠`0x1405e4d50`＝**e9→suffix_loop** `0x1405e0e38`（无 LBRACE 消费／无 struct-lit）。
- tip 孤儿 live：`struct_lit_fields`＠`0x1405e5554`／`anonymous_struct_lit`＠`0x1405e5c04`／finish＠`0x1405e5e84`（prologue 在；全 tip 无 e8 调用者，因 lbrace 未分派）。
- tip ptr 可用：`lbrace_looks_like_block_ptr`＠`0x1405dd4ff`→C looks_like_block；`parse_anonymous_struct_lit_ptr`＠`0x1405dd97c`→W anon＠`0x1405e5c04`。
- 与 11.55／11.61 同族：tip 缺 live primary 臂；`[` 已 11.61；`{` 本刀。

## 修

- tip-only host-gcc twin：`compiler/seeds/win_tip_pe_overrides/stale_primary_lbrace_x_into_override.c`
  （Prefer `parser_asm_primary_lbrace_x_into_c` ABI；调 tip looks_like_block／anon_ptr／suffix_loop／block_ptr＋tip `wrap_block_ref_as_expr_primary_c`）。
- inject：`compiler/scripts/win_tip_pe_inject_primary_lbrace_override.py` → 新节 **`.c72lbr`** PLACE `0x14a25a000`；stub＠`0x1405e4d50`→live；`--nm-exe` bak_pre1149。
- **无 Soft Cap 体拷**；未回滚 11.67；未升钉。

## 验收

- gate72 OK exit0（struct lit＋field-assign＋A_val＋nested＋context.x）。
- 保绿：gate71／67／63／62／61／60／59／56／55 OK。
- 附：`std/context/mod.x` `check` 现 EXIT0；`return { a: 0 }` OK。
- L2 1/5＠`58e34910f` 未抬分宣称；经理已 CLOSE ACCEPT；移交 11.73。

## Residual

- `examples/hello.x` tip `check` 仍 **SEGV／XP008 包装残**（非本刀 gate 靶；struct-lit 路径已绿）→移交 **11.73** `after_struct_lit`。
- L2 1/5＠`58e34910f`。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；假绿；CloudAgent；`_dig` 入 git；勿自 CLOSE。
