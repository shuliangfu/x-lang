#!/usr/bin/env bash
# bootstrap_driver_seed_link.sh — phase1/final link body for cold bootstrap (11.0.3 / 11.1.4)
#
# Authority (G.7):
#   - Object lists + CFLAGS + platform link flags live ONLY in compiler/mk/*.mk
#     (DRIVER_SEED_* / BOOTSTRAP_DRIVER_SEED_* / MAIN_LINK_* / SEED_LINK_* expansions).
#   - wave924: This script never hardcodes an .o list. It loads SEED_LINK_* via
#     shell catalog parse of mk files (0 make):
#       bash scripts/driver_seed_obj_catalog.sh --link-export phase1
#       bash scripts/driver_seed_obj_catalog.sh --link-export final
#     `make bootstrap-driver-seed-export-{phase1,final}-link` remains an escape /
#     parity authority via XLANG_SEED_LINK_VIA_MAKE=1.
#   - wave772 · 11.1.4 pure-ld when SEED_LINK_PURE_OK=1:
#       "$SEED_LINK_LD" [platform] $MULTIDEF $ENTRY -o OUT $OBJS $TAIL
#   - wave773 · G.7 有则补全: pure-ld platform helpers in pure_ld_shared.sh
#   - wave774 · 11.1.4 endgame slice: NO silent CC fallback after pure-ld fail.
#       · pure-ld eligible + not FORCE_CC → pure-ld required (hard fail on miss)
#       · FORCE_CC=1 or PURE_OK=0 (ineligible) → named CC residual only
#
# Usage (compiler directory):
#   ./scripts/bootstrap_driver_seed_link.sh phase1
#   ./scripts/bootstrap_driver_seed_link.sh final
#   ./scripts/bootstrap_driver_seed_link.sh --self-test   # pure-ld smoke (tiny objs)
#
# Env:
#   TARGET — final product name when mode=final (default: xlang); must match Makefile
#   XLANG_SEED_LINK_FORCE_CC=1 — skip pure-ld; use SEED_LINK_CC residual only (escape)
#   XLANG_SEED_LINK_VIA_MAKE=1 — escape: use make export instead of shell catalog
#
# PLATFORM: SHARED — link composition identical; mk expands platform
#            crt0 / -e / filtered.o into SEED_LINK_*.
# PLATFORM: MACOS — pure-ld needs -syslibroot / -arch / -platform_version / -lSystem
#            (composed in pure_ld_shared.sh; not a second .o inventory).
# PLATFORM: LINUX — pure-ld freestanding entry + multidef + -lc (nostartfiles-style).
# PLATFORM: WINDOWS — PURE_OK=0 → CC residual only (no pure-ld eligibility).
# Wave: 721 export body · 772 pure-ld prefer · 773 pure_ld_shared · 774 drop silent fallback · 924 shell catalog.

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-}"

note() { echo "bootstrap_driver_seed_link: $*" >&2; }
fail() { echo "bootstrap_driver_seed_link: FAIL: $*" >&2; exit 1; }

# G.7: pure-ld platform prefix / resolve / freestanding facts — pure_ld_shared.sh only.
# shellcheck disable=SC1091
. scripts/pure_ld_shared.sh

# ---------------------------------------------------------------------------
# --self-test: pure-ld smoke with tiny host objs (no product .o list)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--self-test" ] || [ "$MODE" = "self-test" ]; then
  note "self-test pure-ld (tiny objs)"
  tmpd="${TMPDIR:-/tmp}/xlang_seed_link_selftest_$$"
  mkdir -p "$tmpd"
  cleanup() { rm -rf "$tmpd"; }
  trap cleanup EXIT
  # PLATFORM: SHARED — tiny C TUs; entry symbol with leading _ on Darwin.
  entry_sym="seed_link_selftest_entry"
  case "$(uname -s 2>/dev/null || echo Unknown)" in
    Darwin) entry_flag="-e _${entry_sym}" ;;
    *) entry_flag="-e ${entry_sym}" ;;
  esac
  cat >"$tmpd/a.c" <<EOF
int ${entry_sym}(void) { return 0; }
EOF
  cat >"$tmpd/b.c" <<EOF
