#!/bin/bash
# prove_x_o.sh — G-02f / Phase 0 试点：证明单个 .x TU 至少完成 L1/L2
#
# 用法：
#   sh scripts/prove_x_o.sh src/asm/simd_loop.x [seeds/simd_loop.from_x.c]
#
# 职责（当前试点版）：
#   1) bootstrap-safe lint
#   2) .x -> -E 生成 C
#   3) cc -c 生成 .o（支持 G05_X_O_WEAK=1）
#   4) nm 导出符号快照
#   5) 可选：与 seed C/.o 的导出符号集合做最小对照
#   6) 若 seed 为 L2 thin+rest 形态，则自动编 rest 并做 ld -r 合并验证
#   7) 最小 smoke：关键导出符号的解析烟测（probe + resolve check）
#
# 约束：
#   - 所有外部命令都带硬超时
#   - 诊断工件落到 tests/probes/prove_x_o/，不写 /tmp
#   - 默认先跑 x_bootstrap_safe_lint.sh；可用 XLANG_PROVE_SKIP_LINT=1 跳过

set -eu

cd "$(dirname "$0")/.."

usage() {
  cat <<'EOF'
usage:
  sh scripts/prove_x_o.sh <x-file> [seed-c-or-o]

examples:
  sh scripts/prove_x_o.sh src/asm/simd_loop.x seeds/simd_loop.from_x.c
  XLANG_PROVE_TIMEOUT=12 sh scripts/prove_x_o.sh src/asm/simd_enc.x
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  usage >&2
  exit 2
fi

X_SRC="$1"
SEED_SRC="${2:-}"
TIMEOUT="${XLANG_PROVE_TIMEOUT:-8}"
CC_BIN="${CC:-cc}"
BASE_CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"

if [ ! -f "$X_SRC" ]; then
  echo "prove_x_o: missing x source: $X_SRC" >&2
  exit 1
fi

pick_xlang() {
  if [ -x ./xlang ]; then
    echo ./xlang
    return 0
  fi
  if [ -x ./xlang-c ]; then
    echo ./xlang-c
    return 0
  fi
  if [ -x ./bootstrap_xlangc ]; then
    echo ./bootstrap_xlangc
    return 0
  fi
  return 1
}

run_timeout() {
  _timeout="$1"
  shift
  perl -e 'alarm shift; exec @ARGV' "$_timeout" "$@"
}

resolve_seed_src() {
  _x_src="$1"
  _stem="$(basename "$_x_src" .x)"
  _seed_dir="seeds"
  _macro=""
  _macro_hits=""
  _hit_count=0

  if [ -f "${_seed_dir}/${_stem}.from_x.c" ]; then
    printf '%s\n' "${_seed_dir}/${_stem}.from_x.c"
    return 0
  fi

  case "$_stem" in
    *_thin)
      _base="${_stem%_thin}"
      if [ -f "${_seed_dir}/${_base}.from_x.c" ]; then
        printf '%s\n' "${_seed_dir}/${_base}.from_x.c"
        return 0
      fi
      ;;
  esac

  _macro="$(rg -o 'XLANG_[A-Z0-9_]+_FROM_X' "$_x_src" | sort -u | head -n 1 || true)"
  if [ -n "$_macro" ]; then
    _macro_hits="$(rg -l "$_macro" "$_seed_dir" -g '*.from_x.c' | sort -u || true)"
    _hit_count="$(printf '%s\n' "$_macro_hits" | awk 'NF { n++ } END { print n + 0 }')"
    if [ "$_hit_count" = "1" ]; then
      printf '%s\n' "$_macro_hits"
      return 0
    fi
  fi

  return 1
}

if [ -z "$SEED_SRC" ]; then
  SEED_SRC="$(resolve_seed_src "$X_SRC" || true)"
fi

acquire_probe_lock() {
  _stem="$1"
  _lock_root="../tests/probes/prove_x_o"
  _lock_dir="${_lock_root}/${_stem}.lock"
  _lock_timeout="${XLANG_PROVE_LOCK_TIMEOUT:-15}"
  _start_ts="${SECONDS:-0}"

  mkdir -p "$_lock_root"
  while ! mkdir "$_lock_dir" 2>/dev/null; do
    if [ $(( ${SECONDS:-0} - _start_ts )) -ge "$_lock_timeout" ]; then
      echo "prove_x_o: timed out waiting for probe lock: $_lock_dir" >&2
      exit 1
    fi
    sleep 1
  done
  printf '%s\n' "$$" >"${_lock_dir}/pid"
  trap 'rm -rf "$_lock_dir"' EXIT INT TERM HUP
}

