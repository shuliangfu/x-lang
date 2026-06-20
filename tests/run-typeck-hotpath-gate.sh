#!/usr/bin/env bash
# COMP-002：typeck 热路径剖析与优化门禁
#
# 1) manifest：comp-typeck-hotpath-v1.md + typeck-hotpath-matrix.tsv
# 2) 符号存在性 + min_opt_done
# 3) hook：region/linear typeck；Linux 上 WPO opt-in smoke
# 4) compile-dogfood 须含 check_typeck 行
#
# 用法：./tests/run-typeck-hotpath-gate.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHUX_TYPECK_HOTPATH_TSV:-tests/baseline/typeck-hotpath-matrix.tsv}"
DOGFOOD="${SHUX_PERF_COMPILE_BASELINE:-tests/baseline/compile-dogfood.tsv}"
MIN_DONE=6

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

echo "=== COMP-002: typeck hotpath manifest ==="
for f in \
  analysis/comp-typeck-hotpath-v1.md \
  "$MATRIX" \
  "$DOGFOOD"; do
  if [ ! -f "$f" ]; then
    echo "typeck-hotpath gate FAIL: missing $f" >&2
    exit 1
  fi
done

# 读取 min_opt_done（默认 6）
while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    \#*) ;;
    min_opt_done) MIN_DONE="$c2" ;;
  esac
done < "$MATRIX"

if ! awk -F'\t' '$1=="check_typeck" && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$DOGFOOD"; then
  echo "typeck-hotpath gate FAIL: $DOGFOOD missing check_typeck row" >&2
  exit 1
fi

echo "typeck-hotpath manifest OK (host=$(ci_host_summary), min_opt_done=$MIN_DONE)"

# ── 符号存在 + done 计数 ──
MISS=0
DONE=0
HOOKS=""
echo "=== COMP-002: hot symbol check ==="
while IFS=$'\t' read -r hot_id sym tier opt_status src hook notes; do
  [ -z "${hot_id:-}" ] && continue
  case "$hot_id" in \#*|min_opt_done) continue ;; esac
  if [ ! -f "$src" ]; then
    echo "typeck-hotpath FAIL: missing source $src ($hot_id)" >&2
    MISS=$((MISS + 1))
    continue
  fi
  if ! grep -qE "(function|void|int32_t|int64_t|bool|i32) ${sym}\\(" "$src" 2>/dev/null; then
    echo "typeck-hotpath FAIL: symbol ${sym} not in $src ($hot_id)" >&2
    MISS=$((MISS + 1))
  fi
  if [ "$opt_status" = "done" ]; then
    DONE=$((DONE + 1))
  fi
  if [ -n "${hook:-}" ] && [ "$hook" != "check_typeck" ] && [[ "$hook" == *.sh ]]; then
    case " $HOOKS " in
      *" $hook "*) ;;
      *) HOOKS="$HOOKS $hook" ;;
    esac
  fi
done < "$MATRIX"

if [ "$MISS" -gt 0 ]; then
  echo "typeck-hotpath gate FAIL: missing=${MISS}" >&2
  exit 1
fi
if [ "$DONE" -lt "$MIN_DONE" ]; then
  echo "typeck-hotpath gate FAIL: done=${DONE} < min_opt_done=${MIN_DONE}" >&2
  exit 1
fi
echo "typeck-hotpath symbols OK (done=${DONE})"

# ── hook 烟测 ──
SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ]; then
  echo "typeck-hotpath gate SKIP hooks (no native shux)" >&2
  echo "typeck-hotpath gate OK"
  exit 0
fi

FAILS=0
for hook in $HOOKS; do
  script="tests/${hook}"
  if [ ! -f "$script" ]; then
    echo "typeck-hotpath FAIL: missing hook script $script" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  echo "── hook: $hook (SHUX=$SHUX_BIN) ──"
  chmod +x "$script" 2>/dev/null || true
  if SHUX="$SHUX_BIN" "$script"; then
    echo "typeck-hotpath hook OK $hook"
  else
    echo "typeck-hotpath hook FAIL $hook" >&2
    FAILS=$((FAILS + 1))
  fi
done

if [ "$FAILS" -gt 0 ]; then
  echo "typeck-hotpath gate FAIL: ${FAILS} hook(s)" >&2
  exit 1
fi

echo "typeck-hotpath gate OK"
