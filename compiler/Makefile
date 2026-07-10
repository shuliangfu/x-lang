# Shux 编译器（compiler）构建
#
# 【G-05 日常入口】优先仓库根 ./shux-build.sh build 或本目录 ./build_tool ./shux
# → scripts/g05_build_shux_asm.sh → g05_prepare_and_relink（纯 shell，零 make；FULL=1 → bstrict）
# 【本 Makefile】冷启动单文件 .o 规则、CI 历史目标、test/bootstrap-* — 兜底（非用户日常入口）。
# 【build-tool】默认 copy seeds/build_*_gen.c 链出 build_tool（不依赖已删 C 前端 -E-extern）。
#
# 阶段 1：main + lexer，产出 shux；阶段 8：可选 OPT=1 为 shux 启用 -O2
#
# 【生成 C 后无补丁】-E 产出 pipeline_gen.c / driver_gen.c 后不再做 sed/awk/perl/echo 后处理。
# pipeline_gen.c：包装/size/debug 由 runtime.c 在 -E 且入口为 pipeline.x 时追加 pipeline_glue.c 到 stdout。

CC ?= cc
CFLAGS ?= -Wall -Wextra -I. -Iinclude -Isrc
# Windows/MinGW: __attribute__((weak)) 函数符号不被 PE 格式支持，
# 所有 weak 函数在 stub 文件中变为正常定义；用 --allow-multiple-definition 解决重复定义冲突。
ifeq ($(OS),Windows_NT)
WIN_LDFLAGS = -Wl,--allow-multiple-definition
else
WIN_LDFLAGS =
endif
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
TARGET = shux
SRCS = src/main.c src/runtime.c src/async/async_liveness.c src/async/async_cps_codegen.c
# OBJS_CORE：G-06 默认 shux-c=bootstrap_shuxc；仅 SHUX_LEGACY_C_FRONTEND=1 时链下列 runtime 桩（无 C 前端 .c）。
OBJS_CORE = src/main.o src/runtime.o src/diag.o src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o src/runtime_c_import.o src/runtime_driver_strict_glue_stubs.o src/lexer/cfg_eval_bootstrap_stub.o src/driver/fmt_check_cmd.o src/async/async_liveness.o src/async/async_cps_codegen.o src/lsp/lsp_diag_pipeline_sizes.o src/lsp/lsp_diag_stubs_no_c.o
ifeq ($(SHUX_LEGACY_C_FRONTEND),1)
# 考古冷启动：完整 C 前端 shux-c（仅用于生成/刷新 seeds/ 预编译种子）
OBJS_CORE = src/main.o src/runtime.o src/diag.o src/driver/fmt_check_cmd.o src/lexer/lexer.o src/lexer/cfg_eval_bootstrap_stub.o src/ast/ast.o src/async/async_liveness.o src/async/async_cps_codegen.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_c_import.o
endif
OBJS = $(OBJS_CORE)
# 注：lsp.x 生成的 lsp_gen 与 lsp_diag 中 lsp_build_* 同名；若把 InitializeResult/response 外壳迁入 .x，
# 默认 shux 须链 lsp_x.o、lsp_io_x.o；F-03 v2/v3 std.io 由 .x codegen 提供，无 io.o。

# C 仅版 shux：无 main_x/pipeline_x，供 bootstrap-pipeline 用 -E 生成 pipeline_gen.c（避免用已链 main_x 的 $(TARGET) 导致走 .x 路径失败）
SHUX_C = shux-c
# bootstrap-driver-seed 末尾 `cp $(TARGET)` 得到；不作为 lsp_*_gen.c / driver_gen / preprocess_gen 的 Makefile 前置（否则与 seed 依赖环）。
# -E/-E-extern 生成时在 recipe 内 `test -f shux-x`：冷启动仅用 shux-c；二次构建起用 shux-x（pipeline+codegen.x），使 LSP 生成 C 与 codegen.x 的自动 extern 一致。
SHUX_X = shux-x
# 与既有 shux-c 命令行一致的 -L（lsp/*.x -E；-L src 仅限 main.x / driver_gen）
LSP_X_E_DIRS = -L .. -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess
MAIN_X_E_DIRS = -L .. -L src -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess
# main.x -E-extern 直接 import 的模块；变更须重生成 driver_gen.c / driver_x.o
MAIN_X_DEPS = src/main.x src/codegen/codegen.x src/ast/ast.x src/preprocess/preprocess.x
# preprocess.x 独立 -E-extern 入口
PREPROCESS_X_DEPS = src/preprocess/preprocess.x
.PHONY: all std-objs clean test size-baseline perf-baseline bootstrap-token bootstrap-lexer bootstrap-parser bootstrap-parse-file bootstrap-typeck bootstrap-codegen bootstrap-driver bootstrap-driver-seed bootstrap-driver-bstrict bootstrap-driver-bstrict-relink bootstrap-driver-bstrict-windows bootstrap-driver-crt0 bootstrap-driver-asm bootstrap-driver-asm-only bootstrap-asm bootstrap_shuxc check-asm-o-quality check-6.4 bootstrap-self check-7.2 check-7.2-bstrict bootstrap-verify bootstrap-verify-seed bootstrap-verify-bstrict bootstrap-verify-stage2 bootstrap-verify-stage2-bstrict bootstrap-test build-tool build-tool-x build-via-tool first-time verify-selfhost-stage2 regen-lsp-gens-x shux-no-c-frontend gen-x-driver-objs build-user-asm-backend build-seed-user-asm-partial bootstrap-driver-seed-user-asm compile_commands.json

# std.process：F 闭合 — mod.x + process.x 用 -E-extern 编译（裸符号），
# ld -r 合并 runtime_process_argv.o + runtime_process_os_glue.o（提供 process_*_c 定义）。
../std/process/process.o: ../std/process/mod.x ../std/process/process.x scripts/shux_compile_std_module.sh runtime_process_argv.o runtime_process_os_glue.o
	@sh scripts/shux_compile_std_module.sh --bare-impl $@.core ../std/process/mod.x ../std/process/process.x && \
	ld -r -o $@ $@.core runtime_process_argv.o runtime_process_os_glue.o && \
	rm -f $@.core

# std.string：F 闭合 — mod.x + string.x 用 -E-extern 编译（裸符号），
# ld -r 合并 runtime_string_fast.o（提供 string_*_c fast-path 定义）。
../std/string/string.o: ../std/string/mod.x ../std/string/string.x scripts/shux_compile_std_module.sh src/asm/runtime_string_fast.inc scripts/cc_inc_tu.sh
	@sh scripts/cc_inc_tu.sh src/asm/runtime_string_fast.inc $@.fast && \
	sh scripts/shux_compile_std_module.sh --bare-impl $@.core ../std/string/mod.x ../std/string/string.x && \
	ld -r -o $@ $@.core $@.fast && \
	rm -f $@.core $@.fast

# std.path：保留 mod.x 作为 F-path v1 源码锚点；path.o 由 C provider 产出，
# 避免 bootstrap asm backend 在 dirname/last_slash 链上反复卡住。
../std/path/path.o: ../std/path/mod.x src/asm/runtime_path_fast.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_path_fast.inc ../std/path/path_core.o && \
	ld -r -o ../std/path/path.o ../std/path/path_core.o && \
	rm -f ../std/path/path_core.o

# std.heap：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + libc + ops）。
../std/heap/heap.o: ../std/heap/mod.x ../std/heap/libc.x ../std/heap/ops.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh $@ ../std/heap/mod.x ../std/heap/libc.x ../std/heap/ops.x

# std.heap.page_mmap：F-no-libc NL-03 freestanding mmap bump 堆（单文件 .x -E + cc）。
# 路径前缀 std_heap_page_mmap_*；传递依赖 std.sys.linux + core.mem 由 freestanding on_demand 链入。
../std/heap/page_mmap.o: ../std/heap/page_mmap.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh $@ ../std/heap/page_mmap.x

# std.sys：OS 原语门面（mod.x -E + cc；#[cfg(target_os)] 分平台）。
# 路径前缀 std_sys_*；Linux 编译激活 linux import，传递依赖 std/sys/linux.o + core/mem/mem.o。
../std/sys/sys.o: ../std/sys/mod.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh $@ ../std/sys/mod.x

# std.sys.linux：Linux syscall 号表 + freestanding invoke（linux.x -E + cc）。
# 路径前缀 std_sys_linux_*；含 hosted libc 函数（open/mmap），靠 --gc-sections 移除未引用者。
../std/sys/linux.o: ../std/sys/linux.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh $@ ../std/sys/linux.x

# core.mem：内存操作原语（mod.x -E + cc）。
# 路径前缀 core_mem_*；align_up/mem_copy/mem_set 等纯 .x 实现，无 libc 依赖。
../core/mem/mem.o: ../core/mem/mod.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh $@ ../core/mem/mod.x

# std.map：F 闭合 — 纯 .x -E-extern + cc -c。
../std/map/map.o: ../std/map/mod.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/map/mod.x

# std.set：F 闭合 — 纯 .x -E-extern + cc -c。
../std/set/set.o: ../std/set/mod.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/set/mod.x

# std.runtime：保留 runtime.x 作为 F-runtime v1 源码锚点；runtime.o 仅提供
# runtime_panic/runtime_abort/runtime_crash_evidence_collect_c 三个 extern provider。
../std/runtime/runtime.o: ../std/runtime/runtime.x src/asm/runtime_std_runtime_fast.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_std_runtime_fast.inc ../std/runtime/runtime_core.o && \
	ld -r -o ../std/runtime/runtime.o ../std/runtime/runtime_core.o && \
	rm -f ../std/runtime/runtime_core.o

# std.net：F-04 v10～v14 纯 .x（F-ZC）；OS glue 由 runtime_net_*_fast.inc 提供（G-02e-18）。
../std/net/net.o: ../std/net/alpn.x ../std/net/dns.x ../std/net/io_batch.x ../std/net/addr.x ../std/net/ipv6.x ../std/net/sock.x ../std/net/udp.x ../std/net/tcp.x ../std/net/udp_batch.x ../std/net/workers.x src/asm/runtime_net_dns_fast.inc src/asm/runtime_net_io_batch_fast.inc src/asm/runtime_net_addr_fast.inc src/asm/runtime_net_ipv6_fast.inc src/asm/runtime_net_sock_fast.inc scripts/cc_inc_tu.sh
	@objs=""; \
	shux="$${SHUX:-}"; \
	if [ -z "$$shux" ] || [ ! -x "$$shux" ]; then \
	  if [ -x ./shux-c ]; then shux=./shux-c; \
	  elif [ -x ./shux_asm ]; then shux=./shux_asm; \
	  elif [ -x ./shux ]; then shux=./shux; \
	  else shux=; fi; \
	fi; \
	if [ -n "$$shux" ]; then \
	  for x in alpn udp tcp udp_batch workers; do \
	  sh scripts/shux_compile_std_x.sh $$shux ../std/net/$$x.x ../std/net/$$x.o || exit 1; \
	  objs="$$objs ../std/net/$$x.o"; \
	  done; \
	  sh scripts/cc_inc_tu.sh src/asm/runtime_net_dns_fast.inc ../std/net/net_dns_fast.o && \
	  sh scripts/cc_inc_tu.sh src/asm/runtime_net_io_batch_fast.inc ../std/net/net_io_batch_fast.o && \
	  sh scripts/cc_inc_tu.sh src/asm/runtime_net_addr_fast.inc ../std/net/net_addr_fast.o && \
	  sh scripts/cc_inc_tu.sh src/asm/runtime_net_ipv6_fast.inc ../std/net/net_ipv6_fast.o && \
	  sh scripts/cc_inc_tu.sh src/asm/runtime_net_sock_fast.inc ../std/net/net_sock_fast.o && \
	  ld -r $(LD_R_MULTIDEF_FLAGS) -o $@ $$objs ../std/net/net_dns_fast.o ../std/net/net_io_batch_fast.o ../std/net/net_addr_fast.o ../std/net/net_ipv6_fast.o ../std/net/net_sock_fast.o && \
	  rm -f ../std/net/net_dns_fast.o ../std/net/net_io_batch_fast.o ../std/net/net_addr_fast.o ../std/net/net_ipv6_fast.o ../std/net/net_sock_fast.o; \
	else \
	  echo "net.o: need shux-c to merge net_*.x"; exit 0; \
	fi

net-o-stub:
	$(MAKE) ../std/net/net.o

