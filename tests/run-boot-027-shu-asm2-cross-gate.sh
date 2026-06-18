#!/usr/bin/env bash
# BOOT-027：parser C5 shu_asm2 跨平台发布门禁
#
# 用法：./tests/run-boot-027-shu-asm2-cross-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_BOOT027_DOC:-analysis/boot-027-shu-asm2-cross-v1.md}"
MANIFEST="${SHU_BOOT027_TSV:-tests/baseline/boot-027-shu-asm2-cross.tsv}"
WAVE="${SHU_BOOT027_WAVE_TSV:-tests/baseline/shu-asm2-cross-wave.tsv}"
MATRIX="tests/baseline/comp-parser-mega7-matrix.tsv"
REPRO="tests/baseline/bootstrap-repro.tsv"
LIB="tests/lib/boot-027-shu-asm2-cross.sh"
MIN_HOOKS=4
MIN_ROWS=4

# shellcheck source=tests/lib/boot-027-shu-asm2-cross.sh
. "$LIB"

echo "=== BOOT-027: shu_asm2 cross manifest ==="
for f in "$DOC" "$MANIFEST" "$WAVE" "$LIB" "$MATRIX" "$REPRO" \
  tests/run-shu-asm2-cross-smoke.sh \
  tests/run-stage2-bstrict-gate.sh \
  tests/run-bootstrap-crossplatform-gate.sh \
  tests/run-boot-026-parser-c4-bootstrap-gate.sh; do
  if [ ! -f "$f" ]; then
      echo "boot-027-shu-asm2-cross gate FAIL: missing $f" >&2
      exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_c5_hooks) MIN_HOOKS="$c2" ;;
    min_wave_rows) MIN_ROWS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in c5_ok c5_smoke boot027_shu_asm2_cross shu_asm2_cross_target; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-027-shu-asm2-cross gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'boot027_shu_asm2_cross' "$REPRO" 2>/dev/null; then
  echo "boot-027-shu-asm2-cross gate FAIL: bootstrap-repro missing boot027" >&2
  exit 1
fi

ROW_N=0
MISS=0
echo "=== BOOT-027: C5 cross wave rows ==="
while IFS=$'\t' read -r c5_id hook _role _notes; do
  [ -z "${c5_id:-}" ] && continue
  case "$c5_id" in \#*|min_*) continue ;; esac
  ROW_N=$((ROW_N + 1))
  if ! grep -qF "$c5_id" "$DOC" 2>/dev/null; then
    echo "boot-027 FAIL: doc missing $c5_id" >&2
    MISS=$((MISS + 1))
  fi
  if [ ! -f "tests/$hook" ]; then
    echo "boot-027 FAIL: missing tests/$hook" >&2
    MISS=$((MISS + 1))
  else
    echo "boot-027 OK $c5_id -> $hook"
  fi
done < "$WAVE"

if [ "$ROW_N" -lt "$MIN_ROWS" ]; then
  echo "boot-027-shu-asm2-cross gate FAIL: rows=${ROW_N} < min ${MIN_ROWS}" >&2
  exit 1
fi

HOOK_N=0
while IFS=$'\t' read -r item_id kind anchor _target _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    hook_gate|hook_ref)
      HOOK_N=$((HOOK_N + 1))
      if [ ! -f "tests/$anchor" ]; then
        echo "boot-027 FAIL: manifest missing tests/$anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$HOOK_N" -lt "$MIN_HOOKS" ]; then
  echo "boot-027-shu-asm2-cross gate FAIL: hooks=${HOOK_N} < min ${MIN_HOOKS}" >&2
  exit 1
fi

if ! grep -F 'C6_shu_asm2_cross' "$MATRIX" 2>/dev/null | grep -qF 'run-boot-027-shu-asm2-cross-gate.sh'; then
  echo "boot-027 FAIL: C6_shu_asm2_cross not wired to boot-027 gate" >&2
  MISS=$((MISS + 1))
fi

if [ "$MISS" -gt 0 ]; then
  boot027_emit_report "fail" 0 0 0
  exit 1
fi
echo "boot-027-shu-asm2-cross manifest OK (rows=${ROW_N} hooks=${HOOK_N})"

echo "=== BOOT-027: parent BOOT-026 manifest ==="
chmod +x tests/run-boot-026-parser-c4-bootstrap-gate.sh
SHU_BOOT026_MANIFEST_ONLY=1 ./tests/run-boot-026-parser-c4-bootstrap-gate.sh

if [ "${SHU_BOOT027_MANIFEST_ONLY:-0}" = "1" ]; then
  boot027_emit_report "ok" 0 0 1
  echo "boot-027-shu-asm2-cross gate OK (manifest only)"
  exit 0
fi

C5_OK=0
C5_SMOKE=0
SKIP=1

if boot027_linux_asm2_candidate; then
  echo "=== BOOT-027: shu_asm2 cross smoke (Linux) ==="
  chmod +x tests/run-shu-asm2-cross-smoke.sh
  SMOKE_LOG="/tmp/boot027_smoke_$$.log"
  if ./tests/run-shu-asm2-cross-smoke.sh 2>&1 | tee "$SMOKE_LOG"; then
    read -r C5_OK C5_SMOKE <<< "$(boot027_parse_smoke_log "$SMOKE_LOG")"
    SKIP=0
    echo "boot-027 smoke OK (c5_ok=${C5_OK} smoke=${C5_SMOKE})"
  else
    rm -f "$SMOKE_LOG"
    boot027_emit_report "fail" 0 0 0
    exit 1
  fi
  rm -f "$SMOKE_LOG"
else
  echo "boot-027-shu-asm2-cross gate SKIP wave (Darwin or no native shu_asm2)" >&2
fi

if [ "$SKIP" -eq 0 ] && [ "$C5_OK" -lt 1 ]; then
  echo "boot-027-shu-asm2-cross gate FAIL: c5_ok=0" >&2
  boot027_emit_report "fail" 0 "$C5_SMOKE" 0
  exit 1
fi

boot027_emit_report "ok" "$C5_OK" "$C5_SMOKE" "$SKIP"
echo "boot-027-shu-asm2-cross gate OK"
