#!/usr/bin/env bash
# E-04：runtime_*_abi 薄壳活面门禁（假权威诚实）。
#
# 用法：./tests/run-e04-runtime-soft-gate.sh
# 环境：
# 2026-08-26: soft XLANG_E04_FAIL retired (die always hard).
#   XLANG_E04_MANIFEST_ONLY=1     — 仅 manifest / 活面存在性
#
# wave honesty (2026-08-24 #5): DOC → analysis/archive/phase/；
# monofile seeds/runtime.from_x.c retired wave321 — live = runtime_*_abi + rt_*；
# Makefile deleted MG wave941 → compiler/mk/driver_seed_composites.mk +
# compiler/mk/driver_seed_link_picks.mk（refuse resurrect）。
# Override: XLANG_E04_DOC_DIR=… / XLANG_E04_MK_COMPOSITES=… / XLANG_E04_MK_PICKS=…
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

DOC_DIR="${XLANG_E04_DOC_DIR:-analysis/archive/phase}"
DOC="$DOC_DIR/phase-e-e04-v35.md"
ABI_MF="tests/baseline/e04-runtime-abi.tsv"
BUILD="compiler/scripts/build_xlang_asm.sh"
MK_COMPOSITES="${XLANG_E04_MK_COMPOSITES:-compiler/mk/driver_seed_composites.mk}"
MK_PICKS="${XLANG_E04_MK_PICKS:-compiler/mk/driver_seed_link_picks.mk}"
MAIN="compiler/seeds/main.from_x.c"
ABI_H="compiler/src/runtime_abi.h"
PROC_ABI_H="compiler/src/runtime_proc_abi.h"
IO_ABI_C="compiler/seeds/runtime_io_abi.from_x.c"
LINK_ABI_C="compiler/seeds/runtime_link_abi.from_x.c"
LINK_ABI_H="compiler/src/runtime_link_abi.h"
DRIVER_ABI_C="compiler/seeds/runtime_driver_abi.from_x.c"
DRIVER_ABI_H="compiler/src/runtime_driver_abi.h"
PIPELINE_ABI_C="compiler/seeds/runtime_pipeline_abi.from_x.c"
PIPELINE_ABI_H="compiler/src/runtime_pipeline_abi.h"
DIAG_C="compiler/seeds/runtime_driver_diagnostic.from_x.c"
C_IMPORT_C="compiler/seeds/runtime_c_import.from_x.c"
CRT0_LINUX="compiler/src/asm/crt0_x86_64.s"
CRT0_DARWIN_ARM="compiler/src/asm/crt0_arm64.s"
CRT0_DARWIN_X64="compiler/src/asm/crt0_darwin_x86_64.s"
CRT0_MINGW="compiler/seeds/crt0_mingw.from_x.c"

die() {
  echo "e04 gate FAIL: $*" >&2
  exit 1
}

echo "=== E-04: live runtime_*_abi faces (monofile/Makefile retired) ==="

# MG: compiler/Makefile deleted — refuse resurrect.
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use mk/driver_seed_*.mk + ./xbuild)"
fi
# wave321: monofile retired — refuse resurrect.
if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected (live = runtime_*_abi + rt_* slices)"
fi

for f in "$DOC" "$ABI_MF" "$BUILD" "$MK_COMPOSITES" "$MK_PICKS" \
  "$MAIN" "$ABI_H" "$PROC_ABI_H" "$IO_ABI_C" "$LINK_ABI_C" "$LINK_ABI_H" \
  "$DRIVER_ABI_C" "$DRIVER_ABI_H" "$PIPELINE_ABI_C" "$PIPELINE_ABI_H" \
  "$DIAG_C" "$C_IMPORT_C" \
  "$CRT0_MINGW" "$CRT0_LINUX" "$CRT0_DARWIN_ARM" "$CRT0_DARWIN_X64"; do
  [ -f "$f" ] || die "missing $f"
done

grep -q 'E-04 v35' "$DOC" || die "doc missing E-04 v35 marker"

