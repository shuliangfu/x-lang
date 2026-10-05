#!/usr/bin/env bash
# bootstrap_stage123_v2v3.sh — stage1..stage3 in one command, then v2 == v3.
#
# Item 8.2 (analysis/终局待办.md): run stage1 to stage3 automatically and
# compare v2 with v3.
#
#   v1 (start)  = compiler/xlang_asm as found when this script starts
#   stage1      = v1 rebuilds every compiler object from .x and relinks -> g1
#   stage2 (v2) = g1 rebuilds every object again and relinks          -> g2
#   stage3 (v3) = g2 rebuilds every object again and relinks          -> g3
#   gate        = stripped g2 and stripped g3 are byte-identical
#
# Each stage touches every compiler .x so the normal ensure path recompiles
# them with the compiler that is installed at that moment, then relinks
# xlang_asm. Nothing is compiled by hand here and no cc is invoked by this
# script; ensure and relink keep their own rules (no new host-cc .c, no
# FORCE, no full runtime_pipeline_abi rebuild).
#
# runtime_pipeline_abi.o: rebuilding the whole object is banned, so the
# copy present at start is saved and put back before every stage. Its .x
# helpers are still recompiled each stage through the thin layers.
#
# Usage (any cwd):
#   bash compiler/scripts/bootstrap_stage123_v2v3.sh [OUT_DIR]
# Env:
#   XLANG_V2V3_OUT          output dir (default /tmp/xlang_v2v3)
#   XLANG_V2V3_ENSURE_TO    ensure timeout seconds per stage (default 5400)
#   XLANG_V2V3_RELINK_TO    relink timeout seconds per stage (default 900)
#   XLANG_V2V3_TRACE=1      item 8.3: Linux records every execve of ensure and
#                           relink with strace -f; any C compiler basename
#                           (cc, gcc, clang, cc1, ...) fails the run (exit 5)
#                           after all three stages; calls go to g*.cc.txt
#
# Output: OUT_DIR/g{1,2,3}.xa (+ .s stripped), g*_ensure.log, g*_relink.log,
#         OUT_DIR/v2v3.txt summary. Last line is V2V3 OK or V2V3 FAIL <why>.
# Exit:   0 v2 == v3; 2 setup; 3 ensure/relink/stale stage; 4 v2 != v3;
#         5 a C compiler was executed (XLANG_V2V3_TRACE=1 only).
#
# PLATFORM: Linux gold gate today. Darwin uses the same ensure/relink
#   scripts; Windows is not covered here.
# wave2058: new.

set -u
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
C="$ROOT/compiler"
OUT="${1:-${XLANG_V2V3_OUT:-/tmp/xlang_v2v3}}"
ETO="${XLANG_V2V3_ENSURE_TO:-5400}"
RTO="${XLANG_V2V3_RELINK_TO:-900}"
PABI="$C/src/runtime_pipeline_abi.o"
TRACE="${XLANG_V2V3_TRACE:-0}"
# Same compiler basename rule as check_default_no_host_cc.sh.
ccre='^(cc|c89|c99|gcc|g\+\+|c\+\+|clang|clang\+\+|cpp|tcc|cc1|cc1plus|cl|[A-Za-z0-9_.-]*-(gcc|g\+\+|cc|clang|clang\+\+))(-[0-9.]+)?(\.exe)?$'

mkdir -p "$OUT" || exit 2
S="$OUT/v2v3.txt"
: > "$S"
say() { echo "$*" | tee -a "$S"; }
die() { say "V2V3 FAIL $2"; exit "$1"; }

hsum() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -c1-16
  else shasum -a 256 "$1" | cut -c1-16; fi
}
strip_to() {
  # $1 in, $2 out: drop symbol tables so only code/data are compared.
  rm -f "$2"
  # w2060: Darwin strip re-signs ad hoc with the output file name as the
  # code-signature Identifier (g2.xa.s vs g3.xa.s), so identical binaries
  # compared unequal. Strip under one fixed base name, then move.
  if [ "$(uname -s)" = Darwin ]; then
    _st_dir="$(dirname "$2")/.strip_tmp"
    rm -rf "$_st_dir" && mkdir -p "$_st_dir" \
      && cp "$1" "$_st_dir/xlang_asm" && strip -S -x "$_st_dir/xlang_asm" 2>/dev/null \
      && mv "$_st_dir/xlang_asm" "$2"
    rm -rf "$_st_dir"
  else strip -o "$2" "$1" 2>/dev/null; fi
  [ -s "$2" ] || cp "$1" "$2"
}

cd "$C" || exit 2
TR=; ALLHIT=
if [ "$TRACE" = 1 ]; then
  [ "$(uname -s)" = Linux ] || die 2 "XLANG_V2V3_TRACE=1 is Linux only (strace)"
  command -v strace >/dev/null 2>&1 || die 2 "strace not installed"
  TR="strace -f -qq -e trace=execve -o"
