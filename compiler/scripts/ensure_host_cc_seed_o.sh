#!/usr/bin/env bash
# ensure_host_cc_seed_o.sh — R1 host-cc seed/from_x → .o single body
#   wave748: first family RT_SEED_SLICE
#   wave749: second family R1_CORE_SEED (diag / link_abi / c_import / bridge / seed_link_compat)
#   wave750: third family R1_FRONTEND_GLUE (lexer/ast/lsp basename-mismatch map)
#   wave751: fourth family R1_MAIN_RUNTIME (main/runtime multi-flag variants)
#   wave752: fifth family R1_ALIAS_STUBS (link alias / bare / compat stubs)
#   wave753: sixth family R1_EXTRA_CFLAGS (pipeline_abi / -fPIE / sqlite multi-flag /
#            parser link-alias extras)
#   wave754: seventh family R1_MISC_BASENAME (misc pure basename host-cc:
#            channel/kv/scheduler glue, backend enc, lsp ctx, pipeline_glue
#            strict_minimal, runtime_asm_build, link_abi_user_env)
#   wave755: eighth family R1_SEED_MAP (basename-mismatch + orch -D:
#            target_cpu_pure → target_cpu.o, runtime_ast_glue → ast_seed.o,
#            pipeline_bootstrap_orchestration + -Ibuild_asm -D)
#   wave756: R4 pure-R1 body helper — `try-r1 OUT` resolves OUT against the
#            eight catalog KEY memberships (G.7 lists stay mk) and runs the
#            same ensure_one body. Used by rebuild_leaves so pure R1 leaves
#            leave the make pattern graph; non-members exit 3 (caller make).
#   wave757: R3 cold-else body helper — `try-r3-cold OUT` resolves OUT against
#            catalog R3_COLD_SEED_OBJS (thin+rest leaves whose cold path is
#            pure basename host-cc). Same ensure_one body; exit 3 if not member.
#            rebuild_leaves residual uses this before make.
#   wave763: R3 PREFER thin+rest product path — `try-r3-prefer OUT` (same catalog
#            R3_COLD_SEED_OBJS; G.7 有则补全, no new list). When
#            XLANG_G05_PREFER_X_O=1 and xlang-c works: thin.x via
#            rt_prefer_try_x_to_o (wave190: single -E prologue; no bare -E|cc)
#            + seed rest (-D FROM_X) → ld -r. Else / fail → ensure_one cold seed
#            (same body as try-r3-cold). Product leaves thin-call this helper
#            via try-heat / g05 r3-prefer-family. simd_enc/loop keep nm symbol
#            gates.
#   wave764: G.7 g05 dual-hybrid swallow — same try-r3-prefer body owns product
#            daily path for R3_COLD nine (g05_ensure thin-calls r3-prefer-family).
#            Leaf map gains optional full.x first ladder (simd/backend R2 full
#            surface H=0; fail → thin; fail → cold).
#   wave765: G.7 g05 labi multi-slice swallow — `try-labi-prefer OUT` for
#            src/runtime_link_abi.o (L0..L9+L8b+L8c + rest FROM_X → cc -r).
#            g05_ensure + Makefile thin-call (no dual hybrid body).
#   wave766: G.7 g05 rt multi-slice swallow — `try-rt-prefer OUT` for
#            src/runtime_driver_no_c.o (content..dispatch + rest FROM_X → cc -r;
#            RT_SEED_SLICE external). g05_ensure + Makefile thin-call.
#   wave318: G.7 runtime mega full seed host-cc leave (prefer path) —
#            when all hybrid non-default RT_* slices are ok, monofile rest under
#            full XLANG_RT_*_FROM_X is T=0 (empty mega). Omit host-cc of
#            seeds/runtime.from_x.c and merge slices only (parser f-330 analogue).
#   wave319: G.7 runtime cold multi-slice leave (PREFER=0) —
#            multi-slice path no longer gated on PREFER=1; PREFER=0 uses cold
#            layer seeds only (no .x try). When full non-default set ok → same
#            omit empty mega rest as wave318 (no monofile host-cc). Monofile
#            seeds/runtime.from_x.c remains last-resort only (partial/fail).
#            Not M4 pin-off (7.1 still ⬜ — monofile seed still in tree).
#   wave320: G.7 product no_c refuse monofile (7.1.2 step) —
#            multi-slice gated on content layer seed (not monofile presence);
#            partial rest + last-resort monofile host-cc **refused** by default
#            (fail hard). Escape: XLANG_RT_ALLOW_MONOFILE_LAST_RESORT=1
#            (archaeology only; requires monofile file if still present).
#   wave321: G.7 R1 monofile physical retire (7.1.1) —
#            seeds/runtime.from_x.c **removed**. R1 main-runtime runtime*.o
#            cold maps → multi-slice product object (content layer seeds only).
#            runtime.o / runtime_x.o / runtime_driver.o become aliases of
#            multi-slice no_c (monofile flag variants retired; LEGACY monofile
#            host-cc gone). Escape monofile last-resort fails without seed.
#   wave767: G.7 g05 pipeline_abi + ldpc PREFER swallow —
#            `try-pipeline-abi-prefer OUT` (full .x WEAK + rest FROM_X → cc -r)
#            · `try-ldpc-prefer OUT` (thin .x WEAK + rest L2_LSP_CTX → cc -r).
#            g05_ensure + Makefile thin-call.
#   wave768: G.7 g05 target_cpu PREFER swallow —
#            `try-target-cpu-prefer OUT` (flags.x + rest pure FROM_X → cc -r).
#            g05_ensure + Makefile thin-call.
#   wave769: G.7 g05 L2 asm three thin+rest PREFER swallow —
#            `try-l2-asm-prefer OUT` for user_asm_seed_bridge /
#            backend_x86_64_enc_c / asm_backend_compat_stubs (table-driven;
#            thin .x + rest FROM_X → $CC -r; cold ensure_one).
#   wave770: G.7 g05 async three thin+rest PREFER swallow —
#            `try-async-prefer OUT` for async_liveness / async_cps_codegen /
#            async_asm_pool (table-driven; full .x + rest FROM_X → $CC -r;
#            cold ensure_one).
#   wave771: G.7 g05 other L2 four thin+rest PREFER swallow —
#            `try-other-l2-prefer OUT` for seed_link_compat / strict_glue_stubs /
#            fmt_check_cmd_driver / lsp_diag (table-driven; thin/full .x + rest
#            FROM_X → $CC -r; slc named-weak via G05_X_O_WEAK_FUNCS; cold
#            ensure_one + fmt USE_X_PIPELINE).
#   wave775: G.7 fmt_check_cmd.o Makefile dual → try-other-l2-prefer (有则补全) —
#            same table; leaf_kind=fmt_core (no -DXLANG_USE_X_PIPELINE; OBJS_CORE /
#            PIPELINE_X satellite path). Residual: physical delete · panic PREFER.
#   wave776: G.7 R2 panic PREFER thin+rest → `try-r2-prefer OUT` (有则补全) —
#            membership = catalog DRIVER_SEED_PANIC_OBJS; PREFER=1 thin.x + seed
#            rest FROM_X → ld -r (host pick mirrors Makefile ifeq tree); fail /
#            PREFER≠1 / pure-asm host → ensure_r2_panic_one cold (try-r2 twin).
#            Makefile runtime_panic.o thin-call; dual hybrid deleted.
#   wave779: G.7 B1 runtime_* OS/glue dual hybrid → `try-runtime-os-prefer OUT`
#            (有则补全; table-driven 23 leaves; reuses rt_prefer_try_x_to_o).
#            Makefile thin-call only (NOT physical delete). Special leaf_kinds:
#            http (-Iseeds/http), ed25519 (-Isrc/asm), tls (mbedtls -I fallback),
#            net_udp (Linux-only PREFER). Residual: B2–B5 · physical delete.
#   wave780: G.7 B2 std/core product hybrid → `try-std-core-prefer OUT`
#            (有则补全; 5 leaves: process/path/runtime/net + core/slice).
#            leaf_kind: direct (path/runtime/slice R2 DIRECT xlang-c -lib-name),
#            process_merge (args seed + argv + os_glue ld -r), net_merge
#            (sub .x + net_*_fast PREFER + final ld -r). Makefile thin-call only.
#            Residual: B3–B5 · physical delete.
#   wave781: G.7 B3 LSP satellite hybrid → `try-lsp-sat-prefer OUT`
#            (有则补全; dedicated table — shapes differ from try-other-l2-prefer /
#            try-ldpc: sizes_nostub = xlang-c -E → cc -c direct; stubs_no_c =
#            xlang-c -E thin + seed rest FROM_X → ld -r multidef). Makefile
#            thin-call only (NOT physical delete). Residual: B4–B5 · physical delete.
#   wave782: G.7 B4 gen.c → .o bootstrap → `try-gen-c-to-o OUT`
#            (有则补全; body = ensure_gen_x_o.sh maps for lexer_x / ast_gen2 /
#            driver_x / preprocess_x — outside try-gen-x catalog).
#            wave295 B′: _x_stubs2 host left (dead dual; not g05/stage2 link).
#            Makefile thin-call only (NOT physical delete). Residual: B5 · physical delete.
#   wave783: G.7 B5 cfg_eval multi-ladder → `try-cfg-eval-ladder OUT`
#            (有则补全; single leaf src/lexer/cfg_eval.o; rungs: -E-extern±L →
#            linux pin gen + link_alias ld -r → bootstrap stub). Makefile
#            thin-call only (NOT physical delete). Residual: B6 R5 · physical delete.
#   wave950: cfg-eval soft missing xlang-c → scripts/ensure_xlang_c.sh (0-make;
#            was make-target xlang-c; post-delete residual; soft || true pin/stub OK).
#   wave789: B7A heat shell auto-dispatch — `try-heat OUT` (有则补全; NOT physical
#            delete). Ladder existing try-* membership helpers (prefer before
#            pure R1/R2/gen) so heat can rebuild ensure-owned leaves without
#            knowing which Makefile recipe owns them. Makefile thin-call edges
#            remain residual (make dep graph); this is shell-primary heat body
#            dispatch only. Residual: Makefile edges · Windows gate physical del.
#   wave790: B7A heat Makefile thin-call unify — all ensure *recipes* call
#            `try-heat $@` only (115 leaves; G.7 single heat entry). Historical
#            try-*/one mode names stay in Makefile comments for archaeology.
#            Dependency edges still residual (NOT physical delete).
#   wave791: B7A heat dep-edge thin — pure runtime_* (seed+.x) Makefile prereqs
#            collapse to FORCE + ensure script; try-heat owns seed/.x mtime.
#            NOT physical delete; hdr/c/asm/stamp leaves keep full edges.
#   wave792: B7A heat dep-edge thin — pure seed+.x residual (R1/async/rt/alias/L2/
#            lsp/strict_minimal; +31 → 59 FORCE) same FORCE+ensure pattern.
#            Exclude hdr/twin (scheduler·strict_glue_stubs)/cfg_eval multi/asm/gen.
#   wave793: B7A heat dep-edge thin — pure seed+.x+.h residual → FORCE (+19 → 78).
#            ensure_one + prefer skip paths own project-header mtime via
#            seed_project_hdrs_newer (quoted/angle #include under .|include|src,
#            depth-capped BFS). NOT physical delete; residual twin/c multi/asm/gen.
#   wave794: B7A heat dep-edge thin — twin · Makefile-flags · pure leftover → FORCE
#            (+8 → 86). scheduler_glue (async_net_fs #include) · strict_glue_stubs
#            (heap_user #include + thin.x prefer) · glue_standalone multi-c ·
#            slice pure seed+.x · main_driver/runtime_driver{,_no_c}/pipeline_abi
#            (Makefile macro flags via force_thin_makefile_flags_newer).
#            Residual: cfg_eval multi · asm/gen · stamp · std merge · gen_x.
#            NOT physical delete.
#   wave795: B7A heat dep-edge thin — cfg_eval multi · pure asm · std direct/process
#            → FORCE (+15 → 101). cfg_eval multi-seed · crt0/freestanding/typeck_f64
#            · path/runtime/process. Host ifeq for crt0/typeck kept. crt0_mingw
#            Makefile flags via force_thin_makefile_flags_newer. Residual: net
#            multi-merge · panic stamp · gen_x · orch. NOT physical delete.
#   wave796: B7A heat dep-edge thin net multi-merge · panic stamp · gen_x/B4
#            residual (+11 → 112 FORCE). Shell owns: net_merge multi .x/seed
#            mtime; panic platform stamp + host pick (already try-r2); gen_x
#            via try-heat → try-gen-x / try-gen-c-to-o (PIPELINE_X_DEPS env).
#            Residual: orch / physical delete after Windows. NOT physical delete.
#   wave797: B7A heat dep-edge thin orch residual (+1 → 113 FORCE).
#            Shell owns: orch seed/.x + pipeline_gen.c + pipeline_glue_types.inc.
#            Residual: physical delete after Windows only. NOT physical delete.
#   wave758: R4 residual pure host-cc thin_glue → R1 seed-map (G.7 有则补全):
#            parser_asm_thin_glue.o ← seeds/parser_asm_thin_c.from_x.c +
#            -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE -Isrc/lexer -Isrc/asm -Iseeds/parser_asm;
#            ensure_one also refreshes on seeds/parser_asm/*.inc (Makefile prereq twin).
#   wave759: R4 residual glue standalone → R1 seed-map (G.7 有则补全):
#            build_asm/pipeline_glue_standalone.o ← seeds/pipeline_glue_standalone.from_x.c
#            + -Wno-error=return-type -Ibuild_asm. wave309 seed retired; ensure_one
#            early-exits when seed absent. Freshness residual (archaeology path):
#            build_asm/pipeline_glue_types.inc only — deleted pipeline_glue.c /
#            ast_pool.c -nt never fire (same debt layer as SYMS／glue ensure).
#   wave760: R2 panic cold body — `try-r2 OUT` resolves OUT against catalog
#            DRIVER_SEED_PANIC_OBJS (lists = mk). Cold path selects source by
#            host uname (Linux x86_64 → runtime_panic_x86_64.s when present;
#            arm64/aarch64 → runtime_panic_arm64.from_x.c; else
#            runtime_panic.from_x.c), touches platform stamp
#            build_asm/runtime_panic.$(uname -s).$(uname -m).stamp, then
#            ensure_one (seed) or plain cc -c (.s). PREFER thin+rest stays
#            Makefile. rebuild_leaves residual uses try-r2 before make.
#   wave762: R2 typeck_f64 + crt0 — extend try-r2 membership to catalog
#            DRIVER_SEED_TYPECK_F64_OBJS + DRIVER_SEED_CRT0_OBJS (lists = mk).
#            typeck_f64_bits.o: host picks platform .s (Linux/Darwin/Windows).
#            crt0*.o / freestanding_io_x86_64.o: fixed o→.s map; crt0_mingw.o
#            uses src/crt0_mingw.x via cc_inc_tu --auto (+ WIN32_O_CFLAGS).
#            G.7 有则补全 on try-r2 (no second helper name).
#
# Authority (G.7):
#   Single shell *recipe body* for pure host-cc compile of seeds/*.from_x.c → .o.
#   Object *lists* stay in Makefile / mk (catalog export keys).
#   This script never hardcodes a second product .o inventory as authority.
#   Seed / flag path conventions (not .o lists):
#     basename match:  <dir>/<leaf>.o  ←  seeds/<leaf>.from_x.c
#     frontend-glue:   fixed o→seed map (leaf stem ≠ seed stem)
#     main-runtime:    o→seed map (main_* ← main; runtime_* ← runtime) +
#                      o→extra -D flags (thin Makefile passes expanded make vars)
#     alias-stubs:     basename match (same as core-seed / rt-slice)
#     extra-cflags:    o→seed map (sqlite_stub shares sqlite seed) +
#                      o→extra flags (-D / -fPIE; thin passes make vars)
#     misc-basename:   basename match (same as alias-stubs / core-seed)
#     seed-map:        o→seed map (stem ≠ seed stem) + optional orch extras
#
# Families (list authority = catalog KEY):
#   RT_SEED_SLICE_OBJS     — five Cap residual slices under src/runtime/
#   R1_CORE_SEED_OBJS      — diag + runtime_link_abi + runtime_c_import +
#                            x_seed_bridge + seed_link_compat
#   R1_FRONTEND_GLUE_OBJS  — lexer.o / ast.o / lsp_diag.o (runtime_*_glue seeds)
#   R1_MAIN_RUNTIME_OBJS   — main / main_x / main_driver / runtime / runtime_x /
#                            runtime_driver / runtime_driver_no_c
#   R1_ALIAS_STUBS_OBJS    — x_frontend_link_alias + bare aliases + typeck stubs +
#                            user_asm_seed_bridge + asm_backend_compat_stubs +
#                            runtime_driver_strict_glue_stubs
#   R1_EXTRA_CFLAGS_OBJS   — runtime_pipeline_abi + runtime_asm_io_stubs (-fPIE) +
#                            runtime_sqlite_glue[+_stub] + parser_asm_parse_expr_link
#   R1_MISC_BASENAME_OBJS  — pure basename host-cc without special -D/-f extras
#                            (glue/enc/ctx/pipeline_glue_strict_minimal/asm_build/…)
#   R1_SEED_MAP_OBJS       — basename-mismatch + bootstrap orch extras + thin_glue
#                            + glue standalone (target_cpu / ast_seed / orch /
#                            parser_asm_thin_glue · pipeline_glue_standalone · wave758/759)
#   R3_COLD_SEED_OBJS      — thin+rest cold-else pure host-cc (wave757)
#   wave761: R4 residual gen *_x + pipeline_x — `try-gen-x OUT`
#            membership = catalog LSP_X / PIPELINE_X keys;
#            body = scripts/ensure_gen_x_o.sh (G.7 有则补全).
#            rebuild_leaves try-r2 then try-gen-x then residual make.

# Not in scope (honest residual):
#   - ~~R3 Makefile PREFER thin for R3_COLD nine~~ wave763 try-r3-prefer
#   - ~~g05 R3_COLD nine dual hybrid~~ wave764 → r3-prefer-family
#   - ~~g05 labi multi-slice~~ wave765 try-labi-prefer
#   - ~~g05 rt multi-slice~~ wave766 try-rt-prefer
#   - ~~g05 pipeline_abi / ldpc PREFER~~ wave767 try-pipeline-abi-prefer / try-ldpc-prefer
#   - ~~g05 target_cpu PREFER~~ wave768 try-target-cpu-prefer
#   - ~~g05 L2 asm three (uasb/bxec/abcs)~~ wave769 try-l2-asm-prefer
#   - ~~g05 async three (liveness/cps/asm_pool)~~ wave770 try-async-prefer
#   - ~~g05 other L2 four (slc/strict_glue/fmt_check/lsp_diag)~~ wave771
#     try-other-l2-prefer
#   - ~~fmt_check_cmd.o Makefile dual~~ wave775 → try-other-l2-prefer fmt_core
#   - ~~panic PREFER thin~~ wave776 → try-r2-prefer
#   - ~~B1 runtime_* OS/glue dual hybrid~~ wave779 → try-runtime-os-prefer
#   - ~~B2 std/core product hybrid~~ wave780 → try-std-core-prefer
#   - ~~B3 LSP satellite hybrid~~ wave781 → try-lsp-sat-prefer
#   - ~~B4 gen_c_to_o bootstrap~~ wave782 → try-gen-c-to-o
#   - ~~B5 cfg_eval multi-ladder~~ wave783 → try-cfg-eval-ladder
#   - R5 CI all · B6 · pure-ld residual
#   - pure-ld (11.1.4) · physical Makefile delete (11.3.1)
#   - bootstrap_nostdlib_stubs.o (cc_inc_tu residual)
#   - ~~crt0_user.o / freestanding_io.o / ast_x.o cp wrappers~~ wave836 → ensure_cp_alias_o
#
# Usage (cwd = compiler/):
#   bash scripts/ensure_host_cc_seed_o.sh one <out.o> <seed.from_x.c> [extra cflags...]
#   bash scripts/ensure_host_cc_seed_o.sh try-r1 <out.o>   # wave756 R4 pure-R1 helper
#   bash scripts/ensure_host_cc_seed_o.sh try-r3-cold <out.o>
#   bash scripts/ensure_host_cc_seed_o.sh try-r3-prefer <out.o> # wave763 PREFER thin+rest
#   bash scripts/ensure_host_cc_seed_o.sh try-labi-prefer <out.o> # wave765 labi multi-slice
#   bash scripts/ensure_host_cc_seed_o.sh try-rt-prefer <out.o>   # wave766 rt multi-slice
#   bash scripts/ensure_host_cc_seed_o.sh try-pipeline-abi-prefer <out.o> # wave767 pipeline_abi
#   bash scripts/ensure_host_cc_seed_o.sh try-ldpc-prefer <out.o>  # wave767 ldpc thin+rest
#   bash scripts/ensure_host_cc_seed_o.sh try-target-cpu-prefer <out.o> # wave768 target_cpu
#   bash scripts/ensure_host_cc_seed_o.sh try-l2-asm-prefer <out.o> # wave769 L2 asm three
#   bash scripts/ensure_host_cc_seed_o.sh try-async-prefer <out.o> # wave770 async three
#   bash scripts/ensure_host_cc_seed_o.sh try-other-l2-prefer <out.o> # wave771 other L2 four
#   bash scripts/ensure_host_cc_seed_o.sh try-r2-prefer <out.o> # wave776 R2 panic PREFER thin
#   bash scripts/ensure_host_cc_seed_o.sh try-runtime-os-prefer <out.o> # wave779 B1 runtime OS 23
#   bash scripts/ensure_host_cc_seed_o.sh try-std-core-prefer <out.o> # wave780 B2 std/core 5
#   bash scripts/ensure_host_cc_seed_o.sh try-lsp-sat-prefer <out.o> # wave781 B3 LSP satellite 2
#   bash scripts/ensure_host_cc_seed_o.sh try-gen-c-to-o <out.o> # wave782 B4 gen.c→.o bootstrap 5
#   bash scripts/ensure_host_cc_seed_o.sh try-cfg-eval-ladder <out.o> # wave783 B5 cfg_eval multi-ladder 1
#   bash scripts/ensure_host_cc_seed_o.sh try-heat <out.o>  # wave789 B7A heat auto-dispatch ladder
#   bash scripts/ensure_host_cc_seed_o.sh try-r2 <out.o>   # wave760/762 R2 UNAME leaves
#   bash scripts/ensure_host_cc_seed_o.sh try-gen-x <out.o> # wave761 gen *_x / pipeline_x
#   bash scripts/ensure_host_cc_seed_o.sh r2-panic         # DRIVER_SEED_PANIC family
#   bash scripts/ensure_host_cc_seed_o.sh r2-typeck-f64    # DRIVER_SEED_TYPECK_F64 family
#   bash scripts/ensure_host_cc_seed_o.sh r2-crt0          # DRIVER_SEED_CRT0 family
#   bash scripts/ensure_host_cc_seed_o.sh rt-slice          # RT_SEED_SLICE family
#   bash scripts/ensure_host_cc_seed_o.sh core-seed         # R1_CORE_SEED family
#   bash scripts/ensure_host_cc_seed_o.sh frontend-glue     # R1_FRONTEND_GLUE family
#   bash scripts/ensure_host_cc_seed_o.sh main-runtime      # R1_MAIN_RUNTIME family
#   bash scripts/ensure_host_cc_seed_o.sh alias-stubs       # R1_ALIAS_STUBS family
#   bash scripts/ensure_host_cc_seed_o.sh extra-cflags      # R1_EXTRA_CFLAGS family
#   bash scripts/ensure_host_cc_seed_o.sh misc-basename     # R1_MISC_BASENAME family
#   bash scripts/ensure_host_cc_seed_o.sh seed-map          # R1_SEED_MAP family
#   bash scripts/ensure_host_cc_seed_o.sh all               # all swallowed families
#   bash scripts/ensure_host_cc_seed_o.sh --check
#   bash scripts/ensure_host_cc_seed_o.sh seed-map --force
#   ./xbuild host-cc-seed | … | misc-basename | seed-map | r2-panic
#
#   wave964: --check post_ship when Makefile absent (wave941 phys-del).
#            Catalog + shell seed maps / try-heat ladder remain the authority;
#            MF thin-call residual inventory is N/A (no dual "missing Makefile" fail).
#            PLATFORM: SHARED — 0-make structural honesty; dual-end L2 safe.
#
# Env:
#   CC — host compiler (default: resolve_host_cc.sh — `cc` if present else `gcc`;
#        PLATFORM: WINDOWS/MinGW often has only gcc, no `cc` binary name)
#   CFLAGS — base flags (default: load via make export-try-heat-cflags when unset
#        — wave862; fallback -Wall -Wextra -I. -Iinclude -Isrc)
#   PIPELINE_GEN_CFLAGS — silence flags (default: load via export-try-heat-cflags
#        when unset — wave862; needs make ifeq for CC_IS_CLANG)
#   RUNTIME_DRIVER_CFLAGS / RUNTIME_DRIVER_NO_C_CFLAGS — multi-flag variants
#   RUNTIME_PIPELINE_ABI_CFLAGS / PARSER_ASM_LINK_ALIAS_CFLAGS — extra-cflags family
#     (Makefile thin expands make vars; family mode uses env or defaults below)
#   XLANG_HOST_CC_SEED_FORCE=1 — force recompile (same as --force)
#   MAKE — catalog list expansion + wave862 CFLAGS export leaf (default: make)
#   XLANG_G05_PREFER_X_O — prefer thin .x path when 1 (default per family helper
#        :-0 or :-1). wave881: Makefile try-heat drops PREFER recipe inject;
#        set via make CLI / env (GNU make auto-exports CLI+env vars). Cold seed:
#        `make XLANG_G05_PREFER_X_O=0 …` still forces seed path without inject.
#
# PLATFORM: SHARED — shell orchestration; seed pins host-portable C.
#   R2 panic body: PLATFORM LINUX|x86_64 (.s) / MACOS|arm64 + LINUX|aarch64
#   (arm64 seed) / else (from_x seed). PREFER thin = try-r2-prefer (wave776).
#   R2 typeck_f64 / crt0: PLATFORM per host .s / mingw seed (wave762).
# Wave: 748–763 Track MG · 11.3.1 R1 families + R4 pure-R1 + R3 cold-else +
#       R3 PREFER thin (try-r3-prefer) + thin_glue/glue-standalone seed-map +
#       R2 panic/typeck_f64/crt0 (not physical delete · not pure-ld).

set -euo pipefail
_ENSURE_HOST_CC_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
cd "$_ENSURE_HOST_CC_DIR/.."

# G.7: single default-CC policy (scripts/resolve_host_cc.sh). Do not hardcode
# CC=cc — MinGW ships gcc without a `cc` alias (Windows hybrid min-gate).
# shellcheck source=resolve_host_cc.sh
. "$_ENSURE_HOST_CC_DIR/resolve_host_cc.sh"

# Stage 12.2.1: XLANG_FORBID_HOST_CC gate (no-op when flag unset; zero impact
# on normal builds). When XLANG_FORBID_HOST_CC=1, replaces $CC with a wrapper
# that logs and blocks all host-CC invocations — builds the zero-CC problem map.
# PLATFORM: SHARED.
. "$_ENSURE_HOST_CC_DIR/forbid_host_cc.sh"

# Stage 12.2.3: pure-ld partial-merge helper (replaces $CC -r -nostdlib in
# prefer hybrid merges; zero-CC when XLANG_ZERO_CC_LD=1, else $CC -r zero
# regression). PLATFORM: SHARED.
. "$_ENSURE_HOST_CC_DIR/pure_ld_shared.sh"

# Stage 12.0.5: strip ambient tree PREFER_ASM_O unless ALLOW_TREE (G.7).
# Prefer families re-scope PREFER inside pure_asm subshells. PLATFORM: SHARED.
xlang_strip_tree_prefer_asm_unless_allowed

MAKE="${MAKE:-make}"
FORCE="${XLANG_HOST_CC_SEED_FORCE:-0}"

# wave862 · B7B try-heat CFLAGS bulk shell-load (G.7 有则补全 on wave860 export-leaf).
# Product CFLAGS / PIPELINE_GEN_CFLAGS need make expansion (OPT += -O2; clang
# silence ifeq). Makefile try-heat recipes drop multi-token CFLAGS= env; shell
# loads export-try-heat-cflags when either var is unset. Fallback matches
# historic shell defaults when make export is unavailable.
# wave881 · B7B try-heat PREFER inject hygiene: product try-heat drops PREFER
# inject (no XLANG_G05_PREFER_X_O= / XLANG= recipe inject). Prefer policy is
# env/CLI + shell defaults (G.7 single body).
# wave884 · B7B residual CC= inject hygiene: product try-heat is env-free thin
# @bash only — CC from resolve_host_cc when unset; make CLI/env auto-export.
# wave885 · B7B residual G05_SYNC inject hygiene: relink-xlang / xlang_asm drop
# G05_SYNC_ASM= recipe inject; shell --no-sync + default sync own policy.
# wave886 · B7B residual LD + pipeline bag inject hygiene: cfg_eval drops
# LD=/LD_RELFLAGS=; pipeline_x drops PIPELINE_X_* / XLANG_FORCE_REGEN_GEN inject.
# Shell owns LD defaults + PIPELINE_X_DEPS mk-load when unset.
# Residual: thin edges · B2 · mk lists · physical delete.
# wave942: catalog-primary CFLAGS/PIPELINE_GEN_CFLAGS load (was make
# export-try-heat-cflags). Makefile physically deleted in wave941; catalog is
# the single authority for mk-derived KEY=VALUE (CC, CFLAGS, PIPELINE_GEN_CFLAGS
# all sourced from mk/*.mk via driver_seed_obj_catalog.sh --shell).
# XLANG_CATALOG_CACHE_FILE lets the parent bootstrap pass a pre-warmed cache
# so this script does not re-parse all mk files (Windows MinGW: ~3min/call).
# PLATFORM: SHARED — same KEY=VALUE semantics on Darwin/Linux/Windows MSYS2.
_load_try_heat_cflags_via_catalog() {
  local _val
  if [ -z "${CFLAGS+x}" ]; then
    if [ -n "${XLANG_CATALOG_CACHE_FILE:-}" ] && [ -s "${XLANG_CATALOG_CACHE_FILE:-}" ]; then
      _val=$(sed -n "s|^CFLAGS=||p" "${XLANG_CATALOG_CACHE_FILE}" | tail -n 1)
    else
      _val=$(bash scripts/driver_seed_obj_catalog.sh --shell 2>/dev/null \
        | sed -n "s|^CFLAGS=||p" | tail -n 1)
    fi
    [ -n "$_val" ] && CFLAGS="$_val"
  fi
  if [ -z "${PIPELINE_GEN_CFLAGS+x}" ]; then
    if [ -n "${XLANG_CATALOG_CACHE_FILE:-}" ] && [ -s "${XLANG_CATALOG_CACHE_FILE:-}" ]; then
      _val=$(sed -n "s|^PIPELINE_GEN_CFLAGS=||p" "${XLANG_CATALOG_CACHE_FILE}" | tail -n 1)
    else
      _val=$(bash scripts/driver_seed_obj_catalog.sh --shell 2>/dev/null \
        | sed -n "s|^PIPELINE_GEN_CFLAGS=||p" | tail -n 1)
    fi
    [ -n "$_val" ] && PIPELINE_GEN_CFLAGS="$_val"
  fi
  return 0
}

if [ -z "${CFLAGS+x}" ] || [ -z "${PIPELINE_GEN_CFLAGS+x}" ]; then
  _load_try_heat_cflags_via_catalog || true
fi
# Match g05 / Makefile product includes; PIPELINE_GEN_CFLAGS optional when empty.
BASE_CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}"
# PLATFORM: MACOS — match macho.x LC_BUILD_VERSION minos 11.0.0.
# Catalog CFLAGS already completes this when unset; keep the flag if env CFLAGS
# omitted it so always-linked companions (stubs/panic/user_env) match product-asm.
# Do not -w swallow; do not raise macho.x minos to 26.0.
case "$(uname -s 2>/dev/null)" in
  Darwin)
    case " $BASE_CFLAGS " in
      *" -mmacosx-version-min="*) ;;
      *) BASE_CFLAGS="$BASE_CFLAGS -mmacosx-version-min=11.0" ;;
    esac
    ;;
esac
PIPELINE_GEN_CFLAGS="${PIPELINE_GEN_CFLAGS:-}"

# Default multi-flag mirrors for family mode when env empty.
# PLATFORM: SHARED — must stay aligned with Makefile RUNTIME_DRIVER_*_CFLAGS
# (without optional XLANG_LEGACY_PREPROCESS_C; LEGACY path dead after preprocess.c
# physical delete). wave864: product thin leaves no longer inject make-expanded
# RUNTIME_*/PARSER_* bags — shell defaults are the authority when env unset.
_DEFAULT_RT_SLICE_CFLAGS="-DXLANG_RT_ARENA_BUF_FROM_X -DXLANG_RT_EMIT_STATE_FROM_X -DXLANG_RT_PREAMBLE_FROM_X -DXLANG_RT_STACK_FROM_X -DXLANG_RT_PARSE_DIAG_FROM_X"
_DEFAULT_RUNTIME_DRIVER_CFLAGS="-DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_PREPROCESS -DXLANG_NO_C_FRONTEND -DXLANG_ASM_USE_COMPILER_IMPL_C ${_DEFAULT_RT_SLICE_CFLAGS}"
_DEFAULT_RUNTIME_DRIVER_NO_C_CFLAGS="-DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_PREPROCESS -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN -DXLANG_NO_C_FRONTEND -DXLANG_ASM_USE_COMPILER_IMPL_C ${_DEFAULT_RT_SLICE_CFLAGS}"
# PLATFORM: SHARED — defaults aligned with Makefile (without optional LEGACY).
_DEFAULT_RUNTIME_PIPELINE_ABI_CFLAGS="-DXLANG_USE_X_PIPELINE"
_DEFAULT_PARSER_ASM_LINK_ALIAS_CFLAGS="-DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS"
# PLATFORM: SHARED — aligned with Makefile PARSER_ASM_THIN_GLUE_CFLAGS + -I paths.
_DEFAULT_PARSER_ASM_THIN_GLUE_CFLAGS="-DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE -Isrc/lexer -Isrc/asm -Iseeds/parser_asm"

# wave326: M4 7.3.1 link_abi mega pin close — prefer 12× labi_*.x slices by default.
# Product authority: L0..L9 + L8b + L8c labi_*.x prefer → per-slice .o →
#   $CC -r -nostdlib merge → src/runtime_link_abi.o; -D XLANG_LABI_*_FROM_X only
#   on slices that preferred .x (rest compiled from mega seed with those gates).
# Pin seed (seeds/runtime_link_abi.from_x.c + seeds/labi_*.from_x.c) is
#   archaeology egg only (true cold / no product xlang binary).
# PLATFORM: SHARED — cold start (R1_CORE_SEED direct call) + g05 daily path
#   now aligned (no more "g05 PREFER=1 vs direct call PREFER=0" dual policy).
# Aligned with wave322 typeck / wave323 codegen / wave325 parser FROM_X defaults.
XLANG_LINK_ABI_FROM_X="${XLANG_LINK_ABI_FROM_X:-1}"
XLANG_LINK_ABI_ALLOW_PIN="${XLANG_LINK_ABI_ALLOW_PIN:-1}"

MODE="${1:-}"
if [ -z "$MODE" ]; then
  echo "ensure_host_cc_seed_o: usage: one|try-r1|try-r3-cold|try-r3-prefer|try-labi-prefer|try-rt-prefer|try-pipeline-abi-prefer|inject-macho-write|inject-emit-ctx-bss|inject-pabi-leaf|try-ldpc-prefer|try-target-cpu-prefer|try-l2-asm-prefer|try-async-prefer|try-other-l2-prefer|try-r2-prefer|try-runtime-os-prefer|try-std-core-prefer|try-lsp-sat-prefer|try-gen-c-to-o|try-cfg-eval-ladder|try-x-to-o|try-heat|try-r2|try-gen-x|rt-slice|core-seed|frontend-glue|main-runtime|alias-stubs|extra-cflags|misc-basename|seed-map|r3-cold-seed|r2-panic|r2-typeck-f64|r2-crt0|gen-x|all|--check  (see header)" >&2
  exit 2
fi
shift || true

# Parse trailing --force on any mode
for arg in "$@"; do
  case "$arg" in
    --force|-f|force) FORCE=1 ;;
  esac
done

log() { echo "ensure-host-cc-seed: $*" >&2; }


# ---------------------------------------------------------------------------
# wave793: project-header freshness (G.7 single body for FORCE thin).
#
# Mirror Makefile .h prereqs without dual lists: scan seed #include "..." / <...>
# and resolve under dirname(seed), include/, src/, and .  Depth-capped BFS so
# transitive project headers (e.g. lexer.h → token.h) refresh the .o.
# System headers (not found under project paths) are ignored.
# First-hop also catches twin seed embeds (#include "seeds/async_net_fs.from_x.c",
# runtime_heap_user.from_x.c) — wave794 twin FORCE thin relies on this.
# Exit 0 if any resolved project header is newer than OUT; else 1.
# PLATFORM: SHARED — portable shell; no make graph.
# ---------------------------------------------------------------------------
seed_project_hdrs_newer() {
  local seed="$1"
  local out="$2"
  local f inc cand resolved dir n=0 max_n=64
  local queue="" seen=" "
  if [ -z "$seed" ] || [ -z "$out" ] || [ ! -f "$seed" ] || [ ! -f "$out" ]; then
    return 1
  fi
  queue="$seed"
  seen=" $seed "
  while [ -n "$queue" ] && [ "$n" -lt "$max_n" ]; do
    f="${queue%% *}"
    if [ "$queue" = "$f" ]; then
      queue=""
    else
      queue="${queue#* }"
    fi
    n=$((n + 1))
    [ -f "$f" ] || continue
    dir="$(dirname "$f")"
    # shellcheck disable=SC2016
    while IFS= read -r inc || [ -n "$inc" ]; do
      [ -z "$inc" ] && continue
      # Skip obvious libc / system basenames when not present in project tree.
      resolved=""
      for cand in "$dir/$inc" "include/$inc" "src/$inc" "$inc"; do
        if [ -f "$cand" ]; then
          resolved="$cand"
          break
        fi
      done
      [ -z "$resolved" ] && continue
      if [ "$resolved" -nt "$out" ]; then
        return 0
      fi
      case "$seen" in
        *" $resolved "*) ;;
        *)
          seen="$seen$resolved "
          case "$resolved" in
            *.h|*.hpp|*.inc)
              if [ -z "$queue" ]; then
                queue="$resolved"
              else
                queue="$queue $resolved"
              fi
              ;;
          esac
          ;;
      esac
    done <<EOF
$(sed -n 's/^[[:space:]]*#[[:space:]]*include[[:space:]]*[<"]\([^>"]*\)[>"].*/\1/p' "$f" 2>/dev/null || true)
EOF
  done
  return 1
}

# ---------------------------------------------------------------------------
# wave794: Makefile mtime for flag-sensitive FORCE-thin leaves (G.7 single body).
#
# These leaves historically listed Makefile as a make prereq so CFLAGS / -D
# Historic FORCE-thin edge: Makefile mtime drove macro-flag rebuilds
# (USE_X_PIPELINE / USE_X_DRIVER / NO_C / …). wave941 deleted Makefile —
# dead `[ Makefile -nt OUT ]` never fires (bash missing -nt → false).
# Authority now = FORCE / catalog / seed+.x (ensure_one); this helper stays
# as a named no-op so callers keep a single G.7 hook.
# Exit 0 if flags source is newer than OUT; else 1 (always 1 post-MG).
# PLATFORM: SHARED — portable shell; no make graph.
# ---------------------------------------------------------------------------
force_thin_makefile_flags_newer() {
  local out="$1"
  case "$out" in
    # wave794: main/runtime/pipeline macro flags · wave795: crt0_mingw WIN32_O_CFLAGS
    # wave941: Makefile absent — never refresh via deleted make graph.
    src/main_driver.o|src/runtime_driver.o|src/runtime_driver_no_c.o|src/runtime_pipeline_abi.o|src/asm/crt0_mingw.o)
      return 1
      ;;
  esac
  return 1
}

# ---------------------------------------------------------------------------
# one OUT SEED [extra cflags...]
# PLATFORM: SHARED — pure host-cc body; no make graph.
# ---------------------------------------------------------------------------
ensure_one() {
  local out="$1"
  local seed="$2"
  shift 2
  # Drop --force tokens if present as extra args
  local extras=()
  local a
  for a in "$@"; do
    case "$a" in
      --force|-f|force) continue ;;
      *) extras+=("$a") ;;
    esac
  done

  if [ -z "$out" ] || [ -z "$seed" ]; then
    echo "ensure_host_cc_seed_o one: need <out.o> <seed.from_x.c>" >&2
    exit 2
  fi

  # w857: this object has no C seed. Check it before the missing-seed exit
  # so a caller that still passes the old path name does not fail closed.
  # PLATFORM: SHARED.
  if [ "$out" = "src/asm/backend_arch_emit_dispatch.o" ]; then
    ensure_arch_emit_dispatch_pure || return 1
    return 0
  fi

  if [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o: missing seed $seed" >&2
    exit 1
  fi
  # w862: thin enc publics and the slice marker are in the .x.
  # Do not cc the tail alone. PLATFORM: SHARED.
  if [ "$out" = "src/asm/backend_enc_dispatch.o" ]; then
    ensure_enc_dispatch_pure || return 1
    return 0
  fi

  mkdir -p "$(dirname "$out")"

  if [ "$FORCE" != "1" ] && [ -f "$out" ] && [ ! "$seed" -nt "$out" ]; then
    # Sibling .x deps: out path stem, seed-stem under src/asm or src/,
    # and main_c_entry.x for main family (Makefile dep name).
    local need=0
    local xsrc stem cand inc
    xsrc="${out%.o}.x"
    if [ -f "$xsrc" ] && [ "$xsrc" -nt "$out" ]; then
      need=1
    fi
    stem="$(basename "$seed" .from_x.c)"
    for cand in "src/asm/${stem}.x" "src/${stem}.x" "src/main_c_entry.x"; do
      if [ -f "$cand" ] && [ "$cand" -nt "$out" ]; then
        need=1
        break
      fi
    done
    # wave758: parser_asm_thin_glue monothin includes many seeds/parser_asm/*.inc;
    # Makefile lists them as prereqs — mirror freshness here (G.7 single body).
    if [ "$need" -eq 0 ] && [ "$stem" = "parser_asm_thin_c" ]; then
      for inc in seeds/parser_asm/*.inc; do
        if [ -f "$inc" ] && [ "$inc" -nt "$out" ]; then
          need=1
          break
        fi
      done
    fi
    # wave759→wave309: glue_standalone seed retired; deleted pipeline_glue.c /
    # ast_pool.c -nt never fire. Residual freshness = types.inc only when the
    # archaeology seed path is still invoked (G.7 single body). PLATFORM: SHARED.
    if [ "$need" -eq 0 ] && [ "$stem" = "pipeline_glue_standalone" ]; then
      for cand in build_asm/pipeline_glue_types.inc; do
        if [ -f "$cand" ] && [ "$cand" -nt "$out" ]; then
          need=1
          break
        fi
      done
    fi
    # wave797: pipeline_bootstrap_orchestration historically rebuilt when pipeline_gen.c
    # or build_asm/pipeline_glue_types.inc changed (Makefile prereq twin). Mirror here
    # so FORCE + try-heat can drop source prereqs (G.7 single body; not physical delete).
    if [ "$need" -eq 0 ] && [ "$stem" = "pipeline_bootstrap_orchestration" ]; then
      for cand in pipeline_gen.c build_asm/pipeline_glue_types.inc; do
        if [ -f "$cand" ] && [ "$cand" -nt "$out" ]; then
          need=1
          break
        fi
      done
    fi
    # wave793: project headers (Makefile .h prereqs) — single body for FORCE thin.
    if [ "$need" -eq 0 ] && seed_project_hdrs_newer "$seed" "$out"; then
      need=1
    fi
    # wave794: Makefile flag-sensitive FORCE thin (main/runtime/pipeline_abi).
    if [ "$need" -eq 0 ] && force_thin_makefile_flags_newer "$out"; then
      need=1
    fi
    if [ "$need" -eq 0 ]; then
      log "skip $out (up-to-date vs $seed)"
      return 0
    fi
  fi

  # wave940: pipeline_glue_standalone.o embeds build_asm/pipeline_glue_types.inc
  # via #include. On cold start (build_asm/ cleared) the .inc is missing and
  # cc fails with "fatal error: pipeline_glue_types.inc: No such file or
  # directory". Root-cause fix (G.7 single body): ensure .inc before cc -c.
  # PLATFORM: SHARED — same extract on Darwin/Linux/Windows MSYS2.
  # Before wave940 this was a symptom-level fix (manual cc -Ibuild_asm); now
  # the seed-map body owns the .inc prerequisite just like Makefile prereq.
  if [ "$out" = "build_asm/pipeline_glue_standalone.o" ] \
    && [ ! -s build_asm/pipeline_glue_types.inc ] \
    && [ -f scripts/ensure_pipeline_glue_types.sh ]; then
    log "ensure build_asm/pipeline_glue_types.inc (cold-start prereq for $out)"
    bash scripts/ensure_pipeline_glue_types.sh >&2 || {
      echo "ensure_host_cc_seed_o: ensure_pipeline_glue_types.sh failed for $out" >&2
      return 1
    }
  fi

  log "cc -c $seed → $out"
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS "${extras[@]+"${extras[@]}"}" -c -o "$out" "$seed"; then
    echo "ensure_host_cc_seed_o: cc failed for $out (seed=$seed)" >&2
    return 1
  fi
}

# ---------------------------------------------------------------------------
# Catalog list expansion (G.7: KEY only; no hardcoded .o inventory in shell)
# ---------------------------------------------------------------------------
# Process + optional file cache (wave MG Windows):
#   try-heat is invoked as a *new bash* per Makefile FORCE leaf. Without a
#   shared cache, each of ~50 ensure goals re-runs driver_seed_obj_catalog.sh
#   (full mk parse). On MinGW/Git Bash that multi-minute stalls look like a
#   hung make with no gcc. catalog_blob already memoizes in-process; also honor
#   XLANG_CATALOG_CACHE_FILE so ensure_prereqs / rebuild can warm once.
# PLATFORM: SHARED — cache is optional; unset = prior in-process-only behavior.
catalog_blob() {
  # Prefer shared file cache (cross-process for one ensure/make/bootstrap wave).
  # Parent (bootstrap_driver_seed / ensure_prereqs / rebuild_leaves) should set
  # XLANG_CATALOG_CACHE_FILE; without it each try-* re-parses mk (Windows stall).
  if [ -n "${XLANG_CATALOG_CACHE_FILE:-}" ] && [ -s "${XLANG_CATALOG_CACHE_FILE}" ]; then
    cat "${XLANG_CATALOG_CACHE_FILE}"
    return 0
  fi
  if [ -z "${_catalog_blob_cache:-}" ]; then
    if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
      echo "ensure_host_cc_seed_o: missing scripts/driver_seed_obj_catalog.sh" >&2
      exit 1
    fi
    # --shell: never route catalog through MAKE wrap (Windows gate MAKE is a
    # logging wrapper; export-via-make is LEGACY only). PLATFORM: SHARED.
    _catalog_blob_cache="$(bash scripts/driver_seed_obj_catalog.sh --shell)"
    if [ -n "${XLANG_CATALOG_CACHE_FILE:-}" ]; then
      # Best-effort warm for sibling try-heat processes in the same ensure wave.
      printf '%s\n' "$_catalog_blob_cache" >"${XLANG_CATALOG_CACHE_FILE}" 2>/dev/null || true
    fi
  fi
  printf '%s\n' "$_catalog_blob_cache"
}

catalog_key_list() {
  # $1 = catalog KEY name (e.g. RT_SEED_SLICE_OBJS)
  local key="$1"
  local key_line
  if [ -z "$key" ]; then
    echo "ensure_host_cc_seed_o: catalog_key_list needs KEY" >&2
    exit 2
  fi
  key_line="$(catalog_blob | sed -n "s|^${key}=||p" | head -1)"
  if [ -z "${key_line// /}" ]; then
    echo "ensure_host_cc_seed_o: empty $key from catalog (export missing?)" >&2
    exit 1
  fi
  printf '%s\n' "$key_line"
}

# seed convention (basename match): basename of .o → seeds/<basename>.from_x.c
seed_for_o() {
  local o="$1"
  local base
  base="$(basename "$o" .o)"
  printf 'seeds/%s.from_x.c\n' "$base"
}

# seed convention (frontend-glue basename mismatch): o path → seed path.
# PLATFORM: SHARED — map is path convention only; list authority = catalog KEY.
# Not a second .o inventory: unknown catalog members fail closed.
seed_for_frontend_glue() {
  local o="$1"
  case "$o" in
    src/lexer/lexer.o)   printf 'seeds/runtime_lexer_glue.from_x.c\n' ;;
    src/ast/ast.o)       printf 'seeds/runtime_ast_glue.from_x.c\n' ;;
    src/lsp/lsp_diag.o)  printf 'seeds/runtime_lsp_glue.from_x.c\n' ;;
    *)
      echo "ensure_host_cc_seed_o: no frontend-glue seed map for $o" >&2
      exit 1
      ;;
  esac
}

# seed convention (main-runtime multi-out from shared seeds).
# PLATFORM: SHARED — map is path convention only; list authority = catalog KEY.
# wave321: runtime* monofile retired — map reports content layer gate seed
# (check / inventory); body builds via ensure_runtime_multi_slice_leaf.
seed_for_main_runtime() {
  local o="$1"
  case "$o" in
    src/main.o|src/main_x.o|src/main_driver.o)
      printf 'seeds/main.from_x.c\n'
      ;;
    src/runtime.o|src/runtime_x.o|src/runtime_driver.o|src/runtime_driver_no_c.o)
      # wave321 7.1.1: monofile seeds/runtime.from_x.c physically retired.
      # Content layer seed is the product multi-slice gate (wave320).
      printf 'seeds/rt_content.from_x.c\n'
      ;;
    *)
      echo "ensure_host_cc_seed_o: no main-runtime seed map for $o" >&2
      exit 1
      ;;
  esac
}

# wave321: R1 runtime*.o leaves — multi-slice only (no monofile host-cc).
# PLATFORM: SHARED freestanding product no_c multi-slice is the sole authority.
is_runtime_multi_slice_leaf() {
  case "$1" in
    src/runtime.o|src/runtime_x.o|src/runtime_driver.o|src/runtime_driver_no_c.o)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Build product multi-slice into runtime_driver_no_c.o; optional alias copy for
# archaeology catalog members that historically used monofile + different -D.
# G.7: single body = ensure_rt_prefer_one; no second monofile compile path.
ensure_runtime_multi_slice_leaf() {
  local o="$1"
  local no_c="src/runtime_driver_no_c.o"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o: ensure_runtime_multi_slice_leaf needs <out.o>" >&2
    return 2
  fi
  if ! is_runtime_multi_slice_leaf "$o"; then
    echo "ensure_host_cc_seed_o: $o is not a runtime multi-slice leaf" >&2
    return 1
  fi
  # Product authority always lands on no_c first.
  ensure_rt_prefer_one "$no_c" || return 1
  if [ "$o" != "$no_c" ]; then
    # wave321: monofile flag variants (plain / USE_X_PIPELINE / DRIVER_CFLAGS)
    # retired with physical monofile rm. Catalog still lists these .o for R1
    # inventory; content = multi-slice no_c product object (alias copy).
    mkdir -p "$(dirname "$o")"
    cp -f "$no_c" "$o" || return 1
    log "main-runtime: $o ← multi-slice no_c alias (wave321 monofile retired)"
  fi
  return 0
}

# Extra -D flags for main-runtime family (stdout, space-separated; may be empty).
# wave864: product try-heat thin-call is CC= only; env override still honored when
# set; else shell defaults (authority). Makefile may still define flag bags for
# force_thin_makefile_flags_newer / docs — not recipe inject.
# Family mode: use env when set, else defaults aligned with Makefile base flags.
extras_for_main_runtime() {
  local o="$1"
  case "$o" in
    src/main.o|src/runtime.o)
      ;;
    src/main_x.o|src/runtime_x.o)
      printf '%s' '-DXLANG_USE_X_PIPELINE'
      ;;
    src/main_driver.o)
      printf '%s' '-DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE'
      ;;
    src/runtime_driver.o)
      if [ -n "${RUNTIME_DRIVER_CFLAGS:-}" ]; then
        printf '%s' "$RUNTIME_DRIVER_CFLAGS"
      else
        printf '%s' "$_DEFAULT_RUNTIME_DRIVER_CFLAGS"
      fi
      ;;
    src/runtime_driver_no_c.o)
      if [ -n "${RUNTIME_DRIVER_NO_C_CFLAGS:-}" ]; then
        printf '%s' "$RUNTIME_DRIVER_NO_C_CFLAGS"
      else
        printf '%s' "$_DEFAULT_RUNTIME_DRIVER_NO_C_CFLAGS"
      fi
      ;;
    *)
      echo "ensure_host_cc_seed_o: no main-runtime extras map for $o" >&2
      exit 1
      ;;
  esac
}

# seed convention (extra-cflags: basename + multi-out sqlite stub).
# PLATFORM: SHARED — map is path convention only; list authority = catalog KEY.
seed_for_extra_cflags() {
  local o="$1"
  case "$o" in
    runtime_sqlite_glue_stub.o)
      printf 'seeds/runtime_sqlite_glue.from_x.c\n'
      ;;
    src/runtime_pipeline_abi.o|runtime_asm_io_stubs.o|runtime_sqlite_glue.o|src/asm/parser_asm_parse_expr_link.o)
      seed_for_o "$o"
      ;;
    *)
      echo "ensure_host_cc_seed_o: no extra-cflags seed map for $o" >&2
      exit 1
      ;;
  esac
}

# Extra flags for extra-cflags family (stdout, space-separated; may be empty).
# wave864: pipeline_abi product thin-call is CC= only; env override still honored;
# else _DEFAULT_RUNTIME_PIPELINE_ABI_CFLAGS. Other leaves use fixed -fPIE/-D bags.
# Family mode: use env when set, else defaults aligned with Makefile base flags.
extras_for_extra_cflags() {
  local o="$1"
  case "$o" in
    src/runtime_pipeline_abi.o)
      if [ -n "${RUNTIME_PIPELINE_ABI_CFLAGS:-}" ]; then
        printf '%s' "$RUNTIME_PIPELINE_ABI_CFLAGS"
      else
        printf '%s' "$_DEFAULT_RUNTIME_PIPELINE_ABI_CFLAGS"
      fi
      ;;
    runtime_asm_io_stubs.o)
      printf '%s' '-fPIE'
      ;;
    runtime_sqlite_glue.o)
      # PLATFORM: SHARED — seed has #ifdef XLANG_DB_USE_SQLITE3 / stub #else.
      # Always defining it makes cc -c require sqlite3.h (Ubuntu gold may not
      # ship libsqlite3). Probe the header; omit the define so stub T
      # xlang_db_use_sqlite3_c still lands. G.7 complete extra-cflags; product
      # -o must not hard-fail on missing sqlite3.h (cookbook sqlite_available).
      if echo '#include <sqlite3.h>' | ${CC:-cc} -E - >/dev/null 2>&1; then
        printf '%s' '-DXLANG_DB_USE_SQLITE3'
      fi
      ;;
    runtime_sqlite_glue_stub.o)
      ;;
    src/asm/parser_asm_parse_expr_link.o)
      if [ -n "${PARSER_ASM_LINK_ALIAS_CFLAGS:-}" ]; then
        printf '%s' "$PARSER_ASM_LINK_ALIAS_CFLAGS"
      else
        printf '%s' "$_DEFAULT_PARSER_ASM_LINK_ALIAS_CFLAGS"
      fi
      ;;
    *)
      echo "ensure_host_cc_seed_o: no extra-cflags extras map for $o" >&2
      exit 1
      ;;
  esac
}


# seed convention (seed-map: basename mismatch + orch basename).
# PLATFORM: SHARED — map is path convention only; list authority = catalog KEY.
# Not a second .o inventory: unknown catalog members fail closed.
seed_for_seed_map() {
  local o="$1"
  case "$o" in
    src/driver/target_cpu.o)
      printf 'seeds/target_cpu_pure.from_x.c\n'
      ;;
    src/ast/ast_seed.o)
      printf 'seeds/runtime_ast_glue.from_x.c\n'
      ;;
    pipeline_bootstrap_orchestration.o)
      printf 'seeds/pipeline_bootstrap_orchestration.from_x.c\n'
      ;;
    # wave758: R4 residual pure host-cc monothin (basename mismatch).
    parser_asm_thin_glue.o)
      printf 'seeds/parser_asm_thin_c.from_x.c\n'
      ;;
    # wave759: R4 residual glue standalone (build_asm/ path; basename seed).
    build_asm/pipeline_glue_standalone.o)
      printf 'seeds/pipeline_glue_standalone.from_x.c\n'
      ;;
    *)
      echo "ensure_host_cc_seed_o: no seed-map seed map for $o" >&2
      exit 1
      ;;
  esac
}

# Extra flags for seed-map family (stdout, space-separated; may be empty).
# wave864: parser_asm_thin_glue product thin-call is CC= only; env override still
# honored; else _DEFAULT_PARSER_ASM_THIN_GLUE_CFLAGS (-D + monothin -I).
# Family mode: orch needs -Ibuild_asm + -D; thin_glue needs NO_SEED_PARSE + -I;
# glue standalone needs -Wno-error=return-type -Ibuild_asm; target_cpu/ast_seed pure.
extras_for_seed_map() {
  local o="$1"
  case "$o" in
    src/driver/target_cpu.o|src/ast/ast_seed.o)
      ;;
    pipeline_bootstrap_orchestration.o)
      printf '%s' '-Ibuild_asm -DPIPELINE_BOOTSTRAP_ORCH_NO_PIPELINE_RUN_WRAPPER'
      ;;
    parser_asm_thin_glue.o)
      if [ -n "${PARSER_ASM_THIN_GLUE_CFLAGS:-}" ]; then
        # Makefile thin may export only -D; always append monothin -I paths.
        printf '%s %s' "$PARSER_ASM_THIN_GLUE_CFLAGS" "-Isrc/lexer -Isrc/asm -Iseeds/parser_asm"
      else
        printf '%s' "$_DEFAULT_PARSER_ASM_THIN_GLUE_CFLAGS"
      fi
      ;;
    # wave759: match Makefile/g05 cc_inc_tu extras (types.inc under build_asm/).
    build_asm/pipeline_glue_standalone.o)
      printf '%s' '-Wno-error=return-type -Ibuild_asm'
      ;;
    *)
      echo "ensure_host_cc_seed_o: no seed-map extras map for $o" >&2
      exit 1
      ;;
  esac
}

# Ensure every .o in catalog KEY via pure host-cc body.
# $1=KEY $2=label $3=seed_mode (basename|frontend-glue|main-runtime|extra-cflags|seed-map)
ensure_catalog_family() {
  local key="$1"
  local label="$2"
  local seed_mode="${3:-basename}"
  local list n=0 o seed extras_str
  list="$(catalog_key_list "$key")"
  # Word-split intentionally (space-separated make expansion).
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    # w847/w863/w864/w865/w866/w867/w868/w869: seed-only cc drops the alias bodies that live in the .x.
    # PLATFORM: SHARED.
    if [ "$o" = "x_frontend_link_alias.o" ]; then
      ensure_x_frontend_link_alias_prefer || exit 1
      n=$((n + 1))
      continue
    fi
    # wave321: runtime* R1 leaves never host-cc monofile (multi-slice only).
    if [ "$seed_mode" = "main-runtime" ] && is_runtime_multi_slice_leaf "$o"; then
      ensure_runtime_multi_slice_leaf "$o" || exit 1
      n=$((n + 1))
      continue
    fi
    case "$seed_mode" in
      basename) seed="$(seed_for_o "$o")" ;;
      frontend-glue) seed="$(seed_for_frontend_glue "$o")" ;;
      main-runtime) seed="$(seed_for_main_runtime "$o")" ;;
      extra-cflags) seed="$(seed_for_extra_cflags "$o")" ;;
      seed-map) seed="$(seed_for_seed_map "$o")" ;;
      *)
        echo "ensure_host_cc_seed_o: unknown seed_mode $seed_mode" >&2
        exit 2
        ;;
    esac
    extras_str=""
    case "$seed_mode" in
      main-runtime) extras_str="$(extras_for_main_runtime "$o")" ;;
      extra-cflags) extras_str="$(extras_for_extra_cflags "$o")" ;;
      seed-map) extras_str="$(extras_for_seed_map "$o")" ;;
    esac
    if [ -n "$extras_str" ]; then
      # shellcheck disable=SC2086
      ensure_one "$o" "$seed" $extras_str
    else
      ensure_one "$o" "$seed"
    fi
    n=$((n + 1))
  done
  log "$label OK ($n objs via catalog $key)"
}

# Product install of src/runtime/rt_emit_state.o:
#   pure-asm src/runtime/rt_emit_state.x (five setters + slice marker)
#   + seeds/rt_emit_state.from_x.c (BSS + lib-name + entry prefix)
# The five setters were deleted from the seed in w845.
# labi_rt_emit_state_slice_marker moved into the .x in w859 (still returns 1).
# There is no full-seed fallback and no Windows special case: a seed-only cc
# does not define the setters or the marker. XLANG_G05_PREFER_X_O is ignored.
# Do not gcc -E this TU. Do not rebuild runtime_driver_no_c.o from this path.
# Failure leaves the previous .o in place and returns 1.
# PLATFORM: SHARED — POSIX and Windows both take this path.
# G.7: one body; g05 rt-slice, build_xlang_asm, strict glue, and the
# experimental bootstrap call this. The older try-rt-prefer temp must not
# replace this .o.
ensure_rt_emit_state_prefer() {
  local o="src/runtime/rt_emit_state.o"
  local seed="seeds/rt_emit_state.from_x.c"
  local xsrc="src/runtime/rt_emit_state.x"
  local thin rest merged ld_flags bare_thin bare_rest bare_merged

  if [ ! -f "$seed" ] || [ ! -f "$xsrc" ]; then
    echo "ensure_host_cc_seed_o try-rt-emit-state-prefer: missing $seed or $xsrc" >&2
    return 1
  fi

  # Up-to-date: seed, the .x, and project headers. A full-cc .o that predates
  # the deleted C bodies still rebuilds once either input moves.
  if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ ! "$seed" -nt "$o" ]; then
    if [ ! "$xsrc" -nt "$o" ] && ! seed_project_hdrs_newer "$seed" "$o"; then
      log "skip up-to-date $o (rt-emit-state)"
      return 0
    fi
  fi

  bare_thin="$(mktemp "${TMPDIR:-/tmp}/rtemit_thin.XXXXXX")" || true
  bare_rest="$(mktemp "${TMPDIR:-/tmp}/rtemit_rest.XXXXXX")" || true
  bare_merged="$(mktemp "${TMPDIR:-/tmp}/rtemit_merged.XXXXXX")" || true
  if [ -z "$bare_thin" ] || [ -z "$bare_rest" ] || [ -z "$bare_merged" ]; then
    echo "ensure: rt-emit-state mktemp failed" >&2
    rm -f "$bare_thin" "$bare_rest" "$bare_merged"
    return 1
  fi
  rm -f "$bare_thin" "$bare_rest" "$bare_merged"
  thin="${bare_thin}.o"
  rest="${bare_rest}.o"
  merged="${bare_merged}.o"
  # pure_asm only. Do not fall through to gcc -E of this TU.
  # PLATFORM: SHARED — rt_prefer scopes PREFER_ASM_O inside the subshell.
  # The marker is in the .x. The seed cc emits BSS, lib-name, and entry prefix.
  if (
    if [ "${XLANG_PREFER_ASM_O_RT:-1}" = "1" ]; then
      export XLANG_PREFER_ASM_O=1
    elif [ "${XLANG_ALLOW_TREE_PREFER_ASM:-0}" != "1" ]; then
      unset XLANG_PREFER_ASM_O
    fi
    unset G05_X_O_WEAK G05_X_O_WEAK_FUNCS
    pure_asm_x_to_o "$thin" "$xsrc"
  ) && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c "$seed" -o "$rest" \
    && ld_flags="$(r3_prefer_ld_r_flags)" \
    && ld $ld_flags -o "$merged" "$thin" "$rest" \
    && r3_prefer_nm_has_sym "$merged" "driver_run_x_emit_c_set_path" \
    && r3_prefer_nm_has_sym "$merged" "driver_run_x_emit_c_set_lib" \
    && r3_prefer_nm_has_sym "$merged" "driver_run_x_emit_c_set_n_lib_roots" \
    && r3_prefer_nm_has_sym "$merged" "driver_run_x_emit_c_set_emit_extern" \
    && r3_prefer_nm_has_sym "$merged" "driver_argv_parse_x_emit_c" \
    && r3_prefer_nm_has_sym "$merged" "labi_rt_emit_state_slice_marker" \
    && r3_prefer_nm_has_sym "$merged" "xlang_pipeline_pctx_set_entry_lib_prefix" \
    && r3_prefer_nm_has_sym "$merged" "xlang_driver_x_emit_set_lib_name" \
    && r3_prefer_nm_has_sym "$merged" "xlang_driver_x_emit_lib_name_into" \
    && r3_prefer_nm_has_sym "$merged" "driver_x_emit_c_path" \
    && r3_prefer_nm_has_sym "$merged" "driver_x_emit_lib_name_buf"; then
    mv -f "$merged" "$o"
    log "rt-emit-state $o <- pure-asm $xsrc + BSS rest (w859; marker is in the .x)"
    rm -f "$thin" "$rest"
    return 0
  fi
  echo "ensure: rt-emit-state pure-asm failed; marker and setters are in the .x, no seed fallback" >&2
  rm -f "$thin" "$rest" "$merged"
  return 1
}

# Product install of src/runtime/rt_arena_buf.o:
#   pure-asm src/runtime/rt_arena_buf.x (two buffers + slice marker)
#   + seeds/rt_arena_buf.from_x.c (128MiB / 2MiB BSS only)
# driver_arena_buf / driver_module_buf were deleted from the seed in w844.
# labi_rt_arena_buf_slice_marker moved into the .x in w858 (still returns 1).
# There is no full-seed fallback and no Windows special case: a seed-only cc
# does not define those symbols. XLANG_G05_PREFER_X_O is ignored.
# Do not gcc -E this TU. Do not rebuild runtime_driver_no_c.o from this path.
# Failure leaves the previous .o in place and returns 1.
# PLATFORM: SHARED — POSIX and Windows both take this path.
# G.7: one body; g05 rt-slice, build_xlang_asm, strict glue, and the
# experimental bootstrap call this. The older try-rt-prefer temp must not
# replace this .o.
ensure_rt_arena_buf_prefer() {
  local o="src/runtime/rt_arena_buf.o"
  local seed="seeds/rt_arena_buf.from_x.c"
  local xsrc="src/runtime/rt_arena_buf.x"
  local thin rest merged ld_flags bare_thin bare_rest bare_merged

  if [ ! -f "$seed" ] || [ ! -f "$xsrc" ]; then
    echo "ensure_host_cc_seed_o try-rt-arena-buf-prefer: missing $seed or $xsrc" >&2
    return 1
  fi

  # Up-to-date: seed, the .x, and project headers. A full-cc .o that predates
  # the deleted C bodies still rebuilds once either input moves.
  if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ ! "$seed" -nt "$o" ]; then
    if [ ! "$xsrc" -nt "$o" ] && ! seed_project_hdrs_newer "$seed" "$o"; then
      log "skip up-to-date $o (rt-arena-buf)"
      return 0
    fi
  fi

  bare_thin="$(mktemp "${TMPDIR:-/tmp}/rtarena_thin.XXXXXX")" || true
  bare_rest="$(mktemp "${TMPDIR:-/tmp}/rtarena_rest.XXXXXX")" || true
  bare_merged="$(mktemp "${TMPDIR:-/tmp}/rtarena_merged.XXXXXX")" || true
  if [ -z "$bare_thin" ] || [ -z "$bare_rest" ] || [ -z "$bare_merged" ]; then
    echo "ensure: rt-arena-buf mktemp failed" >&2
    rm -f "$bare_thin" "$bare_rest" "$bare_merged"
    return 1
  fi
  rm -f "$bare_thin" "$bare_rest" "$bare_merged"
  thin="${bare_thin}.o"
  rest="${bare_rest}.o"
  merged="${bare_merged}.o"
  # pure_asm only. Do not fall through to gcc -E of this TU.
  # PLATFORM: SHARED — rt_prefer scopes PREFER_ASM_O inside the subshell.
  # The marker is in the .x. The seed cc emits BSS only.
  if (
    if [ "${XLANG_PREFER_ASM_O_RT:-1}" = "1" ]; then
      export XLANG_PREFER_ASM_O=1
    elif [ "${XLANG_ALLOW_TREE_PREFER_ASM:-0}" != "1" ]; then
      unset XLANG_PREFER_ASM_O
    fi
    unset G05_X_O_WEAK G05_X_O_WEAK_FUNCS
    pure_asm_x_to_o "$thin" "$xsrc"
  ) && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c "$seed" -o "$rest" \
    && ld_flags="$(r3_prefer_ld_r_flags)" \
    && ld $ld_flags -o "$merged" "$thin" "$rest" \
    && r3_prefer_nm_has_sym "$merged" "driver_arena_buf" \
    && r3_prefer_nm_has_sym "$merged" "driver_module_buf" \
    && r3_prefer_nm_has_sym "$merged" "labi_rt_arena_buf_slice_marker" \
    && r3_prefer_nm_has_sym "$merged" "driver_arena_static" \
    && r3_prefer_nm_has_sym "$merged" "driver_module_static"; then
    mv -f "$merged" "$o"
    log "rt-arena-buf $o <- pure-asm $xsrc + BSS rest (w858; marker is in the .x)"
    rm -f "$thin" "$rest"
    return 0
  fi
  echo "ensure: rt-arena-buf pure-asm failed; marker and buffers are in the .x, no seed fallback" >&2
  rm -f "$thin" "$rest" "$merged"
  return 1
}

# Product install of src/runtime/rt_parse_diag.o:
#   pure-asm src/runtime/rt_parse_diag.x (precise diagnostic + slice marker)
#   + seeds/rt_parse_diag.from_x.c (recovery diagnostics)
# runtime_report_precise_parse_failure_if_known was deleted from the seed
# in w846, including the PRECISE_BRIDGE wrapper.
# labi_rt_parse_diag_slice_marker moved into the .x in w860 (still returns 1).
# There is no full-seed fallback and no Windows special case: a seed-only cc
# does not define the precise diagnostic or the marker. XLANG_G05_PREFER_X_O
# is ignored. Do not gcc -E this TU.
# Do not pass -DXLANG_RT_PARSE_DIAG_PRECISE_BRIDGE.
# Do not rebuild runtime_driver_no_c.o from this path.
# Failure leaves the previous .o in place and returns 1.
# PLATFORM: SHARED — POSIX and Windows both take this path.
# G.7: one body; g05 rt-slice, build_xlang_asm, strict glue, and the
# experimental bootstrap call this. The older try-rt-prefer temp must not
# replace this .o. Its -DXLANG_RT_PARSE_DIAG_FROM_X /
# PRECISE_BRIDGE flags are no-ops and that temp is not merged into no_c.
ensure_rt_parse_diag_prefer() {
  local o="src/runtime/rt_parse_diag.o"
  local seed="seeds/rt_parse_diag.from_x.c"
  local xsrc="src/runtime/rt_parse_diag.x"
  local thin rest merged ld_flags bare_thin bare_rest bare_merged

  if [ ! -f "$seed" ] || [ ! -f "$xsrc" ]; then
    echo "ensure_host_cc_seed_o try-rt-parse-diag-prefer: missing $seed or $xsrc" >&2
    return 1
  fi

  # Up-to-date: seed, the .x, and project headers. A full-cc .o that predates
  # the deleted C body still rebuilds once either input moves.
  if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ ! "$seed" -nt "$o" ]; then
    if [ ! "$xsrc" -nt "$o" ] && ! seed_project_hdrs_newer "$seed" "$o"; then
      log "skip up-to-date $o (rt-parse-diag)"
      return 0
    fi
  fi

  bare_thin="$(mktemp "${TMPDIR:-/tmp}/rtpdiag_thin.XXXXXX")" || true
  bare_rest="$(mktemp "${TMPDIR:-/tmp}/rtpdiag_rest.XXXXXX")" || true
  bare_merged="$(mktemp "${TMPDIR:-/tmp}/rtpdiag_merged.XXXXXX")" || true
  if [ -z "$bare_thin" ] || [ -z "$bare_rest" ] || [ -z "$bare_merged" ]; then
    echo "ensure: rt-parse-diag mktemp failed" >&2
    rm -f "$bare_thin" "$bare_rest" "$bare_merged"
    return 1
  fi
  rm -f "$bare_thin" "$bare_rest" "$bare_merged"
  thin="${bare_thin}.o"
  rest="${bare_rest}.o"
  merged="${bare_merged}.o"
  # pure_asm only. Do not fall through to gcc -E of this TU.
  # PLATFORM: SHARED — rt_prefer scopes PREFER_ASM_O inside the subshell.
  # The marker is in the .x. The seed cc emits recovery diagnostics.
  # Default unwind: the live object has __compact_unwind. Do not pass
  # -fno-unwind-tables.
  if (
    if [ "${XLANG_PREFER_ASM_O_RT:-1}" = "1" ]; then
      export XLANG_PREFER_ASM_O=1
    elif [ "${XLANG_ALLOW_TREE_PREFER_ASM:-0}" != "1" ]; then
      unset XLANG_PREFER_ASM_O
    fi
    unset G05_X_O_WEAK G05_X_O_WEAK_FUNCS
    pure_asm_x_to_o "$thin" "$xsrc"
  ) && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c "$seed" -o "$rest" \
    && ld_flags="$(r3_prefer_ld_r_flags)" \
    && ld $ld_flags -o "$merged" "$thin" "$rest" \
    && r3_prefer_nm_has_sym "$merged" "runtime_report_precise_parse_failure_if_known" \
    && r3_prefer_nm_has_sym "$merged" "labi_rt_parse_diag_slice_marker" \
    && r3_prefer_nm_has_sym "$merged" "runtime_report_parse_recovery_diagnostics"; then
    mv -f "$merged" "$o"
    log "rt-parse-diag $o <- pure-asm $xsrc + recovery rest (w860; marker is in the .x)"
    rm -f "$thin" "$rest"
    return 0
  fi
  echo "ensure: rt-parse-diag pure-asm failed; marker and precise diagnostic are in the .x, no seed fallback" >&2
  rm -f "$thin" "$rest" "$merged"
  return 1
}

# Product install of src/runtime/rt_preamble.o:
#   pure-asm src/runtime/rt_preamble.x (two writers + slice marker)
#   + seeds/rt_preamble.from_x.c (string tables only)
# w843 deleted the C writers. w861 deleted the C marker. There is no
# full-seed fallback and no Windows special case: a seed-only cc does not
# define write_io_net_abi_inline, write_fs_path_map_error_abi_inline, or
# labi_rt_preamble_slice_marker. XLANG_G05_PREFER_X_O is ignored.
# Do not gcc -E this TU. Default unwind: do not pass -fno-unwind-tables.
# PLATFORM: SHARED — POSIX and Windows both take this path.
# G.7: one body; g05 rt-slice, build_xlang_asm, strict glue, and the
# experimental bootstrap call this. The older try-rt-prefer temp must not
# replace this .o.
ensure_rt_preamble_prefer() {
  local o="src/runtime/rt_preamble.o"
  local seed="seeds/rt_preamble.from_x.c"
  local xsrc="src/runtime/rt_preamble.x"
  local thin rest merged ld_flags bare_thin bare_rest bare_merged

  if [ ! -f "$seed" ] || [ ! -f "$xsrc" ]; then
    echo "ensure_host_cc_seed_o try-rt-preamble-prefer: missing $seed or $xsrc" >&2
    return 1
  fi

  # Up-to-date: seed, the .x, and project headers. A full-cc .o that predates
  # the deleted C writers still rebuilds once either input moves.
  if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ ! "$seed" -nt "$o" ]; then
    if [ ! "$xsrc" -nt "$o" ] && ! seed_project_hdrs_newer "$seed" "$o"; then
      log "skip up-to-date $o (rt-preamble)"
      return 0
    fi
  fi

  bare_thin="$(mktemp "${TMPDIR:-/tmp}/rtpre_thin.XXXXXX")" || true
  bare_rest="$(mktemp "${TMPDIR:-/tmp}/rtpre_rest.XXXXXX")" || true
  bare_merged="$(mktemp "${TMPDIR:-/tmp}/rtpre_merged.XXXXXX")" || true
  if [ -z "$bare_thin" ] || [ -z "$bare_rest" ] || [ -z "$bare_merged" ]; then
    echo "ensure: rt-preamble mktemp failed" >&2
    rm -f "$bare_thin" "$bare_rest" "$bare_merged"
    return 1
  fi
  rm -f "$bare_thin" "$bare_rest" "$bare_merged"
  thin="${bare_thin}.o"
  rest="${bare_rest}.o"
  merged="${bare_merged}.o"
  # pure_asm only. Do not fall through to gcc -E of this TU.
  # PLATFORM: SHARED — rt_prefer scopes PREFER_ASM_O inside the subshell.
  # The marker is in the .x. The seed cc emits the string tables.
  # Default unwind. Do not pass -fno-unwind-tables.
  if (
    if [ "${XLANG_PREFER_ASM_O_RT:-1}" = "1" ]; then
      export XLANG_PREFER_ASM_O=1
    elif [ "${XLANG_ALLOW_TREE_PREFER_ASM:-0}" != "1" ]; then
      unset XLANG_PREFER_ASM_O
    fi
    unset G05_X_O_WEAK G05_X_O_WEAK_FUNCS
    pure_asm_x_to_o "$thin" "$xsrc"
  ) && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c "$seed" -o "$rest" \
    && ld_flags="$(r3_prefer_ld_r_flags)" \
    && ld $ld_flags -o "$merged" "$thin" "$rest" \
    && r3_prefer_nm_has_sym "$merged" "write_io_net_abi_inline" \
    && r3_prefer_nm_has_sym "$merged" "write_fs_path_map_error_abi_inline" \
    && r3_prefer_nm_has_sym "$merged" "labi_rt_preamble_slice_marker" \
    && r3_prefer_nm_has_sym "$merged" "driver_preamble_io_net_lines" \
    && r3_prefer_nm_has_sym "$merged" "driver_preamble_io_net_lines_n" \
    && r3_prefer_nm_has_sym "$merged" "driver_preamble_fs_path_lines" \
    && r3_prefer_nm_has_sym "$merged" "driver_preamble_fs_path_lines_n"; then
    mv -f "$merged" "$o"
    log "rt-preamble $o <- pure-asm $xsrc + table rest (w861; marker is in the .x)"
    rm -f "$thin" "$rest"
    return 0
  fi
  echo "ensure: rt-preamble pure-asm failed; writers and marker are in the .x, no seed fallback" >&2
  rm -f "$thin" "$rest" "$merged"
  return 1
}

ensure_rt_slice() {
  local list o n=0
  list="$(catalog_key_words "RT_SEED_SLICE_OBJS")"
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    if [ "$o" = "src/runtime/rt_emit_state.o" ]; then
      ensure_rt_emit_state_prefer || exit 1
    elif [ "$o" = "src/runtime/rt_arena_buf.o" ]; then
      ensure_rt_arena_buf_prefer || exit 1
    elif [ "$o" = "src/runtime/rt_parse_diag.o" ]; then
      ensure_rt_parse_diag_prefer || exit 1
    elif [ "$o" = "src/runtime/rt_preamble.o" ]; then
      ensure_rt_preamble_prefer || exit 1
    else
      ensure_one "$o" "$(seed_for_o "$o")"
    fi
    n=$((n + 1))
  done
  log "rt-slice OK ($n objs via catalog RT_SEED_SLICE_OBJS)"
}

ensure_core_seed() {
  ensure_catalog_family "R1_CORE_SEED_OBJS" "core-seed" "basename"
}

ensure_frontend_glue() {
  ensure_catalog_family "R1_FRONTEND_GLUE_OBJS" "frontend-glue" "frontend-glue"
}

ensure_main_runtime() {
  ensure_catalog_family "R1_MAIN_RUNTIME_OBJS" "main-runtime" "main-runtime"
}

# Product install of x_frontend_link_alias.o:
#   pure-asm x_frontend_link_alias.x (18 aliases plus the w863
#   pipeline_type_kind_ord_at mangled face and the w864
#   glue_asm_build_func_export_sym_c mangled face, the w865
#   glue_asm_build_import_binding_call_sym mangled face, the w866
#   glue_try_std_heap_redirect_sym_local mangled face, the w867
#   glue_codegen_import_path_to_c_prefix_into mangled face, the w868
#   pipeline_expr_field_access_name_len mangled face, and the w869
#   pipeline_expr_field_access_base_ref mangled face; seven weakened)
#   + seeds/x_frontend_link_alias.from_x.c (lexer struct-return + XLANG_WEAK
#   cluster)
# w847 deleted the 18 C bodies and the XLANG_XFLA_ASM gate. w863 moved
# pipeline_type_kind_ord_at_u8_ptr_i32_reti32 into the .x; it stays strong.
# w864 moved glue_asm_build_func_export_sym_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_reti32
# into the .x; it stays strong.
# w865 moved glue_asm_build_import_binding_call_sym_u8_ptr_i32_u8_ptr_i32_u8_ptr_reti32
# into the .x; it stays strong.
# w866 moved glue_try_std_heap_redirect_sym_local_u8_ptr_i32_u8_ptr_i32_reti32
# into the .x; it stays strong.
# w867 moved glue_codegen_import_path_to_c_prefix_into_u8_ptr_u8_ptr_i32
# into the .x; it stays strong. The unsuffixed body returns void.
# w868 moved pipeline_expr_field_access_name_len_u8_ptr_i32_reti32
# into the .x; it stays weak. The unsuffixed body stays in the pipeline object.
# w869 moved pipeline_expr_field_access_base_ref_u8_ptr_i32_reti32
# into the .x; it stays weak. The unsuffixed body stays in the pipeline object.
# A seed-only cc does not define those symbols. There is no full-seed
# fallback and no Windows special case. XLANG_G05_PREFER_X_O is ignored.
# Do not gcc -E this TU. Do not rebuild runtime_driver_no_c.o from this path.
# PLATFORM: SHARED — POSIX and Windows both take this path.
# G.7: one body. try-r1 / try-heat, the alias-stubs family, and g05 call this.
ensure_x_frontend_link_alias_prefer() {
  local o="x_frontend_link_alias.o"
  local seed="seeds/x_frontend_link_alias.from_x.c"
  local xsrc="x_frontend_link_alias.x"
  local thin rest bare_thin bare_rest
  local weak_funcs="check_block_impl,check_expr_impl,find_or_alloc_ptr_type_ref,pipeline_typeck_set_active_ctx_c,pipeline_typeck_ptr_for_addr_of_operand_c,pipeline_expr_field_access_name_len_u8_ptr_i32_reti32,pipeline_expr_field_access_base_ref_u8_ptr_i32_reti32"

  if [ ! -f "$seed" ] || [ ! -f "$xsrc" ]; then
    echo "ensure_host_cc_seed_o try-xfla-prefer: missing $seed or $xsrc" >&2
    return 1
  fi

  # Up-to-date: seed, the .x, and project headers. A full-cc .o that predates
  # the deleted C bodies still rebuilds once either input moves.
  if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ ! "$seed" -nt "$o" ]; then
    if [ ! "$xsrc" -nt "$o" ] && ! seed_project_hdrs_newer "$seed" "$o"; then
      log "skip up-to-date $o (x-frontend-link-alias)"
      return 0
    fi
  fi

  bare_thin="$(mktemp "${TMPDIR:-/tmp}/xfla_thin.XXXXXX")" || true
  bare_rest="$(mktemp "${TMPDIR:-/tmp}/xfla_rest.XXXXXX")" || true
  if [ -z "$bare_thin" ] || [ -z "$bare_rest" ]; then
    echo "ensure: x-frontend-link-alias mktemp failed" >&2
    return 1
  fi
  rm -f "$bare_thin" "$bare_rest"
  thin="${bare_thin}.o"
  rest="${bare_rest}.o"
  # pure_asm only. Do not fall through to gcc -E of this TU.
  # PLATFORM: SHARED — PREFER_ASM_O is scoped to this subshell.
  if (
    export XLANG_PREFER_ASM_O=1
    export G05_X_O_WEAK_FUNCS="$weak_funcs"
    pure_asm_x_to_o "$thin" "$xsrc"
  ) && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c "$seed" -o "$rest" \
    && pure_ld_partial_merge "$o" "$thin" "$rest"; then
    log "x-frontend-link-alias $o <- pure-asm $xsrc + lexer/mangled rest (w869; type_kind_ord, func_export, import_binding, heap_redirect, import_path, field_name_len, and field_base_ref faces are in the .x; field_name_len and field_base_ref stay weak)"
    rm -f "$thin" "$rest"
    return 0
  fi
  echo "ensure: x-frontend-link-alias pure-asm failed; C bodies are gone, no seed fallback" >&2
  rm -f "$thin" "$rest" "$o"
  return 1
}

ensure_alias_stubs() {
  # Basename convention — same seed_mode as core-seed / rt-slice.
  # x_frontend_link_alias.o is intercepted inside ensure_catalog_family.
  ensure_catalog_family "R1_ALIAS_STUBS_OBJS" "alias-stubs" "basename"
}

ensure_extra_cflags() {
  # Multi-flag / multi-out pure host-cc (pipeline_abi, -fPIE, sqlite, parser link).
  ensure_catalog_family "R1_EXTRA_CFLAGS_OBJS" "extra-cflags" "extra-cflags"
}

ensure_misc_basename() {
  # Pure basename host-cc without special extras (glue / enc / ctx / pipeline_glue / …).
  ensure_catalog_family "R1_MISC_BASENAME_OBJS" "misc-basename" "basename"
}

ensure_seed_map() {
  # Basename-mismatch + orch -D pure host-cc (target_cpu / ast_seed / orch).
  ensure_catalog_family "R1_SEED_MAP_OBJS" "seed-map" "seed-map"
}

ensure_all_swallowed() {
  ensure_rt_slice
  ensure_core_seed
  ensure_frontend_glue
  ensure_main_runtime
  ensure_alias_stubs
  ensure_extra_cflags
  ensure_misc_basename
  ensure_seed_map
  log "all swallowed R1 families OK (rt-slice + core-seed + frontend-glue + main-runtime + alias-stubs + extra-cflags + misc-basename + seed-map)"
}

# ---------------------------------------------------------------------------
# wave756: try-r1 OUT — pure R1 body for R4 rebuild without hardcoding .o lists.
#
# Resolve OUT by *membership* in catalog KEY families (lists = mk only).
# Exit codes:
#   0 — OUT is pure R1; ensure_one ran (or skipped up-to-date)
#   3 — OUT not in any R1 catalog family (caller should use make residual)
#   1 — membership found but ensure failed / catalog error
# PLATFORM: SHARED — same host-cc body as family modes; no dual recipe.
# Catalog expansion: catalog_blob / catalog_key_list (above; shared file cache).
# ---------------------------------------------------------------------------
catalog_key_words() {
  # $1 = KEY — print space-separated words from cached catalog blob
  local key="$1"
  local line
  line="$(catalog_blob | sed -n "s|^${key}=||p" | head -1)"
  printf '%s\n' "$line"
}

list_has_word() {
  # $1=needle $2=space-separated list
  local needle="$1"
  local list="$2"
  local w
  # shellcheck disable=SC2086
  for w in $list; do
    [ "$w" = "$needle" ] && return 0
  done
  return 1
}

# Print seed_mode for OUT if member of any pure R1 family; else return 1.
# Order: specific maps first (seed-map / frontend-glue / main-runtime / extra-cflags),
# then basename families. KEY membership only — no second .o inventory.
r1_seed_mode_for_o() {
  local o="$1"
  local list
  list="$(catalog_key_words "R1_SEED_MAP_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "seed-map"
    return 0
  fi
  list="$(catalog_key_words "R1_FRONTEND_GLUE_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "frontend-glue"
    return 0
  fi
  list="$(catalog_key_words "R1_MAIN_RUNTIME_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "main-runtime"
    return 0
  fi
  list="$(catalog_key_words "R1_EXTRA_CFLAGS_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "extra-cflags"
    return 0
  fi
  list="$(catalog_key_words "RT_SEED_SLICE_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "basename"
    return 0
  fi
  list="$(catalog_key_words "R1_CORE_SEED_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "basename"
    return 0
  fi
  list="$(catalog_key_words "R1_ALIAS_STUBS_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "basename"
    return 0
  fi
  list="$(catalog_key_words "R1_MISC_BASENAME_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "basename"
    return 0
  fi
  return 1
}

try_ensure_r1_one() {
  local o="$1"
  local seed_mode seed extras_str
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-r1: need <out.o>" >&2
    exit 2
  fi
  # sat -B + XLANG_G05_PREFER_X_O=0 used to cold-cc the mega seed
  # (seeds/runtime_link_abi.from_x.c `#ifndef FROM_X`) and wipe prefer
  # labi_*.x slices. Route like pipeline_abi: single body
  # ensure_labi_prefer_one (FROM_X default 1 still hybrids). Do **not**
  # gate on G05_PREFER=1. G.7: no second labi builder.
  # PLATFORM: SHARED — sat try-r1 + g05 try-labi-prefer share one body.
  if [ "$o" = "src/runtime_link_abi.o" ]; then
    ensure_labi_prefer_one "$o" || return 1
    return 0
  fi
  # wave176 / L4: pipeline_abi always routes through ensure_pipeline_abi_prefer_one
  # (hybrid when egg exists; cold seed last resort). Do **not** gate on PREFER=1 —
  # sat rebuild sets PREFER=0 and would otherwise cold-cc the broken full seed and
  # wipe a good hybrid .o. G.7: single body wave767.
  # PLATFORM: SHARED · pin egg required for true-cold hybrid.
  if [ "$o" = "src/runtime_pipeline_abi.o" ]; then
    ensure_pipeline_abi_prefer_one "$o" || return 1
    return 0
  fi
  # w847/w863/w864/w865/w866/w867/w868/w869: alias bodies that live in the .x are not in the seed.
  # Seed-only cc drops them. Do not gate on XLANG_G05_PREFER_X_O.
  # PLATFORM: SHARED.
  if [ "$o" = "x_frontend_link_alias.o" ]; then
    ensure_x_frontend_link_alias_prefer || return 1
    return 0
  fi
  # wave321 7.1.1: runtime monofile retired — multi-slice product body only.
  if is_runtime_multi_slice_leaf "$o"; then
    ensure_runtime_multi_slice_leaf "$o" || return 1
    return 0
  fi
  if ! seed_mode="$(r1_seed_mode_for_o "$o")"; then
    # Not pure R1 — honest residual for R2/R3/gen/etc.
    return 3
  fi
  case "$seed_mode" in
    basename) seed="$(seed_for_o "$o")" ;;
    frontend-glue) seed="$(seed_for_frontend_glue "$o")" ;;
    main-runtime) seed="$(seed_for_main_runtime "$o")" ;;
    extra-cflags) seed="$(seed_for_extra_cflags "$o")" ;;
    seed-map) seed="$(seed_for_seed_map "$o")" ;;
    *)
      echo "ensure_host_cc_seed_o try-r1: unknown seed_mode $seed_mode for $o" >&2
      exit 1
      ;;
  esac
  extras_str=""
  case "$seed_mode" in
    main-runtime) extras_str="$(extras_for_main_runtime "$o")" ;;
    extra-cflags) extras_str="$(extras_for_extra_cflags "$o")" ;;
    seed-map) extras_str="$(extras_for_seed_map "$o")" ;;
  esac
  if [ -n "$extras_str" ]; then
    # shellcheck disable=SC2086
    ensure_one "$o" "$seed" $extras_str
  else
    ensure_one "$o" "$seed"
  fi
  return 0
}

# ---------------------------------------------------------------------------
# wave757: try-r3-cold OUT — R3 cold-else pure host-cc without dual .o lists.
#
# Membership = catalog R3_COLD_SEED_OBJS only (lists = mk).
# Seed = basename convention (seeds/<leaf>.from_x.c); same ensure_one as R1.
# Exit codes:
#   0 — OUT is R3 cold-seed member; ensure_one ran (or skipped up-to-date)
#   3 — OUT not in R3_COLD_SEED_OBJS (caller residual make)
#   1 — membership found but ensure failed / catalog error
# PLATFORM: SHARED — cold path body only; PREFER thin+rest remains Makefile.
# ---------------------------------------------------------------------------
try_ensure_r3_cold_one() {
  local o="$1"
  local list seed
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-r3-cold: need <out.o>" >&2
    exit 2
  fi
  list="$(catalog_key_words "R3_COLD_SEED_OBJS")"
  if ! list_has_word "$o" "$list"; then
    return 3
  fi
  # w849: arch emit has no cold C bodies. Same pure-asm path as prefer.
  if [ "$o" = "src/asm/backend_arch_emit_dispatch.o" ]; then
    ensure_arch_emit_dispatch_pure || return 1
    return 0
  fi
  # w853: diagnostic thin publics have no cold C bodies. Same pure-asm path.
  if [ "$o" = "src/runtime_driver_diagnostic.o" ]; then
    ensure_rdd_pure || return 1
    return 0
  fi
  # w862: enc thin publics and the slice marker have no product C bodies.
  if [ "$o" = "src/asm/backend_enc_dispatch.o" ]; then
    ensure_enc_dispatch_pure || return 1
    return 0
  fi
  seed="$(seed_for_o "$o")"
  ensure_one "$o" "$seed"
  return 0
}

ensure_r3_cold_seed() {
  ensure_catalog_family "R3_COLD_SEED_OBJS" "r3-cold-seed" "basename"
}

# ---------------------------------------------------------------------------
# wave763/764: try-r3-prefer OUT — R3 PREFER thin+rest product path (single body).
# Stage 12.0.5 pure-asm hybrid (opt-in PREFER_ASM_O; not product-default):
#   thin via rt_prefer_try_x_to_o → pure_asm_x_to_o first. Freestanding reject
#   covers U xlang_driver_*_opaque (rdabi fallthrough -E). ptr+int ADD uses
#   scale1 64-bit (glue_try_emit_ptr_arith_scaled) — closes pure-asm rio IO001.
#   Dual-end R3 hybrid 9/9 pure-ld + matrix 5/5 @ tip after fix.

#
# Membership = catalog R3_COLD_SEED_OBJS only (lists = mk; same KEY as cold).
# When XLANG_G05_PREFER_X_O=1 and ./xlang-c is executable:
#   wave764 ladder (per leaf map):
#     1) optional full.x + full rest -D (R2 full surface; simd/backend)
#     2) thin.x (or primary .x) + thin rest -D
#     3) ld -r prefer.o rest.o → OUT (Darwin arch + multidef; ELF/PE allow-multidef)
#     4) optional nm symbol gate (simd_enc / simd_loop) — fail → next ladder step
# Prefer fail / PREFER≠1 / no xlang-c → ensure_one cold seed (try-r3-cold twin).
# Callers: Makefile nine leaves (wave763) · g05 r3-prefer-family (wave764).
# Exit codes:
#   0 — OUT is R3_COLD member; prefer or cold body produced OUT
#   3 — OUT not in R3_COLD_SEED_OBJS
#   1 — membership found but both prefer and cold failed
# PLATFORM: SHARED shell body · Darwin ld -r arch/multidef · cold chain PREFER=0.
# G.7: no second .o list; per-leaf x/rest-defs/nm/full are seed-path conventions.
# ---------------------------------------------------------------------------

# R3 prefer leaf map — NOT an .o inventory (membership = catalog only).
# stdout fields (pipe-separated):
#   thin_x | thin_rest_defs | nm_sym | full_x_or_- | full_rest_defs_or_-
# rest_defs = comma-joined -D tokens without -D prefix.
# PLATFORM: SHARED — Makefile phase4 thin + former g05 full ladder (wave764).
r3_prefer_leaf_spec() {
  local o="$1"
  case "$o" in
    src/runtime_io_abi.o)
      # Primary surface is full .x (not *_thin.x); dual rest -D historical.
      printf '%s\n' "src/runtime_io_abi.x|XLANG_L2_RIO_THIN_FROM_X,XLANG_RUNTIME_IO_ABI_FROM_X|-|-|-"
      ;;
    src/runtime_driver_abi.o)
      printf '%s\n' "src/runtime_driver_abi_thin.x|XLANG_L2_RDABI_THIN_FROM_X|-|-|-"
      ;;
    src/runtime_driver_diagnostic.o)
      # w853: ensure_r3_prefer_one does not use this spec. Thin publics are
      # pure-asm of runtime_driver_diagnostic_thin.x. The seed is the asm BSS
      # tail only. Kept so the leaf map still names the .x.
      printf '%s\n' "src/runtime_driver_diagnostic_thin.x|XLANG_L2_RDD_THIN_FROM_X|-|-|-"
      ;;
    src/asm/simd_enc.o)
      # wave764: full.x first (R2 H=0), then thin L2; nm gate on both.
      printf '%s\n' "src/asm/simd_enc_thin.x|XLANG_L2_SIMD_ENC_THIN_FROM_X|simd_rbp_disp32|src/asm/simd_enc.x|XLANG_SIMD_ENC_FROM_X"
      ;;
    src/asm/simd_loop.o)
      printf '%s\n' "src/asm/simd_loop_thin.x|XLANG_L2_SIMD_LOOP_THIN_FROM_X|glue_simd_loop_pick_lanes_c|src/asm/simd_loop.x|XLANG_SIMD_LOOP_FROM_X"
      ;;
    src/asm/backend_enc_dispatch.o)
      # w862: ensure_r3_prefer_one does not use this spec. Thin publics and
      # the slice marker are pure-asm of backend_enc_dispatch_thin.x.
      # The seed is the f64/Cap tail. The marker returns 1.
      # Do not switch the product to the full .x.
      printf '%s\n' "src/asm/backend_enc_dispatch_thin.x|XLANG_L2_ENC_DISPATCH_THIN_FROM_X|backend_enc_addsd_rax_rbx_arch|src/asm/backend_enc_dispatch.x|XLANG_BACKEND_ENC_DISPATCH_FROM_X"
      ;;
    src/asm/backend_arch_emit_dispatch.o)
      # w849: ensure_r3_prefer_one does not use this spec for the product
      # object. The 47 shells are pure-asm of the full .x. The thin .c is
      # deleted. Kept so the leaf map still names the .x.
      printf '%s\n' "src/asm/backend_arch_emit_dispatch_thin.x|XLANG_L2_ARCH_EMIT_THIN_FROM_X|-|src/asm/backend_arch_emit_dispatch.x|XLANG_BACKEND_ARCH_EMIT_DISPATCH_FROM_X"
      ;;
    src/asm/backend_try_inline_dispatch.o)
      printf '%s\n' "src/asm/backend_try_inline_dispatch_thin.x|XLANG_L2_TRY_INLINE_THIN_FROM_X|-|src/asm/backend_try_inline_dispatch.x|XLANG_BACKEND_TRY_INLINE_DISPATCH_FROM_X"
      ;;
    src/asm/backend_call_dispatch.o)
      printf '%s\n' "src/asm/backend_call_dispatch_thin.x|XLANG_L2_CALL_DISPATCH_THIN_FROM_X|-|src/asm/backend_call_dispatch.x|XLANG_BACKEND_CALL_DISPATCH_FROM_X"
      ;;
    *)
      return 1
      ;;
  esac
}

r3_prefer_ld_r_flags() {
  # stdout: ld args for partial link (no -o / inputs). PLATFORM: SHARED.
  local uname_s uname_m
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  if [ "$uname_s" = "Darwin" ]; then
    case "$uname_m" in
      arm64|aarch64) printf '%s\n' "-arch arm64 -r -multiply_defined suppress" ;;
      x86_64|amd64)  printf '%s\n' "-arch x86_64 -r -multiply_defined suppress" ;;
      *)             printf '%s\n' "-r -multiply_defined suppress" ;;
    esac
  else
    # PLATFORM: LINUX|WINDOWS (ELF/PE) — GNU ld multidef for thin+rest merge.
    printf '%s\n' "-r --allow-multiple-definition"
  fi
}

r3_prefer_nm_has_sym() {
  # $1=out.o $2=symbol (unadorned). Accepts Darwin leading underscore.
  local o="$1" sym="$2"
  [ -z "$sym" ] || [ "$sym" = "-" ] && return 0
  nm -gU "$o" 2>/dev/null | awk -v s="$sym" '
    $0 ~ (" " s "$") || $0 ~ (" _" s "$") { found=1 }
    END { exit !found }
  '
}

# Try one prefer step: thin.x → .o (rt_prefer prologue) + seed rest -D → ld -r OUT.
# $1=out.o $2=x_src $3=rest_csv $4=nm_sym $5=seed $6=xlang_bin
# Returns 0 on success (OUT written + nm ok).
#
# G.7 / wave190: thin compile MUST reuse rt_prefer_try_x_to_o (single -E prologue
# authority). Bare `xlang -E | cc` left U xlang_driver_* on pure
# runtime_driver_abi_thin (stdout_ptr / fputs_opaque / … are static inline only
# inside that harness). PLATFORM: SHARED.
r3_prefer_try_step() {
  local o="$1" x_src="$2" rest_csv="$3" nm_sym="$4" seed="$5" xlang_bin="$6"
  local thin_o rest_o ld_flags d_args=() d
  local label="${x_src##*/}"

  [ -n "$x_src" ] && [ "$x_src" != "-" ] && [ -f "$x_src" ] || return 1
  [ -f "$seed" ] || return 1
  [ -x "$xlang_bin" ] || return 1

  thin_o="${o%.o}_prefer_step.o"
  rest_o="${o%.o}_prefer_rest.o"
  mkdir -p "$(dirname "$o")"
  # Thin surface: same prologue as try-pipeline-abi / g05 (xlang_driver_* inlines).
  if ! rt_prefer_try_x_to_o "$x_src" "$thin_o"; then
    rm -f "$thin_o" "$rest_o"
    return 1
  fi
  d_args=()
  if [ -n "$rest_csv" ] && [ "$rest_csv" != "-" ]; then
    IFS=',' read -r -a _defs <<< "$rest_csv"
    for d in "${_defs[@]}"; do
      [ -n "$d" ] && d_args+=("-D$d")
    done
  fi
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
    "${d_args[@]}" -c "$seed" -o "$rest_o" 2>/dev/null; then
    rm -f "$thin_o" "$rest_o"
    return 1
  fi
  ld_flags="$(r3_prefer_ld_r_flags)"
  # shellcheck disable=SC2086
  if ld $ld_flags -o "$o" "$thin_o" "$rest_o" 2>/dev/null \
    && r3_prefer_nm_has_sym "$o" "$nm_sym"; then
    log "prefer thin+rest $o <- $x_src + $seed ($label; try-r3-prefer)"
    rm -f "$thin_o" "$rest_o"
    return 0
  fi
  rm -f "$thin_o" "$rest_o"
  return 1
}

# w857: 47 ta-dispatch shells, the doc anchor, and the slice marker live
# only in backend_arch_emit_dispatch.x. The C seed is deleted. Product
# object is pure_asm_x_to_o of that file. No host cc, no gcc -E, no ld -r.
# nm gates: backend_arch_emit_ret_imm32, the slice marker, the doc anchor.
# G05_X_O_WEAK is cleared so those symbols stay strong.
# XLANG_G05_PREFER_X_O is ignored. Failure leaves the previous .o.
# PLATFORM: SHARED.
ensure_arch_emit_dispatch_pure() {
  local o="src/asm/backend_arch_emit_dispatch.o"
  local x_src="src/asm/backend_arch_emit_dispatch.x"
  local thin_tmp thin_o
  local stale=0

  if [ ! -f "$x_src" ]; then
    echo "ensure: arch emit missing $x_src; no C fallback" >&2
    return 1
  fi
  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    [ "$x_src" -nt "$o" ] && stale=1
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (arch-emit pure-asm w857)"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$o")"
  thin_tmp="$(mktemp "${TMPDIR:-/tmp}/arch_emit_x.XXXXXX")"
  thin_o="${thin_tmp}.o"
  mv "$thin_tmp" "$thin_o"

  if ! (
    export XLANG_PREFER_ASM_O=1
    unset G05_X_O_WEAK G05_X_O_WEAK_FUNCS
    pure_asm_x_to_o "$thin_o" "$x_src"
  ); then
    echo "ensure: arch emit pure-asm failed; no C fallback" >&2
    rm -f "$thin_o"
    return 1
  fi
  if ! r3_prefer_nm_has_sym "$thin_o" "backend_arch_emit_ret_imm32" \
    || ! r3_prefer_nm_has_sym "$thin_o" "backend_arch_emit_dispatch_slice_marker" \
    || ! r3_prefer_nm_has_sym "$thin_o" "backend_arch_emit_dispatch_x_doc_anchor"; then
    echo "ensure: arch emit nm gate failed; no C fallback" >&2
    rm -f "$thin_o"
    return 1
  fi
  mv -f "$thin_o" "$o"
  log "prefer pure-asm $o <- $x_src (w857; marker is in the .x, no host cc)"
  return 0
}

# w853: thin public bodies live only in runtime_driver_diagnostic_thin.x.
# Product object is pure_asm_x_to_o of that thin plus cc of the asm BSS tail
# with -DXLANG_L2_RDD_THIN_FROM_X. No gcc -E. No cold full-seed cc.
# XLANG_G05_PREFER_X_O is ignored. Windows takes the same path.
# Keep default unwind tables: the linked object carries __compact_unwind.
# Failure leaves the previous .o in place and returns 1.
# PLATFORM: SHARED.
ensure_rdd_pure() {
  local o="src/runtime_driver_diagnostic.o"
  local x_src="src/runtime_driver_diagnostic_thin.x"
  local seed="seeds/runtime_driver_diagnostic.from_x.c"
  local thin_tmp thin_o rest_tmp rest_o merged_tmp merged_o ld_flags asm_bin
  local stale=0

  if [ ! -f "$x_src" ] || [ ! -f "$seed" ]; then
    echo "ensure: diagnostic missing $x_src or $seed; C bodies are gone, no fallback" >&2
    return 1
  fi
  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    [ "$seed" -nt "$o" ] && stale=1
    [ "$x_src" -nt "$o" ] && stale=1
    if [ "$stale" = "0" ] && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (diagnostic pure-asm w853)"
      return 0
    fi
  fi

  if [ -x ./xlang_asm ]; then
    asm_bin=./xlang_asm
  elif [ -x ./xlang ]; then
    asm_bin=./xlang
  elif [ -x ./xlang-c ]; then
    asm_bin=./xlang-c
  else
    echo "ensure: diagnostic pure-asm has no compiler; C bodies are gone, no fallback" >&2
    return 1
  fi

  mkdir -p "$(dirname "$o")"
  thin_tmp="$(mktemp "${TMPDIR:-/tmp}/rdd_x.XXXXXX")"
  thin_o="${thin_tmp}.o"
  mv "$thin_tmp" "$thin_o"
  rest_tmp="$(mktemp "${TMPDIR:-/tmp}/rdd_tail.XXXXXX")"
  rest_o="${rest_tmp}.o"
  mv "$rest_tmp" "$rest_o"
  merged_tmp="$(mktemp "${TMPDIR:-/tmp}/rdd_merged.XXXXXX")"
  merged_o="${merged_tmp}.o"
  mv "$merged_tmp" "$merged_o"

  if ! (
    export XLANG="$asm_bin"
    export XLANG_PREFER_ASM_O=1
    unset G05_X_O_WEAK
    unset G05_X_O_WEAK_FUNCS
    pure_asm_x_to_o "$thin_o" "$x_src"
  ); then
    echo "ensure: diagnostic pure-asm failed; C bodies are gone, no fallback" >&2
    rm -f "$thin_o" "$rest_o" "$merged_o"
    return 1
  fi
  # Tail cc matches the linked object, including __compact_unwind.
  # Do not pass -fno-unwind-tables. PLATFORM: SHARED.
  # shellcheck disable=SC2086
  if ! ${CC:-cc} $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
      -DXLANG_L2_RDD_THIN_FROM_X -c -o "$rest_o" "$seed"; then
    echo "ensure: diagnostic tail cc failed; C bodies are gone, no fallback" >&2
    rm -f "$thin_o" "$rest_o" "$merged_o"
    return 1
  fi
  ld_flags="$(r3_prefer_ld_r_flags)"
  # shellcheck disable=SC2086
  if ! ld $ld_flags -o "$merged_o" "$thin_o" "$rest_o" \
    || ! r3_prefer_nm_has_sym "$merged_o" "driver_diagnostic_parse_fail" \
    || ! r3_prefer_nm_has_sym "$merged_o" "driver_diagnostic_asm_fail_at"; then
    echo "ensure: diagnostic merge failed; C bodies are gone, no fallback" >&2
    rm -f "$thin_o" "$rest_o" "$merged_o"
    return 1
  fi
  mv -f "$merged_o" "$o"
  rm -f "$thin_o" "$rest_o"
  log "runtime_driver_diagnostic.o from $x_src (pure-asm) + asm BSS tail [w853]"
  return 0
}

# w854: thin enc publics live only in backend_enc_dispatch_thin.x.
# w862: backend_enc_dispatch_slice_marker lives in that .x too and returns 1.
# Product object is pure_asm_x_to_o of that thin plus cc of the f64/Cap tail
# with -DXLANG_L2_ENC_DISPATCH_THIN_FROM_X. No gcc -E. No cold full-seed cc.
# No full.x attempt. XLANG_G05_PREFER_X_O is ignored. Windows takes the same
# path. Keep default unwind tables: the linked object carries __compact_unwind.
# nm gates: backend_enc_addsd_rax_rbx_arch (tail), backend_enc_append_u32_le_c
# (thin), and backend_enc_dispatch_slice_marker (thin).
# Failure leaves the previous .o in place and returns 1.
# PLATFORM: SHARED.
ensure_enc_dispatch_pure() {
  local o="src/asm/backend_enc_dispatch.o"
  local x_src="src/asm/backend_enc_dispatch_thin.x"
  local seed="seeds/backend_enc_dispatch.from_x.c"
  local thin_tmp thin_o rest_tmp rest_o merged_tmp merged_o ld_flags asm_bin
  local stale=0

  if [ ! -f "$x_src" ] || [ ! -f "$seed" ]; then
    echo "ensure: enc dispatch missing $x_src or $seed; C bodies are gone, no fallback" >&2
    return 1
  fi
  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    [ "$seed" -nt "$o" ] && stale=1
    [ "$x_src" -nt "$o" ] && stale=1
    if [ "$stale" = "0" ] && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (enc dispatch pure-asm w862)"
      return 0
    fi
  fi

  if [ -x ./xlang_asm ]; then
    asm_bin=./xlang_asm
  elif [ -x ./xlang ]; then
    asm_bin=./xlang
  elif [ -x ./xlang-c ]; then
    asm_bin=./xlang-c
  else
    echo "ensure: enc dispatch pure-asm has no compiler; C bodies are gone, no fallback" >&2
    return 1
  fi

  mkdir -p "$(dirname "$o")"
  thin_tmp="$(mktemp "${TMPDIR:-/tmp}/enc_x.XXXXXX")"
  thin_o="${thin_tmp}.o"
  mv "$thin_tmp" "$thin_o"
  rest_tmp="$(mktemp "${TMPDIR:-/tmp}/enc_tail.XXXXXX")"
  rest_o="${rest_tmp}.o"
  mv "$rest_tmp" "$rest_o"
  merged_tmp="$(mktemp "${TMPDIR:-/tmp}/enc_merged.XXXXXX")"
  merged_o="${merged_tmp}.o"
  mv "$merged_tmp" "$merged_o"

  if ! (
    export XLANG="$asm_bin"
    export XLANG_PREFER_ASM_O=1
    unset G05_X_O_WEAK
    unset G05_X_O_WEAK_FUNCS
    pure_asm_x_to_o "$thin_o" "$x_src"
  ); then
    echo "ensure: enc dispatch pure-asm failed; C bodies are gone, no fallback" >&2
    rm -f "$thin_o" "$rest_o" "$merged_o"
    return 1
  fi
  # Tail cc matches the linked object, including __compact_unwind.
  # Do not pass -fno-unwind-tables. Do not pass -no_compact_unwind.
  # PLATFORM: SHARED.
  # shellcheck disable=SC2086
  if ! ${CC:-cc} $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
      -DXLANG_L2_ENC_DISPATCH_THIN_FROM_X -c -o "$rest_o" "$seed"; then
    echo "ensure: enc dispatch tail cc failed; C bodies are gone, no fallback" >&2
    rm -f "$thin_o" "$rest_o" "$merged_o"
    return 1
  fi
  ld_flags="$(r3_prefer_ld_r_flags)"
  # shellcheck disable=SC2086
  if ! ld $ld_flags -o "$merged_o" "$thin_o" "$rest_o" \
    || ! r3_prefer_nm_has_sym "$merged_o" "backend_enc_addsd_rax_rbx_arch" \
    || ! r3_prefer_nm_has_sym "$merged_o" "backend_enc_append_u32_le_c" \
    || ! r3_prefer_nm_has_sym "$merged_o" "backend_enc_dispatch_slice_marker"; then
    echo "ensure: enc dispatch merge failed; C bodies are gone, no fallback" >&2
    rm -f "$thin_o" "$rest_o" "$merged_o"
    return 1
  fi
  mv -f "$merged_o" "$o"
  rm -f "$thin_o" "$rest_o"
  log "backend_enc_dispatch.o from $x_src (pure-asm) + f64/Cap tail [w862; marker is in the .x]"
  return 0
}

ensure_r3_prefer_one() {
  # Prefer ladder (full→thin) or cold seed for one R3_COLD member (no membership check).
  local o="$1"
  local spec x_src rest_csv nm_sym full_x full_rest seed
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local xlang_bin="./xlang-c"
  local ok=0
  local stale=0

  # w849: do not gcc -E this TU and do not cold-cc the marker alone.
  if [ "$o" = "src/asm/backend_arch_emit_dispatch.o" ]; then
    ensure_arch_emit_dispatch_pure || return 1
    return 0
  fi
  # w853: do not gcc -E this TU and do not cold-cc the tail alone.
  if [ "$o" = "src/runtime_driver_diagnostic.o" ]; then
    ensure_rdd_pure || return 1
    return 0
  fi
  # w862: do not gcc -E this TU, do not try the full .x, and do not cold-cc
  # the f64/Cap tail alone. The slice marker is in the thin .x.
  if [ "$o" = "src/asm/backend_enc_dispatch.o" ]; then
    ensure_enc_dispatch_pure || return 1
    return 0
  fi

  seed="$(seed_for_o "$o")"
  if ! spec="$(r3_prefer_leaf_spec "$o")"; then
    echo "ensure_host_cc_seed_o try-r3-prefer: no leaf spec for $o" >&2
    return 1
  fi
  x_src="$(printf '%s' "$spec" | cut -d'|' -f1)"
  rest_csv="$(printf '%s' "$spec" | cut -d'|' -f2)"
  nm_sym="$(printf '%s' "$spec" | cut -d'|' -f3)"
  full_x="$(printf '%s' "$spec" | cut -d'|' -f4)"
  full_rest="$(printf '%s' "$spec" | cut -d'|' -f5)"
  [ -z "$full_x" ] && full_x="-"
  [ -z "$full_rest" ] && full_rest="-"

  # Up-to-date skip (make / g05 already gated; shell direct calls benefit).
  # wave764: also consider full.x mtime when present.
  if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ -f "$seed" ]; then
    stale=0
    [ "$seed" -nt "$o" ] && stale=1
    if [ -f "$x_src" ] && [ "$x_src" -nt "$o" ]; then
      stale=1
    fi
    if [ -n "$full_x" ] && [ "$full_x" != "-" ] && [ -f "$full_x" ] && [ "$full_x" -nt "$o" ]; then
      stale=1
    fi
    # wave793: project-header mtime (FORCE thin; G.7 single body).
    if [ "$stale" = "0" ] && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    # wave794: Makefile flag-sensitive FORCE thin (main/runtime/pipeline_abi).
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (r3-prefer)"
      return 0
    fi
  fi

  # PLATFORM: SHARED cold-chain — only PREFER=1 may thin (Darwin history: thin
  # with PREFER=0 left UNDEFs in phase1). wave763 unified PREFER=1 for all nine;
  # wave764 full→thin ladder for g05 R2 full surface (simd/backend).
  if [ "$prefer" = "1" ] && [ -x "$xlang_bin" ] && [ -f "$seed" ]; then
    # 1) optional full.x first
    if [ -n "$full_x" ] && [ "$full_x" != "-" ] && [ -f "$full_x" ]; then
      if r3_prefer_try_step "$o" "$full_x" "$full_rest" "$nm_sym" "$seed" "$xlang_bin"; then
        ok=1
      fi
    fi
    # 2) thin / primary .x
    if [ "$ok" != "1" ] && [ -f "$x_src" ]; then
      if r3_prefer_try_step "$o" "$x_src" "$rest_csv" "$nm_sym" "$seed" "$xlang_bin"; then
        ok=1
      fi
    fi
  fi

  if [ "$ok" = "1" ]; then
    return 0
  fi

  # Cold fallback — same ensure_one as try-r3-cold.
  # Force when prefer path may have left a partial/bad OUT (e.g. nm gate fail).
  if [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o try-r3-prefer: missing seed $seed for $o" >&2
    return 1
  fi
  if [ -f "$o" ] && [ "$prefer" = "1" ]; then
    # Prefer attempted: never keep a thin that failed nm / ld semantics.
    FORCE=1
    ensure_one "$o" "$seed"
    FORCE=0
  else
    ensure_one "$o" "$seed"
  fi
  return 0
}

try_ensure_r3_prefer_one() {
  local o="$1"
  local list
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-r3-prefer: need <out.o>" >&2
    exit 2
  fi
  list="$(catalog_key_words "R3_COLD_SEED_OBJS")"
  if ! list_has_word "$o" "$list"; then
    return 3
  fi
  ensure_r3_prefer_one "$o"
  return 0
}

ensure_r3_prefer() {
  # Family mode: all R3_COLD members via prefer-or-cold body.
  local list o
  list="$(catalog_key_words "R3_COLD_SEED_OBJS")"
  if [ -z "$list" ]; then
    echo "ensure_host_cc_seed_o r3-prefer: empty R3_COLD_SEED_OBJS" >&2
    exit 1
  fi
  for o in $list; do
    ensure_r3_prefer_one "$o" || return 1
  done
}


# ---------------------------------------------------------------------------
# wave765: try-labi-prefer OUT — g05 labi multi-slice product PREFER (single body).
# wave760 Class K: labi_host_lit.x owns xlang_host_is_*_impl (#[cfg] two-level);
#   FROM_X rest skips Cap #if impls — cuts host-cc of those two bodies.
# wave761 Class L: same L2 slice owns link_abi_host_is_{apple,windows,
#   linux_x86_64,posix_aarch64}; FROM_X rest skips four more Cap #if gates.
# wave762 Class M: same L2 slice owns bootstrap_nostdlib_pthread_is_stub;
#   FROM_X rest skips that Cap #if WEAK. compile_sync argv uses runtime
#   host gates (spawn still Cap #if — _spawnvp is Windows-only).
#
# Single leaf: src/runtime_link_abi.o (in R1_CORE_SEED_OBJS; cold twin = ensure_one).
# When XLANG_G05_PREFER_X_O=1 and an xlang binary works:
#   L0..L9 + L8b(+L8c capacity split) prefer .x → .o (else cold layer seed)
#   rest = seeds/runtime_link_abi.from_x.c with XLANG_LABI_*_FROM_X for ok layers
#   merge: $CC -r -nostdlib slices + rest → OUT
# Prefer fail / PREFER≠1 / no xlang → ensure_one cold full seed (same as core-seed).
# Callers: g05_ensure (wave765) · Makefile src/runtime_link_abi.o (unified)
#   · sat try-r1 (same body; no mega `#ifndef` wipe).
# Exit codes:
#   0 — OUT is runtime_link_abi.o; prefer or cold body produced OUT
#   3 — OUT is not src/runtime_link_abi.o
#   1 — membership found but cold seed missing / compile failed
# PLATFORM: SHARED shell body · g05 historic PREFER=1 · cold chain PREFER=0.
# G.7: no second .o list; layer table is seed-path convention (not product inventory).
# Residual after: rt multi-slice · pipeline_abi · ldpc · target_cpu · pure-ld · physical delete.
# ---------------------------------------------------------------------------

# True when this host's product -E binary is a leftover Windows PE that cannot
# compile tip .x sources (e.g. pipeline_abi mega 92k LOC or labi multi-slice).
# PLATFORM: WINDOWS — 2026-07-31 leftover PE is present for Track L / can_run
# egg pick, but attempting -E with it hangs or corrupts stdout.
windows_leftover_pe_cannot_e() {
  case "$(uname -s 2>/dev/null)" in
    Windows_NT*|MINGW*|MSYS*|CYGWIN*) return 0 ;;
  esac
  return 1
}


# stdout: -include win32_compat.h on Windows hosts (setenv/mmap shims).
# PLATFORM: WINDOWS — empty on POSIX. Use on cold seed cc that call setenv etc.
host_cc_win_compat_cflags() {
  case "$(uname -s 2>/dev/null)" in
    Windows_NT*|MINGW*|MSYS*|CYGWIN*) printf '%s' '-include win32_compat.h' ;;
  esac
}


labi_prefer_pick_xlang() {
  # PLATFORM: WINDOWS — leftover PE cannot -E tip slices; fallback to cold seed.
  if windows_leftover_pe_cannot_e; then
    return 1
  fi
  # stdout: first executable product binary.
  local b
  for b in ./xlang ./xlang-c ./bootstrap_xlangc; do
    if [ -x "$b" ]; then
      printf '%s\n' "$b"
      return 0
    fi
  done
  return 1
}

# Prefer one layer .x → .o (simple -E harness; fail → caller seed).
# $1=x_src $2=out.o  Returns 0 on success.
# Stage 12.0.5 labi-only pure-asm product default (authorized 2026-08-12):
#   · XLANG_PREFER_ASM_O_LABI defaults to 1 → scoped XLANG_PREFER_ASM_O=1 for
#     pure_asm_x_to_o only (subshell; does NOT leak tree-level PREFER_ASM_O).
#   · pure_asm reject (panic/__error/CG002/ONLY miss) → fall through -E+$CC.
#   · Escape hatch: XLANG_PREFER_ASM_O_LABI=0 → historic -E+$CC. Ambient tree
#     PREFER_ASM_O does NOT re-enable pure-asm unless
#     XLANG_ALLOW_TREE_PREFER_ASM=1 (product entry also strips tree PREFER).
# Peer defaults (same-day auth wave): XLANG_PREFER_ASM_O_RT (rt_prefer harness
# families: rt/async/R3/l2-asm/B1–B3/…) and XLANG_PREFER_ASM_O_G05 (g05_try).
#   · pipeline_abi mega pure-asm: product open (opaque WEAK on driver_abi bag;
#     hang wall closed typeck slim dual-end <90s emit).
# PLATFORM: SHARED — retry -E then -backend c -E (Ubuntu SIGSEGV history).
# G.7: single pure_asm_x_to_o authority; no second pure-asm helper.
labi_prefer_try_x_to_o() {
  local x_src="$1" x_out="$2" xlang_bin tmp e_ok e_try
  [ -f "$x_src" ] || return 1
  mkdir -p "$(dirname "$x_out")"
  # Labi-only pure-asm default: scope PREFER_ASM_O=1 inside subshell so
  # pure_asm_x_to_o (G.7) runs without flipping tree-level product defaults.
  # When LABI=0: unset ambient PREFER unless ALLOW_TREE (close tree leak).
  # PLATFORM: SHARED.
  if (
    if [ "${XLANG_PREFER_ASM_O_LABI:-1}" = "1" ]; then
      export XLANG_PREFER_ASM_O=1
    elif [ "${XLANG_ALLOW_TREE_PREFER_ASM:-0}" != "1" ]; then
      unset XLANG_PREFER_ASM_O
    fi
    pure_asm_x_to_o "$x_out" "$x_src"
  ); then
    return 0
  fi
  xlang_bin="$(labi_prefer_pick_xlang)" || return 1
  tmp="$(mktemp "${TMPDIR:-/tmp}/labipref.XXXXXX")"
  e_ok=0
  for e_try in 1 2 3 4 5; do
    if "$xlang_bin" -E "$x_src" >"$tmp" 2>/dev/null && [ -s "$tmp" ]; then
      e_ok=1
      break
    fi
    : >"$tmp"
    if "$xlang_bin" -backend c -E "$x_src" >"$tmp" 2>/dev/null && [ -s "$tmp" ]; then
      e_ok=1
      break
    fi
    : >"$tmp"
  done
  if [ "$e_ok" != "1" ]; then
    rm -f "$tmp"
    return 1
  fi
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -x c -c -o "$x_out" "$tmp" 2>/dev/null; then
    rm -f "$tmp"
    return 1
  fi
  rm -f "$tmp"
  return 0
}

# Compile one layer: prefer .x else seed → tmp .o. Sets ok via nameref-ish stdout.
# $1=label $2=x $3=seed $4=out_tmp  → 0 if layer .o ready.
labi_prefer_layer() {
  local label="$1" x_src="$2" seed="$3" out_tmp="$4"
  # wave326: XLANG_LINK_ABI_FROM_X is the new pin-close default;
  # XLANG_G05_PREFER_X_O remains as legacy g05-wide escape hatch.
  local prefer="${XLANG_LINK_ABI_FROM_X:-${XLANG_G05_PREFER_X_O:-0}}"
  if [ "$prefer" = "1" ] && [ -f "$x_src" ]; then
    if labi_prefer_try_x_to_o "$x_src" "$out_tmp"; then
      log "labi $label ← $x_src (prefer .x)"
      return 0
    fi
  fi
  if [ -f "$seed" ]; then
    # shellcheck disable=SC2086
    if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$out_tmp" "$seed" 2>/dev/null; then
      log "labi $label ← $seed (cold seed slice)"
      return 0
    fi
  fi
  return 1
}


# Class CB-fix: nm gates for labi L2 host_lit (SHARED Darwin/Linux).
labi_obj_defines() {
  nm -gU "$1" 2>/dev/null | grep -E " [TWtw] (_)?${2}\$" >/dev/null
}
labi_obj_undefines() {
  nm -gu "$1" 2>/dev/null | grep -E " (_)?${2}\$" >/dev/null
}

ensure_labi_prefer_one() {
  # Prefer multi-slice or cold full seed for src/runtime_link_abi.o (no membership check).
  local o="$1"
  local seed="seeds/runtime_link_abi.from_x.c"
  # wave326: XLANG_LINK_ABI_FROM_X is the pin-close default (1 = labi_*.x authoritative);
  # XLANG_G05_PREFER_X_O remains as legacy g05-wide escape. ALLOW_PIN=1 keeps
  # true-cold egg path: if no xlang binary → compile full seed as archaeology fallback.
  local prefer="${XLANG_LINK_ABI_FROM_X:-${XLANG_G05_PREFER_X_O:-0}}"
  local stale=0 done=0
  local l0_o l1_o l2_o l3_o l4_o l5_o l6_o l7_o l8_o l8b_o l8c_o l9_o rest_o
  local l0_ok=0 l1_ok=0 l2_ok=0 l3_ok=0 l4_ok=0 l5_ok=0 l6_ok=0 l7_ok=0
  local l8_ok=0 l8b_ok=0 l8c_ok=0 l9_ok=0
  local l8b_x_ok=0 l8c_x_ok=0
  local rest_defs link_objs
  # Layer paths (seed-path convention; not a product .o list).
  local l0_x=src/runtime/labi_path_pure.x l0_seed=seeds/labi_path_pure.from_x.c
  local l1_x=src/runtime/labi_diag_pure.x l1_seed=seeds/labi_diag_pure.from_x.c
  local l2_x=src/runtime/labi_host_lit.x l2_seed=seeds/labi_host_lit.from_x.c
  local l3_x=src/runtime/labi_path_io.x l3_seed=seeds/labi_path_io.from_x.c
  local l4_x=src/runtime/labi_ensure_list.x l4_seed=seeds/labi_ensure_list.from_x.c
  local l5_x=src/runtime/labi_invoke_cc_list.x l5_seed=seeds/labi_invoke_cc_list.from_x.c
  local l6_x=src/runtime/labi_invoke_ld_list.x l6_seed=seeds/labi_invoke_ld_list.from_x.c
  local l7_x=src/runtime/labi_freestanding_list.x l7_seed=seeds/labi_freestanding_list.from_x.c
  local l8_x=src/runtime/labi_std_list.x l8_seed=seeds/labi_std_list.from_x.c
  local l8b_x=src/runtime/labi_ondemand_list.x l8b_seed=seeds/labi_ondemand_list.from_x.c
  local l8c_x=src/runtime/labi_ondemand_heavy.x
  local l9_x=src/runtime/labi_gates.x l9_seed=seeds/labi_gates.from_x.c

  if [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o try-labi-prefer: missing seed $seed" >&2
    return 1
  fi

  # Up-to-date skip: seed + any layer .x / layer seed newer → rebuild.
  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    stale=0
    [ "$seed" -nt "$o" ] && stale=1
    for f in \
      "$l0_x" "$l0_seed" "$l1_x" "$l1_seed" "$l2_x" "$l2_seed" \
      "$l3_x" "$l3_seed" "$l4_x" "$l4_seed" "$l5_x" "$l5_seed" \
      "$l6_x" "$l6_seed" "$l7_x" "$l7_seed" "$l8_x" "$l8_seed" \
      "$l8b_x" "$l8b_seed" "$l8c_x" "$l9_x" "$l9_seed" seeds/labi_od_needle_tables.c
    do
      if [ -f "$f" ] && [ "$f" -nt "$o" ]; then
        stale=1
        break
      fi
    done
    # wave793: project-header mtime (FORCE thin; G.7 single body).
    if [ "$stale" = "0" ] && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    # wave794: Makefile flag-sensitive FORCE thin (main/runtime/pipeline_abi).
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    # Class CB-fix: stale hybrid — FROM_X rest + L2 without *_impl → final U.
    if [ "$stale" = "0" ] && labi_obj_undefines "$o" "xlang_host_is_linux_impl"; then
      stale=1
      log "labi $o U-refs xlang_host_is_linux_impl; force rebuild (CB-fix)"
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (labi-prefer)"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$o")"

  # Multi-slice prefer only when PREFER=1 (Darwin cold-chain safety twin of R3).
  if [ "$prefer" = "1" ] && labi_prefer_pick_xlang >/dev/null 2>&1; then
    l0_o="$(mktemp "${TMPDIR:-/tmp}/labi_l0.XXXXXX")"
    l1_o="$(mktemp "${TMPDIR:-/tmp}/labi_l1.XXXXXX")"
    l2_o="$(mktemp "${TMPDIR:-/tmp}/labi_l2.XXXXXX")"
    l3_o="$(mktemp "${TMPDIR:-/tmp}/labi_l3.XXXXXX")"
    l4_o="$(mktemp "${TMPDIR:-/tmp}/labi_l4.XXXXXX")"
    l5_o="$(mktemp "${TMPDIR:-/tmp}/labi_l5.XXXXXX")"
    l6_o="$(mktemp "${TMPDIR:-/tmp}/labi_l6.XXXXXX")"
    l7_o="$(mktemp "${TMPDIR:-/tmp}/labi_l7.XXXXXX")"
    l8_o="$(mktemp "${TMPDIR:-/tmp}/labi_l8.XXXXXX")"
    l8b_o="$(mktemp "${TMPDIR:-/tmp}/labi_l8b.XXXXXX")"
    l8c_o="$(mktemp "${TMPDIR:-/tmp}/labi_l8c.XXXXXX")"
    l9_o="$(mktemp "${TMPDIR:-/tmp}/labi_l9.XXXXXX")"
    rest_o="$(mktemp "${TMPDIR:-/tmp}/labi_rest.XXXXXX")"

    labi_prefer_layer L0 "$l0_x" "$l0_seed" "$l0_o" && l0_ok=1
    labi_prefer_layer L1 "$l1_x" "$l1_seed" "$l1_o" && l1_ok=1
    labi_prefer_layer L2 "$l2_x" "$l2_seed" "$l2_o" && l2_ok=1
    labi_prefer_layer L3 "$l3_x" "$l3_seed" "$l3_o" && l3_ok=1
    labi_prefer_layer L4 "$l4_x" "$l4_seed" "$l4_o" && l4_ok=1
    labi_prefer_layer L5 "$l5_x" "$l5_seed" "$l5_o" && l5_ok=1
    # Class AU: never prefer L6 .x — tip asm miscompiles append_std plan shell
    # (f[zi]=0 infinite loop) and prefer L6 OP_STD/ensure leaves miss std/fmt.
    # L6 stays host-cc via mega rest (no XLANG_LABI_INVOKE_LD_LIST_FROM_X).
    l6_ok=0
    log "labi L6 ← host-cc rest (Class AU: skip prefer .x)"
    labi_prefer_layer L7 "$l7_x" "$l7_seed" "$l7_o" && l7_ok=1
    # Class AU: L8 plan table also host-cc (with L6) until tip asm fk/plan proven.
    l8_ok=0
    log "labi L8 ← host-cc rest (Class AU: skip prefer .x)"
    labi_prefer_layer L9 "$l9_x" "$l9_seed" "$l9_o" && l9_ok=1

    # wave263: L8b early + L8c heavy must BOTH prefer .x, else full L8b seed covers both.
    # Class AU: L6+L8 stay host-cc; L8b/L8c prefer still allowed.
    if [ "$prefer" = "1" ] && [ -f "$l8b_x" ] && labi_prefer_try_x_to_o "$l8b_x" "$l8b_o"; then
      l8b_x_ok=1
    fi
    if [ "$prefer" = "1" ] && [ -f "$l8c_x" ] && labi_prefer_try_x_to_o "$l8c_x" "$l8c_o"; then
      l8c_x_ok=1
    fi
    if [ "$l8b_x_ok" = "1" ] && [ "$l8c_x_ok" = "1" ]; then
      l8b_ok=1
      l8c_ok=1
      log "labi L8b+L8c ← $l8b_x + $l8c_x (capacity split)"
    elif [ -f "$l8b_seed" ]; then
      # PLATFORM: SHARED — L8c prefer of heavy.x often fails (fn#142 typeck).
      # This seed then first-wins as the live L8b table. Counts/needles must
      # stay twin of labi_ondemand_list.x (g15 24 vs 28 was seed-count drift).
      # shellcheck disable=SC2086
      if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$l8b_o" "$l8b_seed" 2>/dev/null; then
        l8b_ok=1
        l8c_ok=0
        log "labi L8b ← $l8b_seed (full seed; L8c unused)"
      fi
    fi

    # Class CB-fix: HOST_LIT_FROM_X only when L2 actually owns *_impl (.x prefer).
    # Cold seed L2 only wraps → U-ref; demote so Cap #if impls stay in rest.
    if [ "$l2_ok" = "1" ]; then
      if ! labi_obj_defines "$l2_o" "xlang_host_is_linux_impl" \
        || ! labi_obj_defines "$l2_o" "xlang_host_is_apple_aarch64_impl"; then
        log "labi L2 lacking *_impl (cold seed?); demote l2_ok — keep rest Cap (CB-fix)"
        l2_ok=0
      fi
    fi

    # Rest FROM_X flags (L0 always required for hybrid path).
    rest_defs="-DXLANG_LABI_PATH_PURE_FROM_X -DXLANG_LABI_NEEDLE_TABLES_EXTERNAL"
    [ "$l1_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_DIAG_PURE_FROM_X"
    [ "$l2_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_HOST_LIT_FROM_X"
    [ "$l3_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_PATH_IO_FROM_X"
    [ "$l4_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_ENSURE_LIST_FROM_X"
    [ "$l5_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_INVOKE_CC_LIST_FROM_X"
    [ "$l6_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_INVOKE_LD_LIST_FROM_X"
    [ "$l7_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_FREESTANDING_LIST_FROM_X"
    [ "$l8_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_STD_LIST_FROM_X"
    [ "$l8b_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_ONDEMAND_LIST_FROM_X"
    [ "$l9_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_GATES_FROM_X"

    if [ "$l0_ok" = "1" ]; then
      # shellcheck disable=SC2086
      if $CC $BASE_CFLAGS -I. -Iinclude -Isrc $rest_defs -c -o "$rest_o" "$seed" 2>/dev/null; then
        link_objs="$l0_o"
        [ "$l1_ok" = "1" ] && link_objs="$link_objs $l1_o"
        [ "$l2_ok" = "1" ] && link_objs="$link_objs $l2_o"
        [ "$l3_ok" = "1" ] && link_objs="$link_objs $l3_o"
        [ "$l4_ok" = "1" ] && link_objs="$link_objs $l4_o"
        [ "$l5_ok" = "1" ] && link_objs="$link_objs $l5_o"
        [ "$l6_ok" = "1" ] && link_objs="$link_objs $l6_o"
        [ "$l7_ok" = "1" ] && link_objs="$link_objs $l7_o"
        [ "$l8_ok" = "1" ] && link_objs="$link_objs $l8_o"
        [ "$l8b_ok" = "1" ] && link_objs="$link_objs $l8b_o"
        [ "$l8c_ok" = "1" ] && link_objs="$link_objs $l8c_o"
        [ "$l9_ok" = "1" ] && link_objs="$link_objs $l9_o"
        # Class BE: when L8b+L8c prefer .x, link host-cc needle tables (bodies omitted in .x).
        # Full L8b seed already #includes tables unless NEEDLE_TABLES_EXTERNAL.
        # Class BG: always link needle tables when prefer multi-slice (L5 icc + L8b/L8c od).
        needle_o="$(mktemp "${TMPDIR:-/tmp}/labi_needle.XXXXXX")"
        # shellcheck disable=SC2086
        if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$needle_o" seeds/labi_od_needle_tables.c 2>/dev/null; then
          rm -f "$needle_o"
          needle_o=""
        fi
        # shellcheck disable=SC2086
        # PLATFORM: SHARED — historic g05 used $CC -r -nostdlib (not ld Darwin flags).
        if [ -n "$needle_o" ]; then
          if pure_ld_partial_merge "$o" $link_objs "$rest_o" "$needle_o" 2>/dev/null; then
            log "prefer multi-slice $o <- L0..L9+L8b+L8c + needle tables + link_abi rest (try-labi-prefer)"
            done=1
          fi
          rm -f "$needle_o"
        elif pure_ld_partial_merge "$o" $link_objs "$rest_o" 2>/dev/null; then
          log "prefer multi-slice $o <- L0..L9+L8b+L8c + link_abi rest (try-labi-prefer)"
          done=1
        fi
      fi
    fi
    rm -f "$l0_o" "$l1_o" "$l2_o" "$l3_o" "$l4_o" "$l5_o" "$l6_o" \
      "$l7_o" "$l8_o" "$l8b_o" "$l8c_o" "$l9_o" "$rest_o"
    if [ "$done" = "0" ]; then
      log "labi multi-slice hybrid failed; fallback full seed"
    fi
  fi

  if [ "$done" = "1" ]; then
    return 0
  fi

  # Cold full seed (ensure_one twin / PREFER=0).
  if [ -f "$o" ] && [ "$prefer" = "1" ]; then
    FORCE=1
    ensure_one "$o" "$seed"
    FORCE=0
  else
    ensure_one "$o" "$seed"
  fi
  return 0
}

try_ensure_labi_prefer_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-labi-prefer: need <out.o>" >&2
    exit 2
  fi
  if [ "$o" != "src/runtime_link_abi.o" ]; then
    return 3
  fi
  ensure_labi_prefer_one "$o"
  return 0
}

# ---------------------------------------------------------------------------
# wave766: try-rt-prefer OUT — g05 rt multi-slice product PREFER (single body).
#
# Single leaf: src/runtime_driver_no_c.o (R1_MAIN_RUNTIME; cold twin = ensure_one
# with RUNTIME_DRIVER_NO_C_CFLAGS).
# When XLANG_G05_PREFER_X_O=1 and an xlang binary works:
#   content + util + argv + emit_flags + compile + run + asm + entry + diag +
#   elf_diag + lib_root + fs + fmt + dispatch* + run_*  prefer thin/full .x
#   → slice .o (else cold layer seed); rest = seeds/runtime.from_x.c under
#   XLANG_RT_*_FROM_X for ok layers; merge $CC -r -nostdlib slices + rest → OUT.
# PLATFORM: SHARED — do NOT merge RT_SEED_SLICE permanent .o into no_c
#   (arena/emit_state/preamble/stack/parse_diag stay external; FROM_X on rest
#   leaves them U in no_c — historic Darwin 22× multidef fix).
# Prefer fail / partial slices → **refuse** monofile by default (wave320);
#   set XLANG_RT_ALLOW_MONOFILE_LAST_RESORT=1 to restore monofile + NO_C last resort.
# wave319: PREFER=0 still multi-slices from cold layer seeds; omit empty mega when full.
# wave320: gate on content layer seed; product path never host-cc monofile unless escape.
# Callers: g05_ensure (wave766) · heat / try-rt-prefer product leaf.
# Exit codes:
#   0 — OUT is runtime_driver_no_c.o; multi-slice (or allow-escape monofile) produced OUT
#   3 — OUT is not src/runtime_driver_no_c.o
#   1 — multi-slice incomplete / monofile refused / compile failed
# PLATFORM: SHARED shell body · g05 historic PREFER=1 · cold chain PREFER=0 multi-slice.
# G.7: no second .o list; layer table is seed-path convention (not product inventory).
# Residual after wave321 monofile rm: typeck 7.4.1 · LEGACY monofile flag variants.
# ---------------------------------------------------------------------------

rt_prefer_no_c_cflags() {
  # stdout: NO_C product flags (Makefile/env or default).
  if [ -n "${RUNTIME_DRIVER_NO_C_CFLAGS:-}" ]; then
    printf '%s' "$RUNTIME_DRIVER_NO_C_CFLAGS"
  else
    printf '%s' "$_DEFAULT_RUNTIME_DRIVER_NO_C_CFLAGS"
  fi
}

rt_prefer_try_x_to_o() {
  _xsrc="$1"
  _xout="$2"
  shift 2
  _xxlang=""
  if [ -x ./xlang ]; then
    _xxlang=./xlang
  elif [ -x ./xlang-c ]; then
    _xxlang=./xlang-c
  elif [ -x ./bootstrap_xlangc ]; then
    _xxlang=./bootstrap_xlangc
  else
    return 1
  fi
  if [ ! -f "$_xsrc" ]; then
    return 1
  fi
  mkdir -p "$(dirname "$_xout")"
  # Stage 12.0.5 prefer-family pure-asm product default (authorized 2026-08-12):
  #   · XLANG_PREFER_ASM_O_RT defaults to 1 → scoped XLANG_PREFER_ASM_O=1 for
  #     pure_asm_x_to_o only (subshell; does NOT leak tree-level PREFER_ASM_O).
  #   · Covers every prefer family that reuses this harness: try-rt-prefer,
  #     try-r3-prefer, try-async-prefer, try-l2-asm-prefer, try-target-cpu /
  #     try-ldpc / try-other-l2, B1 runtime-os / B2 std-core / B3 lsp-sat, etc.
  #   · pure_asm reject (panic/__error/CG002/ONLY miss/WEAK polish fail) →
  #     fall through -E+$CC (same as labi default path).
  #   · Escape hatch: XLANG_PREFER_ASM_O_RT=0 → historic -E+$CC. Ambient tree
  #     PREFER does NOT re-enable pure-asm unless XLANG_ALLOW_TREE_PREFER_ASM=1.
  #   · Ban: tree-level PREFER_ASM_O=1 as product default (hard strip + family=0).
  #     pipeline_abi mega product pure-asm skip (Cap residual; opaque WEAK closed).
  # PLATFORM: SHARED harness · G.7 single pure_asm_x_to_o authority.
  # Labi keeps its own XLANG_PREFER_ASM_O_LABI gate in labi_prefer_try_x_to_o.
  if (
    if [ "${XLANG_PREFER_ASM_O_RT:-1}" = "1" ]; then
      export XLANG_PREFER_ASM_O=1
    elif [ "${XLANG_ALLOW_TREE_PREFER_ASM:-0}" != "1" ]; then
      unset XLANG_PREFER_ASM_O
    fi
    pure_asm_x_to_o "$_xout" "$_xsrc"
  ); then
    return 0
  fi
  # Historic product path: -E → prologue → $CC -c.
  # BSD/macOS mktemp 要求 X 串在模板末尾；勿用 XXXXXX.c
  _xtmp=$(mktemp "${TMPDIR:-/tmp}/rtpref_x.XXXXXX") || return 1
  # F1-2026-08-18: XLANG_PREGEN_E_C=<path> reuses a pre-generated -E dump instead
  # of running the (OOM-prone) -E step here. Use case: mega runtime_pipeline_abi.x
  # -E peaks 22-40GB RSS (fat AST nodes x GrowVec doubling) and dev-box jetsam
  # kills it ~24GB; a big-RAM host (Ubuntu gold, 61GB) runs the bare -E and the
  # artifact is transferred back. Downstream post-processing (weak rename,
  # prologue, cc flags) stays in THIS function — single authority, G.7.
  # PLATFORM: SHARED harness
  if [ -n "${XLANG_PREGEN_E_C:-}" ]; then
    if [ -s "$XLANG_PREGEN_E_C" ]; then
      cat "$XLANG_PREGEN_E_C" > "$_xtmp"
    else
      echo "rt_prefer_try_x_to_o: XLANG_PREGEN_E_C set but empty/missing: $XLANG_PREGEN_E_C" >&2
      rm -f "$_xtmp"
      return 1
    fi
  else
  # 优先默认 -E（Linux 上 -backend c -E 可能 SIGSEGV）；再回退 -backend c -E。
  # Ubuntu 主机偶发 -E SIGSEGV：最多 5 次重试（对齐 prove harness b12bf000）。
  # PLATFORM: SHARED harness
  # shellcheck disable=SC2086
  _e_ok=0
  for _e_try in 1 2 3 4 5; do
    if "$_xxlang" -E "$_xsrc" >"$_xtmp" 2>/dev/null && [ -s "$_xtmp" ]; then
      _e_ok=1
      break
    fi
    : >"$_xtmp"
    if "$_xxlang" -backend c -E "$_xsrc" >"$_xtmp" 2>/dev/null && [ -s "$_xtmp" ]; then
      _e_ok=1
      break
    fi
    : >"$_xtmp"
  done
  if [ "$_e_ok" != "1" ]; then
    rm -f "$_xtmp"
    return 1
  fi
  fi
  if [ -n "${G05_X_O_WEAK_FUNCS:-}" ]; then
    # Named weak only (G.7 有则补全 on rt_prefer harness).
    # wave771 seed_link_compat: 6 stubs must stay weak so lsp_diag_x /
    # lsp_diag_pipeline_ctx strong defs win; do NOT weak every export.
    # Format: G05_X_O_WEAK_FUNCS="name1,name2,..." (bare C identifiers).
    # PLATFORM: SHARED — matches historic g05 sed on ^int32_t name(
    _old_ifs_w="$IFS"
    IFS=','
    for _wfn in $G05_X_O_WEAK_FUNCS; do
      _wfn="$(printf '%s' "$_wfn" | tr -d '[:space:]')"
      [ -z "$_wfn" ] && continue
      perl -i -pe "s/^(int32_t)\\s+${_wfn}\\s*\\(/XLANG_WEAK \$1 ${_wfn}(/" "$_xtmp" || true
    done
    IFS="$_old_ifs_w"
  elif [ "${G05_X_O_WEAK:-0}" = "1" ]; then
    # 仅改非 static 的简单返回类型函数定义行（-E 产物形态）
    # G-02f-335/336：含 uint8_t * / char * / int64_t 返回（diag_color_prefix / get_source_len 等）
    perl -i -pe 's/^((?:void|int64_t|int32_t|int|size_t|uint32_t|uint64_t|uint8_t \*|uint8_t|const char \*|char \*))\s+(\w+)\s*\(/XLANG_WEAK $1 $2(/' "$_xtmp" || true
  fi
  # F1-2026-08-18 chunked -E: -E renders .x file-level `let g_*` as C `static`
  # globals. In a monolithic file all functions share one storage; split chunks
  # would each get a PRIVATE copy (semantic divergence). G05_X_O_GLOBALS_WEAK=1
  # drops `static` and marks them XLANG_WEAK so ld -r first-wins restores the
  # single shared storage across merged chunks. Default 0 = zero regression.
  # PLATFORM: SHARED harness (chunked runtime_pipeline_abi thin builder).
  if [ "${G05_X_O_GLOBALS_WEAK:-0}" = "1" ]; then
    perl -i -pe 's/^static ((?:(?:const|volatile)\s+)?\w[\w\s]*?\*?\s*g_\w+)/XLANG_WEAK $1/' "$_xtmp" || true
  fi
  # G-02f-458: 前端 *_gen.c .o 的符号重命名
  # 格式：G05_X_O_SYM_RENAME="old1:new1,old2:new2,..."
  # 将 -E 输出中的 .x 函数名重命名为 gen.c 期望的符号名（模块前缀+函数名）
  if [ -n "${G05_X_O_SYM_RENAME:-}" ]; then
    _old_ifs="$IFS"
    IFS=','
    for _pair in $G05_X_O_SYM_RENAME; do
      _old_name="${_pair%%:*}"
      _new_name="${_pair#*:}"
      if [ -n "$_old_name" ] && [ -n "$_new_name" ] && [ "$_old_name" != "$_new_name" ]; then
        perl -i -pe "s/\\b${_old_name}\\b/${_new_name}/g" "$_xtmp" || true
      fi
    done
    IFS="$_old_ifs"
  fi
  # G-02f-332/334：-E 缺 ssize_t / open 原型；前置 POSIX 头，并删掉 -E 里冲突的 libc extern
  {
    echo '/* rt_prefer_try_x_to_o prologue (G-02f-332/334 + uio/poll) */'
    echo '#include <stddef.h>'
    echo '#include <stdint.h>'
    echo '#include "xlang_weak.h"'
    echo '#include <sys/types.h>'
    echo '#include <stdlib.h>'
    echo '#include <string.h>'
    echo '#include <stdio.h>'
    echo '#ifdef _WIN32'
    # PLATFORM: WINDOWS — -E dumps call POSIX read/write/rmdir; MinGW CRT is
    # _read/_write/_rmdir. win32_compat.h is the alias authority (access too).
    echo '#include "win32_compat.h"'
    echo '#else'
    echo '#include <unistd.h>'
    echo '#include <fcntl.h>'
    echo '#include <errno.h>'
    # PLATFORM: POSIX — -E preamble 内联 xlang_sys_readv/writev/poll 需原型；
    # 下方 sed 会删掉 -E 自带 #include <poll.h> 等，故在 prologue 补齐。
    echo '#include <sys/uio.h>'
    echo '#include <poll.h>'
    # Cap residual 9.1.10: fmt walk *u8 wrappers via xlang_dir_cap.h (no libc opendir).
    echo '#include <xlang_dir_cap.h>'
    echo 'static inline uint8_t *xlang_fmt_opendir(uint8_t *name) {'
    echo '  return name ? (uint8_t *)xlang_dir_open((const char *)(void *)name) : (uint8_t *)0;'
    echo '}'
    echo 'static inline int32_t xlang_fmt_closedir(uint8_t *dirp) {'
    echo '  return dirp ? (int32_t)xlang_dir_close((void *)dirp) : (int32_t)-1;'
    echo '}'
    echo 'static inline int32_t xlang_fmt_access(uint8_t *path, int32_t mode) {'
    echo '  return path ? (int32_t)access((const char *)path, (int)mode) : (int32_t)-1;'
    echo '}'
    echo 'static inline uint8_t *xlang_fmt_readdir_name(uint8_t *dirp) {'
    echo '  char *n;'
    echo '  if (!dirp) return (uint8_t *)0;'
    echo '  n = xlang_dir_readdir_name((void *)dirp);'
    echo '  return (uint8_t *)(void *)n;'
    echo '}'
    echo '#endif'
    # PLATFORM: SHARED — Cap residual 9.7.1: opaque *u8 stream face → fd-handle.
    # Authority: include/xlang_driver_stream_cap.h (handle = fd+1, NULL invalid;
    # std fds 0/1/2 never closed). Write/open/close route through the Cap
    # authorities (xlang_io_write / xlang_io_open_write / xlang_proc_close_fd),
    # so generated TUs carry zero stdio UNDEFs. Signatures stay `uint8_t *` —
    # .x consumers are source-compatible.
    echo '#include "xlang_driver_stream_cap.h"'
    echo 'static inline int32_t xlang_driver_fputs_opaque(uint8_t *s, uint8_t *stream) {'
    echo '  int fd = xlang_driver_handle_to_fd(stream);'
    echo '  if (!s || fd < 0) return -1;'
    echo '  return (int32_t)xlang_io_write(fd, s, strlen((const char *)(void *)s));'
    echo '}'
    echo 'static inline uint8_t *xlang_driver_stdout_ptr(void) {'
    echo '  return xlang_driver_handle_from_fd(1);'
    echo '}'
    echo 'static inline int32_t xlang_driver_fclose_opaque(uint8_t *stream) {'
    echo '  return (int32_t)xlang_driver_handle_close(stream);'
    echo '}'
    echo 'static inline int32_t xlang_driver_fwrite_opaque(uint8_t *data, int32_t len, uint8_t *stream) {'
    echo '  long n;'
    echo '  int fd;'
    echo '  if (!data || len < 0 || !stream) return 1;'
    echo '  if (len == 0) return 0;'
    echo '  fd = xlang_driver_handle_to_fd(stream);'
    echo '  if (fd < 0) return 1;'
    echo '  n = xlang_io_write(fd, data, (size_t)len);'
    echo '  return n == (size_t)len ? 0 : 1;'
    echo '}'
    echo 'static inline uint8_t *xlang_driver_fopen_write_opaque(uint8_t *path) {'
    echo '  int fd;'
    echo '  if (!path) return (uint8_t *)0;'
    echo '  fd = xlang_io_open_write((const char *)(void *)path);'
    echo '  return fd < 0 ? (uint8_t *)0 : xlang_driver_handle_from_fd(fd);'
    echo '}'
    echo 'static inline uint8_t *xlang_driver_stderr_ptr(void) {'
    echo '  return xlang_driver_handle_from_fd(2);'
    echo '}'
    echo 'static inline void xlang_driver_fflush_stdout(void) {'
    echo '}'
    echo 'static inline uint8_t *xlang_driver_fopen_wb_opaque(uint8_t *path) {'
    echo '  int fd;'
    echo '  if (!path) return (uint8_t *)0;'
    echo '  fd = xlang_io_open_write((const char *)(void *)path);'
    echo '  return fd < 0 ? (uint8_t *)0 : xlang_driver_handle_from_fd(fd);'
    echo '}'
    echo 'static inline uint8_t *xlang_driver_fdopen_wb_opaque(int32_t fd) {'
    echo '  if (fd < 0) return (uint8_t *)0;'
    echo '  return xlang_driver_handle_from_fd(fd);'
    echo '}'
    # PLATFORM: SHARED — wave79 Cap residual: libc realpath as opaque *u8 for pure
    # xlang_path_try_realpath_inplace (runtime_pipeline_abi.x). .x must not name char*
    # realpath (labi_path_io clash note); non-POSIX returns null → pure leaves path.
    # POSIX/APPLE: realpath from unistd/stdlib (prologue includes them above).
    echo '#if defined(_POSIX_VERSION) || defined(__APPLE__)'
    echo 'static inline uint8_t *xlang_driver_realpath_opaque(uint8_t *path, uint8_t *resolved) {'
    echo '  char *r;'
    echo '  if (!path || !resolved) return (uint8_t *)0;'
    echo '  r = realpath((const char *)(void *)path, (char *)(void *)resolved);'
    echo '  return (uint8_t *)(void *)r;'
    echo '}'
    echo '#else'
    echo 'static inline uint8_t *xlang_driver_realpath_opaque(uint8_t *path, uint8_t *resolved) {'
    echo '  (void)path; (void)resolved;'
    echo '  return (uint8_t *)0;'
    echo '}'
    echo '#endif'
    # PLATFORM: SHARED — wave84 Cap residual: function address as *u8 for pure
    # pipeline_run_x_thread_fn_ptr / xlang_asm_codegen_elf_o_thread_fn_ptr
    # (runtime_pipeline_abi.x). .x cannot form function-pointer constants (&fn);
    # pure thin surface owns the product names; cast residual stays in this harness
    # (same pattern as stdout_ptr / realpath_opaque). Cold twin under seed #ifndef FROM_X.
    # Match pure .x export: *u8 arg / *u8 return (not void* — gcc conflicts with pure body).
    echo 'extern uint8_t *pipeline_run_x_thread_fn(uint8_t *);'
    echo 'extern uint8_t *xlang_asm_codegen_elf_o_thread_fn(uint8_t *);'
    echo 'static inline uint8_t *xlang_driver_pipeline_run_x_thread_fn_ptr(void) {'
    echo '  return (uint8_t *)(void *)pipeline_run_x_thread_fn;'
    echo '}'
    echo 'static inline uint8_t *xlang_driver_asm_elf_o_thread_fn_ptr(void) {'
    echo '  return (uint8_t *)(void *)xlang_asm_codegen_elf_o_thread_fn;'
    echo '}'
    # Strip -E #include + libc redecls that clash with prologue headers.
    # PLATFORM: SHARED harness — G.7 product authority for libc skip is
    # codegen_is_libc_conflicting_extern_name (codegen.x + seed). After wave30,
    # mkstemp/rename are in that predicate; sed lines below stay as defense for
    # cold/old xlang -E, opendir opaque (intentionally NOT in product skip), and
    # xlang_fmt_*/xlang_driver_* harness helpers defined as static inline above.
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
        -e '/^extern uint8_t \* memcpy(/d' \
        -e '/^extern void \* memcpy(/d' \
        -e '/^extern int32_t memcmp(/d' \
        -e '/^extern int memcmp(/d' \
        -e '/^extern char \* getenv(/d' \
        -e '/^extern uint8_t \* getenv(/d' \
        -e '/^extern char \* getcwd(/d' \
        -e '/^extern uint8_t \* getcwd(/d' \
        -e '/^extern int32_t unlink(/d' \
        -e '/^extern int unlink(/d' \
        -e '/^extern size_t strlen(/d' \
        -e '/^extern int32_t strcmp(/d' \
        -e '/^extern int strcmp(/d' \
        -e '/^extern int32_t strncmp(/d' \
        -e '/^extern int strncmp(/d' \
        -e '/^extern uint8_t \* strstr(/d' \
        -e '/^extern char \* strstr(/d' \
        -e '/^extern uint8_t \* memset(/d' \
        -e '/^extern void \* memset(/d' \
        -e '/^extern int32_t setenv(/d' \
        -e '/^extern int setenv(/d' \
        -e '/^extern uint8_t \* strerror(/d' \
        -e '/^extern char \* strerror(/d' \
        -e '/^extern int32_t system(/d' \
        -e '/^extern int system(/d' \
        -e '/^extern int32_t fputs(/d' \
        -e '/^extern int fputs(/d' \
        -e '/^extern uint8_t \* opendir(/d' \
        -e '/^extern void \* opendir(/d' \
        -e '/^extern DIR \* opendir(/d' \
        -e '/^extern int32_t closedir(/d' \
        -e '/^extern int closedir(/d' \
        -e '/^extern int32_t access(/d' \
        -e '/^extern int access(/d' \
        -e '/^extern uint8_t \* xlang_fmt_opendir(/d' \
        -e '/^extern int32_t xlang_fmt_closedir(/d' \
        -e '/^extern int32_t xlang_fmt_access(/d' \
        -e '/^extern uint8_t \* xlang_fmt_readdir_name(/d' \
        -e '/^extern int32_t xlang_driver_fputs_opaque(/d' \
        -e '/^extern uint8_t \* xlang_driver_stdout_ptr(/d' \
        -e '/^extern int32_t xlang_driver_fclose_opaque(/d' \
        -e '/^extern int32_t xlang_driver_fwrite_opaque(/d' \
        -e '/^extern uint8_t \* xlang_driver_fopen_write_opaque(/d' \
        -e '/^extern uint8_t \* xlang_driver_stderr_ptr(/d' \
        -e '/^extern void xlang_driver_fflush_stdout(/d' \
        -e '/^extern uint8_t \* xlang_driver_fopen_wb_opaque(/d' \
        -e '/^extern uint8_t \* xlang_driver_fdopen_wb_opaque(/d' \
        -e '/^extern uint8_t \* xlang_driver_realpath_opaque(/d' \
        -e '/^extern uint8_t \* xlang_driver_pipeline_run_x_thread_fn_ptr(/d' \
        -e '/^extern uint8_t \* xlang_driver_asm_elf_o_thread_fn_ptr(/d' \
        -e '/^extern int32_t mkstemp(/d' \
        -e '/^extern int mkstemp(/d' \
        -e '/^extern int32_t rename(/d' \
        -e '/^extern int rename(/d' \
        "$_xtmp"
  } >"${_xtmp}.full" && mv "${_xtmp}.full" "$_xtmp"
  # shellcheck disable=SC2086
  # -x c：mktemp 无扩展名时 clang 否则不当作 C 源
  if ! $CC $BASE_CFLAGS "$@" -x c -c -o "$_xout" "$_xtmp"; then
    rm -f "$_xtmp"
    return 1
  fi
  rm -f "$_xtmp"
  return 0
}

ensure_rt_prefer_one() {
  # Prefer multi-slice (or cold multi-slice); monofile last-resort only with escape.
  # PLATFORM: SHARED freestanding — wave318/319 omit empty mega; wave320 refuse monofile.
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local allow_monofile="${XLANG_RT_ALLOW_MONOFILE_LAST_RESORT:-0}"
  local RUNTIME_DRIVER_NO_C_CFLAGS
  RUNTIME_DRIVER_NO_C_CFLAGS="$(rt_prefer_no_c_cflags)"
  export RUNTIME_DRIVER_NO_C_CFLAGS
  # Historic g05 block (paths + hybrid/cold multi-slice; monofile opt-in only).
    # G-02f-14 / G-02f-261～265 / G-02f-291～297：runtime_driver_no_c.o
    # PREFER_X_O=1：R2..parsed 切片 hybrid（.x+seed）→ omit empty mega rest (wave318)
    # PREFER_X_O=0：同层 cold seed 切片 only → omit empty mega rest (wave319)
    # wave320：默认 **拒** monofile last-resort（7.1.2）；escape=XLANG_RT_ALLOW_MONOFILE_LAST_RESORT=1
    # 注：RFC R4 DCE 在 !XLANG_USE_X_DRIVER 下，不进产品 .o；R7 spawn 仍 rest
    _rt=seeds/runtime.from_x.c
    _rt_content_x=src/runtime/rt_content.x
    _rt_content_seed=seeds/rt_content.from_x.c
    _rt_util_seed=seeds/rt_util.from_x.c
    _rt_util_x=src/runtime/rt_util.x
    _rt_argv_seed=seeds/rt_argv.from_x.c
    _rt_argv_x=src/runtime/rt_argv.x
    _rt_ef_seed=seeds/rt_emit_flags.from_x.c
    _rt_ef_x=src/runtime/rt_emit_flags.x
    _rt_pre_seed=seeds/rt_preamble.from_x.c
    _rt_pre_x=src/runtime/rt_preamble.x
    _rt_compile_seed=seeds/rt_compile.from_x.c
    _rt_compile_x=src/runtime/rt_compile.x
    _rt_run_seed=seeds/rt_run_exec.from_x.c
    _rt_run_exec_x=src/runtime/rt_run_exec.x
    _rt_asm_seed=seeds/rt_asm_stub.from_x.c
    _rt_asm_stub_x=src/runtime/rt_asm_stub.x
    _rt_entry_seed=seeds/rt_entry.from_x.c
    _rt_entry_x=src/runtime/rt_entry.x
    _rt_diag_seed=seeds/rt_diag_errno.from_x.c
    _rt_diag_x=src/runtime/rt_diag_errno.x
    _rt_emit_st_seed=seeds/rt_emit_state.from_x.c
    _rt_emit_st_x=src/runtime/rt_emit_state.x
    _rt_elf_diag_seed=seeds/rt_pipeline_elf_diag.from_x.c
    _rt_elf_diag_x=src/runtime/rt_pipeline_elf_diag.x
    _rt_lib_root_seed=seeds/rt_lib_root.from_x.c
    _rt_lib_root_x=src/runtime/rt_lib_root.x
    _rt_parse_diag_seed=seeds/rt_parse_diag.from_x.c
    _rt_parse_diag_x=src/runtime/rt_parse_diag.x
    _rt_fs_open_seed=seeds/rt_fs_open.from_x.c
    _rt_fs_open_x=src/runtime/rt_fs_open.x
    _rt_arena_buf_seed=seeds/rt_arena_buf.from_x.c
    _rt_arena_buf_x=src/runtime/rt_arena_buf.x
    _rt_fmt_one_seed=seeds/rt_fmt_one.from_x.c
    _rt_fmt_one_x=src/runtime/rt_fmt_one.x
    _rt_dispatch_thin_seed=seeds/rt_dispatch_thin.from_x.c
    _rt_dispatch_thin_x=src/runtime/rt_dispatch_thin.x
    _rt_dispatch_impl_seed=seeds/rt_dispatch_impl.from_x.c
    _rt_dispatch_impl_x=src/runtime/rt_dispatch_impl.x
    _rt_run_x_emit_seed=seeds/rt_run_x_emit.from_x.c
    _rt_run_x_emit_x=src/runtime/rt_run_x_emit.x
    _rt_run_asm_backend_seed=seeds/rt_run_asm_backend.from_x.c
    _rt_run_asm_backend_x=src/runtime/rt_run_asm_backend.x
    _rt_run_compiler_parsed_seed=seeds/rt_run_compiler_parsed.from_x.c
    _rt_run_compiler_parsed_x=src/runtime/rt_run_compiler_parsed.x
    _rt_stack_seed=seeds/rt_stack.from_x.c
    _rt_stack_x=src/runtime/rt_stack.x
    _rt_o="$1"
    # wave320: product multi-slice gated on content layer seed (not monofile presence).
    # Monofile may be absent after future 7.1.1 physical retire; escape still uses _rt.
    # PLATFORM: SHARED freestanding runtime product no_c.
    if [ -f "$_rt_content_seed" ] || [ -f "$_rt" ]; then
      if [ ! -f "$_rt_o" ] \
        || { [ -f "$_rt" ] && [ "$_rt" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_content_seed" ] && [ "$_rt_content_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_util_seed" ] && [ "$_rt_util_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_util_x" ] && [ "$_rt_util_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_argv_seed" ] && [ "$_rt_argv_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_argv_x" ] && [ "$_rt_argv_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_ef_seed" ] && [ "$_rt_ef_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_ef_x" ] && [ "$_rt_ef_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_pre_seed" ] && [ "$_rt_pre_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_pre_x" ] && [ "$_rt_pre_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_compile_seed" ] && [ "$_rt_compile_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_compile_x" ] && [ "$_rt_compile_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_run_seed" ] && [ "$_rt_run_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_run_exec_x" ] && [ "$_rt_run_exec_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_asm_seed" ] && [ "$_rt_asm_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_asm_stub_x" ] && [ "$_rt_asm_stub_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_entry_seed" ] && [ "$_rt_entry_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_entry_x" ] && [ "$_rt_entry_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_diag_seed" ] && [ "$_rt_diag_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_diag_x" ] && [ "$_rt_diag_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_emit_st_seed" ] && [ "$_rt_emit_st_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_emit_st_x" ] && [ "$_rt_emit_st_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_elf_diag_seed" ] && [ "$_rt_elf_diag_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_elf_diag_x" ] && [ "$_rt_elf_diag_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_lib_root_seed" ] && [ "$_rt_lib_root_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_lib_root_x" ] && [ "$_rt_lib_root_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_parse_diag_seed" ] && [ "$_rt_parse_diag_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_parse_diag_x" ] && [ "$_rt_parse_diag_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_fs_open_seed" ] && [ "$_rt_fs_open_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_fs_open_x" ] && [ "$_rt_fs_open_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_arena_buf_seed" ] && [ "$_rt_arena_buf_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_arena_buf_x" ] && [ "$_rt_arena_buf_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_fmt_one_seed" ] && [ "$_rt_fmt_one_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_fmt_one_x" ] && [ "$_rt_fmt_one_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_dispatch_thin_seed" ] && [ "$_rt_dispatch_thin_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_dispatch_thin_x" ] && [ "$_rt_dispatch_thin_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_dispatch_impl_seed" ] && [ "$_rt_dispatch_impl_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_dispatch_impl_x" ] && [ "$_rt_dispatch_impl_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_run_x_emit_seed" ] && [ "$_rt_run_x_emit_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_run_x_emit_x" ] && [ "$_rt_run_x_emit_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_run_asm_backend_seed" ] && [ "$_rt_run_asm_backend_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_run_asm_backend_x" ] && [ "$_rt_run_asm_backend_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_run_compiler_parsed_seed" ] && [ "$_rt_run_compiler_parsed_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_run_compiler_parsed_x" ] && [ "$_rt_run_compiler_parsed_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_stack_seed" ] && [ "$_rt_stack_seed" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_stack_x" ] && [ "$_rt_stack_x" -nt "$_rt_o" ]; } \
        || { [ -f "$_rt_content_x" ] && [ "$_rt_content_x" -nt "$_rt_o" ]; }; then
        _rt_done=0
        # wave319: multi-slice whenever content cold seed exists (not only PREFER=1).
        # Per-slice still tries .x only when PREFER=1; PREFER=0 uses cold seed bodies.
        # PLATFORM: SHARED freestanding runtime mega cold multi-slice omit empty rest.
        if [ -f "$_rt_content_seed" ]; then
          _rt_c_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_content.XXXXXX") || true
          _rt_u_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_util.XXXXXX") || true
          _rt_a_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_argv.XXXXXX") || true
          _rt_e_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_eflags.XXXXXX") || true
          _rt_p_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_pre.XXXXXX") || true
          _rt_cmp_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_compile.XXXXXX") || true
          _rt_run_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_run.XXXXXX") || true
          _rt_asm_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_asm.XXXXXX") || true
          _rt_ent_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_entry.XXXXXX") || true
          _rt_diag_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_diag.XXXXXX") || true
          _rt_est_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_emit_st.XXXXXX") || true
          _rt_elfd_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_elf_diag.XXXXXX") || true
          _rt_lr_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_lib_root.XXXXXX") || true
          _rt_pd_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_parse_diag.XXXXXX") || true
          _rt_fs_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_fs_open.XXXXXX") || true
          _rt_ab_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_arena_buf.XXXXXX") || true
          _rt_fo_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_fmt_one.XXXXXX") || true
          _rt_dt_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_dispatch_thin.XXXXXX") || true
          _rt_di_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_dispatch_impl.XXXXXX") || true
          _rt_xe_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_run_x_emit.XXXXXX") || true
          _rt_abk_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_run_asm_backend.XXXXXX") || true
          _rt_rcp_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_run_compiler_parsed.XXXXXX") || true
          _rt_st_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_stack.XXXXXX") || true
          _rt_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_rest.XXXXXX") || true
          _rt_content_ok=0
          _rt_util_ok=0
          _rt_argv_ok=0
          _rt_ef_ok=0
          _rt_pre_ok=0
          _rt_compile_ok=0
          _rt_run_ok=0
          _rt_asm_ok=0
          _rt_entry_ok=0
          _rt_diag_ok=0
          _rt_est_ok=0
          _rt_elfd_ok=0
          _rt_lr_ok=0
          _rt_pd_ok=0
          _rt_fs_ok=0
          _rt_ab_ok=0
          _rt_fo_ok=0
          _rt_dt_ok=0
          _rt_di_ok=0
          _rt_xe_ok=0
          _rt_abk_ok=0
          _rt_rcp_ok=0
          _rt_st_ok=0
          if [ -n "$_rt_c_o" ]; then
            # G-02f-436：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_content_x" ]; then
              _rt_content_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_content_thin.XXXXXX") || true
              _rt_content_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_content_rest.XXXXXX") || true
              if [ -n "$_rt_content_thin_o" ] && [ -n "$_rt_content_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_content_x" "$_rt_content_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_CONTENT_FROM_X \
                     -c -o "$_rt_content_rest_o" "$_rt_content_seed" \
                && pure_ld_partial_merge "$_rt_c_o" "$_rt_content_thin_o" "$_rt_content_rest_o" 2>/dev/null; then
                _rt_content_ok=1
                echo "rt-prefer: R2 content ← full .x + rest H=0 (path wrappers in .x)"
              fi
              rm -f "$_rt_content_thin_o" "$_rt_content_rest_o"
            fi
            if [ "$_rt_content_ok" = "0" ] && [ -f "$_rt_content_seed" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_c_o" "$_rt_content_seed"; then
                _rt_content_ok=1
                echo "rt-prefer: R2 content ← $_rt_content_seed (G-02f-261/306 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_u_o" ]; then
            # G-02f-435：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_util_x" ]; then
              _rt_util_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_util_thin.XXXXXX") || true
              _rt_util_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_util_rest.XXXXXX") || true
              if [ -n "$_rt_util_thin_o" ] && [ -n "$_rt_util_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_util_x" "$_rt_util_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_UTIL_FROM_X \
                     -c -o "$_rt_util_rest_o" "$_rt_util_seed" \
                && pure_ld_partial_merge "$_rt_u_o" "$_rt_util_thin_o" "$_rt_util_rest_o" 2>/dev/null; then
                _rt_util_ok=1
                echo "rt-prefer: R0 util ← thin .x + rest (G-02f-435 L2 prefer .x)"
              fi
              rm -f "$_rt_util_thin_o" "$_rt_util_rest_o"
            fi
            if [ "$_rt_util_ok" = "0" ] && [ -f "$_rt_util_seed" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_u_o" "$_rt_util_seed"; then
                _rt_util_ok=1
                echo "rt-prefer: R0 util ← $_rt_util_seed (G-02f-262 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_a_o" ]; then
            # R2 full：PREFER_X_O=1 时 full .x + rest seed (-D FROM_X 业务 H=0) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_argv_x" ]; then
              _rt_argv_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_argv_thin.XXXXXX") || true
              _rt_argv_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_argv_rest.XXXXXX") || true
              if [ -n "$_rt_argv_thin_o" ] && [ -n "$_rt_argv_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_argv_x" "$_rt_argv_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_ARGV_FROM_X \
                     -c -o "$_rt_argv_rest_o" "$_rt_argv_seed" \
                && pure_ld_partial_merge "$_rt_a_o" "$_rt_argv_thin_o" "$_rt_argv_rest_o" 2>/dev/null; then
                _rt_argv_ok=1
                echo "rt-prefer: R1 argv ← full .x + rest (R2 full H=0; G-02f-431 PREFER_X_O)"
              fi
              rm -f "$_rt_argv_thin_o" "$_rt_argv_rest_o"
            fi
            if [ "$_rt_argv_ok" = "0" ] && [ -f "$_rt_argv_seed" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_a_o" "$_rt_argv_seed"; then
                _rt_argv_ok=1
                echo "rt-prefer: R1 argv ← $_rt_argv_seed (G-02f-263 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_e_o" ] && [ -f "$_rt_ef_seed" ]; then
            # G-02f-451：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_ef_x" ]; then
              _rt_ef_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_emit_flags_thin.XXXXXX") || true
              _rt_ef_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_emit_flags_rest.XXXXXX") || true
              if [ -n "$_rt_ef_thin_o" ] && [ -n "$_rt_ef_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_ef_x" "$_rt_ef_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_EMIT_FLAGS_FROM_X \
                     -c -o "$_rt_ef_rest_o" "$_rt_ef_seed" \
                && pure_ld_partial_merge "$_rt_e_o" "$_rt_ef_thin_o" "$_rt_ef_rest_o" 2>/dev/null; then
                _rt_ef_ok=1
                echo "rt-prefer: R2 emit_flags ← full .x + rest (G-02f R2 prefer .x; FROM_X rest H=0)"
              fi
              rm -f "$_rt_ef_thin_o" "$_rt_ef_rest_o"
            fi
            if [ "$_rt_ef_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_e_o" "$_rt_ef_seed"; then
                _rt_ef_ok=1
                echo "rt-prefer: R5-lite emit_flags ← $_rt_ef_seed (G-02f-264 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_p_o" ] && [ -f "$_rt_pre_seed" ]; then
            # w861: the two writers and the slice marker are in the .x.
            # This temp merges .x + string tables. It must not replace
            # src/runtime/rt_preamble.o. Do not invoke try-rt-prefer.
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_pre_x" ]; then
              _rt_p_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_pre_thin.XXXXXX") || true
              _rt_p_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_pre_rest.XXXXXX") || true
              if [ -n "$_rt_p_thin_o" ] && [ -n "$_rt_p_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_pre_x" "$_rt_p_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_PREAMBLE_FROM_X \
                     -c -o "$_rt_p_rest_o" "$_rt_pre_seed" \
                && pure_ld_partial_merge "$_rt_p_o" "$_rt_p_thin_o" "$_rt_p_rest_o" 2>/dev/null; then
                _rt_pre_ok=1
                echo "rt-prefer: R3 preamble ← full .x + rest tables (w861; marker is in the .x)"
              fi
              rm -f "$_rt_p_thin_o" "$_rt_p_rest_o"
            fi
            if [ "$_rt_pre_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_p_o" "$_rt_pre_seed"; then
                _rt_pre_ok=1
                echo "rt-prefer: R3 preamble ← $_rt_pre_seed (G-02f-265 seed slice cold)"
              fi
            fi
          fi
          if [ -n "$_rt_cmp_o" ] && [ -f "$_rt_compile_seed" ]; then
            # G-02f-454：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
            # 门闩：.x -E 可能「假成功」缺关键 T 符号；FROM_X rest 仅前向声明 → 最终 link U。
            # 合并后必须有 seed 权威入口，否则回退完整 seed 冷编。
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_compile_x" ]; then
              _rt_cmp_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_compile_thin.XXXXXX") || true
              _rt_cmp_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_compile_rest.XXXXXX") || true
              if [ -n "$_rt_cmp_thin_o" ] && [ -n "$_rt_cmp_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_compile_x" "$_rt_cmp_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_COMPILE_FROM_X \
                     $(host_cc_win_compat_cflags) \
                     -c -o "$_rt_cmp_rest_o" "$_rt_compile_seed" \
                && pure_ld_partial_merge "$_rt_cmp_o" "$_rt_cmp_thin_o" "$_rt_cmp_rest_o" 2>/dev/null \
                && nm "$_rt_cmp_o" 2>/dev/null | grep -q " T driver_compile_state_alloc_c$" \
                && nm "$_rt_cmp_o" 2>/dev/null | grep -q " T driver_deps_are_std_core_closure_only$" \
                && nm "$_rt_cmp_o" 2>/dev/null | grep -q " T driver_compile_parse_argv_impl_c$"; then
                _rt_compile_ok=1
                echo "rt-prefer: R6 compile ← full .x + rest marker (R2 full H=0)"
              else
                echo "rt-prefer: R6 compile .x hybrid incomplete (missing T exports) → seed fallback" >&2
              fi
              rm -f "$_rt_cmp_thin_o" "$_rt_cmp_rest_o"
            fi
            if [ "$_rt_compile_ok" = "0" ]; then
              # shellcheck disable=SC2086
              # shellcheck disable=SC2046,SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc $(host_cc_win_compat_cflags) -c -o "$_rt_cmp_o" "$_rt_compile_seed"; then
                _rt_compile_ok=1
                echo "rt-prefer: R6 compile pure ← $_rt_compile_seed (G-02f-291~296 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_run_o" ]; then
            # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
            # 门闩：.x -E 假成功缺 driver_run_test 时不得标 FROM_X（否则 driver_test_x 链 U）。
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_run_exec_x" ]; then
              _rt_run_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_run_thin.XXXXXX") || true
              _rt_run_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_run_rest.XXXXXX") || true
              if [ -n "$_rt_run_thin_o" ] && [ -n "$_rt_run_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_run_exec_x" "$_rt_run_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_RUN_EXEC_FROM_X \
                     -c -o "$_rt_run_rest_o" "$_rt_run_seed" \
                && pure_ld_partial_merge "$_rt_run_o" "$_rt_run_thin_o" "$_rt_run_rest_o" 2>/dev/null \
                && nm "$_rt_run_o" 2>/dev/null | grep -q " T driver_run_test$"; then
                _rt_run_ok=1
                echo "rt-prefer: R7 run/exec ← full .x + rest marker (R2 full H=0)"
              else
                echo "rt-prefer: R7 run/exec .x hybrid incomplete (missing driver_run_test) → seed fallback" >&2
              fi
              rm -f "$_rt_run_thin_o" "$_rt_run_rest_o"
            fi
            if [ "$_rt_run_ok" = "0" ] && [ -f "$_rt_run_seed" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_run_o" "$_rt_run_seed"; then
                _rt_run_ok=1
                echo "rt-prefer: R7 run/exec ← $_rt_run_seed (G-02f-297~299/311 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_asm_o" ]; then
            # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_asm_stub_x" ]; then
              _rt_asm_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_asm_thin.XXXXXX") || true
              _rt_asm_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_asm_rest.XXXXXX") || true
              if [ -n "$_rt_asm_thin_o" ] && [ -n "$_rt_asm_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_asm_stub_x" "$_rt_asm_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_ASM_STUB_FROM_X \
                     -c -o "$_rt_asm_rest_o" "$_rt_asm_seed" \
                && pure_ld_partial_merge "$_rt_asm_o" "$_rt_asm_thin_o" "$_rt_asm_rest_o" 2>/dev/null; then
                _rt_asm_ok=1
                echo "rt-prefer: R9 asm stub ← full .x + rest marker (R2 full H=0)"
              fi
              rm -f "$_rt_asm_thin_o" "$_rt_asm_rest_o"
            fi
            if [ "$_rt_asm_ok" = "0" ] && [ -f "$_rt_asm_seed" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_asm_o" "$_rt_asm_seed"; then
                _rt_asm_ok=1
                echo "rt-prefer: R9 asm stub ← $_rt_asm_seed (G-02f-300 seed slice cold)"
              fi
            fi
          fi
          if [ -n "$_rt_ent_o" ] && [ -f "$_rt_entry_seed" ]; then
            # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_entry_x" ]; then
              _rt_ent_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_entry_thin.XXXXXX") || true
              _rt_ent_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_entry_rest.XXXXXX") || true
              if [ -n "$_rt_ent_thin_o" ] && [ -n "$_rt_ent_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_entry_x" "$_rt_ent_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_ENTRY_FROM_X \
                     -c -o "$_rt_ent_rest_o" "$_rt_entry_seed" \
                && pure_ld_partial_merge "$_rt_ent_o" "$_rt_ent_thin_o" "$_rt_ent_rest_o" 2>/dev/null; then
                _rt_entry_ok=1
                echo "rt-prefer: R10 entry ← full .x + rest marker (R2 full H=0)"
              fi
              rm -f "$_rt_ent_thin_o" "$_rt_ent_rest_o"
            fi
            if [ "$_rt_entry_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_ent_o" "$_rt_entry_seed"; then
                _rt_entry_ok=1
                echo "rt-prefer: R10 entry gates ← $_rt_entry_seed (G-02f-301/310 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_diag_o" ] && [ -f "$_rt_diag_seed" ]; then
            # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_diag_x" ]; then
              _rt_diag_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_diag_thin.XXXXXX") || true
              _rt_diag_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_diag_rest.XXXXXX") || true
              if [ -n "$_rt_diag_thin_o" ] && [ -n "$_rt_diag_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_diag_x" "$_rt_diag_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_DIAG_ERRNO_FROM_X \
                     -c -o "$_rt_diag_rest_o" "$_rt_diag_seed" \
                && pure_ld_partial_merge "$_rt_diag_o" "$_rt_diag_thin_o" "$_rt_diag_rest_o" 2>/dev/null; then
                _rt_diag_ok=1
                echo "rt-prefer: rest diag_errno ← full .x + rest marker (R2 full H=0)"
              fi
              rm -f "$_rt_diag_thin_o" "$_rt_diag_rest_o"
            fi
            if [ "$_rt_diag_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_diag_o" "$_rt_diag_seed"; then
                _rt_diag_ok=1
                echo "rt-prefer: rest diag errno ← $_rt_diag_seed (G-02f-302 seed slice cold)"
              fi
            fi
          fi
          if [ -n "$_rt_est_o" ] && [ -f "$_rt_emit_st_seed" ]; then
            # G-02f-455：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_emit_st_x" ]; then
              _rt_est_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_emit_st_thin.XXXXXX") || true
              _rt_est_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_emit_st_rest.XXXXXX") || true
              if [ -n "$_rt_est_thin_o" ] && [ -n "$_rt_est_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_emit_st_x" "$_rt_est_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_EMIT_STATE_FROM_X \
                     -c -o "$_rt_est_rest_o" "$_rt_emit_st_seed" \
                && pure_ld_partial_merge "$_rt_est_o" "$_rt_est_thin_o" "$_rt_est_rest_o" 2>/dev/null; then
                _rt_est_ok=1
                echo "rt-prefer: rest emit state ← full .x + rest BSS+marker (R2 full H=0)"
              fi
              rm -f "$_rt_est_thin_o" "$_rt_est_rest_o"
            fi
            if [ "$_rt_est_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_est_o" "$_rt_emit_st_seed"; then
                _rt_est_ok=1
                echo "rt-prefer: rest emit state+argv ← $_rt_emit_st_seed (G-02f-303/304 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_elfd_o" ] && [ -f "$_rt_elf_diag_seed" ]; then
            # G-02f-445：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_elf_diag_x" ]; then
              _rt_elfd_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_elf_diag_thin.XXXXXX") || true
              _rt_elfd_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_elf_diag_rest.XXXXXX") || true
              if [ -n "$_rt_elfd_thin_o" ] && [ -n "$_rt_elfd_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_elf_diag_x" "$_rt_elfd_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_PIPELINE_ELF_DIAG_FROM_X \
                     -c -o "$_rt_elfd_rest_o" "$_rt_elf_diag_seed" \
                && pure_ld_partial_merge "$_rt_elfd_o" "$_rt_elfd_thin_o" "$_rt_elfd_rest_o" 2>/dev/null; then
                _rt_elfd_ok=1
                echo "rt-prefer: rest pipeline elf diag ← full .x + rest marker (R2 full H=0)"
              fi
              rm -f "$_rt_elfd_thin_o" "$_rt_elfd_rest_o"
            fi
            if [ "$_rt_elfd_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_elfd_o" "$_rt_elf_diag_seed"; then
                _rt_elfd_ok=1
                echo "rt-prefer: rest pipeline elf diag ← $_rt_elf_diag_seed (G-02f-304 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_lr_o" ]; then
            # G-02f-432：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_lib_root_x" ]; then
              _rt_lr_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_lr_thin.XXXXXX") || true
              _rt_lr_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_lr_rest.XXXXXX") || true
              if [ -n "$_rt_lr_thin_o" ] && [ -n "$_rt_lr_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_lib_root_x" "$_rt_lr_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_LIB_ROOT_FROM_X \
                     -c -o "$_rt_lr_rest_o" "$_rt_lib_root_seed" \
                && pure_ld_partial_merge "$_rt_lr_o" "$_rt_lr_thin_o" "$_rt_lr_rest_o" 2>/dev/null; then
                _rt_lr_ok=1
                echo "rt-prefer: rest lib_root ← thin .x + rest (G-02f-432 L2 prefer .x)"
              fi
              rm -f "$_rt_lr_thin_o" "$_rt_lr_rest_o"
            fi
            if [ "$_rt_lr_ok" = "0" ] && [ -f "$_rt_lib_root_seed" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_lr_o" "$_rt_lib_root_seed"; then
                _rt_lr_ok=1
                echo "rt-prefer: rest lib_root ← $_rt_lib_root_seed (G-02f-305 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_pd_o" ] && [ -f "$_rt_parse_diag_seed" ]; then
            # w860: the precise diagnostic and the slice marker are in the .x.
            # FROM_X / PRECISE_BRIDGE below are no-ops. This temp is rm'd
            # and must not replace src/runtime/rt_parse_diag.o. Do not
            # route a slice refresh through try-rt-prefer of no_c.
            # G-02f-448：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_parse_diag_x" ]; then
              _rt_pd_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_parse_diag_thin.XXXXXX") || true
              _rt_pd_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_parse_diag_rest.XXXXXX") || true
              if [ -n "$_rt_pd_thin_o" ] && [ -n "$_rt_pd_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_parse_diag_x" "$_rt_pd_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc \
                     -DXLANG_RT_PARSE_DIAG_FROM_X -DXLANG_RT_PARSE_DIAG_PRECISE_BRIDGE \
                     -c -o "$_rt_pd_rest_o" "$_rt_parse_diag_seed" \
                && pure_ld_partial_merge "$_rt_pd_o" "$_rt_pd_thin_o" "$_rt_pd_rest_o" 2>/dev/null; then
                _rt_pd_ok=1
                echo "rt-prefer: rest parse_diag ← thin .x + rest (R2 full H=0; G-02f-448 PREFER_X_O)"
              fi
              rm -f "$_rt_pd_thin_o" "$_rt_pd_rest_o"
            fi
            if [ "$_rt_pd_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_pd_o" "$_rt_parse_diag_seed"; then
                _rt_pd_ok=1
                echo "rt-prefer: rest parse diag ← $_rt_parse_diag_seed (G-02f-307 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_fs_o" ] && [ -f "$_rt_fs_open_seed" ]; then
            # G-02f-452：PREFER_X_O=1 时 thin .x + rest seed (-D) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_fs_open_x" ]; then
              _rt_fs_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_fs_open_thin.XXXXXX") || true
              _rt_fs_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_fs_open_rest.XXXXXX") || true
              if [ -n "$_rt_fs_thin_o" ] && [ -n "$_rt_fs_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_fs_open_x" "$_rt_fs_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_FS_OPEN_FROM_X \
                     -c -o "$_rt_fs_rest_o" "$_rt_fs_open_seed" \
                && pure_ld_partial_merge "$_rt_fs_o" "$_rt_fs_thin_o" "$_rt_fs_rest_o" 2>/dev/null; then
                _rt_fs_ok=1
                echo "rt-prefer: rest fs open ← thin .x + rest (R2 full H=0; G-02f-452 PREFER_X_O)"
              fi
              rm -f "$_rt_fs_thin_o" "$_rt_fs_rest_o"
            fi
            if [ "$_rt_fs_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_fs_o" "$_rt_fs_open_seed"; then
                _rt_fs_ok=1
                echo "rt-prefer: rest fs open ← $_rt_fs_open_seed (G-02f-308 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_ab_o" ] && [ -f "$_rt_arena_buf_seed" ]; then
            # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，BSS+marker) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_arena_buf_x" ]; then
              _rt_ab_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_arena_thin.XXXXXX") || true
              _rt_ab_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_arena_rest.XXXXXX") || true
              if [ -n "$_rt_ab_thin_o" ] && [ -n "$_rt_ab_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_arena_buf_x" "$_rt_ab_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_ARENA_BUF_FROM_X \
                     -c -o "$_rt_ab_rest_o" "$_rt_arena_buf_seed" \
                && pure_ld_partial_merge "$_rt_ab_o" "$_rt_ab_thin_o" "$_rt_ab_rest_o" 2>/dev/null; then
                _rt_ab_ok=1
                echo "rt-prefer: rest arena_buf ← full .x + rest BSS+marker (R2 full H=0)"
              fi
              rm -f "$_rt_ab_thin_o" "$_rt_ab_rest_o"
            fi
            if [ "$_rt_ab_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_ab_o" "$_rt_arena_buf_seed"; then
                _rt_ab_ok=1
                echo "rt-prefer: rest arena_buf ← $_rt_arena_buf_seed (G-02f-309 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_fo_o" ] && [ -f "$_rt_fmt_one_seed" ]; then
            # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_fmt_one_x" ]; then
              _rt_fo_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_fmt_one_thin.XXXXXX") || true
              _rt_fo_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_fmt_one_rest.XXXXXX") || true
              if [ -n "$_rt_fo_thin_o" ] && [ -n "$_rt_fo_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_fmt_one_x" "$_rt_fo_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_FMT_ONE_FROM_X \
                     -c -o "$_rt_fo_rest_o" "$_rt_fmt_one_seed" \
                && pure_ld_partial_merge "$_rt_fo_o" "$_rt_fo_thin_o" "$_rt_fo_rest_o" 2>/dev/null; then
                _rt_fo_ok=1
                echo "rt-prefer: rest fmt_one ← full .x + rest marker (R2 full H=0)"
              fi
              rm -f "$_rt_fo_thin_o" "$_rt_fo_rest_o"
            fi
            if [ "$_rt_fo_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_fo_o" "$_rt_fmt_one_seed"; then
                _rt_fo_ok=1
                echo "rt-prefer: rest fmt_one ← $_rt_fmt_one_seed (G-02f-311 seed slice cold)"
              fi
            fi
          fi
          if [ -n "$_rt_dt_o" ] && [ -f "$_rt_dispatch_thin_seed" ]; then
            # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_dispatch_thin_x" ]; then
              _rt_dt_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_dispatch_thin_thin.XXXXXX") || true
              _rt_dt_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_dispatch_thin_rest.XXXXXX") || true
              if [ -n "$_rt_dt_thin_o" ] && [ -n "$_rt_dt_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_dispatch_thin_x" "$_rt_dt_thin_o" \
                && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_DISPATCH_THIN_FROM_X \
                     -c -o "$_rt_dt_rest_o" "$_rt_dispatch_thin_seed" \
                && pure_ld_partial_merge "$_rt_dt_o" "$_rt_dt_thin_o" "$_rt_dt_rest_o" 2>/dev/null; then
                _rt_dt_ok=1
                echo "rt-prefer: rest dispatch_thin ← full .x + rest marker (R2 H=0)"
              fi
              rm -f "$_rt_dt_thin_o" "$_rt_dt_rest_o"
            fi
            if [ "$_rt_dt_ok" = "0" ]; then
              # shellcheck disable=SC2086
              # cold / no PREFER：全 C 体；product 冷路径仍带 ASM_USE_COMPILER_IMPL_C 选 full 分派
              if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_ASM_USE_COMPILER_IMPL_C -c -o "$_rt_dt_o" "$_rt_dispatch_thin_seed"; then
                _rt_dt_ok=1
                echo "rt-prefer: rest dispatch_thin ← $_rt_dispatch_thin_seed (G-02f-312 seed slice cold)"
              fi
            fi
          fi
          if [ -n "$_rt_di_o" ] && [ -f "$_rt_dispatch_impl_seed" ]; then
            # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_dispatch_impl_x" ]; then
              _rt_di_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_dispatch_impl_thin.XXXXXX") || true
              _rt_di_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_dispatch_impl_rest.XXXXXX") || true
              if [ -n "$_rt_di_thin_o" ] && [ -n "$_rt_di_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_dispatch_impl_x" "$_rt_di_thin_o" \
                && $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_DISPATCH_IMPL_FROM_X \
                     -c -o "$_rt_di_rest_o" "$_rt_dispatch_impl_seed" \
                && pure_ld_partial_merge "$_rt_di_o" "$_rt_di_thin_o" "$_rt_di_rest_o" 2>/dev/null; then
                _rt_di_ok=1
                echo "rt-prefer: rest dispatch_impl ← full .x + rest marker (R2 H=0)"
              fi
              rm -f "$_rt_di_thin_o" "$_rt_di_rest_o"
            fi
            if [ "$_rt_di_ok" = "0" ]; then
              # shellcheck disable=SC2086
              # same product NO_C / pipeline / impl flags as runtime rest
              if $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_di_o" "$_rt_dispatch_impl_seed"; then
                _rt_di_ok=1
                echo "rt-prefer: rest dispatch_impl ← $_rt_dispatch_impl_seed (G-02f-313 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_xe_o" ] && [ -f "$_rt_run_x_emit_seed" ]; then
            # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_run_x_emit_x" ]; then
              _rt_xe_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_run_x_emit_thin.XXXXXX") || true
              _rt_xe_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_run_x_emit_rest.XXXXXX") || true
              if [ -n "$_rt_xe_thin_o" ] && [ -n "$_rt_xe_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_run_x_emit_x" "$_rt_xe_thin_o" \
                && $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_RUN_X_EMIT_FROM_X \
                     -c -o "$_rt_xe_rest_o" "$_rt_run_x_emit_seed" \
                && pure_ld_partial_merge "$_rt_xe_o" "$_rt_xe_thin_o" "$_rt_xe_rest_o" 2>/dev/null; then
                _rt_xe_ok=1
                echo "rt-prefer: R2 run_x_emit ← full .x + rest marker (R2 full H=0)"
              fi
              rm -f "$_rt_xe_thin_o" "$_rt_xe_rest_o"
            fi
            if [ "$_rt_xe_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_xe_o" "$_rt_run_x_emit_seed"; then
                _rt_xe_ok=1
                echo "rt-prefer: rest run_x_emit ← $_rt_run_x_emit_seed (G-02f-314 seed slice cold)"
              fi
            fi
          fi
          if [ -n "$_rt_abk_o" ] && [ -f "$_rt_run_asm_backend_seed" ]; then
            # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_run_asm_backend_x" ]; then
              _rt_abk_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_abk_thin.XXXXXX") || true
              _rt_abk_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_abk_rest.XXXXXX") || true
              if [ -n "$_rt_abk_thin_o" ] && [ -n "$_rt_abk_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_run_asm_backend_x" "$_rt_abk_thin_o" \
                && $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_RUN_ASM_BACKEND_FROM_X \
                     -c -o "$_rt_abk_rest_o" "$_rt_run_asm_backend_seed" \
                && pure_ld_partial_merge "$_rt_abk_o" "$_rt_abk_thin_o" "$_rt_abk_rest_o" 2>/dev/null; then
                _rt_abk_ok=1
                echo "rt-prefer: R2 run_asm_backend ← full .x + rest marker (R2 full H=0)"
              fi
              rm -f "$_rt_abk_thin_o" "$_rt_abk_rest_o"
            fi
            if [ "$_rt_abk_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_abk_o" "$_rt_run_asm_backend_seed"; then
                _rt_abk_ok=1
                echo "rt-prefer: rest run_asm_backend ← $_rt_run_asm_backend_seed (G-02f-315 seed slice)"
              fi
            fi
          fi
          if [ -n "$_rt_rcp_o" ] && [ -f "$_rt_run_compiler_parsed_seed" ]; then
            # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_run_compiler_parsed_x" ]; then
              _rt_rcp_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_rcp_thin.XXXXXX") || true
              _rt_rcp_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_rcp_rest.XXXXXX") || true
              if [ -n "$_rt_rcp_thin_o" ] && [ -n "$_rt_rcp_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_run_compiler_parsed_x" "$_rt_rcp_thin_o" \
                && $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_RUN_COMPILER_PARSED_FROM_X \
                     -c -o "$_rt_rcp_rest_o" "$_rt_run_compiler_parsed_seed" \
                && pure_ld_partial_merge "$_rt_rcp_o" "$_rt_rcp_thin_o" "$_rt_rcp_rest_o" 2>/dev/null; then
                _rt_rcp_ok=1
                echo "rt-prefer: R2 run_compiler_parsed ← full .x + rest marker (R2 full H=0)"
              fi
              rm -f "$_rt_rcp_thin_o" "$_rt_rcp_rest_o"
            fi
            if [ "$_rt_rcp_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_rcp_o" "$_rt_run_compiler_parsed_seed"; then
                _rt_rcp_ok=1
                echo "rt-prefer: rest run_compiler_parsed ← $_rt_run_compiler_parsed_seed (G-02f-316 seed slice cold)"
              fi
            fi
          fi
          if [ -n "$_rt_st_o" ] && [ -f "$_rt_stack_seed" ]; then
            # R2 full H=0：PREFER_X_O=1 时 full .x + rest seed (-D，仅 marker) → cc -r 合并
            if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_rt_stack_x" ]; then
              _rt_st_thin_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_stack_thin.XXXXXX") || true
              _rt_st_rest_o=$(mktemp "${TMPDIR:-/tmp}/rtpref_stack_rest.XXXXXX") || true
              if [ -n "$_rt_st_thin_o" ] && [ -n "$_rt_st_rest_o" ] \
                && rt_prefer_try_x_to_o "$_rt_stack_x" "$_rt_st_thin_o" \
                && $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -DXLANG_RT_STACK_FROM_X \
                     -c -o "$_rt_st_rest_o" "$_rt_stack_seed" \
                && pure_ld_partial_merge "$_rt_st_o" "$_rt_st_thin_o" "$_rt_st_rest_o" 2>/dev/null; then
                _rt_st_ok=1
                echo "rt-prefer: rest stack esc ← full .x + rest marker (R2 full H=0)"
              fi
              rm -f "$_rt_st_thin_o" "$_rt_st_rest_o"
            fi
            if [ "$_rt_st_ok" = "0" ]; then
              # shellcheck disable=SC2086
              if $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_st_o" "$_rt_stack_seed"; then
                _rt_st_ok=1
                echo "rt-prefer: rest stack esc ← $_rt_stack_seed (G-02f-317 seed slice cold)"
              fi
            fi
          fi
          _rt_rest_defs="-DXLANG_RT_CONTENT_FROM_X"
          if [ "$_rt_util_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_UTIL_FROM_X"
          fi
          if [ "$_rt_argv_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_ARGV_FROM_X"
          fi
          if [ "$_rt_ef_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_EMIT_FLAGS_FROM_X"
          fi
          if [ "$_rt_pre_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_PREAMBLE_FROM_X"
          fi
          if [ "$_rt_compile_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_COMPILE_FROM_X"
          fi
          if [ "$_rt_run_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_RUN_EXEC_FROM_X"
          fi
          if [ "$_rt_asm_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_ASM_STUB_FROM_X"
          fi
          if [ "$_rt_entry_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_ENTRY_FROM_X"
          fi
          if [ "$_rt_diag_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_DIAG_ERRNO_FROM_X"
          fi
          if [ "$_rt_est_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_EMIT_STATE_FROM_X"
          fi
          if [ "$_rt_elfd_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_PIPELINE_ELF_DIAG_FROM_X"
          fi
          if [ "$_rt_lr_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_LIB_ROOT_FROM_X"
          fi
          if [ "$_rt_pd_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_PARSE_DIAG_FROM_X"
          fi
          if [ "$_rt_fs_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_FS_OPEN_FROM_X"
          fi
          if [ "$_rt_ab_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_ARENA_BUF_FROM_X"
          fi
          if [ "$_rt_fo_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_FMT_ONE_FROM_X"
          fi
          if [ "$_rt_dt_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_DISPATCH_THIN_FROM_X"
          fi
          if [ "$_rt_di_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_DISPATCH_IMPL_FROM_X"
          fi
          if [ "$_rt_xe_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_RUN_X_EMIT_FROM_X"
          fi
          if [ "$_rt_abk_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_RUN_ASM_BACKEND_FROM_X"
          fi
          if [ "$_rt_rcp_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_RUN_COMPILER_PARSED_FROM_X"
          fi
          if [ "$_rt_st_ok" = "1" ]; then
            _rt_rest_defs="$_rt_rest_defs -DXLANG_RT_STACK_FROM_X"
          fi
          # wave318: full non-default hybrid set ⇒ monofile rest T=0 under all
          # XLANG_RT_*_FROM_X (NO_C already carries 5 RT_SEED_SLICE FROM_X).
          # PLATFORM: SHARED freestanding — omit empty mega rest host-cc.
          _rt_full_slices_ok=0
          if [ "$_rt_content_ok" = "1" ] \
            && [ "$_rt_util_ok" = "1" ] && [ "$_rt_argv_ok" = "1" ] \
            && [ "$_rt_ef_ok" = "1" ] && [ "$_rt_compile_ok" = "1" ] \
            && [ "$_rt_run_ok" = "1" ] && [ "$_rt_asm_ok" = "1" ] \
            && [ "$_rt_entry_ok" = "1" ] && [ "$_rt_diag_ok" = "1" ] \
            && [ "$_rt_elfd_ok" = "1" ] && [ "$_rt_lr_ok" = "1" ] \
            && [ "$_rt_fs_ok" = "1" ] && [ "$_rt_fo_ok" = "1" ] \
            && [ "$_rt_dt_ok" = "1" ] && [ "$_rt_di_ok" = "1" ] \
            && [ "$_rt_xe_ok" = "1" ] && [ "$_rt_abk_ok" = "1" ] \
            && [ "$_rt_rcp_ok" = "1" ]; then
            _rt_full_slices_ok=1
          fi
          if [ "$_rt_content_ok" = "1" ]; then
            _rt_link_objs="$_rt_c_o"
            if [ "$_rt_util_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_u_o"
            fi
            if [ "$_rt_argv_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_a_o"
            fi
            if [ "$_rt_ef_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_e_o"
            fi
            # PLATFORM: SHARED — do NOT merge RT_SEED_SLICE objs into no_c.
            # g05_relink_env always links:
            #   rt_arena_buf / rt_emit_state / rt_preamble / rt_stack / rt_parse_diag
            # as separate .o. Merging them here caused Darwin 22× duplicate symbols
            # (parse_diag recovery + arena/emit/preamble/stack). Keep FROM_X on rest
            # (above) so no_c leaves those symbols U; permanent slice .o provide them.
            # Still merge non-slice hybrid pieces (content/util/argv/…/fs/fmt/dispatch…).
            if [ "$_rt_compile_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_cmp_o"
            fi
            if [ "$_rt_run_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_run_o"
            fi
            if [ "$_rt_asm_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_asm_o"
            fi
            if [ "$_rt_entry_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_ent_o"
            fi
            if [ "$_rt_diag_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_diag_o"
            fi
            if [ "$_rt_elfd_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_elfd_o"
            fi
            if [ "$_rt_lr_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_lr_o"
            fi
            if [ "$_rt_fs_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_fs_o"
            fi
            if [ "$_rt_fo_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_fo_o"
            fi
            if [ "$_rt_dt_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_dt_o"
            fi
            if [ "$_rt_di_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_di_o"
            fi
            if [ "$_rt_xe_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_xe_o"
            fi
            if [ "$_rt_abk_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_abk_o"
            fi
            if [ "$_rt_rcp_ok" = "1" ]; then
              _rt_link_objs="$_rt_link_objs $_rt_rcp_o"
            fi
            # Do NOT cp hybrid temps over permanent RT_SEED_SLICE .o (Makefile/seed
            # path owns those). Hybrid thin+rest can be incomplete and would
            # poison product asm codegen (CG002 code_len=0 on Darwin).
            # shellcheck disable=SC2086
            if [ "$_rt_full_slices_ok" = "1" ]; then
              # wave318/319: all non-default slices present → empty mega rest;
              # no host-cc of seeds/runtime.from_x.c (prefer hybrid or cold seeds).
              if pure_ld_partial_merge "$_rt_o" $_rt_link_objs 2>/dev/null; then
                if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ]; then
                  echo "rt-prefer: $_rt_o ← hybrid slices only; omit empty mega rest (wave318)"
                else
                  echo "rt-prefer: $_rt_o ← cold slices only; omit empty mega rest (wave319)"
                fi
                _rt_done=1
              fi
            elif [ "$allow_monofile" = "1" ] && [ -f "$_rt" ] && [ -n "$_rt_rest_o" ] \
              && $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc \
                   $_rt_rest_defs -c -o "$_rt_rest_o" "$_rt" \
              && pure_ld_partial_merge "$_rt_o" $_rt_link_objs "$_rt_rest_o" 2>/dev/null; then
              # wave320: partial monofile rest only with explicit archaeology escape.
              echo "rt-prefer: $_rt_o ← R2..R10/diag/…/parsed + monofile rest (ALLOW_MONOFILE_LAST_RESORT=1)"
              _rt_done=1
            elif [ "$_rt_full_slices_ok" != "1" ]; then
              echo "rt-prefer: partial multi-slice; refuse monofile rest (wave320; set XLANG_RT_ALLOW_MONOFILE_LAST_RESORT=1)" >&2
            fi
          fi
          if [ "$_rt_done" = "0" ]; then
            echo "rt-prefer: L2 multi-slice runtime incomplete (wave320)" >&2
          fi
          rm -f "$_rt_c_o" "$_rt_u_o" "$_rt_a_o" "$_rt_e_o" "$_rt_p_o" "$_rt_cmp_o" "$_rt_run_o" "$_rt_asm_o" "$_rt_ent_o" "$_rt_diag_o" "$_rt_est_o" "$_rt_elfd_o" "$_rt_lr_o" "$_rt_pd_o" "$_rt_fs_o" "$_rt_ab_o" "$_rt_fo_o" "$_rt_dt_o" "$_rt_di_o" "$_rt_xe_o" "$_rt_abk_o" "$_rt_rcp_o" "$_rt_st_o" "$_rt_rest_o"
        fi
        if [ "$_rt_done" = "0" ]; then
          # wave320: product default refuses monofile full-seed last-resort (7.1.2).
          # multi-error recovery 权威在 seeds/rt_parse_diag.from_x.c → 单独链 rt_parse_diag.o
          # （g05_relink_env RT_SEED_SLICE）；NO_C 已带 XLANG_RT_PARSE_DIAG_FROM_X，禁止再 merge。
          if [ "$allow_monofile" = "1" ] && [ -f "$_rt" ]; then
            # wave321: monofile seed physically retired; this branch only if a
            # local archaeology copy is reintroduced outside the tree.
            echo "rt-prefer: runtime_driver_no_c.o ← monofile seed + NO_C (ALLOW_MONOFILE_LAST_RESORT=1)"
            # shellcheck disable=SC2086
            if ! $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -I. -Iinclude -Isrc -c -o "$_rt_o" "$_rt"; then
              echo "rt-prefer: monofile host-cc failed" >&2
              return 1
            fi
            _rt_done=1
          else
            echo "rt-prefer: refuse monofile last-resort for $_rt_o (wave321 monofile retired; need full multi-slice)" >&2
            return 1
          fi
        fi
      fi
    else
      echo "rt-prefer: missing content layer seed ($_rt_content_seed) (wave321 monofile retired)" >&2
      return 1
    fi
  return 0
}

try_ensure_rt_prefer_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-rt-prefer: need <out.o>" >&2
    exit 2
  fi
  if [ "$o" != "src/runtime_driver_no_c.o" ]; then
    return 3
  fi
  # wave320: propagate multi-slice fail / monofile refuse (exit 1).
  ensure_rt_prefer_one "$o"
}

# ---------------------------------------------------------------------------
# wave767: try-pipeline-abi-prefer OUT — g05 pipeline_abi product PREFER (single body).
#
# Single leaf: src/runtime_pipeline_abi.o (R1_EXTRA_CFLAGS; cold twin = ensure_one
# with RUNTIME_PIPELINE_ABI_CFLAGS / -DXLANG_USE_X_PIPELINE).
# When an xlang binary works (always hybrid for this leaf; not gated on PREFER=1):
#   full .x → .o via rt_prefer_try_x_to_o with G05_X_O_WEAK=1 (Darwin ld -r
#     pure-dup tolerance; same harness as wave766 — Cap residual realpath /
#     thread_fn_ptr prologue required by runtime_pipeline_abi.x)
#   rest = seeds/runtime_pipeline_abi.from_x.c under
#     -DXLANG_USE_X_PIPELINE -DXLANG_RUNTIME_PIPELINE_ABI_FROM_X
#   merge: pure_ld_partial_merge thin + rest → OUT
# Prefer fail / no xlang → ensure_one cold + pipeline ABI cflags (or keep OUT).
#
# Stage 12.0.5 COMPILE residual (pipeline_abi mega pure-asm product skip):
#   · typeck wall slim ✅ dual-end emit mac ~45–60s / Ubuntu ~75s (hang closed).
#   · opaque freestanding surface ✅ XLANG_WEAK in runtime_driver_abi.from_x.c
#     (pure-asm may U those faces; pure-ld resolves vs driver_abi bag).
#   · product pure-asm install residual: Cap residual only in seed rest
#     (pure monofile incomplete; basename skip + call-site PREFER_ASM_O_RT=0).
#
# Callers: g05_ensure (wave767) · product ensure_one route for pipeline_abi.
# Exit codes:
#   0 — OUT is runtime_pipeline_abi.o; prefer or cold body produced OUT
#   3 — OUT is not src/runtime_pipeline_abi.o
#   1 — cold seed missing / compile failed
# PLATFORM: SHARED shell body · product cold path = egg hybrid (not cold full seed).
# G.7: reuses rt_prefer_try_x_to_o harness (有则补全; no second -E prologue).
# Residual after: ~~target_cpu~~(wave768) · other L2 · pure-ld · physical delete.
# ---------------------------------------------------------------------------

pipeline_abi_prefer_cflags() {
  # stdout: cold seed flags (Makefile/env or default -DXLANG_USE_X_PIPELINE).
  if [ -n "${RUNTIME_PIPELINE_ABI_CFLAGS:-}" ]; then
    printf '%s' "$RUNTIME_PIPELINE_ABI_CFLAGS"
  else
    printf '%s' "$_DEFAULT_RUNTIME_PIPELINE_ABI_CFLAGS"
  fi
}

ensure_pipeline_abi_prefer_one() {
  local o="$1"
  local seed="seeds/runtime_pipeline_abi.from_x.c"
  local x_src="src/runtime_pipeline_abi.x"
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local stale=0 done=0
  local thin_o rest_o cold_flags

  # After clang-aligned writer + 10/10 Darwin overlay: prefer uses asm for
  # inject_thin_leaf .x thins. Escape XLANG_PABI_THIN_PREFER_ASM=0 → -E.
  # Does not FORCE mega -E. PLATFORM: SHARED · MACOS overlay · LINUX gold.
  XLANG_PABI_THIN_PREFER_ASM="${XLANG_PABI_THIN_PREFER_ASM:-1}"
  export XLANG_PABI_THIN_PREFER_ASM

  if [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o try-pipeline-abi-prefer: missing seed $seed" >&2
    return 1
  fi

  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    stale=0
    # Incomplete Darwin libtool archive masquerading as .o → always rebuild.
    # PLATFORM: MACOS Cap residual (10.3.2); LINUX never matches.
    if pipeline_abi_o_is_libtool_archive "$o"; then
      local arch_sz
      arch_sz=$(wc -c <"$o" | tr -d ' ')
      if [ -z "$arch_sz" ] || [ "$arch_sz" -lt 1000000 ]; then
        log "pipeline_abi prefer: incomplete libtool archive $o (${arch_sz:-0}B) → force rebuild"
        stale=1
      fi
    fi
    [ "$seed" -nt "$o" ] && stale=1
    if [ -f "$x_src" ] && [ "$x_src" -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi.h ] && [ src/runtime_pipeline_abi.h -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_param_ptr_slot_thin.x ] \
      && [ src/runtime_pipeline_abi_param_ptr_slot_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_slot_bytes_thin.x ] \
      && [ src/runtime_pipeline_abi_slot_bytes_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_fnptr_as_thin.x ] \
      && [ src/runtime_pipeline_abi_fnptr_as_thin.x -nt "$o" ]; then
      stale=1
    fi
    # wave507: Cap-fn-ptr EXPR_AS peer-flat overlay mtime
    for _fas in \
      src/runtime_pipeline_abi_fnptr_as_f2i32_thin.x \
      src/runtime_pipeline_abi_fnptr_as_f2i64_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f32_i32_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f32_i64mov_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f32_u64_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f32_i64_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f32_k15_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f32_sf64_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f64_u64_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f64_i64_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f64_i64mov_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f64_i32_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f64_f32_thin.x \
      src/runtime_pipeline_abi_fnptr_as_f2i_orch_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f32_orch_thin.x \
      src/runtime_pipeline_abi_fnptr_as_i2f64_orch_thin.x \
      src/runtime_pipeline_abi_fnptr_as_lea_thin.x \
      src/runtime_pipeline_abi_fnptr_as_cast_orch_thin.x
    do
      if [ -f "$_fas" ] && [ "$_fas" -nt "$o" ]; then
        stale=1
        break
      fi
    done
    unset _fas
    if [ -f src/runtime_pipeline_abi_asm_expr_thin.x ] \
      && [ src/runtime_pipeline_abi_asm_expr_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_fnptr_array_esz_thin.x ] \
      && [ src/runtime_pipeline_abi_fnptr_array_esz_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_reent_deep_copy_thin.x ] \
      && [ src/runtime_pipeline_abi_reent_deep_copy_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_fixed_array_copy_thin.x ] \
      && [ src/runtime_pipeline_abi_fixed_array_copy_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_unused_hints_thin.x ] \
      && [ src/runtime_pipeline_abi_unused_hints_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_wpo_dump_thin.x ] \
      && [ src/runtime_pipeline_abi_wpo_dump_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_wpo_dump_orch_thin.x ] \
      && [ src/runtime_pipeline_abi_wpo_dump_orch_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_field_load_sz_thin.x ] \
      && [ src/runtime_pipeline_abi_field_load_sz_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_macho_write_thin.x ] \
      && [ src/runtime_pipeline_abi_macho_write_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_type_to_c_repr_thin.x ] \
      && [ src/runtime_pipeline_abi_type_to_c_repr_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_binop_block_peel_thin.x ] \
      && [ src/runtime_pipeline_abi_binop_block_peel_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_thin.x -nt "$o" ]; then
      stale=1
    fi
    # wave466–471: INDEX/FIELD Cap residual PREFER overlay mtime
    if [ -f src/runtime_pipeline_abi_assign_index_simd_body_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_simd_body_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_simd_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_simd_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_named_body_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_named_body_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_named_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_named_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_bulk_lval_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_bulk_lval_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_bulk_call_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_bulk_call_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_bulk_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_bulk_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_array_lit_home_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_array_lit_home_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_array_lit_mid_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_array_lit_mid_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_array_lit_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_array_lit_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_var_root_finish_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_var_root_finish_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_var_root_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_var_root_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_generic_try_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_generic_try_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_generic_try2_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_generic_try2_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_generic_scaled_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_generic_scaled_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_index_generic_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_index_generic_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_deref_vec_gate_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_deref_vec_gate_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_deref_after_addr_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_deref_after_addr_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_deref_finish_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_deref_finish_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_deref_peel_var_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_deref_peel_var_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_deref_peel_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_deref_peel_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_deref_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_deref_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_var_try_let_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_var_try_let_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_var_finish_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_var_finish_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_var_store_slice_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_var_store_slice_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_var_store_f32_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_var_store_f32_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_var_store_pair_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_var_store_pair_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_var_store_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_var_store_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_var_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_var_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_rhsrax_arms_load_lr_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_rhsrax_arms_load_lr_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_rhsrax_arms_simple_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_rhsrax_arms_simple_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_rhsrax_arms_div_float_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_rhsrax_arms_div_float_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_rhsrax_arms_div_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_rhsrax_arms_div_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_rhsrax_arms_mod_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_rhsrax_arms_mod_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_rhsrax_arms_shl_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_rhsrax_arms_shl_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_rhsrax_arms_shr_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_rhsrax_arms_shr_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_ptr_hit_step_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_ptr_hit_step_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_ptr_hit_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_ptr_hit_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_var_depth1_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_var_depth1_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_var_simd_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_var_simd_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_var_array_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_var_array_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_var_struct_store_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_var_struct_store_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_var_struct_pair_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_var_struct_pair_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_var_struct_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_var_struct_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_ptr_struct_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_ptr_struct_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_ptr_array_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_ptr_array_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_ptr_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_ptr_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_assign_field_scalar_thin.x ] \
      && [ src/runtime_pipeline_abi_assign_field_scalar_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_binop_stack_spill_try_reload_rax_thin.x ] \
      && [ src/runtime_pipeline_abi_binop_stack_spill_try_reload_rax_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_binop_stack_spill_try_reload_rbx_thin.x ] \
      && [ src/runtime_pipeline_abi_binop_stack_spill_try_reload_rbx_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_binop_stack_spill_try_reload_thin.x ] \
      && [ src/runtime_pipeline_abi_binop_stack_spill_try_reload_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_w157_sum_thin.x ] \
      && [ src/runtime_pipeline_abi_w157_sum_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_binop_var_slot_cache_thin.x ] \
      && [ src/runtime_pipeline_abi_binop_var_slot_cache_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_binop_stack_spill_try_reload_thin.x ] \
      && [ src/runtime_pipeline_abi_binop_stack_spill_try_reload_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_asm73_chaitin_thin.x ] \
      && [ src/runtime_pipeline_abi_asm73_chaitin_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_asm73_live_interf_thin.x ] \
      && [ src/runtime_pipeline_abi_asm73_live_interf_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_asm73_live_set_thin.x ] \
      && [ src/runtime_pipeline_abi_asm73_live_set_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_for_call_args_thin.x ] \
      && [ src/runtime_pipeline_abi_for_call_args_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_emit_index_thin.x ] \
      && [ src/runtime_pipeline_abi_emit_index_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_call_method_wrappers_thin.x ] \
      && [ src/runtime_pipeline_abi_call_method_wrappers_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_al_nc_seq_thin.x ] \
      && [ src/runtime_pipeline_abi_al_nc_seq_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_emit_ctx_bss_thin.x ] \
      && [ src/runtime_pipeline_abi_emit_ctx_bss_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_emit_ctx_module_dep_thin.x ] \
      && [ src/runtime_pipeline_abi_emit_ctx_module_dep_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_emit_ctx_sret_thin.x ] \
      && [ src/runtime_pipeline_abi_emit_ctx_sret_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_typeck_active_thin.x ] \
      && [ src/runtime_pipeline_abi_typeck_active_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_glue_statics_thin.x ] \
      && [ src/runtime_pipeline_abi_glue_statics_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_type_alias_thin.x ] \
      && [ src/runtime_pipeline_abi_type_alias_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_module_import_thin.x ] \
      && [ src/runtime_pipeline_abi_module_import_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_module_enum_thin.x ] \
      && [ src/runtime_pipeline_abi_module_enum_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_top_level_let_thin.x ] \
      && [ src/runtime_pipeline_abi_top_level_let_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_modlet_thin.x ] \
      && [ src/runtime_pipeline_abi_modlet_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_struct_layout_thin.x ] \
      && [ src/runtime_pipeline_abi_struct_layout_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_asm_locals_thin.x ] \
      && [ src/runtime_pipeline_abi_asm_locals_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_block_tree_thin.x ] \
      && [ src/runtime_pipeline_abi_block_tree_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_type_pool_thin.x ] \
      && [ src/runtime_pipeline_abi_type_pool_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_grow_vec_thin.x ] \
      && [ src/runtime_pipeline_abi_grow_vec_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_dep_ctx_thin.x ] \
      && [ src/runtime_pipeline_abi_dep_ctx_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_elf_ctx_thin.x ] \
      && [ src/runtime_pipeline_abi_elf_ctx_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_asm_wpo_thin.x ] \
      && [ src/runtime_pipeline_abi_asm_wpo_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_sidecar_pool_thin.x ] \
      && [ src/runtime_pipeline_abi_sidecar_pool_thin.x -nt "$o" ]; then
      stale=1
    fi
    # wave504: sidecar init peers also invalidate OUT.
    if [ -f src/runtime_pipeline_abi_sidecar_pool_arena_init_thin.x ] \
      && [ src/runtime_pipeline_abi_sidecar_pool_arena_init_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_sidecar_pool_module_init_thin.x ] \
      && [ src/runtime_pipeline_abi_sidecar_pool_module_init_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_sidecar_pool_onefunc_init_thin.x ] \
      && [ src/runtime_pipeline_abi_sidecar_pool_onefunc_init_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_value_abi_thin.x ] \
      && [ src/runtime_pipeline_abi_value_abi_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_block_domain_thin.x ] \
      && [ src/runtime_pipeline_abi_block_domain_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_expr_sidecar_thin.x ] \
      && [ src/runtime_pipeline_abi_expr_sidecar_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_lifecycle_thin.x ] \
      && [ src/runtime_pipeline_abi_lifecycle_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_lifecycle_module_reset_thin.x ] \
      && [ src/runtime_pipeline_abi_lifecycle_module_reset_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_lifecycle_arena_reset_thin.x ] \
      && [ src/runtime_pipeline_abi_lifecycle_arena_reset_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_lifecycle_onefunc_reset_thin.x ] \
      && [ src/runtime_pipeline_abi_lifecycle_onefunc_reset_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_lifecycle_block_thin.x ] \
      && [ src/runtime_pipeline_abi_lifecycle_block_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_lifecycle_drop_thin.x ] \
      && [ src/runtime_pipeline_abi_lifecycle_drop_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_module_func_thin.x ] \
      && [ src/runtime_pipeline_abi_module_func_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_onefunc_thin.x ] \
      && [ src/runtime_pipeline_abi_onefunc_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_bootstrap_glue_thin.x ] \
      && [ src/runtime_pipeline_abi_bootstrap_glue_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_ast_forwarders_thin.x ] \
      && [ src/runtime_pipeline_abi_ast_forwarders_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_parse_orch_thin.x ] \
      && [ src/runtime_pipeline_abi_parse_orch_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_typeck_orch_thin.x ] \
      && [ src/runtime_pipeline_abi_typeck_orch_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_typeck_check_expr_thin.x ] \
      && [ src/runtime_pipeline_abi_typeck_check_expr_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_parser_result_thin.x ] \
      && [ src/runtime_pipeline_abi_parser_result_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_asm_label_format_thin.x ] \
      && [ src/runtime_pipeline_abi_asm_label_format_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_codegen_outbuf_thin.x ] \
      && [ src/runtime_pipeline_abi_codegen_outbuf_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_asm_codegen_mega_body_thin.x ] \
      && [ src/runtime_pipeline_abi_asm_codegen_mega_body_thin.x -nt "$o" ]; then
      stale=1
    fi
    if [ -f src/runtime_pipeline_abi_elf_codegen_forwarders_thin.x ] \
      && [ src/runtime_pipeline_abi_elf_codegen_forwarders_thin.x -nt "$o" ]; then
      stale=1
    fi
    # wave793: project-header mtime (FORCE thin; G.7 single body).
    if [ "$stale" = "0" ] && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    # wave794: Makefile flag-sensitive FORCE thin (main/runtime/pipeline_abi).
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (pipeline-abi-prefer)"
      # C thins only (idempotent). Do not re-pure-asm every .x leaf on a
      # green OUT — that path turned Darwin product red (wave220 probe).
      # PLATFORM: SHARED shell · MACOS + LINUX gold.
      pipeline_abi_inject_macho_write_thin "$o" || true
      pipeline_abi_inject_emit_ctx_bss_thin "$o" || true
      pipeline_abi_inject_emit_ctx_func_index_thin "$o" || true
      pipeline_abi_inject_block_final_expr_thin "$o" || true
      pipeline_abi_inject_return_elf_impl_thin "$o" || true
      pipeline_abi_inject_emit_ctx_module_dep_thin "$o" || true
      pipeline_abi_inject_emit_ctx_sret_thin "$o" || true
      pipeline_abi_inject_typeck_active_thin "$o" || true
      pipeline_abi_inject_glue_statics_thin "$o" || true
      pipeline_abi_inject_type_alias_thin "$o" || true
      pipeline_abi_inject_module_import_thin "$o" || true
      pipeline_abi_inject_module_enum_thin "$o" || true
      pipeline_abi_inject_top_level_let_thin "$o" || true
      pipeline_abi_inject_modlet_thin "$o" || true
      pipeline_abi_inject_struct_layout_thin "$o" || true
      pipeline_abi_inject_asm_locals_thin "$o" || true
      pipeline_abi_inject_block_tree_thin "$o" || true
      pipeline_abi_inject_type_pool_thin "$o" || true
      pipeline_abi_inject_grow_vec_thin "$o" || true
      pipeline_abi_inject_dep_ctx_thin "$o" || true
      pipeline_abi_inject_elf_ctx_thin "$o" || true
      pipeline_abi_inject_const_lit_is_const "$o" || true
      pipeline_abi_inject_asm_wpo_cap "$o" || true
      pipeline_abi_inject_reloc_typed_page21 "$o" || true
      pipeline_abi_inject_data_len_dual_bss "$o" || true
      pipeline_abi_inject_asm_wpo_thin "$o" || true
      pipeline_abi_inject_sidecar_pool_thin "$o" || true
      pipeline_abi_inject_value_abi_thin "$o" || true
      pipeline_abi_inject_block_domain_thin "$o" || true
      pipeline_abi_inject_expr_sidecar_thin "$o" || true
      pipeline_abi_inject_lifecycle_thin "$o" || true
      pipeline_abi_inject_module_func_thin "$o" || true
      pipeline_abi_inject_onefunc_thin "$o" || true
      pipeline_abi_inject_bootstrap_glue_thin "$o" || true
      pipeline_abi_inject_ast_forwarders_thin "$o" || true
      pipeline_abi_inject_parse_orch_thin "$o" || true
      pipeline_abi_inject_typeck_orch_thin "$o" || true
      pipeline_abi_inject_typeck_check_expr_thin "$o" || true
      pipeline_abi_inject_parser_result_thin "$o" || true
      pipeline_abi_inject_asm_label_format_thin "$o" || true
      pipeline_abi_inject_codegen_outbuf_thin "$o" || true
      pipeline_abi_inject_asm_codegen_mega_body_thin "$o" || true
      pipeline_abi_inject_elf_codegen_forwarders_thin "$o" || true
      # wave466: even on skip-up-to-date, re-enter assign inject so LINUX
      #   heal overlays (w458–w478) can fire when their stamps are missing.
      #   wave477: arr_return b0/c + glue_statics tip no-local HARD BAN
      #   (tip U-complete but product reinject → L2 CG002 4/5); keep prior overlays.
      #   Does not re-run mega -E. PLATFORM: SHARED shell · LINUX gold.
      pipeline_abi_inject_assign_thin "$o" || true
      # Class P: re-enter assign_index inject so Linux UNDEF heal can fire
      # even when pipeline_abi.o is stamp-fresh (skip-up-to-date).
      pipeline_abi_inject_assign_index_thin "$o" || true
      # wave609 M2: add_defs product PREFER_ASM (stamp-gated; no host-cc).
      # wave610 M2: param_ptr_slot product PREFER_ASM (stamp-gated; no host-cc).
      # PLATFORM: SHARED shell.
      pipeline_abi_inject_preprocess_malloc_thin "$o" || true
      pipeline_abi_inject_param_ptr_slot_thin "$o" || true
      return 0
    fi
    # Thin inject: mega .x prefer -E is hang-prone (92k LOC). When a hybrid
    # OUT already exists, inject-only instead of full hybrid rebuild.
    # .x leaves: only if src newer than OUT (INJECT_IF_NEWER). C thins always.
    # FORCE=1 / XLANG_HOST_CC_SEED_FORCE=1 still does full thin+rest prefer
    # on POSIX gold. PLATFORM: SHARED shell · LINUX gold + MACOS.
    # PLATFORM: WINDOWS — leftover PE cannot -E mega; FORCE skip is below.
    if [ -s "$o" ] && ! pipeline_abi_o_is_libtool_archive "$o" \
      && { [ -f src/runtime_pipeline_abi_reent_deep_copy_thin.x ] \
      || [ -f src/runtime_pipeline_abi_fixed_array_copy_thin.x ]; }; then
      log "pipeline_abi prefer: inject-only thins (skip full mega -E; HOST_CC_SEED_FORCE=1 for hybrid)"
      XLANG_PABI_THIN_INJECT_IF_NEWER=1
      export XLANG_PABI_THIN_INJECT_IF_NEWER
      pipeline_abi_inject_reent_deep_copy_thin "$o" || true
      pipeline_abi_inject_fixed_array_copy_thin "$o" || true
      pipeline_abi_inject_slot_bytes_thin "$o" || true
      pipeline_abi_inject_field_load_sz_thin "$o" || true
      pipeline_abi_inject_macho_write_thin "$o" || true
      pipeline_abi_inject_unused_hints_thin "$o" || true
      pipeline_abi_inject_wpo_dump_thin "$o" || true
      # ttc-thin merge-fail is pre-existing (already-strong dup); do not
      # abort before blkpeel (same as arrcopy || true before ttc).
      pipeline_abi_inject_type_to_c_repr_thin "$o" || true
      # blkpeel merge-fail is pre-existing on Ubuntu leftover (already-strong
      # dup). Do not abort before ptrslot (this leaf).
      pipeline_abi_inject_binop_block_peel_thin "$o" || true
      pipeline_abi_inject_param_ptr_slot_thin "$o" || return 1
      pipeline_abi_inject_fnptr_as_thin "$o" || return 1
      pipeline_abi_inject_asm_expr_thin "$o" || return 1
      pipeline_abi_inject_fnptr_array_esz_thin "$o" || return 1
      pipeline_abi_inject_assign_thin "$o" || true
      pipeline_abi_inject_assign_index_thin "$o" || true
      pipeline_abi_inject_arr_lit_flat_thin "$o" || true
      pipeline_abi_inject_arr_return_thin "$o" || true
      pipeline_abi_inject_arr_struct_lit_thin "$o" || true
      pipeline_abi_inject_w157_sum_thin "$o" || true
      pipeline_abi_inject_binop_var_slot_cache_thin "$o" || true
      pipeline_abi_inject_binop_stack_spill_try_reload_thin "$o" || true
      pipeline_abi_inject_asm73_chaitin_thin "$o" || true
      pipeline_abi_inject_asm73_live_interf_thin "$o" || true
      pipeline_abi_inject_asm73_live_set_thin "$o" || true
      pipeline_abi_inject_for_call_args_thin "$o" || true
      pipeline_abi_inject_emit_index_thin "$o" || true
      pipeline_abi_inject_call_method_wrappers_thin "$o" || true
      pipeline_abi_inject_al_nc_seq_thin "$o" || true
      pipeline_abi_inject_emit_ctx_bss_thin "$o" || true
      pipeline_abi_inject_emit_ctx_func_index_thin "$o" || true
      pipeline_abi_inject_block_final_expr_thin "$o" || true
      pipeline_abi_inject_return_elf_impl_thin "$o" || true
      pipeline_abi_inject_emit_ctx_module_dep_thin "$o" || true
      pipeline_abi_inject_emit_ctx_sret_thin "$o" || true
      pipeline_abi_inject_typeck_active_thin "$o" || true
      pipeline_abi_inject_glue_statics_thin "$o" || true
      pipeline_abi_inject_type_alias_thin "$o" || true
      pipeline_abi_inject_module_import_thin "$o" || true
      pipeline_abi_inject_module_enum_thin "$o" || true
      pipeline_abi_inject_top_level_let_thin "$o" || true
      pipeline_abi_inject_modlet_thin "$o" || true
      pipeline_abi_inject_struct_layout_thin "$o" || true
      pipeline_abi_inject_asm_locals_thin "$o" || true
      pipeline_abi_inject_block_tree_thin "$o" || true
      pipeline_abi_inject_type_pool_thin "$o" || true
      pipeline_abi_inject_grow_vec_thin "$o" || true
      pipeline_abi_inject_dep_ctx_thin "$o" || true
      pipeline_abi_inject_elf_ctx_thin "$o" || true
      pipeline_abi_inject_const_lit_is_const "$o" || true
      pipeline_abi_inject_asm_wpo_cap "$o" || true
      pipeline_abi_inject_reloc_typed_page21 "$o" || true
      pipeline_abi_inject_data_len_dual_bss "$o" || true
      pipeline_abi_inject_asm_wpo_thin "$o" || true
      pipeline_abi_inject_sidecar_pool_thin "$o" || true
      pipeline_abi_inject_value_abi_thin "$o" || true
      pipeline_abi_inject_block_domain_thin "$o" || true
      pipeline_abi_inject_expr_sidecar_thin "$o" || true
      pipeline_abi_inject_lifecycle_thin "$o" || true
      pipeline_abi_inject_module_func_thin "$o" || true
      pipeline_abi_inject_onefunc_thin "$o" || true
      pipeline_abi_inject_bootstrap_glue_thin "$o" || true
      pipeline_abi_inject_ast_forwarders_thin "$o" || true
      pipeline_abi_inject_parse_orch_thin "$o" || true
      pipeline_abi_inject_typeck_orch_thin "$o" || true
      pipeline_abi_inject_typeck_check_expr_thin "$o" || true
      pipeline_abi_inject_parser_result_thin "$o" || true
      pipeline_abi_inject_asm_label_format_thin "$o" || true
      pipeline_abi_inject_codegen_outbuf_thin "$o" || true
      pipeline_abi_inject_asm_codegen_mega_body_thin "$o" || true
      pipeline_abi_inject_elf_codegen_forwarders_thin "$o" || true
      pipeline_abi_inject_preprocess_malloc_thin "$o" || true
      pipeline_abi_inject_import_heap_thin "$o" || true
      pipeline_abi_inject_read_file_x_view_thin "$o" || true
      unset XLANG_PABI_THIN_INJECT_IF_NEWER
      return 0
    fi
  fi

  # PLATFORM: WINDOWS — leftover PE (Track L / can_run egg) is executable so
  # hybrid rt_prefer_try_x_to_o would launch ./xlang -E of mega
  # runtime_pipeline_abi.x (92k LOC; hang / multi-GB RSS, stderr discarded).
  # SAT rebuild sets XLANG_HOST_CC_SEED_FORCE=1 which skips the inject-only
  # keep above. Do NOT keep leftover hybrid $o: Windows leftover pabi is tens
  # of KiB (FROM_X rest without thin) vs ~1.4MiB POSIX hybrid, and omits
  # pipeline_type_* / pipeline_asm_* / ast_pool_* that tip glue UNDEF at phase1.
  # Cold full seed (no FROM_X) hits 251 void*/struct* dual-decls in
  # seeds/runtime_pipeline_abi.from_x.c — not a viable identity path (wave176).
  # G.7 有则补全 of the POSIX hybrid rest CC line + pure_ld_partial_merge:
  #   rest = host-cc seed under -DXLANG_RUNTIME_PIPELINE_ABI_FROM_X (3s, 220KiB)
  #          plus WIN_LEFTOVER_GROW_VEC so leftover-PE rest compiles seed
  #          ifndef-FROM_X cold twins POSIX .x thin -E would provide T:
  #          grow_vec/sidecar + wave123 glue_arm64_mov_*/lea + wave125
  #          pipeline_asm_ctx_layout + wave133 glue_enc_sxt/zxt (closed out
  #          of wave132 so WIN rest does not take ty_ref / append_bytes
  #          dual-decl) + wave273 F7 data-section (emit_data_len /
  #          append_data_u32_le / set_shndx_override; BSS moved before first
  #          use; rest of wave273 stays closed — append_bytes dual-decl) +
  #          wave74 driver_dep_* + wave77 typeck_ndep/sidecar + wave73
  #          pipeline_diag_* + path wrappers (import_path_to_file_path /
  #          get_entry_dir / cstr_ends_with_dot_x / import_path_is_file_path /
  #          path_try_realpath_inplace / resolve_file_import_path /
  #          resolve_import_file_path_multi; _impl already always compiled) +
  #          wave67 path_bufs_reset / copy_entry_dir / fill_ctx_path_buffers /
  #          pctx_seed_dep_slots / pctx_seed_dep_import_paths_only /
  #          pctx_update_dep_slots_no_reset / set_use_asm_backend +
  #          wave68/70 entry_dir BSS+set/get + dep arena/module slots
  #          (set_dep_slots / get_dep_arena_slot; independent ifndefs) +
  #          is_object/_magic + fclose_asm_out cluster (fp_is_stdout /
  #          fclose_file; independent ifndefs) + user_std_net/skip_typeck
  #          cluster (std_dep_skip_x_typeck / std_net_dep_path /
  #          std_io_driver_dep_path / dep_parse_skip_typeck_path;
  #          independent ifndefs; wrappers call always-extern pipeline.x
  #          faces; leftover standalone defines 0 of remaining unique) +
  #          dep_prerun_entry_dir + _pick (independent ifndefs; entry_dir
  #          calls _pick; leftover standalone defines 0 of remaining unique) +
  #          merge_deps_path_already_out + _scan + merge_direct_then_transitive
  #          deps / dep_paths (independent ifndefs; wrappers call always-
  #          compiled _impl; _impl already calls already_out; leftover
  #          standalone defines 0 of remaining unique) +
  #          one_ctx_for_dep_prerun + map_impl + find_loaded_import_index +
  #          _scan (independent ifndefs; wrapper calls always-compiled _impl;
  #          _impl already calls map_impl; map_impl calls find_loaded_import_index
  #          which calls _scan; leftover standalone defines 0 of remaining unique) +
  #          load_direct_imports_for_asm_layout + _impl + module_num_imports +
  #          load_one_direct_resolve_read_preprocess + load_one_direct_import_at +
  #          load_direct_fail_cleanup + preprocess_raw_to_malloc / _impl
  #          (independent ifndefs; unlike merge/one_ctx, _impl is still ifndef —
  #          convert it with the wrapper; resolve_read calls already-OR'd path
  #          wrappers / pipeline_diag plus preprocess_raw_to_malloc; leftover
  #          standalone defines 0 of remaining unique) +
  #          public xlang_preprocess / with_path / quiet (one independent
  #          ifndef; wrappers call already-T _impl; leftover rest compiles
  #          with XLANG_USE_X_PIPELINE so LEGACY preprocess_c_fallback #else
  #          is not parsed; unique lists preprocess + with_path; leftover
  #          standalone defines 0 of remaining unique) +
  #          xlang_lsp_free_loaded_imports (independent ifndef; wrapper
  #          calls already-T _impl with void**; header struct ast_Module **
  #          @304 is prototype+definition, not a dual-decl; leftover
  #          standalone defines 0 of remaining unique; do not convert
  #          neighboring xlang_lsp_ptr_slot_clear — not unique) +
  #          collect leftover cluster (12 independent ifndefs: strdup /
  #          to_load_has / seed_to_load / enqueue_module_imports /
  #          tmp_parse_and_enqueue / deps_process_one / deps_transitive_impl /
  #          deps_transitive / paths_tmp_resolve_parse_enqueue /
  #          paths_process_one / dep_paths_transitive_impl /
  #          dep_paths_transitive; unlike merge/one_ctx, _impl is still
  #          ifndef — convert with the wrapper; wrappers call _impl;
  #          _impl calls seed_to_load + process_one; process_one calls
  #          already-OR'd load_one_direct_import_at + find_loaded_import_index
  #          + tmp_parse; unique lists deps_transitive + dep_paths_transitive;
  #          leftover standalone defines 0 of remaining unique; do not
  #          convert neighboring xlang_driver_asm_prepare_entry_elf_emit —
  #          it calls closed debug_trace) +
  #          dep_prerun leftover cluster (6 independent ifndefs: thread_fn
  #          impl+wrapper / large_stack impl+wrapper / parse_skip
  #          impl+wrapper / typeck_only impl+wrapper / parse_only
  #          impl+wrapper / for_asm_module_o; unlike merge/one_ctx, _impl
  #          is still ifndef — convert with the wrapper; parse_skip_impl
  #          calls large_stack; large_stack_impl calls thread_fn;
  #          thread_fn_impl calls always-extern pipeline_run_x_pipeline;
  #          unique lists thread_fn + large_stack + four dep_prerun
  #          wrappers; leftover standalone defines 0 of remaining unique;
  #          do not convert neighboring pipeline_run_x_thread_fn_ptr —
  #          not unique — or xlang_asm_codegen_elf_o_product_emit /
  #          thread_fn_ptr — not unique; elf_o leftover cluster converts
  #          thread_fn+large_stack only — or
  #          xlang_driver_asm_prepare_entry_elf_emit — calls closed
  #          debug_trace; pipeline_run_x_pipeline_impl is a separate
  #          leftover cluster after closing enclosing wave101) +
  #          elf_o leftover cluster (2 independent ifndefs: thread_fn
  #          impl+wrapper / large_stack impl+wrapper; unlike merge/one_ctx,
  #          _impl is still ifndef — convert with the wrapper; thread_fn_impl
  #          calls always-extern asm_asm_codegen_elf_o; large_stack_impl
  #          calls thread_fn + driver_run_thread_on_large_stack; unique
  #          lists thread_fn + large_stack; leftover standalone defines 0
  #          of remaining unique; do not convert neighboring
  #          xlang_asm_codegen_elf_o_product_emit / thread_fn_ptr — not
  #          unique — or xlang_driver_asm_prepare_entry_elf_emit — calls
  #          closed debug_trace) +
  #          glue_type leftover cluster (surgical extract at start of
  #          independent wave154 ifndef: size_simple + align_simple +
  #          helpers empty_struct / layout_metrics / w154_layout_name_eq;
  #          unique lists size_simple + align_simple; leftover standalone
  #          defines 0 of remaining unique; glue_vector_type_lanes_esz_c
  #          stays closed — not unique — leftover rest externs it; do not
  #          convert neighboring typeck_typeck_struct_layout_metrics — not
  #          unique — or glue_type_named_layout_size_any_module_elf_c —
  #          nested in wave178) +
  #          rec leftover cluster (surgical extract of inner wave152
  #          ifndef after closing enclosing wave149: rec + lit_i32 /
  #          match_subject_field / emit_expr_elf_c wrapper / emit_expr_elf_fast;
  #          rec calls fast — convert together; unique lists rec; leftover
  #          standalone defines 0 of remaining unique; wave149 binop helpers
  #          stay closed; wave153 block_body stays its own ifndef) +
  #          append_reloc leftover cluster (surgical extract of nested
  #          wave273 after closing enclosing wave154/wave178/wave273
  #          reopen-after-F7: pipeline_elf_ctx_append_reloc_absolute64
  #          only; unique lists absolute64; leftover standalone defines 0
  #          of remaining unique; callee append_reloc_typed stays closed —
  #          not unique — leftover rest U it; SAT / leftover standalone
  #          provide T; do not convert neighboring append_reloc / typed —
  #          not unique — or reloc_sym_name_ptr — not unique — or
  #          glue_type_named_layout_size_any_module_elf_c — nested in
  #          wave178 stub) +
  #          sret leftover cluster (surgical extract of nested wave223
  #          after closing enclosing wave154 reopen-after-glue_type +
  #          wave178: three sret setters + getters sharing BSS cells;
  #          unique lists the three setters; leftover standalone defines
  #          0 of remaining unique; getters not unique — SAT / leftover
  #          standalone provide T; convert together so setters have a
  #          cell; do not convert neighboring wave222 module/dep_pipe —
  #          not unique — or named_layout — seed body is a stub — or
  #          pipeline_module_*_storage_* — nested wave178 sidecar) +
  #          pipeline_run_x_pipeline_impl leftover cluster (surgical
  #          extract after closing enclosing wave101: impl only; unique
  #          lists impl; leftover standalone defines 0 of remaining unique;
  #          callees parse_entry/load_deps/typecheck/codegen wrappers not
  #          unique — SAT / leftover standalone provide T; do not convert
  #          neighboring driver_emit_lib_root_release — nested wave101
  #          sidecar BSS) +
  #          modlet leftover cluster (surgical extract of nested wave139
  #          after closing enclosing wave136: four unique prepare/seed/
  #          register/lit_inits faces + BSS g_pipeline_asm_modlet_cold +
  #          helpers name_is_shared/load/store; unique lists the four;
  #          leftover standalone defines 0 of remaining unique; name_is_shared
  #          / load / store not unique — SAT / leftover standalone provide T;
  #          convert together so unique faces have a cell; do not convert
  #          neighboring wave140 index — not unique) +
  #          array_lit leftover cluster (surgical extract of nested wave143
  #          unique after closing enclosing remaining wave136:
  #          pipeline_asm_array_lit_elem_byte_sz_c + helper
  #          pipeline_asm_array_lit_elem_type_ref; unique lists
  #          elem_byte_sz_c; leftover standalone defines 0 of remaining
  #          unique; elem_type_ref not unique — SAT / leftover standalone
  #          provide T; convert together so unique has a helper; do not
  #          convert neighboring wave140 index — not unique — or remaining
  #          wave143 emit/empty/force_esz — not unique) +
  #          stack_off leftover unique (surgical extract of nested wave148
  #          unique after closing enclosing remaining wave136:
  #          glue_asm_local_var_stack_off_scoped; unique lists this face;
  #          leftover standalone defines 0 of remaining unique; callees
  #          var_name_len/into leftover rest already T; find_offset_scoped
  #          leftover rest already T uint8_t*; find_offset leftover rest U —
  #          SAT / leftover standalone provide T; do not convert neighboring
  #          remaining wave143 emit/empty/force_esz — not unique — or
  #          remaining wave148 vector-lane emit — not unique) +
  #          glue_func_return leftover unique (surgical extract of nested
  #          wave192 unique after closing enclosing wave154 reopen-after-
  #          glue_type + wave178 INDEX-peel: glue_func_return_byte_size_c;
  #          unique lists this face; leftover standalone defines 0 of
  #          remaining unique; seed body was a stub return 0 — port the
  #          real .x body instead of OR'ing the stub; callees size_simple
  #          leftover rest already T; kind_ord leftover rest already extern
  #          void*; num_funcs always-compiled void* — do not re-extern;
  #          func_return_type_at leftover rest T later so extract carries
  #          a void* extern; leftover rest U num_funcs — SAT / leftover
  #          standalone provide T; do not convert neighboring dual_gp /
  #          param_home_width — not unique) +
  #          named_layout leftover unique (surgical extract of nested
  #          wave191 unique after closing enclosing wave154 reopen-after-
  #          glue_type + wave178 INDEX-peel: glue_type_named_layout_size_any_module_elf_c;
  #          unique lists this face; leftover standalone defines 0 of
  #          remaining unique; seed body was a stub return 0 — port the
  #          real .x body instead of OR'ing the stub; callees leftover rest
  #          already T/extern from glue_type + array_lit clusters; ndep
  #          always-compiled struct* — do not re-extern; leftover rest U
  #          emit_module_ref_c / emit_dep_pipe_c defs — SAT / leftover
  #          standalone provide T; do not convert neighboring pass_addr /
  #          dual_gp / param_home_width — not unique) +
  #          glue_call_return leftover unique (surgical extract of nested
  #          wave194 unique after closing enclosing wave154 reopen-after-
  #          glue_type + wave178 INDEX-peel: glue_call_return_byte_size_c;
  #          unique lists this face; leftover standalone defines 0 of
  #          remaining unique; seed body was a stub return -1 — port the
  #          real .x body instead of OR'ing the stub; callees size_simple
  #          leftover rest already T; kind_ord / func_return_type_at /
  #          emit_dep_pipe / emit_module_ref leftover rest already extern;
  #          extract carries resolve + get_dep_return_type void* externs;
  #          leftover rest U glue_asm_resolve — SAT / leftover standalone
  #          provide T; do not convert neighboring param_agg / load_var /
  #          wave195–199 — not unique — or glue_asm_resolve — seed stub) +
  #          type_alias leftover unique (surgical extract of nested
  #          wave262 unique after closing enclosing wave154 reopen-after-
  #          sret + wave178 INDEX-peel: pipeline_module_type_alias_storage_reset
  #          / storage_release; unique lists these two faces; leftover
  #          standalone defines 0 of remaining unique; seed bodies are
  #          real — convert unique + BSS + find_slot together so leftover
  #          rest WAVE279 ast_pool_module_reset/release has a cell;
  #          remaining wave262 alloc/set/getters stay closed on leftover
  #          rest — not unique; SAT / leftover standalone provide T; do
  #          not convert neighboring wave224 / wave261 — not unique) +
  #          enum leftover unique (surgical extract of nested wave264
  #          unique after closing enclosing wave154 reopen-after-
  #          type_alias + wave178 INDEX-peel: pipeline_module_enum_storage_reset
  #          / storage_release; unique lists these two faces; leftover
  #          standalone defines 0 of remaining unique; seed bodies are
  #          real — convert unique + BSS + find_slot + header_n/set_header_n
  #          together so leftover rest WAVE279 ast_pool_module_reset/release
  #          has a cell; remaining wave264 alloc/set/getters stay closed
  #          on leftover rest — not unique; SAT / leftover standalone
  #          provide T; do not convert neighboring wave263 import — not
  #          unique — or remaining tl/sl unique — own extracts) +
  #          top_level_let leftover unique (surgical extract of nested
  #          wave265 unique after closing enclosing wave154 reopen-after-
  #          enum + wave178 INDEX-peel: pipeline_module_top_level_let_storage_reset
  #          / storage_release; unique lists these two faces; leftover
  #          standalone defines 0 of remaining unique; seed bodies are
  #          real — convert unique + BSS + find_slot + header_n/set_header_n
  #          together so leftover rest WAVE279 ast_pool_module_reset/release
  #          has a cell; remaining wave265 alloc/set/getters stay closed
  #          on leftover rest — not unique; SAT / leftover standalone
  #          provide T; do not convert neighboring remaining wave264
  #          alloc/set — not unique — or remaining sl unique — own extract) +
  #          struct_layout leftover unique (surgical extract of nested
  #          wave266 unique after closing enclosing wave154 reopen-after-
  #          tl + wave178 INDEX-peel: pipeline_module_struct_layout_storage_reset
  #          / storage_release; unique lists these two faces; leftover
  #          standalone defines 0 of remaining unique; seed bodies are
  #          real — convert unique + BSS + find_slot + header_n/set_header_n
  #          together so leftover rest WAVE279 ast_pool_module_reset/release
  #          has a cell; remaining wave266 alloc/set/getters stay closed
  #          on leftover rest — not unique; SAT / leftover standalone
  #          provide T; do not convert neighboring remaining wave265
  #          alloc/set — not unique) +
  #          block_diverged leftover unique (independent ifndef after
  #          lsp_free; no seed twin in wave213 cluster: glue_asm_block_diverged_set
  #          + getter + BSS together so leftover rest SET/GET share leftover
  #          rest BSS; unique lists setter only — leftover standalone already
  #          T getter; leftover standalone defines 0 of remaining unique;
  #          port from .x @77841/@77856; do not add faces to wave213 cluster
  #          — cold full seed compiles this OR; a second def would dual-def
  #          in the same TU) +
  #          driver_emit leftover unique (surgical extract of nested
  #          wave104 emit sidecar after closing enclosing wave101:
  #          driver_emit_lib_root_release + reset/append/count/len/copy +
  #          BSS + find together so leftover rest SET/GET/release share
  #          leftover rest BSS; unique lists release only — leftover
  #          standalone already T reset/append; leftover standalone
  #          defines 0 of remaining unique; seed bodies are real; do not
  #          convert neighboring asm_qual_sym_layer_* — not unique,
  #          separate BSS family) +
  #          debug_trace leftover unique (independent ifndefs: match +
  #          impl + wrapper together so leftover rest wrapper calls
  #          leftover rest impl; unique lists wrapper only; leftover
  #          standalone defines 0 of remaining unique; leftover rest
  #          FROM_X proto @49851 is void* — the struct* extern @18600
  #          is inside FALSE #ifndef FROM_X wave144/145 nest, not a
  #          leftover-rest dual-decl; do not convert neighboring
  #          pipeline_asm_debug_enabled / mega_pre_reset wrappers —
  #          not unique) +
  #          prepare_entry leftover unique (independent ifndef: unique
  #          lists xlang_driver_asm_prepare_entry_elf_emit; leftover
  #          standalone defines 0 of remaining unique; header @292
  #          prototype+definition; calls leftover rest T debug_trace;
  #          do not convert neighboring product_emit / thread_fn_ptr —
  #          not unique; pabi leftover unique coding is exhausted
  #          after this extract).
  #          pipeline_resolve_path / read_file stay closed this wave.
  #          FROM_X rest otherwise only externs them.
  #   thin = leftover build_asm/pipeline_glue_standalone.o (7/31 archaeology;
  #          ASM_GLUE_STANDALONE_O is empty on product; this file is the only
  #          on-disk provider of pipeline_type_* / ast_pool_* ifndef-FROM_X
  #          twins when PE cannot -E; it does NOT define grow_vec/sidecar)
  # Merge rest-first so tip FROM_X wins overlaps; leftover fills missing twins.
  # POSIX (Linux gold / Darwin): FORCE hybrid -E stays the product path.
  if pipeline_abi_windows_leftover_pe_cannot_e; then
    local win_rest win_thin win_sz win_e win_egg_o win_e_tmp
    # PLATFORM: WINDOWS — PE-egg substitute = Darwin -E thin (windows_e.c)
    # product bodies + FROM_X rest (Cap trampolines / #ifndef FROM_X twins).
    # Egg alone leaves ~300 Cap/twin UNDEFs; rest alone misses mega product
    # bodies. Merge rest-first (allow-multiple) so Cap/twins win overlaps.
    win_e="seeds/runtime_pipeline_abi.windows_e.c"
    if [ -f "$win_e" ]; then
      mkdir -p "$(dirname "$o")"
      # PLATFORM: WINDOWS — keep merged egg+FROM_X (>=1.5MB) under sat try-heat
      # when FORCE!=1. MinGW mtime is unreliable; mktemp .c required.
      # XLANG_HOST_CC_SEED_FORCE=1 must rebuild (pipe_elf_off / stub fixes).
      if [ "${FORCE:-0}" != "1" ] && [ -s "$o" ]; then
        win_sz=$(wc -c <"$o" | tr -d ' ')
        if [ -n "$win_sz" ] && [ "$win_sz" -gt 1500000 ]; then
          log "pipeline_abi prefer: keep Windows egg+FROM_X $o (${win_sz}B)"
          return 0
        fi
      fi
      log "pipeline_abi prefer: Windows egg+FROM_X host-cc $win_e + $seed → $o"
      # BusyBox/w64 mktemp: XXXXXX is suffix; gcc -c needs .c
      _t="$(mktemp "${TMPDIR:-/tmp}/pabi_win_e.XXXXXX")" || return 1
      win_e_tmp="${_t}.c"
      mv "$_t" "$win_e_tmp" || return 1
      win_egg_o="$(mktemp "${TMPDIR:-/tmp}/pabi_win_egg.XXXXXX")"
      win_rest="$(mktemp "${TMPDIR:-/tmp}/pabi_win_rest.XXXXXX")"
      # Strip mmap/munmap externs that clash with win32_compat.h inline shims.
      sed -e "/extern .*[ ]munmap(/d" -e "/extern .*[ ]mmap(/d" "$win_e" >"$win_e_tmp" \
        || { rm -f "$win_e_tmp" "$win_egg_o" "$win_rest"; return 1; }
      # shellcheck disable=SC2086
      if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_USE_X_PIPELINE \
           $(host_cc_win_compat_cflags) -Wno-pointer-sign -c -o "$win_egg_o" "$win_e_tmp"; then
        echo "ensure_host_cc_seed_o: Windows egg-thin cc failed for $o" >&2
        rm -f "$win_e_tmp" "$win_egg_o" "$win_rest"
        return 1
      fi
      rm -f "$win_e_tmp"
      # shellcheck disable=SC2086
      if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_USE_X_PIPELINE \
           -DXLANG_RUNTIME_PIPELINE_ABI_FROM_X \
           -DXLANG_RUNTIME_PIPELINE_ABI_WIN_LEFTOVER_GROW_VEC \
           $(host_cc_win_compat_cflags) -Wno-pointer-sign -c -o "$win_rest" "$seed"; then
        echo "ensure_host_cc_seed_o: Windows FROM_X rest cc failed for $o" >&2
        rm -f "$win_egg_o" "$win_rest"
        return 1
      fi
      if ! pure_ld_partial_merge "$o" "$win_rest" "$win_egg_o"; then
        echo "ensure_host_cc_seed_o: Windows egg+FROM_X merge failed for $o" >&2
        rm -f "$win_egg_o" "$win_rest"
        return 1
      fi
      rm -f "$win_egg_o" "$win_rest"
      # Thin windows_e extras first. asm_wpo AFTER stubs (below) so PE ld -r
      # last-wins keeps real emit_order_* (stub -1 was CG002 empty root).
      for win_extra in         seeds/runtime_pipeline_abi_elf_ctx.windows_e.c         seeds/runtime_pipeline_abi_assign_emit.windows_e.c         seeds/runtime_pipeline_abi_modlet.windows_e.c; do
        [ -f "$win_extra" ] || continue
        win_xo="$(mktemp "${TMPDIR:-/tmp}/pabi_win_x.XXXXXX")"
        _t="$(mktemp "${TMPDIR:-/tmp}/pabi_win_xt.XXXXXX")" || return 1
        win_xt="${_t}.c"
        mv "$_t" "$win_xt" || return 1
        win_mo="$(mktemp "${TMPDIR:-/tmp}/pabi_win_mo.XXXXXX")"
        sed -e "/extern .*[ ]munmap(/d" -e "/extern .*[ ]mmap(/d" "$win_extra" >"$win_xt"           || { rm -f "$win_xo" "$win_xt" "$win_mo"; return 1; }
        # shellcheck disable=SC2086
        if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_USE_X_PIPELINE              $(host_cc_win_compat_cflags) -Wno-pointer-sign -c -o "$win_xo" "$win_xt"; then
          echo "ensure_host_cc_seed_o: Windows extra cc failed: $win_extra" >&2
          rm -f "$win_xo" "$win_xt" "$win_mo"
          return 1
        fi
        rm -f "$win_xt"
        if ! pure_ld_partial_merge "$win_mo" "$o" "$win_xo"; then
          echo "ensure_host_cc_seed_o: Windows extra merge failed: $win_extra" >&2
          rm -f "$win_xo" "$win_mo"
          return 1
        fi
        mv -f "$win_mo" "$o"
        rm -f "$win_xo"
      done
      win_stub="seeds/runtime_pipeline_abi.windows_link_stubs.c"
      if [ -f "$win_stub" ]; then
        win_stub_o="$(mktemp "${TMPDIR:-/tmp}/pabi_win_stub.XXXXXX")"
        win_mo="$(mktemp "${TMPDIR:-/tmp}/pabi_win_mo.XXXXXX")"
        # shellcheck disable=SC2086
        if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc $(host_cc_win_compat_cflags)              -c -o "$win_stub_o" "$win_stub"; then
          echo "ensure_host_cc_seed_o: Windows link-stubs cc failed for $o" >&2
          rm -f "$win_stub_o" "$win_mo"
          return 1
        fi
        if ! pure_ld_partial_merge "$win_mo" "$o" "$win_stub_o"; then
          echo "ensure_host_cc_seed_o: Windows link-stubs merge failed for $o" >&2
          rm -f "$win_stub_o" "$win_mo"
          return 1
        fi
        mv -f "$win_mo" "$o"
        rm -f "$win_stub_o"
      fi
      # asm_wpo emit_order AFTER stubs (PE last-wins / FIRST both safe with identity stubs).
      win_extra="seeds/runtime_pipeline_abi_asm_wpo.from_x.c"
      if [ -f "$win_extra" ]; then
        win_xo="$(mktemp "${TMPDIR:-/tmp}/pabi_win_x.XXXXXX")"
        _t="$(mktemp "${TMPDIR:-/tmp}/pabi_win_xt.XXXXXX")" || return 1
        win_xt="${_t}.c"
        mv "$_t" "$win_xt" || return 1
        win_mo="$(mktemp "${TMPDIR:-/tmp}/pabi_win_mo.XXXXXX")"
        sed -e "/extern .*[ ]munmap(/d" -e "/extern .*[ ]mmap(/d" "$win_extra" >"$win_xt"           || { rm -f "$win_xo" "$win_xt" "$win_mo"; return 1; }
        # shellcheck disable=SC2086
        if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_USE_X_PIPELINE              $(host_cc_win_compat_cflags) -Wno-pointer-sign -c -o "$win_xo" "$win_xt"; then
          echo "ensure_host_cc_seed_o: WARN skip asm_wpo (identity emit_order stubs remain)" >&2
          rm -f "$win_xo" "$win_xt" "$win_mo"
          win_xo=""
        fi
        rm -f "$win_xt"
        if [ -n "$win_xo" ] && [ -s "$win_xo" ]; then
          if ! pure_ld_partial_merge "$win_mo" "$o" "$win_xo"; then
            echo "ensure_host_cc_seed_o: WARN asm_wpo merge failed (identity stubs remain)" >&2
            rm -f "$win_xo" "$win_mo"
          else
            mv -f "$win_mo" "$o"
            rm -f "$win_xo"
          fi
        fi
      fi
      win_sz=$(wc -c <"$o" | tr -d ' ')
      log "prefer Windows egg+FROM_X+extras $o (${win_sz:-0}B)"
      return 0
    fi
    win_thin="build_asm/pipeline_glue_standalone.o"
    mkdir -p "$(dirname "$o")"
    # Keep a prior good cold hybrid unless FORCE (sat rebuild must not wipe it).
    if [ "${FORCE:-0}" != "1" ] && [ -s "$o" ]; then
      win_sz=$(wc -c <"$o" | tr -d ' ')
      if [ -n "$win_sz" ] && [ "$win_sz" -gt 100000 ]; then
        log "pipeline_abi prefer: keep existing Windows hybrid $o (${win_sz}B)"
        return 0
      fi
    fi
    if [ ! -s "$win_thin" ]; then
      # wave309 retired product glue floor; Windows cold still needs the thin twin
      # for FROM_X rest merge (seed restored under seeds/ + pipeline_glue.c).
      # PLATFORM: WINDOWS — build seed-map thin then continue hybrid merge.
      local _gs _gx
      _gs="$(seed_for_seed_map "$win_thin")"
      _gx="$(extras_for_seed_map "$win_thin")"
      if [ ! -f "$_gs" ]; then
        echo "ensure_host_cc_seed_o: Windows leftover PE cannot -E; missing $win_thin and seed $_gs" >&2
        return 1
      fi
      log "pipeline_abi prefer: cold-build $win_thin from $_gs (Win archaeology twin)"
      # Direct cc — avoid nested re-parse of this script via ensure_one (MinGW bash
      # spends minutes parsing 17k lines). PLATFORM: WINDOWS cold bootstrap.
      if [ -f scripts/ensure_pipeline_glue_types.sh ]; then
        bash scripts/ensure_pipeline_glue_types.sh >/dev/null 2>&1 || true
      fi
      # shellcheck disable=SC2086
      if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Ibuild_asm -Wno-error=return-type \
           $_gx $(host_cc_win_compat_cflags) -c -o "$win_thin" "$_gs"; then
        echo "ensure_host_cc_seed_o: Windows cold-build $win_thin failed" >&2
        return 1
      fi
    fi
    win_rest="$(mktemp "${TMPDIR:-/tmp}/pabi_win_rest.XXXXXX")"
    log "pipeline_abi prefer: leftover PE cannot -E mega; host-cc FROM_X rest + grow_vec/sidecar twins + leftover standalone thin"
    # shellcheck disable=SC2086
    if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_USE_X_PIPELINE \
         -DXLANG_RUNTIME_PIPELINE_ABI_FROM_X \
         -DXLANG_RUNTIME_PIPELINE_ABI_WIN_LEFTOVER_GROW_VEC \
         -c -o "$win_rest" "$seed"; then
      echo "ensure_host_cc_seed_o: Windows FROM_X rest cc failed for $o" >&2
      rm -f "$win_rest"
      return 1
    fi
    if ! pure_ld_partial_merge "$o" "$win_rest" "$win_thin"; then
      echo "ensure_host_cc_seed_o: Windows rest+standalone merge failed for $o" >&2
      rm -f "$win_rest"
      return 1
    fi
    rm -f "$win_rest"
    # PLATFORM: WINDOWS — thin mega / thin wrapper keep relative calls to thin
    # twins (PE first-wins does not rewrite intra-object). Rest WIN_LEFTOVER:
    # get_return/nso/body_ref + WAVE290 mega_body void-main mov-imm-0.
    # G.7: one post-merge redirect script (proved by return-42 / void-main).
    if ! bash scripts/win_pe_pabi_redirect_return_helpers.sh "$o"; then
      echo "ensure_host_cc_seed_o: Windows thin→rest return-helper redirect failed for $o" >&2
      return 1
    fi
    win_sz=$(wc -c <"$o" | tr -d ' ')
    log "prefer Windows leftover-PE hybrid $o <- FROM_X rest + grow_vec/sidecar + $win_thin (${win_sz:-0}B) + return-helper redirect"
    return 0
  fi

  mkdir -p "$(dirname "$o")"

  # Hybrid thin+rest whenever a pin/product egg exists.
  # PLATFORM: SHARED — L4 root fix: sat rebuild forces XLANG_G05_PREFER_X_O=0
  # (-B). Historical gate only hybrid-ed when PREFER=1, so sat re-entered cold
  # full seed (void*/struct* dual decls) and **wiped** a good hybrid .o from
  # ensure_prereqs → pure-ld phase1 missing src/runtime_pipeline_abi.o.
  # Cold full seed is not a viable identity path until seed dual-decls are
  # cleaned; egg hybrid is the single working product cold path for this leaf.
  # PLATFORM: WINDOWS — leftover PE cannot -E; skip this block (predicate).
  if [ -f "$x_src" ] \
    && ! pipeline_abi_windows_leftover_pe_cannot_e \
    && { [ -x ./xlang ] || [ -x ./xlang-c ] || [ -x ./bootstrap_xlangc ]; }; then
    thin_o="$(mktemp "${TMPDIR:-/tmp}/pabi_thin.XXXXXX")"
    rest_o="$(mktemp "${TMPDIR:-/tmp}/pabi_rest.XXXXXX")"
    # WEAK pure thin: Darwin ld -r tolerates residual pure-dup still in rest.
    # Stage 12.0.5: force XLANG_PREFER_ASM_O_RT=0 — opaque freestanding surface
    # closed (WEAK on driver_abi bag) but mega pure monofile still incomplete
    # (Cap residual only in seed rest). Basename ban + RT=0 keep product -E hybrid.
    # PLATFORM: SHARED · G.7 call-site + pure_asm_x_to_o basename skip.
    # shellcheck disable=SC2086
    # w834: POSIX product rest does not host-cc ast_forwarders faces.
    # w835: same for typeck_orch (7 faces).
    # w836: same for elf_codegen_forwarders (19 faces).
    # Pure-asm thin inject supplies them. Windows / cold omit these macros.
    # PLATFORM: POSIX — WINDOWS keeps the C bodies (cannot -E tip thins).
    if XLANG_PREFER_ASM_O_RT=0 G05_X_O_WEAK=1 rt_prefer_try_x_to_o "$x_src" "$thin_o" \
      && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_USE_X_PIPELINE \
           -DXLANG_RUNTIME_PIPELINE_ABI_FROM_X \
           -DXLANG_RUNTIME_PIPELINE_ABI_MODLET_IN_REST \
           -DXLANG_PABI_AST_FORWARDERS_ASM \
           -DXLANG_PABI_TYPECK_ORCH_ASM \
           -DXLANG_PABI_ELF_CODEGEN_FORWARDERS_ASM \
           -c -o "$rest_o" "$seed" \
      && pure_ld_partial_merge "$o" "$thin_o" "$rest_o" 2>/dev/null; then
      # PLATFORM: MACOS — libtool -static fallback yields ar named .o; Cap LEA
      # and product force_load need a complete hybrid or cold MH_OBJECT, not a
      # thin+rest archive leftover. Discard and fall through to cold seed.
      # wave345: MODLET_IN_REST puts prepare/bake cold twin in FROM_X rest
      # (avoids mega -E for ordinal .data bake). PLATFORM: SHARED POSIX rest.
      if pipeline_abi_o_is_libtool_archive "$o"; then
        # Accept complete Darwin prefer archives (thin+rest); discard tiny leftovers.
        # Incomplete Cap residual was ~260KiB (fnptr_thin + pabi_rest_try only).
        local hyb_sz
        hyb_sz=$(wc -c <"$o" | tr -d ' ')
        if [ -n "$hyb_sz" ] && [ "$hyb_sz" -ge 1000000 ]; then
          log "prefer thin+rest $o <- $x_src + seed-rest (Darwin libtool archive ≥1MiB; prefer=${prefer})"
          done=1
        else
          log "pipeline_abi hybrid produced incomplete libtool archive (${hyb_sz:-0}B); discard → cold/seed"
          rm -f "$o"
          done=0
        fi
      else
        log "prefer thin+rest $o <- $x_src + seed-rest (try-pipeline-abi-prefer; prefer=${prefer}; pure-asm skip Cap-residual RT=0)"
        done=1
      fi
    else
      log "pipeline_abi hybrid failed; fallback full seed (prefer=${prefer})"
    fi
    rm -f "$thin_o" "$rest_o"
  fi

  if [ "$done" = "1" ]; then
    # 4.2.7: inject nested reent deep-copy esz fix without full mega -E.
    # Full runtime_pipeline_abi.x prefer -E is multi-minute / hang-prone (92k LOC);
    # thin leaf re-emits only glue_slice_let_reent_deep_copy_after_dual_gp_elf_c
    # (same body as mega pure leave) and first-wins ld -r over weak pure.
    pipeline_abi_inject_reent_deep_copy_thin "$o" || true
    pipeline_abi_inject_fixed_array_copy_thin "$o" || true
    pipeline_abi_inject_slot_bytes_thin "$o" || true
    pipeline_abi_inject_field_load_sz_thin "$o" || true
    pipeline_abi_inject_macho_write_thin "$o" || true
    pipeline_abi_inject_unused_hints_thin "$o" || true
      pipeline_abi_inject_wpo_dump_thin "$o" || true
    pipeline_abi_inject_type_to_c_repr_thin "$o" || true
    pipeline_abi_inject_binop_block_peel_thin "$o" || true
    pipeline_abi_inject_param_ptr_slot_thin "$o" || true
    pipeline_abi_inject_fnptr_as_thin "$o" || true
    pipeline_abi_inject_asm_expr_thin "$o" || true
    pipeline_abi_inject_fnptr_array_esz_thin "$o" || true
    pipeline_abi_inject_assign_thin "$o" || true
    pipeline_abi_inject_assign_index_thin "$o" || true
      pipeline_abi_inject_arr_lit_flat_thin "$o" || true
    pipeline_abi_inject_arr_return_thin "$o" || true
    pipeline_abi_inject_arr_struct_lit_thin "$o" || true
    pipeline_abi_inject_w157_sum_thin "$o" || true
    pipeline_abi_inject_binop_var_slot_cache_thin "$o" || true
    pipeline_abi_inject_binop_stack_spill_try_reload_thin "$o" || true
    pipeline_abi_inject_asm73_chaitin_thin "$o" || true
    pipeline_abi_inject_asm73_live_interf_thin "$o" || true
    pipeline_abi_inject_asm73_live_set_thin "$o" || true
    pipeline_abi_inject_for_call_args_thin "$o" || true
    pipeline_abi_inject_emit_index_thin "$o" || true
    pipeline_abi_inject_call_method_wrappers_thin "$o" || true
    pipeline_abi_inject_al_nc_seq_thin "$o" || true
    pipeline_abi_inject_emit_ctx_bss_thin "$o" || true
      pipeline_abi_inject_emit_ctx_func_index_thin "$o" || true
      pipeline_abi_inject_block_final_expr_thin "$o" || true
      pipeline_abi_inject_return_elf_impl_thin "$o" || true
      pipeline_abi_inject_emit_ctx_module_dep_thin "$o" || true
      pipeline_abi_inject_emit_ctx_sret_thin "$o" || true
      pipeline_abi_inject_typeck_active_thin "$o" || true
      pipeline_abi_inject_glue_statics_thin "$o" || true
      pipeline_abi_inject_type_alias_thin "$o" || true
      pipeline_abi_inject_module_import_thin "$o" || true
      pipeline_abi_inject_module_enum_thin "$o" || true
      pipeline_abi_inject_top_level_let_thin "$o" || true
      pipeline_abi_inject_modlet_thin "$o" || true
      pipeline_abi_inject_struct_layout_thin "$o" || true
      pipeline_abi_inject_asm_locals_thin "$o" || true
      pipeline_abi_inject_block_tree_thin "$o" || true
      pipeline_abi_inject_type_pool_thin "$o" || true
      pipeline_abi_inject_grow_vec_thin "$o" || true
      pipeline_abi_inject_dep_ctx_thin "$o" || true
      pipeline_abi_inject_elf_ctx_thin "$o" || true
      pipeline_abi_inject_const_lit_is_const "$o" || true
      pipeline_abi_inject_asm_wpo_cap "$o" || true
      pipeline_abi_inject_reloc_typed_page21 "$o" || true
      pipeline_abi_inject_data_len_dual_bss "$o" || true
      pipeline_abi_inject_asm_wpo_thin "$o" || true
      pipeline_abi_inject_sidecar_pool_thin "$o" || true
      pipeline_abi_inject_value_abi_thin "$o" || true
      pipeline_abi_inject_block_domain_thin "$o" || true
      pipeline_abi_inject_expr_sidecar_thin "$o" || true
      pipeline_abi_inject_lifecycle_thin "$o" || true
      pipeline_abi_inject_module_func_thin "$o" || true
      pipeline_abi_inject_onefunc_thin "$o" || true
      pipeline_abi_inject_bootstrap_glue_thin "$o" || true
      pipeline_abi_inject_ast_forwarders_thin "$o" || true
      pipeline_abi_inject_parse_orch_thin "$o" || true
      pipeline_abi_inject_typeck_orch_thin "$o" || true
      pipeline_abi_inject_typeck_check_expr_thin "$o" || true
      pipeline_abi_inject_parser_result_thin "$o" || true
      pipeline_abi_inject_asm_label_format_thin "$o" || true
      pipeline_abi_inject_codegen_outbuf_thin "$o" || true
      pipeline_abi_inject_asm_codegen_mega_body_thin "$o" || true
      pipeline_abi_inject_elf_codegen_forwarders_thin "$o" || true
    pipeline_abi_inject_preprocess_malloc_thin "$o" || true
    pipeline_abi_inject_import_heap_thin "$o" || true
    pipeline_abi_inject_read_file_x_view_thin "$o" || true
    return 0
  fi

  # Cold full seed (ensure_one twin) with XLANG_USE_X_PIPELINE — last resort only.
  # wave176: cold full seed currently fails type conflicts (void* vs struct*
  # dual decls in from_x). If hybrid failed but OUT still exists, keep it.
  # PLATFORM: SHARED freestanding product / sat rebuild safety.
  # Hard-fail when OUT is still missing — never return 0 with no leaf (L4 pure-ld).
  cold_flags="$(pipeline_abi_prefer_cflags)"
  # shellcheck disable=SC2086
  if [ -s "$o" ]; then
    # Cap residual (10.3.2): never "keep" an incomplete Darwin libtool archive.
    if pipeline_abi_o_is_libtool_archive "$o"; then
      local keep_sz
      keep_sz=$(wc -c <"$o" | tr -d ' ')
      if [ -z "$keep_sz" ] || [ "$keep_sz" -lt 1000000 ]; then
        log "pipeline_abi discard incomplete libtool archive $o (${keep_sz:-0}B); try cold seed (10.3.2)"
        rm -f "$o"
      else
        log "pipeline_abi keep Darwin libtool archive $o (${keep_sz}B ≥1MiB)"
        pipeline_abi_inject_reent_deep_copy_thin "$o" || true
        pipeline_abi_inject_fixed_array_copy_thin "$o" || true
        pipeline_abi_inject_slot_bytes_thin "$o" || true
        pipeline_abi_inject_field_load_sz_thin "$o" || true
        pipeline_abi_inject_macho_write_thin "$o" || true
        pipeline_abi_inject_unused_hints_thin "$o" || true
          pipeline_abi_inject_wpo_dump_thin "$o" || true
        pipeline_abi_inject_type_to_c_repr_thin "$o" || true
        pipeline_abi_inject_binop_block_peel_thin "$o" || true
        pipeline_abi_inject_param_ptr_slot_thin "$o" || true
        pipeline_abi_inject_fnptr_as_thin "$o" || true
        pipeline_abi_inject_asm_expr_thin "$o" || true
        pipeline_abi_inject_fnptr_array_esz_thin "$o" || true
        pipeline_abi_inject_assign_thin "$o" || true
        pipeline_abi_inject_assign_index_thin "$o" || true
      pipeline_abi_inject_arr_lit_flat_thin "$o" || true
        pipeline_abi_inject_arr_return_thin "$o" || true
        pipeline_abi_inject_arr_struct_lit_thin "$o" || true
        pipeline_abi_inject_w157_sum_thin "$o" || true
        pipeline_abi_inject_binop_var_slot_cache_thin "$o" || true
        pipeline_abi_inject_binop_stack_spill_try_reload_thin "$o" || true
        pipeline_abi_inject_asm73_chaitin_thin "$o" || true
        pipeline_abi_inject_asm73_live_interf_thin "$o" || true
        pipeline_abi_inject_asm73_live_set_thin "$o" || true
        pipeline_abi_inject_for_call_args_thin "$o" || true
        pipeline_abi_inject_emit_index_thin "$o" || true
        pipeline_abi_inject_call_method_wrappers_thin "$o" || true
        pipeline_abi_inject_al_nc_seq_thin "$o" || true
        pipeline_abi_inject_emit_ctx_bss_thin "$o" || true
      pipeline_abi_inject_emit_ctx_func_index_thin "$o" || true
      pipeline_abi_inject_block_final_expr_thin "$o" || true
      pipeline_abi_inject_return_elf_impl_thin "$o" || true
      pipeline_abi_inject_emit_ctx_module_dep_thin "$o" || true
      pipeline_abi_inject_emit_ctx_sret_thin "$o" || true
      pipeline_abi_inject_typeck_active_thin "$o" || true
      pipeline_abi_inject_glue_statics_thin "$o" || true
      pipeline_abi_inject_type_alias_thin "$o" || true
      pipeline_abi_inject_module_import_thin "$o" || true
      pipeline_abi_inject_module_enum_thin "$o" || true
      pipeline_abi_inject_top_level_let_thin "$o" || true
      pipeline_abi_inject_modlet_thin "$o" || true
      pipeline_abi_inject_struct_layout_thin "$o" || true
      pipeline_abi_inject_asm_locals_thin "$o" || true
      pipeline_abi_inject_block_tree_thin "$o" || true
      pipeline_abi_inject_type_pool_thin "$o" || true
      pipeline_abi_inject_grow_vec_thin "$o" || true
      pipeline_abi_inject_dep_ctx_thin "$o" || true
      pipeline_abi_inject_elf_ctx_thin "$o" || true
      pipeline_abi_inject_const_lit_is_const "$o" || true
      pipeline_abi_inject_asm_wpo_cap "$o" || true
      pipeline_abi_inject_reloc_typed_page21 "$o" || true
      pipeline_abi_inject_data_len_dual_bss "$o" || true
      pipeline_abi_inject_asm_wpo_thin "$o" || true
      pipeline_abi_inject_sidecar_pool_thin "$o" || true
      pipeline_abi_inject_value_abi_thin "$o" || true
      pipeline_abi_inject_block_domain_thin "$o" || true
      pipeline_abi_inject_expr_sidecar_thin "$o" || true
      pipeline_abi_inject_lifecycle_thin "$o" || true
      pipeline_abi_inject_module_func_thin "$o" || true
      pipeline_abi_inject_onefunc_thin "$o" || true
      pipeline_abi_inject_bootstrap_glue_thin "$o" || true
      pipeline_abi_inject_ast_forwarders_thin "$o" || true
      pipeline_abi_inject_parse_orch_thin "$o" || true
      pipeline_abi_inject_typeck_orch_thin "$o" || true
      pipeline_abi_inject_typeck_check_expr_thin "$o" || true
      pipeline_abi_inject_parser_result_thin "$o" || true
      pipeline_abi_inject_asm_label_format_thin "$o" || true
      pipeline_abi_inject_codegen_outbuf_thin "$o" || true
      pipeline_abi_inject_asm_codegen_mega_body_thin "$o" || true
      pipeline_abi_inject_elf_codegen_forwarders_thin "$o" || true
          pipeline_abi_inject_preprocess_malloc_thin "$o" || true
        pipeline_abi_inject_import_heap_thin "$o" || true
        pipeline_abi_inject_read_file_x_view_thin "$o" || true
        return 0
      fi
    else
      log "pipeline_abi skip cold wipe; keep existing $o (wave176; cold seed type conflicts)"
      pipeline_abi_inject_reent_deep_copy_thin "$o" || true
      pipeline_abi_inject_fixed_array_copy_thin "$o" || true
      pipeline_abi_inject_slot_bytes_thin "$o" || true
      pipeline_abi_inject_field_load_sz_thin "$o" || true
      pipeline_abi_inject_macho_write_thin "$o" || true
      pipeline_abi_inject_unused_hints_thin "$o" || true
        pipeline_abi_inject_wpo_dump_thin "$o" || true
      pipeline_abi_inject_type_to_c_repr_thin "$o" || true
      pipeline_abi_inject_binop_block_peel_thin "$o" || true
      pipeline_abi_inject_param_ptr_slot_thin "$o" || true
      pipeline_abi_inject_fnptr_as_thin "$o" || true
      pipeline_abi_inject_asm_expr_thin "$o" || true
      pipeline_abi_inject_fnptr_array_esz_thin "$o" || true
      pipeline_abi_inject_assign_thin "$o" || true
      pipeline_abi_inject_assign_index_thin "$o" || true
      pipeline_abi_inject_arr_lit_flat_thin "$o" || true
      pipeline_abi_inject_arr_return_thin "$o" || true
      pipeline_abi_inject_arr_struct_lit_thin "$o" || true
      pipeline_abi_inject_w157_sum_thin "$o" || true
      pipeline_abi_inject_binop_var_slot_cache_thin "$o" || true
      pipeline_abi_inject_binop_stack_spill_try_reload_thin "$o" || true
      pipeline_abi_inject_asm73_chaitin_thin "$o" || true
      pipeline_abi_inject_asm73_live_interf_thin "$o" || true
      pipeline_abi_inject_asm73_live_set_thin "$o" || true
      pipeline_abi_inject_for_call_args_thin "$o" || true
      pipeline_abi_inject_emit_index_thin "$o" || true
      pipeline_abi_inject_call_method_wrappers_thin "$o" || true
      pipeline_abi_inject_al_nc_seq_thin "$o" || true
      pipeline_abi_inject_emit_ctx_bss_thin "$o" || true
      pipeline_abi_inject_emit_ctx_func_index_thin "$o" || true
      pipeline_abi_inject_block_final_expr_thin "$o" || true
      pipeline_abi_inject_return_elf_impl_thin "$o" || true
      pipeline_abi_inject_emit_ctx_module_dep_thin "$o" || true
      pipeline_abi_inject_emit_ctx_sret_thin "$o" || true
      pipeline_abi_inject_typeck_active_thin "$o" || true
      pipeline_abi_inject_glue_statics_thin "$o" || true
      pipeline_abi_inject_type_alias_thin "$o" || true
      pipeline_abi_inject_module_import_thin "$o" || true
      pipeline_abi_inject_module_enum_thin "$o" || true
      pipeline_abi_inject_top_level_let_thin "$o" || true
      pipeline_abi_inject_modlet_thin "$o" || true
      pipeline_abi_inject_struct_layout_thin "$o" || true
      pipeline_abi_inject_asm_locals_thin "$o" || true
      pipeline_abi_inject_block_tree_thin "$o" || true
      pipeline_abi_inject_type_pool_thin "$o" || true
      pipeline_abi_inject_grow_vec_thin "$o" || true
      pipeline_abi_inject_dep_ctx_thin "$o" || true
      pipeline_abi_inject_elf_ctx_thin "$o" || true
      pipeline_abi_inject_const_lit_is_const "$o" || true
      pipeline_abi_inject_asm_wpo_cap "$o" || true
      pipeline_abi_inject_reloc_typed_page21 "$o" || true
      pipeline_abi_inject_data_len_dual_bss "$o" || true
      pipeline_abi_inject_asm_wpo_thin "$o" || true
      pipeline_abi_inject_sidecar_pool_thin "$o" || true
      pipeline_abi_inject_value_abi_thin "$o" || true
      pipeline_abi_inject_block_domain_thin "$o" || true
      pipeline_abi_inject_expr_sidecar_thin "$o" || true
      pipeline_abi_inject_lifecycle_thin "$o" || true
      pipeline_abi_inject_module_func_thin "$o" || true
      pipeline_abi_inject_onefunc_thin "$o" || true
      pipeline_abi_inject_bootstrap_glue_thin "$o" || true
      pipeline_abi_inject_ast_forwarders_thin "$o" || true
      pipeline_abi_inject_parse_orch_thin "$o" || true
      pipeline_abi_inject_typeck_orch_thin "$o" || true
      pipeline_abi_inject_typeck_check_expr_thin "$o" || true
      pipeline_abi_inject_parser_result_thin "$o" || true
      pipeline_abi_inject_asm_label_format_thin "$o" || true
      pipeline_abi_inject_codegen_outbuf_thin "$o" || true
      pipeline_abi_inject_asm_codegen_mega_body_thin "$o" || true
      pipeline_abi_inject_elf_codegen_forwarders_thin "$o" || true
      pipeline_abi_inject_preprocess_malloc_thin "$o" || true
      pipeline_abi_inject_import_heap_thin "$o" || true
      pipeline_abi_inject_read_file_x_view_thin "$o" || true
      return 0
    fi
  fi
  if ! ensure_one "$o" "$seed" $cold_flags; then
    echo "ensure_host_cc_seed_o: pipeline_abi cold seed failed and no hybrid $o" >&2
    echo "  need: pin egg (./xbuild bootstrap-driver-seed installs select_bootstrap)" >&2
    return 1
  fi
  if [ ! -s "$o" ]; then
    echo "ensure_host_cc_seed_o: pipeline_abi ensure finished without $o" >&2
    return 1
  fi
  pipeline_abi_inject_reent_deep_copy_thin "$o" || true
  pipeline_abi_inject_fixed_array_copy_thin "$o" || true
  pipeline_abi_inject_slot_bytes_thin "$o" || true
  pipeline_abi_inject_field_load_sz_thin "$o" || true
  pipeline_abi_inject_macho_write_thin "$o" || true
  pipeline_abi_inject_unused_hints_thin "$o" || true
      pipeline_abi_inject_wpo_dump_thin "$o" || true
  pipeline_abi_inject_type_to_c_repr_thin "$o" || true
  pipeline_abi_inject_binop_block_peel_thin "$o" || true
  pipeline_abi_inject_param_ptr_slot_thin "$o" || true
  pipeline_abi_inject_fnptr_as_thin "$o" || true
  pipeline_abi_inject_asm_expr_thin "$o" || true
  pipeline_abi_inject_fnptr_array_esz_thin "$o" || true
  pipeline_abi_inject_assign_thin "$o" || true
  pipeline_abi_inject_assign_index_thin "$o" || true
      pipeline_abi_inject_arr_lit_flat_thin "$o" || true
  pipeline_abi_inject_arr_return_thin "$o" || true
  pipeline_abi_inject_arr_struct_lit_thin "$o" || true
  pipeline_abi_inject_w157_sum_thin "$o" || true
  pipeline_abi_inject_binop_var_slot_cache_thin "$o" || true
  pipeline_abi_inject_binop_stack_spill_try_reload_thin "$o" || true
  pipeline_abi_inject_asm73_chaitin_thin "$o" || true
  pipeline_abi_inject_asm73_live_interf_thin "$o" || true
  pipeline_abi_inject_asm73_live_set_thin "$o" || true
  pipeline_abi_inject_for_call_args_thin "$o" || true
  pipeline_abi_inject_emit_index_thin "$o" || true
  pipeline_abi_inject_call_method_wrappers_thin "$o" || true
  pipeline_abi_inject_al_nc_seq_thin "$o" || true
  pipeline_abi_inject_emit_ctx_bss_thin "$o" || true
      pipeline_abi_inject_emit_ctx_func_index_thin "$o" || true
      pipeline_abi_inject_block_final_expr_thin "$o" || true
      pipeline_abi_inject_return_elf_impl_thin "$o" || true
      pipeline_abi_inject_emit_ctx_module_dep_thin "$o" || true
      pipeline_abi_inject_emit_ctx_sret_thin "$o" || true
      pipeline_abi_inject_typeck_active_thin "$o" || true
      pipeline_abi_inject_glue_statics_thin "$o" || true
      pipeline_abi_inject_type_alias_thin "$o" || true
      pipeline_abi_inject_module_import_thin "$o" || true
      pipeline_abi_inject_module_enum_thin "$o" || true
      pipeline_abi_inject_top_level_let_thin "$o" || true
      pipeline_abi_inject_modlet_thin "$o" || true
      pipeline_abi_inject_struct_layout_thin "$o" || true
      pipeline_abi_inject_asm_locals_thin "$o" || true
      pipeline_abi_inject_block_tree_thin "$o" || true
      pipeline_abi_inject_type_pool_thin "$o" || true
      pipeline_abi_inject_grow_vec_thin "$o" || true
      pipeline_abi_inject_dep_ctx_thin "$o" || true
      pipeline_abi_inject_elf_ctx_thin "$o" || true
      pipeline_abi_inject_const_lit_is_const "$o" || true
      pipeline_abi_inject_asm_wpo_cap "$o" || true
      pipeline_abi_inject_reloc_typed_page21 "$o" || true
      pipeline_abi_inject_data_len_dual_bss "$o" || true
      pipeline_abi_inject_asm_wpo_thin "$o" || true
      pipeline_abi_inject_sidecar_pool_thin "$o" || true
      pipeline_abi_inject_value_abi_thin "$o" || true
      pipeline_abi_inject_block_domain_thin "$o" || true
      pipeline_abi_inject_expr_sidecar_thin "$o" || true
      pipeline_abi_inject_lifecycle_thin "$o" || true
      pipeline_abi_inject_module_func_thin "$o" || true
      pipeline_abi_inject_onefunc_thin "$o" || true
      pipeline_abi_inject_bootstrap_glue_thin "$o" || true
      pipeline_abi_inject_ast_forwarders_thin "$o" || true
      pipeline_abi_inject_parse_orch_thin "$o" || true
      pipeline_abi_inject_typeck_orch_thin "$o" || true
      pipeline_abi_inject_typeck_check_expr_thin "$o" || true
      pipeline_abi_inject_parser_result_thin "$o" || true
      pipeline_abi_inject_asm_label_format_thin "$o" || true
      pipeline_abi_inject_codegen_outbuf_thin "$o" || true
      pipeline_abi_inject_asm_codegen_mega_body_thin "$o" || true
      pipeline_abi_inject_elf_codegen_forwarders_thin "$o" || true
  pipeline_abi_inject_preprocess_malloc_thin "$o" || true
  pipeline_abi_inject_import_heap_thin "$o" || true
  pipeline_abi_inject_read_file_x_view_thin "$o" || true
  return 0
}

# Generic first-wins thin inject into src/runtime_pipeline_abi.o (PLATFORM: SHARED).
# Thin .x body MUST match the same-named export in runtime_pipeline_abi.x;
# regenerate the thin when that function changes. First-wins ld -r: thin.o then pabi.o.
# G.7: one helper; 4.2.7 nested SLICE esz + dest-ARRAY [K][N]T memcpy both reuse it.
# True if PATH is a Darwin libtool/ar archive (magic "!<arch>"), not MH_OBJECT.
# PLATFORM: MACOS — prefer/inject ld -r fallback uses libtool -static; a later
# inject into that archive can leave a tiny incomplete .o (Cap LEA missing).
# LINUX ELF never matches. G.7 single gate for pabi recover / inject refuse.
pipeline_abi_o_is_libtool_archive() {
  local p="$1"
  local mag
  [ -f "$p" ] || return 1
  # PLATFORM: MACOS — magic "!<arch>" (7 bytes). Avoid tr on binary (Darwin LC_CTYPE).
  mag="$(head -c 7 "$p" 2>/dev/null || true)"
  [ "$mag" = '!<arch>' ]
}

# True when this host's product -E binary is a leftover Windows PE that cannot
# compile tip pipeline_abi sources (mega hang; thin -E fail).
# PLATFORM: WINDOWS — 2026-07-31 leftover PE is present for Track L / can_run
# so the "no xlang binary" skip does not fire. POSIX gold xlang_asm CAN -E.
# G.7: one predicate; prefer FORCE hybrid + thin inject both consult it
# BEFORE launching leftover PE -E (post-fail keep is not enough: mega hangs).
pipeline_abi_windows_leftover_pe_cannot_e() {
  windows_leftover_pe_cannot_e
}

# Return 0 if ANY global text symbol in THIN is already a global T in BASE.
# Cap residual C→.x thins often add helper T (e.g. w288_format_*) that are
# absent from leftover; requiring *all* thin T in base skipped weaken and
# left overlapping exports strong → Darwin ld -r failed → libtool archive
# with duplicate members (wave294 asm_label_format). Weaken only needs the
# intersection; additive-only thins still return 1 (no overlap).
# PLATFORM: SHARED nm (Darwin leading underscore accepted as-is).
# wave647: strong-text symbol names in OBJ (one per line).
# Darwin plain `nm` displays Mach-O WEAK text as 'T' (ELF shows 'W'), so the
# historic `nm -gU | awk '$2=="T"'` ELF check misread weak externals as
# strong and tripped the destructive --redefine-sym fallback (a rename
# redirects the base's OWN callers to the dead *_pabi_superseded copy —
# w647 `&g` CG002: addr_of called the superseded lea, cold table empty).
# Darwin authority = `nm -m`: weak text prints "weak external", strong
# prints "external"; text section is (__TEXT,__text) (incl. non-external).
# ELF keeps plain nm (W/w never match T/t). G.7: single strong-T predicate
# for already_defined + weaken verify loops.
# PLATFORM: SHARED — Darwin nm -m · LINUX nm -gU.
pipeline_abi_strong_text_syms() {
  local obj="$1"
  if [ "$(uname -s 2>/dev/null || echo Unknown)" = "Darwin" ]; then
    nm -m "$obj" 2>/dev/null | awk '$0 ~ /\(__TEXT,__text\)/ && $0 !~ /weak/ { print $NF }'
  else
    nm -gU "$obj" 2>/dev/null | awk '/ [Tt] / { print $NF }'
  fi
}

pipeline_abi_thin_already_defined() {
  local base="$1"
  local thin="$2"
  local sym
  local thin_syms
  local base_strong
  [ -f "$base" ] && [ -f "$thin" ] || return 1
  thin_syms="$(nm -gU "$thin" 2>/dev/null | awk '/ [Tt] / { print $NF }')"
  [ -n "$thin_syms" ] || return 1
  base_strong="$(pipeline_abi_strong_text_syms "$base")"
  while IFS= read -r sym; do
    [ -n "$sym" ] || continue
    case "
$base_strong
" in
      *"
$sym
"*) return 0 ;;
    esac
  done <<EOF
$thin_syms
EOF
  return 1
}

# Weaken every global T from THIN inside BASE so Darwin ld -r can overlay
# a newer leaf (two strong T → two LC_SEGMENT / libtool dual member).
# G.7: reuse pure_asm_find_objcopy; do not invent a second objcopy hunt.
# PLATFORM: SHARED — ELF + Mach-O (--weaken-symbol name and _name).
# Darwin refuse of xlang_asm MH_OBJECT overlay. Old writer (named __TEXT,
# dummy nlist, no LC_DYSYMTAB) poisoned ELF finalize (L2 all CG002).
# Product writer ingested 2026-09-16 (clang-aligned: empty segname,
# LC_DYSYMTAB, flags 0x80000400, no dummy nlist) — dummy + durable C thin
# both Darwin L2 5/5. Default allow overlay. Restore old refuse with
# XLANG_PABI_DARWIN_REFUSE_ASM=1.
# G.7: gate the existing inject; do not invent a second merger.
# PLATFORM: MACOS — Linux ELF relocatable is a different load class.
pipeline_abi_darwin_refuse_asm_thin_overlay() {
  [ "$(uname -s 2>/dev/null)" = "Darwin" ] && [ "${XLANG_PABI_DARWIN_REFUSE_ASM:-0}" = "1" ]
}

pipeline_abi_weaken_thin_syms_in_obj() {
  local base="$1"
  local thin="$2"
  local oc=""
  local sym=""
  local any=0
  local still_t=0
  local dead=""
  local base_strong
  [ -s "$base" ] && [ -s "$thin" ] || return 1
  oc="$(pure_asm_find_objcopy)" || return 1
  while IFS= read -r sym; do
    [ -n "$sym" ] || continue
    "$oc" --weaken-symbol="$sym" "$base" 2>/dev/null || true
    case "$sym" in
      _*) "$oc" --weaken-symbol="${sym#_}" "$base" 2>/dev/null || true ;;
      *) "$oc" --weaken-symbol="_${sym}" "$base" 2>/dev/null || true ;;
    esac
    any=1
  done <<EOF
$(nm -gU "$thin" 2>/dev/null | awk '/ [Tt] / { print $NF }')
EOF
  [ "$any" = "1" ] || return 1
  # PLATFORM: MACOS — llvm-objcopy --weaken-symbol is often a no-op on
  # multi-ld-r MH_OBJECT (returns 0, symbol stays T). Fall back to
  # --redefine-sym so Darwin ld -r can first-wins overlay the thin
  # (wave328 mega_body C→.x). Dead renamed bodies stay until next prefer.
  # wave647: the strong-T check is now weak-aware (nm -m on Darwin) — a
  # rename redirects the BASE's own callers to the dead copy, so it must
  # only ever run on genuinely strong leftovers, never on already-weak text.
  # PLATFORM: LINUX — weaken usually works; redefine only if still T.
  # Unique dead names: tip often already has *_pabi_superseded from a prior
  # Cap overlay. Redefining onto an existing name creates duplicate atoms in
  # one MH_OBJECT → Darwin ld asserts "malformed atom files with duplicate
  # names" and pure_ld_partial_merge falls back to libtool archive (g05 red).
  # Pick *_pabi_superseded / *_pabi_superseded2 / … until free (wave329).
  still_t=0
  base_strong="$(pipeline_abi_strong_text_syms "$base")"
  while IFS= read -r sym; do
    [ -n "$sym" ] || continue
    case "
$base_strong
" in
      *"
$sym
"*)
        still_t=1
        dead="${sym}_pabi_superseded"
        n=1
        while nm -gU "$base" 2>/dev/null | awk -v s="$dead" '
          $NF == s { found=1 }
          END { exit !found }
        '; do
          n=$((n + 1))
          dead="${sym}_pabi_superseded${n}"
        done
        "$oc" --redefine-sym="${sym}=${dead}" "$base" 2>/dev/null || true
        case "$sym" in
          _*)
            "$oc" --redefine-sym="${sym#_}=${dead#_}" "$base" 2>/dev/null || true
            ;;
          *)
            "$oc" --redefine-sym="_${sym}=_${dead}" "$base" 2>/dev/null || true
            ;;
        esac
        ;;
    esac
  done <<EOF
$(nm -gU "$thin" 2>/dev/null | awk '/ [Tt] / { print $NF }')
EOF
  if [ "$still_t" = "1" ]; then
    log "pipeline_abi weaken: Darwin/objcopy weaken no-op → redefine-sym unique *_pabi_supersededN"
  fi
  # Refuse if any thin T still strong in base (redefine failed / no-op).
  base_strong="$(pipeline_abi_strong_text_syms "$base")"
  while IFS= read -r sym; do
    [ -n "$sym" ] || continue
    case "
$base_strong
" in
      *"
$sym
"*)
        log "pipeline_abi weaken: leftover T still strong after redefine ($sym)"
        return 1
        ;;
    esac
  done <<EOF
$(nm -gU "$thin" 2>/dev/null | awk '/ [Tt] / { print $NF }')
EOF
  return 0
}

pipeline_abi_inject_thin_leaf() {
  local o="$1"
  local thin_x="$2"
  local tag="$3"
  local xlang_bin=""
  local gen_c thin_o base_o restore_o used_asm=0
  local thin_bn thin_stem pabi_asm_only pabi_asm_match
  if [ ! -s "$o" ] || [ ! -f "$thin_x" ]; then
    return 0
  fi
  # Prefer skip/inject-only: do not re-overlay every PREFER_ASM .x leaf on an
  # already-green hybrid OUT (Darwin: re-pure-asm first-wins regenerates and
  # can turn product red). Only inject when the leaf src is newer than OUT
  # (or XLANG_PABI_THIN_FORCE_INJECT=1). Fresh hybrid (done=1) leaves the
  # gate unset so all leaves still ingest. C thins (macho/emit_ctx) bypass
  # this helper. PLATFORM: SHARED shell · MACOS + LINUX gold.
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER:-0}" = "1" ] \
    && [ "${XLANG_PABI_THIN_FORCE_INJECT:-0}" != "1" ] \
    && [ ! "$thin_x" -nt "$o" ]; then
    return 0
  fi
  # Cap residual (10.3.2 Darwin): do not inject into a libtool archive named .o.
  # Caller (prefer) must rebuild MH_OBJECT / ELF first. PLATFORM: MACOS.
  if pipeline_abi_o_is_libtool_archive "$o"; then
    log "pipeline_abi ${tag} inject skip: $o is libtool archive (rebuild pabi first)"
    return 1
  fi
  # PLATFORM: WINDOWS — leftover PE cannot -E tip thins (fail or hang).
  # Do not launch; keep existing hybrid $o (same as no-binary skip).
  # POSIX (Linux gold / Darwin): continue with product -E.
  if pipeline_abi_windows_leftover_pe_cannot_e; then
    log "pipeline_abi ${tag} inject skip: Windows leftover PE cannot -E tip thins; keep $o"
    return 0
  fi
  if [ -x ./xlang_asm ]; then
    xlang_bin=./xlang_asm
  elif [ -x ./xlang ]; then
    xlang_bin=./xlang
  elif [ -x ./xlang-c ]; then
    xlang_bin=./xlang-c
  else
    log "pipeline_abi ${tag} inject skip: no xlang binary"
    return 0
  fi
  gen_c="$(mktemp "${TMPDIR:-/tmp}/pabi_thin.XXXXXX.c")"
  thin_o="$(mktemp "${TMPDIR:-/tmp}/pabi_thin.XXXXXX.o")"
  base_o="$(mktemp "${TMPDIR:-/tmp}/pabi_thin_base.XXXXXX.o")"
  restore_o="$(mktemp "${TMPDIR:-/tmp}/pabi_thin_restore.XXXXXX.o")"
  # M2 class E: thins are standalone -c green. Prefer defaults
# wave457 gate: LINUX tip PREFER forbidden when -c .o is U-starved or 0-call
#   (field/index/scalar tip empty-body假绿; L2 may still 5/5).
  # XLANG_PABI_THIN_PREFER_ASM=1 (asm overlay). Direct inject without
  # prefer still defaults -E unless the env is set. Darwin refuse only if
  # XLANG_PABI_DARWIN_REFUSE_ASM=1. Mega runtime_pipeline_abi.x stays banned.
  # PLATFORM: SHARED — do not leak tree PREFER_ASM_O.
  used_asm=0
  thin_bn="$(basename "$thin_x")"
  thin_stem="${thin_bn%.x}"
  pabi_asm_only="${XLANG_PABI_THIN_PREFER_ASM_ONLY:-}"
  pabi_asm_match=1
  if [ -n "$pabi_asm_only" ]; then
    pabi_asm_match=0
    case ",${pabi_asm_only}," in
      *",${thin_bn},"*|*,${thin_stem},*) pabi_asm_match=1 ;;
    esac
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM:-0}" = "1" ] && [ "$pabi_asm_match" = "1" ] && (
    export XLANG_PREFER_ASM_O=1
    unset G05_X_O_WEAK
    unset G05_X_O_WEAK_FUNCS
    unset G05_X_O_SYM_RENAME
    pure_asm_x_to_o "$thin_o" "$thin_x"
  ) && [ -s "$thin_o" ]; then
    if pipeline_abi_darwin_refuse_asm_thin_overlay; then
      log "pipeline_abi ${tag} inject: Darwin refuse asm MH_OBJECT overlay (CG002); fall back -E+cc"
      used_asm=0
    else
      used_asm=1
    fi
  fi
  if [ "$used_asm" != "1" ]; then
    if ! "$xlang_bin" -E "$thin_x" >"$gen_c" 2>/dev/null || [ ! -s "$gen_c" ]; then
      log "pipeline_abi ${tag} inject: -E failed"
      rm -f "$gen_c" "$thin_o" "$base_o" "$restore_o"
      return 1
    fi
    # shellcheck disable=SC2086
    if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$thin_o" "$gen_c" 2>/dev/null; then
      log "pipeline_abi ${tag} inject: cc thin failed"
      rm -f "$gen_c" "$thin_o" "$base_o" "$restore_o"
      return 1
    fi
  fi
  # PLATFORM: MACOS — g05 re-injects after bootstrap already overlaid this leaf.
  # Second strong overlay cannot Darwin ld -r (two LC_SEGMENT / two T); libtool
  # -static then keeps both members. Final -force_load of a ≤2-member archive
  # pulls both → duplicate `_glue_slice_let_reent_deep_copy_after_dual_gp_elf_c`
  # (L4 @7f2754d80). Skip when already T unless source is newer — then weaken
  # leftover T and overlay (M2 PREFER_ASM replace of historic -E+$CC leaf).
  if pipeline_abi_thin_already_defined "$o" "$thin_o"; then
    # Historic -E+$CC: skip second strong overlay (Darwin ld -r / libtool).
    # Pure-asm opt-in replaces leftover T (weaken then first-wins).
    # Cap residual C→.x via -E (XLANG_PABI_THIN_ALLOW_E_REPLACE=1): same
    # weaken+first-wins when pure-asm bodies are red (wave294 digit loops).
    if [ "$used_asm" != "1" ] \
      && [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE:-0}" != "1" ] \
      && [ "${XLANG_PABI_THIN_FORCE_INJECT:-0}" != "1" ]; then
      log "pipeline_abi ${tag} inject skip: already defined in $o"
      rm -f "$gen_c" "$thin_o" "$base_o" "$restore_o"
      return 0
    fi
  fi
  cp -f "$o" "$base_o"
  cp -f "$o" "$restore_o"
  if pipeline_abi_thin_already_defined "$o" "$thin_o"; then
    if ! pipeline_abi_weaken_thin_syms_in_obj "$base_o" "$thin_o"; then
      log "pipeline_abi ${tag} inject skip: already T and cannot weaken leftover"
      rm -f "$gen_c" "$thin_o" "$base_o" "$restore_o"
      return 0
    fi
    if [ "$used_asm" = "1" ]; then
      log "pipeline_abi ${tag} inject: weakened leftover T (pure-asm replace)"
    else
      log "pipeline_abi ${tag} inject: weakened leftover T (-E replace)"
    fi
  fi
  if pure_ld_partial_merge "$o" "$thin_o" "$base_o" 2>/dev/null; then
    # PLATFORM: MACOS — ld -r may fall back to libtool -static. Accept only if
    # the archive still contains the full base (≥ base size). Tiny incomplete
    # archives (Cap residual 10.3.2: thin+rest_try leftover) are refused.
    if pipeline_abi_o_is_libtool_archive "$o"; then
      local base_sz out_sz
      base_sz=$(wc -c <"$base_o" | tr -d ' ')
      out_sz=$(wc -c <"$o" | tr -d ' ')
      if [ -z "$base_sz" ] || [ -z "$out_sz" ] || [ "$out_sz" -lt "$base_sz" ]; then
        cp -f "$restore_o" "$o"
        log "pipeline_abi ${tag} inject: incomplete libtool archive; restored base"
        rm -f "$gen_c" "$thin_o" "$base_o" "$restore_o"
        return 1
      fi
      log "pipeline_abi ${tag} inject OK (Darwin libtool archive ≥ base; force_load)"
    else
      if [ "$used_asm" = "1" ]; then
        log "pipeline_abi ${tag} inject OK (pure-asm first-wins over leftover)"
      else
        log "pipeline_abi ${tag} inject OK (first-wins over weak pure)"
      fi
    fi
    rm -f "$gen_c" "$thin_o" "$base_o" "$restore_o"
    return 0
  fi
  cp -f "$restore_o" "$o"
  log "pipeline_abi ${tag} inject: merge failed; restored base"
  rm -f "$gen_c" "$thin_o" "$base_o" "$restore_o"
  return 1
}

# wave299/333/484/486/488/500/501 M2: preprocess_malloc Cap residual .x thin (PP002 heap).
# wave501: tip PREFER alloc_dup via memcpy (byte-while tip PREFER SEGV @w488).
#   add_defs tip PREFER was BAN'd (L2 hang @w501) — leftover assign_var smash.
# wave609 M2: add_defs product PREFER_ASM (standalone -c complete after w600).
#   Stamp w609 both ends. Do not fall back to -E for this TU.
# wave500: tip PREFER scratch + after + main (tipU 齐; L2 验).
# Stamp w501 peers + w609 add_defs. G.7 match mega xlang_preprocess_raw_to_malloc_impl.
# PLATFORM: SHARED.
pipeline_abi_inject_preprocess_malloc_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_preprocess_malloc_thin.x"
  local stamp="src/.pabi_w501_preprocess_malloc.stamp"
  local stamp_prefer="src/.pabi_w609_add_defs_prefer.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ] && [ -f "$stamp_prefer" ]; then
    local _ok=1 _px _ps
    for _pair in \
      "src/runtime_pipeline_abi_preprocess_malloc_clear_outs_thin.x|.pabi_w501_preprocess_malloc_clear_outs.stamp" \
      "src/runtime_pipeline_abi_preprocess_malloc_validate_len_thin.x|.pabi_w501_preprocess_malloc_validate_len.stamp" \
      "src/runtime_pipeline_abi_preprocess_malloc_gate_setup_thin.x|.pabi_w501_preprocess_malloc_gate_setup.stamp" \
      "src/runtime_pipeline_abi_preprocess_malloc_scratch_thin.x|.pabi_w501_preprocess_malloc_scratch.stamp" \
      "src/runtime_pipeline_abi_preprocess_malloc_add_defs_thin.x|.pabi_w609_add_defs_prefer.stamp" \
      "src/runtime_pipeline_abi_preprocess_malloc_try_buf_thin.x|.pabi_w501_preprocess_malloc_try_buf.stamp" \
      "src/runtime_pipeline_abi_preprocess_malloc_check_stack_thin.x|.pabi_w501_preprocess_malloc_check_stack.stamp" \
      "src/runtime_pipeline_abi_preprocess_malloc_alloc_dup_thin.x|.pabi_w501_preprocess_malloc_alloc_dup.stamp" \
      "src/runtime_pipeline_abi_preprocess_malloc_after_scratch_thin.x|.pabi_w501_preprocess_malloc_after_scratch.stamp"
    do
      _px="${_pair%%|*}"
      _ps="src/${_pair#*|}"
      if [ -f "$_px" ] && { [ ! -f "$_ps" ] || [ "$_px" -nt "$_ps" ]; }; then
        _ok=0
        break
      fi
    done
    if [ "$_ok" = "1" ]; then
      return 0
    fi
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  local p_x p_rest p_stamp p_tag p_prefer p_rest2
  for p_peer in \
    "src/runtime_pipeline_abi_preprocess_malloc_clear_outs_thin.x|.pabi_w501_preprocess_malloc_clear_outs.stamp|w501-preprocess-malloc-clear-outs|1" \
    "src/runtime_pipeline_abi_preprocess_malloc_validate_len_thin.x|.pabi_w501_preprocess_malloc_validate_len.stamp|w501-preprocess-malloc-validate-len|1" \
    "src/runtime_pipeline_abi_preprocess_malloc_gate_setup_thin.x|.pabi_w501_preprocess_malloc_gate_setup.stamp|w501-preprocess-malloc-gate-setup|1" \
    "src/runtime_pipeline_abi_preprocess_malloc_scratch_thin.x|.pabi_w501_preprocess_malloc_scratch.stamp|w501-preprocess-malloc-scratch|1" \
    "src/runtime_pipeline_abi_preprocess_malloc_add_defs_thin.x|.pabi_w609_add_defs_prefer.stamp|w609-add-defs-prefer|1" \
    "src/runtime_pipeline_abi_preprocess_malloc_try_buf_thin.x|.pabi_w501_preprocess_malloc_try_buf.stamp|w501-preprocess-malloc-try-buf|1" \
    "src/runtime_pipeline_abi_preprocess_malloc_check_stack_thin.x|.pabi_w501_preprocess_malloc_check_stack.stamp|w501-preprocess-malloc-check-stack|1" \
    "src/runtime_pipeline_abi_preprocess_malloc_alloc_dup_thin.x|.pabi_w501_preprocess_malloc_alloc_dup.stamp|w501-preprocess-malloc-alloc-dup|1" \
    "src/runtime_pipeline_abi_preprocess_malloc_after_scratch_thin.x|.pabi_w501_preprocess_malloc_after_scratch.stamp|w501-preprocess-malloc-after-scratch|1" \
    "src/runtime_pipeline_abi_preprocess_malloc_thin.x|.pabi_w501_preprocess_malloc.stamp|w501-preprocess-malloc|1"
  do
    p_x="${p_peer%%|*}"
    p_rest="${p_peer#*|}"
    p_stamp="src/${p_rest%%|*}"
    p_rest2="${p_rest#*|}"
    p_tag="${p_rest2%%|*}"
    p_prefer="${p_rest2##*|}"
    if [ -f "$p_x" ] && { [ ! -f "$p_stamp" ] || [ "$p_x" -nt "$p_stamp" ]; }; then
      export XLANG_PABI_THIN_PREFER_ASM="$p_prefer"
      pipeline_abi_inject_thin_leaf "$o" "$p_x" "$p_tag"
      rc=$?
      if [ "$rc" -eq 0 ]; then
        touch "$p_stamp"
        # PLATFORM: SHARED — keep historic w501 add_defs stamp so leftover
        # skip-up-to-date peers do not re-enter the -E path.
        if [ "$p_stamp" = "$stamp_prefer" ]; then
          touch src/.pabi_w501_preprocess_malloc_add_defs.stamp
        fi
      else
        break
      fi
    fi
  done
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    touch "$stamp_prefer"
    rm -f src/.pabi_w333_preprocess_malloc.stamp src/.pabi_w484_preprocess_malloc*.stamp \
      src/.pabi_w486_preprocess_malloc*.stamp src/.pabi_w488_preprocess_malloc*.stamp \
      src/.pabi_w500_preprocess_malloc*.stamp
  fi
  return "$rc"
}

# wave298/354/487/509 M2: import_heap Cap residual C→.x (was C strong overlay).
# wave487: peer-flat no-local (resolve/read_prep/parse+gate); tip U-complete.
# wave509: parse tipU 6/7→7/7 — i64 wrapper (no cast-on-get) + pipe cell;
#   stamp parse → w509; BOTH PREFER reinject parse leaf.
# PRODUCT inject: BOTH PREFER. PLATFORM: SHARED.
pipeline_abi_inject_import_heap_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_import_heap_thin.x"
  local stamp="src/.pabi_w487_import_heap.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    local _ok=1 _px _ps
    for _pair in \
      "src/runtime_pipeline_abi_import_heap_resolve_thin.x|.pabi_w487_import_heap_resolve.stamp" \
      "src/runtime_pipeline_abi_import_heap_read_prep_thin.x|.pabi_w487_import_heap_read_prep.stamp" \
      "src/runtime_pipeline_abi_import_heap_parse_thin.x|.pabi_w509_import_heap_parse.stamp"
    do
      _px="${_pair%%|*}"
      _ps="src/${_pair#*|}"
      if [ -f "$_px" ] && { [ ! -f "$_ps" ] || [ "$_px" -nt "$_ps" ]; }; then
        _ok=0
        break
      fi
    done
    if [ "$_ok" = "1" ]; then
      return 0
    fi
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  local p_x p_rest p_stamp p_tag p_prefer p_rest2
  for p_peer in \
    "src/runtime_pipeline_abi_import_heap_resolve_thin.x|.pabi_w487_import_heap_resolve.stamp|w487-import-heap-resolve|1" \
    "src/runtime_pipeline_abi_import_heap_read_prep_thin.x|.pabi_w487_import_heap_read_prep.stamp|w487-import-heap-read-prep|1" \
    "src/runtime_pipeline_abi_import_heap_parse_thin.x|.pabi_w509_import_heap_parse.stamp|w509-import-heap-parse|1" \
    "src/runtime_pipeline_abi_import_heap_thin.x|.pabi_w487_import_heap.stamp|w487-import-heap|1"
  do
    p_x="${p_peer%%|*}"
    p_rest="${p_peer#*|}"
    p_stamp="src/${p_rest%%|*}"
    p_rest2="${p_rest#*|}"
    p_tag="${p_rest2%%|*}"
    p_prefer="${p_rest2##*|}"
    if [ -f "$p_x" ] && { [ ! -f "$p_stamp" ] || [ "$p_x" -nt "$p_stamp" ]; }; then
      export XLANG_PABI_THIN_PREFER_ASM="$p_prefer"
      pipeline_abi_inject_thin_leaf "$o" "$p_x" "$p_tag"
      rc=$?
      if [ "$rc" -eq 0 ]; then
        touch "$p_stamp"
        # wave509: retire w487 parse stamp when parse leaf overlays.
        if [ "$p_tag" = "w509-import-heap-parse" ]; then
          rm -f src/.pabi_w487_import_heap_parse.stamp
        fi
      else
        break
      fi
    fi
  done
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    rm -f src/.pabi_w298_import_heap.stamp src/.pabi_w354_import_heap.stamp
  fi
  return "$rc"
}

# wave297/352/519 M2: read_file_x_view Cap residual C→.x (was C strong overlay).
# PRODUCT inject wave352: PREFER_ASM both ends (ALLOW_E_REPLACE + stamp).
# Class B FileView: standalone -c green after Cap A INDEX (w350); product
# PREFER unlocks host-cc leave. G.7 match seed pipeline_read_file_x cold twin.
# wave519: tip CG002 heal (BSS FileView + pipe-cell mid path/buf/rc/data) →
#   tipU Soft Cap; stamp → w519; tip PRODUCT reinject HARD BAN (keep prior
#   PREFER overlay; do not tip-reinject after green).
# PLATFORM: SHARED · PREFER first-wins · BAN force tip reinject.
pipeline_abi_inject_read_file_x_view_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_read_file_x_view_thin.x"
  local stamp="src/.pabi_w519_read_file_x_view.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — w519 HARD BAN tip force-reinject once stamped.
  if [ -f "$stamp" ]; then
    return 0
  fi
  # Migrate w352 → w519 without reinject (tipU heal inventory only).
  if [ -f src/.pabi_w352_read_file_x_view.stamp ]; then
    touch "$stamp"
    rm -f src/.pabi_w352_read_file_x_view.stamp src/.pabi_w297_read_file_x_view.stamp
    log "pipeline_abi w519-read-file-x-view: tipU heal stamped; tip force-reinject HARD BAN (keep PREFER overlay)"
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — PREFER_ASM first-wins (cold unlock only).
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w519-read-file-x-view"
  rc=$?
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    rm -f src/.pabi_w297_read_file_x_view.stamp src/.pabi_w352_read_file_x_view.stamp
  fi
  return "$rc"
}

# wave410d/589 M2: reent_deep_copy Cap residual. G.7: match mega leave.
# PRODUCT inject wave410d: PREFER_ASM both ends (ALLOW_E_REPLACE + stamp).
# wave589: Ubuntu tip `-backend asm -c` empty .o (if-before-call /
#   mid-assign / rc=call then if / nested while COMMON digit fill /
#   local u8 label buffers / branch-gated encoders). Darwin original
#   36/36. reent_deep_copy_store_encoders recovered 36/36. HARD BAN
#   tip PRODUCT reinject both ends. Keep w410 overlay.
# PLATFORM: SHARED · stamp-only BAN then return 0.
pipeline_abi_inject_reent_deep_copy_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_reent_deep_copy_thin.x"
  local stamp="src/.pabi_w589_reent_deep_copy.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — wave589 Soft Cap HARD BAN tip reinject (keep w410).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w410_reent_deep_copy.stamp
  log "pipeline_abi w589-reent-deep-copy: tipU stamped; tip PRODUCT reinject HARD BAN (keep w410)"
  return 0
}

# wave408/418/608 M2: fixed_array_copy Cap residual — lea-not-load.
# PRODUCT inject wave608:
#   MACOS: stamp-only keep overlay (Darwin already leas CALL-arg T[N]).
#     HARD BAN PREFER of full thin and helpers.
#   LINUX: gcc -E helpers-only thin (glue_call_arg_var_use_lea_not_load_elf_c).
#     leftover PREFER smash T (sub $0xac8, no endbr64) returned 0 so CALL-arg
#     T[N] loaded the payload as a pointer. HARD BAN PREFER helpers.
#     Do not -E the full thin (LINUX XT001 / remaining exports BAN).
# wave749: classify thin frame. Live unique = leftover gcc W of the same
#   glue (Darwin weak sub #0x180 / LINUX W endbr64 sub $0x160 size 0x58e).
#   Standalone -c still smash (sub $0xbc8 / #0xbd0). Stamp skip correct.
#   Do NOT re-PREFER (dest-overwrite). Do NOT gcc -E as the repair.
#   Not leftover-first. Not the w748 assign_index inline class.
# G.7: helpers export matches mega glue_call_arg_var_use_lea_not_load_elf_c.
# PLATFORM: SHARED · MACOS stamp-only / LINUX helpers -E (historical; BAN tip -E).
pipeline_abi_inject_fixed_array_copy_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_fixed_array_copy_helpers_thin.x"
  local stamp="src/.pabi_w557_fixed_array_copy_helpers.stamp"
  local stamp_e="src/.pabi_w608_call_arg_lea.stamp"
  local stamp_full="src/.pabi_w418_fixed_array_copy.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  case "$(uname -s)" in
    Darwin)
      # PLATFORM: MACOS — overlay already leas CALL-arg T[N].
      # wave749: stamp skip keeps weak live; HARD BAN PREFER smash thin.
      if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ]; then
        return 0
      fi
      touch "$stamp"
      touch "$stamp_e"
      touch "$stamp_full"
      log "pipeline_abi w608-call-arg-lea: MACOS keep prior overlay; HARD BAN PREFER"
      return 0
      ;;
    Linux)
      # PLATFORM: LINUX — -E replace smash leftover PREFER T.
      # wave749: stamp skip keeps leftover gcc W live; re-PREFER / tip -E BAN.
      if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ]; then
        return 0
      fi
      local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
      local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
      local had_prefer=0 had_e_repl=0 rc=0
      if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
      if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
      unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1  # wave621: stale-era smash wall re-verified
      export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
      pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w608-call-arg-lea-e"
      rc=$?
      if [ "$had_prefer" = "1" ]; then
        export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
      else
        unset XLANG_PABI_THIN_PREFER_ASM
      fi
      if [ "$had_e_repl" = "1" ]; then
        export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
      else
        unset XLANG_PABI_THIN_ALLOW_E_REPLACE
      fi
      if [ "$rc" -eq 0 ]; then
        touch "$stamp"
        touch "$stamp_e"
        log "pipeline_abi w608-call-arg-lea: LINUX -E replace (smash leftover T)"
      fi
      return "$rc"
      ;;
  esac
  touch "$stamp"
  touch "$stamp_e"
  log "pipeline_abi w608-call-arg-lea: non-POSIX stamp-only (keep prior)"
  return 0
}

# wave400/415/428 M2: slot_bytes Cap residual — asymmetric helpers+asm_local unlock.
# PRODUCT inject wave428:
#   MACOS: PREFER_ASM full thin (helpers+asm_local; product L2 verified).
#   LINUX: helpers-only (w415) then asm_local rest-only (w428; peers extern;
#     Ubuntu -c ~879B; product inject+true relink L2 5/5 opt=102 md5 changed).
# wave428 also BAN probes: ttc main empty .o; field XT001; param CG002.
# wave538: LINUX asm_local Soft Cap HARD BAN (keep w428 overlay).
# wave590: LINUX helpers Ubuntu tip `-backend asm -c` UND=1 (kind_ord only;
#   T only asm_fixed_array_total_bytes_mod). Darwin original 22 UND / 3 T.
#   Cause: if-before-call / mid-assign nlen/nt/asz/ko / nested while
#   name-match / local u8[256] / i32[1] *i32 metrics out.
#   slot_bytes_store_encoders recovered 22+pipe_store. HARD BAN LINUX
#   tip PRODUCT reinject (keep w415 overlay). MACOS still PREFER-injects
#   the full thin.
# G.7: helpers+asm_local bodies match mega / full thin.
# PLATFORM: SHARED · MACOS full PREFER / LINUX helpers BAN + asm_local BAN.
pipeline_abi_inject_slot_bytes_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_slot_bytes_thin.x"
  local stamp="src/.pabi_w415_slot_bytes.stamp"
  local tag="w415-slot-bytes"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  # PLATFORM: LINUX — helpers then asm_local rest (w428); both BAN tip reinject.
  case "$(uname -s)" in
    Linux)
      thin_x="src/runtime_pipeline_abi_slot_bytes_helpers_thin.x"
      stamp="src/.pabi_w590_slot_bytes_helpers.stamp"
      tag="w590-slot-bytes-helpers"
      ;;
  esac
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: LINUX — wave590 Soft Cap HARD BAN helpers tip reinject
  # (keep the w415 overlay). wave538 still BAN asm_local. Do not
  # prefer-reinject these leaves. MACOS still injects the full thin.
  if [ "$(uname -s)" = "Linux" ]; then
    if [ -f "$thin_x" ]; then
      touch "$stamp"
      rm -f src/.pabi_w415_slot_bytes_helpers.stamp
      log "pipeline_abi w590-slot-bytes-helpers: tipU stamped; tip PRODUCT reinject HARD BAN (keep w415)"
    fi
    local l2x="src/runtime_pipeline_abi_slot_asm_local_thin.x"
    local l2s="src/.pabi_w538_slot_asm_local.stamp"
    if [ -f "$l2x" ]; then
      touch "$l2s"
      rm -f src/.pabi_w428_slot_asm_local.stamp
      log "pipeline_abi w538-slot-asm-local: tipU 1/1 stamped; tip PRODUCT reinject HARD BAN (keep prior)"
    fi
    return 0
  fi
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: MACOS — PREFER_ASM full thin (product L2 verified).
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "$tag"
  rc=$?
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
  fi
  return "$rc"
}

# wave401/414/431/433/485/508 M2: field_load_sz Cap residual — asymmetric helpers unlock.
# PRODUCT inject wave414:
#   MACOS: PREFER_ASM full thin (helpers+main; -c green; product L2 verified).
#   LINUX: PREFER_ASM helpers-only thin (field_load_sz_bytes_eq;
#     Ubuntu helpers -c ~1023B green). Full tip -c XT001@bytes_eq
#     MISATTRIBUTED — root = LINUX typeck/arena on main co-file.
# wave431: main rest-only Darwin -c ~4571B; LINUX HARD BAN (asm empty;
#   -E omit T). Main tip reinject still BAN on LINUX.
# wave433: LINUX layout+main PREFER — nested byte-compare while →
#   copy+bytes_eq layout thin + main tip (Ubuntu -c ~3740+3256B; -E T present).
# wave485: LINUX layout+try_layout+name_heur+main no-local PREFER — tip U
#   starved 3/9＋2/11 → peer-flat tip U 齐; stamp w485.
# wave508: layout tipU 12/13→13/13 — `out[j]=name_byte_at() as u8` mid-cast
#   drop; pipe-cell heal; stamp → w508 (LINUX PREFER reinject layout leaf).
# wave540: LINUX helpers tipU 0/0 (drop 15 unused externs) HARD BAN tip
#   reinject; stamp w540. layout/try/heur/main stay w508/w485.
# G.7: helpers/layout/main match mega; MACOS stays full thin.
# PLATFORM: SHARED · MACOS full PREFER / LINUX helpers BAN + layout+main PREFER.
pipeline_abi_inject_field_load_sz_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_field_load_sz_thin.x"
  local stamp="src/.pabi_w414_field_load_sz.stamp"
  local tag="w414-field-load-sz"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  local lay_x lay_stamp main_x main_stamp try_x try_stamp heur_x heur_stamp
  # PLATFORM: LINUX — helpers then layout/try/heur then main tip PREFER.
  case "$(uname -s)" in
    Linux)
      thin_x="src/runtime_pipeline_abi_field_load_sz_helpers_thin.x"
      stamp="src/.pabi_w540_field_load_sz_helpers.stamp"
      tag="w540-field-load-sz-helpers"
      lay_x="src/runtime_pipeline_abi_field_load_layout_thin.x"
      lay_stamp="src/.pabi_w508_field_load_layout.stamp"
      try_x="src/runtime_pipeline_abi_field_load_try_layout_thin.x"
      try_stamp="src/.pabi_w485_field_load_try_layout.stamp"
      heur_x="src/runtime_pipeline_abi_field_load_name_heur_thin.x"
      heur_stamp="src/.pabi_w485_field_load_name_heur.stamp"
      main_x="src/runtime_pipeline_abi_field_load_main_thin.x"
      main_stamp="src/.pabi_w485_field_load_main.stamp"
      ;;
  esac
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    if [ -n "${lay_x-}" ] && [ -f "$lay_x" ]; then
      if [ -f "$lay_stamp" ] && [ ! "$lay_x" -nt "$lay_stamp" ] \
        && [ -f "$try_stamp" ] && [ ! "$try_x" -nt "$try_stamp" ] \
        && [ -f "$heur_stamp" ] && [ ! "$heur_x" -nt "$heur_stamp" ] \
        && [ -f "$main_stamp" ] && [ ! "$main_x" -nt "$main_stamp" ]; then
        return 0
      fi
    else
      return 0
    fi
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — PREFER_ASM for the leaf selected above.
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  # PLATFORM: LINUX — wave540 Soft Cap HARD BAN helpers tip reinject.
  # Dead extern decls dropped in .x; do not prefer-reinject this leaf.
  # MACOS still PREFER-injects the full thin selected above.
  if [ "$(uname -s)" = "Linux" ]; then
    touch "$stamp"
    rm -f src/.pabi_w414_field_load_sz_helpers.stamp
    log "pipeline_abi w540-field-load-sz-helpers: tipU 0/0 stamped; tip PRODUCT reinject HARD BAN (keep prior)"
    rc=0
  elif [ ! -f "$stamp" ] || [ "$thin_x" -nt "$stamp" ]; then
    pipeline_abi_inject_thin_leaf "$o" "$thin_x" "$tag"
    rc=$?
    if [ "$rc" -eq 0 ]; then
      touch "$stamp"
    fi
  else
    rc=0
  fi
  # PLATFORM: LINUX — layout → try_layout → name_heur → main (wave485/w508).
  if [ "$rc" -eq 0 ] && [ -n "${lay_x-}" ] && [ -f "$lay_x" ]; then
    if [ ! -f "$lay_stamp" ] || [ "$lay_x" -nt "$lay_stamp" ]; then
      pipeline_abi_inject_thin_leaf "$o" "$lay_x" "w508-field-load-layout"
      rc=$?
      if [ "$rc" -eq 0 ]; then
        touch "$lay_stamp"
        rm -f src/.pabi_w433_field_load_layout.stamp \
          src/.pabi_w485_field_load_layout.stamp
      fi
    fi
  fi
  if [ "$rc" -eq 0 ] && [ -n "${try_x-}" ] && [ -f "$try_x" ]; then
    if [ ! -f "$try_stamp" ] || [ "$try_x" -nt "$try_stamp" ]; then
      pipeline_abi_inject_thin_leaf "$o" "$try_x" "w485-field-load-try-layout"
      rc=$?
      if [ "$rc" -eq 0 ]; then
        touch "$try_stamp"
      fi
    fi
  fi
  if [ "$rc" -eq 0 ] && [ -n "${heur_x-}" ] && [ -f "$heur_x" ]; then
    if [ ! -f "$heur_stamp" ] || [ "$heur_x" -nt "$heur_stamp" ]; then
      pipeline_abi_inject_thin_leaf "$o" "$heur_x" "w485-field-load-name-heur"
      rc=$?
      if [ "$rc" -eq 0 ]; then
        touch "$heur_stamp"
      fi
    fi
  fi
  if [ "$rc" -eq 0 ] && [ -n "${main_x-}" ] && [ -f "$main_x" ]; then
    if [ ! -f "$main_stamp" ] || [ "$main_x" -nt "$main_stamp" ]; then
      pipeline_abi_inject_thin_leaf "$o" "$main_x" "w485-field-load-main"
      rc=$?
      if [ "$rc" -eq 0 ]; then
        touch "$main_stamp"
        rm -f src/.pabi_w433_field_load_main.stamp
      fi
    fi
  fi
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  return "$rc"
}

# wave314/370/370b/612 M2: macho_write Cap residual C→.x (was Darwin C thin).
# wave370b: HARD BAN PREFER — PREFER of this thin hit g05 BRANCH26 because
#   the live gcc writer ignored typed sidecar (empty C static) while
#   append_reloc_typed is the elf_ctx PREFER overlay (different BSS).
# wave612: Darwin host-cc -E of this thin (calls reloc_r_type_at) PLUS
#   ld -r -alias leftover append_reloc_typed_pabi_superseded → live typed
#   so leftover modlet lea writes the elf_ctx PREFER sidecar. HARD BAN PREFER
#   of the writer thin (file-level ws_* lets). LINUX stamp-only (ELF writer).
# PLATFORM: MACOS -E replace + alias · LINUX stamp-only · BAN PREFER.
pipeline_abi_inject_macho_write_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_macho_write_thin.x"
  local stamp="src/.pabi_w612_macho_write_page21.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: MACOS — skip (w634): the thin inject on Darwin fails the
  # FIRST function emit (CG002 code_len=40, modlet_find never reached —
  # a Mach-O-side shadow class, not the table split; Ubuntu green).
  # Keep the prior overlay; LINUX carries the ONE-set. Bisect next wave.
  if [ "$(uname -s)" != "Linux" ]; then
    touch "$stamp"
    return 0
  fi
  case "$(uname -s)" in
    Darwin)
      # PLATFORM: MACOS — -E replace leftover gcc writer that read empty
      # C static r_type. Thin calls reloc_r_type_at (elf_ctx PREFER BSS).
      if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
        pipeline_abi_darwin_alias_leftover_typed_reloc "$o" || return $?
        return 0
      fi
      local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
      local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
      local had_prefer=0 had_e_repl=0 rc=0
      if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
      if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
      unset XLANG_PABI_THIN_INJECT_IF_NEWER
      export XLANG_PABI_THIN_PREFER_ASM=0
      export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
      pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w612-macho-write-page21"
      rc=$?
      if [ "$had_prefer" = "1" ]; then
        export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
      else
        unset XLANG_PABI_THIN_PREFER_ASM
      fi
      if [ "$had_e_repl" = "1" ]; then
        export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
      else
        unset XLANG_PABI_THIN_ALLOW_E_REPLACE
      fi
      if [ "$rc" -eq 0 ]; then
        touch "$stamp"
        rm -f src/.pabi_w314_macho_write.stamp src/.pabi_w370_macho_write.stamp \
          src/.pabi_w370b_macho_write.stamp src/.pabi_w612_typed_reloc_forward.stamp
        log "pipeline_abi w612-macho-write-page21: MACOS -E replace (typed sidecar accessor)"
        pipeline_abi_darwin_alias_leftover_typed_reloc "$o" || rc=$?
      fi
      return "$rc"
      ;;
    Linux)
      # PLATFORM: LINUX — product emit is ELF, not macho. Keep overlay.
      touch "$stamp"
      rm -f src/.pabi_w314_macho_write.stamp src/.pabi_w370_macho_write.stamp \
        src/.pabi_w370b_macho_write.stamp src/.pabi_w612_typed_reloc_forward.stamp
      log "pipeline_abi w612-macho-write-page21: LINUX stamp-only (ELF writer)"
      return 0
      ;;
  esac
  touch "$stamp"
  log "pipeline_abi w612-macho-write-page21: non-POSIX stamp-only"
  return 0
}

# wave612: leftover modlet lea was rebound to append_reloc_typed_pabi_superseded
# when elf_ctx PREFER injected. Darwin ld -r -alias that leftover spelling to
# the live typed authority so ADRP writes the PREFER sidecar the writer reads.
# inject_thin_leaf unique-redefine cannot intercept in-pabi callers.
# PLATFORM: MACOS only. Idempotent if addresses already match.
pipeline_abi_darwin_alias_leftover_typed_reloc() {
  local o="$1"
  local live="_pipeline_elf_ctx_append_reloc_typed"
  local leftover="_pipeline_elf_ctx_append_reloc_typed_pabi_superseded"
  local live_addr leftover_addr tmp
  [ "$(uname -s)" = Darwin ] || return 0
  [ -s "$o" ] || return 0
  live_addr=$(nm -m "$o" | awk '/ _pipeline_elf_ctx_append_reloc_typed$/{print $1; exit}')
  leftover_addr=$(nm -m "$o" | awk '/ _pipeline_elf_ctx_append_reloc_typed_pabi_superseded$/{print $1; exit}')
  if [ -z "$live_addr" ] || [ -z "$leftover_addr" ]; then
    return 0
  fi
  if [ "$live_addr" = "$leftover_addr" ]; then
    return 0
  fi
  tmp=$(mktemp "${o}.alias.XXXXXX")
  if ld -r -o "$tmp" "$o" -alias "$live" "$leftover"; then
    mv -f "$tmp" "$o"
    log "pipeline_abi w612: Darwin alias leftover typed → live PAGE21 sidecar"
    return 0
  fi
  rm -f "$tmp"
  return 1
}

# wave398/493/738 M2: unused_hints Cap residual.
# PRODUCT inject wave493:
#   tipU heal (no-local mid `x=call()` → tipU 17/17).
#   tip PREFER → L2 SEGV 0/5 both probes → BAN pure-asm (smash leftover era).
#   LINUX stayed -E+$CC; MACOS keep w398 PREFER overlay.
# wave738 M2: standalone -c U-complete both ends (T=7 U=17). Smash leftover
#   families already -E healed (w598–w608). LINUX product leftover gcc W
#   (endbr64, sub $0x30, size 0x13b) → PREFER_ASM T (no host-cc).
#   MACOS keep prior PREFER overlay (do not re-inject Darwin ld -r).
#   Do not fall back to -E for this TU.
# G.7: thin body matches runtime_pipeline_abi.x pipeline_typeck_unused_binding_hints.
# PLATFORM: SHARED · MACOS keep overlay / LINUX PREFER_ASM replace.
pipeline_abi_inject_unused_hints_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_unused_hints_thin.x"
  local stamp="src/.pabi_w493_unused_hints.stamp"
  local stamp_prefer="src/.pabi_w738_unused_hints_prefer.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: MACOS — keep w398 PREFER overlay; do not re-inject.
  if [ "$(uname -s)" != "Linux" ]; then
    touch "$stamp"
    touch "$stamp_prefer"
    rm -f src/.pabi_w398_unused_hints.stamp
    log "pipeline_abi w738-unused-hints: MACOS keep prior PREFER overlay"
    return 0
  fi
  if [ -f "$stamp_prefer" ] && [ ! "$thin_x" -nt "$stamp_prefer" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: LINUX — product PREFER_ASM first-wins leftover gcc W.
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w738-unused-hints-prefer"
  rc=$?
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    touch "$stamp_prefer"
    rm -f src/.pabi_w398_unused_hints.stamp
    log "pipeline_abi w738-unused-hints: LINUX PREFER_ASM replace (no host-cc for this TU)"
  fi
  return "$rc"
}

# Cap-fn-ptr (10.3.2) / wave507: EXPR_AS peer-flat tip PREFER.
# G.7: gate + cast_orch + sub-orch + arms + lea; LEA spell stays
#   pipe_modlet_lea_fn_sym_to_rax. Monolith tip T001/CG002 after i→f32
#   i64mov; peers tipU-complete.
# wave606: leftover PREFER glue_emit_as_cast_orch_elf_c smash
#   (`sub $0x898`, no endbr64) drops the INDEX operand of `as`
#   (`return b[2] as i32` leaves eax=last ARRAY_LIT store). Gate /
#   lea / f2i orch are the same smash leftover T. Darwin overlay
#   already emits the load. LINUX -E replace the family. HARD BAN
#   PREFER. MACOS stamp-only keep overlay. Do not Soft-Cap.
# wave751: classify thin frame. Live unique AS = leftover gcc W monolith
#   pipeline_asm_emit_as_elf_impl (Darwin weak sub #0x1a0 / LINUX W
#   endbr64 sub $0x170 size 0xe91). Peer cast_orch/orch/arms/lea absent
#   from product pabi. Gate -c smash sub $0x888/#0x890; cast_orch -c
#   smash sub $0x898/#0x8a0. Stamp skip correct. Do NOT re-PREFER.
#   Do NOT gcc -E as the repair. Not leftover-first.
# PLATFORM: SHARED shell · LINUX gold + MACOS.
pipeline_abi_inject_fnptr_as_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_fnptr_as_thin.x"
  local stamp="src/.pabi_w507_fnptr_as.stamp"
  local stamp_e="src/.pabi_w606_fnptr_as.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  local p_peer p_x p_rest p_stamp p_tag
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # wave751: stamp skip keeps leftover gcc W monolith; re-PREFER / tip -E BAN.
  # Skip when w606 stamp is fresh vs every peer thin.
  if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ]; then
    local _ok=1
    for p_peer in \
      "src/runtime_pipeline_abi_fnptr_as_f2i32_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_f2i64_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f32_i32_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f32_i64mov_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f32_u64_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f32_i64_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f32_k15_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f32_sf64_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f64_u64_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f64_i64_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f64_i64mov_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f64_i32_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f64_f32_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_f2i_orch_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f32_orch_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_i2f64_orch_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_lea_thin.x" \
      "src/runtime_pipeline_abi_fnptr_as_cast_orch_thin.x"
    do
      if [ -f "$p_peer" ] && [ "$p_peer" -nt "$stamp_e" ]; then
        _ok=0
        break
      fi
    done
    if [ "$_ok" = "1" ]; then
      return 0
    fi
  fi
  case "$(uname -s)" in
    Darwin)
      # PLATFORM: MACOS — overlay already emits INDEX load for `as`.
      touch "$stamp"
      touch "$stamp_e"
      log "pipeline_abi w606-fnptr-as: MACOS keep prior overlay; HARD BAN PREFER"
      return 0
      ;;
    Linux)
      # PLATFORM: LINUX — -E replace smash leftover PREFER T family.
      ;;
    *)
      touch "$stamp"
      touch "$stamp_e"
      log "pipeline_abi w606-fnptr-as: non-POSIX stamp-only (keep prior)"
      return 0
      ;;
  esac
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1  # wave621: stale-era smash wall re-verified
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  # Arms → sub-orch → lea → cast_orch → gate (first-wins ld -r).
  for p_peer in \
    "src/runtime_pipeline_abi_fnptr_as_f2i32_thin.x|.pabi_w507_fnptr_as_f2i32.stamp|w606-fnptr-as-f2i32-e" \
    "src/runtime_pipeline_abi_fnptr_as_f2i64_thin.x|.pabi_w507_fnptr_as_f2i64.stamp|w606-fnptr-as-f2i64-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f32_i32_thin.x|.pabi_w507_fnptr_as_i2f32_i32.stamp|w606-fnptr-as-i2f32-i32-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f32_i64mov_thin.x|.pabi_w507_fnptr_as_i2f32_i64mov.stamp|w606-fnptr-as-i2f32-i64mov-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f32_u64_thin.x|.pabi_w507_fnptr_as_i2f32_u64.stamp|w606-fnptr-as-i2f32-u64-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f32_i64_thin.x|.pabi_w507_fnptr_as_i2f32_i64.stamp|w606-fnptr-as-i2f32-i64-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f32_k15_thin.x|.pabi_w507_fnptr_as_i2f32_k15.stamp|w606-fnptr-as-i2f32-k15-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f32_sf64_thin.x|.pabi_w507_fnptr_as_i2f32_sf64.stamp|w606-fnptr-as-i2f32-sf64-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f64_u64_thin.x|.pabi_w507_fnptr_as_i2f64_u64.stamp|w606-fnptr-as-i2f64-u64-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f64_i64_thin.x|.pabi_w507_fnptr_as_i2f64_i64.stamp|w606-fnptr-as-i2f64-i64-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f64_i64mov_thin.x|.pabi_w507_fnptr_as_i2f64_i64mov.stamp|w606-fnptr-as-i2f64-i64mov-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f64_i32_thin.x|.pabi_w507_fnptr_as_i2f64_i32.stamp|w606-fnptr-as-i2f64-i32-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f64_f32_thin.x|.pabi_w507_fnptr_as_i2f64_f32.stamp|w606-fnptr-as-i2f64-f32-e" \
    "src/runtime_pipeline_abi_fnptr_as_f2i_orch_thin.x|.pabi_w507_fnptr_as_f2i_orch.stamp|w606-fnptr-as-f2i-orch-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f32_orch_thin.x|.pabi_w507_fnptr_as_i2f32_orch.stamp|w606-fnptr-as-i2f32-orch-e" \
    "src/runtime_pipeline_abi_fnptr_as_i2f64_orch_thin.x|.pabi_w507_fnptr_as_i2f64_orch.stamp|w606-fnptr-as-i2f64-orch-e" \
    "src/runtime_pipeline_abi_fnptr_as_lea_thin.x|.pabi_w507_fnptr_as_lea.stamp|w606-fnptr-as-lea-e" \
    "src/runtime_pipeline_abi_fnptr_as_cast_orch_thin.x|.pabi_w507_fnptr_as_cast_orch.stamp|w606-fnptr-as-cast-orch-e" \
    "src/runtime_pipeline_abi_fnptr_as_thin.x|.pabi_w507_fnptr_as.stamp|w606-fnptr-as-gate-e"
  do
    p_x="${p_peer%%|*}"
    p_rest="${p_peer#*|}"
    p_stamp="src/${p_rest%%|*}"
    p_tag="${p_rest#*|}"
    if [ -f "$p_x" ]; then
      pipeline_abi_inject_thin_leaf "$o" "$p_x" "$p_tag"
      rc=$?
      if [ "$rc" -eq 0 ]; then
        touch "$p_stamp"
      else
        break
      fi
    fi
  done
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    touch "$stamp_e"
    log "pipeline_abi w606-fnptr-as: LINUX -E replace (smash leftover T family)"
  fi
  return "$rc"
}

# wave441/460–w471: assign_index family Cap residual.
# wave607: leftover PREFER smash T (`sub $0xb98`/`$0x1098`, no endbr64)
#   extra pop+store overwrites u8 `b[2]=7` (first movb 7 is correct;
#   later pops store stack garbage over the same dest). Darwin overlay
#   stores once. LINUX -E of complete thins. HARD BAN PREFER.
#   MACOS stamp-only keep overlay. Do not Soft-Cap. Do not -E
#   setup/walk/peel/resolve (w541–w546 Soft-Cap keep overlay).
# wave748: leftover from_x wipe drops glue_emit_assign_index_* from pabi
#   (stamps still skip). Live unique INDEX is leftover gcc
#   pipeline_asm_emit_assign_elf_c inline (Darwin weak / LINUX W
#   endbr64 sub $0x238), not this peel. Standalone -c T=1 U=6 still
#   smash (`sub $0xb98` / `#0xba0`). b[2]=7 run=7 / a[0]=9 run=9 on
#   leftover. Do NOT re-PREFER (dead peel, or dest-overwrite if
#   assign_emit_thin is also PREFERed — w452 BAN). Not the w746/w747
#   leftover-wipe class. Do not gcc -E as the repair.
# PLATFORM: SHARED shell · LINUX gold + MACOS.

# wave764 Class P: Linux g05 UNDEF heal for assign_index setup/resolve.
# Root: w607 mid -E inject leaves T callers; w543/w546 Soft-Cap BAN tip
# reinject left stamps while leftover wipe dropped defs → nm -u UNDEF at
# pure-ld. Heal ONLY when symbol is undefined (link surface). Do not reopen
# HARD BAN classification; do not Soft-Cap tip PREFER when already T.
# PLATFORM: LINUX gold · MACOS no-op (overlay keep) · WINDOWS no-op.
pipeline_abi_heal_assign_index_undef() {
  local o="$1"
  local u_syms need_setup=0 need_resolve=0 need_walk=0 need_peel=0
  local saved_prefer saved_e_repl had_prefer=0 had_e_repl=0 rc=0
  [ -s "$o" ] || return 0
  case "$(uname -s)" in
    Linux) ;;
    *) return 0 ;;
  esac
  u_syms=$(nm -u "$o" 2>/dev/null | awk '{print $NF}')
  case "$u_syms" in
    *glue_emit_assign_index_setup_elf_c*) need_setup=1 ;;
  esac
  case "$u_syms" in
    *glue_emit_assign_index_array_resolve_elf_c*) need_resolve=1 ;;
  esac
  case "$u_syms" in
    *glue_emit_assign_index_array_walk_elf_c*) need_walk=1 ;;
  esac
  case "$u_syms" in
    *glue_emit_assign_index_array_peel_elf_c*) need_peel=1 ;;
  esac
  local has_mid=0
  if nm -g "$o" 2>/dev/null | grep -E ' [Tt] glue_emit_assign_index_(bulk|array|named|simd|struct_lit|generic)_elf_c' >/dev/null; then
    has_mid=1
  fi
  if [ "$need_setup" = "0" ] && [ "$need_resolve" = "0" ] \
    && [ "$need_walk" = "0" ] && [ "$need_peel" = "0" ] && [ "$has_mid" = "0" ]; then
    return 0
  fi
  if [ "$has_mid" = "1" ]; then
    need_setup=1
    need_resolve=1
    need_walk=1
    need_peel=1
  fi
  log "pipeline_abi Class P heal assign_index (link stubs): setup=$need_setup walk=$need_walk peel=$need_peel resolve=$need_resolve mid=$has_mid"
  # Soft-Cap -E tip bodies SEGV on Ubuntu product (w543/w546). Use fail-closed
  # C stubs for link only; live INDEX stays leftover emit_assign (w748).
  local stub_c="seeds/assign_index_undef_link_stubs.c"
  local stub_o base_o
  if [ ! -f "$stub_c" ]; then
    log "pipeline_abi Class P heal: missing $stub_c"
    return 1
  fi
  stub_o="$(mktemp "${TMPDIR:-/tmp}/pabi_idx_stub.XXXXXX.o")"
  base_o="$(mktemp "${TMPDIR:-/tmp}/pabi_idx_base.XXXXXX.o")"
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$stub_o" "$stub_c" 2>/dev/null; then
    log "pipeline_abi Class P heal: cc stubs failed"
    rm -f "$stub_o" "$base_o"
    return 1
  fi
  cp -f "$o" "$base_o"
  # If Soft-Cap tip T already present (bad prior heal), weaken then stub overlay.
  if pipeline_abi_thin_already_defined "$o" "$stub_o"; then
    pipeline_abi_weaken_thin_syms_in_obj "$base_o" "$stub_o" || true
  fi
  if ! pure_ld_partial_merge "$o" "$stub_o" "$base_o" 2>/dev/null; then
    cp -f "$base_o" "$o"
    log "pipeline_abi Class P heal: ld -r stubs failed; restored"
    rm -f "$stub_o" "$base_o"
    return 1
  fi
  rm -f "$stub_o" "$base_o"
  if nm -u "$o" 2>/dev/null | grep -q 'glue_emit_assign_index_setup_elf_c\|glue_emit_assign_index_array_resolve_elf_c'; then
    log "pipeline_abi Class P heal: still UNDEF after stubs"
    return 1
  fi
  log "pipeline_abi Class P heal assign_index UNDEF: OK (link stubs)"
  return 0
}

pipeline_abi_inject_assign_index_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_assign_index_thin.x"
  local stamp="src/.pabi_w460_heal_index.stamp"
  local stamp_e="src/.pabi_w607_assign_index.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  local p_peer p_x p_rest p_stamp p_tag
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # wave748: stamp skip is correct. Live unique INDEX is leftover
  # gcc emit_assign inline; re-PREFER of this smash peel is BAN even
  # when glue_emit_assign_index_* is missing from pabi (leftover-wipe
  # of a dead overlay, not of a live unique T).
  if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ]; then
    local _ok=1
    for p_peer in \
      "src/runtime_pipeline_abi_assign_index_struct_lit_arr_thin.x" \
      "src/runtime_pipeline_abi_assign_index_struct_lit_rbx_thin.x" \
      "src/runtime_pipeline_abi_assign_index_simd_body_thin.x" \
      "src/runtime_pipeline_abi_assign_index_named_body_thin.x" \
      "src/runtime_pipeline_abi_assign_index_bulk_lval_thin.x" \
      "src/runtime_pipeline_abi_assign_index_bulk_call_thin.x" \
      "src/runtime_pipeline_abi_assign_index_array_lit_home_thin.x" \
      "src/runtime_pipeline_abi_assign_index_array_lit_mid_thin.x" \
      "src/runtime_pipeline_abi_assign_index_array_rbx_thin.x" \
      "src/runtime_pipeline_abi_assign_index_generic_try_thin.x" \
      "src/runtime_pipeline_abi_assign_index_generic_try2_thin.x" \
      "src/runtime_pipeline_abi_assign_index_generic_scaled_thin.x" \
      "src/runtime_pipeline_abi_assign_index_struct_lit_thin.x" \
      "src/runtime_pipeline_abi_assign_index_simd_thin.x" \
      "src/runtime_pipeline_abi_assign_index_named_thin.x" \
      "src/runtime_pipeline_abi_assign_index_array_lit_thin.x" \
      "src/runtime_pipeline_abi_assign_index_array_thin.x" \
      "src/runtime_pipeline_abi_assign_index_bulk_thin.x" \
      "src/runtime_pipeline_abi_assign_index_generic_thin.x"
    do
      if [ -f "$p_peer" ] && [ "$p_peer" -nt "$stamp_e" ]; then
        _ok=0
        break
      fi
    done
    if [ "$_ok" = "1" ]; then
      # Class P: stamp skip still heals setup/resolve UNDEF (link surface).
      pipeline_abi_heal_assign_index_undef "$o" || true
      return 0
    fi
  fi
  case "$(uname -s)" in
    Darwin)
      # PLATFORM: MACOS — overlay already stores u8 index once.
      touch "$stamp"
      touch "$stamp_e"
      log "pipeline_abi w607-assign-index: MACOS keep prior overlay; HARD BAN PREFER"
      pipeline_abi_heal_assign_index_undef "$o" || true
      return 0
      ;;
    Linux)
      # PLATFORM: LINUX — -E replace smash leftover PREFER T family.
      ;;
    *)
      touch "$stamp"
      touch "$stamp_e"
      log "pipeline_abi w607-assign-index: non-POSIX stamp-only (keep prior)"
      return 0
      ;;
  esac
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1  # wave621: stale-era smash wall re-verified
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  # Leaves → mid dispatchers → tip (first-wins ld -r).
  for p_peer in \
    "src/runtime_pipeline_abi_assign_index_struct_lit_arr_thin.x|.pabi_w463_heal_index_struct_lit_arr.stamp|w607-assign-index-struct-lit-arr-e" \
    "src/runtime_pipeline_abi_assign_index_struct_lit_rbx_thin.x|.pabi_w465_heal_index_struct_lit_rbx.stamp|w607-assign-index-struct-lit-rbx-e" \
    "src/runtime_pipeline_abi_assign_index_simd_body_thin.x|.pabi_w466_heal_index_simd_body.stamp|w607-assign-index-simd-body-e" \
    "src/runtime_pipeline_abi_assign_index_named_body_thin.x|.pabi_w467_heal_index_named_body.stamp|w607-assign-index-named-body-e" \
    "src/runtime_pipeline_abi_assign_index_bulk_lval_thin.x|.pabi_w468_heal_index_bulk_lval.stamp|w607-assign-index-bulk-lval-e" \
    "src/runtime_pipeline_abi_assign_index_bulk_call_thin.x|.pabi_w468_heal_index_bulk_call.stamp|w607-assign-index-bulk-call-e" \
    "src/runtime_pipeline_abi_assign_index_array_lit_home_thin.x|.pabi_w469_heal_index_array_lit_home.stamp|w607-assign-index-array-lit-home-e" \
    "src/runtime_pipeline_abi_assign_index_array_lit_mid_thin.x|.pabi_w469_heal_index_array_lit_mid.stamp|w607-assign-index-array-lit-mid-e" \
    "src/runtime_pipeline_abi_assign_index_array_rbx_thin.x|.pabi_w464_heal_index_array_rbx.stamp|w607-assign-index-array-rbx-e" \
    "src/runtime_pipeline_abi_assign_index_generic_try_thin.x|.pabi_w471_heal_index_generic_try.stamp|w607-assign-index-generic-try-e" \
    "src/runtime_pipeline_abi_assign_index_generic_try2_thin.x|.pabi_w471_heal_index_generic_try2.stamp|w607-assign-index-generic-try2-e" \
    "src/runtime_pipeline_abi_assign_index_generic_scaled_thin.x|.pabi_w471_heal_index_generic_scaled.stamp|w607-assign-index-generic-scaled-e" \
    "src/runtime_pipeline_abi_assign_index_struct_lit_thin.x|.pabi_w461_heal_index_struct_lit.stamp|w607-assign-index-struct-lit-e" \
    "src/runtime_pipeline_abi_assign_index_simd_thin.x|.pabi_w466_heal_index_simd.stamp|w607-assign-index-simd-e" \
    "src/runtime_pipeline_abi_assign_index_named_thin.x|.pabi_w467_heal_index_named.stamp|w607-assign-index-named-e" \
    "src/runtime_pipeline_abi_assign_index_array_lit_thin.x|.pabi_w469_heal_index_array_lit.stamp|w607-assign-index-array-lit-e" \
    "src/runtime_pipeline_abi_assign_index_array_thin.x|.pabi_w462_heal_index_array.stamp|w607-assign-index-array-e" \
    "src/runtime_pipeline_abi_assign_index_bulk_thin.x|.pabi_w468_heal_index_bulk.stamp|w607-assign-index-bulk-e" \
    "src/runtime_pipeline_abi_assign_index_generic_thin.x|.pabi_w471_heal_index_generic.stamp|w607-assign-index-generic-e" \
    "src/runtime_pipeline_abi_assign_index_thin.x|.pabi_w460_heal_index.stamp|w607-assign-index-gate-e"
  do
    p_x="${p_peer%%|*}"
    p_rest="${p_peer#*|}"
    p_stamp="src/${p_rest%%|*}"
    p_tag="${p_rest#*|}"
    if [ -f "$p_x" ]; then
      pipeline_abi_inject_thin_leaf "$o" "$p_x" "$p_tag"
      rc=$?
      if [ "$rc" -eq 0 ]; then
        touch "$p_stamp"
      else
        break
      fi
    fi
  done
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    touch "$stamp_e"
    log "pipeline_abi w607-assign-index: LINUX -E replace (smash leftover T family)"
  fi
  if [ "$rc" -eq 0 ]; then
    pipeline_abi_heal_assign_index_undef "$o" || true
  fi
  return "$rc"
}

# wave409/419/431/495/739 M2: asm_expr Cap residual — asymmetric unlock.
# PRODUCT inject wave495:
#   tipU heal (no-local mid `x=call()` → tipU 35/35 both full+helpers).
#   tip helpers PREFER → L2 FAIL (rv=232／opt SEGV／hello) → BAN pure-asm.
#   MACOS: PREFER_ASM full thin (stamp w495).
#   LINUX: stayed -E+$CC helpers (stamp w495 helpers; tipU heal via host-cc).
#     Full emit_expr_elf_c tip reinject still BAN on LINUX.
# wave739 M2: standalone -c U-complete both ends (helpers T=2 U=35). Smash
#   leftover families already -E healed (w598–w608). LINUX product leftover
#   gcc W rec (endbr64, sub $0x50, size 0x6a1) → PREFER_ASM T (no host-cc).
#   MACOS keep prior full-thin PREFER overlay (do not re-inject Darwin ld -r).
#   Do not fall back to -E for this TU. Full emit_expr_elf_c tip still BAN.
# wave752: classify full tip. Live tip = leftover gcc W wrapper (Darwin
#   weak sub #0x40 / LINUX W endbr64 sub $0x20 size 0x3e → call rec).
#   Full -c tip smash sub $0x888/#0x890. HARD BAN PREFER tip remains.
#   Do NOT tip PREFER / tip -E as repair. Not leftover-first.
# G.7: thin body matches mega; LINUX leftover holds emit_expr_elf_c tip.
# PLATFORM: SHARED · MACOS full PREFER keep / LINUX helpers PREFER_ASM.
pipeline_abi_inject_asm_expr_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_asm_expr_thin.x"
  local stamp="src/.pabi_w495_asm_expr.stamp"
  local stamp_prefer="src/.pabi_w739_asm_expr_helpers_prefer.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # wave752: tip HARD BAN PREFER; MACOS keep overlay; LINUX helpers-only.
  # PLATFORM: MACOS — keep w495 full PREFER overlay; do not re-inject.
  if [ "$(uname -s)" != "Linux" ]; then
    touch "$stamp"
    touch "$stamp_prefer"
    rm -f src/.pabi_w419_asm_expr.stamp src/.pabi_w409_asm_expr.stamp src/.pabi_w431_asm_expr_helpers.stamp
    log "pipeline_abi w739-asm-expr: MACOS keep prior full PREFER overlay"
    return 0
  fi
  # PLATFORM: LINUX — helpers PREFER_ASM first-wins leftover gcc W rec.
  thin_x="src/runtime_pipeline_abi_asm_expr_helpers_thin.x"
  stamp="src/.pabi_w495_asm_expr_helpers.stamp"
  [ -f "$thin_x" ] || return 0
  if [ -f "$stamp_prefer" ] && [ ! "$thin_x" -nt "$stamp_prefer" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w739-asm-expr-helpers-prefer"
  rc=$?
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    touch "$stamp_prefer"
    rm -f src/.pabi_w419_asm_expr.stamp src/.pabi_w409_asm_expr.stamp src/.pabi_w431_asm_expr_helpers.stamp
    log "pipeline_abi w739-asm-expr: LINUX PREFER_ASM replace (no host-cc for rec TU)"
  fi
  return "$rc"
}

# wave399 M2: fnptr_array_esz Cap residual — unlock PREFER_ASM both ends.
# PRODUCT inject wave399: PREFER_ASM (ALLOW_E_REPLACE + stamp). Standalone
# -c green both ends (Darwin 5713B / Ubuntu 6734B); was class-E default -E.
# Seed rest holds strong glue_array_lit_force_esz_from_elem_type_c /
# glue_fixed_array_temp_bytes — weaken then first-wins thin (no mega -E).
# wave496: tipU heal (no-local pipe cells); stamp → w496; keep PREFER both.
# wave605: leftover PREFER pipeline_asm_array_lit_elem_byte_sz_c smash
#   (`sub $0xb38`, no endbr64) returns 4 for u8 ARRAY_LIT, so flatten
#   stores `mov %eax, off(%rbx)` (i32) instead of byte. Darwin overlay
#   already `strb`. LINUX -E replace leftover T. HARD BAN PREFER.
#   MACOS keep Darwin overlay. Do not Soft-Cap. Do not BAN the other
#   remaining U-complete PREFER families.
# wave750: classify thin frame. Live unique = leftover gcc W of the three
#   exports (Darwin weak / LINUX W endbr64 small frames). Standalone -c
#   still smash (sub $0xb38 / #0xb40 on elem_byte_sz). Stamp skip correct.
#   Do NOT re-PREFER (dest-overwrite). Do NOT gcc -E as the repair.
#   Not leftover-first. Same class as w749 call_arg_lea (W live, smash thin).
# G.7: thin body matches runtime_pipeline_abi.x. PLATFORM: SHARED.
pipeline_abi_inject_fnptr_array_esz_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_fnptr_array_esz_thin.x"
  local stamp="src/.pabi_w496_fnptr_array_esz.stamp"
  local stamp_e="src/.pabi_w605_fnptr_array_esz.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  case "$(uname -s)" in
    Darwin)
      # PLATFORM: MACOS — overlay already stores u8 ARRAY_LIT as strb.
      # wave750: stamp skip keeps weak live; HARD BAN PREFER smash thin.
      if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ]; then
        return 0
      fi
      touch "$stamp"
      touch "$stamp_e"
      log "pipeline_abi w605-fnptr-arr-esz: MACOS keep prior overlay; HARD BAN PREFER"
      return 0
      ;;
    Linux)
      # PLATFORM: LINUX — -E replace smash leftover PREFER T.
      # wave750: stamp skip keeps leftover gcc W live; re-PREFER / tip -E BAN.
      if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ]; then
        return 0
      fi
      local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
      local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
      local had_prefer=0 had_e_repl=0 rc=0
      if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
      if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
      unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1  # wave621: stale-era smash wall re-verified
      export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
      pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w605-fnptr-arr-esz-e"
      rc=$?
      if [ "$had_prefer" = "1" ]; then
        export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
      else
        unset XLANG_PABI_THIN_PREFER_ASM
      fi
      if [ "$had_e_repl" = "1" ]; then
        export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
      else
        unset XLANG_PABI_THIN_ALLOW_E_REPLACE
      fi
      if [ "$rc" -eq 0 ]; then
        touch "$stamp"
        touch "$stamp_e"
        log "pipeline_abi w605-fnptr-arr-esz: LINUX -E replace (smash leftover T)"
      fi
      return "$rc"
      ;;
  esac
  touch "$stamp"
  touch "$stamp_e"
  log "pipeline_abi w605-fnptr-arr-esz: non-POSIX stamp-only (keep prior)"
  return 0
}

# wave396/498/502/503/514/594/611/613/615/746 M2: wpo_dump Cap residual.
# wave498: tip PREFER omitted export (Ubuntu file-tail parse_skip from
#   append_i32 onward). LINUX stayed -E; MACOS stamp-only keep overlay.
# wave597: grow_vec -E restored realloc/mmap; standalone -backend asm -c
#   of this helpers thin now emits append_i32 + the export both ends
#   (Darwin T=24 UND=39; Ubuntu T=24 UND=39).
# wave611 M2 diagnose:
#   · Darwin current-thin -c is U-complete but g05 ld rejects
#     ARM64_RELOC_BRANCH26 on COMMON Lxml adrp+add (r_address=0x3454 in
#     w502_wpo_collect_all). Origin = untyped default reloc on file-level
#     let lea; authority = glue_asm_lea_rax_common_adrp_arm64 PAGE21/12.
#     FIXED by wave612 / re-closed wave743 leftover-gcc reloc sidecar
#     (standalone thin PAGE21-on-adrp / BRANCH26-on-bl only; r_address
#     0x3454 is now PAGE21 on _Lxml_f091ea8477a2a1c3).
#   · Ubuntu current-thin PREFER first-wins links and L2 5/5 (getenv unset),
#     but XLANG_WPO_DUMP_CALLGRAPH dump path SEGV 139. Smash leftover dump
#     still writes JSON v2. Same class as orch *i32 store (w594 BAN).
#     ROOT-CAUSED by wave613: COMMON misclassification at the writers (dual
#     sidecar instances) pinned the thin's Lxml cells into read-only
#     __TEXT/__text — the dump path's first write faulted on BOTH ends.
#     Fixed by the ctx shndx==65522 single-authority classification.
# wave613 M2: MACOS product PREFER_ASM (dump probe JSON v2 green, L2 5/5).
# wave615 M2: LINUX product PREFER_ASM re-verify on top of the w613 COMMON
#   fix + w614 dual-end L4 (ELF writer side shipped).
# wave746 M2: leftover from_x rebuild wiped the PREFER overlay (live dump
#   is leftover gcc Darwin weak / LINUX W, endbr64 sub $0x1c0) while
#   w615 stamps still skipped. Standalone thin is U-complete both ends
#   (T=24 U=39, Lxml COMMON, Darwin PAGE21=52 PAGOF12=52 nsects=1).
#   Re-PREFER when live dump is leftover gcc weak/W. Do not gcc -E as
#   the repair. Do not Darwin ld -r merge a two-segment thin (this thin
#   is nsects=1 + COMMON). orch stamp skip stays (not this knife).
# wave754: classify orch. Live dump = main thin PREFER T (sub ~$0xa18 /
#   #0xa20). Orch -c smash export $0xcc8/#0xcd0. HARD BAN orch PREFER.
#   No named CG002 wall this tip. Do not leftover-first.
# G.7: thin/orch body match runtime_pipeline_abi.x pipeline_typeck_wpo_dump_callgraph.
# PLATFORM: SHARED · PREFER_ASM both ends (main); orch stamp-gated.
pipeline_abi_inject_wpo_dump_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_wpo_dump_thin.x"
  local stamp="src/.pabi_w498_wpo_dump.stamp"
  local stamp_prefer="src/.pabi_w615_wpo_dump_prefer.stamp"
  local orch_x="src/runtime_pipeline_abi_wpo_dump_orch_thin.x"
  local orch_s="src/.pabi_w594_wpo_dump_orch.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # wave622: orch product PREFER both ends. The w503/514/594 "L2 SEGV 0/5"
  # wall was the w613 COMMON class (orch's file-level let cells pinned
  # read-only — standalone -c now T=10 UND=21, 6 cells proper commons;
  # product probe on a fresh rebuild-only .o: g05 links, dump JSON v2
  # 233B, L2 5/5). Stamp-gated like the main thin.
  # wave754: stamp skip keeps orch out; live dump face stays main thin T.
  if [ -f "$orch_x" ]; then
    if [ ! -f "$orch_s" ] || [ "$orch_x" -nt "$orch_s" ]; then
      local o_saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
      local o_saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
      local o_had_prefer=0 o_had_e_repl=0 o_rc=0
      if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then o_had_prefer=1; fi
      if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then o_had_e_repl=1; fi
      unset XLANG_PABI_THIN_INJECT_IF_NEWER
      export XLANG_PABI_THIN_PREFER_ASM=1
      export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
      pipeline_abi_inject_thin_leaf "$o" "$orch_x" "w622-wpo-dump-orch-prefer"
      o_rc=$?
      if [ "$o_had_prefer" = "1" ]; then
        export XLANG_PABI_THIN_PREFER_ASM="$o_saved_prefer"
      else
        unset XLANG_PABI_THIN_PREFER_ASM
      fi
      if [ "$o_had_e_repl" = "1" ]; then
        export XLANG_PABI_THIN_ALLOW_E_REPLACE="$o_saved_e_repl"
      else
        unset XLANG_PABI_THIN_ALLOW_E_REPLACE
      fi
      if [ "$o_rc" -eq 0 ]; then
        touch "$orch_s"
        rm -f src/.pabi_w503_wpo_dump_orch.stamp src/.pabi_w514_wpo_dump_orch.stamp
        log "pipeline_abi w622-wpo-dump-orch: PREFER_ASM replace (no host-cc for this TU)"
      fi
    fi
  fi
  # wave615 M2: LINUX product PREFER_ASM too — this TU is now zero host-cc on
  #   BOTH ends. w611's "Ubuntu dump SEGV 139" root cause was the COMMON
  #   misclassification w613 fixed at the writers (ctx shndx==65522 single
  #   authority): the thin's Lxml cells were pinned read-only __TEXT/__text
  #   and the dump path's first write faulted. The ELF writer side of that
  #   fix shipped and dual-end-L4-verified in w614 (@45f8c48ec). Stamp-gated
  #   identically on both platforms.
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ] && [ -f "$stamp_prefer" ]; then
    # w746: leftover from_x rebuild wipes PREFER but stamps still skip.
    # Re-inject when live dump is leftover gcc Darwin weak / LINUX W.
    # PLATFORM: SHARED nm — Darwin `nm -m` "weak"; LINUX `nm -g` " W ".
    if ! nm -m "$o" 2>/dev/null | grep 'pipeline_typeck_wpo_dump_callgraph$' | grep -q 'weak' \
      && ! nm -g "$o" 2>/dev/null | grep 'pipeline_typeck_wpo_dump_callgraph$' | grep -q ' W '; then
      return 0
    fi
    log "pipeline_abi w746-wpo-dump: live leftover gcc weak/W; re-PREFER"
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — product PREFER_ASM both ends (wave613 MACOS,
  #   wave615 LINUX re-verify after the w613/w614 COMMON + cold-chain fixes;
  #   wave746 leftover-wipe re-PREFER).
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w746-wpo-dump-prefer"
  rc=$?
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    touch "$stamp_prefer"
    touch src/.pabi_w746_wpo_dump_prefer.stamp
    rm -f src/.pabi_w611_wpo_dump_prefer.stamp src/.pabi_w613_wpo_dump_prefer.stamp
    log "pipeline_abi w746-wpo-dump: PREFER_ASM replace (no host-cc for this TU)"
  fi
  return "$rc"
}


# wave631/646 M2: modlet family ONE-set — root fix of the w629 dual-table split
# wave646: MACOS skip removed — the strong writer seed (w645,
#   seeds/pabi_strong_writer.from_x.c) resolves the CG002 writer layer
#   (rest cold prepare vs chunk-lane weak hot find/load/lea →
#   addr_of(&module_scalar_cell) CG002 -99 / monofile mov $0).
#   runtime_pipeline_abi_modlet_thin.x carries the whole family + table +
#   companion state in ONE member (standalone -c green: T=228 UND=28,
#   40 commons). PREFER both ends, stamp-gated (.pabi_w631 prefer stamp).
#   Do not -E; do not split the family.
# PLATFORM: SHARED — PREFER_ASM both ends.
pipeline_abi_inject_modlet_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_modlet_thin.x"
  local stamp="src/.pabi_w631_modlet.stamp"
  local stamp_prefer="src/.pabi_w631_modlet_prefer.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ] && [ -f "$stamp_prefer" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then had_newer=1; fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w631-modlet-prefer"
  rc=$?
  if [ "$had_newer" = "1" ]; then export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"; fi
  if [ "$had_prefer" = "1" ]; then export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"; else unset XLANG_PABI_THIN_PREFER_ASM; fi
  if [ "$had_e_repl" = "1" ]; then export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"; else unset XLANG_PABI_THIN_ALLOW_E_REPLACE; fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    touch "$stamp_prefer"
    # wave645/646: merge the strong writer .o to override the all-weak
    # G05_X_O_WEAK=1 platform_macho_write (cc -r weak-vs-strong → strong wins).
    local strong_x="seeds/pabi_strong_writer.from_x.c"
    local strong_o="src/pabi_strong_writer.o"
    if [ -f "$strong_x" ] && { [ ! -f "$strong_o" ] || [ "$strong_x" -nt "$strong_o" ]; }; then
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$strong_o" "$strong_x" 2>/dev/null || true
    fi
    if [ -s "$strong_o" ]; then
      local merged_o
      merged_o="$(mktemp "${TMPDIR:-/tmp}/pabi_strong_merge.XXXXXX")"
      if cc -r -nostdlib -o "$merged_o" "$o" "$strong_o" 2>/dev/null; then
        mv -f "$merged_o" "$o"
      else
        rm -f "$merged_o" 2>/dev/null || true
      fi
    fi
    log "pipeline_abi w631-modlet: PREFER_ASM replace + strong writer (ONE-set)"
  fi
  return "$rc"
}

# wave402/432/494/610 M2: param_ptr_slot Cap residual.
# wave494: tipU 19/19; tip PREFER then L2 opt=77 (leftover smash in the
#   compiler's assign/deref family). LINUX stayed -E; MACOS stamp-only.
# wave610 M2: standalone PREFER is U-complete both ends (T=3 UND=19,
#   PLT32 to glue_emit_module_from_ctx / pipe_* / kind_ord). Compiler
#   assign_var/deref/rhs_to_rax are gcc -E after w598–w600, so this
#   thin's own -backend asm -c now emits the ptr-load walk. Product
#   path is PREFER_ASM both ends. Do not fall back to -E.
# G.7: thin body matches runtime_pipeline_abi.x glue_local_var_slot_needs_ptr_load_elf_c.
# PLATFORM: SHARED · PREFER_ASM first-wins · LINUX gold + MACOS.
pipeline_abi_inject_param_ptr_slot_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_param_ptr_slot_thin.x"
  local stamp="src/.pabi_w494_param_ptr_slot.stamp"
  local stamp_prefer="src/.pabi_w610_param_ptr_slot_prefer.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ] && [ -f "$stamp_prefer" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — product PREFER_ASM (wave610). First-wins over leftover T.
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w610-param-ptr-slot-prefer"
  rc=$?
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    touch "$stamp_prefer"
    rm -f src/.pabi_w432_param_ptr_slot.stamp src/.pabi_w402_param_ptr_slot.stamp
    log "pipeline_abi w610-param-ptr-slot: PREFER_ASM replace (no host-cc for this TU)"
  fi
  return "$rc"
}

# host-C type_to_c_repr SLICE `*`→`_p` sanitizer family.
# G.7: .x thin matches mega; inject_thin_leaf class E.
# wave397/412/434 M2: type_to_c_repr Cap residual — asymmetric helpers unlock.
# PRODUCT inject wave412:
#   MACOS: PREFER_ASM full thin (helpers+main; -c green; product L2 verified).
#   LINUX: PREFER_ASM helpers-only thin (cg_ttc_* + kind/vector/append;
#     Ubuntu helpers -c ~6100B green). Full tip -c XT001@cg_ttc MISATTRIBUTED
#     — root = LINUX typeck/arena on large main body (short main+helpers green;
#     full main alone parse-skip). Main leaf tip reinject still BAN.
# wave434: LINUX named+array_slice+main PREFER — co-file NAMED+ARRAY/SLICE
#   → Ubuntu XT001/empty; split peer thins (named ~2000B / as ~5726B /
#   main dispatcher ~2548B). MACOS stays full thin.
# wave480: LINUX named no-local PREFER — tip U=1/2 (`name_len=call()` drop)
#   → tip U=2/2; stamp w480. array_slice+main stamps stay w434 until healed.
# wave482: LINUX array_slice no-local PREFER — tip U=1/7 (`x=call()` drop) →
#   tip U=4/4 via pipe_store/load cells; stamp w482. main stays w434.
# wave483: LINUX main peer-flat no-local PREFER — tip U=2/10 → 12/12
#   (ptr/vec/named_fb peers + gate); stamp w483.
# wave539: LINUX helpers tipU 0/0 (drop 5 unused externs) HARD BAN tip
#   reinject; stamp w539. named/array_slice/main stay w480/w482/w483.
# G.7: helpers/named/array_slice/main match mega / full thin authority.
# Seed C-extract markers remain cold twin only (not product inject path).
# PLATFORM: SHARED · MACOS full PREFER / LINUX helpers BAN + named+as+main PREFER.
pipeline_abi_inject_type_to_c_repr_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_type_to_c_repr_thin.x"
  local stamp="src/.pabi_w412_type_to_c_repr.stamp"
  local tag="w412-type-to-c-repr"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  local named_x named_stamp as_x as_stamp main_x main_stamp
  local need_main=0
  # PLATFORM: LINUX — helpers then named + array_slice + main tip PREFER.
  case "$(uname -s)" in
    Linux)
      thin_x="src/runtime_pipeline_abi_type_to_c_repr_helpers_thin.x"
      stamp="src/.pabi_w539_type_to_c_repr_helpers.stamp"
      tag="w539-type-to-c-repr-helpers"
      named_x="src/runtime_pipeline_abi_type_to_c_repr_named_thin.x"
      named_stamp="src/.pabi_w480_type_to_c_repr_named.stamp"
      as_x="src/runtime_pipeline_abi_type_to_c_repr_array_slice_thin.x"
      as_stamp="src/.pabi_w482_type_to_c_repr_array_slice.stamp"
      main_x="src/runtime_pipeline_abi_type_to_c_repr_main_thin.x"
      main_stamp="src/.pabi_w483_type_to_c_repr_main.stamp"
      ;;
  esac
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # wave483: any main peer stamp stale → force inject path
  if [ "$(uname -s)" = "Linux" ]; then
    local _mp _mx _ms
    for _mp in \
      "src/runtime_pipeline_abi_type_to_c_repr_main_ptr_thin.x|.pabi_w483_type_to_c_repr_main_ptr.stamp" \
      "src/runtime_pipeline_abi_type_to_c_repr_main_vec_thin.x|.pabi_w483_type_to_c_repr_main_vec.stamp" \
      "src/runtime_pipeline_abi_type_to_c_repr_main_named_fb_thin.x|.pabi_w483_type_to_c_repr_main_named_fb.stamp" \
      "src/runtime_pipeline_abi_type_to_c_repr_main_thin.x|.pabi_w483_type_to_c_repr_main.stamp"
    do
      _mx="${_mp%%|*}"
      _ms="src/${_mp#*|}"
      if [ -f "$_mx" ] && { [ ! -f "$_ms" ] || [ "$_mx" -nt "$_ms" ]; }; then
        need_main=1
        break
      fi
    done
  fi
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    if [ -n "${named_x-}" ] && [ -f "$named_x" ]; then
      if [ -f "$named_stamp" ] && [ ! "$named_x" -nt "$named_stamp" ] \
        && [ -f "$as_stamp" ] && [ ! "$as_x" -nt "$as_stamp" ] \
        && [ "$need_main" = "0" ]; then
        return 0
      fi
    else
      return 0
    fi
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — PREFER_ASM for the leaf selected above.
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  # PLATFORM: LINUX — wave539 Soft Cap HARD BAN helpers tip reinject.
  # Dead extern decls dropped in .x; do not prefer-reinject this leaf.
  # MACOS still PREFER-injects the full thin selected above.
  if [ "$(uname -s)" = "Linux" ]; then
    touch "$stamp"
    rm -f src/.pabi_w412_type_to_c_repr_helpers.stamp
    log "pipeline_abi w539-type-to-c-repr-helpers: tipU 0/0 stamped; tip PRODUCT reinject HARD BAN (keep prior)"
    rc=0
  elif [ ! -f "$stamp" ] || [ "$thin_x" -nt "$stamp" ]; then
    pipeline_abi_inject_thin_leaf "$o" "$thin_x" "$tag"
    rc=$?
    if [ "$rc" -eq 0 ]; then
      touch "$stamp"
    fi
  else
    rc=0
  fi
  # PLATFORM: LINUX — named then array_slice then main peers+gate.
  if [ "$rc" -eq 0 ] && [ -n "${named_x-}" ] && [ -f "$named_x" ]; then
    if [ ! -f "$named_stamp" ] || [ "$named_x" -nt "$named_stamp" ]; then
      pipeline_abi_inject_thin_leaf "$o" "$named_x" "w480-type-to-c-repr-named"
      rc=$?
      if [ "$rc" -eq 0 ]; then
        touch "$named_stamp"
        rm -f src/.pabi_w434_type_to_c_repr_named.stamp
      fi
    fi
  fi
  if [ "$rc" -eq 0 ] && [ -n "${as_x-}" ] && [ -f "$as_x" ]; then
    if [ ! -f "$as_stamp" ] || [ "$as_x" -nt "$as_stamp" ]; then
      pipeline_abi_inject_thin_leaf "$o" "$as_x" "w482-type-to-c-repr-array-slice"
      rc=$?
      if [ "$rc" -eq 0 ]; then
        touch "$as_stamp"
        rm -f src/.pabi_w434_type_to_c_repr_array_slice.stamp
      fi
    fi
  fi
  # PLATFORM: LINUX — wave483 main ptr→vec→named_fb→gate.
  if [ "$rc" -eq 0 ] && [ "$(uname -s)" = "Linux" ]; then
    local tm_x tm_rest tm_stamp tm_tag
    for tm_peer in \
      "src/runtime_pipeline_abi_type_to_c_repr_main_ptr_thin.x|.pabi_w483_type_to_c_repr_main_ptr.stamp|w483-type-to-c-repr-main-ptr" \
      "src/runtime_pipeline_abi_type_to_c_repr_main_vec_thin.x|.pabi_w483_type_to_c_repr_main_vec.stamp|w483-type-to-c-repr-main-vec" \
      "src/runtime_pipeline_abi_type_to_c_repr_main_named_fb_thin.x|.pabi_w483_type_to_c_repr_main_named_fb.stamp|w483-type-to-c-repr-main-named-fb" \
      "src/runtime_pipeline_abi_type_to_c_repr_main_thin.x|.pabi_w483_type_to_c_repr_main.stamp|w483-type-to-c-repr-main"
    do
      tm_x="${tm_peer%%|*}"
      tm_rest="${tm_peer#*|}"
      tm_stamp="src/${tm_rest%%|*}"
      tm_tag="${tm_rest#*|}"
      if [ -f "$tm_x" ] && { [ ! -f "$tm_stamp" ] || [ "$tm_x" -nt "$tm_stamp" ]; }; then
        pipeline_abi_inject_thin_leaf "$o" "$tm_x" "$tm_tag"
        rc=$?
        if [ "$rc" -eq 0 ]; then
          touch "$tm_stamp"
          if [ "$tm_tag" = "w483-type-to-c-repr-main" ]; then
            rm -f src/.pabi_w434_type_to_c_repr_main.stamp
          fi
        else
          break
        fi
      fi
    done
  fi
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  return "$rc"
}

# wave407/417/422/423/426/435 M2: binop_block_peel Cap residual — helpers+rest unlock.
# PRODUCT inject wave423:
#   MACOS: PREFER_ASM full thin (product L2 verified).
#   LINUX: helpers (transparent) + may_clobber rest (w422) + load_to_rbx rest
#     (w423; peers extern→leftover).
# wave426: try_binop_load / index_addr rest-only Darwin -c green; LINUX HARD
#   BAN (Ubuntu asm empty .o). Stamps local; no tip overlay.
# wave435: LINUX index_ko47 + index_addr PREFER — INDEX arm co-file XT001
#   split (ko47 ~1687B / walker ~1919B Ubuntu -c green).
# wave479: LINUX ko47 peer-flat (slice/ty11/base_kind/fa/lit+gate) +
#   index_addr peer-flat (await/as/field/deref+walker) no-local PREFER.
#   Root: tip U=1/8 (`let x=call()` / deep nest drop). Stamps w479.
# wave436: LINUX load_operand PREFER — flat peer chain (nested if under
#   if(ko==N)/deep nests empties Ubuntu asm; single-level if + leaf calls).
#   Order: leaves→const→var_rbx→var_rax→var_ko3→rest_arms→main dispatcher.
# G.7: bodies match mega / full thin semantics (flat reshape).
# PLATFORM: SHARED · MACOS full PREFER / LINUX helpers+rest+index+load_operand PREFER.
pipeline_abi_inject_binop_block_peel_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_binop_block_peel_thin.x"
  local stamp="src/.pabi_w423_binop_block_peel.stamp"
  local tag="w423-binop-block-peel"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  local rest_x rest_stamp
  local idx_ko idx_ko_s idx_main idx_main_s
  local lo_main lo_main_s
  local need_idx=0
  # PLATFORM: LINUX — helpers then may_clobber rest (middle tip BAN).
  case "$(uname -s)" in
    Linux)
      thin_x="src/runtime_pipeline_abi_binop_block_peel_helpers_thin.x"
      stamp="src/.pabi_w554_binop_block_peel_helpers.stamp"
      tag="w422-binop-block-peel-helpers"
      rest_x="src/runtime_pipeline_abi_binop_block_peel_rest_thin.x"
      rest_stamp="src/.pabi_w549_binop_block_peel_rest.stamp"
      idx_ko="src/runtime_pipeline_abi_binop_block_peel_index_ko47_thin.x"
      idx_ko_s="src/.pabi_w479_binop_block_peel_index_ko47.stamp"
      idx_main="src/runtime_pipeline_abi_binop_block_peel_index_addr_thin.x"
      idx_main_s="src/.pabi_w479_binop_block_peel_index_addr.stamp"
      lo_main="src/runtime_pipeline_abi_binop_block_peel_load_operand_thin.x"
      lo_main_s="src/.pabi_w553_binop_block_peel_load_operand.stamp"
      ;;
  esac
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # wave479: any ko47/index_addr peer stamp stale → force inject path
  if [ "$(uname -s)" = "Linux" ]; then
    local _ip _ix _is
    for _ip in \
      "src/runtime_pipeline_abi_binop_block_peel_index_ko47_slice_thin.x|.pabi_w479_binop_block_peel_index_ko47_slice.stamp" \
      "src/runtime_pipeline_abi_binop_block_peel_index_ko47_ty11_thin.x|.pabi_w479_binop_block_peel_index_ko47_ty11.stamp" \
      "src/runtime_pipeline_abi_binop_block_peel_index_ko47_base_kind_thin.x|.pabi_w479_binop_block_peel_index_ko47_base_kind.stamp" \
      "src/runtime_pipeline_abi_binop_block_peel_index_ko47_fa_thin.x|.pabi_w479_binop_block_peel_index_ko47_fa.stamp" \
      "src/runtime_pipeline_abi_binop_block_peel_index_ko47_lit_thin.x|.pabi_w479_binop_block_peel_index_ko47_lit.stamp" \
      "src/runtime_pipeline_abi_binop_block_peel_index_ko47_thin.x|.pabi_w479_binop_block_peel_index_ko47.stamp" \
      "src/runtime_pipeline_abi_binop_block_peel_index_addr_await_thin.x|.pabi_w479_binop_block_peel_index_addr_await.stamp" \
      "src/runtime_pipeline_abi_binop_block_peel_index_addr_as_thin.x|.pabi_w479_binop_block_peel_index_addr_as.stamp" \
      "src/runtime_pipeline_abi_binop_block_peel_index_addr_field_thin.x|.pabi_w479_binop_block_peel_index_addr_field.stamp" \
      "src/runtime_pipeline_abi_binop_block_peel_index_addr_deref_thin.x|.pabi_w479_binop_block_peel_index_addr_deref.stamp" \
      "src/runtime_pipeline_abi_binop_block_peel_index_addr_thin.x|.pabi_w479_binop_block_peel_index_addr.stamp"
    do
      _ix="${_ip%%|*}"
      _is="src/${_ip#*|}"
      if [ -f "$_ix" ] && { [ ! -f "$_is" ] || [ "$_ix" -nt "$_is" ]; }; then
        need_idx=1
        break
      fi
    done
  fi
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    # helpers up-to-date; still try rest / index / load_operand overlays on LINUX
    if [ -n "${rest_x-}" ] && [ -f "$rest_x" ]; then
      if [ -f "$rest_stamp" ] && [ ! "$rest_x" -nt "$rest_stamp" ] \
        && [ "$need_idx" = "0" ] \
        && [ -f "$lo_main_s" ] && [ ! "$lo_main" -nt "$lo_main_s" ]; then
        # also need load_to_rbx stamp check
        local l2s_chk="src/.pabi_w550_binop_block_peel_load_to_rbx.stamp"
        local l2x_chk="src/runtime_pipeline_abi_binop_block_peel_load_to_rbx_thin.x"
        if [ -f "$l2s_chk" ] && [ ! "$l2x_chk" -nt "$l2s_chk" ]; then
          return 0
        fi
      fi
    else
      return 0
    fi
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — PREFER_ASM for the leaf selected above.
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  # LINUX wave554: helpers tipU stamped. HARD BAN tip PRODUCT reinject
  # (keep the w422 overlay). MACOS still injects the full binop thin.
  if [ "$(uname -s)" = "Linux" ]; then
    if [ -f "$thin_x" ]; then
      touch "$stamp"
      rm -f src/.pabi_w422_binop_block_peel_helpers.stamp
      log "pipeline_abi w554 binop_block_peel_helpers: tipU stamped; tip PRODUCT reinject HARD BAN"
    fi
    rc=0
  elif [ ! -f "$stamp" ] || [ "$thin_x" -nt "$stamp" ]; then
    pipeline_abi_inject_thin_leaf "$o" "$thin_x" "$tag"
    rc=$?
    if [ "$rc" -eq 0 ]; then
      touch "$stamp"
    fi
  else
    rc=0
  fi
  # PLATFORM: LINUX — wave549 Soft Cap: may_clobber rest tipU stamped.
  # HARD BAN tip PRODUCT reinject (keep the w422 overlay).
  if [ "$rc" -eq 0 ] && [ -n "${rest_x-}" ] && [ -f "$rest_x" ]; then
    touch "$rest_stamp"
    rm -f src/.pabi_w422_binop_block_peel_rest.stamp
    log "pipeline_abi w549 binop_block_peel_rest: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # PLATFORM: LINUX — wave550 Soft Cap: load_to_rbx tipU stamped.
  # HARD BAN tip PRODUCT reinject (keep the w423 overlay).
  if [ "$rc" -eq 0 ] && [ "$(uname -s)" = "Linux" ]; then
    local l2x="src/runtime_pipeline_abi_binop_block_peel_load_to_rbx_thin.x"
    local l2s="src/.pabi_w550_binop_block_peel_load_to_rbx.stamp"
    if [ -f "$l2x" ]; then
      touch "$l2s"
      rm -f src/.pabi_w423_binop_block_peel_load_to_rbx.stamp
      log "pipeline_abi w550 load_to_rbx: tipU stamped; tip PRODUCT reinject HARD BAN"
    fi
  fi
  # PLATFORM: LINUX — wave479 ko47 peers→gate then index_addr peers→walker.
  # Order: slice→ty11→base_kind→fa→lit→ko47 gate → await→as→field→deref→addr.
  if [ "$rc" -eq 0 ] && [ "$(uname -s)" = "Linux" ]; then
    local ik_x ik_rest ik_stamp ik_tag
    for ik_peer in \
      "src/runtime_pipeline_abi_binop_block_peel_index_ko47_slice_thin.x|.pabi_w479_binop_block_peel_index_ko47_slice.stamp|w479-binop-block-peel-index-ko47-slice" \
      "src/runtime_pipeline_abi_binop_block_peel_index_ko47_ty11_thin.x|.pabi_w479_binop_block_peel_index_ko47_ty11.stamp|w479-binop-block-peel-index-ko47-ty11" \
      "src/runtime_pipeline_abi_binop_block_peel_index_ko47_base_kind_thin.x|.pabi_w479_binop_block_peel_index_ko47_base_kind.stamp|w479-binop-block-peel-index-ko47-base-kind" \
      "src/runtime_pipeline_abi_binop_block_peel_index_ko47_fa_thin.x|.pabi_w479_binop_block_peel_index_ko47_fa.stamp|w479-binop-block-peel-index-ko47-fa" \
      "src/runtime_pipeline_abi_binop_block_peel_index_ko47_lit_thin.x|.pabi_w479_binop_block_peel_index_ko47_lit.stamp|w479-binop-block-peel-index-ko47-lit" \
      "src/runtime_pipeline_abi_binop_block_peel_index_ko47_thin.x|.pabi_w479_binop_block_peel_index_ko47.stamp|w479-binop-block-peel-index-ko47" \
      "src/runtime_pipeline_abi_binop_block_peel_index_addr_await_thin.x|.pabi_w479_binop_block_peel_index_addr_await.stamp|w479-binop-block-peel-index-addr-await" \
      "src/runtime_pipeline_abi_binop_block_peel_index_addr_as_thin.x|.pabi_w479_binop_block_peel_index_addr_as.stamp|w479-binop-block-peel-index-addr-as" \
      "src/runtime_pipeline_abi_binop_block_peel_index_addr_field_thin.x|.pabi_w479_binop_block_peel_index_addr_field.stamp|w479-binop-block-peel-index-addr-field" \
      "src/runtime_pipeline_abi_binop_block_peel_index_addr_deref_thin.x|.pabi_w479_binop_block_peel_index_addr_deref.stamp|w479-binop-block-peel-index-addr-deref" \
      "src/runtime_pipeline_abi_binop_block_peel_index_addr_thin.x|.pabi_w479_binop_block_peel_index_addr.stamp|w479-binop-block-peel-index-addr"
    do
      ik_x="${ik_peer%%|*}"
      ik_rest="${ik_peer#*|}"
      ik_stamp="src/${ik_rest%%|*}"
      ik_tag="${ik_rest#*|}"
      if [ -f "$ik_x" ] && { [ ! -f "$ik_stamp" ] || [ "$ik_x" -nt "$ik_stamp" ]; }; then
        pipeline_abi_inject_thin_leaf "$o" "$ik_x" "$ik_tag"
        rc=$?
        if [ "$rc" -eq 0 ]; then
          touch "$ik_stamp"
          # Retire w435 stamps so prefer does not double-gate on stale name
          case "$ik_tag" in
            w479-binop-block-peel-index-ko47)
              rm -f src/.pabi_w435_binop_block_peel_index_ko47.stamp
              ;;
            w479-binop-block-peel-index-addr)
              rm -f src/.pabi_w435_binop_block_peel_index_addr.stamp
              ;;
          esac
        else
          break
        fi
      fi
    done
  fi
  # PLATFORM: LINUX — wave436 load_operand flat peer chain then dispatcher.
  if [ "$rc" -eq 0 ] && [ "$(uname -s)" = "Linux" ]; then
    local lo_peer lo_x lo_stamp lo_tag lo_rest
    for lo_peer in \
      "src/runtime_pipeline_abi_binop_block_peel_load_operand_leaves_thin.x|.pabi_w555_binop_block_peel_load_operand_leaves.stamp|w555-ban-load-operand-leaves" \
      "src/runtime_pipeline_abi_binop_block_peel_load_operand_const_thin.x|.pabi_w548_binop_block_peel_load_operand_const.stamp|w548-ban-load-operand-const" \
      "src/runtime_pipeline_abi_binop_block_peel_load_operand_var_rbx_thin.x|.pabi_w552_binop_block_peel_load_operand_var_rbx.stamp|w552-ban-load-operand-var-rbx" \
      "src/runtime_pipeline_abi_binop_block_peel_load_operand_var_rax_thin.x|.pabi_w551_binop_block_peel_load_operand_var_rax.stamp|w551-ban-load-operand-var-rax" \
      "src/runtime_pipeline_abi_binop_block_peel_load_operand_var_ko3_thin.x|.pabi_w547_binop_block_peel_load_operand_var_ko3.stamp|w547-ban-load-operand-var-ko3" \
      "src/runtime_pipeline_abi_binop_block_peel_load_operand_rest_arms_thin.x|.pabi_w556_binop_block_peel_load_operand_rest_arms.stamp|w556-ban-load-operand-rest-arms" \
      "src/runtime_pipeline_abi_binop_block_peel_load_operand_thin.x|.pabi_w553_binop_block_peel_load_operand.stamp|w553-ban-load-operand"
    do
      lo_x="${lo_peer%%|*}"
      lo_rest="${lo_peer#*|}"
      lo_stamp="src/${lo_rest%%|*}"
      lo_tag="${lo_rest#*|}"
      # wave547 Soft Cap: var_ko3 tipU stamped; HARD BAN tip PRODUCT reinject.
      case "$lo_x" in
        *load_operand_var_ko3_thin.x)
          if [ -f "$lo_x" ]; then
            touch "$lo_stamp"
            rm -f src/.pabi_w436_binop_block_peel_load_operand_var_ko3.stamp
            log "pipeline_abi w547 load_operand_var_ko3: tipU stamped; tip PRODUCT reinject HARD BAN"
          fi
          continue
          ;;
        *load_operand_const_thin.x)
          if [ -f "$lo_x" ]; then
            touch "$lo_stamp"
            rm -f src/.pabi_w436_binop_block_peel_load_operand_const.stamp
            log "pipeline_abi w548 load_operand_const: tipU stamped; tip PRODUCT reinject HARD BAN"
          fi
          continue
          ;;
        *load_operand_var_rax_thin.x)
          if [ -f "$lo_x" ]; then
            touch "$lo_stamp"
            rm -f src/.pabi_w436_binop_block_peel_load_operand_var_rax.stamp
            log "pipeline_abi w551 load_operand_var_rax: tipU stamped; tip PRODUCT reinject HARD BAN"
          fi
          continue
          ;;
        *load_operand_var_rbx_thin.x)
          if [ -f "$lo_x" ]; then
            touch "$lo_stamp"
            rm -f src/.pabi_w436_binop_block_peel_load_operand_var_rbx.stamp
            log "pipeline_abi w552 load_operand_var_rbx: tipU stamped; tip PRODUCT reinject HARD BAN"
          fi
          continue
          ;;
        *binop_block_peel_load_operand_thin.x)
          if [ -f "$lo_x" ]; then
            touch "$lo_stamp"
            rm -f src/.pabi_w436_binop_block_peel_load_operand.stamp
            log "pipeline_abi w553 load_operand: tipU stamped; tip PRODUCT reinject HARD BAN"
          fi
          continue
          ;;
        *load_operand_leaves_thin.x)
          if [ -f "$lo_x" ]; then
            touch "$lo_stamp"
            rm -f src/.pabi_w436_binop_block_peel_load_operand_leaves.stamp
            log "pipeline_abi w555 load_operand_leaves: tipU stamped; tip PRODUCT reinject HARD BAN"
          fi
          continue
          ;;
        *load_operand_rest_arms_thin.x)
          if [ -f "$lo_x" ]; then
            touch "$lo_stamp"
            rm -f src/.pabi_w436_binop_block_peel_load_operand_rest_arms.stamp
            log "pipeline_abi w556 load_operand_rest_arms: tipU stamped; tip PRODUCT reinject HARD BAN"
          fi
          continue
          ;;
      esac
      if [ -f "$lo_x" ] && { [ ! -f "$lo_stamp" ] || [ "$lo_x" -nt "$lo_stamp" ]; }; then
        pipeline_abi_inject_thin_leaf "$o" "$lo_x" "$lo_tag"
        rc=$?
        if [ "$rc" -eq 0 ]; then
          touch "$lo_stamp"
        else
          break
        fi
      fi
    done
  fi
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  return "$rc"
}

# wave403/413/416/420/421/425/437 M2: assign Cap residual — asymmetric helpers unlock.
# PRODUCT inject wave421:
#   MACOS: PREFER_ASM full thin (helpers+exports; product L2 verified).
#   LINUX: PREFER_ASM helpers thin = lhs+rhs + field_pair+body_stmt
#     (skip poison middle rhs_to_rax/emit_assign — contiguous grow XT001;
#     Ubuntu -c ~6101B; product inject+relink L2 5/5 opt=102).
# wave425: rhsrax rest-only thin (Darwin -c ~6425B) — LINUX HARD BAN
#   (Ubuntu asm -c empty .o; -E omits T; false inject +80B). Stamp
#   .pabi_w425_assign_rhsrax.stamp; no tip overlay.
# wave426: emit_assign rest-only (Darwin -c ~50KB) — LINUX HARD BAN
#   (Ubuntu empty .o; -E omits T). Same class as rhsrax.
# wave437: LINUX rhsrax PREFER — flat arm helpers (nested if/micro-unsafe
#   emptied .o; Ubuntu -c ~12096B / 14T). emit_assign still BAN.
# wave441/445/448/449/451: LINUX emit unlock — flat peer FIELD/INDEX/VAR/DEREF + dispatcher.
#   w441b soft -E chain; w445 six-peer pure-asm overlay (`*out=` heal);
#   tip rhsrax to_rax pure-asm HARD BAN (si SEGV); w448 arms-only PREFER overlay;
#   w449 deref family PREFER; w451 var no-local PREFER; emit tip HARD BAN
#   (w452 no-local reshape tip→si CG002; stay -E);
#   w457 emit hybrid tip→si CG002; field no-local tip U-starved (假绿) BAN;
#   w454 to_rax dispatcher no-local PREFER (arms stay w448).
#   w599 LINUX -E replace smash leftover to_rax; HARD BAN PREFER.
# G.7: helpers+rhsrax+emit peers match mega / full thin semantics.
# PLATFORM: SHARED · MACOS full PREFER / LINUX -E chain + w445/w448/w449/w451/w454 heal-asm.
pipeline_abi_inject_assign_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_assign_thin.x"
  local stamp="src/.pabi_w421_assign.stamp"
  local tag="w421-assign"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  local rhs_x rhs_s
  local arms_x arms_s
  local var_x var_s
  local torax_x torax_s
  local emit_x emit_s peer lo_x lo_stamp lo_tag lo_rest
  local need_emit=0
  local need_heal=0
  local need_arms=0
  local need_deref=0
  local need_var=0
  local need_torax=0
  # PLATFORM: LINUX — helpers -E; rhsrax full -E (w445);
  #   arms PREFER (w448); to_rax dispatcher LINUX -E (w599; PREFER BAN);
  #   emit chain -E (w441b); six-peer heal-asm (w445);
  #   deref family PREFER (w449); var no-local PREFER (w451);
  #   emit tip BAN (w452 no-local tip→si CG002).
  case "$(uname -s)" in
    Linux)
      thin_x="src/runtime_pipeline_abi_assign_helpers_thin.x"
      stamp="src/.pabi_w558_assign_helpers.stamp"
      tag="w421-assign-helpers"
      rhs_x="src/runtime_pipeline_abi_assign_rhsrax_thin.x"
      rhs_s="src/.pabi_w559_assign_rhsrax.stamp"
      arms_x="src/runtime_pipeline_abi_assign_rhsrax_arms_load_lr_thin.x"
      arms_s="src/.pabi_w474_heal_rhsrax_arms_load_lr.stamp"
      torax_x="src/runtime_pipeline_abi_assign_rhsrax_to_rax_thin.x"
      torax_s="src/.pabi_w454_assign_rhsrax_to_rax.stamp"
      emit_x="src/runtime_pipeline_abi_assign_emit_thin.x"
      emit_s="src/.pabi_w445_assign_emit.stamp"
      var_x="src/runtime_pipeline_abi_assign_var_thin.x"
      var_s="src/.pabi_w473_heal_var.stamp"
      ;;
  esac
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  if [ -n "${emit_x-}" ] && [ -f "$emit_x" ]; then
    if [ ! -f "$emit_s" ] || [ "$emit_x" -nt "$emit_s" ]; then
      need_emit=1
    fi
  fi
  if [ -n "${arms_x-}" ] && [ -f "$arms_x" ]; then
    if [ ! -f "$arms_s" ] || [ "$arms_x" -nt "$arms_s" ]; then
      need_arms=1
    fi
  fi
  # wave474: other rhsrax arm leaves also gate need_arms
  if [ "$need_arms" = "0" ]; then
    for _ap in \
      src/runtime_pipeline_abi_assign_rhsrax_arms_simple_thin.x \
      src/runtime_pipeline_abi_assign_rhsrax_arms_div_float_thin.x \
      src/runtime_pipeline_abi_assign_rhsrax_arms_div_thin.x \
      src/runtime_pipeline_abi_assign_rhsrax_arms_mod_thin.x \
      src/runtime_pipeline_abi_assign_rhsrax_arms_shl_thin.x \
      src/runtime_pipeline_abi_assign_rhsrax_arms_shr_thin.x
    do
      if [ -f "$_ap" ]; then
        case "$_ap" in
          *simple*) _as="src/.pabi_w474_heal_rhsrax_arms_simple.stamp" ;;
          *div_float*) _as="src/.pabi_w474_heal_rhsrax_arms_div_float.stamp" ;;
          *div_thin*) _as="src/.pabi_w474_heal_rhsrax_arms_div.stamp" ;;
          *mod*) _as="src/.pabi_w474_heal_rhsrax_arms_mod.stamp" ;;
          *shl*) _as="src/.pabi_w474_heal_rhsrax_arms_shl.stamp" ;;
          *shr*) _as="src/.pabi_w474_heal_rhsrax_arms_shr.stamp" ;;
        esac
        if [ ! -f "$_as" ] || [ "$_ap" -nt "$_as" ]; then
          need_arms=1
          break
        fi
      fi
    done
  fi
  if [ -n "${torax_x-}" ] && [ -f "$torax_x" ]; then
    if [ ! -f "$torax_s" ] || [ "$torax_x" -nt "$torax_s" ]; then
      need_torax=1
    fi
  fi
  if [ -n "${var_x-}" ] && [ -f "$var_x" ]; then
    if [ ! -f "$var_s" ] || [ "$var_x" -nt "$var_s" ]; then
      need_var=1
    fi
  fi
  # wave445 heal stamps — any missing/stale forces continue past early return.
  case "$(uname -s)" in
    Linux)
      for _hs in \
        src/.pabi_w445_heal_field_chain_walk.stamp \
        src/.pabi_w445_heal_field_mag_fold.stamp \
        src/.pabi_w445_heal_index_setup.stamp \
        src/.pabi_w445_heal_index_array_walk.stamp \
        src/.pabi_w445_heal_index_array_peel.stamp \
        src/.pabi_w445_heal_index_array_resolve.stamp
      do
        _hx="${_hs%.stamp}"
        # map stamp → src file roughly via known names
        :
      done
      for _pair in \
        "src/runtime_pipeline_abi_assign_field_chain_walk_thin.x|src/.pabi_w544_assign_field_chain_walk.stamp" \
        "src/runtime_pipeline_abi_assign_field_mag_fold_thin.x|src/.pabi_w545_assign_field_mag_fold.stamp" \
        "src/runtime_pipeline_abi_assign_index_setup_thin.x|src/.pabi_w543_assign_index_setup.stamp" \
        "src/runtime_pipeline_abi_assign_index_array_walk_thin.x|src/.pabi_w541_assign_index_array_walk.stamp" \
        "src/runtime_pipeline_abi_assign_index_array_peel_thin.x|src/.pabi_w542_assign_index_array_peel.stamp" \
        "src/runtime_pipeline_abi_assign_index_array_resolve_thin.x|src/.pabi_w546_assign_index_array_resolve.stamp" \
        "src/runtime_pipeline_abi_assign_index_simd_body_thin.x|src/.pabi_w466_heal_index_simd_body.stamp" \
        "src/runtime_pipeline_abi_assign_index_simd_thin.x|src/.pabi_w466_heal_index_simd.stamp" \
        "src/runtime_pipeline_abi_assign_index_named_body_thin.x|src/.pabi_w467_heal_index_named_body.stamp" \
        "src/runtime_pipeline_abi_assign_index_named_thin.x|src/.pabi_w467_heal_index_named.stamp" \
        "src/runtime_pipeline_abi_assign_index_bulk_lval_thin.x|src/.pabi_w468_heal_index_bulk_lval.stamp" \
        "src/runtime_pipeline_abi_assign_index_bulk_call_thin.x|src/.pabi_w468_heal_index_bulk_call.stamp" \
        "src/runtime_pipeline_abi_assign_index_bulk_thin.x|src/.pabi_w468_heal_index_bulk.stamp" \
        "src/runtime_pipeline_abi_assign_index_array_lit_home_thin.x|src/.pabi_w469_heal_index_array_lit_home.stamp" \
        "src/runtime_pipeline_abi_assign_index_array_lit_mid_thin.x|src/.pabi_w469_heal_index_array_lit_mid.stamp" \
        "src/runtime_pipeline_abi_assign_index_array_lit_thin.x|src/.pabi_w469_heal_index_array_lit.stamp" \
        "src/runtime_pipeline_abi_assign_field_var_root_finish_thin.x|src/.pabi_w470_heal_field_var_root_finish.stamp" \
        "src/runtime_pipeline_abi_assign_field_var_root_thin.x|src/.pabi_w470_heal_field_var_root.stamp" \
        "src/runtime_pipeline_abi_assign_index_generic_try_thin.x|src/.pabi_w471_heal_index_generic_try.stamp" \
        "src/runtime_pipeline_abi_assign_index_generic_try2_thin.x|src/.pabi_w471_heal_index_generic_try2.stamp" \
        "src/runtime_pipeline_abi_assign_index_generic_scaled_thin.x|src/.pabi_w471_heal_index_generic_scaled.stamp" \
        "src/runtime_pipeline_abi_assign_index_generic_thin.x|src/.pabi_w471_heal_index_generic.stamp" \
        "src/runtime_pipeline_abi_assign_deref_vec_gate_thin.x|src/.pabi_w472_heal_deref_vec_gate.stamp" \
        "src/runtime_pipeline_abi_assign_deref_after_addr_thin.x|src/.pabi_w472_heal_deref_after_addr.stamp" \
        "src/runtime_pipeline_abi_assign_deref_finish_thin.x|src/.pabi_w472_heal_deref_finish.stamp" \
        "src/runtime_pipeline_abi_assign_deref_peel_var_thin.x|src/.pabi_w472_heal_deref_peel_var.stamp" \
        "src/runtime_pipeline_abi_assign_deref_peel_thin.x|src/.pabi_w472_heal_deref_peel.stamp" \
        "src/runtime_pipeline_abi_assign_deref_thin.x|src/.pabi_w472_heal_deref.stamp" \
        "src/runtime_pipeline_abi_assign_var_store_slice_thin.x|src/.pabi_w473_heal_var_store_slice.stamp" \
        "src/runtime_pipeline_abi_assign_var_store_f32_thin.x|src/.pabi_w473_heal_var_store_f32.stamp" \
        "src/runtime_pipeline_abi_assign_var_store_pair_thin.x|src/.pabi_w473_heal_var_store_pair.stamp" \
        "src/runtime_pipeline_abi_assign_var_store_thin.x|src/.pabi_w473_heal_var_store.stamp" \
        "src/runtime_pipeline_abi_assign_var_finish_thin.x|src/.pabi_w473_heal_var_finish.stamp" \
        "src/runtime_pipeline_abi_assign_var_try_let_thin.x|src/.pabi_w473_heal_var_try_let.stamp" \
        "src/runtime_pipeline_abi_assign_var_thin.x|src/.pabi_w473_heal_var.stamp" \
        "src/runtime_pipeline_abi_assign_rhsrax_arms_load_lr_thin.x|src/.pabi_w474_heal_rhsrax_arms_load_lr.stamp" \
        "src/runtime_pipeline_abi_assign_rhsrax_arms_simple_thin.x|src/.pabi_w474_heal_rhsrax_arms_simple.stamp" \
        "src/runtime_pipeline_abi_assign_rhsrax_arms_div_float_thin.x|src/.pabi_w474_heal_rhsrax_arms_div_float.stamp" \
        "src/runtime_pipeline_abi_assign_rhsrax_arms_div_thin.x|src/.pabi_w474_heal_rhsrax_arms_div.stamp" \
        "src/runtime_pipeline_abi_assign_rhsrax_arms_mod_thin.x|src/.pabi_w474_heal_rhsrax_arms_mod.stamp" \
        "src/runtime_pipeline_abi_assign_rhsrax_arms_shl_thin.x|src/.pabi_w474_heal_rhsrax_arms_shl.stamp" \
        "src/runtime_pipeline_abi_assign_rhsrax_arms_shr_thin.x|src/.pabi_w474_heal_rhsrax_arms_shr.stamp" \
        "src/runtime_pipeline_abi_assign_field_ptr_hit_step_thin.x|src/.pabi_w475_heal_field_ptr_hit_step.stamp" \
        "src/runtime_pipeline_abi_assign_field_ptr_hit_thin.x|src/.pabi_w475_heal_field_ptr_hit.stamp" \
        "src/runtime_pipeline_abi_assign_field_var_depth1_thin.x|src/.pabi_w475_heal_field_var_depth1.stamp" \
        "src/runtime_pipeline_abi_assign_field_var_simd_thin.x|src/.pabi_w475_heal_field_var_simd.stamp" \
        "src/runtime_pipeline_abi_assign_field_var_array_thin.x|src/.pabi_w475_heal_field_var_array.stamp" \
        "src/runtime_pipeline_abi_assign_field_var_struct_store_thin.x|src/.pabi_w475_heal_field_var_struct_store.stamp" \
        "src/runtime_pipeline_abi_assign_field_var_struct_pair_thin.x|src/.pabi_w475_heal_field_var_struct_pair.stamp" \
        "src/runtime_pipeline_abi_assign_field_var_struct_thin.x|src/.pabi_w475_heal_field_var_struct.stamp" \
        "src/runtime_pipeline_abi_assign_field_ptr_struct_thin.x|src/.pabi_w476_heal_field_ptr_struct.stamp" \
        "src/runtime_pipeline_abi_assign_field_ptr_array_thin.x|src/.pabi_w476_heal_field_ptr_array.stamp" \
        "src/runtime_pipeline_abi_assign_field_ptr_thin.x|src/.pabi_w476_heal_field_ptr.stamp" \
        "src/runtime_pipeline_abi_assign_field_scalar_thin.x|src/.pabi_w476_heal_field_scalar.stamp" \
        "src/runtime_pipeline_abi_binop_stack_spill_try_reload_rax_thin.x|src/.pabi_w478_heal_spill_reload_rax.stamp" \
        "src/runtime_pipeline_abi_binop_stack_spill_try_reload_rbx_thin.x|src/.pabi_w478_heal_spill_reload_rbx.stamp" \
        "src/runtime_pipeline_abi_binop_stack_spill_try_reload_thin.x|src/.pabi_w478_heal_spill_reload.stamp"
      do
        _hx="${_pair%%|*}"
        _hs="${_pair#*|}"
        if [ -f "$_hx" ] && { [ ! -f "$_hs" ] || [ "$_hx" -nt "$_hs" ]; }; then
          need_heal=1
          break
        fi
      done
      # wave449: deref peer arms PREFER overlay stamps (dispatcher → w472)
      for _pair in \
        "src/runtime_pipeline_abi_assign_deref_vec_var_thin.x|src/.pabi_w533_assign_deref_vec_var.stamp" \
        "src/runtime_pipeline_abi_assign_deref_vec_call_thin.x|src/.pabi_w536_assign_deref_vec_call.stamp" \
        "src/runtime_pipeline_abi_assign_deref_slice_call_thin.x|src/.pabi_w537_assign_deref_slice_call.stamp" \
        "src/runtime_pipeline_abi_assign_deref_array_call_thin.x|src/.pabi_w535_assign_deref_array_call.stamp" \
        "src/runtime_pipeline_abi_assign_deref_let_init_thin.x|src/.pabi_w533_assign_deref_let_init.stamp" \
        "src/runtime_pipeline_abi_assign_deref_scalar_thin.x|src/.pabi_w534_assign_deref_scalar.stamp" \
        "src/runtime_pipeline_abi_assign_deref_vec_gate_thin.x|src/.pabi_w472_heal_deref_vec_gate.stamp" \
        "src/runtime_pipeline_abi_assign_deref_after_addr_thin.x|src/.pabi_w472_heal_deref_after_addr.stamp" \
        "src/runtime_pipeline_abi_assign_deref_finish_thin.x|src/.pabi_w472_heal_deref_finish.stamp" \
        "src/runtime_pipeline_abi_assign_deref_peel_var_thin.x|src/.pabi_w472_heal_deref_peel_var.stamp" \
        "src/runtime_pipeline_abi_assign_deref_peel_thin.x|src/.pabi_w472_heal_deref_peel.stamp" \
        "src/runtime_pipeline_abi_assign_deref_thin.x|src/.pabi_w472_heal_deref.stamp"
      do
        _hx="${_pair%%|*}"
        _hs="${_pair#*|}"
        if [ -f "$_hx" ] && { [ ! -f "$_hs" ] || [ "$_hx" -nt "$_hs" ]; }; then
          need_deref=1
          break
        fi
      done
      ;;
  esac
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    # helpers up-to-date; still try rhsrax / arms / emit / heal / deref / var on LINUX
    if [ -n "${rhs_x-}" ] && [ -f "$rhs_x" ]; then
      if [ -f "$rhs_s" ] && [ ! "$rhs_x" -nt "$rhs_s" ] && [ "$need_emit" = "0" ] && [ "$need_heal" = "0" ] && [ "$need_arms" = "0" ] && [ "$need_torax" = "0" ] && [ "$need_deref" = "0" ] && [ "$need_var" = "0" ]; then
        return 0
      fi
    elif [ "$need_emit" = "0" ] && [ "$need_heal" = "0" ] && [ "$need_arms" = "0" ] && [ "$need_torax" = "0" ] && [ "$need_deref" = "0" ] && [ "$need_var" = "0" ]; then
      return 0
    fi
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — PREFER_ASM for the leaf selected above.
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  # LINUX wave558: assign helpers tipU stamped. HARD BAN tip PRODUCT
  # reinject (keep the w421 overlay). MACOS still injects the full thin.
  if [ "$(uname -s)" = "Linux" ]; then
    if [ -f "$thin_x" ]; then
      touch "$stamp"
      rm -f src/.pabi_w421_assign_helpers.stamp
      log "pipeline_abi w558 assign_helpers: tipU stamped; tip PRODUCT reinject HARD BAN"
    fi
    rc=0
  elif [ ! -f "$stamp" ] || [ "$thin_x" -nt "$stamp" ]; then
    pipeline_abi_inject_thin_leaf "$o" "$thin_x" "$tag"
    rc=$?
    if [ "$rc" -eq 0 ]; then
      touch "$stamp"
    fi
  else
    rc=0
  fi
  # PLATFORM: LINUX — second inject flat rhsrax (wave437/445/448).
  # wave445: tip pure-asm regen of full rhsrax → product si SEGV; reinject -E.
  # wave448: to_rax tip pure-asm HARD BAN (full thin → si SEGV); keep -E here, then
  #   arms-only PREFER overlay; w599 to_rax LINUX -E after arms (PREFER BAN).
  # LINUX wave559: rhsrax tipU stamped. HARD BAN tip PRODUCT reinject
  # (keep the w437 -E overlay). Pure-asm reinject SEGVs (wave445).
  if [ "$rc" -eq 0 ] && [ -n "${rhs_x-}" ] && [ -f "$rhs_x" ]; then
    touch "$rhs_s"
    rm -f src/.pabi_w437_assign_rhsrax.stamp
    log "pipeline_abi w559 assign_rhsrax: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # PLATFORM: LINUX — wave448/w474 arms no-local PREFER (to_rax dispatcher → w454).
  # wave474: seven leaves (load_lr/simple/div_float/div/mod/shl/shr); tip U-complete.
  if [ "$rc" -eq 0 ]; then
    local a_x a_rest a_stamp a_tag
    export XLANG_PABI_THIN_PREFER_ASM=1
    export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
    for peer in \
      "src/runtime_pipeline_abi_assign_rhsrax_arms_load_lr_thin.x|.pabi_w474_heal_rhsrax_arms_load_lr.stamp|w474-heal-rhsrax-arms-load-lr" \
      "src/runtime_pipeline_abi_assign_rhsrax_arms_simple_thin.x|.pabi_w474_heal_rhsrax_arms_simple.stamp|w474-heal-rhsrax-arms-simple" \
      "src/runtime_pipeline_abi_assign_rhsrax_arms_div_float_thin.x|.pabi_w474_heal_rhsrax_arms_div_float.stamp|w474-heal-rhsrax-arms-div-float" \
      "src/runtime_pipeline_abi_assign_rhsrax_arms_div_thin.x|.pabi_w474_heal_rhsrax_arms_div.stamp|w474-heal-rhsrax-arms-div" \
      "src/runtime_pipeline_abi_assign_rhsrax_arms_mod_thin.x|.pabi_w474_heal_rhsrax_arms_mod.stamp|w474-heal-rhsrax-arms-mod" \
      "src/runtime_pipeline_abi_assign_rhsrax_arms_shl_thin.x|.pabi_w474_heal_rhsrax_arms_shl.stamp|w474-heal-rhsrax-arms-shl" \
      "src/runtime_pipeline_abi_assign_rhsrax_arms_shr_thin.x|.pabi_w474_heal_rhsrax_arms_shr.stamp|w474-heal-rhsrax-arms-shr"
    do
      a_x="${peer%%|*}"
      a_rest="${peer#*|}"
      a_stamp="src/${a_rest%%|*}"
      a_tag="${a_rest#*|}"
      if [ -f "$a_x" ] && { [ ! -f "$a_stamp" ] || [ "$a_x" -nt "$a_stamp" ]; }; then
        pipeline_abi_inject_thin_leaf "$o" "$a_x" "$a_tag"
        rc=$?
        if [ "$rc" -eq 0 ]; then
          touch "$a_stamp"
        else
          break
        fi
      fi
    done
  fi
  # wave454: to_rax dispatcher-only no-local PREFER (full to_rax tip still BAN).
  # wave599: leftover PREFER to_rax smashes scalar caller (`sub $0x1158`).
  #   LINUX -E replace; HARD BAN PREFER; MACOS keep overlay.
  # PLATFORM: LINUX gold.
  if [ "$rc" -eq 0 ]; then
    pipeline_abi_inject_rhsrax_to_rax_thin "$o" || rc=$?
  fi
  # wave600 smash was stale-era; family is PREFER both ends since w620.
  #   LINUX -E replace; HARD BAN PREFER; MACOS keep overlay.
  # PLATFORM: LINUX gold.
  if [ "$rc" -eq 0 ]; then
    pipeline_abi_inject_assign_var_thin "$o" || rc=$?
  fi
  # PLATFORM: LINUX — third inject emit peer chain (wave441/445).
  # Order: FIELD leaves → INDEX leaves → VAR → DEREF leaves → arm
  #   dispatchers → emit dispatcher (G.7 first-wins).
  # wave441b: chain via -E (PREFER_ASM=0). Tip regen of to_rax/var/emit
  #   pure-asm → product si SEGV 139; keep soft -E for those tips.
  # wave445: after chain, overlay six `*out=`-healed peers as pure-asm.
  # wave448: rhsrax arms PREFER overlay (above); to_rax stays -E.
  # wave449: deref family PREFER overlay after heals; var+emit stay -E.
  # wave452: emit no-local reshape retained in .x; tip pure-asm still BAN
  #   (si CG002); this -E chain is the product path for emit dispatcher.
  # wave458: after chain+heals+var, LINUX overlays field_var_stores no-local
  #   PREFER (tip `let rc=call()` U-starved → eq-cascade U=4/4).
  if [ "$rc" -eq 0 ] && [ -n "${emit_x-}" ] && [ -f "$emit_x" ]; then
    if [ ! -f "$emit_s" ] || [ "$emit_x" -nt "$emit_s" ]; then
      export XLANG_PABI_THIN_PREFER_ASM=0
      export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
      for peer in \
        "src/runtime_pipeline_abi_assign_field_chain_walk_thin.x|.pabi_w544_assign_field_chain_walk.stamp|w544-ban-field-chain-walk" \
        "src/runtime_pipeline_abi_assign_field_ptr_hit_thin.x|.pabi_w445_assign_field_ptr_hit.stamp|w441-assign-field-ptr-hit" \
        "src/runtime_pipeline_abi_assign_field_mag_fold_thin.x|.pabi_w545_assign_field_mag_fold.stamp|w545-ban-field-mag-fold" \
        "src/runtime_pipeline_abi_assign_field_var_simd_thin.x|.pabi_w445_assign_field_var_simd.stamp|w441-assign-field-var-simd" \
        "src/runtime_pipeline_abi_assign_field_var_struct_thin.x|.pabi_w445_assign_field_var_struct.stamp|w441-assign-field-var-struct" \
        "src/runtime_pipeline_abi_assign_field_var_array_thin.x|.pabi_w445_assign_field_var_array.stamp|w441-assign-field-var-array" \
        "src/runtime_pipeline_abi_assign_field_var_depth1_thin.x|.pabi_w445_assign_field_var_depth1.stamp|w441-assign-field-var-depth1" \
        "src/runtime_pipeline_abi_assign_field_var_stores_thin.x|.pabi_w445_assign_field_var_stores.stamp|w441-assign-field-var-stores" \
        "src/runtime_pipeline_abi_assign_field_var_root_finish_thin.x|.pabi_w445_assign_field_var_root_finish.stamp|w441-assign-field-var-root-finish" \
        "src/runtime_pipeline_abi_assign_field_var_root_thin.x|.pabi_w445_assign_field_var_root.stamp|w441-assign-field-var-root" \
        "src/runtime_pipeline_abi_assign_field_ptr_thin.x|.pabi_w445_assign_field_ptr.stamp|w441-assign-field-ptr" \
        "src/runtime_pipeline_abi_assign_field_scalar_thin.x|.pabi_w445_assign_field_scalar.stamp|w441-assign-field-scalar" \
        "src/runtime_pipeline_abi_assign_field_thin.x|.pabi_w445_assign_field.stamp|w441-assign-field" \
        "src/runtime_pipeline_abi_assign_index_setup_thin.x|.pabi_w543_assign_index_setup.stamp|w543-ban-index-setup" \
        "src/runtime_pipeline_abi_assign_index_struct_lit_arr_thin.x|.pabi_w445_assign_index_struct_lit_arr.stamp|w441-assign-index-struct-lit-arr" \
        "src/runtime_pipeline_abi_assign_index_struct_lit_rbx_thin.x|.pabi_w445_assign_index_struct_lit_rbx.stamp|w441-assign-index-struct-lit-rbx" \
        "src/runtime_pipeline_abi_assign_index_struct_lit_thin.x|.pabi_w445_assign_index_struct_lit.stamp|w441-assign-index-struct-lit" \
        "src/runtime_pipeline_abi_assign_index_simd_body_thin.x|.pabi_w445_assign_index_simd_body.stamp|w441-assign-index-simd-body" \
        "src/runtime_pipeline_abi_assign_index_simd_thin.x|.pabi_w445_assign_index_simd.stamp|w441-assign-index-simd" \
        "src/runtime_pipeline_abi_assign_index_named_body_thin.x|.pabi_w445_assign_index_named_body.stamp|w441-assign-index-named-body" \
        "src/runtime_pipeline_abi_assign_index_named_thin.x|.pabi_w445_assign_index_named.stamp|w441-assign-index-named" \
        "src/runtime_pipeline_abi_assign_index_bulk_lval_thin.x|.pabi_w445_assign_index_bulk_lval.stamp|w441-assign-index-bulk-lval" \
        "src/runtime_pipeline_abi_assign_index_bulk_call_thin.x|.pabi_w445_assign_index_bulk_call.stamp|w441-assign-index-bulk-call" \
        "src/runtime_pipeline_abi_assign_index_array_walk_thin.x|.pabi_w541_assign_index_array_walk.stamp|w541-ban-index-array-walk" \
        "src/runtime_pipeline_abi_assign_index_array_peel_thin.x|.pabi_w542_assign_index_array_peel.stamp|w542-ban-index-array-peel" \
        "src/runtime_pipeline_abi_assign_index_array_resolve_thin.x|.pabi_w546_assign_index_array_resolve.stamp|w546-ban-index-array-resolve" \
        "src/runtime_pipeline_abi_assign_index_array_lit_home_thin.x|.pabi_w445_assign_index_array_lit_home.stamp|w441-assign-index-array-lit-home" \
        "src/runtime_pipeline_abi_assign_index_array_lit_mid_thin.x|.pabi_w445_assign_index_array_lit_mid.stamp|w441-assign-index-array-lit-mid" \
        "src/runtime_pipeline_abi_assign_index_array_lit_thin.x|.pabi_w445_assign_index_array_lit.stamp|w441-assign-index-array-lit" \
        "src/runtime_pipeline_abi_assign_index_array_rbx_thin.x|.pabi_w445_assign_index_array_rbx.stamp|w441-assign-index-array-rbx" \
        "src/runtime_pipeline_abi_assign_index_array_thin.x|.pabi_w445_assign_index_array.stamp|w441-assign-index-array" \
        "src/runtime_pipeline_abi_assign_index_bulk_thin.x|.pabi_w445_assign_index_bulk.stamp|w441-assign-index-bulk" \
        "src/runtime_pipeline_abi_assign_index_generic_try_thin.x|.pabi_w445_assign_index_generic_try.stamp|w441-assign-index-generic-try" \
        "src/runtime_pipeline_abi_assign_index_generic_try2_thin.x|.pabi_w445_assign_index_generic_try2.stamp|w441-assign-index-generic-try2" \
        "src/runtime_pipeline_abi_assign_index_generic_scaled_thin.x|.pabi_w445_assign_index_generic_scaled.stamp|w441-assign-index-generic-scaled" \
        "src/runtime_pipeline_abi_assign_index_generic_thin.x|.pabi_w445_assign_index_generic.stamp|w441-assign-index-generic" \
        "src/runtime_pipeline_abi_assign_index_thin.x|.pabi_w445_assign_index.stamp|w441-assign-index" \
        "src/runtime_pipeline_abi_assign_var_thin.x|.pabi_w445_assign_var.stamp|w441-assign-var" \
        "src/runtime_pipeline_abi_assign_deref_vec_var_thin.x|.pabi_w533_assign_deref_vec_var.stamp|w533-ban-deref-vec-var" \
        "src/runtime_pipeline_abi_assign_deref_vec_call_thin.x|.pabi_w536_assign_deref_vec_call.stamp|w536-ban-deref-vec-call" \
        "src/runtime_pipeline_abi_assign_deref_slice_call_thin.x|.pabi_w537_assign_deref_slice_call.stamp|w537-ban-deref-slice-call" \
        "src/runtime_pipeline_abi_assign_deref_array_call_thin.x|.pabi_w535_assign_deref_array_call.stamp|w535-ban-deref-array-call" \
        "src/runtime_pipeline_abi_assign_deref_let_init_thin.x|.pabi_w533_assign_deref_let_init.stamp|w533-ban-deref-let-init" \
        "src/runtime_pipeline_abi_assign_deref_scalar_thin.x|.pabi_w534_assign_deref_scalar.stamp|w534-ban-deref-scalar" \
        "src/runtime_pipeline_abi_assign_deref_thin.x|.pabi_w445_assign_deref.stamp|w441-assign-deref" \
        "src/runtime_pipeline_abi_assign_emit_thin.x|.pabi_w445_assign_emit.stamp|w441-assign-emit"
      do
        lo_x="${peer%%|*}"
        lo_rest="${peer#*|}"
        lo_stamp="src/${lo_rest%%|*}"
        lo_tag="${lo_rest#*|}"
        # wave533–w537 Soft Cap: HARD BAN tip reinject for deref peers.
        case "$lo_x" in
          *assign_deref_let_init_thin.x|*assign_deref_vec_var_thin.x|*assign_deref_scalar_thin.x|*assign_deref_array_call_thin.x|*assign_deref_vec_call_thin.x|*assign_deref_slice_call_thin.x|*assign_index_array_walk_thin.x|*assign_index_array_peel_thin.x|*assign_index_setup_thin.x|*assign_field_chain_walk_thin.x|*assign_field_mag_fold_thin.x|*assign_index_array_resolve_thin.x)
            if [ -f "$lo_x" ]; then
              touch "$lo_stamp"
              rm -f src/.pabi_w445_assign_deref_let_init.stamp \
                src/.pabi_w445_assign_deref_vec_var.stamp \
                src/.pabi_w445_assign_deref_scalar.stamp \
                src/.pabi_w445_assign_deref_array_call.stamp \
                src/.pabi_w445_assign_deref_vec_call.stamp \
                src/.pabi_w445_assign_deref_slice_call.stamp \
                src/.pabi_w449_heal_deref_let_init.stamp \
                src/.pabi_w449_heal_deref_vec_var.stamp \
                src/.pabi_w449_heal_deref_scalar.stamp \
                src/.pabi_w449_heal_deref_array_call.stamp \
                src/.pabi_w449_heal_deref_vec_call.stamp \
                src/.pabi_w449_heal_deref_slice_call.stamp \
                src/.pabi_w445_assign_index_array_walk.stamp \
                src/.pabi_w445_heal_index_array_walk.stamp \
                src/.pabi_w445_assign_index_array_peel.stamp \
                src/.pabi_w445_heal_index_array_peel.stamp \
                src/.pabi_w445_assign_index_setup.stamp \
                src/.pabi_w445_heal_index_setup.stamp \
                src/.pabi_w445_assign_field_chain_walk.stamp \
                src/.pabi_w445_heal_field_chain_walk.stamp \
                src/.pabi_w445_assign_field_mag_fold.stamp \
                src/.pabi_w445_heal_field_mag_fold.stamp \
                src/.pabi_w445_assign_index_array_resolve.stamp \
                src/.pabi_w445_heal_index_array_resolve.stamp
            fi
            continue
            ;;
        esac
        if [ -f "$lo_x" ] && { [ ! -f "$lo_stamp" ] || [ "$lo_x" -nt "$lo_stamp" ]; }; then
          pipeline_abi_inject_thin_leaf "$o" "$lo_x" "$lo_tag"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$lo_stamp"
          else
            break
          fi
        fi
      done
      export XLANG_PABI_THIN_PREFER_ASM=1
    fi
  fi
  # wave445: six-peer pure-asm overlay (independent of emit -E stamp gate).
  # Root: Ubuntu CG002 on `out[0]=`/`out[i]=`; heal uses `*out=` / `&a[i]; *p=`.
  # Ban tip regen of to_rax/var/emit (si SEGV). PLATFORM: LINUX gold.
  if [ "$rc" -eq 0 ]; then
    local h_x h_rest h_stamp h_tag
    export XLANG_PABI_THIN_PREFER_ASM=1
    export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
    for peer in \
      "src/runtime_pipeline_abi_assign_field_chain_walk_thin.x|.pabi_w544_assign_field_chain_walk.stamp|w544-ban-field-chain-walk" \
      "src/runtime_pipeline_abi_assign_field_mag_fold_thin.x|.pabi_w545_assign_field_mag_fold.stamp|w545-ban-field-mag-fold" \
      "src/runtime_pipeline_abi_assign_index_setup_thin.x|.pabi_w543_assign_index_setup.stamp|w543-ban-index-setup" \
      "src/runtime_pipeline_abi_assign_index_array_walk_thin.x|.pabi_w541_assign_index_array_walk.stamp|w541-ban-index-array-walk" \
      "src/runtime_pipeline_abi_assign_index_array_peel_thin.x|.pabi_w542_assign_index_array_peel.stamp|w542-ban-index-array-peel" \
      "src/runtime_pipeline_abi_assign_index_array_resolve_thin.x|.pabi_w546_assign_index_array_resolve.stamp|w546-ban-index-array-resolve"
    do
      h_x="${peer%%|*}"
      h_rest="${peer#*|}"
      h_stamp="src/${h_rest%%|*}"
      h_tag="${h_rest#*|}"
      # wave541 Soft Cap: HARD BAN tip reinject (raw *i32 store SEGV on Ubuntu tip).
      case "$h_x" in
          *assign_index_array_walk_thin.x|*assign_index_array_peel_thin.x|*assign_index_setup_thin.x|*assign_field_chain_walk_thin.x|*assign_field_mag_fold_thin.x|*assign_index_array_resolve_thin.x)
          if [ -f "$h_x" ]; then
            touch "$h_stamp"
            rm -f src/.pabi_w445_assign_index_array_walk.stamp \
              src/.pabi_w445_heal_index_array_walk.stamp \
              src/.pabi_w445_assign_index_array_peel.stamp \
              src/.pabi_w445_heal_index_array_peel.stamp \
              src/.pabi_w445_assign_index_setup.stamp \
              src/.pabi_w445_heal_index_setup.stamp \
              src/.pabi_w445_assign_field_chain_walk.stamp \
              src/.pabi_w445_heal_field_chain_walk.stamp \
              src/.pabi_w445_assign_field_mag_fold.stamp \
              src/.pabi_w445_heal_field_mag_fold.stamp \
              src/.pabi_w445_assign_index_array_resolve.stamp \
              src/.pabi_w445_heal_index_array_resolve.stamp
            log "pipeline_abi w541-w546 index/field chain: tipU stamped; tip PRODUCT reinject HARD BAN (keep prior)"
          fi
          continue
          ;;
      esac
      if [ -f "$h_x" ] && { [ ! -f "$h_stamp" ] || [ "$h_x" -nt "$h_stamp" ]; }; then
        pipeline_abi_inject_thin_leaf "$o" "$h_x" "$h_tag"
        rc=$?
        if [ "$rc" -eq 0 ]; then
          touch "$h_stamp"
        else
          break
        fi
      fi
    done
  fi
  # wave449/w472: deref peer arms + six-leaf dispatcher. Product si green alone.
  # PLATFORM: LINUX gold.
  if [ "$rc" -eq 0 ]; then
    local d_x d_rest d_stamp d_tag
    export XLANG_PABI_THIN_PREFER_ASM=1
    export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
    for peer in \
      "src/runtime_pipeline_abi_assign_deref_vec_var_thin.x|.pabi_w533_assign_deref_vec_var.stamp|w533-ban-deref-vec-var" \
      "src/runtime_pipeline_abi_assign_deref_vec_call_thin.x|.pabi_w536_assign_deref_vec_call.stamp|w536-ban-deref-vec-call" \
      "src/runtime_pipeline_abi_assign_deref_slice_call_thin.x|.pabi_w537_assign_deref_slice_call.stamp|w537-ban-deref-slice-call" \
      "src/runtime_pipeline_abi_assign_deref_array_call_thin.x|.pabi_w535_assign_deref_array_call.stamp|w535-ban-deref-array-call" \
      "src/runtime_pipeline_abi_assign_deref_let_init_thin.x|.pabi_w533_assign_deref_let_init.stamp|w533-ban-deref-let-init" \
      "src/runtime_pipeline_abi_assign_deref_scalar_thin.x|.pabi_w534_assign_deref_scalar.stamp|w534-ban-deref-scalar" \
      "src/runtime_pipeline_abi_assign_deref_vec_gate_thin.x|.pabi_w472_heal_deref_vec_gate.stamp|w472-heal-deref-vec-gate" \
      "src/runtime_pipeline_abi_assign_deref_after_addr_thin.x|.pabi_w472_heal_deref_after_addr.stamp|w472-heal-deref-after-addr" \
      "src/runtime_pipeline_abi_assign_deref_finish_thin.x|.pabi_w472_heal_deref_finish.stamp|w472-heal-deref-finish" \
      "src/runtime_pipeline_abi_assign_deref_peel_var_thin.x|.pabi_w472_heal_deref_peel_var.stamp|w472-heal-deref-peel-var" \
      "src/runtime_pipeline_abi_assign_deref_peel_thin.x|.pabi_w472_heal_deref_peel.stamp|w472-heal-deref-peel" \
      "src/runtime_pipeline_abi_assign_deref_thin.x|.pabi_w472_heal_deref.stamp|w472-heal-deref"
    do
      d_x="${peer%%|*}"
      d_rest="${peer#*|}"
      d_stamp="src/${d_rest%%|*}"
      d_tag="${d_rest#*|}"
      # wave533–w537 Soft Cap: HARD BAN tip reinject for deref peers.
      # wave596: HARD BAN peel PRODUCT reinject — PREFER asm and -E both
      #   SEGV 139 on `unsafe { *p = 1 }` (gdb: frame smash at 0x9 in peel).
      #   Darwin MACOS skip / overlay is fine. Keep prior w472 leftover.
      case "$d_x" in
        *assign_deref_peel_thin.x)
          if [ -f "$d_x" ]; then
            touch "$d_stamp"
            touch src/.pabi_w596_deref_peel.stamp
            log "pipeline_abi w596-deref-peel: PRODUCT reinject HARD BAN (keep prior)"
          fi
          continue
          ;;
        *assign_deref_let_init_thin.x|*assign_deref_vec_var_thin.x|*assign_deref_scalar_thin.x|*assign_deref_array_call_thin.x|*assign_deref_vec_call_thin.x|*assign_deref_slice_call_thin.x)
          if [ -f "$d_x" ]; then
            touch "$d_stamp"
            rm -f src/.pabi_w445_assign_deref_let_init.stamp \
              src/.pabi_w445_assign_deref_vec_var.stamp \
              src/.pabi_w445_assign_deref_scalar.stamp \
              src/.pabi_w445_assign_deref_array_call.stamp \
              src/.pabi_w445_assign_deref_vec_call.stamp \
              src/.pabi_w445_assign_deref_slice_call.stamp \
              src/.pabi_w449_heal_deref_let_init.stamp \
              src/.pabi_w449_heal_deref_vec_var.stamp \
              src/.pabi_w449_heal_deref_scalar.stamp \
              src/.pabi_w449_heal_deref_array_call.stamp \
              src/.pabi_w449_heal_deref_vec_call.stamp \
              src/.pabi_w449_heal_deref_slice_call.stamp
            log "pipeline_abi w537-assign-deref: tipU pipe-cell stamped; tip PRODUCT reinject HARD BAN (keep prior)"
          fi
          continue
          ;;
      esac
      if [ -f "$d_x" ] && { [ ! -f "$d_stamp" ] || [ "$d_x" -nt "$d_stamp" ]; }; then
        pipeline_abi_inject_thin_leaf "$o" "$d_x" "$d_tag"
        rc=$?
        if [ "$rc" -eq 0 ]; then
          touch "$d_stamp"
        else
          break
        fi
      fi
    done
  fi
  # wave451/w473: var tip + peers were PREFER overlay (LINUX only).
  # wave600 smash was stale-era (family PREFER both ends since w620) — LINUX
  #   -E replace via pipeline_abi_inject_assign_var_thin; HARD BAN PREFER.
  # PLATFORM: LINUX gold.
  if [ "$rc" -eq 0 ]; then
    pipeline_abi_inject_assign_var_thin "$o" || rc=$?
  fi
  # wave475: field_var peers + ptr_hit gate/step no-local PREFER (LINUX only).
  # Root: tip U=0 (let-bound call / while); struct split pair+store.
  # PLATFORM: LINUX gold.
  if [ "$rc" -eq 0 ]; then
    local f_x f_rest f_stamp f_tag
    export XLANG_PABI_THIN_PREFER_ASM=1
    export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
    for peer in \
      "src/runtime_pipeline_abi_assign_field_ptr_hit_step_thin.x|.pabi_w475_heal_field_ptr_hit_step.stamp|w475-heal-field-ptr-hit-step" \
      "src/runtime_pipeline_abi_assign_field_ptr_hit_thin.x|.pabi_w475_heal_field_ptr_hit.stamp|w475-heal-field-ptr-hit" \
      "src/runtime_pipeline_abi_assign_field_var_depth1_thin.x|.pabi_w475_heal_field_var_depth1.stamp|w475-heal-field-var-depth1" \
      "src/runtime_pipeline_abi_assign_field_var_simd_thin.x|.pabi_w475_heal_field_var_simd.stamp|w475-heal-field-var-simd" \
      "src/runtime_pipeline_abi_assign_field_var_array_thin.x|.pabi_w475_heal_field_var_array.stamp|w475-heal-field-var-array" \
      "src/runtime_pipeline_abi_assign_field_var_struct_store_thin.x|.pabi_w475_heal_field_var_struct_store.stamp|w475-heal-field-var-struct-store" \
      "src/runtime_pipeline_abi_assign_field_var_struct_pair_thin.x|.pabi_w475_heal_field_var_struct_pair.stamp|w475-heal-field-var-struct-pair" \
      "src/runtime_pipeline_abi_assign_field_var_struct_thin.x|.pabi_w475_heal_field_var_struct.stamp|w475-heal-field-var-struct"
    do
      f_x="${peer%%|*}"
      f_rest="${peer#*|}"
      f_stamp="src/${f_rest%%|*}"
      f_tag="${f_rest#*|}"
      if [ -f "$f_x" ] && { [ ! -f "$f_stamp" ] || [ "$f_x" -nt "$f_stamp" ]; }; then
        pipeline_abi_inject_thin_leaf "$o" "$f_x" "$f_tag"
        rc=$?
        if [ "$rc" -eq 0 ]; then
          touch "$f_stamp"
        else
          break
        fi
      fi
    done
  fi
  # wave476: field_ptr gate+struct+array + field_scalar no-local PREFER (LINUX only).
  # Root: tip U=0/171 (giant let + let-bound call drop body / zero reloc); ptr monolith CG002.
  # PLATFORM: LINUX gold.
  if [ "$rc" -eq 0 ]; then
    local g_x g_rest g_stamp g_tag
    export XLANG_PABI_THIN_PREFER_ASM=1
    export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
    for peer in \
      "src/runtime_pipeline_abi_assign_field_ptr_struct_thin.x|.pabi_w476_heal_field_ptr_struct.stamp|w476-heal-field-ptr-struct" \
      "src/runtime_pipeline_abi_assign_field_ptr_array_thin.x|.pabi_w476_heal_field_ptr_array.stamp|w476-heal-field-ptr-array" \
      "src/runtime_pipeline_abi_assign_field_ptr_thin.x|.pabi_w476_heal_field_ptr.stamp|w476-heal-field-ptr" \
      "src/runtime_pipeline_abi_assign_field_scalar_thin.x|.pabi_w476_heal_field_scalar.stamp|w476-heal-field-scalar"
    do
      g_x="${peer%%|*}"
      g_rest="${peer#*|}"
      g_stamp="src/${g_rest%%|*}"
      g_tag="${g_rest#*|}"
      if [ -f "$g_x" ] && { [ ! -f "$g_stamp" ] || [ "$g_x" -nt "$g_stamp" ]; }; then
        pipeline_abi_inject_thin_leaf "$o" "$g_x" "$g_tag"
        rc=$?
        if [ "$rc" -eq 0 ]; then
          touch "$g_stamp"
        else
          break
        fi
      fi
    done
  fi
  # wave478: binop_stack_spill try_reload gate+rax+rbx no-local PREFER.
  # Root: tip U=4/7 (`let x=call()` mid-drop); rbx arm tip-drop → peer split.
  # PLATFORM: SHARED · LINUX gold · MACOS co-path (arm64 ta==1 live).
  if [ "$rc" -eq 0 ]; then
    local s_x s_rest s_stamp s_tag
    export XLANG_PABI_THIN_PREFER_ASM=1
    export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
    for peer in \
      "src/runtime_pipeline_abi_binop_stack_spill_try_reload_rax_thin.x|.pabi_w478_heal_spill_reload_rax.stamp|w478-heal-spill-reload-rax" \
      "src/runtime_pipeline_abi_binop_stack_spill_try_reload_rbx_thin.x|.pabi_w478_heal_spill_reload_rbx.stamp|w478-heal-spill-reload-rbx" \
      "src/runtime_pipeline_abi_binop_stack_spill_try_reload_thin.x|.pabi_w478_heal_spill_reload.stamp|w478-heal-spill-reload"
    do
      s_x="${peer%%|*}"
      s_rest="${peer#*|}"
      s_stamp="src/${s_rest%%|*}"
      s_tag="${s_rest#*|}"
      if [ -f "$s_x" ] && { [ ! -f "$s_stamp" ] || [ "$s_x" -nt "$s_stamp" ]; }; then
        pipeline_abi_inject_thin_leaf "$o" "$s_x" "$s_tag"
        rc=$?
        if [ "$rc" -eq 0 ]; then
          touch "$s_stamp"
        else
          break
        fi
      fi
    done
  fi
  # wave477: arr_return b0/c + glue_statics tip no-local HARD BAN
  # (tip U-complete; product reinject → L2 CG002 4/5). Keep w439/w332 overlays.
  # wave458: field_var_stores tip no-local PREFER overlay (LINUX only).
  # Root: tip `let rc = call()` drops mid-peer calls → U-starved (only depth1);
  #   eq-cascade no-local → Ubuntu tip U=4/4; product inject L2 5/5.
  # wave459: field dispatcher same unlock (U=4/4); MACOS skip (same UNDEF risk).
  # wave460: index dispatcher same unlock (U=6/6); MACOS skip.
  # wave461: index_struct_lit same unlock (U=3/3); MACOS skip.
  # wave462: index_array same unlock (U=4/4); MACOS skip.
  # wave463: index_struct_lit_arr same unlock (U=6/6); MACOS skip.
  # wave464: index_array_rbx esz-only no-local (U=5/5); MACOS skip.
  #   Drop total_bytes dual-tail (tip U-starve / SEGV); stride = caller esz.
  # wave465: index_struct_lit_rbx shared-emit no-local (U=7/7); MACOS skip.
  # wave466: index_simd split body+dispatcher no-local (body U=5/5; tip U=5/5);
  #   MACOS skip. Monolithic tip U-starved 1/9 / lit*nbytes co-file drops setup.
  # wave467: index_named split body+dispatcher no-local (body U=5/5; tip U=5/5);
  #   MACOS skip. Monolithic tip U-starved 1/8.
  # PLATFORM: LINUX gold · MACOS skip (full assign chain already PREFER; Darwin
  #   g05 mega re-inject after stores overlay can UNDEF peer leaves).
  case "$(uname -s)" in
    Linux)
      if [ "$rc" -eq 0 ]; then
        local stores_x="src/runtime_pipeline_abi_assign_field_var_stores_thin.x"
        local stores_s="src/.pabi_w458_heal_field_var_stores.stamp"
        if [ -f "$stores_x" ] && { [ ! -f "$stores_s" ] || [ "$stores_x" -nt "$stores_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$stores_x" "w458-heal-field-var-stores"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$stores_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local field_x="src/runtime_pipeline_abi_assign_field_thin.x"
        local field_s="src/.pabi_w459_heal_field.stamp"
        if [ -f "$field_x" ] && { [ ! -f "$field_s" ] || [ "$field_x" -nt "$field_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$field_x" "w459-heal-field"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$field_s"
          fi
        fi
      fi
      # wave607: HARD BAN leftover PREFER of assign_index smash family.
      # Extra pop/store overwrote u8 `b[2]=7`. LINUX -E is
      # pipeline_abi_inject_assign_index_thin. Touch heal stamps so the
      # PREFER overlay below skips (thin not newer than stamp).
      # PLATFORM: LINUX — MACOS never ran these heals.
      if [ "$rc" -eq 0 ]; then
        touch \
          src/.pabi_w460_heal_index.stamp \
          src/.pabi_w461_heal_index_struct_lit.stamp \
          src/.pabi_w462_heal_index_array.stamp \
          src/.pabi_w463_heal_index_struct_lit_arr.stamp \
          src/.pabi_w464_heal_index_array_rbx.stamp \
          src/.pabi_w465_heal_index_struct_lit_rbx.stamp \
          src/.pabi_w466_heal_index_simd_body.stamp \
          src/.pabi_w466_heal_index_simd.stamp \
          src/.pabi_w467_heal_index_named_body.stamp \
          src/.pabi_w467_heal_index_named.stamp \
          src/.pabi_w468_heal_index_bulk_lval.stamp \
          src/.pabi_w468_heal_index_bulk_call.stamp \
          src/.pabi_w468_heal_index_bulk.stamp \
          src/.pabi_w469_heal_index_array_lit_home.stamp \
          src/.pabi_w469_heal_index_array_lit_mid.stamp \
          src/.pabi_w469_heal_index_array_lit.stamp \
          src/.pabi_w471_heal_index_generic_try.stamp \
          src/.pabi_w471_heal_index_generic_try2.stamp \
          src/.pabi_w471_heal_index_generic_scaled.stamp \
          src/.pabi_w471_heal_index_generic.stamp
        log "pipeline_abi w607-assign-index: HARD BAN PREFER heals (LINUX -E via inject_assign_index_thin)"
      fi
      if [ "$rc" -eq 0 ]; then
        local index_x="src/runtime_pipeline_abi_assign_index_thin.x"
        local index_s="src/.pabi_w460_heal_index.stamp"
        if [ -f "$index_x" ] && { [ ! -f "$index_s" ] || [ "$index_x" -nt "$index_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$index_x" "w460-heal-index"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$index_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local isl_x="src/runtime_pipeline_abi_assign_index_struct_lit_thin.x"
        local isl_s="src/.pabi_w461_heal_index_struct_lit.stamp"
        if [ -f "$isl_x" ] && { [ ! -f "$isl_s" ] || [ "$isl_x" -nt "$isl_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$isl_x" "w461-heal-index-struct-lit"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$isl_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local ia_x="src/runtime_pipeline_abi_assign_index_array_thin.x"
        local ia_s="src/.pabi_w462_heal_index_array.stamp"
        if [ -f "$ia_x" ] && { [ ! -f "$ia_s" ] || [ "$ia_x" -nt "$ia_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$ia_x" "w462-heal-index-array"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$ia_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local sla_x="src/runtime_pipeline_abi_assign_index_struct_lit_arr_thin.x"
        local sla_s="src/.pabi_w463_heal_index_struct_lit_arr.stamp"
        if [ -f "$sla_x" ] && { [ ! -f "$sla_s" ] || [ "$sla_x" -nt "$sla_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$sla_x" "w463-heal-index-struct-lit-arr"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$sla_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local rbx_x="src/runtime_pipeline_abi_assign_index_array_rbx_thin.x"
        local rbx_s="src/.pabi_w464_heal_index_array_rbx.stamp"
        if [ -f "$rbx_x" ] && { [ ! -f "$rbx_s" ] || [ "$rbx_x" -nt "$rbx_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$rbx_x" "w464-heal-index-array-rbx"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$rbx_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local slr_x="src/runtime_pipeline_abi_assign_index_struct_lit_rbx_thin.x"
        local slr_s="src/.pabi_w465_heal_index_struct_lit_rbx.stamp"
        if [ -f "$slr_x" ] && { [ ! -f "$slr_s" ] || [ "$slr_x" -nt "$slr_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$slr_x" "w465-heal-index-struct-lit-rbx"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$slr_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local sb_x="src/runtime_pipeline_abi_assign_index_simd_body_thin.x"
        local sb_s="src/.pabi_w466_heal_index_simd_body.stamp"
        if [ -f "$sb_x" ] && { [ ! -f "$sb_s" ] || [ "$sb_x" -nt "$sb_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$sb_x" "w466-heal-index-simd-body"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$sb_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local sd_x="src/runtime_pipeline_abi_assign_index_simd_thin.x"
        local sd_s="src/.pabi_w466_heal_index_simd.stamp"
        if [ -f "$sd_x" ] && { [ ! -f "$sd_s" ] || [ "$sd_x" -nt "$sd_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$sd_x" "w466-heal-index-simd"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$sd_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local nb_x="src/runtime_pipeline_abi_assign_index_named_body_thin.x"
        local nb_s="src/.pabi_w467_heal_index_named_body.stamp"
        if [ -f "$nb_x" ] && { [ ! -f "$nb_s" ] || [ "$nb_x" -nt "$nb_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$nb_x" "w467-heal-index-named-body"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$nb_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local nd_x="src/runtime_pipeline_abi_assign_index_named_thin.x"
        local nd_s="src/.pabi_w467_heal_index_named.stamp"
        if [ -f "$nd_x" ] && { [ ! -f "$nd_s" ] || [ "$nd_x" -nt "$nd_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$nd_x" "w467-heal-index-named"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$nd_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local bl_x="src/runtime_pipeline_abi_assign_index_bulk_lval_thin.x"
        local bl_s="src/.pabi_w468_heal_index_bulk_lval.stamp"
        if [ -f "$bl_x" ] && { [ ! -f "$bl_s" ] || [ "$bl_x" -nt "$bl_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$bl_x" "w468-heal-index-bulk-lval"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$bl_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local bc_x="src/runtime_pipeline_abi_assign_index_bulk_call_thin.x"
        local bc_s="src/.pabi_w468_heal_index_bulk_call.stamp"
        if [ -f "$bc_x" ] && { [ ! -f "$bc_s" ] || [ "$bc_x" -nt "$bc_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$bc_x" "w468-heal-index-bulk-call"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$bc_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local bd_x="src/runtime_pipeline_abi_assign_index_bulk_thin.x"
        local bd_s="src/.pabi_w468_heal_index_bulk.stamp"
        if [ -f "$bd_x" ] && { [ ! -f "$bd_s" ] || [ "$bd_x" -nt "$bd_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$bd_x" "w468-heal-index-bulk"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$bd_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local ah_x="src/runtime_pipeline_abi_assign_index_array_lit_home_thin.x"
        local ah_s="src/.pabi_w469_heal_index_array_lit_home.stamp"
        if [ -f "$ah_x" ] && { [ ! -f "$ah_s" ] || [ "$ah_x" -nt "$ah_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$ah_x" "w469-heal-index-array-lit-home"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$ah_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local am_x="src/runtime_pipeline_abi_assign_index_array_lit_mid_thin.x"
        local am_s="src/.pabi_w469_heal_index_array_lit_mid.stamp"
        if [ -f "$am_x" ] && { [ ! -f "$am_s" ] || [ "$am_x" -nt "$am_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$am_x" "w469-heal-index-array-lit-mid"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$am_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local ag_x="src/runtime_pipeline_abi_assign_index_array_lit_thin.x"
        local ag_s="src/.pabi_w469_heal_index_array_lit.stamp"
        if [ -f "$ag_x" ] && { [ ! -f "$ag_s" ] || [ "$ag_x" -nt "$ag_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$ag_x" "w469-heal-index-array-lit"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$ag_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local ff_x="src/runtime_pipeline_abi_assign_field_var_root_finish_thin.x"
        local ff_s="src/.pabi_w470_heal_field_var_root_finish.stamp"
        if [ -f "$ff_x" ] && { [ ! -f "$ff_s" ] || [ "$ff_x" -nt "$ff_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$ff_x" "w470-heal-field-var-root-finish"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$ff_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local fr_x="src/runtime_pipeline_abi_assign_field_var_root_thin.x"
        local fr_s="src/.pabi_w470_heal_field_var_root.stamp"
        if [ -f "$fr_x" ] && { [ ! -f "$fr_s" ] || [ "$fr_x" -nt "$fr_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$fr_x" "w470-heal-field-var-root"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$fr_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local gt_x="src/runtime_pipeline_abi_assign_index_generic_try_thin.x"
        local gt_s="src/.pabi_w471_heal_index_generic_try.stamp"
        if [ -f "$gt_x" ] && { [ ! -f "$gt_s" ] || [ "$gt_x" -nt "$gt_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$gt_x" "w471-heal-index-generic-try"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$gt_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local g2_x="src/runtime_pipeline_abi_assign_index_generic_try2_thin.x"
        local g2_s="src/.pabi_w471_heal_index_generic_try2.stamp"
        if [ -f "$g2_x" ] && { [ ! -f "$g2_s" ] || [ "$g2_x" -nt "$g2_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$g2_x" "w471-heal-index-generic-try2"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$g2_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local gs_x="src/runtime_pipeline_abi_assign_index_generic_scaled_thin.x"
        local gs_s="src/.pabi_w471_heal_index_generic_scaled.stamp"
        if [ -f "$gs_x" ] && { [ ! -f "$gs_s" ] || [ "$gs_x" -nt "$gs_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$gs_x" "w471-heal-index-generic-scaled"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$gs_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local gd_x="src/runtime_pipeline_abi_assign_index_generic_thin.x"
        local gd_s="src/.pabi_w471_heal_index_generic.stamp"
        if [ -f "$gd_x" ] && { [ ! -f "$gd_s" ] || [ "$gd_x" -nt "$gd_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$gd_x" "w471-heal-index-generic"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$gd_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local vg_x="src/runtime_pipeline_abi_assign_deref_vec_gate_thin.x"
        local vg_s="src/.pabi_w472_heal_deref_vec_gate.stamp"
        if [ -f "$vg_x" ] && { [ ! -f "$vg_s" ] || [ "$vg_x" -nt "$vg_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$vg_x" "w472-heal-deref-vec-gate"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$vg_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local aa_x="src/runtime_pipeline_abi_assign_deref_after_addr_thin.x"
        local aa_s="src/.pabi_w472_heal_deref_after_addr.stamp"
        if [ -f "$aa_x" ] && { [ ! -f "$aa_s" ] || [ "$aa_x" -nt "$aa_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$aa_x" "w472-heal-deref-after-addr"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$aa_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local df_x="src/runtime_pipeline_abi_assign_deref_finish_thin.x"
        local df_s="src/.pabi_w472_heal_deref_finish.stamp"
        if [ -f "$df_x" ] && { [ ! -f "$df_s" ] || [ "$df_x" -nt "$df_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$df_x" "w472-heal-deref-finish"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$df_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local pv_x="src/runtime_pipeline_abi_assign_deref_peel_var_thin.x"
        local pv_s="src/.pabi_w472_heal_deref_peel_var.stamp"
        if [ -f "$pv_x" ] && { [ ! -f "$pv_s" ] || [ "$pv_x" -nt "$pv_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$pv_x" "w472-heal-deref-peel-var"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$pv_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local dp_x="src/runtime_pipeline_abi_assign_deref_peel_thin.x"
        local dp_s="src/.pabi_w472_heal_deref_peel.stamp"
        if [ -f "$dp_x" ]; then
          # wave596: HARD BAN peel PRODUCT reinject (PREFER asm / -E both SEGV).
          touch "$dp_s"
          touch src/.pabi_w596_deref_peel.stamp
          log "pipeline_abi w596-deref-peel: PRODUCT reinject HARD BAN (keep prior)"
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local dd_x="src/runtime_pipeline_abi_assign_deref_thin.x"
        local dd_s="src/.pabi_w472_heal_deref.stamp"
        if [ -f "$dd_x" ] && { [ ! -f "$dd_s" ] || [ "$dd_x" -nt "$dd_s" ]; }; then
          # wave598: gate skips leftover peel (w596 BAN). PREFER the
          #   scalar-dispatch body; do not reinject peel.
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$dd_x" "w598-deref-gate-scalar"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$dd_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        # wave598: leftover PREFER scalar smashes caller rbp. LINUX -E
        #   replace; HARD BAN PREFER; MACOS keep overlay.
        pipeline_abi_inject_deref_scalar_thin "$o" || rc=$?
      fi
      if [ "$rc" -eq 0 ]; then
        # assign_var family PREFER both ends since w620 (stale-era ban lifted)
        #   PREFER reinject; LINUX -E is pipeline_abi_inject_assign_var_thin.
        pipeline_abi_inject_assign_var_thin "$o" || rc=$?
      fi
      if [ "$rc" -eq 0 ]; then
        # wave607: leftover PREFER assign_index smash extra pop/store.
        #   HARD BAN PREFER; LINUX -E is pipeline_abi_inject_assign_index_thin.
        pipeline_abi_inject_assign_index_thin "$o" || rc=$?
      fi
      if [ "$rc" -eq 0 ]; then
        local phs_x="src/runtime_pipeline_abi_assign_field_ptr_hit_step_thin.x"
        local phs_s="src/.pabi_w475_heal_field_ptr_hit_step.stamp"
        if [ -f "$phs_x" ] && { [ ! -f "$phs_s" ] || [ "$phs_x" -nt "$phs_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$phs_x" "w475-heal-field-ptr-hit-step"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$phs_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local ph_x="src/runtime_pipeline_abi_assign_field_ptr_hit_thin.x"
        local ph_s="src/.pabi_w475_heal_field_ptr_hit.stamp"
        if [ -f "$ph_x" ] && { [ ! -f "$ph_s" ] || [ "$ph_x" -nt "$ph_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$ph_x" "w475-heal-field-ptr-hit"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$ph_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local fd1_x="src/runtime_pipeline_abi_assign_field_var_depth1_thin.x"
        local fd1_s="src/.pabi_w475_heal_field_var_depth1.stamp"
        if [ -f "$fd1_x" ] && { [ ! -f "$fd1_s" ] || [ "$fd1_x" -nt "$fd1_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$fd1_x" "w475-heal-field-var-depth1"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$fd1_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local fsi_x="src/runtime_pipeline_abi_assign_field_var_simd_thin.x"
        local fsi_s="src/.pabi_w475_heal_field_var_simd.stamp"
        if [ -f "$fsi_x" ] && { [ ! -f "$fsi_s" ] || [ "$fsi_x" -nt "$fsi_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$fsi_x" "w475-heal-field-var-simd"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$fsi_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local far_x="src/runtime_pipeline_abi_assign_field_var_array_thin.x"
        local far_s="src/.pabi_w475_heal_field_var_array.stamp"
        if [ -f "$far_x" ] && { [ ! -f "$far_s" ] || [ "$far_x" -nt "$far_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$far_x" "w475-heal-field-var-array"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$far_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local fss_x="src/runtime_pipeline_abi_assign_field_var_struct_store_thin.x"
        local fss_s="src/.pabi_w475_heal_field_var_struct_store.stamp"
        if [ -f "$fss_x" ] && { [ ! -f "$fss_s" ] || [ "$fss_x" -nt "$fss_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$fss_x" "w475-heal-field-var-struct-store"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$fss_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local fsp_x="src/runtime_pipeline_abi_assign_field_var_struct_pair_thin.x"
        local fsp_s="src/.pabi_w475_heal_field_var_struct_pair.stamp"
        if [ -f "$fsp_x" ] && { [ ! -f "$fsp_s" ] || [ "$fsp_x" -nt "$fsp_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$fsp_x" "w475-heal-field-var-struct-pair"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$fsp_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local fst_x="src/runtime_pipeline_abi_assign_field_var_struct_thin.x"
        local fst_s="src/.pabi_w475_heal_field_var_struct.stamp"
        if [ -f "$fst_x" ] && { [ ! -f "$fst_s" ] || [ "$fst_x" -nt "$fst_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$fst_x" "w475-heal-field-var-struct"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$fst_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local fps_x="src/runtime_pipeline_abi_assign_field_ptr_struct_thin.x"
        local fps_s="src/.pabi_w476_heal_field_ptr_struct.stamp"
        if [ -f "$fps_x" ] && { [ ! -f "$fps_s" ] || [ "$fps_x" -nt "$fps_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$fps_x" "w476-heal-field-ptr-struct"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$fps_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local fpa_x="src/runtime_pipeline_abi_assign_field_ptr_array_thin.x"
        local fpa_s="src/.pabi_w476_heal_field_ptr_array.stamp"
        if [ -f "$fpa_x" ] && { [ ! -f "$fpa_s" ] || [ "$fpa_x" -nt "$fpa_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$fpa_x" "w476-heal-field-ptr-array"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$fpa_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local fp_x="src/runtime_pipeline_abi_assign_field_ptr_thin.x"
        local fp_s="src/.pabi_w476_heal_field_ptr.stamp"
        if [ -f "$fp_x" ] && { [ ! -f "$fp_s" ] || [ "$fp_x" -nt "$fp_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$fp_x" "w476-heal-field-ptr"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$fp_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local fsc_x="src/runtime_pipeline_abi_assign_field_scalar_thin.x"
        local fsc_s="src/.pabi_w476_heal_field_scalar.stamp"
        if [ -f "$fsc_x" ] && { [ ! -f "$fsc_s" ] || [ "$fsc_x" -nt "$fsc_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$fsc_x" "w476-heal-field-scalar"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$fsc_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local sra_x="src/runtime_pipeline_abi_binop_stack_spill_try_reload_rax_thin.x"
        local sra_s="src/.pabi_w478_heal_spill_reload_rax.stamp"
        if [ -f "$sra_x" ] && { [ ! -f "$sra_s" ] || [ "$sra_x" -nt "$sra_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$sra_x" "w478-heal-spill-reload-rax"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$sra_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local srb_x="src/runtime_pipeline_abi_binop_stack_spill_try_reload_rbx_thin.x"
        local srb_s="src/.pabi_w478_heal_spill_reload_rbx.stamp"
        if [ -f "$srb_x" ] && { [ ! -f "$srb_s" ] || [ "$srb_x" -nt "$srb_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$srb_x" "w478-heal-spill-reload-rbx"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$srb_s"
          fi
        fi
      fi
      if [ "$rc" -eq 0 ]; then
        local sr_x="src/runtime_pipeline_abi_binop_stack_spill_try_reload_thin.x"
        local sr_s="src/.pabi_w478_heal_spill_reload.stamp"
        if [ -f "$sr_x" ] && { [ ! -f "$sr_s" ] || [ "$sr_x" -nt "$sr_s" ]; }; then
          export XLANG_PABI_THIN_PREFER_ASM=1
          export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
          pipeline_abi_inject_thin_leaf "$o" "$sr_x" "w478-heal-spill-reload"
          rc=$?
          if [ "$rc" -eq 0 ]; then
            touch "$sr_s"
          fi
        fi
      fi
      ;;
  esac
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  return "$rc"
}

# wave438 M2: arr_lit_flat Cap residual — flat peer chain unlock.
# PRODUCT inject wave438:
#   BOTH: PREFER_ASM peer chain (nested if/micro-unsafe emptied Ubuntu .o;
#   Darwin peers -c green). Order: repark→one_cell→cells→one_row→rows→
#   struct→one_scalar→step→scalar→main dispatcher.
# wave568: repark Ubuntu tip dropped every encoder (rc=call then if).
#   HARD BAN tip PRODUCT reinject both ends; keep the w438 overlay.
# wave569: one_cell Ubuntu tip dropped the slice-init encoder
#   (if-before-call + mid-assign). HARD BAN tip PRODUCT reinject
#   both ends; keep the w438 overlay.
# wave570: cells Ubuntu tip dropped every encoder (while +
#   st=one_cell then if). HARD BAN tip PRODUCT reinject both
#   ends; keep the w438 overlay.
# wave571: one_row Ubuntu tip dropped kind_ord + glue_emit
#   (if-before-call + ko=call then if + row_st=call then if;
#   only cells dispatch UND). HARD BAN tip PRODUCT reinject
#   both ends; keep the w438 overlay.
# wave572: rows Ubuntu tip dropped every encoder (while +
#   mid-assign + st=one_row then if). HARD BAN tip PRODUCT
#   reinject both ends; keep the w438 overlay.
# wave573: struct Ubuntu tip dropped every encoder (if-before-call
#   + mid-assign + st=glue_emit then if; original flat_i[0] store
#   is *i32 SEGV class but body dropped so compile rc=0). HARD BAN
#   tip PRODUCT reinject both ends; keep the w438 overlay.
# wave574: one_scalar Ubuntu tip dropped every encoder (rc=lea/mov
#   then if + may_clobber=call + rc=scalar_elem then if +
#   if(may_clobber) rc=repark + fi=flat_i[0] + rc=store then if +
#   flat_i[0]=fi+1; original flat_i[0] store is *i32 SEGV class
#   but body dropped so compile rc=0). HARD BAN tip PRODUCT
#   reinject both ends; keep the w438 overlay.
# wave575: step Ubuntu tip dropped elem_ref + kind_ord + try_struct
#   (elem_ref=call then if + ko=kind_ord then if + if(ko==46)
#   return flatten + tr=try_struct then if; only flatten recurse
#   + one_scalar dispatch UND). HARD BAN tip PRODUCT reinject
#   both ends; keep the w438 overlay.
# wave576: scalar Ubuntu tip dropped every encoder (n_arr=num_elems
#   then if + store_sz=leaf_esz then if + while rc=step then if;
#   Darwin original 2 UND = num_elems + step). HARD BAN tip
#   PRODUCT reinject both ends; keep the w438 overlay.
# wave577: main Ubuntu tip dropped kind_ord + elem_type + type_kind
#   + type_elem (if-before-call + ko=kind_ord then if + dest_elem
#   then dest_ek + inner then inner_k; only slice_rows + scalar
#   dispatch UND). Darwin original 6 UND. HARD BAN tip PRODUCT
#   reinject both ends; keep the w438 overlay. No remaining PREFER.
# G.7: semantics match mega pipeline_asm_emit_array_lit_flat_elf_c.
# PLATFORM: SHARED · repark/one_cell/cells/one_row/rows/struct/one_scalar/step/scalar/main BAN tip reinject / no remaining PREFER.
pipeline_abi_inject_arr_lit_flat_thin() {
  local o="$1"
  local main_x="src/runtime_pipeline_abi_arr_lit_flat_thin.x"
  [ -s "$o" ] && [ -f "$main_x" ] || return 0
  # wave568: repark Ubuntu tip dropped every encoder (rc=call then if).
  # HARD BAN tip PRODUCT reinject on both ends. Keep the w438 overlay.
  if [ -f src/runtime_pipeline_abi_arr_lit_flat_repark_thin.x ]; then
    touch src/.pabi_w568_arr_lit_flat_repark.stamp
    rm -f src/.pabi_w438_arr_lit_flat_repark.stamp
    log "pipeline_abi w568 arr_lit_flat_repark: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave569: one_cell Ubuntu tip dropped the slice-init encoder
  # (if-before-call + mid-assign). HARD BAN tip PRODUCT reinject
  # on both ends. Keep the w438 overlay.
  if [ -f src/runtime_pipeline_abi_arr_lit_flat_one_cell_thin.x ]; then
    touch src/.pabi_w569_arr_lit_flat_one_cell.stamp
    rm -f src/.pabi_w438_arr_lit_flat_one_cell.stamp
    log "pipeline_abi w569 arr_lit_flat_one_cell: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave570: cells Ubuntu tip dropped every encoder (while +
  # st=one_cell then if). HARD BAN tip PRODUCT reinject on both
  # ends. Keep the w438 overlay.
  if [ -f src/runtime_pipeline_abi_arr_lit_flat_cells_thin.x ]; then
    touch src/.pabi_w570_arr_lit_flat_cells.stamp
    rm -f src/.pabi_w438_arr_lit_flat_cells.stamp
    log "pipeline_abi w570 arr_lit_flat_cells: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave571: one_row Ubuntu tip dropped kind_ord + glue_emit
  # (if-before-call + ko=call then if + row_st=call then if;
  # only cells dispatch UND). HARD BAN tip PRODUCT reinject
  # on both ends. Keep the w438 overlay.
  if [ -f src/runtime_pipeline_abi_arr_lit_flat_one_row_thin.x ]; then
    touch src/.pabi_w571_arr_lit_flat_one_row.stamp
    rm -f src/.pabi_w438_arr_lit_flat_one_row.stamp
    log "pipeline_abi w571 arr_lit_flat_one_row: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave572: rows Ubuntu tip dropped every encoder (while +
  # mid-assign + st=one_row then if). HARD BAN tip PRODUCT
  # reinject on both ends. Keep the w438 overlay.
  if [ -f src/runtime_pipeline_abi_arr_lit_flat_rows_thin.x ]; then
    touch src/.pabi_w572_arr_lit_flat_rows.stamp
    rm -f src/.pabi_w438_arr_lit_flat_rows.stamp
    log "pipeline_abi w572 arr_lit_flat_rows: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave573: struct Ubuntu tip dropped every encoder (if-before-call
  # + mid-assign + st=glue_emit then if). HARD BAN tip PRODUCT
  # reinject on both ends. Keep the w438 overlay.
  if [ -f src/runtime_pipeline_abi_arr_lit_flat_struct_thin.x ]; then
    touch src/.pabi_w573_arr_lit_flat_struct.stamp
    rm -f src/.pabi_w438_arr_lit_flat_struct.stamp
    log "pipeline_abi w573 arr_lit_flat_struct: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave574: one_scalar Ubuntu tip dropped every encoder (rc=lea/mov
  # then if + may_clobber=call + rc=scalar_elem then if +
  # if(may_clobber) rc=repark + fi=flat_i[0] + rc=store then if +
  # flat_i[0]=fi+1). HARD BAN tip PRODUCT reinject on both ends.
  # Keep the w438 overlay.
  if [ -f src/runtime_pipeline_abi_arr_lit_flat_one_scalar_thin.x ]; then
    touch src/.pabi_w574_arr_lit_flat_one_scalar.stamp
    rm -f src/.pabi_w438_arr_lit_flat_one_scalar.stamp
    log "pipeline_abi w574 arr_lit_flat_one_scalar: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave575: step Ubuntu tip dropped elem_ref + kind_ord + try_struct
  # (elem_ref=call then if + ko=kind_ord then if + if(ko==46)
  # return flatten + tr=try_struct then if; only flatten recurse
  # + one_scalar dispatch UND). HARD BAN tip PRODUCT reinject
  # on both ends. Keep the w438 overlay.
  if [ -f src/runtime_pipeline_abi_arr_lit_flat_step_thin.x ]; then
    touch src/.pabi_w575_arr_lit_flat_step.stamp
    rm -f src/.pabi_w438_arr_lit_flat_step.stamp
    log "pipeline_abi w575 arr_lit_flat_step: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave576: scalar Ubuntu tip dropped every encoder (n_arr=num_elems
  # then if + store_sz=leaf_esz then if + while rc=step then if;
  # Darwin original 2 UND = num_elems + step). HARD BAN tip
  # PRODUCT reinject on both ends. Keep the w438 overlay.
  if [ -f src/runtime_pipeline_abi_arr_lit_flat_scalar_thin.x ]; then
    touch src/.pabi_w576_arr_lit_flat_scalar.stamp
    rm -f src/.pabi_w438_arr_lit_flat_scalar.stamp
    log "pipeline_abi w576 arr_lit_flat_scalar: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave577: main Ubuntu tip dropped kind_ord + elem_type + type_kind
  # + type_elem (if-before-call + ko=kind_ord then if + dest_elem
  # then dest_ek + inner then inner_k; only slice_rows + scalar
  # dispatch UND). Darwin original 6 UND. HARD BAN tip PRODUCT
  # reinject on both ends. Keep the w438 overlay.
  if [ -f src/runtime_pipeline_abi_arr_lit_flat_thin.x ]; then
    touch src/.pabi_w577_arr_lit_flat.stamp
    rm -f src/.pabi_w438_arr_lit_flat.stamp
    log "pipeline_abi w577 arr_lit_flat_main: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave577: no remaining PREFER peers. Overlay stays w438.
  return 0
}

# wave439 M2: arr_return Cap residual — flat peer chain unlock.
# PRODUCT inject wave439:
#   BOTH: PREFER_ASM peer chain (Ubuntu emptied on co-located Path arms /
#   nested micro-unsafe / CG002 label patch). Order was a0→a→a2→b0_prep→
#   b0_durable→b0→b→c_dest_array→c_slice→c_fallback→c→d→main.
#   Remaining PREFER: none (family HARD BAN tip reinject; keep w439).
# G.7: semantics match mega pipeline_asm_emit_return_elf_impl.
# PLATFORM: SHARED · stamp-only BAN (no PREFER peers).
# wave439/477/510/560/578/579/580/581/582/583/584/585/586/587 M2:
#   arr_return Cap residual — peer-flat then HARD BAN tip reinject.
# PRODUCT inject wave439: BOTH PREFER peer chain (now stamp-only BAN).
# wave477: tip PRODUCT reinject of b0/c → L2 CG002 4/5 HARD BAN (claimed).
# wave510: b0/c tipU heal (pipe-cell mid `rc=call()`) + formalize HARD BAN
#   tip reinject (stamp w510; do not call inject_thin_leaf for b0/c; keep
#   w439 leftover overlay).
# wave560: a0 HARD BAN. wave578: a HARD BAN (if-before-call + rc=sret
#   then if). wave579: a2 HARD BAN (if-before-call + rc=emit then if +
#   rc=mov then if + rc=memcpy then if). wave580: b0_prep HARD BAN
#   (Ubuntu SEGV 139 = *i32 out store; if-before-call + rc=call then if).
# wave581: b0_durable HARD BAN (Ubuntu UND=2 = if-before-call + mid-assign
#   + nested while + rc=call then if).
# wave582: b HARD BAN (Ubuntu UND=0 = if-before-call + esc=call then if
#   + rc=emit then if + mid-assign + rc=promote then if).
# wave583: c_dest_array HARD BAN (Ubuntu UND=1 = if-before-call +
#   mid-assign + tk=kind_ord then if + rc=durable then if +
#   rc=force_esz then if; only void bump survived).
# wave584: c_slice HARD BAN (Ubuntu UND=1 = if-before-call +
#   mid-assign + nested tk=kind_ord then if + rc=durable then if +
#   rc=force_esz then if + rc=push/mov/pop then if; only void bump
#   survived).
# wave585: c_fallback HARD BAN (Ubuntu UND=0 = rc=emit then if +
#   if-before-assign + mid-assign rty/sty + rc=promote then if).
# wave586: d HARD BAN (Ubuntu UND=0 = unused ko/sret sink then if +
#   rc=emit then if + if-before-assign + mid-assign rty/sty +
#   rc=promote then if).
# wave587: main HARD BAN (Ubuntu UND=1 = jmp only; mid-assign ly/ret_op
#   + if-before-call + sequential rc=path then if + rc=spills/cps then
#   if + while tj_lbl). Remaining PREFER: none.
# G.7: semantics match mega return path B0/C leave.
# PLATFORM: SHARED · b0/c/a0/a/a2/b0_prep/b0_durable/b/c_dest_array/c_slice/c_fallback/d/main BAN tip reinject.
pipeline_abi_inject_arr_return_thin() {
  local o="$1"
  local main_x="src/runtime_pipeline_abi_arr_return_thin.x"
  local ban_x ban_s ban_peer
  [ -s "$o" ] && [ -f "$main_x" ] || return 0
  # wave477/w510: HARD BAN tip product reinject of b0 + c (L2 CG002).
  # wave560: a0 Ubuntu tip dropped every call; HARD BAN reinject (keep w439).
  # wave578: a Ubuntu tip dropped the sret encoder (if-before-call +
  #   rc=sret then if). HARD BAN tip PRODUCT reinject (keep w439).
  # wave579: a2 Ubuntu tip dropped emit/mov/memcpy (if-before-call +
  #   rc=call then if). HARD BAN tip PRODUCT reinject (keep w439).
  # wave580: b0_prep Ubuntu tip SEGV 139 (*i32 out store) plus
  #   if-before-call / rc=call then if. HARD BAN tip PRODUCT reinject
  #   (keep w439).
  # wave581: b0_durable Ubuntu tip UND=2 (align + pipe_store only) from
  #   if-before-call / mid-assign / nested while / rc=call then if.
  #   HARD BAN tip PRODUCT reinject (keep w439).
  # wave582: b Ubuntu tip UND=0 from if-before-call / esc=call then if
  #   / rc=emit then if / mid-assign / rc=promote then if. HARD BAN
  #   tip PRODUCT reinject (keep w439).
  # wave583: c_dest_array Ubuntu tip UND=1 (void bump only) from
  #   if-before-call / mid-assign / tk=kind_ord then if / rc=durable
  #   then if / rc=force_esz then if. HARD BAN tip PRODUCT reinject
  #   (keep w439).
  # wave584: c_slice Ubuntu tip UND=1 (void bump only) from
  #   if-before-call / mid-assign / nested tk=kind_ord then if /
  #   rc=durable then if / rc=force_esz then if / rc=push/mov/pop
  #   then if. HARD BAN tip PRODUCT reinject (keep w439).
  # wave585: c_fallback Ubuntu tip UND=0 from rc=emit then if /
  #   if-before-assign / mid-assign rty/sty / rc=promote then if.
  #   HARD BAN tip PRODUCT reinject (keep w439).
  # wave586: d Ubuntu tip UND=0 from unused ko/sret sink then if /
  #   rc=emit then if / if-before-assign / mid-assign rty/sty /
  #   rc=promote then if. HARD BAN tip PRODUCT reinject (keep w439).
  # wave587: main Ubuntu tip UND=1 (jmp only) from mid-assign
  #   ly/ret_op + if (ret_op != 0) + sequential rc=path then if +
  #   rc=spills/cps then if + while tj_lbl. Darwin original 19 UND.
  #   HARD BAN tip PRODUCT reinject (keep w439).
  # tipU heal bodies remain in tree for inventory; stamp-only skip.
  for ban_peer in \
    "src/runtime_pipeline_abi_arr_return_b0_thin.x|.pabi_w510_arr_return_b0.stamp" \
    "src/runtime_pipeline_abi_arr_return_c_thin.x|.pabi_w510_arr_return_c.stamp" \
    "src/runtime_pipeline_abi_arr_return_a0_thin.x|.pabi_w560_arr_return_a0.stamp" \
    "src/runtime_pipeline_abi_arr_return_a_thin.x|.pabi_w578_arr_return_a.stamp" \
    "src/runtime_pipeline_abi_arr_return_a2_thin.x|.pabi_w579_arr_return_a2.stamp" \
    "src/runtime_pipeline_abi_arr_return_b0_prep_thin.x|.pabi_w580_arr_return_b0_prep.stamp" \
    "src/runtime_pipeline_abi_arr_return_b0_durable_thin.x|.pabi_w581_arr_return_b0_durable.stamp" \
    "src/runtime_pipeline_abi_arr_return_b_thin.x|.pabi_w582_arr_return_b.stamp" \
    "src/runtime_pipeline_abi_arr_return_c_dest_array_thin.x|.pabi_w583_arr_return_c_dest_array.stamp" \
    "src/runtime_pipeline_abi_arr_return_c_slice_thin.x|.pabi_w584_arr_return_c_slice.stamp" \
    "src/runtime_pipeline_abi_arr_return_c_fallback_thin.x|.pabi_w585_arr_return_c_fallback.stamp" \
    "src/runtime_pipeline_abi_arr_return_d_thin.x|.pabi_w586_arr_return_d.stamp" \
    "src/runtime_pipeline_abi_arr_return_thin.x|.pabi_w587_arr_return.stamp"
  do
    ban_x="${ban_peer%%|*}"
    ban_s="src/${ban_peer#*|}"
    if [ -f "$ban_x" ] && { [ ! -f "$ban_s" ] || [ "$ban_x" -nt "$ban_s" ]; }; then
      touch "$ban_s"
      rm -f src/.pabi_w439_arr_return_b0.stamp src/.pabi_w439_arr_return_c.stamp \
        src/.pabi_w477_arr_return_b0.stamp src/.pabi_w477_arr_return_c.stamp \
        src/.pabi_w439_arr_return_a0.stamp src/.pabi_w439_arr_return_a.stamp \
        src/.pabi_w439_arr_return_a2.stamp src/.pabi_w439_arr_return_b0_prep.stamp \
        src/.pabi_w439_arr_return_b0_durable.stamp src/.pabi_w439_arr_return_b.stamp \
        src/.pabi_w439_arr_return_c_dest_array.stamp \
        src/.pabi_w439_arr_return_c_slice.stamp \
        src/.pabi_w439_arr_return_c_fallback.stamp \
        src/.pabi_w439_arr_return_d.stamp \
        src/.pabi_w439_arr_return.stamp
      log "pipeline_abi w510-arr-return: tipU heal stamped; tip PRODUCT reinject HARD BAN for $(basename "$ban_x") (keep w439)"
    fi
  done
  # wave587: no remaining PREFER peers. Overlay stays w439.
  return 0
}

# wave440/442/446/447 M2: arr_struct_lit Cap residual — asymmetric unlock.
# PRODUCT inject:
#   MACOS (w440): PREFER_ASM full peer chain.
#   LINUX (w442): -E peer chain; (w446): nine-peer pure-asm overlay
#     (call_*+resolve_call+copy_*+zero+resolve_vf).
#   wave447 HARD BAN tip pure-asm for arrlit+main: tip regen → opt SEGV 139
#     (even param-touching stubs); bare `return 0` stub → opt=94. Keep -E.
#   wave455: no-local kind_ord main tip → opt=94 (tip .o U-starved). BAN.
# wave591: arrlit Ubuntu tip `-backend asm -c` UND=1 (vector_let_init
#   only). Darwin original 9/9. arr_struct_lit_arrlit_store_encoders
#   recovered 10/10. HARD BAN tip PRODUCT reinject both ends (first
#   loop too). Keep w440 overlay. Do not un-BAN arrlit+main.
# G.7: semantics match mega glue_struct_lit_store_fixed_array_field_elf_c.
# PLATFORM: SHARED · MACOS pure-asm / LINUX -E + w446 heal-asm.
pipeline_abi_inject_arr_struct_lit_thin() {
  local o="$1"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  local peer lo_x lo_stamp lo_tag lo_rest
  local prefer_asm=1
  local need_heal=0
  local main_x="src/runtime_pipeline_abi_arr_struct_lit_thin.x"
  local main_s="src/.pabi_w446_arr_struct_lit.stamp"
  local _hx _hs _pair
  [ -s "$o" ] && [ -f "$main_x" ] || return 0
  # wave561: call_elems Ubuntu tip dropped 7/8 calls (while + mid-assign).
  # HARD BAN tip PRODUCT reinject on both ends. Keep the w440/w446 overlay.
  if [ -f src/runtime_pipeline_abi_arr_struct_lit_call_elems_thin.x ]; then
    touch src/.pabi_w561_arr_struct_lit_call_elems.stamp
    rm -f src/.pabi_w440_arr_struct_lit_call_elems.stamp \
      src/.pabi_w446_heal_call_elems.stamp
    log "pipeline_abi w561 arr_struct_lit_call_elems: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave562: zero Ubuntu tip dropped every call (while + i64 mid-assign).
  # HARD BAN tip PRODUCT reinject on both ends. Keep the w440/w446 overlay.
  if [ -f src/runtime_pipeline_abi_arr_struct_lit_zero_thin.x ]; then
    touch src/.pabi_w562_arr_struct_lit_zero.stamp
    rm -f src/.pabi_w440_arr_struct_lit_zero.stamp \
      src/.pabi_w446_heal_zero.stamp
    log "pipeline_abi w562 arr_struct_lit_zero: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave563: call_one_elem Ubuntu tip dropped every call (rc=call then if).
  # HARD BAN tip PRODUCT reinject on both ends. Keep the w440/w446 overlay.
  if [ -f src/runtime_pipeline_abi_arr_struct_lit_call_one_elem_thin.x ]; then
    touch src/.pabi_w563_arr_struct_lit_call_one_elem.stamp
    rm -f src/.pabi_w440_arr_struct_lit_call_one_elem.stamp \
      src/.pabi_w446_heal_call_one_elem.stamp
    log "pipeline_abi w563 arr_struct_lit_call_one_elem: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave564: copy_elems Ubuntu tip dropped every call (while + rc=call then if).
  # HARD BAN tip PRODUCT reinject on both ends. Keep the w440/w446 overlay.
  if [ -f src/runtime_pipeline_abi_arr_struct_lit_copy_elems_thin.x ]; then
    touch src/.pabi_w564_arr_struct_lit_copy_elems.stamp
    rm -f src/.pabi_w440_arr_struct_lit_copy_elems.stamp \
      src/.pabi_w446_heal_copy_elems.stamp
    log "pipeline_abi w564 arr_struct_lit_copy_elems: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave565: copy_bulk Ubuntu tip kept only pipe_store (rc=call then if / mid-assign).
  # HARD BAN tip PRODUCT reinject on both ends. Keep the w440/w446 overlay.
  # Do not BAN copy dispatcher (Ubuntu tip already U-complete).
  if [ -f src/runtime_pipeline_abi_arr_struct_lit_copy_bulk_thin.x ]; then
    touch src/.pabi_w565_arr_struct_lit_copy_bulk.stamp
    rm -f src/.pabi_w440_arr_struct_lit_copy_bulk.stamp \
      src/.pabi_w446_heal_copy_bulk.stamp
    log "pipeline_abi w565 arr_struct_lit_copy_bulk: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave566: call_bulk Ubuntu tip kept only pipe_store (rc=call then if / mid-assign).
  # HARD BAN tip PRODUCT reinject on both ends. Keep the w440/w446 overlay.
  # Do not BAN call dispatcher (Ubuntu tip already U-complete).
  if [ -f src/runtime_pipeline_abi_arr_struct_lit_call_bulk_thin.x ]; then
    touch src/.pabi_w566_arr_struct_lit_call_bulk.stamp
    rm -f src/.pabi_w440_arr_struct_lit_call_bulk.stamp \
      src/.pabi_w446_heal_call_bulk.stamp
    log "pipeline_abi w566 arr_struct_lit_call_bulk: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave567: resolve_vf Ubuntu tip `-backend asm -c` SEGV 139 on
  #   `*out_src_off = i32`. Original if-after-assign also UND-drops.
  # HARD BAN tip PRODUCT reinject on both ends. Keep the w440/w446 overlay.
  # Do not BAN copy dispatcher or call dispatcher (already U-complete).
  if [ -f src/runtime_pipeline_abi_arr_struct_lit_resolve_vf_thin.x ]; then
    touch src/.pabi_w567_arr_struct_lit_resolve_vf.stamp
    rm -f src/.pabi_w440_arr_struct_lit_resolve_vf.stamp \
      src/.pabi_w446_heal_resolve_vf.stamp
    log "pipeline_abi w567 arr_struct_lit_resolve_vf: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave591: arrlit Ubuntu tip dropped 8/9 encoders (mid-assign lit_n
  #   then if / if-before-return sret_direct / while / rc=call then if).
  # HARD BAN tip PRODUCT reinject on both ends. Keep the w440 overlay.
  # Do not un-BAN arrlit+main (wave447 opt SEGV / opt=94).
  if [ -f src/runtime_pipeline_abi_arr_struct_lit_arrlit_thin.x ]; then
    touch src/.pabi_w591_arr_struct_lit_arrlit.stamp
    rm -f src/.pabi_w440_arr_struct_lit_arrlit.stamp
    log "pipeline_abi w591 arr_struct_lit_arrlit: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # wave592: main Ubuntu tip dropped 12/13 encoders (if-before-call /
  #   mid-assign src/iko/n_arr/esz/elem_tr/field_mag / rc=call then if).
  # HARD BAN first-loop tip PRODUCT reinject both ends. Keep the w440 overlay.
  # Do not BAN copy dispatcher or call dispatcher (already U-complete).
  # Do not un-BAN arrlit+main (wave447 opt SEGV / opt=94).
  if [ -f src/runtime_pipeline_abi_arr_struct_lit_thin.x ]; then
    touch src/.pabi_w592_arr_struct_lit.stamp
    rm -f src/.pabi_w440_arr_struct_lit.stamp
    log "pipeline_abi w592 arr_struct_lit: tipU stamped; tip PRODUCT reinject HARD BAN"
  fi
  # PLATFORM: LINUX — soft -E chain (w442) + nine-peer pure-asm heal (w446).
  case "$(uname -s)" in
    Linux) prefer_asm=0 ;;
  esac
  case "$(uname -s)" in
    Linux)
      for _pair in \
        "src/runtime_pipeline_abi_arr_struct_lit_call_bulk_thin.x|src/.pabi_w566_arr_struct_lit_call_bulk.stamp" \
        "src/runtime_pipeline_abi_arr_struct_lit_call_one_elem_thin.x|src/.pabi_w563_arr_struct_lit_call_one_elem.stamp" \
        "src/runtime_pipeline_abi_arr_struct_lit_call_elems_thin.x|src/.pabi_w561_arr_struct_lit_call_elems.stamp" \
        "src/runtime_pipeline_abi_arr_struct_lit_resolve_call_thin.x|src/.pabi_w446_heal_resolve_call.stamp" \
        "src/runtime_pipeline_abi_arr_struct_lit_copy_bulk_thin.x|src/.pabi_w565_arr_struct_lit_copy_bulk.stamp" \
        "src/runtime_pipeline_abi_arr_struct_lit_copy_elems_thin.x|src/.pabi_w564_arr_struct_lit_copy_elems.stamp" \
        "src/runtime_pipeline_abi_arr_struct_lit_copy_thin.x|src/.pabi_w446_heal_copy.stamp" \
        "src/runtime_pipeline_abi_arr_struct_lit_zero_thin.x|src/.pabi_w562_arr_struct_lit_zero.stamp" \
        "src/runtime_pipeline_abi_arr_struct_lit_resolve_vf_thin.x|src/.pabi_w567_arr_struct_lit_resolve_vf.stamp"
      do
        _hx="${_pair%%|*}"
        _hs="${_pair#*|}"
        if [ -f "$_hx" ] && { [ ! -f "$_hs" ] || [ "$_hx" -nt "$_hs" ]; }; then
          need_heal=1
          break
        fi
      done
      ;;
  esac
  if [ -f "$main_s" ] && [ ! "$main_x" -nt "$main_s" ] && [ "$need_heal" = "0" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM="$prefer_asm"
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  for peer in \
    "src/runtime_pipeline_abi_arr_struct_lit_resolve_call_thin.x|.pabi_w440_arr_struct_lit_resolve_call.stamp|w440-arr-struct-lit-resolve-call" \
    "src/runtime_pipeline_abi_arr_struct_lit_copy_thin.x|.pabi_w440_arr_struct_lit_copy.stamp|w440-arr-struct-lit-copy"
  do
    lo_x="${peer%%|*}"
    lo_rest="${peer#*|}"
    lo_stamp="src/${lo_rest%%|*}"
    lo_tag="${lo_rest#*|}"
    if [ -f "$lo_x" ] && { [ ! -f "$lo_stamp" ] || [ "$lo_x" -nt "$lo_stamp" ]; }; then
      pipeline_abi_inject_thin_leaf "$o" "$lo_x" "$lo_tag"
      rc=$?
      if [ "$rc" -eq 0 ]; then
        touch "$lo_stamp"
      else
        break
      fi
    fi
  done
  # wave446: nine-peer pure-asm overlay (LINUX).
  # wave447/455: arrlit+main tip pure-asm HARD BAN (opt SEGV / opt=94); stay -E.
  # wave591: arrlit first-loop also HARD BAN (Ubuntu UND=1 encoder drop).
  # wave592: main first-loop also HARD BAN (Ubuntu UND=1 encoder drop).
  # PLATFORM: LINUX gold · MACOS skipped (full chain already PREFER).
  case "$(uname -s)" in
    Linux)
      if [ "$rc" -eq 0 ]; then
        export XLANG_PABI_THIN_PREFER_ASM=1
        export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
        for peer in \
          "src/runtime_pipeline_abi_arr_struct_lit_resolve_call_thin.x|.pabi_w446_heal_resolve_call.stamp|w446-heal-resolve-call" \
          "src/runtime_pipeline_abi_arr_struct_lit_copy_thin.x|.pabi_w446_heal_copy.stamp|w446-heal-copy"
        do
          lo_x="${peer%%|*}"
          lo_rest="${peer#*|}"
          lo_stamp="src/${lo_rest%%|*}"
          lo_tag="${lo_rest#*|}"
          if [ -f "$lo_x" ] && { [ ! -f "$lo_stamp" ] || [ "$lo_x" -nt "$lo_stamp" ]; }; then
            pipeline_abi_inject_thin_leaf "$o" "$lo_x" "$lo_tag"
            rc=$?
            if [ "$rc" -eq 0 ]; then
              touch "$lo_stamp"
            else
              break
            fi
          fi
        done
        if [ "$rc" -eq 0 ]; then
          touch "$main_s"
        fi
      fi
      ;;
  esac
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  return "$rc"
}

# wave406 M2: w157_sum Cap residual — HARD BAN tip reinject.
# PRODUCT inject wave406:
#   BOTH ends: HARD BAN tip reinject (stamp only).
#   Probe: standalone -c PREFER green Darwin 24744B / Ubuntu 22031B, but
#   Darwin product inject → ARM64_RELOC_BRANCH26 on ld -r thin member
#   (same class as w404 bvsc). Keep leftover; no tip overlay.
# G.7: thin body matches mega wave157 leave (cold twin only).
# PLATFORM: SHARED · both ends hard-skip.
pipeline_abi_inject_w157_sum_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_w157_sum_thin.x"
  local stamp="src/.pabi_w406_w157_sum.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — HARD BAN tip reinject (Darwin BRANCH26).
  touch "$stamp"
  return 0
}

# wave404 M2: binop_var_slot_cache Cap residual — HARD BAN tip reinject.
# PRODUCT inject wave404:
#   BOTH ends: HARD BAN tip reinject (stamp only).
#   Probe: standalone -c PREFER green Darwin 8235B / Ubuntu 9142B, but
#   product inject → Darwin ARM64_RELOC_BRANCH26 on ld -r thin member;
#   Ubuntu inject → xlang_asm SEGV (L2 0/5). Keep leftover; no tip overlay.
# G.7: thin body matches mega wave210 leave (cold twin only).
# PLATFORM: SHARED · both ends hard-skip.
pipeline_abi_inject_binop_var_slot_cache_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_binop_var_slot_cache_thin.x"
  local stamp="src/.pabi_w404_binop_var_slot_cache.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — HARD BAN tip reinject (Darwin BRANCH26 / Ubuntu SEGV).
  touch "$stamp"
  return 0
}

# wave405/w478 M2: binop_stack_spill_try_reload Cap residual — PREFER both ends.
# wave478: gate+rax+rbx no-local (tip U-complete); stamps w478.
# G.7: thin body matches mega wave211 leave.
# PLATFORM: SHARED · both ends PREFER.
pipeline_abi_inject_binop_stack_spill_try_reload_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_binop_stack_spill_try_reload_thin.x"
  local stamp="src/.pabi_w478_heal_spill_reload.stamp"
  local rax_x="src/runtime_pipeline_abi_binop_stack_spill_try_reload_rax_thin.x"
  local rax_s="src/.pabi_w478_heal_spill_reload_rax.stamp"
  local rbx_x="src/runtime_pipeline_abi_binop_stack_spill_try_reload_rbx_thin.x"
  local rbx_s="src/.pabi_w478_heal_spill_reload_rbx.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # Skip only when all three stamps are fresh
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ] \
    && { [ ! -f "$rax_x" ] || { [ -f "$rax_s" ] && [ ! "$rax_x" -nt "$rax_s" ]; }; } \
    && { [ ! -f "$rbx_x" ] || { [ -f "$rbx_s" ] && [ ! "$rbx_x" -nt "$rbx_s" ]; }; }; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — PREFER_ASM (standalone -c + product inject gate green).
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  if [ -f "$rax_x" ] && { [ ! -f "$rax_s" ] || [ "$rax_x" -nt "$rax_s" ]; }; then
    pipeline_abi_inject_thin_leaf "$o" "$rax_x" "w478-heal-spill-reload-rax"
    rc=$?
    if [ "$rc" -eq 0 ]; then touch "$rax_s"; fi
  fi
  if [ "$rc" -eq 0 ] && [ -f "$rbx_x" ] && { [ ! -f "$rbx_s" ] || [ "$rbx_x" -nt "$rbx_s" ]; }; then
    pipeline_abi_inject_thin_leaf "$o" "$rbx_x" "w478-heal-spill-reload-rbx"
    rc=$?
    if [ "$rc" -eq 0 ]; then touch "$rbx_s"; fi
  fi
  if [ "$rc" -eq 0 ]; then
    pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w478-heal-spill-reload"
    rc=$?
  fi
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    # Retire w405 stamp so prefer does not double-gate on stale name
    rm -f src/.pabi_w405_binop_stack_spill_try_reload.stamp
  fi
  return "$rc"
}

# wave410/513 M2: asm73_chaitin Cap residual — HARD BAN tip reinject.
# PRODUCT inject wave410:
#   BOTH ends: HARD BAN tip reinject (stamp only).
#   Probe: standalone -c PREFER green Darwin 4125B / Ubuntu 4737B, but
#   Darwin product inject → ARM64_RELOC_BRANCH26 on ld -r thin member.
# wave513: tipU 0/2→4/4 pipe-cell heal (mid cfg_parent_get /
#   linear_max_live_n_get); stamp → w513; tip PRODUCT reinject still HARD BAN.
# G.7: thin body matches mega wave212 leave (cold twin only).
# PLATFORM: SHARED · both ends hard-skip.
pipeline_abi_inject_asm73_chaitin_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_asm73_chaitin_thin.x"
  local stamp="src/.pabi_w513_asm73_chaitin.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — HARD BAN tip reinject (Darwin BRANCH26).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w410_asm73_chaitin.stamp
  log "pipeline_abi w513-asm73-chaitin: tipU heal stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}

# wave410b/512 M2: asm73_live_interf Cap residual — HARD BAN tip reinject.
# PRODUCT inject wave410b:
#   BOTH ends: HARD BAN tip reinject (stamp only).
#   Probe: standalone -c PREFER green both ends, Darwin product inject →
#   ARM64_RELOC_BRANCH26 (same class as chaitin/al_nc/w157).
# wave512: tipU 2/5→5/5 pipe-cell heal (mid live_fwd_n_get / off_at /
#   live_at_stmt_as_u8); stamp → w512; tip PRODUCT reinject still HARD BAN.
# G.7: thin body matches mega wave213 leave (cold twin only).
# PLATFORM: SHARED · both ends hard-skip.
pipeline_abi_inject_asm73_live_interf_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_asm73_live_interf_thin.x"
  local stamp="src/.pabi_w512_asm73_live_interf.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — HARD BAN tip reinject (Darwin BRANCH26).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w410_asm73_live_interf.stamp
  log "pipeline_abi w512-asm73-live-interf: tipU heal stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}

# wave410c/511 M2: asm73_live_set Cap residual — HARD BAN tip reinject.
# PRODUCT inject wave410c:
#   BOTH ends: HARD BAN tip reinject (stamp only).
#   Same BSS/COMMON tip-reinject class as chaitin/live_interf (-c green;
#   product inject deferred BAN without separate BRANCH26 repro — family).
# wave511: tipU 3/6→6/6 pipe-cell heal (mid pipe_load / active_get /
#   stmt_order_has_cfg); stamp → w511; tip PRODUCT reinject still HARD BAN.
# G.7: thin body matches mega wave214 leave (cold twin only).
# PLATFORM: SHARED · both ends hard-skip.
pipeline_abi_inject_asm73_live_set_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_asm73_live_set_thin.x"
  local stamp="src/.pabi_w511_asm73_live_set.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — HARD BAN tip reinject (asm73 BSS family).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w410_asm73_live_set.stamp
  log "pipeline_abi w511-asm73-live-set: tipU heal stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}

# wave216/348/375/588 for_call_args mega leave. G.7: match mega entry.
# PRODUCT inject wave375: PREFER_ASM both ends (ALLOW_E_REPLACE + stamp).
# wave348: historic leftover mega lea'd i32 VAR CALL args; thin does
# resolve→use_lea→load (scalar rvalue). wave375: tip standalone -c 27881B
# PREFER green — unlock both-end PREFER (was FORCE -E).
# wave588: Ubuntu tip `-backend asm -c` empty .o (if-before-call /
#   mid-assign / rc=call then if / local u8[256] / *i32 out slots).
#   Darwin original 68/68. for_call_args_store_encoders recovered
#   68/68. HARD BAN tip PRODUCT reinject both ends. Keep w375 overlay.
# PLATFORM: SHARED · stamp-only BAN then return 0.
pipeline_abi_inject_for_call_args_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_for_call_args_thin.x"
  local stamp="src/.pabi_w588_for_call_args.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — wave588 Soft Cap HARD BAN tip reinject (keep w375).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w375_for_call_args.stamp src/.pabi_w348_for_call_args.stamp
  log "pipeline_abi w588-for-call-args: tipU stamped; tip PRODUCT reinject HARD BAN (keep w375)"
  return 0
}

# PRODUCT inject stamp w351/w378/w387/516: Cap A module fixed-array INDEX rvalue.
# Roots: (1) mega VAR modlet_find gate; (2) Darwin redefine poison of
# block_body→rec; (3) Ubuntu PREFER pure-asm emit_index breaks option
# (run=240) — host-C -E thin is green. Thin body ≡ mega post-gate.
# wave378 reconfirm: Ubuntu inject-pabi-leaf PREFER → L2 option=240 again;
# stay LINUX -E (BAN Ubuntu PREFER). Darwin PREFER path unchanged.
# wave387 HARD BAN reinject both ends: stay prior overlay (Darwin PREFER
# weaken∪asm_expr / Ubuntu -E); tip reinject poison class.
# wave516: tipU 6/13→15/15 pipe-cell heal (mid base/idx/esz/hit/rc/res_ty/rtk);
#   stamp → w516; tip PRODUCT reinject still HARD BAN (keep prior overlay).
# PLATFORM: SHARED · BAN reinject both ends.
pipeline_abi_inject_emit_index_thin() {
  local o="$1"
  local thin_idx="src/runtime_pipeline_abi_emit_index_thin.x"
  local stamp="src/.pabi_w516_emit_index.stamp"
  [ -s "$o" ] && [ -f "$thin_idx" ] || return 0
  # PLATFORM: SHARED — hard BAN reinject (do not call inject_thin_leaf /
  # Darwin weaken path). Keep prior green overlay.
  if [ -f "$stamp" ] && [ ! "$thin_idx" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w350_emit_index.stamp src/.pabi_w351_emit_index.stamp \
    src/.pabi_w387_emit_index.stamp
  log "pipeline_abi w516-emit-index: tipU heal stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}

# wave411/492 M2: call_method_wrappers Cap residual — PREFER both ends.
# PRODUCT inject wave492:
#   tipU heal (no-local arena expr ptr → tipU 5/5) + BOTH tip PREFER
#   (Darwin -c／Ubuntu pure-asm first-wins; dual-end L2 5/5 verified).
# G.7: thin body matches mega wave217 CALL/METHOD leave.
# PLATFORM: SHARED · both ends PREFER.
pipeline_abi_inject_call_method_wrappers_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_call_method_wrappers_thin.x"
  local stamp="src/.pabi_w492_call_method_wrappers.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — PREFER_ASM (wave492 tipU heal + dual-end L2 verified).
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w492-call-method-wrappers"
  rc=$?
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
  fi
  return "$rc"
}

# wave409b M2: al_nc_seq Cap residual — HARD BAN tip reinject.
# PRODUCT inject wave409b:
#   BOTH ends: HARD BAN tip reinject (stamp only).
#   Probe: standalone -c PREFER green Darwin 632B / Ubuntu 985B, but
#   Darwin product inject → ARM64_RELOC_BRANCH26 on ld -r thin member.
# G.7: thin body matches mega wave219 leave (cold twin only).
# PLATFORM: SHARED · both ends hard-skip.
pipeline_abi_inject_al_nc_seq_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_al_nc_seq_thin.x"
  local stamp="src/.pabi_w409_al_nc_seq.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — HARD BAN tip reinject (Darwin BRANCH26).
  touch "$stamp"
  return 0
}

# wave317/342/380/601/618 M2: emit_ctx_bss Cap residual .x thin.
# wave380/601 walls (Darwin BRANCH26; Ubuntu PREFER L2 SEGV; LINUX -E
#   dual-BSS option ptr SEGV) were pre-fix eras: BRANCH26 = the w612 typed
#   reloc; the SEGVs = the w613 COMMON class (this TU's file-level let
#   option cells pinned read-only / dual sidecar instances). Standalone -c
#   now: T=15 UND=0, all 6 cells proper commons.
# wave618: product PREFER_ASM both ends, injected as ONE set with the
#   func_index + module_dep peers (single consistent cell family; partial
#   replacement was exactly the w601 dual-BSS trigger).
# G.7 match mega wave220/221 leave. PLATFORM: SHARED · PREFER_ASM.
pipeline_abi_inject_emit_ctx_bss_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_emit_ctx_bss_thin.x"
  local stamp="src/.pabi_w380_emit_ctx_bss.stamp"
  local stamp_prefer="src/.pabi_w618_emit_ctx_prefer.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ] && [ -f "$stamp_prefer" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then had_newer=1; fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w618-emit-ctx-bss-prefer"
  rc=$?
  if [ "$had_newer" = "1" ]; then export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"; fi
  if [ "$had_prefer" = "1" ]; then export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"; else unset XLANG_PABI_THIN_PREFER_ASM; fi
  if [ "$had_e_repl" = "1" ]; then export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"; else unset XLANG_PABI_THIN_ALLOW_E_REPLACE; fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    touch "$stamp_prefer"
    rm -f src/.pabi_w342_emit_ctx_bss.stamp src/.pabi_w601_emit_ctx_bss.stamp
    log "pipeline_abi w618-emit-ctx-bss: PREFER_ASM replace (trio set with func_index+module_dep)"
  fi
  return "$rc"
}

# wave601/618 M2: emit_ctx func_index get/set peer-flat of bss_thin.
# w601 dual-BSS SEGV was the w613 COMMON/dual-sidecar class; standalone -c
#   now T=2 UND=0. wave618: PREFER as ONE set with bss + module_dep.
# PLATFORM: SHARED · PREFER_ASM (w618 trio set).
pipeline_abi_inject_emit_ctx_func_index_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_emit_ctx_func_index_thin.x"
  local stamp_e="src/.pabi_w601_emit_ctx_func_index.stamp"
  local stamp_prefer="src/.pabi_w618_emit_ctx_prefer.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ] && [ -f "$stamp_prefer" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then had_newer=1; fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w618-emit-ctx-func-index-prefer"
  rc=$?
  if [ "$had_newer" = "1" ]; then export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"; fi
  if [ "$had_prefer" = "1" ]; then export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"; else unset XLANG_PABI_THIN_PREFER_ASM; fi
  if [ "$had_e_repl" = "1" ]; then export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"; else unset XLANG_PABI_THIN_ALLOW_E_REPLACE; fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp_e"
    touch "$stamp_prefer"
    log "pipeline_abi w618-emit-ctx-func-index: PREFER_ASM replace (trio set)"
  fi
  return "$rc"
}

# wave315/340/380/601/618 M2: emit_ctx_module_dep Cap residual .x thin.
# w380/w601 walls were the w612 typed-reloc + w613 COMMON/dual-sidecar
#   classes; standalone -c now T=4 UND=0, 2 cells proper commons.
# wave618: PREFER as ONE set with bss + func_index.
# G.7 match mega wave222 leave. PLATFORM: SHARED · PREFER_ASM (w618 trio).
pipeline_abi_inject_emit_ctx_module_dep_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_emit_ctx_module_dep_thin.x"
  local stamp="src/.pabi_w380_emit_ctx_module_dep.stamp"
  local stamp_prefer="src/.pabi_w618_emit_ctx_prefer.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ] && [ -f "$stamp_prefer" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then had_newer=1; fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w618-emit-ctx-module-dep-prefer"
  rc=$?
  if [ "$had_newer" = "1" ]; then export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"; fi
  if [ "$had_prefer" = "1" ]; then export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"; else unset XLANG_PABI_THIN_PREFER_ASM; fi
  if [ "$had_e_repl" = "1" ]; then export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"; else unset XLANG_PABI_THIN_ALLOW_E_REPLACE; fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    touch "$stamp_prefer"
    rm -f src/.pabi_w340_emit_ctx_module_dep.stamp src/.pabi_w601_emit_ctx_module_dep.stamp
    log "pipeline_abi w618-emit-ctx-module-dep: PREFER_ASM replace (trio set)"
  fi
  return "$rc"
}

# wave601/619 M2: block final_expr tail_join gate.
# wave601 walls are closed at the roots: the unknown-identity fallback was
#   the gate bug (fixed in-body), and the emit_ctx getter state it read is
#   now the w618 ONE-set PREFER family (single cell side).
# wave619: source-level T001 fixed (six bare extern calls wrapped unsafe;
#   standalone -c green T=1 UND=14) — product PREFER_ASM both ends.
# G.7: thin body matches the mega leave (same unsafe fix applied there).
# PLATFORM: SHARED · PREFER_ASM both ends.
pipeline_abi_inject_block_final_expr_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_block_final_expr_thin.x"
  local stamp_e="src/.pabi_w601_block_final_expr.stamp"
  local stamp_prefer="src/.pabi_w619_block_final_expr_prefer.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ] && [ -f "$stamp_prefer" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then had_newer=1; fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w619-block-final-expr-prefer"
  rc=$?
  if [ "$had_newer" = "1" ]; then export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"; fi
  if [ "$had_prefer" = "1" ]; then export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"; else unset XLANG_PABI_THIN_PREFER_ASM; fi
  if [ "$had_e_repl" = "1" ]; then export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"; else unset XLANG_PABI_THIN_ALLOW_E_REPLACE; fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp_e"
    touch "$stamp_prefer"
    log "pipeline_abi w619-block-final-expr: PREFER_ASM replace (no host-cc for this TU)"
  fi
  return "$rc"
}

# wave602/740 M2: return_elf_impl Cap residual .x thin.
# leftover PREFER smash (`sub $0xe98`, no endbr64) drops tail_join ENC_JMP
# so Ubuntu `if { return 7 }` falls through to `return 1`. LINUX w602 -E
# replaced smash T; live leftover gcc W (endbr64, sub $0x1e8) already run=7.
# wave740 Class A: wrap remaining export-extern in unsafe so standalone
# `-backend asm -c` is T=1 U=7 (no T001). HARD BAN product PREFER of this
# simplified exit (Path A–C stay on leftover). Stamp-exists skip even if
# .x is newer so the unsafe wrap cannot first-win as PREFER_ASM.
# wave753: classify thin frame. Live = leftover gcc W (Darwin weak sub
#   #0x260 / LINUX W endbr64 sub $0x1e8 size 0x1a7e). Standalone -c still
#   smash (sub $0xaa8 / #0xab0). Stamp skip correct. Do NOT re-PREFER.
#   Do NOT gcc -E as the repair. Not leftover-first.
# MACOS stamp-only keep overlay. Do not un-BAN arr_return Soft-Cap.
# G.7 mega pipeline_asm_emit_return_elf_impl EXIT. PLATFORM: SHARED.
pipeline_abi_inject_return_elf_impl_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_return_elf_impl_thin.x"
  local stamp_e="src/.pabi_w602_return_elf_impl.stamp"
  local stamp_ban="src/.pabi_w740_return_elf_impl_class_a.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  case "$(uname -s)" in
    Darwin)
      # PLATFORM: MACOS — overlay already runs return-in-if=7.
      # wave740/753: stamp-exists skip even if .x is newer (HARD BAN PREFER).
      if [ -f "$stamp_e" ]; then
        touch "$stamp_ban"
        log "pipeline_abi w740-return-elf-impl: MACOS keep prior overlay; HARD BAN PREFER"
        return 0
      fi
      touch "$stamp_e"
      touch "$stamp_ban"
      log "pipeline_abi w740-return-elf-impl: MACOS keep prior overlay; HARD BAN PREFER"
      return 0
      ;;
    Linux)
      # PLATFORM: LINUX — keep leftover gcc W overlay (run=7).
      # wave740/753: do not PREFER_ASM this simplified exit even if .x is newer.
      # Missing stamp (cold) still -E replaces smash T; PREFER_ASM stays 0.
      if [ -f "$stamp_e" ]; then
        touch "$stamp_ban"
        log "pipeline_abi w740-return-elf-impl: LINUX keep leftover gcc W; HARD BAN PREFER"
        return 0
      fi
      local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
      local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
      local had_prefer=0 had_e_repl=0 rc=0
      if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
      if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
      unset XLANG_PABI_THIN_INJECT_IF_NEWER
      export XLANG_PABI_THIN_PREFER_ASM=0
      export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
      pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w740-return-elf-impl-e"
      rc=$?
      if [ "$had_prefer" = "1" ]; then
        export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
      else
        unset XLANG_PABI_THIN_PREFER_ASM
      fi
      if [ "$had_e_repl" = "1" ]; then
        export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
      else
        unset XLANG_PABI_THIN_ALLOW_E_REPLACE
      fi
      if [ "$rc" -eq 0 ]; then
        touch "$stamp_e"
        touch "$stamp_ban"
        log "pipeline_abi w740-return-elf-impl: LINUX -E replace (HARD BAN PREFER)"
      fi
      return "$rc"
      ;;
  esac
  touch "$stamp_e"
  touch "$stamp_ban"
  log "pipeline_abi w740-return-elf-impl: non-POSIX stamp-only (keep prior)"
  return 0
}

# wave316/341/380 M2: emit_ctx_sret Cap residual .x thin (was wave223 C thin).
# PRODUCT inject wave380 HARD BAN reinject both ends (Cap A class w380).
# G.7 match mega wave223 leave. PLATFORM: SHARED · BAN reinject both ends.
pipeline_abi_inject_emit_ctx_sret_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_emit_ctx_sret_thin.x"
  local stamp="src/.pabi_w380_emit_ctx_sret.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN reinject (do not call inject_thin_leaf).
  touch "$stamp"
  rm -f src/.pabi_w341_emit_ctx_sret.stamp
  return 0
}

# wave313/339/380 M2: typeck_active Cap residual .x thin (was wave224 C thin).
# PRODUCT inject wave380 HARD BAN reinject both ends: tip Darwin PREFER →
# BRANCH26; tip Ubuntu PREFER reinject → L2 SEGV. Keep prior overlays.
# G.7 match mega wave224 leave. PLATFORM: SHARED · BAN reinject both ends.
pipeline_abi_inject_typeck_active_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_typeck_active_thin.x"
  local stamp="src/.pabi_w380_typeck_active.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN reinject (do not call inject_thin_leaf).
  touch "$stamp"
  rm -f src/.pabi_w339_typeck_active.stamp
  return 0
}

# wave295/332/477/506 M2: glue_statics Cap residual .x thin (2 Cap bridge faces).
# PRODUCT inject: wave332 PREFER_ASM overlay kept; wave477 tip reinject HARD BAN
#   (L2 CG002 4/5). wave506: tipU re-heal (no-local re-call → tipU 6/6) but
#   tip PRODUCT PREFER still HARD BAN — stamp-only skip inject_thin_leaf.
# G.7 wave261 cold twins. PLATFORM: SHARED · BAN tip reinject.
pipeline_abi_inject_glue_statics_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_glue_statics_thin.x"
  local stamp="src/.pabi_w506_glue_statics.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # wave477/w506: HARD BAN tip product reinject (keep w332 PREFER overlay).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w332_glue_statics.stamp src/.pabi_w477_glue_statics.stamp
  log "pipeline_abi w506-glue-statics: tipU heal stamped; tip PRODUCT reinject HARD BAN (keep w332)"
  return 0
}

# wave303/358/491 M2: type_alias Cap residual C→.x (was wave262 C thin).
# wave491: tipU heal (no-local malloc → tipU 9/9) but tip PRODUCT reinject
#   HARD BAN — pure-asm reinject → L2 opt hang. Keep prior w358 overlay;
#   stamp w491 skip. T001 w303_* stay in .x.
# G.7 match mega wave262 leave. PLATFORM: SHARED · BAN tip reinject.
pipeline_abi_inject_type_alias_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_type_alias_thin.x"
  local stamp="src/.pabi_w491_type_alias.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # wave491 HARD BAN tip product reinject (opt hang @ tipU-complete PREFER).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w303_type_alias.stamp src/.pabi_w358_type_alias.stamp
  log "pipeline_abi w491-type-alias: tipU heal stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}

# wave310/377/390/527 M2: module_import Cap residual C→.x (was wave263 C thin).
# PRODUCT inject wave390 HARD BAN reinject both ends: stay prior overlay.
#   Prior: BAN PREFER (BRANCH26); MACOS -E / LINUX hard-skip (w377).
#   w390: formalize HARD BAN reinject (do not call inject_thin_leaf) —
#     tip reinject poison class; keep green Darwin -E / Ubuntu prior -E
#     via stamp only until BRANCH26 / Ubuntu typeck root.
# wave527 Soft Cap: tip XT001 heal (hoist ensure_* nested lets + pipe-cell
#   malloc); tipU 10/10; stamp → w527; tip PRODUCT reinject HARD BAN.
# G.7 match mega wave110/wave263 leave. PLATFORM: SHARED · BAN reinject.
pipeline_abi_inject_module_import_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_module_import_thin.x"
  local stamp="src/.pabi_w527_module_import.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN reinject (do not call inject_thin_leaf).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w310_module_import.stamp src/.pabi_w377_module_import.stamp \
    src/.pabi_w390_module_import.stamp
  log "pipeline_abi w527-module-import: tip XT001+tipU heal stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}

# wave306/360/360b/386/523 M2: module_enum Cap residual C→.x (was wave264 C thin).
# PRODUCT inject wave386 HARD BAN reinject both ends: stay prior overlay.
#   Prior: MACOS PREFER / LINUX -E (w360b; Ubuntu PREFER → si Result_i32).
#   w386: formalize HARD BAN reinject (do not call inject_thin_leaf) —
#     tip reinject poison class; keep green Darwin PREFER / Ubuntu -E via
#     stamp only until Result_i32 root.
# wave523 Soft Cap: tipU pipe-cell heal (malloc/dep_ctx/expr_* mid-call);
#   stamp → w523; tip PRODUCT reinject still HARD BAN (keep prior overlay).
# G.7 match mega wave264 leave. PLATFORM: SHARED · BAN reinject both ends.
pipeline_abi_inject_module_enum_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_module_enum_thin.x"
  local stamp="src/.pabi_w523_module_enum.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN reinject (do not call inject_thin_leaf).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w306_module_enum.stamp src/.pabi_w360_module_enum.stamp \
    src/.pabi_w360b_module_enum.stamp src/.pabi_w386_module_enum.stamp
  log "pipeline_abi w523-module-enum: tipU heal stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}

# wave305/359/359b/524 M2: top_level_let Cap residual C→.x (was wave265 C thin).
# PRODUCT inject wave359b HARD BAN: return 0 without overlay.
# wave359 PREFER (and -E re-inject of T001 thin) poisons Cap residual
# asm_codegen_elf_o / can break L2 si. T001 wrappers add new T syms so
# already_defined skip fails — must hard-skip. Stamp w359b.
# wave524 Soft Cap: tipU pipe-cell heal (malloc／hoist／sum mid-call);
#   stamp → w524; tip PRODUCT reinject still HARD BAN (keep prior overlay).
# PLATFORM: SHARED · both ends hard-skip until elf_o root.
pipeline_abi_inject_top_level_let_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_top_level_let_thin.x"
  local stamp="src/.pabi_w524_top_level_let.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN (do not call inject_thin_leaf).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w305_top_level_let.stamp src/.pabi_w359_top_level_let.stamp \
    src/.pabi_w359b_top_level_let.stamp
  log "pipeline_abi w524-top-level-let: tipU heal stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}

# wave307/362/518 M2: struct_layout Cap residual C→.x (was wave266 C thin).
# PRODUCT inject wave362 HARD BAN: return 0 without overlay.
# wave362 PREFER: gate type_alias -c green; Darwin L2 option exit 240.
# T001 w307_* stay in .x. Stamp w362.
# wave518: tipU 11/12→14/14 pipe-cell heal (mid malloc); stamp → w518;
#   tip PRODUCT reinject still HARD BAN (keep prior overlay).
# PLATFORM: SHARED · both ends hard-skip until product L2 root.
pipeline_abi_inject_struct_layout_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_struct_layout_thin.x"
  local stamp="src/.pabi_w518_struct_layout.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN (do not call inject_thin_leaf).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w307_struct_layout.stamp src/.pabi_w362_struct_layout.stamp
  log "pipeline_abi w518-struct-layout: tipU heal stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}

# wave304/361/430/490/595/604/617/747 M2: asm_locals Cap residual C→.x.
# wave490/595 walls (PRODUCT PREFER → L2 SEGV 0/5 both ends) were the w613
#   COMMON misclassification class: this thin's file-level let BSS cells
#   (Lxml_*, incl. the get/set slot tables) were pinned read-only __TEXT and
#   the compiler faulted writing its own locals state on every compile. The
#   w613 ctx-shndx authority fix emits them as proper commons (verified:
#   standalone -c all N_UNDF 2^4-aligned, T=27 UND=10) and w614–w616
#   dual-end L4 shipped it.
# wave617: product PREFER_ASM both ends (this TU zero host-cc). The w604
#   monolith keeps get+set in ONE TU (single BSS face; get peer stays
#   skip-stamped). Do not -E as a new repair.
# wave747: leftover from_x rebuild wipes PREFER while w617 stamps skip.
#   Re-PREFER when live asm_ctx_block_slot_get is Darwin nm -m weak /
#   LINUX nm -g W. Thin is nsects=1 + COMMON (inject_thin_leaf OK).
#   Do not gcc -E. Do not Darwin ld -r a two-segment thin.
# G.7: thin body matches mega wave267 leave.
# PLATFORM: SHARED · PREFER_ASM both ends; get peer stays merged (no split).
pipeline_abi_inject_asm_locals_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_asm_locals_thin.x"
  local stamp="src/.pabi_w604_asm_locals.stamp"
  local stamp_prefer="src/.pabi_w617_asm_locals_prefer.stamp"
  local get_x="src/runtime_pipeline_abi_asm_locals_get_thin.x"
  local get_stamp="src/.pabi_w595_asm_locals_get.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # w617: get peer stays merged in the monolith (w604 single-BSS rule).
  if [ -f "$get_x" ]; then
    touch "$get_stamp"
  fi
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ] && [ -f "$stamp_prefer" ]; then
    # w747: leftover from_x rebuild wipes PREFER but stamps still skip.
    # Re-inject when live get is leftover gcc Darwin weak / LINUX W.
    # PLATFORM: SHARED nm — Darwin `nm -m` "weak"; LINUX `nm -g` " W ".
    if ! nm -m "$o" 2>/dev/null | grep 'asm_ctx_block_slot_get$' | grep -q 'weak' \
      && ! nm -g "$o" 2>/dev/null | grep 'asm_ctx_block_slot_get$' | grep -q ' W '; then
      return 0
    fi
    log "pipeline_abi w747-asm-locals: live leftover gcc weak/W; re-PREFER"
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — product PREFER_ASM both ends (wave617, on the w613
  # COMMON fix + w614–w616 dual-end L4; wave747 leftover-wipe re-PREFER).
  # Do not gcc -E. Do not Darwin ld -r a two-segment thin. Do not PREFER
  # the isolated get peer (w595 BAN). Thin is nsects=1 + COMMON.
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w747-asm-locals-prefer"
  rc=$?
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    touch "$stamp_prefer"
    touch src/.pabi_w490_asm_locals.stamp
    touch src/.pabi_w747_asm_locals_prefer.stamp
    rm -f src/.pabi_w361_asm_locals.stamp src/.pabi_w304_asm_locals.stamp src/.pabi_w430_asm_locals.stamp
    log "pipeline_abi w747-asm-locals: PREFER_ASM replace (no host-cc for this TU)"
  fi
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  return "$rc"
}

# wave302/349/350/351 M2: block_tree Cap residual C→.x (was wave269 C thin).
# PRODUCT inject stamp w351: PREFER_ASM both ends (Cap A unlock).
#   w351: Ubuntu Cap A via -E emit_index (PREFER pure-asm broke option);
#   block_tree PREFER product inject L2 5/5 both ends.
# wave497: tipU heal (no-local pipe cells); stamp → w497.
#   LINUX: PREFER_ASM (tipU_o 23/23; L2 5/5＠6453912).
#   MACOS: HARD BAN tip reinject — tip PREFER / -E tip .o → ARM64_RELOC_BRANCH26
#     at pure-ld (r_address=0x11C); keep prior w496 overlay.
# G.7 match mega wave269 leave. PLATFORM: SHARED · MACOS hard-skip / LINUX PREFER.
# Note: wave268 sizing already via slot_bytes_thin.x + NL-04 seed (no C redo).
pipeline_abi_inject_block_tree_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_block_tree_thin.x"
  local stamp="src/.pabi_w497_block_tree.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: MACOS — HARD BAN tip reinject (BRANCH26 @w497 tip PREFER/-E tip .o).
  if [ "$(uname -s)" != "Linux" ]; then
    touch "$stamp"
    rm -f src/.pabi_w351_block_tree.stamp
    return 0
  fi
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: LINUX — PREFER_ASM (w497 tipU heal; L2 green).
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w497-block-tree"
  rc=$?
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
  fi
  return "$rc"
}

# wave337–344 M2 Cap leaf PREFER_ASM inventory:
#   DONE PREFER (SHARED): w331 typeck_orch / w332 glue_statics /
#     w333 preprocess_malloc / w334 lifecycle / w336 ast_forwarders.
#   DONE PREFER (LINUX gold only, Darwin -E):
#     w339 typeck_active · w340 emit_ctx_module_dep · w341 emit_ctx_sret ·
#     w342 emit_ctx_bss (small Cap A; w344 .data bake for non-zero imm).
#   BAN product PREFER (stay -E+$CC until root fix):
#     A typeck_check_expr Ubuntu (XT001 expected i32/found i32; Darwin PREFER
#       w348 OK). w352 probe: x86_64 pure-asm check_expr_c frame ~0x998 +
#       cltq arg home — stay LINUX -E until ABI root.
#   UNLOCKED w350: block_tree PREFER (Cap A let-array INDEX).
#   UNLOCKED w352: read_file_x_view PREFER (class B local u8[32] FileView).
#   UNLOCKED w353: asm_label_format PREFER (digit-loop into caller buf).
#   UNLOCKED w487: import_heap peer-flat tip PREFER (resolve/read_prep/parse+gate).
#   UNLOCKED w355: codegen_outbuf PREFER (T001 unsafe + u8[64] float buf).
#   UNLOCKED w356: grow_vec PREFER (T001 unsafe LE helpers · class C GrowVec-LE).
#   UNLOCKED w357b: type_pool Darwin PREFER / Ubuntu -E (class C Type LE).
#   UNLOCKED w358: type_alias PREFER both ends (T001 w303_* · file-local maps).
#   BAN w359 PREFER top_level_let: L2 green but pure-asm overlay poisons
#     subsequent Cap residual asm_codegen_elf_o (type_alias -c CG002) →
#     w359b stay -E both ends (T001 w305_* kept).
#   UNLOCKED w360b: module_enum Darwin PREFER / Ubuntu -E (si Result_i32).
#   BAN w359b: top_level_let hard-skip overlay (elf_o / L2 poison).
#   BAN w361: asm_locals hard-skip (PREFER L2 opt/si SEGV; gate -c green).
#   BAN w362: struct_layout hard-skip (PREFER L2 option=240; gate -c green).
#   UNLOCKED w363b: module_func Darwin PREFER / Ubuntu -E (undef main).
#   UNLOCKED w364: block_domain PREFER both ends (T001 w326_* · gate+L2).
#   UNLOCKED w365: expr_sidecar PREFER both ends (T001 w327_* · gate+L2).
#   UNLOCKED w366: sidecar_pool PREFER both ends (T001 w308_* · gate+L2).
#   wave504: tipU heal inventory (init peers) + HARD BAN tip PRODUCT reinject
#     (L2 SEGV 0/5; keep w366 leftover). Main tip still file-tail incomplete.
#   BAN w367: dep_ctx PREFER (gate type_alias -c绿; L2 opt/si/hello XT001
#     no-impl method) — hard-skip; stay prior -E.
#   BAN w382 reinject: elf_ctx tip Darwin BRANCH26 / Ubuntu PREFER SEGV —
#     hard-skip both ends; keep prior MACOS PREFER / LINUX -E (w368b).
#   BAN w369: asm_wpo PREFER (ARM64_RELOC_BRANCH26 on non-b/bl in thin;
#     g05 pure-ld fail) — hard-skip; stay prior -E.
#   BAN w370: macho_write PREFER (ARM64_RELOC_BRANCH26 on non-b/bl in thin;
#     g05 pure-ld fail) — hard-skip; stay prior -E; T001 w314_* kept.
#   UNLOCKED w371/371b: mega_body Darwin PREFER／Ubuntu hard-skip stay prior -E
#     (Ubuntu XT001 w328_store_ptr · Type LE face; cannot -E reinject).
#   BAN historic/w379: onefunc PREFER (w335 SEGV; w379 XP001 parse) — hard-skip;
#     T001 w325_* kept.
#     B residual local fixed arrays
#       (bootstrap_glue u8[1024] scope sidecar — pure-asm XP001 both ends;
#        parse_orch / parser_result / value_abi sret).
#     C residual GrowVec/sidecar LE peers still -E:
#       onefunc (BAN PREFER w379) / dep_ctx (BAN PREFER) / asm_wpo (BAN PREFER) /
#       macho_write (BAN PREFER) / top_level_let / asm_locals / struct_layout
#       (BAN).
# wave338: modlet scalar COMMON root (NEG-over-LIT + null TYPE_PTR).
# wave339–342: Cap A emit_ctx + typeck_active OK.
# wave344: non-zero scalar imm → .data bake (library TU).
# wave345: MODLET_IN_REST prepare 入链.
# wave346: check_expr ordinal let→const.
# wave347: pure-asm call-arg i32 VAR lea root of PREFER XT001; scalar use_lea guard.
# wave348/375: for_call_args rvalue; wave375 PREFER both ends (was -E).
# wave588: for_call_args tipU 68/68 + PRODUCT BAN (Ubuntu original empty .o).
# wave589: reent_deep_copy tipU 36/36 + PRODUCT BAN (Ubuntu original empty .o).
# wave375 BAN: parser_result PREFER (LexerResult.next_lex size under pure-asm).
# wave349: block_tree T001 unsafe wrap.
# wave351: Cap A emit_index (Darwin PREFER / Ubuntu -E) + block_tree PREFER both.
# wave378: emit_index Ubuntu PREFER reconfirm BAN (option=240); value_abi BAN PREFER
#   formal (sret ABI · stamp w378 · -E both ends).
# wave352: read_file_x_view PREFER (class B FileView); Ubuntu check_expr stay -E.
# wave379: onefunc HARD BAN PREFER (XP001 parse reconfirm); check_expr HARD BAN
#   reinject both ends (Ubuntu XT001; Darwin BRANCH26) — prior overlays kept.
# wave353: asm_label_format PREFER (digit-loop); historic w294 SEGV ban lifted.
# wave487: import_heap peer-flat tip PREFER (resolve/read_prep/parse+gate).
# wave355: codegen_outbuf PREFER (T001 unsafe pipe_store + float buf).
# wave356: grow_vec PREFER (T001 unsafe LE helpers).
# wave357/357b/372/372b: type_pool Darwin PREFER / Ubuntu -E (option T001 reconfirmed).
# wave358: type_alias PREFER both ends (T001 w303_* · file-local maps).
# wave360/360b: module_enum Darwin PREFER / Ubuntu -E (si Result_i32).
# wave359b: top_level_let hard-skip (overlay poison).
# wave361: asm_locals hard-skip (PREFER L2 opt/si SEGV; gate -c green).
# wave363/363b: module_func Darwin PREFER / Ubuntu -E (undef main).
# wave364: block_domain PREFER both ends (T001 w326_* · gate+L2).
# wave365: expr_sidecar PREFER both ends (T001 w327_* · gate+L2).
# wave366: sidecar_pool PREFER both ends (T001 w308_* · gate+L2).
# wave367/367b: dep_ctx T001 try + BAN PREFER (L2 opt/si/hello XT001).
# wave368/368b: elf_ctx Darwin PREFER / Ubuntu -E (elf patch offset=-1).
# wave369/369b: asm_wpo T001 w311_* + BAN PREFER (ARM64_RELOC_BRANCH26).
# wave370/370b: macho_write T001 w314_* + BAN PREFER (ARM64_RELOC_BRANCH26).
# wave371/371b: mega_body Darwin PREFER / Ubuntu hard-skip (XT001 store_ptr).
# wave372/372b/383: type_pool PREFER both ends (w383 Ubuntu unlock).
# wave378: value_abi BAN PREFER (sret) + emit_index Ubuntu PREFER BAN reconfirm.
# wave379: onefunc HARD BAN PREFER + check_expr HARD BAN reinject (prior overlays).
# wave380: Cap A HARD BAN reinject both ends (Darwin BRANCH26; Ubuntu SEGV);
#   keep prior overlays (was LINUX PREFER / DARWIN -E).
# wave381: parser_result HARD BAN reinject both ends (tip T001 next_lex /
#   Ubuntu PREFER XT001; keep prior -E overlay).
# wave382: elf_ctx HARD BAN reinject both ends (Darwin BRANCH26; Ubuntu SEGV).
# wave383: type_pool PREFER both ends (Ubuntu tip unlock; option=102).
# wave383b: HARD BAN tip force-reinject after green (Ubuntu 3rd tip
#   reinject → option T001; heal prefer_green overlay). Stamp-only.
# wave384: value_abi HARD BAN reinject both ends (sret; stay prior -E).
# wave385: module_func HARD BAN reinject both ends (keep Darwin PREFER /
#   Ubuntu -E; undef-main root).
# wave386: module_enum HARD BAN reinject both ends (keep Darwin PREFER /
#   Ubuntu -E; Result_i32 root).
# wave387: emit_index HARD BAN reinject both ends (keep Darwin PREFER /
#   Ubuntu -E; option=240 root).
# wave388: parse_orch HARD BAN reinject both ends (keep Darwin PREFER /
#   Ubuntu hard-skip; ParseIntoResult/typeck root).
# wave389: mega_body HARD BAN reinject both ends (keep Darwin PREFER /
#   Ubuntu hard-skip; Type LE / fn#116 root).
# wave390: module_import HARD BAN reinject both ends (keep Darwin -E /
#   Ubuntu hard-skip; BRANCH26 root).
# wave391: bootstrap_glue HARD BAN reinject both ends (keep Darwin -E /
#   Ubuntu hard-skip; BRANCH26 root).
# wave392: Type LE residual ROOT MAP (no product unlock yet):
#   Ubuntu tip -c mega_body thin → XT001 @ w328_store_ptr (fn#116) is
#   MISATTRIBUTED. Bisect: drop last export (mega LOOP) → -c green with
#   store_ptr intact; helpers-only (≤61 funcs) green; full 62-fn file red.
#   Darwin -c full file green. Root = LINUX typeck/arena pressure on
#   helpers+LOOP combined — next = split LOOP leaf (hand), then unlock try.
# wave393/393b/393c/393d: mega LOOP split leaf landed (helpers vs loop).
# wave394: CG002 root = emit_one+mega co-file; third leaf emit_one_thin;
#   Ubuntu+Darwin -c all three green → unlock three-leaf PREFER inject.
# wave396: wpo_dump PREFER both ends (-c green; type_alias -c gate OK).
# wave397/412: type_to_c_repr MACOS full PREFER／LINUX helpers PREFER
#   (Ubuntu full XT001 misattr; main leaf tip still BAN).
# wave398: unused_hints PREFER both ends (-c green both ends).
# wave399: fnptr_array_esz PREFER both ends (-c green both ends).
# wave400/415: slot_bytes MACOS full PREFER／LINUX helpers PREFER (asm_local tip BAN).
# wave590: LINUX helpers HARD BAN tip PRODUCT reinject (keep w415 overlay).
# wave401/414: field_load_sz MACOS full PREFER／LINUX helpers PREFER (main tip BAN).
# wave402: param_ptr_slot MACOS PREFER／LINUX BAN (Ubuntu CG002 elf patch).
# wave432: param_ptr_slot BOTH PREFER (helper extract; Ubuntu -E/CG002 healed).
# wave403/413/416/420/421: assign MACOS full PREFER／LINUX helpers+pair/body PREFER (middle BAN).
# wave404: binop_var_slot_cache HARD BAN tip reinject both ends (BRANCH26/SEGV).
# wave405: binop_stack_spill_try_reload PREFER both ends.
# wave406: w157_sum HARD BAN tip reinject both ends (Darwin BRANCH26).
# wave407/417/422/423: binop_block_peel MACOS full PREFER／LINUX helpers+may_clobber+load_to_rbx PREFER (load/index BAN).
# wave408/418: fixed_array_copy MACOS full PREFER／LINUX helpers PREFER (rest BAN).
# wave409/419: asm_expr MACOS full PREFER／LINUX HARD BAN (helpers product opt=255); wave409b al_nc HARD BAN.
# wave410: asm73_* HARD BAN (BRANCH26); wave410d reent PREFER both ends.
# wave492: call_method_wrappers tipU heal + BOTH PREFER (was soft -E stub @w411).
# wave412: type_to_c_repr LINUX helpers PREFER (main tip still BAN).
# wave413/416/420/421: assign LINUX helpers+pair/body PREFER (middle BAN).
# wave414: field_load_sz LINUX helpers PREFER (main tip still BAN).
# wave415: slot_bytes LINUX helpers PREFER (asm_local tip still BAN).
# wave590: LINUX helpers HARD BAN (Ubuntu UND=1 kind_ord only; Darwin 22/22).
# wave421: assign LINUX helpers+pair/body PREFER (middle BAN).
# wave417: binop_block_peel LINUX helpers PREFER (rest tip BAN).
# wave418: fixed_array_copy LINUX helpers PREFER (rest tip BAN).
# wave419: asm_expr LINUX helpers PREFER (emit_expr_elf_c tip BAN).
# wave432: param_ptr_slot BOTH PREFER (helper extract; Ubuntu -E/CG002 healed).
# wave433: field_load LINUX layout+main PREFER (nested byte-while → copy+bytes_eq).
# wave434: type_to_c_repr LINUX named+array_slice+main PREFER (co-file XT001 split).
# wave435: peel index_addr LINUX ko47+walker PREFER (INDEX co-file XT001 split).
# wave479: peel index_addr LINUX ko47+walker peer-flat no-local PREFER (tip U heal).
# wave436: peel load_operand LINUX flat peer chain PREFER (nested-if asm ban).
# wave437: assign rhsrax LINUX flat helpers PREFER (emit_assign still BAN).
# wave438: arr_lit_flat BOTH flat peer chain PREFER.
# wave568: repark HARD BAN tip PRODUCT reinject (keep w438 overlay).
# wave569: one_cell HARD BAN tip PRODUCT reinject (keep w438 overlay).
# wave570: cells HARD BAN tip PRODUCT reinject (keep w438 overlay).
# wave571: one_row HARD BAN tip PRODUCT reinject (keep w438 overlay).
# wave572: rows HARD BAN tip PRODUCT reinject (keep w438 overlay).
# wave573: struct HARD BAN tip PRODUCT reinject (keep w438 overlay).
# wave574: one_scalar HARD BAN tip PRODUCT reinject (keep w438 overlay).
# wave575: step HARD BAN tip PRODUCT reinject (keep w438 overlay).
# wave576: scalar HARD BAN tip PRODUCT reinject (keep w438 overlay).
# wave577: main HARD BAN tip PRODUCT reinject (keep w438 overlay).
# wave439: arr_return BOTH flat peer chain PREFER.
# wave510: b0/c HARD BAN tip PRODUCT reinject (keep w439 overlay).
# wave560: a0 HARD BAN tip PRODUCT reinject (keep w439 overlay).
# wave578: a HARD BAN tip PRODUCT reinject (keep w439 overlay).
# wave579: a2 HARD BAN tip PRODUCT reinject (keep w439 overlay).
# wave580: b0_prep HARD BAN tip PRODUCT reinject (keep w439 overlay).
# wave581: b0_durable HARD BAN tip PRODUCT reinject (keep w439 overlay).
# wave582: b HARD BAN tip PRODUCT reinject (keep w439 overlay).
# wave583: c_dest_array HARD BAN tip PRODUCT reinject (keep w439 overlay).
# wave584: c_slice HARD BAN tip PRODUCT reinject (keep w439 overlay).
# wave585: c_fallback HARD BAN tip PRODUCT reinject (keep w439 overlay).
# wave586: d HARD BAN tip PRODUCT reinject (keep w439 overlay).
# wave587: main HARD BAN tip PRODUCT reinject (keep w439 overlay).
# wave440: arr_struct_lit MACOS peer PREFER / LINUX tip BAN (opt=94).
# wave441: assign emit LINUX -E peer chain PREFER (pure-asm CG002/SEGV).
# wave442: arr_struct_lit LINUX -E peer PREFER (call heal; pure-asm residual).
# wave443: mega helpers LINUX -E PREFER (+emit_one); loop tip BAN.
# wave444: mega loop LINUX HARD BAN (-E EM:0 / pure-asm SEGV 139).
# wave453: loop BSS+pipe_elf_off+no-local tip→code_len=0; -E→BLD001. BAN.
# Next: arr_struct_lit main (Ubuntu UND=1 vs Darwin 13; already BAN PREFER overlay).
#   Remaining PREFER copy／resolve_call U-complete, do not BAN. 禁 un-BAN arrlit＋main.


# PLATFORM: SHARED shell · MACOS + LINUX gold.

# wave301/357/357b/372/372b/373/383/383b/515 M2: type_pool Cap residual C→.x
#   (was wave270 C thin).
# PRODUCT inject wave383: PREFER_ASM both ends (first-wins / missing stamp).
#   w372b/373: MACOS PREFER / LINUX -E (option T001 / non-i32 params root).
#   w383: Ubuntu tip PREFER L2 5/5 (option=102); Darwin tip reinject green.
#   w383b: Ubuntu tip force-reinject flaky (3rd → T001) — HARD BAN delete-
#     stamp / tip reinject after green; keep PREFER overlay via stamp.
#   w395: Ubuntu opt=134 after tip mega poison — heal by restoring
#     /tmp/w383_pabi_u_prefer_green.o (2675520) + FULL=0 g05; keep stamp;
#     do NOT tip-reinject type_pool (w383b BAN). Dual L2 5/5.
# wave515: tipU 2/5→7/7 pipe-cell heal (mid type_ptr/alloc/num_types);
#   stamp → w515; tip force-reinject still HARD BAN (keep PREFER overlay).
# G.7 LE name_len@260. PLATFORM: SHARED · PREFER both ends · BAN force tip.
pipeline_abi_inject_type_pool_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_type_pool_thin.x"
  local stamp="src/.pabi_w515_type_pool.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — w383b/515 HARD BAN tip force-reinject: if stamp exists,
  # skip even when thin.x is newer (git pull mtime must not reinject; Ubuntu
  # 3rd tip reinject → option T001). Delete stamp only to re-try (banned).
  if [ -f "$stamp" ]; then
    return 0
  fi
  # Migrate w383 → w515 without reinject (tipU heal inventory only).
  if [ -f src/.pabi_w383_type_pool.stamp ]; then
    touch "$stamp"
    rm -f src/.pabi_w383_type_pool.stamp
    log "pipeline_abi w515-type-pool: tipU heal stamped; tip force-reinject HARD BAN (keep PREFER overlay)"
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — PREFER_ASM both ends (w383 Ubuntu unlock; first-wins).
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w515-type-pool"
  rc=$?
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    rm -f src/.pabi_w301_type_pool.stamp src/.pabi_w357_type_pool.stamp \
      src/.pabi_w372_type_pool.stamp src/.pabi_w372b_type_pool.stamp \
      src/.pabi_w383_type_pool.stamp
  fi
  return "$rc"
}

# wave300/356/489/597 M2: grow_vec Cap residual C→.x (was wave271 C thin).
# wave489: tipU heal (no-local mmap/realloc → tipU 15/15) but tip PRODUCT
#   PREFER HARD BAN — pure-asm inject → L2 BLD001 undefined `main`.
# wave597: LINUX prior overlay has grow_vec T but ZERO realloc/mmap/calloc
#   UND → arena stuck at INIT_CAP=256 → parse_skip file-tail (asm_locals
#   set/get after pipeline_asm_local_offset_c). Healed thin standalone -c
#   is U-complete. Do not retry PREFER. LINUX -E replace leftover T.
#   MACOS keep prior (live UND realloc/mmap/calloc). Stamp w597.
# PLATFORM: LINUX gold -E replace · MACOS keep prior · SHARED shell.
pipeline_abi_inject_grow_vec_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_grow_vec_thin.x"
  local stamp="src/.pabi_w489_grow_vec.stamp"
  local stamp_e="src/.pabi_w597_grow_vec.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  case "$(uname -s)" in
    Darwin)
      # PLATFORM: MACOS — live grow_vec already UND realloc/mmap/calloc.
      # Keep prior overlay; HARD BAN PREFER (w489 BLD001).
      if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
        return 0
      fi
      touch "$stamp"
      touch "$stamp_e"
      rm -f src/.pabi_w300_grow_vec.stamp src/.pabi_w356_grow_vec.stamp
      log "pipeline_abi w597-grow-vec: MACOS keep prior (realloc live); HARD BAN PREFER"
      return 0
      ;;
    Linux)
      # PLATFORM: LINUX — restore realloc/mmap via -E replace of starved prior.
      if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ]; then
        return 0
      fi
      local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
      local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
      local had_prefer=0 had_e_repl=0 rc=0
      if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
      if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
      unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1  # wave621: stale-era smash wall re-verified
      export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
      pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w597-grow-vec-e"
      rc=$?
      if [ "$had_prefer" = "1" ]; then
        export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
      else
        unset XLANG_PABI_THIN_PREFER_ASM
      fi
      if [ "$had_e_repl" = "1" ]; then
        export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
      else
        unset XLANG_PABI_THIN_ALLOW_E_REPLACE
      fi
      if [ "$rc" -eq 0 ]; then
        touch "$stamp"
        touch "$stamp_e"
        rm -f src/.pabi_w300_grow_vec.stamp src/.pabi_w356_grow_vec.stamp
        log "pipeline_abi w597-grow-vec: LINUX -E replace (restore realloc/mmap)"
      fi
      return "$rc"
      ;;
  esac
  # PLATFORM: WINDOWS / other — stamp only; leftover PE cannot -E.
  touch "$stamp"
  touch "$stamp_e"
  log "pipeline_abi w597-grow-vec: non-POSIX stamp-only (keep prior)"
  return 0
}

# wave598: DEREF scalar leftover PREFER smashes caller frame on
# `unsafe { *p = 1 }` (gate/peel epilogue rbp=1). LINUX -E replace of
# leftover T with the pipe-cell emit body. HARD BAN PREFER (w534).
# MACOS keep Darwin overlay (already green). PLATFORM: LINUX gold.
pipeline_abi_inject_deref_scalar_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_assign_deref_scalar_thin.x"
  local stamp="src/.pabi_w534_assign_deref_scalar.stamp"
  local stamp_e="src/.pabi_w598_deref_scalar.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  case "$(uname -s)" in
    Darwin)
      # PLATFORM: MACOS — overlay scalar already compiles `*p=`.
      if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ]; then
        return 0
      fi
      touch "$stamp"
      touch "$stamp_e"
      log "pipeline_abi w598-deref-scalar: MACOS keep prior overlay; HARD BAN PREFER"
      return 0
      ;;
    Linux)
      # PLATFORM: LINUX — -E replace smash leftover PREFER T.
      if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ]; then
        return 0
      fi
      local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
      local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
      local had_prefer=0 had_e_repl=0 rc=0
      if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
      if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
      unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1  # wave621: stale-era smash wall re-verified
      export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
      pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w598-deref-scalar-e"
      rc=$?
      if [ "$had_prefer" = "1" ]; then
        export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
      else
        unset XLANG_PABI_THIN_PREFER_ASM
      fi
      if [ "$had_e_repl" = "1" ]; then
        export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
      else
        unset XLANG_PABI_THIN_ALLOW_E_REPLACE
      fi
      if [ "$rc" -eq 0 ]; then
        touch "$stamp"
        touch "$stamp_e"
        rm -f src/.pabi_w445_assign_deref_scalar.stamp \
          src/.pabi_w449_heal_deref_scalar.stamp
        log "pipeline_abi w598-deref-scalar: LINUX -E replace (smash leftover T)"
      fi
      return "$rc"
      ;;
  esac
  touch "$stamp"
  touch "$stamp_e"
  log "pipeline_abi w598-deref-scalar: non-POSIX stamp-only (keep prior)"
  return 0
}

# wave599: leftover PREFER glue_emit_assign_rhs_to_rax_elf_c smashes
# the caller (w598 -E scalar). objdump: `sub $0x1158,%rsp`, no endbr64.
# Ubuntu `unsafe { *p = 1 }` then CG002 because pipe_load after the
# smash sees -1 (rhs_elf itself returned 0). LINUX -E replace leftover
# T with the no-local dispatcher thin. HARD BAN PREFER (w454).
# MACOS keep Darwin overlay (already compiles `*p=`).
# PLATFORM: LINUX gold.
pipeline_abi_inject_rhsrax_to_rax_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_assign_rhsrax_to_rax_thin.x"
  local stamp="src/.pabi_w454_assign_rhsrax_to_rax.stamp"
  local stamp_e="src/.pabi_w599_rhsrax_to_rax.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  case "$(uname -s)" in
    Darwin)
      # PLATFORM: MACOS — overlay already compiles `*p=`.
      if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ]; then
        return 0
      fi
      touch "$stamp"
      touch "$stamp_e"
      log "pipeline_abi w599-rhsrax-to-rax: MACOS keep prior overlay; HARD BAN PREFER"
      return 0
      ;;
    Linux)
      # PLATFORM: LINUX — -E replace smash leftover PREFER T.
      if [ -f "$stamp_e" ] && [ ! "$thin_x" -nt "$stamp_e" ]; then
        return 0
      fi
      local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
      local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
      local had_prefer=0 had_e_repl=0 rc=0
      if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
      if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
      unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1  # wave621: stale-era smash wall re-verified
      export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
      pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w599-rhsrax-to-rax-e"
      rc=$?
      if [ "$had_prefer" = "1" ]; then
        export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
      else
        unset XLANG_PABI_THIN_PREFER_ASM
      fi
      if [ "$had_e_repl" = "1" ]; then
        export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
      else
        unset XLANG_PABI_THIN_ALLOW_E_REPLACE
      fi
      if [ "$rc" -eq 0 ]; then
        touch "$stamp"
        touch "$stamp_e"
        log "pipeline_abi w599-rhsrax-to-rax: LINUX -E replace (smash leftover T)"
      fi
      return "$rc"
      ;;
  esac
  touch "$stamp"
  touch "$stamp_e"
  log "pipeline_abi w599-rhsrax-to-rax: non-POSIX stamp-only (keep prior)"
  return 0
}

# wave600/620 M2: glue_emit_assign_var_elf_c 7-leaf family.
# wave600 walls ("leftover PREFER smashes the caller, huge frame, di store
#   never lands") were the stale warm-composition era — probe w620 on the
#   w613–w619 dual-L4 chain: all 7 leaves PREFER'd, Ubuntu w600 repro
#   (di=1 / while(di<n){di++}) = 3, nested-while inner-lets = 63,
#   if-in-while = 4, L2 5/5. MACOS already ran the PREFER overlay.
# wave620: product PREFER_ASM both ends (7 leaves, one w620 prefer stamp).
#   Do not -E as a new repair.
# PLATFORM: SHARED · PREFER_ASM both ends.
pipeline_abi_inject_assign_var_thin() {
  local o="$1"
  local stamp_e="src/.pabi_w600_assign_var.stamp"
  local stamp_prefer="src/.pabi_w620_assign_var_prefer.stamp"
  local gate_x="src/runtime_pipeline_abi_assign_var_thin.x"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  local _px _ps _need=0
  [ -s "$o" ] && [ -f "$gate_x" ] || return 0
  if [ -f "$stamp_e" ] && [ ! "$gate_x" -nt "$stamp_e" ] && [ -f "$stamp_prefer" ]; then
    return 0
  fi
  for _pair in \
    "src/runtime_pipeline_abi_assign_var_thin.x|.pabi_w473_heal_var.stamp" \
    "src/runtime_pipeline_abi_assign_var_try_let_thin.x|.pabi_w473_heal_var_try_let.stamp" \
    "src/runtime_pipeline_abi_assign_var_finish_thin.x|.pabi_w473_heal_var_finish.stamp" \
    "src/runtime_pipeline_abi_assign_var_store_thin.x|.pabi_w473_heal_var_store.stamp" \
    "src/runtime_pipeline_abi_assign_var_store_pair_thin.x|.pabi_w473_heal_var_store_pair.stamp" \
    "src/runtime_pipeline_abi_assign_var_store_f32_thin.x|.pabi_w473_heal_var_store_f32.stamp" \
    "src/runtime_pipeline_abi_assign_var_store_slice_thin.x|.pabi_w473_heal_var_store_slice.stamp"
  do
    _px="${_pair%%|*}"
    _ps="src/${_pair##*|}"
    if [ -f "$_px" ] && { [ ! -f "$stamp_e" ] || [ "$_px" -nt "$stamp_e" ] || [ ! -f "$_ps" ]; }; then
      _need=1
      break
    fi
  done
  if [ "$_need" != "1" ] && [ -f "$stamp_prefer" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then had_newer=1; fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  rc=0
  for _pair in \
    "src/runtime_pipeline_abi_assign_var_store_slice_thin.x|.pabi_w473_heal_var_store_slice.stamp" \
    "src/runtime_pipeline_abi_assign_var_store_f32_thin.x|.pabi_w473_heal_var_store_f32.stamp" \
    "src/runtime_pipeline_abi_assign_var_store_pair_thin.x|.pabi_w473_heal_var_store_pair.stamp" \
    "src/runtime_pipeline_abi_assign_var_store_thin.x|.pabi_w473_heal_var_store.stamp" \
    "src/runtime_pipeline_abi_assign_var_finish_thin.x|.pabi_w473_heal_var_finish.stamp" \
    "src/runtime_pipeline_abi_assign_var_try_let_thin.x|.pabi_w473_heal_var_try_let.stamp" \
    "src/runtime_pipeline_abi_assign_var_thin.x|.pabi_w473_heal_var.stamp"
  do
    _px="${_pair%%|*}"
    _ps="src/${_pair##*|}"
    if [ -f "$_px" ]; then
      pipeline_abi_inject_thin_leaf "$o" "$_px" "w620-assign-var-prefer" || { rc=$?; break; }
      touch "$_ps"
    fi
  done
  if [ "$had_newer" = "1" ]; then export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"; fi
  if [ "$had_prefer" = "1" ]; then export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"; else unset XLANG_PABI_THIN_PREFER_ASM; fi
  if [ "$had_e_repl" = "1" ]; then export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"; else unset XLANG_PABI_THIN_ALLOW_E_REPLACE; fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp_e"
    touch "$stamp_prefer"
    log "pipeline_abi w620-assign-var: PREFER_ASM replace 7 leaves (no host-cc for this family)"
  fi
  return "$rc"
}

# wave309/367/367b/528 M2: dep_ctx Cap residual C→.x (was wave272 C thin).
# PRODUCT inject wave367b HARD BAN PREFER: stay prior -E overlay; do not
# re-overlay. Prior PREFER/T001 tries broke L2. Stamp w367b.
# wave528 Soft Cap: tip T001 heal (w528_* unsafe/pipe-cell wrappers) +
#   tipU 18/18; stamp → w528; tip PRODUCT reinject HARD BAN (keep prior).
# PLATFORM: SHARED · both ends hard-skip until product L2 root.
pipeline_abi_inject_dep_ctx_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_dep_ctx_thin.x"
  local stamp="src/.pabi_w528_dep_ctx.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN PREFER (do not call inject_thin_leaf).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w309_dep_ctx.stamp src/.pabi_w367_dep_ctx.stamp \
    src/.pabi_w367b_dep_ctx.stamp
  log "pipeline_abi w528-dep-ctx: tip T001+tipU heal stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}

# wave312/368b/382 M2: elf_ctx Cap residual C→.x (was wave273 C thin).
# PRODUCT inject wave382 HARD BAN reinject both ends: stay prior overlay.
#   Prior: MACOS PREFER / LINUX -E (w368b).
#   w382 probe: Ubuntu tip PREFER once looked L2 green then tip reinject
#     SEGV all probes; Darwin tip PREFER reinject → BRANCH26.
#   Stamp only until reloc/elf-patch root. G.7 match mega ELF leave.
# PLATFORM: SHARED · BAN reinject both ends.
pipeline_abi_inject_elf_ctx_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_elf_ctx_thin.x"
  local stamp="src/.pabi_w382_elf_ctx.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN reinject (do not call inject_thin_leaf).
  touch "$stamp"
  rm -f src/.pabi_w312_elf_ctx.stamp src/.pabi_w368_elf_ctx.stamp
  return 0
}

# wave311/369b M2: asm_wpo Cap residual C→.x (was wave274 C thin).
# wave745 product PREFER: g05 prepends src/runtime_pipeline_abi_asm_wpo_thin.o
# (const_lit sidecar must already be live). Cap sidecar is fallback only.
pipeline_abi_inject_asm_wpo_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_asm_wpo_thin.x"
  local thin_o="src/runtime_pipeline_abi_asm_wpo_thin.o"
  local stamp="src/.pabi_w745_asm_wpo_thin_prefer.stamp"
  local xlang
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  rm -f src/.pabi_w369b_asm_wpo.stamp src/.pabi_w311_asm_wpo.stamp src/.pabi_w369_asm_wpo.stamp
  if [ -f "$stamp" ] && [ -s "$thin_o" ] \
    && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  xlang="$(pwd)/xlang_asm"
  [ -x "$xlang" ] || xlang="$(pwd)/xlang"
  [ -x "$xlang" ] || {
    log "pipeline_abi w745-asm-wpo-thin: no xlang to -c thin"
    return 0
  }
  # Skip compile until const_lit sidecar is linked into xlang.
  # Leftover gcc (Darwin weak / LINUX W) folds mutable let init → smash at().
  # const_lit.o newer than xlang means this inject pass has not g05'd yet.
  # PLATFORM: SHARED — first g05 after pull keeps cap until this heals.
  if [ -s src/runtime_pipeline_abi_const_lit.o ] \
      && [ src/runtime_pipeline_abi_const_lit.o -nt "$xlang" ]; then
    log "pipeline_abi w745-asm-wpo-thin: skip -c until const_lit sidecar linked"
    return 0
  fi
  if nm -m "$xlang" 2>/dev/null | grep 'asm_module_top_level_const_lit_i32$' \
      | grep -q 'weak'; then
    log "pipeline_abi w745-asm-wpo-thin: skip -c until const_lit sidecar live"
    return 0
  fi
  if nm -g "$xlang" 2>/dev/null | grep 'asm_module_top_level_const_lit_i32$' \
      | grep -q ' W '; then
    log "pipeline_abi w745-asm-wpo-thin: skip -c until const_lit sidecar live"
    return 0
  fi
  if ! "$xlang" -backend asm -c "$thin_x" -o "$thin_o"; then
    log "pipeline_abi w745-asm-wpo-thin: PREFER -c failed"
    return 1
  fi
  touch "$stamp"
  log "pipeline_abi w745-asm-wpo-thin: PREFER_ASM sidecar (g05 prepend, no ld -r)"
  return 0
}

# wave742 M2: live WPO cap FUNCS 4096 / EDGES 16384 leftover-gcc sidecar.
# wave741 classified dummy pad≥2048 T=2048 (aliases missing, parse skips=0)
# as emit-order cap, not parser skip; source already 4096.
# Live leftover is host-cc of the .x leave (g_aw_* 2048, Darwin weak T /
# Ubuntu W). FROM_X rest skips WAVE274; whole from_x type-conflicts;
# PREFER asm_wpo_thin stays HARD BAN (Darwin Lxml COMMON BRANCH26 +
# ld -r → libtool n_sect=2 on _Lxml_eeba97b0edf5c0f6, w369b).
# Overlay: host-cc seeds/runtime_pipeline_abi_asm_wpo_overlay.c (complete
# product-pool structs + leftover C twin using global accessors) →
# src/runtime_pipeline_abi_asm_wpo_cap.o, g05 first-wins over leftover
# weak. Do not Darwin ld -r merge into pabi. Do not PREFER the thin.
# Do not gcc -E of .x as the repair. Do not redefine leftover T (w647:
# rename redirects pabi's own callers onto the dead 2048 body).
# PLATFORM: SHARED leftover gcc sidecar · LINUX gold · MACOS co-path.
pipeline_abi_inject_asm_wpo_cap() {
  local o="$1"
  local src="seeds/runtime_pipeline_abi_asm_wpo_overlay.c"
  local twin="seeds/runtime_pipeline_abi_asm_wpo.from_x.c"
  local cap="src/runtime_pipeline_abi_asm_wpo_cap.o"
  local stamp="src/.pabi_w742_asm_wpo_cap.stamp"
  local stamp_ban="src/.pabi_w369b_asm_wpo.stamp"
  [ -s "$o" ] && [ -f "$src" ] && [ -f "$twin" ] || return 0
  touch "$stamp_ban"
  if [ -f "$stamp" ] && [ -s "$cap" ] \
    && [ ! "$src" -nt "$stamp" ] && [ ! "$twin" -nt "$stamp" ]; then
    return 0
  fi
  # PLATFORM: SHARED — leftover gcc overlay sidecar (clang Darwin / gcc LINUX).
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Iseeds -c -o "$cap" "$src"; then
    log "pipeline_abi w742-asm-wpo-cap: cc overlay failed"
    return 1
  fi
  touch "$stamp"
  log "pipeline_abi w742-asm-wpo-cap: leftover gcc sidecar FUNCS=4096 (HARD BAN PREFER thin)"
  return 0
}

# wave743 M2: Darwin COMMON lea PAGE21. leftover gcc lea writes g_pipe_elf
# reloc rows with no owner; leftover compact macho_write inlines leftover C
# static g_pipeline_elf_reloc_r_type + owner check → empty → BRANCH26.
# Heal: globalize both BSS homes, leftover-gcc sidecar append_reloc_typed
# (strong T) writes both arrays and binds both owners. Do not gcc -E .x.
# Do not PREFER macho_write_thin. Do not Darwin ld -r into pabi. Do not
# redefine leftover T (w647). HARD BAN PREFER asm_wpo_thin until this
# sidecar is live and standalone thin COMMON lea is PAGE21/PAGEOFF12.
# PLATFORM: SHARED leftover gcc sidecar · LINUX gold · MACOS writer co-path.
pipeline_abi_w743_objcopy() {
  if [ "$(uname -s)" = Darwin ]; then
    if [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ]; then
      echo /opt/homebrew/opt/llvm/bin/llvm-objcopy
      return 0
    fi
  fi
  if command -v llvm-objcopy >/dev/null 2>&1; then
    command -v llvm-objcopy
    return 0
  fi
  if command -v objcopy >/dev/null 2>&1; then
    command -v objcopy
    return 0
  fi
  return 1
}

pipeline_abi_inject_reloc_typed_page21() {
  local o="$1"
  local src="seeds/runtime_pipeline_abi_reloc_typed_overlay.c"
  local cap="src/runtime_pipeline_abi_reloc_typed.o"
  local stamp="src/.pabi_w743_reloc_typed_page21.stamp"
  local objcopy pfx
  [ -s "$o" ] && [ -f "$src" ] || return 0
  if [ "$(uname -s)" = Darwin ]; then
    pfx="_"
  else
    pfx=""
  fi
  objcopy="$(pipeline_abi_w743_objcopy)" || {
    log "pipeline_abi w743-reloc-typed: objcopy missing"
    return 1
  }
  # PLATFORM: SHARED — leftover C statics are non-external; sidecar must
  # write them, so globalize. Idempotent if already external.
  if ! "$objcopy" \
    --globalize-symbol="${pfx}g_pipe_elf_reloc_r_type" \
    --globalize-symbol="${pfx}g_pipe_elf_reloc_r_pcrel" \
    --globalize-symbol="${pfx}g_pipe_elf_reloc_sidecar_owner" \
    --globalize-symbol="${pfx}g_pipeline_elf_reloc_r_type" \
    --globalize-symbol="${pfx}g_pipeline_elf_reloc_r_pcrel" \
    --globalize-symbol="${pfx}g_pipeline_elf_reloc_sidecar_owner" \
    "$o"; then
    log "pipeline_abi w743-reloc-typed: globalize BSS failed"
    return 1
  fi
  if [ -f "$stamp" ] && [ -s "$cap" ] && [ ! "$src" -nt "$stamp" ]; then
    return 0
  fi
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Iseeds -c -o "$cap" "$src"; then
    log "pipeline_abi w743-reloc-typed: cc overlay failed"
    return 1
  fi
  touch "$stamp"
  log "pipeline_abi w743-reloc-typed: leftover gcc sidecar PAGE21 owner bind"
  return 0
}

# wave744 M2: Darwin Lxml S n_sect=2. leftover gcc emit/append/poke write
# .x g_pipe_elf_data_len; leftover compact macho_write inlines leftover C
# g_pipeline_elf_data_len (empty → nsects=1) while wave344 non-zero scalar
# imm (g_aw_root_id=-1) is SHNX_DATA n_sect=2. Heal: globalize both BSS
# homes, leftover-gcc sidecar F7 data family (strong T) writes both buffers.
# Do not gcc -E .x. Do not PREFER macho_write_thin. Do not Darwin ld -r
# into pabi. Do not redefine leftover T (w647). HARD BAN PREFER
# asm_wpo_thin: n_sect closed, but g05-prepend thin is CG002 code_len=0.
# PLATFORM: SHARED leftover gcc sidecar · LINUX gold · MACOS writer co-path.
pipeline_abi_inject_data_len_dual_bss() {
  local o="$1"
  local src="seeds/runtime_pipeline_abi_data_len_overlay.c"
  local cap="src/runtime_pipeline_abi_data_len.o"
  local stamp="src/.pabi_w744_data_len_dual_bss.stamp"
  local objcopy pfx
  [ -s "$o" ] && [ -f "$src" ] || return 0
  if [ "$(uname -s)" = Darwin ]; then
    pfx="_"
  else
    pfx=""
  fi
  objcopy="$(pipeline_abi_w743_objcopy)" || {
    log "pipeline_abi w744-data-len: objcopy missing"
    return 1
  }
  # PLATFORM: SHARED — leftover C statics are non-external; sidecar must
  # write them, so globalize. Mega .x BSS is already local; globalize so
  # the sidecar can bind both homes. Idempotent if already external.
  if ! "$objcopy" \
    --globalize-symbol="${pfx}g_pipe_elf_data_buf" \
    --globalize-symbol="${pfx}g_pipe_elf_data_len" \
    --globalize-symbol="${pfx}g_pipe_elf_data_owner" \
    --globalize-symbol="${pfx}g_pipeline_elf_data_buf" \
    --globalize-symbol="${pfx}g_pipeline_elf_data_len" \
    "$o"; then
    log "pipeline_abi w744-data-len: globalize BSS failed"
    return 1
  fi
  # Mega smash T of reset / data_ptr / append_u32 is strong; leftover gcc
  # emit/append_zeros/poke is already weak. Weaken so sidecar strong T
  # first-wins. Do not --redefine-sym leftover T (w647).
  # PLATFORM: SHARED objcopy weaken · Darwin leftover already weak is a no-op.
  "$objcopy" \
    --weaken-symbol="${pfx}pipeline_elf_ctx_emit_data_len" \
    --weaken-symbol="${pfx}pipeline_elf_ctx_append_data_zeros" \
    --weaken-symbol="${pfx}pipeline_elf_ctx_data_poke_u8" \
    --weaken-symbol="${pfx}pipeline_elf_ctx_append_data_u32_le" \
    --weaken-symbol="${pfx}pipeline_elf_ctx_data_data_ptr" \
    --weaken-symbol="${pfx}pipeline_elf_ctx_reset_data" \
    "$o" || true
  if [ -f "$stamp" ] && [ -s "$cap" ] && [ ! "$src" -nt "$stamp" ]; then
    return 0
  fi
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Iseeds -c -o "$cap" "$src"; then
    log "pipeline_abi w744-data-len: cc overlay failed"
    return 1
  fi
  touch "$stamp"
  log "pipeline_abi w744-data-len: leftover gcc sidecar dual BSS F7 data"
  return 0
}

# wave745 M2: const_lit only hits `const`; load_operand VAR-without-slot
# falls back to emit_expr_elf_fast. leftover gcc sidecar first-wins leftover
# gcc weak T. Do not gcc -E .x. Do not PREFER peel_thin. Do not ld -r
# into pabi. Do not redefine leftover T (w647).
# PLATFORM: SHARED leftover gcc sidecar · LINUX gold · MACOS co-path.
pipeline_abi_inject_const_lit_is_const() {
  local o="$1"
  local src="seeds/runtime_pipeline_abi_const_lit_overlay.c"
  local cap="src/runtime_pipeline_abi_const_lit.o"
  local stamp="src/.pabi_w745_const_lit_is_const.stamp"
  local objcopy pfx
  [ -s "$o" ] && [ -f "$src" ] || return 0
  if [ "$(uname -s)" = Darwin ]; then
    pfx="_"
  else
    pfx=""
  fi
  objcopy="$(pipeline_abi_w743_objcopy)" || {
    log "pipeline_abi w745-const-lit: objcopy missing"
    return 1
  }
  # Leftover gcc const_lit / load_operand is already weak; mega smash T
  # of load_operand (if present) needs weaken so sidecar strong T wins.
  # PLATFORM: SHARED objcopy weaken · Darwin leftover already weak is a no-op.
  "$objcopy" \
    --weaken-symbol="${pfx}asm_module_top_level_const_lit_i32" \
    --weaken-symbol="${pfx}glue_try_binop_load_operand_elf_c" \
    "$o" || true
  if [ -f "$stamp" ] && [ -s "$cap" ] && [ ! "$src" -nt "$stamp" ]; then
    return 0
  fi
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Iseeds -c -o "$cap" "$src"; then
    log "pipeline_abi w745-const-lit: cc overlay failed"
    return 1
  fi
  touch "$stamp"
  log "pipeline_abi w745-const-lit: leftover gcc sidecar const_lit is_const + load_operand fallback"
  return 0
}

# wave308/366/w504 M2: sidecar_pool Cap residual C→.x (was wave275 C thin).
# PRODUCT inject wave366: PREFER_ASM both ends (prior green overlay).
# wave504: tipU heal inventory (init peers + thin get) but tip PRODUCT PREFER
#   HARD BAN — pure-asm reinject → L2 SEGV 0/5 (same class as w489/w491/w503).
#   Keep prior w366 leftover; stamp-only skip. Tip still drops onefunc_get
#   in monolith main even after peer peel (file-tail); ban until tipU 6/6 + L2.
# T001 w308_* helpers; large BSS; gate=type_alias -c + L2.
# G.7 match mega wave275 leave. PLATFORM: SHARED · BAN tip reinject both ends.
pipeline_abi_inject_sidecar_pool_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_sidecar_pool_thin.x"
  local stamp="src/.pabi_w504_sidecar_pool.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — HARD BAN tip product reinject (L2 SEGV @ w504).
  # tipU heal peers remain in tree for inventory; do not call inject_thin_leaf.
  touch "$stamp"
  touch src/.pabi_w504_sidecar_pool_arena_init.stamp
  touch src/.pabi_w504_sidecar_pool_module_init.stamp
  touch src/.pabi_w504_sidecar_pool_onefunc_init.stamp
  rm -f src/.pabi_w308_sidecar_pool.stamp src/.pabi_w366_sidecar_pool.stamp
  log "pipeline_abi w504-sidecar-pool: tipU heal stamped; tip PRODUCT reinject HARD BAN (keep w366)"
  return 0
}









# wave330/378/384/517 M2: value_abi Cap residual C→.x (was wave276 C thin).
# PRODUCT inject wave384 HARD BAN reinject both ends: stay prior -E overlay.
#   w378 BAN PREFER (sret ABI SysV vs AAPCS64) — stay -E+$CC both ends.
#   w384: formalize HARD BAN reinject (do not call inject_thin_leaf) —
#     tip -E reinject of opaque sret blobs is poison-class with Cap A /
#     tip force-reinject; keep green overlay via stamp only.
# wave517: float-bits peer-flat tipU Soft Cap (value_abi_float_bits_thin);
#   Ubuntu tip CG002 on sret monolith; stamp → w517; tip PRODUCT reinject
#   still HARD BAN (keep prior -E overlay).
# G.7 WAVE276_ARENA_VALUE_ABI_ALWAYS. PLATFORM: SHARED · BAN reinject.
pipeline_abi_inject_value_abi_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_value_abi_thin.x"
  local float_x="src/runtime_pipeline_abi_value_abi_float_bits_thin.x"
  local stamp="src/.pabi_w517_value_abi.stamp"
  local float_s="src/.pabi_w517_value_abi_float_bits.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN reinject (do not call inject_thin_leaf).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ] \
    && { [ ! -f "$float_x" ] || { [ -f "$float_s" ] && [ ! "$float_x" -nt "$float_s" ]; }; }; then
    return 0
  fi
  touch "$stamp"
  if [ -f "$float_x" ]; then
    touch "$float_s"
  fi
  rm -f src/.pabi_w330_value_abi.stamp src/.pabi_w378_value_abi.stamp \
    src/.pabi_w384_value_abi.stamp
  log "pipeline_abi w517-value-abi: float-bits tipU peer stamped; tip PRODUCT reinject HARD BAN (keep prior -E)"
  return 0
}



# wave326/364/526 M2: block_domain Cap residual C→.x (was wave277 C thin).
# PRODUCT inject wave364: PREFER_ASM both ends try (ALLOW_E_REPLACE + stamp).
# T001 w326_* helpers; standalone -c green; gate=type_alias -c + L2.
# wave526 Soft Cap: tip CG002 heal (libc memmove) + tipU pipe-cell;
#   stamp → w526; tip PRODUCT reinject HARD BAN (keep prior PREFER overlay).
# G.7 WAVE277_BLOCK_DOMAIN_ALWAYS. PLATFORM: SHARED · BAN reinject after w526.
pipeline_abi_inject_block_domain_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_block_domain_thin.x"
  local stamp="src/.pabi_w526_block_domain.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN tip reinject (do not call inject_thin_leaf).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w326_block_domain.stamp src/.pabi_w364_block_domain.stamp
  log "pipeline_abi w526-block-domain: tip CG002+tipU heal stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}



# wave327/365/529 M2: expr_sidecar Cap residual C→.x (was wave278 C thin).
# PRODUCT inject wave365: PREFER_ASM both ends try (ALLOW_E_REPLACE + stamp).
# T001 w327_load/store; standalone -c green; gate=type_alias -c + L2.
# wave529 Soft Cap: tip SEGV heal (i64/f64 via memcpy) + pipe-cell mid-call
#   (w327_expr/sc + w529_gv_*/block_ptr) + Darwin tipU complete; stamp → w529;
#   tip PRODUCT reinject HARD BAN (keep prior PREFER overlay). Ubuntu tip
#   full-leaf still truncates mid-TU (tip emit capacity) — BAN justified.
#   Prefer reinject → L2 SEGV class (Soft Cap stamp-only).
# G.7 WAVE278_EXPR_SIDECAR_DOMAIN_ALWAYS. PLATFORM: SHARED.
pipeline_abi_inject_expr_sidecar_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_expr_sidecar_thin.x"
  local stamp="src/.pabi_w529_expr_sidecar.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN PREFER (do not call inject_thin_leaf).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w327_expr_sidecar.stamp src/.pabi_w365_expr_sidecar.stamp
  log "pipeline_abi w529-expr-sidecar: tip SEGV+pipe-cell+Darwin tipU stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}



# wave320/334/522 M2: lifecycle Cap residual C→.x (was wave279 C thin).
# PRODUCT inject wave334: PREFER_ASM both ends (ALLOW_E_REPLACE + stamp).
# wave522 Soft Cap: peer-flat release + module/arena/onefunc reset + block +
#   drop (Ubuntu tip CG002 on shared monolithic TU; tipU Soft Cap); stamp →
#   w522; tip PRODUCT reinject HARD BAN (keep prior PREFER overlay).
# G.7 WAVE279_LIFECYCLE_ALWAYS. PLATFORM: SHARED.
pipeline_abi_inject_lifecycle_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_lifecycle_thin.x"
  local mreset_x="src/runtime_pipeline_abi_lifecycle_module_reset_thin.x"
  local areset_x="src/runtime_pipeline_abi_lifecycle_arena_reset_thin.x"
  local oreset_x="src/runtime_pipeline_abi_lifecycle_onefunc_reset_thin.x"
  local block_x="src/runtime_pipeline_abi_lifecycle_block_thin.x"
  local drop_x="src/runtime_pipeline_abi_lifecycle_drop_thin.x"
  local stamp="src/.pabi_w522_lifecycle.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — w522 HARD BAN tip force-reinject once stamped.
  if [ -f "$stamp" ]; then
    return 0
  fi
  # Migrate w334 → w522 without reinject (tipU heal inventory only).
  if [ -f src/.pabi_w334_lifecycle.stamp ]; then
    touch "$stamp"
    rm -f src/.pabi_w334_lifecycle.stamp src/.pabi_w320_lifecycle.stamp
    log "pipeline_abi w522-lifecycle: tipU peer-flat stamped; tip force-reinject HARD BAN (keep PREFER overlay)"
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — PREFER_ASM first-wins (cold unlock: peers→release).
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  if [ -f "$mreset_x" ]; then
    pipeline_abi_inject_thin_leaf "$o" "$mreset_x" "w522-lifecycle-module-reset"
    rc=$?
  fi
  if [ "$rc" -eq 0 ] && [ -f "$areset_x" ]; then
    pipeline_abi_inject_thin_leaf "$o" "$areset_x" "w522-lifecycle-arena-reset"
    rc=$?
  fi
  if [ "$rc" -eq 0 ] && [ -f "$oreset_x" ]; then
    pipeline_abi_inject_thin_leaf "$o" "$oreset_x" "w522-lifecycle-onefunc-reset"
    rc=$?
  fi
  if [ "$rc" -eq 0 ] && [ -f "$block_x" ]; then
    pipeline_abi_inject_thin_leaf "$o" "$block_x" "w522-lifecycle-block"
    rc=$?
  fi
  if [ "$rc" -eq 0 ] && [ -f "$drop_x" ]; then
    pipeline_abi_inject_thin_leaf "$o" "$drop_x" "w522-lifecycle-drop"
    rc=$?
  fi
  if [ "$rc" -eq 0 ]; then
    pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w522-lifecycle-release"
    rc=$?
  fi
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    rm -f src/.pabi_w320_lifecycle.stamp src/.pabi_w334_lifecycle.stamp
  fi
  return "$rc"
}



# wave324/363/363b/385 M2: module_func Cap residual C→.x (was wave280 C thin).
# PRODUCT inject wave385 HARD BAN reinject both ends: stay prior overlay.
#   Prior: MACOS PREFER / LINUX -E (w363b; Ubuntu PREFER → undef main).
#   w385: formalize HARD BAN reinject (do not call inject_thin_leaf) —
#     tip reinject poison class (Cap A / type_pool / elf_ctx); keep green
#     Darwin PREFER / Ubuntu -E via stamp only until undef-main root.
# G.7 WAVE280. PLATFORM: SHARED · BAN reinject both ends.
pipeline_abi_inject_module_func_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_module_func_thin.x"
  local stamp="src/.pabi_w385_module_func.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN reinject (do not call inject_thin_leaf).
  touch "$stamp"
  rm -f src/.pabi_w324_module_func.stamp src/.pabi_w363_module_func.stamp \
    src/.pabi_w363b_module_func.stamp
  return 0
}



# wave325/335/363/379/525 M2: onefunc Cap residual C→.x (was wave281 C thin).
# PRODUCT inject wave379 HARD BAN PREFER: stay prior -E overlay; do not
# re-overlay. wave335 PREFER → Darwin L2 SEGV; wave379 PREFER reconfirm →
# Darwin L2 opt/si/hello XP001 parse fail (gate type_alias -c + thin -c green).
# T001 w325_* kept. Stamp w379.
# wave525 Soft Cap: tipU pipe-cell heal (sidecar／GrowVec／block mid-call);
#   stamp → w525; tip PRODUCT reinject still HARD BAN (keep prior overlay).
# PLATFORM: SHARED · both ends hard-skip until GrowVec/sidecar LE pure-asm root.
pipeline_abi_inject_onefunc_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_onefunc_thin.x"
  local stamp="src/.pabi_w525_onefunc.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN PREFER (do not call inject_thin_leaf).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w325_onefunc.stamp src/.pabi_w379_onefunc.stamp
  log "pipeline_abi w525-onefunc: tipU heal stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}



# wave321/376/391 M2: bootstrap_glue Cap residual C→.x (was wave282 C thin).
# PRODUCT inject wave391 HARD BAN reinject both ends: stay prior overlay.
#   Prior: BAN PREFER (BRANCH26); MACOS -E / LINUX hard-skip (w376).
#   w391: formalize HARD BAN reinject (do not call inject_thin_leaf) —
#     tip reinject poison class; keep green Darwin -E / Ubuntu prior -E
#     via stamp only until BRANCH26 / Ubuntu typeck root.
# G.7 WAVE282_BOOTSTRAP_GLUE_ALWAYS. PLATFORM: SHARED · BAN reinject.
pipeline_abi_inject_bootstrap_glue_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_bootstrap_glue_thin.x"
  local stamp="src/.pabi_w391_bootstrap_glue.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN reinject (do not call inject_thin_leaf).
  touch "$stamp"
  rm -f src/.pabi_w321_bootstrap_glue.stamp src/.pabi_w376_bootstrap_glue.stamp
  return 0
}



# wave322/336 M2: ast_forwarders Cap residual .x thin (rename shims + copy_lib_root).
# PRODUCT inject: wave336 PREFER_ASM (ALLOW_E_REPLACE + stamp). No BSS;
# no GrowVec/pipe LE; shim bodies T001-unsafe (was -E+$CC interim).
# G.7 WAVE283_AST_FORWARDERS_ALWAYS. PLATFORM: SHARED.
pipeline_abi_inject_ast_forwarders_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_ast_forwarders_thin.x"
  local stamp="src/.pabi_w336_ast_forwarders.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # w834: POSIX product rest omits these faces (-DXLANG_PABI_AST_FORWARDERS_ASM).
  # A stamp skip on a fresh hybrid leaves them undefined. Re-inject when the
  # sentinel is not already strong text. Old hybrids that still contain the
  # C body stay put until the rest is rebuilt. PLATFORM: SHARED.
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    if pipeline_abi_strong_text_syms "$o" | grep -Eq '(^|_)pipeline_copy_lib_root_to_buf256$'; then
      return 0
    fi
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w336-ast-forwarders"
  rc=$?
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
  fi
  return "$rc"
}



# wave323/374/374b/388 M2: parse_orch Cap residual C→.x (was wave284 C thin).
# PRODUCT inject wave388 HARD BAN reinject both ends: stay prior overlay.
#   Prior: MACOS PREFER / LINUX hard-skip (w374b; Ubuntu tip whole-body
#   unsafe → XT001 even under -E).
#   w388: formalize HARD BAN reinject (do not call inject_thin_leaf) —
#     tip reinject poison class; keep green Darwin PREFER / Ubuntu prior
#     -E via stamp only until ParseIntoResult/typeck root.
# G.7 WAVE284_PARSE_ORCH_ALWAYS. PLATFORM: SHARED · BAN reinject both ends.
pipeline_abi_inject_parse_orch_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_parse_orch_thin.x"
  local stamp="src/.pabi_w388_parse_orch.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN reinject (do not call inject_thin_leaf).
  touch "$stamp"
  rm -f src/.pabi_w323_parse_orch.stamp src/.pabi_w374_parse_orch.stamp \
    src/.pabi_w374b_parse_orch.stamp
  return 0
}



# wave318/331/481 M2: typeck_orch Cap residual .x thin (shims+layout glue).
# PRODUCT inject: wave331/w481 PREFER_ASM (ALLOW_E_REPLACE + stamp). No BSS;
# out-param *i32 reloc OK under pure-asm (was -E+$CC interim).
# wave481: no-local validate (tip U=5/6 → 6/6); stamp w481 both ends.
# G.7 WAVE285_TYPECK_ORCH_ALWAYS. PLATFORM: SHARED.
pipeline_abi_inject_typeck_orch_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_typeck_orch_thin.x"
  local stamp="src/.pabi_w481_typeck_orch.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # w835: POSIX product rest omits these faces (-DXLANG_PABI_TYPECK_ORCH_ASM).
  # A stamp skip on a fresh hybrid leaves them undefined. Re-inject when the
  # sentinel is not already strong text. Old hybrids that still contain the
  # C body stay put until the rest is rebuilt. PLATFORM: SHARED.
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    if pipeline_abi_strong_text_syms "$o" | grep -Eq '(^|_)typeck_x_type_size_from_layout_glue$'; then
      return 0
    fi
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w481-typeck-orch"
  rc=$?
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    rm -f src/.pabi_w331_typeck_orch.stamp
  fi
  return "$rc"
}



# wave345: ingest modlet prepare/bake cold twin into product pabi WITHOUT mega -E.
# Compiles seeds/runtime_pipeline_abi.from_x.c under FROM_X+MODLET_IN_REST,
# localizes all globals then re-globalizes modlet export faces, weakens those
# in OUT, ld -r modlet-first. Lands w344 ordinal→.data bake on library TUs.
# PLATFORM: SHARED shell · LINUX gold · MACOS co-path · no FORCE mega.
pipeline_abi_inject_modlet_prepare_rest() {
  local o="$1"
  local seed="seeds/runtime_pipeline_abi.from_x.c"
  local stamp="src/.pabi_w345_modlet_prepare.stamp"
  local rest_o modlet_o base_o out_o
  local objcopy_bin=""
  local s=""
  local rc=0
  [ -s "$o" ] && [ -f "$seed" ] || return 0
  if [ -f "$stamp" ] && [ ! "$seed" -nt "$stamp" ]; then
    return 0
  fi
  if command -v objcopy >/dev/null 2>&1; then
    objcopy_bin="objcopy"
  elif command -v llvm-objcopy >/dev/null 2>&1; then
    objcopy_bin="llvm-objcopy"
  elif [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ]; then
    objcopy_bin="/opt/homebrew/opt/llvm/bin/llvm-objcopy"
  else
    log "pipeline_abi w345-modlet-prepare: no objcopy"
    return 1
  fi
  rest_o="$(mktemp "${TMPDIR:-/tmp}/pabi_modlet_rest.XXXXXX.o")"
  modlet_o="$(mktemp "${TMPDIR:-/tmp}/pabi_modlet_only.XXXXXX.o")"
  base_o="$(mktemp "${TMPDIR:-/tmp}/pabi_modlet_base.XXXXXX.o")"
  out_o="$(mktemp "${TMPDIR:-/tmp}/pabi_modlet_out.XXXXXX.o")"
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_USE_X_PIPELINE \
       -DXLANG_RUNTIME_PIPELINE_ABI_FROM_X \
       -DXLANG_RUNTIME_PIPELINE_ABI_MODLET_IN_REST \
       -c -o "$rest_o" "$seed"; then
    log "pipeline_abi w345-modlet-prepare: cc rest failed"
    rm -f "$rest_o" "$modlet_o" "$base_o" "$out_o"
    return 1
  fi
  cp -f "$rest_o" "$modlet_o"
  # Localize all globals so non-modlet FROM_X T do not collide with product.
  if ! "$objcopy_bin" -w --localize-symbol='*' "$modlet_o" 2>/dev/null; then
    log "pipeline_abi w345-modlet-prepare: localize-all failed"
    rm -f "$rest_o" "$modlet_o" "$base_o" "$out_o"
    return 1
  fi
  for s in \
    pipeline_asm_modlet_prepare_and_emit_elf_c \
    pipeline_asm_modlet_seed_nonzero_inits_elf_c \
    pipeline_asm_modlet_load_to_rax_elf_c \
    pipeline_asm_modlet_store_from_rax_elf_c \
    pipeline_asm_modlet_name_is_shared \
    pipeline_asm_register_module_top_level_lets_c \
    pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c
  do
    "$objcopy_bin" --globalize-symbol="$s" "$modlet_o" 2>/dev/null || true
    # PLATFORM: MACOS — Mach-O underscore.
    "$objcopy_bin" --globalize-symbol="_${s}" "$modlet_o" 2>/dev/null || true
  done
  cp -f "$o" "$base_o"
  for s in \
    pipeline_asm_modlet_prepare_and_emit_elf_c \
    pipeline_asm_modlet_seed_nonzero_inits_elf_c \
    pipeline_asm_modlet_load_to_rax_elf_c \
    pipeline_asm_modlet_store_from_rax_elf_c \
    pipeline_asm_modlet_name_is_shared \
    pipeline_asm_register_module_top_level_lets_c \
    pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c
  do
    "$objcopy_bin" --weaken-symbol="$s" "$base_o" 2>/dev/null || true
    "$objcopy_bin" --weaken-symbol="_${s}" "$base_o" 2>/dev/null || true
  done
  if ! ld -r -o "$out_o" "$modlet_o" "$base_o" 2>/dev/null; then
    log "pipeline_abi w345-modlet-prepare: ld -r merge failed"
    rm -f "$rest_o" "$modlet_o" "$base_o" "$out_o"
    return 1
  fi
  cp -f "$out_o" "$o"
  touch "$stamp"
  log "pipeline_abi w345-modlet-prepare inject OK (MODLET_IN_REST cold twin first-wins)"
  rm -f "$rest_o" "$modlet_o" "$base_o" "$out_o"
  return 0
}

# wave319/343/344/346/348/379/530/531 M2: typeck_check_expr Cap residual .x thin (was wave286 C).
# PRODUCT inject wave379 HARD BAN reinject: stay prior overlay; do not
# re-overlay. Prior: Darwin PREFER (w348) / Ubuntu -E. wave379 probes:
#   · Ubuntu tip XT001 on thin (w286_arena_num_exprs) even under -E.
#   · Darwin tip PREFER reinject → g05 ARM64_RELOC_BRANCH26.
# wave530 Soft Cap: tip XT001 heal (pipe_load unsafe + flatten nested lets).
# wave531 Soft Cap: tip CG002 peer-flat — faces + mega + impl peers tipU
#   complete both ends; stamp → w531; tip PRODUCT reinject HARD BAN (keep prior).
# Cold WEAK check_expr_impl{,_mega} left to typeck_x / seed (not in .x thin).
# G.7 WAVE286_TYPECK_CHECK_EXPR_ALWAYS.
# PLATFORM: SHARED · both ends hard-skip until reloc/typeck root.
pipeline_abi_inject_typeck_check_expr_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_typeck_check_expr_thin.x"
  local mega_x="src/runtime_pipeline_abi_typeck_check_expr_mega_thin.x"
  local impl_x="src/runtime_pipeline_abi_typeck_check_expr_impl_thin.x"
  local stamp="src/.pabi_w531_typeck_check_expr.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN reinject (do not call inject_thin_leaf).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ] \
    && [ ! "$mega_x" -nt "$stamp" ] && [ ! "$impl_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w348_typeck_check_expr.stamp src/.pabi_w346_typeck_check_expr.stamp \
    src/.pabi_w379_typeck_check_expr.stamp src/.pabi_w530_typeck_check_expr.stamp
  log "pipeline_abi w531-typeck-check-expr: tip CG002 peer-flat+tipU stamped; tip PRODUCT reinject HARD BAN (keep prior)"
  return 0
}



# wave329/375/381/532 M2: parser_result Cap residual C→.x (was wave287 C thin).
# PRODUCT inject wave381 HARD BAN reinject both ends: stay prior -E overlay.
#   w375 BAN PREFER (LexerResult.next_lex size under pure-asm).
#   w381 tip: Darwin -E/PREFER both T001 next_lex; Ubuntu PREFER XT001 unsafe;
#   Ubuntu -E still emits but reinject banned to match Cap A tip-poison class.
# wave532 Soft Cap: opaque u8[N] result blobs (ban nested Lexer/Token size);
#   tipU Soft Cap both ends; stamp → w532; tip PRODUCT reinject HARD BAN
#   (keep prior -E overlay; stamp-only 禁 prefer 全量误重注).
# G.7 WAVE287_PARSER_RESULT_ALWAYS. PLATFORM: SHARED · BAN reinject both ends.
pipeline_abi_inject_parser_result_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_parser_result_thin.x"
  local stamp="src/.pabi_w532_parser_result.stamp"
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — hard BAN reinject (do not call inject_thin_leaf).
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    return 0
  fi
  touch "$stamp"
  rm -f src/.pabi_w329_parser_result.stamp src/.pabi_w381_parser_result.stamp
  log "pipeline_abi w532-parser-result: opaque tipU stamped; tip PRODUCT reinject HARD BAN (keep prior -E)"
  return 0
}



# wave294/353/520 M2: asm_label_format Cap residual C→.x (was wave288 C thin).
# PRODUCT inject wave353: PREFER_ASM both ends (ALLOW_E_REPLACE + stamp).
# wave520 Soft Cap: peer-flat digits + emit_next + format_id (Ubuntu tip
#   CG002 when all share one tip TU); tipU Soft Cap; stamp → w520;
#   tip PRODUCT reinject HARD BAN (keep prior PREFER overlay).
# G.7 match seed WAVE288_ASM_LABEL_FORMAT_ALWAYS. PLATFORM: SHARED.
pipeline_abi_inject_asm_label_format_thin() {
  local o="$1"
  local digits_x="src/runtime_pipeline_abi_asm_label_digits_thin.x"
  local emit_x="src/runtime_pipeline_abi_asm_label_emit_next_thin.x"
  local thin_x="src/runtime_pipeline_abi_asm_label_format_thin.x"
  local stamp="src/.pabi_w520_asm_label.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — w520 HARD BAN tip force-reinject once stamped.
  if [ -f "$stamp" ]; then
    return 0
  fi
  # Migrate w353 → w520 without reinject (tipU heal inventory only).
  if [ -f src/.pabi_w353_asm_label.stamp ]; then
    touch "$stamp"
    rm -f src/.pabi_w353_asm_label.stamp src/.pabi_w294_asm_label.stamp
    log "pipeline_abi w520-asm-label: tipU peer-flat stamped; tip force-reinject HARD BAN (keep PREFER overlay)"
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — PREFER_ASM first-wins (cold unlock: digits→emit→format).
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  if [ -f "$digits_x" ]; then
    pipeline_abi_inject_thin_leaf "$o" "$digits_x" "w520-asm-label-digits"
    rc=$?
  fi
  if [ "$rc" -eq 0 ] && [ -f "$emit_x" ]; then
    pipeline_abi_inject_thin_leaf "$o" "$emit_x" "w520-asm-label-emit"
    rc=$?
  fi
  if [ "$rc" -eq 0 ]; then
    pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w520-asm-label-format"
    rc=$?
  fi
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    rm -f src/.pabi_w294_asm_label.stamp src/.pabi_w353_asm_label.stamp
  fi
  return "$rc"
}



# wave296/355/521 M2: codegen_outbuf Cap residual C→.x (was wave289 C thin).
# PRODUCT inject wave355: PREFER_ASM both ends (ALLOW_E_REPLACE + stamp).
# wave521 Soft Cap: peer-flat append + BSS float/bits + pipe-cell mid n/rc/op
#   (Ubuntu tip CG002 on shared append+float TU; tipU Soft Cap); stamp → w521;
#   tip PRODUCT reinject HARD BAN (keep prior PREFER overlay).
# G.7 WAVE289_CODEGEN_OUTBUF_ALWAYS. PLATFORM: SHARED.
pipeline_abi_inject_codegen_outbuf_thin() {
  local o="$1"
  local append_x="src/runtime_pipeline_abi_codegen_outbuf_append_thin.x"
  local thin_x="src/runtime_pipeline_abi_codegen_outbuf_thin.x"
  local stamp="src/.pabi_w521_codegen_outbuf.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # PLATFORM: SHARED — w521 HARD BAN tip force-reinject once stamped.
  if [ -f "$stamp" ]; then
    return 0
  fi
  # Migrate w355 → w521 without reinject (tipU heal inventory only).
  if [ -f src/.pabi_w355_codegen_outbuf.stamp ]; then
    touch "$stamp"
    rm -f src/.pabi_w355_codegen_outbuf.stamp src/.pabi_w296_codegen_outbuf.stamp
    log "pipeline_abi w521-codegen-outbuf: tipU peer-flat stamped; tip force-reinject HARD BAN (keep PREFER overlay)"
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — PREFER_ASM first-wins (cold unlock: append→main).
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  if [ -f "$append_x" ]; then
    pipeline_abi_inject_thin_leaf "$o" "$append_x" "w521-codegen-outbuf-append"
    rc=$?
  fi
  if [ "$rc" -eq 0 ]; then
    pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w521-codegen-outbuf"
    rc=$?
  fi
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    rm -f src/.pabi_w296_codegen_outbuf.stamp src/.pabi_w355_codegen_outbuf.stamp
  fi
  return "$rc"
}



# wave290/328/371/371b/389/394/394b/424/443/444 M2: asm_codegen_mega_body Cap residual.
# PRODUCT inject wave424/443/444 asymmetric:
#   MACOS: three-leaf PREFER (helpers → emit_one → loop); Darwin L2 5/5.
#   LINUX wave424: PREFER emit_one ONLY.
#   LINUX wave443: helpers via -E unlock (pure-asm helpers → CG002/SEGV w429).
#   LINUX wave444: loop tip HARD BAN — root map:
#     · -E tip: codegen drops e_machine/reloc stores + reorders modlet → EM:0
#       (ld "Relocations in generic ELF (EM: 0)"); L2 0/5 build=1.
#     · pure-asm tip: inject OK but product SEGV 139 (L2 0/5).
#     Keep leftover mega_body_c; stamp .pabi_w444_mega_loop (no tip overlay).
#   wave450: reshape probes confirm tip pipe_store / malloc / stack arrays
#     each alone → product si SEGV; -E still EM:0. HARD BAN unchanged.
#   wave453: BSS+pipe_elf_off+no-local tip → L2 0/5 code_len=0; -E → BLD001
#     no main. HARD BAN unchanged. Stamp-only loop.
#   wave456: arch peer + loop -E(call peer) → L2 0/5 BLD001 no main. BAN.
#     Stamp .pabi_w443_mega_helpers + .pabi_w499_mega_emit_one.
# wave427: loop-alone after emit_one PREFER still BAN (product EM:0 L2 0/5).
# wave429: mega_body pure-asm product CG002/SEGV; healed by leave leftover;
#   w443 soft -E helpers unlock.
# wave499: emit_one tipU heal — peer-flat split (head+6 peers); stamp → w499;
#   LINUX PREFER peers+head (helpers -E; loop BAN).
# G.7 WAVE290_ASM_CODEGEN_MEGA_BODY_ALWAYS.
# PLATFORM: SHARED · MACOS helpers+peers+head+loop PREFER / LINUX helpers-E+peers / loop BAN.
pipeline_abi_inject_asm_codegen_mega_body_thin() {
  local o="$1"
  local thin_helpers="src/runtime_pipeline_abi_asm_codegen_mega_body_thin.x"
  local thin_emit="src/runtime_pipeline_abi_asm_codegen_mega_emit_one_thin.x"
  local thin_loop="src/runtime_pipeline_abi_asm_codegen_mega_loop_thin.x"
  # wave499 peers (inject before head so first-wins overlays land under head U).
  local thin_skip="src/runtime_pipeline_abi_asm_codegen_mega_emit_skip_heavy_thin.x"
  local thin_frame="src/runtime_pipeline_abi_asm_codegen_mega_emit_frame_thin.x"
  local thin_bsync="src/runtime_pipeline_abi_asm_codegen_mega_emit_body_sync_thin.x"
  local thin_binits="src/runtime_pipeline_abi_asm_codegen_mega_emit_body_inits_thin.x"
  local thin_retex="src/runtime_pipeline_abi_asm_codegen_mega_emit_ret_expr_thin.x"
  local thin_epi="src/runtime_pipeline_abi_asm_codegen_mega_emit_epilogue_thin.x"
  local stamp="src/.pabi_w394_mega_body.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local had_newer=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_helpers" ] && [ -f "$thin_emit" ] && [ -f "$thin_loop" ] || return 0
  [ -f "$thin_skip" ] && [ -f "$thin_frame" ] && [ -f "$thin_bsync" ] \
    && [ -f "$thin_binits" ] && [ -f "$thin_retex" ] && [ -f "$thin_epi" ] || return 0
  # Inject emit_one peer pack (PREFER); caller sets PREFER/ALLOW_E.
  # PLATFORM: SHARED shell · LINUX gold peers · MACOS co-path.
  _w499_inject_emit_peers() {
    local _o="$1"
    local _rc=0
    pipeline_abi_inject_thin_leaf "$_o" "$thin_skip" "w499-mega-emit-skip" || _rc=$?
    if [ "$_rc" -eq 0 ]; then
      pipeline_abi_inject_thin_leaf "$_o" "$thin_frame" "w499-mega-emit-frame" || _rc=$?
    fi
    if [ "$_rc" -eq 0 ]; then
      pipeline_abi_inject_thin_leaf "$_o" "$thin_bsync" "w499-mega-emit-bsync" || _rc=$?
    fi
    if [ "$_rc" -eq 0 ]; then
      pipeline_abi_inject_thin_leaf "$_o" "$thin_binits" "w499-mega-emit-binits" || _rc=$?
    fi
    if [ "$_rc" -eq 0 ]; then
      pipeline_abi_inject_thin_leaf "$_o" "$thin_retex" "w499-mega-emit-retex" || _rc=$?
    fi
    if [ "$_rc" -eq 0 ]; then
      pipeline_abi_inject_thin_leaf "$_o" "$thin_epi" "w499-mega-emit-epi" || _rc=$?
    fi
    if [ "$_rc" -eq 0 ]; then
      pipeline_abi_inject_thin_leaf "$_o" "$thin_emit" "w499-mega-emit-one" || _rc=$?
    fi
    return "$_rc"
  }
  # PLATFORM: LINUX — helpers -E (w443) then emit_one peers+head PREFER (w499);
  #   loop tip HARD BAN (w444/w450/w453: -E EM:0/BLD001; tip SEGV/code_len=0).
  case "$(uname -s)" in
    Linux)
      local stamp_h="src/.pabi_w443_mega_helpers.stamp"
      local stamp_l="src/.pabi_w499_mega_emit_one.stamp"
      local stamp_loop="src/.pabi_w444_mega_loop.stamp"
      local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
      local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
      local had_prefer=0 had_e_repl=0
      local need_h=0 need_e=0
      # PLATFORM: LINUX — HARD BAN loop tip reinject (stamp only).
      touch "$stamp_loop"
      if [ ! -f "$stamp_h" ] || [ "$thin_helpers" -nt "$stamp_h" ]; then
        need_h=1
      fi
      if [ ! -f "$stamp_l" ] || [ "$thin_emit" -nt "$stamp_l" ] \
        || [ "$thin_skip" -nt "$stamp_l" ] || [ "$thin_frame" -nt "$stamp_l" ] \
        || [ "$thin_bsync" -nt "$stamp_l" ] || [ "$thin_binits" -nt "$stamp_l" ] \
        || [ "$thin_retex" -nt "$stamp_l" ] || [ "$thin_epi" -nt "$stamp_l" ]; then
        need_e=1
      fi
      if [ "$need_h" = "0" ] && [ "$need_e" = "0" ]; then
        touch "$stamp"
        return 0
      fi
      if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then had_prefer=1; fi
      if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then had_e_repl=1; fi
      unset XLANG_PABI_THIN_INJECT_IF_NEWER
      export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
      # Order: helpers -E first, then peers+head pure-asm (G.7 first-wins).
      if [ "$need_h" = "1" ]; then
        export XLANG_PABI_THIN_PREFER_ASM=0
        pipeline_abi_inject_thin_leaf "$o" "$thin_helpers" "w443-mega-helpers-e"
        rc=$?
        if [ "$rc" -eq 0 ]; then
          touch "$stamp_h"
        fi
      fi
      if [ "$rc" -eq 0 ] && [ "$need_e" = "1" ]; then
        export XLANG_PABI_THIN_PREFER_ASM=1
        _w499_inject_emit_peers "$o"
        rc=$?
        if [ "$rc" -eq 0 ]; then
          touch "$stamp_l"
          rm -f src/.pabi_w424_mega_emit_one.stamp
        fi
      fi
      if [ "$had_prefer" = "1" ]; then export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"; else unset XLANG_PABI_THIN_PREFER_ASM; fi
      if [ "$had_e_repl" = "1" ]; then export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"; else unset XLANG_PABI_THIN_ALLOW_E_REPLACE; fi
      if [ "$rc" -eq 0 ]; then
        touch "$stamp"
        rm -f src/.pabi_w328_mega_body.stamp src/.pabi_w371_mega_body.stamp \
          src/.pabi_w389_mega_body.stamp
      fi
      return "$rc"
      ;;
  esac
  # Skip when stamp newer than helpers+head+peers+loop (already overlaid).
  if [ -f "$stamp" ] \
    && [ ! "$thin_helpers" -nt "$stamp" ] \
    && [ ! "$thin_emit" -nt "$stamp" ] \
    && [ ! "$thin_loop" -nt "$stamp" ] \
    && [ ! "$thin_skip" -nt "$stamp" ] \
    && [ ! "$thin_frame" -nt "$stamp" ] \
    && [ ! "$thin_bsync" -nt "$stamp" ] \
    && [ ! "$thin_binits" -nt "$stamp" ] \
    && [ ! "$thin_retex" -nt "$stamp" ] \
    && [ ! "$thin_epi" -nt "$stamp" ]; then
    return 0
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: MACOS — Order: helpers → peers+head → loop (first-wins).
  # wave499: emit_one tipU peer-flat; tag w499-mega-emit-*.
  pipeline_abi_inject_thin_leaf "$o" "$thin_helpers" "w394-mega-helpers" || rc=$?
  if [ "$rc" -eq 0 ]; then
    _w499_inject_emit_peers "$o" || rc=$?
  fi
  if [ "$rc" -eq 0 ]; then
    pipeline_abi_inject_thin_leaf "$o" "$thin_loop" "w394-mega-loop" || rc=$?
  fi
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    rm -f src/.pabi_w328_mega_body.stamp src/.pabi_w371_mega_body.stamp \
      src/.pabi_w389_mega_body.stamp src/.pabi_w424_mega_emit_one.stamp
  fi
  return "$rc"
}


# wave292/w505 M2: elf_codegen_forwarders Cap residual C→.x (was wave291 C thin).
# PRODUCT inject wave505: PREFER_ASM both ends (tip U-complete rename shims;
#   was ambient/-E only — header claimed PREFER but inject never set it).
# Stamp gate: tracks successful overlay so daily prefer stays cheap.
# G.7 WAVE291_ELF_CODEGEN_FORWARDERS_ALWAYS. PLATFORM: SHARED · PREFER both.
pipeline_abi_inject_elf_codegen_forwarders_thin() {
  local o="$1"
  local thin_x="src/runtime_pipeline_abi_elf_codegen_forwarders_thin.x"
  local stamp="src/.pabi_w505_elf_fwd.stamp"
  local saved_newer="${XLANG_PABI_THIN_INJECT_IF_NEWER-}"
  local saved_prefer="${XLANG_PABI_THIN_PREFER_ASM-}"
  local saved_e_repl="${XLANG_PABI_THIN_ALLOW_E_REPLACE-}"
  local had_newer=0 had_prefer=0 had_e_repl=0
  local rc=0
  [ -s "$o" ] && [ -f "$thin_x" ] || return 0
  # w836: POSIX product rest omits these faces
  # (-DXLANG_PABI_ELF_CODEGEN_FORWARDERS_ASM). A stamp skip on a fresh
  # hybrid leaves them undefined. Re-inject when the sentinel is not
  # already strong text. Old hybrids that still contain the C body stay
  # put until the rest is rebuilt. PLATFORM: SHARED.
  if [ -f "$stamp" ] && [ ! "$thin_x" -nt "$stamp" ]; then
    if pipeline_abi_strong_text_syms "$o" | grep -Eq '(^|_)pipeline_sizeof_elf_ctx$'; then
      return 0
    fi
  fi
  if [ "${XLANG_PABI_THIN_INJECT_IF_NEWER+x}" = "x" ]; then
    had_newer=1
  fi
  if [ "${XLANG_PABI_THIN_PREFER_ASM+x}" = "x" ]; then
    had_prefer=1
  fi
  if [ "${XLANG_PABI_THIN_ALLOW_E_REPLACE+x}" = "x" ]; then
    had_e_repl=1
  fi
  unset XLANG_PABI_THIN_INJECT_IF_NEWER
  # PLATFORM: SHARED — PREFER_ASM (tip U-complete @ w505 probe).
  export XLANG_PABI_THIN_PREFER_ASM=1
  export XLANG_PABI_THIN_ALLOW_E_REPLACE=1
  pipeline_abi_inject_thin_leaf "$o" "$thin_x" "w505-elf-fwd"
  rc=$?
  if [ "$had_newer" = "1" ]; then
    export XLANG_PABI_THIN_INJECT_IF_NEWER="$saved_newer"
  fi
  if [ "$had_prefer" = "1" ]; then
    export XLANG_PABI_THIN_PREFER_ASM="$saved_prefer"
  else
    unset XLANG_PABI_THIN_PREFER_ASM
  fi
  if [ "$had_e_repl" = "1" ]; then
    export XLANG_PABI_THIN_ALLOW_E_REPLACE="$saved_e_repl"
  else
    unset XLANG_PABI_THIN_ALLOW_E_REPLACE
  fi
  if [ "$rc" -eq 0 ]; then
    touch "$stamp"
    rm -f src/.pabi_w292_elf_fwd.stamp
  fi
  return "$rc"
}


try_ensure_pipeline_abi_prefer_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-pipeline-abi-prefer: need <out.o>" >&2
    exit 2
  fi
  if [ "$o" != "src/runtime_pipeline_abi.o" ]; then
    return 3
  fi
  ensure_pipeline_abi_prefer_one "$o" || return 1
  return 0
}

# ---------------------------------------------------------------------------
# wave852: try-ldpc-prefer OUT — lsp_diag_pipeline_ctx pure-asm + C tail.
#
# Nine thin aliases exist only in src/lsp/lsp_diag_pipeline_ctx.x.
# Their C bodies are deleted. The seed keeps the _impl tail and the
# 16388-byte state buffer.
#   pure_asm_x_to_o of the .x (no gcc -E)
#   G05_X_O_WEAK_FUNCS on the eight aliases plus fill_paths / write_all /
#     typeck_lsp_main / debug / apply. lsp_diag_x_alloc_dep_ctx_size stays
#     strong (live binding). Do not set G05_X_O_WEAK=1.
#   cc the seed with -DXLANG_L2_LSP_CTX_THIN_FROM_X and no unwind tables
#   pure_ld_partial_merge
# Failure leaves the previous .o and returns 1. No full-seed cc fallback.
# XLANG_G05_PREFER_X_O is ignored.
# Callers: g05_ensure · Makefile src/lsp/lsp_diag_pipeline_ctx.o.
# PLATFORM: SHARED — Darwin weaken via llvm-objcopy; Windows same path.
# ---------------------------------------------------------------------------

# True when OBJ has SYM as a weak text definition.
# PLATFORM: MACOS — nm prints a leading underscore. PLATFORM: SHARED — also
# accept the bare name.
_ldpc_nm_weak() {
  local obj="$1" sym="$2"
  nm -m "$obj" 2>/dev/null | grep -E "weak.* (_)?${sym}\$" >/dev/null
}

ensure_ldpc_prefer_one() {
  local o="$1"
  local seed="seeds/lsp_diag_pipeline_ctx.from_x.c"
  local x_src="src/lsp/lsp_diag_pipeline_ctx.x"
  local stale=0
  local thin_o rest_o merged asm_bin
  # Named weak only. alloc stays strong so --weaken-all is wrong.
  local weak_funcs="lsp_apply_default_io_policy,lsp_build_diagnostics_response,lsp_build_semantic_tokens_response,lsp_debug_report_sqpoll_env,lsp_diag_definition_at,lsp_diag_hover_at,lsp_diag_pipeline_ctx_fill_paths,lsp_diag_references_at,lsp_hover_at,lsp_io_lsp_diag_invalidate_cache,lsp_references_at,lsp_write_all,typeck_lsp_main"
  local w

  if [ ! -f "$seed" ] || [ ! -f "$x_src" ]; then
    echo "ensure_host_cc_seed_o try-ldpc-prefer: missing $x_src or $seed; C aliases are gone, no fallback" >&2
    return 1
  fi

  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    stale=0
    [ "$seed" -nt "$o" ] && stale=1
    [ "$x_src" -nt "$o" ] && stale=1
    if [ "$stale" = "0" ] && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (ldpc-prefer)"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$o")"
  if [ -x "./xlang_asm" ]; then
    asm_bin="./xlang_asm"
  elif [ -x "./xlang" ]; then
    asm_bin="./xlang"
  elif [ -x "./xlang-c" ]; then
    asm_bin="./xlang-c"
  fi
  if [ -z "$asm_bin" ]; then
    echo "ensure_host_cc_seed_o try-ldpc-prefer: no asm compiler; C aliases are gone, no fallback" >&2
    return 1
  fi

  thin_o="$(mktemp "${TMPDIR:-/tmp}/ldpc_thin.XXXXXX")"
  rest_o="$(mktemp "${TMPDIR:-/tmp}/ldpc_rest.XXXXXX")"
  merged="$(mktemp "${TMPDIR:-/tmp}/ldpc_merge.XXXXXX")"
  mv "$thin_o" "${thin_o}.o"
  mv "$rest_o" "${rest_o}.o"
  mv "$merged" "${merged}.o"
  thin_o="${thin_o}.o"
  rest_o="${rest_o}.o"
  merged="${merged}.o"

  # PLATFORM: SHARED — pure-asm only. WEAK_FUNCS does not weaken alloc.
  if ! (
    export XLANG="$asm_bin"
    export XLANG_PREFER_ASM_O=1
    export G05_X_O_WEAK_FUNCS="$weak_funcs"
    unset G05_X_O_WEAK
    pure_asm_x_to_o "$thin_o" "$x_src"
  ); then
    echo "ensure_host_cc_seed_o try-ldpc-prefer: pure-asm failed; C aliases are gone, no fallback" >&2
    rm -f "$thin_o" "$rest_o" "$merged"
    return 1
  fi
  for w in lsp_diag_hover_at lsp_diag_definition_at lsp_diag_references_at typeck_lsp_main; do
    if ! _ldpc_nm_weak "$thin_o" "$w"; then
      echo "ensure_host_cc_seed_o try-ldpc-prefer: $w is not weak; refusing install" >&2
      rm -f "$thin_o" "$rest_o" "$merged"
      return 1
    fi
  done
  if _ldpc_nm_weak "$thin_o" "lsp_diag_x_alloc_dep_ctx_size"; then
    echo "ensure_host_cc_seed_o try-ldpc-prefer: alloc must stay strong; refusing install" >&2
    rm -f "$thin_o" "$rest_o" "$merged"
    return 1
  fi

  # PLATFORM: SHARED — no unwind section, so the merge stays text-only plus
  # the state-buffer common and the tail cstring. FROM_X keeps _impl names.
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_L2_LSP_CTX_THIN_FROM_X \
       -fno-asynchronous-unwind-tables -fno-unwind-tables \
       -c -o "$rest_o" "$seed"; then
    echo "ensure_host_cc_seed_o try-ldpc-prefer: C tail cc failed; leaving previous object" >&2
    rm -f "$thin_o" "$rest_o" "$merged"
    return 1
  fi
  if ! pure_ld_partial_merge "$merged" "$thin_o" "$rest_o"; then
    echo "ensure_host_cc_seed_o try-ldpc-prefer: merge failed; leaving previous object" >&2
    rm -f "$thin_o" "$rest_o" "$merged"
    return 1
  fi
  if ! r3_prefer_nm_has_sym "$merged" "lsp_diag_x_alloc_dep_ctx_size" \
    || ! r3_prefer_nm_has_sym "$merged" "lsp_diag_pipeline_ctx_fill_paths_impl" \
    || ! r3_prefer_nm_has_sym "$merged" "g_lsp_state_buf" \
    || ! _ldpc_nm_weak "$merged" "lsp_diag_hover_at"; then
    echo "ensure_host_cc_seed_o try-ldpc-prefer: merged object failed nm gate; leaving previous object" >&2
    rm -f "$thin_o" "$rest_o" "$merged"
    return 1
  fi
  mv -f "$merged" "$o"
  rm -f "$thin_o" "$rest_o"
  log "lsp_diag_pipeline_ctx.o from $x_src (pure-asm) + C tail [w852]"
  return 0
}

try_ensure_ldpc_prefer_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-ldpc-prefer: need <out.o>" >&2
    exit 2
  fi
  if [ "$o" != "src/lsp/lsp_diag_pipeline_ctx.o" ]; then
    return 3
  fi
  ensure_ldpc_prefer_one "$o"
  return 0
}

# ---------------------------------------------------------------------------
# wave768: try-target-cpu-prefer OUT — g05 target_cpu product PREFER (single body).
#
# Single leaf: src/driver/target_cpu.o (R1_SEED_MAP; cold twin = ensure_one pure
# seed seeds/target_cpu_pure.from_x.c).
# When XLANG_G05_PREFER_X_O=1 and an xlang binary works:
#   flags.x (pending/tolower/eq5/eq6) → .o via rt_prefer_try_x_to_o
#     (G.7 有则补全: same harness as pipeline_abi/ldpc/rt; no WEAK — historic
#     g05 flags helpers are strong and rest omits them under FROM_X)
#   rest = seeds/target_cpu_pure.from_x.c under -DXLANG_L2_TARGET_CPU_FLAGS_FROM_X
#   merge: $CC -r -nostdlib flags + rest → OUT (g05 historic)
# Prefer fail / PREFER≠1 / no xlang → ensure_one cold pure seed (full TU).
# Callers: g05_ensure (wave768) · Makefile src/driver/target_cpu.o (unified).
# Exit codes:
#   0 — OUT is target_cpu.o; prefer or cold body produced OUT
#   3 — OUT is not src/driver/target_cpu.o
#   1 — cold seed missing / compile failed
# PLATFORM: SHARED shell body · g05 historic PREFER=1 · cold chain PREFER=0.
# G.7: reuses rt_prefer_try_x_to_o harness (有则补全; no second -E prologue).
# Residual after: other L2 hybrid · pure-ld · physical delete.
# ---------------------------------------------------------------------------

ensure_target_cpu_prefer_one() {
  local o="$1"
  local seed="seeds/target_cpu_pure.from_x.c"
  local flags_x="src/driver/target_cpu_flags.x"
  local pure_x="src/driver/target_cpu_pure.x"
  local hdr="include/target_cpu.h"
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local stale=0 done=0
  local thin_o rest_o

  if [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o try-target-cpu-prefer: missing seed $seed" >&2
    return 1
  fi

  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    stale=0
    [ "$seed" -nt "$o" ] && stale=1
    if [ -f "$flags_x" ] && [ "$flags_x" -nt "$o" ]; then
      stale=1
    fi
    if [ -f "$pure_x" ] && [ "$pure_x" -nt "$o" ]; then
      stale=1
    fi
    if [ -f "$hdr" ] && [ "$hdr" -nt "$o" ]; then
      stale=1
    fi
    # wave793: project-header mtime (FORCE thin; G.7 single body).
    if [ "$stale" = "0" ] && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    # wave794: Makefile flag-sensitive FORCE thin (main/runtime/pipeline_abi).
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (target-cpu-prefer)"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$o")"

  # PREFER flags.x + seed-rest only when PREFER=1 (Darwin cold-chain safety twin).
  if [ "$prefer" = "1" ] && [ -f "$flags_x" ] \
    && { [ -x ./xlang ] || [ -x ./xlang-c ] || [ -x ./bootstrap_xlangc ]; }; then
    thin_o="$(mktemp "${TMPDIR:-/tmp}/tcpu_flags.XXXXXX")"
    rest_o="$(mktemp "${TMPDIR:-/tmp}/tcpu_rest.XXXXXX")"
    # shellcheck disable=SC2086
    if rt_prefer_try_x_to_o "$flags_x" "$thin_o" \
      && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_L2_TARGET_CPU_FLAGS_FROM_X \
           -c -o "$rest_o" "$seed" \
      && pure_ld_partial_merge "$o" "$thin_o" "$rest_o" 2>/dev/null; then
      log "prefer thin+rest $o <- $flags_x + seed-rest (try-target-cpu-prefer)"
      done=1
    else
      log "target_cpu hybrid failed; fallback full seed"
    fi
    rm -f "$thin_o" "$rest_o"
  fi

  if [ "$done" = "1" ]; then
    return 0
  fi

  # Cold full pure seed (ensure_one twin / PREFER=0).
  if [ -f "$o" ] && [ "$prefer" = "1" ]; then
    FORCE=1
    ensure_one "$o" "$seed"
    FORCE=0
  else
    ensure_one "$o" "$seed"
  fi
  return 0
}

try_ensure_target_cpu_prefer_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-target-cpu-prefer: need <out.o>" >&2
    exit 2
  fi
  if [ "$o" != "src/driver/target_cpu.o" ]; then
    return 3
  fi
  ensure_target_cpu_prefer_one "$o"
  return 0
}

# ---------------------------------------------------------------------------
# wave769: try-l2-asm-prefer OUT — g05 L2 asm three thin+rest product PREFER.
#
# Table-driven single body (G.7 有则补全; no second -E prologue; reuses
# rt_prefer_try_x_to_o). Leaves (historic g05 G-02f-439/441/442 dual hybrid):
#   src/asm/user_asm_seed_bridge.o
#     x=src/asm/user_asm_seed_bridge.x
#     seed=seeds/user_asm_seed_bridge.from_x.c
#     rest -D=XLANG_USER_ASM_SEED_BRIDGE_FROM_X
#     rest -I=default
#   src/asm/backend_x86_64_enc_c.o
#     x=src/asm/backend_x86_64_enc_c.x
#     seed=seeds/backend_x86_64_enc_c.from_x.c
#     rest -D=XLANG_BACKEND_X86_64_ENC_C_FROM_X
#     rest -I=default
#   src/asm/asm_backend_compat_stubs.o
#     x=src/asm/asm_backend_compat_stubs.x
#     seed=seeds/asm_backend_compat_stubs.from_x.c
#     rest -D=XLANG_ASM_BACKEND_COMPAT_STUBS_FROM_X
#     rest -I=default + -Isrc/asm -Isrc/lexer
# When XLANG_G05_PREFER_X_O=1 and an xlang binary works:
#   thin .x → .o via rt_prefer_try_x_to_o (no WEAK — historic g05 strong thin)
#   rest = seed under FROM_X -D (+ optional -I)
#   merge: $CC -r -nostdlib thin + rest → OUT
# Prefer fail / PREFER≠1 / no xlang → ensure_one cold plain seed.
# Callers: g05_ensure (wave769) · Makefile three leaves (was ensure one cold).
# Exit codes:
#   0 — OUT is a table member; prefer or cold body produced OUT
#   3 — OUT is not in the L2 asm prefer table
#   1 — cold seed missing / compile failed
# PLATFORM: SHARED shell body · g05 historic PREFER=1 · cold chain PREFER=0.
# Residual after: ~~async three~~ (wave770) · other L2 (seed_link_compat /
#   strict_glue / fmt_check / lsp_diag…) · pure-ld · physical delete.
# ---------------------------------------------------------------------------

# Resolve OUT → seed|x_src|from_x_def|rest_extra_incs (pipe-separated).
# Empty string means non-member.
l2_asm_prefer_spec_for_out() {
  case "$1" in
    src/asm/user_asm_seed_bridge.o)
      printf '%s' "seeds/user_asm_seed_bridge.from_x.c|src/asm/user_asm_seed_bridge.x|XLANG_USER_ASM_SEED_BRIDGE_FROM_X|"
      ;;
    src/asm/backend_x86_64_enc_c.o)
      printf '%s' "seeds/backend_x86_64_enc_c.from_x.c|src/asm/backend_x86_64_enc_c.x|XLANG_BACKEND_X86_64_ENC_C_FROM_X|"
      ;;
    src/asm/asm_backend_compat_stubs.o)
      printf '%s' "seeds/asm_backend_compat_stubs.from_x.c|src/asm/asm_backend_compat_stubs.x|XLANG_ASM_BACKEND_COMPAT_STUBS_FROM_X|-Isrc/asm -Isrc/lexer"
      ;;
    *)
      printf '%s' ""
      ;;
  esac
}

ensure_l2_asm_prefer_one() {
  local o="$1"
  local spec seed x_src from_x_def rest_extra rest
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local stale=0 done=0
  local thin_o rest_o

  spec="$(l2_asm_prefer_spec_for_out "$o")"
  if [ -z "$spec" ]; then
    return 3
  fi
  seed="${spec%%|*}"
  rest="${spec#*|}"
  x_src="${rest%%|*}"
  rest="${rest#*|}"
  from_x_def="${rest%%|*}"
  rest_extra="${rest#*|}"

  if [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o try-l2-asm-prefer: missing seed $seed for $o" >&2
    return 1
  fi

  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    stale=0
    [ "$seed" -nt "$o" ] && stale=1
    if [ -f "$x_src" ] && [ "$x_src" -nt "$o" ]; then
      stale=1
    fi
    # wave793: project-header mtime (FORCE thin; G.7 single body).
    if [ "$stale" = "0" ] && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    # wave794: Makefile flag-sensitive FORCE thin (main/runtime/pipeline_abi).
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (l2-asm-prefer)"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$o")"

  # PREFER thin.x + seed-rest only when PREFER=1 (Darwin cold-chain safety twin).
  if [ "$prefer" = "1" ] && [ -f "$x_src" ] \
    && { [ -x ./xlang ] || [ -x ./xlang-c ] || [ -x ./bootstrap_xlangc ]; }; then
    thin_o="$(mktemp "${TMPDIR:-/tmp}/l2asm_thin.XXXXXX")"
    rest_o="$(mktemp "${TMPDIR:-/tmp}/l2asm_rest.XXXXXX")"
    # shellcheck disable=SC2086
    if rt_prefer_try_x_to_o "$x_src" "$thin_o" \
      && $CC $BASE_CFLAGS -I. -Iinclude -Isrc $rest_extra -D"$from_x_def" \
           -c -o "$rest_o" "$seed" \
      && pure_ld_partial_merge "$o" "$thin_o" "$rest_o" 2>/dev/null; then
      log "prefer thin+rest $o <- $x_src + seed-rest (try-l2-asm-prefer)"
      done=1
    else
      log "l2-asm hybrid failed for $o; fallback full seed"
    fi
    rm -f "$thin_o" "$rest_o"
  fi

  if [ "$done" = "1" ]; then
    return 0
  fi

  # Cold full seed (ensure_one twin / PREFER=0).
  if [ -f "$o" ] && [ "$prefer" = "1" ]; then
    FORCE=1
    ensure_one "$o" "$seed"
    FORCE=0
  else
    ensure_one "$o" "$seed"
  fi
  return 0
}

try_ensure_l2_asm_prefer_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-l2-asm-prefer: need <out.o>" >&2
    exit 2
  fi
  if [ -z "$(l2_asm_prefer_spec_for_out "$o")" ]; then
    return 3
  fi
  ensure_l2_asm_prefer_one "$o"
  return 0
}

# ---------------------------------------------------------------------------
# wave770: try-async-prefer OUT — g05 async three full.x+rest product PREFER.
#
# Table-driven single body (G.7 有则补全; no second -E prologue; reuses
# rt_prefer_try_x_to_o). Leaves (historic g05 R2 dual hybrid / glue unbundle):
#   src/async/async_liveness.o
#     x=src/async/async_liveness.x
#     seed=seeds/async_liveness.from_x.c
#     rest -D=XLANG_ASYNC_LIVENESS_FROM_X
#   src/async/async_cps_codegen.o
#     x=src/async/async_cps_codegen.x
#     seed=seeds/async_cps_codegen.from_x.c
#     rest -D=XLANG_ASYNC_CPS_CODEGEN_FROM_X
#   src/async/async_asm_pool.o
#     x=src/asm/async_asm_pool.x
#     seed=seeds/async_asm_pool.from_x.c
#     rest -D=XLANG_ASYNC_ASM_POOL_FROM_X
# When XLANG_G05_PREFER_X_O=1 and an xlang binary works:
#   full .x → .o via rt_prefer_try_x_to_o (no WEAK — historic g05 strong thin)
#   rest = seed under FROM_X -D (slice_marker only)
#   merge: $CC -r -nostdlib thin + rest → OUT
# Prefer fail / PREFER≠1 / no xlang → ensure_one cold plain seed.
# Stage 12.0.5 pure-asm hybrid (opt-in PREFER_ASM_O; not product-default):
#   pure_asm standalone 3/3 (div0 FAIL_ABI residual closed) · FORCE try-async-prefer
#   pure-asm thin+rest · soft g05 pure-ld · matrix 5/5 · restore -E 5/5
#   dual-end @ tip 190ab4eb3 (mac + Ubuntu gold). No WEAK polish needed.
# Callers: g05_ensure (wave770) · Makefile three leaves (was dual hybrid).
# Exit codes:
#   0 — OUT is a table member; prefer or cold body produced OUT
#   3 — OUT is not in the async prefer table
#   1 — cold seed missing / compile failed
# PLATFORM: SHARED shell body · g05 historic PREFER=1 · cold chain PREFER=0.
# Residual after: other L2 (seed_link_compat / strict_glue / fmt_check /
#   lsp_diag…) · pure-ld · physical delete.
# ---------------------------------------------------------------------------

# Resolve OUT → seed|x_src|from_x_def (pipe-separated). Empty = non-member.
async_prefer_spec_for_out() {
  case "$1" in
    src/async/async_liveness.o)
      printf '%s' "seeds/async_liveness.from_x.c|src/async/async_liveness.x|XLANG_ASYNC_LIVENESS_FROM_X"
      ;;
    src/async/async_cps_codegen.o)
      printf '%s' "seeds/async_cps_codegen.from_x.c|src/async/async_cps_codegen.x|XLANG_ASYNC_CPS_CODEGEN_FROM_X"
      ;;
    src/async/async_asm_pool.o)
      printf '%s' "seeds/async_asm_pool.from_x.c|src/asm/async_asm_pool.x|XLANG_ASYNC_ASM_POOL_FROM_X"
      ;;
    *)
      printf '%s' ""
      ;;
  esac
}

ensure_async_prefer_one() {
  local o="$1"
  local spec seed x_src from_x_def rest
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local stale=0 done=0
  local thin_o rest_o

  spec="$(async_prefer_spec_for_out "$o")"
  if [ -z "$spec" ]; then
    return 3
  fi
  seed="${spec%%|*}"
  rest="${spec#*|}"
  x_src="${rest%%|*}"
  from_x_def="${rest#*|}"

  if [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o try-async-prefer: missing seed $seed for $o" >&2
    return 1
  fi

  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    stale=0
    [ "$seed" -nt "$o" ] && stale=1
    if [ -f "$x_src" ] && [ "$x_src" -nt "$o" ]; then
      stale=1
    fi
    # wave793: project-header mtime (FORCE thin; G.7 single body).
    if [ "$stale" = "0" ] && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    # wave794: Makefile flag-sensitive FORCE thin (main/runtime/pipeline_abi).
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (async-prefer)"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$o")"

  # PREFER full .x + seed-rest only when PREFER=1 (Darwin cold-chain safety twin).
  if [ "$prefer" = "1" ] && [ -f "$x_src" ] \
    && { [ -x ./xlang ] || [ -x ./xlang-c ] || [ -x ./bootstrap_xlangc ]; }; then
    thin_o="$(mktemp "${TMPDIR:-/tmp}/async_thin.XXXXXX")"
    rest_o="$(mktemp "${TMPDIR:-/tmp}/async_rest.XXXXXX")"
    # shellcheck disable=SC2086
    if rt_prefer_try_x_to_o "$x_src" "$thin_o" \
      && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -D"$from_x_def" \
           -c -o "$rest_o" "$seed" \
      && pure_ld_partial_merge "$o" "$thin_o" "$rest_o" 2>/dev/null; then
      log "prefer full.x+rest $o <- $x_src + seed-rest (try-async-prefer)"
      done=1
    else
      log "async hybrid failed for $o; fallback full seed"
    fi
    rm -f "$thin_o" "$rest_o"
  fi

  if [ "$done" = "1" ]; then
    return 0
  fi

  # Cold full seed (ensure_one twin / PREFER=0).
  if [ -f "$o" ] && [ "$prefer" = "1" ]; then
    FORCE=1
    ensure_one "$o" "$seed"
    FORCE=0
  else
    ensure_one "$o" "$seed"
  fi
  return 0
}

try_ensure_async_prefer_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-async-prefer: need <out.o>" >&2
    exit 2
  fi
  if [ -z "$(async_prefer_spec_for_out "$o")" ]; then
    return 3
  fi
  ensure_async_prefer_one "$o"
  return 0
}

# ---------------------------------------------------------------------------
# wave771 + wave775: try-other-l2-prefer OUT — other L2 thin+rest PREFER table.
#
# Table-driven single body (G.7 有则补全; reuses rt_prefer_try_x_to_o).
# Leaves (historic dual hybrid; special prologues/weak sed):
#   src/seed_link_compat.o
#     x=src/seed_link_compat.x  seed=seeds/seed_link_compat.from_x.c
#     rest -D=XLANG_SEED_LINK_COMPAT_FROM_X + -Isrc/asm -Isrc/lexer
#     thin: G05_X_O_WEAK_FUNCS=6 lsp/typeck stubs (not WEAK=all)
#   src/runtime_driver_strict_glue_stubs.o
#     x=src/runtime_driver_strict_glue_thin.x
#     seed=seeds/runtime_driver_strict_glue_stubs.from_x.c
#     rest -D=XLANG_L2_STRICT_GLUE_THIN_FROM_X
#     thin: G05_X_O_WEAK=1; stale also on seeds/runtime_heap_user.from_x.c
#   src/driver/fmt_check_cmd_driver.o
#     x=src/driver/fmt_check_cmd_thin.x  seed=seeds/fmt_check_cmd.from_x.c
#     rest -D=XLANG_L2_FMT_CHECK_THIN_FROM_X -DXLANG_USE_X_PIPELINE
#     thin: G05_X_O_WEAK=1; cold seed also -DXLANG_USE_X_PIPELINE
#   src/driver/fmt_check_cmd.o  (wave775 · non-driver OBJS_CORE / PIPELINE_X)
#     same thin.x + seed; rest -D=XLANG_L2_FMT_CHECK_THIN_FROM_X only
#     leaf_kind=fmt_core — NO -DXLANG_USE_X_PIPELINE (runtime_x lacks USE_X_DRIVER;
#     fmt/check must stay on run_compiler_c stubs)
#   src/lsp/lsp_diag.o
#     x=src/asm/runtime_lsp_glue.x  seed=seeds/runtime_lsp_glue.from_x.c
#     rest -D=XLANG_L2_LSP_GLUE_FULL_FROM_X
#     thin: G05_X_O_WEAK=1
# Prefer fail / PREFER≠1 / no xlang → ensure_one cold (fmt keeps USE_X_PIPELINE).
# Callers: g05_ensure (wave771 four) · Makefile five leaves (wave775 adds fmt.o).
# Exit codes:
#   0 — OUT is a table member; prefer or cold body produced OUT
#   3 — OUT is not in the other-L2 prefer table
#   1 — cold seed missing / compile failed
# PLATFORM: SHARED shell body · g05 historic PREFER=1 · cold chain PREFER=0.
# Residual after: physical delete · panic PREFER (if any).
# ---------------------------------------------------------------------------

# Resolve OUT → seed|x_src|from_x_def|weak_mode|leaf_kind (pipe-separated).
# weak_mode: slc6 | weak
# leaf_kind: slc | strict | fmt | fmt_core | lsp  (rest/cold extras + extra stale)
other_l2_prefer_spec_for_out() {
  case "$1" in
    src/seed_link_compat.o)
      printf '%s' "seeds/seed_link_compat.from_x.c|src/seed_link_compat.x|XLANG_SEED_LINK_COMPAT_FROM_X|slc6|slc"
      ;;
    src/runtime_driver_strict_glue_stubs.o)
      printf '%s' "seeds/runtime_driver_strict_glue_stubs.from_x.c|src/runtime_driver_strict_glue_thin.x|XLANG_L2_STRICT_GLUE_THIN_FROM_X|weak|strict"
      ;;
    src/driver/fmt_check_cmd_driver.o)
      printf '%s' "seeds/fmt_check_cmd.from_x.c|src/driver/fmt_check_cmd_thin.x|XLANG_L2_FMT_CHECK_THIN_FROM_X|weak|fmt"
      ;;
    src/driver/fmt_check_cmd.o)
      # wave775: non-driver dual → same prefer body; no USE_X_PIPELINE.
      printf '%s' "seeds/fmt_check_cmd.from_x.c|src/driver/fmt_check_cmd_thin.x|XLANG_L2_FMT_CHECK_THIN_FROM_X|weak|fmt_core"
      ;;
    src/lsp/lsp_diag.o)
      printf '%s' "seeds/runtime_lsp_glue.from_x.c|src/asm/runtime_lsp_glue.x|XLANG_L2_LSP_GLUE_FULL_FROM_X|weak|lsp"
      ;;
    *)
      printf '%s' ""
      ;;
  esac
}

# Historic G-02f-440: six weak stubs overridden by lsp_diag_x / pipeline_ctx.
# slc6 historic lsp/typeck stubs + std_sys_read_file_into (seed from_x.c already
# XLANG_WEAK; prefer thin .x must match). Without weak, strong dual vs driver_x
# monomorphized std.sys fails Darwin pure-ld (ld64 multidef obsolete).
# PLATFORM: SHARED — G.7 seed face weak; product mono in driver_x wins.
_OTHER_L2_SLC_WEAK_FUNCS="lsp_diag_lsp_build_diagnostics_response,lsp_diag_lsp_build_semantic_tokens_response,lsp_diag_hover_at,lsp_diag_references_at,lsp_diag_definition_at,typeck_lsp_main_impl,std_sys_read_file_into"

ensure_other_l2_prefer_one() {
  local o="$1"
  local spec seed x_src from_x_def weak_mode leaf_kind rest
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local stale=0 done=0
  local thin_o rest_o
  local rest_extra="" cold_extra=()

  spec="$(other_l2_prefer_spec_for_out "$o")"
  if [ -z "$spec" ]; then
    return 3
  fi
  seed="${spec%%|*}"
  rest="${spec#*|}"
  x_src="${rest%%|*}"
  rest="${rest#*|}"
  from_x_def="${rest%%|*}"
  rest="${rest#*|}"
  weak_mode="${rest%%|*}"
  leaf_kind="${rest#*|}"

  if [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o try-other-l2-prefer: missing seed $seed for $o" >&2
    return 1
  fi

  case "$leaf_kind" in
    slc) rest_extra="-Isrc/asm -Isrc/lexer" ;;
    fmt)
      # driver leaf: rest + cold need -DXLANG_USE_X_PIPELINE (product pipeline).
      rest_extra="-DXLANG_USE_X_PIPELINE"
      cold_extra=(-DXLANG_USE_X_PIPELINE)
      ;;
    fmt_core)
      # wave775 non-driver: OBJS_CORE / PIPELINE_X satellite — seed/thin only;
      # no USE_X_PIPELINE (avoids missing driver_run_compiler_full on runtime_x).
      ;;
    strict|lsp) ;;
    *)
      echo "ensure_host_cc_seed_o try-other-l2-prefer: unknown leaf_kind $leaf_kind" >&2
      return 1
      ;;
  esac

  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    stale=0
    [ "$seed" -nt "$o" ] && stale=1
    if [ -f "$x_src" ] && [ "$x_src" -nt "$o" ]; then
      stale=1
    fi
    # strict_glue seed #includes runtime_heap_user — refresh when heap seed newer.
    if [ "$leaf_kind" = "strict" ] \
      && [ -f seeds/runtime_heap_user.from_x.c ] \
      && [ seeds/runtime_heap_user.from_x.c -nt "$o" ]; then
      stale=1
    fi
    # wave793: project-header mtime (FORCE thin; G.7 single body).
    if [ "$stale" = "0" ] && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    # wave794: Makefile flag-sensitive FORCE thin (main/runtime/pipeline_abi).
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (other-l2-prefer)"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$o")"

  # PREFER thin/full .x + seed-rest only when PREFER=1 (Darwin cold-chain twin).
  if [ "$prefer" = "1" ] && [ -f "$x_src" ] \
    && { [ -x ./xlang ] || [ -x ./xlang-c ] || [ -x ./bootstrap_xlangc ]; }; then
    thin_o="$(mktemp "${TMPDIR:-/tmp}/ol2_thin.XXXXXX")"
    rest_o="$(mktemp "${TMPDIR:-/tmp}/ol2_rest.XXXXXX")"
    _thin_ok=0
    case "$weak_mode" in
      slc6)
        if G05_X_O_WEAK_FUNCS="$_OTHER_L2_SLC_WEAK_FUNCS" \
          rt_prefer_try_x_to_o "$x_src" "$thin_o"; then
          _thin_ok=1
        fi
        ;;
      weak)
        if G05_X_O_WEAK=1 rt_prefer_try_x_to_o "$x_src" "$thin_o"; then
          _thin_ok=1
        fi
        ;;
      *)
        if rt_prefer_try_x_to_o "$x_src" "$thin_o"; then
          _thin_ok=1
        fi
        ;;
    esac
    # shellcheck disable=SC2086
    if [ "$_thin_ok" = "1" ] \
      && $CC $BASE_CFLAGS -I. -Iinclude -Isrc $rest_extra -D"$from_x_def" \
           -c -o "$rest_o" "$seed" \
      && pure_ld_partial_merge "$o" "$thin_o" "$rest_o" 2>/dev/null; then
      log "prefer thin.x+rest $o <- $x_src + seed-rest (try-other-l2-prefer/$leaf_kind)"
      done=1
    else
      log "other-l2 hybrid failed for $o ($leaf_kind); fallback full seed"
    fi
    rm -f "$thin_o" "$rest_o"
  fi

  if [ "$done" = "1" ]; then
    return 0
  fi

  # Cold full seed (ensure_one twin / PREFER=0). fmt keeps USE_X_PIPELINE.
  if [ -f "$o" ] && [ "$prefer" = "1" ]; then
    FORCE=1
    ensure_one "$o" "$seed" "${cold_extra[@]+"${cold_extra[@]}"}"
    FORCE=0
  else
    ensure_one "$o" "$seed" "${cold_extra[@]+"${cold_extra[@]}"}"
  fi
  return 0
}

try_ensure_other_l2_prefer_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-other-l2-prefer: need <out.o>" >&2
    exit 2
  fi
  if [ -z "$(other_l2_prefer_spec_for_out "$o")" ]; then
    return 3
  fi
  ensure_other_l2_prefer_one "$o"
  return 0
}

# ---------------------------------------------------------------------------
# wave779: try-runtime-os-prefer OUT — B1 runtime_* OS/glue dual hybrid table.
#
# Table-driven single body (G.7 有则补全; reuses rt_prefer_try_x_to_o).
# 23 top-level runtime_*.o leaves that still had Makefile thin+rest PREFER dual
# (test_fn_invoke … process_os_glue). NOT physical delete — Makefile keeps
# thin-call edges + prereqs.
#
# Spec: seed|x_src|from_x_def|leaf_kind
# leaf_kind:
#   std          — default -I. -Iinclude -Isrc only
#   http         — rest/cold + -Iseeds/http; x under src/asm/http/
#   ed25519      — rest/cold + -Isrc/asm
#   tls          — rest/cold try homebrew mbedtls -I then plain (PLATFORM: MACOS
#                  homebrew path optional; LINUX often plain)
#   net_udp      — PLATFORM: LINUX only PREFER; non-Linux always cold seed
# Prefer fail / PREFER≠1 / no xlang → ensure_one cold (with leaf extras).
# Callers: Makefile 23 leaves (wave779).
# Exit codes:
#   0 — OUT is a table member; prefer or cold body produced OUT
#   3 — OUT is not in the runtime-os prefer table
#   1 — cold seed missing / compile failed
# PLATFORM: SHARED shell body · g05 historic PREFER=1 · cold chain PREFER=0.
# Residual after: B2–B5 · physical delete · R5.
# ---------------------------------------------------------------------------

# Resolve OUT → seed|x_src|from_x_def|leaf_kind (pipe-separated).
runtime_os_prefer_spec_for_out() {
  case "$1" in
    runtime_test_fn_invoke.o)
      printf '%s' "seeds/runtime_test_fn_invoke.from_x.c|src/asm/runtime_test_fn_invoke.x|XLANG_RUNTIME_TEST_FN_INVOKE_FROM_X|std"
      ;;
    runtime_random_fill.o)
      printf '%s' "seeds/runtime_random_fill.from_x.c|src/asm/runtime_random_fill.x|XLANG_RUNTIME_RANDOM_FILL_FROM_X|std"
      ;;
    runtime_compress_zlib_glue.o)
      printf '%s' "seeds/runtime_compress_zlib_glue.from_x.c|src/asm/runtime_compress_zlib_glue.x|XLANG_RUNTIME_COMPRESS_ZLIB_GLUE_FROM_X|std"
      ;;
    runtime_time_os.o)
      printf '%s' "seeds/runtime_time_os.from_x.c|src/asm/runtime_time_os.x|XLANG_RUNTIME_TIME_OS_FROM_X|std"
      ;;
    runtime_queue_contention.o)
      printf '%s' "seeds/runtime_queue_contention.from_x.c|src/asm/runtime_queue_contention.x|XLANG_RUNTIME_QUEUE_CONTENTION_FROM_X|std"
      ;;
    runtime_dynlib_os.o)
      printf '%s' "seeds/runtime_dynlib_os.from_x.c|src/asm/runtime_dynlib_os.x|XLANG_RUNTIME_DYNLIB_OS_FROM_X|std"
      ;;
    runtime_env_os.o)
      printf '%s' "seeds/runtime_env_os.from_x.c|src/asm/runtime_env_os.x|XLANG_RUNTIME_ENV_OS_FROM_X|std"
      ;;
    runtime_backtrace_platform.o)
      printf '%s' "seeds/runtime_backtrace_platform.from_x.c|src/asm/runtime_backtrace_platform.x|XLANG_RUNTIME_BACKTRACE_PLATFORM_FROM_X|std"
      ;;
    runtime_log_os.o)
      printf '%s' "seeds/runtime_log_os.from_x.c|src/asm/runtime_log_os.x|XLANG_RUNTIME_LOG_OS_FROM_X|std"
      ;;
    runtime_math_libm.o)
      printf '%s' "seeds/runtime_math_libm.from_x.c|src/asm/runtime_math_libm.x|XLANG_RUNTIME_MATH_LIBM_FROM_X|std"
      ;;
    runtime_atomic_glue.o)
      printf '%s' "seeds/runtime_atomic_glue.from_x.c|src/asm/runtime_atomic_glue.x|XLANG_RUNTIME_ATOMIC_GLUE_FROM_X|std"
      ;;
    runtime_net_udp_batch.o)
      # PLATFORM: LINUX — PREFER gated in ensure body; macOS cold = empty TU.
      printf '%s' "seeds/runtime_net_udp_batch.from_x.c|src/asm/runtime_net_udp_batch.x|XLANG_RUNTIME_NET_UDP_BATCH_FROM_X|net_udp"
      ;;
    runtime_net_workers.o)
      printf '%s' "seeds/runtime_net_workers.from_x.c|src/asm/runtime_net_workers.x|XLANG_RUNTIME_NET_WORKERS_FROM_X|std"
      ;;
    runtime_sync_os.o)
      printf '%s' "seeds/runtime_sync_os.from_x.c|src/asm/runtime_sync_os.x|XLANG_RUNTIME_SYNC_OS_FROM_X|std"
      ;;
    runtime_sync_lock_diag_tls.o)
      printf '%s' "seeds/runtime_sync_lock_diag_tls.from_x.c|src/asm/runtime_sync_lock_diag_tls.x|XLANG_RUNTIME_SYNC_LOCK_DIAG_TLS_FROM_X|std"
      ;;
    runtime_thread_glue.o)
      printf '%s' "seeds/runtime_thread_glue.from_x.c|src/asm/runtime_thread_glue.x|XLANG_RUNTIME_THREAD_GLUE_FROM_X|std"
      ;;
    runtime_http_glue.o)
      printf '%s' "seeds/runtime_http_glue.from_x.c|src/asm/http/runtime_http_glue.x|XLANG_RUNTIME_HTTP_GLUE_FROM_X|http"
      ;;
    runtime_tls_mbedtls_bio.o)
      # PLATFORM: MACOS homebrew mbedtls -I optional; LINUX often plain.
      printf '%s' "seeds/runtime_tls_mbedtls_bio.from_x.c|src/asm/runtime_tls_mbedtls_bio.x|XLANG_RUNTIME_TLS_MBEDTLS_BIO_FROM_X|tls"
      ;;
    runtime_arrow_simd_glue.o)
      printf '%s' "seeds/runtime_arrow_simd_glue.from_x.c|src/asm/runtime_arrow_simd_glue.x|XLANG_RUNTIME_ARROW_SIMD_GLUE_FROM_X|std"
      ;;
    runtime_crypto_inc_glue.o)
      printf '%s' "seeds/runtime_crypto_inc_glue.from_x.c|src/asm/runtime_crypto_inc_glue.x|XLANG_RUNTIME_CRYPTO_INC_GLUE_FROM_X|std"
      ;;
    runtime_ed25519_ref10_glue.o)
      printf '%s' "seeds/runtime_ed25519_ref10_glue.from_x.c|src/asm/runtime_ed25519_ref10_glue.x|XLANG_RUNTIME_ED25519_REF10_GLUE_FROM_X|ed25519"
      ;;
    runtime_process_argv.o)
      printf '%s' "seeds/runtime_process_argv.from_x.c|src/asm/runtime_process_argv.x|XLANG_RUNTIME_PROCESS_ARGV_FROM_X|std"
      ;;
    runtime_process_os_glue.o)
      printf '%s' "seeds/runtime_process_os_glue.from_x.c|src/asm/runtime_process_os_glue.x|XLANG_RUNTIME_PROCESS_OS_GLUE_FROM_X|std"
      ;;
    *)
      printf '%s' ""
      ;;
  esac
}

# Compile rest/cold seed with leaf extras. stdout unused; sets rest_o/out via args.
# $1=out_o  $2=seed  $3=from_x_def_or_empty  $4=leaf_kind
# from_x_def empty → cold path (no FROM_X).
_runtime_os_cc_seed() {
  local out_o="$1" seed="$2" from_x_def="$3" leaf_kind="$4"
  local def_flag=() rest_extra=()
  if [ -n "$from_x_def" ]; then
    def_flag=(-D"$from_x_def")
  fi
  case "$leaf_kind" in
    http) rest_extra=(-Iseeds/http) ;;
    ed25519) rest_extra=(-Isrc/asm) ;;
    tls)
      # PLATFORM: MACOS — try homebrew mbedtls include first; fall back plain.
      # shellcheck disable=SC2086
      if $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
           -I/opt/homebrew/opt/mbedtls/include \
           "${def_flag[@]+"${def_flag[@]}"}" \
           -c -o "$out_o" "$seed" 2>/dev/null; then
        return 0
      fi
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
        "${def_flag[@]+"${def_flag[@]}"}" \
        -c -o "$out_o" "$seed"
      return $?
      ;;
    std|net_udp) ;;
    *)
      echo "ensure_host_cc_seed_o try-runtime-os-prefer: unknown leaf_kind $leaf_kind" >&2
      return 1
      ;;
  esac
  # shellcheck disable=SC2086
  $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
    "${rest_extra[@]+"${rest_extra[@]}"}" \
    "${def_flag[@]+"${def_flag[@]}"}" \
    -c -o "$out_o" "$seed"
}

ensure_runtime_os_prefer_one() {
  local o="$1"
  local spec seed x_src from_x_def leaf_kind rest
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local stale=0 done=0
  local thin_o rest_o uname_s

  spec="$(runtime_os_prefer_spec_for_out "$o")"
  if [ -z "$spec" ]; then
    return 3
  fi
  seed="${spec%%|*}"
  rest="${spec#*|}"
  x_src="${rest%%|*}"
  rest="${rest#*|}"
  from_x_def="${rest%%|*}"
  leaf_kind="${rest#*|}"

  if [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o try-runtime-os-prefer: missing seed $seed for $o" >&2
    return 1
  fi

  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    stale=0
    [ "$seed" -nt "$o" ] && stale=1
    if [ -f "$x_src" ] && [ "$x_src" -nt "$o" ]; then
      stale=1
    fi
    # wave793: project-header mtime (FORCE thin; G.7 single body).
    if [ "$stale" = "0" ] && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    # wave794: Makefile flag-sensitive FORCE thin (main/runtime/pipeline_abi).
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (runtime-os-prefer)"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$o")"

  # PLATFORM: LINUX — net_udp PREFER only on Linux (macOS cold = empty .o).
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  _do_prefer=0
  if [ "$prefer" = "1" ] && [ -f "$x_src" ] \
    && { [ -x ./xlang ] || [ -x ./xlang-c ] || [ -x ./bootstrap_xlangc ]; }; then
    if [ "$leaf_kind" = "net_udp" ] && [ "$uname_s" != "Linux" ]; then
      _do_prefer=0
    else
      _do_prefer=1
    fi
  fi

  if [ "$_do_prefer" = "1" ]; then
    thin_o="$(mktemp "${TMPDIR:-/tmp}/rtos_thin.XXXXXX")"
    rest_o="$(mktemp "${TMPDIR:-/tmp}/rtos_rest.XXXXXX")"
    if rt_prefer_try_x_to_o "$x_src" "$thin_o" \
      && _runtime_os_cc_seed "$rest_o" "$seed" "$from_x_def" "$leaf_kind" \
      && pure_ld_partial_merge "$o" "$thin_o" "$rest_o" 2>/dev/null; then
      log "prefer thin.x+rest $o <- $x_src + seed-rest (try-runtime-os-prefer/$leaf_kind)"
      done=1
    else
      log "runtime-os hybrid failed for $o ($leaf_kind); fallback full seed"
    fi
    rm -f "$thin_o" "$rest_o"
  fi

  if [ "$done" = "1" ]; then
    return 0
  fi

  # Cold full seed (ensure_one twin / PREFER=0 / net_udp non-Linux).
  # tls needs mbedtls fallback — use _runtime_os_cc_seed for cold too.
  if [ "$leaf_kind" = "tls" ] || [ "$leaf_kind" = "http" ] || [ "$leaf_kind" = "ed25519" ]; then
    if [ -f "$o" ] && [ "$prefer" = "1" ]; then
      FORCE=1
    fi
    if [ "$FORCE" = "1" ] || [ ! -f "$o" ] || [ "$seed" -nt "$o" ] \
      || { [ -f "$x_src" ] && [ "$x_src" -nt "$o" ]; }; then
      _runtime_os_cc_seed "$o" "$seed" "" "$leaf_kind" || return 1
      log "cold seed $o <- $seed (try-runtime-os-prefer/$leaf_kind)"
    else
      log "skip up-to-date $o (runtime-os-prefer cold)"
    fi
    FORCE="${XLANG_HOST_CC_SEED_FORCE:-0}"
    return 0
  fi

  if [ -f "$o" ] && [ "$prefer" = "1" ]; then
    FORCE=1
    ensure_one "$o" "$seed"
    FORCE=0
  else
    ensure_one "$o" "$seed"
  fi
  return 0
}

try_ensure_runtime_os_prefer_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-runtime-os-prefer: need <out.o>" >&2
    exit 2
  fi
  if [ -z "$(runtime_os_prefer_spec_for_out "$o")" ]; then
    return 3
  fi
  ensure_runtime_os_prefer_one "$o"
  return 0
}



# ---------------------------------------------------------------------------
# wave780: try-std-core-prefer OUT — B2 std/core product hybrid table.
#
# Table-driven single body (G.7 有则补全). Five product leaves that still had
# Makefile inline host-cc / PREFER hybrid (process · path · runtime · net ·
# core/slice glue). NOT physical delete — Makefile keeps thin-call edges + prereqs.
#
# leaf_kind:
#   direct        — R2 DIRECT: PREFER=1 + xlang-c → -lib-name "" -o OUT from .x;
#                   else / fail → cold seed (path / runtime / slice)
#   process_merge — cold only: cc args_thin seed + ld -r with runtime_process_argv.o
#                   + runtime_process_os_glue.o (B1 already try-runtime-os-prefer)
#   net_merge     — multi sub .x + net_*_fast PREFER thin+rest + final ld -r
#                   PLATFORM: MACOS force xlang-c for net submodules (dead_strip UNDEF)
# Prefer fail / PREFER≠1 / no xlang → cold seed (direct) or process/net cold path.
# Callers: Makefile 5 leaves (wave780).
# Exit codes:
#   0 — OUT is a table member; body produced OUT
#   3 — OUT is not in the std-core prefer table
#   1 — seed missing / compile failed
# PLATFORM: SHARED shell body · g05 historic PREFER=1 · cold chain PREFER=0.
# Residual after: B3–B5 · physical delete · R5.
# ---------------------------------------------------------------------------

# Normalize OUT path variants to a canonical key used by the table.
# Accepts: ../std/path/path.o | std/path/path.o | absolute …/std/path/path.o
std_core_prefer_key_for_out() {
  local o="$1"
  case "$o" in
    ../std/process/process.o|std/process/process.o|*std/process/process.o)
      printf '%s' "std/process/process.o" ;;
    ../std/path/path.o|std/path/path.o|*std/path/path.o)
      printf '%s' "std/path/path.o" ;;
    ../std/runtime/runtime.o|std/runtime/runtime.o|*std/runtime/runtime.o)
      printf '%s' "std/runtime/runtime.o" ;;
    ../std/net/net.o|std/net/net.o|*std/net/net.o)
      printf '%s' "std/net/net.o" ;;
    ../core/slice/slice.o|core/slice/slice.o|*core/slice/slice.o)
      printf '%s' "core/slice/slice.o" ;;
    *)
      printf '%s' ""
      ;;
  esac
}

# Spec: seed|x_src|leaf_kind
std_core_prefer_spec_for_out() {
  local key
  key="$(std_core_prefer_key_for_out "$1")"
  case "$key" in
    std/path/path.o)
      printf '%s' "seeds/runtime_path_fast.from_x.c|src/asm/runtime_path_fast.x|direct"
      ;;
    std/runtime/runtime.o)
      printf '%s' "seeds/runtime_std_runtime_fast.from_x.c|src/asm/runtime_std_runtime_fast.x|direct"
      ;;
    core/slice/slice.o)
      printf '%s' "seeds/runtime_slice_glue.from_x.c|src/asm/runtime_slice_glue.x|direct"
      ;;
    std/process/process.o)
      # 7.2.1 fourth knife: .x authority (src/runtime_process_args_thin.x)
      # via product -x -E into a stable gen; seed remains the no-product
      # cold fallback.
      if [ -x ./xlang_asm ] || [ -x ./xlang ] || [ -x ./xlang-c ]; then
        printf '%s' "runtime_process_args_thin_gen.c|src/runtime_process_args_thin.x|process_merge"
      else
        printf '%s' "seeds/runtime_process_args_thin.from_x.c||process_merge"
      fi
      ;;
    std/net/net.o)
      printf '%s' "||net_merge"
      ;;
    *)
      printf '%s' ""
      ;;
  esac
}

# Prefer: historic Makefile used xlang-c -lib-name "" (R2 DIRECT), not -E rest.
_std_core_try_xlang_c_direct() {
  local x_src="$1" out_o="$2"
  local xx=""
  if [ -x ./xlang-c ]; then
    xx=./xlang-c
  elif [ -x ./xlang ]; then
    xx=./xlang
  elif [ -x ./bootstrap_xlangc ]; then
    xx=./bootstrap_xlangc
  else
    return 1
  fi
  [ -f "$x_src" ] || return 1
  mkdir -p "$(dirname "$out_o")"
  # PLATFORM: SHARED — R2 DIRECT pure-compute / thin wrappers via -lib-name "".
  XLANG_KEEP_C=1 "$xx" -L .. -L src -L src/asm -lib-name "" -o "$out_o" "$x_src"
}

# Relocatable multi-obj merge for std/core prefer (process_merge / net_merge / fast).
#
# G.7: single authority = `pure_ld_partial_merge` (already sourced above).
# Do NOT keep a second body with bare `ld -r -multiply_defined suppress`:
#   - `-multiply_defined` is obsolete on current Apple ld
#   - no Darwin libtool fallback → when an input is a prefer **libtool archive
#     named `.o`** (e.g. `runtime_process_argv.o` thin+rest after F7 two-segment
#     `ld -r` failure), Apple `ld -r` errors
#     "more than one LC_SEGMENT found in object file" and process_merge fails →
#     no `std/process/process.o` → product `-o` UNDEF `std_process_*` (tip L4
#     run-process BLD001 after CG002 force_load wave left process_argv as archive)
#
# PLATFORM: SHARED — pure_ld_partial_merge owns Linux ELF -r + Darwin libtool
#           -static fallback; callers (process_merge / net_merge) unchanged.
_std_core_ld_r() {
  local out="$1"
  shift
  pure_ld_partial_merge "$out" "$@"
}

# PLATFORM: SHARED — after ld -r product .o, keep only export faces as global T.
# formal_mod co-emits foreign std_io_*/core_result_*/xlang_io_*/ctx_*/process_*
# bodies as global T; product monofile also emits them → multi-def (L4
# run-std-net-context-gate: 221 dups). Localize non-export T so monofile owns
# foreign faces; this .o only exports its API. G.7 single post-merge authority.
# $1=out.o  remaining args = bare prefixes without leading _ (e.g. std_net_ net_)
# Darwin: nmedit -s keep_list. Linux: objcopy/llvm-objcopy --localize-symbol.
_std_core_keep_global_prefixes() {
  local out="$1"
  shift
  [ -f "$out" ] || return 0
  command -v nm >/dev/null 2>&1 || return 0
  local uname_s keep_re keep_list sym bare p
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  keep_re=""
  for p in "$@"; do
    [ -n "$p" ] || continue
    if [ -n "$keep_re" ]; then
      keep_re="${keep_re}|${p}"
    else
      keep_re="${p}"
    fi
  done
  [ -n "$keep_re" ] || return 0
  keep_list=$(mktemp "${TMPDIR:-/tmp}/xlang_keep_glob.XXXXXX") || return 0
  # nm -gU: defined global only. Match bare name against keep prefixes (optional _).
  nm -gU "$out" 2>/dev/null | awk '{print $NF}' | while IFS= read -r sym; do
    [ -n "$sym" ] || continue
    bare="$sym"
    case "$sym" in
      _*) bare="${sym#_}" ;;
    esac
    if printf '%s' "$bare" | grep -Eq "^(${keep_re})"; then
      printf '%s\n' "$sym"
    fi
  done >"$keep_list" 2>/dev/null || true
  if [ ! -s "$keep_list" ]; then
    rm -f "$keep_list"
    return 0
  fi
  if [ "$uname_s" = "Darwin" ] && command -v nmedit >/dev/null 2>&1; then
    # nmedit: globals NOT in list become local. Export list = keep.
    nmedit -s "$keep_list" "$out" 2>/dev/null || true
  else
    # Linux / objcopy path: localize every global T not in keep_list.
    local oc=""
    if command -v objcopy >/dev/null 2>&1; then
      oc=objcopy
    elif command -v llvm-objcopy >/dev/null 2>&1; then
      oc=llvm-objcopy
    elif [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ]; then
      oc=/opt/homebrew/opt/llvm/bin/llvm-objcopy
    fi
    if [ -n "$oc" ]; then
      nm -gU "$out" 2>/dev/null | awk '{print $NF}' | while IFS= read -r sym; do
        [ -n "$sym" ] || continue
        if ! grep -Fxq "$sym" "$keep_list" 2>/dev/null; then
          "$oc" --localize-symbol="$sym" "$out" 2>/dev/null || true
        fi
      done
    fi
  fi
  rm -f "$keep_list"
  return 0
}

# One net_*_fast PREFER or cold seed piece.
# $1=fast_o $2=seed $3=x_src $4=from_x_def $5=mode (thin_rest|direct) $6=xlang_bin
_std_core_net_fast_one() {
  local fast_o="$1" seed="$2" x_src="$3" from_x_def="$4" mode="$5" xbin="${6:-}"
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local thin_o rest_o dir
  dir="$(dirname "$fast_o")"
  mkdir -p "$dir"
  if [ "$prefer" = "1" ] && [ -f "$x_src" ] && [ -n "$xbin" ] && [ -x "$xbin" ]; then
    if [ "$mode" = "direct" ]; then
      if XLANG_KEEP_C=1 "$xbin" -L .. -L src -L src/asm -lib-name "" -o "$fast_o" "$x_src" 2>/dev/null; then
        return 0
      fi
    else
      thin_o="${fast_o%.o}_thin.o"
      rest_o="${fast_o%.o}_rest.o"
      # shellcheck disable=SC2086
      if XLANG_KEEP_C=1 "$xbin" -L .. -L src -L src/asm -lib-name "" -o "$thin_o" "$x_src" 2>/dev/null \
        && $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -D"$from_x_def" -c "$seed" -o "$rest_o" 2>/dev/null \
        && _std_core_ld_r "$fast_o" "$thin_o" "$rest_o"; then
        rm -f "$thin_o" "$rest_o"
        return 0
      fi
      rm -f "$thin_o" "$rest_o"
    fi
  fi
  # shellcheck disable=SC2086
  $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c "$seed" -o "$fast_o"
}

ensure_std_core_prefer_one() {
  local o="$1"
  local key spec seed x_src leaf_kind rest
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local stale=0
  local uname_s xlang net_sub_xlang objs x
  local tmp_args

  key="$(std_core_prefer_key_for_out "$o")"
  spec="$(std_core_prefer_spec_for_out "$o")"
  if [ -z "$spec" ] || [ -z "$key" ]; then
    return 3
  fi
  # Force canonical OUT under compiler/ parent layout (../std|core/...).
  case "$key" in
    std/*|core/*) o="../$key" ;;
  esac

  seed="${spec%%|*}"
  rest="${spec#*|}"
  x_src="${rest%%|*}"
  leaf_kind="${rest#*|}"

  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    stale=0
    if [ -n "$seed" ] && [ -f "$seed" ] && [ "$seed" -nt "$o" ]; then
      stale=1
    fi
    if [ -n "$x_src" ] && [ -f "$x_src" ] && [ "$x_src" -nt "$o" ]; then
      stale=1
    fi
    if [ "$leaf_kind" = "process_merge" ]; then
      if [ -f runtime_process_argv.o ] && [ runtime_process_argv.o -nt "$o" ]; then
        stale=1
      fi
      if [ -f runtime_process_os_glue.o ] && [ runtime_process_os_glue.o -nt "$o" ]; then
        stale=1
      fi
      # PLATFORM: SHARED — import_alias carries std_process_* product face.
      if [ -f seeds/runtime_process_import_alias.from_x.c ] &&
         [ seeds/runtime_process_import_alias.from_x.c -nt "$o" ]; then
        stale=1
      fi

    fi
    # wave796: net multi-merge source mtime (FORCE thin; G.7 single body).
    # Mirrors historic Makefile prereqs + net_merge body inputs.
    if [ "$stale" = "0" ] && [ "$leaf_kind" = "net_merge" ]; then
      local _net_dep
      for _net_dep in \
        ../std/net/mod.x ../std/net/alpn.x ../std/net/dns.x \
        ../std/net/io_batch.x ../std/net/addr.x ../std/net/ipv6.x \
        ../std/net/sock.x ../std/net/udp.x ../std/net/tcp.x \
        ../std/net/udp_batch.x ../std/net/workers.x ../std/net/tcp_pool.x \
        seeds/runtime_net_dns_fast.from_x.c \
        seeds/runtime_net_io_batch_fast.from_x.c \
        seeds/runtime_net_addr_fast.from_x.c \
        seeds/runtime_net_ipv6_fast.from_x.c \
        seeds/runtime_net_sock_fast.from_x.c \
        src/asm/runtime_net_dns_fast.x \
        src/asm/runtime_net_io_batch_fast.x \
        src/asm/runtime_net_addr_fast.x \
        src/asm/runtime_net_ipv6_fast.x \
        src/asm/runtime_net_sock_fast.x
      do
        if [ -f "$_net_dep" ] && [ "$_net_dep" -nt "$o" ]; then
          stale=1
          break
        fi
      done
    fi
    # wave793: project-header mtime (FORCE thin; G.7 single body).
    if [ "$stale" = "0" ] && [ -n "$seed" ] && [ -f "$seed" ]       && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    # wave794: Makefile flag-sensitive FORCE thin (main/runtime/pipeline_abi).
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (std-core-prefer/$leaf_kind)"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$o")"

  case "$leaf_kind" in
    direct)
      if [ ! -f "$seed" ]; then
        echo "ensure_host_cc_seed_o try-std-core-prefer: missing seed $seed for $o" >&2
        return 1
      fi
      if [ "$prefer" = "1" ] && [ -f "$x_src" ]; then
        if _std_core_try_xlang_c_direct "$x_src" "$o"; then
          log "prefer direct.x $o <- $x_src (try-std-core-prefer/direct)"
          return 0
        fi
        log "std-core direct prefer failed for $o; fallback full seed"
      fi
      if [ -f "$o" ] && [ "$prefer" = "1" ]; then
        FORCE=1
        ensure_one "$o" "$seed"
        FORCE=0
      else
        ensure_one "$o" "$seed"
      fi
      return 0
      ;;

    process_merge)
      # PLATFORM: SHARED — process.o = args_thin + argv + os_glue + import_alias.
      # import_alias exports std_process_* for pure-asm import METHOD (G.7 complete
      # process_merge; C-path co-emit of mod.x is not used on pure-asm product).
      # 7.2.1 fourth knife: when the map pointed at the .x authority, regen the
      # stable gen via the product -x -E first (both bare wrappers verified);
      # $seed then names the gen file for the shared compile below.
      if [ -n "$x_src" ] && [ -f "$x_src" ] && [ -x ./xlang_asm ]; then
        if ! ./xlang_asm -x -E -L .. "$x_src" >"$seed" 2>/dev/null \
           || ! grep -q '^int32_t process_args_count_c(' "$seed" \
           || ! grep -q '^uint8_t \* process_arg_c(' "$seed"; then
          echo "ensure_host_cc_seed_o: process args .x regen failed; cold seed needed" >&2
          return 1
        fi
      fi
      if [ ! -f "$seed" ]; then
        echo "ensure_host_cc_seed_o try-std-core-prefer: missing seed $seed for $o" >&2
        return 1
      fi
      if [ ! -f runtime_process_argv.o ]; then
        try_ensure_runtime_os_prefer_one runtime_process_argv.o \
          || ensure_one runtime_process_argv.o seeds/runtime_process_argv.from_x.c \
          || return 1
      fi
      if [ ! -f runtime_process_os_glue.o ]; then
        try_ensure_runtime_os_prefer_one runtime_process_os_glue.o \
          || ensure_one runtime_process_os_glue.o seeds/runtime_process_os_glue.from_x.c \
          || return 1
      fi
      _proc_alias_c="seeds/runtime_process_import_alias.from_x.c"
      # 7.2.1 twelfth knife (reverted on Ubuntu red): std_process_exit needs
      # the static-inline xlang_proc_exit Cap body (raw syscall; .x cannot
      # express it as extern — no exported definer). Stays seed until the
      # exit face gets an exported symbol or the Cap inline strategy lands.
      if [ ! -f "$_proc_alias_c" ]; then
        echo "ensure_host_cc_seed_o try-std-core-prefer: missing $_proc_alias_c for $o" >&2
        return 1
      fi
      tmp_args="$(mktemp "${TMPDIR:-/tmp}/proc_args.XXXXXX")"
      tmp_alias="$(mktemp "${TMPDIR:-/tmp}/proc_alias.XXXXXX")"
      # shellcheck disable=SC2086
      if ! $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c "$seed" -o "$tmp_args"; then
        rm -f "$tmp_args" "$tmp_alias"
        return 1
      fi
      # shellcheck disable=SC2086
      if ! $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c "$_proc_alias_c" -o "$tmp_alias"; then
        rm -f "$tmp_args" "$tmp_alias"
        return 1
      fi
      if ! _std_core_ld_r "$o" "$tmp_args" runtime_process_argv.o runtime_process_os_glue.o "$tmp_alias"; then
        rm -f "$tmp_args" "$tmp_alias"
        return 1
      fi
      rm -f "$tmp_args" "$tmp_alias"
      log "process_merge $o <- $seed + argv + os_glue + import_alias (try-std-core-prefer)"
      return 0
      ;;

    net_merge)
      # PLATFORM: SHARED net.o — mod.x + alpn/udp/tcp/udp_batch/workers/tls_stub/tcp_pool
      # + five fast pieces. PLATFORM: MACOS — force xlang-c for net submodules
      # (post-wave102 pure-asm arm64 left tls_stub UNDEFs under product -dead_strip).
      # F-04 tcp_pool.x must be in this merge: before this leaf, only weak
      # std_net_tcp_pool_net_tcp_pool_*_c stubs (return 0) were merged, so
      # cookbook net_tcp_pool built but create handle was always 0 (run=1).
      # G.7: complete net_merge with real tcp_pool.o + strong import aliases
      # (≡ tls_stub); do not keep a second weak body. PLATFORM: SHARED.
      xlang="${XLANG:-}"
      if [ -z "$xlang" ] || [ ! -x "$xlang" ]; then
        if [ -x ./xlang_asm ]; then xlang=./xlang_asm
        elif [ -x ./xlang ]; then xlang=./xlang
        elif [ -x ./xlang-c ]; then xlang=./xlang-c
        else xlang=; fi
      fi
      if [ -z "$xlang" ]; then
        echo "net.o: need xlang-c to merge net_*.x" >&2
        # Historic Makefile exited 0 here (soft). Keep soft for cold trees.
        return 0
      fi
      net_sub_xlang="$xlang"
      uname_s="$(uname -s 2>/dev/null || echo Unknown)"
      case "$uname_s" in
        Darwin)
          if [ -x ./xlang-c ]; then net_sub_xlang=./xlang-c
          elif [ -x ./xlang ]; then net_sub_xlang=./xlang; fi
          ;;
      esac
      objs=""
      # PLATFORM: SHARED — include tls_stub + tcp_pool (mod.x import both).
      # OpenSSL/mbedTLS variants remain separate product overlays.
      for x in alpn udp tcp udp_batch workers tls_stub tcp_pool; do
        sh scripts/xlang_compile_std_x.sh "$net_sub_xlang" "../std/net/$x.x" "../std/net/$x.o" || return 1
        objs="$objs ../std/net/$x.o"
      done
      # Import-binding face: bare net_tls_*_c → std_net_tls_stub_net_tls_*_c
      # and bare net_tcp_pool_*_c → std_net_tcp_pool_net_tcp_pool_*_c.
      # xlang_compile_std_x emits bare C symbols; mod.x import path prefixes both
      # leaf and name. G.7: single alias .o after stub/pool compile (no second body).
      if [ -f ../std/net/tls_stub.o ] || [ -f ../std/net/tcp_pool.o ]; then
        # Keep alias .o under std/net/ (not TMPDIR) so ld -r sees a stable path.
        _tls_alias_c="../std/net/tls_stub_import_alias.c"
        _tls_alias_o="../std/net/tls_stub_import_alias.o"
        {
          echo '/* net_merge: import-binding aliases for std.net.tls_stub + tcp_pool */'
          echo '#include <stdint.h>'
          echo '#include <stddef.h>'
          cat <<'TEOF'
extern int32_t net_tls_is_available_c(void);
extern uint8_t *net_tls_backend_name_c(void);
extern int32_t net_tls_connect_client_c(int32_t fd, uint8_t *sni);
extern int32_t net_tls_connect_client_alpn_c(int32_t fd, uint8_t *sni, uint8_t *alpn, int32_t alpn_len);
extern int32_t net_tls_close_c(int64_t h);
extern int32_t net_tls_read_c(int64_t h, uint8_t *buf, int32_t cap);
extern int32_t net_tls_write_c(int64_t h, uint8_t *buf, int32_t len);
extern int32_t net_tls_last_error_c(void);
extern int32_t net_tls_alpn_selected_c(int64_t h, uint8_t *out, int32_t out_cap);
extern int32_t net_tls_alpn_is_h2_c(int64_t h);
int32_t std_net_tls_stub_net_tls_is_available_c(void) { return net_tls_is_available_c(); }
uint8_t *std_net_tls_stub_net_tls_backend_name_c(void) { return net_tls_backend_name_c(); }
int32_t std_net_tls_stub_net_tls_connect_client_c(int32_t fd, uint8_t *sni) { return net_tls_connect_client_c(fd, sni); }
int32_t std_net_tls_stub_net_tls_connect_client_alpn_c(int32_t fd, uint8_t *sni, uint8_t *alpn, int32_t alpn_len) { return net_tls_connect_client_alpn_c(fd, sni, alpn, alpn_len); }
int32_t std_net_tls_stub_net_tls_close_c(int64_t h) { return net_tls_close_c(h); }
int32_t std_net_tls_stub_net_tls_read_c(int64_t h, uint8_t *buf, int32_t cap) { return net_tls_read_c(h, buf, cap); }
int32_t std_net_tls_stub_net_tls_write_c(int64_t h, uint8_t *buf, int32_t len) { return net_tls_write_c(h, buf, len); }
int32_t std_net_tls_stub_net_tls_last_error_c(void) { return net_tls_last_error_c(); }
int32_t std_net_tls_stub_net_tls_alpn_selected_c(int64_t h, uint8_t *out, int32_t out_cap) { return net_tls_alpn_selected_c(h, out, out_cap); }
int32_t std_net_tls_stub_net_tls_alpn_is_h2_c(int64_t h) { return net_tls_alpn_is_h2_c(h); }
/* Residual io faces when product only needs connect_ctx.
 * Weak so real io .o can override when linked. PLATFORM: SHARED. */
__attribute__((weak)) int32_t std_io_read_fixed_fd(int32_t a, uint32_t b, size_t c, size_t d, uint32_t e) {
  (void)a;(void)b;(void)c;(void)d;(void)e; return -1;
}
__attribute__((weak)) int32_t std_io_write_fixed_fd(int32_t a, uint32_t b, size_t c, size_t d, uint32_t e) {
  (void)a;(void)b;(void)c;(void)d;(void)e; return -1;
}
__attribute__((weak)) uint8_t *xlang_io_read_ptr_len(size_t h, size_t *out_len) {
  (void)h; if (out_len) *out_len = 0; return (uint8_t *)0;
}
/* Strong import aliases for std.net.tcp_pool (≡ tls_stub). Bare bodies live in
 * tcp_pool.o from tcp_pool.x. Do NOT weaken these — weak return-0 stubs were the
 * net_tcp_pool cookbook run=1 root cause. PLATFORM: SHARED. */
extern int64_t net_tcp_pool_create_c(uint32_t a, uint32_t b, int32_t c);
extern int32_t net_tcp_pool_acquire_c(int64_t h, uint32_t t);
extern int32_t net_tcp_pool_release_c(int64_t h, int32_t fd);
extern void net_tcp_pool_drain_c(int64_t h);
extern void net_tcp_pool_destroy_c(int64_t h);
extern int32_t net_tcp_pool_connect_count_c(int64_t h);
extern int32_t net_tcp_pool_idle_count_c(int64_t h);
extern int32_t net_tcp_pool_smoke_c(void);
int64_t std_net_tcp_pool_net_tcp_pool_create_c(uint32_t a, uint32_t b, int32_t c) {
  return net_tcp_pool_create_c(a, b, c);
}
int32_t std_net_tcp_pool_net_tcp_pool_acquire_c(int64_t h, uint32_t t) {
  return net_tcp_pool_acquire_c(h, t);
}
int32_t std_net_tcp_pool_net_tcp_pool_release_c(int64_t h, int32_t fd) {
  return net_tcp_pool_release_c(h, fd);
}
void std_net_tcp_pool_net_tcp_pool_drain_c(int64_t h) { net_tcp_pool_drain_c(h); }
void std_net_tcp_pool_net_tcp_pool_destroy_c(int64_t h) { net_tcp_pool_destroy_c(h); }
int32_t std_net_tcp_pool_net_tcp_pool_connect_count_c(int64_t h) {
  return net_tcp_pool_connect_count_c(h);
}
int32_t std_net_tcp_pool_net_tcp_pool_idle_count_c(int64_t h) {
  return net_tcp_pool_idle_count_c(h);
}
int32_t std_net_tcp_pool_net_tcp_pool_smoke_c(void) { return net_tcp_pool_smoke_c(); }
/* Fast-path addr helpers sometimes only on asm leaves; weak for pure host-C net.o. */
__attribute__((weak)) int64_t net_tcp_local_addr_c(int32_t fd) { (void)fd; return 0; }
__attribute__((weak)) int64_t net_tcp_peer_addr_c(int32_t fd) { (void)fd; return 0; }
__attribute__((weak)) void net_tcp_set_addr_port_buf_c(uint8_t *b, uint32_t a, uint32_t p) {
  (void)b;(void)a;(void)p;
}
__attribute__((weak)) void net_udp_set_addr_port_buf_c(uint8_t *b, uint32_t a, uint32_t p) {
  (void)b;(void)a;(void)p;
}
TEOF
        } >"$_tls_alias_c"
        if cc -std=c11 -c -o "$_tls_alias_o" "$_tls_alias_c" 2>/dev/null; then
          objs="$objs $_tls_alias_o"
        fi
        rm -f "$_tls_alias_c"
      fi
      sh scripts/xlang_compile_std_module.sh ../std/net/mod.o ../std/net/mod.x || return 1
      objs="$objs ../std/net/mod.o"
      _std_core_net_fast_one ../std/net/net_dns_fast.o \
        seeds/runtime_net_dns_fast.from_x.c src/asm/runtime_net_dns_fast.x \
        XLANG_RUNTIME_NET_DNS_FAST_FROM_X thin_rest "$net_sub_xlang" || return 1
      _std_core_net_fast_one ../std/net/net_io_batch_fast.o \
        seeds/runtime_net_io_batch_fast.from_x.c src/asm/runtime_net_io_batch_fast.x \
        XLANG_RUNTIME_NET_IO_BATCH_FAST_FROM_X thin_rest "$net_sub_xlang" || return 1
      _std_core_net_fast_one ../std/net/net_addr_fast.o \
        seeds/runtime_net_addr_fast.from_x.c src/asm/runtime_net_addr_fast.x \
        XLANG_RUNTIME_NET_ADDR_FAST_FROM_X direct "$net_sub_xlang" || return 1
      _std_core_net_fast_one ../std/net/net_ipv6_fast.o \
        seeds/runtime_net_ipv6_fast.from_x.c src/asm/runtime_net_ipv6_fast.x \
        XLANG_RUNTIME_NET_IPV6_FAST_FROM_X thin_rest "$net_sub_xlang" || return 1
      _std_core_net_fast_one ../std/net/net_sock_fast.o \
        seeds/runtime_net_sock_fast.from_x.c src/asm/runtime_net_sock_fast.x \
        XLANG_RUNTIME_NET_SOCK_FAST_FROM_X thin_rest "$net_sub_xlang" || return 1
      # shellcheck disable=SC2086
      if ! _std_core_ld_r "$o" $objs \
        ../std/net/net_dns_fast.o ../std/net/net_io_batch_fast.o \
        ../std/net/net_addr_fast.o ../std/net/net_ipv6_fast.o \
        ../std/net/net_sock_fast.o; then
        return 1
      fi
      rm -f ../std/net/mod.o ../std/net/net_dns_fast.o ../std/net/net_io_batch_fast.o \
        ../std/net/net_addr_fast.o ../std/net/net_ipv6_fast.o ../std/net/net_sock_fast.o
      # Keep only net product faces global. formal_mod co-emits std_io_*/core_result_*
      # etc. as T; monofile also defines them → multi-def on product -o (L4 STD-092).
      # PLATFORM: SHARED — nmedit (Darwin) / objcopy localize (Linux).
      _std_core_keep_global_prefixes "$o" "std_net_" "net_"
      log "net_merge $o <- sub.x + mod + five fast (try-std-core-prefer)"
      return 0
      ;;

    *)
      echo "ensure_host_cc_seed_o try-std-core-prefer: unknown leaf_kind $leaf_kind" >&2
      return 1
      ;;
  esac
}

try_ensure_std_core_prefer_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-std-core-prefer: need <out.o>" >&2
    exit 2
  fi
  if [ -z "$(std_core_prefer_spec_for_out "$o")" ]; then
    return 3
  fi
  ensure_std_core_prefer_one "$o"
  return 0
}

# ---------------------------------------------------------------------------
# wave781: try-lsp-sat-prefer OUT — B3 LSP satellite hybrid table.
#
# Table-driven single body (G.7 有则补全). Two Makefile product hybrids that
# sit *outside* try-other-l2-prefer (lsp_diag.o glue) and try-ldpc-prefer
# (pipeline_ctx). Shapes differ enough that extending other-l2 would fork
# authority — dedicated table is the single body for these two leaves.
#
# leaf_kind:
#   direct_e   — w848: pure_asm_x_to_o of the .x only. The C seed
#                seeds/lsp_diag_pipeline_sizes.from_x.c is deleted.
#                No gcc -E. No cold seed. Failure returns 1.
#                XLANG_G05_PREFER_X_O is ignored. PLATFORM: SHARED.
#   thin_rest_e — PREFER: pure-asm -c thin first (wave757 Class H), else
#                 xlang-c -E .x → thin.o + seed rest
#                 -DXLANG_LSP_DIAG_STUBS_NO_C_FROM_X → ld -r multidef.
#                 cold: seeds/lsp_diag_stubs_no_c.from_x.c
# Prefer fail / no xlang-c → cold seed. NOT physical delete — Makefile thin-call.
# wave756 Class G: lsp_diag_pipeline_sizes.x standalone asm is U-complete
# (T=3). w848 deleted the C seed. direct_e is pure_asm_x_to_o only.
# Do not gcc -E this TU. Do not restore the seed. Pin unchanged.
# wave757 Class H: lsp_diag_stubs_no_c.x standalone -c T=5 U=0 both ends.
# Prefer pure-asm thin + seed rest (FROM_X) before -E thin. Seed rest still
# host-cc (C body); .x gen path cuts host-cc. Do not -E as repair. Pin unchanged.
# Callers: Makefile 2 leaves (wave781).
# Exit codes:
#   0 — OUT is a table member; body produced OUT
#   3 — OUT is not in the lsp-sat prefer table
#   1 — seed missing / compile failed
# PLATFORM: SHARED shell body · product dual hybrid historic (xlang-c when present).
# Residual after: ~~B4~~ (wave782) · B5 · physical delete · R5.
# ---------------------------------------------------------------------------

# Spec: seed|x_src|from_x_def|leaf_kind
# from_x_def empty for direct_e; XLANG_LSP_DIAG_STUBS_NO_C_FROM_X for thin_rest_e.
lsp_sat_prefer_spec_for_out() {
  case "$1" in
    src/lsp/lsp_diag_pipeline_sizes_nostub.o)
      # w848: seed field is "-" because the C file is deleted.
      printf '%s' "-|src/lsp/lsp_diag_pipeline_sizes.x||direct_e"
      ;;
    src/lsp/lsp_diag_stubs_no_c.o)
      printf '%s' "seeds/lsp_diag_stubs_no_c.from_x.c|src/lsp/lsp_diag_stubs_no_c.x|XLANG_LSP_DIAG_STUBS_NO_C_FROM_X|thin_rest_e"
      ;;
    *)
      printf '%s' ""
      ;;
  esac
}

# Historic Makefile xlang-c -E for LSP satellites (stubs uses module -L paths).
_lsp_sat_xlang_c_e() {
  local x_src="$1" tmp_c="$2" mode="$3"
  if [ ! -x ./xlang-c ]; then
    return 1
  fi
  [ -f "$x_src" ] || return 1
  case "$mode" in
    direct_e)
      ./xlang-c -E "$x_src" >"$tmp_c" 2>/dev/null
      ;;
    thin_rest_e)
      ./xlang-c -L .. -L src -L src/asm -L src/ast -L src/parser \
        -L src/typeck -L src/preprocess -L src/codegen -L src/pipeline \
        -E "$x_src" >"$tmp_c" 2>/dev/null
      ;;
    *)
      return 1
      ;;
  esac
  [ -s "$tmp_c" ]
}

ensure_lsp_sat_prefer_one() {
  local o="$1"
  local spec seed x_src from_x_def leaf_kind rest
  local stale=0
  local tmp_c thin_o rest_o

  spec="$(lsp_sat_prefer_spec_for_out "$o")"
  if [ -z "$spec" ]; then
    return 3
  fi
  seed="${spec%%|*}"
  rest="${spec#*|}"
  x_src="${rest%%|*}"
  rest="${rest#*|}"
  from_x_def="${rest%%|*}"
  leaf_kind="${rest#*|}"

  # w848: direct_e seed is "-" (file deleted). Other leaves still require a seed.
  if [ "$seed" != "-" ] && [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o try-lsp-sat-prefer: missing seed $seed for $o" >&2
    return 1
  fi

  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    stale=0
    [ "$seed" -nt "$o" ] && stale=1
    if [ -f "$x_src" ] && [ "$x_src" -nt "$o" ]; then
      stale=1
    fi
    # wave793: project-header mtime (FORCE thin; G.7 single body).
    if [ "$stale" = "0" ] && seed_project_hdrs_newer "$seed" "$o"; then
      stale=1
    fi
    # wave794: Makefile flag-sensitive FORCE thin (main/runtime/pipeline_abi).
    if [ "$stale" = "0" ] && force_thin_makefile_flags_newer "$o"; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (lsp-sat-prefer/$leaf_kind)"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$o")"

  case "$leaf_kind" in
    direct_e)
      # w848: the three sizeof functions live only in the .x. The C seed
      # is deleted. pure_asm_x_to_o only. No gcc -E. No cold-seed cc.
      # XLANG_G05_PREFER_X_O is ignored. Windows takes the same path.
      # PLATFORM: SHARED.
      if [ ! -f "$x_src" ]; then
        echo "ensure: lsp sizes missing $x_src; C seed is gone, no fallback" >&2
        return 1
      fi
      if (
        export XLANG_PREFER_ASM_O=1
        pure_asm_x_to_o "$o" "$x_src"
      ); then
        log "prefer direct_e pure-asm $o <- $x_src (w848; C seed deleted)"
        return 0
      fi
      echo "ensure: lsp sizes pure-asm failed; C seed is gone, no fallback" >&2
      rm -f "$o"
      return 1
      ;;

    thin_rest_e)
      # PLATFORM: SHARED — Class H pure-asm thin first; else -E thin + seed rest.
      if [ -f "$x_src" ] && [ -n "$from_x_def" ]; then
        local asm_bin=""
        if [ -x "./xlang_asm" ]; then
          asm_bin="./xlang_asm"
        elif [ -x "./xlang" ]; then
          asm_bin="./xlang"
        elif [ -x ./xlang-c ]; then
          asm_bin="./xlang-c"
        fi
        if [ -n "$asm_bin" ]; then
          # wave757: xlang_asm -c requires a .o suffix (else it links as exe
          # and fails looking for main). BSD mktemp wants X at end of template.
          thin_o="$(mktemp "${TMPDIR:-/tmp}/ldsn_thin.XXXXXX").o"
          rest_o="$(mktemp "${TMPDIR:-/tmp}/ldsn_rest.XXXXXX").o"
          # shellcheck disable=SC2086
          if "$asm_bin" -backend asm -c "$x_src" -o "$thin_o" 2>/dev/null \
            && [ -s "$thin_o" ] \
            && $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
                 -D"$from_x_def" -c "$seed" -o "$rest_o" \
            && _std_core_ld_r "$o" "$thin_o" "$rest_o"; then
            rm -f "$thin_o" "$rest_o" "${thin_o%.o}" "${rest_o%.o}"
            log "prefer thin_rest_e pure-asm $o <- $x_src + seed-rest (try-lsp-sat-prefer/Class H)"
            return 0
          fi
          rm -f "$thin_o" "$rest_o" "${thin_o%.o}" "${rest_o%.o}" "$o"
        fi
      fi
      if [ -f "$x_src" ] && [ -x ./xlang-c ] && [ -n "$from_x_def" ]; then
        tmp_c="$(mktemp "${TMPDIR:-/tmp}/ldsn.XXXXXX")"
        thin_o="$(mktemp "${TMPDIR:-/tmp}/ldsn_thin.XXXXXX")"
        rest_o="$(mktemp "${TMPDIR:-/tmp}/ldsn_rest.XXXXXX")"
        # shellcheck disable=SC2086
        if _lsp_sat_xlang_c_e "$x_src" "$tmp_c" thin_rest_e \
          && $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
               -x c -c "$tmp_c" -o "$thin_o" \
          && $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
               -D"$from_x_def" -c "$seed" -o "$rest_o" \
          && _std_core_ld_r "$o" "$thin_o" "$rest_o"; then
          rm -f "$tmp_c" "$thin_o" "$rest_o"
          log "prefer thin_rest_e $o <- $x_src + seed-rest (try-lsp-sat-prefer/thin_rest_e)"
          return 0
        fi
        rm -f "$tmp_c" "$thin_o" "$rest_o"
        log "lsp-sat thin_rest_e prefer failed for $o; fallback full seed"
      fi
      if [ -f "$o" ]; then
        FORCE=1
        ensure_one "$o" "$seed"
        FORCE=0
      else
        ensure_one "$o" "$seed"
      fi
      return 0
      ;;

    *)
      echo "ensure_host_cc_seed_o try-lsp-sat-prefer: unknown leaf_kind $leaf_kind" >&2
      return 1
      ;;
  esac
}

try_ensure_lsp_sat_prefer_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-lsp-sat-prefer: need <out.o>" >&2
    exit 2
  fi
  if [ -z "$(lsp_sat_prefer_spec_for_out "$o")" ]; then
    return 3
  fi
  ensure_lsp_sat_prefer_one "$o" || return 1
  return 0
}

# ---------------------------------------------------------------------------
# wave782: try-gen-c-to-o OUT — B4 gen.c → .o bootstrap.
#
# Table-driven membership (G.7 有则补全). Four Makefile pure host-cc leaves
# outside try-gen-x catalog (lsp trio + pipeline_x are try-gen-x). Body =
# ensure_gen_x_o.sh one OUT (same authority as wave761 gen maps; extended for B4).
#
# Leaves: lexer_x.o · ast_gen2.o · driver_x.o · preprocess_x.o
# wave295 B′: _x_stubs2.o host left (dead dual; product g05 / stage2 never linked).
# Prefer fail N/A — cold gen.c only (historic Makefile).
# Callers: Makefile 4 leaves (wave782/295). NOT physical delete.
# Exit codes:
#   0 — OUT is a B4 table member; body produced OUT (or skip up-to-date)
#   3 — OUT is not in the gen-c-to-o table
#   1 — gen missing / compile failed
# PLATFORM: SHARED shell body.
# Residual after: B5 · physical delete · R5.
# ---------------------------------------------------------------------------

gen_c_to_o_spec_for_out() {
  # stdout non-empty iff B4 member (value = gen source path for --check).
  case "$1" in
    lexer_x.o) printf '%s' "lexer_gen.c" ;;
    ast_gen2.o) printf '%s' "ast_gen2.c" ;;
    driver_x.o) printf '%s' "driver_gen.c" ;;
    preprocess_x.o) printf '%s' "preprocess_gen.c" ;;
    *) printf '%s' "" ;;
  esac
}

try_ensure_gen_c_to_o_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-gen-c-to-o: need <out.o>" >&2
    exit 2
  fi
  if [ -z "$(gen_c_to_o_spec_for_out "$o")" ]; then
    return 3
  fi
  if [ ! -f scripts/ensure_gen_x_o.sh ]; then
    echo "ensure_host_cc_seed_o try-gen-c-to-o: missing scripts/ensure_gen_x_o.sh (wave782)" >&2
    return 1
  fi
  if [ "$FORCE" = "1" ]; then
    XLANG_GEN_X_FORCE=1 XLANG_HOST_CC_SEED_FORCE=1 \
      bash scripts/ensure_gen_x_o.sh one "$o" || return 1
  else
    bash scripts/ensure_gen_x_o.sh one "$o" || return 1
  fi
  return 0
}

# ---------------------------------------------------------------------------
# wave783: try-cfg-eval-ladder OUT — B5 cfg_eval multi-ladder (single leaf).
#
# Authority for src/lexer/cfg_eval.o product body (G.7 有则补全). Historic
# Makefile multi-ladder: live -E-extern (+/- -L) → cc with PIPELINE_GEN_CFLAGS
# + link_alias ld -r; else linux pin gen + alias; else bootstrap stub copy.
# Dead rung dropped: `if false &&` default-pipeline asm path (was permanently
# disabled). Cold may soft-ensure xlang-c via ensure_xlang_c.sh (wave950;
# was make-target xlang-c); pin/stub rungs do not require it.
#
# wave755 Class F (cfg_eval pure-asm): live `-backend asm -c` of cfg_eval.x is
# U-complete both ends (host lit stays U). Prefer that pure-asm rung BEFORE
# -E-extern+cc so this TU stops host-cc of gen.c. Link host_lit only (not full
# link_alias).
# wave851: host_lit is pure-asm of cfg_eval_host_lit.x only. The C seed
# is deleted. Pure-asm failure returns 1 and leaves the previous .o.
# Zero host-cc of this TU. Do not gcc -E it.
# wave759 Class J: Darwin file-level let ADRP must be PAGE21 (not BR26) or
# Rung0 ld -r fails and falls to pin. Regression: scripts/smoke_file_let_page21.sh.
# Do not -E as the repair. Do not bump pin.
#
# Exit codes:
#   0 — OUT is B5 member; ladder produced OUT (or skip up-to-date)
#   3 — OUT is not src/lexer/cfg_eval.o
#   1 — all rungs failed
# PLATFORM: SHARED shell body · pin = Ubuntu gold seed; Darwin may fall to stub
# when -E emits illegal dual host-lit C (historic Makefile twin).
# Callers: g05 / rebuild_leaves / historic Makefile thin-call (wave783).
# wave950: missing xlang-c → ensure_xlang_c.sh (0-make post-delete).
# ---------------------------------------------------------------------------

cfg_eval_ladder_spec_for_out() {
  # stdout non-empty iff B5 member.
  case "$1" in
    src/lexer/cfg_eval.o) printf '%s' "cfg_eval_multi_ladder" ;;
    *) printf '%s' "" ;;
  esac
}

# wave886: default LD_RELFLAGS when unset (mirror Makefile UNAME ifeq).
# PLATFORM: MACOS — ld -r needs explicit -arch; LINUX/WINDOWS leave empty.
# G.7 single body — CLI/env LD_RELFLAGS still wins when set.
_cfg_eval_default_ld_relflags() {
  local uname_s uname_m
  uname_s=$(uname -s 2>/dev/null || echo unknown)
  uname_m=$(uname -m 2>/dev/null || echo unknown)
  case "$uname_s" in
    Darwin)
      case "$uname_m" in
        arm64|aarch64) printf '%s' "-arch arm64" ;;
        x86_64|amd64) printf '%s' "-arch x86_64" ;;
        *) printf '%s' "" ;;
      esac
      ;;
    *)
      printf '%s' ""
      ;;
  esac
}

# Link cfg_eval pure-asm .o + host_lit only → OUT (wave755 Class F /
# wave851). Bare cfg_* names from -backend asm -c clash with link_alias
# wrappers (those expect lexer_cfg_* from -E-extern). host_lit supplies
# only cfg_host_os_lit / cfg_host_arch_lit.
# wave851: pure-asm -c of src/lexer/cfg_eval_host_lit.x only. The C seed
# is deleted. Failure leaves the previous host_lit .o and returns 1.
# PLATFORM: SHARED — same LD/LD_RELFLAGS defaults as alias link.
_cfg_eval_link_x_plus_host_lit() {
  local out="$1" x_o="$2"
  local ld_bin="${LD:-ld}"
  local ld_rel="${LD_RELFLAGS-}"
  local lit_o="src/lexer/cfg_eval_host_lit.o"
  local lit_x="src/lexer/cfg_eval_host_lit.x"
  local asm_bin="" lit_tmp lit_new
  if [ -z "${LD_RELFLAGS+x}" ]; then
    ld_rel="$(_cfg_eval_default_ld_relflags)"
  fi
  if [ ! -f "$lit_x" ]; then
    echo "ensure_host_cc_seed_o try-cfg-eval-ladder: missing $lit_x; C seed is gone, no fallback" >&2
    return 1
  fi
  if [ -x "./xlang_asm" ]; then
    asm_bin="./xlang_asm"
  elif [ -x "./xlang" ]; then
    asm_bin="./xlang"
  elif [ -x "./xlang-c" ]; then
    asm_bin="./xlang-c"
  fi
  if [ -z "$asm_bin" ]; then
    echo "ensure_host_cc_seed_o try-cfg-eval-ladder: no asm compiler; C seed is gone, no fallback" >&2
    return 1
  fi
  # macOS mktemp requires the XXXXXX suffix at the end of the template.
  lit_tmp="$(mktemp "${TMPDIR:-/tmp}/cfg_host_lit.XXXXXX")"
  lit_new="${lit_tmp}.o"
  mv "$lit_tmp" "$lit_new"
  if ! "$asm_bin" -backend asm -c "$lit_x" -o "$lit_new" 2>/dev/null \
    || [ ! -s "$lit_new" ] \
    || ! r3_prefer_nm_has_sym "$lit_new" "cfg_host_os_lit" \
    || ! r3_prefer_nm_has_sym "$lit_new" "cfg_host_arch_lit"; then
    echo "ensure_host_cc_seed_o try-cfg-eval-ladder: host_lit pure-asm failed; C seed is gone, no fallback" >&2
    rm -f "$lit_new"
    return 1
  fi
  mv -f "$lit_new" "$lit_o"
  export CFG_EVAL_HOST_LIT_FROM_ASM=1
  # shellcheck disable=SC2086
  if ! $ld_bin $ld_rel -r -o "$out" "$x_o" "$lit_o"; then
    return 1
  fi
  return 0
}

# Link cfg_eval_x.o + link_alias → OUT (historic Makefile $(LD) -r twin).
# PLATFORM: SHARED — LD/LD_RELFLAGS from env when set; shell defaults otherwise
# (wave886: no Makefile recipe inject).
_cfg_eval_link_x_plus_alias() {
  local out="$1" x_o="$2"
  local ld_bin="${LD:-ld}"
  local ld_rel="${LD_RELFLAGS-}"
  if [ -z "${LD_RELFLAGS+x}" ]; then
    ld_rel="$(_cfg_eval_default_ld_relflags)"
  fi
  if [ ! -f scripts/cc_inc_tu.sh ]; then
    echo "ensure_host_cc_seed_o try-cfg-eval-ladder: missing scripts/cc_inc_tu.sh" >&2
    return 1
  fi
  if [ ! -f seeds/cfg_eval_link_alias.from_x.c ]; then
    echo "ensure_host_cc_seed_o try-cfg-eval-ladder: missing seeds/cfg_eval_link_alias.from_x.c" >&2
    return 1
  fi
  sh scripts/cc_inc_tu.sh seeds/cfg_eval_link_alias.from_x.c src/lexer/cfg_eval_link_alias.o || return 1
  # shellcheck disable=SC2086
  $ld_bin $ld_rel -r -o "$out" "$x_o" src/lexer/cfg_eval_link_alias.o
}

ensure_cfg_eval_ladder_one() {
  local o="$1"
  local x_src="src/lexer/cfg_eval.x"
  local pin="seeds/cfg_eval_gen.linux.x86_64.c"
  local alias_seed="seeds/cfg_eval_link_alias.from_x.c"
  local stub_seed="seeds/cfg_eval_bootstrap_stub.from_x.c"
  local x_o="src/lexer/cfg_eval_x.o"
  local gen_c="src/lexer/cfg_eval_gen.c"
  local xlang_c="./xlang-c"
  local stale=0
  local d

  if [ -z "$(cfg_eval_ladder_spec_for_out "$o")" ]; then
    return 3
  fi

  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    stale=0
    local host_lit_x="src/lexer/cfg_eval_host_lit.x"
    for d in "$x_src" "$alias_seed" "$pin" "$host_lit_x" "$stub_seed"; do
      if [ -f "$d" ] && [ "$d" -nt "$o" ]; then
        stale=1
        break
      fi
    done
    # wave793: project-header mtime (FORCE thin; G.7 single body).
    # cfg-eval multi-seed: scan pin + alias + stub for #include freshness.
    if [ "$stale" = "0" ]; then
      if seed_project_hdrs_newer "$pin" "$o"         || seed_project_hdrs_newer "$alias_seed" "$o"         || seed_project_hdrs_newer "$stub_seed" "$o"; then
        stale=1
      fi
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (cfg-eval-ladder)"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$o")"

  # Soft ensure xlang-c for live -E rungs. wave950: ensure_xlang_c.sh (0-make;
  # Makefile deleted wave941). Soft-continue so pin/stub cold paths still work
  # when bootstrap_xlangc / SRC is not ready (L2 residual rebuild).
  # PLATFORM: SHARED — G.7 single authority for default xlang-c alias.
  if [ ! -x "$xlang_c" ]; then
    log "cfg-eval-ladder: xlang-c missing; soft ensure via ensure_xlang_c.sh (pin/stub fallback if fail)"
    bash scripts/ensure_xlang_c.sh ensure xlang-c 2>/dev/null || true
  fi
  # (do not reintroduce bare make-target xlang-c here)

  rm -f "$x_o"

  # Rung 0 (wave755 Class F / wave851): pure-asm -c of cfg_eval.x +
  # pure-asm of cfg_eval_host_lit.x. The host_lit C seed is deleted.
  # PLATFORM: SHARED — xlang_asm preferred; fall back to xlang / xlang-c
  # -backend. Host lit stays U in cfg_eval.x; do NOT link full link_alias
  # (dup cfg_eval_expr_c vs bare pure-asm T). Do not -E as the repair.
  if [ -f "$x_src" ]; then
    local asm_bin=""
    if [ -x "./xlang_asm" ]; then
      asm_bin="./xlang_asm"
    elif [ -x "./xlang" ]; then
      asm_bin="./xlang"
    elif [ -x "$xlang_c" ]; then
      asm_bin="$xlang_c"
    fi
    if [ -n "$asm_bin" ]; then
      if "$asm_bin" -backend asm -c "$x_src" -o "$x_o" 2>/dev/null \
        && [ -s "$x_o" ] \
        && _cfg_eval_link_x_plus_host_lit "$o" "$x_o"; then
        log "cfg_eval.o from cfg_eval.x (pure-asm -c + host_lit.x) [w851]"
        return 0
      fi
      rm -f "$x_o"
    fi
  fi

  # Rung 1: live -E -E-extern -L .. + PIPELINE_GEN_CFLAGS + alias
  # PLATFORM: SHARED — prefer live gen; wave98: bare -E forbidden (dangling BSS).
  if [ -x "$xlang_c" ] && [ -f "$x_src" ]; then
    # shellcheck disable=SC2086
    if "$xlang_c" -E -E-extern -L .. "$x_src" >"$gen_c" 2>/dev/null \
      && [ -s "$gen_c" ] \
      && $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c -o "$x_o" "$gen_c" 2>/dev/null \
      && _cfg_eval_link_x_plus_alias "$o" "$x_o"; then
      log "cfg_eval.o from cfg_eval.x (-E-extern + alias)"
      return 0
    fi
    # Rung 2: -E -E-extern without -L (module path residual)
    # shellcheck disable=SC2086
    if "$xlang_c" -E -E-extern "$x_src" >"$gen_c" 2>/dev/null \
      && [ -s "$gen_c" ] \
      && $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c -o "$x_o" "$gen_c" 2>/dev/null \
      && _cfg_eval_link_x_plus_alias "$o" "$x_o"; then
      log "cfg_eval.o from cfg_eval.x (-E-extern no -L + alias)"
      return 0
    fi
  fi

  # Rung 3: linux pin gen + alias (Ubuntu gold seed; same as typeck pin style)
  # PLATFORM: LINUX pin source · SHARED host-cc of pin on all platforms.
  # shellcheck disable=SC2086
  if [ -s "$pin" ] \
    && $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c -o "$x_o" "$pin" 2>/dev/null \
    && _cfg_eval_link_x_plus_alias "$o" "$x_o"; then
    log "cfg_eval.o from cfg_eval.x (linux pin gen + alias)"
    return 0
  fi

  # Rung 4: bootstrap stub (cold when .x path unusable / -E illegal C)
  if [ -f "$stub_seed" ] && [ -f scripts/cc_inc_tu.sh ]; then
    if sh scripts/cc_inc_tu.sh "$stub_seed" src/lexer/cfg_eval_bootstrap_stub.o \
      && cp -f src/lexer/cfg_eval_bootstrap_stub.o "$o"; then
      log "cfg_eval.o from bootstrap stub (cfg_eval.x unavailable at cold start)"
      return 0
    fi
  fi

  echo "ensure_host_cc_seed_o try-cfg-eval-ladder: all rungs failed for $o" >&2
  return 1
}

try_ensure_cfg_eval_ladder_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-cfg-eval-ladder: need <out.o>" >&2
    exit 2
  fi
  if [ -z "$(cfg_eval_ladder_spec_for_out "$o")" ]; then
    return 3
  fi
  ensure_cfg_eval_ladder_one "$o"
  return $?
}

# ---------------------------------------------------------------------------
# wave760: try-r2 OUT — R2 platform-stamp panic cold body (UNAME leaf).
#
# Membership = catalog DRIVER_SEED_PANIC_OBJS only (lists = mk; currently
# runtime_panic.o). Cold source selection mirrors Makefile / build_xlang_asm:
#   PLATFORM: LINUX|x86_64 — cc -c src/asm/runtime_panic_x86_64.s when present
#   PLATFORM: MACOS|arm64 / LINUX|aarch64 — seeds/runtime_panic_arm64.from_x.c
#   else — seeds/runtime_panic.from_x.c
# Platform stamp: build_asm/runtime_panic.$(uname -s).$(uname -m).stamp
# (create if missing; force rebuild when stamp was missing so platform switch
# cannot leave a stale .o without a matching stamp).
# Exit codes:
#   0 — OUT is panic catalog member; cold body ran (or skipped up-to-date)
#   3 — OUT not in DRIVER_SEED_PANIC_OBJS (caller residual make)
#   1 — membership found but compile failed / missing source
# PLATFORM: SHARED shell body · per-host source pick tagged above.
# PREFER_X_O=1 thin+rest → try-r2-prefer (wave776; not this cold helper).
# ---------------------------------------------------------------------------
r2_panic_host_pick_src() {
  # stdout: "asm|seed <path>" — host cold source for runtime_panic.o
  # PLATFORM: LINUX|x86_64 prefer pure-syscall .s; arm64/aarch64 arm64 seed;
  #           else portable from_x seed (incl. Darwin x86_64 / Windows).
  local uname_s uname_m
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  if [ "$uname_s" = "Linux" ] && [ "$uname_m" = "x86_64" ] \
    && [ -f src/asm/runtime_panic_x86_64.s ]; then
    printf '%s\n' "asm src/asm/runtime_panic_x86_64.s"
    return 0
  fi
  case "$uname_m" in
    arm64|aarch64)
      if [ -f seeds/runtime_panic_arm64.from_x.c ]; then
        printf '%s\n' "seed seeds/runtime_panic_arm64.from_x.c"
        return 0
      fi
      ;;
  esac
  if [ -f seeds/runtime_panic.from_x.c ]; then
    printf '%s\n' "seed seeds/runtime_panic.from_x.c"
    return 0
  fi
  echo "ensure_host_cc_seed_o r2-panic: no runtime_panic cold source for $uname_s/$uname_m" >&2
  return 1
}

ensure_r2_panic_one() {
  # Cold body for a DRIVER_SEED_PANIC_OBJS member (no membership check).
  local o="$1"
  local pick kind src stamp uname_s uname_m need=0 cand
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  stamp="build_asm/runtime_panic.${uname_s}.${uname_m}.stamp"
  mkdir -p build_asm
  if [ ! -f "$stamp" ]; then
    touch "$stamp"
    need=1
  fi
  pick="$(r2_panic_host_pick_src)" || return 1
  kind="${pick%% *}"
  src="${pick#* }"
  if [ ! -f "$src" ]; then
    echo "ensure_host_cc_seed_o r2-panic: missing source $src" >&2
    return 1
  fi
  case "$kind" in
    seed)
      # Sibling .x freshness is inside ensure_one; stamp-missing forces compile.
      # FORCE is script-global (read at ensure_one); temporarily raise when stamp was new.
      if [ "$need" = "1" ] && [ "$FORCE" != "1" ]; then
        FORCE=1
        ensure_one "$o" "$src"
        FORCE=0
      else
        ensure_one "$o" "$src"
      fi
      ;;
    asm)
      # PLATFORM: LINUX|x86_64 — plain cc -c .s (no PIPELINE_GEN_CFLAGS).
      if [ "$FORCE" != "1" ] && [ "$need" = "0" ] && [ -f "$o" ] \
        && [ ! "$src" -nt "$o" ]; then
        log "skip $o (up-to-date vs $src)"
        return 0
      fi
      log "cc -c $src → $o"
      # Stage 12.2.3: pure_as_compile (as when XLANG_ZERO_CC_AS=1, else $CC -c).
      pure_as_compile "$o" "$src"
      ;;
    *)
      echo "ensure_host_cc_seed_o r2-panic: unknown kind $kind" >&2
      return 1
      ;;
  esac
  # Keep stamp mtime after successful compile so make prereq stays satisfied.
  touch "$stamp"
  return 0
}

try_ensure_r2_one() {
  # wave760 panic + wave762 typeck_f64/crt0 — single try-r2 entry (G.7 有则补全).
  local o="$1"
  local list
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-r2: need <out.o>" >&2
    exit 2
  fi
  # 1) panic catalog
  list="$(catalog_key_words "DRIVER_SEED_PANIC_OBJS")"
  if list_has_word "$o" "$list"; then
    case "$o" in
      runtime_panic.o) ensure_r2_panic_one "$o"; return 0 ;;
      *)
        echo "ensure_host_cc_seed_o try-r2: no cold map for panic member $o" >&2
        return 1
        ;;
    esac
  fi
  # 2) typeck_f64 catalog
  list="$(catalog_key_words "DRIVER_SEED_TYPECK_F64_OBJS")"
  if list_has_word "$o" "$list"; then
    case "$o" in
      src/typeck/typeck_f64_bits.o) ensure_r2_typeck_f64_one "$o"; return 0 ;;
      *)
        echo "ensure_host_cc_seed_o try-r2: no cold map for typeck_f64 member $o" >&2
        return 1
        ;;
    esac
  fi
  # 3) crt0 catalog
  list="$(catalog_key_words "DRIVER_SEED_CRT0_OBJS")"
  if list_has_word "$o" "$list"; then
    ensure_r2_crt0_one "$o" || return 1
    return 0
  fi
  return 3
}

ensure_r2_panic() {
  local list n=0 o
  list="$(catalog_key_words "DRIVER_SEED_PANIC_OBJS")"
  if [ -z "${list// /}" ]; then
    echo "ensure_host_cc_seed_o: empty DRIVER_SEED_PANIC_OBJS" >&2
    exit 1
  fi
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    ensure_r2_panic_one "$o" || exit 1
    n=$((n + 1))
  done
  log "r2-panic OK ($n objs; catalog DRIVER_SEED_PANIC_OBJS)"
}

# ---------------------------------------------------------------------------
# wave776: try-r2-prefer OUT — R2 panic PREFER thin+rest product path.
#
# Membership = catalog DRIVER_SEED_PANIC_OBJS (lists = mk; currently
# runtime_panic.o only). G.7 有则补全 on R2 family (parallel try-r3-prefer;
# not a second list / second cold body).
#
# PREFER host pick mirrors historic Makefile ifeq tree (NOT cold pick):
#   PLATFORM: LINUX|x86_64 + runtime_panic_x86_64.s present
#     → no PREFER (pure syscall .s; cold only)
#   PLATFORM: LINUX|arm64|aarch64
#     → thin src/asm/runtime_panic_arm64.x
#       + rest seeds/runtime_panic_arm64.from_x.c -DXLANG_RUNTIME_PANIC_ARM64_FROM_X
#   PLATFORM: LINUX (other, incl. x86_64 without .s) + non-Linux (MACOS/…)
#     → thin src/asm/runtime_panic.x
#       + rest seeds/runtime_panic.from_x.c -DXLANG_RUNTIME_PANIC_FROM_X
#       (Darwin arm64 historic PREFER uses portable panic.x, not arm64.x)
#
# When XLANG_G05_PREFER_X_O=1 and xlang-c works and prefer spec non-empty:
#   thin via historic xlang-c -o (same -L / -lib-name as Makefile dual)
#   rest = $CC seed -D FROM_X
#   merge = ld $(r3_prefer_ld_r_flags) thin + rest → OUT
# Prefer fail / PREFER≠1 / pure-asm host / no xlang-c → ensure_r2_panic_one cold.
#
# Callers: Makefile runtime_panic.o (all UNAME branches; was dual hybrid).
# Exit codes:
#   0 — OUT is panic catalog member; prefer or cold body produced OUT
#   3 — OUT not in DRIVER_SEED_PANIC_OBJS
#   1 — cold compile failed / missing source
# PLATFORM: SHARED shell body · per-host PREFER pick tagged above.
# Residual after: R5 CI · physical delete · FORCE_CC named residual.
# ---------------------------------------------------------------------------

# stdout: "x_src|seed|from_x_def" or empty when PREFER not applicable (pure asm).
r2_panic_prefer_spec() {
  local uname_s uname_m
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  # PLATFORM: LINUX|x86_64 pure-syscall .s — Makefile has no PREFER dual.
  if [ "$uname_s" = "Linux" ] && [ "$uname_m" = "x86_64" ] \
    && [ -f src/asm/runtime_panic_x86_64.s ]; then
    printf '%s' ""
    return 0
  fi
  if [ "$uname_s" = "Linux" ]; then
    case "$uname_m" in
      arm64|aarch64)
        # PLATFORM: LINUX|aarch64 — arm64 thin + arm64 seed rest.
        if [ -f src/asm/runtime_panic_arm64.x ] \
          && [ -f seeds/runtime_panic_arm64.from_x.c ]; then
          printf '%s' "src/asm/runtime_panic_arm64.x|seeds/runtime_panic_arm64.from_x.c|XLANG_RUNTIME_PANIC_ARM64_FROM_X"
          return 0
        fi
        ;;
    esac
    # PLATFORM: LINUX other (or aarch64 fallback) — portable panic.x + from_x.
    if [ -f src/asm/runtime_panic.x ] && [ -f seeds/runtime_panic.from_x.c ]; then
      printf '%s' "src/asm/runtime_panic.x|seeds/runtime_panic.from_x.c|XLANG_RUNTIME_PANIC_FROM_X"
      return 0
    fi
  else
    # PLATFORM: MACOS / non-Linux — historic PREFER pair (panic.x + from_x)
    # even when cold pick uses arm64 seed on Darwin arm64.
    if [ -f src/asm/runtime_panic.x ] && [ -f seeds/runtime_panic.from_x.c ]; then
      printf '%s' "src/asm/runtime_panic.x|seeds/runtime_panic.from_x.c|XLANG_RUNTIME_PANIC_FROM_X"
      return 0
    fi
  fi
  printf '%s' ""
  return 0
}

ensure_r2_prefer_one() {
  # PREFER thin+rest or cold for one DRIVER_SEED_PANIC member (no membership check).
  local o="$1"
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local spec x_src seed from_x_def rest
  local thin_o rest_o ld_flags done=0 stale=0

  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-r2-prefer: need <out.o>" >&2
    return 2
  fi

  # PREFER thin+rest only when PREFER=1 (Darwin cold-chain safety twin of R3).
  if [ "$prefer" = "1" ]; then
    spec="$(r2_panic_prefer_spec)"
    if [ -n "$spec" ]; then
      x_src="${spec%%|*}"
      rest="${spec#*|}"
      seed="${rest%%|*}"
      from_x_def="${rest#*|}"
      if [ -f "$x_src" ] && [ -f "$seed" ] && [ -x ./xlang-c ]; then
        if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
          stale=0
          [ "$seed" -nt "$o" ] && stale=1
          [ "$x_src" -nt "$o" ] && stale=1
          # wave793: project-header mtime (FORCE thin; G.7 single body).
          if [ "$stale" = "0" ] && [ -n "$seed" ] && [ -f "$seed" ]             && seed_project_hdrs_newer "$seed" "$o"; then
            stale=1
          fi
          if [ "$stale" = "0" ]; then
            log "skip up-to-date $o (r2-prefer)"
            return 0
          fi
        fi
        thin_o="$(mktemp "${TMPDIR:-/tmp}/r2pref_thin.XXXXXX")"
        rest_o="$(mktemp "${TMPDIR:-/tmp}/r2pref_rest.XXXXXX")"
        ld_flags="$(r3_prefer_ld_r_flags)"
        # Historic Makefile: XLANG_KEEP_C=1 ./xlang-c -L … -lib-name "" -o thin .x
        # PLATFORM: SHARED product PREFER path (not -E harness; keep dual fidelity).
        # shellcheck disable=SC2086
        if XLANG_KEEP_C=1 ./xlang-c -L .. -L src -L src/asm -lib-name "" \
             -o "$thin_o" "$x_src" 2>/dev/null \
          && $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
               -D"$from_x_def" -c -o "$rest_o" "$seed" 2>/dev/null \
          && ld $ld_flags -o "$o" "$thin_o" "$rest_o" 2>/dev/null; then
          log "prefer thin.x+rest $o <- $x_src + $seed (try-r2-prefer)"
          done=1
        else
          log "r2-prefer hybrid failed for $o; fallback cold try-r2"
        fi
        rm -f "$thin_o" "$rest_o"
      fi
    fi
  fi

  if [ "$done" = "1" ]; then
    # Keep platform stamp fresh (same as cold body).
    local uname_s uname_m stamp
    uname_s="$(uname -s 2>/dev/null || echo Unknown)"
    uname_m="$(uname -m 2>/dev/null || echo unknown)"
    stamp="build_asm/runtime_panic.${uname_s}.${uname_m}.stamp"
    mkdir -p build_asm
    touch "$stamp"
    return 0
  fi

  # Cold path = try-r2 / ensure_r2_panic_one (G.7 single cold body).
  # After failed PREFER, force recompile so a partial thin.o is not left green.
  if [ "$prefer" = "1" ] && [ -f "$o" ]; then
    FORCE=1
    ensure_r2_panic_one "$o" || return 1
    FORCE=0
  else
    ensure_r2_panic_one "$o" || return 1
  fi
  return 0
}

try_ensure_r2_prefer_one() {
  local o="$1"
  local list
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-r2-prefer: need <out.o>" >&2
    exit 2
  fi
  list="$(catalog_key_words "DRIVER_SEED_PANIC_OBJS")"
  if ! list_has_word "$o" "$list"; then
    return 3
  fi
  case "$o" in
    runtime_panic.o) ensure_r2_prefer_one "$o"; return 0 ;;
    *)
      echo "ensure_host_cc_seed_o try-r2-prefer: no prefer map for panic member $o" >&2
      return 1
      ;;
  esac
}

# ---------------------------------------------------------------------------
# wave762: R2 typeck_f64_bits — host picks platform pure-.s source.
# Membership = catalog DRIVER_SEED_TYPECK_F64_OBJS (lists = mk).
# PLATFORM: LINUX|x86_64 / LINUX|aarch64 / DARWIN|arm64 / DARWIN|x86_64 /
#           WINDOWS|x86_64 mingw .s. Mirrors g05_ensure + Makefile (G.7 one body).
# ---------------------------------------------------------------------------
r2_typeck_f64_host_pick_src() {
  # stdout: path to .s for typeck_f64_bits.o on this host
  local uname_s uname_m
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  # PLATFORM: WINDOWS — MSYS/MinGW uname often MINGW64_NT-* / MSYS_NT-*.
  case "$uname_s" in
    Windows_NT*|MINGW*|MSYS*|CYGWIN*)
      if [ -f src/typeck/typeck_f64_bits_x86_64_mingw.s ]; then
        printf '%s\n' "src/typeck/typeck_f64_bits_x86_64_mingw.s"
        return 0
      fi
      ;;
  esac
  if [ "${XLANG_IS_WIN_HOST:-0}" = "1" ]; then
    if [ -f src/typeck/typeck_f64_bits_x86_64_mingw.s ]; then
      printf '%s\n' "src/typeck/typeck_f64_bits_x86_64_mingw.s"
      return 0
    fi
  fi
  case "${uname_s}/${uname_m}" in
    Linux/x86_64)
      printf '%s\n' "src/typeck/typeck_f64_bits_x86_64.s" ;;
    Linux/aarch64)
      printf '%s\n' "src/typeck/typeck_f64_bits_aarch64_elf.s" ;;
    Darwin/arm64|Darwin/aarch64)
      printf '%s\n' "src/typeck/typeck_f64_bits_arm64.s" ;;
    Darwin/x86_64|Darwin/amd64)
      printf '%s\n' "src/typeck/typeck_f64_bits_x86_64.s" ;;
    *)
      echo "ensure_host_cc_seed_o r2-typeck-f64: unsupported host $uname_s/$uname_m" >&2
      return 1
      ;;
  esac
  return 0
}

ensure_r2_typeck_f64_one() {
  local o="$1"
  local src
  src="$(r2_typeck_f64_host_pick_src)" || return 1
  if [ ! -f "$src" ]; then
    echo "ensure_host_cc_seed_o r2-typeck-f64: missing $src" >&2
    return 1
  fi
  mkdir -p "$(dirname "$o")"
  if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ ! "$src" -nt "$o" ]; then
    log "skip $o (up-to-date vs $src)"
    return 0
  fi
  log "cc -c $src → $o"
  # Stage 12.2.3: pure_as_compile (as when XLANG_ZERO_CC_AS=1, else $CC -c).
  pure_as_compile "$o" "$src"
}

ensure_r2_typeck_f64() {
  local list n=0 o
  list="$(catalog_key_words "DRIVER_SEED_TYPECK_F64_OBJS")"
  if [ -z "${list// /}" ]; then
    echo "ensure_host_cc_seed_o: empty DRIVER_SEED_TYPECK_F64_OBJS" >&2
    exit 1
  fi
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    ensure_r2_typeck_f64_one "$o" || exit 1
    n=$((n + 1))
  done
  log "r2-typeck-f64 OK ($n objs; catalog DRIVER_SEED_TYPECK_F64_OBJS)"
}

# ---------------------------------------------------------------------------
# wave762: R2 crt0 / freestanding platform leaves — fixed o→src map.
# Membership = catalog DRIVER_SEED_CRT0_OBJS. Most are plain .s; mingw is seed
# via cc_inc_tu (+ WIN32_O_CFLAGS from env/make).
# PLATFORM: LINUX crt0_x86_64 + freestanding · MACOS arm64/darwin_x86_64 ·
#           WINDOWS crt0_mingw seed.
# ---------------------------------------------------------------------------
r2_crt0_src_for_out() {
  # stdout: "asm|seed|cc_inc_tu <path>" for OUT; fail closed if unknown.
  local o="$1"
  case "$o" in
    src/asm/crt0_x86_64.o)
      printf '%s\n' "asm src/asm/crt0_x86_64.s" ;;
    src/asm/crt0_arm64.o)
      printf '%s\n' "asm src/asm/crt0_arm64.s" ;;
    src/asm/crt0_darwin_x86_64.o)
      printf '%s\n' "asm src/asm/crt0_darwin_x86_64.s" ;;
    src/asm/crt0_user_x86_64.o)
      printf '%s\n' "asm src/asm/crt0_user_x86_64.s" ;;
    src/asm/freestanding_io_x86_64.o)
      printf '%s\n' "asm src/asm/freestanding_io_x86_64.s" ;;
    src/asm/crt0_mingw.o)
      # PLATFORM: WINDOWS — .x authority prefer lane (7.2.1 second knife);
      # seed remains the no-product cold fallback.
      printf '%s\n' "cc_inc_tu_x src/crt0_mingw.x" ;;
    *)
      echo "ensure_host_cc_seed_o r2-crt0: no source map for $o" >&2
      return 1
      ;;
  esac
  return 0
}

ensure_r2_crt0_one() {
  local o="$1"
  local pick kind src
  pick="$(r2_crt0_src_for_out "$o")" || return 1
  kind="${pick%% *}"
  src="${pick#* }"
  if [ ! -f "$src" ]; then
    echo "ensure_host_cc_seed_o r2-crt0: missing $src" >&2
    return 1
  fi
  mkdir -p "$(dirname "$o")"
  case "$kind" in
    asm)
      if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ ! "$src" -nt "$o" ] \
        && ! force_thin_makefile_flags_newer "$o"; then
        log "skip $o (up-to-date vs $src)"
        return 0
      fi
      log "cc -c $src → $o"
      # Stage 12.2.3: pure_as_compile (as when XLANG_ZERO_CC_AS=1, else $CC -c).
      pure_as_compile "$o" "$src"
      ;;
    cc_inc_tu_x)
      # 7.2.1: prefer-.x leaf — cc_inc_tu --auto (product -x -E + char**
      # fixup); WIN32_O_CFLAGS pass-through like cc_inc_tu below.
      if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
        log "skip $o (prefer-.x lane: FORCE to rebuild)"
        return 0
      fi
      sh scripts/cc_inc_tu.sh --auto "$o" ${WIN32_O_CFLAGS:-}
      ;;
    cc_inc_tu)
      # PLATFORM: WINDOWS — WIN32_O_CFLAGS from env when set by caller (wave866:
      # Makefile drops WIN32_O_CFLAGS= inject; shell ${WIN32_O_CFLAGS:-} empty default).
      # wave795: Makefile mtime for flag-sensitive rebuild (force_thin_makefile_flags_newer).
      if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ ! "$src" -nt "$o" ] \
        && ! force_thin_makefile_flags_newer "$o"; then
        log "skip $o (up-to-date vs $src)"
        return 0
      fi
      if [ ! -f scripts/cc_inc_tu.sh ]; then
        echo "ensure_host_cc_seed_o r2-crt0: missing scripts/cc_inc_tu.sh" >&2
        return 1
      fi
      log "cc_inc_tu $src → $o"
      # shellcheck disable=SC2086
      sh scripts/cc_inc_tu.sh "$src" "$o" ${WIN32_O_CFLAGS:-}
      ;;
    *)
      echo "ensure_host_cc_seed_o r2-crt0: unknown kind $kind" >&2
      return 1
      ;;
  esac
  return 0
}

r2_crt0_host_relevant() {
  # Family-mode filter: catalog lists all platforms, but .s for other OS/ISA
  # live in-tree and must not be assembled by the host toolchain.
  # try-r2 OUT still runs ensure_r2_crt0_one for any member (Makefile only
  # requests the host MAIN_LINK / freestanding leaf).
  # PLATFORM: per-leaf gate below.
  local o="$1" uname_s uname_m
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  case "$o" in
    src/asm/crt0_x86_64.o|src/asm/crt0_user_x86_64.o|src/asm/freestanding_io_x86_64.o)
      [ "$uname_s" = "Linux" ] && [ "$uname_m" = "x86_64" ]
      ;;
    src/asm/crt0_arm64.o)
      [ "$uname_s" = "Darwin" ] && { [ "$uname_m" = "arm64" ] || [ "$uname_m" = "aarch64" ]; }
      ;;
    src/asm/crt0_darwin_x86_64.o)
      [ "$uname_s" = "Darwin" ] && { [ "$uname_m" = "x86_64" ] || [ "$uname_m" = "amd64" ]; }
      ;;
    src/asm/crt0_mingw.o)
      case "$uname_s" in
        Windows_NT*|MINGW*|MSYS*|CYGWIN*) return 0 ;;
      esac
      [ "${XLANG_IS_WIN_HOST:-0}" = "1" ]
      ;;
    *)
      return 1
      ;;
  esac
}

ensure_r2_crt0() {
  # Family runner: only host-relevant leaves (source present + host gate).
  local list n=0 o pick src
  list="$(catalog_key_words "DRIVER_SEED_CRT0_OBJS")"
  if [ -z "${list// /}" ]; then
    echo "ensure_host_cc_seed_o: empty DRIVER_SEED_CRT0_OBJS" >&2
    exit 1
  fi
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    if ! r2_crt0_host_relevant "$o"; then
      log "r2-crt0 skip $o (not host MAIN_LINK/freestanding leaf)"
      continue
    fi
    pick="$(r2_crt0_src_for_out "$o")" || continue
    src="${pick#* }"
    if [ ! -f "$src" ]; then
      log "r2-crt0 skip $o (source $src missing)"
      continue
    fi
    ensure_r2_crt0_one "$o" || exit 1
    n=$((n + 1))
  done
  log "r2-crt0 OK ($n host-relevant objs; catalog DRIVER_SEED_CRT0_OBJS)"
}


# ---------------------------------------------------------------------------
# wave761: try-gen-x OUT — residual gen *_x.o + pipeline_x.o (R4 pattern body).
#
# Membership (catalog only; G.7 no dual .o list):
#   lsp_io_x.o | lsp_x.o | lsp_diag_x.o ∈ DRIVER_SEED_LSP_X_OBJS
#   pipeline_x.o ∈ DRIVER_SEED_PIPELINE_X_OBJS
# Body: scripts/ensure_gen_x_o.sh one OUT (compile map + gen_driver STALE).
# Exit codes:
#   0 — OUT is gen residual member; body ran (or skipped up-to-date)
#   3 — OUT not in gen residual map / catalog
#   1 — membership found but compile failed
# PLATFORM: SHARED shell · PIPELINE_X_DEPS / FORCE from env (Makefile expands).
# ---------------------------------------------------------------------------
try_ensure_gen_x_one() {
  local o="$1"
  local list
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-gen-x: need <out.o>" >&2
    exit 2
  fi
  case "$o" in
    lsp_io_x.o|lsp_x.o|lsp_diag_x.o)
      list="$(catalog_key_words "DRIVER_SEED_LSP_X_OBJS")"
      if ! list_has_word "$o" "$list"; then
        return 3
      fi
      ;;
    pipeline_x.o)
      list="$(catalog_key_words "DRIVER_SEED_PIPELINE_X_OBJS")"
      if ! list_has_word "$o" "$list"; then
        return 3
      fi
      ;;
    *)
      return 3
      ;;
  esac
  if [ ! -f scripts/ensure_gen_x_o.sh ]; then
    echo "ensure_host_cc_seed_o try-gen-x: missing scripts/ensure_gen_x_o.sh (wave761)" >&2
    return 1
  fi
  # Propagate FORCE into gen body (same global FORCE used by ensure_one).
  if [ "$FORCE" = "1" ]; then
    XLANG_GEN_X_FORCE=1 XLANG_HOST_CC_SEED_FORCE=1 \
      bash scripts/ensure_gen_x_o.sh one "$o" || return 1
  else
    bash scripts/ensure_gen_x_o.sh one "$o" || return 1
  fi
  return 0
}

ensure_gen_x_residual() {
  # Family runner: all gen residual maps (lsp trio + pipeline).
  bash scripts/ensure_gen_x_o.sh residual-all
}

# ---------------------------------------------------------------------------
# --check: wiring + catalog keys + convention (no full compile required)
# ---------------------------------------------------------------------------
check_family() {
  # $1=KEY $2=min_count $3=label $4=seed_mode $5=optional path prefix pattern
  local key="$1"
  local min_n="$2"
  local label="$3"
  local seed_mode="${4:-basename}"
  local path_pfx="${5:-}"
  local list n=0 o seed
  if ! list="$(catalog_key_list "$key" 2>/dev/null)"; then
    bad "catalog cannot expand $key (add export key)"
    return
  fi
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    n=$((n + 1))
    case "$seed_mode" in
      basename) seed="$(seed_for_o "$o")" ;;
      frontend-glue)
        if ! seed="$(seed_for_frontend_glue "$o" 2>/dev/null)"; then
          bad "frontend-glue map missing for catalog member $o"
          continue
        fi
        ;;
      main-runtime)
        if ! seed="$(seed_for_main_runtime "$o" 2>/dev/null)"; then
          bad "main-runtime map missing for catalog member $o"
          continue
        fi
        # extras map must also resolve (fail closed)
        if ! extras_for_main_runtime "$o" >/dev/null 2>&1; then
          bad "main-runtime extras map missing for catalog member $o"
        fi
        ;;
      extra-cflags)
        if ! seed="$(seed_for_extra_cflags "$o" 2>/dev/null)"; then
          bad "extra-cflags map missing for catalog member $o"
          continue
        fi
        if ! extras_for_extra_cflags "$o" >/dev/null 2>&1; then
          bad "extra-cflags extras map missing for catalog member $o"
        fi
        ;;
      seed-map)
        if ! seed="$(seed_for_seed_map "$o" 2>/dev/null)"; then
          bad "seed-map map missing for catalog member $o"
          continue
        fi
        if ! extras_for_seed_map "$o" >/dev/null 2>&1; then
          bad "seed-map extras map missing for catalog member $o"
        fi
        ;;
      *) bad "unknown seed_mode $seed_mode for $label"; continue ;;
    esac
    if [ ! -f "$seed" ]; then
      bad "missing seed for $o → $seed ($label)"
    fi
    if [ -n "$path_pfx" ]; then
      case "$o" in
        ${path_pfx}*) ;;
        *) bad "$label .o not under $path_pfx: $o" ;;
      esac
    fi
  done
  if [ "$n" -lt "$min_n" ]; then
    bad "$key count $n < $min_n ($label)"
  else
    note "catalog $key n=$n ($label)"
  fi
}

run_check() {
  local fail=0
  note() { echo "ensure_host_cc_seed_o: $*" >&2; }
  bad() { echo "ensure_host_cc_seed_o: FAIL: $*" >&2; fail=1; }

  # -------------------------------------------------------------------------
  # wave964 post_ship: Makefile physically deleted (wave941). Catalog + shell
  # own host-cc seed/.o; MF thin-call residual inventory is N/A.
  # PLATFORM: SHARED — structural honesty only (no product compile); dual-end L2.
  # -------------------------------------------------------------------------
  if [ ! -f Makefile ]; then
    local _ps_key _ps_keys _ps_cache
    if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
      bad "missing driver_seed_obj_catalog.sh (wave964 post_ship)"
    else
      note "catalog script present (wave964 post_ship)"
    fi
    if [ ! -f mk/driver_seed_r_lists.mk ]; then
      bad "missing mk/driver_seed_r_lists.mk (wave964; R* list authority)"
    fi
    # Warm file cache once: catalog_key_list uses `catalog_blob | sed` (pipe
    # subshell loses in-process _catalog_blob_cache). Without a file cache,
    # each family re-parses mk (~9s × N) and --check looks hung.
    # PLATFORM: SHARED — same cache contract as bootstrap/ensure_prereqs.
    _ps_cache="${TMPDIR:-/tmp}/xlang_ensure_host_cc_check_$$.catalog"
    if bash scripts/driver_seed_obj_catalog.sh --shell >"$_ps_cache" 2>/dev/null \
      && [ -s "$_ps_cache" ]; then
      export XLANG_CATALOG_CACHE_FILE="$_ps_cache"
      note "catalog cache warm for --check (wave964 post_ship)"
    else
      rm -f "$_ps_cache" 2>/dev/null || true
      note "catalog cache warm skipped; in-process only (wave964)"
    fi
    # List authority lives in mk/*.mk (catalog re-exports). Not Makefile.
    _ps_keys="RT_SEED_SLICE_OBJS R1_CORE_SEED_OBJS R1_FRONTEND_GLUE_OBJS R1_MAIN_RUNTIME_OBJS \
R1_ALIAS_STUBS_OBJS R1_EXTRA_CFLAGS_OBJS R1_MISC_BASENAME_OBJS R1_SEED_MAP_OBJS \
R3_COLD_SEED_OBJS DRIVER_SEED_PANIC_OBJS DRIVER_SEED_TYPECK_F64_OBJS DRIVER_SEED_CRT0_OBJS"
    # shellcheck disable=SC2086
    for _ps_key in $_ps_keys; do
      if ! grep -q "$_ps_key" mk/*.mk 2>/dev/null; then
        bad "$_ps_key not defined in mk/*.mk (wave964 post_ship)"
      fi
    done
    # Catalog expand + seed map resolve (G.7 lists stay mk; shell owns seed paths).
    check_family "RT_SEED_SLICE_OBJS" 5 "rt-slice" "basename" "src/runtime/"
    check_family "R1_CORE_SEED_OBJS" 5 "core-seed" "basename" "src/"
    check_family "R1_FRONTEND_GLUE_OBJS" 3 "frontend-glue" "frontend-glue" "src/"
    check_family "R1_MAIN_RUNTIME_OBJS" 7 "main-runtime" "main-runtime" "src/"
    check_family "R1_ALIAS_STUBS_OBJS" 8 "alias-stubs" "basename" ""
    check_family "R1_EXTRA_CFLAGS_OBJS" 5 "extra-cflags" "extra-cflags" ""
    # Floors track mk/driver_seed_r_lists.mk (post_ship; was misc=9 seed-map=5).
    check_family "R1_MISC_BASENAME_OBJS" 8 "misc-basename" "basename" ""
    check_family "R1_SEED_MAP_OBJS" 4 "seed-map" "seed-map" ""
    check_family "R3_COLD_SEED_OBJS" 9 "r3-cold-seed" "basename" ""
    {
      local panic_list panic_n=0 po pick
      if ! panic_list="$(catalog_key_list "DRIVER_SEED_PANIC_OBJS" 2>/dev/null)"; then
        bad "catalog cannot expand DRIVER_SEED_PANIC_OBJS (wave964 post_ship)"
      else
        # shellcheck disable=SC2086
        for po in $panic_list; do
          [ -z "$po" ] && continue
          panic_n=$((panic_n + 1))
        done
        if [ "$panic_n" -lt 1 ]; then
          bad "DRIVER_SEED_PANIC_OBJS empty (wave964 post_ship)"
        else
          note "catalog DRIVER_SEED_PANIC_OBJS n=$panic_n (r2-panic)"
        fi
        if ! pick="$(r2_panic_host_pick_src 2>/dev/null)"; then
          bad "r2_panic_host_pick_src failed on this host (wave964 post_ship)"
        else
          note "r2-panic host pick: $pick"
        fi
      fi
    }
    {
      local f64_list f64_n=0 fo f64_src crt0_list crt0_n=0 co
      if ! f64_list="$(catalog_key_list "DRIVER_SEED_TYPECK_F64_OBJS" 2>/dev/null)"; then
        bad "catalog cannot expand DRIVER_SEED_TYPECK_F64_OBJS (wave964 post_ship)"
      else
        # shellcheck disable=SC2086
        for fo in $f64_list; do
          [ -z "$fo" ] && continue
          f64_n=$((f64_n + 1))
        done
        if [ "$f64_n" -lt 1 ]; then
          bad "DRIVER_SEED_TYPECK_F64_OBJS empty (wave964 post_ship)"
        else
          note "catalog DRIVER_SEED_TYPECK_F64_OBJS n=$f64_n (r2-typeck-f64)"
        fi
        if ! f64_src="$(r2_typeck_f64_host_pick_src 2>/dev/null)"; then
          bad "r2_typeck_f64_host_pick_src failed on this host (wave964 post_ship)"
        else
          note "r2-typeck-f64 host pick: $f64_src"
        fi
      fi
      if ! crt0_list="$(catalog_key_list "DRIVER_SEED_CRT0_OBJS" 2>/dev/null)"; then
        bad "catalog cannot expand DRIVER_SEED_CRT0_OBJS (wave964 post_ship)"
      else
        # shellcheck disable=SC2086
        for co in $crt0_list; do
          [ -z "$co" ] && continue
          crt0_n=$((crt0_n + 1))
        done
        if [ "$crt0_n" -lt 1 ]; then
          bad "DRIVER_SEED_CRT0_OBJS empty (wave964 post_ship)"
        else
          note "catalog DRIVER_SEED_CRT0_OBJS n=$crt0_n (r2-crt0)"
        fi
      fi
    }
    # G.7: list authority is catalog/mk only — no hardcoded assignment of product lists.
    if grep -nE '^(export )?RT_SEED_SLICE_OBJS=' "$0" 2>/dev/null \
      | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
      bad "must not hardcode RT_SEED_SLICE_OBJS= in shell body"
    fi
    if grep -nE '^(export )?R1_CORE_SEED_OBJS=' "$0" 2>/dev/null \
      | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
      bad "must not hardcode R1_CORE_SEED_OBJS= in shell body"
    fi
    if grep -nE '^(export )?DRIVER_SEED_PANIC_OBJS=' "$0" 2>/dev/null \
      | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
      bad "must not hardcode DRIVER_SEED_PANIC_OBJS= in shell body"
    fi
    # Shell ladder / bodies still required after MF delete.
    if ! grep -q 'try_ensure_r1_one\|try-r1' "$0"; then
      bad "try-r1 / try_ensure_r1_one missing (wave756/964)"
    else
      note "try-r1 pure-R1 helper present (wave964 post_ship)"
    fi
    if ! grep -q 'try_ensure_r3_cold_one\|try-r3-cold' "$0"; then
      bad "try-r3-cold missing (wave757/964)"
    else
      note "try-r3-cold helper present (wave964 post_ship)"
    fi
    if ! grep -q 'try_ensure_r2_one\|try-r2' "$0"; then
      bad "try-r2 / try_ensure_r2_one missing (wave760/762/964)"
    else
      note "try-r2 R2 UNAME helper present (wave964 post_ship)"
    fi
    if ! grep -q 'try_heat_one\|try-heat' "$0"; then
      bad "try-heat / try_heat_one missing (wave789/964 B7A heat)"
    else
      note "try-heat B7A heat auto-dispatch present (wave964 post_ship)"
    fi
    if ! grep -q '_load_try_heat_cflags_via_catalog\|export-try-heat-cflags' "$0"; then
      bad "shell must load try-heat CFLAGS via catalog (wave862/942/964)"
    else
      note "try-heat CFLAGS catalog-load present (wave964 post_ship)"
    fi
    if ! grep -q 'try_ensure_gen_x_one\|try-gen-x' "$0"; then
      bad "try-gen-x / try_ensure_gen_x_one missing (wave761/964)"
    else
      note "try-gen-x gen residual helper present (wave964 post_ship)"
    fi
    if [ ! -f scripts/ensure_gen_x_o.sh ]; then
      bad "scripts/ensure_gen_x_o.sh missing (wave761/964)"
    else
      note "ensure_gen_x_o.sh present (wave964 post_ship)"
    fi
    # wave950: cfg-eval soft missing xlang-c → ensure_xlang_c.sh (0-make).
    if grep -E '^[[:space:]]+\$MAKE[[:space:]]+xlang-c' "$0" 2>/dev/null | grep -q .; then
      bad "cfg-eval ladder must not residual bare make xlang-c (wave950/964; ensure_xlang_c.sh)"
    fi
    if ! grep -q 'ensure_xlang_c\.sh ensure' "$0" 2>/dev/null; then
      bad "cfg-eval ladder must soft-call ensure_xlang_c.sh for missing xlang-c (wave950/964)"
    else
      note "cfg-eval soft xlang-c → ensure_xlang_c.sh (wave964 post_ship; 0-make)"
    fi
    if ! grep -q 'seed_project_hdrs_newer' "$0"; then
      bad "seed_project_hdrs_newer missing (wave793/964)"
    else
      note "seed_project_hdrs_newer present (wave964 post_ship)"
    fi
    if ! grep -q 'force_thin_makefile_flags_newer' "$0"; then
      bad "force_thin_makefile_flags_newer missing (wave794/964)"
    else
      note "force_thin_makefile_flags_newer present (wave964 post_ship)"
    fi
    if ! grep -q 'udp_batch.x' "$0" || ! grep -q 'runtime_net_sock_fast.from_x.c' "$0"; then
      bad "net_merge multi-source mtime missing (wave796/964)"
    else
      note "net_merge multi-source mtime present (wave964 post_ship)"
    fi
    # B4 gen-c-to-o table (shell owns map; MF multi-target gone).
    if ! grep -q 'gen_c_to_o_spec_for_out\|try_ensure_gen_c_to_o_one' "$0"; then
      bad "gen-c-to-o table/body missing (wave782/964)"
    else
      note "gen-c-to-o table present (wave964 post_ship)"
    fi
    _b4_n=0
    for _b4_leaf in lexer_x.o ast_gen2.o driver_x.o preprocess_x.o; do
      if [ -n "$(gen_c_to_o_spec_for_out "$_b4_leaf" 2>/dev/null || true)" ]; then
        _b4_n=$((_b4_n + 1))
      else
        bad "gen_c_to_o_spec_for_out missing $_b4_leaf (wave782/964/295)"
      fi
    done
    if [ "$_b4_n" -ne 4 ]; then
      bad "gen-c-to-o table size $_b4_n != 4 (wave782/964/295 B4 heat)"
    else
      note "gen-c-to-o table has 4 members (wave295 post_ship; stubs2 left)"
    fi
    # B5 cfg-eval ladder table.
    if ! grep -q 'cfg_eval_ladder_spec_for_out\|ensure_cfg_eval_ladder_one\|try-cfg-eval-ladder' "$0"; then
      bad "cfg-eval ladder table/body missing (wave783/964)"
    else
      note "cfg-eval ladder present (wave964 post_ship)"
    fi
    if [ -n "$(cfg_eval_ladder_spec_for_out "src/lexer/cfg_eval.o" 2>/dev/null || true)" ]; then
      note "cfg_eval_ladder_spec_for_out has src/lexer/cfg_eval.o (wave964 post_ship)"
    else
      bad "cfg_eval_ladder_spec_for_out missing src/lexer/cfg_eval.o (wave783/964)"
    fi
    # Prefer helpers still present (product path via try-heat ladder).
    if ! grep -q 'try_ensure_runtime_os_prefer_one' "$0" \
      || ! grep -q 'try_ensure_r1_one' "$0" \
      || ! grep -q 'try_ensure_gen_x_one' "$0"; then
      bad "try-heat ladder requires existing try-* helpers (wave789/964)"
    else
      note "try-heat ladder deps present (prefer/R1/gen; wave964 post_ship)"
    fi
    if [ -n "${_ps_cache:-}" ]; then
      rm -f "$_ps_cache" 2>/dev/null || true
    fi
    if [ "$fail" -ne 0 ]; then
      echo "ensure_host_cc_seed_o: --check FAILED (wave964 post_ship)" >&2
      exit 1
    fi
    echo "ensure_host_cc_seed_o: CHECK OK (wave964 post_ship; catalog+shell R1/R3/R2/gen-x/try-heat; MF thin residual N/A after wave941 phys-del; 0-make)" >&2
    exit 0
  fi

  # wave907–915 G.7: multi-target FORCE try-heat covers many historical per-leaf prefer
  # checks (R1/R3/ASYNC/B1 / GEN_X / GEN_C_TO_O / B3_LSP_SAT / FMT_CHECK / R2 CRT0 / TYPECK_F64 / PANIC).
  # Accept per-leaf OR membership in a multi-target list whose recipe thin-calls ensure
  # try-heat (prefer / gen-x / gen-c-to-o / lsp-sat / other-l2 / try-r2 ladder lives in shell).
  # Archaeology: this block runs only when Makefile is present (pre_ship / restored MF).
  makefile_leaf_try_heat_ok() {
    local leaf="$1"
    local prefer_re="${2:-try-heat}"
    if awk -v leaf="$leaf" -v pre="$prefer_re" '
      $0 ~ ("^" leaf ":") {grab=1; next}
      grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
      grab {body = body $0 "\n"}
      END {
        if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ pre) exit 0
        exit 1
      }
    ' Makefile; then
      return 0
    fi
    local mk="mk/driver_seed_r_lists.mk"
    local var
    for var in \
      RT_SEED_SLICE_OBJS R1_CORE_SEED_OBJS R1_FRONTEND_GLUE_OBJS R1_MAIN_RUNTIME_OBJS \
      R1_ALIAS_STUBS_OBJS R1_EXTRA_CFLAGS_OBJS R1_MISC_BASENAME_OBJS R1_SEED_MAP_OBJS \
      R3_COLD_SEED_OBJS ASYNC_THREE_SEED_OBJS B1_RUNTIME_OS_SEED_OBJS GEN_X_SEED_OBJS \
      GEN_C_TO_O_SEED_OBJS B3_LSP_SAT_SEED_OBJS FMT_CHECK_SEED_OBJS DRIVER_SEED_CRT0_OBJS DRIVER_SEED_TYPECK_F64_OBJS DRIVER_SEED_PANIC_OBJS DRIVER_SEED_CFG_EVAL_OBJS; do
      if [ ! -f "$mk" ]; then
        continue
      fi
      if ! awk -v var="$var" -v leaf="$leaf" '
        /^[[:space:]]*#/ { next }
        $0 ~ ("^" var "[[:space:]]*=") {
          line=$0
          sub(/#.*/,"",line)
          n=split(line, a, /[[:space:]\\]+/)
          for (i=1;i<=n;i++) if (a[i]==leaf) { found=1; exit 0 }
        }
        END { exit found ? 0 : 1 }
      ' "$mk"; then
        continue
      fi
      if grep -qE "\\$\\(${var}\\):[[:space:]]*FORCE" Makefile 2>/dev/null \
        && awk -v var="$var" '
          $0 ~ ("\\$\\(" var "\\):") { hit=1; next }
          hit && /^[^#[:space:]\t]/ { exit 1 }
          hit && /ensure_host_cc_seed_o\.sh/ && /try-heat/ { found=1; exit 0 }
          END { exit found ? 0 : 1 }
        ' Makefile; then
        return 0
      fi
    done
    # B2 std_core hybrid multi-target (separate mk)
    local b2mk="mk/std_core_hybrid_product_objs.mk"
    if [ -f "$b2mk" ] \
      && awk -v leaf="$leaf" '
        /^[[:space:]]*#/ { next }
        /STD_CORE_HYBRID_PRODUCT_OBJS/ {
          line=$0
          sub(/#.*/,"",line)
          n=split(line, a, /[[:space:]\\]+/)
          for (i=1;i<=n;i++) if (a[i]==leaf) { found=1; exit 0 }
        }
        END { exit found ? 0 : 1 }
      ' "$b2mk" \
      && grep -qE '\$\(STD_CORE_HYBRID_PRODUCT_OBJS\):[[:space:]]*FORCE' Makefile 2>/dev/null \
      && awk '
        /\$\(STD_CORE_HYBRID_PRODUCT_OBJS\):/ { hit=1; next }
        hit && /^[^#[:space:]\t]/ { exit 1 }
        hit && /ensure_host_cc_seed_o\.sh/ && /try-heat/ { found=1; exit 0 }
        END { exit found ? 0 : 1 }
      ' Makefile; then
      return 0
    fi
    return 1
  }

  if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
    bad "missing driver_seed_obj_catalog.sh"
  fi
  if ! grep -q 'RT_SEED_SLICE_OBJS' Makefile \
    && ! grep -q 'RT_SEED_SLICE_OBJS' mk/*.mk 2>/dev/null; then
    bad "RT_SEED_SLICE_OBJS not defined in Makefile/mk"
  fi
  if ! grep -q 'R1_CORE_SEED_OBJS' Makefile \
    && ! grep -q 'R1_CORE_SEED_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_CORE_SEED_OBJS not defined in Makefile/mk (wave749)"
  fi
  if ! grep -q 'R1_FRONTEND_GLUE_OBJS' Makefile \
    && ! grep -q 'R1_FRONTEND_GLUE_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_FRONTEND_GLUE_OBJS not defined in Makefile/mk (wave750)"
  fi
  if ! grep -q 'R1_MAIN_RUNTIME_OBJS' Makefile \
    && ! grep -q 'R1_MAIN_RUNTIME_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_MAIN_RUNTIME_OBJS not defined in Makefile/mk (wave751)"
  fi
  if ! grep -q 'R1_ALIAS_STUBS_OBJS' Makefile \
    && ! grep -q 'R1_ALIAS_STUBS_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_ALIAS_STUBS_OBJS not defined in Makefile/mk (wave752)"
  fi
  if ! grep -q 'R1_EXTRA_CFLAGS_OBJS' Makefile \
    && ! grep -q 'R1_EXTRA_CFLAGS_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_EXTRA_CFLAGS_OBJS not defined in Makefile/mk (wave753)"
  fi
  if ! grep -q 'R1_MISC_BASENAME_OBJS' Makefile \
    && ! grep -q 'R1_MISC_BASENAME_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_MISC_BASENAME_OBJS not defined in Makefile/mk (wave754)"
  fi
  if ! grep -q 'R1_SEED_MAP_OBJS' Makefile \
    && ! grep -q 'R1_SEED_MAP_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_SEED_MAP_OBJS not defined in Makefile/mk (wave755)"
  fi
  if ! grep -q 'R3_COLD_SEED_OBJS' Makefile \
    && ! grep -q 'R3_COLD_SEED_OBJS' mk/*.mk 2>/dev/null; then
    bad "R3_COLD_SEED_OBJS not defined in Makefile/mk (wave757)"
  fi
  if ! grep -q 'DRIVER_SEED_PANIC_OBJS' Makefile \
    && ! grep -q 'DRIVER_SEED_PANIC_OBJS' mk/*.mk 2>/dev/null; then
    bad "DRIVER_SEED_PANIC_OBJS not defined in Makefile/mk (wave760 R2 panic list)"
  fi

  check_family "RT_SEED_SLICE_OBJS" 5 "rt-slice" "basename" "src/runtime/"
  check_family "R1_CORE_SEED_OBJS" 5 "core-seed" "basename" "src/"
  check_family "R1_FRONTEND_GLUE_OBJS" 3 "frontend-glue" "frontend-glue" "src/"
  check_family "R1_MAIN_RUNTIME_OBJS" 7 "main-runtime" "main-runtime" "src/"
  # alias-stubs: mixed cwd-root and src/ paths; no single path prefix.
  check_family "R1_ALIAS_STUBS_OBJS" 8 "alias-stubs" "basename" ""
  # extra-cflags: mixed paths; multi-flag map.
  check_family "R1_EXTRA_CFLAGS_OBJS" 5 "extra-cflags" "extra-cflags" ""
  # misc-basename: mixed cwd-root / src/ / build_asm/ paths; pure basename.
  # Floor tracks mk (post_ship; was 9).
  check_family "R1_MISC_BASENAME_OBJS" 8 "misc-basename" "basename" ""
  # seed-map: mismatch stems + orch extras + thin_glue (wave758).
  # Floor tracks mk (post_ship; was 5).
  check_family "R1_SEED_MAP_OBJS" 4 "seed-map" "seed-map" ""
  # R3 cold-else: thin+rest leaves cold path = pure basename host-cc.
  check_family "R3_COLD_SEED_OBJS" 9 "r3-cold-seed" "basename" ""
  # R2 panic: catalog list must resolve; seed/asm pick must work on this host.
  {
    local panic_list panic_n=0 po pick
    if ! panic_list="$(catalog_key_list "DRIVER_SEED_PANIC_OBJS" 2>/dev/null)"; then
      bad "catalog cannot expand DRIVER_SEED_PANIC_OBJS (wave760)"
    else
      # shellcheck disable=SC2086
      for po in $panic_list; do
        [ -z "$po" ] && continue
        panic_n=$((panic_n + 1))
      done
      if [ "$panic_n" -lt 1 ]; then
        bad "DRIVER_SEED_PANIC_OBJS empty (wave760)"
      else
        note "catalog DRIVER_SEED_PANIC_OBJS n=$panic_n (r2-panic)"
      fi
      if ! pick="$(r2_panic_host_pick_src 2>/dev/null)"; then
        bad "r2_panic_host_pick_src failed on this host (wave760)"
      else
        note "r2-panic host pick: $pick"
      fi
    fi
  }
  # wave762: typeck_f64 + crt0 catalogs + host pick / map
  {
    local f64_list f64_n=0 fo f64_src crt0_list crt0_n=0 co
    if ! f64_list="$(catalog_key_list "DRIVER_SEED_TYPECK_F64_OBJS" 2>/dev/null)"; then
      bad "catalog cannot expand DRIVER_SEED_TYPECK_F64_OBJS (wave762)"
    else
      # shellcheck disable=SC2086
      for fo in $f64_list; do
        [ -z "$fo" ] && continue
        f64_n=$((f64_n + 1))
      done
      if [ "$f64_n" -lt 1 ]; then
        bad "DRIVER_SEED_TYPECK_F64_OBJS empty (wave762)"
      else
        note "catalog DRIVER_SEED_TYPECK_F64_OBJS n=$f64_n (r2-typeck-f64)"
      fi
      if ! f64_src="$(r2_typeck_f64_host_pick_src 2>/dev/null)"; then
        bad "r2_typeck_f64_host_pick_src failed on this host (wave762)"
      else
        note "r2-typeck-f64 host pick: $f64_src"
      fi
    fi
    if ! crt0_list="$(catalog_key_list "DRIVER_SEED_CRT0_OBJS" 2>/dev/null)"; then
      bad "catalog cannot expand DRIVER_SEED_CRT0_OBJS (wave762)"
    else
      # shellcheck disable=SC2086
      for co in $crt0_list; do
        [ -z "$co" ] && continue
        crt0_n=$((crt0_n + 1))
      done
      if [ "$crt0_n" -lt 1 ]; then
        bad "DRIVER_SEED_CRT0_OBJS empty (wave762)"
      else
        note "catalog DRIVER_SEED_CRT0_OBJS n=$crt0_n (r2-crt0)"
      fi
    fi
  }

  # Makefile thin: recipes must call this script (not inline $(CC) -c for swallowed leaves)
  if ! grep -q 'ensure_host_cc_seed_o\.sh' Makefile; then
    bad "Makefile must thin-call ensure_host_cc_seed_o.sh for R1 families"
  else
    note "Makefile thin-call present"
  fi
  # Core-seed leaves must not keep inline $(CC) -c recipes (thin only).
  if grep -A1 -E '^(src/diag\.o|src/runtime_link_abi\.o|src/runtime_c_import\.o|src/x_seed_bridge\.o|src/seed_link_compat\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile core-seed leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile core-seed leaves thin (no inline \$(CC) -c)"
  fi
  # Frontend-glue leaves must not keep inline $(CC) -c recipes.
  if grep -A1 -E '^(src/lexer/lexer\.o|src/ast/ast\.o|src/lsp/lsp_diag\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile frontend-glue leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile frontend-glue leaves thin (no inline \$(CC) -c)"
  fi
  # Main-runtime leaves must not keep inline $(CC) -c recipes.
  if grep -A1 -E '^(src/main\.o|src/main_x\.o|src/main_driver\.o|src/runtime\.o|src/runtime_x\.o|src/runtime_driver\.o|src/runtime_driver_no_c\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile main-runtime leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile main-runtime leaves thin (no inline \$(CC) -c)"
  fi
  # Alias-stubs leaves must not keep inline $(CC) -c recipes.
  if grep -A1 -E '^(x_frontend_link_alias\.o|ast_asm_bare_link_alias\.o|backend_asm_bare_link_alias\.o|backend_asm_strict_fallback_alias\.o|typeck_c_module_stubs\.o|src/asm/user_asm_seed_bridge\.o|src/asm/asm_backend_compat_stubs\.o|src/runtime_driver_strict_glue_stubs\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile alias-stubs leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile alias-stubs leaves thin (no inline \$(CC) -c)"
  fi
  # Extra-cflags leaves must not keep inline $(CC) -c recipes.
  if grep -A1 -E '^(src/runtime_pipeline_abi\.o|runtime_asm_io_stubs\.o|runtime_sqlite_glue\.o|runtime_sqlite_glue_stub\.o|src/asm/parser_asm_parse_expr_link\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile extra-cflags leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile extra-cflags leaves thin (no inline \$(CC) -c)"
  fi
  # Misc-basename leaves must not keep inline $(CC) -c recipes.
  if grep -A2 -E '^(runtime_link_abi_user_env\.o|runtime_channel_glue\.o|runtime_scheduler_glue\.o|runtime_kv_mmap_glue\.o|src/asm/backend_x86_64_enc_c\.o|src/asm/backend_arm64_enc_c\.o|src/lsp/lsp_diag_pipeline_ctx\.o|build_asm/pipeline_glue_strict_minimal\.o|src/asm/runtime_asm_build\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile misc-basename leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile misc-basename leaves thin (no inline \$(CC) -c)"
  fi
  # Seed-map leaves must not keep inline $(CC) -c recipes (incl. thin_glue wave758).
  if grep -A2 -E '^(src/driver/target_cpu\.o|src/ast/ast_seed\.o|pipeline_bootstrap_orchestration\.o|parser_asm_thin_glue\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile seed-map leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile seed-map leaves thin (no inline \$(CC) -c; wave758 thin_glue)"
  fi
  # wave759: glue standalone target is $(ASM_GLUE_STANDALONE_O) — recipe must call ensure,
  # not residual cc_inc_tu (G.7 single body via ensure_one).
  # wave905: leaf joined multi-target $(R1_SEED_MAP_OBJS): FORCE try-heat (no per-leaf line).
  if awk '
    /^\$\(ASM_GLUE_STANDALONE_O\):|^build_asm\/pipeline_glue_standalone\.o:/ { in_t=1; next }
    in_t && /^[^[:space:]#]/ { in_t=0 }
    in_t { body = body $0 "\n" }
    END {
      if (body ~ /ensure_host_cc_seed_o\.sh/ && body !~ /cc_inc_tu\.sh/) exit 0
      exit 1
    }
  ' Makefile; then
    note "Makefile glue standalone thin (ensure; no cc_inc_tu; wave759)"
  elif grep -qE '\$\(R1_SEED_MAP_OBJS\):[[:space:]]*FORCE' Makefile 2>/dev/null \
    && grep -qF 'build_asm/pipeline_glue_standalone.o' mk/driver_seed_r_lists.mk 2>/dev/null \
    && awk '
      /\$\(R1_SEED_MAP_OBJS\):/ { hit=1; next }
      hit && /^[^#[:space:]\t]/ { exit 1 }
      hit && /ensure_host_cc_seed_o\.sh/ && /try-heat/ { found=1; exit 0 }
      END { exit found ? 0 : 1 }
    ' Makefile; then
    note "Makefile glue standalone via multi-target R1_SEED_MAP try-heat (wave905)"
  else
    bad "Makefile ASM_GLUE_STANDALONE / pipeline_glue_standalone must thin-call ensure (wave759/905; no cc_inc_tu)"
  fi

  # G.7: list authority is catalog only — no hardcoded assignment of product lists.
  if grep -nE '^(export )?RT_SEED_SLICE_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode RT_SEED_SLICE_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_CORE_SEED_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_CORE_SEED_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_FRONTEND_GLUE_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_FRONTEND_GLUE_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_MAIN_RUNTIME_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_MAIN_RUNTIME_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_ALIAS_STUBS_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_ALIAS_STUBS_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_EXTRA_CFLAGS_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_EXTRA_CFLAGS_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_MISC_BASENAME_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_MISC_BASENAME_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_SEED_MAP_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_SEED_MAP_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R3_COLD_SEED_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R3_COLD_SEED_OBJS= in shell body"
  fi
  if grep -nE '^(export )?DRIVER_SEED_PANIC_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode DRIVER_SEED_PANIC_OBJS= in shell body (wave760)"
  fi
  if grep -nE '^(export )?DRIVER_SEED_TYPECK_F64_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode DRIVER_SEED_TYPECK_F64_OBJS= in shell body (wave762)"
  fi
  if grep -nE '^(export )?DRIVER_SEED_CRT0_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode DRIVER_SEED_CRT0_OBJS= in shell body (wave762)"
  fi

  # wave760 + wave776 + wave915: Makefile panic must thin-call try-heat|try-r2-prefer|try-r2.
  # wave915: multi-target $(DRIVER_SEED_PANIC_OBJS): FORCE try-heat (list in r_lists).
  if grep -qE '\$\(DRIVER_SEED_PANIC_OBJS\):[[:space:]]*FORCE' Makefile 2>/dev/null \
    && awk '
      /\$\(DRIVER_SEED_PANIC_OBJS\):/ { hit=1; next }
      hit && /^[^#[:space:]\t]/ { exit 1 }
      hit && /ensure_host_cc_seed_o\.sh/ && /try-heat|try-r2-prefer|try-r2/ { found=1; exit 0 }
      END { exit found ? 0 : 1 }
    ' Makefile; then
    note "Makefile R2 PANIC multi-target FORCE thin try-heat (wave915)"
  elif awk '
    /^runtime_panic\.o:/ { in_t=1; next }
    in_t && /^[^[:space:]#]/ { in_t=0 }
    in_t { body = body $0 "\n" }
    END {
      if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-heat|try-r2-prefer|try-r2|r2-panic|try_r2/) exit 0
      exit 1
    }
  ' Makefile; then
    note "Makefile runtime_panic thin-calls ensure try-r2-prefer/try-r2 (wave760/776)"
  else
    bad "Makefile runtime_panic.o must thin-call ensure try-heat|try-r2-prefer or try-r2 (wave776/915 multi-target)"
  fi
  # wave776: ban dual hybrid (inline xlang-c thin + seed rest + ld -r).
  # wave915: multi-target recipe body must also stay thin (no dual hybrid).
  if grep -qE '\$\(DRIVER_SEED_PANIC_OBJS\):[[:space:]]*FORCE' Makefile 2>/dev/null \
    && awk '
      /\$\(DRIVER_SEED_PANIC_OBJS\):/ { hit=1; next }
      hit && /^[^#[:space:]\t]/ { exit 0 }
      hit {
        body = body $0 "\n"
      }
      END {
        if (body ~ /runtime_panic\.thin\.o/ && body ~ /runtime_panic\.rest\.o/) exit 1
        if (body ~ /XLANG_RUNTIME_PANIC_FROM_X/ && body ~ /ld -r/) exit 1
        if (body ~ /\.\/xlang-c/ && body ~ /runtime_panic/ && body ~ /ld -r/) exit 1
        exit 0
      }
    ' Makefile; then
    note "Makefile runtime_panic multi-target has no dual hybrid body (wave776/915)"
  elif awk '
    /^runtime_panic\.o:/ { in_t=1; next }
    in_t && /^[^[:space:]#]/ { in_t=0 }
    in_t { body = body $0 "\n" }
    END {
      if (body ~ /runtime_panic\.thin\.o/ && body ~ /runtime_panic\.rest\.o/) exit 1
      if (body ~ /XLANG_RUNTIME_PANIC_FROM_X/ && body ~ /ld -r/) exit 1
      if (body ~ /\.\/xlang-c/ && body ~ /runtime_panic/ && body ~ /ld -r/) exit 1
      exit 0
    }
  ' Makefile; then
    note "Makefile runtime_panic has no dual hybrid body (wave776)"
  else
    bad "Makefile runtime_panic.o still has dual hybrid PREFER body (wave776)"
  fi
  if ! grep -q 'try_ensure_r2_prefer_one\|try-r2-prefer' "$0"; then
    bad "try-r2-prefer / try_ensure_r2_prefer_one missing (wave776)"
  else
    note "try-r2-prefer helper present (wave776)"
  fi

  # wave762/914: typeck_f64 must thin-call try-heat|try-r2 (no inline $(CC) -c).
  # wave914: multi-target $(DRIVER_SEED_TYPECK_F64_OBJS): FORCE try-heat (UNAME gates dropped).
  if grep -qE '\$\(DRIVER_SEED_TYPECK_F64_OBJS\):[[:space:]]*FORCE' Makefile 2>/dev/null \
    && awk '
      /\$\(DRIVER_SEED_TYPECK_F64_OBJS\):/ { hit=1; next }
      hit && /^[^#[:space:]\t]/ { exit 1 }
      hit && /ensure_host_cc_seed_o\.sh/ && /try-heat|try-r2/ { found=1; exit 0 }
      END { exit found ? 0 : 1 }
    ' Makefile; then
    note "Makefile R2 TYPECK_F64 multi-target FORCE thin try-heat (wave914)"
  elif awk '
    /^src\/typeck\/typeck_f64_bits\.o:/ { in_t=1; next }
    in_t && /^[^[:space:]#]/ { in_t=0 }
    in_t { body = body $0 "\n" }
    END {
      if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-heat|try-r2/) exit 0
      exit 1
    }
  ' Makefile; then
    note "Makefile typeck_f64_bits thin-calls ensure try-r2 (wave762)"
  else
    bad "Makefile typeck_f64_bits.o must thin-call ensure try-heat|try-r2 (wave762/914 multi-target)"
  fi
  # Host MAIN_LINK crt0 (Darwin arm64 / Linux x86_64 / …) — per-leaf or wave913 multi-target.
  # wave913: multi-target $(DRIVER_SEED_CRT0_OBJS): FORCE try-heat covers all six catalog leaves
  # (no per-leaf dual). Accept multi-target OR historical per-leaf try-heat|try-r2.
  if grep -qE '\$\(DRIVER_SEED_CRT0_OBJS\):[[:space:]]*FORCE' Makefile 2>/dev/null \
    && awk '
      /\$\(DRIVER_SEED_CRT0_OBJS\):/ { hit=1; next }
      hit && /^[^#[:space:]\t]/ { exit 1 }
      hit && /ensure_host_cc_seed_o\.sh/ && /try-heat|try-r2/ { found=1; exit 0 }
      END { exit found ? 0 : 1 }
    ' Makefile; then
    note "Makefile R2 CRT0 multi-target FORCE thin try-heat (wave913; covers six)"
  elif awk '
    /^src\/asm\/crt0_[a-z0-9_]+\.o:/ { in_t=1; body=""; next }
    in_t && /^[^[:space:]#]/ {
      if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-heat|try-r2/) found=1
      in_t=0
    }
    in_t { body = body $0 "\n" }
    END { if (found) exit 0; exit 1 }
  ' Makefile; then
    note "Makefile crt0 leaves thin-call ensure try-r2 (wave762)"
  else
    bad "Makefile crt0_*.o recipes must thin-call ensure try-heat|try-r2 (wave762/913 multi-target)"
  fi

  if [ "$fail" -ne 0 ]; then
    echo "ensure_host_cc_seed_o: --check FAILED" >&2
    exit 1
  fi
  # wave756: try-r1 entry must exist (R4 pure-R1 body helper)
  if ! grep -q 'try_ensure_r1_one\|try-r1' "$0"; then
    bad "try-r1 / try_ensure_r1_one missing (wave756 R4 pure-R1)"
  else
    note "try-r1 pure-R1 helper present (wave756)"
  fi
  # wave757: try-r3-cold entry must exist (R3 cold-else body helper)
  if ! grep -q 'try_ensure_r3_cold_one\|try-r3-cold' "$0"; then
    bad "try-r3-cold / try_ensure_r3_cold_one missing (wave757 R3 cold-else)"
  else
    note "try-r3-cold R3 cold-else helper present (wave757)"
  fi
  # wave763: try-r3-prefer PREFER thin+rest product path
  if ! grep -q 'try_ensure_r3_prefer_one\|try-r3-prefer' "$0"; then
    bad "try-r3-prefer / try_ensure_r3_prefer_one missing (wave763 R3 PREFER thin)"
  else
    note "try-r3-prefer R3 PREFER thin helper present (wave763)"
  fi
  if ! grep -q 'r3_prefer_leaf_spec\|ensure_r3_prefer_one' "$0"; then
    bad "r3 prefer body missing (wave763)"
  else
    note "r3-prefer leaf map + body present (wave763)"
  fi
  # Makefile R3_COLD nine must thin-call try-heat|try-r3-prefer (no inline thin+rest).
  # wave906: multi-target $(R3_COLD_SEED_OBJS): FORCE + try-heat covers all nine
  # (G.7 有则补全 list; no per-leaf dual). Accept multi-target OR historical per-leaf.
  _r3c_multi=0
  if grep -qE '\$\(R3_COLD_SEED_OBJS\):[[:space:]]*FORCE' Makefile 2>/dev/null \
    && awk '
      /\$\(R3_COLD_SEED_OBJS\):/ { hit=1; next }
      hit && /^[^#[:space:]\t]/ { exit 1 }
      hit && /ensure_host_cc_seed_o\.sh/ && /try-heat|try-r3-prefer/ { found=1; exit 0 }
      END { exit found ? 0 : 1 }
    ' Makefile; then
    _r3c_multi=1
    note "Makefile R3_COLD multi-target FORCE thin try-heat (wave906; covers nine)"
  fi
  for leaf in \
    src/runtime_io_abi.o \
    src/runtime_driver_abi.o \
    src/runtime_driver_diagnostic.o \
    src/asm/simd_enc.o \
    src/asm/simd_loop.o \
    src/asm/backend_enc_dispatch.o \
    src/asm/backend_arch_emit_dispatch.o \
    src/asm/backend_try_inline_dispatch.o \
    src/asm/backend_call_dispatch.o
  do
    if [ "$_r3c_multi" -eq 1 ]; then
      # Multi-target owns thin-call; still ban per-leaf dual recipe if present.
      if grep -qE "^${leaf}:" Makefile 2>/dev/null; then
        bad "Makefile $leaf still has per-leaf target under R3_COLD multi-target (wave906)"
      fi
      continue
    fi
    if awk -v t="$leaf" '
      $0 ~ "^" t ":" {grab=1; next}
      grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
      grab {body = body $0 "\n"}
      END {
        if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-heat|try-r3-prefer/) exit 0
        exit 1
      }
    ' Makefile; then
      note "Makefile $leaf thin-calls ensure try-r3-prefer (wave763)"
    else
      bad "Makefile $leaf must thin-call ensure try-heat|try-r3-prefer (wave763/906)"
    fi
    # No residual inline ld -r thin+rest in the leaf recipe body.
    if awk -v t="$leaf" '
      $0 ~ "^" t ":" {grab=1; next}
      grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
      grab {body = body $0 "\n"}
      END {
        if (body ~ /ld -r/ && body ~ /_rest\.o/) exit 1
        exit 0
      }
    ' Makefile; then
      :
    else
      bad "Makefile $leaf still has inline ld -r thin+rest (wave763)"
    fi
  done
  # wave764: g05 product daily path must thin-call r3-prefer-family (no dual hybrid
  # for R3_COLD nine: rio / rdabi / rdd / simd_* / backend_*).
  if [ -f scripts/g05_ensure_relink_prereqs.sh ]; then
    if grep -q 'r3-prefer-family\|r3_prefer_family' scripts/g05_ensure_relink_prereqs.sh \
      && grep -q 'ensure_host_cc_seed_o.sh' scripts/g05_ensure_relink_prereqs.sh; then
      note "g05_ensure thin-calls ensure r3-prefer-family (wave764)"
    else
      bad "g05_ensure must thin-call ensure r3-prefer-family for R3_COLD (wave764)"
    fi
    # Dual body residual: g05 must not re-open inline hybrid for R3_COLD leaves.
    if grep -qE 'g05_rio_thin|g05_rdabi_thin|g05_rdd_thin|g05_simd_enc_thin|g05_bed_thin|G-02f-334：runtime_io_abi' \
      scripts/g05_ensure_relink_prereqs.sh; then
      bad "g05_ensure still has R3_COLD dual hybrid body (wave764)"
    else
      note "g05_ensure R3_COLD dual hybrid body removed (wave764)"
    fi
    # wave764 full ladder in leaf map (simd/backend full.x field present).
    if grep -q 'XLANG_SIMD_ENC_FROM_X' "$0" \
      && grep -q 'r3_prefer_try_step' "$0"; then
      note "try-r3-prefer full→thin ladder present (wave764)"
    else
      bad "try-r3-prefer must gain full→thin ladder (wave764)"
    fi
  else
    bad "scripts/g05_ensure_relink_prereqs.sh missing (wave764 g05 gate)"
  fi
  # wave765: try-labi-prefer labi multi-slice (g05 + Makefile thin-call; no dual hybrid)
  if ! grep -q 'try_ensure_labi_prefer_one\|try-labi-prefer' "$0"; then
    bad "try-labi-prefer / try_ensure_labi_prefer_one missing (wave765 labi multi-slice)"
  else
    note "try-labi-prefer labi multi-slice helper present (wave765)"
  fi
  if ! grep -q 'ensure_labi_prefer_one\|labi_prefer_try_x_to_o' "$0"; then
    bad "labi prefer body missing (wave765)"
  else
    note "labi-prefer multi-slice body present (wave765)"
  fi
  if makefile_leaf_try_heat_ok "src/runtime_link_abi.o" 'try-heat|try-labi-prefer'; then
    note "Makefile src/runtime_link_abi.o thin-calls ensure try-labi-prefer (wave765/899 multi)"
  else
    bad "Makefile src/runtime_link_abi.o must thin-call ensure try-heat|try-labi-prefer (wave765/899)"
  fi
  if [ -f scripts/g05_ensure_relink_prereqs.sh ]; then
    if grep -q 'try-labi-prefer\|labi-prefer' scripts/g05_ensure_relink_prereqs.sh \
      && grep -q 'ensure_host_cc_seed_o.sh' scripts/g05_ensure_relink_prereqs.sh; then
      note "g05_ensure thin-calls ensure try-labi-prefer (wave765)"
    else
      bad "g05_ensure must thin-call ensure try-heat|try-labi-prefer for labi (wave765)"
    fi
    if grep -qE 'g05_labi_l0\.|_labi_l0_seed=seeds/labi_path_pure|_labi_rest_defs=.*LABI_PATH_PURE' \
      scripts/g05_ensure_relink_prereqs.sh; then
      bad "g05_ensure still has labi multi-slice dual hybrid body (wave765)"
    else
      note "g05_ensure labi multi-slice dual hybrid body removed (wave765)"
    fi
  else
    bad "scripts/g05_ensure_relink_prereqs.sh missing (wave765 g05 gate)"
  fi
  # wave766: try-rt-prefer rt multi-slice (g05 + Makefile thin-call; no dual hybrid)
  if ! grep -q 'try_ensure_rt_prefer_one\|try-rt-prefer' "$0"; then
    bad "try-rt-prefer / try_ensure_rt_prefer_one missing (wave766 rt multi-slice)"
  else
    note "try-rt-prefer rt multi-slice helper present (wave766)"
  fi
  if ! grep -q 'ensure_rt_prefer_one\|rt_prefer_try_x_to_o' "$0"; then
    bad "rt prefer body missing (wave766)"
  else
    note "rt-prefer multi-slice body present (wave766)"
  fi
  if makefile_leaf_try_heat_ok "src/runtime_driver_no_c.o" 'try-heat|try-rt-prefer'; then
    note "Makefile src/runtime_driver_no_c.o thin-calls ensure try-rt-prefer (wave766/901 multi)"
  else
    bad "Makefile src/runtime_driver_no_c.o must thin-call ensure try-heat|try-rt-prefer (wave766/901)"
  fi
  if [ -f scripts/g05_ensure_relink_prereqs.sh ]; then
    if grep -q 'try-rt-prefer\|rt-prefer' scripts/g05_ensure_relink_prereqs.sh \
      && grep -q 'ensure_host_cc_seed_o.sh' scripts/g05_ensure_relink_prereqs.sh; then
      note "g05_ensure thin-calls ensure try-rt-prefer (wave766)"
    else
      bad "g05_ensure must thin-call ensure try-heat|try-rt-prefer for rt multi-slice (wave766)"
    fi
    # Dual body residual: g05 must not re-open inline rt multi-slice hybrid.
    if grep -qE '_rt_content_seed=seeds/rt_content|_rt_rest_defs=.*RT_CONTENT_FROM_X|g05_rt_content\.XXXXXX' \
      scripts/g05_ensure_relink_prereqs.sh; then
      bad "g05_ensure still has rt multi-slice dual hybrid body (wave766)"
    else
      note "g05_ensure rt multi-slice dual hybrid body removed (wave766)"
    fi
  else
    bad "scripts/g05_ensure_relink_prereqs.sh missing (wave766 g05 gate)"
  fi
  # wave767: try-pipeline-abi-prefer + try-ldpc-prefer (g05 + Makefile thin-call)
  if ! grep -q 'try_ensure_pipeline_abi_prefer_one\|try-pipeline-abi-prefer' "$0"; then
    bad "try-pipeline-abi-prefer / try_ensure_pipeline_abi_prefer_one missing (wave767)"
  else
    note "try-pipeline-abi-prefer helper present (wave767)"
  fi
  if ! grep -q 'ensure_pipeline_abi_prefer_one' "$0"; then
    bad "pipeline_abi prefer body missing (wave767)"
  else
    note "pipeline-abi-prefer body present (wave767)"
  fi
  if ! grep -q 'try_ensure_ldpc_prefer_one\|try-ldpc-prefer' "$0"; then
    bad "try-ldpc-prefer / try_ensure_ldpc_prefer_one missing (wave767)"
  else
    note "try-ldpc-prefer helper present (wave767)"
  fi
  if ! grep -q 'ensure_ldpc_prefer_one' "$0"; then
    bad "ldpc prefer body missing (wave767)"
  else
    note "ldpc-prefer body present (wave767)"
  fi
  if makefile_leaf_try_heat_ok "src/runtime_pipeline_abi.o" 'try-heat|try-pipeline-abi-prefer'; then
    note "Makefile src/runtime_pipeline_abi.o thin-calls ensure try-pipeline-abi-prefer (wave767/903 multi)"
  else
    bad "Makefile src/runtime_pipeline_abi.o must thin-call ensure try-heat|try-pipeline-abi-prefer (wave767/903)"
  fi
  if makefile_leaf_try_heat_ok "src/lsp/lsp_diag_pipeline_ctx.o" 'try-heat|try-ldpc-prefer'; then
    note "Makefile src/lsp/lsp_diag_pipeline_ctx.o thin-calls ensure try-ldpc-prefer (wave767/904 multi)"
  else
    bad "Makefile src/lsp/lsp_diag_pipeline_ctx.o must thin-call ensure try-heat|try-ldpc-prefer (wave767/904)"
  fi
  if [ -f scripts/g05_ensure_relink_prereqs.sh ]; then
    if grep -q 'try-pipeline-abi-prefer\|pipeline-abi-prefer' scripts/g05_ensure_relink_prereqs.sh \
      && grep -q 'try-ldpc-prefer\|ldpc-prefer' scripts/g05_ensure_relink_prereqs.sh \
      && grep -q 'ensure_host_cc_seed_o.sh' scripts/g05_ensure_relink_prereqs.sh; then
      note "g05_ensure thin-calls ensure try-pipeline-abi-prefer + try-ldpc-prefer (wave767)"
    else
      bad "g05_ensure must thin-call ensure try-heat|try-pipeline-abi-prefer and try-ldpc-prefer (wave767)"
    fi
    # Dual body residual: g05 must not re-open inline pipeline_abi / ldpc hybrid.
    if grep -qE '_rpabi=seeds/runtime_pipeline_abi\.from_x\.c|_ldpc=seeds/lsp_diag_pipeline_ctx\.from_x\.c' \
      scripts/g05_ensure_relink_prereqs.sh; then
      bad "g05_ensure still has pipeline_abi/ldpc dual hybrid body (wave767)"
    else
      note "g05_ensure pipeline_abi/ldpc dual hybrid body removed (wave767)"
    fi
  else
    bad "scripts/g05_ensure_relink_prereqs.sh missing (wave767 g05 gate)"
  fi
  # wave768: try-target-cpu-prefer (g05 + Makefile thin-call)
  if ! grep -q 'try_ensure_target_cpu_prefer_one\|try-target-cpu-prefer' "$0"; then
    bad "try-target-cpu-prefer / try_ensure_target_cpu_prefer_one missing (wave768)"
  else
    note "try-target-cpu-prefer helper present (wave768)"
  fi
  if ! grep -q 'ensure_target_cpu_prefer_one' "$0"; then
    bad "target_cpu prefer body missing (wave768)"
  else
    note "target-cpu-prefer body present (wave768)"
  fi
  if makefile_leaf_try_heat_ok "src/driver/target_cpu.o" 'try-heat|try-target-cpu-prefer'; then
    note "Makefile src/driver/target_cpu.o thin-calls ensure try-target-cpu-prefer (wave768/905 multi)"
  else
    bad "Makefile src/driver/target_cpu.o must thin-call ensure try-heat|try-target-cpu-prefer (wave768/905)"
  fi
  if [ -f scripts/g05_ensure_relink_prereqs.sh ]; then
    if grep -q 'try-target-cpu-prefer\|target-cpu-prefer' scripts/g05_ensure_relink_prereqs.sh \
      && grep -q 'ensure_host_cc_seed_o.sh' scripts/g05_ensure_relink_prereqs.sh; then
      note "g05_ensure thin-calls ensure try-target-cpu-prefer (wave768)"
    else
      bad "g05_ensure must thin-call ensure try-heat|try-target-cpu-prefer (wave768)"
    fi
    # Dual body residual: g05 must not re-open inline target_cpu flags hybrid.
    if grep -qE '_tcflags_x=src/driver/target_cpu_flags\.x|_tcpure=seeds/target_cpu_pure\.from_x\.c' \
      scripts/g05_ensure_relink_prereqs.sh; then
      bad "g05_ensure still has target_cpu dual hybrid body (wave768)"
    else
      note "g05_ensure target_cpu dual hybrid body removed (wave768)"
    fi
  else
    bad "scripts/g05_ensure_relink_prereqs.sh missing (wave768 g05 gate)"
  fi
  # wave769: try-l2-asm-prefer (g05 + Makefile thin-call; three L2 asm leaves)
  if ! grep -q 'try_ensure_l2_asm_prefer_one\|try-l2-asm-prefer' "$0"; then
    bad "try-l2-asm-prefer / try_ensure_l2_asm_prefer_one missing (wave769)"
  else
    note "try-l2-asm-prefer helper present (wave769)"
  fi
  if ! grep -q 'ensure_l2_asm_prefer_one\|l2_asm_prefer_spec_for_out' "$0"; then
    bad "l2-asm prefer body/table missing (wave769)"
  else
    note "l2-asm-prefer table body present (wave769)"
  fi
  for _l2_leaf in \
    src/asm/user_asm_seed_bridge.o \
    src/asm/backend_x86_64_enc_c.o \
    src/asm/asm_backend_compat_stubs.o; do
    if makefile_leaf_try_heat_ok "$_l2_leaf" 'try-heat|try-l2-asm-prefer'; then
      note "Makefile $_l2_leaf thin-calls ensure try-l2-asm-prefer (wave769/multi)"
    else
      bad "Makefile $_l2_leaf must thin-call ensure try-heat|try-l2-asm-prefer (wave769/multi)"
    fi
  done
  if [ -f scripts/g05_ensure_relink_prereqs.sh ]; then
    if grep -q 'try-l2-asm-prefer\|l2-asm-prefer' scripts/g05_ensure_relink_prereqs.sh \
      && grep -q 'ensure_host_cc_seed_o.sh' scripts/g05_ensure_relink_prereqs.sh; then
      note "g05_ensure thin-calls ensure try-l2-asm-prefer (wave769)"
    else
      bad "g05_ensure must thin-call ensure try-heat|try-l2-asm-prefer for L2 asm three (wave769)"
    fi
    # Dual body residual: g05 must not re-open inline uasb/bxec/abcs hybrid.
    if grep -qE '_uasb_seed=|_bxec_seed=|_abcs_seed=|user_asm_seed_bridge ← thin|_bxec_thin_o=|_abcs_thin_o=' \
      scripts/g05_ensure_relink_prereqs.sh; then
      bad "g05_ensure still has L2 asm dual hybrid body (wave769)"
    else
      note "g05_ensure L2 asm dual hybrid body removed (wave769)"
    fi
  else
    bad "scripts/g05_ensure_relink_prereqs.sh missing (wave769 g05 gate)"
  fi
  # wave770: try-async-prefer (g05 + Makefile thin-call; three async leaves)
  if ! grep -q 'try_ensure_async_prefer_one\|try-async-prefer' "$0"; then
    bad "try-async-prefer / try_ensure_async_prefer_one missing (wave770)"
  else
    note "try-async-prefer helper present (wave770)"
  fi
  if ! grep -q 'ensure_async_prefer_one\|async_prefer_spec_for_out' "$0"; then
    bad "async prefer body/table missing (wave770)"
  else
    note "async-prefer table body present (wave770)"
  fi
  for _async_leaf in \
    src/async/async_liveness.o \
    src/async/async_cps_codegen.o \
    src/async/async_asm_pool.o; do
    if makefile_leaf_try_heat_ok "$_async_leaf" 'try-heat|try-async-prefer'; then
      note "Makefile $_async_leaf thin-calls ensure try-async-prefer (wave770/907 multi)"
    else
      bad "Makefile $_async_leaf must thin-call ensure try-heat|try-async-prefer (wave770/907)"
    fi
  done
  if [ -f scripts/g05_ensure_relink_prereqs.sh ]; then
    if grep -q 'try-async-prefer\|async-prefer' scripts/g05_ensure_relink_prereqs.sh \
      && grep -q 'ensure_host_cc_seed_o.sh' scripts/g05_ensure_relink_prereqs.sh; then
      note "g05_ensure thin-calls ensure try-async-prefer (wave770)"
    else
      bad "g05_ensure must thin-call ensure try-heat|try-async-prefer for async three (wave770)"
    fi
    # Dual body residual: g05 must not re-open inline async hybrid.
    if grep -qE '_aliv_seed=|_acps_seed=|_aap_seed=|async_liveness PREFER|_aliv_x_o=|_acps_x_o=|_aap_x_o=' \
      scripts/g05_ensure_relink_prereqs.sh; then
      bad "g05_ensure still has async dual hybrid body (wave770)"
    else
      note "g05_ensure async dual hybrid body removed (wave770)"
    fi
  else
    bad "scripts/g05_ensure_relink_prereqs.sh missing (wave770 g05 gate)"
  fi
  # wave771 + wave775: try-other-l2-prefer (g05 four + Makefile five incl. fmt_core)
  if ! grep -q 'try_ensure_other_l2_prefer_one\|try-other-l2-prefer' "$0"; then
    bad "try-other-l2-prefer / try_ensure_other_l2_prefer_one missing (wave771)"
  else
    note "try-other-l2-prefer helper present (wave771/775)"
  fi
  if ! grep -q 'ensure_other_l2_prefer_one\|other_l2_prefer_spec_for_out' "$0"; then
    bad "other-l2 prefer body/table missing (wave771)"
  else
    note "other-l2-prefer table body present (wave771/775)"
  fi
  if ! grep -q 'fmt_core' "$0"; then
    bad "fmt_core leaf_kind missing (wave775 fmt_check_cmd.o)"
  else
    note "fmt_core leaf_kind present (wave775)"
  fi
  if ! grep -q 'G05_X_O_WEAK_FUNCS' "$0"; then
    bad "G05_X_O_WEAK_FUNCS named-weak missing in rt_prefer (wave771 slc)"
  else
    note "G05_X_O_WEAK_FUNCS named-weak present (wave771)"
  fi
  for _ol2_leaf in \
    src/seed_link_compat.o \
    src/runtime_driver_strict_glue_stubs.o \
    src/driver/fmt_check_cmd_driver.o \
    src/driver/fmt_check_cmd.o \
    src/lsp/lsp_diag.o; do
    if makefile_leaf_try_heat_ok "$_ol2_leaf" 'try-heat|try-other-l2-prefer'; then
      note "Makefile $_ol2_leaf thin-calls ensure try-other-l2-prefer (wave771/775/multi)"
    else
      bad "Makefile $_ol2_leaf must thin-call ensure try-heat|try-other-l2-prefer (wave771/775/multi)"
    fi
  done
  # wave775: ban re-opened Makefile dual hybrid body for non-driver fmt.o
  if awk '
    $0 ~ /^src\/driver\/fmt_check_cmd\.o:/ {grab=1; next}
    grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
    grab {body = body $0 "\n"}
    END {
      if (body ~ /mktemp/ && body ~ /fmt_check_cmd_thin\.o/) exit 0
      exit 1
    }
  ' Makefile; then
    bad "Makefile fmt_check_cmd.o still has dual hybrid body (wave775)"
  else
    note "Makefile fmt_check_cmd.o dual hybrid body removed (wave775)"
  fi
  if [ -f scripts/g05_ensure_relink_prereqs.sh ]; then
    if grep -q 'try-other-l2-prefer\|other-l2-prefer' scripts/g05_ensure_relink_prereqs.sh \
      && grep -q 'ensure_host_cc_seed_o.sh' scripts/g05_ensure_relink_prereqs.sh; then
      note "g05_ensure thin-calls ensure try-other-l2-prefer (wave771)"
    else
      bad "g05_ensure must thin-call ensure try-heat|try-other-l2-prefer for other L2 four (wave771)"
    fi
    # Dual body residual: g05 must not re-open inline slc/strict/fmt/lsp hybrid.
    if grep -qE '_slc_o=|_slc_seed=|_rdss=|_rdss_thin_x=|_fcc=|_fcc_thin_x=|_lspg=|_lspg_thin_x=' \
      scripts/g05_ensure_relink_prereqs.sh; then
      bad "g05_ensure still has other L2 dual hybrid body (wave771)"
    else
      note "g05_ensure other L2 dual hybrid body removed (wave771)"
    fi
  else
    bad "scripts/g05_ensure_relink_prereqs.sh missing (wave771 g05 gate)"
  fi
  # wave779: try-runtime-os-prefer B1 23 runtime_* OS/glue dual hybrid
  if ! grep -q 'try_ensure_runtime_os_prefer_one\|try-runtime-os-prefer' "$0"; then
    bad "try-runtime-os-prefer / try_ensure_runtime_os_prefer_one missing (wave779)"
  else
    note "try-runtime-os-prefer helper present (wave779)"
  fi
  if ! grep -q 'runtime_os_prefer_spec_for_out\|ensure_runtime_os_prefer_one' "$0"; then
    bad "runtime-os prefer body/table missing (wave779)"
  else
    note "runtime-os-prefer table body present (wave779)"
  fi
  # Count table members (must stay 23 — heat inventory wave777 B1).
  _rtos_n=0
  for _rtos_leaf in \
    runtime_test_fn_invoke.o \
    runtime_random_fill.o \
    runtime_compress_zlib_glue.o \
    runtime_time_os.o \
    runtime_queue_contention.o \
    runtime_dynlib_os.o \
    runtime_env_os.o \
    runtime_backtrace_platform.o \
    runtime_log_os.o \
    runtime_math_libm.o \
    runtime_atomic_glue.o \
    runtime_net_udp_batch.o \
    runtime_net_workers.o \
    runtime_sync_os.o \
    runtime_sync_lock_diag_tls.o \
    runtime_thread_glue.o \
    runtime_http_glue.o \
    runtime_tls_mbedtls_bio.o \
    runtime_arrow_simd_glue.o \
    runtime_crypto_inc_glue.o \
    runtime_ed25519_ref10_glue.o \
    runtime_process_argv.o \
    runtime_process_os_glue.o; do
    if [ -n "$(runtime_os_prefer_spec_for_out "$_rtos_leaf")" ]; then
      _rtos_n=$((_rtos_n + 1))
    else
      bad "runtime_os_prefer_spec_for_out missing $_rtos_leaf (wave779)"
    fi
    # wave908: multi-target $(B1_RUNTIME_OS_SEED_OBJS): FORCE try-heat OR per-leaf
    if makefile_leaf_try_heat_ok "$_rtos_leaf" 'try-heat|try-runtime-os-prefer'; then
      note "Makefile $_rtos_leaf thin-calls ensure try-heat|try-runtime-os-prefer (wave779/908)"
    else
      bad "Makefile $_rtos_leaf must thin-call ensure try-heat|try-runtime-os-prefer (wave779/908)"
    fi
    # Ban re-opened dual hybrid body (mktemp + thin.o / rest.o inline).
    if awk -v leaf="$_rtos_leaf" '
      $0 ~ ("^" leaf ":") {grab=1; next}
      grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
      grab {body = body $0 "\n"}
      END {
        if (body ~ /mktemp/ && body ~ /(thin\.o|_thin\.o|rest\.o|_rest\.o)/) exit 0
        if (body ~ /XLANG_KEEP_C=1/ && body ~ /xlang-c/) exit 0
        exit 1
      }
    ' Makefile; then
      bad "Makefile $_rtos_leaf still has dual hybrid body (wave779)"
    fi
  done
  if [ "$_rtos_n" -ne 23 ]; then
    bad "runtime-os prefer table size $_rtos_n != 23 (wave779 B1 heat)"
  else
    note "runtime-os prefer table has 23 members (wave779 B1)"
  fi
  # wave780: try-std-core-prefer B2 5 std/core product hybrid
  if ! grep -q 'try_ensure_std_core_prefer_one\|try-std-core-prefer' "$0"; then
    bad "try-std-core-prefer / try_ensure_std_core_prefer_one missing (wave780)"
  else
    note "try-std-core-prefer helper present (wave780)"
  fi
  if ! grep -q 'std_core_prefer_spec_for_out\|ensure_std_core_prefer_one' "$0"; then
    bad "std-core prefer body/table missing (wave780)"
  else
    note "std-core-prefer table body present (wave780)"
  fi
  # wave897: multi-target $(STD_CORE_HYBRID_PRODUCT_OBJS) + mk list (no per-leaf target line).
  # Accept A) legacy per-leaf `^OUT:` FORCE+try-heat, or B) OUT in mk list + multi-target rule.
  _SC_MK="mk/std_core_hybrid_product_objs.mk"
  [ -f "$_SC_MK" ] || _SC_MK="compiler/mk/std_core_hybrid_product_objs.mk"
  _sc_n=0
  _sc_multi=0
  if [ -f "$_SC_MK" ] && grep -qE '\$\(STD_CORE_HYBRID_PRODUCT_OBJS\):[[:space:]]*FORCE' Makefile; then
    if awk '
      /\$\(STD_CORE_HYBRID_PRODUCT_OBJS\):/ { hit=1; next }
      hit && /^[^#[:space:]\t]/ { exit 1 }
      hit && /ensure_host_cc_seed_o\.sh/ && /try-heat|try-std-core-prefer/ { found=1; exit 0 }
      END { exit found ? 0 : 1 }
    ' Makefile; then
      _sc_multi=1
      note "Makefile multi-target STD_CORE_HYBRID_PRODUCT_OBJS FORCE+try-heat (wave897)"
    fi
  fi
  for _sc_leaf in \
    ../std/process/process.o \
    ../std/path/path.o \
    ../std/runtime/runtime.o \
    ../std/net/net.o \
    ../core/slice/slice.o; do
    if [ -n "$(std_core_prefer_spec_for_out "$_sc_leaf")" ]; then
      _sc_n=$((_sc_n + 1))
    else
      bad "std_core_prefer_spec_for_out missing $_sc_leaf (wave780)"
    fi
    _ok_t=0
    if awk -v leaf="$_sc_leaf" '
      $0 ~ ("^" leaf ":") {grab=1; next}
      grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
      grab {body = body $0 "\n"}
      END {
        if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-heat|try-std-core-prefer/) exit 0
        exit 1
      }
    ' Makefile; then
      _ok_t=1
    elif [ "$_sc_multi" -eq 1 ] && grep -qF "$_sc_leaf" "$_SC_MK" 2>/dev/null; then
      _ok_t=1
    fi
    if [ "$_ok_t" -eq 1 ]; then
      note "Makefile $_sc_leaf thin-calls ensure try-heat|try-std-core-prefer (wave780/897)"
    else
      bad "Makefile $_sc_leaf must thin-call ensure try-heat|try-std-core-prefer (wave780/897)"
    fi
    # Ban re-opened hybrid: only scan recipe lines (leading tab), not following
    # comment blocks (those often mention historic xlang-c / PREFER).
    # wave897 multi-target path: no per-leaf body — skip dual-hybrid scan when covered by mk.
    if [ "$_sc_multi" -eq 1 ] && grep -qF "$_sc_leaf" "$_SC_MK" 2>/dev/null \
      && ! grep -qE "^${_sc_leaf}:" Makefile 2>/dev/null; then
      :
    elif awk -v leaf="$_sc_leaf" '
      $0 ~ ("^" leaf ":") {grab=1; next}
      grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
      grab && /^\t/ {body = body $0 "\n"}
      END {
        if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-heat|try-std-core-prefer/ && body !~ /xlang_compile_std_x\.sh/ && body !~ /\$\(CC\)/) exit 1
        if (body ~ /XLANG_KEEP_C=1/ && body ~ /xlang-c/ && body !~ /ensure_host_cc_seed_o/) exit 0
        if (body ~ /\$\(CC\)/ && body ~ /-c seeds\//) exit 0
        if (body ~ /xlang_compile_std_x\.sh/ && body ~ /net_dns_fast/) exit 0
        exit 1
      }
    ' Makefile; then
      bad "Makefile $_sc_leaf still has dual hybrid body (wave780)"
    fi
  done
  if [ "$_sc_n" -ne 5 ]; then
    bad "std-core prefer table size $_sc_n != 5 (wave780 B2 heat)"
  else
    note "std-core prefer table has 5 members (wave780 B2; wave897 multi-target)"
  fi
  # wave781: try-lsp-sat-prefer B3 2 LSP satellite hybrid
  if ! grep -q 'try_ensure_lsp_sat_prefer_one\|try-lsp-sat-prefer' "$0"; then
    bad "try-lsp-sat-prefer / try_ensure_lsp_sat_prefer_one missing (wave781)"
  else
    note "try-lsp-sat-prefer helper present (wave781)"
  fi
  if ! grep -q 'lsp_sat_prefer_spec_for_out\|ensure_lsp_sat_prefer_one' "$0"; then
    bad "lsp-sat prefer body/table missing (wave781)"
  else
    note "lsp-sat-prefer table body present (wave781)"
  fi
  _ls_n=0
  # wave911: multi-target $(B3_LSP_SAT_SEED_OBJS): FORCE try-heat covers both
  # (no per-leaf dual). Accept multi-target OR historical per-leaf.
  if grep -qE '\$\(B3_LSP_SAT_SEED_OBJS\):[[:space:]]*FORCE' Makefile \
    && awk '
      /\$\(B3_LSP_SAT_SEED_OBJS\):/ { hit=1; next }
      hit && /^[^#[:space:]\t]/ { exit 1 }
      hit && /ensure_host_cc_seed_o\.sh/ && /try-heat/ { found=1; exit 0 }
      END { exit found ? 0 : 1 }
    ' Makefile; then
    note "Makefile B3_LSP_SAT multi-target FORCE thin try-heat (wave911; covers two)"
  fi
  for _ls_leaf in \
    src/lsp/lsp_diag_pipeline_sizes_nostub.o \
    src/lsp/lsp_diag_stubs_no_c.o; do
    if [ -n "$(lsp_sat_prefer_spec_for_out "$_ls_leaf")" ]; then
      _ls_n=$((_ls_n + 1))
    else
      bad "lsp_sat_prefer_spec_for_out missing $_ls_leaf (wave781)"
    fi
    if makefile_leaf_try_heat_ok "$_ls_leaf" 'try-heat|try-lsp-sat-prefer'; then
      note "Makefile $_ls_leaf thin-calls try-heat|try-lsp-sat-prefer (wave781/911)"
    else
      bad "Makefile $_ls_leaf must thin-call ensure try-heat|try-lsp-sat-prefer (wave781/911)"
    fi
    # Ban re-opened hybrid: only scan tab-prefixed recipe lines (not # comments).
    # Multi-target: no per-leaf body — skip dual-body scan when leaf only via list.
    if grep -qE "^${_ls_leaf}:" Makefile 2>/dev/null; then
      if awk -v leaf="$_ls_leaf" '
        $0 ~ ("^" leaf ":") {grab=1; next}
        grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
        grab && /^\t/ {body = body $0 "\n"}
        END {
          if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-heat|try-lsp-sat-prefer/ && body !~ /\$\(CC\)/ && body !~ /xlang-c/) exit 1
          if (body ~ /xlang-c/ && body !~ /ensure_host_cc_seed_o/) exit 0
          if (body ~ /\$\(CC\)/ && body ~ /-c seeds\//) exit 0
          if (body ~ /mktemp/ && body ~ /(thin\.o|_thin\.o|rest\.o|_rest\.o)/) exit 0
          exit 1
        }
      ' Makefile; then
        bad "Makefile $_ls_leaf still has dual hybrid body (wave781)"
      fi
    fi
  done
  if [ "$_ls_n" -ne 2 ]; then
    bad "lsp-sat prefer table size $_ls_n != 2 (wave781 B3 heat)"
  else
    note "lsp-sat prefer table has 2 members (wave781 B3; wave911 multi-target)"
  fi
  # wave782: try-gen-c-to-o B4 5 gen.c → .o bootstrap
  if ! grep -q 'try_ensure_gen_c_to_o_one\|try-gen-c-to-o' "$0"; then
    bad "try-gen-c-to-o / try_ensure_gen_c_to_o_one missing (wave782)"
  else
    note "try-gen-c-to-o helper present (wave782)"
  fi
  if ! grep -q 'gen_c_to_o_spec_for_out' "$0"; then
    bad "gen_c_to_o table missing (wave782)"
  else
    note "gen-c-to-o table present (wave782)"
  fi
  if ! grep -q 'build_lexer_x\|lexer_x.o' scripts/ensure_gen_x_o.sh; then
    bad "ensure_gen_x_o.sh missing B4 lexer_x map (wave782)"
  else
    note "ensure_gen_x_o B4 maps present (wave782)"
  fi
  _b4_n=0
  # wave910/295: multi-target $(GEN_C_TO_O_SEED_OBJS): FORCE try-heat covers all four
  # (no per-leaf dual; stubs2 left). Accept multi-target OR historical per-leaf.
  if grep -qE '\$\(GEN_C_TO_O_SEED_OBJS\):[[:space:]]*FORCE' Makefile \
    && awk '
      /\$\(GEN_C_TO_O_SEED_OBJS\):/ { hit=1; next }
      hit && /^[^#[:space:]\t]/ { exit 1 }
      hit && /ensure_host_cc_seed_o\.sh/ && /try-heat/ { found=1; exit 0 }
      END { exit found ? 0 : 1 }
    ' Makefile; then
    note "Makefile GEN_C_TO_O multi-target FORCE thin try-heat (wave910/295; covers four)"
  fi
  for _b4_leaf in lexer_x.o ast_gen2.o driver_x.o preprocess_x.o; do
    if [ -n "$(gen_c_to_o_spec_for_out "$_b4_leaf")" ]; then
      _b4_n=$((_b4_n + 1))
    else
      bad "gen_c_to_o_spec_for_out missing $_b4_leaf (wave782/295)"
    fi
    if makefile_leaf_try_heat_ok "$_b4_leaf" 'try-heat|try-gen-c-to-o'; then
      note "Makefile $_b4_leaf thin-calls try-heat|try-gen-c-to-o (wave782/796/910/295)"
    else
      bad "Makefile $_b4_leaf must thin-call ensure try-heat|try-gen-c-to-o (wave782/910/295)"
    fi
    # Ban re-opened inline $(CC) -c body on recipe lines (comments OK).
    # wave910: multi-target has no per-leaf recipe — only check if per-leaf line exists.
    if grep -qE "^${_b4_leaf}:" Makefile 2>/dev/null; then
      if awk -v leaf="$_b4_leaf" '
        $0 ~ ("^" leaf ":") {grab=1; next}
        grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
        grab && /^\t/ {body = body $0 "\n"}
        END {
          if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-heat|try-gen-c-to-o/ && body !~ /\$\(CC\)/) exit 1
          if (body ~ /\$\(CC\)/ && body ~ /-c /) exit 0
          if (body ~ /sync_lexer_gen_token_enum/ && body !~ /ensure_host_cc_seed_o/) exit 0
          exit 1
        }
      ' Makefile; then
        bad "Makefile $_b4_leaf still has inline host-cc body (wave782)"
      fi
    fi
  done
  if [ "$_b4_n" -ne 4 ]; then
    bad "gen-c-to-o table size $_b4_n != 4 (wave782/295 B4 heat)"
  else
    note "gen-c-to-o table has 4 members (wave295 B4; stubs2 left)"
  fi
  # wave783: try-cfg-eval-ladder B5 multi-ladder (1 leaf)
  if ! grep -q 'try_ensure_cfg_eval_ladder_one\|try-cfg-eval-ladder' "$0"; then
    bad "try-cfg-eval-ladder / try_ensure_cfg_eval_ladder_one missing (wave783)"
  else
    note "try-cfg-eval-ladder helper present (wave783)"
  fi
  if ! grep -q 'cfg_eval_ladder_spec_for_out\|ensure_cfg_eval_ladder_one' "$0"; then
    bad "cfg_eval ladder table/body missing (wave783)"
  else
    note "cfg-eval ladder table present (wave783)"
  fi
  if [ -n "$(cfg_eval_ladder_spec_for_out "src/lexer/cfg_eval.o")" ]; then
    note "cfg_eval_ladder_spec_for_out has src/lexer/cfg_eval.o (wave783 B5)"
  else
    bad "cfg_eval_ladder_spec_for_out missing src/lexer/cfg_eval.o (wave783)"
  fi
  if [ -z "$(cfg_eval_ladder_spec_for_out "not_a_cfg_eval.o")" ]; then
    note "cfg_eval_ladder non-member empty (wave783)"
  else
    bad "cfg_eval_ladder_spec_for_out must reject non-members (wave783)"
  fi
  # wave950: cfg-eval soft missing xlang-c → ensure_xlang_c.sh (0-make).
  # PLATFORM: SHARED — post_ship honesty after Makefile physical delete.
  # Match only active recipe lines (leading spaces + $MAKE), not comments/strings.
  if grep -E '^[[:space:]]+\$MAKE[[:space:]]+xlang-c' "$0" 2>/dev/null | grep -q .; then
    bad "cfg-eval ladder must not residual bare make xlang-c (wave950; ensure_xlang_c.sh)"
  fi
  if ! grep -q 'ensure_xlang_c\.sh ensure' "$0" 2>/dev/null; then
    bad "cfg-eval ladder must soft-call ensure_xlang_c.sh for missing xlang-c (wave950)"
  else
    note "cfg-eval soft xlang-c → ensure_xlang_c.sh (wave950; 0-make)"
  fi
  # wave783 + wave916: cfg_eval must thin-call try-heat|try-cfg-eval-ladder.
  # wave916: multi-target $(DRIVER_SEED_CFG_EVAL_OBJS): FORCE try-heat (list in r_lists).
  if grep -qE '\$\(DRIVER_SEED_CFG_EVAL_OBJS\):[[:space:]]*FORCE' Makefile 2>/dev/null \
    && awk '
      /\$\(DRIVER_SEED_CFG_EVAL_OBJS\):/ { hit=1; next }
      hit && /^[^#[:space:]\t]/ { exit 1 }
      hit && /ensure_host_cc_seed_o\.sh/ && /try-heat|try-cfg-eval-ladder/ { found=1; exit 0 }
      END { exit found ? 0 : 1 }
    ' Makefile; then
    note "Makefile B5 CFG_EVAL multi-target FORCE thin try-heat (wave916)"
  elif awk '
    $0 ~ /^src\/lexer\/cfg_eval\.o:/ {grab=1; next}
    grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
    grab {body = body $0 "\n"}
    END {
      if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-heat|try-cfg-eval-ladder/) exit 0
      exit 1
    }
  ' Makefile; then
    note "Makefile src/lexer/cfg_eval.o thin-calls ensure try-cfg-eval-ladder (wave783)"
  else
    bad "Makefile cfg_eval must thin-call ensure try-heat|try-cfg-eval-ladder (wave783/916 multi-target)"
  fi
  # Ban re-opened multi-ladder: no inline $(CC)/xlang-c/-E-extern on recipe lines.
  # wave916: multi-target recipe body must also stay thin (no inline multi-ladder).
  if grep -qE '\$\(DRIVER_SEED_CFG_EVAL_OBJS\):[[:space:]]*FORCE' Makefile 2>/dev/null \
    && awk '
      /\$\(DRIVER_SEED_CFG_EVAL_OBJS\):/ { hit=1; next }
      hit && /^[^#[:space:]\t]/ { exit 0 }
      hit && /^\t/ {body = body $0 "\n"}
      END {
        if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-heat|try-cfg-eval-ladder/ \
            && body !~ /\$\(CC\)/ && body !~ /xlang-c/ && body !~ /-E-extern/) exit 1
        if (body ~ /\$\(CC\)/ && body ~ /-c /) exit 0
        if (body ~ /-E-extern/ && body !~ /ensure_host_cc_seed_o/) exit 0
        if (body ~ /cfg_eval_bootstrap_stub/ && body !~ /ensure_host_cc_seed_o/) exit 0
        exit 1
      }
    ' Makefile; then
    bad "Makefile B5 CFG_EVAL multi-target still has multi-ladder body (wave783/916)"
  elif awk '
    $0 ~ /^src\/lexer\/cfg_eval\.o:/ {grab=1; next}
    grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
    grab && /^\t/ {body = body $0 "\n"}
    END {
      if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-heat|try-cfg-eval-ladder/ \
          && body !~ /\$\(CC\)/ && body !~ /xlang-c/ && body !~ /-E-extern/) exit 1
      if (body ~ /\$\(CC\)/ && body ~ /-c /) exit 0
      if (body ~ /-E-extern/ && body !~ /ensure_host_cc_seed_o/) exit 0
      if (body ~ /cfg_eval_bootstrap_stub/ && body !~ /ensure_host_cc_seed_o/) exit 0
      exit 1
    }
  ' Makefile; then
    bad "Makefile src/lexer/cfg_eval.o still has multi-ladder body (wave783)"
  fi
  # wave760/762: try-r2 R2 UNAME leaves (panic + typeck_f64 + crt0)
  if ! grep -q 'try_ensure_r2_one\|try-r2' "$0"; then
    bad "try-r2 / try_ensure_r2_one missing (wave760/762 R2 UNAME)"
  else
    note "try-r2 R2 UNAME helper present (wave760 panic + wave762 typeck_f64/crt0)"
  fi
  if ! grep -q 'ensure_r2_typeck_f64_one\|r2_typeck_f64_host_pick' "$0"; then
    bad "r2 typeck_f64 body missing (wave762)"
  else
    note "r2-typeck-f64 body present (wave762)"
  fi
  if ! grep -q 'ensure_r2_crt0_one\|r2_crt0_src_for_out' "$0"; then
    bad "r2 crt0 body missing (wave762)"
  else
    note "r2-crt0 body present (wave762)"
  fi
  # wave761: try-gen-x gen residual helper
  if ! grep -q 'try_ensure_gen_x_one\|try-gen-x' "$0"; then
    bad "try-gen-x / try_ensure_gen_x_one missing (wave761 gen residual)"
  else
    note "try-gen-x gen residual helper present (wave761)"
  fi
  if [ ! -f scripts/ensure_gen_x_o.sh ]; then
    bad "scripts/ensure_gen_x_o.sh missing (wave761)"
  else
    note "ensure_gen_x_o.sh present (wave761)"
  fi
  # Makefile gen residual: wave761 ensure_gen_x_o · wave796 FORCE + try-heat
  # (try-heat → try-gen-x → ensure_gen_x_o body; G.7 single body).
  # wave909: multi-target $(GEN_X_SEED_OBJS): FORCE try-heat covers all four
  # (no per-leaf dual). Accept multi-target OR historical per-leaf.
  if grep -qE '\$\(GEN_X_SEED_OBJS\):[[:space:]]*FORCE' Makefile \
    && awk '
      /\$\(GEN_X_SEED_OBJS\):/ { hit=1; next }
      hit && /^[^#[:space:]\t]/ { exit 1 }
      hit && /ensure_host_cc_seed_o\.sh/ && /try-heat/ { found=1; exit 0 }
      END { exit found ? 0 : 1 }
    ' Makefile; then
    note "Makefile GEN_X multi-target FORCE thin try-heat (wave909; covers four)"
  fi
  for leaf in lsp_io_x.o lsp_x.o lsp_diag_x.o pipeline_x.o; do
    if makefile_leaf_try_heat_ok "$leaf" 'try-heat|try-gen-x'; then
      note "Makefile $leaf thin-calls try-heat|try-gen-x (wave761/796/909)"
    elif awk -v t="$leaf" '
      $0 ~ "^" t ":" {grab=1; next}
      grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
      grab {body = body $0 "\n"}
      END {
        if (body ~ /ensure_gen_x_o\.sh/) exit 0
        if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-heat/) exit 0
        exit 1
      }
    ' Makefile; then
      note "Makefile $leaf thin-calls try-heat|ensure_gen_x_o (wave761/796)"
    else
      bad "Makefile $leaf must thin-call try-heat or ensure_gen_x_o.sh (wave761/796/909)"
    fi
  done

  # wave789: B7A heat auto-dispatch entry must exist (shell ladder; no second body).
  if ! grep -q 'try_heat_one\|try-heat' "$0"; then
    bad "try-heat / try_heat_one missing (wave789 B7A heat shell dispatch)"
  else
    note "try-heat B7A heat auto-dispatch present (wave789)"
  fi
  # wave862: try-heat CFLAGS bulk shell-load via export-try-heat-cflags (G.7).
  # Makefile try-heat recipes must not re-inject CFLAGS=/PIPELINE_GEN_CFLAGS=.
  # wave942: catalog-primary CFLAGS load (was make export-try-heat-cflags).
  # Makefile physically deleted in wave941; catalog is the single authority.
  if ! grep -q '_load_try_heat_cflags_via_catalog\|export-try-heat-cflags' "$0"; then
    bad "shell must load try-heat CFLAGS via catalog (wave862/942)"
  else
    note "try-heat CFLAGS catalog-load present (wave862/942)"
  fi
  _th_cflags_n=$(awk '
    $0 ~ /ensure_host_cc_seed_o\.sh try-heat/ { grab=1 }
    grab {
      body = body $0 "\n"
      if ($0 ~ /try-heat \$\@/) {
        if (body ~ /CFLAGS="\$\(CFLAGS\)"/ || body ~ /PIPELINE_GEN_CFLAGS="\$\(PIPELINE_GEN_CFLAGS\)"/) n++
        body=""; grab=0
      }
    }
    END { print n+0 }
  ' Makefile)
  if [ "${_th_cflags_n:-0}" -ne 0 ]; then
    bad "Makefile try-heat recipes still inject CFLAGS=/PIPELINE_GEN_CFLAGS= (wave862; got ${_th_cflags_n})"
  else
    note "Makefile try-heat recipes drop CFLAGS/PIPELINE_GEN inject (wave862)"
  fi
  if ! grep -q 'seed_project_hdrs_newer' "$0"; then
    bad "seed_project_hdrs_newer missing (wave793 B7A hdr mtime for FORCE thin)"
  else
    note "seed_project_hdrs_newer present (wave793 project-header freshness)"
  fi
  if ! grep -q 'force_thin_makefile_flags_newer' "$0"; then
    bad "force_thin_makefile_flags_newer missing (wave794 Makefile-flags FORCE thin)"
  else
    note "force_thin_makefile_flags_newer present (wave794 flag-sensitive leaves)"
  fi
  if ! grep -q 'try_ensure_runtime_os_prefer_one' "$0" \
    || ! grep -q 'try_ensure_r1_one' "$0" \
    || ! grep -q 'try_ensure_gen_x_one' "$0"; then
    bad "try-heat ladder requires existing try-* helpers (wave789 G.7 有则补全)"
  else
    note "try-heat ladder deps present (prefer/R1/gen; wave789)"
  fi

  if [ "$fail" -ne 0 ]; then
    echo "ensure_host_cc_seed_o: --check FAILED" >&2
    exit 1
  fi
  # wave796: net multi-merge FORCE thin requires multi .x/seed mtime loop.
  if ! grep -q 'udp_batch.x' "$0" || ! grep -q 'runtime_net_sock_fast.from_x.c' "$0"; then
    bad "net_merge multi-source mtime missing (wave796 B7A FORCE thin)"
  else
    note "net_merge multi-source mtime present (wave796 FORCE thin)"
  fi
  # wave866: crt0_mingw must not inject multi-token WIN32_O_CFLAGS= (G.7 hygiene).
  # Shell uses ${WIN32_O_CFLAGS:-}; no Makefile ?= composition for this bag.
  # wave913: mingw is multi-target member — also scan multi-target body if no per-leaf line.
  _win_rec=$(awk '
    $0 ~ /^src\/asm\/crt0_mingw\.o:/ {grab=1; next}
    grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
    grab {print}
  ' Makefile 2>/dev/null || true)
  if [ -z "${_win_rec:-}" ]; then
    _win_rec=$(awk '
      /\$\(DRIVER_SEED_CRT0_OBJS\):/ { grab=1; next }
      grab && /^[^#[:space:]\t]/ { exit }
      grab { print }
    ' Makefile 2>/dev/null || true)
  fi
  if grep -qE 'WIN32_O_CFLAGS=' <<<"${_win_rec:-}"; then
    bad "Makefile crt0_mingw still injects WIN32_O_CFLAGS= (wave866/913)"
  else
    note "Makefile crt0_mingw drops WIN32_O_CFLAGS inject (wave866/913 multi-target)"
  fi
  echo "ensure_host_cc_seed_o: CHECK OK (R1 families + try-r1 + R3 cold-else + R3 PREFER thin + R2 panic/typeck_f64/crt0 + gen-x residual + try-heat + CFLAGS shell-load wave862 + WIN32_O drop wave866 + hdr/Makefile-flags + net multi-merge mtime · wave748–866)" >&2
}

# ---------------------------------------------------------------------------
# wave789: try-heat OUT — B7A heat shell auto-dispatch (G.7 有则补全).
#
# Single heat entry that ladders *existing* membership helpers only.
# Prefer/hybrid product modes run before pure R1/R2/gen so heat matches
# Makefile product thin-call semantics (labi/rt/pipeline_abi/… before R1).
# Exit codes:
#   0 — some mode claimed OUT and ensure body ran (or skipped up-to-date)
#   3 — no ensure mode claims OUT (caller residual make / non-ensure leaf)
#   1/2 — matching mode hard-failed
# PLATFORM: SHARED — orchestration only; no second recipe body / no .o list.
# NOT physical delete: Makefile thin-call edges remain for make dep graph.
# wave791–794: FORCE-thin leaves (pure seed+.x(+.h) + twin + Makefile-flags +
# pure leftover) still use this ladder for seed/.x/project-hdr/Makefile-flags
# (and prefer-table) freshness — cheap skip when up-to-date
# (seed_project_hdrs_newer · force_thin_makefile_flags_newer).
# ---------------------------------------------------------------------------
try_heat_one() {
  local o="$1"
  local rc
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-heat: need <out.o>" >&2
    exit 2
  fi
  # Prefer / hybrid first (heat product path), then pure R1, R2 UNAME, gen-x.
  # Each helper exits 3 when OUT is not a member — cheap membership only.
  set +e
  try_ensure_runtime_os_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_std_core_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_lsp_sat_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_gen_c_to_o_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_cfg_eval_ladder_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_r3_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_labi_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_rt_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_pipeline_abi_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_ldpc_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_target_cpu_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_l2_asm_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_async_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_other_l2_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_r2_prefer_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_r1_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_r2_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  set +e
  try_ensure_gen_x_one "$o"; rc=$?; set -e
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -ne 3 ] && return "$rc"
  # Honest residual: not an ensure-owned leaf (make graph / non-catalog).
  return 3
}

case "$MODE" in
  inject-macho-write|inject_macho_write)
    # Durable C-thin ingest of clang-aligned pipeline_macho_write_o_to_buf_c.
    # Does NOT run try-pipeline-abi-prefer (no mega -E, no other thins).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-macho-write: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_macho_write_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-modlet-prepare|inject_modlet_prepare)
    # wave345: MODLET_IN_REST prepare/bake into product pabi (no mega -E).
    # PLATFORM: SHARED · LINUX gold · MACOS co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-modlet-prepare: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_modlet_prepare_rest "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-emit-ctx-bss|inject_emit_ctx_bss)
    # Durable C-thin ingest: w220–224 emit_ctx/typeck + w261–w267／w269 Cap domain C thins (w268=.x).
    # Does NOT run try-pipeline-abi-prefer. Prior leaves may no-op on Darwin
    # when already ingested. PLATFORM: SHARED · MACOS + LINUX.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-emit-ctx-bss: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_emit_ctx_bss_thin "$1"
    pipeline_abi_inject_emit_ctx_func_index_thin "$1"
    pipeline_abi_inject_block_final_expr_thin "$1"
    pipeline_abi_inject_return_elf_impl_thin "$1"
    pipeline_abi_inject_emit_ctx_module_dep_thin "$1"
    pipeline_abi_inject_emit_ctx_sret_thin "$1"
    pipeline_abi_inject_typeck_active_thin "$1"
    pipeline_abi_inject_glue_statics_thin "$1"
    pipeline_abi_inject_type_alias_thin "$1"
    pipeline_abi_inject_module_import_thin "$1"
    pipeline_abi_inject_module_enum_thin "$1"
    pipeline_abi_inject_top_level_let_thin "$1"
    pipeline_abi_inject_struct_layout_thin "$1"
    pipeline_abi_inject_asm_locals_thin "$1"
    pipeline_abi_inject_block_tree_thin "$1"
    pipeline_abi_inject_type_pool_thin "$1"
    pipeline_abi_inject_grow_vec_thin "$1"
    pipeline_abi_inject_dep_ctx_thin "$1"
    pipeline_abi_inject_elf_ctx_thin "$1"
    pipeline_abi_inject_const_lit_is_const "$1"
    pipeline_abi_inject_asm_wpo_cap "$1"
    pipeline_abi_inject_reloc_typed_page21 "$1"
    pipeline_abi_inject_data_len_dual_bss "$1"
    pipeline_abi_inject_asm_wpo_thin "$1"
    pipeline_abi_inject_sidecar_pool_thin "$1"
    pipeline_abi_inject_value_abi_thin "$1"
    pipeline_abi_inject_block_domain_thin "$1"
    pipeline_abi_inject_expr_sidecar_thin "$1"
    pipeline_abi_inject_lifecycle_thin "$1"
    pipeline_abi_inject_module_func_thin "$1"
    pipeline_abi_inject_onefunc_thin "$1"
    pipeline_abi_inject_bootstrap_glue_thin "$1"
    pipeline_abi_inject_ast_forwarders_thin "$1"
    pipeline_abi_inject_parse_orch_thin "$1"
    pipeline_abi_inject_typeck_orch_thin "$1"
    pipeline_abi_inject_typeck_check_expr_thin "$1"
    pipeline_abi_inject_parser_result_thin "$1"
    pipeline_abi_inject_asm_label_format_thin "$1"
    pipeline_abi_inject_codegen_outbuf_thin "$1"
    pipeline_abi_inject_asm_codegen_mega_body_thin "$1"
    pipeline_abi_inject_elf_codegen_forwarders_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-asm-label|inject_asm_label|inject-asm-label-format)
    # wave353: asm_label_format PREFER_ASM both ends (digit-loop into caller buf).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-asm-label: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_asm_label_format_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-glue-statics|inject_glue_statics)
    # wave332: glue_statics PREFER_ASM (stamp + ALLOW_E_REPLACE).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-glue-statics: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_glue_statics_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-codegen-outbuf|inject_codegen_outbuf)
    # wave355: codegen_outbuf PREFER_ASM both ends (T001 unsafe + float buf).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-codegen-outbuf: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_codegen_outbuf_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-read-file-x-view|inject_read_file_x_view)
    # wave352: read_file_x_view PREFER_ASM both ends (class B FileView).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-read-file-x-view: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_read_file_x_view_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-import-heap|inject_import_heap)
    # wave487: import_heap peer-flat tip PREFER (resolve/read_prep/parse+gate).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-import-heap: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_import_heap_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-preprocess-malloc|inject_preprocess_malloc|inject-add-defs|inject_add_defs)
    # wave333: preprocess_malloc PREFER_ASM (stamp + ALLOW_E_REPLACE).
    # wave609 M2: add_defs leaf product PREFER_ASM (no host-cc).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-preprocess-malloc: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_preprocess_malloc_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-grow-vec|inject_grow_vec)
    # wave597: LINUX -E replace starved grow_vec (restore realloc/mmap).
    # MACOS keep prior. HARD BAN PREFER (w489 BLD001).
    # PLATFORM: LINUX gold · MACOS keep prior.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-grow-vec: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_grow_vec_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-deref-scalar|inject_deref_scalar)
    # wave598: LINUX -E replace smash leftover scalar PREFER.
    # MACOS keep overlay. HARD BAN PREFER (w534).
    # PLATFORM: LINUX gold · MACOS keep prior.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-deref-scalar: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_deref_scalar_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-rhsrax-to-rax|inject_rhsrax_to_rax)
    # wave599: LINUX -E replace smash leftover rhs_to_rax PREFER.
    # MACOS keep overlay. HARD BAN PREFER (w454).
    # PLATFORM: LINUX gold · MACOS keep prior.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-rhsrax-to-rax: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_rhsrax_to_rax_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-assign-var|inject_assign_var)
    # wave600 -E replaced the smash-era PREFER; wave620 re-verified on the
    # w613–w619 chain and flipped the family to PREFER_ASM both ends.
    # PLATFORM: SHARED · PREFER_ASM.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-assign-var: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_assign_var_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-type-pool|inject_type_pool)
    # wave383/383b: type_pool PREFER_ASM both ends; stamp exists → skip
    # (HARD BAN tip force-reinject; ignore thin.x mtime after pull).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-type-pool: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_type_pool_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-modlet|inject_modlet)
    # wave631: modlet family ONE-set PREFER (w629 dual-table root fix).
    # PLATFORM: SHARED · PREFER_ASM both ends.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-modlet: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_modlet_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-wpo-dump|inject_wpo_dump)
    # wave498: LINUX -E helpers. wave611: standalone PREFER U-complete;
    #   product PREFER blocked on the COMMON misclassification. wave613
    #   fixed it (MACOS PREFER); wave615: PREFER both ends.
    # wave746: leftover rebuild wipe → re-PREFER when live dump is weak/W.
    # PLATFORM: SHARED shell · PREFER_ASM both ends.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-wpo-dump: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_wpo_dump_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-type-to-c-repr|inject_type_to_c_repr|inject-ttc)
    # wave412: MACOS full PREFER / LINUX helpers PREFER.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-type-to-c-repr: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_type_to_c_repr_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-unused-hints|inject_unused_hints)
    # wave398: unused_hints PREFER_ASM both ends (stamp + ALLOW_E_REPLACE).
    # wave493: LINUX -E after tip PREFER SEGV. wave738: LINUX PREFER_ASM
    #   replace leftover gcc W (standalone U-complete; no host-cc).
    #   MACOS keep prior PREFER overlay.
    # PLATFORM: SHARED shell · MACOS keep overlay · LINUX gold ingest.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-unused-hints: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_unused_hints_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-fnptr-as|inject_fnptr_as)
    # wave507: PREFER both ends. wave606: LINUX -E replace smash leftover
    #   as_cast_orch T (drops INDEX operand of `as`). HARD BAN PREFER.
    #   MACOS stamp-only keep overlay.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-fnptr-as: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_fnptr_as_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-assign-index|inject_assign_index)
    # wave460–w471: PREFER LINUX heals. wave607: LINUX -E replace smash
    #   leftover assign_index T (extra pop/store overwrites u8 `b[2]=7`).
    #   HARD BAN PREFER. MACOS stamp-only keep overlay.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-assign-index: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_assign_index_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-fnptr-array-esz|inject_fnptr_array_esz|inject-fnptr-arr-esz)
    # wave399/w496: PREFER both ends. wave605: LINUX -E replace smash leftover
    #   elem_byte_sz T (u8 ARRAY_LIT store_sz=4). HARD BAN PREFER.
    #   MACOS stamp-only keep overlay.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-fnptr-array-esz: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_fnptr_array_esz_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-slot-bytes|inject_slot_bytes)
    # wave415: MACOS full PREFER / LINUX helpers PREFER.
    # wave590: LINUX helpers HARD BAN tip PRODUCT reinject (keep w415).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-slot-bytes: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_slot_bytes_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
    inject-field-load-sz|inject_field_load_sz)
    # wave414: MACOS full PREFER / LINUX helpers PREFER.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-field-load-sz: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_field_load_sz_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
    inject-param-ptr-slot|inject_param_ptr_slot)
    # wave610 M2: product PREFER_ASM both ends (no host-cc for this TU).
    # PLATFORM: SHARED shell · LINUX gold + MACOS.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-param-ptr-slot: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_param_ptr_slot_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
    inject-assign|inject_assign)
    # wave421/437: MACOS full PREFER / LINUX helpers+rhsrax PREFER (emit BAN).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-assign: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_assign_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
    inject-arr-lit-flat|inject_arr_lit_flat)
    # wave438: BOTH PREFER flat peer chain.
    # wave568: repark HARD BAN tip PRODUCT reinject (keep w438 overlay).
    # wave569: one_cell HARD BAN tip PRODUCT reinject (keep w438 overlay).
    # wave570: cells HARD BAN tip PRODUCT reinject (keep w438 overlay).
    # wave571: one_row HARD BAN tip PRODUCT reinject (keep w438 overlay).
    # wave572: rows HARD BAN tip PRODUCT reinject (keep w438 overlay).
    # wave573: struct HARD BAN tip PRODUCT reinject (keep w438 overlay).
    # wave574: one_scalar HARD BAN tip PRODUCT reinject (keep w438 overlay).
    # wave575: step HARD BAN tip PRODUCT reinject (keep w438 overlay).
    # wave576: scalar HARD BAN tip PRODUCT reinject (keep w438 overlay).
    # wave577: main HARD BAN tip PRODUCT reinject (keep w438 overlay).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-arr-lit-flat: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_arr_lit_flat_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
    inject-arr-return|inject_arr_return)
    # wave439: BOTH PREFER flat peer chain.
    # wave510: b0/c HARD BAN tip PRODUCT reinject (keep w439 overlay).
    # wave560: a0 HARD BAN tip PRODUCT reinject (keep w439 overlay).
    # wave578: a HARD BAN tip PRODUCT reinject (keep w439 overlay).
    # wave579: a2 HARD BAN tip PRODUCT reinject (keep w439 overlay).
    # wave580: b0_prep HARD BAN tip PRODUCT reinject (keep w439 overlay).
    # wave581: b0_durable HARD BAN tip PRODUCT reinject (keep w439 overlay).
    # wave582: b HARD BAN tip PRODUCT reinject (keep w439 overlay).
    # wave583: c_dest_array HARD BAN tip PRODUCT reinject (keep w439 overlay).
    # wave584: c_slice HARD BAN tip PRODUCT reinject (keep w439 overlay).
    # wave585: c_fallback HARD BAN tip PRODUCT reinject (keep w439 overlay).
    # wave586: d HARD BAN tip PRODUCT reinject (keep w439 overlay).
    # wave587: main HARD BAN tip PRODUCT reinject (keep w439 overlay).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-arr-return: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_arr_return_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
    inject-arr-struct-lit|inject_arr_struct_lit)
    # wave440/442: MACOS pure-asm PREFER / LINUX -E peer PREFER (call heal).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-arr-struct-lit: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_arr_struct_lit_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
    inject-binop-var-slot-cache|inject_binop_var_slot_cache)
    # wave404: HARD BAN tip reinject both ends.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-binop-var-slot-cache: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_binop_var_slot_cache_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
    inject-binop-stack-spill-try-reload|inject_binop_stack_spill_try_reload)
    # wave405: PREFER both ends.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-binop-stack-spill-try-reload: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_binop_stack_spill_try_reload_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
    inject-w157-sum|inject_w157_sum)
    # wave406: HARD BAN tip reinject both ends.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-w157-sum: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_w157_sum_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
    inject-binop-block-peel|inject_binop_block_peel)
    # wave423: MACOS full PREFER / LINUX helpers+may_clobber+load_to_rbx PREFER.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-binop-block-peel: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_binop_block_peel_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
    inject-fixed-array-copy|inject_fixed_array_copy|inject-call-arg-lea|inject_call_arg_lea)
    # wave418: MACOS full PREFER / LINUX helpers PREFER.
    # wave608: LINUX -E replace smash leftover lea-not-load T (CALL-arg T[N]
    #   loaded payload as pointer). HARD BAN PREFER. MACOS stamp-only keep overlay.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-fixed-array-copy: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_fixed_array_copy_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
    inject-asm-expr|inject_asm_expr)
    # wave419: MACOS full PREFER / LINUX HARD BAN (helpers product opt=255).
    # wave495: LINUX helpers -E after tip PREFER L2 FAIL.
    # wave739: LINUX helpers PREFER_ASM replace leftover gcc W rec
    #   (standalone U-complete; no host-cc). MACOS keep full overlay.
    # PLATFORM: SHARED shell · MACOS keep overlay · LINUX gold ingest.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-asm-expr: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_asm_expr_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-al-nc-seq|inject_al_nc_seq)
    # wave409b: HARD BAN tip reinject both ends.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-al-nc-seq: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_al_nc_seq_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-reent-deep-copy|inject_reent_deep_copy)
    # wave410d: PREFER both ends.
    # wave589: HARD BAN tip PRODUCT reinject (keep w410 overlay).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-reent-deep-copy: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_reent_deep_copy_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-asm73-chaitin|inject_asm73_chaitin)
    # wave410: HARD BAN tip reinject both ends.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-asm73-chaitin: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_asm73_chaitin_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-call-method-wrappers|inject_call_method_wrappers)
    # wave411: PREFER both ends.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-call-method-wrappers: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_call_method_wrappers_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-block-tree|inject_block_tree)
    # wave302: C→.x block_tree via -E+$CC (stamp + ALLOW_E_REPLACE).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-block-tree: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_block_tree_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-type-alias|inject_type_alias)
    # wave358: type_alias PREFER_ASM both ends (T001 w303_* wrappers).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-type-alias: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_type_alias_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-asm-locals|inject_asm_locals)
    # wave430/490/604: LINUX -E replace; MACOS HARD BAN (pure-asm SEGV).
    # wave595: get peer PREFER BAN (L2 SEGV).
    # wave604: complete -E so trailing get shares BSS with set (nested inner let).
    # wave617: product PREFER_ASM both ends (w613 COMMON + dual-end L4).
    # wave747: leftover rebuild wipe → re-PREFER when live get is weak/W.
    # PLATFORM: SHARED shell · PREFER_ASM both ends.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-asm-locals: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_asm_locals_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-top-level-let|inject_top_level_let)
    # wave359b: BAN re-overlay top_level_let (elf_o poison); skip if already T.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-top-level-let: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_top_level_let_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-module-enum|inject_module_enum)
    # wave386: module_enum HARD BAN reinject both ends (stamp only;
    #   keep prior Darwin PREFER / Ubuntu -E). PLATFORM: SHARED.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-module-enum: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_module_enum_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-module-import|inject_module_import)
    # wave390: module_import HARD BAN reinject both ends (stamp only;
    #   keep prior Darwin -E / Ubuntu hard-skip). PLATFORM: SHARED.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-module-import: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_module_import_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-asm-wpo|inject_asm_wpo)
    # wave311: C→.x asm_wpo via -E+$CC (stamp + ALLOW_E_REPLACE).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-asm-wpo: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_const_lit_is_const "$1"
    pipeline_abi_inject_asm_wpo_cap "$1"
    pipeline_abi_inject_reloc_typed_page21 "$1"
    pipeline_abi_inject_data_len_dual_bss "$1"
    pipeline_abi_inject_asm_wpo_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-elf-ctx|inject_elf_ctx)
    # wave382: HARD BAN reinject both ends (Darwin BRANCH26; Ubuntu SEGV).
    # Excludes macho_write (macho_write_thin). PLATFORM: SHARED shell · stamp only.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-elf-ctx: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_elf_ctx_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-typeck-active|inject_typeck_active)
    # wave339: typeck_active Cap A — LINUX PREFER_ASM / DARWIN -E+$CC.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-typeck-active: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_typeck_active_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-macho-write|inject_macho_write)
    # wave314: C→.x macho_write via -E+$CC (stamp + ALLOW_E_REPLACE).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-macho-write: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_macho_write_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-modlet-prepare|inject_modlet_prepare)
    # wave345: MODLET_IN_REST prepare/bake (no mega -E). PLATFORM: SHARED.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-modlet-prepare: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_modlet_prepare_rest "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-emit-ctx-module-dep|inject_emit_ctx_module_dep)
    # wave601: LINUX -E replace smash leftover T; MACOS stamp-only keep overlay.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-emit-ctx-module-dep: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_emit_ctx_module_dep_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-emit-ctx-sret|inject_emit_ctx_sret)
    # wave341: emit_ctx_sret Cap A — LINUX PREFER_ASM / DARWIN -E+$CC.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-emit-ctx-sret: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_emit_ctx_sret_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-block-final-expr|inject_block_final_expr)
    # wave601: LINUX -E tail_join unknown-identity=0; MACOS stamp-only keep overlay.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-block-final-expr: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_block_final_expr_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-return-elf-impl|inject_return_elf_impl)
    # wave602: LINUX -E operand+tail_join jmp; MACOS stamp-only keep overlay.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-return-elf-impl: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_return_elf_impl_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-emit-ctx-func-index|inject_emit_ctx_func_index)
    # wave601: stamp-only BAN (LINUX -E dual-BSS option SEGV).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-emit-ctx-func-index: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_emit_ctx_func_index_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-emit-ctx-bss-leaf|inject_emit_ctx_bss_leaf)
    # wave380: stamp-only BAN full bss_thin. wave601 smash is func-index peer.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-emit-ctx-bss-leaf: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_emit_ctx_bss_thin "$1"
    pipeline_abi_inject_emit_ctx_func_index_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-typeck-orch|inject_typeck_orch)
    # wave331: typeck_orch PREFER_ASM (was wave318 -E+$CC).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-typeck-orch: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_typeck_orch_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-typeck-check-expr|inject_typeck_check_expr)
    # wave379: HARD BAN reinject both ends (Ubuntu XT001; Darwin BRANCH26).
    # PLATFORM: SHARED shell · stamp only.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-typeck-check-expr: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_typeck_check_expr_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-lifecycle|inject_lifecycle)
    # wave334: lifecycle PREFER_ASM (stamp + ALLOW_E_REPLACE).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-lifecycle: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_lifecycle_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-for-call-args|inject_for_call_args|inject-fca|inject_fca)
    # wave375: for_call_args PREFER_ASM both ends (stamp + ALLOW_E_REPLACE).
    # wave588: HARD BAN tip PRODUCT reinject (keep w375 overlay).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-for-call-args: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_for_call_args_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-bootstrap|inject_bootstrap|inject-bootstrap-glue|inject_bootstrap_glue)
    # wave391: bootstrap_glue HARD BAN reinject both ends (stamp only;
    #   keep prior Darwin -E / Ubuntu hard-skip). PLATFORM: SHARED.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-bootstrap: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_bootstrap_glue_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-ast-forwarders|inject_ast_forwarders|inject-astfwd|inject_astfwd)
    # wave336: ast_forwarders PREFER_ASM (stamp + ALLOW_E_REPLACE).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-ast-forwarders: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_ast_forwarders_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-parse-orch|inject_parse_orch|inject-porch|inject_porch)
    # wave388: parse_orch HARD BAN reinject both ends (stamp only;
    #   keep prior Darwin PREFER / Ubuntu hard-skip). PLATFORM: SHARED.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-parse-orch: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_parse_orch_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-module-func|inject_module_func|inject-mfn|inject_mfn)
    # wave385: module_func HARD BAN reinject both ends (stamp only;
    #   keep prior Darwin PREFER / Ubuntu -E). PLATFORM: SHARED.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-module-func: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_module_func_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-onefunc|inject_onefunc|inject-ofn|inject_ofn)
    # wave379: HARD BAN PREFER (w335 SEGV; w379 XP001) — stamp only.
    # PLATFORM: SHARED shell.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-onefunc: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_onefunc_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-block-domain|inject_block_domain|inject-blkdom|inject_blkdom)
    # wave364: block_domain PREFER_ASM try (T001 w326_*); L2 gate required.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-block-domain: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_block_domain_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-expr-sidecar|inject_expr_sidecar|inject-exsc|inject_exsc)
    # wave327: C→.x expr_sidecar via -E+$CC (stamp + ALLOW_E_REPLACE).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-expr-sidecar: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_expr_sidecar_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-mega-body|inject_mega_body|inject-megabody|inject_megabody)
    # wave394: three-leaf PREFER unlock (helpers / emit_one / loop).
    # PLATFORM: SHARED.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-mega-body: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_asm_codegen_mega_body_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-parser-result|inject_parser_result|inject-pres|inject_pres)
    # wave381: HARD BAN reinject both ends (tip T001 / XT001) — stamp only.
    # PLATFORM: SHARED shell.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-parser-result: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_parser_result_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-value-abi|inject_value_abi|inject-vabi|inject_vabi)
    # wave384: value_abi HARD BAN reinject both ends (sret; stamp only).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-value-abi: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_value_abi_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-struct-layout|inject_struct_layout)
    # wave362: struct_layout HARD BAN (PREFER L2 option=240); stamp only.
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-struct-layout: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_struct_layout_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-sidecar-pool|inject_sidecar_pool)
    # wave308/366/w504: sidecar_pool PREFER + init peers (stamp w504).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-sidecar-pool: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_sidecar_pool_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-dep-ctx|inject_dep_ctx)
    # wave309: C→.x dep_ctx via -E+$CC (stamp + ALLOW_E_REPLACE).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o inject-dep-ctx: need <out.o>" >&2
      exit 2
    fi
    set +e
    pipeline_abi_inject_dep_ctx_thin "$1"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  inject-pabi-leaf|inject_pabi_leaf)
    # One-leaf PREFER_ASM overlay via pipeline_abi_inject_thin_leaf.
    # Does NOT run try-pipeline-abi-prefer (no mega -E, no other thins).
    # PLATFORM: SHARED shell · MACOS ingest · LINUX gold co-path.
    if [ "$#" -lt 2 ]; then
      echo "ensure_host_cc_seed_o inject-pabi-leaf: need <out.o> <thin.x> [tag]" >&2
      exit 2
    fi
    export XLANG_PABI_THIN_PREFER_ASM=1
    export XLANG_PABI_THIN_PREFER_ASM_ONLY="$(basename "$2" .x)"
    set +e
    pipeline_abi_inject_thin_leaf "$1" "$2" "${3:-pabi-leaf}"
    _irc=$?
    set -e
    exit "$_irc"
    ;;
  try-x-to-o|x-to-o)
    # F1-2026-08-18 chunked -E builder: generic rt_prefer harness entry for
    # arbitrary (SRC.x, OUT.o) pairs. Purpose: split OOM-prone mega modules
    # (runtime_pipeline_abi.x -E peaks 22-40GB RSS) into line-balanced chunks,
    # each small enough for dev-box jetsam limits; caller merges chunk .o's
    # via pure_ld_partial_merge (first-wins). Env passthrough (single
    # authority stays rt_prefer_try_x_to_o — no second build path, G.7):
    #   XLANG_PREFER_ASM_O_RT=0  → historic -E+$CC (chunk path default)
    #   G05_X_O_WEAK=1           → weakify function defs (first-wins merge)
    #   G05_X_O_GLOBALS_WEAK=1   → un-static + weakify g_* globals (shared
    #                              storage across chunks; see weakify block)
    # PLATFORM: SHARED harness.
    if [ "$#" -lt 2 ]; then
      echo "ensure_host_cc_seed_o try-x-to-o: need <src.x> <out.o>" >&2
      exit 2
    fi
    set +e
    rt_prefer_try_x_to_o "$1" "$2"
    _xrc=$?
    set -e
    exit "$_xrc"
    ;;
  one)
    if [ "$#" -lt 2 ]; then
      echo "ensure_host_cc_seed_o one: need <out.o> <seed.from_x.c> [extra...]" >&2
      exit 2
    fi
    ensure_one "$@"
    ;;
  try-r1|try_r1|one-r1|r1-one)
    # wave756: R4 pure-R1 helper — exit 3 if not pure R1 catalog member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-r1: need <out.o>" >&2
      exit 2
    fi
    # Drop trailing --force tokens already handled via FORCE global.
    _try_out="$1"
    set +e
    try_ensure_r1_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-r3-cold|try_r3_cold|r3-cold|r3-cold-one)
    # wave757: R3 cold-else helper — exit 3 if not R3_COLD_SEED_OBJS member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-r3-cold: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_r3_cold_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-r3-prefer|try_r3_prefer|r3-prefer|r3-prefer-one|prefer-thin|try-prefer-thin)
    # wave763: R3 PREFER thin+rest helper — exit 3 if not R3_COLD_SEED_OBJS member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-r3-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_r3_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  r3-prefer-family|r3_prefer_family|prefer-thin-family|family=r3_prefer)
    ensure_r3_prefer
    ;;
  try-labi-prefer|try_labi_prefer|labi-prefer|labi-prefer-one|try-labi)
    # wave765: labi multi-slice PREFER helper — exit 3 if not src/runtime_link_abi.o.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-labi-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_labi_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-rt-prefer|try_rt_prefer|rt-prefer|rt-prefer-one|try-rt)
    # wave766: rt multi-slice PREFER helper — exit 3 if not src/runtime_driver_no_c.o.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-rt-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_rt_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-pipeline-abi-prefer|try_pipeline_abi_prefer|pipeline-abi-prefer|pipeline-abi|try-pabi)
    # wave767: pipeline_abi PREFER helper — exit 3 if not src/runtime_pipeline_abi.o.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-pipeline-abi-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_pipeline_abi_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-ldpc-prefer|try_ldpc_prefer|ldpc-prefer|ldpc-prefer-one|try-ldpc)
    # wave767: ldpc PREFER helper — exit 3 if not src/lsp/lsp_diag_pipeline_ctx.o.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-ldpc-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_ldpc_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-target-cpu-prefer|try_target_cpu_prefer|target-cpu-prefer|tcpu-prefer|try-tcpu)
    # wave768: target_cpu PREFER helper — exit 3 if not src/driver/target_cpu.o.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-target-cpu-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_target_cpu_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-l2-asm-prefer|try_l2_asm_prefer|l2-asm-prefer|l2-asm|try-l2-asm)
    # wave769: L2 asm three PREFER helper — exit 3 if not table member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-l2-asm-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_l2_asm_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-async-prefer|try_async_prefer|async-prefer|async|try-async)
    # wave770: async three PREFER helper — exit 3 if not table member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-async-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_async_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-other-l2-prefer|try_other_l2_prefer|other-l2-prefer|other-l2|try-other-l2|ol2-prefer)
    # wave771: other L2 four PREFER helper — exit 3 if not table member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-other-l2-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_other_l2_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-r2-prefer|try_r2_prefer|r2-prefer|panic-prefer|try-r2-prefer-panic)
    # wave776: R2 panic PREFER thin+rest; exit 3 if not DRIVER_SEED_PANIC member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-r2-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_r2_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-runtime-os-prefer|try_runtime_os_prefer|runtime-os-prefer|rtos-prefer|try-runtime-os|b1-prefer)
    # wave779: B1 runtime_* OS/glue PREFER table; exit 3 if not table member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-runtime-os-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_runtime_os_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-std-core-prefer|try_std_core_prefer|std-core-prefer|stdcore-prefer|try-std-core|b2-prefer)
    # wave780: B2 std/core product hybrid table; exit 3 if not table member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-std-core-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_std_core_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-lsp-sat-prefer|try_lsp_sat_prefer|lsp-sat-prefer|lspsat-prefer|try-lsp-sat|b3-prefer)
    # wave781: B3 LSP satellite hybrid table; exit 3 if not table member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-lsp-sat-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_lsp_sat_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-gen-c-to-o|try_gen_c_to_o|gen-c-to-o|genc2o|try-gen-c|b4-gen|b4-prefer)
    # wave782: B4 gen.c → .o bootstrap table; exit 3 if not table member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-gen-c-to-o: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_gen_c_to_o_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-cfg-eval-ladder|try_cfg_eval_ladder|cfg-eval-ladder|cfgeval-ladder|try-cfg-eval|b5-cfg|b5-ladder)
    # wave783: B5 cfg_eval multi-ladder; exit 3 if not member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-cfg-eval-ladder: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_cfg_eval_ladder_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-heat|try_heat|heat|heat-one|try-auto|auto|b7a-heat)
    # wave789: B7A heat shell auto-dispatch; exit 3 if no ensure mode claims OUT.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-heat: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_heat_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-r2|try_r2|try-r2-panic|r2-one|r2-panic-one)
    # wave760/762: R2 UNAME helper — panic | typeck_f64 | crt0; exit 3 if not member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-r2: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_r2_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-gen-x|try_gen_x|try-gen|gen-x-one|r4-gen-one)
    # wave761: gen residual helper — exit 3 if not gen map + catalog member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-gen-x: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_gen_x_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  r3-cold-seed|r3_cold_seed|cold-seed|family=r3_cold_seed)
    ensure_r3_cold_seed
    ;;
  r2-panic|r2_panic|panic-cold|family=r2_panic|family=driver_seed_panic)
    ensure_r2_panic
    ;;
  r2-typeck-f64|r2_typeck_f64|typeck-f64|typeck_f64|family=r2_typeck_f64|family=driver_seed_typeck_f64)
    ensure_r2_typeck_f64
    ;;
  r2-crt0|r2_crt0|crt0|family=r2_crt0|family=driver_seed_crt0)
    ensure_r2_crt0
    ;;
  gen-x|gen_x|residual-gen|family=gen_x|family=r4_gen_x)
    ensure_gen_x_residual
    ;;
  rt-slice|rt_slice|rt-seed-slice|family=rt_seed_slice)
    ensure_rt_slice
    ;;
  try-rt-emit-state-prefer|try-rt-emit-state)
    ensure_rt_emit_state_prefer
    ;;
  try-rt-arena-buf-prefer|try-rt-arena-buf)
    ensure_rt_arena_buf_prefer
    ;;
  try-rt-parse-diag-prefer|try-rt-parse-diag)
    ensure_rt_parse_diag_prefer
    ;;
  try-rt-preamble-prefer|try-rt-preamble)
    ensure_rt_preamble_prefer
    ;;
  try-xfla-prefer|try-x-frontend-link-alias-prefer)
    ensure_x_frontend_link_alias_prefer
    ;;
  core-seed|core_seed|core|r1-core|r1-core-seed|family=r1_core_seed)
    ensure_core_seed
    ;;
  frontend-glue|frontend_glue|glue|r1-frontend-glue|r1-glue|family=r1_frontend_glue)
    ensure_frontend_glue
    ;;
  main-runtime|main_runtime|r1-main-runtime|r1-main|family=r1_main_runtime)
    ensure_main_runtime
    ;;
  alias-stubs|alias_stubs|r1-alias-stubs|r1-alias|family=r1_alias_stubs)
    ensure_alias_stubs
    ;;
  extra-cflags|extra_cflags|r1-extra-cflags|r1-extra|pipeline-abi|family=r1_extra_cflags)
    ensure_extra_cflags
    ;;
  misc-basename|misc_basename|misc|r1-misc-basename|r1-misc|family=r1_misc_basename)
    ensure_misc_basename
    ;;
  seed-map|seed_map|r1-seed-map|r1-mismatch|mismatch|family=r1_seed_map)
    ensure_seed_map
    ;;
  all|family|families|swallowed)
    # Umbrella: all swallowed pure R1 families on this body.
    ensure_all_swallowed
    ;;
  --check|check|-c)
    run_check
    ;;
  help|-h|--help)
    sed -n '2,75p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "ensure_host_cc_seed_o: unknown mode '$MODE' (one|try-r1|try-r3-cold|try-r3-prefer|try-labi-prefer|try-rt-prefer|try-pipeline-abi-prefer|try-ldpc-prefer|try-target-cpu-prefer|try-r2-prefer|try-heat|try-r2|try-gen-x|try-x-to-o|rt-slice|core-seed|frontend-glue|main-runtime|alias-stubs|extra-cflags|misc-basename|seed-map|r3-cold-seed|r2-panic|r2-typeck-f64|r2-crt0|gen-x|all|--check)" >&2
    exit 2
    ;;
esac
