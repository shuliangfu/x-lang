# x_e_dirs.mk — wave824 · 11.3.1 B7B
#
# Single-authority inventories for product *-E module search roots (-L flags):
#   MAIN_X_E_DIRS     — main.x / driver_gen -E roots (includes bare -L src)
#   LSP_X_E_DIRS      — lsp/*.x -E roots (no bare -L src; historic product)
#   PIPELINE_X_E_DIRS — pipeline.x -E roots (bootstrap-pipeline / pipeline_gen)
#
# Used by:
#   - compiler/Makefile: thin leaves that expand $(MAIN_X_E_DIRS)/$(LSP_X_E_DIRS)
#   - scripts/ensure_driver_gen.sh: main.x -E
#   - scripts/ensure_lsp_pipeline_gen.sh: lsp + pipeline -E
#   - scripts/ensure_archaeology_gen.sh: lsp_io_std_heap -E (LSP roots)
#   - scripts/driver_leaf_x_to_o.sh: kind=lsp dirs (must match LSP_X_E_DIRS)
#   - driver_seed_obj_catalog.sh shell parse (0-make; G.7)
#
# G.7: Definitions live only here. Makefile must include, not re-assign the
# full inventory. Shell must not hardcode a second MAIN/LSP/PIPELINE_X_E_DIRS
# list (parse this mk instead).
#
# wave824: moved out of compiler/Makefile inline body + closed dual bash arrays
# in ensure_driver_gen / ensure_lsp_pipeline_gen / ensure_archaeology_gen
# (list residual of b7b_lists_in_mk). NOT physical delete — thin edges +
# std_core product make graph still residual.
#
# PLATFORM: SHARED — -L roots are host-portable source layout paths.
# Honesty fixed multi-token authority COUNT (directory path tokens only;
# excludes the literal "-L" flag tokens):
#   MAIN_X_E_DIRS 9 + LSP_X_E_DIRS 8 + PIPELINE_X_E_DIRS 9 = 26

# main.x / driver_gen: -L src required so src/main.x resolves relative imports.
MAIN_X_E_DIRS = -L .. -L src -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess

# lsp/*.x product -E: no bare -L src (historic; avoids picking wrong main module).
LSP_X_E_DIRS = -L .. -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess

# pipeline.x -E (pipeline_gen / bootstrap-pipeline): includes src/asm for backend.
PIPELINE_X_E_DIRS = -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess
