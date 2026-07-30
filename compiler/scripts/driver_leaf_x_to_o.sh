#!/usr/bin/env bash
# driver_leaf_x_to_o.sh — Track L：driver / lsp leaf .x → .o（符号 rename 与 g05/prove 一致）
#
# Usage (cwd = compiler/):
#   bash scripts/driver_leaf_x_to_o.sh <src.x> <out.o> <rename-map> [cold-seed.c]
#       # legacy explicit args (g05 / build_xlang_asm / archaeology callers)
#   bash scripts/driver_leaf_x_to_o.sh ensure <out.o>
#   bash scripts/driver_leaf_x_to_o.sh auto <out.o>     # alias of ensure
#   bash scripts/driver_leaf_x_to_o.sh list
#   bash scripts/driver_leaf_x_to_o.sh --check
#
# rename-map: old1:new1,old2:new2 (may be empty)
# Prefer: xlang/xlang-c/bootstrap_xlangc -E → rename → cc -c
# Fallback: cold-seed.c (seeds/* only; never workspace pinned driver_*_gen.c)
#
# wave814 (G.7 有则补全): product leaf table lives here — src + rename + cold
# seed + -L roots. Makefile thin-calls `ensure $@` only. NOT physical delete;
# thin edges + B7B lists + B2 remain residual.
# wave828 (G.7 有则补全): FORCE dep-thin — Makefile prereqs are FORCE + script only;
#   shell owns catalog source mtime (skip up-to-date). NOT physical delete; thin
#   edges + B2 try-heat + mk lists still form make graph residual.
# wave860 (G.7 有则补全 on wave857/859 export-leaf pattern): BASE_CFLAGS multi-token
#   composition loads via make export-driver-leaf-base-cflags when unset
#   ($(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc). Makefile recipes drop
#   multi-token BASE_CFLAGS= env. NOT physical delete; thin edges + B2 + lists remain.
#
# Env: CC, BASE_CFLAGS (optional; shell-loads export leaf when unset), MAKE,
#      DRIVER_SUBCMD_DIRS (legacy override; ensure uses catalog)
# PLATFORM: SHARED — catalog + compile body.
set -eu
cd "$(dirname "$0")/.."

# ---------------------------------------------------------------------------
# wave814: driver_leaf shell-primary catalog (G.7; not physical delete)
# Spec: src|rename|cold_seed|dirs_kind
#   dirs_kind = base | extended | lsp  (matches historic Makefile env)
# Keys accept bare out name or path ending in the leaf .o
# ---------------------------------------------------------------------------

driver_leaf_key_for_out() {
  _o="$1"
  case "$_o" in
    driver_fmt_x.o|*driver_fmt_x.o) printf '%s' "driver_fmt_x.o" ;;
    driver_check_x.o|*driver_check_x.o) printf '%s' "driver_check_x.o" ;;
    driver_test_x.o|*driver_test_x.o) printf '%s' "driver_test_x.o" ;;
    driver_build_x.o|*driver_build_x.o) printf '%s' "driver_build_x.o" ;;
    driver_run_x.o|*driver_run_x.o) printf '%s' "driver_run_x.o" ;;
    driver_compile_x.o|*driver_compile_x.o) printf '%s' "driver_compile_x.o" ;;
    driver_emit_x.o|*driver_emit_x.o) printf '%s' "driver_emit_x.o" ;;
    lsp_io_std_heap_x.o|*lsp_io_std_heap_x.o) printf '%s' "lsp_io_std_heap_x.o" ;;
    *) printf '%s' "" ;;
  esac
}

