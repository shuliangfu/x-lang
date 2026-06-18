#!/usr/bin/env bash
# COMP-008：链接符号冲突 fixture 烟测
#
# 用法：
#   ./tests/run-comp-link-sym.sh
#   ./tests/run-comp-link-sym.sh tests/fixtures/comp-link-sym/undefined_parser.log
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/comp-link-sym.sh
. tests/lib/comp-link-sym.sh

CASES="${SHU_LINK_SYM_CASES:-tests/baseline/comp-link-sym-cases.tsv}"
FIX_DIR="tests/fixtures/comp-link-sym"

echo "=== COMP-008: link symbol conflict smoke ==="

if [ -n "${1:-}" ]; then
  log="$(cat "$1")"
  comp_link_sym_classify "$log"
  echo "comp-link-sym OK"
  exit 0
fi

FAILS=0
while IFS=$'\t' read -r case_id logfile exp_kind exp_symbol exp_hint exp_repro; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  path="$FIX_DIR/$logfile"
  if [ ! -f "$path" ]; then
    echo "comp-link-sym FAIL: missing fixture $path" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  log="$(cat "$path")"
  got_kind=""
  got_symbol=""
  got_hint=""
  got_repro=""
  while IFS='=' read -r k v; do
    case "$k" in
      SHU_LINK_KIND) got_kind="$v" ;;
      SHU_LINK_SYMBOL) got_symbol="$v" ;;
      SHU_LINK_HINT) got_hint="$v" ;;
      SHU_LINK_REPRO) got_repro="$v" ;;
    esac
  done < <(comp_link_sym_classify "$log" 2>/dev/null || true)

  ok=1
  if [ "$got_kind" != "$exp_kind" ]; then ok=0; fi
  if [ "$exp_symbol" != "-" ] && [ "$got_symbol" != "$exp_symbol" ]; then ok=0; fi
  if [ "$got_hint" != "$exp_hint" ]; then ok=0; fi
  if [ "$got_repro" != "$exp_repro" ]; then ok=0; fi

  if [ "$ok" -eq 0 ]; then
    echo "comp-link-sym FAIL $case_id: kind=$got_kind want=$exp_kind sym=$got_symbol want=$exp_symbol hint=$got_hint want=$exp_hint repro=$got_repro want=$exp_repro" >&2
    FAILS=$((FAILS + 1))
  else
    echo "comp-link-sym OK $case_id → $exp_kind / ${exp_symbol:-?}"
  fi
done < "$CASES"

if [ "$FAILS" -gt 0 ]; then
  echo "comp-link-sym FAIL: ${FAILS} case(s)" >&2
  exit 1
fi
echo "comp-link-sym OK"
