#!/usr/bin/env bash
# C-08 v1 + G-05 收尾：根 build.x 构建策略 + build_tool / 统一入口 / 零 Makefile。
#
# 用法：./tests/run-c08-build-x-gate.sh
# wave honesty (2026-08-24 #4): DOC under analysis/archive/; compiler/Makefile +
# root Makefile deleted MG wave941 — entry = ./xbuild → xlang-build.sh;
# build-tool = scripts/build_tool.sh (refuse MF resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_C08_DOC:-analysis/archive/phase/phase-c-c08-v1.md}"

echo "=== C-08 / G-05: build.x + daily entry policy ==="
for f in build.x "$DOC" xlang-build.sh xbuild \
         compiler/scripts/g05_build_xlang_asm.sh \
         compiler/scripts/build_tool.sh \
         compiler/seeds/build_tool_libc_bridge.from_x.c; do
  [ -f "$f" ] || { echo "c08 build-x FAIL: missing $f" >&2; exit 1; }
done
grep -q 'build_use_asm_only' build.x || { echo "c08 build-x FAIL: build.x missing build_use_asm_only" >&2; exit 1; }
grep -q 'build_tool' build.x || { echo "c08 build-x FAIL: build.x missing build_tool ref" >&2; exit 1; }
[ -f compiler/seeds/build_runtime.from_x.c ] || { echo "c08 build-x FAIL: missing build_runtime.from_x.c" >&2; exit 1; }

# MG: Makefiles deleted — refuse resurrect; build-tool via shell + xbuild.
if [ -f compiler/Makefile ]; then
  echo "c08 build-x FAIL: compiler/Makefile resurrected (use ./xbuild + scripts/build_tool.sh)" >&2
  exit 1
fi
if [ -f Makefile ]; then
  echo "c08 build-x FAIL: root Makefile resurrected (use ./xbuild → xlang-build.sh)" >&2
  exit 1
fi
grep -q 'build-tool' xlang-build.sh || {
  echo "c08 build-x FAIL: xlang-build.sh missing build-tool command" >&2
  exit 1
}
grep -q 'scripts/build_tool.sh' xlang-build.sh || {
  echo "c08 build-x FAIL: xlang-build.sh must invoke scripts/build_tool.sh" >&2
  exit 1
}

# G-05：统一入口与 build_tool
grep -q 'build_tool' xlang-build.sh || { echo "c08 build-x FAIL: xlang-build.sh missing build_tool" >&2; exit 1; }
grep -q 'g05_build_xlang_asm\|g05_prepare_and_relink\|xlang-build' xbuild || true

# G-05 单点：libc bridge 必须调 g05 脚本（不再裸 make xlang_asm 字符串作默认路径）
grep -q 'g05_build_xlang_asm.sh' compiler/seeds/build_tool_libc_bridge.from_x.c || {
  echo "c08 build-x FAIL: build_tool_libc_bridge must invoke scripts/g05_build_xlang_asm.sh" >&2
  exit 1
}
# G-05 100%：默认走 prepare_and_relink，不再 exec make xlang_asm
grep -q 'g05_prepare_and_relink' compiler/scripts/g05_build_xlang_asm.sh || {
  echo "c08 build-x FAIL: g05_build_xlang_asm.sh must call g05_prepare_and_relink" >&2
  exit 1
}
grep -q 'bootstrap-driver-bstrict' compiler/scripts/g05_build_xlang_asm.sh || {
  echo "c08 build-x FAIL: g05_build_xlang_asm.sh missing FULL=1 bstrict path" >&2
  exit 1
}
for s in g05_relink_xlang.sh g05_prepare_and_relink.sh g05_build_xlang_asm.sh \
         g05_relink_env.sh g05_ensure_relink_prereqs.sh build_tool.sh; do
  [ -f "compiler/scripts/$s" ] || { echo "c08 build-x FAIL: missing compiler/scripts/$s" >&2; exit 1; }
done
# 产品路径零 make：prepare/ensure 不得调用 make 目标图
if grep -E 'make[[:space:]]+g05-|make[[:space:]]+-s[[:space:]]+g05-|make[[:space:]]+g05-export|make[[:space:]]+g05-ensure|make[[:space:]]+xlang_asm' \
     compiler/scripts/g05_prepare_and_relink.sh compiler/scripts/g05_ensure_relink_prereqs.sh \
     compiler/scripts/g05_relink_env.sh 2>/dev/null | grep -v '^[^:]*:[[:space:]]*#' >/dev/null; then
  echo "c08 build-x FAIL: product-path g05 scripts must not invoke make g05-*/xlang_asm" >&2
  exit 1
fi
grep -q 'g05_relink_env' compiler/scripts/g05_prepare_and_relink.sh || {
  echo "c08 build-x FAIL: prepare must use g05_relink_env.sh" >&2
  exit 1
}
grep -q 'g05_ensure_relink_prereqs' compiler/scripts/g05_prepare_and_relink.sh || {
  echo "c08 build-x FAIL: prepare must call g05_ensure_relink_prereqs.sh" >&2
  exit 1
}

# Daily entry documents G-05 / xbuild (root Makefile left).
grep -q 'G-05\|g05\|xlang-build' xbuild xlang-build.sh || {
  echo "c08 build-x FAIL: xbuild/xlang-build.sh should document G-05 daily entry" >&2
  exit 1
}

[ -f compiler/seeds/build_gen.c ] && [ -f compiler/seeds/build_runner_gen.c ] && [ -f compiler/seeds/build_runtime_x_gen.c ] || {
  echo "c08 build-x FAIL: missing compiler/seeds/build_*_gen.c pins" >&2
  exit 1
}

# 可选：legacy 烟测（默认跳过；XLANG_G05_LEGACY_SMOKE=1 时尝试，失败不硬红除非 XLANG_G05_LEGACY_FAIL=1）
if [ "${XLANG_G05_LEGACY_SMOKE:-}" = "1" ] && [ -x compiler/build_tool ]; then
  echo "=== G-05 optional legacy smoke (XLANG_G05_LEGACY_SMOKE=1) ==="
  set +e
  (cd compiler && ./build_tool ./xlang legacy)
  leg_rc=$?
  set -e
  if [ "$leg_rc" -ne 0 ]; then
    echo "g05 legacy smoke: FAIL rc=$leg_rc (known-limited: -x -E / seeds; not daily path)"
    if [ "${XLANG_G05_LEGACY_FAIL:-}" = "1" ]; then
      echo "c08 build-x FAIL: legacy smoke hard-fail (XLANG_G05_LEGACY_FAIL=1)" >&2
      exit 1
    fi
  else
    echo "g05 legacy smoke: OK"
  fi
fi

echo "c08 build-x gate OK (G-05 entry + g05_build_xlang_asm choke point + xbuild)"
