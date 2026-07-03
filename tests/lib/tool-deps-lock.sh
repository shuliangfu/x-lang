#!/usr/bin/env bash
# tool-deps-lock.sh — TOOL-008 共享：锁文件哈希与路径辅助
#
# 用法（source 后）：
#   tool_deps_sha256_file PATH
#   tool_deps_relpath_from_repo ABS_PATH [REPO_ROOT]

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"

# 计算文件 sha256（小写 hex）；Linux 用 sha256sum，macOS 用 shasum。
tool_deps_sha256_file() {
  local f="$1"
  if [ ! -f "$f" ]; then
    return 1
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$f" 2>/dev/null | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" 2>/dev/null | awk '{print $1}'
  else
    return 1
  fi
}

# 将绝对路径转为相对仓库根的路径。
tool_deps_relpath_from_repo() {
  local abs="$1"
  local repo="${2:-$ROOT}"
  python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$abs" "$repo"
}

# 从 manifest 解析 lib_roots 与 requires（输出到变量由调用方设置）。
tool_deps_read_manifest() {
  local manifest="$1"
  local manifest_dir
  manifest_dir="$(cd "$(dirname "$manifest")" && pwd)"
  MANIFEST_DIR="$manifest_dir"
  ROOTS=()
  REQUIRES=()
  PKG_NAME=""
  while IFS=$'\t' read -r kind key val _notes; do
    [ -z "${kind:-}" ] && continue
    case "$kind" in \#*) continue ;; esac
    case "$kind" in
      meta)
        if [ "$key" = "name" ]; then PKG_NAME="$val"; fi
        ;;
      lib_root)
        case "$val" in
          /*) ROOTS+=("$val") ;;
          *) ROOTS+=("$manifest_dir/$val") ;;
        esac
        ;;
      require) REQUIRES+=("$key") ;;
    esac
  done < "$manifest"
  if [ "${#ROOTS[@]}" -eq 0 ]; then
    ROOTS+=("$manifest_dir")
  fi
}

# 在 lib_roots 中解析 import，打印绝对路径。
tool_deps_resolve_abs() {
  local import_path="$1"
  # shellcheck source=tests/lib/tool-pkgmgr.sh
  . "$ROOT/tests/lib/tool-pkgmgr.sh"
  local lr
  for lr in "${ROOTS[@]}"; do
    if tool_pkg_resolve_import "$lr" "$import_path" >/dev/null 2>&1; then
      tool_pkg_resolve_import "$lr" "$import_path"
      return 0
    fi
  done
  return 1
}