# Live pipeline / driver / link ABI symbols (tip faces; no monofile call-site checks).
for sym in xlang_collect_deps_transitive xlang_merge_direct_then_transitive_deps \
  xlang_load_direct_imports_for_asm_layout xlang_preprocess \
  xlang_import_dep_dir_from_path xlang_asm_codegen_elf_o_large_stack \
  pipeline_typeck_module_for_ctx xlang_lsp_free_loaded_imports \
  pipeline_set_entry_dir pipeline_read_file \
  xlang_pipeline_run_x_pipeline_large_stack \
  xlang_preprocess_raw_to_malloc \
  xlang_pipeline_fill_ctx_path_buffers \
  xlang_find_loaded_import_index \
  driver_dep_publish_slot \
  xlang_resolve_import_file_path_multi; do
  grep -q "$sym" "$PIPELINE_ABI_C" || die "runtime_pipeline_abi.from_x.c missing $sym"
done
for sym in xlang_collect_deps_transitive xlang_preprocess \
  xlang_driver_asm_prepare_entry_elf_emit xlang_lsp_free_loaded_imports \
  xlang_pipeline_dep_prerun_parse_only xlang_pipeline_pctx_seed_dep_slots \
  xlang_dep_prerun_entry_dir driver_dep_arena_buf XLANG_DRIVER_DEP_SLOT_MAX \
  xlang_get_entry_dir; do
  grep -q "$sym" "$PIPELINE_ABI_H" || die "runtime_pipeline_abi.h missing $sym"
done

grep -q 'driver_diagnostic_parse_fail' "$DIAG_C" || die "runtime_driver_diagnostic missing driver_diagnostic_parse_fail"
grep -q 'driver_diagnostic_hint_unused_binding' "$DIAG_C" || die "runtime_driver_diagnostic missing driver_diagnostic_hint_unused_binding"
grep -q 'xlang_c_resolve_and_load_imports' "$C_IMPORT_C" || die "runtime_c_import missing xlang_c_resolve_and_load_imports"
grep -q 'xlang_lsp_resolve_and_load_imports' "$C_IMPORT_C" || die "runtime_c_import missing xlang_lsp_resolve_and_load_imports"

for sym in driver_bump_stack_limit driver_pipeline_fail_code \
  driver_argv_collect_defines driver_asm_build_skip_typeck \
  driver_compile_phase_timing_begin driver_peek_source_file \
  driver_source_has_top_level_import_path driver_check_only_get; do
  grep -q "$sym" "$DRIVER_ABI_C" || die "runtime_driver_abi.from_x.c missing $sym"
done
for sym in driver_run_thread_on_large_stack driver_print_x_smoke_summary \
  driver_set_pipeline_entry_source_len; do
  grep -q "$sym" "$DRIVER_ABI_H" || die "runtime_driver_abi.h missing $sym"
done

for sym in xlang_invoke_ld_for_exe xlang_invoke_cc \
  xlang_generated_c_needs_async_scheduler xlang_asm_invoke_ld_platform \
  xlang_asm_ld_prepare_for_exe_link xlang_asm_user_o_has_undef_syms \
  xlang_asm_ld_append_mach_tail_libs xlang_asm_ld_append_unix_gcc_tail_libs \
  xlang_rel_o_path_from_argv0 xlang_asm_ld_append_std_objs \
  xlang_asm_ld_append_on_demand_user_objs ShuAsmLdPathBank \
  xlang_asm_ld_bank_push xlang_asm_ld_try_under_lib_roots \
  xlang_std_io_o_path xlang_repo_root_from_argv0 \
  xlang_link_freestanding_enabled xlang_ensure_runtime_asm_io_stubs_o \
  xlang_ensure_crt0_user_o xlang_ensure_freestanding_io_o \
  xlang_crt0_user_o_path xlang_freestanding_io_o_path \
  xlang_runtime_asm_io_stubs_o_path xlang_ensure_runtime_panic_o \
  xlang_runtime_panic_o_path xlang_std_async_scheduler_o_path \
  xlang_resolve_compiler_dir xlang_asm_ld_effective_link_argv0 \
  xlang_append_linux_link_harden invoke_cc_append_compress_ld \
  xlang_std_compress_o_path link_abi_generated_c_needs_zlib \
  xlang_forward_main_to_main_entry xlang_waitpid_retry; do
  grep -q "$sym" "$LINK_ABI_C" || die "runtime_link_abi.from_x.c missing $sym"
