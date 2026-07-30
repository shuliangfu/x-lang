# Xlang 编译器（compiler）构建
#
# 【G-05 日常入口】优先仓库根 ./xlang-build.sh build 或本目录 ./build_tool ./xlang
# → scripts/g05_build_xlang_asm.sh → g05_prepare_and_relink（纯 shell，零 make；FULL=1 → bstrict）
# 【本 Makefile】冷启动单文件 .o 规则、CI 历史目标、test/bootstrap-* — 兜底（非用户日常入口）。
# 【build-tool】默认 copy seeds/build_*_gen.c 链出 build_tool（不依赖已删 C 前端 -E-extern）。
#
# 阶段 1：main + lexer，产出 xlang；阶段 8：可选 OPT=1 为 xlang 启用 -O2
#
# 【生成 C 后无补丁】-E 产出 pipeline_gen.c / driver_gen.c 后不再做 sed/awk/perl/echo 后处理。
# pipeline_gen.c：包装/size/debug 由 runtime.c 在 -E 且入口为 pipeline.x 时追加 pipeline_glue.c 到 stdout。

# Host C compiler default.
# PLATFORM: SHARED — POSIX toolchains provide `cc`; MinGW-w64 on Windows often
# ships only `gcc` (no `cc` alias). `CC ?= cc` alone breaks ensure/seed recipes
# that invoke $(CC) / scripts defaulting to cc. Override still wins: make CC=clang.
ifeq ($(OS),Windows_NT)
CC ?= gcc
else
# MSYS/MinGW shells sometimes leave OS unset; detect via uname.
_UNAME_S_CC := $(shell uname -s 2>/dev/null)
ifneq (,$(filter MINGW% MSYS% CYGWIN%,$(_UNAME_S_CC)))
CC ?= gcc
else
CC ?= cc
endif
endif

# wave884 B7B residual: drop single-token CC="$(CC)" recipe injects.
# Authority: scripts/resolve_host_cc.sh when CC unset; make CLI CC= auto-exports;
# parent env CC honored. NOT physical delete — thin edges + B2 remain.
# wave888 B7B residual: pure @bash scripts/… thin-call form (drop dual chmod +x;
# drop @./scripts/ and sh ./… recipe forms). COUNT=22 recipe sites. Authority:
# bash invokes script path (no recipe chmod). NOT physical delete — thin edges
# + B2 + mk lists remain.
# PLATFORM: SHARED — mac/Linux cc default; Windows/MinGW gcc via resolve.
CFLAGS ?= -Wall -Wextra -I. -Iinclude -Isrc
# Windows/MinGW: __attribute__((weak)) 函数符号不被 PE 格式支持，
# 所有 weak 函数在 stub 文件中变为正常定义；用 --allow-multiple-definition 解决重复定义冲突。
ifeq ($(OS),Windows_NT)
# PLATFORM: WINDOWS — PE link flags for non-bootstrap targets (see MAIN_LINK_FLAGS
#            for bootstrap-driver-seed stack reserve).
#   --allow-multiple-definition: XLANG_WEAK expands to empty on PE, so weak stub
#     .o files become strong defs; FIRST in link order wins. Required to resolve
#     duplicate symbol conflicts between stubs and real implementations.
WIN_LDFLAGS = -Wl,--allow-multiple-definition
# Why: On MSYS Git Bash, make auto-detects SHELL = "C:/Program Files/Git/usr/bin/sh.exe"
#      (path with embedded space) but fails to quote it, so the sh invocation
#      becomes "C:/Program" + args and every recipe aborts with
#      "bash: C:\Program: No such file or directory". Forcing SHELL := sh
#      makes make PATH-search sh, resolving to MSYS /usr/bin/sh (no spaces).
# Invariant: SHELL := sh relies on MSYS Git Bash having sh in PATH (default
#            install). Safe: only triggered on Windows_NT; macOS/Linux use
#            system /bin/sh via PATH lookup.
# PLATFORM: WINDOWS | MSYS | MINGW (SHELL override); no-op elsewhere.
SHELL := sh
# Why: MSYS Git Bash ships /usr/local/bin/python3 as a 2-line shim
#      (#!/usr/bin/env bash; exec python "$@"). env's PATH-search for bash
#      resolves to "C:/Program Files/Git/usr/bin/bash.exe" (path with space),
#      and env invokes it unquoted — bash sees "C:\Program" as the command
#      name and aborts with "bash: C:\Program: No such file or directory".
#      Direct `python` resolves via PATH to "/c/Program Files/Python312/python"
#      (also has a space), but bash's PATH lookup handles spaces correctly
#      (unlike env's execve via the shim). On macOS/Linux `python3` is the
#      canonical name and is used unchanged.
# Invariant: PYTHON := python only on Windows_NT; verified that
#            `python --version` returns Python 3.12.x on Windows MSYS.
# PLATFORM: WINDOWS | MSYS | MINGW (PYTHON override); no-op elsewhere.
PYTHON := python
else
WIN_LDFLAGS =
PYTHON := python3
endif
# 仅编译 pipeline_gen.c / driver_gen.c 等生成代码时加：静默已知警告，使 bootstrap-driver 整次 0 警告
# GCC 不识别 -Wno-logical-op-parentheses / -Wno-bitwise-op-parentheses / -Wno-incompatible-pointer-types-discards-qualifiers，会出 cc1 note；仅 Clang 追加
PIPELINE_GEN_CFLAGS_BASE = -Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits
# PLATFORM: MACOS/CLANG — Apple Clang treats -Wparentheses-equality as distinct from
# -Wparentheses; without -Wno-parentheses-equality, -E-extern gen C (cfg_eval/typeck/…)
# hard-fails under -Werror and silently falls back to bootstrap stubs (false Cap residual).
# PLATFORM: LINUX/GCC — -Wno-parentheses in BASE is usually enough; extra flag is no-op.
PIPELINE_GEN_CFLAGS_CLANG = -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses -Wno-incompatible-pointer-types-discards-qualifiers -Wno-parentheses-equality
CC_IS_CLANG := $(findstring clang,$(shell $(CC) -v 2>&1))
PIPELINE_GEN_CFLAGS = $(PIPELINE_GEN_CFLAGS_BASE) $(if $(CC_IS_CLANG),$(PIPELINE_GEN_CFLAGS_CLANG))
# 阶段 8：make OPT=1 时为 xlang 启用 -O2，便于开发时快速运行测试
ifeq ($(OPT),1)
  CFLAGS += -O2
endif
# 宿主 OS/架构（runtime_panic / freestanding / crt0 规则共用）
UNAME_S := $(shell uname -s 2>/dev/null || echo Unknown)
UNAME_M := $(shell uname -m 2>/dev/null || echo unknown)
# Product pin seeds (*.linux.x86_64.c) are host-portable generated C (not machine code).
# Cold start on Darwin/Windows must fall back to these when local -E fails (old bootstrap_xlangc
# typeck/unsafe lag). Historically gated to Linux host only → mac cold bootstrap-driver-seed red.
SEED_LINUX_X86_64_OK := 0
ifneq ($(wildcard seeds/parser_gen.linux.x86_64.c),)
  SEED_LINUX_X86_64_OK := 1
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
# filtered .o 符号导出：macOS 用 -exported_symbols_list，GNU ld 用 --version-script
ifeq ($(UNAME_S),Darwin)
  LD_FILTER_EXPORT = -exported_symbols_list
  LD_FILTER_USE_VER = 0
else
  LD_FILTER_EXPORT = --version-script
  LD_FILTER_USE_VER = 1
endif
TARGET = xlang
# wave823 B7B: SRCS / MAIN_X_DEPS / PREPROCESS_X_DEPS / PIPELINE_*_DEPS →
# mk/x_source_deps.mk (G.7; not physical delete). Makefile include only.
# Include early so $(PIPELINE_X_DEPS) is non-empty before pipeline_x.o rules.
include mk/x_source_deps.mk
# wave824 B7B: MAIN_X_E_DIRS / LSP_X_E_DIRS / PIPELINE_X_E_DIRS →
# mk/x_e_dirs.mk (G.7; not physical delete). Makefile include only.
# Include early with source-deps so gen thin leaves expand non-empty -L roots.
include mk/x_e_dirs.mk
# wave820 B7B: OBJS_CORE / OBJS archaeology list → mk/objs_core.mk (G.7; not physical delete).
# Makefile include only; product make xlang is g05 (wave786); escape XLANG_HOST_CC_OBJS_CORE=1.
include mk/objs_core.mk

# wave894: formal_mod product edge inventory (make-graph only; body = ensure catalog).
include mk/formal_mod_product_objs.mk
# wave895: std_x product edge inventory (make-graph only; body = ensure catalog).
include mk/std_x_product_objs.mk
# wave896: driver_leaf product edge inventory (make-graph only; body = ensure catalog).
include mk/driver_leaf_product_objs.mk
# wave897: B2 std/core hybrid product edge inventory (make-graph only; body = try-heat).
include mk/std_core_hybrid_product_objs.mk
# 注：lsp.x 生成的 lsp_gen 与 lsp_diag 中 lsp_build_* 同名；若把 InitializeResult/response 外壳迁入 .x，
# 默认 xlang 须链 lsp_x.o、lsp_io_x.o；F-03 v2/v3 std.io 由 .x codegen 提供，无 io.o。

# C 仅版 xlang：无 main_x/pipeline_x，供 bootstrap-pipeline 用 -E 生成 pipeline_gen.c（避免用已链 main_x 的 $(TARGET) 导致走 .x 路径失败）
XLANG_C = xlang-c
# bootstrap-driver-seed 末尾 `cp $(TARGET)` 得到；不作为 lsp_*_gen.c / driver_gen / preprocess_gen 的 Makefile 前置（否则与 seed 依赖环）。
# -E/-E-extern 生成时在 recipe 内 `test -f xlang-x`：冷启动仅用 xlang-c；二次构建起用 xlang-x（pipeline+codegen.x），使 LSP 生成 C 与 codegen.x 的自动 extern 一致。
XLANG_X = xlang-x
# MAIN/LSP/PIPELINE_X_E_DIRS: list authority mk/x_e_dirs.mk (wave824).
# MAIN_X_DEPS / PREPROCESS_X_DEPS: list authority mk/x_source_deps.mk (wave823).
.PHONY: all std-objs clean test size-baseline perf-baseline bootstrap-token bootstrap-lexer bootstrap-parser bootstrap-parse-file bootstrap-typeck bootstrap-codegen bootstrap-driver bootstrap-driver-seed bootstrap-driver-bstrict bootstrap-driver-bstrict-relink bootstrap-driver-bstrict-windows bootstrap-driver-crt0 bootstrap-driver-asm bootstrap-driver-asm-only bootstrap-asm bootstrap_xlangc check-asm-o-quality check-6.4 bootstrap-self check-7.2 check-7.2-bstrict bootstrap-verify bootstrap-verify-seed bootstrap-verify-bstrict bootstrap-verify-stage2 bootstrap-verify-stage2-bstrict bootstrap-test build-tool build-tool-x build-via-tool first-time verify-selfhost-stage2 regen-lsp-gens-x xlang-no-c-frontend gen-x-driver-objs build-user-asm-backend build-seed-user-asm-partial bootstrap-driver-seed-user-asm compile_commands.json


# ---------------------------------------------------------------------------
# wave894 B7B: formal_mod product edges list→mk + multi-target FORCE thin ensure
# G.7: list authority = mk/formal_mod_product_objs.mk (COUNT=38).
# Body authority = scripts/xlang_compile_std_module.sh ensure (wave812 catalog;
# wave826 shell owns source mtime). Makefile only FORCE + thin-call.
# PLATFORM: SHARED — not physical delete; residual thin edges + B2 try-heat +
# other mk lists hybrid + tip Windows → dual L4 → explicit auth ship delete.
# ---------------------------------------------------------------------------
$(FORMAL_MOD_PRODUCT_OBJS): FORCE scripts/xlang_compile_std_module.sh
	@bash scripts/xlang_compile_std_module.sh ensure $@

# ---------------------------------------------------------------------------
# wave895 B7B: std_x product edges list→mk + multi-target FORCE thin ensure
# G.7: list authority = mk/std_x_product_objs.mk (COUNT=22).
# Body authority = scripts/xlang_compile_std_x.sh ensure (wave825 catalog;
# wave827 shell owns source mtime). Makefile only FORCE + thin-call.
# PLATFORM: SHARED — not physical delete; residual thin edges + B2 try-heat +
# other mk lists hybrid + tip Windows → dual L4 → explicit auth ship delete.
# ---------------------------------------------------------------------------
$(STD_X_PRODUCT_OBJS): FORCE scripts/xlang_compile_std_x.sh
	@bash scripts/xlang_compile_std_x.sh ensure $@

# ---------------------------------------------------------------------------
# wave896 B7B: driver_leaf product edges list→mk + multi-target FORCE thin ensure
# G.7: list authority = mk/driver_leaf_product_objs.mk (COUNT=8).
# Body authority = scripts/driver_leaf_x_to_o.sh ensure (wave814 catalog;
# wave828 shell owns source mtime; wave860 BASE_CFLAGS export leaf).
# Makefile only FORCE + thin-call. DRIVER_SUBCMD_OBJS (wave816) remains seed
# link prereq set (7 leaves) — distinct from this ensure-catalog multi-target.
# PLATFORM: SHARED — not physical delete; residual thin edges + B2 try-heat +
# other mk lists hybrid + tip Windows → dual L4 → explicit auth ship delete.
# ---------------------------------------------------------------------------
$(DRIVER_LEAF_PRODUCT_OBJS): FORCE scripts/driver_leaf_x_to_o.sh
	@bash scripts/driver_leaf_x_to_o.sh ensure $@





# ---------------------------------------------------------------------------
# wave897 B7B: B2 std/core hybrid product edges list→mk multi-target FORCE thin
# G.7: list authority = mk/std_core_hybrid_product_objs.mk (COUNT=5).
# Body authority = scripts/ensure_host_cc_seed_o.sh try-heat → try-std-core-prefer
# (wave780 B2 table; wave790 heat unify; wave794–796 FORCE dep-thin mtime).
# Leaves: process (process_merge) · path (direct) · runtime (direct) · net (net_merge)
# · core/slice/slice.o (direct; distinct from formal_mod core/slice/mod.o).
# Archaeology (not dual recipe authority):
#   process.o — process_*_c argv/OS glue only; user API co-emitted from mod.x.
#   path.o / runtime.o — R2 DIRECT pure compute / thin panic wrappers.
#   net.o — mod.x + sub .x + five runtime_net_*_fast; PLATFORM: MACOS force xlang-c.
#   slice.o — runtime_slice_glue pure compute (from_ptr/subslice).
# Makefile only FORCE + thin-call try-heat. NOT physical delete — thin edges +
# remaining mk lists hybrid + tip Windows → dual L4 → explicit auth ship delete.
# wave881 B7B: try-heat PREFER inject hygiene — no XLANG_G05_PREFER_X_O / XLANG=
# recipe inject (COUNT=31 family; prefer via make CLI/env or shell default).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(STD_CORE_HYBRID_PRODUCT_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave815: archaeology host-pick phonies → scripts/archaeology_host_pick_phony.sh
# (G.7; not physical delete). Makefile thin-call ensure only; host pick + TLS/sqlite
# merge body live in the shell catalog. Nested product .o still via make try-heat.
# wave839: FORCE dep-thin — drop script-only prereq residual; FORCE + script only
# (G.7 有则补全). Shell owns host pick / TLS-sqlite merge; FORCE always re-enters
# (matches product leaf pattern; never make-skipped by stale script mtimes alone).
# wave867 B7B: drop multi-token LD_R_MULTIDEF_FLAGS inject (G.7 hygiene).
# Shell arch_ld_r_multidef_flags() owns host uname default when env unset
# (Darwin -multiply_defined suppress / else --allow-multiple-definition).
# wave883 B7B: drop single-token MAKE= inject (G.7 hygiene).
# Shell MAKE="${MAKE:-make}" + GNU make auto-exports MAKE to recipe env.
# Optional LD_R_MULTIDEF_FLAGS still accepted by shell when caller sets it.
# NOT physical delete — thin edges + B2 remain.
# PLATFORM: SHARED — FORCE always invokes ensure; bash for Ubuntu dash.
net-o-stub: FORCE scripts/archaeology_host_pick_phony.sh
	@bash scripts/archaeology_host_pick_phony.sh ensure $@

# TLS：F-04 v8 net-o-openssl 编译 std/net/tls_openssl.x（不再 #include tls_openssl.inc.c）。
net-o-openssl: FORCE scripts/archaeology_host_pick_phony.sh
	@bash scripts/archaeology_host_pick_phony.sh ensure $@

net-o-mbedtls: FORCE scripts/archaeology_host_pick_phony.sh
	@bash scripts/archaeology_host_pick_phony.sh ensure $@

# std.thread：mod.x 提供 std_thread_* 包装；pthread 胶层在 runtime_thread_glue.o（thread_*_c）。
# 【Why 勿只编 thread.x】thread.x 仅 marker，link_only 时缺 _std_thread_create 等。
# std.async：F-async v2 纯 .x（F-ZC）；调度胶层在 runtime_scheduler_glue.o；Unix 按需 -pthread。

# std.async：F-async-future v2 纯 .x → future.o（同 hash/cache）。

# std.time：F 闭合 — mod.x 内联派生函数（now_monotonic_us/sleep_ms/duration_ns 等），
# 仅 5 个基础 OS extern 由 runtime_time_os.o 提供。无需 time.x / time_import_alias.c。
# std.random：F 闭合 — mod.x（用户 API）+ random.x（impl 裸符号）用 -E-extern 编译；
# CSPRNG OS 在 runtime_random_fill.o，最终 exe 链接时按需推入。
# std.env：product surface = mod.x (std_env_getenv/…); OS glue in runtime_env_os.o.
# PLATFORM: SHARED — do NOT compile only env.x (std_env_env_* / missing std_env_*);
# asm fk0 pulls formal env.o; wrong authority → Ubuntu BLD001 (tests/env).
# env.x is helpers (parse_kv / platform_encoding / no_mangle args_iter), not product API.
# std.fs：F-03 pure .x — formal .o for -backend asm (co-emit of std.fs is skipped).
# PLATFORM: SHARED — product authority remains mod.x+posix via import; vehicle is
# compile driver only (user -o KEEP_C path). Do NOT compile mod.x as entry on Linux
# (libc name collisions / posix_fadvise order). Wrong/missing → U std_fs_invalid.
# std.sync：F 闭合 — mod.x（用户 API）+ sync.x（impl 裸符号）用 -E-extern 编译；
# OS/TLS 胶层在 runtime_sync_*.o，最终 exe 链接时按需推入。
# std.queue：F 闭合 — mod.x 用户 API（Queue_i32/u8）；queue.x 为 F-queue marker。
# pthread 胶层在 runtime_queue_contention.o（链接按需）。
# std.encoding：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + encoding）。
# std.base64：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + base64）。
# std.crypto：F-闭合 — mod.x + 5 .x 用 -E-extern 编译（裸符号）。
# mod.x 提供 extern 声明 + 公共 API；core/aes_gcm/chacha20_*/ed25519.x 提供裸符号实现。
# std.log：F-闭合 — mod.x + log.x 用 -E-extern 编译（裸符号）。
# mod.x 提供 extern 声明 + 公共 API；log.x 提供 log_write_c 等裸符号实现。

# std.test：F 闭合 — mod.x（用户 API）+ test.x（impl 裸符号）用 -E-extern 编译；
# fn-ptr 在 runtime_test_fn_invoke.o，最终 exe 链接时按需推入。
# std.atomic：F 闭合 — mod.x（用户 API）+ atomic.x（impl 裸符号）用 -E-extern 编译；
# 原子胶层在 runtime_atomic_glue.o，最终 exe 链接时按需推入。
# std.channel：F-channel v2 纯 .x（F-ZC）；channel 胶层在 runtime_channel_glue.o；Unix 需 -lpthread。

# std.backtrace：F-backtrace v2 纯 .x（F-ZC）；平台胶层在 runtime_backtrace_platform.o。

# std.hash：F 闭合 — mod.x（用户 API）+ hash.x（impl 裸符号）用 -E-extern 编译。
# std.math：F-math v2 纯 .x（F-ZC）；libm 胶层在 runtime_math_libm.o（链接 exe 仍须 -lm）。
# PLATFORM: SHARED — 权威 = mod.x (std_math_* API) + math.x (bare math_*_c constants)
# via xlang_compile_std_module --bare-impl. Do NOT compile only math.x (missing std_math_*).
# Ban old xlang-c -E double-prefix stale path.
# std.sort：F-sort v1 — product surface = mod.x (std_sort_sort_*) + sort.x impl.
# PLATFORM: SHARED — do NOT compile only sort.x (bare sort_* / missing std_sort_sort_*);
# asm fk0 pulls formal sort.o; wrong authority → Ubuntu BLD001 (tests/sort).
# Import binding (not --bare-impl): sort.x path prefix → std_sort_sort_sort_qsort_*.
# G-01：core/ 零 C — 位运算/volatile/slice 已纯 .x（见 analysis/phase-g-full-selfhost-tasks-v1.md）