# Compile rename authority (historic Makefile DRIVER_COMPILE_RENAME).
# PLATFORM: SHARED — must match prove/g05 cold seed renames.
driver_leaf_compile_rename() {
  printf '%s' \
    'compile_dispatch_asm_backend:driver_compile_dispatch_asm_backend,'\
'compile_dispatch_emit_c_path:driver_compile_dispatch_emit_c_path,'\
'eq_minus_o:driver_eq_minus_o,'\
'eq_minus_L:driver_eq_minus_L,'\
'eq_minus_backend:driver_eq_minus_backend,'\
'eq_minus_target:driver_eq_minus_target,'\
'eq_minus_target_cpu:driver_eq_minus_target_cpu,'\
'eq_print_target_cpu:driver_eq_print_target_cpu,'\
'eq_minus_O:driver_eq_minus_O,'\
'eq_flto:driver_eq_flto,'\
'eq_minus_freestanding:driver_eq_minus_freestanding,'\
'eq_legacy_f32_abi:driver_eq_legacy_f32_abi,'\
'eq_fsanitize_address:driver_eq_fsanitize_address,'\
'eq_asm_word:driver_eq_asm_word,'\
'eq_c_word:driver_eq_c_word,'\
'path_ends_x:driver_path_ends_x,'\
'target_has_arm:driver_target_has_arm,'\
'run_compiler_full_x_post_parse:driver_run_compiler_full_x_post_parse,'\
'run_compiler_full_x:driver_run_compiler_full_x'
}

# Emit rename authority (historic Makefile DRIVER_EMIT_RENAME).
driver_leaf_emit_rename() {
  printf '%s' \
    'emit_copy_lib_roots_to_ctx:driver_emit_copy_lib_roots_to_ctx,'\
'run_x_emit_x:driver_run_x_emit_x,'\
'dispatch_x_emit_to_c:driver_dispatch_x_emit_to_c,'\
'emit_state_key:driver_emit_state_key,'\
'pipeline_dep_ctx_fill_for_emit:driver_pipeline_dep_ctx_fill_for_emit'
}

# lsp_io_std_heap rename (historic Makefile LSP_IO_STD_HEAP_RENAME).
driver_leaf_lsp_io_std_heap_rename() {
  printf '%s' \
    'std_heap_alloc:lsp_io_std_heap_std_heap_alloc,'\
'std_heap_alloc_zeroed:lsp_io_std_heap_std_heap_alloc_zeroed,'\
'std_heap_free:lsp_io_std_heap_std_heap_free'
}

# Print catalog line for key: src|rename|cold_seed|dirs_kind
# rename may be empty; long renames resolved at ensure time via helpers above
# when rename field is @compile / @emit / @lsp_io_std_heap.
driver_leaf_spec_for_key() {
  case "$1" in
    driver_fmt_x.o)
      printf '%s' 'src/driver/fmt.x|cmd_fmt:driver_cmd_fmt|seeds/driver_fmt_gen.linux.x86_64.c|base'
      ;;
    driver_check_x.o)
      printf '%s' 'src/driver/check.x|cmd_check:driver_cmd_check|seeds/driver_check_gen.linux.x86_64.c|base'
      ;;
    driver_test_x.o)
      printf '%s' 'src/driver/test.x|cmd_test:driver_cmd_test|seeds/driver_test_gen.linux.x86_64.c|base'
      ;;
    driver_build_x.o)
      printf '%s' 'src/driver/build.x|cmd_build:build_cmd_build|seeds/driver_build_gen.linux.x86_64.c|base'
      ;;
    driver_run_x.o)
      printf '%s' 'src/driver/run.x|run_eq_word:driver_run_eq_word,cmd_run:driver_cmd_run|seeds/driver_run_gen.linux.x86_64.c|base'
      ;;
    driver_compile_x.o)
      printf '%s' 'src/driver/compile.x|@compile|seeds/driver_compile_gen.linux.x86_64.c|extended'
      ;;
    driver_emit_x.o)
      printf '%s' 'src/driver/emit.x|@emit|seeds/driver_emit_gen.linux.x86_64.c|extended'
      ;;
    lsp_io_std_heap_x.o)
      printf '%s' 'src/lsp/lsp_io_std_heap.x|@lsp_io_std_heap|seeds/lsp_io_std_heap_gen.linux.x86_64.c|lsp'
      ;;
    *)
      printf '%s' ''
      ;;
  esac
}

driver_leaf_mk_assign_val() {
  # First KEY = value from product mk (strip comments / trailing space).
  # PLATFORM: SHARED — pure text parse; no make. G.7: no dual hardcode of
  # product -L inventories (wave816 DRIVER_SUBCMD_DIRS; wave824 LSP_X_E_DIRS).
  local key="$1"
  local mk="$2"
  local line
  line=$(grep -E "^${key}[[:space:]]*=" "$mk" 2>/dev/null | head -1 | sed "s/^${key}[[:space:]]*=[[:space:]]*//;s/#.*//;s/[[:space:]]*$//")
  printf '%s' "$line"
}

