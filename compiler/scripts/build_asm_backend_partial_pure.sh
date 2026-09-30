#!/usr/bin/env bash
# build_asm_backend_partial_pure.sh -- the one builder of
# build_asm/seed_host/asm_backend_partial.o (w1540/w1541, checklist 6.3).
#
# One pure-asm emit of src/asm/backend_seed_mega_fallback.x on all three
# hosts. Strong: the four backend_asm_codegen_ast* entries,
# pipeline_seed_mega_ctx_reset, pipeline_dep_ctx_target_arch_local.
# The ten backend_emit_* return-0 stubs are weak on Darwin and Linux (PE has
# no weak; Windows links first-wins, same as the old seed object).
# The real-partial marker every script tests is strong
# backend_asm_codegen_ast_seed_mega (never the file size).
#
# Callers: g05_ensure_relink_prereqs.sh (every g05 generation),
# build_seed_asm_host.sh, gen_g06_phase1_backend_stub.sh.
# No host cc, no -E, no seeds/asm_backend_partial.*.o copy.
# seeds/backend_seed_mega_fallback.from_x.c stays on disk only (9.1).
# Three failed tries exit 1. Up to date (source not newer and anchor present)
# exits 0 without work. XLANG may point at the emitting compiler; otherwise
# pure_asm_x_to_o picks ./xlang, ./xlang_asm, ...
#
# PLATFORM: SHARED. Usage (any cwd): bash scripts/build_asm_backend_partial_pure.sh
set -u
cd "$(dirname "$0")/.." || exit 1
. scripts/pure_ld_shared.sh

_bo=build_asm/seed_host/asm_backend_partial.o
_bx=src/asm/backend_seed_mega_fallback.x
_bw="backend_emit_block_body,backend_emit_block_inits,backend_emit_expr,backend_emit_expr_call,backend_emit_expr_elf,backend_emit_expr_method_call,backend_emit_for_loop,backend_emit_if_then_block_body_text,backend_emit_loop_body_content,backend_emit_while_loop"

# Linux nm: "ADDR T name"; Darwin: "ADDR T _name". Weak polish may stamp W.
bpp_defines() {
  nm -gU "$1" 2>/dev/null | grep -E " [TWtw] (_)?$2\$" >/dev/null
}

[ -f "$_bx" ] || { echo "build_asm_backend_partial_pure: ERROR missing $_bx" >&2; exit 1; }
mkdir -p build_asm/seed_host
if [ -f "$_bo" ] && [ ! "$_bx" -nt "$_bo" ] \
  && bpp_defines "$_bo" backend_seed_mega_fallback_w1540_anchor; then
  exit 0
fi
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT) _bw= ;;
esac
for _try in 1 2 3; do
  rm -f "$_bo.x.tmp.o"
  _ok=0
  if (
    export XLANG_PREFER_ASM_O=1
    unset G05_X_O_WEAK G05_X_O_WEAK_FUNCS G05_X_O_SYM_RENAME XLANG_PREFER_ASM_O_ONLY
    [ -n "$_bw" ] && export G05_X_O_WEAK_FUNCS="$_bw"
    pure_asm_x_to_o "$_bo.x.tmp.o" "$_bx"
  ) && [ -s "$_bo.x.tmp.o" ]; then
    _ok=1
    for _bs in backend_asm_codegen_ast backend_asm_codegen_ast_seed_mega \
      backend_asm_codegen_ast_to_elf backend_asm_codegen_ast_to_elf_seed_mega \
      pipeline_seed_mega_ctx_reset pipeline_dep_ctx_target_arch_local \
      backend_emit_block_body backend_emit_while_loop \
      backend_seed_mega_fallback_w1540_anchor; do
      bpp_defines "$_bo.x.tmp.o" "$_bs" || { _ok=0; break; }
    done
    nm -gU "$_bo.x.tmp.o" 2>/dev/null | grep -qE " T _?backend_asm_codegen_ast_seed_mega\$" || _ok=0
  fi
  if [ "$_ok" = 1 ]; then
    mv -f "$_bo.x.tmp.o" "$_bo"
    echo "g05_ensure: $_bo <- $_bx (w1540 pure asm, whole object, no cc)"
    exit 0
  fi
  printf '%s try=%s build_asm_backend_partial_pure: pure asm %s failed\n' \
    "$(date +%H:%M:%S)" "$_try" "$_bx" >>build_asm/g05_xasm_crash.log 2>/dev/null || true
done
rm -f "$_bo.x.tmp.o" "$_bo"
echo "$(uname -s) $_bx" >>build_asm/g05_cc_fallback.log 2>/dev/null || true
echo "build_asm_backend_partial_pure: ERROR $_bx pure asm failed 3x; no cc fallback" >&2
exit 1
