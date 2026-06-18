#!/usr/bin/env bash
# BOOT-003：自举失败最小复现统一入口
#
# 任一 CI 自举阶段失败，可用单命令隔离复现。
# 用法：
#   ./tests/run-bootstrap-repro.sh list
#   ./tests/run-bootstrap-repro.sh <case_id>
#   ./tests/run-bootstrap-repro.sh all
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHU_BOOTSTRAP_REPRO_TSV:-tests/baseline/bootstrap-repro.tsv}"

# 与 bstrict-ci 一致：深递归 parser 需要较大栈。
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

repro_is_docker() {
  [ -f /.dockerenv ] || [ -n "${SHU_CI_DOCKER:-}" ]
}

repro_platform_ok() {
  local plat="$1"
  case "$plat" in
    any) return 0 ;;
    linux)
      [ "$(uname -s 2>/dev/null)" = "Linux" ] || return 1
      ;;
    !docker)
      repro_is_docker && return 1 || return 0
      ;;
    *)
      return 0
      ;;
  esac
}

lookup_case() {
  local want="$1"
  while IFS=$'\t' read -r case_id stage hook platform notes; do
    [ -z "$case_id" ] && continue
    case "$case_id" in \#*) continue ;; esac
    if [ "$case_id" = "$want" ]; then
      echo "${case_id}	${stage}	${hook}	${platform}	${notes}"
      return 0
    fi
  done < "$MATRIX"
  return 1
}

list_cases() {
  echo "BOOT-003 bootstrap repro cases (from $MATRIX):"
  while IFS=$'\t' read -r case_id stage hook platform notes; do
    [ -z "$case_id" ] && continue
    case "$case_id" in \#*) continue ;; esac
    printf "  %-28s [%s] %s — %s\n" "$case_id" "$stage" "$hook" "$notes"
  done < "$MATRIX"
}

run_one_case() {
  local case_id="$1"
  local row
  if ! row="$(lookup_case "$case_id")"; then
    echo "bootstrap-repro FAIL: unknown case_id '$case_id'" >&2
    echo "Run: ./tests/run-bootstrap-repro.sh list" >&2
    return 1
  fi
  local stage hook platform notes
  stage="$(echo "$row" | cut -f2)"
  hook="$(echo "$row" | cut -f3)"
  platform="$(echo "$row" | cut -f4)"
  notes="$(echo "$row" | cut -f5)"

  if ! repro_platform_ok "$platform"; then
    echo "bootstrap-repro SKIP $case_id ($notes): platform=$platform host=$(uname -s 2>/dev/null)"
    return 0
  fi
  if [ "$case_id" = "stage2_bstrict" ] && [ -n "${SHU_CI_SKIP_STAGE2:-}" ]; then
    echo "bootstrap-repro SKIP $case_id (SHU_CI_SKIP_STAGE2=1)"
    return 0
  fi
  if [ "$case_id" = "bstrict_build" ] && [ -n "${SHU_BOOTSTRAP_REPRO_SKIP_BUILD:-}" ]; then
    echo "bootstrap-repro SKIP $case_id (SHU_BOOTSTRAP_REPRO_SKIP_BUILD=1)"
    return 0
  fi

  local script="tests/${hook}"
  if [ ! -f "$script" ]; then
    echo "bootstrap-repro FAIL $case_id: missing $script" >&2
    return 1
  fi
  chmod +x "$script" 2>/dev/null || true

  echo "=== bootstrap-repro: $case_id [$stage] — $notes ==="
  case "$case_id" in
    bstrict_build)
      "$script"
      ;;
    strict_smoke)
      # 需先有 build log；无则先构建。
      if [ ! -f /tmp/build_bstrict.log ] && [ ! -f /tmp/bootstrap_repro_build.log ]; then
        echo "bootstrap-repro: no build log; running bstrict_build first ..."
        run_one_case bstrict_build
      fi
      BUILD_LOG="${BUILD_LOG:-/tmp/bootstrap_repro_build.log}"
      [ -f "$BUILD_LOG" ] || BUILD_LOG=/tmp/build_bstrict.log
      BUILD_LOG="$BUILD_LOG" "$script"
      ;;
    shu_asm_gate)
      SHU="${SHU:-./compiler/shu_asm}" "$script"
      ;;
    parser_second_pass)
      SHU_PARSER_SECOND_PASS_FAIL=1 \
      SHU_PARSER_SECOND_PASS_COMPILER="${SHU_PARSER_SECOND_PASS_COMPILER:-compiler/shu_asm}" \
      SHU_PARSER_SECOND_PASS_EMIT_HEAVY=1 \
      SHU_PARSER_THIN_GLUE_SYMBOL_INTEGRITY_FAIL=1 \
        "$script"
      ;;
    parser_symbol_integrity)
      SHU_PARSER_THIN_GLUE_SYMBOL_INTEGRITY_FAIL=1 "$script"
      ;;
    parser_mega_bisect)
      SHU_PARSER_MEGA_BISECT_FAIL=1 "$script"
      ;;
    parser_parse_count)
      SHU_PARSER_PARSE_COUNT_FAIL=1 \
      SHU_PARSER_PARSE_COUNT_TARGET="${SHU_PARSER_PARSE_COUNT_TARGET:-466}" \
      SHU="${SHU:-./compiler/shu_asm}" "$script"
      ;;
    wpo_strict_link)
      SHU_WPO_STRICT_LINK_FAIL=1 "$script"
      ;;
    stage2_bstrict)
      SHU_STAGE2_SKIP_BOOTSTRAP=1 "$script"
      ;;
    run_all_bstrict)
      export SHU_BSTRICT_SKIP_BUILD=1
      SHU="${SHU:-./compiler/shu_asm}" "$script"
      ;;
    asm_73)
      export ASM73_FALLBACK_SHU="${ASM73_FALLBACK_SHU:-./compiler/shu_asm73_seed}"
      SHU="${SHU:-./compiler/shu_asm}" "$script"
      ;;
    *)
      "$script"
      ;;
  esac
  echo "bootstrap-repro OK $case_id"
}

CMD="${1:-list}"
case "$CMD" in
  list|-l|--list)
    list_cases
    ;;
  all)
    FAILS=0
    while IFS=$'\t' read -r case_id stage hook platform notes; do
      [ -z "$case_id" ] && continue
      case "$case_id" in \#*) continue ;; esac
      [ "$case_id" = "full_ci" ] && continue
      if ! run_one_case "$case_id"; then
        FAILS=$((FAILS + 1))
      fi
    done < "$MATRIX"
    if [ "$FAILS" -gt 0 ]; then
      echo "bootstrap-repro all FAIL: ${FAILS} case(s)" >&2
      exit 1
    fi
    echo "bootstrap-repro all OK"
    ;;
  help|-h|--help)
    echo "Usage: $0 list|<case_id>|all|diag [--repro] [logfile]"
    echo "Doc: analysis/boot-repro-v1.md"
    echo "Diag: analysis/boot-stage-diag-v1.md (BOOT-004)"
    list_cases
    ;;
  diag)
    shift
    chmod +x tests/run-bootstrap-stage-diag.sh 2>/dev/null || true
    exec tests/run-bootstrap-stage-diag.sh "$@"
    ;;
  *)
    run_one_case "$CMD"
    ;;
esac
