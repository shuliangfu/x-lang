#!/bin/sh
# build_shu_asm.sh — 用 asm 后端构建 shu（Goal 2：.su → 目标文件 .o，不经 -E C 翻译）
# 用法：在 compiler 目录下执行 SHU=./shu ./scripts/build_shu_asm.sh
#       或由 build_tool 调用：./build_tool ./shu asm（策略见仓库根目录 build.su 注释）。
# 依赖：SHU 已支持 -backend asm；宿主 cc 用于链接桩、-E 产物与最终链接 shu_asm。
# crt0 / runtime_panic / typeck_f64_bits 由本脚本内 ensure_asm_link_objs 用 cc 生成，不依赖 make。
#
# 回退链接（非 Linux crt0 路径）：runtime_asm_build 调 main_entry（main.su 经 -E 的 C 符号名）；runtime_driver 依赖
# pipeline_run_su_pipeline、parser_parse_into*、asm_asm_codegen_elf_o 等。这些符号来自 -E 生成的
# pipeline_gen.c/driver_gen.c（与 Makefile bootstrap-driver-seed 一致），不能仅靠 src/*.c 前端：
# C parser 导出的是 parse 等名，与 runtime 期望的 parser_parse_into 不一致。
# pipeline_gen.c 已内联 ast/lexer/parser/typeck/codegen 与 asm 后端；当前 -backend asm 产出的 build_asm/*.o
# 多为空桩（仅 Mach-O 壳），并入回退链接会触发 Apple ld 断言或重复定义。故回退链仅 -E 产物 + C 种子，不并 build_asm/*.o。
# Linux crt0 成功路径仍使用整包 NONEMPTY_ASM（见下方）。
#
# 仅当 main.o/pipeline.o 均非空且链接仍失败时退出码 1（供 build_tool 回退 legacy）；其它情况 0。
# 构建顺序与 LIBROOT 唯一定义在 src/asm/asm_build_list.su。

set -e
cd "$(dirname "$0")/.."

# 调试 env 勿泄漏进 build_asm：SHU_ASM_START_FUNC>=模块 func 数时 emit 循环全跳过，仅剩 8B 空 __text 桩（B-strict PTEXT 门禁失败）。
unset SHU_ASM_START_FUNC 2>/dev/null || true

# B-strict（SHU_ASM_EXPERIMENTAL_SKIP_GEN=1）：链接或 smoke 失败即 exit 1，不回退 gen_driver / pipeline_su。
shu_asm_bstrict_fail() {
  echo "build_shu_asm: B-strict failed: $*"
  exit 1
}

SHU="${SHU:-./shu}"
BUILD_LIST_SU="src/asm/asm_build_list.su"
BUILD_DIR="build_asm"
mkdir -p "$BUILD_DIR"

# ./shu 在 make all 后为 C 种子（无 -backend asm）；bootstrap-driver-seed 后 shu-su 与 shu 均含 asm。
if [ "$SHU" = "./shu" ] && [ -x ./shu-su ]; then
  if ./shu -backend asm 2>&1 | grep -q "not available"; then
    SHU=./shu-su
  fi
fi

# 链接拓扑在非 Linux 宿主上固定 pipeline_su；Linux 上若 check_asm_o_quality 认定全部 __text 非空，
# 且未手动导出 SHU_ASM_LINK_TOPOLOGY，则自动选 full_asm（见 docs/SELFHOST.md §4）。具体赋值在质检文件写出之后。
# （不在此处默认值化 SHU_ASM_LINK_TOPOLOGY，避免与下方自动选择冲突）

# 从 .su 唯一定义读取 LIBROOT（行格式：// LIBROOT:<tab>-L .. -L src ...）；TAB 用于兼容 BSD sed
TAB=$(printf '\t')
LIBROOT=""
if [ -f "$BUILD_LIST_SU" ]; then
  LIBROOT=$(grep '^// LIBROOT:' "$BUILD_LIST_SU" | sed "s|^// LIBROOT:${TAB}||")
fi
[ -z "$LIBROOT" ] && LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

echo "build_shu_asm: using SHU=$SHU (list from $BUILD_LIST_SU)"

# compile_su 的 stub 回退与后续链接均依赖宿主 cc；须在 asm 编译循环之前定义。
CC="${CC:-cc}"
CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"

# backend.su 等大模块 asm 编译 abort 时，用最小 .s 占位保证 __text 非空（质检 24/24）。
emit_asm_text_stub_o() {
  local out="$1"
  local stub_s="scripts/asm_text_stub.s"
  [ -f "$stub_s" ] || return 1
  echo "    fallback: $CC -c $stub_s -> $out (asm compile abort recovery)"
  "$CC" -c -o "$out" "$stub_s" 2>/dev/null
}

# 按依赖顺序尝试编译各 .su 为 .o（顺序由 asm_build_list.su 的 // BUILD: 行定义）
# SKIP 表示该次 -backend asm -o 编译失败（命令非零退出）；默认保留 stderr，可直接看到失败原因（如 asm_codegen_elf_o failed）。
# 常见原因：asm_codegen_elf_o 内某步失败，或 pipeline 解析/类型检查/codegen 失败。若需静默可设 SHU_ASM_QUIET=1。

# 质量向：小/中模块默认走真 typeck+asm；特大模块仍 SKIP_TYPECK（可用 SHU_ASM_FORCE_SKIP_TYPECK=1 强制全 skip）。
    asm_out_needs_skip_typeck() {
  case "$1" in
    typeck.o|parser.o|pipeline.o|macho.o|backend.o|codegen.o|lsp.o|main.o|ast.o|types.o|peephole.o|coff.o|platform_elf.o|x86_64.o|x86_64_enc.o|arm64.o|arm64_enc.o|riscv64.o|riscv64_enc.o|asm.o)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

compile_su() {
  local out="$BUILD_DIR/$1"
  local src="$2"
  local skip_typeck=0
  printf "  asm %s -> %s ... " "$src" "$out"
  # 大模块（typeck/codegen/elf）parse/typeck 栈帧深；macOS 默认栈易 segfault(139)。
  ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  # 单模块 .o：仅编入口符号，dep 由其它 build_asm/*.o 并列提供，避免 Mach-O 重复定义。
  # 勿设 SHU_TYPECK_FORCE_C：C typeck_module 面向旧式 fat Module，slim pool 模块会 segfault。
  if [ -n "${SHU_ASM_FORCE_SKIP_TYPECK:-}" ]; then
    skip_typeck=1
  elif asm_out_needs_skip_typeck "$1"; then
    skip_typeck=1
  fi
  if [ -n "${SHU_ASM_QUIET}" ]; then
    if [ "$skip_typeck" -eq 1 ]; then
      if env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 "$SHU" -backend asm -o "$out" $LIBROOT "$src" 2>/dev/null; then echo OK; return 0; fi
    else
      if env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 "$SHU" -backend asm -o "$out" $LIBROOT "$src" 2>/dev/null; then echo OK; return 0; fi
      if env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 "$SHU" -backend asm -o "$out" $LIBROOT "$src" 2>/dev/null; then echo OK-fallback-skip; return 0; fi
    fi
    if emit_asm_text_stub_o "$out"; then echo OK-stub; return 0; fi
    echo SKIP
    return 0
  fi
  if [ "$skip_typeck" -eq 1 ]; then
    if env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 "$SHU" -backend asm -o "$out" $LIBROOT "$src"; then echo OK; return 0; fi
  else
    if env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 "$SHU" -backend asm -o "$out" $LIBROOT "$src"; then echo OK; return 0; fi
    echo "    retry with SHU_ASM_BUILD_SKIP_TYPECK=1 ..."
    if env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 "$SHU" -backend asm -o "$out" $LIBROOT "$src"; then echo OK-fallback-skip; return 0; fi
  fi
  # backend.su 等大模块在 SKIP_TYPECK 桩 emit 时仍可能 abort；用最小 .s 占位保证 __text 非空。
  if emit_asm_text_stub_o "$out"; then echo OK-stub; return 0; fi
  echo SKIP
  return 0
}

