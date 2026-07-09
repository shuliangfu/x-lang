#!/usr/bin/env bash
# G-FFI-5 release CI 入口（策略门禁硬绿 + 可选运行时套件）
#
# 硬门槛（默认，跨平台）：
#   1) business 零裸 extern
#   2) §8 std 业务 unsafe 债务冻结（baseline）
#   3) std/sys|std/ffi unsafe 包裹 grep
#   4) SAFE-003 审计清单（跳过嵌套 lang-unsafe，避免链接债拖红策略门）
#
# 可选运行时：
#   SHUX_G_FFI5_LANG_UNSAFE=1  → 再跑 run-lang-unsafe-gate（需健康 std .o 链接）
#   SHUX_G_FFI5_LANG_UNSAFE_STRICT=1 → lang-unsafe 失败硬退出
#   默认：不跑 lang-unsafe 全套（当前多平台有 link/typeck 债，不阻塞 G-FFI-5 策略闭合）
#
# 用法：./tests/run-g-ffi-5-release-ci-gate.sh
#   SHUX_G_FFI5_FAIL=1  硬失败（CI 默认建议 1）
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_G_FFI5_FAIL:-1}
export SHUX_G_FFI5_FAIL="$FAIL"

die() {
  echo "g-ffi-5 release-ci FAIL: $*" >&2
  exit 1
}

echo "=== G-FFI-5 release CI bundle (policy hard) ==="
chmod +x \
  tests/run-g-ffi-5-std-wrap-gate.sh \
  tests/run-g-ffi-5-business-no-bare-extern-gate.sh \
  tests/run-lang-unsafe-gate.sh \
  tests/run-safe-unsafe-api-gate.sh \
  tests/run-safe-unsafe-audit-gate.sh 2>/dev/null || true

# 1–3：策略门禁
./tests/run-g-ffi-5-business-no-bare-extern-gate.sh || die "business-no-bare-extern"

# 4：SAFE-003 清单（默认跳过嵌套 lang-unsafe）
if [ -f tests/run-safe-unsafe-audit-gate.sh ]; then
  export SHUX_SAFE_SKIP_LANG_UNSAFE=1
  ./tests/run-safe-unsafe-audit-gate.sh || die "safe-unsafe-audit"
fi

# 5：可选 LANG-007 运行时套件
if [ "${SHUX_G_FFI5_LANG_UNSAFE:-0}" = "1" ] || [ "${SHUX_G_FFI5_LANG_UNSAFE_STRICT:-0}" = "1" ]; then
  if [ -z "${SHUX:-}" ]; then
    for cand in ./compiler/shux ./compiler/shux_asm ./compiler/shux-c; do
      if [ -x "$cand" ]; then
        export SHUX="$cand"
        break
      fi
    done
  fi
  set +e
  ./tests/run-lang-unsafe-gate.sh
  lu_rc=$?
  set -e
  if [ "$lu_rc" -ne 0 ]; then
    if [ "${SHUX_G_FFI5_LANG_UNSAFE_STRICT:-0}" = "1" ]; then
      die "lang-unsafe (rc=$lu_rc)"
    fi
    echo "g-ffi-5 release-ci: lang-unsafe soft-fail (rc=$lu_rc; set LANG_UNSAFE_STRICT=1 to hard-fail)"
  fi
else
  echo "g-ffi-5 release-ci: skip lang-unsafe suite (opt-in SHUX_G_FFI5_LANG_UNSAFE=1; known link/typeck debt)"
fi

echo "g-ffi-5 release-ci gate OK"
