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
SHU="${SHU:-./shu}"
BUILD_LIST_SU="src/asm/asm_build_list.su"
BUILD_DIR="build_asm"
mkdir -p "$BUILD_DIR"

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

# 按依赖顺序尝试编译各 .su 为 .o（顺序由 asm_build_list.su 的 // BUILD: 行定义）
# SKIP 表示该次 -backend asm -o 编译失败（命令非零退出）；默认保留 stderr，可直接看到失败原因（如 asm_codegen_elf_o failed）。
# 常见原因：asm_codegen_elf_o 内某步失败，或 pipeline 解析/类型检查/codegen 失败。若需静默可设 SHU_ASM_QUIET=1。
compile_su() {
  local out="$BUILD_DIR/$1"
  local src="$2"
  printf "  asm %s -> %s ... " "$src" "$out"
  if [ -n "${SHU_ASM_QUIET}" ]; then
    if "$SHU" -backend asm -o "$out" $LIBROOT "$src" 2>/dev/null; then echo OK; else echo SKIP; fi
  else
    if "$SHU" -backend asm -o "$out" $LIBROOT "$src"; then echo OK; else echo SKIP; fi
  fi
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
CC="${CC:-cc}"
CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"

# 与 Makefile PIPELINE_GEN_CFLAGS 对齐：编译 -E 大文件时压制已知告警；Clang 追加额外 -Wno。
detect_pipeline_gen_cflags() {
  PIPELINE_GEN_CFLAGS="-Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits"
  if "$CC" -v 2>&1 | grep -qi clang; then
    PIPELINE_GEN_CFLAGS="$PIPELINE_GEN_CFLAGS -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses -Wno-incompatible-pointer-types-discards-qualifiers"
  fi
}

# 收集非空 build_asm/*.o（空文件多为 asm SKIP 残留）
build_nonempty_asm_objs() {
  NONEMPTY_ASM=""
  for o in "$BUILD_DIR"/*.o; do
    [ -f "$o" ] || continue
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

# bootstrap-driver-seed 同款的 C 种子 .o：与 pipeline_su.o 并存时不链完整 ast.c（用 -DSHU_USE_SU_AST 的 ast_seed）。
ensure_asm_driver_seed_c_objs() {
  SEED_DIR="$BUILD_DIR/asm_driver_seed"
  mkdir -p "$SEED_DIR"
  echo "  cc -c asm_driver_seed/*.o <- preprocess/lexer/ast_seed/parser/typeck/codegen/lsp_diag/lsp_state .c"
  "$CC" $CFLAGS -c -o "$SEED_DIR/preprocess.o" src/preprocess.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/lexer.o" src/lexer/lexer.c
  "$CC" $CFLAGS -DSHU_USE_SU_AST -c -o "$SEED_DIR/ast_seed.o" src/ast/ast.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/parser.o" src/parser/parser.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/typeck.o" src/typeck/typeck.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/codegen.o" src/codegen/codegen.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/lsp_diag.o" src/lsp/lsp_diag.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/lsp_state.o" src/lsp/lsp_state.c
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
  LIB_E_MAIN="-L .. -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess"

  echo "  $SHU_E -E pipeline.su -> $GEN_DIR/pipeline_gen.c ..."
  "$SHU_E" $LIB_E_PIPELINE src/pipeline/pipeline.su -E >"$GEN_DIR/pipeline_gen.c"
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
  echo "  $SHU_E -E preprocess.su (-E-extern) -> $GEN_DIR/preprocess_gen.c ..."
  "$SHU_E" -L src/lexer -E -E-extern src/preprocess/preprocess.su >"$GEN_DIR/preprocess_gen.c"

  echo "  cc -c gen_driver/*_su.o <- pipeline/driver/lsp/preprocess -E 产物"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I.. \
    -Dstd_io_driver_driver_read_ptr_len=shu_io_read_ptr_len \
    -Dstd_io_driver_driver_read_ptr=shu_io_read_ptr \
    -c "$GEN_DIR/pipeline_gen.c" -o "$GEN_DIR/pipeline_su.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Dstd_io_read=io_read -Dstd_io_write=io_write \
    -c "$GEN_DIR/lsp_io_gen.c" -o "$GEN_DIR/lsp_io_su.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -c "$GEN_DIR/lsp_gen.c" -o "$GEN_DIR/lsp_su.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
    -c "$GEN_DIR/lsp_io_std_heap_gen.c" -o "$GEN_DIR/lsp_io_std_heap_su.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS \
    -Dstd_fs_fs_read=fs_posix_read_c -Dstd_fs_fs_write=fs_posix_write_c -Dstd_fs_fs_close=fs_posix_close_c \
    -c "$GEN_DIR/driver_gen.c" -o "$GEN_DIR/driver_su.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -c "$GEN_DIR/preprocess_gen.c" -o "$GEN_DIR/preprocess_su.o"
}

# 回退链接所需的 C 桩（不依赖 make）
ensure_runtime_cc_stubs() {
  echo "  cc -c src/asm/runtime_asm_build.o <- src/asm/runtime_asm_build.c"
  "$CC" $CFLAGS -c -o src/asm/runtime_asm_build.o src/asm/runtime_asm_build.c
  echo "  cc -c src/runtime_driver.o <- src/runtime.c (-DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE)"
  "$CC" $CFLAGS -DSHU_USE_SU_DRIVER -DSHU_USE_SU_PIPELINE -c -o src/runtime_driver.o src/runtime.c
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
  if [ -f src/asm/crt0_x86_64.s ]; then
    echo "  cc -c src/asm/crt0_x86_64.o <- src/asm/crt0_x86_64.s"
    "$CC" -c -o src/asm/crt0_x86_64.o src/asm/crt0_x86_64.s
  fi
  if [ "$UNAME_S" = "Linux" ] && [ -f src/typeck/typeck_f64_bits_x86_64.s ]; then
    echo "  cc -c src/typeck/typeck_f64_bits.o <- typeck_f64_bits_x86_64.s"
    "$CC" -c -o src/typeck/typeck_f64_bits.o src/typeck/typeck_f64_bits_x86_64.s
  else
    echo "  cc -c src/typeck/typeck_f64_bits.o <- typeck_f64_bits.c"
    "$CC" $CFLAGS -c -o src/typeck/typeck_f64_bits.o src/typeck/typeck_f64_bits.c
  fi
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
  if [ "$UNAMES" != "Linux" ]; then
    echo "build_shu_asm: host=$UNAMES: topology pipeline_su (non-Linux hosts: crt0/B-partial ELF path not wired; hybrid only; docs/SELFHOST.md §4)"
  elif [ "$ASM_TEXT_ALL_OK" = "1" ]; then
    SHU_ASM_LINK_TOPOLOGY=full_asm
    echo "build_shu_asm: auto SHU_ASM_LINK_TOPOLOGY=full_asm (Linux, all BUILD objects non-empty __text)"
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
  if [ "$(uname -s 2>/dev/null)" = "Linux" ] && [ -f src/asm/crt0_x86_64.o ] && [ -f src/typeck/typeck_f64_bits.o ] && [ -f runtime_panic.o ]; then
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
    if [ "$SHU_ASM_LINK_TOPOLOGY" = "full_asm" ] && [ "$ASM_TEXT_ALL_OK" = "1" ]; then
      echo "build_shu_asm: full_asm: __text 已全部非空，但默认仍生成 gen_driver（单一 full_asm 链接未默认启用）；见 docs/SELFHOST.md。"
    fi
    ensure_asm_gen_driver_su_objs
    PIPELINE_LIBS=""
    if [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
      PIPELINE_LIBS="-luring -lpthread"
    fi
    SEED_O="$BUILD_DIR/asm_driver_seed"
    GEN_O="$BUILD_DIR/gen_driver"
    echo "  linking shu_asm (runtime_asm_build + runtime_driver + seed + -E driver/pipeline/lsp; no build_asm/*.o) ..."
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
      "$GEN_O/pipeline_su.o" \
      "$GEN_O/preprocess_su.o" \
      "$GEN_O/lsp_su.o" \
      "$GEN_O/lsp_io_su.o" \
      "$GEN_O/lsp_io_std_heap_su.o" \
      "$SEED_O/lsp_diag.o" \
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
else
  echo "build_shu_asm: main.o or pipeline.o missing or empty; asm link skipped."
fi

# 目标 B 语义：crt0 路径未使用 pipeline_gen.c；driver 回退路径为 B-hybrid（见 docs/SELFHOST.md）
if [ "$ASM_READY" -eq 1 ] && [ "$LINK_OK" -eq 1 ]; then
  case "$LINK_MODE" in
    crt0)
      echo "build_shu_asm: Target-B-partial: linked without cc -c pipeline_gen.c (crt0 + asm .o)."
      ;;
    driver)
      echo "build_shu_asm: Target-B-hybrid: shu-c -E + cc -c gen_driver (topology=${SHU_ASM_LINK_TOPOLOGY})."
      ;;
  esac
fi

if [ "$ASM_READY" -eq 1 ] && [ "$LINK_OK" -ne 1 ]; then
  exit 1
fi
exit 0