int seed_link_selftest_other(void) { return 1; }
EOF
  "${CC:-cc}" -c -o "$tmpd/a.o" "$tmpd/a.c"
  "${CC:-cc}" -c -o "$tmpd/b.o" "$tmpd/b.c"
  out="$tmpd/out.exe"
  # G.7: pure_ld_try_link is the only pure-ld argv composition path.
  if ! pure_ld_try_link "$out" "$tmpd/a.o $tmpd/b.o" "$entry_flag" \
      "$(pure_ld_default_libc_tail)" "" ""; then
    fail "self-test pure-ld failed"
  fi
  [ -f "$out" ] || fail "self-test: missing $out"
  note "self-test OK pure-ld → $out"
  exit 0
fi

if [ "$MODE" != "phase1" ] && [ "$MODE" != "final" ]; then
  echo "bootstrap_driver_seed_link: usage: $0 phase1|final|--self-test" >&2
  exit 2
fi

# wave924: SEED_LINK_* via shell catalog parse of mk files (0 make).
# XLANG_SEED_LINK_VIA_MAKE=1 escapes to make export (parity / debug).
# Shell path resolves CC / LD / CFLAGS / TARGET / DRIVER_SEED_LINK_FLAGS /
# ASM_GLUE_DUP_LDFLAGS / MAIN_LINK_FLAGS / LD_R_MULTIDEF_FLAGS /
# SEED_LINK_PURE_OK / ENTRY / LD_TAIL / BOOTSTRAP_DRIVER_SEED_*_LINK_OBJS
# from mk/driver_seed_{mode_objs,link_picks,composites}.mk + host defaults.
export_target="bootstrap-driver-seed-export-${MODE}-link"
if [ "${XLANG_SEED_LINK_VIA_MAKE:-0}" = "1" ]; then
  # Make escape path. Clear MAKEFLAGS so parent `make -n` / jobserver
  # dry-run does not turn the export target into printed recipe text.
  export_raw=$(MAKEFLAGS= "${MAKE:-make}" -s "$export_target" TARGET="${TARGET:-xlang}")
else
  export_raw=$(bash scripts/driver_seed_obj_catalog.sh --link-export "$MODE")
fi
if [ -z "$export_raw" ]; then
  fail "empty export from $export_target"
fi

SEED_LINK_CC=
SEED_LINK_CFLAGS=
SEED_LINK_LD=
SEED_LINK_MULTIDEF=
SEED_LINK_ENTRY=
SEED_LINK_LD_TAIL=
SEED_LINK_PURE_OK=0
SEED_LINK_OUT=
SEED_LINK_OBJS=
while IFS= read -r line; do
  [ -z "${line:-}" ] && continue
  case "$line" in
    SEED_LINK_CC=*) SEED_LINK_CC=${line#SEED_LINK_CC=} ;;
    SEED_LINK_CFLAGS=*) SEED_LINK_CFLAGS=${line#SEED_LINK_CFLAGS=} ;;
    SEED_LINK_LD=*) SEED_LINK_LD=${line#SEED_LINK_LD=} ;;
    SEED_LINK_MULTIDEF=*) SEED_LINK_MULTIDEF=${line#SEED_LINK_MULTIDEF=} ;;
    SEED_LINK_ENTRY=*) SEED_LINK_ENTRY=${line#SEED_LINK_ENTRY=} ;;
    SEED_LINK_LD_TAIL=*) SEED_LINK_LD_TAIL=${line#SEED_LINK_LD_TAIL=} ;;
    SEED_LINK_PURE_OK=*) SEED_LINK_PURE_OK=${line#SEED_LINK_PURE_OK=} ;;
    SEED_LINK_OUT=*) SEED_LINK_OUT=${line#SEED_LINK_OUT=} ;;
    SEED_LINK_OBJS=*) SEED_LINK_OBJS=${line#SEED_LINK_OBJS=} ;;
    *)
      fail "unknown export line: $line"
      ;;
  esac
done <<EOF
$export_raw
EOF

