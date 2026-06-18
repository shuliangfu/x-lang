#!/usr/bin/env bash
# TOOL-001：formatter 风格锁定 manifest 门禁
#
# 用法：./tests/run-tool-fmt-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_TOOL_FMT_DOC:-analysis/tool-fmt-style-v1.md}"
MANIFEST="${SHU_TOOL_FMT_MANIFEST:-tests/baseline/tool-fmt-style.tsv}"
MIN_CASES=5
MIN_RULES=6

# shellcheck source=tests/lib/tool-fmt.sh
. tests/lib/tool-fmt.sh

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*) return 0 ;;
    *) return 0 ;;
  esac
}

echo "=== TOOL-001: formatter style manifest ==="
for f in "$DOC" "$MANIFEST" compiler/src/driver/fmt.su compiler/src/driver/fmt_check_cmd.c; do
  if [ ! -f "$f" ]; then
    echo "tool-fmt gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 c3 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases) MIN_CASES="$c2" ;;
    min_rules) MIN_RULES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
CASE_N=0
RULE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-fmt FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    rules)
      RULE_N=$((RULE_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-fmt FAIL: doc missing rule $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "tool-fmt FAIL: missing golden $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "tool-fmt FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "tool-fmt FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "tool-fmt FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-fmt FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "tool-fmt FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-fmt FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "tool-fmt gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$RULE_N" -lt "$MIN_RULES" ]; then
  echo "tool-fmt gate FAIL: rules=${RULE_N} < min ${MIN_RULES}" >&2
  exit 1
fi

for kw in formatter style idempotent runnable semicolon_space; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "tool-fmt gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "tool-fmt gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "tool-fmt manifest OK (cases=${CASE_N} rules=${RULE_N})"

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
  make -C compiler -q 2>/dev/null || make -C compiler
  echo "=== TOOL-001: fmt hooks (SHU=$SHU_BIN) ==="
  chmod +x tests/run-fmt-cmd.sh tests/run-fmt-check-cmd.sh tests/run-fmt-wrap.sh
  SHU="$SHU_BIN" ./tests/run-fmt-cmd.sh
  echo "tool-fmt hooks OK"
else
  echo "tool-fmt gate SKIP hooks (no shu)" >&2
fi

echo "tool-fmt gate OK"
