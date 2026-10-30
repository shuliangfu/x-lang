# DIG SoftCap `@523600` callers / edx frame_sz compute

**2026-10-30 ~16:05 CST (Asia/Shanghai)** · Base Isol alt_frame2 `9378df517f96`. Short timeout INT3 (≤5s/site, budget≤85s). Ban tip`@121278` / join/epi / LIVE SoftCap transplant / arg-loop / mega.

## Question

Which E8 caller of `@523600` is on-path for lit SoftCap USER emit, and how does edx get thin `0x68`/`0x1b8` vs SoftCap target `0x868`?

## DIG nails

### 1) On-path caller = **`@20f08a` HIT** (only)

| E8 caller | INT3 lit | edx into `@523600` | role |
|---|---|---|---|
| `@20ee89` | **AV** | `edx=0` (mode=`[rbp+0x7fc]`) | size-zero early path |
| **`@20f08a`** | **HIT** | **`edx=[rbp+0x828]`** (mode=`[rbp+0x7fc]`) | **REAL USER frame_sz** |
| `@238694` | **AV** | `edx=0` (mode=`[rbp+0xd4]`) | size-zero sibling FN |
| `@5b0d49` | **OK** (off-path) | `rdx=0x10` | other/small use |

Chain confirmed HIT: store828`@20efaf` → load828`@20f077` → call`@20f08a` → cfn`@523600` → prol`@50f3e0`; helper`@24b49d` + add40`@24b9c7` HIT.

### 2) edx size compute (no on-path imm `0x68`/`0x1b8`)

```
[rbp+0x828] := 0                    @20ef5a
if [rbp+0x7d8] != 0:
  eax := @24b49d(...)               ; frame_sz helper
  [rbp+0x828] := eax                @20efaf  HIT
edx := [rbp+0x828]                  @20f077  HIT
call @523600                        @20f08a  HIT
```

Helper `@24b49d` final return:

```
[rbp+0xfc] := sum(locals/spills/align + [rbp+0xf8])
eax := [rbp+0xfc] + 0x40            @24b9c7  HIT
; early-exit: eax := 0x40           @24b67a
```

⇒ thin `0x68` = computed base `0x28` + `0x40`; `0x1b8` = base `0x178` + `0x40`. **No** plantable imm `0x68`/`0x1b8`/`0x868` on this path — size is **sum+0x40**.

Nearby `@20f026..@20f06b` (`@298ab2`/`@298a9f`) bumps `[rbp+0x1c4]` stack cursor for modes 0/1 when >`0x10` — **not** the USER `frame_sz` into 828.

### 3) Baseline

lit OK sha `332eed5f048b` — USER `0x68`×1 + `0x1b8`×1, **`0x868=False`**.

## Plant

Tried semantic **`edx_868`**: `@20f077` `mov edx,[rbp+0x828]` → `mov edx,0x868; nop` (sha12 `21827e406f6e`).

| probe | result |
|---|---|
| p_ret_lit | **AV** |
| p_ret_fwd | **GS** |
| p_ret_local | **AV** |

**Not isolatable this beat** — forcing SoftCap-sized edx alone AV/GS (downstream emitter / stack / Capless thin path not ready for `0x868`). Ban tip`@121278` / join/epi / LIVE / mega / arg-loop. Probe hosts removed.

## Next single-point (still ban tip`@121278`/join/epi/LIVE/mega)

Why `@24b49d` summands yield thin base `0x28`/`0x178` (→`0x68`/`0x1b8`) instead of SoftCap base `0x828` (→`0x868`) — DIG feeders of `[rbp+0xfc]` parts (`@2a2ef3`/`@27fbc5`/`@2a3077`/`@27ef44` / `@2a3237`) under lit; or what must accompany edx=`0x868` to avoid AV/GS. Short timeout.
