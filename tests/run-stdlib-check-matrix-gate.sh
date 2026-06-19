#!/usr/bin/env bash
# BOOT-013：stdlib check 矩阵 manifest 门禁
#
# 用法：./tests/run-stdlib-check-matrix-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STDLIB_CHECK_DOC:-analysis/boot-stdlib-check-matrix-v1.md}"
MANIFEST="${SHUX_STDLIB_CHECK_TSV:-tests/baseline/stdlib-check-matrix.tsv}"
LIB="tests/lib/stdlib-check-matrix.sh"
RUNNER="tests/run-stdlib-check-matrix.sh"
MIN_MOD=55
PREFIX="shux: [SHUX_STDLIB_CHECK]"

# shellcheck source=tests/lib/stdlib-check-matrix.sh
. tests/lib/stdlib-check-matrix.sh

echo "=== BOOT-013: stdlib check matrix manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$RUNNER"; do
  if [ ! -f "$f" ]; then
    echo "stdlib-check-matrix gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in runnable SHUX_STDLIB_CHECK 模块矩阵 shux check; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "stdlib-check-matrix gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_modules) MIN_MOD="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
MOD_N=0
CORE_N=0
STD_N=0
while IFS=$'\t' read -r item_id kind anchor layer _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|read_path|matrix|report) continue ;; esac
  case "$kind" in
    module)
      MOD_N=$((MOD_N + 1))
      mod_path="${anchor//./\/}/mod.sx"
      case "$layer" in
        core) CORE_N=$((CORE_N + 1)); mod_path="core/${anchor#core.}/mod.sx" ;;
        std) STD_N=$((STD_N + 1)); mod_path="std/${anchor#std.}/mod.sx" ;;
      esac
      if [ ! -f "$mod_path" ]; then
        echo "stdlib-check-matrix FAIL: missing $mod_path ($anchor)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        : # doc lists layers not each module
      fi
      ;;
    script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "stdlib-check-matrix FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "stdlib-check-matrix FAIL: doc missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$MOD_N" -lt "$MIN_MOD" ]; then
  echo "stdlib-check-matrix gate FAIL: modules=${MOD_N} < min ${MIN_MOD}" >&2
  exit 1
fi
WANT_STD=$((MIN_MOD - 11))
if [ "$CORE_N" -ne 11 ] || [ "$STD_N" -ne "$WANT_STD" ]; then
  echo "stdlib-check-matrix gate FAIL: core=${CORE_N} std=${STD_N} want 11/${WANT_STD}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "stdlib-check-matrix gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "stdlib-check-matrix manifest OK (modules=${MOD_N}, core=${CORE_N}, std=${STD_N})"

if SHUX_BIN="$(stdlib_cm_resolve_shu 2>/dev/null)"; then
  echo "=== BOOT-013: runnable matrix (SHUX=$SHUX_BIN) ==="
  chmod +x "$RUNNER" "$LIB"
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  set -o pipefail
  if ! ./"$RUNNER" 2>&1 | tee /tmp/stdlib_check_matrix.log; then
    set +o pipefail
    echo "stdlib-check-matrix gate FAIL: runner" >&2
    exit 1
  fi
  set +o pipefail
  grep -qF "$PREFIX" /tmp/stdlib_check_matrix.log || {
    echo "stdlib-check-matrix gate FAIL: missing report prefix" >&2
    exit 1
  }
else
  echo "stdlib-check-matrix gate SKIP runnable (no shux)" >&2
fi

echo "stdlib-check-matrix gate OK"
