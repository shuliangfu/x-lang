# Win tip L2 hello XP008 named init_named miss（刀 11.71）· **CLOSE ACCEPT**

> Gate：`tests/run-win-tip-l2-hello-xp008-named-init-named-miss-gate.sh`（OK exit0）。
> Beat：`win_tip_l2_hello_xp008_named_init_named_miss`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.59–**11.70** 绿族／HOLD 勿 regress。
> tip PE **`26ec339d5388…`→`6a0f73a8656f…`**（at_end subtract stub）；经理 CLOSE ACCEPT＠`0ab799e4a`。
> 禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。

## DIG（诚实根因）

- Fixture `min_A_val.x`：tip `check` 曾红 `expected  , found )`；SC Prefer `check` 绿。
- Live dig（ASLR-safe；hook `init_named_at`＠`0x1402A9CA1`；dig-only 未入 tip 产品／未入 git）：
  - tip：4× init_named，名＝`)`／` `，RA_pref＝`0x140647a6c`（＝11.59 live `named_type_x` 内 call＠`0x140647a67` 返回；**非**另路 path-builder）。
  - SC Prefer：4× init_named，名＝`A`，RA_pref＝`0x1406531eb`（`parse_named_type_x`＠`0x140652d78`）。
- 订正 11.70「跳过 init_named」：tip **有**调 init_named，但 name 字节错。
- 根因＝tip `parser_asm_copy_slice_to_name64_at_end_buf`＠`0x1405c1cec` 为 **裸 E9→start-pos `*_buf_c`＠`0x1405c1b68`**，丢掉 `start = end_pos - nlen`（与 `pthin_lex_skip.x` Prefer-M2 注释／`parser.x` 权威一致）。step 后 `lex_pos` 作 end 时，复制的是 IDENT **之后**的 `)`／空格。
- same_kind 仍靠 kind-arg8；slot 被错名 init 后 equal_named 对 `)` vs ` ` → diag。
- 无 Soft Cap 字节混 tip；11.67 wrap＠`0x140647bb0` 未动。

## 修

- tip-only stub＠`0x140647fb0`：`movsxd rax,r9d; sub r8,rax; jmp 0x1405c1b68`；`0x1405c1cec`→stub。
- 脚本：`compiler/scripts/win_tip_pe_patch_copy_slice_at_end_subtract.py`。
- Gate71 OK；nested／slice／`*IoBatchBuf`／array-let／named_type／IF／parse-skip gates OK。
- 复验 dig：tip init_named 4× 名＝`A`（对齐 SC）。

## 验收

- gate71 OK exit0（A_val／`*A`／context／nested／ptr）。
- 保绿：gate67／63／62／61／59／56／60 OK。
- L2 1/5＠`58e34910f` 未抬分宣称；P012／hello XP008 未本刀宣称清。
- **正式 CLOSE ACCEPT**（经理裁定＠`0ab799e4a`／PE `6a0f73a8656f…`）。

## Residual（若有）

- hello／`std.context/mod.x` 仍 XP008／P001＝**struct lit** `{ handle: … }`（移交 11.72）；L2 1/5＠`58e34910f`。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；force equal／force name；CloudAgent；`_dig` 入 git。
