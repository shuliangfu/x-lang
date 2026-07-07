#!/usr/bin/env bash
# 全量回归套件：运行所有 run-*.sh（与 compiler/Makefile 的 test 目标一致）。
# 自举测试不跑：run-x-pipeline、run-x-multi-file、run-asm、run-without-c、run-bootstrap-verify 均不执行。
# 入口：./tests/run-all.sh；不设 SHU 时 make all 后优先 export SHUX=./compiler/shux-c（与 Makefile test_c 一致），避免本机 compiler/shux 为 seed 时子脚本误用 .x 路径。

set -e
cd "$(dirname "$0")/.."

# 【Why 根源治理 Windows TEMP 截断】MinGW make 子进程继承的 TEMP 可能被截断为
# "C:\Users\...\AppData\Loc"，导致 shux-c.exe 内部 gcc 调用失败 → std .o 构建失败 → 82/90 测试回归。
# 修复：Windows 下统一 export 短路径 TEMP/TMP，确保所有 make 子进程继承。
# 【Why 根源治理 Windows pthread 大栈失败】driver_run_thread_on_large_stack 在 Windows MinGW 上
# 用 pthread_attr_setstack 创建 256MiB 大栈线程时失败，导致无 -o 时的 token dump 路径返回 127
# （run-import/run-std/run-stdlib-import 等用 `out=$($SHUX file.x)` 检查 parse/typeck 输出全挂）。
# 修复：Windows 下 export SHUX_PIPELINE_NO_LARGE_STACK=1，跳过 pthread，直接在当前栈上跑。
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*)
    export TEMP=C:/shux_tmp
    export TMP=C:/shux_tmp
    mkdir -p "$TEMP" 2>/dev/null || true
    export SHUX_PIPELINE_NO_LARGE_STACK=1
    # 【Why 根源治理 Windows Store python3 stub】Windows 预装 python3 是 Store stub，
    # 无输出且 exit 49；run-comment-prefix.sh / run-fmt-wrap.sh 等用 python3 的脚本全挂。
    # 修复：python3 不可用时创建 /usr/local/bin/python3 → python 的 shim，
    # 并把 /usr/local/bin 加到 PATH 前面（Git Bash 默认不含此路径，导致 shim 不生效）。
    if ! python3 --version >/dev/null 2>&1 && command -v python >/dev/null 2>&1; then
      mkdir -p /usr/local/bin 2>/dev/null || true
      printf '#!/usr/bin/env bash\nexec python "$@"\n' > /usr/local/bin/python3 2>/dev/null || true
      chmod +x /usr/local/bin/python3 2>/dev/null || true
    fi
    # 确保 /usr/local/bin 在 PATH 前面，使 python3 shim 优先于 WindowsApps alias
    case ":$PATH:" in
      *:/usr/local/bin:*) ;;
      *) export PATH="/usr/local/bin:$PATH" ;;
    esac
    ;;
esac

# RUN_ALL_PORTABLE=1：全平台可移植子集（shux-c、无 asm/自举）；供 run-portable-c.sh / lite CI 使用。
if [ -n "${RUN_ALL_PORTABLE:-}" ]; then
    export RUN_ALL_USE_C=1
    export SHUX_SKIP_SUBSCRIPT_MAKE=1
    make -C compiler -q all 2>/dev/null || make -C compiler all
    if [ -x ./compiler/shux-c ]; then
        export SHUX=./compiler/shux-c
    fi
fi

