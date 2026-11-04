# Win tip L2 hello XP008 struct lit parse（刀 11.72）· **OPEN／DIG**

> Gate：`tests/run-win-tip-l2-hello-xp008-struct-lit-parse-gate.sh`（docs OK；Win HOLD exit2 until struct-lit green）。
> Beat：`win_tip_l2_hello_xp008_struct_lit_parse`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；保绿 gate71＋67／63–55 族。
> tip PE **`6a0f73a8656f…`**（11.71 后；本刀未修）；docs tip **`9efc7878b`**。
> 禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／回滚 11.67 wrap／升钉。

## 靶

- DIG tip 在 11.71 后下一 XP008／P012 **真残**；证据够 tip-only 小修；否则 HOLD-ready。

## DIG（诚实 · 进行中）

### 表象／矩阵（Win tip PE `6a0f73a8656f…`）

- OK：nested／`*IoBatchBuf`／`id(A):A`／`id(*A):*A`／cast `*A`／`p.a`／`x.s.a`／field-assign `let _rc:A; _rc.a=0`／**`check std/context/context.x`**。
- FAIL：`let _rc: A = { a: 0 }`／`return { a: 0 }`／top-level const／let struct-lit → **P001 parse skip**；`std/context/mod.x`／`std/fmt`／`examples/hello.x` → XP008 dep prerun（包装同一残）。
- Soft Cap Prefer `09fe` 只读：同 struct-lit fixture **OK**（SC≠抬 tip）；SC `mod.x`／hello 另有偏移残，不作本刀假绿对照。

### 位点／对照

- tip 符号表坏（nm／objdump -t 失败）；用 **xlang.exe 符号 VA − `0x1240`** 映 tip（已用 tip array stub `0x1405e4d48`＝xlang `0x1405e5f88`、paren `0x1405e4d40` 校验）。
- tip mapped：
  - `parse_primary_x`＠**`0x1405e4d58`**（INT3 **命中**／crash）
  - `primary_literal`＠`0x1405e0670`（INT3 命中）
  - `primary_suffix_loop`＠`0x1405e0e38`（INT3 命中）
  - `struct_lit_fields`＠`0x1405e5554`／`anonymous_struct_lit`＠`0x1405e5c04`／`finish_struct_lit_from_type_ident`＠`0x1405e5e84`：体在（prologue），INT3 **未命中**；全 tip `.text` **无 e8 调用者**（孤儿）。
- SC Prefer：`__stale_prim_…parse_primary_x…`＠`0x1405f1eb8`＝**e9→live** `parser_asm_parse_primary_x_into_c`＠`0x140009adc`；另有 live struct_lit `_x_into`。tip primary＝满体非 trampoline，且未走到 struct_lit 解析器。
- 与 11.55／11.61 同族：tip 缺 live primary 分派能力；`{…}` struct-lit 未挂上（`[` 已由 11.61 array stub 修）。

### 修靶（未落地）

- tip-only：为 primary brace／struct-lit 补 live twin（Prefer `pthin_expr_primary.x` 权威）＋JMP／inject；**禁** Soft Cap 体拷；未回滚 11.67。
- 孤儿 fields／anon／finish  alone 不够（路径未调到）。

## 修

- （未修 PE；DIG 续／或证据不足则 HOLD-ready。）

## 验收

- gate72 docs OK；Win 仍 HOLD exit2（struct lit 红）。
- 保绿：gate71 族勿 regress（本刀未动 PE）。

## Residual／禁

- Soft Cap G05；回滚 11.67；假绿；CloudAgent；`_dig` 入 git；勿自 CLOSE。