# std.ffi：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + ffi）。

# std.context：F-闭合 — mod.x + context.x 用 -E-extern 编译（裸符号）。
# mod.x 提供 is_cancelled/deadline_ns/remaining_ns 等公共 API；context.x 提供 ctx_*_c 实现。
# std.error：F-闭合 — mod.x 用 -E-extern 编译。提供 http_err_cancelled/timeout 等错误码 API。

# std.datetime：F-datetime v2 + F-ZC 纯 datetime.x → datetime.o（无 glue；无 xlang 时 exit 0）。

# std.uuid：F-uuid v1 纯 .x（uuid.x）；依赖 random.o + time.o。

# std.url：F-url v2 + F-ZC 纯 url.x → url.o（无 glue；无 xlang 时 exit 0）。

# std.cli：命令行解析（std/cli/cli.c）。
# std.cli：F-cli v1 纯 .x（cli.x）；零胶层 C。


# std.security：F-security v1 + F-ZC 纯 security.x → security.o（无 glue；无 xlang 时 exit 0）。


# std.config：F-config v2 + F-ZC 纯 config.x → config.o（无 glue；无 xlang 时 exit 0）。

# std.cache：F-cache v2 纯 .x（cache.x）；零胶层 C。

# std.trace：F-trace v2 纯 trace.x → trace.o（无 glue；无 xlang 时 exit 0）。


# std.task：F-task v2 纯 .x → task.o（同 trace/cache v2）。


# std.schema：F-schema v2 纯 .x → schema.o（同 cache/encoding）。

# std.db.kv：F-05 v2 纯 .x（F-ZC）；mmap 胶层在 runtime_kv_mmap_glue.o。

# std.db.arrow：F-05 v1 纯 .x（F-ZC）；SIMD 胶层在 runtime_arrow_simd_glue.o。

# std.sys.mmap：F-02 v1 Linux/macOS 纯 .x（已移除 mmap.inc.c）
# std.sys.win32：F-02 v2 纯 .x kernel32 FFI（已移除 win32.inc.c / win32_net.inc.c）

# E-04 v21：Windows/MinGW/MSYS 宿主探测（MAIN_LINK_O=crt0_mingw.o）
XLANG_IS_WIN_HOST :=
ifeq ($(OS),Windows_NT)
XLANG_IS_WIN_HOST := 1
else
ifneq ($(findstring MINGW,$(UNAME_S)),)
XLANG_IS_WIN_HOST := 1
else
ifneq ($(findstring MSYS,$(UNAME_S)),)
XLANG_IS_WIN_HOST := 1
endif
endif
endif

# std.db.sqlite：F-05 v3 纯 .x（F-ZC）；sqlite3 胶层在 runtime_sqlite_glue.o。
sqlite-o: ../std/db/sqlite/sqlite.o runtime_sqlite_glue.o
# wave815: archaeology host-pick phony → shell catalog (G.7; not physical delete).
# wave839: FORCE dep-thin — FORCE + archaeology_host_pick_phony only (G.7 有则补全).
# wave867 B7B: drop multi-token LD_R_MULTIDEF_FLAGS inject (G.7 hygiene; same as net-o-*).
# wave883 B7B: drop single-token MAKE= inject (shell MAKE default + make auto-export).
# PLATFORM: SHARED — FORCE always invokes ensure; bash for Ubuntu dash.
sqlite-o-stub: FORCE scripts/archaeology_host_pick_phony.sh
	@bash scripts/archaeology_host_pick_phony.sh ensure $@

# std.elf：F-elf v2 + F-ZC 纯 elf.x → elf.o（无 glue；无 xlang 时 exit 0）。

# P4 std 模块（按需链接）
# std.json：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + json）。
# F-04 v7：std.compress 全格式已迁 .x；compress.o 不再构建，保留 target 名兼容门禁。
compress-o-zlib compress-o-zlib-zstd compress-o-brotli compress-o-zlib-zstd-brotli:
	@true
# std.unicode：F-unicode v2 纯 .x → unicode.o（同 hash/schema）。
# std.dynlib：F 闭合 — mod.x（用户 API）+ dynlib.x（impl 裸符号）用 -E-extern 编译；
# dlopen 胶层在 runtime_dynlib_os.o，最终 exe 链接时按需推入。
# std.socketio：F-socketio v2 纯 socketio.x；ld -r 合并为 socketio.o（P3 可选）。
# std.tar：F-tar v2 纯 tar.x；import binding 别名桩 tar_import_alias.c。
# std.tar：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + tar）。


# 测试与 xlang 链接 std 时依赖的 .o：所有 std 模块 + runtime_panic.o；Linux 另预编 freestanding 链入桩
# wave813 B7B: list authority → mk/std_and_panic_objs.mk (G.7; not physical delete).
# Makefile keeps include + consumers (std-objs / test_c / bootstrap-*); no dual list.
include mk/std_and_panic_objs.mk


# 同时链出 xlang-c：与 pipeline/lsp/build_gen 的 -E 生成及 test_c 前置一致，避免仅 make all 后缺少 xlang-c。
# XLANG_RUN_ALL_BOOTSTRAP_XLANG=1：run-all 显式 XLANG=seed 时子脚本须保持 bootstrap 链，禁止 C-only all 覆盖 xlang。
# 默认 all 不构建 STD_AND_PANIC_O（xlang-c 无 -backend 解析；按需 `make std-objs` 或单条 ../std/*/*.o）。
# wave784: B6 R5 CI / compiler-all body → scripts/compiler_all_ci.sh (thin-call only).
# Policy/sequence shell-owned; leaf .o + link still make graph (B7). NOT physical delete.
# wave880 B7B: drop multi-token OPT/MAKE/TARGET/XLANG_*/SKIP inject (G.7 hygiene).
# Shell owns OPT (MAKELEVEL bare make → empty; direct CI → 1) + MAKE/TARGET/XLANG_C.
# Process env / make OPT=1 still honored (GNU make exports cmdline vars).
# PLATFORM: SHARED — orchestration in shell; leaf recipes keep platform ABI.
.PHONY: all
all:
	@bash scripts/compiler_all_ci.sh

std-objs: $(STD_AND_PANIC_O)

# wave786 B7D: host-cc product `xlang` link = g05 authority (G.7 有则补全).
# Before: $(TARGET): $(OBJS) with OBJS_CORE only → UNDEF (parser/typeck/pipeline missing).
# Product list + pure-ld live in g05_relink_env / g05_relink_xlang; do NOT re-list .o here.
# PLATFORM: SHARED — same g05 path on mac/Ubuntu/Windows host (Windows LEGACY env still via g05).
# Escape (archaeology only): XLANG_HOST_CC_OBJS_CORE=1 restores incomplete OBJS_CORE link
# (expect UNDEF residual; not product). Cold tree without product .o: run bootstrap-driver-seed first.
# wave891 B7B residual: bare `$(CC) $(CFLAGS) -o $@ $^ $(WIN_LDFLAGS)` → shell-primary
#   scripts/host_cc_objs_core_link.sh (G.7 有则补全 wave858 legacy link form).
#   LINK_OBJS via export-objs-core-link-objs; CFLAGS via export-try-heat-cflags;
#   WIN_LDFLAGS shell uname. Thin @bash only. NOT physical delete — thin edges + B2 + mk lists.
# PLATFORM: SHARED — archaeology host-cc; WIN_LDFLAGS is WINDOWS|PE only inside shell.
ifeq ($(XLANG_HOST_CC_OBJS_CORE),1)
$(TARGET): $(OBJS)
	@bash scripts/host_cc_objs_core_link.sh
else
.PHONY: $(TARGET)
$(TARGET):
	@bash scripts/g05_prepare_and_relink.sh
endif

# G-06：默认 xlang-c = bootstrap_xlangc 预编译种子（无 cc 编 OBJS_CORE）；考古：XLANG_LEGACY_C_FRONTEND=1。
# wave838: FORCE dep-thin — drop bootstrap_xlangc_create.sh make-graph edge (select
# invokes create only when needed). Prereqs FORCE + select only; shell owns host
# seed pick / can_run skip / pin copy. Already .PHONY; FORCE matches product leaf
# pattern so recipe is never make-skipped by stale script mtimes alone.
# PLATFORM: SHARED — FORCE always invokes select (cheap can_run); bash for Ubuntu dash.
# wave888 B7B residual: pure @bash thin-call (drop dual chmod +x; bash invokes script).
# NOT physical delete — thin edges + B2 + mk lists remain.
bootstrap_xlangc: FORCE scripts/select_bootstrap_xlangc.sh
	@bash scripts/select_bootstrap_xlangc.sh

ifeq ($(XLANG_LEGACY_C_FRONTEND),1)
# G-02a: lexer.o / ast.o (LEGACY runtime_*_glue seeds) — joined wave900 multi-target
# $(R1_FRONTEND_GLUE_OBJS). Basename-mismatch map lives in ensure frontend-glue mode.

# G-02a: typeck.c 已物理删除；typeck.o 由 typeck.x 生成（typeck_x.o），C 编排由 typeck_c_module_stubs.o 提供。

# G-02a: codegen.c 已物理删除；codegen_x.o 由 codegen.x 生成，codegen_pipeline_stubs.o 提供 weak 桩。

else
# Default product xlang-c = sync copy of bootstrap_xlangc (G-06 seed).
# XLANG_SKIP_SUBSCRIPT_MAKE=1 skips cp: run-all may build real C frontend first;
# overwriting would break that path. bootstrap_xlangc prereq still runs select.
# wave876: full body → scripts/ensure_xlang_c.sh (G.7 无才新增; shell owns
#   SKIP_SUBSCRIPT soft-skip + cp -f bootstrap_xlangc → XLANG_C).
# LEGACY host-cc path stays wave858 legacy_xlang_c_link.sh (separate ifeq).
# wave887 B7B: drop XLANG_C= recipe inject — shell ensure OUT=$@ (or XLANG_C env/CLI).
# Thin @bash only. NOT physical delete — thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — binary sync only; seed pick stays select_bootstrap_xlangc.
$(XLANG_C): bootstrap_xlangc scripts/ensure_xlang_c.sh
	@bash scripts/ensure_xlang_c.sh ensure $@
endif

# G-02f-11：diag 产品 seed — joined wave899 multi-target $(R1_CORE_SEED_OBJS).

# G-02f-15：lsp_diag 产品 seed — joined wave900 multi-target $(R1_FRONTEND_GLUE_OBJS).
# wave771 archaeology: other L2 PREFER thin+rest → try-other-l2-prefer (body in try-heat).

# `xlang-c` 默认模式可能只是 bootstrap_xlangc 的同步副本；凡是依赖 `-E/-E-extern`
# 生成当前源码对应 C 的目标，必须先强制刷新一次 legacy C frontend，避免继续吃旧语义。
# wave889 B7B residual: drop nested $(MAKE) $(XLANG_C); thin ensure after
# bootstrap_xlangc prereq (same product path as default $(XLANG_C); G.7 有则补全
# ensure_xlang_c). NOT physical delete — thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — binary sync only; seed pick stays select_bootstrap_xlangc.
.PHONY: legacy-xlang-c-ready
legacy-xlang-c-ready: bootstrap_xlangc scripts/ensure_xlang_c.sh
	@bash scripts/ensure_xlang_c.sh ensure $(XLANG_C)

LEGACY_XLANG_C_READY_TARGETS = build-tool

$(LEGACY_XLANG_C_READY_TARGETS): | legacy-xlang-c-ready

# G-02f-16：main 产品 seed（LEGACY 极简入口）— joined wave901 multi-target
# $(R1_MAIN_RUNTIME_OBJS). Multi-flag variants share seeds (main.from_x / runtime.from_x).

# E-04 v2/v3：argv/target 与 POSIX I/O ABI 薄壳；默认 seed / B-strict 均链入。

# G-02f-12 / Phase 4：runtime_io_abi PREFER_X_O — joined wave906 multi-target $(R3_COLD_SEED_OBJS).
# 5 个 _impl 真迁 .x（read/malloc/memcpy）；4 个保留 seed（mmap/fstat/O_* flags/平台 #ifdef）
# PLATFORM: SHARED 冷链纪律 — 仅 XLANG_G05_PREFER_X_O=1 才 thin（同 simd_enc；见下 runtime_driver_abi）。
# Archaeology: wave757 R3 cold-else + wave763 try-r3-prefer + wave793 FORCE — body in try-heat.

# G-02f-13：runtime_link_abi 产品 seed — joined wave899 multi-target $(R1_CORE_SEED_OBJS).
# wave765 archaeology: labi multi-slice PREFER → try-labi-prefer (cold full seed fallback; body in try-heat).

# G-02f-12 / Phase 4：runtime_driver_abi thin+rest PREFER_X_O — joined wave906 multi-target $(R3_COLD_SEED_OBJS).
# PLATFORM: SHARED 冷链 — bootstrap-driver-seed 传 XLANG_G05_PREFER_X_O=0 必须走 seed。
# 【Why 2026-07-16 铁证】Darwin 冷测：select_bootstrap 先恢复 xlang-c，若仅「有 xlang-c 就 thin」，
# thin 会 emit process_args_count_c → U process_xlang_argc_get，而 phase1 未链 runtime_process_argv.o
# → mac phase1 UNDEF；Ubuntu 上 thin -E/cc 常失败回退 seed 故假绿。须与 simd_enc 同源门控。
# 链闭包：DRIVER_SEED_OBJS 含 runtime_process_argv.o（PREFER=1 时亦须能解析 process_xlang_*）。
# Archaeology: wave757/763 try-r3-prefer · wave793 FORCE — body in try-heat.

# G-02f-12：runtime_pipeline_abi 产品 seed — joined wave903 multi-target $(R1_EXTRA_CFLAGS_OBJS).
# Archaeology: wave753 R1 cold USE_X_PIPELINE · wave767 try-pipeline-abi-prefer · wave794 FORCE
# · wave864 extras_for_extra_cflags / _DEFAULT_RUNTIME_PIPELINE_ABI_CFLAGS — body in try-heat.


# G-02f-22：runtime_c_import 产品 seed — joined wave899 multi-target $(R1_CORE_SEED_OBJS).

# ---------------------------------------------------------------------------
# wave907 · B7B async three product edges multi-target FORCE thin try-heat
# G.7 有则补全: list authority = $(ASYNC_THREE_SEED_OBJS) in mk/driver_seed_r_lists.mk
# (wave770 try-async-prefer table; wave788 list-in-mk family; no second .o list).
# Body authority = scripts/ensure_host_cc_seed_o.sh try-heat
# (wave770/790/792/793; PREFER full.x+rest ladder lives in try-heat → try-async-prefer).
# Leaves: async_liveness · async_cps_codegen · async_asm_pool.
# Archaeology: G-02f-18 independent TU · R2 unbundle async_asm_pool from glue ·
# wave792/793 FORCE dep-thin — body in try-heat.
# Makefile only FORCE + thin-call. NOT physical delete — thin edges + remaining
# mk lists hybrid (B1 runtime OS / gen-x / …) + tip Windows → dual L4 → explicit auth.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(ASYNC_THREE_SEED_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-12 / Phase 4：runtime_driver_diagnostic — joined wave906 multi-target $(R3_COLD_SEED_OBJS).
# PLATFORM: SHARED 冷链 — 仅 XLANG_G05_PREFER_X_O=1 才 thin（同 simd_enc / runtime_driver_abi）。
# Archaeology: wave757/763 try-r3-prefer · wave793 FORCE — body in try-heat.

# 6.3：runtime.c 提供 run_compiler_c 与弱符号 main_entry；带 .x 入口时用 runtime_driver.o（含 driver_*/pipeline_*）
# G-02f-14：runtime 产品 seed（多变体）— joined wave901 multi-target $(R1_MAIN_RUNTIME_OBJS).
# Makefile 为 prerequisite：编译宏（如 XLANG_USE_X_PREPROCESS）变更时须重编，否则 runtime_driver.o 缺 preprocess() 导致链接 Undefined _preprocess。
# XLANG_ASM_USE_COMPILER_IMPL_C：driver_run_compiler_full 走 impl_c（parse_argv+post_parse），避免 compile.x X emit 路径 silent fail（与 B-strict xlang_asm 同）。
# E-03 v2：XLANG_LEGACY_PREPROCESS_C=1 时 runtime preprocess() 仍调 C preprocess_c_fallback。
# PLATFORM: SHARED — RUNTIME_DRIVER_CFLAGS compiles src/runtime_driver.o (LEGACY mode link unit).
#   G-02a: C frontend (typeck.c/parser.c/preprocess.c/codegen.c) physically deleted; only
#   XLANG_WEAK stubs in runtime_driver_strict_glue_stubs.from_x.c remain (parse/typeck_module
#   return -1). LEGACY mode MUST define XLANG_NO_C_FRONTEND to match RUNTIME_DRIVER_NO_C_CFLAGS,
#   otherwise #if !defined(XLANG_NO_C_FRONTEND) blocks (e.g. driver_run_asm_backend L4320 C typeck
#   precheck) get compiled in and call stub parse() → return -1 → exit=1 on Windows.
#   Why LEGACY still exists: Windows MSYS has no pinned seed; needs runtime_driver.o (not
#   runtime_driver_no_c.o) for the xlang-c standalone build recipe (L2486-2490). But the .o
#   content is now identical to no_c — only the link target name differs.
#   Invariant: RUNTIME_DRIVER_CFLAGS and RUNTIME_DRIVER_NO_C_CFLAGS keep the same XLANG_NO_C_FRONTEND
#              gate; only XLANG_USE_X_TYPECK/XLANG_USE_X_CODEGEN differ (LEGACY omits them because
#              DRIVER_SEED_LINK_FLAGS already defines them at link time for all .o units).
RUNTIME_DRIVER_CFLAGS = -DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_PREPROCESS -DXLANG_NO_C_FRONTEND -DXLANG_ASM_USE_COMPILER_IMPL_C
RUNTIME_DRIVER_NO_C_CFLAGS = -DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_PREPROCESS -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN -DXLANG_NO_C_FRONTEND -DXLANG_ASM_USE_COMPILER_IMPL_C
# Cap residual 数据/符号在 rt_* 切片（g05 同构）：driver_abi 始终 extern 引用；
# 冷启动 bootstrap-driver-seed 必须链 RT_SEED_SLICE_OBJS，runtime 侧开 FROM_X 避免 static 副本漂移。
# parse_diag：runtime_report_parse_recovery_diagnostics 权威在 seeds/rt_parse_diag.from_x.c；
# no_c 仅 U 引用，冷启动/g05 必须链 RT slice（缺则 bootstrap-driver-seed 链失败）。
RUNTIME_DRIVER_RT_SLICE_CFLAGS = -DXLANG_RT_ARENA_BUF_FROM_X -DXLANG_RT_EMIT_STATE_FROM_X -DXLANG_RT_PREAMBLE_FROM_X -DXLANG_RT_STACK_FROM_X -DXLANG_RT_PARSE_DIAG_FROM_X
RUNTIME_DRIVER_CFLAGS += $(RUNTIME_DRIVER_RT_SLICE_CFLAGS)
RUNTIME_DRIVER_NO_C_CFLAGS += $(RUNTIME_DRIVER_RT_SLICE_CFLAGS)
ifeq ($(XLANG_LEGACY_PREPROCESS_C),1)
RUNTIME_DRIVER_CFLAGS += -DXLANG_LEGACY_PREPROCESS_C
RUNTIME_DRIVER_NO_C_CFLAGS += -DXLANG_LEGACY_PREPROCESS_C
endif
# E-04 v32：pipeline_abi 与 driver 同源 X preprocess；LEGACY 时走 preprocess_c_fallback。
RUNTIME_PIPELINE_ABI_CFLAGS = -DXLANG_USE_X_PIPELINE
ifeq ($(XLANG_LEGACY_PREPROCESS_C),1)
RUNTIME_PIPELINE_ABI_CFLAGS += -DXLANG_LEGACY_PREPROCESS_C
endif
# wave751 R1 runtime_driver.o — joined wave901 multi-target $(R1_MAIN_RUNTIME_OBJS).
# Extra flags = ensure extras_for_main_runtime / _DEFAULT_RUNTIME_DRIVER_CFLAGS (wave864).

# G-02f Cap residual slices：driver_abi 跨 TU 数据/thread_fn（arena BSS、emit 扫描槽、preamble 表、stack_esc）。
# 与 g05_ensure 产品路径同源 seed；冷启动 phase1 必须进 DRIVER_SEED_OBJS。
# multi-error recovery 诊断（G-02f-307 / rt_parse_diag）；勿仅靠 no_c 内嵌 merge——冷启动 phase1 须显式链入。
# wave788 B7B: RT / R1 / R3 pure-literal lists → mk/driver_seed_r_lists.mk
# (G.7 single list authority; shell catalog parses the same mk; do not re-assign).
include mk/driver_seed_r_lists.mk

