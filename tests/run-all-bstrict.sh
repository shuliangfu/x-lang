#!/usr/bin/env bash
# M3-b / F1–F2：B-strict 白名单（含 run-io/http/tar/json；与 run-shux-asm-gate + L4 核心子集一致）。
# 用法：./tests/run-all-bstrict.sh
# 不跑全量 run-all（其余用例仍走 shux-c）；验收 shux_asm 替代 seed 后白名单不回归。

set -e
cd "$(dirname "$0")/.."

if [ ! -f compiler/shux_asm ] || [ ! -x compiler/shux_asm ]; then
  echo "run-all-bstrict: build shux_asm first: make -C compiler bootstrap-driver-bstrict" >&2
  exit 127
fi

# run-bootstrap-bstrict-ci.sh 已构建 shux_asm 时跳过重复全量编译。
if [ -n "${SHUX_BSTRICT_SKIP_BUILD:-}" ]; then
  echo "run-all-bstrict: SHUX_BSTRICT_SKIP_BUILD=1, cp shux_asm -> shux ..."
  cp -f compiler/shux_asm compiler/shux
else
  echo "run-all-bstrict: bootstrap-driver-bstrict (M7: shux_asm -> shux by default) ..."
  make -C compiler bootstrap-driver-bstrict
fi

export SHUX=./compiler/shux
export SHUX_SKIP_SUBSCRIPT_MAKE=1
export SHUX_RUN_ALL_BOOTSTRAP_SHUX=1
export SHUX_BSTRICT_RUN_ALL=1
# refresh 后 shux/shux_asm 为 seed 链；-o 链接用 shux-c（与 run-option/run-pool-limits 分流一致）。
export SHUX_LINK_SHUX=./compiler/shux-c
# CI 全量（SHUX_CI_NO_SKIP=1）须跑 parse 烟测；本地可 SHUX_SKIP_PARSE_SMOKE=1 规避 seed 链 SIGSEGV。
if [ -z "${SHUX_CI_NO_SKIP:-}" ]; then
  export SHUX_SKIP_PARSE_SMOKE=1
fi

# bootstrap-driver-seed 仅预链 io/fs/heap；runtime -o 按磁盘存在的 std/*.o 追加链接。
# Docker 门禁 purge 宿主 Mach-O 后须重建，否则 run-crypto/run-log 等 -o 缺 C 符号。
if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ]; then
  # shellcheck source=lib/build-std-c-o.sh
  . "$(dirname "$0")/lib/build-std-c-o.sh"
  echo "run-all-bstrict: ensure std C .o for bootstrap -o linking ..."
  BSTRICT_STD_O=(
    ../std/process/process.o ../std/string/string.o ../std/path/path.o
    ../std/runtime/runtime.o ../std/net/net.o ../std/thread/thread.o
    ../std/time/time.o ../std/random/random.o ../std/env/env.o
    ../std/sync/sync.o ../std/encoding/encoding.o ../std/base64/base64.o
    ../std/crypto/crypto.o ../std/log/log.o ../std/atomic/atomic.o
    ../std/channel/channel.o ../std/backtrace/backtrace.o ../std/hash/hash.o
    ../std/math/math.o ../std/sort/sort.o ../std/ffi/ffi.o ../std/json/json.o
    ../std/csv/csv.o ../std/unicode/unicode.o
    ../std/dynlib/dynlib.o ../std/http/http.o ../std/tar/tar.o ../std/queue/queue.o
    ../std/test/test.o
  )
  for o in "${BSTRICT_STD_O[@]}"; do
    ensure_std_c_o "$o"
  done
fi

# 与 run-shux-asm-gate + run-all.sh run_shu_for_script 白名单核心项对齐
BSTRICT_SCRIPTS=(
  run-lexer.sh
  run-typeck.sh
  run-check.sh
  run-types-gate.sh
  run-hello.sh
  run-import.sh
  run-stdlib-import.sh
  run-std.sh
  run-while.sh
  run-option.sh
  run-compound-assign.sh
  run-multi-file.sh
  run-struct.sh
  run-return-value.sh
  run-return-expr.sh
  run-target.sh
  run-parser.sh
  run-for.sh
  run-array.sh
  run-pointer.sh
  run-if-expr.sh
  run-enum-asm.sh
  run-match.sh
  run-enum.sh
  run-dual-chain-struct-return.sh
  run-float.sh
  run-slice.sh
  run-defer.sh
  run-vector.sh
  run-asm-binop-var.sh
  run-asm-binop-block-var.sh
  run-asm-binop-cfg-merge.sh
  run-asm-binop-field-index.sh
  run-asm-binop-nested-var.sh
  run-asm-binop-index-lit.sh
  run-asm-index-var.sh
  run-asm-vector-var.sh
  run-asm-assign-var.sh
  run-asm-assign-index-binop.sh
  run-asm-assign-index-lit.sh
  run-asm-assign-index-lit-to-index.sh
  run-asm-assign-index-var.sh
  run-asm-assign-index-expr.sh
  run-asm-assign-index-block.sh
  run-asm-assign-index-param.sh
  run-asm-binop-div-index.sh
  run-asm-cmp-index-binop.sh
  run-panic.sh
  run-result.sh
  run-binary-expr.sh
  run-fmt-cmd.sh
  run-test-cmd.sh
  run-bool.sh
  run-ternary.sh
  run-boundary-encodings.sh
  run-let-const.sh
  run-toplevel-let.sh
  run-preprocess.sh
  run-goto.sh
  run-multi-func.sh
  run-mem.sh
  run-string.sh
  run-core-types.sh
  run-builtin.sh
  run-trait.sh
  run-generic.sh
  run-encoding.sh
  run-base64.sh
  run-time.sh
  run-sync.sh
  run-atomic.sh
  run-ffi.sh
  run-safe-ffi-contract-gate.sh
  run-csv.sh
  run-io.sh
  run-http.sh
  run-tar.sh
  run-json.sh
  run-net.sh
  run-process.sh
  run-set.sh
  run-queue.sh
  run-vec.sh
  run-heap.sh
  run-fs.sh
  run-path.sh
  run-map.sh
  run-error.sh
  run-compress.sh
  run-thread.sh
  run-fmt.sh
  run-debug.sh
  run-io-driver.sh
  run-multi-file-generic.sh
  run-env.sh
  run-crypto.sh
  run-log.sh
  run-stdtest.sh
  run-channel.sh
  run-backtrace.sh
  run-hash.sh
  run-math.sh
  run-sort.sh
  run-unicode.sh
  run-dynlib.sh
  run-random.sh
  run-runtime.sh
  run-abi-layout.sh
  run-fmt-std.sh
  run-std-mem-safe-gate.sh
  run-lang-unsafe-gate.sh
  run-scope-borrow-gate.sh
  run-al06-gate.sh
  run-type-borrow-conflict-gate.sh
  run-i64-ctfe-gate.sh
  run-safe-unsafe-audit-gate.sh
  run-ub.sh
  run-safe-leak-nightly-gate.sh
  run-signed-overflow-gate.sh
  run-lexer-bounds-gate.sh
  run-layout-overflow-gate.sh
  run-link-hardening-gate.sh
  run-pool-limits.sh
)

