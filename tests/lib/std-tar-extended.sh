#!/usr/bin/env bash
# std-tar-extended.sh — STD-152 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_tar_extended_symbols_ok MOD_SU TAR_C TSV
#   std_tar_extended_run_c_smoke TAR_C
#   std_tar_extended_run_su_smoke SHU_BIN SU TAR_O
#   std_tar_extended_emit_report status c_ok su_ok skip

STD_TAR_EXTENDED_PREFIX="${SHU_STD_TAR_EXTENDED_PREFIX:-shu: [SHU_STD_TAR_EXTENDED]}"

# 校验 manifest symbol/file/api；echo 缺失数。
std_tar_extended_symbols_ok() {
  local mod_su="$1"
  local tar_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-tar-extended FAIL: missing api '$anchor' in $mod_su" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol|impl_prefix|impl_pax)
        case "$mod_path" in
          std/tar/tar.c) mod_path="$tar_c" ;;
          std/tar/mod.su) mod_path="$mod_su" ;;
          *) mod_path="$mod_su" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-tar-extended FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-tar-extended FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 C 烟测（tar.o + extended_ok.c）。
std_tar_extended_run_c_smoke() {
  local tar_c="$1"
  local smoke_c="tests/std-tar/extended_ok.c"
  local exe="/tmp/shu_std_tar_extended_c_$$"
  if [ ! -f "$smoke_c" ]; then
    echo "std-tar-extended FAIL: missing $smoke_c" >&2
    return 1
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/tar/tar.o
  local tar_o
  tar_o="$(cd compiler && pwd)/../std/tar/tar.o"
  if ! cc -std=c11 -Wall -Wextra -o "$exe" "$smoke_c" "$tar_o" 2>/dev/null; then
    echo "std-tar-extended FAIL: compile C smoke" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-tar-extended FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 编译并运行 .su 烟测（须链 tar.o）。
std_tar_extended_run_su_smoke() {
  local shu="$1"
  local src="$2"
  local tar_o="$3"
  local exe="/tmp/shu_std_tar_extended_su_$$"
  if [ ! -f "$src" ]; then
    echo "std-tar-extended FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shu" -L . "$src" -o "$exe" "$tar_o" >/dev/null 2>&1; then
    echo "std-tar-extended FAIL: compile $src" >&2
    "$shu" -L . "$src" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-tar-extended FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_tar_extended_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_TAR_EXTENDED_PREFIX} status=${status} c=${c_ok} su=${su_ok} skip=${skip}"
}
