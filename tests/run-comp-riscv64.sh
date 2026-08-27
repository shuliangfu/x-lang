#!/usr/bin/env bash
# COMP-012: riscv64 regression smoke (false-authority honesty).
#
# Honesty: soft SKIP→OK when no asm-capable xlang retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG = hard die. Missing
# native = hard die. Native present but riscv64 asm not available =
# skip= (capability N/A, not soft SKIP→OK). Report run=/skip=.
#
# Usage: ./tests/run-comp-riscv64.sh
# PLATFORM: SHARED archaeology (riscv ld / ELF optional).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/comp-riscv64.sh
. tests/lib/comp-riscv64.sh

MATRIX="${XLANG_RISCV64_MATRIX:-tests/baseline/comp-riscv64-matrix.tsv}"
PREFIX="xlang: [XLANG_COMP_RISCV64]"
RUN_OK=0
SKIP=0
FAILS=0

die() {
  echo "comp-riscv64 FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
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
    # Explicit XLANG that is missing or wrong-ABI = hard die (refuse soft SKIP→OK).
    return 1
  fi
  # Prefer product asm. PLATFORM: SHARED — product path honesty; Ubuntu gold.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== COMP-012: riscv64 regression smoke ==="

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# Capability N/A (seed/C-only or no riscv64 asm) = skip=, not soft SKIP→OK.
if ! comp_riscv64_asm_capable "$XLANG_BIN"; then
  echo "comp-riscv64 SKIP (native present; riscv64 asm not available; capability N/A)"
  SKIP=$((SKIP + 1))
  ok_report
  exit 0
fi

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

HOSTOS="$(uname -s 2>/dev/null || echo Unknown)"

while IFS=$'\t' read -r case_id sample check_kind _expect policy _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac

  case "$check_kind" in
    hook_ref)
      if grep -q 'riscv64' tests/run-asm.sh 2>/dev/null; then
        echo "comp-riscv64 OK $case_id (run-asm hook present)"
        RUN_OK=$((RUN_OK + 1))
      else
        echo "comp-riscv64 FAIL: run-asm missing riscv64 section" >&2
        FAILS=$((FAILS + 1))
      fi
      continue
      ;;
    qemu_run)
      # QEMU cases live in run-comp-riscv64-qemu-smoke.sh (not this runner).
      echo "comp-riscv64 SKIP $case_id (qemu_run delegated)"
      SKIP=$((SKIP + 1))
      continue
      ;;
  esac

  path="$(comp_riscv64_sample_path "$sample" 2>/dev/null || true)"
  if [ -z "$path" ]; then
    if [ "$policy" = "required" ]; then
      echo "comp-riscv64 FAIL: missing sample $sample" >&2
      FAILS=$((FAILS + 1))
    else
      echo "comp-riscv64 SKIP $case_id (no $sample)"
      SKIP=$((SKIP + 1))
    fi
    continue
  fi

  case "$check_kind" in
    asm_text)
      if comp_riscv64_check_asm_text "$XLANG_BIN" "$path"; then
        echo "comp-riscv64 OK $case_id asm_text"
        RUN_OK=$((RUN_OK + 1))
      else
        echo "comp-riscv64 FAIL: $case_id asm_text" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    asm_text_elf)
      if comp_riscv64_check_asm_text "$XLANG_BIN" "$path"; then
        echo "comp-riscv64 OK $case_id asm_text"
        RUN_OK=$((RUN_OK + 1))
      else
        echo "comp-riscv64 FAIL: $case_id asm_text" >&2
        FAILS=$((FAILS + 1))
        continue
      fi
      o="/tmp/xlang_riscv_${case_id}.$$.o"
      if comp_riscv64_emit_elf_o "$XLANG_BIN" "$path" "$o"; then
        echo "comp-riscv64 OK $case_id elf_o"
        RUN_OK=$((RUN_OK + 1))
        bin="/tmp/xlang_riscv_bin_${case_id}.$$"
        if ld_used="$(comp_riscv64_try_link_run "$o" "$bin" 2>/dev/null || true)" && [ -n "$ld_used" ]; then
          echo "comp-riscv64 OK $case_id link_run ($ld_used exit=42)"
          RUN_OK=$((RUN_OK + 1))
        else
          echo "comp-riscv64 SKIP $case_id link_run (no riscv ld)"
          SKIP=$((SKIP + 1))
        fi
        rm -f "$bin" 2>/dev/null || true
      else
        if [ "$policy" = "linux_hard" ] && [ "$HOSTOS" = "Linux" ]; then
          echo "comp-riscv64 FAIL: $case_id elf_o on Linux" >&2
          FAILS=$((FAILS + 1))
        else
          echo "comp-riscv64 SKIP $case_id elf_o (host=$HOSTOS)"
          SKIP=$((SKIP + 1))
        fi
      fi
      rm -f "$o" 2>/dev/null || true
      ;;
    elf_o)
      o="/tmp/xlang_riscv_${case_id}.$$.o"
      if comp_riscv64_emit_elf_o "$XLANG_BIN" "$path" "$o"; then
        echo "comp-riscv64 OK $case_id elf_o"
        RUN_OK=$((RUN_OK + 1))
        if [ "$case_id" = "case_elf_main" ]; then
          bin="/tmp/xlang_riscv_bin_${case_id}.$$"
          if ld_used="$(comp_riscv64_try_link_run "$o" "$bin" 2>/dev/null || true)" && [ -n "$ld_used" ]; then
            echo "comp-riscv64 OK $case_id link_run ($ld_used exit=42)"
            RUN_OK=$((RUN_OK + 1))
          else
            echo "comp-riscv64 SKIP $case_id link_run (no riscv ld)"
            SKIP=$((SKIP + 1))
          fi
          rm -f "$bin" 2>/dev/null || true
        fi
      else
        if [ "$policy" = "linux_hard" ] && [ "$HOSTOS" = "Linux" ]; then
          echo "comp-riscv64 FAIL: $case_id elf_o on Linux" >&2
          FAILS=$((FAILS + 1))
        else
          echo "comp-riscv64 SKIP $case_id elf_o (host=$HOSTOS)"
          SKIP=$((SKIP + 1))
        fi
      fi
      rm -f "$o" 2>/dev/null || true
      ;;
    *)
      echo "comp-riscv64 SKIP $case_id unknown check $check_kind"
      SKIP=$((SKIP + 1))
      ;;
  esac
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  die "${FAILS} case(s)"
fi
echo "comp-riscv64 OK"
ok_report
