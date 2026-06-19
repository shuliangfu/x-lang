# Shux 编译器（compiler）构建
# 【推荐】日常/朝 Zig 对齐：在 compiler 目录用 ../build.sx 驱动的 build_tool — ./build_tool ./shux 或 ./build_tool ./shux asm（见 build.sx 顶注释「去掉 Makefile 的爬梯」）。
# 【build-tool / first-time】仅依赖 shux-c（OBJS_CORE）。lsp_*_gen / driver_gen / preprocess_gen：前置仍要 shux-c（冷启动）；recipe 内在已有 ./shux-sx 时改用 .sx codegen（无前置 shux-sx，避免 seed 依赖环）。
# 【兜底/可选】本 Makefile 用于：从零构建、与历史 CI 兼容、或尚未迁走的 test 目标。
# 阶段 1：main.c + lexer，产出 shux；阶段 8：可选 OPT=1 为 shux 启用 -O2
#
# 【生成 C 后无补丁】-E 产出 pipeline_gen.c / driver_gen.c 后不再做 sed/awk/perl/echo 后处理。
# pipeline_gen.c：包装/size/debug 由 runtime.c 在 -E 且入口为 pipeline.sx 时追加 pipeline_glue.c 到 stdout，Makefile 不修改生成文件。
# driver_gen.c：仅由 -E -E-extern 生成；run_compiler_c 在 runtime.c 定义；字段 ->、written 比较等已在 codegen/main.sx 从根源修。

CC      ?= cc
CFLAGS  ?= -Wall -Wextra -I. -Iinclude -Isrc
# 仅编译 pipeline_gen.c / driver_gen.c 等生成代码时加：静默已知警告，使 bootstrap-driver 整次 0 警告
# GCC 不识别 -Wno-logical-op-parentheses / -Wno-bitwise-op-parentheses / -Wno-incompatible-pointer-types-discards-qualifiers，会出 cc1 note；仅 Clang 追加
PIPELINE_GEN_CFLAGS_BASE = -Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits
PIPELINE_GEN_CFLAGS_CLANG = -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses -Wno-incompatible-pointer-types-discards-qualifiers
CC_IS_CLANG := $(findstring clang,$(shell $(CC) -v 2>&1))
PIPELINE_GEN_CFLAGS = $(PIPELINE_GEN_CFLAGS_BASE) $(if $(CC_IS_CLANG),$(PIPELINE_GEN_CFLAGS_CLANG))
# 阶段 8：make OPT=1 时为 shux 启用 -O2，便于开发时快速运行测试
ifeq ($(OPT),1)
  CFLAGS += -O2
endif
# 宿主 OS/架构（runtime_panic / freestanding / crt0 规则共用）
UNAME_S := $(shell uname -s 2>/dev/null || echo Unknown)
UNAME_M := $(shell uname -m 2>/dev/null || echo unknown)
ALPINE := $(shell test -f /etc/alpine-release && echo 1)
TARGET  = shux
SRCS    = src/main.c src/runtime.c src/preprocess.c src/lexer/lexer.c src/ast/ast.c src/parser/parser.c src/typeck/typeck.c src/codegen/codegen.c src/async/async_liveness.c src/async/async_cps_codegen.c
# OBJS_CORE：仅 C 前端 + pipeline 等；完整 shux 日后可 OBJS=$(OBJS_CORE) $(LSP_GEN_OBJS)，shux-c 仍链 CORE，避免与 -E 生成 lsp_gen 的规则循环依赖。
OBJS_CORE = src/main.o src/runtime.o src/driver/fmt_check_cmd.o src/preprocess.o src/lexer/lexer.o src/ast/ast.o src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o src/async/async_liveness.o src/async/async_cps_codegen.o src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes.o
OBJS      = $(OBJS_CORE)
# 注：lsp.sx 生成的 lsp_gen 与 lsp_diag 中 lsp_build_* 同名；若把 InitializeResult/response 外壳迁入 .sx，
# 默认 shux 须链 lsp_sx.o、lsp_io_sx.o 及 ../std/io/io.o、../std/heap/heap.o，且 shux-c 链接须用不含 LSP .o 的子集以免与生成 lsp_gen 的规则循环依赖；见 src/lsp/lsp_diag.c 头注释。

# C 仅版 shux：无 main_sx/pipeline_sx，供 bootstrap-pipeline 用 -E 生成 pipeline_gen.c（避免用已链 main_sx 的 $(TARGET) 导致走 .sx 路径失败）
SHUX_C = shux-c
# bootstrap-driver-seed 末尾 `cp $(TARGET)` 得到；不作为 lsp_*_gen.c / driver_gen / preprocess_gen 的 Makefile 前置（否则与 seed 依赖环）。
# -E/-E-extern 生成时在 recipe 内 `test -f shux-sx`：冷启动仅用 shux-c；二次构建起用 shux-sx（pipeline+codegen.sx），使 LSP 生成 C 与 codegen.sx 的自动 extern 一致。
SHUX_SX = shux-sx
# 与既有 shux-c 命令行一致的 -L（lsp/*.sx -E；-L src 仅限 main.sx / driver_gen）
LSP_SU_E_DIRS = -L .. -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess
MAIN_SX_E_DIRS = -L .. -L src -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess
# main.sx -E-extern 直接 import 的模块；变更须重生成 driver_gen.c / driver_sx.o
MAIN_SX_DEPS = src/main.sx src/codegen/codegen.sx src/ast/ast.sx src/preprocess/preprocess.sx
# preprocess.sx 独立 -E-extern 入口
PREPROCESS_SX_DEPS = src/preprocess/preprocess.sx
.PHONY: all clean test size-baseline perf-baseline bootstrap-token bootstrap-lexer bootstrap-parser bootstrap-parse-file bootstrap-typeck bootstrap-codegen bootstrap-driver bootstrap-driver-seed bootstrap-driver-bstrict bootstrap-driver-crt0 bootstrap-driver-asm bootstrap-driver-asm-only bootstrap-asm check-asm-o-quality check-6.4 bootstrap-self check-7.2 check-7.2-bstrict bootstrap-verify bootstrap-verify-seed bootstrap-verify-bstrict bootstrap-verify-stage2 bootstrap-verify-stage2-bstrict bootstrap-test build-tool build-tool-sx build-via-tool first-time verify-selfhost-stage2 regen-lsp-gens-sx shux-no-c-frontend gen-sx-driver-objs build-user-asm-backend build-seed-user-asm-partial bootstrap-driver-seed-user-asm compile_commands.json

# 舒 IO 后端（分析/舒IO实现路线图.md 阶段 1）：源码在 std/io/io.c；产出 ../std/io/io.o。
../std/io/io.o: ../std/io/io.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.fs 高性能：mmap/munmap（std/fs/fs.c）；链接用户程序时由 runtime.c 链入 ../std/fs/fs.o。
../std/fs/fs.o: ../std/fs/fs.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.process：argc/argv/getenv（std/process/process.c）；链接用户程序时由 runtime.c 链入 ../std/process/process.o。
../std/process/process.o: ../std/process/process.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.string：长串快路径 memcmp/memmem（std/string/string.c）；链接用户程序时由 runtime.c 链入 ../std/string/string.o。
../std/string/string.o: ../std/string/string.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.heap：堆分配 malloc/free/realloc（std/heap/heap.c）；供 std.vec、std.map 等使用。
../std/heap/heap.o: ../std/heap/heap.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.path：平台主分隔符 path_sep_c（std/path/path.c）；供 std.path path_sep() 使用。
../std/path/path.o: ../std/path/path.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.runtime：panic/abort 对接 shux_panic_（std/runtime/runtime.c）；链接时需与 runtime_panic.o 同链。
../std/runtime/runtime.o: ../std/runtime/runtime.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.net：TCP socket（std/net/net.c）；链接用户程序时由 runtime.c 链入 ../std/net/net.o。
# TLS：net-o-openssl 启用 SHUX_NET_USE_OPENSSL（OpenSSL 头路径自动回退 Homebrew）。
../std/net/net.o: ../std/net/net.c ../std/net/ws.inc.c ../std/net/tls_stub.inc.c
	$(CC) $(CFLAGS) -c -o $@ $<

net-o-openssl: ../std/net/net.c
	@if $(CC) $(CFLAGS) -DSHUX_NET_USE_OPENSSL -c -o ../std/net/net.o $< 2>/dev/null; then \
	  echo "net-o-openssl: system OpenSSL"; \
	else \
	  $(CC) $(CFLAGS) -I/opt/homebrew/opt/openssl/include -DSHUX_NET_USE_OPENSSL -c -o ../std/net/net.o $<; \
	fi

net-o-stub: ../std/net/net.c
	$(CC) $(CFLAGS) -c -o ../std/net/net.o ../std/net/net.c

net-o-mbedtls: ../std/net/net.c
	@if $(CC) $(CFLAGS) -DSHUX_NET_USE_MBEDTLS -I/opt/homebrew/opt/mbedtls/include -c -o ../std/net/net.o $< 2>/dev/null; then \
	  echo "net-o-mbedtls: homebrew mbedtls"; \
	else \
	  $(CC) $(CFLAGS) -DSHUX_NET_USE_MBEDTLS -c -o ../std/net/net.o $<; \
	fi

# std.thread：线程（std/thread/thread.c）；链接时由 runtime.c 链入 ../std/thread/thread.o，Unix 需 -lpthread。
../std/thread/thread.o: ../std/thread/thread.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.async：协作调度 ping-pong（std/async/scheduler.c）；import std.async 且调用 coop_pingpong* 时链入。
../std/async/scheduler.o: ../std/async/scheduler.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.async：Future/Poll 手动运行时（std/async/future.c）；future_* 烟测链入。
../std/async/future.o: ../std/async/future.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.time：单调/墙钟、sleep（std/time/time.c）；链接用户程序时由 runtime.c 链入 ../std/time/time.o。
../std/time/time.o: ../std/time/time.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.random：密码学安全随机（std/random/random.c）；链接用户程序时由 runtime.c 链入 ../std/random/random.o。
../std/random/random.o: ../std/random/random.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.env：环境变量与临时目录（std/env/env.c）；链接用户程序时由 runtime.c 链入 ../std/env/env.o。
../std/env/env.o: ../std/env/env.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.sync：互斥锁（std/sync/sync.c）；链接用户程序时由 runtime.c 链入 ../std/sync/sync.o；Unix 需 -lpthread。
../std/sync/sync.o: ../std/sync/sync.c
# std.queue：STD-048 并发烟测（std/queue/queue.c）；Unix 需 -lpthread。
../std/queue/queue.o: ../std/queue/queue.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.encoding：UTF-8/ASCII（std/encoding/encoding.c）
../std/encoding/encoding.o: ../std/encoding/encoding.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.base64：Base64 编解码（std/base64/base64.c）
../std/base64/base64.o: ../std/base64/base64.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.crypto：SHA-256/512、HMAC（std/crypto/crypto.c）
../std/crypto/crypto.o: ../std/crypto/crypto.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.log：日志 stderr（std/log/log.c）
../std/log/log.o: ../std/log/log.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.test：测试断言（std/test/test.c）
../std/test/test.o: ../std/test/test.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.atomic：原子操作（std/atomic/atomic.c）；链接用户程序时由 runtime.c 链入 ../std/atomic/atomic.o。
../std/atomic/atomic.o: ../std/atomic/atomic.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.channel：有界/无界 channel（std/channel/channel.c）；链接时由 runtime.c 链入；Unix 需 -lpthread。
../std/channel/channel.o: ../std/channel/channel.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.backtrace：调用栈捕获（std/backtrace/backtrace.c）；链接时由 runtime.c 链入。
../std/backtrace/backtrace.o: ../std/backtrace/backtrace.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.hash：SipHash-2-4 Hasher（std/hash/hash.c）；链接时由 runtime.c 链入。
../std/hash/hash.o: ../std/hash/hash.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.math：数学常量与函数（std/math/math.c）；链接时由 runtime.c 链入，需 -lm。
../std/math/math.o: ../std/math/math.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.sort：排序（std/sort/sort.c）；链接时由 runtime.c 链入。
../std/sort/sort.o: ../std/sort/sort.c
	$(CC) $(CFLAGS) -c -o $@ $<

