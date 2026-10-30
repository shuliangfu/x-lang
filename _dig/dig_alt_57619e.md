# DIG SoftCap lit @57619e alt (@5603b8 / @56fa68) → @57629b

Base: post_fa3 `453f3e66f96c` (h3_jesk `cfb0fae4f5d9` + jmp-skip mid `@5760c2/@5760fb`). Short timeout INT3. Ban letter-pile / LIVE SoftCap transplant / arg-loop / twin.

## Path

| site | role | SoftCap lit |
|---|---|---|
| @576134 je @57619e | enter alt | taken (call sites HIT) |
| @57619e | alt head `mov r8d,[rbp+0x904]` | valid entry (je target) |
| @5761c2 call @5603b8 | first helper | call site **HIT** |
| @5761c7 after | store eax→`[rbp+0x8fc]` | **AV** (no clean return) |
| @5761d5 call @56fa68 | second helper | call site **HIT** |
| @5761da after / @57629b inc | — | **AV** without plant |

## Nail 1: @56fa68 = mid-insn (same class as @5862f8)

- Bytes `@56fa60`: `88 83 c2 00 00 00` … = `mov [rbx+disp],al` clear run.
- No push-rbp in prior 0x100. Executing as call target → AV.
- LIVE map (prior): `@56fa68` ≅ LIVE `@281df8` (cmp ecx,0x10) — Isol delta landed mid clear.

## Nail 2: @5603b8 = valid prol; AV inside / bad frame

- `@5603b8`: `push rbp; mov rbp,rsp; push rbx; sub rsp,0x428` — **legal entry** (entry INT3 **HIT**).
- Body probes: early AV after prol; one deep HIT `@560480` — not mid-insn entry.
- after-call AV + later `@57629b` store AV under skip ⇒ **bad frame / rbp** (not missing call-mk alone).
- `@55e5f8` (alt success-path helper): also valid prol.

## Isol plant `alt_57619e` / `post_57619e` (one; semantic)

| Isol | sha12 | plant | SoftCap p_ret_* |
|---|---|---|---|
| alt_57619e | `e1c45031fb92` | near-jmp `@5761c2→@57629b` (+ xor-nop 2nd call) | lit/**AV** fwd/**GS** local/**AV** |

- Advances: `@57629b` inc **HIT** (INT3 before store).
- `@5762a2` loop / exit / post-loop still **AV** — executing `add [rbp+0x934],1` AVs ⇒ rbp/frame still bad after skip.
- Weaker jmp-to-`@5761da` (`b5d9c562dc4b`) also red (AV/GS/AV).

## Next single-point

DIG **bad-frame root** at alt (rbp after post_fa3 skip / `@5603b8` body) — not another mid-call skip alone; then `@57629b`→loop exit `@5762b4` / `@5763c4`.

## Ban / PROD

PROD SoftCap `7a2cf5da581a` untouched. Pin ecdb5cc1e not raised. Not green.
