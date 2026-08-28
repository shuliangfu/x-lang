#!/usr/bin/env bash
# STD-009: std.http server bench manifest gate — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft auto-make + soft ensure_std_c_o + check=/run=/skip= retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make / prefer-c / soft ensure).
# Product tests/http/main.x -o exit0 = hard run (run=1). check = obs.
# Report: run=/obs=/skip=. Bench anchors → bench/i08_http_* (fossil removed).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-http-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
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

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-http gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP}"
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
  local log="/tmp/xlang_std_http_${tag}_$$.log"
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-http FAIL: compile $src" >&2
    tail -n 10 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  [ "$ec" -eq 0 ]
}

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-http-bench-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

echo "=== STD-009: std.http bench manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_X" "$HTTP_C" "$SMOKE_X" \
  tests/baseline/http-perf.tsv tests/baseline/http-perf-latency.tsv; do
  [ -f "$f" ] || die "missing $f"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

grep -qF '## 6. Gate' "$DOC" 2>/dev/null || die "doc missing '## 6. Gate'"

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

[ "$API_N" -ge "$MIN_APIS" ] || die "apis=${API_N} < min ${MIN_APIS}"

for kw in throughput latency server respond_get_ok runnable; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done

cap="$(perf_http_read_cap http_get_bench)"
lat="$(perf_http_read_cap http_get_bench_p99 tests/baseline/http-perf-latency.tsv)"
[ -n "$cap" ] && [ -n "$lat" ] || die "baseline rows"

[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "std-http manifest OK (apis=${API_N})"

if [ "${XLANG_STD_HTTP_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP}"
  echo "std-http gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
if [ "$(uname -s)" = "Darwin" ] && [ -d /opt/homebrew/lib ]; then
  export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
fi
echo "=== STD-009: smoke (XLANG=$XLANG_BIN; check obs; main product hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std009_http_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-http OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make / soft ensure (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

if std_http_run_smoke "$XLANG_BIN" "$SMOKE_X" "main"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-http OK: main"
else
  die "main.x exit!=0 (refuse soft SKIP→OK)"
fi

echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP}"
echo "std-http gate OK"
