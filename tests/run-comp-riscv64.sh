#!/usr/bin/env bash
# COMP-012：riscv64 回归烟测
#
# 用法：./tests/run-comp-riscv64.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/comp-riscv64.sh
. tests/lib/comp-riscv64.sh

MATRIX="${SHU_RISCV64_MATRIX:-tests/baseline/comp-riscv64-matrix.tsv}"

echo "=== COMP-012: riscv64 regression smoke ==="

SHU_BIN=""
for cand in ./compiler/shu ./compiler/shu-c ./compiler/shu_asm; do
  if comp_riscv64_native_shu "$cand"; then
    SHU_BIN="$cand"
    break
  fi
done

if [ -z "$SHU_BIN" ]; then
  echo "comp-riscv64 SKIP (no native shu)"
  echo "comp-riscv64 OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

FAILS=0
HOSTOS="$(uname -s 2>/dev/null || echo Unknown)"

while IFS=$'\t' read -r case_id sample check_kind _expect policy _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac

  case "$check_kind" in
    hook_ref)
      if grep -q 'riscv64' tests/run-asm.sh 2>/dev/null; then
        echo "comp-riscv64 OK $case_id (run-asm hook present)"
      else
        echo "comp-riscv64 FAIL: run-asm missing riscv64 section" >&2
        FAILS=$((FAILS + 1))
      fi
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
    fi
    continue
  fi

  case "$check_kind" in
    asm_text)
      if comp_riscv64_check_asm_text "$SHU_BIN" "$path"; then
        echo "comp-riscv64 OK $case_id asm_text"
      else
        echo "comp-riscv64 FAIL: $case_id asm_text" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    asm_text_elf)
      if comp_riscv64_check_asm_text "$SHU_BIN" "$path"; then
        echo "comp-riscv64 OK $case_id asm_text"
      else
        echo "comp-riscv64 FAIL: $case_id asm_text" >&2
        FAILS=$((FAILS + 1))
        continue
      fi
      o="/tmp/shu_riscv_${case_id}.$$.o"
      if comp_riscv64_emit_elf_o "$SHU_BIN" "$path" "$o"; then
        echo "comp-riscv64 OK $case_id elf_o"
        bin="/tmp/shu_riscv_bin_${case_id}.$$"
        if ld_used="$(comp_riscv64_try_link_run "$o" "$bin" 2>/dev/null || true)" && [ -n "$ld_used" ]; then
          echo "comp-riscv64 OK $case_id link_run ($ld_used exit=42)"
        else
          echo "comp-riscv64 SKIP $case_id link_run (no riscv ld)"
        fi
        rm -f "$bin" 2>/dev/null || true
      else
        if [ "$policy" = "linux_hard" ] && [ "$HOSTOS" = "Linux" ]; then
          echo "comp-riscv64 FAIL: $case_id elf_o on Linux" >&2
          FAILS=$((FAILS + 1))
        else
          echo "comp-riscv64 SKIP $case_id elf_o (host=$HOSTOS)"
        fi
      fi
      rm -f "$o" 2>/dev/null || true
      ;;
    elf_o)
      o="/tmp/shu_riscv_${case_id}.$$.o"
      if comp_riscv64_emit_elf_o "$SHU_BIN" "$path" "$o"; then
        echo "comp-riscv64 OK $case_id elf_o"
        if [ "$case_id" = "case_elf_main" ]; then
          bin="/tmp/shu_riscv_bin_${case_id}.$$"
          if ld_used="$(comp_riscv64_try_link_run "$o" "$bin" 2>/dev/null || true)" && [ -n "$ld_used" ]; then
            echo "comp-riscv64 OK $case_id link_run ($ld_used exit=42)"
          else
            echo "comp-riscv64 SKIP $case_id link_run (no riscv ld)"
          fi
          rm -f "$bin" 2>/dev/null || true
        fi
      else
        if [ "$policy" = "linux_hard" ] && [ "$HOSTOS" = "Linux" ]; then
          echo "comp-riscv64 FAIL: $case_id elf_o on Linux" >&2
          FAILS=$((FAILS + 1))
        else
          echo "comp-riscv64 SKIP $case_id elf_o (host=$HOSTOS)"
        fi
      fi
      rm -f "$o" 2>/dev/null || true
      ;;
    *)
      echo "comp-riscv64 SKIP $case_id unknown check $check_kind"
      ;;
  esac
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  echo "comp-riscv64 FAIL: ${FAILS} case(s)" >&2
  exit 1
fi
echo "comp-riscv64 OK"
