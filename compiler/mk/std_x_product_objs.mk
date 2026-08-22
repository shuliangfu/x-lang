# std_x_product_objs.mk — wave895 B7B std_x product edges list→mk
#
# G.7: make-graph inventory only. Compile body authority remains
#   scripts/xlang_compile_std_x.sh ensure (wave825 catalog + wave827 mtime).
# PLATFORM: SHARED — portable product .o paths from compiler/ cwd.
#
# NOT physical delete. Residual after: thin edges + B2 try-heat + other
# mk lists hybrid + tip Windows → dual L4 → explicit auth ship delete.
#
# Consumers: Makefile multi-target FORCE thin ensure; std-objs via STD_AND_PANIC_O
# still lists overlapping members (wave813); this list is std_x-catalog-only.

STD_X_PRODUCT_OBJS = \
	../std/async/scheduler.o \
	../std/async/future.o \
	../std/channel/channel.o \
	../std/backtrace/backtrace.o \
	../std/uuid/uuid.o \
	../std/url/url.o \
	../std/security/security.o \
	../std/config/config.o \
	../std/cache/cache.o \
	../std/trace/trace.o \
	../std/task/task.o \
	../std/schema/schema.o \
	../std/db/kv/kv.o \
	../std/db/arrow/arrow.o \
	../std/db/sqlite/sqlite.o \
	../std/elf/elf.o \
	../std/regex/regex.o \
	../std/unicode/unicode.o \
	../std/socketio/socketio.o \
	../std/simd/simd.o
