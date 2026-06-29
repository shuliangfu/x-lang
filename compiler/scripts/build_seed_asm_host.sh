#!/bin/sh
# build_seed_asm_host.sh — 用 shux-c -E 将 asm 后端编成宿主 .o，供 bootstrap-driver-seed 链入（无 weak 桩、无 runtime 回退）。
# 用法：在 compiler 目录 ./scripts/build_seed_asm_host.sh
# 依赖：./shux-c（make shux-c）

set -e
cd "$(dirname "$0")/.."
OUT_DIR=build_asm/seed_host
mkdir -p "$OUT_DIR"

_seed_os="$(uname -s 2>/dev/null | tr '[:upper:]' '[:lower:]')"
_seed_arch="$(uname -m 2>/dev/null | tr '[:upper:]' '[:lower:]')"
case "$_seed_arch" in x86_64|amd64) _seed_arch="x86_64" ;; aarch64|arm64) _seed_arch="arm64" ;; esac
case "$_seed_os" in darwin) _seed_os="darwin" ;; linux) _seed_os="linux" ;; esac
HOST_SEED="./seeds/bootstrap_shuxc.${_seed_os}.${_seed_arch}"

can_seed_run() {
  [ -x "$1" ] || return 1
  _tmp="/tmp/shux_build_seed_can_run_$$.su"
  printf '%s\n' 'function main(): i32 { return 0; }' >"$_tmp"
  if "$1" -c "$_tmp" >/dev/null 2>&1; then
    rm -f "$_tmp" 2>/dev/null || true
    return 0
  fi
  rm -f "$_tmp" 2>/dev/null || true
  return 1
}

SHUX_E=./bootstrap_shuxc
if can_seed_run "$HOST_SEED"; then
  SHUX_E="$HOST_SEED"
elif can_seed_run ./bootstrap_shuxc; then
  SHUX_E=./bootstrap_shuxc
elif can_seed_run ./shux-c; then
  SHUX_E=./shux-c
elif can_seed_run ./shux-seed-phase1; then
  SHUX_E=./shux-seed-phase1
elif can_seed_run ./shux-sx; then
  SHUX_E=./shux-sx
elif can_seed_run ./shux; then
  SHUX_E=./shux
elif can_seed_run ./shux_asm; then
  SHUX_E=./shux_asm
fi
if [ ! -x "$SHUX_E" ]; then
  echo "build_seed_asm_host: 缺少可执行 seed（shux-seed-phase1 / shux-c）" >&2
  exit 1
fi

# `asm.sx -E` 依赖最新的 .sx pipeline/runtime 修复；若已有 `shux-sx`，优先用它而不是
# 更老的 bootstrap_shuxc/host seed，避免 0 字节且无 stderr 的假失败。
SHUX_ASM_E="${SHUX_ASM_E:-$SHUX_E}"
if can_seed_run ./shux-sx; then
  SHUX_ASM_E=./shux-sx
elif can_seed_run ./shux; then
  SHUX_ASM_E=./shux
fi

CC="${CC:-cc}"
CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc -Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-sign-compare"
if $CC --version 2>/dev/null | grep -qi clang; then
  CFLAGS="$CFLAGS -Wno-logical-op-parentheses"
fi

LIB_ASM="-L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -L src/pipeline -L src/codegen"
LIB_ASM_MIN="-L src/asm"

