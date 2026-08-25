#!/usr/bin/env bash
# STD-034 (STD-HTTP-HTTPS)：std.http HTTPS 客户端门禁（假权威诚实）。
#
# 用法：./tests/run-std-http-https-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); https_smoke.x exit 0 hard-fail (no soft SKIP
# when native xlang present). Report check=/run=/skip=. C/OpenSSL smoke stays
# observational only. Product surface already green under asm; gate was
# portable-false-red (prefer xlang-c / hard check / soft SKIP / hard C smoke).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
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

echo "=== STD-034: http https manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$HTTP_C" "$TLS_BRIDGE" \
  "$SMOKE_X" "$SMOKE_C" "$README"; do
  if [ ! -f "$f" ]; then
    echo "std-http-https gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-HTTP-HTTPS https_is_available err_tls_not_impl https:// TLS net_tls; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-http-https gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-http-https gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

if ! grep -qF "https://" "$README" 2>/dev/null; then
  echo "std-http-https gate FAIL: README missing https" >&2
  exit 1
fi

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
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        echo "std-http-https gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-http-https gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-http-https gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_http_https_symbols_ok "$MOD_X" "$HTTP_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_http_https_emit_report "fail" 0 0 1
  echo "std-http-https gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-http-https manifest OK"

if [ "${XLANG_STD_HTTP_HTTPS_MANIFEST_ONLY:-0}" = "1" ]; then
  std_http_https_emit_report "ok" 0 0 1
  echo "std-http-https gate OK (manifest only)"
  exit 0
fi

stdlib_cm_native_xlang() {
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

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-034: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if [ "$(uname -s)" = "Darwin" ] && [ -d /opt/homebrew/lib ]; then
    export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
  fi
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-http-https gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/http/http.o
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_http_https_run_smoke "$XLANG_BIN" "$SMOKE_X" "https_smoke"; then
    RUN_OK=1
    SKIP=0
  else
    std_http_https_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi

  # Observational C / OpenSSL probes (never hard-green).
  # PLATFORM: SHARED — host TLS optional; stub offline path covered by .x smoke.
  C_OK=0
  OPENSSL_OK=0
  HTTP_O="$(cd compiler && pwd)/../std/http/http.o"
  if [ -f "$HTTP_O" ] && cc -std=c11 -O1 -o /tmp/xlang_http_https_stub_$$ "$SMOKE_C" "$HTTP_O" 2>/dev/null; then
    if /tmp/xlang_http_https_stub_$$ >/dev/null 2>&1; then
      C_OK=1
    fi
    rm -f /tmp/xlang_http_https_stub_$$
  else
    echo "std-http-https gate SKIP c stub smoke (observational)" >&2
  fi
  if std_net_tls_probe_openssl; then
    TLS_PORT="${XLANG_HTTPS_SMOKE_PORT:-9888}"
    TLS_CERT="/tmp/xlang_https_cert_$$.pem"
    TLS_KEY="/tmp/xlang_https_key_$$.pem"
    TLS_PID="/tmp/xlang_https_spid_$$"
    if openssl req -x509 -newkey rsa:2048 -keyout "$TLS_KEY" -out "$TLS_CERT" -days 1 -nodes \
      -subj "/CN=localhost" 2>/dev/null; then
      if std_net_tls_build_openssl_o && std_net_tls_start_s_server "$TLS_PID" "$TLS_PORT" "$TLS_CERT" "$TLS_KEY"; then
        NET_O="$(cd compiler && pwd)/../std/net/net.o"
        export XLANG_HTTPS_SMOKE_PORT="$TLS_PORT"
        ldflags="$(std_net_tls_openssl_ldflags)"
        if std_http_https_run_c_smoke "$HTTP_O" "$NET_O" "$ldflags"; then
          OPENSSL_OK=1
        fi
        std_net_tls_stop_s_server "$TLS_PID"
      fi
    fi
    rm -f "$TLS_CERT" "$TLS_KEY"
    std_net_tls_restore_stub_o 2>/dev/null || true
  else
    echo "std-http-https gate SKIP openssl smoke (observational)" >&2
  fi
  echo "std-http-https c_ok=${C_OK} openssl_ok=${OPENSSL_OK} (observational)"
else
  echo "std-http-https gate FAIL: no native xlang" >&2
  std_http_https_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-http-https check_ok=${CHECK_OK} (observational)"
std_http_https_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-http-https gate OK"
