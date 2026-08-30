#!/usr/bin/env bash
# std-db-kv-arrow.sh — F-05 kv+arrow manifest 与烟测辅助
#
# 用法（source 后）：
#   std_db_kv_arrow_symbols_ok KV_MOD ARROW_MOD KV_X ARROW_X TSV
#   std_db_kv_arrow_run_smoke XLANG_BIN X TAG
#   std_db_kv_arrow_run_c_smokes
#   std_db_kv_arrow_emit_report status run_ok obs skip
# 2026-08-28: report run=/obs=/skip= (soft fallthrough residual closed).
# Honesty leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Parent kv-arrow / F-05 already Honesty
# (resolve_shu / prefer-asm). leftover nested product path (manifest /
# kv_tick / arrow_column / cookbook -o / observational host-C) stay.
# Do not fork a third resolver here.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.

STD_DB_KV_ARROW_PREFIX="${XLANG_STD_DB_KV_ARROW_PREFIX:-xlang: [XLANG_STD_DB_KV_ARROW]}"

std_db_kv_arrow_symbols_ok() {
  local kv_mod="$1"
  local arrow_mod="$2"
  local kv_x="$3"
  local arrow_x="$4"
  local tsv="$5"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        case "$mod_path" in
          std/db/arrow/mod.x) mod_path="$arrow_mod" ;;
          *) mod_path="$kv_mod" ;;
        esac
        if ! grep -qE "function ${anchor}\\(" "$mod_path" 2>/dev/null; then
          echo "std-db-kv-arrow FAIL: missing api '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|script)
        if [ ! -f "$anchor" ]; then
          echo "std-db-kv-arrow FAIL: missing $kind '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/db/arrow/arrow.x) mod_path="$arrow_x" ;;
          std/db/kv/kv.x) mod_path="$kv_x" ;;
          *) ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-db-kv-arrow FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        :
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_db_kv_arrow_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_db_kv_arrow_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-db-kv-arrow FAIL: missing $src" >&2
    return 1
  fi
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-db-kv-arrow FAIL: compile $src" >&2
    "$xlang" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-db-kv-arrow FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Observational host-C smokes (kv + arrow). Returns 0 only if both present and exit 0.
# Refuse soft auto-make / soft ensure rebuild — use existing .o only.
# PLATFORM: SHARED archaeology — not the product asm hard-green path.
std_db_kv_arrow_run_c_smokes() {
  local tmp
  tmp=$(mktemp -d)
  local ok=0
  local kv_path="$tmp/kv_smoke.dat"
  cat >"$tmp/kv_smoke_main.c" <<EOF
#include <stdint.h>
extern int32_t db_kv_smoke_c(uint8_t *path);
int main(void) {
  uint8_t p[] = "$kv_path";
  return db_kv_smoke_c(p) == 0 ? 0 : 1;
}
EOF
  cat >"$tmp/arrow_smoke_main.c" <<'EOF'
#include <stdint.h>
extern int32_t arrow_smoke_c(void);
int main(void) { return arrow_smoke_c() == 0 ? 0 : 1; }
EOF
  # No soft xlang_compiler_make || true — missing .o → observational miss.
  if [ -f std/db/kv/kv.o ] && [ -f compiler/runtime_kv_mmap_glue.o ] \
    && nm std/db/kv/kv.o 2>/dev/null | grep -q ' db_kv_smoke_c\| T _db_kv_smoke_c\| T db_kv_smoke_c'; then
    if cc -o "$tmp/kv_c_smoke" "$tmp/kv_smoke_main.c" std/db/kv/kv.o \
         compiler/runtime_kv_mmap_glue.o 2>/dev/null \
       && "$tmp/kv_c_smoke"; then
      ok=$((ok + 1))
    fi
  fi
  if [ -f std/db/arrow/arrow.o ] && [ -f compiler/runtime_arrow_simd_glue.o ] \
    && nm std/db/arrow/arrow.o 2>/dev/null | grep -q ' arrow_smoke_c\| T _arrow_smoke_c\| T arrow_smoke_c'; then
    if cc -o "$tmp/arrow_c_smoke" "$tmp/arrow_smoke_main.c" std/db/arrow/arrow.o \
         compiler/runtime_arrow_simd_glue.o 2>/dev/null \
       && "$tmp/arrow_c_smoke"; then
      ok=$((ok + 1))
    fi
  fi
  rm -rf "$tmp"
  [ "$ok" -eq 2 ]
}

# Structured report line (honesty: run=/obs=/skip=).
# @param $1 status — ok|fail
# @param $2 run_ok — product kv+arrow+cb hard green count
# @param $3 obs — check/host-C observational residuals
# @param $4 skip — 1 only for manifest-only
std_db_kv_arrow_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_DB_KV_ARROW_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