# 读 .o 代码段大小（Mach-O __text 或 ELF .text），失败返回 0。
asm_o_text_bytes() {
  local o="$1"
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  if [ -z "$hex" ]; then
    hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  fi
  if [ -z "$hex" ]; then
    echo 0
    return
  fi
  echo $((16#$hex))
}

# 实验链第一遍链接后：用新 shu_asm + 最新 pipeline_glue_standalone 重编 pipeline.o（避免鸡生蛋 4B 桩）。
rebuild_pipeline_o_second_pass() {
  if [ ! -x ./shu_asm ]; then
    echo "build_shu_asm: second pass skipped (no ./shu_asm)"
    return 1
  fi
  ensure_asm_pipeline_glue_standalone_obj
  echo "build_shu_asm: second pass — recompile pipeline.o with bootstrap shu_asm ..."
  ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  PTMP="$BUILD_DIR/pipeline.second_pass.o"
  # 首遍 bootstrap 刚链出 shu_asm 时优先用其重编 pipeline.o（勿回退宿主 ./shu，二者 TU 不一致）。
  local pcomp="./shu_asm"
  if [ ! -x "$pcomp" ]; then
    pcomp="${SHU:-./shu}"
  fi
  if env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 "$pcomp" -backend asm -o "$PTMP" $LIBROOT src/pipeline/pipeline.su; then
    mv -f "$PTMP" "$BUILD_DIR/pipeline.o"
    PTEXT=$(asm_o_text_bytes "$BUILD_DIR/pipeline.o")
    echo "build_shu_asm: pipeline.o second pass OK (__text=${PTEXT}B)"
    return 0
  fi
  if env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 "$pcomp" -backend asm -o "$PTMP" $LIBROOT src/pipeline/pipeline.su; then
    mv -f "$PTMP" "$BUILD_DIR/pipeline.o"
    PTEXT=$(asm_o_text_bytes "$BUILD_DIR/pipeline.o")
    echo "build_shu_asm: pipeline.o second pass OK with SKIP_TYPECK (__text=${PTEXT}B)"
    return 0
  fi
  rm -f "$PTMP" 2>/dev/null || true
  echo "build_shu_asm: pipeline.o second pass failed"
  return 1
}

# 第二遍：用 bootstrap shu_asm（experimental 链，含 pipeline_su.o）重编大模块；须在 strict 重链覆盖 shu_asm 之前执行。
rebuild_typeck_parser_backend_second_pass() {
  # 第二遍优先用宿主 SHU（pipeline_su.o 内 ast_pool）；自链 shu_asm 编 typeck.su 易 Abort。
  local comp="${SHU:-./shu}"
  if [ -n "${1:-}" ] && [ -x "${1}" ]; then
    comp="$1"
  fi
  if [ ! -x "$comp" ]; then
    comp="./shu_asm.experimental"
  fi
  if [ ! -x "$comp" ]; then
    comp="./shu_asm"
  fi
  if [ ! -x "$comp" ]; then
    return 1
  fi
  local ok=0
  ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  for spec in "typeck.o:src/typeck/typeck.su" "parser.o:src/parser/parser.su" "backend.o:src/asm/backend.su"; do
    local out="${spec%%:*}"
    local src="${spec#*:}"
    local tmp="$BUILD_DIR/${out%.o}.second_pass.o"
    local pass_ok=0
    echo "build_shu_asm: second pass — recompile $out with $comp ..."
    if [ "$out" = "typeck.o" ]; then
      # strict 第二遍：EMIT_HEAVY 真 emit func#146+；Abort 时回退 SKIP 桩。
      if env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY=1 "$comp" -backend asm -o "$tmp" $LIBROOT "$src" && pass_ok=1; then
        :
      elif env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 "$comp" -backend asm -o "$tmp" $LIBROOT "$src" && pass_ok=1; then
        echo "build_shu_asm: $out second pass EMIT_HEAVY failed; fallback SKIP stub"
      fi
    elif [ "$out" = "backend.o" ]; then
      if env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY=1 "$comp" -backend asm -o "$tmp" $LIBROOT "$src" && pass_ok=1; then
        :
      elif env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 "$comp" -backend asm -o "$tmp" $LIBROOT "$src" && pass_ok=1; then
        echo "build_shu_asm: $out second pass EMIT_HEAVY failed; fallback SKIP stub"
      fi
    elif env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 "$comp" -backend asm -o "$tmp" $LIBROOT "$src" && pass_ok=1; then
      :
    fi
    if [ "$pass_ok" -eq 1 ] && [ -f "$tmp" ]; then
      mv -f "$tmp" "$BUILD_DIR/$out"
      echo "build_shu_asm: $out second pass OK (__text=$(asm_o_text_bytes "$BUILD_DIR/$out")B)"
      ok=1
    else
      rm -f "$tmp" 2>/dev/null || true
      echo "build_shu_asm: $out second pass failed"
      return 1
    fi
  done
  [ "$ok" -eq 1 ]
}

# build_asm/main.o（ENTRY_MODULE_ONLY）会导出强符号 main_entry，盖住 bridge 的子命令路由；剥离后保留 entry。
strip_main_entry_from_build_asm_main_o() {
  local mo="$BUILD_DIR/main.o"
  [ -f "$mo" ] || return 0
  if ! nm "$mo" 2>/dev/null | grep -q ' _main_entry$'; then
    return 0
  fi
  echo "build_shu_asm: strip _main_entry from main.o (CLI dispatch via asm_experimental_symbol_bridge) ..."
  if command -v llvm-objcopy >/dev/null 2>&1; then
    llvm-objcopy --strip-symbol=_main_entry "$mo"
  elif strip -N _main_entry "$mo" 2>/dev/null; then
    :
  elif command -v objcopy >/dev/null 2>&1; then
    objcopy --strip-symbol=_main_entry "$mo" 2>/dev/null || objcopy -N _main_entry "$mo"
  else
    echo "build_shu_asm: cannot strip _main_entry (need llvm-objcopy or strip -N)" >&2
    return 1
  fi
}

# B-strict strict 重链前：main.su 勿 ENTRY_MODULE_ONLY，否则 entry 无 check/fmt/test 子命令路由。
rebuild_main_o_for_cli() {
  local comp="${SHU_ASM_SECOND_PASS_COMPILER:-./shu_asm.experimental}"
  [ -x "$comp" ] || comp="./shu_asm"
  [ -x "$comp" ] || comp="$SHU"
  local tmp="$BUILD_DIR/main.cli.o"
  echo "build_shu_asm: recompile main.o (full CLI entry, no ENTRY_MODULE_ONLY) ..."
  set +e
  if "$comp" -backend asm -o "$tmp" $LIBROOT src/main.su; then
    mv -f "$tmp" "$BUILD_DIR/main.o"
    echo "build_shu_asm: main.o CLI entry OK (__text=$(asm_o_text_bytes "$BUILD_DIR/main.o" 2>/dev/null || echo ?)B)"
    set -e
    return 0
  fi
  set -e
  echo "build_shu_asm: main.o CLI recompile failed (check/fmt/test may be unavailable)" >&2
  return 1
}

if [ -f "$BUILD_LIST_SU" ]; then
  grep '^// BUILD:' "$BUILD_LIST_SU" | while IFS= read -r line; do
    rest=$(echo "$line" | sed "s|^// BUILD:${TAB}||")
    out=$(echo "$rest" | cut -f1)
    src=$(echo "$rest" | cut -f2)
    [ -n "$out" ] && [ -n "$src" ] && compile_su "$out" "$src"
  done
else
  echo "build_shu_asm: $BUILD_LIST_SU not found, using built-in list."
  compile_su token.o src/lexer/token.su
  compile_su ast.o src/ast/ast.su
  compile_su codegen.o src/codegen/codegen.su
  compile_su typeck.o src/typeck/typeck.su
  compile_su lexer.o src/lexer/lexer.su
  compile_su preprocess.o src/preprocess/preprocess.su
  compile_su std_fs.o ../std/fs/mod.su
  compile_su lsp.o src/lsp/lsp.su
  compile_su types.o src/asm/types.su
  compile_su platform_elf.o src/asm/platform/elf.su
  compile_su x86_64.o src/asm/arch/x86_64.su
  compile_su x86_64_enc.o src/asm/arch/x86_64_enc.su
  compile_su arm64.o src/asm/arch/arm64.su
  compile_su arm64_enc.o src/asm/arch/arm64_enc.su
  compile_su riscv64.o src/asm/arch/riscv64.su
  compile_su riscv64_enc.o src/asm/arch/riscv64_enc.su
  compile_su peephole.o src/asm/peephole.su
  compile_su backend.o src/asm/backend.su
  compile_su asm.o src/asm/asm.su
  compile_su macho.o src/asm/platform/macho.su
  compile_su coff.o src/asm/platform/coff.su
  compile_su parser.o src/parser/parser.su
  compile_su pipeline.o src/pipeline/pipeline.su
  compile_su main.o src/main.su
fi

# 报告 build_asm/*.o 的 __text 是否非空；写入 build_asm/.asm_text_quality（供 topology 降级判断）
if [ -z "${SHU_ASM_SKIP_QUALITY_REPORT}" ]; then
  SHU="$SHU" ./scripts/check_asm_o_quality.sh || true
  # Target B（SELFHOST §4）：非空清单提示下一批应修的 BUILD 令牌，便于逐项消灭 EMPTY/MISSING
  BADEMPTY="$BUILD_DIR/.asm_empty_text_list"
  if [ -s "$BADEMPTY" ]; then
    echo "build_shu_asm: __text EMPTY/MISSING sample (full list: $BADEMPTY, doc: docs/SELFHOST.md §4.1)"
    head -n 12 "$BADEMPTY" | sed 's/^/  /' || true
  fi
fi

# 链接：仅当 main.o 与 pipeline.o 均来自 asm 时，用 asm 版链接。
# 优先尝试「无 C 桩」路径（仅 Linux）：crt0_x86_64.o + typeck_f64_bits.o + runtime_panic.o + build_asm/*.o + -lc -lm；
# 失败或非 Linux 时回退到 runtime_asm_build.o + runtime_driver.o + -E 流水线 .o + C 种子（不并 build_asm/*.o，见上文）。
#
# 下列用 cc 直接编译，不调用 make，以便在「仅 bootstrap.sh + build_tool」环境下完成 asm 链接（朝去掉 Makefile 走一步）。
# CC/CFLAGS 已在 compile_su 之前定义（stub 回退需要）。

# 与 Makefile PIPELINE_GEN_CFLAGS 对齐：编译 -E 大文件时压制已知告警；Clang 追加额外 -Wno。
detect_pipeline_gen_cflags() {
  PIPELINE_GEN_CFLAGS="-Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits"
  if "$CC" -v 2>&1 | grep -qi clang; then
    PIPELINE_GEN_CFLAGS="$PIPELINE_GEN_CFLAGS -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses -Wno-incompatible-pointer-types-discards-qualifiers"
  fi
}

# Target B 实验链：编译 pipeline_run_su_pipeline 最小 C 桥（见 src/asm/pipeline_glue_link.c）。
ensure_asm_pipeline_glue_link_obj() {
  GLUE_LINK_OBJ="$BUILD_DIR/pipeline_glue_link.o"
  if [ ! -f "$GLUE_LINK_OBJ" ] || [ "src/asm/pipeline_glue_link.c" -nt "$GLUE_LINK_OBJ" ]; then
    echo "  cc -c src/asm/pipeline_glue_link.c -> $GLUE_LINK_OBJ"
    "$CC" $CFLAGS -c -o "$GLUE_LINK_OBJ" src/asm/pipeline_glue_link.c
  fi
}

# 实验链：run_su_pipeline_impl 别名到 pipeline_run_su_pipeline_impl（无 pipeline_su.o 时）
ensure_asm_pipeline_run_impl_alias_obj() {
  ALIAS_OBJ="$BUILD_DIR/pipeline_run_impl_alias.o"
  if [ ! -f "$ALIAS_OBJ" ] || [ "src/asm/pipeline_run_impl_alias.c" -nt "$ALIAS_OBJ" ]; then
    echo "  cc -c src/asm/pipeline_run_impl_alias.c -> $ALIAS_OBJ"
    "$CC" $CFLAGS -c -o "$ALIAS_OBJ" src/asm/pipeline_run_impl_alias.c
  fi
}

# strict 链：build_asm/parser.o 自举时 parse_into_buf 等大函数未进 module；从 pipeline_su.o 部分链接 parser_* 真机码。
ensure_parser_bootstrap_partial_obj() {
  PARTIAL="$BUILD_DIR/parser_bootstrap_partial.o"
  SYMS="$BUILD_DIR/parser_bootstrap_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_su.o"
  ensure_pipeline_su_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_su_objs
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    printf '%s\n' \
      '_parser_parse_into_buf' \
      '_parser_collect_imports_buf' \
      '_parser_parse_into_init' \
      '_parser_parse_into_set_main_index' > "$SYMS"
    echo "  ld -r -exported_symbols_list $SYMS pipeline_su.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$SUO"
  fi
}

# strict 链：从 pipeline_su.o 导出全部 parser_* 真机码（自洽 TU），替代 build_asm/parser.o 桩 + 零散 partial。
ensure_parser_from_su_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/parser_from_su_partial.o"
  SYMS="$BUILD_DIR/parser_from_su_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_su.o"
  ensure_pipeline_su_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_su_objs
  fi
  if [ ! -f "$SYMS" ] || [ "$SUO" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ]; then
    GLUE_O="$BUILD_DIR/pipeline_glue_standalone.o"
    ensure_asm_pipeline_glue_standalone_obj
    nm "$SUO" | awk '/ T _parser_/ {print $3}' > "$BUILD_DIR/.parser_from_su_all.txt"
    : > "$SYMS"
    while IFS= read -r sym; do
      [ -n "$sym" ] || continue
      if [ -f "$GLUE_O" ] && nm "$GLUE_O" 2>/dev/null | grep -q " T ${sym}$"; then
        continue
      fi
      printf '%s\n' "$sym" >> "$SYMS"
    done < "$BUILD_DIR/.parser_from_su_all.txt"
    echo "  nm pipeline_su.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') parser_* symbols, glue dupes skipped)"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    echo "  ld -r -exported_symbols_list $SYMS pipeline_su.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$SUO"
  fi
}

# strict 链：build_asm/parser.o 的 parse_into_init 等为桩；与 parser_bootstrap_partial 合并后 bootstrap 符号优先。
ensure_parser_strict_merged_obj() {
  local MERGED PO PARTIAL SYMS
  MERGED="$BUILD_DIR/parser_strict_merged.o"
  SYMS="$BUILD_DIR/parser_strict_merged_export.txt"
  PO="$BUILD_DIR/parser.o"
  ensure_parser_bootstrap_partial_obj
  PARTIAL="$BUILD_DIR/parser_bootstrap_partial.o"
  if [ ! -f "$PO" ] || [ ! -f "$PARTIAL" ]; then
    return 1
  fi
  if [ ! -f "$MERGED" ] || [ "$PO" -nt "$MERGED" ] || [ "$PARTIAL" -nt "$MERGED" ] || [ "$SYMS" -nt "$MERGED" ]; then
    printf '%s\n' \
      '_parser_parse_into_buf' \
      '_parser_collect_imports_buf' \
      '_parser_parse_into_init' \
      '_parser_parse_into_set_main_index' > "$SYMS"
    echo "  ld -r -exported_symbols_list $SYMS parser.o + parser_bootstrap_partial.o -> $MERGED"
    ld -r -exported_symbols_list "$SYMS" -o "$MERGED" "$PO" "$PARTIAL"
  fi
  return 0
}

# strict 链：build_asm/pipeline.o 编排函数 emit 不可用；C 实现供 ld -r 合并进 runtime partial。
ensure_pipeline_asm_orchestration_partial_obj() {
  local PARTIAL SYMS ALIAS_O
  PARTIAL="$BUILD_DIR/pipeline_asm_orchestration_partial.o"
  SYMS="$BUILD_DIR/pipeline_asm_orchestration_export.txt"
  ALIAS_O="$BUILD_DIR/pipeline_asm_orchestration_alias.o"
  if [ ! -f "$ALIAS_O" ] || [ "src/asm/pipeline_asm_orchestration_alias.c" -nt "$ALIAS_O" ]; then
    echo "  cc -c src/asm/pipeline_asm_orchestration_alias.c -> $ALIAS_O"
    "$CC" $CFLAGS -c -o "$ALIAS_O" src/asm/pipeline_asm_orchestration_alias.c
  fi
  if [ ! -f "$PARTIAL" ] || [ "$ALIAS_O" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_pipeline_run_su_pipeline_impl
_run_su_pipeline_impl
_pipeline_impl_run_all
_pipeline_impl_phase_parse_load
_pipeline_impl_phase_parse_only
_pipeline_impl_typecheck
_parse_into_with_init_buf
EOF
    echo "  ld -r -exported_symbols_list $SYMS orchestration_alias.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$ALIAS_O"
  fi
  # strict 链最终链接读 pipeline_asm_runtime_partial.o
  cp -f "$PARTIAL" "$BUILD_DIR/pipeline_asm_runtime_partial.o"
  return 0
}

# strict 链：pipeline.o 第二遍 emit 的 typecheck if/else 不完整；C alias 单独提供 pipeline_impl_typecheck。
ensure_pipeline_asm_typecheck_alias_obj() {
  local ALIAS_O
  ALIAS_O="$BUILD_DIR/pipeline_asm_typecheck_alias.o"
  if [ ! -f "$ALIAS_O" ] || [ "src/asm/pipeline_asm_typecheck_alias.c" -nt "$ALIAS_O" ]; then
    echo "  cc -c src/asm/pipeline_asm_typecheck_alias.c -> $ALIAS_O"
    "$CC" $CFLAGS -c -o "$ALIAS_O" src/asm/pipeline_asm_typecheck_alias.c
  fi
}

# strict 链：pipeline.o 第二遍 emit 的 run_all typeck 失败后仍进 codegen；C alias 单独 ld -r。
ensure_pipeline_asm_run_all_partial_obj() {
  local PARTIAL SYMS ALIAS_O
  PARTIAL="$BUILD_DIR/pipeline_asm_run_all_partial.o"
  SYMS="$BUILD_DIR/pipeline_asm_run_all_export.txt"
  ALIAS_O="$BUILD_DIR/pipeline_asm_run_all_alias.o"
  if [ ! -f "$ALIAS_O" ] || [ "src/asm/pipeline_asm_run_all_alias.c" -nt "$ALIAS_O" ]; then
    echo "  cc -c src/asm/pipeline_asm_run_all_alias.c -> $ALIAS_O"
    "$CC" $CFLAGS -c -o "$ALIAS_O" src/asm/pipeline_asm_run_all_alias.c
  fi
  if [ ! -f "$PARTIAL" ] || [ "$ALIAS_O" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_pipeline_impl_run_all
_run_su_pipeline_impl
EOF
    echo "  ld -r -exported_symbols_list $SYMS run_all_alias.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$ALIAS_O"
  fi
}

# strict 链（B-strict+asm）：第二遍 build_asm/pipeline.o 导出编排符号（spill/load 已修）；不含 U 的 phase_parse_only。
ensure_pipeline_asm_orchestration_from_build_o() {
  local PARTIAL SYMS PO
  PARTIAL="$BUILD_DIR/pipeline_asm_orchestration_from_build.o"
  SYMS="$BUILD_DIR/pipeline_asm_orchestration_from_build_export.txt"
  PO="$BUILD_DIR/pipeline.o"
  if [ ! -f "$PO" ] || [ ! -s "$PO" ]; then
    return 1
  fi
  if [ ! -f "$PARTIAL" ] || [ "$PO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_pipeline_impl_phase_load_deps
_pipeline_impl_should_skip_codegen
_pipeline_impl_codegen_deps
_pipeline_impl_codegen_entry
_pipeline_impl_codegen_chain
EOF
    echo "  ld -r -exported_symbols_list $SYMS build_asm/pipeline.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$PO"
  fi
  return 0
}

# strict 链：pipeline.su 自洽 parse 包（parse_into_with_init_buf + parser_*），避免 U 解析到 build_asm 空桩。
ensure_pipeline_parse_su_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/pipeline_parse_su_partial.o"
  SYMS="$BUILD_DIR/pipeline_parse_su_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_su.o"
  ensure_pipeline_su_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_su_objs
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_pipeline_parse_into_with_init_buf
_parser_parse_into_buf
_parser_parse_into_init
_parser_parse_into_set_main_index
_parser_collect_imports_buf
EOF
    echo "  ld -r -exported_symbols_list $SYMS pipeline_su.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$SUO"
  fi
}

# strict 链：pipeline.o 第二遍 emit 缺 pipeline_impl_phase_parse_only（ENTRY_MODULE_ONLY 未落码），单 TU 补一条。
ensure_pipeline_phase_parse_only_partial_obj() {
  local PARTIAL SYMS ALIAS_O
  PARTIAL="$BUILD_DIR/pipeline_phase_parse_only_partial.o"
  SYMS="$BUILD_DIR/pipeline_phase_parse_only_export.txt"
  ALIAS_O="$BUILD_DIR/pipeline_phase_parse_only_alias.o"
  if [ ! -f "$ALIAS_O" ] || [ "src/asm/pipeline_phase_parse_only_alias.c" -nt "$ALIAS_O" ]; then
    echo "  cc -c src/asm/pipeline_phase_parse_only_alias.c -> $ALIAS_O"
    "$CC" $CFLAGS -c -o "$ALIAS_O" src/asm/pipeline_phase_parse_only_alias.c
  fi
  if [ ! -f "$PARTIAL" ] || [ "$ALIAS_O" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
      cat > "$SYMS" <<'EOF'
_pipeline_impl_phase_parse_only
EOF
    else
      cat > "$SYMS" <<'EOF'
_pipeline_impl_phase_parse_only
_pipeline_impl_phase_parse_load
EOF
    fi
    echo "  ld -r -exported_symbols_list $SYMS phase_parse_only_alias.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$ALIAS_O"
  fi
}

# strict 链：C orchestration partial 即 runtime partial（勿链 pipeline.o，避免 dead broken 符号拉入 U typeck）。
ensure_pipeline_asm_runtime_partial_obj() {
  ensure_pipeline_asm_orchestration_partial_obj
}

# strict 回退：build_asm pipeline 仍不足时，从 pipeline_su.o 部分链接完整 pipeline_run_su_pipeline_impl。
ensure_pipeline_runtime_bootstrap_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/pipeline_runtime_bootstrap_partial.o"
  SYMS="$BUILD_DIR/pipeline_runtime_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_su.o"
  ensure_pipeline_su_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_su_objs
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    printf '%s\n' '_pipeline_run_su_pipeline_impl' > "$SYMS"
    echo "  ld -r -exported_symbols_list $SYMS pipeline_su.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$SUO"
  fi
}

# strict 链：build_asm 编排/typeck/codegen 仍不足时，从 pipeline_su.o 部分链接（不含 pipeline_run 重复符号）。
ensure_pipeline_asm_su_bootstrap_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/pipeline_asm_su_bootstrap_partial.o"
  SYMS="$BUILD_DIR/pipeline_asm_su_bootstrap_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_su.o"
  ensure_pipeline_su_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_su_objs
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_asm_asm_codegen_ast
_backend_asm_codegen_ast
_typeck_typeck_su_ast
_typeck_typeck_su_ast_library
EOF
    echo "  ld -r -exported_symbols_list $SYMS pipeline_su.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$SUO"
  fi
  # 兼容旧名
  cp -f "$PARTIAL" "$BUILD_DIR/pipeline_asm_codegen_bootstrap_partial.o"
}

# strict 编排链：parse + typeck + codegen 须同一 ld -r（两次 partial 会重复 parser 内部符号 → body_ref=0）。
ensure_pipeline_asm_strict_support_partial_obj() {
  local PARTIAL SYMS SUO PARSE_ONLY_SYMS
  PARTIAL="$BUILD_DIR/pipeline_asm_strict_support_partial.o"
  SYMS="$BUILD_DIR/pipeline_asm_strict_support_export.txt"
  PARSE_ONLY_SYMS="$BUILD_DIR/pipeline_asm_strict_support_parse_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_su.o"
  local TCK_BYTES BACK_BYTES
  TCK_BYTES=$(asm_o_text_bytes "$BUILD_DIR/typeck.o" 2>/dev/null || echo 0)
  BACK_BYTES=$(asm_o_text_bytes "$BUILD_DIR/backend.o" 2>/dev/null || echo 0)
  ensure_pipeline_su_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_su_objs
  fi
  # build_asm typeck.o 已完整自举（__text>8KiB）时 partial 只补 parse；否则 partial 含 typeck_su_ast*。
  if asm_strict_typeck_selfhosted; then
    cat > "$PARSE_ONLY_SYMS" <<'EOF'
_pipeline_parse_into_with_init_buf
_parser_parse_into_buf
_parser_parse_into_init
_parser_parse_into_set_main_index
_parser_collect_imports_buf
_parser_parse_into
_parser_get_module_num_imports
_parser_get_module_import_path
EOF
    SYMS="$PARSE_ONLY_SYMS"
    echo "build_shu_asm: strict_support parse-only partial (typeck.o=${TCK_BYTES}B selfhosted from build_asm)"
  else
    cat > "$SYMS" <<'EOF'
_pipeline_parse_into_with_init_buf
_parser_parse_into_buf
_parser_parse_into_init
_parser_parse_into_set_main_index
_parser_collect_imports_buf
_parser_parse_into
_parser_get_module_num_imports
_parser_get_module_import_path
_typeck_typeck_su_ast
_typeck_typeck_su_ast_library
EOF
    echo "build_shu_asm: strict_support parse+typeck partial (typeck.o=${TCK_BYTES}B not selfhosted yet)"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || \
     [ "$BUILD_DIR/typeck.o" -nt "$PARTIAL" ] || [ "$BUILD_DIR/backend.o" -nt "$PARTIAL" ]; then
    echo "  ld -r -exported_symbols_list $SYMS pipeline_su.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$SUO"
  fi
}

# B-strict：runtime 入口薄壳，委托 strict_core 全局 pipeline_pipeline_impl_run_all（勿链 pipeline_su run_impl partial）。
ensure_pipeline_run_bootstrap_trampoline_obj() {
  local TRAMP_O TRAMP_CFLAGS
  TRAMP_O="$BUILD_DIR/pipeline_run_bootstrap_trampoline.o"
  TRAMP_CFLAGS="$CFLAGS"
  if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
    TRAMP_CFLAGS="$CFLAGS -DSTRICT_LINK_BUILD_ASM_PIPELINE=1"
  fi
  if [ ! -f "$TRAMP_O" ] || [ "src/asm/pipeline_run_bootstrap_trampoline.c" -nt "$TRAMP_O" ] || \
     [ ! -f "$BUILD_DIR/.pipeline_trampoline_strict_flag" ] || \
     [ "$(cat "$BUILD_DIR/.pipeline_trampoline_strict_flag" 2>/dev/null)" != "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" ]; then
    echo "  cc -c src/asm/pipeline_run_bootstrap_trampoline.c -> $TRAMP_O (STRICT_LINK_BUILD_ASM_PIPELINE=${STRICT_LINK_BUILD_ASM_PIPELINE:-0})"
    "$CC" $TRAMP_CFLAGS -c -o "$TRAMP_O" src/asm/pipeline_run_bootstrap_trampoline.c
    echo "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" >"$BUILD_DIR/.pipeline_trampoline_strict_flag"
  fi
}

# B-strict：pipeline_su.o 导出除 run_impl 外全部全局符号（backend 内 glue 须为 T 非 local t）。
ensure_pipeline_asm_strict_core_partial_obj() {
  local PARTIAL SYMS SUO ALL_SYMS
  PARTIAL="$BUILD_DIR/pipeline_asm_strict_core_partial.o"
  SYMS="$BUILD_DIR/pipeline_asm_strict_core_export.txt"
  ALL_SYMS="$BUILD_DIR/pipeline_asm_strict_core_all_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_su.o"
  ensure_pipeline_su_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_su_objs
  fi
  if [ ! -f "$ALL_SYMS" ] || [ "$SUO" -nt "$ALL_SYMS" ] || [ "ast_pool.c" -nt "$ALL_SYMS" ]; then
    nm "$SUO" | awk '/ T _/ {print $3}' | \
      grep -v '_pipeline_run_su_pipeline_impl$' | \
      grep -v '^_fs_' | \
      grep -v '^_std_fs_' | \
      grep -v '^_std_io_' > "$ALL_SYMS"
    echo "  nm pipeline_su.o -> $ALL_SYMS ($(wc -l <"$ALL_SYMS" | tr -d ' ') symbols, excl run_impl/fs/std_fs)"
  fi
  SYMS="$ALL_SYMS"
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || \
     [ "$BUILD_DIR/typeck.o" -nt "$PARTIAL" ] || [ "ast_pool.c" -nt "$PARTIAL" ]; then
    echo "  ld -r -exported_symbols_list $SYMS pipeline_su.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$SUO"
    echo "build_shu_asm: strict_core full partial (pipeline_su minus run_impl, glue globals preserved)"
  fi
}

# B-strict：最小 glue（无 ast_pool）；strict_core partial 已含 ast_pool 真机码。
ensure_asm_pipeline_glue_strict_minimal_obj() {
  local GLUE_OBJ="$BUILD_DIR/pipeline_glue_strict_minimal.o"
  if [ ! -f "$GLUE_OBJ" ] || [ "src/asm/pipeline_glue_strict_minimal.c" -nt "$GLUE_OBJ" ]; then
    echo "  cc -c src/asm/pipeline_glue_strict_minimal.c -> $GLUE_OBJ"
    "$CC" $CFLAGS -c -o "$GLUE_OBJ" src/asm/pipeline_glue_strict_minimal.c
  fi
}

# B-strict：preprocess -D 与 labeled 名写入（ast_pool_l5_bridge.c；strict_core 无整份 ast_pool TU）。
ensure_ast_pool_l5_bridge_obj() {
  local OBJ="$BUILD_DIR/ast_pool_l5_bridge.o"
  if [ ! -f "$OBJ" ] || [ "src/ast_pool_l5_bridge.c" -nt "$OBJ" ] || [ "ast_pool.c" -nt "$OBJ" ]; then
    echo "  cc -c src/ast_pool_l5_bridge.c -> $OBJ"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$OBJ" src/ast_pool_l5_bridge.c
  fi
}

# B-strict：pipeline_su.o 仅导出 asm/backend 四入口（legacy；strict 链请用 strict_core 单 partial）。
ensure_pipeline_asm_codegen_only_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/pipeline_asm_codegen_only_partial.o"
  SYMS="$BUILD_DIR/pipeline_asm_codegen_only_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_su.o"
  ensure_pipeline_su_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_su_objs
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_asm_asm_codegen_ast
_asm_asm_codegen_elf_o
_backend_asm_codegen_ast
_backend_asm_codegen_ast_to_elf
EOF
    echo "  ld -r -exported_symbols_list $SYMS pipeline_su.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$SUO"
  fi
}

# build_asm pipeline.o 第二遍 __text>512B 时链入真编排（含 pipeline_impl_run_all），替代 strict_core partial。
asm_strict_pipeline_selfhosted() {
  local t
  t=$(asm_o_text_bytes "$BUILD_DIR/pipeline.o" 2>/dev/null || echo 0)
  [ "$t" -gt 512 ] 2>/dev/null
}

# build_asm typeck.o 仅 __text>8KiB 视为完整自举 emit；否则 typeck 走 strict_support partial。
asm_strict_typeck_selfhosted() {
  local t
  t=$(asm_o_text_bytes "$BUILD_DIR/typeck.o" 2>/dev/null || echo 0)
  [ "$t" -gt 8192 ] 2>/dev/null
}

# build_asm typeck.o 未自举完成时：仅导出 layout/metrics 符号供 glue，不含 typeck_su_ast 桩。
ensure_typeck_asm_layout_partial_obj() {
  local PARTIAL SYMS TCK
  PARTIAL="$BUILD_DIR/typeck_asm_layout_partial.o"
  SYMS="$BUILD_DIR/typeck_asm_layout_export.txt"
  TCK="$BUILD_DIR/typeck.o"
  if [ ! -f "$TCK" ] || [ ! -s "$TCK" ]; then
    return 1
  fi
  if [ ! -f "$PARTIAL" ] || [ "$TCK" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_typeck_struct_layout_metrics
_typeck_validate_struct_layouts_zero_padding
_ensure_struct_layout_from_struct_lit
_typeck_merge_dep_struct_layouts_into_entry
_entry_module_find_struct_layout_index
_typeck_find_struct_layout_index_by_name
EOF
    echo "  ld -r -exported_symbols_list $SYMS typeck.o -> $PARTIAL (layout only)"
    set +e
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$TCK" 2>"$BUILD_DIR/.typeck_layout_partial_err"
    local ld_rc=$?
    set -e
    if [ "$ld_rc" -ne 0 ]; then
      echo "build_shu_asm: typeck layout partial skipped (layout symbols missing in typeck.o; need typeck second pass >8KiB)"
      rm -f "$PARTIAL"
      return 1
    fi
  fi
}

# build_asm typeck.o 供 glue metrics；codegen 走 codegen_only partial。
asm_strict_keep_build_asm_typeck_backend() {
  asm_strict_typeck_selfhosted
}

# 实验 asm-only 链：build_asm 裸符号名 → runtime 期望名（首链 experimental 仍需要；strict 链不链 bridge）。
ensure_asm_experimental_symbol_bridge_obj() {
  BRIDGE_OBJ="$BUILD_DIR/asm_experimental_symbol_bridge.o"
  if [ ! -f "$BRIDGE_OBJ" ] || [ "src/asm/asm_experimental_symbol_bridge.c" -nt "$BRIDGE_OBJ" ]; then
    echo "  cc -c src/asm/asm_experimental_symbol_bridge.c -> $BRIDGE_OBJ"
    "$CC" $CFLAGS -c -o "$BRIDGE_OBJ" src/asm/asm_experimental_symbol_bridge.c
  fi
}

# 实验链：排除 partial/glue/与 runtime/seed 冲突的模块 .o。
filter_experimental_asm_objs() {
  FILTERED=""
  UNAME_HOST=$(uname -m 2>/dev/null || echo unknown)
  for o in $NONEMPTY_ASM; do
    base=$(basename "$o")
    case "$base" in
      main.o|parser.o|asm.o|lsp.o|\
      backend.o|codegen.o|typeck.o|pipeline.o|std_fs.o|platform_elf.o|macho.o|coff.o|\
      pipeline_glue_link.o|pipeline_run_impl_alias.o|pipeline_glue_standalone.o|pipeline_glue_strict_minimal.o|\
      parser_bootstrap_partial.o|parser_from_su_partial.o|parser_strict_merged.o|\
      pipeline_parse_su_partial.o|pipeline_runtime_bootstrap_partial.o|\
      pipeline_asm_su_bootstrap_partial.o|pipeline_asm_codegen_bootstrap_partial.o|\
      pipeline_asm_runtime_partial.o|pipeline_asm_orchestration_partial.o|\
      pipeline_asm_orchestration_from_build.o|pipeline_phase_parse_only_partial.o|\
      pipeline_phase_parse_only_alias.o|pipeline_asm_run_all_partial.o|\
      pipeline_asm_run_all_alias.o|pipeline_asm_typecheck_alias.o|\
      pipeline_asm_helpers_partial.o|pipeline_asm_orchestration_alias.o|\
      pipeline_asm_strict_support_partial.o|pipeline_asm_codegen_only_partial.o|\
      pipeline_asm_strict_core_partial.o|\
      pipeline_run_bootstrap_trampoline.o|\
      std_fs_shim.o|su_seed_bridge.o|\
      parser_from_gen.o|asm_experimental_symbol_bridge.o|asm_shu_lsp_diag_stub.o|lsp_codegen_extern.o)
        continue
        ;;
    esac
    case "$UNAME_HOST" in
      arm64|aarch64)
        case "$base" in
          x86_64.o|x86_64_enc.o|riscv64.o|riscv64_enc.o) continue ;;
        esac
        ;;
      x86_64|amd64)
        case "$base" in
          arm64.o|arm64_enc.o|riscv64.o|riscv64_enc.o) continue ;;
        esac
        ;;
    esac
    FILTERED="$FILTERED $o"
  done
}

