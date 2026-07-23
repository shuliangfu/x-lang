#!/usr/bin/env bash
# C-05 v1：LSP lsp_diag.x 链入 + --lsp 烟测（方案 B 子集）。
#
# 用法：./tests/run-c05-lsp-x-gate.sh
# 环境：
#   XLANG_C05_FAIL=1           — 失败时硬退出
#   XLANG_C05_MANIFEST_ONLY=1  — 仅 manifest，不跑 LSP 烟测
#   XLANG=./compiler/xlang      — 默认 bootstrap seed xlang
set -e
cd "$(dirname "$0")/.."

FAIL=${XLANG_C05_FAIL:-0}
DOC="analysis/phase-c-c05-v1.md"
MANIFEST="tests/baseline/c05-lsp-x-manifest.tsv"
MF="compiler/Makefile"
LSP_X="compiler/src/lsp/lsp_diag.x"
XLANG_BIN="${XLANG:-./compiler/xlang}"

die() {
  echo "c05 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

# 探测二进制是否为当前宿主可执行格式。
native_shu() {
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

echo "=== C-05: LSP lsp_diag.x (v1) ==="
for f in "$DOC" "$MANIFEST" "$MF" "$LSP_X" \
  compiler/seeds/lsp_diag_pipeline_ctx.from_x.c tests/run-lsp.sh tests/run-lsp-completion.sh; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'C-05 v1' "$DOC" || die "doc missing C-05 v1 marker"
grep -q 'pipeline_lsp_diag_parse_typeck_buf' "$LSP_X" || die "lsp_diag.x missing pipeline hook"
grep -q 'lsp_diag_gen.c' "$MF" || die "Makefile missing lsp_diag_gen.c rule"
grep -q 'lsp_diag_x.o' "$MF" || die "Makefile missing lsp_diag_x.o"
grep -q 'lsp_diag_pipeline_ctx' "$MF" || die "Makefile missing lsp_diag_pipeline_ctx (hosts former lsp_diag_x_alias)"
grep -q 'bootstrap-driver-seed' "$MF" || die "Makefile missing bootstrap-driver-seed"

if [ "${XLANG_C05_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "c05 lsp-x gate OK (manifest only)"
  exit 0
fi

if ! native_shu "$XLANG_BIN"; then
  for cand in ./compiler/xlang ./compiler/xlang-x ./compiler/xlang-c; do
    if native_shu "$cand"; then
      XLANG_BIN="$cand"
      break
    fi
  done
fi

if ! native_shu "$XLANG_BIN"; then
  echo "c05 lsp-x gate: SKIP smoke (no native xlang; manifest OK)"
  exit 0
fi

if ! "$XLANG_BIN" --help 2>/dev/null | grep -q '\-\-lsp'; then
  echo "c05: building bootstrap-driver-seed for --lsp ..."
  make -C compiler bootstrap-driver-seed >/dev/null
  XLANG_BIN=./compiler/xlang
fi

echo "=== C-05: delegate run-lsp.sh (XLANG=$XLANG_BIN) ==="
chmod +x tests/run-lsp.sh
if ! XLANG="$XLANG_BIN" ./tests/run-lsp.sh; then
  die "run-lsp.sh failed"
fi

echo "c05 lsp-x gate OK (lsp_diag.x wired + --lsp smoke)"
