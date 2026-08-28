#!/usr/bin/env bash
# std-metrics-obs.sh — STD-117 ObservabilityCtx + log KV helpers.
#
# Usage (after source):
#   std_metrics_obs_symbols_ok MOD_X TSV
#   std_metrics_obs_run_x_smoke XLANG SRC
#   std_metrics_obs_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_METRICS_OBS_PREFIX="${XLANG_STD117_METRICS_OBS_PREFIX:-xlang: [XLANG_STD117_METRICS_OBS]}"

# Validate manifest api/file/smoke/vectors anchors.
# Echo miss count; return 0 when miss=0.
std_metrics_obs_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run .x obs correlation smoke.
# Prefer callers pin XLANG_LINK_XLANG to product asm before invoke.
# Tip product UNDEF for std_metrics_*/std_trace_* is gate-obs.
std_metrics_obs_run_x_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_std_metrics_obs_$$"
  local log="/tmp/xlang_std_metrics_obs_compile_$$.log"
  if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
    tail -12 "$log" >&2 || true
    rm -f "$log" "$exe"
    return 1
  fi
  rm -f "$log"
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; check / tip UNDEF = obs).
std_metrics_obs_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_METRICS_OBS_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
