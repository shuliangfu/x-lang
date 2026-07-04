#!/usr/bin/env bash
# F-10 v1：make test_x + Stage2 portable 子集（无 shux 时 SKIP 不 FAIL）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F10_TEST_X_PORTABLE_FAIL:-0}
DOC="analysis/phase-f-f10-v1.md"
MANIFEST="tests/baseline/f10-test-x-portable.tsv"
die() { echo "f10-test-x-portable gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

echo "=== F-10 v1: test_x + portable subset ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-10 v1' "$DOC" || die "doc marker"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile|script) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    gate_ref) [ -f "$anchor" ] || die "missing gate_ref $anchor ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q '^test_x:' compiler/Makefile || die "Makefile missing test_x"
grep -q 'test_x' compiler/Makefile || die "compiler Makefile missing test_x"

SHUX_BIN=""
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux_asm && echo ./compiler/shux_asm || true)"; then
  :
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== F-10: make test_x (SHUX=$SHUX_BIN) ==="
  make -C compiler test_x >/dev/null 2>&1 || die "make test_x failed"
else
  echo "f10 SKIP make test_x (no native shux)" >&2
fi

if [ -f tests/run-d04-stage2-portable-diff-gate.sh ]; then
  echo "=== F-10: delegate d04 portable subset ==="
  chmod +x tests/run-d04-stage2-portable-diff-gate.sh
  tests/run-d04-stage2-portable-diff-gate.sh || die "d04 portable gate failed"
fi

echo "f10-test-x-portable gate OK"
