#!/usr/bin/env bash
# E-04 v1～v4：runtime 路径审计 + runtime_*_abi 薄壳门禁。
#
# 用法：./tests/run-e04-runtime-soft-gate.sh
# 环境：
#   SHUX_E04_FAIL=1              — 失败时硬退出
#   SHUX_E04_MANIFEST_ONLY=1     — 仅 manifest
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_E04_FAIL:-0}
DOC="analysis/phase-e-e04-v35.md"
DOC_V34="analysis/phase-e-e04-v34.md"
DOC_V33="analysis/phase-e-e04-v33.md"
DOC_V32="analysis/phase-e-e04-v32.md"
DOC_V31="analysis/phase-e-e04-v31.md"
DOC_V30="analysis/phase-e-e04-v30.md"
DOC_V29="analysis/phase-e-e04-v29.md"
DOC_V28="analysis/phase-e-e04-v28.md"
DOC_V27="analysis/phase-e-e04-v27.md"
DOC_V26="analysis/phase-e-e04-v26.md"
DOC_V25="analysis/phase-e-e04-v25.md"
DOC_V24="analysis/phase-e-e04-v24.md"
DOC_V23="analysis/phase-e-e04-v23.md"
DOC_V22="analysis/phase-e-e04-v22.md"
DOC_V21="analysis/phase-e-e04-v21.md"
DOC_V20="analysis/phase-e-e04-v20.md"
DOC_V19="analysis/phase-e-e04-v19.md"
DOC_V18="analysis/phase-e-e04-v18.md"
DOC_V17="analysis/phase-e-e04-v17.md"
DOC_V16="analysis/phase-e-e04-v16.md"
DOC_V15="analysis/phase-e-e04-v15.md"
DOC_V14="analysis/phase-e-e04-v14.md"
DOC_V13="analysis/phase-e-e04-v13.md"
DOC_V12="analysis/phase-e-e04-v12.md"
DOC_V11="analysis/phase-e-e04-v11.md"
DOC_V10="analysis/phase-e-e04-v10.md"
DOC_V9="analysis/phase-e-e04-v9.md"
DOC_V8="analysis/phase-e-e04-v8.md"
DOC_V7="analysis/phase-e-e04-v7.md"
DOC_V6="analysis/phase-e-e04-v6.md"
DOC_V5="analysis/phase-e-e04-v5.md"
DOC_V4="analysis/phase-e-e04-v4.md"
DOC_V3="analysis/phase-e-e04-v3.md"
DOC_V2="analysis/phase-e-e04-v2.md"
DOC_V1="analysis/phase-e-e04-v1.md"
MF="compiler/Makefile"
ABI_MF="tests/baseline/e04-runtime-abi.tsv"
BUILD="compiler/scripts/build_shux_asm.sh"
RUNTIME="compiler/src/runtime.c"
MAIN="compiler/src/main.c"
ABI_C="compiler/src/runtime_abi.c"
IO_ABI_C="compiler/src/runtime_io_abi.c"
PROC_ABI_C="compiler/src/runtime_proc_abi.c"
LINK_ABI_C="compiler/src/runtime_link_abi.c"
LINK_ABI_H="compiler/src/runtime_link_abi.h"
DRIVER_ABI_C="compiler/src/runtime_driver_abi.c"
DRIVER_ABI_H="compiler/src/runtime_driver_abi.h"
PIPELINE_ABI_C="compiler/src/runtime_pipeline_abi.c"
PIPELINE_ABI_H="compiler/src/runtime_pipeline_abi.h"
CRT0_LINUX="compiler/src/asm/crt0_x86_64.s"
CRT0_DARWIN_ARM="compiler/src/asm/crt0_arm64.s"
CRT0_DARWIN_X64="compiler/src/asm/crt0_darwin_x86_64.s"
CRT0_MINGW="compiler/src/asm/crt0_mingw.inc"

