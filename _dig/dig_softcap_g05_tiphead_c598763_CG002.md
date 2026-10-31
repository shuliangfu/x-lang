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

## 7) 2026-10-31 ~10:15 CST (Asia/Shanghai) — host-cc w1010 plant (concrete patch)

### Patch
- `compiler/scripts/g05_relink_env.sh` Windows `MINGW*` case for body_sync / emit_let_init:
  - **was** `_g05_pure_overlay` of the `.x` twins → selfhost `w1009_*_SCAPDEAD`
  - **now** `gcc -c -O2` of the `.c` twins → leftover-class `t w1010_emit_let` + `T glue_block_body_emit_let_init`
  - fail-closed if nm lacks `w1010_emit_let` / pipeline T / glue_block T
- Darwin/Linux `.x` pure_overlay unchanged.

### Pre-relink plant (Win tree)
- `build_asm/selfhost_pabi/body_sync_let_order.o` = host-cc 7972 (`t w1010_emit_let`, homes `rsp+0x20..+0x48`)
- `build_asm/selfhost_pabi/emit_let_init.o` = host-cc 4806 (`T glue_block_body_emit_let_init`)
- selfhost bak: `C:\xlang_tmp\p1060\g05th_dig\*.selfhost.bak`
- dig stash: `C:\xlang_tmp\p1060\g05th_dig\*.hostcc.o`

### Intent
Smallest isol that can falsify or green cold gates: SoftCap-plant leftover-class w1010 + correct glue_block chain (DIG §6). Relink tiphead Cap soft next; cold 4-gate; **no SoftCap re-close / no PROD/nail raise until cold green**.

### Next
Guarded-relink → dig cold 4-gate on new tiphead sha. If still CG002, dig whether struct T still selfhost (reinject) needs leftover overlay, or N≥5 emit elsewhere.

## 8) 2026-10-31 ~10:40 CST (Asia/Shanghai) — host-cc cold + LEFT_PUSH struct dig

### Tip SoftCap after host-cc plant
- tip git: `82700e544` = origin/dev (host-cc body_sync+emit_let + block_prefix)
- Cap soft tiphead sha12 **`13e5e99ef39b`** size **7990620**
- Live: `t w1010_emit_let@14010b380` (MS homes), `T glue_block_body_emit_let_init@14010bed0` (host-cc PUSH), `T glue_emit_struct_type_let_init_elf_c@14011aa40` **still selfhost** (`mov $0x1ca8`), W@`1402c8f0e` jmp→T
- Cold tip SoftCap / tiphead: **0/4 CG002** (synced WORK). Smoke `_min_ret0` / `_p_mk_only` RC0; aggregate slit/`p_ret_lit` CG002.
- Dig T→restored-W leftover struct (prior): still **0/4 CG002** — tip W leftover is rbp-frame, **not** w1778 push-all.

### Dig SoftCap plant: leftover-class LEFT_PUSH struct (w1741 `let_only.o`)
- Source COFF: `C:\xlang_tmp\w1741\let_only.o` (63609) — **single** `T glue_emit_struct_type_let_init_elf_c`, locals include `t pipeline_asm_emit_struct_let_init_elf_c`; prologue **byte-match** w1778 live T@`1404af9f0` (`push r15..`, `sub $0x58`, homes `rsp+0xc0..`).
- Relink: `G05_STRUCT_LET_INIT_WIN_REINJECT` → leftpush; post-env force; `g05_relink_xlang`; **dig host only** then restore tip SoftCap cave + selfhost `.good`.
- Dig host sha12 **`edce125ae6d0`** size **8020281** (`g05th_dig/lab_CapSoftWin_tiphead_LEFTPUSH.exe`; cave copy `lab_CapSoftWin_tiphead_LEFTPUSH_dig.exe` for seed-relative cold).
- Live dig: `T glue_emit_struct@14011ebe0` **LEFT_PUSH**, W jmp→T; w1010 + host-cc glue_block unchanged.
- Cold dig LEFT_PUSH (cave-hosted): **0/4 CG002**. Smoke ret0/mk_only RC0. w1778 still **4/4**.
- PROD `7a2cf5da581a` / nail untouched / w1778 `9c4746d5b5d7` untouched. Tip SoftCap remains `13e5e99ef39b`.

