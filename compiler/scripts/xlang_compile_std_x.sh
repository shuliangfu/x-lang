#!/bin/sh
# xlang_compile_std_x.sh — compile std/*.x → .o (Makefile std-objs + shell-primary)
#
# PLATFORM: SHARED — host product path for pure .x std leaves (asm prefer, C fallback).
# Authority for host pick + -E/cc / -backend asm + per-leaf mode table.
# Makefile must only thin-call this script (wave811 body; wave825 catalog ensure;
# wave827 FORCE dep-thin; wave895 list→mk multi-target).
#
# Usage (cwd = compiler/):
#   xlang_compile_std_x.sh ensure <out.o>                             # wave825 catalog
#   xlang_compile_std_x.sh auto <out.o>                               # alias of ensure
#   xlang_compile_std_x.sh list                                       # catalog keys
#   xlang_compile_std_x.sh --check                                    # catalog + thin greps
#   xlang_compile_std_x.sh <xlang-bin|auto|auto-soft|auto-merge|auto-soft-merge> <x-path> <out.o>
#
# Modes (catalog or explicit):
#   auto              hard-fail if no host; pick xlang_asm → xlang → xlang-c
#   auto-soft         same pick; exit 0 if no host (F-ZC soft leaves)
#   auto-merge        compile to ${out%.o}_main.o then ld -r → out.o (hard)
#   auto-soft-merge   same merge; exit 0 if no host (socketio)
#   <path-to-bin>     use explicit driver
#
# wave811 (G.7 有则补全): host pick + soft/hard + socketio merge body here;
#   Makefile lost multi-line if-ladder (thin-call auto|auto-soft|auto-soft-merge).
# wave825 (G.7 有则补全): product mode|x_path table lives here; Makefile thin-call
#   `ensure $@` only. NOT physical delete —
#   thin edges + formal_mod + B2 ensure + mk lists still form std_core_product_make_graph.
# wave827 (G.7 有则补全): FORCE dep-thin — Makefile prereqs are FORCE + script only;
#   shell owns catalog source mtime (skip up-to-date). NOT physical delete; thin edges
#   + formal_mod FORCE + B2 try-heat + mk lists still form std_core_product_make_graph residual.
# wave895 (G.7 有则补全): make-graph inventory → mk/std_x_product_objs.mk;
#   Makefile multi-target $(STD_X_PRODUCT_OBJS) FORCE thin ensure only.
#   NOT physical delete; residual thin edges + B2 try-heat + other mk lists hybrid.
#
# auto: prefer xlang_asm → xlang → xlang-c (lib modules need asm .o; do not prefer xlang-c
# unless XLANG_COMPILE_STD_USE_C=1).
set -e

# ---------------------------------------------------------------------------
# wave825: std_x shell-primary catalog (G.7 有则补全; not physical delete)
# Spec: mode|x_path
#   mode = auto | auto-soft | auto-soft-merge | auto-merge
#   x_path = ../std/.../*.x from compiler/ cwd
# Keys accept: ../std/.../x.o | std/.../x.o | *std/.../x.o
# Honesty COUNT = 21 (cli.o moved to formal_mod; was 22).
# ---------------------------------------------------------------------------