driver_leaf_dirs_for_kind() {
  # base = DRIVER_SUBCMD_DIRS (mk/driver_subcmd_objs.mk wave816)
  # lsp  = LSP_X_E_DIRS (mk/x_e_dirs.mk wave824)
  # extended = g05/subcmd extended roots (archaeology; not MAIN/LSP product E_DIRS)
  case "$1" in
    base)
      _v=$(driver_leaf_mk_assign_val DRIVER_SUBCMD_DIRS "mk/driver_subcmd_objs.mk")
      if [ -z "$_v" ]; then
        echo "driver_leaf_x_to_o: failed to load DRIVER_SUBCMD_DIRS from mk/driver_subcmd_objs.mk" >&2
        return 2
      fi
      printf '%s' "$_v"
      ;;
    extended)
      printf '%s' '-L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/lsp -L src/preprocess -L src/driver'
      ;;
    lsp)
      _v=$(driver_leaf_mk_assign_val LSP_X_E_DIRS "mk/x_e_dirs.mk")
      if [ -z "$_v" ]; then
        echo "driver_leaf_x_to_o: failed to load LSP_X_E_DIRS from mk/x_e_dirs.mk" >&2
        return 2
      fi
      printf '%s' "$_v"
      ;;
    *)
      _v=$(driver_leaf_mk_assign_val DRIVER_SUBCMD_DIRS "mk/driver_subcmd_objs.mk")
      if [ -z "$_v" ]; then
        printf '%s' '-L .. -L src -L src/lexer -L src/ast'
      else
        printf '%s' "$_v"
      fi
      ;;
  esac
}

driver_leaf_resolve_rename() {
  case "$1" in
    @compile) driver_leaf_compile_rename ;;
    @emit) driver_leaf_emit_rename ;;
    @lsp_io_std_heap) driver_leaf_lsp_io_std_heap_rename ;;
    *) printf '%s' "$1" ;;
  esac
}

driver_leaf_list_keys() {
  printf '%s\n' \
    driver_fmt_x.o \
    driver_check_x.o \
    driver_test_x.o \
    driver_build_x.o \
    driver_run_x.o \
    driver_compile_x.o \
    driver_emit_x.o \
    lsp_io_std_heap_x.o
}

driver_leaf_check() {
  _n=0
  _miss=0
  while IFS= read -r _k; do
    _n=$((_n + 1))
    _spec="$(driver_leaf_spec_for_key "$_k")"
    if [ -z "$_spec" ]; then
      echo "driver_leaf_x_to_o --check: missing spec for $_k" >&2
      _miss=$((_miss + 1))
      continue
    fi
    _src="${_spec%%|*}"
    _rest="${_spec#*|}"
    _rename_tok="${_rest%%|*}"
    _rest2="${_rest#*|}"
    _seed="${_rest2%%|*}"
    _kind="${_rest2#*|}"
    if [ ! -f "$_src" ]; then
      echo "driver_leaf_x_to_o --check: missing src $_src for $_k" >&2
      _miss=$((_miss + 1))
    fi
    if [ ! -f "$_seed" ]; then
      echo "driver_leaf_x_to_o --check: missing cold seed $_seed for $_k" >&2
      _miss=$((_miss + 1))
    fi
    case "$_kind" in
      base|extended|lsp) ;;
      *)
        echo "driver_leaf_x_to_o --check: bad dirs_kind $_kind for $_k" >&2
        _miss=$((_miss + 1))
        ;;
    esac
    _rn="$(driver_leaf_resolve_rename "$_rename_tok")"
    case "$_k" in
      driver_compile_x.o)
        case "$_rn" in
          *driver_compile_dispatch_asm_backend*) ;;
          *)
            echo "driver_leaf_x_to_o --check: compile rename map incomplete" >&2
            _miss=$((_miss + 1))
            ;;
        esac
        ;;
      driver_emit_x.o)
        case "$_rn" in
          *driver_run_x_emit_x*) ;;
          *)
            echo "driver_leaf_x_to_o --check: emit rename map incomplete" >&2
            _miss=$((_miss + 1))
            ;;
        esac
        ;;
      lsp_io_std_heap_x.o)
        case "$_rn" in
          *lsp_io_std_heap_std_heap_alloc*) ;;
          *)
            echo "driver_leaf_x_to_o --check: lsp_io_std_heap rename map incomplete" >&2
            _miss=$((_miss + 1))
            ;;
        esac
        ;;
    esac
  done <<EOF
