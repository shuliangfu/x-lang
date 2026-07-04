#!/usr/bin/env bash
# SAFE-006：数据竞争检测实验线 runner
#
# 用法：
#   ./tests/run-safe-race-detect.sh
#   SHUX_RACE_PROBE=1 ./tests/run-safe-race-detect.sh
set -e
cd "$(dirname "$0")/.."

MANIFEST="${SHUX_RACE_MANIFEST:-tests/baseline/safe-race-detect.tsv}"
DO_PROBE=0
[ "${SHUX_RACE_PROBE:-0}" = "1" ] && DO_PROBE=1

# shellcheck source=tests/lib/safe-race.sh
. tests/lib/safe-race.sh

native_shu() {
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

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

echo "=== SAFE-006: race detect experimental line ==="
make -C compiler -q 2>/dev/null || make -C compiler

CASES_OK=0
CASES_FAIL=0
PROBE_STATUS="skip"

if [ -z "$SHUX_BIN" ]; then
  echo "safe-race-detect SKIP cases (no native shux)" >&2
else
  while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*|track_*|probe|lib|runner|gate|workflow|cross_*) continue ;; esac
    case "$kind" in
      case)
        echo "── $item_id ($src) ──"
        if safe_race_run_x "$SHUX_BIN" "$src" "$item_id"; then
          CASES_OK=$((CASES_OK + 1))
        else
          CASES_FAIL=$((CASES_FAIL + 1))
        fi
        ;;
    esac
  done < "$MANIFEST"
fi

if [ "$DO_PROBE" -eq 1 ]; then
  if safe_race_tsan_ok; then
    echo "── race_probe (TSAN) ──"
    if safe_race_run_probe; then
      PROBE_STATUS="ok"
    else
      prc=$?
      if [ "$prc" -eq 2 ]; then
        PROBE_STATUS="skip"
      else
        PROBE_STATUS="fail"
        CASES_FAIL=$((CASES_FAIL + 1))
      fi
    fi
  else
    echo "safe-race probe SKIP: no TSAN toolchain" >&2
    PROBE_STATUS="skip"
  fi
fi

if [ "$CASES_FAIL" -gt 0 ]; then
  safe_race_emit_report "fail" "$CASES_OK" "$CASES_FAIL" "$PROBE_STATUS"
  echo "safe-race-detect FAIL" >&2
  exit 1
fi

safe_race_emit_report "ok" "$CASES_OK" "$CASES_FAIL" "$PROBE_STATUS"
echo "safe-race-detect OK"
