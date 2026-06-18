#!/usr/bin/env bash
# track-only：pipeline_wpo opt-in（WPO helper + C orchestration）须能编 return-value 且不 SIGSEGV。
# 用法：./tests/run-pipeline-wpo-optin-smoke.sh
# 前置：compiler/shu_asm 或 build_asm/pipeline_wpo.o 已存在（ensure-wpo 或 bootstrap-driver-bstrict）。
set -e
cd "$(dirname "$0")/.."

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

if [ ! -x compiler/shu ] && [ ! -x compiler/shu-su ]; then
  echo "pipeline-wpo-optin: SKIP (no seed shu; make -C compiler all)" >&2
  exit 0
fi

chmod +x tests/ensure-wpo-build-asm-artifacts.sh compiler/scripts/relink_shu_asm_strict_glue.sh
SHU_WPO_REBUILD_ARTIFACTS_ONLY=1 ./tests/ensure-wpo-build-asm-artifacts.sh

if [ ! -f compiler/build_asm/pipeline_wpo.o ]; then
  echo "pipeline-wpo-optin: SKIP (no pipeline_wpo.o)" >&2
  exit 0
fi

echo "pipeline-wpo-optin: relink strict_glue (SHU_ASM_STRICT_LINK_PIPELINE_WPO=1) ..."
rm -f compiler/build_asm/pipeline_wpo_helpers_partial.o \
  compiler/build_asm/pipeline_wpo_helpers_export.txt \
  compiler/build_asm/.pipeline_wpo_helpers_export_syms.txt
(
  cd compiler
  export SHU_ASM_STRICT_LINK_PIPELINE_WPO=1
  export SHU_ASM_STRICT_LINK_PIPELINE_WPO_FULL=0
  export STRICT_LINK_BUILD_ASM_PIPELINE=1
  ./scripts/relink_shu_asm_strict_glue.sh 2>&1 | tee /tmp/pipeline_wpo_optin_relink.log
)

if ! grep -q 'pipeline_wpo_helpers' /tmp/pipeline_wpo_optin_relink.log; then
  echo "pipeline-wpo-optin FAIL: relink log missing pipeline_wpo_helpers link line" >&2
  exit 1
fi

if [ ! -x compiler/shu_asm.strict_glue ]; then
  echo "pipeline-wpo-optin FAIL: shu_asm.strict_glue not built" >&2
  exit 1
fi

echo "pipeline-wpo-optin: compile+run return-value ..."
OUT="/tmp/shu_wpo_optin_rv"
rm -f "$OUT"
(
  cd compiler
  ulimit -s 65532 2>/dev/null || true
  ./shu_asm.strict_glue ../tests/return-value/main.su -o "$OUT" -backend asm
)
if [ ! -x "$OUT" ]; then
  echo "pipeline-wpo-optin FAIL: no executable at $OUT" >&2
  exit 1
fi
RC=0
"$OUT" || RC=$?
if [ "$RC" -ne 42 ]; then
  echo "pipeline-wpo-optin FAIL: exit $RC (expected 42)" >&2
  exit 1
fi

echo "pipeline-wpo-optin OK (WPO helpers + SU runtime bootstrap, return-value 42)"
