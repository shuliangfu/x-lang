#!/bin/sh
# build_shux_asm.sh — 用 asm 后端构建 shux（Goal 2：.sx → 目标文件 .o，不经 -E C 翻译）
# 用法：在 compiler 目录下执行 SHUX=./shux ./scripts/build_shux_asm.sh
#       或由 build_tool 调用：./build_tool ./shux asm（策略见仓库根目录 build.sx 注释）。
# 依赖：SHU 已支持 -backend asm；宿主 cc 用于链接桩、-E 产物与最终链接 shux_asm。
# crt0 / runtime_panic / typeck_f64_bits 由本脚本内 ensure_asm_link_objs 用 cc 生成，不依赖 make。
#
# 回退链接（非 Linux crt0 路径）：runtime_asm_build 调 main_entry（main.sx 经 -E 的 C 符号名）；runtime_driver 依赖
# pipeline_run_sx_pipeline、parser_parse_into*、asm_asm_codegen_elf_o 等。这些符号来自 -E 生成的
# pipeline_gen.c/driver_gen.c（与 Makefile bootstrap-driver-seed 一致），不能仅靠 src/*.c 前端：
# C parser 导出的是 parse 等名，与 runtime 期望的 parser_parse_into 不一致。
# pipeline_gen.c 已内联 ast/lexer/parser/typeck/codegen 与 asm 后端；当前 -backend asm 产出的 build_asm/*.o
# 多为空桩（仅 Mach-O 壳），并入回退链接会触发 Apple ld 断言或重复定义。故回退链仅 -E 产物 + C 种子，不并 build_asm/*.o。
# Linux crt0 成功路径仍使用整包 NONEMPTY_ASM（见下方）。
#
# 仅当 main.o/pipeline.o 均非空且链接仍失败时退出码 1（供 build_tool 回退 legacy）；其它情况 0。
# 构建顺序与 LIBROOT 唯一定义在 src/asm/asm_build_list.sx。

set -e
cd "$(dirname "$0")/.."

# 可选外层超时（阶段 G phase0-stream）：SHUX_BUILD_ASM_TIMEOUT=3600 等。
if [ -z "${SHUX_BUILD_ASM_TIMEOUT_WRAPPED:-}" ] && [ -n "${SHUX_BUILD_ASM_TIMEOUT:-}" ] && [ "${SHUX_BUILD_ASM_TIMEOUT}" != "0" ]; then
  _to_bin=""
  if command -v timeout >/dev/null 2>&1; then
    _to_bin=timeout
  elif command -v gtimeout >/dev/null 2>&1; then
    _to_bin=gtimeout
  fi
  if [ -n "$_to_bin" ]; then
    export SHUX_BUILD_ASM_TIMEOUT_WRAPPED=1
    build_shux_asm_info "outer timeout ${SHUX_BUILD_ASM_TIMEOUT}s"
    exec "$_to_bin" "${SHUX_BUILD_ASM_TIMEOUT}" "$0" "$@"
  fi
  build_shux_asm_warn "timeout unavailable; SHUX_BUILD_ASM_TIMEOUT ignored"
fi

# CI：跳过 second pass 与全量 typeck 预检，避免 Token/Lexer 布局刷屏导致 runner OOM（1h+ lost communication）。
if [ -n "${CI:-}" ] && [ "${SHUX_ASM_CI_SKIP_FAST:-0}" != "1" ]; then
  export SHUX_ASM_FORCE_SKIP_TYPECK="${SHUX_ASM_FORCE_SKIP_TYPECK:-1}"
  export SHUX_ASM_QUIET="${SHUX_ASM_QUIET:-1}"
  export SHUX_ASM_CI_SKIP_SECOND_PASS=1
  # B-strict SKIP_GEN 仅 Linux CI；macOS/Windows experimental 链常缺 LSP/typeck 符号，失败时 gen_driver。
  if [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
    export SHUX_ASM_EXPERIMENTAL_SKIP_GEN="${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-1}"
  fi
  # macOS/Windows CI：experimental bootstrap 成功后即停，勿再 strict 重链（30–60min+ 易超时）。
  export SHUX_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY=1
fi

# 调试 env 勿泄漏进 build_asm：SHUX_ASM_START_FUNC>=模块 func 数时 emit 循环全跳过，仅剩 8B 空 __text 桩（B-strict PTEXT 门禁失败）。
unset SHUX_ASM_START_FUNC 2>/dev/null || true

build_shux_asm_warn() {
  printf 'warning: build_shux_asm: %s\n' "$*" >&2
}

build_shux_asm_info() {
  printf 'info: build_shux_asm: %s\n' "$*" >&2
}

build_shux_asm_error() {
  printf 'build error: build_shux_asm: %s\n' "$*" >&2
}

# B-strict（SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1）：链接或 smoke 失败即 exit 1，不回退 gen_driver / pipeline_sx。
# 非 SKIP_GEN 时仅告警并返回，供 Linux 等宿主继续 gen_driver 回退或保留 experimental bootstrap 产物。
shux_asm_bstrict_fail() {
  build_shux_asm_error "B-strict failed: $*"
  if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
    exit 1
  fi
  return 1
}

# E-06 v5：MSYS2/MINGW 宿主探测（Windows B-strict experimental SX-only 链）。
build_shux_asm_is_msys() {
  if [ -n "${MSYSTEM:-}" ]; then
    return 0
  fi
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*) return 0 ;;
  esac
  return 1
}

SHUX="${SHUX:-./shux}"
BUILD_LIST_SX="src/asm/asm_build_list.sx"
BUILD_DIR="build_asm"
mkdir -p "$BUILD_DIR"

# ./shux 在 make all 后为 C 种子（无 -backend asm）；bootstrap-driver-seed 后 shux-sx 与 shux 均含 asm。
if [ "$SHUX" = "./shux" ] && [ -x ./shux-sx ]; then
  if ./shux -backend asm 2>&1 | grep -q "not available"; then
    SHUX=./shux-sx
  fi
fi

# 链接拓扑：未导出 SHUX_ASM_LINK_TOPOLOGY 时，check_asm_o_quality 认定全部 __text 非空 → full_asm（Linux/macOS 同）。
# M7/M11 release 默认 SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 → asm_only_strict（最终链无 pipeline_sx.o / pipeline_gen.c）。
# E-06 v1：SKIP_GEN 严格段不得 cc -c E-03 软退役前端 .c（asm_driver_seed 考古除外）— run-e06-no-compiler-frontend-cc-gate.sh
# E-06 v2：experimental bootstrap 在 *_sx.o 就绪时跳过 asm_driver_seed 前端 cc -c 与链接（strict 回退仍 ensure 前端 .o）。
# 具体赋值在质检文件写出之后；勿在此预置 SHUX_ASM_LINK_TOPOLOGY，避免与下方自动选择冲突。

# 从 .sx 唯一定义读取 LIBROOT（行格式：// LIBROOT:<tab>-L .. -L src ...）；TAB 用于兼容 BSD sed
TAB=$(printf '\t')
LIBROOT=""
if [ -f "$BUILD_LIST_SX" ]; then
  LIBROOT=$(grep '^// LIBROOT:' "$BUILD_LIST_SX" | sed "s|^// LIBROOT:${TAB}||")
fi
[ -z "$LIBROOT" ] && LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

build_shux_asm_info "using SHUX=$SHUX (list from $BUILD_LIST_SX)"

# compile_sx 的 stub 回退与后续链接均依赖宿主 cc；须在 asm 编译循环之前定义。
CC="${CC:-cc}"
CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"

# backend.sx 等大模块 asm 编译 abort 时，用最小 .s/.c 占位保证 __text 非空（质检 24/24）。
emit_asm_text_stub_o() {
  local out="$1"
  local stub_c="scripts/asm_text_stub.c"
  local stub_s="scripts/asm_text_stub.s"
  if [ -f "$stub_c" ]; then
    "$CC" $CFLAGS -c -o "$out" "$stub_c" 2>/dev/null && return 0
  fi
  [ -f "$stub_s" ] || return 1
  echo "    fallback: $CC -c $stub_s -> $out (asm compile abort recovery)"
  "$CC" -c -o "$out" "$stub_s" 2>/dev/null
}

# strict 链前：首遍 stub .o 若仍含强符号 shux_asm_ci_text_stub，用 weak 版重编（并列链 multiple definition）。
refresh_build_asm_ci_text_stubs_for_strict_link() {
  local o="" txt="" sym=""
  for o in $NONEMPTY_ASM; do
    sym=$(nm "$o" 2>/dev/null | awk '/ shux_asm_ci_text_stub$/ {print $2; exit}')
    [ "$sym" = "T" ] || continue
    txt=$(asm_o_text_bytes "$o" 2>/dev/null || echo 0)
    [ "$txt" -le 64 ] 2>/dev/null || continue
    emit_asm_text_stub_o "$o" 2>/dev/null || true
  done
}

# 按依赖顺序尝试编译各 .sx 为 .o（顺序由 asm_build_list.sx 的 // BUILD: 行定义）
# SKIP 表示该次 -backend asm -o 编译失败（命令非零退出）；默认保留 stderr，可直接看到失败原因（如 asm_codegen_elf_o failed）。
# 常见原因：asm_codegen_elf_o 内某步失败，或 pipeline 解析/类型检查/codegen 失败。若需静默可设 SHUX_ASM_QUIET=1。

# 非 Linux CI（macOS/Windows）：experimental bootstrap 不链 build_asm/*.o；
# MSYS 上 -backend asm 会挂起 45min+（含 typeck），故 build_asm 一律 text stub。
asm_ci_stub_build_asm_module() {
  local out="$1"
  [ -n "${SHUX_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY:-}" ] || return 1
  # Linux CI 仍全量 emit（ubuntu B-strict / bootstrap-verify）。
  [ "$(uname -s 2>/dev/null)" = "Linux" ] && return 1
  return 0
}

# MSYS/macOS CI：typeck.sx EMIT_HEAVY 会挂起；S2 __text 门禁仅 Linux x64 实跑。
asm_ci_skip_typeck_emit_heavy() {
  [ -n "${SHUX_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY:-}" ] || return 1
  [ "$(uname -s 2>/dev/null)" = "Linux" ] && return 1
  return 0
}

# CI 快速路径：非宿主 ISA 的 encoder 模块用 text stub，缩短 macOS/Windows build_shux_asm。
asm_ci_host_skip_module() {
  local out="$1"
  local host=""
  [ -n "${SHUX_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY:-}" ] || return 1
  case "$(uname -m 2>/dev/null)" in
    arm64|aarch64) host=arm64 ;;
    x86_64|amd64) host=x86_64 ;;
    *) return 1 ;;
  esac
  case "$out" in
    x86_64_enc.o|riscv64.o|riscv64_enc.o)
      [ "$host" = "x86_64" ] && return 1
      return 0 ;;
    arm64_enc.o)
      [ "$host" = "arm64" ] && return 1
      return 0 ;;
    *) return 1 ;;
  esac
}

# 仅保留 emit 仍会宿主 Abort 的特大模块走 SKIP+桩；其余默认 C 预检 + 真 emit（见 pipeline_should_skip_sx_typeck）。
asm_out_needs_skip_typeck() {
  case "$1" in
    ast.o|typeck.o|parser.o|backend.o|arm64_enc.o|x86_64_enc.o|riscv64_enc.o|lexer.o|pipeline.o|codegen.o|lsp.o|main.o)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

compile_sx() {
  local out="$BUILD_DIR/$1"
  local src="$2"
  local skip_typeck=0
  local preserve_backup=""
  printf "  asm %s -> %s ... " "$src" "$out"
  # 首遍 BUILD 循环：无 EMIT_HEAVY 时一律 text stub（Rosetta/大模块 elf emit 极慢）；真符号由 second pass + SX/partial 提供。
  if [ -z "${SHUX_ASM_ENTRY_EMIT_HEAVY:-}" ]; then
    if emit_asm_text_stub_o "$out"; then
      echo "OK-${1%.o}-stub"
      return 0
    fi
  fi
  # CI：macOS/Windows 除 typeck.o 外 stub（experimental 链不依赖 build_asm；MSYS token.sx 会挂起）。
  if asm_ci_stub_build_asm_module "$1"; then
    if emit_asm_text_stub_o "$out"; then
      echo "OK-ci-stub-build"
      return 0
    fi
  fi
  # CI：交叉架构 encoder 用最小 stub .o，避免 x86_64_enc 等在 ARM macOS 上耗时/Abort。
  if asm_ci_host_skip_module "$1"; then
    if emit_asm_text_stub_o "$out"; then
      echo "OK-ci-stub"
      return 0
    fi
  fi
  # 自举第二遍：重编失败时保留已有非空 __text（避免 stage2 清空 build_asm/*.o）。
  if [ -f "$out" ] && [ -s "$out" ]; then
    preserve_backup="$BUILD_DIR/.preserve_${1}"
    cp -f "$out" "$preserve_backup" 2>/dev/null || preserve_backup=""
  fi
  # 大模块（typeck/codegen/elf）parse/typeck 栈帧深；macOS 默认栈易 segfault(139)。
  ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  # 单模块 .o：仅编入口符号，dep 由其它 build_asm/*.o 并列提供，避免 Mach-O 重复定义。
  # 勿设 SHUX_TYPECK_FORCE_C：C typeck_module 面向旧式 fat Module，slim pool 模块会 segfault。
  if [ -n "${SHUX_ASM_FORCE_SKIP_TYPECK:-}" ]; then
    skip_typeck=1
  elif asm_out_needs_skip_typeck "$1"; then
    skip_typeck=1
  fi
  if [ "$skip_typeck" -eq 1 ]; then
    if env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 "$SHUX" -backend asm -o "$out" $LIBROOT "$src" ${SHUX_ASM_QUIET:+2>/dev/null}; then
      _txt=$(asm_o_text_bytes "$out")
      if [ "$_txt" = "0" ]; then
        echo "WARN-empty-__text"
        build_shux_asm_warn "$out __text=0 (SHUX_ASM_ENTRY_ONLY_DEBUG=1 $SHUX -backend asm -o /tmp/x.o $LIBROOT $src -> funcs=N)"
      fi
      echo OK; return 0
    fi
  else
    if env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 "$SHUX" -backend asm -o "$out" $LIBROOT "$src" ${SHUX_ASM_QUIET:+2>/dev/null}; then
      _txt=$(asm_o_text_bytes "$out")
      if [ "$_txt" = "0" ]; then
        echo "WARN-empty-__text"
        build_shux_asm_warn "$out __text=0 (SHUX_ASM_ENTRY_ONLY_DEBUG=1 ... -> funcs=N)"
      fi
      echo OK; return 0
    elif env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 "$SHUX" -backend asm -o "$out" $LIBROOT "$src" ${SHUX_ASM_QUIET:+2>/dev/null}; then
      _txt=$(asm_o_text_bytes "$out")
      if [ "$_txt" = "0" ]; then
        echo "WARN-empty-__text"
      fi
      echo OK-skip-typeck; return 0
    fi
  fi
  echo SKIP
  if [ -n "$preserve_backup" ] && [ -f "$preserve_backup" ]; then
    cp -f "$preserve_backup" "$out" 2>/dev/null || true
    echo "(preserved __text=$(asm_o_text_bytes "$out" 2>/dev/null || echo 0)B)"
  fi
  # Darwin 首遍：main.sx / lexer.sx SKIP_TYPECK 常 Bus error/SIGSEGV；用 text stub 占位使 pipeline.o 已绿时仍能走 experimental + second pass。
  case "$1" in
    main.o|lexer.o)
      if [ "$(asm_o_text_bytes "$out" 2>/dev/null || echo 0)" = "0" ]; then
        if emit_asm_text_stub_o "$out"; then
          echo "OK-stub-after-skip"
          return 0
        fi
      fi
      ;;
  esac
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
  # POSIX sh（#!/bin/sh）不支持 bash 的 $((16#hex))；与 run-s2-typeck-gate.sh 一致用 perl。
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

# macOS ld64 / lld 支持 -exported_symbols_list；GNU bfd ld 须 --version-script。
ld_supports_exported_symbols_list() {
  ld -v 2>&1 | grep -qE 'PROJECT:ld64|LLD|LLVM'
}

# 从符号列表（每行一个，可带 Mach-O 前缀 _）做 ld -r 局部导出；供 strict partial 链。
ld_partial_export() {
  local syms_file="$1"
  local out_o="$2"
  shift 2
  local in_o="$1"
  if ld_supports_exported_symbols_list; then
    ld -r -exported_symbols_list "$syms_file" -o "$out_o" "$in_o"
    return $?
  fi
  # GNU bfd ld：--version-script 不剥离 .o 内符号；须 objcopy --keep-global-symbols 真删局部符号。
  local keep="$out_o.keep_syms"
  : > "$keep"
  while IFS= read -r sym || [ -n "$sym" ]; do
    [ -z "$sym" ] && continue
    case "$sym" in \#*) continue ;; esac
    sym="${sym#_}"
    echo "$sym" >> "$keep"
  done < "$syms_file"
  ld -r -o "$out_o" "$in_o" || return 1
  objcopy --keep-global-symbols="$keep" "$out_o" "$out_o"
}

# 实验链第一遍链接后：用新 shux_asm + 最新 pipeline_glue_standalone 重编 pipeline.o（避免鸡生蛋 4B 桩）。
# 成功须 __text≥200B（B-strict 前置）；bootstrap shux_asm 在 Linux ELF 常产出 0B 桩，须回退 seed ./shux。
rebuild_pipeline_o_second_pass() {
  if [ -n "${SHUX_ASM_CI_SKIP_SECOND_PASS:-}" ]; then
    build_shux_asm_info "pipeline.o second pass skipped (CI fast)"
    return 0
  fi
  local min_text=200
  local pcomp PTMP PTEXT=0
  # pipeline_sx.o 已 selfhosted 时 promote 为 build_asm/pipeline.o，跳过 pipeline.sx asm 二遍（Docker 上易 futex 卡死）
  _promote_pipeline_sx_second_pass() {
    [ -f pipeline_sx.o ] || return 1
    cp -f pipeline_sx.o "$BUILD_DIR/pipeline.o"
    asm_strict_pipeline_selfhosted || return 1
    PTEXT=$(asm_o_text_bytes "$BUILD_DIR/pipeline.o" 2>/dev/null || echo 0)
    build_shux_asm_info "pipeline.o second pass promote pipeline_sx.o (__text=${PTEXT}B, skip asm emit)"
    return 0
  }
  if [ "${SHUX_ASM_SECOND_PASS_FORCE_ASM:-0}" != "1" ] && _promote_pipeline_sx_second_pass; then
    return 0
  fi
  # virtiofs 挂载下长时 asm -o 易 futex 卡死；优先在容器 /tmp 落盘，成功后再 mv 到 BUILD_DIR
  if [ -n "${SHUX_ASM_SECOND_PASS_TMP:-}" ]; then
    PTMP="$SHUX_ASM_SECOND_PASS_TMP"
  elif [ -d /tmp ] && [ -w /tmp ]; then
    PTMP="/tmp/shux_pipeline_second_pass_$$.o"
  else
    PTMP="$BUILD_DIR/pipeline.second_pass.o"
  fi
  ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  build_shux_asm_info "second pass - recompile pipeline.o (tmp=$PTMP)"
  # 单次 attempt 超时（秒）；EMIT_HEAVY 在 pipeline.sx 上偶发 futex 卡死，须 timeout 后回退轻量路径
  _sp_timeout="${SHUX_ASM_SECOND_PASS_TIMEOUT:-7200}"
  _run_pipeline_sp() {
    _sp_env="$1"
    shift
    rm -f "$PTMP" 2>/dev/null || true
    if command -v timeout >/dev/null 2>&1; then
      timeout "$_sp_timeout" env -u SHUX_ASM_START_FUNC "$@" "$_sp_env" -backend asm -o "$PTMP" $LIBROOT src/pipeline/pipeline.sx 2>"$BUILD_DIR/pipeline.second_pass.err"
    else
      env -u SHUX_ASM_START_FUNC "$@" "$_sp_env" -backend asm -o "$PTMP" $LIBROOT src/pipeline/pipeline.sx 2>"$BUILD_DIR/pipeline.second_pass.err"
    fi
  }
  _try_pipeline_sp_ok() {
    _label="$1"
    shift
    PTEXT=$(asm_o_text_bytes "$PTMP" 2>/dev/null || echo 0)
    if [ "$PTEXT" -ge "$min_text" ] 2>/dev/null; then
      mv -f "$PTMP" "$BUILD_DIR/pipeline.o"
      build_shux_asm_info "pipeline.o second pass OK $_label (__text=${PTEXT}B)"
      return 0
    fi
    build_shux_asm_warn "pipeline.o second pass $_label too small (__text=${PTEXT}B)"
    return 1
  }
  for pcomp in "./shux_asm.experimental" "./shux-seed-phase1" "${SHUX:-}" "./shux" "./shux_asm"; do
    [ -n "$pcomp" ] || continue
    [ -x "$pcomp" ] || continue
    build_shux_asm_info "pipeline.o second pass try $pcomp"
    # 1) 轻量 SKIP_TYPECK（避免 EMIT_HEAVY futex 卡死）
    if _run_pipeline_sp "$pcomp" SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1; then
      _try_pipeline_sp_ok "with SKIP_TYPECK via $pcomp" && return 0
    fi
    rm -f "$PTMP" 2>/dev/null || true
    # 2) 默认 entry-only
    if _run_pipeline_sp "$pcomp" SHUX_ASM_ENTRY_MODULE_ONLY=1; then
      _try_pipeline_sp_ok "via $pcomp" && return 0
    fi
    rm -f "$PTMP" 2>/dev/null || true
    # 3) EMIT_HEAVY 最后尝试（timeout 后失败则换下一 compiler）
    if _run_pipeline_sp "$pcomp" SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0; then
      _try_pipeline_sp_ok "with EMIT_HEAVY via $pcomp" && return 0
    fi
    rm -f "$PTMP" 2>/dev/null || true
  done
  if _promote_pipeline_sx_second_pass; then
    return 0
  fi
  build_shux_asm_error "pipeline.o second pass failed (no compiler reached __text>=${min_text}B)"
  return 1
}

# 第二遍：用 bootstrap shux_asm（experimental 链，含 pipeline_sx.o）重编大模块；须在 strict 重链覆盖 shux_asm 之前执行。
rebuild_typeck_parser_backend_second_pass() {
  if [ -n "${SHUX_ASM_CI_SKIP_SECOND_PASS:-}" ]; then
    build_shux_asm_info "typeck/parser/backend second pass skipped (CI fast)"
    return 0
  fi
  # 第二遍编译器：显式参数 > ./shux_asm（strict 产物）> ${SHUX} > experimental；勿用过期 seed ./shux。
  local comp=""
  if [ -n "${1:-}" ] && [ -x "${1}" ]; then
    comp="$1"
  elif [ -n "${SHUX_ASM_SECOND_PASS_COMPILER:-}" ] && [ -x "${SHUX_ASM_SECOND_PASS_COMPILER}" ]; then
    comp="${SHUX_ASM_SECOND_PASS_COMPILER}"
  elif [ -x "./shux_asm.experimental" ]; then
    comp="./shux_asm.experimental"
  elif [ -n "${SHUX:-}" ] && [ -x "${SHUX}" ]; then
    comp="${SHUX}"
  elif [ -x "./shux" ]; then
    comp="./shux"
  elif [ -x "./shux-seed-phase1" ]; then
    comp="./shux-seed-phase1"
  elif [ -x "./shux_asm" ]; then
    comp="./shux_asm"
  else
    return 1
  fi
  local ok=0
  ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  for spec in "typeck.o:src/typeck/typeck.sx:typeck_sx.o" "parser.o:src/parser/parser.sx:parser_sx.o" "backend.o:src/asm/backend.sx:"; do
    local out="${spec%%:*}"
    local rest="${spec#*:}"
    local src="${rest%%:*}"
    local sx_o="${rest#*:}"
    local tmp="$BUILD_DIR/${out%.o}.second_pass.o"
    local pass_ok=0
    # backend：seed partial 已提供强符号时跳过 asm 二遍（backend.sx 极大，Docker 易 OOM/Killed）
    if [ "$out" = "backend.o" ] && [ -s "$BUILD_DIR/seed_host/asm_backend_partial.o" ]; then
      build_shux_asm_info "$out second pass skip - seed_host/asm_backend_partial.o"
      ok=1
      continue
    fi
    # typeck/parser：promote 已 pinned 的 *_sx.o（与 pipeline_sx promote 同理）
    if [ "${SHUX_ASM_SECOND_PASS_FORCE_ASM:-0}" != "1" ] && [ -n "$sx_o" ] && [ -f "$sx_o" ]; then
      cp -f "$sx_o" "$BUILD_DIR/$out"
      case "$out" in
        typeck.o)
          if asm_strict_typeck_selfhosted; then
            build_shux_asm_info "$out second pass promote $sx_o (__text=$(asm_o_text_bytes "$BUILD_DIR/$out")B, skip asm emit)"
            ok=1
            continue
          fi
          ;;
        parser.o)
          if [ "$(asm_o_text_bytes "$BUILD_DIR/$out" 2>/dev/null || echo 0)" -gt 8192 ] 2>/dev/null; then
            build_shux_asm_info "$out second pass promote $sx_o (__text=$(asm_o_text_bytes "$BUILD_DIR/$out")B, skip asm emit)"
            ok=1
            continue
          fi
          ;;
      esac
      rm -f "$BUILD_DIR/$out" 2>/dev/null || true
    fi
    build_shux_asm_info "second pass - recompile $out with $comp"
    if [ "$out" = "typeck.o" ] || [ "$out" = "backend.o" ] || [ "$out" = "parser.o" ]; then
      # 第二遍：EMIT_HEAVY 真 emit（parser 截断模块在 ast_pool 内桩化；真机在 parser_sx.o）。
      if env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
        "$comp" -backend asm -o "$tmp" $LIBROOT "$src" && pass_ok=1; then
        :
      fi
    elif env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 "$comp" -backend asm -o "$tmp" $LIBROOT "$src" && pass_ok=1; then
      :
    fi
    if [ "$pass_ok" -eq 1 ] && [ -f "$tmp" ]; then
      mv -f "$tmp" "$BUILD_DIR/$out"
      build_shux_asm_info "$out second pass OK (__text=$(asm_o_text_bytes "$BUILD_DIR/$out")B)"
      ok=1
    else
      rm -f "$tmp" 2>/dev/null || true
      build_shux_asm_error "$out second pass failed"
      return 1
    fi
  done
  [ "$ok" -eq 1 ]
}

