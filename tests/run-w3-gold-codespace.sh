#!/usr/bin/env bash
# run-w3-gold-codespace.sh — Codespace 上跑 bootstrap-gold inner 的推荐入口
#
# 设计目标：
#   - 单实例：禁止叠多个 nohup/后台 gate（避免 fork 风暴）
#   - 有界：整链 wall timeout（默认 45min），L5/P1 子段另有上限
#   - 可观测：tee 写 log + 心跳；非 TTY 下 shux -o 不挂死
#
# 用法（Codespace 仓库根）：
#   ./tests/run-w3-gold-codespace.sh              # 全链
#   SHUX_W3_RESUME_FROM=l5 ./tests/run-w3-gold-codespace.sh   # 仅 L5+P1
#   SHUX_W3_RESUME_FROM=p1 ./tests/run-w3-gold-codespace.sh   # 仅 P1（L5 已过）
#   ./tests/run-w3-gold-codespace.sh status     # 查看是否在跑
#   ./tests/run-w3-gold-codespace.sh stop       # 停止 gate + 清理 shux

set -euo pipefail
cd "$(dirname "$0")/.."

LOG="${SHUX_W3_GOLD_LOG:-logs/gold-inner.log}"
PIDFILE="${SHUX_W3_GOLD_PIDFILE:-logs/gold-inner.pid}"
WALL_SEC="${SHUX_W3_GOLD_WALL_SEC:-2700}"

mkdir -p logs

# 清理孤儿 shux 进程（Codespace fork 上限易触顶）。
_w3_cleanup_shux() {
  pkill -f '[/ ]compiler/shux' 2>/dev/null || true
  pkill -f 'run-linux-a09-a11-gate-inner' 2>/dev/null || true
  sleep 1
}

# 打印 gate 是否在跑及日志尾部。
_w3_status() {
  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo "w3-gold: RUNNING pid=$(cat "$PIDFILE") log=$LOG"
  else
    echo "w3-gold: NOT running (stale pidfile ignored)"
    rm -f "$PIDFILE"
  fi
  if [ -f "$LOG" ]; then
    echo "--- tail $LOG ---"
    tail -20 "$LOG"
    grep -E 'DONE|EXIT=|W3 best-effort complete|wall=' "$LOG" 2>/dev/null | tail -5 || true
  fi
}

# 停止正在跑的 gate。
_w3_stop() {
  if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null || true
    rm -f "$PIDFILE"
  fi
  _w3_cleanup_shux
  echo "w3-gold: stopped"
}

case "${1:-run}" in
  status) _w3_status; exit 0 ;;
  stop) _w3_stop; exit 0 ;;
  run) ;;
  *) echo "usage: $0 [run|status|stop]" >&2; exit 2 ;;
esac

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "w3-gold: already running pid=$(cat "$PIDFILE"); use '$0 status' or '$0 stop'" >&2
  exit 1
fi

ulimit -s 65532 2>/dev/null || true
ulimit -n 8192 2>/dev/null || true
_w3_cleanup_shux

echo "w3-gold: starting wall=${WALL_SEC}s log=$LOG resume=${SHUX_W3_RESUME_FROM:-full}"
rm -f "$LOG"

# 整链包在 timeout 内；stdout 经 tee|cat Drain（nohup 重定向同根因）。
nohup bash -c "
  set -eo pipefail
  if command -v timeout >/dev/null 2>&1; then
    timeout -k 60 ${WALL_SEC} env SHUX_W3_RESUME_FROM=\"${SHUX_W3_RESUME_FROM:-}\" \
      ./tests/run-linux-a09-a11-gate-inner.sh 2>&1 | tee -a \"${LOG}\" | cat >/dev/null
  else
    env SHUX_W3_RESUME_FROM=\"${SHUX_W3_RESUME_FROM:-}\" \
      ./tests/run-linux-a09-a11-gate-inner.sh 2>&1 | tee -a \"${LOG}\" | cat >/dev/null
  fi
  echo EXIT=\$? >> \"${LOG}\"
" >logs/gold-nohup.out 2>&1 &

echo $! >"$PIDFILE"
echo "w3-gold: pid=$(cat "$PIDFILE") — poll: $0 status"
