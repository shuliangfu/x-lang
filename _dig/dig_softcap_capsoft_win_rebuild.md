# DIG `softcap_capsoft_win_rebuild` (10.60 SoftCap)

**Date:** 2026-10-30 ~20:10 CST (Asia/Shanghai)
**Goal:** On Win cave, rebuild / align SoftCap↔Cap soft contract path via four-piece map (win_shadow / sret_reg_shift / sret_home / imm→arg) so tip SoftCap past CG002 and emits runnable `p_ret_*` USER — **without** PE Isol as close / LIVE transplant / PROD·pin bump.
**Isol host (对照 only):** `host_967_s25.exe` sha12 `e53841ce0e24`
**tip SoftCap = PROD SoftCap Capless:** `lab_SoftCap_76795.exe` sha12 `7a2cf5da581a` (**not bumped**)
**Cap soft Win host (本拍 plant):** `lab_CapSoftWin_w1778.exe` sha12 `9c4746d5b5d7` (from `C:\xlang_tmp\w1778\xlang_side.exe`)
**pin `ecdb5cc1e`:** untouched
**Ban:** PE Isol as close / LIVE SoftCap transplant / tip@121278 / join / epi / mega / arg-loop / hollow·skip as close / LIVE SoftCap transplant

## 0) Gate (this beat)

| host | sha12 | lit | fwd | local | let | note |
|---|---|---|---|---|---|---|
| Isol `host_967_s25` | `e53841ce0e24` | **0** | **0** | **0** | **0** | 对照 only |
| tip SoftCap (=PROD Capless) | `7a2cf5da581a` | **CG002** | **CG002** | **CG002** | **CG002** | **未动**; code_len=0 |
| Cap soft Win `lab_CapSoftWin_w1778` | `9c4746d5b5d7` | **0** `a5a38f5fedda` | **0** `579b00643379` | **0** `32aed12b68a5` | **0** `48dabc18be10` | **4/4 cold green** via Cap soft emit |
| Cap soft Win g05_stage | `d001fe5da40d` | **0** | exit1 | **0** | exit1 | 2/4; older stage |
| LIVE `lab_LIVE_pret` | `cbc0d8e8d96f` | **0** | AV | exit1 | exit1 | 1/4; **禁移植** |
| Darwin tip Cap soft | `0c0a41335a35` | **0** | **0** | **0** | — | Cap soft contract proof |

**Gate green ≠ PROD bump / ≠ close knife.** Cap soft Win 4/4 ≠ tip SoftCap(=PROD Capless) green. PROD Capless still CG002.

## 1) DIG 钉死（本拍）

