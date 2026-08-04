#!/usr/bin/env bash
# clean_compiler.sh — wipe compiler intermediate artifacts (11.0.3 · wave718)
#
# Authority (G.7):
#   Single implementation of `make clean` under compiler/. Makefile `clean`
#   and xlang-build.sh clean call this script only — no second clean recipe.
#
# Semantics (match historical Makefile clean, cwd = compiler/):
#   - remove product binaries, gen leftovers, build_tool, build_* dirs
#   - remove listed ../std/*.o (find under compiler/ does not cover them)
#   - find . -name '*.o' under compiler/ (covers former $(OBJS) expansion)
#
# Usage:
#   ./scripts/clean_compiler.sh
#   (from repo root)  ./compiler/scripts/clean_compiler.sh
#
# Env:
#   TARGET  — product name (default: xlang)
#   XLANG_C — seed compiler name (default: xlang-c)
#
# PLATFORM: SHARED
# Wave: 718 Track MG

set -euo pipefail
cd "$(dirname "$0")/.."

TARGET="${TARGET:-xlang}"
XLANG_C="${XLANG_C:-xlang-c}"

# Explicit list mirrors Makefile clean (std paths + binaries + gen). find
# below covers the rest of compiler/**/*.o so we do not re-list OBJS_CORE.
rm -f \
  src/main.o src/runtime.o src/diag.o \
  src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o \
  src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o \
  src/runtime_c_import.o src/runtime_driver_strict_glue_stubs.o \
  src/lexer/cfg_eval_bootstrap_stub.o src/driver/fmt_check_cmd.o \
  src/async/async_liveness.o src/async/async_cps_codegen.o \
  src/lsp/lsp_diag_pipeline_sizes.o src/lsp/lsp_diag_stubs_no_c.o \
  src/main_driver.o src/runtime_driver.o src/runtime_driver_no_c.o \
  src/runtime_x.o src/main_x.o src/ast/ast_seed.o src/preprocess_for_driver.o \
  ../std/process/process.o ../std/string/string.o ../std/runtime/runtime.o \
  ../std/net/net.o ../std/thread/thread.o ../std/time/time.o \
  ../std/random/random.o ../std/env/env.o ../std/sync/sync.o \
  ../std/encoding/encoding.o ../std/base64/base64.o ../std/crypto/crypto.o \
  ../std/log/log.o ../std/atomic/atomic.o ../std/channel/channel.o \
  ../std/backtrace/backtrace.o ../std/hash/hash.o ../std/math/math.o \
  ../std/sort/sort.o ../std/ffi/ffi.o ../std/json/json.o ../std/csv/csv.o \
  ../std/regex/regex.o ../std/compress/compress.o ../std/unicode/unicode.o \
  ../std/dynlib/dynlib.o ../std/http/http.o ../std/tar/tar.o ../std/test/test.o \
  src/asm/runtime_asm_build.o src/asm/crt0_x86_64.o src/typeck/typeck_f64_bits.o \
  src/lsp/lsp_diag_pipeline_sizes.o \
  lsp_io_x.o lsp_x.o lsp_diag_x.o lsp_io_std_heap_x.o \
  lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c \
  "${TARGET}" xlang-x xlang-no-c-frontend "${XLANG_C}" \
  "${TARGET}_stage1" "${TARGET}_stage2" "${TARGET}_x" "${TARGET}_x_stage2" \
  typeck_gen.c typeck_x.o codegen_gen.c codegen_x.o parser_gen.c parser_x.o \
  driver_gen.c driver_x.o driver_fmt_gen.c driver_check_gen.c driver_test_gen.c \
  driver_fmt_x.o driver_check_x.o driver_test_x.o pipeline_gen.c pipeline_x.o \
  typeck_x_x.c typeck_x_x.o codegen_x_x.c codegen_x_x.o \
  build_gen.c build_runner_gen.c build_runtime_x_gen.c \
  build_tool.o build_runner.o build_runtime.o build_runtime_x.o build_tool \
  runtime_panic.o xlang_asm preprocess_gen.c preprocess_x.o \
  build_tool_main.o build_tool_libc_bridge.o

rm -rf build_asm build build_final build_manual build_v5 build_v7
rm -f bootstrap_xlang xlang_asm2 xlang_x_dbg xlang_stage1_test a.out
rm -f .lldb_* *.bak pipeline_gen.c.bak lsp_gen.c.bak
rm -f 0 2>/dev/null || true

for f in _*; do
  case "$f" in
    _stubs.c|_x_stubs.inc|_x_stubs2.c) ;;
    *) rm -rf "$f" ;;
  esac
done 2>/dev/null || true

find . -name '*.o' -delete 2>/dev/null || true
find . -name '*.o.tmp' -delete 2>/dev/null || true
rm -f test_perl.txt test_pre_out.s 2>/dev/null || true
rm -f ../rvwbuf.tmp 2>/dev/null || true
find . -name '*.x.bak' -delete 2>/dev/null || true
rm -rf tmp_bisect 2>/dev/null || true
rm -f tmp_* 2>/dev/null || true

echo "clean_compiler: OK (compiler/ + listed std .o)"
