#!/usr/bin/env bash
# std.net gate: Ipv4Addr / TcpStream / TcpListener / UDP batch buf —
# honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … xlang-c … || true`) + soft
# default `./compiler/xlang` + soft gcc fallback when xlang_asm -o fails
# (false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c / soft gcc fallback). Product -o main +
# udp_batch_buf exit0 = hard run. ensure_std_c_o / ensure_runtime_* left
# intact (leave ensure_std family; only soft compiler make + soft fallback
# retired). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-net.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh

PREFIX="${XLANG_NET_PREFIX:-xlang: [XLANG_NET]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-180}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "net test FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in compiler/xlang_asm compiler/xlang-c compiler/xlang; do
    abs="$root/$cand"
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

# Product -o then run exit0. Soft gcc fallback retired — product link miss = hard die.
run_net_case() {
  local label="$1" src="$2"
  local exe="/tmp/xlang_net_${label}_$$" log="/tmp/xlang_net_${label}_$$.log" o_ec r_ec
  [ -f "$src" ] || die "missing $src"
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$label product -o timeout"
  elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    die "$label product -o failed (ec=$o_ec; soft gcc fallback retired); $(tail -8 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
  r_ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$r_ec" -eq 124 ]; then
    die "$label run timeout"
  elif [ "$r_ec" -ne 0 ]; then
    die "$label expected exit 0, got $r_ec"
  fi
  RUN_OK=$((RUN_OK + 1))
  echo "net OK: $label exit=0"
}

echo "=== net gate (prefer asm; hard; refuse soft auto-make / soft gcc fallback / soft SKIP→OK) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# Leave ensure_std family: still ensure dependent .o for net link contract.
# Refuse soft auto-make of xlang-c itself (above).
ensure_std_c_o ../std/net/net.o || die "ensure_std_c_o net.o failed"
ensure_std_c_o ../std/thread/thread.o || die "ensure_std_c_o thread.o failed"
ensure_runtime_net_udp_batch_o || die "ensure_runtime_net_udp_batch_o failed"
ensure_runtime_net_workers_o || die "ensure_runtime_net_workers_o failed"
ensure_runtime_asm_io_stubs_o || die "ensure_runtime_asm_io_stubs_o failed"
ensure_runtime_panic_o || die "ensure_runtime_panic_o failed"
ensure_runtime_process_argv_o || die "ensure_runtime_process_argv_o failed"
ensure_std_c_o ../std/random/random.o || die "ensure_std_c_o random.o failed"

run_net_case "main" "tests/net/main.x"
run_net_case "udp_batch_buf" "tests/net/udp_batch_buf.x"

echo "net test OK"
ok_report
