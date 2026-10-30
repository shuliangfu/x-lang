# DIG on-path `emit_u32` feeder / real USER `sub rsp` path

**2026-10-30 ~16:00 CST (Asia/Shanghai)** · Base Isol alt_frame2 `9378df517f96`. Short timeout INT3 (≤5s/site, budget≤85s). Ban tip`@121278` / join/epi / LIVE SoftCap transplant / arg-loop / mega.

## Question

Who feeds `frame_sz` (`0x68` / `0x1b8`) into on-path `emit_u32@5110f8`, and can that feed be retargeted / bypassed to SoftCap `0x868`?

## DIG nails

### 1) Frontier falsified: `emit_u32` ≠ USER `frame_sz` writer

| site | INT3 lit | role |
|---|---|---|
| `emit_u32@5110f8` | **HIT** | generic u32 emit (mov-imm etc.) — **not** `sub rsp` size |
| `emit_u8@511018` | **HIT** | generic u8 emit |
| Capless/enc-band `mov eax,0x68/0x1b8` near emit_u32 | **none HIT** | no plantable imm feeder into emit_u32 for frame |
| wrappers `@518098/@5182ac` (`mov edx,0x48` etc.) | earlier HIT / AV | opcode bytes (`48`/`81`), **not** frame_sz |

Baseline lit still OK sha `332eed5f048b` — USER `48 81 EC` **`0x68`×1 + `0x1b8`×1**, **`0x868=False`**.

### 2) Real USER `enc_prologue` (on-path) = `@50f3e0` (**HIT**)

FN `@50f3e0` (edx = `frame_sz` arg):

1. emit `48 89 E5` via `emit_raw4` (len 3)
2. pack `0xEC8148` at `[rbp-0x12]` + size bytes from **aligned** edx
3. `emit_raw4@511094` (**HIT**) len=7 → USER `48 81 EC xx xx xx xx`

Template builder `@512f0c` remains **off-path** (0 E8 callers) — confirmed prior DIG.

### 3) Dispatcher into prol = `@523600` (**HIT**)

FN `@523600`(rcx=emitter, edx=`frame_sz`, r8d=mode):

| mode | call |
|---|---|
| 1 | `@4e95c0`(edx=sz) |
| 2 | `@4e9910`(edx=sz) |
| else | **`@50f3e0`(edx=sz)** ← lit path (`e8@52364b` **HIT**) |

`e8@5236c1` → prol = **OK** (off-path for lit). Body has **no** `mov *,0x68/0x1b8` — size is **arg** `[rbp+0x18]`.

E8 callers of `@523600`: `0x20ee89`, `0x20f08a`, `0x238694`, `0x5b0d49`.

### 4) Size imm → prol window

`mov 0x68/0x1b8` within 0x100 of E8→`@50f3e0`: **[]**. No on-path imm size plant site.

## Plant

**Not isolatable this beat** (`feed_u32` / `fsz_868`):

- No HIT on-path `mov imm,0x68/0x1b8` feeding emit_u32 or prol.
- `frame_sz` enters `@523600` / `@50f3e0` as **edx arg** (computed upstream).
- Ban tip`@121278` / join/epi / LIVE / mega / arg-loop.

No new Isol host shipped (probe hosts removed from cave).

## Next single-point (still ban tip`@121278`/join/epi/LIVE/mega)

Who **calls `@523600`** with edx=`0x68`/`0x1b8` (or computes that edx) — map E8 callers `@20ee89/@20f08a/@238694/@5b0d49` + size compute; Isol-native SoftCap-sized feed if a single imm/HIT site exists. Short timeout.