if [ -n "$SHUX" ]; then
    export SHUX
    export RUN_ALL_USE_C=
    # B-strict run-all（tests/run-all-bstrict.sh）：勿 bootstrap-driver-seed 覆盖 shux_asm。
    if [ -n "${SHUX_BSTRICT_RUN_ALL:-}" ]; then
        if [ ! -x "$SHUX" ]; then
            echo "run-all.sh: SHUX_BSTRICT_RUN_ALL but $SHUX not executable" >&2
            exit 127
        fi
        export SHUX_RUN_ALL_BOOTSTRAP_SHUX=1
        export SHUX_LINK_SHUX="${SHUX_LINK_SHUX:-$SHUX}"
        # 非白名单脚本仍走 shux-c，须确保 shux-c 已构建。
        make -C compiler shux-c -q 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
    else
    # 子脚本内 `make -C compiler` 走 bootstrap-driver-seed，避免默认 all 用 C-only shux 覆盖 .x pipeline 链。
    # 【Why 根源治理 Windows seed 不可用】Windows 上 bootstrap_shuxc.exe 是旧版本（7月4日），
    # typeck 对大 u32 字面量（如 ARM64 指令编码 2847898621）报 "no matching overload"，
    # 导致 make bootstrap-driver-seed 失败。且 seeds/ 无 Windows 版本 seed。
    # 修复：Windows 下跳过 bootstrap-driver-seed，所有测试用 shux-c（C 前端）。
    case "$(uname -s 2>/dev/null)" in
      MINGW*|MSYS*|CYGWIN*)
        # Windows：seed 不可用，不设 SHUX_RUN_ALL_BOOTSTRAP_SHUX，所有测试走 shux-c。
        make -B -C compiler SHUX_LEGACY_C_FRONTEND=1 shux-c 2>/dev/null || true
        export SHUX_SKIP_SUBSCRIPT_MAKE=1
        ;;
      *)
    export SHUX_RUN_ALL_BOOTSTRAP_SHUX=1
    # 【Why 根源治理 shux-c 被覆盖】bootstrap-driver-seed 依赖 $(SHUX_C)=shux-c，
    # 而 shux-c 默认 target 是 `cp -f bootstrap_shuxc shux-c`（Makefile line 708），
    # 会把真正的 C 前端 shux-c 覆盖成 bootstrap_shuxc 副本（.x pipeline，3.9MB），
    # 导致 62+ 测试因用错 shux-c 而失败。修复：先 -B 构建真正 C 前端，
    # 再 export SHUX_SKIP_SUBSCRIPT_MAKE=1 阻止 bootstrap-driver-seed 覆盖它。
    make -B -C compiler SHUX_LEGACY_C_FRONTEND=1 shux-c 2>/dev/null || true
    export SHUX_SKIP_SUBSCRIPT_MAKE=1
    # 子脚本不再各自 make，避免长回归中反复链接 shux 产生竞态；入口统一构建一次 seed。
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
        ;;
    esac
    fi
    if [ -z "${SHUX_BSTRICT_RUN_ALL:-}" ]; then
        # stdlib-import 等用 shux-c 链多模块可执行；seed 仅 check/typeck。
        # -B 重建确保 shux-c 是真正 C 前端（bootstrap-driver-seed 可能触发依赖重建覆盖）。
        make -B -C compiler SHUX_LEGACY_C_FRONTEND=1 shux-c 2>/dev/null || true
        # 可执行链接/退出码回归优先 shux-c；typeck/check 仍用 SHU（seed）。
        if [ -x ./compiler/shux-c ]; then
            export SHUX_LINK_SHUX=./compiler/shux-c
        fi
    fi
    # 【Why 根源治理 .o 污染】shux_compile_std_x.sh auto 优先选 shux_asm/shux（seed），
    # 而 seed 在 macOS -backend asm 产出错误 .o 且 exit=0 不回退。
    # 修复：强制 std .o 用 shux-c 编译（与测试程序同源）。
    # 【工程原则】每次测试前必须全部重新编译 .o：若依赖旧 .o，代码改坏但 .o 仍是旧的正确版本，
    # 测试误报通过，掩盖真实回归。删除后预编译，确保 .o 与当前源码一致。
    export SHUX_COMPILE_STD_USE_C=1
    find std -name '*.o' -delete 2>/dev/null || true
    # 预编译所有 std .o（SHUX_COMPILE_STD_USE_C=1 强制用 shux-c）；失败不中断，后续按需 ensure
    make -C compiler std-objs SHUX_COMPILE_STD_USE_C=1 2>/dev/null || true
    # 预编译 core .o（SHUX_SKIP_SUBSCRIPT_MAKE=1 时子脚本跳过 make，需入口预构建）
    make -C compiler ../core/slice/slice.o 2>/dev/null || true
    # SHU 与 compiler/shux 为同一inode 时不能做「先 mv 再 cp」：mv 会破坏 cp 的源路径（常见：SHUX=./compiler/shux）。
    if [ -f compiler/shux ] && [ compiler/shux -ef "$SHUX" ]; then
        :
    elif [ -f compiler/shux ]; then
        mv compiler/shux compiler/shux.bak
        cp "$SHUX" compiler/shux
        trap '[ -f compiler/shux.bak ] && mv compiler/shux.bak compiler/shux 2>/dev/null || true' EXIT
    else
        cp "$SHUX" compiler/shux
        trap '[ -f compiler/shux.bak ] && mv compiler/shux.bak compiler/shux 2>/dev/null || true' EXIT
    fi
