#!/usr/bin/env bash
# DOC-003：性能调优手册 manifest 门禁
#
# 1) doc-perf-tuning-v1.md 必需章节与交叉引用
# 2) perf baseline registry + hook 脚本存在
# 3) 文档须引用 SHUX_COMPILE_PHASE_TIMING 与关键 gate 名
#
# 用法：./tests/run-doc-perf-tuning-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_DOC_PERF_TUNING:-analysis/doc-perf-tuning-v1.md}"
MANIFEST="${SHUX_DOC_PERF_TUNING_TSV:-tests/baseline/doc-perf-tuning.tsv}"
REG="${SHUX_PERF_BASELINE_REGISTRY:-tests/baseline/perf-baseline-registry.tsv}"
MIN_SEC=7
MIN_XREF=6

echo "=== DOC-003: perf tuning handbook manifest ==="
for f in "$DOC" "$MANIFEST" "$REG" NEXT.md; do
  if [ ! -f "$f" ]; then
    echo "doc-perf-tuning gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_sections) MIN_SEC="$c2" ;;
    min_cross_refs) MIN_XREF="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
SEC=0
XREF=0
HOOKS=""
echo "=== DOC-003: sections and refs ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "doc-perf-tuning FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      else
        SEC=$((SEC + 1))
        echo "doc-perf-tuning OK section $item_id"
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "doc-perf-tuning FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      else
        XREF=$((XREF + 1))
        if ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
          echo "doc-perf-tuning FAIL: doc missing ref $anchor" >&2
          MISS=$((MISS + 1))
        else
          echo "doc-perf-tuning OK cross-ref $anchor"
        fi
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "doc-perf-tuning FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "doc-perf-tuning FAIL: doc missing file ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "doc-perf-tuning FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      else
        case " $HOOKS " in
          *" $path "*) ;;
          *) HOOKS="$HOOKS $path" ;;
        esac
        if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
          echo "doc-perf-tuning FAIL: doc missing hook ref $anchor" >&2
          MISS=$((MISS + 1))
        fi
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SEC" -lt "$MIN_SEC" ]; then
  echo "doc-perf-tuning gate FAIL: sections=${SEC} < min ${MIN_SEC}" >&2
  exit 1
fi
if [ "$XREF" -lt "$MIN_XREF" ]; then
  echo "doc-perf-tuning gate FAIL: cross_refs=${XREF} < min ${MIN_XREF}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "doc-perf-tuning gate FAIL: missing=${MISS}" >&2
  exit 1
fi

for kw in SHUX_COMPILE_PHASE_TIMING run-perf-compile-dogfood run-bootstrap-stage-diag; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "doc-perf-tuning gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "doc-perf-tuning manifest OK (sections=${SEC}, cross_refs=${XREF})"

# hook 存在性二次确认（不强制跑，避免 CI 耗时）
for hook in $HOOKS; do
  if [ ! -f "$hook" ]; then
    echo "doc-perf-tuning gate FAIL: hook missing $hook" >&2
    exit 1
  fi
done
echo "doc-perf-tuning hooks OK"

echo "doc-perf-tuning gate OK"