# asm_seed_full.sx -E：seed partial 专用 full 入口；普通 runtime `asm.sx` 已瘦成薄桥，不再适合作为 partial 源。
# 长任务心跳，避免 Docker 内静默数分钟像卡住。
run_asm_sx_emit_c() {
  _out="$1"
  _err="$2"
  _start=$(date +%s)
  _run() {
    SHUX_STACK_LIMIT_MB="${SHUX_STACK_LIMIT_MB:-512}" "$SHUX_ASM_E" $LIB_ASM -E src/asm/asm_seed_full.sx >"$_out" 2>"$_err"
  }
  _run_bg() {
    # 回退仍须全量 -L；仅 -L src/asm 无法 resolve import codegen/ast 等。
    SHUX_STACK_LIMIT_MB="${SHUX_STACK_LIMIT_MB:-512}" "$SHUX_ASM_E" $LIB_ASM -E src/asm/asm_seed_full.sx >"$_out" 2>"$_err"
  }
  _wait_with_heartbeat() {
    _pid=$1
    _label=$2
    while kill -0 "$_pid" 2>/dev/null; do
      _elapsed=$(( $(date +%s) - _start ))
      _bytes=0
      [ -f "$_out" ] && _bytes=$(wc -c <"$_out" | tr -d ' ')
      echo "[$(date +%H:%M:%S)] build_seed_asm_host: ${_label} ... ${_elapsed}s, out=${_bytes} bytes" >&2
      sleep 15
    done
    wait "$_pid"
    return $?
  }
  # -E 成功写 stdout 后宿主清理阶段可能 abort(134)，但 C 已落盘；有实质输出则视为成功。
  # 兼容两种合法形态：
  # 1) 旧的 full emit：大于 50KiB，含 backend_*。
  # 2) 现在的 thin bridge：约 1KiB，含 asm_asm_codegen_* 转发入口。
  _emit_c_usable() {
    [ -s "$_out" ] || return 1
    _bytes=$(wc -c <"$_out" | tr -d ' ')
    if [ "$_bytes" -ge 50000 ] && grep -q 'backend_' "$_out" 2>/dev/null; then
      return 0
    fi
    if [ "$_bytes" -ge 800 ] && \
       grep -q 'asm_asm_codegen_ast' "$_out" 2>/dev/null && \
       grep -q 'asm_asm_codegen_elf_o' "$_out" 2>/dev/null; then
      return 0
    fi
    return 1
  }
  rm -f "$_out" "$_err"
  _run &
  _pid=$!
  _wait_with_heartbeat "$_pid" "asm.sx -E LIB_ASM"
  _erc=$?
  if _emit_c_usable; then
    return 0
  fi
  [ "$_erc" -eq 0 ] && [ -s "$_out" ] && return 0
  echo "build_seed_asm_host: LIB_ASM -E exit=${_erc}, retry once ..." >&2
  if [ -s "$_err" ]; then tail -10 "$_err" >&2; fi
  rm -f "$_out" "$_err"
  _start=$(date +%s)
  _run &
  _pid=$!
  _wait_with_heartbeat "$_pid" "asm.sx -E retry"
  _erc=$?
  if _emit_c_usable; then
    return 0
  fi
  if [ -s "$_err" ]; then tail -20 "$_err" >&2; fi
  return 1
}

dedupe_slice() {
  if [ "${SHUX_ALLOW_GEN_PATCH:-0}" = "1" ]; then
    perl -i -ne 'print unless /^struct shux_slice_uint8_t/ && $seen++' "$1" 2>/dev/null || true
  fi
}

# -E 落盘/沿用 asm_full_gen.c 是否值得走 fix+cc（拒绝过短截断；uint8_t[N] name 由 fix_asm_full_gen_c.pl 修复）。
# 与 _emit_c_usable 保持同一判定：既接受旧 full emit，也接受新的 thin bridge emit。
asm_full_gen_c_usable_for_fix() {
  _c="$1"
  [ -s "$_c" ] || return 1
  _bytes=$(wc -c <"$_c" | tr -d ' ')
  if [ "$_bytes" -ge 50000 ] && grep -q 'backend_' "$_c" 2>/dev/null; then
    return 0
  fi
  if [ "$_bytes" -ge 800 ] && \
     grep -q 'asm_asm_codegen_ast' "$_c" 2>/dev/null && \
     grep -q 'asm_asm_codegen_elf_o' "$_c" 2>/dev/null; then
    return 0
  fi
  return 1
}