# core.builtin：位运算热路径（core/builtin/builtin.c）；按需链入（CORE-009）。
../core/builtin/builtin.o: ../core/builtin/builtin.c
	$(CC) $(CFLAGS) -c -o $@ $<

# core.mem：volatile/fence（core/mem/mem.c）；按需链入（CORE-017）。
../core/mem/mem.o: ../core/mem/mem.c
	$(CC) $(CFLAGS) -c -o $@ $<

# core.slice：subslice 视图构造（core/slice/slice.c）；按需链入（CORE-004/157）。
../core/slice/slice.o: ../core/slice/slice.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.ffi：C 字符串互操作（std/ffi/ffi.c）；链接时由 runtime.c 链入。
../std/ffi/ffi.o: ../std/ffi/ffi.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.context：取消/超时/deadline 传播（std/context/context.c）；链接时由 runtime.c 链入。
../std/context/context.o: ../std/context/context.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.datetime：RFC3339/DateTime/Duration（std/datetime/datetime.c）；依赖 std/time/time.o。
../std/datetime/datetime.o: ../std/datetime/datetime.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.uuid：UUID v4/v7（std/uuid/uuid.c）；依赖 random.o + time.o。
../std/uuid/uuid.o: ../std/uuid/uuid.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.url：URL parse/build/query（std/url/url.c）。
../std/url/url.o: ../std/url/url.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.cli：命令行解析（std/cli/cli.c）。
../std/cli/cli.o: ../std/cli/cli.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.security：HKDF / secure_zero / mlock（std/security/security.c）。
../std/security/security.o: ../std/security/security.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.config：分层配置 TOML/ENV（std/config/config.c）；依赖 std/env/env.o。
../std/config/config.o: ../std/config/config.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.cache：LRU/TTL 缓存与对象池（std/cache/cache.c）；依赖 std/time/time.o。
../std/cache/cache.o: ../std/cache/cache.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.trace：Span 追踪（std/trace/trace.c）；依赖 std/time + std/random。
../std/trace/trace.o: ../std/trace/trace.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.task：TaskGroup/JoinSet（std/task/task.c）；依赖 scheduler + context + time。
../std/task/task.o: ../std/task/task.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.schema：typed decode/validate（std/schema/schema.c）；依赖 json + csv。
../std/schema/schema.o: ../std/schema/schema.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.db.kv：mmap LSM Append-Only KV（std/db/kv/kv.c）
../std/db/kv/kv.o: ../std/db/kv/kv.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.db.arrow：列式零拷贝内存（std/db/arrow/arrow.c）
../std/db/arrow/arrow.o: ../std/db/arrow/arrow.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.sys.mmap：MAP_SHARED 可写映射（std/sys/mmap.inc.c）
../std/sys/mmap.o: ../std/sys/mmap.inc.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.sys.win32：kernel32 WriteFile（std/sys/win32.inc.c）
../std/sys/win32.o: ../std/sys/win32.inc.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.sqlite：默认 SQLite3 后端（std/db/sqlite/sqlite.c）；无 libsqlite3 时用 sqlite-o-stub。
../std/db/sqlite/sqlite.o: ../std/db/sqlite/sqlite.c
	$(CC) $(CFLAGS) -DSHUX_DB_USE_SQLITE3 -c -o $@ $<
sqlite-o: ../std/db/sqlite/sqlite.o
sqlite-o-stub: ../std/db/sqlite/sqlite.c
	$(CC) $(CFLAGS) -c -o ../std/db/sqlite/sqlite.o ../std/db/sqlite/sqlite.c

# std.elf：ELF64 只读解析（std/elf/elf.c）；链接时由 runtime.c 链入。
../std/elf/elf.o: ../std/elf/elf.c
	$(CC) $(CFLAGS) -c -o $@ $<

# P4 std 模块（按需链接）
../std/json/json.o: ../std/json/json.c
	$(CC) $(CFLAGS) -c -o $@ $<
../std/csv/csv.o: ../std/csv/csv.c
	$(CC) $(CFLAGS) -c -o $@ $<
../std/regex/regex.o: ../std/regex/regex.c
	$(CC) $(CFLAGS) -c -o $@ $<
../std/compress/zlib/zlib.o: ../std/compress/zlib/zlib.c
	$(CC) $(CFLAGS) -c -o $@ $<
../std/compress/gzip/gzip.o: ../std/compress/gzip/gzip.c
	$(CC) $(CFLAGS) -c -o $@ $<
../std/compress/brotli/brotli.o: ../std/compress/brotli/brotli.c
	$(CC) $(CFLAGS) -c -o $@ $<
../std/compress/zstd/zstd.o: ../std/compress/zstd/zstd.c
	$(CC) $(CFLAGS) -c -o $@ $<
COMPRESS_PARTS = ../std/compress/zlib/zlib.o ../std/compress/gzip/gzip.o ../std/compress/brotli/brotli.o ../std/compress/zstd/zstd.o
../std/compress/compress.o: $(COMPRESS_PARTS)
	$(LD) -r -o $@ $(COMPRESS_PARTS)
# 可选：启用 zlib 的 compress.o，用于 tests/run-compress.sh 测试 gzip
compress-o-zlib:
	$(CC) $(CFLAGS) -DSHUX_USE_ZLIB -c -o ../std/compress/zlib/zlib.o ../std/compress/zlib/zlib.c
	$(CC) $(CFLAGS) -DSHUX_USE_ZLIB -c -o ../std/compress/gzip/gzip.o ../std/compress/gzip/gzip.c
	$(CC) $(CFLAGS) -c -o ../std/compress/brotli/brotli.o ../std/compress/brotli/brotli.c
	$(CC) $(CFLAGS) -c -o ../std/compress/zstd/zstd.o ../std/compress/zstd/zstd.c
	$(LD) -r -o ../std/compress/compress.o $(COMPRESS_PARTS)
# 可选：启用 zlib + zstd，用于 STD-007 gzip/zstd 往返烟测
compress-o-zlib-zstd:
	$(CC) $(CFLAGS) -DSHUX_USE_ZLIB -DSHUX_USE_ZSTD -c -o ../std/compress/zlib/zlib.o ../std/compress/zlib/zlib.c
	$(CC) $(CFLAGS) -DSHUX_USE_ZLIB -DSHUX_USE_ZSTD -c -o ../std/compress/gzip/gzip.o ../std/compress/gzip/gzip.c
	$(CC) $(CFLAGS) -c -o ../std/compress/brotli/brotli.o ../std/compress/brotli/brotli.c
	$(CC) $(CFLAGS) -DSHUX_USE_ZSTD -c -o ../std/compress/zstd/zstd.o ../std/compress/zstd/zstd.c
	$(LD) -r -o ../std/compress/compress.o $(COMPRESS_PARTS)
# 可选：启用 Brotli（STD-125）；链接时加 -lbrotlienc -lbrotlidec
compress-o-brotli:
	$(CC) $(CFLAGS) -c -o ../std/compress/zlib/zlib.o ../std/compress/zlib/zlib.c
	$(CC) $(CFLAGS) -c -o ../std/compress/gzip/gzip.o ../std/compress/gzip/gzip.c
	$(CC) $(CFLAGS) -DSHUX_USE_BROTLI -c -o ../std/compress/brotli/brotli.o ../std/compress/brotli/brotli.c
	$(CC) $(CFLAGS) -c -o ../std/compress/zstd/zstd.o ../std/compress/zstd/zstd.c
	$(LD) -r -o ../std/compress/compress.o $(COMPRESS_PARTS)
# 可选：zlib + zstd + Brotli 全格式（STD-125 推荐矩阵）
compress-o-zlib-zstd-brotli:
	$(CC) $(CFLAGS) -DSHUX_USE_ZLIB -c -o ../std/compress/zlib/zlib.o ../std/compress/zlib/zlib.c
	$(CC) $(CFLAGS) -DSHUX_USE_ZLIB -c -o ../std/compress/gzip/gzip.o ../std/compress/gzip/gzip.c
	$(CC) $(CFLAGS) -DSHUX_USE_BROTLI -c -o ../std/compress/brotli/brotli.o ../std/compress/brotli/brotli.c
	$(CC) $(CFLAGS) -DSHUX_USE_ZSTD -c -o ../std/compress/zstd/zstd.o ../std/compress/zstd/zstd.c
	$(LD) -r -o ../std/compress/compress.o $(COMPRESS_PARTS)
../std/unicode/unicode.o: ../std/unicode/unicode.c
	$(CC) $(CFLAGS) -c -o $@ $<
../std/dynlib/dynlib.o: ../std/dynlib/dynlib.c
	$(CC) $(CFLAGS) -c -o $@ $<
../std/http/http.o: ../std/http/http.c
	$(CC) $(CFLAGS) -c -o $@ $<

# std.socketio：Engine.IO / Socket.IO 包编解码（P3 可选，按需链入，非 STD_AND_PANIC_O 默认集）。
../std/socketio/socketio.o: ../std/socketio/socketio.c
	$(CC) $(CFLAGS) -c -o $@ $<
../std/tar/tar.o: ../std/tar/tar.c
	$(CC) $(CFLAGS) -c -o $@ $<
../std/simd/simd.o: ../std/simd/simd.c
	$(CC) $(CFLAGS) -c -o $@ $<

# 测试与 shux 链接 std 时依赖的 .o：所有 std 模块 + runtime_panic.o；Linux 另预编 freestanding 链入桩
STD_AND_PANIC_O = ../std/io/io.o ../std/fs/fs.o ../std/process/process.o ../std/string/string.o ../std/heap/heap.o ../std/path/path.o ../std/runtime/runtime.o ../std/net/net.o ../std/thread/thread.o ../std/time/time.o ../std/random/random.o ../std/env/env.o ../std/sync/sync.o ../std/encoding/encoding.o ../std/base64/base64.o ../std/crypto/crypto.o ../std/log/log.o ../std/atomic/atomic.o ../std/channel/channel.o ../std/backtrace/backtrace.o ../std/hash/hash.o ../std/math/math.o ../std/sort/sort.o ../std/ffi/ffi.o ../std/json/json.o ../std/csv/csv.o ../std/regex/regex.o ../std/compress/compress.o ../std/unicode/unicode.o ../std/dynlib/dynlib.o ../std/http/http.o ../std/tar/tar.o ../std/simd/simd.o ../std/test/test.o runtime_panic.o runtime_asm_io_stubs.o
ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
STD_AND_PANIC_O += crt0_user.o freestanding_io.o
endif
endif

# 同时链出 shux-c：与 pipeline/lsp/build_gen 的 -E 生成及 test_c 前置一致，避免仅 make all 后缺少 shux-c。
# SHUX_RUN_ALL_BOOTSTRAP_SHUX=1：run-all 显式 SHUX=seed 时子脚本 `make -C compiler` 须保持 bootstrap 链，禁止 C-only all 覆盖 shux。
ifeq ($(SHUX_RUN_ALL_BOOTSTRAP_SHUX),1)
all: bootstrap-driver-seed
else
all: $(TARGET) $(SHUX_C) $(STD_AND_PANIC_O)
endif

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

$(SHUX_C): $(OBJS_CORE)
	$(CC) $(CFLAGS) -o $@ $^

src/main.o: src/main.c
	$(CC) $(CFLAGS) -c -o $@ $<

# 6.3：runtime.c 提供 run_compiler_c 与弱符号 main_entry；带 .sx 入口时用 runtime_driver.o（含 driver_*/pipeline_*）
src/runtime.o: src/runtime.c
	$(CC) $(CFLAGS) -c -o $@ $<
# Makefile 为 prerequisite：编译宏（如 SHUX_USE_SX_PREPROCESS）变更时须重编，否则 runtime_driver.o 缺 preprocess() 导致链接 Undefined _preprocess。
src/runtime_driver.o: src/runtime.c Makefile
	$(CC) $(CFLAGS) -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_PREPROCESS -c -o $@ $<
