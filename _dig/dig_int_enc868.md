# DIG Capless-internal USER enc (`frame_sz` → `enc_prologue`)

**2026-10-30 ~15:54 CST (Asia/Shanghai)** · Base Isol alt_frame2 `9378df517f96`. Short timeout INT3 (≤5s/site, budget≤85s). Ban tip`@121278` / join/epi / LIVE SoftCap transplant / arg-loop / mega.

## Question

Inside Capless USER emit: who selects `frame_sz`, who calls / implements `enc_prologue`, and how SoftCap lit could get `0x868` instead of thin `0x68`/`0x1b8`?

## DIG nails

### 1) Capless-on-path helpers (lit) ≠ SoftCap `0x868` writer

| site | role | INT3 lit |
|---|---|---|
| CapFN `@5752bc` | CapFN | **HIT** (via `last@57b98c` `@57bb30`; Capless direct CapFN E8s `@576a98/@5775a7/@577b78` = **OK** off-path for lit) |
| CapFN→`@55d948` | returns `0x40` or `8` | **HIT** — slot/align class, **≠** USER `frame_sz` |
| `last@57b98c` | Capless finalize | **HIT** |
| `pre_last@567a30` | h_emit-ish | **HIT** (later reprobe AV class) |
| `clc68@55ab88` | stub `eax=0`; HOST `sub rsp,0x68` | **HIT** — **not** USER emit |
| `post_args@57464c` | | AV / Capless E8 OK |
| SoftCap-band HOST `@50f8a0` `sub rsp,0x868` | callers `@5228b3…` | **AV** off-path |

Capless body still has **`mov eax,0x68/0x1b8/0x868` = []**. Capless-band / enc-band `mov eax,0x68` (`@553c15…`) and `0x1b8` (`@512d28/@547a3e`): INT3 **OK/AV — none HIT**.

### 2) Real USER `enc_prologue` template builder = `@512f0c` (Isol-native)

FN `@512f0c` builds stack templates in locals:

| local | bytes written | meaning |
|---|---|---|
| `[rbp-0x28]` | `48 89 E5` | `mov rbp,rsp` |
| `[rbp-0x40]` | `48 81 EC` + **`00 00 00 00`** | `sub rsp,imm32` with **zero** size placeholder |

⇒ `frame_sz` is **not** baked as SoftCap `0x868` here; size is filled **later** (emit path). **E8 callers of `@512f0c` = 0** this Isol; body INT3 at `48/81/EC` sites **OK/AV** — template builder **not** on lit for alt_frame2 (thin frames still appear via other emit).

### 3) On-path byte emitters (lit) = `emit_u8@511018` / `emit_u32@5110f8`

| site | INT3 lit |
|---|---|
| `emit_u8@511018` | **HIT** |
| `emit_u32@5110f8` | **HIT** |
| `@5182ac` family (`mov edx,0x48` → emit) | earlier **HIT** / reprobe AV |

These are generic enc writers Capless lit **does** use. No Capless-band `mov *,0xEC81` opcode-imm builders. `enc_prologue` / `compute_frame_size` string LEAs remain name-match visitors (`@22ce08/@22d391`), not emit.

### 4) SoftCap lit `0x868` vs thin

| claim | result |
|---|---|
| Capless-internal imm selects `0x868` | **Falsified** — band `mov*,0x868` n=0; HOST `0x868` templates off-path |
| Patch `@512d28` `mov eax,0x1b8`→`0x868` (`int_enc868`) | **Red** — site INT3 **OK** (off-path); plant lit/fwd/local **AV/GS/AV** |
| CapFN / last / clc68 raise USER frame to SoftCap | **Falsified** — CapFN helper sizes `0x40/8`; clc68 stub |

Baseline lit still OK sha `332eed5f048b` — USER **`0x68`+`0x1b8`**, **`0x868=False`**.

## Wiring gap (conclusion)

Capless-internal USER enc for lit = **`emit_u8` / `emit_u32` on-path**; prologue **template** `@512f0c` exists (`48 81 EC` + zero imm) but is **unwired / off-path** on alt_frame2 (0 E8 callers). **`frame_sz` is not an on-path Capless/enc-band imm** — no HIT `mov eax,0x68/0x1b8` to retarget to SoftCap `0x868`. SoftCap `0x868` remains HOST SoftCap templates (banned tip`@121278` path), never fed into Capless lit enc arg.

## Plant

**Not isolatable this beat** without banned moves:

- `int_enc868` (`@512d28` `0x1b8`→`0x868`): off-path + AV/GS.
- No on-path `frame_sz` imm INT3 HIT.
- Ban tip`@121278` / join/epi / LIVE / mega / arg-loop.

No new Isol host shipped (plant host removed from cave).

## Next single-point (still ban tip`@121278`/join/epi/LIVE/mega)

Who **fills** `sub rsp,imm32` size on lit: on-path **`emit_u32(frame_sz)`** caller (or write into `48 81 EC` template +3) that currently supplies `0x68`/`0x1b8` — map edx/r8d feeders into `emit_u32@5110f8` from Capless lit, then Isol-native SoftCap-sized feed if a single site HITs. Short timeout.