# fix perl 三件套 + lea 自递归清理
run_fix_asm_full_c_pipeline() {
  _c="$1"
  [ "${SHUX_ALLOW_GEN_PATCH:-0}" = "1" ] || return 0
  if grep -q 'struct ast_ASTArena {' "$_c" 2>/dev/null; then
    perl scripts/fix_slim_arena_gen_c.pl "$_c"
  fi
  perl scripts/fix_backend_enc_recursive_gen_c.pl "$_c"
  perl scripts/fix_asm_full_gen_c.pl "$_c"
  perl -i -0777 -pe 's/int32_t backend_enc_lea_rbp_to_rax_arch\(struct platform_elf_ElfCodegenCtx \* elf_ctx, int32_t offset, int32_t ta\) \{\n  return backend_enc_lea_rbp_to_rax_arch\(elf_ctx, offset, ta\);\n\}\n//s' "$_c" 2>/dev/null || true
}

# cc -c asm_full_gen.c → asm_full.o（失败时可选从 pre_fix/.bak 重跑 fix）
try_cc_asm_full_gen_c() {
  _c="$1"
  rm -f "$ASM_FULL_O" "$OUT_DIR/asm_full_merged.o" "$OUT_DIR/asm_full_with_enc_stubs.o"
  if $CC $CFLAGS -c "$_c" -o "$ASM_FULL_O" 2>"$OUT_DIR/cc.err"; then
    return 0
  fi
  echo "[$(date +%H:%M:%S)] build_seed_asm_host: cc FAILED ($(grep -c 'error:' "$OUT_DIR/cc.err" 2>/dev/null || echo 0) errors)" >&2
  tail -15 "$OUT_DIR/cc.err" >&2
  if [ "${SHUX_ALLOW_GEN_PATCH:-0}" != "1" ]; then
    return 1
  fi
  for _retry in "${ASM_FULL_C}.pre_fix" "${ASM_FULL_C}.bak"; do
    [ -f "$_retry" ] || continue
    asm_full_gen_c_usable_for_fix "$_retry" || continue
    echo "build_seed_asm_host: cc 失败，重试 fix+cc from ${_retry} ..." >&2
    cp -f "$_retry" "$ASM_FULL_C"
    run_fix_asm_full_c_pipeline "$ASM_FULL_C"
    rm -f "$ASM_FULL_O"
    if $CC $CFLAGS -c "$ASM_FULL_C" -o "$ASM_FULL_O" 2>"$OUT_DIR/cc.err"; then
      echo "[$(date +%H:%M:%S)] build_seed_asm_host: cc OK from ${_retry}" >&2
      return 0
    fi
  done
  return 1
}

# Mach-O nm 带前导 _；ELF (Linux/Alpine) 不带。统一检测符号是否存在。
has_nm_sym() {
  _obj="$1"
  _want="$2"
  _bare="${_want#_}"
  nm "$_obj" 2>/dev/null | awk -v w="$_bare" '{
    s = $3
    sub(/^_/, "", s)
    if (s == w && ($2 ~ /^[Tt]$/ || $2 ~ /^[Tt] /)) found = 1
  } END { exit !found }'
}

# 真 partial 须含强符号 backend_asm_codegen_ast_seed_mega（phase1 弱桩为 W）。
has_real_partial_seed_mega() {
  _obj="$1"
  nm "$_obj" 2>/dev/null | awk '/ T / {
    s=$3; sub(/^_/, "", s)
    if (s == "backend_asm_codegen_ast_seed_mega") found=1
  } END { exit !found }'
}

BACKEND_FALLBACK_SRC="src/asm/backend_seed_mega_fallback.c"

