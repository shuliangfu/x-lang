# 10.88 PROGRESS — capsoft_prefer_m2_dig_next_grain (HARD-STOP)

Time: 2026-11-03 ~14:14 Asia/Shanghai (CST, UTC+8)
Knife: local Mac.lan `b93fb82c-3bf3-4127-baa9-c1c63f355789`
Repo: `/Users/shuliangfu/worker/xlang/x-lang` · branch `dev`＝`origin/dev`
Docs tip (CLOSE 10.87＋OPEN 10.88): **`9e7eaef7e`**
Code Prefer-M2 SoftCap A2: **`82da2af73`** (unchanged — no new Prefer-M2 tip.x)
Gate: manager **CLOSE＝A HOLD** · was HARD-STOP proposal · **NOT self-CLOSE**

## HOLD confirm (untouched)
- PROD Soft Cap / cave Soft Cap **`74d0bd9c9fbf`** NOT raised
- tiphead Prefer-M2 **`9ecd26ea44ab`** HOLD
- nail **ecdb** HOLD
- Cap tip Prefer-M2b **10470224** sha12 **`e6b1078f4070`** UNTOUCHED (Ban B)
- A2 plant **`bd9406ca693a`** / w1521 plant **`b5ea4c985936`** NOT rewritten this knife
- `_dig/p1088_PROGRESS.md` (+CLOSE/OPEN) committed on manager CLOSE exception; no dig_* branch

## Part A (done this turn)
CLOSE 10.87 docs＋plant tool＋`_dig/p1087*` → tip **`9e7eaef7e`**＝origin/dev (manager exception).

## Part B — SoftCap Prefer dig residual hunt (read-only hosts)

Hosts (Win `ssh windows-server`; Soft Cap PE not written):
| host | sha12 | size |
|---|---|---|
| w1521 P1087 plant | **b5ea4c985936** | 8091136 |
| A2 P1084 plant | bd9406ca693a | 8083457 |
| CapSoft 1f78 | 1f78def393fc | 8182784 |
| SoftCap dig e24f56 | e24f56c34394 | 8082432 |
| PROD Soft Cap | 74d0bd9c9fbf | 8082432 HOLD |
| tiphead Prefer-M2 | 9ecd26ea44ab | HOLD |

### SoftCap Prefer matrix on w1521 (already CLOSED 10.87 plant)
Protect＋parity＋extras — **all run=0** (non-hollow Prefer.o):
softcap_lit / call_arg / n_no_assign / nested_let / return_sret / call_ret_pt / two_args / fwd /
lit / local / _var_let / multi / one / classic / exact / assign_ok / call_assign / field_assign

→ SoftCap Prefer dig-only **4/4 + 8/8 (+extras) already GREEN** on w1521 **`b5ea4c`**. Replaying SoftCap-parity same-body dig PE would be **banned churn**.

### Apparent reds that are NOT SoftCap-dig next-grain
1. **n_assign_only `return (y as i32)`** — inverted probe. SoftCap dig A2/w1521 correctly assign (stores −18/−20/−20) and return **1**; CapSoft 1f78 assign-mismatch (store −28) returns **0** = false green. Corrected `assign_ok` (Point-wrap check y==1): **w1521/A2 run=0**, 1f78/e24 run=1.
2. **block_pt block-expr** `let p = { let x=1; Point{a:x,b:2,c:3} }` — **run=1 on ALL** SoftCap dig / CapSoft 1f78 / Cap tip Prefer-M2b Darwin. SoftCap dig Prefer.o omits Point field stores; Cap tip emits temp then field-load ABI mismatch. **Universal residual**, not SoftCap-dig-only gap vs CapSoft.

### Why no new Prefer-M2 tip.x / dig plant this knife
- Acceptance needs SoftCap Prefer dig-only matrix **4/4 or 8/8 distinct from w1521** — w1521 already saturates that surface.
- Distinct remaining candidate **block_pt** is CapSoft+Cap tip red too → tip.x Prefer-M2 block-expr grain would need Cap tip validation path under **Ban B Cap tip 10470224** HOLD (same class as 10.86 tip-cold: Cap tip poison risk).
- Ban SoftCap-parity same-body dig PE churn; Ban tip-module TYPE_PTR hollow (10.85 archive); Ban tip-cold fmt; Ban dig_* branch; Soft Cap / nail / 9ecd NOT raise.
- No honest SoftCap Prefer dig PE plant distinct from w1521 without banned paths or Cap tip–touching tip.x grain.

## Decision
**Manager CLOSE 10.88＝A HOLD** (SoftCap Prefer dig-only next-grain residual HOLD). NOT self-CLOSE; manager-approved.
- No new tip Prefer-M2 SHA
- No new dig SoftCap plant
- SoftCap Prefer dig score on current best plant w1521 **`b5ea4c`**: protect **4/4** + SoftCap-parity **8/8** + extras **GREEN** (already archived CLOSE 10.87)
- False residual `n_assign_only` corrected and excluded
- Shared residual **block_pt** block-expr run=1 handed to OPEN **10.89** `softcap_prefer_m2_tipx_block_pt` (Prefer-M2 SoftCap tip.x grain **allowed**)

## Report checklist
1. CLOSE 10.87 docs tip SHA: **`9e7eaef7e`** → CLOSE 10.88 docs tip follows this commit
2. 10.88 tip SHA: **none** · plant: **none** · SoftCap Prefer score: w1521 baseline **4/4+8/8 GREEN** (no new distinct grain)
3. Acceptance: **A HOLD** (manager) — SoftCap Prefer dig-only next-grain residual **HOLD**
4. HOLD Soft Cap `74d0` / nail ecdb / tiphead Prefer-M2 `9ecd` / Cap tip Prefer-M2b **10470224** sha12 **e6b1078f4070** / A2 `bd9406` / w1521 `b5ea4c` confirmed