std_x_key_for_out() {
  _o="$1"
  case "$_o" in
    ../std/async/scheduler.o|std/async/scheduler.o|*std/async/scheduler.o) printf '%s' "std/async/scheduler.o" ;;
    ../std/async/future.o|std/async/future.o|*std/async/future.o) printf '%s' "std/async/future.o" ;;
    ../std/channel/channel.o|std/channel/channel.o|*std/channel/channel.o) printf '%s' "std/channel/channel.o" ;;
    ../std/backtrace/backtrace.o|std/backtrace/backtrace.o|*std/backtrace/backtrace.o) printf '%s' "std/backtrace/backtrace.o" ;;
    ../std/uuid/uuid.o|std/uuid/uuid.o|*std/uuid/uuid.o) printf '%s' "std/uuid/uuid.o" ;;
    ../std/url/url.o|std/url/url.o|*std/url/url.o) printf '%s' "std/url/url.o" ;;
    ../std/security/security.o|std/security/security.o|*std/security/security.o) printf '%s' "std/security/security.o" ;;
    ../std/config/config.o|std/config/config.o|*std/config/config.o) printf '%s' "std/config/config.o" ;;
    ../std/cache/cache.o|std/cache/cache.o|*std/cache/cache.o) printf '%s' "std/cache/cache.o" ;;
    ../std/trace/trace.o|std/trace/trace.o|*std/trace/trace.o) printf '%s' "std/trace/trace.o" ;;
    ../std/task/task.o|std/task/task.o|*std/task/task.o) printf '%s' "std/task/task.o" ;;
    ../std/schema/schema.o|std/schema/schema.o|*std/schema/schema.o) printf '%s' "std/schema/schema.o" ;;
    ../std/db/kv/kv.o|std/db/kv/kv.o|*std/db/kv/kv.o) printf '%s' "std/db/kv/kv.o" ;;
    ../std/db/arrow/arrow.o|std/db/arrow/arrow.o|*std/db/arrow/arrow.o) printf '%s' "std/db/arrow/arrow.o" ;;
    ../std/db/sqlite/sqlite.o|std/db/sqlite/sqlite.o|*std/db/sqlite/sqlite.o) printf '%s' "std/db/sqlite/sqlite.o" ;;
    ../std/elf/elf.o|std/elf/elf.o|*std/elf/elf.o) printf '%s' "std/elf/elf.o" ;;
    ../std/regex/regex.o|std/regex/regex.o|*std/regex/regex.o) printf '%s' "std/regex/regex.o" ;;
    ../std/unicode/unicode.o|std/unicode/unicode.o|*std/unicode/unicode.o) printf '%s' "std/unicode/unicode.o" ;;
    ../std/socketio/socketio.o|std/socketio/socketio.o|*std/socketio/socketio.o) printf '%s' "std/socketio/socketio.o" ;;
    ../std/simd/simd.o|std/simd/simd.o|*std/simd/simd.o) printf '%s' "std/simd/simd.o" ;;
    *) printf '%s' "" ;;
  esac
}

# Authority: mode|x_path (match historic Makefile wave811 recipe args).
std_x_spec_for_key() {
  case "$1" in
    std/async/scheduler.o) printf '%s' "auto-soft|../std/async/scheduler.x" ;;
    std/async/future.o) printf '%s' "auto-soft|../std/async/future.x" ;;
    std/channel/channel.o) printf '%s' "auto-soft|../std/channel/channel.x" ;;
    std/backtrace/backtrace.o) printf '%s' "auto-soft|../std/backtrace/backtrace.x" ;;
    std/uuid/uuid.o) printf '%s' "auto|../std/uuid/uuid.x" ;;
    std/url/url.o) printf '%s' "auto-soft|../std/url/url.x" ;;
    std/security/security.o) printf '%s' "auto-soft|../std/security/security.x" ;;
    std/config/config.o) printf '%s' "auto-soft|../std/config/config.x" ;;
    std/cache/cache.o) printf '%s' "auto|../std/cache/cache.x" ;;
    std/trace/trace.o) printf '%s' "auto-soft|../std/trace/trace.x" ;;
    std/task/task.o) printf '%s' "auto-soft|../std/task/task.x" ;;
    std/schema/schema.o) printf '%s' "auto|../std/schema/schema.x" ;;
    std/db/kv/kv.o) printf '%s' "auto-soft|../std/db/kv/kv.x" ;;
    std/db/arrow/arrow.o) printf '%s' "auto-soft|../std/db/arrow/arrow.x" ;;
    std/db/sqlite/sqlite.o) printf '%s' "auto-soft|../std/db/sqlite/sqlite.x" ;;
    std/elf/elf.o) printf '%s' "auto-soft|../std/elf/elf.x" ;;
    std/regex/regex.o) printf '%s' "auto-soft|../std/regex/regex.x" ;;
    std/unicode/unicode.o) printf '%s' "auto-soft|../std/unicode/unicode.x" ;;
    std/socketio/socketio.o) printf '%s' "auto-soft-merge|../std/socketio/socketio.x" ;;
    std/simd/simd.o) printf '%s' "auto-soft|../std/simd/simd.x" ;;
    *) printf '%s' "" ;;
  esac
}