build_backend_partial_from_c_fallback() {
  rm -f "$BACKEND_PARTIAL"
  echo "build_seed_asm_host: fallback cc $BACKEND_FALLBACK_SRC -> $BACKEND_PARTIAL" >&2
  if ! $CC $CFLAGS -c "$BACKEND_FALLBACK_SRC" -o "$BACKEND_PARTIAL" 2>"$OUT_DIR/backend_seed_mega_fallback.err"; then
    tail -20 "$OUT_DIR/backend_seed_mega_fallback.err" >&2
    rm -f "$BACKEND_PARTIAL"
    return 1
  fi
  if ! has_real_partial_seed_mega "$BACKEND_PARTIAL"; then
    echo "build_seed_asm_host: fallback partial 缺少强 seed_mega" >&2
    rm -f "$BACKEND_PARTIAL"
    return 1
  fi
  return 0
}

# 从 .o 收集 backend/peephole/platform 导出符号名（保留 nm 原样：Darwin 带 _，ELF 不带）。
collect_backend_export_syms() {
  _obj="$1"
  _out="$2"
  nm "$_obj" | awk '/ T / {
    s=$3
    if (s ~ /^_?(backend_|peephole_|platform_elf|platform_macho|platform_coff)/) print s
  }' | sort -u >"$_out"
}

# GNU ld -r + version script 不会把未列出符号降为 local；objcopy 逐个 localize，避免与 seed 其它 .o 重复定义。
localize_elf_partial_non_exported() {
  _out_o="$1"
  _syms="$2"
  command -v objcopy >/dev/null 2>&1 || return 0
  nm "$_out_o" 2>/dev/null | awk '/ T / {print $3}' | while read -r _sym; do
    [ -z "$_sym" ] && continue
    _bare="${_sym#_}"
    if grep -qxF "$_sym" "$_syms" 2>/dev/null || grep -qxF "$_bare" "$_syms" 2>/dev/null; then
      continue
    fi
    objcopy --localize-symbol="$_bare" "$_out_o" 2>/dev/null || objcopy --localize-symbol="$_sym" "$_out_o" 2>/dev/null || true
  done
}

# 按宿主 ld 能力做 partial export：Darwin -exported_symbols_list；GNU ld --version-script。
ld_partial_export() {
  _syms="$1"
  _out_o="$2"
  _in_o="$3"
  _ver="$OUT_DIR/asm_backend_export.ver"
  if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    # Mach-O：符号表须带前导 _
    _macho_syms="$OUT_DIR/asm_backend_export_macho.txt"
    : >"$_macho_syms"
    while read -r _s; do
      [ -z "$_s" ] && continue
      case "$_s" in _*) echo "$_s" >>"$_macho_syms" ;; *) echo "_$_s" >>"$_macho_syms" ;; esac
    done < "$_syms"
    ld -r -exported_symbols_list "$_macho_syms" -o "$_out_o" "$_in_o"
    return $?
  fi
  # GNU ld (Alpine/Linux)：version script 标记 global；再 objcopy 把其余 T 符号降为 local
  {
    echo "{"
    echo "  global:"
    while read -r _s; do
      [ -z "$_s" ] && continue
      echo "    ${_s#_};"
    done < "$_syms"
    echo "  local: *;"
    echo "};"
  } >"$_ver"
  ld -r --version-script="$_ver" -o "$_out_o" "$_in_o"
  localize_elf_partial_non_exported "$_out_o" "$_syms"
}

# asm.sx 全量 -E：ld -r 仅导出 backend/peephole/platform 入口，避免与 pipeline_sx.o / codegen_sx.o 重复符号
ASM_FULL_C="$OUT_DIR/asm_full_gen.c"
ASM_FULL_O="$OUT_DIR/asm_full.o"
BACKEND_PARTIAL="$OUT_DIR/asm_backend_partial.o"
SYMS="$OUT_DIR/asm_backend_export.txt"

