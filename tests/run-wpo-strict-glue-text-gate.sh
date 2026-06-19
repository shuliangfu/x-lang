#!/usr/bin/env bash
# S5：strict_glue 实二进制 .text A/B（pipeline WPO helpers on/off，同 strict_glue 链骨架）。
# 与 proxy（run-perf-wpo-dce-shux-asm-text.sh）互补：本脚本读最终 ELF .text，非 A/B 反推。
# 用法：
#   ./tests/run-wpo-strict-glue-text-gate.sh
#   SHUX_WPO_STRICT_GLUE_TEXT_FAIL=1 ./tests/run-wpo-strict-glue-text-gate.sh
#   SHUX_WPO_STRICT_GLUE_TEXT_UPDATE_BASELINE=1 ./tests/run-wpo-strict-glue-text-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. "$(dirname "$0")/lib/wpo-ab-proxy.sh"

text_bytes() { wpo_ab_text_bytes "$@"; }

STRICT_GLUE="${SHUX_WPO_STRICT_GLUE:-compiler/shux_asm.strict_glue}"
FAIL=${SHUX_WPO_STRICT_GLUE_TEXT_FAIL:-0}
UPDATE_BASELINE=${SHUX_WPO_STRICT_GLUE_TEXT_UPDATE_BASELINE:-0}
BASELINE="${SHUX_WPO_STRICT_GLUE_TEXT_BASELINE:-tests/baseline/wpo-strict-glue-text.tsv}"
MAX_GROWTH_BYTES=$(awk -F'\t' '$1=="max_text_growth_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE" 2>/dev/null)
MAX_GROWTH_BYTES=${MAX_GROWTH_BYTES:-8192}

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "run-wpo-strict-glue-text-gate: N/A on Darwin (strict_glue link; Linux x86_64/ARM64 covers)"
  echo "run-wpo-strict-glue-text-gate OK (Darwin N/A)"
  exit 0
fi

chmod +x tests/run-wpo-strict-link-gate.sh tests/ensure-wpo-build-asm-artifacts.sh \
  compiler/scripts/relink_shux_asm_strict_glue.sh 2>/dev/null || true

echo "=== wpo strict_glue binary .text A/B (pipeline WPO helpers off vs on) ==="

if [ ! -f compiler/build_asm/pipeline_wpo.o ]; then
  echo "run-wpo-strict-glue-text-gate: ensure WPO build_asm artifacts ..."
  ./tests/ensure-wpo-build-asm-artifacts.sh
fi
if [ ! -f compiler/build_asm/pipeline_wpo.o ]; then
  echo "run-wpo-strict-glue-text-gate: SKIP (no pipeline_wpo.o)"
  exit 0
fi

# 强制重编 LSP/typeck_io 桩（strict_glue 链依赖）。
rm -f compiler/build_asm/asm_shu_lsp_diag_stub.o 2>/dev/null || true

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
  export SHUX_ASM_STRICT_LINK_PIPELINE_WPO=0
  export STRICT_LINK_BUILD_ASM_PIPELINE=1
  export STRICT_LINK_BUILD_ASM_WPO=0
  export STRICT_LINK_BUILD_ASM_TYPECK_WPO=1
  export STRICT_LINK_BUILD_ASM_BACKEND_WPO=1
  ./scripts/relink_shux_asm_strict_glue.sh >/tmp/wpo_strict_glue_text_off.log 2>&1
)

if [ ! -x "$STRICT_GLUE" ]; then
  echo "run-wpo-strict-glue-text-gate FAIL: missing $STRICT_GLUE (WPO off)" >&2
  tail -n 8 /tmp/wpo_strict_glue_text_off.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

TEXT_OFF=$(text_bytes "$STRICT_GLUE") || {
  echo "run-wpo-strict-glue-text-gate FAIL: cannot read .text (WPO off)" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

# B：链 pipeline_wpo helpers + C orchestration（与 strict link gate 一致）
wpo_strict_glue_rm_pipeline_partials
SHUX_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh >/tmp/wpo_strict_glue_text_on.log 2>&1

TEXT_ON=$(text_bytes "$STRICT_GLUE") || {
  echo "run-wpo-strict-glue-text-gate FAIL: cannot read .text (WPO on)" >&2
  tail -n 8 /tmp/wpo_strict_glue_text_on.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
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
  echo "run-wpo-strict-glue-text-gate FAIL: WPO on .text growth ${DELTA}B > max ${MAX_GROWTH_BYTES}B" >&2
  [ "$FAIL" = "1" ] && exit 1
fi

if [ "$DELTA" -gt 0 ]; then
  echo "run-wpo-strict-glue-text-gate OK (off=${TEXT_OFF}B on=${TEXT_ON}B delta=+${DELTA}B/${PCT}%, pipeline WPO helpers 略增 .text 实锤)"
  exit 0
fi

if [ "$SAVE" -gt 0 ]; then
  echo "run-wpo-strict-glue-text-gate OK (off=${TEXT_OFF}B on=${TEXT_ON}B save=${SAVE}B/${PCT}%)"
  exit 0
fi

echo "run-wpo-strict-glue-text-gate OK (off=${TEXT_OFF}B on=${TEXT_ON}B, no measurable delta)"
