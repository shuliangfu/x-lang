#!/usr/bin/env bash
# S3 pipeline gate: build_asm/pipeline.o __text / real_funcs / key insn floors.
#
# Honesty: soft XLANG_S3_FAIL_ON_REGRESSION / missing-.o soft OK retired.
# Linux x86_64 gold hard-dies missing/under / stub funcs. Darwin CI stub
# (__text≈4) is N/A (skip=1). `xlang check` observational (paused). On gold,
# stub-sized pipeline.o triggers sync EMIT_HEAVY before floors.
#
# Usage: ./tests/run-s3-pipeline-gate.sh
# Report: run=/obs=/skip=
# PLATFORM: LINUX|UBUNTU x86_64 gold; DARWIN N/A when stub/missing.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. ./tests/lib/ci-host.sh

PIPELINE_X="compiler/src/pipeline/pipeline.x"
PIPELINE_O="compiler/build_asm/pipeline.o"
BASELINE="${XLANG_S3_PIPELINE_BASELINE:-tests/baseline/s3-pipeline-o.tsv}"
# Stale TU .o can duplicate symbols with build_asm/pipeline.o (strict relink).
rm -f compiler/build_asm/pipeline_bootstrap_link_alias.o 2>/dev/null || true
MIN_TEXT=$(awk -F'\t' '$1=="min_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT=${MIN_TEXT:-512}
MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=${MIN_REAL:-0}
STUB_TEXT_MAX=8192

PREFIX="xlang: [XLANG_S3_PIPELINE_GATE]"
RUN_OK=0
OBS=0
SKIP=0
CHECK_OK=0

die() {
  echo "s3 pipeline gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} check=${CHECK_OK} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} check=${CHECK_OK} host=$(ci_host_summary)"
}

is_gold() { ci_is_linux_x64; }

count_real_asm_funcs() {
  python3 - "$1" <<'PY'
import subprocess, re, sys
path = sys.argv[1]
head = r"^[0-9a-f]+ <(_?[^+>]+)>:\n"
nxt = r"(?=^[0-9a-f]+ <_?[^+>]+>:\n|\Z)"
try:
    text = subprocess.check_output(["objdump", "-d", path], text=True, stderr=subprocess.DEVNULL)
except subprocess.CalledProcessError:
    print(0)
    sys.exit(0)
real = 0
for m in re.finditer(head + r"((?:.*\n)*?)" + nxt, text, re.M):
    insns = [ln for ln in m.group(2).splitlines() if ln.strip() and not ln.endswith(":")]
    if len(insns) > 10:
        real += 1
print(real)
PY
}

func_insn_count() {
  python3 - "$1" "$2" <<'PY'
import subprocess, re, sys
path, name = sys.argv[1], sys.argv[2]
text = subprocess.check_output(["objdump", "-d", path], text=True, stderr=subprocess.DEVNULL)
m = re.search(rf"^[0-9a-f]+ <(?:_)?{re.escape(name)}>:\n((?:.*\n)*?)(?=^[0-9a-f]+ <_?|\Z)", text, re.M)
if not m:
    print(0)
else:
    ins = [ln for ln in m.group(1).splitlines() if ln.strip() and not ln.endswith(":")]
    print(len(ins))
PY
}

text_section_size() {
  local o="$1"
  [ -f "$o" ] || { echo 0; return; }
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && { echo 0; return; }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

# ── 1) check observational ──
ENV_XLANG="${XLANG:-}"
XLANG=""
for cand in "$ENV_XLANG" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
  [ -n "$cand" ] && [ -x "$cand" ] || continue
  XLANG="$cand"
  break
done
if [ -n "$XLANG" ] && [ -x "$XLANG" ]; then
  set +e
  out=$("$XLANG" check "$PIPELINE_X" 2>&1)
  crc=$?
  set -e
  if [ "$crc" -eq 0 ] && [ -z "$out" ]; then
    CHECK_OK=1
  else
    OBS=$((OBS + 1))
    echo "s3 pipeline gate: obs — check not silent (paused gate; crc=$crc)"
  fi
else
  OBS=$((OBS + 1))
  echo "s3 pipeline gate: obs — no compiler for check"
fi

if [ ! -f "$PIPELINE_O" ]; then
  if is_gold; then
    die "missing $PIPELINE_O (run ./tests/run-s3-pipeline-sync-build-o.sh)"
  fi
  SKIP=1
  echo "s3 pipeline gate: missing $PIPELINE_O — non-gold N/A (skip=1)"
  ok_report
  exit 0
fi

sz=$(text_section_size "$PIPELINE_O")
real=$(count_real_asm_funcs "$PIPELINE_O")

# Gold: stub-sized → sync EMIT_HEAVY then remeasure.
if is_gold && [ "${sz:-0}" -lt "$STUB_TEXT_MAX" ] 2>/dev/null; then
  echo "s3 pipeline gate: stub pipeline.o __text=${sz} < ${STUB_TEXT_MAX}, sync EMIT_HEAVY ..."
  "$(dirname "$0")/run-s3-pipeline-sync-build-o.sh"
  sz=$(text_section_size "$PIPELINE_O")
  real=$(count_real_asm_funcs "$PIPELINE_O")
fi

echo "s3 pipeline gate: $PIPELINE_O __text=${sz} real_funcs=${real} (min_text=${MIN_TEXT}, min_real=${MIN_REAL})"

if [ "${XLANG_S3_UPDATE_BASELINE:-0}" = "1" ]; then
  {
    echo "# S3 pipeline.o：build_asm/pipeline.x 的 asm 产物 baseline"
    echo "# 更新：XLANG_S3_UPDATE_BASELINE=1 ./tests/run-s3-pipeline-gate.sh"
    printf 'min_text_bytes\t%s\n' "$sz"
    printf 'min_real_funcs\t%s\n' "$real"
    echo "min_text_emit_heavy	512"
  } >"$BASELINE"
  echo "s3 pipeline gate: updated baseline min_text_bytes=$sz min_real_funcs=$real"
fi

is_stub=0
if [ "${sz:-0}" -lt 256 ] 2>/dev/null; then
  is_stub=1
fi
if nm "$PIPELINE_O" 2>/dev/null | grep -qE ' T (_)?xlang_asm_ci_text_stub$' && [ "${real:-0}" -eq 0 ]; then
  is_stub=1
fi

if [ "$is_stub" -eq 1 ]; then
  if is_gold; then
    die "stub pipeline.o __text=${sz} real_funcs=${real}"
  fi
  SKIP=1
  echo "s3 pipeline gate: stub pipeline.o — non-gold N/A (skip=1)"
  ok_report
  exit 0
fi

if [ "${sz:-0}" -eq 0 ] 2>/dev/null; then
  die "empty __text in $PIPELINE_O"
fi

if ! awk -v s="$sz" -v m="$MIN_TEXT" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
  if is_gold; then
    die "__text $sz < min_text_bytes $MIN_TEXT"
  fi
  SKIP=1
  echo "s3 pipeline gate: under min_text on non-gold — N/A (skip=1)"
  ok_report
  exit 0
fi

if [ "${MIN_REAL:-0}" -gt 0 ] && [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
  if is_gold; then
    die "real_funcs ${real} < min_real_funcs ${MIN_REAL}"
  fi
  SKIP=1
  echo "s3 pipeline gate: under min_real on non-gold — N/A (skip=1)"
  ok_report
  exit 0
fi

# Key insn floors (was soft FAIL_ON_REGRESSION=1 only).
func_under=0
require_insns() {
  local name="$1" min="$2"
  local got
  got=$(func_insn_count "$PIPELINE_O" "$name")
  echo "s3 pipeline gate: ${name} insns=${got} (min=${min})"
  if [ "${got:-0}" -lt "$min" ] 2>/dev/null; then
    if is_gold; then
      die "${name} still stub (${got} insns < ${min})"
    fi
    func_under=1
  fi
}

require_insns pipeline_should_skip_x_typeck 8
require_insns resolve_path_probe_dot_x_and_mod 40
require_insns resolve_path_x 40
require_insns path_append_from_buf_256 15
require_insns path_append_from_buf_512 15
require_insns path_append_import_path 15
require_insns resolve_path_import_has_dot 15
require_insns read_file_x 20
require_insns pipeline_load_import_from_disk 80
require_insns pipeline_load_one_import_slot 30
require_insns pipeline_load_and_sync_direct_import_deps 60
require_insns pipeline_sync_dep_slots_from_driver 25
require_insns run_x_pipeline_fill_dep_import_path 25
require_insns pipeline_parse_into_buf 25
require_insns parse_into_with_init_buf 25
require_insns run_x_pipeline_parse_entry_do_parse 25
require_insns run_x_pipeline_parse_entry_if_needed 20
require_insns run_x_pipeline_typecheck_entry 8
require_insns pipeline_typeck_entry_module 8
require_insns typeck_after_parse_ok 8
require_insns pipeline_typeck_parsed_module 8
# info-only (no floor)
echo "s3 pipeline gate: parse_into_with_init insns=$(func_insn_count "$PIPELINE_O" parse_into_with_init) (info)"
echo "s3 pipeline gate: pipeline_parse_set_main_from_buf insns=$(func_insn_count "$PIPELINE_O" pipeline_parse_set_main_from_buf) (info)"
echo "s3 pipeline gate: lsp_diag_parse_entry_buf insns=$(func_insn_count "$PIPELINE_O" lsp_diag_parse_entry_buf) (info)"
require_insns lsp_diag_typeck_after_load 25
require_insns lsp_diag_parse_typeck_buf 8
require_insns run_x_pipeline_impl 60
require_insns run_x_pipeline_codegen_one_dep 40
require_insns run_x_pipeline_codegen_deps 30
require_insns run_x_pipeline_codegen_entry 25

if [ "$func_under" -eq 1 ]; then
  SKIP=1
  echo "s3 pipeline gate: func under on non-gold — N/A (skip=1)"
  ok_report
  exit 0
fi

RUN_OK=1
echo "s3 pipeline gate OK (__text=${sz}, real_funcs=${real})"
ok_report
