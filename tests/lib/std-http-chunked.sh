#!/usr/bin/env bash
# std-http-chunked.sh — STD-033 manifest + smoke helpers.
#
# Usage (after source):
#   std_http_chunked_symbols_ok MOD_X CHUNKED_INC HTTP_C TSV
#   std_http_chunked_run_smoke XLANG_BIN X TAG
#   std_http_chunked_emit_report status run obs skip
# Honesty: run=/obs=/skip= (check = obs; prefer asm product -o hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_HTTP_CHUNKED_PREFIX="${XLANG_STD_HTTP_CHUNKED_PREFIX:-xlang: [XLANG_STD_HTTP_CHUNKED]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_http_chunked_symbols_ok() {
  local mod_x="$1"
  local chunked_inc="$2"
  local http_c="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-http-chunked FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local target="${mod_path:-$chunked_inc}"
        case "$target" in
          compiler/seeds/runtime_http_glue.from_x.c) target="$http_c" ;;
        esac
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "std-http-chunked FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$mod_path" ]; then
          echo "std-http-chunked FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        elif ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-http-chunked FAIL: $mod_path missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|bench)
        if [ ! -f "$anchor" ]; then
          echo "std-http-chunked FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script|gate|anchor|hook_script)
        # DOC ## 4. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run chunked smoke .x via product XLANG_BIN -L . -o; expect exit 0.
# Refuse soft RUN_XLANG remap / soft ensure rebuild (gate pins XLANG_LINK_XLANG).
# PLATFORM: SHARED archaeology — product honesty path.
std_http_chunked_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_http_chunked_${tag}_$$"
  local log="/tmp/xlang_std_http_chunked_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-http-chunked FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-http-chunked FAIL: compile $src" >&2
    tail -n 10 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-http-chunked FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=).
# Hard-green signal is product -o chunked_keepalive.x; check = obs.
std_http_chunked_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_HTTP_CHUNKED_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
