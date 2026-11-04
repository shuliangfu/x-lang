#!/usr/bin/env bash
# toml0 smoke exit matrix protect (knife 11.43).
# PASS while product config_smoke_c and config_yaml_smoke_c both return 3
# (11.31 residual). FAIL if either returns 0 without Soft Cap tiphead knife.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

PREFIX="xlang: [TOML0_SMOKE_EXIT_MATRIX_PROTECT]"
OUT="/tmp/xlang_toml0_smoke_matrix_$$"
SRC="/tmp/xlang_toml0_smoke_matrix_$$.c"
LOG="/tmp/xlang_toml0_smoke_matrix_$$.err"

die() {
  echo "toml0-smoke-exit-matrix-protect gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  rm -f "$OUT" "$SRC" "$LOG"
  exit 1
}

[ -f std/config/config.o ] || die "missing config.o (refuse rebuild)"
[ -f compiler/runtime_asm_io_stubs.o ] || die "missing io stubs"
[ -f tests/std-config/yaml_smoke_ok.c ] || die "missing yaml_smoke_ok.c"
grep -qF 'config_yaml_smoke_c()' tests/std-config/yaml_smoke_ok.c || die "yaml harness must call smoke_c"
grep -qF 'return (int)config_yaml_smoke_c()' tests/std-config/yaml_smoke_ok.c || die "yaml harness must passthrough (11.42)"
grep -qF 'return (int)config_smoke_c()' tests/std-config/config_smoke_ok.c || die "config harness must passthrough"

cat >"$SRC" <<'CEOF'
#include <stdint.h>
#include <stdio.h>
extern int32_t config_smoke_c(void);
extern int32_t config_yaml_smoke_c(void);
int main(void) {
  int32_t c = config_smoke_c();
  int32_t y = config_yaml_smoke_c();
  printf("config_smoke=%d yaml_smoke=%d\n", (int)c, (int)y);
  if (c == 0 || y == 0) return 10;
  if (c != 3 || y != 3) return 11;
  return 0;
}
CEOF

if ! cc -std=c11 -O0 -o "$OUT" "$SRC" \
    std/config/config.o std/env/env.o \
    compiler/runtime_process_argv.o compiler/runtime_env_os.o \
    compiler/src/runtime_io_abi.o compiler/runtime_link_abi_user_env.o \
    compiler/runtime_asm_io_stubs.o 2>"$LOG"; then
  tail -n 15 "$LOG" >&2 || true
  die "host-cc link failed"
fi
set +e
"$OUT"
ec=$?
set -e
rm -f "$OUT" "$SRC" "$LOG"
[ "$ec" -eq 0 ] || die "matrix exit=$ec (want both smoke=3 residual_locked)"

echo "${PREFIX} status=ok residual_locked=1 config_smoke=3 yaml_smoke=3 runtime_load=deferred host=$(ci_host_summary)"
echo "toml0-smoke-exit-matrix-protect gate OK (residual locked; not product green)"
