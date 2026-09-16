#!/usr/bin/env bash
# TOOL-002: linter rules manifest + nested lint-check hooks — leftover
# native_xlang duplicate of dod_native_exe →硬绿.
#
# Honesty: leftover parent `native_xlang` (third resolver / false authority)
# retired. Nested run-lint-check.sh already honesty-closed (resolve_shu /
# prefer-asm / explicit-bad hard-die). G.7: complete existing nested
# resolve_shu; do not fork a third resolver in this host. Explicit-bad
# caller XLANG hard-dies via parent dod_native_exe before nesting.
# Missing native still FAIL (nested). Manifest + archive DOC = hard.
# Report: run=/obs=/skip=. Keep `tool-lint gate OK`.
# wave honesty (2026-08-24 #9): DOC → analysis/archive/tool/;
# live = lsp_diag.h + fmt_check_cmd.from_x.c. Refuse lsp_diag.c resurrect.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-tool-lint-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/tool-lint.sh
. tests/lib/tool-lint.sh

DOC="${XLANG_TOOL_LINT_DOC:-analysis/archive/tool/tool-lint-rules-v1.md}"
MANIFEST="${XLANG_TOOL_LINT_MANIFEST:-tests/baseline/tool-lint-rules.tsv}"
PROFILE="${XLANG_TOOL_LINT_PROFILE_TSV:-tests/baseline/tool-lint-ci-profile.tsv}"
PREFIX="xlang: [XLANG_TOOL_LINT]"
MIN_RULES=6
MIN_CASES=4
MIN_PROFILE_ROWS=6
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "tool-lint gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

abs_of() {
  case "$1" in
    /*) echo "$1" ;;
    *) echo "$(pwd)/$1" ;;
  esac
}

echo "=== TOOL-002: linter rules manifest (archive DOC) ==="
if [ -f analysis/tool-lint-rules-v1.md ]; then
  echo "tool-lint gate FAIL: top-level DOC resurrected (live = archive/tool/)" >&2
  exit 1
fi
if [ -f compiler/src/lsp/lsp_diag.c ]; then
  echo "tool-lint gate FAIL: lsp_diag.c resurrected (live = lsp_diag.h)" >&2
  exit 1
fi
for f in "$DOC" "$MANIFEST" "$PROFILE" compiler/src/lsp/lsp_diag.h compiler/seeds/fmt_check_cmd.from_x.c; do
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

# Explicit XLANG that is missing/non-native hard-dies (refuse leftover
# native_xlang / leftover ignore of explicit-bad). Unset XLANG: nested
# already-honesty-closed run-lint-check.sh resolve_shu prefers asm.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  abs="$(abs_of "$XLANG")"
  if ! dod_native_exe "$abs"; then
    die "explicit XLANG not native (refuse leftover native_xlang / leftover ignore of explicit-bad / leftover XLANG fallthrough / soft SKIP→OK / soft auto-make)"
  fi
  export XLANG="$abs"
  export XLANG_LINK_XLANG="$abs"
fi

echo "=== TOOL-002: lint hooks (nested run-lint-check.sh; refuse leftover native_xlang) ==="
chmod +x tests/run-lint-check.sh
# Drop leftover parent native_xlang. Nested gate already honesty-closed:
# explicit XLANG that is missing/non-native hard-dies; missing native FAIL.
./tests/run-lint-check.sh || die "nested lint-check failed (refuse leftover native_xlang / soft SKIP→OK)"
RUN_OK=$((RUN_OK + 1))
echo "tool-lint hooks OK"

echo "tool-lint gate OK"
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
exit 0
