#!/usr/bin/env bash
# BOOT-004：自举阶段化诊断门禁
#
# manifest + fixture 分类烟测（不跑真实自举）。
# 用法：./tests/run-bootstrap-stage-diag-gate.sh
set -e
cd "$(dirname "$0")/.."

PATTERNS="${SHUX_BOOT_STAGE_PATTERNS:-tests/baseline/bootstrap-stage-patterns.tsv}"
FIXTURES="${SHUX_BOOT_STAGE_FIXTURES:-tests/baseline/bootstrap-stage-diag-fixtures.tsv}"
LIB="tests/lib/bootstrap-stage-diag.sh"
FIX_DIR="tests/fixtures/bootstrap-stage-diag"

echo "=== BOOT-004: bootstrap stage diag manifest ==="
for f in \
  analysis/boot-stage-diag-v1.md \
  "$PATTERNS" \
  "$FIXTURES" \
  "$LIB" \
  tests/run-bootstrap-stage-diag.sh; do
  if [ ! -f "$f" ]; then
    echo "bootstrap-stage-diag gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "bootstrap-stage-diag manifest OK"

# shellcheck source=tests/lib/bootstrap-stage-diag.sh
. "$LIB"

FAILS=0
echo "=== BOOT-004: fixture classification ==="
while IFS=$'\t' read -r fid logfile exp_stage exp_repro; do
  [ -z "${fid:-}" ] && continue
  case "$fid" in \#*) continue ;; esac
  local_path="$FIX_DIR/$logfile"
  if [ ! -f "$local_path" ]; then
    echo "bootstrap-stage-diag FAIL: missing fixture $local_path" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  log="$(cat "$local_path")"
  got_stage=""
  got_repro=""
  while IFS='=' read -r k v; do
    case "$k" in
      SHUX_BOOT_STAGE) got_stage="$v" ;;
      SHUX_BOOT_REPRO) got_repro="$v" ;;
    esac
  done < <(bootstrap_stage_classify "$log" 2>/dev/null || true)

  if [ "$got_stage" != "$exp_stage" ] || [ "$got_repro" != "$exp_repro" ]; then
    echo "bootstrap-stage-diag FAIL $fid: stage=$got_stage want=$exp_stage repro=$got_repro want=$exp_repro" >&2
    FAILS=$((FAILS + 1))
  else
    echo "bootstrap-stage-diag OK $fid → $exp_stage / $exp_repro"
  fi
done < "$FIXTURES"

if [ "$FAILS" -gt 0 ]; then
  echo "bootstrap-stage-diag gate FAIL: ${FAILS} fixture(s)" >&2
  exit 1
fi

echo "bootstrap-stage-diag gate OK"
