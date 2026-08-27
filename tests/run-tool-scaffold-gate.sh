#!/usr/bin/env bash
# TOOL-006: project scaffold manifest gate.
#
# Honesty: soft SKIP→OK when no native xlang (bare "gate OK") + prefer
# xlang-c before xlang_asm retired. Prefer product xlang_asm. Explicit
# bad XLANG = hard die. Missing native = hard die (hooks are the live
# face). DOC authority = archive/tool. Report run=/hooks=/skip=.
#
# Usage: ./tests/run-tool-scaffold-gate.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/tool-scaffold.sh
. tests/lib/tool-scaffold.sh

DOC="${XLANG_TOOL_SCAFFOLD_DOC:-analysis/archive/tool/tool-project-scaffold-v1.md}"
MANIFEST="${XLANG_TOOL_SCAFFOLD_MANIFEST:-tests/baseline/tool-project-scaffold.tsv}"
TEMPLATE="tests/templates/project-hello"
MIN_RULES=5
MIN_TEMPLATE_FILES=2
EXPECT_EXIT=42
PREFIX="xlang: [XLANG_TOOL_SCAFFOLD]"
RUN_OK=0
HOOKS_OK=0
SKIP=0

die() {
  echo "tool-scaffold gate FAIL: $*" >&2
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

echo "=== TOOL-006: project scaffold manifest (archive DOC) ==="
if [ -f analysis/tool-project-scaffold-v1.md ]; then
  die "top-level DOC resurrected (live = archive/tool/)"
fi
for f in "$DOC" "$MANIFEST" "$TEMPLATE/main.x" "$TEMPLATE/README.md" scripts/xlang-new.sh; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_rules) MIN_RULES="$c2" ;;
    min_template_files) MIN_TEMPLATE_FILES="$c2" ;;
    expect_exit) EXPECT_EXIT="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
RULE_N=0
TPL_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|expect_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-scaffold FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    rules)
      RULE_N=$((RULE_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-scaffold FAIL: doc missing rule $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    template)
      TPL_N=$((TPL_N + 1))
      if [ ! -f "$src" ]; then
        echo "tool-scaffold FAIL: missing template $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "tool-scaffold FAIL: doc missing template $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "tool-scaffold FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-scaffold FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "tool-scaffold FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-scaffold FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

FILES_N=$(tool_scaffold_template_files "$TEMPLATE")
[ "$RULE_N" -ge "$MIN_RULES" ] || die "rules=${RULE_N} < min ${MIN_RULES}"
if [ "$TPL_N" -lt "$MIN_TEMPLATE_FILES" ] || [ "${FILES_N:-0}" -lt "$MIN_TEMPLATE_FILES" ]; then
  die "template files=${FILES_N} tpl_rows=${TPL_N}"
fi
grep -q 'function main(): i32' "$TEMPLATE/main.x" 2>/dev/null || die "template missing main()"
grep -qi 'xlang run' "$TEMPLATE/README.md" 2>/dev/null || die "README missing xlang run"
for kw in scaffold template runnable report; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "tool-scaffold manifest OK (rules=${RULE_N} files=${FILES_N} expect_exit=${EXPECT_EXIT})"
RUN_OK=1

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== TOOL-006: scaffold hooks (XLANG=$XLANG_BIN) ==="
chmod +x tests/run-tool-scaffold.sh scripts/xlang-new.sh
XLANG="$XLANG_BIN" XLANG_SCAFFOLD_EXPECT_EXIT="$EXPECT_EXIT" ./tests/run-tool-scaffold.sh
DEMO="/tmp/xlang_new_demo_$$"
rm -rf "$DEMO"
./scripts/xlang-new.sh "$DEMO"
if [ ! -f "$DEMO/main.x" ]; then
  rm -rf "$DEMO"
  die "xlang-new did not create main.x"
fi
rm -rf "$DEMO"
HOOKS_OK=1
echo "tool-scaffold hooks OK"

ok_report
echo "tool-scaffold gate OK"