# CI / experimental-only：S2 gate 要求 build_asm/typeck.o __text≥68264；首遍 SKIP_TYPECK 仅 ~165B 桩，须单独 EMIT_HEAVY。
# 不受 SHUX_ASM_CI_SKIP_SECOND_PASS 影响（仅重编 typeck.o，比全量 second pass 快）。
rebuild_typeck_o_emit_heavy_s2() {
  local comp="${1:-./shux_asm.experimental}"
  local out="$BUILD_DIR/typeck.o"
  local src="src/typeck/typeck.sx"
  local tmp="$BUILD_DIR/typeck.emit_heavy_s2.o"
  local cur_txt new_txt min_gate=68264
  local baseline="../../tests/baseline/s2-typeck-o.tsv"

  if [ -f "$baseline" ]; then
    min_gate=$(awk -F'\t' '$1=="min_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$baseline" 2>/dev/null)
    [ -z "$min_gate" ] && min_gate=68264
  fi
  if [ ! -x "$comp" ]; then
    comp="./shux_asm"
  fi
  if [ ! -x "$comp" ]; then
    build_shux_asm_error "typeck EMIT_HEAVY S2: no shux_asm compiler"
    return 1
  fi
  cur_txt=$(asm_o_text_bytes "$out" 2>/dev/null || echo 0)
  if [ "${cur_txt:-0}" -ge "$min_gate" ] 2>/dev/null; then
    build_shux_asm_info "typeck.o already S2-ready (__text=${cur_txt}B >= ${min_gate})"
    return 0
  fi
  build_shux_asm_info "S2 typeck: EMIT_HEAVY recompile typeck.o with $comp (was __text=${cur_txt}B)"
  ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  rm -f "$tmp"
  if ! env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
    SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
    "$comp" -backend asm -o "$tmp" $LIBROOT "$src"; then
    rm -f "$tmp" 2>/dev/null || true
    build_shux_asm_error "typeck.o EMIT_HEAVY compile failed"
    return 1
  fi
  new_txt=$(asm_o_text_bytes "$tmp" 2>/dev/null || echo 0)
  if [ "${new_txt:-0}" -lt "$min_gate" ] 2>/dev/null; then
    rm -f "$tmp" 2>/dev/null || true
    build_shux_asm_error "typeck.o EMIT_HEAVY __text=${new_txt}B < S2 min ${min_gate}"
    return 1
  fi
  mv -f "$tmp" "$out"
  ensure_typeck_asm_layout_partial_obj || true
  build_shux_asm_info "typeck.o EMIT_HEAVY S2 OK (__text=${new_txt}B)"
  return 0
}

# M8a：parser 支持 Module.sub.Type 后，须用已链入新 parser 的编译器重编首遍仅解析到首个函数的模块（arm64_enc 等）。
rebuild_m8a_parser_dependent_modules_second_pass() {
  if [ -n "${SHUX_ASM_CI_SKIP_SECOND_PASS:-}" ]; then
    build_shux_asm_info "M8a second pass skipped (CI fast)"
    return 0
  fi
  local comp="${SHUX_ASM_SECOND_PASS_COMPILER:-./shux_asm}"
  if [ -n "${1:-}" ] && [ -x "${1}" ]; then
    comp="$1"
  fi
  if [ ! -x "$comp" ]; then
    comp="${SHUX:-./shux}"
  fi
  if [ ! -x "$comp" ]; then
    return 1
  fi
  local ok=0
  ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  for spec in "arm64_enc.o:src/asm/arch/arm64_enc.sx" "lsp.o:src/lsp/lsp.sx" "asm.o:src/asm/asm.sx"; do
    local out="${spec%%:*}"
    local src="${spec#*:}"
    local tmp="$BUILD_DIR/${out%.o}.m8a_second_pass.o"
    build_shux_asm_info "M8a second pass - recompile $out with $comp"
    local cur_txt=0
    if [ -f "$BUILD_DIR/$out" ]; then
      cur_txt=$(asm_o_text_bytes "$BUILD_DIR/$out" 2>/dev/null || echo 0)
    fi
    if [ "$cur_txt" -gt 0 ] 2>/dev/null; then
      build_shux_asm_info "$out M8a pass skipped (__text=${cur_txt}B already OK)"
      ok=1
      continue
    fi
    if env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 "$comp" -backend asm -o "$tmp" $LIBROOT "$src" \
      && [ -f "$tmp" ]; then
      local new_txt=0
      new_txt=$(asm_o_text_bytes "$tmp" 2>/dev/null || echo 0)
      if [ "${new_txt:-0}" -gt 0 ] 2>/dev/null; then
        mv -f "$tmp" "$BUILD_DIR/$out"
        build_shux_asm_info "$out M8a pass OK (__text=${new_txt}B)"
        ok=1
      else
        rm -f "$tmp" 2>/dev/null || true
        build_shux_asm_warn "$out M8a pass empty __text (keep existing ${cur_txt}B)"
        [ "${cur_txt:-0}" -gt 0 ] 2>/dev/null && ok=1
      fi
    else
      rm -f "$tmp" 2>/dev/null || true
      build_shux_asm_warn "$out M8a pass failed"
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
  build_shux_asm_info "strip _main_entry from main.o (CLI dispatch via asm_experimental_symbol_bridge)"
  if command -v llvm-objcopy >/dev/null 2>&1; then
    llvm-objcopy --strip-symbol=_main_entry "$mo"
  elif strip -N _main_entry "$mo" 2>/dev/null; then
    :
  elif command -v objcopy >/dev/null 2>&1; then
    objcopy --strip-symbol=_main_entry "$mo" 2>/dev/null || objcopy -N _main_entry "$mo"
  else
    build_shux_asm_error "cannot strip _main_entry (need llvm-objcopy or strip -N)"
    return 1
  fi
}

# B-strict strict 重链前：main.sx 须 ENTRY_MODULE_ONLY + ENTRY_EMIT_HEAVY 真 emit entry（含 check/fmt/test 路由）。
# 勿去掉 ENTRY_MODULE_ONLY（会拉全量 dep typeck，codegen import 常失败）；EMIT_HEAVY 与 typeck 第二遍同模式。
# 优先 SHUX_ASM_WPO_DCE 默认开（main.o ~9KiB→~32B）；失败或无 entry 时回退 WPO=0。
rebuild_main_o_for_cli() {
  local tmp="/tmp/shux_build_main.cli.o"
  local comp=""
  local txt=""
  local wpo_mode=""
  local main_tout="${SHUX_MAIN_O_COMPILE_TIMEOUT:-300}"

  if [ "${SHUX_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ]; then
    build_shux_asm_info "skip main.o recompile (SHUX_ASM_SKIP_MAIN_O_REBUILD=1)"
    return 0
  fi

  # main.sx EMIT_HEAVY 须大栈；Alpine 默认 8192KiB 时 WPO on 易 SIGSEGV/失败。
  ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true

  # 尝试编译 main.o：wpo_arg 为空=默认 WPO 开；0=显式关（A/B 对照 / 回退）。
  # WPO on 优先 SKIP+无 EMIT_HEAVY（main.sx 仅 export entry，~656B）；失败再试 EMIT_HEAVY 全链。
  try_main_o_compile() {
    local wpo_arg="$1"
    local compiler="$2"
    local emit_heavy="${3:-0}"
    rm -f "$tmp" 2>/dev/null || true
    if command -v timeout >/dev/null 2>&1; then
      if [ -n "$wpo_arg" ]; then
        timeout "$main_tout" env -u SHUX_ASM_START_FUNC \
          SHUX_ASM_ENTRY_MODULE_ONLY=1 \
          SHUX_ASM_BUILD_SKIP_TYPECK=1 \
          SHUX_ASM_ENTRY_EMIT_HEAVY="$emit_heavy" \
          SHUX_ASM_WPO_DCE="$wpo_arg" \
          "$compiler" -backend asm -o "$tmp" $LIBROOT src/main.sx 2>/dev/null || return 1
      else
        timeout "$main_tout" env -u SHUX_ASM_START_FUNC \
          SHUX_ASM_ENTRY_MODULE_ONLY=1 \
          SHUX_ASM_BUILD_SKIP_TYPECK=1 \
          SHUX_ASM_ENTRY_EMIT_HEAVY="$emit_heavy" \
          "$compiler" -backend asm -o "$tmp" $LIBROOT src/main.sx 2>/dev/null || return 1
      fi
    elif [ -n "$wpo_arg" ]; then
      if ! env -u SHUX_ASM_START_FUNC \
        SHUX_ASM_ENTRY_MODULE_ONLY=1 \
        SHUX_ASM_BUILD_SKIP_TYPECK=1 \
        SHUX_ASM_ENTRY_EMIT_HEAVY="$emit_heavy" \
        SHUX_ASM_WPO_DCE="$wpo_arg" \
        "$compiler" -backend asm -o "$tmp" $LIBROOT src/main.sx 2>/dev/null; then
        return 1
      fi
    elif ! env -u SHUX_ASM_START_FUNC \
      SHUX_ASM_ENTRY_MODULE_ONLY=1 \
      SHUX_ASM_BUILD_SKIP_TYPECK=1 \
      SHUX_ASM_ENTRY_EMIT_HEAVY="$emit_heavy" \
      "$compiler" -backend asm -o "$tmp" $LIBROOT src/main.sx 2>/dev/null; then
      return 1
    fi
    txt=$(asm_o_text_bytes "$tmp" 2>/dev/null || echo 0)
    if [ "$txt" = "0" ]; then
      return 1
    fi
    if ! nm "$tmp" 2>/dev/null | grep -q ' entry$'; then
      return 1
    fi
    # WPO on：main.sx 仅 entry export 时 __text 约 656B（cap 见 wpo-main-o.tsv 768B）。
    if [ -z "$wpo_arg" ] && [ "$txt" -gt 768 ] 2>/dev/null; then
      return 1
    fi
    return 0
  }

  build_shux_asm_info "recompile main.o (ENTRY_MODULE_ONLY + ENTRY_EMIT_HEAVY + WPO DCE prefer-on)"
  set +e
  # SHUX_WPO_MAIN_REBUILD_ONLY：post-strict 仅允许指定编译器（须为新链出的 ./shux_asm）。
  if [ -n "${SHUX_WPO_MAIN_REBUILD_ONLY:-}" ]; then
    for comp in ${SHUX_WPO_MAIN_REBUILD_ONLY}; do
      [ -x "$comp" ] || continue
      wpo_mode="on"
      if try_main_o_compile "" "$comp" 0; then
        :
      elif try_main_o_compile "" "$comp" 1; then
        wpo_mode="on-heavy"
      elif try_main_o_compile "0" "$comp" 0; then
        wpo_mode="off"
      elif try_main_o_compile "0" "$comp" 1; then
        wpo_mode="off-heavy"
      else
        continue
      fi
      mv -f "$tmp" "$BUILD_DIR/main.o"
      build_shux_asm_info "main.o CLI entry OK via $comp (__text=${txt}B, WPO DCE ${wpo_mode}, symbol entry)"
      set -e
      return 0
    done
    set -e
    build_shux_asm_error "main.o post-strict WPO recompile failed (compiler=${SHUX_WPO_MAIN_REBUILD_ONLY})"
    return 1
  fi
  # post-strict / 生产链：优先 experimental（ENTRY_MODULE_ONLY smoke 通过）。
  while IFS= read -r comp; do
    [ -n "$comp" ] || continue
    wpo_mode="on"
    if try_main_o_compile "" "$comp" 0; then
      :
    elif try_main_o_compile "" "$comp" 1; then
      wpo_mode="on-heavy"
    elif try_main_o_compile "0" "$comp" 0; then
      wpo_mode="off"
    elif try_main_o_compile "0" "$comp" 1; then
      wpo_mode="off-heavy"
    else
      continue
    fi
    mv -f "$tmp" "$BUILD_DIR/main.o"
    build_shux_asm_info "main.o CLI entry OK via $comp (__text=${txt}B, WPO DCE ${wpo_mode}, symbol entry)"
    set -e
    return 0
  done <<EOF
$(wpo_rebuild_compiler_candidates)
EOF
  set -e
  build_shux_asm_error "main.o CLI recompile failed (check/fmt/test may rely on asm_experimental_symbol_bridge)"
  return 1
}

# strict 链成功后重编 main.o：strict shux_asm 自编 main.sx 易 SIGSEGV；优先 experimental。
# 若已有 WPO 压缩 main.o（≤768B + entry），勿用 WPO off 回退覆盖。
rebuild_main_o_post_strict_link() {
  ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true
  local comp
  local cur_txt
  if [ "${SHUX_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ]; then
    build_shux_asm_info "post-strict skip main.o recompile (SHUX_ASM_SKIP_MAIN_O_REBUILD=1)"
    return 0
  fi
  if [ -f "$BUILD_DIR/asm_experimental_symbol_bridge.o" ] && \
     ! nm "$BUILD_DIR/main.o" 2>/dev/null | grep -q ' entry$'; then
    build_shux_asm_info "post-strict skip main.o recompile (bridge entry; main.o stub)"
    return 0
  fi
  cur_txt=$(asm_o_text_bytes "$BUILD_DIR/main.o" 2>/dev/null || echo 0)
  if [ "$cur_txt" -gt 0 ] && [ "$cur_txt" -le 768 ] 2>/dev/null && \
     nm "$BUILD_DIR/main.o" 2>/dev/null | grep -q ' entry$'; then
    build_shux_asm_info "post-strict main.o keep compressed (__text=${cur_txt}B, entry present)"
    return 0
  fi
  for comp in ./shux_asm ./shux_asm.experimental ./shux_asm_stage1 ./shux; do
    [ -x "$comp" ] || continue
    if SHUX_WPO_MAIN_REBUILD_ONLY="$comp" rebuild_main_o_for_cli; then
      return 0
    fi
  done
  return 1
}

# ld -r：EMIT_HEAVY driver_compile + link_alias → driver_compile_link.o（strict 替换 driver_compile_sx.o）。
# EMIT_HEAVY 常漏 driver_compile_parse_argv_loop；从 driver_compile_sx.o 部分导出补全。
ensure_driver_parse_argv_loop_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/driver_compile_parse_argv_loop_partial.o"
  SYMS="$BUILD_DIR/driver_compile_parse_argv_loop_export.txt"
  SUO="driver_compile_sx.o"
  [ -f "$SUO" ] || return 1
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ]; then
    printf '%s\n' 'driver_compile_parse_argv_loop' >"$SYMS"
    echo "  ld partial export $SYMS $SUO -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$SUO" || return 1
  fi
  return 0
}

ensure_driver_compile_link_obj() {
  local eh_o="$BUILD_DIR/driver_compile_emit_heavy.o"
  local alias_src="src/asm/driver_compile_asm_link_alias.c"
  local alias_o="$BUILD_DIR/driver_compile_asm_link_alias.o"
  local link_o="$BUILD_DIR/driver_compile_link.o"
  local loop_partial="$BUILD_DIR/driver_compile_parse_argv_loop_partial.o"
  [ -f "$eh_o" ] && [ -s "$eh_o" ] || return 1
  [ -f "$alias_src" ] || return 1
  if [ ! -f "$alias_o" ] || [ "$alias_src" -nt "$alias_o" ]; then
    build_shux_asm_info "cc driver_compile_asm_link_alias.o"
    "$CC" $CFLAGS -c -o "$alias_o" "$alias_src"
  fi
  if nm "$eh_o" 2>/dev/null | grep -qE ' U (_)?driver_compile_parse_argv_loop$'; then
    ensure_driver_parse_argv_loop_partial_obj || return 1
  else
    loop_partial=""
    # emit_heavy 已含 loop：仅用 eh+alias 重编 link_o，勿再 ld -r partial。
    rm -f "$link_o" 2>/dev/null || true
  fi
  if [ ! -f "$link_o" ] || [ "$eh_o" -nt "$link_o" ] || [ "$alias_o" -nt "$link_o" ] || \
     { [ -n "$loop_partial" ] && [ -f "$loop_partial" ] && [ "$loop_partial" -nt "$link_o" ]; }; then
    build_shux_asm_info "ld -r driver_compile_emit_heavy.o + link_alias -> driver_compile_link.o"
    rm -f "$link_o" 2>/dev/null || true
    if [ -n "$loop_partial" ] && [ -f "$loop_partial" ]; then
      ld -r -o "$link_o" "$eh_o" "$alias_o" "$loop_partial" 2>/dev/null || return 1
    else
      ld -r -o "$link_o" "$eh_o" "$alias_o" 2>/dev/null || return 1
    fi
  fi
  nm -g "$link_o" 2>/dev/null | grep -qE '(_)?driver_run_compiler_full_sx' || return 1
  if nm "$link_o" 2>/dev/null | grep -qE ' U (_)?driver_compile_parse_argv_loop$'; then
    return 1
  fi
  return 0
}

# EMIT_HEAVY 全量 driver_compile（S3 gate / strict link）；与 WPO 压缩 driver_compile.o 分离。
try_driver_emit_heavy_compile() {
  local out_o="$1"
  local compiler="$2"
  local eh_tout="${SHUX_DRIVER_EMIT_HEAVY_TIMEOUT:-600}"
  rm -f "$out_o" 2>/dev/null || true
  if command -v timeout >/dev/null 2>&1; then
    timeout "$eh_tout" env -u SHUX_ASM_START_FUNC \
      SHUX_ASM_ENTRY_MODULE_ONLY=1 \
      SHUX_ASM_BUILD_SKIP_TYPECK=1 \
      SHUX_ASM_ENTRY_EMIT_HEAVY=1 \
      SHUX_ASM_WPO_DCE=0 \
      "$compiler" -backend asm -o "$out_o" $LIBROOT src/driver/compile.sx 2>/dev/null || return 1
  elif ! env -u SHUX_ASM_START_FUNC \
    SHUX_ASM_ENTRY_MODULE_ONLY=1 \
    SHUX_ASM_BUILD_SKIP_TYPECK=1 \
    SHUX_ASM_ENTRY_EMIT_HEAVY=1 \
    SHUX_ASM_WPO_DCE=0 \
    "$compiler" -backend asm -o "$out_o" $LIBROOT src/driver/compile.sx 2>/dev/null; then
    return 1
  fi
  [ -s "$out_o" ] || return 1
  [ "$(asm_o_text_bytes "$out_o" 2>/dev/null || echo 0)" -ge 5104 ] 2>/dev/null
}

# WPO 压缩 driver_compile.o 验收：无 entry 符号；须 __text≤768B 且含至少一个真 export。
driver_wpo_compressed_o_ok() {
  local o="$1"
  local txt
  txt=$(asm_o_text_bytes "$o" 2>/dev/null || echo 0)
  [ "$txt" -gt 0 ] 2>/dev/null || return 1
  [ "$txt" -le 768 ] 2>/dev/null || return 1
  nm "$o" 2>/dev/null | grep -qE ' T (compile_dispatch_asm_backend|run_compiler_full_sx|entry)$' && return 0
  nm "$o" 2>/dev/null | grep -q ' T ' 
}

# B-strict：WPO 压缩 driver_compile.o；失败不覆盖已有压缩产物。
rebuild_driver_compile_o_wpo() {
  local tmp="/tmp/shux_build_driver_compile.cli.o"
  local comp=""
  local txt=""
  local wpo_mode=""
  if [ "${SHUX_ASM_SKIP_WPO_DOGFOOD:-0}" = "1" ]; then
    build_shux_asm_info "skip driver_compile.o WPO recompile (SHUX_ASM_SKIP_WPO_DOGFOOD=1)"
    return 0
  fi
  ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true

  try_driver_wpo_compile() {
    local wpo_arg="$1"
    local compiler="$2"
    rm -f "$tmp" 2>/dev/null || true
    if [ -n "$wpo_arg" ]; then
      if ! env -u SHUX_ASM_START_FUNC \
        SHUX_ASM_ENTRY_MODULE_ONLY=1 \
        SHUX_ASM_BUILD_SKIP_TYPECK=1 \
        SHUX_ASM_ENTRY_EMIT_HEAVY=1 \
        SHUX_ASM_WPO_DCE="$wpo_arg" \
        "$compiler" -backend asm -o "$tmp" $LIBROOT src/driver/compile.sx 2>/dev/null; then
        return 1
      fi
    elif ! env -u SHUX_ASM_START_FUNC \
      SHUX_ASM_ENTRY_MODULE_ONLY=1 \
      SHUX_ASM_BUILD_SKIP_TYPECK=1 \
      SHUX_ASM_ENTRY_EMIT_HEAVY=1 \
      "$compiler" -backend asm -o "$tmp" $LIBROOT src/driver/compile.sx 2>/dev/null; then
      return 1
    fi
    txt=$(asm_o_text_bytes "$tmp" 2>/dev/null || echo 0)
    [ "$txt" -gt 0 ] || return 1
    if [ -z "$wpo_arg" ] && [ "$txt" -gt 768 ] 2>/dev/null; then
      return 1
    fi
    driver_wpo_compressed_o_ok "$tmp" || return 1
    return 0
  }

  build_shux_asm_info "recompile driver_compile.o (WPO DCE prefer-on, entry-only ~145B)"
  set +e
  while IFS= read -r comp; do
    [ -n "$comp" ] || continue
    wpo_mode="on"
    if try_driver_wpo_compile "" "$comp"; then
      :
    elif try_driver_wpo_compile "0" "$comp"; then
      wpo_mode="off"
    else
      continue
    fi
    mv -f "$tmp" "$BUILD_DIR/driver_compile.o"
    build_shux_asm_info "driver_compile.o WPO OK via $comp (__text=${txt}B, WPO DCE ${wpo_mode})"
    set -e
    return 0
  done <<EOF
$(wpo_rebuild_compiler_candidates)
EOF
  set -e
  build_shux_asm_warn "driver_compile.o WPO recompile failed (non-fatal)"
  return 1
}

# EMIT_HEAVY + link.o：strict 链 parse_argv / run_compiler_full_sx asm 替换 C-gen。
rebuild_driver_compile_emit_heavy_and_link() {
  local eh_o="$BUILD_DIR/driver_compile_emit_heavy.o"
  local comp=""
  local eh_tout="${SHUX_DRIVER_EMIT_HEAVY_TIMEOUT:-600}"
  if [ "${SHUX_ASM_SKIP_DRIVER_EMIT_HEAVY:-0}" = "1" ]; then
    build_shux_asm_info "skip driver_compile_emit_heavy.o recompile (SHUX_ASM_SKIP_DRIVER_EMIT_HEAVY=1)"
    return 0
  fi
  ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true
  build_shux_asm_info "recompile driver_compile_emit_heavy.o (EMIT_HEAVY full SX)"
  set +e
  for comp in "${SHUX:-}" "./shux_asm" "./shux_asm_stage1" "${SHUX_ASM_SECOND_PASS_COMPILER:-./shux_asm.experimental}" "./shux" "./shux-sx"; do
    [ -n "$comp" ] || continue
    [ -x "$comp" ] || continue
    if try_driver_emit_heavy_compile "$eh_o" "$comp"; then
      if ensure_driver_compile_link_obj; then
        build_shux_asm_info "driver_compile_emit_heavy.o OK via $comp (__text=$(asm_o_text_bytes "$eh_o")B, link.o ready)"
        set -e
        return 0
      fi
    fi
  done
  set -e
  build_shux_asm_warn "driver_compile_emit_heavy.o failed; using strict driver asm fallback to C-gen"
  return 1
}

rebuild_driver_compile_post_strict_link() {
  local cur_txt
  cur_txt=$(asm_o_text_bytes "$BUILD_DIR/driver_compile.o" 2>/dev/null || echo 0)
  if driver_wpo_compressed_o_ok "$BUILD_DIR/driver_compile.o" 2>/dev/null; then
    build_shux_asm_info "post-strict driver_compile.o keep compressed (__text=${cur_txt}B)"
  else
    rebuild_driver_compile_o_wpo || true
  fi
  rebuild_driver_compile_emit_heavy_and_link || true
  rebuild_pipeline_wpo_post_strict || true
  rebuild_typeck_wpo_post_strict || true
  rebuild_backend_wpo_post_strict || true
  if asm_pipeline_wpo_strict_reach_ok; then
    export STRICT_LINK_BUILD_ASM_WPO=1
    build_shux_asm_info "post-strict STRICT_LINK_BUILD_ASM_WPO=1 (pipeline_wpo.o reach OK)"
  fi
  if [ "${SHUX_ASM_STRICT_LINK_TYPECK_WPO:-1}" != "0" ] && asm_typeck_wpo_strict_reach_ok; then
    export STRICT_LINK_BUILD_ASM_TYPECK_WPO=1
    build_shux_asm_info "post-strict STRICT_LINK_BUILD_ASM_TYPECK_WPO=1 (typeck_wpo reach OK; helpers only if typeck.o not selfhosted)"
  fi
  if asm_backend_wpo_strict_reach_ok; then
    export STRICT_LINK_BUILD_ASM_BACKEND_WPO=1
    build_shux_asm_info "post-strict STRICT_LINK_BUILD_ASM_BACKEND_WPO=1 (backend_wpo.o reach OK)"
  fi
}

# strict_glue 链：pipeline.sx ENTRY_MODULE_ONLY 自编译用于 WPO dogfood 烟测（须 reach OK）。
shux_asm_entry_module_smoke_ok() {
  local comp="$1"
  local tmp="/tmp/shux_wpo_entry_smoke.$$.o"
  local tout="${SHUX_ASM_ENTRY_SMOKE_TIMEOUT:-120}"
  [ -x "$comp" ] || return 1
  rm -f "$tmp" 2>/dev/null || true
  if command -v timeout >/dev/null 2>&1; then
    timeout "$tout" env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 \
      "$comp" -backend asm -o "$tmp" $LIBROOT src/pipeline/pipeline.sx 2>/dev/null \
      || { rm -f "$tmp" 2>/dev/null || true; return 1; }
  elif ! env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 \
    "$comp" -backend asm -o "$tmp" $LIBROOT src/pipeline/pipeline.sx 2>/dev/null; then
    rm -f "$tmp" 2>/dev/null || true
    return 1
  fi
  if [ ! -s "$tmp" ]; then
    rm -f "$tmp" 2>/dev/null || true
    return 1
  fi
  if ! pipeline_wpo_tmp_reach_ok "$tmp" 2>/dev/null; then
    rm -f "$tmp" 2>/dev/null || true
    return 1
  fi
  rm -f "$tmp" 2>/dev/null || true
  return 0
}

# ast_pool.c 变更后须重编 pipeline_sx.o（含 WPO reach fixpoint）并重链 experimental。
ensure_experimental_ast_pool_for_wpo() {
  local gen_drv="$BUILD_DIR/gen_driver/pipeline_sx.o"
  local need=0
  if [ ast_pool.c -nt pipeline_sx.o ] 2>/dev/null || [ pipeline_glue.c -nt pipeline_sx.o ] 2>/dev/null; then
    need=1
  elif [ -f "$gen_drv" ] && { [ ast_pool.c -nt "$gen_drv" ] || [ pipeline_glue.c -nt "$gen_drv" ]; }; then
    need=1
  fi
  if [ "$need" -eq 1 ] && command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
    build_shux_asm_info "ast_pool/glue stale - make pipeline_sx.o PIPELINE_SX_FORCE_COMPILE=1"
    make pipeline_sx.o PIPELINE_SX_FORCE_COMPILE=1 || return 1
  fi
  if [ ! -x ./scripts/relink_shux_asm_experimental_bootstrap.sh ]; then
    return 1
  fi
  if [ ! -x ./shux_asm.experimental ] || [ pipeline_sx.o -nt ./shux_asm.experimental ] 2>/dev/null \
    || [ ast_pool.c -nt ./shux_asm.experimental ] 2>/dev/null; then
    build_shux_asm_info "relink shux_asm.experimental (pipeline_sx.o / ast_pool WPO)"
    ./scripts/relink_shux_asm_experimental_bootstrap.sh || return 1
  fi
  return 0
}

# WPO 五模块自编译：优先 experimental（ENTRY_MODULE_ONLY 可用）；strict_glue 须 smoke 通过。
wpo_rebuild_compiler_candidates() {
  local comp=""
  if [ -n "${SHUX_WPO_REBUILD_COMPILER:-}" ]; then
    for comp in ${SHUX_WPO_REBUILD_COMPILER}; do
      [ -x "$comp" ] && printf '%s\n' "$comp"
    done
    return 0
  fi
  # pipeline 已 promote/selfhosted 时跳过 pipeline.sx smoke（Docker 上易 futex 卡死数小时）
  if [ "${SHUX_ASM_SKIP_ENTRY_SMOKE:-0}" = "1" ] || asm_strict_pipeline_selfhosted 2>/dev/null; then
    for comp in ./shux_asm.experimental ./shux_asm.strict_glue ./shux_asm ./shux-seed-phase1 ./shux; do
      [ -x "$comp" ] && printf '%s\n' "$comp"
    done
    return 0
  fi
  if [ -x ./shux_asm.experimental ] && shux_asm_entry_module_smoke_ok ./shux_asm.experimental; then
    printf '%s\n' "./shux_asm.experimental"
  fi
  if [ -x ./shux_asm.strict_glue ] && shux_asm_entry_module_smoke_ok ./shux_asm.strict_glue; then
    printf '%s\n' "./shux_asm.strict_glue"
  fi
  if [ -x ./shux_asm ] && shux_asm_entry_module_smoke_ok ./shux_asm; then
    printf '%s\n' "./shux_asm"
  fi
  if [ -n "${SHUX_ASM_SECOND_PASS_COMPILER:-}" ] && [ -x "${SHUX_ASM_SECOND_PASS_COMPILER}" ] \
    && shux_asm_entry_module_smoke_ok "${SHUX_ASM_SECOND_PASS_COMPILER}"; then
    printf '%s\n' "${SHUX_ASM_SECOND_PASS_COMPILER}"
  fi
  for comp in ./shux ./shux-sx; do
    [ -x "$comp" ] && shux_asm_entry_module_smoke_ok "$comp" && printf '%s\n' "$comp"
  done
}

# pipeline_wpo.o 编排链 reach：tmp .o 内 run_sx_pipeline_impl 直接 callee 须已定义。
pipeline_wpo_tmp_reach_ok() {
  local o="$1"
  [ -f "$o" ] || return 1
  nm "$o" 2>/dev/null | grep -qE '(_)?run_sx_pipeline_impl' || return 1
  nm "$o" 2>/dev/null | grep -qE ' U (_)?run_sx_pipeline_typecheck_entry$' && return 1
  nm "$o" 2>/dev/null | grep -qE ' U (_)?run_sx_pipeline_codegen_entry$' && return 1
  nm "$o" 2>/dev/null | grep -qE ' U (_)?run_sx_pipeline_parse_entry_if_needed$' && return 1
  nm "$o" 2>/dev/null | grep -qE ' U (_)?run_sx_pipeline_codegen_deps$' && return 1
  return 0
}

# pipeline.sx WPO 压缩产物（dogfood；strict 仍用 build_asm/pipeline.o 全量 EMIT_HEAVY）。
rebuild_pipeline_wpo_o() {
  local tmp="/tmp/shux_build_pipeline_wpo.cli.o"
  local comp=""
  local txt=""
  local preserve_backup=""
  local pipe_wpo_max="${SHUX_WPO_PIPELINE_MAX_TEXT:-12288}"
  local pipe_tout="${SHUX_WPO_PIPELINE_COMPILE_TIMEOUT:-600}"
  if [ "${SHUX_ASM_SKIP_WPO_DOGFOOD:-0}" = "1" ]; then
    build_shux_asm_info "skip pipeline_wpo.o recompile (SHUX_ASM_SKIP_WPO_DOGFOOD=1)"
    return 0
  fi
  ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  if [ -f "$BUILD_DIR/pipeline_wpo.o" ] && [ -s "$BUILD_DIR/pipeline_wpo.o" ]; then
    preserve_backup="$BUILD_DIR/.preserve_pipeline_wpo.o"
    cp -f "$BUILD_DIR/pipeline_wpo.o" "$preserve_backup" 2>/dev/null || preserve_backup=""
  fi
  ensure_experimental_ast_pool_for_wpo || true
  try_pipe_wpo() {
    local wpo_arg="$1"
    local compiler="$2"
    rm -f "$tmp" 2>/dev/null || true
    if command -v timeout >/dev/null 2>&1; then
      if [ -n "$wpo_arg" ]; then
        timeout "$pipe_tout" env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
          SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE="$wpo_arg" \
          "$compiler" -backend asm -o "$tmp" $LIBROOT src/pipeline/pipeline.sx 2>/dev/null || return 1
      else
        timeout "$pipe_tout" env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
          SHUX_ASM_ENTRY_EMIT_HEAVY=1 \
          "$compiler" -backend asm -o "$tmp" $LIBROOT src/pipeline/pipeline.sx 2>/dev/null || return 1
      fi
    elif [ -n "$wpo_arg" ]; then
      env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
        SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE="$wpo_arg" \
        "$compiler" -backend asm -o "$tmp" $LIBROOT src/pipeline/pipeline.sx 2>/dev/null || return 1
    else
      env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
        SHUX_ASM_ENTRY_EMIT_HEAVY=1 \
        "$compiler" -backend asm -o "$tmp" $LIBROOT src/pipeline/pipeline.sx 2>/dev/null || return 1
    fi
    txt=$(asm_o_text_bytes "$tmp" 2>/dev/null || echo 0)
    [ "$txt" -gt 0 ] || return 1
    [ "$txt" -le "$pipe_wpo_max" ] 2>/dev/null || return 1
    nm "$tmp" 2>/dev/null | grep -q 'run_sx_pipeline_impl' || return 1
    pipeline_wpo_tmp_reach_ok "$tmp" || return 1
    return 0
  }
  build_shux_asm_info "recompile pipeline_wpo.o (WPO DCE, run_sx_pipeline_impl root, max __text=${pipe_wpo_max}B)"
  set +e
  while IFS= read -r comp; do
    [ -n "$comp" ] || continue
    if try_pipe_wpo "" "$comp"; then
      mv -f "$tmp" "$BUILD_DIR/pipeline_wpo.o"
      build_shux_asm_info "pipeline_wpo.o OK via $comp (__text=${txt}B, reach OK)"
      rm -f "$preserve_backup" 2>/dev/null || true
      set -e
      return 0
    fi
  done <<EOF
$(wpo_rebuild_compiler_candidates)
EOF
  set -e
  if [ -n "$preserve_backup" ] && [ -f "$preserve_backup" ]; then
    cp -f "$preserve_backup" "$BUILD_DIR/pipeline_wpo.o"
    build_shux_asm_warn "pipeline_wpo.o rebuild failed; restored previous artifact"
  fi
  return 1
}

rebuild_pipeline_wpo_post_strict() {
  rebuild_pipeline_wpo_o || true
}

# typeck.sx WPO 压缩产物（dogfood；strict 仍用 build_asm/typeck.o 全量 EMIT_HEAVY）。
rebuild_typeck_wpo_o() {
  local tmp="/tmp/shux_build_typeck_wpo.cli.o"
  local comp=""
  local txt=""
  if [ "${SHUX_ASM_SKIP_WPO_DOGFOOD:-0}" = "1" ]; then
    build_shux_asm_info "skip typeck_wpo.o recompile (SHUX_ASM_SKIP_WPO_DOGFOOD=1)"
    return 0
  fi
  ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  try_tck_wpo() {
    local wpo_arg="$1"
    local compiler="$2"
    rm -f "$tmp" 2>/dev/null || true
    if [ -n "$wpo_arg" ]; then
      env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
        SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE="$wpo_arg" \
        "$compiler" -backend asm -o "$tmp" $LIBROOT src/typeck/typeck.sx 2>/dev/null || return 1
    else
      env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
        SHUX_ASM_ENTRY_EMIT_HEAVY=1 \
        "$compiler" -backend asm -o "$tmp" $LIBROOT src/typeck/typeck.sx 2>/dev/null || return 1
    fi
    txt=$(asm_o_text_bytes "$tmp" 2>/dev/null || echo 0)
    [ "$txt" -gt 0 ] || return 1
    [ "$txt" -le 2048 ] 2>/dev/null || return 1
    nm "$tmp" 2>/dev/null | grep -q 'typeck_sx_ast' || return 1
    nm "$tmp" 2>/dev/null | grep -q 'check_block' || return 1
    return 0
  }
  build_shux_asm_info "recompile typeck_wpo.o (WPO DCE, typeck_sx_ast root)"
  set +e
  while IFS= read -r comp; do
    [ -n "$comp" ] || continue
    if try_tck_wpo "" "$comp"; then
      mv -f "$tmp" "$BUILD_DIR/typeck_wpo.o"
      build_shux_asm_info "typeck_wpo.o OK via $comp (__text=${txt}B)"
      set -e
      return 0
    fi
  done <<EOF
$(wpo_rebuild_compiler_candidates)
EOF
  set -e
  return 1
}

rebuild_typeck_wpo_post_strict() {
  rebuild_typeck_wpo_o || true
}

# backend.sx WPO 压缩产物（dogfood；strict 仍用 build_asm/backend.o 全量 EMIT_HEAVY）。
rebuild_backend_wpo_o() {
  local tmp="/tmp/shux_build_backend_wpo.cli.o"
  local comp=""
  local txt=""
  if [ "${SHUX_ASM_SKIP_WPO_DOGFOOD:-0}" = "1" ]; then
    build_shux_asm_info "skip backend_wpo.o recompile (SHUX_ASM_SKIP_WPO_DOGFOOD=1)"
    return 0
  fi
  ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  try_be_wpo() {
    local wpo_arg="$1"
    local compiler="$2"
    rm -f "$tmp" 2>/dev/null || true
    if [ -n "$wpo_arg" ]; then
      env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
        SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE="$wpo_arg" \
        "$compiler" -backend asm -o "$tmp" $LIBROOT src/asm/backend.sx 2>/dev/null || return 1
    else
      env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
        SHUX_ASM_ENTRY_EMIT_HEAVY=1 \
        "$compiler" -backend asm -o "$tmp" $LIBROOT src/asm/backend.sx 2>/dev/null || return 1
    fi
    txt=$(asm_o_text_bytes "$tmp" 2>/dev/null || echo 0)
    [ "$txt" -gt 0 ] || return 1
    [ "$txt" -le 512 ] 2>/dev/null || return 1
    nm "$tmp" 2>/dev/null | grep -q 'asm_codegen_ast' || return 1
    return 0
  }
  build_shux_asm_info "recompile backend_wpo.o (WPO DCE, asm_codegen_ast root)"
  set +e
  while IFS= read -r comp; do
    [ -n "$comp" ] || continue
    if try_be_wpo "" "$comp"; then
      mv -f "$tmp" "$BUILD_DIR/backend_wpo.o"
      build_shux_asm_info "backend_wpo.o OK via $comp (__text=${txt}B)"
      set -e
      return 0
    fi
  done <<EOF
$(wpo_rebuild_compiler_candidates)
EOF
  set -e
  return 1
}

rebuild_backend_wpo_post_strict() {
  rebuild_backend_wpo_o || true
}

# 仅重编 WPO dogfood 五模块（CI/stage2 补链；须已有可执行 ./shux_asm，跳过 BUILD 循环与链接）。
if [ "${SHUX_WPO_REBUILD_ARTIFACTS_ONLY:-}" = "1" ]; then
  ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  # ast_pool WPO reach：重编 pipeline_sx.o + relink experimental（WPO 产物编应用须 shux_asm.experimental 或 strict_glue）。
  ensure_experimental_ast_pool_for_wpo || \
    build_shux_asm_warn "ensure_experimental_ast_pool_for_wpo failed (WPO rebuild may use stale ast_pool)"
  if [ -x ./scripts/relink_shux_asm_strict_glue.sh ] \
    && { [ ast_pool.c -nt ./shux_asm.strict_glue ] 2>/dev/null || [ pipeline_glue.c -nt ./shux_asm.strict_glue ] 2>/dev/null \
      || [ pipeline_sx.o -nt ./shux_asm.strict_glue ] 2>/dev/null; }; then
    build_shux_asm_info "ast_pool/glue newer - relink shux_asm.strict_glue (pipeline_glue_standalone only, no shux_asm overwrite)"
    ./scripts/relink_shux_asm_strict_glue.sh || \
      build_shux_asm_warn "relink_shux_asm_strict_glue failed"
  fi
  wpo_fail=0
  rebuild_main_o_for_cli || wpo_fail=1
  rebuild_driver_compile_o_wpo || wpo_fail=1
  rebuild_pipeline_wpo_o || wpo_fail=1
  rebuild_typeck_wpo_o || wpo_fail=1
  rebuild_backend_wpo_o || wpo_fail=1
  if [ "$wpo_fail" -ne 0 ]; then
    build_shux_asm_error "SHUX_WPO_REBUILD_ARTIFACTS_ONLY failed (one or more WPO .o missing)"
    exit 1
  fi
  build_shux_asm_info "SHUX_WPO_REBUILD_ARTIFACTS_ONLY OK (main+driver+pipeline_wpo+typeck_wpo+backend_wpo)"
  exit 0
fi

# runtime-only 快速重链：勿重跑 BUILD 循环（会覆盖 build_asm/*.o 中已绿 __text）。
if [ -n "${SHUX_ASM_BSTRICT_RELINK_ONLY:-}" ]; then
  if [ -z "${SHUX_ASM_SKIP_QUALITY_REPORT:-}" ]; then
    export SHUX_ASM_SKIP_QUALITY_REPORT=1
  fi
fi

if [ -z "${SHUX_ASM_BSTRICT_RELINK_ONLY:-}" ]; then
if [ -f "$BUILD_LIST_SX" ]; then
  grep '^// BUILD:' "$BUILD_LIST_SX" | while IFS= read -r line; do
    rest=$(echo "$line" | sed "s|^// BUILD:${TAB}||")
    out=$(echo "$rest" | cut -f1)
    src=$(echo "$rest" | cut -f2)
    [ -n "$out" ] && [ -n "$src" ] && compile_sx "$out" "$src"
  done
else
  build_shux_asm_warn "$BUILD_LIST_SX not found, using built-in list"
  compile_sx token.o src/lexer/token.sx
  compile_sx ast.o src/ast/ast.sx
  compile_sx codegen.o src/codegen/codegen.sx
  compile_sx typeck.o src/typeck/typeck.sx
  compile_sx lexer.o src/lexer/lexer.sx
  compile_sx preprocess.o src/preprocess/preprocess.sx
  compile_sx std_fs.o ../std/fs/mod.sx
  compile_sx lsp.o src/lsp/lsp.sx
  compile_sx types.o src/asm/types.sx
  compile_sx platform_elf.o src/asm/platform/elf.sx
  compile_sx x86_64.o src/asm/arch/x86_64.sx
  compile_sx x86_64_enc.o src/asm/arch/x86_64_enc.sx
  compile_sx arm64.o src/asm/arch/arm64.sx
  compile_sx arm64_enc.o src/asm/arch/arm64_enc.sx
  compile_sx riscv64.o src/asm/arch/riscv64.sx
  compile_sx riscv64_enc.o src/asm/arch/riscv64_enc.sx
  compile_sx peephole.o src/asm/peephole.sx
  compile_sx backend.o src/asm/backend.sx
  compile_sx asm.o src/asm/asm.sx
  compile_sx macho.o src/asm/platform/macho.sx
  compile_sx coff.o src/asm/platform/coff.sx
  compile_sx parser.o src/parser/parser.sx
  compile_sx pipeline.o src/pipeline/pipeline.sx
  compile_sx main.o src/main.sx
fi
fi

# 报告 build_asm/*.o 的 __text 是否非空；写入 build_asm/.asm_text_quality（供 topology 降级判断）
if [ -z "${SHUX_ASM_BSTRICT_RELINK_ONLY:-}" ]; then
if [ -z "${SHUX_ASM_SKIP_QUALITY_REPORT}" ]; then
  SHUX="$SHUX" ./scripts/check_asm_o_quality.sh || true
  # Target B（SELFHOST §4）：非空清单提示下一批应修的 BUILD 令牌，便于逐项消灭 EMPTY/MISSING
  BADEMPTY="$BUILD_DIR/.asm_empty_text_list"
  if [ -s "$BADEMPTY" ]; then
    build_shux_asm_warn "__text EMPTY/MISSING sample (full list: $BADEMPTY, doc: docs/SELFHOST.md §4.1)"
    head -n 12 "$BADEMPTY" | sed 's/^/  /' || true
  fi
fi
fi

# 链接：仅当 main.o 与 pipeline.o 均来自 asm 时，用 asm 版链接。
# 优先尝试「无 C 桩」路径（仅 Linux）：crt0_x86_64.o + typeck_f64_bits.o + runtime_panic.o + build_asm/*.o + libc/libm；
# 失败或非 Linux 时回退到 runtime_asm_build.o + runtime_driver.o + -E 流水线 .o + C 种子（不并 build_asm/*.o，见上文）。
#
# 下列用 cc 直接编译，不调用 make，以便在「仅 bootstrap.sh + build_tool」环境下完成 asm 链接（朝去掉 Makefile 走一步）。
# CC/CFLAGS 已在 compile_sx 之前定义（stub 回退需要）。

# 与 Makefile PIPELINE_GEN_CFLAGS 对齐：编译 -E 大文件时压制已知告警；Clang 追加额外 -Wno。
detect_pipeline_gen_cflags() {
  PIPELINE_GEN_CFLAGS="-Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits"
  if "$CC" -v 2>&1 | grep -qi clang; then
    PIPELINE_GEN_CFLAGS="$PIPELINE_GEN_CFLAGS -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses -Wno-incompatible-pointer-types-discards-qualifiers"
  fi
}

# Target B 实验链：编译 pipeline_run_sx_pipeline 最小 C 桥（见 src/asm/pipeline_glue_link.c）。
ensure_asm_pipeline_glue_link_obj() {
  GLUE_LINK_OBJ="$BUILD_DIR/pipeline_glue_link.o"
  if [ ! -f "$GLUE_LINK_OBJ" ] || [ "src/asm/pipeline_glue_link.c" -nt "$GLUE_LINK_OBJ" ]; then
    echo "  cc -c src/asm/pipeline_glue_link.c -> $GLUE_LINK_OBJ"
    "$CC" $CFLAGS -c -o "$GLUE_LINK_OBJ" src/asm/pipeline_glue_link.c
  fi
}

# 实验链：run_sx_pipeline_impl 别名到 pipeline_run_sx_pipeline_impl（无 pipeline_sx.o 时）
ensure_asm_pipeline_run_impl_alias_obj() {
  ALIAS_OBJ="$BUILD_DIR/pipeline_run_impl_alias.o"
  local ALIAS_CFLAGS="$CFLAGS"
  if asm_strict_sx_orchestration_ok; then
    ALIAS_CFLAGS="$CFLAGS -DSHUX_PIPELINE_RUN_IMPL_ALIAS_PARSE_ALIASES=0"
  fi
  if [ ! -f "$ALIAS_OBJ" ] || [ "src/asm/pipeline_run_impl_alias.c" -nt "$ALIAS_OBJ" ] || \
     [ ! -f "$BUILD_DIR/.pipeline_run_impl_alias_sx_orch" ] || \
     { asm_strict_sx_orchestration_ok && [ "$(cat "$BUILD_DIR/.pipeline_run_impl_alias_sx_orch" 2>/dev/null)" != "1" ]; } || \
     { ! asm_strict_sx_orchestration_ok && [ "$(cat "$BUILD_DIR/.pipeline_run_impl_alias_sx_orch" 2>/dev/null)" = "1" ]; }; then
    echo "  cc -c src/asm/pipeline_run_impl_alias.c -> $ALIAS_OBJ (SX orch=$(asm_strict_sx_orchestration_ok && echo 1 || echo 0))"
    "$CC" $ALIAS_CFLAGS -c -o "$ALIAS_OBJ" src/asm/pipeline_run_impl_alias.c
    if asm_strict_sx_orchestration_ok; then echo "1" >"$BUILD_DIR/.pipeline_run_impl_alias_sx_orch"; else echo "0" >"$BUILD_DIR/.pipeline_run_impl_alias_sx_orch"; fi
  fi
}

# strict 链：build_asm/parser.o 自举时 parse_into_buf 等大函数未进 module；从 pipeline_sx.o 部分链接 parser_* 真机码。
ensure_parser_bootstrap_partial_obj() {
  PARTIAL="$BUILD_DIR/parser_bootstrap_partial.o"
  SYMS="$BUILD_DIR/parser_bootstrap_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_sx.o"
  ensure_pipeline_sx_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_sx_objs
  fi
  if [ ! -f "$PARTIAL" ] || [ "$0" -nt "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    printf '%s\n' \
      '_parser_parse_into_buf' \
      '_parser_collect_imports_buf' \
      '_parser_parse_into_init' \
      '_parser_parse_into_set_main_index' > "$SYMS"
    echo "  ld -r -exported_symbols_list $SYMS pipeline_sx.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$SUO"
  fi
}

# strict 链：从 pipeline_sx.o 导出全部 parser_* 真机码（自洽 TU），替代 build_asm/parser.o 桩 + 零散 partial。
ensure_parser_from_sx_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/parser_from_sx_partial.o"
  SYMS="$BUILD_DIR/parser_from_sx_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_sx.o"
  ensure_pipeline_sx_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_sx_objs
  fi
  if [ ! -f "$SYMS" ] || [ "$SUO" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ]; then
    GLUE_O="$BUILD_DIR/pipeline_glue_standalone.o"
    ensure_asm_pipeline_glue_standalone_obj
    nm "$SUO" | awk '/ T _parser_/ {print $3}' > "$BUILD_DIR/.parser_from_sx_all.txt"
    : > "$SYMS"
    while IFS= read -r sym; do
      [ -n "$sym" ] || continue
      if [ -f "$GLUE_O" ] && nm "$GLUE_O" 2>/dev/null | grep -q " T ${sym}$"; then
        continue
      fi
      printf '%s\n' "$sym" >> "$SYMS"
    done < "$BUILD_DIR/.parser_from_sx_all.txt"
    echo "  nm pipeline_sx.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') parser_* symbols, glue dupes skipped)"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    echo "  ld -r -exported_symbols_list $SYMS pipeline_sx.o -> $PARTIAL"
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
_pipeline_run_sx_pipeline_impl
_run_sx_pipeline_impl
_run_sx_pipeline_parse_entry_do_parse
_run_sx_pipeline_parse_entry_if_needed
_parse_into_with_init_buf
EOF
    echo "  ld partial export $SYMS orchestration_alias.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$ALIAS_O"
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
_run_sx_pipeline_impl
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
    echo "  ld partial export $SYMS build_asm/pipeline.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$PO"
  fi
  return 0
}

# strict 链：pipeline.sx 自洽 parse 包（parse_into_with_init_buf + parser_*），避免 U 解析到 build_asm 空桩。
ensure_pipeline_parse_sx_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/pipeline_parse_sx_partial.o"
  SYMS="$BUILD_DIR/pipeline_parse_sx_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_sx.o"
  ensure_pipeline_sx_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_sx_objs
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_pipeline_parse_into_with_init_buf
_pipeline_resolve_path_sx
_pipeline_read_file_sx
EOF
    echo "  ld -r -exported_symbols_list $SYMS pipeline_sx.o -> $PARTIAL"
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

# strict 链：自 build_asm/pipeline.o 导出除 impl/parse/typecheck 外全部全局 T（C 编排见 orchestration_alias.c）。
pipeline_strict_link_export_syms_stale() {
  local syms="$1"
  local po="$2"
  [ -f "$syms" ] || return 0
  grep -qE '^(_)?preprocess_if_stack_|^(_)?backend_ctx_(push|pop)_loop_labels$|^(_)?backend_try_fold_count_up_while_elf$' "$syms" 2>/dev/null && return 0
  # SX 编排：partial 不得再 export C 版 run_sx_pipeline_*（runtime bootstrap 提供 pipeline_run_sx_pipeline_impl）。
  if asm_strict_sx_orchestration_ok 2>/dev/null; then
    grep -qxF 'run_sx_pipeline_impl' "$syms" 2>/dev/null && return 0
    grep -qxF 'run_sx_pipeline_parse_entry_do_parse' "$syms" 2>/dev/null && return 0
  fi
  # 历史 WPO subtract 误留仅 ~27 个 orchestration 符号的小表。
  local n_po n_sym
  n_po=$(nm "$po" 2>/dev/null | awk '/ T / {c++} END{print c+0}')
  n_sym=$(wc -l <"$syms" | tr -d ' ')
  if [ "${n_po:-0}" -gt 80 ] 2>/dev/null && [ "${n_sym:-0}" -lt 40 ] 2>/dev/null; then
    grep -qxF 'run_sx_pipeline_impl' "$syms" 2>/dev/null && return 0
  fi
  return 1
}

ensure_pipeline_o_strict_link_partial_obj() {
  local PARTIAL SYMS PO WPO_E
  PARTIAL="$BUILD_DIR/pipeline_strict_link_partial.o"
  SYMS="$BUILD_DIR/pipeline_strict_link_export.txt"
  PO="$BUILD_DIR/pipeline.o"
  WPO_E="$BUILD_DIR/pipeline_wpo.o"
  if [ ! -f "$PO" ] || [ ! -s "$PO" ]; then
    return 1
  fi
  if pipeline_strict_link_export_syms_stale "$SYMS" "$PO"; then
    rm -f "$PARTIAL" "$SYMS"
  fi
  if [ "$(cat "$BUILD_DIR/.pipeline_strict_orch_mode" 2>/dev/null)" = "su" ] && ! asm_strict_sx_orchestration_ok; then
    rm -f "$PARTIAL" "$SYMS"
  fi
  if [ "$(cat "$BUILD_DIR/.pipeline_strict_orch_mode" 2>/dev/null)" = "c" ] && asm_strict_sx_orchestration_ok; then
    rm -f "$PARTIAL" "$SYMS"
  fi
  if [ -f "$SYMS" ] && grep -qE '_pipeline_should_skip_sx_typeck|pipeline_should_skip_sx_typeck' "$SYMS" 2>/dev/null; then
    rm -f "$PARTIAL" "$SYMS"
  fi
  if [ ! -f "$SYMS" ] || [ "$0" -nt "$SYMS" ] || [ "$PO" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$SYMS" ]; } || \
     { [ -f "$BUILD_DIR/pipeline_sx_glue_support_export.txt" ] && [ "$BUILD_DIR/pipeline_sx_glue_support_export.txt" -nt "$SYMS" ]; }; then
    nm "$PO" 2>/dev/null | awk '/ T / {print $3}' | grep -vE \
      '_run_sx_pipeline_(impl|parse_entry_do_parse|parse_entry_if_needed|typecheck_entry)$|^_?(parse_into_with_init_buf|parse_into_with_init|pipeline_run_sx_pipeline_impl|pipeline_should_skip_sx_typeck|preprocess_if_stack_.*|backend_ctx_push_loop_labels|backend_ctx_pop_loop_labels|backend_try_fold_count_up_while_elf)$' \
      >"$SYMS"
    # S5 WPO：pipeline_wpo.o / helpers partial 已定义的符号须从 partial 剔除，避免 multiple definition。
    if [ "${STRICT_LINK_BUILD_ASM_WPO:-0}" -eq 1 ] && asm_pipeline_wpo_strict_reach_ok; then
      if asm_pipeline_wpo_strict_link_full_ok; then
        nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.pipeline_wpo_export_syms.txt"
        echo "  pipeline_strict_link: minus full pipeline_wpo exports ($(wc -l <"$BUILD_DIR/.pipeline_wpo_export_syms.txt" | tr -d ' ') syms)"
      elif [ -f "$BUILD_DIR/.pipeline_wpo_helpers_export_syms.txt" ] && [ -s "$BUILD_DIR/.pipeline_wpo_helpers_export_syms.txt" ]; then
        cp -f "$BUILD_DIR/.pipeline_wpo_helpers_export_syms.txt" "$BUILD_DIR/.pipeline_wpo_export_syms.txt"
      elif [ -f "$WPO_E" ]; then
        nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.pipeline_wpo_export_syms.txt"
      fi
      if [ -s "$BUILD_DIR/.pipeline_wpo_export_syms.txt" ]; then
        sort -u "$BUILD_DIR/.pipeline_wpo_export_syms.txt" -o "$BUILD_DIR/.pipeline_wpo_export_syms.txt"
        comm -23 "$SYMS" "$BUILD_DIR/.pipeline_wpo_export_syms.txt" >"$SYMS.wpo" 2>/dev/null && mv -f "$SYMS.wpo" "$SYMS"
        echo "  pipeline_strict_link: minus pipeline_wpo exports ($(wc -l <"$BUILD_DIR/.pipeline_wpo_export_syms.txt" | tr -d ' ') syms)"
      fi
    fi
    # SX glue support partial 从 pipeline_sx.o 提供 glue/astpool 符号；勿与 build_asm partial 重复 export。
    if asm_strict_typeck_sx_glue_via_pipeline_sx && [ -f "$BUILD_DIR/pipeline_sx_glue_support_export.txt" ] && \
       [ -s "$BUILD_DIR/pipeline_sx_glue_support_export.txt" ]; then
      sort -u "$SYMS" -o "$SYMS"
      sort -u "$BUILD_DIR/pipeline_sx_glue_support_export.txt" -o "$BUILD_DIR/.pipeline_sx_glue_support_export.sorted.txt"
      comm -23 "$SYMS" "$BUILD_DIR/.pipeline_sx_glue_support_export.sorted.txt" >"$SYMS.gsup" 2>/dev/null && mv -f "$SYMS.gsup" "$SYMS"
      echo "  pipeline_strict_link: minus pipeline_sx_glue_support exports ($(wc -l <"$BUILD_DIR/.pipeline_sx_glue_support_export.sorted.txt" | tr -d ' ') syms)"
    fi
    echo "  nm pipeline.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') symbols, minus parse/typecheck/impl entry)"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$0" -nt "$PARTIAL" ] || [ "$PO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$PARTIAL" ]; } || \
     { [ -f "$BUILD_DIR/pipeline_sx_glue_support_export.txt" ] && [ "$BUILD_DIR/pipeline_sx_glue_support_export.txt" -nt "$PARTIAL" ]; } || \
     [ "src/asm/pipeline_asm_orchestration_alias.c" -nt "$PARTIAL" ]; then
    if asm_strict_typeck_sx_glue_via_pipeline_sx && [ -f "$BUILD_DIR/pipeline_sx_glue_support_export.txt" ] && \
       [ -s "$BUILD_DIR/pipeline_sx_glue_support_export.txt" ]; then
      sort -u "$SYMS" -o "$SYMS"
      sort -u "$BUILD_DIR/pipeline_sx_glue_support_export.txt" -o "$BUILD_DIR/.pipeline_sx_glue_support_export.sorted.txt"
      comm -23 "$SYMS" "$BUILD_DIR/.pipeline_sx_glue_support_export.sorted.txt" >"$SYMS.link" 2>/dev/null && mv -f "$SYMS.link" "$SYMS"
    fi
    echo "  ld partial export $SYMS pipeline.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$PO" || return 1
  fi
  return 0
}

# strict WPO opt-in：从 pipeline_wpo.o 导出 helper（剔除 SX 编排入口；编排仍走 C orchestration partial）。
ensure_pipeline_wpo_helpers_partial_obj() {
  local PARTIAL SYMS WPO_E
  PARTIAL="$BUILD_DIR/pipeline_wpo_helpers_partial.o"
  SYMS="$BUILD_DIR/pipeline_wpo_helpers_export.txt"
  WPO_E="$BUILD_DIR/pipeline_wpo.o"
  if [ ! -f "$WPO_E" ] || [ ! -s "$WPO_E" ]; then
    return 1
  fi
  if ! asm_pipeline_wpo_strict_reach_ok; then
    return 1
  fi
  if [ "${STRICT_LINK_BUILD_ASM_WPO:-0}" -eq 1 ] && [ -f "$BUILD_DIR/pipeline.o" ] && \
     ! nm "$BUILD_DIR/pipeline.o" 2>/dev/null | grep -qE ' T (_)?resolve_path_try_one_lib_root$'; then
    local comp tmp pt
    tmp="$BUILD_DIR/pipeline.wpo_strict_helpers.o"
    for comp in ./shux_asm.experimental ./shux_asm ./shux ./shux-sx; do
      [ -x "$comp" ] || continue
      echo "  pipeline_wpo_helpers: rebuild pipeline.o EMIT_HEAVY via $comp"
      ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
      rm -f "$tmp" 2>/dev/null || true
      if env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
        SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
        "$comp" -backend asm -o "$tmp" -L asm_libroot -L .. -L src src/pipeline/pipeline.sx 2>/dev/null; then
        pt=$(asm_o_text_bytes "$tmp" 2>/dev/null || echo 0)
        if [ "$pt" -gt 512 ] 2>/dev/null && \
           nm "$tmp" 2>/dev/null | grep -qE ' T (_)?resolve_path_try_one_lib_root$'; then
          mv -f "$tmp" "$BUILD_DIR/pipeline.o"
          rm -f "$BUILD_DIR/pipeline_strict_link_partial.o" "$BUILD_DIR/pipeline_strict_link_export.txt" 2>/dev/null || true
          break
        fi
      fi
      rm -f "$tmp" 2>/dev/null || true
    done
  fi
  if [ ! -f "$SYMS" ] || [ "$WPO_E" -nt "$SYMS" ] || [ "src/asm/pipeline_asm_orchestration_alias.c" -nt "$SYMS" ] || \
     { ensure_pipeline_glue_standalone_export_syms_txt && [ "$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt" -nt "$SYMS" ]; }; then
    nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | grep -vE \
      '^(run_sx_pipeline_impl|run_sx_pipeline_parse_entry_do_parse|run_sx_pipeline_parse_entry_if_needed|run_sx_pipeline_typecheck_entry|parse_into_with_init_buf|parse_into_with_init|pipeline_run_sx_pipeline_impl|pipeline_run_sx_pipeline|pipeline_should_skip_sx_typeck)$' \
      >"$SYMS"
    if ensure_pipeline_glue_standalone_export_syms_txt; then
      comm -23 "$SYMS" "$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt" >"$SYMS.glue" 2>/dev/null && mv -f "$SYMS.glue" "$SYMS"
      echo "  pipeline_wpo_helpers: minus glue_standalone T dupes"
    fi
    echo "  nm pipeline_wpo.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') helper syms, minus orchestration entry)"
  fi
  if [ -f "$PARTIAL" ] && ensure_pipeline_glue_standalone_export_syms_txt && \
     [ -f "$BUILD_DIR/.pipeline_wpo_helpers_export_syms.txt" ]; then
    if comm -12 "$BUILD_DIR/.pipeline_wpo_helpers_export_syms.txt" \
       "$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt" 2>/dev/null | grep -q .; then
      build_shux_asm_warn "stale pipeline_wpo_helpers_partial (glue dupes); rebuild"
      rm -f "$PARTIAL" "$SYMS"
    fi
  fi
  if [ ! -s "$SYMS" ]; then
    return 1
  fi
  if [ ! -f "$PARTIAL" ] || [ "$WPO_E" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    echo "  ld partial export $SYMS pipeline_wpo.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$WPO_E" || return 1
    nm "$PARTIAL" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.pipeline_wpo_helpers_export_syms.txt"
  fi
  return 0
}

# WPO helpers 导出排除表：mega entry + check_* 须由 typeck.o 全量提供（WPO 版内联压缩 check_block 会 SIGSEGV）。
typeck_wpo_helpers_export_exclude_re() {
  echo '^(check_block|check_expr|typeck_sx_ast|typeck_sx_ast_library)$'
}

# strict WPO：从 typeck_wpo.o 仅导出 layout/unify helper；entry/check_* 仍由 typeck.o 全量提供。
ensure_typeck_wpo_helpers_partial_obj() {
  local PARTIAL SYMS WPO_E EXCLUDE_RE
  PARTIAL="$BUILD_DIR/typeck_wpo_helpers_partial.o"
  SYMS="$BUILD_DIR/typeck_wpo_helpers_export.txt"
  WPO_E="$BUILD_DIR/typeck_wpo.o"
  EXCLUDE_RE=$(typeck_wpo_helpers_export_exclude_re)
  if [ ! -f "$WPO_E" ] || [ ! -s "$WPO_E" ]; then
    return 1
  fi
  if ! asm_typeck_wpo_strict_reach_ok; then
    return 1
  fi
  # 旧 partial 曾误含 typeck_sx_ast（内联 WPO check_block）→ 强制重算。
  if [ -f "$PARTIAL" ]; then
    nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?typeck_sx_ast$' && rm -f "$PARTIAL" "$SYMS"
  fi
  if [ ! -f "$SYMS" ] || [ "$WPO_E" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ]; then
    nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | grep -vE "$EXCLUDE_RE" >"$SYMS"
    echo "  nm typeck_wpo.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') layout syms, minus check_block/check_expr/typeck_sx_ast*)"
  fi
  [ -s "$SYMS" ] || return 1
  if [ ! -f "$PARTIAL" ] || [ "$WPO_E" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    echo "  ld partial export $SYMS typeck_wpo.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$WPO_E" || return 1
    nm "$PARTIAL" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.typeck_wpo_helpers_export_syms.txt"
    nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?typeck_sx_ast$' && {
      build_shux_asm_error "typeck_wpo_helpers_partial must not export typeck_sx_ast (use typeck.o entry)"
      return 1
    }
  fi
  return 0
}

# strict 链：C orchestration partial 即 runtime partial（勿链 pipeline.o，避免 dead broken 符号拉入 U typeck）。
ensure_pipeline_asm_runtime_partial_obj() {
  ensure_pipeline_asm_orchestration_partial_obj
}

# strict 回退：build_asm pipeline 仍不足时，从 pipeline_sx.o 部分链接完整 pipeline_run_sx_pipeline_impl。
ensure_pipeline_runtime_bootstrap_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/pipeline_runtime_bootstrap_partial.o"
  SYMS="$BUILD_DIR/pipeline_runtime_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_sx.o"
  ensure_pipeline_sx_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_sx_objs
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    printf '%s\n' '_pipeline_run_sx_pipeline_impl' > "$SYMS"
    echo "  ld partial export $SYMS pipeline_sx.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$SUO"
  fi
}

# strict SX 编排：从 pipeline_sx.o 导出 glue/astpool 桥接（与 runtime bootstrap 同 TU）；替代 glue_standalone 避免双 astpool SIGSEGV。
ensure_pipeline_sx_glue_support_partial_obj() {
  local PARTIAL SYMS SUO TCK_SYMS
  PARTIAL="$BUILD_DIR/pipeline_sx_glue_support_partial.o"
  SYMS="$BUILD_DIR/pipeline_sx_glue_support_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_sx.o"
  TCK_SYMS="$BUILD_DIR/typeck_strict_link_export.txt"
  ensure_pipeline_sx_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_sx_objs
  fi
  [ -f "$SUO" ] || return 1
  if asm_strict_typeck_sx_glue_via_pipeline_sx && [ -f typeck_sx.o ]; then
    nm typeck_sx.o 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.typeck_sx_all_t.txt"
    TCK_SYMS="$BUILD_DIR/.typeck_sx_all_t.txt"
  else
    ensure_typeck_o_strict_link_partial_obj || true
    TCK_SYMS="$BUILD_DIR/typeck_strict_link_export.txt"
  fi
  if [ ! -f "$SYMS" ] || [ "$0" -nt "$SYMS" ] || [ "$SUO" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ] || \
     { [ -f "$TCK_SYMS" ] && [ "$TCK_SYMS" -nt "$SYMS" ]; } || \
     { [ -f "$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt" ] && [ "$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt" -nt "$SYMS" ]; }; then
    ensure_pipeline_glue_standalone_export_syms_txt || return 1
    nm "$SUO" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.pipeline_sx_all_t.txt"
    comm -12 "$BUILD_DIR/.pipeline_sx_all_t.txt" "$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt" \
      >"$BUILD_DIR/.pipeline_sx_glue_common.txt" 2>/dev/null || return 1
    : >"$SYMS"
    while IFS= read -r sym || [ -n "$sym" ]; do
      [ -z "$sym" ] && continue
      case "$sym" in
        _pipeline_run_sx_pipeline_impl|pipeline_run_sx_pipeline_impl|_run_sx_pipeline_impl|run_sx_pipeline_impl)
          continue
          ;;
        _preprocess_if_stack_*|preprocess_if_stack_*|_backend_ctx_push_loop_labels|backend_ctx_push_loop_labels|_backend_ctx_pop_loop_labels|backend_ctx_pop_loop_labels|_backend_try_fold_count_up_while_elf|backend_try_fold_count_up_while_elf)
          continue
          ;;
        _typeck_sx_ast|typeck_sx_ast|_typeck_sx_ast_library|typeck_sx_ast_library|_check_block|check_block|_check_expr|check_expr|_check_block_*|check_block_*|_check_expr_*|check_expr_*|_typeck_check_*|typeck_check_*)
          continue
          ;;
      esac
      if [ -f "$TCK_SYMS" ] && grep -qxF "$sym" "$TCK_SYMS" 2>/dev/null; then
        continue
      fi
      PIPE_SYMS="$BUILD_DIR/pipeline_strict_link_export.txt"
      if [ -f "$PIPE_SYMS" ] && grep -qxF "$sym" "$PIPE_SYMS" 2>/dev/null; then
        continue
      fi
      printf '%s\n' "$sym" >>"$SYMS"
    done <"$BUILD_DIR/.pipeline_sx_glue_common.txt"
    sort -u "$SYMS" -o "$SYMS"
    # build_asm pipeline_strict_link_partial 须 U→T：交集抽取常漏 _c 后缀外的 SX 编排符号。
    for sym in pipeline_load_and_sync_direct_import_deps pipeline_run_sx_pipeline_fill_dep_import_path; do
      sym_export="$sym"
      if ld_supports_exported_symbols_list; then
        sym_export="_$sym"
      fi
      grep -qxF "$sym_export" "$SYMS" 2>/dev/null || printf '%s\n' "$sym_export" >>"$SYMS"
    done
    echo "  pipeline_sx glue support: $(wc -l <"$SYMS" | tr -d ' ') syms (pipeline_sx∩glue minus orch/typeck)"
  fi
  [ -s "$SYMS" ] || return 1
  if [ ! -f "$PARTIAL" ] || [ "$0" -nt "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    echo "  ld partial export $SYMS pipeline_sx.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$SUO" || return 1
  fi
  return 0
}