done
for sym in xlang_output_want_exe xlang_output_is_elf_o XLANG_INVOKE_CC_MAX_C_FILES \
  XLANG_LD_ARGV_CAP ShuAsmLdStdLinkFlags; do
  grep -q "$sym" "$LINK_ABI_H" || die "runtime_link_abi.h missing $sym"
done
grep -q 'runtime_driver_abi.h' "$LINK_ABI_C" || die "runtime_link_abi.inc must include runtime_driver_abi.h"

# Forward / waitpid moved into link_abi (runtime_abi.c / runtime_proc_abi.c retired).
grep -q 'xlang_forward_main_to_main_entry' "$ABI_H" || die "runtime_abi.h missing xlang_forward_main_to_main_entry"
grep -q 'xlang_waitpid_retry' "$PROC_ABI_H" || die "runtime_proc_abi.h missing xlang_waitpid_retry"
grep -q 'xlang_forward_main_to_main_entry' "$MAIN" || die "main.from_x.c should call xlang_forward_main_to_main_entry"
grep -q 'E-04 v21' "$MAIN" || die "main.from_x.c missing E-04 v21 minimal main marker"
if grep -qE 'extern int main_entry' "$MAIN" 2>/dev/null; then
  die "main.from_x.c should not extern main_entry (use runtime_abi forward)"
fi

# crt0 → main_entry (platform entry surface).
grep -q 'call[[:space:]]*main_entry' "$CRT0_LINUX" || die "crt0_x86_64.s must call main_entry"
if grep -qE '^[[:space:]]*call[[:space:]]*entry[[:space:]]*$' "$CRT0_LINUX" 2>/dev/null; then
  die "crt0_x86_64.s still calls bare entry"
fi
grep -q '_main_entry' "$CRT0_DARWIN_ARM" || die "crt0_arm64.s must call _main_entry"
grep -q '_main_entry' "$CRT0_DARWIN_X64" || die "crt0_darwin_x86_64.s must call _main_entry"
grep -q 'xlang_forward_main_to_main_entry' "$CRT0_MINGW" || die "crt0_mingw.inc must call xlang_forward_main_to_main_entry"

# mk live faces (DRIVER_SEED_OBJS / MAIN_LINK_O / PREPROCESS_LINK_O).
grep -q 'DRIVER_SEED_OBJS' "$MK_COMPOSITES" || die "$MK_COMPOSITES missing DRIVER_SEED_OBJS"
for o in runtime_pipeline_abi.o runtime_driver_abi.o runtime_driver_diagnostic.o \
  runtime_link_abi.o runtime_io_abi.o; do
  grep -q "$o" "$MK_COMPOSITES" || die "$MK_COMPOSITES missing $o"
done
grep -q 'MAIN_LINK_O' "$MK_PICKS" || die "$MK_PICKS missing MAIN_LINK_O"
grep -q 'PREPROCESS_LINK_O' "$MK_PICKS" || die "$MK_PICKS missing PREPROCESS_LINK_O"
# Default preprocess link must stay empty (E-03 soft-retire).
grep -qE '^PREPROCESS_LINK_O[[:space:]]*=' "$MK_PICKS" || die "$MK_PICKS missing PREPROCESS_LINK_O assignment"
if grep -qE '^PREPROCESS_LINK_O[[:space:]]*=[[:space:]]*[^[:space:]]' "$MK_PICKS"; then
  die "$MK_PICKS PREPROCESS_LINK_O default must be empty"
fi
grep -q 'crt0_x86_64.o\|crt0_arm64.o\|crt0_darwin_x86_64.o\|crt0_mingw.o' "$MK_PICKS" \
  || die "$MK_PICKS missing crt0*.o in MAIN_LINK_O branches"
grep -q 'ensure_runtime_pipeline_abi_obj\|ensure_runtime_link_abi_obj\|ensure_runtime_proc_abi_obj' "$BUILD" \
  || die "build_xlang_asm.sh missing ensure_runtime_*_abi_obj helpers"

