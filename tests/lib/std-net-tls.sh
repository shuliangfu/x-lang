#!/usr/bin/env bash
# std-net-tls.sh — STD-030/083 TLS manifest helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_net_tls_symbols_ok MOD_X TLS_STUB_X TSV
#   std_net_tls_run_smoke XLANG_BIN SRC TAG
#   std_net_tls_run_openssl_c_smoke   # prebuilt .o only
#   std_net_tls_run_mbedtls_c_smoke   # prebuilt .o only
#   std_net_tls_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure / soft net-o-*; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_NET_TLS_PREFIX="${XLANG_STD_NET_TLS_PREFIX:-xlang: [XLANG_STD_NET_TLS]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_net_tls_symbols_ok() {
  local mod_x="$1"
  local net_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-net-tls FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol|const_not_impl)
        local target="$mod_x"
        case "$mod_path" in
          std/net/net.c) target="${net_c:-std/net/tls_stub.x}" ;;
          std/net/tls_stub.x|std/net/tls_openssl.x|std/net/tls_mbedtls.x) target="$mod_path" ;;
          *) [ -n "${mod_path:-}" ] && target="$mod_path" ;;
        esac
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "std-net-tls FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD_NET_TLS_DOC:-analysis/archive/std/std-net-tls-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-net-tls FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-net-tls FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-net-tls FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "std-net-tls FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Product tip -o smoke. Caller decides hard vs obs (tip typeck/UNDEF = obs leave).
# PLATFORM: SHARED archaeology — product honesty path.
std_net_tls_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_net_tls_${tag}_$$"
  local log="/tmp/xlang_std_net_tls_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-net-tls FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  # Do not restore set -e between steps: return 1 must not trip the gate's set +e window.
  # PLATFORM: SHARED archaeology.
  set +e
  XLANG_NET_TLS="${XLANG_NET_TLS:-stub}" "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-net-tls OBS tip product -o (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-net-tls OBS tip run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Probe whether the host can link OpenSSL (libssl).
# PLATFORM: SHARED — Darwin Homebrew / Ubuntu libssl-dev.
std_net_tls_probe_openssl() {
  local out="/tmp/xlang_net_tls_ssl_probe_$$"
  if cc -std=c11 -x c - -lssl -lcrypto -o "$out" 2>/dev/null <<'EOF'
#include <openssl/ssl.h>
int main(void) { return OPENSSL_init_ssl(0, NULL) ? 0 : 1; }
EOF
  then
    rm -f "$out"
    return 0
  fi
  if cc -std=c11 -I/opt/homebrew/opt/openssl/include -L/opt/homebrew/opt/openssl/lib \
    -x c - -lssl -lcrypto -o "$out" 2>/dev/null <<'EOF'
#include <openssl/ssl.h>
int main(void) { return OPENSSL_init_ssl(0, NULL) ? 0 : 1; }
EOF
  then
    rm -f "$out"
    return 0
  fi
  rm -f "$out"
  return 1
}

# OpenSSL compile/link flags (Homebrew fallback).
std_net_tls_openssl_ldflags() {
  if cc -std=c11 -x c - -lssl -lcrypto -o /dev/null 2>/dev/null <<'EOF'
#include <openssl/ssl.h>
int main(void) { return 0; }
EOF
  then
    echo "-lssl -lcrypto"
    return 0
  fi
  echo "-I/opt/homebrew/opt/openssl/include -L/opt/homebrew/opt/openssl/lib -lssl -lcrypto"
}

# Probe whether the host can link mbedTLS.
# PLATFORM: SHARED — optional; Darwin Homebrew common.
std_net_tls_probe_mbedtls() {
  local out="/tmp/xlang_net_tls_mb_probe_$$"
  if cc -std=c11 -I/opt/homebrew/opt/mbedtls/include -L/opt/homebrew/opt/mbedtls/lib \
    -x c - -lmbedtls -lmbedx509 -lmbedcrypto -o "$out" 2>/dev/null <<'EOF'
#include "mbedtls/ssl.h"
#include "psa/crypto.h"
int main(void) {
  mbedtls_ssl_context s;
  mbedtls_ssl_init(&s);
  mbedtls_ssl_free(&s);
  return psa_crypto_init() == PSA_SUCCESS ? 0 : 1;
}
EOF
  then
    rm -f "$out"
    return 0
  fi
  rm -f "$out"
  return 1
}

