# DIG `src_softcap_s25_emit` (10.60 SoftCap)

**Date:** 2026-10-30 ~20:00 CST (Asia/Shanghai)
**Goal:** Fold Isol s25 semantics (rcx=sret + imm→rdx + frame/shadow) into durable **source-level SoftCap** emit so tip SoftCap (not only PE Isol host) greens lit/fwd/local/let.
**Isol host (对照 only):** `host_967_s25.exe` sha12 `e53841ce0e24`
**tip SoftCap = PROD SoftCap:** `lab_SoftCap_76795.exe` sha12 `7a2cf5da581a` (**not bumped**)
**pin `ecdb5cc1e`:** untouched
**Ban:** PE Isol as close / LIVE SoftCap transplant / tip@121278 / join / epi / mega / arg-loop / hollow·skip as close

## 0) Gate (this beat)

| host | sha12 | lit | fwd | local | let | note |
|---|---|---|---|---|---|---|
| Isol `host_967_s25` | `e53841ce0e24` | **0** `5c6778769c3c` | **0** `a99121ae7a80` | **0** `36d26fcc9657` | **0** `d16c78ade1f2` | cold reconfirm |
| tip SoftCap (=PROD) | `7a2cf5da581a` | **CG002** exit1 | **CG002** exit1 | **CG002** exit1 | **CG002** exit1 | code_len=0 / no USER |
| Darwin tip Cap soft `./compiler/xlang` | `0c0a41335a35` | **0** | **0** | **0** | — | Cap soft contract proof (ARM64) |

**Gate green ≠ PROD bump / ≠ close knife.** Isol green ≠ tip SoftCap green.

## 1) Isol s25 ↔ tip Cap soft source map (钉死)

| Isol PE plant | SoftCap Capless site | tip Cap soft twin | status |
|---|---|---|---|
| Capless USER16 `sub20; x+1→rdx` | `@57ba3b` / len `@57ba94` | `glue_asm_emit_call_with_cleanup` win_shadow `sub rsp,32` + BinaryExpr emit + `backend_enc_mov_rax_to_arg_reg_arch(k=1)` under `sret_reg_shift` | Cap soft **present** |
| c1→c2 `4889c1e8`→`4889c2e8` | fixup scan1 | `pipeline_asm_emit_set_call_sret_reg_shift_c(1)` → arg pack uses `eff_reg_max=reg_max-1` (BinaryExpr → rdx) | Cap soft **present** |
| let_sret `lea[rbp-0x38]`→`mov[rbp-0x50]` | fixup scan2 | `struct_let_init_thin` `sret_home_off` + `return_sret_thin` `w1521_rs_fwd_call_x86` (lea home → arg0=rcx, shift=1) | Cap soft **present** |
| main_imm9 `mov eax,9; mov rdx,rax` | fixup scan3 | tip Cap soft IntegerLit SoftCapCallExpr arg → `enc_mov_rax_to_arg_reg` with shift | Cap soft **present** |

**Nail:** tip Cap soft already encodes Isol s25 semantics. Darwin Cap soft p_ret_* run=0 proves Cap soft contract. SoftCap Capless PE `@57ba3b` is **not** tip Cap soft — SoftCap Capless is SoftCap-internal Capless emit (frozen PE Capless slot). **No tip Capless source twin exists.**

## 2) Source-level gap (钉死)

1. **tip SoftCap ≠ tip Cap soft.** tip SoftCap today = PROD SoftCap `7a2cf5da581a` Capless PE path. Compiling `p_ret_*` → CG002 `asm_codegen failed` / `code_len=0` / no USER.
2. **Isol s25** greens by planting Capless USER16 + 3-scan fixup into SoftCap Capless PE. That is Isol对照, **not** tip SoftCap, **not** source fold.
3. **Closing tip SoftCap four-gate** requires either:
   - **(A)** SoftCap Capless source twin in tip (does not exist — Capless is SoftCap PE Capless), or
   - **(B)** SoftCap Cap soft Windows rebuild from tip Cap soft so tip SoftCap uses Cap soft emit (rcx=sret / imm→rdx / win_shadow / let sret_home) instead of Capless PE.
4. LIVE SoftCap transplant / matching LIVE spill / dropping Isol sub20 = **hard ban** (see `dig_live_isol_parity`).
5. PE Isol plant as tip SoftCap close = **hard ban** (Isol host 仅对照).

## 3) Plant attempt (this beat)

**Plant:** Cap soft emit contract reconfirm + tip SoftCap four-gate probe (no PE Isol / no LIVE transplant / no PROD bump).

| attempt | result |
|---|---|
| Isol cold four-gate | **GREEN** (USER shas stable) |
| tip SoftCap (=PROD) four-gate | **RED** CG002 all four (no USER) |
| Darwin tip Cap soft p_ret_lit/fwd/local | **GREEN** run=0 |
| tip Cap soft source edit | **none needed** — Cap soft already encodes Isol recipe (map §1); SoftCap Capless PE gap is SoftCap Capless twin / SoftCap Cap soft rebuild, not tip Cap soft regression |

**No tip Cap soft code change this beat** — changing Cap soft without SoftCap Cap soft Windows rebuild cannot green tip SoftCap (PROD Capless PE still drives SoftCap USER emit). PE Isol plant of Capless USER16 as tip SoftCap = banned close shape.

## 4) Next single point

**`softcap_capsoft_win_rebuild`** (or SoftCap Capless source twin if Capless .x ever surfaces): rebuild SoftCap Cap soft from tip Cap soft on Win cave so tip SoftCap emits Isol-shaped USER via Cap soft (rcx=sret + imm→rdx + win_shadow + let sret_home) **without** PE Isol plant / without LIVE transplant. Still **no PROD / pin bump** until tip SoftCap four-gate cold-greens.

Optional side: Ubuntu tip-cold after Cap soft rebuild stays green.

## 5) Artifacts

- This DIG: `_dig/dig_src_softcap_s25_emit.md`
- Isol persist: `_dig/build_isol_967_s25.py` / `host_967_s25.exe` `e53841ce0e24`
- Parity DIG: `_dig/dig_live_isol_parity.md`
- tip Cap soft host: `./compiler/xlang` sha12 `0c0a41335a35` (Darwin)
- PROD SoftCap `7a2cf5da581a` / pin `ecdb5cc1e`: **untouched**

## 6) Open bans unchanged

CloudAgent / 10.74 / HARD BAN / mega / 假绿 / LIVE SoftCap transplant / PE Isol as close / arg-loop / tip@121278 / join / epi / hollow·skip_1a0 as close / letter-pile.
