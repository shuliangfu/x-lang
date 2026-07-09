#!/usr/bin/env bash
# G-FFI-5：业务 tests 无「裸 extern 调用」——含 extern 的业务测试须有 unsafe 包裹调用，
# 或列入 tests/baseline/g-ffi-5-business-extern-allowlist.tsv。
#
# 排除：tests/unsafe、tests/probes、tests/kernel、tests/ffi（专项/探针）。
#
# 安全路线 §8「业务层零 unsafe」可验证策略：
#   - 默认：freeze 基线 tests/baseline/g-ffi-5-std-business-unsafe-baseline.tsv
#     · 基线内文件允许仍含 unsafe（既有债务）
#     · 基线外 std 业务 .x 新增 unsafe → 硬失败（债务不得扩张）
#   - SHUX_G_FFI5_STRICT_ZERO_UNSAFE=1：要求 std 业务层 unsafe 计数为 0（终局）
#
# 用法：./tests/run-g-ffi-5-business-no-bare-extern-gate.sh
#   SHUX_G_FFI5_FAIL=1  — 失败硬退出（CI）
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_G_FFI5_FAIL:-0}
ALLOW="tests/baseline/g-ffi-5-business-extern-allowlist.tsv"
STD_BASE="tests/baseline/g-ffi-5-std-business-unsafe-baseline.tsv"
die() {
  echo "g-ffi-5 business FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== G-FFI-5: business tests no bare extern calls ==="
[ -f "$ALLOW" ] || die "missing $ALLOW"
[ -f tests/run-g-ffi-5-std-wrap-gate.sh ] || die "missing std wrap gate"
[ -f "$STD_BASE" ] || die "missing $STD_BASE"

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
echo "g-ffi-5 business tests: no bare extern OK"

# ── 安全路线 §8：std **业务层** unsafe 债务冻结 / 终局清零 ──
# 基础设施边界（syscall/FFI/OS/IO 底座）允许 unsafe，不计入业务债：
#   sys, ffi, heap, crypto, dynlib, process, thread, sync, atomic, channel,
#   net, http, fs, path, runtime, log, time, random, env, backtrace, compress, db, sqlite
echo "=== G-FFI-5: std business unsafe policy (excl infra boundary) ==="
is_infra_boundary() {
  case "$1" in
    std/sys/*|std/ffi/*|std/heap/*|std/crypto/*|std/dynlib/*|std/process/*| \
    std/thread/*|std/sync/*|std/atomic/*|std/channel/*|std/net/*|std/http/*| \
    std/fs/*|std/path/*|std/runtime/*|std/log/*|std/time/*|std/random/*| \
    std/env/*|std/backtrace/*|std/compress/*|std/db/*|std/sqlite/*) return 0 ;;
    *) return 1 ;;
  esac
}

BASE_TMP=$(mktemp)
CUR_TMP=$(mktemp)
trap 'rm -f "$BASE_TMP" "$CUR_TMP"' EXIT

# shellcheck disable=SC2162
while IFS=$'\t' read tid path rest; do
  [ -z "${tid:-}" ] && continue
  case "$tid" in \#*) continue ;; esac
  [ -n "$path" ] || continue
  if is_infra_boundary "$path"; then
    continue
  fi
  printf '%s\n' "$path"
done < "$STD_BASE" | sort -u > "$BASE_TMP"
BASE_N=$(wc -l < "$BASE_TMP" | tr -d ' ')

: > "$CUR_TMP"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if is_infra_boundary "$f"; then
    continue
  fi
  if grep -q 'unsafe' "$f"; then
    printf '%s\n' "$f" >> "$CUR_TMP"
  fi
done <<EOF
$(find std -name '*.x' 2>/dev/null | sort)
EOF
CUR_N=$(wc -l < "$CUR_TMP" | tr -d ' ')
echo "g-ffi-5 §8: current unsafe files=$CUR_N baseline=$BASE_N"

if [ "${SHUX_G_FFI5_STRICT_ZERO_UNSAFE:-0}" = "1" ]; then
  if [ "$CUR_N" -ne 0 ]; then
    while IFS= read -r f; do
      echo "  std unsafe (strict zero): $f" >&2
    done < "$CUR_TMP"
    die "$CUR_N std business .x still use unsafe (STRICT_ZERO_UNSAFE=1)"
  fi
  echo "g-ffi-5 §8 STRICT zero unsafe OK"
else
  NEW=0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if ! grep -qxF "$f" "$BASE_TMP"; then
      echo "  NEW std unsafe (not in baseline): $f" >&2
      NEW=$((NEW + 1))
    fi
  done < "$CUR_TMP"
  [ "$NEW" -eq 0 ] || die "$NEW new std business .x gained unsafe (shrink baseline only when clearing debt)"
  CLEARED=0
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    if [ -f "$p" ] && ! grep -q 'unsafe' "$p"; then
      echo "  progress: baseline path cleared unsafe: $p"
      CLEARED=$((CLEARED + 1))
    fi
  done < "$BASE_TMP"
  echo "g-ffi-5 §8 freeze OK (debt frozen; cleared_scan=$CLEARED; STRICT_ZERO_UNSAFE=1 for end-state)"
fi

# ── 挂接既有 std wrap ──
chmod +x tests/run-g-ffi-5-std-wrap-gate.sh
./tests/run-g-ffi-5-std-wrap-gate.sh || die "std wrap gate failed"

echo "g-ffi-5 business-no-bare-extern gate OK"