$(driver_leaf_list_keys)
EOF
  if [ "$_n" -ne 8 ]; then
    echo "driver_leaf_x_to_o --check: expected 8 catalog keys, got $_n" >&2
    exit 1
  fi
  if [ "$_miss" -ne 0 ]; then
    echo "driver_leaf_x_to_o --check: FAIL ($_miss issues)" >&2
    exit 1
  fi
  # Makefile thin greps when available (cwd = compiler/)
  _mf=Makefile
  if [ -f "$_mf" ]; then
    for _leaf in driver_fmt_x.o driver_check_x.o driver_test_x.o driver_build_x.o \
      driver_run_x.o driver_compile_x.o driver_emit_x.o lsp_io_std_heap_x.o; do
      # wave828: FORCE required (dep-thin); ban dual catalog .x on prereq line.
      if ! awk -v leaf="$_leaf" '
        $0 ~ ("^" leaf ":") {
          line=$0
          if (line !~ /FORCE/) { exit 1 }
          if (line ~ /\.x([[:space:]]|$)/) { exit 1 }
          want=1; next
        }
        want && /^[^#[:space:]]/ { want=0 }
        want && /driver_leaf_x_to_o\.sh ensure/ { found=1 }
        END { exit found ? 0 : 1 }
      ' "$_mf"; then
        echo "driver_leaf_x_to_o --check: Makefile $_leaf must FORCE + ensure (wave828 FORCE thin)" >&2
        exit 1
      fi
    done
    # No residual explicit-arg product recipe (legacy path still OK for g05 scripts).
    if grep -nE $'^\t.*driver_leaf_x_to_o\.sh (src/|seeds/)' "$_mf" 2>/dev/null | head -1 | grep -q .; then
      echo "driver_leaf_x_to_o --check: Makefile still has explicit-arg driver_leaf recipes (wave814)" >&2
      exit 1
    fi
    # wave860: Makefile must not re-export multi-token BASE_CFLAGS (shell loads export leaf).
    if grep -nE $'^\tBASE_CFLAGS=' "$_mf" 2>/dev/null | head -1 | grep -q .; then
      echo "driver_leaf_x_to_o --check: Makefile must not inject BASE_CFLAGS= (wave860; shell loads export-driver-leaf-base-cflags)" >&2
      exit 1
    fi
    if ! grep -qE '^export-driver-leaf-base-cflags:' "$_mf"; then
      echo "driver_leaf_x_to_o --check: Makefile must define export-driver-leaf-base-cflags (wave860)" >&2
      exit 1
    fi
  fi
  echo "driver_leaf_x_to_o --check: OK (8 catalog leaves; FORCE+ensure wave828; BASE_CFLAGS export leaf wave860; not physical delete)"
  exit 0
}

# wave860: BASE_CFLAGS from make export leaf when unset (G.7; not physical delete).
# Composition needs make expansion (OPT CFLAGS, PIPELINE_GEN_CFLAGS clang ifeq).
# PLATFORM: SHARED — KEY=value from export target; fallback matches historic default.
_load_driver_leaf_base_cflags_via_make() {
  local raw line
  raw=$(MAKEFLAGS= "${MAKE:-make}" -s export-driver-leaf-base-cflags) || return 1
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      BASE_CFLAGS=*) BASE_CFLAGS=${line#BASE_CFLAGS=} ;;
    esac
  done <<<"$raw"
  [ -n "${BASE_CFLAGS:-}" ]
}

pick_xlang() {
  for b in ./xlang ./xlang-c ./bootstrap_xlangc; do
    if [ -x "$b" ]; then
      printf '%s\n' "$b"
      return 0
    fi
  done
  return 1
}