# ---------------------------------------------------------------------------
# wave898 B7B: RT_SEED_SLICE product edges multi-target FORCE thin try-heat
# G.7 有则补全: list authority = RT_SEED_SLICE_OBJS in mk/driver_seed_r_lists.mk
# (wave748 family · wave788 list→mk · COUNT=5). Do NOT open a second .o list.
# Body authority = scripts/ensure_host_cc_seed_o.sh try-heat (wave748/790/792).
# Leaves: rt_arena_buf · rt_emit_state · rt_preamble · rt_stack · rt_parse_diag.
# wave861 B7B: no multi-token CFLAGS -I bag (product -I already in CFLAGS/BASE).
# Makefile only FORCE + thin-call try-heat. NOT physical delete — thin edges +
# remaining R1 family multi-target / mk lists hybrid + tip Windows → dual L4 →
# explicit auth ship delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(RT_SEED_SLICE_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# ---------------------------------------------------------------------------
# wave899 B7B: R1_CORE_SEED product edges multi-target FORCE thin try-heat
# G.7 有则补全: list authority = R1_CORE_SEED_OBJS in mk/driver_seed_r_lists.mk
# (wave749 family · wave788 list→mk · COUNT=5). Do NOT open a second .o list.
# Body authority = scripts/ensure_host_cc_seed_o.sh try-heat (wave749/790/792/793).
# Leaves: diag · runtime_link_abi · runtime_c_import · x_seed_bridge · seed_link_compat.
# PREFER archaeology (wave765 try-labi-prefer · wave771 try-other-l2-prefer) lives in
# try-heat body; Makefile only FORCE + thin-call. NOT physical delete — thin edges +
# remaining R1 family multi-target / mk lists hybrid + tip Windows → dual L4 →
# explicit auth ship delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(R1_CORE_SEED_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# ---------------------------------------------------------------------------
# wave900 B7B: R1_FRONTEND_GLUE product edges multi-target FORCE thin try-heat
# G.7 有则补全: list authority = R1_FRONTEND_GLUE_OBJS in mk/driver_seed_r_lists.mk
# (wave750 family · wave788 list→mk · COUNT=3). Do NOT open a second .o list.
# Body authority = scripts/ensure_host_cc_seed_o.sh try-heat (wave750/790/792/793).
# Leaves: lexer.o · ast.o · lsp_diag.o (basename-mismatch seed map in ensure).
# PREFER archaeology (wave771 try-other-l2-prefer on lsp_diag) lives in try-heat
# body; Makefile only FORCE + thin-call. NOT physical delete — thin edges +
# remaining R1 family multi-target / mk lists hybrid + tip Windows → dual L4 →
# explicit auth ship delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(R1_FRONTEND_GLUE_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# ---------------------------------------------------------------------------
# wave901 B7B: R1_MAIN_RUNTIME product edges multi-target FORCE thin try-heat
# G.7 有则补全: list authority = R1_MAIN_RUNTIME_OBJS in mk/driver_seed_r_lists.mk
# (wave751 family · wave788 list→mk · COUNT=7). Do NOT open a second .o list.
# Body authority = scripts/ensure_host_cc_seed_o.sh try-heat (wave751/790/792/793/794).
# Leaves: main · main_x · main_driver · runtime · runtime_x · runtime_driver ·
# runtime_driver_no_c (shared seeds + multi-flag map in ensure extras_for_main_runtime).
# PREFER archaeology (wave766 try-rt-prefer on runtime_driver_no_c) lives in try-heat
# body; Makefile only FORCE + thin-call. NOT physical delete — thin edges +
# remaining R1 family multi-target / mk lists hybrid + tip Windows → dual L4 →
# explicit auth ship delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(R1_MAIN_RUNTIME_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# ---------------------------------------------------------------------------
# wave902 B7B: R1_ALIAS_STUBS product edges multi-target FORCE thin try-heat
# G.7 有则补全: list authority = R1_ALIAS_STUBS_OBJS in mk/driver_seed_r_lists.mk
# (wave752 family · wave788 list→mk · COUNT=8). Do NOT open a second .o list.
# Body authority = scripts/ensure_host_cc_seed_o.sh try-heat (wave752/790/792/793/794).
# Leaves: x_frontend_link_alias · ast_asm_bare_link_alias · backend_asm_bare_link_alias ·
# backend_asm_strict_fallback_alias · typeck_c_module_stubs · user_asm_seed_bridge ·
# asm_backend_compat_stubs · runtime_driver_strict_glue_stubs (pure basename seeds).
# PREFER archaeology (wave769 try-l2-asm-prefer · wave771 try-other-l2-prefer) lives
# in try-heat body; Makefile only FORCE + thin-call. NOT physical delete — thin edges +
# remaining R1 family multi-target / mk lists hybrid + tip Windows → dual L4 →
# explicit auth ship delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(R1_ALIAS_STUBS_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# ---------------------------------------------------------------------------
# wave903 B7B: R1_EXTRA_CFLAGS product edges multi-target FORCE thin try-heat
# G.7 有则补全: list authority = R1_EXTRA_CFLAGS_OBJS in mk/driver_seed_r_lists.mk
# (wave753 family · wave788 list→mk · COUNT=5). Do NOT open a second .o list.
# Body authority = scripts/ensure_host_cc_seed_o.sh try-heat (wave753/790/791/794/767).
# Leaves: runtime_pipeline_abi · runtime_asm_io_stubs · runtime_sqlite_glue ·
# runtime_sqlite_glue_stub · parser_asm_parse_expr_link (extra flags / multi-out seeds).
# Seed/flag maps (pipeline_abi -D · asm_io -fPIE · sqlite glue+stub · parser -D) live in
# ensure extras_for_extra_cflags; Makefile only FORCE + thin-call. NOT physical delete —
# thin edges + remaining R1 family multi-target (MISC/SEED_MAP/…) / mk lists hybrid +
# tip Windows → dual L4 → explicit auth ship delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(R1_EXTRA_CFLAGS_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# ---------------------------------------------------------------------------
# wave904 B7B: R1_MISC_BASENAME product edges multi-target FORCE thin try-heat
# G.7 有则补全: list authority = R1_MISC_BASENAME_OBJS in mk/driver_seed_r_lists.mk
# (wave754 family · wave788 list→mk · COUNT=9). Do NOT open a second .o list.
# Body authority = scripts/ensure_host_cc_seed_o.sh try-heat (wave754/790/791/792/793/794/767).
# Leaves: runtime_link_abi_user_env · runtime_channel_glue · runtime_scheduler_glue ·
# runtime_kv_mmap_glue · backend_x86_64_enc_c · backend_arm64_enc_c ·
# lsp_diag_pipeline_ctx · pipeline_glue_strict_minimal · runtime_asm_build
# (pure basename host-cc; no special -D/-f extras beyond ensure defaults).
# Seed maps / ldpc prefer / l2-asm prefer live in ensure try-heat ladder; Makefile only
# FORCE + thin-call. NOT physical delete — thin edges + ~~SEED_MAP multi~~ wave905 +
# remaining mk lists hybrid + tip Windows → dual L4 → explicit auth ship delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(R1_MISC_BASENAME_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# ---------------------------------------------------------------------------
# wave905 B7B: R1_SEED_MAP product edges multi-target FORCE thin try-heat
# G.7 有则补全: list authority = R1_SEED_MAP_OBJS in mk/driver_seed_r_lists.mk
# (wave755 family · wave758 thin_glue · wave759 glue_standalone · wave788 list→mk · COUNT=5).
# Do NOT open a second .o list. Body authority = scripts/ensure_host_cc_seed_o.sh try-heat
# (wave755/758/759/768/793/794/797; seed/flag maps + target_cpu prefer in ensure ladder).
# Leaves: target_cpu · ast_seed · pipeline_bootstrap_orchestration · parser_asm_thin_glue ·
# pipeline_glue_standalone (basename-mismatch + orch -D + monothin extras; shell-owned).
# Makefile only FORCE + thin-call. NOT physical delete — thin edges + remaining mk lists hybrid
# + tip Windows → dual L4 → explicit auth ship delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(R1_SEED_MAP_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# ---------------------------------------------------------------------------
# wave906 B7B: R3_COLD product edges multi-target FORCE thin try-heat
# G.7 有则补全: list authority = R3_COLD_SEED_OBJS in mk/driver_seed_r_lists.mk
# (wave757 family · wave763 try-r3-prefer · wave788 list→mk · COUNT=9).
# Do NOT open a second .o list. Body authority = scripts/ensure_host_cc_seed_o.sh try-heat
# (wave757/763/764/790/792/793; PREFER thin+rest ladder lives in try-heat → try-r3-prefer).
# Leaves: runtime_io_abi · runtime_driver_abi · runtime_driver_diagnostic · simd_enc ·
# simd_loop · backend_enc_dispatch · backend_arch_emit_dispatch · backend_try_inline_dispatch ·
# backend_call_dispatch.
# Makefile only FORCE + thin-call. NOT physical delete — thin edges + remaining mk lists hybrid
# (async / B1 runtime OS / gen-x / …) + tip Windows → dual L4 → explicit auth ship delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(R3_COLD_SEED_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02a: preprocess.c 已物理删除；preprocess_for_driver.o 不再编译（XLANG_LEGACY_PREPROCESS_C 路径已死）。
# xlang_x 用：仅 -DXLANG_USE_X_PIPELINE（runtime_x / main_x via wave901 multi-target).

# wave775: non-driver fmt_check_cmd.o → ensure try-other-l2-prefer (fmt_core).
# G.7 有则补全 — same body as driver leaf; leaf_kind=fmt_core omits USE_X_PIPELINE
# (OBJS_CORE / PIPELINE_X satellite: runtime_x has no XLANG_USE_X_DRIVER).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x WEAK + rest FROM_X.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/driver/fmt_check_cmd.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave771: product PREFER → ensure try-other-l2-prefer (thin .x WEAK + rest FROM_X + USE_X_PIPELINE; cold seed).
# PLATFORM: SHARED — product daily path; PREFER=0 cold keeps -DXLANG_USE_X_PIPELINE.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/driver/fmt_check_cmd_driver.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02a：C 前端 lexer/ast/parser/typeck/codegen/preprocess/autovec/lsp_diag 已物理删除；见对应 .x。


# XLANG_NO_C_FRONTEND 实验链接：满足 pipeline 对 codegen_set_* 的引用，无 codegen.c

# G-02-B1：cfg_eval 仅 cfg_eval.x（无 cfg_eval.c 回退）。
# wave98 Cap residual pure: product complex #if must link cfg_eval.x authority
# (lexer_cfg_eval_expr_c + link_alias → cfg_eval_expr_c), NOT bootstrap stub when -E works.
# PIPELINE_GEN_CFLAGS required so Apple Clang -Wparentheses-equality does not kill -E-extern.
# PLATFORM: SHARED — if -E emits illegal C (e.g. dual cfg-host os lit on Darwin),
# ladder falls through to bootstrap stub so L4 cold can finish.
# Deps: link_alias + linux pin gen (Ubuntu gold) + host lit + bootstrap stub seed.
# wave98: do NOT use plain -E — bare -E emits dangling BSS → SEGV on complex #if.
# wave783 B5: multi-ladder body → ensure try-cfg-eval-ladder (G.7; not physical delete).
src/lexer/cfg_eval.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave795 B7A: heat dep-edge thin cfg_eval multi residual — prereqs → FORCE + ensure;
# try-heat owns multi-seed/.x + hdr mtime (try-cfg-eval-ladder). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# wave886 B7B residual: drop LD=/LD_RELFLAGS= recipe inject (G.7 hygiene).
# Authority: ensure try-cfg-eval-ladder — LD:-ld + shell Darwin arch default;
# CLI/env LD / LD_RELFLAGS still override. NOT physical delete.
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02a：preprocess 已迁 preprocess.x；不再编译 preprocess.c。

# runtime.c：不引用 C lexer/parser/typeck/codegen（见 XLANG_NO_C_FRONTEND 包裹的 load_one_import 等）
# G-02f-14：G05 产品 runtime_driver_no_c — joined wave901 multi-target $(R1_MAIN_RUNTIME_OBJS).
# wave751 R1 cold + wave766 try-rt-prefer + wave864 shell flag defaults live in ensure try-heat.

# xlang_x 使用带 -DXLANG_USE_X_PIPELINE 编译的 main — joined wave901 multi-target $(R1_MAIN_RUNTIME_OBJS).

# xlang_x：pipeline_x.o 编排 typeck_x/codegen_x（G-02a: typeck.c + codegen.c 已删；X pipeline 独立）。
# wave817 B7B: list authority → mk/pipeline_x_objs.mk (G.7; not physical delete).
# Makefile keeps include + consumers (xlang-x-pipeline / seed link / composites);
# no dual PIPELINE_X_* / PIPELINE_LIBS inventory.
include mk/pipeline_x_objs.mk

# asm 后端 -o <exe> 时链接用：提供 xlang_panic_；Linux x86_64 有 .s 时用纯 syscall .s，否则 .inc（G-02e-20）
# wave760 R2: cold body → ensure try-r2 (platform stamp + UNAME source pick;
# list = DRIVER_SEED_PANIC_OBJS).
# wave776 R2 PREFER: thin+rest → ensure try-r2-prefer (G.7 single PREFER body;
# fail / PREFER=0 / pure-asm host → cold try-r2 twin). Makefile thin-call only.
# PLATFORM: LINUX|x86_64 (.s) / MACOS|arm64 + LINUX|aarch64 (arm64 seed) / else (from_x).
RUNTIME_PANIC_S := $(wildcard src/asm/runtime_panic_x86_64.s)
# wave796 B7A: heat dep-edge thin panic stamp residual — UNAME prereqs → FORCE + ensure;
# shell try-r2 / try-r2-prefer owns host source pick + platform stamp mtime.
# wave889 B7B residual: drop dual Makefile stamp body (mkdir+touch). Shell ensure
# owns build_asm/runtime_panic.$(uname -s).$(uname -m).stamp under try-r2 /
# try-r2-prefer. Stamp target no longer in make graph (was unused prereq).
# NOT physical delete — thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# PLATFORM: LINUX|x86_64 — cold .s when present; arm64 seed; else portable from_x
# (shell r2_panic_host_pick_src; stamp path under build_asm/).
runtime_panic.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# seed asm 用户程序：std.io 跳过 .x emit 时的 print/write/read_ptr 链接桩（G-02e-20 .inc）
# G-02f-20：runtime_asm_io_stubs 产品 seed — joined wave903 multi-target $(R1_EXTRA_CFLAGS_OBJS).


# ---------------------------------------------------------------------------
# wave908 · B7B B1 runtime OS product edges multi-target FORCE thin try-heat
# G.7 有则补全: list authority = $(B1_RUNTIME_OS_SEED_OBJS) in mk/driver_seed_r_lists.mk
# (wave779 try-runtime-os-prefer table; wave788 list-in-mk family; no second .o list).
# Body authority = scripts/ensure_host_cc_seed_o.sh try-heat
# (wave779/790/791/792/793; PREFER thin.x+rest ladder lives in try-heat → try-runtime-os-prefer).
# Leaves (23): runtime_test_fn_invoke · random_fill · compress_zlib_glue · time_os ·
# queue_contention · dynlib_os · env_os · backtrace_platform · log_os · math_libm ·
# atomic_glue · net_udp_batch · net_workers · sync_os · sync_lock_diag_tls · thread_glue ·
# http_glue · tls_mbedtls_bio · arrow_simd_glue · crypto_inc_glue · ed25519_ref10_glue ·
# process_argv · process_os_glue.
# Archaeology: F-ZC / G-02f OS+glue dual hybrid · wave518–523 R2 thin+rest · wave779 body
# swallow · wave791 FORCE dep-thin — body in try-heat.
# Makefile only FORCE + thin-call. NOT physical delete — thin edges + remaining
# mk lists hybrid (gen-x / …) + tip Windows → dual L4 → explicit auth.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(B1_RUNTIME_OS_SEED_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# ---------------------------------------------------------------------------
# wave909 · B7B GEN_X product edges multi-target FORCE thin try-heat
# G.7 有则补全: list authority = $(GEN_X_SEED_OBJS) in mk/driver_seed_r_lists.mk
# (wave761 try-gen-x map = lsp_io_x · lsp_x · lsp_diag_x · pipeline_x; no second body).
# Body authority = scripts/ensure_host_cc_seed_o.sh try-heat
# (wave761/796/790; try-heat → try-gen-x → ensure_gen_x_o.sh owns gen.c / DEPS mtime).
# rebuild_leaves membership stays catalog DRIVER_SEED_LSP_X_OBJS subset +
# DRIVER_SEED_PIPELINE_X_OBJS (GEN_X_SEED_OBJS is make-graph inventory only).
# Archaeology: wave761 swallow · wave796 FORCE dep-thin — body in try-heat.
# Makefile only FORCE + thin-call. NOT physical delete — thin edges + remaining
# mk lists hybrid (B4 gen-c-to-o / …) + tip Windows → dual L4 → explicit auth.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# ---------------------------------------------------------------------------
$(GEN_X_SEED_OBJS): FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@


# 无 C 自举：crt0 提供 _start 与 driver_get_argv_i；链接 asm 版 xlang 时用本 .o 替代 main.o / runtime_asm_build.o
# wave762 R2: body → ensure_host_cc_seed_o.sh try-r2 (list = DRIVER_SEED_CRT0_OBJS /
# DRIVER_SEED_TYPECK_F64_OBJS). UNAME ifeq only selects which target is defined on
# this host; recipe body is shell (G.7 single cold body). PLATFORM tags in ensure.
# wave795 B7A: heat dep-edge thin pure asm residual — .s prereqs → FORCE + ensure;
# try-heat owns .s/seed mtime (try-r2). Host ifeq gate kept. NOT physical delete.
ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
src/asm/crt0_x86_64.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# S4 freestanding 用户程序入口（call _main；见 tests/run-freestanding-hello.sh）
src/asm/crt0_user_x86_64.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# S4 freestanding syscall write（xlang_sys_write）
src/asm/freestanding_io_x86_64.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# runtime.c 链 freestanding 用户程序时在 compiler/ 下查找 crt0_user.o / freestanding_io.o
# wave836: FORCE dep-thin — shell owns SRC mtime + try-heat (ensure_cp_alias_o; not physical delete).
# PLATFORM: x86_64 freestanding link names (block gated by UNAME_M); FORCE always invokes script.
crt0_user.o: FORCE scripts/ensure_cp_alias_o.sh
	@bash scripts/ensure_cp_alias_o.sh ensure $@
freestanding_io.o: FORCE scripts/ensure_cp_alias_o.sh
	@bash scripts/ensure_cp_alias_o.sh ensure $@
# NL-07 v2：bootstrap crt0 nostdlib 最小 libc 桩（cc_inc_tu residual — not R2 try-r2)
# wave831: FORCE dep-thin — shell owns seed mtime (cc_inc_tu; not physical delete).
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
src/asm/bootstrap_nostdlib_stubs.o: FORCE scripts/cc_inc_tu.sh
	# wave889 B7B residual: bare sh → pure @bash thin-call form (wave888 incomplete).
	@bash scripts/cc_inc_tu.sh seeds/bootstrap_nostdlib_stubs.from_x.c $@
endif
endif
# E-04 v20：Darwin bootstrap 默认 crt0（arm64 / x86_64 Mach-O）
ifeq ($(UNAME_S),Darwin)
ifneq (,$(filter arm64 aarch64,$(UNAME_M)))
src/asm/crt0_arm64.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@
else ifneq (,$(filter x86_64 amd64,$(UNAME_M)))
src/asm/crt0_darwin_x86_64.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@
endif
endif
# E-04 v21：Windows/MinGW/MSYS bootstrap 默认 crt0_mingw 替代 main_driver.o
# wave762: try-r2 body (cc_inc_tu + WIN32_O_CFLAGS inside ensure; list = DRIVER_SEED_CRT0)
# wave866 B7B: drop multi-token WIN32_O_CFLAGS inject (G.7 hygiene).
# Ensure shell uses ${WIN32_O_CFLAGS:-} when env set by caller; no make-expanded bag
# (WIN32_O_CFLAGS has no Makefile ?= composition). Shell resolve_host_cc (wave884; no CC= inject).
# PLATFORM: WINDOWS — crt0_mingw host only; mac/Ubuntu skip this recipe via ifeq.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
ifeq ($(XLANG_IS_WIN_HOST),1)
src/asm/crt0_mingw.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@
endif

