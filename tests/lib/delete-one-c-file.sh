#!/usr/bin/env bash
# delete-one-c-file.sh — 阶段 G 单文件删 C/H + 快速回归 + 单文件 git commit
#
# 用法（仓库根）：
#   ./tests/lib/delete-one-c-file.sh compiler/src/lexer/lexer.c "lexer.x self-host"
#   SHUX_DELETE_C_SKIP_GIT=1 ./tests/lib/delete-one-c-file.sh path/to/file.c "reason"
#   SHUX_DELETE_C_SKIP_REGRESS=1 ./tests/lib/delete-one-c-file.sh path/to/file.c "reason"
#
# 环境：
#   SHUX_DELETE_C_SKIP_GIT=1       — 不 git commit
#   SHUX_DELETE_C_SKIP_REGRESS=1   — 不跑 E-soft / D-03
#   SHUX_DELETE_C_DOCKER=1         — 在 Linux amd64 Docker 内跑回归

set -euo pipefail
cd "$(dirname "$0")/../.."

TARGET="${1:-}"
REASON="${2:-x migration}"
PROGRESS="./tests/lib/progress-run.sh"

usage() {
  echo "usage: $0 <path-to-.c-or-.h> [commit-reason-snippet]" >&2
  exit 2
}

[ -n "$TARGET" ] || usage
[ -f "$TARGET" ] || { echo "delete-one-c-file: missing $TARGET" >&2; exit 1; }

case "$TARGET" in
  *.c|*.h) ;;
  *) echo "delete-one-c-file: not a .c/.h file: $TARGET" >&2; exit 2 ;;
esac

progress() {
  echo "[$(date +%H:%M:%S)] delete-c $*"
}

run_regress() {
  if [ "${SHUX_DELETE_C_SKIP_REGRESS:-0}" = "1" ]; then
    progress "SKIP regress (SHUX_DELETE_C_SKIP_REGRESS=1)"
    return 0
  fi
  chmod +x "$PROGRESS" tests/run-e-soft-retire-gate.sh tests/run-d03-stage2-hash-gate.sh 2>/dev/null || true
  progress "regress E-soft ..."
  SHUX_E_SOFT_FAIL=1 ./tests/run-e-soft-retire-gate.sh
  if [ "${SHUX_DELETE_C_DOCKER:-0}" = "1" ]; then
    progress "regress Docker bootstrap + D-03 ..."
    docker run --rm --platform linux/amd64 -v "$(pwd):/src" -w /src ubuntu:22.04 bash -lc '
      set -e
      apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq gcc make >/dev/null
      make -C compiler bootstrap-driver-bstrict
      SHUX_D03_FAIL=1 ./tests/run-d03-stage2-hash-gate.sh
    '
  else
    progress "regress bootstrap-driver-bstrict (host) ..."
    make -C compiler bootstrap-driver-bstrict -q 2>/dev/null || make -C compiler bootstrap-driver-bstrict
    progress "regress D-03 ..."
    SHUX_D03_FAIL=1 ./tests/run-d03-stage2-hash-gate.sh
  fi
}

progress "remove $TARGET ($REASON)"
rm -f "$TARGET"

# 刷新 F-09 whitelist（若 gate 存在）
if [ -f tests/run-no-handwritten-c-gate.sh ]; then
  SHUX_NO_HANDWRITTEN_C_UPDATE=1 ./tests/run-no-handwritten-c-gate.sh 2>/dev/null || true
fi

run_regress

if [ "${SHUX_DELETE_C_SKIP_GIT:-0}" = "1" ]; then
  progress "SKIP git (SHUX_DELETE_C_SKIP_GIT=1)"
  progress "OK removed $TARGET"
  exit 0
fi

base="$(basename "$TARGET")"
git add "$TARGET"
if [ -f tests/baseline/no-handwritten-c-whitelist.tsv ]; then
  git add tests/baseline/no-handwritten-c-whitelist.tsv
fi

git commit -m "$(cat <<EOF
refactor(compiler): remove $base after $REASON
EOF
)"

progress "OK committed removal of $TARGET"