apply_rename() {
  _file="$1"
  _map="$2"
  [ -z "$_map" ] && return 0
  _old_ifs="$IFS"
  IFS=','
  # shellcheck disable=SC2086
  for _pair in $_map; do
    _old="${_pair%%:*}"
    _new="${_pair#*:}"
    if [ -n "$_old" ] && [ -n "$_new" ] && [ "$_old" != "$_new" ]; then
      perl -i -pe "s/\\b${_old}\\b/${_new}/g" "$_file"
    fi
  done
  IFS="$_old_ifs"
}

# Core build body (legacy + ensure share this).
# Args: X_SRC OUT_O SYM_RENAME COLD_SEED
# Env: CC BASE_CFLAGS DRIVER_SUBCMD_DIRS (or DIRS pre-set)
driver_leaf_build() {
  X_SRC="$1"
  OUT_O="$2"
  SYM_RENAME="${3:-}"
  COLD_SEED="${4:-}"

  if [ ! -f "$X_SRC" ]; then
    echo "driver_leaf_x_to_o: missing $X_SRC" >&2
    exit 1
  fi

  CC="${CC:-cc}"
  # wave860: shell-load BASE_CFLAGS via export leaf when unset (G.7).
  # Explicit BASE_CFLAGS= from env (tests / g05) still wins; never dual-compose in Makefile.
  if [ -z "${BASE_CFLAGS:-}" ]; then
    if ! _load_driver_leaf_base_cflags_via_make; then
      BASE_CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
    fi
  fi
  DIRS="${DRIVER_SUBCMD_DIRS:--L .. -L src -L src/lexer -L src/ast}"

  if XLANG_BIN=$(pick_xlang); then
    tmp="$(mktemp "${TMPDIR:-/tmp}/driver_leaf.XXXXXX.c")"
    # 30s guard (align prove_module_selfhost / g05)
    # shellcheck disable=SC2086
    if perl -e 'alarm 30; exec @ARGV' "$XLANG_BIN" -E $DIRS "$X_SRC" >"$tmp" 2>/dev/null \
      && [ -s "$tmp" ]; then
      grep -v '^DBG-' "$tmp" >"${tmp}.clean" && mv "${tmp}.clean" "$tmp"
      apply_rename "$tmp" "$SYM_RENAME"
      {
        echo '/* driver_leaf_x_to_o prologue */'
        echo '#include <stddef.h>'
        echo '#include <stdint.h>'
        echo '#include <sys/types.h>'
        echo '#include <stdlib.h>'
        echo '#include <string.h>'
        echo '#include <stdio.h>'
        echo '#ifndef _WIN32'
        echo '#include <unistd.h>'
        echo '#include <fcntl.h>'
        echo '#include <errno.h>'
        echo '#endif'
        sed -e '/^#include /d' \
            -e '/^extern ssize_t read(/d' \
            -e '/^extern ssize_t write(/d' \
            -e '/^extern int32_t open(/d' \
            -e '/^extern int open(/d' \
            -e '/^extern int32_t fcntl(/d' \
            -e '/^extern int fcntl(/d' \
            -e '/^extern int32_t close(/d' \
            -e '/^extern int close(/d' \
            -e '/^extern uint8_t \* calloc(/d' \
            -e '/^extern uint8_t \* malloc(/d' \
            -e '/^extern void free(/d' \
            -e '/^extern char \* getenv(/d' \
            -e '/^extern uint8_t \* getenv(/d' \
            -e '/^extern int32_t unlink(/d' \
            -e '/^extern int unlink(/d' \
            -e '/^extern size_t strlen(/d' \
            "$tmp"
      } >"${tmp}.full" && mv "${tmp}.full" "$tmp"
      # shellcheck disable=SC2086
      if $CC $BASE_CFLAGS -x c -c -o "$OUT_O" "$tmp" 2>/dev/null; then
        rm -f "$tmp"
        echo "driver_leaf_x_to_o: $OUT_O <- $X_SRC (PREFER_X_O)"
        return 0
      fi
    fi
    rm -f "$tmp"
    echo "driver_leaf_x_to_o: PREFER_X_O failed for $X_SRC; try cold seed" >&2
  fi

  if [ -n "$COLD_SEED" ] && [ -f "$COLD_SEED" ]; then
    # PLATFORM: SHARED — cold seed may contain extern decls that conflict with
    # system headers on macOS (void* vs uint8_t*). Strip before compile.
    _seed_tmp="$(mktemp "${TMPDIR:-/tmp}/cold_seed.XXXXXX.c")"
    sed -e '/^extern uint8_t \* malloc(/d' \
        -e '/^extern void free(/d' \
        -e '/^extern uint8_t \* calloc(/d' \
        "$COLD_SEED" > "$_seed_tmp"
    # shellcheck disable=SC2086
    if $CC $BASE_CFLAGS -c -o "$OUT_O" "$_seed_tmp" 2>/dev/null; then
      rm -f "$_seed_tmp"
      echo "driver_leaf_x_to_o: $OUT_O <- $COLD_SEED (cold seed, stripped externs)"
      return 0
    fi
    rm -f "$_seed_tmp"
    # Fallback: unstripped (Linux often has no conflict)
    # shellcheck disable=SC2086
    $CC $BASE_CFLAGS -c -o "$OUT_O" "$COLD_SEED"
    echo "driver_leaf_x_to_o: $OUT_O <- $COLD_SEED (cold seed)"
    return 0
  fi

  echo "driver_leaf_x_to_o: cannot build $OUT_O (no xlang -E and no cold seed)" >&2
  exit 1
}

