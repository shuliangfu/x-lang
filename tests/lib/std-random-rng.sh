#!/usr/bin/env bash
# std-random-rng.sh — STD-130: reproducible PRNG manifest helpers.
#
# Usage (after source):
#   std_random_rng_symbols_ok MOD_X RANDOM_X TSV
#   std_random_rng_run_c_smoke RANDOM_O   # observational host-C only
#   std_random_rng_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_RANDOM_RNG_PREFIX="${XLANG_STD130_RANDOM_RNG_PREFIX:-xlang: [XLANG_STD130_RANDOM_RNG]}"

# Validate manifest entries. Echo miss count; return 0 when miss=0.
std_random_rng_symbols_ok() {
  local mod_x="$1"
  local random_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api|struct_rng)
        if ! grep -qE "(function|struct) ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-random-rng FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/random/random.c|std/random/random.x) path="$random_c" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-random-rng FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-random-rng FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script)
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Observational C smoke: existing random.o + runtime_random_fill.o.
# Refuse soft ensure/auto-make; missing .o → caller counts obs.
# PLATFORM: SHARED archaeology — product honesty is rng_roundtrip.x / main.x via asm.
std_random_rng_run_c_smoke() {
  local random_o="$1"
  local src="tests/random/rng_smoke_ok.c"
  local out="/tmp/xlang_std_random_rng_c_$$"
  local fill_o=""
  [ -f "$random_o" ] || return 1
  if [ -f compiler/runtime_random_fill.o ]; then
    fill_o="compiler/runtime_random_fill.o"
  elif [ -f "$(cd compiler && pwd)/runtime_random_fill.o" ]; then
    fill_o="$(cd compiler && pwd)/runtime_random_fill.o"
  else
    return 1
  fi
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t random_rng_smoke_c(void);' \
      'int main(void) { return random_rng_smoke_c() != 0; }' > "$src"
  fi
  local ld_extra=""
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) ld_extra="-lbcrypt" ;;
  esac
  if ! cc -std=c11 -O1 -o "$out" "$src" "$random_o" "$fill_o" $ld_extra 2>/dev/null; then
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
std_random_rng_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_RANDOM_RNG_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
