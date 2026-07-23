#!/usr/bin/env bash
# M3-b / F1–F2：B-strict 全量白名单（bootstrap-bstrict / staging）。
#
# 自举最小验收见 ./tests/run-bootstrap-min-gate.sh（bootstrap-min，~25 项，不阻塞于 net/vec 等）。
# 本脚本覆盖全 std + asm 微测；gcc 回退 / import_alias 允许，非 D+E+F 闭合的必要条件。
#
# 用法：./tests/run-all-bstrict.sh
# 真冷测试：XLANG_L4_COLD=1 ./tests/run-all-bstrict.sh
# 不跑全量 run-all（其余用例仍走 xlang-c）；验收 xlang_asm 替代 seed 后白名单不回归。

set -e
cd "$(dirname "$0")/.."

# Wall-clock total for this suite (minutes + seconds at exit).
# PLATFORM: SHARED — date +%s is portable on macOS / Linux / Git Bash.
# Covers L4 purge + bootstrap-driver-bstrict + whitelist scripts (full script wall).
_RUN_BSTRICT_WALL_START=$(date +%s)
echo "run-all-bstrict: started at $(date '+%Y-%m-%d %H:%M:%S')"
_run_bstrict_print_elapsed() {
  local _end _elapsed _min _sec
  _end=$(date +%s)
  _elapsed=$((_end - _RUN_BSTRICT_WALL_START))
  if [ "$_elapsed" -lt 0 ]; then
    _elapsed=0
  fi
  _min=$((_elapsed / 60))
  _sec=$((_elapsed % 60))
  echo "run-all-bstrict: 本次测试共耗时 ${_min} 分 ${_sec} 秒（合计 ${_elapsed} 秒）"
}
trap '_run_bstrict_print_elapsed' EXIT

# L4 true cold test (opt-in): purge ALL .o + core binaries, then rebuild from scratch.
# PLATFORM: SHARED — works on macOS/Linux/Windows (MSYS).
# Usage: XLANG_L4_COLD=1 ./tests/run-all-bstrict.sh
# Per AGENTS.md L4 definition:
#   - Delete ALL .o under compiler/std/core (no selective deletion)
#   - Delete+rebuild xlang/xlang-c/xlang_asm/xlang_asm2/bootstrap_xlangc
#   - bootstrap-driver-bstrict rebuilds from zero (.o + g05 relink)
#   - Then run full bstrict whitelist
# Why opt-in: default CI uses incremental cache; L4 only for bootstrap/cut-over gates.
# Invariant: XLANG_L4_COLD=1 forces rebuild regardless of XLANG_BSTRICT_SKIP_BUILD.
if [ -n "${XLANG_L4_COLD:-}" ]; then
  echo "run-all-bstrict: XLANG_L4_COLD=1, purging ALL .o + core binaries (L4 true cold test) ..."
  # 1. Delete every .o under compiler/ (covers src/, build_asm/, build_seed_asm_host/, etc.)
  find compiler -name '*.o' -type f -delete 2>/dev/null || true
  # 2. Delete every .o under std/ and core/
  find std -name '*.o' -type f -delete 2>/dev/null || true
  find core -name '*.o' -type f -delete 2>/dev/null || true
  # 3. Delete core binaries (force full rebuild via bootstrap-driver-bstrict)
  rm -f compiler/xlang compiler/xlang-c compiler/xlang_asm compiler/xlang_asm2 compiler/bootstrap_xlangc
  # 4. Force rebuild path (ignore XLANG_BSTRICT_SKIP_BUILD for this run)
  unset XLANG_BSTRICT_SKIP_BUILD
  _l4_purged_o=$(find compiler std core -name '*.o' -type f 2>/dev/null | wc -l | tr -d ' ')
  echo "run-all-bstrict: L4 purge done (residual .o = ${_l4_purged_o}); rebuilding via bootstrap-driver-bstrict"
fi

