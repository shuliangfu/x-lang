# DIG SoftCap-full full_chain — Capless early → Capless-miss CALL finish falsified

Date: 2026-10-30 ~13:08 CST Asia/Shanghai
Tip at plant: `8d656135d` (= origin/dev; dig-only; no product code)
Isol-TT baseline sha12 `1f836615e0fc`
Isol-full_chain sha12 `eb3576c8fe3c`

## USER gap (reconfirmed)

LIVE SoftCap lit CallExpr: `mov eax,imm; spill; mov rdx,rax; near E8 call-mk` + frame `0x868`/`0x878`.
Isol-TT / smega_le / full_chain: thin `lea→rcx` + field-read + frame `0x1b8`; exit 1.

## DIG (Isol-native; ban LIVE SoftCap transplant)

1. SoftCap twin → SoftMega `@59b170` → SoftCap-full `@57effc`. SoftCap-full Capless `@555ed8`:
   ret≠0 → `@5890c8` `mov eax,0; jmp @58e997` **exits SoftCap-full**, skipping Capless-miss `@5890dc+`.
2. Capless SoftCap twin can early-claim success without lit call-mk; SoftCap-full trusts it and returns.
3. Capless-miss chain Isol-native CALL finish isomorphic to Capless CALL kind=3 miss:
   helpers `@557974`/`@55483c`/… → mov_imm_w `@53ff24` → `@523ba4` → `@57518c` →
   post_args `@57464c` → arch_E8 `@5264bc` → E8enc `@51a534` (Isol-native near E8).
4. SoftCap-full also calls `@57464c` `@588cf8` **before** Capless; still leaves emit=TT for SoftCap
   CallExpr (name/state not SoftCap lit call-mk). SoftCap-full never calls CE `@522c0c` / emit_args `@5752bc`.
5. Isol E8 writers: CE→E8enc; `@51a534` sole near-E8 with callers (`@52652b`/`@5265b3` via `@5264bc`);
   SoftCap-full reaches `@57464c`→`@5264bc` but SoftCap lit CallExpr emit stays TT.
6. Prior falsified: callsz_le / scap0 / AAA / DDD / YY155 / YY164 / smega_le.

## Plant Isol-full_chain

- Site: SoftCap-full `@5890c8` Capless early success → `jmp Capless-miss @5890dc` (+8 nop).
- Intent: after Capless >0, still run Capless-miss CALL finish (mov_imm + `@57464c`→E8).
- Builder: `_dig/build_isol_full_chain.py`
- Ban: LIVE SoftCap transplant / mega / letter pile / multi-site helper cascade.

## Win SoftCap cave `out_full_chain/` (2026-10-30 ~13:06 CST)

| probe | emit sha12 | n868/n878 | n1b8 | b80a | run |
|-------|------------|-----------|------|------|-----|
| p_ret_lit | `5b173cef1205`＝TT | 0/0 | 1 | 1 | **exit 1** |
| p_ret_fwd | `546a4c6d02df` | 0/0 | 1 | 1 | **exit 1** |
| p_ret_local | `018c76562e9e` | 0/0 | 1 | 1 | **exit 1** |

⇒ Capless early→miss force **does not** change SoftCap lit emit. Capless-miss either already
on path (Capless ret=0) or runs and early-success-exits via helper chain before mov_imm/`@57464c`
for SoftCap CallExpr — same TT thin. SoftCap lit call-mk still missing.

## Next DIG (single-site; ban transplant / letter pile)

Isol-native **real** SoftCap lit call-mk writer path that SoftCap CallExpr actually reaches
(which Capless-miss helper early-success exits SoftCap CallExpr; or tip glue
`glue_asm_emit_call_with_cleanup` / CE if args recoverable from SoftCap-full success) —
**not** LIVE SoftCap tree, **not** multi-site helper nop cascades.