# asm 链接无 runtime_driver 时：提供 typeck_float64_bits_lo/hi（G-02e：全平台 .s，零 C）。
# wave762 R2: body → ensure try-r2 (host pick .s; list = DRIVER_SEED_TYPECK_F64_OBJS).
# UNAME ifeq keeps unsupported-arch hard error surface; recipe is shell.
# wave795 B7A: .s prereqs → FORCE; shell owns freshness (try-r2). NOT physical delete.
ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
src/typeck/typeck_f64_bits.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave795 B7A: heat dep-edge thin pure asm residual — .s prereq → FORCE + ensure;
# try-heat owns host-picked .s mtime (r2-typeck-f64). NOT physical delete.
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@
else ifeq ($(UNAME_M),aarch64)
src/typeck/typeck_f64_bits.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave795 B7A: heat dep-edge thin pure asm residual — .s prereq → FORCE + ensure;
# try-heat owns host-picked .s mtime (r2-typeck-f64). NOT physical delete.
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@
else
$(error typeck_f64_bits: unsupported Linux arch $(UNAME_M); add .s)
endif
else ifeq ($(UNAME_S),Darwin)
ifeq ($(UNAME_M),arm64)
src/typeck/typeck_f64_bits.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave795 B7A: heat dep-edge thin pure asm residual — .s prereq → FORCE + ensure;
# try-heat owns host-picked .s mtime (r2-typeck-f64). NOT physical delete.
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@
else ifeq ($(UNAME_M),x86_64)
# Darwin x86_64：SysV .s 无 _ 前缀；clang 汇编 Mach-O 时需额外处理，当前主路径为 arm64。
src/typeck/typeck_f64_bits.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave795 B7A: heat dep-edge thin pure asm residual — .s prereq → FORCE + ensure;
# try-heat owns host-picked .s mtime (r2-typeck-f64). NOT physical delete.
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@
else
$(error typeck_f64_bits: unsupported Darwin arch $(UNAME_M); add .s)
endif
else ifeq ($(XLANG_IS_WIN_HOST),1)
# Windows MSYS/MinGW x86_64: PE/COFF doesn't support ELF-style .type directive;
# use _mingw variant (x64 PE COFF doesn't add underscore prefix, so symbol names
# match the SysV variant — see typeck_f64_bits_x86_64_mingw.s docblock).
ifeq ($(UNAME_M),x86_64)
src/typeck/typeck_f64_bits.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave795 B7A: heat dep-edge thin pure asm residual — .s prereq → FORCE + ensure;
# try-heat owns host-picked .s mtime (r2-typeck-f64). NOT physical delete.
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@
else
$(error typeck_f64_bits: unsupported Windows arch $(UNAME_M); add .s)
endif
else
$(error typeck_f64_bits: unsupported OS $(UNAME_S); add .s)
endif

# wave718: clean body → scripts/clean_compiler.sh (G.7 single authority)
# wave879 B7B: drop multi-token TARGET/XLANG_C inject (G.7 hygiene).
# Shell defaults own TARGET/XLANG_C (clean_compiler). Thin @bash only (wave890).
clean:
	@bash scripts/clean_compiler.sh

# 阶段 1 词法 + 阶段 3 类型检查 + …；依赖 xlang 与全部 std .o、runtime_panic.o，clean 后 test 会先构建再跑脚本
# test_c：与 ../tests/run-all-c.sh 等价（C 版 xlang-c 跑整份 run-all，不含自举专用脚本）
# test_x：bootstrap-driver-seed + run-lsp + run-all-x（.x 流水线全量）
# wave720: bodies → scripts/run_compiler_tests.sh (G.7); prereqs stay make graph.
# wave880 B7B: drop multi-token TARGET/XLANG_C/ENSURE inject (G.7 hygiene).
# Shell MAKELEVEL default ENSURE=0 on make-graph path; direct xbuild keeps ENSURE=1.
# 依赖 $(XLANG_C) 以便 make clean && make test_c 时 xlang-c 存在
test_c: $(TARGET) $(XLANG_C) $(STD_AND_PANIC_O)
	@bash scripts/run_compiler_tests.sh c

# x 自举：bootstrap-driver-seed + LSP + 全量自举（run-all-x：用 xlang_x 跑整份 run-all）
test_x: bootstrap-driver-seed
	@bash scripts/run_compiler_tests.sh x

# 全量：先 C 再 x 自举（thin: reuses c/x shells via mode all)
# wave892 B7B residual: drop dual @echo status body (G.7 form hygiene).
# Authority: scripts/run_compiler_tests.sh already prints "Test all OK" on mode all.
# Pure prereq chain; thin @true only. NOT physical delete — thin edges remain.
test: test_c test_x
	@true

# wave719: bootstrap-token/lexer body → scripts/bootstrap_token_lexer_smoke.sh (G.7)
# wave882 B7B: drop single-token TARGET= inject (G.7 hygiene).
# Shell TARGET="${TARGET:-xlang}" + GNU make CLI auto-export; default product path
# needs no recipe inject. $(TARGET) prereq stays make graph.
# 依赖 $(STD_AND_PANIC_O)：-o 链 std/io 等 .o，clean 后仅 make $(TARGET) 会缺这些文件导致 cc 失败。
bootstrap-token: $(TARGET) $(STD_AND_PANIC_O)
	@bash scripts/bootstrap_token_lexer_smoke.sh token

bootstrap-lexer: $(TARGET) $(STD_AND_PANIC_O)
	@bash scripts/bootstrap_token_lexer_smoke.sh lexer

# wave844: full body → scripts/bootstrap_parser_smoke.sh (G.7 有则补全; shell owns
#   parser.x -o smoke + parse-file dual-path fixtures). NOT physical delete —
#   prereq graph (relink-xlang / STD_AND_PANIC_O / bootstrap-parser) residual.
# wave882 B7B: drop single-token TARGET= inject (shell TARGET default + CLI auto-export).
# 自举 9.1：用 xlang 编译 parser.x（import lexer + token + ast + std.fs），解析 function main(): i32 { return 0; } 并验证；-L .. 供 std.fs，-L src/lexer 供 token，-L src/ast 供 ast
bootstrap-parser: relink-xlang $(STD_AND_PANIC_O) scripts/bootstrap_parser_smoke.sh
	@bash scripts/bootstrap_parser_smoke.sh parser

# 9.1 联调：.x `parse()` 支持 return 字面量或 `parse_expr_into`（堆上大块 Arena，栈安全）；宿主 xlang 走完整流水线。
# 第二段：`return (1 + 2) * 3 + -1`，.x standalone 走 parse()→堆上 Arena→parse_expr_into；宿主 xlang 走完整流水线。
# wave882 B7B: drop single-token TARGET= inject (same as bootstrap-parser).
bootstrap-parse-file: $(TARGET) $(STD_AND_PANIC_O) bootstrap-parser scripts/bootstrap_parser_smoke.sh
	@bash scripts/bootstrap_parser_smoke.sh parse-file

# 迁移到 .x：parser.x -E-extern + ast 池 getter 补丁 → parser_x.o（提供 parser_parse_into_buf；与瘦 pipeline_x.o 分 TU）。
# 须 xlang-x -x -E 全量 TU；xlang-c 瘦 gen 缺 copy_module_import_path64 / parse_expr_into 等。
# ast_gen2.c 仅 typeck/codegen 单 TU 需要；clean worktree 用 pinned parser seed 时不应先触发它。
# wave736: G.7 body → scripts/ensure_migrate_gen.sh (parser_gen.c seed/pin/-E)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
# wave877 B7B: drop multi-token MAKE/XLANG_*/FORCE/TIMEOUT inject (G.7 hygiene).
# Shell defaults own MAKE/XLANG_C/XLANG_X/FORCE_REGEN/TIMEOUT (ensure_*_gen).
# Command-line overrides still flow via make recipe env. Thin @bash only.
parser_gen.c: FORCE scripts/ensure_migrate_gen.sh
	@bash scripts/ensure_migrate_gen.sh parser
# wave735: G.7 body → scripts/migrate_x_objs.sh (parser leaf)
# wave832: FORCE dep-thin — shell owns gen.c mtime (migrate need_rebuild; not physical delete).
# PLATFORM: SHARED — FORCE always invokes migrate (cheap mtime skip).
# wave865 B7B: drop multi-token CFLAGS inject (G.7 hygiene).
# migrate_x_objs shell-loads export-try-heat-cflags when CFLAGS/PIPELINE_GEN unset.
# wave878 B7B: drop multi-token CC/PYTHON/MAKE inject (G.7 hygiene).
# Shell defaults own CC/PYTHON/MAKE (migrate_x_objs). Thin @bash only (wave890).
parser_x.o: FORCE scripts/migrate_x_objs.sh
	@bash scripts/migrate_x_objs.sh parser

# lexer.x：须 xlang-x -x -E 全量 TU；xlang-c 无 -x 时缺 advance_one/next_body。
# wave737: G.7 body → scripts/ensure_migrate_gen.sh lexer (pin/seed/-E + slim + token enum)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
lexer_gen.c: FORCE scripts/ensure_migrate_gen.sh
	@bash scripts/ensure_migrate_gen.sh lexer

# wave782: B4 gen.c → .o bootstrap body → try-gen-c-to-o (thin-call only).
# wave796 B7A: heat dep-edge thin gen_x residual — gen.c prereq → FORCE + ensure;
# try-heat → try-gen-c-to-o owns lexer_gen.c mtime. NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
lexer_x.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-11：x_seed_bridge 产品 seed — joined wave899 multi-target $(R1_CORE_SEED_OBJS).

# pipeline_x.o 仍引用 typeck_typeck_* / codegen_codegen_* / lexer_lexer_*；*_x.o 导出无重复前缀名。
# G-02f-16：x_frontend_link_alias 产品 seed（G-02e-8 三 alias 并入体）
# — joined wave902 multi-target $(R1_ALIAS_STUBS_OBJS).
# G-02f-17：strict/bootstrap bare alias + typeck stubs seeds
# (ast_asm_bare / backend_asm_bare / backend_asm_strict_fallback / typeck_c_module_stubs)
# — joined wave902 multi-target $(R1_ALIAS_STUBS_OBJS).
# wave727 · 11.0.4: USER_ASM / Darwin filtered / ASM_HOST_DISPATCH lists live in
# mk/user_asm_seed_objs.mk (G.7 single authority; do not re-assign here).
# Thin leaf bootstrap-driver-seed-asm-host is the cold-orch entry; build-seed-asm-host
# remains the historical alias (g05 hints / external callers).
include mk/user_asm_seed_objs.mk

.PHONY: build-seed-asm-host bootstrap-driver-seed-asm-host
# partial export 须先 nm dispatch .o 剔除重复符号；冷启动时 dispatch 可能尚未编译。
.PHONY: parser-legacy-text-o
parser-legacy-text-o:
	@bash scripts/extract_parser_legacy_text.sh

bootstrap-driver-seed-asm-host: $(DRIVER_SEED_ASM_HOST_DISPATCH_OBJS)
	@bash scripts/build_seed_asm_host.sh

# Historical alias → thin leaf (G.7 single body; no second recipe).
build-seed-asm-host: bootstrap-driver-seed-asm-host

# §5b #9 — host stubs body → scripts/bootstrap_driver_seed_host_stubs.sh (wave723).
# SCAN_BASE / CFLAGS / OUT: Makefile export only (G.7). Optional HOST_DIR peers
# (asm_full.o, asm_backend_partial.o) remain fixed relative names in shell.
# wave883 B7B: drop single-token MAKE= inject (shell MAKE default + make auto-export).
$(USER_ASM_SEED_HOST_STUBS): pipeline_x.o $(ASM_GLUE_STANDALONE_O) $(USER_ASM_SEED_OBJS) scripts/gen_asm_full_link_stubs.pl scripts/bootstrap_driver_seed_host_stubs.sh
	@bash scripts/bootstrap_driver_seed_host_stubs.sh

$(USER_ASM_SEED_HOST_OBJS): build-seed-asm-host

# G-02f-15：user_asm_seed_bridge + asm_backend_compat_stubs 产品 seed
# (wave752 R1 · wave769 try-l2-asm-prefer in try-heat) — joined wave902 multi-target
# $(R1_ALIAS_STUBS_OBJS).

# G-02f-9 / Phase 4：backend_*_dispatch thin+rest PREFER_X_O — joined wave906 multi-target
# $(R3_COLD_SEED_OBJS). wave763 PREFER gate unified (PREFER=1 only) for cold-chain safety (Darwin).
# Archaeology: wave757/763 try-r3-prefer · wave792 FORCE — body in try-heat.

# G-02f-15：backend_x86_64_enc_c 产品 seed — joined wave904 multi-target $(R1_MISC_BASENAME_OBJS).
# Archaeology: wave754 R1 cold · wave769 try-l2-asm-prefer · wave792 FORCE — body in try-heat.

# CG002：backend_arm64_enc_c 产品 seed — joined wave904 multi-target $(R1_MISC_BASENAME_OBJS).
# PLATFORM: MACOS arm64 pure-asm 必需；其它主机链接无害（ta!=1 不调）。
# Archaeology: wave754 R1 · wave792 FORCE — body in try-heat.

# backend_arch_emit / try_inline / call_dispatch — joined wave906 multi-target $(R3_COLD_SEED_OBJS).
# Archaeology: wave757/763 try-r3-prefer · wave792 FORCE — body in try-heat.

# parser EMIT_HEAVY thin delegate C 目标：bootstrap xlang 须链入，extern bl 白名单 emit 才不 segfault。
# 全量 parser_x.o 已含 parse_into_buf / get_module_* 等；禁 seed slice 与重复前缀符号。
PARSER_ASM_THIN_GLUE_CFLAGS = -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE
PARSER_ASM_LINK_ALIAS_CFLAGS = -DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS
# G-02f-10：thin glue 产品 seed — joined wave905 multi-target $(R1_SEED_MAP_OBJS).
# Archaeology: wave758 R1 seed-map basename mismatch · wave831 FORCE drop seed/inc ·
# wave864 drop multi-token CFLAGS inject · monothin -I/-D in ensure extras_for_seed_map.
# parse_expr_link — joined wave903 multi-target $(R1_EXTRA_CFLAGS_OBJS).


# Authority: scripts/filter_bootstrap_seed_against_partial_o.sh → filter_o_export_against_deps.sh
# (G.7 single path; g05_ensure same). PLATFORM: SHARED — Darwin product USER_ASM_LINK.
# wave835: FORCE dep-thin — drop SRC/partial make-graph prereqs; shell owns mtime +
# try-heat SRC then filter (parallel-safe). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes ensure (cheap mtime skip).
# wave863 B7B: drop multi-token CFLAGS/PIPELINE_GEN inject (G.7 hygiene).
# try-heat (wave862) shell-loads export-try-heat-cflags when unset; filter scripts
# must not pass empty CFLAGS= (would block shell-load). Shell resolve_host_cc (wave884; no CC= inject).
build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o: FORCE scripts/filter_bootstrap_seed_against_partial_o.sh
	@bash scripts/filter_bootstrap_seed_against_partial_o.sh ensure $@

build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o: FORCE scripts/filter_bootstrap_seed_against_partial_o.sh
	@bash scripts/filter_bootstrap_seed_against_partial_o.sh ensure $@

build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o: FORCE scripts/filter_bootstrap_seed_against_partial_o.sh
	@bash scripts/filter_bootstrap_seed_against_partial_o.sh ensure $@

# Authority: scripts/filter_bootstrap_seed_pipeline_o.sh → filter_o_export_against_deps.sh
# (G.7 single path; g05_ensure same). PLATFORM: SHARED — Darwin product link primary.
# wave835: FORCE dep-thin — drop pipeline_x/partial/strict_minimal make-graph prereqs;
# shell owns mtime + try-heat SRC. NOT physical delete.
# wave863 B7B: drop multi-token CFLAGS/PIPELINE_GEN inject (same as partial trio).
# PLATFORM: SHARED — FORCE always invokes ensure (cheap mtime skip).
build_asm/bootstrap_seed_pipeline_filtered.o: FORCE scripts/filter_bootstrap_seed_pipeline_o.sh
	@bash scripts/filter_bootstrap_seed_pipeline_o.sh ensure $@

# wave831: FORCE dep-thin — shell owns seed mtime (cc_inc_tu; not physical delete).
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
src/asm/asm_experimental_symbol_bridge.o: FORCE scripts/cc_inc_tu.sh
	# wave889 B7B residual: bare sh → pure @bash thin-call form.
	@bash scripts/cc_inc_tu.sh seeds/asm_experimental_symbol_bridge.from_x.c $@

# 迁移到 .x：parser/typeck/codegen 独立 -E-extern 产物；pipeline_x.o 仅编排（-E-extern），seed 链 typeck_x.o/codegen_x.o。
# wave735/736: G.7 body → migrate_x_objs.sh (_x.o) + ensure_migrate_gen.sh (*_gen.c)
# wave865 B7B: drop multi-token CFLAGS inject (G.7 hygiene; same as parser/typeck/codegen).
# wave878 B7B: drop multi-token CC/PYTHON/MAKE inject (G.7 hygiene; shell defaults).
migrate-x-objs:
	@bash scripts/migrate_x_objs.sh all

# wave830: G.7 body → scripts/ensure_ast_gen2.sh (pin / FORCE_REGEN / -E + fix_slim)
# FORCE dep-thin — shell owns pin policy (G.7; not physical delete).
# PLATFORM: SHARED — FORCE always invokes ensure (cheap pin skip).
ast_gen2.c: FORCE scripts/ensure_ast_gen2.sh
	@bash scripts/ensure_ast_gen2.sh

# wave782: B4 gen.c → .o bootstrap body → try-gen-c-to-o (thin-call only).
# wave796 B7A: heat dep-edge thin gen_x residual — gen.c prereq → FORCE + ensure;
# try-heat → try-gen-c-to-o owns ast_gen2.c mtime. NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
ast_gen2.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave736: G.7 body → scripts/ensure_migrate_gen.sh (typeck_gen.c seed/pin/-E)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
typeck_gen.c: FORCE scripts/ensure_migrate_gen.sh
	@bash scripts/ensure_migrate_gen.sh typeck

# wave735: G.7 body → scripts/migrate_x_objs.sh (typeck leaf)
# wave832: FORCE dep-thin — shell owns gen.c mtime (migrate need_rebuild; not physical delete).
# PLATFORM: SHARED — FORCE always invokes migrate (cheap mtime skip).
# wave865 B7B: drop multi-token CFLAGS inject (G.7 hygiene).
# wave878 B7B: drop multi-token CC/PYTHON/MAKE inject (G.7 hygiene; shell defaults).
typeck_x.o: FORCE scripts/migrate_x_objs.sh
	@bash scripts/migrate_x_objs.sh typeck

# wave736: G.7 body → scripts/ensure_migrate_gen.sh (codegen_gen.c tip seed pin/-E)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
codegen_gen.c: FORCE scripts/ensure_migrate_gen.sh
	@bash scripts/ensure_migrate_gen.sh codegen

# wave735: G.7 body → scripts/migrate_x_objs.sh (codegen leaf)
# wave832: FORCE dep-thin — shell owns gen.c mtime (migrate need_rebuild; not physical delete).
# PLATFORM: SHARED — FORCE always invokes migrate (cheap mtime skip).
# wave865 B7B: drop multi-token CFLAGS inject (G.7 hygiene).
# wave878 B7B: drop multi-token CC/PYTHON/MAKE inject (G.7 hygiene; shell defaults).
codegen_x.o: FORCE scripts/migrate_x_objs.sh
	@bash scripts/migrate_x_objs.sh codegen

# 6.1：.x typeck 入口与 C AST 对接；force-regen typeck_gen → migrate typeck_x → relink TARGET。
# wave785 B7c: typeck_x.o → migrate_x_objs (no dual $(CC) -c).
# wave841: full body → scripts/bootstrap_typeck_codegen.sh (G.7 有则补全 ensure_migrate_gen
#   FORCE_REGEN + migrate_x_objs; Makefile thin-call only).
# wave850 B7B: BTC_OBJS bag → mk/driver_seed_composites.mk RELINK_PRODUCT_LINK_OBJS
#   (G.7 有则补全; no dual inline product link inventory in typeck/codegen/relink-lexer).
# wave856: shell loads LINK_OBJS via export-relink-product-link-objs (no multi-token BTC_OBJS=).
# wave857: shell loads LINK_CFLAGS via export leaves (no multi-token BTC_CFLAGS=).
# wave865: shell/migrate loads product CFLAGS via export-try-heat-cflags (no multi-token CFLAGS=).
# wave879 B7B: drop multi-token MAKE/TARGET/XLANG_C/CC/PYTHON inject (G.7 hygiene).
# Shell defaults own env (bootstrap_typeck_codegen). Thin @bash only.
# NOT physical delete — prereq make-graph + thin edges + mk lists remain residual.
# PLATFORM: SHARED — shell owns gen/migrate/link orchestration.
bootstrap-typeck: $(TARGET) $(XLANG_C) bootstrap_xlangc $(RELINK_XLANG_PREREQS) scripts/bootstrap_typeck_codegen.sh
	@bash scripts/bootstrap_typeck_codegen.sh typeck

# 6.2：.x codegen 入口与 C AST 对接；force-regen typeck+codegen gen → migrate both → relink TARGET。
# wave785 B7c: typeck/codegen .o → migrate_x_objs (no dual $(CC) -c).
# wave841: full body → scripts/bootstrap_typeck_codegen.sh (G.7 有则补全; same shell as typeck).
# wave850 B7B: BTC_OBJS → $(RELINK_PRODUCT_LINK_OBJS) (composites.mk; same bag as typeck/RXL).
# wave856: shell loads LINK_OBJS via export-relink-product-link-objs (no multi-token BTC_OBJS=).
# wave857: shell loads LINK_CFLAGS via export leaves (no multi-token BTC_CFLAGS=).
# wave865: shell/migrate loads product CFLAGS via export-try-heat-cflags (no multi-token CFLAGS=).
# wave879 B7B: drop multi-token MAKE/TARGET/XLANG_C/CC/PYTHON inject (G.7 hygiene).
# Shell defaults own env (bootstrap_typeck_codegen). Thin @bash only.
# NOT physical delete — prereq make-graph + thin edges + mk lists remain residual.
# PLATFORM: SHARED — shell owns gen/migrate/link orchestration.
bootstrap-codegen: $(TARGET) $(XLANG_C) bootstrap_xlangc $(RELINK_XLANG_PREREQS) scripts/bootstrap_typeck_codegen.sh
	@bash scripts/bootstrap_typeck_codegen.sh codegen