std_x_all_keys() {
  printf '%s\n' \
    std/async/scheduler.o \
    std/async/future.o \
    std/channel/channel.o \
    std/backtrace/backtrace.o \
    std/uuid/uuid.o \
    std/url/url.o \
    std/security/security.o \
    std/config/config.o \
    std/cache/cache.o \
    std/trace/trace.o \
    std/task/task.o \
    std/schema/schema.o \
    std/db/kv/kv.o \
    std/db/arrow/arrow.o \
    std/db/sqlite/sqlite.o \
    std/elf/elf.o \
    std/regex/regex.o \
    std/unicode/unicode.o \
    std/socketio/socketio.o \
    std/simd/simd.o
}

std_x_out_for_key() {
  printf '../%s' "$1"
}

std_x_list() {
  std_x_all_keys | while IFS= read -r _k; do
    _sp="$(std_x_spec_for_key "$_k")"
    printf '%s  %s\n' "$_k" "$_sp"
  done
}

std_x_check() {
  _bad=0
  _n=0
  _here="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
  # Catalog x_path tokens are relative to compiler/ (e.g. ../std/cli/cli.x).
  # Resolve against compiler/ so --check works from repo root or compiler/.
  _comp="$(CDPATH= cd -- "$_here/.." && pwd)"
  _mk="$_comp/Makefile"
  [ -f "$_mk" ] || _mk="$_here/Makefile"
  while IFS= read -r _k; do
    _n=$((_n + 1))
    _sp="$(std_x_spec_for_key "$_k")"
    if [ -z "$_sp" ]; then
      echo "std_x --check: empty spec for $_k" >&2
      _bad=1
      continue
    fi
    _mode="${_sp%%|*}"
    _xsrc="${_sp#*|}"
    case "$_mode" in
      auto|auto-soft|auto-soft-merge|auto-merge) ;;
      *)
        echo "std_x --check: bad mode '$_mode' for $_k" >&2
        _bad=1
        ;;
    esac
    # PLATFORM: SHARED — sources live at repo std/; compiler/ cwd uses ../std/...
    if [ ! -f "$_comp/$_xsrc" ] && [ ! -f "$_xsrc" ]; then
      echo "std_x --check: missing source $_xsrc for $_k" >&2
      _bad=1
    fi
    _tgt="$(std_x_out_for_key "$_k")"
    # Makefile thin-call: ensure|auto only (wave825); FORCE dep-thin (wave827).
    # wave895: multi-target $(STD_X_PRODUCT_OBJS) + mk list (no per-leaf target line).
    # Accept A) legacy per-leaf `^OUT:` FORCE+ensure, or B) OUT in mk list + multi-target rule.
    if [ -f "$_mk" ]; then
      _sx_mk="$_comp/mk/std_x_product_objs.mk"
      [ -f "$_sx_mk" ] || _sx_mk="$_here/mk/std_x_product_objs.mk"
      _ok_leaf=0
      if awk -v tgt="$_tgt" '
        $0 ~ ("^" tgt ":") {
          line=$0
          # wave827: FORCE required (dep-thin); ban dual catalog .x on prereq line.
          if (line !~ /FORCE/) { exit 1 }
          if (line ~ /\.x([[:space:]]|$)/) { exit 1 }
          hit=1; next
        }
        hit && /^[^#[:space:]]/ { exit 1 }
        hit && /xlang_compile_std_x\.sh/ {
          if ($0 ~ /ensure|[[:space:]]auto[[:space:]]+\$@/) { found=1; exit 0 }
        }
        END { exit found ? 0 : 1 }
      ' "$_mk" 2>/dev/null; then
        _ok_leaf=1
      elif [ -f "$_sx_mk" ] \
        && grep -qF "$_tgt" "$_sx_mk" \
        && grep -qE '\$\(STD_X_PRODUCT_OBJS\):[[:space:]]*FORCE' "$_mk" \
        && awk '
          /\$\(STD_X_PRODUCT_OBJS\):/ { hit=1; next }
          hit && /^[^#[:space:]\t]/ { exit 1 }
          hit && /xlang_compile_std_x\.sh/ && /ensure|auto/ { found=1; exit 0 }
          END { exit found ? 0 : 1 }
        ' "$_mk"; then
        _ok_leaf=1
      fi
      if [ "$_ok_leaf" -ne 1 ]; then
        echo "std_x --check: Makefile/mk $_tgt must FORCE + ensure|auto (wave827/wave895)" >&2
        _bad=1
      fi
    fi
  done <<'KEYS'
std/async/scheduler.o
std/async/future.o
std/channel/channel.o
std/backtrace/backtrace.o
std/uuid/uuid.o
std/url/url.o
std/security/security.o
std/config/config.o
std/cache/cache.o
std/trace/trace.o
std/task/task.o
std/schema/schema.o
std/db/kv/kv.o
std/db/arrow/arrow.o
std/db/sqlite/sqlite.o
std/elf/elf.o
std/regex/regex.o
std/unicode/unicode.o
std/socketio/socketio.o
std/simd/simd.o
KEYS
  if [ "$_n" -ne 20 ]; then
    echo "std_x --check: expected 20 keys, counted $_n" >&2
    _bad=1
  fi
  if [ "$_bad" -ne 0 ]; then
    echo "std_x --check: FAIL" >&2
    return 1
  fi
  echo "std_x --check: OK (20 leaves; catalog + mk list + multi-target FORCE+ensure wave895; not physical delete)"
  return 0
}

# Compile body (wave811). Args: mode_or_bin x_path out_o
# PLATFORM: SHARED — soft vs hard is product leaf policy (F-ZC), not OS branch.
std_x_compile_one() {
  xlang_bin="$1"
  x_path="$2"
  out_o="$3"
  if [ -z "$xlang_bin" ] || [ -z "$x_path" ] || [ -z "$out_o" ]; then
    echo "usage: xlang_compile_std_x.sh <xlang|auto|auto-soft|auto-merge|auto-soft-merge> <file.x> <out.o>" >&2
    return 1
  fi

  _soft=0
  _merge=0
  case "$xlang_bin" in
    auto-soft-merge)
      _soft=1
      _merge=1
      xlang_bin=auto
      ;;
    auto-merge)
      _merge=1
      xlang_bin=auto
      ;;
    auto-soft)
      _soft=1
      xlang_bin=auto
      ;;
  esac

  # Final OUT for merge mode; compile may target *_main.o first.
  _final_out="$out_o"
  if [ "$_merge" = "1" ]; then
    case "$out_o" in
      *.o) _main_o="${out_o%.o}_main.o" ;;
      *)
        echo "xlang_compile_std_x.sh: merge mode needs .o out, got $out_o" >&2
        return 1
        ;;
    esac
    out_o="$_main_o"
  fi

  # Makefile runs under compiler/; entry paths must be ../std/... for -L ..
  case "$x_path" in
    std/*) x_path="../$x_path" ;;
  esac
  if [ "$xlang_bin" = "auto" ]; then
    # 【Why 根源】run-all 批量回归时 XLANG_COMPILE_STD_USE_C=1 强制走 xlang-c：
    # xlang_asm/xlang（seed）在 macOS -backend asm 对部分 .x 产出 code_len=0 或语义错误 .o，
    # 且 exit=0 不回退，污染 std/*.o 导致单独通过批量失败。
    # 设此变量后优先 xlang-c，确保 .o 与测试程序同源（都用 C 前端）。
    if [ -n "${XLANG_COMPILE_STD_USE_C:-}" ] && [ -x ./xlang-c ]; then
      xlang_bin=./xlang-c
    elif [ -x ./xlang_asm ]; then
      xlang_bin=./xlang_asm
    elif [ -x ./xlang ]; then
      xlang_bin=./xlang
    elif [ -x ./xlang-c ]; then
      xlang_bin=./xlang-c
    else
      if [ "$_soft" = "1" ]; then
        echo "xlang_compile_std_x.sh: no xlang host; soft-skip ${_final_out} (auto-soft)" >&2
        return 0
      fi
      echo "xlang_compile_std_x.sh: need xlang_asm, xlang, or xlang-c in compiler/" >&2
      return 1
    fi
  fi
  # PLATFORM: SHARED (host -E+cc path; required on MACOS when -backend asm code_len=0)
  # rt_preamble injects weak args_iter_* for programs that do not link std.env.
  # env.x provides strong #[no_mangle] args_iter_* in the same TU. Clang rejects
  # weak+strong redefinition (Linux cold usually stays on asm .o and never hits this).
  # Authority: strip only the preamble weak defs when a non-weak def exists in gen.c.
  xlang_strip_conflicting_weak_args_iter() {
    _gen="$1"
    [ -f "$_gen" ] || return 0
    if grep -qE '__attribute__\(\(weak\)\).*args_iter_count_c' "$_gen" 2>/dev/null \
      && grep -qE '^int32_t args_iter_count_c\(' "$_gen" 2>/dev/null; then
      sed -e '/__attribute__((weak)) int32_t args_iter_count_c(void)/d' \
          -e '/__attribute__((weak)) uint8_t \*args_iter_at_c(int32_t/d' \
          "$_gen" >"$_gen.strip" && mv "$_gen.strip" "$_gen"
    fi
  }

  # PLATFORM: MACOS/LINUX — std/net cfg errno bodies call __error / __errno_location.
  # Codegen may omit the extern prototype; host-cc then fails (Darwin cold net.o).
  # Inject after last #include when the gen C actually references the symbol.
  xlang_inject_errno_externs() {
    _gen="$1"
    [ -f "$_gen" ] || return 0
    _need=0
    if grep -qE '__error\s*\(' "$_gen" 2>/dev/null \
      && ! grep -qE 'extern\s+.*\*?\s*__error\s*\(' "$_gen" 2>/dev/null; then
      _need=1
    fi
    if grep -qE '__errno_location\s*\(' "$_gen" 2>/dev/null \
      && ! grep -qE 'extern\s+.*\*?\s*__errno_location\s*\(' "$_gen" 2>/dev/null; then
      _need=1
    fi
    [ "$_need" = "1" ] || return 0
    if grep -q '^#include' "$_gen" 2>/dev/null; then
      last_inc_line=$(grep -n '^#include' "$_gen" | tail -1 | cut -d: -f1)
    else
      last_inc_line=1
    fi
    [ -n "$last_inc_line" ] || last_inc_line=1
    # Portable insert: write block then splice (sed -i a\\ differs BSD/GNU).
    {
      head -n "$last_inc_line" "$_gen"
      echo '/* PLATFORM: injected by xlang_compile_std_x — errno TLS accessors */'
      echo '#if defined(__APPLE__)'
      echo 'extern int *__error(void);'
      echo '#elif defined(__linux__)'
      echo 'extern int *__errno_location(void);'
      echo '#endif'
      tail -n +"$((last_inc_line + 1))" "$_gen"
    } >"$_gen.errno" && mv "$_gen.errno" "$_gen"
  }

  # PLATFORM: POSIX — std/net/udp.x (and peers) call fcntl via extern "C" but
  # -E host-C may omit fcntl.h / prototype. Clang (Darwin) then fails
  # "call to undeclared function 'fcntl'" → udp.o never built → net_merge fails
  # soft-empty → L4 run-std-net-context-gate UNDEF std_net_*. G.7: inject header
  # when body uses fcntl and include is missing (same splice authority as errno).
  xlang_inject_fcntl_header() {
    _gen="$1"
    [ -f "$_gen" ] || return 0
    if ! grep -qE '\bfcntl\s*\(' "$_gen" 2>/dev/null; then
      return 0
    fi
    if grep -qE '#include\s*[<"]fcntl\.h[>"]' "$_gen" 2>/dev/null; then
      return 0
    fi
    if grep -q '^#include' "$_gen" 2>/dev/null; then
      last_inc_line=$(grep -n '^#include' "$_gen" | tail -1 | cut -d: -f1)
    else
      last_inc_line=0
    fi
    {
      if [ "$last_inc_line" -gt 0 ]; then
        head -n "$last_inc_line" "$_gen"
      fi
      echo '/* PLATFORM: POSIX injected by xlang_compile_std_x — fcntl for net nonblock */'
      echo '#include <fcntl.h>'
      if [ "$last_inc_line" -gt 0 ]; then
        tail -n +"$((last_inc_line + 1))" "$_gen"
      else
        cat "$_gen"
      fi
    } >"$_gen.fcntl" && mv "$_gen.fcntl" "$_gen"
  }

  case "$(basename "$xlang_bin")" in
    xlang-c)
      # -o may use ASM backend which fails on some .x files (pointer arith, arrays).
      # Use -E + cc -c instead for reliable C backend compilation.
      gen_c="$out_o.gen.c"
      "$xlang_bin" -E -L .. "$x_path" > "$gen_c" 2>/dev/null || { rm -f "$gen_c"; return 1; }
      if grep -q '^#include' "$gen_c" 2>/dev/null; then
        last_inc_line=$(grep -n '^#include' "$gen_c" | tail -1 | cut -d: -f1)
        if [ -n "$last_inc_line" ]; then
          sed -i.bak "${last_inc_line}a\\
