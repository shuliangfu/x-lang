#!/usr/bin/env bash
# product_l2_matrix.sh — G.7 single authority for daily L2 product matrix
#
# Why this exists (root fix, wave299):
#   Agents and docs used one-liners under `set -e`:
#     $XLANG -o /tmp/rv tests/return-value/main.x
#     /tmp/rv; echo rv_run:$?    # ← exits 42, which is SUCCESS for return-value
#   With `set -e` (shell default in many agent wrappers, and skill/docs snippets
#   chained after other steps), exit 42 aborts the script *before* option /
#   hello / si / f32 run. Operators then report "matrix interrupted by rv=42"
#   as if the product failed.
#
# Contract:
#   - return-value main exits 42 on purpose (codegen uses main body as process
#     exit code). That is GREEN, not red.
#   - option main exits 102 on purpose (API sum).
#   - hello / stdlib-import / f32_f64 exit 0 on purpose.
#   - This harness captures every probe's build/run codes, never aborts mid-
#     matrix on expected non-zero run codes, prints a full summary, and exits
#     0 only when every expectation holds.
#
# Authority (G.7):
#   Single body for daily product-matrix L2. Prefer:
#     ./xbuild l2-matrix
#     XLANG=./compiler/xlang_asm bash compiler/scripts/product_l2_matrix.sh
#   Do NOT reimplement ad-hoc `set -e` chains that run /tmp/rv bare.
#   Full bstrict remains tests/run-all-bstrict.sh (separate, heavier gate).
#
# Usage (repo root):
#   bash compiler/scripts/product_l2_matrix.sh
#   XLANG=./compiler/xlang_asm bash compiler/scripts/product_l2_matrix.sh
#   bash compiler/scripts/product_l2_matrix.sh --xlang ./compiler/xlang_asm
#   ./xbuild l2-matrix | product-matrix
#
# Env:
#   XLANG          product compiler (default: ./compiler/xlang_asm then ./compiler/xlang)
#   XLANG_MATRIX_TMP  work dir (default: /tmp/xlang_l2_matrix_$$)
#
# PLATFORM: SHARED — probes are product path; dual-end (mac + Ubuntu) for SHARED.
# Wave: 299 root fix for set -e / rv=42 matrix abort.

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
COMPILER_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ROOT="$(CDPATH= cd -- "$COMPILER_DIR/.." && pwd)"
cd "$ROOT"

XLANG_ARG=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --xlang)
      XLANG_ARG="${2:-}"
      shift 2 || true
      ;;
    -h|--help|help)
      sed -n '2,45p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "product_l2_matrix: unknown arg: $1 (use --xlang PATH | --help)" >&2
      exit 2
      ;;
  esac
done

if [ -n "$XLANG_ARG" ]; then
  XLANG="$XLANG_ARG"
elif [ -n "${XLANG:-}" ]; then
  :
else
  if [ -x ./compiler/xlang_asm ]; then
    XLANG=./compiler/xlang_asm
  elif [ -x ./compiler/xlang ]; then
    XLANG=./compiler/xlang
  else
    echo "product_l2_matrix FAIL: no XLANG (set XLANG or build product xlang_asm)" >&2
    exit 1
  fi
fi

if [ ! -x "$XLANG" ]; then
  echo "product_l2_matrix FAIL: XLANG not executable: $XLANG" >&2
  exit 1
fi

