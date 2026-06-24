#!/usr/bin/env bash
# std-metrics.sh — STD-078 manifest 与烟测辅助

STD_METRICS_PREFIX="${SHUX_STD_METRICS_PREFIX:-shux: [SHUX_STD_METRICS]}"

std_metrics_symbols_ok() {
  local mod_sx="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-metrics FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-metrics FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_metrics_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-metrics}"
  local exe="/tmp/shux_std_metrics_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-metrics FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-metrics FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_metrics_emit_report() {
  local status="$1"
  local su_ok="$2"
  local skip="$3"
  echo "${STD_METRICS_PREFIX} status=${status} sx=${su_ok} skip=${skip}"
}