#undef htonl\\
#undef htons\\
#undef ntohl\\
#undef ntohs" "$gen_c"
          rm -f "$gen_c.bak"
        fi
      fi
      xlang_strip_conflicting_weak_args_iter "$gen_c"
      xlang_inject_errno_externs "$gen_c"
      xlang_inject_fcntl_header "$gen_c"
      # PLATFORM: SHARED — function/data sections so product -dead_strip/--gc-sections
      # can drop unused net/tls/pool residual U (net.o is one ld -r unit).
      cc -Wall -Wextra -ffunction-sections -fdata-sections -I. -Iinclude -Isrc -c -o "$out_o" "$gen_c" || { rm -f "$gen_c"; return 1; }
      rm -f "$gen_c"
      ;;
    *)
      # 【Why 根源】Darwin 的 bootstrap-driver-seed 使用 asm_backend_partial.o 中的
      # seed_mega 桩（仅 14 个弱符号返回 0），真实 ARM64 指令发射器未被 -E 编入。
      # 因此 -backend asm 在 macOS 上产出 code_len=0，所有 std/*.o 编译失败。
      # 【修复】-backend asm 失败时回退到 xlang-c（-E + cc -c），保证 std .o 可用。
      if env XLANG_ASM_WPO_DCE=0 "$xlang_bin" -backend asm -L .. "$x_path" -o "$out_o" 2>/dev/null; then
        :
      else
        if [ -x ./xlang-c ]; then
          gen_c="$out_o.gen.c"
          ./xlang-c -E -L .. "$x_path" > "$gen_c" || { rm -f "$gen_c"; return 1; }
          if grep -q '^#include' "$gen_c"; then
            last_inc_line=$(grep -n '^#include' "$gen_c" | tail -1 | cut -d: -f1)
            if [ -n "$last_inc_line" ]; then
              sed -i.bak "${last_inc_line}a\\
