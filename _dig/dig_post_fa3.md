# DIG SoftCap lit post-@575fa3 clear / @5762a2 loop (call-mk @5752bc)

Base: h3_jesk `cfb0fae4f5d9`. Short timeout INT3. Ban letter-pile / LIVE SoftCap transplant / arg-loop / twin.

## Path (HIT)

| site | role | SoftCap lit |
|---|---|---|
| @575fa3..@576052 | clear 5×memset + init 938/934 | **HIT** |
| @57605c jmp @5762a2 | enter loop cond | reaches (@5762a2 **HIT**) |
| @5762a2 / @5762ae jl | loop cond → body | **HIT** |
| @576061 / @57607a call @1ff2a3 | body head | **HIT** |
| @5760c2 call @5862f8 | first helper | call site **HIT**; after **AV** |
| @5760fb call @5863c9 | second helper | after **AV** |

## Nail: AV root = mid-insn call targets

- `call @5760c2 → @5862f8` and `call @5760fb → @5863c9` land **mid-instruction** inside a long `mov [rbx+disp],eax` clear (run starts ~@58616a), **not** valid fn entries.
- Bytes at @5862f0: `89 83 04 01 00 00` (`mov [rbx+0x104],eax`); @5862f8 is mid-insn.
- Executing mid-insn / wrong rbx → AV before `@5760c7` / loop exit.

## Isol plant `post_fa3` (one; semantic)

| Isol | sha12 | plant | SoftCap p_ret_* |
|---|---|---|---|
| post_fa3 | `453f3e66f96c` | jmp-skip `@5760c2→@576110` (+ nop 2nd call) | lit/**AV** fwd/**GS** local/**AV** |

- Advances: `@576110` / `@576132` / `@57619e` **HIT**.
- Still AV before `@57629b` inc / loop exit `@5762b4` / post-loop `@5763c4`.
- xor-only skip of calls: still AV (falsified as insufficient).

## Next single-point

Densify alt path `@57619e` (`call @5603b8` / `@56fa68`) → `@57629b`; then loop exit / `@5763c4`.

## Ban / PROD

PROD SoftCap `7a2cf5da581a` untouched. Pin ecdb5cc1e not raised. Not green.