ensure_parent_dir() {
  _path="$1"
  mkdir -p "$(dirname "$_path")"
}

build_probe_dir() {
  _stem="$1"
  _dir="../tests/probes/prove_x_o/${_stem}"
  mkdir -p "$_dir"
  echo "$_dir"
}

extract_defined_symbols() {
  _obj="$1"
  _out="$2"
  nm "$_obj" | awk '$2 ~ /^[TWD]$/ { print $3 }' | sort -u >"$_out"
}

extract_rest_macro() {
  _seed_src="$1"
  if [ ! -f "$_seed_src" ]; then
    return 1
  fi
  rg -o 'XLANG_[A-Z0-9_]+_FROM_X' "$_seed_src" | sort -u | head -n 1
}

strip_libc_redecls() {
  _in="$1"
  _out="$2"
  {
    echo '/* prove_x_o prologue */'
    echo '#include <stddef.h>'
    echo '#include <stdint.h>'
    echo '#include <sys/types.h>'
    echo '#ifndef _WIN32'
    echo '#include <unistd.h>'
    echo '#include <fcntl.h>'
    echo '#include <errno.h>'
    echo '#endif'
    sed -e '/^#include /d' \
        -e '/^extern ssize_t read(/d' \
        -e '/^extern ssize_t write(/d' \
        -e '/^extern int32_t open(/d' \
        -e '/^extern int open(/d' \
        -e '/^extern int32_t fcntl(/d' \
        -e '/^extern int fcntl(/d' \
        -e '/^extern int32_t close(/d' \
        -e '/^extern int close(/d' \
        -e '/^extern uint8_t \* calloc(/d' \
        -e '/^extern uint8_t \* malloc(/d' \
        -e '/^extern void free(/d' \
        -e '/^extern char \* getenv(/d' \
        -e '/^extern uint8_t \* getenv(/d' \
        -e '/^extern int32_t unlink(/d' \
        -e '/^extern int unlink(/d' \
        -e '/^extern size_t strlen(/d' \
        "$_in"
  } >"$_out"
}

postprocess_generated_c() {
  _in="$1"
  _out="$2"
  strip_libc_redecls "$_in" "$_out"
  if [ "${G05_X_O_WEAK:-0}" = "1" ]; then
    perl -i -pe 's/^((?:void|int64_t|int32_t|int|size_t|uint32_t|uint64_t|uint8_t \*|uint8_t|const char \*|char \*))\s+(\w+)\s*\(/__attribute__((weak)) $1 $2(/' "$_out" || true
  fi
}

compile_x_generated_to_o() {
  _x_src="$1"
  _raw_c="$2"
  _gen_c="$3"
  _obj_o="$4"
  _log_e="$5"
  _log_cc="$6"

  if ! run_timeout "$TIMEOUT" "$XLANG_BIN" -E "$_x_src" >"$_raw_c" 2>"$_log_e"; then
    : >"$_raw_c"
    if ! run_timeout "$TIMEOUT" "$XLANG_BIN" -backend c -E "$_x_src" >"$_raw_c" 2>>"$_log_e"; then
      echo "prove_x_o: xlang -E failed for $_x_src" >&2
      echo "  log: $_log_e" >&2
      exit 1
    fi
  fi

  if [ ! -s "$_raw_c" ]; then
    echo "prove_x_o: generated C is empty: $_raw_c" >&2
    exit 1
  fi

  postprocess_generated_c "$_raw_c" "$_gen_c"

  if ! run_timeout "$TIMEOUT" "$CC_BIN" $BASE_CFLAGS -x c -c -o "$_obj_o" "$_gen_c" >/dev/null 2>"$_log_cc"; then
    echo "prove_x_o: cc -c failed for $_gen_c" >&2
    echo "  log: $_log_cc" >&2
    exit 1
  fi
}

compile_seed_to_o() {
  _seed_src="$1"
  _seed_o="$2"
  case "$_seed_src" in
    *.o)
      cp "$_seed_src" "$_seed_o"
      ;;
    *.inc)
      run_timeout "$TIMEOUT" bash scripts/cc_inc_tu.sh "$_seed_src" "$_seed_o"
      ;;
    *)
      run_timeout "$TIMEOUT" "$CC_BIN" $BASE_CFLAGS -c -o "$_seed_o" "$_seed_src"
      ;;
  esac
}

