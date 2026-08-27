#!/usr/bin/env bash
# Sync EMIT_HEAVY + WPO driver_compile*.o into compiler/build_asm/.
#
# Honesty: soft XLANG_S3_FAIL_ON_EMIT_HEAVY retired. Size floors live in
# run-s3-driver-emit-heavy.sh (Linux gold hard; Darwin skip). Emit skip
# propagates here (no false-green write). WPO fallback to emit_heavy copy
# is observational when WPO compress fails.
#
# Usage: ./tests/run-s3-driver-sync-build-o.sh
# Report: run=/obs=/skip=
# PLATFORM: LINUX|UBUNTU x86_64 gold; DARWIN N/A when emit-heavy skips.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. ./tests/lib/ci-host.sh

DEST="compiler/build_asm/driver_compile.o"
DEST_EH="compiler/build_asm/driver_compile_emit_heavy.o"
BASELINE="${XLANG_S3_DRIVER_EMIT_BASELINE:-tests/baseline/s3-driver-o.tsv}"
MIN_TEXT_EH=$(awk -F'\t' '$1=="min_text_emit_heavy" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT_EH=${MIN_TEXT_EH:-256}

PREFIX="xlang: [XLANG_S3_DRIVER_SYNC_BUILD_O]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "s3 driver sync-build-o FAIL: $*" >&2
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

# ── 1) EMIT_HEAVY full body ──
emit_heavy_ok=0
# Returns 0=ok, 1=fail, 2=skip N/A. Keep set +e for non-zero return (bash set -e exits).
try_emit() {
  local cand="$1" log=/tmp/xlang_s3_driver_eh_try.log rc
  [ -x "$cand" ] || return 1
  set +e
  XLANG_S3_EMIT_HEAVY_COMPILER="$cand" ./tests/run-s3-driver-emit-heavy.sh >"$log" 2>&1
  rc=$?
  cat "$log"
  if grep -qE 'skip=1' "$log"; then
    return 2
  fi
  # tip EMIT_HEAVY product residual (obs=) — treat like skip for sync write
  if grep -qE 'obs=[1-9]' "$log"; then
    return 2
  fi
  if [ "$rc" -eq 0 ]; then
    return 0
  fi
  return 1
}

if [ -n "${XLANG_S3_EMIT_HEAVY_COMPILER:-}" ] && [ -x "${XLANG_S3_EMIT_HEAVY_COMPILER}" ]; then
  set +e
  try_emit "${XLANG_S3_EMIT_HEAVY_COMPILER}"
  trc=$?
  set -e
  if [ "$trc" -eq 0 ]; then
    emit_heavy_ok=1
  elif [ "$trc" -eq 2 ]; then
    SKIP=1
    echo "s3 driver sync-build-o: emit-heavy N/A — skip write"
    ok_report
    exit 0
  fi
fi
if [ "$emit_heavy_ok" -eq 0 ]; then
  for cand in ./compiler/xlang_asm ./compiler/xlang_asm.strict_glue ./compiler/xlang_asm.experimental; do
    [ -x "$cand" ] || continue
    echo "s3 driver sync-build-o: trying emit-heavy with $cand ..."
    set +e
    try_emit "$cand"
    trc=$?
    set -e
    if [ "$trc" -eq 0 ]; then
      export XLANG_S3_EMIT_HEAVY_COMPILER="$cand"
      emit_heavy_ok=1
      break
    elif [ "$trc" -eq 2 ]; then
      SKIP=1
      echo "s3 driver sync-build-o: emit-heavy N/A — skip write"
      ok_report
      exit 0
    fi
  done
fi
if [ "$emit_heavy_ok" -eq 0 ]; then
  die "emit-heavy failed (all compilers)"
fi

SRC="/tmp/xlang_s3_driver_emit_heavy.o"
[ -f "$SRC" ] || die "missing $SRC"

mkdir -p "$(dirname "$DEST")"
cp -f "$SRC" "$DEST_EH"
eh_sz=$(text_section_size "$DEST_EH")
echo "s3 driver sync-build-o: wrote $DEST_EH __text=${eh_sz} (min_text_emit_heavy=${MIN_TEXT_EH})"

if ! awk -v s="$eh_sz" -v m="$MIN_TEXT_EH" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
  if ci_is_linux_x64; then
    die "emit_heavy __text ${eh_sz} < min_text_emit_heavy ${MIN_TEXT_EH}"
  fi
  SKIP=1
  echo "s3 driver sync-build-o: under on non-gold — N/A (skip=1)"
  ok_report
  exit 0
fi

# ── 2) WPO compressed driver_compile.o (dogfood; fallback = emit_heavy copy) ──
WPO_OK=0
COMP="${XLANG_S3_EMIT_HEAVY_COMPILER:-./compiler/xlang_asm}"
LIBROOT="-L compiler/asm_libroot -L compiler/.. -L compiler/src -L compiler/src/lexer -L compiler/src/ast -L compiler/src/parser -L compiler/src/typeck -L compiler/src/codegen -L compiler/src/preprocess -L compiler/src/pipeline -L compiler/src/lsp -L compiler/src/asm"
WPO_TMP="/tmp/xlang_s3_driver_wpo.o"
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
if [ -x "$COMP" ]; then
  rm -f "$WPO_TMP" 2>/dev/null || true
  if env -u XLANG_ASM_START_FUNC XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_ASM_ENTRY_EMIT_HEAVY=1 \
    XLANG_ASM_WPO_DCE=1 \
    "$COMP" -backend asm -o "$WPO_TMP" $LIBROOT compiler/src/driver/compile.x 2>/dev/null; then
    wpo_sz=$(text_section_size "$WPO_TMP")
    if [ "$wpo_sz" -gt 0 ] && [ "$wpo_sz" -le 768 ] 2>/dev/null && \
       nm "$WPO_TMP" 2>/dev/null | grep -qE ' T (_)?(compile_dispatch_asm_backend|run_compiler_full_x|entry)$'; then
      cp -f "$WPO_TMP" "$DEST"
      echo "s3 driver sync-build-o: wrote $DEST __text=${wpo_sz} (WPO entry-only)"
      WPO_OK=1
    fi
  fi
fi
if [ "$WPO_OK" -eq 0 ]; then
  cp -f "$DEST_EH" "$DEST"
  OBS=$((OBS + 1))
  echo "s3 driver sync-build-o: WPO fallback — $DEST = emit_heavy copy (__text=${eh_sz}) obs=1"
fi

# ── 3) pure_ld_partial_merge: emit_heavy + link_alias → driver_compile_link.o ──
# G.7: same authority as build_xlang_asm ensure_driver_compile_link_obj.
# PLATFORM: MACOS — F7 two LC_SEGMENT → libtool ar; LINUX — ET_REL.
LINK_ALIAS_INC="compiler/seeds/driver_compile_asm_link_alias.from_x.c"
LINK_ALIAS_O="compiler/build_asm/driver_compile_asm_link_alias.o"
LINK_O="compiler/build_asm/driver_compile_link.o"
# shellcheck source=compiler/scripts/pure_ld_shared.sh
. compiler/scripts/pure_ld_shared.sh
if [ -f "$LINK_ALIAS_INC" ]; then
  ( cd compiler && sh scripts/cc_inc_tu.sh seeds/driver_compile_asm_link_alias.from_x.c build_asm/driver_compile_asm_link_alias.o )
  rm -f "$LINK_O" 2>/dev/null || true
  pure_ld_partial_merge "$LINK_O" "$DEST_EH" "$LINK_ALIAS_O"
  if nm -g "$LINK_O" 2>/dev/null | grep -qE '(_)?driver_run_compiler_full_x'; then
    echo "s3 driver sync-build-o: wrote $LINK_O (driver_run_compiler_full_x alias OK)"
  else
    if ci_is_linux_x64; then
      die "$LINK_O missing driver_run_compiler_full_x"
    fi
    OBS=$((OBS + 1))
    echo "s3 driver sync-build-o: obs — $LINK_O missing driver_run_compiler_full_x"
  fi
fi

RUN_OK=1
echo "s3 driver sync-build-o OK ($DEST wpo=${WPO_OK}; $DEST_EH __text=${eh_sz})"
ok_report
