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

# std.process：F 闭合 — process.o 只提供 process_*_c（argv 薄封装 + OS glue）。
# 用户 std_process_* API 由 -o 路径 co-emit std/process/mod.x（带 std_process_ 前缀）。
# 【Why 不 -E mod.x/process.x】产品 -x -E 对无 main 库模块当前会在巨型 preamble 后截断
# 函数体（16KiB/20KiB），且裸 getcwd/pipe 与 unistd 编译期冲突。截断修通后可改回
# xlang_compile_std_module --bare-impl process.x（mod.x 仍勿编入 .o，避免双定义）。
# wave780 B2: hybrid body → ensure try-std-core-prefer (G.7; not physical delete).
# wave790 B7A: heat recipe unify → try-heat only (mode names in comments; dep edges residual).
# PLATFORM: SHARED — cold ld -r args seed + runtime_process_argv + os_glue.
../std/process/process.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave795 B7A: heat dep-edge thin std merge process residual — prereqs → FORCE + ensure;
# try-heat owns seed/peer .o mtime (process_merge). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# std.string：F 闭合 — 产品 -o 完整 emit（-x -E 会截断函数体）。
# 用 xlang_compile_std_module（与 crypto 等同路径）；优先 xlang_asm/xlang 产品宿主。
../std/string/string.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.path：保留 mod.x 作为 F-path v1 源码锚点；path.o 由 C provider 产出，
# 避免 bootstrap asm backend 在 dirname/last_slash 链上反复卡住。
# G-02f-21 (wave531)：R2 DIRECT mode — pure-compute path helpers (16 functions:
#   path_sep/is_sep/last_sep/last_dot + std_path_join/dirname/basename/...).
#   No OS bridge, no _impl indirection; .x compiles standalone via xlang-c
#   -lib-name "". Seed .from_x.c guarded by XLANG_RUNTIME_PATH_FAST_FROM_X for
#   cold path fallback only.
# PLATFORM: SHARED path — pure compute (pointer scan + min), no OS dependency.
#   Note: .x path_sep_c always returns '/' (47) per posix gate; seed Win branch
#   returns '\' (92) but is skipped in R2 mode.
# wave780 B2: dual hybrid → ensure try-std-core-prefer (G.7; not physical delete).
../std/path/path.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave795 B7A: heat dep-edge thin std direct path residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x mtime (std-core-prefer/direct). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# std.heap：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + libc + ops）。
../std/heap/heap.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.heap.page_mmap：F-no-libc NL-03 freestanding mmap bump 堆（单文件 .x -E + cc）。
# 路径前缀 std_heap_page_mmap_*；传递依赖 std.sys.linux + core.mem 由 freestanding on_demand 链入。
../std/heap/page_mmap.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.sys：OS 原语门面（mod.x -E + cc；#[cfg(target_os)] 分平台）。
# 路径前缀 std_sys_*；Linux 编译激活 linux import，传递依赖 std/sys/linux.o + core/mem/mem.o。
../std/sys/sys.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.sys.linux：Linux syscall 号表 + freestanding invoke（linux.x -E + cc）。
# 路径前缀 std_sys_linux_*；含 hosted libc 函数（open/mmap），靠 --gc-sections 移除未引用者。
../std/sys/linux.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# core.mem：内存操作原语（mod.x -E + cc）。
# 路径前缀 core_mem_*；align_up/mem_copy/mem_set 等纯 .x 实现，无 libc 依赖。
../core/mem/mem.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# PLATFORM: SHARED — core.types/option/result formal .o for -backend asm on_demand.
# Do not asm co-emit these (Ubuntu x86_64 hang on option/result); C -E + cc only.
../core/types/types.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

../core/option/option.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

../core/result/result.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# core.debug：兼容 alias of core.assert; formal .o for asm on_demand (no co-emit).
# PLATFORM: SHARED — tests/sort etc. U core_debug_assert_eq_*; L4 wipe needs make ensure.
../core/debug/debug.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# core.slice formal API (mod.x → core_slice_len_*/get_*). Glue from_ptr/subslice stays
# in core/slice/slice.o (runtime_slice_glue). PLATFORM: SHARED — Ubuntu -backend asm
# length.x BLD001 U core_slice_len_i32 when only glue .o existed; simple-group g9 + ensure.
../core/slice/mod.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.map：F 闭合 — 纯 .x -E-extern + cc -c。
../std/map/map.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.set：F 闭合 — 纯 .x -E-extern + cc -c。
../std/set/set.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.vec：F 闭合 — 单 mod.x（import std.heap）；link_only 产品链按需 std/vec/vec.o。
# PLATFORM: SHARED — L4 全擦后须 make 本目标或 link ensure（push_existing  alone 静默 skip）。
../std/vec/vec.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.runtime：保留 runtime.x 作为 F-runtime v1 源码锚点；runtime.o 仅提供
# runtime_panic/runtime_abort/runtime_crash_evidence_collect_c 三个 extern provider。
# G-02f-23 (wave532)：R2 DIRECT mode — 6 thin wrappers forwarding to extern "C"
#   xlang_panic_ / xlang_crash_evidence_collect_c (resolved by runtime_panic module
#   at link time). No OS bridge, no _impl indirection; .x compiles standalone via
#   xlang-c -lib-name "". Seed .from_x.c guarded by XLANG_RUNTIME_STD_RUNTIME_FAST_FROM_X
#   for cold path fallback only.
# PLATFORM: SHARED runtime — pure thin wrappers to panic; no OS dependency.
# wave780 B2: dual hybrid → ensure try-std-core-prefer (G.7; not physical delete).
../std/runtime/runtime.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave795 B7A: heat dep-edge thin std direct runtime residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x mtime (std-core-prefer/direct). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# std.net：F-04 v10～v14 纯 .x（F-ZC）；OS glue 由 runtime_net_*_fast.inc 提供（G-02e-18）。
# PLATFORM: SHARED — mod.x MUST be compiled into net.o; otherwise std_net_listen /
# std_net_close_listener / std_net_accept etc. exported symbols are missing from
# net.o, and any user program calling net.* API hits Undefined symbol BLD001.
# Root cause fix (2026-07-19): add mod.x via xlang_compile_std_module.sh (matches
# string/heap/sys/fs pattern). Sub-module .x keep xlang_compile_std_x.sh bare path.
# PLATFORM: MACOS — after wave102 pure-asm arm64 enc, -backend asm succeeds for
# alpn/tcp/...; ld -r with C mod.o leaves tls_stub/tcp_pool/io UNDEFs live under
# product -dead_strip (net-context BLD001). Pre-wave102 Darwin fell back to xlang-c
# (code_len=0). Recipe forces ./xlang-c for Darwin net submodules; Linux keeps asm.
# wave780 B2: multi hybrid → ensure try-std-core-prefer (G.7; not physical delete).
# wave796 B7A: heat dep-edge thin net multi-merge residual — prereqs → FORCE + ensure;
# try-heat owns multi .x + five fast seed/.x mtime (net_merge). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
../std/net/net.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG="$(XLANG)" XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# wave815: archaeology host-pick phonies → scripts/archaeology_host_pick_phony.sh
# (G.7; not physical delete). Makefile thin-call ensure only; host pick + TLS/sqlite
# merge body live in the shell catalog. Nested product .o still via make try-heat.
# wave839: FORCE dep-thin — drop script-only prereq residual; FORCE + script only
# (G.7 有则补全). Shell owns host pick / TLS-sqlite merge; FORCE always re-enters
# (matches product leaf pattern; never make-skipped by stale script mtimes alone).
# PLATFORM: SHARED — FORCE always invokes ensure; bash for Ubuntu dash.
net-o-stub: FORCE scripts/archaeology_host_pick_phony.sh
	@MAKE="$(MAKE)" LD_R_MULTIDEF_FLAGS="$(LD_R_MULTIDEF_FLAGS)" \
	  bash scripts/archaeology_host_pick_phony.sh ensure $@

# TLS：F-04 v8 net-o-openssl 编译 std/net/tls_openssl.x（不再 #include tls_openssl.inc.c）。
net-o-openssl: FORCE scripts/archaeology_host_pick_phony.sh
	@MAKE="$(MAKE)" LD_R_MULTIDEF_FLAGS="$(LD_R_MULTIDEF_FLAGS)" \
	  bash scripts/archaeology_host_pick_phony.sh ensure $@

net-o-mbedtls: FORCE scripts/archaeology_host_pick_phony.sh
	@MAKE="$(MAKE)" LD_R_MULTIDEF_FLAGS="$(LD_R_MULTIDEF_FLAGS)" \
	  bash scripts/archaeology_host_pick_phony.sh ensure $@

# std.thread：mod.x 提供 std_thread_* 包装；pthread 胶层在 runtime_thread_glue.o（thread_*_c）。
# 【Why 勿只编 thread.x】thread.x 仅 marker，link_only 时缺 _std_thread_create 等。
../std/thread/thread.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.async：F-async v2 纯 .x（F-ZC）；调度胶层在 runtime_scheduler_glue.o；Unix 按需 -pthread。
../std/async/scheduler.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

# std.async：F-async-future v2 纯 .x → future.o（同 hash/cache）。
../std/async/future.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

# std.time：F 闭合 — mod.x 内联派生函数（now_monotonic_us/sleep_ms/duration_ns 等），
# 仅 5 个基础 OS extern 由 runtime_time_os.o 提供。无需 time.x / time_import_alias.c。
../std/time/time.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.random：F 闭合 — mod.x（用户 API）+ random.x（impl 裸符号）用 -E-extern 编译；
# CSPRNG OS 在 runtime_random_fill.o，最终 exe 链接时按需推入。
../std/random/random.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.env：product surface = mod.x (std_env_getenv/…); OS glue in runtime_env_os.o.
# PLATFORM: SHARED — do NOT compile only env.x (std_env_env_* / missing std_env_*);
# asm fk0 pulls formal env.o; wrong authority → Ubuntu BLD001 (tests/env).
# env.x is helpers (parse_kv / platform_encoding / no_mangle args_iter), not product API.
../std/env/env.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.fs：F-03 pure .x — formal .o for -backend asm (co-emit of std.fs is skipped).
# PLATFORM: SHARED — product authority remains mod.x+posix via import; vehicle is
# compile driver only (user -o KEEP_C path). Do NOT compile mod.x as entry on Linux
# (libc name collisions / posix_fadvise order). Wrong/missing → U std_fs_invalid.
../std/fs/fs.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.sync：F 闭合 — mod.x（用户 API）+ sync.x（impl 裸符号）用 -E-extern 编译；
# OS/TLS 胶层在 runtime_sync_*.o，最终 exe 链接时按需推入。
../std/sync/sync.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.queue：F 闭合 — mod.x 用户 API（Queue_i32/u8）；queue.x 为 F-queue marker。
# pthread 胶层在 runtime_queue_contention.o（链接按需）。
../std/queue/queue.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.encoding：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + encoding）。
../std/encoding/encoding.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.base64：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + base64）。
../std/base64/base64.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.crypto：F-闭合 — mod.x + 5 .x 用 -E-extern 编译（裸符号）。
# mod.x 提供 extern 声明 + 公共 API；core/aes_gcm/chacha20_*/ed25519.x 提供裸符号实现。
../std/crypto/crypto.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.log：F-闭合 — mod.x + log.x 用 -E-extern 编译（裸符号）。
# mod.x 提供 extern 声明 + 公共 API；log.x 提供 log_write_c 等裸符号实现。
../std/log/log.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@


# std.test：F 闭合 — mod.x（用户 API）+ test.x（impl 裸符号）用 -E-extern 编译；
# fn-ptr 在 runtime_test_fn_invoke.o，最终 exe 链接时按需推入。
../std/test/test.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.atomic：F 闭合 — mod.x（用户 API）+ atomic.x（impl 裸符号）用 -E-extern 编译；
# 原子胶层在 runtime_atomic_glue.o，最终 exe 链接时按需推入。
../std/atomic/atomic.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.channel：F-channel v2 纯 .x（F-ZC）；channel 胶层在 runtime_channel_glue.o；Unix 需 -lpthread。
../std/channel/channel.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

# std.backtrace：F-backtrace v2 纯 .x（F-ZC）；平台胶层在 runtime_backtrace_platform.o。
../std/backtrace/backtrace.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

# std.hash：F 闭合 — mod.x（用户 API）+ hash.x（impl 裸符号）用 -E-extern 编译。
../std/hash/hash.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.math：F-math v2 纯 .x（F-ZC）；libm 胶层在 runtime_math_libm.o（链接 exe 仍须 -lm）。
# PLATFORM: SHARED — 权威 = mod.x (std_math_* API) + math.x (bare math_*_c constants)
# via xlang_compile_std_module --bare-impl. Do NOT compile only math.x (missing std_math_*).
# Ban old xlang-c -E double-prefix stale path.
../std/math/math.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.sort：F-sort v1 — product surface = mod.x (std_sort_sort_*) + sort.x impl.
# PLATFORM: SHARED — do NOT compile only sort.x (bare sort_* / missing std_sort_sort_*);
# asm fk0 pulls formal sort.o; wrong authority → Ubuntu BLD001 (tests/sort).
# Import binding (not --bare-impl): sort.x path prefix → std_sort_sort_sort_qsort_*.
../std/sort/sort.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# G-01：core/ 零 C — 位运算/volatile/slice 已纯 .x（见 analysis/phase-g-full-selfhost-tasks-v1.md）

# std.ffi：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + ffi）。
../std/ffi/ffi.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@


# std.context：F-闭合 — mod.x + context.x 用 -E-extern 编译（裸符号）。
# mod.x 提供 is_cancelled/deadline_ns/remaining_ns 等公共 API；context.x 提供 ctx_*_c 实现。
../std/context/context.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.error：F-闭合 — mod.x 用 -E-extern 编译。提供 http_err_cancelled/timeout 等错误码 API。
../std/error/error.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@


# std.datetime：F-datetime v2 + F-ZC 纯 datetime.x → datetime.o（无 glue；无 xlang 时 exit 0）。
../std/datetime/datetime.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

# std.uuid：F-uuid v1 纯 .x（uuid.x）；依赖 random.o + time.o。
../std/uuid/uuid.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

# std.url：F-url v2 + F-ZC 纯 url.x → url.o（无 glue；无 xlang 时 exit 0）。
../std/url/url.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

# std.cli：命令行解析（std/cli/cli.c）。
# std.cli：F-cli v1 纯 .x（cli.x）；零胶层 C。
../std/cli/cli.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@


# std.security：F-security v1 + F-ZC 纯 security.x → security.o（无 glue；无 xlang 时 exit 0）。
../std/security/security.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@


# std.config：F-config v2 + F-ZC 纯 config.x → config.o（无 glue；无 xlang 时 exit 0）。
../std/config/config.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

# std.cache：F-cache v2 纯 .x（cache.x）；零胶层 C。
../std/cache/cache.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

# std.trace：F-trace v2 纯 trace.x → trace.o（无 glue；无 xlang 时 exit 0）。
../std/trace/trace.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@


# std.task：F-task v2 纯 .x → task.o（同 trace/cache v2）。
../std/task/task.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@


