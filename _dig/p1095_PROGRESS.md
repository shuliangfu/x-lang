# P1095 PROGRESS — softcap_prefer_m2_tipx_source

Time: 2026-11-03 ~16:00 Asia/Shanghai
Knife: Mac.lan `b93fb82c-3bf3-4127-baa9-c1c63f355789` + Win `ssh windows-server`
HOLD: Soft Cap **74d0bd9c9fbf** / nail ecdb / tiphead Prefer-M2 **9ecd26ea44ab** / Cap tip Prefer-M2b **10470224** / code tip Prefer-M2 SoftCap **13fec616d**
Never self-CLOSE. Ban SoftCap-parity / Cap tip poison / block_pt / block_lit / dig SoftCap tip hollow / tip-cold / Cap soft tiphead CG002 primary / CloudAgent / dig_* branch.

## Tip.x source path (Soft Cap Prefer tip.x Prefer-M2)
- Prefer-M2 SoftCap tip.x authority at HEAD **13fec616d** (docs tip CLOSE 10.94 **8f11f053b**)
- call_arg / win_param_home: `compiler/src/runtime_pipeline_abi_win_param_home_thin.x` (SoftCap Prefer 10.74 Win w1521 byref; tip Prefer `win_param_home.o` 9026B)
- nested_let / enc_store Cont+GLUE: `compiler/src/runtime_pipeline_abi_glue_block_body_emit_let_init_thin.x` (+ `.c`) Prefer-M2 SoftCap A2 **82da2af73**
- block_pt (HOLD, do not reopen): `compiler/src/runtime_pipeline_abi_struct_let_init_thin.x` (**13fec616d**)
- WIP salvage: only `_dig/p1095_OPEN.md`＠15:51; **no** local tip.x edits / no untracked tip.x / no prior Activity-fail tip.x WIP; dirty tree = old probes/junk only

## Step 2 — Win Soft Cap Prefer tip-alone baseline (DONE)
See `_dig/p1095_baseline.md` (local, not git).

| fixture | tip alone 74d0 | dig 3f6ad | dig 09fe |
|---|---|---|---|
| softcap_lit | o=463 **run=0** | o=463 **run=0** | o=463 **run=0** |
| call_arg | o=537 **run=1** | o=553 **run=0** | o=553 **run=0** |
| call_arg_direct | o=484 **run=1** | o=500 **run=0** | o=500 **run=0** |
| nested_let | o=387 **run=1** | o=387 **run=1** | o=387 **run=0** |
| n_no_assign | o=379 **run=1** | o=379 **run=1** | o=379 **run=0** |
| block_let / _var_let | run=1 | run=1 | **run=0** |
| field_assign / return_sret | run=6 | run=6 | run=6 |
| classic/exact/fwd/local/multi/one | run=0 | run=0 | run=0 |

## Step 3 — tip alone already matches? NO
Tip alone Soft Cap Prefer 74d0 **lags** dig plant greens on call_arg family + nested_let family. Not ACCEPT.

## Step 4 — fold dig plant PE deltas into tip.x?
### Dig plant PE deltas (already tip.x-encoded)
1. **call_arg 3f6ad**: plant tip Prefer `win_param_home.o` `.text` (w1521 RCX byref) onto Soft Cap Prefer dig tip PE 74d0 — tip.x source = `runtime_pipeline_abi_win_param_home_thin.x` (already on tip; tip Prefer Soft Cap live Prefer of this thin → Prefer.o=**9026**)
2. **nested_let 09fe**: Cont tramp + GLUE `mov edx,[rbp+0x30]` onto Soft Cap Prefer tip.x call_arg plant — tip.x source = Prefer-M2 SoftCap A2 glue **82da2af73** (`runtime_pipeline_abi_glue_block_body_emit_let_init_thin.x`)

### Soft Cap Prefer tip alone absorb path blocked
| path | result | ban / HOLD |
|---|---|---|
| Soft Cap Prefer tip alone Soft Cap Prefer 74d0 Prefer of tip.x `win_param_home_thin.x` | Prefer.o=**0** hollow crc=0 | dig SoftCap Prefer tip-module hollow HOLD (10.83); dig hollow primary **banned** |
| Soft Cap Prefer tip alone Soft Cap Prefer 74d0 Prefer of tip.x A2 glue thin | Prefer.o=0 XP001/CG002 | same hollow class |
| Soft Cap Prefer tip alone Soft Cap Prefer PROD raise from tip Prefer-M2 SoftCap tip.x | would absorb tip.x into Soft Cap Prefer tip alone host | Soft Cap **74d0 HOLD** — raise **banned** |
| Cap tip Prefer-M2b Soft Cap Prefer tip Prefer Soft Cap host | Cap tip size 7991207 / Ban B | Cap tip poison **banned** |
| Soft Cap Prefer tip dig PE plant (3f6ad/09fe) | already ACCEPT 10.91/10.92 | dig tip PE plant ≠ tip alone; dig plant next-grain HOLD 10.94 |

### Minimal tip.x diff
**None honest.** Prefer-M2 Soft Cap tip.x already carries dig plant PE delta authority (win_param_home_thin + A2 glue). No tip.x source bump can change Soft Cap Prefer tip alone Soft Cap Prefer 74d0 Prefer.o/run without Soft Cap raise / Cap tip poison / dig hollow primary / dig tip PE plant (not tip alone).

**No commit+push** (no tip Prefer-M2 SoftCap SHA bump; code tip stays **13fec616d**).

## Step 5 — Result
**HARD-STOP** Soft Cap Prefer tip alone Soft Cap Prefer 74d0 lag vs dig plant greens (**3f6ad** / **09fe**): tip.x source already encodes dig plant PE deltas; Soft Cap Prefer tip alone Soft Cap Prefer Prefer of tip.x hollow; Soft Cap Prefer tip alone Soft Cap Prefer absorb blocked under HOLD bans.

Ask manager CLOSE Soft Cap Prefer tip.x Prefer-M2 **source** grain HARD-STOP HOLD (tip alone Soft Cap Prefer 74d0 residual HOLD; dig plant greens ACCEPT stay 10.91/10.92).
PROD Soft Cap **74d0bd9c9fbf**／nail ecdb／tiphead Prefer-M2 **9ecd**／Cap tip **10470224**／code tip Prefer-M2 SoftCap **13fec616d** HOLD.
Never self-CLOSE — parent→manager.

## Report checklist
1. tip SHA bumped: **none** (stays **13fec616d**)
2. tip-alone vs dig-plant: tip alone lags (call_arg run=1 vs 0; nested_let run=1 vs 0) — table in `_dig/p1095_baseline.md`
3. Decision: **HARD-STOP** (not ACCEPT; not self-CLOSE)
4. HOLD Soft Cap/nail/9ecd/Cap tip confirmed untouched

## CLOSE 10.95＝(1) HOLD (manager APPROVED)
HARD-STOP Soft Cap Prefer tip.x Prefer-M2 **source** residual HOLD — tip alone Soft Cap Prefer 74d0 lags dig plant; Prefer-M2 Soft Cap tip.x already encodes dig PE @82da2af73; further align needs banned paths. Keep 10.91/10.92 dig plant ACCEPT. Soft Cap/nail/9ecd/Cap tip/code tip **13fec616d** NOT raised. Ship `_dig/p1095_*` manager exception. Never self-CLOSE (manager CLOSED).