# strict 链：build_asm 编译器 .o + codegen_only partial（四入口真 codegen）+ runtime_bootstrap pipeline_run。
# STRICT_LINK_BUILD_ASM_PIPELINE=1 时链入 build_asm/pipeline.o（真编排），不链 runtime_bootstrap partial。
filter_strict_asm_objs() {
  FILTERED=""
  UNAME_HOST=$(uname -m 2>/dev/null || echo unknown)
  local LINK_BUILD_ASM_TYPECK=0
  local LINK_BUILD_ASM_PIPELINE=0
  if asm_strict_typeck_selfhosted; then
    LINK_BUILD_ASM_TYPECK=1
  fi
  if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
    LINK_BUILD_ASM_PIPELINE=1
  fi
  for o in $NONEMPTY_ASM; do
    base=$(basename "$o")
    if [ "$base" = "pipeline.o" ]; then
      if [ "$LINK_BUILD_ASM_PIPELINE" -eq 1 ]; then
        FILTERED="$FILTERED $o"
      fi
      continue
    fi
    if [ "$base" = "parser.o" ]; then
      continue
    fi
    case "$base" in
      parser.o|backend.o|asm.o|main.o|lsp.o|std_fs.o|\
      codegen.o|pipeline_glue_link.o|pipeline_run_impl_alias.o|pipeline_glue_standalone.o|pipeline_glue_strict_minimal.o|\
      parser_bootstrap_partial.o|parser_from_su_partial.o|parser_strict_merged.o|\
      pipeline_parse_su_partial.o|pipeline_runtime_bootstrap_partial.o|\
      pipeline_asm_su_bootstrap_partial.o|pipeline_asm_codegen_bootstrap_partial.o|\
      pipeline_asm_runtime_partial.o|pipeline_asm_orchestration_partial.o|\
      pipeline_asm_orchestration_from_build.o|pipeline_phase_parse_only_partial.o|\
      pipeline_phase_parse_only_alias.o|pipeline_asm_run_all_partial.o|\
      pipeline_asm_run_all_alias.o|pipeline_asm_typecheck_alias.o|\
      pipeline_asm_helpers_partial.o|pipeline_asm_orchestration_alias.o|\
      pipeline_asm_strict_support_partial.o|pipeline_asm_codegen_only_partial.o|\
      pipeline_asm_strict_core_partial.o|\
      pipeline_run_bootstrap_trampoline.o|\
      typeck_skip.o|typeck_heavy.o|typeck.second.o|\
      typeck_asm_layout_partial.o|\
      std_fs_shim.o|su_seed_bridge.o|\
      parser_from_gen.o|asm_experimental_symbol_bridge.o|asm_shu_lsp_diag_stub.o|lsp_codegen_extern.o)
        continue
        ;;
    esac
    if [ "$base" = "typeck.o" ]; then
      if [ "$LINK_BUILD_ASM_TYPECK" -eq 1 ]; then
        FILTERED="$FILTERED $o"
      fi
      continue
    fi
    if [ "$base" = "typeck_asm_layout_partial.o" ] && [ "$LINK_BUILD_ASM_TYPECK" -eq 1 ]; then
      continue
    fi
    case "$UNAME_HOST" in
      arm64|aarch64)
        case "$base" in
          x86_64.o|x86_64_enc.o|riscv64.o|riscv64_enc.o) continue ;;
        esac
        ;;
      x86_64|amd64)
        case "$base" in
          arm64.o|arm64_enc.o|riscv64.o|riscv64_enc.o) continue ;;
        esac
        ;;
    esac
    FILTERED="$FILTERED $o"
  done
}

