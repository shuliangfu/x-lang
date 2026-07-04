#!/usr/bin/env sh
# create_driver_subcmd_gen_seeds.sh — 冷启动用 driver 子命令 gen seed（G-06）
#
# fmt/check 可 -E；test/compile/build/run/emit 对 bootstrap_shuxc 解析失败时用薄桩 TU。

set -e
cd "$(dirname "$0")/.."
mkdir -p seeds

write_stub() {
  sub="$1"
  body="$2"
  out="seeds/driver_${sub}_gen.linux.x86_64.c"
  cat > "$out" <<EOF
/* G-06 cold-start seed stub for driver/${sub}.x */
#include <stdint.h>
${body}
EOF
  echo "create_driver_subcmd_gen_seeds: $out ($(wc -c < "$out" | tr -d ' ') bytes)"
}

write_stub fmt '
extern int32_t driver_run_fmt(int32_t argc, uint8_t *argv);
int32_t driver_cmd_fmt(int32_t argc, uint8_t *argv) {
  return driver_run_fmt(argc, argv);
}
'

write_stub check '
extern int32_t driver_run_compiler_check(int32_t argc, uint8_t *argv);
int32_t driver_cmd_check(int32_t argc, uint8_t *argv) {
  return driver_run_compiler_check(argc, argv);
}
'

write_stub test '
extern int32_t driver_run_test(int32_t argc, uint8_t *argv);
int32_t driver_cmd_test(int32_t argc, uint8_t *argv) {
  return driver_run_test(argc, argv);
}
'

write_stub compile '
int driver_compile_gen_seed_placeholder;
'

write_stub build '
int driver_build_gen_seed_placeholder;
'

write_stub run '
extern int32_t driver_exec_compiled(int32_t argc, uint8_t *argv);
int32_t driver_cmd_run(int32_t argc, uint8_t *argv) {
  return driver_exec_compiled(argc, argv);
}
'

write_stub emit '
int driver_emit_gen_seed_placeholder;
'

echo "create_driver_subcmd_gen_seeds OK"
