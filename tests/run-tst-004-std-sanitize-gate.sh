#!/usr/bin/env bash
# TST-004：std 模块 sanitizer 夜跑子集门禁
#
# 验收：manifest 登记 heap/channel ASAN 用例；本机 ASAN 可用时跑夜跑子集。
#
# 用法：./tests/run-tst-004-std-sanitize-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_TST004_DOC:-analysis/tst-004-std-sanitize-v1.md}"
MANIFEST="${SHUX_TST004_TSV:-tests/baseline/tst-004-std-sanitize.tsv}"
LIB="tests/lib/tst-004-std-sanitize.sh"
MIN_CASES=2

# shellcheck source=tests/lib/tst-004-std-sanitize.sh
. "$LIB"

echo "=== TST-004: std sanitizer manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" tests/run-tst-004-std-sanitize-nightly.sh \
  tests/sanitize/std_heap_asan.sx tests/sanitize/std_channel_asan.sx; do
  if [ ! -f "$f" ]; then
    echo "tst-004-sanitize gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in TST-004 ASAN heap channel sanitizer nightly; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "tst-004-sanitize gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_cases) MIN_CASES="$c2" ;; esac
done < "$MANIFEST"

miss="$(tst004_sanitize_verify_manifest "$MANIFEST" || true)"
if [ "${miss:-0}" -gt 0 ]; then
  tst004_sanitize_emit_report fail 0 0 0
  echo "tst-004-sanitize gate FAIL: manifest_miss=${miss}" >&2
  exit 1
fi
echo "tst-004-sanitize manifest OK"

CASE_N=0
while IFS=$'\t' read -r item_id kind _a _b _c _d; do
  [ -z "${item_id:-}" ] && continue
  case "$kind" in case) CASE_N=$((CASE_N + 1)) ;; esac
done < "$MANIFEST"

if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "tst-004-sanitize gate FAIL: cases $CASE_N < min $MIN_CASES" >&2
  tst004_sanitize_emit_report fail 0 0 0
  exit 1
fi

OK=0
FAIL=0
SKIP=0
if safe_leak_asan_ok; then
  echo "=== TST-004: ASAN smoke (nightly subset) ==="
  if ./tests/run-tst-004-std-sanitize-nightly.sh; then
    OK=$MIN_CASES
  else
    FAIL=1
    tst004_sanitize_emit_report fail 0 "$FAIL" 0
    exit 1
  fi
else
  echo "tst-004-sanitize gate SKIP ASAN smoke (cc no -fsanitize=address)" >&2
  SKIP=1
fi

tst004_sanitize_emit_report ok "$OK" "$FAIL" "$SKIP"
echo "tst-004-std-sanitize gate OK"
