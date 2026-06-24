#!/usr/bin/env bash
# NL-07 v3：编译器 bootstrap nostdlib 链入烟测（Linux x86_64 硬绿；其它平台 SKIP）。
#
# 用法：./tests/run-nolibc-n07-v3-link-gate.sh
# 环境：
#   SHUX_NOLIBC_N07_V3_FAIL=1              — 失败时硬退出
#   SHUX_NOLIBC_N07_V3_MANIFEST_ONLY=1    — 仅 manifest 审计
#   SHUX_NOLIBC_N07_LINK_SMOKE_WITH_PANIC=0 — 不链 runtime_panic.o
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NOLIBC_N07_V3_FAIL:-0}
DOC="analysis/phase-f-n07-v3.md"
MANIFEST="tests/baseline/nolibc-n07-v3-link.tsv"
SMOKE_LIB="tests/lib/nolibc-n07-link-smoke.sh"
SMOKE_C="tests/fixtures/nolibc-n07-bootstrap-smoke.c"

die() {
  echo "nolibc-n07-v3 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== NL-07 v3: bootstrap nostdlib link smoke (Linux x86_64) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'NL-07 v3' "$DOC" || die "doc missing NL-07 v3 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f "$SMOKE_LIB" ] || die "missing $SMOKE_LIB"
[ -f "$SMOKE_C" ] || die "missing $SMOKE_C"

while IFS=$'\t' read -r item_id category anchor check_type notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in
    exists)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    grep)
      if [ ! -f "$anchor" ] || ! grep -qF "$notes" "$anchor" 2>/dev/null; then
        die "grep fail: $anchor need '$notes' ($item_id)"
      fi
      ;;
    gate_ref)
      [ -f "$anchor" ] || die "missing gate $anchor ($item_id)"
      ;;
  esac
done < "$MANIFEST"

if [ "${SHUX_NOLIBC_N07_V3_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "nolibc-n07-v3 gate OK (manifest only)"
  exit 0
fi

if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  echo "nolibc-n07-v3 SKIP link smoke (need Linux x86_64; use Docker: SHUX_DOCKER_PLATFORM=linux/amd64)" >&2
  echo "nolibc-n07-v3 gate OK (manifest; link smoke skipped)"
  exit 0
fi

# shellcheck source=tests/lib/nolibc-n07-link-smoke.sh
. "$SMOKE_LIB"
if ! nolibc_n07_run_bootstrap_link_smoke; then
  die "bootstrap nostdlib link smoke failed"
fi

echo "nolibc-n07-v3 gate OK (nostdlib link smoke hard green on Linux x86_64)"