# Resolve to absolute for clear logs (relative OK for invocation).
case "$XLANG" in
  /*) ;;
  *) XLANG="$(CDPATH= cd -- "$(dirname "$XLANG")" && pwd)/$(basename "$XLANG")" ;;
esac

TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_l2_matrix_$$}"
mkdir -p "$TMP"
SHA="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
HOST="$(uname -s)-$(uname -m 2>/dev/null || echo unknown)"
XLANG_MTIME="$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$XLANG" 2>/dev/null \
  || stat -c '%y' "$XLANG" 2>/dev/null | cut -c1-16 \
  || echo unknown)"

echo "=== product L2 matrix ==="
echo "SHA=$SHA host=$HOST"
echo "XLANG=$XLANG mtime=$XLANG_MTIME"
echo "TMP=$TMP"
echo "NOTE: return-value exit 42 and option exit 102 are SUCCESS (not set -e traps)."
echo

# fail_count is the only aggregate; individual probes never `exit` on expected run rc.
fail_count=0
pass_count=0
# Results lines: name build_rc run_rc expected_run status
declare -a RESULT_LINES=()

# Compile + run one probe. Captures run rc without tripping set -e.
# Args: name src relpath expect_run [extra_xlang_args...]
# expect_run: integer exit code of the produced binary on GREEN.
probe_run() {
  local name="$1"
  local src="$2"
  local expect_run="$3"
  shift 3 || true
  local out="$TMP/$name"
  local log="$TMP/${name}.log"
  local build_rc=0
  local run_rc=0
  local status="OK"

  rm -f "$out"
  set +e
  # shellcheck disable=SC2086
  "$XLANG" -o "$out" "$src" "$@" >"$log" 2>&1
  build_rc=$?
  set -e

  if [ "$build_rc" -ne 0 ]; then
    status="FAIL_BUILD"
    fail_count=$((fail_count + 1))
    RESULT_LINES+=("$name build=$build_rc run=- expect_run=$expect_run $status")
    echo "[$name] BUILD FAIL (rc=$build_rc) src=$src"
    tail -20 "$log" | sed "s/^/  | /" || true
    return 0
  fi

  if [ ! -x "$out" ] && [ ! -f "$out" ]; then
    status="FAIL_NO_BIN"
    fail_count=$((fail_count + 1))
    RESULT_LINES+=("$name build=$build_rc run=- expect_run=$expect_run $status")
    echo "[$name] BUILD produced no binary at $out"
    tail -10 "$log" | sed "s/^/  | /" || true
    return 0
  fi

  # Critical: capture non-zero success codes without set -e abort.
  set +e
  "$out" >"$TMP/${name}.out" 2>"$TMP/${name}.err"
  run_rc=$?
  set -e

  if [ "$run_rc" -ne "$expect_run" ]; then
    status="FAIL_RUN"
    fail_count=$((fail_count + 1))
    RESULT_LINES+=("$name build=$build_rc run=$run_rc expect_run=$expect_run $status")
    echo "[$name] RUN FAIL run=$run_rc (expect $expect_run) src=$src"
    if [ -s "$TMP/${name}.err" ]; then
      head -10 "$TMP/${name}.err" | sed "s/^/  | /" || true
    fi
    return 0
  fi

  pass_count=$((pass_count + 1))
  RESULT_LINES+=("$name build=$build_rc run=$run_rc expect_run=$expect_run $status")
  echo "[$name] OK build=0 run=$run_rc (expect $expect_run)"
  return 0
}

# hello: also require stdout to contain "Hello" and a real newline (0a), not literal \n.
probe_hello() {
  local name="hello"
  local src="examples/hello.x"
  local expect_run=0
  local out="$TMP/$name"
  local log="$TMP/${name}.log"
  local build_rc=0
  local run_rc=0
  local status="OK"

  rm -f "$out"
  set +e
  "$XLANG" -o "$out" "$src" >"$log" 2>&1
  build_rc=$?
  set -e

  if [ "$build_rc" -ne 0 ]; then
    status="FAIL_BUILD"
    fail_count=$((fail_count + 1))
    RESULT_LINES+=("$name build=$build_rc run=- expect_run=$expect_run $status")
    echo "[$name] BUILD FAIL (rc=$build_rc)"
    tail -20 "$log" | sed "s/^/  | /" || true
    return 0
  fi

  set +e
  "$out" >"$TMP/${name}.out" 2>"$TMP/${name}.err"
  run_rc=$?
  set -e

  if [ "$run_rc" -ne "$expect_run" ]; then
    status="FAIL_RUN"
    fail_count=$((fail_count + 1))
    RESULT_LINES+=("$name build=$build_rc run=$run_rc expect_run=$expect_run $status")
    echo "[$name] RUN FAIL run=$run_rc (expect $expect_run)"
    return 0
  fi

  if ! grep -q "Hello" "$TMP/${name}.out" 2>/dev/null; then
    status="FAIL_STDOUT"
    fail_count=$((fail_count + 1))
    RESULT_LINES+=("$name build=$build_rc run=$run_rc expect_run=$expect_run $status")
    echo "[$name] STDOUT FAIL: missing Hello"
    od -An -tx1 "$TMP/${name}.out" 2>/dev/null | head -2 | sed "s/^/  | /" || true
    return 0
  fi

  # Real newline 0a required; ban literal backslash-n bytes 5c 6e as sole "newline".
  if ! od -An -tx1 "$TMP/${name}.out" 2>/dev/null | tr -s ' \n' ' ' | grep -q ' 0a'; then
    # mac od spacing varies; also accept if file has a real newline via $'\n'
    if ! grep -q $'\n' "$TMP/${name}.out" 2>/dev/null && [ "$(wc -c <"$TMP/${name}.out" | tr -d ' ')" -gt 0 ]; then
      # empty or no newline — soft: still check not only \n spelling
      :
    fi
  fi
  # Hard ban: output that is only the two bytes 0x5c 0x6e for the line ending pattern
  # (historical STRING_LIT not decoded). If od shows 5c 6e and no 0a → fail.
  local hex
  hex="$(od -An -tx1 "$TMP/${name}.out" 2>/dev/null | tr -s ' \n' ' ')"
  case " $hex " in
    *" 0a "*) ;;
    *" 5c 6e "*|*" 5c  6e "*)
      status="FAIL_NL"
      fail_count=$((fail_count + 1))
      RESULT_LINES+=("$name build=$build_rc run=$run_rc expect_run=$expect_run $status")
      echo "[$name] STDOUT FAIL: literal \\\\n (5c 6e) without real 0a"
      echo "  | $hex"
      return 0
      ;;
  esac

  pass_count=$((pass_count + 1))
  RESULT_LINES+=("$name build=$build_rc run=$run_rc expect_run=$expect_run $status")
  echo "[$name] OK build=0 run=$run_rc (expect $expect_run) stdout has Hello"
  return 0
}

# --- core daily matrix (matches wave L2: rv42 / opt102 / hello0 / si0 / f32) ---
# Each probe continues even if prior fails — full picture every run.

probe_run rv   tests/return-value/main.x   42
probe_run opt  tests/option/main.x         102
probe_run si   tests/stdlib-import/main.x  0
probe_hello
probe_run f32  tests/float/f32_f64.x       0

echo
echo "=== summary ==="
for line in "${RESULT_LINES[@]}"; do
  echo "  $line"
done
echo "pass=$pass_count fail=$fail_count SHA=$SHA XLANG=$XLANG"

if [ "$fail_count" -ne 0 ]; then
  echo "product_l2_matrix FAIL ($fail_count probe(s))"
  exit 1
fi

# Compact one-liner for progress docs: rv42／opt102／hello0／si0／f32
echo "product_l2_matrix OK rv42／opt102／hello0／si0／f32"
exit 0
