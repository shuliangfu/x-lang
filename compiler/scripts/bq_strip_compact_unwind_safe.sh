#!/usr/bin/env bash
# Class BQ／BS／BT: strip __compact_unwind on Darwin tip-linked objs (BS n_sect remap).
# Ban: parser_asm_thin_glue.o only.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PY=scripts/pabi_strip_macho_compact_unwind.py
for o in \
  src/seed_link_compat.o \
  src/runtime_driver_diagnostic.o \
  src/asm/backend_try_inline_dispatch.o \
  src/asm/backend_call_dispatch.o \
  src/asm/backend_enc_dispatch.o \
  src/diag.o \
  src/runtime_driver_strict_glue_stubs.o \
  src/asm/simd_enc.o \
  src/asm/backend_arm64_enc_c.o \
  src/asm/simd_loop.o \
  src/asm/backend_arch_emit_dispatch.o \
  src/driver/fmt_check_cmd_driver.o \
  src/runtime/rt_preamble.o \
  src/lsp/lsp_diag.o
do
  if [[ -f "$o" ]]; then
    python3 "$PY" "$o" -o "$o" || true
  else
    echo "skip missing $o" >&2
  fi
done
