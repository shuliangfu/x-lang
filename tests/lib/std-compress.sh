#!/usr/bin/env bash
# std-compress.sh — STD-007 共享：std.compress 烟测辅助
#
# 用法（source 后）：
#   std_compress_has_api MOD fn
#   std_compress_try_libs          # 尝试 rebuild compress.o（zlib/zstd）
#   std_compress_run_smoke SHU src tag
#   std_compress_probe_roundtrip SHU src  # 打印 ok|skip|fail

# 检查 mod.sx 是否导出指定函数。
std_compress_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# F-04 v7：compress 格式已全 .sx；compress-o-* 为兼容 no-op，runtime 按需 -lz/-lzstd/-lbrotli*。
std_compress_try_libs() {
  (cd compiler && make compress-o-zlib-zstd 2>/dev/null) || true
  echo "std-compress: formats via .sx (F-04 v7, no compress.o)" >&2
  return 0
}

std_compress_native_shu() {
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

std_compress_resolve_shu() {
  if [ -n "${SHUX:-}" ] && std_compress_native_shu "$SHUX"; then
    echo "$SHUX"
    return 0
  fi
  local cand
  for cand in ./compiler/shux-c ./compiler/shux; do
    if std_compress_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

# 编译运行烟测；期望退出码 0。
std_compress_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_compress_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-compress FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/tmp/shux_std_compress_build.log 2>&1; then
    tail -8 /tmp/shux_std_compress_build.log >&2 || true
    rm -f "$exe"
    return 1
  fi
  local ec=0
  "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-compress FAIL: $tag exit=$ec ($src)" >&2
    return 1
  fi
  return 0
}

# 探测往返是否真正执行（exit 0 且压缩 API 非 -1 需结合专用探针文件）。
std_compress_probe_enabled() {
  local shux="$1"
  local src="$2"
  local tag="${3:-probe}"
  local exe="/tmp/shux_std_compress_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    rm -f "$exe"
    echo "fail"
    return 1
  fi
  local ec=0
  "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "fail"
    return 1
  fi
  echo "ok"
  return 0
}
