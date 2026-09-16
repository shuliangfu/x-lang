#!/usr/bin/env bash
# std-async-language.sh — STD-041 manifest + smoke helpers
#
# Usage (after source):
#   std_alang_symbols_ok MOD_X TSV
#   std_alang_emit_report status run_ok mod_ok skip_1m [obs]
#   std_alang_run_smoke XLANG_BIN X OUT

STD_ALANG_PREFIX="${XLANG_STD_ASYNC_LANGUAGE_PREFIX:-xlang: [XLANG_STD_ASYNC_LANGUAGE]}"

# Validate manifest symbol/file rows; echo miss count; return 0 on success.
std_alang_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$mod_x" 2>/dev/null; then
          echo "std-async-language FAIL: missing '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-async-language FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run smoke; return 0 on success.
std_alang_run_smoke() {
  local xlang="$1"
  local x="$2"
  local out="$3"
  rm -f "$out"
  if ! "$xlang" -L . "$x" -o "$out" >/tmp/std_alang_smoke.log 2>&1; then
    cat /tmp/std_alang_smoke.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne 0 ]; then
    echo "std-async-language FAIL: $x exit=$ec" >&2
    return 1
  fi
  return 0
}

# Emit structured report line (obs optional; default 0).
std_alang_emit_report() {
  local status="$1"
  local run_ok="$2"
  local mod_ok="$3"
  local skip_1m="$4"
  local obs="${5:-0}"
  echo "${STD_ALANG_PREFIX} status=${status} run=${run_ok} mod=${mod_ok} obs=${obs} skip_1m=${skip_1m}"
}
