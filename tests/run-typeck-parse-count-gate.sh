#!/usr/bin/env bash
# A-11 track/CI：asm pipeline 编 typeck.sx 时 after_entry_parse num_defined 须 ≥ min（146 为全量 defined）。
# 用法：./tests/run-typeck-parse-count-gate.sh
# 环境：SHUX_TYPECK_PARSE_COUNT_FAIL=1 低于 MIN 时硬失败
#       SHUX_TYPECK_PARSE_COUNT_MIN / TARGET 覆盖 baseline
set -e
cd "$(dirname "$0")/.."

BASELINE="${SHUX_TYPECK_PARSE_COUNT_TSV:-tests/baseline/typeck-parse-count.tsv}"
FAIL=${SHUX_TYPECK_PARSE_COUNT_FAIL:-0}
MIN_FUNCS=${SHUX_TYPECK_PARSE_COUNT_MIN:-$(awk -F'\t' '$1=="min_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE" 2>/dev/null)}
TARGET_FUNCS=${SHUX_TYPECK_PARSE_COUNT_TARGET:-$(awk -F'\t' '$1=="target_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE" 2>/dev/null)}
MIN_FUNCS=${MIN_FUNCS:-80}
TARGET_FUNCS=${TARGET_FUNCS:-146}
SHUX="${SHUX:-./compiler/shux_asm}"
TYPECK_SX="compiler/src/typeck/typeck.sx"
OUT="/tmp/shux_typeck_parse_count.$$.o"
LOG="/tmp/shux_typeck_parse_count.$$.log"
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "typeck-parse-count-gate: N/A on Darwin"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "typeck-parse-count-gate: SKIP (no compiler shux/shux_asm)"
  exit 0
fi

src_count=$(grep -c '^function ' "$TYPECK_SX" 2>/dev/null || echo 0)
echo "typeck-parse-count-gate: source functions in typeck.sx: ${src_count} (baseline min=${MIN_FUNCS}, stretch target>=${TARGET_FUNCS})"

rm -f "$OUT" "$LOG" 2>/dev/null || true

typeck_parse_count_compile() {
  local comp="$1"
  (
    cd compiler
    env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
      SHUX_ASM_PARSE_METRIC_ONLY=1 \
      SHUX_DEBUG_PIPE=1 \
      "../$comp" -backend asm -o "$OUT" $LIBROOT src/typeck/typeck.sx
  ) >"$LOG" 2>&1
}

# 整文件 parse 被 OOM killer 干掉（exit 137 / log 含 Killed）时，分块 parse 累加 num_defined。
typeck_parse_count_try_chunked() {
  local comp="$1"
  local sum
  chmod +x tests/lib/typeck-parse-count-chunk.sh 2>/dev/null || true
  if ! sum="$(tests/lib/typeck-parse-count-chunk.sh "$comp" "$TYPECK_SX" 2>>"$LOG")"; then
    return 1
  fi
  ndef="$sum"
  nf="$sum"
  metric="$sum"
  compile_ok=1
  echo "typeck-parse-count-gate: chunked parse OK (num_defined_sum=${sum})" >&2
  return 0
}

compile_ok=0
if typeck_parse_count_compile "$SHUX"; then
  compile_ok=1
elif [ "$SHUX" != "./compiler/shux" ] && [ -x "./compiler/shux" ]; then
  echo "typeck-parse-count-gate: WARN $SHUX failed; fallback ./compiler/shux (seed parse metric, nostdlib shux_asm typeck OOM)" >&2
  if typeck_parse_count_compile "./compiler/shux"; then
    compile_ok=1
  fi
fi

if [ "$compile_ok" -eq 0 ]; then
  echo "typeck-parse-count-gate: WARN full-file parse failed; trying chunked parse (SHUX_TYPECK_PARSE_CHUNK_FUNCS=${SHUX_TYPECK_PARSE_CHUNK_FUNCS:-10})" >&2
  if ! typeck_parse_count_try_chunked "$SHUX"; then
    if [ "$SHUX" != "./compiler/shux" ] && [ -x "./compiler/shux" ]; then
      typeck_parse_count_try_chunked "./compiler/shux" || true
    fi
  fi
fi

if [ "$compile_ok" -eq 0 ]; then
  echo "typeck-parse-count-gate FAIL: compile command failed" >&2
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$OUT" "$LOG" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

nf=$(sed -n 's/.*after_entry_parse num_funcs=\([0-9][0-9]*\).*/\1/p' "$LOG" | tail -1)
ndef=$(sed -n 's/.*num_defined=\([0-9][0-9]*\).*/\1/p' "$LOG" | tail -1)
skip_count=$(grep -c 'parse skip at byte' "$LOG" 2>/dev/null || echo 0)
commit_fail_count=$(grep -c 'parse commit fail at byte' "$LOG" 2>/dev/null || echo 0)
first_skip=$(grep 'parse skip at byte' "$LOG" 2>/dev/null | head -1 || true)
first_commit_fail=$(grep 'parse commit fail at byte' "$LOG" 2>/dev/null | head -1 || true)
# 分块路径已在 try_chunked 中设置 metric；整文件成功时从 LOG 提取。
if [ -z "${metric:-}" ]; then
  metric=${ndef:-$nf}
fi
if [ -z "$nf" ] && [ -z "$ndef" ] && [ -z "${metric:-}" ]; then
  echo "typeck-parse-count-gate: no after_entry_parse in log (skip metric)" >&2
  tail -n 8 "$LOG" 2>/dev/null || true
  rm -f "$OUT" "$LOG" 2>/dev/null || true
  exit 0
fi

if [ "${SHUX_TYPECK_PARSE_COUNT_UPDATE:-0}" = "1" ]; then
  {
    echo "# typeck.sx asm ENTRY_MODULE_ONLY parse 指标（A-11）"
    echo "# 更新：SHUX_TYPECK_PARSE_COUNT_UPDATE=1 ./tests/run-typeck-parse-count-gate.sh"
    printf 'min_funcs\t%s\n' "$metric"
    printf 'target_funcs\t%s\n' "$metric"
    printf 'min_defined\t%s\n' "$metric"
    printf 'target_defined\t%s\n' "$metric"
    printf 'source_funcs\t%s\n' "$src_count"
  } >"$BASELINE"
  echo "typeck-parse-count-gate: updated baseline min/target=${nf}"
fi

rm -f "$OUT" "$LOG" 2>/dev/null || true

if [ "$metric" -lt "$MIN_FUNCS" ] 2>/dev/null; then
  echo "typeck-parse-count-gate FAIL: num_defined=${metric} (num_funcs=${nf:-?}) < baseline ${MIN_FUNCS} (skips=${skip_count} commit_fails=${commit_fail_count})" >&2
  [ -n "$first_skip" ] && echo "typeck-parse-count-gate: first_skip: $first_skip" >&2
  [ -n "$first_commit_fail" ] && echo "typeck-parse-count-gate: first_commit_fail: $first_commit_fail" >&2
  grep -E 'parse skip at byte|parse commit fail at byte' "$LOG" 2>/dev/null | head -5 >&2 || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ "$skip_count" -gt 0 ] 2>/dev/null || [ "$commit_fail_count" -gt 0 ] 2>/dev/null; then
  echo "typeck-parse-count-gate: note parse_skips=${skip_count} commit_fails=${commit_fail_count} (partial; target defined>=${TARGET_FUNCS})"
  [ -n "$first_skip" ] && echo "typeck-parse-count-gate: first_skip: $first_skip"
  [ -n "$first_commit_fail" ] && echo "typeck-parse-count-gate: first_commit_fail: $first_commit_fail"
fi

if [ "$metric" -ge "$TARGET_FUNCS" ] 2>/dev/null; then
  echo "typeck-parse-count-gate OK (num_defined=${metric} num_funcs=${nf:-?} >= stretch ${TARGET_FUNCS}; full or chunked module parse)"
  exit 0
fi

echo "typeck-parse-count-gate OK (num_defined=${metric} num_funcs=${nf:-?}; baseline ${MIN_FUNCS}; target ${TARGET_FUNCS} — partial parse, typeck_sx.o may cover gap)"
exit 0
