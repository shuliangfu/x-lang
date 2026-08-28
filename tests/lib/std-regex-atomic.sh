#!/usr/bin/env bash
# std-regex-atomic.sh — STD-124 atomic-group helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_regex_atomic_source_regex
#   std_regex_atomic_symbols_ok REGEX_X TSV
#   std_regex_atomic_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# Parent STD-051 helpers (run_c_smoke / run_smoke) are G.7 authority — do not duplicate.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_REGEX_ATOMIC_PREFIX="${XLANG_STD124_REGEX_ATOMIC_PREFIX:-xlang: [XLANG_STD124_REGEX_ATOMIC]}"

# Source STD-051 helpers (run_c_smoke / run_smoke). G.7: do not fork.
std_regex_atomic_source_regex() {
  # shellcheck source=tests/lib/std-regex.sh
  . tests/lib/std-regex.sh
}

# Validate manifest; echo miss count; return 0 iff miss==0.
std_regex_atomic_symbols_ok() {
  local regex_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/regex/regex.x" ]; then path="$regex_x"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-regex-atomic FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD124_DOC:-analysis/archive/std/std-regex-atomic-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-regex-atomic FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-regex-atomic FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-regex-atomic FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "std-regex-atomic FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; retired c=/x=).
std_regex_atomic_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_REGEX_ATOMIC_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