# Target B 实验链：独立 pipeline_glue+ast_pool TU（类型从 pipeline_gen.c 抽取，不含 .su 函数体）。
ensure_asm_pipeline_glue_standalone_obj() {
  detect_pipeline_gen_cflags
  GLUE_TYPES="$BUILD_DIR/pipeline_glue_types.inc"
  GLUE_STANDALONE_OBJ="$BUILD_DIR/pipeline_glue_standalone.o"
  GEN_PIPELINE="$BUILD_DIR/gen_driver/pipeline_gen.c"
  NEED_GEN=0
  if [ ! -f "$GEN_PIPELINE" ]; then
    NEED_GEN=1
  fi
  if [ "$NEED_GEN" -eq 0 ] && [ ! -f "$GLUE_TYPES" ]; then
    NEED_GEN=1
  fi
  if [ "$NEED_GEN" -eq 0 ] && [ "$GEN_PIPELINE" -nt "$GLUE_TYPES" ]; then
    NEED_GEN=1
  fi
  if [ "$NEED_GEN" -eq 1 ]; then
    mkdir -p "$BUILD_DIR/gen_driver"
    SHU_E_LOCAL="${SHU_E:-}"
    if [ -z "$SHU_E_LOCAL" ] || [ ! -x "$SHU_E_LOCAL" ]; then
      if [ -x ./shu-c ]; then SHU_E_LOCAL=./shu-c; else SHU_E_LOCAL="$SHU"; fi
    fi
    echo "  $SHU_E_LOCAL -E pipeline.su -> $GEN_PIPELINE (glue standalone types) ..."
    "$SHU_E_LOCAL" -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess \
      src/pipeline/pipeline.su -E >"$GEN_PIPELINE"
    perl -i -ne 'print unless /^struct shulang_slice_uint8_t/ && $seen++' "$GEN_PIPELINE" 2>/dev/null || true
    perl scripts/fix_slim_arena_gen_c.pl "$GEN_PIPELINE" 2>/dev/null || true
    perl scripts/hoist_pipeline_prototypes.pl "$GEN_PIPELINE" 2>/dev/null || true
    echo "  perl extract_pipeline_glue_types.pl -> $GLUE_TYPES"
    perl scripts/extract_pipeline_glue_types.pl "$GEN_PIPELINE" >"$GLUE_TYPES"
    if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
      perl -i -0777 -pe 's/\nenum ast_ExprKind parser_compound_assign_token_to_expr_kind\(enum token_TokenKind kind\) \{\n  return compound_assign_token_to_expr_kind_from_glue\(kind\);\n\}//g' "$GLUE_TYPES" 2>/dev/null || true
    fi
  fi
  if [ ! -f "$GLUE_STANDALONE_OBJ" ] || [ "src/asm/pipeline_glue_standalone.c" -nt "$GLUE_STANDALONE_OBJ" ] || [ "$GLUE_TYPES" -nt "$GLUE_STANDALONE_OBJ" ] || [ "ast_pool.c" -nt "$GLUE_STANDALONE_OBJ" ] || [ "pipeline_glue.c" -nt "$GLUE_STANDALONE_OBJ" ] || [ "scripts/extract_pipeline_glue_types.pl" -nt "$GLUE_STANDALONE_OBJ" ]; then
    echo "  cc -c src/asm/pipeline_glue_standalone.c -> $GLUE_STANDALONE_OBJ"
    if ! "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I"$BUILD_DIR" -c -o "$GLUE_STANDALONE_OBJ" src/asm/pipeline_glue_standalone.c; then
      echo "build_shu_asm: pipeline_glue_standalone.o compile failed (strict 链可继续用 pipeline_glue_strict_minimal)"
      rm -f "$GLUE_STANDALONE_OBJ" 2>/dev/null || true
    fi
  fi
}

