#!/usr/bin/env bash
# TOOL-002：linter 规则分层 manifest 门禁
#
# 用法：./tests/run-tool-lint-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_TOOL_LINT_DOC:-analysis/tool-lint-rules-v1.md}"
MANIFEST="${SHU_TOOL_LINT_MANIFEST:-tests/baseline/tool-lint-rules.tsv}"
PROFILE="${SHU_TOOL_LINT_PROFILE_TSV:-tests/baseline/tool-lint-ci-profile.tsv}"
MIN_RULES=6
MIN_CASES=4
MIN_PROFILE_ROWS=6

# shellcheck source=tests/lib/tool-lint.sh
. tests/lib/tool-lint.sh

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

echo "=== TOOL-002: linter rules manifest ==="
for f in "$DOC" "$MANIFEST" "$PROFILE" compiler/src/lsp/lsp_diag.h compiler/src/driver/fmt_check_cmd.c; do
  if [ ! -f "$f" ]; then
    echo "tool-lint gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_rules) MIN_RULES="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_rows) MIN_PROFILE_ROWS="$c2" ;;
  esac
done < "$PROFILE"

MISS=0
RULE_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-lint FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    rules)
      RULE_N=$((RULE_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-lint FAIL: doc missing rule $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "tool-lint FAIL: missing golden $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "tool-lint FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "tool-lint FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "tool-lint FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-lint FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "tool-lint FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-lint FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

PROFILE_N=$(tool_lint_profile_rows ci-default "$PROFILE")
if [ "$RULE_N" -lt "$MIN_RULES" ]; then
  echo "tool-lint gate FAIL: rules=${RULE_N} < min ${MIN_RULES}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "tool-lint gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$PROFILE_N" -lt "$MIN_PROFILE_ROWS" ]; then
  echo "tool-lint gate FAIL: profile rows=${PROFILE_N} < min ${MIN_PROFILE_ROWS}" >&2
  exit 1
fi

for kw in linter error warn info configurable runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "tool-lint gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "tool-lint gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "tool-lint manifest OK (rules=${RULE_N} cases=${CASE_N} profile=${PROFILE_N})"

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
  echo "=== TOOL-002: lint hooks (SHU=$SHU_BIN) ==="
  chmod +x tests/run-lint-check.sh
  ./tests/run-lint-check.sh
  echo "tool-lint hooks OK"
else
  echo "tool-lint gate SKIP hooks (no native shu)" >&2
fi

echo "tool-lint gate OK"
