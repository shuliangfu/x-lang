#!/usr/bin/env bash
# STD-034: std.http HTTPS client gate — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft ensure_std_c_o / soft auto-make + check=/run=/skip= retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make / prefer-c / soft ensure).
# Product https_smoke.x -o exit0 = hard run (run=1). check / host-C stub /
# OpenSSL live probe = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-http-https-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_HTTP_HTTPS_DOC:-analysis/archive/std/std-http-https-v1.md}"
MANIFEST="${XLANG_STD_HTTP_HTTPS_TSV:-tests/baseline/std-http-https.tsv}"
MOD_X="std/http/mod.x"
HTTP_C="compiler/seeds/runtime_http_glue.from_x.c"
TLS_BRIDGE="compiler/seeds/http/http_tls_bridge.inc"
LIB="tests/lib/std-http-https.sh"
SMOKE_X="tests/http/https_smoke.x"
SMOKE_C="tests/http/https_smoke_ok.c"
README="std/http/README.md"
MIN_APIS=2

# shellcheck source=tests/lib/std-http-https.sh
. "$LIB"
# shellcheck source=tests/lib/std-net-tls.sh
. tests/lib/std-net-tls.sh

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-http-https gate FAIL: $*" >&2
  std_http_https_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-034: http https manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$HTTP_C" "$TLS_BRIDGE" \
  "$SMOKE_X" "$SMOKE_C" "$README"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-HTTP-HTTPS https_is_available err_tls_not_impl https:// TLS net_tls; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"
grep -qF "https://" "$README" 2>/dev/null || die "README missing https"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
      ;;
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_http_https_symbols_ok "$MOD_X" "$HTTP_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-http-https manifest OK"

if [ "${XLANG_STD_HTTP_HTTPS_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_http_https_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-http-https gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# PLATFORM: MACOS — Homebrew OpenSSL/lib path for optional host TLS deps.
if [ "$(uname -s)" = "Darwin" ] && [ -d /opt/homebrew/lib ]; then
  export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
fi
echo "=== STD-034: smoke (XLANG=$XLANG_BIN; check/host-C/OpenSSL obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std034_https_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-http-https OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft ensure_std_c_o / soft auto-make (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
if std_http_https_run_smoke "$XLANG_BIN" "$SMOKE_X" "https_smoke"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-http-https OK: product -o"
else
  die "product -o failed (refuse soft SKIP→OK)"
fi

# Observational C stub / OpenSSL probes (never hard-green; existing .o only).
# PLATFORM: SHARED — host TLS optional; stub offline path covered by .x smoke.
HTTP_O="std/http/http.o"
if [ -f "$HTTP_O" ] && cc -std=c11 -O1 -o /tmp/xlang_http_https_stub_$$ "$SMOKE_C" "$HTTP_O" 2>/dev/null; then
  if /tmp/xlang_http_https_stub_$$ >/dev/null 2>&1; then
    echo "std-http-https c stub OK (observational)"
  else
    echo "std-http-https OBS c stub run (host-C archaeology)" >&2
    OBS=$((OBS + 1))
  fi
  rm -f /tmp/xlang_http_https_stub_$$
else
  echo "std-http-https OBS c stub (host-C archaeology; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
fi

if std_net_tls_probe_openssl; then
  TLS_PORT="${XLANG_HTTPS_SMOKE_PORT:-9888}"
  TLS_CERT="/tmp/xlang_https_cert_$$.pem"
  TLS_KEY="/tmp/xlang_https_key_$$.pem"
  TLS_PID="/tmp/xlang_https_spid_$$"
  OPENSSL_OK=0
  if openssl req -x509 -newkey rsa:2048 -keyout "$TLS_KEY" -out "$TLS_CERT" -days 1 -nodes \
    -subj "/CN=localhost" 2>/dev/null; then
    if std_net_tls_build_openssl_o && std_net_tls_start_s_server "$TLS_PID" "$TLS_PORT" "$TLS_CERT" "$TLS_KEY"; then
      NET_O="std/net/net.o"
      export XLANG_HTTPS_SMOKE_PORT="$TLS_PORT"
      ldflags="$(std_net_tls_openssl_ldflags)"
      if [ -f "$HTTP_O" ] && [ -f "$NET_O" ] && std_http_https_run_c_smoke "$HTTP_O" "$NET_O" "$ldflags"; then
        OPENSSL_OK=1
        echo "std-http-https openssl OK (observational)"
      fi
      std_net_tls_stop_s_server "$TLS_PID"
    fi
  fi
  rm -f "$TLS_CERT" "$TLS_KEY"
  std_net_tls_restore_stub_o 2>/dev/null || true
  if [ "$OPENSSL_OK" -eq 0 ]; then
    echo "std-http-https OBS openssl (host-TLS archaeology; refuse soft ensure)" >&2
    OBS=$((OBS + 1))
  fi
else
  echo "std-http-https OBS openssl probe (no openssl; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

std_http_https_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-http-https gate OK"
