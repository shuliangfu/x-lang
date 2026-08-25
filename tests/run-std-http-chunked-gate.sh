#!/usr/bin/env bash
# STD-033：std.http 分块传输与 Keep-Alive 门禁（假权威诚实）。
#
# 用法：./tests/run-std-http-chunked-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); chunked_keepalive.x exit 0 hard-fail (no soft
# SKIP when native xlang present). Report check=/run=/skip=. Bench path fixed to
# live i08_* (fossil http_chunked_decode_bench.x removed). Product surface already
# green under asm; gate was portable-false-red (prefer xlang-c / hard check /
# soft SKIP / missing fossil bench).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

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

echo "=== STD-033: http chunked/keep-alive manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$HTTP_C" "$CHUNKED_INC" "$SMOKE" "$BENCH"; do
  if [ ! -f "$f" ]; then
    echo "std-http-chunked gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in chunked keep-alive decode_chunked build_get_keep_alive; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-http-chunked gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-http-chunked gate FAIL: doc missing '## 4. Gate'" >&2
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
        echo "std-http-chunked gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-http-chunked gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-http-chunked gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_http_chunked_symbols_ok "$MOD_X" "$CHUNKED_INC" "$HTTP_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_http_chunked_emit_report "fail" 0 0 1
  echo "std-http-chunked gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-http-chunked manifest OK"

if [ "${XLANG_STD_HTTP_CHUNKED_MANIFEST_ONLY:-0}" = "1" ]; then
  std_http_chunked_emit_report "ok" 0 0 1
  echo "std-http-chunked gate OK (manifest only)"
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
  echo "=== STD-033: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if [ "$(uname -s)" = "Darwin" ] && [ -d /opt/homebrew/lib ]; then
    export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
  fi
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-http-chunked gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  # Bench check is observational only (not hard-green signal).
  if ! "$XLANG_BIN" check -L . "$BENCH" >/dev/null 2>&1; then
    echo "std-http-chunked gate SKIP check bench (observational)" >&2
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

  if std_http_chunked_run_smoke "$XLANG_BIN" "$SMOKE" "chunked_keepalive"; then
    RUN_OK=1
    SKIP=0
  else
    std_http_chunked_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-http-chunked gate FAIL: no native xlang" >&2
  std_http_chunked_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-http-chunked check_ok=${CHECK_OK} (observational)"
std_http_chunked_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-http-chunked gate OK"
