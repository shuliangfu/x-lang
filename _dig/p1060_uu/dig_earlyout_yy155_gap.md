# YY155 SoftCap CallExpr early-out true gap (non-@56d014)

## Nail
- SoftCap twin `@57ef78` always SoftCap flag=1 → SoftMega `@59b170`
- SoftMega `@59b911`/`@59b4e0` → bridge `@59aa8c`
- Bridge SoftCap≠0 `@59ab11` → **SoftCap-full `@57effc`** (sole caller)
- SoftCap-full: **no** CALL kind=3, **no** CE `@522c0c`, **no** h_emit `@567a30`, **no** CapFN
- SoftCap-full 1× `@56d014` (println/spill; XX falsified) — not lit call-mk
- SoftMega >16 `@59b6a9` → ARM64 egg `@57426c` (sole caller), never Isol x86 E8 `@514434`
- Capless `@57656c` **has** CALL kind=3 `@577c24` → helpers → h_emit

## USER delta (reconfirmed)
- Isol-TT: `lea→rcx` then field-read (no imm→rdx / no call mk); frames thin `0x1b8`
- LIVE: `lea→rcx; mov edx,0xa; call mk@0x1490`; frames `0x868`/`0x878`

## Plant Isol-YY
- Single E8 retarget `@59ab11`: SoftCap-full → Capless
- Builder `_dig/build_isol_yy.py`
