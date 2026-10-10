#!/usr/bin/env bash
# g05_relink_xlang.sh — G-05：最终链接 xlang 的唯一 shell 实现
#
# 由 g05_prepare_and_relink.sh 在依赖齐备后调用（G05_* 来自 g05_relink_env.sh）。
# 目的：最终链接 + 同步 xlang-c/bootstrap_xlangc 仅在本脚本（G-05 100% 产品路径）。
#
# wave773 · 11.1.4 pure-ld (G.7 有则补全 pure_ld_shared.sh):
#   When freestanding-eligible (Darwin / Linux x86_64 crt0), pure-ld first.
# wave774 · 11.1.4 endgame slice: NO silent CC fallback after pure-ld fail.
#   · freestanding-eligible + not FORCE_CC → pure-ld required (hard fail on miss)
#   · FORCE_CC=1 or host ineligible → named $CC $CFLAGS -o residual only
#   Object list authority remains g05_relink_env (no second .o inventory).
#
# 环境变量（g05_relink_env.sh 注入）：
#   G05_CC          编译器（默认 cc）— residual path
#   G05_CFLAGS      完整 cflags + link flags（含 -e _start 等）— residual path
#   G05_OUT         输出二进制名（默认 xlang）
#   G05_OBJS        全部 .o 参数（空格分隔）
#   G05_XLANG_C      xlang-c 同步名（默认 xlang-c）
#   G05_BOOTSTRAP   bootstrap_xlangc 同步名（默认 bootstrap_xlangc）
#   G05_SYNC_ASM=1  同时 cp 到 xlang_asm（可选；prepare 亦可在外层做）
#
# Env overrides:
#   XLANG_G05_FORCE_CC=1 / XLANG_SEED_LINK_FORCE_CC=1 — skip pure-ld; CC residual only
#
# 用法（compiler/ 目录）：
#   eval "$(sh scripts/g05_relink_env.sh)" && sh scripts/g05_relink_xlang.sh
#
# PLATFORM: SHARED — pure-ld required when freestanding; Windows stays CC residual.
# PLATFORM: LINUX — nostdlib product drops -lc (static freestanding); libc cold uses -lc.
# PLATFORM: MACOS — pure_ld_shared syslibroot + -lSystem.
# Wave: 773 pure-ld prefer · 774 drop silent CC fallback.

set -e
cd "$(dirname "$0")/.."

# w1484: refuse to link when ensure / relink_env logged a g05 pure-asm crash
# (a retry or cc fallback may have hidden it). PLATFORM: SHARED.
if [ -s build_asm/g05_xasm_crash.log ]; then
  echo "g05_relink_xlang: g05 pure-asm compiler crashed (build_asm/g05_xasm_crash.log):" >&2
  sed 's/^/  /' build_asm/g05_xasm_crash.log >&2
  if [ "${XLANG_G05_XASM_ALLOW_CRASH:-0}" != "1" ]; then
    echo "  fix the product and rm the log, or XLANG_G05_XASM_ALLOW_CRASH=1 to only warn" >&2
    exit 1
  fi
fi

CC="${G05_CC:-cc}"
CFLAGS="${G05_CFLAGS:-}"

# Stage 12.2.1: XLANG_FORBID_HOST_CC gate (no-op when flag unset; zero impact
# on normal builds). When XLANG_FORBID_HOST_CC=1, replaces $CC with a wrapper
# that logs and blocks all host-CC invocations — builds the zero-CC problem map.
# PLATFORM: SHARED.
. "$(dirname "$0")/forbid_host_cc.sh"

OUT="${G05_OUT:-xlang}"
OBJS="${G05_OBJS:-}"
# w2055: "sym=object" pairs whose strong sidecar must beat a weakened pabi
# copy. Darwin pure-ld writes a link map and the check below reads it.
WINNERS="${G05_LINK_WINNERS:-}"
XLANG_C="${G05_XLANG_C:-xlang-c}"
BOOTSTRAP="${G05_BOOTSTRAP:-bootstrap_xlangc}"

if [ -z "$OBJS" ]; then
  echo "g05_relink_xlang: G05_OBJS empty (eval g05_relink_env.sh first)" >&2
  exit 1
fi

