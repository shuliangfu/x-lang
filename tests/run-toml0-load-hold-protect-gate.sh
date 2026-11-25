#!/usr/bin/env bash
# toml0 load runtime HOLD protect (knife 11.36) — host-cc vs product config.o.
# Green = residual still locked (load OK + get NOT_FOUND). Not product load green.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

PROBE="tests/std-config/toml0_load_hold_protect.c"
PREFIX="xlang: [TOML0_LOAD_HOLD_PROTECT]"
OUT="/tmp/xlang_toml0_hold_protect_$$"
LOG="/tmp/xlang_toml0_hold_protect_$$.err"

die() {
  echo "toml0-load-hold-protect gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  rm -f "$OUT" "$LOG"
  exit 1
}

[ -f "$PROBE" ] || die "missing $PROBE"
[ -f std/config/config.o ] || die "missing std/config/config.o (refuse rebuild)"
[ -f std/config/README.md ] || die "missing README"
grep -qF '11.31' std/config/README.md || die "README must cite 11.31 residual"
grep -qF 'cfg_trim' std/config/README.md || die "README must cite cfg_trim root cause"

for o in \
  std/config/config.o \
  std/env/env.o \
  compiler/runtime_process_argv.o \
  compiler/runtime_env_os.o \
  compiler/src/runtime_io_abi.o \
  compiler/runtime_link_abi_user_env.o \
  compiler/runtime_asm_io_stubs.o
do
  [ -f "$o" ] || die "missing prebuilt $o (refuse soft auto-make)"
done

if ! cc -std=c11 -O0 -o "$OUT" "$PROBE" \
    std/config/config.o \
    std/env/env.o \
    compiler/runtime_process_argv.o \
    compiler/runtime_env_os.o \
    compiler/src/runtime_io_abi.o \
    compiler/runtime_link_abi_user_env.o \
    compiler/runtime_asm_io_stubs.o 2>"$LOG"; then
  tail -n 20 "$LOG" >&2 || true
  die "host-cc link failed"
fi

set +e
"$OUT"
ec=$?
set -e
rm -f "$OUT" "$LOG"
[ "$ec" -eq 0 ] || die "probe exit=$ec"

echo "${PREFIX} status=ok residual_locked=1 host-cc=1 runtime_load=deferred host=$(ci_host_summary)"
echo "toml0-load-hold-protect gate OK (residual locked; not product load green)"
