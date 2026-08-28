#!/usr/bin/env bash
# std-env-iter.sh — STD-025: env_iter / args_iter manifest helpers.
#
# Usage (after source):
#   std_env_iter_symbols_ok ENV_X ENV_IMPL ENV_GLUE TSV
#   std_env_iter_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_ENV_ITER_PREFIX="${XLANG_STD_ENV_ITER_PREFIX:-xlang: [XLANG_STD_ENV_ITER]}"

# Validate manifest symbol anchors. Echo miss count; return 0 when miss=0.
std_env_iter_symbols_ok() {
  local mod_x="$1"
  local env_impl="$2"
  local env_glue="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$kind" in
      symbol)
        local target="$mod_x"
        case "$mod_path" in
          std/env/env.c|std/env/env.x) target="$env_impl" ;;
          std/env/env_os_glue.c|compiler/seeds/runtime_env_os.from_x.c) target="$env_glue" ;;
        esac
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "std-env-iter FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_env_iter_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_ENV_ITER_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