# G.7: pure-ld helpers — single authority (shared with cold seed link).
# shellcheck disable=SC1091
. scripts/pure_ld_shared.sh
# nostdlib policy for Linux product (same as g05_relink_env).
# shellcheck disable=SC1091
. scripts/bootstrap_nostdlib_shared.sh

n_objs=$(printf '%s\n' "$OBJS" | wc -w | tr -d ' ')

# w2060: snapshot this stage's compiler before the link replaces it. The two
# host-cc leaf vehicles below (std/fs/fs.o, std/string/string.o) are rebuilt
# by the compiler that runs this stage (g1 <- v1, g2 <- g1, g3 <- g2), the
# same compiler that built every other object of the stage. Same preference
# as pure_asm_x_to_o: ./xlang, then ./xlang_asm. PLATFORM: LINUX|DARWIN.
# Windows: keep the .exe name so the copy stays runnable. PLATFORM: SHARED.
_G05_STAGE_X=""
_G05_STAGE_X_FROM=""
_G05_STAGE_DIR=""
# Windows has no writable /tmp; TEMP is set by the build env. PLATFORM: SHARED.
_G05_TMPROOT="${TMPDIR:-${TEMP:-/tmp}}"
for _sx_cand in xlang xlang.exe xlang_asm xlang_asm.exe; do
  if [ -f "$_sx_cand" ] && [ -x "$_sx_cand" ] && [ -s "$_sx_cand" ]; then
    _G05_STAGE_DIR="$(mktemp -d "$_G05_TMPROOT/g05_stage_x.XXXXXX" 2>/dev/null || echo "$_G05_TMPROOT/g05_stage_x.$$")"
    mkdir -p "$_G05_STAGE_DIR"
    _G05_STAGE_X="$_G05_STAGE_DIR/$_sx_cand"
    if cp -p "$_sx_cand" "$_G05_STAGE_X" && chmod +x "$_G05_STAGE_X"; then
      _G05_STAGE_X_FROM="$PWD/$_sx_cand"
    else
      rm -rf "$_G05_STAGE_DIR"
      _G05_STAGE_X=""
      _G05_STAGE_DIR=""
    fi
    break
  fi
done

g05_force_cc() {
  [ "${XLANG_G05_FORCE_CC:-0}" = "1" ] || [ "${XLANG_SEED_LINK_FORCE_CC:-0}" = "1" ]
}

# Named CC residual only (FORCE_CC escape or pure-ld ineligible host).
# wave774: not used as silent fallback after pure-ld failure.
run_g05_cc_residual() {
  # shellcheck disable=SC2086
  echo "g05_relink_xlang: $CC ... -o $OUT  ($n_objs objs; CC residual)"
  # w2055: Windows links through this path; with WINNERS set it writes a
  # GNU ld map and runs the same winner check. PLATFORM: WINDOWS.
  _cmap=""
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*|Windows_NT*)
      if [ -n "$WINNERS" ]; then
        _cmap="build_asm/$(basename "$OUT").ldmap"
        rm -f "$_cmap"
      fi
      ;;
  esac
  # shellcheck disable=SC2086
  $CC $CFLAGS ${_cmap:+-Wl,-Map=$_cmap} -o "$OUT" $OBJS
  echo "g05_relink_xlang: OK CC residual $OUT" >&2
  if [ -n "$_cmap" ]; then
    g05_check_link_winners "$_cmap" || exit 1
  fi
}

