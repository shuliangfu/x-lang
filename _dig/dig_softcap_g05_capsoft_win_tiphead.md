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

## CG002 root DIG (~17:43 Asia/Shanghai) — ae815 vs PROD/F9/w1778

### Re-verify hosts
| host | sha12 | size |
|------|-------|------|
| dig tiphead Cap soft | **ae81595209f3** | 7989102 |
| morning tip SoftCap Cap soft | 13e5e99ef39b | 7990620 |
| SoftCap bak_pre_83bde | 06fa052fb409 | 8062464 |
| FACE_UNIFY F9 dig SoftCap PE | d263fe8c312b | 8062464 |
| PROD Soft Cap | **db734adafe5e** | 8062464 |
| w1778 Cap soft | 9c4746d5b5d7 | 8447113 |

### Cold 4-gate (`build` / bare `-o`)
| host | lit | fwd | local | _var_let |
|------|-----|-----|-------|----------|
| tiphead **ae815** | **CG002** | **CG002** | **CG002** | **CG002** |
| morning **13e5** | CG002 | CG002 | CG002 | CG002 |
| F9 dig **d263** | OK | OK | OK | OK |
| PROD **db734** | OK | OK | OK | OK |
| w1778 **9c47** | OK | OK | OK | OK |

### Parse / emit iso (`-c`)
| probe | ae815 | 13e5 | SoftCap 06fa/PROD/F9 | w1778 |
|-------|-------|------|----------------------|-------|
| ret0 | OK | OK | OK | OK |
| scalar_let `let x: i64=1` | CG002 code_len=**17** | same | same (SoftCap `-c` quirk) | **OK** |
| let_slit named-struct | CG002 code_len=**0** | same | **OK** | **OK** |
| fn_ret_Point | OK but **false green** (nm: only `T main`, mk dropped) | — | — | OK nf≥2 |

### Root finding (true-fix class)
1. **Tip-HEAD Cap soft Win `ae815` cold CG002 is Cap soft tiphead family residual** (same as morning `13e5`), **not** ld-undef and **not** Prefer-M2 tip.x alone.
2. Abort class for aggregate gates: **named-struct let → empty codegen ctx (`code_len=0`)** — prior hangprobe on `13e5` mapped this to **parse-skip** (`diagnostic_parse_skip` → `skip_one_function_full_into`) before Cap soft `finish_struct_lit` / HAS_HOME helpers. ae815 same cold surface; do **not** re-thrash helpers-only.
3. **SoftCap PE dig F9 `d263fe8c312b` already cold 4/4** (parse/sret plants on SoftCap PE text). Tiphead Cap soft **rebuild from Prefer-M2 tip does not carry those SoftCap PE plants** → cold regresses to CG002. F9 green ≠ Cap soft tip-HEAD green; door green ≠ close knife.
4. `scalar_let` CG002 code_len=17 appears on SoftCap PE **and** Cap soft tiphead under `-c`; only w1778 OK. **Not** the cold-gate discriminator (PROD `build` 4/4 despite `-c` scalar_let CG002). Cold residual discriminator is **let_slit / aggregate** Cap soft tiphead vs SoftCap PE/w1778.
5. Prefer-M2 SoftCap dig remains **STOP**. Cap soft tiphead has Prefer-M2 `emit_let` / `asm_ctx_local_find_offset` symbols HIT but Cap soft emit path never verified on cold green.

### PROD / nail
- PROD Soft Cap **db734adafe5e** re-verified cold **4/4** — **unchanged** (no raise).
- Nail **ecdb5cc1e** — **not raised** this beat.
- Darwin Cap soft `0c0a41335a35` / Ubuntu tip SoftCap `ea9ddf4eb937` — not touched.

### Next (no fake green)
1. Smallest Cap soft tiphead isol: restore **named-struct parse acceptance** in let/signatures so `skip_one_function` is not taken (w1778 parser path), then Cap soft `finish_struct_lit` can run — dig plant Prefer-M2 host-cc of proven parser pieces; **or** guarded Cap soft tiphead rebuild that actually wires those parser Ts.
2. Do **not** treat F9 SoftCap PE cave promote as Cap soft tip-HEAD cold-chain close.
3. SoftCap PE clamp retire still **NO** until Cap soft tiphead cold green + Prefer-M2 E2E.
4. Soft-stop 20:00; usage stop at 99.5%.