if [ -z "$SEED_LINK_OUT" ] || [ -z "$SEED_LINK_OBJS" ]; then
  fail "incomplete export (OUT/OBJS) from $export_target"
  echo "$export_raw" >&2
fi

# knife256 / 10.2: Darwin phase1/final hollow-fill objs first-win over pabi U.
# Manifest from darwin_phase1_hollow_fill.sh (egg thins + m8 return-0 stubs).
# PLATFORM: MACOS tip cold after 9.1 hollow.
_HOLLOW_MANIFEST=build_asm/selfhost_pabi/phase1_hollow_fill_objs.txt
if [ -s "$_HOLLOW_MANIFEST" ]; then
  _hollow_objs=$(tr '\n' ' ' <"$_HOLLOW_MANIFEST" | sed 's/[[:space:]]*$//')
  if [ -n "$_hollow_objs" ]; then
    SEED_LINK_OBJS="$_hollow_objs $SEED_LINK_OBJS"
    note "Darwin hollow-fill prepended ($(printf '%s\n' $_hollow_objs | wc -w | tr -d ' ') objs)"
  fi
fi

# knife256 / 10.2: Darwin cold prefer may leave runtime_pipeline_abi.o as a
# libtool archive (thin+rest). Apple ld -force_load then hits internal strong
# dups. Flatten to one MH_OBJECT (rest weakened where thin already defines).
# Also weaken tip copies of hollow-owned strong symbols (multiply_defined
# obsolete). Re-apply mega e_machine off 0x10a→0x299 when needed.
# PLATFORM: MACOS phase1/final.
if [ "$(uname -s)" = "Darwin" ]; then
  _pabi=src/runtime_pipeline_abi.o
  _oc=""
  for _c in /opt/homebrew/opt/llvm/bin/llvm-objcopy /usr/local/opt/llvm/bin/llvm-objcopy llvm-objcopy; do
    if command -v "$_c" >/dev/null 2>&1 || [ -x "$_c" ]; then _oc=$_c; break; fi
  done
  if [ -f "$_pabi" ] && [ -n "$_oc" ]; then
    if dd if="$_pabi" bs=8 count=1 2>/dev/null | grep -q '^!<arch>'; then
      _flat_dir=$(mktemp -d "${TMPDIR:-/tmp}/pabi_flat.XXXXXX")
      (
        cd "$_flat_dir" || exit 1
        ar -x "$OLDPWD/$_pabi" || exit 1
        _thin=$(ls pabi_thin.* 2>/dev/null | head -1)
        _rest=$(ls pabi_rest.* 2>/dev/null | head -1)
        if [ -n "$_thin" ] && [ -n "$_rest" ]; then
          while read -r _sym; do
            "$_oc" --weaken-symbol="$_sym" "$_rest" 2>/dev/null || true
          done < <(nm -gU "$_thin" 2>/dev/null | awk '/ T /{print $NF}')
          ld -r -o pabi_flat.o "$_thin" "$_rest" || exit 1
          cp -f pabi_flat.o "$OLDPWD/$_pabi"
          echo "bootstrap_driver_seed_link: flattened libtool $_pabi → MH_OBJECT" >&2
        fi
      ) || note "pabi flatten skipped/failed (keep archive)"
      rm -rf "$_flat_dir"
    fi
    # hollow-owned strongs must beat tip (Apple ld: no multiply_defined)
    for _hs in       _parser_asm_copy_slice_to_name64_buf_c       _platform_macho_write_macho_o_to_buf       _pipeline_elf_ctx_add_label       _pipeline_elf_ctx_add_sym       _pipeline_asm_emit_return_elf_impl       _backend_emit_block_body_sync_elf       _pipeline_asm_emit_block_body_sync_elf       _pipeline_asm_emit_expr_elf_fast
    do
      for _to in src/runtime_pipeline_abi.o parser_asm_thin_glue.o; do
        if [ -f "$_to" ] && nm -gU "$_to" 2>/dev/null | awk '/ T /{print $NF}' | grep -qx "$_hs"; then
          "$_oc" --weaken-symbol="$_hs" "$_to" 2>/dev/null || true
        fi
      done
    done
    if [ -f scripts/pabi_patch_emachine_off_10a_to_299.py ]; then
      python3 scripts/pabi_patch_emachine_off_10a_to_299.py "$_pabi" 2>/dev/null || true
    fi
  fi