#undef htonl\\
#undef htons\\
#undef ntohl\\
#undef ntohs" "$gen_c"
              rm -f "$gen_c.bak"
            fi
          fi
          xlang_strip_conflicting_weak_args_iter "$gen_c"
          xlang_inject_errno_externs "$gen_c"
          xlang_inject_fcntl_header "$gen_c"
          cc -Wall -Wextra -ffunction-sections -fdata-sections -I. -Iinclude -Isrc -c -o "$out_o" "$gen_c" || { rm -f "$gen_c"; return 1; }
          rm -f "$gen_c"
        else
          return 1
        fi
      fi
      ;;
  esac

  # wave811: socketio-style single-TU merge — compile landed on *_main.o; ld -r → final OUT.
  # PLATFORM: SHARED — host ld -r only (no second Makefile hybrid ladder).
  if [ "$_merge" = "1" ]; then
    if [ ! -f "$out_o" ]; then
      echo "xlang_compile_std_x.sh: merge missing intermediate $out_o" >&2
      return 1
    fi
    ld -r -o "$_final_out" "$out_o" || return 1
  fi
  return 0
}

# Mode dispatch (wave825 catalog + wave811 legacy explicit).
case "${1:-}" in
  list)
    std_x_list
    exit 0
    ;;
  --check)
    std_x_check
    exit $?
    ;;
  ensure|auto)
    # wave825: catalog-primary. Note: bare "auto" as argv1 with one more arg is ensure.
    # Legacy three-arg "auto <x> <out>" still hits the * branch below when $3 is set —
    # but callers using "auto <out.o>" alone get catalog. Distinguish by argc.
    if [ -n "${3:-}" ]; then
      # Legacy: auto|auto-soft|… <x-path> <out.o>
      std_x_compile_one "$1" "$2" "$3"
      exit $?
    fi
    if [ -z "${2:-}" ]; then
      echo "usage: xlang_compile_std_x.sh ensure <out.o>" >&2
      exit 1
    fi
    out_o="$2"
    # Canonical OUT under ../std/... when key is known.
    _key="$(std_x_key_for_out "$out_o")"
    if [ -z "$_key" ]; then
      echo "xlang_compile_std_x.sh ensure: unknown std_x leaf: $out_o" >&2
      exit 3
    fi
    case "$_key" in
      std/*) out_o="../$_key" ;;
    esac
    _spec="$(std_x_spec_for_key "$_key")"
    _mode="${_spec%%|*}"
    _xsrc="${_spec#*|}"
    # wave827: FORCE-thin mtime — shell owns catalog source freshness (G.7).
    # Makefile always invokes via FORCE; skip recompile when OUT is newer than the
    # catalog .x source. FORCE=1 forces rebuild (tests / explicit). PLATFORM: SHARED.
    if [ "${FORCE:-0}" != "1" ] && [ -f "$out_o" ]; then
      _sx_stale=0
      if [ -f "$_xsrc" ] && [ "$_xsrc" -nt "$out_o" ]; then
        _sx_stale=1
      fi
      if [ "$_sx_stale" = "0" ]; then
        echo "xlang_compile_std_x: skip up-to-date $out_o (std_x/$_key)" >&2
        exit 0
      fi
    fi
    std_x_compile_one "$_mode" "$_xsrc" "$out_o"
    exit $?
    ;;
  auto-soft|auto-soft-merge|auto-merge)
    if [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
      echo "usage: xlang_compile_std_x.sh <auto|auto-soft|auto-soft-merge|auto-merge> <file.x> <out.o>" >&2
      exit 1
    fi
    std_x_compile_one "$1" "$2" "$3"
    exit $?
    ;;
  "")
    echo "usage: xlang_compile_std_x.sh ensure <out.o> | list | --check | <mode> <file.x> <out.o>" >&2
    exit 1
    ;;
  *)
    # Explicit driver path or auto three-arg already handled; remaining = bin path.
    if [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
      echo "usage: xlang_compile_std_x.sh <xlang|auto|auto-soft|auto-merge|auto-soft-merge> <file.x> <out.o>" >&2
      exit 1
    fi
    std_x_compile_one "$1" "$2" "$3"
    exit $?
    ;;
esac
