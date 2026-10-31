# DIG softcap_g05 tiphead `c598763c708d` still CG002 after SLI reinject

**Date:** 2026-10-31 ~09:40 CST (Asia/Shanghai)
**Beat:** softcap_g05 — reinject known-good `struct_let_init_win.o`, guarded-relink, cold 4-gate
**tiphead Cap soft:** `lab_CapSoftWin_tiphead.exe` sha12 **`c598763c708d`** size=8014310 (guarded-relink ~09:35 exit 0)
**tip SoftCap plant:** same sha (identity = Cap soft tiphead) — plant done; gates still red
**对照 w1778:** `9c4746d5b5d7` — still **4/4** green (`p_ret_lit` manual confirm run=0)
**PROD Capless:** `lab_SoftCap_76795.exe` **`7a2cf5da581a`** untouched · nail **`ecdb5cc1e`** untouched

## 0) What landed

1. Located saved good overlay: `C:\xlang_tmp\w2060_side\saved\build_asm\selfhost_pabi\struct_let_init_win.o` (18115, Oct 6) — sole T `glue_emit_struct_type_let_init_elf_c` (no `sli_emit_if_arm_or_array_elf_c`).
2. Wired reinject in `compiler/scripts/g05_relink_env.sh` (`G05_STRUCT_LET_INIT_WIN_REINJECT` / `.good`).
3. Patched `C:\xlang_tmp\win_g05_guarded_relink.sh` to plant SLI + append `src/win_named_narrow_stubs.o` (widen_mixed U-refs). Fast-path without stubs had wiped `xlang.exe` (restored from `xlang_asm.exe` / cave `7c1051`).
4. Guarded-relink: `10.60 reinject struct_let_init_win.o from struct_let_init_win.o.good` HIT; G05_OBJS=155 + named_narrow; **relink exit 0** → sha12 **`c598763c708d`**.
5. Cold planted tip SoftCap / tiphead / WORK side copies to `c598763c708d`.

## 1) Cold four-gate

| host | sha12 | lit | fwd | local | let |
|---|---|---|---|---|---|
| tip SoftCap plant | `c598763c708d` | **CG002** | 0xc0000142* | 0xc0000142* | 0xc0000142* |
| Cap soft tiphead direct | `c598763c708d` | 0xc0000142* | 0xc0000142* | 0xc0000142* | 0xc0000142* |
| w1778 | `9c4746d5b5d7` | **0** | **0** | **0** | **0** |

\*First SoftCap gate definitive: `codegen error[CG002]: asm_codegen failed` / `elf ctx code_len=0`. Manual re-run `p_ret_lit.x` on tip SoftCap → CG002; tiphead `--help` OK (not a hard DLL-load fail on the host). Subsequent 0xc0000142 treated as cascade noise after first CG002.

Gate source `p_ret_lit.x` **is** aggregate let-init: `let w: W = mk();` after `mk(): W { return W{…} }`.

## 2) DIG vs prior `7c1051` / w1778

| | `7c1051` (fat prior) | `c598763` (reinject) | w1778 |
|---|---|---|---|
| `glue_emit_struct_type_let_init_elf_c` | T + W; also T `sli_emit_if_arm_or_array` | T@`140120c60` + W; **no** sli_emit | T@`1404af9f0` (+ low t) |
| overlay class | fat 31221 mega-ish | good 18115 let_init-only | C leftover style |

Reinject **did** replace fat mega T with let_init-only COFF. Still CG002 on `let w: W = mk()` → good overlay alone does **not** cover call-return→aggregate-let (or dispatch never reaches a working arm). Overlay U-refs include `try_inline_struct_lit_return_call_to_slot_elf` / `pipeline_asm_emit_struct_let_init_elf_c` — next dig those providers tiphead vs w1778.

## 3) Not done / bans

- Gate green ≠ knife ✅ ≠ raise PROD. No PROD/nail raise. No mega / LIVE / PE Isol SoftCap close / CloudAgent / 10.74.

## 4) Next single point

