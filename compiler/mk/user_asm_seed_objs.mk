# user_asm_seed_objs.mk — wave727 · 11.0.4
#
# Single-authority object lists for USER_ASM seed / Darwin filtered / asm-host
# dispatch prereqs. Included by compiler/Makefile after UNAME_S is defined.
#
# G.7: Do not re-assign these variables in Makefile body or hardcode the same
# .o inventory in shell. Catalog expands via shell mk parse (wave788) or make
# export escape — never a second .o inventory in residual scripts.
#
# PLATFORM: SHARED — Darwin branch uses filtered .o; Linux uses plain .o.

# seed xlang 用户程序 -backend asm：xlang-c -E 编出的 backend/peephole/platform + user_asm_seed_bridge（无 weak 桩、无 C 回退）
USER_ASM_SEED_HOST_DIR = build_asm/seed_host
USER_ASM_SEED_HOST_OBJS = $(USER_ASM_SEED_HOST_DIR)/asm_backend_partial.o
USER_ASM_SEED_HOST_STUBS = $(USER_ASM_SEED_HOST_DIR)/asm_full_link_stubs.o
USER_ASM_SEED_OBJS = src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arm64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o
USER_ASM_LINK = $(USER_ASM_SEED_HOST_OBJS) $(USER_ASM_SEED_HOST_STUBS) $(USER_ASM_SEED_OBJS)
ifeq ($(UNAME_S),Darwin)
BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O = build_asm/bootstrap_seed_pipeline_filtered.o
# PLATFORM: MACOS — backend_arm64_enc_c.o strong arch_arm64_enc_* override seed_link_compat weak -1 (CG002).
BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS = build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o src/asm/backend_arm64_enc_c.o src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o
BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS = $(BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O) $(BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS)
XLANG_X_PIPELINE_LINK_O = $(BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O)
XLANG_X_USER_ASM_OBJS = $(BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS)
RELINK_XLANG_PIPELINE_LINK_O = $(BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O)
RELINK_XLANG_USER_ASM_LINK = $(USER_ASM_SEED_HOST_OBJS) $(USER_ASM_SEED_HOST_STUBS) $(BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS)
RELINK_XLANG_FILTERED_OBJS = $(BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS)
else
BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O = pipeline_x.o
BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS = $(USER_ASM_SEED_OBJS)
BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS =
XLANG_X_PIPELINE_LINK_O = pipeline_x.o
XLANG_X_USER_ASM_OBJS = $(USER_ASM_SEED_OBJS)
RELINK_XLANG_PIPELINE_LINK_O = pipeline_x.o
RELINK_XLANG_USER_ASM_LINK = $(USER_ASM_LINK)
RELINK_XLANG_FILTERED_OBJS =
endif

# §5b #8 — build-seed-asm-host body is scripts/build_seed_asm_host.sh (wave725).
# Dispatch prereqs: single-authority list DRIVER_SEED_ASM_HOST_DISPATCH_OBJS (this file).
DRIVER_SEED_ASM_HOST_DISPATCH_OBJS = src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o
