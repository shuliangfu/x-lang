
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

