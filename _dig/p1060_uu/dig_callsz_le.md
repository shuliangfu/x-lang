# DIG SoftCap twin callsz_le — force ≤0x10 helper chain falsified

Date: 2026-10-30 ~12:45 CST Asia/Shanghai
Tip at plant: `50e9001d2` (dig-only; no product code)
Isol-TT baseline sha12 `1f836615e0fc`
Isol-callsz_le sha12 **`96b155a04a14`**
PROD SoftCap `7a2cf5da581a` / nail ecdb5cc1e **untouched**

## DIG: SoftCap twin size gate

Isol `@1d9b91` / LIVE `@50786` **isomorphic**:
```
cmp [rbp-4],0x10; jle +0x126 → ≤16 entry
```

| path | Isol | LIVE |
|---|---|---|
| before gate | SoftMega `@57ef78` + Capless + helpers + encode | SoftCap `@289dcb` + Capless + helpers + encode |
| ≤16 | SoftMega + Capless + `@521f10`/`@521d78`/`@524944`/`@1cd1e5` | SoftCap + Capless + isomorphic helpers |
| >16 | SoftMega + Capless + early `mov eax,0` | SoftCap + Capless + early `mov eax,0` |

LIVE call-mk for `p_ret_*` is written **inside** SoftCap `@289dcb` (both paths call it). Isol maps that slot to SoftMega trampoline — no `imm→rdx + E8` into user emit. Post helpers do not emit `ba0a` / call-mk for large CallExpr.

## Plant Isol-callsz_le (semantic short name; ban letter pile)

| Site | Patch |
|---|---|
| SoftCap twin `@1d9b91` `cmp [rbp-4],0x10; jle ≤16` (`837dfc100f8e26010000`) | keep cmp; jle→jmp `@1d9cc1` (`837dfc10e92701000090`) |

Win SoftCap cave `out_callsz_le/`:

| case | crc | emit | n868/n878 | n1b8 | ba0a | run |
|---|---|---|---|---|---|---|
| p_ret_lit | 0 | `5b173cef1205`＝TT | **0/0** | 1 | 0 | **exit 1** |
| p_ret_fwd | 0 | `546a4c6d02df`＝TT | 0/0 | 1 | 0 | exit 1 |
| p_ret_local | 0 | `018c76562e9e`＝TT | 0/0 | 1 | 0 | exit 1 |

⇒ forcing ≤16 SoftCap/SoftMega + post helpers **still** does not install SoftCap lit call-mk. SoftMega≠LIVE SoftCap `@289dcb` remains the hard writer gap.

## Gates
- Win SoftCap Isol-callsz_le `p_ret_*`: compile green / **run exit 1** (falsified)
- Darwin tip Cap soft `./compiler/xlang` sha12 `0c0a41335a35`: p_ret_* **r=0** ✅
- Ubuntu tip `compiler/bootstrap_xlangc` sha12 `ea9ddf4eb937`: p_ret_* **r=0** ✅；tip-cold pure-ld prior break noted
- PROD SoftCap / nail **untouched**

## Next single-point (no letter pile)
1. DIG whether Isol already has a real imm→rdx+E8 emit helper (ban LIVE SoftCap transplant); after SoftMega/SoftCap-full success, single-site call that helper — or rewrite >16 early `mov eax,0` to fall into it.
2. Or after glue leftover `call_ret_sz>16` sret lea + emit_expr success, single-site finish call-mk using an Isol-native encoder.
3. Ban: mega / whole-tree / cave letter pile / CloudAgent / ungreen approval / PROD lift.
