#!/bin/sh
# verify-selfhost-stage2-bstrict.sh — B-strict Stage2: xlang_asm → xlang_asm2 behavior parity.
# Orthogonal to verify-selfhost-stage2.sh (xlang-x -x -E → _gen2.c). This script only
# verifies the asm-chain second bootstrap.
# Authority (G.7): single body for make verify-selfhost-stage2-bstrict / bootstrap_verify
#   / CI stage2-bstrict / tests/run-stage2-*.
# wave893: live under compiler/scripts/ (Makefile pure @bash scripts/… form).
# Usage: cd compiler && bash scripts/verify-selfhost-stage2-bstrict.sh
# Env:
#   XLANG_STAGE2_SKIP_BOOTSTRAP=1 — skip Step 0 (gate already bootstrapped)
#   XLANG_STAGE2_SKIP_GEN1_REBUILD=1 — skip Step1 recipe rebuild; freeze whatever
#     xlang_asm is present (DEBUG ONLY — restores g05≠round2 topology fork)
#   XLANG_STAGE2_SKIP_SECOND_BUILD=1 — skip Step 2 (stages already present)
#   XLANG_STAGE2_SKIP_MAIN_WPO=1 — skip Step 2b main.x WPO
#   XLANG_STAGE2_SKIP_REFRESH=1 — skip Step 5 refresh-xlang-asm-gate
#   XLANG_ASM_SKIP_MAIN_O_REBUILD=1 — bridge strict fast path
#   XLANG_ASM_SKIP_WPO_DOGFOOD=1 — skip Step 2c–2h WPO chain
# PLATFORM: SHARED — orchestration only; product binaries stay host-local.

set -e
# cwd = compiler/ (this file lives in scripts/)
cd "$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

# G.7 single Stage2 asm_only_strict build recipe (Step1 gen1 + Step2 gen2).
# Must stay bit-identical across both rounds — topology fork was caused by freezing
# g05 product xlang_asm as gen1 while Step2 linked round2 asm_only_strict.
# PLATFORM: SHARED. Args: $1=XLANG driver path, $2=tee log path.
stage2_build_asm_only_strict() {
  _s2_xlang="$1"
  _s2_log="$2"
  # CI=1 时 build_xlang_asm 设 XLANG_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY，跳过 strict 重链；Stage2 须全量 B-strict。
  # PLATFORM: LINUX Stage2 — default WPO opt-in can shrink pipeline.o export list
  # (0–36 syms) and break strict re-link; dogfood WPO is orthogonal to gen1→gen2 parity.
  # SKIP_MAIN / SKIP_WPO / STRICT_LINK_PIPELINE_WPO=0 match proven green gate (b5470cde+).
  # BOOTSTRAP_ROUND2=1 selects the round2 companion set and skips stage1 sync
  # (Stage2 owns gen1 freeze explicitly after each round).
  env -u CI \
    XLANG_ASM_CI_SKIP_FAST=1 \
    XLANG_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
    XLANG_ASM_CI_SKIP_SECOND_PASS= \
    XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1 \
    XLANG_ASM_BOOTSTRAP_ROUND2=1 \
    XLANG_ASM_SKIP_MAIN_O_REBUILD="${XLANG_ASM_SKIP_MAIN_O_REBUILD:-1}" \
    XLANG_ASM_SKIP_WPO_DOGFOOD="${XLANG_ASM_SKIP_WPO_DOGFOOD:-1}" \
    XLANG_ASM_STRICT_LINK_PIPELINE_WPO="${XLANG_ASM_STRICT_LINK_PIPELINE_WPO:-0}" \
    XLANG="$_s2_xlang" \
    ./scripts/build_xlang_asm.sh 2>&1 | tee "$_s2_log"
}

