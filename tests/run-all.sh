#!/usr/bin/env bash
# 全量回归套件：运行所有 run-*.sh（与 compiler/Makefile 的 test 目标一致）。
# 自举测试不跑：run-su-pipeline、run-su-multi-file、run-asm、run-without-c、run-bootstrap-verify 均不执行。
# 入口：./tests/run-all.sh；不设 SHU 时 make all 后优先 export SHU=./compiler/shu-c（与 Makefile test_c 一致），避免本机 compiler/shu 为 seed 时子脚本误用 .su 路径。

set -e
cd "$(dirname "$0")/.."
if [ -n "$SHU" ]; then
    export SHU
    export RUN_ALL_USE_C=
    # B-strict run-all（tests/run-all-bstrict.sh）：勿 bootstrap-driver-seed 覆盖 shu_asm。
    if [ -n "${SHULANG_BSTRICT_RUN_ALL:-}" ]; then
        if [ ! -x "$SHU" ]; then
            echo "run-all.sh: SHULANG_BSTRICT_RUN_ALL but $SHU not executable" >&2
            exit 127
        fi
        export SHULANG_RUN_ALL_BOOTSTRAP_SHU=1
        export SHULANG_LINK_SHU="${SHULANG_LINK_SHU:-$SHU}"
        # 非白名单脚本仍走 shu-c，须确保 shu-c 已构建。
        make -C compiler shu-c -q 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
    else
    # 子脚本内 `make -C compiler` 走 bootstrap-driver-seed，避免默认 all 用 C-only shu 覆盖 .su pipeline 链。
    export SHULANG_RUN_ALL_BOOTSTRAP_SHU=1
    # 子脚本不再各自 make，避免长回归中反复链接 shu 产生竞态；入口统一构建一次 seed。
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
    fi
    if [ -z "${SHULANG_BSTRICT_RUN_ALL:-}" ]; then
        # stdlib-import 等用 shu-c 链多模块可执行；seed 仅 check/typeck。
        make -C compiler shu-c -q 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
        # 可执行链接/退出码回归优先 shu-c；typeck/check 仍用 SHU（seed）。
        if [ -x ./compiler/shu-c ]; then
            export SHULANG_LINK_SHU=./compiler/shu-c
        fi
    fi
    export SHULANG_SKIP_SUBSCRIPT_MAKE=1
    # SHU 与 compiler/shu 为同一inode 时不能做「先 mv 再 cp」：mv 会破坏 cp 的源路径（常见：SHU=./compiler/shu）。
    if [ -f compiler/shu ] && [ compiler/shu -ef "$SHU" ]; then
        :
    elif [ -f compiler/shu ]; then
        mv compiler/shu compiler/shu.bak
        cp "$SHU" compiler/shu
        trap '[ -f compiler/shu.bak ] && mv compiler/shu.bak compiler/shu 2>/dev/null || true' EXIT
    else
        cp "$SHU" compiler/shu
        trap '[ -f compiler/shu.bak ] && mv compiler/shu.bak compiler/shu 2>/dev/null || true' EXIT
    fi
else
    # 无 SHU 时默认使用 C 流水线：仅构建 all（C 版 shu），子脚本不构建 bootstrap-driver-seed
    export RUN_ALL_USE_C=1
    make -C compiler -q all 2>/dev/null || make -C compiler all
    # 与 Makefile test_c 一致：子脚本用 shu-c 走纯 C 前端，避免本机 compiler/shu 已是
    # bootstrap-driver-seed（链 .su pipeline）时仍当「默认 C 回归」却误走 .su typeck 失败
    if [ -x "./compiler/shu-c" ]; then
        export SHU=./compiler/shu-c
    fi
fi

# 无 shu 则直接失败，避免整次跑完仍打印 all tests OK
if [ ! -f compiler/shu ] || [ ! -x compiler/shu ]; then
    echo "run-all.sh: compiler/shu not found or not executable (run 'make -C compiler' first)." >&2
    exit 127
