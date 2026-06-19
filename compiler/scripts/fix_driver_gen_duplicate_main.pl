#!/usr/bin/env perl
# shux-c -E-extern 生成 driver_gen.c 时可能重复 main_run_compiler_c（后者自递归）。
# 保留转调 impl 的版本，删掉多余的自调用副本。
use strict;
use warnings;

my $path = $ARGV[0] or die "usage: fix_driver_gen_duplicate_main.pl driver_gen.c\n";
open my $fh, '+<', $path or die "open $path: $!\n";
local $/;
my $src = <$fh>;
my $orig = $src;

# 删掉 codegen 重复生成的 wrapper（impl 本体经 #define 已导出为 main_run_compiler_c）。
$src =~ s/\nint32_t main_run_compiler_c\(int32_t argc, uint8_t \* argv\) \{\n  return main_run_compiler_c_impl\(argc, argv\);\n\}//s;
$src =~ s/\nint32_t main_run_compiler_c\(int32_t argc, uint8_t \* argv\) \{\n  return main_run_compiler_c\(argc, argv\);\n\}//s;
# 去重连续相同前向声明。
while ($src =~ s/(int32_t main_run_compiler_c\(int32_t argc, uint8_t \* argv\);\n)\1/$1/s) { }

# main.sx 调用 preprocess_sx_buf；-E-extern 导出 preprocess_sx_buf（由 preprocess_sx.o 提供）。
if (index($src, 'preprocess_sx_buf') >= 0 && index($src, '#define preprocess_sx_buf preprocess_sx_buf') < 0) {
  # 已是单名 preprocess_sx_buf，无需 #define 别名。
}

# -E-extern 瘦 driver_gen：生成体为 main_*，build_asm/main.o 导出多为单前缀（eq_minus_E 等）；补声明与 #define。
if ($path =~ /driver_gen\.c$/ && index($src, 'driver_gen thin TU aliases') < 0) {
  my $aliases = <<'DGEN';
/* driver_gen thin TU aliases: main.sx -E-extern 调用 main_*，build_asm/main.o 为单前缀符号 */
extern int32_t eq_minus_E(uint8_t *buf, int32_t len);
extern int32_t eq_minus_E_extern(uint8_t *buf, int32_t len);
extern int32_t eq_asm(uint8_t *buf, int32_t len);
extern int32_t str_eq(uint8_t *a, int32_t a_len, uint8_t *b, int32_t b_len);
extern int32_t target_contains_arm(uint8_t *buf, int32_t len);
extern int32_t target_contains_riscv(uint8_t *buf, int32_t len);
extern int32_t driver_emit_try_append_lib_from_argv(int32_t argc, uint8_t *argv, int32_t arg_i, struct main_DriverSuEmitState *state);
extern int32_t main_run_compiler_c(int32_t argc, uint8_t *argv);
extern int32_t main_cmd_build(int32_t argc, uint8_t *argv);
extern int32_t main_cmd_run(int32_t argc, uint8_t *argv);
extern int32_t driver_cmd_fmt(int32_t argc, uint8_t *argv);
extern int32_t driver_cmd_check(int32_t argc, uint8_t *argv);
extern int32_t driver_cmd_test(int32_t argc, uint8_t *argv);
#define main_eq_minus_E eq_minus_E
#define main_eq_minus_E_extern eq_minus_E_extern
#define main_eq_asm eq_asm
#define main_str_eq str_eq
#define main_target_contains_arm target_contains_arm
#define main_target_contains_riscv target_contains_riscv
#define main_driver_emit_try_append_lib_from_argv driver_emit_try_append_lib_from_argv
#define main_run_compiler_c_impl main_run_compiler_c

DGEN
  $src =~ s/(struct main_DriverSuEmitState \{[^\}]+\};)/$1\n$aliases/s
    or warn "fix_driver_gen: thin TU alias anchor not found\n";
}

if ($src ne $orig) {
  seek $fh, 0, 0;
  print $fh $src;
  truncate $fh, tell($fh);
}
close $fh;
