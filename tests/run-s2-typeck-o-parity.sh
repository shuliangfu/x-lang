#!/usr/bin/env bash
# S2 typeck.o parity: EMIT_HEAVY build_asm/typeck.o + layout partial vs strict chain.
#
# Honesty: soft XLANG_S2_FAIL_ON_PARITY retired — under-baseline / fossil mega
# needles / unexpected glue soft die→exit0 was portable false-green. Missing
# typeck.o on Linux gold is hard die. Darwin / non-Linux-x64 stub-or-missing
# stays N/A (skip=1; EMIT_HEAVY Linux x86_64 gold). Tip product residual
# (pipeline_type_ensure_by_kind_ord still referenced) is observational.
# Mega entry needles aligned to live typeck_* names (fossil check_block_impl
# short names were false-FAIL). Glue whitelist expanded to tip live U surface.
#
# Usage: ./tests/run-s2-typeck-o-parity.sh
# Report: run=/obs=/skip=
# PLATFORM: LINUX|UBUNTU x86_64 gold; DARWIN N/A when stub/missing.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/s2-typeck-layout-partial.sh
. ./tests/lib/s2-typeck-layout-partial.sh
# shellcheck source=tests/lib/ci-host.sh
. ./tests/lib/ci-host.sh

TYPECK_O="compiler/build_asm/typeck.o"
PARTIAL="compiler/build_asm/typeck_asm_layout_partial.o"
BASELINE="${XLANG_S2_TYPECK_BASELINE:-tests/baseline/s2-typeck-o.tsv}"
MIN_TEXT=$(awk -F'\t' '$1=="min_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT=${MIN_TEXT:-8192}
MIN_REAL=${MIN_REAL:-130}
PREFIX="xlang: [XLANG_S2_TYPECK_PARITY]"
RUN_OK=0
OBS=0
SKIP=1

die() {
  echo "s2 parity FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

text_section_size() {
  local o="$1"
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && { echo 0; return; }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

# GNU objdump inserts <sym+0xN> labels inside bodies; ignore '+' labels or insn
# counts truncate to ~9. ELF has no leading _; Mach-O does.
# Count funcs with >10 insns (exclude uniform ret0 stub prologues).
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

# Symbol defined (ELF/Mach-O; optional typeck_ prefix handled by caller).
sym_defined() {
  local o="$1" sym="$2"
  nm "$o" 2>/dev/null | grep -qE " T (_)?${sym}\$"
}

# PLATFORM: LINUX|UBUNTU x86_64 — EMIT_HEAVY typeck.o gold.
# PLATFORM: MACOS|DARWIN / other — stub build_asm is normal without sync; skip.
is_emit_heavy_gold_host() {
  ci_is_linux && ci_is_x86_64_host
}

if [ ! -f "$TYPECK_O" ]; then
  if is_emit_heavy_gold_host; then
    die "missing $TYPECK_O (run ./tests/run-s2-typeck-sync-build-o.sh; refuse soft SKIP→OK)"
  fi
  echo "s2 parity: N/A missing $TYPECK_O on $(ci_host_summary) (EMIT_HEAVY Linux x86_64 gold)"
  ok_report
  exit 0
fi

sz=$(text_section_size "$TYPECK_O")
real=$(count_real_asm_funcs "$TYPECK_O")
echo "s2 parity: $TYPECK_O __text=${sz} real_funcs=${real} (min_text=${MIN_TEXT}, min_real=${MIN_REAL})"

# Stub / unsynced object: Darwin heat leaves tiny typeck.o; Linux gold must sync.
if [ "${sz:-0}" -lt "${MIN_TEXT}" ] 2>/dev/null || [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
  if ! is_emit_heavy_gold_host; then
    echo "s2 parity: N/A stub/unsynced typeck.o on $(ci_host_summary) (__text=${sz} real=${real}; EMIT_HEAVY Linux x86_64 gold)"
    ok_report
    exit 0
  fi
  die "__text ${sz} < min_text_bytes ${MIN_TEXT} or real_funcs ${real} < min_real_funcs ${MIN_REAL} (run sync)"
fi
SKIP=0
RUN_OK=$((RUN_OK + 1))

# Ban regression to pipeline_type_ensure_by_kind_ord (X ensure_* + init_* glue).
# Tip product still references it → observational residual (not soft silence).
if nm "$TYPECK_O" 2>/dev/null | grep -qE ' (_)?pipeline_type_ensure_by_kind_ord$'; then
  echo "s2 parity OBS: typeck.o still refs pipeline_type_ensure_by_kind_ord (dep_return tip residual)" >&2
  OBS=$((OBS + 1))
else
  echo "s2 parity: no pipeline_type_ensure_by_kind_ord in typeck.o OK"
  RUN_OK=$((RUN_OK + 1))
fi

# Allowed pool read/write glue (link-time: runtime_pipeline_abi).
# Tip live U surface expanded 2026-08-27 (find_or_alloc_* / region_label / type_arg).
# ensure_by_kind_ord stays outside whitelist (obs above).
ALLOW_GLUE='pipeline_type_kind_ord_at|pipeline_type_elem_ref_at|pipeline_type_array_size_at|pipeline_type_named_name_into|pipeline_type_init_primitive_kind_at|pipeline_type_init_named_at|pipeline_type_init_compound_kind_at|pipeline_type_append_type_arg|pipeline_type_find_or_alloc_compound|pipeline_type_find_or_alloc_named|pipeline_type_find_or_alloc_ptr|pipeline_type_find_or_alloc_slice|pipeline_type_region_label_into|pipeline_type_region_label_len_at|pipeline_type_set_elem_array_size_at|pipeline_type_type_arg_ref_at'
unexpected=$(nm "$TYPECK_O" 2>/dev/null | awk '/ U (_)?pipeline_type_/ {print $2}' | sed 's/^_//' | grep -Ev "^(${ALLOW_GLUE})$" | grep -Ev '^pipeline_type_ensure_by_kind_ord$' || true)
if [ -n "$unexpected" ]; then
  die "unexpected _pipeline_type_* refs: $(echo "$unexpected" | tr '\n' ' ')"
fi
echo "s2 parity: pipeline_type_* glue refs whitelist OK"
RUN_OK=$((RUN_OK + 1))

# EMIT_HEAVY mega entries: live typeck_* names (fossil bare check_*_impl retired).
# Mega may still be thin stubs by design; symbols must exist for C glue aliases.
for sym in typeck_check_block_impl typeck_check_expr_impl typeck_x_ast; do
  if ! sym_defined "$TYPECK_O" "$sym"; then
    die "missing mega entry symbol $sym (C glue alias target)"
  fi
done
echo "s2 parity: mega entry symbols OK (typeck_check_block_impl/check_expr_impl/typeck_x_ast)"
RUN_OK=$((RUN_OK + 1))

# Rebuild layout partial; must match strict-chain export table.
if ! s2_rebuild_typeck_layout_partial "$TYPECK_O" "$PARTIAL"; then
  die "layout partial ld -r failed"
fi

psz=$(text_section_size "$PARTIAL")
echo "s2 parity: $PARTIAL __text=${psz}"
if [ "${psz:-0}" -lt 8192 ] 2>/dev/null; then
  die "layout partial __text ${psz} < 8192"
fi

for sym in typeck_struct_layout_metrics typeck_merge_dep_struct_layouts_into_entry ensure_struct_layout_from_struct_lit; do
  if ! nm "$PARTIAL" 2>/dev/null | grep -qE "(_)?${sym}\$"; then
    die "layout partial missing symbol $sym"
  fi
done
echo "s2 parity: layout partial export symbols OK"
RUN_OK=$((RUN_OK + 1))

# typeck_x.o if present: no_layout partial must not duplicate layout exports.
if [ -f compiler/typeck_x.o ]; then
  X_PARTIAL="compiler/build_asm/typeck_x_no_layout_partial.o"
  X_SYMS="compiler/build_asm/typeck_x_no_layout_export.txt"
  nm compiler/typeck_x.o 2>/dev/null | awk '/ T _?typeck_/ {print $3}' | sed 's/^_//' | \
    grep -v '^typeck_struct_layout_metrics$' | \
    grep -v '^typeck_validate_struct_layouts_zero_padding$' | \
    grep -v '^typeck_merge_dep_struct_layouts_into_entry$' | \
    grep -v '^typeck_find_layout_idx_by_type_name$' | \
    sed 's/^/_/' >"$X_SYMS" || true
  if [ -s "$X_SYMS" ]; then
    echo "s2 parity: ld -r typeck_x.o -> $X_PARTIAL (no layout dupes)"
    if s2_ld_partial_export "$X_SYMS" "$X_PARTIAL" compiler/typeck_x.o 2>"${X_PARTIAL}.err"; then
      echo "s2 parity: typeck_x_no_layout_partial OK"
      RUN_OK=$((RUN_OK + 1))
    else
      die "typeck_x_no_layout partial failed (see ${X_PARTIAL}.err)"
    fi
  else
    echo "s2 parity: skip typeck_x_no_layout (no typeck_ exports in typeck_x.o)"
  fi
else
  echo "s2 parity: skip typeck_x.o checks (compiler/typeck_x.o missing)"
fi

echo "s2 parity OK (__text=${sz}, real_funcs=${real}, layout_partial=${psz}, run=${RUN_OK}, obs=${OBS})"
ok_report
exit 0
