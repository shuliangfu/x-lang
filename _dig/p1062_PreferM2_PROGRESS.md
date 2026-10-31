# 10.62 SoftCap — Prefer-M2 tip.x prefer name-find (PROGRESS / SoftCap dig STOP)

**Date:** 2026-10-31 ~17:20 CST (Asia/Shanghai)
**Tip:** `83bde10a5` (Prefer-M2 tip source; Cap soft Win tiphead dig on this tip)
**PROD Soft Cap:** `db734adafe5e` (**unchanged** — PE clamp dig-egg kept)
**Nail:** `ecdb5cc1e` (**unchanged**)
**Beat:** Prefer-M2 tip `.x` (or twin) so `emit_let_init` prefers `asm_ctx_local_find_offset` when `llen>0`; strip-clamp dig host multi EXIT=0 + SoftCap cold 4/4; no PROD raise.

## Verdict

**STOP Prefer-M2 SoftCap dig.** SoftCap PE verify hard-blocked: multi torn offset does **not** enter via `emit_let_init` `slot_off` return, so tip.x Prefer-M2 at emit_let cannot retire the PE clamp on this host.

**true-fix SoftCap multi strip-clamp:** **NO** (still AV / torn).

## Tip.x change (landed)

`glue_block_body_emit_let_init` (thin `.x` / thin `.c` / mega twin):

After `slot_off = backend_asm_ctx_slot_offset(ctx, slot)`, if `llen > 0 && lnb != 0`:
`found = asm_ctx_local_find_offset(ctx, lnb, llen)`; if `found >= 0` then `slot_off = found`.

No NEW host-cc `.c`. Guarded by `llen>0` (Darwin/Ubuntu source-safe).

## SoftCap dig evidence (why STOP)

1. **Strip-clamp only** (`38727056bb53`, restore BAK at `0x14052f45e`, keep skip `rs_copy` @`0x1400f9974`):
   - multi host OK, run **AV**
   - USER has `mov [rbp-0x436da040], rax` (torn); PROD clamp turns that site into `mov [rbp-0x18], rax` → EXIT=0
2. **Prefer plant at emit_let hook** `0x14011d30e` → CALL-RET stub in grown `.cfix` @`0x14a21e200` (shadow + `local_find`):
   - Host **OK** all probes (cave/shadow fixed vs earlier NOP-pad AV)
   - multi still **AV** / `torn85` / no `e8` — Prefer-M2 at emit_let did **not** rewrite the torn store
3. **prefer + fallback clamp on emit_let return** (`|eax|>0x1000 → 0x18`): multi still torn85 → emit_let’s returned `slot_off` is **not** the `-0x436da040` value
4. **PE clamp site** is a **different** function @`0x14052f44c` (rdx=offset → trampoline `|off|>0x1000→0x18` @`.cfix+0x1b0`). That path re-derives/receives the torn offset **after** / **aside from** emit_let_init Prefer-M2.

Conclusion: SoftCap multi AV root for dig-egg clamp is the `0x14052f44c` offset consumer, not thin `emit_let_init` index return. Prefer-M2 tip.x alone cannot strip-clamp-verify green on PROD SoftCap binary. FACE_UNIFY/over-skip not the blocker this run; **emit_let≠torn-source** is.

## PROD / nail

- PROD Soft Cap **`db734adafe5e`** untouched (still has PE clamp + skip rs_copy)
- Nail **`ecdb5cc1e`** untouched
- Dig hosts only: strip `38727056bb53`, prefer grow `5f26bcf924f6`, diag variants — **not** raised

## Switched beat (alternate Cap soft Win board item)

**`softcap_g05_capsoft_win_tiphead`** — fix `win_g05_rebuild` ld undef `g_pipeline_elf_reloc_*` and rebuild tip-HEAD Cap soft Win so tip SoftCap identity tracks tip-HEAD Cap soft (Prefer-M2 tip.x then rides Cap soft emit; still **no PROD Capless/SoftCap bump** / **no pin** until accepted).

See `_dig/dig_softcap_tip_capsoft_win_promote.md` residual.

## Bans held

No CloudAgent / no PROD raise / no NEW host-cc `.c` / no fake SoftCap green / no mega glue_tail close.

---

## Cap soft Win tiphead DIG (~17:25 Asia/Shanghai) — `softcap_g05_capsoft_win_tiphead`

**Tip now:** `83bde10a5` (Win repo ff to origin/dev; Prefer-M2 in thin.c).

### true-fix: ld undef `g_pipeline_elf_reloc_*`

**RESOLVED (plant path), not open ld-fail.** Evidence:

1. `seeds/runtime_pipeline_abi_reloc_typed_overlay.c` defines **B** `g_pipeline_elf_reloc_r_type` / `_r_pcrel` / `_sidecar_owner` (long names).
2. `win_elf_dual_bss.o` defines **B** `g_pipe_elf_reloc_*` (short names the overlay also refs as U) **and** long `g_pipeline_elf_reloc_*`.
3. Morning `win_g05_rebuild` (~10:28) with that plant: **relink exit 0**, tiphead sha12 **`13e5e99ef39b`** size 7990620 (`lab_tip_SoftCap_CapSoftWin.exe`).
4. Stale promote note “still FAIL ld undef” is **obsolete** relative to that green relink.

### Remaining (this beat)

Cave `lab_CapSoftWin_tiphead.exe` is still dig-egg **`06fa052fb409`** (REV_REALIGN SoftCap), **not** tip-HEAD Cap soft from tip `83bde10a5`. Single detached `win_g05_rebuild` from tip Prefer-M2 is in flight; cold-chain after xlang.exe sha lands. **No PROD Soft Cap raise** (`db734adafe5e` keep clamp). Nail **ecdb5cc1e** unchanged.

Prefer-M2 SoftCap dig remains **STOP** — this beat is Cap soft Win tiphead rebuild/ld only.

### tiphead rebuild result (~17:36 Asia/Shanghai)

- ld `g_pipeline_elf_reloc_*`: **RESOLVED** (reloc_typed + dual_bss)
- ld named_narrow (widen_mixed): **RESOLVED** via `win_named_narrow_stubs.o` on G05_OBJS → relink exit 0
- tip-HEAD Cap soft Win dig: **`ae81595209f3`** (Prefer-M2 emit_let T present)
- cold 4/4 tiphead: **0/4 CG002**; PROD Soft Cap `db734adafe5e` still **4/4**
- SoftCap PE clamp retire: **NO**; Prefer-M2 SoftCap dig remains STOP

## CG002 root on tiphead ae815 (~17:43 Asia/Shanghai)

- Re-verify: tiphead **ae815** cold **0/4 CG002**; PROD **db734** cold **4/4**; w1778 **4/4**; F9 SoftCap PE dig **d263** cold **4/4**.
- Root: Cap soft tiphead aggregate **let_slit → code_len=0** (parse-skip class per prior `13e5` hangprobe); SoftCap PE F9 plants not in Cap soft tip-HEAD rebuild. Prefer-M2 SoftCap dig **STOP**. No PROD/nail raise.
- Next: named-struct parse acceptance isol on Cap soft tiphead (not helpers re-thrash; not F9-as-CapSoft-tiphead fake green).
