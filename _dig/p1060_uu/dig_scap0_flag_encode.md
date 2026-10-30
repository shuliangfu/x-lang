# DIG SoftCap flag / encode + Isol-scap0 plant — both candidates isomorphic; SoftCap=0 falsified

Date: 2026-10-30 ~12:35 CST Asia/Shanghai
Tip at plant: `fd99fd5b6` (dig-only; no product code)
Isol-TT baseline sha12 `1f836615e0fc`
Isol-scap0 sha12 **`a147a2410f84`**
PROD SoftCap `7a2cf5da581a` / nail ecdb5cc1e **untouched**

## DIG: who writes LIVE SoftCap lit call-mk?

### Candidate 1 — emit_expr SoftCap flag Isol `@1cf074` / LIVE `@464cb`
- SoftCap flag `test [rip+flag]; jne SoftCap≠0` **isomorphic**.
- SoftCap≠0 → kind dispatch → SoftCap twin for kinds `0x30|0x31`.
- SoftCap=0 → SoftCap=0 alt `@272bde` / LIVE `@ead6d` (kind `0x1a` special; else `@26ffcc`).
- Flag itself does **not** emit `imm→rdx + call mk`.

### Candidate 2 — CALL post-Capless encode Isol `@1e20b1` / LIVE `@59ad9`
- Encode loop **isomorphic**.
- Called only on SoftCap twin **type==0xa** path AFTER SoftCap/Capless success (size bump + helpers then encode).
- SoftCap twin `cmp [rbp-4],0x10`:
  - **≤0x10** → SoftCap/Capless then post helpers (`@521f10`/`@521d78`/`@524944`/`@1cd1e5`).
  - **>0x10** (p_ret_* large sret) → sret setup + SoftCap/Capless then **`mov eax,0; ret`** — **NO encode**.
- Therefore encode is **not** the lit SoftCap call-mk writer for `p_ret_*`.

### True LIVE writer
- SoftCap twin kind==`0x31` → LIVE SoftCap **`@289dcb`** (frame `0x1070`) writes user `lea→rcx; mov edx,imm; call mk`.
- Isol same slot → SoftMega trampoline `@57ef78` → SoftCap-full `@57effc` (YY155: no CALL/CE/h_emit) — success after glue sret lea only.
- Capless (kind≠0x31) not SoftCap CallExpr call-mk authority (AAA/DDD; LIVE Capless no kind=0x30).

## Plant Isol-scap0 (semantic short name; ban letter pile)

| Site | Patch |
|---|---|
| SoftCap flag `@1cf0a6` `test eax,eax; jne SoftCap≠0` (`85c07533`) | nop jne → `85c09090` → always SoftCap=0 alt |

Win SoftCap cave `out_scap0/`:

| case | crc | emit | n868/n878 | n1b8 | ba0a | run |
|---|---|---|---|---|---|---|
| p_ret_lit | 0 | `5b173cef1205`＝TT | **0/0** | 1 | 0 | **exit 1** |
| p_ret_fwd | 0 | `546a4c6d02df`＝TT | 0/0 | 1 | 0 | exit 1 |
| p_ret_local | 0 | `018c76562e9e`＝TT | 0/0 | 1 | 0 | exit 1 |

⇒ SoftCap=0 alt **also** does not install SoftCap lit call-mk. SoftCap≠0 SoftCap twin→SoftMega gap remains the hard blocker (LIVE SoftCap body absent on Isol).

## Gates
- Win SoftCap Isol-scap0 `p_ret_*`: compile green / **run exit 1** (falsified)
- Darwin tip Cap soft `./compiler/xlang`: p_ret_* **r=0** ✅
- Ubuntu tip `compiler/bootstrap_xlangc` sha12 `ea9ddf4eb937`: p_ret_* **r=0** ✅；tip-cold pure-ld prior break noted
- PROD SoftCap / nail **untouched**

## Next single-point (no letter pile)
Isol SoftCap twin kind==0x31 SoftMega trampoline ≠ LIVE SoftCap `@289dcb`. Options still open without mega/whole-tree:
1. Force SoftCap twin `cmp [rbp-4],0x10` always ≤0x10 path (`callsz_le`) — SoftCap then post helpers; DIG whether helpers write call-mk for large CallExpr.
2. After >16 SoftCap success, fall into ≤0x10 post-helper chain instead of early `mov eax,0; ret`.
3. SoftCap-full early success after glue sret — inject Isol Capless CALL finish that emits imm→rdx+E8 (only if a real Isol helper writes that pattern; ban LIVE SoftCap transplant).

Ban: mega / whole-tree / cave letter pile / CloudAgent / ungreen approval / PROD lift.

## Follow-up 2026-10-30 ~12:45 — callsz_le ≤16 helper chain falsified

See `dig_callsz_le.md`. SoftCap twin size gate Isol@1d9b91/LIVE@50786 isomorphic. Plant `callsz_le` (jle→jmp ≤16 @1d9cc1) emit＝TT / exit 1 / ba0a=0. Post helpers do not write call-mk; SoftMega≠LIVE SoftCap@289dcb remains.