fi
if [ -z "$SEED_LINK_CC" ] && [ -z "$SEED_LINK_LD" ]; then
  fail "incomplete export (CC/LD) from $export_target"
fi

# knife256 / 10.2: phase1/final must not pure-ld a missing frontend .o.
# Track L migrate can race with a later wipe/refresh; re-seed parser/typeck/codegen
# when listed in SEED_LINK_OBJS but absent on disk. PLATFORM: SHARED Darwin tip-cold.
for _fe in parser_x.o typeck_x.o codegen_x.o; do
  case " $SEED_LINK_OBJS " in
    *" $_fe "*)
      if [ ! -f "$_fe" ]; then
        note "missing $_fe before $MODE link; migrate Track L re-seed"
        if [ "${XLANG_MIGRATE_TRACK_L_COLD_SEED:-0}" != "1" ]; then
          export XLANG_MIGRATE_TRACK_L_COLD_SEED=1
        fi
        if ! bash scripts/migrate_x_objs.sh "$_fe" >&2; then
          fail "cannot restore missing $_fe via migrate_x_objs.sh"
        fi
        [ -f "$_fe" ] || fail "$_fe still missing after migrate"
      fi
      ;;
  esac
done

# knife256 / 10.2 P001: Track L parser_x.o calls struct-returning
# lexer_init(); tip pure-asm lexer_x.o exports lexer_init(out:*Lexer):void.
# parse_into_buf uses lexer_next_buf_into (out-ptr; ABI-compatible with tip).
# Fix: demote tip _lexer_init to local; prepend strong return-by-value asm
# shim. Keep tip lexer for next_* so parser_asm bridges stay tip-ABI.
# PLATFORM: SHARED phase1/final with Track L parser.
if [ -f parser_x.o ] && [ -f lexer_x.o ]; then
  _psz=$(wc -c <parser_x.o | tr -d ' ')
  if [ "$_psz" -lt 400000 ]; then
    _shim_dir=build_asm/seed_host
    mkdir -p "$_shim_dir"
    _shim="$_shim_dir/lexer_init_ret_by_value_shim.o"
    _lex_f="$_shim_dir/lexer_x_trackl_abi.o"
    _arch=$(uname -m)
    case "$_arch" in
      arm64|aarch64) _shim_s=src/asm/lexer_init_ret_by_value_shim_arm64.s ;;
      x86_64|amd64) _shim_s=src/asm/lexer_init_ret_by_value_shim_x86_64.s ;;
      *) fail "P001 ABI shim: unsupported arch $_arch" ;;
    esac
    [ -f "$_shim_s" ] || fail "missing $_shim_s"
    if [ ! -f "$_shim" ] || [ "$_shim_s" -nt "$_shim" ]; then
      as -o "$_shim" "$_shim_s" || fail "as failed for $_shim_s"
    fi
    if [ ! -f "$_lex_f" ] || [ lexer_x.o -nt "$_lex_f" ]; then
      _exp="$_shim_dir/lexer_x_trackl_exports.txt"
      nm -gU lexer_x.o | awk '/ [Tt] /{print $3}' | grep -v '^_lexer_init$' | grep -v '^lexer_init$' >"$_exp"
      ld -r -o "$_lex_f" -exported_symbols_list "$_exp" lexer_x.o || fail "ld -r filter lexer_init failed"
    fi
    _new_objs=""
    for _o in $SEED_LINK_OBJS; do
      if [ "$_o" = "lexer_x.o" ]; then
        _new_objs="$_new_objs $_lex_f"
      else
        _new_objs="$_new_objs $_o"
      fi
    done
    SEED_LINK_OBJS="$_shim $_new_objs"
    note "P001 ABI: return-by-value lexer_init shim + filtered tip lexer (Track L parser sz=$_psz)"
  fi
fi