else
    # 无 SHU 时默认使用 C 流水线：仅构建 all（C 版 shux），子脚本不构建 bootstrap-driver-seed
    export RUN_ALL_USE_C=1
    make -C compiler -q all 2>/dev/null || make -C compiler all
    # 与 Makefile test_c 一致：子脚本用 shux-c 走纯 C 前端，避免本机 compiler/shux 已是
    # bootstrap-driver-seed（链 .x pipeline）时仍当「默认 C 回归」却误走 .x typeck 失败
    # 额外构建真正的 C 前端（SHUX_LEGACY_C_FRONTEND=1），避免 .x pipeline mangling 缺失导致重载冲突。
    # 用 -B 强制重建：`make all` 可能已把 shux-c 当作副产品生成（默认 cp bootstrap_shuxc），
    # 时间戳较新会导致后续 `make shux-c` 误判 up-to-date 而跳过真正 C 前端的构建。
    make -B -C compiler SHUX_LEGACY_C_FRONTEND=1 shux-c 2>/dev/null || true
    if [ -x "./compiler/shux-c" ]; then
        export SHUX=./compiler/shux-c
    fi
    # 阻止子脚本再次 `make all` / `make shux-c`：默认 shux-c target 是 `cp -f bootstrap_shuxc shux-c`，
    # 会覆盖上面刚刚构建好的真正 C 前端（SHUX_LEGACY_C_FRONTEND=1），导致回归全部失败。
    export SHUX_SKIP_SUBSCRIPT_MAKE=1
    # 【Why 根源治理 .o 污染】同 SHUX 分支：强制 std .o 用 shux-c 编译，清理旧 .o 并预编译。
    export SHUX_COMPILE_STD_USE_C=1
    find std -name '*.o' -delete 2>/dev/null || true
    make -C compiler std-objs SHUX_COMPILE_STD_USE_C=1 2>/dev/null || true
fi

# 无 shux 则直接失败，避免整次跑完仍打印 all tests OK
if [ ! -f compiler/shux ] || [ ! -x compiler/shux ]; then
    echo "run-all.sh: compiler/shux not found or not executable (run 'make -C compiler' first)." >&2
    exit 127
fi

