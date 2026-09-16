#!/usr/bin/env bash
# S5: strict_glue real binary .text A/B (pipeline WPO helpers on/off).
# Complements proxy (run-perf-wpo-dce-xlang-asm-text.sh): reads final ELF
# .text, not A/B reverse inference.
#
# Honesty: soft XLANG_WPO_STRICT_GLUE_TEXT_FAIL retired — missing binary /
# .text growth over max was portable false-green (soft die→exit0) and
# missing pipeline_wpo.o soft-SKIP→OK. Missing artifacts after ensure is
# hard die. Growth over max is hard fail. Darwin stays N/A (Linux gold).
#
# Usage:
#   ./tests/run-wpo-strict-glue-text-gate.sh
#   XLANG_WPO_STRICT_GLUE_TEXT_UPDATE_BASELINE=1 ./tests/run-wpo-strict-glue-text-gate.sh
# Report: run=/skip=
# PLATFORM: LINUX|UBUNTU gold; DARWIN N/A (helpers A/B soft-skipped when
# abi on LD argv / multi-LC_SEGMENT).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. "$(dirname "$0")/lib/wpo-ab-proxy.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

text_bytes() { wpo_ab_text_bytes "$@"; }

STRICT_GLUE="${XLANG_WPO_STRICT_GLUE:-compiler/xlang_asm.strict_glue}"
UPDATE_BASELINE=${XLANG_WPO_STRICT_GLUE_TEXT_UPDATE_BASELINE:-0}
BASELINE="${XLANG_WPO_STRICT_GLUE_TEXT_BASELINE:-tests/baseline/wpo-strict-glue-text.tsv}"
MAX_GROWTH_BYTES=$(awk -F'\t' '$1=="max_text_growth_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE" 2>/dev/null)
MAX_GROWTH_BYTES=${MAX_GROWTH_BYTES:-8192}
PREFIX="xlang: [XLANG_WPO_STRICT_GLUE_TEXT]"

die() {
  echo "run-wpo-strict-glue-text-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=0 skip=0 host=$(ci_host_summary)"
  exit 1
}

# PLATFORM: MACOS — A/B .text growth needs helpers on vs off. Tip soft-skips
# helpers extract when abi is on LD argv (dual-authority / multi-LC_SEGMENT), so
# A/B is not meaningful on Darwin yet. Linux covers measured growth.
# (strict_link gate itself is SHARED and no longer hard-N/A on Darwin.)
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "run-wpo-strict-glue-text-gate: N/A on Darwin (helpers A/B soft-skipped when abi on argv; Linux covers)"
  echo "run-wpo-strict-glue-text-gate OK (Darwin N/A)"
  echo "${PREFIX} status=ok run=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

chmod +x tests/run-wpo-strict-link-gate.sh tests/ensure-wpo-build-asm-artifacts.sh \
  compiler/scripts/relink_xlang_asm_strict_glue.sh 2>/dev/null || true

echo "=== wpo strict_glue binary .text A/B (pipeline WPO helpers off vs on) ==="

if [ ! -f compiler/build_asm/pipeline_wpo.o ]; then
  echo "run-wpo-strict-glue-text-gate: ensure WPO build_asm artifacts ..."
  ./tests/ensure-wpo-build-asm-artifacts.sh
fi
if [ ! -f compiler/build_asm/pipeline_wpo.o ]; then
  die "no pipeline_wpo.o after ensure (refuse soft SKIP→OK)"
fi

# 强制重编 LSP/typeck_io 桩（strict_glue 链依赖）。
rm -f compiler/build_asm/asm_xlang_lsp_diag_stub.o 2>/dev/null || true

wpo_strict_glue_rm_pipeline_partials() {
  rm -f compiler/build_asm/pipeline_strict_link_partial.o \
    compiler/build_asm/pipeline_strict_link_export.txt \
    compiler/build_asm/pipeline_wpo_helpers_partial.o \
    compiler/build_asm/pipeline_wpo_helpers_export.txt \
    compiler/build_asm/.pipeline_wpo_helpers_export_syms.txt \
    compiler/build_asm/.pipeline_wpo_export_syms.txt
}

# A：无 pipeline WPO helpers（C orchestration only）
echo "run-wpo-strict-glue-text-gate: relink strict_glue (WPO helpers OFF) ..."
wpo_strict_glue_rm_pipeline_partials
(
  cd compiler
  export XLANG_ASM_STRICT_LINK_PIPELINE_WPO=0
  export STRICT_LINK_BUILD_ASM_PIPELINE=1
  export STRICT_LINK_BUILD_ASM_WPO=0
  export STRICT_LINK_BUILD_ASM_TYPECK_WPO=1
  export STRICT_LINK_BUILD_ASM_BACKEND_WPO=1
  ./scripts/relink_xlang_asm_strict_glue.sh >/tmp/wpo_strict_glue_text_off.log 2>&1
)

if [ ! -x "$STRICT_GLUE" ]; then
  tail -n 8 /tmp/wpo_strict_glue_text_off.log 2>/dev/null || true
  die "missing $STRICT_GLUE (WPO off)"
fi

TEXT_OFF=$(text_bytes "$STRICT_GLUE") || die "cannot read .text (WPO off)"

# B: link pipeline_wpo helpers + C orchestration (same as strict link gate)
wpo_strict_glue_rm_pipeline_partials
./tests/run-wpo-strict-link-gate.sh >/tmp/wpo_strict_glue_text_on.log 2>&1

TEXT_ON=$(text_bytes "$STRICT_GLUE") || {
  tail -n 8 /tmp/wpo_strict_glue_text_on.log 2>/dev/null || true
  die "cannot read .text (WPO on)"
}

SAVE=0
DELTA=0
PCT=0
if [ "$TEXT_ON" -gt "$TEXT_OFF" ]; then
  DELTA=$((TEXT_ON - TEXT_OFF))
  PCT=$(awk -v d="$DELTA" -v b="$TEXT_OFF" 'BEGIN { if (b > 0) printf "%.2f", d * 100 / b; else print "0.00" }')
elif [ "$TEXT_OFF" -gt "$TEXT_ON" ]; then
  SAVE=$((TEXT_OFF - TEXT_ON))
  PCT=$(awk -v s="$SAVE" -v b="$TEXT_OFF" 'BEGIN { if (b > 0) printf "%.2f", s * 100 / b; else print "0.00" }')
fi

echo "| variant | .text (B) |"
echo "| strict_glue (WPO helpers OFF) | $TEXT_OFF |"
echo "| strict_glue (WPO helpers ON) | $TEXT_ON |"
if [ "$DELTA" -gt 0 ]; then
  echo "| measured delta (on - off) | +${DELTA}B (${PCT}%) |"
else
  echo "| measured save (off - on) | ${SAVE}B (${PCT}%) |"
fi

if [ "$UPDATE_BASELINE" = "1" ]; then
  tmp="$(mktemp)"
  awk -F'\t' -v off="$TEXT_OFF" -v on="$TEXT_ON" -v delta="$DELTA" -v save="$SAVE" -v pct="$PCT" '
    BEGIN { updated_off=0; updated_on=0; updated_delta=0; updated_save=0; updated_pct=0 }
    $1 ~ /^#/ || NF == 0 { print; next }
    $1 == "text_off_bytes" { print "text_off_bytes\t" off; updated_off=1; next }
    $1 == "text_on_bytes" { print "text_on_bytes\t" on; updated_on=1; next }
    $1 == "measured_delta_bytes" { print "measured_delta_bytes\t" delta; updated_delta=1; next }
    $1 == "measured_save_bytes" { print "measured_save_bytes\t" save; updated_save=1; next }
    $1 == "measured_delta_pct" || $1 == "measured_save_pct" { print "measured_delta_pct\t" pct; updated_pct=1; next }
    { print }
    END {
      if (!updated_off) print "text_off_bytes\t" off
      if (!updated_on) print "text_on_bytes\t" on
      if (!updated_delta) print "measured_delta_bytes\t" delta
      if (!updated_save) print "measured_save_bytes\t" save
      if (!updated_pct) print "measured_delta_pct\t" pct
    }
  ' "$BASELINE" >"$tmp"
  mv -f "$tmp" "$BASELINE"
  echo "run-wpo-strict-glue-text-gate: baseline updated -> $BASELINE"
fi

if [ "$DELTA" -gt "$MAX_GROWTH_BYTES" ]; then
  die "WPO on .text growth ${DELTA}B > max ${MAX_GROWTH_BYTES}B"
fi

if [ "$DELTA" -gt 0 ]; then
  echo "run-wpo-strict-glue-text-gate OK (off=${TEXT_OFF}B on=${TEXT_ON}B delta=+${DELTA}B/${PCT}%, pipeline WPO helpers 略增 .text 实锤)"
  echo "${PREFIX} status=ok run=1 skip=0 host=$(ci_host_summary)"
  exit 0
fi

if [ "$SAVE" -gt 0 ]; then
  echo "run-wpo-strict-glue-text-gate OK (off=${TEXT_OFF}B on=${TEXT_ON}B save=${SAVE}B/${PCT}%)"
  echo "${PREFIX} status=ok run=1 skip=0 host=$(ci_host_summary)"
  exit 0
fi

echo "run-wpo-strict-glue-text-gate OK (off=${TEXT_OFF}B on=${TEXT_ON}B, no measurable delta)"
echo "${PREFIX} status=ok run=1 skip=0 host=$(ci_host_summary)"
