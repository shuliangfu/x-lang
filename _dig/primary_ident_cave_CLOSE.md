# primary_ident_cave CLOSE — knife 10.46 SoftCap work

## Verdict
**Root fix landed on SoftCap WORK copy only** (PROD Restored baseline untouched).

Cave `@0x558e9f` (PE `0x55849f`) replaces SoftCap `primary_ident_x` stub `@0x5dd6dc`
(was E9→`suffix_loop`; now E9→cave). Order: **kind → zeros → set_var_name → line_col**.

Fail-open v2 heuristic:
- If next tok is SEMI / RBRACE / EOF → scan source char before IDENT (skip ws).
- If prev char is binop / `(`, `,`, `[`, `!`, `=` … → **build EXPR_VAR** (unlocks `return a + b;`).
- Else → return 0 no consume (preserves SoftCap `snap_set_return_path` for bare `return x;`).

## SoftCap side table (Win, Mac→ssh windows-server)

Seeds: `C:/xlang_tmp/seeds/` (+ empty `runtime_asm_io_stubs.from_x.c` + prebuilt `.o`).

| case | PROD L | SOFT work | ISOL | LIVE | SOFT run ec |
|------|--------|-----------|------|------|-------------|
| letret7 | PASS | PASS | PASS | PASS | 7 |
| two_lets | CG002 | **PASS** | **PASS** | PASS | 5 |
| one_let_add | CG002 | **PASS** | **PASS** | PASS | 5 |
| two_lets_ret_a | PASS | PASS | PASS | PASS | 3 |
| three_lets | PASS | PASS | PASS | PASS | 3 |
| ret_add | PASS | PASS | PASS | PASS | 7 |
| add2 | CG002 | XT001 | XT001 | PASS | — |
| if0 | CG002 | CG002 | CG002 | PASS | — |
| ret0 | PASS | PASS | PASS | PASS | 0 |

**Score:** PROD **5/9** → SoftCap work **7/9** (raised past prior 1/8 natural). LIVE 9/9.

Hit dig (SOFT work): `two_lets` cave=4 alloc_slot=1 set_body=1 set_var=4; bare `letret7` set_var=0 (snap preserved).

## Artifacts
- WORK: `C:/xlang_tmp/xlang_softcap_cave_work.exe` size **7961399**
- ISOL: `C:/xlang_tmp/xlang_parse_commit_isol.exe` size **7961399** (same cave)
- PROD Restored: `C:/xlang_tmp/xlang_comboB_L_before_mega_fail_bisect.exe` **7961399**, stub still E9→suffix (`e997dbffff`)
- Cave src: `C:/xlang_tmp/isol_ident/cave_v2.S` / `cave_v2_fix.bin` / `build_cave_v2b.py`
- I fold: `C:/xlang_tmp/xlang_comboB_I_fold_7945801.exe` **7945801** intact

## body[0] nail (unchanged)
- alloc_slot SoftCap `0x140203be1`; set_body_ref `0x140203f83`

## Bans held
禁 10.74／HARD BAN／CloudAgent／mega 放大／tip 叶子／SoftCap emit E9／硬拧 COUNTFN／新 host-cc .c／LEGACY／未绿勿 push／钉盘 ecdb5cc1e 不升。PROD 基线未毁。

## Not done / next card
1. **add2** — parse commits (alloc_slot=2) but typeck `expected i32, found *u8` on `return add(...)` (call/ret typing; not primary_ident).
2. **if0** — still CG002, alloc_slot=0 (if/cond path; different miss).
3. Formal Win 侧验脚本 + Darwin Cap soft + Ubuntu tip-cold RC — **deferred** until SoftCap nearer full green; **no commit/push**.

## tip / nail
tip 67e466cf5／工作 tip 7b85bd1a9；钉盘 ecdb5cc1e 不升。
