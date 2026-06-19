#!/usr/bin/env bash
# COMP-010：编译产物体积归因烟测
#
# 用法：
#   ./tests/run-comp-size-attrib.sh
#   SHUX_SIZE_ATTRIB_REPORT=/tmp/report.tsv ./tests/run-comp-size-attrib.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/comp-size-attrib.sh
. tests/lib/comp-size-attrib.sh

MATRIX="${SHUX_SIZE_ATTRIB_MATRIX:-tests/baseline/comp-size-attrib-matrix.tsv}"
REPORT="${SHUX_SIZE_ATTRIB_REPORT:-/tmp/comp_size_attrib_report.$$.tsv}"

echo "=== COMP-010: size attribution smoke ==="

TOTAL=0
COUNT=0
TOP_ID=""
TOP_PCT="0"
TMP_ROWS="$(mktemp /tmp/comp_size_attrib_rows.XXXXXX)"
trap 'rm -f "$TMP_ROWS" 2>/dev/null || true' EXIT

while IFS=$'\t' read -r art_id kind rel policy _notes; do
  [ -z "${art_id:-}" ] && continue
  case "$art_id" in \#*|min_*) continue ;; esac

  file_b=0
  text_b=0
  note=""

  if [ "$kind" = "rollup" ]; then
    if dir="$(comp_size_attrib_resolve_path "$rel" 2>/dev/null || true)" && [ -n "$dir" ]; then
      read -r file_b text_b <<<"$(comp_size_attrib_rollup_build_asm "$dir" | tr '\t' ' ')"
      note="rollup *.o"
    else
      [ "$policy" = "required" ] && { echo "comp-size-attrib FAIL: missing rollup $rel" >&2; exit 1; }
      echo "comp-size-attrib SKIP $art_id (no $rel)"
      continue
    fi
  else
    path="$(comp_size_attrib_resolve_path "$rel" 2>/dev/null || true)"
    if [ -z "$path" ]; then
      if [ "$policy" = "required" ]; then
        echo "comp-size-attrib FAIL: missing required $rel" >&2
        exit 1
      fi
      echo "comp-size-attrib SKIP $art_id (no $rel)"
      continue
    fi
    file_b="$(comp_size_attrib_file_bytes "$path")"
    if [ "$kind" = "object" ]; then
      text_b="$(comp_size_attrib_o_text_bytes "$path")"
      note="__text"
    fi
  fi

  TOTAL=$((TOTAL + file_b))
  COUNT=$((COUNT + 1))
  printf '%s\t%s\t%s\t%s\t%s\n' "$art_id" "$kind" "$file_b" "$text_b" "$note" >>"$TMP_ROWS"
  echo "comp-size-attrib: $art_id kind=$kind file=${file_b}B text=${text_b}B"
done < "$MATRIX"

if [ "$COUNT" -lt 1 ]; then
  echo "comp-size-attrib SKIP (no artifacts present; run make -C compiler first?)"
  echo "comp-size-attrib OK"
  exit 0
fi

{
  echo "# comp-size-attrib report (TSV)"
  echo "artifact_id	kind	file_bytes	text_bytes	pct_of_total	notes"
  while IFS=$'\t' read -r art_id kind file_b text_b note; do
    pct="$(awk -v f="$file_b" -v t="$TOTAL" 'BEGIN { if (t>0) printf "%.1f", f*100/t; else print "0" }')"
    echo -e "${art_id}\t${kind}\t${file_b}\t${text_b}\t${pct}\t${note}"
    top_cmp="$(awk -v a="$pct" -v b="$TOP_PCT" 'BEGIN { print (a+0 > b+0) ? 1 : 0 }')"
    if [ "$top_cmp" = "1" ]; then
      TOP_ID="$art_id"
      TOP_PCT="$pct"
    fi
  done <"$TMP_ROWS"
} >"$REPORT"

if [ -z "${SHUX_SIZE_ATTRIB_REPORT:-}" ]; then
  head -12 "$REPORT"
  rm -f "$REPORT" 2>/dev/null || true
fi

echo "comp-size-attrib: distribution total=${TOTAL}B artifacts=${COUNT} top=${TOP_ID}:${TOP_PCT}%"
echo "comp-size-attrib OK"
