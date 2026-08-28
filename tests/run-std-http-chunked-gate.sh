#!/usr/bin/env bash
# STD-033: std.http chunked transfer + Keep-Alive gate — honesty leftover wrap dead source →硬绿.
#
# Honesty: leftover bootstrap-link wrap sourced unused (no RUN_XLANG) + unused
# compiler-make.sh retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover wrap dead
# source / unused compiler-make / soft SKIP→OK / prefer-c). Product
# chunked_keepalive.x -o exit0 = hard run (run=1). check / bench check = obs.
# Report: run=/obs=/skip=. G.7: complete existing resolve_shu; drop unused
# compiler-make.sh. PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-http-chunked-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_HTTP_CHUNKED_DOC:-analysis/archive/std/std-http-chunked-v1.md}"
MANIFEST="${XLANG_STD_HTTP_CHUNKED_TSV:-tests/baseline/std-http-chunked.tsv}"
MOD_X="std/http/mod.x"
HTTP_C="compiler/seeds/runtime_http_glue.from_x.c"
CHUNKED_INC="compiler/seeds/http/http_chunked.inc"
LIB="tests/lib/std-http-chunked.sh"
SMOKE="tests/http/chunked_keepalive.x"
BENCH="bench/i08_http_chunked_decode_bench.x"
MIN_APIS=5

# shellcheck source=tests/lib/std-http-chunked.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-http-chunked gate FAIL: $*" >&2
  std_http_chunked_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-http-chunked-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

echo "=== STD-033: http chunked/keep-alive manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$HTTP_C" "$CHUNKED_INC" "$SMOKE" "$BENCH"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in chunked keep-alive decode_chunked build_get_keep_alive; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

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

sym_miss="$(std_http_chunked_symbols_ok "$MOD_X" "$CHUNKED_INC" "$HTTP_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-http-chunked manifest OK"

if [ "${XLANG_STD_HTTP_CHUNKED_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_http_chunked_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-http-chunked gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
if [ "$(uname -s)" = "Darwin" ] && [ -d /opt/homebrew/lib ]; then
  export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
fi
echo "=== STD-033: smoke (XLANG=$XLANG_BIN; check obs; chunked product hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std033_chunked_check.log 2>&1
chk=$?
"$XLANG_BIN" check -L . "$BENCH" >/tmp/xlang_std033_chunked_bench_check.log 2>&1
chk_b=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-http-chunked OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi
if [ "$chk_b" -ne 0 ]; then
  echo "std-http-chunked OBS check bench (paused / CHK residual ec=$chk_b)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover wrap dead source / unused compiler-make.sh
# (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

if std_http_chunked_run_smoke "$XLANG_BIN" "$SMOKE" "chunked_keepalive"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-http-chunked OK: chunked_keepalive"
else
  die "chunked_keepalive.x exit!=0 (refuse soft SKIP→OK)"
fi

std_http_chunked_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-http-chunked gate OK"
