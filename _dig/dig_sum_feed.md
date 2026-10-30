# DIG SoftCap `@24b49d` summand feeders / thin base vs SoftCap `0x828`

**2026-10-30 ~16:10 CST (Asia/Shanghai)** · Base Isol alt_frame2 `9378df517f96`. Short timeout INT3 (≤5s/site, budget≤85s). Ban tip`@121278` / join/epi / LIVE SoftCap transplant / arg-loop / mega.

## Question

Why `@24b49d` summands yield thin base `0x28`/`0x178` (→ frame `0x68`/`0x1b8`) instead of SoftCap base `0x828` (→ `0x868`)? Who writes the parts?

## DIG nails

### 1) Sum formula (static + on-path HIT)

```
[rbp-0x44] := 0x10 … mutated by @2a3237          HIT call@24b88c / fn
[rbp+0xf0] := @2a2ef3(fn_obj, mode)              HIT call@24b8a1 / fn  (locals-ish)
[rbp+0xec] := @27fbc5(fn_obj, mode)              HIT call@24b8bc / fn  (spill/stack pool)
[rbp+0xdc] := @2a3077(fn_obj, mode)              HIT call@24b8e6 / fn
[rbp+0xd8] := @27ef44(fn_obj, mode)              HIT call@24b901 / fn
[rbp+0xfc] := (-44)+f0+dc+d8 ; align-16
[rbp+0xf8] := from ec:
               0                         if ec<=0
               ec+0x100                  if 0<ec<=0x3ff
               CLAMP 0x800               if ec>0x3ff && f8<=0x7ff
fc += f8
eax := fc + 0x40                         @24b9c7 HIT
```

Caller of helper on USER path: E8`@20efaa` → store`[rbp+0x828]` `@20efaf` (prior DIG). Sibling E8`@5102a5` other.

### 2) Thin vs SoftCap delta = **f8 clamp `0x800`**

| | base (`fc`) | +`0x40` frame |
|---|---|---|
| thin main | `0x28` | `0x68` |
| thin other | `0x178` | `0x1b8` |
| SoftCap | `0x828` | `0x868` |

**`0x828 − 0x28 = 0x800`** ≡ the `mov [rbp+0xf8],0x800` clamp at `@24b998`.

INT3 `@24b998` clamp under lit → **OK (off-path)**. Lit never takes SoftCap pad; `ec` from `@27fbc5` stays ≤`0x3ff` (no clamp). **No** on-path imm `0x28`/`0x178`/`0x828` — sizes are pure compute.

### 3) Baseline

lit OK sha `332eed5f048b` — USER `0x68`×1 + `0x1b8`×1, **`0x868=False`**, run_rc=1 (known CallExpr gap).

## Plant

### `f8_800` (`@24b977` cmp/jle → `jmp @24b998`) sha12 `7fb689b4501e`

Force SoftCap spill pad. First pass: lit OK `n868=1`; re-check **AV**/GS — **flaky, not clean Isol**.

### `base_828` (`@24b9c1` `mov eax,[rbp+0xfc]` → `mov eax,0x828; nop`) sha12 `0977d6fbb472`

| probe | compile | emit n868 | run |
|---|---|---|---|
| p_ret_lit | **OK** | **2** | **exit 1** |
| p_ret_fwd | **GS** | — | — |
| p_ret_local | **OK** | **2** | **exit 1** |

⇒ SoftCap-sized USER `sub rsp,0x868` **is** plantable at sum return, but runtime still exit 1 (same as thin baseline) — **frame size alone ≠ CallExpr green**. Prior `edx_868` AV/GS was at load site; forcing inside helper is cleaner but still not Isol-green.

**Not isolatable to green this beat** (bans tip`@121278`/join/epi/LIVE/mega/arg-loop). Probe hosts removed.

## Next single-point (still ban tip`@121278`/join/epi/LIVE/mega)

1. Why lit `@27fbc5` (`ec`) stays small (no natural `0x800` clamp) — what SoftCap/LIVE feeds that Isol Capless path omits; **or**
2. Under `base_828`-sized frame, single-point DIG/call-mk for CallExpr imm→rdx＋E8 (Isol-native helper only) — frame now SoftCap-shaped, remaining gap is call-mk.

Short timeout. PROD SoftCap `7a2cf5da581a` / pin `ecdb5cc1e` untouched.