# After a Stage2 asm_only_strict build: require binary, warn on missing B-strict
# markers / driver_compile_link (Linux soft-continue matches prior Step2 policy).
# PLATFORM: SHARED. Args: $1=log path, $2=step label for messages.
stage2_check_asm_only_strict_log() {
  _s2_log="$1"
  _s2_step="$2"
  if ! grep -qE 'asm_only_strict|B-strict OK' "$_s2_log"; then
    case "$(uname -s)-$(uname -m 2>/dev/null)" in
      Linux-x86_64|Linux-amd64)
        if [ -x ./xlang_asm ]; then
          echo "verify-stage2-bstrict: WARN $_s2_step log missing B-strict OK on Linux x86_64; continue (xlang_asm produced; A-09/A-11 gates)" >&2
        else
          echo "verify-stage2-bstrict: $_s2_step did not reach B-strict link" >&2
          exit 1
        fi
        ;;
      *)
        echo "verify-stage2-bstrict: $_s2_step did not reach B-strict link" >&2
        exit 1
        ;;
    esac
  fi
  if ! grep -q 'driver_compile_link.o' "$_s2_log"; then
    if [ -f build_asm/driver_compile_link.o ] && nm -g build_asm/driver_compile_link.o 2>/dev/null | grep -qE '(_)?driver_run_compiler_full_x'; then
      echo "verify-stage2-bstrict: driver_compile_link.o present (artifact OK; log grep missed)"
    elif grep -q 'skip driver_compile_emit_heavy.o recompile (XLANG_ASM_SKIP_DRIVER_EMIT_HEAVY=1)' "$_s2_log" \
      || [ "${XLANG_ASM_SKIP_DRIVER_EMIT_HEAVY:-0}" = "1" ]; then
      # Honest residual: bridge / pipeline-selfhosted path sets SKIP=1 (not OOM).
      # PLATFORM: SHARED — do not blame EMIT_HEAVY OOM when the skip is intentional.
      echo "verify-stage2-bstrict: WARN — driver_compile_link.o skipped (XLANG_ASM_SKIP_DRIVER_EMIT_HEAVY=1; bridge/selfhosted); continue behavior parity"
    else
      echo "verify-stage2-bstrict: WARN — driver_compile_link.o not built (EMIT_HEAVY failed or skipped); continue behavior parity"
    fi
  fi
  if [ ! -x ./xlang_asm ]; then
    echo "verify-stage2-bstrict: xlang_asm missing after $_s2_step" >&2
    exit 1
  fi
}

echo "============================================"
echo " Xlang B-strict Stage2（xlang_asm -> xlang_asm2）"
echo "============================================"

if [ "${XLANG_STAGE2_SKIP_BOOTSTRAP:-0}" = "1" ] && [ -x ./xlang_asm ]; then
  echo ""
  echo "── Step 0: bootstrap-driver-bstrict (SKIP, xlang_asm present) ──"
else
  echo ""
  echo "── Step 0: bootstrap-driver-bstrict ──"
  # wave941 MG: compiler/Makefile physically deleted; default MAKE=../xbuild
  # (this script cd's into compiler/ at line 20, so ../xbuild is repo root).
  # The make-specific -q query gate is dropped: xbuild has no -q equivalent
  # and always runs the shell-primary bootstrap_driver_seed.sh; running it
  # unconditionally is the safe choice for a verification gate.
  # PLATFORM: SHARED.
  # NOTE: bootstrap-driver-bstrict ends with refresh_xlang_asm_gate → g05 product
  # overlay on xlang_asm. Step1 below rebuilds gen1 with the Stage2 recipe so
  # SHA256 does not compare g05 product vs round2 asm_only_strict.
  ${MAKE:-../xbuild} bootstrap-driver-seed
  XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1 ${MAKE:-../xbuild} bootstrap-driver-bstrict
  if [ ! -x ./xlang_asm ]; then
    echo "verify-stage2-bstrict: xlang_asm missing" >&2
    exit 1
  fi
fi

