# DIG `softcap_tip_capsoft_win_promote` (10.60 SoftCap)

**Date:** 2026-10-30 ~20:14 CST (Asia/Shanghai)
**Goal:** Wire tip SoftCap identity to Cap soft Win host (w1778-class) so tip SoftCap four-gate cold-greens via Cap soft emit — **without** PE Isol as close / LIVE transplant / PROD·pin bump.
**Isol host (对照 only):** `host_967_s25.exe` sha12 `e53841ce0e24`
**PROD SoftCap Capless (未动):** `lab_SoftCap_76795.exe` sha12 `7a2cf5da581a`
**tip SoftCap identity (本拍 plant):** `lab_SoftCap_tip.exe` = Cap soft Win `lab_CapSoftWin_w1778.exe` sha12 `9c4746d5b5d7`
**pin `ecdb5cc1e`:** untouched
**Ban:** PE Isol as close / LIVE SoftCap transplant / tip@121278 / join / epi / mega / arg-loop / hollow·skip as close / PROD Capless overwrite

## 0) Gate (this beat)

| host | sha12 | lit | fwd | local | let | note |
|---|---|---|---|---|---|---|
| **tip SoftCap (=Cap soft Win)** | `9c4746d5b5d7` | **0** `a5a38f5fedda` | **0** `579b00643379` | **0** `32aed12b68a5` | **0** `48dabc18be10` | **4/4 cold green** via Cap soft `build` + WORK seeds/include |
| Cap soft Win direct | `9c4746d5b5d7` | **0** | **0** | **0** | **0** | same USER shas |
| Isol `host_967_s25` | `e53841ce0e24` | **0** | **0** | **0** | **0** | 对照 only；USER ≠ Cap soft |
| PROD SoftCap Capless | `7a2cf5da581a` | **CG002** | **CG002** | **CG002** | **CG002** | **未动**; code_len=0 |

**Gate green ≠ PROD bump / ≠ close knife.** tip SoftCap Cap soft 4/4 ≠ PROD Capless green. PROD Capless still CG002 untouched.

## 1) DIG 钉死（本拍）

1. **tip SoftCap identity rewired:** cave `lab_SoftCap_tip.exe` (+ alias `lab_tip_SoftCap_CapSoftWin.exe`) = Cap soft Win w1778 `9c4746d5b5d7`. tip SoftCap **no longer** means PROD Capless `7a2cf5da581a`.
2. **CLI contract:** tip SoftCap Cap soft uses `xlang build <src> -o <out>` with exe-relative tip `seeds`+`include` at `C:\xlang_tmp\p1060\capsoft_win_rebuild\` (needs `xlang_weak.h`). SoftCap Capless bare CLI remains PROD-only and still CG002.
3. **USER path = Cap soft emit** (not PE Isol Capless USER16): USER shas match Cap soft Win cold (`a5a38f5fedda` / `579b00643379` / `32aed12b68a5` / `48dabc18be10`); Isol USER shas differ (`5c6778769c3c` / …).
4. **PROD SoftCap Capless untouched:** sha still `7a2cf5da581a`; four-gate still CG002×4. Pin `ecdb5cc1e` not raised.
5. **Banned closes not used:** no PE Isol plant as tip SoftCap; no LIVE transplant; no PROD overwrite; no Capless USER16 plant; no hollow/skip.

## 2) Plant (this beat)

| attempt | result |
|---|---|
| Copy Cap soft Win → `lab_SoftCap_tip.exe` / alias | planted sha `9c4746d5b5d7` |
| tip SoftCap four-gate (`build` + WORK) | **GREEN 4/4** cold |
| Cap soft Win direct four-gate | **GREEN 4/4** (same USER) |
| PROD Capless four-gate | **RED** CG002×4 (untouched) |
| Isol four-gate | **GREEN** (对照) |
| PE Isol as tip SoftCap | **not done** (ban) |
| LIVE SoftCap transplant | **not done** (ban) |
| PROD / pin bump | **not done** |

## 3) Residual / next

tip SoftCap Cap soft host is **w1778-class** (`xlang_side.exe` mtime ~2026-10-03), not tip-HEAD g05 Cap soft Win selfhost. `win_g05_rebuild` still FAIL ld undef `g_pipeline_elf_reloc_*`. Darwin Cap soft / Ubuntu tip-cold not re-run this beat (isolate Win promote only).

**Next single point:** `softcap_g05_capsoft_win_tiphead` — fix `win_g05_rebuild` ld undef `g_pipeline_elf_reloc_*` and rebuild tip-HEAD Cap soft Win so tip SoftCap identity tracks tip-HEAD Cap soft (still **no PROD Capless bump** / **no pin bump** until tip-HEAD Cap soft Win is accepted tip SoftCap product).

Optional: Darwin Cap soft + Ubuntu tip-cold reconfirm under tip SoftCap Cap soft identity.

## 4) Artifacts

- This DIG: `_dig/dig_softcap_tip_capsoft_win_promote.md`
- Script/log: `_dig/p1060_promote.py` / `_dig/p1060_promote.log`
- Cave tip SoftCap: `C:\xlang_tmp\p1060\cave\lab_SoftCap_tip.exe` sha `9c4746d5b5d7`
- Cave alias: `lab_tip_SoftCap_CapSoftWin.exe`
- Cap soft Win source host: `lab_CapSoftWin_w1778.exe` sha `9c4746d5b5d7`
- Workdir: `C:\xlang_tmp\p1060\capsoft_win_rebuild\` (seeds+include from tip)
- PROD SoftCap `7a2cf5da581a` / pin `ecdb5cc1e`: **untouched**

## 5) Open bans unchanged

CloudAgent / 10.74 / HARD BAN / mega / 假绿 / LIVE SoftCap transplant / PE Isol as close / arg-loop / tip@121278 / join / epi / hollow·skip_1a0 as close / letter-pile / LIVE SoftCap transplant / PROD Capless overwrite.
