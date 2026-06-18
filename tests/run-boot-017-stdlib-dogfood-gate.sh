#!/usr/bin/env bash
# BOOT-017：标准库 .su 前端编译 dogfood 指标门禁
#
# 用法：./tests/run-boot-017-stdlib-dogfood-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_BOOT017_DOC:-analysis/boot-017-stdlib-dogfood-v1.md}"
MANIFEST="${SHU_BOOT017_MANIFEST:-tests/baseline/boot-017-stdlib-dogfood.tsv}"
MATRIX="${SHU_BOOT017_MATRIX:-tests/baseline/stdlib-check-matrix.tsv}"
BASELINE="${SHU_BOOT017_BASELINE:-tests/baseline/stdlib-dogfood.tsv}"
LIB="tests/lib/boot-017-stdlib-dogfood.sh"
RUNNER="tests/run-boot-017-stdlib-dogfood.sh"
MIN_MODULES=55
PREFIX="shu: [SHU_BOOT017_STDLIB_DOGFOOD]"

# shellcheck source=tests/lib/boot-017-stdlib-dogfood.sh
. tests/lib/boot-017-stdlib-dogfood.sh

echo "=== BOOT-017: stdlib dogfood manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$RUNNER" "$MATRIX"; do
  if [ ! -f "$f" ]; then
    echo "boot-017-stdlib-dogfood gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in PERF-004 分模块 SHU_BOOT017_STDLIB_DOGFOOD stdlib-dogfood; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-017-stdlib-dogfood gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_modules) MIN_MODULES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-017-stdlib-dogfood FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref|file)
      if [ ! -f "$mod_path" ]; then
        echo "boot-017-stdlib-dogfood FAIL: missing $mod_path ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "boot-017-stdlib-dogfood FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$MISS" -gt 0 ]; then
  echo "boot-017-stdlib-dogfood gate FAIL: missing=${MISS}" >&2
  exit 1
fi

# 基线须覆盖矩阵全部 module 行
BASE_N=0
MOD_N=0
while IFS=$'\t' read -r item_id kind anchor _layer _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|read_path|matrix|report) continue ;; esac
  [ "$kind" = "module" ] || continue
  MOD_N=$((MOD_N + 1))
  if [ -f "$BASELINE" ] && awk -F'\t' -v m="$anchor" '$1==m && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$BASELINE"; then
    BASE_N=$((BASE_N + 1))
  fi
done < "$MATRIX"

if [ "$MOD_N" -lt "$MIN_MODULES" ]; then
  echo "boot-017-stdlib-dogfood gate FAIL: matrix modules=${MOD_N}" >&2
  exit 1
fi
if [ ! -f "$BASELINE" ]; then
  echo "boot-017-stdlib-dogfood gate FAIL: missing baseline $BASELINE" >&2
  exit 1
fi
if [ "$BASE_N" -lt "$MOD_N" ]; then
  echo "boot-017-stdlib-dogfood gate FAIL: baseline rows=${BASE_N} < modules=${MOD_N}" >&2
  exit 1
fi
echo "boot-017-stdlib-dogfood manifest OK (modules=${MOD_N}, baseline=${BASE_N})"

# perf 注册表须含 stdlib-dogfood
REG="${SHU_PERF_BASELINE_REGISTRY:-tests/baseline/perf-baseline-registry.tsv}"
if ! awk -F'\t' '$1=="stdlib-dogfood" && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$REG" 2>/dev/null; then
  echo "boot-017-stdlib-dogfood gate FAIL: perf-baseline-registry missing stdlib-dogfood" >&2
  exit 1
fi

if SHU_BIN="$(boot017_resolve_shu 2>/dev/null)"; then
  echo "=== BOOT-017: per-module timing (SHU=$SHU_BIN) ==="
  chmod +x "$RUNNER" "$LIB"
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  set -o pipefail
  if ! SHU="$SHU_BIN" ./"$RUNNER" 2>&1 | tee /tmp/boot017_stdlib_dogfood.log; then
    set +o pipefail
    echo "boot-017-stdlib-dogfood gate FAIL: runner" >&2
    exit 1
  fi
  set +o pipefail
  grep -qF "$PREFIX" /tmp/boot017_stdlib_dogfood.log || {
    echo "boot-017-stdlib-dogfood gate FAIL: missing report prefix" >&2
    exit 1
  }
else
  echo "boot-017-stdlib-dogfood gate SKIP timing (no native shu)" >&2
fi

echo "boot-017-stdlib-dogfood gate OK"
