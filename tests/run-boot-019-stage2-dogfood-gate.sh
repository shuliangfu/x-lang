#!/usr/bin/env bash
# BOOT-019：Stage2 parser/typeck dogfood manifest 门禁
#
# 1) boot-019-stage2-dogfood-v1.md 必需章节
# 2) 六条烟测存在且文档引用
# 3) native shux 时跑 bootstrap 子集 runner（check 必绿；link 可选）
#
# 用法：./tests/run-boot-019-stage2-dogfood-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_BOOT019_DOC:-analysis/boot-019-stage2-dogfood-v1.md}"
MANIFEST="${SHUX_BOOT019_TSV:-tests/baseline/boot-019-stage2-dogfood.tsv}"
RUNNER="tests/run-bootstrap-stage2-dogfood-parser-typeck.sh"
LIB="tests/lib/boot-019-stage2-dogfood.sh"
MIN_SMOKE=6

# shellcheck source=tests/lib/boot-019-stage2-dogfood.sh
. tests/lib/boot-019-stage2-dogfood.sh

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

echo "=== BOOT-019: Stage2 dogfood manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$RUNNER" NEXT.md; do
  if [ ! -f "$f" ]; then
    echo "boot-019-stage2-dogfood gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_smoke) MIN_SMOKE="$c2" ;;
  esac
done < "$MANIFEST"

for kw in bootstrap-verify parser typeck check-7.2 Stage2; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-019-stage2-dogfood gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

MISS=0
SMOKE=0
echo "=== BOOT-019: smokes, hooks, refs ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-019 FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      SMOKE=$((SMOKE + 1))
      if [ ! -f "$anchor" ]; then
        echo "boot-019 FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-019 FAIL: doc missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "boot-019 OK smoke $anchor"
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "boot-019 FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "boot-019 FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "boot-019 FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SMOKE" -lt "$MIN_SMOKE" ]; then
  echo "boot-019-stage2-dogfood gate FAIL: smokes=${SMOKE} < min ${MIN_SMOKE}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "boot-019-stage2-dogfood gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "boot-019-stage2-dogfood manifest OK (smokes=${SMOKE})"

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

CHECK_OK=0
LINK_OK=0
SKIP=1
if [ -n "$SHUX_BIN" ] && native_shu "$SHUX_BIN"; then
  echo "=== BOOT-019: bootstrap subset runner (SHUX=$SHUX_BIN) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  chmod +x "$RUNNER"
  if SHUX="$SHUX_BIN" BOOT019_SKIP_LINK="${BOOT019_SKIP_LINK:-}" "$RUNNER" >/tmp/boot019_subset.log 2>&1; then
    grep -q 'bootstrap-stage2-dogfood parser/typeck OK' /tmp/boot019_subset.log
    CHECK_OK=6
    if grep -q 'link+run OK' /tmp/boot019_subset.log; then
      LINK_OK=$(grep -c 'link+run OK' /tmp/boot019_subset.log || true)
    fi
    SKIP=0
  else
    tail -10 /tmp/boot019_subset.log >&2 || true
    boot019_emit_report "fail" 0 0 1
    exit 1
  fi
else
  echo "boot-019-stage2-dogfood gate SKIP runner (no native shux)" >&2
fi

boot019_emit_report "ok" "$CHECK_OK" "$LINK_OK" "$SKIP"
echo "boot-019-stage2-dogfood gate OK"