# shux_sx 用：仅 -DSHUX_USE_SX_PIPELINE，提供 asm_codegen_ast、pipeline_parse_into_buf、main_entry（弱符号）等
src/runtime_sx.o: src/runtime.c
	$(CC) $(CFLAGS) -DSHUX_USE_SX_PIPELINE -c -o $@ $<

src/driver/fmt_check_cmd.o: src/driver/fmt_check_cmd.c
	$(CC) $(CFLAGS) -c -o $@ $<

src/driver/fmt_check_cmd_driver.o: src/driver/fmt_check_cmd.c
	$(CC) $(CFLAGS) -DSHUX_USE_SX_PIPELINE -c -o $@ $<

src/preprocess.o: src/preprocess.c src/preprocess.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/lexer/lexer.o: src/lexer/lexer.c src/lexer/lexer.h include/token.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/ast/ast.o: src/ast/ast.c include/ast.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/parser/parser.o: src/parser/parser.c src/parser/parser.h src/lexer/lexer.h include/ast.h include/token.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/typeck/typeck.o: src/typeck/typeck.c src/typeck/typeck.h include/ast.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/codegen/codegen.o: src/codegen/codegen.c src/codegen/codegen.h include/ast.h src/lsp/lsp_codegen_extern.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/lsp/lsp_codegen_extern.o: src/lsp/lsp_codegen_extern.c src/lsp/lsp_codegen_extern.h
	$(CC) $(CFLAGS) -c -o $@ $<

# SHUX_NO_C_FRONTEND 实验链接：满足 pipeline 对 codegen_set_* 的引用，无 codegen.c
src/codegen/codegen_pipeline_stubs.o: src/codegen/codegen_pipeline_stubs.c include/ast.h src/codegen/codegen.h
	$(CC) $(CFLAGS) -c -o $@ $<

# 与 runtime 中 SHUX_USE_SX_PREPROCESS 配对，仅导出 preprocess_c_fallback
src/preprocess_for_driver.o: src/preprocess.c src/preprocess.h Makefile
	$(CC) $(CFLAGS) -DSHUX_USE_SX_PREPROCESS -c -o $@ $<

# runtime.c：不引用 C lexer/parser/typeck/codegen（见 SHUX_NO_C_FRONTEND 包裹的 load_one_import 等）
src/runtime_driver_no_c.o: src/runtime.c Makefile
	$(CC) $(CFLAGS) -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_PREPROCESS -DSHUX_NO_C_FRONTEND -c -o $@ $<

# shux_sx 使用带 -DSHUX_USE_SX_PIPELINE 编译的 main，否则 #ifdef 块不会生效
src/main_sx.o: src/main.c
	$(CC) $(CFLAGS) -DSHUX_USE_SX_PIPELINE -c -o $@ $<

PIPELINE_OBJS = src/main_sx.o src/runtime_sx.o src/preprocess.o src/lexer/lexer.o src/ast/ast_seed.o src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o
# shux_sx：pipeline_sx.o 编排 typeck_sx/codegen_sx（非 C typeck.o/codegen.o）。
PIPELINE_SX_BASE_OBJS = src/main_sx.o src/runtime_sx.o src/preprocess.o src/lexer/lexer.o src/ast/ast_seed.o src/parser/parser.o
PIPELINE_SX_FRONTEND_OBJS = typeck_sx.o codegen_sx.o typeck_sx_link_alias.o codegen_sx_link_alias.o
# parser_sx / seed partial / C typeck·codegen·bridge + 卫星 .o（对齐 DRIVER_SEED_OBJS 除 main_sx/runtime_sx 外的链接依赖）。
# fmt_check_cmd.o（非 _driver）：runtime_sx 无 SHUX_USE_SX_DRIVER，fmt/check 走 run_compiler_c 桩，避免缺 driver_run_compiler_full。
PIPELINE_SX_SATELLITE_OBJS = lexer_sx.o lexer_sx_link_alias.o preprocess_sx.o \
  src/driver/fmt_check_cmd.o src/driver/target_cpu.o \
  src/asm/simd_enc.o src/asm/simd_loop.o \
  src/async/async_liveness.o src/async/async_cps_codegen.o \
  src/std_fs_shim.o $(AST_POOL_L5_BRIDGE_O) src/lsp/lsp_codegen_extern.o
PIPELINE_SX_LINK_OBJS = parser_sx.o src/typeck/typeck.o src/codegen/codegen.o src/sx_seed_bridge.o pipeline_bootstrap_orchestration.o $(PIPELINE_SX_SATELLITE_OBJS) $(USER_ASM_LINK)
PIPELINE_SX_SUPPORT_OBJS = build-seed-asm-host $(PIPELINE_SX_LINK_OBJS)

# shux-sx-pipeline 链接了 ../std/io/io.o；Linux 下 io.c 使用 io_uring，需 -luring -lpthread（见 std/io/io.c 头注释）
PIPELINE_LIBS :=
ifeq ($(UNAME_S),Linux)
  PIPELINE_LIBS := -luring -lpthread
endif

# asm 后端 -o <exe> 时链接用：提供 shux_panic_；Linux x86_64 有 .s 时用纯 syscall .s，否则 .c
RUNTIME_PANIC_S := $(wildcard src/asm/runtime_panic_x86_64.s)
ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
ifneq (,$(RUNTIME_PANIC_S))
runtime_panic.o: src/asm/runtime_panic_x86_64.s
	$(CC) -c -o $@ $<
else
runtime_panic.o: src/asm/runtime_panic.c
	$(CC) $(CFLAGS) -c -o $@ $<
endif
else
runtime_panic.o: src/asm/runtime_panic_arm64.c
	$(CC) $(CFLAGS) -c -o $@ $<
endif
else
runtime_panic.o: src/asm/runtime_panic.c
	$(CC) $(CFLAGS) -c -o $@ $<
endif

# seed asm 用户程序：std.io 跳过 .sx emit 时的 print/write/read_ptr 链接桩（见 runtime_asm_io_stubs.c）
runtime_asm_io_stubs.o: src/asm/runtime_asm_io_stubs.c
	$(CC) $(CFLAGS) -c -o $@ $<

# 无 C 自举：crt0 提供 _start 与 driver_get_argv_i（仅 Linux x86_64）；链接 asm 版 shux 时用本 .o 替代 main.o / runtime_asm_build.o
ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
src/asm/crt0_x86_64.o: src/asm/crt0_x86_64.s
	$(CC) -c -o $@ $<
# S4 freestanding 用户程序入口（call _main；见 tests/run-freestanding-hello.sh）
src/asm/crt0_user_x86_64.o: src/asm/crt0_user_x86_64.s
	$(CC) -c -o $@ $<
# S4 freestanding syscall write（shux_sys_write）
src/asm/freestanding_io_x86_64.o: src/asm/freestanding_io_x86_64.s
	$(CC) -c -o $@ $<
# runtime.c 链 freestanding 用户程序时在 compiler/ 下查找 crt0_user.o / freestanding_io.o
crt0_user.o: src/asm/crt0_user_x86_64.o
	cp $< $@
freestanding_io.o: src/asm/freestanding_io_x86_64.o
	cp $< $@
endif
endif

# asm 链接无 runtime_driver 时：提供 typeck_float64_bits_lo/hi。Linux x86_64 优先用 asm，否则 .c
ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
src/typeck/typeck_f64_bits.o: src/typeck/typeck_f64_bits_x86_64.s
	$(CC) -c -o $@ $<
else
src/typeck/typeck_f64_bits.o: src/typeck/typeck_f64_bits.c
	$(CC) $(CFLAGS) -c -o $@ $<
endif
else
src/typeck/typeck_f64_bits.o: src/typeck/typeck_f64_bits.c
	$(CC) $(CFLAGS) -c -o $@ $<
endif

clean:
	rm -f $(OBJS) src/main_driver.o src/runtime_driver.o src/runtime_driver_no_c.o src/runtime_sx.o src/main_sx.o src/ast/ast_seed.o src/preprocess_for_driver.o src/codegen/codegen_pipeline_stubs.o ../std/io/io.o ../std/fs/fs.o ../std/process/process.o ../std/string/string.o ../std/heap/heap.o ../std/runtime/runtime.o ../std/net/net.o ../std/thread/thread.o ../std/time/time.o ../std/random/random.o ../std/env/env.o ../std/sync/sync.o ../std/encoding/encoding.o ../std/base64/base64.o ../std/crypto/crypto.o ../std/log/log.o ../std/atomic/atomic.o ../std/channel/channel.o ../std/backtrace/backtrace.o ../std/hash/hash.o ../std/math/math.o ../std/sort/sort.o ../std/ffi/ffi.o ../std/json/json.o ../std/csv/csv.o ../std/regex/regex.o ../std/compress/compress.o ../std/unicode/unicode.o ../std/dynlib/dynlib.o ../std/http/http.o ../std/tar/tar.o ../std/test/test.o src/asm/runtime_asm_build.o src/asm/crt0_x86_64.o src/typeck/typeck_f64_bits.o src/lsp/lsp_state.o src/lsp/lsp_diag_pipeline_sizes.o lsp_io_sx.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_std_heap_sx.o lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c $(TARGET) shux-sx shux-no-c-frontend $(SHUX_C) $(TARGET)_stage1 $(TARGET)_stage2 $(TARGET)_su $(TARGET)_su_stage2 typeck_gen.c typeck_sx.o codegen_gen.c codegen_sx.o parser_gen.c parser_sx.o driver_gen.c driver_sx.o driver_fmt_gen.c driver_check_gen.c driver_test_gen.c driver_fmt_sx.o driver_check_sx.o driver_test_sx.o _stubs_driver.o pipeline_gen.c pipeline_sx.o typeck_sx_sx.c typeck_sx_sx.o codegen_sx_sx.c codegen_sx_sx.o build_gen.c build_runner_gen.c build_runtime_sx_gen.c build_tool.o build_runner.o build_runtime.o build_runtime_sx.o build_tool runtime_panic.o shux_asm preprocess_gen.c preprocess_sx.o
	rm -rf build_asm build build_final build_manual build_v5 build_v7
	rm -f bootstrap_shux shux_asm2 shux_sx_dbg shux_stage1_test a.out
	rm -f .lldb_* *.bak pipeline_gen.c.bak lsp_gen.c.bak
	rm -f 0 2>/dev/null || true
	@for f in _*; do \
	  case "$$f" in _stubs.c|_sx_stubs.c|_sx_stubs2.c|_stubs_driver.c) ;; *) rm -rf "$$f" ;; esac; \
	done 2>/dev/null || true
	find . -name '*.o' -delete 2>/dev/null || true
	find . -name '*.o.tmp' -delete 2>/dev/null || true
	rm -f test_perl.txt test_pre_out.s 2>/dev/null || true
	rm -f ../rvwbuf.tmp 2>/dev/null || true
	find . -name '*.sx.bak' -delete 2>/dev/null || true
	rm -rf tmp_bisect 2>/dev/null || true
	rm -f tmp_* 2>/dev/null || true

# 阶段 1 词法 + 阶段 3 类型检查 + …；依赖 shux 与全部 std .o、runtime_panic.o，clean 后 test 会先构建再跑脚本
# test_c：与 ../tests/run-all-c.sh 等价（C 版 shux-c 跑整份 run-all，不含自举专用脚本）
# test_sx：bootstrap-driver-seed + run-lsp + run-all-sx（.sx 流水线全量）
# 依赖 $(SHUX_C) 以便 make clean && make test_c 时 shux-c 存在
test_c: $(TARGET) $(SHUX_C) $(STD_AND_PANIC_O)
	@if [ -f ../tests/run-all-c.sh ]; then (cd .. && chmod +x tests/run-all-c.sh && ./tests/run-all-c.sh); else echo "tests/run-all-c.sh missing" >&2; exit 1; fi
	@echo "Test C OK"

