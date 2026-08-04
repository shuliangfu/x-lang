# pipeline_x_objs.mk — wave817 · 11.3.1 B7B
#
# Single-authority lists for Track F / xlang-x-pipeline product object sets
# and product PIPELINE_LIBS (Linux -lpthread for net/thread).
#
# Used by:
#   - xlang-x-pipeline (BASE + FRONTEND + SUPPORT / LINK + PIPELINE_LIBS)
#   - seed / relink recipes that expand $(PIPELINE_LIBS) via composites
#   - driver_seed_obj_catalog.sh shell parse (0-make; G.7)
#
# G.7: Definitions live only here. Makefile must include, not re-assign the
# full inventory. Shell host-defaults must not hardcode a second PIPELINE_LIBS
# or PIPELINE_X_* .o list (parse this mk instead).
#
# wave817: moved out of compiler/Makefile inline body (list residual of
# b7b_lists_in_mk / std_core_product_make_graph). NOT physical delete — thin
# edges + other mk lists + B2 ensure graph still residual.
#
# PLATFORM: SHARED — product leaf names are host-portable basenames.
# PLATFORM: LINUX — PIPELINE_LIBS := -lpthread (net/thread); else empty.
# Note: PIPELINE_X_LINK_OBJS refs $(USER_ASM_LINK) (user_asm_seed_objs.mk);
# recursive make expansion is OK when consumers run after that include.
# Catalog must parse user_asm_seed_objs.mk before this file.

# Core pipeline-x base (main/runtime with USE_X_PIPELINE + diag + seed lexer/ast).
PIPELINE_X_BASE_OBJS = src/main_x.o src/runtime_x.o src/diag.o src/lexer/lexer.o src/ast/ast_seed.o

# Typeck/codegen X frontends + frontend link alias.
PIPELINE_X_FRONTEND_OBJS = typeck_x.o codegen_x.o x_frontend_link_alias.o

# Satellite .o set aligned with DRIVER_SEED_OBJS extras (except main_x/runtime_x).
# fmt_check_cmd.o (non-_driver): runtime_x has no XLANG_USE_X_DRIVER; fmt/check
# use run_compiler_c stubs to avoid missing driver_run_compiler_full.
PIPELINE_X_SATELLITE_OBJS = lexer_x.o preprocess_x.o \
  src/driver/fmt_check_cmd.o src/driver/target_cpu.o \
  src/asm/simd_enc.o src/asm/simd_loop.o \
  src/async/async_liveness.o src/async/async_cps_codegen.o \
  src/runtime_driver_strict_glue_stubs.o

# Full link set for xlang_x (parser + frontends + bridge + satellites + user asm).
PIPELINE_X_LINK_OBJS = parser_x.o typeck_x.o codegen_x.o src/x_seed_bridge.o $(PIPELINE_X_SATELLITE_OBJS) $(USER_ASM_LINK)

# Make prereq set for xlang-x-pipeline (phony host dispatch + link objs).
PIPELINE_X_SUPPORT_OBJS = build-seed-asm-host $(PIPELINE_X_LINK_OBJS)

# xlang-x-pipeline / seed link: F-03 v2/v3 std.io pure .x; Linux -lpthread
# (net/thread); no -luring here (strict glue / bootstrap nostdlib own that).
PIPELINE_LIBS :=
ifeq ($(UNAME_S),Linux)
  PIPELINE_LIBS := -lpthread
endif