driver_leaf_ensure() {
  OUT_O="${1:?driver_leaf ensure needs <out.o>}"
  _key="$(driver_leaf_key_for_out "$OUT_O")"
  if [ -z "$_key" ]; then
    echo "driver_leaf_x_to_o ensure: unknown leaf $OUT_O (not in wave814 catalog)" >&2
    exit 1
  fi
  _spec="$(driver_leaf_spec_for_key "$_key")"
  if [ -z "$_spec" ]; then
    echo "driver_leaf_x_to_o ensure: empty spec for $_key" >&2
    exit 1
  fi
  _src="${_spec%%|*}"
  _rest="${_spec#*|}"
  _rename_tok="${_rest%%|*}"
  _rest2="${_rest#*|}"
  _seed="${_rest2%%|*}"
  _kind="${_rest2#*|}"
  _rename="$(driver_leaf_resolve_rename "$_rename_tok")"
  # ensure path: catalog owns -L roots (G.7). Escape only via
  # XLANG_DRIVER_LEAF_DIRS_OVERRIDE (explicit non-empty). Legacy CLI still
  # respects DRIVER_SUBCMD_DIRS for g05/build_xlang_asm callers.
  if [ -n "${XLANG_DRIVER_LEAF_DIRS_OVERRIDE:-}" ]; then
    export DRIVER_SUBCMD_DIRS="$XLANG_DRIVER_LEAF_DIRS_OVERRIDE"
  else
    export DRIVER_SUBCMD_DIRS
    DRIVER_SUBCMD_DIRS="$(driver_leaf_dirs_for_kind "$_kind")"
  fi
  # wave828: FORCE-thin mtime — shell owns catalog source freshness (G.7).
  # Makefile always invokes via FORCE; skip recompile when OUT is newer than the
  # catalog .x source. FORCE=1 forces rebuild (tests / explicit). PLATFORM: SHARED.
  if [ "${FORCE:-0}" != "1" ] && [ -f "$OUT_O" ]; then
    _dl_stale=0
    if [ -f "$_src" ] && [ "$_src" -nt "$OUT_O" ]; then
      _dl_stale=1
    fi
    if [ "$_dl_stale" = "0" ]; then
      echo "driver_leaf_x_to_o: skip up-to-date $OUT_O (driver_leaf/$_key)" >&2
      return 0
    fi
  fi
  driver_leaf_build "$_src" "$OUT_O" "$_rename" "$_seed"
}

# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
case "${1:-}" in
  ensure|auto)
    shift
    driver_leaf_ensure "${1:?}"
    exit 0
    ;;
  list)
    driver_leaf_list_keys
    exit 0
    ;;
  --check)
    driver_leaf_check
    ;;
  -h|--help)
    sed -n '2,25p' "$0"
    exit 0
    ;;
esac

# Legacy explicit args (g05 / build_xlang_asm / callers)
X_SRC="${1:?}"
OUT_O="${2:?}"
SYM_RENAME="${3:-}"
COLD_SEED="${4:-}"
driver_leaf_build "$X_SRC" "$OUT_O" "$SYM_RENAME" "$COLD_SEED"
exit 0
