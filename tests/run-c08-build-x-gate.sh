#!/usr/bin/env bash
# C-08 v1 + G-05 收尾：根 build.x 构建策略 + build_tool / 统一入口 / Makefile 边界。
#
# 用法：./tests/run-c08-build-x-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== C-08 / G-05: build.x + daily entry policy ==="
for f in build.x analysis/phase-c-c08-v1.md shux-build.sh \
         compiler/scripts/g05_build_shux_asm.sh \
         compiler/src/build_tool_libc_bridge.c; do
  [ -f "$f" ] || { echo "c08 build-x FAIL: missing $f" >&2; exit 1; }
done
grep -q 'build_use_asm_only' build.x || { echo "c08 build-x FAIL: build.x missing build_use_asm_only" >&2; exit 1; }
grep -q 'build_tool' build.x || { echo "c08 build-x FAIL: build.x missing build_tool ref" >&2; exit 1; }
[ -f compiler/src/build_runtime.c ] || { echo "c08 build-x FAIL: missing build_runtime.c" >&2; exit 1; }
grep -q 'build-tool' compiler/Makefile || { echo "c08 build-x FAIL: Makefile missing build-tool target" >&2; exit 1; }

# G-05：统一入口与 build_tool
grep -q 'build_tool' shux-build.sh || { echo "c08 build-x FAIL: shux-build.sh missing build_tool" >&2; exit 1; }
grep -q 'g05_build_shux_asm' shux-build.sh || true  # optional mention in help

# G-05 单点：libc bridge 必须调 g05 脚本（不再裸 make shux_asm 字符串作默认路径）
grep -q 'g05_build_shux_asm.sh' compiler/src/build_tool_libc_bridge.c || {
  echo "c08 build-x FAIL: build_tool_libc_bridge must invoke scripts/g05_build_shux_asm.sh" >&2
  exit 1
}
# 脚本内仍可委托 make（实现层）；须保留 shux_asm 金标准路径
grep -q 'make shux_asm' compiler/scripts/g05_build_shux_asm.sh || {
  echo "c08 build-x FAIL: g05_build_shux_asm.sh must default to make shux_asm" >&2
  exit 1
}
grep -q 'bootstrap-driver-bstrict' compiler/scripts/g05_build_shux_asm.sh || {
  echo "c08 build-x FAIL: g05_build_shux_asm.sh missing FULL=1 bstrict path" >&2
  exit 1
}
# G-05 最终链接迁出 Makefile recipe → g05_relink_shux.sh
[ -f compiler/scripts/g05_relink_shux.sh ] || {
  echo "c08 build-x FAIL: missing compiler/scripts/g05_relink_shux.sh" >&2
  exit 1
}
grep -q 'g05_relink_shux.sh' compiler/Makefile || {
  echo "c08 build-x FAIL: Makefile relink-shux must invoke g05_relink_shux.sh" >&2
  exit 1
}

# 根 Makefile 日常目标委托 shux-build.sh（G-05 物理收缩：顶层不再直调 compiler）
grep -q 'shux-build.sh' Makefile || {
  echo "c08 build-x FAIL: root Makefile must delegate to shux-build.sh" >&2
  exit 1
}
grep -q 'G-05' Makefile || {
  echo "c08 build-x FAIL: root Makefile should document G-05 daily entry" >&2
  exit 1
}

# compiler/Makefile 顶注释：兜底角色
head -10 compiler/Makefile | grep -q 'G-05\|兜底\|build_tool' || {
  echo "c08 build-x FAIL: compiler/Makefile header should mark G-05 fallback role" >&2
  exit 1
}

[ -f compiler/seeds/build_gen.c ] && [ -f compiler/seeds/build_runner_gen.c ] && [ -f compiler/seeds/build_runtime_x_gen.c ] || {
  echo "c08 build-x FAIL: missing compiler/seeds/build_*_gen.c pins" >&2
  exit 1
}

# 可选：legacy 烟测（默认跳过；SHUX_G05_LEGACY_SMOKE=1 时尝试，失败不硬红除非 SHUX_G05_LEGACY_FAIL=1）
if [ "${SHUX_G05_LEGACY_SMOKE:-}" = "1" ] && [ -x compiler/build_tool ]; then
  echo "=== G-05 optional legacy smoke (SHUX_G05_LEGACY_SMOKE=1) ==="
  set +e
  (cd compiler && ./build_tool ./shux legacy)
  leg_rc=$?
  set -e
  if [ "$leg_rc" -ne 0 ]; then
    echo "g05 legacy smoke: FAIL rc=$leg_rc (known-limited: -x -E / seeds; not daily path)"
    if [ "${SHUX_G05_LEGACY_FAIL:-}" = "1" ]; then
      echo "c08 build-x FAIL: legacy smoke hard-fail (SHUX_G05_LEGACY_FAIL=1)" >&2
      exit 1
    fi
  else
    echo "g05 legacy smoke: OK"
  fi
fi

echo "c08 build-x gate OK (G-05 entry + g05_build_shux_asm choke point)"
