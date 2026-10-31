# DIG softcap_g05 tiphead `7c1051a95fcc` still CG002 (vs w1778)

**Date:** 2026-10-31 ~09:16 CST (Asia/Shanghai)
**Beat:** `softcap_g05_capsoft_win_tiphead` — guarded-relink tiphead Cap soft past CG002
**tiphead Cap soft:** `lab_CapSoftWin_tiphead.exe` sha12 **`7c1051a95fcc`** size=8026647 (guarded-relink ~09:12 exit 0)
**tip SoftCap plant:** same sha (identity = Cap soft tiphead)
**对照 w1778:** `lab_CapSoftWin_w1778.exe` sha12 **`9c4746d5b5d7`** size=8447113 — **4/4 cold green**
**PROD Capless:** `7a2cf5da581a` **untouched** · nail `ecdb5cc1e` **untouched**

## 0) Cold four-gate (this beat)

| host | sha12 | lit | fwd | local | let |
|---|---|---|---|---|---|
| tip SoftCap plant | `7c1051a95fcc` | **CG002** | **CG002** | **CG002** | **CG002** |
| Cap soft tiphead direct | `7c1051a95fcc` | **CG002** | **CG002** | **CG002** | **CG002** |
| w1778 | `9c4746d5b5d7` | **0** | **0** | **0** | **0** |
| PROD Capless | `7a2cf5da581a` | (untouched) | | | |

All tiphead fails: `codegen error[CG002]: asm_codegen failed` / `elf ctx code_len=0 num_labels=0 num_patches=0`.

## 1) DIG 钉死 vs w1778

1. **10.60 reinject landed** (struct_lit_field / addr_of / call_spill) + win_patch W→T for field_offset/store_sz. tiphead **has** T `glue_asm_last_struct_lit_temp_bytes_c` / `glue_addr_simd_lane_type_c` / `pipeline_expr_struct_lit_field_offset_at`. **Not** the remaining CG002 root.
2. **Ladder (tiphead):** scalar let OK; struct **type decl only** OK; **STRUCT_LIT in return** (`mk(): Point { return Point{…} }`) OK; **any aggregate let** CG002 — `let p: Point`, `let p: Point = Point{…}`, empty `let s: S`, `let a: [2]i32 = […]`.
3. **Reframe:** CG002 surface is STRUCT_LIT gates, root is **aggregate let-init** (struct **or** array local), not missing last_struct/field_offset.
4. **Overlay fail:** `g05_relink_env` Win build of `runtime_pipeline_abi_struct_let_init_thin.x` → **SEGV** (`XLANG_PREFER_ASM_O=1 … -backend asm -c`); log: `failed (Windows struct let init)` / `WARNING keep prior struct_let_init_win.o`. WORK now **MISS** `struct_let_init.o` / `struct_let_init_win.o` / `emit_let_init.o`.
5. tiphead `glue_emit_struct_type_let_init_elf_c` T@`140121170` (from_x/mega stack-probe style); W@`1402d1f7e` **jmp→T**. w1778 winner T@`1404af9f0` (C leftover style) + low t@`14008a21e` — **handles non-STRUCT_LIT / uninit paths tiphead mega T does not**.
6. Same class: `assign_win` SEGV keep-prior; `for_call_args_thin` fail keep-prior.

## 2) Not done / bans

- No second relink this beat (parent: do not wait).
- No PE Isol as tip SoftCap · no LIVE transplant · no PROD/nail raise · no mega · no CloudAgent.

## 3) Next single point (for parent)

- **`struct_let_init_win` overlay:** stop SEGV when compiling `struct_let_init_thin.x` on Win (or reinject a known-good `struct_let_init_win.o` / prefer egg W over mega T for `glue_emit_struct_type_let_init_elf_c`), then guarded-relink tiphead, re-cold 4 gates. Gate green ≠ knife ✅ ≠ raise PROD.

## 4) Artifacts

- Cold inline this beat; plants sha `7c1051a95fcc`
- Relink log: `C:\xlang_tmp\g05_rebuild.log` (exit 0, G05_OBJS=155, 10.60 reinjects HIT)
- PROD / nail untouched
