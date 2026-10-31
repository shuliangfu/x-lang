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

## 2026-10-31 ~16:00 CST Asia/Shanghai — Prefer-M2 parse-append dig (SoftCap Cap soft Win egg)

### Pin: truncate site = SoftCap Cap soft Win FACE_UNIFY eggs (not tip parser.x)

Probe matrix (Win `lab_SoftCap_tip.exe`=`d263fe8c312b` vs W1778=`9c4746d5b5d7` vs SoftCap bak_pre_1060=`7a2cf5da581a`):

| probe | SoftCap tip | SoftCap bak | W1778 | note |
|---|---|---|---|---|
| plain 3× empty if | jcc=1 sp=0x40 | **jcc=3** sp=0x80 | jcc=3 | tip truncates; bak OK |
| if + let + 2×if | jcc=1 | jcc=3 | jcc=3 | tip over-skips mid `let` too |
| while + if + while | jcc=2 | — | jcc=3 | tip drops stmt after first if |
| if-else-if chain | jcc=2 | — | jcc=2 | single if-stmt OK |
| one if / ret_then | match | — | match | |
| p_ret_fwd USER main | **0x88 / jcc=1** | CG002 (pre-raise) | **0xe8 / jcc=3** | |

FACE ladder (hosts copied into `cave/` so seeds resolve):
- F0..F2 / CONSUME_FIX: XT001 on plain_ifs (parse drops trailing `return` → typeck)
- **F3 HIT `e4b57ee59d26` → F9 `d263fe8c312b`**: build OK, **jcc=1** (truncate present at F3 already)
- tip SoftCap PE **byte-identical to F9**

Darwin tip Cap soft `./compiler/xlang` sha12 **`0c0a41335a35`**: plain 3×if `_main` emits **3× cbz** (a/b/c) — tip `parser.x` / `pthin_ctrl.x` source path OK.

### Mechanism (best current)
After first mid-block `parse_if_stmt_into`, SoftCap Cap soft Win FACE_UNIFY eggs leave `lex_cur` past following sibling stmts (ifs **and** `let`/`while`). Outer block loop never appends them → body_sync `nif=1` / `nso=2`. Likely Cap soft egg `scan_sync_after_if` / `realign_lex_after_if_arm` collateral from F3 HIT plant — **not** tip Prefer-M2 `.x` defect (Darwin + SoftCap bak falsify tip-source root for SoftCap identity).

### Prefer-M2 change?
**Blocked** for SoftCap identity this beat: tip `.x` already correct (Darwin positive control). SoftCap Cap soft Win tiphead eggs (F3+) diverge. No host-cc `.c` added; no HARD BAN / mega / glue_tail / P4b / bstrict / CloudAgent; **PROD Soft Cap `d263fe8c312b` / nail `ecdb5cc1e` unchanged**.

### Post metrics (unchanged — no fix)
- tip SoftCap: nso=2 nif=1; USER main span **~0x88** a-only
- w1778: nso=10 nif=3; USER main span **0xe8** a/b/c
- SoftCap cold lit/fwd/local/_var_let 4/4 still green on tip SoftCap (F9); a/b/c still missing in USER main

### True-fix?
**No.** Docs-only dig progress.

### Next
1. Cap soft Win tiphead rebuild / HIT-plant reverse dig (still **no PROD/nail raise**) — restore multi-if append without losing cold 4/4.
2. Optional: SoftCap debugger lex-pos after first `parse_if` (confirm scan_sync over-skip delta vs W1778).
3. Soft-stop 20:00 Asia/Shanghai still applies for later beats.
