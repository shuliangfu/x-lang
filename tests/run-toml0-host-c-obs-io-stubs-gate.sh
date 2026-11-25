#!/usr/bin/env bash
# toml0 host-C obs io stubs link (knife 11.37).
# PASS: std_config_host_c_obs recipe includes runtime_asm_io_stubs.o AND obs returns 0
# (smoke exit=3 = 11.31 residual archaeology; NOT product load green).
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/std-config.sh
. "$(dirname "$0")/lib/std-config.sh"

PREFIX="xlang: [TOML0_HOST_C_OBS_IO_STUBS]"
LIB="tests/lib/std-config.sh"
STUBS="compiler/runtime_asm_io_stubs.o"

die() {
  echo "toml0-host-c-obs-io-stubs gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  exit 1
}

[ -f "$LIB" ] || die "missing $LIB"
grep -qF 'runtime_asm_io_stubs.o' "$LIB" || die "std-config.sh must link runtime_asm_io_stubs.o"
grep -qF 'Knife 11.37' "$LIB" || die "std-config.sh must cite Knife 11.37"
[ -f "$STUBS" ] || die "missing prebuilt $STUBS (refuse soft auto-make)"
[ -f std/config/config.o ] || die "missing std/config/config.o (refuse rebuild)"

set +e
std_config_host_c_obs "tests/std-config/config_smoke_ok.c"
ec=$?
set -e
[ "$ec" -eq 0 ] || die "std_config_host_c_obs exit=$ec (want 0 with residual honesty)"

echo "${PREFIX} status=ok stubs_linked=1 obs_ec=0 smoke_residual=11.31 host=$(ci_host_summary)"
echo "toml0-host-c-obs-io-stubs gate OK (link fixed; smoke exit=3 obs not product green)"
