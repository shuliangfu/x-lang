#!/usr/bin/env bash
# std-crypto.sh — STD-006: std.crypto / std.random helpers (false-authority honesty)
#
# Usage (after source):
#   std_crypto_has_api MOD_X fn_name
#   std_crypto_run_smoke XLANG_BIN smoke_x [tag]
#   std_crypto_run_hook XLANG_BIN tests/run-*.sh
#   std_crypto_emit_report status check_ok sha256_ok hmac_ok mem_eq_ok rand_ok main_ok mac_ok skip
#
# Prefer product asm + RUN_XLANG (after gate pins XLANG_LINK_XLANG).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_CRYPTO_PREFIX="${XLANG_STD_CRYPTO_PREFIX:-xlang: [XLANG_STD_CRYPTO]}"

# Check mod.x exports the named function.
std_crypto_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# Compile and run smoke .x; expect exit 0.
# Prefer RUN_XLANG (after gate pins XLANG_LINK_XLANG) so Darwin does not
# silently remap asm→c. Falls back to direct XLANG_BIN -L . -o.
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
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-crypto FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-crypto FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
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

# True iff the binary is executable for this host.
std_crypto_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# Prefer product asm; pin path used by gate via XLANG_LINK_XLANG.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
std_crypto_resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if std_crypto_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
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
std_crypto_ensure_runtime_glue_o() {
  # shellcheck source=tests/lib/build-std-c-o.sh
  . "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/build-std-c-o.sh"
  ensure_runtime_ed25519_ref10_glue_o
  ensure_runtime_crypto_inc_glue_o
}

# Structured report (honesty: check=/sha256=/hmac=/mem_eq=/rand=/main=/mac=/skip=).
# Hard-green = sha256+hmac+mem_eq+rand+main; check + mac observational
# (mac_verify product link UNDEF residual — not soft).
std_crypto_emit_report() {
  local status="$1"
  local check_ok="$2"
  local sha256_ok="$3"
  local hmac_ok="$4"
  local mem_eq_ok="$5"
  local rand_ok="$6"
  local main_ok="$7"
  local mac_ok="$8"
  local skip="$9"
  echo "${STD_CRYPTO_PREFIX} status=${status} check=${check_ok} sha256=${sha256_ok} hmac=${hmac_ok} mem_eq=${mem_eq_ok} rand=${rand_ok} main=${main_ok} mac=${mac_ok} skip=${skip}"
}