# w2055: read the link map (Darwin ld64 -map or GNU ld -Map) and prove each
# "sym=object" pair in WINNERS resolved to that object. A miss means the
# weakened pabi copy won.
g05_check_link_winners() {
  python3 - "$1" $WINNERS <<'PYEOF'
import os, re, sys
mp = sys.argv[1]
objs, syms, sec = {}, {}, None
for line in open(mp, encoding="utf-8", errors="replace"):
    if line.startswith("# Object files:"):
        sec = "o"; continue
    if line.startswith("# Sections:"):
        sec = None; continue
    if line.startswith("# Symbols:"):
        sec = "s"; continue
    if sec == "o":
        m = re.match(r"\[\s*(\d+)\]\s+(.*)$", line.rstrip("\n"))
        if m:
            objs[m.group(1)] = m.group(2)
    elif sec == "s":
        m = re.match(r"0x[0-9A-Fa-f]+\s+0x[0-9A-Fa-f]+\s+\[\s*(\d+)\]\s+(\S+)$", line.rstrip("\n"))
        if m:
            syms.setdefault(m.group(2), []).append(m.group(1))
if not objs:
    # GNU ld -Map: an input-section line names the object; the symbol lines
    # under it (address + name) are the definitions that won.
    syms, cur, pend = {}, None, False
    for line in open(mp, encoding="utf-8", errors="replace"):
        t = line.rstrip("\n")
        m = re.match(r"^ (\.\S+)?\s+0x[0-9a-fA-F]+\s+0x[0-9a-fA-F]+\s+(\S+\.o)\s*$", t)
        if m and (m.group(1) or pend):
            cur = m.group(2); pend = False; continue
        if re.match(r"^ \.\S+\s*$", t):
            pend = True; continue
        pend = False
        m = re.match(r"^\s+0x[0-9a-fA-F]+\s+([A-Za-z_][\w.$]*)\s*$", t)
        if m and cur:
            k = "g%d" % len(objs)
            objs[k] = cur
            syms.setdefault(m.group(1), []).append(k)
bad = 0
for pair in sys.argv[2:]:
    sym, _, want = pair.partition("=")
    got = [objs.get(i, "?") for i in syms.get(sym, [])]
    ok = len(got) == 1 and os.path.realpath(got[0]) == os.path.realpath(want)
    print("g05_relink_xlang: winner %s -> %s %s" % (sym, ",".join(got) or "missing", "OK" if ok else "FAIL (want %s)" % want), file=sys.stderr)
    bad += not ok
sys.exit(1 if bad else 0)
PYEOF
}

# pure-ld required when freestanding-eligible and not forced to CC residual.
run_g05_pure_ld_required() {
  entry=""
  tail=""
  extra=""

  # Product freestanding entry (matches MAIN_LINK_FLAGS / cold SEED_LINK_ENTRY).
  entry="$(pure_ld_default_entry)"
  if bootstrap_wants_nostdlib; then
    # PLATFORM: LINUX — map cc -nostdlib -static -Wl,--gc-sections → pure ld flags.
    # No -lc; freestanding_io + nostdlib stubs already in G05_OBJS.
    extra="-static --gc-sections"
    tail=""
  else
    # Darwin / Linux-with-libc freestanding (nostartfiles-style).
    tail="$(pure_ld_default_libc_tail)"
  fi
  _map=""
  if [ -n "$WINNERS" ]; then
    _map="build_asm/$(basename "$OUT").ldmap"
    rm -f "$_map"
    case "$(uname -s 2>/dev/null)" in
      Darwin) extra="$extra -map $_map" ;;
      Linux) extra="$extra -Map=$_map" ;;
      *) _map="" ;;
    esac
  fi
  echo "g05_relink_xlang: pure-ld → $OUT  ($n_objs objs)" >&2
  if pure_ld_try_link "$OUT" "$OBJS" "$entry" "$tail" "$extra" ""; then
    echo "g05_relink_xlang: OK pure-ld $OUT" >&2
    if [ -n "$_map" ]; then
      g05_check_link_winners "$_map" || exit 1
    fi
    return 0
  fi
  echo "g05_relink_xlang: FAIL pure-ld for $OUT (no silent CC fallback; set XLANG_G05_FORCE_CC=1 for escape)" >&2
  exit 1
}

# Decision tree (wave774):
#   FORCE_CC=1              → named CC residual only
#   !freestanding_ok        → named CC residual only (ineligible host)
#   else                    → pure-ld required (hard fail on miss)
if g05_force_cc; then
  echo "g05_relink_xlang: pure-ld skipped (FORCE_CC) → CC residual only" >&2
  run_g05_cc_residual
elif ! pure_ld_freestanding_ok; then
  echo "g05_relink_xlang: pure-ld ineligible (host not freestanding) → CC residual only" >&2
  run_g05_cc_residual
else
  run_g05_pure_ld_required
fi

# w1010: PE mega same-TU leftover body_sync / emit_let_init → jmp to host-gcc twin.
# PLATFORM: WINDOWS only (script no-ops on Mach-O/ELF).
# MinGW -o xlang often materializes as xlang.exe; resolve before cp/patch.
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    if [ -f "${OUT}.exe" ]; then
      OUT="${OUT}.exe"
    fi
    if [ -f scripts/win_patch_body_sync_jmp.py ] && [ -f "$OUT" ]; then
      python3 scripts/win_patch_body_sync_jmp.py "$OUT" || { echo "g05_relink_xlang: win_patch_body_sync_jmp failed" >&2; exit 1; }
    fi
    ;;
