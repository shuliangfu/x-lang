#!/usr/bin/env bash
# delete-one-c-file.sh — stage G single-file drop C/H + quick regress + optional commit
#
# Usage (repo root):
#   ./tests/lib/delete-one-c-file.sh compiler/src/lexer/lexer.c "lexer.x self-host"
#   XLANG_DELETE_C_SKIP_GIT=1 ./tests/lib/delete-one-c-file.sh path/to/file.c "reason"
#   XLANG_DELETE_C_SKIP_REGRESS=1 ./tests/lib/delete-one-c-file.sh path/to/file.c "reason"
#
# Env:
#   XLANG_DELETE_C_SKIP_GIT=1       — skip git commit
#   XLANG_DELETE_C_SKIP_REGRESS=1   — skip E-soft / D-03
#   XLANG_DELETE_C_DOCKER=1         — run regress inside Linux amd64 Docker
#
# wave731 · 11.4.6: outer build entry is ./xbuild (G.7). Residual make graph
# only via xbuild → run_compiler_make / build_tool.sh until stage 11.3/12.
# PLATFORM: SHARED shell entry · host-cc packages residual until stage 12.

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
  if [ "${XLANG_DELETE_C_SKIP_REGRESS:-0}" = "1" ]; then
    progress "SKIP regress (XLANG_DELETE_C_SKIP_REGRESS=1)"
    return 0
  fi
  chmod +x "$PROGRESS" ./xbuild ./xlang-build.sh \
    tests/run-e-soft-retire-gate.sh tests/run-d03-stage2-hash-gate.sh 2>/dev/null || true
  progress "regress E-soft ..."
  XLANG_E_SOFT_FAIL=1 ./tests/run-e-soft-retire-gate.sh
  if [ "${XLANG_DELETE_C_DOCKER:-0}" = "1" ]; then
    progress "regress Docker bootstrap + D-03 (./xbuild) ..."
    # Bare ubuntu: residual host-cc/make until stage 12 (seed graph / build_tool).
    # Prefer prebuilt xlang-linux-dev image when available (packages preinstalled).
    docker run --rm --platform linux/amd64 -v "$(pwd):/src" -w /src ubuntu:22.04 bash -lc '
      set -e
      if ! command -v cc >/dev/null 2>&1 || ! command -v make >/dev/null 2>&1; then
        apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq gcc make >/dev/null
      fi
      chmod +x ./xbuild ./xlang-build.sh
      ./xbuild bootstrap-driver-bstrict
      XLANG_D03_FAIL=1 ./tests/run-d03-stage2-hash-gate.sh
    '
  else
    progress "regress bootstrap-driver-bstrict via ./xbuild (host) ..."
    ./xbuild bootstrap-driver-bstrict
    progress "regress D-03 ..."
    XLANG_D03_FAIL=1 ./tests/run-d03-stage2-hash-gate.sh
  fi
}

progress "remove $TARGET ($REASON)"
rm -f "$TARGET"

# 刷新 F-09 whitelist（若 gate 存在）
if [ -f tests/run-no-handwritten-c-gate.sh ]; then
  XLANG_NO_HANDWRITTEN_C_UPDATE=1 ./tests/run-no-handwritten-c-gate.sh 2>/dev/null || true
fi

run_regress

if [ "${XLANG_DELETE_C_SKIP_GIT:-0}" = "1" ]; then
  progress "SKIP git (XLANG_DELETE_C_SKIP_GIT=1)"
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
