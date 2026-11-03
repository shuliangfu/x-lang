# 10.87 PROGRESS — capsoft_prefer_m2_dig_next_grain

Time: 2026-11-03 ~14:12 Asia/Shanghai (CST, UTC+8)
Knife: local Mac.lan `b93fb82c-3bf3-4127-baa9-c1c63f355789`
Repo: `/Users/shuliangfu/worker/xlang/x-lang` · branch `dev`
Docs tip at OPEN: **`e2f85a0b3`** (CLOSE 10.86＋OPEN 10.87)
Code Prefer-M2 SoftCap A2: **`82da2af73`** (unchanged — no new Prefer-M2 tip.x this knife)

## Manager decision
**CLOSE 10.87 = A ACCEPT** (manager APPROVED). Never self-CLOSE.
OPEN next: **10.88** `capsoft_prefer_m2_dig_next_grain`.

## ACCEPT evidence (prior run — no new dig PE churn this archive)

### Dig SoftCap Prefer plant
- Host: `C:\xlang_tmp\p1060\g05th_dig\lab_SoftCap_d8e2_preferM2_A2_w1521_param_home_P1087_b5ea4c985936.exe`
- SHA12: **`b5ea4c985936`**
- Size: **8091136**
- Base: A2 nested_let plant **`bd9406ca693a`** (kept; NOT raised)
- Grain: tip Prefer `win_param_home` / `w1521_ph_copy_byref` planted into SoftCap dig A2 as distinct SoftCap Prefer emit path (RX `.tpph`); **NOT** SoftCap-parity same-body PE churn on Prefer.o=387
- Tool: `tools/dig/p1087_softcap_dig_prefer_w1521_param_home_plant.py`

### SoftCap Prefer protect 4/4 (plant vs A2 delta)
| case | plant `b5ea4c` | A2 `bd9406` |
|---|---|---|
| softcap_lit | **rc=0** | rc=0 |
| call_arg | **rc=0** | **rc=1** (baseline fail) |
| n_no_assign | **rc=0** | rc=0 |
| block_pt | **rc=0** | rc=0 |

→ SoftCap Prefer protect **4/4 GREEN** on w1521 plant; call_arg is the true advance vs A2.

### SoftCap Prefer P1087 suite (plant)
P1087_`exact` / `classic` / `one` / `multi` / `_var_let` / `local` / `fwd` — **all rc=0**.

## HOLD confirm (untouched)
- PROD Soft Cap / cave Soft Cap **`74d0bd9c9fbf`** NOT raised
- tiphead Prefer-M2 **`9ecd26ea44ab`** HOLD
- nail **ecdb** HOLD (docs)
- Cap tip Prefer-M2b **10470224** sha12 **`e6b1078f4070`** UNTOUCHED (Ban B)
- A2 plant **`bd9406ca693a`** NOT raised (base only)
- Code Prefer-M2 tip stays **`82da2af73`** — **no new tip.x Prefer-M2 grain**
- Ban held: SoftCap-parity same-body dig churn; tip-module TYPE_PTR hollow; tip-cold fmt; dig_* branch

## Acceptance
- SoftCap Prefer dig-only next grain proving Prefer matrix 4/4 (protect) + P1087 suite green: **MET** via plant **`b5ea4c985936`**
- Soft Cap / nail / 9ecd / Cap tip / A2 HOLD: **MET**
- Never self-CLOSE: manager APPROVED CLOSE＝A ACCEPT

## Archive note
Manager exception this CLOSE only: commit `_dig/p1087*` evidence + plant tool into origin/dev with docs. Live knife notes for 10.88 go to `_dig/p1088_PROGRESS.md` (may stay untracked until next CLOSE unless manager says otherwise).