# knife256 / 10.2: gate Track L typeck against silent shrink (~135KB missing
# typeck_x_ast_check_one_func). Healthy archaeology pin is ~365KB.
# PLATFORM: SHARED phase1/final.
case " $SEED_LINK_OBJS " in
  *" typeck_x.o "*)
    if [ -f typeck_x.o ]; then
      _tsz=$(wc -c <typeck_x.o | tr -d ' ')
      if [ "$_tsz" -lt 300000 ]; then
        note "typeck_x.o too small ($_tsz); Track L re-seed"
        export XLANG_MIGRATE_TRACK_L_COLD_SEED=1
        bash scripts/migrate_x_objs.sh typeck_x.o >&2 || fail "typeck shrink re-seed failed"
        _tsz=$(wc -c <typeck_x.o | tr -d ' ')
        [ "$_tsz" -ge 300000 ] || fail "typeck_x.o still too small after re-seed ($_tsz)"
      fi
      if ! nm -gU typeck_x.o 2>/dev/null | grep -E 'T _?typeck_x_ast_check_one_func$' >/dev/null; then
        note "typeck_x.o missing typeck_x_ast_check_one_func; Track L re-seed"
        export XLANG_MIGRATE_TRACK_L_COLD_SEED=1
        bash scripts/migrate_x_objs.sh typeck_x.o >&2 || fail "typeck symbol re-seed failed"
        nm -gU typeck_x.o 2>/dev/null | grep -E 'T _?typeck_x_ast_check_one_func$' >/dev/null           || fail "typeck_x.o still missing typeck_x_ast_check_one_func"
      fi
    fi
    ;;
esac

n_objs=$(printf '%s\n' "$SEED_LINK_OBJS" | wc -w | tr -d ' ')

# ---------------------------------------------------------------------------
# CC residual only path (FORCE_CC escape or pure-ld ineligible host).
# wave774: not used as silent fallback after pure-ld failure.
# ---------------------------------------------------------------------------
run_cc_residual() {
  if [ -z "$SEED_LINK_CC" ]; then
    fail "CC residual needed but SEED_LINK_CC empty"
  fi
  note "${MODE} link (CC residual) → $SEED_LINK_OUT  ($n_objs objs via Makefile export)"
  # Word-split CFLAGS and OBJS intentionally (space-separated make expansions).
  # shellcheck disable=SC2086
  "$SEED_LINK_CC" $SEED_LINK_CFLAGS -o "$SEED_LINK_OUT" $SEED_LINK_OBJS
  note "OK CC residual $SEED_LINK_OUT"
}

# ---------------------------------------------------------------------------
# pure-ld required path when eligible (wave772/774).
# MULTIDEF from Makefile export is folded into pure_ld_try_link's host multidef
# (same Darwin/Linux shape). ENTRY/TAIL still come from Makefile export authority.
# ---------------------------------------------------------------------------
run_pure_ld_required() {
  note "${MODE} pure-ld → $SEED_LINK_OUT  ($n_objs objs via pure_ld_shared)"
  if pure_ld_try_link "$SEED_LINK_OUT" "$SEED_LINK_OBJS" \
      "${SEED_LINK_ENTRY:-}" "${SEED_LINK_LD_TAIL:-}" "" "${SEED_LINK_LD:-}"; then
    note "OK pure-ld $SEED_LINK_OUT"
    return 0
  fi
  fail "pure-ld failed for $SEED_LINK_OUT (no silent CC fallback; set XLANG_SEED_LINK_FORCE_CC=1 for escape)"
}

# Decision tree (wave774):
#   FORCE_CC=1        → named CC residual only
#   PURE_OK!=1        → named CC residual only (ineligible host)
#   else              → pure-ld required (hard fail on miss)
if [ "${XLANG_SEED_LINK_FORCE_CC:-0}" = "1" ]; then
  note "pure-ld skipped (XLANG_SEED_LINK_FORCE_CC=1) → CC residual only"
  run_cc_residual
  exit 0
fi

if [ "${SEED_LINK_PURE_OK:-0}" != "1" ]; then
  note "pure-ld ineligible (SEED_LINK_PURE_OK=${SEED_LINK_PURE_OK:-0}) → CC residual only"
  run_cc_residual
  exit 0
fi

run_pure_ld_required
exit 0