# su 自举：bootstrap-driver-seed + LSP + 全量自举（run-all-sx：用 shux_sx 跑整份 run-all）
test_sx: bootstrap-driver-seed
	@if [ -f ../tests/run-lsp.sh ]; then (cd .. && chmod +x tests/run-lsp.sh && ./tests/run-lsp.sh); fi
	@if [ -f ../tests/run-all-sx.sh ]; then (cd .. && chmod +x tests/run-all-sx.sh && ./tests/run-all-sx.sh); fi
	@echo "Test SU OK"

# 全量：先 C 再 su 自举
test: test_c test_sx
	@echo "Test all OK"

# 自举 9.1：用 shux 编译 token 模块（库）+ token_standalone.sx（入口），验证 .sx 前端数据定义可由宿主编译
# 依赖 $(STD_AND_PANIC_O)：-o 链 std/io 等 .o，clean 后仅 make $(TARGET) 会缺这些文件导致 cc 失败。
bootstrap-token: $(TARGET) $(STD_AND_PANIC_O)
	./$(TARGET) -L src/lexer src/lexer/token_standalone.sx -o /tmp/shux_token_test && /tmp/shux_token_test && echo "bootstrap-token OK"

# 自举 9.1：用 shux 编译 lexer.sx（入口，import token），验证多文件 + 跨模块 enum 可编译链接
bootstrap-lexer: $(TARGET) $(STD_AND_PANIC_O)
	./$(TARGET) -L src/lexer src/lexer/lexer.sx -o /tmp/shux_lexer_test && /tmp/shux_lexer_test && echo "bootstrap-lexer OK"

# 自举 9.1：用 shux 编译 parser.sx（import lexer + token + ast + std.fs），解析 function main(): i32 { return 0; } 并验证；-L .. 供 std.fs，-L src/lexer 供 token，-L src/ast 供 ast
bootstrap-parser: $(TARGET) $(STD_AND_PANIC_O)
	rm -f /tmp/shux_parse_test.sx && ./$(TARGET) -L .. -L src/lexer -L src/ast src/parser/parser.sx -o /tmp/shux_parser_test && /tmp/shux_parser_test && echo "bootstrap-parser OK"

# 9.1 联调：.sx `parse()` 支持 return 字面量或 `parse_expr_into`（堆上大块 Arena，栈安全）；宿主 shux 走完整流水线。
# 第二段：`return (1 + 2) * 3 + -1`，.sx standalone 走 parse()→堆上 Arena→parse_expr_into；宿主 shux 走完整流水线。
bootstrap-parse-file: $(TARGET) $(STD_AND_PANIC_O) bootstrap-parser
	@printf 'function main(): i32 { return 0; }\0' > /tmp/shux_parse_test.sx && \
	/tmp/shux_parser_test && echo "su parser: parse OK (minimal)" && \
	(out=$$(./$(TARGET) -L .. /tmp/shux_parse_test.sx 2>&1); echo "$$out" | grep -q "parse OK") && echo "C parser: parse OK (minimal)" && \
	printf 'function main(): i32 { return (1 + 2) * 3 + -1; }\0' > /tmp/shux_parse_test.sx && \
	/tmp/shux_parser_test && echo "su parser: parse OK (expr-chain)" && \
	(out=$$(./$(TARGET) -L .. /tmp/shux_parse_test.sx 2>&1); echo "$$out" | grep -q "parse OK") && echo "C parser: parse OK (expr-chain)" && \
	echo "bootstrap-parse-file OK"

# 迁移到 .sx：parser.sx -E-extern + ast 池 getter 补丁 → parser_sx.o（提供 parser_parse_into_buf；与瘦 pipeline_sx.o 分 TU）。
# 须 shux-sx -sx -E 全量 TU；shux-c 瘦 gen 缺 copy_module_import_path64 / parse_expr_into 等。
parser_gen.c: $(SHUX_C) ast_gen2.c src/parser/parser.sx
	@if [ -f $(SHUX_SX) ]; then \
	  echo "parser_gen.c: ./$(SHUX_SX) -sx -E -E-extern ..." >&2; \
	  if ./$(SHUX_SX) -sx -E -L .. -L src/lexer -L src/ast -E-extern src/parser/parser.sx > $@ 2>/dev/null \
	     && grep -q 'parser_copy_module_import_path64' $@; then \
	    : ; \
	  else \
	    echo "parser_gen.c: shux-sx failed or thin output; fallback shux-c" >&2; \
	    ./$(SHUX_C) -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.sx > $@; \
	  fi; \
	else \
	  ./$(SHUX_C) -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.sx > $@; \
	fi
	perl -i -ne 'print unless /^struct shux_slice_uint8_t/ && $$seen++' $@ 2>/dev/null || true
	@if ! grep -q 'C-04 -E-extern TU aliases' $@ 2>/dev/null; then \
	  perl scripts/fix_slim_arena_gen_c.pl $@; \
	fi
	@if ! grep -q 'C-04 parser: ast_expr_init_match_enum after struct ast_Expr' $@ 2>/dev/null; then \
	  perl scripts/fix_parser_pool_access_gen_c.pl $@; \
	fi
	@if ! grep -q 'parser_copy_module_import_path64' $@; then \
	  echo "parser_gen.c: inject extern parser_copy_module_import_path64 (parser_asm_link_alias/thin_c)" >&2; \
	  printf '%s\n' '/* pipeline extern parser_copy_module_import_path64 (thin parser_gen TU) */' \
	    'extern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t out[64]);' >> $@; \
	fi
	@echo "parser_gen.c: from parser.sx (-E-extern, full TU via shux-sx -su)"
parser_sx.o: parser_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -Dstd_io_driver_driver_read_ptr_len=shux_io_read_ptr_len -Dstd_io_driver_driver_read_ptr=shux_io_read_ptr -c parser_gen.c -o parser_sx.o
	@echo "parser_sx.o OK"

# lexer.sx：须 shux-sx -sx -E 走 C parser/codegen 全量 TU；shux-c 无 -sx 时仅 ~57 行缺 advance_one/next_body。
lexer_gen.c: $(SHUX_C) src/lexer/lexer.sx
	@if [ -f $(SHUX_SX) ]; then \
	  echo "lexer_gen.c: ./$(SHUX_SX) -sx -E -E-extern ..." >&2; \
	  if ./$(SHUX_SX) -sx -E -L src/lexer -E-extern src/lexer/lexer.sx > $@ 2>/dev/null \
	     && grep -q 'lexer_advance_one' $@; then \
	    : ; \
	  else \
	    echo "lexer_gen.c: shux-sx failed or thin output; fallback shux-c" >&2; \
	    ./$(SHUX_C) -L src/lexer -E -E-extern src/lexer/lexer.sx > $@; \
	  fi; \
	else \
	  ./$(SHUX_C) -L src/lexer -E -E-extern src/lexer/lexer.sx > $@; \
	fi
	perl scripts/fix_slim_arena_gen_c.pl $@
	@grep -q 'lexer_advance_one' $@ || (echo "lexer_gen.c: missing lexer_advance_one (need shux-sx -sx -E)" >&2; exit 1)
	@echo "lexer_gen.c: from lexer.sx (-E-extern, full TU via shux-sx -su)"

lexer_sx.o: lexer_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c lexer_gen.c -o lexer_sx.o
	@echo "lexer_sx.o OK"

src/sx_seed_bridge.o: src/sx_seed_bridge.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/std_fs_shim.o: src/std_fs_shim.c
	$(CC) $(CFLAGS) -I. -c -o $@ $<

src/std_sys_shim.o: src/std_sys_shim.c
	$(CC) $(CFLAGS) -I. -c -o $@ $<

# pipeline_sx.o 仍引用 typeck_typeck_* / codegen_codegen_*；typeck_sx.o 导出 typeck_* / codegen_*。
typeck_sx_link_alias.o: typeck_sx_link_alias.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<
codegen_sx_link_alias.o: codegen_sx_link_alias.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<
lexer_sx_link_alias.o: lexer_sx_link_alias.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<
# seed shux 用户程序 -backend asm：shux-c -E 编出的 backend/peephole/platform + user_asm_seed_bridge（无 weak 桩、无 C 回退）
USER_ASM_SEED_HOST_DIR = build_asm/seed_host
USER_ASM_SEED_HOST_OBJS = $(USER_ASM_SEED_HOST_DIR)/asm_backend_partial.o
USER_ASM_SEED_OBJS = src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o src/asm/pipeline_abi_f32_xmm.o parser_asm_thin_glue.o parser_asm_link_alias.o src/asm/parser_asm_parse_expr_link.o
USER_ASM_LINK = $(USER_ASM_SEED_HOST_OBJS) $(USER_ASM_SEED_OBJS)

.PHONY: build-seed-asm-host
# partial export 须先 nm dispatch .o 剔除重复符号；冷启动时 dispatch 可能尚未编译。
.PHONY: parser-legacy-text-o
parser-legacy-text-o:
	@chmod +x scripts/extract_parser_legacy_text.sh 2>/dev/null || true
	@./scripts/extract_parser_legacy_text.sh

build-seed-asm-host: src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o src/asm/pipeline_abi_f32_xmm.o
	@chmod +x scripts/build_seed_asm_host.sh 2>/dev/null || true
	@./scripts/build_seed_asm_host.sh

$(USER_ASM_SEED_HOST_OBJS): build-seed-asm-host

src/asm/user_asm_seed_bridge.o: src/asm/user_asm_seed_bridge.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/asm/asm_backend_compat_stubs.o: src/asm/asm_backend_compat_stubs.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/asm/backend_enc_dispatch.o: src/asm/backend_enc_dispatch.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/asm/backend_arch_emit_dispatch.o: src/asm/backend_arch_emit_dispatch.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/asm/backend_try_inline_dispatch.o: src/asm/backend_try_inline_dispatch.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/asm/backend_call_dispatch.o: src/asm/backend_call_dispatch.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/asm/pipeline_abi_f32_xmm.o: src/asm/pipeline_abi_f32_xmm.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# parser EMIT_HEAVY thin delegate C 目标：bootstrap shux 须链入，extern bl 白名单 emit 才不 segfault。
# 全量 parser_sx.o 已含 parse_into_buf / get_module_* 等；禁 seed slice 与重复前缀符号。
PARSER_ASM_THIN_GLUE_CFLAGS = -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE
PARSER_ASM_LINK_ALIAS_CFLAGS = -DPARSER_ASM_LINK_ALIAS_SKIP_SU_SYMBOLS
parser_asm_thin_glue.o: src/asm/parser_asm_thin_c.c
	$(CC) $(CFLAGS) $(PARSER_ASM_THIN_GLUE_CFLAGS) -I. -Iinclude -Isrc -Isrc/lexer -c -o $@ $<

