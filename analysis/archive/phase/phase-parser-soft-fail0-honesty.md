# Parser soft FAIL:-0 → hard honesty (phase)

> Archived archaeology DOC for the parser FAIL:-0 soft cluster.
> Live roadmap: `analysis/自举进度.md`. Refuse resurrecting a top-level twin.

## Gate

Honesty wave: retire soft `XLANG_PARSER_*_FAIL` die→exit0 on:

| Gate | Script | Linux hard surface |
|------|--------|--------------------|
| C1 bootstrap TU | `tests/run-parser-parse-bootstrap-gate.sh` | cc + `parse_into_buf` / `parser_parse_into_buf` + `.text` min |
| C2 link smoke | `tests/run-parser-parse-bootstrap-link-smoke.sh` | when `parser_parse_bootstrap.o` present: compile smoke hard |
| C2 bisect | `tests/run-parser-parse-bootstrap-bisect-gate.sh` | MINIMAL whitelist hard; FULL mega emit remains observational |
| C3 x-emit probe | `tests/run-parser-parse-bootstrap-x-emit-gate.sh` | MINIMAL hard; unexpected mega `parse_into_buf` hard; known FULL fail OK |
| thin glue symbols | `tests/run-parser-thin-glue-symbol-integrity-gate.sh` | baseline TSV + stretch/glue mins hard |
| experimental emit | `tests/run-parser-experimental-emit-gate.sh` | DOC hard; present+OK=run=1; present+fail=obs (REQUIRE=1 hard) |
| parse count | `tests/run-parser-parse-count-gate.sh` | `num_funcs` ≥ baseline min hard |
| mega bisect | `tests/run-parser-mega-bisect-gate.sh` | unexpected large delta hard (stub/fail path OK; **not** mega promote) |
| mega sweep | `tests/run-parser-mega-bisect-sweep-gate.sh` | unexpected emit hard; absolute-size TSV drift = obs |

**PLATFORM: LINUX** gold for nm/objdump/ELF; **DARWIN** honest `skip=1` (N/A), not soft PASS.
**Non-goal:** mega product promote / assemble full `parser.x` as default / raise pin.

Parent wrappers: BOOT-024 (`boot-024-parser-bootstrap-emit-v1.md`), ENG quality thin-glue (`eng-quality-gate-v1.md`).