# 6.3/6.4：入口在 main.x；链接时用 main_driver.o（带 XLANG_USE_X_DRIVER/PIPELINE 以启用 -backend asm）+ runtime_driver.o + ...
# G-02f-16：main_driver 与 main 同源 seed — joined wave901 multi-target $(R1_MAIN_RUNTIME_OBJS).
# G-02a: preprocess.c 已物理删除；runtime preprocess() 走 preprocess.x（preprocess_x.o）。
# G-02f-6：target_cpu.o 单 TU — joined wave905 multi-target $(R1_SEED_MAP_OBJS).
# Archaeology: wave755 R1 · wave768 try-target-cpu-prefer · wave793 FORCE · seed map
# target_cpu ← target_cpu_pure — body in try-heat.
# G-02f-7 / Phase 4：simd_enc thin+rest PREFER_X_O — joined wave906 multi-target $(R3_COLD_SEED_OBJS).
# 源：src/asm/simd_enc_thin.x（74 #[no_mangle] thin wrapper）+ seeds/simd_enc.from_x.c（_impl rest）
# 仅 XLANG_G05_PREFER_X_O=1 且 xlang-c 可用时走 thin；否则 seed 完整编译。
# 【Why 2026-07-16】Darwin 上 bootstrap_xlangc 常在：若仅按「有 xlang-c」走 thin，thin 可能
# 假成功（能 cc/ld -r 但缺 simd_rbp_disp32 等强符号）→ seed phase1 链失败。
# Ubuntu 上 thin 生成 C 常编译失败并回退 seed，故冷链绿；mac 须与冷链同源：默认 seed。
# 验收：nm 须有 simd_rbp_disp32，否则丢弃 thin 回退 seed（body = try-r3-prefer in try-heat）.
# Archaeology: wave757/763 try-r3-prefer · wave793 FORCE — body in try-heat.
# G-02f-8 / Phase 4：simd_loop thin+rest PREFER_X_O — joined wave906 multi-target $(R3_COLD_SEED_OBJS).
# 源：src/asm/simd_loop_thin.x（22 #[no_mangle] thin wrapper）+ seeds/simd_loop.from_x.c（17 _impl rest）
# 仅 XLANG_G05_PREFER_X_O=1 且 xlang-c 可用时走 thin；否则 seed 完整编译（同 simd_enc 冷链纪律）。
# Archaeology: wave757/763 try-r3-prefer · wave793 FORCE — body in try-heat.
# G-02a Step 1：默认构建切 no_c 模式；默认 bootstrap 不链 LEXER_LINK_O / AST_LINK_O。
# C 前端 .c（ast/lexer/parser/typeck/codegen）仍保留，因 build_xlang_asm.sh + relink 脚本仍引用 ast_seed.o 等。
# bootstrap-driver-seed：pipeline_x.o 为 -E-extern 编排；parser/lexer/typeck/codegen *_x.o 分 TU。
# C-06 v1 默认：不链 C parser/typeck/codegen.o（XLANG_LEGACY_C_FRONTEND=1 恢复双轨）。
# seed 链：lexer_x.o + x_frontend_link_alias.o（X 词法）；默认不链 C lexer.o（E-03 v2）。
# wave818 B7B: seed mode picks → mk/driver_seed_mode_objs.mk (G.7; not physical delete).
# Makefile keeps include + consumers (composites / seed link / rebuild);
# no dual DRIVER_SEED_SUPPORT_EXTRA / RUNTIME_O inventory.
# G-06：capture 用 XLANG_LEGACY_C_FRONTEND=1；产品默认 no_c；XLANG_NO_C_SEED_LINK
# 与产品同 inventory（见 mk 注释）。stubs 仍在 GLUE_SUFFIX（link END）。
include mk/driver_seed_mode_objs.mk
# pipeline_glue_standalone 与 pipeline_x.o 重复时 glue 置链接末尾且允许多定义（覆盖 pipeline_gen 快照内旧 glue）。
# wave788: ASM_GLUE_STANDALONE_O lives in mk/driver_seed_r_lists.mk (included above).
# Why: XLANG_WEAK (see include/xlang_weak.h) expands to `__attribute__((weak))` on ELF
#      (Linux/macOS) but to EMPTY on PE/MinGW (Windows). Seed .from_x.c files contain
#      XLANG_WEAK stub fallbacks (e.g. process_args_count_c, parse, typeck_module) that
#      have a matching strong real implementation in another .o (e.g.
#      runtime_process_args_thin.from_x.c → process_args_count_c real impl). On ELF,
#      `ld -r` permits weak+strong merge silently. On PE/MinGW, XLANG_WEAK becomes
#      strong so both defs are strong → `ld -r` errors with "multiple definition".
#      `LD_R_MULTIDEF_FLAGS` resolves this uniformly: first-seen wins, and seed .o
#      ordering puts real impls before stubs in every `ld -r` rule.
# Invariant: Applied to every `ld -r` rule that merges 2+ .o inputs. Single-input
#            `ld -r` (rename-only, e.g. path.o/runtime.o) also gets the flag for
#            consistency (no-op when no duplicates). `ld -r $(LD_FILTER_EXPORT)`
#            (L1632 backend_x86_64_enc_c.o) is excluded — single .o + version script.
# PLATFORM: SHARED — Darwin uses -multiply_defined suppress; ELF/PE uses
#           --allow-multiple-definition. Both are no-ops when no duplicate exists.
ifeq ($(UNAME_S),Darwin)
LD_R_MULTIDEF_FLAGS = -multiply_defined suppress
ASM_GLUE_DUP_LDFLAGS = -Wl,-multiply_defined,suppress
else
LD_R_MULTIDEF_FLAGS = --allow-multiple-definition
ASM_GLUE_DUP_LDFLAGS = -Wl,--allow-multiple-definition
endif
# wave819 B7B: seed link picks → mk/driver_seed_link_picks.mk (G.7; not physical delete).
# MAIN_LINK / LEXER_AST / LSP_DIAG / PREPROCESS / GLUE_SUFFIX authority in mk only.
# Why stubs at GLUE_SUFFIX link END: PE first-wins multidef; real impls before stubs.
# PLATFORM: SHARED — Windows-critical; no-op on ELF/Darwin weak.
include mk/driver_seed_link_picks.mk
# wave821 B7B: archaeology experiment lists → mk/archaeology_experiment_objs.mk
# (G.7; not physical delete). X_FRONTEND_EXPERIMENT (7) + NO_C_FRONTEND (expands
# MAIN_LINK/PREPROCESS/AST). Include after link_picks; before experiment recipes.
# wave851: XLANG_NO_C_FRONTEND_LINK_OBJS (XNC full bag).
# wave852: DRIVER_SEED_X_FRONTEND_LINK_OBJS (BXF full bag).
# Makefile include only — no dual inline re-list.
include mk/archaeology_experiment_objs.mk
# wave728 · 11.0.4: DRIVER_SEED_OBJS / X_FRONTEND / LINK_BASE / PREREQS composites
# live in mk/driver_seed_composites.mk (include after DRIVER_SUBCMD_OBJS + USER_ASM).
# Do not re-assign here (G.7). Recipes above expand vars at recipe time.

# 阶段 10.4 实验：链 typeck_x.o/codegen_x.o 替代 C 前端（不含 pipeline_x.o，无 XLANG_USE_X_PIPELINE）。
# 勿复用 DRIVER_SEED_X_FRONTEND_OBJS 名：bootstrap-driver-seed 链依赖 parser_x.o/lexer_x.o（见上 §1280）。
# List authority: mk/archaeology_experiment_objs.mk (wave821).
# wave848: full body → scripts/bootstrap_driver_seed_x_frontend.sh (G.7 有则补全;
#   shell owns host-cc link of $(TARGET)_x_frontend). Lists stay mk expansion.
# wave852 B7B: BXF_LINK_OBJS → $(DRIVER_SEED_X_FRONTEND_LINK_OBJS)
#   (archaeology_experiment_objs.mk; no dual inline bag re-list).
# wave856: shell loads LINK_OBJS via export-bxf-link-objs (no multi-token BXF_LINK_OBJS=).
# wave880 B7B: drop multi-token MAKE/CC/OUT inject (G.7 hygiene).
# Shell defaults OUT=${TARGET}_x_frontend (TARGET default xlang). Thin @bash only.
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell owns link orchestration.
bootstrap-driver-seed-x-frontend: $(XLANG_C) migrate-x-objs driver_x.o preprocess_x.o $(DRIVER_SUBCMD_GEN) $(DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS) $(LSP_DIAG_LINK_O) $(DRIVER_SUBCMD_OBJS) scripts/bootstrap_driver_seed_x_frontend.sh
	@bash scripts/bootstrap_driver_seed_x_frontend.sh

# 6.3：.x 入口与 main.c 一一对应。bootstrap-driver-seed = 用 C 代码生成（生成 pipeline_gen.c / driver_gen.c）得到种子 xlang；仅首次或无 xlang 时需要。
# bootstrap-driver-asm / bootstrap-driver-hybrid = B-hybrid（build_xlang_asm 无 SKIP_GEN），产出可覆盖 $(TARGET)。
# bootstrap-driver = M7 默认 B-strict（同 bootstrap-driver-bstrict）：SKIP_GEN 链 xlang_asm 并覆盖 $(TARGET)；冷启动仍仅 bootstrap-driver-seed。
# 无补丁：driver_gen.c 仅由 -E -E-extern 生成；run_compiler_c 在 runtime.c 中定义并转调 main_run_compiler_c；其余从 main.x/codegen 根源修
# LSP 诊断：G-02a lsp_diag.c 已删；仅 lsp_diag_x.o + stubs。

# 非产品 / xlang-c 弱占位链：仍用手写 .inc（含 weak fill_paths 等）
# wave831: FORCE dep-thin — shell owns seed mtime (cc_inc_tu; not physical delete).
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
src/lsp/lsp_diag_pipeline_sizes.o: FORCE scripts/cc_inc_tu.sh
	# wave889 B7B residual: bare sh → pure @bash thin-call form.
	# wave892 B7B residual: drop multi-token -I. -Iinclude -Isrc (G.7 hygiene).
	# Shell BASE_CFLAGS default already has -I. -Iinclude -Isrc (cc_inc_tu.sh);
	# same form as other cc_inc_tu leaves. NOT physical delete — thin edges remain.
	@bash scripts/cc_inc_tu.sh seeds/lsp_diag_pipeline_sizes_weak.from_x.c $@

# G-02f-1 / Phase 4：产品 G05 nostub 真迁 .x（#[no_mangle] 三枚 sizeof）
# 源：src/lsp/lsp_diag_pipeline_sizes.x
# 冷启动产物：seeds/lsp_diag_pipeline_sizes.from_x.c（xlang-c 不存在时回退）
# wave781: B3 product PREFER dual hybrid body → try-lsp-sat-prefer (thin-call only).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/lsp/lsp_diag_pipeline_sizes_nostub.o: FORCE scripts/ensure_host_cc_seed_o.sh
	# wave781: B3 lsp-sat PREFER direct_e → try-lsp-sat-prefer (cold seed fallback).
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02e-8：lsp_diag_x_alias 已并入本 TU。
# G-02f-12：lsp_diag_pipeline_ctx 产品 seed — joined wave904 multi-target $(R1_MISC_BASENAME_OBJS).
# Archaeology: wave754 R1 cold · wave767 try-ldpc-prefer · wave792 FORCE — body in try-heat.

# G-02f-11：runtime_driver_strict_glue_stubs 产品 seed（内含 runtime_heap_user.inc）
# (wave752 R1 · wave771 try-other-l2-prefer · wave794 twin) — joined wave902 multi-target
# $(R1_ALIAS_STUBS_OBJS).

# G-02a：ast_seed.o — joined wave905 multi-target $(R1_SEED_MAP_OBJS).
# Archaeology: wave755 R1 · seed map ast_seed ← runtime_ast_glue · wave793 FORCE — body in try-heat.
# (ast_module_free/ast_expr_free/… 8 内存管理；no_c 下 ast_expr_init_match_enum 由 x_seed_bridge).

# G-02a: ast_x.o alias — ast_seed.o 提供 C ABI 内存管理实现。
# wave836: FORCE dep-thin — shell owns SRC mtime + try-heat (ensure_cp_alias_o; not physical delete).
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
ast_x.o: FORCE scripts/ensure_cp_alias_o.sh
	@bash scripts/ensure_cp_alias_o.sh ensure $@

# G-02a: preprocess.c 已物理删除；preprocess.o 不再编译（preprocess_x.o 由 .x 生成）。

# G-02a / G-02f-21：lexer.o runtime_lexer_glue product seed — joined wave900 multi-target
# $(R1_FRONTEND_GLUE_OBJS). (Default product path twin of LEGACY ifeq block.)

# G-02f-80：cfg_eval 冷启动 stub；legacy xlang-c 直链需要独立 .o 规则。
# wave831: FORCE dep-thin — shell owns seed+.x mtime (cc_inc_tu PEERS; not physical delete).
# wave887 B7B: drop XLANG_CC_INC_TU_PEERS inject — shell seed-map owns peer .x when unset.
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
src/lexer/cfg_eval_bootstrap_stub.o: FORCE scripts/cc_inc_tu.sh
	@bash scripts/cc_inc_tu.sh seeds/cfg_eval_bootstrap_stub.from_x.c $@

# G-02a: typeck.c 已物理删除；typeck_x.o 由 typeck.x 生成，typeck_c_module_stubs.o 提供 weak 桩。

# G-02a: codegen.c 已物理删除；codegen_x.o 由 codegen.x 生成，codegen_pipeline_stubs.o 提供 weak 桩。

# G-02a: autovec.c 已物理删除（孤立死代码，无任何调用点/include）。

# wave739: G.7 body → scripts/ensure_lsp_pipeline_gen.sh (product LSP gens)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
lsp_diag_gen.c: FORCE scripts/ensure_lsp_pipeline_gen.sh
	@bash scripts/ensure_lsp_pipeline_gen.sh lsp_diag

# wave761/796/909: lsp_diag_x.o joined multi-target $(GEN_X_SEED_OBJS) FORCE try-heat
# (try-heat → try-gen-x → ensure_gen_x_o; gen.c mtime in shell).

# lsp_io.x：C-04 v0 要求 xlang-c 自动生成 import extern；xlang-x 仍走旧块时回退 xlang-c。
# wave739: G.7 body → scripts/ensure_lsp_pipeline_gen.sh
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
lsp_io_gen.c: FORCE scripts/ensure_lsp_pipeline_gen.sh
	@bash scripts/ensure_lsp_pipeline_gen.sh lsp_io

# LSP 模块：main.x 依赖 lsp；std.io 由 .x codegen 提供（F-03 v2/v3，无 io.o）。
# LSP state 单独 .c，避免 lsp_main 内大数组导致 state 被覆盖

# lsp_gen.c 期望 typeck_read_message 等；lsp_io -E-extern 未产出时由桩提供（G-02e-16 .inc）。
# wave831: FORCE dep-thin — shell owns seed mtime (cc_inc_tu; not physical delete).
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
src/lsp/typeck_lsp_io_stub.o: FORCE scripts/cc_inc_tu.sh
	# wave889 B7B residual: bare sh → pure @bash thin-call form.
	@bash scripts/cc_inc_tu.sh seeds/typeck_lsp_io_stub.from_x.c $@

# G-02f-11 / G-02f-440：seed_link_compat 产品 seed — joined wave899 multi-target $(R1_CORE_SEED_OBJS).
# wave771 archaeology: other L2 PREFER thin+rest → try-other-l2-prefer (cold plain seed fallback; body in try-heat).

# wave739: G.7 body → scripts/ensure_lsp_pipeline_gen.sh (lsp_gen + g_lsp_state_buf post)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
lsp_gen.c: FORCE scripts/ensure_lsp_pipeline_gen.sh
	@bash scripts/ensure_lsp_pipeline_gen.sh lsp_gen

# Track L：lsp_io_std_heap / driver_*_x product edges — list→mk multi-target
# (wave896). Catalog body = driver_leaf_x_to_o.sh ensure (wave814/828/860).
# 冷启动仅 seeds/*_gen.linux.x86_64.c；工作区 *_gen.c 仅考古/FORCE_REGEN。
# wave740: G.7 body → scripts/ensure_archaeology_gen.sh (Track L archaeology only)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
lsp_io_std_heap_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@bash scripts/ensure_archaeology_gen.sh lsp_io_std_heap

# bootstrap-driver-seed / relink-xlang 共用：lsp_io / lsp 生成 C → .o
# wave761/796/909: lsp_io_x.o + lsp_x.o joined multi-target $(GEN_X_SEED_OBJS)
# FORCE try-heat (try-heat → try-gen-x; gen.c / lsp_io.x mtime in shell).

# Driver 子命令 .o（seed link / relink prereq names — not ensure recipe edges）：
#   Track L 已退役叶子：fmt/check/test/build/run/compile/emit + lsp_io_std_heap → ensure catalog
#   构建不读工作区 pinned *_gen.c；冷启动回退仅 seeds/*_gen.linux.x86_64.c
# wave816 B7B: list authority → mk/driver_subcmd_objs.mk (G.7; not physical delete).
# Makefile keeps include + consumers (seed link / relink / composites); no dual list.
# wave896: ensure edges → mk/driver_leaf_product_objs.mk multi-target (early include).
include mk/driver_subcmd_objs.mk

# wave740: G.7 body → scripts/ensure_archaeology_gen.sh
# 考古：可选再生成工作区 *_gen.c（不进 DRIVER_SEED_PREREQS；叶子已退役；产品用 *_x.o）
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_fmt_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@bash scripts/ensure_archaeology_gen.sh fmt
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_check_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@bash scripts/ensure_archaeology_gen.sh check
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_test_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@bash scripts/ensure_archaeology_gen.sh test
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_compile_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@bash scripts/ensure_archaeology_gen.sh compile
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_build_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@bash scripts/ensure_archaeology_gen.sh build
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_run_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@bash scripts/ensure_archaeology_gen.sh run
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_emit_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@bash scripts/ensure_archaeology_gen.sh emit

# driver_emit_x.o：见上文 Track L 叶子规则（.x→.o）；勿再从 pinned gen.c 覆盖

# asm_driver_*：driver_gen.c 为 extern 时由本桩提供符号（fmt/check/test 见 DRIVER_SUBCMD_OBJS）。
# 链接顺序：须紧跟 preprocess_x.o 之后（先于 lsp_diag/std *.o），避免与 runtime_driver.o
# 中 _preprocess / preprocess_preprocess_x_buf 解析顺序导致 Undefined _preprocess。

# Stage2 混合链接桩（verify-selfhost-stage2.sh）
# wave782: B4 gen.c → .o bootstrap body → try-gen-c-to-o (thin-call only).
# wave796 B7A: heat dep-edge thin gen_x residual — .c prereq → FORCE + ensure.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
_x_stubs2.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# PIPELINE_ASM_X_DEPS / PIPELINE_X_DEPS: list authority mk/x_source_deps.mk
# (wave823; included early so $(PIPELINE_X_DEPS) is non-empty here).
ifneq ($(filter 1,$(XLANG_FORCE_REGEN_GEN) $(PIPELINE_X_FORCE_COMPILE)),)
PIPELINE_X_FORCE_PREREQ = FORCE
endif

# pipeline_x.o：与 pipeline_gen.c 及 PIPELINE_X_DEPS 绑定；parser/backend 等 .x 变更须重编，避免 seed 仍用旧 pipeline 逻辑（entry 消失等）。
# 默认复用 build_asm/gen_driver/pipeline_x.o（fat 编排）；设 PIPELINE_X_FORCE_COMPILE=1 才从 pipeline_gen.c 重编。
# pipeline_glue.c / ast_pool.c 由 pipeline_glue_standalone.o 覆盖，勿因二者 mtime 触发整 TU 重编（否则与 partial 并列链 parse 塌陷）。
# wave761/796/886/909: joined multi-target $(GEN_X_SEED_OBJS) FORCE try-heat
# (try-heat → try-gen-x; gen_driver STALE + PIPELINE_X_DEPS from mk via ensure_gen_x_o.sh;
# FORCE flags via CLI/env + rebuild_leaves export). NOT physical delete.
FORCE:

# driver_gen.c / driver_x.o：main.x 驱动入口。
# wave738: G.7 body → scripts/ensure_driver_gen.sh (MAIN_X_DEPS freshness / seed / -E + fix dup main)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_gen.c: FORCE scripts/ensure_driver_gen.sh
	@bash scripts/ensure_driver_gen.sh driver