# pipeline parser_* 前缀 alias + parse 弱裸名桩（seed ./shux 与 experimental bootstrap 共用）。
parser_asm_link_alias.o: src/asm/parser_asm_link_alias.c
	$(CC) $(CFLAGS) $(PARSER_ASM_LINK_ALIAS_CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/asm/parser_asm_parse_expr_link.o: src/asm/parser_asm_parse_expr_link.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/asm/asm_experimental_symbol_bridge.o: src/asm/asm_experimental_symbol_bridge.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# 迁移到 .sx：parser/typeck/codegen 独立 -E-extern 产物；pipeline_sx.o 仅编排（-E-extern），seed 链 typeck_sx.o/codegen_sx.o。
migrate-sx-objs: parser_sx.o typeck_sx.o codegen_sx.o
	@echo "migrate-sx-objs OK (parser_sx.o typeck_sx.o codegen_sx.o 已就绪)"

# ast_gen2.c：fix_slim_arena_gen_c.pl 注入 ast_ast_* 原型（typeck/codegen 单文件编译依赖）
ast_gen2.c: $(SHUX_C) src/ast/ast.sx
	./$(SHUX_C) -L src/ast -E -E-extern src/ast/ast.sx > $@
	perl scripts/fix_slim_arena_gen_c.pl $@

ast_gen2.o: ast_gen2.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c ast_gen2.c -o ast_gen2.o

typeck_gen.c: $(SHUX_C) ast_gen2.c src/typeck/typeck.sx
	./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser src/typeck/typeck.sx -E-extern > $@
	perl scripts/fix_slim_arena_gen_c.pl $@

typeck_sx.o: typeck_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c typeck_gen.c -o typeck_sx.o
	@test $$(stat -f%z typeck_sx.o 2>/dev/null || stat -c%s typeck_sx.o) -gt 10000 || (echo "typeck_sx.o too small (corrupt gen? rm typeck_gen.c && make typeck_gen.c typeck_sx.o)" >&2; exit 1)

codegen_gen.c: $(SHUX_C) ast_gen2.c src/codegen/codegen.sx
	./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck src/codegen/codegen.sx -E-extern > $@
	perl scripts/fix_slim_arena_gen_c.pl $@

codegen_sx.o: codegen_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c codegen_gen.c -o codegen_sx.o
	@test $$(stat -f%z codegen_sx.o 2>/dev/null || stat -c%s codegen_sx.o) -gt 50000 || (echo "codegen_sx.o too small (corrupt gen? rm codegen_gen.c && make codegen_gen.c codegen_sx.o)" >&2; exit 1)

# 6.1：.sx typeck 入口与 C AST 对接；用 C-only shux 编译 typeck.sx 生成 typeck_gen.c，再链接进 shux，使 typeck 由 .sx 入口转调 C
bootstrap-typeck: $(TARGET)
	./$(TARGET) src/typeck/typeck.sx -E > typeck_gen.c
	$(CC) $(CFLAGS) -c typeck_gen.c -o typeck_sx.o
	$(CC) $(CFLAGS) -DSHUX_USE_SX_TYPECK -o $(TARGET) $(OBJS) typeck_sx.o
	@echo "bootstrap-typeck OK"

# 6.2：.sx codegen 入口与 C AST 对接；编译 typeck.sx + codegen.sx 生成 _gen.c，链接进 shux，使 typeck 与 codegen 均由 .sx 入口转调 C
bootstrap-codegen: $(TARGET)
	./$(TARGET) src/typeck/typeck.sx -E > typeck_gen.c
	./$(TARGET) src/codegen/codegen.sx -E > codegen_gen.c
	$(CC) $(CFLAGS) -c typeck_gen.c -o typeck_sx.o
	$(CC) $(CFLAGS) -c codegen_gen.c -o codegen_sx.o
	$(CC) $(CFLAGS) -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN -o $(TARGET) $(OBJS) typeck_sx.o codegen_sx.o
	@echo "bootstrap-codegen OK"

# 6.3/6.4：入口在 main.sx；链接时用 main_driver.o（带 SHUX_USE_SX_DRIVER/PIPELINE 以启用 -backend asm）+ runtime_driver.o + ...
src/main_driver.o: src/main.c Makefile
	$(CC) $(CFLAGS) -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -c -o $@ $<
# runtime_driver.o 已定义 preprocess()；此处须链 preprocess_for_driver.o（仅 preprocess_c_fallback），不可与 src/preprocess.o 同链。
src/driver/target_cpu.o: src/driver/target_cpu.c include/target_cpu.h
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<
src/asm/simd_enc.o: src/asm/simd_enc.c include/simd_enc.h include/target_cpu.h
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<
src/asm/simd_loop.o: src/asm/simd_loop.c include/simd_loop.h include/simd_enc.h include/target_cpu.h
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<
DRIVER_OBJS = src/main_driver.o src/runtime_driver.o src/preprocess_for_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o src/lexer/lexer.o src/ast/ast.o src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o
# 6.3/6.4：.sx pipeline 的 pipeline_gen.c 已含 ast_expr_init_match_enum；C 侧 ast.c 同链时须 -DSHUX_USE_SX_AST 去掉该符号定义，仍保留 ast_*_free 供 C parser / runtime 使用。
src/ast/ast_seed.o: src/ast/ast.c include/ast.h
	$(CC) $(CFLAGS) -DSHUX_USE_SX_AST -c -o $@ $<

# bootstrap-driver-seed：pipeline_sx.o 为 -E-extern 编排；parser/lexer/typeck/codegen _su.o 分 TU；C parser/typeck/codegen 供 lsp 与 -E driver。
# seed 链：lexer_sx.o（SU 词法）+ lexer.o（lexer_new/free 与 C 前端 lexer_next）。
# preprocess -D 槽与 parser labeled 名写入（parser_sx.o / runtime_driver 依赖，不可缺链）。
AST_POOL_L5_BRIDGE_O = src/ast_pool_l5_bridge.o
DRIVER_SEED_OBJS = src/main_driver.o src/runtime_driver.o src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o src/preprocess_for_driver.o src/lexer/lexer.o src/ast/ast_seed.o parser_sx.o lexer_sx.o lexer_sx_link_alias.o typeck_sx.o codegen_sx.o typeck_sx_link_alias.o codegen_sx_link_alias.o src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o src/async/async_liveness.o src/async/async_cps_codegen.o src/sx_seed_bridge.o src/std_fs_shim.o src/std_sys_shim.o $(AST_POOL_L5_BRIDGE_O)
DRIVER_SEED_SX_OBJS = parser_sx.o typeck_sx.o codegen_sx.o

# 阶段 10.4 实验：链 typeck_sx.o/codegen_sx.o 替代 C 前端（不含 pipeline_sx.o，无 SHUX_USE_SX_PIPELINE）。
DRIVER_SEED_SX_FRONTEND_OBJS = src/main_driver.o src/runtime_driver.o src/preprocess_for_driver.o src/lexer/lexer.o src/ast/ast_seed.o src/parser/parser.o typeck_sx.o codegen_sx.o
bootstrap-driver-seed-su-frontend: $(SHUX_C) migrate-sx-objs driver_sx.o preprocess_sx.o $(DRIVER_SUBCMD_GEN) $(DRIVER_SEED_SX_FRONTEND_OBJS) src/lsp/lsp_diag.o _stubs_driver.o $(DRIVER_SUBCMD_OBJS)
	$(CC) $(CFLAGS) -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN -o $(TARGET)_su_frontend $(DRIVER_SEED_SX_FRONTEND_OBJS) driver_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o src/lsp/lsp_diag.o ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o $(PIPELINE_LIBS)
	@echo "bootstrap-driver-seed-su-frontend OK ($(TARGET)_su_frontend: .sx typeck/codegen, no pipeline_sx.o)"

# 6.3：.sx 入口与 main.c 一一对应。bootstrap-driver-seed = 用 C 代码生成（生成 pipeline_gen.c / driver_gen.c）得到种子 shux；仅首次或无 shux 时需要。
# bootstrap-driver-asm / bootstrap-driver-hybrid = B-hybrid（build_shux_asm 无 SKIP_GEN），产出可覆盖 $(TARGET)。
# bootstrap-driver = M7 默认 B-strict（同 bootstrap-driver-bstrict）：SKIP_GEN 链 shux_asm 并覆盖 $(TARGET)；冷启动仍仅 bootstrap-driver-seed。
# 无补丁：driver_gen.c 仅由 -E -E-extern 生成；run_compiler_c 在 runtime.c 中定义并转调 main_run_compiler_c；其余从 main.sx/codegen 根源修
# LSP 诊断：lsp_diag.sx -E → lsp_diag_gen.c → lsp_diag_sx.o（parse_into + typeck_sx_ast）；lsp_diag.c 仍提供收集器与 definition 等
src/lsp/lsp_diag.o: src/lsp/lsp_diag.c src/lsp/lsp_diag.h
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/lsp/lsp_diag_pipeline_sizes.o: src/lsp/lsp_diag_pipeline_sizes.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# bootstrap/relink 同时链 lsp_diag_pipeline_ctx.o；Cygwin 无 weak，须省略 sizes 内占位符号。
src/lsp/lsp_diag_pipeline_sizes_nostub.o: src/lsp/lsp_diag_pipeline_sizes.c
	$(CC) $(CFLAGS) -DSHUX_LSP_PIPELINE_CTX_LINKED -I. -Iinclude -Isrc -c -o $@ $<

src/lsp/lsp_diag_pipeline_ctx.o: src/lsp/lsp_diag_pipeline_ctx.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/lsp/lsp_diag_sx_alias.o: src/lsp/lsp_diag_sx_alias.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

$(AST_POOL_L5_BRIDGE_O): src/ast_pool_l5_bridge.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

lsp_diag_gen.c: $(SHUX_C) src/lsp/lsp_diag.sx
	@echo "lsp_diag_gen.c: $(SHUX_C) -E -E-extern (avoid shux-sx -sx -E: broken TU for lsp_diag.sx)" >&2
	./$(SHUX_C) $(LSP_SU_E_DIRS) -L src/pipeline src/lsp/lsp_diag.sx -E -E-extern > $@
	@if ! grep -q 'C-04 -E-extern TU aliases' $@ 2>/dev/null; then \
	  perl scripts/fix_slim_arena_gen_c.pl $@; \
	fi
	@if ! grep -q 'C-04 parser: ast_expr_init_match_enum after struct ast_Expr' $@ 2>/dev/null; then \
	  perl scripts/fix_parser_pool_access_gen_c.pl $@; \
	fi

lsp_diag_sx.o: lsp_diag_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c lsp_diag_gen.c -o lsp_diag_sx.o

# lsp_io.sx：C-04 v0 要求 shux-c 自动生成 import extern；shux-sx 仍走旧块时回退 shux-c。
lsp_io_gen.c: $(SHUX_C) src/lsp/lsp_io.sx
	@if [ -f $(SHUX_SX) ]; then \
	  echo "lsp_io_gen.c: ./$(SHUX_SX) -sx -E ..." >&2; \
	  ./$(SHUX_SX) -sx -E $(LSP_SU_E_DIRS) -E-extern src/lsp/lsp_io.sx > $@.tmp 2>/dev/null || true; \
	  if [ -s $@.tmp ] && ! grep -q 'lsp_io -E-extern stubs (io.o' $@.tmp; then \
	    mv $@.tmp $@; \
	  else \
	    rm -f $@.tmp; \
	    echo "lsp_io_gen.c: fallback to shux-c -E -E-extern (C-04)" >&2; \
	    ./$(SHUX_C) $(LSP_SU_E_DIRS) src/lsp/lsp_io.sx -E -E-extern > $@; \
	  fi; \
	else \
	  ./$(SHUX_C) $(LSP_SU_E_DIRS) src/lsp/lsp_io.sx -E -E-extern > $@; \
	fi

# LSP 模块：main.sx 依赖 lsp，需单独 -E 生成 lsp_gen.c；-E-extern 使 lsp_io、std.io、std.heap 仅生成 extern，由 lsp_io_sx.o 与 io.o/heap.o 提供。
# LSP state 单独 .c，避免 lsp_main 内大数组导致 state 被覆盖
src/lsp/lsp_state.o: src/lsp/lsp_state.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# lsp_gen.c 期望 typeck_read_message 等；lsp_io -E-extern 未产出时由桩提供。
src/lsp/typeck_lsp_io_stub.o: src/lsp/typeck_lsp_io_stub.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

lsp_gen.c: $(SHUX_C) src/lsp/lsp.sx
	@if [ -f $(SHUX_SX) ]; then \
	  echo "lsp_gen.c: ./$(SHUX_SX) -sx -E ..." >&2; \
	  ./$(SHUX_SX) -sx -E $(LSP_SU_E_DIRS) -E-extern src/lsp/lsp.sx > $@.tmp 2>/dev/null || true; \
	  if [ -s $@.tmp ] && grep -q typeck_lsp_main_impl $@.tmp && ! grep -q 'lsp.sx -E-extern stubs (lsp_io_sx' $@.tmp; then \
	    mv $@.tmp $@; \
	  else \
	    rm -f $@.tmp; \
	    echo "lsp_gen.c: shux-sx failed or old extern block, fallback to shux-c -E -E-extern" >&2; \
	    ./$(SHUX_C) $(LSP_SU_E_DIRS) src/lsp/lsp.sx -E -E-extern > $@; \
	  fi; \
	else \
	  ./$(SHUX_C) $(LSP_SU_E_DIRS) src/lsp/lsp.sx -E -E-extern > $@; \
	fi
	@sed -i.bak 's/uint8_t state_buf\[16388\] = { 0 }/extern uint8_t g_lsp_state_buf[16388]/' lsp_gen.c 2>/dev/null || true
	@sed -i.bak 's/(state_buf)/(g_lsp_state_buf)/g' lsp_gen.c 2>/dev/null || true

# std_heap_* 由 lsp_io_std_heap.sx 提供（转调 heap_alloc_c/heap_free_c/heap_alloc_zeroed_c）；shux-sx 路径下 extern 由 codegen.sx 输出。
lsp_io_std_heap_gen.c: $(SHUX_C) src/lsp/lsp_io_std_heap.sx
	@if [ -f $(SHUX_SX) ]; then \
	  echo "lsp_io_std_heap_gen.c: ./$(SHUX_SX) -sx -E ..." >&2; \
	  ./$(SHUX_SX) -sx -E $(LSP_SU_E_DIRS) -E-extern src/lsp/lsp_io_std_heap.sx > $@; \
	else \
	  ./$(SHUX_C) $(LSP_SU_E_DIRS) src/lsp/lsp_io_std_heap.sx -E -E-extern > $@; \
	fi
lsp_io_std_heap_sx.o: lsp_io_std_heap_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c lsp_io_std_heap_gen.c -o lsp_io_std_heap_sx.o

# bootstrap-driver-seed / relink-shux 共用：lsp_io / lsp 生成 C → .o
lsp_io_sx.o: lsp_io_gen.c src/lsp/lsp_io.sx
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Dstd_io_read=io_read -Dstd_io_write=io_write -c lsp_io_gen.c -o lsp_io_sx.o

lsp_sx.o: lsp_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c lsp_gen.c -o lsp_sx.o

# fmt/check/test/compile/build/run：独立 .sx -E-extern 产出；asm_driver_* 仍由 _stubs_driver.c 提供
DRIVER_SUBCMD_GEN = driver_fmt_gen.c driver_check_gen.c driver_test_gen.c driver_compile_gen.c driver_build_gen.c driver_run_gen.c driver_emit_gen.c
DRIVER_SUBCMD_OBJS = driver_fmt_sx.o driver_check_sx.o driver_test_sx.o driver_compile_sx.o driver_build_sx.o driver_run_sx.o driver_emit_sx.o
DRIVER_SUBCMD_DIRS = -L .. -L src -L src/lexer -L src/ast

driver_fmt_gen.c: $(SHUX_C) src/driver/fmt.sx
	./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/fmt.sx > $@
driver_check_gen.c: $(SHUX_C) src/driver/check.sx
	./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/check.sx > $@
driver_test_gen.c: $(SHUX_C) src/driver/test.sx
	./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/test.sx > $@
driver_compile_gen.c: $(SHUX_C) src/driver/compile.sx
	./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/compile.sx > $@
driver_build_gen.c: $(SHUX_C) src/driver/build.sx
	./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/build.sx > $@
driver_run_gen.c: $(SHUX_C) src/driver/run.sx
	./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/run.sx > $@
driver_emit_gen.c: $(SHUX_C) src/driver/emit.sx
	./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -L ../std/fs -L src/preprocess -L src/pipeline -L src/codegen -E -E-extern src/driver/emit.sx > $@

driver_fmt_sx.o: driver_fmt_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_fmt_gen.c -o $@
driver_check_sx.o: driver_check_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_check_gen.c -o $@
driver_test_sx.o: driver_test_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_test_gen.c -o $@
driver_compile_sx.o: driver_compile_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_compile_gen.c -o $@
driver_build_sx.o: driver_build_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_build_gen.c -o $@
driver_run_sx.o: driver_run_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_run_gen.c -o $@
driver_emit_sx.o: driver_emit_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_emit_gen.c -o $@

# asm_driver_*：driver_gen.c 为 extern 时由本桩提供符号（fmt/check/test 见 DRIVER_SUBCMD_OBJS）。
# 链接顺序：_stubs_driver.o 须紧跟 preprocess_sx.o 之后（先于 lsp_diag/std *.o），避免与 runtime_driver.o
# 中 _preprocess / preprocess_preprocess_sx_buf 解析顺序导致 Undefined _preprocess。
_stubs_driver.o: _stubs_driver.c
	$(CC) $(CFLAGS) -c -o $@ $<

# Stage2 混合链接桩（verify-selfhost-stage2.sh）
_sx_stubs2.o: _sx_stubs2.c
	$(CC) $(CFLAGS) -c -o $@ $<

# pipeline_sx.o：与 pipeline_gen.c 及 PIPELINE_SX_DEPS 绑定；parser/backend 等 .sx 变更须重编，避免 seed 仍用旧 pipeline 逻辑（entry 消失等）。
# 默认复用 build_asm/gen_driver/pipeline_sx.o（fat 编排）；设 PIPELINE_SX_FORCE_COMPILE=1 才从 pipeline_gen.c 重编。
# pipeline_glue.c / ast_pool.c 新于 gen_driver 副本时须重编（M8：emit_assign / struct lea 等 glue 符号）。
pipeline_sx.o: pipeline_gen.c $(PIPELINE_SX_DEPS)
	@GEN_DRV=build_asm/gen_driver/pipeline_sx.o; \
	STALE=0; \
	if [ -f "$$GEN_DRV" ] && { [ pipeline_glue.c -nt "$$GEN_DRV" ] || [ ast_pool.c -nt "$$GEN_DRV" ] || [ ast_pool_bootstrap_glue.c -nt "$$GEN_DRV" ]; }; then STALE=1; fi; \
	if [ -z "$$PIPELINE_SX_FORCE_COMPILE" ] && [ "$$STALE" -eq 0 ] && [ -f "$$GEN_DRV" ]; then \
	  cp "$$GEN_DRV" $@ && echo "pipeline_sx.o: from build_asm/gen_driver"; \
	else \
	  $(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I.. -Dstd_io_driver_driver_read_ptr_len=shux_io_read_ptr_len -Dstd_io_driver_driver_read_ptr=shux_io_read_ptr -c pipeline_gen.c -o $@ && \
	  mkdir -p build_asm/gen_driver && cp $@ "$$GEN_DRV"; \
	fi

# driver_gen.c / driver_sx.o：main.sx 驱动入口；-E 须 shux-c（C parser stmt_order）。
driver_gen.c: $(SHUX_C) $(MAIN_SX_DEPS)
	./$(SHUX_C) $(MAIN_SX_E_DIRS) src/main.sx -E -E-extern > $@
	perl scripts/fix_driver_gen_duplicate_main.pl $@

driver_sx.o: driver_gen.c $(MAIN_SX_DEPS)
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -include src/sx_stubs.h -Dstd_fs_fs_read=fs_posix_read_c -Dstd_fs_fs_write=fs_posix_write_c -Dstd_fs_fs_close=fs_posix_close_c -Dfs_read=fs_posix_read_c -Dfs_write=fs_posix_write_c -Dfs_close=fs_posix_close_c -c driver_gen.c -o driver_sx.o

# preprocess_gen.c / preprocess_sx.o：runtime SHUX_USE_SX_PREPROCESS 路径。
preprocess_gen.c: $(SHUX_C) $(PREPROCESS_SX_DEPS)
	./$(SHUX_C) -L src/lexer -E -E-extern src/preprocess/preprocess.sx > $@

preprocess_sx.o: preprocess_gen.c $(PREPROCESS_SX_DEPS)
	$(CC) $(CFLAGS) -c preprocess_gen.c -o preprocess_sx.o

# SHUX_NO_C_FRONTEND 下 lsp_diag_sx.o / lsp_sx.o 需要的文档缓冲 + SU 管道缓冲桩
src/lsp/lsp_diag_stubs_no_c.o: src/lsp/lsp_diag_stubs_no_c.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# SHUX_SKIP_SUBSCRIPT_MAKE=1：run-all 入口已链 seed，子脚本 `make` 仅在校验 shux 缺失时再完整 bootstrap。
ifeq ($(SHUX_SKIP_SUBSCRIPT_MAKE),1)
bootstrap-driver-seed:
	@test -x '$(TARGET)' || $(MAKE) bootstrap-driver-seed SHUX_SKIP_SUBSCRIPT_MAKE= SHUX_RUN_ALL_BOOTSTRAP_SHUX=1
else
bootstrap-driver-seed: $(SHUX_C) build-seed-asm-host $(USER_ASM_LINK) pipeline_sx.o parser_sx.o lexer_sx.o lexer_sx_link_alias.o typeck_sx.o codegen_sx.o typeck_sx_link_alias.o codegen_sx_link_alias.o driver_sx.o preprocess_sx.o lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c $(DRIVER_SUBCMD_GEN) src/main_driver.o src/runtime_driver.o src/driver/fmt_check_cmd_driver.o src/preprocess_for_driver.o src/lexer/lexer.o src/ast/ast_seed.o src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o src/sx_seed_bridge.o src/std_fs_shim.o src/std_sys_shim.o $(AST_POOL_L5_BRIDGE_O) pipeline_bootstrap_orchestration.o src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_diag_sx_alias.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o _stubs_driver.o $(DRIVER_SUBCMD_OBJS)
	@# gen_driver 的 pipeline_sx.o partial 可能缺 pipeline_asm_block_*；链 USER_ASM 前强制从 pipeline_gen.c 重编完整 TU。
	@$(MAKE) pipeline_sx.o PIPELINE_SX_FORCE_COMPILE=1
	$(MAKE) -B src/runtime_driver.o src/preprocess_for_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o
	$(MAKE) lsp_io_sx.o lsp_sx.o lsp_diag_sx.o
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c src/lsp/lsp_diag_sx_alias.c -o src/lsp/lsp_diag_sx_alias.o
	$(CC) $(CFLAGS) -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN -o $(TARGET) $(DRIVER_SEED_OBJS) driver_sx.o pipeline_sx.o pipeline_bootstrap_orchestration.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o $(PIPELINE_LIBS) $(USER_ASM_LINK)
	cp -f $(TARGET) shux-sx
	@echo "bootstrap-driver-seed OK (seed 已链 shux-c -E asm 后端)"
endif

# 与 bootstrap-driver-seed 相同；保留别名供脚本引用
# bootstrap seed 链 pipeline_bootstrap_orchestration.o 需 glue 类型头（与 build_shux_asm B-strict 同源）。
build_asm/pipeline_glue_types.inc: pipeline_gen.c scripts/extract_pipeline_glue_types.pl
	@mkdir -p build_asm
	perl scripts/extract_pipeline_glue_types.pl pipeline_gen.c > $@

pipeline_bootstrap_orchestration.o: pipeline_bootstrap_orchestration.c pipeline_gen.c build_asm/pipeline_glue_types.inc
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -Ibuild_asm -DPIPELINE_BOOTSTRAP_ORCH_NO_PIPELINE_RUN_WRAPPER -c -o $@ pipeline_bootstrap_orchestration.c

# relink-shux 与 bootstrap-driver-seed 链接同一组 .o；须声明为 prerequisite，否则冷启动仅 make all 后缺 main_driver.o 等。
RELINK_SHUX_PREREQS = build-seed-asm-host $(USER_ASM_LINK) $(DRIVER_SUBCMD_GEN) \
  $(DRIVER_SEED_OBJS) driver_sx.o pipeline_sx.o pipeline_bootstrap_orchestration.o \
  lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c \
  lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o \
  $(DRIVER_SUBCMD_OBJS) _stubs_driver.o \
  src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes_nostub.o \
  src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o \
  ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o

# driver/fmt_check 变更后快速重链 shux（不跑 asm.sx -E；需已有 build_asm/seed_host/asm_backend_partial.o）
.PHONY: relink-shux refresh-shux-asm-gate
relink-shux: $(SHUX_C) $(RELINK_SHUX_PREREQS)
	$(MAKE) driver_fmt_sx.o driver_check_sx.o
	@$(MAKE) -B src/runtime_driver.o src/async/async_cps_codegen.o
	@$(MAKE) pipeline_sx.o PIPELINE_SX_FORCE_COMPILE=1
	$(CC) $(CFLAGS) -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN -o $(TARGET) $(DRIVER_SEED_OBJS) driver_sx.o pipeline_sx.o pipeline_bootstrap_orchestration.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o $(PIPELINE_LIBS) $(USER_ASM_LINK)
	@echo "relink-shux OK"

bootstrap-driver-seed-user-asm: bootstrap-driver-seed
	@echo "bootstrap-driver-seed-user-asm OK (= bootstrap-driver-seed + USER_ASM_LINK)"

# 实验：不链 C lexer/parser/typeck/codegen；依赖已成功的 bootstrap-driver-seed 产物。(-E-extern / 泛型单态 C 路径不可用)
DRIVER_NO_C_FRONTEND_OBJS = src/main_driver.o src/runtime_driver_no_c.o src/preprocess_for_driver.o src/ast/ast_seed.o src/codegen/codegen_pipeline_stubs.o src/typeck/typeck_f64_bits.o
shux-no-c-frontend: $(DRIVER_NO_C_FRONTEND_OBJS) src/lsp/lsp_diag_stubs_no_c.o
	@test -f driver_sx.o && test -f pipeline_sx.o && test -f preprocess_sx.o || (echo "请先 make bootstrap-driver-seed" && exit 1)
	$(CC) $(CFLAGS) -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -o $@ $(DRIVER_NO_C_FRONTEND_OBJS) driver_sx.o pipeline_sx.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o src/lsp/lsp_diag_pipeline_sizes.o src/lsp/lsp_state.o src/lsp/lsp_diag_stubs_no_c.o lsp_io_std_heap_sx.o ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o $(PIPELINE_LIBS)
	@echo "shux-no-c-frontend OK (try: ./shux-no-c-frontend -E examples/hello.sx)"

# 注意：Makefile 中存在同名规则 `shux-sx:`，不能把 `shux-sx` 列为本目标 prerequisite，否则会先执行重链接口而非仅检测文件是否存在。
regen-lsp-gens-su:
	@if [ ! -f $(SHUX_SX) ]; then echo "请先 make bootstrap-driver-seed（需要 ./$(SHUX_SX)）。" >&2; exit 1; fi
	rm -f lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c
	$(MAKE) lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c
	@echo "regen-lsp-gens-sx OK"

# 仅重链 ./shux-sx；pipeline/driver/preprocess 的 .sx 变更会经对应 *_su.o 目标触发重编后再链接。
shux-sx: build-seed-asm-host src/asm/user_asm_seed_bridge.o $(DRIVER_SEED_OBJS) pipeline_sx.o driver_sx.o preprocess_sx.o
	@test -f driver_sx.o && test -f lsp_sx.o && test -f lsp_diag_sx.o && test -f src/lsp/lsp_diag_sx_alias.o && test -f lsp_io_sx.o && test -f preprocess_sx.o && test -f lsp_io_std_heap_sx.o && test -f driver_fmt_sx.o && test -f driver_check_sx.o && test -f driver_test_sx.o && test -f driver_compile_sx.o && test -f driver_build_sx.o && test -f driver_run_sx.o && test -f _stubs_driver.o || (echo "缺少 driver_sx.o 等，请先: make bootstrap-driver-seed" && exit 1)
	$(CC) $(CFLAGS) -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -o $@ $(DRIVER_SEED_OBJS) driver_sx.o pipeline_sx.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o $(PIPELINE_LIBS) $(USER_ASM_LINK)
	@echo "shux-sx OK"

# Stage2：shux-sx 用 -sx -E-extern 生成 _gen2.c 并链出 shux-sx2，与 shux-sx 行为对比（脚本内会 make shux-sx / bootstrap-driver-seed）
verify-selfhost-stage2:
	sh ./verify-selfhost-stage2.sh

# 可选：在 bootstrap-verify 之外单独跑 Stage2（不阻塞 PR 默认 CI）
bootstrap-verify-stage2: verify-selfhost-stage2
	@echo "bootstrap-verify-stage2 OK"

# M5：B-strict 二遍 build_shux_asm（shux_asm -> shux_asm2），不依赖 shux-sx -sx -E。
verify-selfhost-stage2-bstrict:
	sh ./verify-selfhost-stage2-bstrict.sh

bootstrap-verify-stage2-bstrict: verify-selfhost-stage2-bstrict
	@echo "bootstrap-verify-stage2-bstrict OK"

# B-hybrid：asm 构建（无 SKIP_GEN），成功则 shux_asm 覆盖 $(TARGET)；失败保留 seed。
bootstrap-driver-hybrid bootstrap-driver-asm: $(TARGET)
	@SHUX=./$(TARGET) ./scripts/build_shux_asm.sh
	@if [ -f shux_asm ]; then cp -f shux_asm $(TARGET) && echo "bootstrap-driver-hybrid OK: $(TARGET) from asm (B-hybrid)"; else echo "bootstrap-driver-hybrid: asm build skipped ($(TARGET) left as seed); run SHUX=./$(TARGET) ./scripts/build_shux_asm.sh for details."; fi

# 仅 asm、不生成 C（B-hybrid 别名，保留历史目标名）
bootstrap-driver-asm-only: bootstrap-driver-hybrid

# M7 默认自举：B-strict（SKIP_GEN，链接审计无 cc -c pipeline_gen.c）；shux_asm 默认覆盖 $(TARGET)。
# 仅保留 shux_asm、不覆盖 seed：SHUX_BSTRICT_NO_REPLACE=1 make bootstrap-driver-bstrict
bootstrap-driver-bstrict: bootstrap-driver-seed
	@SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 SHUX=./$(TARGET) ./scripts/build_shux_asm.sh
	@if [ ! -f shux_asm ]; then echo "bootstrap-driver-bstrict: shux_asm build failed (see build_shux_asm.sh log)" >&2; exit 1; fi
	@$(MAKE) refresh-shux-asm-gate

# P0 asm 门禁：strict shux_asm 与 seed+migrate-sx-objs 对齐（M-3 含 typeck/codegen/ast）；shux_asm2 仍保留 gen2。
refresh-shux-asm-gate: migrate-sx-objs relink-shux
	@cp -f $(TARGET) shux_asm
	@echo "refresh-shux-asm-gate OK (shux_asm <- seed+migrate-sx-objs)"
	@if [ -n "$$SHUX_BSTRICT_NO_REPLACE" ]; then echo "bootstrap-driver-bstrict OK (shux_asm=seed+parser_sx; $(TARGET) unchanged)"; else cp -f shux_asm $(TARGET) && echo "bootstrap-driver-bstrict OK (shux_asm -> $(TARGET), release default B-strict)"; fi

# 日常/release 默认路径（M7）：等价 bootstrap-driver-bstrict；冷启动须先 bootstrap-driver-seed 或 make all。
bootstrap-driver: bootstrap-driver-bstrict

# M4 Linux：crt0 + full_asm .o 链（B-partial，无 runtime_driver）；与 bootstrap-driver-bstrict（asm_only_strict）分轨验收。
bootstrap-driver-crt0: bootstrap-driver-seed
	@SHUX=./$(TARGET) ./scripts/build_shux_asm.sh 2>&1 | tee /tmp/build_shux_crt0.log; \
	grep -qE 'Target-B-partial|LINK_MODE=crt0|no C runtime driver' /tmp/build_shux_crt0.log || \
	(echo "bootstrap-driver-crt0: expected crt0 link in log" >&2; exit 1); \
	if grep -q 'cc -c pipeline_gen.c' /tmp/build_shux_crt0.log; then \
	  echo "bootstrap-driver-crt0: crt0 path must not cc -c pipeline_gen.c" >&2; exit 1; fi; \
	test -f shux_asm && echo "bootstrap-driver-crt0 OK (shux_asm via crt0 + build_asm/*.o)"

# build-user-asm-backend：自 shux 编 build_asm/*.o（完整 asm 自举）；seed 默认用 build-seed-asm-host（shux-c -E）。
build-user-asm-backend:
	@./scripts/build_user_asm_backend.sh

# Goal 2（用 asm 后端构建 shux）：构建最小 C 桩 + 可选执行 asm 自举脚本（需先 bootstrap-driver）
bootstrap-asm: $(TARGET) src/asm/runtime_asm_build.o src/runtime_driver.o
	@echo "bootstrap-asm: runtime_asm_build.o + runtime_driver.o ready."
	@echo "  Full asm build: SHUX=./$(TARGET) ./scripts/build_shux_asm.sh (requires bootstrap-driver first)"
bootstrap-asm-full: bootstrap-driver bootstrap-asm
	@SHUX=./$(TARGET) ./scripts/build_shux_asm.sh

# Goal 2 辅助：检查 build_asm/*.o 的 __text 段是否非空（需先有 build_asm，例如刚跑过 build_shux_asm.sh）。严格失败：SHUX_ASM_QUALITY_STRICT=1 make check-asm-o-quality
check-asm-o-quality: $(TARGET)
	@SHUX=./$(TARGET) ./scripts/check_asm_o_quality.sh

# 6.4 验收：宿主编译器能编译整机 .sx（typeck+codegen+driver）并产出新 shux，且新 shux 能编译运行测试（return-value 返回 42 视为成功）。用 seed 构建 shux 以保证通过（asm 路径修好后可改为 bootstrap-driver）。
# seed 的 .sx 单文件路径把 C 写到 -o；须 $(CC) 链成可执行再运行（与 shux-c 直接出 Mach-O/ELF 不同）。
check-6.4: $(TARGET)
	@$(MAKE) bootstrap-driver-seed && ./$(TARGET) ../tests/return-value/main.sx -o /tmp/check64.c && $(CC) $(CFLAGS) -o /tmp/check64 /tmp/check64.c && /tmp/check64; [ $$? -eq 42 ] && echo "check-6.4 OK"

# 首次/从零构建：一条命令得到 shux-c + build_tool（build-tool 仅依赖 shux-c，与 lsp_gen 生成物无环）。与 README「读者一次做对」一致。
first-time: build-tool

# 阶段 7：build.sx 在仓库根目录，用 shux-c 编成 build_tool（在 compiler 目录下），运行 build_tool 即完成一次编译器构建
build-tool: $(SHUX_C)
	./$(SHUX_C) ../build.sx -E > build_gen.c
	$(CC) $(CFLAGS) -c build_gen.c -o build_tool.o
	$(CC) $(CFLAGS) -c src/build_runtime.c -o build_runtime.o
	$(CC) $(CFLAGS) -o build_tool build_tool.o build_runtime.o
	@echo "build_tool OK（在 compiler 目录下运行 ./build_tool ./shux 可产出 shux）"

# build_tool 完全无 C（仅 Linux）：crt0 + build_runner.sx + build.sx + build_runtime_sx.sx，不再链接 build_runtime.c
ifeq ($(UNAME_S),Linux)
build-tool-su: $(SHUX_C) src/asm/crt0_x86_64.o
	./$(SHUX_C) ../build.sx -E > build_gen.c
	$(CC) $(CFLAGS) -c build_gen.c -o build_tool.o
	./$(SHUX_C) ../build_runner.sx -E > build_runner_gen.c
	$(CC) $(CFLAGS) -c build_runner_gen.c -o build_runner.o
	./$(SHUX_C) ../build_runtime_sx.sx -E > build_runtime_sx_gen.c
	$(CC) $(CFLAGS) -ffreestanding -c build_runtime_sx_gen.c -o build_runtime_sx.o
	$(CC) $(CFLAGS) -o build_tool src/asm/crt0_x86_64.o build_runner.o build_tool.o build_runtime_sx.o -lc
	@echo "build_tool OK (no C runtime; run ./build_tool ./shux)"
endif

# 运行 build_tool 产出 shux（等价于 make bootstrap-driver，无需执行 Makefile bootstrap-driver 目标）
build-via-tool: build-tool
	./build_tool ./$(TARGET)
	@echo "build-via-tool OK（shux 已由 build_tool 产出）"

# 阶段 8.1/8.2：用 seed 产出 shu₁（C 生成 pipeline_gen.c/driver_gen.c 再链接）；用 shu₁ 再编得到 shu₂。两代跑 run-all 一致即自举验证通过。
# 注：asm 链接就绪（Goal 2）后可改为 bootstrap-driver，则 shu₁ 为 asm 版，实现「无 C 生成」自举。
# 与 bootstrap-driver-seed 一致：需生成 lsp_io_gen.c / lsp_io_std_heap_gen.c；lsp_io/lsp 的 extern 已写入生成 C，编译时仅需 lsp_io 的 std_io 宏与 io.o/heap.o 链接。
# bootstrap-self 末尾：stage2 对 return-value -o /tmp/out_self 可与 run-return-value.sh 一致产出 Mach-O/ELF；若为 C 源码则用 cc -x c 链出临时 bin（勿假定 -o *.c 必为 C）。
bootstrap-self: bootstrap-driver-seed
	@cp $(TARGET) $(TARGET)_stage1 && \
	$(MAKE) -s pipeline_sx.o driver_sx.o preprocess_sx.o lsp_io_gen.c lsp_gen.c lsp_io_std_heap_gen.c 2>/dev/null || true && \
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Dstd_io_read=io_read -Dstd_io_write=io_write -c lsp_io_gen.c -o lsp_io_sx.o && \
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c lsp_gen.c -o lsp_sx.o && \
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c lsp_io_std_heap_gen.c -o lsp_io_std_heap_sx.o && \
	$(CC) $(CFLAGS) -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -o $(TARGET)_stage2 $(DRIVER_SEED_OBJS) driver_sx.o pipeline_sx.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o $(PIPELINE_LIBS) $(USER_ASM_LINK) && \
	rm -f /tmp/out_self /tmp/out_self.bin && \
	./$(TARGET)_stage2 ../tests/return-value/main.sx -o /tmp/out_self && \
	ft=`file -b /tmp/out_self 2>/dev/null || true`; BIN=/tmp/out_self; \
	case "$$ft" in \
	  *Mach-O*|*ELF*|*PE32*) ;; \
	  *) $(CC) $(CFLAGS) -x c -std=c11 -Wall -Wextra -o /tmp/out_self.bin /tmp/out_self && BIN=/tmp/out_self.bin ;; \
	esac && \
	$$BIN; EX=$$?; [ $$EX -eq 42 ] && echo "bootstrap-self OK (shux1 -> shux2)" || (echo "bootstrap-self FAIL: stage2 or out_self exit=$$EX"; exit 1)

