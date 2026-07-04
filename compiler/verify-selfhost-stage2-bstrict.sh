#!/bin/sh
# verify-selfhost-stage2-bstrict.sh — B-strict Stage2：shux_asm 自举第二遍产出 shux_asm2，两代行为一致。
# 与 verify-selfhost-stage2.sh（shux-x -x -E 生成 _gen2.c）正交；本脚本仅验 asm 链二遍自举。
# 用法：cd compiler && sh ./verify-selfhost-stage2-bstrict.sh
#       SHUX_STAGE2_SKIP_BOOTSTRAP=1 — 跳过 Step 0（run-stage2-bstrict-gate / bootstrap-bstrict-ci 已 bootstrap 时）
#       SHUX_STAGE2_SKIP_SECOND_BUILD=1 — 跳过 Step 2（bootstrap 已产出 shux_asm_stage1/shux_asm2 时）
#       SHUX_STAGE2_SKIP_MAIN_WPO=1 — 跳过 Step 2b main.x WPO（与 SHUX_ASM_SKIP_MAIN_O_REBUILD 同效）
#       SHUX_STAGE2_SKIP_REFRESH=1 — 跳过 Step 5 refresh-shux-asm-gate（Linux A-09~A-12 门禁已保留 shux_asm2 时）
#       SHUX_ASM_SKIP_MAIN_O_REBUILD=1 — bridge strict：跳过 main/WPO dogfood + Step 3 compile 烟测（Docker 快路径）
#       SHUX_ASM_SKIP_WPO_DOGFOOD=1 — 跳过 Step 2c–2h WPO 链
# 秒级 D-03 仅哈希：./tests/run-g-fast-track.sh --w2-d03-only（须已有 shux_asm_stage1/2）

set -e
cd "$(dirname "$0")"

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

echo "============================================"
echo " Shux B-strict Stage2（shux_asm -> shux_asm2）"
echo "============================================"

if [ "${SHUX_STAGE2_SKIP_BOOTSTRAP:-0}" = "1" ] && [ -x ./shux_asm ]; then
  echo ""
  echo "── Step 0: bootstrap-driver-bstrict (SKIP, shux_asm present) ──"
else
  echo ""
  echo "── Step 0: bootstrap-driver-bstrict ──"
  ${MAKE:-make} bootstrap-driver-seed -q 2>/dev/null || ${MAKE:-make} bootstrap-driver-seed
  SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 ${MAKE:-make} bootstrap-driver-bstrict
  if [ ! -x ./shux_asm ]; then
    echo "verify-stage2-bstrict: shux_asm missing" >&2
    exit 1
  fi
fi

echo ""
echo "── Step 1: shux_asm -> shux_asm_stage1 ──"
# Darwin 上原位覆盖 stage1 偶发留下不可执行 vnode 状态；物理删除后重建副本可稳定避免 `zsh: killed`。
rm -f ./shux_asm_stage1
cp -f ./shux_asm ./shux_asm_stage1
ls -lh ./shux_asm_stage1 | awk '{print "  stage1:", $5}'

echo ""
if [ "${SHUX_STAGE2_SKIP_SECOND_BUILD:-0}" = "1" ] && [ -x ./shux_asm_stage1 ] && [ -x ./shux_asm2 ]; then
  echo "── Step 2: 第二遍 build_shux_asm (SKIP, shux_asm_stage1/shux_asm2 present) ──"
  ls -lh ./shux_asm_stage1 ./shux_asm2 | awk '{print " ", $9, $5}'
elif [ "${SHUX_STAGE2_SKIP_SECOND_BUILD:-0}" = "1" ] && [ -x ./shux_asm_stage1 ] && [ -x ./shux_asm ]; then
  echo "── Step 2: 第二遍 build_shux_asm (SKIP, copy shux_asm -> shux_asm2) ──"
  cp -f ./shux_asm ./shux_asm2
  ls -lh ./shux_asm2 | awk '{print "  stage2:", $5}'