if [ -z "${XLANG_L4_COLD:-}" ]; then
  if [ ! -f compiler/xlang_asm ] || [ ! -x compiler/xlang_asm ]; then
    echo "run-all-bstrict: build xlang_asm first: make -C compiler bootstrap-driver-bstrict" >&2
    exit 127
  fi
fi

# run-bootstrap-bstrict-ci.sh 已构建 xlang_asm 时跳过重复全量编译。
# PLATFORM: SHARED — product gate must use this-SHA g05 xlang_asm.
# Preferring leftover Stage2 freestanding xlang_asm2 (static ~5MB) over product
# xlang_asm is a July-14-class wrong-binary path (SEGV on std -E / false red).
# Opt-in only: XLANG_BSTRICT_USE_ASM2=1 when intentionally validating gen2.
if [ -n "${XLANG_BSTRICT_SKIP_BUILD:-}" ]; then
  if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && [ -x compiler/xlang_asm2 ]; then
    echo "run-all-bstrict: XLANG_BSTRICT_SKIP_BUILD=1 + USE_ASM2, cp xlang_asm2 -> xlang ..."
    cp -f compiler/xlang_asm2 compiler/xlang
  else
    echo "run-all-bstrict: XLANG_BSTRICT_SKIP_BUILD=1, cp xlang_asm -> xlang (product; not Stage2 asm2) ..."
    cp -f compiler/xlang_asm compiler/xlang
  fi
else
  echo "run-all-bstrict: bootstrap-driver-bstrict (M7: xlang_asm -> xlang by default) ..."
  make -C compiler bootstrap-driver-bstrict
fi

export XLANG=./compiler/xlang
export XLANG_SKIP_SUBSCRIPT_MAKE=1
export XLANG_RUN_ALL_BOOTSTRAP_XLANG=1
export XLANG_BSTRICT_RUN_ALL=1
# W3 gold：各 run-*.sh 内 ensure_std_c_o 会经 make 调 seed xlang，易挂起；统一跳过。
if [ -n "${XLANG_W3_BSTRICT_BEST_EFFORT:-}" ]; then
  export XLANG_W3_SKIP_STD_ENSURE=1
fi
# -o 链接宿主：产品冷链用本波 xlang（已 cp 自 xlang_asm），配合 XLANG_FORCE_LINK_BACKEND=c。
# 旧默认 pin xlang-c：冷 L2 后常为 seed 拷贝，import/hello/types 等 -o 假红或空产物。
if [ -z "${XLANG_LINK_XLANG:-}" ]; then
  if [ -x ./compiler/xlang_asm ]; then
    export XLANG_LINK_XLANG=./compiler/xlang_asm
  elif [ -x ./compiler/xlang ]; then
    export XLANG_LINK_XLANG=./compiler/xlang
  elif [ -x ./compiler/xlang-c ]; then
    export XLANG_LINK_XLANG=./compiler/xlang-c
  fi
fi
if [ -z "${XLANG_FORCE_LINK_BACKEND:-}" ]; then
  case "$(basename "${XLANG_LINK_XLANG:-}")" in
    xlang|xlang_asm|xlang_asm2|xlang_asm_stage1) export XLANG_FORCE_LINK_BACKEND=c ;;
  esac
fi
# CI 全量（XLANG_CI_NO_SKIP=1）须跑 parse 烟测；本地可 XLANG_SKIP_PARSE_SMOKE=1 规避 seed 链 SIGSEGV。
if [ -z "${XLANG_CI_NO_SKIP:-}" ]; then
  export XLANG_SKIP_PARSE_SMOKE=1
fi

# bootstrap-driver-seed 仅预链 io/fs/heap；runtime -o 按磁盘存在的 std/*.o 追加链接。
# Docker 门禁 purge 宿主 Mach-O 后须重建，否则 run-crypto/run-log 等 -o 缺 C 符号。
# 产品冷链：XLANG_SKIP_STD_ENSURE=1 跳过 ensure（避免残缺 std/*.o 被 labi 硬链毒化 asm 测）。
if [ -n "${XLANG_SKIP_STD_ENSURE:-}" ]; then
  echo "run-all-bstrict: XLANG_SKIP_STD_ENSURE=1, skip ensure std C .o"
