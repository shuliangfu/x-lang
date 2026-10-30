# DIG `fwd_46_967_sret_persist` (10.60 SoftCap)

**Date:** 2026-10-30 ~19:50 CST (Asia/Shanghai)
**Goal:** Fold Isol `host_967_s25` (rcx=sret / four-gate green) into a **reproducible** Isol/WORK form.
**PROD SoftCap `7a2cf5da581a` / pin `ecdb5cc1e`:** untouched.
**Gate green ≠ PROD bump / ≠ close knife.**

## Persist landing

| Item | Value |
|---|---|
| Isol host | `host_967_s25.exe` sha12 `e53841ce0e24` |
| Isol WORK alias | `xlang_isol1060_967_s25.exe` (same bytes) |
| BASE | `host_967_sret_tr460.exe` sha12 `336f7fe218be` |
| Cave | `C:/xlang_tmp/p1060/cave/` |
| Rebuild+cold | `_dig/build_isol_967_s25.py` |
| Cold-only | `_dig/gate_967_s25_cold.py` |
| Winner DIG | `_dig/dig_fwd_46_967_sret_25.py` / `.log` |

## Plant (byte-identical to dig25)

1. **Capless USER16** `@57ba3b` / len `@57ba94`:
   `sub rsp,0x20; mov rax,[rbp-0x10]; inc rax; mov rdx,rax` (x+1→rdx).
2. **Fixup body** @INT3 cave `0x559821` (589B), trampoline `jmp @57bbae → cave → @57bd4e`:
   - **c1→c2**: `4889c1e8` → `4889c2e8` (BinaryExpr→rdx)
   - **let_sret**: `lea [rbp-0x38]` → `mov [rbp-0x50]` (caller sret as rcx)
   - **main_imm9**: after `lea[rbp-0x28]+mov rcx+sub20`, replace x+1 with `mov eax,9; mov rdx,rax; nop; nop`

## Expected cold gate

| src | USER sha12 | run |
|---|---|---|
| p_ret_lit.x | `5c6778769c3c` | 0 |
| p_ret_fwd.x | `a99121ae7a80` | 0 |
| p_ret_local.x | `36d26fcc9657` | 0 |
| _var_let.x | `d16c78ade1f2` | 0 |

## How to re-run (Win cave)

```text
# from Mac repo:
scp _dig/build_isol_967_s25.py windows-server:C:/xlang_tmp/p1060/cave/
ssh windows-server 'python C:/xlang_tmp/p1060/cave/build_isol_967_s25.py'
# or cold-only:
scp _dig/gate_967_s25_cold.py windows-server:C:/xlang_tmp/p1060/cave/
ssh windows-server 'python C:/xlang_tmp/p1060/cave/gate_967_s25_cold.py'
```

## Not done / bans

- **Do not** bump PROD SoftCap / pin.
- hollow_only / skip_1a0: control only — not close.
- Darwin Cap soft / Ubuntu tip-cold: only after persist stays green; report separately.
- No LIVE SoftCap transplant / mega / letter-pile / arg-loop / tip@121278.

## Next single point (after persist green)

- Source-level SoftCap change that emits the same USER shape without Isol PE plant,
  **or** Dig LIVE SoftCap semantic parity check on Isol path — still **no PROD bump** until LIVE SoftCap semantics green.