# mbedTLS link flags.
std_net_tls_mbedtls_ldflags() {
  echo "-I/opt/homebrew/opt/mbedtls/include -L/opt/homebrew/opt/mbedtls/lib -lmbedtls -lmbedx509 -lmbedcrypto"
}

# Start openssl s_server on 127.0.0.1:PORT; echo pid > $1.
# PLATFORM: SHARED archaeology — optional host-C handshake helper.
std_net_tls_start_s_server() {
  local pid_file="$1"
  local port="$2"
  local cert="$3"
  local key="$4"
  local log="/tmp/xlang_tls_s_server_$$.log"
  openssl s_server -accept "$port" -cert "$cert" -key "$key" -www \
    >/dev/null 2>"$log" &
  echo $! >"$pid_file"
  sleep 0.4
  if ! kill -0 "$(cat "$pid_file")" 2>/dev/null; then
    echo "std-net-tls OBS s_server start" >&2
    tail -5 "$log" 2>/dev/null >&2 || true
    return 1
  fi
  return 0
}

# Stop s_server.
std_net_tls_stop_s_server() {
  local pid_file="$1"
  if [ -f "$pid_file" ]; then
    kill "$(cat "$pid_file")" 2>/dev/null || true
    rm -f "$pid_file"
  fi
}

# Host-C archaeology: prebuilt tls_openssl.o + net.o only. Refuse soft net-o-openssl.
# Returns 0 green, 1 link/run fail, 2 missing prebuilt .o.
# PLATFORM: SHARED — do not soft rebuild.
std_net_tls_run_openssl_c_smoke() {
  local src="tests/net/tls_openssl_smoke_ok.c"
  local out="/tmp/xlang_net_tls_openssl_$$"
  local tls_o="std/net/tls_openssl.o"
  local net_o="std/net/net.o"
  local ldflags
  ldflags="$(std_net_tls_openssl_ldflags)"
  if [ ! -f "$tls_o" ] || [ ! -f "$net_o" ]; then
    echo "std-net-tls OBS openssl c smoke (missing prebuilt .o; refuse soft auto-make)" >&2
    return 2
  fi
  # shellcheck disable=SC2086
  if ! cc -std=c11 -O1 -o "$out" "$src" "$tls_o" "$net_o" $ldflags 2>/tmp/std_net_tls_ossl_$$.log; then
    echo "std-net-tls OBS openssl c smoke link (refuse soft ensure)" >&2
    return 1
  fi
  # Do not restore set -e here: return 1 must not trip the gate's set +e window.
  # PLATFORM: SHARED archaeology.
  set +e
  XLANG_TLS_SMOKE_PORT="${XLANG_TLS_SMOKE_PORT:-9876}" "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-net-tls OBS openssl c smoke run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Host-C archaeology: prebuilt tls_mbedtls.o + net.o only. Refuse soft net-o-mbedtls.
# Returns 0 green, 1 link/run fail, 2 missing prebuilt .o.
# PLATFORM: SHARED — do not soft rebuild.
std_net_tls_run_mbedtls_c_smoke() {
  local src="tests/net/tls_mbedtls_smoke_ok.c"
  local out="/tmp/xlang_net_tls_mbedtls_$$"
  local tls_o="std/net/tls_mbedtls.o"
  local net_o="std/net/net.o"
  local ldflags
  ldflags="$(std_net_tls_mbedtls_ldflags)"
  if [ ! -f "$tls_o" ] || [ ! -f "$net_o" ]; then
    echo "std-net-tls OBS mbedtls c smoke (missing prebuilt .o; refuse soft auto-make)" >&2
    return 2
  fi
  # shellcheck disable=SC2086
  if ! cc -std=c11 -O1 -o "$out" "$src" "$tls_o" "$net_o" $ldflags 2>/tmp/std_net_tls_mb_$$.log; then
    echo "std-net-tls OBS mbedtls c smoke link (refuse soft ensure)" >&2
    return 1
  fi
  # Do not restore set -e here: return 1 must not trip the gate's set +e window.
  # PLATFORM: SHARED archaeology.
  set +e
  XLANG_TLS_SMOKE_PORT="${XLANG_TLS_SMOKE_PORT:-9876}" "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-net-tls OBS mbedtls c smoke run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired stub=/typeck=/openssl=).
std_net_tls_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_NET_TLS_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
