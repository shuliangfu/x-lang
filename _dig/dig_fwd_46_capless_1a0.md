# DIG `fwd_46_capless_1a0` (10.60 SoftCap)

**Date:** 2026-10-30 ~19:07 CST (Asia/Shanghai)
**Result:** RED — Capless/Isol 6th/7th supply does **not** yield non-hollow USER run-OK.
**Next single point:** `fwd_46_967_sret`
**PROD SoftCap `7a2cf5da581a` / pin `ecdb5cc1e`:** untouched.

## Gate / baseline
- Isol host `host_cmk0_irdx_sub20.exe` sha `3f43f1609d70`
- skip_1a0_calls `79f39a84ead4` (gate green, USER hollow-shaped) — control only, not close
- hollow_only USER `e411d7260d78` run OK (main→mk direct)
- Capless/Isol 1a0 plants → USER `f4839df16ab1` compile OK / **run GS** (F483)

## Confirmed mechanics
1. Capless `@576746→0x46a4db` writes only 5th `dword [rsp+0x20]` from `[rbp+0x4b0]`; no 6th/7th.
2. Body homes r9d over `[rbp+0x198]`, then reads `[rbp+0x1a0]` / `[rbp+0x1a8]` into `call@46a967→0x469aa4` and `call@46a99d→0x47a492`.
3. Real 46-callers `@46bac7`/`@46bda6` write qword `[rsp+0x20]` + dword `[rsp+0x28]` (no +0x30).
4. Capless `[4b0]` = Capless's own unset 6th incoming (callers of Capless only write +0x20).
5. `469aa4` forwards `[1a0]` as **5th qword** into `4698c0` → type switch `4538f4` / `45411e` / `4694c1`.
6. `4538f4` uses 5th `[rbp+0x30]` as rcx → `call 0x2a7545` (predicate); so 1a0 is an object/cookie, not a raw int.

## USER shape (critical)
| plant | USER sha | fwd run | shape |
|---|---|---|---|
| skip_1a0 / hollow | `e411d7260d78` | OK | main@1567→**mk@1490** (fw folded away) |
| Capless/Isol 1a0 fill | `f4839df16ab1` | **GS** | main@1567→**fw@14f8**; fw@1536→mk@1490 |

f483 `fw@14f8` SoftCap-framed call-mk is **broken**:
- `mov eax,0xa; mov rdx,rax` (imm→rdx / cmk0 path)
- `rcx = x+1` (value), **not** sret dest saved at `[rbp-0x30]`
- → mk called with integer-as-pointer → GS

Many Capless tramp / Isol body fills (copy5, b150/b164/b180, zeros, Capless 6th=[4b0]/r8d/r9, 7th=0, etc.) either AV at compile or land the **same** f483 USER → GS. 1a0 content often does not change USER sha ⇒ emit of broken fw is not fixed by Capless 6th/7th alone.

## Plants (abbrev; see `dig_fwd_46_capless_1a0_{2..11}.log`)
- Capless tramp: 5th/6th/7th variants → mostly AV or f483 GS
- Isol fill `[1a0]` from `[150]`/`[164]`/`[188]`/`[198]d` → AV or f483 GS
- rdx0_967 / r8z_967 / rest jejne alone → still reach 99d / GS
- twin vs Isol body: only `eb→74`@46a82b + `eb→75`@46a90c; twin Capless same incomplete args
- Round-10 idx* Capless small indices → fwd=GS compile

## Verdict
`fwd_46_capless_1a0` **closed red**: Capless-side 6th/7th / Isol `[1a0]` supply cannot get non-hollow run-OK. The smash after enabling 967 is **SoftCap fw call-mk sret** (rcx=value not dest).

## Next (one point)
- **`fwd_46_967_sret`**: DIG/fix SoftCap emit of fw→mk so rcx=sret dest (keep cmk0 imm→rdx for lit), such that USER with 967 path runs OK and is not hollow-shaped.
- Do **not** treat skip_1a0 / hollow as close; do **not** bump PROD / pin until semantic green.

## Artifacts
- Scripts: `_dig/dig_fwd_46_capless_1a0{,_2.._11}.py`
- Logs: `_dig/dig_fwd_46_capless_1a0_{2..11}.log` (Win cave mirrors)
- Ban list unchanged; no LIVE SoftCap transplant; no Darwin/Ubuntu this beat.
