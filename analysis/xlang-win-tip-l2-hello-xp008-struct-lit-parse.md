# Win tip L2 hello XP008 struct lit parse（刀 11.72）· **OPEN／DIG**

> Gate：`tests/run-win-tip-l2-hello-xp008-struct-lit-parse-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_struct_lit_parse`（可改更准名）。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；保绿 gate71＋67／63–55 族。
> tip PE **`6a0f73a8656f…`**（11.71 后；本刀未修前）。
> 禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／回滚 11.67 wrap／升钉。

## 靶

- DIG tip 在 11.71 named_init 修后的下一 XP008／P012 **真残**；证据够 tip-only 小修；否则 HOLD-ready。

## DIG（进行中）

- 11.71 后矩阵（Win tip PE `6a0f73a8656f…`）：
  - OK：nested／`*IoBatchBuf`／`id(A):A`／`id(*A):*A`／cast `*A`／`p.a`／`x.s.a`／**`check std/context/context.x`**。
  - FAIL：`check std/context/mod.x`／`std/fmt`／`examples/hello.x` → P001／XP008 parse skip＠mod `background`（byte≈1973／2059）。
- 隔离：
  - `let _rc: A; _rc.a = 0; return _rc` → **OK**
  - `let _rc: A = { a: 0 }`／`return { a: 0 }`／top-level `const`／`let` struct-lit → **P001 parse skip**
- 表象 hello XP008＝dep prerun←`std.context/mod.x` struct-lit；非 context.x typeck（已绿）。
- Soft Cap Prefer 对照／tip stub 位点：DIG 续。

## 修

- （待 DIG 钉 tip-peel／缺 live twin 后再 tip-only；禁 Soft Cap 混 tip。）

## 验收

- （未收。）gate72 骨架＋docs；gate71 保绿勿 regress。

## Residual／禁

- Soft Cap G05；回滚 11.67；假绿；CloudAgent；`_dig` 入 git；勿自 CLOSE。
