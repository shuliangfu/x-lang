#!/usr/bin/env bash
# std-elf-sym-rela.sh — STD-103 manifest 与 symtab/rela 烟测辅助

STD_ELF_SYM_RELA_PREFIX="${SHUX_STD103_PREFIX:-shux: [SHUX_STD103_ELF_SYM_RELA]}"

# 校验 manifest 中 api/const/symbol/file。
std_elf_sym_rela_symbols_ok() {
  local mod_x="$1"
  local elf_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-elf-sym-rela FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_x" 2>/dev/null; then
          echo "std-elf-sym-rela FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/elf/elf.x" ]; then path="$elf_x"; fi
        if [ "$path" = "std/elf/elf_glue.c" ]; then path="$elf_x"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-elf-sym-rela FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|fixture)
        if [ ! -f "$anchor" ]; then
          echo "std-elf-sym-rela FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# C symtab/rela 烟测。
std_elf_sym_rela_run_c_smoke() {
  local elf_o_dir="$1"
  local src="tests/std-elf/parse_sym_rela_smoke_ok.c"
  local out="/tmp/shux_std_elf_sym_rela_$$"
  local elf_o
  elf_o="${elf_o_dir}/elf.o"
  if [ ! -f "$elf_o" ]; then
    echo "std-elf-sym-rela FAIL: missing $elf_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$elf_o" 2>/dev/null; then
    echo "std-elf-sym-rela FAIL: compile C smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-elf-sym-rela FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# .x 烟测。
std_elf_sym_rela_run_x_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-symrela}"
  local exe="/tmp/shux_std_elf_sym_rela_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-elf-sym-rela FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-elf-sym-rela FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_elf_sym_rela_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_ELF_SYM_RELA_PREFIX} status=${status} c=${c_ok} x=${su_ok} skip=${skip}"
}
