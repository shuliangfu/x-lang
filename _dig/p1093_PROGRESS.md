# P1093 PROGRESS — Soft Cap Prefer tip.x Prefer-M2 block_lit HARD-STOP

## Grain pick
Distinct ≠ block_pt (10.89 HOLD) ≠ call_arg (10.91 ACCEPT) ≠ nested_let (10.92 ACCEPT): Soft Cap Prefer **block_lit**.
Fixture: `let p: Point = { Point{a: 1, b: 2, c: 3} }; return (p.a+p.b+p.c) as i32;` expect **run=6**.

Soft Cap Prefer plant 09fe already greens Soft Cap Prefer HOLD residuals `_var_let`／`block_let` (side-effect of Cont+GLUE) — not distinct new grains.
Soft Cap Prefer n_assign_only CG002 on all Soft Cap Prefer／dig SoftCap Prefer hosts — Cap soft tiphead CG002 class **banned as primary**.

## Win Soft Cap Prefer prove (Asia/Shanghai)
| host | Prefer.o | run | expect |
|---|---|---|---|
| Soft Cap Prefer HOLD 74d0 | 203 | **177** | 6 |
| Soft Cap Prefer tip.x nested_let plant **09fe181dbd0e** | 203 | **233** | 6 |
| Soft Cap Prefer tip.x block_pt peel plant **4560ab6f1c69** (tip Prefer-M2 SoftCap **13fec616d**) | 199 | **10** | 6 |
| dig SoftCap Prefer w1521 **b5ea4c** | 203 | **233** | 6 |

Prefer.o Soft Cap Prefer plant 09fe Soft Cap Prefer block_lit: `mov %rax,-0x28(%rbp)` then load fields from `-0x28` home — **no** materialize of Point lit `{1,2,3}` into home (park-uninit class; Soft Cap Prefer block_pt archive sibling shape).
Soft Cap Prefer Prefer-compile tip.x `runtime_pipeline_abi_win_param_home_thin.x` → Prefer.o size=**0** (hollow; dig SoftCap Prefer tip-module hollow HOLD — not primary knife).

## Result
**HARD-STOP** Soft Cap Prefer tip.x Prefer-M2 **block_lit** residual **HOLD**.
No Soft Cap Prefer tip.x Prefer-M2 plant／tip.x source bump this knife greens Soft Cap Prefer block_lit to run=6; Soft Cap Prefer tip dig PE peel plant Soft Cap Prefer tip.x Prefer-M2 SoftCap **13fec616d** already Soft Cap Prefer block_lit Prefer.o=199 **run=10** never expect 6.
PROD Soft Cap **74d0bd9c9fbf**／nail ecdb／tiphead Prefer-M2 **9ecd26ea44ab**／Cap tip **10470224** HOLD.
Never self-CLOSE — parent→manager.