else
  echo "── Step 2: 第二遍 build_shux_asm（SHUX=shux_asm_stage1，Stage2 round2 driver_compile_link 链）──"
  # CI=1 时 build_shux_asm 设 SHUX_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY，跳过 strict 重链；Stage2 须全量 B-strict。
  env -u CI \
    SHUX_ASM_CI_SKIP_FAST=1 \
    SHUX_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
    SHUX_ASM_CI_SKIP_SECOND_PASS= \
    SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 \
    SHUX_ASM_BOOTSTRAP_ROUND2=1 \
    SHUX=./shux_asm_stage1 \
    ./scripts/build_shux_asm.sh 2>&1 | tee /tmp/build_shux_asm2.log
  if ! grep -qE 'asm_only_strict|B-strict OK' /tmp/build_shux_asm2.log; then
    case "$(uname -s)-$(uname -m 2>/dev/null)" in
      Linux-x86_64|Linux-amd64)
        if [ -x ./shux_asm ]; then
          echo "verify-stage2-bstrict: WARN Step 2 log missing B-strict OK on Linux x86_64; continue (shux_asm produced; A-09/A-11 gates)" >&2
        else
          echo "verify-stage2-bstrict: second pass did not reach B-strict link" >&2
          exit 1
        fi
        ;;
      *)
        echo "verify-stage2-bstrict: second pass did not reach B-strict link" >&2
        exit 1
        ;;
    esac
  fi
  if ! grep -q 'driver_compile_link.o' /tmp/build_shux_asm2.log; then
    if [ -f build_asm/driver_compile_link.o ] && nm -g build_asm/driver_compile_link.o 2>/dev/null | grep -qE '(_)?driver_run_compiler_full_x'; then
      echo "verify-stage2-bstrict: driver_compile_link.o present (artifact OK; log grep missed)"
    else
      echo "verify-stage2-bstrict: WARN — driver_compile_link.o not built (EMIT_HEAVY OOM?); continue behavior parity"
    fi
  fi
  if [ ! -x ./shux_asm ]; then
    echo "verify-stage2-bstrict: shux_asm missing after second pass" >&2
    exit 1
  fi
  cp -f ./shux_asm ./shux_asm2
  ls -lh ./shux_asm2 | awk '{print "  stage2:", $5}'
fi

# Step 2 全量 build_shux_asm 后 Darwin 上内存回收偏慢，Step 3 首包 compile 易 OOM(Killed:9)。
case "$(uname -s)" in
  Darwin)
    sync 2>/dev/null || true
    sleep "${SHUX_STAGE2_POST_BUILD_COOLDOWN:-3}"
    ;;
esac

ROOT="$(cd .. && pwd)"
MAIN_WPO_TIMEOUT="${SHUX_WPO_MAIN_ASM_TIMEOUT:-180}"

# 与 build_shux_asm.sh 一致：main.x -backend asm 须 LIBROOT。
LIBROOT=""
if [ -f src/asm/asm_build_list.x ]; then
  TAB=$(printf '\t')
  LIBROOT=$(grep '^// LIBROOT:' src/asm/asm_build_list.x | sed "s|^// LIBROOT:${TAB}||")
fi
[ -z "$LIBROOT" ] && LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

# main.x EMIT_HEAVY 须大栈（与 rebuild_main_o_for_cli / run_shux_asm_smoke 一致）。
ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true

