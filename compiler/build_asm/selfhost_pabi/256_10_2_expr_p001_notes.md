# 256/10.2 Track L expr P001 (2026-10-13 CST)

## Tip
`806b37d8e` + local: opaque memcpy writeback on primary/cast/logor ptr faces;
p9a_lex_bridge first-win in thin glue; restored-prefixed lexer_x; pel `_pel_*`.

## Matrix (tip `-backend asm -c`) — GREEN
| case | result |
|------|--------|
| r1 / rx / let1 / call | OK |
| letx / binop / paren / unary | OK (was P001) |

## Root cause (fixed)
Tip CG field stores `p.line/col = res.next_lex.*` use wrong nested offsets and
8-byte `str` that clobbers adjacent `out_ok` on the caller stack. After IDENT
primary, binop peek never saw PLUS. Fix: opaque `memcpy(lex, res+8, 16)` +
i32 ok/ref loads in ptr_into faces (minimal restored-compiled injects; tip
cannot emit full tramp faces).

## Relink deps (Darwin)
- `p9a_lex_bridge.o` must first-win over hollow tip.bak lex peek (1576 vs 1164)
- `lexer_x.o` must export `_lexer_*` prefixes (restored-built)
- pel symbols `_pel_*` (not `_parser_pel_*`); dedupe root vs src/asm pel .o

## Bans held
No CloudAgent / FORCE_CC / new host-cc .c / KEEP_C / winner / leftover / .prev / pin bump / post-hoc product binary patch.

## Next
Cap tip-thin → g05 → Mac L2 5/5 + 129 bstrict → l4 → Ubuntu ff → 勾 10.2