### Falsified
1. host-cc w1010 + host-cc glue_block alone (struct still selfhost) → still CG002.
2. host-cc callers + **leftover-class LEFT_PUSH struct** (w1778-class body, W→T patched) → still CG002.
Caller-marshal-only and struct-body-only plants are each insufficient on tip SoftCap family.

### Still diverging vs w1778 (next pressure)
- dig/tip `glue_block` = host-cc **PUSH**; w1778 live T@`140019d12` = **RBP** `sub $0xa0` (also T@`14013ac48` MSVC-ish). No thin isol `.o` yet matching `@140019d12` (egg mega only).
- `pipeline_asm_emit_struct_let_init_elf_c` winners / multiples differ tip vs w1778.
- Optional: fix Win thin SEGV on `struct_let_init_thin.x` for true overlay; or fix selfhost Win64 N≥5 call emit at source and rebuild tiphead Cap soft.

### Not a SoftCap close
LEFT_PUSH dig host is dig-only. No SoftCap tiphead promote, no PROD/nail raise, no PE Isol SoftCap close.

### Next single point
Plant w1778-class **RBP leftover `glue_block_body_emit_let_init`** (extract thin COFF from egg / match T@`140019d12`) **with** LEFT_PUSH struct + host-cc w1010 — **or** fix selfhost Win64 N≥5 call emit and rebuild tiphead. Prefer smallest isol that can falsify/green cold. **No SoftCap re-close / no PROD raise until cold green.**

### Artifacts
- Dig relink: `C:\xlang_tmp\g05_dig_leftpush.log` / `win_g05_dig_leftpush_relink.sh`
- Dig host: `C:\xlang_tmp\p1060\g05th_dig\lab_CapSoftWin_tiphead_LEFTPUSH.exe` (`edce125ae6d0`)
- LEFT_PUSH COFF: `C:\xlang_tmp\w1741\let_only.o`
- Tip SoftCap backup pre-dig: `cave\lab_CapSoftWin_tiphead.exe.bak_pre_leftpush` (= `13e5e99ef39b`)

## 9) 2026-10-31 ~11:00 CST (Asia/Shanghai) — RBP leftover glue_block + LEFT_PUSH dig

### Thin extract (not mega)
- Source: `compiler/src/runtime_pipeline_abi_glue_block_body_emit_let_init_thin.c`
- Build: `gcc -c -O0 -fno-omit-frame-pointer` → `C:\xlang_tmp\p1060\g05th_dig\el_O0fp.o` (5956)
- Prologue **byte-match** w1778 live T@`140019d12`: `push rbp; mov rbp,rsp; sub rsp,0xa0` (a0_off=422 in COFF)
- `-O2` / `-O1` / no-fp → **not** A0 (host-cc PUSH or other). Egg/`egg_thin.o` = `sub $0x190` class — **wrong** (mega-ish).

### Dig SoftCap plant
- Force after `g05_relink_env`: `el_O0fp.o` → `emit_let_init.o` + LEFT_PUSH `let_only.o` → `struct_let_init_win.o` + host-cc `body_sync` w1010.
- Relink: `win_g05_dig_rbp_leftpush_relink.sh` / log `g05_dig_rbp_leftpush.log`.
- Note: `g05_relink_xlang` returned 1 after OK link (`win_patch_body_sync_jmp` PermissionError on rewrite); product `compiler/xlang.exe` still held the plant (T symbols classified). Saved dig-only; tip SoftCap cave restored.

### Dig host
- sha12 **`e0946cbb62f5`** size **8021361**
- Paths: `g05th_dig/lab_CapSoftWin_tiphead_RBP_LEFTPUSH.exe`, cave `lab_CapSoftWin_tiphead_RBP_LEFTPUSH_dig.exe` / `_cold_RBP_LEFTPUSH_host.exe`
- Live: `T glue_block_body_emit_let_init@14010bf72` **RBP_A0** (`sub rsp,0xa0`); `T glue_emit_struct@14011efc0` **LEFT_PUSH**; `t w1010_emit_let@14010b380`