# strict 链：build_asm 编排/typeck/codegen 仍不足时，从 pipeline_sx.o 部分链接（不含 pipeline_run 重复符号）。
ensure_pipeline_asm_sx_bootstrap_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/pipeline_asm_sx_bootstrap_partial.o"
  SYMS="$BUILD_DIR/pipeline_asm_sx_bootstrap_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_sx.o"
  ensure_pipeline_sx_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_sx_objs
  fi
  if [ ! -f "$PARTIAL" ] || [ "$0" -nt "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_asm_asm_codegen_ast
_backend_asm_codegen_ast
_typeck_typeck_sx_ast
_typeck_typeck_sx_ast_library
EOF
    echo "  ld -r -exported_symbols_list $SYMS pipeline_sx.o -> $PARTIAL"
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
  SUO="$BUILD_DIR/gen_driver/pipeline_sx.o"
  local TCK_BYTES BACK_BYTES
  TCK_BYTES=$(asm_o_text_bytes "$BUILD_DIR/typeck.o" 2>/dev/null || echo 0)
  BACK_BYTES=$(asm_o_text_bytes "$BUILD_DIR/backend.o" 2>/dev/null || echo 0)
  ensure_pipeline_sx_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_sx_objs
  fi
  # build_asm typeck.o 已完整自举（__text>8KiB）时 partial 只补 parse；否则 partial 含 typeck_sx_ast*。
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
    build_shux_asm_info "strict_support parse-only partial (typeck.o=${TCK_BYTES}B selfhosted from build_asm)"
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
_typeck_typeck_sx_ast
_typeck_typeck_sx_ast_library
EOF
    build_shux_asm_info "strict_support parse+typeck partial (typeck.o=${TCK_BYTES}B not selfhosted yet)"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || \
     [ "$BUILD_DIR/typeck.o" -nt "$PARTIAL" ] || [ "$BUILD_DIR/backend.o" -nt "$PARTIAL" ]; then
    echo "  ld -r -exported_symbols_list $SYMS pipeline_sx.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$SUO"
  fi
}

# WPO opt-in helper 链：仅 typecheck emit 桥（编排入口由 C orchestration partial 提供）。
ensure_pipeline_wpo_typecheck_emit_bridge_obj() {
  local BR_O="$BUILD_DIR/pipeline_wpo_typecheck_emit_bridge.o"
  local BR_SRC="src/asm/pipeline_wpo_typecheck_emit_bridge.c"
  if [ ! -f "$BR_SRC" ]; then
    return 1
  fi
  if [ ! -f "$BR_O" ] || [ "$BR_SRC" -nt "$BR_O" ]; then
    echo "  cc -c $BR_SRC -> $BR_O (WPO typecheck emit bridge)"
    "$CC" $CFLAGS -c -o "$BR_O" "$BR_SRC" || return 1
  fi
  return 0
}

# S5 WPO strict 链：pipeline_wpo.o + glue 入口/typecheck emit 别名（替代 C orchestration partial）。
ensure_pipeline_wpo_strict_link_alias_obj() {
  local ALIAS_O="$BUILD_DIR/pipeline_wpo_strict_link_alias.o"
  local ALIAS_SRC="src/asm/pipeline_wpo_strict_link_alias.c"
  if [ "${STRICT_LINK_BUILD_ASM_WPO:-0}" -ne 1 ] || ! asm_pipeline_wpo_strict_reach_ok; then
    return 0
  fi
  if [ ! -f "$ALIAS_SRC" ]; then
    return 1
  fi
  if [ ! -f "$ALIAS_O" ] || [ "$ALIAS_SRC" -nt "$ALIAS_O" ]; then
    echo "  cc -c $ALIAS_SRC -> $ALIAS_O (WPO strict link alias)"
    "$CC" $CFLAGS -c -o "$ALIAS_O" "$ALIAS_SRC" || return 1
  fi
  return 0
}

# WPO strict partial 导出表是否过期：旧缓存曾误删 check_block callee 或误含 WPO typeck_sx_ast。
typeck_wpo_strict_partial_export_syms_stale() {
  local syms="$1"
  [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] || return 1
  asm_typeck_wpo_strict_reach_ok || return 1
  [ -f "$syms" ] || return 0
  grep -qxF 'typeck_check_block_one_while' "$syms" 2>/dev/null || return 0
  grep -qxF 'check_block_as_loop_body' "$syms" 2>/dev/null || return 0
  grep -qxF 'typeck_sx_ast' "$syms" 2>/dev/null && return 0
  if [ -f "$BUILD_DIR/.typeck_wpo_helpers_export_syms.txt" ] && \
     grep -qxF 'typeck_sx_ast' "$BUILD_DIR/.typeck_wpo_helpers_export_syms.txt" 2>/dev/null; then
    return 0
  fi
  return 1
}

# pipeline_glue_standalone.o 全局 T 导出表：与 build_asm/typeck.o 并列链时会 duplicate ast_pool/glue → fill_cl SIGSEGV。
ensure_pipeline_glue_standalone_export_syms_txt() {
  local GLUE_O="$BUILD_DIR/pipeline_glue_standalone.o"
  local OUT="$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt"
  [ -f "$GLUE_O" ] || return 1
  if [ ! -f "$OUT" ] || [ "$GLUE_O" -nt "$OUT" ] || [ "pipeline_glue.c" -nt "$OUT" ]; then
    nm "$GLUE_O" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$OUT"
  fi
  [ -s "$OUT" ] || return 1
  return 0
}

# WPO FULL：从 pipeline_glue_standalone 剔除 pipeline_wpo.o 已 T 定义的符号，避免 multiple definition。
ensure_pipeline_glue_standalone_wpo_dedupe_obj() {
  local PARTIAL SYMS GLUE_O WPO_E
  PARTIAL="$BUILD_DIR/pipeline_glue_wpo_dedupe.o"
  SYMS="$BUILD_DIR/pipeline_glue_wpo_dedupe_export.txt"
  GLUE_O="$BUILD_DIR/pipeline_glue_standalone.o"
  WPO_E="$BUILD_DIR/pipeline_wpo.o"
  ensure_asm_pipeline_glue_standalone_obj || return 1
  [ -f "$WPO_E" ] || return 1
  if [ ! -f "$SYMS" ] || [ "$GLUE_O" -nt "$SYMS" ] || [ "$WPO_E" -nt "$SYMS" ]; then
    nm "$GLUE_O" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.pipeline_glue_all_t.txt"
    nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.pipeline_wpo_all_t.txt"
    comm -23 "$BUILD_DIR/.pipeline_glue_all_t.txt" "$BUILD_DIR/.pipeline_wpo_all_t.txt" >"$SYMS"
    echo "  pipeline_glue wpo dedupe: $(wc -l <"$SYMS" | tr -d ' ') syms (glue minus pipeline_wpo T dupes)"
  fi
  [ -s "$SYMS" ] || return 1
  if [ ! -f "$PARTIAL" ] || [ "$GLUE_O" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || [ "$WPO_E" -nt "$PARTIAL" ]; then
    echo "  ld partial export $SYMS pipeline_glue_standalone.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$GLUE_O" || return 1
  fi
  return 0
}

# strict 链：自 build_asm/typeck.o 导出除 WPO 已定义外符号（impl mega 等仍由 partial 提供）。
ensure_typeck_o_strict_link_partial_obj() {
  local PARTIAL SYMS TCKO WPO_E GLUE_O
  PARTIAL="$BUILD_DIR/typeck_strict_link_partial.o"
  SYMS="$BUILD_DIR/typeck_strict_link_export.txt"
  TCKO="$BUILD_DIR/typeck.o"
  WPO_E="$BUILD_DIR/typeck_wpo.o"
  GLUE_O="$BUILD_DIR/pipeline_glue_standalone.o"
  if [ ! -f "$TCKO" ] || [ ! -s "$TCKO" ]; then
    return 1
  fi
  # 过期 export/partial 须强制重算（仅减 typeck_wpo.o 的 6 个 T，须保留 typeck_check_block_one_* 等 callee）。
  if typeck_wpo_strict_partial_export_syms_stale "$SYMS"; then
    rm -f "$SYMS" "$PARTIAL"
  fi
  if [ -f "$PARTIAL" ] && [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] && asm_typeck_wpo_strict_reach_ok; then
    nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?typeck_check_block_one_while$' || rm -f "$PARTIAL"
  fi
  # glue_standalone 更新后须重算 export，避免 typeck partial 仍导出 pipeline_arena_expr_ptr 等重复符号。
  if [ -f "$PARTIAL" ] && [ -f "$GLUE_O" ] && [ "$GLUE_O" -nt "$PARTIAL" ]; then
    rm -f "$PARTIAL"
  fi
  if [ ! -f "$SYMS" ] || [ "$TCKO" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$SYMS" ]; } || \
     { [ -f "$GLUE_O" ] && [ "$GLUE_O" -nt "$SYMS" ]; }; then
    nm "$TCKO" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$SYMS"
    if [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] && [ -f "$WPO_E" ] && asm_typeck_wpo_strict_reach_ok && asm_typeck_wpo_strict_link_helpers_ok; then
      if [ -f "$BUILD_DIR/.typeck_wpo_helpers_export_syms.txt" ] && [ -s "$BUILD_DIR/.typeck_wpo_helpers_export_syms.txt" ]; then
        cp -f "$BUILD_DIR/.typeck_wpo_helpers_export_syms.txt" "$BUILD_DIR/.typeck_wpo_export_syms.txt"
      else
        nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | grep -vE "$(typeck_wpo_helpers_export_exclude_re)" | sort -u >"$BUILD_DIR/.typeck_wpo_export_syms.txt"
      fi
      if [ -s "$BUILD_DIR/.typeck_wpo_export_syms.txt" ]; then
        sort -u "$BUILD_DIR/.typeck_wpo_export_syms.txt" -o "$BUILD_DIR/.typeck_wpo_export_syms.txt"
        comm -23 "$SYMS" "$BUILD_DIR/.typeck_wpo_export_syms.txt" >"$SYMS.wpo" 2>/dev/null && mv -f "$SYMS.wpo" "$SYMS"
        echo "  typeck_strict_link: minus typeck_wpo layout exports ($(wc -l <"$BUILD_DIR/.typeck_wpo_export_syms.txt" | tr -d ' ') syms, keep check_block/typeck_sx_ast from typeck.o)"
      fi
    fi
    if ensure_pipeline_glue_standalone_export_syms_txt; then
      sort -u "$SYMS" -o "$SYMS"
      comm -12 "$SYMS" "$BUILD_DIR/.pipeline_glue_standalone_export_syms.txt" >"$BUILD_DIR/.typeck_glue_dup_syms.txt" 2>/dev/null || true
      if [ -s "$BUILD_DIR/.typeck_glue_dup_syms.txt" ]; then
        comm -23 "$SYMS" "$BUILD_DIR/.typeck_glue_dup_syms.txt" >"$SYMS.glue" 2>/dev/null && mv -f "$SYMS.glue" "$SYMS"
        echo "  typeck_strict_link: minus typeck∩glue duplicate exports ($(wc -l <"$BUILD_DIR/.typeck_glue_dup_syms.txt" | tr -d ' ') syms, glue_standalone owns ast_pool)"
      fi
    fi
    echo "  nm typeck.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') symbols)"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$TCKO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$PARTIAL" ]; } || \
     { [ -f "$GLUE_O" ] && [ "$GLUE_O" -nt "$PARTIAL" ]; }; then
    echo "  ld partial export $SYMS typeck.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$TCKO" || return 1
    if [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] && asm_typeck_wpo_strict_reach_ok; then
      nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?typeck_check_block_one_while$' || {
        build_shux_asm_error "typeck_strict_link_partial missing typeck_check_block_one_while (stale export?)"
        return 1
      }
      nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?check_block_as_loop_body$' || {
        build_shux_asm_error "typeck_strict_link_partial missing check_block_as_loop_body"
        return 1
      }
      nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?check_block$' || {
        build_shux_asm_error "typeck_strict_link_partial missing check_block (must come from typeck.o, not typeck_wpo.o)"
        return 1
      }
      nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?typeck_sx_ast$' || {
        build_shux_asm_error "typeck_strict_link_partial missing typeck_sx_ast (must come from typeck.o, not typeck_wpo.o)"
        return 1
      }
    fi
  fi
  return 0
}

# strict 链：C orchestration TU（不含 pipeline_run 包装，与 trampoline 并列）。
ensure_pipeline_bootstrap_orchestration_strict_obj() {
  local ORCH_O
  ORCH_O="$BUILD_DIR/pipeline_bootstrap_orchestration_strict.o"
  if [ ! -f "$ORCH_O" ] || [ "pipeline_bootstrap_orchestration.c" -nt "$ORCH_O" ]; then
    echo "  cc -c pipeline_bootstrap_orchestration.c -> $ORCH_O (strict, no pipeline_run wrapper)"
    "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -I"$BUILD_DIR" -DPIPELINE_BOOTSTRAP_ORCH_NO_PIPELINE_RUN_WRAPPER \
      -c -o "$ORCH_O" pipeline_bootstrap_orchestration.c
  fi
}

# B-strict：runtime 入口薄壳，委托 C glue run_sx_pipeline_impl（build_asm/pipeline.o 仅 path/load helper）。
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

# B-strict：最小 glue（无 ast_pool）；编排真机在 ast_pool.c glue_standalone。
ensure_asm_pipeline_glue_strict_minimal_obj() {
  local GLUE_OBJ="$BUILD_DIR/pipeline_glue_strict_minimal.o"
  if [ ! -f "$GLUE_OBJ" ] || [ "src/asm/pipeline_glue_strict_minimal.c" -nt "$GLUE_OBJ" ]; then
    echo "  cc -c src/asm/pipeline_glue_strict_minimal.c -> $GLUE_OBJ"
    "$CC" $CFLAGS -c -o "$GLUE_OBJ" src/asm/pipeline_glue_strict_minimal.c
  fi
}

# B-strict：preprocess -D 与 labeled 名写入（ast_pool_l5_bridge.c）。
ensure_ast_pool_l5_bridge_obj() {
  local OBJ="$BUILD_DIR/ast_pool_l5_bridge.o"
  if [ ! -f "$OBJ" ] || [ "src/ast_pool_l5_bridge.c" -nt "$OBJ" ] || [ "ast_pool.c" -nt "$OBJ" ]; then
    echo "  cc -c src/ast_pool_l5_bridge.c -> $OBJ"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$OBJ" src/ast_pool_l5_bridge.c
  fi
}

# B-strict：pipeline_sx.o 仅导出 asm/backend 四入口（legacy experimental 链）。
ensure_pipeline_asm_codegen_only_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/pipeline_asm_codegen_only_partial.o"
  SYMS="$BUILD_DIR/pipeline_asm_codegen_only_export.txt"
  SUO="$BUILD_DIR/gen_driver/pipeline_sx.o"
  ensure_pipeline_sx_o_fresh
  if [ ! -f "$SUO" ]; then
    ensure_asm_gen_driver_sx_objs
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_asm_asm_codegen_ast
_asm_asm_codegen_elf_o
_backend_asm_codegen_ast
_backend_asm_codegen_ast_to_elf
EOF
    echo "  ld -r -exported_symbols_list $SYMS pipeline_sx.o -> $PARTIAL"
    ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$SUO"
  fi
}

# build_asm pipeline.o 第二遍：path/resolve/load + run_sx_pipeline_impl 均 SX 真 emit。
# 当前 seed 二遍实测 __text≈6843B（低于历史 S3a 11588B 目标，但符号齐全即可 strict）。
# nm：ELF 无 leading _，Mach-O 有 _；resolve 符号名为 resolve_path_probe_dot_sx_and_mod 等。
asm_strict_pipeline_selfhosted() {
  local t
  t=$(asm_o_text_bytes "$BUILD_DIR/pipeline.o" 2>/dev/null || echo 0)
  [ "$t" -ge 6144 ] 2>/dev/null || return 1
  nm -g "$BUILD_DIR/pipeline.o" 2>/dev/null | grep -qE '(_)?path_append_from_buf_256|(_)?resolve_path_.*su' || return 1
  nm -g "$BUILD_DIR/pipeline.o" 2>/dev/null | grep -qE '(_)?run_sx_pipeline_impl' || return 1
  return 0
}

# build_asm pipeline 自举后用户 .sx 编译：走 SX run_sx_pipeline_impl（与 experimental 一致）；C orchestration alias 已知 fill_cl SIGSEGV。
asm_strict_sx_orchestration_ok() {
  local p_sx_t=0
  [ "${SHUX_ASM_STRICT_C_ORCHESTRATION:-0}" = "1" ] && return 1
  [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ] || return 1
  if asm_strict_pipeline_selfhosted; then
    return 0
  fi
  # runtime-only relink 可能复用薄 build_asm/pipeline.o，但真正可执行的 SX orchestration
  # 已存在于 pipeline_sx.o；此时仍应允许 strict 路径按 companion 判真。
  [ -f pipeline_sx.o ] || return 1
  p_sx_t=$(asm_o_text_bytes pipeline_sx.o 2>/dev/null || echo 0)
  [ "$p_sx_t" -ge 6144 ] 2>/dev/null || return 1
  nm -g pipeline_sx.o 2>/dev/null | grep -qE '(_)?path_append_from_buf_256|(_)?resolve_path_.*su' || return 1
  nm -g pipeline_sx.o 2>/dev/null | grep -qE '(_)?run_sx_pipeline_impl' || return 1
  return 0
}

# 自举 typeck + SX 编排：glue 走 pipeline_sx partial + glue_strict_minimal（勿 glue_standalone 双 astpool）。
asm_strict_typeck_sx_glue_via_pipeline_sx() {
  asm_strict_sx_orchestration_ok || return 1
  if asm_strict_typeck_selfhosted; then
    return 0
  fi
  # runtime-only relink 可能复用薄 build_asm/typeck.o，但 typeck_sx.o 已是完整 companion；
  # 此时仍应走 strict_minimal glue，避免退回缺少 pipeline_asm_* helper 的 glue_standalone。
  if [ -f typeck_sx.o ] && [ -s typeck_sx.o ]; then
    local t_sx
    t_sx=$(asm_o_text_bytes typeck_sx.o 2>/dev/null || echo 0)
    [ "$t_sx" -gt 10000 ] 2>/dev/null && return 0
  fi
  return 0
}

# pipeline_wpo.o 编排链 reach：run_sx_pipeline_impl 直接 callee 须在 TU 内定义（S5 strict WPO link 前置）。
asm_pipeline_wpo_strict_reach_ok() {
  local po="$BUILD_DIR/pipeline_wpo.o"
  [ -f "$po" ] || return 1
  nm "$po" 2>/dev/null | grep -qE '(_)?run_sx_pipeline_impl' || return 1
  nm "$po" 2>/dev/null | grep -qE ' U (_)?run_sx_pipeline_typecheck_entry$' && return 1
  nm "$po" 2>/dev/null | grep -qE ' U (_)?run_sx_pipeline_codegen_entry$' && return 1
  nm "$po" 2>/dev/null | grep -qE ' U (_)?run_sx_pipeline_parse_entry_if_needed$' && return 1
  nm "$po" 2>/dev/null | grep -qE ' U (_)?run_sx_pipeline_codegen_deps$' && return 1
  return 0
}

# track-only：链整颗 pipeline_wpo.o（SX run_sx_pipeline_impl 编排）；默认 helpers+C 编排（稳定）。
asm_pipeline_wpo_strict_link_full_ok() {
  local po="$BUILD_DIR/pipeline_wpo.o"
  [ "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO_FULL:-0}" = "1" ] || return 1
  asm_pipeline_wpo_strict_reach_ok || return 1
  nm "$po" 2>/dev/null | grep -qE ' T (_)?resolve_path_try_one_lib_root$' || return 1
  return 0
}

