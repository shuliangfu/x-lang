#!/usr/bin/env bash
# LANG-002：import 解析跨平台一致性门禁
#
# 同一套 .su / run-*.sh 在 Linux / macOS / Windows MSYS 须行为一致。
# 用法：./tests/run-lang-import-gate.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

MATRIX="${SHU_LANG_IMPORT_TSV:-tests/baseline/lang-import-crossplatform.tsv}"

native_shu() {
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

echo "=== LANG-002: import cross-platform manifest ==="
for f in \
  analysis/lang-import-v1-rfc.md \
  "$MATRIX" \
  tests/import/main.su \
  tests/import/missing_module.su \
  tests/parser/import_std_async.su; do
  if [ ! -f "$f" ]; then
    echo "lang-import gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "lang-import manifest OK (host=$(ci_host_summary))"

make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler ../std/async/scheduler.o -q 2>/dev/null \
  || make -C compiler ../std/async/scheduler.o

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHU_BIN" ]; then
  echo "lang-import gate SKIP bench (no native shu)" >&2
  exit 0
fi

# 链接优先 shu-c（与 run-stdlib-import 一致，跨平台稳定）。
LINK_SHU="$SHU_BIN"
if [ -x ./compiler/shu-c ] && native_shu ./compiler/shu-c; then
  LINK_SHU=./compiler/shu-c
fi

run_su_case() {
  local script="$1"
  local want_ec="${2:-0}"
  local src=""
  if [ -f "tests/import/${script}" ]; then
    src="tests/import/${script}"
  elif [ -f "tests/parser/${script}" ]; then
    src="tests/parser/${script}"
  else
    echo "lang-import FAIL: missing ${script}" >&2
    return 1
  fi
  local out="/tmp/shu_lang_import_${script%.su}"
  if ! "$LINK_SHU" -L . "$src" -o "$out" >/tmp/shu_lang_import_compile.log 2>&1; then
    cat /tmp/shu_lang_import_compile.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "$want_ec" ]; then
    echo "lang-import FAIL ${script}: exit=$ec want=$want_ec" >&2
    return 1
  fi
  return 0
}

FAILS=0
echo "=== LANG-002: import smoke (CHECK/LINK via $(basename "$LINK_SHU")) ==="

while IFS=$'\t' read -r case_id script policy want_ec notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in
    \#*) continue ;;
  esac
  echo "── $case_id: $notes ──"
  case "$policy" in
    hook)
      hook="tests/${script}"
      chmod +x "$hook" 2>/dev/null || true
      if SHU="$SHU_BIN" "$hook"; then
        echo "lang-import OK $case_id"
      else
        echo "lang-import FAIL $case_id ($script)" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    run)
      if run_su_case "$script" "${want_ec:-0}"; then
        echo "lang-import OK $case_id"
      else
        FAILS=$((FAILS + 1))
      fi
      ;;
    *)
      echo "lang-import WARN: unknown policy $policy" >&2
      ;;
  esac
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  echo "lang-import gate FAIL: ${FAILS} case(s)" >&2
  exit 1
fi

echo "lang-import gate OK"