- Dig why `glue_emit_struct_type_let_init_elf_c` T@`140120c60` still yields `code_len=0` for `let w: W = mk()` vs w1778 T@`1404af9f0`: compare call-return-to-slot / `try_inline_*` / `pipeline_asm_emit_struct_let_init_elf_c` winners; or fix Win thin SEGV so a fresher overlay builds; do **not** re-plant SoftCap until cold green.

## 5) Artifacts

- Relink log: `C:\xlang_tmp\g05_rebuild.log` (exit 0, reinject HIT, append named_narrow)
- Cold log: `C:\xlang_tmp\p1060\g05th_cold.log`
- Cave backup prior tiphead: `lab_CapSoftWin_tiphead_backup.exe` = `7c1051a95fcc`

## 6) DIG continuation 2026-10-31 ~10:10 CST (Asia/Shanghai) — tip T vs w1778 T

### Live addresses
| | tiphead `c598763c708d` | w1778 `9c4746d5b5d7` |
|---|---|---|
| `glue_emit_struct_type_let_init_elf_c` | **T@`140120c60`** (selfhost, frame `sub $0x1ca8` stack-probe) + W@`1402cf12e` (`jmp` T; leftover C body dead after jmp) | **T@`1404af9f0`** leftover C (`push r15..`, correct MS ABI) |
| `glue_block_body_emit_let_init` | T@`14010eef0` selfhost + W@`14027dd9a` jmp→T | T@`140019d12` leftover C |
| let-emit caller | **only** `w1009_emit_let_SCAPDEAD@14010c1e0` → glue_block T | **`w1010_emit_let@140019240`** leftover C |

### Root (concrete)
1. **Reinject false hope:** saved `struct_let_init_win.o` (18115) is **selfhost-compiled** (identical prologue to tip T: `mov $0x1ca8` / stack probe) — **not** leftover C. Relink replaced fat mega with selfhost let_init-only; live T remains ABI-broken on the **caller** side.
2. **Win64 ≥5-arg call bug (selfhost):** at `w1009_emit_let_SCAPDEAD`→glue_block (`14010c526`..) and glue_block→struct (`14010f828`..): `push` stack args **without shadow**, then **reload 5th/6th into r8/r9 clobbering arg3/arg4**. w1778 `w1010_emit_let` correctly stores homes at `rsp+0x20..+0x48`.
3. **W leftover PE restores are dead:** all live `E8` calls target **T** addresses; W is only `jmp T`. Retargeting leftover-gb calls T→W, and even planting `jmp` at T→leftover-W / glue_block-T→leftover-gb, **still CG002** — because **callers** still use the broken marshal (garbage 5th–7th/10th).
4. tip T internal STRUCT_LIT→`pipeline_asm_emit_struct_let_init@1402d07cf` marshal looks MS-correct (`mov` to `0x20/0x28(%rsp)`). Failure is **incoming** args / call-return path, not lit_fields body (tip lit_fields≈w1778 reloc-only).
5. Cold (codegen): w1778 slit/call/`p_ret_lit` = PRC001 (codegen OK, spawn missing); tip / TjmpW / retarget = **CG002** on slit/call/`p_ret_lit`; `_min_ret0` / `_p_mk_only` = PRC001 on tip+TjmpW.

### Not a SoftCap close
Dig PE copies (`*_gb_st*`, `*_TjmpW.exe`) are **dig artifacts only**. No SoftCap re-plant, no PROD/nail raise.

### Next single point
Replace tip’s live let-emit caller with leftover-class **`w1010_emit_let`** (correct Win MS ABI) **and** keep leftover/C-correct `glue_block`→`glue_emit_struct` chain — **or** fix selfhost Win64 N≥5 call marshalling and rebuild tiphead Cap soft. Optionally fix Win thin SEGV for a fresher true leftover overlay. **No SoftCap re-close / no PROD raise until cold green.**

### Artifacts (Win)
- `C:\xlang_tmp\p1060\g05th_dig\sli_*.ps1` / `sli_*.txt`
- dig hosts: `cave\lab_CapSoftWin_tiphead_gb_st*.exe`, `lab_CapSoftWin_tiphead_TjmpW.exe`
