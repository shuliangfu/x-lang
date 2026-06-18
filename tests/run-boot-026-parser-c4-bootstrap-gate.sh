#!/usr/bin/env bash
# BOOT-026：parser C4 全量 SU bootstrap 门禁
#
# 用法：./tests/run-boot-026-parser-c4-bootstrap-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_BOOT026_DOC:-analysis/boot-026-parser-c4-bootstrap-v1.md}"
MANIFEST="${SHU_BOOT026_TSV:-tests/baseline/boot-026-parser-c4-bootstrap.tsv}"
WAVE="${SHU_BOOT026_WAVE_TSV:-tests/baseline/parser-c4-bootstrap-wave.tsv}"
MATRIX="tests/baseline/comp-parser-mega7-matrix.tsv"
REPRO="tests/baseline/bootstrap-repro.tsv"
LIB="tests/lib/boot-026-parser-c4-bootstrap.sh"
MIN_HOOKS=4
MIN_ROWS=4

# shellcheck source=tests/lib/boot-026-parser-c4-bootstrap.sh
. "$LIB"

echo "=== BOOT-026: parser C4 SU bootstrap manifest ==="
for f in "$DOC" "$MANIFEST" "$WAVE" "$LIB" "$MATRIX" "$REPRO" \
  tests/run-parser-parse-bootstrap-su-emit-gate.sh \
  tests/run-parser-parse-bootstrap-bisect-gate.sh \
  tests/run-parser-parse-bootstrap-link-smoke.sh \
  tests/run-boot-025-parser-gen12-consistency-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "boot-026-parser-c4-bootstrap gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_c4_hooks) MIN_HOOKS="$c2" ;;
    min_wave_rows) MIN_ROWS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in c4_minimal_ok c4_su_probe boot026_su_c4 su_bootstrap_target; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-026-parser-c4-bootstrap gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'boot026_su_c4' "$REPRO" 2>/dev/null; then
  echo "boot-026-parser-c4-bootstrap gate FAIL: bootstrap-repro missing boot026" >&2
  exit 1
fi

ROW_N=0
MISS=0
echo "=== BOOT-026: C4 bootstrap wave rows ==="
while IFS=$'\t' read -r c4_id hook _role _notes; do
  [ -z "${c4_id:-}" ] && continue
  case "$c4_id" in \#*|min_*) continue ;; esac
  ROW_N=$((ROW_N + 1))
  if ! grep -qF "$c4_id" "$DOC" 2>/dev/null; then
    echo "boot-026 FAIL: doc missing $c4_id" >&2
    MISS=$((MISS + 1))
  fi
  if [ ! -f "tests/$hook" ]; then
    echo "boot-026 FAIL: missing tests/$hook" >&2
    MISS=$((MISS + 1))
  else
    echo "boot-026 OK $c4_id -> $hook"
  fi
done < "$WAVE"

if [ "$ROW_N" -lt "$MIN_ROWS" ]; then
  echo "boot-026-parser-c4-bootstrap gate FAIL: rows=${ROW_N} < min ${MIN_ROWS}" >&2
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
        echo "boot-026 FAIL: manifest missing tests/$anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$HOOK_N" -lt "$MIN_HOOKS" ]; then
  echo "boot-026-parser-c4-bootstrap gate FAIL: hooks=${HOOK_N} < min ${MIN_HOOKS}" >&2
  exit 1
fi

if ! grep -F 'C5_su_bootstrap' "$MATRIX" 2>/dev/null | grep -qF 'run-boot-026-parser-c4-bootstrap-gate.sh'; then
  echo "boot-026 FAIL: C5_su_bootstrap not wired to boot-026 gate" >&2
  MISS=$((MISS + 1))
fi

if [ "$MISS" -gt 0 ]; then
  boot026_emit_report "fail" 0 0 0
  exit 1
fi
echo "boot-026-parser-c4-bootstrap manifest OK (rows=${ROW_N} hooks=${HOOK_N})"

echo "=== BOOT-026: parent BOOT-025 manifest ==="
chmod +x tests/run-boot-025-parser-gen12-consistency-gate.sh
SHU_BOOT025_MANIFEST_ONLY=1 ./tests/run-boot-025-parser-gen12-consistency-gate.sh

if [ "${SHU_BOOT026_MANIFEST_ONLY:-0}" = "1" ]; then
  boot026_emit_report "ok" 0 0 1
  echo "boot-026-parser-c4-bootstrap gate OK (manifest only)"
  exit 0
fi

C4_MINIMAL_OK=0
C4_SU_PROBE=0
SKIP=1

if boot026_parser_linux_shu; then
  echo "=== BOOT-026: SU emit probe (Linux shu) ==="
  chmod +x tests/run-parser-parse-bootstrap-su-emit-gate.sh
  SU_LOG="/tmp/boot026_su_emit_$$.log"
  if ./tests/run-parser-parse-bootstrap-su-emit-gate.sh 2>&1 | tee "$SU_LOG"; then
    read -r C4_MINIMAL_OK C4_SU_PROBE <<< "$(boot026_parse_su_emit_log "$SU_LOG")"
    SKIP=0
    echo "boot-026 su_emit OK (minimal=${C4_MINIMAL_OK} probe=${C4_SU_PROBE})"
  else
    rm -f "$SU_LOG"
    boot026_emit_report "fail" 0 0 0
    exit 1
  fi
  rm -f "$SU_LOG"
else
  echo "boot-026-parser-c4-bootstrap gate SKIP wave (Darwin or no compiler/shu)" >&2
fi

if [ "$SKIP" -eq 0 ] && [ "$C4_MINIMAL_OK" -lt 1 ]; then
  echo "boot-026-parser-c4-bootstrap gate FAIL: c4_minimal_ok=0" >&2
  boot026_emit_report "fail" 0 "$C4_SU_PROBE" 0
  exit 1
fi

boot026_emit_report "ok" "$C4_MINIMAL_OK" "$C4_SU_PROBE" "$SKIP"
echo "boot-026-parser-c4-bootstrap gate OK"
