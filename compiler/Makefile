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
SEED_LINUX_X86_64_OK := 0
ifeq ($(UNAME_S),Linux)
  ifneq (,$(filter x86_64 amd64,$(UNAME_M)))
    SEED_LINUX_X86_64_OK := 1
  endif
endif
ALPINE := $(shell test -f /etc/alpine-release && echo 1)
# Darwin：ld -r 须显式 -arch（与 cc 默认 triple 一致）。
LD ?= ld
ifeq ($(UNAME_S),Darwin)
  ifneq (,$(filter arm64 aarch64,$(UNAME_M)))
    LD_RELFLAGS = -arch arm64
  else ifneq (,$(filter x86_64 amd64,$(UNAME_M)))
    LD_RELFLAGS = -arch x86_64
  else
    LD_RELFLAGS =
  endif
else
  LD_RELFLAGS =
endif
TARGET  = shux
SRCS    = src/main.c src/runtime.c src/async/async_liveness.c src/async/async_cps_codegen.c
# OBJS_CORE：G-06 默认 shux-c=bootstrap_shuxc；仅 SHUX_LEGACY_C_FRONTEND=1 时链下列 runtime 桩（无 C 前端 .c）。
OBJS_CORE = src/main.o src/runtime.o src/runtime_abi.o src/runtime_io_abi.o src/runtime_proc_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o src/runtime_c_import.o src/driver/fmt_check_cmd.o src/async/async_liveness.o src/async/async_cps_codegen.o src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag_pipeline_sizes.o
ifeq ($(SHUX_LEGACY_C_FRONTEND),1)
# 考古冷启动：完整 C 前端 shux-c（仅用于生成/刷新 seeds/ 预编译种子）
OBJS_CORE = src/main.o src/runtime.o src/driver/fmt_check_cmd.o src/preprocess.o src/lexer/lexer.o src/ast/ast.o src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o src/async/async_liveness.o src/async/async_cps_codegen.o src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_c_import.o
endif
OBJS      = $(OBJS_CORE)
# 注：lsp.sx 生成的 lsp_gen 与 lsp_diag 中 lsp_build_* 同名；若把 InitializeResult/response 外壳迁入 .sx，
# 默认 shux 须链 lsp_sx.o、lsp_io_sx.o；F-03 v2/v3 std.io 由 .sx codegen 提供，无 io.o。

# C 仅版 shux：无 main_sx/pipeline_sx，供 bootstrap-pipeline 用 -E 生成 pipeline_gen.c（避免用已链 main_sx 的 $(TARGET) 导致走 .sx 路径失败）
SHUX_C = shux-c
# bootstrap-driver-seed 末尾 `cp $(TARGET)` 得到；不作为 lsp_*_gen.c / driver_gen / preprocess_gen 的 Makefile 前置（否则与 seed 依赖环）。
# -E/-E-extern 生成时在 recipe 内 `test -f shux-sx`：冷启动仅用 shux-c；二次构建起用 shux-sx（pipeline+codegen.sx），使 LSP 生成 C 与 codegen.sx 的自动 extern 一致。
SHUX_SX = shux-sx
# 与既有 shux-c 命令行一致的 -L（lsp/*.sx -E；-L src 仅限 main.sx / driver_gen）
LSP_SX_E_DIRS = -L .. -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess
MAIN_SX_E_DIRS = -L .. -L src -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess
# main.sx -E-extern 直接 import 的模块；变更须重生成 driver_gen.c / driver_sx.o
MAIN_SX_DEPS = src/main.sx src/codegen/codegen.sx src/ast/ast.sx src/preprocess/preprocess.sx
# preprocess.sx 独立 -E-extern 入口
PREPROCESS_SX_DEPS = src/preprocess/preprocess.sx
.PHONY: all std-objs clean test size-baseline perf-baseline bootstrap-token bootstrap-lexer bootstrap-parser bootstrap-parse-file bootstrap-typeck bootstrap-codegen bootstrap-driver bootstrap-driver-seed bootstrap-driver-bstrict bootstrap-driver-bstrict-relink bootstrap-driver-bstrict-windows bootstrap-driver-crt0 bootstrap-driver-asm bootstrap-driver-asm-only bootstrap-asm bootstrap_shuxc check-asm-o-quality check-6.4 bootstrap-self check-7.2 check-7.2-bstrict bootstrap-verify bootstrap-verify-seed bootstrap-verify-bstrict bootstrap-verify-stage2 bootstrap-verify-stage2-bstrict bootstrap-test build-tool build-tool-sx build-via-tool first-time verify-selfhost-stage2 regen-lsp-gens-sx shux-no-c-frontend gen-sx-driver-objs build-user-asm-backend build-seed-user-asm-partial bootstrap-driver-seed-user-asm compile_commands.json

