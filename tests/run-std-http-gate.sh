#!/usr/bin/env bash
# STD-009：std.http 服务器基准 manifest 门禁
#
# 用法：./tests/run-std-http-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_HTTP_DOC:-analysis/std-http-bench-v1.md}"
MANIFEST="${SHUX_STD_HTTP_MANIFEST:-tests/baseline/std-http-manifest.tsv}"
MOD_X="${SHUX_STD_HTTP_MOD:-std/http/mod.x}"
HTTP_C="${SHUX_STD_HTTP_C:-compiler/src/asm/http/runtime_http_glue.inc}"
MIN_APIS=2

# shellcheck source=tests/lib/perf-http.sh
. tests/lib/perf-http.sh

native_shu() {
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

std_http_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

std_http_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="$3"
  local exe="/tmp/shux_std_http_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    "$shux" -L . "$src" -o "$exe" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  local ec=0
  "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

echo "=== STD-009: std.http bench manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_X" "$HTTP_C" \
  tests/baseline/http-perf.tsv tests/baseline/http-perf-latency.tsv; do
  if [ ! -f "$f" ]; then
    echo "std-http gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
API_N=0
while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-http FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      API_N=$((API_N + 1))
      if ! std_http_has_api "$MOD_X" "$anchor"; then
        echo "std-http FAIL: missing API $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-http FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "std-http FAIL: missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if [ "$anchor" = "compiler/src/asm/http/runtime_http_glue.inc" ]; then
        if ! grep -qF 'http_respond_get_ok_c' "$HTTP_C" 2>/dev/null; then
          echo "std-http FAIL: missing http_respond_get_ok_c" >&2
          MISS=$((MISS + 1))
        fi
      fi
      ;;
    script|hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "std-http FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-http FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if [ ! -f "$anchor" ]; then
        echo "std-http FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "std-http FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-http FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-http gate FAIL: apis=${API_N} < min ${MIN_APIS}" >&2
  exit 1
fi

for kw in throughput latency server respond_get_ok runnable; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "std-http gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

cap="$(perf_http_read_cap http_get_bench)"
lat="$(perf_http_read_cap http_get_bench_p99 tests/baseline/http-perf-latency.tsv)"
if [ -z "$cap" ] || [ -z "$lat" ]; then
  echo "std-http gate FAIL: baseline rows" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  echo "std-http gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "std-http manifest OK (apis=${API_N})"

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -n "$SHUX_BIN" ] && native_shu "$SHUX_BIN"; then
  make -C compiler -q 2>/dev/null || make -C compiler
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/http/http.o
  if std_http_run_smoke "$SHUX_BIN" tests/http/main.x main; then
    echo "std-http smoke OK main"
  else
    echo "std-http gate FAIL: main smoke" >&2
    exit 1
  fi
else
  echo "std-http gate SKIP smoke (no native shux)" >&2
fi

echo "std-http gate OK"
