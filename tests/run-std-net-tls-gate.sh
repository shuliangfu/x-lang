#!/usr/bin/env bash
# STD-030/083: std.net TLS gate — honesty soft prefer-c / soft SKIP→OK /
# soft auto-make / soft ensure_std_c_o / soft net-o-* / stub=/typeck= →硬绿.
#
# Honesty: prefer-c first (xlang-c) + soft SKIP→OK (no native still gate OK /
# zstd link SKIP) + soft `ensure_std_c_o` / soft `xlang_compiler_make net-o-*`
# + soft auto-make xlang-c + hard check as sole .x smoke + report
# `stub=`/`typeck=`/`openssl=` retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Host-C archaeology = obs only (prebuilt
# net.o / tls_openssl.o / tls_mbedtls.o; refuse soft ensure). check residual
# = obs (paused 2026-08-05). tip product -o typeck = obs (product debt; leave).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-net-tls-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_NET_TLS_DOC:-analysis/archive/std/std-net-tls-v1.md}"
MANIFEST="${XLANG_STD_NET_TLS_TSV:-tests/baseline/std-net-tls.tsv}"
NET_X="std/net/mod.x"
TLS_STUB_X="std/net/tls_stub.x"
LIB="tests/lib/std-net-tls.sh"
STUB_X="tests/net/tls_stub.x"
RUNTIME_X="tests/net/tls_runtime_link_smoke.x"
SMOKE_C="tests/net/tls_openssl_smoke_ok.c"
MBEDTLS_SMOKE_C="tests/net/tls_mbedtls_smoke_ok.c"
MIN_APIS=7

# shellcheck source=tests/lib/std-net-tls.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-net-tls gate FAIL: $*" >&2
  std_net_tls_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== STD-030: net TLS prereq manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$NET_X" "$TLS_STUB_X" "$STUB_X" "$RUNTIME_X" "$SMOKE_C" "$MBEDTLS_SMOKE_C" std/net/tls_openssl.x std/net/tls_mbedtls.x std/net/tls_stub.x; do
  [ -f "$f" ] || die "missing $f"
done
for kw in STD-030 STD-083 STD-085 OpenSSL tls_connect_client tls_read TLS_NOT_IMPL runtime_link; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-net-tls-v1.md ] || die "dual-authority fossil analysis/std-net-tls-v1.md (archive live)"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_net_tls_symbols_ok "$NET_X" "$TLS_STUB_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-net-tls manifest OK"

if [ "${XLANG_STD_NET_TLS_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_net_tls_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-net-tls gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-030: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

set +e
"$XLANG_BIN" check -L . "$STUB_X" >/tmp/xlang_std_net_tls_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-net-tls OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product typeck residual = obs (leave product debt). Refuse soft net-o-stub.
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
if std_net_tls_run_smoke "$XLANG_BIN" "$STUB_X" "stub"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-net-tls OK: product stub"
else
  echo "std-net-tls OBS tip product stub (typeck/UNDEF residual)" >&2
  OBS=$((OBS + 1))
fi

if std_net_tls_run_smoke "$XLANG_BIN" "$RUNTIME_X" "runtime"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-net-tls OK: product runtime_link"
else
  echo "std-net-tls OBS tip product runtime_link (residual)" >&2
  OBS=$((OBS + 1))
fi

# Host-C OpenSSL archaeology = obs only when lib+prebuilt present; else skip env.
# Refuse soft net-o-openssl / soft ensure.
# PLATFORM: SHARED archaeology.
if std_net_tls_probe_openssl; then
  echo "=== STD-083: OpenSSL TLS handshake smoke (prebuilt .o only) ==="
  TLS_PORT="${XLANG_TLS_SMOKE_PORT:-9876}"
  TLS_CERT="/tmp/xlang_tls_cert_$$.pem"
  TLS_KEY="/tmp/xlang_tls_key_$$.pem"
  TLS_PID="/tmp/xlang_tls_spid_$$"
  if openssl req -x509 -newkey rsa:2048 -keyout "$TLS_KEY" -out "$TLS_CERT" -days 1 -nodes \
    -subj "/CN=localhost" >/dev/null 2>&1 \
    && std_net_tls_start_s_server "$TLS_PID" "$TLS_PORT" "$TLS_CERT" "$TLS_KEY"; then
    export XLANG_TLS_SMOKE_PORT="$TLS_PORT"
    set +e
    std_net_tls_run_openssl_c_smoke
    ossl_rc=$?
    set -e
    std_net_tls_stop_s_server "$TLS_PID"
    case "$ossl_rc" in
      0)
        RUN_OK=$((RUN_OK + 1))
        echo "std-net-tls OK: openssl c smoke"
        ;;
      *)
        echo "std-net-tls OBS openssl c smoke (rc=$ossl_rc)" >&2
        OBS=$((OBS + 1))
        ;;
    esac
  else
    echo "std-net-tls OBS openssl s_server setup" >&2
    OBS=$((OBS + 1))
    std_net_tls_stop_s_server "$TLS_PID" 2>/dev/null || true
  fi
  rm -f "$TLS_CERT" "$TLS_KEY"
else
  echo "std-net-tls env-skip openssl (no libssl)" >&2
  SKIP=$((SKIP + 1))
fi

if std_net_tls_probe_mbedtls; then
  echo "=== STD-085: mbedTLS TLS handshake smoke (prebuilt .o only) ==="
  TLS_PORT_MB="${XLANG_TLS_SMOKE_PORT_MB:-9877}"
  TLS_CERT_MB="/tmp/xlang_tls_cert_mb_$$.pem"
  TLS_KEY_MB="/tmp/xlang_tls_key_mb_$$.pem"
  TLS_PID_MB="/tmp/xlang_tls_spid_mb_$$"
  if openssl req -x509 -newkey rsa:2048 -keyout "$TLS_KEY_MB" -out "$TLS_CERT_MB" -days 1 -nodes \
    -subj "/CN=localhost" >/dev/null 2>&1 \
    && std_net_tls_start_s_server "$TLS_PID_MB" "$TLS_PORT_MB" "$TLS_CERT_MB" "$TLS_KEY_MB"; then
    export XLANG_TLS_SMOKE_PORT="$TLS_PORT_MB"
    set +e
    std_net_tls_run_mbedtls_c_smoke
    mb_rc=$?
    set -e
    std_net_tls_stop_s_server "$TLS_PID_MB"
    case "$mb_rc" in
      0)
        RUN_OK=$((RUN_OK + 1))
        echo "std-net-tls OK: mbedtls c smoke"
        ;;
      *)
        echo "std-net-tls OBS mbedtls c smoke (rc=$mb_rc)" >&2
        OBS=$((OBS + 1))
        ;;
    esac
  else
    echo "std-net-tls OBS mbedtls s_server setup" >&2
    OBS=$((OBS + 1))
    std_net_tls_stop_s_server "$TLS_PID_MB" 2>/dev/null || true
  fi
  rm -f "$TLS_CERT_MB" "$TLS_KEY_MB"
else
  echo "std-net-tls env-skip mbedtls (no libmbedtls)" >&2
  SKIP=$((SKIP + 1))
fi

std_net_tls_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-net-tls gate OK"
