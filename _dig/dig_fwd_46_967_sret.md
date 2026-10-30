# DIG `fwd_46_967_sret` (10.60 SoftCap)

**Date:** 2026-10-30 ~19:42 CST (Asia/Shanghai)
**Result:** GREEN (Isol) — non-hollow USER run-OK on lit/fwd/local/let.
**Winner host:** `host_967_s25.exe` sha12 `e53841ce0e24` (cave)
**PROD SoftCap `7a2cf5da581a` / pin `ecdb5cc1e`:** untouched.
**hollow_only / skip_1a0:** control only — not close.

## Gate
| src | USER sha12 | run |
|---|---|---|
| p_ret_lit.x | `5c6778769c3c` | 0 |
| p_ret_fwd.x | `a99121ae7a80` | 0 |
| p_ret_local.x | `36d26fcc9657` | 0 |
| _var_let.x | `d16c78ade1f2` | 0 |

## Root cause (call@46a967 / call-mk@14f8)
SoftCap Capless plant for return-CallExpr was emitting fw→mk with rcx=value (or wrong sret). Fix is Capless USER16 plant + post-plant fixup scans:

1. **Capless plant** `@57ba3b` / len `@57ba94`: `sub rsp,0x20; mov rax,[rbp-0x10]; inc rax; mov rdx,rax` (x+1→rdx). Always plant when Capless fires.
2. **c1→c2** scan: `4889c1 e8` → `4889c2 e8` so BinaryExpr result goes to rdx (return-CallExpr path).
3. **let_sret** scan: `lea rax,[rbp-0x38]` → `mov rax,[rbp-0x50]` so let-init fw passes **caller sret** as rcx (not &local v).
4. **main_imm9** scan: after `lea [rbp-0x28]; mov rcx,rax; sub rsp,0x20`, replace Capless-planted x+1 with `mov eax,9; mov rdx,rax; nop; nop` so main→fw gets literal 9 (fw then mk(x+1)=10).

## Why window trampoline
In-place fixup window `57bbae..57bd4e` = 416B; full 3-scan body ≈589B. dig25: `jmp` trampoline `@57bbae` → INT3 cave `@0x559821` (4967B), body there, `jmp` back `@57bd4e`.

## Intermediate proofs
- **s19a** (imm9 plant + c1toc2): lit/fwd/local run=0; let exit1 (no caller sret / no x+1 on let).
- **s20b** (x+1 + let_sret + c1toc2): fw let ABI OK; main Capless reads garbage → fwd/let exit1.
- **dig21b** (s20b + USER post-patch main_imm9): all four run=0 (semantic proof; not Isol-resident).
- **dig22–24**: trampoline/rel8/pattern bugs (ILLEGAL_INSN / INT3 / hang / miss).
- **dig25**: Isol-resident all-green.

## USER shape (fwd / let)
- fwd main: `lea sret; mov rcx; sub 20; mov eax,9; mov rdx,rax; call fw` — fw→mk gets rcx=sret, rdx=x+1.
- let fw: `mov rcx,[rbp-0x50]` (caller sret); `mov rax,[rbp-0x10]; inc; mov rdx,rax; call mk`.

## Artifacts
- Winner: `_dig/dig_fwd_46_967_sret_25.py` / `.log` → cave `host_967_s25.exe`
- Trail: `_dig/dig_fwd_46_967_sret_{17,17b_probe,18,19,20,21,21b,22,22b,23,24}.py` + logs
- Intermediate hosts (cave): `host_967_s19a.exe`, `host_967_s20b.exe`

## Next
- Fold Isol s25 plant into a durable SoftCap source change (or keep as Isol recipe) before any PROD/pin bump.
- Do **not** bump PROD / pin yet — Isol green ≠ LIVE SoftCap transplant.
- hollow / skip_1a0 remain controls only.

## Persist (fwd_46_967_sret_persist)

- Rebuild+cold: `_dig/build_isol_967_s25.py` → host sha `e53841ce0e24` (byte-identical rebuild from BASE `336f7fe218be`)
- WORK alias: `xlang_isol1060_967_s25.exe` (same bytes; cave)
- Cold-only: `_dig/gate_967_s25_cold.py`
- Persist dig: `_dig/dig_fwd_46_967_sret_persist.md`
- Cold gate (rebuild + cold-only): lit/fwd/local/let **all run=0** USER shas match dig25
- **PROD SoftCap / pin untouched** — gate green ≠ PROD bump / ≠ close knife
- Darwin Cap soft / Ubuntu tip-cold: defer until persist stays green
