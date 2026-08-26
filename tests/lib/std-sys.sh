#!/usr/bin/env bash
# std-sys.sh — BOOT-029 manifest and smoke helpers (honesty).
# PLATFORM: SHARED archaeology.

STD_SYS_PREFIX="${XLANG_BOOT029_STD_SYS_PREFIX:-xlang: [XLANG_BOOT029_STD_SYS]}"

# Validate manifest entries; echo missing count.
# @param $1 mod_x — std/sys/mod.x
# @param $2 tsv — baseline manifest
# @param $3 doc — archive DOC path
std_sys_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local doc="$3"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-sys FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="${mod_path:-$mod_x}"
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sys FAIL: missing symbol '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-sys FAIL: doc missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-sys FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        # TSV: anchor may be basename; path column holds tests/run-….sh
        local spath="$anchor"
        if [ -n "${mod_path:-}" ] && [ -f "$mod_path" ]; then
          spath="$mod_path"
        elif [ ! -f "$spath" ] && [ -f "tests/$anchor" ]; then
          spath="tests/$anchor"
        fi
        if [ ! -f "$spath" ]; then
          echo "std-sys FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Run a write smoke and require exact stdout "Hello Xlang!\n" + exit 0.
# @param $1 exe — built executable path
# @param $2 tag — label for error messages
std_sys_expect_hello() {
  local exe="$1"
  local tag="${2:-smoke}"
  local expected
  expected=$(printf 'Hello Xlang!\n')
  set +e
  local out
  out=$("$exe" 2>/dev/null)
  local ec=$?
  set -e
  if [ "$ec" -ne 0 ] || [ "$out" != "$expected" ]; then
    echo "std-sys FAIL: $tag exit=$ec out='$out'" >&2
    return 1
  fi
  return 0
}

# Emit structured report (honesty: check=/run=/skip=; platform notes separate).
# @param $1 status — ok|fail
# @param $2 check_ok
# @param $3 run_ok
# @param $4 skip
std_sys_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_SYS_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
