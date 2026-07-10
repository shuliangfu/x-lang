#!/usr/bin/env bash
# BOOT-024：parser C2 139 函数 bootstrap emit 门禁
#
# 用法：./tests/run-boot-024-parser-bootstrap-emit-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_BOOT024_DOC:-analysis/boot-024-parser-bootstrap-emit-v1.md}"
MANIFEST="${SHUX_BOOT024_TSV:-tests/baseline/boot-024-parser-bootstrap-emit.tsv}"
WAVE="${SHUX_BOOT024_WAVE_TSV:-tests/baseline/parser-bootstrap-emit-wave.tsv}"
MATRIX="tests/baseline/comp-parser-mega7-matrix.tsv"
LIB="tests/lib/boot-024-parser-bootstrap-emit.sh"
MIN_HOOKS=4
MIN_ROWS=4

# shellcheck source=tests/lib/boot-024-parser-bootstrap-emit.sh
. "$LIB"

echo "=== BOOT-024: parser bootstrap emit manifest ==="
for f in "$DOC" "$MANIFEST" "$WAVE" "$LIB" "$MATRIX" \
  compiler/src/asm/parser_asm_parse_bootstrap_obj.inc \
  tests/run-parser-parse-bootstrap-gate.sh \
  tests/run-parser-parse-bootstrap-link-smoke.sh \
  tests/run-parser-parse-bootstrap-bisect-gate.sh \
  tests/run-parser-parse-bootstrap-x-emit-gate.sh \
  tests/run-boot-023-mega7-full-emit-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "boot-024-parser-bootstrap-emit gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_bootstrap_hooks) MIN_HOOKS="$c2" ;;
    min_wave_rows) MIN_ROWS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in bootstrap_minimal_ok bootstrap_full_emit SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT boot_bisect; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-024-parser-bootstrap-emit gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

ROW_N=0
MISS=0
echo "=== BOOT-024: bootstrap emit wave rows ==="
while IFS=$'\t' read -r boot_id _phase hook _role _notes; do
  [ -z "${boot_id:-}" ] && continue
  case "$boot_id" in \#*|min_*) continue ;; esac
  ROW_N=$((ROW_N + 1))
  if ! grep -qF "$boot_id" "$DOC" 2>/dev/null; then
    echo "boot-024 FAIL: doc missing $boot_id" >&2
    MISS=$((MISS + 1))
  fi
  if [ ! -f "tests/$hook" ]; then
    echo "boot-024 FAIL: missing tests/$hook" >&2
    MISS=$((MISS + 1))
  else
    echo "boot-024 OK $boot_id -> $hook"
  fi
done < "$WAVE"

if [ "$ROW_N" -lt "$MIN_ROWS" ]; then
  echo "boot-024-parser-bootstrap-emit gate FAIL: rows=${ROW_N} < min ${MIN_ROWS}" >&2
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
        echo "boot-024 FAIL: manifest missing tests/$anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$HOOK_N" -lt "$MIN_HOOKS" ]; then
  echo "boot-024-parser-bootstrap-emit gate FAIL: hooks=${HOOK_N} < min ${MIN_HOOKS}" >&2
  exit 1
fi

# C3 须登记 BOOT-024 gate
if ! grep -F 'C3_full_emit' "$MATRIX" 2>/dev/null | grep -qF 'run-boot-024-parser-bootstrap-emit-gate.sh'; then
  echo "boot-024 FAIL: C3_full_emit not wired to boot-024 gate" >&2
  MISS=$((MISS + 1))
fi

if [ "$MISS" -gt 0 ]; then
  boot024_emit_report "fail" 0 0 0
  exit 1
fi
echo "boot-024-parser-bootstrap-emit manifest OK (rows=${ROW_N} hooks=${HOOK_N})"

if [ "${SHUX_BOOT024_MANIFEST_ONLY:-0}" = "1" ]; then
  boot024_emit_report "ok" 0 0 1
  echo "boot-024-parser-bootstrap-emit gate OK (manifest only)"
  exit 0
fi

BOOTSTRAP_MINIMAL_OK=0
BOOTSTRAP_FULL_EMIT=0
SKIP=1

if boot024_parser_linux_shu; then
  echo "=== BOOT-024: bootstrap bisect (Linux shux) ==="
  chmod +x tests/run-parser-parse-bootstrap-bisect-gate.sh
  BISECT_OUT="/tmp/boot024_bisect_$$.log"
  if ./tests/run-parser-parse-bootstrap-bisect-gate.sh 2>&1 | tee "$BISECT_OUT"; then
    MIN_N="$(boot024_parse_bisect_minimal "$BISECT_OUT")"
    BOOTSTRAP_FULL_EMIT="$(boot024_parse_bisect_full_emit "$BISECT_OUT")"
    if [ "${MIN_N:-0}" -ge 1 ]; then
      BOOTSTRAP_MINIMAL_OK=1
    fi
    SKIP=0
    echo "boot-024 bisect OK (minimal=${BOOTSTRAP_MINIMAL_OK} full_emit=${BOOTSTRAP_FULL_EMIT})"
  else
    rm -f "$BISECT_OUT"
    boot024_emit_report "fail" 0 0 0
    exit 1
  fi
  rm -f "$BISECT_OUT"
else
  echo "boot-024-parser-bootstrap-emit gate SKIP wave (Darwin or no compiler/shux)" >&2
fi

if [ "$SKIP" -eq 0 ] && [ "$BOOTSTRAP_MINIMAL_OK" -lt 1 ]; then
  echo "boot-024-parser-bootstrap-emit gate FAIL: bootstrap_minimal_ok=0" >&2
  boot024_emit_report "fail" 0 "$BOOTSTRAP_FULL_EMIT" 0
  exit 1
fi

boot024_emit_report "ok" "$BOOTSTRAP_MINIMAL_OK" "$BOOTSTRAP_FULL_EMIT" "$SKIP"
echo "boot-024-parser-bootstrap-emit gate OK"