# std.process：F-process v2 纯 .sx（F-ZC）；OS 胶层在 runtime_process_os_glue.o；import binding 别名桩 process_import_alias.c。
../std/process/process.o: ../std/process/process.sx ../std/process/process_import_alias.c
	@if [ -x ./shux-c ]; then \
	  ./shux-c -L .. ../std/process/process.sx -o ../std/process/process_core.o; \
	elif [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/process/process.sx -o ../std/process/process_core.o; \
	else echo "make process.o: need shux-c or shux_asm (F-process v2)" >&2; exit 1; fi; \
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/process/process_import_alias.o ../std/process/process_import_alias.c && \
	ld -r -o ../std/process/process.o ../std/process/process_core.o ../std/process/process_import_alias.o && \
	rm -f ../std/process/process_core.o ../std/process/process_import_alias.o

# std.string：F-string v1 纯 .sx（string.sx）；import binding 别名桩 string_import_alias.c。
../std/string/string.o: ../std/string/string.sx ../std/string/string_import_alias.c
	@if [ -x ./shux-c ]; then \
	  ./shux-c -L .. ../std/string/string.sx -o ../std/string/string_core.o; \
	elif [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/string/string.sx -o ../std/string/string_core.o; \
	else echo "make string.o: need shux-c or shux_asm (F-string v1)" >&2; exit 1; fi; \
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/string/string_import_alias.o ../std/string/string_import_alias.c && \
	ld -r -o ../std/string/string.o ../std/string/string_core.o ../std/string/string_import_alias.o && \
	rm -f ../std/string/string_core.o ../std/string/string_import_alias.o

# std.path：F-path v1 纯 .sx（path_sep_c 内联 cfg）；mod.sx 编译为 path.o。
../std/path/path.o: ../std/path/mod.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make path.o: need shux-c or shux (F-path v1)" >&2; exit 1; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/path/mod.sx ../std/path/path.o

# std.heap：F-03 纯 .sx 优先；typeck 未 relink 进 shux_asm 时回退 heap_import_alias.c。
../std/heap/heap.o: ../std/heap/mod.sx ../std/heap/heap_import_alias.c
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else shux=; fi; \
	if [ -n "$$shux" ] && sh scripts/shux_compile_std_sx.sh $$shux ../std/heap/mod.sx ../std/heap/heap.o 2>/dev/null; then \
	  exit 0; \
	fi; \
	echo "make heap.o: sx emit failed, fallback heap_import_alias.c" >&2; \
	$(CC) $(CFLAGS) -fPIE -c -o $@ ../std/heap/heap_import_alias.c

# std.map：纯 .sx 优先；失败回退 map_import_alias.c。
../std/map/map.o: ../std/map/mod.sx ../std/map/map_import_alias.c
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else shux=; fi; \
	if [ -n "$$shux" ] && sh scripts/shux_compile_std_sx.sh $$shux ../std/map/mod.sx ../std/map/map.o 2>/dev/null; then \
	  exit 0; \
	fi; \
	echo "make map.o: sx emit failed, fallback map_import_alias.c" >&2; \
	$(CC) $(CFLAGS) -fPIE -c -o $@ ../std/map/map_import_alias.c

# std.set：纯 .sx 优先；失败回退 set_import_alias.c。
../std/set/set.o: ../std/set/mod.sx ../std/set/set_import_alias.c
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else shux=; fi; \
	if [ -n "$$shux" ] && sh scripts/shux_compile_std_sx.sh $$shux ../std/set/mod.sx ../std/set/set.o 2>/dev/null; then \
	  exit 0; \
	fi; \
	echo "make set.o: sx emit failed, fallback set_import_alias.c" >&2; \
	$(CC) $(CFLAGS) -fPIE -c -o $@ ../std/set/set_import_alias.c

# std.runtime：panic/abort 对接 shux_panic_（std/runtime/runtime.c）；链接时需与 runtime_panic.o 同链。
# std.runtime：F-runtime v1 纯 .sx（runtime.sx）；零胶层 C。
../std/runtime/runtime.o: ../std/runtime/runtime.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make runtime.o: need shux-c or shux (F-runtime v1)" >&2; exit 1; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/runtime/runtime.sx ../std/runtime/runtime.o

# std.net：F-04 v10～v14 纯 .sx（F-ZC）；import binding 别名桩 net_import_alias.c。
../std/net/net.o: ../std/net/alpn.sx ../std/net/dns.sx ../std/net/io_batch.sx ../std/net/addr.sx ../std/net/ipv6.sx ../std/net/sock.sx ../std/net/udp.sx ../std/net/tcp.sx ../std/net/udp_batch.sx ../std/net/workers.sx ../std/net/net_import_alias.c
	@objs=""; \
	shux="$${SHUX:-}"; \
	if [ -z "$$shux" ] || [ ! -x "$$shux" ]; then \
	  if [ -x ./shux ]; then shux=./shux; \
	  elif [ -x ./shux_asm ]; then shux=./shux_asm; \
	  elif [ -x ./shux-c ]; then shux=./shux-c; \
	  else shux=; fi; \
	fi; \
	if [ -n "$$shux" ]; then \
	  for sx in alpn dns io_batch addr ipv6 sock udp tcp udp_batch workers; do \
	    sh scripts/shux_compile_std_sx.sh $$shux ../std/net/$$sx.sx ../std/net/$$sx.o || exit 1; \
	    objs="$$objs ../std/net/$$sx.o"; \
	  done; \
	  $(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/net/net_import_alias.o ../std/net/net_import_alias.c && \
	  ld -r --allow-multiple-definition -o $@ $$objs ../std/net/net_import_alias.o; \
	else \
	  echo "net.o: need shux-c to merge net_*.sx"; exit 0; \
	fi

net-o-stub:
	$(MAKE) ../std/net/net.o

# TLS：F-04 v8 net-o-openssl 编译 std/net/tls_openssl.sx（不再 #include tls_openssl.inc.c）。
net-o-openssl:
	@if [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/net/tls_openssl.sx -o ../std/net/tls_openssl.o && \
	  $(MAKE) net-o-stub; \
	elif [ -x ./shux ]; then \
	  ./shux -backend asm -L .. ../std/net/tls_openssl.sx -o ../std/net/tls_openssl.o && \
	  $(MAKE) net-o-stub; \
	elif [ -x ./shux-c ]; then \
	  ./shux-c -backend c -L .. ../std/net/tls_openssl.sx -o ../std/net/tls_openssl.o && \
	  $(MAKE) net-o-stub; \
	else \
	  echo "net-o-openssl: need shux_asm, shux, or shux-c"; exit 1; \
	fi

net-o-mbedtls:
	@if [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/net/tls_mbedtls.sx -o ../std/net/tls_mbedtls_main.o && \
	  $(MAKE) runtime_tls_mbedtls_bio.o && \
	  ld -r -o ../std/net/tls_mbedtls.o ../std/net/tls_mbedtls_main.o runtime_tls_mbedtls_bio.o && \
	  $(MAKE) net-o-stub; \
	elif [ -x ./shux ]; then \
	  ./shux -backend asm -L .. ../std/net/tls_mbedtls.sx -o ../std/net/tls_mbedtls_main.o && \
	  $(MAKE) runtime_tls_mbedtls_bio.o && \
	  ld -r -o ../std/net/tls_mbedtls.o ../std/net/tls_mbedtls_main.o runtime_tls_mbedtls_bio.o && \
	  $(MAKE) net-o-stub; \
	elif [ -x ./shux-c ]; then \
	  ./shux-c -backend c -L .. ../std/net/tls_mbedtls.sx -o ../std/net/tls_mbedtls_main.o && \
	  $(MAKE) runtime_tls_mbedtls_bio.o && \
	  ld -r -o ../std/net/tls_mbedtls.o ../std/net/tls_mbedtls_main.o runtime_tls_mbedtls_bio.o && \
	  $(MAKE) net-o-stub; \
	else \
	  echo "net-o-mbedtls: need shux_asm, shux, or shux-c"; exit 1; \
	fi

# std.thread：F-thread v2 纯 .sx（F-ZC）；pthread 胶层在 runtime_thread_glue.o；Unix 需 -lpthread。
../std/thread/thread.o: ../std/thread/thread.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make thread.o: need shux-c or shux (F-thread zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/thread/thread.sx ../std/thread/thread.o

# std.async：F-async v2 纯 .sx（F-ZC）；调度胶层在 runtime_scheduler_glue.o；Unix 按需 -pthread。
../std/async/scheduler.o: ../std/async/scheduler.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make scheduler.o: need shux-c or shux (F-async zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/async/scheduler.sx ../std/async/scheduler.o

# std.async：F-async-future v2 纯 .sx → future.o（同 hash/cache）。
../std/async/future.o: ../std/async/future.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "future.o: need shux-c or shux (F-async-future v2)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/async/future.sx ../std/async/future.o

# std.time：F-time v2 纯 .sx（F-ZC）；OS syscall 在 runtime_time_os.o；import binding 别名桩 time_import_alias.c。
../std/time/time.o: ../std/time/time.sx ../std/time/time_import_alias.c
	@if [ -x ./shux-c ]; then \
	  ./shux-c -L .. ../std/time/time.sx -o ../std/time/time_core.o; \
	elif [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/time/time.sx -o ../std/time/time_core.o; \
	else echo "make time.o: need shux-c or shux_asm (F-time v1)" >&2; exit 1; fi; \
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/time/time_import_alias.o ../std/time/time_import_alias.c && \
	ld -r -o ../std/time/time.o ../std/time/time_core.o ../std/time/time_import_alias.o && \
	rm -f ../std/time/time_core.o ../std/time/time_import_alias.o

# std.random：F-random v2 纯 .sx（F-ZC）；CSPRNG OS 在 runtime_random_fill.o。
../std/random/random.o: ../std/random/random.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make random.o: need shux-c or shux (F-random zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/random/random.sx ../std/random/random.o

# std.env：F-env v2 纯 .sx（F-ZC）；OS 胶层在 runtime_env_os.o。
../std/env/env.o: ../std/env/env.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make env.o: need shux-c or shux (F-env zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/env/env.sx ../std/env/env.o

# std.sync：F-sync v3 纯 .sx（F-ZC）；OS/TLS 胶层在 runtime_sync_*.o；import binding 别名桩 sync_import_alias.c。
../std/sync/sync.o: ../std/sync/sync.sx ../std/sync/sync_import_alias.c
	@if [ -x ./shux-c ]; then \
	  ./shux-c -L .. ../std/sync/sync.sx -o ../std/sync/sync_core.o; \
	elif [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/sync/sync.sx -o ../std/sync/sync_core.o; \
	else echo "make sync.o: need shux-c or shux_asm (F-sync v3)" >&2; exit 1; fi; \
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/sync/sync_import_alias.o ../std/sync/sync_import_alias.c && \
	ld -r -o ../std/sync/sync.o ../std/sync/sync_core.o ../std/sync/sync_import_alias.o && \
	rm -f ../std/sync/sync_core.o ../std/sync/sync_import_alias.o

# std.queue：F-queue v2 纯 .sx（F-ZC）；pthread 胶层在 runtime_queue_contention.o。
../std/queue/queue.o: ../std/queue/queue.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make queue.o: need shux-c or shux (F-queue zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/queue/queue.sx ../std/queue/queue.o

# std.encoding：F-encoding v1 纯 .sx（encoding.sx）；import binding 别名桩 encoding_import_alias.c。
../std/encoding/encoding.o: ../std/encoding/encoding.sx ../std/encoding/encoding_import_alias.c
	@if [ -x ./shux-c ]; then \
	  ./shux-c -L .. ../std/encoding/encoding.sx -o ../std/encoding/encoding_core.o; \
	elif [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/encoding/encoding.sx -o ../std/encoding/encoding_core.o; \
	else echo "make encoding.o: need shux-c or shux_asm (F-encoding v1)" >&2; exit 1; fi; \
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/encoding/encoding_import_alias.o ../std/encoding/encoding_import_alias.c && \
	ld -r -o ../std/encoding/encoding.o ../std/encoding/encoding_core.o ../std/encoding/encoding_import_alias.o && \
	rm -f ../std/encoding/encoding_core.o ../std/encoding/encoding_import_alias.o

# std.base64：F-base64 v1 纯 .sx（base64.sx）；import binding 别名桩 base64_import_alias.c。
../std/base64/base64.o: ../std/base64/base64.sx ../std/base64/base64_import_alias.c
	@if [ -x ./shux-c ]; then \
	  ./shux-c -L .. ../std/base64/base64.sx -o ../std/base64/base64_core.o; \
	elif [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/base64/base64.sx -o ../std/base64/base64_core.o; \
	else echo "make base64.o: need shux-c or shux_asm (F-base64 v1)" >&2; exit 1; fi; \
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/base64/base64_import_alias.o ../std/base64/base64_import_alias.c && \
	ld -r -o ../std/base64/base64.o ../std/base64/base64_core.o ../std/base64/base64_import_alias.o && \
	rm -f ../std/base64/base64_core.o ../std/base64/base64_import_alias.o

# std.crypto：F-crypto v2 纯 .sx（F-ZC）；SHA-512/ref10 胶层在 runtime_crypto_*_glue.o。
../std/crypto/crypto.o: ../std/crypto/core.sx ../std/crypto/aes_gcm.sx ../std/crypto/chacha20_poly1305.sx ../std/crypto/chacha20_aead.sx ../std/crypto/ed25519.sx
	@objs=""; \
	if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else shux=; fi; \
	if [ -n "$$shux" ]; then \
	  sh scripts/shux_compile_std_sx.sh auto ../std/crypto/core.sx ../std/crypto/core.o || exit 1; \
	  sh scripts/shux_compile_std_sx.sh auto ../std/crypto/aes_gcm.sx ../std/crypto/aes_gcm.o || exit 1; \
	  sh scripts/shux_compile_std_sx.sh auto ../std/crypto/chacha20_poly1305.sx ../std/crypto/chacha20_poly1305.o || exit 1; \
	  sh scripts/shux_compile_std_sx.sh auto ../std/crypto/chacha20_aead.sx ../std/crypto/chacha20_aead.o || exit 1; \
	  sh scripts/shux_compile_std_sx.sh auto ../std/crypto/ed25519.sx ../std/crypto/ed25519.o || exit 1; \
	  objs="../std/crypto/core.o ../std/crypto/aes_gcm.o ../std/crypto/chacha20_poly1305.o ../std/crypto/chacha20_aead.o ../std/crypto/ed25519.o"; \
	  ld -r -o $@ $$objs; \
	else \
	  echo "crypto.o: need shux-c to merge crypto .sx"; exit 0; \
	fi

# std.log：F-log v2 纯 .sx（F-ZC）；OS 胶层在 runtime_log_os.o。
# LANG-007 v2：shux-c -E → cc -c 库模块；fallback shux_compile_std_sx.sh。
../std/log/log.o: ../std/log/log.sx
	@if [ -x ./shux-c ]; then \
	  ./shux-c -E -L .. ../std/log/log.sx > ../std/log/log_core_gen.c && \
	  $(CC) $(CFLAGS) -c -o ../std/log/log.o ../std/log/log_core_gen.c && \
	  rm -f ../std/log/log_core_gen.c; \
	elif [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	else echo "make log.o: need shux-c or shux (F-log zero-c)" >&2; exit 0; fi; \
	if [ ! -f ../std/log/log.o ]; then \
	  sh scripts/shux_compile_std_sx.sh auto ../std/log/log.sx ../std/log/log.o; \
	fi


# std.test：F-test v2 纯 .sx（F-ZC）；fn-ptr 在 runtime_test_fn_invoke.o。
../std/test/test.o: ../std/test/test.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make test.o: need shux-c or shux (F-test zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/test/test.sx ../std/test/test.o

# std.atomic：F-atomic v2 纯 .sx（F-ZC）；原子胶层在 runtime_atomic_glue.o；import binding 别名桩 atomic_import_alias.c。
../std/atomic/atomic.o: ../std/atomic/atomic.sx ../std/atomic/atomic_import_alias.c
	@if [ -x ./shux-c ]; then \
	  ./shux-c -L .. ../std/atomic/atomic.sx -o ../std/atomic/atomic_core.o; \
	elif [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/atomic/atomic.sx -o ../std/atomic/atomic_core.o; \
	else echo "make atomic.o: need shux-c or shux_asm (F-atomic v2)" >&2; exit 1; fi; \
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/atomic/atomic_import_alias.o ../std/atomic/atomic_import_alias.c && \
	ld -r -o ../std/atomic/atomic.o ../std/atomic/atomic_core.o ../std/atomic/atomic_import_alias.o && \
	rm -f ../std/atomic/atomic_core.o ../std/atomic/atomic_import_alias.o

# std.channel：F-channel v2 纯 .sx（F-ZC）；channel 胶层在 runtime_channel_glue.o；Unix 需 -lpthread。
../std/channel/channel.o: ../std/channel/channel.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make channel.o: need shux-c or shux (F-channel zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/channel/channel.sx ../std/channel/channel.o

# std.backtrace：F-backtrace v2 纯 .sx（F-ZC）；平台胶层在 runtime_backtrace_platform.o。
../std/backtrace/backtrace.o: ../std/backtrace/backtrace.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make backtrace.o: need shux-c or shux (F-backtrace zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/backtrace/backtrace.sx ../std/backtrace/backtrace.o

# std.hash：F-hash v2 纯 .sx → hash.o（同 json/schema）。
../std/hash/hash.o: ../std/hash/hash.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "hash.o: need shux-c or shux (F-hash v2)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/hash/hash.sx ../std/hash/hash.o

# std.math：F-math v2 纯 .sx（F-ZC）；libm 胶层在 runtime_math_libm.o（链接 exe 仍须 -lm）。
# LANG-007 v2：shux-c -E → cc -c 库模块；fallback shux_compile_std_sx.sh。
../std/math/math.o: ../std/math/math.sx
	@if [ -x ./shux-c ]; then \
	  ./shux-c -E -L .. ../std/math/math.sx > ../std/math/math_core_gen.c && \
	  $(CC) $(CFLAGS) -c -o ../std/math/math.o ../std/math/math_core_gen.c && \
	  rm -f ../std/math/math_core_gen.c; \
	elif [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	else echo "make math.o: need shux-c or shux (F-math zero-c)" >&2; exit 0; fi; \
	if [ ! -f ../std/math/math.o ]; then \
	  sh scripts/shux_compile_std_sx.sh auto ../std/math/math.sx ../std/math/math.o; \
	fi

# std.sort：F-sort v1 纯 .sx（sort.sx）；无胶层 C。
../std/sort/sort.o: ../std/sort/sort.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make sort.o: need shux-c or shux (F-sort v1)" >&2; exit 1; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/sort/sort.sx ../std/sort/sort.o

# G-01：core/ 零 C — 位运算/volatile/slice 已纯 .sx（见 analysis/phase-g-full-selfhost-tasks-v1.md）

# std.ffi：F-ffi v1 + F-ZC 纯 ffi.sx；import binding 别名桩 ffi_import_alias.c。
# LANG-007 v2：shux-c 默认 sx pipeline 对 ffi.sx typeck 仍红；库模块用 -backend c -E → cc -c。
../std/ffi/ffi.o: ../std/ffi/ffi.sx ../std/ffi/ffi_import_alias.c
	@if [ -x ./shux-c ]; then \
	  ./shux-c -backend c -E -L .. ../std/ffi/ffi.sx > ../std/ffi/ffi_core_gen.c && \
	  $(CC) $(CFLAGS) -c -o ../std/ffi/ffi_core.o ../std/ffi/ffi_core_gen.c && \
	  rm -f ../std/ffi/ffi_core_gen.c; \
	elif [ -x ./shux_asm ]; then \
	  env SHUX_ASM_WPO_DCE=0 ./shux_asm -backend asm -L .. ../std/ffi/ffi.sx -o ../std/ffi/ffi_core.o; \
	else echo "make ffi.o: need shux-c or shux_asm (F-ffi v1)" >&2; exit 1; fi; \
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/ffi/ffi_import_alias.o ../std/ffi/ffi_import_alias.c && \
	ld -r -o ../std/ffi/ffi.o ../std/ffi/ffi_core.o ../std/ffi/ffi_import_alias.o && \
	rm -f ../std/ffi/ffi_core.o ../std/ffi/ffi_import_alias.o


# std.context：F-context v2 纯 context.sx → context.o（无 glue；无 shux 时 exit 0）。
../std/context/context.o: ../std/context/context.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "context.o: need shux-c or shux (F-context v2)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/context/context.sx ../std/context/context.o


# std.datetime：F-datetime v2 + F-ZC 纯 datetime.sx → datetime.o（无 glue；无 shux 时 exit 0）。
../std/datetime/datetime.o: ../std/datetime/datetime.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "datetime.o: need shux-c or shux (F-datetime zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/datetime/datetime.sx ../std/datetime/datetime.o

# std.uuid：F-uuid v1 纯 .sx（uuid.sx）；依赖 random.o + time.o。
../std/uuid/uuid.o: ../std/uuid/uuid.sx ../std/random/random.o ../std/time/time.o
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make uuid.o: need shux-c or shux (F-uuid v1)" >&2; exit 1; fi; \
	$(MAKE) -q ../std/random/random.o 2>/dev/null || $(MAKE) ../std/random/random.o; \
	$(MAKE) -q ../std/time/time.o 2>/dev/null || $(MAKE) ../std/time/time.o; \
	sh scripts/shux_compile_std_sx.sh auto ../std/uuid/uuid.sx ../std/uuid/uuid.o

# std.url：F-url v2 + F-ZC 纯 url.sx → url.o（无 glue；无 shux 时 exit 0）。
../std/url/url.o: ../std/url/url.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "url.o: need shux-c or shux (F-url v2 zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/url/url.sx ../std/url/url.o

# std.cli：命令行解析（std/cli/cli.c）。
# std.cli：F-cli v1 纯 .sx（cli.sx）；零胶层 C。
../std/cli/cli.o: ../std/cli/cli.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make cli.o: need shux-c or shux (F-cli v1)" >&2; exit 1; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/cli/cli.sx ../std/cli/cli.o


# std.security：F-security v1 + F-ZC 纯 security.sx → security.o（无 glue；无 shux 时 exit 0）。
../std/security/security.o: ../std/security/security.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "security.o: need shux-c or shux (F-security zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/security/security.sx ../std/security/security.o


# std.config：F-config v2 + F-ZC 纯 config.sx → config.o（无 glue；无 shux 时 exit 0）。
../std/config/config.o: ../std/config/config.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "config.o: need shux-c or shux (F-config v2 zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/config/config.sx ../std/config/config.o

# std.cache：F-cache v2 纯 .sx（cache.sx）；零胶层 C。
../std/cache/cache.o: ../std/cache/cache.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "cache.o: need shux-c or shux (F-cache v2)" >&2; exit 1; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/cache/cache.sx ../std/cache/cache.o

# std.trace：F-trace v2 纯 trace.sx → trace.o（无 glue；无 shux 时 exit 0）。
../std/trace/trace.o: ../std/trace/trace.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "trace.o: need shux-c or shux (F-trace v2)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/trace/trace.sx ../std/trace/trace.o


# std.task：F-task v2 纯 .sx → task.o（同 trace/cache v2）。
../std/task/task.o: ../std/task/task.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "task.o: need shux-c or shux (F-task v2)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/task/task.sx ../std/task/task.o


# std.schema：F-schema v2 纯 .sx → schema.o（同 cache/encoding）。
../std/schema/schema.o: ../std/schema/schema.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "schema.o: need shux-c or shux (F-schema v2)" >&2; exit 1; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/schema/schema.sx ../std/schema/schema.o

# std.db.kv：F-05 v2 纯 .sx（F-ZC）；mmap 胶层在 runtime_kv_mmap_glue.o。
../std/db/kv/kv.o: ../std/db/kv/kv.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make kv.o: need shux-c or shux (F-db-kv zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/db/kv/kv.sx ../std/db/kv/kv.o

# std.db.arrow：F-05 v1 纯 .sx（F-ZC）；SIMD 胶层在 runtime_arrow_simd_glue.o。
../std/db/arrow/arrow.o: ../std/db/arrow/arrow.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make arrow.o: need shux-c or shux (F-db-arrow zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/db/arrow/arrow.sx ../std/db/arrow/arrow.o

# std.sys.mmap：F-02 v1 Linux/macOS 纯 .sx（已移除 mmap.inc.c）
# std.sys.win32：F-02 v2 纯 .sx kernel32 FFI（已移除 win32.inc.c / win32_net.inc.c）

# E-04 v21：Windows/MinGW/MSYS 宿主探测（MAIN_LINK_O=crt0_mingw.o）
SHUX_IS_WIN_HOST :=
ifeq ($(OS),Windows_NT)
SHUX_IS_WIN_HOST := 1
else
ifneq ($(findstring MINGW,$(UNAME_S)),)
SHUX_IS_WIN_HOST := 1
else
ifneq ($(findstring MSYS,$(UNAME_S)),)
SHUX_IS_WIN_HOST := 1
endif
endif
endif

# std.db.sqlite：F-05 v3 纯 .sx（F-ZC）；sqlite3 胶层在 runtime_sqlite_glue.o。
../std/db/sqlite/sqlite.o: ../std/db/sqlite/sqlite.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make sqlite.o: need shux-c or shux (F-db-sqlite zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/db/sqlite/sqlite.sx ../std/db/sqlite/sqlite.o
sqlite-o: ../std/db/sqlite/sqlite.o runtime_sqlite_glue.o
sqlite-o-stub:
	$(MAKE) runtime_sqlite_glue_stub.o
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else shux=; fi; \
	if [ -n "$$shux" ]; then \
	  sh scripts/shux_compile_std_sx.sh auto ../std/db/sqlite/sqlite.sx ../std/db/sqlite/sqlite_main.o || exit 1; \
	  ld -r -o ../std/db/sqlite/sqlite.o ../std/db/sqlite/sqlite_main.o runtime_sqlite_glue_stub.o; \
	else \
	  ld -r -o ../std/db/sqlite/sqlite.o runtime_sqlite_glue_stub.o; \
	  echo "sqlite.o-stub: need shux-c to merge sqlite.sx"; \
	fi

# std.elf：F-elf v2 + F-ZC 纯 elf.sx → elf.o（无 glue；无 shux 时 exit 0）。
../std/elf/elf.o: ../std/elf/elf.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "elf.o: need shux-c or shux (F-elf v2 zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/elf/elf.sx ../std/elf/elf.o

# P4 std 模块（按需链接）
# std.json：F-json v2 纯 json.sx；import binding 别名桩 json_import_alias.c。
# LANG-007 v2：shux-c -E → cc -c 库模块；fallback shux_asm。
../std/json/json.o: ../std/json/json.sx ../std/json/json_import_alias.c
	@if [ -x ./shux-c ]; then \
	  ./shux-c -E -L .. ../std/json/json.sx > ../std/json/json_core_gen.c && \
	  $(CC) $(CFLAGS) -c -o ../std/json/json_core.o ../std/json/json_core_gen.c && \
	  rm -f ../std/json/json_core_gen.c; \
	elif [ -x ./shux_asm ]; then \
	  sh scripts/shux_compile_std_sx.sh ./shux_asm ../std/json/json.sx ../std/json/json_core.o; \
	else echo "make json.o: need shux-c or shux_asm (F-json v2)" >&2; exit 1; fi; \
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/json/json_import_alias.o ../std/json/json_import_alias.c && \
	ld -r -o ../std/json/json.o ../std/json/json_core.o ../std/json/json_import_alias.o && \
	rm -f ../std/json/json_core.o ../std/json/json_import_alias.o
# std.csv：F-csv v1 纯 .sx（csv.sx）；import binding 别名桩 csv_import_alias.c（std_csv_escape）。
../std/csv/csv.o: ../std/csv/csv.sx ../std/csv/csv_import_alias.c
	@if [ -x ./shux-c ]; then \
	  ./shux-c -L .. ../std/csv/csv.sx -o ../std/csv/csv_core.o; \
	elif [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/csv/csv.sx -o ../std/csv/csv_core.o; \
	else echo "make csv.o: need shux-c or shux_asm (F-csv v1)" >&2; exit 1; fi; \
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/csv/csv_import_alias.o ../std/csv/csv_import_alias.c && \
	ld -r --allow-multiple-definition -o ../std/csv/csv.o ../std/csv/csv_import_alias.o ../std/csv/csv_core.o && \
	rm -f ../std/csv/csv_core.o ../std/csv/csv_import_alias.o
# std.regex：F-regex v2 纯 .sx → regex.o（同 hash/schema）。
../std/regex/regex.o: ../std/regex/regex.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "regex.o: need shux-c or shux (F-regex v2)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/regex/regex.sx ../std/regex/regex.o
# F-04 v7：std.compress 全格式已迁 .sx；compress.o 不再构建，保留 target 名兼容门禁。
compress-o-zlib compress-o-zlib-zstd compress-o-brotli compress-o-zlib-zstd-brotli:
	@true
# std.unicode：F-unicode v2 纯 .sx → unicode.o（同 hash/schema）。
../std/unicode/unicode.o: ../std/unicode/unicode.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "unicode.o: need shux-c or shux (F-unicode v2)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/unicode/unicode.sx ../std/unicode/unicode.o
# std.dynlib：F-dynlib v2 纯 .sx（F-ZC）；dlopen 胶层在 runtime_dynlib_os.o。
../std/dynlib/dynlib.o: ../std/dynlib/dynlib.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make dynlib.o: need shux-c or shux (F-dynlib zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/dynlib/dynlib.sx ../std/dynlib/dynlib.o
# std.http：F-http v2 纯 .sx（F-ZC）；HTTP 胶层在 runtime_http_glue.o；import binding 别名桩 http_import_alias.c。
../std/http/http.o: ../std/http/http.sx ../std/http/http_import_alias.c
	@if [ -x ./shux-c ]; then \
	  ./shux-c -L .. ../std/http/http.sx -o ../std/http/http_core.o; \
	elif [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/http/http.sx -o ../std/http/http_core.o; \
	else echo "make http.o: need shux-c or shux_asm (F-http v2)" >&2; exit 1; fi; \
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/http/http_import_alias.o ../std/http/http_import_alias.c && \
	ld -r -o ../std/http/http.o ../std/http/http_core.o ../std/http/http_import_alias.o && \
	rm -f ../std/http/http_core.o ../std/http/http_import_alias.o

# std.socketio：F-socketio v2 纯 socketio.sx；ld -r 合并为 socketio.o（P3 可选）。
../std/socketio/socketio.o: ../std/socketio/socketio.sx
	@objs=""; \
	if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else \
	  echo "socketio.o: need shux-c to compile socketio.sx"; exit 0; \
	fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/socketio/socketio.sx ../std/socketio/socketio_main.o || exit 1; \
	objs="$$objs ../std/socketio/socketio_main.o"; \
	$(LD) $(LD_RELFLAGS) -r -o $@ $$objs
# std.tar：F-tar v2 纯 tar.sx；import binding 别名桩 tar_import_alias.c。
../std/tar/tar.o: ../std/tar/tar.sx ../std/tar/tar_import_alias.c
	@if [ -x ./shux-c ]; then \
	  ./shux-c -L .. ../std/tar/tar.sx -o ../std/tar/tar_core.o; \
	elif [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/tar/tar.sx -o ../std/tar/tar_core.o; \
	else echo "make tar.o: need shux-c or shux_asm (F-tar v2)" >&2; exit 1; fi; \
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o ../std/tar/tar_import_alias.o ../std/tar/tar_import_alias.c && \
	ld -r --allow-multiple-definition -o ../std/tar/tar.o ../std/tar/tar_import_alias.o ../std/tar/tar_core.o && \
	rm -f ../std/tar/tar_core.o ../std/tar/tar_import_alias.o
# std.simd：F-simd v1 + F-ZC 纯 simd.sx → simd.o（无 glue；无 shux 时 exit 0）。
../std/simd/simd.o: ../std/simd/simd.sx
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "simd.o: need shux-c or shux (F-simd zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_sx.sh auto ../std/simd/simd.sx ../std/simd/simd.o


# 测试与 shux 链接 std 时依赖的 .o：所有 std 模块 + runtime_panic.o；Linux 另预编 freestanding 链入桩
STD_AND_PANIC_O = ../std/process/process.o ../std/string/string.o ../std/path/path.o ../std/runtime/runtime.o ../std/net/net.o ../std/thread/thread.o ../std/async/scheduler.o ../std/time/time.o ../std/random/random.o ../std/env/env.o ../std/sync/sync.o ../std/encoding/encoding.o ../std/base64/base64.o ../std/crypto/crypto.o ../std/log/log.o ../std/atomic/atomic.o ../std/channel/channel.o ../std/backtrace/backtrace.o ../std/hash/hash.o ../std/math/math.o ../std/sort/sort.o ../std/ffi/ffi.o ../std/json/json.o ../std/csv/csv.o ../std/regex/regex.o ../std/unicode/unicode.o ../std/dynlib/dynlib.o ../std/http/http.o ../std/tar/tar.o ../std/simd/simd.o ../std/context/context.o ../std/trace/trace.o ../std/test/test.o runtime_panic.o runtime_asm_io_stubs.o runtime_process_argv.o runtime_process_os_glue.o runtime_test_fn_invoke.o runtime_random_fill.o runtime_time_os.o runtime_dynlib_os.o runtime_env_os.o runtime_backtrace_platform.o runtime_log_os.o runtime_math_libm.o runtime_atomic_glue.o runtime_channel_glue.o runtime_net_udp_batch.o runtime_net_workers.o runtime_sync_os.o runtime_sync_lock_diag_tls.o runtime_thread_glue.o runtime_scheduler_glue.o runtime_http_glue.o runtime_crypto_inc_glue.o runtime_ed25519_ref10_glue.o
ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
STD_AND_PANIC_O += crt0_user.o freestanding_io.o
endif
endif

# 同时链出 shux-c：与 pipeline/lsp/build_gen 的 -E 生成及 test_c 前置一致，避免仅 make all 后缺少 shux-c。
# SHUX_RUN_ALL_BOOTSTRAP_SHUX=1：run-all 显式 SHUX=seed 时子脚本 `make -C compiler` 须保持 bootstrap 链，禁止 C-only all 覆盖 shux。
# 默认 all 不构建 STD_AND_PANIC_O（shux-c 无 -backend 解析；按需 `make std-objs` 或单条 ../std/*/*.o）。
ifeq ($(SHUX_RUN_ALL_BOOTSTRAP_SHUX),1)
all: bootstrap-driver-seed
else
all: $(TARGET) $(SHUX_C)
std-objs: $(STD_AND_PANIC_O)
endif

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# G-06：默认 shux-c = bootstrap_shuxc 预编译种子（无 cc 编 OBJS_CORE）；考古：SHUX_LEGACY_C_FRONTEND=1。
bootstrap_shuxc: scripts/bootstrap_shuxc_create.sh scripts/select_bootstrap_shuxc.sh
	@chmod +x scripts/select_bootstrap_shuxc.sh 2>/dev/null || true
	@./scripts/select_bootstrap_shuxc.sh

# 考古 shux-c 额外链 runtime ABI 薄壳（runtime.c 已拆分，LEGACY C 前端仍依赖这些符号）
LEGACY_SHUX_C_EXTRA = src/runtime_abi.o src/runtime_io_abi.o src/runtime_proc_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o src/runtime_c_import.o src/runtime_pipeline_abi_shux_c_stubs.o _stubs_driver.o

ifeq ($(SHUX_LEGACY_C_FRONTEND),1)
$(SHUX_C): $(OBJS_CORE) $(LEGACY_SHUX_C_EXTRA)
	$(CC) $(CFLAGS) -o $@ $^ $(PIPELINE_LIBS)

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

src/lsp/lsp_diag.o: src/lsp/lsp_diag.c src/lsp/lsp_diag.h
	$(CC) $(CFLAGS) -c -o $@ $<
else
$(SHUX_C): bootstrap_shuxc
	@cp -f bootstrap_shuxc $@
endif

src/main.o: src/main.c
	$(CC) $(CFLAGS) -c -o $@ $<

# E-04 v2/v3：argv/target 与 POSIX I/O ABI 薄壳；默认 seed / B-strict 均链入。
src/runtime_abi.o: src/runtime_abi.c src/runtime_abi.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/runtime_io_abi.o: src/runtime_io_abi.c src/runtime_io_abi.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/runtime_proc_abi.o: src/runtime_proc_abi.c src/runtime_proc_abi.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/runtime_link_abi.o: src/runtime_link_abi.c src/runtime_link_abi.h src/runtime_proc_abi.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/runtime_driver_abi.o: src/runtime_driver_abi.c src/runtime_driver_abi.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/runtime_pipeline_abi.o: src/runtime_pipeline_abi.c src/runtime_pipeline_abi.h Makefile
	$(CC) $(CFLAGS) $(RUNTIME_PIPELINE_ABI_CFLAGS) -c -o $@ $<

src/runtime_c_import.o: src/runtime_c_import.c src/runtime_c_import.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/runtime_driver_diagnostic.o: src/runtime_driver_diagnostic.c src/runtime_driver_diagnostic.h
	$(CC) $(CFLAGS) -c -o $@ $<

# 6.3：runtime.c 提供 run_compiler_c 与弱符号 main_entry；带 .sx 入口时用 runtime_driver.o（含 driver_*/pipeline_*）
src/runtime.o: src/runtime.c
	$(CC) $(CFLAGS) -c -o $@ $<
# Makefile 为 prerequisite：编译宏（如 SHUX_USE_SX_PREPROCESS）变更时须重编，否则 runtime_driver.o 缺 preprocess() 导致链接 Undefined _preprocess。
# SHUX_ASM_USE_COMPILER_IMPL_C：driver_run_compiler_full 走 impl_c（parse_argv+post_parse），避免 compile.sx SX emit 路径 silent fail（与 B-strict shux_asm 同）。
# E-03 v2：SHUX_LEGACY_PREPROCESS_C=1 时 runtime preprocess() 仍调 C preprocess_c_fallback。
RUNTIME_DRIVER_CFLAGS = -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_PREPROCESS -DSHUX_ASM_USE_COMPILER_IMPL_C
RUNTIME_DRIVER_NO_C_CFLAGS = -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_PREPROCESS -DSHUX_NO_C_FRONTEND -DSHUX_ASM_USE_COMPILER_IMPL_C
ifeq ($(SHUX_LEGACY_PREPROCESS_C),1)
RUNTIME_DRIVER_CFLAGS += -DSHUX_LEGACY_PREPROCESS_C
RUNTIME_DRIVER_NO_C_CFLAGS += -DSHUX_LEGACY_PREPROCESS_C
endif
# E-04 v32：pipeline_abi 与 driver 同源 SX preprocess；LEGACY 时走 preprocess_c_fallback。
RUNTIME_PIPELINE_ABI_CFLAGS = -DSHUX_USE_SX_PIPELINE
ifeq ($(SHUX_LEGACY_PREPROCESS_C),1)
RUNTIME_PIPELINE_ABI_CFLAGS += -DSHUX_LEGACY_PREPROCESS_C
endif
src/runtime_driver.o: src/runtime.c Makefile
	$(CC) $(CFLAGS) $(RUNTIME_DRIVER_CFLAGS) -c -o $@ $<

src/preprocess_for_driver.o: src/preprocess.c src/preprocess.h
	$(CC) $(CFLAGS) -DSHUX_USE_SX_PREPROCESS -c -o $@ $<
# shux_sx 用：仅 -DSHUX_USE_SX_PIPELINE，提供 asm_codegen_ast、pipeline_parse_into_buf、main_entry（弱符号）等
src/runtime_sx.o: src/runtime.c
	$(CC) $(CFLAGS) -DSHUX_USE_SX_PIPELINE -c -o $@ $<

src/driver/fmt_check_cmd.o: src/driver/fmt_check_cmd.c
	$(CC) $(CFLAGS) -c -o $@ $<

src/driver/fmt_check_cmd_driver.o: src/driver/fmt_check_cmd.c
	$(CC) $(CFLAGS) -DSHUX_USE_SX_PIPELINE -c -o $@ $<

# G-02a：C 前端 lexer/ast/parser/typeck/codegen/preprocess/autovec/lsp_diag 已物理删除；见对应 .sx。

src/lsp/lsp_codegen_extern.o: src/lsp/lsp_codegen_extern.c src/lsp/lsp_codegen_extern.h
	$(CC) $(CFLAGS) -c -o $@ $<

# SHUX_NO_C_FRONTEND 实验链接：满足 pipeline 对 codegen_set_* 的引用，无 codegen.c
src/codegen/codegen_pipeline_stubs.o: src/codegen/codegen_pipeline_stubs.c include/ast.h src/codegen/codegen.h
	$(CC) $(CFLAGS) -c -o $@ $<

# G-02-B1：cfg_eval 仅 cfg_eval.sx（无 cfg_eval.c 回退）。
# cold bootstrap 时 shux-c -backend asm 可能挂起；timeout 后回退 -E-extern / stub。
src/lexer/cfg_eval.o: src/lexer/cfg_eval.sx src/lexer/cfg_eval_link_alias.c | $(SHUX_C)
	@set -e; \
	rm -f src/lexer/cfg_eval_sx.o; \
	if command -v timeout >/dev/null 2>&1; then \
	  timeout "${SHUX_CFG_EVAL_ASM_TIMEOUT:-120}" ./$(SHUX_C) -backend asm -o src/lexer/cfg_eval_sx.o -L .. src/lexer/cfg_eval.sx 2>/dev/null \
	    || rm -f src/lexer/cfg_eval_sx.o; \
	else \
	  ./$(SHUX_C) -backend asm -o src/lexer/cfg_eval_sx.o -L .. src/lexer/cfg_eval.sx 2>/dev/null \
	    || rm -f src/lexer/cfg_eval_sx.o; \
	fi; \
	if [ -s src/lexer/cfg_eval_sx.o ]; then \
	  $(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o src/lexer/cfg_eval_link_alias.o src/lexer/cfg_eval_link_alias.c; \
	  $(LD) $(LD_RELFLAGS) -r -o $@ src/lexer/cfg_eval_sx.o src/lexer/cfg_eval_link_alias.o; \
	  echo "cfg_eval.o from cfg_eval.sx (-backend asm + alias)"; \
	elif ./$(SHUX_C) -E -E-extern -L .. src/lexer/cfg_eval.sx > src/lexer/cfg_eval_gen.c 2>/dev/null \
	  && [ -s src/lexer/cfg_eval_gen.c ]; then \
	  $(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o src/lexer/cfg_eval_sx.o src/lexer/cfg_eval_gen.c; \
	  $(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o src/lexer/cfg_eval_link_alias.o src/lexer/cfg_eval_link_alias.c; \
	  $(LD) $(LD_RELFLAGS) -r -o $@ src/lexer/cfg_eval_sx.o src/lexer/cfg_eval_link_alias.o; \
	  echo "cfg_eval.o from cfg_eval.sx (-E-extern + alias)"; \
	else \
	  $(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o src/lexer/cfg_eval_bootstrap_stub.o src/lexer/cfg_eval_bootstrap_stub.c && \
	  cp -f src/lexer/cfg_eval_bootstrap_stub.o $@ && \
	  echo "cfg_eval.o from bootstrap stub (cfg_eval.sx unavailable at cold start)"; \
	fi

# G-02a：preprocess 已迁 preprocess.sx；不再编译 preprocess.c。

# runtime.c：不引用 C lexer/parser/typeck/codegen（见 SHUX_NO_C_FRONTEND 包裹的 load_one_import 等）
src/runtime_driver_no_c.o: src/runtime.c Makefile
	$(CC) $(CFLAGS) $(RUNTIME_DRIVER_NO_C_CFLAGS) -c -o $@ $<

# shux_sx 使用带 -DSHUX_USE_SX_PIPELINE 编译的 main，否则 #ifdef 块不会生效
src/main_sx.o: src/main.c
	$(CC) $(CFLAGS) -DSHUX_USE_SX_PIPELINE -c -o $@ $<

PIPELINE_OBJS = src/main_sx.o src/runtime_sx.o src/preprocess.o src/lexer/lexer.o src/ast/ast_seed.o src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o src/codegen/autovec.o
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
PIPELINE_SX_LINK_OBJS = parser_sx.o typeck_sx.o codegen_sx.o src/sx_seed_bridge.o pipeline_bootstrap_orchestration.o $(PIPELINE_SX_SATELLITE_OBJS) $(USER_ASM_LINK)
PIPELINE_SX_SUPPORT_OBJS = build-seed-asm-host $(PIPELINE_SX_LINK_OBJS)

# shux-sx-pipeline：F-03 v2/v3 std.io 纯 .sx；Linux 链 -lpthread（net/thread）；无 -luring。
PIPELINE_LIBS :=
ifeq ($(UNAME_S),Linux)
  PIPELINE_LIBS := -lpthread
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
	$(CC) $(CFLAGS) -fPIE -c -o $@ $<

# F-ZC：std.test fn-ptr invoke；与 test.o 一并链入（见 runtime_test_fn_invoke.c）
runtime_test_fn_invoke.o: src/asm/runtime_test_fn_invoke.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：CSPRNG OS fill；与 random.o 一并链入（见 runtime_random_fill.c）
runtime_random_fill.o: src/asm/runtime_random_fill.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：time OS syscall；与 time.o 一并链入（见 runtime_time_os.c）
runtime_time_os.o: src/asm/runtime_time_os.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：queue 竞争烟测 pthread；与 queue.o 一并链入（见 runtime_queue_contention.c）
runtime_queue_contention.o: src/asm/runtime_queue_contention.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：dynlib dlopen/LoadLibrary；与 dynlib.o 一并链入（见 runtime_dynlib_os.c）
runtime_dynlib_os.o: src/asm/runtime_dynlib_os.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：env OS getenv/setenv/iter；与 env.o 一并链入（见 runtime_env_os.c）
runtime_env_os.o: src/asm/runtime_env_os.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：backtrace capture/symbolicate/crash evidence；与 backtrace.o 一并链入
runtime_backtrace_platform.o: src/asm/runtime_backtrace_platform.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：log sink/轮转/异步；与 log.o 一并链入（见 runtime_log_os.c）
runtime_log_os.o: src/asm/runtime_log_os.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：math libm/fenv；与 math.o 一并链入（须 -lm；见 runtime_math_libm.c）
runtime_math_libm.o: src/asm/runtime_math_libm.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：atomic load/store/CAS/fence；与 atomic.o 一并链入（见 runtime_atomic_glue.c）
runtime_atomic_glue.o: src/asm/runtime_atomic_glue.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：channel 有界/无界/select；与 channel.o 一并链入（Unix 须 -lpthread；见 runtime_channel_glue.c）
runtime_channel_glue.o: src/asm/runtime_channel_glue.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：net UDP batch recvmmsg/sendmmsg；与 net.o 一并链入（见 runtime_net_udp_batch.c）
runtime_net_udp_batch.o: src/asm/runtime_net_udp_batch.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：net accept worker 线程入口；与 net.o 一并链入（见 runtime_net_workers.c）
runtime_net_workers.o: src/asm/runtime_net_workers.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：sync Mutex/RwLock/Condvar + 锁诊断 TLS；与 sync.o 一并链入（Unix 须 -lpthread）
runtime_sync_os.o: src/asm/runtime_sync_os.c
	$(CC) $(CFLAGS) -c -o $@ $<

runtime_sync_lock_diag_tls.o: src/asm/runtime_sync_lock_diag_tls.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：thread pthread/CreateThread；与 thread.o 一并链入（Unix 须 -lpthread）
runtime_thread_glue.o: src/asm/runtime_thread_glue.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：async 协作调度 + async_net_fs；与 scheduler.o 一并链入（按需 -pthread）
runtime_scheduler_glue.o: src/asm/runtime_scheduler_glue.c src/asm/async_net_fs.inc.c
	$(CC) $(CFLAGS) -Isrc/asm -c -o $@ src/asm/runtime_scheduler_glue.c

# F-ZC：HTTP 客户端/服务端胶层（含 http2/*.inc.c）；与 http.o 一并链入
runtime_http_glue.o: src/asm/http/runtime_http_glue.c
	$(CC) $(CFLAGS) -Isrc/asm/http -c -o $@ $<

# F-ZC：mbedTLS BIO 胶层；net-o-mbedtls 时 ld -r 并入 tls_mbedtls.o
runtime_tls_mbedtls_bio.o: src/asm/runtime_tls_mbedtls_bio.c
	$(CC) $(CFLAGS) -I/opt/homebrew/opt/mbedtls/include -c -o $@ $< 2>/dev/null || $(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：db.kv mmap 胶层；与 kv.o 按需同链
runtime_kv_mmap_glue.o: src/asm/runtime_kv_mmap_glue.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：db.arrow SIMD 胶层；与 arrow.o 按需同链
runtime_arrow_simd_glue.o: src/asm/runtime_arrow_simd_glue.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：db.sqlite 胶层（libsqlite3）；与 sqlite.o 同链
runtime_sqlite_glue.o: src/asm/runtime_sqlite_glue.c
	$(CC) $(CFLAGS) -DSHUX_DB_USE_SQLITE3 -c -o $@ $<

# F-ZC：db.sqlite stub 胶层（无 libsqlite3）；sqlite-o-stub 时 ld -r 并入 sqlite.o
runtime_sqlite_glue_stub.o: src/asm/runtime_sqlite_glue.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：crypto SHA-512/HMAC 胶层；与 crypto.o 一并链入
runtime_crypto_inc_glue.o: src/asm/runtime_crypto_inc_glue.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：Ed25519 ref10（含 crypto/ed25519/*.c）；与 crypto.o 一并链入
runtime_ed25519_ref10_glue.o: src/asm/runtime_ed25519_ref10_glue.c
	$(CC) $(CFLAGS) -Isrc/asm -c -o $@ $<

# F-ZC：codegen 入口 argc/argv 全局；与 process.o 一并链入（见 runtime_process_argv.c）
runtime_process_argv.o: src/asm/runtime_process_argv.c
	$(CC) $(CFLAGS) -c -o $@ $<

# F-ZC：进程 OS 胶层（getenv/spawn/getcwd 等）；与 process.o 一并链入
runtime_process_os_glue.o: src/asm/runtime_process_os_glue.c
	$(CC) $(CFLAGS) -c -o $@ $<

# 无 C 自举：crt0 提供 _start 与 driver_get_argv_i；链接 asm 版 shux 时用本 .o 替代 main.o / runtime_asm_build.o
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
# NL-07 v2：bootstrap crt0 nostdlib 最小 libc 桩
src/asm/bootstrap_nostdlib_stubs.o: src/asm/bootstrap_nostdlib_stubs.c
	$(CC) $(CFLAGS) -c -o $@ $<
endif
endif
# E-04 v20：Darwin bootstrap 默认 crt0（arm64 / x86_64 Mach-O）
ifeq ($(UNAME_S),Darwin)
ifneq (,$(filter arm64 aarch64,$(UNAME_M)))
src/asm/crt0_arm64.o: src/asm/crt0_arm64.s
	$(CC) -c -o $@ $<
else ifneq (,$(filter x86_64 amd64,$(UNAME_M)))
src/asm/crt0_darwin_x86_64.o: src/asm/crt0_darwin_x86_64.s
	$(CC) -c -o $@ $<
endif
endif
# E-04 v21：Windows/MinGW/MSYS bootstrap 默认 crt0_mingw 替代 main_driver.o
ifeq ($(SHUX_IS_WIN_HOST),1)
src/asm/crt0_mingw.o: src/asm/crt0_mingw.c Makefile
	$(CC) $(CFLAGS) $(WIN32_O_CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<
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
	rm -f $(OBJS) src/main_driver.o src/runtime_driver.o src/runtime_driver_no_c.o src/runtime_sx.o src/main_sx.o src/ast/ast_seed.o src/preprocess_for_driver.o src/codegen/codegen_pipeline_stubs.o ../std/process/process.o ../std/string/string.o ../std/runtime/runtime.o ../std/net/net.o ../std/thread/thread.o ../std/time/time.o ../std/random/random.o ../std/env/env.o ../std/sync/sync.o ../std/encoding/encoding.o ../std/base64/base64.o ../std/crypto/crypto.o ../std/log/log.o ../std/atomic/atomic.o ../std/channel/channel.o ../std/backtrace/backtrace.o ../std/hash/hash.o ../std/math/math.o ../std/sort/sort.o ../std/ffi/ffi.o ../std/json/json.o ../std/csv/csv.o ../std/regex/regex.o ../std/compress/compress.o ../std/unicode/unicode.o ../std/dynlib/dynlib.o ../std/http/http.o ../std/tar/tar.o ../std/test/test.o src/asm/runtime_asm_build.o src/asm/crt0_x86_64.o src/typeck/typeck_f64_bits.o src/lsp/lsp_state.o src/lsp/lsp_diag_pipeline_sizes.o lsp_io_sx.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_std_heap_sx.o lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c $(TARGET) shux-sx shux-no-c-frontend $(SHUX_C) $(TARGET)_stage1 $(TARGET)_stage2 $(TARGET)_sx $(TARGET)_sx_stage2 typeck_gen.c typeck_sx.o codegen_gen.c codegen_sx.o parser_gen.c parser_sx.o driver_gen.c driver_sx.o driver_fmt_gen.c driver_check_gen.c driver_test_gen.c driver_fmt_sx.o driver_check_sx.o driver_test_sx.o _stubs_driver.o pipeline_gen.c pipeline_sx.o typeck_sx_sx.c typeck_sx_sx.o codegen_sx_sx.c codegen_sx_sx.o build_gen.c build_runner_gen.c build_runtime_sx_gen.c build_tool.o build_runner.o build_runtime.o build_runtime_sx.o build_tool runtime_panic.o shux_asm preprocess_gen.c preprocess_sx.o
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

# sx 自举：bootstrap-driver-seed + LSP + 全量自举（run-all-sx：用 shux_sx 跑整份 run-all）
test_sx: bootstrap-driver-seed
	@if [ -f ../tests/run-lsp.sh ]; then (cd .. && chmod +x tests/run-lsp.sh && ./tests/run-lsp.sh); fi
	@if [ -f ../tests/run-all-sx.sh ]; then (cd .. && chmod +x tests/run-all-sx.sh && ./tests/run-all-sx.sh); fi
	@echo "Test SX OK"

# 全量：先 C 再 sx 自举
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
	/tmp/shux_parser_test && echo "sx parser: parse OK (minimal)" && \
	(out=$$(./$(TARGET) -L .. /tmp/shux_parse_test.sx 2>&1); echo "$$out" | grep -q "parse OK") && echo "C parser: parse OK (minimal)" && \
	printf 'function main(): i32 { return (1 + 2) * 3 + -1; }\0' > /tmp/shux_parse_test.sx && \
	/tmp/shux_parser_test && echo "sx parser: parse OK (expr-chain)" && \
	(out=$$(./$(TARGET) -L .. /tmp/shux_parse_test.sx 2>&1); echo "$$out" | grep -q "parse OK") && echo "C parser: parse OK (expr-chain)" && \
	echo "bootstrap-parse-file OK"

# 迁移到 .sx：parser.sx -E-extern + ast 池 getter 补丁 → parser_sx.o（提供 parser_parse_into_buf；与瘦 pipeline_sx.o 分 TU）。
# 须 shux-sx -sx -E 全量 TU；shux-c 瘦 gen 缺 copy_module_import_path64 / parse_expr_into 等。
parser_gen.c: $(SHUX_C) ast_gen2.c src/parser/parser.sx
	@if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  tmp="$@.tmp"; \
	  if [ -f $(SHUX_SX) ]; then \
	    echo "parser_gen.c: ./$(SHUX_SX) -sx -E -E-extern ... [forced regen]" >&2; \
	    if ./$(SHUX_SX) -sx -E -L .. -L src/lexer -L src/ast -E-extern src/parser/parser.sx > "$$tmp" 2>/dev/null \
	       && grep -q 'parser_copy_module_import_path64' "$$tmp"; then \
	      mv -f "$$tmp" $@; \
	    else \
	      rm -f "$$tmp"; \
	      ./$(SHUX_C) -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.sx > $@; \
	    fi; \
	  else \
	    ./$(SHUX_C) -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.sx > $@; \
	  fi; \
	elif [ -s parser_gen.c ]; then \
	  echo "parser_gen.c: pinned ($$(wc -c < parser_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/parser_gen.linux.x86_64.c ] && [ ! -s parser_gen.c ]; then \
	  cp -f seeds/parser_gen.linux.x86_64.c parser_gen.c; \
	  echo "parser_gen.c: restored from seeds/parser_gen.linux.x86_64.c"; \
	else \
	  tmp="$@.tmp"; \
	  if [ -f $(SHUX_SX) ]; then \
	    echo "parser_gen.c: ./$(SHUX_SX) -sx -E -E-extern ..." >&2; \
	    if ./$(SHUX_SX) -sx -E -L .. -L src/lexer -L src/ast -E-extern src/parser/parser.sx > "$$tmp" 2>/dev/null \
	       && grep -q 'parser_copy_module_import_path64' "$$tmp"; then \
	      mv -f "$$tmp" $@; \
	    else \
	      echo "parser_gen.c: shux-sx failed or thin output; fallback shux-c" >&2; \
	      rm -f "$$tmp" 2>/dev/null || true; \
	      if ./$(SHUX_C) -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.sx > "$$tmp" 2>/dev/null \
	         && [ -s "$$tmp" ] && grep -q 'parser_copy_module_import_path64' "$$tmp"; then \
	        mv -f "$$tmp" $@; \
	      elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/parser_gen.linux.x86_64.c ]; then \
	        cp -f seeds/parser_gen.linux.x86_64.c $@; \
	        echo "parser_gen.c: fallback seeds/parser_gen.linux.x86_64.c (shux-c -E failed)" >&2; \
	      else \
	        rm -f "$$tmp" 2>/dev/null || true; \
	        echo "parser_gen.c: FAIL (no shux-sx/shux-c -E and no seed)" >&2; exit 1; \
	      fi; \
	    fi; \
	  else \
	    if ./$(SHUX_C) -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.sx > "$$tmp" 2>/dev/null \
	       && [ -s "$$tmp" ] && grep -q 'parser_copy_module_import_path64' "$$tmp"; then \
	      mv -f "$$tmp" $@; \
	    elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/parser_gen.linux.x86_64.c ]; then \
	      cp -f seeds/parser_gen.linux.x86_64.c $@; \
	      echo "parser_gen.c: fallback seeds/parser_gen.linux.x86_64.c" >&2; \
	    else \
	      rm -f "$$tmp" 2>/dev/null || true; \
	      echo "parser_gen.c: FAIL (shux-c -E failed and no seed)" >&2; exit 1; \
	    fi; \
	  fi; \
	fi
	perl -i -ne 'print unless /^struct shux_slice_uint8_t/ && $$seen++' $@ 2>/dev/null || true
	@if ! grep -q 'C-04 -E-extern TU aliases' $@ 2>/dev/null; then \
	  echo "parser_gen.c: FAIL missing C-04 -E-extern TU aliases (need shux-c -E-extern codegen; no perl fallback)" >&2; \
	  exit 1; \
	fi
	@if ! grep -q 'C-04 parser: ast_expr_init_match_enum after struct ast_Expr' $@ 2>/dev/null; then \
	  echo "parser_gen.c: FAIL missing C-04 parser pool marker (need shux-c -E-extern codegen; no perl fallback)" >&2; \
	  exit 1; \
	fi
	@if ! grep -q 'parser_copy_module_import_path64' $@; then \
	  echo "parser_gen.c: inject extern parser_copy_module_import_path64 (parser_asm_link_alias/thin_c)" >&2; \
	  printf '%s\n' '/* pipeline extern parser_copy_module_import_path64 (thin parser_gen TU) */' \
	    'extern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t out[64]);' >> $@; \
	fi
	@echo "parser_gen.c: normalize ast_pipeline onefunc const extern aliases" >&2; \
	perl -0pi -e 's@^extern int32_t ast_pipeline_onefunc_append_const\(.*\);\n@@mg; s@^extern int32_t ast_pipeline_onefunc_const_init_ref\(.*\);\n@@mg; s@^extern int32_t ast_pipeline_onefunc_const_type_ref\(.*\);\n@@mg; s@/\* C-04 -E-extern TU aliases \*/\n@extern int32_t ast_pipeline_onefunc_append_const(uint8_t * restrict out, uint8_t * restrict name, int32_t name_len, int32_t init_val, int32_t init_ref, int32_t type_ref);\nextern int32_t ast_pipeline_onefunc_const_init_ref(uint8_t * restrict out, int32_t i);\nextern int32_t ast_pipeline_onefunc_const_type_ref(uint8_t * restrict out, int32_t i);\n/* C-04 -E-extern TU aliases */\n@s' $@
	@echo "parser_gen.c: from parser.sx (-E-extern, full TU via shux-sx -sx)"
parser_sx.o: parser_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -Dstd_io_driver_driver_read_ptr_len=shux_io_read_ptr_len -Dstd_io_driver_driver_read_ptr=shux_io_read_ptr -c parser_gen.c -o parser_sx.o
	@echo "parser_sx.o OK"

# lexer.sx：须 shux-sx -sx -E 走 C parser/codegen 全量 TU；shux-c 无 -sx 时仅 ~57 行缺 advance_one/next_body。
lexer_gen.c: $(SHUX_C) src/lexer/lexer.sx
	@if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  tmp="$@.tmp"; \
	  if [ -f $(SHUX_SX) ]; then \
	    echo "lexer_gen.c: ./$(SHUX_SX) -sx -E -E-extern ... [forced regen]" >&2; \
	    if ./$(SHUX_SX) -sx -E -L src/lexer -E-extern src/lexer/lexer.sx > "$$tmp" 2>/dev/null \
	       && grep -q 'lexer_advance_one' "$$tmp"; then \
	      mv -f "$$tmp" $@; \
	    else \
	      rm -f "$$tmp"; \
	      ./$(SHUX_C) -L src/lexer -E -E-extern src/lexer/lexer.sx > $@; \
	    fi; \
	  else \
	    ./$(SHUX_C) -L src/lexer -E -E-extern src/lexer/lexer.sx > $@; \
	  fi; \
	elif [ -s lexer_gen.c ]; then \
	  echo "lexer_gen.c: pinned ($$(wc -c < lexer_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/lexer_gen.linux.x86_64.c ] && [ ! -s lexer_gen.c ]; then \
	  cp -f seeds/lexer_gen.linux.x86_64.c lexer_gen.c; \
	  echo "lexer_gen.c: restored from seeds/lexer_gen.linux.x86_64.c"; \
	else \
	  tmp="$@.tmp"; \
	  if [ -f $(SHUX_SX) ]; then \
	    echo "lexer_gen.c: ./$(SHUX_SX) -sx -E -E-extern ..." >&2; \
	    if ./$(SHUX_SX) -sx -E -L src/lexer -E-extern src/lexer/lexer.sx > "$$tmp" 2>/dev/null \
	       && grep -q 'lexer_advance_one' "$$tmp"; then \
	      mv -f "$$tmp" $@; \
	    else \
	      echo "lexer_gen.c: shux-sx failed or thin output; fallback shux-c" >&2; \
	      rm -f "$$tmp" 2>/dev/null || true; \
	      if ./$(SHUX_C) -L src/lexer -E -E-extern src/lexer/lexer.sx > "$$tmp" 2>/dev/null \
	         && [ -s "$$tmp" ] && grep -q 'lexer_advance_one' "$$tmp"; then \
	        mv -f "$$tmp" $@; \
	      elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/lexer_gen.linux.x86_64.c ]; then \
	        cp -f seeds/lexer_gen.linux.x86_64.c $@; \
	        echo "lexer_gen.c: fallback seeds/lexer_gen.linux.x86_64.c (shux-c -E failed)" >&2; \
	      else \
	        rm -f "$$tmp" 2>/dev/null || true; \
	        echo "lexer_gen.c: FAIL (no shux-sx/shux-c -E and no seed)" >&2; exit 1; \
	      fi; \
	    fi; \
	  else \
	    if ./$(SHUX_C) -L src/lexer -E -E-extern src/lexer/lexer.sx > "$$tmp" 2>/dev/null \
	       && [ -s "$$tmp" ] && grep -q 'lexer_advance_one' "$$tmp"; then \
	      mv -f "$$tmp" $@; \
	    elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/lexer_gen.linux.x86_64.c ]; then \
	      cp -f seeds/lexer_gen.linux.x86_64.c $@; \
	      echo "lexer_gen.c: fallback seeds/lexer_gen.linux.x86_64.c" >&2; \
	    else \
	      rm -f "$$tmp" 2>/dev/null || true; \
	      echo "lexer_gen.c: FAIL (shux-c -E failed and no seed)" >&2; exit 1; \
	    fi; \
	  fi; \
	fi
	perl scripts/fix_slim_arena_gen_c.pl $@
	@perl scripts/sync_lexer_gen_token_enum.pl lexer_gen.c
	@grep -q 'lexer_advance_one' $@ || (echo "lexer_gen.c: missing lexer_advance_one (need shux-sx -sx -E)" >&2; exit 1)
	@echo "lexer_gen.c: from lexer.sx (-E-extern, full TU via shux-sx -sx)"

lexer_sx.o: lexer_gen.c
	@perl scripts/sync_lexer_gen_token_enum.pl lexer_gen.c
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
USER_ASM_SEED_HOST_STUBS = $(USER_ASM_SEED_HOST_DIR)/asm_full_link_stubs.o
USER_ASM_SEED_OBJS = src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o src/asm/pipeline_abi_f32_xmm.o parser_asm_thin_glue.o parser_asm_link_alias.o src/asm/parser_asm_parse_expr_link.o
USER_ASM_LINK = $(USER_ASM_SEED_HOST_OBJS) $(USER_ASM_SEED_HOST_STUBS) $(USER_ASM_SEED_OBJS)

.PHONY: build-seed-asm-host
# partial export 须先 nm dispatch .o 剔除重复符号；冷启动时 dispatch 可能尚未编译。
.PHONY: parser-legacy-text-o
parser-legacy-text-o:
	@chmod +x scripts/extract_parser_legacy_text.sh 2>/dev/null || true
	@./scripts/extract_parser_legacy_text.sh

build-seed-asm-host: src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o src/asm/pipeline_abi_f32_xmm.o
	@chmod +x scripts/build_seed_asm_host.sh 2>/dev/null || true
	@./scripts/build_seed_asm_host.sh

$(USER_ASM_SEED_HOST_STUBS): pipeline_sx.o $(ASM_GLUE_STANDALONE_O) $(USER_ASM_SEED_OBJS) scripts/gen_asm_full_link_stubs.pl
	@mkdir -p $(USER_ASM_SEED_HOST_DIR)
	@_scan="pipeline_sx.o $(ASM_GLUE_STANDALONE_O) $(USER_ASM_SEED_OBJS)"; \
	  [ -f $(USER_ASM_SEED_HOST_DIR)/asm_full.o ] && _scan="$(USER_ASM_SEED_HOST_DIR)/asm_full.o $$_scan"; \
	  [ -f $(USER_ASM_SEED_HOST_DIR)/asm_backend_partial.o ] && _scan="$(USER_ASM_SEED_HOST_DIR)/asm_backend_partial.o $$_scan"; \
	  perl scripts/gen_asm_full_link_stubs.pl $(USER_ASM_SEED_HOST_DIR)/asm_full_link_stubs.c $$_scan && \
	  $(CC) $(CFLAGS) -c -o $@ $(USER_ASM_SEED_HOST_DIR)/asm_full_link_stubs.c

$(USER_ASM_SEED_HOST_OBJS): build-seed-asm-host

src/asm/user_asm_seed_bridge.o: src/asm/user_asm_seed_bridge.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/asm/asm_backend_compat_stubs.o: src/asm/asm_backend_compat_stubs.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<
src/asm/bootstrap_seed_io_stubs.o: src/asm/bootstrap_seed_io_stubs.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/asm/backend_enc_dispatch.o: src/asm/backend_enc_dispatch.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/asm/backend_x86_64_enc_c.o: src/asm/backend_x86_64_enc_c.c
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
PARSER_ASM_LINK_ALIAS_CFLAGS = -DPARSER_ASM_LINK_ALIAS_SKIP_SX_SYMBOLS
parser_asm_thin_glue.o: src/asm/parser_asm_thin_c.c src/asm/parser_asm_type_ref_slice.c src/asm/parser_asm_struct_layout_slice.c src/asm/parser_asm_top_level_let_slice.c src/asm/parser_asm_if_stmt_slice.c
	$(CC) $(CFLAGS) $(PARSER_ASM_THIN_GLUE_CFLAGS) -I. -Iinclude -Isrc -Isrc/lexer -c -o $@ src/asm/parser_asm_thin_c.c

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
	@if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  ./$(SHUX_C) -L src/ast -E -E-extern src/ast/ast.sx > $@; \
	  perl scripts/fix_slim_arena_gen_c.pl $@; \
	elif [ -s ast_gen2.c ]; then \
	  echo "ast_gen2.c: pinned ($$(wc -c < ast_gen2.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	else \
	  ./$(SHUX_C) -L src/ast -E -E-extern src/ast/ast.sx > $@; \
	  perl scripts/fix_slim_arena_gen_c.pl $@; \
	fi

ast_gen2.o: ast_gen2.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c ast_gen2.c -o ast_gen2.o

typeck_gen.c: $(SHUX_C) ast_gen2.c src/typeck/typeck.sx
	@if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  ./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser src/typeck/typeck.sx -E-extern > $@; \
	elif [ -s typeck_gen.c ]; then \
	  echo "typeck_gen.c: pinned ($$(wc -c < typeck_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/typeck_gen.linux.x86_64.c ] && [ ! -s typeck_gen.c ]; then \
	  cp -f seeds/typeck_gen.linux.x86_64.c typeck_gen.c; \
	  echo "typeck_gen.c: restored from seeds/typeck_gen.linux.x86_64.c"; \
	else \
	  ./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser src/typeck/typeck.sx -E-extern > $@ || \
	    { if [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/typeck_gen.linux.x86_64.c ]; then cp -f seeds/typeck_gen.linux.x86_64.c $@ && echo "typeck_gen.c: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	fi
	perl scripts/fix_slim_arena_gen_c.pl $@

typeck_sx.o: typeck_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c typeck_gen.c -o typeck_sx.o
	@test $$(stat -f%z typeck_sx.o 2>/dev/null || stat -c%s typeck_sx.o) -gt 10000 || (echo "typeck_sx.o too small (corrupt gen? rm typeck_gen.c && make typeck_gen.c typeck_sx.o)" >&2; exit 1)

codegen_gen.c: $(SHUX_C) ast_gen2.c src/codegen/codegen.sx
	@if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  ./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck src/codegen/codegen.sx -E-extern > $@; \
	elif [ -s codegen_gen.c ]; then \
	  echo "codegen_gen.c: pinned ($$(wc -c < codegen_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/codegen_gen.linux.x86_64.c ] && [ ! -s codegen_gen.c ]; then \
	  cp -f seeds/codegen_gen.linux.x86_64.c codegen_gen.c; \
	  echo "codegen_gen.c: restored from seeds/codegen_gen.linux.x86_64.c"; \
	else \
	  ./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck src/codegen/codegen.sx -E-extern > $@ || \
	    { if [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/codegen_gen.linux.x86_64.c ]; then cp -f seeds/codegen_gen.linux.x86_64.c $@ && echo "codegen_gen.c: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	fi
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
DRIVER_OBJS = src/main_driver.o src/runtime_driver.o src/preprocess_for_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o src/lexer/lexer.o src/ast/ast.o src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o src/codegen/autovec.o
# G-02a：ast_seed / C 前端已删；默认 bootstrap 不链 LEXER_LINK_O / AST_LINK_O。
# bootstrap-driver-seed：pipeline_sx.o 为 -E-extern 编排；parser/lexer/typeck/codegen *_sx.o 分 TU。
# C-06 v1 默认：不链 C parser/typeck/codegen.o（SHUX_LEGACY_C_FRONTEND=1 恢复双轨）。
# seed 链：lexer_sx.o + lexer_sx_link_alias.o（SX 词法）；默认不链 C lexer.o（E-03 v2）。
# E-03 v2 preprocess：默认 bootstrap 不链 preprocess_for_driver.o（runtime preprocess() 走 preprocess.sx）。
# SHUX_LEGACY_PREPROCESS_C=1 恢复 C preprocess_c_fallback（考古）。
ifeq ($(SHUX_LEGACY_PREPROCESS_C),1)
PREPROCESS_LINK_O = src/preprocess_for_driver.o
DRIVER_SEED_PREPROCESS_REBUILD = src/preprocess_for_driver.o
else
PREPROCESS_LINK_O =
DRIVER_SEED_PREPROCESS_REBUILD =
endif
# parser labeled 名写入（parser_sx.o / ast_pool_l5_bridge 依赖，不可缺链）。
AST_POOL_L5_BRIDGE_O = src/ast_pool_l5_bridge.o
DRIVER_SEED_SX_FRONTEND_OBJS = parser_sx.o lexer_sx.o lexer_sx_link_alias.o typeck_sx.o codegen_sx.o typeck_sx_link_alias.o codegen_sx_link_alias.o
# G-02a：C 前端已删；SHUX_LEGACY_C_FRONTEND=1 不再支持。
DRIVER_SEED_C_FRONTEND_LEGACY =
# G-06：提交 seeds/bootstrap_shuxc.* 由 capture（SHUX_LEGACY_C_FRONTEND=1）生成；默认 bootstrap/relink 须匹配该链接布局。
# SHUX_NO_C_SEED_LINK=1 时走 E-04 runtime_driver_no_c（实验；与 pinned seed 不兼容）。
ifeq ($(SHUX_LEGACY_C_FRONTEND),1)
DRIVER_SEED_RUNTIME_O = src/runtime_driver.o
DRIVER_SEED_FRONTEND_EXTRA = $(DRIVER_SEED_C_FRONTEND_LEGACY)
DRIVER_SEED_SUPPORT_EXTRA = src/async/async_liveness.o src/async/async_cps_codegen.o
DRIVER_SEED_LINK_FLAGS = -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN
DRIVER_SEED_RUNTIME_REBUILD = src/runtime_driver.o src/async/async_cps_codegen.o
else ifeq ($(SHUX_NO_C_SEED_LINK),1)
# E-04 v1：无 C ast/lexer/runtime_driver（勿用于已提交 G-06 种子的 relink）。
DRIVER_SEED_RUNTIME_O = src/runtime_driver_no_c.o
DRIVER_SEED_FRONTEND_EXTRA =
DRIVER_SEED_SUPPORT_EXTRA = src/codegen/codegen_pipeline_stubs.o src/lexer/cfg_eval.o src/typeck/typeck_f64_bits.o typeck_c_module_stubs.o src/runtime_pipeline_abi_shux_c_stubs.o src/lsp/lsp_heap_bootstrap.o
DRIVER_SEED_LINK_FLAGS = -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE
DRIVER_SEED_RUNTIME_REBUILD = src/runtime_driver_no_c.o
else
# 默认：seed-compat（runtime_driver + C ast/lexer + async + C parse/typeck/codegen 薄桥；匹配 seeds/bootstrap_shuxc.*）。
DRIVER_SEED_RUNTIME_O = src/runtime_driver.o
DRIVER_SEED_FRONTEND_EXTRA = src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o src/codegen/autovec.o
DRIVER_SEED_SUPPORT_EXTRA = src/async/async_liveness.o src/async/async_cps_codegen.o src/runtime_c_import.o src/preprocess.o src/codegen/codegen_pipeline_stubs.o src/lexer/cfg_eval.o src/typeck/typeck_f64_bits.o typeck_c_module_stubs.o src/runtime_pipeline_abi_shux_c_stubs.o src/lsp/lsp_heap_bootstrap.o
DRIVER_SEED_LINK_FLAGS = -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN
DRIVER_SEED_RUNTIME_REBUILD = src/runtime_driver.o src/async/async_cps_codegen.o
endif
# pipeline_glue_standalone 与 pipeline_sx.o 重复时 glue 置链接末尾且允许多定义（覆盖 pipeline_gen 快照内旧 glue）。
ASM_GLUE_STANDALONE_O = build_asm/pipeline_glue_standalone.o
ASM_GLUE_DUP_LDFLAGS = -Wl,--allow-multiple-definition
DRIVER_SEED_GLUE_PREFIX =
DRIVER_SEED_GLUE_SUFFIX = $(ASM_GLUE_STANDALONE_O)
# E-02 v1：lsp_diag.c 已删；仅 lsp_diag_stubs_no_c.o + lsp_diag_sx.o。
LSP_DIAG_LINK_O = src/lsp/lsp_diag_stubs_no_c.o
# E-03 v2 lexer/ast：seed-compat / LEGACY 链 C lexer.o + ast_seed.o；SHUX_NO_C_SEED_LINK=1 时不链。
ifeq ($(SHUX_LEGACY_C_FRONTEND),1)
LEXER_LINK_O = src/lexer/lexer.o
AST_LINK_O = src/ast/ast_seed.o
else ifeq ($(SHUX_LEGACY_SEED_LEXER_AST),1)
LEXER_LINK_O = src/lexer/lexer.o
AST_LINK_O = src/ast/ast_seed.o
else ifeq ($(SHUX_NO_C_SEED_LINK),1)
LEXER_LINK_O =
AST_LINK_O =
else
LEXER_LINK_O = src/lexer/lexer.o
AST_LINK_O = src/ast/ast_seed.o
endif
# E-04 v19/v20：Linux / Darwin bootstrap 默认 crt0 替代 main_driver.o（driver_sx.o 导出 main_entry）。
# SHUX_LEGACY_MAIN_C=1 或非 crt0 平台仍链 main_driver.o（main.c 薄桩 → shux_forward_main_to_main_entry）。
ifeq ($(SHUX_LEGACY_MAIN_C),1)
MAIN_LINK_O = src/main_driver.o
MAIN_LINK_REBUILD = src/main_driver.o
MAIN_LINK_FLAGS =
else ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
MAIN_LINK_O = src/asm/crt0_x86_64.o
MAIN_LINK_REBUILD = src/asm/crt0_x86_64.o
# 与 build_shux_asm.sh bootstrap_entry_ldflags 一致：crt0 链须 -no-pie，否则 -o 链接偶发 SIGSEGV
MAIN_LINK_FLAGS = -no-pie -e _start -nostartfiles
else
MAIN_LINK_O = src/main_driver.o
MAIN_LINK_REBUILD = src/main_driver.o
MAIN_LINK_FLAGS =
endif
else ifeq ($(UNAME_S),Darwin)
ifneq (,$(filter arm64 aarch64,$(UNAME_M)))
MAIN_LINK_O = src/asm/crt0_arm64.o
MAIN_LINK_REBUILD = src/asm/crt0_arm64.o
MAIN_LINK_FLAGS = -e _start -nostartfiles
else ifneq (,$(filter x86_64 amd64,$(UNAME_M)))
MAIN_LINK_O = src/asm/crt0_darwin_x86_64.o
MAIN_LINK_REBUILD = src/asm/crt0_darwin_x86_64.o
MAIN_LINK_FLAGS = -e _start -nostartfiles
else
MAIN_LINK_O = src/main_driver.o
MAIN_LINK_REBUILD = src/main_driver.o
MAIN_LINK_FLAGS =
endif
else ifeq ($(SHUX_IS_WIN_HOST),1)
MAIN_LINK_O = src/asm/crt0_mingw.o
MAIN_LINK_REBUILD = src/asm/crt0_mingw.o
MAIN_LINK_FLAGS =
else
MAIN_LINK_O = src/main_driver.o
MAIN_LINK_REBUILD = src/main_driver.o
MAIN_LINK_FLAGS =
endif
DRIVER_SEED_OBJS = $(MAIN_LINK_O) src/runtime_abi.o src/runtime_io_abi.o src/runtime_proc_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o $(DRIVER_SEED_RUNTIME_O) src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o src/asm/bootstrap_seed_io_stubs.o $(PREPROCESS_LINK_O) $(LEXER_LINK_O) $(AST_LINK_O) $(DRIVER_SEED_SX_FRONTEND_OBJS) $(DRIVER_SEED_FRONTEND_EXTRA) $(DRIVER_SEED_SUPPORT_EXTRA) src/sx_seed_bridge.o src/std_fs_shim.o src/std_sys_shim.o $(AST_POOL_L5_BRIDGE_O)
DRIVER_SEED_SX_OBJS = parser_sx.o typeck_sx.o codegen_sx.o

# 阶段 10.4 实验：链 typeck_sx.o/codegen_sx.o 替代 C 前端（不含 pipeline_sx.o，无 SHUX_USE_SX_PIPELINE）。
# 勿复用 DRIVER_SEED_SX_FRONTEND_OBJS 名：bootstrap-driver-seed 链依赖 parser_sx.o/lexer_sx.o（见上 §1280）。
DRIVER_SEED_SX_FRONTEND_EXPERIMENT_OBJS = src/main_driver.o src/runtime_driver.o src/preprocess_for_driver.o src/lexer/lexer.o src/ast/ast_seed.o src/parser/parser.o typeck_sx.o codegen_sx.o
bootstrap-driver-seed-sx-frontend: $(SHUX_C) migrate-sx-objs driver_sx.o preprocess_sx.o $(DRIVER_SUBCMD_GEN) $(DRIVER_SEED_SX_FRONTEND_EXPERIMENT_OBJS) $(LSP_DIAG_LINK_O) _stubs_driver.o $(DRIVER_SUBCMD_OBJS)
	$(CC) $(CFLAGS) -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN -o $(TARGET)_sx_frontend $(DRIVER_SEED_SX_FRONTEND_EXPERIMENT_OBJS) driver_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o $(LSP_DIAG_LINK_O) $(PIPELINE_LIBS)
	@echo "bootstrap-driver-seed-sx-frontend OK ($(TARGET)_sx_frontend: .sx typeck/codegen, no pipeline_sx.o)"

# 6.3：.sx 入口与 main.c 一一对应。bootstrap-driver-seed = 用 C 代码生成（生成 pipeline_gen.c / driver_gen.c）得到种子 shux；仅首次或无 shux 时需要。
# bootstrap-driver-asm / bootstrap-driver-hybrid = B-hybrid（build_shux_asm 无 SKIP_GEN），产出可覆盖 $(TARGET)。
# bootstrap-driver = M7 默认 B-strict（同 bootstrap-driver-bstrict）：SKIP_GEN 链 shux_asm 并覆盖 $(TARGET)；冷启动仍仅 bootstrap-driver-seed。
# 无补丁：driver_gen.c 仅由 -E -E-extern 生成；run_compiler_c 在 runtime.c 中定义并转调 main_run_compiler_c；其余从 main.sx/codegen 根源修
# LSP 诊断：G-02a lsp_diag.c 已删；仅 lsp_diag_sx.o + stubs。

src/lsp/lsp_diag_pipeline_sizes.o: src/lsp/lsp_diag_pipeline_sizes.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# bootstrap/relink 同时链 lsp_diag_pipeline_ctx.o；Cygwin 无 weak，须省略 sizes 内占位符号。
src/lsp/lsp_diag_pipeline_sizes_nostub.o: src/lsp/lsp_diag_pipeline_sizes.c
	$(CC) $(CFLAGS) -DSHUX_LSP_PIPELINE_CTX_LINKED -I. -Iinclude -Isrc -c -o $@ $<

src/lsp/lsp_diag_pipeline_ctx.o: src/lsp/lsp_diag_pipeline_ctx.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/lsp/lsp_diag_sx_alias.o: src/lsp/lsp_diag_sx_alias.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

src/lsp/lsp_heap_bootstrap.o: src/lsp/lsp_heap_bootstrap.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

$(AST_POOL_L5_BRIDGE_O): src/ast_pool_l5_bridge.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# G-06：ast.c 以 SHUX_USE_SX_AST 编为 ast_seed.o，供 seed-compat 链（ast_block_free 等；与 capture seeds 一致）。
src/ast/ast_seed.o: src/ast/ast.c include/ast.h
	$(CC) $(CFLAGS) -DSHUX_USE_SX_AST -c -o $@ src/ast/ast.c

# seed-compat：runtime_driver.o 薄桥依赖 C parse/typeck/codegen（与 capture LEGACY 种子一致）。
src/preprocess.o: src/preprocess.c src/preprocess.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/lexer/lexer.o: src/lexer/lexer.c src/lexer/lexer.h include/token.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/parser/parser.o: src/parser/parser.c src/parser/parser.h src/lexer/lexer.h include/ast.h include/token.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/typeck/typeck.o: src/typeck/typeck.c src/typeck/typeck.h include/ast.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/codegen/codegen.o: src/codegen/codegen.c src/codegen/codegen.h include/ast.h src/lsp/lsp_codegen_extern.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/codegen/autovec.o: src/codegen/autovec.c include/autovec.h include/ast.h
	$(CC) $(CFLAGS) -c -o $@ src/codegen/autovec.c

lsp_diag_gen.c: $(SHUX_C) src/lsp/lsp_diag.sx
	@if [ -s lsp_diag_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "lsp_diag_gen.c: pinned ($$(wc -c < lsp_diag_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ -f seeds/lsp_diag_gen.linux.x86_64.c ] && [ ! -s lsp_diag_gen.c ]; then \
	  cp -f seeds/lsp_diag_gen.linux.x86_64.c lsp_diag_gen.c; \
	  echo "lsp_diag_gen.c: restored from seeds/lsp_diag_gen.linux.x86_64.c"; \
	else \
	  echo "lsp_diag_gen.c: $(SHUX_C) -E -E-extern (avoid shux-sx -sx -E: broken TU for lsp_diag.sx)" >&2; \
	  ./$(SHUX_C) $(LSP_SX_E_DIRS) -L src/pipeline src/lsp/lsp_diag.sx -E -E-extern > $@ || \
	    { if [ -f seeds/lsp_diag_gen.linux.x86_64.c ]; then cp -f seeds/lsp_diag_gen.linux.x86_64.c $@ && echo "lsp_diag_gen.c: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	fi
	@if ! grep -q 'C-04 -E-extern TU aliases' $@ 2>/dev/null; then \
	  if [ -f seeds/lsp_diag_gen.linux.x86_64.c ]; then cp -f seeds/lsp_diag_gen.linux.x86_64.c $@; \
	  else echo "lsp_diag_gen.c: FAIL missing C-04 -E-extern TU aliases (need shux-c -E-extern codegen; no perl fallback)" >&2; exit 1; fi; \
	fi

lsp_diag_sx.o: lsp_diag_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c lsp_diag_gen.c -o lsp_diag_sx.o

# lsp_io.sx：C-04 v0 要求 shux-c 自动生成 import extern；shux-sx 仍走旧块时回退 shux-c。
lsp_io_gen.c: $(SHUX_C) src/lsp/lsp_io.sx
	@if [ -s lsp_io_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "lsp_io_gen.c: pinned ($$(wc -c < lsp_io_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/lsp_io_gen.linux.x86_64.c ] && [ ! -s lsp_io_gen.c ]; then \
	  cp -f seeds/lsp_io_gen.linux.x86_64.c lsp_io_gen.c; \
	  echo "lsp_io_gen.c: restored from seeds/lsp_io_gen.linux.x86_64.c"; \
	elif [ -f $(SHUX_SX) ]; then \
	  echo "lsp_io_gen.c: ./$(SHUX_SX) -sx -E ..." >&2; \
	  ./$(SHUX_SX) -sx -E $(LSP_SX_E_DIRS) -E-extern src/lsp/lsp_io.sx > $@.tmp 2>/dev/null || true; \
	  if [ -s $@.tmp ] && ! grep -q 'lsp_io -E-extern stubs (io.o' $@.tmp; then \
	    mv $@.tmp $@; \
	  else \
	    rm -f $@.tmp; \
	    echo "lsp_io_gen.c: fallback to shux-c -E -E-extern (C-04)" >&2; \
	    ./$(SHUX_C) $(LSP_SX_E_DIRS) src/lsp/lsp_io.sx -E -E-extern > $@ || \
	      { if [ -f seeds/lsp_io_gen.linux.x86_64.c ]; then cp -f seeds/lsp_io_gen.linux.x86_64.c $@ && echo "lsp_io_gen.c: fallback seed" >&2; else exit 1; fi; }; \
	  fi; \
	else \
	  ./$(SHUX_C) $(LSP_SX_E_DIRS) src/lsp/lsp_io.sx -E -E-extern > $@ || \
	    { if [ -f seeds/lsp_io_gen.linux.x86_64.c ]; then cp -f seeds/lsp_io_gen.linux.x86_64.c $@ && echo "lsp_io_gen.c: fallback seed" >&2; else exit 1; fi; }; \
	fi

# LSP 模块：main.sx 依赖 lsp；std.io 由 .sx codegen 提供（F-03 v2/v3，无 io.o）。
# LSP state 单独 .c，避免 lsp_main 内大数组导致 state 被覆盖
src/lsp/lsp_state.o: src/lsp/lsp_state.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# lsp_gen.c 期望 typeck_read_message 等；lsp_io -E-extern 未产出时由桩提供。
src/lsp/typeck_lsp_io_stub.o: src/lsp/typeck_lsp_io_stub.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

lsp_gen.c: $(SHUX_C) src/lsp/lsp.sx
	@if [ -s lsp_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "lsp_gen.c: pinned ($$(wc -c < lsp_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/lsp_gen.linux.x86_64.c ] && [ ! -s lsp_gen.c ]; then \
	  cp -f seeds/lsp_gen.linux.x86_64.c lsp_gen.c; \
	  echo "lsp_gen.c: restored from seeds/lsp_gen.linux.x86_64.c"; \
	elif [ -f $(SHUX_SX) ]; then \
	  echo "lsp_gen.c: ./$(SHUX_SX) -sx -E ..." >&2; \
	  ./$(SHUX_SX) -sx -E $(LSP_SX_E_DIRS) -E-extern src/lsp/lsp.sx > $@.tmp 2>/dev/null || true; \
	  if [ -s $@.tmp ] && grep -q typeck_lsp_main_impl $@.tmp && ! grep -q 'lsp.sx -E-extern stubs (lsp_io_sx' $@.tmp; then \
	    mv $@.tmp $@; \
	  else \
	    rm -f $@.tmp; \
	    echo "lsp_gen.c: shux-sx failed or old extern block, fallback to shux-c -E -E-extern" >&2; \
	    ./$(SHUX_C) $(LSP_SX_E_DIRS) src/lsp/lsp.sx -E -E-extern > $@ || \
	      { if [ -f seeds/lsp_gen.linux.x86_64.c ]; then cp -f seeds/lsp_gen.linux.x86_64.c $@ && echo "lsp_gen.c: fallback seed" >&2; else exit 1; fi; }; \
	  fi; \
	else \
	  ./$(SHUX_C) $(LSP_SX_E_DIRS) src/lsp/lsp.sx -E -E-extern > $@ || \
	    { if [ -f seeds/lsp_gen.linux.x86_64.c ]; then cp -f seeds/lsp_gen.linux.x86_64.c $@ && echo "lsp_gen.c: fallback seed" >&2; else exit 1; fi; }; \
	fi
	@sed -i.bak 's/uint8_t state_buf\[16388\] = { 0 }/extern uint8_t g_lsp_state_buf[16388]/' lsp_gen.c 2>/dev/null || true
	@sed -i.bak 's/(state_buf)/(g_lsp_state_buf)/g' lsp_gen.c 2>/dev/null || true

# std_heap_* 由 lsp_io_std_heap.sx 提供（转调 libc malloc/free/calloc）；shux-sx 路径下 extern 由 codegen.sx 输出。
lsp_io_std_heap_gen.c: $(SHUX_C) src/lsp/lsp_io_std_heap.sx
	@if [ -s lsp_io_std_heap_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "lsp_io_std_heap_gen.c: pinned ($$(wc -c < lsp_io_std_heap_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/lsp_io_std_heap_gen.linux.x86_64.c ] && [ ! -s lsp_io_std_heap_gen.c ]; then \
	  cp -f seeds/lsp_io_std_heap_gen.linux.x86_64.c lsp_io_std_heap_gen.c; \
	  echo "lsp_io_std_heap_gen.c: restored from seeds/lsp_io_std_heap_gen.linux.x86_64.c"; \
	elif [ -f $(SHUX_SX) ]; then \
	  echo "lsp_io_std_heap_gen.c: ./$(SHUX_SX) -sx -E ..." >&2; \
	  ./$(SHUX_SX) -sx -E $(LSP_SX_E_DIRS) -E-extern src/lsp/lsp_io_std_heap.sx > $@.tmp 2>/dev/null || true; \
	  if [ -s $@.tmp ]; then \
	    mv $@.tmp $@; \
	  else \
	    rm -f $@.tmp; \
	    echo "lsp_io_std_heap_gen.c: shux-sx failed/OOM, fallback to shux-c -E -E-extern" >&2; \
	    ./$(SHUX_C) $(LSP_SX_E_DIRS) src/lsp/lsp_io_std_heap.sx -E -E-extern > $@ || \
	      { if [ -f seeds/lsp_io_std_heap_gen.linux.x86_64.c ]; then cp -f seeds/lsp_io_std_heap_gen.linux.x86_64.c $@ && echo "lsp_io_std_heap_gen.c: fallback seed" >&2; else exit 1; fi; }; \
	  fi; \
	else \
	  ./$(SHUX_C) $(LSP_SX_E_DIRS) src/lsp/lsp_io_std_heap.sx -E -E-extern > $@ || \
	    { if [ -f seeds/lsp_io_std_heap_gen.linux.x86_64.c ]; then cp -f seeds/lsp_io_std_heap_gen.linux.x86_64.c $@ && echo "lsp_io_std_heap_gen.c: fallback seed" >&2; else exit 1; fi; }; \
	fi
	@sed -i.bak '/^extern uint8_t \* malloc/d; /^extern void free(/d; /^extern uint8_t \* calloc/d' $@ 2>/dev/null || true
	@perl -i.bak -0pe 's/(uint8_t \* typeck_std_heap_alloc\(size_t size\);)/#define std_heap_alloc typeck_std_heap_alloc\n#define std_heap_free typeck_std_heap_free\n#define std_heap_alloc_zeroed typeck_std_heap_alloc_zeroed\n$$1/s' $@ 2>/dev/null || true
lsp_io_std_heap_sx.o: lsp_io_std_heap_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c lsp_io_std_heap_gen.c -o lsp_io_std_heap_sx.o

# bootstrap-driver-seed / relink-shux 共用：lsp_io / lsp 生成 C → .o
lsp_io_sx.o: lsp_io_gen.c src/lsp/lsp_io.sx Makefile
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. \
	  -Dstd_io_read=io_read -Dstd_io_write=io_write \
	  -Dstd_heap_alloc_usize=typeck_std_heap_alloc -Dstd_heap_free_u8_ptr=typeck_std_heap_free \
	  -Dtypeck_std_heap_alloc=lsp_io_std_heap_std_heap_alloc \
	  -Dtypeck_std_heap_free=lsp_io_std_heap_std_heap_free \
	  -c lsp_io_gen.c -o lsp_io_sx.o

lsp_sx.o: lsp_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c lsp_gen.c -o lsp_sx.o

# fmt/check/test/compile/build/run：独立 .sx -E-extern 产出；asm_driver_* 仍由 _stubs_driver.c 提供
DRIVER_SUBCMD_GEN = driver_fmt_gen.c driver_check_gen.c driver_test_gen.c driver_compile_gen.c driver_build_gen.c driver_run_gen.c driver_emit_gen.c
DRIVER_SUBCMD_OBJS = driver_fmt_sx.o driver_check_sx.o driver_test_sx.o driver_compile_sx.o driver_build_sx.o driver_run_sx.o driver_emit_sx.o
DRIVER_SUBCMD_DIRS = -L .. -L src -L src/lexer -L src/ast

driver_fmt_gen.c: $(SHUX_C) src/driver/fmt.sx
	@if [ -s driver_fmt_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_fmt_gen.c: pinned ($$(wc -c < driver_fmt_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_fmt_gen.linux.x86_64.c ] && [ ! -s driver_fmt_gen.c ]; then \
	  cp -f seeds/driver_fmt_gen.linux.x86_64.c driver_fmt_gen.c; \
	  echo "driver_fmt_gen.c: restored from seed"; \
	else \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/fmt.sx > $@ || \
	    { if [ -f seeds/driver_fmt_gen.linux.x86_64.c ]; then cp -f seeds/driver_fmt_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	fi
driver_check_gen.c: $(SHUX_C) src/driver/check.sx
	@if [ -s driver_check_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_check_gen.c: pinned ($$(wc -c < driver_check_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_check_gen.linux.x86_64.c ] && [ ! -s driver_check_gen.c ]; then \
	  cp -f seeds/driver_check_gen.linux.x86_64.c driver_check_gen.c; \
	  echo "driver_check_gen.c: restored from seed"; \
	else \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/check.sx > $@ || \
	    { if [ -f seeds/driver_check_gen.linux.x86_64.c ]; then cp -f seeds/driver_check_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	fi
driver_test_gen.c: $(SHUX_C) src/driver/test.sx
	@if [ -s driver_test_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_test_gen.c: pinned ($$(wc -c < driver_test_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_test_gen.linux.x86_64.c ] && [ ! -s driver_test_gen.c ]; then \
	  cp -f seeds/driver_test_gen.linux.x86_64.c driver_test_gen.c; \
	  echo "driver_test_gen.c: restored from seed"; \
	else \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/test.sx > $@ || \
	    { if [ -f seeds/driver_test_gen.linux.x86_64.c ]; then cp -f seeds/driver_test_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	fi
driver_compile_gen.c: $(SHUX_C) src/driver/compile.sx
	@if [ -s driver_compile_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_compile_gen.c: pinned ($$(wc -c < driver_compile_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_compile_gen.linux.x86_64.c ] && [ ! -s driver_compile_gen.c ]; then \
	  cp -f seeds/driver_compile_gen.linux.x86_64.c driver_compile_gen.c; \
	  echo "driver_compile_gen.c: restored from seed"; \
	else \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/compile.sx > $@ || \
	    { if [ -f seeds/driver_compile_gen.linux.x86_64.c ]; then cp -f seeds/driver_compile_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	fi
driver_build_gen.c: $(SHUX_C) src/driver/build.sx
	@if [ -s driver_build_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_build_gen.c: pinned ($$(wc -c < driver_build_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_build_gen.linux.x86_64.c ] && [ ! -s driver_build_gen.c ]; then \
	  cp -f seeds/driver_build_gen.linux.x86_64.c driver_build_gen.c; \
	  echo "driver_build_gen.c: restored from seed"; \
	else \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/build.sx > $@ || \
	    { if [ -f seeds/driver_build_gen.linux.x86_64.c ]; then cp -f seeds/driver_build_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	fi
driver_run_gen.c: $(SHUX_C) src/driver/run.sx
	@if [ -s driver_run_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_run_gen.c: pinned ($$(wc -c < driver_run_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_run_gen.linux.x86_64.c ] && [ ! -s driver_run_gen.c ]; then \
	  cp -f seeds/driver_run_gen.linux.x86_64.c driver_run_gen.c; \
	  echo "driver_run_gen.c: restored from seed"; \
	else \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/run.sx > $@ || \
	    { if [ -f seeds/driver_run_gen.linux.x86_64.c ]; then cp -f seeds/driver_run_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	fi
driver_emit_gen.c: $(SHUX_C) src/driver/emit.sx
	@if [ -s driver_emit_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_emit_gen.c: pinned ($$(wc -c < driver_emit_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_emit_gen.linux.x86_64.c ] && [ ! -s driver_emit_gen.c ]; then \
	  cp -f seeds/driver_emit_gen.linux.x86_64.c driver_emit_gen.c; \
	  echo "driver_emit_gen.c: restored from seed"; \
	else \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -L ../std/fs -L src/preprocess -L src/pipeline -L src/codegen -E -E-extern src/driver/emit.sx > $@ || \
	    { if [ -f seeds/driver_emit_gen.linux.x86_64.c ]; then cp -f seeds/driver_emit_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	fi

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

# 须在 pipeline_sx.o / bootstrap-pipeline 规则之前定义（Make 解析顺序；后置则 $(PIPELINE_SX_DEPS) 为空）。
PIPELINE_SX_DEPS = src/pipeline/pipeline.sx src/codegen/codegen.sx src/typeck/typeck.sx src/parser/parser.sx src/ast/ast.sx src/lexer/lexer.sx src/preprocess/preprocess.sx src/asm/asm.sx src/asm/backend.sx src/asm/platform/elf.sx src/asm/arch/arm64.sx src/asm/arch/arm64_enc.sx pipeline_glue.c ast_pool.c ast_pool_bootstrap_glue.c

# pipeline_sx.o：与 pipeline_gen.c 及 PIPELINE_SX_DEPS 绑定；parser/backend 等 .sx 变更须重编，避免 seed 仍用旧 pipeline 逻辑（entry 消失等）。
# 默认复用 build_asm/gen_driver/pipeline_sx.o（fat 编排）；设 PIPELINE_SX_FORCE_COMPILE=1 才从 pipeline_gen.c 重编。
# pipeline_glue.c / ast_pool.c 由 pipeline_glue_standalone.o 覆盖，勿因二者 mtime 触发整 TU 重编（否则与 partial 并列链 parse 塌陷）。
pipeline_sx.o: pipeline_gen.c $(PIPELINE_SX_DEPS)
	@GEN_DRV=build_asm/gen_driver/pipeline_sx.o; \
	STALE=0; \
	if [ -f "$$GEN_DRV" ] && { [ ast_pool_bootstrap_glue.c -nt "$$GEN_DRV" ]; }; then STALE=1; fi; \
	if [ -z "$$PIPELINE_SX_FORCE_COMPILE" ] && [ "$$STALE" -eq 0 ] && [ -f "$$GEN_DRV" ]; then \
	  cp "$$GEN_DRV" $@ && echo "pipeline_sx.o: from build_asm/gen_driver"; \
	else \
	  $(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I.. -Dstd_io_driver_driver_read_ptr_len=shux_io_read_ptr_len -Dstd_io_driver_driver_read_ptr=shux_io_read_ptr -c pipeline_gen.c -o $@ && \
	  mkdir -p build_asm/gen_driver && cp $@ "$$GEN_DRV"; \
	fi

# driver_gen.c / driver_sx.o：main.sx 驱动入口；-E 须 shux-c（C parser stmt_order）。
driver_gen.c: $(SHUX_C) $(MAIN_SX_DEPS)
	@if [ -s driver_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_gen.c: pinned ($$(wc -c < driver_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/driver_gen.linux.x86_64.c ] && [ ! -s driver_gen.c ]; then \
	  cp -f seeds/driver_gen.linux.x86_64.c driver_gen.c; \
	  echo "driver_gen.c: restored from seeds/driver_gen.linux.x86_64.c"; \
	else \
	  ./$(SHUX_C) $(MAIN_SX_E_DIRS) src/main.sx -E -E-extern > $@ || \
	    { if [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/driver_gen.linux.x86_64.c ]; then cp -f seeds/driver_gen.linux.x86_64.c $@ && echo "driver_gen.c: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	fi
	perl scripts/fix_driver_gen_duplicate_main.pl $@

driver_sx.o: driver_gen.c $(MAIN_SX_DEPS)
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -include src/sx_stubs.h -Dstd_fs_fs_read=fs_posix_read_c -Dstd_fs_fs_write=fs_posix_write_c -Dstd_fs_fs_close=fs_posix_close_c -Dfs_read=fs_posix_read_c -Dfs_write=fs_posix_write_c -Dfs_close=fs_posix_close_c -c driver_gen.c -o driver_sx.o

# preprocess_gen.c / preprocess_sx.o：runtime SHUX_USE_SX_PREPROCESS 路径。
preprocess_gen.c: $(SHUX_C) $(PREPROCESS_SX_DEPS)
	@if [ -s preprocess_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "preprocess_gen.c: pinned ($$(wc -c < preprocess_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/preprocess_gen.linux.x86_64.c ] && [ ! -s preprocess_gen.c ]; then \
	  cp -f seeds/preprocess_gen.linux.x86_64.c preprocess_gen.c; \
	  echo "preprocess_gen.c: restored from seeds/preprocess_gen.linux.x86_64.c"; \
	else \
	  ./$(SHUX_C) -L src/lexer -E -E-extern src/preprocess/preprocess.sx > $@ || \
	    { if [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/preprocess_gen.linux.x86_64.c ]; then cp -f seeds/preprocess_gen.linux.x86_64.c $@ && echo "preprocess_gen.c: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	fi

preprocess_sx.o: preprocess_gen.c $(PREPROCESS_SX_DEPS)
	$(CC) $(CFLAGS) -c preprocess_gen.c -o preprocess_sx.o

# SHUX_NO_C_FRONTEND 下 lsp_diag_sx.o / lsp_sx.o 需要的文档缓冲 + SX 管道缓冲桩
src/lsp/lsp_diag_stubs_no_c.o: src/lsp/lsp_diag_stubs_no_c.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# SHUX_SKIP_SUBSCRIPT_MAKE=1：run-all 入口已链 seed，子脚本 `make` 仅在校验 shux 缺失时再完整 bootstrap。
ifeq ($(SHUX_SKIP_SUBSCRIPT_MAKE),1)
bootstrap-driver-seed:
	@test -x '$(TARGET)' || $(MAKE) bootstrap-driver-seed SHUX_SKIP_SUBSCRIPT_MAKE= SHUX_RUN_ALL_BOOTSTRAP_SHUX=1
else
# G-06 两阶段 seed：先无 USER_ASM 链 shux-seed-phase1，再用其跑 asm.sx -E 生成 partial，最后全量链 shux。
DRIVER_SEED_LINK_BASE = $(DRIVER_SEED_OBJS) driver_sx.o pipeline_sx.o pipeline_bootstrap_orchestration.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o src/lsp/lsp_codegen_extern.o $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o $(PIPELINE_LIBS)

DRIVER_SEED_PREREQS = $(SHUX_C) pipeline_sx.o parser_sx.o lexer_sx.o lexer_sx_link_alias.o typeck_sx.o codegen_sx.o typeck_sx_link_alias.o codegen_sx_link_alias.o driver_sx.o preprocess_sx.o lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c $(DRIVER_SUBCMD_GEN) $(MAIN_LINK_REBUILD) src/runtime_abi.o src/runtime_io_abi.o src/runtime_proc_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o $(DRIVER_SEED_RUNTIME_O) src/driver/fmt_check_cmd_driver.o $(PREPROCESS_LINK_O) $(LEXER_LINK_O) $(AST_LINK_O) $(DRIVER_SEED_FRONTEND_EXTRA) $(DRIVER_SEED_SUPPORT_EXTRA) src/sx_seed_bridge.o src/std_fs_shim.o src/std_sys_shim.o $(AST_POOL_L5_BRIDGE_O) pipeline_bootstrap_orchestration.o src/lsp/lsp_codegen_extern.o $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_diag_sx_alias.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o _stubs_driver.o $(DRIVER_SUBCMD_OBJS) $(USER_ASM_SEED_OBJS)

bootstrap-driver-seed: $(DRIVER_SEED_PREREQS)
	@# 冷启动：保留已提交的 ast_gen2.c，避免旧 seed 对 ast.sx 重新 -E 失败。
	@if [ -f ast_gen2.c ] && [ -s ast_gen2.c ]; then touch -r ast_gen2.c src/ast/ast.sx 2>/dev/null || true; fi
	@$(MAKE) pipeline_sx.o PIPELINE_SX_FORCE_COMPILE=1
	$(MAKE) -B src/runtime_abi.o src/runtime_io_abi.o src/runtime_proc_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o $(DRIVER_SEED_RUNTIME_REBUILD) $(DRIVER_SEED_PREPROCESS_REBUILD) src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o
	$(MAKE) lsp_io_sx.o lsp_sx.o lsp_diag_sx.o
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c src/lsp/lsp_diag_sx_alias.c -o src/lsp/lsp_diag_sx_alias.o
	@# 冷启动：phase1 须链 dispatch/bridge + partial（seed 或 gen_g06_phase1_backend_stub 弱桩）。
	@chmod +x scripts/build_seed_asm_host.sh scripts/gen_g06_phase1_backend_stub.sh 2>/dev/null || true
	@os=$$(uname -s | tr '[:upper:]' '[:lower:]'); arch=$$(uname -m 2>/dev/null | tr '[:upper:]' '[:lower:]'); \
	  case "$$arch" in x86_64|amd64) arch=x86_64 ;; aarch64|arm64) arch=arm64 ;; esac; \
	  case "$$os" in darwin) os=darwin ;; linux) os=linux ;; esac; \
	  seed_partial="seeds/asm_backend_partial.$${os}.$${arch}.o"; \
	  if [ ! -s build_asm/seed_host/asm_backend_partial.o ] && [ -f "$$seed_partial" ] && [ -s "$$seed_partial" ]; then \
	    if nm "$$seed_partial" 2>/dev/null | awk '/ T / { s=$$3; sub(/^_/, "", s); if (s=="backend_asm_codegen_ast_seed_mega") found=1 } END { exit !found }'; then \
	      mkdir -p build_asm/seed_host; cp -f "$$seed_partial" build_asm/seed_host/asm_backend_partial.o; \
	      echo "bootstrap-driver-seed: seed partial <- $$seed_partial" >&2; \
	    else \
	      echo "bootstrap-driver-seed: ignore non-real seed partial $$seed_partial (missing strong seed_mega)" >&2; \
	    fi; \
	  fi
	@$(MAKE) src/asm/bootstrap_seed_io_stubs.o
	@$(MAKE) $(USER_ASM_SEED_OBJS)
	@# pipeline_sx.o / pipeline_glue_standalone.o 引用的 arch_*_enc_enc_* 须 weak 桩；真 partial 导出不含时由 stubs.o 补齐。
	@$(MAKE) $(ASM_GLUE_STANDALONE_O)
	@if [ ! -s build_asm/seed_host/asm_backend_partial.o ]; then \
	  echo "bootstrap-driver-seed: no seed partial, gen phase1 backend stub ..." >&2; \
	  ./scripts/gen_g06_phase1_backend_stub.sh; \
	fi
	@mkdir -p build_asm/seed_host
	@rm -f $(USER_ASM_SEED_HOST_STUBS) $(USER_ASM_SEED_HOST_DIR)/asm_full_link_stubs.c
	@$(MAKE) $(USER_ASM_SEED_HOST_STUBS)
	@echo "bootstrap-driver-seed: phase1 link (+ USER_ASM dispatch/bridge + seed partial) ..."
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS) -o shux-seed-phase1 $(DRIVER_SEED_GLUE_PREFIX) $(DRIVER_SEED_LINK_BASE) $(USER_ASM_SEED_OBJS) $(USER_ASM_SEED_HOST_STUBS) build_asm/seed_host/asm_backend_partial.o $(DRIVER_SEED_GLUE_SUFFIX)
	@echo "bootstrap-driver-seed: build-seed-asm-host via shux-seed-phase1 ..."
	@SHUX_E=./shux-seed-phase1 ./scripts/build_seed_asm_host.sh || \
	  (./scripts/gen_g06_phase1_backend_stub.sh && echo "bootstrap-driver-seed: WARN asm.sx -E failed, final link uses phase1 stub partial" >&2)
	@$(MAKE) $(USER_ASM_SEED_HOST_STUBS)
	@echo "bootstrap-driver-seed: final link (+ USER_ASM partial) ..."
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS) -o $(TARGET) $(DRIVER_SEED_GLUE_PREFIX) $(DRIVER_SEED_LINK_BASE) $(USER_ASM_LINK) $(DRIVER_SEED_GLUE_SUFFIX)
	@$(MAKE) runtime_panic.o
ifeq ($(SHUX_SKIP_SEED_SMOKE),1)
	@echo "bootstrap-driver-seed: skip seed smoke (SHUX_SKIP_SEED_SMOKE=1)" >&2
else
	@chmod +x scripts/bootstrap_driver_seed_smoke.sh 2>/dev/null || true
	@./scripts/bootstrap_driver_seed_smoke.sh ./$(TARGET)
endif
	cp -f $(TARGET) shux-sx
	cp -f $(TARGET) $(SHUX_C)
	cp -f $(TARGET) bootstrap_shuxc
	@chmod +x scripts/bootstrap_shuxc_create.sh scripts/capture_bootstrap_seeds.sh 2>/dev/null || true
	@./scripts/bootstrap_shuxc_create.sh ./$(TARGET) 2>/dev/null || cp -f $(TARGET) bootstrap_shuxc
	@echo "bootstrap-driver-seed OK (C-06 *_sx.o; G-06 two-phase seed + USER_ASM partial; shux-c synced)"
endif

# 与 bootstrap-driver-seed 相同；保留别名供脚本引用
# bootstrap seed 链 pipeline_bootstrap_orchestration.o 需 glue 类型头（与 build_shux_asm B-strict 同源）。
build_asm/pipeline_glue_types.inc: pipeline_gen.c scripts/extract_pipeline_glue_types.pl
	@mkdir -p build_asm
	perl scripts/extract_pipeline_glue_types.pl pipeline_gen.c > $@

pipeline_bootstrap_orchestration.o: pipeline_bootstrap_orchestration.c pipeline_gen.c build_asm/pipeline_glue_types.inc
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -Ibuild_asm -DPIPELINE_BOOTSTRAP_ORCH_NO_PIPELINE_RUN_WRAPPER -c -o $@ pipeline_bootstrap_orchestration.c

$(ASM_GLUE_STANDALONE_O): src/asm/pipeline_glue_standalone.c build_asm/pipeline_glue_types.inc pipeline_glue.c ast_pool.c
	@mkdir -p build_asm
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -Wno-error=return-type -I. -Iinclude -Isrc -Ibuild_asm -c -o $@ src/asm/pipeline_glue_standalone.c

# relink-shux 与 bootstrap-driver-seed 链接同一组 .o；须声明为 prerequisite，否则冷启动仅 make all 后缺 main_driver.o 等。
RELINK_SHUX_PREREQS = build-seed-asm-host $(USER_ASM_LINK) $(DRIVER_SUBCMD_GEN) \
  $(DRIVER_SEED_OBJS) driver_sx.o pipeline_sx.o pipeline_bootstrap_orchestration.o \
  lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c \
  lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o \
  $(DRIVER_SUBCMD_OBJS) _stubs_driver.o \
  src/lsp/lsp_codegen_extern.o $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o \
  src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o \
# driver/fmt_check 变更后快速重链 shux（不跑 asm.sx -E；需已有 build_asm/seed_host/asm_backend_partial.o）
# relink-shux-lexer：仅重建 lexer_sx.o 并重链，不触发 driver/typeck *_gen.c 再生（迭代 token enum 修复用）。
.PHONY: relink-shux relink-shux-lexer refresh-shux-asm-gate
relink-shux: bootstrap_shuxc $(RELINK_SHUX_PREREQS)
	$(MAKE) driver_fmt_sx.o driver_check_sx.o
	@$(MAKE) -B src/runtime_link_abi.o $(DRIVER_SEED_RUNTIME_REBUILD)
	@$(MAKE) pipeline_sx.o
	@$(MAKE) $(ASM_GLUE_STANDALONE_O)
	@mkdir -p build_asm/seed_host
	@$(MAKE) $(USER_ASM_SEED_HOST_STUBS)
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS) -o $(TARGET) $(DRIVER_SEED_GLUE_PREFIX) $(DRIVER_SEED_OBJS) driver_sx.o pipeline_sx.o pipeline_bootstrap_orchestration.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o src/lsp/lsp_codegen_extern.o $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o $(PIPELINE_LIBS) $(USER_ASM_LINK) $(DRIVER_SEED_GLUE_SUFFIX)
	cp -f $(TARGET) $(SHUX_C)
	cp -f $(TARGET) bootstrap_shuxc
	@echo "relink-shux OK (shux-c synced)"

relink-shux-lexer: lexer_sx.o
	@test -f build_asm/seed_host/asm_backend_partial.o || (echo "relink-shux-lexer: need build_asm/seed_host/asm_backend_partial.o (make build-seed-asm-host)" >&2; exit 1)
	@test -f driver_sx.o && test -f pipeline_sx.o && test -f parser_sx.o && test -f typeck_sx.o && test -f codegen_sx.o || (echo "relink-shux-lexer: missing *_sx.o (make bootstrap-driver-seed first)" >&2; exit 1)
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(MAIN_LINK_FLAGS) -o $(TARGET) $(DRIVER_SEED_OBJS) driver_sx.o pipeline_sx.o pipeline_bootstrap_orchestration.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o src/lsp/lsp_codegen_extern.o $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o $(PIPELINE_LIBS) $(USER_ASM_LINK)
	cp -f $(TARGET) $(SHUX_C)
	cp -f $(TARGET) bootstrap_shuxc
	@echo "relink-shux-lexer OK (lexer_sx.o only; shux-c synced)"

bootstrap-driver-seed-user-asm: bootstrap-driver-seed
	@echo "bootstrap-driver-seed-user-asm OK (= bootstrap-driver-seed + USER_ASM_LINK)"

# 实验：不链 C lexer/parser/typeck/codegen；依赖已成功的 bootstrap-driver-seed 产物。(-E-extern / 泛型单态 C 路径不可用)
DRIVER_NO_C_FRONTEND_OBJS = $(MAIN_LINK_O) src/runtime_abi.o src/runtime_io_abi.o src/runtime_proc_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o src/runtime_driver_no_c.o $(PREPROCESS_LINK_O) $(AST_LINK_O) src/codegen/codegen_pipeline_stubs.o src/typeck/typeck_f64_bits.o
shux-no-c-frontend: $(DRIVER_NO_C_FRONTEND_OBJS) src/lsp/lsp_diag_stubs_no_c.o
	@test -f driver_sx.o && test -f pipeline_sx.o && test -f preprocess_sx.o || (echo "请先 make bootstrap-driver-seed" && exit 1)
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(MAIN_LINK_FLAGS) -o $@ $(DRIVER_NO_C_FRONTEND_OBJS) driver_sx.o pipeline_sx.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o src/lsp/lsp_diag_pipeline_sizes.o src/lsp/lsp_state.o src/lsp/lsp_diag_stubs_no_c.o lsp_io_std_heap_sx.o $(PIPELINE_LIBS)
	@echo "shux-no-c-frontend OK (try: ./shux-no-c-frontend -E examples/hello.sx)"

# 注意：Makefile 中存在同名规则 `shux-sx:`，不能把 `shux-sx` 列为本目标 prerequisite，否则会先执行重链接口而非仅检测文件是否存在。
regen-lsp-gens-sx:
	@if [ ! -f $(SHUX_SX) ]; then echo "请先 make bootstrap-driver-seed（需要 ./$(SHUX_SX)）。" >&2; exit 1; fi
	rm -f lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c
	$(MAKE) lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c
	@echo "regen-lsp-gens-sx OK"

# 仅重链 ./shux-sx；pipeline/driver/preprocess 的 .sx 变更会经对应 *_sx.o 目标触发重编后再链接。
shux-sx: build-seed-asm-host src/asm/user_asm_seed_bridge.o $(DRIVER_SEED_OBJS) pipeline_sx.o driver_sx.o preprocess_sx.o
	@test -f driver_sx.o && test -f lsp_sx.o && test -f lsp_diag_sx.o && test -f src/lsp/lsp_diag_sx_alias.o && test -f lsp_io_sx.o && test -f preprocess_sx.o && test -f lsp_io_std_heap_sx.o && test -f driver_fmt_sx.o && test -f driver_check_sx.o && test -f driver_test_sx.o && test -f driver_compile_sx.o && test -f driver_build_sx.o && test -f driver_run_sx.o && test -f _stubs_driver.o || (echo "缺少 driver_sx.o 等，请先: make bootstrap-driver-seed" && exit 1)
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(MAIN_LINK_FLAGS) -o $@ $(DRIVER_SEED_OBJS) driver_sx.o pipeline_sx.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o src/lsp/lsp_codegen_extern.o $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o $(PIPELINE_LIBS) $(USER_ASM_LINK)
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

# 日常快路径：仅 strict relink（前提 build_asm/*.o 已由 prior bootstrap 产出；改 glue/runtime/link 时用，~30s）。
# 等价：./scripts/relink_shux_asm_bstrict_runtime_objs.sh（附带 bridge/Docker skip 环境）。
bootstrap-driver-bstrict-relink:
	@if [ ! -d build_asm ] || [ ! -f build_asm/pipeline.o ]; then \
	  echo "bootstrap-driver-bstrict-relink: need prior bootstrap (make bootstrap-driver-bstrict)" >&2; exit 1; fi
	@SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 \
	 SHUX_ASM_SKIP_STRICT_SMOKE=1 \
	 SHUX_ASM_SKIP_MAIN_O_REBUILD=1 \
	 SHUX_ASM_SKIP_WPO_DOGFOOD=1 \
	 SHUX_ASM_SKIP_ENTRY_SMOKE=1 \
	 SHUX_ASM_BSTRICT_RELINK_ONLY=1 \
	 SHUX=./shux_asm ./scripts/build_shux_asm.sh
	@if [ ! -f shux_asm ]; then echo "bootstrap-driver-bstrict-relink: shux_asm relink failed" >&2; exit 1; fi
	@echo "bootstrap-driver-bstrict-relink OK (strict relink only; shux_asm updated)"

# 日常/release 默认路径（M7）：等价 bootstrap-driver-bstrict；冷启动须先 bootstrap-driver-seed 或 make all。
bootstrap-driver: bootstrap-driver-bstrict

# E-06 v5 / C-03 v2：Windows MSYS2 B-strict（SKIP_GEN，禁 cc -c pipeline_gen.c）；验收 SHUX_WIN_BSTRICT=1 ./tests/run-bootstrap-bstrict-windows-gate.sh
bootstrap-driver-bstrict-windows: bootstrap-driver-bstrict
	@echo "bootstrap-driver-bstrict-windows OK (E-06 v5: SKIP_GEN B-strict; gate with SHUX_WIN_BSTRICT=1 on MSYS2)"

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

# 阶段 7：build.sx 驱动 build_tool（G-05：build_runner + build_runtime_sx，无 build_runtime.c）
build-tool: $(SHUX_C)
	./$(SHUX_C) -E -E-extern -L .. ../build.sx > build_gen.c
	./$(SHUX_C) -E -E-extern -L .. ../build_runner.sx > build_runner_gen.c
	./$(SHUX_C) -E -E-extern -L .. ../build_runtime_sx.sx > build_runtime_sx_gen.c
	$(CC) $(CFLAGS) -c build_gen.c -o build_tool.o
	$(CC) $(CFLAGS) -c src/build_tool_libc_bridge.c -o build_tool_libc_bridge.o
	$(CC) $(CFLAGS) -c build_runner_gen.c -o build_runner.o
	$(CC) $(CFLAGS) -c build_runtime_sx_gen.c -o build_runtime_sx.o
	$(CC) $(CFLAGS) -c src/build_tool_main.c -o build_tool_main.o
	$(CC) $(CFLAGS) -o build_tool build_tool_main.o build_runner.o build_tool.o build_runtime_sx.o build_tool_libc_bridge.o -lc
	@echo "build_tool OK（./build_tool ./shux；无 build_runtime.c）"

src/build_tool_main.o: src/build_tool_main.c
	$(CC) $(CFLAGS) -c src/build_tool_main.c -o src/build_tool_main.o

# 别名：与 build-tool 相同（历史 target 名）
build-tool-sx: build-tool

# 运行 build_tool 产出 shux（等价于 make bootstrap-driver，无需执行 Makefile bootstrap-driver 目标）
build-via-tool: build-tool
	./build_tool ./$(TARGET)
	@echo "build-via-tool OK（shux 已由 build_tool 产出）"

# 阶段 8.1/8.2：用 seed 产出 shu₁（C 生成 pipeline_gen.c/driver_gen.c 再链接）；用 shu₁ 再编得到 shu₂。两代跑 run-all 一致即自举验证通过。
# 注：asm 链接就绪（Goal 2）后可改为 bootstrap-driver，则 shu₁ 为 asm 版，实现「无 C 生成」自举。
# 与 bootstrap-driver-seed 一致；std.io 纯 .sx（F-03 v2/v3）。
# bootstrap-self 末尾：stage2 对 return-value -o /tmp/out_self 可与 run-return-value.sh 一致产出 Mach-O/ELF；若为 C 源码则用 cc -x c 链出临时 bin（勿假定 -o *.c 必为 C）。
bootstrap-self: bootstrap-driver-seed
	@cp $(TARGET) $(TARGET)_stage1 && \
	$(MAKE) -s pipeline_sx.o driver_sx.o preprocess_sx.o lsp_io_gen.c lsp_gen.c lsp_io_std_heap_gen.c 2>/dev/null || true && \
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Dstd_io_read=io_read -Dstd_io_write=io_write -c lsp_io_gen.c -o lsp_io_sx.o && \
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c lsp_gen.c -o lsp_sx.o && \
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c lsp_io_std_heap_gen.c -o lsp_io_std_heap_sx.o && \
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(MAIN_LINK_FLAGS) -o $(TARGET)_stage2 $(DRIVER_SEED_OBJS) driver_sx.o pipeline_sx.o lsp_sx.o lsp_diag_sx.o src/lsp/lsp_diag_sx_alias.o lsp_io_sx.o preprocess_sx.o $(DRIVER_SUBCMD_OBJS) _stubs_driver.o src/lsp/lsp_codegen_extern.o $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o src/lsp/lsp_state.o lsp_io_std_heap_sx.o $(PIPELINE_LIBS) $(USER_ASM_LINK) && \
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
bootstrap-pipeline: $(SHUX_C) $(PIPELINE_SX_DEPS)
	@if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  ./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -E -E-extern src/pipeline/pipeline.sx > pipeline_gen.c || exit 1; \
	  echo "bootstrap-pipeline: pipeline_gen.c (-E-extern thin TU; forced regen)"; \
	elif [ -s pipeline_gen.c ]; then \
	  echo "bootstrap-pipeline: pinned pipeline_gen.c ($$(wc -c < pipeline_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/pipeline_gen.linux.x86_64.c ] && [ ! -s pipeline_gen.c ]; then \
	  cp -f seeds/pipeline_gen.linux.x86_64.c pipeline_gen.c; \
	  echo "bootstrap-pipeline: restored from seeds/pipeline_gen.linux.x86_64.c"; \
	else \
	  ./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -E -E-extern src/pipeline/pipeline.sx > pipeline_gen.c || \
	    { if [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/pipeline_gen.linux.x86_64.c ]; then cp -f seeds/pipeline_gen.linux.x86_64.c pipeline_gen.c && echo "bootstrap-pipeline: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	  echo "bootstrap-pipeline: pipeline_gen.c (-E-extern thin TU; codegen 无 perl 后处理)"; \
	fi
# 仅重生成并编译 pipeline/driver/preprocess 三个 SX 对象（供调试或 build_shux_asm 对齐）
gen-sx-driver-objs: pipeline_sx.o driver_sx.o preprocess_sx.o
	@echo "gen-sx-driver-objs OK (pipeline_sx.o driver_sx.o preprocess_sx.o)"

# pipeline_gen.c 由 bootstrap-pipeline 生成；-E 时 runtime.c 在入口为 pipeline.sx 时自动追加 pipeline_glue.c 到 stdout，无 Makefile 补丁
pipeline_gen.c: bootstrap-pipeline

# 链接带 -sx 流水线的 shux（需 main_sx.o 用 -DSHUX_USE_SX_PIPELINE 编译，否则 -sx -E 不生效）
# shux-sx-pipeline 链接了；lsp_diag_pipeline_sizes.o 提供 lsp_diag 与 pipeline 间结构体 sizeof；
# _stubs_driver.o 提供 asm_driver_*（fmt/check/test 仅 bootstrap-driver-seed / shux-sx 全驱动链需要 DRIVER_SUBCMD_OBJS）
shux-sx-pipeline: bootstrap-pipeline migrate-sx-objs $(PIPELINE_SX_BASE_OBJS) pipeline_sx.o $(PIPELINE_SX_FRONTEND_OBJS) $(PIPELINE_SX_SUPPORT_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes.o _stubs_driver.o
	@# gen_driver 副本可能缺 pipeline_asm_block_*；与 bootstrap-driver-seed 一致强制从 pipeline_gen.c 重编。
	@$(MAKE) pipeline_sx.o PIPELINE_SX_FORCE_COMPILE=1
	@$(MAKE) migrate-sx-objs $(PIPELINE_SX_SATELLITE_OBJS) pipeline_bootstrap_orchestration.o build-seed-asm-host
	@$(MAKE) -B src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o
	$(CC) $(CFLAGS) -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN -o $(TARGET)_sx $(PIPELINE_SX_BASE_OBJS) pipeline_sx.o $(PIPELINE_SX_FRONTEND_OBJS) $(PIPELINE_SX_LINK_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes.o _stubs_driver.o $(PIPELINE_LIBS)
	@echo "shux_sx built; use ./shux_sx -sx -E <file.sx> to test .sx pipeline"

# 4.5（.sx 流水线编译 compiler 自身）：用 shux_sx 的 -sx -E 生成 typeck.sx / codegen.sx 对应的 C，再由 cc 链接得到新的 shux_sx_stage2。
# 这一目标的目的，是验证「完整前端（parse_into + typeck_sx_ast + codegen_sx_ast）」全部跑在 .sx 上时，仍能产出能工作的编译器。
bootstrap-sx-compiler: shux-sx-pipeline
	./$(TARGET)_sx -sx -E src/typeck/typeck.sx > typeck_sx_sx.c
	./$(TARGET)_sx -sx -E src/codegen/codegen.sx > codegen_sx_sx.c
	$(CC) $(CFLAGS) -c typeck_sx_sx.c -o typeck_sx_sx.o
	$(CC) $(CFLAGS) -c codegen_sx_sx.c -o codegen_sx_sx.o
	$(CC) $(CFLAGS) -DSHUX_USE_SX_TYPECK -DSHUX_USE_SX_CODEGEN -o $(TARGET)_sx_stage2 $(OBJS) typeck_sx_sx.o codegen_sx_sx.o
	@echo "bootstrap-sx-compiler OK (.sx 流水线生成 typeck/codegen C 并链接 shux_sx_stage2)"

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