# G-06：冷启动种子 partial（make clean 后 asm.sx -E 可能失败时沿用）
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m 2>/dev/null | tr '[:upper:]' '[:lower:]')"
case "$arch" in x86_64|amd64) arch="x86_64" ;; aarch64|arm64) arch="arm64" ;; esac
case "$os" in darwin) os="darwin" ;; linux) os="linux" ;; esac
SEED_PARTIAL="seeds/asm_backend_partial.${os}.${arch}.o"
if [ ! -f "$BACKEND_PARTIAL" ] && [ -f "$SEED_PARTIAL" ] && [ -s "$SEED_PARTIAL" ] \
    && has_real_partial_seed_mega "$SEED_PARTIAL"; then
  mkdir -p "$OUT_DIR"
  cp -f "$SEED_PARTIAL" "$BACKEND_PARTIAL"
  echo "build_seed_asm_host: seed partial (seed_mega) <- $SEED_PARTIAL" >&2
  exit 0
fi
# phase1 弱桩 partial 无强符号 seed_mega，须用 shux-seed-phase1 重新 -E asm.sx
if [ -f "$BACKEND_PARTIAL" ] && ! has_real_partial_seed_mega "$BACKEND_PARTIAL"; then
  echo "build_seed_asm_host: phase1 stub partial (no strong seed_mega), regen via asm.sx -E ..." >&2
  rm -f "$BACKEND_PARTIAL"
fi

# `asm.sx` 现已是极薄桥接层；seed partial 的真实实现来自 backend/peephole/platform/arch。
# 因此不要再因为 `asm.sx` 或上次落盘的 `asm_full_gen.c` 较新就强制重建 partial，
# 否则会把已有真实 partial 误判为过期，并尝试从 thin bridge 重新生成而失败。
seed_partial_needs_regen() {
  [ ! -f "$BACKEND_PARTIAL" ] && return 0
  [ "src/asm/asm_seed_full.sx" -nt "$BACKEND_PARTIAL" ] && return 0
  [ "$BACKEND_FALLBACK_SRC" -nt "$BACKEND_PARTIAL" ] && return 0
  [ "src/asm/backend.sx" -nt "$BACKEND_PARTIAL" ] && return 0
  [ "src/asm/peephole.sx" -nt "$BACKEND_PARTIAL" ] && return 0
  [ "src/asm/platform/elf.sx" -nt "$BACKEND_PARTIAL" ] && return 0
  [ "src/asm/arch/arm64_enc.sx" -nt "$BACKEND_PARTIAL" ] && return 0
  [ "src/asm/arch/arm64.sx" -nt "$BACKEND_PARTIAL" ] && return 0
  [ "src/asm/arch/x86_64_enc.sx" -nt "$BACKEND_PARTIAL" ] && return 0
  [ "src/asm/arch/x86_64.sx" -nt "$BACKEND_PARTIAL" ] && return 0
  [ "src/asm/arch/riscv64_enc.sx" -nt "$BACKEND_PARTIAL" ] && return 0
  [ "src/asm/arch/riscv64.sx" -nt "$BACKEND_PARTIAL" ] && return 0
  [ "src/asm/backend_enc_dispatch.o" -nt "$BACKEND_PARTIAL" ] && return 0
  [ "src/asm/backend_arch_emit_dispatch.o" -nt "$BACKEND_PARTIAL" ] && return 0
  return 1
}

