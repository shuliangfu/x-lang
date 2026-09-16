#!/usr/bin/env bash
# TOOL-003: LSP completion quality manifest gate.
#
# Honesty: soft SKIP→OK when no native / no --lsp (bare "gate OK") + prefer
# xlang-c before xlang_asm retired. Prefer product xlang_asm. Explicit bad
# XLANG = hard die. Missing native = hard die. Tip binary without --lsp =
# skip=1 (honest N/A, not silent OK). DOC authority = archive/tool.
# Report run=/hooks=/skip=.
#
# Usage: ./tests/run-tool-lsp-completion-gate.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/tool-lsp-completion.sh
. tests/lib/tool-lsp-completion.sh

DOC="${XLANG_TOOL_LSP_COMP_DOC:-analysis/archive/tool/tool-lsp-completion-v1.md}"
MANIFEST="${XLANG_TOOL_LSP_COMP_MANIFEST:-tests/baseline/tool-lsp-completion.tsv}"
MIN_TIERS=6
MIN_CASES=1
MIN_HITS=6
PREFIX="xlang: [XLANG_TOOL_LSP_COMPLETION]"
RUN_OK=0
HOOKS_OK=0
SKIP=0

die() {
  echo "tool-lsp-completion gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} hooks=${HOOKS_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} hooks=${HOOKS_OK} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== TOOL-003: LSP completion manifest (lsp_diag.c retired) ==="
if [ -f compiler/src/lsp/lsp_diag.c ]; then
  die "lsp_diag.c resurrected (live = lsp_diag.h / runtime_lsp_glue)"
fi
if [ -f analysis/tool-lsp-completion-v1.md ]; then
  die "top-level DOC resurrected (live = archive/tool/)"
fi
for f in "$DOC" "$MANIFEST" compiler/src/lsp/lsp_diag.h compiler/seeds/runtime_lsp_glue.from_x.c; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

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

[ "$TIER_N" -ge "$MIN_TIERS" ] || die "tiers=${TIER_N} < min ${MIN_TIERS}"
[ "$CASE_N" -ge "$MIN_CASES" ] || die "cases=${CASE_N} < min ${MIN_CASES}"
[ "$EXPECT_N" -ge "$MIN_HITS" ] || die "expects=${EXPECT_N} < min ${MIN_HITS}"
for kw in completion CompletionItem hit rate runnable report triggerCharacters; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "tool-lsp-completion manifest OK (tiers=${TIER_N} cases=${CASE_N} expects=${EXPECT_N})"
RUN_OK=1

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

if "$XLANG_BIN" --help 2>/dev/null | grep -q '\-\-lsp'; then
  echo "=== TOOL-003: LSP completion hooks (XLANG=$XLANG_BIN) ==="
  chmod +x tests/run-lsp-completion.sh tests/run-lsp.sh
  XLANG="$XLANG_BIN" ./tests/run-lsp-completion.sh
  HOOKS_OK=1
  echo "tool-lsp-completion hooks OK"
else
  # Tip product binary help may omit --lsp; honest skip, not soft silence.
  SKIP=1
  echo "tool-lsp-completion gate SKIP hooks (no --lsp in XLANG help; skip=1)" >&2
fi

ok_report
echo "tool-lsp-completion gate OK"