# TLS：F-04 v8 net-o-openssl 编译 std/net/tls_openssl.x（不再 #include tls_openssl.inc.c）。
net-o-openssl:
	@if [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/net/tls_openssl.x -o ../std/net/tls_openssl.o && \
	  $(MAKE) net-o-stub; \
	elif [ -x ./shux ]; then \
	  ./shux -backend asm -L .. ../std/net/tls_openssl.x -o ../std/net/tls_openssl.o && \
	  $(MAKE) net-o-stub; \
	elif [ -x ./shux-c ]; then \
	  ./shux-c -L .. ../std/net/tls_openssl.x -o ../std/net/tls_openssl.o && \
	  $(MAKE) net-o-stub; \
	else \
	  echo "net-o-openssl: need shux_asm, shux, or shux-c"; exit 1; \
	fi

net-o-mbedtls:
	@if [ -x ./shux_asm ]; then \
	  ./shux_asm -backend asm -L .. ../std/net/tls_mbedtls.x -o ../std/net/tls_mbedtls_main.o && \
	  $(MAKE) runtime_tls_mbedtls_bio.o && \
	  ld -r -o ../std/net/tls_mbedtls.o ../std/net/tls_mbedtls_main.o runtime_tls_mbedtls_bio.o && \
	  $(MAKE) net-o-stub; \
	elif [ -x ./shux ]; then \
	  ./shux -backend asm -L .. ../std/net/tls_mbedtls.x -o ../std/net/tls_mbedtls_main.o && \
	  $(MAKE) runtime_tls_mbedtls_bio.o && \
	  ld -r -o ../std/net/tls_mbedtls.o ../std/net/tls_mbedtls_main.o runtime_tls_mbedtls_bio.o && \
	  $(MAKE) net-o-stub; \
	elif [ -x ./shux-c ]; then \
	  ./shux-c -L .. ../std/net/tls_mbedtls.x -o ../std/net/tls_mbedtls_main.o && \
	  $(MAKE) runtime_tls_mbedtls_bio.o && \
	  ld -r -o ../std/net/tls_mbedtls.o ../std/net/tls_mbedtls_main.o runtime_tls_mbedtls_bio.o && \
	  $(MAKE) net-o-stub; \
	else \
	  echo "net-o-mbedtls: need shux_asm, shux, or shux-c"; exit 1; \
	fi

# std.thread：F-thread v2 纯 .x（F-ZC）；pthread 胶层在 runtime_thread_glue.o；Unix 需 -lpthread。
../std/thread/thread.o: ../std/thread/thread.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make thread.o: need shux-c or shux (F-thread zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/thread/thread.x ../std/thread/thread.o

# std.async：F-async v2 纯 .x（F-ZC）；调度胶层在 runtime_scheduler_glue.o；Unix 按需 -pthread。
../std/async/scheduler.o: ../std/async/scheduler.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make scheduler.o: need shux-c or shux (F-async zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/async/scheduler.x ../std/async/scheduler.o

# std.async：F-async-future v2 纯 .x → future.o（同 hash/cache）。
../std/async/future.o: ../std/async/future.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "future.o: need shux-c or shux (F-async-future v2)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/async/future.x ../std/async/future.o

# std.time：F 闭合 — mod.x 内联派生函数（now_monotonic_us/sleep_ms/duration_ns 等），
# 仅 5 个基础 OS extern 由 runtime_time_os.o 提供。无需 time.x / time_import_alias.c。
../std/time/time.o: ../std/time/mod.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/time/mod.x

# std.random：F 闭合 — mod.x（用户 API）+ random.x（impl 裸符号）用 -E-extern 编译；
# CSPRNG OS 在 runtime_random_fill.o，最终 exe 链接时按需推入。
../std/random/random.o: ../std/random/mod.x ../std/random/random.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/random/mod.x ../std/random/random.x

# std.env：F-env v2 纯 .x（F-ZC）；OS 胶层在 runtime_env_os.o。
../std/env/env.o: ../std/env/env.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make env.o: need shux-c or shux (F-env zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/env/env.x ../std/env/env.o

# std.sync：F 闭合 — mod.x（用户 API）+ sync.x（impl 裸符号）用 -E-extern 编译；
# OS/TLS 胶层在 runtime_sync_*.o，最终 exe 链接时按需推入。
../std/sync/sync.o: ../std/sync/mod.x ../std/sync/sync.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/sync/mod.x ../std/sync/sync.x

# std.queue：F-queue v2 纯 .x（F-ZC）；pthread 胶层在 runtime_queue_contention.o。
../std/queue/queue.o: ../std/queue/queue.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make queue.o: need shux-c or shux (F-queue zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/queue/queue.x ../std/queue/queue.o

# std.encoding：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + encoding）。
../std/encoding/encoding.o: ../std/encoding/mod.x ../std/encoding/encoding.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/encoding/mod.x ../std/encoding/encoding.x

# std.base64：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + base64）。
../std/base64/base64.o: ../std/base64/mod.x ../std/base64/base64.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/base64/mod.x ../std/base64/base64.x

# std.crypto：F-闭合 — mod.x + 5 .x 用 -E-extern 编译（裸符号）。
# mod.x 提供 extern 声明 + 公共 API；core/aes_gcm/chacha20_*/ed25519.x 提供裸符号实现。
../std/crypto/crypto.o: ../std/crypto/mod.x ../std/crypto/core.x ../std/crypto/aes_gcm.x ../std/crypto/chacha20_poly1305.x ../std/crypto/chacha20_aead.x ../std/crypto/ed25519.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/crypto/mod.x ../std/crypto/core.x ../std/crypto/aes_gcm.x ../std/crypto/chacha20_poly1305.x ../std/crypto/chacha20_aead.x ../std/crypto/ed25519.x

# std.log：F-闭合 — mod.x + log.x 用 -E-extern 编译（裸符号）。
# mod.x 提供 extern 声明 + 公共 API；log.x 提供 log_write_c 等裸符号实现。
../std/log/log.o: ../std/log/mod.x ../std/log/log.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/log/mod.x ../std/log/log.x


# std.test：F 闭合 — mod.x（用户 API）+ test.x（impl 裸符号）用 -E-extern 编译；
# fn-ptr 在 runtime_test_fn_invoke.o，最终 exe 链接时按需推入。
../std/test/test.o: ../std/test/mod.x ../std/test/test.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/test/mod.x ../std/test/test.x

# std.atomic：F 闭合 — mod.x（用户 API）+ atomic.x（impl 裸符号）用 -E-extern 编译；
# 原子胶层在 runtime_atomic_glue.o，最终 exe 链接时按需推入。
../std/atomic/atomic.o: ../std/atomic/mod.x ../std/atomic/atomic.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/atomic/mod.x ../std/atomic/atomic.x

# std.channel：F-channel v2 纯 .x（F-ZC）；channel 胶层在 runtime_channel_glue.o；Unix 需 -lpthread。
../std/channel/channel.o: ../std/channel/channel.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make channel.o: need shux-c or shux (F-channel zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/channel/channel.x ../std/channel/channel.o

# std.backtrace：F-backtrace v2 纯 .x（F-ZC）；平台胶层在 runtime_backtrace_platform.o。
../std/backtrace/backtrace.o: ../std/backtrace/backtrace.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make backtrace.o: need shux-c or shux (F-backtrace zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/backtrace/backtrace.x ../std/backtrace/backtrace.o

# std.hash：F 闭合 — mod.x（用户 API）+ hash.x（impl 裸符号）用 -E-extern 编译。
../std/hash/hash.o: ../std/hash/mod.x ../std/hash/hash.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/hash/mod.x ../std/hash/hash.x

# std.math：F-math v2 纯 .x（F-ZC）；libm 胶层在 runtime_math_libm.o（链接 exe 仍须 -lm）。
# LANG-007 v2：shux-c -E → cc -c 库模块；fallback shux_compile_std_x.sh。
../std/math/math.o: ../std/math/math.x
	@if [ -x ./shux-c ]; then \
	  ./shux-c -E -L .. ../std/math/math.x > ../std/math/math_core_gen.c && \
	  $(CC) $(CFLAGS) -c -o ../std/math/math.o ../std/math/math_core_gen.c && \
	  rm -f ../std/math/math_core_gen.c; \
	elif [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	else echo "make math.o: need shux-c or shux (F-math zero-c)" >&2; exit 0; fi; \
	if [ ! -f ../std/math/math.o ]; then \
	  sh scripts/shux_compile_std_x.sh auto ../std/math/math.x ../std/math/math.o; \
	fi

# std.sort：F-sort v1 纯 .x（sort.x）；无胶层 C。
../std/sort/sort.o: ../std/sort/sort.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make sort.o: need shux-c or shux (F-sort v1)" >&2; exit 1; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/sort/sort.x ../std/sort/sort.o

# G-01：core/ 零 C — 位运算/volatile/slice 已纯 .x（见 analysis/phase-g-full-selfhost-tasks-v1.md）

# std.ffi：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + ffi）。
../std/ffi/ffi.o: ../std/ffi/mod.x ../std/ffi/ffi.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/ffi/mod.x ../std/ffi/ffi.x


# std.context：F-闭合 — mod.x + context.x 用 -E-extern 编译（裸符号）。
# mod.x 提供 is_cancelled/deadline_ns/remaining_ns 等公共 API；context.x 提供 ctx_*_c 实现。
../std/context/context.o: ../std/context/mod.x ../std/context/context.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/context/mod.x ../std/context/context.x

# std.error：F-闭合 — mod.x 用 -E-extern 编译。提供 http_err_cancelled/timeout 等错误码 API。
../std/error/error.o: ../std/error/mod.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh $@ ../std/error/mod.x


# std.datetime：F-datetime v2 + F-ZC 纯 datetime.x → datetime.o（无 glue；无 shux 时 exit 0）。
../std/datetime/datetime.o: ../std/datetime/datetime.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "datetime.o: need shux-c or shux (F-datetime zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/datetime/datetime.x ../std/datetime/datetime.o

# std.uuid：F-uuid v1 纯 .x（uuid.x）；依赖 random.o + time.o。
../std/uuid/uuid.o: ../std/uuid/uuid.x ../std/random/random.o ../std/time/time.o
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make uuid.o: need shux-c or shux (F-uuid v1)" >&2; exit 1; fi; \
	$(MAKE) -q ../std/random/random.o 2>/dev/null || $(MAKE) ../std/random/random.o; \
	$(MAKE) -q ../std/time/time.o 2>/dev/null || $(MAKE) ../std/time/time.o; \
	sh scripts/shux_compile_std_x.sh auto ../std/uuid/uuid.x ../std/uuid/uuid.o

# std.url：F-url v2 + F-ZC 纯 url.x → url.o（无 glue；无 shux 时 exit 0）。
../std/url/url.o: ../std/url/url.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "url.o: need shux-c or shux (F-url v2 zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/url/url.x ../std/url/url.o

# std.cli：命令行解析（std/cli/cli.c）。
# std.cli：F-cli v1 纯 .x（cli.x）；零胶层 C。
../std/cli/cli.o: ../std/cli/cli.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make cli.o: need shux-c or shux (F-cli v1)" >&2; exit 1; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/cli/cli.x ../std/cli/cli.o


# std.security：F-security v1 + F-ZC 纯 security.x → security.o（无 glue；无 shux 时 exit 0）。
../std/security/security.o: ../std/security/security.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "security.o: need shux-c or shux (F-security zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/security/security.x ../std/security/security.o


# std.config：F-config v2 + F-ZC 纯 config.x → config.o（无 glue；无 shux 时 exit 0）。
../std/config/config.o: ../std/config/config.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "config.o: need shux-c or shux (F-config v2 zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/config/config.x ../std/config/config.o

# std.cache：F-cache v2 纯 .x（cache.x）；零胶层 C。
../std/cache/cache.o: ../std/cache/cache.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "cache.o: need shux-c or shux (F-cache v2)" >&2; exit 1; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/cache/cache.x ../std/cache/cache.o

# std.trace：F-trace v2 纯 trace.x → trace.o（无 glue；无 shux 时 exit 0）。
../std/trace/trace.o: ../std/trace/trace.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "trace.o: need shux-c or shux (F-trace v2)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/trace/trace.x ../std/trace/trace.o


# std.task：F-task v2 纯 .x → task.o（同 trace/cache v2）。
../std/task/task.o: ../std/task/task.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "task.o: need shux-c or shux (F-task v2)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/task/task.x ../std/task/task.o


# std.schema：F-schema v2 纯 .x → schema.o（同 cache/encoding）。
../std/schema/schema.o: ../std/schema/schema.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "schema.o: need shux-c or shux (F-schema v2)" >&2; exit 1; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/schema/schema.x ../std/schema/schema.o

# std.db.kv：F-05 v2 纯 .x（F-ZC）；mmap 胶层在 runtime_kv_mmap_glue.o。
../std/db/kv/kv.o: ../std/db/kv/kv.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make kv.o: need shux-c or shux (F-db-kv zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/db/kv/kv.x ../std/db/kv/kv.o

# std.db.arrow：F-05 v1 纯 .x（F-ZC）；SIMD 胶层在 runtime_arrow_simd_glue.o。
../std/db/arrow/arrow.o: ../std/db/arrow/arrow.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make arrow.o: need shux-c or shux (F-db-arrow zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/db/arrow/arrow.x ../std/db/arrow/arrow.o

# std.sys.mmap：F-02 v1 Linux/macOS 纯 .x（已移除 mmap.inc.c）
# std.sys.win32：F-02 v2 纯 .x kernel32 FFI（已移除 win32.inc.c / win32_net.inc.c）

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

# std.db.sqlite：F-05 v3 纯 .x（F-ZC）；sqlite3 胶层在 runtime_sqlite_glue.o。
../std/db/sqlite/sqlite.o: ../std/db/sqlite/sqlite.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "make sqlite.o: need shux-c or shux (F-db-sqlite zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/db/sqlite/sqlite.x ../std/db/sqlite/sqlite.o
sqlite-o: ../std/db/sqlite/sqlite.o runtime_sqlite_glue.o
sqlite-o-stub:
	$(MAKE) runtime_sqlite_glue_stub.o
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else shux=; fi; \
	if [ -n "$$shux" ]; then \
	  sh scripts/shux_compile_std_x.sh auto ../std/db/sqlite/sqlite.x ../std/db/sqlite/sqlite_main.o || exit 1; \
	  ld -r -o ../std/db/sqlite/sqlite.o ../std/db/sqlite/sqlite_main.o runtime_sqlite_glue_stub.o; \
	else \
	  ld -r -o ../std/db/sqlite/sqlite.o runtime_sqlite_glue_stub.o; \
	  echo "sqlite.o-stub: need shux-c to merge sqlite.x"; \
	fi

# std.elf：F-elf v2 + F-ZC 纯 elf.x → elf.o（无 glue；无 shux 时 exit 0）。
../std/elf/elf.o: ../std/elf/elf.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "elf.o: need shux-c or shux (F-elf v2 zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/elf/elf.x ../std/elf/elf.o

# P4 std 模块（按需链接）
# std.json：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + json）。
../std/json/json.o: ../std/json/mod.x ../std/json/json.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/json/mod.x ../std/json/json.x
# std.csv：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + csv）。
../std/csv/csv.o: ../std/csv/mod.x ../std/csv/csv.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/csv/mod.x ../std/csv/csv.x
# std.regex：F-regex v2 纯 .x → regex.o（同 hash/schema）。
../std/regex/regex.o: ../std/regex/regex.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "regex.o: need shux-c or shux (F-regex v2)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/regex/regex.x ../std/regex/regex.o
# F-04 v7：std.compress 全格式已迁 .x；compress.o 不再构建，保留 target 名兼容门禁。
compress-o-zlib compress-o-zlib-zstd compress-o-brotli compress-o-zlib-zstd-brotli:
	@true
# std.unicode：F-unicode v2 纯 .x → unicode.o（同 hash/schema）。
../std/unicode/unicode.o: ../std/unicode/unicode.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "unicode.o: need shux-c or shux (F-unicode v2)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/unicode/unicode.x ../std/unicode/unicode.o
# std.dynlib：F 闭合 — mod.x（用户 API）+ dynlib.x（impl 裸符号）用 -E-extern 编译；
# dlopen 胶层在 runtime_dynlib_os.o，最终 exe 链接时按需推入。
../std/dynlib/dynlib.o: ../std/dynlib/mod.x ../std/dynlib/dynlib.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/dynlib/mod.x ../std/dynlib/dynlib.x
# std.http：F 闭合 — mod.x（用户 API）+ http.x（impl 裸符号）用 -E-extern 编译；
# HTTP 胶层在 runtime_http_glue.o，最终 exe 链接时按需推入。
../std/http/http.o: ../std/http/mod.x ../std/http/http.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/http/mod.x ../std/http/http.x

# std.socketio：F-socketio v2 纯 socketio.x；ld -r 合并为 socketio.o（P3 可选）。
../std/socketio/socketio.o: ../std/socketio/socketio.x
	@objs=""; \
	if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else \
	  echo "socketio.o: need shux-c to compile socketio.x"; exit 0; \
	fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/socketio/socketio.x ../std/socketio/socketio_main.o || exit 1; \
	objs="$$objs ../std/socketio/socketio_main.o"; \
	$(LD) $(LD_RELFLAGS) -r -o $@ $$objs
# std.tar：F-tar v2 纯 tar.x；import binding 别名桩 tar_import_alias.c。
# std.tar：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + tar）。
../std/tar/tar.o: ../std/tar/mod.x ../std/tar/tar.x scripts/shux_compile_std_module.sh
	@sh scripts/shux_compile_std_module.sh --bare-impl $@ ../std/tar/mod.x ../std/tar/tar.x
# std.simd：F-simd v1 + F-ZC 纯 simd.x → simd.o（无 glue；无 shux 时 exit 0）。
../std/simd/simd.o: ../std/simd/simd.x
	@if [ -x ./shux_asm ]; then shux=./shux_asm; \
	elif [ -x ./shux ]; then shux=./shux; \
	elif [ -x ./shux-c ]; then shux=./shux-c; \
	else echo "simd.o: need shux-c or shux (F-simd zero-c)" >&2; exit 0; fi; \
	sh scripts/shux_compile_std_x.sh auto ../std/simd/simd.x ../std/simd/simd.o


# 测试与 shux 链接 std 时依赖的 .o：所有 std 模块 + runtime_panic.o；Linux 另预编 freestanding 链入桩
STD_AND_PANIC_O = ../std/heap/heap.o ../std/heap/page_mmap.o ../std/sys/sys.o ../std/sys/linux.o ../core/mem/mem.o ../std/map/map.o ../std/set/set.o ../std/process/process.o ../std/string/string.o ../std/path/path.o ../std/runtime/runtime.o ../std/net/net.o ../std/thread/thread.o ../std/async/scheduler.o ../std/time/time.o ../std/random/random.o ../std/env/env.o ../std/sync/sync.o ../std/encoding/encoding.o ../std/base64/base64.o ../std/crypto/crypto.o ../std/log/log.o ../std/atomic/atomic.o ../std/channel/channel.o ../std/backtrace/backtrace.o ../std/hash/hash.o ../std/math/math.o ../std/sort/sort.o ../std/ffi/ffi.o ../std/json/json.o ../std/csv/csv.o ../std/regex/regex.o ../std/unicode/unicode.o ../std/dynlib/dynlib.o ../std/http/http.o ../std/tar/tar.o ../std/simd/simd.o ../std/context/context.o ../std/error/error.o ../std/trace/trace.o ../std/test/test.o runtime_panic.o runtime_asm_io_stubs.o runtime_process_argv.o runtime_process_os_glue.o runtime_test_fn_invoke.o runtime_random_fill.o runtime_time_os.o runtime_dynlib_os.o runtime_env_os.o runtime_backtrace_platform.o runtime_log_os.o runtime_math_libm.o runtime_atomic_glue.o runtime_channel_glue.o runtime_net_udp_batch.o runtime_net_workers.o runtime_sync_os.o runtime_sync_lock_diag_tls.o runtime_thread_glue.o runtime_scheduler_glue.o runtime_http_glue.o runtime_crypto_inc_glue.o runtime_ed25519_ref10_glue.o
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
	$(CC) $(CFLAGS) -o $@ $^ $(WIN_LDFLAGS)

# G-06：默认 shux-c = bootstrap_shuxc 预编译种子（无 cc 编 OBJS_CORE）；考古：SHUX_LEGACY_C_FRONTEND=1。
bootstrap_shuxc: scripts/bootstrap_shuxc_create.sh scripts/select_bootstrap_shuxc.sh
	@chmod +x scripts/select_bootstrap_shuxc.sh 2>/dev/null || true
	@./scripts/select_bootstrap_shuxc.sh

# 考古 shux-c 额外链 runtime ABI 薄壳（runtime.c 已拆分，LEGACY C 前端仍依赖这些符号）
LEGACY_SHUX_C_EXTRA = src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o src/runtime_c_import.o src/runtime_driver_strict_glue_stubs.o

ifeq ($(SHUX_LEGACY_C_FRONTEND),1)
$(SHUX_C): $(OBJS_CORE) $(LEGACY_SHUX_C_EXTRA)
	$(CC) $(CFLAGS) -o $@ $^ $(PIPELINE_LIBS) $(WIN_LDFLAGS)

# G-02a: lexer.o 从 runtime_lexer_glue.inc 编译（G-02e-19：cc_inc_tu）。
# 仅提供 lexer_new/lexer_free；lexer_next 由 lexer_x.o（.x）或 runtime_driver_strict_glue_stubs.o（weak 桩）提供。
src/lexer/lexer.o: src/asm/runtime_lexer_glue.inc src/lexer/lexer.h include/token.h scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_lexer_glue.inc $@

# G-02a: ast.o 从 runtime_ast_glue.inc 编译（LEGACY 模式 SHUX_LEGACY_C_FRONTEND=1）。
# LEGACY parser.o 不引用 ast_expr_init_match_enum，安全。
src/ast/ast.o: src/asm/runtime_ast_glue.inc include/ast.h scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_ast_glue.inc $@

src/diag.o: src/diag.c include/diag.h
	$(CC) $(CFLAGS) -c -o $@ $<

# G-02a: typeck.c 已物理删除；typeck.o 由 typeck.x 生成（typeck_x.o），C 编排由 typeck_c_module_stubs.o 提供。

# G-02a: codegen.c 已物理删除；codegen_x.o 由 codegen.x 生成，codegen_pipeline_stubs.o 提供 weak 桩。

else
# SHUX_SKIP_SUBSCRIPT_MAKE=1 时跳过 cp：run-all 入口已构建真正 C 前端（SHUX_LEGACY_C_FRONTEND=1），
# 此处 cp 会覆盖之导致回归全部失败。bootstrap_shuxc target 仍会跑 select_bootstrap_shuxc.sh 同步种子。
$(SHUX_C): bootstrap_shuxc
	@if [ -z "$${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then cp -f bootstrap_shuxc $@; else echo "shux-c: SHUX_SKIP_SUBSCRIPT_MAKE=1, skip cp (preserve real C frontend)"; fi
endif

# G-02a: lsp_diag.c 迁移到 runtime_lsp_glue.inc（24 个符号被 lsp_x.o/fmt_check_cmd*.o/runtime*.o 引用）
# 全局规则，LEGACY 和默认模式共用。
src/lsp/lsp_diag.o: src/asm/runtime_lsp_glue.inc src/lsp/lsp_diag.h include/diag.h scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_lsp_glue.inc $@

# `shux-c` 默认模式可能只是 bootstrap_shuxc 的同步副本；凡是依赖 `-E/-E-extern`
# 生成当前源码对应 C 的目标，必须先强制刷新一次 legacy C frontend，避免继续吃旧语义。
.PHONY: legacy-shux-c-ready
legacy-shux-c-ready:
	@$(MAKE) $(SHUX_C)

LEGACY_SHUX_C_READY_TARGETS = build-tool

$(LEGACY_SHUX_C_READY_TARGETS): | legacy-shux-c-ready

src/main.o: src/main.c
	$(CC) $(CFLAGS) -c -o $@ $<

# E-04 v2/v3：argv/target 与 POSIX I/O ABI 薄壳；默认 seed / B-strict 均链入。

src/runtime_io_abi.o: src/runtime_io_abi.c src/runtime_io_abi.h
	$(CC) $(CFLAGS) -c -o $@ $<


src/runtime_link_abi.o: src/runtime_link_abi.c src/runtime_link_abi.h src/runtime_proc_abi.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/runtime_driver_abi.o: src/runtime_driver_abi.c src/runtime_driver_abi.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/runtime_pipeline_abi.o: src/runtime_pipeline_abi.c src/runtime_pipeline_abi.h Makefile
	$(CC) $(CFLAGS) $(RUNTIME_PIPELINE_ABI_CFLAGS) -c -o $@ $<

src/runtime_c_import.o: src/runtime_c_import.c src/runtime_c_import.h
	$(CC) $(CFLAGS) -c -o $@ $<

src/runtime_driver_diagnostic.o: src/runtime_driver_diagnostic.c src/runtime_driver_diagnostic.h include/diag.h
	$(CC) $(CFLAGS) -c -o $@ $<

# 6.3：runtime.c 提供 run_compiler_c 与弱符号 main_entry；带 .x 入口时用 runtime_driver.o（含 driver_*/pipeline_*）
src/runtime.o: src/runtime.c include/diag.h
	$(CC) $(CFLAGS) -c -o $@ $<
# Makefile 为 prerequisite：编译宏（如 SHUX_USE_X_PREPROCESS）变更时须重编，否则 runtime_driver.o 缺 preprocess() 导致链接 Undefined _preprocess。
# SHUX_ASM_USE_COMPILER_IMPL_C：driver_run_compiler_full 走 impl_c（parse_argv+post_parse），避免 compile.x X emit 路径 silent fail（与 B-strict shux_asm 同）。
# E-03 v2：SHUX_LEGACY_PREPROCESS_C=1 时 runtime preprocess() 仍调 C preprocess_c_fallback。
RUNTIME_DRIVER_CFLAGS = -DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_PREPROCESS -DSHUX_ASM_USE_COMPILER_IMPL_C
RUNTIME_DRIVER_NO_C_CFLAGS = -DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_PREPROCESS -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN -DSHUX_NO_C_FRONTEND -DSHUX_ASM_USE_COMPILER_IMPL_C
ifeq ($(SHUX_LEGACY_PREPROCESS_C),1)
RUNTIME_DRIVER_CFLAGS += -DSHUX_LEGACY_PREPROCESS_C
RUNTIME_DRIVER_NO_C_CFLAGS += -DSHUX_LEGACY_PREPROCESS_C
endif
# E-04 v32：pipeline_abi 与 driver 同源 X preprocess；LEGACY 时走 preprocess_c_fallback。
RUNTIME_PIPELINE_ABI_CFLAGS = -DSHUX_USE_X_PIPELINE
ifeq ($(SHUX_LEGACY_PREPROCESS_C),1)
RUNTIME_PIPELINE_ABI_CFLAGS += -DSHUX_LEGACY_PREPROCESS_C
endif
src/runtime_driver.o: src/runtime.c Makefile include/diag.h
	$(CC) $(CFLAGS) $(RUNTIME_DRIVER_CFLAGS) -c -o $@ $<

# G-02a: preprocess.c 已物理删除；preprocess_for_driver.o 不再编译（SHUX_LEGACY_PREPROCESS_C 路径已死）。
# shux_x 用：仅 -DSHUX_USE_X_PIPELINE，提供 asm_codegen_ast、pipeline_parse_into_buf、main_entry（弱符号）等
src/runtime_x.o: src/runtime.c include/diag.h
	$(CC) $(CFLAGS) -DSHUX_USE_X_PIPELINE -c -o $@ $<

src/driver/fmt_check_cmd.o: src/driver/fmt_check_cmd.c
	$(CC) $(CFLAGS) -c -o $@ $<

src/driver/fmt_check_cmd_driver.o: src/driver/fmt_check_cmd.c
	$(CC) $(CFLAGS) -DSHUX_USE_X_PIPELINE -c -o $@ $<

# G-02a：C 前端 lexer/ast/parser/typeck/codegen/preprocess/autovec/lsp_diag 已物理删除；见对应 .x。


# SHUX_NO_C_FRONTEND 实验链接：满足 pipeline 对 codegen_set_* 的引用，无 codegen.c

# G-02-B1：cfg_eval 仅 cfg_eval.x（无 cfg_eval.c 回退）。
# cold bootstrap 时 shux-c 默认 pipeline 可能挂起；timeout 后回退 -E-extern / stub。
src/lexer/cfg_eval.o: src/lexer/cfg_eval.x src/lexer/cfg_eval_link_alias.inc scripts/cc_inc_tu.sh
	@set -e; \
	$(MAKE) $(SHUX_C); \
	rm -f src/lexer/cfg_eval_x.o; \
	if command -v timeout >/dev/null 2>&1; then \
	  timeout "${SHUX_CFG_EVAL_ASM_TIMEOUT:-120}" ./$(SHUX_C) -o src/lexer/cfg_eval_x.o -L .. src/lexer/cfg_eval.x 2>/dev/null \
	  || rm -f src/lexer/cfg_eval_x.o; \
	else \
	  ./$(SHUX_C) -o src/lexer/cfg_eval_x.o -L .. src/lexer/cfg_eval.x 2>/dev/null \
	  || rm -f src/lexer/cfg_eval_x.o; \
	fi; \
	if [ -s src/lexer/cfg_eval_x.o ]; then \
	  sh scripts/cc_inc_tu.sh src/lexer/cfg_eval_link_alias.inc src/lexer/cfg_eval_link_alias.o; \
	  $(LD) $(LD_RELFLAGS) -r -o $@ src/lexer/cfg_eval_x.o src/lexer/cfg_eval_link_alias.o; \
	  echo "cfg_eval.o from cfg_eval.x (default pipeline + alias)"; \
	elif ./$(SHUX_C) -E -E-extern -L .. src/lexer/cfg_eval.x > src/lexer/cfg_eval_gen.c 2>/dev/null \
	  && [ -s src/lexer/cfg_eval_gen.c ]; then \
	  $(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o src/lexer/cfg_eval_x.o src/lexer/cfg_eval_gen.c; \
	  sh scripts/cc_inc_tu.sh src/lexer/cfg_eval_link_alias.inc src/lexer/cfg_eval_link_alias.o; \
	  $(LD) $(LD_RELFLAGS) -r -o $@ src/lexer/cfg_eval_x.o src/lexer/cfg_eval_link_alias.o; \
	  echo "cfg_eval.o from cfg_eval.x (-E-extern + alias)"; \
	else \
	  sh scripts/cc_inc_tu.sh src/lexer/cfg_eval_bootstrap_stub.inc src/lexer/cfg_eval_bootstrap_stub.o && \
	  cp -f src/lexer/cfg_eval_bootstrap_stub.o $@ && \
	  echo "cfg_eval.o from bootstrap stub (cfg_eval.x unavailable at cold start)"; \
	fi

# G-02a：preprocess 已迁 preprocess.x；不再编译 preprocess.c。

# runtime.c：不引用 C lexer/parser/typeck/codegen（见 SHUX_NO_C_FRONTEND 包裹的 load_one_import 等）
src/runtime_driver_no_c.o: src/runtime.c Makefile
	$(CC) $(CFLAGS) $(RUNTIME_DRIVER_NO_C_CFLAGS) -c -o $@ $<

# shux_x 使用带 -DSHUX_USE_X_PIPELINE 编译的 main，否则 #ifdef 块不会生效
src/main_x.o: src/main.c
	$(CC) $(CFLAGS) -DSHUX_USE_X_PIPELINE -c -o $@ $<

# shux_x：pipeline_x.o 编排 typeck_x/codegen_x（G-02a: typeck.c + codegen.c 已删；X pipeline 独立）。
PIPELINE_X_BASE_OBJS = src/main_x.o src/runtime_x.o src/diag.o src/lexer/lexer.o src/ast/ast_seed.o
PIPELINE_X_FRONTEND_OBJS = typeck_x.o codegen_x.o x_frontend_link_alias.o
# parser_x / seed partial / C typeck·codegen·bridge + 卫星 .o（对齐 DRIVER_SEED_OBJS 除 main_x/runtime_x 外的链接依赖）。
# fmt_check_cmd.o（非 _driver）：runtime_x 无 SHUX_USE_X_DRIVER，fmt/check 走 run_compiler_c 桩，避免缺 driver_run_compiler_full。
PIPELINE_X_SATELLITE_OBJS = lexer_x.o preprocess_x.o \
  src/driver/fmt_check_cmd.o src/driver/target_cpu.o \
  src/asm/simd_enc.o src/asm/simd_loop.o \
  src/async/async_liveness.o src/async/async_cps_codegen.o \
  src/runtime_driver_strict_glue_stubs.o
PIPELINE_X_LINK_OBJS = parser_x.o typeck_x.o codegen_x.o src/x_seed_bridge.o $(PIPELINE_X_SATELLITE_OBJS) $(USER_ASM_LINK)
PIPELINE_X_SUPPORT_OBJS = build-seed-asm-host $(PIPELINE_X_LINK_OBJS)

# shux-x-pipeline：F-03 v2/v3 std.io 纯 .x；Linux 链 -lpthread（net/thread）；无 -luring。
PIPELINE_LIBS :=
ifeq ($(UNAME_S),Linux)
  PIPELINE_LIBS := -lpthread
endif

# asm 后端 -o <exe> 时链接用：提供 shux_panic_；Linux x86_64 有 .s 时用纯 syscall .s，否则 .inc（G-02e-20）
RUNTIME_PANIC_S := $(wildcard src/asm/runtime_panic_x86_64.s)
RUNTIME_PANIC_PLATFORM_STAMP = build_asm/runtime_panic.$(UNAME_S).$(UNAME_M).stamp
$(RUNTIME_PANIC_PLATFORM_STAMP):
	@mkdir -p build_asm
	@touch $@
ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
ifneq (,$(RUNTIME_PANIC_S))
runtime_panic.o: src/asm/runtime_panic_x86_64.s $(RUNTIME_PANIC_PLATFORM_STAMP)
	$(CC) -c -o $@ $<
else
runtime_panic.o: src/asm/runtime_panic.inc $(RUNTIME_PANIC_PLATFORM_STAMP) scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_panic.inc $@
endif
else
runtime_panic.o: src/asm/runtime_panic_arm64.inc $(RUNTIME_PANIC_PLATFORM_STAMP) scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_panic_arm64.inc $@
endif
else
runtime_panic.o: src/asm/runtime_panic.inc $(RUNTIME_PANIC_PLATFORM_STAMP) scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_panic.inc $@
endif

# seed asm 用户程序：std.io 跳过 .x emit 时的 print/write/read_ptr 链接桩（G-02e-20 .inc）
runtime_asm_io_stubs.o: src/asm/runtime_asm_io_stubs.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_asm_io_stubs.inc $@ -fPIE

# F-ZC：std.test fn-ptr invoke；与 test.o 一并链入（G-02e-16：.inc + cc_inc_tu）
runtime_test_fn_invoke.o: src/asm/runtime_test_fn_invoke.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_test_fn_invoke.inc $@

# F-ZC：CSPRNG OS fill；与 random.o 一并链入（G-02e-17：.inc + cc_inc_tu）
runtime_random_fill.o: src/asm/runtime_random_fill.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_random_fill.inc $@

# zlib 宏包装桩；与 compress 同链（G-02e-17：.inc + cc_inc_tu）
runtime_compress_zlib_glue.o: src/asm/runtime_compress_zlib_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_compress_zlib_glue.inc $@

# F-ZC：time OS syscall；与 time.o 一并链入（G-02e-18：.inc + cc_inc_tu）
runtime_time_os.o: src/asm/runtime_time_os.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_time_os.inc $@

# F-ZC：queue 竞争烟测 pthread；与 queue.o 一并链入（G-02e-19：.inc + cc_inc_tu）
runtime_queue_contention.o: src/asm/runtime_queue_contention.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_queue_contention.inc $@

# F-ZC：dynlib dlopen/LoadLibrary；与 dynlib.o 一并链入（G-02e-19：.inc + cc_inc_tu）
runtime_dynlib_os.o: src/asm/runtime_dynlib_os.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_dynlib_os.inc $@

# F-ZC：env OS getenv/setenv/iter；与 env.o 一并链入（G-02e-19：.inc + cc_inc_tu）
runtime_env_os.o: src/asm/runtime_env_os.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_env_os.inc $@

# F-ZC：backtrace capture/symbolicate/crash evidence；与 backtrace.o 一并链入（G-02e-20）
runtime_backtrace_platform.o: src/asm/runtime_backtrace_platform.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_backtrace_platform.inc $@

# F-ZC：log sink/轮转/异步；与 log.o 一并链入（G-02e-19：.inc + cc_inc_tu）
runtime_log_os.o: src/asm/runtime_log_os.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_log_os.inc $@

# F-ZC：math libm/fenv；与 math.o 一并链入（须 -lm；G-02e-19：.inc + cc_inc_tu）
runtime_math_libm.o: src/asm/runtime_math_libm.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_math_libm.inc $@

# F-ZC：atomic load/store/CAS/fence；与 atomic.o 一并链入（G-02e-19：.inc + cc_inc_tu）
runtime_atomic_glue.o: src/asm/runtime_atomic_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_atomic_glue.inc $@

# F-ZC：channel 有界/无界/select；与 channel.o 一并链入（G-02e-20：.inc + cc_inc_tu）
runtime_channel_glue.o: src/asm/runtime_channel_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_channel_glue.inc $@

# F-ZC：net UDP batch recvmmsg/sendmmsg；与 net.o 一并链入（G-02e-19：.inc + cc_inc_tu）
runtime_net_udp_batch.o: src/asm/runtime_net_udp_batch.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_net_udp_batch.inc $@

# F-ZC：net accept worker 线程入口；与 net.o 一并链入（G-02e-18：.inc + cc_inc_tu）
runtime_net_workers.o: src/asm/runtime_net_workers.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_net_workers.inc $@

# F-ZC：sync Mutex/RwLock/Condvar + 锁诊断 TLS；与 sync.o 一并链入（G-02e-20）
runtime_sync_os.o: src/asm/runtime_sync_os.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_sync_os.inc $@

runtime_sync_lock_diag_tls.o: src/asm/runtime_sync_lock_diag_tls.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_sync_lock_diag_tls.inc $@

# F-ZC：thread pthread/CreateThread；与 thread.o 一并链入（G-02e-20）
runtime_thread_glue.o: src/asm/runtime_thread_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_thread_glue.inc $@

# F-ZC：async 协作调度 + async_net_fs；与 scheduler.o 一并链入（按需 -pthread）
runtime_scheduler_glue.o: src/asm/runtime_scheduler_glue.inc src/asm/async_net_fs.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_scheduler_glue.inc $@ -Isrc/asm

# F-ZC：HTTP 客户端/服务端胶层（含 http2/*.inc.c）；与 http.o 一并链入（G-02e-21）
runtime_http_glue.o: src/asm/http/runtime_http_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/http/runtime_http_glue.inc $@ -Isrc/asm/http

# F-ZC：mbedTLS BIO 胶层；net-o-mbedtls 时 ld -r 并入 tls_mbedtls.o（G-02e-18 .inc）
runtime_tls_mbedtls_bio.o: src/asm/runtime_tls_mbedtls_bio.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_tls_mbedtls_bio.inc $@ -I/opt/homebrew/opt/mbedtls/include 2>/dev/null \
	  || sh scripts/cc_inc_tu.sh src/asm/runtime_tls_mbedtls_bio.inc $@

# F-ZC：db.kv mmap 胶层；与 kv.o 按需同链（G-02e-17：.inc + cc_inc_tu）
runtime_kv_mmap_glue.o: src/asm/runtime_kv_mmap_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_kv_mmap_glue.inc $@

# F-ZC：db.arrow SIMD 胶层；与 arrow.o 按需同链（G-02e-19：.inc + cc_inc_tu）
runtime_arrow_simd_glue.o: src/asm/runtime_arrow_simd_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_arrow_simd_glue.inc $@

# F-ZC：db.sqlite 胶层（libsqlite3）；与 sqlite.o 同链（G-02e-20）
runtime_sqlite_glue.o: src/asm/runtime_sqlite_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_sqlite_glue.inc $@ -DSHUX_DB_USE_SQLITE3

# F-ZC：db.sqlite stub 胶层（无 libsqlite3）；sqlite-o-stub 时 ld -r 并入 sqlite.o（G-02e-20）
runtime_sqlite_glue_stub.o: src/asm/runtime_sqlite_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_sqlite_glue.inc $@

# F-ZC：crypto SHA-512/HMAC 胶层；与 crypto.o 一并链入（G-02e-20）
runtime_crypto_inc_glue.o: src/asm/runtime_crypto_inc_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_crypto_inc_glue.inc $@

# F-ZC：Ed25519 ref10（含 crypto/ed25519/*.c）；与 crypto.o 一并链入（G-02e-17 .inc）
runtime_ed25519_ref10_glue.o: src/asm/runtime_ed25519_ref10_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_ed25519_ref10_glue.inc $@ -Isrc/asm

# F-ZC：codegen 入口 argc/argv 全局；与 process.o 一并链入（G-02e-18：.inc + cc_inc_tu）
runtime_process_argv.o: src/asm/runtime_process_argv.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_process_argv.inc $@

# F-ZC：进程 OS 胶层（getenv/spawn/getcwd 等）；与 process.o 一并链入（G-02e-20）
runtime_process_os_glue.o: src/asm/runtime_process_os_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_process_os_glue.inc $@

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
src/asm/bootstrap_nostdlib_stubs.o: src/asm/bootstrap_nostdlib_stubs.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/bootstrap_nostdlib_stubs.inc $@
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

# asm 链接无 runtime_driver 时：提供 typeck_float64_bits_lo/hi（G-02e：全平台 .s，零 C）。
ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
src/typeck/typeck_f64_bits.o: src/typeck/typeck_f64_bits_x86_64.s
	$(CC) -c -o $@ $<
else ifeq ($(UNAME_M),aarch64)
src/typeck/typeck_f64_bits.o: src/typeck/typeck_f64_bits_aarch64_elf.s
	$(CC) -c -o $@ $<
else
$(error typeck_f64_bits: unsupported Linux arch $(UNAME_M); add .s)
endif
else ifeq ($(UNAME_S),Darwin)
ifeq ($(UNAME_M),arm64)
src/typeck/typeck_f64_bits.o: src/typeck/typeck_f64_bits_arm64.s
	$(CC) -c -o $@ $<
else ifeq ($(UNAME_M),x86_64)
# Darwin x86_64：SysV .s 无 _ 前缀；clang 汇编 Mach-O 时需额外处理，当前主路径为 arm64。
src/typeck/typeck_f64_bits.o: src/typeck/typeck_f64_bits_x86_64.s
	$(CC) -c -o $@ $<
else
$(error typeck_f64_bits: unsupported Darwin arch $(UNAME_M); add .s)
endif
else
$(error typeck_f64_bits: unsupported OS $(UNAME_S); add .s)
endif

clean:
	rm -f $(OBJS) src/main_driver.o src/runtime_driver.o src/runtime_driver_no_c.o src/runtime_x.o src/main_x.o src/ast/ast_seed.o src/preprocess_for_driver.o ../std/process/process.o ../std/string/string.o ../std/runtime/runtime.o ../std/net/net.o ../std/thread/thread.o ../std/time/time.o ../std/random/random.o ../std/env/env.o ../std/sync/sync.o ../std/encoding/encoding.o ../std/base64/base64.o ../std/crypto/crypto.o ../std/log/log.o ../std/atomic/atomic.o ../std/channel/channel.o ../std/backtrace/backtrace.o ../std/hash/hash.o ../std/math/math.o ../std/sort/sort.o ../std/ffi/ffi.o ../std/json/json.o ../std/csv/csv.o ../std/regex/regex.o ../std/compress/compress.o ../std/unicode/unicode.o ../std/dynlib/dynlib.o ../std/http/http.o ../std/tar/tar.o ../std/test/test.o src/asm/runtime_asm_build.o src/asm/crt0_x86_64.o src/typeck/typeck_f64_bits.o src/lsp/lsp_diag_pipeline_sizes.o lsp_io_x.o lsp_x.o lsp_diag_x.o lsp_io_std_heap_x.o lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c $(TARGET) shux-x shux-no-c-frontend $(SHUX_C) $(TARGET)_stage1 $(TARGET)_stage2 $(TARGET)_x $(TARGET)_x_stage2 typeck_gen.c typeck_x.o codegen_gen.c codegen_x.o parser_gen.c parser_x.o driver_gen.c driver_x.o driver_fmt_gen.c driver_check_gen.c driver_test_gen.c driver_fmt_x.o driver_check_x.o driver_test_x.o pipeline_gen.c pipeline_x.o typeck_x_x.c typeck_x_x.o codegen_x_x.c codegen_x_x.o build_gen.c build_runner_gen.c build_runtime_x_gen.c build_tool.o build_runner.o build_runtime.o build_runtime_x.o build_tool runtime_panic.o shux_asm preprocess_gen.c preprocess_x.o
	rm -rf build_asm build build_final build_manual build_v5 build_v7
	rm -f bootstrap_shux shux_asm2 shux_x_dbg shux_stage1_test a.out
	rm -f .lldb_* *.bak pipeline_gen.c.bak lsp_gen.c.bak
	rm -f 0 2>/dev/null || true
	@for f in _*; do \
	  case "$$f" in _stubs.c|_x_stubs.inc|_x_stubs2.c) ;; *) rm -rf "$$f" ;; esac; \
	done 2>/dev/null || true
	find . -name '*.o' -delete 2>/dev/null || true
	find . -name '*.o.tmp' -delete 2>/dev/null || true
	rm -f test_perl.txt test_pre_out.s 2>/dev/null || true
	rm -f ../rvwbuf.tmp 2>/dev/null || true
	find . -name '*.x.bak' -delete 2>/dev/null || true
	rm -rf tmp_bisect 2>/dev/null || true
	rm -f tmp_* 2>/dev/null || true

# 阶段 1 词法 + 阶段 3 类型检查 + …；依赖 shux 与全部 std .o、runtime_panic.o，clean 后 test 会先构建再跑脚本
# test_c：与 ../tests/run-all-c.sh 等价（C 版 shux-c 跑整份 run-all，不含自举专用脚本）
# test_x：bootstrap-driver-seed + run-lsp + run-all-x（.x 流水线全量）
# 依赖 $(SHUX_C) 以便 make clean && make test_c 时 shux-c 存在
test_c: $(TARGET) $(SHUX_C) $(STD_AND_PANIC_O)
	@if [ -f ../tests/run-all-c.sh ]; then (cd .. && chmod +x tests/run-all-c.sh && ./tests/run-all-c.sh); else echo "tests/run-all-c.sh missing" >&2; exit 1; fi
	@echo "Test C OK"

# x 自举：bootstrap-driver-seed + LSP + 全量自举（run-all-x：用 shux_x 跑整份 run-all）
test_x: bootstrap-driver-seed
	@if [ -f ../tests/run-lsp.sh ]; then (cd .. && chmod +x tests/run-lsp.sh && ./tests/run-lsp.sh); fi
	@if [ -f ../tests/run-all-x.sh ]; then (cd .. && chmod +x tests/run-all-x.sh && ./tests/run-all-x.sh); fi
	@echo "Test X OK"

# 全量：先 C 再 x 自举
test: test_c test_x
	@echo "Test all OK"

# 自举 9.1：用 shux 编译 token 模块（库）+ token_standalone.x（入口），验证 .x 前端数据定义可由宿主编译
# 依赖 $(STD_AND_PANIC_O)：-o 链 std/io 等 .o，clean 后仅 make $(TARGET) 会缺这些文件导致 cc 失败。
bootstrap-token: $(TARGET) $(STD_AND_PANIC_O)
	./$(TARGET) -L src/lexer src/lexer/token_standalone.x -o /tmp/shux_token_test && /tmp/shux_token_test && echo "bootstrap-token OK"

# 自举 9.1：用 shux 编译 lexer.x（入口，import token），验证多文件 + 跨模块 enum 可编译链接
bootstrap-lexer: $(TARGET) $(STD_AND_PANIC_O)
	./$(TARGET) -L src/lexer src/lexer/lexer.x -o /tmp/shux_lexer_test && /tmp/shux_lexer_test && echo "bootstrap-lexer OK"

# 自举 9.1：用 shux 编译 parser.x（import lexer + token + ast + std.fs），解析 function main(): i32 { return 0; } 并验证；-L .. 供 std.fs，-L src/lexer 供 token，-L src/ast 供 ast
bootstrap-parser: relink-shux $(STD_AND_PANIC_O)
	rm -f /tmp/shux_parse_test.x && ./$(TARGET) -L .. -L src/lexer -L src/ast src/parser/parser.x -o /tmp/shux_parser_test && /tmp/shux_parser_test && echo "bootstrap-parser OK"

# 9.1 联调：.x `parse()` 支持 return 字面量或 `parse_expr_into`（堆上大块 Arena，栈安全）；宿主 shux 走完整流水线。
# 第二段：`return (1 + 2) * 3 + -1`，.x standalone 走 parse()→堆上 Arena→parse_expr_into；宿主 shux 走完整流水线。
bootstrap-parse-file: $(TARGET) $(STD_AND_PANIC_O) bootstrap-parser
	@printf 'function main(): i32 { return 0; }\0' > /tmp/shux_parse_test.x && \
	/tmp/shux_parser_test && echo "x parser: parse OK (minimal)" && \
	(out=$$(./$(TARGET) -L .. /tmp/shux_parse_test.x 2>&1); echo "$$out" | grep -q "parse OK") && echo "C parser: parse OK (minimal)" && \
	printf 'function main(): i32 { return (1 + 2) * 3 + -1; }\0' > /tmp/shux_parse_test.x && \
	/tmp/shux_parser_test && echo "x parser: parse OK (expr-chain)" && \
	(out=$$(./$(TARGET) -L .. /tmp/shux_parse_test.x 2>&1); echo "$$out" | grep -q "parse OK") && echo "C parser: parse OK (expr-chain)" && \
	echo "bootstrap-parse-file OK"

# 迁移到 .x：parser.x -E-extern + ast 池 getter 补丁 → parser_x.o（提供 parser_parse_into_buf；与瘦 pipeline_x.o 分 TU）。
# 须 shux-x -x -E 全量 TU；shux-c 瘦 gen 缺 copy_module_import_path64 / parse_expr_into 等。
parser_gen.c: ast_gen2.c src/parser/parser.x
	@if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  tmp="$@.tmp"; \
	  if [ -f $(SHUX_X) ]; then \
	  echo "parser_gen.c: ./$(SHUX_X) -x -E -E-extern ... [forced regen]" >&2; \
	  if ./$(SHUX_X) -x -E -L .. -L src/lexer -L src/ast -E-extern src/parser/parser.x > "$$tmp" 2>/dev/null \
	  && grep -q 'parser_copy_module_import_path64' "$$tmp"; then \
	  mv -f "$$tmp" $@; \
	  else \
	  rm -f "$$tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.x > "$$tmp" && mv -f "$$tmp" $@; \
	  fi; \
	  else \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.x > "$$tmp" && mv -f "$$tmp" $@; \
	  fi; \
	elif [ -s parser_gen.c ]; then \
	  echo "parser_gen.c: pinned ($$(wc -c < parser_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/parser_gen.linux.x86_64.c ] && [ ! -s parser_gen.c ]; then \
	  cp -f seeds/parser_gen.linux.x86_64.c parser_gen.c; \
	  echo "parser_gen.c: restored from seeds/parser_gen.linux.x86_64.c"; \
	else \
	  tmp="$@.tmp"; \
	  if [ -f $(SHUX_X) ]; then \
	  echo "parser_gen.c: ./$(SHUX_X) -x -E -E-extern ..." >&2; \
	  if ./$(SHUX_X) -x -E -L .. -L src/lexer -L src/ast -E-extern src/parser/parser.x > "$$tmp" 2>/dev/null \
	  && grep -q 'parser_copy_module_import_path64' "$$tmp"; then \
	  mv -f "$$tmp" $@; \
	  else \
	  echo "parser_gen.c: shux-x failed or thin output; fallback shux-c" >&2; \
	  rm -f "$$tmp" 2>/dev/null || true; \
	  if $(MAKE) $(SHUX_C) >/dev/null \
	  && ./$(SHUX_C) -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.x > "$$tmp" 2>/dev/null \
	  && [ -s "$$tmp" ] && grep -q 'parser_copy_module_import_path64' "$$tmp"; then \
	  mv -f "$$tmp" $@; \
	  elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/parser_gen.linux.x86_64.c ]; then \
	  cp -f seeds/parser_gen.linux.x86_64.c $@; \
	  echo "parser_gen.c: fallback seeds/parser_gen.linux.x86_64.c (shux-c -E failed)" >&2; \
	  else \
	  rm -f "$$tmp" 2>/dev/null || true; \
	  echo "parser_gen.c: FAIL (no shux-x/shux-c -E and no seed)" >&2; exit 1; \
	  fi; \
	  fi; \
	  else \
	  if $(MAKE) $(SHUX_C) >/dev/null \
	  && ./$(SHUX_C) -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.x > "$$tmp" 2>/dev/null \
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
	  echo "parser_gen.c: inject extern parser_copy_module_import_path64 (parser_asm_parse_expr_link/thin_c)" >&2; \
	  printf '%s\n' '/* pipeline extern parser_copy_module_import_path64 (thin parser_gen TU) */' \
	  'extern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t out[64]);' >> $@; \
	fi
	@echo "parser_gen.c: normalize ast_pipeline onefunc const extern aliases" >&2; \
	perl -0pi -e 's@^extern int32_t ast_pipeline_onefunc_append_const\(.*\);\n@@mg; s@^extern int32_t ast_pipeline_onefunc_const_init_ref\(.*\);\n@@mg; s@^extern int32_t ast_pipeline_onefunc_const_type_ref\(.*\);\n@@mg; s@/\* C-04 -E-extern TU aliases \*/\n@extern int32_t ast_pipeline_onefunc_append_const(uint8_t * restrict out, uint8_t * restrict name, int32_t name_len, int32_t init_val, int32_t init_ref, int32_t type_ref);\nextern int32_t ast_pipeline_onefunc_const_init_ref(uint8_t * restrict out, int32_t i);\nextern int32_t ast_pipeline_onefunc_const_type_ref(uint8_t * restrict out, int32_t i);\n/* C-04 -E-extern TU aliases */\n@s' $@
	@echo "parser_gen.c: from parser.x (-E-extern, full TU via shux-x -x)"
parser_x.o: parser_gen.c
	@perl scripts/sync_lexer_gen_token_enum.pl parser_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -Dstd_io_driver_driver_read_ptr_len=shux_io_read_ptr_len -Dstd_io_driver_driver_read_ptr=shux_io_read_ptr -c parser_gen.c -o parser_x.o
	@echo "parser_x.o OK"

# lexer.x：须 shux-x -x -E 走 C parser/codegen 全量 TU；shux-c 无 -x 时仅 ~57 行缺 advance_one/next_body。
lexer_gen.c: src/lexer/lexer.x
	@if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  tmp="$@.tmp"; \
	  if [ -f $(SHUX_X) ]; then \
	  echo "lexer_gen.c: ./$(SHUX_X) -x -E -E-extern ... [forced regen]" >&2; \
	  if ./$(SHUX_X) -x -E -L src/lexer -E-extern src/lexer/lexer.x > "$$tmp" 2>/dev/null \
	  && grep -q 'lexer_advance_one' "$$tmp"; then \
	  mv -f "$$tmp" $@; \
	  else \
	  rm -f "$$tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L src/lexer -E -E-extern src/lexer/lexer.x > "$$tmp" && mv -f "$$tmp" $@; \
	  fi; \
	  else \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L src/lexer -E -E-extern src/lexer/lexer.x > "$$tmp" && mv -f "$$tmp" $@; \
	  fi; \
	elif [ -s lexer_gen.c ]; then \
	  echo "lexer_gen.c: pinned ($$(wc -c < lexer_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/lexer_gen.linux.x86_64.c ] && [ ! -s lexer_gen.c ]; then \
	  cp -f seeds/lexer_gen.linux.x86_64.c lexer_gen.c; \
	  echo "lexer_gen.c: restored from seeds/lexer_gen.linux.x86_64.c"; \
	else \
	  tmp="$@.tmp"; \
	  if [ -f $(SHUX_X) ]; then \
	  echo "lexer_gen.c: ./$(SHUX_X) -x -E -E-extern ..." >&2; \
	  if ./$(SHUX_X) -x -E -L src/lexer -E-extern src/lexer/lexer.x > "$$tmp" 2>/dev/null \
	  && grep -q 'lexer_advance_one' "$$tmp"; then \
	  mv -f "$$tmp" $@; \
	  else \
	  echo "lexer_gen.c: shux-x failed or thin output; fallback shux-c" >&2; \
	  rm -f "$$tmp" 2>/dev/null || true; \
	  if $(MAKE) $(SHUX_C) >/dev/null \
	  && ./$(SHUX_C) -L src/lexer -E -E-extern src/lexer/lexer.x > "$$tmp" 2>/dev/null \
	  && [ -s "$$tmp" ] && grep -q 'lexer_advance_one' "$$tmp"; then \
	  mv -f "$$tmp" $@; \
	  elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/lexer_gen.linux.x86_64.c ]; then \
	  cp -f seeds/lexer_gen.linux.x86_64.c $@; \
	  echo "lexer_gen.c: fallback seeds/lexer_gen.linux.x86_64.c (shux-c -E failed)" >&2; \
	  else \
	  rm -f "$$tmp" 2>/dev/null || true; \
	  echo "lexer_gen.c: FAIL (no shux-x/shux-c -E and no seed)" >&2; exit 1; \
	  fi; \
	  fi; \
	  else \
	  if $(MAKE) $(SHUX_C) >/dev/null \
	  && ./$(SHUX_C) -L src/lexer -E -E-extern src/lexer/lexer.x > "$$tmp" 2>/dev/null \
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
	@grep -q 'lexer_advance_one' $@ || (echo "lexer_gen.c: missing lexer_advance_one (need shux-x -x -E)" >&2; exit 1)
	@echo "lexer_gen.c: from lexer.x (-E-extern, full TU via shux-x -x)"

lexer_x.o: lexer_gen.c
	@perl scripts/sync_lexer_gen_token_enum.pl lexer_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c lexer_gen.c -o lexer_x.o
	@echo "lexer_x.o OK"

src/x_seed_bridge.o: src/x_seed_bridge.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# pipeline_x.o 仍引用 typeck_typeck_* / codegen_codegen_* / lexer_lexer_*；*_x.o 导出无重复前缀名。
# G-02e-8：原 lexer/typeck/codegen_x_link_alias 三 TU 并入 x_frontend_link_alias.c。
x_frontend_link_alias.o: x_frontend_link_alias.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<
# seed shux 用户程序 -backend asm：shux-c -E 编出的 backend/peephole/platform + user_asm_seed_bridge（无 weak 桩、无 C 回退）
USER_ASM_SEED_HOST_DIR = build_asm/seed_host
USER_ASM_SEED_HOST_OBJS = $(USER_ASM_SEED_HOST_DIR)/asm_backend_partial.o
USER_ASM_SEED_HOST_STUBS = $(USER_ASM_SEED_HOST_DIR)/asm_full_link_stubs.o
USER_ASM_SEED_OBJS = src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o
USER_ASM_LINK = $(USER_ASM_SEED_HOST_OBJS) $(USER_ASM_SEED_HOST_STUBS) $(USER_ASM_SEED_OBJS)
ifeq ($(UNAME_S),Darwin)
BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O = build_asm/bootstrap_seed_pipeline_filtered.o
BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS = build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o
BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS = $(BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O) $(BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS)
SHUX_X_PIPELINE_LINK_O = $(BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O)
SHUX_X_USER_ASM_OBJS = $(BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS)
RELINK_SHUX_PIPELINE_LINK_O = $(BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O)
RELINK_SHUX_USER_ASM_LINK = $(USER_ASM_SEED_HOST_OBJS) $(USER_ASM_SEED_HOST_STUBS) $(BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS)
RELINK_SHUX_FILTERED_OBJS = $(BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS)
else
BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O = pipeline_x.o
BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS = $(USER_ASM_SEED_OBJS)
BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS =
SHUX_X_PIPELINE_LINK_O = pipeline_x.o
SHUX_X_USER_ASM_OBJS = $(USER_ASM_SEED_OBJS)
RELINK_SHUX_PIPELINE_LINK_O = pipeline_x.o
RELINK_SHUX_USER_ASM_LINK = $(USER_ASM_LINK)
RELINK_SHUX_FILTERED_OBJS =
endif

.PHONY: build-seed-asm-host
# partial export 须先 nm dispatch .o 剔除重复符号；冷启动时 dispatch 可能尚未编译。
.PHONY: parser-legacy-text-o
parser-legacy-text-o:
	@chmod +x scripts/extract_parser_legacy_text.sh 2>/dev/null || true
	@./scripts/extract_parser_legacy_text.sh

build-seed-asm-host: src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o
	@chmod +x scripts/build_seed_asm_host.sh 2>/dev/null || true
	@./scripts/build_seed_asm_host.sh

$(USER_ASM_SEED_HOST_STUBS): pipeline_x.o $(ASM_GLUE_STANDALONE_O) $(USER_ASM_SEED_OBJS) scripts/gen_asm_full_link_stubs.pl
	@mkdir -p $(USER_ASM_SEED_HOST_DIR)
	@_scan="pipeline_x.o $(ASM_GLUE_STANDALONE_O) $(USER_ASM_SEED_OBJS)"; \
	  [ -f $(USER_ASM_SEED_HOST_DIR)/asm_full.o ] && _scan="$(USER_ASM_SEED_HOST_DIR)/asm_full.o $$_scan"; \
	  [ -f $(USER_ASM_SEED_HOST_DIR)/asm_backend_partial.o ] && _scan="$(USER_ASM_SEED_HOST_DIR)/asm_backend_partial.o $$_scan"; \
	  perl scripts/gen_asm_full_link_stubs.pl $(USER_ASM_SEED_HOST_DIR)/asm_full_link_stubs.c $$_scan && \
	  $(CC) $(CFLAGS) -c -o $@ $(USER_ASM_SEED_HOST_DIR)/asm_full_link_stubs.c

$(USER_ASM_SEED_HOST_OBJS): build-seed-asm-host

src/asm/user_asm_seed_bridge.o: src/asm/user_asm_seed_bridge.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/user_asm_seed_bridge.inc $@

src/asm/asm_backend_compat_stubs.o: src/asm/asm_backend_compat_stubs.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/asm_backend_compat_stubs.inc $@

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

# parser EMIT_HEAVY thin delegate C 目标：bootstrap shux 须链入，extern bl 白名单 emit 才不 segfault。
# 全量 parser_x.o 已含 parse_into_buf / get_module_* 等；禁 seed slice 与重复前缀符号。
PARSER_ASM_THIN_GLUE_CFLAGS = -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE
PARSER_ASM_LINK_ALIAS_CFLAGS = -DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS
parser_asm_thin_glue.o: src/asm/parser_asm_thin_c.c \
 src/asm/parser_asm_type_ref_slice.inc \
 src/asm/parser_asm_struct_layout_slice.inc \
 src/asm/parser_asm_library_slice.inc \
 src/asm/parser_asm_body_let_slice.inc \
 src/asm/parser_asm_top_level_let_slice.inc \
 src/asm/parser_asm_type_alias_slice.inc \
 src/asm/parser_asm_one_function_buf_slice.inc \
 src/asm/parser_asm_block_from_res_slice.inc \
 src/asm/parser_asm_if_stmt_slice.inc \
 src/asm/parser_asm_match_subject_slice.inc \
 src/asm/parser_asm_simd_builtin_slice.inc \
 src/asm/parser_asm_if_expr_slice.inc \
 src/asm/parser_asm_finish_struct_lit_slice.inc \
 src/asm/parser_asm_as_suffix_slice.inc \
 src/asm/parser_asm_primary_slice.inc \
 src/asm/parser_asm_unary_slice.inc \
 src/asm/parser_asm_expr_binop_slice.inc \
 src/asm/parser_asm_ternary_assign_slice.inc \
 src/asm/parser_asm_emit_heavy_stretch_slice.inc \
 src/asm/parser_asm_emit_heavy_stretch_suite_slice.inc \
 src/asm/parser_asm_seed_parse_into_buf_slice.inc
	$(CC) $(CFLAGS) $(PARSER_ASM_THIN_GLUE_CFLAGS) -I. -Iinclude -Isrc -Isrc/lexer -c -o $@ src/asm/parser_asm_thin_c.c

# parse_expr_into 桥 + pipeline 弱 parse 桩 / 可选 parser_* 别名（G-02e-7 并入 link_alias）。
src/asm/parser_asm_parse_expr_link.o: src/asm/parser_asm_parse_expr_link.c
	$(CC) $(CFLAGS) $(PARSER_ASM_LINK_ALIAS_CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o: src/asm/backend_x86_64_enc_c.o build_asm/seed_host/asm_backend_partial.o
	@mkdir -p build_asm
	@src_syms=build_asm/bootstrap_seed_backend_x86_64_enc_c.syms; \
	  part_syms=build_asm/bootstrap_seed_backend_partial.syms; \
	  keep_syms=build_asm/bootstrap_seed_backend_x86_64_enc_c.keep; \
	  nm src/asm/backend_x86_64_enc_c.o 2>/dev/null | awk '/ [TDS] / { s=$$3; sub(/^_/, "", s); print s }' | sort -u > "$$src_syms"; \
	  nm build_asm/seed_host/asm_backend_partial.o 2>/dev/null | awk '/ [TDS] / { s=$$3; sub(/^_/, "", s); print s }' | sort -u > "$$part_syms"; \
	  comm -23 "$$src_syms" "$$part_syms" | sed 's/^/_/' > "$$keep_syms"; \
	  ld -r -exported_symbols_list "$$keep_syms" -o $@ src/asm/backend_x86_64_enc_c.o

build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o: src/asm/user_asm_seed_bridge.o build_asm/seed_host/asm_backend_partial.o
	@mkdir -p build_asm
	@src_syms=build_asm/bootstrap_seed_user_asm_seed_bridge.syms; \
	  part_syms=build_asm/bootstrap_seed_backend_partial.syms; \
	  keep_syms=build_asm/bootstrap_seed_user_asm_seed_bridge.keep; \
	  nm src/asm/user_asm_seed_bridge.o 2>/dev/null | awk '/ [TDS] / { s=$$3; sub(/^_/, "", s); print s }' | sort -u > "$$src_syms"; \
	  nm build_asm/seed_host/asm_backend_partial.o 2>/dev/null | awk '/ [TDS] / { s=$$3; sub(/^_/, "", s); print s }' | sort -u > "$$part_syms"; \
	  comm -23 "$$src_syms" "$$part_syms" | sed 's/^/_/' > "$$keep_syms"; \
	  ld -r -exported_symbols_list "$$keep_syms" -o $@ src/asm/user_asm_seed_bridge.o

build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o: src/asm/asm_backend_compat_stubs.o build_asm/seed_host/asm_backend_partial.o
	@mkdir -p build_asm
	@src_syms=build_asm/bootstrap_seed_asm_backend_compat_stubs.syms; \
	  part_syms=build_asm/bootstrap_seed_backend_partial.syms; \
	  keep_syms=build_asm/bootstrap_seed_asm_backend_compat_stubs.keep; \
	  nm src/asm/asm_backend_compat_stubs.o 2>/dev/null | awk '/ [TDS] / { s=$$3; sub(/^_/, "", s); print s }' | sort -u > "$$src_syms"; \
	  nm build_asm/seed_host/asm_backend_partial.o 2>/dev/null | awk '/ [TDS] / { s=$$3; sub(/^_/, "", s); print s }' | sort -u > "$$part_syms"; \
	  comm -23 "$$src_syms" "$$part_syms" | sed 's/^/_/' > "$$keep_syms"; \
	  ld -r -exported_symbols_list "$$keep_syms" -o $@ src/asm/asm_backend_compat_stubs.o

build_asm/bootstrap_seed_pipeline_filtered.o: pipeline_x.o build_asm/seed_host/asm_backend_partial.o build_asm/pipeline_glue_strict_minimal.o
	@mkdir -p build_asm
	@all_syms=build_asm/bootstrap_seed_pipeline.syms; \
	  keep_syms=build_asm/bootstrap_seed_pipeline.keep; \
	  omit_syms=build_asm/bootstrap_seed_pipeline.omit; \
	  : > "$$omit_syms"; \
	  nm pipeline_x.o 2>/dev/null | awk '/ [TDS] / { s=$$3; sub(/^_/, "", s); print s }' | sort -u > "$$all_syms"; \
	  for dep_o in typeck_x.o codegen_x.o build_asm/seed_host/asm_backend_partial.o build_asm/pipeline_glue_strict_minimal.o; do \
	  if [ -f "$$dep_o" ]; then \
	  nm "$$dep_o" 2>/dev/null | awk '/ [TDS] / { s=$$3; sub(/^_/, "", s); print s }' >> "$$omit_syms"; \
	  fi; \
	  done; \
	  sort -u "$$omit_syms" -o "$$omit_syms"; \
	  comm -23 "$$all_syms" "$$omit_syms" | sed 's/^/_/' > "$$keep_syms"; \
	  ld -r -exported_symbols_list "$$keep_syms" -o $@ pipeline_x.o

src/asm/asm_experimental_symbol_bridge.o: src/asm/asm_experimental_symbol_bridge.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/asm_experimental_symbol_bridge.inc $@

# 迁移到 .x：parser/typeck/codegen 独立 -E-extern 产物；pipeline_x.o 仅编排（-E-extern），seed 链 typeck_x.o/codegen_x.o。
migrate-x-objs: parser_x.o typeck_x.o codegen_x.o
	@echo "migrate-x-objs OK (parser_x.o typeck_x.o codegen_x.o 已就绪)"

# ast_gen2.c：fix_slim_arena_gen_c.pl 注入 ast_ast_* 原型（typeck/codegen 单文件编译依赖）
ast_gen2.c: src/ast/ast.x
	@if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L src/ast -E -E-extern src/ast/ast.x > "$$tmp" && mv -f "$$tmp" $@; \
	  perl scripts/fix_slim_arena_gen_c.pl $@; \
	elif [ -s ast_gen2.c ]; then \
	  echo "ast_gen2.c: pinned ($$(wc -c < ast_gen2.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L src/ast -E -E-extern src/ast/ast.x > "$$tmp" && mv -f "$$tmp" $@; \
	  perl scripts/fix_slim_arena_gen_c.pl $@; \
	fi

ast_gen2.o: ast_gen2.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c ast_gen2.c -o ast_gen2.o

typeck_gen.c: ast_gen2.c src/typeck/typeck.x
	@if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  tmp="$@.tmp.$$$$"; rm -f "$$tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser src/typeck/typeck.x -E-extern > "$$tmp" && mv "$$tmp" $@; \
	elif [ -s typeck_gen.c ]; then \
	  echo "typeck_gen.c: pinned ($$(wc -c < typeck_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/typeck_gen.linux.x86_64.c ] && [ ! -s typeck_gen.c ]; then \
	  cp -f seeds/typeck_gen.linux.x86_64.c typeck_gen.c; \
	  echo "typeck_gen.c: restored from seeds/typeck_gen.linux.x86_64.c"; \
	else \
	  tmp="$@.tmp.$$$$"; rm -f "$$tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser src/typeck/typeck.x -E-extern > "$$tmp" && mv "$$tmp" $@ || \
	  { rm -f "$$tmp"; if [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/typeck_gen.linux.x86_64.c ]; then cp -f seeds/typeck_gen.linux.x86_64.c $@ && echo "typeck_gen.c: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	fi
	perl scripts/fix_slim_arena_gen_c.pl $@

typeck_x.o: typeck_gen.c
	@python3 scripts/patch_typeck_gen_lang007.py
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c typeck_gen.c -o typeck_x.o
	@test $$(stat -f%z typeck_x.o 2>/dev/null || stat -c%s typeck_x.o) -gt 10000 || (echo "typeck_x.o too small (corrupt gen? rm typeck_gen.c && make typeck_gen.c typeck_x.o)" >&2; exit 1)

codegen_gen.c: ast_gen2.c src/codegen/codegen.x
	@if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  tmp="$@.tmp.$$$$"; rm -f "$$tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck src/codegen/codegen.x -E-extern > "$$tmp" && mv "$$tmp" $@; \
	elif [ -s codegen_gen.c ]; then \
	  echo "codegen_gen.c: pinned ($$(wc -c < codegen_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/codegen_gen.linux.x86_64.c ] && [ ! -s codegen_gen.c ]; then \
	  cp -f seeds/codegen_gen.linux.x86_64.c codegen_gen.c; \
	  echo "codegen_gen.c: restored from seeds/codegen_gen.linux.x86_64.c"; \
	else \
	  tmp="$@.tmp.$$$$"; rm -f "$$tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck src/codegen/codegen.x -E-extern > "$$tmp" && mv "$$tmp" $@ || \
	  { rm -f "$$tmp"; if [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/codegen_gen.linux.x86_64.c ]; then cp -f seeds/codegen_gen.linux.x86_64.c $@ && echo "codegen_gen.c: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	fi
	perl scripts/fix_slim_arena_gen_c.pl $@

codegen_x.o: codegen_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c codegen_gen.c -o codegen_x.o
	@test $$(stat -f%z codegen_x.o 2>/dev/null || stat -c%s codegen_x.o) -gt 50000 || (echo "codegen_x.o too small (corrupt gen? rm codegen_gen.c && make codegen_gen.c codegen_x.o)" >&2; exit 1)

# 6.1：.x typeck 入口与 C AST 对接；用 C-only shux 编译 typeck.x 生成 typeck_gen.c，再链接进 shux，使 typeck 由 .x 入口转调 C
bootstrap-typeck: $(TARGET) $(SHUX_C) bootstrap_shuxc $(RELINK_SHUX_PREREQS)
	@tmp=typeck_gen.c.tmp.$$$$; rm -f "$$tmp"; \
	./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -E -E-extern src/typeck/typeck.x > "$$tmp" || { rc=$$?; rm -f "$$tmp"; exit $$rc; }; \
	mv "$$tmp" typeck_gen.c
	$(CC) $(CFLAGS) -c typeck_gen.c -o typeck_x.o
	$(CC) $(CFLAGS) -DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_TYPECK $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS) -o $(TARGET) $(DRIVER_SEED_GLUE_PREFIX) $(DRIVER_SEED_OBJS) driver_x.o $(RELINK_SHUX_PIPELINE_LINK_O) lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $(PIPELINE_LIBS) $(RELINK_SHUX_USER_ASM_LINK) $(RELINK_SHUX_GLUE_SUFFIX)
	@echo "bootstrap-typeck OK"

# 6.2：.x codegen 入口与 C AST 对接；编译 typeck.x + codegen.x 生成 _gen.c，链接进 shux，使 typeck 与 codegen 均由 .x 入口转调 C
bootstrap-codegen: $(TARGET) $(SHUX_C) bootstrap_shuxc $(RELINK_SHUX_PREREQS)
	@tmp=typeck_gen.c.tmp.$$$$; rm -f "$$tmp"; \
	./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -E -E-extern src/typeck/typeck.x > "$$tmp" || { rc=$$?; rm -f "$$tmp"; exit $$rc; }; \
	mv "$$tmp" typeck_gen.c
	@tmp=codegen_gen.c.tmp.$$$$; rm -f "$$tmp"; \
	./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -E -E-extern src/codegen/codegen.x > "$$tmp" || { rc=$$?; rm -f "$$tmp"; exit $$rc; }; \
	mv "$$tmp" codegen_gen.c
	$(CC) $(CFLAGS) -c typeck_gen.c -o typeck_x.o
	$(CC) $(CFLAGS) -c codegen_gen.c -o codegen_x.o
	$(CC) $(CFLAGS) -DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS) -o $(TARGET) $(DRIVER_SEED_GLUE_PREFIX) $(DRIVER_SEED_OBJS) driver_x.o $(RELINK_SHUX_PIPELINE_LINK_O) lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $(PIPELINE_LIBS) $(RELINK_SHUX_USER_ASM_LINK) $(RELINK_SHUX_GLUE_SUFFIX)
	@echo "bootstrap-codegen OK"

# 6.3/6.4：入口在 main.x；链接时用 main_driver.o（带 SHUX_USE_X_DRIVER/PIPELINE 以启用 -backend asm）+ runtime_driver.o + ...
src/main_driver.o: src/main.c Makefile
	$(CC) $(CFLAGS) -DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -c -o $@ $<
# G-02a: preprocess.c 已物理删除；runtime preprocess() 走 preprocess.x（preprocess_x.o）。
src/driver/target_cpu.o: src/driver/target_cpu.c include/target_cpu.h
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<
src/asm/simd_enc.o: src/asm/simd_enc.c include/simd_enc.h include/target_cpu.h
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<
src/asm/simd_loop.o: src/asm/simd_loop.c include/simd_loop.h include/simd_enc.h include/target_cpu.h
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<
# G-02a Step 1：默认构建切 no_c 模式；默认 bootstrap 不链 LEXER_LINK_O / AST_LINK_O。
# C 前端 .c（ast/lexer/parser/typeck/codegen）仍保留，因 build_shux_asm.sh + relink 脚本仍引用 ast_seed.o 等。
# bootstrap-driver-seed：pipeline_x.o 为 -E-extern 编排；parser/lexer/typeck/codegen *_x.o 分 TU。
# C-06 v1 默认：不链 C parser/typeck/codegen.o（SHUX_LEGACY_C_FRONTEND=1 恢复双轨）。
# seed 链：lexer_x.o + x_frontend_link_alias.o（X 词法）；默认不链 C lexer.o（E-03 v2）。
# G-02a: preprocess.c 已物理删除；SHUX_LEGACY_PREPROCESS_C 路径已死（preprocess_for_driver.o 无法编译）。
# runtime preprocess() 走 preprocess.x（preprocess_x.o）；PREPROCESS_LINK_O 恒空。
PREPROCESS_LINK_O =
DRIVER_SEED_PREPROCESS_REBUILD =
# parser labeled 名写入（parser_x.o / ast_pool_l5_bridge 依赖，不可缺链）。
AST_POOL_L5_BRIDGE_O = src/runtime_driver_strict_glue_stubs.o
# G-02a：C 前端已删；SHUX_LEGACY_C_FRONTEND=1 不再支持。
DRIVER_SEED_C_FRONTEND_LEGACY =
# G-06：提交 seeds/bootstrap_shuxc.* 由 capture（SHUX_LEGACY_C_FRONTEND=1）生成；默认 bootstrap/relink 须匹配该链接布局。
# SHUX_NO_C_SEED_LINK=1 时走 E-04 runtime_driver_no_c（实验；与 pinned seed 不兼容）。
ifeq ($(SHUX_LEGACY_C_FRONTEND),1)
DRIVER_SEED_RUNTIME_O = src/runtime_driver.o
DRIVER_SEED_FRONTEND_EXTRA = $(DRIVER_SEED_C_FRONTEND_LEGACY)
DRIVER_SEED_SUPPORT_EXTRA = src/async/async_liveness.o src/async/async_cps_codegen.o
DRIVER_SEED_LINK_FLAGS = -DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN
DRIVER_SEED_RUNTIME_REBUILD = src/runtime_driver.o src/async/async_cps_codegen.o
else ifeq ($(SHUX_NO_C_SEED_LINK),1)
# E-04 v1：无 C ast/lexer/runtime_driver（勿用于已提交 G-06 种子的 relink）。
# runtime_driver_strict_glue_stubs.o：提供 lexer_new/parse/preprocess 等 C API weak 桩，供 lsp_diag.o 等
# 非 SHUX_NO_C_FRONTEND 编译单元引用（lsp_diag.c 未走 no_c 守卫，仍需符号满足链接）。
DRIVER_SEED_RUNTIME_O = src/runtime_driver_no_c.o
DRIVER_SEED_FRONTEND_EXTRA =
DRIVER_SEED_SUPPORT_EXTRA = src/runtime_driver_strict_glue_stubs.o src/lexer/cfg_eval.o src/typeck/typeck_f64_bits.o
DRIVER_SEED_LINK_FLAGS = -DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN
DRIVER_SEED_RUNTIME_REBUILD = src/runtime_driver_no_c.o
else
# G-02a：默认 no_c 模式（X pipeline 自洽；C 前端 API weak stubs 满足链接但不调用）。
# 2026-07-08：从 seed-compat 切换到 no_c；macOS arm64 check ✅、compile 走 -E+cc fallback ✅；Linux x86_64 全绿。
DRIVER_SEED_RUNTIME_O = src/runtime_driver_no_c.o
DRIVER_SEED_FRONTEND_EXTRA =
DRIVER_SEED_SUPPORT_EXTRA = src/runtime_driver_strict_glue_stubs.o src/lexer/cfg_eval.o src/typeck/typeck_f64_bits.o
DRIVER_SEED_LINK_FLAGS = -DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN
DRIVER_SEED_RUNTIME_REBUILD = src/runtime_driver_no_c.o
endif
# pipeline_glue_standalone 与 pipeline_x.o 重复时 glue 置链接末尾且允许多定义（覆盖 pipeline_gen 快照内旧 glue）。
ASM_GLUE_STANDALONE_O = build_asm/pipeline_glue_standalone.o
ifeq ($(UNAME_S),Darwin)
LD_R_MULTIDEF_FLAGS = -multiply_defined suppress
ASM_GLUE_DUP_LDFLAGS = -Wl,-multiply_defined,suppress
else
LD_R_MULTIDEF_FLAGS = --allow-multiple-definition
ASM_GLUE_DUP_LDFLAGS = -Wl,--allow-multiple-definition
endif
RELINK_SHUX_GLUE_SUFFIX = build_asm/pipeline_glue_strict_minimal.o
DRIVER_SEED_GLUE_PREFIX =
DRIVER_SEED_GLUE_SUFFIX = $(ASM_GLUE_STANDALONE_O)
# LSP_DIAG_LINK_O：fmt 命令依赖 shu_format_x_document 的真实实现，必须链入 lsp_diag.o
# 而非 lsp_diag_stubs_no_c.o（no-op stub 会让 fmt 静默无操作）。
# 历史：E-02 v1 误注 "lsp_diag.c 已删" 但文件实存；链接 stub 导致 fmt 不生效。
# 修复日期：2026-07-04。
LSP_DIAG_LINK_O = src/lsp/lsp_diag.o
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
# G-02a：默认 no_c 模式；不链 C lexer/ast（X pipeline 自洽）。
LEXER_LINK_O =
AST_LINK_O =
endif
# E-04 v19/v20：Linux / Darwin bootstrap 默认 crt0 替代 main_driver.o（driver_x.o 导出 main_entry）。
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
DRIVER_SEED_OBJS = $(MAIN_LINK_O) src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/diag.o src/runtime_pipeline_abi.o $(DRIVER_SEED_RUNTIME_O) src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o $(PREPROCESS_LINK_O) $(LEXER_LINK_O) $(AST_LINK_O) $(DRIVER_SEED_X_FRONTEND_OBJS) $(DRIVER_SEED_FRONTEND_EXTRA) $(DRIVER_SEED_SUPPORT_EXTRA) src/x_seed_bridge.o src/seed_link_compat.o src/runtime_driver_strict_glue_stubs.o
DRIVER_SEED_X_OBJS = parser_x.o typeck_x.o codegen_x.o

# 阶段 10.4 实验：链 typeck_x.o/codegen_x.o 替代 C 前端（不含 pipeline_x.o，无 SHUX_USE_X_PIPELINE）。
# 勿复用 DRIVER_SEED_X_FRONTEND_OBJS 名：bootstrap-driver-seed 链依赖 parser_x.o/lexer_x.o（见上 §1280）。
DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS = src/main_driver.o src/runtime_driver.o src/diag.o src/lexer/lexer.o src/ast/ast_seed.o typeck_x.o codegen_x.o
bootstrap-driver-seed-x-frontend: $(SHUX_C) migrate-x-objs driver_x.o preprocess_x.o $(DRIVER_SUBCMD_GEN) $(DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS) $(LSP_DIAG_LINK_O) $(DRIVER_SUBCMD_OBJS)
	$(CC) $(CFLAGS) -DSHUX_USE_X_DRIVER -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN -o $(TARGET)_x_frontend $(DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS) driver_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) $(LSP_DIAG_LINK_O) $(PIPELINE_LIBS)
	@echo "bootstrap-driver-seed-x-frontend OK ($(TARGET)_x_frontend: .x typeck/codegen, no pipeline_x.o)"

# 6.3：.x 入口与 main.c 一一对应。bootstrap-driver-seed = 用 C 代码生成（生成 pipeline_gen.c / driver_gen.c）得到种子 shux；仅首次或无 shux 时需要。
# bootstrap-driver-asm / bootstrap-driver-hybrid = B-hybrid（build_shux_asm 无 SKIP_GEN），产出可覆盖 $(TARGET)。
# bootstrap-driver = M7 默认 B-strict（同 bootstrap-driver-bstrict）：SKIP_GEN 链 shux_asm 并覆盖 $(TARGET)；冷启动仍仅 bootstrap-driver-seed。
# 无补丁：driver_gen.c 仅由 -E -E-extern 生成；run_compiler_c 在 runtime.c 中定义并转调 main_run_compiler_c；其余从 main.x/codegen 根源修
# LSP 诊断：G-02a lsp_diag.c 已删；仅 lsp_diag_x.o + stubs。

src/lsp/lsp_diag_pipeline_sizes.o: src/lsp/lsp_diag_pipeline_sizes.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# bootstrap/relink 同时链 lsp_diag_pipeline_ctx.o；Cygwin 无 weak，须省略 sizes 内占位符号。
src/lsp/lsp_diag_pipeline_sizes_nostub.o: src/lsp/lsp_diag_pipeline_sizes.c
	$(CC) $(CFLAGS) -DSHUX_LSP_PIPELINE_CTX_LINKED -I. -Iinclude -Isrc -c -o $@ $<

# G-02e-8：lsp_diag_x_alias 已并入本 TU。
src/lsp/lsp_diag_pipeline_ctx.o: src/lsp/lsp_diag_pipeline_ctx.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# G-02e-14：heap_*_c 在 runtime_heap_user.inc（由 glue_stubs 与 link_abi ensure 共用）。
src/runtime_driver_strict_glue_stubs.o: src/runtime_driver_strict_glue_stubs.c src/runtime_heap_user.inc
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# G-02a：ast_seed.o 从 runtime_ast_glue.inc 编译（从 src/ast/ast.c 迁移）。
# 提供 ast_module_free/ast_expr_free/ast_block_free 等 8 个内存管理函数。
# 不含 ast_expr_init_match_enum（no_c 模式下由 x_seed_bridge.o 提供）。
src/ast/ast_seed.o: src/asm/runtime_ast_glue.inc include/ast.h scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_ast_glue.inc $@

# G-02a: ast_x.o alias — ast_seed.o 提供 C ABI 内存管理实现。
ast_x.o: src/ast/ast_seed.o
	cp -f src/ast/ast_seed.o ast_x.o

# G-02a: preprocess.c 已物理删除；preprocess.o 不再编译（preprocess_x.o 由 .x 生成）。

# G-02a: lexer.o 从 runtime_lexer_glue.inc 编译（G-02e-19：cc_inc_tu）。
src/lexer/lexer.o: src/asm/runtime_lexer_glue.inc src/lexer/lexer.h include/token.h scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_lexer_glue.inc $@

# G-02a: typeck.c 已物理删除；typeck_x.o 由 typeck.x 生成，typeck_c_module_stubs.o 提供 weak 桩。

# G-02a: codegen.c 已物理删除；codegen_x.o 由 codegen.x 生成，codegen_pipeline_stubs.o 提供 weak 桩。

# G-02a: autovec.c 已物理删除（孤立死代码，无任何调用点/include）。

lsp_diag_gen.c: src/lsp/lsp_diag.x
	@if [ -s lsp_diag_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "lsp_diag_gen.c: pinned ($$(wc -c < lsp_diag_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ -f seeds/lsp_diag_gen.linux.x86_64.c ] && [ ! -s lsp_diag_gen.c ]; then \
	  cp -f seeds/lsp_diag_gen.linux.x86_64.c lsp_diag_gen.c; \
	  echo "lsp_diag_gen.c: restored from seeds/lsp_diag_gen.linux.x86_64.c"; \
	else \
	  echo "lsp_diag_gen.c: $(SHUX_C) -E -E-extern (avoid shux-x -x -E: broken TU for lsp_diag.x)" >&2; \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(LSP_X_E_DIRS) -L src/pipeline src/lsp/lsp_diag.x -E -E-extern > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/lsp_diag_gen.linux.x86_64.c ]; then cp -f seeds/lsp_diag_gen.linux.x86_64.c $@ && echo "lsp_diag_gen.c: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	fi
	@if ! grep -q 'C-04 -E-extern TU aliases' $@ 2>/dev/null; then \
	  if [ -f seeds/lsp_diag_gen.linux.x86_64.c ]; then cp -f seeds/lsp_diag_gen.linux.x86_64.c $@; \
	  else echo "lsp_diag_gen.c: FAIL missing C-04 -E-extern TU aliases (need shux-c -E-extern codegen; no perl fallback)" >&2; exit 1; fi; \
	fi

lsp_diag_x.o: lsp_diag_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c lsp_diag_gen.c -o lsp_diag_x.o

# lsp_io.x：C-04 v0 要求 shux-c 自动生成 import extern；shux-x 仍走旧块时回退 shux-c。
lsp_io_gen.c: src/lsp/lsp_io.x
	@if [ -s lsp_io_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "lsp_io_gen.c: pinned ($$(wc -c < lsp_io_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/lsp_io_gen.linux.x86_64.c ] && [ ! -s lsp_io_gen.c ]; then \
	  cp -f seeds/lsp_io_gen.linux.x86_64.c lsp_io_gen.c; \
	  echo "lsp_io_gen.c: restored from seeds/lsp_io_gen.linux.x86_64.c"; \
	elif [ -f $(SHUX_X) ]; then \
	  echo "lsp_io_gen.c: ./$(SHUX_X) -x -E ..." >&2; \
	  ./$(SHUX_X) -x -E $(LSP_X_E_DIRS) -E-extern src/lsp/lsp_io.x > $@.tmp 2>/dev/null || true; \
	  if [ -s $@.tmp ] && ! grep -q 'lsp_io -E-extern stubs (io.o' $@.tmp; then \
	  mv $@.tmp $@; \
	  else \
	  rm -f $@.tmp; \
	  echo "lsp_io_gen.c: fallback to shux-c -E -E-extern (C-04)" >&2; \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(LSP_X_E_DIRS) src/lsp/lsp_io.x -E -E-extern > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/lsp_io_gen.linux.x86_64.c ]; then cp -f seeds/lsp_io_gen.linux.x86_64.c $@ && echo "lsp_io_gen.c: fallback seed" >&2; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	  fi; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(LSP_X_E_DIRS) src/lsp/lsp_io.x -E -E-extern > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/lsp_io_gen.linux.x86_64.c ]; then cp -f seeds/lsp_io_gen.linux.x86_64.c $@ && echo "lsp_io_gen.c: fallback seed" >&2; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	fi

# LSP 模块：main.x 依赖 lsp；std.io 由 .x codegen 提供（F-03 v2/v3，无 io.o）。
# LSP state 单独 .c，避免 lsp_main 内大数组导致 state 被覆盖

# lsp_gen.c 期望 typeck_read_message 等；lsp_io -E-extern 未产出时由桩提供（G-02e-16 .inc）。
src/lsp/typeck_lsp_io_stub.o: src/lsp/typeck_lsp_io_stub.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/lsp/typeck_lsp_io_stub.inc $@

src/seed_link_compat.o: src/seed_link_compat.c
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

lsp_gen.c: src/lsp/lsp.x
	@if [ -s lsp_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "lsp_gen.c: pinned ($$(wc -c < lsp_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/lsp_gen.linux.x86_64.c ] && [ ! -s lsp_gen.c ]; then \
	  cp -f seeds/lsp_gen.linux.x86_64.c lsp_gen.c; \
	  echo "lsp_gen.c: restored from seeds/lsp_gen.linux.x86_64.c"; \
	elif [ -f $(SHUX_X) ]; then \
	  echo "lsp_gen.c: ./$(SHUX_X) -x -E ..." >&2; \
	  ./$(SHUX_X) -x -E $(LSP_X_E_DIRS) -E-extern src/lsp/lsp.x > $@.tmp 2>/dev/null || true; \
	  if [ -s $@.tmp ] && grep -q typeck_lsp_main_impl $@.tmp && ! grep -q 'lsp.x -E-extern stubs (lsp_io_x' $@.tmp; then \
	  mv $@.tmp $@; \
	  else \
	  rm -f $@.tmp; \
	  echo "lsp_gen.c: shux-x failed or old extern block, fallback to shux-c -E -E-extern" >&2; \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(LSP_X_E_DIRS) src/lsp/lsp.x -E -E-extern > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/lsp_gen.linux.x86_64.c ]; then cp -f seeds/lsp_gen.linux.x86_64.c $@ && echo "lsp_gen.c: fallback seed" >&2; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	  fi; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(LSP_X_E_DIRS) src/lsp/lsp.x -E -E-extern > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/lsp_gen.linux.x86_64.c ]; then cp -f seeds/lsp_gen.linux.x86_64.c $@ && echo "lsp_gen.c: fallback seed" >&2; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	fi
	@sed -i.bak 's/uint8_t state_buf\[16388\] = { 0 }/extern uint8_t g_lsp_state_buf[16388]/' lsp_gen.c 2>/dev/null || true
	@sed -i.bak 's/(state_buf)/(g_lsp_state_buf)/g' lsp_gen.c 2>/dev/null || true

# std_heap_* 由 lsp_io_std_heap.x 提供（转调 libc malloc/free/calloc）；shux-x 路径下 extern 由 codegen.x 输出。
lsp_io_std_heap_gen.c: src/lsp/lsp_io_std_heap.x
	@if [ -s lsp_io_std_heap_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "lsp_io_std_heap_gen.c: pinned ($$(wc -c < lsp_io_std_heap_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/lsp_io_std_heap_gen.linux.x86_64.c ] && [ ! -s lsp_io_std_heap_gen.c ]; then \
	  cp -f seeds/lsp_io_std_heap_gen.linux.x86_64.c lsp_io_std_heap_gen.c; \
	  echo "lsp_io_std_heap_gen.c: restored from seeds/lsp_io_std_heap_gen.linux.x86_64.c"; \
	elif [ -f $(SHUX_X) ]; then \
	  echo "lsp_io_std_heap_gen.c: ./$(SHUX_X) -x -E ..." >&2; \
	  ./$(SHUX_X) -x -E $(LSP_X_E_DIRS) -E-extern src/lsp/lsp_io_std_heap.x > $@.tmp 2>/dev/null || true; \
	  if [ -s $@.tmp ]; then \
	  mv $@.tmp $@; \
	  else \
	  rm -f $@.tmp; \
	  echo "lsp_io_std_heap_gen.c: shux-x failed/OOM, fallback to shux-c -E -E-extern" >&2; \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(LSP_X_E_DIRS) src/lsp/lsp_io_std_heap.x -E -E-extern > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/lsp_io_std_heap_gen.linux.x86_64.c ]; then cp -f seeds/lsp_io_std_heap_gen.linux.x86_64.c $@ && echo "lsp_io_std_heap_gen.c: fallback seed" >&2; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	  fi; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(LSP_X_E_DIRS) src/lsp/lsp_io_std_heap.x -E -E-extern > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/lsp_io_std_heap_gen.linux.x86_64.c ]; then cp -f seeds/lsp_io_std_heap_gen.linux.x86_64.c $@ && echo "lsp_io_std_heap_gen.c: fallback seed" >&2; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	fi
	@sed -i.bak '/^extern uint8_t \* malloc/d; /^extern void free(/d; /^extern uint8_t \* calloc/d' $@ 2>/dev/null || true
	@perl -i.bak -0pe 's/(uint8_t \* typeck_std_heap_alloc\(size_t size\);)/#define std_heap_alloc typeck_std_heap_alloc\n#define std_heap_free typeck_std_heap_free\n#define std_heap_alloc_zeroed typeck_std_heap_alloc_zeroed\n$$1/s' $@ 2>/dev/null || true
lsp_io_std_heap_x.o: lsp_io_std_heap_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c lsp_io_std_heap_gen.c -o lsp_io_std_heap_x.o

# bootstrap-driver-seed / relink-shux 共用：lsp_io / lsp 生成 C → .o
lsp_io_x.o: lsp_io_gen.c src/lsp/lsp_io.x Makefile
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. \
	  -Dstd_io_read=io_read -Dstd_io_write=io_write \
	  -Dstd_heap_alloc_usize=typeck_std_heap_alloc -Dstd_heap_free_u8_ptr=typeck_std_heap_free \
	  -Dtypeck_std_heap_alloc=lsp_io_std_heap_std_heap_alloc \
	  -Dtypeck_std_heap_free=lsp_io_std_heap_std_heap_free \
	  -c lsp_io_gen.c -o lsp_io_x.o

lsp_x.o: lsp_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c lsp_gen.c -o lsp_x.o

# fmt/check/test/compile/build/run：独立 .x -E-extern 产出；asm_driver_* 仍由 runtime_driver_strict_glue_stubs.c 提供
DRIVER_SUBCMD_GEN = driver_fmt_gen.c driver_check_gen.c driver_test_gen.c driver_compile_gen.c driver_build_gen.c driver_run_gen.c driver_emit_gen.c
DRIVER_SUBCMD_OBJS = driver_fmt_x.o driver_check_x.o driver_test_x.o driver_compile_x.o driver_build_x.o driver_run_x.o driver_emit_x.o
DRIVER_SUBCMD_DIRS = -L .. -L src -L src/lexer -L src/ast

driver_fmt_gen.c: src/driver/fmt.x
	@if [ -s driver_fmt_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_fmt_gen.c: pinned ($$(wc -c < driver_fmt_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_fmt_gen.linux.x86_64.c ] && [ ! -s driver_fmt_gen.c ]; then \
	  cp -f seeds/driver_fmt_gen.linux.x86_64.c driver_fmt_gen.c; \
	  echo "driver_fmt_gen.c: restored from seed"; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/fmt.x > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/driver_fmt_gen.linux.x86_64.c ]; then cp -f seeds/driver_fmt_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	fi
driver_check_gen.c: src/driver/check.x
	@if [ -s driver_check_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_check_gen.c: pinned ($$(wc -c < driver_check_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_check_gen.linux.x86_64.c ] && [ ! -s driver_check_gen.c ]; then \
	  cp -f seeds/driver_check_gen.linux.x86_64.c driver_check_gen.c; \
	  echo "driver_check_gen.c: restored from seed"; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/check.x > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/driver_check_gen.linux.x86_64.c ]; then cp -f seeds/driver_check_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	fi
driver_test_gen.c: src/driver/test.x
	@if [ -s driver_test_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_test_gen.c: pinned ($$(wc -c < driver_test_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_test_gen.linux.x86_64.c ] && [ ! -s driver_test_gen.c ]; then \
	  cp -f seeds/driver_test_gen.linux.x86_64.c driver_test_gen.c; \
	  echo "driver_test_gen.c: restored from seed"; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/test.x > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/driver_test_gen.linux.x86_64.c ]; then cp -f seeds/driver_test_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	fi
driver_compile_gen.c: src/driver/compile.x
	@if [ -s driver_compile_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_compile_gen.c: pinned ($$(wc -c < driver_compile_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_compile_gen.linux.x86_64.c ] && [ ! -s driver_compile_gen.c ]; then \
	  cp -f seeds/driver_compile_gen.linux.x86_64.c driver_compile_gen.c; \
	  echo "driver_compile_gen.c: restored from seed"; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/compile.x > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/driver_compile_gen.linux.x86_64.c ]; then cp -f seeds/driver_compile_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	fi
driver_build_gen.c: src/driver/build.x
	@if [ -s driver_build_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_build_gen.c: pinned ($$(wc -c < driver_build_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_build_gen.linux.x86_64.c ] && [ ! -s driver_build_gen.c ]; then \
	  cp -f seeds/driver_build_gen.linux.x86_64.c driver_build_gen.c; \
	  echo "driver_build_gen.c: restored from seed"; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/build.x > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/driver_build_gen.linux.x86_64.c ]; then cp -f seeds/driver_build_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	fi
driver_run_gen.c: src/driver/run.x
	@if [ -s driver_run_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_run_gen.c: pinned ($$(wc -c < driver_run_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_run_gen.linux.x86_64.c ] && [ ! -s driver_run_gen.c ]; then \
	  cp -f seeds/driver_run_gen.linux.x86_64.c driver_run_gen.c; \
	  echo "driver_run_gen.c: restored from seed"; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -E -E-extern src/driver/run.x > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/driver_run_gen.linux.x86_64.c ]; then cp -f seeds/driver_run_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	fi
driver_emit_gen.c: src/driver/emit.x
	@if [ -s driver_emit_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "driver_emit_gen.c: pinned ($$(wc -c < driver_emit_gen.c | tr -d ' ') bytes)"; \
	elif [ -f seeds/driver_emit_gen.linux.x86_64.c ] && [ ! -s driver_emit_gen.c ]; then \
	  cp -f seeds/driver_emit_gen.linux.x86_64.c driver_emit_gen.c; \
	  echo "driver_emit_gen.c: restored from seed"; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(DRIVER_SUBCMD_DIRS) -L ../std/fs -L src/preprocess -L src/pipeline -L src/codegen -E -E-extern src/driver/emit.x > "$$tmp" || \
	  { rm -f "$$tmp"; if [ -f seeds/driver_emit_gen.linux.x86_64.c ]; then cp -f seeds/driver_emit_gen.linux.x86_64.c $@; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	fi

driver_fmt_x.o: driver_fmt_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_fmt_gen.c -o $@
driver_check_x.o: driver_check_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_check_gen.c -o $@
driver_test_x.o: driver_test_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_test_gen.c -o $@
driver_compile_x.o: driver_compile_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_compile_gen.c -o $@
driver_build_x.o: driver_build_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_build_gen.c -o $@
driver_run_x.o: driver_run_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_run_gen.c -o $@
driver_emit_x.o: driver_emit_gen.c
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c driver_emit_gen.c -o $@

# asm_driver_*：driver_gen.c 为 extern 时由本桩提供符号（fmt/check/test 见 DRIVER_SUBCMD_OBJS）。
# 链接顺序：须紧跟 preprocess_x.o 之后（先于 lsp_diag/std *.o），避免与 runtime_driver.o
# 中 _preprocess / preprocess_preprocess_x_buf 解析顺序导致 Undefined _preprocess。

# Stage2 混合链接桩（verify-selfhost-stage2.sh）
_x_stubs2.o: _x_stubs2.c
	$(CC) $(CFLAGS) -c -o $@ $<

# 须在 pipeline_x.o / bootstrap-pipeline 规则之前定义（Make 解析顺序；后置则 $(PIPELINE_X_DEPS) 为空）。
# asm 子树经常新增 backend/platform/arch 级别实现；这里用 wildcard 覆盖整棵 .x 依赖，
# 避免 backend.x 之类的活跃链改动未触发 pipeline_gen.c / pipeline_x.o 重生，继续吃旧快照。
PIPELINE_ASM_X_DEPS = $(wildcard src/asm/*.x src/asm/platform/*.x src/asm/arch/*.x)
PIPELINE_X_DEPS = src/pipeline/pipeline.x src/codegen/codegen.x src/typeck/typeck.x src/parser/parser.x src/ast/ast.x src/lexer/lexer.x src/preprocess/preprocess.x $(PIPELINE_ASM_X_DEPS) pipeline_glue.c ast_pool.c ast_pool_bootstrap_glue.c
ifneq ($(filter 1,$(SHUX_FORCE_REGEN_GEN) $(PIPELINE_X_FORCE_COMPILE)),)
PIPELINE_X_FORCE_PREREQ = FORCE
endif

# pipeline_x.o：与 pipeline_gen.c 及 PIPELINE_X_DEPS 绑定；parser/backend 等 .x 变更须重编，避免 seed 仍用旧 pipeline 逻辑（entry 消失等）。
# 默认复用 build_asm/gen_driver/pipeline_x.o（fat 编排）；设 PIPELINE_X_FORCE_COMPILE=1 才从 pipeline_gen.c 重编。
# pipeline_glue.c / ast_pool.c 由 pipeline_glue_standalone.o 覆盖，勿因二者 mtime 触发整 TU 重编（否则与 partial 并列链 parse 塌陷）。
pipeline_x.o: $(PIPELINE_X_FORCE_PREREQ) pipeline_gen.c $(PIPELINE_X_DEPS)
	@perl scripts/sync_lexer_gen_token_enum.pl pipeline_gen.c
	@GEN_DRV=build_asm/gen_driver/pipeline_x.o; \
	STALE=0; \
	if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ] || [ "$(PIPELINE_X_FORCE_COMPILE)" = "1" ]; then STALE=1; fi; \
	if [ -f "$$GEN_DRV" ]; then \
	  for dep in pipeline_gen.c $(PIPELINE_X_DEPS); do \
	  if [ "$$dep" -nt "$$GEN_DRV" ]; then STALE=1; break; fi; \
	  done; \
	else \
	  STALE=1; \
	fi; \
	if [ "$$STALE" -eq 0 ] && [ -f "$$GEN_DRV" ]; then \
	  cp "$$GEN_DRV" $@ && echo "pipeline_x.o: from build_asm/gen_driver"; \
	else \
	  $(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -DSHUX_PIPELINE_GLUE_OMIT_X_DUP_EXPORTS -I.. -Dstd_io_driver_driver_read_ptr_len=shux_io_read_ptr_len -Dstd_io_driver_driver_read_ptr=shux_io_read_ptr -c pipeline_gen.c -o $@ && \
	  mkdir -p build_asm/gen_driver && cp $@ "$$GEN_DRV"; \
	fi
FORCE:

# driver_gen.c / driver_x.o：main.x 驱动入口；-E 须 shux-c（C parser stmt_order）。
# 与 pipeline_gen.c 同理，driver_gen.c 不应把 legacy-shux-c-ready 作为 Make 前置；
# 否则只要 make 检查 driver_gen.c，就会先触发一次 -B legacy shux-c 强刷。
# 这里保留源码级 freshness 判断，但把 legacy frontend 刷新收进真正 fallback 到
# shux-c 重生的分支里，避免 bstrict/relink 链反复为 pinned driver_gen.c 付费。
driver_gen.c: $(MAIN_X_DEPS)
	@need_regen=0; \
	if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  need_regen=1; \
	elif [ -s $@ ]; then \
	  for dep in $(MAIN_X_DEPS); do \
	  if [ "$$dep" -nt $@ ]; then \
	  need_regen=1; \
	  break; \
	  fi; \
	  done; \
	else \
	  need_regen=1; \
	fi; \
	if [ "$$need_regen" = "0" ]; then \
	  echo "driver_gen.c: pinned ($$(wc -c < $@ | tr -d ' ') bytes; up-to-date with MAIN_X_DEPS)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/driver_gen.linux.x86_64.c ] && [ ! -s $@ ]; then \
	  cp -f seeds/driver_gen.linux.x86_64.c $@; \
	  echo "driver_gen.c: restored from seeds/driver_gen.linux.x86_64.c"; \
	elif [ -f $(SHUX_X) ]; then \
	  echo "driver_gen.c: ./$(SHUX_X) -x -E ..." >&2; \
	  ./$(SHUX_X) -x -E $(MAIN_X_E_DIRS) -E-extern src/main.x > $@.tmp 2>/dev/null || true; \
	  if [ -s $@.tmp ] && grep -q 'argc < 3' $@.tmp && grep -q 'main_eq_minus_E(arg_buf, len) != 0' $@.tmp; then \
	  mv $@.tmp $@; \
	  else \
	  rm -f $@.tmp; \
	  echo "driver_gen.c: shux-x failed or old bare -E block, fallback to shux-c -E -E-extern" >&2; \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(MAIN_X_E_DIRS) src/main.x -E -E-extern > "$$tmp" || \
	  { rm -f "$$tmp"; if [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/driver_gen.linux.x86_64.c ]; then cp -f seeds/driver_gen.linux.x86_64.c $@ && echo "driver_gen.c: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv "$$tmp" $@; fi; \
	  fi; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) $(MAIN_X_E_DIRS) src/main.x -E -E-extern > "$$tmp" || \
	  { rm -f "$$tmp"; if [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/driver_gen.linux.x86_64.c ]; then cp -f seeds/driver_gen.linux.x86_64.c $@ && echo "driver_gen.c: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv "$$tmp" $@; fi; \
	fi
	perl scripts/fix_driver_gen_duplicate_main.pl $@

driver_x.o: driver_gen.c $(MAIN_X_DEPS)
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -include src/x_stubs.h -Dstd_fs_fs_read=fs_posix_read_c -Dstd_fs_fs_write=fs_posix_write_c -Dstd_fs_fs_close=fs_posix_close_c -Dfs_read=fs_posix_read_c -Dfs_write=fs_posix_write_c -Dfs_close=fs_posix_close_c -c driver_gen.c -o driver_x.o

# preprocess_gen.c / preprocess_x.o：runtime SHUX_USE_X_PREPROCESS 路径。
preprocess_gen.c: $(PREPROCESS_X_DEPS)
	@if [ -s preprocess_gen.c ] && [ "$(SHUX_FORCE_REGEN_GEN)" != "1" ]; then \
	  echo "preprocess_gen.c: pinned ($$(wc -c < preprocess_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/preprocess_gen.linux.x86_64.c ] && [ ! -s preprocess_gen.c ]; then \
	  cp -f seeds/preprocess_gen.linux.x86_64.c preprocess_gen.c; \
	  echo "preprocess_gen.c: restored from seeds/preprocess_gen.linux.x86_64.c"; \
	else \
	  tmp="$@.tmp"; \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L src/lexer -E -E-extern src/preprocess/preprocess.x > "$$tmp" || \
	  { rm -f "$$tmp"; if [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/preprocess_gen.linux.x86_64.c ]; then cp -f seeds/preprocess_gen.linux.x86_64.c $@ && echo "preprocess_gen.c: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	  if [ -s "$$tmp" ]; then mv -f "$$tmp" $@; fi; \
	fi

preprocess_x.o: preprocess_gen.c $(PREPROCESS_X_DEPS)
	$(CC) $(CFLAGS) -c preprocess_gen.c -o preprocess_x.o

# SHUX_NO_C_FRONTEND 下 lsp_diag_x.o / lsp_x.o 需要的文档缓冲 + X 管道缓冲桩
src/lsp/lsp_diag_stubs_no_c.o: src/lsp/lsp_diag_stubs_no_c.c include/diag.h
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ $<

# SHUX_SKIP_SUBSCRIPT_MAKE=1：run-all 入口已链 seed，子脚本 `make` 仅在校验 shux 缺失时再完整 bootstrap。
ifeq ($(SHUX_SKIP_SUBSCRIPT_MAKE),1)
bootstrap-driver-seed:
	@test -x '$(TARGET)' || $(MAKE) bootstrap-driver-seed SHUX_SKIP_SUBSCRIPT_MAKE= SHUX_RUN_ALL_BOOTSTRAP_SHUX=1
else
# G-06 两阶段 seed：先无 USER_ASM 链 shux-seed-phase1，再用其跑 asm.x -E 生成 partial，最后全量链 shux。
DRIVER_SEED_LINK_BASE = $(DRIVER_SEED_OBJS) driver_x.o pipeline_x.o lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $(PIPELINE_LIBS)
BOOTSTRAP_DRIVER_SEED_LINK_BASE = $(DRIVER_SEED_OBJS) driver_x.o $(BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O) lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $(PIPELINE_LIBS)

DRIVER_SEED_PREREQS = $(SHUX_C) pipeline_x.o parser_x.o lexer_x.o typeck_x.o codegen_x.o x_frontend_link_alias.o driver_x.o preprocess_x.o lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c $(DRIVER_SUBCMD_GEN) $(MAIN_LINK_REBUILD) src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o $(DRIVER_SEED_RUNTIME_O) src/driver/fmt_check_cmd_driver.o $(PREPROCESS_LINK_O) $(LEXER_LINK_O) $(AST_LINK_O) $(DRIVER_SEED_FRONTEND_EXTRA) $(DRIVER_SEED_SUPPORT_EXTRA) src/x_seed_bridge.o src/seed_link_compat.o src/runtime_driver_strict_glue_stubs.o $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $(DRIVER_SUBCMD_OBJS) $(USER_ASM_SEED_OBJS)

bootstrap-driver-seed: DRIVER_SEED_GLUE_SUFFIX = build_asm/pipeline_glue_strict_minimal.o
bootstrap-driver-seed: $(DRIVER_SEED_PREREQS) build_asm/pipeline_glue_strict_minimal.o
	@# 冷启动：保留已提交的 ast_gen2.c，避免旧 seed 对 ast.x 重新 -E 失败。
	@if [ -f ast_gen2.c ] && [ -s ast_gen2.c ]; then touch -r ast_gen2.c src/ast/ast.x 2>/dev/null || true; fi
	@$(MAKE) pipeline_x.o PIPELINE_X_FORCE_COMPILE=1
	$(MAKE) -B src/diag.o src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o $(DRIVER_SEED_RUNTIME_REBUILD) $(DRIVER_SEED_PREPROCESS_REBUILD) src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o
	$(MAKE) lsp_io_x.o lsp_x.o lsp_diag_x.o src/lsp/lsp_diag_pipeline_ctx.o x_frontend_link_alias.o
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
	@$(MAKE) src/x_seed_bridge.o
	@$(MAKE) $(USER_ASM_SEED_OBJS)
	@# pipeline_x.o / pipeline_glue_standalone.o 引用的 arch_*_enc_enc_* 须 weak 桩；真 partial 导出不含时由 stubs.o 补齐。
	@$(MAKE) $(ASM_GLUE_STANDALONE_O)
	@$(MAKE) build-seed-asm-host
	@if [ ! -s build_asm/seed_host/asm_backend_partial.o ]; then \
	  echo "bootstrap-driver-seed: no seed partial, gen phase1 backend stub ..." >&2; \
	  ./scripts/gen_g06_phase1_backend_stub.sh; \
	fi
	@mkdir -p build_asm/seed_host
	@rm -f $(USER_ASM_SEED_HOST_STUBS) $(USER_ASM_SEED_HOST_DIR)/asm_full_link_stubs.c
	@$(MAKE) $(USER_ASM_SEED_HOST_STUBS)
	@$(MAKE) $(BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS)
	@echo "bootstrap-driver-seed: phase1 link (+ USER_ASM dispatch/bridge + seed partial) ..."
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS) -o shux-seed-phase1 $(DRIVER_SEED_GLUE_PREFIX) $(BOOTSTRAP_DRIVER_SEED_LINK_BASE) $(BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS) $(USER_ASM_SEED_HOST_STUBS) build_asm/seed_host/asm_backend_partial.o $(DRIVER_SEED_GLUE_SUFFIX)
	@echo "bootstrap-driver-seed: build-seed-asm-host via shux-seed-phase1 ..."
	@SHUX_E=./shux-seed-phase1 ./scripts/build_seed_asm_host.sh || \
	  (./scripts/gen_g06_phase1_backend_stub.sh && echo "bootstrap-driver-seed: WARN asm.x -E failed, final link uses phase1 stub partial" >&2)
	@$(MAKE) $(USER_ASM_SEED_HOST_STUBS)
	@echo "bootstrap-driver-seed: final link (+ USER_ASM partial) ..."
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS) -o $(TARGET) $(DRIVER_SEED_GLUE_PREFIX) $(BOOTSTRAP_DRIVER_SEED_LINK_BASE) $(USER_ASM_SEED_HOST_OBJS) $(USER_ASM_SEED_HOST_STUBS) $(BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS) $(DRIVER_SEED_GLUE_SUFFIX)
	@$(MAKE) runtime_panic.o
ifeq ($(SHUX_SKIP_SEED_SMOKE),1)
	@echo "bootstrap-driver-seed: skip seed smoke (SHUX_SKIP_SEED_SMOKE=1)" >&2
else
	@chmod +x scripts/bootstrap_driver_seed_smoke.sh 2>/dev/null || true
	@./scripts/bootstrap_driver_seed_smoke.sh ./$(TARGET)
endif
	cp -f $(TARGET) shux-x
	cp -f $(TARGET) $(SHUX_C)
	cp -f $(TARGET) bootstrap_shuxc
	@chmod +x scripts/bootstrap_shuxc_create.sh scripts/capture_bootstrap_seeds.sh 2>/dev/null || true
	@./scripts/bootstrap_shuxc_create.sh ./$(TARGET) 2>/dev/null || cp -f $(TARGET) bootstrap_shuxc
	@echo "bootstrap-driver-seed OK (C-06 *_x.o; G-06 two-phase seed + USER_ASM partial; shux-c synced)"
endif

# 与 bootstrap-driver-seed 相同；保留别名供脚本引用
# bootstrap seed 链 需 glue 类型头（与 build_shux_asm B-strict 同源）。
build_asm/pipeline_glue_types.inc: pipeline_gen.c scripts/extract_pipeline_glue_types.pl
	@mkdir -p build_asm
	perl scripts/extract_pipeline_glue_types.pl pipeline_gen.c > $@

pipeline_bootstrap_orchestration.o: pipeline_bootstrap_orchestration.c pipeline_gen.c build_asm/pipeline_glue_types.inc
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -Ibuild_asm -DPIPELINE_BOOTSTRAP_ORCH_NO_PIPELINE_RUN_WRAPPER -c -o $@ pipeline_bootstrap_orchestration.c

$(ASM_GLUE_STANDALONE_O): src/asm/pipeline_glue_standalone.inc build_asm/pipeline_glue_types.inc pipeline_glue.c ast_pool.c scripts/cc_inc_tu.sh
	@mkdir -p build_asm
	sh scripts/cc_inc_tu.sh src/asm/pipeline_glue_standalone.inc $@ $(PIPELINE_GEN_CFLAGS) -Wno-error=return-type -Ibuild_asm

build_asm/pipeline_glue_strict_minimal.o: src/asm/pipeline_glue_strict_minimal.c
	@mkdir -p build_asm
	$(CC) $(CFLAGS) -I. -Iinclude -Isrc -c -o $@ src/asm/pipeline_glue_strict_minimal.c

# relink-shux 与 bootstrap-driver-seed 链接同一组 .o；须声明为 prerequisite，否则冷启动仅 make all 后缺 main_driver.o 等。
RELINK_SHUX_PREREQS = build-seed-asm-host $(RELINK_SHUX_FILTERED_OBJS) $(USER_ASM_SEED_HOST_STUBS) $(DRIVER_SUBCMD_GEN) \
  $(DRIVER_SEED_OBJS) driver_x.o pipeline_x.o $(RELINK_SHUX_PIPELINE_LINK_O) \
  lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c \
  lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o \
  $(DRIVER_SUBCMD_OBJS) \
  $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o \
  src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o \
# driver/fmt_check 变更后快速重链 shux（不跑 asm.x -E；需已有 build_asm/seed_host/asm_backend_partial.o）
# relink-shux-lexer：仅重建 lexer_x.o 并重链，不触发 driver/typeck *_gen.c 再生（迭代 token enum 修复用）。
# 提供真实 shux_asm 目标，避免同名旧文件让 `make shux_asm` 静默跳过重建。
# Darwin 等宿主直接走 relink-shux 的已过滤拓扑，避免 build_shux_asm.sh 直链 seed_host partial 时重复符号。
# G-05 100%：产品路径编排在 scripts/g05_*.sh（零 make 于 prepare/ensure/export/link）。
# 下列目标仅：
# - 单文件 .o 规则（冷启动隐式）
# - 薄包装兼容 `make shux_asm` / `make relink-shux` → 委托 shell
# - g05-ensure / g05-export 兼容别名 → 同名 shell 脚本
.PHONY: shux_asm relink-shux relink-shux-lexer refresh-shux-asm-gate \
	g05-ensure-relink-prereqs g05-export-relink

# 兼容：委托 scripts/g05_ensure_relink_prereqs.sh（产品路径不再依赖本 recipe 图）
g05-ensure-relink-prereqs:
	@sh scripts/g05_ensure_relink_prereqs.sh

# 兼容：委托 scripts/g05_relink_env.sh（与 shell 清单单一真相）
g05-export-relink:
	@sh scripts/g05_relink_env.sh

# 兼容入口：委托 G-05 shell 编排（无 recipe 内嵌 cc；产品路径零 make）
relink-shux:
	@G05_SYNC_ASM=0 sh scripts/g05_prepare_and_relink.sh
	@echo "relink-shux OK (via g05_prepare_and_relink.sh)"

shux_asm:
	@G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
	@echo "shux_asm OK (via g05_prepare_and_relink.sh)"

relink-shux-lexer: lexer_x.o
	@test -f build_asm/seed_host/asm_backend_partial.o || (echo "relink-shux-lexer: need build_asm/seed_host/asm_backend_partial.o (make build-seed-asm-host)" >&2; exit 1)
	@test -f driver_x.o && test -f pipeline_x.o && test -f parser_x.o && test -f typeck_x.o && test -f codegen_x.o || (echo "relink-shux-lexer: missing *_x.o (make bootstrap-driver-seed first)" >&2; exit 1)
	@$(MAKE) $(RELINK_SHUX_FILTERED_OBJS)
	@$(MAKE) $(RELINK_SHUX_GLUE_SUFFIX)
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS) -o $(TARGET) $(DRIVER_SEED_GLUE_PREFIX) $(DRIVER_SEED_OBJS) driver_x.o $(RELINK_SHUX_PIPELINE_LINK_O) lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $(PIPELINE_LIBS) $(RELINK_SHUX_USER_ASM_LINK) $(RELINK_SHUX_GLUE_SUFFIX)
	cp -f $(TARGET) $(SHUX_C)
	cp -f $(TARGET) bootstrap_shuxc
	@echo "relink-shux-lexer OK (lexer_x.o only; shux-c synced)"

bootstrap-driver-seed-user-asm: bootstrap-driver-seed
	@echo "bootstrap-driver-seed-user-asm OK (= bootstrap-driver-seed + USER_ASM_LINK)"

# 实验：不链 C lexer/parser/typeck/codegen；依赖已成功的 bootstrap-driver-seed 产物。(-E-extern / 泛型单态 C 路径不可用)
DRIVER_NO_C_FRONTEND_OBJS = $(MAIN_LINK_O) src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/diag.o src/runtime_pipeline_abi.o src/runtime_driver_no_c.o $(PREPROCESS_LINK_O) $(AST_LINK_O) src/typeck/typeck_f64_bits.o
shux-no-c-frontend: $(DRIVER_NO_C_FRONTEND_OBJS) src/lsp/lsp_diag_stubs_no_c.o
	@test -f driver_x.o && test -f pipeline_x.o && test -f preprocess_x.o || (echo "请先 make bootstrap-driver-seed" && exit 1)
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(MAIN_LINK_FLAGS) -o $@ $(DRIVER_NO_C_FRONTEND_OBJS) driver_x.o pipeline_x.o lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) src/lsp/lsp_diag_pipeline_sizes.o src/lsp/lsp_diag_stubs_no_c.o lsp_io_std_heap_x.o $(PIPELINE_LIBS)
	@echo "shux-no-c-frontend OK (try: ./shux-no-c-frontend -E examples/hello.x)"

# 注意：Makefile 中存在同名规则 `shux-x:`，不能把 `shux-x` 列为本目标 prerequisite，否则会先执行重链接口而非仅检测文件是否存在。
regen-lsp-gens-x:
	@if [ ! -f $(SHUX_X) ]; then echo "请先 make bootstrap-driver-seed（需要 ./$(SHUX_X)）。" >&2; exit 1; fi
	rm -f lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c
	$(MAKE) lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c
	@echo "regen-lsp-gens-x OK"

# 仅重链 ./shux-x；pipeline/driver/preprocess 的 .x 变更会经对应 *_x.o 目标触发重编后再链接。
shux-x: build-seed-asm-host $(DRIVER_SEED_OBJS) $(SHUX_X_PIPELINE_LINK_O) $(SHUX_X_USER_ASM_OBJS) driver_x.o preprocess_x.o $(RELINK_SHUX_GLUE_SUFFIX)
	@test -f driver_x.o && test -f lsp_x.o && test -f lsp_diag_x.o && test -f lsp_io_x.o && test -f preprocess_x.o && test -f lsp_io_std_heap_x.o && test -f driver_fmt_x.o && test -f driver_check_x.o && test -f driver_test_x.o && test -f driver_compile_x.o && test -f driver_build_x.o && test -f driver_run_x.o && test -f || (echo "缺少 driver_x.o 等，请先: make bootstrap-driver-seed" && exit 1)
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS) -o $@ $(DRIVER_SEED_OBJS) driver_x.o $(SHUX_X_PIPELINE_LINK_O) lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $(USER_ASM_SEED_HOST_OBJS) $(USER_ASM_SEED_HOST_STUBS) $(SHUX_X_USER_ASM_OBJS) $(RELINK_SHUX_GLUE_SUFFIX)
	@echo "shux-x OK"

# Stage2：shux-x 用 -x -E-extern 生成 _gen2.c 并链出 shux-x2，与 shux-x 行为对比（脚本内会 make shux-x / bootstrap-driver-seed）
verify-selfhost-stage2:
	sh ./verify-selfhost-stage2.sh

# 可选：在 bootstrap-verify 之外单独跑 Stage2（不阻塞 PR 默认 CI）
bootstrap-verify-stage2: verify-selfhost-stage2
	@echo "bootstrap-verify-stage2 OK"

# M5：B-strict 二遍 build_shux_asm（shux_asm -> shux_asm2），不依赖 shux-x -x -E。
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

# P0 asm 门禁：strict shux_asm 与 seed+migrate-x-objs 对齐（M-3 含 typeck/codegen/ast）；shux_asm2 仍保留 gen2。
refresh-shux-asm-gate: migrate-x-objs relink-shux
	@cp -f $(TARGET) shux_asm
	@echo "refresh-shux-asm-gate OK (shux_asm <- seed+migrate-x-objs)"
	@if [ -n "$$SHUX_BSTRICT_NO_REPLACE" ]; then echo "bootstrap-driver-bstrict OK (shux_asm=seed+parser_x; $(TARGET) unchanged)"; else cp -f shux_asm $(TARGET) && echo "bootstrap-driver-bstrict OK (shux_asm -> $(TARGET), release default B-strict)"; fi

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
	@echo " Full asm build: SHUX=./$(TARGET) ./scripts/build_shux_asm.sh (requires bootstrap-driver first)"
bootstrap-asm-full: bootstrap-driver bootstrap-asm
	@SHUX=./$(TARGET) ./scripts/build_shux_asm.sh

# Goal 2 辅助：检查 build_asm/*.o 的 __text 段是否非空（需先有 build_asm，例如刚跑过 build_shux_asm.sh）。严格失败：SHUX_ASM_QUALITY_STRICT=1 make check-asm-o-quality
check-asm-o-quality: $(TARGET)
	@SHUX=./$(TARGET) ./scripts/check_asm_o_quality.sh

# 6.4 验收：宿主编译器能编译整机 .x（typeck+codegen+driver）并产出新 shux，且新 shux 能编译运行测试（return-value 返回 42 视为成功）。用 seed 构建 shux 以保证通过（asm 路径修好后可改为 bootstrap-driver）。
# seed 的 .x 单文件路径把 C 写到 -o；须 $(CC) 链成可执行再运行（与 shux-c 直接出 Mach-O/ELF 不同）。
check-6.4: $(TARGET)
	@$(MAKE) bootstrap-driver-seed && ./$(TARGET) ../tests/return-value/main.x -o /tmp/check64.c && $(CC) $(CFLAGS) -o /tmp/check64 /tmp/check64.c && /tmp/check64; [ $$? -eq 42 ] && echo "check-6.4 OK"

# 首次/从零构建：一条命令得到 shux-c + build_tool（build-tool 仅依赖 shux-c，与 lsp_gen 生成物无环）。与 README「读者一次做对」一致。
first-time: build-tool

# 阶段 7：build.x 驱动 build_tool（G-05：build_runner + build_runtime_x，无 build_runtime.c）
# G-05（2026-07-10）：
# - 默认用 seeds/ 下 pinned *_gen.c（-x -E 对 build_runner.entry / 大 TU 仍不稳定；C 前端 -E-extern 已随 G-02a 不可用）
# - 可选：SHUX_BUILD_TOOL_REGEN=1 且 ./shux 可 -x -E 时尝试刷新 build_gen + build_runtime_x_gen
# - build_run_asm_build 默认 `make shux_asm`（与 relink 定稿一致）；FULL=1 → bootstrap-driver-bstrict
# - main 调用 entry（build_runner.x），非 build_entry
build-tool:
	@if [ "$${SHUX_BUILD_TOOL_REGEN:-0}" = "1" ] && [ -x ./shux ]; then \
	  echo "build-tool: regen build_gen + build_runtime_x_gen via ./shux -x -E"; \
	  ./shux -x -E -L .. ../build.x > build_gen.c || cp -f seeds/build_gen.c build_gen.c; \
	  ./shux -x -E -L .. ../build_runtime_x.x > build_runtime_x_gen.c || cp -f seeds/build_runtime_x_gen.c build_runtime_x_gen.c; \
	else \
	  cp -f seeds/build_gen.c build_gen.c; \
	  cp -f seeds/build_runtime_x_gen.c build_runtime_x_gen.c; \
	fi
	cp -f seeds/build_runner_gen.c build_runner_gen.c
	$(CC) $(CFLAGS) -Wno-unused -c build_gen.c -o build_tool.o
	$(CC) $(CFLAGS) -c src/build_tool_libc_bridge.c -o build_tool_libc_bridge.o
	$(CC) $(CFLAGS) -c build_runner_gen.c -o build_runner.o
	$(CC) $(CFLAGS) -Wno-unused -c build_runtime_x_gen.c -o build_runtime_x.o
	$(CC) $(CFLAGS) -c src/build_tool_main.c -o build_tool_main.o
	$(CC) $(CFLAGS) -o build_tool build_tool_main.o build_runner.o build_tool.o build_runtime_x.o build_tool_libc_bridge.o -lc
	@echo "build_tool OK（./build_tool ./shux [asm|legacy]；G-05 pinned seeds）"

src/build_tool_main.o: src/build_tool_main.c
	$(CC) $(CFLAGS) -c src/build_tool_main.c -o src/build_tool_main.o

# 别名：与 build-tool 相同（历史 target 名）
build-tool-x: build-tool

# 运行 build_tool 产出 shux（等价于 make bootstrap-driver，无需执行 Makefile bootstrap-driver 目标）
build-via-tool: build-tool
	./build_tool ./$(TARGET)
	@echo "build-via-tool OK（shux 已由 build_tool 产出）"

# 阶段 8.1/8.2：用 seed 产出 shu₁（C 生成 pipeline_gen.c/driver_gen.c 再链接）；用 shu₁ 再编得到 shu₂。两代跑 run-all 一致即自举验证通过。
# 注：asm 链接就绪（Goal 2）后可改为 bootstrap-driver，则 shu₁ 为 asm 版，实现「无 C 生成」自举。
# 与 bootstrap-driver-seed 一致；std.io 纯 .x（F-03 v2/v3）。
# bootstrap-self 末尾：stage2 对 return-value -o /tmp/out_self 可与 run-return-value.sh 一致产出 Mach-O/ELF；若为 C 源码则用 cc -x c 链出临时 bin（勿假定 -o *.c 必为 C）。
bootstrap-self: bootstrap-driver-seed
	@cp $(TARGET) $(TARGET)_stage1 && \
	$(MAKE) -s pipeline_x.o driver_x.o preprocess_x.o lsp_io_gen.c lsp_gen.c lsp_io_std_heap_gen.c 2>/dev/null || true && \
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Dstd_io_read=io_read -Dstd_io_write=io_write -c lsp_io_gen.c -o lsp_io_x.o && \
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -c lsp_gen.c -o lsp_x.o && \
	$(CC) $(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc -c lsp_io_std_heap_gen.c -o lsp_io_std_heap_x.o && \
	$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(MAIN_LINK_FLAGS) -o $(TARGET)_stage2 $(DRIVER_SEED_OBJS) driver_x.o pipeline_x.o lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $(PIPELINE_LIBS) $(USER_ASM_LINK) && \
	rm -f /tmp/out_self /tmp/out_self.bin && \
	./$(TARGET)_stage2 ../tests/return-value/main.x -o /tmp/out_self && \
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

# 9.1 自举：纯 .x 流水线（parse_into → typeck_x_ast → codegen_x_ast）；生成 pipeline_gen.c 便于联调；-L 与 pipeline 依赖一致。
# 【Why 根源】必须用 $(SHUX_C) 做 -E：G-02a 后 parser.c 已物理删除，$(SHUX_C) 即 bootstrap_shuxc seed（.x pipeline）。
# seed 的 .x parser 按源码顺序填充 stmt_order，codegen 按序输出；若用 $(TARGET)（非 seed 的 .x 解析）则 stmt_order
# 仅有 const+let 导致声明被提到函数首、顺序错乱。故 -E 须固定用 seed 而非 $(TARGET)。
# pipeline_gen.c 必须是真文件目标，且默认沿用 pinned 生成物：
# 1) 若把它挂在 bootstrap-pipeline 这种伪目标下，经 pipeline_x.o / asm_full_link_stubs.o 间接依赖时会反复触发
# bootstrap-pipeline -> legacy-shux-c-ready -> make -B shux-c。
# 2) 若把 legacy-shux-c-ready 作为 order-only 前置，Make 仍会在“检查 pipeline_gen.c”时先执行那段 -B 重编。
# 因此这里把 legacy frontend 刷新收进真正需要重生的分支里：仅当文件缺失或显式 SHUX_FORCE_REGEN_GEN=1 时才刷新并生成；
# 其余情况直接沿用 pinned pipeline_gen.c。
pipeline_gen.c:
	@if [ "$(SHUX_FORCE_REGEN_GEN)" = "1" ]; then \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -E -E-extern src/pipeline/pipeline.x > pipeline_gen.c || exit 1; \
	  echo "bootstrap-pipeline: pipeline_gen.c (-E-extern thin TU; forced regen)"; \
	elif [ -s pipeline_gen.c ]; then \
	  echo "bootstrap-pipeline: pinned pipeline_gen.c ($$(wc -c < pipeline_gen.c | tr -d ' ') bytes; SHUX_FORCE_REGEN_GEN=1 to regen)"; \
	elif [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/pipeline_gen.linux.x86_64.c ] && [ ! -s pipeline_gen.c ]; then \
	  cp -f seeds/pipeline_gen.linux.x86_64.c pipeline_gen.c; \
	  echo "bootstrap-pipeline: restored from seeds/pipeline_gen.linux.x86_64.c"; \
	else \
	  $(MAKE) $(SHUX_C) && \
	  ./$(SHUX_C) -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -E -E-extern src/pipeline/pipeline.x > pipeline_gen.c || \
	  { if [ "$(SEED_LINUX_X86_64_OK)" = "1" ] && [ -f seeds/pipeline_gen.linux.x86_64.c ]; then cp -f seeds/pipeline_gen.linux.x86_64.c pipeline_gen.c && echo "bootstrap-pipeline: fallback seed (shux-c -E failed)" >&2; else exit 1; fi; }; \
	  echo "bootstrap-pipeline: pipeline_gen.c (-E-extern thin TU; codegen 无 perl 后处理)"; \
	fi

.PHONY: bootstrap-pipeline
bootstrap-pipeline: pipeline_gen.c
	@echo "bootstrap-pipeline OK"
# 仅重生成并编译 pipeline/driver/preprocess 三个 X 对象（供调试或 build_shux_asm 对齐）
gen-x-driver-objs: pipeline_x.o driver_x.o preprocess_x.o
	@echo "gen-x-driver-objs OK (pipeline_x.o driver_x.o preprocess_x.o)"

# pipeline_gen.c 为真实文件目标；-E 时 runtime.c 在入口为 pipeline.x 时自动追加 pipeline_glue.c 到 stdout，无 Makefile 补丁

# 链接带 -x 流水线的 shux（需 main_x.o 用 -DSHUX_USE_X_PIPELINE 编译，否则 -x -E 不生效）
# shux-x-pipeline 链接了；lsp_diag_pipeline_sizes.o 提供 lsp_diag 与 pipeline 间结构体 sizeof；
# 提供 asm_driver_*（fmt/check/test 仅 bootstrap-driver-seed / shux-x 全驱动链需要 DRIVER_SUBCMD_OBJS）
shux-x-pipeline: bootstrap-pipeline migrate-x-objs $(PIPELINE_X_BASE_OBJS) pipeline_x.o $(PIPELINE_X_FRONTEND_OBJS) $(PIPELINE_X_SUPPORT_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes.o
	@# gen_driver 副本可能缺 pipeline_asm_block_*；与 bootstrap-driver-seed 一致强制从 pipeline_gen.c 重编。
	@$(MAKE) pipeline_x.o PIPELINE_X_FORCE_COMPILE=1
	@$(MAKE) migrate-x-objs $(PIPELINE_X_SATELLITE_OBJS) build-seed-asm-host
	@$(MAKE) -B src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o
	$(CC) $(CFLAGS) -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN -o $(TARGET)_x $(PIPELINE_X_BASE_OBJS) pipeline_x.o $(PIPELINE_X_FRONTEND_OBJS) $(PIPELINE_X_LINK_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes.o $(PIPELINE_LIBS)
	@echo "shux_x built; use ./shux_x -x -E <file.x> to test .x pipeline"

# 4.5（.x 流水线编译 compiler 自身）：用 shux_x 的 -x -E 生成 typeck.x / codegen.x 对应的 C，再由 cc 链接得到新的 shux_x_stage2。
# 这一目标的目的，是验证「完整前端（parse_into + typeck_x_ast + codegen_x_ast）」全部跑在 .x 上时，仍能产出能工作的编译器。
bootstrap-x-compiler: shux-x-pipeline
	./$(TARGET)_x -x -E src/typeck/typeck.x > typeck_x_x.c
	./$(TARGET)_x -x -E src/codegen/codegen.x > codegen_x_x.c
	$(CC) $(CFLAGS) -c typeck_x_x.c -o typeck_x_x.o
	$(CC) $(CFLAGS) -c codegen_x_x.c -o codegen_x_x.o
	$(CC) $(CFLAGS) -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN -o $(TARGET)_x_stage2 $(OBJS) typeck_x_x.o codegen_x_x.o
	@echo "bootstrap-x-compiler OK (.x 流水线生成 typeck/codegen C 并链接 shux_x_stage2)"

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

# 7.3 默认：B-strict / shux_asm 主路径；-x -E 全模块仍见 bootstrap-verify-seed + verify-selfhost-stage2。
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

# core.slice：语言限制 C 桩（G-01 core 零 C；G-02e-17：.inc + cc_inc_tu）。
../core/slice/slice.o: src/asm/runtime_slice_glue.inc scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh src/asm/runtime_slice_glue.inc $@
