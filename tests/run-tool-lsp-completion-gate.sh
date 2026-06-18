#!/usr/bin/env bash
# TOOL-003：LSP 补全质量 manifest 门禁
#
# 用法：./tests/run-tool-lsp-completion-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_TOOL_LSP_COMP_DOC:-analysis/tool-lsp-completion-v1.md}"
MANIFEST="${SHU_TOOL_LSP_COMP_MANIFEST:-tests/baseline/tool-lsp-completion.tsv}"
MIN_TIERS=6
MIN_CASES=1
MIN_HITS=6

# shellcheck source=tests/lib/tool-lsp-completion.sh
. tests/lib/tool-lsp-completion.sh

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

echo "=== TOOL-003: LSP completion manifest ==="
for f in "$DOC" "$MANIFEST" compiler/src/lsp/lsp_diag.c compiler/src/lsp/lsp_diag.h; do
  if [ ! -f "$f" ]; then
    echo "tool-lsp-completion gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_tiers) MIN_TIERS="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
    min_hits) MIN_HITS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
TIER_N=0
CASE_N=0
EXPECT_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-lsp-completion FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    tiers)
      TIER_N=$((TIER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-lsp-completion FAIL: doc missing tier $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "tool-lsp-completion FAIL: missing golden $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "tool-lsp-completion FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    expect)
      EXPECT_N=$((EXPECT_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-lsp-completion FAIL: doc missing expect label $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "tool-lsp-completion FAIL: missing file $path" >&2
        MISS=$((MISS + 1))
      elif [ "$item_id" = "impl_cap" ]; then
        if ! grep -qF 'completionProvider' "$path" 2>/dev/null; then
          echo "tool-lsp-completion FAIL: missing completionProvider in $path" >&2
          MISS=$((MISS + 1))
        fi
      elif [ "$item_id" = "impl_completion" ]; then
        if ! grep -qF 'lsp_build_completion_response' "$path" 2>/dev/null; then
          echo "tool-lsp-completion FAIL: missing lsp_build_completion_response" >&2
          MISS=$((MISS + 1))
        fi
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "tool-lsp-completion FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-lsp-completion FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "tool-lsp-completion FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-lsp-completion FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$TIER_N" -lt "$MIN_TIERS" ]; then
  echo "tool-lsp-completion gate FAIL: tiers=${TIER_N} < min ${MIN_TIERS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "tool-lsp-completion gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$EXPECT_N" -lt "$MIN_HITS" ]; then
  echo "tool-lsp-completion gate FAIL: expects=${EXPECT_N} < min ${MIN_HITS}" >&2
  exit 1
fi

for kw in completion CompletionItem hit rate runnable report triggerCharacters; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "tool-lsp-completion gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "tool-lsp-completion gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "tool-lsp-completion manifest OK (tiers=${TIER_N} cases=${CASE_N} expects=${EXPECT_N})"

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -n "$SHU_BIN" ] && native_shu "$SHU_BIN" && "$SHU_BIN" --help 2>/dev/null | grep -q '\-\-lsp'; then
  echo "=== TOOL-003: LSP completion hooks (SHU=$SHU_BIN) ==="
  chmod +x tests/run-lsp-completion.sh tests/run-lsp.sh
  SHU="$SHU_BIN" ./tests/run-lsp-completion.sh
  echo "tool-lsp-completion hooks OK"
else
  echo "tool-lsp-completion gate SKIP hooks (no native shu --lsp)" >&2
fi

echo "tool-lsp-completion gate OK"