compile_seed_rest_to_o() {
  _seed_src="$1"
  _seed_rest_o="$2"
  _rest_macro="$3"
  run_timeout "$TIMEOUT" "$CC_BIN" $BASE_CFLAGS "-D${_rest_macro}" -c -o "$_seed_rest_o" "$_seed_src"
}

build_symbol_probe_source() {
  _syms_txt="$1"
  _probe_c="$2"
  _probe_label="$3"
  awk -v probe_label="$_probe_label" '
    BEGIN {
      count = 0
      print "/* prove_x_o symbol resolve probe */"
      print "#include <stddef.h>"
      print "#include <stdint.h>"
      print ""
    }
    NF {
      sym = $0
      cident = sym
      sub(/^_/, "", cident)
      syms[count] = sym
      cidents[count] = cident
      count++
    }
    END {
      for (i = 0; i < count; i++)
        printf "extern int %s(void);\n", cidents[i]
      print ""
      print "void *xlang_probe_refs[] = {"
      for (i = 0; i < count; i++) {
        sep = (i + 1 < count ? "," : "")
        printf "  (void *)%s%s\n", cidents[i], sep
      }
      print "};"
      print ""
      printf "int xlang_probe_%s(void) {\n", probe_label
      print "  return xlang_probe_refs[0] != NULL ? 0 : 1;"
      print "}"
    }
  ' "$_syms_txt" >"$_probe_c"
}

check_probe_resolution() {
  _target_obj="$1"
  _syms_txt="$2"
  _out_dir="$3"
  _tag="$4"

  _probe_c="${_out_dir}/${STEM}.${_tag}.probe.c"
  _probe_o="${_out_dir}/${STEM}.${_tag}.probe.o"
  _probe_link_o="${_out_dir}/${STEM}.${_tag}.probe_link.o"
  _probe_nm="${_out_dir}/${STEM}.${_tag}.probe_link.nm.txt"
  _probe_unresolved="${_out_dir}/${STEM}.${_tag}.probe_unresolved.txt"
  _probe_log="${_out_dir}/${STEM}.${_tag}.probe.log"

  rm -f "$_probe_c" "$_probe_o" "$_probe_link_o" "$_probe_nm" "$_probe_unresolved" "$_probe_log"
  build_symbol_probe_source "$_syms_txt" "$_probe_c" "$_tag"
  if ! run_timeout "$TIMEOUT" "$CC_BIN" $BASE_CFLAGS -x c -c -o "$_probe_o" "$_probe_c" >/dev/null 2>"$_probe_log"; then
    echo "prove_x_o: probe cc -c failed for $_probe_c" >&2
    echo "  log: $_probe_log" >&2
    exit 1
  fi
  if ! run_timeout "$TIMEOUT" "$CC_BIN" -r -nostdlib -o "$_probe_link_o" "$_probe_o" "$_target_obj" >/dev/null 2>>"$_probe_log"; then
    echo "prove_x_o: probe ld -r failed for $_target_obj" >&2
    echo "  log: $_probe_log" >&2
    exit 1
  fi
  nm "$_probe_link_o" >"$_probe_nm"
  awk '
    FNR == NR {
      want[$0] = 1
      next
    }
    $2 == "U" && want[$3] {
      print $3
    }
  ' "$_syms_txt" "$_probe_nm" | sort -u >"$_probe_unresolved"
  if [ -s "$_probe_unresolved" ]; then
    echo "prove_x_o: unresolved exported symbols remain after probe link: $_target_obj" >&2
    echo "  unresolved: $_probe_unresolved" >&2
    exit 1
  fi
  echo "  probe_${_tag}: $_probe_link_o"
  echo "  probe_nm_${_tag}: $_probe_nm"
}

XLANG_BIN="$(pick_xlang)" || {
  echo "prove_x_o: missing bootstrap binary (xlang/xlang-c/bootstrap_xlangc)" >&2
  exit 1
}

if [ "${XLANG_PROVE_SKIP_LINT:-0}" != "1" ]; then
  run_timeout "$TIMEOUT" sh scripts/x_bootstrap_safe_lint.sh "$X_SRC"
fi

STEM="$(basename "$X_SRC" .x)"
acquire_probe_lock "$STEM"
OUT_DIR="$(build_probe_dir "$STEM")"
RAW_C="${OUT_DIR}/${STEM}.raw.c"
GEN_C="${OUT_DIR}/${STEM}.gen.c"
OBJ_O="${OUT_DIR}/${STEM}.o"
NM_TXT="${OUT_DIR}/${STEM}.nm.txt"
SYMS_TXT="${OUT_DIR}/${STEM}.syms.txt"
LOG_E="${OUT_DIR}/${STEM}.e.log"
LOG_CC="${OUT_DIR}/${STEM}.cc.log"

