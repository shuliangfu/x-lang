# P1095 Soft Cap Prefer tip-alone baseline (Asia/Shanghai 2026-11-03 ~15:57)

Hosts (SHA12 confirmed this turn):
- tip alone Soft Cap Prefer HOLD PROD **74d0bd9c9fbf** `C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe` size=8082432 — **no dig tip PE plant**
- dig plant call_arg **3f6ad9910c48** size=8089600
- dig plant nested_let **09fe181dbd0e** size=8091136

Recipe: `HOST -c FIX.x -o Prefer.o` (Prefer.o size); `HOST FIX.x -o exe && ./exe` (run=exit).
Fixtures from `C:\xlang_tmp\p1094\` (already-green suite; skip block_pt / block_lit / n_assign_only).

| fixture | tip alone 74d0 Prefer.o/run | dig plant 3f6ad Prefer.o/run | dig plant 09fe Prefer.o/run | expect |
|---|---|---|---|---|
| softcap_lit | 463 / **0** | 463 / **0** | 463 / **0** | 0 |
| call_arg | 537 / **1** | 553 / **0** | 553 / **0** | 0 |
| call_arg_direct | 484 / **1** | 500 / **0** | 500 / **0** | 0 |
| nested_let | 387 / **1** | 387 / **1** | 387 / **0** | 0 |
| n_no_assign | 379 / **1** | 379 / **1** | 379 / **0** | 0 |
| block_let | 535 / **1** | 535 / **1** | 535 / **0** | 0 |
| _var_let | 542 / **1** | 542 / **1** | 542 / **0** | 0 |
| field_assign | 271 / **6** | 271 / **6** | 271 / **6** | 6 |
| return_sret | 356 / **6** | 356 / **6** | 356 / **6** | 6 |
| classic | 371 / **0** | 371 / **0** | 371 / **0** | 0 |
| exact | 523 / **0** | 523 / **0** | 523 / **0** | 0 |
| fwd | 551 / **0** | 551 / **0** | 551 / **0** | 0 |
| local | 363 / **0** | 363 / **0** | 363 / **0** | 0 |
| multi | 523 / **0** | 523 / **0** | 523 / **0** | 0 |
| one | 455 / **0** | 455 / **0** | 455 / **0** | 0 |

## Tip-alone vs dig-plant verdict
Soft Cap Prefer **tip alone lags** dig plant greens:
- call_arg / call_arg_direct: tip alone run=1 (SysV `0x10/18/20(%rbp)`) vs dig plant run=0 (RCX byref `mov %rcx,%rax`)
- nested_let / n_no_assign / block_let / _var_let: tip alone run=1 vs dig plant 09fe run=0

HOLD Soft Cap / nail / tiphead Prefer-M2 9ecd / Cap tip Prefer-M2b 10470224 NOT raised this baseline.
