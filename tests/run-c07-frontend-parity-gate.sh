#!/usr/bin/env bash
# C-07：shux-c（C 前端）vs shux/shux_asm（.sx 前端）同输入 typeck/run parity 门禁。
#
# 用法：./tests/run-c07-frontend-parity-gate.sh
# 环境：SHUX_C07_FAIL=1 失败时硬退出；C07_REF / C07_CAND 可覆盖编译器路径。
#       SHUX_C07_TRY_RUN=1 时在 typeck_ok 通过后额外尝试 -o 运行（需 liburing 等）。
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_C07_FAIL:-0}
TRY_RUN=${SHUX_C07_TRY_RUN:-0}
MATRIX="${SHUX_C07_MATRIX:-tests/baseline/c07-frontend-parity-matrix.tsv}"
DOC="analysis/phase-c-c07-v1.md"

# shellcheck source=tests/lib/c07-frontend-parity.sh
. tests/lib/c07-frontend-parity.sh

echo "=== C-07: frontend parity (shux-c REF vs sx CAND) ==="
for f in "$MATRIX" "$DOC" tests/lib/c07-frontend-parity.sh; do
  [ -f "$f" ] || { echo "c07 gate FAIL: missing $f" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
done

make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true

rc_resolve=0
c07_resolve_compilers || rc_resolve=$?
if [ "$rc_resolve" -eq 1 ]; then
  echo "c07 gate SKIP (shux-c not runnable on $(ci_host_summary))"
  exit 0
fi
if [ "$rc_resolve" -eq 2 ]; then
  echo "c07 gate SKIP (no runnable shux/shux_asm on $(ci_host_summary))"
  exit 0
fi

echo "c07 parity: REF=$C07_REF CAND=$C07_CAND host=$(ci_host_summary) try_run=$TRY_RUN"

parity_fail() {
  echo "c07 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  return 0
}

pass=0
while IFS=$'\t' read -r case_id src policy expect_exit notes; do
  [ -z "$case_id" ] || [ "${case_id#\#}" != "$case_id" ] && continue
  [ -f "$src" ] || { parity_fail "missing src $src ($case_id)"; continue; }

  tag="${case_id}_$$"
  log_ref="/tmp/c07_${tag}_ref.log"
  log_cand="/tmp/c07_${tag}_cand.log"

  rc_ref=0
  rc_cand=0
  c07_typeck_sx "$C07_REF" "$src" "$log_ref" || rc_ref=$?
  c07_typeck_sx "$C07_CAND" "$src" "$log_cand" || rc_cand=$?

  if [ "$policy" = "compile_fail" ]; then
    if [ "$rc_ref" -eq 0 ] || [ "$rc_cand" -eq 0 ]; then
      parity_fail "$case_id: expected compile fail (ref=$rc_ref cand=$rc_cand) — $notes"
      rm -f "$log_ref" "$log_cand" 2>/dev/null || true
      continue
    fi
    if ! c07_log_typeck_error "$log_ref" && ! c07_log_typeck_error "$log_cand"; then
      parity_fail "$case_id: expected typeck error in log — $notes"
      rm -f "$log_ref" "$log_cand" 2>/dev/null || true
      continue
    fi
    echo "c07 OK compile_fail $case_id ($notes)"
    pass=$((pass + 1))
    rm -f "$log_ref" "$log_cand" 2>/dev/null || true
    continue
  fi

  if [ "$policy" != "typeck_ok" ] && [ "$policy" != "run" ]; then
    parity_fail "$case_id: unknown policy $policy"
    continue
  fi

  if [ "$rc_ref" -ne 0 ] || [ "$rc_cand" -ne 0 ]; then
    parity_fail "$case_id: typeck ref=$rc_ref cand=$rc_cand — $notes"
    tail -n 5 "$log_ref" 2>/dev/null || true
    tail -n 5 "$log_cand" 2>/dev/null || true
    rm -f "$log_ref" "$log_cand" 2>/dev/null || true
    continue
  fi
  if ! c07_log_typeck_ok "$log_ref" || ! c07_log_typeck_ok "$log_cand"; then
    parity_fail "$case_id: missing typeck OK in log — $notes"
    rm -f "$log_ref" "$log_cand" 2>/dev/null || true
    continue
  fi

  if [ "$TRY_RUN" = "1" ]; then
    out_ref="/tmp/c07_${tag}_ref"
    out_cand="/tmp/c07_${tag}_cand"
    rc_link_ref=0
    rc_link_cand=0
    c07_compile_sx "$C07_REF" "$src" "$out_ref" "$log_ref" || rc_link_ref=$?
    c07_compile_sx "$C07_CAND" "$src" "$out_cand" "$log_cand" || rc_link_cand=$?
    if [ "$rc_link_ref" -eq 0 ] && [ "$rc_link_cand" -eq 0 ] && [ -x "$out_ref" ] && [ -x "$out_cand" ]; then
      run_ref=$(c07_run_exit "$out_ref")
      run_cand=$(c07_run_exit "$out_cand")
      if [ "$run_ref" != "$run_cand" ] || [ "$run_ref" != "$expect_exit" ]; then
        parity_fail "$case_id: run ref=$run_ref cand=$run_cand expect=$expect_exit — $notes"
        rm -f "$out_ref" "$out_cand" "$log_ref" "$log_cand" 2>/dev/null || true
        continue
      fi
      echo "c07 OK typeck+run $case_id exit=$run_ref ($notes)"
    else
      echo "c07 OK typeck_only $case_id (run skip: link ref=$rc_link_ref cand=$rc_link_cand) ($notes)"
    fi
    rm -f "$out_ref" "$out_cand" 2>/dev/null || true
  else
    echo "c07 OK typeck $case_id ($notes)"
  fi
  pass=$((pass + 1))
  rm -f "$log_ref" "$log_cand" 2>/dev/null || true
done < "$MATRIX"

if [ "$pass" -lt 1 ]; then
  parity_fail "no cases passed"
  exit 0
fi

echo "c07 frontend-parity gate OK ($pass cases, REF=$C07_REF CAND=$C07_CAND)"
