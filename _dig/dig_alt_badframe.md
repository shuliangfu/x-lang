# DIG SoftCap alt bad-frame / rbp root

Base: post_fa3 `453f3e66f96c` / alt_57619e `e1c45031fb92`. Short timeout INT3. Ban letter-pile / LIVE SoftCap transplant / arg-loop.

## Frame map (HOST Cap FN `@5752bc`, not user emit)

| site | layout |
|---|---|
| Cap FN `@5752bc` | `push rbp; sub rsp,0x9e0; lea rbp,[rsp+0x80]` |
| saved_rbp | `[rbp+0x960]` |
| retaddr | `[rbp+0x968]` |
| arg homes | `[rbp+0x970..0x988]` (rcx/rdx/r8/r9) — **above** saved_rbp into caller home |
| count | `[rbp+0x998]` |
| alt slots | `+0x8fc` store / `+0x900/+0x904` idxs / `+0x934` loop i — **in** `[0..0x960)` |

User SoftCap lit LIVE emit `sub rsp,0x868/0x878` vs Capless thin `0x68/0x1b8` is **orthogonal** to this host Cap FN `0x9e0` lea frame.

## `@5603b8` — legal prol **and** legal epi (not missing rbp restore)

| | |
|---|---|
| prol | `push rbp; mov rbp,rsp; push rbx; sub rsp,0x428` |
| epi | `@560dc7`: `lea rsp,[rbp-8]; pop rbx; pop rbp; ret` (~0xa0f body) |
| callers | **19** E8 sites (incl. `@5761c2`) |
| alt args | `rcx=[rbp+0x970]`, `rdx=[rbp+0x988]`, `r8/r9` = idxs `+0x900/+0x904` |

Prior "bad frame" as missing epi/**rbp save** → **falsified**. Helper owns classic frame; restores rbp.

## What was misread

1. INT3 mid-insn (`@5603d4`, `@5762a0`) → false AV.
2. `add [rbp+0x934],1` under alt skip does **not** inherently AV (loop head `@5762a2` HIT after add).
3. `@5763c4` reachable under skip; `934=0 < [rbp+0x998]` → `jl @5762c3` re-enters second loop (AV/TIMEOUT) — **loop state**, not corrupt rbp slot.

## Root (this DIG)

- Host alt AV at `@5603b8` body / after-call path = **helper args/state or competing callers**, not absent prol/epi.
- Skip `@5603b8/@56fa68` remains valid bypass; residual red = **post-loop / join** + **user emit still Capless thin** (`0x68/0x1b8` ≠ LIVE `0x868/0x878`).
- GS on `p_ret_fwd` persists (cookie / deeper path).

## Plants

| Isol | sha12 | plant | SoftCap p_ret lit/fwd/local | note |
|---|---|---|---|---|
| alt_57619e | `e1c45031fb92` | jmp `@5761c2→@57629b` | AV/GS/AV | inc HIT; loop state red |
| alt_frame | `313533ca3651` | + jmp `@57629b→@5763c4` | TIMEOUT/GS/TIMEOUT | post_loop HIT; jl re-enter |
| alt_frame2 / fix_rbp | `9378df517f96` | + jmp `@57629b→@5763d6` (force exit clear) | **compile** OK/GS/OK | emit thin `0x68/0x1b8`; **run rc=1** ≠ LIVE; **not 运行绿** |

## Next single-point

Keep force-exit land; DIG **join `@576523`→epi `@576555`** why epi AV / why emit stays Capless thin (who writes frame `0x868` on SoftCap lit path) — not another mid-call skip.

## Ban / PROD

PROD SoftCap `7a2cf5da581a` untouched. Pin ecdb5cc1e not raised. Not green.
