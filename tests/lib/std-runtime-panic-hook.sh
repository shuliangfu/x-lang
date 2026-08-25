#!/usr/bin/env bash
# std-runtime-panic-hook.sh — STD-028: panic hook manifest helpers
#
# Usage (after source):
#   std_runtime_panic_manifest_ok DOC README RUNTIME_X TSV
#   std_runtime_panic_run_smoke XLANG_BIN smoke_x tag
#   std_runtime_panic_emit_report status check_ok hook_ok ready_ok exc_ok skip
# 2026-08-26: report check=/hook=/ready=/exc=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology.

STD_RUNTIME_PANIC_PREFIX="${XLANG_STD_RUNTIME_PANIC_PREFIX:-xlang: [XLANG_STD_RUNTIME_PANIC]}"

# Validate manifest; echo "miss" count; return 0 iff miss==0.
std_runtime_panic_manifest_ok() {
  local doc="$1"
  local readme="$2"
  local runtime_x="$3"
  local tsv="$4"
  shift 4
  local miss=0
  local matrix_n=0
  local min_matrix=6
  local item_id kind doc_anchor code_anchor src _notes
  while IFS=$'\t' read -r item_id kind doc_anchor code_anchor src _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*) continue ;;
      min_matrix_rows)
        if [ -n "${doc_anchor:-}" ]; then
          min_matrix="$doc_anchor"
        fi
        continue
        ;;
    esac
    case "$kind" in
      section|cross_ref)
        if ! grep -qF "$doc_anchor" "$doc" 2>/dev/null; then
          echo "std-runtime-panic FAIL: doc missing '$doc_anchor' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      readme)
        if ! grep -qF "$doc_anchor" "$readme" 2>/dev/null; then
          echo "std-runtime-panic FAIL: README missing '$doc_anchor' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        matrix_n=$((matrix_n + 1))
        if ! grep -qE "function ${code_anchor}\\(" "$runtime_x" 2>/dev/null; then
          echo "std-runtime-panic FAIL: missing ${code_anchor} in $runtime_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      code)
        matrix_n=$((matrix_n + 1))
        if [ ! -f "$src" ]; then
          echo "std-runtime-panic FAIL: missing $src ($item_id)" >&2
          miss=$((miss + 1))
        elif ! grep -qF "$code_anchor" "$src" 2>/dev/null; then
          echo "std-runtime-panic FAIL: $src missing '$code_anchor' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|hook|script)
        if [ ! -f "$src" ]; then
          echo "std-runtime-panic FAIL: missing $src ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  if [ "$matrix_n" -lt "$min_matrix" ]; then
    echo "std-runtime-panic FAIL: anchors=${matrix_n} < min ${min_matrix}" >&2
    miss=$((miss + 1))
  fi
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run smoke .x; expect exit 0.
# Prefer RUN_XLANG (after gate pins XLANG_LINK_XLANG) so Darwin does not
# silently remap asm→c. Falls back to direct XLANG_BIN -L . -o.
# PLATFORM: SHARED archaeology — product honesty path.
std_runtime_panic_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_runtime_panic_${tag}_$$"
  local log="/tmp/xlang_std_runtime_panic_build_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-runtime-panic FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-runtime-panic FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-runtime-panic FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-runtime-panic FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: check=/hook=/ready=/exc=/skip=).
std_runtime_panic_emit_report() {
  local status="$1"
  local check_ok="$2"
  local hook_ok="$3"
  local ready_ok="$4"
  local exc_ok="$5"
  local skip="$6"
  echo "${STD_RUNTIME_PANIC_PREFIX} status=${status} check=${check_ok} hook=${hook_ok} ready=${ready_ok} exc=${exc_ok} skip=${skip}"
}