die() {
  echo "e04 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== E-04 v35: dep transitive collect/merge in pipeline_abi ==="
for f in "$DOC" "$DOC_V34" "$DOC_V33" "$DOC_V32" "$DOC_V31" "$DOC_V30" "$DOC_V29" "$DOC_V28" "$DOC_V27" "$DOC_V26" "$DOC_V25" "$DOC_V24" "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  compiler/src/runtime_driver_diagnostic.c compiler/src/runtime_driver_diagnostic.h \
  compiler/src/runtime_c_import.inc compiler/src/runtime_c_import.h \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v35' "$DOC" || die "doc missing E-04 v35 marker"
grep -q 'shux_collect_deps_transitive' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_collect_deps_transitive"
grep -q 'shux_merge_direct_then_transitive_deps' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_merge_direct_then_transitive_deps"
grep -q 'shux_load_direct_imports_for_asm_layout' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_load_direct_imports_for_asm_layout"
grep -q 'shux_collect_deps_transitive' "$PIPELINE_ABI_H" || die "runtime_pipeline_abi.h missing shux_collect_deps_transitive"
if grep -qE '^static int collect_deps_transitive\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines collect_deps_transitive"
fi
if grep -qE '^static int merge_direct_then_transitive_deps\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines merge_direct_then_transitive_deps"
fi
if grep -qE '^static int load_direct_imports_for_asm_layout\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines load_direct_imports_for_asm_layout"
fi
grep -q 'shux_collect_deps_transitive' "$RUNTIME" || die "runtime.c should call shux_collect_deps_transitive"

echo "=== E-04 v34: driver diagnostic block in runtime_driver_diagnostic TU ==="
for f in "$DOC_V34" "$DOC_V33" "$DOC_V32" "$DOC_V31" "$DOC_V30" "$DOC_V29" "$DOC_V28" "$DOC_V27" "$DOC_V26" "$DOC_V25" "$DOC_V24" "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  compiler/src/runtime_driver_diagnostic.c compiler/src/runtime_driver_diagnostic.h \
  compiler/src/runtime_c_import.inc compiler/src/runtime_c_import.h \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v34' "$DOC_V34" || die "doc missing E-04 v34 marker"
grep -q 'driver_diagnostic_parse_fail' compiler/src/runtime_driver_diagnostic.c || die "runtime_driver_diagnostic.c missing driver_diagnostic_parse_fail"
grep -q 'driver_diagnostic_hint_unused_binding' compiler/src/runtime_driver_diagnostic.c || die "runtime_driver_diagnostic.c missing driver_diagnostic_hint_unused_binding"
grep -q 'runtime_driver_diagnostic.o' "$MF" || die "Makefile OBJS_CORE missing runtime_driver_diagnostic.o"
grep -q 'runtime_driver_diagnostic.o' "$MF" && grep -q 'DRIVER_SEED_OBJS' "$MF" && grep -q 'runtime_driver_diagnostic.o' "$MF" || die "Makefile DRIVER_SEED_OBJS missing runtime_driver_diagnostic.o"
if grep -qE '^void driver_diagnostic_parse_fail\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_diagnostic_parse_fail"
fi
if grep -qE '^void driver_diagnostic_hint_unused_binding\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_diagnostic_hint_unused_binding"
fi
grep -q 'runtime_driver_diagnostic.c' "$RUNTIME" || die "runtime.c should reference runtime_driver_diagnostic.c"

echo "=== E-04 v33: C import load TU + top-level import detect in driver/pipeline ABI ==="
for f in "$DOC_V33" "$DOC_V32" "$DOC_V31" "$DOC_V30" "$DOC_V29" "$DOC_V28" "$DOC_V27" "$DOC_V26" "$DOC_V25" "$DOC_V24" "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  compiler/src/runtime_c_import.inc compiler/src/runtime_c_import.h \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v33' "$DOC_V33" || die "doc missing E-04 v33 marker"
grep -q 'shu_c_resolve_and_load_imports' compiler/src/runtime_c_import.inc || die "runtime_c_import.inc missing shu_c_resolve_and_load_imports"
grep -q 'shu_lsp_resolve_and_load_imports' compiler/src/runtime_c_import.inc || die "runtime_c_import.inc missing shu_lsp_resolve_and_load_imports"
grep -q 'runtime_c_import.o' "$MF" || die "Makefile OBJS_CORE missing runtime_c_import.o"
grep -q 'driver_source_has_top_level_import_path' "$DRIVER_ABI_C" || die "runtime_driver_abi.c missing driver_source_has_top_level_import_path"
grep -q 'shux_merge_deps_path_already_out' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_merge_deps_path_already_out"
if grep -qE '^static ASTModule \*load_one_import\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines load_one_import"
fi
if grep -qE '^static int resolve_and_load_imports\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines resolve_and_load_imports"
fi
if grep -qE '^int shu_lsp_resolve_and_load_imports\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines shu_lsp_resolve_and_load_imports"
fi
if grep -qE '^int driver_source_has_top_level_import_path\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_source_has_top_level_import_path"
fi
grep -q 'shu_c_resolve_and_load_imports' "$RUNTIME" || die "runtime.c should call shu_c_resolve_and_load_imports"

echo "=== E-04 v32: shux_preprocess in pipeline_abi (runtime SHUX_RUNTIME_PREPROCESS macro) ==="
for f in "$DOC_V32" "$DOC_V31" "$DOC_V30" "$DOC_V29" "$DOC_V28" "$DOC_V27" "$DOC_V26" "$DOC_V25" "$DOC_V24" "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v32' "$DOC_V32" || die "doc missing E-04 v32 marker"
grep -q 'shux_preprocess' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_preprocess"
grep -q 'shux_preprocess' "$PIPELINE_ABI_H" || die "runtime_pipeline_abi.h missing shux_preprocess"
grep -q 'RUNTIME_PIPELINE_ABI_CFLAGS' "$MF" || die "Makefile missing RUNTIME_PIPELINE_ABI_CFLAGS"
grep -q 'SHUX_RUNTIME_PREPROCESS' "$RUNTIME" || die "runtime.c missing SHUX_RUNTIME_PREPROCESS macro"
if grep -qE '^char \*preprocess\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines preprocess()"
fi
if grep -qE '^static char \*preprocess_via_x\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines preprocess_via_x"
fi
grep -q 'SHUX_RUNTIME_PREPROCESS' "$RUNTIME" || die "runtime.c should use SHUX_RUNTIME_PREPROCESS for preprocess calls"

echo "=== E-04 v31: asm ELF large-stack + LSP import free in pipeline_abi ==="
for f in "$DOC_V31" "$DOC_V30" "$DOC_V29" "$DOC_V28" "$DOC_V27" "$DOC_V26" "$DOC_V25" "$DOC_V24" "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v31' "$DOC_V31" || die "doc missing E-04 v31 marker"
grep -q 'shux_import_dep_dir_from_path' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_import_dep_dir_from_path"
grep -q 'shux_driver_asm_prepare_entry_elf_emit' "$PIPELINE_ABI_H" || die "runtime_pipeline_abi.h missing shux_driver_asm_prepare_entry_elf_emit"
grep -q 'shux_asm_codegen_elf_o_large_stack' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_asm_codegen_elf_o_large_stack"
grep -q 'pipeline_typeck_module_for_ctx' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing pipeline_typeck_module_for_ctx"
grep -q 'shu_lsp_free_loaded_imports' "$PIPELINE_ABI_H" || die "runtime_pipeline_abi.h missing shu_lsp_free_loaded_imports"
if grep -qE '^static void driver_asm_prepare_entry_elf_emit\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_asm_prepare_entry_elf_emit"
fi
if grep -qE '^static int32_t asm_asm_codegen_elf_o_large_stack\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines asm_asm_codegen_elf_o_large_stack"
fi
if grep -qE '^int32_t pipeline_typeck_module_for_ctx\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines pipeline_typeck_module_for_ctx"
fi
if grep -qE '^void shu_lsp_free_loaded_imports\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines shu_lsp_free_loaded_imports"
fi
grep -q 'shux_asm_codegen_elf_o_large_stack' "$RUNTIME" || die "runtime.c should call shux_asm_codegen_elf_o_large_stack"
grep -q 'shux_import_dep_dir_from_path' compiler/src/runtime_c_import.inc || die "runtime_c_import.inc should call shux_import_dep_dir_from_path"

echo "=== E-04 v30: pipeline I/O primitives + dep prerun in pipeline_abi ==="
for f in "$DOC_V30" "$DOC_V29" "$DOC_V28" "$DOC_V27" "$DOC_V26" "$DOC_V25" "$DOC_V24" "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v30' "$DOC_V30" || die "doc missing E-04 v30 marker"
grep -q 'pipeline_set_entry_dir' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing pipeline_set_entry_dir"
grep -q 'pipeline_read_file' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing pipeline_read_file"
grep -q 'shux_pipeline_run_x_pipeline_large_stack' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_pipeline_run_x_pipeline_large_stack"
grep -q 'shux_pipeline_dep_prerun_parse_only' "$PIPELINE_ABI_H" || die "runtime_pipeline_abi.h missing shux_pipeline_dep_prerun_parse_only"
if grep -qE '^void pipeline_set_entry_dir\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines pipeline_set_entry_dir"
fi
if grep -qE '^static int pipeline_run_x_pipeline_large_stack\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines pipeline_run_x_pipeline_large_stack"
fi
grep -q 'shux_pipeline_run_x_pipeline_large_stack' "$RUNTIME" || die "runtime.c should call shux_pipeline_run_x_pipeline_large_stack"

echo "=== E-04 v29: stack bump + large-stack pthread + preprocess/typeck dep in ABI ==="
for f in "$DOC_V29" "$DOC_V28" "$DOC_V27" "$DOC_V26" "$DOC_V25" "$DOC_V24" "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v29' "$DOC_V29" || die "doc missing E-04 v29 marker"
grep -q 'driver_bump_stack_limit' "$DRIVER_ABI_C" || die "runtime_driver_abi.c missing driver_bump_stack_limit"
grep -q 'driver_run_thread_on_large_stack' "$DRIVER_ABI_H" || die "runtime_driver_abi.h missing driver_run_thread_on_large_stack"
grep -q 'shux_preprocess_raw_to_malloc' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_preprocess_raw_to_malloc"
grep -q 'typeck_ndep' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing typeck_ndep"
grep -q 'driver_typeck_dep_sidecar_clear' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing driver_typeck_dep_sidecar_clear"
if grep -qE '^void driver_bump_stack_limit\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_bump_stack_limit"
fi
if grep -qE '^void driver_run_on_large_stack_pthread\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_run_on_large_stack_pthread"
fi
if grep -qE '^static int su_preprocess_raw_to_malloc\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines su_preprocess_raw_to_malloc"
fi
if grep -qE '^void driver_typeck_dep_sidecar_clear\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_typeck_dep_sidecar_clear"
fi
grep -q 'shux_preprocess_raw_to_malloc' "$RUNTIME" || die "runtime.c should call shux_preprocess_raw_to_malloc"

echo "=== E-04 v28: PipelineDepCtx helpers + pipeline diagnostics in ABI ==="
for f in "$DOC_V28" "$DOC_V27" "$DOC_V26" "$DOC_V25" "$DOC_V24" "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v28' "$DOC_V28" || die "doc missing E-04 v28 marker"
grep -q 'shux_pipeline_fill_ctx_path_buffers' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_pipeline_fill_ctx_path_buffers"
grep -q 'shux_pipeline_pctx_seed_dep_slots' "$PIPELINE_ABI_H" || die "runtime_pipeline_abi.h missing shux_pipeline_pctx_seed_dep_slots"
grep -q 'shux_asm_user_std_dep_skip_x_typeck' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_asm_user_std_dep_skip_x_typeck"
grep -q 'driver_pipeline_fail_code' "$DRIVER_ABI_C" || die "runtime_driver_abi.c missing driver_pipeline_fail_code"
grep -q 'driver_print_x_smoke_summary' "$DRIVER_ABI_H" || die "runtime_driver_abi.h missing driver_print_x_smoke_summary"
grep -q 'driver_peek_source_file' "$DRIVER_ABI_C" || die "runtime_driver_abi.c missing driver_peek_source_file"
if grep -qE '^static void pipeline_fill_ctx_path_buffers\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines pipeline_fill_ctx_path_buffers"
fi
if grep -qE '^void driver_pipeline_fail_code\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_pipeline_fail_code"
fi
grep -q 'shux_pipeline_fill_ctx_path_buffers' "$RUNTIME" || die "runtime.c should call shux_pipeline_fill_ctx_path_buffers"

echo "=== E-04 v27: import/load helpers + argv defines in pipeline/driver ABI ==="
for f in "$DOC_V27" "$DOC_V26" "$DOC_V25" "$DOC_V24" "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v27' "$DOC_V27" || die "doc missing E-04 v27 marker"
grep -q 'shux_find_loaded_import_index' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_find_loaded_import_index"
grep -q 'shux_dep_prerun_entry_dir' "$PIPELINE_ABI_H" || die "runtime_pipeline_abi.h missing shux_dep_prerun_entry_dir"
grep -q 'shux_asm_out_buf_is_object' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_asm_out_buf_is_object"
grep -q 'driver_argv_collect_defines' "$DRIVER_ABI_C" || die "runtime_driver_abi.c missing driver_argv_collect_defines"
if grep -qE '^static int find_loaded_index\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines find_loaded_index"
fi
if grep -qE '^static int driver_argv_collect_defines\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_argv_collect_defines"
fi
if grep -qE '^static void driver_asm_fclose_asm_out\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_asm_fclose_asm_out"
fi
grep -q 'shux_find_loaded_import_index' "$RUNTIME" || die "runtime.c should call shux_find_loaded_import_index"

echo "=== E-04 v26: driver_dep_* slots in runtime_pipeline_abi ==="
for f in "$DOC_V26" "$DOC_V25" "$DOC_V24" "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v26' "$DOC_V26" || die "doc missing E-04 v26 marker"
grep -q 'driver_dep_publish_slot' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing driver_dep_publish_slot"
grep -q 'driver_dep_arena_buf' "$PIPELINE_ABI_H" || die "runtime_pipeline_abi.h missing driver_dep_arena_buf"
grep -q 'SHUX_DRIVER_DEP_SLOT_MAX' "$PIPELINE_ABI_H" || die "runtime_pipeline_abi.h missing SHUX_DRIVER_DEP_SLOT_MAX"
grep -q 'driver_dep_seeded_clear_all' "$RUNTIME" || die "runtime.c should call driver_dep_seeded_clear_all"
if grep -qE '^void driver_dep_publish_slot\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_dep_publish_slot"
fi
if grep -qE '^uint8_t \*driver_dep_arena_buf\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_dep_arena_buf"
fi
grep -q 'driver_dep_seeded_clear_all' "$RUNTIME" || die "runtime.c should still call driver_dep_seeded_clear_all"

echo "=== E-04 v25: pipeline/asm flags + phase timing in runtime_driver_abi ==="
for f in "$DOC_V25" "$DOC_V24" "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v25' "$DOC_V25" || die "doc missing E-04 v25 marker"
grep -q 'driver_asm_build_skip_typeck' "$DRIVER_ABI_C" || die "runtime_driver_abi.c missing driver_asm_build_skip_typeck"
grep -q 'driver_compile_phase_timing_begin' "$DRIVER_ABI_C" || die "runtime_driver_abi.c missing driver_compile_phase_timing_begin"
grep -q 'driver_set_pipeline_entry_source_len' "$DRIVER_ABI_H" || die "runtime_driver_abi.h missing driver_set_pipeline_entry_source_len"
if grep -qE '^int32_t driver_asm_build_skip_typeck\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_asm_build_skip_typeck"
fi
if grep -qE '^void driver_compile_phase_timing_begin\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_compile_phase_timing_begin"
fi
if grep -qE '^int32_t driver_asm_entry_module_only_from_env\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_asm_entry_module_only_from_env"
fi
grep -q 'driver_asm_build_skip_typeck' "$RUNTIME" || die "runtime.c should still call driver_asm_build_skip_typeck"
grep -q 'driver_set_pipeline_entry_source_len' "$RUNTIME" || die "runtime.c should call driver_set_pipeline_entry_source_len"

echo "=== E-04 v24: import path resolve in runtime_pipeline_abi ==="
for f in "$DOC_V24" "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v24' "$DOC_V24" || die "doc missing E-04 v24 marker"
grep -q 'runtime_pipeline_abi.o' "$MF" || die "Makefile missing runtime_pipeline_abi.o in OBJS_CORE/seed"
grep -q 'shux_resolve_import_file_path_multi' "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.c missing shux_resolve_import_file_path_multi"
grep -q 'shux_get_entry_dir' "$PIPELINE_ABI_H" || die "runtime_pipeline_abi.h missing shux_get_entry_dir"
grep -q 'runtime_pipeline_abi.h' "$RUNTIME" || die "runtime.c must include runtime_pipeline_abi.h"
if grep -qE '^static void resolve_import_file_path_multi\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines resolve_import_file_path_multi"
fi
if grep -qE '^static void import_path_to_file_path\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines import_path_to_file_path"
fi
if grep -qE '^static void get_entry_dir\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines get_entry_dir"
fi
grep -q 'shux_resolve_import_file_path_multi' "$RUNTIME" || die "runtime.c should call shux_resolve_import_file_path_multi"
grep -q 'shux_get_entry_dir' "$RUNTIME" || die "runtime.c should call shux_get_entry_dir"
grep -q 'ensure_runtime_pipeline_abi_obj' "$BUILD" || die "build_shux_asm.sh missing ensure_runtime_pipeline_abi_obj"

echo "=== E-04 v23: invoke_ld + -o suffix in runtime_link_abi ==="
for f in "$DOC_V23" "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v23' "$DOC_V23" || die "doc missing E-04 v23 marker"
grep -q 'shux_invoke_ld_for_exe' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_invoke_ld_for_exe"
grep -q 'shux_output_want_exe' "$LINK_ABI_H" || die "runtime_link_abi.h missing shux_output_want_exe"
grep -q 'shux_output_is_elf_o' "$LINK_ABI_H" || die "runtime_link_abi.h missing shux_output_is_elf_o"
grep -q 'runtime_driver_abi.h' "$LINK_ABI_C" || die "runtime_link_abi.c must include runtime_driver_abi.h for freestanding"
if grep -qE '^static int invoke_ld\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines invoke_ld"
fi
if grep -qE '^static int driver_asm_invoke_ld\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_asm_invoke_ld"
fi
if grep -qE '^static int output_want_exe\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines output_want_exe"
fi
if grep -qE '^static int driver_asm_output_want_exe_cstr\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_asm_output_want_exe_cstr"
fi
grep -q 'shux_invoke_ld_for_exe' "$RUNTIME" || die "runtime.c should call shux_invoke_ld_for_exe"
grep -q 'shux_output_want_exe' "$RUNTIME" || die "runtime.c should call shux_output_want_exe"

echo "=== E-04 v22: driver flags in runtime_driver_abi ==="
for f in "$DOC_V22" "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v22' "$DOC_V22" || die "doc missing E-04 v22 marker"
grep -q 'runtime_driver_abi.o' "$MF" || die "Makefile missing runtime_driver_abi.o in seed link"
grep -q 'driver_check_only_get' "$DRIVER_ABI_C" || die "runtime_driver_abi.c missing driver_check_only_get"
if grep -qE '^void driver_check_only_set\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_check_only_set"
fi
if grep -qE '^int32_t driver_freestanding_get\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines driver_freestanding_get"
fi
grep -q 'driver_print_check_ok' "$RUNTIME" || die "runtime.c should still call driver_print_check_ok"

echo "=== E-04 v21: MinGW/Windows crt0_mingw ==="
for f in "$DOC_V21" "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v21' "$DOC_V21" || die "doc missing E-04 v21 marker"
grep -q 'crt0_mingw.o' "$MF" || die "Makefile missing crt0_mingw.o in MAIN_LINK_O path"
grep -q 'SHUX_IS_WIN_HOST' "$MF" || die "Makefile missing SHUX_IS_WIN_HOST"
grep -q 'shux_forward_main_to_main_entry' "$CRT0_MINGW" || die "crt0_mingw.inc must call shux_forward_main_to_main_entry"

echo "=== E-04 v20: Darwin crt0 + MAIN_LINK_FLAGS ==="
for f in "$DOC_V20" "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v20' "$DOC_V20" || die "doc missing E-04 v20 marker"
grep -q 'crt0_arm64.o' "$MF" || die "Makefile missing crt0_arm64.o in MAIN_LINK_O path"
grep -q 'crt0_darwin_x86_64.o' "$MF" || die "Makefile missing crt0_darwin_x86_64.o"
grep -q 'MAIN_LINK_FLAGS' "$MF" || die "Makefile missing MAIN_LINK_FLAGS"
grep -q 'nostartfiles' "$MF" || die "Makefile missing Darwin nostartfiles link flags"
grep -q '_main_entry' "$CRT0_DARWIN_ARM" || die "crt0_arm64.s must call _main_entry"
grep -q '_main_entry' "$CRT0_DARWIN_X64" || die "crt0_darwin_x86_64.s must call _main_entry"

echo "=== E-04 v19: Linux MAIN_LINK_O=crt0; crt0 calls main_entry ==="
for f in "$DOC_V19" "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" "$CRT0_LINUX" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v19' "$DOC_V19" || die "doc missing E-04 v19 marker"
grep -q 'MAIN_LINK_O' "$MF" || die "Makefile missing MAIN_LINK_O"
grep -q 'SHUX_LEGACY_MAIN_C' "$MF" || die "Makefile missing SHUX_LEGACY_MAIN_C"
grep -q 'crt0_x86_64.o' "$MF" || die "Makefile missing crt0_x86_64.o in MAIN_LINK_O path"
grep -q 'call[[:space:]]*main_entry' "$CRT0_LINUX" || die "crt0_x86_64.s must call main_entry"
grep -q '$(MAIN_LINK_O)' "$MF" || die "DRIVER_SEED_OBJS should use \$(MAIN_LINK_O)"
if grep -qE '^[[:space:]]*call[[:space:]]*entry[[:space:]]*$' "$CRT0_LINUX" 2>/dev/null; then
  die "crt0_x86_64.s still calls bare entry"
fi

echo "=== E-04 v18: main() forward in runtime_abi ==="
for f in "$DOC_V18" "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v18' "$DOC_V18" || die "doc missing E-04 v18 marker"
grep -q 'shux_forward_main_to_main_entry' "$ABI_C" || die "runtime_abi.c missing shux_forward_main_to_main_entry"
grep -q 'shux_forward_main_to_main_entry' "$MAIN" || die "main.c should call shux_forward_main_to_main_entry"
if grep -qE 'extern int main_entry' "$MAIN" 2>/dev/null; then
  die "main.c should not extern main_entry (use runtime_abi forward)"
fi

echo "=== E-04 v17: invoke_cc in runtime_link_abi ==="
for f in "$DOC_V17" "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v17' "$DOC_V17" || die "doc missing E-04 v17 marker"
grep -q 'shux_invoke_cc' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_invoke_cc"
grep -q 'shux_generated_c_needs_async_scheduler' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_generated_c_needs_async_scheduler"
grep -q 'SHUX_INVOKE_CC_MAX_C_FILES' "$LINK_ABI_H" || die "runtime_link_abi.h missing SHUX_INVOKE_CC_MAX_C_FILES"
if grep -qE '^static int invoke_cc\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines invoke_cc"
fi
grep -q 'shux_invoke_cc(' "$RUNTIME" || die "runtime.c should call shux_invoke_cc"

echo "=== E-04 v16: retire get_std_*_o_path; invoke_cc uses shux_rel_o_path_from_argv0 ==="
for f in "$DOC_V16" "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v16' "$DOC_V16" || die "doc missing E-04 v16 marker"
if grep -qE '^static const char \*get_std_[a-z_]+_o_path\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines get_std_*_o_path"
fi
for legacy in 'std/fs/fs.o' 'std/heap/heap.o' 'std/compress/compress.o'; do
  if grep -q "shux_rel_o_path_from_argv0(argv\[0\], \"$legacy\")" "$RUNTIME" 2>/dev/null; then
    die "runtime.c still resolves $legacy (F-06 v1)"
  fi
done
grep -q 'F-06 v1' "$RUNTIME" || die "runtime.c missing F-06 v1 legacy std .o cleanup marker"

echo "=== E-04 v15: asm_invoke_ld_platform in runtime_link_abi ==="
for f in "$DOC_V15" "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v15' "$DOC_V15" || die "doc missing E-04 v15 marker"
grep -q 'shux_asm_invoke_ld_platform' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_asm_invoke_ld_platform"
if grep -qE '^static int asm_invoke_ld_platform\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines asm_invoke_ld_platform"
fi
if grep -qE '^static int shu_ld_freestanding_enabled\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines shu_ld_freestanding_enabled"
fi

echo "=== E-04 v14: invoke_ld prepare + tail -l* + nm self-contained in runtime_link_abi ==="
for f in "$DOC_V14" "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v14' "$DOC_V14" || die "doc missing E-04 v14 marker"
grep -q 'SHUX_LD_ARGV_CAP' "$LINK_ABI_H" || die "runtime_link_abi.h missing SHUX_LD_ARGV_CAP"
grep -q 'shux_asm_ld_prepare_for_exe_link' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_asm_ld_prepare_for_exe_link"
grep -q 'shux_asm_user_o_has_undef_syms' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_asm_user_o_has_undef_syms"
grep -q 'shux_asm_ld_append_mach_tail_libs' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_asm_ld_append_mach_tail_libs"
grep -q 'shux_asm_ld_append_unix_gcc_tail_libs' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_asm_ld_append_unix_gcc_tail_libs"
if grep -qE '^static int (freestanding_prepare_runtime_panic_o|asm_user_o_has_undef_syms)\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines freestanding_prepare_runtime_panic_o or asm_user_o_has_undef_syms"
fi
if grep -q '#define SHUX_LD_ARGV_CAP' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines SHUX_LD_ARGV_CAP (expected runtime_link_abi.h)"
fi

echo "=== E-04 v13: asm_ld_append_std/on_demand + rel path in runtime_link_abi ==="
for f in "$DOC_V13" "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v13' "$DOC_V13" || die "doc missing E-04 v13 marker"
grep -q 'ShuAsmLdStdLinkFlags' "$LINK_ABI_H" || die "runtime_link_abi.h missing ShuAsmLdStdLinkFlags"
grep -q 'shux_rel_o_path_from_argv0' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_rel_o_path_from_argv0"
grep -q 'shux_asm_ld_append_std_objs' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_asm_ld_append_std_objs"
grep -q 'shux_asm_ld_append_on_demand_user_objs' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_asm_ld_append_on_demand_user_objs"
if grep -qE '^static void (asm_ld_append_std_objs|asm_ld_append_on_demand_user_objs)\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines asm_ld_append_std/on_demand"
fi

echo "=== E-04 v12: asm ld path bank + io/repo root in runtime_link_abi ==="
for f in "$DOC_V12" "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v12' "$DOC_V12" || die "doc missing E-04 v12 marker"
grep -q 'ShuAsmLdPathBank' "$LINK_ABI_C" || die "runtime_link_abi.c missing ShuAsmLdPathBank"
grep -q 'shux_asm_ld_bank_push' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_asm_ld_bank_push"
grep -q 'shux_asm_ld_try_under_lib_roots' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_asm_ld_try_under_lib_roots"
grep -q 'shux_std_io_o_path' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_std_io_o_path"
grep -q 'shux_repo_root_from_argv0' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_repo_root_from_argv0"
if grep -qE '^static const char \*(get_io_o_path|get_repo_root)\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines get_io_o_path or get_repo_root"
fi
if grep -qE '^typedef struct ShuAsmLdPathBank' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines ShuAsmLdPathBank (expected runtime_link_abi.h)"
fi
if grep -qE '^static const char \*shux_asm_ld_(bank_push|try_under_lib_roots)\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines shux_asm_ld_bank_push or try_under_lib_roots"
fi

echo "=== E-04 v11: ensure io_stubs/crt0/freestanding in runtime_link_abi ==="
for f in "$DOC_V11" "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v11' "$DOC_V11" || die "doc missing E-04 v11 marker"
grep -q 'shux_link_freestanding_enabled' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_link_freestanding_enabled"
grep -q 'shux_ensure_runtime_asm_io_stubs_o' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_ensure_runtime_asm_io_stubs_o"
grep -q 'shux_ensure_crt0_user_o' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_ensure_crt0_user_o"
grep -q 'shux_ensure_freestanding_io_o' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_ensure_freestanding_io_o"
if grep -qE '^static int ensure_(runtime_asm_io_stubs_o|crt0_user_o|freestanding_io_o)\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines ensure_runtime_asm_io_stubs_o/crt0/freestanding_io"
fi

echo "=== E-04 v10: freestanding/crt0 paths + ensure runtime_panic in runtime_link_abi ==="
for f in "$DOC_V10" "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v10' "$DOC_V10" || die "doc missing E-04 v10 marker"
grep -q 'shux_crt0_user_o_path' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_crt0_user_o_path"
grep -q 'shux_freestanding_io_o_path' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_freestanding_io_o_path"
grep -q 'shux_runtime_asm_io_stubs_o_path' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_runtime_asm_io_stubs_o_path"
grep -q 'shux_ensure_runtime_panic_o' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_ensure_runtime_panic_o"
if grep -qE '^static (const char \*(get_crt0_user_o_path|get_freestanding_io_o_path|get_runtime_asm_io_stubs_o_path)|int ensure_runtime_panic_o)\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines crt0/freestanding/io_stubs path or ensure_runtime_panic_o"
fi

echo "=== E-04 v9: runtime_panic + async scheduler .o paths in runtime_link_abi ==="
for f in "$DOC_V9" "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v9' "$DOC_V9" || die "doc missing E-04 v9 marker"
grep -q 'shux_runtime_panic_o_path' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_runtime_panic_o_path"
grep -q 'shux_std_async_scheduler_o_path' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_std_async_scheduler_o_path"
if grep -qE '^static const char \*(get_runtime_panic_o_path|get_std_async_scheduler_o_path)\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines get_runtime_panic_o_path or get_std_async_scheduler_o_path"
fi

echo "=== E-04 v8: compiler dir + asm ld effective argv0 in runtime_link_abi ==="
for f in "$DOC_V8" "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v8' "$DOC_V8" || die "doc missing E-04 v8 marker"
grep -q 'shu_resolve_compiler_dir' "$LINK_ABI_C" || die "runtime_link_abi.c missing shu_resolve_compiler_dir"
grep -q 'shux_asm_ld_effective_link_argv0' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_asm_ld_effective_link_argv0"
if grep -qE '^static (int shu_resolve_compiler_dir|const char \*shux_asm_ld_effective_link_argv0)\(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines shu_resolve_compiler_dir or shux_asm_ld_effective_link_argv0"
fi

echo "=== E-04 v7: Linux link hardening in runtime_link_abi ==="
for f in "$DOC_V7" "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v7' "$DOC_V7" || die "doc missing E-04 v7 marker"
grep -q 'shux_append_linux_link_harden' "$LINK_ABI_C" || die "runtime_link_abi.c missing shux_append_linux_link_harden"
if grep -q '^static void shux_append_linux_link_harden(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines shux_append_linux_link_harden (expected runtime_link_abi.c)"
fi

echo "=== E-04 v6: compress/net TLS link helpers in runtime_link_abi ==="
for f in "$DOC_V6" "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v6' "$DOC_V6" || die "doc missing E-04 v6 marker"
grep -q 'invoke_cc_append_compress_ld' "$LINK_ABI_C" || die "runtime_link_abi.c missing invoke_cc_append_compress_ld"
if grep -q '^static void invoke_cc_append_compress_ld(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines invoke_cc_append_compress_ld (expected runtime_link_abi.c)"
fi
if grep -q '^static void asm_ld_append_compress_libs(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines asm_ld_append_compress_libs (expected runtime_link_abi.c)"
fi

echo "=== E-04 v5: runtime link/cc helper ABI thin shell ==="
for f in "$DOC_V5" "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$LINK_ABI_C" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v5' "$DOC_V5" || die "doc missing E-04 v5 marker"
grep -q 'src/runtime_link_abi.o' "$MF" || die "Makefile missing runtime_link_abi.o"
grep -q 'ensure_runtime_link_abi_obj' "$BUILD" || die "build_shux_asm missing ensure_runtime_link_abi_obj"
grep -q 'runtime_link_abi.h' "$RUNTIME" || die "runtime.c should include runtime_link_abi.h"
if grep -q '^static int invoke_cc_argv_push_existing(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines invoke_cc_argv_push_existing (expected runtime_link_abi.c)"
fi
if ! sed -n '/^DRIVER_SEED_OBJS =/,/^$/p' "$MF" | grep -q 'src/runtime_link_abi.o'; then
  die "DRIVER_SEED_OBJS missing src/runtime_link_abi.o"
fi

echo "=== E-04 v4: runtime ABI + I/O + proc/link helper thin shell ==="
for f in "$DOC_V4" "$DOC_V3" "$DOC_V2" "$DOC_V1" "$MF" "$BUILD" "$RUNTIME" "$MAIN" \
  "$ABI_C" "$IO_ABI_C" "$PROC_ABI_C" "$ABI_MF"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-04 v4' "$DOC_V4" || die "doc missing E-04 v4 marker"
grep -q 'src/runtime_proc_abi.o' "$MF" || die "Makefile missing runtime_proc_abi.o"
grep -q 'ensure_runtime_proc_abi_obj' "$BUILD" || die "build_shux_asm missing ensure_runtime_proc_abi_obj"
grep -q 'runtime_proc_abi.h' "$RUNTIME" || die "runtime.c should include runtime_proc_abi.h"

if grep -q '^static int shu_waitpid_retry(' "$RUNTIME" 2>/dev/null; then
  die "runtime.c still defines shu_waitpid_retry (expected runtime_proc_abi.c)"
fi
if ! sed -n '/^DRIVER_SEED_OBJS =/,/^$/p' "$MF" | grep -q 'src/runtime_proc_abi.o'; then
  die "DRIVER_SEED_OBJS missing src/runtime_proc_abi.o"
fi
if ! grep '^OBJS_CORE' "$MF" | grep -q 'runtime_abi\.o'; then
  die "OBJS_CORE missing runtime_abi.o (E-03 v4)"
fi

MISS=0
while IFS=$'\t' read -r item_id _e_task path status _replacement check_type notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in
    exists)
      [ -f "$path" ] || { echo "e04 missing: $path ($item_id)" >&2; MISS=$((MISS + 1)); }
      ;;
    grep)
      case "$path" in
        runtime_abi.c:*)
          sym="${path#runtime_abi.c:}"
          grep -q "$sym" "$ABI_C" || { echo "e04 grep fail: $ABI_C need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_io_abi.c:*)
          sym="${path#runtime_io_abi.c:}"
          grep -q "$sym" "$IO_ABI_C" || { echo "e04 grep fail: $IO_ABI_C need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_proc_abi.c:*)
          sym="${path#runtime_proc_abi.c:}"
          grep -q "$sym" "$PROC_ABI_C" || { echo "e04 grep fail: $PROC_ABI_C need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_link_abi.c:*)
          sym="${path#runtime_link_abi.c:}"
          grep -q "$sym" "$LINK_ABI_C" || { echo "e04 grep fail: $LINK_ABI_C need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_driver_abi.c:*)
          sym="${path#runtime_driver_abi.c:}"
          grep -q "$sym" "$DRIVER_ABI_C" || { echo "e04 grep fail: $DRIVER_ABI_C need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_pipeline_abi.c:*)
          sym="${path#runtime_pipeline_abi.c:}"
          grep -q "$sym" "$PIPELINE_ABI_C" || { echo "e04 grep fail: $PIPELINE_ABI_C need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_pipeline_abi.h:*)
          sym="${path#runtime_pipeline_abi.h:}"
          grep -q "$sym" "$PIPELINE_ABI_H" || { echo "e04 grep fail: $PIPELINE_ABI_H need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_c_import.inc:*)
          sym="${path#runtime_c_import.inc:}"
          grep -q "$sym" compiler/src/runtime_c_import.inc || { echo "e04 grep fail: runtime_c_import.inc need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_driver_diagnostic.c:*)
          sym="${path#runtime_driver_diagnostic.c:}"
          grep -q "$sym" compiler/src/runtime_driver_diagnostic.c || { echo "e04 grep fail: runtime_driver_diagnostic.c need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime.c:*)
          sym="${path#runtime.c:}"
          grep -q "$sym" "$RUNTIME" || { echo "e04 grep fail: $RUNTIME need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_link_abi.h:*)
          sym="${path#runtime_link_abi.h:}"
          grep -q "$sym" "$LINK_ABI_H" || { echo "e04 grep fail: $LINK_ABI_H need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        *)
          [ -f "$path" ] && grep -qE "$notes" "$path" || { echo "e04 grep fail: $path need '$notes'" >&2; MISS=$((MISS + 1)); }
          ;;
      esac
      ;;
    track-only)
      echo "e04 track: $item_id ($notes)"
      ;;
    gate_ref)
      [ -f "$path" ] || { echo "e04 missing gate: $path" >&2; MISS=$((MISS + 1)); }
      ;;
    *)
      echo "e04 unknown check_type: $check_type ($item_id)" >&2
      MISS=$((MISS + 1))
      ;;
  esac
done < "$ABI_MF"
[ "$MISS" -eq 0 ] || die "$MISS manifest item(s) failed"

echo "e04 track: main.c only SHUX_LEGACY_MAIN_C or shux-c OBJS_CORE (by design; not E blocker)"
echo "e04 track: runtime.c active as driver glue + shux-c (E-04 CLOSED at v35; optional split defer)"
echo "e04 track: OBJS_CORE C frontend for shux-c cold start only (E-03 track; defer to F)"

if [ "${SHUX_E04_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e04 runtime soft-retire gate OK (manifest only)"
  exit 0
fi

echo "e04 runtime path gate OK (runtime_*_abi.o + runtime_driver_no_c.o default)"