### Cold 4-gate (cave-hosted; codegen view)
| host | sha12 | ret0 | mk_only | slit | p_ret_lit |
|------|-------|------|---------|------|----------|
| dig RBP+LEFT_PUSH | `e0946cbb62f5` | PRC001 (codegen OK) | PRC001 | **CG002** | **CG002** |
| tip SoftCap | `13e5e99ef39b` | PRC001 | PRC001 | **CG002** | **CG002** |
| LEFT_PUSH dig | `edce125ae6d0` | PRC001 | PRC001 | **CG002** | **CG002** |
| w1778 | `9c4746d5b5d7` | PRC001 | PRC001 | PRC001 | PRC001 |

- Dig / tip SoftCap / LEFT_PUSH: **0/4 green** (aggregate **CG002**). w1778 still **4/4** codegen-green (PRC001 = spawn `xlang_run_1` missing in this PATH; not CG002).
- Tip SoftCap cave unchanged **`13e5e99ef39b`**. PROD Capless `lab_SoftCap_76795.exe` **`7a2cf5da581a`** untouched. Nail `ecdb5cc1e` not raised. w1778 untouched.

### Falsified (add)
3. host-cc w1010 + **RBP leftover glue_block** (w1778 T@`140019d12` class) + **LEFT_PUSH struct** → still aggregate CG002.
Caller stack + leftover glue_block shape + leftover struct body together are still insufficient on tip SoftCap family.

### Not a SoftCap close
RBP+LEFT_PUSH dig host is dig-only. No SoftCap tiphead promote, no PROD/nail raise, no PE Isol SoftCap close, no mega / LIVE / egg mega.

### Next single point
**Fix selfhost Win64 N≥5 call emit** and rebuild tiphead Cap soft (remaining fork from §8). Dig whether `pipeline_asm_emit_struct_let_init_elf_c` / call-return-to-slot winners still diverge vs w1778 after that. Prefer M2 true host-cc reduction. **No SoftCap re-close / no PROD raise until cold green.** Gate green ≠ knife done.

### Artifacts
- Thin COFF: `C:\xlang_tmp\p1060\g05th_dig\el_O0fp.o`
- Dig relink: `C:\xlang_tmp\g05_dig_rbp_leftpush.log` / `win_g05_dig_rbp_leftpush_relink.sh`
- Dig host: `C:\xlang_tmp\p1060\g05th_dig\lab_CapSoftWin_tiphead_RBP_LEFTPUSH.exe` (`e0946cbb62f5`)
- Cold: `C:\xlang_tmp\p1060\g05th_dig\rbp_leftpush_cold4.txt`
- Tip SoftCap backup pre-dig: `cave\lab_CapSoftWin_tiphead.exe.bak_pre_rbp_leftpush` (= `13e5e99ef39b`)

## 10) 2026-10-31 ~11:45 CST (Asia/Shanghai) — HAS_HOME Cap soft helpers plant falsified

### Root evidence (pre-plant)
- tip SoftCap Cap soft T `pipeline_asm_emit_expr_elf_rec` body: **home20=0**, r8 movs abundant (NO_HOME).
- tip `asm_expr_helpers_win.o` (Cap soft tiphead Cap soft Cap soft-compiled): **home20=0**.
- w1778 Cap soft-compile of `runtime_pipeline_abi_asm_expr_helpers_thin.x`: **home20=37**, Cap soft T sites emit `mov [rsp+0x20],rax` before 5-arg calls (HAS_HOME).
- tip SoftCap Cap soft-compiling helpers_thin → **CG002** `code_len=0` (chicken-egg). Encoder Windows twin is linked (clamp 0x3f + home template) but Cap soft tiphead Cap soft Cap soft cannot Cap soft-compile this thin.

### Plant (M2 Cap soft reduction, dig-only)
- Source: `C:\xlang_tmp\p1060\m2_expr\helpers_from_w1778.o` → `g05th_dig/asm_expr_helpers_win.hashome.o` (12475).
- `g05_relink_env.sh` WIN_REC: `G05_ASM_EXPR_HELPERS_WIN_REINJECT` / `.hashome` + reject NO_HOME Cap soft T (home `[rsp+0x20]` count≥1); optional `XLANG_SIDE_EXE` Cap soft-compile fallback.
- Dig relink: `win_g05_dig_hashome_helpers_relink.sh` / log `g05_dig_hashome_helpers.log`.
- Dig host sha12 **`9c08bd814c11`** size **7989102**.
- Live: `T pipeline_asm_emit_expr_elf_rec@14012cb4c` **HAS_HOME** (`homes_in_first_1k=4`, plant count=37); W jmp→T patched.
- Tip SoftCap cave restored **`13e5e99ef39b`** (dig-only; no promote).