# wave782: B4 gen.c → .o bootstrap body → try-gen-c-to-o (thin-call only).
# wave796 B7A: heat dep-edge thin gen_x residual — gen/MAIN_X prereqs → FORCE + ensure;
# try-heat owns driver_gen.c + MAIN_X mtime. NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
driver_x.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# preprocess_gen.c / preprocess_x.o：runtime XLANG_USE_X_PREPROCESS 路径。
# wave738: G.7 body → scripts/ensure_driver_gen.sh preprocess
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
preprocess_gen.c: FORCE scripts/ensure_driver_gen.sh
	@bash scripts/ensure_driver_gen.sh preprocess

# wave782: B4 gen.c → .o bootstrap body → try-gen-c-to-o (thin-call only).
# wave796 B7A: heat dep-edge thin gen_x residual — gen/PREPROCESS_X prereqs → FORCE + ensure;
# try-heat owns preprocess_gen.c + preprocess.x mtime. NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
preprocess_x.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# XLANG_NO_C_FRONTEND 下 lsp_diag_x.o / lsp_x.o 需要的文档缓冲 + X 管道缓冲桩
# G-02f-22：lsp_diag_stubs_no_c 产品 seed
# G-02f-rest：rest→.x 迁移（lsp_diag_copy_text_impl + json_escape_str_impl 真迁 .x）
# wave781: B3 product PREFER thin+rest dual hybrid body → try-lsp-sat-prefer (thin-call only).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/lsp/lsp_diag_stubs_no_c.o: FORCE scripts/ensure_host_cc_seed_o.sh
	# wave781: B3 lsp-sat PREFER thin_rest_e → try-lsp-sat-prefer (cold seed fallback).
	@bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# XLANG_SKIP_SUBSCRIPT_MAKE=1：run-all 入口已链 seed，子脚本 `make` 仅在校验 xlang 缺失时再完整 bootstrap。
# wave891 B7B residual: nested `@test -x || $(MAKE) bootstrap-driver-seed …` body →
#   thin `@bash scripts/bootstrap_driver_seed.sh` (G.7 有则补全; shell owns soft-skip
#   when TARGET executable, else re-enters make with SKIP cleared + RUN_ALL=1).
# Thin @bash only. NOT physical delete — thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — same soft-skip on mac/Ubuntu/Windows host.
ifeq ($(XLANG_SKIP_SUBSCRIPT_MAKE),1)
bootstrap-driver-seed:
	@bash scripts/bootstrap_driver_seed.sh
else
# G-06 两阶段 seed：先无 USER_ASM 链 xlang-seed-phase1，再用其跑 asm.x -E 生成 partial，最后全量链 xlang。
# wave728: composites (DRIVER_SEED_OBJS / LINK_BASE / PREREQS) → mk only (G.7).
# wave822 B7B: LEGACY_XLANG_C_* + RELINK_XLANG_PREREQS also live in composites.mk
# (G.7 有则补全; Makefile include only — no dual inline re-list).
# wave850 B7B: RELINK_PRODUCT_LINK_BASE/OBJS (product archaeology full link bag)
# also live here — BTC_OBJS / RXL_LINK_OBJS consumers expand the var only.
# wave851 B7B: XLANG_X_LINK_* + BOOTSTRAP_SELF_LINK_OBJS (XXL/BS product-shaped
# archaeology bags) also live here — Makefile expand only. XNC full bag is in
# archaeology_experiment_objs.mk (same wave).
# wave853 B7B: BOOTSTRAP_DRIVER_SEED_{PHASE1,FINAL}_LINK_OBJS (seed SEED_LINK_OBJS
# phase1/final bags) also live here — Makefile expand only.
# wave854 B7B: RELINK_XLANG_REQUIRED_OBJS + XLANG_X_REQUIRED_OBJS (seed-gate bags)
# also live here. wave855: shell loads REQUIRED from mk (no multi-token env export).
# XNC gate bag is in archaeology_experiment.
include mk/driver_seed_composites.mk

# legacy xlang-c: list authority mk/driver_seed_composites.mk (wave822).
# wave858: host-cc link body → scripts/legacy_xlang_c_link.sh (G.7 有则补全;
#   shell loads LINK_OBJS via export-legacy-xlang-c-link-objs; CFLAGS reuses
#   export-relink-product-link-cflags — same formula as product archaeology).
# Archaeology XLANG_LEGACY_C_FRONTEND=1 only. NOT physical delete — prereq
# make-graph + thin edges + B2 + mk lists remain residual.
# wave880 B7B: drop multi-token MAKE/CC/OUT inject (G.7 hygiene).
# Shell defaults OUT=${XLANG_C:-xlang-c}. Thin @bash only.
# PLATFORM: SHARED — shell owns link; lists stay mk expansion.
ifeq ($(XLANG_LEGACY_C_FRONTEND),1)
$(XLANG_C): $(LEGACY_XLANG_C_PREREQS) scripts/legacy_xlang_c_link.sh
	@bash scripts/legacy_xlang_c_link.sh
endif

# 11.0.3 wave717: orchestration authority → scripts/bootstrap_driver_seed.sh
# 11.0.3 wave721: phase1/final $(CC) body → scripts/bootstrap_driver_seed_link.sh;
# 11.0.3 wave722: sat/lsp rebuild body → scripts/bootstrap_driver_seed_rebuild_leaves.sh;
# 11.0.3 wave723: host-stubs body → scripts/bootstrap_driver_seed_host_stubs.sh;
# 11.0.3 wave724: bridge/panic/user-asm/glue → same rebuild_leaves.sh + export;
# 11.0.3 wave725: §5b #1 check-abi shell · #2 pipeline_x FORCE export+shell · #8 asm-host thin leaf;
# 11.0.3/11.0.4 wave726–728: export-obj-catalog = single KEY=value dump of DRIVER_SEED_* lists
#   (xbuild read API). wave727: §5b/USER_ASM leaves in mk; wave728: composites in
#   mk/driver_seed_composites.mk; Makefile only includes + export leaves (G.7).
# PLATFORM: SHARED — sequence in shell; Darwin filtered.o still via class-G shell recipes.

include mk/driver_seed_export_lists.mk

.PHONY: bootstrap-driver-seed-sat-rebuild \
	bootstrap-driver-seed-lsp-x-objs \
	bootstrap-driver-seed-bridge \
	bootstrap-driver-seed-panic \
	bootstrap-driver-seed-user-asm-seed-objs \
	bootstrap-driver-seed-asm-glue-standalone \
	bootstrap-driver-seed-pipeline-x \
	bootstrap-driver-seed-filtered-objs \
	bootstrap-driver-seed-host-stubs \
	bootstrap-driver-seed-export-sat-rebuild \
	bootstrap-driver-seed-export-lsp-x-objs \
	bootstrap-driver-seed-export-bridge \
	bootstrap-driver-seed-export-panic \
	bootstrap-driver-seed-export-user-asm \
	bootstrap-driver-seed-export-glue \
	bootstrap-driver-seed-export-pipeline-x \
	bootstrap-driver-seed-export-host-stubs \
	bootstrap-driver-seed-export-phase1-link \
	bootstrap-driver-seed-export-final-link \
	export-relink-product-link-objs \
	export-xlang-x-link-objs \
	export-xnc-link-objs \
	export-bxf-link-objs \
	export-bs-link-objs \
	export-legacy-xlang-c-link-objs \
	export-objs-core-link-objs \
	export-xxp-link-bags \
	export-bxc-link-objs \
	export-driver-leaf-base-cflags \
	export-try-heat-cflags \
	export-relink-product-link-cflags \
	export-btc-typeck-link-cflags \
	export-xnc-link-cflags \
	export-bxf-link-cflags \
	bootstrap-driver-seed-export-obj-catalog \
	bootstrap-driver-seed-phase1-link \
	bootstrap-driver-seed-final-link

# wave726–728 · 11.0.4: one leaf dumps all §5b / link / composite object lists (expanded).
# Authority: mk/driver_seed_export_lists.mk + mk/user_asm_seed_objs.mk +
# mk/driver_seed_composites.mk. Read-only export for xbuild / inventory;
# shell must not hardcode a second copy of any list.
# PLATFORM: SHARED — KEY=value; no compile/link side effects.
bootstrap-driver-seed-export-obj-catalog:
	@printf 'DRIVER_SEED_PIPELINE_X_OBJS=%s\n' '$(DRIVER_SEED_PIPELINE_X_OBJS)'
	@printf 'DRIVER_SEED_SAT_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_SAT_REBUILD_OBJS)'
	@printf 'DRIVER_SEED_LSP_X_OBJS=%s\n' '$(DRIVER_SEED_LSP_X_OBJS)'
	@printf 'DRIVER_SEED_BRIDGE_OBJS=%s\n' '$(DRIVER_SEED_BRIDGE_OBJS)'
	@printf 'DRIVER_SEED_PANIC_OBJS=%s\n' '$(DRIVER_SEED_PANIC_OBJS)'
	@printf 'DRIVER_SEED_TYPECK_F64_OBJS=%s\n' '$(DRIVER_SEED_TYPECK_F64_OBJS)'
	@printf 'DRIVER_SEED_CRT0_OBJS=%s\n' '$(DRIVER_SEED_CRT0_OBJS)'
	@printf 'DRIVER_SEED_USER_ASM_SEED_OBJS=%s\n' '$(DRIVER_SEED_USER_ASM_SEED_OBJS)'
	@printf 'DRIVER_SEED_ASM_GLUE_OBJS=%s\n' '$(DRIVER_SEED_ASM_GLUE_OBJS)'
	@printf 'DRIVER_SEED_HOST_STUBS_SCAN_BASE=%s\n' '$(DRIVER_SEED_HOST_STUBS_SCAN_BASE)'
	@printf 'DRIVER_SEED_ASM_HOST_DISPATCH_OBJS=%s\n' '$(DRIVER_SEED_ASM_HOST_DISPATCH_OBJS)'
	@printf 'DRIVER_SEED_OBJS=%s\n' '$(DRIVER_SEED_OBJS)'
	@printf 'DRIVER_SEED_LINK_BASE=%s\n' '$(DRIVER_SEED_LINK_BASE)'
	@printf 'BOOTSTRAP_DRIVER_SEED_LINK_BASE=%s\n' '$(BOOTSTRAP_DRIVER_SEED_LINK_BASE)'
	@printf 'DRIVER_SEED_PREREQS=%s\n' '$(DRIVER_SEED_PREREQS)'
	@printf 'DRIVER_SEED_X_FRONTEND_OBJS=%s\n' '$(DRIVER_SEED_X_FRONTEND_OBJS)'
	@printf 'BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS=%s\n' '$(BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS)'
	@printf 'BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS=%s\n' '$(BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS)'
	@printf 'USER_ASM_SEED_OBJS=%s\n' '$(USER_ASM_SEED_OBJS)'
	@printf 'ASM_GLUE_STANDALONE_O=%s\n' '$(ASM_GLUE_STANDALONE_O)'
	@printf 'RT_SEED_SLICE_OBJS=%s\n' '$(RT_SEED_SLICE_OBJS)'
	@printf 'R1_CORE_SEED_OBJS=%s\n' '$(R1_CORE_SEED_OBJS)'
	@printf 'R1_FRONTEND_GLUE_OBJS=%s\n' '$(R1_FRONTEND_GLUE_OBJS)'
	@printf 'R1_MAIN_RUNTIME_OBJS=%s\n' '$(R1_MAIN_RUNTIME_OBJS)'
	@printf 'R1_ALIAS_STUBS_OBJS=%s\n' '$(R1_ALIAS_STUBS_OBJS)'
	@printf 'R1_EXTRA_CFLAGS_OBJS=%s\n' '$(R1_EXTRA_CFLAGS_OBJS)'
	@printf 'R1_MISC_BASENAME_OBJS=%s\n' '$(R1_MISC_BASENAME_OBJS)'
	@printf 'R1_SEED_MAP_OBJS=%s\n' '$(R1_SEED_MAP_OBJS)'
	@printf 'R3_COLD_SEED_OBJS=%s\n' '$(R3_COLD_SEED_OBJS)'
	@printf 'ASYNC_THREE_SEED_OBJS=%s\n' '$(ASYNC_THREE_SEED_OBJS)'
	@printf 'B1_RUNTIME_OS_SEED_OBJS=%s\n' '$(B1_RUNTIME_OS_SEED_OBJS)'
	@printf 'GEN_X_SEED_OBJS=%s\n' '$(GEN_X_SEED_OBJS)'

# §5b #2 — pipeline_x.o FORCE recompile on cold start (PIPELINE_X_FORCE_COMPILE=1)
# Body: bootstrap_driver_seed_rebuild_leaves.sh pipeline-x; list = DRIVER_SEED_PIPELINE_X_OBJS only.
bootstrap-driver-seed-export-pipeline-x:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_PIPELINE_X_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' ''
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' 'PIPELINE_X_FORCE_COMPILE=1'

# wave883 B7B: drop single-token MAKE= inject on rebuild-leaves phonies (G.7 hygiene).
# Shell MAKE="${MAKE:-make}" + GNU make auto-exports MAKE; nested make uses recipe env.
# wave888 B7B: pure @bash thin-call (drop dual chmod + @./scripts form; family COUNT in tip).
bootstrap-driver-seed-pipeline-x:
	@bash scripts/bootstrap_driver_seed_rebuild_leaves.sh pipeline-x

# §5b #3 — satellite runtime/diag/simd forced seed path (XLANG_G05_PREFER_X_O=0)
# Body: bootstrap_driver_seed_rebuild_leaves.sh sat; list = DRIVER_SEED_SAT_REBUILD_OBJS only.
bootstrap-driver-seed-export-sat-rebuild:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_SAT_REBUILD_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' '-B'
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' 'XLANG_G05_PREFER_X_O=0'

bootstrap-driver-seed-sat-rebuild:
	@bash scripts/bootstrap_driver_seed_rebuild_leaves.sh sat

# §5b #4 — lsp / frontend alias objs (list = DRIVER_SEED_LSP_X_OBJS only)
bootstrap-driver-seed-export-lsp-x-objs:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_LSP_X_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' ''
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' ''

bootstrap-driver-seed-lsp-x-objs:
	@bash scripts/bootstrap_driver_seed_rebuild_leaves.sh lsp

# §5b #5 — x_seed_bridge.o (list = DRIVER_SEED_BRIDGE_OBJS only)
bootstrap-driver-seed-export-bridge:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_BRIDGE_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' ''
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' ''

bootstrap-driver-seed-bridge:
	@bash scripts/bootstrap_driver_seed_rebuild_leaves.sh bridge

# §5b #12 — runtime_panic.o (list = DRIVER_SEED_PANIC_OBJS only; platform recipe stays Makefile)
bootstrap-driver-seed-export-panic:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_PANIC_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' ''
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' ''

bootstrap-driver-seed-panic:
	@bash scripts/bootstrap_driver_seed_rebuild_leaves.sh panic

# §5b #6 — USER_ASM seed objs (list = DRIVER_SEED_USER_ASM_SEED_OBJS → USER_ASM_SEED_OBJS)
bootstrap-driver-seed-export-user-asm:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_USER_ASM_SEED_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' ''
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' ''

bootstrap-driver-seed-user-asm-seed-objs:
	@bash scripts/bootstrap_driver_seed_rebuild_leaves.sh user-asm

# §5b #7 — pipeline_glue_standalone.o (list = DRIVER_SEED_ASM_GLUE_OBJS)
bootstrap-driver-seed-export-glue:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_ASM_GLUE_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' ''
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' ''

bootstrap-driver-seed-asm-glue-standalone:
	@bash scripts/bootstrap_driver_seed_rebuild_leaves.sh glue


# §5b #10 — class-G filtered (Darwin); empty expansion on Linux
bootstrap-driver-seed-filtered-objs: $(BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS)

# §5b #9 — host stubs (always run shell so post-partial refresh is not skipped)
# SCAN_BASE/CFLAGS/OUT: export leaf only. Body: bootstrap_driver_seed_host_stubs.sh.
# PHONY thin leaf always regenerates (partial is optional scan peer, not a make prereq).
bootstrap-driver-seed-export-host-stubs:
	@printf 'SEED_STUBS_CC=%s\n' '$(CC)'
	@printf 'SEED_STUBS_CFLAGS=%s\n' '$(CFLAGS)'
	@printf 'SEED_STUBS_OUT=%s\n' '$(USER_ASM_SEED_HOST_STUBS)'
	@printf 'SEED_STUBS_HOST_DIR=%s\n' '$(USER_ASM_SEED_HOST_DIR)'
	@printf 'SEED_STUBS_GEN_C=%s\n' '$(USER_ASM_SEED_HOST_DIR)/asm_full_link_stubs.c'
	@printf 'SEED_STUBS_SCAN_BASE=%s\n' '$(DRIVER_SEED_HOST_STUBS_SCAN_BASE)'
	@printf 'SEED_STUBS_PERL=%s\n' 'scripts/gen_asm_full_link_stubs.pl'

# wave883 B7B: drop single-token MAKE= inject (shell MAKE default + make auto-export).
bootstrap-driver-seed-host-stubs:
	@bash scripts/bootstrap_driver_seed_host_stubs.sh

# §5b #11 — phase1 / final link
# OBJS+CFLAGS: Makefile export only (G.7). Link body: bootstrap_driver_seed_link.sh.
# KEY=value SEED_LINK_* export for shell parse (no dual .o list in shell).
# wave772 · 11.1.4 pure-ld: also export SEED_LINK_LD / MULTIDEF / ENTRY / PURE_OK / LD_TAIL.
# wave853 B7B: SEED_LINK_OBJS → $(BOOTSTRAP_DRIVER_SEED_{PHASE1,FINAL}_LINK_OBJS)
#   (composites.mk; no dual re-list of LINK_BASE + user-asm + glue).
#   Glue is RELINK_XLANG_GLUE_SUFFIX inside the bags (historic target-specific
#   DRIVER_SEED_GLUE_SUFFIX override on these leaves retired with the bags).
# PLATFORM: SHARED — PURE_OK when freestanding crt0 entry; WINDOWS residual stays CC.

# pure-ld eligibility: freestanding crt0 + -e _start (not main_driver / not PE residual).
# PLATFORM: LINUX x86_64 · MACOS arm64/x86_64 — pure ld + tail libs; else PURE_OK=0 → CC residual.
ifeq ($(XLANG_LEGACY_MAIN_C),1)
SEED_LINK_PURE_OK = 0
SEED_LINK_ENTRY =
SEED_LINK_LD_TAIL =
else ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
SEED_LINK_PURE_OK = 1
SEED_LINK_ENTRY = -e _start
# nostartfiles-style cold seed still pulls libc via former CC driver; pure-ld needs -lc.
SEED_LINK_LD_TAIL = -lc
else
SEED_LINK_PURE_OK = 0
SEED_LINK_ENTRY =
SEED_LINK_LD_TAIL =
endif
else ifeq ($(UNAME_S),Darwin)
SEED_LINK_PURE_OK = 1
SEED_LINK_ENTRY = -e _start
# PLATFORM: MACOS — syslibroot/arch/platform_version composed in bootstrap_driver_seed_link.sh
SEED_LINK_LD_TAIL = -lSystem
else
SEED_LINK_PURE_OK = 0
SEED_LINK_ENTRY =
SEED_LINK_LD_TAIL =
endif

# KEY=value lines (first '=' splits). Avoid TAB: some make/shell paths mangle \t.
bootstrap-driver-seed-export-phase1-link:
	@printf 'SEED_LINK_CC=%s\n' '$(CC)'
	@printf 'SEED_LINK_CFLAGS=%s\n' '$(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS)'
	@printf 'SEED_LINK_LD=%s\n' '$(LD)'
	@printf 'SEED_LINK_MULTIDEF=%s\n' '$(LD_R_MULTIDEF_FLAGS)'
	@printf 'SEED_LINK_ENTRY=%s\n' '$(SEED_LINK_ENTRY)'
	@printf 'SEED_LINK_LD_TAIL=%s\n' '$(SEED_LINK_LD_TAIL)'
	@printf 'SEED_LINK_PURE_OK=%s\n' '$(SEED_LINK_PURE_OK)'
	@printf 'SEED_LINK_OUT=%s\n' 'xlang-seed-phase1'
	@printf 'SEED_LINK_OBJS=%s\n' '$(BOOTSTRAP_DRIVER_SEED_PHASE1_LINK_OBJS)'

bootstrap-driver-seed-export-final-link:
	@printf 'SEED_LINK_CC=%s\n' '$(CC)'
	@printf 'SEED_LINK_CFLAGS=%s\n' '$(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS)'
	@printf 'SEED_LINK_LD=%s\n' '$(LD)'
	@printf 'SEED_LINK_MULTIDEF=%s\n' '$(LD_R_MULTIDEF_FLAGS)'
	@printf 'SEED_LINK_ENTRY=%s\n' '$(SEED_LINK_ENTRY)'
	@printf 'SEED_LINK_LD_TAIL=%s\n' '$(SEED_LINK_LD_TAIL)'
	@printf 'SEED_LINK_PURE_OK=%s\n' '$(SEED_LINK_PURE_OK)'
	@printf 'SEED_LINK_OUT=%s\n' '$(TARGET)'
	@printf 'SEED_LINK_OBJS=%s\n' '$(BOOTSTRAP_DRIVER_SEED_FINAL_LINK_OBJS)'