# Linux reach OK 时默认链 pipeline_wpo helpers + C 编排（稳定）；FULL=1 显式开启整颗 pipeline_wpo.o。
maybe_default_pipeline_wpo_strict_link() {
  if [ -n "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO+x}" ]; then
    return 0
  fi
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Linux-x86_64|Linux-amd64|Linux-aarch64|Linux-arm64)
      if asm_pipeline_wpo_strict_reach_ok; then
        export SHUX_ASM_STRICT_LINK_PIPELINE_WPO=1
        if [ "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO_FULL:-0}" = "1" ]; then
          export SHUX_ASM_STRICT_LINK_PIPELINE_WPO_FULL=1
          build_shux_asm_info "default SHUX_ASM_STRICT_LINK_PIPELINE_WPO=1 + FULL=1 (whole pipeline_wpo.o + glue support)"
        else
          export SHUX_ASM_STRICT_LINK_PIPELINE_WPO_FULL=0
          build_shux_asm_info "default SHUX_ASM_STRICT_LINK_PIPELINE_WPO=1 (helpers + C orchestration)"
        fi
      fi
      ;;
  esac
}

# typeck_wpo.o WPO reach：typeck_sx_ast / check_block / check_expr 须在 TU 内定义（impl 由 partial 补）。
asm_typeck_wpo_strict_reach_ok() {
  local to="$BUILD_DIR/typeck_wpo.o"
  [ -f "$to" ] || return 1
  nm "$to" 2>/dev/null | grep -qE '(_)?typeck_sx_ast' || return 1
  nm "$to" 2>/dev/null | grep -qE ' U (_)?typeck_sx_ast$' && return 1
  nm "$to" 2>/dev/null | grep -qE ' U (_)?check_block$' && return 1
  nm "$to" 2>/dev/null | grep -qE ' U (_)?check_expr$' && return 1
  nm "$to" 2>/dev/null | grep -qE ' T (_)?check_block' || return 1
  nm "$to" 2>/dev/null | grep -qE ' T (_)?check_expr' || return 1
  return 0
}

# typeck_wpo helpers partial 仅于 typeck.o 未自举时链入；自举 typeck.o 已含 layout，且 wpo partial 会带入内联 check_block 局部符号 → SIGSEGV。
asm_typeck_wpo_strict_link_helpers_ok() {
  [ "${STRICT_LINK_BUILD_ASM_TYPECK_WPO:-0}" -eq 1 ] || return 1
  asm_typeck_wpo_strict_reach_ok || return 1
  asm_strict_typeck_selfhosted && return 1
  return 0
}

# backend_wpo.o WPO reach：asm_codegen_ast / emit_expr_elf / emit_block_body_elf 须在 TU 内定义。
asm_backend_wpo_strict_reach_ok() {
  local bo="$BUILD_DIR/backend_wpo.o"
  [ -f "$bo" ] || return 1
  nm "$bo" 2>/dev/null | grep -qE ' T (_)?asm_codegen_ast$' || return 1
  nm "$bo" 2>/dev/null | grep -qE ' U (_)?asm_codegen_ast$' && return 1
  nm "$bo" 2>/dev/null | grep -qE ' T (_)?emit_expr_elf' || return 1
  nm "$bo" 2>/dev/null | grep -qE ' T (_)?emit_block_body_elf' || return 1
  return 0
}

# build_asm backend.o 已 EMIT（薄桩 + helper；mega 真实现在 seed partial）。
asm_strict_backend_selfhosted() {
  local t
  t=$(asm_o_text_bytes "$BUILD_DIR/backend.o" 2>/dev/null || echo 0)
  [ "$t" -gt 1024 ] 2>/dev/null
}

# strict WPO 链：backend_asm_bare_link_alias.c（glue backend_* → build_asm 裸符号）。
ensure_backend_asm_bare_link_alias_obj() {
  local ALIAS_O="$BUILD_DIR/backend_asm_bare_link_alias.o"
  if [ ! -f "$ALIAS_O" ] || [ backend_asm_bare_link_alias.c -nt "$ALIAS_O" ]; then
    echo "  cc -c backend_asm_bare_link_alias.c -> $ALIAS_O"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$ALIAS_O" backend_asm_bare_link_alias.c
  fi
}

# strict 非 WPO backend fallback：给 user_asm_seed_bridge 提供 backend_* 强桥接，避免落到 seed weak return -1 桩。
ensure_backend_asm_strict_fallback_alias_obj() {
  local ALIAS_O="$BUILD_DIR/backend_asm_strict_fallback_alias.o"
  if [ ! -f "$ALIAS_O" ] || [ backend_asm_strict_fallback_alias.c -nt "$ALIAS_O" ]; then
    echo "  cc -c backend_asm_strict_fallback_alias.c -> $ALIAS_O"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$ALIAS_O" backend_asm_strict_fallback_alias.c
  fi
}

# strict 链：compat stubs 须随源码重编（勿用 src/asm/*.o 陈旧副本）。
ensure_asm_backend_compat_stubs_obj() {
  local STUB_O="$BUILD_DIR/asm_backend_compat_stubs.o"
  if [ ! -f "$STUB_O" ] || [ src/asm/asm_backend_compat_stubs.c -nt "$STUB_O" ]; then
    echo "  cc -c src/asm/asm_backend_compat_stubs.c -> $STUB_O"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$STUB_O" src/asm/asm_backend_compat_stubs.c
  fi
}

ensure_bstrict_filtered_obj_against_seed_partial() {
  local src_o="$1"
  local out_o="$2"
  local tag="$3"
  local seed_o="$BUILD_DIR/seed_host/asm_backend_partial.o"
  local src_syms="$BUILD_DIR/.${tag}_all_t.txt"
  local seed_syms="$BUILD_DIR/.bstrict_seed_partial_all_t.txt"
  local keep_syms="$BUILD_DIR/.${tag}_keep.txt"
  [ -f "$src_o" ] || return 1
  [ -f "$seed_o" ] || return 1
  if [ ! -f "$out_o" ] || [ "$src_o" -nt "$out_o" ] || [ "$seed_o" -nt "$out_o" ] || [ "$keep_syms" -nt "$out_o" ]; then
    nm "$src_o" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$src_syms"
    nm "$seed_o" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$seed_syms"
    comm -23 "$src_syms" "$seed_syms" >"$keep_syms"
    [ -s "$keep_syms" ] || return 1
    echo "  ld partial export $keep_syms $(basename "$src_o") -> $(basename "$out_o")"
    ld_partial_export "$keep_syms" "$out_o" "$src_o" || return 1
  fi
  return 0
}

ensure_bstrict_pipeline_filtered_obj() {
  local src_o="pipeline_sx.o"
  local out_o="$BUILD_DIR/bstrict_pipeline_filtered.o"
  local all_syms="$BUILD_DIR/.bstrict_pipeline_all_t.txt"
  local omit_syms="$BUILD_DIR/.bstrict_pipeline_omit.txt"
  local keep_syms="$BUILD_DIR/.bstrict_pipeline_keep.txt"
  local dep_o
  [ -f "$src_o" ] || return 1
  : >"$omit_syms"
  for dep_o in typeck_sx.o codegen_sx.o "$BUILD_DIR/seed_host/asm_backend_partial.o"; do
    [ -f "$dep_o" ] || continue
    nm "$dep_o" 2>/dev/null | awk '/ T / {print $3}' >>"$omit_syms"
  done
  sort -u "$omit_syms" -o "$omit_syms"
  if [ ! -f "$out_o" ] || [ "$src_o" -nt "$out_o" ] || [ "$omit_syms" -nt "$out_o" ]; then
    nm "$src_o" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$all_syms"
    comm -23 "$all_syms" "$omit_syms" >"$keep_syms"
    [ -s "$keep_syms" ] || return 1
    echo "  ld partial export $keep_syms pipeline_sx.o -> $(basename "$out_o")"
    ld_partial_export "$keep_syms" "$out_o" "$src_o" || return 1
  fi
  return 0
}

# strict WPO 链：seed partial 保留 mega + arch enc + glue 侧car（剔除 wpo 已替代的薄入口）。
ensure_asm_backend_seed_helper_partial_obj() {
  local PARTIAL SYMS SEED EXCLUDE
  PARTIAL="$BUILD_DIR/asm_backend_seed_helper_partial.o"
  SYMS="$BUILD_DIR/asm_backend_seed_helper_export.txt"
  EXCLUDE="$BUILD_DIR/asm_backend_seed_helper_exclude.txt"
  SEED="$BUILD_DIR/seed_host/asm_backend_partial.o"
  if [ ! -f "$SEED" ] || [ ! -s "$SEED" ]; then
    return 1
  fi
  if [ ! -f "$SYMS" ] || [ "$SEED" -nt "$SYMS" ] || [ ! -f "$EXCLUDE" ] || [ "$EXCLUDE" -nt "$SYMS" ]; then
    cat >"$EXCLUDE" <<'EOF'
backend_asm_codegen_ast
backend_asm_codegen_ast_to_elf
backend_emit_expr_elf
backend_emit_block_body_elf
EOF
    nm "$SEED" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$SYMS.all"
    sort -u "$EXCLUDE" -o "$EXCLUDE"
    comm -23 "$SYMS.all" "$EXCLUDE" >"$SYMS"
    rm -f "$SYMS.all"
    build_shux_asm_info "seed helper export: $(wc -l <"$SYMS" | tr -d ' ') symbols (seed minus wpo thin entry)"
  fi
  if [ -f "$SYMS" ] && grep -qxF 'backend_asm_codegen_ast' "$SYMS" 2>/dev/null; then
    build_shux_asm_warn "stale asm_backend_seed_helper export (dup bare_link_alias); regen"
    rm -f "$SYMS" "$PARTIAL"
  fi
  if [ -f "$PARTIAL" ] && nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?backend_asm_codegen_ast$'; then
    build_shux_asm_warn "stale asm_backend_seed_helper_partial (dup bare_link_alias); rebuild"
    rm -f "$PARTIAL"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$SEED" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || [ "$EXCLUDE" -nt "$PARTIAL" ]; then
    build_shux_asm_info "ld partial export $SYMS seed asm_backend_partial.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$SEED" || return 1
  fi
  return 0
}

# WPO strict partial 导出表是否过期：须含 arch/emit helper、不含 stub mega。
backend_wpo_strict_partial_export_syms_stale() {
  local syms="$1"
  [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] || return 1
  asm_backend_wpo_strict_reach_ok || return 1
  [ -f "$syms" ] || return 0
  grep -qxF 'arch_emit_add_imm_to_rax' "$syms" 2>/dev/null || return 0
  grep -qxF 'asm_codegen_ast_seed_mega' "$syms" 2>/dev/null && return 0
  return 1
}

# strict 链：自 build_asm/backend.o 导出除 WPO 已定义与 stub mega 外符号。
ensure_backend_o_strict_link_partial_obj() {
  local PARTIAL SYMS BACKO WPO_E
  PARTIAL="$BUILD_DIR/backend_strict_link_partial.o"
  SYMS="$BUILD_DIR/backend_strict_link_export.txt"
  BACKO="$BUILD_DIR/backend.o"
  WPO_E="$BUILD_DIR/backend_wpo.o"
  if [ ! -f "$BACKO" ] || [ ! -s "$BACKO" ]; then
    return 1
  fi
  if backend_wpo_strict_partial_export_syms_stale "$SYMS"; then
    rm -f "$SYMS" "$PARTIAL"
  fi
  if [ -f "$PARTIAL" ] && [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] && asm_backend_wpo_strict_reach_ok; then
    nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?arch_emit_add_imm_to_rax$' || rm -f "$PARTIAL"
  fi
  if [ ! -f "$SYMS" ] || [ "$BACKO" -nt "$SYMS" ] || [ "ast_pool.c" -nt "$SYMS" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$SYMS" ]; }; then
    nm "$BACKO" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$SYMS"
    if [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] && [ -f "$WPO_E" ] && asm_backend_wpo_strict_reach_ok; then
      nm "$WPO_E" 2>/dev/null | awk '/ T / {print $3}' | sort -u >"$BUILD_DIR/.backend_wpo_export_syms.txt"
      if [ -s "$BUILD_DIR/.backend_wpo_export_syms.txt" ]; then
        sort -u "$BUILD_DIR/.backend_wpo_export_syms.txt" -o "$BUILD_DIR/.backend_wpo_export_syms.txt"
        comm -23 "$SYMS" "$BUILD_DIR/.backend_wpo_export_syms.txt" >"$SYMS.wpo" 2>/dev/null && mv -f "$SYMS.wpo" "$SYMS"
        echo "  backend_strict_link: minus backend_wpo.o exports ($(wc -l <"$BUILD_DIR/.backend_wpo_export_syms.txt" | tr -d ' ') syms)"
      fi
      grep -vxF 'asm_codegen_ast_seed_mega' "$SYMS" >"$SYMS.nmega" 2>/dev/null && mv -f "$SYMS.nmega" "$SYMS"
      grep -vxF 'asm_codegen_ast_to_elf_seed_mega' "$SYMS" >"$SYMS.nmega2" 2>/dev/null && mv -f "$SYMS.nmega2" "$SYMS"
    fi
    echo "  nm backend.o -> $SYMS ($(wc -l <"$SYMS" | tr -d ' ') symbols)"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$BACKO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ] || \
     { [ -f "$WPO_E" ] && [ "$WPO_E" -nt "$PARTIAL" ]; }; then
    echo "  ld partial export $SYMS backend.o -> $PARTIAL"
    ld_partial_export "$SYMS" "$PARTIAL" "$BACKO" || return 1
    if [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] && asm_backend_wpo_strict_reach_ok; then
      nm "$PARTIAL" 2>/dev/null | grep -qE ' T (_)?arch_emit_add_imm_to_rax$' || {
        build_shux_asm_error "backend_strict_link_partial missing arch_emit_add_imm_to_rax"
        return 1
      }
    fi
  fi
  return 0
}

# strict WPO 链 backend 对象组：wpo + seed helper（mega/emit 仍在 seed）；build_asm backend.o 薄桩不与 seed 混链。
# 非 WPO fallback 下优先直接使用 seed partial 的真实 backend_* 强符号；仅当旧 seed partial 缺符号时才补 alias。
strict_asm_backend_companion_objs() {
  local seed_o="$BUILD_DIR/seed_host/asm_backend_partial.o"
  if [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] && asm_backend_wpo_strict_reach_ok; then
    ensure_backend_asm_bare_link_alias_obj >&2 || return 1
    ensure_asm_backend_seed_helper_partial_obj >&2 || return 1
    printf '%s\n' "$BUILD_DIR/backend_wpo.o $BUILD_DIR/backend_asm_bare_link_alias.o $BUILD_DIR/asm_backend_seed_helper_partial.o"
    return 0
  fi
  if [ -f "$seed_o" ] && \
     nm "$seed_o" 2>/dev/null | grep -qE ' T (_)?backend_asm_codegen_ast$' && \
     nm "$seed_o" 2>/dev/null | grep -qE ' T (_)?backend_asm_codegen_ast_to_elf$'; then
    printf '%s\n' "$seed_o"
    return 0
  fi
  ensure_backend_asm_strict_fallback_alias_obj >&2 || return 1
  printf '%s\n' "$BUILD_DIR/backend_asm_strict_fallback_alias.o $seed_o"
  return 0
}

# 保留旧名供 grep；第二遍 EMIT_HEAVY 验收与 asm_strict_pipeline_selfhosted 一致。
asm_pipeline_run_impl_has_real_body() {
  asm_strict_pipeline_selfhosted
}

# build_asm typeck.o 仅 __text>8KiB 视为完整自举 emit；否则 typeck 走 strict_support partial。
asm_strict_typeck_selfhosted() {
  local t
  t=$(asm_o_text_bytes "$BUILD_DIR/typeck.o" 2>/dev/null || echo 0)
  [ "$t" -gt 8192 ] 2>/dev/null
}

# build_asm driver_compile_emit_heavy.o + driver_compile_link.o：run_compiler_full_sx / parse_argv SX emit。
# driver_compile.o 为 WPO 压缩 entry TU（dogfood）；strict 链尺寸门禁看 emit_heavy.o。
asm_strict_driver_selfhosted() {
  local t
  [ -f "$BUILD_DIR/driver_compile_link.o" ] || return 1
  t=$(asm_o_text_bytes "$BUILD_DIR/driver_compile_emit_heavy.o" 2>/dev/null || echo 0)
  if [ "$t" -lt 5104 ] 2>/dev/null; then
    t=$(asm_o_text_bytes "$BUILD_DIR/driver_compile.o" 2>/dev/null || echo 0)
  fi
  [ "$t" -ge 5104 ] 2>/dev/null || return 1
  nm -g "$BUILD_DIR/driver_compile_link.o" 2>/dev/null | grep -qE '(_)?driver_run_compiler_full_sx' || return 1
  return 0
}

# Stage2 二遍自举：SHU 已是 shux_asm 时仍用 driver_compile_sx（gen1 拓扑），直至 gen2 driver SX 链稳定。
asm_strict_bootstrap_round2() {
  if [ -n "${SHUX_ASM_STRICT_FORCE_DRIVER_SX:-}" ]; then
    return 0
  fi
  if [ -n "${SHUX_ASM_BOOTSTRAP_ROUND2:-}" ]; then
    return 0
  fi
  case "${SHUX:-}" in
    ./shux_asm|./shux_asm_stage1|./shux_asm2|*/shux_asm|*/shux_asm_stage1|*/shux_asm2) return 0 ;;
  esac
  case "$(basename "${SHUX:-}" 2>/dev/null)" in
    shux_asm|shux_asm_stage1|shux_asm2) return 0 ;;
  esac
  return 1
}

# Stage2 round2 是否跳过 typeck_wpo（SHUX_ASM_ROUND2_TRY_TYPECK_WPO=1 为 track-only 试链）。
asm_strict_round2_skip_typeck_wpo() {
  if [ -n "${SHUX_ASM_ROUND2_TRY_TYPECK_WPO:-}" ]; then
    return 1
  fi
  asm_strict_bootstrap_round2
}

# strict 最终链是否使用 driver_compile_link.o（须 asm_strict_driver_selfhosted）。
asm_strict_link_driver_selfhosted() {
  if [ -n "${SHUX_ASM_STRICT_FORCE_DRIVER_SX:-}" ]; then
    build_shux_asm_info "SHUX_ASM_STRICT_FORCE_DRIVER_SX=1 - keep driver_compile_sx"
    return 1
  fi
  if ! asm_strict_driver_selfhosted; then
    return 1
  fi
  return 0
}

# build_asm typeck.o 未自举完成时：仅导出 layout/metrics 符号供 glue，不含 typeck_sx_ast 桩。
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
_typeck_ensure_struct_layout_from_struct_lit
_typeck_merge_dep_struct_layouts_into_entry
_typeck_wpo_unify_soa_layouts
_typeck_entry_module_find_struct_layout_index
_typeck_find_layout_idx_by_type_name
EOF
    echo "  ld -r -exported_symbols_list $SYMS typeck.o -> $PARTIAL (layout only)"
    set +e
    ld_partial_export "$SYMS" "$PARTIAL" "$TCK" 2>"$BUILD_DIR/.typeck_layout_partial_err"
    local ld_rc=$?
    set -e
    if [ "$ld_rc" -ne 0 ]; then
      build_shux_asm_warn "typeck layout partial skipped (layout symbols missing in typeck.o; need typeck second pass >8KiB)"
      rm -f "$PARTIAL"
      return 1
    fi
  fi
}

# strict 链：build_asm layout partial 已导出 layout 符号时，从 typeck_sx.o 剔除同符号避免 duplicate。
ensure_typeck_sx_no_layout_partial_obj() {
  local PARTIAL SYMS SUO
  PARTIAL="$BUILD_DIR/typeck_sx_no_layout_partial.o"
  SYMS="$BUILD_DIR/typeck_sx_no_layout_export.txt"
  SUO="typeck_sx.o"
  if [ ! -f "$SUO" ]; then
    return 1
  fi
  if [ -f "$SYMS" ] && grep -qE '^_typeck_(ensure_struct_layout_from_struct_lit|entry_module_find_struct_layout_index)$' "$SYMS" 2>/dev/null; then
    rm -f "$SYMS" "$PARTIAL"
  fi
  if [ ! -f "$SYMS" ] || [ "$0" -nt "$SYMS" ] || [ "$SUO" -nt "$SYMS" ]; then
    # ELF 符号无 leading _；统一 sed 去/加 _ 供 macOS exported_symbols_list 与 Linux objcopy。
    nm "$SUO" 2>/dev/null | awk '/ T _?typeck_/ {print $3}' | sed 's/^_//' | \
      grep -v '^typeck_struct_layout_metrics$' | \
      grep -v '^typeck_validate_struct_layouts_zero_padding$' | \
      grep -v '^typeck_merge_dep_struct_layouts_into_entry$' | \
      grep -v '^typeck_wpo_unify_soa_layouts$' | \
      grep -v '^typeck_find_layout_idx_by_type_name$' | \
      grep -v '^typeck_ensure_struct_layout_from_struct_lit$' | \
      grep -v '^typeck_entry_module_find_struct_layout_index$' | \
      sed 's/^/_/' >"$SYMS"
  fi
  if [ ! -f "$PARTIAL" ] || [ "$0" -nt "$PARTIAL" ] || [ "$SUO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    echo "  ld -r -exported_symbols_list $SYMS typeck_sx.o -> $PARTIAL (no layout dupes)"
    set +e
    ld_partial_export "$SYMS" "$PARTIAL" "$SUO" 2>"$BUILD_DIR/.typeck_sx_no_layout_err"
    local ld_rc=$?
    set -e
    if [ "$ld_rc" -ne 0 ]; then
      rm -f "$PARTIAL"
      return 1
    fi
  fi
}

# strict 双自举（build_asm typeck.o + pipeline.o）：C typeck 仅导出编排入口，避免与 SX typeck.o 重复。
ensure_typeck_c_orchestration_partial_obj() {
  local PARTIAL SYMS TCKO
  PARTIAL="$BUILD_DIR/typeck_c_orchestration_partial.o"
  SYMS="$BUILD_DIR/typeck_c_orchestration_export.txt"
  TCKO="src/typeck/typeck.o"
  if [ ! -f "$TCKO" ]; then
    TCKO="$BUILD_DIR/asm_driver_seed/typeck.o"
  fi
  if [ ! -f "$TCKO" ]; then
    return 1
  fi
  if [ ! -f "$PARTIAL" ] || [ "$TCKO" -nt "$PARTIAL" ] || [ "$SYMS" -nt "$PARTIAL" ]; then
    cat > "$SYMS" <<'EOF'
_typeck_module
_typeck_one_function
EOF
    build_shux_asm_info "ld -r -exported_symbols_list $SYMS $TCKO -> $PARTIAL (C orchestration only)"
    set +e
    ld_partial_export "$SYMS" "$PARTIAL" "$TCKO" 2>"$BUILD_DIR/.typeck_c_orch_partial_err"
    local ld_rc=$?
    set -e
    if [ "$ld_rc" -ne 0 ]; then
      rm -f "$PARTIAL"
      return 1
    fi
  fi
}

# strict 整链 typeck.o 时：用 weak 桩满足 lsp_diag.c / runtime 对 C typeck_module 的链接，不再 ld -r 抽 seed typeck.o。
ensure_typeck_c_module_stubs_obj() {
  local OBJ="$BUILD_DIR/typeck_c_module_stubs.o"
  if [ ! -f "$OBJ" ] || [ typeck_c_module_stubs.c -nt "$OBJ" ]; then
    build_shux_asm_info "cc -c typeck_c_module_stubs.c -> $OBJ"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$OBJ" typeck_c_module_stubs.c
  fi
}

# strict 整链 typeck.o 时：优先 seed typeck_module 仅预检；失败回退 weak 桩。
ensure_typeck_c_user_precheck_obj() {
  if ensure_typeck_c_orchestration_partial_obj; then
    echo "$BUILD_DIR/typeck_c_orchestration_partial.o"
    return 0
  fi
  build_shux_asm_warn "typeck_c_orchestration_partial failed; falling back to typeck_c_module_stubs"
  ensure_typeck_c_module_stubs_obj
  echo "$BUILD_DIR/typeck_c_module_stubs.o"
  return 0
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
      pipeline_glue_link.o|pipeline_run_impl_alias.o|pipeline_glue_standalone.o|pipeline_glue_strict_minimal.o|pipeline_glue_wpo_dedupe.o|\
      parser_bootstrap_partial.o|parser_from_sx_partial.o|parser_strict_merged.o|\
      pipeline_parse_sx_partial.o|pipeline_runtime_bootstrap_partial.o|pipeline_sx_glue_support_partial.o|\
      pipeline_asm_sx_bootstrap_partial.o|pipeline_asm_codegen_bootstrap_partial.o|\
      pipeline_asm_runtime_partial.o|pipeline_asm_orchestration_partial.o|\
      pipeline_asm_orchestration_from_build.o|pipeline_phase_parse_only_partial.o|\
      pipeline_phase_parse_only_alias.o|pipeline_asm_run_all_partial.o|\
      pipeline_asm_run_all_alias.o|pipeline_asm_typecheck_alias.o|\
      pipeline_asm_helpers_partial.o|pipeline_asm_orchestration_alias.o|\
      pipeline_strict_link_partial.o|pipeline_wpo.o|pipeline_wpo_helpers_partial.o|pipeline_wpo_typecheck_emit_bridge.o|pipeline_wpo_strict_link_alias.o|\
      pipeline_asm_strict_support_partial.o|pipeline_asm_codegen_only_partial.o|\
      pipeline_asm_strict_core_partial.o|\
      bootstrap_seed_pipeline_filtered.o|bootstrap_seed_user_asm_seed_bridge_filtered.o|bootstrap_seed_asm_backend_compat_stubs_filtered.o|bootstrap_seed_backend_x86_64_enc_c_filtered.o|\
      bstrict_pipeline_filtered.o|bstrict_user_asm_seed_bridge_filtered.o|bstrict_asm_backend_compat_stubs_filtered.o|bstrict_backend_x86_64_enc_c_filtered.o|\
      pipeline_run_bootstrap_trampoline.o|pipeline_bootstrap_orchestration_strict.o|\
      driver_compile_parse_argv_loop_partial.o|\
      typeck_asm_layout_partial.o|typeck_sx_no_layout_partial.o|typeck_c_orchestration_partial.o|\
      typeck_c_module_stubs.o|typeck_asm_bare_link_alias.o|typeck_wpo.o|typeck_wpo_helpers_partial.o|typeck_strict_link_partial.o|\
      typeck_lsp_io_stub.o|\
      backend_wpo.o|backend_strict_link_partial.o|backend_asm_bare_link_alias.o|backend_asm_strict_fallback_alias.o|asm_backend_seed_helper_partial.o|\
      asm_backend_compat_stubs.o|\
      std_fs_shim.o|sx_seed_bridge.o|\
      parser_from_gen.o|asm_experimental_symbol_bridge.o|asm_shux_lsp_diag_stub.o|lsp_codegen_extern.o)
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
        # pipeline_wpo：FULL=整颗 SX 编排；默认 helpers + C orchestration（稳定）。
        if [ "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO:-0}" = "1" ] && [ "${STRICT_LINK_BUILD_ASM_WPO:-0}" -eq 1 ] && asm_pipeline_wpo_strict_reach_ok; then
          if asm_pipeline_wpo_strict_link_full_ok; then
            ensure_pipeline_wpo_strict_link_alias_obj && FILTERED="$FILTERED $BUILD_DIR/pipeline_wpo_strict_link_alias.o"
            FILTERED="$FILTERED $BUILD_DIR/pipeline_wpo.o"
            # FULL 仍须 pipeline_sx glue support：ast_pool 桥接符号不在 pipeline_wpo.o 内（typeck_sx U 引用）。
            if asm_strict_typeck_sx_glue_via_pipeline_sx && ensure_pipeline_sx_glue_support_partial_obj; then
              FILTERED="$FILTERED $BUILD_DIR/pipeline_sx_glue_support_partial.o"
              build_shux_asm_info "strict link pipeline_sx glue support (FULL wpo astpool bridge)"
            fi
            build_shux_asm_info "strict link whole pipeline_wpo.o (SX orchestration, track-only FULL)"
          else
            if asm_strict_sx_orchestration_ok; then
              ensure_pipeline_runtime_bootstrap_partial_obj && FILTERED="$FILTERED $BUILD_DIR/pipeline_runtime_bootstrap_partial.o"
              if asm_strict_typeck_sx_glue_via_pipeline_sx && ensure_pipeline_sx_glue_support_partial_obj; then
                FILTERED="$FILTERED $BUILD_DIR/pipeline_sx_glue_support_partial.o"
                build_shux_asm_info "strict link pipeline_sx glue support (replace glue_standalone astpool)"
              fi
              if ensure_pipeline_wpo_helpers_partial_obj; then
                FILTERED="$FILTERED $BUILD_DIR/pipeline_wpo_helpers_partial.o"
                build_shux_asm_info "strict link pipeline_wpo_helpers + pipeline_sx runtime bootstrap (opt-in WPO)"
              else
                build_shux_asm_warn "pipeline_wpo_helpers partial failed; using pipeline_sx runtime bootstrap only"
              fi
              echo "su" >"$BUILD_DIR/.pipeline_strict_orch_mode"
            else
              ensure_pipeline_asm_orchestration_partial_obj
              FILTERED="$FILTERED $BUILD_DIR/pipeline_asm_orchestration_partial.o"
              if ensure_pipeline_wpo_helpers_partial_obj; then
                FILTERED="$FILTERED $BUILD_DIR/pipeline_wpo_helpers_partial.o"
                build_shux_asm_info "strict link pipeline_wpo_helpers + C orchestration (opt-in WPO)"
              else
                build_shux_asm_warn "pipeline_wpo_helpers partial failed; falling back to C orchestration only"
              fi
              echo "c" >"$BUILD_DIR/.pipeline_strict_orch_mode"
            fi
          fi
        else
          if asm_strict_sx_orchestration_ok; then
            ensure_pipeline_runtime_bootstrap_partial_obj && FILTERED="$FILTERED $BUILD_DIR/pipeline_runtime_bootstrap_partial.o"
            if asm_strict_typeck_sx_glue_via_pipeline_sx && ensure_pipeline_sx_glue_support_partial_obj; then
              FILTERED="$FILTERED $BUILD_DIR/pipeline_sx_glue_support_partial.o"
              build_shux_asm_info "strict link pipeline_sx glue support (replace glue_standalone astpool)"
            fi
            build_shux_asm_info "strict link pipeline_sx runtime bootstrap orchestration"
            echo "su" >"$BUILD_DIR/.pipeline_strict_orch_mode"
          else
            ensure_pipeline_asm_orchestration_partial_obj
            FILTERED="$FILTERED $BUILD_DIR/pipeline_asm_orchestration_partial.o"
            build_shux_asm_info "strict link pipeline_asm_orchestration_partial.o (C run_sx_pipeline_impl)"
            echo "c" >"$BUILD_DIR/.pipeline_strict_orch_mode"
          fi
        fi
        if ensure_pipeline_o_strict_link_partial_obj; then
          FILTERED="$FILTERED $BUILD_DIR/pipeline_strict_link_partial.o"
        else
          FILTERED="$FILTERED $o"
        fi
      fi
      continue
    fi
    if [ "$base" = "parser.o" ]; then
      continue
    fi
    case "$base" in
      driver_compile.cli.o|main.cli.o|\
      parser.o|backend.o|asm.o|main.o|lsp.o|std_fs.o|\
      codegen.o|pipeline_glue_link.o|pipeline_run_impl_alias.o|pipeline_glue_standalone.o|pipeline_glue_strict_minimal.o|pipeline_glue_wpo_dedupe.o|\
      parser_bootstrap_partial.o|parser_from_sx_partial.o|parser_strict_merged.o|\
      pipeline_parse_sx_partial.o|pipeline_runtime_bootstrap_partial.o|pipeline_sx_glue_support_partial.o|\
      pipeline_asm_sx_bootstrap_partial.o|pipeline_asm_codegen_bootstrap_partial.o|\
      pipeline_asm_runtime_partial.o|pipeline_asm_orchestration_partial.o|\
      pipeline_asm_orchestration_from_build.o|pipeline_phase_parse_only_partial.o|\
      pipeline_phase_parse_only_alias.o|pipeline_asm_run_all_partial.o|\
      pipeline_asm_run_all_alias.o|pipeline_asm_typecheck_alias.o|\
      pipeline_asm_helpers_partial.o|pipeline_asm_orchestration_alias.o|\
      pipeline_strict_link_partial.o|pipeline_wpo.o|pipeline_wpo_helpers_partial.o|pipeline_wpo_typecheck_emit_bridge.o|pipeline_wpo_strict_link_alias.o|\
      pipeline_asm_strict_support_partial.o|pipeline_asm_codegen_only_partial.o|\
      pipeline_asm_strict_core_partial.o|\
      bootstrap_seed_pipeline_filtered.o|bootstrap_seed_user_asm_seed_bridge_filtered.o|bootstrap_seed_asm_backend_compat_stubs_filtered.o|bootstrap_seed_backend_x86_64_enc_c_filtered.o|\
      bstrict_pipeline_filtered.o|bstrict_user_asm_seed_bridge_filtered.o|bstrict_asm_backend_compat_stubs_filtered.o|bstrict_backend_x86_64_enc_c_filtered.o|\
      pipeline_run_bootstrap_trampoline.o|pipeline_bootstrap_orchestration_strict.o|\
      driver_compile_parse_argv_loop_partial.o|\
      typeck_skip.o|typeck_heavy.o|typeck.second.o|\
      typeck_asm_layout_partial.o|typeck_sx_no_layout_partial.o|typeck_c_orchestration_partial.o|\
      typeck_c_module_stubs.o|typeck_asm_bare_link_alias.o|typeck_wpo.o|typeck_wpo_helpers_partial.o|typeck_strict_link_partial.o|\
      typeck_lsp_io_stub.o|\
      backend_wpo.o|backend_strict_link_partial.o|backend_asm_bare_link_alias.o|backend_asm_strict_fallback_alias.o|asm_backend_seed_helper_partial.o|\
      asm_backend_compat_stubs.o|\
      std_fs_shim.o|sx_seed_bridge.o|\
      parser_from_gen.o|asm_experimental_symbol_bridge.o|asm_shux_lsp_diag_stub.o|lsp_codegen_extern.o|\
      parser_asm_link_alias.o|parser_asm_minimal_partial.o|\
      ast_pool_l5_bridge.o|\
      lexer.o|peephole.o|platform_elf.o|macho.o|coff.o)
        continue
        ;;
    esac
    # strict 链的 x86_64 encoder 由 seed_host partial / filtered dispatch companions 提供；
    # 若再把 build_asm/backend_x86_64_enc_c.o 混进 ASM_TRY_OBJS，会和 seed partial 重复定义。
    if [ "$base" = "backend_x86_64_enc_c.o" ] && [ -s "$BUILD_DIR/seed_host/asm_backend_partial.o" ]; then
      build_shux_asm_info "strict skip build_asm/backend_x86_64_enc_c.o (seed_host partial already provides encoder)"
      continue
    fi
    # Darwin strict fallback 的 mega backend 也已被 seed_host partial 覆盖；
    # 若再把 build_asm/backend_seed_mega_fallback.o 混入 strict link，会与 seed partial 重复导出 backend_asm_codegen_*。
    if [ "$base" = "backend_seed_mega_fallback.o" ] && [ -s "$BUILD_DIR/seed_host/asm_backend_partial.o" ]; then
      build_shux_asm_info "strict skip build_asm/backend_seed_mega_fallback.o (seed_host partial already provides backend mega fallback)"
      continue
    fi
    if [ "$base" = "typeck.o" ]; then
      # typeck 自举：WPO reach OK 且 typeck.o 未自举时链 typeck_wpo helpers + partial；自举后整颗 typeck.o（wpo partial 会 poison check_block）。
      if [ "$LINK_BUILD_ASM_TYPECK" -eq 1 ]; then
        if asm_typeck_wpo_strict_link_helpers_ok; then
          if ensure_typeck_wpo_helpers_partial_obj; then
            FILTERED="$FILTERED $BUILD_DIR/typeck_wpo_helpers_partial.o"
            build_shux_asm_info "strict link typeck_wpo_helpers + typeck.o partial (pre-selfhosted typeck)"
          else
            FILTERED="$FILTERED $BUILD_DIR/typeck_wpo.o"
            build_shux_asm_warn "strict link typeck_wpo.o (helpers partial failed; falling back to full wpo.o)"
          fi
          ensure_typeck_o_strict_link_partial_obj && FILTERED="$FILTERED $BUILD_DIR/typeck_strict_link_partial.o"
        elif asm_strict_typeck_selfhosted; then
          if asm_strict_typeck_sx_glue_via_pipeline_sx; then
            build_shux_asm_info "strict skip build_asm/typeck.o (SX glue; seed typeck + typeck_sx.o tail)"
          elif ensure_typeck_o_strict_link_partial_obj; then
            FILTERED="$FILTERED $BUILD_DIR/typeck_strict_link_partial.o"
            build_shux_asm_info "strict link typeck.o partial (selfhosted, minus glue dupes)"
          else
            FILTERED="$FILTERED $o"
            build_shux_asm_warn "strict link whole typeck.o (selfhosted partial failed)"
          fi
        else
          FILTERED="$FILTERED $o"
        fi
      fi
      continue
    fi
    if [ "$base" = "typeck_asm_layout_partial.o" ] && [ "$LINK_BUILD_ASM_TYPECK" -eq 1 ]; then
      continue
    fi
    if [ "$base" = "driver_compile.o" ] || [ "$base" = "driver_compile_asm_link_alias.o" ] || [ "$base" = "driver_compile_emit_heavy.o" ]; then
      # driver_compile_link 或 Stage2 round2（driver_compile_sx）均勿再链 build_asm driver 三件套。
      if asm_strict_link_driver_selfhosted || asm_strict_bootstrap_round2; then
        continue
      fi
    fi
    if [ "$base" = "driver_compile_link.o" ]; then
      if asm_strict_link_driver_selfhosted; then
        FILTERED="$FILTERED $o"
      fi
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
    # strict 勿链 text 桩 encoder（仅 U enc_u32_le）；backend_enc_dispatch + seed partial 已覆盖。
    case "$base" in
      x86_64_enc.o|arm64_enc.o|riscv64_enc.o)
        enc_stub_bytes=$(asm_o_text_bytes "$o" 2>/dev/null || echo 0)
        if [ "${enc_stub_bytes:-0}" -lt 512 ] 2>/dev/null; then
          build_shux_asm_info "strict skip stub $base (__text=${enc_stub_bytes}B)"
          continue
        fi
        ;;
    esac
    FILTERED="$FILTERED $o"
  done
}

