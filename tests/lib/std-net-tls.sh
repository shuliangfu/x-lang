#!/usr/bin/env bash
# std-net-tls.sh — STD-030/083：TLS manifest 与烟测辅助
#
# 用法（source 后）：
#   std_net_tls_symbols_ok MOD_SU NET_C TSV
#   std_net_tls_run_smoke SHUX_BIN SU TAG
#   std_net_tls_emit_report status stub_ok typeck_ok skip

STD_NET_TLS_PREFIX="${SHUX_STD_NET_TLS_PREFIX:-shux: [SHUX_STD_NET_TLS]}"

# 校验 manifest symbol/api/file；echo 缺失数。
std_net_tls_symbols_ok() {
  local mod_su="$1"
  local net_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-net-tls FAIL: missing api '$anchor' in $mod_su" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol|const_not_impl)
        local target="$mod_su"
        case "$mod_path" in
          std/net/net.c) target="$net_c" ;;
          std/net/tls_stub.inc.c|std/net/tls_openssl.inc.c) target="$mod_path" ;;
          *) [ -n "${mod_path:-}" ] && target="$mod_path" ;;
        esac
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "std-net-tls FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-net-tls FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行烟测 .sx（须已 ensure net.o）。
std_net_tls_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_net_tls_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-net-tls FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-net-tls FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-net-tls FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 探测本机是否可链 OpenSSL（libssl）。
std_net_tls_probe_openssl() {
  local out="/tmp/shux_net_tls_ssl_probe_$$"
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

# OpenSSL 编译/链接 flags（Homebrew 回退）。
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

# 探测本机是否可链 mbedTLS。
std_net_tls_probe_mbedtls() {
  local out="/tmp/shux_net_tls_mb_probe_$$"
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

# mbedTLS 链接 flags。
std_net_tls_mbedtls_ldflags() {
  echo "-I/opt/homebrew/opt/mbedtls/include -L/opt/homebrew/opt/mbedtls/lib -lmbedtls -lmbedx509 -lmbedcrypto"
}

# 构建 net.o（mbedTLS TLS）。
std_net_tls_build_mbedtls_o() {
  if ! make -C compiler net-o-mbedtls >/dev/null 2>&1; then
    echo "std-net-tls FAIL: make net-o-mbedtls" >&2
    return 1
  fi
  return 0
}

# 构建 net.o（OpenSSL TLS）。
std_net_tls_build_openssl_o() {
  if ! make -C compiler net-o-openssl >/dev/null 2>&1; then
    echo "std-net-tls FAIL: make net-o-openssl" >&2
    return 1
  fi
  return 0
}

# 恢复 stub net.o。
std_net_tls_restore_stub_o() {
  make -C compiler net-o-stub >/dev/null 2>&1 || make -C compiler ../std/net/net.o >/dev/null 2>&1 || true
}

# 启动 openssl s_server 于 127.0.0.1:PORT；echo pid > $1。
std_net_tls_start_s_server() {
  local pid_file="$1"
  local port="$2"
  local cert="$3"
  local key="$4"
  local log="/tmp/shux_tls_s_server_$$.log"
  openssl s_server -accept "$port" -cert "$cert" -key "$key" -www \
    >/dev/null 2>"$log" &
  echo $! >"$pid_file"
  sleep 0.4
  if ! kill -0 "$(cat "$pid_file")" 2>/dev/null; then
    echo "std-net-tls FAIL: s_server start" >&2
    tail -5 "$log" 2>/dev/null >&2 || true
    return 1
  fi
  return 0
}

# 停止 s_server。
std_net_tls_stop_s_server() {
  local pid_file="$1"
  if [ -f "$pid_file" ]; then
    kill "$(cat "$pid_file")" 2>/dev/null || true
    rm -f "$pid_file"
  fi
}

# C 烟测：tls_openssl_smoke_ok.c + net.o(OpenSSL) + libssl。
std_net_tls_run_openssl_c_smoke() {
  local src="tests/net/tls_openssl_smoke_ok.c"
  local out="/tmp/shux_net_tls_openssl_$$"
  local net_o="std/net/net.o"
  local ldflags
  ldflags="$(std_net_tls_openssl_ldflags)"
  if [ ! -f "$net_o" ]; then
    echo "std-net-tls FAIL: missing $net_o" >&2
    return 1
  fi
  # shellcheck disable=SC2086
  if ! cc -std=c11 -O1 -o "$out" "$src" "$net_o" std/io/io.o $ldflags 2>/dev/null; then
    echo "std-net-tls FAIL: compile openssl smoke" >&2
    return 1
  fi
  SHUX_TLS_SMOKE_PORT="${SHUX_TLS_SMOKE_PORT:-9876}" "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-net-tls FAIL: openssl smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# C 烟测：tls_mbedtls_smoke_ok.c + net.o(mbedTLS) + libmbedtls。
std_net_tls_run_mbedtls_c_smoke() {
  local src="tests/net/tls_mbedtls_smoke_ok.c"
  local out="/tmp/shux_net_tls_mbedtls_$$"
  local net_o="std/net/net.o"
  local ldflags
  ldflags="$(std_net_tls_mbedtls_ldflags)"
  if [ ! -f "$net_o" ]; then
    echo "std-net-tls FAIL: missing $net_o" >&2
    return 1
  fi
  # shellcheck disable=SC2086
  if ! cc -std=c11 -O1 -o "$out" "$src" "$net_o" std/io/io.o $ldflags 2>/dev/null; then
    echo "std-net-tls FAIL: compile mbedtls smoke" >&2
    return 1
  fi
  SHUX_TLS_SMOKE_PORT="${SHUX_TLS_SMOKE_PORT:-9876}" "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-net-tls FAIL: mbedtls smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 通过 shux-c 链接 OpenSSL net.o 并验证 tls_is_available（runtime 自动 -lssl）。
std_net_tls_runtime_link_smoke() {
  local shux="$1"
  local src="tests/net/tls_runtime_link_smoke.sx"
  local exe="/tmp/shux_net_tls_runtime_$$"
  if [ ! -f "$src" ]; then
    echo "std-net-tls FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-net-tls FAIL: runtime link compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-net-tls FAIL: runtime link run exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_net_tls_emit_report() {
  local status="$1"
  local stub_ok="$2"
  local typeck_ok="$3"
  local skip="$4"
  local openssl_ok="${5:-0}"
  local mbedtls_ok="${6:-0}"
  local runtime_link_ok="${7:-0}"
  echo "${STD_NET_TLS_PREFIX} status=${status} stub=${stub_ok} typeck=${typeck_ok} skip=${skip} openssl=${openssl_ok} mbedtls=${mbedtls_ok} runtime_link=${runtime_link_ok}"
}