# wave856 · B7B LINK_OBJS shell-load via make export leaves (G.7 有则补全 on
# bootstrap_driver_seed_export-*-link pattern). Full bags need make expansion
# (nested $(...) / Darwin filtered pipeline picks) — NOT pure mk text parse
# (wave855 REQUIRED was fixed multi-token only).
# Consumers load when env unset: RXL/BTC → RELINK_PRODUCT; XXL; XNC; BXF; BS.
# Makefile archaeology thin-call recipes drop multi-token *_LINK_OBJS= env.
# PLATFORM: SHARED — KEY=value; no compile/link side effects.
# NOT physical delete — thin edges + B2 + mk lists remain residual (CFLAGS → wave857 export leaves).
export-relink-product-link-objs:
	@printf 'LINK_OBJS=%s\n' '$(RELINK_PRODUCT_LINK_OBJS)'

export-xlang-x-link-objs:
	@printf 'LINK_OBJS=%s\n' '$(XLANG_X_LINK_OBJS)'

export-xnc-link-objs:
	@printf 'LINK_OBJS=%s\n' '$(XLANG_NO_C_FRONTEND_LINK_OBJS)'

export-bxf-link-objs:
	@printf 'LINK_OBJS=%s\n' '$(DRIVER_SEED_X_FRONTEND_LINK_OBJS)'

export-bs-link-objs:
	@printf 'LINK_OBJS=%s\n' '$(BOOTSTRAP_SELF_LINK_OBJS)'

# wave858 · B7B LEGACY xlang-c LINK_OBJS shell-load via make export leaf (G.7).
# Bag = $(LEGACY_XLANG_C_PREREQS) from composites.mk (wave822 list authority).
# Consumers: scripts/legacy_xlang_c_link.sh when env unset.
# PLATFORM: SHARED — KEY=value; no compile/link side effects.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
export-legacy-xlang-c-link-objs:
	@printf 'LINK_OBJS=%s\n' '$(LEGACY_XLANG_C_PREREQS)'

# wave891 B7B: archaeology HOST_CC_OBJS_CORE LINK_OBJS export leaf (G.7 有则补全
# export-*-link-objs pattern). List authority mk/objs_core.mk OBJS=$(OBJS_CORE).
# NOT physical delete — thin edges + B2 + mk lists remain residual.
export-objs-core-link-objs:
	@printf 'LINK_OBJS=%s\n' '$(OBJS)'

# wave859 · B7B XXP/BXC multi-token bag shell-load via make export leaves (G.7).
# xlang-x-pipeline (wave845 shell-primary) still required multi-token XXP_* env
# from Makefile; LINK needs make expansion ($(USER_ASM_LINK) nested + PIPELINE_LIBS
# platform ifeq). bootstrap-x-compiler still required BXC_LINK_OBJS=$(OBJS).
# Shell loads when unset; Makefile recipes drop multi-token XXP_*/BXC_ env.
# PLATFORM: SHARED — KEY=value; no compile/link side effects.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
export-xxp-link-bags:
	@printf 'XXP_BASE_OBJS=%s\n' '$(PIPELINE_X_BASE_OBJS)'
	@printf 'XXP_FRONTEND_OBJS=%s\n' '$(PIPELINE_X_FRONTEND_OBJS)'
	@printf 'XXP_LINK_OBJS=%s\n' '$(PIPELINE_X_LINK_OBJS)'
	@printf 'XXP_SATELLITE_OBJS=%s\n' '$(PIPELINE_X_SATELLITE_OBJS)'
	@printf 'XXP_LSP_DIAG=%s\n' '$(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes.o'
	@printf 'XXP_LIBS=%s\n' '$(PIPELINE_LIBS)'

export-bxc-link-objs:
	@printf 'LINK_OBJS=%s\n' '$(OBJS)'

# wave860 · B7B driver_leaf BASE_CFLAGS multi-token shell-load via make export leaf (G.7).
# wave814/828 product leaves still required multi-token BASE_CFLAGS="$(CFLAGS)
# $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc" on thin-call recipes. Composition
# needs make expansion (OPT CFLAGS += -O2; PIPELINE_GEN_CFLAGS CC_IS_CLANG ifeq).
# Shell loads when unset; Makefile recipes drop multi-token BASE_CFLAGS= env.
# PLATFORM: SHARED — KEY=value; no compile side effects.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
export-driver-leaf-base-cflags:
	@printf 'BASE_CFLAGS=%s\n' '$(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc'

# wave862 · B7B try-heat CFLAGS/PIPELINE_GEN_CFLAGS bulk shell-load via make export leaf (G.7).
# Heat thin-call recipes historically re-injected multi-token
#   CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)"
# on every FORCE leaf. Composition needs make expansion (OPT CFLAGS += -O2;
# PIPELINE_GEN_CFLAGS BASE + CC_IS_CLANG ifeq) — not pure shell default.
# Shell loads when unset; Makefile try-heat recipes drop CFLAGS=/PIPELINE_GEN=
# env (keep CC= + leaf-specific extras). PLATFORM: SHARED — KEY=value; no compile.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
export-try-heat-cflags:
	@printf 'CFLAGS=%s\n' '$(CFLAGS)'
	@printf 'PIPELINE_GEN_CFLAGS=%s\n' '$(PIPELINE_GEN_CFLAGS)'

# wave857 · B7B LINK CFLAGS shell-load via make export leaves (G.7 有则补全 on
# wave856 LINK_OBJS export pattern). Flags need make expansion (DRIVER_SEED_LINK_FLAGS /
# ASM_GLUE_DUP_LDFLAGS / MAIN_LINK_FLAGS / platform ifeq) — NOT pure mk text.
# Bags (4 formulas / 6 shells): relink-product (RXL+XXL+BTC codegen); btc-typeck;
# xnc (XNC+BS); bxf. Makefile recipes drop multi-token *_LINK_CFLAGS=/BTC_CFLAGS=/BS_LINK_FLAGS=.
# PLATFORM: SHARED — KEY=value; no compile/link side effects.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
export-relink-product-link-cflags:
	@printf 'LINK_CFLAGS=%s\n' '$(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS)'

export-btc-typeck-link-cflags:
	@printf 'LINK_CFLAGS=%s\n' '$(CFLAGS) -DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_TYPECK $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS)'

export-xnc-link-cflags:
	@printf 'LINK_CFLAGS=%s\n' '$(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(MAIN_LINK_FLAGS)'

export-bxf-link-cflags:
	@printf 'LINK_CFLAGS=%s\n' '$(CFLAGS) -DXLANG_USE_X_DRIVER -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN'

# wave883 B7B: drop single-token MAKE= inject (align final-link wave879; shell MAKE default).
bootstrap-driver-seed-phase1-link:
	@bash scripts/bootstrap_driver_seed_link.sh phase1

# wave879 B7B: drop multi-token MAKE/TARGET inject (G.7 hygiene).
# Shell defaults own MAKE/TARGET (bootstrap_driver_seed_link). Thin ./scripts only.
bootstrap-driver-seed-final-link:
	@bash scripts/bootstrap_driver_seed_link.sh final

# wave744 · 11.3 residual: prereq *edges* satisfied inside bootstrap_driver_seed.sh
# via scripts/driver_seed_ensure_prereqs.sh (catalog DRIVER_SEED_PREREQS + glue
# companion). Makefile no longer carries $(DRIVER_SEED_PREREQS) as make-graph
# deps on this phony (G.7: list still mk only; shell owns edge walk).
# wave879 B7B: drop multi-token MAKE/TARGET/XLANG_C/SKIP inject (G.7 hygiene).
# Shell defaults own env; XLANG_SKIP_SEED_SMOKE still honored from process env.
# PLATFORM: SHARED — thin phony leaf; leaf .o pattern rules remain residual.
bootstrap-driver-seed:
	@bash scripts/bootstrap_driver_seed.sh
endif

# 与 bootstrap-driver-seed 相同；保留别名供脚本引用
# bootstrap seed 链 需 glue 类型头（与 build_xlang_asm B-strict 同源）。
# PLATFORM: SHARED — run i64 ABI guard before extract so glue never sees int32_t Expr.int_val.
# wave833: FORCE dep-thin — prereqs → FORCE + ensure; shell owns gen/extract mtime
# + XLANG_GLUE_TYPES_FORCE + i64 ABI guard call (G.7). NOT physical delete.
# Extract algorithm remains extract_pipeline_glue_types.pl (not reimplemented).
build_asm/pipeline_glue_types.inc: FORCE scripts/ensure_pipeline_glue_types.sh
	@bash scripts/ensure_pipeline_glue_types.sh

# G-02f-17：pipeline_bootstrap_orchestration — joined wave905 multi-target $(R1_SEED_MAP_OBJS).
# Archaeology: wave755 R1 · orch -Ibuild_asm -D…NO_PIPELINE_RUN_WRAPPER · wave797 FORCE thin
# (try-heat owns seed/.x + pipeline_gen.c + pipeline_glue_types.inc) — body in try-heat.

# $(ASM_GLUE_STANDALONE_O) / pipeline_glue_standalone — joined wave905 multi-target $(R1_SEED_MAP_OBJS).
# Archaeology: wave759 R1 seed-map · wave794 multi-c mtime · wave889 ensure_one owns dirname mkdir.

# G-02f-11：pipeline_glue_strict_minimal 产品 seed — joined wave904 multi-target $(R1_MISC_BASENAME_OBJS).
# Archaeology: wave754 R1 · wave792 FORCE · wave889 ensure_one owns dirname mkdir — body in try-heat.

# relink-xlang 与 bootstrap-driver-seed 链接同一组 .o；list authority =
# mk/driver_seed_composites.mk RELINK_XLANG_PREREQS (wave822 B7B; not physical delete).
# Consumers: bootstrap-typeck / bootstrap-codegen expand $(RELINK_XLANG_PREREQS).
# Note: those targets appear *before* this include in file order — GNU make
# expands prereqs at parse time, so late consumers still see empty RELINK unless
# the rule is moved after composites include (pre-existing; not this wave).
# driver/fmt_check 变更后快速重链 xlang（不跑 asm.x -E；需已有 build_asm/seed_host/asm_backend_partial.o）
# relink-xlang-lexer：仅重建 lexer_x.o 并重链，不触发 driver/typeck *_gen.c 再生（迭代 token enum 修复用）。
# 提供真实 xlang_asm 目标，避免同名旧文件让 `make xlang_asm` 静默跳过重建。
# Darwin 等宿主直接走 relink-xlang 的已过滤拓扑，避免 build_xlang_asm.sh 直链 seed_host partial 时重复符号。
# G-05 100%：产品路径编排在 scripts/g05_*.sh（零 make 于 prepare/ensure/export/link）。
# 下列目标仅：
# - 单文件 .o 规则（冷启动隐式）
# - 薄包装兼容 `make xlang_asm` / `make relink-xlang` → 委托 shell
# - g05-ensure / g05-export 兼容别名 → 同名 shell 脚本
.PHONY: xlang_asm relink-xlang relink-xlang-lexer refresh-xlang-asm-gate \
	g05-ensure-relink-prereqs g05-export-relink

# 兼容：委托 scripts/g05_ensure_relink_prereqs.sh（产品路径不再依赖本 recipe 图）
g05-ensure-relink-prereqs:
	@bash scripts/g05_ensure_relink_prereqs.sh

# 兼容：委托 scripts/g05_relink_env.sh（与 shell 清单单一真相）
g05-export-relink:
	@bash scripts/g05_relink_env.sh

# 兼容入口：委托 G-05 shell 编排（无 recipe 内嵌 cc；产品路径零 make）
# wave885 B7B residual: drop G05_SYNC_ASM=0/1 recipe inject (G.7 hygiene).
# Authority: scripts/g05_prepare_and_relink.sh — default sync xlang→xlang_asm;
# --no-sync for relink-xlang only. Env G05_SYNC_ASM still works for direct shell.
# NOT physical delete — thin edges + B2 + mk lists + LD/pipeline bags remain.
# PLATFORM: SHARED — same g05 shell body on mac / Ubuntu / Windows host.
# wave892 B7B residual: drop dual @echo after thin-call (G.7 form hygiene).
# Shell g05_prepare_and_relink prints OK; pure @bash only.
relink-xlang:
	@bash scripts/g05_prepare_and_relink.sh --no-sync

xlang_asm:
	@bash scripts/g05_prepare_and_relink.sh

# wave849: full body → scripts/relink_xlang_lexer.sh (G.7 有则补全; shell owns seed
#   gate + host-cc link + XLANG_C/bootstrap_xlangc sync).
# wave850 B7B: RXL_LINK_OBJS → $(RELINK_PRODUCT_LINK_OBJS) (composites.mk; same bag
#   as BTC_OBJS typeck/codegen — no dual inline product link inventory).
# wave854 B7B: RELINK_XLANG_REQUIRED_OBJS list authority → composites.mk.
# wave855: shell loads REQUIRED from mk (no Makefile multi-token env export).
# wave856: shell loads LINK_OBJS via export-relink-product-link-objs (no multi-token RXL_LINK_OBJS=).
# wave879 B7B: drop multi-token MAKE/CC/TARGET/XLANG_C/BOOTSTRAP inject (G.7 hygiene).
# Shell defaults own env (relink_xlang_lexer). Thin @bash only.
# NOT physical delete — prereq make-graph (lexer_x.o / FILTERED / GLUE) + thin edges
#   + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell owns preflight + link + product alias sync.
relink-xlang-lexer: lexer_x.o $(RELINK_XLANG_FILTERED_OBJS) $(RELINK_XLANG_GLUE_SUFFIX) scripts/relink_xlang_lexer.sh
	@bash scripts/relink_xlang_lexer.sh

# wave892 B7B residual: drop pure @echo alias body → @true (G.7 form hygiene).
# Alias of bootstrap-driver-seed (+ USER_ASM_LINK graph elsewhere); no dual status body.
bootstrap-driver-seed-user-asm: bootstrap-driver-seed
	@true

# 实验：不链 C lexer/parser/typeck/codegen；依赖已成功的 bootstrap-driver-seed 产物。(-E-extern / 泛型单态 C 路径不可用)
# List authority: mk/archaeology_experiment_objs.mk (wave821).
# wave847: full body → scripts/xlang_no_c_frontend.sh (G.7 有则补全; shell owns seed
#   gate + host-cc link). Lists stay mk expansion (DRIVER_NO_C_FRONTEND_OBJS /
#   DRIVER_SUBCMD / PIPELINE_LIBS). NOT physical delete — prereq make-graph +
#   thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell owns preflight + link orchestration.
# wave851 B7B: XNC_LINK_OBJS → $(XLANG_NO_C_FRONTEND_LINK_OBJS)
#   (archaeology_experiment_objs.mk; no dual inline no-C full link inventory).
# wave854 B7B: XLANG_NO_C_FRONTEND_REQUIRED_OBJS list authority →
#   archaeology_experiment_objs.mk.
# wave855: shell loads REQUIRED from mk (no Makefile multi-token env export).
# wave856: shell loads LINK_OBJS via export-xnc-link-objs (no multi-token XNC_LINK_OBJS=).
# wave880 B7B: drop multi-token MAKE/CC/OUT inject (G.7 hygiene).
# Shell defaults OUT=xlang-no-c-frontend. Thin @bash only.
xlang-no-c-frontend: $(DRIVER_NO_C_FRONTEND_OBJS) src/lsp/lsp_diag_stubs_no_c.o scripts/xlang_no_c_frontend.sh
	@bash scripts/xlang_no_c_frontend.sh

# 注意：Makefile 中存在同名规则 `xlang-x:`，不能把 `xlang-x` 列为本目标 prerequisite，否则会先执行重链接口而非仅检测文件是否存在。
# wave873: full body → scripts/regen_lsp_gens_x.sh (G.7 有则补全).
# Shell owns XLANG_X gate + rm four gens + make file targets + OK line.
# Gen *body* remains ensure_lsp_pipeline_gen / ensure_archaeology_gen (thin leaves).
# wave879 B7B: drop multi-token MAKE/XLANG_X inject (G.7 hygiene).
# Shell defaults own MAKE/XLANG_X (regen_lsp_gens_x). Thin @bash only.
# NOT physical delete — thin edges + B2 + mk lists.
# PLATFORM: SHARED — orchestration only; gen pin/-E policy stays ensure shells.
regen-lsp-gens-x: scripts/regen_lsp_gens_x.sh
	@bash scripts/regen_lsp_gens_x.sh

# 仅重链 ./xlang-x；pipeline/driver/preprocess 的 .x 变更会经对应 *_x.o 目标触发重编后再链接。
# wave846: full body → scripts/xlang_x.sh (G.7 有则补全; shell owns seed gate + host-cc
#   link). Lists stay mk expansion (composites / user_asm / subcmd / link_picks).
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell owns preflight + link orchestration.
# wave851 B7B: XXL_LINK_OBJS → $(XLANG_X_LINK_OBJS)
#   (composites.mk; no dual inline xlang-x product link inventory).
# wave854 B7B: XLANG_X_REQUIRED_OBJS list authority → composites.mk.
# wave855: shell loads REQUIRED from mk (no Makefile multi-token env export).
# wave856: shell loads LINK_OBJS via export-xlang-x-link-objs (no multi-token XXL_LINK_OBJS=).
# wave879 B7B: drop multi-token MAKE/CC/XLANG_X inject (G.7 hygiene).
# Shell defaults own env (xlang_x). Thin @bash only.
xlang-x: build-seed-asm-host $(DRIVER_SEED_OBJS) $(XLANG_X_PIPELINE_LINK_O) $(XLANG_X_USER_ASM_OBJS) driver_x.o preprocess_x.o $(RELINK_XLANG_GLUE_SUFFIX) scripts/xlang_x.sh
	@bash scripts/xlang_x.sh

# Stage2：xlang-x 用 -x -E-extern 生成 _gen2.c 并链出 xlang-x2，与 xlang-x 行为对比（脚本内会 make xlang-x / bootstrap-driver-seed）
# wave893 B7B residual: pure @bash scripts/ form (drop @bash ./ compiler-root body).
# Authority: scripts/verify-selfhost-stage2.sh (G.7 有则补全; body moved under scripts/).
# Root shim compiler/verify-selfhost-stage2.sh remains for CI/tests path compatibility.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — thin orchestration only.
verify-selfhost-stage2: scripts/verify-selfhost-stage2.sh
	@bash scripts/verify-selfhost-stage2.sh

# 可选：在 bootstrap-verify 之外单独跑 Stage2（不阻塞 PR 默认 CI）
# wave892 B7B residual: drop pure @echo alias body → @true (G.7 form hygiene).
bootstrap-verify-stage2: verify-selfhost-stage2
	@true

# M5：B-strict 二遍 build_xlang_asm（xlang_asm -> xlang_asm2），不依赖 xlang-x -x -E。
# wave893 B7B residual: pure @bash scripts/ form (drop @bash ./ compiler-root body).
# Authority: scripts/verify-selfhost-stage2-bstrict.sh (G.7 有则补全).
# Root shim remains for CI/tests path compatibility.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — thin orchestration only.
verify-selfhost-stage2-bstrict: scripts/verify-selfhost-stage2-bstrict.sh
	@bash scripts/verify-selfhost-stage2-bstrict.sh

# wave892 B7B residual: drop pure @echo alias body → @true (G.7 form hygiene).
bootstrap-verify-stage2-bstrict: verify-selfhost-stage2-bstrict
	@true

# B-hybrid：asm 构建（无 SKIP_GEN），成功则 xlang_asm 覆盖 $(TARGET)；失败保留 seed。
# wave872: full body → scripts/bootstrap_driver_hybrid.sh (G.7 有则补全).
# Shell owns build_xlang_asm (no SKIP_GEN) + xlang_asm→TARGET replace / soft-skip.
# wave882 B7B: drop single-token TARGET= inject (G.7 hygiene).
# Shell TARGET="${TARGET:-xlang}" + CLI auto-export; thin @bash only.
# $(TARGET) prereq stays make graph.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration only; ABI stays in build_xlang_asm.
bootstrap-driver-hybrid bootstrap-driver-asm: $(TARGET) scripts/bootstrap_driver_hybrid.sh
	@bash scripts/bootstrap_driver_hybrid.sh

# 仅 asm、不生成 C（B-hybrid 别名，保留历史目标名）
bootstrap-driver-asm-only: bootstrap-driver-hybrid

# M7 默认自举：B-strict（SKIP_GEN，链接审计无 cc -c pipeline_gen.c）；xlang_asm 默认覆盖 $(TARGET)。
# wave719: body → scripts/bootstrap_driver_bstrict.sh (G.7); prereq seed 仍 make 图。
# 仅保留 xlang_asm、不覆盖 seed：XLANG_BSTRICT_NO_REPLACE=1 make bootstrap-driver-bstrict
# wave882 B7B: drop TARGET= from multi-token inject (shell TARGET default + CLI).
# wave883 B7B: drop MAKE= from multi-token inject (shell MAKE default + make auto-export).
# wave887 B7B: drop ENSURE_SEED=0 inject — seed is make prereq; shell default 1 only
#   fires when ./$TARGET missing (direct xlang-build / CLI override still ok).
bootstrap-driver-bstrict: bootstrap-driver-seed
	@bash scripts/bootstrap_driver_bstrict.sh