# F-06 v1: no legacy std fs/heap/compress .o path resolves in live link ABI.
for legacy in 'std/fs/fs.o' 'std/heap/heap.o' 'std/compress/compress.o'; do
  if grep -q "xlang_rel_o_path_from_argv0(argv\[0\], \"$legacy\")" "$LINK_ABI_C" 2>/dev/null; then
    die "runtime_link_abi still resolves $legacy"
  fi
done
grep -q 'F-06 v1' "$LINK_ABI_C" || die "runtime_link_abi missing F-06 v1 marker"
grep -q 'F-06 v1' "$BUILD" || die "build_xlang_asm.sh missing F-06 v1 marker"

# Manifest: skip dead runtime.c / top-level analysis DOC / Makefile rows;
# still verify live exists/grep faces that map to tip seeds.
MISS=0
while IFS=$'\t' read -r item_id _e_task path status _replacement check_type notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  # Skip retired archaeology rows (monofile / top-level DOC / Makefile /
  # runtime_abi.c / runtime_proc_abi.c bodies absorbed into link_abi;
  # "Phase E active" monofile markers retired with wave321).
  case "$item_id" in
    e04_runtime_still_active|e04_main_still_active) continue ;;
  esac
  case "$path" in
    runtime.c:*|runtime_abi.c:*|runtime_proc_abi.c:*|compiler/seeds/runtime.from_x.c|compiler/src/runtime_abi.c|compiler/src/runtime_proc_abi.c|compiler/Makefile|analysis/phase-e-e04-*)
      continue
      ;;
  esac
  case "$check_type" in
    exists)
      [ -f "$path" ] || { echo "e04 missing: $path ($item_id)" >&2; MISS=$((MISS + 1)); }
      ;;
    grep)
      case "$path" in
        runtime_io_abi.from_x.c:*)
          sym="${path#runtime_io_abi.from_x.c:}"
          grep -q "$sym" "$IO_ABI_C" || { echo "e04 grep fail: $IO_ABI_C need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_link_abi.from_x.c:*)
          sym="${path#runtime_link_abi.from_x.c:}"
          grep -q "$sym" "$LINK_ABI_C" || { echo "e04 grep fail: $LINK_ABI_C need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_driver_abi.from_x.c:*)
          sym="${path#runtime_driver_abi.from_x.c:}"
          grep -q "$sym" "$DRIVER_ABI_C" || { echo "e04 grep fail: $DRIVER_ABI_C need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_pipeline_abi.from_x.c:*)
          sym="${path#runtime_pipeline_abi.from_x.c:}"
          grep -q "$sym" "$PIPELINE_ABI_C" || { echo "e04 grep fail: $PIPELINE_ABI_C need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_pipeline_abi.h:*)
          sym="${path#runtime_pipeline_abi.h:}"
          grep -q "$sym" "$PIPELINE_ABI_H" || { echo "e04 grep fail: $PIPELINE_ABI_H need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_c_import.from_x.c:*)
          sym="${path#runtime_c_import.from_x.c:}"
          grep -q "$sym" "$C_IMPORT_C" || { echo "e04 grep fail: runtime_c_import need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_driver_diagnostic.from_x.c:*)
          sym="${path#runtime_driver_diagnostic.from_x.c:}"
          grep -q "$sym" "$DIAG_C" || { echo "e04 grep fail: runtime_driver_diagnostic need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        runtime_link_abi.h:*)
          sym="${path#runtime_link_abi.h:}"
          grep -q "$sym" "$LINK_ABI_H" || { echo "e04 grep fail: $LINK_ABI_H need $sym" >&2; MISS=$((MISS + 1)); }
          ;;
        *)
          if [ -f "$path" ]; then
            grep -qE "$notes" "$path" || { echo "e04 grep fail: $path need '$notes'" >&2; MISS=$((MISS + 1)); }
          else
            echo "e04 grep fail: missing $path ($item_id)" >&2
            MISS=$((MISS + 1))
          fi
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

echo "e04 track: monofile runtime.from_x.c retired wave321 (live ABI + rt_* slices)"
echo "e04 track: Makefile deleted MG wave941 (mk/driver_seed_*.mk + ./xbuild)"

if [ "${XLANG_E04_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e04 runtime soft-retire gate OK (manifest only)"
  exit 0
fi

echo "e04 runtime path gate OK (live runtime_*_abi + mk DRIVER_SEED + archive DOC)"