esac

# w1499: copy onto a fresh inode. macOS keeps the code signature of an
# executable it already ran cached per vnode, so cp over the old file can make
# the next exec die with SIGKILL ("load code signature error 2").
# PLATFORM: MACOS needs it; SHARED harmless.
_g05_cp_fresh() {
  [ "$1" = "$2" ] && return 0
  rm -f "$2"
  cp -f "$1" "$2"
}
_g05_cp_fresh "$OUT" "$XLANG_C"
_g05_cp_fresh "$OUT" "$BOOTSTRAP"
echo "g05_relink_xlang OK ($OUT → $XLANG_C + $BOOTSTRAP)"

# Always sync product asm name after g05. On Windows MinGW, L2 defaults to
# ./compiler/xlang_asm (no .exe) while -o xlang materializes as xlang.exe —
# a stale bare xlang_asm silently fails hello/si while xlang_asm.exe is green.
# PLATFORM: WINDOWS sync both names; SHARED sync bare xlang_asm.
_g05_cp_fresh "$OUT" xlang_asm
echo "g05_relink_xlang: synced xlang_asm"
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    _g05_cp_fresh "$OUT" xlang_asm.exe
    echo "g05_relink_xlang: synced xlang_asm.exe"
    # MinGW -o writes xlang.exe. The copies above publish xlang_asm,
    # xlang_asm.exe, the unsuffixed xlang-c, and bootstrap_xlangc.
    # They do not publish the literal bare xlang, which ./xlang and the
    # stage identity check both open, nor xlang-c.exe, which the nine
    # driver leaves exec (pick_xlang). Leaving either name on the previous
    # image makes the next generation compare or compile with the old
    # compiler. CPython isfile does not add the Git bash .exe suffix.
    # _g05_cp_fresh removes only the literal destination; a bare name does
    # not delete the .exe sibling. PLATFORM: WINDOWS.
    if python3 -c 'import os,sys; raise SystemExit(0 if os.path.isfile(sys.argv[1]) else 1)' xlang; then
      _g05_cp_fresh "$OUT" xlang
      echo "g05_relink_xlang: synced xlang"
    fi
    _g05_cp_fresh "$OUT" xlang-c.exe
    echo "g05_relink_xlang: synced xlang-c.exe"
    ;;
esac

# w1545 (Windows FORCE refresh of every leaf, failures kept with a WARN) is
# folded into the shared block below (w2060): one freshness rule and a hard
# fail on every host. PLATFORM: SHARED.

