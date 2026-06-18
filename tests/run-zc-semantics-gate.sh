#!/usr/bin/env bash
# ZC-006：零拷贝语义白皮书 manifest 门禁
#
# 1) zc-semantics-v1.md 必需章节与拷贝 catalog
# 2) ZC-1..5 tier 与交叉引用
# 3) 示例存在；可选跑 run-zc-gates.sh
#
# 用法：./tests/run-zc-semantics-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_ZC_SEMANTICS_DOC:-analysis/zc-semantics-v1.md}"
MANIFEST="${SHU_ZC_SEMANTICS_TSV:-tests/baseline/zc-semantics.tsv}"
MIN_SEC=7
MIN_ZC=5
RUN_HOOKS=0
[ "${SHU_ZC_SEMANTICS_RUN_HOOKS:-0}" = "1" ] && RUN_HOOKS=1

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

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

echo "=== ZC-006: zero-copy semantics manifest ==="
for f in "$DOC" "$MANIFEST" NEXT.md; do
  if [ ! -f "$f" ]; then
    echo "zc-semantics gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_sections) MIN_SEC="$c2" ;;
    min_zc_tiers) MIN_ZC="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
SEC=0
ZC=0
HOOK=""
echo "=== ZC-006: sections, catalog, tiers ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section|catalog_anchor)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "zc-semantics FAIL: missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      elif [ "$kind" = "section" ]; then
        SEC=$((SEC + 1))
        echo "zc-semantics OK section $item_id"
      fi
      ;;
    zc_tier)
      ZC=$((ZC + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "zc-semantics FAIL: doc missing tier $anchor" >&2
        MISS=$((MISS + 1))
      fi
      gate_script="$notes"
      case "$gate_script" in
        tests/*) gate_path="$gate_script" ;;
        *) gate_path="tests/$gate_script" ;;
      esac
      if [ ! -f "$gate_path" ]; then
        echo "zc-semantics FAIL: missing gate $gate_path" >&2
        MISS=$((MISS + 1))
      else
        echo "zc-semantics OK tier $anchor ($gate_path)"
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "zc-semantics FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "zc-semantics FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "zc-semantics OK cross-ref $anchor"
      fi
      ;;
    example)
      if [ ! -f "$anchor" ]; then
        echo "zc-semantics FAIL: missing example $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "zc-semantics FAIL: doc missing example $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "zc-semantics OK example $anchor"
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "zc-semantics FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      else
        HOOK="$path"
        echo "zc-semantics OK hook $anchor"
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SEC" -lt "$MIN_SEC" ]; then
  echo "zc-semantics gate FAIL: sections=${SEC} < min ${MIN_SEC}" >&2
  exit 1
fi
if [ "$ZC" -lt "$MIN_ZC" ]; then
  echo "zc-semantics gate FAIL: zc_tiers=${ZC} < min ${MIN_ZC}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "zc-semantics gate FAIL: missing=${MISS}" >&2
  exit 1
fi

for kw in read_ptr StrView fs_mmap_ro fs_pipe_splice; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "zc-semantics gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "zc-semantics manifest OK (sections=${SEC}, zc_tiers=${ZC})"

if [ "$RUN_HOOKS" -eq 0 ]; then
  SHU_BIN="${SHU:-}"
  if [ -z "$SHU_BIN" ]; then
    for cand in ./compiler/shu-c ./compiler/shu; do
      if native_shu "$cand"; then
        SHU_BIN="$cand"
        break
      fi
    done
  fi
  if [ -n "$SHU_BIN" ]; then
    RUN_HOOKS=1
  fi
fi

if [ "$RUN_HOOKS" -eq 1 ] && [ -n "$HOOK" ]; then
  echo "=== ZC-006: linked hook $HOOK ==="
  chmod +x "$HOOK" 2>/dev/null || true
  if SHU="${SHU:-}" "$HOOK"; then
    echo "zc-semantics hook OK"
  else
    echo "zc-semantics gate FAIL: hook $(basename "$HOOK")" >&2
    exit 1
  fi
else
  echo "zc-semantics gate SKIP hook (no native shu; SHU_ZC_SEMANTICS_RUN_HOOKS=1 to force)" >&2
fi

echo "zc-semantics gate OK"
