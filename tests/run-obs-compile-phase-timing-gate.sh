#!/usr/bin/env bash
# OBS-001：编译阶段耗时埋点 manifest + 烟测门禁
#
# 1) obs-compile-phase-timing-v1.md + manifest
# 2) runtime.c / pipeline.su 符号与 env 锚点
# 3) native shu：SHU_COMPILE_PHASE_TIMING=1 check 须输出汇总行
#
# 用法：./tests/run-obs-compile-phase-timing-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_OBS_PHASE_TIMING_DOC:-analysis/obs-compile-phase-timing-v1.md}"
MANIFEST="${SHU_OBS_PHASE_TIMING_TSV:-tests/baseline/obs-compile-phase-timing.tsv}"
RUNTIME="${SHU_OBS_PHASE_TIMING_RUNTIME:-compiler/src/runtime.c}"
PIPELINE="${SHU_OBS_PHASE_TIMING_PIPELINE:-compiler/src/pipeline/pipeline.su}"
MIN_ITEMS=6
OUTPUT_PREFIX="shu: [SHU_COMPILE_PHASE_TIMING]"
SMOKE_FIX="tests/bench/loop_i32.su"

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

echo "=== OBS-001: compile phase timing manifest ==="
for f in "$DOC" "$MANIFEST" "$RUNTIME" "$PIPELINE"; do
  if [ ! -f "$f" ]; then
    echo "obs-compile-phase-timing gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_items) continue ;; esac
  case "$item_id" in
    output_prefix) OUTPUT_PREFIX="$anchor" ;;
    smoke_fixture) SMOKE_FIX="$anchor" ;;
  esac
done < "$MANIFEST"

MISS=0
FOUND=0
echo "=== OBS-001: manifest anchor check ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_items) continue ;; esac
  FOUND=$((FOUND + 1))
  case "$kind" in
    env_var)
      if ! grep -qF "$anchor" "$RUNTIME" 2>/dev/null; then
        echo "obs-compile-phase-timing FAIL: env $anchor not in $RUNTIME" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    output_prefix|field_parse|field_typeck|field_codegen|field_total)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "obs-compile-phase-timing FAIL: doc missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    impl_begin|impl_end|impl_flush)
      if ! grep -qE "(void|function) ${anchor}\\(" "$RUNTIME" 2>/dev/null; then
        echo "obs-compile-phase-timing FAIL: ${anchor} not in $RUNTIME" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    pipeline_hook)
      if ! grep -qF "$anchor" "$PIPELINE" 2>/dev/null; then
        echo "obs-compile-phase-timing FAIL: ${anchor} not in $PIPELINE" >&2
        MISS=$((MISS + 1))
      fi
      if ! grep -qF "driver_compile_phase_timing_begin" "$PIPELINE" 2>/dev/null; then
        echo "obs-compile-phase-timing FAIL: timing hooks missing in $PIPELINE" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke_fixture)
      if [ ! -f "$anchor" ]; then
        echo "obs-compile-phase-timing FAIL: missing fixture $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$FOUND" -lt "$MIN_ITEMS" ]; then
  echo "obs-compile-phase-timing gate FAIL: items=${FOUND} < min_items=${MIN_ITEMS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "obs-compile-phase-timing gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "obs-compile-phase-timing manifest OK (host=$(ci_host_summary), items=${FOUND})"

# ── native shu 烟测 ──
SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHU_BIN" ]; then
  echo "obs-compile-phase-timing gate SKIP smoke (no native shu)" >&2
  echo "obs-compile-phase-timing gate OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

LOG=/tmp/shu_obs_phase_timing.log
if ! SHU_COMPILE_PHASE_TIMING=1 "$SHU_BIN" check "$SMOKE_FIX" >"$LOG" 2>&1; then
  echo "obs-compile-phase-timing gate FAIL: check $SMOKE_FIX (see $LOG)" >&2
  tail -20 "$LOG" >&2 || true
  exit 1
fi
if ! grep -qF "$OUTPUT_PREFIX" "$LOG"; then
  echo "obs-compile-phase-timing gate FAIL: no timing line in stderr (see $LOG)" >&2
  tail -20 "$LOG" >&2 || true
  exit 1
fi
for field in parse_ms= typeck_ms= codegen_ms= total_ms=; do
  if ! grep -qF "$field" "$LOG"; then
    echo "obs-compile-phase-timing gate FAIL: missing $field in output" >&2
    exit 1
  fi
done
echo "obs-compile-phase-timing smoke OK ($SHU_BIN check $SMOKE_FIX)"

echo "obs-compile-phase-timing gate OK"