# w2055: Linux leaves were only ever built when missing. A source change in a
# leaf module (80fd8b8ee: core/option out-pointer returns) left the old object
# in place and user programs linked the stale ABI (L2 opt exit 134). Rebuild
# only leaves the std module script reports stale (ensure without FORCE), with
# the product's asm backend so no host C compiler runs. Keep the old leaf when
# the rebuild fails.
# w2055: Darwin too. Its leaves were never refreshed either (core/option
# kept the by-value ABI, L2 opt hit expect_i32's panic), and its default
# leaf backend is C plus the host compiler, so refresh here with asm.
# w2060: Windows takes the same block (was the w1545 FORCE loop that kept a
# failed leaf with only a WARN). PLATFORM: LINUX|DARWIN|WINDOWS.
case "$(uname -s 2>/dev/null)" in
  Linux|Darwin|MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    case "$OUT" in /*|?:*) _refresh_x="$OUT" ;; *) _refresh_x="./$OUT" ;; esac
    _kept_stale=""
    # The refresh must not fall back to the module script's C path: a cc
    # that always fails sits first on PATH, so an asm failure keeps the old
    # leaf instead of adding a host compiler run.
    _nocc_dir=$(mktemp -d "$_G05_TMPROOT/g05_nocc.XXXXXX" 2>/dev/null || echo "$_G05_TMPROOT/g05_nocc.$$")
    mkdir -p "$_nocc_dir"
    for _ccn in cc gcc clang; do
      printf '#!/bin/sh\necho "g05_relink_xlang: host $0 blocked during leaf refresh" >&2\nexit 1\n' > "$_nocc_dir/$_ccn"
      chmod +x "$_nocc_dir/$_ccn"
    done
    # w2060 (manager ruling A): std/fs/fs.o and std/string/string.o have no
    # asm vehicle; their dedicated scripts (xlang_compile_std_fs_formal.sh,
    # xlang_compile_std_string_o.sh) compile the product's emitted C with the
    # host cc lines they already carry. Host cc is allowed for those two
    # scripts only, through a logging wrapper; every other leaf keeps the
    # always-failing cc above. Freshness is one rule on every host: a leaf is
    # STALE when the shared script's own source check says so, or when this
    # stage's compiler is newer than the leaf (so g1, g2 and g3 each rebuild
    # it with their own compiler). A missing leaf is skipped (refresh only,
    # same as every other leaf). A failed rebuild restores the old leaf and
    # stops the relink: no ALLOW escape. PLATFORM: LINUX|DARWIN.
    _ccv_x="${_G05_STAGE_X:-$_refresh_x}"
    _ccv_from="${_G05_STAGE_X_FROM:-$_refresh_x}"
    if command -v sha256sum >/dev/null 2>&1; then
      _ccv_sha=$(sha256sum "$_ccv_x" | cut -c1-16)
    else
      _ccv_sha=$(shasum -a 256 "$_ccv_x" | cut -c1-16)
    fi
    _ccv_id="$_ccv_sha@$(stat -c %Y "$_ccv_x" 2>/dev/null || stat -f %m "$_ccv_x" 2>/dev/null || echo 0)"
    _ccv_hostcc=$(cd .. && git ls-files 'compiler/*.c' 2>/dev/null | wc -l | tr -d ' ')
    _ccv_dir=$(mktemp -d "$_G05_TMPROOT/g05_ccv.XXXXXX" 2>/dev/null || echo "$_G05_TMPROOT/g05_ccv.$$")
    mkdir -p "$_ccv_dir"
    for _ccn in cc gcc clang; do
      _ccv_real=$(command -v "$_ccn" 2>/dev/null || true)
      if [ -n "$_ccv_real" ]; then
        # Log to a file: the vehicles send cc stderr to their own temp files.
        printf '#!/bin/sh\necho "cc-vehicle exec %s $*" >> "%s/calls"\nexec "%s" "$@"\n' \
          "$_ccn" "$_ccv_dir" "$_ccv_real" > "$_ccv_dir/$_ccn"
      else
        printf '#!/bin/sh\necho "g05_relink_xlang: cc-vehicle %s not installed" >&2\nexit 1\n' \
          "$_ccn" > "$_ccv_dir/$_ccn"
      fi
      chmod +x "$_ccv_dir/$_ccn"
    done
    for _leaf in ../core/*/*.o ../std/*/*.o ../std/*/*/*.o; do
      [ -s "$_leaf" ] || continue
      case "$_leaf" in
        ../std/fs/fs.o|../std/string/string.o)
          # w2060: the link above runs before this refresh, so the leaf is
          # newer than the product that was just linked; with mtime alone the
          # next stage saw its compiler as older and skipped (g1 rebuilt, g2
          # skipped, g3 rebuilt). Record which compiler built the leaf
          # (sha@mtime of this stage's compiler) and rebuild when the record
          # is missing or names another compiler. PLATFORM: SHARED.
          _ccv_stamp="build_asm/g05_leaf_stamp/$(echo "$_leaf" | sed 's#^\.\./##; s#/#_#g').id"
          _ccv_prev=$(cat "$_ccv_stamp" 2>/dev/null || echo none)
          _ccv_force=0
          [ "$_ccv_x" -nt "$_leaf" ] && _ccv_force=1
          [ "$_ccv_prev" = "$_ccv_id" ] || _ccv_force=1
          echo "g05_relink_xlang: cc-vehicle $_leaf compiler=$_ccv_from sha=$_ccv_sha force=$_ccv_force id=$_ccv_id prev=$_ccv_prev host-cc=$_ccv_hostcc"
          cp -fp "$_leaf" "$_leaf.w2055bak"
          _before=$(stat -c %Y "$_leaf" 2>/dev/null || stat -f %m "$_leaf" 2>/dev/null || echo 0)
          _erc=0
          : > "$_ccv_dir/calls"
          PATH="$_ccv_dir:$PATH" FORCE="$_ccv_force" XLANG_FORCE_LINK_BACKEND=asm XLANG="$_ccv_x" \
            bash scripts/xlang_compile_std_module.sh ensure "$_leaf" >"$_ccv_dir/log" 2>&1 || _erc=$?
          sed -e 's/^/  /' "$_ccv_dir/log" | cut -c1-240
          sed -e 's/^/  g05_relink_xlang: /' "$_ccv_dir/calls" | cut -c1-240
          echo "g05_relink_xlang: cc-vehicle $_leaf cc-calls=$(wc -l < "$_ccv_dir/calls" | tr -d ' ') rc=$_erc"
          if [ "$_erc" = 0 ] && [ -s "$_leaf" ]; then
            _after=$(stat -c %Y "$_leaf" 2>/dev/null || stat -f %m "$_leaf" 2>/dev/null || echo 0)
            if [ "$_after" != "$_before" ] || ! cmp -s "$_leaf" "$_leaf.w2055bak"; then
              rm -f "$_leaf.w2055bak"
              mkdir -p build_asm/g05_leaf_stamp && echo "$_ccv_id" > "$_ccv_stamp"
              echo "g05_relink_xlang: refreshed stale $_leaf (cc-vehicle, $_ccv_from)"
              continue
            fi
            if [ "$_ccv_force" != 1 ]; then
              rm -f "$_leaf.w2055bak"
              continue
            fi
            # FORCE=1 must rebuild; an untouched leaf is a skipped rebuild.
            _erc=nochange
          fi
          mv -f "$_leaf.w2055bak" "$_leaf"
          echo "g05_relink_xlang: FAIL cc-vehicle rebuild of $_leaf rc=$_erc (old leaf restored)" >&2
          rm -rf "$_ccv_dir" "$_nocc_dir"
          if [ -n "$_G05_STAGE_DIR" ]; then rm -rf "$_G05_STAGE_DIR"; fi
          exit 1
          ;;
      esac
      _before=$(stat -c %Y "$_leaf" 2>/dev/null || stat -f %m "$_leaf" 2>/dev/null || echo 0)
      cp -fp "$_leaf" "$_leaf.w2055bak"
      _erc=0
      PATH="$_nocc_dir:$PATH" XLANG_FORCE_LINK_BACKEND=asm XLANG="$_refresh_x" bash scripts/xlang_compile_std_module.sh ensure "$_leaf" >/dev/null 2>&1 || _erc=$?
      if [ "$_erc" = 3 ]; then
        # Not a catalog leaf (exit 3): the product never ensures it; leave it.
        mv -f "$_leaf.w2055bak" "$_leaf"
        continue
      fi
      if [ "$_erc" = 0 ] && [ -s "$_leaf" ]; then
        rm -f "$_leaf.w2055bak"
        _after=$(stat -c %Y "$_leaf" 2>/dev/null || stat -f %m "$_leaf" 2>/dev/null || echo 0)
        if [ "$_after" != "$_before" ]; then
          echo "g05_relink_xlang: refreshed stale $_leaf"
        fi
      else
        mv -f "$_leaf.w2055bak" "$_leaf"
        _kept_stale="$_kept_stale $_leaf"
        echo "g05_relink_xlang: !!!!! STALE LEAF KEPT: $_leaf (asm rebuild failed; programs linking it get the OLD object) !!!!!" >&2
      fi
    done
    rm -rf "$_nocc_dir" "$_ccv_dir"
    if [ -n "$_kept_stale" ]; then
      echo "g05_relink_xlang: !!!!! STALE LEAVES KEPT ($(echo $_kept_stale | wc -w)):$_kept_stale !!!!!" >&2
      # w2060: formal gate — any STALE LEAF KEPT is a hard fail (old leaf must not ship).
      # Escape only with XLANG_G05_ALLOW_STALE_LEAF=1 for local diagnosis.
      if [ "${XLANG_G05_ALLOW_STALE_LEAF:-0}" != "1" ]; then
        echo "g05_relink_xlang: FAIL on STALE LEAF KEPT (set XLANG_G05_ALLOW_STALE_LEAF=1 to warn-only)" >&2
        exit 1
      fi
    fi
    ;;
esac
if [ -n "$_G05_STAGE_DIR" ]; then rm -rf "$_G05_STAGE_DIR"; fi
exit 0