ensure_parent_dir "$RAW_C"

rm -f "$RAW_C" "$GEN_C" "$OBJ_O" "$NM_TXT" "$SYMS_TXT" "$LOG_E" "$LOG_CC"

G05_X_O_WEAK="${G05_X_O_WEAK:-1}" compile_x_generated_to_o "$X_SRC" "$RAW_C" "$GEN_C" "$OBJ_O" "$LOG_E" "$LOG_CC"

nm "$OBJ_O" >"$NM_TXT"
extract_defined_symbols "$OBJ_O" "$SYMS_TXT"

echo "prove_x_o: ok"
echo "  x_src:      $X_SRC"
echo "  generated:  $GEN_C"
echo "  object:     $OBJ_O"
echo "  nm:         $NM_TXT"
echo "  symbols:    $SYMS_TXT"

if [ -n "$SEED_SRC" ]; then
  if [ ! -f "$SEED_SRC" ]; then
    echo "prove_x_o: missing seed source: $SEED_SRC" >&2
    exit 1
  fi
  SEED_O="${OUT_DIR}/${STEM}.seed.o"
  SEED_NM="${OUT_DIR}/${STEM}.seed.nm.txt"
  SEED_SYMS="${OUT_DIR}/${STEM}.seed.syms.txt"
  DIFF_ONLY_X="${OUT_DIR}/${STEM}.only_x.txt"
  DIFF_ONLY_SEED="${OUT_DIR}/${STEM}.only_seed.txt"
  REST_MACRO="${OUT_DIR}/${STEM}.rest_macro.txt"
  REST_O="${OUT_DIR}/${STEM}.rest.o"
  MERGED_O="${OUT_DIR}/${STEM}.merged.o"
  MERGED_NM="${OUT_DIR}/${STEM}.merged.nm.txt"
  MERGED_SYMS="${OUT_DIR}/${STEM}.merged.syms.txt"
  LD_R_LOG="${OUT_DIR}/${STEM}.ld_r.log"
  rm -f "$SEED_O" "$SEED_NM" "$SEED_SYMS" "$DIFF_ONLY_X" "$DIFF_ONLY_SEED" "$REST_MACRO" "$REST_O" "$MERGED_O" "$MERGED_NM" "$MERGED_SYMS" "$LD_R_LOG"
  compile_seed_to_o "$SEED_SRC" "$SEED_O"
  nm "$SEED_O" >"$SEED_NM"
  extract_defined_symbols "$SEED_O" "$SEED_SYMS"
  comm -23 "$SYMS_TXT" "$SEED_SYMS" >"$DIFF_ONLY_X" || true
  comm -13 "$SYMS_TXT" "$SEED_SYMS" >"$DIFF_ONLY_SEED" || true
  echo "  seed_obj:   $SEED_O"
  echo "  seed_nm:    $SEED_NM"
  echo "  only_x:     $DIFF_ONLY_X"
  echo "  only_seed:  $DIFF_ONLY_SEED"
  check_probe_resolution "$SEED_O" "$SYMS_TXT" "$OUT_DIR" "seed"

  if [ "${SEED_SRC##*.}" = "c" ]; then
    _rest_macro="$(extract_rest_macro "$SEED_SRC" || true)"
    if [ -n "$_rest_macro" ]; then
      printf '%s\n' "$_rest_macro" >"$REST_MACRO"
      compile_seed_rest_to_o "$SEED_SRC" "$REST_O" "$_rest_macro"
      if ! run_timeout "$TIMEOUT" "$CC_BIN" -r -nostdlib -o "$MERGED_O" "$OBJ_O" "$REST_O" > /dev/null 2>"$LD_R_LOG"; then
        echo "prove_x_o: ld -r failed for $X_SRC + $SEED_SRC(rest)" >&2
        echo "  log: $LD_R_LOG" >&2
        exit 1
      fi
      nm "$MERGED_O" >"$MERGED_NM"
      extract_defined_symbols "$MERGED_O" "$MERGED_SYMS"
      echo "  rest_macro: $_rest_macro"
      echo "  rest_obj:   $REST_O"
      echo "  merged_o:   $MERGED_O"
      echo "  merged_nm:  $MERGED_NM"
      echo "  merged_syms:$MERGED_SYMS"
      check_probe_resolution "$MERGED_O" "$SYMS_TXT" "$OUT_DIR" "merged"
    fi
  fi
fi

exit 0
