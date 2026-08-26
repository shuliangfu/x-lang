#!/usr/bin/env bash
# boot-force-stub.sh — BOOT-010 force_stub helpers
#
# Usage (after source):
#   boot010_want_exit REG_SRC          # echo expected run exit; 1 if unknown
#   boot010_link_run_one XLANG SRC OUT WANT
#   boot010_emit_report status link_ok skip
#
# honesty 2026-08-26: prefer asm; link+run matrix reg_src hard; check_only
# observational; no soft SKIP→OK; report link=/skip=.
# PLATFORM: SHARED archaeology.

BOOT010_PREFIX="${XLANG_BOOT010_PREFIX:-xlang: [XLANG_BOOT010]}"

# Map matrix regression_src → expected process exit (product link+run).
# Authority for padding want=2 = tests/baseline/lang-unsafe-api.tsv U1 row.
# PLATFORM: SHARED — exits are language semantics, not host-specific.
boot010_want_exit() {
  case "$1" in
    tests/if-expr/simple.x) echo 10 ;;
    tests/if-expr/no_else.x) echo 42 ;;
    tests/float/f32_f64.x) echo 0 ;;
    tests/unsafe/allow_padding_ok.x) echo 2 ;;
    *) return 1 ;;
  esac
}

# Try product -o link and run; 0=ok, 2=link fail, 1=run fail / wrong exit.
boot010_link_run_one() {
  local xlang="$1"
  local src="$2"
  local out="$3"
  local want="$4"
  if [ ! -f "$src" ]; then
    echo "boot-force-stub FAIL: missing $src" >&2
    return 1
  fi
  if ! "$xlang" -L . "$src" -o "$out" >/dev/null 2>&1; then
    echo "boot-force-stub FAIL: link $src" >&2
    return 2
  fi
  local ex=0
  "$out" >/dev/null 2>&1 || ex=$?
  if [ "$ex" -ne "$want" ]; then
    echo "boot-force-stub FAIL: $src run exit=$ex want=$want" >&2
    return 1
  fi
  return 0
}

# Emit structured report line: link=/skip=.
boot010_emit_report() {
  local status="$1"
  local link_ok="$2"
  local skip="$3"
  echo "${BOOT010_PREFIX} status=${status} link=${link_ok} skip=${skip}"
}
