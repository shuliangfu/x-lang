# DIG SoftCap join `@576523`→epi `@576555` / who writes lit frame `0x868`

Base Isol: alt_frame2 `9378df517f96`. Short timeout INT3 (≤5s/site, budget≤85s). Ban letter-pile / LIVE SoftCap transplant / arg-loop.

## Join → epi (HOST Cap FN `@5752bc`, frame `0x9e0`)

| RVA | insn |
|---|---|
| `@5763d6` | `mov [rbp+0x934],0` (alt_frame2 force-exit land) |
| `@5763e0` | `jmp @576523` |
| **`@576523`** | `mov eax,[rbp+0x934]`; `cmp eax,[rbp+0x998]`; **`jl @5763e5`** (re-enter body if i&lt;count) |
| `@576535` | `mov ecx,0`; `call @24b022`; `mov eax,0`; `jmp @576555` |
| **`@576555`** | `add rsp,0x9e0`; `pop rbp`; `ret` |

**Semantics:** join is the Cap FN **loop-exit gate**, not a user-emit site. Clear-934 then jmp join **restarts** the body when `count>0` (jl `@5763e5`); true skip-to-epi land = `@576535` / `@576555`. Host epi tears down **`0x9e0`**, orthogonal to SoftCap lit **`0x868`**.

## INT3 frontier (alt_frame2 × `p_ret_lit`, 2026-10-30)

| site | tag |
|---|---|
| `@5763d6` clr934 | **HIT** |
| `@5763e0` jmp523 | AV (treat as mid/alt; see note) |
| `@576523` join | AV |
| `@57652f` jl | **HIT** |
| `@576535` post_jl | **HIT** |
| `@57653a` call `@24b022` | AV |
| `@576544` jmp epi | AV |
| `@576555` epi | AV |
| `@5763e5` reenter | AV |
| `@57651c` inc934 | **HIT** |

Baseline alt_frame2 lit: **OK** sha `332eed5f048b` — frames **`0x68`+`0x1b8`**, **`0x868=False`**.

Note: jl/post_jl/inc/clr **HIT** ⇒ join region **reachable** under force-exit; epi-byte AV alone ≠ "unreachable join" (same mid-insn class as prior DIG). Compile-OK thin emit stands.

## Who writes SoftCap lit `0x868` (vs Capless thin / Cap FN)

| path | frame | role |
|---|---|---|
| HOST Cap FN `@5752bc`…`@576555` | **`0x9e0`** | compile orchestration / join-epi only |
| Capless user emit (Isol `p_ret_*` now) | **`0x68` / `0x1b8`** | Capless `enc_prologue` / `compute_frame_size` (strings `@dcd2d9` / `@658417`) |
| SoftCap lit LIVE user emit | **`0x868` / `0x878`** | SoftCap helper templates (HOST 29× `sub rsp,0x868`; tip `@121278` cluster) |
| tip SoftCap `@121278` | `sub rsp,0x868` | sole E8 caller `@1215b9` (SoftCap-family **internal**); **not** Cap FN |

- Isol host: **`mov eax,0x868` count = 0**; Capless loads small imms (`0x68`/`0x1b8`) into enc path.
- LIVE `out_LIVE_p_ret_lit`: `0x868`×1 + `0x878`×1 (mk/main); thin Isol emit: `0x68`+`0x1b8`, no `0x868`.

**Conclusion:** **`0x868` writer = SoftCap emit/helper path** (tip `@121278` family), **not** join/epi and **not** Cap FN `0x9e0`. alt_frame2 reaches host join enough to compile but user emit stays Capless thin ⇒ join retarget **cannot** mint `0x868`.

## Plant `join_epi` (isolatable; red)

Patch `@5763e0` `jmp @576523` → `jmp @576535` (skip jl reentry). sha12 **`ff46f731435d`**.

| src | compile | `0x868` | run |
|---|---|---|---|
| `p_ret_lit` | **AV** | — | — |
| `p_ret_fwd` | **GS** | — | — |
| `p_ret_local` | **AV** | — | — |

Plant INT3: post_jl **HIT**; epi AV; join OK (skipped). **Worse than alt_frame2; not 运行绿.**

## Next single-point

Keep alt_frame2 force-exit. **Do not** further join/epi retarget for `0x868`. DIG/plant **Capless→SoftCap lit emit wire**: how SoftCap tip `@121278`/`0x868` templates get selected instead of Capless `enc_prologue` thin `0x68`/`0x1b8` for `p_ret_*` (Isol-native; ban LIVE transplant / arg-loop).

## Ban / PROD

PROD SoftCap `7a2cf5da581a` **untouched**. Pin `ecdb5cc1e` **not raised**. Not green.
