# Isol-AAA / Isol-DDD Win plant — Capless CapFN plants falsified; next single-point

Date: 2026-10-30 ~12:22 CST Asia/Shanghai
Tip at plant: `38f5d2045` (unchanged; dig-only)
Isol-TT baseline sha12 `1f836615e0fc`
PROD SoftCap `7a2cf5da581a` / nail ecdb5cc1e **untouched**

## Plants run (Win SoftCap cave)

| Isol | sha12 | plant | lit emit | n868/n878 | run |
|---|---|---|---|---|---|
| AAA | `9326cde5b6af` | YY SoftMega `@59ab11`→Capless + CapFN SoftCap `@576b71`→CALL body `@577c37` | `5b173cef1205`＝TT | 0/0 | **exit 1** |
| DDD | `a9e70ef1595b` | CapFN SoftCap `@576b71` + CapFN=0 `@576b7b` → h_emit `@578184` | `5b173cef1205`＝TT | 0/0 | **exit 1** |

fwd/local likewise emit＝TT counterparts; frames thin (`n1b8=1`).

## YY155 / YY164 carry-forward (still hold)

- SoftCap twin→SoftMega→bridge `@59ab11`→SoftCap-full `@57effc`: **no** CALL kind=3 / CE / h_emit (YY155).
- Capless CapFN SoftCap SoftCap `@576b71` `mov eax,0; jmp exit` — CapFN kinds ∈{0x33,0x34} not kind=3; Isol-ZZ kind==3 fallthrough **falsified** (YY164).
- SoftCap-full→Capless (YY) hits CapFN SoftCap early-out; AAA forces that early-out into CALL body `@577c37` — still emit＝TT (CALL body is **VAR** handler after kind==3, wrong for CallExpr 48).
- DDD force→h_emit: still emit＝TT (Capless never on SoftCap CallExpr call-mk authority for lit).

## Capless is not LIVE SoftCap CallExpr call-mk authority

LIVE Capless `@2967b4` kind imm scan = Isol Capless: 0x33/0x34/0x2c/0x3 only — **no kind=0x30**. CapFN SoftCap early-out **identical** on LIVE (`mov eax,0; jmp exit`). Tip CallExpr kind=48 → CALL handler → Capless (kind≠0x31 SoftCap twin). Therefore Capless CapFN / h_emit / VAR-body plants cannot install LIVE lit `imm→rdx + call mk`.

## USER delta (reconfirmed)

```
Isol/TT @1504: lea→rcx; then field-read          frames 0x68 / 0x1b8   emit 5b173cef1205
LIVE     @1504: lea→rcx; mov eax,0xa; … mov rdx; call mk@1490
                                                 frames 0x868 / 0x878  emit dbaab1c7ce70
```

## Next true single-point (no new isol letter)

After leftover Windows `glue_emit_struct_type_let_init` CALL>16 (`runtime_pipeline_abi.windows_link_stubs.c`: lea_rbp→rax, mov_rax→arg0, sret_shift=1, `pipeline_asm_emit_expr_elf_c`), Isol stops at sret lea; LIVE continues imm→rdx+call.

Capless early-out alone cannot explain LIVE green (LIVE Capless same). Dig **one** of:

1. emit_expr SoftCap flag/fast-path at dispatcher `@1cf074` (Isol) / `@464cb` (LIVE): `test [rip+flag]; je → alt` — SoftCap may bypass kind→Capless.
2. CALL handler post-Capless encode `@1e20b1` (Isol) vs `@59ad9` (LIVE) and the `cmp [rbp-4],0x10` / `cmp [rbp-0x20],0xa` gate that selects thin vs call-mk path.
3. Confirm whether Isol SoftCap CallExpr even enters CALL handler after glue sret lea, or returns success with zero call bytes.

Plant only that single site on Isol-TT. **Ban** mega / whole-tree / new cave letter pile.