# 阶段 8.3 seed：两代 shux（shux_stage1/shux_stage2）烟测；B-strict 主路径见 check-7.2-bstrict。
check-7.2: bootstrap-self
	@ROOT=$$(pwd)/..; CDIR=$$(pwd); \
	for ST in $(TARGET)_stage1 $(TARGET)_stage2; do \
	  cp "$$CDIR/$$ST" "$$CDIR/$(TARGET)" && \
	  cd "$$ROOT" && \
	  SHUX="$$CDIR/$$ST" ./tests/run-return-value.sh && \
	  SHUX="$$CDIR/$$ST" ./tests/run-hello.sh && \
	  SHUX="$$CDIR/$$ST" ./tests/run-lexer.sh && \
	  SHUX="$$CDIR/$$ST" ./tests/run-typeck.sh && \
	  SHUX="$$CDIR/$$ST" ./tests/run-bootstrap-semantic-smoke-vec-map-heap.sh && \
	  SHUX="$$CDIR/$$ST" ./tests/run-bootstrap-stage2-dogfood-parser-typeck.sh || \
	  (echo "check-7.2 FAIL: $$ST"; exit 1); \
	done && \
	echo "check-7.2 OK (both stages: return-value, hello, lexer, typeck, vec/map/heap + parser/typeck dogfood)"