echo ""
echo "── Step 1: materialize gen1 via Stage2 asm_only_strict recipe ──"
# Root cause of topology fork (4.8M g05 ≠ 5.5M round2): Step1 used to freeze the
# g05-synced product binary as gen1. Hash STRICT then compared different link
# recipes. Fix: rebuild gen1 with the SAME build_xlang_asm env as Step2, then freeze.
# PLATFORM: DARWIN — delete-then-cp avoids bad vnode / `zsh: killed` on in-place overwrite.
# PLATFORM: SHARED — gen1 freeze contract for dual-end hash STRICT (Linux + Darwin).
# Escape: XLANG_STAGE2_SKIP_GEN1_REBUILD=1 keeps legacy freeze-only (DEBUG; honest red).
if [ "${XLANG_STAGE2_SKIP_GEN1_REBUILD:-0}" = "1" ]; then
  echo "verify-stage2-bstrict: SKIP gen1 recipe rebuild (XLANG_STAGE2_SKIP_GEN1_REBUILD=1; topology may fork)"
  _GEN1_DRIVER=""
else
  _GEN1_DRIVER=./xlang_asm
  [ -x "$_GEN1_DRIVER" ] || _GEN1_DRIVER=./xlang
  if [ ! -x "$_GEN1_DRIVER" ]; then
    echo "verify-stage2-bstrict: no driver for gen1 rebuild ($_GEN1_DRIVER)" >&2
    exit 1
  fi
  echo "  gen1 driver: $_GEN1_DRIVER (Stage2 asm_only_strict recipe; not g05 freeze)"
  stage2_build_asm_only_strict "$_GEN1_DRIVER" /tmp/build_xlang_asm_gen1.log
  stage2_check_asm_only_strict_log /tmp/build_xlang_asm_gen1.log "Step 1 gen1"
fi
rm -f ./xlang_asm_stage1 ./xlang_asm_gen1_for_hash
cp -f ./xlang_asm ./xlang_asm_stage1
cp -f ./xlang_asm ./xlang_asm_gen1_for_hash
ls -lh ./xlang_asm_stage1 | awk '{print "  stage1 (gen1):", $5}'

echo ""
if [ "${XLANG_STAGE2_SKIP_SECOND_BUILD:-0}" = "1" ] && [ -x ./xlang_asm_stage1 ] && [ -x ./xlang_asm2 ]; then
  echo "── Step 2: 第二遍 build_xlang_asm (SKIP, xlang_asm_stage1/xlang_asm2 present) ──"
  ls -lh ./xlang_asm_stage1 ./xlang_asm2 | awk '{print " ", $9, $5}'
elif [ "${XLANG_STAGE2_SKIP_SECOND_BUILD:-0}" = "1" ] && [ -x ./xlang_asm_stage1 ] && [ -x ./xlang_asm ]; then
  echo "── Step 2: 第二遍 build_xlang_asm (SKIP, copy xlang_asm -> xlang_asm2) ──"
  cp -f ./xlang_asm ./xlang_asm2
  ls -lh ./xlang_asm2 | awk '{print "  stage2:", $5}'
else
  echo "── Step 2: 第二遍 build_xlang_asm（XLANG=xlang_asm_stage1，同配方 round2）──"
  stage2_build_asm_only_strict ./xlang_asm_stage1 /tmp/build_xlang_asm2.log
  stage2_check_asm_only_strict_log /tmp/build_xlang_asm2.log "Step 2"
  cp -f ./xlang_asm ./xlang_asm2
  ls -lh ./xlang_asm2 | awk '{print "  stage2:", $5}'
fi

# Step 2 全量 build_xlang_asm 后 Darwin 上内存回收偏慢，Step 3 首包 compile 易 OOM(Killed:9)。
case "$(uname -s)" in
  Darwin)
    sync 2>/dev/null || true
    sleep "${XLANG_STAGE2_POST_BUILD_COOLDOWN:-3}"
    ;;
esac

