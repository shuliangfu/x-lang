#!/usr/bin/env bash
# STD-155：std.bytes 与 Arena 协作策略门禁
#
# 用法：./tests/run-std-bytes-arena-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-bytes-arena-v1.md"
MANIFEST="tests/baseline/std-bytes-arena-manifest.tsv"
MOD_SU="std/bytes/mod.su"
LIB="tests/lib/std-bytes-arena.sh"
SMOKE_SU="tests/std-bytes/arena_external.su"
MIN_APIS=4

# shellcheck source=tests/lib/std-bytes-arena.sh
. "$LIB"

echo "=== STD-155: bytes arena manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$SMOKE_SU" std/bytes/README.md std/heap/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-bytes-arena gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-155 bytes_from_external BYTES_OWN_EXTERNAL arena64_init; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-bytes-arena gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "bytes_from_external" std/bytes/README.md 2>/dev/null; then
  echo "std-bytes-arena gate FAIL: README missing bytes_from_external" >&2
  exit 1
fi

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in api) API_N=$((API_N + 1)) ;; esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-bytes-arena gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_bytes_arena_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_bytes_arena_emit_report "fail" 0 0
  exit 1
fi
echo "std-bytes-arena manifest OK"

SU_OK=0
SKIP=0
SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ]; then
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-bytes-arena gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_bytes_arena_emit_report "fail" 0 0
    exit 1
  fi
  if std_bytes_arena_run_smoke "$SHU_BIN" "$SMOKE_SU"; then
    SU_OK=1
  else
    std_bytes_arena_emit_report "fail" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_bytes_arena_emit_report "ok" "$SU_OK" "$SKIP"
echo "std-bytes-arena gate OK"
