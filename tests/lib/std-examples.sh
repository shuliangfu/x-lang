#!/usr/bin/env bash
# std-examples.sh — STD-012 shared: catalog validate + check obs + runnable smoke.
#
# Usage (after source):
#   std_ex_catalog_count [catalog_tsv]
#   std_ex_validate_paths [catalog_tsv]
#   std_ex_check_example XLANG_BIN path
#   std_ex_run_x_smoke XLANG_BIN SRC OUT_PREFIX
#   std_ex_emit_report status check_ok x_ok skip
# 2026-08-26: report check=/x=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_EX_PREFIX="${XLANG_STD_EXAMPLES_PREFIX:-xlang: [XLANG_STD_EXAMPLES]}"

# Count catalog example rows (exclude comments).
std_ex_catalog_count() {
  local cat="${1:-tests/baseline/std-examples-catalog.tsv}"
  awk -F'\t' '$1 !~ /^#/ && NF >= 3 { n++ } END { print n+0 }' "$cat"
}

# Validate every catalog path exists; return 1 on any miss.
std_ex_validate_paths() {
  local cat="${1:-tests/baseline/std-examples-catalog.tsv}"
  local miss=0
  while IFS=$'\t' read -r eid _cat path _tier _notes; do
    [ -z "${eid:-}" ] && continue
    case "$eid" in \#*) continue ;; esac
    if [ ! -f "$path" ]; then
      echo "std-examples FAIL: missing $path ($eid)" >&2
      miss=$((miss + 1))
    fi
  done < "$cat"
  [ "$miss" -eq 0 ]
}

# Observational xlang check for one example; return 0 on pass.
# Check gate paused 2026-08-05 — callers must not hard-fail on red.
# @param $1 XLANG_BIN — resolved product compiler
# @param $2 SRC — .x path
std_ex_check_example() {
  local xlang="$1"
  local src="$2"
  if [ ! -f "$src" ]; then
    return 1
  fi
  if "$xlang" check -L . "$src" >/dev/null 2>&1; then
    return 0
  fi
  "$xlang" check -L . "$src" 2>&1 | tail -5 >&2 || true
  return 1
}

# Build+run one .x smoke; return 0 when process exits 0.
# @param $1 XLANG_BIN — resolved product compiler (prefer asm)
# @param $2 SRC — .x smoke path
# @param $3 OUT_PREFIX — /tmp prefix for binary + build log
std_ex_run_x_smoke() {
  local xlang_bin="$1"
  local src="$2"
  local out_prefix="$3"
  local out="${out_prefix}"
  local log="${out_prefix}.log"
  # Prefer bootstrap-link RUN_XLANG when caller pinned XLANG_LINK_XLANG.
  # PLATFORM: SHARED — product path honesty.
  local runner="${RUN_XLANG:-}"
  if [ -z "$runner" ]; then
    runner="$xlang_bin"
  fi
  if ! $runner -L . "$src" -o "$out" 2>"$log"; then
    echo "std-examples FAIL: link $src" >&2
    tail -20 "$log" 2>/dev/null >&2 || true
    rm -f "$out"
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-examples FAIL: $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (check observational; x runnable hard; skip only
# for manifest-only paths — never soft-OK when no native compiler).
# @param $1 status — ok|fail
# @param $2 check_ok — observational check (0/1; not hard green)
# @param $3 x_ok — must runnable exit0 (hard green)
# @param $4 skip — 1 only for manifest-only
std_ex_emit_report() {
  local status="$1"
  local check_ok="$2"
  local x_ok="$3"
  local skip="$4"
  echo "${STD_EX_PREFIX} status=${status} check=${check_ok} x=${x_ok} skip=${skip}"
}

# Print catalog Markdown index table (stdout).
std_ex_print_index() {
  local cat="${1:-tests/baseline/std-examples-catalog.tsv}"
  printf '\n| id | category | path | tier |\n'
  printf '|----|----------|------|------|\n'
  while IFS=$'\t' read -r eid category path tier _notes; do
    [ -z "${eid:-}" ] && continue
    case "$eid" in \#*) continue ;; esac
    printf '| %s | %s | %s | %s |\n' "$eid" "$category" "$path" "$tier"
  done < "$cat"
  printf '\n'
}
