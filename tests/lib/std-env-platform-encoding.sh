#!/usr/bin/env bash
# std-env-platform-encoding.sh — STD-132: platform encoding / env-block helpers.
#
# Usage (after source):
#   std_env_platform_encoding_symbols_ok MOD_X ENV_X ENV_GLUE TSV
#   std_env_platform_encoding_run_c_smoke ENV_O [RUNTIME_ENV_O]
#   std_env_platform_encoding_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_ENV_PLATFORM_ENCODING_PREFIX="${XLANG_STD132_ENV_PLATFORM_ENCODING_PREFIX:-xlang: [XLANG_STD132_ENV_PLATFORM_ENCODING]}"

# Validate manifest api/symbol/file/smoke anchors. Echo miss count.
std_env_platform_encoding_symbols_ok() {
  local mod_x="$1"
  local env_x="$2"
  local env_glue="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-env-platform-encoding FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/env/env.c|std/env/env.x) path="$env_x" ;;
          std/env/env_os_glue.c|compiler/seeds/runtime_env_os.from_x.c) path="$env_glue" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-env-platform-encoding FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-env-platform-encoding FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Observational C smoke: existing env.o + runtime_env_os.o only.
# Refuse soft ensure/auto-make; missing .o → caller counts obs.
# PLATFORM: SHARED archaeology — product honesty is platform_encoding.x via asm.
std_env_platform_encoding_run_c_smoke() {
  local env_o="$1"
  local runtime_env_o="${2:-compiler/runtime_env_os.o}"
  local src="tests/env/platform_encoding_smoke_ok.c"
  local out="/tmp/xlang_std_env_pe_c_$$"
  [ -f "$env_o" ] || return 1
  [ -f "$runtime_env_o" ] || return 1
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t env_platform_encoding_smoke_c(void);' \
      'int main(void) { return env_platform_encoding_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$env_o" "$runtime_env_o" 2>/dev/null; then
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_env_platform_encoding_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_ENV_PLATFORM_ENCODING_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
