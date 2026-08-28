#!/usr/bin/env bash
# std-compress.sh — STD-007 gzip/zstd/legacy helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_compress_has_api MOD fn
#   std_compress_symbols_ok MOD_X TSV
#   std_compress_run_smoke XLANG_BIN SRC [TAG]
#   std_compress_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft std_compress_try_libs
# / XLANG fallthrough; report run=/obs=/skip= (retired check=/gzip=/zstd=/legacy=).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_COMPRESS_PREFIX="${XLANG_STD_COMPRESS_PREFIX:-xlang: [XLANG_STD_COMPRESS]}"

# Check mod.x exports the named function.
std_compress_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# Validate manifest; echo miss count; return 0 iff miss==0.
# Kinds: api / section / layers / file / cross_ref / target / script /
# hook_script / smoke. Full-path TSV anchors preferred.
# PLATFORM: SHARED archaeology — inventory only; do not invoke make.
std_compress_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor src _tier notes path
  local doc="${XLANG_STD_COMPRESS_DOC:-analysis/archive/std/std-compress-v1.md}"
  while IFS=$'\t' read -r item_id kind anchor src _tier notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! std_compress_has_api "$mod_x" "$anchor"; then
          echo "std-compress FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        elif [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-compress FAIL: doc missing API '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|layers)
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-compress FAIL: missing $kind '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|cross_ref)
        path="${src:-$anchor}"
        if [ ! -f "$path" ]; then
          echo "std-compress FAIL: missing file '$path'" >&2
          miss=$((miss + 1))
        fi
        ;;
      target)
        # Post-MF phys-del: compress-o-* live as hub no-ops in compiler-make.sh.
        # Inventory grep only — refuse xlang_compiler_make / try_libs.
        path="${src:-tests/lib/compiler-make.sh}"
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-compress FAIL: missing hub phony '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      script|hook_script)
        path="$anchor"
        if [ ! -f "$path" ]; then
          path="${src:-}"
        fi
        if [ ! -f "$path" ]; then
          path="tests/$anchor"
        fi
        if [ ! -f "$path" ] && [ "$kind" = "script" ] && [ -f "tests/lib/$anchor" ]; then
          path="tests/lib/$anchor"
        fi
        if [ ! -f "$path" ]; then
          echo "std-compress FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-compress FAIL: missing smoke '$anchor'" >&2
          miss=$((miss + 1))
        elif [ ! -f "$doc" ] || ! grep -qF "$(basename "$anchor")" "$doc" 2>/dev/null; then
          echo "std-compress FAIL: doc missing smoke '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Product tip -o smoke. Caller decides hard vs obs (tip UNDEF/SEGV = obs leave).
# PLATFORM: SHARED archaeology — product honesty path.
# Do not restore set -e between steps: return 1 must not trip the gate's set -e.
# Refuse RUN_XLANG / bootstrap-link remap (Darwin must not silently asm→c).
std_compress_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_compress_${tag}_$$"
  local log="/tmp/xlang_std_compress_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-compress FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-compress OBS tip product -o $src (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-compress OBS tip run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired check=/gzip=/zstd=/legacy=).
std_compress_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_COMPRESS_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
