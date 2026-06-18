#!/usr/bin/env bash
# BOOT-004：自举失败日志阶段诊断入口
#
# 从 CI / 本地 log 自动定位编译流水线阶段，并可选触发最小复现。
# 用法：
#   ./tests/run-bootstrap-stage-diag.sh ci.log
#   ./tests/run-bootstrap-stage-diag.sh --stdin < ci.log
#   ./tests/run-bootstrap-stage-diag.sh --repro ci.log   # 诊断后自动跑 repro
set -e
cd "$(dirname "$0")/.."

LIB="tests/lib/bootstrap-stage-diag.sh"
REPRO="tests/run-bootstrap-repro.sh"

if [ ! -f "$LIB" ]; then
  echo "bootstrap-stage-diag FAIL: missing $LIB" >&2
  exit 1
fi
# shellcheck source=tests/lib/bootstrap-stage-diag.sh
. "$LIB"

DO_REPRO=0
LOG_ARG=""
for arg in "$@"; do
  case "$arg" in
    --repro|-r) DO_REPRO=1 ;;
    --stdin) LOG_ARG="--stdin" ;;
    *)
      if [ -z "$LOG_ARG" ] || [ "$LOG_ARG" = "--stdin" ]; then
        LOG_ARG="$arg"
      fi
      ;;
  esac
done

if [ -z "$LOG_ARG" ]; then
  echo "Usage: $0 [--repro] [--stdin | logfile]" >&2
  exit 1
fi

OUT="$(mktemp /tmp/shu_boot_stage_diag.XXXXXX)"
if ! bootstrap_stage_classify "$(read_log "$LOG_ARG")" >"$OUT"; then
  cat "$OUT"
  rm -f "$OUT"
  exit 1
fi
cat "$OUT"

# shellcheck disable=SC1090
source "$OUT"
rm -f "$OUT"

if [ "$DO_REPRO" -eq 1 ] && [ -n "${SHU_BOOT_REPRO:-}" ] && [ "$SHU_BOOT_REPRO" != "full_ci" ]; then
  echo "=== bootstrap-stage-diag: running repro $SHU_BOOT_REPRO ==="
  chmod +x "$REPRO" 2>/dev/null || true
  "$REPRO" "$SHU_BOOT_REPRO"
elif [ "$DO_REPRO" -eq 1 ]; then
  echo "=== bootstrap-stage-diag: low confidence — running full_ci ==="
  "$REPRO" full_ci
fi
