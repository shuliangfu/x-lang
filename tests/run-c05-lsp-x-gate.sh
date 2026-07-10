#!/usr/bin/env bash
# C-05 v1：LSP lsp_diag.x 链入 + --lsp 烟测（方案 B 子集）。
#
# 用法：./tests/run-c05-lsp-x-gate.sh
# 环境：
# SHUX_C05_FAIL=1 — 失败时硬退出
# SHUX_C05_MANIFEST_ONLY=1 — 仅 manifest，不跑 LSP 烟测
# SHUX=./compiler/shux — 默认 bootstrap seed shux
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_C05_FAIL:-0}
DOC="analysis/phase-c-c05-v1.md"
MANIFEST="tests/baseline/c05-lsp-x-manifest.tsv"
MF="compiler/Makefile"
LSP_X="compiler/src/lsp/lsp_diag.x"
SHUX_BIN="${SHUX:-./compiler/shux}"

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
 compiler/src/lsp/lsp_diag_pipeline_ctx.c tests/run-lsp.sh tests/run-lsp-completion.sh; do
 [ -f "$f" ] || die "missing $f"
done
grep -q 'C-05 v1' "$DOC" || die "doc missing C-05 v1 marker"
grep -q 'pipeline_lsp_diag_parse_typeck_buf' "$LSP_X" || die "lsp_diag.x missing pipeline hook"
grep -q 'lsp_diag_gen.c' "$MF" || die "Makefile missing lsp_diag_gen.c rule"
grep -q 'lsp_diag_x.o' "$MF" || die "Makefile missing lsp_diag_x.o"
grep -q 'lsp_diag_pipeline_ctx' "$MF" || die "Makefile missing lsp_diag_pipeline_ctx (hosts former lsp_diag_x_alias)"
grep -q 'bootstrap-driver-seed' "$MF" || die "Makefile missing bootstrap-driver-seed"

if [ "${SHUX_C05_MANIFEST_ONLY:-0}" = "1" ]; then
 echo "c05 lsp-x gate OK (manifest only)"
 exit 0
fi

if ! native_shu "$SHUX_BIN"; then
 for cand in ./compiler/shux ./compiler/shux-x ./compiler/shux-c; do
 if native_shu "$cand"; then
 SHUX_BIN="$cand"
 break
 fi
 done
fi

if ! native_shu "$SHUX_BIN"; then
 echo "c05 lsp-x gate: SKIP smoke (no native shux; manifest OK)"
 exit 0
fi

if ! "$SHUX_BIN" --help 2>/dev/null | grep -q '\-\-lsp'; then
 echo "c05: building bootstrap-driver-seed for --lsp ..."
 make -C compiler bootstrap-driver-seed >/dev/null
 SHUX_BIN=./compiler/shux
fi

echo "=== C-05: delegate run-lsp.sh (SHUX=$SHUX_BIN) ==="
chmod +x tests/run-lsp.sh
if ! SHUX="$SHUX_BIN" ./tests/run-lsp.sh; then
 die "run-lsp.sh failed"
fi

echo "c05 lsp-x gate OK (lsp_diag.x wired + --lsp smoke)"
