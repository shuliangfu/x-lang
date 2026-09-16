#!/usr/bin/env bash
# stbl-import-std-layout.sh — STBL-004: import path resolve + DOC section helpers.
#
# Usage (source):
#   stbl_import_std_resolve_probe LIB_ROOT IMPORT EXPECTED_RELPATH
#   stbl_import_std_sections_ok DOC TSV
#   stbl_import_std_resolve_shu
#   stbl_import_std_run_smoke XLANG_BIN smoke_x [tag]
#   stbl_import_std_emit_report status run obs skip
#
# Honesty: refuse soft auto-make / soft SKIP→OK / prefer-c / XLANG
# fallthrough / bootstrap-link remap; report run=/obs=/skip=. Product -o
# via stbl_import_std_run_smoke (G.7: do not fork). Native exe check
# converges on dod_native_exe.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STBL_IMPORT_STD_PREFIX="${XLANG_STBL_IMPORT_STD_PREFIX:-xlang: [XLANG_STBL_IMPORT_STD]}"

# shellcheck source=tests/lib/dod-native-exe.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/dod-native-exe.sh"

# Depends on TOOL-007 resolve subset (caller must source tests/lib/tool-pkgmgr.sh).
stbl_import_std_resolve_probe() {
  local lib_root="$1"
  local import_path="$2"
  local expected="$3"
  local got

  if ! got="$(tool_pkg_resolve_import "$lib_root" "$import_path")"; then
    echo "stbl-import-std FAIL: cannot resolve '$import_path' under '$lib_root'" >&2
    return 1
  fi
  # tool_pkg_resolve_import may return a ./ prefix; align with manifest relpath.
  case "$got" in
    ./*) got="${got#./}" ;;
  esac
  if [ "$got" != "$expected" ]; then
    echo "stbl-import-std FAIL: $import_path -> '$got' (want '$expected')" >&2
    return 1
  fi
  return 0
}

# Verify RFC contains every TSV section / cross_ref anchor; echo miss count.
stbl_import_std_sections_ok() {
  local doc="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _expected _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*|min_*|resolve_*|cross_*|smoke|lib|gate) continue ;;
    esac
    case "$kind" in
      section)
        if ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "stbl-import-std FAIL: doc missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "stbl-import-std FAIL: missing cross_ref '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# G.7: native exe check converges on dod_native_exe (single authority).
stbl_import_std_native_xlang() {
  dod_native_exe "$1"
}

# Prefer product asm; refuse prefer-c / soft auto-make / XLANG fallthrough.
# Explicit XLANG that is missing or non-native returns 1 (caller hard-dies).
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
stbl_import_std_resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

# Compile and run smoke .x; expect exit 0.
# Refuse RUN_XLANG / bootstrap-link remap (Darwin must not silently asm→c).
# Do not restore set -e before return 1.
# PLATFORM: SHARED archaeology — product honesty path.
stbl_import_std_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_stbl004_${tag}_$$"
  local log="/tmp/xlang_stbl004_build_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "stbl-import-std FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "stbl-import-std FAIL: compile $src" >&2
    tail -12 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "stbl-import-std FAIL: $tag exit=$ec ($src)" >&2
    return 1
  fi
  return 0
}

# Emit structured report line (status=/run=/obs=/skip=).
# PLATFORM: SHARED archaeology — honesty contract shared with other soft gates.
stbl_import_std_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STBL_IMPORT_STD_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
