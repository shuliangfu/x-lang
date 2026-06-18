#!/usr/bin/env bash
# STD-012：标准库示例工程 manifest 门禁
#
# 用法：./tests/run-std-examples-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_EXAMPLES_DOC:-analysis/std-examples-v1.md}"
MANIFEST="${SHU_STD_EXAMPLES_MANIFEST:-tests/baseline/std-examples-manifest.tsv}"
CATALOG="${SHU_STD_EXAMPLES_CATALOG:-tests/baseline/std-examples-catalog.tsv}"
MIN_EX=30

# shellcheck source=tests/lib/std-examples.sh
. tests/lib/std-examples.sh

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

echo "=== STD-012: std examples manifest ==="
for f in "$DOC" "$MANIFEST" "$CATALOG"; do
  if [ ! -f "$f" ]; then
    echo "std-examples gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_examples) MIN_EX="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
IDX=0
echo "=== STD-012: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    example_index)
      IDX=$((IDX + 1))
      if ! awk -F'\t' -v e="$anchor" '$1==e && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$CATALOG"; then
        echo "std-examples FAIL: catalog missing $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing index $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "std-examples FAIL: missing $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "std-examples FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "std-examples FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "std-examples FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

COUNT=$(std_ex_catalog_count "$CATALOG")
if [ "$COUNT" -lt "$MIN_EX" ]; then
  echo "std-examples gate FAIL: catalog count=${COUNT} < min ${MIN_EX}" >&2
  exit 1
fi

if ! std_ex_validate_paths "$CATALOG"; then
  echo "std-examples gate FAIL: catalog paths" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  echo "std-examples gate FAIL: missing=${MISS}" >&2
  exit 1
fi

for kw in examples catalog cookbook runnable; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "std-examples gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "std-examples manifest OK (catalog=${COUNT} index=${IDX})"

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -n "$SHU_BIN" ] && native_shu "$SHU_BIN"; then
  echo "=== STD-012: cookbook + core typeck smoke ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  CHECK_FAIL=0
  CHECK_N=0
  while IFS=$'\t' read -r eid _cat path tier _notes; do
    [ -z "${eid:-}" ] && continue
    case "$eid" in \#*) continue ;; esac
    case "$tier" in
      cookbook|core)
        CHECK_N=$((CHECK_N + 1))
        if std_ex_check_example "$SHU_BIN" "$path"; then
          echo "std-examples typeck OK $eid"
        else
          echo "std-examples typeck FAIL $eid ($path)" >&2
          CHECK_FAIL=$((CHECK_FAIL + 1))
        fi
        ;;
    esac
  done < "$CATALOG"
  if [ "$CHECK_FAIL" -gt 0 ]; then
    echo "std-examples gate FAIL: typeck=${CHECK_FAIL}/${CHECK_N}" >&2
    exit 1
  fi
  echo "std-examples typeck smoke OK (${CHECK_N} cookbook+core)"
else
  echo "std-examples gate SKIP typeck (no native shu)" >&2
fi

echo "std-examples gate OK"