# P0 asm 门禁：strict xlang_asm 与 seed+migrate-x-objs 对齐（M-3 含 typeck/codegen/ast）；xlang_asm2 仍保留 gen2。
# wave734: body → scripts/refresh_xlang_asm_gate.sh (G.7)
# wave735: migrate → scripts/migrate_x_objs.sh (no make migrate-x-objs inside refresh).
# wave882 B7B: drop TARGET= from multi-token inject (shell TARGET default + CLI).
# wave883 B7B: drop MAKE= from multi-token inject (shell MAKE default + make auto-export).
# wave887 B7B: drop NO_REPLACE passthrough inject — shell reads env/CLI; make CLI auto-export.
refresh-xlang-asm-gate:
	@bash scripts/refresh_xlang_asm_gate.sh

# 日常快路径：仅 strict relink（前提 build_asm/*.o 已由 prior bootstrap 产出；改 glue/runtime/link 时用，~30s）。
# wave868: full body → scripts/relink_xlang_asm_bstrict_runtime_objs.sh (G.7 有则补全;
#   historic dual body retired — script was already named equivalent). Thin-call only.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell owns prereq gate + XLANG_ASM_* + build_xlang_asm invoke.
bootstrap-driver-bstrict-relink: scripts/relink_xlang_asm_bstrict_runtime_objs.sh
	@bash scripts/relink_xlang_asm_bstrict_runtime_objs.sh

# 日常/release 默认路径（M7）：等价 bootstrap-driver-bstrict；冷启动须先 bootstrap-driver-seed 或 make all。
bootstrap-driver: bootstrap-driver-bstrict

# E-06 v5 / C-03 v2：Windows MSYS2 B-strict（SKIP_GEN，禁 cc -c pipeline_gen.c）；验收 XLANG_WIN_BSTRICT=1 ./tests/run-bootstrap-bstrict-windows-gate.sh
# wave892 B7B residual: drop pure @echo alias body → @true (G.7 form hygiene).
# Gate: XLANG_WIN_BSTRICT=1 ./tests/run-bootstrap-bstrict-windows-gate.sh (MSYS2).
bootstrap-driver-bstrict-windows: bootstrap-driver-bstrict
	@true

# M4 Linux：crt0 + full_asm .o 链（B-partial，无 runtime_driver）；与 bootstrap-driver-bstrict（asm_only_strict）分轨验收。
# wave869: full body → scripts/bootstrap_driver_crt0.sh (G.7 有则补全).
# Shell owns build_xlang_asm invoke + crt0 log gates + xlang_asm post-check.
# wave882 B7B: drop single-token TARGET= inject (shell TARGET default + CLI auto-export).
# Seed prereq stays make graph. Thin @bash only.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration only; ABI stays in build_xlang_asm.
bootstrap-driver-crt0: bootstrap-driver-seed scripts/bootstrap_driver_crt0.sh
	@bash scripts/bootstrap_driver_crt0.sh

# build-user-asm-backend：自 xlang 编 build_asm/*.o（完整 asm 自举）；seed 默认用 build-seed-asm-host（xlang-c -E）。
build-user-asm-backend:
	@bash scripts/build_user_asm_backend.sh

# Goal 2（用 asm 后端构建 xlang）：构建最小 C 桩 + 可选执行 asm 自举脚本（需先 bootstrap-driver）
# wave892 B7B residual: drop dual pure @echo status body → @true (G.7 form hygiene).
# Prereqs own the objects; full asm path remains bootstrap-asm-full / build_xlang_asm.sh.
bootstrap-asm: $(TARGET) src/asm/runtime_asm_build.o src/runtime_driver.o
	@true
# wave887 B7B: drop XLANG= inject — build_xlang_asm defaults XLANG=./$TARGET (or env/CLI).
bootstrap-asm-full: bootstrap-driver bootstrap-asm
	@bash scripts/build_xlang_asm.sh

# Goal 2 辅助：检查 build_asm/*.o 的 __text 段是否非空（需先有 build_asm，例如刚跑过 build_xlang_asm.sh）。严格失败：XLANG_ASM_QUALITY_STRICT=1 make check-asm-o-quality
# wave887 B7B: drop dead XLANG= inject (quality scan does not use XLANG; thin @sh only).
check-asm-o-quality: $(TARGET)
	@bash scripts/check_asm_o_quality.sh

# 6.4 验收：宿主编译器能编译整机 .x（typeck+codegen+driver）并产出新 xlang，且新 xlang 能编译运行测试（return-value 返回 42 视为成功）。用 seed 构建 xlang 以保证通过（asm 路径修好后可改为 bootstrap-driver）。
# seed 的 .x 单文件路径把 C 写到 -o；须 $(CC) 链成可执行再运行（与 xlang-c 直接出 Mach-O/ELF 不同）。
# wave871: full body → scripts/check_6_4.sh (G.7 有则补全; shell owns emit-C + host-cc + exit 42).
# wave879 B7B: drop multi-token TARGET/CC inject (G.7 hygiene).
# Shell defaults own TARGET/CC (check_6_4). Thin @bash only.
# Seed prereq stays make graph (bootstrap-driver-seed).
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell owns seed-path 6.4 smoke orchestration.
check-6.4: bootstrap-driver-seed scripts/check_6_4.sh
	@bash scripts/check_6_4.sh

# 首次/从零构建：一条命令得到 xlang-c + build_tool（build-tool 仅依赖 xlang-c，与 lsp_gen 生成物无环）。与 README「读者一次做对」一致。
first-time: build-tool

# 阶段 7：build.x 驱动 build_tool（G-05：build_runner + build_runtime_x，无 build_runtime.inc）
# G-05（2026-07-10）：
# - 默认用 seeds/ 下 pinned *_gen.c（-x -E 对 build_runner.entry / 大 TU 仍不稳定；C 前端 -E-extern 已随 G-02a 不可用）
# - 可选：XLANG_BUILD_TOOL_REGEN=1 且 ./xlang 可 -x -E 时尝试刷新 build_gen + build_runtime_x_gen
# - build_run_asm_build 默认 `make xlang_asm`（与 relink 定稿一致）；FULL=1 → bootstrap-driver-bstrict
# - main 调用 entry（build_runner.x），非 build_entry
# wave718: body → scripts/build_tool.sh (G.7; xlang-build calls shell directly)
# wave866 B7B: drop multi-token CFLAGS='$(CFLAGS)' inject (G.7 hygiene).
# Shell loads export-try-heat-cflags when CFLAGS unset (same authority as try-heat
# / migrate wave862–865).
# wave879 B7B: drop multi-token CC/XLANG_BUILD_TOOL_REGEN inject (G.7 hygiene).
# Shell defaults own CC/MAKE/REGEN (build_tool; REGEN still from process env).
# PLATFORM: SHARED — host-cc residual for G-05 entry until BC retires build_tool C.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
build-tool:
	@bash scripts/build_tool.sh

# wave831: FORCE dep-thin — shell owns seed mtime (cc_inc_tu; not physical delete).
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
src/build_tool_main.o: FORCE scripts/cc_inc_tu.sh
	# wave889 B7B residual: bare sh → pure @bash thin-call form.
	@bash scripts/cc_inc_tu.sh seeds/build_tool_main.from_x.c $@

# 别名：与 build-tool 相同（历史 target 名）
build-tool-x: build-tool

# 运行 build_tool 产出 xlang（等价于 make bootstrap-driver，无需执行 Makefile bootstrap-driver 目标）
# wave874: full body → scripts/build_via_tool.sh (G.7 有则补全; shell owns
#   ./build_tool ./TARGET invoke + OK; also xlang-build run_build_tool authority).
# wave882 B7B: drop single-token TARGET= inject (shell TARGET default + CLI auto-export).
# build-tool prereq stays make graph. Thin @bash only.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration only; ABI stays in build_tool / g05.
build-via-tool: build-tool scripts/build_via_tool.sh
	@bash scripts/build_via_tool.sh


# 阶段 8.1/8.2：用 seed 产出 xlang₁（C 生成 pipeline_gen.c/driver_gen.c 再链接）；用 xlang₁ 再编得到 xlang₂。两代跑 run-all 一致即自举验证通过。
# 注：asm 链接就绪（Goal 2）后可改为 bootstrap-driver，则 xlang₁ 为 asm 版，实现「无 C 生成」自举。
# 与 bootstrap-driver-seed 一致；std.io 纯 .x（F-03 v2/v3）。
# bootstrap-self 末尾：stage2 对 return-value -o /tmp/out_self 可与 run-return-value.sh 一致产出 Mach-O/ELF；若为 C 源码则用 cc -x c 链出临时 bin（勿假定 -o *.c 必为 C）。
# wave785 B7c: lsp_io_x/lsp_x/lsp_io_std_heap_x via existing thin leaves (ensure_gen_x_o / driver_leaf);
#   no dual archaeology $(CC) -c (G.7 有则补全). Link residual stays B7d.
# wave843: full body → scripts/bootstrap_self.sh (G.7 有则补全; shell owns stage1 snapshot +
#   satellite ensure + stage2 host-cc link + out_self smoke). BS_LINK_OBJS = mk expansion.
# wave851 B7B: BS_LINK_OBJS → $(BOOTSTRAP_SELF_LINK_OBJS) (composites.mk; no dual
#   inline DRIVER_SEED_LINK_BASE re-list).
# wave856: shell loads LINK_OBJS via export-bs-link-objs (no multi-token BS_LINK_OBJS=).
# wave879 B7B: drop multi-token TARGET/CC/MAKE inject (G.7 hygiene).
# Shell defaults own env (bootstrap_self). Thin @bash only.
# NOT physical delete — prereq bootstrap-driver-seed + thin edges + mk lists remain residual.
# PLATFORM: SHARED — shell owns stage2 link/smoke orchestration.
bootstrap-self: bootstrap-driver-seed scripts/bootstrap_self.sh
	@bash scripts/bootstrap_self.sh

# 阶段 8.3 seed：两代 xlang（xlang_stage1/xlang_stage2）烟测；B-strict 主路径见 check-7.2-bstrict。
# wave870: full body → scripts/check_7_2.sh (G.7 有则补全; shell owns stage loop + smoke suite).
# wave882 B7B: drop single-token TARGET= inject (shell TARGET default + CLI auto-export).
# Thin @bash only.
# NOT physical delete — prereq bootstrap-self + thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell owns seed-path two-stage smoke orchestration.
check-7.2: bootstrap-self scripts/check_7_2.sh
	@bash scripts/check_7_2.sh

# 9.1 自举：纯 .x 流水线（parse_into → typeck_x_ast → codegen_x_ast）；生成 pipeline_gen.c 便于联调；-L 与 pipeline 依赖一致。
# 【Why 根源】必须用 $(XLANG_C) 做 -E：G-02a 后 parser.c 已物理删除，$(XLANG_C) 即 bootstrap_xlangc seed（.x pipeline）。
# seed 的 .x parser 按源码顺序填充 stmt_order，codegen 按序输出；若用 $(TARGET)（非 seed 的 .x 解析）则 stmt_order
# 仅有 const+let 导致声明被提到函数首、顺序错乱。故 -E 须固定用 seed 而非 $(TARGET)。
# pipeline_gen.c 必须是真文件目标，且默认沿用 pinned 生成物：
# 1) 若把它挂在 bootstrap-pipeline 这种伪目标下，经 pipeline_x.o / asm_full_link_stubs.o 间接依赖时会反复触发
# bootstrap-pipeline -> legacy-xlang-c-ready -> make -B xlang-c。
# 2) 若把 legacy-xlang-c-ready 作为 order-only 前置，Make 仍会在“检查 pipeline_gen.c”时先执行那段 -B 重编。
# 因此这里把 legacy frontend 刷新收进真正需要重生的分支里：仅当文件缺失或显式 XLANG_FORCE_REGEN_GEN=1 时才刷新并生成；
# 其余情况直接沿用 pinned pipeline_gen.c。
#
# PLATFORM: SHARED — ABI guard (P0-4 / run-i64-ctfe-gate):
# ast.x Expr.int_val / token.Token.int_val are i64. seeds/pipeline_gen.linux.x86_64.c
# matches. Stale or bad bootstrap -E can leave `int32_t int_val` in pipeline_gen.c;
# extract → pipeline_glue_types.inc → glue CTFE then truncates INT64_MAX to -1 and
# folds `0 - lit - 1` to 0 (silent wrong code, exit 1 ≠ 42). After every branch,
# require `int64_t int_val` in struct ast_Expr or restore the linux.x86_64 seed.
# wave739: G.7 body → scripts/ensure_lsp_pipeline_gen.sh (pin/seed/-E + i64 ABI check)
# wave837: FORCE dep-thin — empty prereq was last gen.c file-target residual after
# wave829 (17 *_gen.c FORCE) + wave834 (bootstrap-pipeline FORCE). Shell owns
# pin/seed/FORCE_REGEN + always-run i64 ABI (make no longer skips when file exists).
# PLATFORM: SHARED — FORCE always invokes ensure (cheap pin skip). NOT physical delete.
pipeline_gen.c: FORCE scripts/ensure_lsp_pipeline_gen.sh
	@bash scripts/ensure_lsp_pipeline_gen.sh pipeline

# PLATFORM: SHARED — always-run ABI guard (make may skip pipeline_gen.c recipe when file exists).
# Stale workspace pipeline_gen.c with int32_t int_val is the P0-4 L4 failure mode on Ubuntu cold.
# §5b #1 wave725: body → scripts/check_pipeline_gen_expr_i64_abi.sh (G.7 single authority).
.PHONY: check-pipeline-gen-expr-i64-abi
check-pipeline-gen-expr-i64-abi:
	@bash scripts/check_pipeline_gen_expr_i64_abi.sh

# wave834: FORCE shell-primary — drop make-graph edge on pipeline_gen.c file.
# G.7 有则补全: body already ensure_lsp_pipeline_gen.sh pipeline (wave739); thin-call only.
# Shell always runs pin/seed/force -E + i64 ABI (make file-prereq skipped when pin exists).
# PLATFORM: SHARED — same ensure on Darwin/Linux/Windows MSYS2. NOT physical delete.
.PHONY: bootstrap-pipeline
# wave892 B7B residual: drop dual @echo after thin-call (G.7 form hygiene).
# Shell ensure_lsp_pipeline_gen owns pipeline pin messaging; pure @bash only.
bootstrap-pipeline: FORCE scripts/ensure_lsp_pipeline_gen.sh
	@bash scripts/ensure_lsp_pipeline_gen.sh pipeline
# 仅重生成并编译 pipeline/driver/preprocess 三个 X 对象（供调试或 build_xlang_asm 对齐）
# wave892 B7B residual: drop pure @echo alias body → @true (G.7 form hygiene).
# Prereqs own pipeline_x.o driver_x.o preprocess_x.o rebuild.
gen-x-driver-objs: pipeline_x.o driver_x.o preprocess_x.o
	@true

# pipeline_gen.c 为真实文件目标；-E 时 runtime.c 在入口为 pipeline.x 时自动追加 pipeline_glue.c 到 stdout，无 Makefile 补丁

# 链接带 -x 流水线的 xlang（需 main_x.o 用 -DXLANG_USE_X_PIPELINE 编译，否则 -x -E 不生效）
# xlang-x-pipeline 链接了；lsp_diag_pipeline_sizes.o 提供 lsp_diag 与 pipeline 间结构体 sizeof；
# 提供 asm_driver_*（fmt/check/test 仅 bootstrap-driver-seed / xlang-x 全驱动链需要 DRIVER_SUBCMD_OBJS）
# wave845: full body → scripts/xlang_x_pipeline.sh (G.7 有则补全; shell owns multi-make
# ensure ladder + host-cc link). Lists stay mk expansion (pipeline_x_objs.mk).
# wave859: shell loads XXP_* via export-xxp-link-bags when unset (no multi-token
# XXP_* env export).
# wave865: shell loads CFLAGS via export-try-heat-cflags when unset (no multi-token
# CFLAGS= env).
# wave879 B7B: drop multi-token TARGET/CC/MAKE inject (G.7 hygiene).
# Shell defaults own env (xlang_x_pipeline). Thin @bash only.
# NOT physical delete — prereq make-graph + thin edges + B2
# + mk lists remain residual.
# PLATFORM: SHARED — shell owns force-rebuild + link orchestration.
xlang-x-pipeline: bootstrap-pipeline migrate-x-objs $(PIPELINE_X_BASE_OBJS) pipeline_x.o $(PIPELINE_X_FRONTEND_OBJS) $(PIPELINE_X_SUPPORT_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes.o scripts/xlang_x_pipeline.sh
	@bash scripts/xlang_x_pipeline.sh

# 4.5（.x 流水线编译 compiler 自身）：用 xlang_x 的 -x -E 生成 typeck.x / codegen.x 对应的 C，再由 cc 链接得到新的 xlang_x_stage2。
# 这一目标的目的，是验证「完整前端（parse_into + typeck_x_ast + codegen_x_ast）」全部跑在 .x 上时，仍能产出能工作的编译器。
# wave785 B7c: typeck_x_x / codegen_x_x are *not* migrate_x_objs (different TU names; archaeology).
# wave842: full body → scripts/bootstrap_x_compiler.sh (G.7 有则补全; shell owns -x -E + host-cc -c + link).
# wave859: shell loads BXC_LINK_OBJS via export-bxc-link-objs when unset (no multi-token
# BXC_LINK_OBJS= env).
# wave865: shell loads CFLAGS via export-try-heat-cflags when unset (no multi-token
# CFLAGS= env).
# wave879 B7B: drop multi-token TARGET/CC/MAKE inject (G.7 hygiene).
# Shell defaults own env (bootstrap_x_compiler). Thin @bash only.
# NOT physical delete — prereq make-graph (xlang-x-pipeline)
# + thin edges + mk lists remain residual.
# PLATFORM: SHARED — shell owns stage2 emit/compile/link orchestration.
bootstrap-x-compiler: xlang-x-pipeline scripts/bootstrap_x_compiler.sh
	@bash scripts/bootstrap_x_compiler.sh

# 自举测试（不含 run-all）：seed 构建 xlang，再用 xlang 自编得到 xlang_stage2，stage2 跑 return-value 返回 42 即通过。用于快速验证「xlang 能编译自己」。
# wave892 B7B residual: drop pure @echo alias body → @true (G.7 form hygiene).
# Prereq bootstrap-self owns stage1→stage2 smoke; no dual status body.
bootstrap-test: bootstrap-self
	@true

# M9：B-strict 语义自举主路径（xlang_asm→xlang_asm2 + lexer/typeck 烟测）。
# wave720: check-7.2-bstrict / bootstrap-verify body → scripts/bootstrap_verify_bstrict.sh
# Prereq bootstrap-driver-bstrict keeps cold graph on make path.
# wave880 B7B: drop multi-token MAKE/TARGET/ENSURE inject (G.7 hygiene).
# Shell MAKELEVEL default ENSURE=0 on make-graph path; direct xbuild keeps ENSURE=1.
check-7.2-bstrict: bootstrap-driver-bstrict
	@bash scripts/bootstrap_verify_bstrict.sh

bootstrap-verify-bstrict: check-7.2-bstrict
	@true

# wave892 B7B residual: drop pure @echo alias body → @true (G.7 form hygiene).
bootstrap-verify-seed: check-7.2
	@true

# 7.3 默认：B-strict / xlang_asm 主路径；-x -E 全模块仍见 bootstrap-verify-seed + verify-selfhost-stage2。
bootstrap-verify: bootstrap-verify-bstrict
	@true

# clangd：生成 compile_commands.json + ide/pipeline_glue_types.inc（IDE 误报 glue 池时运行）
# wave888 B7B: thin @bash scripts/ form (drop bare ./scripts/…).
compile_commands.json:
	@bash scripts/gen_compile_commands.sh

# 阶段 8 体积基线：编译固定用例并输出可执行文件大小
# wave875: full body → scripts/stage8_baseline.sh size (G.7 有则补全;
#   measurement authority stays tests/run-size-baseline.sh; shell owns make
#   cwd → repo-root dispatch + soft-skip). Thin-call only.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration only.
size-baseline: scripts/stage8_baseline.sh
	@bash scripts/stage8_baseline.sh size

# 阶段 8 性能基线：编译并多次运行 perf-baseline，输出耗时
# wave875: full body → scripts/stage8_baseline.sh perf (G.7 有则补全;
#   measurement authority stays tests/run-perf-baseline.sh; shell owns make
#   cwd → repo-root dispatch + soft-skip). Thin-call only.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration only.
perf-baseline: scripts/stage8_baseline.sh
	@bash scripts/stage8_baseline.sh perf


# G-02f-22：runtime_asm_build 产品 seed — joined wave904 multi-target $(R1_MISC_BASENAME_OBJS).
# Archaeology: wave754 R1 · wave792 FORCE — body in try-heat.
