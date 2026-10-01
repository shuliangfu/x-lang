/* Standalone translation unit for the CTFE half of
 * seeds/typeck_cap_residual.from_x.c.
 *
 * This is not a second implementation. The bodies stay in that seed.
 * assemble_typeck_gen_from_x.py pastes the same seed into typeck_gen.c,
 * which is what host-cc typeck_x.o compiles. seeds/typeck_cap_residual_tu.c
 * defines TYPECK_CAP_RESIDUAL_SLOTS_ONLY and so does not emit the seven
 * CTFE faces. This file includes the seed without that macro, so the
 * object also contains the slot-prefix globals. Link it after the slot
 * object: those duplicates lose, and the seven CTFE globals win.
 *
 * struct ast_Expr is not written here. The compiler adds -I of a header
 * sliced from typeck_gen.c (enum ast_TypeKind through the end of
 * struct ast_Expr) by assemble_typeck_gen_from_x.py --write-expr-layout.
 * That slice is the same text the host-cc paste compiles.
 *
 * g05 links this object only when typeck_x.pure_asm matches typeck_x.o.
 * Beside a host-cc typeck_x.o the seven faces would be duplicated and
 * the earlier copy would win, so the hook must not add this object then.
 *
 * PLATFORM: LINUX — the g05 hook is Linux-only. Darwin and Windows still
 * host-cc typeck_gen.c, which already contains these bodies.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "typeck_expr_layout.h"

struct ast_ASTArena;
struct ast_Module;
struct ast_PipelineDepCtx;

extern void lsp_diag_report_typeck(int32_t line, int32_t col, uint8_t *msg);
extern uint8_t *link_abi_getenv(uint8_t *name);
extern int32_t glue_module_func_index_by_name_c(uint8_t *mod, uint8_t *name, int32_t name_len);

#include "typeck_cap_residual.from_x.c"
