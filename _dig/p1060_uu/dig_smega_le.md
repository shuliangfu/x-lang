# DIG SoftMega smega_le — SoftMega size≤16 (skip ARM egg) falsified

Date: 2026-10-30 ~13:10 CST Asia/Shanghai
Tip at plant: `c12201522` (dig-only; no product code)
Isol-TT baseline sha12 `1f836615e0fc`
Isol-smega_le sha12 `984e58dc6677`

## USER gap (reconfirmed; not ba0a)

LIVE `out_LIVE_p_ret_lit` `dbaab1c7ce70` main@~14f8:
`sub rsp,0x878; lea rcx,[rbp-0x28]; mov eax,0xa; spill; mov rdx,rax; call mk`

Isol-TT `5b173cef1205`:
`sub rsp,0x1b8; lea rcx,[rbp-0x28];` then **immediate field-read** (no imm→rdx, no call mk)

W = 3×i64 = 24B >16. Frames thin ≠ `0x868`/`0x878`.

## SoftMega / SoftCap-full map (Isol-native)

1. SoftCap twin kind 0x31 → SoftMega wrapper `@57ef78` → body `@59b170` (LIVE SoftCap `@289dcb` **≠** this slot; transplant **禁**).
2. SoftMega `@59b4e0` / `@59b911` → bridge `@59aa8c` → SoftCap-full `@57effc` (YY155: **no** CALL kind=3 / CE / h_emit).
3. SoftMega size gate `@59b608`: `cmp size,0x10; setg; je@59b617→@59b85d` (≤16).
   >16 fallthrough → sole ARM egg call `@59b6a9→@57426c` (const `0x02990030`).
   **LIVE has ZERO** that egg const. Isol-only wrong-arch path.
4. SoftCap-full **does** call Isol `@1fff*` helpers isomorphic to LIVE SoftCap `@77cbe` family — still **no** lit SoftCap CallExpr call-mk.
5. LIVE SoftCap early callees `@2818c1` / `@28a1f6`… **no** Isol body match (cannot plant without LIVE SoftCap transplant).
6. E8enc `@514434` sole caller CE `@522c0c` (6 Capless-side callers); SoftMega/full BFS does not reach CE for this CallExpr.
7. callsz_le forced SoftCap **twin** ≤16 helpers — SoftMega still sees real size; twin helpers **≠** call-mk (prior beat).

## Plant Isol-smega_le

- Site: SoftMega `@59b617` `je →@59b85d` → `jmp ≤16 @59b85d` (+nop). Keep cmp/setg.
- Intent: >16 SoftCap CallExpr skip ARM egg; take SoftCap-full emit path.
- Builder: `_dig/build_isol_smega_le.py`
- Ban: LIVE SoftCap transplant / mega / letter pile.

## Win SoftCap cave `out_smega_le/`

| probe | emit sha12 | n868/n878 | n1b8 | b80a | run |
|-------|------------|-----------|------|------|-----|
| p_ret_lit | `5b173cef1205`＝TT | 0/0 | 1 | 1 | **exit 1** |
| p_ret_fwd | `546a4c6d02df` | 0/0 | 1 | 1 | **exit 1** |
| p_ret_local | `018c76562e9e` | 0/0 | 1 | 1 | **exit 1** |

⇒ SoftMega size≤16 force **does not** change SoftCap lit emit (already on SoftCap-full path, not ARM egg). SoftCap-full success without call-mk **holds**.

## Next DIG (single-site; ban transplant)

Isol-native helper that writes `mov eax,imm`＋`mov rdx,rax`＋`E8` (CE / Capless CALL encode / `emit_call_*` if still linked), then SoftCap-full／glue >16 sret success 后单点 call — **not** LIVE SoftCap tree.
