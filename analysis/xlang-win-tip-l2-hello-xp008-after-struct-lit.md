# Win tip L2 hello XP008 after struct lit（刀 11.73）· **DIG**

> Gate：`tests/run-win-tip-l2-hello-xp008-after-struct-lit-gate.sh`（DIG／HOLD exit2 until live header）。
> Beat：`win_tip_l2_hello_xp008_after_struct_lit`（准名可改 `win_tip_l2_hello_xp008_trait_header_stale_e9`）。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；保绿 gate72＋71／67／63–55。
> tip PE **`2e92a66da052…`**（11.72 .c72lbr 后；本刀未改 PE）；docs tip 随 DIG 文档推送。
> 禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／回滚 11.67 wrap／升钉。

## DIG（诚实根因）

- `examples/hello.x` tip `check` → **EXIT 139 SEGV**（空日志）；非 gate72 struct-lit 靶。
- 依赖链：`hello`→`std.fmt`→`std.io`；`std/io/mod.x` 含 **`export trait Reader`／`Writer`**。
- 直接 `check std/io/mod.x`／最小 `export trait Reader { function read(self): i32; }` → tip **SEGV 139**。
- gdb：崩＠`p12g_store_i32` preferred **`0x1406227df`**（`mov %al,(%rbx)`）。
- 帧参：`base=rcx` 像指针；**`off=rdx`／`val=r8` 实为指针**（非 i32）→ `base+off` 越界写。
- 调用链：`parser_asm_skip_one_trait_into_slice_c`＠`0x140606bac` → call **`parser_asm_skip_one_trait_header_into_c`＠`0x1406087c4`**。
- **真残**：tip `parser_asm_skip_one_trait_header_into_c` 首字节 **`e9`→`p12g_store_i32`＠`0x140622780`**（相对 `+0x19fb7`）——**stale trampoline 误靶**；三参 `(lex,source,ent_img)` 被当成 `(base,off,val)`。
- `parser_asm_skip_one_trait_body_into_c`＠`0x1406088d8` 有真 prologue（非本刀崩点）；`p12g_store_i32` 体与 Soft Cap Prefer **同构**（非 store 本身坏）。
- Soft Cap Prefer `09fe`（`C:/xlang_tmp/prod_softcap/lab_SoftCap_76795.exe`）**只读对照**：
  - Prefer `header` 同款 **`e9`→自 PE 的 `p12g_store_i32`**（相对位移同 `0x19fb7`）；最小 trait 夹具 Prefer 亦 SEGV。
  - Prefer `check examples/hello.x` → **XP008**＠`core.fmt`（更早 parse skip；未同显 std.io trait SEGV）。
  - **≠** Soft Cap 混 tip；≠抬 Soft Cap。

## 修靶（未做／下一 plant）

- tip-only：host-gcc／源 `compiler/src/asm/pthin_skip_tl.x` `parser_asm_skip_one_trait_header_into_c` live twin＋新节 inject；stub＠`0x1406087c4` `e9`→live（仿 11.71／11.72）。
- **禁** Soft Cap 体拷；header 源约 4KB＋多 `parser_asm_lex_*`／`p12g_*` 解析依赖；P12g RFC 记大函数纯 asm 槽位债——twin 须走 host-cc／既有 tip 符号。
- 验收预期：`Reader`／`std/io/mod.x`／hello 不再 SEGV＠`p12g_store`；gate73 OK；保绿 gate72＋71／67／63–55；L2 1/5 勿 regress。

## Residual（当前）

- hello／`std.io` trait 路径 tip **SEGV**（header stale e9）；未 plant PE。
- Prefer 同族 header 误靶＝产品历史债；tip 因 11.60–11.72 走得更远才在 hello 上爆 SEGV。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；假绿（header 恒 return0 冒充）；CloudAgent；`_dig` 入 git；勿自 CLOSE。
