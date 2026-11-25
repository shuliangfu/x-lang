#!/usr/bin/env bash
# toml0 yaml host-C obs io stubs link (knife 11.40).
# PASS: std_config_yaml_run_c_smoke recipe includes runtime_asm_io_stubs.o AND
# host-cc link succeeds. Smoke non-zero remains OBS (11.31 class); not product green.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

PREFIX="xlang: [TOML0_YAML_HOST_C_OBS_IO_STUBS]"
LIB="tests/lib/std-config-yaml.sh"
STUBS="compiler/runtime_asm_io_stubs.o"
SRC="tests/std-config/yaml_smoke_ok.c"
OUT="/tmp/xlang_toml0_yaml_stubs_$$"
LOG="/tmp/xlang_toml0_yaml_stubs_$$.err"

die() {
  echo "toml0-yaml-host-c-obs-io-stubs gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  rm -f "$OUT" "$LOG"
  exit 1
}

[ -f "$LIB" ] || die "missing $LIB"
grep -qF 'runtime_asm_io_stubs.o' "$LIB" || die "std-config-yaml.sh must link runtime_asm_io_stubs.o"
grep -qF 'Knife 11.40' "$LIB" || die "std-config-yaml.sh must cite Knife 11.40"
[ -f "$STUBS" ] || die "missing prebuilt $STUBS (refuse soft auto-make)"
[ -f std/config/config.o ] || die "missing std/config/config.o (refuse rebuild)"
[ -f "$SRC" ] || die "missing $SRC"

for o in \
  std/config/config.o \
  std/env/env.o \
  compiler/runtime_process_argv.o \
  compiler/src/runtime_io_abi.o \
  compiler/runtime_link_abi_user_env.o \
  compiler/runtime_env_os.o \
  "$STUBS"
do
  [ -f "$o" ] || die "missing prebuilt $o"
done

if ! cc -std=c11 -O1 -o "$OUT" "$SRC" \
    std/config/config.o \
    std/env/env.o \
    compiler/runtime_process_argv.o \
    compiler/src/runtime_io_abi.o \
    compiler/runtime_link_abi_user_env.o \
    compiler/runtime_env_os.o \
    "$STUBS" 2>"$LOG"; then
  tail -n 15 "$LOG" >&2 || true
  die "host-cc link with stubs failed"
fi
set +e
"$OUT" >/dev/null 2>&1
run_ec=$?
set -e
rm -f "$OUT" "$LOG"

# 11.40 link + 11.42 passthrough: expect smoke residual exit=3 (11.31 family).
# exit=0 would mean residual CLEARED without Soft Cap tiphead knife — fail loud.
if [ "${run_ec}" -eq 0 ]; then
  die "run_ec=0 residual CLEARED? reopen Soft Cap tiphead; do not silent-ACCEPT"
fi
if [ "${run_ec}" -ne 3 ]; then
  die "run_ec=${run_ec} want 3 (11.31 residual passthrough after 11.42)"
fi
echo "${PREFIX} status=ok stubs_linked=1 link=1 run_ec=3 residual_locked=1 runtime_yaml=deferred host=$(ci_host_summary)"
echo "toml0-yaml-host-c-obs-io-stubs gate OK (link+passthrough; residual locked; not product green)"