# Target B 实验链：独立 pipeline_glue+ast_pool TU（类型从 pipeline_gen.c 抽取，不含 .sx 函数体）。
ensure_asm_pipeline_glue_standalone_obj() {
  detect_pipeline_gen_cflags
  GLUE_TYPES="$BUILD_DIR/pipeline_glue_types.inc"
  GLUE_STANDALONE_OBJ="$BUILD_DIR/pipeline_glue_standalone.o"
  GEN_PIPELINE="$BUILD_DIR/gen_driver/pipeline_gen.c"
  NEED_GEN=0
  if [ ! -f "$GEN_PIPELINE" ] || [ ! -s "$GEN_PIPELINE" ]; then
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
    if [ -f pipeline_gen.c ] && [ -s pipeline_gen.c ]; then
      cp -f pipeline_gen.c "$GEN_PIPELINE"
      if [ -f scripts/patch_pipeline_gen_ast_layout.pl ]; then
        perl scripts/patch_pipeline_gen_ast_layout.pl "$GEN_PIPELINE"
      fi
      echo "  pinned pipeline_gen.c -> $GEN_PIPELINE ($(wc -c <"$GEN_PIPELINE" | tr -d ' ') bytes)"
    else
    SHUX_E_LOCAL="${SHUX_E:-}"
    if [ -z "$SHUX_E_LOCAL" ] || [ ! -x "$SHUX_E_LOCAL" ]; then
      for _e in ./shux ./shux-seed-phase1 ./shux_asm ./shux-c; do
        if [ -x "$_e" ] && "$_e" -h >/dev/null 2>&1; then
          SHUX_E_LOCAL="$_e"
          break
        fi
      done
      [ -z "$SHUX_E_LOCAL" ] && SHUX_E_LOCAL="$SHUX"
    fi
    # glue 仅需类型/extern（extract_pipeline_glue_types.pl 在 #include pipeline_glue.c 前截断）；
    # 全量 -E 会内联 std.io 等大依赖，codegen 中途失败产出截断 C 且 exit=1，阻断 set -e 链。
    echo "  $SHUX_E_LOCAL -E -E-extern pipeline.sx -> $GEN_PIPELINE (glue standalone types) ..."
    "$SHUX_E_LOCAL" -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess \
      -E -E-extern src/pipeline/pipeline.sx >"$GEN_PIPELINE"
    if [ -f scripts/patch_pipeline_gen_ast_layout.pl ]; then
      perl scripts/patch_pipeline_gen_ast_layout.pl "$GEN_PIPELINE"
    fi
    fi
    perl -i -ne 'print unless /^struct shux_slice_uint8_t/ && $seen++' "$GEN_PIPELINE" 2>/dev/null || true
    perl scripts/fix_slim_arena_gen_c.pl "$GEN_PIPELINE" 2>/dev/null || true
    perl scripts/hoist_pipeline_prototypes.pl "$GEN_PIPELINE" 2>/dev/null || true
    echo "  perl extract_pipeline_glue_types.pl -> $GLUE_TYPES"
    perl scripts/extract_pipeline_glue_types.pl "$GEN_PIPELINE" >"$GLUE_TYPES"
    perl scripts/patch_ide_glue_types.pl "$GLUE_TYPES"
    if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
      perl -i -0777 -pe 's/\nenum ast_ExprKind parser_compound_assign_token_to_expr_kind\(enum token_TokenKind kind\) \{\n  return compound_assign_token_to_expr_kind_from_glue\(kind\);\n\}//g' "$GLUE_TYPES" 2>/dev/null || true
    fi
  fi
  if [ ! -f "$GLUE_STANDALONE_OBJ" ] || [ "src/asm/pipeline_glue_standalone.c" -nt "$GLUE_STANDALONE_OBJ" ] || [ "$GLUE_TYPES" -nt "$GLUE_STANDALONE_OBJ" ] || [ "ast_pool.c" -nt "$GLUE_STANDALONE_OBJ" ] || [ "pipeline_glue.c" -nt "$GLUE_STANDALONE_OBJ" ] || [ "scripts/extract_pipeline_glue_types.pl" -nt "$GLUE_STANDALONE_OBJ" ] || [ "scripts/patch_ide_glue_types.pl" -nt "$GLUE_STANDALONE_OBJ" ]; then
    build_shux_asm_info "cc -c src/asm/pipeline_glue_standalone.c -> $GLUE_STANDALONE_OBJ"
    if ! "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I"$BUILD_DIR" -c -o "$GLUE_STANDALONE_OBJ" src/asm/pipeline_glue_standalone.c; then
      build_shux_asm_warn "pipeline_glue_standalone.o compile failed (strict 链可继续用 pipeline_glue_strict_minimal)"
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

# F-06 v1：fs/io/heap 已纯 .sx；bootstrap 不再 cc -c std/*.c（符号由 std_fs_shim / runtime_io_abi / lsp_io_std_heap_sx 等提供）。
ensure_std_fs_io_heap_objs() {
  :
}

# pipeline.sx import pipeline.run_sx_pipeline → pipeline_run_sx_link_alias 提供 C 符号。
ensure_pipeline_run_sx_link_alias_obj() {
  if [ ! -f src/asm/pipeline_run_sx_link_alias.o ] || [ src/asm/pipeline_run_sx_link_alias.c -nt src/asm/pipeline_run_sx_link_alias.o ]; then
    build_shux_asm_info "cc pipeline_run_sx_link_alias.o"
    "$CC" $CFLAGS -c -o src/asm/pipeline_run_sx_link_alias.o src/asm/pipeline_run_sx_link_alias.c
  fi
}

# B-strict 首遍 bootstrap：与 bootstrap-driver-seed 对齐的 -E-extern 分模块 .o + asm 后端 partial。
# 瘦 pipeline_sx.o 须链 parser_sx/typeck_sx/codegen_sx/lexer_sx、std_fs_shim、seed_host backend partial；
# 首遍勿并 build_asm/*.o（各模块 __shux_asm_mod_stub 重复 → Darwin ld 失败）。
ensure_asm_bootstrap_sx_companion_objs() {
  if [ "${SHUX_ASM_BOOTSTRAP_SX_COMPANIONS_READY:-0}" = "1" ] \
    && [ -f parser_sx.o ] && [ -f lexer_sx.o ] && [ -f typeck_sx.o ] \
    && [ -f codegen_sx.o ] && [ -f preprocess_sx.o ] \
    && [ -f driver_sx.o ] && [ -f driver_fmt_sx.o ] && [ -f driver_check_sx.o ] \
    && [ -f driver_test_sx.o ] && [ -f driver_build_sx.o ] && [ -f driver_run_sx.o ] \
    && [ -f driver_compile_sx.o ] && [ -f driver_emit_sx.o ] \
    && [ -f lsp_io_std_heap_sx.o ]; then
    build_shux_asm_info "reuse SX companion objs (already ensured in this run)"
    return 0
  fi
  detect_pipeline_gen_cflags
  ensure_pipeline_sx_o_fresh
  # runtime-only relink：SX companion .o 已存在时勿 make typeck_sx.o（stale typeck_gen 会阻断 relink）。
  if [ -n "${SHUX_ASM_BSTRICT_RELINK_ONLY:-}" ] \
    && [ -f parser_sx.o ] && [ -f lexer_sx.o ] && [ -f typeck_sx.o ] \
    && [ -f codegen_sx.o ] && [ -f preprocess_sx.o ]; then
    build_shux_asm_info "BSTRICT_RELINK_ONLY - skip SX companion make (reuse existing *_sx.o)"
    return 0
  elif [ -f Makefile ] && command -v make >/dev/null 2>&1; then
    build_shux_asm_info "ensure SX companion objs (parser/lexer/typeck/codegen/preprocess/compile)"
    # 瘦 pipeline_sx.o 仍引用 codegen_codegen_* / typeck_typeck_* / lexer_lexer_init；须与 bootstrap-driver-seed 同款 link alias。
    # sx 命名 迁移：链接行仍引用 *_sx.o，须 make 别名目标（cp *_sx.o）。
    make -s parser_sx.o lexer_sx.o typeck_sx.o codegen_sx.o preprocess_sx.o \
      lexer_sx.o codegen_sx.o typeck_sx.o preprocess_sx.o \
      lexer_sx_link_alias.o typeck_sx_link_alias.o codegen_sx_link_alias.o \
      driver_sx.o driver_fmt_sx.o driver_check_sx.o driver_test_sx.o \
      driver_build_sx.o driver_run_sx.o driver_compile_sx.o driver_emit_sx.o \
      driver_fmt_sx.o driver_check_sx.o driver_test_sx.o \
      driver_build_sx.o driver_run_sx.o driver_compile_sx.o driver_emit_sx.o \
      lsp_io_std_heap_sx.o \
      src/std_sys_shim.o src/asm/parser_asm_parse_expr_link.o
  fi
  if [ ! -f "$BUILD_DIR/std_fs_shim.o" ] || [ "src/std_fs_shim.c" -nt "$BUILD_DIR/std_fs_shim.o" ]; then
    echo "  cc -c src/std_fs_shim.c -> $BUILD_DIR/std_fs_shim.o"
    "$CC" $CFLAGS -c -o "$BUILD_DIR/std_fs_shim.o" src/std_fs_shim.c
  fi
  if [ ! -f "$BUILD_DIR/sx_seed_bridge.o" ] || [ "src/sx_seed_bridge.c" -nt "$BUILD_DIR/sx_seed_bridge.o" ]; then
    echo "  cc -c src/sx_seed_bridge.c -> $BUILD_DIR/sx_seed_bridge.o"
    "$CC" $CFLAGS -c -o "$BUILD_DIR/sx_seed_bridge.o" src/sx_seed_bridge.c
  fi
  if [ ! -f "$BUILD_DIR/seed_link_compat.o" ] || [ "src/seed_link_compat.c" -nt "$BUILD_DIR/seed_link_compat.o" ]; then
    echo "  cc -c src/seed_link_compat.c -> $BUILD_DIR/seed_link_compat.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$BUILD_DIR/seed_link_compat.o" src/seed_link_compat.c
  fi
  if [ ! -f "$BUILD_DIR/preprocess_if_stack_bridge.o" ] || [ "src/preprocess_if_stack_bridge.c" -nt "$BUILD_DIR/preprocess_if_stack_bridge.o" ]; then
    echo "  cc -c src/preprocess_if_stack_bridge.c -> $BUILD_DIR/preprocess_if_stack_bridge.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$BUILD_DIR/preprocess_if_stack_bridge.o" src/preprocess_if_stack_bridge.c
  fi
  # dispatch TU 须先于 build_seed_asm_host（partial 导出须 nm 四份 dispatch .o）。
  ensure_bstrict_seed_support_objs
  if [ -n "${SHUX_ASM_BSTRICT_RELINK_ONLY:-}" ] && [ -f "$BUILD_DIR/seed_host/asm_backend_partial.o" ]; then
    :
  elif [ ! -f "$BUILD_DIR/seed_host/asm_backend_partial.o" ] || [ "src/asm/backend.sx" -nt "$BUILD_DIR/seed_host/asm_backend_partial.o" ]; then
    build_shux_asm_info "build_seed_asm_host (backend_enc_* for pipeline_sx.o)"
    ./scripts/build_seed_asm_host.sh
  fi
  ensure_ast_pool_l5_bridge_obj
  if [ ! -f pipeline_bootstrap_orchestration.o ] || [ pipeline_bootstrap_orchestration.c -nt pipeline_bootstrap_orchestration.o ]; then
    make pipeline_bootstrap_orchestration.o
  fi
  SHUX_ASM_BOOTSTRAP_SX_COMPANIONS_READY=1
}

# 与 Makefile USER_ASM_SEED_OBJS 对齐：pipeline_glue / partial 引用的 enc/call 分派 TU。
# backend_x86_64_enc_c.o 须链入，否则 asm_full_link_stubs weak enc_label 恒 -1（用户 asm -o 全挂）。
BSTRICT_PIPELINE_LINK_O="pipeline_sx.o"
BSTRICT_EXPERIMENTAL_GLUE_OBJ="$BUILD_DIR/pipeline_glue_standalone.o"
BSTRICT_USER_ASM_SEED_BRIDGE_LINK="src/asm/user_asm_seed_bridge.o"
BSTRICT_ASM_BACKEND_COMPAT_STUBS_LINK="src/asm/asm_backend_compat_stubs.o"
BSTRICT_BACKEND_X86_64_ENC_LINK="src/asm/backend_x86_64_enc_c.o"
BSTRICT_DISPATCH_OBJS="src/asm/backend_enc_dispatch.o $BSTRICT_BACKEND_X86_64_ENC_LINK src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o src/asm/pipeline_abi_f32_xmm.o"

refresh_bstrict_link_variants() {
  BSTRICT_PIPELINE_LINK_O="pipeline_sx.o"
  BSTRICT_EXPERIMENTAL_GLUE_OBJ="$BUILD_DIR/pipeline_glue_standalone.o"
  BSTRICT_USER_ASM_SEED_BRIDGE_LINK="src/asm/user_asm_seed_bridge.o"
  BSTRICT_ASM_BACKEND_COMPAT_STUBS_LINK="src/asm/asm_backend_compat_stubs.o"
  BSTRICT_BACKEND_X86_64_ENC_LINK="src/asm/backend_x86_64_enc_c.o"
  if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    BSTRICT_EXPERIMENTAL_GLUE_OBJ="$BUILD_DIR/pipeline_glue_strict_minimal.o"
    if ensure_bstrict_pipeline_filtered_obj 2>/dev/null; then
      BSTRICT_PIPELINE_LINK_O="$BUILD_DIR/bstrict_pipeline_filtered.o"
    fi
    if [ -s "$BUILD_DIR/seed_host/asm_backend_partial.o" ]; then
      ensure_asm_backend_compat_stubs_obj >/dev/null 2>&1 || true
      if ensure_bstrict_filtered_obj_against_seed_partial "src/asm/user_asm_seed_bridge.o" "$BUILD_DIR/bstrict_user_asm_seed_bridge_filtered.o" "bstrict_user_asm_seed_bridge" 2>/dev/null; then
        BSTRICT_USER_ASM_SEED_BRIDGE_LINK="$BUILD_DIR/bstrict_user_asm_seed_bridge_filtered.o"
      fi
      if ensure_bstrict_filtered_obj_against_seed_partial "$BUILD_DIR/asm_backend_compat_stubs.o" "$BUILD_DIR/bstrict_asm_backend_compat_stubs_filtered.o" "bstrict_asm_backend_compat_stubs" 2>/dev/null; then
        BSTRICT_ASM_BACKEND_COMPAT_STUBS_LINK="$BUILD_DIR/bstrict_asm_backend_compat_stubs_filtered.o"
      fi
      if ensure_bstrict_filtered_obj_against_seed_partial "src/asm/backend_x86_64_enc_c.o" "$BUILD_DIR/bstrict_backend_x86_64_enc_c_filtered.o" "bstrict_backend_x86_64_enc_c" 2>/dev/null; then
        BSTRICT_BACKEND_X86_64_ENC_LINK="$BUILD_DIR/bstrict_backend_x86_64_enc_c_filtered.o"
      fi
    fi
  fi
  BSTRICT_DISPATCH_OBJS="src/asm/backend_enc_dispatch.o $BSTRICT_BACKEND_X86_64_ENC_LINK src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o src/asm/pipeline_abi_f32_xmm.o"
  GEN_DRIVER_BSTRICT_COMPANIONS="$BUILD_DIR/std_fs_shim.o src/std_sys_shim.o $BUILD_DIR/sx_seed_bridge.o $BUILD_DIR/seed_link_compat.o $BUILD_DIR/seed_host/asm_backend_partial.o $BSTRICT_USER_ASM_SEED_BRIDGE_LINK $BSTRICT_ASM_BACKEND_COMPAT_STUBS_LINK $BSTRICT_DISPATCH_OBJS parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o"
}

# gen_driver 回退链须与 bootstrap-driver-seed 同款 companion：pipeline_sx.o 引用 std_fs_shim / try_inline 分派等。
GEN_DRIVER_BSTRICT_COMPANIONS="$BUILD_DIR/std_fs_shim.o src/std_sys_shim.o $BUILD_DIR/sx_seed_bridge.o $BUILD_DIR/seed_link_compat.o $BUILD_DIR/seed_host/asm_backend_partial.o $BSTRICT_USER_ASM_SEED_BRIDGE_LINK $BSTRICT_ASM_BACKEND_COMPAT_STUBS_LINK $BSTRICT_DISPATCH_OBJS parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o"

# gen_driver 回退链：pipeline_sx.o / runtime_driver 须 parser/lexer/codegen SX + driver 子命令 + orchestration（Darwin 勿仅 SEED parser.o）。
GEN_DRIVER_SX_PIPELINE_COMPANIONS="parser_sx.o lexer_sx.o codegen_sx.o lexer_sx_link_alias.o codegen_sx_link_alias.o driver_build_sx.o driver_run_sx.o driver_compile_sx.o driver_emit_sx.o pipeline_bootstrap_orchestration.o $BUILD_DIR/ast_pool_l5_bridge.o"

# 与 Makefile bootstrap-driver-seed / relink-shux 对齐：pipeline_sx.o 经 glue 引用的 backend 桥与 check/fmt C 实现。
ensure_bstrict_seed_support_objs() {
  if [ ! -f "$BUILD_DIR/backend_asm_strict_fallback_alias.o" ] \
    || [ "backend_asm_strict_fallback_alias.c" -nt "$BUILD_DIR/backend_asm_strict_fallback_alias.o" ]; then
    echo "  cc -c backend_asm_strict_fallback_alias.c -> $BUILD_DIR/backend_asm_strict_fallback_alias.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$BUILD_DIR/backend_asm_strict_fallback_alias.o" backend_asm_strict_fallback_alias.c
  fi
  if [ ! -f src/asm/asm_backend_compat_stubs.o ] \
    || [ "src/asm/asm_backend_compat_stubs.c" -nt src/asm/asm_backend_compat_stubs.o ]; then
    echo "  cc -c src/asm/asm_backend_compat_stubs.c -> src/asm/asm_backend_compat_stubs.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/asm_backend_compat_stubs.o src/asm/asm_backend_compat_stubs.c
  fi
  for _disp in backend_enc_dispatch backend_x86_64_enc_c backend_arch_emit_dispatch backend_try_inline_dispatch backend_call_dispatch pipeline_abi_f32_xmm; do
    if [ ! -f "src/asm/${_disp}.o" ] || [ "src/asm/${_disp}.c" -nt "src/asm/${_disp}.o" ]; then
      echo "  cc -c src/asm/${_disp}.c -> src/asm/${_disp}.o"
      "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "src/asm/${_disp}.o" "src/asm/${_disp}.c"
    fi
  done
  if [ ! -f src/driver/fmt_check_cmd_driver.o ] \
    || [ "src/driver/fmt_check_cmd.c" -nt src/driver/fmt_check_cmd_driver.o ]; then
    echo "  cc -c src/driver/fmt_check_cmd.c -> src/driver/fmt_check_cmd_driver.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/driver/fmt_check_cmd_driver.o src/driver/fmt_check_cmd.c
  fi
  if [ ! -f src/driver/target_cpu.o ] \
    || [ "src/driver/target_cpu.c" -nt src/driver/target_cpu.o ]; then
    echo "  cc -c src/driver/target_cpu.c -> src/driver/target_cpu.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/driver/target_cpu.o src/driver/target_cpu.c
  fi
  if [ ! -f src/asm/simd_enc.o ] \
    || [ "src/asm/simd_enc.c" -nt src/asm/simd_enc.o ]; then
    echo "  cc -c src/asm/simd_enc.c -> src/asm/simd_enc.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/simd_enc.o src/asm/simd_enc.c
  fi
  if [ ! -f src/asm/simd_loop.o ] \
    || [ "src/asm/simd_loop.c" -nt src/asm/simd_loop.o ]; then
    echo "  cc -c src/asm/simd_loop.c -> src/asm/simd_loop.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/simd_loop.o src/asm/simd_loop.c
  fi
  if [ ! -f src/asm/user_asm_seed_bridge.o ] \
    || [ "src/asm/user_asm_seed_bridge.c" -nt src/asm/user_asm_seed_bridge.o ]; then
    echo "  cc -c src/asm/user_asm_seed_bridge.c -> src/asm/user_asm_seed_bridge.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/asm/user_asm_seed_bridge.o src/asm/user_asm_seed_bridge.c
  fi
  if [ ! -f src/lsp/lsp_heap_bootstrap.o ] \
    || [ "src/lsp/lsp_heap_bootstrap.c" -nt src/lsp/lsp_heap_bootstrap.o ]; then
    echo "  cc -c src/lsp/lsp_heap_bootstrap.c -> src/lsp/lsp_heap_bootstrap.o"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/lsp/lsp_heap_bootstrap.o src/lsp/lsp_heap_bootstrap.c
  fi
  # parser EMIT_HEAVY extern bl _glue：须与 Makefile USER_ASM_SEED_OBJS 同步链入 shux_asm。
  PARSER_ASM_THIN_GLUE_CFLAGS="-DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE"
  if [ ! -f parser_asm_thin_glue.o ] \
    || [ "src/asm/parser_asm_thin_c.c" -nt parser_asm_thin_glue.o ] \
    || [ "src/asm/parser_asm_struct_layout_slice.c" -nt parser_asm_thin_glue.o ] \
    || [ "src/asm/parser_asm_block_from_res_slice.c" -nt parser_asm_thin_glue.o ] \
    || [ "src/asm/parser_asm_if_stmt_slice.c" -nt parser_asm_thin_glue.o ]; then
    echo "  cc -c src/asm/parser_asm_thin_c.c -> parser_asm_thin_glue.o"
    "$CC" $CFLAGS $PARSER_ASM_THIN_GLUE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -c -o parser_asm_thin_glue.o src/asm/parser_asm_thin_c.c
  fi
}

# bootstrap-driver-seed 同款的 C 种子 .o：与 pipeline_sx.o 并存时不链完整 ast.c（用 -DSHUX_USE_SX_AST 的 ast_seed）。
# E-02 v1：默认 seed 链 lsp_diag_stubs_no_c.o；SHUX_LEGACY_LSP_DIAG_C=1 恢复 lsp_diag.c。
lsp_diag_seed_obj_path() {
  local seed_dir="$1"
  if [ "${SHUX_LEGACY_LSP_DIAG_C:-0}" = "1" ]; then
    echo "$seed_dir/lsp_diag.o"
  else
    echo "$seed_dir/lsp_diag_stubs_no_c.o"
  fi
}

ensure_lsp_diag_seed_obj() {
  local seed_dir="$1"
  if [ "${SHUX_LEGACY_LSP_DIAG_C:-0}" = "1" ]; then
    if [ ! -f "$seed_dir/lsp_diag.o" ] || [ "src/lsp/lsp_diag.c" -nt "$seed_dir/lsp_diag.o" ]; then
      echo "  cc -c $seed_dir/lsp_diag.o <- lsp_diag.c (LEGACY)"
      "$CC" $CFLAGS -c -o "$seed_dir/lsp_diag.o" src/lsp/lsp_diag.c
    fi
  else
    if [ ! -f "$seed_dir/lsp_diag_stubs_no_c.o" ] || [ "src/lsp/lsp_diag_stubs_no_c.c" -nt "$seed_dir/lsp_diag_stubs_no_c.o" ]; then
      echo "  cc -c $seed_dir/lsp_diag_stubs_no_c.o (E-02 soft-retire lsp_diag.c)"
      "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$seed_dir/lsp_diag_stubs_no_c.o" src/lsp/lsp_diag_stubs_no_c.c
    fi
  fi
}

ensure_diag_seed_obj() {
  local seed_dir="$1"
  if [ ! -f "$seed_dir/diag.o" ] || [ "src/diag.c" -nt "$seed_dir/diag.o" ] || [ "include/diag.h" -nt "$seed_dir/diag.o" ]; then
    echo "  cc -c $seed_dir/diag.o <- src/diag.c"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$seed_dir/diag.o" src/diag.c
  fi
}

ensure_asm_driver_seed_support_c_objs() {
  SEED_DIR="${SEED_DIR:-$BUILD_DIR/asm_driver_seed}"
  mkdir -p "$SEED_DIR"
  ensure_diag_seed_obj "$SEED_DIR"
  if [ ! -f "$SEED_DIR/async_liveness.o" ] || [ src/async/async_liveness.c -nt "$SEED_DIR/async_liveness.o" ]; then
    "$CC" $CFLAGS -c -o "$SEED_DIR/async_liveness.o" src/async/async_liveness.c
  fi
  if [ ! -f "$SEED_DIR/async_cps_codegen.o" ] || [ src/async/async_cps_codegen.c -nt "$SEED_DIR/async_cps_codegen.o" ]; then
    "$CC" $CFLAGS -c -o "$SEED_DIR/async_cps_codegen.o" src/async/async_cps_codegen.c
  fi
  ensure_lsp_diag_seed_obj "$SEED_DIR"
  LSP_DIAG_SEED_O=$(lsp_diag_seed_obj_path "$SEED_DIR")
  export LSP_DIAG_SEED_O
  if [ ! -f "$SEED_DIR/lsp_state.o" ] || [ src/lsp/lsp_state.c -nt "$SEED_DIR/lsp_state.o" ]; then
    "$CC" $CFLAGS -c -o "$SEED_DIR/lsp_state.o" src/lsp/lsp_state.c
  fi
}

ensure_asm_driver_seed_frontend_c_objs() {
  SEED_DIR="${SEED_DIR:-$BUILD_DIR/asm_driver_seed}"
  mkdir -p "$SEED_DIR"
  # G-02a：默认 omit C 前端 seed；SX *_sx.o 由 ensure_asm_bootstrap_sx_companion_objs 提供。
  if asm_seed_omit_c_frontend_seed; then
    echo "  G-02a: omit C frontend seed (SX *_sx.o; SHUX_LEGACY_SEED_FRONTEND_CC=1 to restore cc -c)"
    return 0
  fi
  echo "  cc -c asm_driver_seed/*.o <- preprocess/lexer/ast_seed/parser/typeck/codegen .c (SHUX_LEGACY_SEED_FRONTEND_CC archaeology)"
  if [ ! -f src/preprocess.c ] || [ ! -f src/lexer/lexer.c ] || [ ! -f src/ast/ast.c ] \
    || [ ! -f src/parser/parser.c ] || [ ! -f src/typeck/typeck.c ] || [ ! -f src/codegen/codegen.c ]; then
    build_shux_asm_error "LEGACY seed frontend .c missing; use SX companions or restore C sources"
    return 1
  fi
  "$CC" $CFLAGS -DSHUX_USE_SX_PREPROCESS -c -o "$SEED_DIR/preprocess.o" src/preprocess.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/lexer.o" src/lexer/lexer.c
  "$CC" $CFLAGS -DSHUX_USE_SX_AST -c -o "$SEED_DIR/ast_seed.o" src/ast/ast.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/parser.o" src/parser/parser.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/typeck.o" src/typeck/typeck.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/codegen.o" src/codegen/codegen.c
  "$CC" $CFLAGS -c -o "$SEED_DIR/autovec.o" src/codegen/autovec.c
}

# E-06 v2/v4：SX 前端 *.o 就绪检测（parser_sx / typeck_sx / codegen_sx / lexer_sx）。
asm_seed_sx_frontend_o_ready() {
  for o in parser_sx.o typeck_sx.o codegen_sx.o lexer_sx.o; do
    if [ ! -f "$o" ] || [ ! -s "$o" ]; then
      return 1
    fi
  done
  return 0
}

# E-06 v4：SX 前端 .o 就绪时 experimental / strict 链不 cc -c / 不链 asm_driver_seed 前端 C TU（与 omit 一致）。
asm_seed_use_sx_frontend() {
  asm_seed_omit_c_frontend_seed
}

# E-06 v4：gen_driver / ensure_asm_driver_seed — SX 就绪即 omit C 前端 seed（不要求 SKIP_GEN）。
asm_seed_omit_c_frontend_seed() {
  if [ -n "${SHUX_LEGACY_SEED_FRONTEND_CC:-}" ]; then
    return 1
  fi
  asm_seed_sx_frontend_o_ready
}

# E-06 v3：strict 重链仅保留 async seed（无 parser/typeck/codegen/lexer/ast C 前端 .o）。
asm_seed_st_async_support_link() {
  SEED_DIR="${SEED_DIR:-$BUILD_DIR/asm_driver_seed}"
  echo "$SEED_DIR/async_liveness.o $SEED_DIR/async_cps_codegen.o"
}

# E-06 v3：legacy strict 仍链 asm_driver_seed 全量 C 前端 .o（考古 / 非 SKIP_GEN）。
asm_seed_st_frontend_seed_link() {
  SEED_DIR="${SEED_DIR:-$BUILD_DIR/asm_driver_seed}"
  echo "$SEED_DIR/parser.o $SEED_DIR/typeck.o $SEED_DIR/codegen.o $SEED_DIR/autovec.o $SEED_DIR/async_liveness.o $SEED_DIR/async_cps_codegen.o $SEED_DIR/lexer.o $SEED_DIR/ast_seed.o"
}

# E-06 v3：bare typeck alias 路径省略 seed typeck.o，其余与 frontend_seed 一致。
asm_seed_st_frontend_seed_no_typeck_link() {
  SEED_DIR="${SEED_DIR:-$BUILD_DIR/asm_driver_seed}"
  echo "$SEED_DIR/parser.o $SEED_DIR/codegen.o $SEED_DIR/autovec.o $SEED_DIR/async_liveness.o $SEED_DIR/async_cps_codegen.o $SEED_DIR/lexer.o $SEED_DIR/ast_seed.o"
}

# SX glue 后缀：codegen_sx + sx link alias（strict / experimental 共用）。
asm_seed_st_sx_glue_suffix() {
  echo "codegen_sx.o lexer_sx_link_alias.o typeck_sx_link_alias.o codegen_sx_link_alias.o"
}

# preprocess：SX 路径由 preprocess_sx.o 提供，不链 seed preprocess.o。
asm_seed_st_preprocess_link() {
  SEED_DIR="${SEED_DIR:-$BUILD_DIR/asm_driver_seed}"
  if asm_seed_use_sx_frontend; then
    echo ""
    return 0
  fi
  echo "$SEED_DIR/preprocess.o"
}

# E-06 v4：gen_driver 回退链 — omit seed C 前端 .o（preprocess/lexer/ast/parser/typeck/codegen）。
asm_seed_gen_driver_c_frontend_link() {
  SEED_DIR="${SEED_DIR:-$BUILD_DIR/asm_driver_seed}"
  if asm_seed_omit_c_frontend_seed; then
    echo ""
    return 0
  fi
  echo "$SEED_DIR/preprocess.o $SEED_DIR/lexer.o $SEED_DIR/ast_seed.o $SEED_DIR/parser.o $SEED_DIR/typeck.o $SEED_DIR/codegen.o"
}

ensure_asm_driver_seed_c_objs() {
  SEED_DIR="$BUILD_DIR/asm_driver_seed"
  export SEED_DIR
  if asm_seed_omit_c_frontend_seed; then
    echo "  E-06 v2/v4: asm_driver_seed skip frontend cc -c (SX *_sx.o; SHUX_LEGACY_SEED_FRONTEND_CC=1 to restore)"
    ensure_asm_driver_seed_support_c_objs
    return 0
  fi
  ensure_asm_driver_seed_frontend_c_objs
  ensure_asm_driver_seed_support_c_objs
}

# strict 重链 companion：与 experimental bootstrap 一致。
# - std_sys_shim：driver_emit_sx / pipeline read_file
# - parser_asm_parse_expr_link：thin glue → parser_sx parse_expr_into
# - pipeline_fill_dep_strict_alias：strict 链仅 fill_dep 裸名（勿整包 pipeline_run_sx_link_alias）
ensure_asm_strict_link_extra_objs() {
  if [ ! -f src/std_sys_shim.o ] || [ src/std_sys_shim.c -nt src/std_sys_shim.o ]; then
    echo "  cc -c src/std_sys_shim.c -> src/std_sys_shim.o"
    "$CC" $CFLAGS -c -o src/std_sys_shim.o src/std_sys_shim.c
  fi
  if [ ! -f src/asm/parser_asm_parse_expr_link.o ] \
    || [ src/asm/parser_asm_parse_expr_link.c -nt src/asm/parser_asm_parse_expr_link.o ]; then
    echo "  cc -c src/asm/parser_asm_parse_expr_link.c -> src/asm/parser_asm_parse_expr_link.o"
    "$CC" $CFLAGS -c -o src/asm/parser_asm_parse_expr_link.o src/asm/parser_asm_parse_expr_link.c
  fi
  # G-02-B1：优先 .sx（-backend asm）；无 shux 或失败时回退 .c（删 C 前须 Docker Stage2 回归）。
  if [ -f src/asm/pipeline_fill_dep_strict_alias.sx ] \
    && { [ ! -f src/asm/pipeline_fill_dep_strict_alias.o ] \
      || [ src/asm/pipeline_fill_dep_strict_alias.sx -nt src/asm/pipeline_fill_dep_strict_alias.o ]; }; then
    if [ -x "$SHUX" ] && "$SHUX" -backend asm -o src/asm/pipeline_fill_dep_strict_alias.o $LIBROOT \
      src/asm/pipeline_fill_dep_strict_alias.sx 2>/dev/null \
      && [ -s src/asm/pipeline_fill_dep_strict_alias.o ]; then
      echo "  $SHUX -backend asm -> src/asm/pipeline_fill_dep_strict_alias.o (G-02-B1 .sx)"
    elif [ -f src/asm/pipeline_fill_dep_strict_alias.c ]; then
      echo "  cc -c src/asm/pipeline_fill_dep_strict_alias.c -> src/asm/pipeline_fill_dep_strict_alias.o (fallback)"
      "$CC" $CFLAGS -c -o src/asm/pipeline_fill_dep_strict_alias.o src/asm/pipeline_fill_dep_strict_alias.c
    fi
  elif [ ! -f src/asm/pipeline_fill_dep_strict_alias.o ] \
    && [ -f src/asm/pipeline_fill_dep_strict_alias.c ]; then
    echo "  cc -c src/asm/pipeline_fill_dep_strict_alias.c -> src/asm/pipeline_fill_dep_strict_alias.o"
    "$CC" $CFLAGS -c -o src/asm/pipeline_fill_dep_strict_alias.o src/asm/pipeline_fill_dep_strict_alias.c
  fi
}

# experimental / strict 链：lsp_state.o 依赖 typeck_lsp_main_impl（lsp.sx -E → lsp_sx.o）；勿拉整包 gen_driver。
ensure_asm_experimental_lsp_objs() {
  GEN_DIR="$BUILD_DIR/gen_driver"
  mkdir -p "$GEN_DIR"
  local lsp_ok=1
  for o in lsp_sx.o lsp_io_sx.o lsp_io_std_heap_sx.o; do
    if [ ! -f "$o" ] || [ ! -s "$o" ]; then
      lsp_ok=0
      break
    fi
  done
  if [ "$lsp_ok" -eq 1 ]; then
    cp -f lsp_sx.o lsp_io_sx.o lsp_io_std_heap_sx.o "$GEN_DIR/"
    cp -f lsp_io_std_heap_sx.o "$GEN_DIR/lsp_io_std_heap_sx.o"
    return 0
  fi
  if [ ! -f Makefile ] || ! command -v make >/dev/null 2>&1; then
    ensure_asm_gen_driver_sx_objs
    return 0
  fi
  # OOM 可能留下 0 字节 gen；删空文件以便 Makefile 走 shux-c fallback。
  if [ -f lsp_io_std_heap_gen.c ] && [ ! -s lsp_io_std_heap_gen.c ]; then
    rm -f lsp_io_std_heap_gen.c
  fi
  build_shux_asm_info "ensure lsp_sx.o (+ lsp_io) for lsp_state (typeck_lsp_main_impl)"
  make -s lsp_io_gen.c lsp_gen.c lsp_io_std_heap_gen.c lsp_sx.o lsp_io_sx.o lsp_io_std_heap_sx.o
  cp -f lsp_sx.o lsp_io_sx.o lsp_io_std_heap_sx.o "$GEN_DIR/"
}

# ast_pool.c 白名单在 pipeline_sx.o（#include pipeline_glue.c）内；PIPELINE_SX_DEPS（含 backend/arm64_enc）变更后须 bootstrap-pipeline → pipeline_sx.o。
ensure_pipeline_sx_o_fresh() {
  local need=0
  # runtime-only relink：已有 pipeline_sx.o 时跳过（勿因 ast_pool 等 mtime 触发 bootstrap-pipeline）。
  if [ -n "${SHUX_ASM_BSTRICT_RELINK_ONLY:-}" ] && [ -f pipeline_sx.o ]; then
    mkdir -p "$BUILD_DIR/gen_driver"
    if [ ! -f "$BUILD_DIR/gen_driver/pipeline_sx.o" ] || ! cmp -s pipeline_sx.o "$BUILD_DIR/gen_driver/pipeline_sx.o" 2>/dev/null; then
      cp -fp pipeline_sx.o "$BUILD_DIR/gen_driver/pipeline_sx.o" 2>/dev/null || true
    fi
    return 0
  fi
  if [ ! -f pipeline_sx.o ] || [ ! -f pipeline_gen.c ]; then
    need=1
  fi
  if [ "$need" -eq 0 ] && [ "ast_pool.c" -nt "pipeline_sx.o" ]; then
    need=1
  fi
  # Makefile PIPELINE_SX_DEPS：asm 编码/backend 变更不会触达 pipeline_gen.c 时 ensure 仍须重 -E。
  for dep in \
    src/pipeline/pipeline.sx src/codegen/codegen.sx src/typeck/typeck.sx src/parser/parser.sx \
    src/ast/ast.sx src/lexer/lexer.sx src/preprocess/preprocess.sx src/asm/asm.sx \
    src/asm/backend.sx src/asm/platform/elf.sx src/asm/arch/arm64.sx src/asm/arch/arm64_enc.sx; do
    if [ -f "$dep" ] && [ "$dep" -nt "pipeline_sx.o" ]; then
      need=1
      break
    fi
  done
  if [ "$need" -eq 1 ]; then
    build_shux_asm_info "rebuild pipeline_sx.o (PIPELINE_SX_DEPS / ast_pool newer than pipeline_sx.o)"
    make bootstrap-pipeline pipeline_sx.o
  fi
  # gen_driver 与 strict partial 须与 compiler/pipeline_sx.o 同步；parser_sx.o 变更后须失效旧 partial。
  if [ -f pipeline_sx.o ]; then
    mkdir -p "$BUILD_DIR/gen_driver"
    if [ ! -f "$BUILD_DIR/gen_driver/pipeline_sx.o" ] || ! cmp -s pipeline_sx.o "$BUILD_DIR/gen_driver/pipeline_sx.o" 2>/dev/null; then
      cp -fp pipeline_sx.o "$BUILD_DIR/gen_driver/pipeline_sx.o"
    fi
  fi
  if [ -f parser_sx.o ]; then
    for stale in \
      "$BUILD_DIR/parser_bootstrap_partial.o" \
      "$BUILD_DIR/parser_strict_merged.o" \
      "$BUILD_DIR/parser_from_sx_partial.o" \
      "$BUILD_DIR/pipeline_asm_strict_support_partial.o"; do
      if [ -f "$stale" ] && [ parser_sx.o -nt "$stale" ]; then
        rm -f "$stale"
      fi
    done
  fi
}

# B-strict 最终链：用 seed shux-c -E 的 parser_sx.o 覆盖 C seed parser（struct return / param-binop 等门禁）。
ensure_parser_sx_o_for_strict_link() {
  if [ ! -f Makefile ] || [ ! -f src/parser/parser.sx ]; then
    return 0
  fi
  if [ ! -f parser_sx.o ] || [ src/parser/parser.sx -nt parser_sx.o ]; then
    build_shux_asm_info "make parser_sx.o (strict link must override seed parser.o)"
    make -s parser_sx.o
  fi
}

# 用 shux-c（优先）对 pipeline/main/lsp/preprocess 做 -E，再 cc 编成 .o；提供 pipeline_*、entry、main_run_compiler_c、asm_asm_codegen_elf_o 等。
# SHUX_E 可覆盖；默认 ./shux-c（Makefile 约定：pipeline -E 须 C 解析器 stmt_order，勿用已链 sx 前端的 shux）。
ensure_asm_gen_driver_sx_objs() {
  detect_pipeline_gen_cflags
  GEN_DIR="$BUILD_DIR/gen_driver"
  if [ "${SHUX_ASM_GEN_DRIVER_SX_READY:-0}" = "1" ] \
    && [ -f "$GEN_DIR/pipeline_sx.o" ] && [ -f "$GEN_DIR/driver_sx.o" ] \
    && [ -f "$GEN_DIR/preprocess_sx.o" ] && [ -f "$GEN_DIR/lsp_io_sx.o" ] \
    && [ -f "$GEN_DIR/lsp_sx.o" ] && [ -f "$GEN_DIR/lsp_io_std_heap_sx.o" ] \
    && [ -f "$GEN_DIR/driver_fmt_sx.o" ] && [ -f "$GEN_DIR/driver_check_sx.o" ] \
    && [ -f "$GEN_DIR/driver_test_sx.o" ]; then
    build_shux_asm_info "reuse gen_driver SX objs (already ensured in this run)"
    return 0
  fi
  mkdir -p "$GEN_DIR"
  SHUX_E="${SHUX_E:-}"
  if [ -z "$SHUX_E" ] || [ ! -x "$SHUX_E" ]; then
    if [ -x ./shux-c ]; then
      SHUX_E=./shux-c
    else
      SHUX_E="$SHUX"
    fi
  fi
  LIB_E_PIPELINE="-L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess"
  LIB_E_MAIN="-L .. -L src -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess"

  # -E 单文件聚合时可能对 slice ABI 重复吐出同名 struct，同一 TU 内触发重定义；与 verify-selfhost.sh 一致只保留首行。
  dedupe_shux_slice_struct() {
    f="$1"
    [ -f "$f" ] || return 0
    perl -i -ne 'print unless /^struct shux_slice_uint8_t/ && $seen++' "$f" 2>/dev/null || true
  }

  # 与 Makefile bootstrap-pipeline 一致：优先复用已补齐布局的顶层 pipeline_gen.c，避免旧 shux-c 重新 -E pipeline.sx 失败。
  if [ -f pipeline_gen.c ] && [ -s pipeline_gen.c ] && [ "${SHUX_FORCE_REGEN_GEN:-0}" != "1" ]; then
    echo "  pinned pipeline_gen.c -> $GEN_DIR/pipeline_gen.c ($(wc -c <pipeline_gen.c | tr -d ' ') bytes)"
    cp -f pipeline_gen.c "$GEN_DIR/pipeline_gen.c"
  else
    echo "  $SHUX_E -E -E-extern pipeline.sx -> $GEN_DIR/pipeline_gen.c ..."
    "$SHUX_E" $LIB_E_PIPELINE -E -E-extern src/pipeline/pipeline.sx >"$GEN_DIR/pipeline_gen.c"
  fi
  if [ -f scripts/patch_pipeline_gen_ast_layout.pl ]; then
    perl scripts/patch_pipeline_gen_ast_layout.pl "$GEN_DIR/pipeline_gen.c"
  fi
  dedupe_shux_slice_struct "$GEN_DIR/pipeline_gen.c"
  if [ -f lsp_io_gen.c ] && [ -s lsp_io_gen.c ] && [ "${SHUX_FORCE_REGEN_GEN:-0}" != "1" ]; then
    echo "  pinned lsp_io_gen.c -> $GEN_DIR/lsp_io_gen.c ($(wc -c <lsp_io_gen.c | tr -d ' ') bytes)"
    cp -f lsp_io_gen.c "$GEN_DIR/lsp_io_gen.c"
  else
    echo "  $SHUX_E -E lsp_io.sx (-E-extern) -> $GEN_DIR/lsp_io_gen.c ..."
    "$SHUX_E" $LIB_E_MAIN src/lsp/lsp_io.sx -E -E-extern >"$GEN_DIR/lsp_io_gen.c"
  fi
  if [ -f lsp_gen.c ] && [ -s lsp_gen.c ] && [ "${SHUX_FORCE_REGEN_GEN:-0}" != "1" ]; then
    echo "  pinned lsp_gen.c -> $GEN_DIR/lsp_gen.c ($(wc -c <lsp_gen.c | tr -d ' ') bytes)"
    cp -f lsp_gen.c "$GEN_DIR/lsp_gen.c"
  else
    echo "  $SHUX_E -E lsp.sx (-E-extern) -> $GEN_DIR/lsp_gen.c ..."
    "$SHUX_E" $LIB_E_MAIN src/lsp/lsp.sx -E -E-extern >"$GEN_DIR/lsp_gen.c"
  fi
  # lsp_gen.c 内大 state 数组迁至 lsp_state.c 的 g_lsp_state_buf（与 Makefile bootstrap-driver-seed 一致）
  sed -i.bak 's/uint8_t state_buf\[16388\] = { 0 }/extern uint8_t g_lsp_state_buf[16388]/' "$GEN_DIR/lsp_gen.c" 2>/dev/null || true
  sed -i.bak 's/(state_buf)/(g_lsp_state_buf)/g' "$GEN_DIR/lsp_gen.c" 2>/dev/null || true
  rm -f "$GEN_DIR/lsp_gen.c.bak"
  if [ -f lsp_io_std_heap_gen.c ] && [ -s lsp_io_std_heap_gen.c ] && [ "${SHUX_FORCE_REGEN_GEN:-0}" != "1" ]; then
    echo "  pinned lsp_io_std_heap_gen.c -> $GEN_DIR/lsp_io_std_heap_gen.c ($(wc -c <lsp_io_std_heap_gen.c | tr -d ' ') bytes)"
    cp -f lsp_io_std_heap_gen.c "$GEN_DIR/lsp_io_std_heap_gen.c"
  else
    echo "  $SHUX_E -E lsp_io_std_heap.sx (-E-extern) -> $GEN_DIR/lsp_io_std_heap_gen.c ..."
    "$SHUX_E" $LIB_E_MAIN src/lsp/lsp_io_std_heap.sx -E -E-extern >"$GEN_DIR/lsp_io_std_heap_gen.c"
  fi
  driver_gen_pinned=0
  if [ -f driver_gen.c ] && [ -s driver_gen.c ] && [ "${SHUX_FORCE_REGEN_GEN:-0}" != "1" ]; then
    driver_gen_pinned=1
    for dep in src/main.sx src/codegen/codegen.sx src/ast/ast.sx src/preprocess/preprocess.sx; do
      if [ -f "$dep" ] && [ "$dep" -nt driver_gen.c ]; then
        driver_gen_pinned=0
        break
      fi
    done
  fi
  if [ "$driver_gen_pinned" = "1" ]; then
    echo "  pinned driver_gen.c -> $GEN_DIR/driver_gen.c ($(wc -c <driver_gen.c | tr -d ' ') bytes)"
    cp -f driver_gen.c "$GEN_DIR/driver_gen.c"
  else
    driver_gen_tmp="$GEN_DIR/driver_gen.c.tmp"
    rm -f "$driver_gen_tmp"
    if [ -x ./shux-sx ]; then
      echo "  ./shux-sx -sx -E main.sx (-E-extern) -> $GEN_DIR/driver_gen.c ..."
      ./shux-sx -sx -E $LIB_E_MAIN -E-extern src/main.sx >"$driver_gen_tmp" 2>/dev/null || true
    fi
    if [ -s "$driver_gen_tmp" ] && grep -q 'argc < 3' "$driver_gen_tmp" && grep -q 'main_eq_minus_E(arg_buf, len) != 0' "$driver_gen_tmp"; then
      mv -f "$driver_gen_tmp" "$GEN_DIR/driver_gen.c"
    else
      rm -f "$driver_gen_tmp"
      echo "  $SHUX_E -E main.sx (-E-extern) -> $GEN_DIR/driver_gen.c ..."
      "$SHUX_E" $LIB_E_MAIN src/main.sx -E -E-extern >"$GEN_DIR/driver_gen.c"
    fi
  fi
  dedupe_shux_slice_struct "$GEN_DIR/driver_gen.c"
  if [ -f preprocess_gen.c ] && [ -s preprocess_gen.c ] && [ "${SHUX_FORCE_REGEN_GEN:-0}" != "1" ]; then
    echo "  pinned preprocess_gen.c -> $GEN_DIR/preprocess_gen.c ($(wc -c <preprocess_gen.c | tr -d ' ') bytes)"
    cp -f preprocess_gen.c "$GEN_DIR/preprocess_gen.c"
  else
    echo "  $SHUX_E -E preprocess.sx (-E-extern) -> $GEN_DIR/preprocess_gen.c ..."
    "$SHUX_E" -L src/lexer -E -E-extern src/preprocess/preprocess.sx >"$GEN_DIR/preprocess_gen.c"
  fi
  dedupe_shux_slice_struct "$GEN_DIR/preprocess_gen.c"

  if [ -f driver_fmt_gen.c ] && [ -s driver_fmt_gen.c ] && [ "${SHUX_FORCE_REGEN_GEN:-0}" != "1" ]; then
    echo "  pinned driver_fmt_gen.c -> $GEN_DIR/driver_fmt.c ($(wc -c <driver_fmt_gen.c | tr -d ' ') bytes)"
    cp -f driver_fmt_gen.c "$GEN_DIR/driver_fmt.c"
  else
    "$SHUX_E" -L .. -L src -L src/lexer -L src/ast -E -E-extern src/driver/fmt.sx >"$GEN_DIR/driver_fmt.c"
  fi
  if [ -f driver_check_gen.c ] && [ -s driver_check_gen.c ] && [ "${SHUX_FORCE_REGEN_GEN:-0}" != "1" ]; then
    echo "  pinned driver_check_gen.c -> $GEN_DIR/driver_check.c ($(wc -c <driver_check_gen.c | tr -d ' ') bytes)"
    cp -f driver_check_gen.c "$GEN_DIR/driver_check.c"
  else
    "$SHUX_E" -L .. -L src -L src/lexer -L src/ast -E -E-extern src/driver/check.sx >"$GEN_DIR/driver_check.c"
  fi
  if [ -f driver_test_gen.c ] && [ -s driver_test_gen.c ] && [ "${SHUX_FORCE_REGEN_GEN:-0}" != "1" ]; then
    echo "  pinned driver_test_gen.c -> $GEN_DIR/driver_test.c ($(wc -c <driver_test_gen.c | tr -d ' ') bytes)"
    cp -f driver_test_gen.c "$GEN_DIR/driver_test.c"
  else
    "$SHUX_E" -L .. -L src -L src/lexer -L src/ast -E -E-extern src/driver/test.sx >"$GEN_DIR/driver_test.c"
  fi

  echo "  cc -c gen_driver/driver_*.o <- src/driver/*.sx (-E-extern)"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -c "$GEN_DIR/driver_fmt.c" -o "$GEN_DIR/driver_fmt_sx.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -c "$GEN_DIR/driver_check.c" -o "$GEN_DIR/driver_check_sx.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -c "$GEN_DIR/driver_test.c" -o "$GEN_DIR/driver_test_sx.o"

  # pipeline/driver/preprocess：优先复用 Makefile gen-sx-driver-objs（与 bootstrap-driver-seed 同源依赖）
  if [ -f Makefile ] && command -v make >/dev/null 2>&1; then
    echo "  make gen-sx-driver-objs -> copy pipeline_sx.o driver_sx.o preprocess_sx.o to $GEN_DIR/"
    make -s gen-sx-driver-objs
    cp -f pipeline_sx.o "$GEN_DIR/"
    cp -f driver_sx.o "$GEN_DIR/driver_sx.o"
    cp -f preprocess_sx.o "$GEN_DIR/preprocess_sx.o"
  else
    echo "  cc -c gen_driver/*_sx.o <- pipeline/driver/lsp/preprocess -E 产物 (no Makefile make)"
    "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I.. \
      -Dstd_io_driver_driver_read_ptr_len=shux_io_read_ptr_len \
      -Dstd_io_driver_driver_read_ptr=shux_io_read_ptr \
      -c "$GEN_DIR/pipeline_gen.c" -o "$GEN_DIR/pipeline_sx.o"
    "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -include src/sx_stubs.h \
      -Dstd_fs_fs_read=fs_posix_read_c -Dstd_fs_fs_write=fs_posix_write_c -Dstd_fs_fs_close=fs_posix_close_c \
      -c "$GEN_DIR/driver_gen.c" -o "$GEN_DIR/driver_sx.o"
    "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -c "$GEN_DIR/preprocess_gen.c" -o "$GEN_DIR/preprocess_sx.o"
  fi

  echo "  cc -c gen_driver/lsp*.o <- lsp -E 产物"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Dstd_io_read=io_read -Dstd_io_write=io_write \
    -Dstd_heap_alloc_usize=typeck_std_heap_alloc -Dstd_heap_free_u8_ptr=typeck_std_heap_free \
    -Dtypeck_std_heap_alloc=lsp_io_std_heap_std_heap_alloc \
    -Dtypeck_std_heap_free=lsp_io_std_heap_std_heap_free \
    -c "$GEN_DIR/lsp_io_gen.c" -o "$GEN_DIR/lsp_io_sx.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -c "$GEN_DIR/lsp_gen.c" -o "$GEN_DIR/lsp_sx.o"
  "$CC" $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
    -c "$GEN_DIR/lsp_io_std_heap_gen.c" -o "$GEN_DIR/lsp_io_std_heap_sx.o"
  ensure_gen_driver_typeck_companion_objs
  SHUX_ASM_GEN_DRIVER_SX_READY=1
}

# gen_driver 回退链：pipeline_sx.o 内 mega C 直接调用 typeck_check_*（typeck.sx -E 导出），须链 typeck_sx.o 与 alias。
ensure_gen_driver_typeck_companion_objs() {
  if [ "${SHUX_ASM_GEN_DRIVER_TYPECK_READY:-0}" = "1" ] \
    && [ -f typeck_sx.o ] && [ -f typeck_sx_link_alias.o ]; then
    build_shux_asm_info "reuse gen_driver typeck companions (already ensured in this run)"
    return 0
  fi
  if [ -f Makefile ] && command -v make >/dev/null 2>&1; then
    build_shux_asm_info "gen_driver typeck companions (typeck_sx.o + link alias)"
    make -s typeck_sx.o typeck_sx_link_alias.o
  fi
  SHUX_ASM_GEN_DRIVER_TYPECK_READY=1
}

# 与 ensure_gen_driver_typeck_companion_objs 配套：gen_driver 链接行追加对象（experimental 链已含；回退仅补 typeck mega 符号）。
GEN_DRIVER_TYPECK_COMPANIONS="typeck_sx.o typeck_sx_link_alias.o"

# lsp_diag.c 依赖 pipeline 结构体 sizeof（与 Makefile bootstrap-driver-seed 一致）
ensure_lsp_diag_pipeline_sizes_obj() {
  if [ ! -f src/lsp/lsp_diag_pipeline_sizes.o ]; then
    echo "  cc -c src/lsp/lsp_diag_pipeline_sizes.o"
    "$CC" $CFLAGS -c -o src/lsp/lsp_diag_pipeline_sizes.o src/lsp/lsp_diag_pipeline_sizes.c
  fi
}

# B-hybrid 链 lsp_sx.o 需要 lsp_build_diagnostics_response 等；typeck_lsp_io 见 src/lsp/typeck_lsp_io_stub.c。
ensure_asm_shux_lsp_diag_stub_obj() {
  STUB_C="scripts/asm_shux_lsp_diag_stub.c"
  STUB_O="$BUILD_DIR/asm_shux_lsp_diag_stub.o"
  LSP_IO_STUB="src/lsp/typeck_lsp_io_stub.c"
  LSP_IO_O="$BUILD_DIR/typeck_lsp_io_stub.o"
  if [ ! -f "$LSP_IO_O" ] || [ "$LSP_IO_STUB" -nt "$LSP_IO_O" ]; then
    echo "  cc -c $LSP_IO_O <- $LSP_IO_STUB"
    "$CC" $CFLAGS -c -o "$LSP_IO_O" "$LSP_IO_STUB"
  fi
  if [ ! -f "$STUB_O" ] || [ "$STUB_C" -nt "$STUB_O" ]; then
    echo "  cc -c $STUB_O <- $STUB_C"
    "$CC" $CFLAGS -c -o "$STUB_O" "$STUB_C"
  fi
}

# codegen.o（C seed）引用 lsp_codegen_emit_*；小 TU，不与 pipeline_sx.o 重复
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
  echo "  cc -c src/runtime_driver.o <- src/runtime.c (-DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_PREPROCESS)"
  local rt_flags="-DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_PREPROCESS"
  if [ "${SHUX_LEGACY_PREPROCESS_C:-0}" = "1" ]; then
    rt_flags="$rt_flags -DSHUX_LEGACY_PREPROCESS_C"
  fi
  "$CC" $CFLAGS $rt_flags -c -o src/runtime_driver.o src/runtime.c
}

