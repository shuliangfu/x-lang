# F-closure-e-extern（std `-E-extern` archaeology · NO_C_FRONTEND honesty）

> **Status (2026-08-27):** soft `XLANG_F_CLOSURE_FAIL` retired. Product
> binaries are built with `-DXLANG_NO_C_FRONTEND`; `-E-extern` is refused
> with BLD001. The old soft gate swallowed 71/71 `FAIL_XLANGC` as exit0
> (portable false-green / prefer-c dual authority).

## 1. Why this gate exists

Historical F closure scanned every `std/**/mod.x` through
`xlang-c -E-extern` + `cc -c`. That path required the C frontend.

Under Stage12.0.5 prefer pure-asm product default, shipping a soft-green
`-E-extern` batch while every product binary refuses the flag is a
**prefer-c archaeology false authority**.

## 2. Honesty contract

| Check | Hard? | Notes |
|-------|-------|-------|
| Archive DOC + `## Gate` | yes | this file |
| `./xbuild` present; no `compiler/Makefile` | yes | MG |
| Prefer-asm native binary | yes | `xlang_asm` first |
| Product refuses `-E-extern` with BLD001 / NO_C_FRONTEND | yes | representative `std/cli/mod.x` |
| Full `-E-extern`+`cc -c` batch | **retired** | cannot green on product |

## Gate

```bash
./tests/run-f-closure-e-extern-gate.sh
# Report: refuse=/mods=/skip=
# Soft XLANG_F_CLOSURE_FAIL retired (die always hard).
# Authority refuse: tests/lib/prefer-asm-e-extern-refuse.sh
```

PLATFORM: SHARED archaeology.