# 9.1 自举：纯 .sx 流水线（parse_into → typeck_sx_ast → codegen_sx_ast）；生成 pipeline_gen.c 便于联调；-L 与 pipeline 依赖一致。
# 必须用 $(SHUX_C) 做 -E：C 解析器(parser.c) 会按源码顺序填充 stmt_order，codegen 按序输出；若用 $(TARGET) 走 .sx 解析则 stmt_order 仅有 const+let 导致声明被提到函数首、顺序错乱。
# 修改 PIPELINE_SX_DEPS 内任一 .sx 后须触发 bootstrap-pipeline → pipeline_sx.o；`make shux-sx` 亦依赖 pipeline_sx.o，避免 test 后仍链旧 pipeline。
PIPELINE_SX_DEPS = src/pipeline/pipeline.sx src/codegen/codegen.sx src/typeck/typeck.sx src/parser/parser.sx src/ast/ast.sx src/lexer/lexer.sx src/preprocess/preprocess.sx src/asm/asm.sx src/asm/backend.sx src/asm/platform/elf.sx src/asm/arch/arm64.sx src/asm/arch/arm64_enc.sx pipeline_glue.c ast_pool.c
bootstrap-pipeline: $(SHUX_C) $(PIPELINE_SX_DEPS)
	./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -E -E-extern src/pipeline/pipeline.sx > pipeline_gen.c
	@echo "bootstrap-pipeline: pipeline_gen.c (-E-extern thin TU; codegen 无 perl 后处理)"