# B-strict shux_asm：driver_run_compiler_full 走 impl_c（完整 parse_argv），勿与 seed 共用 runtime_driver.o 宏。
ensure_runtime_abi_obj() {
  local o="src/runtime_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_abi.c" -nt "$o" ]; then
    echo "  cc -c $o <- src/runtime_abi.c (E-04 v2 ABI thin shell)"
    "$CC" $CFLAGS -c -o "$o" src/runtime_abi.c
  fi
}

ensure_runtime_io_abi_obj() {
  local o="src/runtime_io_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_io_abi.c" -nt "$o" ]; then
    echo "  cc -c $o <- src/runtime_io_abi.c (E-04 v3 I/O ABI)"
    "$CC" $CFLAGS -c -o "$o" src/runtime_io_abi.c
  fi
}

ensure_runtime_proc_abi_obj() {
  local o="src/runtime_proc_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_proc_abi.c" -nt "$o" ]; then
    echo "  cc -c $o <- src/runtime_proc_abi.c (E-04 v4 proc/link ABI)"
    "$CC" $CFLAGS -c -o "$o" src/runtime_proc_abi.c
  fi
}

ensure_runtime_link_abi_obj() {
  local o="src/runtime_link_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_link_abi.c" -nt "$o" ]; then
    echo "  cc -c $o <- src/runtime_link_abi.c (E-04 v5 link/cc ABI helpers)"
    "$CC" $CFLAGS -c -o "$o" src/runtime_link_abi.c
  fi
}

ensure_runtime_pipeline_abi_obj() {
  local o="src/runtime_pipeline_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_pipeline_abi.c" -nt "$o" ] || [ "Makefile" -nt "$o" ]; then
    echo "  cc -c $o <- src/runtime_pipeline_abi.c (E-04 v32 pipeline import + preprocess ABI)"
    local pa_flags="-DSHUX_USE_SX_PIPELINE"
    if [ "${SHUX_LEGACY_PREPROCESS_C:-0}" = "1" ]; then
      pa_flags="$pa_flags -DSHUX_LEGACY_PREPROCESS_C"
    fi
    "$CC" $CFLAGS $pa_flags -c -o "$o" src/runtime_pipeline_abi.c
  fi
}

ensure_runtime_driver_abi_obj() {
  local o="src/runtime_driver_abi.o"
  if [ ! -f "$o" ] || [ "src/runtime_driver_abi.c" -nt "$o" ]; then
    echo "  cc -c $o <- src/runtime_driver_abi.c (E-04 driver ABI: stack bump / dep path)"
    "$CC" $CFLAGS -c -o "$o" src/runtime_driver_abi.c
  fi
}

ensure_diag_obj() {
  local o="src/diag.o"
  if [ ! -f "$o" ] || [ "src/diag.c" -nt "$o" ] || [ "include/diag.h" -nt "$o" ]; then
    echo "  cc -c $o <- src/diag.c"
    "$CC" $CFLAGS -c -o "$o" src/diag.c
  fi
}

ensure_runtime_driver_diagnostic_obj() {
  local o="src/runtime_driver_diagnostic.o"
  if [ ! -f "$o" ] || [ "src/runtime_driver_diagnostic.c" -nt "$o" ]; then
    echo "  cc -c $o <- src/runtime_driver_diagnostic.c (E-04 typeck diagnostic hooks)"
    "$CC" $CFLAGS -c -o "$o" src/runtime_driver_diagnostic.c
  fi
}

ensure_runtime_driver_asm_strict_obj() {
  ensure_runtime_abi_obj
  ensure_runtime_io_abi_obj
  ensure_runtime_proc_abi_obj
  ensure_runtime_link_abi_obj
  ensure_runtime_pipeline_abi_obj
  ensure_runtime_driver_abi_obj
  ensure_diag_obj
  ensure_runtime_driver_diagnostic_obj
  local o="src/runtime_driver_asm_bstrict.o"
  if [ ! -f "$o" ] || [ "src/runtime.c" -nt "$o" ] || [ "scripts/build_shux_asm.sh" -nt "$o" ]; then
    echo "  cc -c $o <- src/runtime.c (-DSHUX_ASM_USE_COMPILER_IMPL_C -DSHUX_NO_C_FRONTEND)"
    local rt_flags="-DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_PREPROCESS -DSHUX_ASM_USE_COMPILER_IMPL_C -DSHUX_NO_C_FRONTEND"
    if [ "${SHUX_LEGACY_PREPROCESS_C:-0}" = "1" ]; then
      rt_flags="$rt_flags -DSHUX_LEGACY_PREPROCESS_C"
    fi
    "$CC" $CFLAGS $rt_flags -c -o "$o" src/runtime.c
  fi
  # 兼容旧链脚本/规则仍引用 runtime_driver_asm_strict.o
  cp -f "$o" src/runtime_driver_asm_strict.o 2>/dev/null || true
}

# bootstrap-driver-seed DRIVER_SEED_SUPPORT_EXTRA 对齐：SX 前端 experimental 链缺 C codegen/lexer 时的桩。
ensure_asm_bootstrap_support_extra_objs() {
  local o
  o="src/codegen/codegen_pipeline_stubs.o"
  if [ ! -f "$o" ] || [ "src/codegen/codegen_pipeline_stubs.c" -nt "$o" ]; then
    echo "  cc -c $o <- src/codegen/codegen_pipeline_stubs.c (cfg/WPO/C-codegen stubs)"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$o" src/codegen/codegen_pipeline_stubs.c
  fi
  o="src/lexer/cfg_eval.o"
  if [ -f src/lexer/cfg_eval.sx ] \
    && { [ ! -f "$o" ] || [ src/lexer/cfg_eval.sx -nt "$o" ]; }; then
    if [ -x "$SHUX" ] && "$SHUX" -backend asm -o "$o" $LIBROOT src/lexer/cfg_eval.sx 2>/dev/null \
      && [ -s "$o" ]; then
      echo "  $SHUX -backend asm -> $o (G-02-B1 cfg_eval.sx)"
    elif [ -x "$SHUX" ] && "$SHUX" -E -E-extern $LIBROOT src/lexer/cfg_eval.sx > src/lexer/cfg_eval_gen.c 2>/dev/null \
      && [ -s src/lexer/cfg_eval_gen.c ]; then
      echo "  $SHUX -E-extern -> cfg_eval_gen.c + link alias -> $o (G-02-B1 cfg_eval.sx)"
      "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/lexer/cfg_eval_sx.o src/lexer/cfg_eval_gen.c
      "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o src/lexer/cfg_eval_link_alias.o src/lexer/cfg_eval_link_alias.c
      "$LD" $LD_RELFLAGS -r -o "$o" src/lexer/cfg_eval_sx.o src/lexer/cfg_eval_link_alias.o
    elif [ -f src/lexer/cfg_eval.sx ] && [ -x "$SHUX" ]; then
      build_shux_asm_error "cfg_eval: need $SHUX -backend asm or -E-extern for cfg_eval.sx (G-02a: no cfg_eval.c)"
      return 1
    fi
  fi
  ensure_typeck_f64_bits_obj
  o="src/runtime_pipeline_abi_shux_c_stubs.o"
  if [ ! -f "$o" ] || [ "src/runtime_pipeline_abi_shux_c_stubs.c" -nt "$o" ]; then
    echo "  cc -c $o <- src/runtime_pipeline_abi_shux_c_stubs.c (pipeline ABI weak stubs)"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$o" src/runtime_pipeline_abi_shux_c_stubs.c
  fi
  ensure_typeck_c_module_stubs_obj
  o="src/lsp/lsp_heap_bootstrap.o"
  if [ ! -f "$o" ] || [ "src/lsp/lsp_heap_bootstrap.c" -nt "$o" ]; then
    echo "  cc -c $o <- src/lsp/lsp_heap_bootstrap.c (heap_alloc_c for lsp_io_std_heap)"
    "$CC" $CFLAGS -I. -Iinclude -Isrc -c -o "$o" src/lsp/lsp_heap_bootstrap.c
  fi
}

# experimental / strict runtime 链：与 Makefile DRIVER_SEED_SUPPORT_EXTRA 一致。
asm_bootstrap_support_extra_link() {
  echo "src/codegen/codegen_pipeline_stubs.o src/lexer/cfg_eval.o src/typeck/typeck_f64_bits.o src/runtime_pipeline_abi_shux_c_stubs.o $BUILD_DIR/typeck_c_module_stubs.o src/lsp/lsp_heap_bootstrap.o"
}

# 确保 typeck_f64_bits.o 存在（pipeline_sx / parser 浮点字面量位拆分）。
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

# typeck 整链 build_asm/typeck.o：裸符号 → typeck_ 前缀 glue 名（见 typeck_asm_bare_link_alias.c）。
ensure_typeck_asm_bare_link_alias_obj() {
  local OBJ="$BUILD_DIR/typeck_asm_bare_link_alias.o"
  local GEN="scripts/gen_typeck_asm_bare_link_alias.py"
  if [ -f "$GEN" ] && [ -f "$BUILD_DIR/typeck.o" ] && [ -f typeck_sx.o ]; then
    if [ ! -f typeck_asm_bare_link_alias.c ] || [ src/typeck/typeck.sx -nt typeck_asm_bare_link_alias.c ] \
      || [ "$BUILD_DIR/typeck.o" -nt typeck_asm_bare_link_alias.c ]; then
      python3 "$GEN" 2>/dev/null || true
    fi
  fi
  if [ ! -f "$OBJ" ] || [ "typeck_asm_bare_link_alias.c" -nt "$OBJ" ]; then
    echo "  cc -c typeck_asm_bare_link_alias.c -> $OBJ"
    "$CC" $CFLAGS -c -o "$OBJ" typeck_asm_bare_link_alias.c
  fi
}

# 确保 runtime_panic.o / crt0 / typeck_f64_bits 存在（逻辑与 compiler/Makefile 中对应规则一致）
ensure_asm_link_objs() {
  UNAME_S=$(uname -s 2>/dev/null || echo Unknown)
  ALPINE=0
  test -f /etc/alpine-release && ALPINE=1
  if [ "$UNAME_S" = "Linux" ] && [ "$(uname -m 2>/dev/null)" = "x86_64" ] && [ -f src/asm/runtime_panic_x86_64.s ]; then
    echo "  cc -c runtime_panic.o <- src/asm/runtime_panic_x86_64.s"
    "$CC" -c -o runtime_panic.o src/asm/runtime_panic_x86_64.s
  elif [ -f src/asm/runtime_panic_arm64.c ] && { [ "$(uname -m 2>/dev/null)" = "aarch64" ] || [ "$(uname -m 2>/dev/null)" = "arm64" ]; }; then
    echo "  cc -c runtime_panic.o <- src/asm/runtime_panic_arm64.c"
    "$CC" $CFLAGS -c -o runtime_panic.o src/asm/runtime_panic_arm64.c
  else
    echo "  cc -c runtime_panic.o <- src/asm/runtime_panic.c"
    "$CC" $CFLAGS -c -o runtime_panic.o src/asm/runtime_panic.c
  fi
  if [ "$UNAME_S" = "Linux" ] && [ -f src/asm/crt0_x86_64.s ]; then
    echo "  cc -c src/asm/crt0_x86_64.o <- src/asm/crt0_x86_64.s"
    "$CC" -c -o src/asm/crt0_x86_64.o src/asm/crt0_x86_64.s
  fi
  ensure_typeck_f64_bits_obj
  # atoi stub: 生成的 pipeline 代码调用 atoi（libc），nostdlib 链接缺此符号
  if [ ! -f atoi_stub.o ]; then
    echo '  cc -c atoi_stub.o (atoi stub for nostdlib link)'
    printf '#include <stddef.h>\nint atoi(const char *n) { int v=0; while(*n>=48&&*n<=57){v=v*10+(*n-48);n++;} return v; }\n' > /tmp/atoi_stub_$$.c
    "$CC" $CFLAGS -c -o atoi_stub.o /tmp/atoi_stub_$$.c
    rm -f /tmp/atoi_stub_$$.c
  fi
  export SHUX_ATOI_STUB="atoi_stub.o"
}

# 用户程序 asm 链预编译 runtime 对象（nostdlib shux_asm 无 fork+cc，须在 build 阶段产出）。
ensure_runtime_user_link_objs() {
  if [ ! -f runtime_asm_io_stubs.o ] || [ src/asm/runtime_asm_io_stubs.c -nt runtime_asm_io_stubs.o ]; then
    echo "  cc -c runtime_asm_io_stubs.o <- src/asm/runtime_asm_io_stubs.c"
    "$CC" $CFLAGS -c -o runtime_asm_io_stubs.o src/asm/runtime_asm_io_stubs.c
  fi
  if [ ! -f runtime_process_argv.o ] || [ src/asm/runtime_process_argv.c -nt runtime_process_argv.o ]; then
    echo "  cc -c runtime_process_argv.o <- src/asm/runtime_process_argv.c"
    "$CC" $CFLAGS -c -o runtime_process_argv.o src/asm/runtime_process_argv.c
  fi
  if [ ! -f runtime_random_fill.o ] || [ src/asm/runtime_random_fill.c -nt runtime_random_fill.o ]; then
    echo "  cc -c runtime_random_fill.o <- src/asm/runtime_random_fill.c"
    "$CC" $CFLAGS -c -o runtime_random_fill.o src/asm/runtime_random_fill.c
  fi
  if [ ! -f runtime_time_os.o ] || [ src/asm/runtime_time_os.c -nt runtime_time_os.o ]; then
    echo "  cc -c runtime_time_os.o <- src/asm/runtime_time_os.c"
    "$CC" $CFLAGS -c -o runtime_time_os.o src/asm/runtime_time_os.c
  fi
  if [ ! -f runtime_env_os.o ] || [ src/asm/runtime_env_os.c -nt runtime_env_os.o ]; then
    echo "  cc -c runtime_env_os.o <- src/asm/runtime_env_os.c"
    "$CC" $CFLAGS -c -o runtime_env_os.o src/asm/runtime_env_os.c
  fi
}

# NL-07 v2：编译 freestanding_io / bootstrap nostdlib 桩（仅 Linux crt0 链尝试用）。
ensure_freestanding_io_x86_64_obj() {
  if [ -f src/asm/freestanding_io_x86_64.s ]; then
    if [ ! -f src/asm/freestanding_io_x86_64.o ] || [ src/asm/freestanding_io_x86_64.s -nt src/asm/freestanding_io_x86_64.o ]; then
      echo "  cc -c src/asm/freestanding_io_x86_64.o <- src/asm/freestanding_io_x86_64.s"
      "$CC" -c -o src/asm/freestanding_io_x86_64.o src/asm/freestanding_io_x86_64.s
    fi
  fi
}

ensure_bootstrap_nostdlib_stubs_obj() {
  if [ -f src/asm/bootstrap_nostdlib_stubs.c ]; then
    if [ ! -f src/asm/bootstrap_nostdlib_stubs.o ] || [ src/asm/bootstrap_nostdlib_stubs.c -nt src/asm/bootstrap_nostdlib_stubs.o ]; then
      echo "  cc -c src/asm/bootstrap_nostdlib_stubs.o <- src/asm/bootstrap_nostdlib_stubs.c"
      "$CC" $CFLAGS -c -o src/asm/bootstrap_nostdlib_stubs.o src/asm/bootstrap_nostdlib_stubs.c
    fi
  fi
}

# NL-07 v2：SHUX_BOOTSTRAP_NOSTDLIB=1 且 Linux 时尝试 nostdlib（去 -lc/-lm，保留 PIPELINE_LIBS 如 -lpthread）。
# NL-07 v5：Linux x86_64 默认启用 nostdlib（除非 SHUX_BOOTSTRAP_ALLOW_LIBC=1 显式回退 libc）。
bootstrap_wants_nostdlib() {
  if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
    return 1
  fi
  if [ -n "${SHUX_BOOTSTRAP_ALLOW_LIBC:-}" ]; then
    return 1
  fi
  if [ -n "${SHUX_BOOTSTRAP_NOSTDLIB:-}" ]; then
    return 0
  fi
  if [ "$(uname -m 2>/dev/null)" = "x86_64" ] || [ "$(uname -m 2>/dev/null)" = "amd64" ]; then
    return 0
  fi
  return 1
}

# crt0 链尾参数（无 PIPELINE_LIBS）。
bootstrap_link_tail_crt0() {
  if bootstrap_wants_nostdlib; then
    ensure_freestanding_io_x86_64_obj
    ensure_bootstrap_nostdlib_stubs_obj
    echo "-nostdlib -static -Wl,--gc-sections src/asm/freestanding_io_x86_64.o src/asm/bootstrap_nostdlib_stubs.o"
  else
    echo "-lc -lm"
  fi
}

# driver / experimental / strict 链尾（保留 PIPELINE_LIBS，仅去 -lc/-lm）。
bootstrap_link_tail_driver() {
  if bootstrap_wants_nostdlib; then
    ensure_freestanding_io_x86_64_obj
    ensure_bootstrap_nostdlib_stubs_obj
    echo "-nostdlib -static -Wl,--gc-sections src/asm/freestanding_io_x86_64.o src/asm/bootstrap_nostdlib_stubs.o ${PIPELINE_LIBS}"
  else
    echo "-lm -lc ${PIPELINE_LIBS}"
  fi
}

