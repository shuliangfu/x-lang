#!/usr/bin/env bash
# std-elf-deep.sh — STD-063 manifest 与深化烟测辅助

STD_ELF_DEEP_PREFIX="${SHUX_STD063_PREFIX:-shux: [SHUX_STD063_ELF_DEEP]}"

# 校验深化 manifest 中 api/const/symbol。
std_elf_deep_symbols_ok() {
  local mod_sx="$1"
  local elf_sx="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-elf-deep FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_sx" 2>/dev/null; then
          echo "std-elf-deep FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/elf/elf.sx" ]; then path="$elf_sx"; fi
        if [ "$path" = "std/elf/elf_glue.c" ]; then path="$elf_sx"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-elf-deep FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|fixture)
        if [ ! -f "$anchor" ]; then
          echo "std-elf-deep FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# C 深化烟测。
std_elf_deep_run_c_smoke() {
  local elf_o_dir="$1"
  local src="tests/std-elf/parse_sections_smoke_ok.c"
  local out="/tmp/shux_std_elf_deep_$$"
  local elf_o
  elf_o="${elf_o_dir}/elf.o"
  if [ ! -f "$elf_o" ]; then
    echo "std-elf-deep FAIL: missing $elf_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$elf_o" 2>/dev/null; then
    echo "std-elf-deep FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-elf-deep FAIL: c deep smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# .sx 深化烟测（复用 STD-058 辅助）。
std_elf_deep_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_elf_deep_sx_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-elf-deep SKIP: compile $src" >&2
    rm -f "$exe"
    return 2
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-elf-deep SKIP: run $src exit=$ec" >&2
    return 2
  fi
  return 0
}

# 输出门禁报告。
std_elf_deep_emit_report() {
  local status="$1"
  local deep_c="$2"
  local deep_sx="$3"
  local skip="$4"
  echo "${STD_ELF_DEEP_PREFIX} status=${status} deep_c=${deep_c} deep_sx=${deep_sx} skip=${skip}"
}
