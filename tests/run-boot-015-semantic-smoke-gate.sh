#!/usr/bin/env bash
# BOOT-015：语义自举 smoke（vec/map/heap）manifest 门禁
#
# 1) boot-015-semantic-smoke-v1.md 必需章节
# 2) 三模块烟测存在且文档引用
# 3) native shu 时跑 bootstrap 子集 runner（check 必绿；link 可选）
#
# 用法：./tests/run-boot-015-semantic-smoke-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_BOOT015_DOC:-analysis/boot-015-semantic-smoke-v1.md}"
MANIFEST="${SHU_BOOT015_TSV:-tests/baseline/boot-015-semantic-smoke.tsv}"
RUNNER="tests/run-bootstrap-semantic-smoke-vec-map-heap.sh"
LIB="tests/lib/boot-015-semantic-smoke.sh"
MIN_SMOKE=3

# shellcheck source=tests/lib/boot-015-semantic-smoke.sh
. tests/lib/boot-015-semantic-smoke.sh

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

echo "=== BOOT-015: semantic smoke manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$RUNNER" NEXT.md; do
  if [ ! -f "$f" ]; then
    echo "boot-015-semantic-smoke gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_smoke) MIN_SMOKE="$c2" ;;
  esac
done < "$MANIFEST"

for kw in bootstrap-verify vec map heap check-7.2; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-015-semantic-smoke gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

MISS=0
SMOKE=0
echo "=== BOOT-015: smokes, hooks, refs ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-015 FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      SMOKE=$((SMOKE + 1))
      if [ ! -f "$anchor" ]; then
        echo "boot-015 FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-015 FAIL: doc missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "boot-015 OK smoke $anchor"
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "boot-015 FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "boot-015 FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "boot-015 FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SMOKE" -lt "$MIN_SMOKE" ]; then
  echo "boot-015-semantic-smoke gate FAIL: smokes=${SMOKE} < min ${MIN_SMOKE}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "boot-015-semantic-smoke gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "boot-015-semantic-smoke manifest OK (smokes=${SMOKE})"

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

CHECK_OK=0
LINK_OK=0
SKIP=1
if [ -n "$SHU_BIN" ] && native_shu "$SHU_BIN"; then
  echo "=== BOOT-015: bootstrap subset runner (SHU=$SHU_BIN) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  chmod +x "$RUNNER"
  if SHU="$SHU_BIN" BOOT015_SKIP_LINK="${BOOT015_SKIP_LINK:-}" "$RUNNER" >/tmp/boot015_subset.log 2>&1; then
    grep -q 'bootstrap-semantic-smoke vec/map/heap OK' /tmp/boot015_subset.log
    CHECK_OK=3
    if grep -q 'link+run OK' /tmp/boot015_subset.log; then
      LINK_OK=$(grep -c 'link+run OK' /tmp/boot015_subset.log || true)
    fi
    SKIP=0
  else
    tail -10 /tmp/boot015_subset.log >&2 || true
    boot015_emit_report "fail" 0 0 1
    exit 1
  fi
else
  echo "boot-015-semantic-smoke gate SKIP runner (no native shu)" >&2
fi

boot015_emit_report "ok" "$CHECK_OK" "$LINK_OK" "$SKIP"
echo "boot-015-semantic-smoke gate OK"