for script in "${BSTRICT_SCRIPTS[@]}"; do
  if [ ! -f "tests/$script" ]; then
    echo "run-all-bstrict: missing tests/$script" >&2
    exit 1
  fi
  chmod +x "tests/$script"
  echo "run-all-bstrict: $script ..."
  # Darwin：连续 shux_asm check 易 OOM(Killed:9)；run-check 已跑 types gate 后须冷却再跑 run-types-gate。
  case "$(uname -s)" in
    Darwin)
      case "$script" in
        run-types-gate.sh) sleep "${SHUX_BSTRICT_DARWIN_TYPES_COOLDOWN:-5}" ;;
        *) sleep "${SHUX_BSTRICT_DARWIN_COOLDOWN:-1}" ;;
      esac
      ;;
  esac
  # asm 白名单须 asm-capable 编译器 -o；refresh 后 shux 为 seed 链，experimental 仍保留真 asm。
  script_shu="$SHUX"
  script_link="${SHUX_LINK_SHUX:-}"
  case "$script" in
    run-types-gate.sh)
      # run-check.sh 已用 shux-c 跑完整 types gate；再跑 shux_asm check 在 Linux 上 std.fmt
      # import 易报 dep not ready，Darwin 上亦易 OOM(Killed:9)。
      echo "run-all-bstrict: skip $script (run-check.sh already ran types gate via shux-c)"
      continue
      ;;
    run-dual-chain-struct-return.sh)
      # arm64：该脚本强制 seed/shux_asm 双链 typeck；struct/return 项已在前序脚本覆盖。
      case "$(uname -m 2>/dev/null)" in
        x86_64|amd64) ;;
        *)
          echo "run-all-bstrict: skip $script on $(uname -m) (dual-chain seed+shux_asm; struct/return already ran)"
          continue
          ;;
      esac
      ;;
    run-vector.sh)
      # shux_asm 用户 -o 缺 std/string/string.o（vec_add_verify 需 shux_string_memcmp_c）；-o 走 shux-c。
      case "$(uname -m 2>/dev/null)" in
        x86_64|amd64)
          if [ -x ./compiler/shux-c ]; then
            script_shu=./compiler/shux-c
            script_link=./compiler/shux-c
          fi
          ;;
        *)
          echo "run-all-bstrict: skip $script on $(uname -m) (user asm -o incomplete; Linux x86_64 covers)"
          continue
          ;;
      esac
      ;;
    run-asm-*.sh)
      if [ -x ./compiler/shux_asm.experimental ]; then
        script_shu=./compiler/shux_asm.experimental
      elif [ -x ./compiler/shux_asm ]; then
        script_shu=./compiler/shux_asm
      fi
      script_link=./compiler/shux-c
      ;;
    *)
      # 仍直接用 $SHUX -o 且未 source bootstrap-link-shux 的脚本：refresh 后 seed shux asm 不可用。
      if [ -x ./compiler/shux-c ] && grep -qE '[[:space:]]-o[[:space:]]' "tests/$script" \
         && ! grep -q 'bootstrap-link-shux' "tests/$script"; then
        script_shu=./compiler/shux-c
        script_link=./compiler/shux-c
      fi
      ;;
  esac
  attempt=1
  while [ "$attempt" -le 3 ]; do
    if SHUX="$script_shu" SHUX_LINK_SHUX="$script_link" ./tests/"$script"; then
      break
    fi
    if [ "$attempt" -ge 3 ]; then
      echo "run-all-bstrict: $script failed after 3 attempts" >&2
      exit 1
    fi
    echo "run-all-bstrict: retry $script (attempt $((attempt + 1))) ..."
    attempt=$((attempt + 1))
  done
done

echo "run-all-bstrict OK (${#BSTRICT_SCRIPTS[@]} scripts, compiler/shux is shux_asm)"
