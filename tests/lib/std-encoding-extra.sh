#!/usr/bin/env bash
# std-encoding-extra.sh — STD-127 Base32/percent helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_encoding_extra_symbols_ok MOD_X ENCODING_X TSV
#   std_encoding_extra_run_c_smoke ENCODING_O   # prebuilt encoding.o only
#   std_encoding_extra_run_smoke XLANG_BIN SRC
#   std_encoding_extra_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_ENCODING_EXTRA_PREFIX="${XLANG_STD127_ENCODING_EXTRA_PREFIX:-xlang: [XLANG_STD127_ENCODING_EXTRA]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_encoding_extra_symbols_ok() {
  local mod_x="$1"
  local encoding_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-encoding-extra FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/encoding/encoding.c|std/encoding/encoding.x) path="$encoding_c" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-encoding-extra FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD127_DOC:-analysis/archive/std/std-encoding-extra-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-encoding-extra FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-encoding-extra FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-encoding-extra FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Product tip -o smoke. Caller decides hard vs obs (tip UNDEF = obs leave).
# PLATFORM: SHARED archaeology — product honesty path.
std_encoding_extra_run_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_std_encoding_extra_$$"
  local log="/tmp/xlang_std_encoding_extra_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-encoding-extra FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  # Do not restore set -e between steps: return 1 must not trip the gate's set +e window.
  # PLATFORM: SHARED archaeology.
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-encoding-extra OBS tip product -o (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-encoding-extra OBS tip run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Host-C archaeology: prebuilt std/encoding/encoding.o only.
# Refuse soft ensure_std_c_o / soft auto-make.
# Returns 0 green, 1 link/run fail, 2 missing prebuilt / missing smoke symbol.
# PLATFORM: SHARED — do not toggle set -e (leaks make return 1 kill the gate).
std_encoding_extra_run_c_smoke() {
  local encoding_o="$1"
  local src="tests/encoding/extra_smoke_ok.c"
  local out="/tmp/xlang_std_encoding_extra_c_$$"
  if [ ! -f "$encoding_o" ]; then
    echo "std-encoding-extra OBS c smoke (missing prebuilt $encoding_o; refuse soft ensure)" >&2
    return 2
  fi
  if ! nm "$encoding_o" 2>/dev/null | grep -q ' encoding_extra_smoke_c'; then
    echo "std-encoding-extra OBS c smoke (encoding.o missing extra smoke symbol; refuse soft rebuild)" >&2
    return 2
  fi
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t encoding_extra_smoke_c(void);' \
      'int main(void) { return encoding_extra_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$encoding_o" 2>/tmp/std_encoding_extra_c_$$.log; then
    echo "std-encoding-extra OBS c smoke link (refuse soft ensure)" >&2
    return 1
  fi
  # Do not restore set -e here: return 1 must not trip the gate's set +e window.
  # PLATFORM: SHARED — SEGV/exit≠0 is obs, not soft die.
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-encoding-extra OBS c smoke run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired c=/x=).
std_encoding_extra_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_ENCODING_EXTRA_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