### Cold 4-gate (compiler cwd; `-c` codegen scoring)
| host | sha12 | ret0 | mk_only | slit | p_ret_lit |
|------|-------|------|---------|------|----------|
| dig HAS_HOME helpers | `9c08bd814c11` | OK | OK | **CG002** | **CG002** |
| tip SoftCap | `13e5e99ef39b` | OK | (OK class) | **CG002** | **CG002** |
| w1778 | `9c4746d5b5d7` | — | — | OK | (XP001 dialect on one probe; slit OK) |

- Dig HAS_HOME: **0/4 green** on aggregate (slit/p_ret_lit CG002). Cap soft T HAS_HOME alone insufficient.
- Hang-probe (Python `subprocess` timeout only — Win `TIMEOUT` broken): Cap soft T / glue_struct / glue_block / struct_let_init / struct_lit / lit_fields / w1010 all **MISS_CG002** on dig HAS_HOME for `_p_slit.x` — those entry points are **not** reached before CG002 (or path aborts earlier). glue_struct ~4.9s / lit_fields ~5.8s of work then CG002 without entering patched T.

### Falsified (add)
4. **HAS_HOME Cap soft helpers** (w1778 Cap soft-compile of `asm_expr_helpers_thin` → Cap soft T N≥5 homes) → still aggregate CG002. Cap soft T NO_HOME was real but **not** the slit abort site on tip SoftCap family.

### Not a SoftCap close
HAS_HOME dig host is dig-only. No SoftCap tiphead promote, no PROD/nail raise, no PE Isol SoftCap close, no mega / LIVE / egg mega. Gate green ≠ knife done.

### Next single point
**Find the actual CG002 abort path for slit** on tip SoftCap `13e5e99ef39b` (or dig HAS_HOME): who is entered on `_p_slit.x` codegen before `code_len=0`. Map remaining Win64 N≥5 marshal gaps on that path (homes vs r8/r9 clobber at Cap soft-compiled callers). Prefer M2 host-cc / HAS_HOME plant of the **proven** on-path module — do **not** re-thrash Cap soft helpers alone. **No SoftCap re-close / no PROD raise until cold green.**

### Artifacts
- HAS_HOME COFF: `C:\xlang_tmp\p1060\g05th_dig\asm_expr_helpers_win.hashome.o` (+ tip `build_asm/selfhost_pabi/asm_expr_helpers_win.o.hashome`)
- Dig relink: `C:\xlang_tmp\g05_dig_hashome_helpers.log` / `win_g05_dig_hashome_helpers_relink.sh`
- Dig host: `C:\xlang_tmp\p1060\g05th_dig\lab_CapSoftWin_tiphead_HASHOME_HELPERS.exe` (`9c08bd814c11`); cave dig copy
- Cold: `C:\xlang_tmp\p1060\g05th_dig\hashome_helpers_cold4.txt`
- Tip SoftCap backup pre-dig: `cave\lab_CapSoftWin_tiphead.exe.bak_pre_hashome_helpers` (= `13e5e99ef39b`)
- WIP: `compiler/scripts/g05_relink_env.sh` HAS_HOME reinject (kept for future tiphead Cap soft rebuilds)

## 11) 2026-10-31 ~12:25 CST (Asia/Shanghai) — slit CG002 abort is parse-skip (not Cap soft T N≥5)

### Abort map (tip SoftCap cave `13e5e99ef39b`, `-c` from compiler cwd)

Cold-gate `_p_slit.x` / `p_ret_lit.x` fail **before Cap soft T codegen**:

| probe | tip SoftCap | w1778 `9c4746d5b5d7` |
|-------|-------------|----------------------|
| `let x: i64 = 1` | parse OK nf=1 | OK |
| `struct Point` + `main return 0` (no let) | parse OK nf=1 | OK |
| `let p: Point;` (uninit, no lit) | **P001 no functions** | OK nf=1 |
| `let p: Point = Point { … }` (slit) | **P001** | OK nf=1 |
| `function mk(): Point { … }` + clean main | OK **nf=1** (mk silently dropped) | OK nf=2 |
| `function f(p: Point)` + clean main | OK **nf=1** (f dropped) | OK nf=2 |

