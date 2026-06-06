#!/usr/bin/env bash
# S3 pipeline SU 门禁：pipeline.su check + build_asm/pipeline.o __text / safe_helper 真 emit。
# 用法：./tests/run-s3-pipeline-gate.sh
# 可选：SHU_S3_REQUIRE_PIPELINE_O=1 — 无 pipeline.o 时失败
# 可选：SHU_S3_FAIL_ON_REGRESSION=1 — 低于 baseline 时失败
# 可选：SHU_S3_UPDATE_BASELINE=1 — 更新 tests/baseline/s3-pipeline-o.tsv
set -e
cd "$(dirname "$0")/.."
make -C compiler shu-c -q 2>/dev/null || make -C compiler shu-c

SHU=${SHU:-./compiler/shu-c}
PIPELINE_SU="compiler/src/pipeline/pipeline.su"
PIPELINE_O="compiler/build_asm/pipeline.o"
BASELINE="${SHU_S3_PIPELINE_BASELINE:-tests/baseline/s3-pipeline-o.tsv}"
# 已删 TU 的 stale .o 会与 build_asm/pipeline.o 重复符号（strict relink）
rm -f compiler/build_asm/pipeline_bootstrap_link_alias.o 2>/dev/null || true
MIN_TEXT=$(awk -F'\t' '$1=="min_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT=${MIN_TEXT:-512}
MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=${MIN_REAL:-0}

count_real_asm_funcs() {
  python3 - "$1" <<'PY'
import subprocess, re, sys
path = sys.argv[1]
try:
    text = subprocess.check_output(["objdump", "-d", path], text=True, stderr=subprocess.DEVNULL)
except subprocess.CalledProcessError:
    print(0)
    sys.exit(0)
real = 0
for m in re.finditer(r"^[0-9a-f]+ <(_[^>]+)>:\n((?:.*\n)*?)(?=\n[0-9a-f]+ <_|\Z)", text, re.M):
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
m = re.search(rf"^[0-9a-f]+ <_{re.escape(name)}>:\n((?:.*\n)*?)(?=^[0-9a-f]+ <_|\Z)", text, re.M)
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

# ── 1) pipeline.su check ──
out=$("$SHU" check "$PIPELINE_SU" 2>&1) || {
  echo "$out"
  echo "s3 pipeline gate: check failed on $PIPELINE_SU"
  exit 1
}
if [ -n "$out" ]; then
  echo "s3 pipeline gate: expected silent check on $PIPELINE_SU, got: $out"
  exit 1
fi

if [ ! -f "$PIPELINE_O" ]; then
  if [ "${SHU_S3_REQUIRE_PIPELINE_O:-0}" = "1" ]; then
    echo "s3 pipeline gate: missing $PIPELINE_O (run ./tests/run-s3-pipeline-sync-build-o.sh)" >&2
    exit 1
  fi
  echo "s3 pipeline gate OK (check only; $PIPELINE_O missing)"
  exit 0
fi

sz=$(text_section_size "$PIPELINE_O")
real=$(count_real_asm_funcs "$PIPELINE_O")
echo "s3 pipeline gate: $PIPELINE_O __text=${sz} real_funcs=${real} (min_text=${MIN_TEXT}, min_real=${MIN_REAL})"

if [ "${SHU_S3_UPDATE_BASELINE:-0}" = "1" ]; then
  {
    echo "# S3 pipeline.o：build_asm/pipeline.su 的 asm 产物 baseline"
    echo "# 更新：SHU_S3_UPDATE_BASELINE=1 ./tests/run-s3-pipeline-gate.sh"
    printf 'min_text_bytes\t%s\n' "$sz"
    printf 'min_real_funcs\t%s\n' "$real"
    echo "min_text_emit_heavy	512"
  } >"$BASELINE"
  echo "s3 pipeline gate: updated baseline min_text_bytes=$sz min_real_funcs=$real"
fi

if [ "${sz:-0}" -eq 0 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: empty __text in $PIPELINE_O" >&2
  exit 1
fi

if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] || [ "${SHU_S3_REQUIRE_PIPELINE_O:-0}" = "1" ]; then
  if ! awk -v s="$sz" -v m="$MIN_TEXT" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
    echo "s3 pipeline gate FAIL: __text $sz < min_text_bytes $MIN_TEXT" >&2
    exit 1
  fi
  if [ "${MIN_REAL:-0}" -gt 0 ] && [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
    echo "s3 pipeline gate FAIL: real_funcs ${real} < min_real_funcs ${MIN_REAL}" >&2
    exit 1
  fi
fi

# S3 起步：pipeline_should_skip_su_typeck 须 SU 真 emit（非 7-insn ret0 桩）
skip_insns=$(func_insn_count "$PIPELINE_O" "pipeline_should_skip_su_typeck")
echo "s3 pipeline gate: pipeline_should_skip_su_typeck insns=${skip_insns} (min=15)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${skip_insns:-0}" -lt 15 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: pipeline_should_skip_su_typeck still stub (${skip_insns} insns)" >&2
  exit 1
fi

# S3 起步：resolve_path 探测链须 SU 真 emit（非 ret0 桩）
probe_insns=$(func_insn_count "$PIPELINE_O" "resolve_path_probe_dot_su_and_mod")
echo "s3 pipeline gate: resolve_path_probe_dot_su_and_mod insns=${probe_insns} (min=40)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${probe_insns:-0}" -lt 40 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: resolve_path_probe still stub (${probe_insns} insns)" >&2
  exit 1
fi

resolve_insns=$(func_insn_count "$PIPELINE_O" "resolve_path_su")
echo "s3 pipeline gate: resolve_path_su insns=${resolve_insns} (min=40)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${resolve_insns:-0}" -lt 40 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: resolve_path_su still stub (${resolve_insns} insns)" >&2
  exit 1
fi

path256_insns=$(func_insn_count "$PIPELINE_O" "path_append_from_buf_256")
echo "s3 pipeline gate: path_append_from_buf_256 insns=${path256_insns} (min=15)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${path256_insns:-0}" -lt 15 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: path_append_from_buf_256 still stub (${path256_insns} insns)" >&2
  exit 1
fi

path512_insns=$(func_insn_count "$PIPELINE_O" "path_append_from_buf_512")
echo "s3 pipeline gate: path_append_from_buf_512 insns=${path512_insns} (min=15)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${path512_insns:-0}" -lt 15 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: path_append_from_buf_512 still stub (${path512_insns} insns)" >&2
  exit 1
fi

path_import_insns=$(func_insn_count "$PIPELINE_O" "path_append_import_path")
echo "s3 pipeline gate: path_append_import_path insns=${path_import_insns} (min=15)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${path_import_insns:-0}" -lt 15 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: path_append_import_path still stub (${path_import_insns} insns)" >&2
  exit 1
fi

has_dot_insns=$(func_insn_count "$PIPELINE_O" "resolve_path_import_has_dot")
echo "s3 pipeline gate: resolve_path_import_has_dot insns=${has_dot_insns} (min=15)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${has_dot_insns:-0}" -lt 15 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: resolve_path_import_has_dot still stub (${has_dot_insns} insns)" >&2
  exit 1
fi

read_insns=$(func_insn_count "$PIPELINE_O" "read_file_su")
echo "s3 pipeline gate: read_file_su insns=${read_insns} (min=20)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${read_insns:-0}" -lt 20 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: read_file_su still stub (${read_insns} insns)" >&2
  exit 1
fi

load_insns=$(func_insn_count "$PIPELINE_O" "pipeline_load_import_from_disk")
echo "s3 pipeline gate: pipeline_load_import_from_disk insns=${load_insns} (min=80)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${load_insns:-0}" -lt 80 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: pipeline_load_import_from_disk still stub (${load_insns} insns)" >&2
  exit 1
fi

load_one_insns=$(func_insn_count "$PIPELINE_O" "pipeline_load_one_import_slot")
echo "s3 pipeline gate: pipeline_load_one_import_slot insns=${load_one_insns} (min=30)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${load_one_insns:-0}" -lt 30 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: pipeline_load_one_import_slot still stub (${load_one_insns} insns)" >&2
  exit 1
fi

load_sync_insns=$(func_insn_count "$PIPELINE_O" "pipeline_load_and_sync_direct_import_deps")
echo "s3 pipeline gate: pipeline_load_and_sync_direct_import_deps insns=${load_sync_insns} (min=60)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${load_sync_insns:-0}" -lt 60 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: pipeline_load_and_sync_direct_import_deps still stub (${load_sync_insns} insns)" >&2
  exit 1
fi

sync_slots_insns=$(func_insn_count "$PIPELINE_O" "pipeline_sync_dep_slots_from_driver")
echo "s3 pipeline gate: pipeline_sync_dep_slots_from_driver insns=${sync_slots_insns} (min=25)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${sync_slots_insns:-0}" -lt 25 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: pipeline_sync_dep_slots_from_driver still stub (${sync_slots_insns} insns)" >&2
  exit 1
fi

fill_path_insns=$(func_insn_count "$PIPELINE_O" "run_su_pipeline_fill_dep_import_path")
echo "s3 pipeline gate: run_su_pipeline_fill_dep_import_path insns=${fill_path_insns} (min=25)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${fill_path_insns:-0}" -lt 25 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: run_su_pipeline_fill_dep_import_path still stub (${fill_path_insns} insns)" >&2
  exit 1
fi

parse_buf_insns=$(func_insn_count "$PIPELINE_O" "pipeline_parse_into_buf")
echo "s3 pipeline gate: pipeline_parse_into_buf insns=${parse_buf_insns} (min=25)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${parse_buf_insns:-0}" -lt 25 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: pipeline_parse_into_buf still stub (${parse_buf_insns} insns)" >&2
  exit 1
fi

parse_init_buf_insns=$(func_insn_count "$PIPELINE_O" "parse_into_with_init_buf")
echo "s3 pipeline gate: parse_into_with_init_buf insns=${parse_init_buf_insns} (min=25)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${parse_init_buf_insns:-0}" -lt 25 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: parse_into_with_init_buf still stub (${parse_init_buf_insns} insns)" >&2
  exit 1
fi

parse_entry_insns=$(func_insn_count "$PIPELINE_O" "run_su_pipeline_parse_entry_if_needed")
echo "s3 pipeline gate: run_su_pipeline_parse_entry_if_needed insns=${parse_entry_insns} (min=20)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${parse_entry_insns:-0}" -lt 20 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: run_su_pipeline_parse_entry_if_needed still stub (${parse_entry_insns} insns)" >&2
  exit 1
fi

typecheck_entry_insns=$(func_insn_count "$PIPELINE_O" "run_su_pipeline_typecheck_entry")
echo "s3 pipeline gate: run_su_pipeline_typecheck_entry insns=${typecheck_entry_insns} (min=10; thin→typecheck_entry_emit_c)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${typecheck_entry_insns:-0}" -lt 10 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: run_su_pipeline_typecheck_entry still stub (${typecheck_entry_insns} insns)" >&2
  exit 1
fi

typeck_entry_mod_insns=$(func_insn_count "$PIPELINE_O" "pipeline_typeck_entry_module")
echo "s3 pipeline gate: pipeline_typeck_entry_module insns=${typeck_entry_mod_insns} (min=10; thin→typeck_entry_module_c)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${typeck_entry_mod_insns:-0}" -lt 10 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: pipeline_typeck_entry_module still stub (${typeck_entry_mod_insns} insns)" >&2
  exit 1
fi

typeck_after_insns=$(func_insn_count "$PIPELINE_O" "typeck_after_parse_ok")
echo "s3 pipeline gate: typeck_after_parse_ok insns=${typeck_after_insns} (min=10; thin→pipeline_typeck_after_parse_ok_c)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${typeck_after_insns:-0}" -lt 10 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: typeck_after_parse_ok still stub (${typeck_after_insns} insns)" >&2
  exit 1
fi

typeck_parsed_insns=$(func_insn_count "$PIPELINE_O" "pipeline_typeck_parsed_module")
echo "s3 pipeline gate: pipeline_typeck_parsed_module insns=${typeck_parsed_insns} (min=10; thin→typeck_parsed_module_c)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${typeck_parsed_insns:-0}" -lt 10 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: pipeline_typeck_parsed_module still stub (${typeck_parsed_insns} insns)" >&2
  exit 1
fi

parse_init_insns=$(func_insn_count "$PIPELINE_O" "parse_into_with_init")
echo "s3 pipeline gate: parse_into_with_init insns=${parse_init_insns} (info; thin_delegate→parse_into_with_init_c)"

parse_set_main_insns=$(func_insn_count "$PIPELINE_O" "pipeline_parse_set_main_from_buf")
echo "s3 pipeline gate: pipeline_parse_set_main_from_buf insns=${parse_set_main_insns} (info; entry 经 do_parse_c)"

parse_entry_do_insns=$(func_insn_count "$PIPELINE_O" "run_su_pipeline_parse_entry_do_parse")
echo "s3 pipeline gate: run_su_pipeline_parse_entry_do_parse insns=${parse_entry_do_insns} (info; if_needed→do_parse_c)"

lsp_parse_entry_insns=$(func_insn_count "$PIPELINE_O" "lsp_diag_parse_entry_buf")
echo "s3 pipeline gate: lsp_diag_parse_entry_buf insns=${lsp_parse_entry_insns} (info; LSP 经 do_parse_c 路径)"

lsp_typeck_load_insns=$(func_insn_count "$PIPELINE_O" "lsp_diag_typeck_after_load")
echo "s3 pipeline gate: lsp_diag_typeck_after_load insns=${lsp_typeck_load_insns} (min=25)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${lsp_typeck_load_insns:-0}" -lt 25 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: lsp_diag_typeck_after_load still stub (${lsp_typeck_load_insns} insns)" >&2
  exit 1
fi

lsp_diag_insns=$(func_insn_count "$PIPELINE_O" "lsp_diag_parse_typeck_buf")
echo "s3 pipeline gate: lsp_diag_parse_typeck_buf insns=${lsp_diag_insns} (min=10; thin→lsp_diag_parse_typeck_buf_c)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${lsp_diag_insns:-0}" -lt 10 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: lsp_diag_parse_typeck_buf still stub (${lsp_diag_insns} insns)" >&2
  exit 1
fi

impl_insns=$(func_insn_count "$PIPELINE_O" "run_su_pipeline_impl")
echo "s3 pipeline gate: run_su_pipeline_impl insns=${impl_insns} (min=60)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${impl_insns:-0}" -lt 60 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: run_su_pipeline_impl still stub (${impl_insns} insns)" >&2
  exit 1
fi

codegen_one_insns=$(func_insn_count "$PIPELINE_O" "run_su_pipeline_codegen_one_dep")
echo "s3 pipeline gate: run_su_pipeline_codegen_one_dep insns=${codegen_one_insns} (min=40)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${codegen_one_insns:-0}" -lt 40 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: run_su_pipeline_codegen_one_dep still stub (${codegen_one_insns} insns)" >&2
  exit 1
fi

codegen_deps_insns=$(func_insn_count "$PIPELINE_O" "run_su_pipeline_codegen_deps")
echo "s3 pipeline gate: run_su_pipeline_codegen_deps insns=${codegen_deps_insns} (min=30)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${codegen_deps_insns:-0}" -lt 30 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: run_su_pipeline_codegen_deps still stub (${codegen_deps_insns} insns)" >&2
  exit 1
fi

codegen_entry_insns=$(func_insn_count "$PIPELINE_O" "run_su_pipeline_codegen_entry")
echo "s3 pipeline gate: run_su_pipeline_codegen_entry insns=${codegen_entry_insns} (min=25)"
if [ "${SHU_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${codegen_entry_insns:-0}" -lt 25 ] 2>/dev/null; then
  echo "s3 pipeline gate FAIL: run_su_pipeline_codegen_entry still stub (${codegen_entry_insns} insns)" >&2
  exit 1
fi

echo "s3 pipeline gate OK (__text=${sz}, real_funcs=${real})"
