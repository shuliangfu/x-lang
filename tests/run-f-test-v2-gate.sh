#!/usr/bin/env bash
# F-test v2：std.test 逻辑下沉 + F-ZC 纯 .x。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_TEST_V2_FAIL:-0}
DOC="analysis/phase-f-test-v2.md"
MANIFEST="tests/baseline/f-test-v2-closure.tsv"
die() { echo "f-test-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-test v2: test logic → test.x (F-ZC zero glue) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-test v2' "$DOC" || die "doc marker"
[ -f std/test/test.x ] || die "missing test.x"
[ -f compiler/seeds/runtime_test_fn_invoke.from_x.c ] || die "missing runtime_test_fn_invoke.inc"
[ ! -f std/test/test_glue.c ] || die "test_glue.c should be deleted (F-ZC)"
[ ! -f std/test/test.c ] || die "test.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'test_expect_c' std/test/test.x || die "test.x missing expect"
grep -q 'test_runner_report_case_c' std/test/test.x || die "test.x missing runner"
grep -q 'test_bench_run_c' std/test/test.x || die "test.x missing bench_run"
grep -q 'test_fuzz_next_c' std/test/test.x || die "test.x missing fuzz_next"
grep -q 'test_f_test_v2_marker_c' std/test/test.x || die "test.x missing v2 marker"
grep -q 'test_io_bench_line_c' std/test/test.x || die "test.x missing IO bench"
grep -q 'test_f_zero_c_marker_c' std/test/test.x || die "test.x missing F-ZC marker"
grep -q 'runtime_test_fn_invoke' compiler/Makefile || die "Makefile missing runtime_test_fn_invoke.o"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler runtime_test_fn_invoke.o ../std/test/test.o >/dev/null 2>&1 || die "make test.o failed"
else
  echo "f-test-v2 SKIP test.o build (no shux-c)" >&2
fi
for sub in run-std-test-bench-fuzz-gate.sh run-std-test-executable-gate.sh run-std-test-runner-gate.sh; do
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-test-v2 gate OK"
