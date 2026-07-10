#!/usr/bin/env bash
# COMP-004：WPO v1 manifest 门禁
#
# 用法：./tests/run-comp-wpo-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_COMP_WPO_DOC:-analysis/comp-wpo-v1.md}"
MANIFEST="${SHUX_COMP_WPO_MANIFEST:-tests/baseline/comp-wpo.tsv}"
PROTO="${SHUX_COMP_WPO_PROTO:-tests/baseline/comp-wpo-prototype.tsv}"
MIN_STAGES=6
MIN_CASES=4
MIN_CAPS=6

# shellcheck source=tests/lib/comp-wpo.sh
. tests/lib/comp-wpo.sh

echo "=== COMP-004: WPO v1 manifest ==="
for f in "$DOC" "$MANIFEST" "$PROTO" \
  compiler/seeds/runtime.from_x.c compiler/scripts/wpo_dce.pl compiler/scripts/wpo_const_spec.pl \
  tests/wpo/dead_fn.x tests/wpo/dead_user.x tests/wpo/if_block_reach.x tests/wpo/const_spec.x \
  tests/run-wpo-dce-emit.sh tests/run-pipeline-wpo-optin-smoke.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-wpo gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_stages) MIN_STAGES="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_capabilities) MIN_CAPS="$c2" ;;
  esac
done < "$PROTO"

MISS=0
STAGE_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-wpo FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    stages)
      STAGE_N=$((STAGE_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-wpo FAIL: doc missing stage $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-wpo FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "comp-wpo FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "comp-wpo FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "comp-wpo FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ref)
      if [ ! -f "$src" ]; then
        echo "comp-wpo FAIL: missing hook $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-wpo FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-wpo FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-wpo FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "comp-wpo FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-wpo FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

CAP_N=0
while IFS=$'\t' read -r cap script _status _notes; do
  [ -z "${cap:-}" ] && continue
  case "$cap" in \#*|min_*) continue ;; esac
  CAP_N=$((CAP_N + 1))
  if ! grep -qF "$cap" "$DOC" 2>/dev/null; then
    echo "comp-wpo FAIL: doc missing capability $cap" >&2
    MISS=$((MISS + 1))
  fi
  if [ ! -f "tests/$script" ]; then
    echo "comp-wpo FAIL: missing prototype script tests/$script" >&2
    MISS=$((MISS + 1))
  fi
done < "$PROTO"

if [ "$STAGE_N" -lt "$MIN_STAGES" ]; then
  echo "comp-wpo gate FAIL: stages=${STAGE_N} < min ${MIN_STAGES}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "comp-wpo gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$CAP_N" -lt "$MIN_CAPS" ]; then
  echo "comp-wpo gate FAIL: capabilities=${CAP_N} < min ${MIN_CAPS}" >&2
  exit 1
fi

for kw in wpo whole program prototype runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-wpo gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "comp-wpo gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "comp-wpo manifest OK (stages=${STAGE_N} cases=${CASE_N} caps=${CAP_N})"

if [ "${SHUX_COMP_WPO_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "comp-wpo gate OK (manifest only)"
  exit 0
fi

chmod +x tests/run-comp-wpo.sh
./tests/run-comp-wpo.sh

echo "comp-wpo gate OK"