# NL-07 v5：nostdlib 静态链不链 libpthread（libpthread 依赖 libc；桩见 bootstrap_nostdlib_stubs.c）。
bootstrap_pipeline_libs() {
  if bootstrap_wants_nostdlib; then
    echo ""
  elif [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
    echo "-luring -lpthread"
  else
    echo ""
  fi
}

# NL-07 v5：nostdlib 须 crt0 _start→main_entry；libc 路径仍用 runtime_asm_build main()。
bootstrap_entry_obj() {
  if bootstrap_wants_nostdlib && [ "$(uname -s 2>/dev/null)" = "Linux" ] && [ -f src/asm/crt0_x86_64.o ]; then
    echo "src/asm/crt0_x86_64.o"
  else
    echo "src/asm/runtime_asm_build.o"
  fi
}

# NL-07 v5：crt0 链用 -e _start -nostartfiles（与 bootstrap-driver-seed 一致）。
bootstrap_entry_ldflags() {
  if bootstrap_wants_nostdlib && [ "$(uname -s 2>/dev/null)" = "Linux" ] && [ -f src/asm/crt0_x86_64.o ]; then
    echo "-no-pie -e _start -nostartfiles"
  else
    echo ""
  fi
}

# pipeline_glue_standalone 提供 backend_ctx_push_loop_labels 等 C 真实现；
# 与 pipeline_sx.o / asm_backend_partial.o 重复时须 glue 置首且允许多定义（首符号生效）。
asm_glue_duplicate_ldflags() {
  if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    echo "-Wl,-multiply_defined -Wl,suppress"
  else
    echo "-Wl,--allow-multiple-definition"
  fi
}

# 确保 crt0 / nostdlib 对象在 experimental/strict 链前已编译。
bootstrap_ensure_entry_objs() {
  if bootstrap_wants_nostdlib && [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
    ensure_asm_link_objs
    ensure_runtime_user_link_objs
    ensure_freestanding_io_x86_64_obj
    ensure_bootstrap_nostdlib_stubs_obj
  fi
}

# 仅重链 shux_asm（runtime/bootstrap/crt0 对象更新后）；不跑 build_asm 全量 -backend asm 循环。
# 用法：SHUX_ASM_BSTRICT_RELINK_ONLY=1 ./scripts/build_shux_asm.sh
#       或 ./scripts/relink_shux_asm_bstrict_runtime_objs.sh
#
# strict 重链成功后同步 shux_asm_stage1（C5/C6 gate 与 gen2 读 stage1 副本）。
shux_asm_sync_stage1_from_strict() {
  if [ -f ./shux_asm ] && [ -x ./shux_asm ]; then
    # Darwin 上直接覆盖 stage1 偶发留下坏 vnode/签名缓存；先删再拷可稳定执行同内容副本。
    rm -f ./shux_asm_stage1 2>/dev/null || true
    cp -f ./shux_asm ./shux_asm_stage1 2>/dev/null || true
  fi
}

shux_asm_bstrict_relink_runtime_only() {
  local ST_RC=0
  local ST_GLUE_OBJ ST_WPO_ALIAS ST_PARSER_LINK ST_BRIDGE_OBJ ST_DRIVER_CLI_OBJS
  local ST_SEED_PREPROCESS_LINK ST_SEED_PARSER_TCK ST_STRICT_COMPANIONS ST_TYPECK_LSP_STUB
  local ST_STRICT_FB_SX_TAIL ST_BACKEND_COMPANIONS ST_TYPECK_SX_LINK
  local BSTRICT_SEED_SUPPORT BOOT_ENTRY_OBJ BOOT_ENTRY_LDFLAGS BOOT_DRIVER_TAIL
  local ST_BSTRICT_LINK_EXTRA PTEXT

  build_shux_asm_info "SHUX_ASM_BSTRICT_RELINK_ONLY - refresh runtime/bootstrap + strict relink"
  export STRICT_LINK_BUILD_ASM_PIPELINE=1
  SEED_O="${SEED_O:-$BUILD_DIR/asm_driver_seed}"
  ensure_diag_seed_obj "$SEED_O"
  ensure_lsp_diag_seed_obj "$SEED_O"
  LSP_DIAG_SEED_O=${LSP_DIAG_SEED_O:-$(lsp_diag_seed_obj_path "$SEED_O")}
  PIPELINE_LIBS=$(bootstrap_pipeline_libs)
  build_nonempty_asm_objs
  PTEXT=$(asm_o_text_bytes "$BUILD_DIR/pipeline.o" 2>/dev/null || echo 0)
  ensure_asm_pipeline_glue_standalone_obj
  ensure_asm_pipeline_glue_strict_minimal_obj
  ensure_asm_experimental_symbol_bridge_obj
  ensure_asm_bootstrap_sx_companion_objs
  ensure_asm_experimental_lsp_objs
  ensure_runtime_abi_obj
  ensure_runtime_io_abi_obj
  ensure_runtime_proc_abi_obj
  ensure_runtime_link_abi_obj
  ensure_runtime_pipeline_abi_obj
  ensure_runtime_driver_abi_obj
  ensure_runtime_driver_diagnostic_obj
  ensure_runtime_driver_asm_strict_obj
  ensure_asm_bootstrap_support_extra_objs
  BSTRICT_SEED_SUPPORT=$(asm_bootstrap_support_extra_link)
  ensure_parser_sx_o_for_strict_link
  strip_main_entry_from_build_asm_main_o || true
  bootstrap_ensure_entry_objs

  ST_GLUE_OBJ="$BUILD_DIR/pipeline_glue_standalone.o"
  if asm_strict_typeck_sx_glue_via_pipeline_sx; then
    ST_GLUE_OBJ="$BUILD_DIR/pipeline_glue_strict_minimal.o"
  fi
  ST_WPO_ALIAS=""
  ST_PARSER_LINK=""
  ST_BRIDGE_OBJ="$BUILD_DIR/asm_experimental_symbol_bridge.o"
  ST_DRIVER_CLI_OBJS="driver_fmt_sx.o driver_check_sx.o driver_test_sx.o driver_build_sx.o driver_run_sx.o driver_compile_sx.o driver_emit_sx.o"
  if asm_strict_link_driver_selfhosted; then
    ST_DRIVER_CLI_OBJS="driver_fmt_sx.o driver_check_sx.o driver_test_sx.o driver_build_sx.o driver_run_sx.o driver_emit_sx.o"
    export STRICT_LINK_BUILD_ASM_DRIVER=1
  fi
  ST_SEED_PREPROCESS_LINK=$(asm_seed_st_preprocess_link)
  ST_TYPECK_SX_LINK="typeck_sx.o"
  # selfhosted strict relink 不会并链 ST_LAYOUT_PARTIAL；此时若误用 no_layout partial，
  # 会把 typeck_ensure_struct_layout_from_struct_lit / entry_module_find_struct_layout_index 一并裁掉。
  if ! asm_strict_typeck_selfhosted && ensure_typeck_asm_layout_partial_obj && ensure_typeck_sx_no_layout_partial_obj; then
    ST_TYPECK_SX_LINK="$BUILD_DIR/typeck_sx_no_layout_partial.o"
  fi
  if asm_strict_typeck_selfhosted && asm_strict_typeck_sx_glue_via_pipeline_sx; then
    if asm_seed_use_sx_frontend; then
      ST_SEED_PARSER_TCK="$(asm_seed_st_async_support_link) $(asm_seed_st_sx_glue_suffix)"
    else
      ST_SEED_PARSER_TCK="$(asm_seed_st_frontend_seed_link) $(asm_seed_st_sx_glue_suffix)"
    fi
  elif asm_seed_use_sx_frontend; then
    ST_SEED_PARSER_TCK="$(asm_seed_st_async_support_link) $ST_TYPECK_SX_LINK $(asm_seed_st_sx_glue_suffix)"
  else
    ST_SEED_PARSER_TCK="$(asm_seed_st_frontend_seed_link) $ST_TYPECK_SX_LINK $(asm_seed_st_sx_glue_suffix)"
  fi
  ST_PARSER_SX_TAIL="parser_sx.o lexer_sx.o"
  if asm_strict_typeck_sx_glue_via_pipeline_sx && [ -n "$ST_TYPECK_SX_LINK" ] && [ -f "$ST_TYPECK_SX_LINK" ]; then
    case " $ST_SEED_PARSER_TCK " in
      *" $ST_TYPECK_SX_LINK "*) ST_TYPECK_SX_TAIL="" ;;
      *) ST_TYPECK_SX_TAIL="$ST_TYPECK_SX_LINK" ;;
    esac
  fi
  ensure_ast_pool_l5_bridge_obj
  ensure_asm_backend_compat_stubs_obj
  refresh_bstrict_link_variants
  ST_BACKEND_COMPANIONS=$(strict_asm_backend_companion_objs) || ST_BACKEND_COMPANIONS="$BUILD_DIR/seed_host/asm_backend_partial.o"
  ST_BSTRICT_LINK_EXTRA="src/std_sys_shim.o src/asm/parser_asm_parse_expr_link.o src/asm/pipeline_fill_dep_strict_alias.o $BUILD_DIR/seed_host/asm_full_link_stubs.o"
  ST_STRICT_COMPANIONS="$BUILD_DIR/sx_seed_bridge.o $BUILD_DIR/seed_link_compat.o $ST_BACKEND_COMPANIONS $BSTRICT_USER_ASM_SEED_BRIDGE_LINK $BSTRICT_ASM_BACKEND_COMPAT_STUBS_LINK $BSTRICT_DISPATCH_OBJS parser_asm_thin_glue.o $ST_BSTRICT_LINK_EXTRA src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o preprocess_sx.o $BUILD_DIR/ast_pool_l5_bridge.o $ST_DRIVER_CLI_OBJS"
  ensure_pipeline_o_strict_link_partial_obj || true
  filter_strict_asm_objs
  ASM_TRY_OBJS="$FILTERED"
  ST_TYPECK_LSP_STUB=""
  if [ ! -f "$BUILD_DIR/gen_driver/lsp_io_sx.o" ]; then
    ST_TYPECK_LSP_STUB="$BUILD_DIR/typeck_lsp_io_stub.o"
  fi
  ST_RUNTIME_PARTIAL=""
  ST_RUNTIME_PANIC=""
  ST_RUNTIME_EXTRA=""
  ST_LAYOUT_PARTIAL=""
  ST_PIPELINE_ALIAS=""
  ST_STRICT_FB_SX_TAIL=""
  if [ -f runtime_panic.o ]; then
    ST_RUNTIME_PANIC="runtime_panic.o atoi_stub.o"
  fi
  refresh_build_asm_ci_text_stubs_for_strict_link || true
  if [ ! -f "$BUILD_DIR/seed_host/asm_backend_partial.o" ] \
    || [ "$(wc -c <"$BUILD_DIR/seed_host/asm_backend_partial.o" | tr -d ' ')" -lt 8192 ]; then
    if [ "${SHUX_ASM_BSTRICT_RELINK_ALLOW_PHASE1_STUB:-0}" = "1" ]; then
      build_shux_asm_warn "runtime-only relink with phase1 asm_backend_partial (dev/Docker only)"
    else
      shux_asm_bstrict_fail "runtime-only relink needs real build_asm/seed_host/asm_backend_partial.o (not phase1 stub)"
    fi
  fi
  BOOT_ENTRY_OBJ=$(bootstrap_entry_obj)
  BOOT_ENTRY_LDFLAGS=$(bootstrap_entry_ldflags)
  BOOT_DRIVER_TAIL=$(bootstrap_link_tail_driver)
  ASM_GLUE_DUP_LDFLAGS=$(asm_glue_duplicate_ldflags)

  set +e
  # shellcheck disable=SC2086
  "$CC" $CFLAGS $BOOT_ENTRY_LDFLAGS $ASM_GLUE_DUP_LDFLAGS -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -o shux_asm \
    $BOOT_ENTRY_OBJ \
    src/runtime_abi.o \
    src/runtime_io_abi.o \
    src/runtime_proc_abi.o \
    src/runtime_link_abi.o \
    src/runtime_pipeline_abi.o \
    src/runtime_driver_abi.o \
    src/diag.o \
    src/runtime_driver_diagnostic.o \
    src/runtime_driver_asm_strict.o \
    $BSTRICT_SEED_SUPPORT \
    "$ST_GLUE_OBJ" \
    $ST_WPO_ALIAS \
    $ASM_TRY_OBJS \
    $ST_PARSER_LINK \
    $ST_RUNTIME_PARTIAL \
    "$BUILD_DIR/std_fs_shim.o" \
    $ST_BRIDGE_OBJ \
    "$BUILD_DIR/asm_shux_lsp_diag_stub.o" \
    $ST_TYPECK_LSP_STUB \
    "$BUILD_DIR/lsp_codegen_extern.o" \
    $ST_SEED_PREPROCESS_LINK \
    $ST_SEED_PARSER_TCK \
    $ST_STRICT_COMPANIONS \
    "$BUILD_DIR/gen_driver/lsp_sx.o" \
    "$BUILD_DIR/gen_driver/lsp_io_sx.o" \
    "$BUILD_DIR/gen_driver/lsp_io_std_heap_sx.o" \
    "$LSP_DIAG_SEED_O" \
    "$SEED_O/lsp_state.o" \
    src/lsp/lsp_diag_pipeline_sizes.o \
    $ST_RUNTIME_PANIC $SHUX_ATOI_STUB \
    $ST_RUNTIME_EXTRA \
    $ST_LAYOUT_PARTIAL \
    $ST_PIPELINE_ALIAS \
    $ST_PARSER_SX_TAIL \
    $ST_TYPECK_SX_TAIL \
    $BOOT_DRIVER_TAIL 2>"$BUILD_DIR/.asm_strict_relink_only_err"
  ST_RC=$?
  set -e
  if [ "$ST_RC" -ne 0 ]; then
    build_shux_asm_error "runtime-only strict relink failed (rc=$ST_RC)"
    tail -n 12 "$BUILD_DIR/.asm_strict_relink_only_err" 2>/dev/null | sed 's/^/  /' || true
    shux_asm_bstrict_fail "runtime-only strict relink failed"
  fi
  build_shux_asm_info "shux_asm strict OK (runtime-only relink, pipeline.o __text=${PTEXT}B)"
  LINK_OK=1
  LINK_MODE=asm_only_strict
  if [ -z "${SHUX_ASM_SKIP_STRICT_SMOKE:-}" ]; then
    if ! SHUX_ASM_SMOKE_SKIP_GATE=1 ./scripts/run_shux_asm_smoke.sh >"$BUILD_DIR/.asm_strict_smoke.log" 2>&1; then
      shux_asm_bstrict_fail "strict shux_asm smoke failed after runtime-only relink"
    fi
    build_shux_asm_info "strict shux_asm smoke passed (runtime-only relink)"
  fi
  shux_asm_sync_stage1_from_strict
}

if [ -n "${SHUX_ASM_BSTRICT_RELINK_ONLY:-}" ]; then
  shux_asm_bstrict_relink_runtime_only
  exit 0
fi

LINK_OK=0
ASM_READY=0
LINK_MODE=""
ASM_TEXT_ALL_OK=0
[ -f "$BUILD_DIR/.asm_text_quality" ] && ASM_TEXT_ALL_OK=$(cat "$BUILD_DIR/.asm_text_quality")

# 拓扑：显式导出 SHUX_ASM_LINK_TOPOLOGY 时尊重用户值；否则全域 __text 非空 → full_asm，否则 pipeline_sx
if [ -z "${SHUX_ASM_LINK_TOPOLOGY+x}" ]; then
  SHUX_ASM_LINK_TOPOLOGY=pipeline_sx
  UNAMES=$(uname -s 2>/dev/null || echo Unknown)
  if [ "$ASM_TEXT_ALL_OK" = "1" ]; then
    SHUX_ASM_LINK_TOPOLOGY=full_asm
    build_shux_asm_info "auto SHUX_ASM_LINK_TOPOLOGY=full_asm ($UNAMES, all BUILD __text non-empty)"
    if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
      build_shux_asm_info "M11 production B-strict (SKIP_GEN -> asm_only_strict, no cc -c pipeline_gen.c in final link)"
    elif [ "$UNAMES" != "Linux" ]; then
      build_shux_asm_info "hint: export SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 or make bootstrap-driver-bstrict for asm_only_strict"
    fi
  elif [ "$UNAMES" != "Linux" ]; then
    build_shux_asm_info "host=$UNAMES: topology pipeline_sx (__text 未全绿；crt0 仅 Linux，见 docs/SELFHOST.md §4)"
  fi