Bare `-o` maps parse-fail / nf=0 → **CG002 code_len=0**. So mk_only “OK” on tip SoftCap is a **false green** (main never names Point).

### Hang-probe (Python `subprocess` timeout + explicit kill; Win `TIMEOUT` broken)

tip SoftCap slit (`EB FE` at Cap soft T / listed W):

| symbol | tip SoftCap slit | w1778 slit |
|--------|------------------|------------|
| `parser_parse_type_ref_for_arena_into` | HIT | HIT |
| `parser_asm_parse_named_type_ref_c` | HIT | MISS_OK |
| `parser_skip_one_function_full_into` + asm slice | **HIT** | MISS_OK |
| `driver_diagnostic_parse_skip_function` / `parser_diagnostic_parse_skip` | **HIT** | MISS_OK |
| `parser_asm_finish_struct_lit_from_type_ident_into_c` | **MISS_P001** | **HIT** |
| `parser_asm_primary_ident_x_into_c` | HIT (W) | HIT (W) |
| `parser_asm_primary_ident_suffix_loop_c` | MISS_P001 | NO_SYM |
| Cap soft glue_block / glue_struct / emit_expr (prior) | MISS_CG002 | (entered on W) |

tip SoftCap lun (`let p: Point;`): `parser_body_skip_let_const_then_if_into` **HIT**, `pipeline_parser_library_init_named_type_c` **HIT**, skip_one_function **HIT**; finish_struct MISS (no lit).

**Chain:** named-struct in let/params/returns → tip SoftCap **parse-skips the function** (`diagnostic_parse_skip` → `skip_one_function_full_into`) → `num_funcs=0` when main itself uses Point → P001 / bare CG002. Never reaches Cap soft `finish_struct_lit` / glue_struct / HAS_HOME helpers. w1778 never skip-hits; reaches `finish_struct_lit`.

### Off-path (still real, not slit abort)
- Cap soft T `pipeline_asm_emit_expr_elf_rec` NO_HOME / HAS_HOME plant (**falsify #4**).
- `assign_var_try_let` NO_HOME r8/r9 clobber sites (prior `1400043d2`/`140004817` class) — not entered on slit.
- EXPORT_R9LEA dig `ccca8f5f32c0` and FORCE_FULL `force_full_bodies→mov eax,1;ret` dig `0353d85aa9a7`: still slit CG002; force_full MISS on slit (not consulted). Treat as **falsify #5 / #6** (marshal / force_full plants off abort path).

### Falsified (add)
5. EXPORT_R9LEA / assign_var N≥5 marshal plant — not on slit abort path (parse-skip earlier).
6. FORCE_FULL / `force_full_bodies` plant — MISS on slit; still CG002.

### Not a SoftCap close
Parse-root DIG only. Tip SoftCap cave remains **`13e5e99ef39b`**. No tiphead promote, no PROD/nail raise, no PE Isol SoftCap close, no mega / LIVE / egg mega. Gate green ≠ knife done.

### Next single point
**Smallest isol:** restore tip SoftCap **parse acceptance** of named-struct in let (and signatures) so `skip_one_function` is not taken — then Cap soft `finish_struct_lit` can run (w1778 path). Prefer M2 host-cc / dig plant of proven parser pieces (`parse_type_ref` / `named_type_ref` / let-bind path that avoids `diagnostic_parse_skip`; or primary_ident→finish_struct once type annot works). Do **not** re-thrash HAS_HOME helpers / FORCE_FULL / EXPORT_R9LEA. Prior PROD SoftCap Isol-A/B (consume + LBRACE→finish_struct) is related but RVAs differ on tiphead Cap soft; re-verify on `13e5e99ef39b` before transplant. Dig-only → cold 4-gate; if green, guarded tiphead Cap soft rebuild; **still no PROD/nail**.

### Artifacts
- Hangprobe: `C:\xlang_tmp\p1060\g05th_dig\hangprobe7b.py` / `hangprobe7w.py` (+ outs)
- Parse iso matrix: `iso_parse.py` / `iso_parse2.py` / `iso_parse3.py` under `g05th_dig/`
- Tip SoftCap cave: `13e5e99ef39b` unchanged