## 12) 2026-10-31 ~18:06 CST — named-struct parse slit (thin_glue first-wins)

- Hangprobe Cap soft tiphead `ae815` let_slit: HIT `named_type_x` / `type_alloc`; **MISS** `pipeline_type_init_named_at` / `finish_struct_lit`; HIT parse-skip. w1778 opposite (finish_struct HIT; no skip).
- True-fix: tiphead `named_type_x` prologue **`sub rsp,0x258`**; w1778 + on-disk `pthin_type_ref_consume_real.o` = **`sub rsp,0x628`**. type_alloc body identical → Cap soft under-frame → alloc returns 0 → named_type fails → parse-skip → CG002 `code_len=0`.
- Link root: `parser_asm_thin_glue.o` (USER_ASM_LINK, stale small-frame W) **first-wins** over `build_asm/selfhost_pabi/pthin_type_ref_consume_real.o` (large-frame W). `objcopy -N` refused (reloc-named); `objcopy --redefine-sym …=__stale_*` clears 31 overlap W on thin_glue.
- Dig: redefine thin_glue → relink dig host (not PROD/nail; not SoftCap PE promote). Live page tip → `7086f0da7`.


## 13) 2026-10-31 ~18:18 CST — TYPE_REF_STRIP dig host (thin_glue redefine → consume_real)

- Dig host: `lab_CapSoftWin_tiphead_TYPE_REF_STRIP.exe` sha12 **`7c205f452157`** size 8024972 (dig-only; cave tiphead still **`ae81595209f3`**).
- `parser_asm_thin_glue.o` 31 overlap W → `__stale_*`; link binds `pthin_type_ref_consume_real.o`.
- Dig `named_type_x` prologue **`sub rsp,0x628`** (was tiphead 0x258) — frame true-fix closed.
- Cold dig **still 0/4 CG002** (`code_len=0`) on `p_ret_lit` — same class as ae815. PROD Soft Cap **`db734adafe5e` lit OK / 不升**. Nail ecdb **不升**.
- Hangprobe (let_slit): dig+tip **parse_skip HIT**; dig **finish_struct MISS**; w1778 finish_struct HIT / parse_skip MISS. Dig named_type HIT @0x628 still does not clear parse-skip.
- Surgical redefine (only named_type+type_ref_impl) relink aborted (g05 fell to CC-residual / WinMain undef) — not a symbol falsify; keep full-31 redefine dig artifact.
- **Next slit:** why consume_real-framed named_type still → parse-skip / no finish_struct (init_named reachability + sibling type_ref path; not SoftCap PE promote). Prefer-M2 SoftCap dig STOP.

## 14) 2026-10-31 ~18:25 CST — TRS_TRAMP (stale → consume_real E9)

- Dig host: `lab_CapSoftWin_tiphead_TRS_TRAMP.exe` sha12 **`54d57f8b082d`** (from TYPE_REF_STRIP + E9 tramp `__stale_*` → live `pthin_type_ref_consume_real` bodies).
- Hangprobe let_slit: **named_type / type_ref_impl HIT** (tramp path); **finish_struct still MISS**; parse_skip still HIT. Cold still CG002 `code_len=0`.
- True-fix closed for relative-call false-bind to `__stale_*` after redefine: tramp makes type path hit consume_real. Still insufficient for Cap soft emit.
- PROD Soft Cap **`db734adafe5e` 不升**; nail ecdb **不升**. Prefer-M2 SoftCap dig STOP.

## 15) 2026-10-31 ~18:40 CST — primary_ident stub true-fix (acceptance slit)