fi
# $1 trace file: print C compiler basenames that were executed, comma list.
cc_hits() {
  grep -oE 'execve\("[^"]+"' "$1" | sed 's/^execve("//; s/"$//' | sort -u |
    while read -r p; do b=${p##*/}; echo "$b" | grep -qE "$ccre" && echo "$b"; done |
    sort -u | tr '\n' ','
}
[ -x xlang_asm ] || die 2 "no compiler/xlang_asm (v1)"
[ -f "$PABI" ] || die 2 "no src/runtime_pipeline_abi.o"
cp -p "$PABI" "$OUT/pabi_start.o" || die 2 "cannot save runtime_pipeline_abi.o"
cp -p xlang_asm "$OUT/v1.xa"
say "v1 $(wc -c < xlang_asm | tr -d ' ') $(hsum xlang_asm) head=$(git -C "$ROOT" rev-parse --short=9 HEAD 2>/dev/null)"

for g in 1 2 3; do
  cp -p "$OUT/pabi_start.o" "$PABI"
  touch "$OUT/g${g}_marker"; sleep 1
  find src -name "*.x" ! -name "*wpo_thin*" -exec touch {} +
  for f in typeck_gen.c ast_asm_bare_link_alias.x backend_asm_bare_link_alias.x \
           backend_asm_strict_fallback_alias.x pipeline_bootstrap_orchestration.x \
           typeck_c_module_stubs.x x_frontend_link_alias.x; do
    [ -f "$f" ] && touch "$f"
  done
  rm -f build_asm/seed_host/asm_full_link_stubs.o build_asm/seed_host/asm_full_link_stubs.x \
        build_asm/seed_host/asm_full_link_stubs.x.syms build_asm/g05_xasm_crash.log
  timeout "$ETO" ${TR:+$TR "$OUT/g${g}_ensure.tr"} sh scripts/g05_ensure_relink_prereqs.sh > "$OUT/g${g}_ensure.log" 2>&1
  erc=$?
  [ "$erc" = 0 ] || die 3 "g$g ensure rc=$erc"
  if [ -s build_asm/g05_xasm_crash.log ]; then die 3 "g$g compiler crash log not empty"; fi
  timeout "$RTO" ${TR:+$TR "$OUT/g${g}_relink.tr"} bash -c 'set -a; eval "$(sh scripts/g05_relink_env.sh 2>/dev/null)"; set +a; sh scripts/g05_relink_xlang.sh' \
    > "$OUT/g${g}_relink.log" 2>&1
  rrc=$?
  [ "$rrc" = 0 ] || die 3 "g$g relink rc=$rrc"
  [ xlang_asm -nt "$OUT/g${g}_marker" ] || die 3 "g$g xlang_asm not relinked (stale)"
  if [ -n "$TR" ]; then
    nex=$(cat "$OUT/g${g}_ensure.tr" "$OUT/g${g}_relink.tr" | grep -c 'execve(')
    hit=$(cat "$OUT/g${g}_ensure.tr" "$OUT/g${g}_relink.tr" > "$OUT/g${g}.tr" && cc_hits "$OUT/g${g}.tr")
    say "g$g execve=$nex cc=${hit:-none}"
    if [ -n "$hit" ]; then
      ALLHIT="$ALLHIT g$g:$hit"
      grep -E 'execve\("[^"]*/(cc|gcc|clang|cc1|c\+\+|g\+\+|[A-Za-z0-9_.-]*-gcc)(-[0-9.]+)?"' "$OUT/g${g}.tr" > "$OUT/g${g}.cc.txt"
    fi
  fi
  nnew=$(find . -name '*.o' -newer "$OUT/g${g}_marker" | wc -l | tr -d ' ')
  cp -p xlang_asm "$OUT/g${g}.xa"
  strip_to "$OUT/g${g}.xa" "$OUT/g${g}.xa.s"
  say "g$g fresh $(wc -c < xlang_asm | tr -d ' ') $(hsum xlang_asm) strip $(hsum "$OUT/g${g}.xa.s") new_o=$nnew"
done

cp -p "$OUT/pabi_start.o" "$PABI"
if cmp -s "$OUT/g1.xa.s" "$OUT/g2.xa.s"; then say "info stage1 == v2"; else say "info stage1 != v2 (expected when v1 is older)"; fi
cmp -s "$OUT/g2.xa.s" "$OUT/g3.xa.s" || die 4 "v2 != v3"
[ -z "$ALLHIT" ] || die 5 "C compiler executed:$ALLHIT (see g*.cc.txt)"
say "V2V3 OK"
exit 0
