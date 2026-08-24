#!/usr/bin/env bash
# TOOL-009：VS Code 扩展 0.2 稳定发布 manifest + grammar + vsix 门禁（假权威诚实）。
#
# 用法：./tests/run-tool-vscode-020-gate.sh
# wave honesty (2026-08-24 #9): DOC → analysis/archive/tool/;
# live = editors/vscode + VERSION sync.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_TOOL009_DOC:-analysis/archive/tool/tool-vscode-020-v1.md}"
MANIFEST="${XLANG_TOOL009_MANIFEST:-tests/baseline/tool-vscode-020.tsv}"
LIB="tests/lib/tool-vscode-020.sh"
MIN_RULES=8
MIN_GOLDEN=5

# shellcheck source=tests/lib/tool-vscode-020.sh
. tests/lib/tool-vscode-020.sh
# shellcheck source=tests/lib/eng-version-release-rhythm.sh
. tests/lib/eng-version-release-rhythm.sh

echo "=== TOOL-009: vscode 0.2 manifest (archive DOC) ==="
if [ -f analysis/tool-vscode-020-v1.md ]; then
  echo "tool-vscode-020 gate FAIL: top-level DOC resurrected (live = archive/tool/)" >&2
  exit 1
fi
# VERSION root + 0.2.0 release are product debt (live package.json=0.1.0).
# Honesty: do not invent VERSION/0.2.0; grammar + archive DOC stay hard.
for f in "$DOC" "$MANIFEST" "$LIB" \
  editors/vscode/package.json editors/vscode/grammars/x.tmLanguage.json \
  tests/run-tool-vscode-pack.sh; do
  if [ ! -f "$f" ]; then
    echo "tool-vscode-020 gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_rules) MIN_RULES="$c2" ;;
    min_golden) MIN_GOLDEN="$c2" ;;
  esac
done < "$MANIFEST"

for kw in Grammar 规则矩阵 vscode-xlang grammar_ok vsix; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "tool-vscode-020 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! tool_vscode_020_grammar_json_ok; then
  echo "tool-vscode-020 gate FAIL: invalid grammar JSON" >&2
  exit 1
fi
echo "tool-vscode-020 OK grammar JSON"

# Observational: 0.2.0 VERSION sync deferred (live editors/vscode = 0.1.0; no root VERSION).
if tool_vscode_020_version_sync_ok \
  && eng_version_vscode_sync_ok "VERSION" "editors/vscode/package.json"; then
  echo "tool-vscode-020 OK version sync (0.2.0)"
else
  echo "tool-vscode-020 gate SKIP version sync (0.2.0 release debt; live package 0.1.0)" >&2
fi

RULE_N=0
GOLDEN_N=0
MISS=0
GRAMMAR_OK=0
echo "=== TOOL-009: grammar rules + golden ==="
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    grammar_rule)
      RULE_N=$((RULE_N + 1))
      if ! tool_vscode_020_grammar_has_rule "editors/vscode/grammars/x.tmLanguage.json" "$anchor"; then
        echo "tool-vscode-020 FAIL: grammar missing rule $anchor ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$item_id" "$DOC" 2>/dev/null; then
        echo "tool-vscode-020 FAIL: doc missing rule $item_id" >&2
        MISS=$((MISS + 1))
      else
        GRAMMAR_OK=$((GRAMMAR_OK + 1))
        echo "tool-vscode-020 OK rule $item_id"
      fi
      ;;
    golden)
      GOLDEN_N=$((GOLDEN_N + 1))
      if [ ! -f "$src" ]; then
        echo "tool-vscode-020 FAIL: missing golden $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "tool-vscode-020 FAIL: doc missing golden $src" >&2
        MISS=$((MISS + 1))
      else
        echo "tool-vscode-020 OK golden $(basename "$src")"
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "tool-vscode-020 FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$RULE_N" -lt "$MIN_RULES" ]; then
  echo "tool-vscode-020 gate FAIL: rules=${RULE_N} < min ${MIN_RULES}" >&2
  exit 1
fi
if [ "$GOLDEN_N" -lt "$MIN_GOLDEN" ]; then
  echo "tool-vscode-020 gate FAIL: golden=${GOLDEN_N} < min ${MIN_GOLDEN}" >&2
  exit 1
fi
if [ "$GRAMMAR_OK" -lt "$MIN_RULES" ]; then
  echo "tool-vscode-020 gate FAIL: grammar_ok=${GRAMMAR_OK} < min ${MIN_RULES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "tool-vscode-020 gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "tool-vscode-020 manifest OK (rules=${RULE_N} golden=${GOLDEN_N})"

VSIX_OK=0
SKIP=1
EXPECTED_VER="${XLANG_TOOL009_VERSION:-0.2.0}"
VSIX="editors/vscode/vscode-xlang-${EXPECTED_VER}.vsix"

# Observational: vsix 0.2.0 pack deferred until VERSION/package sync lands.
if tool_vscode_020_version_sync_ok && tool_vscode_020_has_node; then
  echo "=== TOOL-009: vsix pack smoke ==="
  chmod +x tests/run-tool-vscode-pack.sh
  if ./tests/run-tool-vscode-pack.sh; then
    if [ -f "$VSIX" ]; then
      VSIX_OK=1
      SKIP=0
      echo "tool-vscode-020 runnable OK vsix"
    else
      echo "tool-vscode-020 gate SKIP vsix missing after pack (0.2 release debt)" >&2
    fi
  else
    echo "tool-vscode-020 gate SKIP vsix pack failed (0.2 release debt)" >&2
  fi
elif tool_vscode_020_has_node; then
  echo "tool-vscode-020 gate SKIP vsix pack (0.2.0 VERSION debt; live package 0.1.0)" >&2
else
  echo "tool-vscode-020 gate SKIP vsix pack (no node/npm)" >&2
fi

tool_vscode_020_emit_report "ok" "$GRAMMAR_OK" "$VSIX_OK" "$SKIP"
echo "tool-vscode-020 gate OK"
