#!/usr/bin/env bash
# 将 EMIT_HEAVY 第二遍产物写入 compiler/build_asm/pipeline.o，供 S3 gate 使用。
# 依次尝试 strict_glue / shu_asm / experimental，取 __text 最大且编译成功的产物。
# 用法：./tests/run-s3-pipeline-sync-build-o.sh
set -e
cd "$(dirname "$0")/.."
DEST="compiler/build_asm/pipeline.o"
BASELINE="${SHU_S3_PIPELINE_BASELINE:-tests/baseline/s3-pipeline-o.tsv}"
MIN_TEXT_EH=$(awk -F'\t' '$1=="min_text_emit_heavy" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT_EH=${MIN_TEXT_EH:-512}

text_section_size() {
  local o="$1"
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && { echo 0; return; }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

# 尝试单个编译器 emit-heavy；成功时 stdout 打印 __text 字节数。
try_emit_heavy() {
  local cand="$1"
  [ -x "$cand" ] || return 1
  if ! SHU_S3_EMIT_HEAVY_COMPILER="$cand" ./tests/run-s3-pipeline-emit-heavy.sh >/tmp/s3_eh_try.log 2>&1; then
    return 1
  fi
  [ -f /tmp/shu_s3_pipeline_emit_heavy.o ] || return 1
  text_section_size /tmp/shu_s3_pipeline_emit_heavy.o
}

emit_heavy_ok=0
best_sz=0
best_comp=""
if [ -n "${SHU_S3_EMIT_HEAVY_COMPILER:-}" ] && [ -x "${SHU_S3_EMIT_HEAVY_COMPILER}" ]; then
  if sz=$(try_emit_heavy "${SHU_S3_EMIT_HEAVY_COMPILER}"); then
    best_sz=$sz
    best_comp="${SHU_S3_EMIT_HEAVY_COMPILER}"
    emit_heavy_ok=1
  fi
fi
if [ "$emit_heavy_ok" -eq 0 ]; then
  for cand in ./compiler/shu_asm.strict_glue ./compiler/shu_asm ./compiler/shu_asm.experimental; do
    [ -x "$cand" ] || continue
    echo "s3 sync-build-o: trying emit-heavy with $cand ..."
    if sz=$(try_emit_heavy "$cand"); then
      if [ "${sz:-0}" -gt "${best_sz:-0}" ] 2>/dev/null; then
        best_sz=$sz
        best_comp=$cand
        emit_heavy_ok=1
      fi
    fi
  done
fi
if [ "$emit_heavy_ok" -eq 0 ] || [ -z "$best_comp" ]; then
  echo "s3 sync-build-o: emit-heavy failed (all compilers)" >&2
  exit 1
fi
export SHU_S3_EMIT_HEAVY_COMPILER="$best_comp"
SHU_S3_EMIT_HEAVY_COMPILER="$best_comp" ./tests/run-s3-pipeline-emit-heavy.sh

SRC="/tmp/shu_s3_pipeline_emit_heavy.o"
[ -f "$SRC" ] || {
  echo "s3 sync-build-o: missing $SRC" >&2
  exit 1
}

mkdir -p "$(dirname "$DEST")"
cp -f "$SRC" "$DEST"

sz=$(text_section_size "$DEST")
echo "s3 sync-build-o: wrote $DEST __text=${sz} (compiler=$best_comp, min_text_emit_heavy=${MIN_TEXT_EH})"

if [ "${SHU_S3_FAIL_ON_EMIT_HEAVY:-0}" = "1" ]; then
  if ! awk -v s="$sz" -v m="$MIN_TEXT_EH" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
    echo "s3 sync-build-o FAIL: __text ${sz} < min_text_emit_heavy ${MIN_TEXT_EH}" >&2
    exit 1
  fi
fi

echo "s3 sync-build-o OK ($DEST)"
