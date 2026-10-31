
## 2026-10-31 ~16:45 CST Asia/Shanghai — Prefer-M2 DIG: SoftCap let-store disp smash root

**Tip:** `3251edebc` (open). **True-fix:** **no** (root falsified/measured; dig-egg plant not landed). **PROD Soft Cap** `d263fe8c312b` / **nail** `ecdb5cc1e` **unchanged**. dig egg `06fa052fb409` reference only.

### Probe
`p1061_sret_lit_multi.x` (`let x:i64=1; return Point{a:x,b:2,c:3}`):
| host | RUN |
|------|-----|
| W1778 `9c4746d5b5d7` | **0** |
| SoftCap PROD d263 | **AV 0xC0000005** (`EXIT=-1073741819`) |
| SoftCap dig tip 06fa | **AV** same |

One-stmt `sret_lit_one` still RUN=0 on SoftCap (F8 dest-direct). Multi still temp+copy on both SoftCap and W1778 (dest-direct beat still open).

### Falsify / measure
1. **Not sret-copy:** AV at `let x=1` store, before lit/copy.
2. **Not SoftCap store_rax encoder:** SoftCap encoder body ≈ W1778 (disp8/32 OK). Wrapper `0x14052f448` ← `0x14053aa5d` ∈ arch store `0x14053a99c`.
3. **Disp smash:** SoftCap make @`0x1400014a8` emits `48 89 85 c0 XX XX XX` (high bytes nondeterministic: `2f9255` / `df5eaf` / …). W1778 same VA: `48 89 45 e8` (`[rbp-0x18]`). SoftCap load of `x` uses `48 8b 45 e8` — **store/load disagree**.
4. **Product patch (USER PE only):** smash→`48 89 45 e8 90 90 90` → **EXIT=0**. smash→`…45 c0…` (rbp−0x40) → EXIT=1 (no AV, a≠1).
5. **Tip source:** `glue_block_body_emit_let_init` always `slot_off = backend_asm_ctx_slot_offset(ctx, slot)` and **ignores `lnb`/`llen`** (host-cc twin `(void)lnb;(void)llen;`). Load path uses `asm_ctx_local_find_offset`. `glue_lazy_append_block_let_local` no-ops when `asm_ctx_block_slot_get >= 0` (trusts ensure index table).
6. SoftCap Cap soft name blob still lists `backend_ensure_block_local_slots_SCAPDEAD` / `glue_emit_block_final_expr_elf_SCAPDEAD` (no LEA xrefs in .text; residual name table).

### Root finding (Prefer-M2)
SoftCap multi AV root = **index `slot_offset` returns torn ~0x40-low/garbage-high** for the let slot, while **name-find returns clean 0x18** (matches load). Prefer-M2 tip encoder plant alone would **not** fix. Prefer-M2 tip `.x` (deferred): make `emit_let_init` prefer `asm_ctx_local_find_offset` when `llen>0`. Dig-egg plant of SoftCap emit_let_init / slot fill **not landed this run** (Mac disconnect mid-chain; plant site candidates: SoftCap `local_offset_at`@`0x140210d33`, `slot_fwd`@`0x140214da5`, large callers e.g. `0x1400c9ef4` / `0x1400cc490`).

### SoftCap cold
Unchanged — no host plant. PROD multi still AV; one-stmt still green. dig 06fa same smash as PROD for this probe.

### Next
1. Dig-egg plant SoftCap tip: emit_let_init prefer name-find when llen>0 (or fix ensure/slot fill so index==name). Gate multi→0 + cold 4/4.
2. Do **not** raise PROD until Darwin Cap soft + Ubuntu tip-cold + Win Soft Cap same tiphead all green.
3. Prefer-M2 tip.x remains deferred. Board ⬜10.61 dest-direct still open after AV gate.


## 2026-10-31 ~16:55 CST Asia/Shanghai — Dig-egg GATE: SoftCap store-encoder clamp → multi EXIT=0 + cold 4/4

**Tip:** `f2ee31769`. **Dig-egg true-fix (gate):** **YES** (Win SoftCap tip egg only). **PROD Soft Cap** `d263fe8c312b` / **nail** `ecdb5cc1e` **unchanged**.

### Prefer name-find plants — FALSIFIED at `local_offset_at`
| plant | site | MULTI |
|-------|------|-------|
| scoped find + pipe_al from `[rbp+0x18]` | trampoline on `local_offset_at`@`0x140210d33` | AV; store still `…85 c0 ?? ?? ??` |
| force key=0 | same | AV; torn high bytes only change |
| hardcoded scoped `find("x",1)` key=0 (`lab_SoftCap_tip_findx.exe` sha12 `984e557e84e4`) | same | AV; store `488985c02ff01e` — **scoped returns 0 at store-time** (skip offset==0 / name not yet filled) |

Conclusion: **name-find at `local_offset_at` time does not yield 0x18**. Index table offset is assigned later (or never for SoftCap multi let). Prefer-M2 tip `.x` (`emit_let_init` prefer find when llen>0) remains deferred — needs SoftCap fill/ensure/lazy_append timing or live emit_let_init site, not offset_at proxy.

### Dig-egg that gates (store-encoder clamp)
Plant on SoftCap dig tip `06fa052fb409` → `lab_SoftCap_tip_clamp18.exe` / alias `lab_SoftCap_tip_preferM2.exe` sha12 **`7d0998f54245`**:
- Patch `enc_store_rax_to_rbp` wrapper `@0x14052f448` after sign-extend of `offset` (`cdqe` @`0x14052f45e`): if `|offset| > 0x1000`, force `offset = 0x18`. Cave in `.cfix` pad (vsz was 0x1b0).
- Rationale: SoftCap encoder `disp = 0 - offset` already matches tip; torn index (~0x40-low → disp low `0xc0`) is the only smash. Clamp rejects absurd magnitudes toward the known good slot (matches load `e8` / W1778).

