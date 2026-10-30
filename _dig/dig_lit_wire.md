# DIG Capless→SoftCap lit emit wire (`lit_wire`)

**2026-10-30 ~15:55 CST (Asia/Shanghai)** · Base Isol alt_frame2 `9378df517f96`. Short timeout INT3 (≤5s/site, budget≤85s). Ban join/epi retarget / LIVE SoftCap transplant / arg-loop / letter-pile.

## Question

Why Capless `p_ret_*` emit stays thin `enc_prologue` `0x68`/`0x1b8` instead of SoftCap tip `@121278` family writing user `0x868`?

## DIG nails

### 1) tip SoftCap `@121278` is host helper, not Capless user-emit writer

| | |
|---|---|
| prol | `push rbp; mov rbp,rsp; push rbx; **sub rsp,0x868**` |
| body | rcx→slot; rdx←0; **`call @21b5fa`**; epi |
| E8 callers | **sole** `@1215b9` (SoftCap-internal) |
| tip_scfull | prior plant tip `@12377c` Capless→`@121278` → **crc=0x1** (ABI/stub; falsified) |

INT3 lit (alt_frame2): `@1212aa` (tip→`@21b5fa`) **not HIT**; tip itself not a Capless user-frame emitter.

### 2) Capless lit path **does** take tip kind `0x30` → Capless

| site | INT3 lit |
|---|---|
| `@12374a` `cmp [rbp+0x1f4],0x30` | **TIMEOUT** (on-path / INT3 hang class) |
| `@12377c` `call Capless @57656c` | **TIMEOUT** |
| `@57656c` Capless FN | **TIMEOUT** |
| `@12378c` kind `0x31` SoftMega `@57ef78` | AV (not clean Capless land) |

Baseline lit: compile **OK** sha `332eed5f048b` — frames **`0x68`+`0x1b8`**, **`0x868=False`**.

### 3) SoftCap flag / encode not the missing wire

- SoftCap flag `@1cf0a6` (prior Isol-scap0 SoftCap=0) **falsified** earlier → still TT thin.
- This beat: flag path not the `0x868` selector for Capless user emit.
- `mov eax,0x868` on Isol HOST: **n=0**. Thin imms exist (`0x68`×39 / `0x1b8`×35) but **no** SoftCap-sized imm feeds `enc_prologue`.

### 4) Sibling SoftCap `@21b5fa` callers HIT ≠ user `0x868` emit

`@21b5fa` = Cap decode helper (`rcx` ptr, `edx` index; `shl eax,3` …). E8 callers include tip `@1212aa` **and** cluster `@1203ae/@1204eb/@1205a5/@12063b/@1206d1/@120a40`.

INT3 lit: cluster call sites **HIT**; tip `@1212aa` **not HIT**. HIT sites are **mid-body Cap-decode** (`host_frame_0x868_near_prol=False`) — shared SoftCap decode, **not** `arch_x86_64_enc_enc_prologue(0x868)` into USER blob.

HOST still has 29× `sub rsp,0x868` (SoftCap helper templates). USER Isol emit stays Capless thin.

### 5) `enc_prologue` / `compute_frame_size` strings

- `enc_prologue` `@dcd2d9`; `compute_frame_size` `@658417` (lea xrefs `@22ce08/@22d391` = name-match visitor `r9d=0x12`, not emit).
- Fork remains: **upstream Capless vs SoftCap path selection** passes small `frame_sz` into `enc_prologue`; tip `@121278` family does not get selected as Capless user emit.

## Wiring gap (conclusion)

| dimension | finding |
|---|---|
| **kind** | tip SoftCap kind **`0x30`→Capless `@57656c`** (thin); kind **`0x31`→SoftMega `@57ef78`≠LIVE SoftCap `@289dcb`** |
| **site** | Capless user emit never calls tip `@121278`; tip_scfull retarget **crc=0x1** |
| **flag** | SoftCap emit_expr flag SoftCap=0/≠0 **already falsified** (scap0); not the `0x868` imm source |
| **early-out** | not a new early-out this beat; Capless path **reaches** Capless FN and completes thin emit |

**Gap = kind/site:** Isol tip SoftCap dispatch sends lit to **Capless** (thin `enc_prologue`), while SoftCap tip `@121278`/`0x868` templates stay **host-internal / Cap-decode siblings** — never wired as USER SoftCap lit frame writer. No Isol `mov eax,0x868` to feed enc.

## Plant

**Not isolatable this beat** as a single semantic `lit_wire`/`enc_868` without banned moves:

- No on-path `mov eax,0x68` INT3 HIT to patch → `0x868` (sampled emit bands empty).
- tip→`@121278` already falsified (`tip_scfull`).
- Ban: join/epi / LIVE SoftCap transplant / arg-loop / SoftMega mega.

No new Isol host shipped green for `0x868`.

## Next single-point (still ban join/epi)

Isol-native **Capless post-success → SoftCap user frame select**: find where Capless emit passes `frame_sz` into `enc_prologue` for mk/main and whether SoftCap twin kind`0x31` can land an Isol helper that writes USER `sub rsp,0x868` (not tip`@121278` retarget; not LIVE transplant). Short timeout.

## Ban / PROD

PROD SoftCap `7a2cf5da581a` **untouched**. Pin `ecdb5cc1e` **not raised**. Not green.
