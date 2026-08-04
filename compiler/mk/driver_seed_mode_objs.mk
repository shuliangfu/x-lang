# driver_seed_mode_objs.mk — wave818 · 11.3.1 B7B · wave925 pipeline-gen-cflags
#
# Single-authority seed *mode picks* for bootstrap-driver-seed / composites:
#   DRIVER_SEED_RUNTIME_O
#   DRIVER_SEED_FRONTEND_EXTRA
#   DRIVER_SEED_SUPPORT_EXTRA
#   DRIVER_SEED_LINK_FLAGS
#   DRIVER_SEED_RUNTIME_REBUILD
#   PIPELINE_GEN_CFLAGS_BASE / CLANG / CC_IS_CLANG / PIPELINE_GEN_CFLAGS (wave925)
#
# Used by:
#   - compiler/Makefile seed link / rebuild recipes
#   - mk/driver_seed_composites.mk (DRIVER_SEED_OBJS / PREREQS expand SUPPORT_EXTRA)
#   - driver_seed_obj_catalog.sh shell parse (0-make; G.7)
#   - driver_seed_obj_catalog.sh --cflags-export (wave925: CFLAGS + PIPELINE_GEN_CFLAGS)
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

# ---------------------------------------------------------------------------
# wave925: PIPELINE_GEN_CFLAGS moved from Makefile inline (G.7 single authority).
# Converted from $(if $(CC_IS_CLANG),...) to ifeq so catalog_parse_mk can
# resolve. CC_IS_CLANG is NOT defined here — it is computed by:
#   - Makefile (before include): CC_IS_CLANG := $(findstring clang,$(shell $(CC) -v 2>&1))
#   - catalog_seed_host_defaults (shell): $CC -v 2>&1 | grep -q clang → "clang" or ""
# Both produce "clang" when CC output contains "clang", empty otherwise.
# catalog_parse_mk reads CC_IS_CLANG from store (set before parse).
# ---------------------------------------------------------------------------
PIPELINE_GEN_CFLAGS_BASE = -Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits
# PLATFORM: MACOS/CLANG — Apple Clang treats -Wparentheses-equality as distinct
# from -Wparentheses; without -Wno-parentheses-equality, -E-extern gen C
# (cfg_eval/typeck/…) hard-fails under -Werror and silently falls back to
# bootstrap stubs (false Cap residual).
# PLATFORM: LINUX/GCC — -Wno-parentheses in BASE is usually enough; extra flag no-op.
PIPELINE_GEN_CFLAGS_CLANG = -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses -Wno-incompatible-pointer-types-discards-qualifiers -Wno-parentheses-equality
PIPELINE_GEN_CFLAGS = $(PIPELINE_GEN_CFLAGS_BASE)
ifeq ($(CC_IS_CLANG),clang)
PIPELINE_GEN_CFLAGS += $(PIPELINE_GEN_CFLAGS_CLANG)
endif
