# driver_subcmd_objs.mk — wave816 · 11.3.1 B7B
#
# Single-authority lists for Track L driver subcommand product leaves and
# archaeology gen inventory (DRIVER_SUBCMD_* / DRIVER_LEAF_*).
#
# Used by:
#   - bootstrap-driver-seed / phase1 / final / relink (via DRIVER_SUBCMD_OBJS)
#   - mk/driver_seed_composites.mk (requires DRIVER_SUBCMD_OBJS + GEN before include)
#   - driver_seed_obj_catalog.sh shell parse (0-make; G.7)
#   - archaeology FORCE_REGEN gen names (DRIVER_SUBCMD_GEN_ALL)
#
# G.7: Definitions live only here. Makefile must include, not re-assign the
# full inventory. Shell host-defaults must not hardcode a second .o list for
# DRIVER_SUBCMD_OBJS (parse this mk instead).
#
# wave816: moved out of compiler/Makefile inline body (list residual of
# b7b_lists_in_mk / std_core_product_make_graph). NOT physical delete — thin
# edges + other mk lists + B2 ensure graph still residual.
#
# PLATFORM: SHARED — product leaf names are host-portable basenames.

# Historic partial set (fmt/check/test/build/run only; no compile/emit).
# Kept for any remaining consumers of the short name.
DRIVER_LEAF_OBJS = driver_fmt_x.o driver_check_x.o driver_test_x.o driver_build_x.o driver_run_x.o

# Product seed prereqs: Track L retired workspace *_gen.c from DRIVER_SEED_PREREQS.
# Empty on purpose (archaeology gens optional via FORCE_REGEN only).
DRIVER_SUBCMD_GEN =

# Archaeology gen inventory (FORCE_REGEN / ensure_archaeology_gen parity).
DRIVER_SUBCMD_GEN_ALL = driver_fmt_gen.c driver_check_gen.c driver_test_gen.c driver_compile_gen.c driver_build_gen.c driver_run_gen.c driver_emit_gen.c

# Full product driver subcommand .o set (7 leaves; seed link / relink / stage2).
DRIVER_SUBCMD_OBJS = driver_fmt_x.o driver_check_x.o driver_test_x.o driver_compile_x.o driver_build_x.o driver_run_x.o driver_emit_x.o

# Default -L roots for driver leaf -E / host-cc paths (legacy env override name).
# Product ensure path uses driver_leaf_x_to_o.sh catalog dirs; this remains the
# Makefile-exported default for g05 / build_xlang_asm explicit-arg callers.
DRIVER_SUBCMD_DIRS = -L .. -L src -L src/lexer -L src/ast
