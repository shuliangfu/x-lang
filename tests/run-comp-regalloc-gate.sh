#!/usr/bin/env bash
# COMP-005: register-allocation strategy manifest gate (false-authority honesty).
# wave309 honesty: live glue_asm73_* in runtime_pipeline_abi.x;
# DOC default = analysis/archive/comp/comp-regalloc-v1.md (archived).
#
# Honesty: soft SKIP→OK in run-comp-regalloc.sh retired (2026-08-27). Prefer
# product xlang_asm via child; DOC→archive with ## Gate; refuse top-level
# DOC resurrect. Report inherits child run=/skip=; greppable gate OK kept.
#
# Usage: ./tests/run-comp-regalloc-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="${XLANG_COMP_REGALLOC_DOC:-analysis/archive/comp/comp-regalloc-v1.md}"
MANIFEST="${XLANG_COMP_REGALLOC_MANIFEST:-tests/baseline/comp-regalloc.tsv}"
QUALITY="${XLANG_COMP_REGALLOC_QUALITY:-tests/baseline/comp-regalloc-quality.tsv}"
MIN_LAYERS=6
MIN_CASES=4
MIN_METRICS=9
PREFIX="xlang: [XLANG_COMP_REGALLOC]"

die() {
  echo "comp-regalloc gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  exit 1
}

# Refuse resurrecting top-level DOC (archive is authority).
if [ -f analysis/comp-regalloc-v1.md ]; then
  die "refuse top-level analysis/comp-regalloc-v1.md (use archive/comp)"
fi

# shellcheck source=tests/lib/comp-regalloc.sh
. tests/lib/comp-regalloc.sh

echo "=== COMP-005: regalloc strategy manifest ==="
# wave309: pipeline_glue.c left — live asm73 regalloc = runtime_pipeline_abi.x.
# Doc archived under analysis/archive/comp/ (default DOC path updated).
for f in "$DOC" "$MANIFEST" "$QUALITY" \
  compiler/src/runtime_pipeline_abi.x compiler/src/asm/README.md \
  tests/asm/binop_return_four_mul.x tests/asm/binop_return_seven_add.x \
  tests/asm/binop_return_fourteen_add.x tests/asm/binop_if_return_twelve_add.x \
  tests/run-asm-73-gate.sh; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done

if ! grep -qE '^## Gate' "$DOC"; then
  die "doc missing ## Gate section"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_layers) MIN_LAYERS="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_metrics) MIN_METRICS="$c2" ;;
  esac
done < "$QUALITY"

MISS=0
LAYER_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-regalloc FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-regalloc FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-regalloc FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "comp-regalloc FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "comp-regalloc FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "comp-regalloc FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ref)
      if [ ! -f "$src" ]; then
        echo "comp-regalloc FAIL: missing hook $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-regalloc FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-regalloc FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-regalloc FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "comp-regalloc FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-regalloc FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

METRIC_N=0
while IFS=$'\t' read -r metric_id arch _strategy _threshold script _notes; do
  [ -z "${metric_id:-}" ] && continue
  case "$metric_id" in \#*|min_*) continue ;; esac
  METRIC_N=$((METRIC_N + 1))
  if ! grep -qF "$metric_id" "$DOC" 2>/dev/null; then
    echo "comp-regalloc FAIL: doc missing metric $metric_id" >&2
    MISS=$((MISS + 1))
  fi
  if [ -f "tests/$script" ]; then
    :
  elif [ -f "tests/asm/$script" ]; then
    :
  else
    echo "comp-regalloc FAIL: missing quality script $script" >&2
    MISS=$((MISS + 1))
  fi
done < "$QUALITY"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  die "layers=${LAYER_N} < min ${MIN_LAYERS}"
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  die "cases=${CASE_N} < min ${MIN_CASES}"
fi
if [ "$METRIC_N" -lt "$MIN_METRICS" ]; then
  die "metrics=${METRIC_N} < min ${MIN_METRICS}"
fi

for kw in register allocation regalloc quality runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done

if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi
echo "comp-regalloc manifest OK (layers=${LAYER_N} cases=${CASE_N} metrics=${METRIC_N})"

chmod +x tests/run-comp-regalloc.sh
./tests/run-comp-regalloc.sh

chmod +x tests/run-comp-regalloc-result-spill-gate.sh
./tests/run-comp-regalloc-result-spill-gate.sh

echo "comp-regalloc gate OK"