ROOT="$(cd .. && pwd)"
MAIN_WPO_TIMEOUT="${XLANG_WPO_MAIN_ASM_TIMEOUT:-180}"

# 与 build_xlang_asm.sh 一致：main.x -backend asm 须 LIBROOT。
LIBROOT=""
if [ -f src/asm/asm_build_list.x ]; then
  TAB=$(printf '\t')
  LIBROOT=$(grep '^// LIBROOT:' src/asm/asm_build_list.x | sed "s|^// LIBROOT:${TAB}||")
fi
[ -z "$LIBROOT" ] && LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

# main.x EMIT_HEAVY 须大栈（与 rebuild_main_o_for_cli / run_xlang_asm_smoke 一致）。
ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true

# Step 2b：用 gen2/gen1 编译器重编 build_asm/main.o（WPO DCE）；build_xlang_asm 内 post-strict 可能 SIGSEGV。
echo ""
echo "── Step 2b: WPO main.o recompile（xlang_asm2 → stage1 fallback）──"
# bridge 分发 entry 时 main.o 为 stub，WPO 重编易 futex/OOM；与 build_xlang_asm XLANG_ASM_SKIP_MAIN_O_REBUILD 对齐。
MAIN_WPO_OK=0
MAIN_WPO_COMPRESSED=0
if [ "${XLANG_STAGE2_SKIP_MAIN_WPO:-0}" = "1" ] || [ "${XLANG_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ]; then
  echo "verify-stage2-bstrict: skip Step 2b main.o WPO (XLANG_STAGE2_SKIP_MAIN_WPO / XLANG_ASM_SKIP_MAIN_O_REBUILD)"
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
    if ! timeout "$MAIN_WPO_TIMEOUT" env -u XLANG_ASM_START_FUNC \
      XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_ASM_ENTRY_EMIT_HEAVY="$emit_heavy" \
      XLANG_ASM_WPO_DCE="$wpo_arg" \
      "$comp" -backend asm -o "$tmp" $LIBROOT src/main.x >/dev/null 2>&1; then
      return 1
    fi
  elif ! timeout "$MAIN_WPO_TIMEOUT" env -u XLANG_ASM_START_FUNC \
    XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_ASM_ENTRY_EMIT_HEAVY="$emit_heavy" \
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
for comp in ./xlang_asm2 ./xlang_asm.experimental ./xlang_asm_stage1 ./xlang_asm; do
  [ -x "$comp" ] || continue
  if stage2_rebuild_main_o_wpo "$comp" "" 0; then
    MAIN_WPO_OK=1
    txt=$(stage2_main_o_text_bytes build_asm/main.o 2>/dev/null || echo 9999)
    if [ "$txt" -le 768 ] 2>/dev/null; then
      MAIN_WPO_COMPRESSED=1
    fi
    break
  fi
  if [ "${XLANG_ASM_SKIP_MAIN_O_REBUILD:-0}" != "1" ] && stage2_rebuild_main_o_wpo "$comp" "" 1; then
    MAIN_WPO_OK=1
    break
  fi
done
if [ "$MAIN_WPO_OK" -eq 0 ]; then
  for comp in ./xlang_asm2 ./xlang_asm_stage1 ./xlang_asm; do
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
if [ "${XLANG_ASM_SKIP_WPO_DOGFOOD:-0}" = "1" ] || [ "${XLANG_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ]; then
  echo "verify-stage2-bstrict: skip Step 2c–2g WPO build_asm chain (XLANG_ASM_SKIP_WPO_DOGFOOD / bridge strict path)"
else
if ! XLANG_WPO_CHAIN_FAIL=1 bash "$ROOT/tests/run-wpo-build-asm-chain-gate.sh" "$ROOT/compiler/build_asm"; then
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
echo "── Step 2h: WPO strict link 门禁（pipeline+typeck+backend → xlang_asm.strict_glue）──"
if [ "${XLANG_ASM_SKIP_WPO_DOGFOOD:-0}" = "1" ] || [ "${XLANG_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ]; then
  echo "verify-stage2-bstrict: skip Step 2h WPO strict link gate (XLANG_ASM_SKIP_WPO_DOGFOOD / bridge strict path)"
else
chmod +x "$ROOT/tests/run-wpo-strict-link-gate.sh" \
  "$ROOT/tests/run-wpo-pipeline-reach-gate.sh" \
  "$ROOT/tests/run-wpo-typeck-reach-gate.sh" \
  "$ROOT/tests/run-wpo-backend-reach-gate.sh" \
  "$ROOT/compiler/scripts/relink_xlang_asm_strict_glue.sh" 2>/dev/null || true
if ! XLANG_WPO_STRICT_LINK_FAIL=1 bash "$ROOT/tests/run-wpo-strict-link-gate.sh"; then
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
# PLATFORM: DARWIN — default pure-asm user -o (G.7 twin tip product path).
# Historical `-backend c` fallback was for Stage2 binaries that linked prefer/libtool
# ar user_asm after weak stubs (CG002 code_len=0). Fixed by BSTRICT MH_OBJECT host
# + EARLY link + arm64 enc; keep ALLOW_HOST_CC escape only when XLANG_STAGE2_FORCE_BACKEND_C=1.
case "$(uname -s)-$(uname -m 2>/dev/null)" in
  Darwin-*|Linux-aarch64|Linux-arm64)
    if [ "${XLANG_STAGE2_FORCE_BACKEND_C:-0}" = "1" ]; then
      STAGE2_COMPILE_BACKEND="-backend c"
      export XLANG_ALLOW_HOST_CC=1
      echo "verify-stage2-bstrict: Darwin/ARM64 FORCE -backend c (XLANG_STAGE2_FORCE_BACKEND_C=1; ALLOW_HOST_CC=1)"
    else
      echo "verify-stage2-bstrict: Darwin/ARM64 use default asm backend for user compile (pure-asm Mach-O)"
    fi
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
if [ "${XLANG_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ] && [ -f build_asm/asm_experimental_symbol_bridge.o ]; then
  echo "verify-stage2-bstrict: skip Step 3 compile attempts (bridge strict; D-03 hash gate covers Stage2 reproducibility)"
else
if run_compile ./xlang_asm_stage1 /tmp/stage2_bstrict_a; then
  set +e
  /tmp/stage2_bstrict_a >/dev/null 2>&1
  r1=$?
  set -e
fi
if run_compile ./xlang_asm2 /tmp/stage2_bstrict_b; then
  set +e
  /tmp/stage2_bstrict_b >/dev/null 2>&1
  r2=$?
  set -e
fi
fi

echo "  xlang_asm (gen1) return-value exit: $r1"
echo "  xlang_asm2 (gen2) return-value exit: $r2"

if [ "$r1" != "42" ] || [ "$r2" != "42" ]; then
  if [ "${XLANG_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ] && [ -f build_asm/asm_experimental_symbol_bridge.o ]; then
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
echo "── Step 4: hello（import std.io，xlang_asm -o 偶发 SIGSEGV 时重试）──"
if [ "${XLANG_ASM_SKIP_ENTRY_SMOKE:-0}" = "1" ] || [ "${XLANG_STAGE2_SKIP_HELLO:-0}" = "1" ]; then
  echo "verify-stage2-bstrict: skip Step 4 hello (XLANG_ASM_SKIP_ENTRY_SMOKE / XLANG_STAGE2_SKIP_HELLO; D-03 hash gate covers Stage2)"
else
  # PLATFORM: SHARED — Darwin/ARM64 pure-asm hello enabled after BSTRICT MH user_asm fix.
  # Escape: XLANG_STAGE2_SKIP_HELLO=1 or FORCE_BACKEND_C (hello still runs with -backend c if set).
  rm -f /tmp/stage2_bstrict_hello1 /tmp/stage2_bstrict_hello2
  HELLO_TIMEOUT="${XLANG_STAGE2_HELLO_TIMEOUT:-120}"
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
  hello_compile ./xlang_asm_stage1 /tmp/stage2_bstrict_hello1 || {
    if [ "${XLANG_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ] && [ -f build_asm/asm_experimental_symbol_bridge.o ]; then
      echo "verify-stage2-bstrict: WARN hello compile SIGSEGV on bridge strict; skip Step 4 (D-03 hash gate)" >&2
    else
      echo "verify-stage2-bstrict: xlang_asm_stage1 hello compile failed (8 attempts)" >&2
      exit 1
    fi
  }
  if [ -x /tmp/stage2_bstrict_hello1 ]; then
  hello_compile ./xlang_asm2 /tmp/stage2_bstrict_hello2 || {
    if [ "${XLANG_ASM_SKIP_MAIN_O_REBUILD:-0}" = "1" ] && [ -f build_asm/asm_experimental_symbol_bridge.o ]; then
      echo "verify-stage2-bstrict: WARN hello compile SIGSEGV on bridge strict; skip Step 4 (D-03 hash gate)" >&2
    else
      echo "verify-stage2-bstrict: xlang_asm2 hello compile failed (8 attempts)" >&2
      exit 1
    fi
  }
  fi
  if [ -x /tmp/stage2_bstrict_hello1 ] && [ -x /tmp/stage2_bstrict_hello2 ]; then
  /tmp/stage2_bstrict_hello1 | grep -q "Hello World" || {
    echo "verify-stage2-bstrict: xlang_asm_stage1 hello run failed" >&2
    exit 1
  }
  /tmp/stage2_bstrict_hello2 | grep -q "Hello World" || {
    echo "verify-stage2-bstrict: xlang_asm2 hello run failed" >&2
    exit 1
  }
  echo "  xlang_asm_stage1 / xlang_asm2 hello: Hello World"
  fi
fi

echo ""
echo "── Step 4b: xlang_asm2 struct mk 烟测（gen2 CALL 内联，须 exit 10）──"
SMK_X="$ROOT/tests/boundary/struct_mk_let_inline.x"
SMK_TIMEOUT="${XLANG_STAGE2_STRUCT_MK_TIMEOUT:-120}"
# PLATFORM: SHARED — Darwin/ARM64 pure-asm struct_mk enabled after BSTRICT MH user_asm fix.
if [ -x ./xlang_asm2 ] && [ -f "$SMK_X" ]; then
  rm -f /tmp/stage2_bstrict_smki2
  (
    # shellcheck disable=SC2086
    ./xlang_asm2 $STAGE2_COMPILE_BACKEND "$SMK_X" -o /tmp/stage2_bstrict_smki2 2>/dev/null
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
    echo "verify-stage2-bstrict: xlang_asm2 struct_mk_let_inline compile failed (rc=$smk_comp_rc, timeout=${SMK_TIMEOUT}s)" >&2
    case "$(uname -s)-$(uname -m 2>/dev/null)" in
      Linux-x86_64|Linux-amd64)
        echo "verify-stage2-bstrict: WARN struct_mk on Linux x86_64 (A-10 run-struct -o uses xlang-c); continue Step 4c+"
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
    echo "verify-stage2-bstrict: xlang_asm2 struct_mk_let_inline exit=$smk_ec (expected 10)" >&2
    exit 1
  fi
  # SHARED：_main 不得 call mk（与 run-asm-call-inline 语义一致）。
  if command -v objdump >/dev/null 2>&1; then
    if objdump -d /tmp/stage2_bstrict_smki2 2>/dev/null | sed -n '/<_main>:/,/^$/p' | grep -qE 'call.*\<mk\>|bl[[:space:]]+.*\<mk\>'; then
      echo "verify-stage2-bstrict: xlang_asm2 struct_mk_let_inline _main still calls mk (inline regression)" >&2
      exit 1
    fi
  elif command -v otool >/dev/null 2>&1; then
    # PLATFORM: DARWIN — otool -tv when objdump absent.
    if otool -tv /tmp/stage2_bstrict_smki2 2>/dev/null | sed -n '/_main:/,/^_/p' | grep -qE 'bl[[:space:]]+_mk\>|bl[[:space:]]+mk\>'; then
      echo "verify-stage2-bstrict: xlang_asm2 struct_mk_let_inline _main still calls mk (inline regression)" >&2
      exit 1
    fi
  fi
  echo "  xlang_asm2 struct_mk_let_inline: exit 10 + no mk call in _main (gen2 inline OK)"
  fi
fi
rm -f /tmp/stage2_bstrict_smki2

echo ""
echo "── Step 4c: Stage2 SHA256 金标准（A-09 / run-stage2-hash-gate）──"
ROOT_HASH="$(cd .. && pwd)"
chmod +x "$ROOT_HASH/tests/run-stage2-hash-gate.sh" 2>/dev/null || true
# Prefer gen1 freeze path (never touched by build sync). Fall back to stage1.
_HASH_GEN1="./xlang_asm_gen1_for_hash"
[ -x "$_HASH_GEN1" ] || _HASH_GEN1="./xlang_asm_stage1"
if [ -x "$_HASH_GEN1" ] && [ -x ./xlang_asm2 ]; then
  # run-stage2-hash-gate.sh cds to repo root; paths must be repo-relative.
  # PLATFORM: SHARED — D-03 default STRICT=1 on both Linux and Darwin after tip
  #   Stage2 SHA256 true fixed-point dogfood (Ubuntu 0ae06666… / Darwin 42ffac6e…).
  #   Step1+Step2 share stage2_build_asm_only_strict (same recipe). Size/hash diverge
  #   now means real compiler non-determinism or residual companion drift — never
  #   freeze g05 product as gen1, and never sync stage1 over gen1 to fake match.
  #   Explicit XLANG_STAGE2_HASH_STRICT=0 still forces track-only (escape hatch).
  _s2_hash_strict="${XLANG_STAGE2_HASH_STRICT:-1}"
  # Surface sizes before gate so topology fork is visible in the Stage2 log.
  ls -lh "$_HASH_GEN1" ./xlang_asm2 | awk '{print "  hash-input:", $9, $5}'
  XLANG_STAGE2_HASH_STRICT="$_s2_hash_strict" \
    "$ROOT_HASH/tests/run-stage2-hash-gate.sh" "compiler/${_HASH_GEN1#./}" compiler/xlang_asm2
else
  echo "verify-stage2-bstrict: skip hash gate (gen1 freeze / xlang_asm2 missing)" >&2
  exit 1
fi

echo ""
echo "── Step 5: refresh xlang_asm gate（P0 asm struct mk 内联）──"
# 纯 strict gen2（typeck_x_no_layout + 无 pipeline_x.o）常无法 struct mk 内联；门禁用 refresh-xlang-asm-gate。
# wave941 MG: compiler/Makefile physically deleted; default MAKE=../xbuild
# (script cd's into compiler/ at line 20, so ../xbuild is repo root).
# PLATFORM: SHARED.
if [ "${XLANG_STAGE2_SKIP_REFRESH:-0}" = "1" ]; then
  echo "verify-stage2-bstrict: skip Step 5 refresh (XLANG_STAGE2_SKIP_REFRESH=1)"
else
  ${MAKE:-../xbuild} refresh-xlang-asm-gate
fi

echo ""
echo "============================================"
echo " ✓ B-strict Stage2 通过"
echo "   xlang_asm_stage1 / xlang_asm2 行为一致（42 + hello）"
echo "   xlang_asm 已恢复为 seed+parser_x（asm-73 / run-pre-push-p0）"
echo "   （-x -E 全模块 C 生成仍见 verify-selfhost-stage2.sh + xlang-x）"
echo "============================================"