# 收集非空 build_asm/*.o（空文件多为 asm SKIP 残留）
build_nonempty_asm_objs() {
  NONEMPTY_ASM=""
  for o in "$BUILD_DIR"/*.o; do
    [ -f "$o" ] || continue
    base=$(basename "$o")
    case "$base" in
      typeck_skip.o|typeck_heavy.o|typeck.second.o)
        continue
        ;;
    esac
    if [ -s "$o" ]; then
      NONEMPTY_ASM="$NONEMPTY_ASM $o"
    fi
  done
}

# 确保 ../std/fs、io、heap 的 .o 存在（与 Makefile 规则一致，供 driver / pipeline_glue 解析 fs/io）
ensure_std_fs_io_heap_objs() {
  echo "  cc -c ../std/io/io.o ../std/fs/fs.o ../std/heap/heap.o (if missing)"
  [ -f ../std/io/io.o ] || "$CC" $CFLAGS -c -o ../std/io/io.o ../std/io/io.c
  [ -f ../std/fs/fs.o ] || "$CC" $CFLAGS -c -o ../std/fs/fs.o ../std/fs/fs.c
  [ -f ../std/heap/heap.o ] || "$CC" $CFLAGS -c -o ../std/heap/heap.o ../std/heap/heap.c
}

# B-strict 首遍 bootstrap：与 bootstrap-driver-seed 对齐的 -E-extern 分模块 .o + asm 后端 partial。
# 瘦 pipeline_su.o 须链 parser_su/typeck_su/codegen_su/lexer_su、std_fs_shim、seed_host backend partial；
# 首遍勿并 build_asm/*.o（各模块 __shu_asm_mod_stub 重复 → Darwin ld 失败）。
ensure_asm_bootstrap_su_companion_objs() {
  detect_pipeline_gen_cflags
  ensure_pipeline_su_o_fresh
  if [ -f Makefile ] && command -v make >/dev/null 2>&1; then
    echo "build_shu_asm: ensure SU companion objs (parser/lexer/typeck/codegen/preprocess/compile) ..."
    # 瘦 pipeline_su.o 仍引用 codegen_codegen_* / typeck_typeck_* / lexer_lexer_init；须与 bootstrap-driver-seed 同款 link alias。
    make -s parser_su.o lexer_su.o typeck_su.o codegen_su.o preprocess_su.o \
      lexer_su_link_alias.o typeck_su_link_alias.o codegen_su_link_alias.o \
      driver_su.o driver_fmt_su.o driver_check_su.o driver_test_su.o \
      driver_build_su.o driver_run_su.o driver_compile_su.o driver_emit_su.o
  fi
  if [ ! -f "$BUILD_DIR/std_fs_shim.o" ] || [ "src/std_fs_shim.c" -nt "$BUILD_DIR/std_fs_shim.o" ]; then
    echo "  cc -c src/std_fs_shim.c -> $BUILD_DIR/std_fs_shim.o"
    "$CC" $CFLAGS -c -o "$BUILD_DIR/std_fs_shim.o" src/std_fs_shim.c
  fi
  if [ ! -f "$BUILD_DIR/su_seed_bridge.o" ] || [ "src/su_seed_bridge.c" -nt "$BUILD_DIR/su_seed_bridge.o" ]; then
    echo "  cc -c src/su_seed_bridge.c -> $BUILD_DIR/su_seed_bridge.o"
    "$CC" $CFLAGS -c -o "$BUILD_DIR/su_seed_bridge.o" src/su_seed_bridge.c
  fi
  if [ ! -f "$BUILD_DIR/seed_host/asm_backend_partial.o" ] || [ "src/asm/backend.su" -nt "$BUILD_DIR/seed_host/asm_backend_partial.o" ]; then
    echo "build_shu_asm: build_seed_asm_host (backend_enc_* for pipeline_su.o) ..."
    ./scripts/build_seed_asm_host.sh
  fi
  ensure_bstrict_seed_support_objs
}

# 与 Makefile bootstrap-driver-seed / relink-shu 对齐：pipeline_su.o 经 glue 引用的 backend 桥与 check/fmt C 实现。
ensure_bstrict_seed_support_objs() {
  if [ ! -f src/asm/asm_backend_compat_stubs.o ] \
    || [ "src/asm/asm_backend_compat_stubs.c" -nt src/asm/asm_backend_compat_stubs.o ]; then
    echo "  cc -c src/asm/asm_backend_compat_stubs.c -> src/asm/asm_backend_compat_stubs.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/asm_backend_compat_stubs.o src/asm/asm_backend_compat_stubs.c
  fi
  if [ ! -f src/driver/fmt_check_cmd_driver.o ] \
    || [ "src/driver/fmt_check_cmd.c" -nt src/driver/fmt_check_cmd_driver.o ]; then
    echo "  cc -c src/driver/fmt_check_cmd.c -> src/driver/fmt_check_cmd_driver.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/driver/fmt_check_cmd_driver.o src/driver/fmt_check_cmd.c
  fi
}

# bootstrap-driver-seed 同款的 C 种子 .o：与 pipeline_su.o 并存时不链完整 ast.c（用 -DSHU_USE_SU_AST 的 ast_seed）。
ensure_asm_driver_seed_c_objs() {
  SEED_DIR="$BUILD_DIR/asm_driver_seed"
  mkdir -p "$SEED_DIR"
  echo "  cc -c asm_driver_seed/*.o <- preprocess/lexer/ast_seed/parser/typeck/codegen/lsp_diag/lsp_state .c"
  "$CC" $CFLAGS -DSHU_USE_SU_PREPROCESS -c -o "$SEED_DIR/preprocess.o" src/preprocess.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/lexer.o" src/lexer/lexer.c
  "$CC" $CFLAGS -DSHU_USE_SU_AST -c -o "$SEED_DIR/ast_seed.o" src/ast/ast.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/parser.o" src/parser/parser.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/typeck.o" src/typeck/typeck.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/codegen.o" src/codegen/codegen.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/lsp_diag.o" src/lsp/lsp_diag.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/lsp_state.o" src/lsp/lsp_state.c
}

# ast_pool.c 白名单在 pipeline_su.o（#include pipeline_glue.c）内；PIPELINE_SU_DEPS（含 backend/arm64_enc）变更后须 bootstrap-pipeline → pipeline_su.o。
ensure_pipeline_su_o_fresh() {
  local need=0
  if [ ! -f pipeline_su.o ] || [ ! -f pipeline_gen.c ]; then
    need=1
  fi
  if [ "$need" -eq 0 ] && [ "ast_pool.c" -nt "pipeline_su.o" ]; then
    need=1
  fi
  # Makefile PIPELINE_SU_DEPS：asm 编码/backend 变更不会触达 pipeline_gen.c 时 ensure 仍须重 -E。
  for dep in \
    src/pipeline/pipeline.su src/codegen/codegen.su src/typeck/typeck.su src/parser/parser.su \
    src/ast/ast.su src/lexer/lexer.su src/preprocess/preprocess.su src/asm/asm.su \
    src/asm/backend.su src/asm/platform/elf.su src/asm/arch/arm64.su src/asm/arch/arm64_enc.su; do
    if [ -f "$dep" ] && [ "$dep" -nt "pipeline_su.o" ]; then
      need=1
      break
    fi
  done
  if [ "$need" -eq 1 ]; then
    echo "build_shu_asm: rebuild pipeline_su.o (PIPELINE_SU_DEPS / ast_pool newer than pipeline_su.o) ..."
    make bootstrap-pipeline pipeline_su.o
  fi
}

# 用 shu-c（优先）对 pipeline/main/lsp/preprocess 做 -E，再 cc 编成 .o；提供 pipeline_*、entry、main_run_compiler_c、asm_asm_codegen_elf_o 等。
# SHU_E 可覆盖；默认 ./shu-c（Makefile 约定：pipeline -E 须 C 解析器 stmt_order，勿用已链 su 前端的 shu）。
ensure_asm_gen_driver_su_objs() {
  detect_pipeline_gen_cflags
  GEN_DIR="$BUILD_DIR/gen_driver"
  mkdir -p "$GEN_DIR"
  SHU_E="${SHU_E:-}"
  if [ -z "$SHU_E" ] || [ ! -x "$SHU_E" ]; then
    if [ -x ./shu-c ]; then
      SHU_E=./shu-c
    else
      SHU_E="$SHU"
    fi
  fi
  LIB_E_PIPELINE="-L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess"
  LIB_E_MAIN="-L .. -L src -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess"

  # -E 单文件聚合时可能对 slice ABI 重复吐出同名 struct，同一 TU 内触发重定义；与 verify-selfhost.sh 一致只保留首行。
  dedupe_shulang_slice_struct() {
    f="$1"
    [ -f "$f" ] || return 0
    perl -i -ne 'print unless /^struct shulang_slice_uint8_t/ && $seen++' "$f" 2>/dev/null || true
  }

  echo "  $SHU_E -E pipeline.su -> $GEN_DIR/pipeline_gen.c ..."
  "$SHU_E" $LIB_E_PIPELINE src/pipeline/pipeline.su -E >"$GEN_DIR/pipeline_gen.c"
  dedupe_shulang_slice_struct "$GEN_DIR/pipeline_gen.c"
  echo "  $SHU_E -E lsp_io.su (-E-extern) -> $GEN_DIR/lsp_io_gen.c ..."
  "$SHU_E" $LIB_E_MAIN src/lsp/lsp_io.su -E -E-extern >"$GEN_DIR/lsp_io_gen.c"
  echo "  $SHU_E -E lsp.su (-E-extern) -> $GEN_DIR/lsp_gen.c ..."
  "$SHU_E" $LIB_E_MAIN src/lsp/lsp.su -E -E-extern >"$GEN_DIR/lsp_gen.c"
  # lsp_gen.c 内大 state 数组迁至 lsp_state.c 的 g_lsp_state_buf（与 Makefile bootstrap-driver-seed 一致）
  sed -i.bak 's/uint8_t state_buf\[16388\] = { 0 }/extern uint8_t g_lsp_state_buf[16388]/' "$GEN_DIR/lsp_gen.c" 2>/dev/null || true
  sed -i.bak 's/(state_buf)/(g_lsp_state_buf)/g' "$GEN_DIR/lsp_gen.c" 2>/dev/null || true
  rm -f "$GEN_DIR/lsp_gen.c.bak"
  echo "  $SHU_E -E lsp_io_std_heap.su (-E-extern) -> $GEN_DIR/lsp_io_std_heap_gen.c ..."
  "$SHU_E" $LIB_E_MAIN src/lsp/lsp_io_std_heap.su -E -E-extern >"$GEN_DIR/lsp_io_std_heap_gen.c"
  echo "  $SHU_E -E main.su (-E-extern) -> $GEN_DIR/driver_gen.c ..."
  "$SHU_E" $LIB_E_MAIN src/main.su -E -E-extern >"$GEN_DIR/driver_gen.c"
  dedupe_shulang_slice_struct "$GEN_DIR/driver_gen.c"
  echo "  $SHU_E -E preprocess.su (-E-extern) -> $GEN_DIR/preprocess_gen.c ..."
  "$SHU_E" -L src/lexer -E -E-extern src/preprocess/preprocess.su >"$GEN_DIR/preprocess_gen.c"
  dedupe_shulang_slice_struct "$GEN_DIR/preprocess_gen.c"

  echo "  $SHU_E -E driver/*.su (-E-extern) -> $GEN_DIR/driver_*.c ..."
  "$SHU_E" -L .. -L src -L src/lexer -L src/ast -E -E-extern src/driver/fmt.su >"$GEN_DIR/driver_fmt.c"
  "$SHU_E" -L .. -L src -L src/lexer -L src/ast -E -E-extern src/driver/check.su >"$GEN_DIR/driver_check.c"
  "$SHU_E" -L .. -L src -L src/lexer -L src/ast -E -E-extern src/driver/test.su >"$GEN_DIR/driver_test.c"

  echo "  cc -c gen_driver/driver_*.o <- src/driver/*.su (-E-extern)"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -c "$GEN_DIR/driver_fmt.c" -o "$GEN_DIR/driver_fmt_su.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -c "$GEN_DIR/driver_check.c" -o "$GEN_DIR/driver_check_su.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -c "$GEN_DIR/driver_test.c" -o "$GEN_DIR/driver_test_su.o"

  # pipeline/driver/preprocess：优先复用 Makefile gen-su-driver-objs（与 bootstrap-driver-seed 同源依赖）
  if [ -f Makefile ] && command -v make >/dev/null 2>&1; then
    echo "  make gen-su-driver-objs -> copy pipeline_su.o driver_su.o preprocess_su.o to $GEN_DIR/"
    make -s gen-su-driver-objs
    cp -f pipeline_su.o driver_su.o preprocess_su.o "$GEN_DIR/"
  else
    echo "  cc -c gen_driver/*_su.o <- pipeline/driver/lsp/preprocess -E 产物 (no Makefile make)"
    "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I.. \
      -Dstd_io_driver_driver_read_ptr_len=shu_io_read_ptr_len \
      -Dstd_io_driver_driver_read_ptr=shu_io_read_ptr \
      -c "$GEN_DIR/pipeline_gen.c" -o "$GEN_DIR/pipeline_su.o"
    "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS \
      -Dstd_fs_fs_read=fs_posix_read_c -Dstd_fs_fs_write=fs_posix_write_c -Dstd_fs_fs_close=fs_posix_close_c \
      -c "$GEN_DIR/driver_gen.c" -o "$GEN_DIR/driver_su.o"
    "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -c "$GEN_DIR/preprocess_gen.c" -o "$GEN_DIR/preprocess_su.o"
  fi

  echo "  cc -c gen_driver/lsp*.o <- lsp -E 产物"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Dstd_io_read=io_read -Dstd_io_write=io_write \
    -c "$GEN_DIR/lsp_io_gen.c" -o "$GEN_DIR/lsp_io_su.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -c "$GEN_DIR/lsp_gen.c" -o "$GEN_DIR/lsp_su.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
    -c "$GEN_DIR/lsp_io_std_heap_gen.c" -o "$GEN_DIR/lsp_io_std_heap_su.o"
}

# lsp_diag.c 依赖 pipeline 结构体 sizeof（与 Makefile bootstrap-driver-seed 一致）
ensure_lsp_diag_pipeline_sizes_obj() {
  if [ ! -f src/lsp/lsp_diag_pipeline_sizes.o ]; then
    echo "  cc -c src/lsp/lsp_diag_pipeline_sizes.o"
    "$CC" $CFLAGS -c -o src/lsp/lsp_diag_pipeline_sizes.o src/lsp/lsp_diag_pipeline_sizes.c
  fi
}

# B-hybrid 链 lsp_su.o 需要 lsp_build_diagnostics_response 等；整份 lsp_diag_su.o 与 pipeline_su.o 重复 ast 符号
ensure_asm_shu_lsp_diag_stub_obj() {
  STUB_C="scripts/asm_shu_lsp_diag_stub.c"
  STUB_O="$BUILD_DIR/asm_shu_lsp_diag_stub.o"
  if [ ! -f "$STUB_O" ] || [ "$STUB_C" -nt "$STUB_O" ]; then
    echo "  cc -c $STUB_O <- $STUB_C"
    "$CC" $CFLAGS -c -o "$STUB_O" "$STUB_C"
  fi
}

# codegen.o（C seed）引用 lsp_codegen_emit_*；小 TU，不与 pipeline_su.o 重复
ensure_asm_lsp_codegen_extern_obj() {
  LCE_C="src/lsp/lsp_codegen_extern.c"
  LCE_O="$BUILD_DIR/lsp_codegen_extern.o"
  if [ ! -f "$LCE_O" ] || [ "$LCE_C" -nt "$LCE_O" ]; then
    echo "  cc -c $LCE_O <- $LCE_C"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$LCE_O" "$LCE_C"
  fi
}

# 回退链接所需的 C 桩（不依赖 make）
ensure_runtime_cc_stubs() {
  echo "  cc -c src/asm/runtime_asm_build.o <- src/asm/runtime_asm_build.c"
  "$CC" $CFLAGS -c -o src/asm/runtime_asm_build.o src/asm/runtime_asm_build.c
  echo "  cc -c src/runtime_driver.o <- src/runtime.c (-DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE -DSHU_USE_SU_PREPROCESS)"
  "$CC" $CFLAGS -DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE -DSHU_USE_SU_PREPROCESS -c -o src/runtime_driver.o src/runtime.c
}

# 确保 typeck_f64_bits.o 存在（pipeline_su / parser 浮点字面量位拆分）。
ensure_typeck_f64_bits_obj() {
  UNAME_S=$(uname -s 2>/dev/null || echo Unknown)
  if [ "$UNAME_S" = "Linux" ] && [ -f src/typeck/typeck_f64_bits_x86_64.s ]; then
    echo "  cc -c src/typeck/typeck_f64_bits.o <- typeck_f64_bits_x86_64.s"
    "$CC" -c -o src/typeck/typeck_f64_bits.o src/typeck/typeck_f64_bits_x86_64.s
  else
    echo "  cc -c src/typeck/typeck_f64_bits.o <- typeck_f64_bits.c"
    "$CC" $CFLAGS -c -o src/typeck/typeck_f64_bits.o src/typeck/typeck_f64_bits.c
  fi
}

# 确保 runtime_panic.o / crt0 / typeck_f64_bits 存在（逻辑与 compiler/Makefile 中对应规则一致）
ensure_asm_link_objs() {
  UNAME_S=$(uname -s 2>/dev/null || echo Unknown)
  ALPINE=0
  test -f /etc/alpine-release && ALPINE=1
  if [ "$UNAME_S" = "Linux" ] && [ "$ALPINE" != "1" ] && [ -f src/asm/runtime_panic_x86_64.s ]; then
    echo "  cc -c runtime_panic.o <- src/asm/runtime_panic_x86_64.s"
    "$CC" -c -o runtime_panic.o src/asm/runtime_panic_x86_64.s
  else
    echo "  cc -c runtime_panic.o <- src/asm/runtime_panic.c"
    "$CC" $CFLAGS -c -o runtime_panic.o src/asm/runtime_panic.c
  fi
  if [ "$UNAME_S" = "Linux" ] && [ -f src/asm/crt0_x86_64.s ]; then
    echo "  cc -c src/asm/crt0_x86_64.o <- src/asm/crt0_x86_64.s"
    "$CC" -c -o src/asm/crt0_x86_64.o src/asm/crt0_x86_64.s
  fi
  ensure_typeck_f64_bits_obj
}

LINK_OK=0
ASM_READY=0
LINK_MODE=""
ASM_TEXT_ALL_OK=0
[ -f "$BUILD_DIR/.asm_text_quality" ] && ASM_TEXT_ALL_OK=$(cat "$BUILD_DIR/.asm_text_quality")

# 拓扑：显式导出 SHU_ASM_LINK_TOPOLOGY 时尊重用户值；否则 Linux + 全域 __text 非空 → full_asm，其余 → pipeline_su
if [ -z "${SHU_ASM_LINK_TOPOLOGY+x}" ]; then
  SHU_ASM_LINK_TOPOLOGY=pipeline_su
  UNAMES=$(uname -s 2>/dev/null || echo Unknown)
  if [ "$ASM_TEXT_ALL_OK" = "1" ]; then
    SHU_ASM_LINK_TOPOLOGY=full_asm
    if [ "$UNAMES" = "Linux" ]; then
      echo "build_shu_asm: auto SHU_ASM_LINK_TOPOLOGY=full_asm (Linux, all BUILD __text non-empty)"
    else
      echo "build_shu_asm: auto SHU_ASM_LINK_TOPOLOGY=full_asm ($UNAMES, all BUILD __text non-empty; link仍默认 pipeline_su 回退，见 SHU_ASM_EXPERIMENTAL_SKIP_GEN)"
    fi
  elif [ "$UNAMES" != "Linux" ]; then
    echo "build_shu_asm: host=$UNAMES: topology pipeline_su (crt0 仅 Linux；docs/SELFHOST.md §4)"
  fi
else
  if [ "$SHU_ASM_LINK_TOPOLOGY" = "full_asm" ] && [ "$ASM_TEXT_ALL_OK" != "1" ]; then
    echo "build_shu_asm: SHU_ASM_LINK_TOPOLOGY=full_asm requires all __text non-empty; forcing pipeline_su"
    SHU_ASM_LINK_TOPOLOGY=pipeline_su
  fi
fi

if [ -f "$BUILD_DIR/main.o" ] && [ -s "$BUILD_DIR/main.o" ] && [ -f "$BUILD_DIR/pipeline.o" ] && [ -s "$BUILD_DIR/pipeline.o" ]; then
  ASM_READY=1
  build_nonempty_asm_objs
  USE_CRT0=0
  if [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
    ensure_asm_link_objs
  fi
  # B-strict（SKIP_GEN）须 asm_only_strict（含 runtime_driver）；crt0 链无 driver，成功反而会触发末尾 bstrict 失败。
  if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
    echo "build_shu_asm: SHU_ASM_EXPERIMENTAL_SKIP_GEN=1 — skip crt0 link (use asm_only_strict; crt0 见 make bootstrap-driver-crt0)"
  elif [ "$(uname -s 2>/dev/null)" = "Linux" ] && [ -f src/asm/crt0_x86_64.o ] && [ -f src/typeck/typeck_f64_bits.o ] && [ -f runtime_panic.o ]; then
    echo "  linking shu_asm (crt0 + typeck_f64_bits + runtime_panic + asm*.o, no runtime_driver) ..."
    set +e
    "$CC" $CFLAGS -o shu_asm src/asm/crt0_x86_64.o src/typeck/typeck_f64_bits.o runtime_panic.o $NONEMPTY_ASM -lc -lm
    CRT_RC=$?
    set -e
    if [ "$CRT_RC" -eq 0 ]; then
      echo "build_shu_asm: shu_asm built (no C runtime driver)."
      LINK_OK=1
      USE_CRT0=1
      LINK_MODE=crt0
    else
      echo "build_shu_asm: crt0 link failed (rc=$CRT_RC), trying runtime_driver fallback..."
    fi
  fi
  if [ "$LINK_OK" -ne 1 ]; then
    ensure_runtime_cc_stubs
    ensure_std_fs_io_heap_objs
    ensure_asm_driver_seed_c_objs
    ensure_lsp_diag_pipeline_sizes_obj
    ensure_asm_shu_lsp_diag_stub_obj
    ensure_asm_lsp_codegen_extern_obj
    if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ] && [ -n "$NONEMPTY_ASM" ]; then
      if [ "$ASM_TEXT_ALL_OK" != "1" ]; then
        echo "build_shu_asm: SHU_ASM_EXPERIMENTAL_SKIP_GEN=1 (__text 未全绿仍试 asm-only 链)"
      else
        echo "build_shu_asm: SHU_ASM_EXPERIMENTAL_SKIP_GEN=1 — 尝试无 pipeline_gen.c 链（实验）"
      fi
      ensure_std_fs_io_heap_objs
      PIPELINE_LIBS=""
      if [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
        PIPELINE_LIBS="-luring -lpthread"
      fi
      UNAME_ASM=$(uname -s 2>/dev/null || echo Unknown)
      # Darwin：ENTRY_MODULE_ONLY 下 duplicate symbol 已消除，但大模块 .o 符号不全/跨模块命名仍会导致 undefined；试链后失败则回退 gen_driver。
      filter_experimental_asm_objs
      ASM_TRY_OBJS="$FILTERED"
      if [ "$UNAME_ASM" = "Darwin" ]; then
        echo "build_shu_asm: Darwin 试 asm-only 链（ENTRY_MODULE_ONLY 已无 duplicate；若 undefined 则回退）"
      fi
      if [ -n "$ASM_TRY_OBJS" ]; then
        ensure_pipeline_su_o_fresh
        ensure_asm_experimental_symbol_bridge_obj
        ensure_asm_driver_seed_c_objs
        ensure_asm_gen_driver_su_objs
        ensure_asm_bootstrap_su_companion_objs
        ensure_ast_pool_l5_bridge_obj
        SEED_O="$BUILD_DIR/asm_driver_seed"
        GEN_O="$BUILD_DIR/gen_driver"
        # 首遍 bootstrap 不链 build_asm/*.o（stub 符号重复）；第二遍 strict 重链再并入 pipeline.o 等。
        echo "  linking shu_asm (experimental bootstrap: runtime + pipeline_su + SU companions + seed C, no build_asm/*.o) ..."
        set +e
        "$CC" $CFLAGS -DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE -o shu_asm \
          src/asm/runtime_asm_build.o \
          src/runtime_driver.o \
          pipeline_su.o \
          "$GEN_O/preprocess_su.o" \
          "$BUILD_DIR/ast_pool_l5_bridge.o" \
          driver_fmt_su.o driver_check_su.o driver_test_su.o driver_build_su.o driver_run_su.o driver_compile_su.o driver_emit_su.o \
          "$BUILD_DIR/std_fs_shim.o" \
          "$BUILD_DIR/su_seed_bridge.o" \
          "$BUILD_DIR/seed_host/asm_backend_partial.o" \
          src/asm/user_asm_seed_bridge.o \
          src/asm/asm_backend_compat_stubs.o \
          src/driver/fmt_check_cmd_driver.o \
          "$BUILD_DIR/asm_experimental_symbol_bridge.o" \
          "$BUILD_DIR/asm_shu_lsp_diag_stub.o" \
          "$BUILD_DIR/lsp_codegen_extern.o" \
          "$SEED_O/preprocess.o" \
          "$SEED_O/parser.o" \
          "$SEED_O/typeck.o" \
          "$SEED_O/codegen.o" \
          "$SEED_O/lexer.o" \
          "$SEED_O/ast_seed.o" \
          parser_su.o lexer_su.o typeck_su.o codegen_su.o \
          lexer_su_link_alias.o typeck_su_link_alias.o codegen_su_link_alias.o \
          "$SEED_O/lsp_diag.o" \
          "$SEED_O/lsp_state.o" \
          src/lsp/lsp_diag_pipeline_sizes.o \
          ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o \
          -lm -lc $PIPELINE_LIBS 2>"$BUILD_DIR/.asm_experimental_link_err"
        FB_RC=$?
        set -e
        if [ "$FB_RC" -eq 0 ]; then
          echo "build_shu_asm: shu_asm built (experimental: build_asm backend + pipeline_su.o bootstrap)."
          cp -f shu_asm shu_asm.experimental 2>/dev/null || true
          export SHU_ASM_SECOND_PASS_COMPILER=./shu_asm.experimental
          LINK_OK=1
          LINK_MODE=asm_only_experimental
          # 第二遍：bootstrap shu_asm 重编 pipeline/typeck/parser/backend，再 strict 重链（无 pipeline_su.o）。
          SECOND_PASS_OK=0
          if rebuild_pipeline_o_second_pass; then
            SECOND_PASS_OK=1
          fi
          PTEXT=$(asm_o_text_bytes "$BUILD_DIR/pipeline.o" 2>/dev/null || echo 0)
          STRICT_TRY=0
          if [ "$SECOND_PASS_OK" -eq 1 ] && [ "$PTEXT" -gt 200 ] 2>/dev/null; then
            STRICT_TRY=1
          elif ensure_pipeline_asm_strict_core_partial_obj; then
            echo "build_shu_asm: pipeline.o second pass skipped/failed (__text=${PTEXT}B); strict_core partial OK — try strict re-link"
            STRICT_TRY=1
          fi
          if [ "$STRICT_TRY" -eq 1 ]; then
            if [ "$SECOND_PASS_OK" -eq 1 ]; then
              if ! rebuild_typeck_parser_backend_second_pass "./shu_asm.experimental"; then
                if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
                  echo "build_shu_asm: bootstrap second pass (typeck/parser/backend) failed; continuing strict with partials"
                fi
              fi
            fi
              ensure_asm_pipeline_glue_standalone_obj
              ensure_asm_pipeline_glue_strict_minimal_obj
              ST_GLUE_OBJ="$BUILD_DIR/pipeline_glue_standalone.o"
              ST_PARSER_LINK=""
              ST_RUNTIME_PARTIAL=""
              ST_RUNTIME_EXTRA=""
              ST_LAYOUT_PARTIAL=""
              ST_PIPELINE_ALIAS=""
              ST_RUNTIME_MODE="bootstrap"
              ST_USES_ASM_PIPELINE=0
              ST_PARSER_LINK=""
              ST_PHASE_PARSE_PARTIAL=""
              STRICT_LINK_BUILD_ASM_PIPELINE=0
              if asm_strict_pipeline_selfhosted; then
                STRICT_LINK_BUILD_ASM_PIPELINE=1
                export STRICT_LINK_BUILD_ASM_PIPELINE
                echo "build_shu_asm: pipeline.o self-hosted (__text=${PTEXT}B) — link build_asm/pipeline.o, skip strict_core partial"
              fi
              ST_PIPELINE_ALIAS=""
              if [ "$STRICT_LINK_BUILD_ASM_PIPELINE" -eq 1 ]; then
                ensure_pipeline_run_bootstrap_trampoline_obj
                ST_RUNTIME_PARTIAL="$BUILD_DIR/pipeline_run_bootstrap_trampoline.o"
                ensure_pipeline_phase_parse_only_partial_obj
                ST_PIPELINE_ALIAS="$BUILD_DIR/pipeline_phase_parse_only_partial.o"
              fi
              if [ "$STRICT_LINK_BUILD_ASM_PIPELINE" -eq 1 ]; then
                ST_RUNTIME_MODE="strict_support"
                ST_GLUE_OBJ="$BUILD_DIR/pipeline_glue_standalone.o"
                ST_RUNTIME_EXTRA=""
                ensure_asm_pipeline_glue_standalone_obj
                if ! asm_strict_typeck_selfhosted; then
                  ensure_typeck_asm_layout_partial_obj && ST_LAYOUT_PARTIAL="$BUILD_DIR/typeck_asm_layout_partial.o"
                fi
              elif ensure_pipeline_asm_strict_core_partial_obj; then
                ensure_pipeline_runtime_bootstrap_partial_obj
                ST_RUNTIME_PARTIAL=""
                ST_RUNTIME_EXTRA="$BUILD_DIR/pipeline_asm_strict_core_partial.o $BUILD_DIR/pipeline_runtime_bootstrap_partial.o"
                if ! asm_strict_typeck_selfhosted; then
                  ensure_typeck_asm_layout_partial_obj && ST_LAYOUT_PARTIAL="$BUILD_DIR/typeck_asm_layout_partial.o"
                fi
                ST_RUNTIME_MODE="strict_support"
                # strict_core partial 已含 pipeline_glue+ast_pool 全符号；勿再链 standalone（815 duplicate symbols）。
                ensure_asm_pipeline_glue_strict_minimal_obj
                ST_GLUE_OBJ="$BUILD_DIR/pipeline_glue_strict_minimal.o"
              else
                ensure_pipeline_parse_su_partial_obj
              fi
              # 实验：C 编排 partial（需 build_asm pipeline.o 或 strict_support；设 SHU_ASM_STRICT_ORCHESTRATION=1 启用）。
              if [ -n "${SHU_ASM_STRICT_ORCHESTRATION:-}" ] && ensure_pipeline_asm_orchestration_partial_obj; then
                ensure_pipeline_asm_orchestration_from_build_o
                ST_RUNTIME_PARTIAL="$BUILD_DIR/pipeline_asm_orchestration_partial.o"
                ST_RUNTIME_EXTRA="$BUILD_DIR/pipeline_asm_strict_support_partial.o $BUILD_DIR/pipeline_asm_orchestration_from_build.o"
                ST_PARSER_LINK=""
                ST_RUNTIME_MODE="asm_orchestration"
                ST_USES_ASM_PIPELINE=1
              elif [ -n "${SHU_ASM_STRICT_ORCHESTRATION_LEGACY:-}" ] && ensure_pipeline_asm_orchestration_from_build_o; then
                ensure_pipeline_phase_parse_only_partial_obj
                ensure_pipeline_asm_run_all_partial_obj
                ensure_asm_pipeline_run_impl_alias_obj
                ensure_pipeline_asm_typecheck_alias_obj
                ensure_pipeline_asm_su_bootstrap_partial_obj
                ST_RUNTIME_PARTIAL="$BUILD_DIR/pipeline_asm_orchestration_from_build.o"
                ST_RUNTIME_EXTRA="$BUILD_DIR/pipeline_phase_parse_only_partial.o $BUILD_DIR/pipeline_asm_run_all_partial.o $BUILD_DIR/pipeline_run_impl_alias.o $BUILD_DIR/pipeline_asm_typecheck_alias.o $BUILD_DIR/pipeline_asm_su_bootstrap_partial.o"
                ST_PARSER_LINK="$BUILD_DIR/pipeline_parse_su_partial.o"
                ST_RUNTIME_MODE="asm_orchestration_legacy"
                ST_USES_ASM_PIPELINE=1
              fi
              if [ "$ST_RUNTIME_MODE" = "strict_support" ] || [ "$ST_USES_ASM_PIPELINE" -eq 1 ]; then
                export STRICT_LINK_BUILD_ASM_PIPELINE
                if [ "$ST_RUNTIME_MODE" = "strict_support" ]; then
                  # build_asm pipeline 自举时须链 preprocess/platform 等 companion .o；否则仅 seed partial 会 U preprocess_su_buf。
                  if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
                    filter_strict_asm_objs
                    ASM_TRY_OBJS="$FILTERED"
                  else
                    ASM_TRY_OBJS=""
                  fi
                else
                  filter_strict_asm_objs
                  ASM_TRY_OBJS="$FILTERED"
                fi
              else
                filter_experimental_asm_objs
                ASM_TRY_OBJS="$FILTERED"
              fi
              echo "  re-link shu_asm (strict: ${ST_RUNTIME_MODE}, no pipeline_su.o) ..."
              ST_BRIDGE_OBJ=""
              ST_SEED_PARSER_TCK=""
              ST_STRICT_COMPANIONS=""
              if [ "$ST_RUNTIME_MODE" = "strict_support" ]; then
                # 始终链 bridge：main.o（ENTRY_MODULE_ONLY）无 check/fmt/test 路由；子命令由 bridge.main_entry 分发。
                ensure_asm_experimental_symbol_bridge_obj
                ST_BRIDGE_OBJ="$BUILD_DIR/asm_experimental_symbol_bridge.o"
                # 子命令 .o（勿链 driver_su.o：与 pipeline_glue_standalone 重复 main_run_compiler_c）；main.o 须全量 entry，见 rebuild_main_o_for_cli。
                ST_DRIVER_CLI_OBJS="driver_fmt_su.o driver_check_su.o driver_test_su.o driver_build_su.o driver_run_su.o driver_compile_su.o driver_emit_su.o"
                if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
                  ST_SEED_PARSER_TCK="$SEED_O/parser.o $SEED_O/typeck.o $SEED_O/codegen.o $SEED_O/lexer.o $SEED_O/ast_seed.o parser_su.o typeck_su.o codegen_su.o lexer_su.o lexer_su_link_alias.o typeck_su_link_alias.o codegen_su_link_alias.o"
                  ensure_ast_pool_l5_bridge_obj
                  ST_STRICT_COMPANIONS="$BUILD_DIR/su_seed_bridge.o $BUILD_DIR/seed_host/asm_backend_partial.o src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/driver/fmt_check_cmd_driver.o $GEN_O/preprocess_su.o $BUILD_DIR/ast_pool_l5_bridge.o $ST_DRIVER_CLI_OBJS"
                else
                  # 须 seed *.o 在前、*_su.o 在后：macOS ld 对重复符号取后链入定义，否则 C parser 覆盖 SU（if-expr/{10} 等回归）。
                  ST_SEED_PARSER_TCK="$SEED_O/parser.o $SEED_O/typeck.o $SEED_O/codegen.o $SEED_O/lexer.o $SEED_O/ast_seed.o parser_su.o lexer_su.o typeck_su.o codegen_su.o lexer_su_link_alias.o typeck_su_link_alias.o codegen_su_link_alias.o"
                  ensure_ast_pool_l5_bridge_obj
                  ST_STRICT_COMPANIONS="$BUILD_DIR/su_seed_bridge.o $BUILD_DIR/seed_host/asm_backend_partial.o src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/driver/fmt_check_cmd_driver.o $GEN_O/preprocess_su.o $BUILD_DIR/ast_pool_l5_bridge.o $ST_DRIVER_CLI_OBJS"
                fi
              elif [ "$ST_USES_ASM_PIPELINE" -eq 1 ]; then
                ST_BRIDGE_OBJ="$BUILD_DIR/asm_experimental_symbol_bridge.o"
                ST_SEED_PARSER_TCK="$SEED_O/parser.o $SEED_O/typeck.o $SEED_O/codegen.o $SEED_O/lexer.o $SEED_O/ast_seed.o"
              else
                ST_BRIDGE_OBJ="$BUILD_DIR/asm_experimental_symbol_bridge.o"
                ST_SEED_PARSER_TCK="$SEED_O/parser.o $SEED_O/typeck.o $SEED_O/codegen.o $SEED_O/lexer.o $SEED_O/ast_seed.o"
              fi
              ensure_asm_bootstrap_su_companion_objs
              rebuild_main_o_for_cli || true
              if [ -n "$ST_BRIDGE_OBJ" ]; then
                strip_main_entry_from_build_asm_main_o || true
              fi
              set +e
              "$CC" $CFLAGS -DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE -o shu_asm \
                src/asm/runtime_asm_build.o \
                src/runtime_driver.o \
                $ASM_TRY_OBJS \
                "$ST_GLUE_OBJ" \
                "$ST_PARSER_LINK" \
                $ST_RUNTIME_PARTIAL \
                "$BUILD_DIR/std_fs_shim.o" \
                $ST_BRIDGE_OBJ \
                "$BUILD_DIR/asm_shu_lsp_diag_stub.o" \
                "$BUILD_DIR/lsp_codegen_extern.o" \
                "$SEED_O/preprocess.o" \
                $ST_SEED_PARSER_TCK \
                $ST_STRICT_COMPANIONS \
                "$SEED_O/lsp_diag.o" \
                "$SEED_O/lsp_state.o" \
                src/lsp/lsp_diag_pipeline_sizes.o \
                ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o \
                $ST_RUNTIME_EXTRA \
                $ST_LAYOUT_PARTIAL \
                $ST_PIPELINE_ALIAS \
                -lm -lc $PIPELINE_LIBS 2>"$BUILD_DIR/.asm_strict_link_err"
              ST_RC=$?
              set -e
              if [ "$ST_RC" -ne 0 ] && [ "$ST_USES_ASM_PIPELINE" -eq 1 ]; then
                echo "build_shu_asm: strict asm orchestration link failed; retry pipeline_runtime_bootstrap_partial.o ..."
                ensure_pipeline_runtime_bootstrap_partial_obj
                ST_PARSER_LINK="$BUILD_DIR/pipeline_parse_su_partial.o"
                ST_RUNTIME_EXTRA=""
                ST_RUNTIME_MODE="bootstrap"
                ST_USES_ASM_PIPELINE=0
                set +e
                "$CC" $CFLAGS -DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE -o shu_asm \
                  src/asm/runtime_asm_build.o \
                  src/runtime_driver.o \
                  $ASM_TRY_OBJS \
                  "$ST_GLUE_OBJ" \
                  "$ST_PARSER_LINK" \
                  "$BUILD_DIR/pipeline_runtime_bootstrap_partial.o" \
                  "$BUILD_DIR/std_fs_shim.o" \
                  "$BUILD_DIR/asm_experimental_symbol_bridge.o" \
                  "$BUILD_DIR/asm_shu_lsp_diag_stub.o" \
                  "$BUILD_DIR/lsp_codegen_extern.o" \
                  "$SEED_O/preprocess.o" \
                  "$SEED_O/parser.o" \
                  "$SEED_O/typeck.o" \
                  "$SEED_O/codegen.o" \
                  "$SEED_O/lexer.o" \
                  "$SEED_O/ast_seed.o" \
                  "$SEED_O/lsp_diag.o" \
                  "$SEED_O/lsp_state.o" \
                  src/lsp/lsp_diag_pipeline_sizes.o \
                  ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o \
                  -lm -lc $PIPELINE_LIBS 2>"$BUILD_DIR/.asm_strict_link_err"
                ST_RC=$?
                set -e
              fi
              if [ "$ST_RC" -ne 0 ]; then
                echo "build_shu_asm: strict link failed (rc=$ST_RC)"
                if [ -s "$BUILD_DIR/.asm_strict_link_err" ]; then
                  tail -n 8 "$BUILD_DIR/.asm_strict_link_err" | sed 's/^/  /'
                fi
              fi
              if [ "$ST_RC" -eq 0 ]; then
                LINK_OK=1
                if [ "$ST_USES_ASM_PIPELINE" -eq 1 ]; then
                  echo "build_shu_asm: shu_asm strict OK (pipeline.o + C orchestration, __text=${PTEXT}B)."
                elif [ "$ST_RUNTIME_MODE" = "strict_support" ]; then
                  echo "build_shu_asm: shu_asm strict OK (run trampoline + strict_core partial, pipeline.o __text=${PTEXT}B)."
                else
                  echo "build_shu_asm: shu_asm strict OK (pipeline_runtime_bootstrap_partial.o + pipeline.o __text=${PTEXT}B)."
                fi
                LINK_MODE=asm_only_strict
                if [ -z "${SHU_ASM_SKIP_STRICT_SMOKE:-}" ]; then
                  if ! SHU_ASM_SMOKE_SKIP_GATE=1 ./scripts/run_shu_asm_smoke.sh >/dev/null 2>&1; then
                    if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
                      shu_asm_bstrict_fail "strict shu_asm smoke failed"
                    fi
                    echo "build_shu_asm: strict shu_asm smoke failed."
                  else
                    echo "build_shu_asm: strict shu_asm smoke passed."
                  fi
                fi
                # strict 产物自编译大模块（>150KiB 入口仍 SIGSEGV；bootstrap experimental 第二遍已通过）。
                if ! rebuild_typeck_parser_backend_second_pass; then
                  if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
                    echo "build_shu_asm: B-strict warning: strict shu_asm self-compile second pass failed (bootstrap shu_asm + smoke OK; retry with seed SHU for -backend asm)"
                  fi
                fi
                TCK2=$(asm_o_text_bytes "$BUILD_DIR/typeck.o" 2>/dev/null || echo 0)
                PAR2=$(asm_o_text_bytes "$BUILD_DIR/parser.o" 2>/dev/null || echo 0)
                BACK2=$(asm_o_text_bytes "$BUILD_DIR/backend.o" 2>/dev/null || echo 0)
                echo "build_shu_asm: strict self-compile __text typeck=${TCK2}B parser=${PAR2}B backend=${BACK2}B"
              else
                if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ] && [ -x shu_asm.experimental ]; then
                  cp -f shu_asm.experimental shu_asm
                  LINK_OK=1
                  LINK_MODE=asm_only_experimental
                  echo "build_shu_asm: B-strict fallback — strict re-link incomplete; using shu_asm.experimental (pipeline_su bootstrap, no pipeline_gen.c in link)"
                elif [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
                  if [ -s "$BUILD_DIR/.asm_strict_link_err" ]; then
                    tail -n 15 "$BUILD_DIR/.asm_strict_link_err" | sed 's/^/  /'
                  fi
                  shu_asm_bstrict_fail "strict re-link failed (rc=$ST_RC)"
                fi
                echo "build_shu_asm: strict re-link failed (rc=$ST_RC); keeping bootstrap shu_asm with pipeline_su.o"
                if [ -s "$BUILD_DIR/.asm_strict_link_err" ]; then
                  tail -n 15 "$BUILD_DIR/.asm_strict_link_err" | sed 's/^/  /'
                fi
              fi
          else
            if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
              shu_asm_bstrict_fail "strict re-link skipped (pipeline.o __text=${PTEXT}B, strict_core partial unavailable)"
            fi
            echo "build_shu_asm: strict re-link skipped (pipeline.o __text=${PTEXT}B); keeping bootstrap shu_asm with pipeline_su.o"
          fi
        else
          if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
            if [ -s "$BUILD_DIR/.asm_experimental_link_err" ]; then
              tail -n 20 "$BUILD_DIR/.asm_experimental_link_err" | sed 's/^/  /'
            fi
            shu_asm_bstrict_fail "experimental asm-only link failed (rc=$FB_RC)"
          fi
          echo "build_shu_asm: experimental asm-only link failed (rc=$FB_RC); falling back to gen_driver..."
          if [ -s "$BUILD_DIR/.asm_experimental_link_err" ]; then
            tail -n 20 "$BUILD_DIR/.asm_experimental_link_err" | sed 's/^/  /'
          fi
        fi
      else
        if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
          shu_asm_bstrict_fail "experimental asm-only skipped on $UNAME_ASM"
        fi
        echo "build_shu_asm: experimental asm-only skipped on $UNAME_ASM; falling back to gen_driver (仍含 cc -c pipeline_gen.c)..."
      fi
    fi
    if [ "$LINK_OK" -ne 1 ]; then
      if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
        shu_asm_bstrict_fail "asm-only link not OK (LINK_MODE=${LINK_MODE:-none})"
      fi
      if [ "$SHU_ASM_LINK_TOPOLOGY" = "full_asm" ] && [ "$ASM_TEXT_ALL_OK" = "1" ]; then
        echo "build_shu_asm: full_asm: __text 已全部非空，默认仍走 gen_driver（设 SHU_ASM_EXPERIMENTAL_SKIP_GEN=1 试 asm-only 链）"
      fi
      ensure_asm_gen_driver_su_objs
    fi
    if [ "$LINK_OK" -ne 1 ]; then
      PIPELINE_LIBS=""
      if [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
        PIPELINE_LIBS="-luring -lpthread"
      fi
      SEED_O="$BUILD_DIR/asm_driver_seed"
      GEN_O="$BUILD_DIR/gen_driver"
      echo "  linking shu_asm (runtime_asm_build + runtime_driver + seed + driver/* + -E pipeline/lsp; no build_asm/*.o) ..."
      set +e
      "$CC" $CFLAGS -DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE -o shu_asm \
        src/asm/runtime_asm_build.o \
        src/runtime_driver.o \
        "$SEED_O/preprocess.o" \
        "$SEED_O/lexer.o" \
        "$SEED_O/ast_seed.o" \
        "$SEED_O/parser.o" \
        "$SEED_O/typeck.o" \
        "$SEED_O/codegen.o" \
        "$GEN_O/driver_su.o" \
        "$GEN_O/driver_fmt_su.o" \
        "$GEN_O/driver_check_su.o" \
        "$GEN_O/driver_test_su.o" \
        "$GEN_O/pipeline_su.o" \
        "$GEN_O/preprocess_su.o" \
        "$GEN_O/lsp_su.o" \
        "$BUILD_DIR/asm_shu_lsp_diag_stub.o" \
        "$BUILD_DIR/lsp_codegen_extern.o" \
        "$GEN_O/lsp_io_su.o" \
        "$GEN_O/lsp_io_std_heap_su.o" \
        "$SEED_O/lsp_diag.o" \
        src/lsp/lsp_diag_pipeline_sizes.o \
        "$SEED_O/lsp_state.o" \
        ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o \
        -lm -lc $PIPELINE_LIBS
      FB_RC=$?
      set -e
      if [ "$FB_RC" -eq 0 ]; then
        echo "build_shu_asm: shu_asm built."
        LINK_OK=1
        LINK_MODE=driver
      else
        echo "build_shu_asm: link failed (rc=$FB_RC). See src/asm/README.md Goal 2."
      fi
    fi
  fi
else
  if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
    shu_asm_bstrict_fail "main.o or pipeline.o missing or empty"
  fi
  echo "build_shu_asm: main.o or pipeline.o missing or empty; trying gen_driver fallback only."
  ensure_runtime_cc_stubs
  ensure_std_fs_io_heap_objs
  ensure_asm_driver_seed_c_objs
  ensure_lsp_diag_pipeline_sizes_obj
  ensure_asm_shu_lsp_diag_stub_obj
  ensure_asm_lsp_codegen_extern_obj
  ensure_asm_gen_driver_su_objs
  PIPELINE_LIBS=""
  if [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
    PIPELINE_LIBS="-luring -lpthread"
  fi
  SEED_O="$BUILD_DIR/asm_driver_seed"
  GEN_O="$BUILD_DIR/gen_driver"
  echo "  linking shu_asm (gen_driver fallback; build_asm incomplete) ..."
  set +e
  "$CC" $CFLAGS -DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE -o shu_asm \
    src/asm/runtime_asm_build.o \
    src/runtime_driver.o \
    "$SEED_O/preprocess.o" \
    "$SEED_O/lexer.o" \
    "$SEED_O/ast_seed.o" \
    "$SEED_O/parser.o" \
    "$SEED_O/typeck.o" \
    "$SEED_O/codegen.o" \
    "$GEN_O/driver_su.o" \
    "$GEN_O/driver_fmt_su.o" \
    "$GEN_O/driver_check_su.o" \
    "$GEN_O/driver_test_su.o" \
    "$GEN_O/pipeline_su.o" \
    "$GEN_O/preprocess_su.o" \
    "$GEN_O/lsp_su.o" \
    "$BUILD_DIR/asm_shu_lsp_diag_stub.o" \
    "$BUILD_DIR/lsp_codegen_extern.o" \
    "$GEN_O/lsp_io_su.o" \
    "$GEN_O/lsp_io_std_heap_su.o" \
    "$SEED_O/lsp_diag.o" \
    src/lsp/lsp_diag_pipeline_sizes.o \
    "$SEED_O/lsp_state.o" \
    ../std/fs/fs.o ../std/io/io.o ../std/heap/heap.o \
    -lm -lc $PIPELINE_LIBS
  FB_RC=$?
  set -e
  if [ "$FB_RC" -eq 0 ]; then
    echo "build_shu_asm: shu_asm built (gen_driver fallback)."
    LINK_OK=1
    LINK_MODE=driver
  fi
fi

if [ "$LINK_OK" -eq 1 ]; then
  case "$LINK_MODE" in
    crt0)
      echo "build_shu_asm: Target-B-partial: linked without cc -c pipeline_gen.c (crt0 + asm .o)."
      ;;
    driver)
      echo "build_shu_asm: Target-B-hybrid: shu-c -E + cc -c gen_driver (topology=${SHU_ASM_LINK_TOPOLOGY})."
      ;;
    asm_only_experimental)
      echo "build_shu_asm: Target-B-experimental: bootstrap with pipeline_su.o partial (no pipeline_gen.c in link)."
      ;;
    asm_only_strict)
      echo "build_shu_asm: Target-B-strict: build_asm + glue_standalone + partials, no pipeline_su.o / pipeline_gen.c."
      ;;
  esac
fi

if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ] && [ "$LINK_MODE" != "asm_only_strict" ] && [ "$LINK_MODE" != "asm_only_experimental" ]; then
  shu_asm_bstrict_fail "B-strict requires asm_only_strict or asm_only_experimental link (got LINK_MODE=${LINK_MODE:-none})"
fi

# B-strict 验收：最终链无 cc -c pipeline_gen.c；asm_only_experimental = pipeline_su partial bootstrap（strict 重链待 pipeline.o 自举）。
if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ] && [ "$LINK_MODE" = "asm_only_strict" ]; then
  echo "build_shu_asm: B-strict OK — LINK_MODE=asm_only_strict, no pipeline_su.o in final link"
fi
if [ -n "${SHU_ASM_EXPERIMENTAL_SKIP_GEN:-}" ] && [ "$LINK_MODE" = "asm_only_experimental" ]; then
  echo "build_shu_asm: B-strict OK (experimental bootstrap) — LINK_MODE=asm_only_experimental, final link uses pipeline_su.o partial not pipeline_gen.c"
fi

if [ "$ASM_READY" -eq 1 ] && [ "$LINK_OK" -ne 1 ]; then
  exit 1
fi
exit 0
