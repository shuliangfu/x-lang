# softcap_g05_capsoft_win_tiphead — Cap soft Win tip-HEAD rebuild / ld

**Date:** 2026-10-31 ~17:25 Asia/Shanghai  
**Tip:** `83bde10a5`  
**PROD Soft Cap:** `db734adafe5e` (**do not raise**)  
**Nail:** `ecdb5cc1e` (**do not raise**)  
**Do not break:** Darwin Cap soft `0c0a41335a35` / Ubuntu tip SoftCap `ea9ddf4eb937`

## Goal

Tip SoftCap Cap soft Win cold-chain align via tip-HEAD Cap soft Win rebuild (`win_g05_rebuild`). No fake green. Prefer-M2 SoftCap dig stays STOP.

## true-fix — ld undef `g_pipeline_elf_reloc_*`

**Status: plant path RESOLVED** (morning exit 0).

| Object | Provides |
|--------|----------|
| `src/runtime_pipeline_abi_reloc_typed.o` from `seeds/runtime_pipeline_abi_reloc_typed_overlay.c` | B `g_pipeline_elf_reloc_r_type` / `_r_pcrel` / `_sidecar_owner` |
| `/c/xlang_tmp/win_elf_dual_bss.o` → `src/win_elf_dual_bss.o` | B `g_pipe_elf_reloc_*` (short) + long `g_pipeline_elf_reloc_*` |

Morning rebuild proof: relink exit 0 → sha12 **`13e5e99ef39b`** size 7990620.

Promote doc residual “still FAIL ld undef” is **stale**.

## Identity board (pre-rebuild this run)

| Host | sha12 | note |
|------|-------|------|
| PROD Soft Cap `lab_SoftCap_76795.exe` | `db734adafe5e` | keep PE clamp; **do not raise** |
| Cave tiphead `lab_CapSoftWin_tiphead.exe` | `06fa052fb409` | dig SoftCap egg — **not** tip-HEAD Cap soft |
| Prior tip SoftCap Cap soft `lab_tip_SoftCap_CapSoftWin.exe` | `13e5e99ef39b` | morning g05 tiphead |
| w1778 Cap soft | `9c4746d5b5d7` | 4/4 cold reference |
| compiler `xlang.exe` (pre this rebuild) | `3feda7638972` | unrelated working tree binary |

## This run

- Win tip fast-forwarded `6ddf8d768` → `83bde10a5` (Prefer-M2 in emit_let_init thin.c).
- Local `g05_relink_env.sh` SoftCap HAS_HOME helpers reinject kept (uncommitted Win worktree).
- Killed overlapping g05 processes; started **one** detached `win_g05_rebuild.sh` with `G05_ASM_EXPR_HELPERS_WIN_REINJECT=…/asm_expr_helpers_win.o.hashome`.
- After xlang.exe lands: install dig-only tiphead, cold 4/4; still no PROD raise.

## SoftCap PE clamp retire?

**Not yet.** Prefer-M2 SoftCap dig STOP; tiphead Cap soft must carry Prefer-M2 end-to-end and cold/multi without clamp before any clamp drop / PROD talk.

## Bans

No CloudAgent / no nail raise / no 10.74 / no HARD BAN main / no mega / glue_tail / P4b / bstrict / no new host-cc `.c` / no fake green.

## Rebuild attempt tip `83bde10a5` (~17:25–17:32)

1. `win_g05_rebuild` ensure exit 0; `g05_relink_env` exit 0; reloc plant OK; HAS_HOME helpers=37.
2. **First ld FAIL** — **not** `g_pipeline_elf_reloc_*` (those resolved). New undefs from `runtime_pipeline_abi_widen_mixed_thin.o`:
   - `glue_binop_named_narrow_id`
   - `glue_binop_named_pair_wrap_id`
   - `glue_emit_named_narrow_wrap_rax`
   - `glue_emit_named_narrow_wrap_rbx`
3. Providers exist as **T** in tip `src/win_named_narrow_stubs.o` (and Cap soft real Ts on morning tiphead `13e5e99ef39b`) but **not** on `G05_OBJS` / not auto-wired by `g05_relink_env`.
4. Surgical relink started: append `src/win_named_narrow_stubs.o` + dual_bss + reloc_typed to `G05_OBJS`.

### true-fix revision

| Issue | Status |
|-------|--------|
| ld undef `g_pipeline_elf_reloc_*` | **RESOLVED** (reloc_typed + dual_bss plant) |
| ld undef named_narrow / pair wrap (widen_mixed) | **IN PROGRESS** — plant existing `win_named_narrow_stubs.o` on link line |

Still **no PROD raise**. SoftCap PE clamp retire: **not yet**.

## Surgical relink result (~17:33 Asia/Shanghai)

- Appended `src/win_named_narrow_stubs.o` (+ dual_bss + reloc_typed) → **relink exit 0**
- tip-HEAD Cap soft Win sha12 **`ae81595209f3`** size **7989102**
- Dig install: cave `lab_CapSoftWin_tiphead.exe` = `ae81595209f3` (bak dig-egg `06fa052fb409` at `.bak_pre_83bde`)
- Prefer-M2 symbols present: `T glue_block_body_emit_let_init` @`0x14010bed0`, `T asm_ctx_local_find_offset`
- `win_g05_rebuild.sh` patched to append named_narrow stubs on future full rebuilds

## Cold 4-gate (dig tiphead `ae81595209f3`)

| gate | tiphead | PROD Soft Cap `db734adafe5e` |
|------|---------|------------------------------|
| p_ret_lit | **CG002** | OK |
| p_ret_fwd | **CG002** | OK |
| p_ret_local | **CG002** | OK |
| _var_let | **CG002** | OK |
| **score** | **0/4** | **4/4** |

**true-fix cold-chain: NO** (CG002 class — same historical tip SoftCap Cap soft tiphead residual; morning `13e5e99ef39b` also CG002 on aggregate). Door green ≠ knife close.

## SoftCap PE clamp retire?

**No.** Tiphead Cap soft linked with Prefer-M2 emit_let T, but cold CG002 blocks Cap soft emit path verification; SoftCap dig Prefer-M2 remains STOP; PROD keeps clamp.

## PROD / nail

- PROD Soft Cap **`db734adafe5e`** unchanged (sanity cold 4/4)
- Nail **`ecdb5cc1e`** unchanged
- Darwin / Ubuntu not touched this beat

## Next / blockers

1. **Hard residual:** tip-HEAD Cap soft Win `ae81595209f3` cold **CG002** on aggregate gates (not ld undef).
2. Dig CG002 abort path on `ae815` (parse skip / Cap soft T / N≥5) — reuse prior tiphead CG002 map; do not re-thrash helpers-only.
3. Optional: wire `win_named_narrow_stubs.o` into committed `g05_relink_env.sh` (currently Win tmp rebuild script only).
4. SoftCap PE clamp drop still blocked until Cap soft tiphead cold green + Prefer-M2 end-to-end.