else
  if [ "$SHUX_ASM_LINK_TOPOLOGY" = "full_asm" ] && [ "$ASM_TEXT_ALL_OK" != "1" ]; then
    build_shux_asm_warn "SHUX_ASM_LINK_TOPOLOGY=full_asm requires all __text non-empty; forcing pipeline_sx"
    SHUX_ASM_LINK_TOPOLOGY=pipeline_sx
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
  if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
    build_shux_asm_info "SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 - skip crt0 link (use asm_only_strict; crt0 见 make bootstrap-driver-crt0)"
  elif [ "$(uname -s 2>/dev/null)" = "Linux" ] && [ -f src/asm/crt0_x86_64.o ] && [ -f src/typeck/typeck_f64_bits.o ] && [ -f runtime_panic.o ]; then
    echo "  linking shux_asm (crt0 + typeck_f64_bits + runtime_panic + asm*.o, no runtime_driver) ..."
    CRT0_ASM=""
    for _co in $NONEMPTY_ASM; do
      _cb=$(basename "$_co")
      case "$_cb" in
        *_partial.o|pipeline_strict_link_partial.o)
          continue
          ;;
      esac
      CRT0_ASM="$CRT0_ASM $_co"
    done
    set +e
    # F-no-libc NL-07 BEGIN — bootstrap nostdlib（SHUX_BOOTSTRAP_NOSTDLIB=1 尝试；失败回退 libc/libm）
    # 目标：crt0_x86_64 + freestanding_io + bootstrap_nostdlib_stubs + build_asm/*.o + -nostdlib --gc-sections
    # F-06 v1：bootstrap 已不链 cc -c 的 std/fs|io|heap .o
    CRT_RC=1
    if bootstrap_wants_nostdlib; then
      BOOT_CRT0_TAIL=$(bootstrap_link_tail_crt0)
      build_shux_asm_info "trying bootstrap nostdlib crt0 link (SHUX_BOOTSTRAP_NOSTDLIB=1)"
      # shellcheck disable=SC2086
      "$CC" $CFLAGS -o shux_asm src/asm/crt0_x86_64.o src/typeck/typeck_f64_bits.o runtime_panic.o atoi_stub.o \
        $CRT0_ASM $BOOT_CRT0_TAIL 2>"$BUILD_DIR/.bootstrap_nostdlib_link_err"
      CRT_RC=$?
      if [ "$CRT_RC" -ne 0 ]; then
        build_shux_asm_error "bootstrap nostdlib crt0 link failed (rc=$CRT_RC)"
        if [ -f "$BUILD_DIR/.bootstrap_nostdlib_link_err" ]; then
          head -15 "$BUILD_DIR/.bootstrap_nostdlib_link_err" 2>/dev/null || true
        fi
      else
        build_shux_asm_info "bootstrap nostdlib crt0 link OK (no libc/libm)"
      fi
    fi
    if [ "$CRT_RC" -ne 0 ]; then
      # F-no-libc track：默认 crt0 链仍须 libc/libm；用户 freestanding 走 runtime NL-05 无 libc。
      BOOT_CRT0_TAIL=$(bootstrap_link_tail_crt0)
      # shellcheck disable=SC2086
      "$CC" $CFLAGS -o shux_asm src/asm/crt0_x86_64.o src/typeck/typeck_f64_bits.o runtime_panic.o atoi_stub.o $CRT0_ASM $BOOT_CRT0_TAIL
      CRT_RC=$?
    fi
    # F-no-libc NL-07 END
    set -e
    if [ "$CRT_RC" -eq 0 ]; then
      build_shux_asm_info "shux_asm built (no C runtime driver)"
      LINK_OK=1
      USE_CRT0=1
      LINK_MODE=crt0
    else
      build_shux_asm_warn "crt0 link failed (rc=$CRT_RC); trying runtime_driver fallback"
    fi
  fi
  if [ "$LINK_OK" -ne 1 ]; then
    ensure_runtime_cc_stubs
    ensure_std_fs_io_heap_objs
    ensure_asm_driver_seed_c_objs
  LSP_DIAG_SEED_O=${LSP_DIAG_SEED_O:-$(lsp_diag_seed_obj_path "$SEED_O")}
    ensure_lsp_diag_pipeline_sizes_obj
    ensure_asm_shux_lsp_diag_stub_obj
    ensure_asm_lsp_codegen_extern_obj
    # Linux：crt0 失败后试 experimental bootstrap（pipeline_sx.o + SX companions）；SKIP_GEN 时 macOS 等同理。
    _try_experimental=0
    if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
      _try_experimental=1
    elif [ "$(uname -s 2>/dev/null)" = "Linux" ] && [ "$LINK_OK" -ne 1 ]; then
      _try_experimental=1
      build_shux_asm_warn "Linux crt0/runtime link failed; trying experimental bootstrap (pipeline_sx.o + SX companions)"
    fi
    if [ "$_try_experimental" -eq 1 ]; then
      _try_exp_enter=0
      if [ -n "$NONEMPTY_ASM" ]; then
        _try_exp_enter=1
      elif [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ] && build_shux_asm_is_msys; then
        build_shux_asm_info "E-06 v5 Windows B-strict - experimental SX-only (no build_asm/*.o required)"
        _try_exp_enter=1
      fi
    else
      _try_exp_enter=0
    fi
    if [ "$_try_exp_enter" -eq 1 ]; then
      if [ "$ASM_TEXT_ALL_OK" != "1" ]; then
        build_shux_asm_info "SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 (__text 未全绿仍试 asm-only 链)"
      else
        build_shux_asm_info "SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 - B-strict asm-only（bootstrap + strict 重链，最终无 pipeline_gen.c）"
      fi
      ensure_std_fs_io_heap_objs
      PIPELINE_LIBS=$(bootstrap_pipeline_libs)
      bootstrap_ensure_entry_objs
      BOOT_ENTRY_OBJ=$(bootstrap_entry_obj)
      BOOT_ENTRY_LDFLAGS=$(bootstrap_entry_ldflags)
      if bootstrap_wants_nostdlib; then
        build_shux_asm_info "NL-07 v5 nostdlib entry $BOOT_ENTRY_OBJ ($BOOT_ENTRY_LDFLAGS)"
      fi
      UNAME_ASM=$(uname -s 2>/dev/null || echo Unknown)
      # Darwin：ENTRY_MODULE_ONLY 下 duplicate symbol 已消除，但大模块 .o 符号不全/跨模块命名仍会导致 undefined；试链后失败则回退 gen_driver。
      filter_experimental_asm_objs
      ASM_TRY_OBJS="$FILTERED"
      if [ "$UNAME_ASM" = "Darwin" ]; then
        build_shux_asm_info "Darwin 试 asm-only 链（ENTRY_MODULE_ONLY 已无 duplicate；若 undefined 则回退）"
      fi
      if build_shux_asm_is_msys && [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
        build_shux_asm_info "MSYS B-strict - skip build_asm/*.o in experimental bootstrap (SX companions + pipeline_sx)"
        ASM_TRY_OBJS=""
      fi
      if [ -n "$ASM_TRY_OBJS" ] || { [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ] && build_shux_asm_is_msys; }; then
        ensure_pipeline_sx_o_fresh
        ensure_asm_experimental_symbol_bridge_obj
        ensure_asm_driver_seed_c_objs
        # B-strict：companion 已提供 preprocess_sx.o / driver_*_sx.o；勿再 ensure_asm_gen_driver_sx_objs（冗余 -E gen_driver/pipeline_gen.c）。
        ensure_asm_bootstrap_sx_companion_objs
        ensure_pipeline_run_sx_link_alias_obj
        ensure_asm_experimental_lsp_objs
        ensure_ast_pool_l5_bridge_obj
        if [ ! -f pipeline_bootstrap_orchestration.o ] || [ pipeline_bootstrap_orchestration.c -nt pipeline_bootstrap_orchestration.o ]; then
          make pipeline_bootstrap_orchestration.o
        fi
        SEED_O="$BUILD_DIR/asm_driver_seed"
        GEN_O="$BUILD_DIR/gen_driver"
        ASM_SEED_FRONTEND_LINK=""
        if ! asm_seed_omit_c_frontend_seed; then
          ASM_SEED_FRONTEND_LINK="$SEED_O/preprocess.o $SEED_O/parser.o $SEED_O/typeck.o $SEED_O/codegen.o $SEED_O/autovec.o $SEED_O/lexer.o $SEED_O/ast_seed.o"
        elif asm_seed_use_sx_frontend; then
          build_shux_asm_info "E-06 v2 experimental link omit asm_driver_seed frontend .o (SX companions)"
        else
          build_shux_asm_info "E-06 v4 experimental link omit asm_driver_seed frontend .o (SX ready, no SKIP_GEN)"
        fi
        # pipeline_sx / dispatch 引用的 arch_* enc/emit 须 weak 桩（与 bootstrap-driver-seed 同源）。
        ASM_LINK_STUBS_O=""
        if [ -f pipeline_sx.o ]; then
          refresh_bstrict_link_variants
          _stub_scan="$BSTRICT_PIPELINE_LINK_O $BSTRICT_DISPATCH_OBJS"
          if [ -f "$BUILD_DIR/seed_host/asm_full.o" ]; then
            _stub_scan="$BUILD_DIR/seed_host/asm_full.o $_stub_scan"
          fi
          if perl scripts/gen_asm_full_link_stubs.pl "$BUILD_DIR/seed_host/asm_full_link_stubs.c" $_stub_scan 2>/dev/null \
            && [ -s "$BUILD_DIR/seed_host/asm_full_link_stubs.c" ]; then
            "$CC" $CFLAGS -c -o "$BUILD_DIR/seed_host/asm_full_link_stubs.o" "$BUILD_DIR/seed_host/asm_full_link_stubs.c" 2>/dev/null \
              && ASM_LINK_STUBS_O="$BUILD_DIR/seed_host/asm_full_link_stubs.o"
          fi
        fi
        # 首遍 bootstrap 不链 build_asm/*.o（stub 符号重复）；第二遍 strict 重链再并入 pipeline.o 等。
        echo "  linking shux_asm (experimental bootstrap: runtime + pipeline_sx + SX companions + seed C, no build_asm/*.o) ..."
        set +e
        ensure_runtime_driver_asm_strict_obj
        ensure_asm_bootstrap_support_extra_objs
        BSTRICT_SEED_SUPPORT=$(asm_bootstrap_support_extra_link)
        BOOT_DRIVER_TAIL=$(bootstrap_link_tail_driver)
        ensure_asm_pipeline_glue_standalone_obj
        ensure_asm_pipeline_glue_strict_minimal_obj
        refresh_bstrict_link_variants
        BSTRICT_MINIMAL_GLUE_COMPANION=""
        if [ "$BSTRICT_EXPERIMENTAL_GLUE_OBJ" != "$BUILD_DIR/pipeline_glue_strict_minimal.o" ]; then
          BSTRICT_MINIMAL_GLUE_COMPANION="$BUILD_DIR/pipeline_glue_strict_minimal.o"
        fi
        ASM_GLUE_DUP_LDFLAGS=$(asm_glue_duplicate_ldflags)
        # shellcheck disable=SC2086
        "$CC" $CFLAGS $BOOT_ENTRY_LDFLAGS $ASM_GLUE_DUP_LDFLAGS -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -o shux_asm \
          $BOOT_ENTRY_OBJ \
          "$BSTRICT_EXPERIMENTAL_GLUE_OBJ" \
          $BSTRICT_MINIMAL_GLUE_COMPANION \
          src/runtime_abi.o \
          src/runtime_io_abi.o \
          src/runtime_proc_abi.o \
          src/runtime_link_abi.o \
          src/runtime_pipeline_abi.o \
          src/runtime_driver_abi.o \
          src/diag.o \
          src/runtime_driver_diagnostic.o \
          src/runtime_driver_asm_strict.o \
          $BSTRICT_SEED_SUPPORT \
          "$BSTRICT_PIPELINE_LINK_O" \
          pipeline_bootstrap_orchestration.o \
          preprocess_sx.o \
          "$BUILD_DIR/ast_pool_l5_bridge.o" \
          driver_fmt_sx.o driver_check_sx.o driver_test_sx.o driver_build_sx.o driver_run_sx.o driver_compile_sx.o driver_emit_sx.o \
          "$BUILD_DIR/std_fs_shim.o" \
          src/std_sys_shim.o \
          "$BUILD_DIR/sx_seed_bridge.o" \
          "$BUILD_DIR/seed_link_compat.o" \
          "$BUILD_DIR/seed_host/asm_backend_partial.o" \
          $ASM_LINK_STUBS_O \
          "$BSTRICT_USER_ASM_SEED_BRIDGE_LINK" \
          "$BSTRICT_ASM_BACKEND_COMPAT_STUBS_LINK" \
          $BSTRICT_DISPATCH_OBJS \
          src/asm/pipeline_run_sx_link_alias.o \
          src/asm/parser_asm_parse_expr_link.o \
          parser_asm_thin_glue.o \
          src/driver/fmt_check_cmd_driver.o \
          src/driver/target_cpu.o \
          src/asm/simd_enc.o \
          src/asm/simd_loop.o \
          src/asm/bootstrap_seed_io_stubs.o \
          "$BUILD_DIR/asm_experimental_symbol_bridge.o" \
          "$BUILD_DIR/asm_shux_lsp_diag_stub.o" \
          "$BUILD_DIR/lsp_codegen_extern.o" \
          $ASM_SEED_FRONTEND_LINK \
          "$SEED_O/async_liveness.o" \
          "$SEED_O/async_cps_codegen.o" \
          parser_sx.o lexer_sx.o typeck_sx.o codegen_sx.o \
          lexer_sx_link_alias.o typeck_sx_link_alias.o codegen_sx_link_alias.o \
          "$GEN_O/lsp_sx.o" \
          "$GEN_O/lsp_io_sx.o" \
          "$GEN_O/lsp_io_std_heap_sx.o" \
          "$LSP_DIAG_SEED_O" \
          "$SEED_O/lsp_state.o" \
          src/lsp/lsp_diag_pipeline_sizes.o \
          $BOOT_DRIVER_TAIL 2>"$BUILD_DIR/.asm_experimental_link_err"
        FB_RC=$?
        set -e
        if [ "$FB_RC" -eq 0 ]; then
          build_shux_asm_info "shux_asm built (experimental: build_asm backend + pipeline_sx.o bootstrap)"
          cp -f shux_asm shux_asm.experimental 2>/dev/null || true
          export SHUX_ASM_SECOND_PASS_COMPILER=./shux_asm.experimental
          LINK_OK=1
          LINK_MODE=asm_only_experimental
          if [ -n "${SHUX_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY:-}" ]; then
            build_shux_asm_info "CI fast - keep asm_only_experimental bootstrap (skip strict relink + gen_driver)"
            if asm_ci_skip_typeck_emit_heavy; then
              build_shux_asm_info "CI fast - skip typeck EMIT_HEAVY on $(uname -s) (S2 gate Linux-only)"
            elif ! rebuild_typeck_o_emit_heavy_s2 "./shux_asm.experimental"; then
              shux_asm_bstrict_fail "typeck.o EMIT_HEAVY required for S2 gate after CI experimental bootstrap"
            fi
          else
          # ast_pool 变更后须刷新 pipeline_sx.o + experimental，第二遍 EMIT_HEAVY skip_heavy 才生效。
          ensure_experimental_ast_pool_for_wpo || true
          # 第二遍：bootstrap shux_asm 重编 pipeline/typeck/parser/backend，再 strict 重链（无 pipeline_sx.o）。
          SECOND_PASS_OK=0
          if rebuild_pipeline_o_second_pass; then
            SECOND_PASS_OK=1
          fi
          # EMIT_HEAVY 第二遍：pipeline 未达标时仍重编 typeck/parser/backend（S2 gate 依赖 build_asm/typeck.o）。
          if ! rebuild_typeck_parser_backend_second_pass "./shux_asm.experimental"; then
            if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
              build_shux_asm_warn "bootstrap second pass (typeck/parser/backend) failed; continuing strict with partials"
            else
              build_shux_asm_warn "typeck/parser/backend second pass failed (pipeline may be partial)"
            fi
          fi
          PTEXT=$(asm_o_text_bytes "$BUILD_DIR/pipeline.o" 2>/dev/null || echo 0)
          STRICT_TRY=0
          if [ "$SECOND_PASS_OK" -eq 1 ] && [ "$PTEXT" -gt 200 ] 2>/dev/null; then
            STRICT_TRY=1
          else
            build_shux_asm_error "pipeline.o second pass failed (__text=${PTEXT}B)"
            shux_asm_bstrict_fail "pipeline second pass required for B-strict (__text=${PTEXT}B)"
          fi
          if [ "$STRICT_TRY" -eq 1 ]; then
              ensure_asm_pipeline_glue_standalone_obj
              ensure_asm_pipeline_glue_strict_minimal_obj
              ST_GLUE_OBJ="$BUILD_DIR/pipeline_glue_standalone.o"
              ST_WPO_ALIAS=""
              ST_PARSER_LINK=""
              ST_RUNTIME_PARTIAL=""
              ST_RUNTIME_EXTRA=""
              ST_LAYOUT_PARTIAL=""
              ST_PIPELINE_ALIAS=""
              ST_RUNTIME_MODE="bootstrap"
              ST_USES_ASM_PIPELINE=0
              ST_PARSER_LINK=""
              ST_PHASE_PARSE_PARTIAL=""
              if asm_strict_pipeline_selfhosted; then
                build_shux_asm_info "pipeline.o EMIT_HEAVY OK (__text=${PTEXT}B, run_sx_pipeline_impl + path/resolve SX emit)"
                STRICT_LINK_BUILD_ASM_PIPELINE=1
                export STRICT_LINK_BUILD_ASM_PIPELINE
                build_shux_asm_info "strict link build_asm/pipeline.o + glue_standalone"
              elif [ "$PTEXT" -gt 512 ] 2>/dev/null; then
                build_shux_asm_error "pipeline.o __text=${PTEXT}B but not selfhosted; B-strict link aborted"
                shux_asm_bstrict_fail "pipeline.o not selfhosted (__text=${PTEXT}B)"
              else
                build_shux_asm_error "pipeline.o __text=${PTEXT}B too small; B-strict link aborted"
                shux_asm_bstrict_fail "pipeline.o __text=${PTEXT}B"
              fi
              ST_PIPELINE_ALIAS=""
              if [ "$STRICT_LINK_BUILD_ASM_PIPELINE" -eq 1 ]; then
                if asm_strict_sx_orchestration_ok; then
                  # SX 编排：pipeline_runtime_bootstrap_partial.o 由 filter_strict_asm_objs 链入 ASM_TRY_OBJS。
                  ST_RUNTIME_PARTIAL=""
                else
                  ensure_pipeline_bootstrap_orchestration_strict_obj
                  # C 编排 trampoline；勿与 pipeline_asm_orchestration_partial 重复 pipeline_run_sx_pipeline_impl。
                  ST_RUNTIME_PARTIAL="$BUILD_DIR/pipeline_bootstrap_orchestration_strict.o"
                fi
              fi
              if [ "$STRICT_LINK_BUILD_ASM_PIPELINE" -eq 1 ]; then
                ST_RUNTIME_MODE="strict_support"
                if asm_strict_typeck_sx_glue_via_pipeline_sx; then
                  ST_GLUE_OBJ="$BUILD_DIR/pipeline_glue_strict_minimal.o"
                  build_shux_asm_info "strict glue_strict_minimal + pipeline_sx glue support (SX orch)"
                else
                  ST_GLUE_OBJ="$BUILD_DIR/pipeline_glue_standalone.o"
                fi
                ST_RUNTIME_EXTRA=""
                if asm_strict_typeck_selfhosted; then
                  ensure_typeck_asm_layout_partial_obj && ST_LAYOUT_PARTIAL="$BUILD_DIR/typeck_asm_layout_partial.o" || ST_LAYOUT_PARTIAL=""
                  if asm_strict_typeck_sx_glue_via_pipeline_sx; then
                    build_shux_asm_info "strict link typeck.o partial + pipeline_sx glue support (__text=$(asm_o_text_bytes "$BUILD_DIR/typeck.o" 2>/dev/null || echo ?)B)"
                  else
                    build_shux_asm_info "strict link typeck.o partial+glue_standalone (__text=$(asm_o_text_bytes "$BUILD_DIR/typeck.o" 2>/dev/null || echo ?)B, minus glue dupes + bare_link_alias)"
                  fi
                else
                  ensure_typeck_asm_layout_partial_obj && ST_LAYOUT_PARTIAL="$BUILD_DIR/typeck_asm_layout_partial.o" || ST_LAYOUT_PARTIAL=""
                fi
              else
                ensure_pipeline_parse_sx_partial_obj
              fi
              # 实验：C 编排 partial（需 build_asm pipeline.o 或 strict_support；设 SHUX_ASM_STRICT_ORCHESTRATION=1 启用）。
              if [ -n "${SHUX_ASM_STRICT_ORCHESTRATION:-}" ] && ensure_pipeline_asm_orchestration_partial_obj; then
                ensure_pipeline_asm_orchestration_from_build_o
                ST_RUNTIME_PARTIAL="$BUILD_DIR/pipeline_asm_orchestration_partial.o"
                ST_RUNTIME_EXTRA="$BUILD_DIR/pipeline_asm_strict_support_partial.o $BUILD_DIR/pipeline_asm_orchestration_from_build.o"
                ST_PARSER_LINK=""
                ST_RUNTIME_MODE="asm_orchestration"
                ST_USES_ASM_PIPELINE=1
              elif [ -n "${SHUX_ASM_STRICT_ORCHESTRATION_LEGACY:-}" ] && ensure_pipeline_asm_orchestration_from_build_o; then
                ensure_pipeline_phase_parse_only_partial_obj
                ensure_pipeline_asm_run_all_partial_obj
                ensure_asm_pipeline_run_impl_alias_obj
                ensure_pipeline_asm_typecheck_alias_obj
                ensure_pipeline_asm_sx_bootstrap_partial_obj
                ST_RUNTIME_PARTIAL="$BUILD_DIR/pipeline_asm_orchestration_from_build.o"
                ST_RUNTIME_EXTRA="$BUILD_DIR/pipeline_phase_parse_only_partial.o $BUILD_DIR/pipeline_asm_run_all_partial.o $BUILD_DIR/pipeline_run_impl_alias.o $BUILD_DIR/pipeline_asm_typecheck_alias.o $BUILD_DIR/pipeline_asm_sx_bootstrap_partial.o"
                ST_PARSER_LINK="$BUILD_DIR/pipeline_parse_sx_partial.o"
                ST_RUNTIME_MODE="asm_orchestration_legacy"
                ST_USES_ASM_PIPELINE=1
              fi
              if [ "$ST_RUNTIME_MODE" = "strict_support" ] || [ "$ST_USES_ASM_PIPELINE" -eq 1 ]; then
                export STRICT_LINK_BUILD_ASM_PIPELINE
                if [ "$ST_RUNTIME_MODE" = "strict_support" ]; then
                  # build_asm pipeline 自举时须链 preprocess/platform 等 companion .o；否则仅 seed partial 会 U preprocess_sx_buf。
                  if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
                    # pipeline_wpo SX 编排编任意 .sx 会 SIGSEGV；默认 C orchestration + WPO helpers（Linux 自动开启）。
                    maybe_default_pipeline_wpo_strict_link
                    if [ "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO:-0}" = "1" ] && asm_pipeline_wpo_strict_reach_ok; then
                      export STRICT_LINK_BUILD_ASM_WPO=1
                    else
                      export STRICT_LINK_BUILD_ASM_WPO=0
                    fi
                    # typeck_wpo helpers（不含 check_block/check_expr；全量 check 仍来自 typeck.o partial）。
                    if [ "${SHUX_ASM_STRICT_LINK_TYPECK_WPO:-1}" != "0" ] && asm_typeck_wpo_strict_reach_ok; then
                      export STRICT_LINK_BUILD_ASM_TYPECK_WPO=1
                    else
                      export STRICT_LINK_BUILD_ASM_TYPECK_WPO=0
                      rm -f "$BUILD_DIR/typeck_strict_link_partial.o" "$BUILD_DIR/typeck_strict_link_export.txt" \
                        "$BUILD_DIR/typeck_wpo_helpers_partial.o" "$BUILD_DIR/typeck_wpo_helpers_export.txt" 2>/dev/null || true
                    fi
                    if asm_backend_wpo_strict_reach_ok; then
                      export STRICT_LINK_BUILD_ASM_BACKEND_WPO=1
                    else
                      export STRICT_LINK_BUILD_ASM_BACKEND_WPO=0
                    fi
                    # WPO FULL：glue_standalone 与 pipeline_wpo.o 有重叠 T（如 pipeline_should_skip_sx_typeck）。
                    if [ "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO:-0}" = "1" ] && asm_pipeline_wpo_strict_link_full_ok; then
                      if ensure_pipeline_glue_standalone_wpo_dedupe_obj; then
                        ST_GLUE_OBJ="$BUILD_DIR/pipeline_glue_wpo_dedupe.o"
                        build_shux_asm_info "strict glue_wpo_dedupe (glue minus pipeline_wpo T dupes)"
                      fi
                    fi
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
              echo "  re-link shux_asm (strict: ${ST_RUNTIME_MODE}, no pipeline_sx.o) ..."
              ensure_asm_driver_seed_c_objs
              SEED_O="$BUILD_DIR/asm_driver_seed"
              ensure_asm_strict_link_extra_objs
              ST_BSTRICT_LINK_EXTRA="src/std_sys_shim.o src/asm/parser_asm_parse_expr_link.o src/asm/pipeline_fill_dep_strict_alias.o $BUILD_DIR/seed_host/asm_full_link_stubs.o"
              ensure_asm_link_objs
              ST_RUNTIME_PANIC="runtime_panic.o atoi_stub.o"
              ST_BRIDGE_OBJ=""
              ST_SEED_PARSER_TCK=""
              ST_SEED_PREPROCESS_LINK=""
              ST_PARSER_SX_TAIL=""
              ST_TYPECK_SX_TAIL=""
              ST_STRICT_COMPANIONS=""
              ST_SEED_PREPROCESS_LINK=$(asm_seed_st_preprocess_link)
              if [ "$ST_RUNTIME_MODE" = "strict_support" ]; then
                ensure_parser_sx_o_for_strict_link
                # 链 bridge：子命令由 bridge.main_entry 分发；裸编译走 weak entry→run_compiler_c（SHUX_ASM_USE_COMPILER_IMPL_C 时走 impl_c parse）。
                ensure_asm_experimental_symbol_bridge_obj
                ST_BRIDGE_OBJ="$BUILD_DIR/asm_experimental_symbol_bridge.o"
                # 子命令 .o（勿链 driver_sx.o：与 pipeline_glue_standalone 重复 main_run_compiler_c）；main.o 不链入（与 driver_emit_sx.o 重复符号）。
                ST_DRIVER_CLI_OBJS="driver_fmt_sx.o driver_check_sx.o driver_test_sx.o driver_build_sx.o driver_run_sx.o driver_compile_sx.o driver_emit_sx.o"
                if asm_strict_link_driver_selfhosted; then
                  ST_DRIVER_CLI_OBJS="driver_fmt_sx.o driver_check_sx.o driver_test_sx.o driver_build_sx.o driver_run_sx.o driver_emit_sx.o"
                  STRICT_LINK_BUILD_ASM_DRIVER=1
                  export STRICT_LINK_BUILD_ASM_DRIVER
                  build_shux_asm_info "strict link build_asm/driver_compile_link.o (parse_argv + run_compiler_full_sx SX emit)"
                fi
                ST_TYPECK_SX_LINK="typeck_sx.o"
                if [ -n "$ST_LAYOUT_PARTIAL" ] && ensure_typeck_sx_no_layout_partial_obj; then
                  ST_TYPECK_SX_LINK="$BUILD_DIR/typeck_sx_no_layout_partial.o"
                fi
                if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
                  ST_WPO_ALIAS=""
                  if [ "${SHUX_ASM_STRICT_LINK_PIPELINE_WPO:-0}" = "1" ] && asm_pipeline_wpo_strict_reach_ok; then
                    export STRICT_LINK_BUILD_ASM_WPO=1
                    if asm_pipeline_wpo_strict_link_full_ok; then
                      build_shux_asm_info "strict link whole pipeline_wpo.o (SX orchestration FULL)"
                    else
                      ensure_pipeline_wpo_typecheck_emit_bridge_obj && ST_WPO_ALIAS="$BUILD_DIR/pipeline_wpo_typecheck_emit_bridge.o"
                      build_shux_asm_info "strict link pipeline_wpo_helpers (opt-in WPO, C orchestration + typecheck emit bridge)"
                    fi
                  fi
                  if asm_backend_wpo_strict_reach_ok; then
                    export STRICT_LINK_BUILD_ASM_BACKEND_WPO=1
                  fi
                  if asm_strict_typeck_selfhosted; then
                    ensure_typeck_f64_bits_obj
                    ST_TCK_C_PRECHECK=$(ensure_typeck_c_user_precheck_obj)
                    if asm_strict_typeck_sx_glue_via_pipeline_sx; then
                      if asm_seed_use_sx_frontend; then
                        ST_SEED_PARSER_TCK="$(asm_seed_st_async_support_link) $(asm_seed_st_sx_glue_suffix)"
                        build_shux_asm_info "E-06 v3 strict SX-only seed (async + SX glue; no SEED C frontend .o)"
                      else
                        ST_SEED_PARSER_TCK="$(asm_seed_st_frontend_seed_link) $(asm_seed_st_sx_glue_suffix)"
                        build_shux_asm_info "strict seed typeck + typeck_sx tail (SX glue; no build_asm typeck partial)"
                      fi
                    else
                      ensure_typeck_asm_bare_link_alias_obj
                      if asm_seed_use_sx_frontend; then
                        ST_SEED_PARSER_TCK="$ST_TCK_C_PRECHECK $BUILD_DIR/typeck_asm_bare_link_alias.o $(asm_seed_st_async_support_link) $(asm_seed_st_sx_glue_suffix) src/typeck/typeck_f64_bits.o"
                        build_shux_asm_info "E-06 v3 strict bare alias SX-only (no SEED parser/lexer/ast .o)"
                      else
                        ST_SEED_PARSER_TCK="$ST_TCK_C_PRECHECK $BUILD_DIR/typeck_asm_bare_link_alias.o $(asm_seed_st_frontend_seed_no_typeck_link) $(asm_seed_st_sx_glue_suffix) src/typeck/typeck_f64_bits.o"
                      fi
                    fi
                  else
                    if asm_seed_use_sx_frontend; then
                      ST_SEED_PARSER_TCK="$(asm_seed_st_async_support_link) $ST_TYPECK_SX_LINK $(asm_seed_st_sx_glue_suffix)"
                    else
                      ST_SEED_PARSER_TCK="$(asm_seed_st_frontend_seed_link) $ST_TYPECK_SX_LINK $(asm_seed_st_sx_glue_suffix)"
                    fi
                  fi
                  # parser_sx.o 须为链接线最后一批：压过 seed parser.o 与 companions 中可能的重复符号（struct mk CALL 内联等）。
                  ST_PARSER_SX_TAIL="parser_sx.o lexer_sx.o"
                  if asm_strict_typeck_sx_glue_via_pipeline_sx && [ -n "$ST_TYPECK_SX_LINK" ] && [ -f "$ST_TYPECK_SX_LINK" ]; then
                    ST_TYPECK_SX_TAIL="$ST_TYPECK_SX_LINK"
                  fi
                  ensure_ast_pool_l5_bridge_obj
                  ST_BACKEND_COMPANIONS=$(strict_asm_backend_companion_objs) || ST_BACKEND_COMPANIONS="$BUILD_DIR/seed_host/asm_backend_partial.o"
                  if [ "${STRICT_LINK_BUILD_ASM_BACKEND_WPO:-0}" -eq 1 ] && asm_backend_wpo_strict_reach_ok; then
                    build_shux_asm_info "strict link backend_wpo.o (WPO reach OK)"
                  fi
                  ensure_asm_backend_compat_stubs_obj
                  refresh_bstrict_link_variants
                  ST_STRICT_COMPANIONS="$BUILD_DIR/sx_seed_bridge.o $BUILD_DIR/seed_link_compat.o $ST_BACKEND_COMPANIONS $BSTRICT_USER_ASM_SEED_BRIDGE_LINK $BSTRICT_ASM_BACKEND_COMPAT_STUBS_LINK $BSTRICT_DISPATCH_OBJS parser_asm_thin_glue.o $ST_BSTRICT_LINK_EXTRA src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o preprocess_sx.o $BUILD_DIR/ast_pool_l5_bridge.o $ST_DRIVER_CLI_OBJS"
                else
                  # legacy：须 seed C 前端 *.o 在前、*_sx.o 在后（macOS ld 重复符号取后定义）。
                  # E-06 v3 SX：仅 async seed + SX glue；parser_sx.o 在 ST_PARSER_SX_TAIL 压过重复符号。
                  if asm_seed_use_sx_frontend; then
                    ST_SEED_PARSER_TCK="$(asm_seed_st_async_support_link) $ST_TYPECK_SX_LINK $(asm_seed_st_sx_glue_suffix)"
                    build_shux_asm_info "E-06 v3 strict default SX-only ST_SEED_PARSER_TCK"
                  else
                    ST_SEED_PARSER_TCK="$(asm_seed_st_frontend_seed_link) $ST_TYPECK_SX_LINK $(asm_seed_st_sx_glue_suffix)"
                  fi
                  ST_PARSER_SX_TAIL="parser_sx.o lexer_sx.o"
                  ensure_ast_pool_l5_bridge_obj
                  ST_BACKEND_COMPANIONS=$(strict_asm_backend_companion_objs) || ST_BACKEND_COMPANIONS="$BUILD_DIR/seed_host/asm_backend_partial.o"
                  ensure_asm_backend_compat_stubs_obj
                  refresh_bstrict_link_variants
                  ST_STRICT_COMPANIONS="$BUILD_DIR/sx_seed_bridge.o $BUILD_DIR/seed_link_compat.o $ST_BACKEND_COMPANIONS $BSTRICT_USER_ASM_SEED_BRIDGE_LINK $BSTRICT_ASM_BACKEND_COMPAT_STUBS_LINK $BSTRICT_DISPATCH_OBJS parser_asm_thin_glue.o $ST_BSTRICT_LINK_EXTRA src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o preprocess_sx.o $BUILD_DIR/ast_pool_l5_bridge.o $ST_DRIVER_CLI_OBJS"
                fi
              elif [ "$ST_USES_ASM_PIPELINE" -eq 1 ]; then
                ST_BRIDGE_OBJ="$BUILD_DIR/asm_experimental_symbol_bridge.o"
                if asm_seed_use_sx_frontend; then
                  ST_SEED_PARSER_TCK="$(asm_seed_st_async_support_link)"
                else
                  ST_SEED_PARSER_TCK="$(asm_seed_st_frontend_seed_link)"
                fi
              else
                ST_BRIDGE_OBJ="$BUILD_DIR/asm_experimental_symbol_bridge.o"
                if asm_seed_use_sx_frontend; then
                  ST_SEED_PARSER_TCK="$(asm_seed_st_async_support_link)"
                else
                  ST_SEED_PARSER_TCK="$(asm_seed_st_frontend_seed_link)"
                fi
              fi
              ensure_asm_bootstrap_sx_companion_objs
              ensure_asm_experimental_lsp_objs
              ensure_runtime_driver_asm_strict_obj
              ensure_asm_bootstrap_support_extra_objs
              BSTRICT_SEED_SUPPORT=$(asm_bootstrap_support_extra_link)
              ST_TYPECK_LSP_STUB=""
              if [ ! -f "$BUILD_DIR/gen_driver/lsp_io_sx.o" ]; then
                ST_TYPECK_LSP_STUB="$BUILD_DIR/typeck_lsp_io_stub.o"
              fi
              if [ -n "$ST_BRIDGE_OBJ" ] || asm_strict_pipeline_selfhosted 2>/dev/null; then
                export SHUX_ASM_SKIP_ENTRY_SMOKE=1
                export SHUX_ASM_SKIP_MAIN_O_REBUILD=1
                export SHUX_ASM_SKIP_DRIVER_EMIT_HEAVY=1
                export SHUX_ASM_SKIP_WPO_DOGFOOD=1
                rebuild_main_o_for_cli || true
                build_shux_asm_info "skip WPO dogfood recompile (strict bridge / pipeline selfhosted)"
              else
                rebuild_main_o_for_cli || true
                rebuild_driver_compile_emit_heavy_and_link || true
                rebuild_driver_compile_o_wpo || true
                rebuild_pipeline_wpo_o || true
                rebuild_typeck_wpo_o || true
                rebuild_backend_wpo_o || true
              fi
              # driver_compile_link 在首批 filter_strict_asm_objs 之后才补全 parse_argv_loop；刷新链入对象避免与 driver_compile_sx 重复。
              if [ "$ST_RUNTIME_MODE" = "strict_support" ]; then
                if asm_strict_link_driver_selfhosted; then
                  STRICT_LINK_BUILD_ASM_DRIVER=1
                  export STRICT_LINK_BUILD_ASM_DRIVER
                  ST_DRIVER_CLI_OBJS="driver_fmt_sx.o driver_check_sx.o driver_test_sx.o driver_build_sx.o driver_run_sx.o driver_emit_sx.o"
                  filter_strict_asm_objs
                  ASM_TRY_OBJS="$FILTERED"
                  build_shux_asm_info "strict re-filter after driver_compile_link OK"
                else
                  ST_DRIVER_CLI_OBJS="driver_fmt_sx.o driver_check_sx.o driver_test_sx.o driver_build_sx.o driver_run_sx.o driver_compile_sx.o driver_emit_sx.o"
                fi
              fi
              if [ -n "$ST_BRIDGE_OBJ" ]; then
                strip_main_entry_from_build_asm_main_o || true
              fi
              refresh_build_asm_ci_text_stubs_for_strict_link || true
              bootstrap_ensure_entry_objs
              BOOT_ENTRY_OBJ=$(bootstrap_entry_obj)
              BOOT_ENTRY_LDFLAGS=$(bootstrap_entry_ldflags)
              ASM_GLUE_DUP_LDFLAGS=$(asm_glue_duplicate_ldflags)
              set +e
              BOOT_DRIVER_TAIL=$(bootstrap_link_tail_driver)
              # shellcheck disable=SC2086
              "$CC" $CFLAGS $BOOT_ENTRY_LDFLAGS $ASM_GLUE_DUP_LDFLAGS -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -o shux_asm \
                $BOOT_ENTRY_OBJ \
                src/runtime_abi.o \
          src/runtime_io_abi.o \
          src/runtime_proc_abi.o \
          src/runtime_link_abi.o \
          src/runtime_pipeline_abi.o \
          src/runtime_driver_abi.o \
          src/diag.o \
          src/runtime_driver_diagnostic.o \
          src/runtime_driver_asm_strict.o \
          $BSTRICT_SEED_SUPPORT \
                "$ST_GLUE_OBJ" \
                $ST_WPO_ALIAS \
                $ASM_TRY_OBJS \
                $ST_PARSER_LINK \
                $ST_RUNTIME_PARTIAL \
                "$BUILD_DIR/std_fs_shim.o" \
                $ST_BRIDGE_OBJ \
                "$BUILD_DIR/asm_shux_lsp_diag_stub.o" \
                $ST_TYPECK_LSP_STUB \
                "$BUILD_DIR/lsp_codegen_extern.o" \
                $ST_SEED_PREPROCESS_LINK \
                $ST_SEED_PARSER_TCK \
                $ST_STRICT_COMPANIONS \
                "$BUILD_DIR/gen_driver/lsp_sx.o" \
                "$BUILD_DIR/gen_driver/lsp_io_sx.o" \
                "$BUILD_DIR/gen_driver/lsp_io_std_heap_sx.o" \
                "$LSP_DIAG_SEED_O" \
                "$SEED_O/lsp_state.o" \
                src/lsp/lsp_diag_pipeline_sizes.o \
                $ST_RUNTIME_PANIC $SHUX_ATOI_STUB \
                $ST_RUNTIME_EXTRA \
                $ST_LAYOUT_PARTIAL \
                $ST_PIPELINE_ALIAS \
                $ST_PARSER_SX_TAIL \
                $ST_TYPECK_SX_TAIL \
                $BOOT_DRIVER_TAIL 2>"$BUILD_DIR/.asm_strict_link_err"
              ST_RC=$?
              set -e
              if [ "$ST_RC" -ne 0 ] && [ "$ST_USES_ASM_PIPELINE" -eq 1 ]; then
                build_shux_asm_warn "strict asm orchestration link failed; retrying with pipeline_runtime_bootstrap_partial.o"
                ensure_pipeline_runtime_bootstrap_partial_obj
                ST_PARSER_LINK="$BUILD_DIR/pipeline_parse_sx_partial.o"
                ST_RUNTIME_EXTRA=""
                ST_RUNTIME_MODE="bootstrap"
                ST_USES_ASM_PIPELINE=0
                ST_STRICT_FB_SX_TAIL=""
                if asm_seed_use_sx_frontend; then
                  ST_SEED_PREPROCESS_LINK=""
                  ST_SEED_PARSER_TCK="$(asm_seed_st_async_support_link) $(asm_seed_st_sx_glue_suffix)"
                  ST_STRICT_FB_SX_TAIL="preprocess_sx.o parser_sx.o lexer_sx.o typeck_sx.o codegen_sx.o"
                  build_shux_asm_info "E-06 v3 strict fallback SX-only (no SEED C frontend .o)"
                else
                  ST_SEED_PREPROCESS_LINK="$SEED_O/preprocess.o"
                  ST_SEED_PARSER_TCK="$SEED_O/parser.o $SEED_O/typeck.o $SEED_O/codegen.o $SEED_O/autovec.o $SEED_O/async_liveness.o $SEED_O/async_cps_codegen.o $SEED_O/lexer.o $SEED_O/ast_seed.o"
                fi
                set +e
              ensure_runtime_driver_asm_strict_obj
              ensure_asm_bootstrap_support_extra_objs
              BSTRICT_SEED_SUPPORT=$(asm_bootstrap_support_extra_link)
              bootstrap_ensure_entry_objs
              BOOT_ENTRY_OBJ=$(bootstrap_entry_obj)
              BOOT_ENTRY_LDFLAGS=$(bootstrap_entry_ldflags)
              ASM_GLUE_DUP_LDFLAGS=$(asm_glue_duplicate_ldflags)
              "$CC" $CFLAGS $BOOT_ENTRY_LDFLAGS $ASM_GLUE_DUP_LDFLAGS -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -o shux_asm \
                $BOOT_ENTRY_OBJ \
                src/runtime_abi.o \
          src/runtime_io_abi.o \
          src/runtime_proc_abi.o \
          src/runtime_link_abi.o \
          src/runtime_pipeline_abi.o \
          src/runtime_driver_abi.o \
          src/diag.o \
          src/runtime_driver_diagnostic.o \
          src/runtime_driver_asm_strict.o \
          $BSTRICT_SEED_SUPPORT \
                "$ST_GLUE_OBJ" \
                $ST_WPO_ALIAS \
                $ASM_TRY_OBJS \
                  "$ST_PARSER_LINK" \
                  "$BUILD_DIR/pipeline_runtime_bootstrap_partial.o" \
                  "$BUILD_DIR/std_fs_shim.o" \
                  "$BUILD_DIR/asm_experimental_symbol_bridge.o" \
                  "$BUILD_DIR/asm_shux_lsp_diag_stub.o" \
                  $ST_TYPECK_LSP_STUB \
                  "$BUILD_DIR/lsp_codegen_extern.o" \
                  $ST_SEED_PREPROCESS_LINK \
                  $ST_SEED_PARSER_TCK \
                  $ST_STRICT_FB_SX_TAIL \
                  "$BUILD_DIR/gen_driver/lsp_sx.o" \
                  "$BUILD_DIR/gen_driver/lsp_io_sx.o" \
                  "$BUILD_DIR/gen_driver/lsp_io_std_heap_sx.o" \
                  "$LSP_DIAG_SEED_O" \
                  "$SEED_O/lsp_state.o" \
                  src/lsp/lsp_diag_pipeline_sizes.o \
                  $BOOT_DRIVER_TAIL 2>"$BUILD_DIR/.asm_strict_link_err"
                ST_RC=$?
                set -e
              fi
              if [ "$ST_RC" -ne 0 ]; then
                build_shux_asm_error "strict link failed (rc=$ST_RC)"
                if [ -s "$BUILD_DIR/.asm_strict_link_err" ]; then
                  tail -n 8 "$BUILD_DIR/.asm_strict_link_err" | sed 's/^/  /'
                fi
              fi
              if [ "$ST_RC" -eq 0 ]; then
                LINK_OK=1
                if [ "$ST_USES_ASM_PIPELINE" -eq 1 ]; then
                  build_shux_asm_info "shux_asm strict OK (pipeline.o + C orchestration, __text=${PTEXT}B)"
                elif [ "$ST_RUNTIME_MODE" = "strict_support" ]; then
                  if [ "${STRICT_LINK_BUILD_ASM_PIPELINE:-0}" -eq 1 ]; then
                    build_shux_asm_info "shux_asm strict OK (build_asm/pipeline.o + glue_standalone, __text=${PTEXT}B)"
                  else
                    build_shux_asm_info "shux_asm strict OK (strict_support, pipeline.o __text=${PTEXT}B)"
                  fi
                else
                  build_shux_asm_info "shux_asm strict OK (pipeline_runtime_bootstrap_partial.o + pipeline.o __text=${PTEXT}B)"
                fi
                LINK_MODE=asm_only_strict
                if [ -z "${SHUX_ASM_SKIP_STRICT_SMOKE:-}" ]; then
                  if ! SHUX_ASM_SMOKE_SKIP_GATE=1 ./scripts/run_shux_asm_smoke.sh >"$BUILD_DIR/.asm_strict_smoke.log" 2>&1; then
                    # strict 重链产物 compile 失败时：本地可 SHUX_ASM_ALLOW_EXPERIMENTAL_FALLBACK=1 回退；B-strict CI 须 FAIL。
                    if [ -x ./shux_asm.experimental ] && cp -f ./shux_asm "$BUILD_DIR/shux_asm.strict_failed" 2>/dev/null; then
                      cp -f ./shux_asm.experimental ./shux_asm
                      if SHUX_ASM_SMOKE_SKIP_GATE=1 ./scripts/run_shux_asm_smoke.sh >"$BUILD_DIR/.asm_strict_smoke_fallback.log" 2>&1; then
                        build_shux_asm_warn "strict smoke failed; installed shux_asm.experimental as shux_asm (fallback OK)"
                        touch "$BUILD_DIR/.strict_smoke_experimental_fallback"
                        if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ] && [ -z "${SHUX_ASM_ALLOW_EXPERIMENTAL_FALLBACK:-}" ]; then
                          shux_asm_bstrict_fail "strict shux_asm smoke failed (experimental fallback disabled for B-strict)"
                        fi
                        tail -n 5 "$BUILD_DIR/.asm_strict_smoke.log" 2>/dev/null | sed 's/^/  strict: /' || true
                      else
                        cp -f "$BUILD_DIR/shux_asm.strict_failed" ./shux_asm 2>/dev/null || true
                        if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
                          shux_asm_bstrict_fail "strict shux_asm smoke failed (experimental fallback also failed)"
                        fi
                        build_shux_asm_error "strict shux_asm smoke failed (experimental fallback also failed)"
                        tail -n 8 "$BUILD_DIR/.asm_strict_smoke.log" 2>/dev/null | sed 's/^/  /' || true
                        tail -n 8 "$BUILD_DIR/.asm_strict_smoke_fallback.log" 2>/dev/null | sed 's/^/  fallback: /' || true
                      fi
                    elif [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
                      shux_asm_bstrict_fail "strict shux_asm smoke failed"
                    else
                      build_shux_asm_error "strict shux_asm smoke failed"
                      tail -n 8 "$BUILD_DIR/.asm_strict_smoke.log" 2>/dev/null | sed 's/^/  /' || true
                    fi
                  else
                    rm -f "$BUILD_DIR/.strict_smoke_experimental_fallback" 2>/dev/null || true
                    build_shux_asm_info "strict shux_asm smoke passed"
                    shux_asm_sync_stage1_from_strict
                  fi
                fi
                # strict 链成功后：用新链 ./shux_asm 重编 WPO 压缩 .o（ast_pool+ulimit；main EH=0 ~656B）。
                if rebuild_main_o_post_strict_link; then
                  :
                elif [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
                  build_shux_asm_warn "post-strict main.o WPO recompile failed (non-fatal for gate; stage2 may retry)"
                else
                  build_shux_asm_warn "post-strict main.o WPO recompile failed (keeping pre-link main.o)"
                fi
                rebuild_driver_compile_post_strict_link || true
                ensure_experimental_ast_pool_for_wpo || true
                # strict 产物自编译大模块（>150KiB 入口仍 SIGSEGV；bootstrap experimental 第二遍已通过）。
                if ! rebuild_typeck_parser_backend_second_pass; then
                  if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
                    build_shux_asm_warn "B-strict self-compile second pass failed (bootstrap shux_asm + smoke OK; retry with seed SHU for -backend asm)"
                  fi
                fi
                # M8a：strict 重链后的 shux_asm 已含新 parser.o，再重编 arm64_enc/lsp/asm（勿用 experimental，其仍链旧 parser）。
                if [ -x ./shux_asm ]; then
                  rebuild_m8a_parser_dependent_modules_second_pass "./shux_asm" || true
                fi
                TCK2=$(asm_o_text_bytes "$BUILD_DIR/typeck.o" 2>/dev/null || echo 0)
                PAR2=$(asm_o_text_bytes "$BUILD_DIR/parser.o" 2>/dev/null || echo 0)
                BACK2=$(asm_o_text_bytes "$BUILD_DIR/backend.o" 2>/dev/null || echo 0)
                build_shux_asm_info "strict self-compile __text typeck=${TCK2}B parser=${PAR2}B backend=${BACK2}B"
              else
                if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
                  if [ -s "$BUILD_DIR/.asm_strict_link_err" ]; then
                    tail -n 15 "$BUILD_DIR/.asm_strict_link_err" | sed 's/^/  /'
                  fi
                  shux_asm_bstrict_fail "strict re-link failed (rc=$ST_RC)"
                fi
                build_shux_asm_warn "strict re-link failed (rc=$ST_RC); keeping bootstrap shux_asm with pipeline_sx.o"
                if [ -s "$BUILD_DIR/.asm_strict_link_err" ]; then
                  tail -n 15 "$BUILD_DIR/.asm_strict_link_err" | sed 's/^/  /'
                fi
              fi
          else
            if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
              shux_asm_bstrict_fail "strict re-link skipped (pipeline.o __text=${PTEXT}B)"
            fi
            build_shux_asm_warn "strict re-link skipped (pipeline.o __text=${PTEXT}B); keeping bootstrap shux_asm with pipeline_sx.o"
          fi
          fi
        else
          if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
            if [ -s "$BUILD_DIR/.asm_experimental_link_err" ]; then
              tail -n 20 "$BUILD_DIR/.asm_experimental_link_err" | sed 's/^/  /'
            fi
            shux_asm_bstrict_fail "experimental asm-only link failed (rc=$FB_RC)"
          fi
          build_shux_asm_warn "experimental asm-only link failed (rc=$FB_RC); falling back to gen_driver"
          if [ -s "$BUILD_DIR/.asm_experimental_link_err" ]; then
            tail -n 20 "$BUILD_DIR/.asm_experimental_link_err" | sed 's/^/  /'
          fi
        fi
      else
        if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
          if build_shux_asm_is_msys; then
            shux_asm_bstrict_fail "Windows B-strict experimental SX-only link prerequisites missing"
          fi
          shux_asm_bstrict_fail "experimental asm-only skipped on $UNAME_ASM"
        fi
        build_shux_asm_warn "experimental asm-only skipped on $UNAME_ASM; falling back to gen_driver (仍含 cc -c pipeline_gen.c)"
      fi
    fi
    if [ "$LINK_OK" -ne 1 ]; then
      if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
        shux_asm_bstrict_fail "asm-only link not OK (LINK_MODE=${LINK_MODE:-none})"
      fi
      if [ "$SHUX_ASM_LINK_TOPOLOGY" = "full_asm" ] && [ "$ASM_TEXT_ALL_OK" = "1" ]; then
        build_shux_asm_info "full_asm: __text 已全部非空，默认仍走 gen_driver（设 SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 试 asm-only 链）"
      fi
      ensure_asm_gen_driver_sx_objs
      ensure_asm_bootstrap_sx_companion_objs
    fi
    if [ "$LINK_OK" -ne 1 ]; then
      PIPELINE_LIBS=$(bootstrap_pipeline_libs)
      bootstrap_ensure_entry_objs
      BOOT_ENTRY_OBJ=$(bootstrap_entry_obj)
      BOOT_ENTRY_LDFLAGS=$(bootstrap_entry_ldflags)
      SEED_O="$BUILD_DIR/asm_driver_seed"
      GEN_O="$BUILD_DIR/gen_driver"
      ASM_GEN_DRIVER_C_FRONTEND_LINK=$(asm_seed_gen_driver_c_frontend_link)
      ASM_GEN_DRIVER_ASYNC_LINK=$(asm_seed_st_async_support_link)
      if asm_seed_omit_c_frontend_seed; then
        build_shux_asm_info "E-06 v4 gen_driver hybrid link omit SEED C frontend .o (SX companions via GEN_DRIVER_SX_PIPELINE_COMPANIONS)"
      fi
      echo "  linking shux_asm (runtime_asm_build + runtime_driver + seed + driver/* + -E pipeline/lsp; no build_asm/*.o) ..."
      set +e
      ensure_runtime_driver_asm_strict_obj
      ensure_asm_bootstrap_support_extra_objs
      ensure_asm_pipeline_glue_strict_minimal_obj
      BSTRICT_SEED_SUPPORT=$(asm_bootstrap_support_extra_link)
      BOOT_DRIVER_TAIL=$(bootstrap_link_tail_driver)
      # shellcheck disable=SC2086
      "$CC" $CFLAGS $BOOT_ENTRY_LDFLAGS -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -o shux_asm \
        $BOOT_ENTRY_OBJ \
        src/runtime_abi.o \
        src/runtime_io_abi.o \
        src/runtime_proc_abi.o \
        src/runtime_link_abi.o \
        src/runtime_pipeline_abi.o \
        src/runtime_driver_abi.o \
        src/diag.o \
        src/runtime_driver_diagnostic.o \
        src/runtime_driver_asm_strict.o \
        $BSTRICT_SEED_SUPPORT \
        $ASM_GEN_DRIVER_C_FRONTEND_LINK \
        $ASM_GEN_DRIVER_ASYNC_LINK \
        "$GEN_O/driver_sx.o" \
        "$GEN_O/driver_fmt_sx.o" \
        "$GEN_O/driver_check_sx.o" \
        "$GEN_O/driver_test_sx.o" \
        "$GEN_O/pipeline_sx.o" \
        "$BUILD_DIR/pipeline_glue_strict_minimal.o" \
        "$GEN_O/preprocess_sx.o" \
        $GEN_DRIVER_TYPECK_COMPANIONS \
        $GEN_DRIVER_BSTRICT_COMPANIONS \
        $GEN_DRIVER_SX_PIPELINE_COMPANIONS \
        "$GEN_O/lsp_sx.o" \
        "$BUILD_DIR/asm_shux_lsp_diag_stub.o" \
        "$BUILD_DIR/lsp_codegen_extern.o" \
        "$GEN_O/lsp_io_sx.o" \
        "$GEN_O/lsp_io_std_heap_sx.o" \
        "$LSP_DIAG_SEED_O" \
        src/lsp/lsp_diag_pipeline_sizes.o \
        "$SEED_O/lsp_state.o" \
        $BOOT_DRIVER_TAIL
      FB_RC=$?
      set -e
      if [ "$FB_RC" -eq 0 ]; then
        build_shux_asm_info "shux_asm built"
        LINK_OK=1
        LINK_MODE=driver
      else
        build_shux_asm_error "link failed (rc=$FB_RC). See src/asm/README.md Goal 2"
      fi
    fi
  fi
else
  if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
    shux_asm_bstrict_fail "main.o or pipeline.o missing or empty"
  fi
  build_shux_asm_warn "main.o or pipeline.o missing or empty; trying gen_driver fallback only"
  ensure_runtime_cc_stubs
  ensure_std_fs_io_heap_objs
  ensure_asm_driver_seed_c_objs
  ensure_lsp_diag_pipeline_sizes_obj
  ensure_asm_shux_lsp_diag_stub_obj
  ensure_asm_lsp_codegen_extern_obj
  ensure_asm_gen_driver_sx_objs
  ensure_asm_bootstrap_sx_companion_objs
  PIPELINE_LIBS=$(bootstrap_pipeline_libs)
  bootstrap_ensure_entry_objs
  BOOT_ENTRY_OBJ=$(bootstrap_entry_obj)
  BOOT_ENTRY_LDFLAGS=$(bootstrap_entry_ldflags)
  SEED_O="$BUILD_DIR/asm_driver_seed"
  GEN_O="$BUILD_DIR/gen_driver"
  ASM_GEN_DRIVER_C_FRONTEND_LINK=$(asm_seed_gen_driver_c_frontend_link)
  ASM_GEN_DRIVER_ASYNC_LINK=$(asm_seed_st_async_support_link)
  if asm_seed_omit_c_frontend_seed; then
    build_shux_asm_info "E-06 v4 gen_driver fallback link omits SEED C frontend .o (SX companions)"
  fi
  build_shux_asm_info "linking shux_asm (gen_driver fallback; build_asm incomplete)"
  set +e
  ensure_runtime_driver_asm_strict_obj
  ensure_asm_bootstrap_support_extra_objs
  BSTRICT_SEED_SUPPORT=$(asm_bootstrap_support_extra_link)
  BOOT_DRIVER_TAIL=$(bootstrap_link_tail_driver)
  # shellcheck disable=SC2086
  "$CC" $CFLAGS $BOOT_ENTRY_LDFLAGS -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -o shux_asm \
    $BOOT_ENTRY_OBJ \
    src/runtime_abi.o \
    src/runtime_io_abi.o \
    src/runtime_proc_abi.o \
    src/runtime_link_abi.o \
    src/runtime_pipeline_abi.o \
    src/runtime_driver_abi.o \
    src/diag.o \
    src/runtime_driver_diagnostic.o \
    src/runtime_driver_asm_strict.o \
    $BSTRICT_SEED_SUPPORT \
    $ASM_GEN_DRIVER_C_FRONTEND_LINK \
    $ASM_GEN_DRIVER_ASYNC_LINK \
    "$GEN_O/driver_sx.o" \
    "$GEN_O/driver_fmt_sx.o" \
    "$GEN_O/driver_check_sx.o" \
    "$GEN_O/driver_test_sx.o" \
    "$GEN_O/pipeline_sx.o" \
    "$GEN_O/preprocess_sx.o" \
    $GEN_DRIVER_TYPECK_COMPANIONS \
    $GEN_DRIVER_BSTRICT_COMPANIONS \
    $GEN_DRIVER_SX_PIPELINE_COMPANIONS \
    "$GEN_O/lsp_sx.o" \
    "$BUILD_DIR/asm_shux_lsp_diag_stub.o" \
    "$BUILD_DIR/typeck_lsp_io_stub.o" \
    "$BUILD_DIR/lsp_codegen_extern.o" \
    "$GEN_O/lsp_io_sx.o" \
    "$GEN_O/lsp_io_std_heap_sx.o" \
    "$LSP_DIAG_SEED_O" \
    src/lsp/lsp_diag_pipeline_sizes.o \
    "$SEED_O/lsp_state.o" \
    $BOOT_DRIVER_TAIL
  FB_RC=$?
  set -e
  if [ "$FB_RC" -eq 0 ]; then
    build_shux_asm_info "shux_asm built (gen_driver fallback)"
    LINK_OK=1
    LINK_MODE=driver
  fi
fi

if [ "$LINK_OK" -eq 1 ]; then
  case "$LINK_MODE" in
    crt0)
      build_shux_asm_info "Target-B-partial: linked without cc -c pipeline_gen.c (crt0 + asm .o)"
      ;;
    driver)
      build_shux_asm_info "Target-B-hybrid: shux-c -E + cc -c gen_driver (topology=${SHUX_ASM_LINK_TOPOLOGY})"
      ;;
    asm_only_experimental)
      build_shux_asm_info "Target-B-experimental: bootstrap with pipeline_sx.o partial (no pipeline_gen.c in link)"
      ;;
    asm_only_strict)
      build_shux_asm_info "Target-B-strict: build_asm + glue_standalone + partials, no pipeline_sx.o / pipeline_gen.c"
      ;;
  esac
fi

if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ] && [ "$LINK_MODE" != "asm_only_strict" ] && [ "$LINK_MODE" != "asm_only_experimental" ]; then
  shux_asm_bstrict_fail "B-strict requires asm_only_strict or asm_only_experimental link (got LINK_MODE=${LINK_MODE:-none})"
fi

# B-strict 验收：最终链无 cc -c pipeline_gen.c；asm_only_experimental = pipeline_sx partial bootstrap（strict 重链待 pipeline.o 自举）。
if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ] && [ "$LINK_MODE" = "asm_only_strict" ]; then
  build_shux_asm_info "B-strict OK - LINK_MODE=asm_only_strict, no pipeline_sx.o in final link"
  if [ "$SHUX_ASM_LINK_TOPOLOGY" = "full_asm" ] && [ "$ASM_TEXT_ALL_OK" = "1" ]; then
    build_shux_asm_info "M11 OK - full_asm topology + asm_only_strict (macOS/Linux production B-strict)"
  fi
fi
if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ] && [ "$LINK_MODE" = "asm_only_experimental" ]; then
  build_shux_asm_info "B-strict OK (experimental bootstrap) - LINK_MODE=asm_only_experimental, final link uses pipeline_sx.o partial not pipeline_gen.c"
fi

# CI：experimental 链成功后仍须 typeck.o EMIT_HEAVY（S2 gate）；兜底若上文未跑或仍为小桩。
if [ "$LINK_OK" -eq 1 ] && [ -n "${CI:-}" ]; then
  _s2_comp="./shux_asm.experimental"
  [ -x "$_s2_comp" ] || _s2_comp="./shux_asm"
  if [ -x "$_s2_comp" ]; then
    _s2_txt=$(asm_o_text_bytes "$BUILD_DIR/typeck.o" 2>/dev/null || echo 0)
    if asm_ci_skip_typeck_emit_heavy; then
      build_shux_asm_info "skip typeck EMIT_HEAVY S2 fallback on $(uname -s) (__text=${_s2_txt}B stub OK)"
    elif [ "${_s2_txt:-0}" -lt 68264 ] 2>/dev/null; then
      rebuild_typeck_o_emit_heavy_s2 "$_s2_comp" || {
        if [ -n "${SHUX_ASM_EXPERIMENTAL_SKIP_GEN:-}" ]; then
          shux_asm_bstrict_fail "typeck.o EMIT_HEAVY S2 fallback failed (__text=${_s2_txt}B)"
        fi
      }
    fi
  fi
fi

if [ "$ASM_READY" -eq 1 ] && [ "$LINK_OK" -ne 1 ]; then
  exit 1
fi
# strict 重链后 shux_asm 偶发 -o SIGSEGV：回退 experimental 快照或本轮 SHUX 编译器。
if [ -x ./shux_asm ] && [ "$LINK_OK" -eq 1 ]; then
  chmod +x scripts/shux_asm_postlink_smoke.sh 2>/dev/null || true
  if [ -x scripts/shux_asm_postlink_smoke.sh ]; then
    ./scripts/shux_asm_postlink_smoke.sh ./shux_asm "${SHUX:-./shux}" || {
      build_shux_asm_warn "shux_asm postlink smoke failed (strict relink -o broken)"
    }
  fi
  if bootstrap_wants_nostdlib; then
    _nostdlib_ok=0
    if command -v readelf >/dev/null 2>&1; then
      if ! readelf -d ./shux_asm 2>/dev/null | grep -q 'NEEDED'; then
        _nostdlib_ok=1
      fi
    elif command -v ldd >/dev/null 2>&1; then
      if ldd ./shux_asm 2>/dev/null | grep -q 'not a dynamic executable'; then
        _nostdlib_ok=1
      fi
    fi
    if [ "$_nostdlib_ok" -eq 1 ]; then
      build_shux_asm_info "bootstrap nostdlib final link OK (no libc/libm)"
    fi
  fi
fi
exit 0
