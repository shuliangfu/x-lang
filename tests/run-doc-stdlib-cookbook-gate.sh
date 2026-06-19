#!/usr/bin/env bash
# DOC-001：标准库 Cookbook manifest 门禁
#
# 1) doc-stdlib-cookbook-v1.md 必需章节
# 2) 12 个 examples/cookbook 食谱存在且文档引用
# 3) 可选：native shux 时对食谱跑 check
#
# 用法：./tests/run-doc-stdlib-cookbook-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_DOC_COOKBOOK:-analysis/doc-stdlib-cookbook-v1.md}"
MANIFEST="${SHUX_DOC_COOKBOOK_TSV:-tests/baseline/doc-stdlib-cookbook.tsv}"
MIN_SEC=6
MIN_REC=12

# shellcheck source=tests/lib/doc-cookbook.sh
. tests/lib/doc-cookbook.sh

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

echo "=== DOC-001: stdlib cookbook manifest ==="
for f in "$DOC" "$MANIFEST" NEXT.md; do
  if [ ! -f "$f" ]; then
    echo "doc-stdlib-cookbook gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_sections) MIN_SEC="$c2" ;;
    min_recipes) MIN_REC="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
SEC=0
REC=0
echo "=== DOC-001: sections, recipes, refs ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "doc-stdlib-cookbook FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      else
        SEC=$((SEC + 1))
        echo "doc-stdlib-cookbook OK section $item_id"
      fi
      ;;
    recipe)
      REC=$((REC + 1))
      if [ ! -f "$anchor" ]; then
        echo "doc-stdlib-cookbook FAIL: missing recipe $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "doc-stdlib-cookbook FAIL: doc missing recipe $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "doc-stdlib-cookbook OK recipe $anchor"
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "doc-stdlib-cookbook FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "doc-stdlib-cookbook FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "doc-stdlib-cookbook FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "doc-stdlib-cookbook FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SEC" -lt "$MIN_SEC" ]; then
  echo "doc-stdlib-cookbook gate FAIL: sections=${SEC} < min ${MIN_SEC}" >&2
  exit 1
fi
if [ "$REC" -lt "$MIN_REC" ]; then
  echo "doc-stdlib-cookbook gate FAIL: recipes=${REC} < min ${MIN_REC}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "doc-stdlib-cookbook gate FAIL: missing=${MISS}" >&2
  exit 1
fi

for kw in IO NET async cookbook recipe; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "doc-stdlib-cookbook gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "doc-stdlib-cookbook manifest OK (sections=${SEC} recipes=${REC})"

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -n "$SHUX_BIN" ] && native_shu "$SHUX_BIN"; then
  echo "=== DOC-001: recipe typeck smoke ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  CHECK_FAIL=0
  while IFS=$'\t' read -r item_id kind anchor _notes; do
    [ "$kind" = "recipe" ] || continue
    if doc_cb_check_recipe "$SHUX_BIN" "$anchor"; then
      echo "doc-stdlib-cookbook typeck OK $anchor"
    else
      echo "doc-stdlib-cookbook typeck FAIL $anchor" >&2
      CHECK_FAIL=$((CHECK_FAIL + 1))
    fi
  done < "$MANIFEST"
  if [ "$CHECK_FAIL" -gt 0 ]; then
    echo "doc-stdlib-cookbook gate FAIL: typeck=${CHECK_FAIL}" >&2
    exit 1
  fi
else
  echo "doc-stdlib-cookbook gate SKIP typeck (no native shux)" >&2
fi

echo "doc-stdlib-cookbook gate OK"
