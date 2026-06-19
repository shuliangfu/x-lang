#!/usr/bin/env bash
# TOOL-006：项目脚手架 manifest 门禁
#
# 用法：./tests/run-tool-scaffold-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_TOOL_SCAFFOLD_DOC:-analysis/tool-project-scaffold-v1.md}"
MANIFEST="${SHUX_TOOL_SCAFFOLD_MANIFEST:-tests/baseline/tool-project-scaffold.tsv}"
TEMPLATE="tests/templates/project-hello"
MIN_RULES=5
MIN_TEMPLATE_FILES=2
EXPECT_EXIT=42

# shellcheck source=tests/lib/tool-scaffold.sh
. tests/lib/tool-scaffold.sh

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

echo "=== TOOL-006: project scaffold manifest ==="
for f in "$DOC" "$MANIFEST" "$TEMPLATE/main.sx" "$TEMPLATE/README.md" scripts/shux-new.sh; do
  if [ ! -f "$f" ]; then
    echo "tool-scaffold gate FAIL: missing $f" >&2
    exit 1
  fi
done

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
if [ "$RULE_N" -lt "$MIN_RULES" ]; then
  echo "tool-scaffold gate FAIL: rules=${RULE_N} < min ${MIN_RULES}" >&2
  exit 1
fi
if [ "$TPL_N" -lt "$MIN_TEMPLATE_FILES" ] || [ "${FILES_N:-0}" -lt "$MIN_TEMPLATE_FILES" ]; then
  echo "tool-scaffold gate FAIL: template files=${FILES_N} tpl_rows=${TPL_N}" >&2
  exit 1
fi

if ! grep -q 'function main(): i32' "$TEMPLATE/main.sx" 2>/dev/null; then
  echo "tool-scaffold gate FAIL: template missing main()" >&2
  exit 1
fi
if ! grep -qi 'shux run' "$TEMPLATE/README.md" 2>/dev/null; then
  echo "tool-scaffold gate FAIL: README missing shux run" >&2
  exit 1
fi

for kw in scaffold template runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "tool-scaffold gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "tool-scaffold gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "tool-scaffold manifest OK (rules=${RULE_N} files=${FILES_N} expect_exit=${EXPECT_EXIT})"

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
  echo "=== TOOL-006: scaffold hooks (SHUX=$SHUX_BIN) ==="
  chmod +x tests/run-tool-scaffold.sh scripts/shux-new.sh
  SHUX="$SHUX_BIN" SHUX_SCAFFOLD_EXPECT_EXIT="$EXPECT_EXIT" ./tests/run-tool-scaffold.sh
  DEMO="/tmp/shux_new_demo_$$"
  rm -rf "$DEMO"
  ./scripts/shux-new.sh "$DEMO"
  if [ ! -f "$DEMO/main.sx" ]; then
    echo "tool-scaffold FAIL: shux-new did not create main.sx" >&2
    rm -rf "$DEMO"
    exit 1
  fi
  rm -rf "$DEMO"
  echo "tool-scaffold hooks OK"
else
  echo "tool-scaffold gate SKIP hooks (no native shux)" >&2
fi

echo "tool-scaffold gate OK"
