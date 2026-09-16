#!/usr/bin/env bash
# B-30：runtime OS 调用盘点门禁（manifest + 关键符号存在）。
#
# 用法：./tests/run-b30-stubs-runtime-os-inventory-gate.sh
# wave honesty (2026-08-24 #4): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# monofile seeds/runtime.from_x.c retired wave321 — live IO/link ABI faces:
#   runtime_read_file_view / xlang_write_path_bytes / link_abi_generated_c_contains_any_substr
# Override: XLANG_B30_RT="f1 f2…", XLANG_B30_DOC=…
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

MANIFEST="${XLANG_B30_MANIFEST:-tests/baseline/b30-os-inventory.tsv}"
DOC="${XLANG_B30_DOC:-analysis/archive/phase/phase-b-completion-v1.md}"
# Live authorities after monofile retire (wave321) + link_abi face rename.
RT="${XLANG_B30_RT:-compiler/seeds/runtime_io_abi.from_x.c compiler/seeds/runtime_link_abi.from_x.c}"
CHECKLIST="${XLANG_B30_CHECKLIST:-compiler/docs/完全去掉C与H-前置清单.md}"

b30_any_file_has() {
  local needle="$1"
  local f
  for f in $RT; do
    if grep -qF "$needle" "$f" 2>/dev/null; then
      return 0
    fi
  done
  return 1
}

echo "=== B-30: stubs/runtime OS inventory ==="
for f in "$MANIFEST" "$DOC" "$CHECKLIST"; do
  [ -f "$f" ] || { echo "b30 gate FAIL: missing $f" >&2; exit 1; }
done
for f in $RT; do
  [ -f "$f" ] || { echo "b30 gate FAIL: missing live seed $f" >&2; exit 1; }
done
b30_any_file_has 'runtime_read_file_view' || b30_any_file_has 'xlang_read_file_into_path' || {
  echo "b30 gate FAIL: live io_abi missing read_file face (runtime_read_file_view / xlang_read_file_into_path)" >&2
  exit 1
}
b30_any_file_has 'xlang_write_path_bytes' || {
  echo "b30 gate FAIL: live io_abi missing write face (xlang_write_path_bytes)" >&2
  exit 1
}
b30_any_file_has 'link_abi_generated_c_contains_any_substr' || {
  echo "b30 gate FAIL: live link_abi missing generated_c scan face" >&2
  exit 1
}
echo "b30 inventory OK"
