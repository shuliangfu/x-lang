#!/usr/bin/env bash
# STD-005：std.time 精度与时区 manifest 门禁
#
# 1) std-time-precision-v1.md + manifest
# 2) mod.x 13 API + time.c 平台实现
# 3) native shux：precision_smoke + main 烟测
#
# 用法：./tests/run-std-time-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_TIME_DOC:-analysis/std-time-precision-v1.md}"
MANIFEST="${SHUX_STD_TIME_MANIFEST:-tests/baseline/std-time-manifest.tsv}"
MOD_X="${SHUX_STD_TIME_MOD:-std/time/mod.x}"
TIME_RUNTIME="compiler/src/asm/runtime_time_os.c"
TIME_X="std/time/time.x"
MIN_APIS=13

# shellcheck source=tests/lib/std-time.sh
. tests/lib/std-time.sh

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

echo "=== STD-005: std.time precision manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_X" "$TIME_RUNTIME" "$TIME_X"; do
  if [ ! -f "$f" ]; then
    echo "std-time gate FAIL: missing $f" >&2
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
echo "=== STD-005: API surface ==="
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-time FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      API_N=$((API_N + 1))
      if ! std_time_has_api "$MOD_X" "$anchor"; then
        echo "std-time FAIL: missing API ${anchor} in $MOD_X" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-time FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "std-time FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script|hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "std-time FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-time FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if [ ! -f "$anchor" ]; then
        echo "std-time FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "std-time FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-time FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-time gate FAIL: apis=${API_N} < min ${MIN_APIS}" >&2
  exit 1
fi

if ! grep -q '_WIN32' "$TIME_RUNTIME" 2>/dev/null || ! grep -q 'CLOCK_MONOTONIC' "$TIME_RUNTIME" 2>/dev/null; then
  echo "std-time gate FAIL: runtime_time_os.c missing platform branches" >&2
  exit 1
fi

for kw in precision timezone UTC monotonic runnable; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "std-time gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "std-time gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "std-time manifest OK (apis=${API_N})"

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
  echo "=== STD-005: std.time smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/time/time.o
  FAIL=0
  for smoke in tests/time/main.x tests/time/precision_smoke.x; do
    tag="$(basename "$smoke" .x)"
    if std_time_run_smoke "$SHUX_BIN" "$smoke" "$tag"; then
      echo "std-time smoke OK $tag"
    else
      FAIL=$((FAIL + 1))
    fi
  done
  if [ "$FAIL" -gt 0 ]; then
    echo "std-time gate FAIL: smoke=${FAIL}" >&2
    exit 1
  fi
else
  echo "std-time gate SKIP smoke (no native shux)" >&2
fi

echo "std-time gate OK"