fi

# CI 下单个脚本失败时打印 SKIP 并继续，但统计失败数；结束时若有失败则报错并 exit 1，不再误报 all tests OK
# 失败时用醒目前缀和 stdout+stderr 双打，便于在截断的 CI 日志里快速定位
RUN_FAILED_COUNT=0
RUN_FAILED_SCRIPTS=""
RUN_BSTRICT_SKIP_COUNT=0
# bootstrap seed 下：typeck/check 与已验 -o 绿了的 run-*.sh 用 seed；其余 -o 仍走 shu-c（避免未覆盖用例 SIGSEGV）。
# L5 白名单增量与三链矩阵：tests/docs/run-all-l5-whitelist.md
# 白名单脚本列表（run_shu_for_script / SHULANG_BSTRICT_RUN_ALL 门禁共用）。
run_all_l5_whitelist_case() {
    case "$1" in
        run-lexer.sh|run-typeck.sh|run-check.sh|run-stdlib-import.sh|run-import.sh|run-std.sh|run-hello.sh|run-io.sh|run-http.sh|run-tar.sh|run-json.sh|run-csv.sh|run-net.sh|run-process.sh|run-set.sh|run-queue.sh|run-vec.sh|run-heap.sh|run-fs.sh|run-path.sh|run-map.sh|run-error.sh|run-compress.sh|run-thread.sh|run-fmt.sh|run-fmt-std.sh|run-debug.sh|run-io-driver.sh|run-multi-file-generic.sh|run-env.sh|run-crypto.sh|run-log.sh|run-stdtest.sh|run-channel.sh|run-backtrace.sh|run-hash.sh|run-math.sh|run-sort.sh|run-unicode.sh|run-dynlib.sh|run-random.sh|run-runtime.sh|run-abi-layout.sh|run-ub.sh|run-target.sh|run-fmt-cmd.sh|run-test-cmd.sh|run-multi-file.sh|run-multi-func.sh|run-toplevel-let.sh|run-let-const.sh|run-return-value.sh|run-return-expr.sh|run-struct.sh|run-parser.sh|run-for.sh|run-array.sh|run-pointer.sh|run-if-expr.sh|run-enum-asm.sh|run-match.sh|run-enum.sh|run-dual-chain-struct-return.sh|run-float.sh|run-slice.sh|run-defer.sh|run-vector.sh|run-asm-binop-var.sh|run-asm-binop-block-var.sh|run-asm-binop-cfg-merge.sh|run-asm-binop-field-index.sh|run-asm-binop-nested-var.sh|run-asm-binop-index-lit.sh|run-asm-index-var.sh|run-asm-vector-var.sh|run-asm-assign-var.sh|run-asm-assign-index-binop.sh|run-asm-assign-index-lit.sh|run-asm-assign-index-lit-to-index.sh|run-asm-binop-block-var.sh|run-asm-assign-index-var.sh|run-asm-assign-index-expr.sh|run-asm-assign-index-block.sh|run-asm-assign-index-param.sh|run-asm-binop-div-index.sh|run-asm-cmp-index-binop.sh|run-panic.sh|run-result.sh|run-bool.sh|run-while.sh|run-option.sh|run-binary-expr.sh|run-compound-assign.sh|run-ternary.sh|run-boundary-encodings.sh|run-pool-limits.sh|run-preprocess.sh|run-goto.sh|run-mem.sh|run-string.sh|run-core-types.sh|run-builtin.sh|run-generic.sh|run-trait.sh|run-encoding.sh|run-base64.sh|run-time.sh|run-sync.sh|run-atomic.sh|run-ffi.sh)
            return 0
            ;;
    esac
    return 1
}
run_shu_for_script() {
    local script="$1"
    # 非 x86_64 bootstrap：可执行 -o 优先 shu-c；typeck/check/lexer 仍用 seed SHU 验 .su 流水线。
    case "$(uname -m 2>/dev/null)" in
      x86_64|amd64) ;;
      *)
        if [ -x ./compiler/shu-c ] && { [ -n "${SHULANG_RUN_ALL_BOOTSTRAP_SHU:-}" ] || [ -n "${SHULANG_BSTRICT_RUN_ALL:-}" ]; }; then
            case "$script" in
              run-typeck.sh|run-check.sh|run-lexer.sh) ;;
              *)
                echo "./compiler/shu-c"
                return 0
                ;;
            esac
        fi
        ;;
    esac
    # B-strict：白名单脚本一律用 SHU（shu_asm），其余仍 shu-c（与 L4 拓扑相同，仅编译器二进制不同）。
    if [ -n "${SHULANG_BSTRICT_RUN_ALL:-}" ] && [ -x ./compiler/shu-c ]; then
        if run_all_l5_whitelist_case "$script"; then
            echo "$SHU"
            return 0
        fi
        echo "./compiler/shu-c"
        return 0
    fi
    if [ -n "${SHULANG_RUN_ALL_BOOTSTRAP_SHU:-}" ] && [ -x ./compiler/shu-c ]; then
        if run_all_l5_whitelist_case "$script"; then
            echo "$SHU"
            return 0
        fi
        echo "./compiler/shu-c"
        return 0
    fi
    echo "$SHU"
}
run() {
    local script="$1"
    local run_shu
    run_shu=$(run_shu_for_script "$script")
    if [ ! -f "tests/$script" ]; then
        echo "run-all FAIL: missing tests/$script" >&2
        exit 1
    fi
    chmod +x "tests/$script"
    if [ -n "${GITHUB_ACTIONS:-}" ] || [ -n "${CI:-}" ]; then
        s=0; SHU="$run_shu" ./tests/$script || s=$?
        if [ "$s" -ne 0 ]; then
            # B-strict 全量：非白名单走 shu-c，失败仅记 SKIP（L5 只门禁 shu_asm 白名单）。
            if [ -n "${SHULANG_BSTRICT_RUN_ALL:-}" ] && ! run_all_l5_whitelist_case "$script"; then
                echo "run-all SKIP (non-whitelist shu-c): $script (exit $s)"
                RUN_BSTRICT_SKIP_COUNT=$((RUN_BSTRICT_SKIP_COUNT + 1))
                return 0
            fi
            local msg="*** run-all FAILED: $script (exit $s) ***"
            echo "$msg"
            echo "$msg" >&2
            RUN_FAILED_COUNT=$((RUN_FAILED_COUNT + 1))
            RUN_FAILED_SCRIPTS="$RUN_FAILED_SCRIPTS $script"
        fi
    else
        SHU="$run_shu" ./tests/$script
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
run run-lexer.sh
run run-typeck.sh
run run-hello.sh
run run-check.sh
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
# toplevel let：C 与 .su 流水线均已支持，自举后始终跑
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
# 自举测试不执行：run-su-pipeline / run-su-multi-file / run-asm / run-without-c / run-bootstrap-verify 已全部排除
run run-vector.sh
# asm 反汇编门禁须 seed/asm 后端；test_c（RUN_ALL_USE_C + shu-c）仅验 C 流水线语义，见 test_su / linux-asm-smoke
# 非 x86_64 无 host asm 对象链，跳过 disasm 门禁（ARM64 CI test_su 仍验 .su 语义）。
if [ -z "${RUN_ALL_USE_C:-}" ]; then
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
if [ -n "${SHULANG_BSTRICT_RUN_ALL:-}" ] && [ "${RUN_BSTRICT_SKIP_COUNT:-0}" -gt 0 ]; then
    echo "run-all-bstrict: L5 whitelist OK; skipped $RUN_BSTRICT_SKIP_COUNT non-whitelist shu-c script(s)"
fi
echo "all tests OK"
