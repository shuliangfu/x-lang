#!/usr/bin/env bash
# D-05 v1：日常发布以 compiler/shux 为单一入口（不依赖 shux-c 冷启动）。
#
# 用法：./tests/run-d05-single-shux-release-gate.sh
# 环境：
#   SHUX_D05_FAIL=1           — 失败时硬退出
#   SHUX_D05_MANIFEST_ONLY=1  — 仅 manifest
#   SHUX=./compiler/shux      — 默认发布二进制
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_D05_FAIL:-0}
DOC="analysis/phase-d-d05-v1.md"
MANIFEST="tests/baseline/d05-single-shux-release.tsv"
MF="compiler/Makefile"
BOOT="compiler/bootstrap.sh"
SHUX_BIN="${SHUX:-./compiler/shux}"
SHUX_ASM="./compiler/shux_asm"

die() {
  echo "d05 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

# 探测二进制是否为当前宿主可执行格式。
d05_native_exe() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

echo "=== D-05: single shux release (v1) ==="
for f in "$DOC" "$MANIFEST" "$MF" "$BOOT" README.md compiler/docs/SELFHOST.md; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'D-05 v1' "$DOC" || die "doc missing D-05 v1 marker"

grep -q 'bootstrap-driver-bstrict' "$MF" || die "Makefile missing bootstrap-driver-bstrict"
grep -q 'cp -f shux_asm $(TARGET)' "$MF" || grep -q 'cp -f shux_asm' "$MF" || die "Makefile missing shux_asm -> shux copy"
grep -q 'bootstrap-driver-bstrict' README.md || die "README missing bootstrap-driver-bstrict"
grep -q 'D-05' compiler/docs/SELFHOST.md || die "SELFHOST missing D-05"

# manifest gate_ref
MISS=0
while IFS=$'\t' read -r item_id _layer anchor check_type _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in gate_ref)
    [ -f "$anchor" ] || { echo "d05 manifest missing: $anchor" >&2; MISS=$((MISS + 1)); }
    ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest gate_ref missing"

if [ "${SHUX_D05_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "d05 single-shux-release gate OK (manifest only)"
  exit 0
fi

# 优先使用 bstrict 产物
if [ -x "$SHUX_ASM" ] && d05_native_exe "$SHUX_ASM"; then
  if [ -x "$SHUX_BIN" ] && d05_native_exe "$SHUX_BIN"; then
    :
  else
    SHUX_BIN="$SHUX_ASM"
  fi
fi

if ! d05_native_exe "$SHUX_BIN"; then
  echo "d05 single-shux-release gate: SKIP smoke (no native shux/shux_asm; manifest OK)"
  exit 0
fi

# ── shux 须具备 seed/.x 能力（shux-c 纯 C 链不具备或较弱）──
if ! "$SHUX_BIN" --help 2>/dev/null | grep -q '\-\-lsp'; then
  echo "d05 note: $SHUX_BIN missing --lsp (may need bootstrap-driver-seed first)" >&2
fi
if ! "$SHUX_BIN" --help 2>/dev/null | grep -qE '\-backend|backend'; then
  die "$SHUX_BIN missing -backend in --help"
fi

# ── 日常 check 不经过 shux-c ──
SMOKE="tests/c07/minimal_return42.x"
[ -f "$SMOKE" ] || SMOKE="examples/hello.x"
unset SHUX_LINK_SHUX
if ! "$SHUX_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
  "$SHUX_BIN" check -L . "$SMOKE" 2>&1 | tail -8 >&2 || true
  die "shux check failed without SHUX_LINK_SHUX ($SMOKE)"
fi
echo "d05 OK: $SHUX_BIN check $SMOKE (no shux-c link fallback)"

# 若 shux 与 shux_asm 同存且均为 native，发布链上宜一致（make shux_asm / bstrict cp）。
# 默认仅 note；硬失败需 SHUX_D05_REQUIRE_ASM_HASH=1（Linux 发版 CI 可开）。
if [ -x "$SHUX_ASM" ] && d05_native_exe "$SHUX_ASM" && [ -x "./compiler/shux" ] && d05_native_exe "./compiler/shux"; then
  if command -v shasum >/dev/null 2>&1; then
    H1=$(shasum -a 256 "./compiler/shux" | awk '{print $1}')
    H2=$(shasum -a 256 "$SHUX_ASM" | awk '{print $1}')
    if [ "$H1" != "$H2" ]; then
      echo "d05 note: shux != shux_asm hash (sync: make -C compiler shux_asm 或 cp shux shux_asm)" >&2
      if [ "${SHUX_D05_REQUIRE_ASM_HASH:-0}" = "1" ]; then
        die "shux and shux_asm differ (SHUX_D05_REQUIRE_ASM_HASH=1)"
      fi
    else
      echo "d05 OK: compiler/shux matches shux_asm (release binary)"
    fi
  fi
fi

echo "d05 single-shux-release gate OK (daily SHUX=$SHUX_BIN, no shux-c cold start required)"
