# YY164 SoftCap CallExpr early-out nail (non-@56d014)

## Capless CapFN SoftCap SoftCap early-out
- CapFN flag [rbp+0x470] set when kind∈{0x33,0x34} AND type CapFN(0x12) or (9∧type-kind==2)
- SoftCap mode [rbp+0x4b0]==1 → CapFN SoftCap helpers @530b50/@530a78 → **@576b71 mov eax,0; jmp exit**
- Skips CALL kind=3 @577c24 / h_emit @567a30 — no imm→rdx+call mk
- Isol-ZZ cave kind==3 fallthrough **falsified**: CapFN CallExpr kinds are **0x33/0x34**, not 3

## SoftCap twin SoftMega SoftCap-full
- SoftCap-full has NO CE/h_emit/E8enc — only @525544×3
- kind!=3 → helpers then continue without x86 call emit
- YY SoftCap-full→Capless hits Capless CapFN SoftCap early-out → same thin emit

## Isol-AAA plant
- SoftMega @59ab11 SoftCap-full→Capless
- Capless @576b71 → jmp @577c37 (CALL body after kind check; CapFN CallExpr skips kind==3)