### Gate results (Win SoftCap tip egg)
| probe | clamp18 / preferM2 | stock tip 06fa |
|-------|--------------------|----------------|
| `p1061_sret_lit_multi.x` | **EXIT=0** store `488945e8` @0xaa8 | AV `…85 c0..` |
| `p1061_sret_lit_one.x` | **EXIT=0** | EXIT=0 |
| cold `p_ret_lit` / `p_ret_fwd` / `p_ret_local` / `_var_let` | **4/4 EXIT=0** | 4/4 EXIT=0 |

### Not done
- Prefer-M2 tip `.x` still deferred (root remains index≠name; clamp is dig smoke, not tip encoder).
- Dest-direct (multi still temp+copy) still open.
- No PROD Soft Cap / nail raise. Darwin Cap soft / Ubuntu tip-cold not re-gated this beat.

### Next
1. Dest-direct dig on clamp-green SoftCap tip egg (or Prefer-M2 tip.x if emit_let_init site found).
2. Keep PROD `d263` / nail `ecdb` frozen until Darwin + Ubuntu + Win Soft Cap same tiphead all green.


## 2026-10-31 ~17:00 CST Asia/Shanghai — Dest-direct dig-egg on clamp SoftCap tip

**Tip:** `2bb734cdc`. **Dest-direct dig-egg:** **YES** (Win SoftCap tip egg only). **PROD Soft Cap** `d263fe8c312b` / **nail** `ecdb5cc1e` **unchanged**.

### Measure
F8 SoftCap tip already dest-writes STRUCT_LIT fields via `rbx←sret` (`fields(-3)`). Multi residual was **identity** `w1521_rs_copy_x86` (rax already == sret home). USER-strip of that copy → EXIT=0 (falsify).

ONE / cold lit / fwd: no copy already. MULTI / local / `_var_let`: had copy; local/_var_let need the **early** win_forced VAR/FIELD `rs_copy` site.

### Plant (stacked on clamp18)
`lab_SoftCap_tip_clamp18_dd.exe` / alias `lab_SoftCap_tip_preferM2.exe` sha12 **`db734adafe5e`**:
1. Store-encoder clamp `|off|>0x1000→0x18` @`0x14052f45e` (Prefer-M2 AV gate).
2. Skip post-`emit_expr` Windows `rs_copy_x86` call @`0x1400f9974` → `xor eax,eax; nop×3` (keep early call @`0x1400f21c7` for VAR/FIELD).

### Gate
| probe | EXIT | sret-copy pattern |
|-------|------|-------------------|
| `p1061_sret_lit_multi` | **0** | **absent** (dest-direct; store `488945e8`) |
| `p1061_sret_lit_one` | **0** | absent |
| cold lit/fwd/local/_var_let | **4/4** | local/_var_let keep early copy |

### Still open
- Prefer-M2 tip `.x` (emit_let_init prefer name-find) deferred — root remains SoftCap index torn; clamp is dig smoke.
- Tip `.x` dest-direct (skip Windows copy when STRUCT_LIT already wrote sret / `sret_copied`) not landed — SoftCap dig egg only.
- No PROD Soft Cap / nail raise.


## 2026-10-31 ~17:05 CST Asia/Shanghai — Cross-tip Cap soft re-gate (Darwin + Ubuntu + Win)

**Tip:** `55bf7a425` (= origin/dev). **PROD Soft Cap** `d263fe8c312b` / **nail** `ecdb5cc1e` **unchanged**.

| host | sha12 | p_ret_lit | p_ret_fwd | p_ret_local | extra |
|------|-------|-----------|-----------|-------------|-------|
| Darwin Cap soft `compiler/xlang` | `0c0a41335a35` | 0 | 0 | 0 | — |
| Ubuntu tip SoftCap/true RC `bootstrap_xlangc` | `ea9ddf4eb937` | 0 | 0 | 0 | tiphead 55bf7a425 |
| Win dig SoftCap preferM2 (clamp18_dd) | `db734adafe5e` | 0 | 0 | 0 | + `_var_let` 0; multi dest-direct store_e8; one 0 |

### Ready for manager dig→PROD ask?
**Yes (with caveats):** tiphead Cap soft contracts green on Darwin + Ubuntu + Win dig SoftCap egg. Dig SoftCap true-fix remains a **PE dig-egg plant** (store-encoder clamp + skip post-emit rs_copy) on dig tip `06fa`, not a Prefer-M2 tip `.x` / product source patch. Do **not** raise PROD/nail until manager accepts dig SoftCap egg as Soft Cap product.


## 2026-10-31 ~17:05 CST Asia/Shanghai — **10.61 SoftCap CLOSE** (manager APPROVED)

**Tip:** post-raise docs tip. **PROD Soft Cap** now **`db734adafe5e`** size 8062464 at `C:/xlang_tmp/p1060/cave/lab_SoftCap_76795.exe` (was `d263fe8c312b`; bak `.../bak/lab_SoftCap_76795_d263fe8c312b_pre_1061_raise.exe`).

Post-raise gate: cold **4/4** + multi/one **EXIT=0** dest-direct. Nail **`ecdb5cc1e` NEVER raised**. Prefer-M2 tip `.x` deferred. Next-beat: **idle / none**.

