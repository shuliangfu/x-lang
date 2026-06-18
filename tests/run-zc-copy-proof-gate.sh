#!/usr/bin/env bash
# ZC-007：零拷贝证明测试模板 + PR 拷贝声明门禁
#
# 1) zc-copy-proof-v1.md + 模板 + manifest
# 2) 模板 metadata 键；PR checklist 字段
# 3) matrix run 行：编译运行 proof（native shu）
#
# 用法：./tests/run-zc-copy-proof-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_ZC_COPY_PROOF_DOC:-analysis/zc-copy-proof-v1.md}"
MATRIX="${SHU_ZC_COPY_PROOF_TSV:-tests/baseline/zc-copy-proof.tsv}"
PR_TPL="${SHU_ZC_PR_COPY_TPL:-tests/templates/zc-pr-copy-declaration.txt}"
SU_TPL="${SHU_ZC_SU_COPY_TPL:-tests/templates/zc-copy-proof-test.su}"
SEM="${SHU_ZC_SEMANTICS_DOC:-analysis/zc-semantics-v1.md}"
MIN_PROOFS=1

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

echo "=== ZC-007: copy proof manifest ==="
for f in "$DOC" "$MATRIX" "$PR_TPL" "$SU_TPL" "$SEM"; do
  if [ ! -f "$f" ]; then
    echo "zc-copy-proof gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_proofs) MIN_PROOFS="$c2" ;; esac
done < "$MATRIX"

# ── 模板 metadata 键 ──
for key in path_id userland_copies zc_tier hot_path fallback; do
  if ! grep -qF "$key:" "$SU_TPL" 2>/dev/null; then
    echo "zc-copy-proof gate FAIL: su template missing key $key" >&2
    exit 1
  fi
done
echo "zc-copy-proof su template OK"

# ── PR checklist 必填字段 ──
for field in userland_copies zc_tier proof_id fallback; do
  if ! grep -qF "$field:" "$PR_TPL" 2>/dev/null; then
    echo "zc-copy-proof gate FAIL: pr template missing $field" >&2
    exit 1
  fi
done
echo "zc-copy-proof pr template OK"

if ! grep -qF 'ZC-007' "$SEM" 2>/dev/null; then
  echo "zc-copy-proof gate FAIL: zc-semantics doc missing ZC-007 ref" >&2
  exit 1
fi

# ── matrix ──
RUN_N=0
FAILS=0
echo "=== ZC-007: proof matrix ==="
while IFS=$'\t' read -r proof_id source policy want_ec copies tier notes; do
  [ -z "${proof_id:-}" ] && continue
  case "$proof_id" in \#*|min_proofs) continue ;; esac
  case "$policy" in
    template)
      case "$source" in
        zc-copy-proof-test.su)
          [ -f "$SU_TPL" ] || { echo "zc-copy-proof FAIL: $SU_TPL" >&2; FAILS=$((FAILS + 1)); }
          ;;
        zc-pr-copy-declaration.txt)
          [ -f "$PR_TPL" ] || { echo "zc-copy-proof FAIL: $PR_TPL" >&2; FAILS=$((FAILS + 1)); }
          ;;
        *)
          echo "zc-copy-proof FAIL: unknown template $source" >&2
          FAILS=$((FAILS + 1))
          ;;
      esac
      ;;
    meta)
      src="tests/templates/$source"
      if [ ! -f "$src" ]; then
        echo "zc-copy-proof FAIL: missing $src" >&2
        FAILS=$((FAILS + 1))
        continue
      fi
      for key in path_id userland_copies zc_tier; do
        if ! grep -qF "$key:" "$src" 2>/dev/null; then
          echo "zc-copy-proof FAIL: $src missing $key" >&2
          FAILS=$((FAILS + 1))
        fi
      done
      ;;
    checklist)
      if ! grep -qF 'userland_copies' "$PR_TPL" 2>/dev/null; then
        echo "zc-copy-proof FAIL: checklist fields" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    run)
      src="tests/zc/$source"
      if [ ! -f "$src" ]; then
        echo "zc-copy-proof FAIL: missing $src" >&2
        FAILS=$((FAILS + 1))
        continue
      fi
      for key in path_id userland_copies zc_tier; do
        if ! grep -qF "$key:" "$src" 2>/dev/null; then
          echo "zc-copy-proof FAIL: $src missing metadata $key" >&2
          FAILS=$((FAILS + 1))
        fi
      done
      if [ "$copies" != "-" ] && ! grep -qF "userland_copies: $copies" "$src" 2>/dev/null; then
        echo "zc-copy-proof FAIL: $src userland_copies mismatch want $copies" >&2
        FAILS=$((FAILS + 1))
      fi
      RUN_N=$((RUN_N + 1))
      echo "zc-copy-proof OK proof row $proof_id"
      ;;
    *)
      echo "zc-copy-proof WARN: unknown policy $policy for $proof_id" >&2
      ;;
  esac
done < "$MATRIX"

if [ "$RUN_N" -lt "$MIN_PROOFS" ]; then
  echo "zc-copy-proof gate FAIL: run_proofs=${RUN_N} < min_proofs=${MIN_PROOFS}" >&2
  exit 1
fi
if [ "$FAILS" -gt 0 ]; then
  echo "zc-copy-proof gate FAIL: matrix errors=${FAILS}" >&2
  exit 1
fi

make -C compiler -q 2>/dev/null || make -C compiler

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
  echo "zc-copy-proof gate SKIP smoke (no native shu)" >&2
  echo "zc-copy-proof gate OK"
  exit 0
fi

run_proof() {
  local script="$1"
  local want_ec="$2"
  local src="tests/zc/$script"
  local out="/tmp/shu_zc_proof_${script%.su}"
  if ! "$SHU_BIN" -L . "$src" -o "$out" >/tmp/shu_zc_proof_compile.log 2>&1; then
    cat /tmp/shu_zc_proof_compile.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "$want_ec" ]; then
    echo "zc-copy-proof FAIL $script: exit=$ec want=$want_ec" >&2
    return 1
  fi
  return 0
}

SMOKE_FAILS=0
echo "=== ZC-007: proof smoke (SHU=$SHU_BIN) ==="
while IFS=$'\t' read -r proof_id source policy want_ec _c _t _n; do
  [ -z "${proof_id:-}" ] && continue
  case "$proof_id" in \#*|min_proofs|template_meta|pr_checklist) continue ;; esac
  [ "$policy" = "run" ] || continue
  echo "── proof $proof_id ──"
  if run_proof "$source" "${want_ec:-0}"; then
    echo "zc-copy-proof smoke OK $proof_id"
  else
    SMOKE_FAILS=$((SMOKE_FAILS + 1))
  fi
done < "$MATRIX"

if [ "$SMOKE_FAILS" -gt 0 ]; then
  echo "zc-copy-proof gate FAIL: smoke=${SMOKE_FAILS}" >&2
  exit 1
fi

echo "zc-copy-proof gate OK"