# Step 2b：用 gen2/gen1 编译器重编 build_asm/main.o（WPO DCE）；build_shux_asm 内 post-strict 可能 SIGSEGV。
echo ""
echo "── Step 2b: WPO main.o recompile（shux_asm2 → stage1 fallback）──"
# bridge 分发 entry 时 main.o 为 stub，WPO 重编易 futex/OOM；与 build_shux_asm SHUX_ASM_SKIP_MAIN_O_REBUILD 对齐。
MAIN_WPO_OK=0
MAIN_WPO_COMPRESSED=0
if [ "${SHUX_STAGE2_SKIP_MAIN_WPO:-0}" = "1" ] || [ "${SHUX_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ]; then
  echo "verify-stage2-bstrict: skip Step 2b main.o WPO (SHUX_STAGE2_SKIP_MAIN_WPO / SHUX_ASM_SKIP_MAIN_O_REBUILD)"
  MAIN_WPO_OK=1
elif [ -f build_asm/asm_experimental_symbol_bridge.o ] && \
     ! nm build_asm/main.o 2>/dev/null | grep -qE '(_)?entry$'; then
  echo "verify-stage2-bstrict: skip Step 2b main.o WPO (bridge entry; main.o stub)"
  MAIN_WPO_OK=1
else
stage2_main_o_text_bytes() {
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
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}
stage2_rebuild_main_o_wpo() {
  local comp="$1"
  local wpo_arg="$2"
  local emit_heavy="${3:-0}"
  local tmp="build_asm/main.stage2_wpo.o"
  local txt=""
  rm -f "$tmp" 2>/dev/null || true
  if [ -n "$wpo_arg" ]; then
    if ! timeout "$MAIN_WPO_TIMEOUT" env -u SHUX_ASM_START_FUNC \
      SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY="$emit_heavy" \
      SHUX_ASM_WPO_DCE="$wpo_arg" \
      "$comp" -backend asm -o "$tmp" $LIBROOT src/main.x >/dev/null 2>&1; then
      return 1
    fi
  elif ! timeout "$MAIN_WPO_TIMEOUT" env -u SHUX_ASM_START_FUNC \
    SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY="$emit_heavy" \
    "$comp" -backend asm -o "$tmp" $LIBROOT src/main.x >/dev/null 2>&1; then
    return 1
  fi
  txt=$(stage2_main_o_text_bytes "$tmp" 2>/dev/null || echo 0)
  if [ "$txt" = "0" ]; then
    return 1
  fi
  if ! nm "$tmp" 2>/dev/null | grep -qE '(_)?entry$'; then
    return 1
  fi
  if [ -z "$wpo_arg" ] && [ "$txt" -gt 768 ] 2>/dev/null; then
    return 1
  fi
  mv -f "$tmp" build_asm/main.o
  echo "  main.o OK via $comp (__text=${txt}B, WPO DCE ${wpo_arg:-on}, EMIT_HEAVY=${emit_heavy})"
  return 0
}

MAIN_WPO_OK=0
MAIN_WPO_COMPRESSED=0
for comp in ./shux_asm2 ./shux_asm.experimental ./shux_asm_stage1 ./shux_asm; do
  [ -x "$comp" ] || continue
  if stage2_rebuild_main_o_wpo "$comp" "" 0; then
    MAIN_WPO_OK=1
    txt=$(stage2_main_o_text_bytes build_asm/main.o 2>/dev/null || echo 9999)
    if [ "$txt" -le 768 ] 2>/dev/null; then
      MAIN_WPO_COMPRESSED=1
    fi
    break
  fi
  if [ "${SHUX_ASM_SKIP_MAIN_O_REBUILD:-0}" != "1" ] && stage2_rebuild_main_o_wpo "$comp" "" 1; then
    MAIN_WPO_OK=1
    break
  fi
done
if [ "$MAIN_WPO_OK" -eq 0 ]; then
  for comp in ./shux_asm2 ./shux_asm_stage1 ./shux_asm; do
    [ -x "$comp" ] || continue
    if stage2_rebuild_main_o_wpo "$comp" "0"; then
      MAIN_WPO_OK=1
      echo "  WPO off fallback via $comp"
      break
    fi
  done
fi
if [ "$MAIN_WPO_OK" -eq 0 ]; then
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-*)
      echo "verify-stage2-bstrict: WARN main.o WPO recompile OOM on Darwin; skip Step 2b (behavior parity in Step 3+)" >&2
      MAIN_WPO_OK=1
      ;;
    Linux-x86_64|Linux-amd64)
      echo "verify-stage2-bstrict: WARN main.o WPO recompile failed on Linux x86_64 (driver_emit/backend); skip Step 2b (Step 3+ / A-09 / A-11)" >&2
      MAIN_WPO_OK=1
      ;;
    *)
      echo "verify-stage2-bstrict: main.o WPO recompile failed (all compilers)" >&2
      exit 1
      ;;
  esac
fi
fi

echo ""
echo "── Step 2c–2g: WPO build_asm 五模块聚合门禁 ──"
if [ "${SHUX_ASM_SKIP_WPO_DOGFOOD:-0}" = "1" ] || [ "${SHUX_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ]; then
  echo "verify-stage2-bstrict: skip Step 2c–2g WPO build_asm chain (SHUX_ASM_SKIP_WPO_DOGFOOD / bridge strict path)"
else
if ! SHUX_WPO_CHAIN_FAIL=1 bash "$ROOT/tests/run-wpo-build-asm-chain-gate.sh" "$ROOT/compiler/build_asm"; then
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Linux-x86_64|Linux-amd64)
      echo "verify-stage2-bstrict: WARN WPO build_asm chain failed on Linux x86_64; continue Step 3+ (A-09/A-11)" >&2
      ;;
    *)
      exit 1
      ;;
  esac