# std.schema：F-schema v2 纯 .x → schema.o（同 cache/encoding）。
../std/schema/schema.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

# std.db.kv：F-05 v2 纯 .x（F-ZC）；mmap 胶层在 runtime_kv_mmap_glue.o。
../std/db/kv/kv.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

# std.db.arrow：F-05 v1 纯 .x（F-ZC）；SIMD 胶层在 runtime_arrow_simd_glue.o。
../std/db/arrow/arrow.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

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
../std/db/sqlite/sqlite.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@
sqlite-o: ../std/db/sqlite/sqlite.o runtime_sqlite_glue.o
# wave815: archaeology host-pick phony → shell catalog (G.7; not physical delete).
# wave839: FORCE dep-thin — FORCE + archaeology_host_pick_phony only (G.7 有则补全).
# PLATFORM: SHARED — FORCE always invokes ensure; bash for Ubuntu dash.
sqlite-o-stub: FORCE scripts/archaeology_host_pick_phony.sh
	@MAKE="$(MAKE)" LD_R_MULTIDEF_FLAGS="$(LD_R_MULTIDEF_FLAGS)" \
	  bash scripts/archaeology_host_pick_phony.sh ensure $@

# std.elf：F-elf v2 + F-ZC 纯 elf.x → elf.o（无 glue；无 xlang 时 exit 0）。
../std/elf/elf.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@

# P4 std 模块（按需链接）
# std.json：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + json）。
../std/json/json.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@
# std.csv：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + csv）。
../std/csv/csv.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@
# std.regex：F-regex v2 纯 .x → regex.o（同 hash/schema）。
../std/regex/regex.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@
# F-04 v7：std.compress 全格式已迁 .x；compress.o 不再构建，保留 target 名兼容门禁。
compress-o-zlib compress-o-zlib-zstd compress-o-brotli compress-o-zlib-zstd-brotli:
	@true
# std.unicode：F-unicode v2 纯 .x → unicode.o（同 hash/schema）。
../std/unicode/unicode.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@
# std.dynlib：F 闭合 — mod.x（用户 API）+ dynlib.x（impl 裸符号）用 -E-extern 编译；
# dlopen 胶层在 runtime_dynlib_os.o，最终 exe 链接时按需推入。
../std/dynlib/dynlib.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@
# std.http：F 闭合 — mod.x（用户 API）+ http.x（impl 裸符号）用 -E-extern 编译；
# HTTP 胶层在 runtime_http_glue.o，最终 exe 链接时按需推入。
../std/http/http.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@

# std.socketio：F-socketio v2 纯 socketio.x；ld -r 合并为 socketio.o（P3 可选）。
../std/socketio/socketio.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@
# std.tar：F-tar v2 纯 tar.x；import binding 别名桩 tar_import_alias.c。
# std.tar：F 闭合 — 纯 .x -E-extern + cc -c + ld -r（mod + tar）。
../std/tar/tar.o: FORCE scripts/xlang_compile_std_module.sh
# wave826: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave812: formal_mod catalog → ensure (G.7; not physical delete).
	@sh scripts/xlang_compile_std_module.sh ensure $@
# std.simd：F-simd v1 + F-ZC 纯 simd.x → simd.o（无 glue；无 xlang 时 exit 0）。
../std/simd/simd.o: FORCE scripts/xlang_compile_std_x.sh
# wave827: FORCE dep-thin — shell owns catalog source mtime (G.7; not physical delete).
# wave825: std_x catalog → ensure (G.7; not physical delete; wave811 body).
	@sh scripts/xlang_compile_std_x.sh ensure $@


# 测试与 xlang 链接 std 时依赖的 .o：所有 std 模块 + runtime_panic.o；Linux 另预编 freestanding 链入桩
# wave813 B7B: list authority → mk/std_and_panic_objs.mk (G.7; not physical delete).
# Makefile keeps include + consumers (std-objs / test_c / bootstrap-*); no dual list.
include mk/std_and_panic_objs.mk

# 同时链出 xlang-c：与 pipeline/lsp/build_gen 的 -E 生成及 test_c 前置一致，避免仅 make all 后缺少 xlang-c。
# XLANG_RUN_ALL_BOOTSTRAP_XLANG=1：run-all 显式 XLANG=seed 时子脚本须保持 bootstrap 链，禁止 C-only all 覆盖 xlang。
# 默认 all 不构建 STD_AND_PANIC_O（xlang-c 无 -backend 解析；按需 `make std-objs` 或单条 ../std/*/*.o）。
# wave784: B6 R5 CI / compiler-all body → scripts/compiler_all_ci.sh (thin-call only).
# Policy/sequence shell-owned; leaf .o + link still make graph (B7). NOT physical delete.
# PLATFORM: SHARED — orchestration in shell; leaf recipes keep platform ABI.
.PHONY: all
all:
	@OPT="$(OPT)" MAKE="$(MAKE)" TARGET="$(TARGET)" XLANG_C="$(XLANG_C)" \
	  XLANG_RUN_ALL_BOOTSTRAP_XLANG="$(XLANG_RUN_ALL_BOOTSTRAP_XLANG)" \
	  XLANG_SKIP_SUBSCRIPT_MAKE="$(XLANG_SKIP_SUBSCRIPT_MAKE)" \
	  bash scripts/compiler_all_ci.sh

std-objs: $(STD_AND_PANIC_O)

# wave786 B7D: host-cc product `xlang` link = g05 authority (G.7 有则补全).
# Before: $(TARGET): $(OBJS) with OBJS_CORE only → UNDEF (parser/typeck/pipeline missing).
# Product list + pure-ld live in g05_relink_env / g05_relink_xlang; do NOT re-list .o here.
# PLATFORM: SHARED — same g05 path on mac/Ubuntu/Windows host (Windows LEGACY env still via g05).
# Escape (archaeology only): XLANG_HOST_CC_OBJS_CORE=1 restores incomplete OBJS_CORE link
# (expect UNDEF residual; not product). Cold tree without product .o: run bootstrap-driver-seed first.
ifeq ($(XLANG_HOST_CC_OBJS_CORE),1)
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(WIN_LDFLAGS)
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
bootstrap_xlangc: FORCE scripts/select_bootstrap_xlangc.sh
	@chmod +x scripts/select_bootstrap_xlangc.sh 2>/dev/null || true
	@bash scripts/select_bootstrap_xlangc.sh

ifeq ($(XLANG_LEGACY_C_FRONTEND),1)
# G-02a: lexer.o 从 runtime_lexer_glue.inc 编译（G-02e-19：cc_inc_tu）。
# 仅提供 lexer_new/lexer_free；lexer_next 由 lexer_x.o（.x）或 runtime_driver_strict_glue_stubs.o（weak 桩）提供。
# G-02f-21：runtime_lexer_glue 产品 seed
# wave750 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_FRONTEND_GLUE_OBJS).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/lexer/lexer.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02a: ast.o 从 runtime_ast_glue.inc 编译（LEGACY 模式 XLANG_LEGACY_C_FRONTEND=1）。
# LEGACY parser.o 不引用 ast_expr_init_match_enum，安全。
# G-02f-21：runtime_ast_glue 产品 seed
# wave750 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_FRONTEND_GLUE_OBJS).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/ast/ast.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02a: typeck.c 已物理删除；typeck.o 由 typeck.x 生成（typeck_x.o），C 编排由 typeck_c_module_stubs.o 提供。

# G-02a: codegen.c 已物理删除；codegen_x.o 由 codegen.x 生成，codegen_pipeline_stubs.o 提供 weak 桩。

