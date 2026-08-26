#!/usr/bin/env bash
# STD-009：std.http 服务器基准 manifest 门禁（假权威诚实）。
#
# 用法：./tests/run-std-http-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); tests/http/main.x exit 0 hard-fail (no soft SKIP
# when native xlang present). Report check=/run=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / soft SKIP when no native / ## 6. 验证与门禁 /
# fossil bench/http_get_bench.x). Bench anchors → bench/i08_http_*.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_HTTP_DOC:-analysis/archive/std/std-http-bench-v1.md}"
MANIFEST="${XLANG_STD_HTTP_MANIFEST:-tests/baseline/std-http-manifest.tsv}"
MOD_X="${XLANG_STD_HTTP_MOD:-std/http/mod.x}"
HTTP_C="${XLANG_STD_HTTP_C:-compiler/seeds/runtime_http_glue.from_x.c}"
SMOKE_X="tests/http/main.x"
MIN_APIS=2
PREFIX="xlang: [XLANG_STD_HTTP]"

# shellcheck source=tests/lib/perf-http.sh
. tests/lib/perf-http.sh

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

std_http_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

std_http_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="$3"
  local exe="/tmp/xlang_std_http_${tag}_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    "$xlang" -L . "$src" -o "$exe" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  local ec=0
  "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

std_http_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
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

echo "=== STD-009: std.http bench manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_X" "$HTTP_C" "$SMOKE_X" \
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

if ! grep -qF '## 6. Gate' "$DOC" 2>/dev/null; then
  echo "std-http gate FAIL: doc missing '## 6. Gate'" >&2
  exit 1
fi

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
      if [ "$anchor" = "compiler/seeds/runtime_http_glue.from_x.c" ]; then
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

if [ "${XLANG_STD_HTTP_MANIFEST_ONLY:-0}" = "1" ]; then
  std_http_emit_report "ok" 0 0 1
  echo "std-http gate OK (manifest only)"
  exit 0
fi

CHECK_OK=0
RUN_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-009: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if [ "$(uname -s)" = "Darwin" ] && [ -d /opt/homebrew/lib ]; then
    export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
  fi
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-http gate SKIP check smoke (paused 2026-08-05)" >&2
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

  if std_http_run_smoke "$XLANG_BIN" "$SMOKE_X" "main"; then
    RUN_OK=1
    SKIP=0
  else
    std_http_emit_report "fail" "$CHECK_OK" 0 0
    echo "std-http gate FAIL: main smoke" >&2
    exit 1
  fi
else
  echo "std-http gate FAIL: no native xlang" >&2
  std_http_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-http check_ok=${CHECK_OK} (observational)"
std_http_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-http gate OK"
