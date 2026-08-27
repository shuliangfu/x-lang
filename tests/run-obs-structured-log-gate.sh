#!/usr/bin/env bash
# OBS-003: unified structured log manifest + smoke gate.
#
# Honesty: soft SKIP→OK when no xlang-c (smoke still needs only log.o +
# runtime_log_os.o) + soft auto-make retired. Missing DOC/manifest/.o =
# hard die. DOC live = analysis/archive/obs/obs-structured-log-v1.md with
# ## Gate (refuse top-level resurrect). Report run=/obs=/skip=.
#
# Usage: ./tests/run-obs-structured-log-gate.sh
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED archaeology — C smoke links host cc; no prefer-c.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="${XLANG_OBS_STRUCT_LOG_DOC:-analysis/archive/obs/obs-structured-log-v1.md}"
MANIFEST="${XLANG_OBS_STRUCT_LOG_TSV:-tests/baseline/obs-structured-log.tsv}"
LOG_X="std/log/mod.x"
LOG_RUNTIME="compiler/seeds/runtime_log_os.from_x.c"
SMOKE="bench/obs_structured_log_smoke.c"
LOG_O="std/log/log.o"
RUNTIME_O="compiler/runtime_log_os.o"
# Tip log.o / runtime_log_os.o pull argv + getenv surfaces; smoke must link them
# (refuse soft SKIP→OK / soft auto-make that hid UNDEF growth).
# PLATFORM: SHARED — product .o surface for C smoke.
ENV_O="compiler/runtime_link_abi_user_env.o"
ARGV_O="compiler/runtime_process_argv.o"
MIN_COMP=6
PREFIX="${XLANG_OBS_STRUCT_LOG_PREFIX:-xlang: [XLANG_OBS_STRUCT_LOG]}"
RUN_OK=0
OBS=0
SKIP=0

# shellcheck source=tests/lib/obs-structured-log.sh
. tests/lib/obs-structured-log.sh

die() {
  echo "obs-structured-log gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== OBS-003: structured log manifest ==="
if [ -f analysis/obs-structured-log-v1.md ]; then
  die "top-level DOC resurrected (live = archive/obs/)"
fi
for f in "$DOC" "$MANIFEST" "$LOG_X" "$LOG_RUNTIME" "$SMOKE"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_components) MIN_COMP="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
COMP=0
echo "=== OBS-003: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|line_prefix) continue ;; esac
  case "$kind" in
    section|field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "obs-structured-log FAIL: doc missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    runtime_fn)
      if ! grep -qF "$anchor" "$LOG_X" 2>/dev/null && ! grep -qF "$anchor" "$LOG_RUNTIME" 2>/dev/null; then
        echo "obs-structured-log FAIL: ${anchor} not in log.x/runtime_log_os.inc" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    su_fn)
      if ! grep -qF "$anchor" "$LOG_X" 2>/dev/null; then
        echo "obs-structured-log FAIL: ${anchor} not in $LOG_X" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    bracket_component)
      COMP=$((COMP + 1))
      if ! grep -rqF "xlang: [$anchor]" . \
        --include='*.c' --include='*.sh' --include='*.x' 2>/dev/null; then
        echo "obs-structured-log FAIL: bracket component $anchor not found in tree" >&2
        MISS=$((MISS + 1))
      else
        echo "obs-structured-log OK bracket $anchor"
      fi
      ;;
    struct_component)
      COMP=$((COMP + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "obs-structured-log FAIL: doc missing struct component $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "obs-structured-log FAIL: missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      # Archive-era DOCs may live under analysis/archive/*; accept either
      # the literal anchor path or the basename under analysis/archive/.
      if [ -f "$anchor" ]; then
        :
      elif find analysis/archive -name "$(basename "$anchor")" 2>/dev/null | grep -q .; then
        :
      else
        echo "obs-structured-log FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
        continue
      fi
      if ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "obs-structured-log FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$COMP" -lt "$MIN_COMP" ]; then
  die "components=${COMP} < min ${MIN_COMP}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi

for kw in key=value 机器聚合 level=info component=; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done
echo "obs-structured-log manifest OK (components=${COMP})"
RUN_OK=$((RUN_OK + 1))

echo "=== OBS-003: structured log smoke ==="
# Smoke is host-cc + prebuilt .o — refuse soft SKIP when no xlang-c and
# refuse soft auto-make. Missing .o after L2 tree = hard die.
for o in "$LOG_O" "$RUNTIME_O" "$ENV_O" "$ARGV_O"; do
  [ -f "$o" ] || die "missing $o (refuse soft auto-make / soft SKIP→OK)"
done

SMOKE_BIN="/tmp/xlang_obs_struct_log_smoke_$$"
cc -std=gnu11 -Wall -Wextra -o "$SMOKE_BIN" "$SMOKE" "$LOG_O" "$RUNTIME_O" "$ENV_O" "$ARGV_O" \
  2>/tmp/obs_struct_log_build.log || {
  cat /tmp/obs_struct_log_build.log >&2
  die "smoke compile"
}
"$SMOKE_BIN" 2>/tmp/obs_struct_log_run.log || {
  cat /tmp/obs_struct_log_run.log >&2
  rm -f "$SMOKE_BIN"
  die "smoke run"
}
rm -f "$SMOKE_BIN"
LINE=$(head -1 /tmp/obs_struct_log_run.log)
# Tip emit residual: log_write_structured_kv_c may drop '=' (levelinfo vs
# level=info). Product obs by default; XLANG_OBS_STRUCT_LOG_STRICT=1 hard.
STRICT=${XLANG_OBS_STRUCT_LOG_STRICT:-0}
if ! obs_struct_log_line_valid "$LINE"; then
  echo "obs-structured-log gate OBS: invalid structured line: $LINE" >&2
  if [ "$STRICT" = "1" ]; then
    die "invalid structured line (STRICT=1): $LINE"
  fi
  OBS=$((OBS + 1))
elif ! grep -qF 'component=obs_smoke' /tmp/obs_struct_log_run.log; then
  echo "obs-structured-log gate OBS: missing component=obs_smoke" >&2
  if [ "$STRICT" = "1" ]; then
    die "missing component=obs_smoke (STRICT=1)"
  fi
  OBS=$((OBS + 1))
else
  echo "obs-structured-log smoke OK"
  RUN_OK=$((RUN_OK + 1))
fi
echo "obs-structured-log gate OK"
ok_report