# CI 下单个脚本失败时打印 SKIP 并继续，但统计失败数；结束时若有失败则报错并 exit 1，不再误报 all tests OK
# 失败时用醒目前缀和 stdout+stderr 双打，便于在截断的 CI 日志里快速定位
RUN_FAILED_COUNT=0
RUN_FAILED_SCRIPTS=""
RUN_BSTRICT_SKIP_COUNT=0
# bootstrap seed 下：typeck/check/lexer/preprocess 用 seed；其余 -o 走 shux-c（L5 白名单仅 B-strict/shux_asm 门禁用）。
# L5 白名单增量与三链矩阵：tests/docs/run-all-l5-whitelist.md
# 白名单脚本列表（run_shu_for_script / SHUX_BSTRICT_RUN_ALL 门禁共用）。
run_all_l5_whitelist_case() {
    case "$1" in
        run-lexer.sh|run-typeck.sh|run-check.sh|run-types-gate.sh|run-stdlib-import.sh|run-import.sh|run-std.sh|run-hello.sh|run-io.sh|run-http.sh|run-tar.sh|run-json.sh|run-csv.sh|run-net.sh|run-process.sh|run-set.sh|run-queue.sh|run-vec.sh|run-heap.sh|run-fs.sh|run-path.sh|run-map.sh|run-error.sh|run-compress.sh|run-thread.sh|run-fmt.sh|run-fmt-std.sh|run-debug.sh|run-io-driver.sh|run-multi-file-generic.sh|run-env.sh|run-crypto.sh|run-log.sh|run-stdtest.sh|run-channel.sh|run-backtrace.sh|run-hash.sh|run-math.sh|run-sort.sh|run-unicode.sh|run-dynlib.sh|run-random.sh|run-runtime.sh|run-abi-layout.sh|run-ub.sh|run-safe-leak-nightly-gate.sh|run-signed-overflow-gate.sh|run-lexer-bounds-gate.sh|run-layout-overflow-gate.sh|run-link-hardening-gate.sh|run-std-mem-safe-gate.sh|run-lang-unsafe-gate.sh|run-scope-borrow-gate.sh|run-al06-gate.sh|run-type-borrow-conflict-gate.sh|run-i64-ctfe-gate.sh|run-safe-unsafe-audit-gate.sh|run-target.sh|run-fmt-cmd.sh|run-test-cmd.sh|run-multi-file.sh|run-multi-func.sh|run-toplevel-let.sh|run-let-const.sh|run-return-value.sh|run-return-expr.sh|run-struct.sh|run-parser.sh|run-for.sh|run-array.sh|run-pointer.sh|run-if-expr.sh|run-enum-asm.sh|run-match.sh|run-enum.sh|run-dual-chain-struct-return.sh|run-float.sh|run-slice.sh|run-defer.sh|run-vector.sh|run-asm-binop-var.sh|run-asm-binop-block-var.sh|run-asm-binop-cfg-merge.sh|run-asm-binop-field-index.sh|run-asm-binop-nested-var.sh|run-asm-binop-index-lit.sh|run-asm-index-var.sh|run-asm-vector-var.sh|run-asm-assign-var.sh|run-asm-assign-index-binop.sh|run-asm-assign-index-lit.sh|run-asm-assign-index-lit-to-index.sh|run-asm-binop-block-var.sh|run-asm-assign-index-var.sh|run-asm-assign-index-expr.sh|run-asm-assign-index-block.sh|run-asm-assign-index-param.sh|run-asm-binop-div-index.sh|run-asm-cmp-index-binop.sh|run-panic.sh|run-result.sh|run-bool.sh|run-while.sh|run-option.sh|run-binary-expr.sh|run-compound-assign.sh|run-ternary.sh|run-boundary-encodings.sh|run-pool-limits.sh|run-preprocess.sh|run-goto.sh|run-mem.sh|run-string.sh|run-core-types.sh|run-builtin.sh|run-generic.sh|run-trait.sh|run-encoding.sh|run-base64.sh|run-time.sh|run-sync.sh|run-atomic.sh|run-ffi.sh|run-safe-ffi-contract-gate.sh)
            return 0
            ;;
    esac
    return 1
}
run_shu_for_script() {
    local script="$1"
    # bootstrap seed（非 B-strict）：仅 typeck/check/lexer/preprocess 用 seed；其余 -o 一律 shux-c（ubuntu seed asm 全链路易 SIGSEGV/ld 失败）。
    if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -z "${SHUX_BSTRICT_RUN_ALL:-}" ] && [ -x ./compiler/shux-c ]; then
        case "$script" in
          run-typeck.sh|run-check.sh|run-lexer.sh|run-preprocess.sh)
            echo "$SHUX"
            return 0
            ;;
          *)
            echo "./compiler/shux-c"
            return 0
            ;;
        esac
    fi
    # 非 x86_64 bootstrap：可执行 -o 优先 shux-c；typeck/check/lexer 仍用 seed SHU 验 .x 流水线。
    case "$(uname -m 2>/dev/null)" in
      x86_64|amd64) ;;
      *)
        if [ -x ./compiler/shux-c ] && { [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] || [ -n "${SHUX_BSTRICT_RUN_ALL:-}" ]; }; then
            case "$script" in
              run-typeck.sh|run-check.sh|run-lexer.sh|run-preprocess.sh) ;;
              *)
                echo "./compiler/shux-c"
                return 0
                ;;
            esac
        fi
        ;;
    esac
    # B-strict：白名单脚本一律用 SHU（shux_asm），其余仍 shux-c（与 L4 拓扑相同，仅编译器二进制不同）。
    if [ -n "${SHUX_BSTRICT_RUN_ALL:-}" ] && [ -x ./compiler/shux-c ]; then
        if run_all_l5_whitelist_case "$script"; then
            echo "$SHUX"
            return 0
        fi
        echo "./compiler/shux-c"
        return 0
    fi
    echo "$SHUX"
}
run() {
    local script="$1"
    local run_shu
    # 便携模式：跳过 x86/asm 专测（全平台同一套 std/语言回归）。
    if [ -n "${RUN_ALL_PORTABLE:-}" ]; then
        case "$script" in
          run-asm*.sh|run-enum-asm.sh)
            echo "run-all SKIP (portable: $script)"
            return 0
            ;;
        esac
    fi
    # CI Linux：run-asm-* 依赖 macOS otool 验 arm64 spill；asm 由 asm-smoke / build_shux_asm job 覆盖。
    if { [ -n "${GITHUB_ACTIONS:-}" ] || [ -n "${CI:-}" ]; } && [ -z "${SHUX_CI_FORCE_ASM:-}" ]; then
        case "$script" in
          run-asm*.sh|run-enum-asm.sh)
            echo "run-all SKIP (CI: $script; asm otool gates need macOS or SHUX_CI_FORCE_ASM=1)"
            return 0
            ;;
        esac
    fi
    run_shu=$(run_shu_for_script "$script")
    if [ ! -f "tests/$script" ]; then
        echo "run-all FAIL: missing tests/$script" >&2
        exit 1
    fi
    chmod +x "tests/$script"
    echo "[$(date +%H:%M:%S)] run-all START tests/$script (SHUX=$run_shu)"
    if [ -n "${GITHUB_ACTIONS:-}" ] || [ -n "${CI:-}" ]; then
        echo "run-all: → $script"
        s=0; SHUX="$run_shu" ./tests/$script || s=$?
        if [ "$s" -ne 0 ]; then
            # B-strict 全量：非白名单走 shux-c，失败仅记 SKIP（L5 只门禁 shux_asm 白名单）。
            if [ -n "${SHUX_BSTRICT_RUN_ALL:-}" ] && ! run_all_l5_whitelist_case "$script"; then
                echo "run-all SKIP (non-whitelist shux-c): $script (exit $s)"
                RUN_BSTRICT_SKIP_COUNT=$((RUN_BSTRICT_SKIP_COUNT + 1))
                return 0
            fi
            local msg="*** run-all FAILED: $script (exit $s) ***"
            echo "$msg"
            echo "$msg" >&2
            RUN_FAILED_COUNT=$((RUN_FAILED_COUNT + 1))
            RUN_FAILED_SCRIPTS="$RUN_FAILED_SCRIPTS $script"
        fi
        if [ "$s" -eq 0 ]; then
            echo "[$(date +%H:%M:%S)] run-all OK tests/$script"
        else
            echo "[$(date +%H:%M:%S)] run-all FAIL tests/$script (exit $s)"
        fi
    else
        s=0
        SHUX="$run_shu" ./tests/$script || s=$?
        if [ "$s" -eq 0 ]; then
            echo "[$(date +%H:%M:%S)] run-all OK tests/$script"
        else
            echo "[$(date +%H:%M:%S)] run-all FAIL tests/$script (exit $s)"
            exit "$s"
        fi
    fi
}