# 仅重生成并编译 pipeline/driver/preprocess 三个 SU 对象（供调试或 build_shux_asm 对齐）
gen-sx-driver-objs: pipeline_sx.o driver_sx.o preprocess_sx.o
	@echo "gen-sx-driver-objs OK (pipeline_sx.o driver_sx.o preprocess_sx.o)"

# pipeline_gen.c 由 bootstrap-pipeline 生成；-E 时 runtime.c 在入口为 pipeline.sx 时自动追加 pipeline_glue.c 到 stdout，无 Makefile 补丁
pipeline_gen.c: bootstrap-pipeline

# 链接带 -sx 流水线的 shux（需 main_sx.o 用 -DSHUX_USE_SX_PIPELINE 编译，否则 -sx -E 不生效）
# shux-sx-pipeline 链接了 ../std/io/io.o；lsp_diag_pipeline_sizes.o 提供 lsp_diag 与 pipeline 间结构体 sizeof；
# _stubs_driver.o 提供 asm_driver_*（fmt/check/test 仅 bootstrap-driver-seed / shux-sx 全驱动链需要 DRIVER_SUBCMD_OBJS）
shux-sx-pipeline: bootstrap-pipeline migrate-sx-objs $(PIPELINE_SX_BASE_OBJS) pipeline_sx.o $(PIPELINE_SX_FRONTEND_OBJS) $(PIPELINE_SX_SUPPORT_OBJS) ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes.o _stubs_driver.o
	@# gen_driver 副本可能缺 pipeline_asm_block_*；与 bootstrap-driver-seed 一致强制从 pipeline_gen.c 重编。
	@$(MAKE) pipeline_sx.o PIPELINE_SX_FORCE_COMPILE=1
	@$(MAKE) migrate-sx-objs $(PIPELINE_SX_SATELLITE_OBJS) pipeline_bootstrap_orchestration.o build-seed-asm-host
	@$(MAKE) -B src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o
	$(CC) $(CFLAGS) -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN -o $(TARGET)_su $(PIPELINE_SX_BASE_OBJS) pipeline_sx.o $(PIPELINE_SX_FRONTEND_OBJS) $(PIPELINE_SX_LINK_OBJS) ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes.o _stubs_driver.o $(PIPELINE_LIBS)
	@echo "shux_sx built; use ./shux_sx -sx -E <file.sx> to test .sx pipeline"

# 4.5（.sx 流水线编译 compiler 自身）：用 shux_sx 的 -sx -E 生成 typeck.sx / codegen.sx 对应的 C，再由 cc 链接得到新的 shux_sx_stage2。
# 这一目标的目的，是验证「完整前端（parse_into + typeck_sx_ast + codegen_sx_ast）」全部跑在 .sx 上时，仍能产出能工作的编译器。
bootstrap-su-compiler: shux-sx-pipeline
	./$(TARGET)_su -sx -E src/typeck/typeck.sx > typeck_sx_sx.c
	./$(TARGET)_su -sx -E src/codegen/codegen.sx > codegen_sx_sx.c
	$(CC) $(CFLAGS) -c typeck_sx_sx.c -o typeck_sx_sx.o
	$(CC) $(CFLAGS) -c codegen_sx_sx.c -o codegen_sx_sx.o
	$(CC) $(CFLAGS) -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN -o $(TARGET)_su_stage2 $(OBJS) typeck_sx_sx.o codegen_sx_sx.o
	@echo "bootstrap-su-compiler OK (.sx 流水线生成 typeck/codegen C 并链接 shux_sx_stage2)"

# 自举测试（不含 run-all）：seed 构建 shux，再用 shux 自编得到 shu_stage2，stage2 跑 return-value 返回 42 即通过。用于快速验证「shux 能编译自己」。
bootstrap-test: bootstrap-self
	@echo "Bootstrap tests OK (self-compilation: shux1 -> shux2)"

# M9：B-strict 语义自举主路径（shux_asm→shux_asm2 + lexer/typeck 烟测）。
check-7.2-bstrict: bootstrap-driver-bstrict
	@sh ./verify-selfhost-stage2-bstrict.sh
	@ROOT=$$(pwd)/..; CDIR=$$(pwd); \
	for ST in shux_asm_stage1 shux_asm2; do \
	  test -x "$$CDIR/$$ST" || { echo "check-7.2-bstrict: $$ST missing"; exit 1; }; \
	  cd "$$ROOT" && \
	  SHUX="$$CDIR/$$ST" ./tests/run-lexer.sh && \
	  SHUX="$$CDIR/$$ST" ./tests/run-typeck.sh && \
	  SHUX="$$CDIR/$$ST" ./tests/run-bootstrap-semantic-smoke-vec-map-heap.sh && \
	  SHUX="$$CDIR/$$ST" ./tests/run-bootstrap-stage2-dogfood-parser-typeck.sh || \
	  (echo "check-7.2-bstrict FAIL: $$ST"; exit 1); \
	done && \
	echo "check-7.2-bstrict OK (shux_asm gen1/gen2: stage2 + lexer + typeck + vec/map/heap + parser/typeck dogfood)"

bootstrap-verify-bstrict: check-7.2-bstrict
	@echo "bootstrap-verify-bstrict OK"

bootstrap-verify-seed: check-7.2
	@echo "bootstrap-verify-seed OK (seed shux -> shux_stage2)"

# 7.3 默认：B-strict / shux_asm 主路径；-sx -E 全模块仍见 bootstrap-verify-seed + verify-selfhost-stage2。
bootstrap-verify: bootstrap-verify-bstrict
	@echo "bootstrap-verify OK (B-strict primary; seed path: make bootstrap-verify-seed)"

# clangd：生成 compile_commands.json + ide/pipeline_glue_types.inc（IDE 误报 glue 池时运行）
compile_commands.json:
	./scripts/gen_compile_commands.sh

# 阶段 8 体积基线：编译固定用例并输出可执行文件大小
size-baseline:
	@if [ -f ../tests/run-size-baseline.sh ]; then (cd .. && chmod +x tests/run-size-baseline.sh && SHUX=./compiler/shux-c ./tests/run-size-baseline.sh); fi

# 阶段 8 性能基线：编译并多次运行 perf-baseline，输出耗时
perf-baseline:
	@if [ -f ../tests/run-perf-baseline.sh ]; then (cd .. && chmod +x tests/run-perf-baseline.sh && SHUX=./compiler/shux-c ./tests/run-perf-baseline.sh); fi
