# driver_leaf_product_objs.mk — wave896 B7B driver_leaf product edges list→mk
#
# G.7: make-graph inventory only. Compile body authority remains
#   scripts/driver_leaf_x_to_o.sh ensure (wave814 catalog + wave828 mtime +
#   wave860 BASE_CFLAGS export leaf).
# PLATFORM: SHARED — portable product .o basenames from compiler/ cwd.
#
# NOT physical delete. Residual after: thin edges + B2 try-heat + other
# mk lists hybrid + tip Windows → dual L4 → explicit auth ship delete.
#
# Consumers: Makefile multi-target FORCE thin ensure.
# Related (distinct authority / purpose — do not dual-list recipe edges):
#   mk/driver_subcmd_objs.mk DRIVER_SUBCMD_OBJS — seed link / relink prereq set
#   (7 leaves; no lsp_io_std_heap_x.o). This list is ensure-catalog-only (9).

DRIVER_LEAF_PRODUCT_OBJS = \
	driver_fmt_x.o \
	driver_check_x.o \
	driver_test_x.o \
	driver_build_x.o \
	driver_run_x.o \
	driver_compile_x.o \
	driver_emit_x.o \
	lsp_io_x.o \
	lsp_io_std_heap_x.o
