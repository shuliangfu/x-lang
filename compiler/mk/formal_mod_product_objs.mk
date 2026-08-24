# formal_mod_product_objs.mk — wave894 B7B formal_mod product edges list→mk
#
# G.7: make-graph inventory only. Compile body authority remains
#   scripts/xlang_compile_std_module.sh ensure (wave812 catalog + wave826 mtime).
# PLATFORM: SHARED — portable product .o paths from compiler/ cwd.
#
# NOT physical delete. Residual after: thin edges + B2 try-heat + other
# mk lists hybrid + tip Windows → dual L4 → explicit auth ship delete.
#
# Consumers: Makefile multi-target FORCE thin ensure; std-objs via STD_AND_PANIC_O
# still lists overlapping members (wave813); this list is formal_mod-only.

FORMAL_MOD_PRODUCT_OBJS = \
	../std/string/string.o \
	../std/heap/heap.o \
	../std/heap/page_mmap.o \
	../std/sys/sys.o \
	../std/sys/linux.o \
	../std/sys/macos.o \
	../core/mem/mem.o \
	../core/builtin/builtin.o \
	../core/types/types.o \
	../core/option/option.o \
	../core/result/result.o \
	../core/debug/debug.o \
	../core/slice/mod.o \
	../core/str/mod.o \
	../core/iterator/mod.o \
	../std/bytes/bytes.o \
	../std/map/map.o \
	../std/set/set.o \
	../std/vec/vec.o \
	../std/thread/thread.o \
	../std/time/time.o \
	../std/random/random.o \
	../std/env/env.o \
	../std/fs/fs.o \
	../std/sync/sync.o \
	../std/queue/queue.o \
	../std/encoding/encoding.o \
	../std/base64/base64.o \
	../std/crypto/crypto.o \
	../std/log/log.o \
	../std/test/test.o \
	../std/atomic/atomic.o \
	../std/hash/hash.o \
	../std/math/math.o \
	../std/sort/sort.o \
	../std/ffi/ffi.o \
	../std/context/context.o \
	../std/error/error.o \
	../std/json/json.o \
	../std/csv/csv.o \
	../std/cli/cli.o \
	../std/config/config.o \
	../std/datetime/datetime.o \
	../std/db/sqlite/sqlite.o \
	../std/db/kv/kv.o \
	../std/db/arrow/arrow.o \
	../std/dynlib/dynlib.o \
	../std/http/http.o \
	../std/tar/tar.o \
	../std/unicode/unicode.o \
	../std/channel/channel.o \
	../std/runtime/runtime.o \
	../std/backtrace/backtrace.o \
	../core/assert/assert.o \
	../std/fmt/fmt.o \
	../std/compress/compress.o \
	../std/io/driver.o \
	../std/io/io.o \
	../std/debug/debug.o \
	../std/simd/simd.o \
	../std/async/async.o