1. **SoftCap PE already embeds Cap soft emit symbols** (`sret_reg_shift` / `glue_asm_emit_call_with_cleanup` / `pipeline_asm_emit_set_call_sret_reg_shift` / `link_abi_host_is_windows` HIT in PROD/Isol/LIVE/g05). Cap soft four-piece is **not missing from SoftCap PE text**; tip SoftCap CG002 is **STRUCT_LIT registration before emit** (num_funcs=0), then Capless SoftCapCallExpr slot `@57ba3b` (no tip Capless twin).
2. **No Cap soft Win host in SoftCap Capless PE lineage** (g05 SoftCap / tip SoftCap / Isol all Capless-path for SoftCap USER; tip Cap soft Win side hosts ≠ SoftCap PE).
3. **Cap soft Win rebuild recipe (plant):**
   - Host: tip Cap soft Win side PE `w1778\xlang_side.exe` sha `9c4746d5b5d7` (also w1774 same USER shas)
   - Workdir: `C:\xlang_tmp\p1060\capsoft_win_rebuild\` with **tip** `compiler/seeds` + tip `compiler/include` (exe-relative seeds; needs `xlang_weak.h`)
   - CLI: `xlang build <src.x> -o <out.exe>` (not SoftCap legacy bare CLI)
   - Cave install: `C:\xlang_tmp\p1060\cave\lab_CapSoftWin_w1778.exe`
4. **Result:** Cap soft Win past CG002 and emits runnable USER for lit/fwd/local/let (**4/4**). USER sha ≠ Isol Capless USER (different emit path — Cap soft, not PE Isol Capless USER16). `sub rsp,20h` counts match Isol lit/fwd (12/14) — Cap soft win_shadow contract present in USER.
5. **g05_stage** `d001fe5da40d` past CG002 but fwd/let **exit=1** (not AV) — older Cap soft Win incomplete for fwd/let sret.
6. **Historical SoftCap Capless hosts** (PROD / g05_1046_n* / tip_peel / softcap_cave_isol `cca095a70725`) remain CG002 or AV — not Cap soft Win rebuild.
7. **g05 tip Cap soft full rebuild** (`win_g05_rebuild.sh`) last FAIL: ld undef `g_pipeline_elf_reloc_*` — not used this beat; Cap soft Win side host already sufficient for four-gate.
8. **Banned closes not used:** no PE Isol plant as tip SoftCap; no LIVE transplant; no PROD/pin bump; no Capless USER16 plant; no hollow/skip.

## 2) SoftCap↔Cap soft contract alignment

| Cap soft twin (tip src) | Cap soft Win USER evidence | SoftCap Capless PE |
|---|---|---|
| `glue_asm_emit_call_with_cleanup` win_shadow | USER `sub rsp,20h` count lit=12 / fwd=14 (≈Isol) | Capless `@57ba3b` USER16 plant = Isol only |
| `pipeline_asm_emit_set_call_sret_reg_shift_c` | Cap soft Win fwd/let run=0 (g05_stage exit1 proves shift needed) | Capless no tip twin |
| `struct_let_init` sret_home / `return_sret` | Cap soft Win let USER `48dabc18be10` run=0 | Capless+Isol let green only via Isol |
| imm→arg under shift | Cap soft Win lit USER `a5a38f5fedda` run=0 | Isol Capless USER16 |

**Nail:** Cap soft Win host exercises tip Cap soft four-piece on Win PE USER emit. tip SoftCap(=PROD Capless) still red CG002 — Cap soft Win is the Cap soft rebuild path, **not** a PROD SoftCap Capless bump.

## 3) Plant attempt (this beat)

| attempt | result |
|---|---|
| tip SoftCap(=PROD) four-gate | **RED** CG002×4 (untouched) |
| Isol four-gate | **GREEN** (对照) |
| Cap soft Win w1778 + tip seeds/include | **GREEN 4/4** cold |
| Cap soft Win g05_stage + tip seeds/include | 2/4 (fwd/let exit1) |
| LIVE four-gate | 1/4 (禁移植) |
| PE Isol as tip SoftCap | **not done** (ban) |
| LIVE SoftCap transplant | **not done** (ban) |
| PROD / pin bump | **not done** |

## 4) Next single point

**`softcap_tip_capsoft_win_promote`** (or `softcap_g05_capsoft_win_tiphead`): wire tip SoftCap identity to Cap soft Win host (w1778-class / tip-HEAD g05 Cap soft Win rebuild) so tip SoftCap four-gate cold-greens via Cap soft — still **no PROD Capless bump** / **no pin bump** until Cap soft Win is the accepted tip SoftCap product. Fix `win_g05_rebuild` ld undef `g_pipeline_elf_reloc_*` if tip-HEAD Cap soft Win selfhost needed.

Optional: Ubuntu tip-cold + Darwin Cap soft stay green (isolate Win Cap soft only).

## 5) Artifacts

- This DIG: `_dig/dig_softcap_capsoft_win_rebuild.md`
- Cave host: `lab_CapSoftWin_w1778.exe` sha `9c4746d5b5d7`
- Workdir recipe: `C:\xlang_tmp\p1060\capsoft_win_rebuild\` (seeds+include from tip)
- Scripts (Win cave): `p1060_csrb_*.py` / `p1060_capsoft_probe.py` / `p1060_csrb_cold.py`
- Prior DIG: `_dig/dig_src_softcap_s25_emit.md`
- PROD SoftCap `7a2cf5da581a` / pin `ecdb5cc1e`: **untouched**

## 6) Open bans unchanged

CloudAgent / 10.74 / HARD BAN / mega / 假绿 / LIVE SoftCap transplant / PE Isol as close / arg-loop / tip@121278 / join / epi / hollow·skip_1a0 as close / letter-pile / LIVE SoftCap transplant.