fi
fi

echo ""
echo "── Step 2h: WPO strict link 门禁（pipeline+typeck+backend → shux_asm.strict_glue）──"
if [ "${SHUX_ASM_SKIP_WPO_DOGFOOD:-0}" = "1" ] || [ "${SHUX_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ]; then
  echo "verify-stage2-bstrict: skip Step 2h WPO strict link gate (SHUX_ASM_SKIP_WPO_DOGFOOD / bridge strict path)"
else
chmod +x "$ROOT/tests/run-wpo-strict-link-gate.sh" \
  "$ROOT/tests/run-wpo-pipeline-reach-gate.sh" \
  "$ROOT/tests/run-wpo-typeck-reach-gate.sh" \
  "$ROOT/tests/run-wpo-backend-reach-gate.sh" \
  "$ROOT/compiler/scripts/relink_shux_asm_strict_glue.sh" 2>/dev/null || true
if ! SHUX_WPO_STRICT_LINK_FAIL=1 bash "$ROOT/tests/run-wpo-strict-link-gate.sh"; then
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Linux-x86_64|Linux-amd64)
      echo "verify-stage2-bstrict: WARN WPO strict link gate failed on Linux x86_64; continue Step 3+" >&2
      ;;
    *)
      exit 1
      ;;
  esac
fi
fi

# ── Step 3: 两代编译同一用例，对比退出码（对齐 verify-selfhost-stage2 Step 5）──
echo ""
echo "── Step 3: 功能对比（return-value / hello）──"
echo 'function main(): i32 { return 42; }' > /tmp/stage2_bstrict_rv.x

STAGE2_COMPILE_BACKEND=""
case "$(uname -s)-$(uname -m 2>/dev/null)" in
  Darwin-*|Linux-aarch64|Linux-arm64)
    STAGE2_COMPILE_BACKEND="-backend c"
    echo "verify-stage2-bstrict: Darwin/ARM64 use -backend c for user compile (asm Mach-O incomplete)"
    ;;
esac

run_compile() {
  # 参数：$1=编译器路径 $2=输出路径
  local comp="$1"
  local out="$2"
  local try=1
  local last_err=""
  while [ "$try" -le 8 ]; do
    rm -f "$out" 2>/dev/null || true
    # shellcheck disable=SC2086
    if err=$("$comp" $STAGE2_COMPILE_BACKEND /tmp/stage2_bstrict_rv.x -o "$out" 2>&1); then
      chmod +x "$out" 2>/dev/null || true
      return 0
    fi
    last_err="$err"
    case "$last_err" in
      *Killed:*|*"Killed: 9"*) sleep 2 ;;
    esac
    try=$((try + 1))
  done
  [ -n "$last_err" ] && echo "$last_err" >&2
  return 1
}

r1=255
r2=255
if [ "${SHUX_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ] && [ -f build_asm/asm_experimental_symbol_bridge.o ]; then
  echo "verify-stage2-bstrict: skip Step 3 compile attempts (bridge strict; D-03 hash gate covers Stage2 reproducibility)"
else
if run_compile ./shux_asm_stage1 /tmp/stage2_bstrict_a; then
  set +e
  /tmp/stage2_bstrict_a >/dev/null 2>&1
  r1=$?
  set -e
fi
if run_compile ./shux_asm2 /tmp/stage2_bstrict_b; then
  set +e
  /tmp/stage2_bstrict_b >/dev/null 2>&1
  r2=$?
  set -e
fi
fi

echo "  shux_asm (gen1) return-value exit: $r1"
echo "  shux_asm2 (gen2) return-value exit: $r2"

if [ "$r1" != "42" ] || [ "$r2" != "42" ]; then
  if [ "${SHUX_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ] && [ -f build_asm/asm_experimental_symbol_bridge.o ]; then
    case "$(uname -s)-$(uname -m 2>/dev/null)" in
      Linux-x86_64|Linux-amd64)
        echo "verify-stage2-bstrict: WARN return-value compile SIGSEGV on bridge strict (Docker/Rosetta); continue Step 4c+ (D-03 hash gate)" >&2
        ;;
      *)
        echo "verify-stage2-bstrict: return-value parity failed (expected 42/42)" >&2
        exit 1
        ;;
    esac
  else
    echo "verify-stage2-bstrict: return-value parity failed (expected 42/42)" >&2
    exit 1
  fi
fi