# 在 CI 下也必须通过的脚本（失败则 run-all 失败，不 SKIP）
run_required() {
    local script="$1"
    if [ ! -f "tests/$script" ]; then
        echo "run-all FAIL: missing tests/$script (required)" >&2
        exit 1
    fi
    chmod +x "tests/$script"
    ./tests/$script
}

# 词法 / 类型检查 / 最小可运行
run_required run-no-legacy-shux-gate.sh
run run-lexer.sh
run run-typeck.sh
run run-hello.sh
run run-check.sh
run run-types-gate.sh
run run-fmt-cmd.sh
run run-test-cmd.sh
run run-import.sh
run run-std.sh
run run-stdlib-import.sh
run run-target.sh
run run-return-value.sh
run run-multi-func.sh
# 泛型 / trait / 多文件
run run-generic.sh
run run-trait.sh
run run-multi-file.sh
run run-multi-file-generic.sh
# 表达式与控制流
run run-binary-expr.sh
run run-compound-assign.sh
run run-let-const.sh
# toplevel let：C 与 .x 流水线均已支持，自举后始终跑
run run-toplevel-let.sh
run run-bool.sh
run run-if-expr.sh
run run-ternary.sh
run run-option.sh
run run-result.sh
run run-process.sh
run run-env.sh
run run-sync.sh
run run-encoding.sh
run run-base64.sh
run run-crypto.sh
run run-log.sh
run run-stdtest.sh
run run-set.sh
run run-queue.sh
run run-atomic.sh
run run-channel.sh
run run-backtrace.sh
run run-hash.sh
run run-math.sh
run run-sort.sh
run run-ffi.sh
run run-json.sh
run run-csv.sh
run run-unicode.sh
run run-dynlib.sh
run run-compress.sh
run run-thread.sh
run run-random.sh
run run-http.sh
run run-tar.sh
run run-boundary-encodings.sh
run run-time.sh
run run-io.sh
run run-while.sh
run run-return-expr.sh
run run-for.sh
run run-float.sh
# 语法 / 结构体 / 类型
run run-parser.sh
run run-struct.sh
run run-slice.sh
run run-array.sh
run run-pointer.sh
run run-enum.sh
run run-match.sh
run run-panic.sh
run run-defer.sh
run run-goto.sh
run run-preprocess.sh
# 自举测试不执行：run-x-pipeline / run-x-multi-file / run-asm / run-without-c / run-bootstrap-verify 已全部排除
run run-vector.sh
# asm 反汇编门禁须 seed/asm 后端；test_c（RUN_ALL_USE_C + shux-c）仅验 C 流水线语义，见 test_x / linux-asm-smoke
# 非 x86_64 无 host asm 对象链，跳过 disasm 门禁（ARM64 CI test_x 仍验 .x 语义）。
# RUN_ALL_PORTABLE：便携全平台回归不含 asm 专测。
if [ -z "${RUN_ALL_USE_C:-}" ] && [ -z "${RUN_ALL_PORTABLE:-}" ]; then
case "$(uname -m 2>/dev/null)" in
  x86_64|amd64)
