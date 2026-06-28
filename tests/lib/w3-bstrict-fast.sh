#!/usr/bin/env bash
# w3-bstrict-fast.sh — W3 bootstrap-gold 在 pinned seed 上的 L5 效率策略
#
# pinned seed / postlink 回退时，123 项 bstrict 多数 -o/asm 无信号且易挂起；
# FAST 模式只跑有代表性的子集，其余秒级 SKIP，配合 per-script timeout + wall clock。

# 判断 script 是否在 W3 FAST 白名单内（应实际执行）。
# 参数：run-xxx.sh  basename
w3_bstrict_fast_should_run() {
  case "$1" in
    run-lexer.sh|run-typeck.sh|run-check.sh|run-parser.sh|\
    run-struct.sh|run-return-value.sh|run-return-expr.sh|\
    run-for.sh|run-if-expr.sh|run-match.sh|run-enum.sh|\
    run-scope-borrow-gate.sh|run-al06-gate.sh|\
    run-type-borrow-conflict-gate.sh|run-i64-ctfe-gate.sh|\
    run-safe-unsafe-audit-gate.sh|run-ub.sh|\
    run-lexer-bounds-gate.sh|run-layout-overflow-gate.sh|\
    run-link-hardening-gate.sh|run-signed-overflow-gate.sh)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# 超时或 wall clock 截止后清理孤儿 shux，避免 fork 风暴占满 Codespace。
w3_bstrict_cleanup_orphans() {
  pkill -f '[/ ]compiler/shux' 2>/dev/null || true
  pkill -f '[/ ]compiler/shux_asm' 2>/dev/null || true
  pkill -f '[/ ]compiler/shux-c' 2>/dev/null || true
  sleep 1
}