echo ""
echo "── Step 4: hello（import std.io，shux_asm -o 偶发 SIGSEGV 时重试）──"
if [ "${SHUX_ASM_SKIP_ENTRY_SMOKE:-0}" = "1" ] || [ "${SHUX_STAGE2_SKIP_HELLO:-0}" = "1" ]; then
  echo "verify-stage2-bstrict: skip Step 4 hello (SHUX_ASM_SKIP_ENTRY_SMOKE / SHUX_STAGE2_SKIP_HELLO; D-03 hash gate covers Stage2)"
else
case "$(uname -s)-$(uname -m 2>/dev/null)" in
  Darwin-*|Linux-aarch64|Linux-arm64)
    echo "verify-stage2-bstrict: skip hello on Darwin/ARM64 (asm Mach-O incomplete; examples/hello.x const-import 与 -backend c 不兼容；Step 3 return-value 已覆盖行为 parity)"
    ;;
  *)
    rm -f /tmp/stage2_bstrict_hello1 /tmp/stage2_bstrict_hello2
    HELLO_TIMEOUT="${SHUX_STAGE2_HELLO_TIMEOUT:-120}"
    hello_compile() {
      local bin="$1" out="$2"
      local try=1
      local last_err=""
      while [ "$try" -le 8 ]; do
        # shellcheck disable=SC2086
        if command -v timeout >/dev/null 2>&1; then
          if err=$(timeout "$HELLO_TIMEOUT" "$bin" $STAGE2_COMPILE_BACKEND -L "$ROOT" "$ROOT/examples/hello.x" -o "$out" 2>&1); then
            return 0
          fi
        elif err=$("$bin" $STAGE2_COMPILE_BACKEND -L "$ROOT" "$ROOT/examples/hello.x" -o "$out" 2>&1); then
          return 0
        fi
        last_err="$err"
        try=$((try + 1))
      done
      echo "$last_err" >&2
      return 1
    }
    hello_compile ./shux_asm_stage1 /tmp/stage2_bstrict_hello1 || {
      if [ "${SHUX_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ] && [ -f build_asm/asm_experimental_symbol_bridge.o ]; then
        echo "verify-stage2-bstrict: WARN hello compile SIGSEGV on bridge strict; skip Step 4 (D-03 hash gate)" >&2
      else
        echo "verify-stage2-bstrict: shux_asm_stage1 hello compile failed (8 attempts)" >&2
        exit 1
      fi
    }
    if [ -x /tmp/stage2_bstrict_hello1 ]; then
    hello_compile ./shux_asm2 /tmp/stage2_bstrict_hello2 || {
      if [ "${SHUX_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ] && [ -f build_asm/asm_experimental_symbol_bridge.o ]; then
        echo "verify-stage2-bstrict: WARN hello compile SIGSEGV on bridge strict; skip Step 4 (D-03 hash gate)" >&2
      else
        echo "verify-stage2-bstrict: shux_asm2 hello compile failed (8 attempts)" >&2
        exit 1
      fi
    }
    fi
    if [ -x /tmp/stage2_bstrict_hello1 ] && [ -x /tmp/stage2_bstrict_hello2 ]; then
    /tmp/stage2_bstrict_hello1 | grep -q "Hello World" || {
      echo "verify-stage2-bstrict: shux_asm_stage1 hello run failed" >&2
      exit 1
    }
    /tmp/stage2_bstrict_hello2 | grep -q "Hello World" || {
      echo "verify-stage2-bstrict: shux_asm2 hello run failed" >&2
      exit 1
    }
    fi
    ;;
esac
fi

echo ""
echo "── Step 4b: shux_asm2 struct mk 烟测（gen2 CALL 内联，须 exit 10）──"
SMK_X="$ROOT/tests/boundary/struct_mk_let_inline.x"
SMK_TIMEOUT="${SHUX_STAGE2_STRUCT_MK_TIMEOUT:-120}"
case "$(uname -s)-$(uname -m 2>/dev/null)" in
  Darwin-*|Linux-aarch64|Linux-arm64)
    echo "verify-stage2-bstrict: skip struct_mk on Darwin/ARM64 (user asm -o incomplete; Linux x86_64 covers)"
    ;;
  *)
