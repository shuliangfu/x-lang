#!/usr/bin/env bash
# BOOT-025：parser C3 gen1/gen2 三代一致性门禁
#
# 用法：./tests/run-boot-025-parser-gen12-consistency-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_BOOT025_DOC:-analysis/boot-025-parser-gen12-consistency-v1.md}"
MANIFEST="${SHUX_BOOT025_TSV:-tests/baseline/boot-025-parser-gen12-consistency.tsv}"
WAVE="${SHUX_BOOT025_WAVE_TSV:-tests/baseline/parser-gen12-consistency-wave.tsv}"
MATRIX="tests/baseline/comp-parser-mega7-matrix.tsv"
REPRO="tests/baseline/bootstrap-repro.tsv"
LIB="tests/lib/boot-025-parser-gen12-consistency.sh"
MIN_HOOKS=3
MIN_ROWS=3

# shellcheck source=tests/lib/boot-025-parser-gen12-consistency.sh
. "$LIB"

echo "=== BOOT-025: parser gen12 consistency manifest ==="
for f in "$DOC" "$MANIFEST" "$WAVE" "$LIB" "$MATRIX" "$REPRO" \
  compiler/verify-selfhost-stage2-bstrict.sh \
  tests/run-stage2-bstrict-gate.sh \
  tests/run-bootstrap-stage2-dogfood-parser-typeck.sh \
  tests/run-boot-024-parser-bootstrap-emit-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "boot-025-parser-gen12-consistency gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_consistency_hooks) MIN_HOOKS="$c2" ;;
    min_wave_rows) MIN_ROWS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in gen12_ok gen12_target consist_stage2 boot025_stage2_gen12; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-025-parser-gen12-consistency gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'boot025_stage2_gen12' "$REPRO" 2>/dev/null; then
  echo "boot-025-parser-gen12-consistency gate FAIL: bootstrap-repro missing boot025" >&2
  exit 1
fi

ROW_N=0
MISS=0
echo "=== BOOT-025: gen12 consistency wave rows ==="
while IFS=$'\t' read -r consist_id hook _role _notes; do
  [ -z "${consist_id:-}" ] && continue
  case "$consist_id" in \#*|min_*) continue ;; esac
  ROW_N=$((ROW_N + 1))
  if ! grep -qF "$consist_id" "$DOC" 2>/dev/null; then
    echo "boot-025 FAIL: doc missing $consist_id" >&2
    MISS=$((MISS + 1))
  fi
  if [ ! -f "tests/$hook" ]; then
    echo "boot-025 FAIL: missing tests/$hook" >&2
    MISS=$((MISS + 1))
  else
    echo "boot-025 OK $consist_id -> $hook"
  fi
done < "$WAVE"

if [ "$ROW_N" -lt "$MIN_ROWS" ]; then
  echo "boot-025-parser-gen12-consistency gate FAIL: rows=${ROW_N} < min ${MIN_ROWS}" >&2
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
        echo "boot-025 FAIL: manifest missing tests/$anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$HOOK_N" -lt "$MIN_HOOKS" ]; then
  echo "boot-025-parser-gen12-consistency gate FAIL: hooks=${HOOK_N} < min ${MIN_HOOKS}" >&2
  exit 1
fi

if ! grep -F 'C4_gen12_consistency' "$MATRIX" 2>/dev/null | grep -qF 'run-boot-025-parser-gen12-consistency-gate.sh'; then
  echo "boot-025 FAIL: C4_gen12_consistency not wired to boot-025 gate" >&2
  MISS=$((MISS + 1))
fi

if [ "$MISS" -gt 0 ]; then
  boot025_emit_report "fail" 0 0 0
  exit 1
fi
echo "boot-025-parser-gen12-consistency manifest OK (rows=${ROW_N} hooks=${HOOK_N})"

if [ "${SHUX_BOOT025_MANIFEST_ONLY:-0}" = "1" ]; then
  boot025_emit_report "ok" 0 0 1
  echo "boot-025-parser-gen12-consistency gate OK (manifest only)"
  exit 0
fi

echo "=== BOOT-025: parent BOOT-024 manifest ==="
chmod +x tests/run-boot-024-parser-bootstrap-emit-gate.sh
SHUX_BOOT024_MANIFEST_ONLY=1 ./tests/run-boot-024-parser-bootstrap-emit-gate.sh

GEN12_OK=0
DOGFOOD_OK=0
SKIP=1

if boot025_gen12_linux_asm; then
  echo "=== BOOT-025: stage2 bstrict (Linux shux_asm) ==="
  chmod +x tests/run-stage2-bstrict-gate.sh
  if ./tests/run-stage2-bstrict-gate.sh 2>&1 | tee "/tmp/boot025_stage2_$$.log" | grep -q 'stage2-bstrict-gate OK'; then
    GEN12_OK=1
    SKIP=0
    echo "boot-025 gen12 OK (stage2-bstrict)"
  else
    echo "boot-025-parser-gen12-consistency gate SKIP stage2 (bstrict unavailable)" >&2
  fi
  rm -f "/tmp/boot025_stage2_$$.log"

  if [ -x "./compiler/shux" ]; then
    echo "=== BOOT-025: parser/typeck dogfood ==="
    chmod +x tests/run-bootstrap-stage2-dogfood-parser-typeck.sh
    if SHUX=./compiler/shux ./tests/run-bootstrap-stage2-dogfood-parser-typeck.sh >/dev/null 2>&1; then
      DOGFOOD_OK=1
      echo "boot-025 dogfood OK"
    else
      echo "boot-025 SKIP dogfood (check/link unavailable)" >&2
    fi
  fi
else
  echo "boot-025-parser-gen12-consistency gate SKIP wave (Darwin or no shux_asm)" >&2
fi

boot025_emit_report "ok" "$GEN12_OK" "$DOGFOOD_OK" "$SKIP"
echo "boot-025-parser-gen12-consistency gate OK"
