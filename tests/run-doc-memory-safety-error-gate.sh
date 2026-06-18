#!/usr/bin/env bash
# DOC-004：内存安全与异常处理指南 manifest 门禁
#
# 1) doc-memory-safety-error-v1.md 必需章节
# 2) 交叉引用 RFC 存在
# 3) 示例 .su 存在；hook 脚本存在（native shu 时可选跑 hook）
#
# 用法：./tests/run-doc-memory-safety-error-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_DOC_MEM_SAFE_ERR:-analysis/doc-memory-safety-error-v1.md}"
MANIFEST="${SHU_DOC_MEM_SAFE_MANIFEST:-tests/baseline/doc-memory-safety-error.tsv}"
MIN_SEC=8
MIN_XREF=6
RUN_HOOKS=0
[ "${SHU_DOC_MEM_SAFE_RUN_HOOKS:-0}" = "1" ] && RUN_HOOKS=1

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

echo "=== DOC-004: memory safety & error guide manifest ==="
for f in "$DOC" "$MANIFEST" NEXT.md; do
  if [ ! -f "$f" ]; then
    echo "doc-memory-safety-error gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_sections) MIN_SEC="$c2" ;;
    min_cross_refs) MIN_XREF="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
SEC=0
XREF=0
HOOKS=""
echo "=== DOC-004: required sections & refs ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "doc-memory-safety-error FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      else
        SEC=$((SEC + 1))
        echo "doc-memory-safety-error OK section $item_id"
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "doc-memory-safety-error FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      else
        XREF=$((XREF + 1))
        if ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
          echo "doc-memory-safety-error FAIL: doc missing link to $anchor" >&2
          MISS=$((MISS + 1))
        else
          echo "doc-memory-safety-error OK cross-ref $anchor"
        fi
      fi
      ;;
    example)
      if [ ! -f "$anchor" ]; then
        echo "doc-memory-safety-error FAIL: missing example $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "doc-memory-safety-error FAIL: doc missing example ref $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "doc-memory-safety-error OK example $anchor"
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "doc-memory-safety-error FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      else
        HOOKS="$HOOKS $path"
        echo "doc-memory-safety-error OK hook $anchor"
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SEC" -lt "$MIN_SEC" ]; then
  echo "doc-memory-safety-error gate FAIL: sections=${SEC} < min ${MIN_SEC}" >&2
  exit 1
fi
if [ "$XREF" -lt "$MIN_XREF" ]; then
  echo "doc-memory-safety-error gate FAIL: cross_refs=${XREF} < min ${MIN_XREF}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "doc-memory-safety-error gate FAIL: missing=${MISS}" >&2
  exit 1
fi

# 指南须引用 EXC + LANG + SAFE 关键词
for kw in EXC-001 EXC-003 LANG-007 SAFE-002; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "doc-memory-safety-error gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "doc-memory-safety-error manifest OK (sections=${SEC}, cross_refs=${XREF})"

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

if [ "$RUN_HOOKS" -eq 1 ]; then
  echo "=== DOC-004: linked gate hooks ==="
  FAILS=0
  for hook in $HOOKS; do
    echo "── hook: $hook ──"
    chmod +x "$hook" 2>/dev/null || true
    if SHU="${SHU:-}" "$hook"; then
      echo "doc-memory-safety-error hook OK $(basename "$hook")"
    else
      echo "doc-memory-safety-error hook FAIL $(basename "$hook")" >&2
      FAILS=$((FAILS + 1))
    fi
  done
  if [ "$FAILS" -gt 0 ]; then
    echo "doc-memory-safety-error gate FAIL: hooks=${FAILS}" >&2
    exit 1
  fi
else
  echo "doc-memory-safety-error gate SKIP hooks (no native shu, set SHU_DOC_MEM_SAFE_RUN_HOOKS=1 to force manifest-only)" >&2
fi

echo "doc-memory-safety-error gate OK"
