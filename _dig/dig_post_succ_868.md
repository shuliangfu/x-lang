# DIG Capless post-success → SoftCap USER `frame_sz` / `enc_prologue(0x868)`

**2026-10-30 ~15:50 CST (Asia/Shanghai)** · Base Isol alt_frame2 `9378df517f96`. Short timeout INT3 (≤5s/site, budget≤85s). Ban tip`@121278` retarget / join/epi / LIVE SoftCap transplant / arg-loop / mega / letter-pile.

## Question

After Capless early-/post-success, how (if at all) does Isol wire SoftCap USER `frame_sz=0x868` or `enc_prologue(0x868)`? Or does kind`0x31` Isol-native SoftMega expose a USER `0x868` writer?

## DIG nails

### 1) Capless post-success lands tip diag — **no** SoftCap USER frame handoff

| site | role | INT3 lit |
|---|---|---|
| Capless `@57656c` | FN entry (`sub rsp,0x500`) | **TIMEOUT** (on-path) |
| Capless epi `@578278` | `add rsp,0x500; pop rbp; ret` | **HIT** |
| Capless pre-epi `@578270` | `mov rcx,rax` → `call @57b98c` | **HIT** |
| tip `@12377c` | `call Capless` | **TIMEOUT** |
| tip `@123787` | `jmp @127212` after store eax | **TIMEOUT** |
| tip `@127212` | Capless-success land (flag/diag only) | **HIT** |

tip after Capless: `mov [rbp+0x1f0],eax; jmp @127212`. Land `@127212` only compares diag flags / optional log `@1c56c0` — **never** calls SoftCap USER `enc_prologue` / never loads `frame_sz=0x868`.

**⇒ Capless post-success → tip is a status sink, not a SoftCap USER frame wire.**

### 2) Capless-miss ≤16 helpers HIT — still not USER `0x868`

Sibling Capless callers (`@126cda` / `@1d9d0e`…): Capless `eax==0` → `@521f10` / `@521d78` / `@524944` (size-dispatch ≤16 helpers). INT3: all three **HIT**. Prior DIG already: these helpers ≠ SoftCap lit call-mk / ≠ USER `0x868` enc.

SoftCap-full early `@5890c8`: **OK** (off-path under tip kind`0x30`).

### 3) kind`0x31` SoftMega — off-path; **0×** USER/`sub rsp,0x868` in SoftMega band

| | |
|---|---|
| tip `@12378c` `cmp kind,0x31` → SoftMega `@57ef78` | INT3 **AV** (not clean Capless land) |
| SoftMega `@57ef78` | INT3 **OK** (lit does not enter SoftMega) |
| SoftMega prol | `sub rsp,0xa8` (thin stub → mega; ban mega) |
| HOST `sub rsp,0x868` | n=29; **near SoftMega band = []**; tip SoftCap band `@121235/@12127d/…`; other `0xecxxx` |

Isol `mov eax,0x868` / `0x878`: **n=0**. SoftMega path is not an Isol-native USER `0x868` writer.

### 4) Capless body emits via CapFN/post_args — **no** SoftCap-sized imm inside Capless

Capless E8 to known helpers (on body): `CapFN@5752bc`, `post_args@57464c`, `clc68@55ab88` (HIT; **HOST** `sub rsp,0x68` stack — not USER emit), `pre_last@567a30`, last `@57b98c` (finalize; INT3 AV class).

Inside Capless FN `+0x1d00`: **`mov eax,0x68/0x1b8/0x868` = []**.

Capless-band `mov eax,0x68` (4 sites `@553c15/@568303/@573d21/@573f60`): INT3 **OK/AV — none HIT**. Capless-band `mov eax,0x1b8`: **OK**.

Baseline lit: OK sha `332eed5f048b` — USER frames **`0x68`+`0x1b8`**, **`0x868=False`**.

`enc_prologue` / `compute_frame_size` string lea xrefs remain name-match visitors (`@22ce08/@22d391`), not Capless emit.

### 5) SoftCap `0x868` templates stay host-internal

Template `81 EC 868` n=29 ≡ HOST SoftCap helper prol band — never selected as Capless USER frame writer after Capless success (confirms lit_wire DIG; tip`@121278` still off-path / tip_scfull crc=0x1).

## Wiring gap (conclusion)

| claim | result |
|---|---|
| Capless post-success → SoftCap USER `frame_sz`/`enc_prologue(0x868)` | **Falsified** — tip`@127212` diag only; Capless already finished thin USER emit |
| kind`0x31` Isol-native USER `0x868` writer | **Falsified** — SoftMega off-path; SoftMega band 0× `0x868` |
| Capless-miss ≤16 as `0x868` wire | **Falsified** — HIT but size-dispatch only |
| On-path `mov eax,0x68` → plant `0x868` | **Unavailable** — Capless-band imm not HIT; Capless body imm n=0 |

**Gap remains kind/site, now refined:** USER thin frames are produced **inside** Capless (CapFN/post_args/enc with small `frame_sz`) before epi; there is **no** post-success SoftCap USER frame select. SoftCap `0x868` HOST templates never enter that Capless-internal enc arg.

## Plant

**Not isolatable this beat** without banned moves:

- No on-path USER `frame_sz` imm INT3 HIT to patch → `0x868`.
- tip`@121278` / join/epi / LIVE SoftCap transplant / SoftMega retarget / arg-loop: **banned**.

No new Isol host shipped.

## Next single-point (still ban tip`@121278`/join/epi/LIVE/mega)

Capless-**internal** USER enc: find the on-path call that feeds `frame_sz` into `enc_prologue` for mk/main (CapFN/`post_args`/`@567a30` chain) and whether Isol can supply SoftCap-sized `frame_sz` there — not tip SoftCap retarget. Short timeout.

## Ban / PROD

PROD SoftCap `7a2cf5da581a` **untouched**. Pin `ecdb5cc1e` **not raised**. Not green.
