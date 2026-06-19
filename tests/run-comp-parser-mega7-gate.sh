#!/usr/bin/env bash
# COMP-001：parser mega 7 深循环改造 manifest 门禁
#
# 1) comp-parser-mega7-v1.md + matrix + boot-mega7-gap + parser-mega-bisect.tsv
# 2) mega7 函数存在于 parser.sx；matrix 行数下限
# 3) capability slice 文件存在（status=done）
# 4) hook：symbol-integrity（Linux）；mega bisect baseline 7 行
#
# 用法：./tests/run-comp-parser-mega7-gate.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHUX_COMP_PARSER_MEGA7_TSV:-tests/baseline/comp-parser-mega7-matrix.tsv}"
MEGA_BISECT="${SHUX_PARSER_MEGA_BISECT_BASELINE:-tests/baseline/parser-mega-bisect.tsv}"
PARSER_SU="compiler/src/parser/parser.sx"
MIN_PHASE_A=2
MIN_MEGA7=7
MIN_SLICE=15

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

# mega 7 符号名（与 parser-mega-bisect.tsv 一致）
MEGA7_FUNCS="parse_into_buf parse_into parse parse_one_function_impl parse_expr_into parse_block_into parse_body_lets_into"

echo "=== COMP-001: parser mega7 manifest ==="
for f in \
  analysis/comp-parser-mega7-v1.md \
  analysis/boot-mega7-gap.md \
  "$MATRIX" \
  "$MEGA_BISECT" \
  "$PARSER_SU"; do
  if [ ! -f "$f" ]; then
    echo "comp-parser-mega7 gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "comp-parser-mega7 manifest OK (host=$(ci_host_summary))"

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_phase_a_rows) MIN_PHASE_A="$c2" ;;
    min_mega7_rows) MIN_MEGA7="$c2" ;;
    min_slice_done) MIN_SLICE="$c2" ;;
  esac
done < "$MATRIX"

# ── mega 7 函数在 parser.sx ──
MISS=0
for fn in $MEGA7_FUNCS; do
  if ! grep -qE "function ${fn}\\(" "$PARSER_SU" 2>/dev/null; then
    echo "comp-parser-mega7 FAIL: function ${fn} not in $PARSER_SU" >&2
    MISS=$((MISS + 1))
  fi
done
[ "$MISS" -eq 0 ] || exit 1
echo "comp-parser-mega7 mega7 symbols OK (7 functions)"

# ── matrix 统计 + capability 文件 ──
PHASE_A=0
MEGA7_N=0
SLICE_DONE=0
HOOKS=""
echo "=== COMP-001: matrix rows ==="
while IFS=$'\t' read -r item_id kind phase status hook notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    phase)
      if [ "$phase" = "A" ]; then
        PHASE_A=$((PHASE_A + 1))
      fi
      ;;
    mega7)
      MEGA7_N=$((MEGA7_N + 1))
      ;;
    capability)
      if [ "$status" = "done" ]; then
        if [ ! -f "$hook" ]; then
          echo "comp-parser-mega7 FAIL: missing slice $hook ($item_id)" >&2
          MISS=$((MISS + 1))
        else
          SLICE_DONE=$((SLICE_DONE + 1))
        fi
      fi
      ;;
  esac
  if [ "$kind" = "phase" ] && [ "$status" = "done" ] && [ -n "${hook:-}" ]; then
    case " $HOOKS " in
      *" $hook "*) ;;
      *) HOOKS="$HOOKS $hook" ;;
    esac
  fi
done < "$MATRIX"

if [ "$PHASE_A" -lt "$MIN_PHASE_A" ]; then
  echo "comp-parser-mega7 gate FAIL: phase_A=${PHASE_A} < min ${MIN_PHASE_A}" >&2
  exit 1
fi
if [ "$MEGA7_N" -lt "$MIN_MEGA7" ]; then
  echo "comp-parser-mega7 gate FAIL: mega7=${MEGA7_N} < min ${MIN_MEGA7}" >&2
  exit 1
fi
if [ "$SLICE_DONE" -lt "$MIN_SLICE" ]; then
  echo "comp-parser-mega7 gate FAIL: slice_done=${SLICE_DONE} < min ${MIN_SLICE}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "comp-parser-mega7 gate FAIL: missing slice files=${MISS}" >&2
  exit 1
fi
echo "comp-parser-mega7 matrix OK (phase_A=${PHASE_A} mega7=${MEGA7_N} slices=${SLICE_DONE})"

# ── parser-mega-bisect.tsv 须含 7 项 mega ──
BISECT_N=0
while IFS=$'\t' read -r name _rest; do
  [ -z "${name:-}" ] && continue
  case "$name" in \#*|baseline_*|min_*) continue ;; esac
  for fn in $MEGA7_FUNCS; do
    if [ "$name" = "$fn" ]; then
      BISECT_N=$((BISECT_N + 1))
    fi
  done
done < "$MEGA_BISECT"
if [ "$BISECT_N" -lt 7 ]; then
  echo "comp-parser-mega7 gate FAIL: parser-mega-bisect.tsv rows=${BISECT_N} want 7" >&2
  exit 1
fi
echo "comp-parser-mega7 bisect baseline OK (${BISECT_N} mega rows)"

# ── Linux hook：symbol-integrity + mega sweep（track-only）──
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "comp-parser-mega7 gate SKIP hooks (Darwin N/A)"
  echo "comp-parser-mega7 gate OK"
  exit 0
fi

FAILS=0
for hook in run-parser-thin-glue-symbol-integrity-gate.sh run-parser-mega-bisect-sweep-gate.sh; do
  script="tests/$hook"
  if [ ! -f "$script" ]; then
    echo "comp-parser-mega7 FAIL: missing $script" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  echo "── hook: $hook ──"
  chmod +x "$script" 2>/dev/null || true
  if "$script"; then
    echo "comp-parser-mega7 hook OK $hook"
  else
    echo "comp-parser-mega7 hook FAIL $hook" >&2
    FAILS=$((FAILS + 1))
  fi
done

if [ "$FAILS" -gt 0 ]; then
  echo "comp-parser-mega7 gate FAIL: ${FAILS} hook(s)" >&2
  exit 1
fi

echo "comp-parser-mega7 gate OK"