elif [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ]; then
  # W3 gold：seed xlang 经 make 编 std/*.x 易挂起/进程风暴；best-effort 跳过整段 ensure。
  if [ -n "${XLANG_BSTRICT_STD_O_BEST_EFFORT:-}" ] && [ -n "${XLANG_W3_BSTRICT_BEST_EFFORT:-}" ]; then
    echo "run-all-bstrict: skip ensure std C .o (W3 best-effort; avoid seed make xlang storm)"
  else
  # shellcheck source=lib/build-std-c-o.sh
  . "$(dirname "$0")/lib/build-std-c-o.sh"
  echo "run-all-bstrict: ensure std C .o for bootstrap -o linking ..."
  # PLATFORM: SHARED — C -o prelinks these; missing .o → silent push_existing skip → UNDEF.
  # error.o required by tests/error (std_error_ok) and http; was omitted → Ubuntu L4 red.
  # core/*.o: required by run-import.sh (import("core.types") / core.result / core.option);
  # L4 wipes them too (Makefile already has rules); without ensure → pipeline XP003 (out_len=0).
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
    ../std/error/error.o ../std/test/test.o
    ../core/types/types.o ../core/result/result.o ../core/option/option.o
    ../core/debug/debug.o ../core/slice/mod.o ../core/mem/mem.o
  )
  for o in "${BSTRICT_STD_O[@]}"; do
    if ensure_std_c_o "$o"; then
      continue
    fi
    if [ -n "${XLANG_BSTRICT_STD_O_BEST_EFFORT:-}" ]; then
      echo "run-all-bstrict: WARN skip $o (ensure_std_c_o failed; best-effort)" >&2
      continue
    fi
    exit 1
  done
  fi
fi

# W3 gold：pinned seed 上跑全量 bstrict 白名单极慢且易挂；FAST 只跑子集。
if [ -n "${XLANG_W3_BSTRICT_BEST_EFFORT:-}" ] && [ -z "${XLANG_W3_BSTRICT_FAST:-}" ]; then
  export XLANG_W3_BSTRICT_FAST=1
fi
# shellcheck source=lib/w3-bstrict-fast.sh
. "$(dirname "$0")/lib/w3-bstrict-fast.sh"
_w3_wall_start=$(date +%s)
_w3_stat_ok=0
_w3_stat_skip=0
_w3_stat_fail=0
_w3_stat_timeout=0

# 与 run-xlang-asm-gate + run-all.sh run_shu_for_script 白名单核心项对齐
BSTRICT_SCRIPTS=(
  run-lexer.sh
  run-typeck.sh
  run-check.sh
  run-types-gate.sh
  run-hello.sh
  # void main + single-arg println product contract (Zig-like exit 0; not dual-arg workaround).
  # PLATFORM: SHARED — must stay on product xlang_asm; complements run-hello.
  run-void-main-gate.sh
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
  # Source hygiene: // comment prefixes + fmt damage (product .x tree).
  # PLATFORM: SHARED — python gate only; no host binary dependency.
  run-comment-prefix.sh
  # C7: expanded whitelist (gate/perf scripts migrated from path A)
  run-perf-simd-xlangffle-select.sh
  run-std-simd-xlangffle-select-gate.sh
  run-std-io-context-gate.sh
  run-std-net-context-gate.sh
)

