#!/usr/bin/env bash
# COMP-010: compile-artifact size attribution smoke (false-authority honesty).
#
# Honesty: soft SKIP→OK when no artifacts retired. Prefer product xlang_asm
# present; run compiler-make before measure. Explicit bad XLANG = hard die.
# Missing native = hard die. Required artifact miss = hard die. Optional
# missing = skip=. Empty measure after make = hard die (refuse soft
# SKIP→OK). Report run=/skip=.
#
# Usage:
#   ./tests/run-comp-size-attrib.sh
#   XLANG_SIZE_ATTRIB_REPORT=/tmp/report.tsv ./tests/run-comp-size-attrib.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/comp-size-attrib.sh
. tests/lib/comp-size-attrib.sh

MATRIX="${XLANG_SIZE_ATTRIB_MATRIX:-tests/baseline/comp-size-attrib-matrix.tsv}"
REPORT="${XLANG_SIZE_ATTRIB_REPORT:-/tmp/comp_size_attrib_report.$$.tsv}"
PREFIX="xlang: [XLANG_COMP_SIZE_ATTRIB]"
RUN_OK=0
SKIP=0

die() {
  echo "comp-size-attrib FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
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

echo "=== COMP-010: size attribution smoke ==="

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

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
      if [ "$policy" = "required" ]; then
        die "missing rollup $rel"
      fi
      echo "comp-size-attrib SKIP $art_id (no $rel)"
      SKIP=$((SKIP + 1))
      continue
    fi
  else
    path="$(comp_size_attrib_resolve_path "$rel" 2>/dev/null || true)"
    if [ -z "$path" ]; then
      if [ "$policy" = "required" ]; then
        die "missing required $rel"
      fi
      echo "comp-size-attrib SKIP $art_id (no $rel)"
      SKIP=$((SKIP + 1))
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
  RUN_OK=$((RUN_OK + 1))
  printf '%s\t%s\t%s\t%s\t%s\n' "$art_id" "$kind" "$file_b" "$text_b" "$note" >>"$TMP_ROWS"
  echo "comp-size-attrib: $art_id kind=$kind file=${file_b}B text=${text_b}B"
done < "$MATRIX"

# Refuse soft SKIP→OK when the measure set is empty after make.
if [ "$COUNT" -lt 1 ]; then
  die "no artifacts present after make (refuse soft SKIP→OK)"
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

if [ -z "${XLANG_SIZE_ATTRIB_REPORT:-}" ]; then
  head -12 "$REPORT"
  rm -f "$REPORT" 2>/dev/null || true
fi

echo "comp-size-attrib: distribution total=${TOTAL}B artifacts=${COUNT} top=${TOP_ID}:${TOP_PCT}%"
echo "comp-size-attrib OK"
ok_report
