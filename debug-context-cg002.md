# Debug Session: context-cg002
- **Status**: [OPEN]
- **Issue**: `./shux_asm -backend asm -L .. ../std/context/context.x -o ...` reaches `pipeline thread done ec=0` and then fails with `codegen error[CG002]: asm_codegen_elf_o failed (elf_ec=-1, out_len=0, num_funcs=34)`.
- **Debug Server**: N/A
- **Log File**: `tests/probes/bootstrap-parser/context_asm_core.stderr`

## Reproduction Steps
1. Run `perl -e 'alarm shift; exec @ARGV' 15 env SHUX_DEBUG_PIPE=1 SHUX_ASM_WPO_DCE=0 ./shux_asm -backend asm -L .. ../std/context/context.x -o ../tests/probes/bootstrap-parser/context_asm_core.o`
2. Observe parse/typeck reaches `pipeline thread done ec=0`.
3. Observe `codegen error[CG002]: asm_codegen_elf_o failed (elf_ec=-1, out_len=0, num_funcs=34)`.

## Hypotheses & Verification
| ID | Hypothesis | Likelihood | Effort | Evidence |
|----|------------|------------|--------|----------|
| A | ELF patch resolution for one local label in `context.x` fails because the patch name and emitted label name diverge | High | Low | Rejected: `SHUX_ASM_DEBUG=1` first exposed an earlier emit failure at `atomic_store_i32_c(&bg.cancelled, 0)` before final patch resolution |
| B | One asm emit branch returns success but leaves an unresolved forward label/patch entry, causing final ELF object assembly to abort | High | Medium | Rejected: after active-link override, `asm_codegen_elf_o elf_ec=0 elf_len=8505` and `context_asm_core.o` is produced |
| C | `context.x` triggers a target-specific arch encoding edge case after code emission, not a parser/typeck issue | Medium | Medium | Rejected: same module succeeds once `ADDR_OF(FIELD_ACCESS)` is routed through lvalue effective-address emit |
| D | The failure is caused by stale/duplicate alias or object topology rather than `context.x` codegen itself | Low | Low | Confirmed in narrowed form: the source fix in `pipeline_glue.c` was correct, but active `shux_asm` linked `pipeline_x.o`'s stale `pipeline_asm_emit_addr_of_elf_c()` instead of the new standalone glue |
| E | A specific function in `context.x` corrupts ELF label bookkeeping before `asm_codegen_elf_o` finalization | Medium | Medium | Partially confirmed: the failing function is `ctx_glue_background_c()`, specifically `atomic_store_i32_c(&bg.cancelled, 0)` and the same shape in child alloc/store paths |

## Findings
- `SHUX_ASM_DEBUG=1` instrumentation first narrowed the failure from generic `CG002` to `ctx_glue_background_c()` emitting `atomic_store_i32_c(&bg.cancelled, 0)`.
- `pipeline_glue.c` fallback logging showed `addr_of elf fallback expr_ref=328 op_ref=327 op_kind=44`, proving the missing shape was `ADDR_OF(FIELD_ACCESS)`.
- The source-side root fix in `pipeline_glue.c` (`ok == 44 -> pipeline_asm_emit_lvalue_eff_addr_elf_c(...)`) did not change runtime behavior because `make shux_asm` linked `build_asm/pipeline_glue_strict_minimal.o` while the active exported symbol still came from `pipeline_x.o`.
- The final minimal fix was to add an override `pipeline_asm_emit_addr_of_elf_c()` in `src/asm/pipeline_glue_strict_minimal.c`, delegating `ADDR_OF(VAR/FIELD_ACCESS/INDEX)` to `pipeline_asm_emit_lvalue_eff_addr_elf_c()`. This override participates in the actual `relink-shux` link and suppresses the stale `pipeline_x.o` snapshot on Darwin.

## Post-Fix Evidence
1. `perl -e 'alarm shift; exec @ARGV' 12 make shux_asm`
2. `perl -e 'alarm shift; exec @ARGV' 15 env SHUX_DEBUG_PIPE=1 SHUX_ASM_DEBUG=1 SHUX_ASM_WPO_DCE=0 ./shux_asm -backend asm -L .. ../std/context/context.x -o ../tests/probes/bootstrap-parser/context_asm_core.o`
3. Observe:
   - no `shux: addr_of elf fallback ...`
   - `note: asm debug: asm_codegen_elf_o macho_write=8505 out_len=0`
   - `note: asm debug: asm_codegen_elf_o elf_ec=0 elf_len=8505`
   - output file `tests/probes/bootstrap-parser/context_asm_core.o` exists (`8.3K`)
4. Front gate moves again under `make bootstrap-parser` to:
   - `parse error[P001]: expected '}'`
   - `../std/trace/trace.x:123:8`