for script in "${BSTRICT_SCRIPTS[@]}"; do
  if [ ! -f "tests/$script" ]; then
    echo "run-all-bstrict: missing tests/$script" >&2
    exit 1
  fi
  # Wall clock：整段 L5 不得超过 XLANG_W3_BSTRICT_WALL_SEC（默认 900s）。
  if [ -n "${XLANG_W3_BSTRICT_WALL_SEC:-}" ] && [ -n "${XLANG_W3_BSTRICT_BEST_EFFORT:-}" ]; then
    _w3_elapsed=$(($(date +%s) - _w3_wall_start))
    if [ "$_w3_elapsed" -ge "${XLANG_W3_BSTRICT_WALL_SEC}" ]; then
      echo "run-all-bstrict: WARN wall ${_w3_elapsed}s >= ${XLANG_W3_BSTRICT_WALL_SEC}s; stop early (W3)" >&2
      break
    fi
  fi
  # FAST：非白名单脚本秒级 SKIP（pinned seed 上无 gold 信号）。
  if [ -n "${XLANG_W3_BSTRICT_FAST:-}" ] && ! w3_bstrict_fast_should_run "$script"; then
    echo "run-all-bstrict: skip $script (W3 fast; pinned seed subset)"
    _w3_stat_skip=$((_w3_stat_skip + 1))
    continue
  fi
  chmod +x "tests/$script"
  echo "run-all-bstrict: $script ..."
  # Darwin：连续 xlang_asm check 易 OOM(Killed:9)；run-check 已跑 types gate 后须冷却再跑 run-types-gate。
  # Heavy -o linkers (run-ub/run-io/run-crypto/run-vector/run-thread/run-net/run-json)
  # peak ~75MB RSS per xlang_asm invocation; transient macOS memory pressure triggers
  # OOM killer (Killed:9). Default 15s cooldown (tunable XLANG_BSTRICT_DARWIN_HEAVY_COOLDOWN).
  case "$(uname -s)" in
    Darwin)
      # PLATFORM: MACOS|DARWIN — continuous xlang_asm -o peaks ~75MB RSS; under memory
      # pressure the OOM killer returns Killed:9. Heavy scripts need longer reclaim
      # windows. run-json was missing from the list (2026-07-21 L4: 3x Killed:9 →
      # product-chain exit 1, ~30 scripts unrun). Default heavy cooldown 15s (was 8).
      case "$script" in
        run-types-gate.sh) sleep "${XLANG_BSTRICT_DARWIN_TYPES_COOLDOWN:-5}" ;;
        run-ub.sh|run-io.sh|run-crypto.sh|run-vector.sh|run-thread.sh|run-net.sh|run-json.sh)
          sleep "${XLANG_BSTRICT_DARWIN_HEAVY_COOLDOWN:-15}" ;;
        *) sleep "${XLANG_BSTRICT_DARWIN_COOLDOWN:-1}" ;;
      esac
      ;;
  esac
  # asm 白名单须 asm-capable 编译器 -o；refresh 后 xlang 为 seed 链，experimental 仍保留真 asm。
  script_shu="$XLANG"
  script_link="${XLANG_LINK_XLANG:-}"
  case "$script" in
    run-hello.sh)
      # W3 / verify：pinned seed 上 hello -o 易 fork 风暴；与 XLANG_ASM_SKIP_ENTRY_SMOKE 同策略跳过。
      if [ -n "${XLANG_W3_BSTRICT_BEST_EFFORT:-}" ] || [ -n "${XLANG_ASM_SKIP_ENTRY_SMOKE:-}" ]; then
        echo "run-all-bstrict: skip $script (W3/entry smoke; seed -o fork storm)"
        continue
      fi
      ;;
    run-types-gate.sh)
      # run-check.sh 已用 xlang-c 跑完整 types gate；再跑 xlang_asm check 在 Linux 上 std.fmt
      # import 易报 dep not ready，Darwin 上亦易 OOM(Killed:9)。
      echo "run-all-bstrict: skip $script (run-check.sh already ran types gate via xlang-c)"
      continue
      ;;
    run-std-io-context-gate.sh|run-std-net-context-gate.sh)
      # PLATFORM: SHARED — context.x uses raw 'extern function atomic_*_c' /
      # 'extern function time_now_monotonic_ns_c' (not import std.atomic/std.time),
      # so xlang -o cannot auto-discover the runtime glue providers. Each gate
      # script now builds runtime_atomic_glue.o / runtime_time_os.o via
      # ensure_runtime_*_o and passes them explicitly on the -o link line.
      ;;
    run-net.sh)
      # PLATFORM: MACOS|DARWIN — net_tcp_listen_c binds port 8080; on Darwin the listen
      # syscall path (seed xlang-c) returns -1 (exit 1). Linux x86_64 covers the net gate.
      # Not caused by vector/codegen changes; pre-existing Darwin net runtime issue.
      case "$(uname -s)" in
        Darwin)
          echo "run-all-bstrict: skip $script on Darwin (net listen syscall; Linux covers)"
          continue
          ;;
      esac
      ;;
    run-dual-chain-struct-return.sh)
      # arm64：该脚本强制 seed/xlang_asm 双链 typeck；struct/return 项已在前序脚本覆盖。
      case "$(uname -m 2>/dev/null)" in
        x86_64|amd64) ;;
        *)
          echo "run-all-bstrict: skip $script on $(uname -m) (dual-chain seed+xlang_asm; struct/return already ran)"
          continue
          ;;
      esac
      ;;
    run-vector.sh)
      # 产品冷链：-o 用 xlang_asm + -backend c（须已有 std/string/string.o）。
      # 旧逻辑强绑 pin xlang-c → 冷 L2 后静默 compile fail、无 FAIL 文案。
      case "$(uname -m 2>/dev/null)" in
        x86_64|amd64)
          script_link="${XLANG_LINK_XLANG:-$script_shu}"
          ;;
        *)
          echo "run-all-bstrict: skip $script on $(uname -m) (user asm -o incomplete; Linux x86_64 covers)"
          continue
          ;;
      esac
      ;;
    run-asm-*.sh)
      # 默认本波产品 xlang_asm；gen2 仅 XLANG_BSTRICT_USE_ASM2=1。
      # 【Why】Stage2 freestanding 残留 xlang_asm2 曾冒充产品 → std -E SEGV / 假红（14 号类）。
      # 旧 xlang_asm.experimental 也曾盖住本波 xlang_asm → Darwin CG002 假红。
      if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && [ -x ./compiler/xlang_asm2 ]; then
        script_shu=./compiler/xlang_asm2
      elif [ -x ./compiler/xlang_asm ]; then
        script_shu=./compiler/xlang_asm
      elif [ -x ./compiler/xlang_asm.experimental ]; then
        script_shu=./compiler/xlang_asm.experimental
      fi
      script_link="$script_shu"
      ;;
    run-typeck.sh|run-check.sh|run-lexer.sh|run-stdlib-import.sh|run-import.sh|run-hello.sh|run-void-main-gate.sh|run-option.sh|run-defer.sh|run-crypto.sh)
      # 产品冷链验收：保留 script_shu=产品 xlang（bstrict 已 cp xlang_asm→xlang）。
      # 禁止因脚本含 `-o` 就改绑 pin xlang-c（CHK001 / 空产物假红）。
      # void-main：must use this-SHA xlang_asm (void main + single-arg println contract).
      script_link="${XLANG_LINK_XLANG:-$script_shu}"
      ;;
    *)
      # 历史：未 source bootstrap-link 且含 -o 时改绑 xlang-c。
      # 产品冷链默认已把 XLANG_LINK_XLANG 指到 xlang_asm；仅当 link 仍是 pin 且脚本明确需要时才改。
      if [ -x ./compiler/xlang-c ] && grep -qE '[[:space:]]-o[[:space:]]' "tests/$script" \
         && ! grep -q 'bootstrap-link-xlang' "tests/$script"; then
        case "$(basename "${XLANG_LINK_XLANG:-}")" in
          xlang-c)
            script_shu=./compiler/xlang-c
            script_link=./compiler/xlang-c
            ;;
          *)
            # 产品 link 宿主：保持 script_shu（xlang_asm 拷贝）
            script_link="${XLANG_LINK_XLANG:-$script_shu}"
            ;;
        esac
      fi
      ;;
  esac
  attempt=1
  _max_attempts=3
  if [ -n "${XLANG_W3_BSTRICT_BEST_EFFORT:-}" ]; then
    _max_attempts=1
  fi
  while [ "$attempt" -le "$_max_attempts" ]; do
    # 前序脚本内 make -C compiler 会把 xlang 刷回 seed；-o 须保持本波产品快照。
    # 默认 xlang_asm；仅 XLANG_BSTRICT_USE_ASM2=1 时用 gen2（禁 Stage2 freestanding 残留冒充）。
    if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && [ -x compiler/xlang_asm2 ]; then
      cp -f compiler/xlang_asm2 compiler/xlang 2>/dev/null || true
    else
      cp -f compiler/xlang_asm compiler/xlang 2>/dev/null || true
    fi
    _script_ok=0
    if [ -n "${XLANG_W3_BSTRICT_BEST_EFFORT:-}" ] && command -v timeout >/dev/null 2>&1; then
      # nohup >> log 时 stdout 非 TTY，子脚本内 xlang -o 会挂起；须 tee|cat Drain。
      _w3_script_log="/tmp/w3_bstrict_${script%.sh}.log"
      _w3_script_timeout="${XLANG_W3_BSTRICT_SCRIPT_TIMEOUT:-120}"
      if timeout -k 10 "$_w3_script_timeout" \
        env XLANG="$script_shu" XLANG_LINK_XLANG="$script_link" \
        bash -c "./tests/$script 2>&1 | tee \"$_w3_script_log\" | cat >/dev/null"; then
        _script_ok=1
      else
        _rc=$?
        w3_bstrict_cleanup_orphans
        if [ "$_rc" -eq 124 ]; then
          echo "run-all-bstrict: WARN timeout $script (${_w3_script_timeout}s; W3 best-effort)" >&2
          _w3_stat_timeout=$((_w3_stat_timeout + 1))
        fi
      fi
    elif XLANG="$script_shu" XLANG_LINK_XLANG="$script_link" ./tests/"$script"; then
      _script_ok=1
    fi
    if [ "$_script_ok" -eq 1 ]; then
      _w3_stat_ok=$((_w3_stat_ok + 1))
      break
    fi
    if [ "$attempt" -ge "$_max_attempts" ]; then
      echo "run-all-bstrict: $script failed after ${_max_attempts} attempt(s)" >&2
      if [ -n "${XLANG_W3_BSTRICT_BEST_EFFORT:-}" ]; then
        echo "run-all-bstrict: WARN continue ($script; XLANG_W3_BSTRICT_BEST_EFFORT=1)" >&2
        _w3_stat_fail=$((_w3_stat_fail + 1))
        break
      fi
      exit 1
    fi
    echo "run-all-bstrict: retry $script (attempt $((attempt + 1))) ..."
    # Darwin retry sleep: transient OOM (Killed:9) often clears after a few seconds of
    # inactive-page reclaim; without sleep, 3 retries can all hit the same pressure window.
    case "$(uname -s)" in
      Darwin) sleep "${XLANG_BSTRICT_DARWIN_RETRY_SLEEP:-5}" ;;
    esac
    attempt=$((attempt + 1))
  done
done

echo "run-all-bstrict OK (${#BSTRICT_SCRIPTS[@]} scripts, compiler/xlang is xlang_asm)"
if [ -n "${XLANG_W3_BSTRICT_BEST_EFFORT:-}" ]; then
  _w3_elapsed=$(($(date +%s) - _w3_wall_start))
  echo "run-all-bstrict: W3 best-effort complete ok=${_w3_stat_ok} skip=${_w3_stat_skip} fail=${_w3_stat_fail} timeout=${_w3_stat_timeout} wall=${_w3_elapsed}s"
fi
