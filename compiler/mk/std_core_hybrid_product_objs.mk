# std_core_hybrid_product_objs.mk — wave897 B7B B2 std/core hybrid edges list→mk
#
# G.7: make-graph inventory only. Compile body authority remains
#   scripts/ensure_host_cc_seed_o.sh try-heat → try-std-core-prefer (wave780
#   table + wave790 heat unify + wave794–796 FORCE dep-thin mtime).
# PLATFORM: SHARED — portable product .o paths from compiler/ cwd.
#
# NOT physical delete. Residual after: thin edges + remaining mk lists hybrid
# + tip Windows → dual L4 → explicit auth ship delete.
#
# Consumers: Makefile multi-target FORCE thin try-heat.
# COUNT=5 (PHYS_DEL_BUCKET_B2_HEAT_TARGETS): process/path/runtime/net + core/slice.
# Distinct from formal_mod core/slice/mod.o (wave894 formal catalog).

STD_CORE_HYBRID_PRODUCT_OBJS = \
	../std/process/process.o \
	../std/path/path.o \
	../std/runtime/runtime.o \
	../std/net/net.o \
	../core/slice/slice.o
