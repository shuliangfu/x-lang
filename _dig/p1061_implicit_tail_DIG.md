# has_implicit_return_tail dig — OPEN (dig-only)

**2026-10-31 ~15:37 CST Asia/Shanghai** · manager refined: **not** SoftCap PROD raise.

## Baselines (do not break)
- tip after 10.60 close: **c3f3a2d21** (= origin/dev at open)
- PROD Soft Cap: **d263fe8c312b** size 8062464 — **unchanged this beat**
- nail: **ecdb5cc1e** — never raise
- w1778 SoftCap cold green: **9c4746d5b5d7**
- Darwin Cap soft / Ubuntu tip SoftCap true RC: keep

## First measurement
tip SoftCap USER `main` **0x88** (a-only) vs W1778 **0xe8** (a/b/c) on `p_ret_fwd` / `p_ret_lit` F9 unify_cold products. Gap still present on tip SoftCap `d263fe8c312b`.

## Plan
See `_dig/dig_1060_PROGRESS.md` §2026-10-31 ~15:37. Prefer-M2; no PE thrash first; no PROD/nail raise.

## 2026-10-31 ~15:47 CST Asia/Shanghai — falsify PARSE vs EMIT (live debugger)

### Method (Prefer-M2 dig; no new host-cc .c; no PE plant)
ASLR-aware Win debugger on tip SoftCap `lab_SoftCap_tip.exe`=`d263fe8c312b` and W1778 `lab_W1778_host.exe`=`9c4746d5b5d7` compiling `tests/probes/p_big_struct/p_ret_fwd.x`.
Breakpoints on `w1010_body_sync_level` stmt_order loop: after `num_stmt_order`, after `stmt_order_kind`, after `num_if_stmts` (k==5), and `pipeline_asm_emit_block_if_stmt_elf` entry.

### SoftCap tip (F9 Cap soft Win) — main body block=4
| probe | value |
|---|---|
| nso | **2** |
| kinds | si0 **kind=1** (let), si1 **kind=5** (if) |
| nif at k==5 | **1** |
| emit_if hits | **1** `(block=4, if_idx=0)` |

### W1778 — main body block=6
| probe | value |
|---|---|
| nso | **10** |
| kinds | si0 kind=1 (let), si1..3 **kind=5** (if×3), si4..9 kind=0 |
| nif at each k==5 | **3** |
| emit_if hits | **3** `(6,0),(6,1),(6,2)` |

### Verdict
- **PARSE / AST truncate WINS.** At body_sync entry SoftCap already has `nif=1` / one stmt_order if; emit walker is faithful (1 emit_if call).
- **EMIT / join missing b/c arms ELIMINATED.** W1778 same walker emits 3 ifs when `nif=3`. SoftCap does not fail mid-loop with nif==3.
- Darwin tip Cap soft still emits full a/b/c on same probe → tip `parser.x` source path can parse 3 ifs; gap is **SoftCap Cap soft Win F9/FACE_UNIFY binary AST** (stale/damaged eggs vs tip source, or plant lineage vs w1778), not host-cc body_sync twin.

### Spans (unchanged; no fix this run)
- tip SoftCap USER main still **~0x88** a-only (frame `sub rsp,0x1b8`)
- W1778 USER main still **0xe8** a/b/c (frame `0x78`)
- mk/fw still write a/b/c on SoftCap

### True-fix?
**No.** No Prefer-M2 .x/host-cc reduction landed; falsify only. tip HEAD still **4408c54cf**. PROD Soft Cap **d263fe8c312b** / nail **ecdb5cc1e** untouched.

### Next (Prefer-M2)
1. Count SoftCap vs W1778 `pipeline_onefunc_append_if` / `pipeline_block_append_if` during parse of `p_ret_fwd` (confirm truncate at parse append, not post-parse strip).
2. Diff Cap soft Win F9/FACE_UNIFY parser eggs vs w1778 / tip Darwin Cap soft — why consecutive mid-body `if { return }` after first if are dropped (lexer consume / final-if mis-peek / onefunc flush).
3. Minimal Prefer-M2 `.x` fix only when root is tip source; if binary-only egg lag → guarded tiphead Cap soft Win rebuild (still **no PROD/nail raise**).
4. Success bar unchanged: SoftCap USER main → **0xe8** a/b/c + cold lit/fwd/local/_var_let **4/4**.

Artifacts: Win `g05th_dig/unify_cold/_dig_p1061_falsify.txt`, `_dig_p1061_falsify_w1778.txt`; scripts `/tmp/p1061_falsify_nif2.py`, `/tmp/p1061_falsify_w1778.py` (also under Win `C:\xlang_tmp\`).