- Tip / TYPE_REF / TRS dig `parser_asm_primary_ident_x_into_c` = **8-byte E9 stub → `primary_suffix_loop`** (thin_glue reloc intentional alias). Tip EXE has **no** 0x6b8 / 0xbb8 primary body.
- w1778 has real ~2072B primary_ident (frame **0xbb8**) calling `lbrace_looks_like_block` / `empty_ident_braces` / `finish_struct_lit_ptr`.
- Real Cap soft body lives in `build_asm/selfhost_pabi/pthin_primary_lbrace_real.o` (W primary_ident frame **0x6b8**) — **not** in default G05_OBJS / USER_ASM_LINK (only thin_glue stub).
- Dig PRIMARY_LBRACE `5bace8ed04e4`: dual primary (low REAL + high E9 stub). E9FIX `6d30bc5a5c71` retargets stub→REAL; still CG002; **named_type still 0x258** there (no TYPE_REF strip). hang_focus: primary often MISS_rc; finish MISS.
- FACE_TRAMP `3feda7638972`: `finish_struct_into_c` HIT still CG002 (likely type-decl path, not let-lit).
- **Next slit:** combine TYPE_REF_STRIP (named_type **0x628**) + primary_ident real (redefine thin_glue primary→`__stale_prim_*` + link `pthin_primary_lbrace_real.o` + consume_real) → hangprobe finish vs parse_skip. No SoftCap PE promote. PROD `db734` / nail ecdb **不升**.

## 16) 2026-10-31 ~18:47 CST — COMBINED TYPE+PRIM dig host (dual-redefine + both reals)

- Dig host: `lab_CapSoftWin_tiphead_COMBINED_TYPE_PRIM.exe` sha12 **`129b2d41fb57`** size 8081379 (dig-only; cave tiphead restored **`ae81595209f3`**).
- thin_glue: type_ref → `__stale_*` + primary family → `__stale_prim_*`; G05_OBJS prepend `pthin_primary_lbrace_real.o` + append `pthin_type_ref_consume_real.o`.
- NM live: `primary_ident` **REAL frame 0x6b8**; `named_type` **REAL frame 0x628**; `finish_struct_lit_from_type_ident_x` **REAL frame 0x368**.
- Cold COMBINED **still 0/4 CG002** `code_len=0`. Hangprobe: live named_type/primary **MISS**; **`__stale_*` / `__stale_prim_*` HIT** — thin_glue internal relative calls still bind stale bodies after redefine (same class as TRS_TRAMP necessity).
- PROD Soft Cap **`db734adafe5e` lit OK / 不升**. Nail ecdb **不升**. Prefer-M2 SoftCap dig STOP.

## 17) 2026-10-31 ~18:49 CST — COMBINED_DUAL_TRAMP — named-struct parse acceptance TRUE-FIXED

- Dig host: `lab_CapSoftWin_tiphead_COMBINED_DUAL_TRAMP.exe` sha12 **`064b35b2e8cc`** (COMBINED + E9 tramp 60 `__stale_*`/`__stale_prim_*` → live reals).
- Hangprobe let_slit: **named_type HIT / primary_ident HIT / finish_struct_lit HIT**; **parse_skip MISS**; stale bodies MISS. `-c` ft_slit2: **no CG002** — exits typeck.
- Cold dig **0/4 TYPECK** (class shift CG002→TYPECK): `expected  , found W` / slit `expected  = Po, found Point` (truncated type-name identity). PROD Soft Cap **`db734adafe5e` lit OK / 不升**. Tiphead cave **`ae81595209f3`**. Nail ecdb **不升**.
- **Parse acceptance isol CLOSED** for Cap soft tiphead dig path (fix parse-skip → finish_struct_lit). **Next slit:** Cap soft tiphead typeck type-name identity (`Po`/`W` truncation vs full `Point`) — not SoftCap PE promote.

## 18) 2026-10-31 ~18:51 CST — MIN_TRAMP (12-sym) same TYPECK class

- Dig `lab_CapSoftWin_tiphead_COMBINED_MIN_TRAMP.exe` sha12 **`957f60cda4f6`**: only named_type/type_ref_impl + primary/finish/lbrace/fields/anonymous/empty_braces/suffix_loop stale→live (12 E9).
- Same surface as dual-60: `-c` slit **typeck** `expected = Po, found Point`; cold **0/4 TYPECK** `expected , found W`. Over-tramp 60 **not** unique cause.
- **Parse acceptance remains CLOSED**. Next = typeck type-name identity isol (why expected side truncates / empties under consume_real+primary real wire). PROD `db734` / nail ecdb **不升**. Prefer-M2 SoftCap dig STOP.
