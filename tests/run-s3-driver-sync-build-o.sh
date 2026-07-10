#!/usr/bin/env bash
# 将 EMIT_HEAVY + WPO 产物写入 compiler/build_asm/，供 S3 driver gate 与 WPO dogfood 使用。
# - driver_compile_emit_heavy.o：全量 EMIT_HEAVY（strict link / S3 insn 门禁）
# - driver_compile.o：WPO 压缩 entry TU（dogfood / run-wpo-driver-o-gate）
# - driver_compile_link.o：ld -r(emit_heavy + link_alias)
# 用法：./tests/run-s3-driver-sync-build-o.sh
set -e
cd "$(dirname "$0")/.."
DEST="compiler/build_asm/driver_compile.o"
DEST_EH="compiler/build_asm/driver_compile_emit_heavy.o"
BASELINE="${SHUX_S3_DRIVER_EMIT_BASELINE:-tests/baseline/s3-driver-o.tsv}"
MIN_TEXT_EH=$(awk -F'\t' '$1=="min_text_emit_heavy" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT_EH=${MIN_TEXT_EH:-256}

text_section_size() {
  local o="$1"
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && { echo 0; return; }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

# ── 1) EMIT_HEAVY 全量（strict link 必需）──
emit_heavy_ok=0
if [ -n "${SHUX_S3_EMIT_HEAVY_COMPILER:-}" ] && [ -x "${SHUX_S3_EMIT_HEAVY_COMPILER}" ]; then
  if SHUX_S3_EMIT_HEAVY_COMPILER="${SHUX_S3_EMIT_HEAVY_COMPILER}" ./tests/run-s3-driver-emit-heavy.sh; then
    emit_heavy_ok=1
  fi
fi
if [ "$emit_heavy_ok" -eq 0 ]; then
  for cand in ./compiler/shux_asm.strict_glue ./compiler/shux_asm.experimental ./compiler/shux_asm; do
    [ -x "$cand" ] || continue
    echo "s3 driver sync-build-o: trying emit-heavy with $cand ..."
    if SHUX_S3_EMIT_HEAVY_COMPILER="$cand" ./tests/run-s3-driver-emit-heavy.sh; then
      export SHUX_S3_EMIT_HEAVY_COMPILER="$cand"
      emit_heavy_ok=1
      break
    fi
  done
fi
if [ "$emit_heavy_ok" -eq 0 ]; then
  echo "s3 driver sync-build-o: emit-heavy failed (all compilers)" >&2
  exit 1
fi

SRC="/tmp/shux_s3_driver_emit_heavy.o"
[ -f "$SRC" ] || {
  echo "s3 driver sync-build-o: missing $SRC" >&2
  exit 1
}

mkdir -p "$(dirname "$DEST")"
cp -f "$SRC" "$DEST_EH"
eh_sz=$(text_section_size "$DEST_EH")
echo "s3 driver sync-build-o: wrote $DEST_EH __text=${eh_sz} (min_text_emit_heavy=${MIN_TEXT_EH})"

if [ "${SHUX_S3_FAIL_ON_EMIT_HEAVY:-0}" = "1" ]; then
  if ! awk -v s="$eh_sz" -v m="$MIN_TEXT_EH" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
    echo "s3 driver sync-build-o FAIL: emit_heavy __text ${eh_sz} < min_text_emit_heavy ${MIN_TEXT_EH}" >&2
    exit 1
  fi
fi

# ── 2) WPO 压缩 driver_compile.o（dogfood；失败则回退 emit_heavy 副本）──
WPO_OK=0
COMP="${SHUX_S3_EMIT_HEAVY_COMPILER:-./compiler/shux_asm.experimental}"
LIBROOT="-L compiler/asm_libroot -L compiler/.. -L compiler/src -L compiler/src/lexer -L compiler/src/ast -L compiler/src/parser -L compiler/src/typeck -L compiler/src/codegen -L compiler/src/preprocess -L compiler/src/pipeline -L compiler/src/lsp -L compiler/src/asm"
WPO_TMP="/tmp/shux_s3_driver_wpo.o"
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
if [ -x "$COMP" ]; then
  rm -f "$WPO_TMP" 2>/dev/null || true
  if env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 \
    SHUX_ASM_WPO_DCE=1 \
    "$COMP" -backend asm -o "$WPO_TMP" $LIBROOT compiler/src/driver/compile.x 2>/dev/null; then
    wpo_sz=$(text_section_size "$WPO_TMP")
    if [ "$wpo_sz" -gt 0 ] && [ "$wpo_sz" -le 768 ] 2>/dev/null && \
       nm "$WPO_TMP" 2>/dev/null | grep -qE ' T (compile_dispatch_asm_backend|run_compiler_full_x|entry)$'; then
      cp -f "$WPO_TMP" "$DEST"
      echo "s3 driver sync-build-o: wrote $DEST __text=${wpo_sz} (WPO entry-only)"
      WPO_OK=1
    fi
  fi
fi
if [ "$WPO_OK" -eq 0 ]; then
  cp -f "$DEST_EH" "$DEST"
  echo "s3 driver sync-build-o: WPO fallback — $DEST = emit_heavy copy (__text=${eh_sz})"
fi

# ── 3) ld -r：emit_heavy + link_alias → driver_compile_link.o ──
# G-02e-15：alias 源为 .inc，经 compiler/scripts/cc_inc_tu.sh 编译
LINK_ALIAS_INC="compiler/seeds/driver_compile_asm_link_alias.from_x.c"
LINK_ALIAS_O="compiler/build_asm/driver_compile_asm_link_alias.o"
LINK_O="compiler/build_asm/driver_compile_link.o"
if [ -f "$LINK_ALIAS_INC" ]; then
  # cc_inc_tu 在 compiler/ 下解析路径；此处从仓库根调用
  ( cd compiler && sh scripts/cc_inc_tu.sh seeds/driver_compile_asm_link_alias.from_x.c build_asm/driver_compile_asm_link_alias.o )
  ld -r -o "$LINK_O" "$DEST_EH" "$LINK_ALIAS_O"
  if nm "$LINK_O" 2>/dev/null | grep -q ' T _driver_run_compiler_full_x$'; then
    echo "s3 driver sync-build-o: wrote $LINK_O (driver_run_compiler_full_x alias OK)"
  else
    echo "s3 driver sync-build-o: warn: $LINK_O missing driver_run_compiler_full_x" >&2
  fi
fi

echo "s3 driver sync-build-o OK ($DEST wpo=${WPO_OK}; $DEST_EH __text=${eh_sz})"