else
# XLANG_SKIP_SUBSCRIPT_MAKE=1 时跳过 cp：run-all 入口已构建真正 C 前端（XLANG_LEGACY_C_FRONTEND=1），
# 此处 cp 会覆盖之导致回归全部失败。bootstrap_xlangc target 仍会跑 select_bootstrap_xlangc.sh 同步种子。
$(XLANG_C): bootstrap_xlangc
	@if [ -z "$${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then cp -f bootstrap_xlangc $@; else echo "xlang-c: XLANG_SKIP_SUBSCRIPT_MAKE=1, skip cp (preserve real C frontend)"; fi
endif

# G-02f-11：diag 产品 seed（全局规则，LEGACY 与默认共用）
# wave749 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_CORE_SEED_OBJS).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/diag.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02a: lsp_diag.c 迁移到 runtime_lsp_glue.inc（24 个符号被 lsp_x.o/fmt_check_cmd*.o/runtime*.o 引用）
# 全局规则，LEGACY 和默认模式共用。
# G-02f-15：lsp_diag 产品 seed（原 runtime_lsp_glue）
# wave750 R1 cold: ensure_one · wave771 product PREFER thin+rest → try-other-l2-prefer.
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/lsp/lsp_diag.o: FORCE scripts/ensure_host_cc_seed_o.sh
	# wave771: other L2 PREFER thin+rest → try-other-l2-prefer (cold plain seed fallback).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# `xlang-c` 默认模式可能只是 bootstrap_xlangc 的同步副本；凡是依赖 `-E/-E-extern`
# 生成当前源码对应 C 的目标，必须先强制刷新一次 legacy C frontend，避免继续吃旧语义。
.PHONY: legacy-xlang-c-ready
legacy-xlang-c-ready:
	@$(MAKE) $(XLANG_C)

LEGACY_XLANG_C_READY_TARGETS = build-tool

$(LEGACY_XLANG_C_READY_TARGETS): | legacy-xlang-c-ready

# G-02f-16：main 产品 seed（LEGACY 极简入口）
# wave751 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MAIN_RUNTIME_OBJS).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/main.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# E-04 v2/v3：argv/target 与 POSIX I/O ABI 薄壳；默认 seed / B-strict 均链入。

# G-02f-12 / Phase 4：runtime_io_abi PREFER_X_O（rest→.x 迁移）
# 5 个 _impl 真迁 .x（read/malloc/memcpy）；4 个保留 seed（mmap/fstat/O_* flags/平台 #ifdef）
# PLATFORM: SHARED 冷链纪律 — 仅 XLANG_G05_PREFER_X_O=1 才 thin（同 simd_enc；见下 runtime_driver_abi）。
# wave757 R3 cold-else + wave763 R3 PREFER thin → ensure try-r3-prefer (list = R3_COLD_SEED_OBJS).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/runtime_io_abi.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@


# G-02f-13：runtime_link_abi 产品 seed（G05 hot）
# wave749 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_CORE_SEED_OBJS).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/runtime_link_abi.o: FORCE scripts/ensure_host_cc_seed_o.sh
	# wave765: labi multi-slice PREFER → try-labi-prefer (cold full seed fallback).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-12 / Phase 4：runtime_driver_abi thin+rest PREFER_X_O
# PLATFORM: SHARED 冷链 — bootstrap-driver-seed 传 XLANG_G05_PREFER_X_O=0 必须走 seed。
# 【Why 2026-07-16 铁证】Darwin 冷测：select_bootstrap 先恢复 xlang-c，若仅「有 xlang-c 就 thin」，
# thin 会 emit process_args_count_c → U process_xlang_argc_get，而 phase1 未链 runtime_process_argv.o
# → mac phase1 UNDEF；Ubuntu 上 thin -E/cc 常失败回退 seed 故假绿。须与 simd_enc 同源门控。
# 链闭包：DRIVER_SEED_OBJS 含 runtime_process_argv.o（PREFER=1 时亦须能解析 process_xlang_*）。
# wave757 R3 cold-else + wave763 R3 PREFER thin → ensure try-r3-prefer (list = R3_COLD_SEED_OBJS).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/runtime_driver_abi.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-12：runtime_pipeline_abi 产品 seed（须 XLANG_USE_X_PIPELINE）
# wave753 R1 cold: ensure_one + USE_X_PIPELINE · wave767 product PREFER → try-pipeline-abi-prefer.
src/runtime_pipeline_abi.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave794 B7A: heat dep-edge thin Makefile-flags residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/hdr + Makefile flag mtime (force_thin_makefile_flags_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
	# wave767: pipeline_abi PREFER thin+rest → try-pipeline-abi-prefer (cold + USE_X_PIPELINE fallback).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  RUNTIME_PIPELINE_ABI_CFLAGS="$(RUNTIME_PIPELINE_ABI_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@


# G-02f-22：runtime_c_import 产品 seed
# wave749 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_CORE_SEED_OBJS).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/runtime_c_import.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-18 / R2 product PREFER：async_liveness 独立 TU（非 glue #include）。
# wave770: product PREFER → ensure try-async-prefer (full .x + rest FROM_X → $CC -r; cold seed).
# PLATFORM: SHARED — product link via DRIVER_SEED_SUPPORT_EXTRA (legacy mode).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/async/async_liveness.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-18 / R2 product PREFER：async_cps_codegen 独立 TU（非 glue #include）。
# wave770: product PREFER → ensure try-async-prefer (full .x + rest FROM_X → $CC -r; cold seed).
# PLATFORM: SHARED — product link via DRIVER_SEED_SUPPORT_EXTRA (legacy mode).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/async/async_cps_codegen.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# R2 unbundle async_asm_pool from pipeline_glue #include (2026-07-21).
# wave770: product PREFER → ensure try-async-prefer (full .x + rest FROM_X → $CC -r; cold seed).
# PLATFORM: SHARED — product link via DRIVER_SEED_SUPPORT_EXTRA (all modes).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/async/async_asm_pool.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-12 / Phase 4：runtime_driver_diagnostic thin+rest PREFER_X_O
# PLATFORM: SHARED 冷链 — 仅 XLANG_G05_PREFER_X_O=1 才 thin（同 simd_enc / runtime_driver_abi）。
# wave757 R3 cold-else + wave763 R3 PREFER thin → ensure try-r3-prefer (list = R3_COLD_SEED_OBJS).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/runtime_driver_diagnostic.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# 6.3：runtime.c 提供 run_compiler_c 与弱符号 main_entry；带 .x 入口时用 runtime_driver.o（含 driver_*/pipeline_*）
# G-02f-14：runtime 产品 seed（多变体）
# wave751 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MAIN_RUNTIME_OBJS).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/runtime.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
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
# wave751 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MAIN_RUNTIME_OBJS).
# Extra flags = $(RUNTIME_DRIVER_CFLAGS) (make expands; shell body only).
src/runtime_driver.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave794 B7A: heat dep-edge thin Makefile-flags residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/diag.h + Makefile flag mtime (force_thin_makefile_flags_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f Cap residual slices：driver_abi 跨 TU 数据/thread_fn（arena BSS、emit 扫描槽、preamble 表、stack_esc）。
# 与 g05_ensure 产品路径同源 seed；冷启动 phase1 必须进 DRIVER_SEED_OBJS。
# wave748 R1: pure host-cc body → scripts/ensure_host_cc_seed_o.sh (G.7 single body).
# List authority remains RT_SEED_SLICE_OBJS; thin leaves only.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# wave861 B7B: drop multi-token CFLAGS="$(CFLAGS) -I. -Iinclude -Isrc" (G.7 hygiene).
# CFLAGS already carries product -I paths (Makefile ?= / shell BASE_CFLAGS default);
# dual -I bag was residual make-escape noise vs sibling try-heat leaves (runtime_x.o).
# NOT physical delete — thin edges + B2 try-heat + mk lists remain.
src/runtime/rt_arena_buf.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# wave861: plain CFLAGS= (no multi-token -I bag; product -I already in CFLAGS).
src/runtime/rt_emit_state.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# wave861: plain CFLAGS= (no multi-token -I bag; product -I already in CFLAGS).
src/runtime/rt_preamble.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# wave861: plain CFLAGS= (no multi-token -I bag; product -I already in CFLAGS).
src/runtime/rt_stack.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# multi-error recovery 诊断（G-02f-307）；勿仅靠 no_c 内嵌 merge——冷启动 phase1 须显式链入。
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# wave861: plain CFLAGS= (no multi-token -I bag; product -I already in CFLAGS).
src/runtime/rt_parse_diag.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# wave788 B7B: RT / R1 / R3 pure-literal lists → mk/driver_seed_r_lists.mk
# (G.7 single list authority; shell catalog parses the same mk; do not re-assign).
include mk/driver_seed_r_lists.mk

# G-02a: preprocess.c 已物理删除；preprocess_for_driver.o 不再编译（XLANG_LEGACY_PREPROCESS_C 路径已死）。
# xlang_x 用：仅 -DXLANG_USE_X_PIPELINE，提供 asm_codegen_ast、pipeline_parse_into_buf、main_entry（弱符号）等
# wave751 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MAIN_RUNTIME_OBJS).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/runtime_x.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave775: non-driver fmt_check_cmd.o → ensure try-other-l2-prefer (fmt_core).
# G.7 有则补全 — same body as driver leaf; leaf_kind=fmt_core omits USE_X_PIPELINE
# (OBJS_CORE / PIPELINE_X satellite: runtime_x has no XLANG_USE_X_DRIVER).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x WEAK + rest FROM_X.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/driver/fmt_check_cmd.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave771: product PREFER → ensure try-other-l2-prefer (thin .x WEAK + rest FROM_X + USE_X_PIPELINE; cold seed).
# PLATFORM: SHARED — product daily path; PREFER=0 cold keeps -DXLANG_USE_X_PIPELINE.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/driver/fmt_check_cmd_driver.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

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
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  LD="$(LD)" LD_RELFLAGS="$(LD_RELFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02a：preprocess 已迁 preprocess.x；不再编译 preprocess.c。

# runtime.c：不引用 C lexer/parser/typeck/codegen（见 XLANG_NO_C_FRONTEND 包裹的 load_one_import 等）
# G-02f-14：G05 产品 runtime_driver_no_c
# wave751 R1 cold: ensure_one + NO_C · wave766 product PREFER multi-slice → try-rt-prefer.
src/runtime_driver_no_c.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave794 B7A: heat dep-edge thin Makefile-flags residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x + Makefile flag mtime (force_thin_makefile_flags_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
	# wave766: rt multi-slice PREFER → try-rt-prefer (cold full seed + NO_C fallback).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  RUNTIME_DRIVER_NO_C_CFLAGS="$(RUNTIME_DRIVER_NO_C_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# xlang_x 使用带 -DXLANG_USE_X_PIPELINE 编译的 main，否则 #ifdef 块不会生效
# wave751 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MAIN_RUNTIME_OBJS).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/main_x.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

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
# NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
# PLATFORM: LINUX|x86_64 — cold .s when present; arm64 seed; else portable from_x
# (shell r2_panic_host_pick_src; stamp build_asm/runtime_panic.$(UNAME).$(ARCH).stamp).
RUNTIME_PANIC_PLATFORM_STAMP = build_asm/runtime_panic.$(UNAME_S).$(UNAME_M).stamp
$(RUNTIME_PANIC_PLATFORM_STAMP):
	@mkdir -p build_asm
	@touch $@
runtime_panic.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# seed asm 用户程序：std.io 跳过 .x emit 时的 print/write/read_ptr 链接桩（G-02e-20 .inc）
# G-02f-20：runtime_asm_io_stubs 产品 seed
# wave753 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_EXTRA_CFLAGS_OBJS).
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_asm_io_stubs.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@


# F-ZC：std.test fn-ptr invoke；与 test.o 一并链入（G-02e-16：.inc + cc_inc_tu）
# G-02f-21：runtime_test_fn_invoke 产品 seed
# wave518 R2 migration: thin (.x) + rest (.from_x.c) thin+rest mode
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_test_fn_invoke.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：CSPRNG OS fill；与 random.o 一并链入（G-02e-17：.inc + cc_inc_tu）
# G-02f-20：runtime_random_fill 产品 seed
# G-02f-20：runtime_random_fill 产品 seed；wave514 R2 thin+rest pattern
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_random_fill.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# zlib 宏包装桩；与 compress 同链（G-02e-17：.inc + cc_inc_tu）
# G-02f-21：runtime_compress_zlib_glue 产品 seed
# wave519 R2 migration: thin (.x) + rest (.from_x.c) thin+rest mode
#   - thin (.x): #[no_mangle] deflateInit2/inflateInit2 (no _c suffix to match
#     libz.x extern declarations)
#   - rest (.from_x.c): _impl_c bridges that #include <zlib.h> and call real
#     deflateInit2_/inflateInit2_ with ZLIB_VERSION and sizeof(z_stream)
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_compress_zlib_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：time OS syscall；与 time.o 一并链入（G-02e-18：.inc + cc_inc_tu）
# G-02f-19：runtime_time_os 产品 seed
# wave501 R2 migration: PREFER_X_O=1 时 .x → thin.o + seed-rest → ld -r；
# 否则冷启动 seed C（完整实现含 public API）。
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_time_os.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：queue 竞争烟测 pthread；与 queue.o 一并链入（G-02e-19：.inc + cc_inc_tu）
# G-02f-21：runtime_queue_contention 产品 seed
# wave512 R2 migration: PREFER_X_O=1 时 .x → thin.o + seed-rest → ld -r；
# 否则冷启动 seed C（完整实现含 public API）。
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_queue_contention.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：dynlib dlopen/LoadLibrary；与 dynlib.o 一并链入（G-02e-19：.inc + cc_inc_tu）
# G-02f-20：runtime_dynlib_os 产品 seed
# wave502 R2 migration: PREFER_X_O=1 时 .x → thin.o + seed-rest → ld -r；
# 否则冷启动 seed C（完整实现含 public API）。
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_dynlib_os.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave253 G.7: sole user-domain residual face body (weak link_abi_getenv twin).
# Never g05 host bag; STD_AND_PANIC / product -o companion of PRIMARY_PANIC.
# wave754 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MISC_BASENAME_OBJS).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_link_abi_user_env.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：env OS getenv/setenv/iter；与 env.o 一并链入（G-02e-19：.inc + cc_inc_tu）
# G-02f-19：runtime_env_os 产品 seed
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_env_os.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：backtrace capture/symbolicate/crash evidence；与 backtrace.o 一并链入（G-02e-20）
# G-02f-19：runtime_backtrace_platform 产品 seed；wave506 R2 full mode
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_backtrace_platform.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：log sink/轮转/异步；与 log.o 一并链入（G-02e-19：.inc + cc_inc_tu）
# G-02f-19：runtime_log_os 产品 seed；wave505 R2 full mode
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_log_os.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：math libm/fenv；与 math.o 一并链入（须 -lm；G-02e-19：.inc + cc_inc_tu）
# G-02f-19：runtime_math_libm 产品 seed；wave511 R2 full mode
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_math_libm.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：atomic load/store/CAS/fence；与 atomic.o 一并链入（G-02e-19：.inc + cc_inc_tu）
# G-02f-19：runtime_atomic_glue 产品 seed；wave508 R2 full mode
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_atomic_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：channel 有界/无界/select；与 channel.o 一并链入（G-02e-20：.inc + cc_inc_tu）
# G-02f-18：runtime_channel_glue 产品 seed
# wave754 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MISC_BASENAME_OBJS).
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_channel_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：net UDP batch recvmmsg/sendmmsg；与 net.o 一并链入（G-02e-19：.inc + cc_inc_tu）
# G-02f-20：runtime_net_udp_batch 产品 seed
# wave523 R2 migration: thin (.x) + rest (.from_x.c) thin+rest mode — Linux only
#   - thin (.x): #[no_mangle] xlang_udp_batch_set_addr_port / poll_readable
#     (no _c suffix) forwarding to _impl
#   - rest (.from_x.c): _impl (sockaddr/poll) + 4 recvmmsg/sendmmsg weak APIs;
#     whole TU guarded by #if __linux__ && __GLIBC__ → macOS cold = empty .o
#   - PLATFORM: LINUX — R2 path gated on UNAME_S=Linux; macOS stays cold (empty)
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_net_udp_batch.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：net accept worker 线程入口；与 net.o 一并链入（G-02e-18：.inc + cc_inc_tu）
# G-02f-20：runtime_net_workers 产品 seed
# wave517 R2 migration: thin (.x) + rest (.from_x.c) thin+rest mode
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_net_workers.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：sync Mutex/RwLock/Condvar + 锁诊断 TLS；与 sync.o 一并链入（G-02e-20）
# G-02f-19：runtime_sync_os 产品 seed；wave504 R2 full mode
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_sync_os.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-19：runtime_sync_lock_diag_tls 产品 seed；wave538 R2 thin+rest pattern
#   - thin (.x): 5 #[no_mangle] (find_meta_idx/get_order/append_byte/append_lit/append_i32)
#     forwarding to _impl for 2, pure for 3
#   - rest (.from_x.c): _impl (find_meta_idx/get_order) + static state; guarded by
#     XLANG_RUNTIME_SYNC_LOCK_DIAG_TLS_FROM_X
#   PLATFORM: SHARED — pure C + __thread (POSIX) / __declspec(thread) (MSVC)
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_sync_lock_diag_tls.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：thread pthread/CreateThread；与 thread.o 一并链入（G-02e-20）
# G-02f-18：runtime_thread_glue 产品 seed；wave513 R2 thin+rest pattern
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_thread_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：async 协作调度 + async_net_fs；与 scheduler.o 一并链入（按需 -pthread）
# G-02f-18：runtime_scheduler_glue 产品 seed（#include async_net_fs.from_x.c）
# wave754 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MISC_BASENAME_OBJS).
# Thin passes -Isrc/asm for historical parity with make recipe (include path).
runtime_scheduler_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave794 B7A: heat dep-edge thin twin residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x + async_net_fs #include (seed_project_hdrs_newer first-hop).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：HTTP 客户端/服务端胶层（含 http2/*.inc.c）；与 http.o 一并链入（G-02e-21）
# G-02f-21：runtime_http_glue 产品 seed（#include http2/*.inc）；thin 在 src/asm/http/
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_http_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：mbedTLS BIO 胶层；net-o-mbedtls 时 ld -r 并入 tls_mbedtls.o（G-02e-18 .inc）
# G-02f-21：runtime_tls_mbedtls_bio 产品 seed
# wave522 R2 migration: thin (.x) + rest (.from_x.c) thin+rest mode
#   - thin (.x): #[no_mangle] xlang_mbedtls_bio_send / bio_recv (no _c suffix)
#     forwarding to _impl
#   - rest (.from_x.c): _impl (send/recv syscalls + errno→mbedTLS mapping) +
#     xlang_mbedtls_ssl_bind_fd_c (always compiled, takes fn address of thin
#     wrappers via forward declaration); needs mbedtls/ssl.h include
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_tls_mbedtls_bio.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：db.kv mmap 胶层；与 kv.o 按需同链（G-02e-17：.inc + cc_inc_tu）
# G-02f-21：runtime_kv_mmap_glue 产品 seed
# wave754 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MISC_BASENAME_OBJS).
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_kv_mmap_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：db.arrow SIMD 胶层；与 arrow.o 按需同链（G-02e-19：.inc + cc_inc_tu）
# G-02f-21：runtime_arrow_simd_glue 产品 seed
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_arrow_simd_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：db.sqlite 胶层（libsqlite3）；与 sqlite.o 同链（G-02e-20）
# G-02f-21：runtime_sqlite_glue 产品 seed
# wave753 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_EXTRA_CFLAGS_OBJS).
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_sqlite_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# wave753 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_EXTRA_CFLAGS_OBJS).
# Multi-out from same seed as runtime_sqlite_glue.o (no -DXLANG_DB_USE_SQLITE3).
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_sqlite_glue_stub.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# G-02f-20：runtime_crypto_inc_glue 产品 seed
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_crypto_inc_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：Ed25519 ref10（含 crypto/ed25519/*.c）；与 crypto.o 一并链入（G-02e-17 .inc）
# G-02f-20：runtime_ed25519_ref10_glue 产品 seed
# wave520 R2 migration: thin (.x) + rest (.from_x.c) thin+rest mode
#   - thin (.x): #[no_mangle] ed25519_ref10_create_keypair/sign/verify (no _c
#     suffix to match ed25519.x extern declarations)
#   - rest (.from_x.c): .inc files emit *_impl_c via macro rename; sha512
#     stays as ed25519_ref10_sha512* (consumed by runtime_crypto_inc_glue)
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_ed25519_ref10_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：codegen 入口 argc/argv 全局；与 process.o 一并链入（G-02e-18：.inc + cc_inc_tu）
# G-02f-20：runtime_process_argv 产品 seed
# wave521 R2 migration: thin (.x) + rest (.from_x.c) thin+rest mode
#   - thin (.x): #[no_mangle] xlang_process_argv_bind_from_crt (no _c suffix
#     to match extern declarations) forwarding to _impl
#   - rest (.from_x.c): _impl (CRT bind logic) + constructor + getters + weak
#     fallbacks; all always compiled (constructor/getters/weak are C-only)
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_process_argv.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# F-ZC：进程 OS 胶层（getenv/spawn/getcwd 等）；与 process.o 一并链入（G-02e-20）
# G-02f-18：runtime_process_os_glue 产品 seed；wave507 R2 full mode
# wave779 B1: dual hybrid → ensure try-runtime-os-prefer (G.7; not physical delete).
# PLATFORM: SHARED — PREFER=0 cold seed; PREFER=1 thin.x + rest FROM_X.
# wave791 B7A: heat dep-edge thin — prereqs → FORCE + ensure script only;
# shell owns seed/.x freshness (try-heat → prefer/R1 ensure). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
runtime_process_os_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# 无 C 自举：crt0 提供 _start 与 driver_get_argv_i；链接 asm 版 xlang 时用本 .o 替代 main.o / runtime_asm_build.o
# wave762 R2: body → ensure_host_cc_seed_o.sh try-r2 (list = DRIVER_SEED_CRT0_OBJS /
# DRIVER_SEED_TYPECK_F64_OBJS). UNAME ifeq only selects which target is defined on
# this host; recipe body is shell (G.7 single cold body). PLATFORM tags in ensure.
# wave795 B7A: heat dep-edge thin pure asm residual — .s prereqs → FORCE + ensure;
# try-heat owns .s/seed mtime (try-r2). Host ifeq gate kept. NOT physical delete.
ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
src/asm/crt0_x86_64.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# S4 freestanding 用户程序入口（call _main；见 tests/run-freestanding-hello.sh）
src/asm/crt0_user_x86_64.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# S4 freestanding syscall write（xlang_sys_write）
src/asm/freestanding_io_x86_64.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" bash scripts/ensure_host_cc_seed_o.sh try-heat $@
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
	sh scripts/cc_inc_tu.sh seeds/bootstrap_nostdlib_stubs.from_x.c $@
endif
endif
# E-04 v20：Darwin bootstrap 默认 crt0（arm64 / x86_64 Mach-O）
ifeq ($(UNAME_S),Darwin)
ifneq (,$(filter arm64 aarch64,$(UNAME_M)))
src/asm/crt0_arm64.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" bash scripts/ensure_host_cc_seed_o.sh try-heat $@
else ifneq (,$(filter x86_64 amd64,$(UNAME_M)))
src/asm/crt0_darwin_x86_64.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" bash scripts/ensure_host_cc_seed_o.sh try-heat $@
endif
endif
# E-04 v21：Windows/MinGW/MSYS bootstrap 默认 crt0_mingw 替代 main_driver.o
# wave762: try-r2 body (cc_inc_tu + WIN32_O_CFLAGS inside ensure; list = DRIVER_SEED_CRT0)
ifeq ($(XLANG_IS_WIN_HOST),1)
src/asm/crt0_mingw.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" WIN32_O_CFLAGS="$(WIN32_O_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
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
	@CC="$(CC)" CFLAGS="$(CFLAGS)" bash scripts/ensure_host_cc_seed_o.sh try-heat $@
else ifeq ($(UNAME_M),aarch64)
src/typeck/typeck_f64_bits.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave795 B7A: heat dep-edge thin pure asm residual — .s prereq → FORCE + ensure;
# try-heat owns host-picked .s mtime (r2-typeck-f64). NOT physical delete.
	@CC="$(CC)" CFLAGS="$(CFLAGS)" bash scripts/ensure_host_cc_seed_o.sh try-heat $@
else
$(error typeck_f64_bits: unsupported Linux arch $(UNAME_M); add .s)
endif
else ifeq ($(UNAME_S),Darwin)
ifeq ($(UNAME_M),arm64)
src/typeck/typeck_f64_bits.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave795 B7A: heat dep-edge thin pure asm residual — .s prereq → FORCE + ensure;
# try-heat owns host-picked .s mtime (r2-typeck-f64). NOT physical delete.
	@CC="$(CC)" CFLAGS="$(CFLAGS)" bash scripts/ensure_host_cc_seed_o.sh try-heat $@
else ifeq ($(UNAME_M),x86_64)
# Darwin x86_64：SysV .s 无 _ 前缀；clang 汇编 Mach-O 时需额外处理，当前主路径为 arm64。
src/typeck/typeck_f64_bits.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave795 B7A: heat dep-edge thin pure asm residual — .s prereq → FORCE + ensure;
# try-heat owns host-picked .s mtime (r2-typeck-f64). NOT physical delete.
	@CC="$(CC)" CFLAGS="$(CFLAGS)" bash scripts/ensure_host_cc_seed_o.sh try-heat $@
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
	@CC="$(CC)" CFLAGS="$(CFLAGS)" bash scripts/ensure_host_cc_seed_o.sh try-heat $@
else
$(error typeck_f64_bits: unsupported Windows arch $(UNAME_M); add .s)
endif
else
$(error typeck_f64_bits: unsupported OS $(UNAME_S); add .s)
endif

# wave718: clean body → scripts/clean_compiler.sh (G.7 single authority)
clean:
	@TARGET='$(TARGET)' XLANG_C='$(XLANG_C)' sh scripts/clean_compiler.sh

# 阶段 1 词法 + 阶段 3 类型检查 + …；依赖 xlang 与全部 std .o、runtime_panic.o，clean 后 test 会先构建再跑脚本
# test_c：与 ../tests/run-all-c.sh 等价（C 版 xlang-c 跑整份 run-all，不含自举专用脚本）
# test_x：bootstrap-driver-seed + run-lsp + run-all-x（.x 流水线全量）
# wave720: bodies → scripts/run_compiler_tests.sh (G.7); prereqs stay make graph.
# 依赖 $(XLANG_C) 以便 make clean && make test_c 时 xlang-c 存在
test_c: $(TARGET) $(XLANG_C) $(STD_AND_PANIC_O)
	@TARGET='$(TARGET)' XLANG_C='$(XLANG_C)' XLANG_TEST_ENSURE=0 \
	  sh scripts/run_compiler_tests.sh c

# x 自举：bootstrap-driver-seed + LSP + 全量自举（run-all-x：用 xlang_x 跑整份 run-all）
test_x: bootstrap-driver-seed
	@TARGET='$(TARGET)' XLANG_TEST_ENSURE=0 XLANG_TEST_ENSURE_SEED=0 \
	  sh scripts/run_compiler_tests.sh x

# 全量：先 C 再 x 自举（thin: reuses c/x shells via mode all)
test: test_c test_x
	@echo "Test all OK"

# wave719: bootstrap-token/lexer body → scripts/bootstrap_token_lexer_smoke.sh (G.7)
# 依赖 $(STD_AND_PANIC_O)：-o 链 std/io 等 .o，clean 后仅 make $(TARGET) 会缺这些文件导致 cc 失败。
bootstrap-token: $(TARGET) $(STD_AND_PANIC_O)
	@TARGET='$(TARGET)' sh scripts/bootstrap_token_lexer_smoke.sh token

bootstrap-lexer: $(TARGET) $(STD_AND_PANIC_O)
	@TARGET='$(TARGET)' sh scripts/bootstrap_token_lexer_smoke.sh lexer

# wave844: full body → scripts/bootstrap_parser_smoke.sh (G.7 有则补全; shell owns
#   parser.x -o smoke + parse-file dual-path fixtures). NOT physical delete —
#   prereq graph (relink-xlang / STD_AND_PANIC_O / bootstrap-parser) residual.
# 自举 9.1：用 xlang 编译 parser.x（import lexer + token + ast + std.fs），解析 function main(): i32 { return 0; } 并验证；-L .. 供 std.fs，-L src/lexer 供 token，-L src/ast 供 ast
bootstrap-parser: relink-xlang $(STD_AND_PANIC_O) scripts/bootstrap_parser_smoke.sh
	@TARGET='$(TARGET)' bash scripts/bootstrap_parser_smoke.sh parser

# 9.1 联调：.x `parse()` 支持 return 字面量或 `parse_expr_into`（堆上大块 Arena，栈安全）；宿主 xlang 走完整流水线。
# 第二段：`return (1 + 2) * 3 + -1`，.x standalone 走 parse()→堆上 Arena→parse_expr_into；宿主 xlang 走完整流水线。
bootstrap-parse-file: $(TARGET) $(STD_AND_PANIC_O) bootstrap-parser scripts/bootstrap_parser_smoke.sh
	@TARGET='$(TARGET)' bash scripts/bootstrap_parser_smoke.sh parse-file

# 迁移到 .x：parser.x -E-extern + ast 池 getter 补丁 → parser_x.o（提供 parser_parse_into_buf；与瘦 pipeline_x.o 分 TU）。
# 须 xlang-x -x -E 全量 TU；xlang-c 瘦 gen 缺 copy_module_import_path64 / parse_expr_into 等。
# ast_gen2.c 仅 typeck/codegen 单 TU 需要；clean worktree 用 pinned parser seed 时不应先触发它。
# wave736: G.7 body → scripts/ensure_migrate_gen.sh (parser_gen.c seed/pin/-E)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
parser_gen.c: FORCE scripts/ensure_migrate_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_PARSER_GEN_TIMEOUT="$(XLANG_PARSER_GEN_TIMEOUT)" \
	  XLANG_C="$(XLANG_C)" XLANG_X="$(XLANG_X)" \
	  bash scripts/ensure_migrate_gen.sh parser
# wave735: G.7 body → scripts/migrate_x_objs.sh (parser leaf)
# wave832: FORCE dep-thin — shell owns gen.c mtime (migrate need_rebuild; not physical delete).
# PLATFORM: SHARED — FORCE always invokes migrate (cheap mtime skip).
parser_x.o: FORCE scripts/migrate_x_objs.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PYTHON="$(PYTHON)" MAKE="$(MAKE)" \
	  sh scripts/migrate_x_objs.sh parser

# lexer.x：须 xlang-x -x -E 全量 TU；xlang-c 无 -x 时缺 advance_one/next_body。
# wave737: G.7 body → scripts/ensure_migrate_gen.sh lexer (pin/seed/-E + slim + token enum)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
lexer_gen.c: FORCE scripts/ensure_migrate_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" XLANG_X="$(XLANG_X)" \
	  bash scripts/ensure_migrate_gen.sh lexer

# wave782: B4 gen.c → .o bootstrap body → try-gen-c-to-o (thin-call only).
# wave796 B7A: heat dep-edge thin gen_x residual — gen.c prereq → FORCE + ensure;
# try-heat → try-gen-c-to-o owns lexer_gen.c mtime. NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
lexer_x.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-11：x_seed_bridge 产品 seed
# wave749 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_CORE_SEED_OBJS).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/x_seed_bridge.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# pipeline_x.o 仍引用 typeck_typeck_* / codegen_codegen_* / lexer_lexer_*；*_x.o 导出无重复前缀名。
# G-02f-16：x_frontend_link_alias 产品 seed（G-02e-8 三 alias 并入体）
# wave752 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_ALIAS_STUBS_OBJS).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
x_frontend_link_alias.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-17：strict/bootstrap bare alias + typeck stubs seeds
# wave752 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_ALIAS_STUBS_OBJS).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
ast_asm_bare_link_alias.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
backend_asm_bare_link_alias.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
backend_asm_strict_fallback_alias.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
typeck_c_module_stubs.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# wave727 · 11.0.4: USER_ASM / Darwin filtered / ASM_HOST_DISPATCH lists live in
# mk/user_asm_seed_objs.mk (G.7 single authority; do not re-assign here).
# Thin leaf bootstrap-driver-seed-asm-host is the cold-orch entry; build-seed-asm-host
# remains the historical alias (g05 hints / external callers).
include mk/user_asm_seed_objs.mk

.PHONY: build-seed-asm-host bootstrap-driver-seed-asm-host
# partial export 须先 nm dispatch .o 剔除重复符号；冷启动时 dispatch 可能尚未编译。
.PHONY: parser-legacy-text-o
parser-legacy-text-o:
	@chmod +x scripts/extract_parser_legacy_text.sh 2>/dev/null || true
	@./scripts/extract_parser_legacy_text.sh

bootstrap-driver-seed-asm-host: $(DRIVER_SEED_ASM_HOST_DISPATCH_OBJS)
	@chmod +x scripts/build_seed_asm_host.sh 2>/dev/null || true
	@./scripts/build_seed_asm_host.sh

# Historical alias → thin leaf (G.7 single body; no second recipe).
build-seed-asm-host: bootstrap-driver-seed-asm-host

# §5b #9 — host stubs body → scripts/bootstrap_driver_seed_host_stubs.sh (wave723).
# SCAN_BASE / CFLAGS / OUT: Makefile export only (G.7). Optional HOST_DIR peers
# (asm_full.o, asm_backend_partial.o) remain fixed relative names in shell.
$(USER_ASM_SEED_HOST_STUBS): pipeline_x.o $(ASM_GLUE_STANDALONE_O) $(USER_ASM_SEED_OBJS) scripts/gen_asm_full_link_stubs.pl scripts/bootstrap_driver_seed_host_stubs.sh
	@chmod +x scripts/bootstrap_driver_seed_host_stubs.sh 2>/dev/null || true
	@MAKE="$(MAKE)" ./scripts/bootstrap_driver_seed_host_stubs.sh

$(USER_ASM_SEED_HOST_OBJS): build-seed-asm-host

# G-02f-15：user_asm_seed_bridge 产品 seed
# wave752 R1 cold: ensure one · wave769 product PREFER → try-l2-asm-prefer.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/asm/user_asm_seed_bridge.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-15：asm_backend_compat_stubs 产品 seed
# wave752 R1 cold: ensure one · wave769 product PREFER → try-l2-asm-prefer.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/asm/asm_backend_compat_stubs.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-9 / Phase 4：backend_*_dispatch thin+rest PREFER_X_O
# wave757 R3 cold-else + wave763 R3 PREFER thin → ensure try-r3-prefer.
# wave763: PREFER gate unified (PREFER=1 only) for cold-chain safety (Darwin).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/asm/backend_enc_dispatch.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-15：backend_x86_64_enc_c 产品 seed
# wave754 R1 cold: ensure one · wave769 product PREFER → try-l2-asm-prefer.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/asm/backend_x86_64_enc_c.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# CG002：backend_arm64_enc_c 产品 seed（强符号覆盖 seed_link_compat weak -1 桩）
# PLATFORM: MACOS arm64 pure-asm 必需；其它主机链接无害（ta!=1 不调）。
# wave754 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MISC_BASENAME_OBJS).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/asm/backend_arm64_enc_c.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave757 R3 cold-else + wave763 R3 PREFER thin → ensure try-r3-prefer.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/asm/backend_arch_emit_dispatch.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave757 R3 cold-else + wave763 R3 PREFER thin → ensure try-r3-prefer.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/asm/backend_try_inline_dispatch.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave757 R3 cold-else + wave763 R3 PREFER thin → ensure try-r3-prefer.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/asm/backend_call_dispatch.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# parser EMIT_HEAVY thin delegate C 目标：bootstrap xlang 须链入，extern bl 白名单 emit 才不 segfault。
# 全量 parser_x.o 已含 parse_into_buf / get_module_* 等；禁 seed slice 与重复前缀符号。
PARSER_ASM_THIN_GLUE_CFLAGS = -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE
PARSER_ASM_LINK_ALIAS_CFLAGS = -DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS
# G-02f-10：thin glue / parse_expr_link 产品 seed
# PLATFORM: SHARED — thin glue monothin includes many parser_asm/*.inc; list ALL
# of them so make rebuilds when glue_tail/library_wrap/etc. change (stale .o caused
# Ubuntu UNDEF parser_skip_one_top_level_let_into_glue after M2 re-pin).
# wave758 R1 seed-map: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_SEED_MAP_OBJS).
# Seed map: parser_asm_thin_glue.o ← seeds/parser_asm_thin_c.from_x.c (basename mismatch).
# ensure_one refreshes on seeds/parser_asm/*.inc (G.7 single body twin of former prereqs).
# wave831: FORCE dep-thin — drop seed/.x/*.inc make-graph prereqs; try-heat owns mtime.
# NOT physical delete. PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
parser_asm_thin_glue.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  PARSER_ASM_THIN_GLUE_CFLAGS="$(PARSER_ASM_THIN_GLUE_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave753 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_EXTRA_CFLAGS_OBJS).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/asm/parser_asm_parse_expr_link.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@


# Authority: scripts/filter_bootstrap_seed_against_partial_o.sh → filter_o_export_against_deps.sh
# (G.7 single path; g05_ensure same). PLATFORM: SHARED — Darwin product USER_ASM_LINK.
# wave835: FORCE dep-thin — drop SRC/partial make-graph prereqs; shell owns mtime +
# try-heat SRC then filter (parallel-safe). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes ensure (cheap mtime skip).
build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o: FORCE scripts/filter_bootstrap_seed_against_partial_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/filter_bootstrap_seed_against_partial_o.sh ensure $@

build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o: FORCE scripts/filter_bootstrap_seed_against_partial_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/filter_bootstrap_seed_against_partial_o.sh ensure $@

build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o: FORCE scripts/filter_bootstrap_seed_against_partial_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/filter_bootstrap_seed_against_partial_o.sh ensure $@

# Authority: scripts/filter_bootstrap_seed_pipeline_o.sh → filter_o_export_against_deps.sh
# (G.7 single path; g05_ensure same). PLATFORM: SHARED — Darwin product link primary.
# wave835: FORCE dep-thin — drop pipeline_x/partial/strict_minimal make-graph prereqs;
# shell owns mtime + try-heat SRC. NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes ensure (cheap mtime skip).
build_asm/bootstrap_seed_pipeline_filtered.o: FORCE scripts/filter_bootstrap_seed_pipeline_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/filter_bootstrap_seed_pipeline_o.sh ensure $@

# wave831: FORCE dep-thin — shell owns seed mtime (cc_inc_tu; not physical delete).
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
src/asm/asm_experimental_symbol_bridge.o: FORCE scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh seeds/asm_experimental_symbol_bridge.from_x.c $@

# 迁移到 .x：parser/typeck/codegen 独立 -E-extern 产物；pipeline_x.o 仅编排（-E-extern），seed 链 typeck_x.o/codegen_x.o。
# wave735/736: G.7 body → migrate_x_objs.sh (_x.o) + ensure_migrate_gen.sh (*_gen.c)
migrate-x-objs:
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PYTHON="$(PYTHON)" MAKE="$(MAKE)" \
	  sh scripts/migrate_x_objs.sh all

# wave830: G.7 body → scripts/ensure_ast_gen2.sh (pin / FORCE_REGEN / -E + fix_slim)
# FORCE dep-thin — shell owns pin policy (G.7; not physical delete).
# PLATFORM: SHARED — FORCE always invokes ensure (cheap pin skip).
ast_gen2.c: FORCE scripts/ensure_ast_gen2.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" \
	  bash scripts/ensure_ast_gen2.sh

# wave782: B4 gen.c → .o bootstrap body → try-gen-c-to-o (thin-call only).
# wave796 B7A: heat dep-edge thin gen_x residual — gen.c prereq → FORCE + ensure;
# try-heat → try-gen-c-to-o owns ast_gen2.c mtime. NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
ast_gen2.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave736: G.7 body → scripts/ensure_migrate_gen.sh (typeck_gen.c seed/pin/-E)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
typeck_gen.c: FORCE scripts/ensure_migrate_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" \
	  bash scripts/ensure_migrate_gen.sh typeck

# wave735: G.7 body → scripts/migrate_x_objs.sh (typeck leaf)
# wave832: FORCE dep-thin — shell owns gen.c mtime (migrate need_rebuild; not physical delete).
# PLATFORM: SHARED — FORCE always invokes migrate (cheap mtime skip).
typeck_x.o: FORCE scripts/migrate_x_objs.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PYTHON="$(PYTHON)" MAKE="$(MAKE)" \
	  sh scripts/migrate_x_objs.sh typeck

# wave736: G.7 body → scripts/ensure_migrate_gen.sh (codegen_gen.c tip seed pin/-E)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
codegen_gen.c: FORCE scripts/ensure_migrate_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" \
	  bash scripts/ensure_migrate_gen.sh codegen

# wave735: G.7 body → scripts/migrate_x_objs.sh (codegen leaf)
# wave832: FORCE dep-thin — shell owns gen.c mtime (migrate need_rebuild; not physical delete).
# PLATFORM: SHARED — FORCE always invokes migrate (cheap mtime skip).
codegen_x.o: FORCE scripts/migrate_x_objs.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PYTHON="$(PYTHON)" MAKE="$(MAKE)" \
	  sh scripts/migrate_x_objs.sh codegen

# 6.1：.x typeck 入口与 C AST 对接；force-regen typeck_gen → migrate typeck_x → relink TARGET。
# wave785 B7c: typeck_x.o → migrate_x_objs (no dual $(CC) -c).
# wave841: full body → scripts/bootstrap_typeck_codegen.sh (G.7 有则补全 ensure_migrate_gen
#   FORCE_REGEN + migrate_x_objs; Makefile thin-call only).
# wave850 B7B: BTC_OBJS bag → mk/driver_seed_composites.mk RELINK_PRODUCT_LINK_OBJS
#   (G.7 有则补全; no dual inline product link inventory in typeck/codegen/relink-lexer).
# wave856: shell loads LINK_OBJS via export-relink-product-link-objs (no multi-token BTC_OBJS=).
# wave857: shell loads LINK_CFLAGS via export leaves (no multi-token BTC_CFLAGS=).
# NOT physical delete — prereq make-graph + thin edges + mk lists remain residual.
# PLATFORM: SHARED — shell owns gen/migrate/link orchestration.
bootstrap-typeck: $(TARGET) $(XLANG_C) bootstrap_xlangc $(RELINK_XLANG_PREREQS) scripts/bootstrap_typeck_codegen.sh
	@MAKE="$(MAKE)" TARGET="$(TARGET)" XLANG_C="$(XLANG_C)" CC="$(CC)" \
	  CFLAGS="$(CFLAGS)" PYTHON="$(PYTHON)" \
	  bash scripts/bootstrap_typeck_codegen.sh typeck

# 6.2：.x codegen 入口与 C AST 对接；force-regen typeck+codegen gen → migrate both → relink TARGET。
# wave785 B7c: typeck/codegen .o → migrate_x_objs (no dual $(CC) -c).
# wave841: full body → scripts/bootstrap_typeck_codegen.sh (G.7 有则补全; same shell as typeck).
# wave850 B7B: BTC_OBJS → $(RELINK_PRODUCT_LINK_OBJS) (composites.mk; same bag as typeck/RXL).
# wave856: shell loads LINK_OBJS via export-relink-product-link-objs (no multi-token BTC_OBJS=).
# wave857: shell loads LINK_CFLAGS via export leaves (no multi-token BTC_CFLAGS=).
# NOT physical delete — prereq make-graph + thin edges + mk lists remain residual.
# PLATFORM: SHARED — shell owns gen/migrate/link orchestration.
bootstrap-codegen: $(TARGET) $(XLANG_C) bootstrap_xlangc $(RELINK_XLANG_PREREQS) scripts/bootstrap_typeck_codegen.sh
	@MAKE="$(MAKE)" TARGET="$(TARGET)" XLANG_C="$(XLANG_C)" CC="$(CC)" \
	  CFLAGS="$(CFLAGS)" PYTHON="$(PYTHON)" \
	  bash scripts/bootstrap_typeck_codegen.sh codegen

# 6.3/6.4：入口在 main.x；链接时用 main_driver.o（带 XLANG_USE_X_DRIVER/PIPELINE 以启用 -backend asm）+ runtime_driver.o + ...
# G-02f-16：main_driver 与 main 同源 seed
# wave751 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MAIN_RUNTIME_OBJS).
src/main_driver.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave794 B7A: heat dep-edge thin Makefile-flags residual — prereqs → FORCE + ensure;
# try-heat owns seed/main_c_entry.x + Makefile flag mtime (force_thin_makefile_flags_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# G-02a: preprocess.c 已物理删除；runtime preprocess() 走 preprocess.x（preprocess_x.o）。
# G-02f-6：target_cpu.o 单 TU（pure seed 含 OS detect；无 ld -r cold）
# wave755 R1: pure host-cc body → ensure (list = R1_SEED_MAP_OBJS).
# wave768 product PREFER flags.x + rest → try-target-cpu-prefer (cold pure seed fallback).
# Seed map: target_cpu.o ← seeds/target_cpu_pure.from_x.c (basename mismatch).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/driver/target_cpu.o: FORCE scripts/ensure_host_cc_seed_o.sh
	# wave768: target_cpu PREFER flags.x + rest → try-target-cpu-prefer (cold pure seed fallback).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# G-02f-7 / Phase 4：simd_enc thin+rest PREFER_X_O
# 源：src/asm/simd_enc_thin.x（74 #[no_mangle] thin wrapper）+ seeds/simd_enc.from_x.c（_impl rest）
# 仅 XLANG_G05_PREFER_X_O=1 且 xlang-c 可用时走 thin；否则 seed 完整编译。
# 【Why 2026-07-16】Darwin 上 bootstrap_xlangc 常在：若仅按「有 xlang-c」走 thin，thin 可能
# 假成功（能 cc/ld -r 但缺 simd_rbp_disp32 等强符号）→ seed phase1 链失败。
# Ubuntu 上 thin 生成 C 常编译失败并回退 seed，故冷链绿；mac 须与冷链同源：默认 seed。
# 验收：nm 须有 simd_rbp_disp32，否则丢弃 thin 回退 seed（body = try-r3-prefer）。
# wave757 R3 cold-else + wave763 R3 PREFER thin → ensure try-r3-prefer.
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/asm/simd_enc.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
# G-02f-8 / Phase 4：simd_loop thin+rest PREFER_X_O
# 源：src/asm/simd_loop_thin.x（22 #[no_mangle] thin wrapper）+ seeds/simd_loop.from_x.c（17 _impl rest）
# 仅 XLANG_G05_PREFER_X_O=1 且 xlang-c 可用时走 thin；否则 seed 完整编译（同 simd_enc 冷链纪律）。
# wave757 R3 cold-else + wave763 R3 PREFER thin → ensure try-r3-prefer.
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/asm/simd_loop.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
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
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell owns link orchestration.
bootstrap-driver-seed-x-frontend: $(XLANG_C) migrate-x-objs driver_x.o preprocess_x.o $(DRIVER_SUBCMD_GEN) $(DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS) $(LSP_DIAG_LINK_O) $(DRIVER_SUBCMD_OBJS) scripts/bootstrap_driver_seed_x_frontend.sh
	@MAKE="$(MAKE)" CC="$(CC)" OUT="$(TARGET)_x_frontend" \
	  bash scripts/bootstrap_driver_seed_x_frontend.sh

# 6.3：.x 入口与 main.c 一一对应。bootstrap-driver-seed = 用 C 代码生成（生成 pipeline_gen.c / driver_gen.c）得到种子 xlang；仅首次或无 xlang 时需要。
# bootstrap-driver-asm / bootstrap-driver-hybrid = B-hybrid（build_xlang_asm 无 SKIP_GEN），产出可覆盖 $(TARGET)。
# bootstrap-driver = M7 默认 B-strict（同 bootstrap-driver-bstrict）：SKIP_GEN 链 xlang_asm 并覆盖 $(TARGET)；冷启动仍仅 bootstrap-driver-seed。
# 无补丁：driver_gen.c 仅由 -E -E-extern 生成；run_compiler_c 在 runtime.c 中定义并转调 main_run_compiler_c；其余从 main.x/codegen 根源修
# LSP 诊断：G-02a lsp_diag.c 已删；仅 lsp_diag_x.o + stubs。

# 非产品 / xlang-c 弱占位链：仍用手写 .inc（含 weak fill_paths 等）
# wave831: FORCE dep-thin — shell owns seed mtime (cc_inc_tu; not physical delete).
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
src/lsp/lsp_diag_pipeline_sizes.o: FORCE scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh seeds/lsp_diag_pipeline_sizes_weak.from_x.c $@ -I. -Iinclude -Isrc

# G-02f-1 / Phase 4：产品 G05 nostub 真迁 .x（#[no_mangle] 三枚 sizeof）
# 源：src/lsp/lsp_diag_pipeline_sizes.x
# 冷启动产物：seeds/lsp_diag_pipeline_sizes.from_x.c（xlang-c 不存在时回退）
# wave781: B3 product PREFER dual hybrid body → try-lsp-sat-prefer (thin-call only).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/lsp/lsp_diag_pipeline_sizes_nostub.o: FORCE scripts/ensure_host_cc_seed_o.sh
	# wave781: B3 lsp-sat PREFER direct_e → try-lsp-sat-prefer (cold seed fallback).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02e-8：lsp_diag_x_alias 已并入本 TU。
# G-02f-12：lsp_diag_pipeline_ctx 产品 seed
# wave754 R1 cold: ensure_one · wave767 product PREFER thin+rest → try-ldpc-prefer.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/lsp/lsp_diag_pipeline_ctx.o: FORCE scripts/ensure_host_cc_seed_o.sh
	# wave767: ldpc PREFER thin+rest → try-ldpc-prefer (cold plain seed fallback).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-11：runtime_driver_strict_glue_stubs 产品 seed（内含 runtime_heap_user.inc）
# wave752 R1 cold: ensure_one · wave771 product PREFER thin+rest → try-other-l2-prefer.
src/runtime_driver_strict_glue_stubs.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave794 B7A: heat dep-edge thin twin residual — prereqs → FORCE + ensure;
# try-heat owns seed/stubs.x/thin.x + heap_user #include (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
	# wave771: other L2 PREFER thin+rest → try-other-l2-prefer (cold plain seed fallback).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02a：ast_seed.o 从 runtime_ast_glue.inc 编译（从 src/ast/ast.c 迁移）。
# 提供 ast_module_free/ast_expr_free/ast_block_free 等 8 个内存管理函数。
# 不含 ast_expr_init_match_enum（no_c 模式下由 x_seed_bridge.o 提供）。
# wave755 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_SEED_MAP_OBJS).
# Seed map: ast_seed.o ← seeds/runtime_ast_glue.from_x.c (basename mismatch).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/ast/ast_seed.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02a: ast_x.o alias — ast_seed.o 提供 C ABI 内存管理实现。
# wave836: FORCE dep-thin — shell owns SRC mtime + try-heat (ensure_cp_alias_o; not physical delete).
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
ast_x.o: FORCE scripts/ensure_cp_alias_o.sh
	@bash scripts/ensure_cp_alias_o.sh ensure $@

# G-02a: preprocess.c 已物理删除；preprocess.o 不再编译（preprocess_x.o 由 .x 生成）。

# G-02a: lexer.o 从 runtime_lexer_glue.inc 编译（G-02e-19：cc_inc_tu）。
# G-02f-21：runtime_lexer_glue 产品 seed
# wave750 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_FRONTEND_GLUE_OBJS).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/lexer/lexer.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-80：cfg_eval 冷启动 stub；legacy xlang-c 直链需要独立 .o 规则。
# wave831: FORCE dep-thin — shell owns seed+.x mtime (cc_inc_tu PEERS; not physical delete).
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
src/lexer/cfg_eval_bootstrap_stub.o: FORCE scripts/cc_inc_tu.sh
	@XLANG_CC_INC_TU_PEERS='src/lexer/cfg_eval_bootstrap_stub.x' \
	  sh scripts/cc_inc_tu.sh seeds/cfg_eval_bootstrap_stub.from_x.c $@

# G-02a: typeck.c 已物理删除；typeck_x.o 由 typeck.x 生成，typeck_c_module_stubs.o 提供 weak 桩。

# G-02a: codegen.c 已物理删除；codegen_x.o 由 codegen.x 生成，codegen_pipeline_stubs.o 提供 weak 桩。

# G-02a: autovec.c 已物理删除（孤立死代码，无任何调用点/include）。

# wave739: G.7 body → scripts/ensure_lsp_pipeline_gen.sh (product LSP gens)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
lsp_diag_gen.c: FORCE scripts/ensure_lsp_pipeline_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" XLANG_X="$(XLANG_X)" \
	  bash scripts/ensure_lsp_pipeline_gen.sh lsp_diag

# wave761: G.7 body → scripts/ensure_gen_x_o.sh (gen residual; try-gen-x)
# wave796 B7A: heat dep-edge thin gen_x residual — gen.c prereq → FORCE + ensure;
# try-heat → try-gen-x owns gen.c mtime. NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
lsp_diag_x.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# lsp_io.x：C-04 v0 要求 xlang-c 自动生成 import extern；xlang-x 仍走旧块时回退 xlang-c。
# wave739: G.7 body → scripts/ensure_lsp_pipeline_gen.sh
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
lsp_io_gen.c: FORCE scripts/ensure_lsp_pipeline_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" XLANG_X="$(XLANG_X)" \
	  bash scripts/ensure_lsp_pipeline_gen.sh lsp_io

# LSP 模块：main.x 依赖 lsp；std.io 由 .x codegen 提供（F-03 v2/v3，无 io.o）。
# LSP state 单独 .c，避免 lsp_main 内大数组导致 state 被覆盖

# lsp_gen.c 期望 typeck_read_message 等；lsp_io -E-extern 未产出时由桩提供（G-02e-16 .inc）。
# wave831: FORCE dep-thin — shell owns seed mtime (cc_inc_tu; not physical delete).
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
src/lsp/typeck_lsp_io_stub.o: FORCE scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh seeds/typeck_lsp_io_stub.from_x.c $@

# G-02f-11 / G-02f-440：seed_link_compat 产品 seed（thin named-weak 6 stubs）
# wave749 R1 cold: ensure_one · wave771 product PREFER thin+rest → try-other-l2-prefer.
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/seed_link_compat.o: FORCE scripts/ensure_host_cc_seed_o.sh
	# wave771: other L2 PREFER thin+rest → try-other-l2-prefer (cold plain seed fallback).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave739: G.7 body → scripts/ensure_lsp_pipeline_gen.sh (lsp_gen + g_lsp_state_buf post)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
lsp_gen.c: FORCE scripts/ensure_lsp_pipeline_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" XLANG_X="$(XLANG_X)" \
	  bash scripts/ensure_lsp_pipeline_gen.sh lsp_gen

# Track L：lsp_io_std_heap 叶子退役 — .x→.o（rename 与 prove_module_selfhost 一致）
# 冷启动仅 seeds/lsp_io_std_heap_gen.linux.x86_64.c；工作区 lsp_io_std_heap_gen.c 仅考古/FORCE_REGEN
# wave814: driver_leaf catalog → ensure (G.7; rename/dirs in script; not physical delete).
# wave828: FORCE dep-thin — shell owns catalog .x mtime (skip up-to-date); not physical delete.
# wave860: BASE_CFLAGS via export-driver-leaf-base-cflags when unset (no multi-token env).
lsp_io_std_heap_x.o: FORCE scripts/driver_leaf_x_to_o.sh
	@MAKE="$(MAKE)" bash scripts/driver_leaf_x_to_o.sh ensure $@
# wave740: G.7 body → scripts/ensure_archaeology_gen.sh (Track L archaeology only)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
lsp_io_std_heap_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" \
	  bash scripts/ensure_archaeology_gen.sh lsp_io_std_heap

# bootstrap-driver-seed / relink-xlang 共用：lsp_io / lsp 生成 C → .o
# wave761: G.7 body → scripts/ensure_gen_x_o.sh (lsp_io -D renames)
# wave796 B7A: heat dep-edge thin gen_x residual — gen.c/.x prereqs → FORCE + ensure;
# try-heat → try-gen-x owns gen.c + lsp_io.x mtime. NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
lsp_io_x.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave761: G.7 body → scripts/ensure_gen_x_o.sh
# wave796 B7A: heat dep-edge thin gen_x residual — gen.c prereq → FORCE + ensure.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
lsp_x.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# Driver 子命令 .o：
#   Track L 已退役叶子：fmt/check/test/build/run/compile/emit + lsp_io_std_heap → PREFER_X_O（.x→.o）
#   构建不读工作区 pinned *_gen.c；冷启动回退仅 seeds/*_gen.linux.x86_64.c
# wave816 B7B: list authority → mk/driver_subcmd_objs.mk (G.7; not physical delete).
# Makefile keeps include + consumers (seed link / relink / composites); no dual list.
include mk/driver_subcmd_objs.mk

# Track L：叶子 .o 直接来自 .x（scripts/driver_leaf_x_to_o.sh）；rename 与 prove_module_selfhost / g05 一致
# wave814: driver_leaf shell-primary catalog → ensure (G.7; not physical delete).
# wave828: FORCE dep-thin — Makefile prereqs FORCE+script only; shell owns catalog .x mtime.
# wave860: BASE_CFLAGS via export-driver-leaf-base-cflags when unset (no multi-token env).
# Makefile thin-call only; src/rename/cold-seed/-L + BASE_CFLAGS live in script catalog/export.
driver_fmt_x.o: FORCE scripts/driver_leaf_x_to_o.sh
	@MAKE="$(MAKE)" bash scripts/driver_leaf_x_to_o.sh ensure $@
driver_check_x.o: FORCE scripts/driver_leaf_x_to_o.sh
	@MAKE="$(MAKE)" bash scripts/driver_leaf_x_to_o.sh ensure $@
driver_test_x.o: FORCE scripts/driver_leaf_x_to_o.sh
	@MAKE="$(MAKE)" bash scripts/driver_leaf_x_to_o.sh ensure $@
driver_build_x.o: FORCE scripts/driver_leaf_x_to_o.sh
	@MAKE="$(MAKE)" bash scripts/driver_leaf_x_to_o.sh ensure $@
driver_run_x.o: FORCE scripts/driver_leaf_x_to_o.sh
	@MAKE="$(MAKE)" bash scripts/driver_leaf_x_to_o.sh ensure $@
# Track L：compile / emit 叶子退役（prove IDENTICAL；emit 依赖 codegen 字段访问 . vs -> 根修）
# wave814: rename maps moved into driver_leaf_x_to_o.sh catalog (G.7 single authority).
driver_compile_x.o: FORCE scripts/driver_leaf_x_to_o.sh
	@MAKE="$(MAKE)" bash scripts/driver_leaf_x_to_o.sh ensure $@
driver_emit_x.o: FORCE scripts/driver_leaf_x_to_o.sh
	@MAKE="$(MAKE)" bash scripts/driver_leaf_x_to_o.sh ensure $@

# wave740: G.7 body → scripts/ensure_archaeology_gen.sh
# 考古：可选再生成工作区 *_gen.c（不进 DRIVER_SEED_PREREQS；叶子已退役；产品用 *_x.o）
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_fmt_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" \
	  bash scripts/ensure_archaeology_gen.sh fmt
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_check_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" \
	  bash scripts/ensure_archaeology_gen.sh check
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_test_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" \
	  bash scripts/ensure_archaeology_gen.sh test
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_compile_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" \
	  bash scripts/ensure_archaeology_gen.sh compile
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_build_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" \
	  bash scripts/ensure_archaeology_gen.sh build
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_run_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" \
	  bash scripts/ensure_archaeology_gen.sh run
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_emit_gen.c: FORCE scripts/ensure_archaeology_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" \
	  bash scripts/ensure_archaeology_gen.sh emit

# driver_emit_x.o：见上文 Track L 叶子规则（.x→.o）；勿再从 pinned gen.c 覆盖

# asm_driver_*：driver_gen.c 为 extern 时由本桩提供符号（fmt/check/test 见 DRIVER_SUBCMD_OBJS）。
# 链接顺序：须紧跟 preprocess_x.o 之后（先于 lsp_diag/std *.o），避免与 runtime_driver.o
# 中 _preprocess / preprocess_preprocess_x_buf 解析顺序导致 Undefined _preprocess。

# Stage2 混合链接桩（verify-selfhost-stage2.sh）
# wave782: B4 gen.c → .o bootstrap body → try-gen-c-to-o (thin-call only).
# wave796 B7A: heat dep-edge thin gen_x residual — .c prereq → FORCE + ensure.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
_x_stubs2.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# PIPELINE_ASM_X_DEPS / PIPELINE_X_DEPS: list authority mk/x_source_deps.mk
# (wave823; included early so $(PIPELINE_X_DEPS) is non-empty here).
ifneq ($(filter 1,$(XLANG_FORCE_REGEN_GEN) $(PIPELINE_X_FORCE_COMPILE)),)
PIPELINE_X_FORCE_PREREQ = FORCE
endif

# pipeline_x.o：与 pipeline_gen.c 及 PIPELINE_X_DEPS 绑定；parser/backend 等 .x 变更须重编，避免 seed 仍用旧 pipeline 逻辑（entry 消失等）。
# 默认复用 build_asm/gen_driver/pipeline_x.o（fat 编排）；设 PIPELINE_X_FORCE_COMPILE=1 才从 pipeline_gen.c 重编。
# pipeline_glue.c / ast_pool.c 由 pipeline_glue_standalone.o 覆盖，勿因二者 mtime 触发整 TU 重编（否则与 partial 并列链 parse 塌陷）。
# wave761: G.7 body → scripts/ensure_gen_x_o.sh (gen_driver STALE + FORCE; DEPS from mk)
# wave796 B7A: heat dep-edge thin gen_x residual — gen/DEPS prereqs → FORCE + ensure;
# recipe still exports PIPELINE_X_DEPS for shell STALE; try-heat → try-gen-x.
# NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
pipeline_x.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  PIPELINE_X_DEPS="$(PIPELINE_X_DEPS)" \
	  PIPELINE_X_FORCE_COMPILE="$(PIPELINE_X_FORCE_COMPILE)" \
	  XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
FORCE:

# driver_gen.c / driver_x.o：main.x 驱动入口。
# wave738: G.7 body → scripts/ensure_driver_gen.sh (MAIN_X_DEPS freshness / seed / -E + fix dup main)
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
driver_gen.c: FORCE scripts/ensure_driver_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_DRIVER_GEN_TIMEOUT="$(XLANG_DRIVER_GEN_TIMEOUT)" \
	  XLANG_C="$(XLANG_C)" XLANG_X="$(XLANG_X)" \
	  bash scripts/ensure_driver_gen.sh driver

# wave782: B4 gen.c → .o bootstrap body → try-gen-c-to-o (thin-call only).
# wave796 B7A: heat dep-edge thin gen_x residual — gen/MAIN_X prereqs → FORCE + ensure;
# try-heat owns driver_gen.c + MAIN_X mtime. NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
driver_x.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# preprocess_gen.c / preprocess_x.o：runtime XLANG_USE_X_PREPROCESS 路径。
# wave738: G.7 body → scripts/ensure_driver_gen.sh preprocess
# wave829: FORCE dep-thin — shell owns pin/seed policy (G.7; not physical delete).
preprocess_gen.c: FORCE scripts/ensure_driver_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" XLANG_X="$(XLANG_X)" \
	  bash scripts/ensure_driver_gen.sh preprocess

# wave782: B4 gen.c → .o bootstrap body → try-gen-c-to-o (thin-call only).
# wave796 B7A: heat dep-edge thin gen_x residual — gen/PREPROCESS_X prereqs → FORCE + ensure;
# try-heat owns preprocess_gen.c + preprocess.x mtime. NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
preprocess_x.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# XLANG_NO_C_FRONTEND 下 lsp_diag_x.o / lsp_x.o 需要的文档缓冲 + X 管道缓冲桩
# G-02f-22：lsp_diag_stubs_no_c 产品 seed
# G-02f-rest：rest→.x 迁移（lsp_diag_copy_text_impl + json_escape_str_impl 真迁 .x）
# wave781: B3 product PREFER thin+rest dual hybrid body → try-lsp-sat-prefer (thin-call only).
# wave793 B7A: heat dep-edge thin pure seed+.x+.h residual — prereqs → FORCE + ensure;
# try-heat owns seed/.x/project-hdr mtime (seed_project_hdrs_newer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/lsp/lsp_diag_stubs_no_c.o: FORCE scripts/ensure_host_cc_seed_o.sh
	# wave781: B3 lsp-sat PREFER thin_rest_e → try-lsp-sat-prefer (cold seed fallback).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# XLANG_SKIP_SUBSCRIPT_MAKE=1：run-all 入口已链 seed，子脚本 `make` 仅在校验 xlang 缺失时再完整 bootstrap。
ifeq ($(XLANG_SKIP_SUBSCRIPT_MAKE),1)
bootstrap-driver-seed:
	@test -x '$(TARGET)' || $(MAKE) bootstrap-driver-seed XLANG_SKIP_SUBSCRIPT_MAKE= XLANG_RUN_ALL_BOOTSTRAP_XLANG=1
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
# PLATFORM: SHARED — shell owns link; lists stay mk expansion.
ifeq ($(XLANG_LEGACY_C_FRONTEND),1)
$(XLANG_C): $(LEGACY_XLANG_C_PREREQS) scripts/legacy_xlang_c_link.sh
	@MAKE="$(MAKE)" CC="$(CC)" OUT="$@" \
	  bash scripts/legacy_xlang_c_link.sh
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
	export-xxp-link-bags \
	export-bxc-link-objs \
	export-driver-leaf-base-cflags \
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

# §5b #2 — pipeline_x.o FORCE recompile on cold start (PIPELINE_X_FORCE_COMPILE=1)
# Body: bootstrap_driver_seed_rebuild_leaves.sh pipeline-x; list = DRIVER_SEED_PIPELINE_X_OBJS only.
bootstrap-driver-seed-export-pipeline-x:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_PIPELINE_X_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' ''
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' 'PIPELINE_X_FORCE_COMPILE=1'

bootstrap-driver-seed-pipeline-x:
	@chmod +x scripts/bootstrap_driver_seed_rebuild_leaves.sh 2>/dev/null || true
	@MAKE="$(MAKE)" ./scripts/bootstrap_driver_seed_rebuild_leaves.sh pipeline-x

# §5b #3 — satellite runtime/diag/simd forced seed path (XLANG_G05_PREFER_X_O=0)
# Body: bootstrap_driver_seed_rebuild_leaves.sh sat; list = DRIVER_SEED_SAT_REBUILD_OBJS only.
bootstrap-driver-seed-export-sat-rebuild:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_SAT_REBUILD_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' '-B'
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' 'XLANG_G05_PREFER_X_O=0'

bootstrap-driver-seed-sat-rebuild:
	@chmod +x scripts/bootstrap_driver_seed_rebuild_leaves.sh 2>/dev/null || true
	@MAKE="$(MAKE)" ./scripts/bootstrap_driver_seed_rebuild_leaves.sh sat

# §5b #4 — lsp / frontend alias objs (list = DRIVER_SEED_LSP_X_OBJS only)
bootstrap-driver-seed-export-lsp-x-objs:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_LSP_X_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' ''
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' ''

bootstrap-driver-seed-lsp-x-objs:
	@chmod +x scripts/bootstrap_driver_seed_rebuild_leaves.sh 2>/dev/null || true
	@MAKE="$(MAKE)" ./scripts/bootstrap_driver_seed_rebuild_leaves.sh lsp

# §5b #5 — x_seed_bridge.o (list = DRIVER_SEED_BRIDGE_OBJS only)
bootstrap-driver-seed-export-bridge:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_BRIDGE_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' ''
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' ''

bootstrap-driver-seed-bridge:
	@chmod +x scripts/bootstrap_driver_seed_rebuild_leaves.sh 2>/dev/null || true
	@MAKE="$(MAKE)" ./scripts/bootstrap_driver_seed_rebuild_leaves.sh bridge

# §5b #12 — runtime_panic.o (list = DRIVER_SEED_PANIC_OBJS only; platform recipe stays Makefile)
bootstrap-driver-seed-export-panic:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_PANIC_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' ''
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' ''

bootstrap-driver-seed-panic:
	@chmod +x scripts/bootstrap_driver_seed_rebuild_leaves.sh 2>/dev/null || true
	@MAKE="$(MAKE)" ./scripts/bootstrap_driver_seed_rebuild_leaves.sh panic

# §5b #6 — USER_ASM seed objs (list = DRIVER_SEED_USER_ASM_SEED_OBJS → USER_ASM_SEED_OBJS)
bootstrap-driver-seed-export-user-asm:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_USER_ASM_SEED_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' ''
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' ''

bootstrap-driver-seed-user-asm-seed-objs:
	@chmod +x scripts/bootstrap_driver_seed_rebuild_leaves.sh 2>/dev/null || true
	@MAKE="$(MAKE)" ./scripts/bootstrap_driver_seed_rebuild_leaves.sh user-asm

# §5b #7 — pipeline_glue_standalone.o (list = DRIVER_SEED_ASM_GLUE_OBJS)
bootstrap-driver-seed-export-glue:
	@printf 'SEED_REBUILD_OBJS=%s\n' '$(DRIVER_SEED_ASM_GLUE_OBJS)'
	@printf 'SEED_REBUILD_MAKE_ARGS=%s\n' ''
	@printf 'SEED_REBUILD_MAKE_VARS=%s\n' ''

bootstrap-driver-seed-asm-glue-standalone:
	@chmod +x scripts/bootstrap_driver_seed_rebuild_leaves.sh 2>/dev/null || true
	@MAKE="$(MAKE)" ./scripts/bootstrap_driver_seed_rebuild_leaves.sh glue


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

bootstrap-driver-seed-host-stubs:
	@chmod +x scripts/bootstrap_driver_seed_host_stubs.sh 2>/dev/null || true
	@MAKE="$(MAKE)" ./scripts/bootstrap_driver_seed_host_stubs.sh

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

bootstrap-driver-seed-phase1-link:
	@chmod +x scripts/bootstrap_driver_seed_link.sh 2>/dev/null || true
	@MAKE="$(MAKE)" ./scripts/bootstrap_driver_seed_link.sh phase1

bootstrap-driver-seed-final-link:
	@chmod +x scripts/bootstrap_driver_seed_link.sh 2>/dev/null || true
	@MAKE="$(MAKE)" TARGET="$(TARGET)" ./scripts/bootstrap_driver_seed_link.sh final

# wave744 · 11.3 residual: prereq *edges* satisfied inside bootstrap_driver_seed.sh
# via scripts/driver_seed_ensure_prereqs.sh (catalog DRIVER_SEED_PREREQS + glue
# companion). Makefile no longer carries $(DRIVER_SEED_PREREQS) as make-graph
# deps on this phony (G.7: list still mk only; shell owns edge walk).
# PLATFORM: SHARED — thin phony leaf; leaf .o pattern rules remain residual.
bootstrap-driver-seed:
	@chmod +x scripts/bootstrap_driver_seed.sh 2>/dev/null || true
	@MAKE="$(MAKE)" TARGET="$(TARGET)" XLANG_C="$(XLANG_C)" \
		XLANG_SKIP_SEED_SMOKE="$(XLANG_SKIP_SEED_SMOKE)" \
		./scripts/bootstrap_driver_seed.sh
endif

# 与 bootstrap-driver-seed 相同；保留别名供脚本引用
# bootstrap seed 链 需 glue 类型头（与 build_xlang_asm B-strict 同源）。
# PLATFORM: SHARED — run i64 ABI guard before extract so glue never sees int32_t Expr.int_val.
# wave833: FORCE dep-thin — prereqs → FORCE + ensure; shell owns gen/extract mtime
# + XLANG_GLUE_TYPES_FORCE + i64 ABI guard call (G.7). NOT physical delete.
# Extract algorithm remains extract_pipeline_glue_types.pl (not reimplemented).
build_asm/pipeline_glue_types.inc: FORCE scripts/ensure_pipeline_glue_types.sh
	@bash scripts/ensure_pipeline_glue_types.sh

# G-02f-17：pipeline_bootstrap_orchestration 产品 seed
# wave755 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_SEED_MAP_OBJS).
# Extras: -Ibuild_asm -DPIPELINE_BOOTSTRAP_ORCH_NO_PIPELINE_RUN_WRAPPER.
# wave797 B7A: heat dep-edge thin orch residual — prereqs → FORCE + ensure;
# try-heat/ensure_one owns seed/.x + pipeline_gen.c + build_asm/pipeline_glue_types.inc mtime.
# NOT physical delete. PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
pipeline_bootstrap_orchestration.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# wave759 R1 seed-map: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_SEED_MAP_OBJS).
# Seed map: build_asm/pipeline_glue_standalone.o ← seeds/pipeline_glue_standalone.from_x.c
# (path under build_asm/ + -Ibuild_asm; was cc_inc_tu residual; G.7 有则补全 seed-map).
$(ASM_GLUE_STANDALONE_O): FORCE scripts/ensure_host_cc_seed_o.sh
# wave794 B7A: heat dep-edge thin multi-c residual — prereqs → FORCE + ensure;
# try-heat/ensure_one owns glue.c/ast_pool/types.inc (wave759 twin) + seed mtime.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
	@mkdir -p build_asm
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-11：pipeline_glue_strict_minimal 产品 seed
# wave754 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MISC_BASENAME_OBJS).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
build_asm/pipeline_glue_strict_minimal.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@mkdir -p build_asm
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

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
	@sh scripts/g05_ensure_relink_prereqs.sh

# 兼容：委托 scripts/g05_relink_env.sh（与 shell 清单单一真相）
g05-export-relink:
	@sh scripts/g05_relink_env.sh

# 兼容入口：委托 G-05 shell 编排（无 recipe 内嵌 cc；产品路径零 make）
relink-xlang:
	@G05_SYNC_ASM=0 sh scripts/g05_prepare_and_relink.sh
	@echo "relink-xlang OK (via g05_prepare_and_relink.sh)"

xlang_asm:
	@G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
	@echo "xlang_asm OK (via g05_prepare_and_relink.sh)"

# wave849: full body → scripts/relink_xlang_lexer.sh (G.7 有则补全; shell owns seed
#   gate + host-cc link + XLANG_C/bootstrap_xlangc sync).
# wave850 B7B: RXL_LINK_OBJS → $(RELINK_PRODUCT_LINK_OBJS) (composites.mk; same bag
#   as BTC_OBJS typeck/codegen — no dual inline product link inventory).
# wave854 B7B: RELINK_XLANG_REQUIRED_OBJS list authority → composites.mk.
# wave855: shell loads REQUIRED from mk (no Makefile multi-token env export).
# wave856: shell loads LINK_OBJS via export-relink-product-link-objs (no multi-token RXL_LINK_OBJS=).
# NOT physical delete — prereq make-graph (lexer_x.o / FILTERED / GLUE) + thin edges
#   + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell owns preflight + link + product alias sync.
relink-xlang-lexer: lexer_x.o $(RELINK_XLANG_FILTERED_OBJS) $(RELINK_XLANG_GLUE_SUFFIX) scripts/relink_xlang_lexer.sh
	@MAKE="$(MAKE)" CC="$(CC)" TARGET="$(TARGET)" XLANG_C="$(XLANG_C)" BOOTSTRAP_XLANGC="bootstrap_xlangc" \
	  bash scripts/relink_xlang_lexer.sh

bootstrap-driver-seed-user-asm: bootstrap-driver-seed
	@echo "bootstrap-driver-seed-user-asm OK (= bootstrap-driver-seed + USER_ASM_LINK)"

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
xlang-no-c-frontend: $(DRIVER_NO_C_FRONTEND_OBJS) src/lsp/lsp_diag_stubs_no_c.o scripts/xlang_no_c_frontend.sh
	@MAKE="$(MAKE)" CC="$(CC)" OUT="$@" \
	  bash scripts/xlang_no_c_frontend.sh

# 注意：Makefile 中存在同名规则 `xlang-x:`，不能把 `xlang-x` 列为本目标 prerequisite，否则会先执行重链接口而非仅检测文件是否存在。
regen-lsp-gens-x:
	@if [ ! -f $(XLANG_X) ]; then echo "请先 make bootstrap-driver-seed（需要 ./$(XLANG_X)）。" >&2; exit 1; fi
	rm -f lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c
	$(MAKE) lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c
	@echo "regen-lsp-gens-x OK"

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
xlang-x: build-seed-asm-host $(DRIVER_SEED_OBJS) $(XLANG_X_PIPELINE_LINK_O) $(XLANG_X_USER_ASM_OBJS) driver_x.o preprocess_x.o $(RELINK_XLANG_GLUE_SUFFIX) scripts/xlang_x.sh
	@MAKE="$(MAKE)" CC="$(CC)" XLANG_X="$(XLANG_X)" \
	  bash scripts/xlang_x.sh

# Stage2：xlang-x 用 -x -E-extern 生成 _gen2.c 并链出 xlang-x2，与 xlang-x 行为对比（脚本内会 make xlang-x / bootstrap-driver-seed）
verify-selfhost-stage2:
	sh ./verify-selfhost-stage2.sh

# 可选：在 bootstrap-verify 之外单独跑 Stage2（不阻塞 PR 默认 CI）
bootstrap-verify-stage2: verify-selfhost-stage2
	@echo "bootstrap-verify-stage2 OK"

# M5：B-strict 二遍 build_xlang_asm（xlang_asm -> xlang_asm2），不依赖 xlang-x -x -E。
verify-selfhost-stage2-bstrict:
	sh ./verify-selfhost-stage2-bstrict.sh

bootstrap-verify-stage2-bstrict: verify-selfhost-stage2-bstrict
	@echo "bootstrap-verify-stage2-bstrict OK"

# B-hybrid：asm 构建（无 SKIP_GEN），成功则 xlang_asm 覆盖 $(TARGET)；失败保留 seed。
bootstrap-driver-hybrid bootstrap-driver-asm: $(TARGET)
	@XLANG=./$(TARGET) ./scripts/build_xlang_asm.sh
	@if [ -f xlang_asm ]; then cp -f xlang_asm $(TARGET) && echo "bootstrap-driver-hybrid OK: $(TARGET) from asm (B-hybrid)"; else echo "bootstrap-driver-hybrid: asm build skipped ($(TARGET) left as seed); run XLANG=./$(TARGET) ./scripts/build_xlang_asm.sh for details."; fi

# 仅 asm、不生成 C（B-hybrid 别名，保留历史目标名）
bootstrap-driver-asm-only: bootstrap-driver-hybrid

# M7 默认自举：B-strict（SKIP_GEN，链接审计无 cc -c pipeline_gen.c）；xlang_asm 默认覆盖 $(TARGET)。
# wave719: body → scripts/bootstrap_driver_bstrict.sh (G.7); prereq seed 仍 make 图。
# 仅保留 xlang_asm、不覆盖 seed：XLANG_BSTRICT_NO_REPLACE=1 make bootstrap-driver-bstrict
bootstrap-driver-bstrict: bootstrap-driver-seed
	@MAKE="$(MAKE)" TARGET="$(TARGET)" XLANG_BSTRICT_ENSURE_SEED=0 \
	  sh scripts/bootstrap_driver_bstrict.sh

# P0 asm 门禁：strict xlang_asm 与 seed+migrate-x-objs 对齐（M-3 含 typeck/codegen/ast）；xlang_asm2 仍保留 gen2。
# wave734: body → scripts/refresh_xlang_asm_gate.sh (G.7)
# wave735: migrate → scripts/migrate_x_objs.sh (no make migrate-x-objs inside refresh).
refresh-xlang-asm-gate:
	@MAKE="$(MAKE)" TARGET="$(TARGET)" \
	  XLANG_BSTRICT_NO_REPLACE="$(XLANG_BSTRICT_NO_REPLACE)" \
	  sh scripts/refresh_xlang_asm_gate.sh

# 日常快路径：仅 strict relink（前提 build_asm/*.o 已由 prior bootstrap 产出；改 glue/runtime/link 时用，~30s）。
# 等价：./scripts/relink_xlang_asm_bstrict_runtime_objs.sh（附带 bridge/Docker skip 环境）。
bootstrap-driver-bstrict-relink:
	@if [ ! -d build_asm ] || [ ! -f build_asm/pipeline.o ]; then \
	  echo "bootstrap-driver-bstrict-relink: need prior bootstrap (make bootstrap-driver-bstrict)" >&2; exit 1; fi
	@XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1 \
	 XLANG_ASM_SKIP_STRICT_SMOKE=1 \
	 XLANG_ASM_SKIP_MAIN_O_REBUILD=1 \
	 XLANG_ASM_SKIP_WPO_DOGFOOD=1 \
	 XLANG_ASM_SKIP_ENTRY_SMOKE=1 \
	 XLANG_ASM_BSTRICT_RELINK_ONLY=1 \
	 XLANG=./xlang_asm ./scripts/build_xlang_asm.sh
	@if [ ! -f xlang_asm ]; then echo "bootstrap-driver-bstrict-relink: xlang_asm relink failed" >&2; exit 1; fi
	@echo "bootstrap-driver-bstrict-relink OK (strict relink only; xlang_asm updated)"

# 日常/release 默认路径（M7）：等价 bootstrap-driver-bstrict；冷启动须先 bootstrap-driver-seed 或 make all。
bootstrap-driver: bootstrap-driver-bstrict

# E-06 v5 / C-03 v2：Windows MSYS2 B-strict（SKIP_GEN，禁 cc -c pipeline_gen.c）；验收 XLANG_WIN_BSTRICT=1 ./tests/run-bootstrap-bstrict-windows-gate.sh
bootstrap-driver-bstrict-windows: bootstrap-driver-bstrict
	@echo "bootstrap-driver-bstrict-windows OK (E-06 v5: SKIP_GEN B-strict; gate with XLANG_WIN_BSTRICT=1 on MSYS2)"

# M4 Linux：crt0 + full_asm .o 链（B-partial，无 runtime_driver）；与 bootstrap-driver-bstrict（asm_only_strict）分轨验收。
bootstrap-driver-crt0: bootstrap-driver-seed
	@XLANG=./$(TARGET) ./scripts/build_xlang_asm.sh 2>&1 | tee /tmp/build_xlang_crt0.log; \
	grep -qE 'Target-B-partial|LINK_MODE=crt0|no C runtime driver' /tmp/build_xlang_crt0.log || \
	(echo "bootstrap-driver-crt0: expected crt0 link in log" >&2; exit 1); \
	if grep -q 'cc -c pipeline_gen.c' /tmp/build_xlang_crt0.log; then \
	  echo "bootstrap-driver-crt0: crt0 path must not cc -c pipeline_gen.c" >&2; exit 1; fi; \
	test -f xlang_asm && echo "bootstrap-driver-crt0 OK (xlang_asm via crt0 + build_asm/*.o)"

# build-user-asm-backend：自 xlang 编 build_asm/*.o（完整 asm 自举）；seed 默认用 build-seed-asm-host（xlang-c -E）。
build-user-asm-backend:
	@./scripts/build_user_asm_backend.sh

# Goal 2（用 asm 后端构建 xlang）：构建最小 C 桩 + 可选执行 asm 自举脚本（需先 bootstrap-driver）
bootstrap-asm: $(TARGET) src/asm/runtime_asm_build.o src/runtime_driver.o
	@echo "bootstrap-asm: runtime_asm_build.o + runtime_driver.o ready."
	@echo " Full asm build: XLANG=./$(TARGET) ./scripts/build_xlang_asm.sh (requires bootstrap-driver first)"
bootstrap-asm-full: bootstrap-driver bootstrap-asm
	@XLANG=./$(TARGET) ./scripts/build_xlang_asm.sh

# Goal 2 辅助：检查 build_asm/*.o 的 __text 段是否非空（需先有 build_asm，例如刚跑过 build_xlang_asm.sh）。严格失败：XLANG_ASM_QUALITY_STRICT=1 make check-asm-o-quality
check-asm-o-quality: $(TARGET)
	@XLANG=./$(TARGET) ./scripts/check_asm_o_quality.sh

# 6.4 验收：宿主编译器能编译整机 .x（typeck+codegen+driver）并产出新 xlang，且新 xlang 能编译运行测试（return-value 返回 42 视为成功）。用 seed 构建 xlang 以保证通过（asm 路径修好后可改为 bootstrap-driver）。
# seed 的 .x 单文件路径把 C 写到 -o；须 $(CC) 链成可执行再运行（与 xlang-c 直接出 Mach-O/ELF 不同）。
check-6.4: $(TARGET)
	@$(MAKE) bootstrap-driver-seed && ./$(TARGET) ../tests/return-value/main.x -o /tmp/check64.c && $(CC) $(CFLAGS) -o /tmp/check64 /tmp/check64.c && /tmp/check64; [ $$? -eq 42 ] && echo "check-6.4 OK"

# 首次/从零构建：一条命令得到 xlang-c + build_tool（build-tool 仅依赖 xlang-c，与 lsp_gen 生成物无环）。与 README「读者一次做对」一致。
first-time: build-tool

# 阶段 7：build.x 驱动 build_tool（G-05：build_runner + build_runtime_x，无 build_runtime.inc）
# G-05（2026-07-10）：
# - 默认用 seeds/ 下 pinned *_gen.c（-x -E 对 build_runner.entry / 大 TU 仍不稳定；C 前端 -E-extern 已随 G-02a 不可用）
# - 可选：XLANG_BUILD_TOOL_REGEN=1 且 ./xlang 可 -x -E 时尝试刷新 build_gen + build_runtime_x_gen
# - build_run_asm_build 默认 `make xlang_asm`（与 relink 定稿一致）；FULL=1 → bootstrap-driver-bstrict
# - main 调用 entry（build_runner.x），非 build_entry
# wave718: body → scripts/build_tool.sh (G.7; xlang-build calls shell directly)
build-tool:
	@CC='$(CC)' CFLAGS='$(CFLAGS)' XLANG_BUILD_TOOL_REGEN="$${XLANG_BUILD_TOOL_REGEN:-0}" \
	  sh scripts/build_tool.sh

# wave831: FORCE dep-thin — shell owns seed mtime (cc_inc_tu; not physical delete).
# PLATFORM: SHARED — FORCE always invokes script (cheap mtime skip).
src/build_tool_main.o: FORCE scripts/cc_inc_tu.sh
	sh scripts/cc_inc_tu.sh seeds/build_tool_main.from_x.c $@

# 别名：与 build-tool 相同（历史 target 名）
build-tool-x: build-tool

# 运行 build_tool 产出 xlang（等价于 make bootstrap-driver，无需执行 Makefile bootstrap-driver 目标）
build-via-tool: build-tool
	./build_tool ./$(TARGET)
	@echo "build-via-tool OK（xlang 已由 build_tool 产出）"

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
# NOT physical delete — prereq bootstrap-driver-seed + thin edges + mk lists remain residual.
# PLATFORM: SHARED — shell owns stage2 link/smoke orchestration.
bootstrap-self: bootstrap-driver-seed scripts/bootstrap_self.sh
	@TARGET="$(TARGET)" CC="$(CC)" MAKE="$(MAKE)" \
	  bash scripts/bootstrap_self.sh

# 阶段 8.3 seed：两代 xlang（xlang_stage1/xlang_stage2）烟测；B-strict 主路径见 check-7.2-bstrict。
check-7.2: bootstrap-self
	@ROOT=$$(pwd)/..; CDIR=$$(pwd); \
	for ST in $(TARGET)_stage1 $(TARGET)_stage2; do \
	  cp "$$CDIR/$$ST" "$$CDIR/$(TARGET)" && \
	  cd "$$ROOT" && \
	  XLANG="$$CDIR/$$ST" ./tests/run-return-value.sh && \
	  XLANG="$$CDIR/$$ST" ./tests/run-hello.sh && \
	  XLANG="$$CDIR/$$ST" ./tests/run-lexer.sh && \
	  XLANG="$$CDIR/$$ST" ./tests/run-typeck.sh && \
	  XLANG="$$CDIR/$$ST" ./tests/run-bootstrap-semantic-smoke-vec-map-heap.sh && \
	  XLANG="$$CDIR/$$ST" ./tests/run-bootstrap-stage2-dogfood-parser-typeck.sh || \
	  (echo "check-7.2 FAIL: $$ST"; exit 1); \
	done && \
	echo "check-7.2 OK (both stages: return-value, hello, lexer, typeck, vec/map/heap + parser/typeck dogfood)"

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
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" XLANG_X="$(XLANG_X)" \
	  bash scripts/ensure_lsp_pipeline_gen.sh pipeline

# PLATFORM: SHARED — always-run ABI guard (make may skip pipeline_gen.c recipe when file exists).
# Stale workspace pipeline_gen.c with int32_t int_val is the P0-4 L4 failure mode on Ubuntu cold.
# §5b #1 wave725: body → scripts/check_pipeline_gen_expr_i64_abi.sh (G.7 single authority).
.PHONY: check-pipeline-gen-expr-i64-abi
check-pipeline-gen-expr-i64-abi:
	@chmod +x scripts/check_pipeline_gen_expr_i64_abi.sh 2>/dev/null || true
	@./scripts/check_pipeline_gen_expr_i64_abi.sh

# wave834: FORCE shell-primary — drop make-graph edge on pipeline_gen.c file.
# G.7 有则补全: body already ensure_lsp_pipeline_gen.sh pipeline (wave739); thin-call only.
# Shell always runs pin/seed/force -E + i64 ABI (make file-prereq skipped when pin exists).
# PLATFORM: SHARED — same ensure on Darwin/Linux/Windows MSYS2. NOT physical delete.
.PHONY: bootstrap-pipeline
bootstrap-pipeline: FORCE scripts/ensure_lsp_pipeline_gen.sh
	@MAKE="$(MAKE)" XLANG_FORCE_REGEN_GEN="$(XLANG_FORCE_REGEN_GEN)" \
	  XLANG_C="$(XLANG_C)" XLANG_X="$(XLANG_X)" \
	  bash scripts/ensure_lsp_pipeline_gen.sh pipeline
	@echo "bootstrap-pipeline OK"
# 仅重生成并编译 pipeline/driver/preprocess 三个 X 对象（供调试或 build_xlang_asm 对齐）
gen-x-driver-objs: pipeline_x.o driver_x.o preprocess_x.o
	@echo "gen-x-driver-objs OK (pipeline_x.o driver_x.o preprocess_x.o)"

# pipeline_gen.c 为真实文件目标；-E 时 runtime.c 在入口为 pipeline.x 时自动追加 pipeline_glue.c 到 stdout，无 Makefile 补丁

# 链接带 -x 流水线的 xlang（需 main_x.o 用 -DXLANG_USE_X_PIPELINE 编译，否则 -x -E 不生效）
# xlang-x-pipeline 链接了；lsp_diag_pipeline_sizes.o 提供 lsp_diag 与 pipeline 间结构体 sizeof；
# 提供 asm_driver_*（fmt/check/test 仅 bootstrap-driver-seed / xlang-x 全驱动链需要 DRIVER_SUBCMD_OBJS）
# wave845: full body → scripts/xlang_x_pipeline.sh (G.7 有则补全; shell owns multi-make
# ensure ladder + host-cc link). Lists stay mk expansion (pipeline_x_objs.mk).
# wave859: shell loads XXP_* via export-xxp-link-bags when unset (no multi-token
# XXP_* env export). NOT physical delete — prereq make-graph + thin edges + B2
# + mk lists remain residual.
# PLATFORM: SHARED — shell owns force-rebuild + link orchestration.
xlang-x-pipeline: bootstrap-pipeline migrate-x-objs $(PIPELINE_X_BASE_OBJS) pipeline_x.o $(PIPELINE_X_FRONTEND_OBJS) $(PIPELINE_X_SUPPORT_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes.o scripts/xlang_x_pipeline.sh
	@TARGET="$(TARGET)" CC="$(CC)" CFLAGS="$(CFLAGS)" MAKE="$(MAKE)" \
	  bash scripts/xlang_x_pipeline.sh

# 4.5（.x 流水线编译 compiler 自身）：用 xlang_x 的 -x -E 生成 typeck.x / codegen.x 对应的 C，再由 cc 链接得到新的 xlang_x_stage2。
# 这一目标的目的，是验证「完整前端（parse_into + typeck_x_ast + codegen_x_ast）」全部跑在 .x 上时，仍能产出能工作的编译器。
# wave785 B7c: typeck_x_x / codegen_x_x are *not* migrate_x_objs (different TU names; archaeology).
# wave842: full body → scripts/bootstrap_x_compiler.sh (G.7 有则补全; shell owns -x -E + host-cc -c + link).
# wave859: shell loads BXC_LINK_OBJS via export-bxc-link-objs when unset (no multi-token
# BXC_LINK_OBJS= env). NOT physical delete — prereq make-graph (xlang-x-pipeline)
# + thin edges + mk lists remain residual.
# PLATFORM: SHARED — shell owns stage2 emit/compile/link orchestration.
bootstrap-x-compiler: xlang-x-pipeline scripts/bootstrap_x_compiler.sh
	@TARGET="$(TARGET)" CC="$(CC)" CFLAGS="$(CFLAGS)" MAKE="$(MAKE)" \
	  bash scripts/bootstrap_x_compiler.sh

# 自举测试（不含 run-all）：seed 构建 xlang，再用 xlang 自编得到 xlang_stage2，stage2 跑 return-value 返回 42 即通过。用于快速验证「xlang 能编译自己」。
bootstrap-test: bootstrap-self
	@echo "Bootstrap tests OK (self-compilation: xlang1 -> xlang2)"

# M9：B-strict 语义自举主路径（xlang_asm→xlang_asm2 + lexer/typeck 烟测）。
# wave720: check-7.2-bstrict / bootstrap-verify body → scripts/bootstrap_verify_bstrict.sh
# Prereq bootstrap-driver-bstrict keeps cold graph on make path (ENSURE=0).
check-7.2-bstrict: bootstrap-driver-bstrict
	@MAKE="$(MAKE)" TARGET="$(TARGET)" XLANG_VERIFY_ENSURE_BSTRICT=0 \
	  sh scripts/bootstrap_verify_bstrict.sh

bootstrap-verify-bstrict: check-7.2-bstrict
	@true

bootstrap-verify-seed: check-7.2
	@echo "bootstrap-verify-seed OK (seed xlang -> xlang_stage2)"

# 7.3 默认：B-strict / xlang_asm 主路径；-x -E 全模块仍见 bootstrap-verify-seed + verify-selfhost-stage2。
bootstrap-verify: bootstrap-verify-bstrict
	@true

# clangd：生成 compile_commands.json + ide/pipeline_glue_types.inc（IDE 误报 glue 池时运行）
compile_commands.json:
	./scripts/gen_compile_commands.sh

# 阶段 8 体积基线：编译固定用例并输出可执行文件大小
size-baseline:
	@if [ -f ../tests/run-size-baseline.sh ]; then (cd .. && chmod +x tests/run-size-baseline.sh && XLANG=./compiler/xlang-c ./tests/run-size-baseline.sh); fi

# 阶段 8 性能基线：编译并多次运行 perf-baseline，输出耗时
perf-baseline:
	@if [ -f ../tests/run-perf-baseline.sh ]; then (cd .. && chmod +x tests/run-perf-baseline.sh && XLANG=./compiler/xlang-c ./tests/run-perf-baseline.sh); fi

# core.slice：语言限制 C 桩（G-01 core 零 C；G-02e-17：.inc + cc_inc_tu）。
# G-02f-22：runtime_slice_glue 产品 seed
# G-02f-29 (wave530)：R2 DIRECT mode — pure-compute module (6 functions: slice
#   from_ptr/subslice for i32/u8/u64, no OS bridge), .x compiles standalone
#   via xlang-c -lib-name "" without thin+rest ld -r. Seed .from_x.c guarded
#   by XLANG_RUNTIME_SLICE_GLUE_FROM_X for cold path fallback only.
# PLATFORM: SHARED slice — pure compute, no OS dependency.
# wave780 B2: dual hybrid → ensure try-std-core-prefer (G.7; not physical delete).
../core/slice/slice.o: FORCE scripts/ensure_host_cc_seed_o.sh
# wave794 B7A: heat dep-edge thin pure seed+.x leftover — prereqs → FORCE + ensure;
# try-heat owns seed/.x mtime (try-std-core-prefer).
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  XLANG_G05_PREFER_X_O="$(XLANG_G05_PREFER_X_O)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@

# G-02f-22：runtime_asm_build 产品 seed
# wave754 R1: pure host-cc body → ensure_host_cc_seed_o.sh (list = R1_MISC_BASENAME_OBJS).
# wave792 B7A: heat dep-edge thin pure seed+.x residual — prereqs → FORCE + ensure;
# shell owns seed/.x freshness (try-heat). NOT physical delete.
# PLATFORM: SHARED — FORCE always invokes try-heat (cheap mtime skip).
src/asm/runtime_asm_build.o: FORCE scripts/ensure_host_cc_seed_o.sh
	@CC="$(CC)" CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)" \
	  bash scripts/ensure_host_cc_seed_o.sh try-heat $@