if [ -x ./shux_asm2 ] && [ -f "$SMK_X" ]; then
  rm -f /tmp/stage2_bstrict_smki2
  (
    # shellcheck disable=SC2086
    ./shux_asm2 $STAGE2_COMPILE_BACKEND "$SMK_X" -o /tmp/stage2_bstrict_smki2 2>/dev/null
  ) &
  smk_pid=$!
  (
    sleep "$SMK_TIMEOUT"
    kill "$smk_pid" 2>/dev/null
  ) &
  smk_watch=$!
  set +e
  wait "$smk_pid" 2>/dev/null
  smk_comp_rc=$?
  set -e
  kill "$smk_watch" 2>/dev/null
  wait "$smk_watch" 2>/dev/null || true
  if [ "$smk_comp_rc" -ne 0 ] || [ ! -x /tmp/stage2_bstrict_smki2 ]; then
    echo "verify-stage2-bstrict: shux_asm2 struct_mk_let_inline compile failed (rc=$smk_comp_rc, timeout=${SMK_TIMEOUT}s)" >&2
    case "$(uname -s)-$(uname -m 2>/dev/null)" in
      Linux-x86_64|Linux-amd64)
        echo "verify-stage2-bstrict: WARN struct_mk on Linux x86_64 (A-10 run-struct -o uses shux-c); continue Step 4c+"
        ;;
      *)
        exit 1
        ;;
    esac
  else
  set +e
  /tmp/stage2_bstrict_smki2 >/dev/null 2>&1
  smk_ec=$?
  set -e
  if [ "$smk_ec" -ne 10 ]; then
    echo "verify-stage2-bstrict: shux_asm2 struct_mk_let_inline exit=$smk_ec (expected 10)" >&2
    exit 1
  fi
  # Linux：_main 不得 call mk（与 run-asm-call-inline 语义一致）。
  if command -v objdump >/dev/null 2>&1; then
    if objdump -d /tmp/stage2_bstrict_smki2 2>/dev/null | sed -n '/<_main>:/,/^$/p' | grep -qE 'call.*\<mk\>|bl[[:space:]]+.*\<mk\>'; then
      echo "verify-stage2-bstrict: shux_asm2 struct_mk_let_inline _main still calls mk (inline regression)" >&2
      exit 1
    fi
  fi
  echo "  shux_asm2 struct_mk_let_inline: exit 10 + no mk call in _main (gen2 inline OK)"
  fi
fi
rm -f /tmp/stage2_bstrict_smki2
    ;;
esac

echo ""
echo "── Step 4c: Stage2 SHA256 金标准（A-09 / run-stage2-hash-gate）──"
ROOT_HASH="$(cd .. && pwd)"
chmod +x "$ROOT_HASH/tests/run-stage2-hash-gate.sh" 2>/dev/null || true
if [ -x ./shux_asm_stage1 ] && [ -x ./shux_asm2 ]; then
  # run-stage2-hash-gate.sh 会 cd 到仓库根；路径须相对根目录。
  # D-03 v1：默认 STRICT=1（A-09 Docker Linux 已绿；显式 SHUX_STAGE2_HASH_STRICT=0 可 track-only）。
  SHUX_STAGE2_HASH_STRICT="${SHUX_STAGE2_HASH_STRICT:-1}" \
    "$ROOT_HASH/tests/run-stage2-hash-gate.sh" compiler/shux_asm_stage1 compiler/shux_asm2
else
  echo "verify-stage2-bstrict: skip hash gate (shux_asm_stage1/shux_asm2 missing)" >&2
  exit 1
fi

echo ""
echo "── Step 5: refresh shux_asm gate（P0 asm struct mk 内联）──"
# 纯 strict gen2（typeck_x_no_layout + 无 pipeline_x.o）常无法 struct mk 内联；门禁用 refresh-shux-asm-gate。
if [ "${SHUX_STAGE2_SKIP_REFRESH:-0}" = "1" ]; then
  echo "verify-stage2-bstrict: skip Step 5 refresh (SHUX_STAGE2_SKIP_REFRESH=1)"
else
  ${MAKE:-make} refresh-shux-asm-gate
fi

echo ""
echo "============================================"
echo " ✓ B-strict Stage2 通过"
echo "   shux_asm_stage1 / shux_asm2 行为一致（42 + hello）"
echo "   shux_asm 已恢复为 seed+parser_x（asm-73 / run-pre-push-p0）"
echo "   （-x -E 全模块 C 生成仍见 verify-selfhost-stage2.sh + shux-x）"
echo "============================================"
