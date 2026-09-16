#!/usr/bin/env bash
# std-crypto.sh — STD-006: std.crypto / std.random helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_crypto_has_api MOD_X fn_name
#   std_crypto_resolve_shu
#   std_crypto_run_smoke XLANG_BIN smoke_x [tag]
#   std_crypto_run_hook XLANG_BIN tests/run-*.sh
#   std_crypto_emit_report status run obs skip
#   std_crypto_resolve_impl_path / std_crypto_o_has_x_symbols / std_crypto_c_link_objs
#
# Honesty: refuse soft auto-make / soft SKIP→OK / prefer-c / XLANG
# fallthrough; report run=/obs=/skip=. Product -o via std_crypto_run_smoke
# (G.7: do not fork). Native exe check converges on dod_native_exe.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_CRYPTO_PREFIX="${XLANG_STD_CRYPTO_PREFIX:-xlang: [XLANG_STD_CRYPTO]}"

# shellcheck source=tests/lib/dod-native-exe.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/dod-native-exe.sh"

# Check mod.x exports the named function.
std_crypto_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# G.7: native exe check converges on dod_native_exe (single authority).
# Thin wrapper for any leftover callers; resolve_shu uses dod_native_exe.
std_crypto_native_xlang() {
  dod_native_exe "$1"
}

# Prefer product asm; refuse prefer-c / soft auto-make / XLANG fallthrough.
# Explicit XLANG that is missing or non-native returns 1 (caller hard-dies).
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
std_crypto_resolve_shu() {
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
# Caller decides hard vs obs (sha256/hmac/mem_eq/rand/main = hard;
# mac_verify product UNDEF = obs leave).
# Do not restore set -e before return 1.
# PLATFORM: SHARED archaeology — product honesty path.
std_crypto_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_crypto_${tag}_$$"
  local log="/tmp/xlang_std_crypto_build_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-crypto FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-crypto FAIL: compile $src" >&2
    tail -12 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-crypto FAIL: $tag exit=$ec ($src)" >&2
    return 1
  fi
  return 0
}

# Run hook script (run-crypto.sh / run-random.sh). Observational at gate.
std_crypto_run_hook() {
  local xlang="$1"
  local hook="$2"
  if [ ! -f "$hook" ]; then
    echo "std-crypto FAIL: missing hook $hook" >&2
    return 1
  fi
  chmod +x "$hook" 2>/dev/null || true
  XLANG="$xlang" "$hook"
}

# crypto.o whether core.x symbols are linked (no xlang-c → glue-only).
std_crypto_o_has_x_symbols() {
  local o="$1"
  nm "$o" 2>/dev/null | grep -qE ' crypto_(mem_eq_c|sha256_c|hmac_sha256_c)$'
}

# manifest mod_path → real source (sha256 in .x; sha512/AEAD in runtime glue).
std_crypto_resolve_impl_path() {
  local mod_path="$1"
  case "$mod_path" in
    std/crypto/crypto.c|std/crypto/core.x) echo "std/crypto/core.x" ;;
    std/crypto/crypto_inc_glue.c|compiler/seeds/runtime_crypto_inc_glue.from_x.c)
      echo "compiler/seeds/runtime_crypto_inc_glue.from_x.c"
      ;;
    std/crypto/ed25519.x|std/crypto/ed25519.inc.c|std/crypto/aes_gcm.x|std/crypto/chacha20_poly1305.x|std/crypto/chacha20_aead.x)
      echo "std/crypto/$(basename "$mod_path")"
      ;;
    std/crypto/ed25519_ref10_glue.c|compiler/seeds/runtime_ed25519_ref10_glue.from_x.c)
      echo "compiler/seeds/runtime_ed25519_ref10_glue.from_x.c"
      ;;
    *) echo "$mod_path" ;;
  esac
}

# F-ZC: crypto C smoke must link crypto.o + runtime glue (ref10 before inc).
std_crypto_c_link_objs() {
  echo "std/crypto/crypto.o compiler/runtime_ed25519_ref10_glue.o compiler/runtime_crypto_inc_glue.o"
}

# Ensure crypto runtime glue .o objects are built.
# Leave: main STD-006 gate must not call this (refuse soft auto-make).
std_crypto_ensure_runtime_glue_o() {
  # shellcheck source=tests/lib/build-std-c-o.sh
  . "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/build-std-c-o.sh"
  ensure_runtime_ed25519_ref10_glue_o
  ensure_runtime_crypto_inc_glue_o
}

# Structured report (honesty: run=/obs=/skip=; retired check=/sha256=/hmac=).
# Hard-green = sha256+hmac+mem_eq+rand+main product -o; check + mac + hooks obs
# (mac_verify product link UNDEF residual — not soft).
std_crypto_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_CRYPTO_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
