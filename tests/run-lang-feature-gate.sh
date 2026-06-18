#!/usr/bin/env bash
# LANG-001：edition / feature gate 烟测。
#
# 用法：./tests/run-lang-feature-gate.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

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

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHU_BIN" ] || ! native_shu "$SHU_BIN"; then
  echo "lang-feature-gate SKIP (no native shu, host=$(ci_host_summary))" >&2
  echo "lang-feature-gate OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler
chmod +x scripts/shu-lang-edition.sh

ED_STABLE=tests/lang-feature/edition_stable.su
FEAT=tests/lang-feature/feature_match.su
EXE="/tmp/shu_lang_feat_$$"

run_expect() {
  local label="$1"
  shift
  "$@" -o "$EXE" 2>&1
  local ec=0
  "$EXE" >/dev/null 2>&1 || ec=$?
  rm -f "$EXE"
  echo "$ec"
}

# edition：默认稳定 0
ec=$(run_expect edition_stable ./scripts/shu-lang-edition.sh 2024 "$ED_STABLE")
[ "$ec" -eq 0 ] || { echo "lang-feature FAIL edition stable want 0 got $ec" >&2; exit 1; }

# edition：无 2025 flag 亦为 0
ec=$(SHU="$SHU_BIN" run_expect edition_default "$SHU_BIN" "$ED_STABLE")
[ "$ec" -eq 0 ] || { echo "lang-feature FAIL edition default want 0 got $ec" >&2; exit 1; }

# edition：2025 experimental 99
ec=$(run_expect edition_2025 ./scripts/shu-lang-edition.sh 2025 "$ED_STABLE")
[ "$ec" -eq 99 ] || { echo "lang-feature FAIL edition 2025 want 99 got $ec" >&2; exit 1; }

# feature：off 0
ec=$(SHU="$SHU_BIN" run_expect feature_off "$SHU_BIN" "$FEAT")
[ "$ec" -eq 0 ] || { echo "lang-feature FAIL feature off want 0 got $ec" >&2; exit 1; }

# feature：on 42
ec=$(run_expect feature_on ./scripts/shu-lang-edition.sh feature MATCH_STMT "$FEAT")
[ "$ec" -eq 42 ] || { echo "lang-feature FAIL feature on want 42 got $ec" >&2; exit 1; }

echo "lang-feature-gate report edition=OK feature=OK host=$(ci_host_summary)"
echo "lang-feature-gate OK"