if seed_partial_needs_regen; then
  echo "build_seed_asm_host: asm_seed_full.sx 全量 -E ..."
  ASM_TMP="$OUT_DIR/asm_full_gen.c.tmp"
  # 须全量 -E（勿 -E-extern：仅 ~100 行 typeck/asm 桩，缺 backend/peephole/platform，cc 失败或沿用陈旧 x86_64 partial.o）。
  run_asm_sx_emit_c "$ASM_TMP" "$OUT_DIR/asm_full_gen.err"
  _erc=$?
  if [ "$_erc" -ne 0 ]; then
    echo "build_seed_asm_host: asm_seed_full.sx -E exit=${_erc}" >&2
    if [ -s "$OUT_DIR/asm_full_gen.err" ]; then
      tail -20 "$OUT_DIR/asm_full_gen.err" >&2
    else
      echo "build_seed_asm_host: (no stderr; bootstrap may have crashed — run preflight_g06_coldstart.sh --asm-e)" >&2
    fi
    # -E OOM(137)/Killed 时若已有可用 asm_full_gen.c（上次 134 落盘），继续 fix+cc
    if [ -s "$ASM_FULL_C" ] && asm_full_gen_c_usable_for_fix "$ASM_FULL_C"; then
      # OOM 落盘可能短于 .bak；优先用更大且可用的 bak
      if [ -f "${ASM_FULL_C}.bak" ] && asm_full_gen_c_usable_for_fix "${ASM_FULL_C}.bak" \
          && [ "$(wc -c <"${ASM_FULL_C}.bak" | tr -d ' ')" -gt "$(wc -c <"$ASM_FULL_C" | tr -d ' ')" ]; then
        cp -f "${ASM_FULL_C}.bak" "$ASM_FULL_C"
        echo "build_seed_asm_host: -E 失败，沿用 ${ASM_FULL_C}.bak ($(wc -c <"$ASM_FULL_C" | tr -d ' ') bytes)" >&2
      else
        echo "build_seed_asm_host: -E 失败，沿用已有 $ASM_FULL_C ($(wc -c <"$ASM_FULL_C" | tr -d ' ') bytes)" >&2
      fi
      rm -f "$ASM_TMP"
    elif [ -f "${ASM_FULL_C}.bak" ] && asm_full_gen_c_usable_for_fix "${ASM_FULL_C}.bak"; then
      cp -f "${ASM_FULL_C}.bak" "$ASM_FULL_C"
      echo "build_seed_asm_host: -E 失败，沿用 ${ASM_FULL_C}.bak ($(wc -c <"$ASM_FULL_C" | tr -d ' ') bytes)" >&2
      rm -f "$ASM_TMP"
    elif [ -f "$BACKEND_PARTIAL" ] && has_real_partial_seed_mega "$BACKEND_PARTIAL"; then
      echo "build_seed_asm_host: asm_seed_full.sx -E 失败，沿用已有 $BACKEND_PARTIAL" >&2
      rm -f "$ASM_TMP"
      exit 0
    else
      rm -f "$ASM_TMP"
      if build_backend_partial_from_c_fallback; then
        echo "build_seed_asm_host: asm_seed_full.sx -E 失败，改用源码 fallback partial" >&2
        exit 0
      fi
      echo "build_seed_asm_host: asm_seed_full.sx -E 失败且无已有 $ASM_FULL_C / $BACKEND_PARTIAL / fallback partial" >&2
      exit 1
    fi
  else
    mv -f "$ASM_TMP" "$ASM_FULL_C"
  fi
  dedupe_slice "$ASM_FULL_C"
  if ! asm_full_gen_c_usable_for_fix "$ASM_FULL_C"; then
    if build_backend_partial_from_c_fallback; then
      echo "build_seed_asm_host: $ASM_FULL_C 不可用，改用源码 fallback partial" >&2
      exit 0
    fi
    echo "build_seed_asm_host: $ASM_FULL_C 不可用（畸形 -E 截断）" >&2
    exit 1
  fi
  cp -f "$ASM_FULL_C" "${ASM_FULL_C}.pre_fix"
  _t0=$(date +%s)
  if [ "${SHUX_ALLOW_GEN_PATCH:-0}" = "1" ]; then
    echo "[$(date +%H:%M:%S)] build_seed_asm_host: fix perl scripts ..." >&2
    run_fix_asm_full_c_pipeline "$ASM_FULL_C"
    echo "[$(date +%H:%M:%S)] build_seed_asm_host: fix perl done ($(( $(date +%s) - _t0 ))s)" >&2
  else
    echo "[$(date +%H:%M:%S)] build_seed_asm_host: gen patch disabled (SHUX_ALLOW_GEN_PATCH=1 to enable)" >&2
  fi
  _t0=$(date +%s)
  echo "[$(date +%H:%M:%S)] build_seed_asm_host: cc -c asm_full_gen.c ..." >&2
  if ! try_cc_asm_full_gen_c "$ASM_FULL_C"; then
    if [ -f "$BACKEND_PARTIAL" ]; then
      echo "build_seed_asm_host: cc asm_full_gen.c 失败，沿用已有 $BACKEND_PARTIAL" >&2
      exit 0
    fi
    echo "build_seed_asm_host: cc asm_full_gen.c 失败且无已有 $BACKEND_PARTIAL" >&2
    exit 1
  fi
  echo "[$(date +%H:%M:%S)] build_seed_asm_host: cc OK ($(( $(date +%s) - _t0 ))s, $(wc -c <"$ASM_FULL_O" | tr -d ' ') bytes -> $ASM_FULL_O)" >&2
  # cc 成功后保留 raw -E 落盘副本，供 OOM/cc 失败时重试
  cp -f "${ASM_FULL_C}.pre_fix" "${ASM_FULL_C}.bak" 2>/dev/null || true
  if [ "${SHUX_ALLOW_GEN_PATCH:-0}" = "1" ]; then
    ENC_STUB_C="$OUT_DIR/asm_full_enc_link_stubs.c"
    ENC_STUB_O="$OUT_DIR/asm_full_enc_link_stubs.o"
    _stub_scan="$ASM_FULL_O"
    for _so in pipeline_sx.o src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o; do
      [ -f "$_so" ] && _stub_scan="$_stub_scan $_so"
    done
    if perl scripts/gen_asm_full_link_stubs.pl "$ENC_STUB_C" $_stub_scan 2>/dev/null; then
      if [ -s "$ENC_STUB_C" ] && grep -q '__attribute__((weak))' "$ENC_STUB_C" 2>/dev/null; then
        if $CC $CFLAGS -c "$ENC_STUB_C" -o "$ENC_STUB_O" 2>/dev/null; then
          ASM_MERGED_ENC="$OUT_DIR/asm_full_with_enc_stubs.o"
          if ld -r "$ASM_FULL_O" "$ENC_STUB_O" -o "$ASM_MERGED_ENC" 2>/dev/null; then
            ASM_FULL_O="$ASM_MERGED_ENC"
            echo "build_seed_asm_host: merged enc/emit weak stubs -> $ASM_FULL_O" >&2
          fi
        fi
      fi
    fi
  fi
  if [ -f build_asm/backend.o ]; then
    ASM_MERGED="$OUT_DIR/asm_full_merged.o"
    if ld -r "$ASM_FULL_O" build_asm/backend.o -o "$ASM_MERGED" 2>/dev/null; then
      ASM_FULL_O="$ASM_MERGED"
      echo "build_seed_asm_host: merged build_asm/backend.o -> $ASM_FULL_O" >&2
    fi
  fi
  # 从 asm_full.o 导出 backend_/peephole_/platform_{elf,macho,coff}_*，供 codegen_sx.o 与 seed bridge 解析。
  # 剔除 backend_*_dispatch.c 已提供的符号，避免与 USER_ASM_LINK 重复定义（须四份 dispatch .o 均已编译）。
  collect_backend_export_syms "$ASM_FULL_O" "$SYMS"
  : >"$OUT_DIR/asm_dispatch_syms.txt"
  for _dof in src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o \
              src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o \
              src/asm/pipeline_abi_f32_xmm.o; do
    if [ ! -f "$_dof" ]; then
      echo "build_seed_asm_host: missing $_dof (make bootstrap-driver-seed 须先编 dispatch TU)" >&2
      exit 1
    fi
    nm "$_dof" 2>/dev/null \
      | awk '/ T / && $3 ~ /^_?(backend_|arch_|pipeline_asm_abi|pipeline_asm_emit)/ {print $3}' >>"$OUT_DIR/asm_dispatch_syms.txt"
  done
  sort -u -o "$OUT_DIR/asm_dispatch_syms.txt" "$OUT_DIR/asm_dispatch_syms.txt"
  if [ -s "$OUT_DIR/asm_dispatch_syms.txt" ]; then
    grep -v -F -f "$OUT_DIR/asm_dispatch_syms.txt" "$SYMS" >"$SYMS.tmp" || true
    mv -f "$SYMS.tmp" "$SYMS"
  fi
  for _extra in arch_arm64_enc_enc_mov_imm32_to_w0 arch_arm64_enc_enc_sub_rax_rbx \
      arch_x86_64_enc_enc_ret_imm32 arch_riscv64_enc_enc_ret_imm32; do
    if has_nm_sym "$ASM_FULL_O" "$_extra"; then
      echo "$_extra" >>"$SYMS"
    fi
  done
  # backend_enc_dispatch.c 依赖 arch_*_enc_enc_*，backend_arch_emit_dispatch.c 依赖 arch_*_emit_*。
  nm "$ASM_FULL_O" | awk '/ T / && $3 ~ /^_?arch_(arm64|x86_64|riscv64)_enc_enc_/ {print $3}' >>"$SYMS"
  nm "$ASM_FULL_O" | awk '/ T / && $3 ~ /^_?arch_(arm64|x86_64|riscv64)_emit_/ {print $3}' >>"$SYMS"
  sort -u -o "$SYMS" "$SYMS"
  # dispatch .o 已提供的 arch_*（如 enc_cdqe_rax）勿再从 partial 导出，避免重复定义。
  if [ -s "$OUT_DIR/asm_dispatch_syms.txt" ]; then
    grep -v -F -f "$OUT_DIR/asm_dispatch_syms.txt" "$SYMS" >"$SYMS.tmp" || cp "$SYMS" "$SYMS.tmp"
    mv -f "$SYMS.tmp" "$SYMS"
  fi
  _use_c_fallback_partial=0
  if ! has_nm_sym "$ASM_FULL_O" "backend_asm_codegen_ast_seed_mega"; then
    _bc=$(nm "$ASM_FULL_O" 2>/dev/null | awk '/ T / && $3 ~ /^_?backend_/ {n++} END {print n+0}')
    if [ "${_bc:-0}" -lt 180 ]; then
      if build_backend_partial_from_c_fallback; then
        echo "build_seed_asm_host: $ASM_FULL_O 缺少 seed_mega（backend T=${_bc:-0}），改用源码 fallback partial" >&2
        _use_c_fallback_partial=1
      else
        echo "build_seed_asm_host: $ASM_FULL_O 缺少 backend_asm_codegen_ast_seed_mega（backend T=${_bc:-0}）" >&2
        exit 1
      fi
    fi
    [ "$_use_c_fallback_partial" -eq 0 ] && echo "build_seed_asm_host: WARN 无 seed_mega，partial 仅导出 ${_bc} 个 backend_* 符号" >&2
  fi
  if [ "$_use_c_fallback_partial" -eq 0 ]; then
    echo "  ld partial export ($(wc -l <"$SYMS" | tr -d ' ') syms) -> $BACKEND_PARTIAL"
    if ! ld_partial_export "$SYMS" "$BACKEND_PARTIAL" "$ASM_FULL_O"; then
      if [ -f "$BACKEND_PARTIAL" ]; then
        echo "build_seed_asm_host: ld -r 失败，沿用已有 $BACKEND_PARTIAL" >&2
        exit 0
      fi
      echo "build_seed_asm_host: ld -r 失败且无已有 $BACKEND_PARTIAL" >&2
      exit 1
    fi
  fi
fi

if [ -s "$BACKEND_PARTIAL" ] && has_real_partial_seed_mega "$BACKEND_PARTIAL"; then
  mkdir -p "$(dirname "$SEED_PARTIAL")"
  cp -f "$BACKEND_PARTIAL" "$SEED_PARTIAL"
fi

echo "build_seed_asm_host OK ($OUT_DIR)"
