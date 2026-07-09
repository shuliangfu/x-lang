#!/usr/bin/env bash
# G-FFI-5：业务 tests 无「裸 extern 调用」——含 extern 的业务测试须有 unsafe 包裹调用，
# 或列入 tests/baseline/g-ffi-5-business-extern-allowlist.tsv。
#
# 排除：tests/unsafe、tests/probes、tests/kernel、tests/ffi（专项/探针）。
# 另验：std/ 业务层（排除 std/sys、std/ffi）零 `unsafe`（安全路线 §8 可验证）。
#
# 用法：./tests/run-g-ffi-5-business-no-bare-extern-gate.sh
#   SHUX_G_FFI5_FAIL=1  — 失败硬退出（CI）
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_G_FFI5_FAIL:-0}
ALLOW="tests/baseline/g-ffi-5-business-extern-allowlist.tsv"
die() {
  echo "g-ffi-5 business FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== G-FFI-5: business tests no bare extern calls ==="
[ -f "$ALLOW" ] || die "missing $ALLOW"
[ -f tests/run-g-ffi-5-std-wrap-gate.sh ] || die "missing std wrap gate"

is_allowlisted() {
  local f="$1"
  # shellcheck disable=SC2162
  while IFS=$'\t' read tid path rest; do
    [ -z "${tid:-}" ] && continue
    case "$tid" in \#*) continue ;; esac
    [ "$path" = "$f" ] && return 0
  done < "$ALLOW"
  return 1
}

# ── business tests: extern 文件必须含 unsafe 或在 allowlist ──
MISS=0
# portable find (no -print0 dependency on weird platforms for bash 3.2)
while IFS= read -r f; do
  [ -n "$f" ] || continue
  case "$f" in
    tests/unsafe/*|tests/probes/*|tests/kernel/*|tests/ffi/*) continue ;;
  esac
  if ! grep -qE '^[[:space:]]*extern ' "$f"; then
    continue
  fi
  if is_allowlisted "$f"; then
    continue
  fi
  if ! grep -q 'unsafe' "$f"; then
    echo "  bare-extern (no unsafe): $f" >&2
    MISS=$((MISS + 1))
  fi
done <<EOF
$(find tests -name '*.x' 2>/dev/null | sort)
EOF

[ "$MISS" -eq 0 ] || die "$MISS business test(s) have extern without unsafe (add unsafe or allowlist)"

# ── 安全路线 §8：业务层 std（非 sys/ffi）零 unsafe ──
echo "=== G-FFI-5: std business layer zero unsafe (excl sys/ffi) ==="
STD_U=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  case "$f" in
    std/sys/*|std/ffi/*) continue ;;
  esac
  if grep -q 'unsafe' "$f"; then
    echo "  std unsafe: $f" >&2
    STD_U=$((STD_U + 1))
  fi
done <<EOF
$(find std -name '*.x' 2>/dev/null | sort)
EOF
[ "$STD_U" -eq 0 ] || die "$STD_U std business .x still use unsafe (should live in std/sys|std/ffi)"

# ── 挂接既有 std wrap ──
chmod +x tests/run-g-ffi-5-std-wrap-gate.sh
./tests/run-g-ffi-5-std-wrap-gate.sh || die "std wrap gate failed"

echo "g-ffi-5 business-no-bare-extern gate OK"
