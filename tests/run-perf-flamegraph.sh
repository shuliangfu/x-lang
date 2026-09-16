#!/usr/bin/env bash
# PERF-005: perf sample + Top-N hotspot report generator.
#
# Honesty: soft SKIP→OK when no perf / no native xlang retired as bare
# exit 0 without skip=. Prefer product xlang_asm. Explicit bad XLANG =
# hard die. Partial Top-N = obs (warn line + OBS). Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-perf-flamegraph.sh
#   XLANG=./compiler/xlang_asm XLANG_PERF_FLAMEGRAPH_CASE=loop_i32_compile ./tests/run-perf-flamegraph.sh
#   XLANG_PERF_FLAMEGRAPH_OUT_DIR=/tmp/fg ./tests/run-perf-flamegraph.sh
# PLATFORM: LINUX (perf gold); Darwin/other = skip=1.
set -e
cd "$(dirname "$0")/.."

MANIFEST="${XLANG_PERF_FLAMEGRAPH_TSV:-tests/baseline/perf-flamegraph.tsv}"
OUT_DIR="${XLANG_PERF_FLAMEGRAPH_OUT_DIR:-/tmp/xlang-perf-flamegraph}"
ONLY_CASE="${XLANG_PERF_FLAMEGRAPH_CASE:-}"
TOPN="${XLANG_PERF_FLAMEGRAPH_TOPN:-20}"
PREFIX="${XLANG_PERF_FLAMEGRAPH_PREFIX:-xlang: [XLANG_PERF_FLAMEGRAPH]}"
RUN_OK=0
OBS=0
SKIP=0

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/perf-flamegraph.sh
. tests/lib/perf-flamegraph.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

die() {
  echo "run-perf-flamegraph FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

# Parse manifest anchor into perf-sampled xlang subcommand (without perf itself).
# check:   anchor like "check path/to.x"
# compile: anchor like "compile path/to.x -o /tmp/out"
fg_run_profile_case() {
  local item_id="$1"
  local anchor="$2"
  local out_case="$3"
  local log_file="$4"
  local action rest src outpath
  action="${anchor%% *}"
  rest="${anchor#* }"
  case "$action" in
    check)
      perf_fg_top_symbols "$item_id" "$XLANG_BIN" check "$rest" >>"$out_case" 2>>"$log_file"
      ;;
    compile)
      src=$(echo "$rest" | awk '{print $1}')
      outpath=$(echo "$rest" | awk '{for(i=1;i<=NF;i++) if($i=="-o") print $(i+1)}')
      perf_fg_top_symbols "$item_id" "$XLANG_BIN" "$src" -o "$outpath" >>"$out_case" 2>>"$log_file"
      ;;
    *)
      return 1
      ;;
  esac
}

if [ ! -f "$MANIFEST" ]; then
  die "missing manifest $MANIFEST"
fi

# Explicit bad XLANG hard-dies before soft platform skip.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "XLANG=${XLANG} not native (refuse soft SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || true
fi

if ! perf_fg_probe_ok; then
  SKIP=1
  echo "${PREFIX} SKIP (perf record unavailable; need Linux + perf; skip=1)" >&2
  ok_report
  exit 0
fi

if [ -z "${XLANG_BIN:-}" ]; then
  die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK)"
fi

mkdir -p "$OUT_DIR"
SUMMARY="${OUT_DIR}/top${TOPN}-summary.tsv"
: >"$SUMMARY"
echo "${PREFIX} xlang=${XLANG_BIN} out=${OUT_DIR} topn=${TOPN}" >&2

FAIL=0
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix|report_header|hook_*|cross_*|smoke_case) continue ;; esac
  case "$kind" in
    profile_case)
      if [ -n "$ONLY_CASE" ] && [ "$item_id" != "$ONLY_CASE" ]; then
        continue
      fi
      action="${anchor%% *}"
      rest="${anchor#* }"
      echo "${PREFIX} profiling case=${item_id} action=${action} ${rest}" >&2
      out_case="${OUT_DIR}/${item_id}-top${TOPN}.tsv"
      : >"$out_case"
      set +e
      fg_run_profile_case "$item_id" "$anchor" "$out_case" "${OUT_DIR}/${item_id}.log"
      rc=$?
      set -e
      if [ "$rc" -eq 0 ]; then
        cat "$out_case" >>"$SUMMARY"
        echo "${PREFIX} case=${item_id} report=${out_case}" >&2
        RUN_OK=1
      elif [ "$rc" -eq 2 ]; then
        # Partial Top-N = obs (not silent OK).
        OBS=1
        echo "${PREFIX} OBS: case=${item_id} partial top (see ${out_case})" >&2
        [ -f "$out_case" ] && cat "$out_case" >>"$SUMMARY"
        RUN_OK=1
      else
        echo "${PREFIX} case=${item_id} FAIL" >&2
        FAIL=$((FAIL + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$FAIL" -gt 0 ]; then
  die "${FAIL} case(s)"
fi
if [ "$RUN_OK" -eq 0 ] && [ -n "$ONLY_CASE" ]; then
  die "requested case ${ONLY_CASE} not profiled"
fi
echo "perf-flamegraph OK (summary=${SUMMARY})"
ok_report
exit 0
