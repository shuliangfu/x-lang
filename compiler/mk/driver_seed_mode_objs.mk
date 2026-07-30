# driver_seed_mode_objs.mk — wave818 · 11.3.1 B7B
#
# Single-authority seed *mode picks* for bootstrap-driver-seed / composites:
#   DRIVER_SEED_RUNTIME_O
#   DRIVER_SEED_FRONTEND_EXTRA
#   DRIVER_SEED_SUPPORT_EXTRA
#   DRIVER_SEED_LINK_FLAGS
#   DRIVER_SEED_RUNTIME_REBUILD
#
# Used by:
#   - compiler/Makefile seed link / rebuild recipes
#   - mk/driver_seed_composites.mk (DRIVER_SEED_OBJS / PREREQS expand SUPPORT_EXTRA)
#   - driver_seed_obj_catalog.sh shell parse (0-make; G.7)
#
# G.7: Definitions live only here. Makefile must include, not re-assign the
# product inventory. Shell host-defaults must not hardcode a second
# DRIVER_SEED_SUPPORT_EXTRA / RUNTIME_O list (parse this mk instead).
#
# wave818: moved out of compiler/Makefile inline ifeq body (list residual of
# b7b_lists_in_mk). NOT physical delete — thin edges + other mk lists +
# std_core product graph still residual.
#
# PLATFORM: SHARED — product leaf names are host-portable basenames.
# Branches: XLANG_LEGACY_C_FRONTEND=1 (archaeology capture layout) vs product
# no_c default. XLANG_NO_C_SEED_LINK=1 historically used a separate else-if
# branch with the *same* inventory as product default (since G-02a); catalog
# parse only supports ifeq/else/endif (not "else ifeq"), so both collapse here
# under the non-LEGACY branch. Make behavior for default flags is unchanged.
#
# Stubs note (Windows-critical history, kept for archaeology):
#   runtime_driver_strict_glue_stubs.o lives in DRIVER_SEED_GLUE_SUFFIX /
#   RELINK_XLANG_GLUE_SUFFIX (link END), not in SUPPORT_EXTRA. SUPPORT_EXTRA
#   keeps non-stub satellites only (async_*, cfg_eval*, typeck_f64_bits).
#   PLATFORM: SHARED — PE first-wins multidef; ELF/Darwin weak is order-no-op.

# Empty: C frontend .c inventory deleted; LEGACY_FRONTEND_EXTRA expands to empty.
DRIVER_SEED_C_FRONTEND_LEGACY =

ifeq ($(XLANG_LEGACY_C_FRONTEND),1)
# Archaeology / capture layout (bootstrap_xlangc seed generation).
DRIVER_SEED_RUNTIME_O = src/runtime_driver.o
DRIVER_SEED_FRONTEND_EXTRA = $(DRIVER_SEED_C_FRONTEND_LEGACY)
# LEGACY SUPPORT: full async pair + bootstrap cfg_eval stub + f64 bits.
DRIVER_SEED_SUPPORT_EXTRA = src/async/async_liveness.o src/async/async_cps_codegen.o src/async/async_asm_pool.o src/lexer/cfg_eval_bootstrap_stub.o src/typeck/typeck_f64_bits.o
DRIVER_SEED_LINK_FLAGS = -DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN
DRIVER_SEED_RUNTIME_REBUILD = src/runtime_driver.o src/async/async_cps_codegen.o
else
# Product no_c default (G-02a). Also covers XLANG_NO_C_SEED_LINK=1 (same inventory).
# async_asm_pool: unbundled from pipeline_glue; required for asm CPS layout.
DRIVER_SEED_RUNTIME_O = src/runtime_driver_no_c.o
DRIVER_SEED_FRONTEND_EXTRA =
DRIVER_SEED_SUPPORT_EXTRA = src/async/async_asm_pool.o src/lexer/cfg_eval.o src/typeck/typeck_f64_bits.o
DRIVER_SEED_LINK_FLAGS = -DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN
DRIVER_SEED_RUNTIME_REBUILD = src/runtime_driver_no_c.o
endif
