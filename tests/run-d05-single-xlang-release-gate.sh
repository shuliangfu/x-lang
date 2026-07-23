#!/usr/bin/env bash
# D-05 v1：日常发布以 compiler/xlang 为单一入口（不依赖 xlang-c 冷启动）。
#
# 用法：./tests/run-d05-single-xlang-release-gate.sh
# 环境：
#   XLANG_D05_FAIL=1           — 失败时硬退出
#   XLANG_D05_MANIFEST_ONLY=1  — 仅 manifest
#   XLANG=./compiler/xlang      — 默认发布二进制
set -e
cd "$(dirname "$0")/.."

FAIL=${XLANG_D05_FAIL:-0}
DOC="analysis/phase-d-d05-v1.md"
MANIFEST="tests/baseline/d05-single-xlang-release.tsv"
MF="compiler/Makefile"
BOOT="compiler/bootstrap.sh"
XLANG_BIN="${XLANG:-./compiler/xlang}"
XLANG_ASM="./compiler/xlang_asm"

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

echo "=== D-05: single xlang release (v1) ==="
for f in "$DOC" "$MANIFEST" "$MF" "$BOOT" README.md compiler/docs/SELFHOST.md; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'D-05 v1' "$DOC" || die "doc missing D-05 v1 marker"

grep -q 'bootstrap-driver-bstrict' "$MF" || die "Makefile missing bootstrap-driver-bstrict"
grep -q 'cp -f xlang_asm $(TARGET)' "$MF" || grep -q 'cp -f xlang_asm' "$MF" || die "Makefile missing xlang_asm -> xlang copy"
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

if [ "${XLANG_D05_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "d05 single-xlang-release gate OK (manifest only)"
  exit 0
fi

# 优先使用 bstrict 产物
if [ -x "$XLANG_ASM" ] && d05_native_exe "$XLANG_ASM"; then
  if [ -x "$XLANG_BIN" ] && d05_native_exe "$XLANG_BIN"; then
    :
  else
    XLANG_BIN="$XLANG_ASM"
  fi
fi

if ! d05_native_exe "$XLANG_BIN"; then
  echo "d05 single-xlang-release gate: SKIP smoke (no native xlang/xlang_asm; manifest OK)"
  exit 0
fi

# ── xlang 须具备 seed/.x 能力（xlang-c 纯 C 链不具备或较弱）──
HELP_OUT=$("$XLANG_BIN" --help 2>&1 || true)
if ! printf '%s' "$HELP_OUT" | grep -q '\-\-lsp'; then
  echo "d05 note: $XLANG_BIN missing --lsp in --help (may need bootstrap-driver-seed)" >&2
fi
# 部分 B-strict 链路上 --help 为空（driver_print_usage 弱桩/未链入）；用 -backend 行为探测兜底
if ! printf '%s' "$HELP_OUT" | grep -qE '\-backend|backend'; then
  if "$XLANG_BIN" -backend asm check -L . tests/c07/minimal_return42.x >/dev/null 2>&1 \
    || "$XLANG_BIN" -backend asm check -L . examples/hello.x >/dev/null 2>&1; then
    echo "d05 note: --help empty/missing -backend text; -backend asm check OK" >&2
  else
    die "$XLANG_BIN missing -backend (help empty and -backend asm check failed)"
  fi
fi

# ── 日常 check 不经过 xlang-c ──
SMOKE="tests/c07/minimal_return42.x"
[ -f "$SMOKE" ] || SMOKE="examples/hello.x"
unset XLANG_LINK_XLANG
if ! "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
  "$XLANG_BIN" check -L . "$SMOKE" 2>&1 | tail -8 >&2 || true
  die "xlang check failed without XLANG_LINK_XLANG ($SMOKE)"
fi
echo "d05 OK: $XLANG_BIN check $SMOKE (no xlang-c link fallback)"

# 若 xlang 与 xlang_asm 同存且均为 native，发布链上宜一致（make xlang_asm / bstrict cp）。
# 默认仅 note；硬失败需 XLANG_D05_REQUIRE_ASM_HASH=1（Linux 发版 CI 可开）。
if [ -x "$XLANG_ASM" ] && d05_native_exe "$XLANG_ASM" && [ -x "./compiler/xlang" ] && d05_native_exe "./compiler/xlang"; then
  if command -v shasum >/dev/null 2>&1; then
    H1=$(shasum -a 256 "./compiler/xlang" | awk '{print $1}')
    H2=$(shasum -a 256 "$XLANG_ASM" | awk '{print $1}')
    if [ "$H1" != "$H2" ]; then
      echo "d05 note: xlang != xlang_asm hash (sync: make -C compiler xlang_asm 或 cp xlang xlang_asm)" >&2
      if [ "${XLANG_D05_REQUIRE_ASM_HASH:-0}" = "1" ]; then
        die "xlang and xlang_asm differ (XLANG_D05_REQUIRE_ASM_HASH=1)"
      fi
    else
      echo "d05 OK: compiler/xlang matches xlang_asm (release binary)"
    fi
  fi
fi

echo "d05 single-xlang-release gate OK (daily XLANG=$XLANG_BIN, no xlang-c cold start required)"
