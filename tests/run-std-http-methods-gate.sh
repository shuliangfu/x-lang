#!/usr/bin/env bash
# STD-032: std.http POST/HEAD + status-line gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# methods_status.x -o exit0 = hard run (run=1). check = obs.
# Report: run=/obs=/skip=. G.7: complete existing resolve_shu; drop unused
# compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-http-methods-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_HTTP_METHODS_DOC:-analysis/archive/std/std-http-methods-v1.md}"
MANIFEST="${XLANG_STD_HTTP_METHODS_TSV:-tests/baseline/std-http-methods.tsv}"
MOD_X="std/http/mod.x"
HTTP_C="compiler/seeds/runtime_http_glue.from_x.c"
LIB="tests/lib/std-http-methods.sh"
METHODS_X="tests/http/methods_status.x"
MIN_APIS=3

# shellcheck source=tests/lib/std-http-methods.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-http-methods gate FAIL: $*" >&2
  std_http_methods_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-032: http methods manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$HTTP_C" "$METHODS_X"; do
  [ -f "$f" ] || die "missing $f"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in POST HEAD PUT DELETE PATCH OPTIONS parse_status_line Method client_request; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

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

sym_miss="$(std_http_methods_symbols_ok "$MOD_X" "$HTTP_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-http-methods manifest OK"

if [ "${XLANG_STD_HTTP_METHODS_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_http_methods_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-http-methods gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
# PLATFORM: MACOS — Homebrew OpenSSL/lib path for optional host TLS deps.
if [ "$(uname -s)" = "Darwin" ] && [ -d /opt/homebrew/lib ]; then
  export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
fi
echo "=== STD-032: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$METHODS_X" >/tmp/xlang_std032_methods_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-http-methods OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft ensure_std_c_o / soft auto-make (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
if std_http_methods_run_smoke "$XLANG_BIN" "$METHODS_X" "methods_status"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-http-methods OK: product -o"
else
  die "product -o failed (refuse soft SKIP→OK)"
fi

std_http_methods_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-http-methods gate OK"
