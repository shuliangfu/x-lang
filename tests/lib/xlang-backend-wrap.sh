#!/usr/bin/env bash
# xlang-backend-wrap.sh — 将 XLANG_BACKEND_WRAP_ARGS（如 -backend c）注入到真实编译器调用。
# 由 bootstrap-link-xlang.sh 在 Darwin 等宿主上设置 RUN_XLANG 为本包装。
#
# 【Why 根源】Darwin arm64 产品 -o 可执行须 -backend c（asm CG002 empty text）。
# 但把 -backend c 注入到 *所有* 调用会炸：
#   - `fmt` / `check` / `explain` 等子命令不该改 backend
#   - 无 -o 的烟测（`xlang file.x`）在 -backend c 路径上 stack overflow（chkstk）
# 仅当 argv 含 `-o`（产物链接/编译）时注入 backend。
set -e
REAL="${XLANG_BACKEND_WRAP_REAL:-./compiler/xlang_asm}"
ARGS=("$@")
need_backend=0
# 子命令在首位时不注入
case "${ARGS[0]:-}" in
  fmt|check|explain|test|build|run|help|-h|--help)
    need_backend=0
    ;;
  *)
    i=0
    while [ "$i" -lt "${#ARGS[@]}" ]; do
      if [ "${ARGS[$i]}" = "-o" ]; then
        need_backend=1
        break
      fi
      i=$((i + 1))
    done
    ;;
esac
if [ "$need_backend" = "1" ] && [ -n "${XLANG_BACKEND_WRAP_ARGS:-}" ]; then
  # shell-split backend args (e.g. "-backend c")
  # shellcheck disable=SC2086
  exec "$REAL" ${XLANG_BACKEND_WRAP_ARGS} "${ARGS[@]}"
fi
exec "$REAL" "${ARGS[@]}"
