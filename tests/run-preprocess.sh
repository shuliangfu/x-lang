#!/usr/bin/env bash
# 条件编译测试：-D FOO 时保留 #if FOO 分支（返回 11），否则走 #else（返回 22）
# bootstrap run-all 下 $SHU 为 seed（验 .su 流水线）；-o 链接走 $RUN_SHU（Darwin/ARM64 seed asm ld 会 __TEXT r-x 失败）。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHU=${SHU:-./compiler/shu}
# shellcheck source=tests/lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"

# 无 -D：应走 #else，返回 22
"$RUN_SHU" tests/preprocess/main.su -o /tmp/shu_pp_no_d 2>&1
exitcode=0; /tmp/shu_pp_no_d >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 22 ] && { echo "expected 22 (no -D), got $exitcode"; exit 1; }

# -D FOO：应走 #if FOO，返回 11
"$RUN_SHU" -D FOO tests/preprocess/main.su -o /tmp/shu_pp_d_foo 2>&1
exitcode=0; /tmp/shu_pp_d_foo >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 11 ] && { echo "expected 11 (-D FOO), got $exitcode"; exit 1; }

# -DFOO 无空格形式
"$RUN_SHU" -DFOO tests/preprocess/main.su -o /tmp/shu_pp_dfoo 2>&1
exitcode=0; /tmp/shu_pp_dfoo >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 11 ] && { echo "expected 11 (-DFOO), got $exitcode"; exit 1; }

# #elseif：无 -D 走 #else → 3；-D FOO → 1；-D BAR → 2
"$RUN_SHU" tests/preprocess/elseif.su -o /tmp/shu_pp_elseif 2>&1
exitcode=0; /tmp/shu_pp_elseif >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 3 ] && { echo "expected 3 (elseif no -D), got $exitcode"; exit 1; }
"$RUN_SHU" -D FOO tests/preprocess/elseif.su -o /tmp/shu_pp_elseif_foo 2>&1
exitcode=0; /tmp/shu_pp_elseif_foo >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "expected 1 (elseif -D FOO), got $exitcode"; exit 1; }
"$RUN_SHU" -D BAR tests/preprocess/elseif.su -o /tmp/shu_pp_elseif_bar 2>&1
exitcode=0; /tmp/shu_pp_elseif_bar >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 2 ] && { echo "expected 2 (elseif -D BAR), got $exitcode"; exit 1; }

# 边界：仅有 #if 无 #endif → 应报 unclosed #if，编译失败
err=$("$RUN_SHU" tests/preprocess/unclosed_if.su -o /tmp/shu_pp_bad 2>&1) || true
echo "$err" | grep -q "unclosed #if" || { echo "expected 'unclosed #if' in: $err"; exit 1; }

# 边界：#else 前无 #if → 应报 #else without #if
err=$("$RUN_SHU" tests/preprocess/else_without_if.su -o /tmp/shu_pp_bad 2>&1) || true
echo "$err" | grep -q "#else without #if" || { echo "expected '#else without #if' in: $err"; exit 1; }

# 边界：#endif 前无 #if → 应报 #endif without #if
err=$("$RUN_SHU" tests/preprocess/endif_without_if.su -o /tmp/shu_pp_bad 2>&1) || true
echo "$err" | grep -q "#endif without #if" || { echo "expected '#endif without #if' in: $err"; exit 1; }

# 边界：#elseif 前无 #if → 应报 #elseif without #if
err=$("$RUN_SHU" tests/preprocess/elseif_without_if.su -o /tmp/shu_pp_bad 2>&1) || true
echo "$err" | grep -q "#elseif without #if" || { echo "expected '#elseif without #if' in: $err"; exit 1; }

# 边界：#elseif 出现在 #else 之后 → 应报 #elseif after #else
err=$("$RUN_SHU" tests/preprocess/elseif_after_else.su -o /tmp/shu_pp_bad 2>&1) || true
echo "$err" | grep -q "#elseif after #else" || { echo "expected '#elseif after #else' in: $err"; exit 1; }

# 边界：同一块内两个 #else → 应报 duplicate #else
err=$("$RUN_SHU" tests/preprocess/duplicate_else.su -o /tmp/shu_pp_bad 2>&1) || true
echo "$err" | grep -q "duplicate #else" || { echo "expected 'duplicate #else' in: $err"; exit 1; }

# 边界：多一个 #endif（顺序/数量错）→ 应报 #endif without #if
err=$("$RUN_SHU" tests/preprocess/extra_endif.su -o /tmp/shu_pp_bad 2>&1) || true
echo "$err" | grep -q "#endif without #if" || { echo "expected '#endif without #if' in: $err"; exit 1; }

echo "preprocess (conditional compile) test OK"
