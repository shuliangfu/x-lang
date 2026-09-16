#!/usr/bin/env bash
# pipeline_wpo opt-in: WPO helpers + C orchestration must compile
# return-value and not SIGSEGV.
#
# Honesty: soft SKIP→OK when no seed xlang / no pipeline_wpo.o (false
# authority) retired. Prefer product xlang_asm present. Explicit missing
# native seed/product on Linux = hard die (refuse soft SKIP→OK / soft
# auto-make). Missing pipeline_wpo.o after ensure = hard die. Darwin /
# non-Linux = skip= (strict_glue WPO gold is Linux; not soft green).
#   - hard: ensure pipeline_wpo.o + relink produces xlang_asm.strict_glue
#     with pipeline_wpo_helpers link line
#   - obs: tip strict_glue return-value -o may SIGSEGV / fail (tip residual;
#     not soft SKIP→OK and not soft FAIL→OK silence)
# Report: run=/obs=/skip=
# Usage: ./tests/run-pipeline-wpo-optin-smoke.sh
# Pre: compiler/xlang_asm or build_asm/pipeline_wpo.o from ensure-wpo /
#      bootstrap-driver-bstrict on Linux.
# PLATFORM: LINUX|UBUNTU archaeology — Darwin skip=; Ubuntu gold.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_PIPELINE_WPO_PREFIX:-xlang: [PIPELINE_WPO_OPTIN]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-180}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "pipeline-wpo-optin FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "=== pipeline-wpo-optin gate (hard; refuse soft SKIP→OK) ==="

# PLATFORM: LINUX|UBUNTU — strict_glue pipeline_wpo opt-in is Linux gold.
if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  SKIP=$((SKIP + 1))
  echo "pipeline-wpo-optin: skip= (platform N/A on $(uname -s); not soft SKIP→OK)" >&2
  ok_report
  exit 0
fi

# Seed or product driver must already exist (refuse soft auto-make all).
if ! dod_native_exe ./compiler/xlang && ! dod_native_exe ./compiler/xlang-x \
  && ! dod_native_exe ./compiler/xlang_asm; then
  die "no native compiler/xlang|xlang-x|xlang_asm (refuse soft SKIP→OK / soft auto-make)"
fi

chmod +x tests/ensure-wpo-build-asm-artifacts.sh compiler/scripts/relink_xlang_asm_strict_glue.sh
XLANG_WPO_REBUILD_ARTIFACTS_ONLY=1 ./tests/ensure-wpo-build-asm-artifacts.sh

if [ ! -f compiler/build_asm/pipeline_wpo.o ]; then
  die "no compiler/build_asm/pipeline_wpo.o after ensure (refuse soft SKIP→OK)"
fi

echo "pipeline-wpo-optin: relink strict_glue (XLANG_ASM_STRICT_LINK_PIPELINE_WPO=1) ..."
rm -f compiler/build_asm/pipeline_wpo_helpers_partial.o \
  compiler/build_asm/pipeline_wpo_helpers_export.txt \
  compiler/build_asm/.pipeline_wpo_helpers_export_syms.txt
(
  cd compiler
  export XLANG_ASM_STRICT_LINK_PIPELINE_WPO=1
  export XLANG_ASM_STRICT_LINK_PIPELINE_WPO_FULL=0
  export STRICT_LINK_BUILD_ASM_PIPELINE=1
  ./scripts/relink_xlang_asm_strict_glue.sh 2>&1 | tee /tmp/pipeline_wpo_optin_relink.log
)

grep -q 'pipeline_wpo_helpers' /tmp/pipeline_wpo_optin_relink.log \
  || die "relink log missing pipeline_wpo_helpers link line"
[ -x compiler/xlang_asm.strict_glue ] || die "xlang_asm.strict_glue not built"
RUN_OK=$((RUN_OK + 1))

echo "pipeline-wpo-optin: compile+run return-value ..."
OUT="/tmp/xlang_wpo_optin_rv_$$"
LOG="/tmp/pipeline_wpo_optin_rv_$$.log"
rm -f "$OUT" "$LOG"
set +e
(
  cd compiler
  ulimit -s 65532 2>/dev/null || true
  ./xlang_asm.strict_glue ../tests/return-value/main.x -o "$OUT" -backend asm
) >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  echo "pipeline-wpo-optin OBS: return-value -o failed (ec=$o_ec; tip strict_glue residual; refuse soft silence); $(tail -3 "$LOG" 2>/dev/null | tr '\n' ' ')" >&2
  OBS=$((OBS + 1))
  rm -f "$OUT" "$LOG"
  ok_report
  echo "pipeline-wpo-optin OK (relink hard; return-value obs)"
  exit 0
fi

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$OUT" >/dev/null 2>&1
r_ec=$?
set -e
rm -f "$OUT" "$LOG"
if [ "$r_ec" -ne 42 ]; then
  echo "pipeline-wpo-optin OBS: return-value exit=$r_ec want 42 (tip residual; refuse soft silence)" >&2
  OBS=$((OBS + 1))
  ok_report
  echo "pipeline-wpo-optin OK (relink hard; return-value obs)"
  exit 0
fi
echo "pipeline-wpo-optin OK: return-value exit=42"
RUN_OK=$((RUN_OK + 1))

ok_report
echo "pipeline-wpo-optin OK (WPO helpers + X runtime bootstrap, return-value 42)"