run run-asm-binop-var.sh
run run-asm-binop-block-var.sh
run run-asm-binop-cfg-merge.sh
run run-asm-binop-field-index.sh
run run-asm-binop-nested-var.sh
run run-asm-binop-index-lit.sh
run run-asm-index-var.sh
run run-asm-vector-var.sh
run run-asm-assign-var.sh
run run-asm-assign-index-binop.sh
run run-asm-assign-index-lit.sh
run run-asm-assign-index-lit-to-index.sh
run run-asm-assign-index-var.sh
run run-asm-assign-index-expr.sh
run run-asm-assign-index-block.sh
run run-asm-assign-index-param.sh
run run-asm-binop-div-index.sh
run run-asm-cmp-index-binop.sh
;;
  *)
    echo "run-all: skip asm disasm gates on $(uname -m 2>/dev/null || echo unknown)"
    ;;
esac
fi
# core/std 与标准库
run run-fmt.sh
run run-fmt-std.sh
run run-debug.sh
run run-core-types.sh
run run-builtin.sh
run run-mem.sh
run run-string.sh
run run-vec.sh
run run-heap.sh
run run-runtime.sh
run run-fs.sh
run run-path.sh
run run-map.sh
run run-error.sh
# 自举相关：net / io.driver / UB / ABI
run run-net.sh
run run-io-driver.sh
run run-ub.sh
run run-pool-limits.sh
run run-abi-layout.sh

if [ -n "${GITHUB_ACTIONS:-}" ] || [ -n "${CI:-}" ]; then
    if [ "$RUN_FAILED_COUNT" -gt 0 ]; then
        echo ""
        echo "run-all: $RUN_FAILED_COUNT test(s) failed; failed scripts:$RUN_FAILED_SCRIPTS"
        echo "run-all: $RUN_FAILED_COUNT test(s) failed; failed scripts:$RUN_FAILED_SCRIPTS" >&2
        exit 1
    fi
fi
if [ -n "${SHUX_BSTRICT_RUN_ALL:-}" ] && [ "${RUN_BSTRICT_SKIP_COUNT:-0}" -gt 0 ]; then
    echo "run-all-bstrict: L5 whitelist OK; skipped $RUN_BSTRICT_SKIP_COUNT non-whitelist shux-c script(s)"
fi
echo "all tests OK"
