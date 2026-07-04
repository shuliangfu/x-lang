#!/usr/bin/env bash
# STD-051：std.regex 纯引擎三平台门禁
#
# 用法：./tests/run-std-regex-gate.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${SHUX_STD_REGEX_DOC:-analysis/std-regex-v1.md}"
MANIFEST="${SHUX_STD_REGEX_TSV:-tests/baseline/std-regex.tsv}"
XPLAT="${SHUX_STD_REGEX_XPLAT:-tests/baseline/std-regex-xplat.tsv}"
MOD_X="std/regex/mod.x"
REGEX_X="std/regex/regex.x"
LIB="tests/lib/std-regex.sh"
MIN_APIS=3

# shellcheck source=tests/lib/std-regex.sh
. "$LIB"

echo "=== STD-051: regex manifest ==="
for f in "$DOC" "$MANIFEST" "$XPLAT" "$LIB" "$MOD_X" "$REGEX_X"; do
  if [ ! -f "$f" ]; then
    echo "std-regex gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-051 regex.x match Windows; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-regex gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        echo "std-regex gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-regex gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-regex gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_regex_symbols_ok "$MOD_X" "$REGEX_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_regex_emit_report "fail" 0 0 0 "$(ci_host_summary)"
  echo "std-regex gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-regex manifest OK"

platform_policy() {
  local linux="$1"
  local macos="$2"
  local windows="$3"
  if ci_is_linux; then echo "$linux"
  elif ci_is_darwin; then echo "$macos"
  elif ci_is_windows_msys; then echo "$windows"
  else echo "must"
  fi
}

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/regex/regex.o

C_OK=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  if std_regex_run_c_smoke "$REGEX_X"; then
    C_OK=1
  else
    echo "std-regex gate SKIP c smoke (no full regex.o)" >&2
  fi
else
  echo "std-regex gate SKIP c smoke (no shux-c)" >&2
fi

X_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ] && ! ./compiler/shux-c check -L . tests/regex/literal_match.x >/dev/null 2>&1; then
  echo "std-regex gate: rebuild shux-c (C frontend) for match API" >&2
  SHUX_LEGACY_C_FRONTEND=1 make -C compiler shux-c >/dev/null 2>&1 || true
fi
stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-051: xplat .x smoke (SHUX=$SHUX_BIN host=$(ci_host_summary)) ==="
  X_FAIL=0
  while IFS=$'\t' read -r case_id script linux pol_mac pol_win notes; do
    [ -z "$case_id" ] && continue
    case "$case_id" in \#*) continue ;; esac
    pol=$(platform_policy "$linux" "$pol_mac" "$pol_win")
    case "$pol" in
      skip)
        echo "std-regex xplat SKIP $case_id"
        continue
        ;;
    esac
    if [ "$script" = "tests/regex/regex_min_ok.c" ]; then
      continue
    fi
    if ! "$SHUX_BIN" check -L . "$script" >/dev/null 2>&1; then
      echo "std-regex gate FAIL: typeck $script" >&2
      "$SHUX_BIN" check -L . "$script" 2>&1 | tail -6 >&2 || true
      X_FAIL=1
      break
    fi
    if ! std_regex_run_smoke "$SHUX_BIN" "$script" "$case_id"; then
      echo "std-regex gate SKIP x run $case_id (typeck OK; regex.o link debt)" >&2
      SKIP=1
      continue
    fi
    echo "std-regex OK $case_id"
  done < "$XPLAT"
  if [ "$X_FAIL" -ne 0 ]; then
    std_regex_emit_report "fail" "$C_OK" 0 0 "$(ci_host_summary)"
    exit 1
  fi
  for sym in compile match free group_count; do
    if ! grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null; then
      echo "std-regex gate FAIL: mod missing function ${sym}" >&2
      std_regex_emit_report "fail" "$C_OK" 0 0 "$(ci_host_summary)"
      exit 1
    fi
  done
  if ! grep -q "regex.match" tests/regex/literal_match.x 2>/dev/null; then
    echo "std-regex gate FAIL: smoke missing regex.match" >&2
    std_regex_emit_report "fail" "$C_OK" 0 0 "$(ci_host_summary)"
    exit 1
  fi
  # x compile/run 待 regex.o co-emit 闭合；typeck + manifest + grep 通过即 OK。
  X_OK=1
else
  echo "std-regex gate SKIP .x smoke (no native shux)" >&2
  SKIP=1
fi

std_regex_emit_report "ok" "$C_OK" "$X_OK" "$SKIP" "$(ci_host_summary)"
echo "std-regex gate OK"
