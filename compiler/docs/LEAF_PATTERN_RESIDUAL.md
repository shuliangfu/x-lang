# Leaf pattern residual (11.3.1 path · not physical delete)

> **Wave path (one line each · inventory → swallow · endgame still open):**
>
> - **wave746** · inventory (named classes R1–R6)
> - **wave747** · R4 mode-policy
> - **wave748–755** · R1 eight families
> - **wave756** · pure-R1 try-r1
> - **wave757** · R3 cold-else try-r3-cold
> - **wave758** · thin_glue seed-map
> - **wave759** · glue-standalone seed-map
> - **wave760** · R2 panic cold try-r2
> - **wave761** · gen/pipeline try-gen-x
> - **wave762–839** · R2/R3 prefer · phys-del prep · B7A–D · list→mk · FORCE dep-thin (see § wave rows)
> - **wave841–845** · B7C shell-primary (typeck/codegen · x-compiler · self · parser smoke · xlang-x-pipeline)
> - **wave846** · B7C xlang-x shell-primary (host-cc product link)
> - **wave847** · B7C xlang-no-c-frontend shell-primary (host-cc product link)
> - **wave848** · B7C bootstrap-driver-seed-x-frontend shell-primary (host-cc experiment link)
> - **wave849** · B7C relink-xlang-lexer shell-primary (host-cc product link + XLANG_C sync)
> - **wave850** · B7B RELINK_PRODUCT_LINK bag → composites.mk (BTC/RXL product link inventory)
> - **wave851** · B7B XXL/BS/XNC full link bags → composites + archaeology_experiment (3 bags)
> - **wave852** · B7B BXF full link bag → archaeology_experiment (bootstrap-driver-seed-x-frontend)
> - **wave853** · B7B seed phase1/final full link bags → composites.mk (SEED_LINK_OBJS; 2 bags)
> - **wave854** · B7B seed-gate REQUIRED_OBJS bags → composites + archaeology (RXL/XXL/XNC; 3 bags)
> - **wave855** · B7B seed-gate REQUIRED shell-load from mk (RXL/XXL/XNC; Makefile drops multi-token env export)
> - **wave856** · B7B archaeology LINK_OBJS shell-load via make export leaves (5 bags / 6 shells; nested expand)
> - **wave799** · execute-gate (hard refuse delete)
> - **wave857** · B7B archaeology LINK_CFLAGS shell-load via make export leaves (4 bags / 6 shells; drop multi-token CFLAGS env)
> - **wave858** · B7B LEGACY xlang-c link shell-primary (export leaf + CFLAGS reuse product)
> - **wave859** · B7B XXP/BXC multi-token bag shell-load via make export leaves (2 shells)
> - **wave860** · B7B driver_leaf BASE_CFLAGS multi-token shell-load via make export leaf (8 leaves)
> - **wave861** · B7B rt_* multi-token -I CFLAGS hygiene (5 RT_SEED_SLICE leaves; plain CFLAGS= try-heat)
> - **wave862** · B7B try-heat CFLAGS/PIPELINE_GEN_CFLAGS bulk shell-load via export-try-heat-cflags (114 recipes)
> - **wave863** · B7B class-G filter CFLAGS/PIPELINE_GEN shell-load hygiene (4 filter FORCE recipes; try-heat CC-only)
> - **wave864** · B7B leaf-extra RUNTIME_*/PARSER_* multi-token CFLAGS inject hygiene (3 leaves; ensure shell defaults)
> - **wave865** · B7B migrate/bootstrap multi-token CFLAGS shell-load via export-try-heat-cflags (8 recipes)
> - **wave866** · B7B build-tool CFLAGS shell-load + WIN32_O_CFLAGS leaf drop (2 recipes)
> - **wave867** · B7B archaeology host-pick LD_R_MULTIDEF_FLAGS leaf drop (4 recipes)
> - **wave868** · B7C bootstrap-driver-bstrict-relink shell-primary (1 phony → relink_xlang_asm_bstrict_runtime_objs.sh)
> - **wave869** · B7C bootstrap-driver-crt0 shell-primary (1 phony → bootstrap_driver_crt0.sh)
> - **wave870** · B7C check-7.2 shell-primary (1 phony → check_7_2.sh; seed stage1/stage2 smoke)
> - **wave871** · B7C check-6.4 shell-primary (1 phony → check_6_4.sh; seed emit-C + host-cc + exit 42)
> - **wave872** · B7C bootstrap-driver-hybrid shell-primary (1 phony → bootstrap_driver_hybrid.sh; B-hybrid build_xlang_asm + replace/soft-skip; alias -asm)
> - **wave873** · B7C regen-lsp-gens-x shell-primary (1 phony → regen_lsp_gens_x.sh; XLANG_X gate + rm four gens + make file targets)
> - **wave874** · B7C build-via-tool shell-primary (1 phony → build_via_tool.sh; run host build_tool → TARGET + OK; xbuild dual retired)
> - **wave875** · B7C size/perf-baseline shell-primary (2 phonies → stage8_baseline.sh; dispatch tests/run-{size,perf}-baseline; soft-skip)
> - **wave876** · B7C default `$(XLANG_C)` product alias shell-primary (1 target → ensure_xlang_c.sh; SKIP_SUBSCRIPT soft-skip + cp bootstrap_xlangc; LEGACY stays wave858)
> - **wave877** · B7B gen/lsp/archaeology ensure multi-token env inject hygiene (20 recipes → thin `@bash ensure_*_gen`; shell defaults own MAKE/XLANG_*/FORCE/TIMEOUT)
> - **wave878** · B7B migrate_x_objs multi-token CC/PYTHON/MAKE inject hygiene (4 recipes → thin `@sh migrate_x_objs`; shell defaults own CC/PYTHON/MAKE)
> - **wave879** · B7B stage/bootstrap multi-token TARGET/CC/MAKE inject hygiene (13 recipes → thin `@sh`/`@bash` clean/typeck/codegen/seed/relink/xlang-x/check-6.4/build-tool/self/pipeline/x-compiler; shell defaults own env)
> - **wave880** · B7B ENSURE=0 / OUT=$@ / all OPT inject hygiene (7 recipes → thin `@bash`/`@sh` all/test_c/test_x/seed-x-frontend/legacy-xlang-c/xnc/check-7.2-bstrict; MAKELEVEL shell defaults)
> - **wave881** · B7B try-heat XLANG_G05_PREFER_X_O inject hygiene (31 recipes → CC-only thin-call; PREFER via make CLI/env + shell default; net XLANG= drop)
> - **wave882** · B7B residual single-token TARGET= inject hygiene (10 recipes → drop TARGET= on token/lexer/parser/parse-file/hybrid/crt0/build-via-tool/check-7.2 + bstrict/refresh multi; shell TARGET:-xlang + CLI auto-export)
> - **wave883** · B7B residual single-token MAKE= inject hygiene (24 recipes → drop MAKE= on archaeology 4 + driver_leaf 8 + rebuild_leaves 7 + host_stubs 2 + phase1-link 1 + bstrict/refresh multi; shell MAKE:-make + GNU make auto-export; keep ENSURE_SEED/NO_REPLACE)
> - **wave884** · B7B residual single-token CC= inject hygiene (118 recipes → drop CC= on 116 pure try-heat/filter + strip CC= from cfg_eval LD bag + pipeline_x multi; shell `resolve_host_cc` + CLI/env; keep LD/pipeline bags)
> - **wave885** · B7B residual G05_SYNC inject hygiene (2 recipes → relink-xlang `--no-sync` + xlang_asm bare; drop `G05_SYNC_ASM=0/1` recipe inject; shell CLI/env default)
> - **wave886** · B7B residual LD + pipeline bag inject hygiene (2 recipes → cfg_eval drop `LD=`/`LD_RELFLAGS=`; pipeline_x drop `PIPELINE_X_*`/`XLANG_FORCE_REGEN_GEN`; shell LD defaults + mk DEPS load)
> - **wave887** · B7B residual terminal env inject hygiene (6 recipes → `XLANG_C` ensure `$@`; cc_inc_tu PEERS seed-map; drop `ENSURE_SEED`/`NO_REPLACE`/`XLANG=` injects; shell defaults + CLI/env)
> - **wave888** · B7B residual recipe thin-call form hygiene (22 recipe sites → drop dual `chmod +x`; unify `@./scripts/` / `sh ./…` → pure `@bash scripts/…`)
> - **wave889** · B7B residual non-thin recipe body / form hygiene (10 sites → drop dual `@mkdir -p build_asm` + panic stamp body; bare `sh scripts/cc_inc_tu` → `@bash`; `legacy-xlang-c-ready` nested `$(MAKE)` → thin ensure)
> - **wave890** · B7B residual bulk `@sh` → `@bash` thin-call form hygiene (77 sites → formal_mod 38 + std_x 22 + migrate/eoo/g05/clean/token/refresh; pure `@bash scripts/…`)
> - **wave891** · B7B residual non-thin HOST_CC + SKIP_SUBSCRIPT body hygiene (2 sites → HOST_CC_OBJS_CORE bare `$(CC)` → `host_cc_objs_core_link.sh`; SKIP_SUBSCRIPT nested `$(MAKE)` → `bootstrap_driver_seed.sh` soft-skip)
> - **wave892** · B7B residual terminal `@echo` + last multi-token `-I` form hygiene (13 sites → dual `@echo` drop 3 · pure `@echo`→`@true` 9 · last `cc_inc_tu` `-I` drop 1)
> - **wave893** · B7B residual verify-selfhost thin-call form hygiene (2 sites → body under `scripts/` · pure `@bash scripts/…` · root shim for CI/tests)
> - **wave894** · B7B formal_mod product edges list→mk + multi-target FORCE thin ensure (38 leaves → `mk/formal_mod_product_objs.mk` + `$(FORMAL_MOD_PRODUCT_OBJS)` ensure)
> - **wave895** · B7B std_x product edges list→mk + multi-target FORCE thin ensure (22 leaves → `mk/std_x_product_objs.mk` + `$(STD_X_PRODUCT_OBJS)` ensure)
> - **wave896** · B7B driver_leaf product edges list→mk + multi-target FORCE thin ensure (8 leaves → `mk/driver_leaf_product_objs.mk` + `$(DRIVER_LEAF_PRODUCT_OBJS)` ensure)
> - **wave897** · B7B B2 std_core hybrid product edges list→mk + multi-target FORCE thin try-heat (5 leaves → `mk/std_core_hybrid_product_objs.mk` + `$(STD_CORE_HYBRID_PRODUCT_OBJS)` try-heat)
> - **wave898** · B7B RT_SEED_SLICE product edges multi-target FORCE thin try-heat (5 leaves → `$(RT_SEED_SLICE_OBJS)` in `mk/driver_seed_r_lists.mk`; G.7 有则补全 no second list)
> - **wave899** · B7B R1_CORE_SEED product edges multi-target FORCE thin try-heat (5 leaves → `$(R1_CORE_SEED_OBJS)` in `mk/driver_seed_r_lists.mk`; G.7 有则补全 no second list)
> - **wave900** · B7B R1_FRONTEND_GLUE product edges multi-target FORCE thin try-heat (3 leaves → `$(R1_FRONTEND_GLUE_OBJS)` in `mk/driver_seed_r_lists.mk`; G.7 有则补全 no second list)
> - **wave901** · B7B R1_MAIN_RUNTIME product edges multi-target FORCE thin try-heat (7 leaves → `$(R1_MAIN_RUNTIME_OBJS)` in `mk/driver_seed_r_lists.mk`; G.7 有则补全 no second list)
> - **wave902** · B7B R1_ALIAS_STUBS product edges multi-target FORCE thin try-heat (8 leaves → `$(R1_ALIAS_STUBS_OBJS)` in `mk/driver_seed_r_lists.mk`; G.7 有则补全 no second list)
> - **wave903** · B7B R1_EXTRA_CFLAGS product edges multi-target FORCE thin try-heat (5 leaves → `$(R1_EXTRA_CFLAGS_OBJS)` in `mk/driver_seed_r_lists.mk`; G.7 有则补全 no second list)
> - **wave904** · B7B R1_MISC_BASENAME product edges multi-target FORCE thin try-heat (9 leaves → `$(R1_MISC_BASENAME_OBJS)` in `mk/driver_seed_r_lists.mk`; G.7 有则补全 no second list)
> - **wave905** · B7B R1_SEED_MAP product edges multi-target FORCE thin try-heat (5 leaves → `$(R1_SEED_MAP_OBJS)` in `mk/driver_seed_r_lists.mk`; G.7 有则补全 no second list)
> - **wave906** · B7B R3_COLD product edges multi-target FORCE thin try-heat (9 leaves → `$(R3_COLD_SEED_OBJS)` in `mk/driver_seed_r_lists.mk`; G.7 有则补全 no second list)
> - **open** · thin edges + mk lists hybrid (async / B1 runtime OS / gen-x / …) · → tip Windows → dual L4 → explicit auth ship delete

> **Authority (G.7):** this document is the **human map** for residual Makefile
> **leaf `.o` pattern / host-cc compile** rules that still block physical delete
> of `compiler/Makefile` (11.3.1). Machine check:
> `compiler/scripts/leaf_pattern_residual.sh --check` ·
> `./xbuild leaf-patterns --check`.  
> **Status map:** `analysis/C迁移追踪.md` §11.3 / §11.3.1 (status only).  
> **Wave rows:** `analysis/自举进度.md` only.  
> **PLATFORM: SHARED** — residual classes are portable; ABI / UNAME recipe bodies
> stay in Makefile / mk until each class is swallowed by a named shell body.

## Non-negotiables (G.7 + G.8)

| Rule | Meaning |
|------|---------|
| **Lists stay mk** | Object lists / Darwin filtered `.o` / composite sets remain `compiler/mk/*.mk` + catalog. **Do not** re-list `.o` in this doc or in residual shells as a second authority. |
| **Orchestration already shell** | Cold step *sequence* and *export→rebuild* leaves are shell (waves 717–744). Residual here is **how individual `.o` files are still produced** (pattern / recipe in Makefile). |
| **No dual compile path** | Inventory **names** residual classes and existing shell owners. Do not open a second `cc -c` driver that copies Makefile recipes. **One body per family** once swallowed. |
| **Physical delete later** | 11.3.1 endgame deletes Makefile only after BC residual classes are 0 or owned by shell without make graph. This wave is inventory + path only. |
| **G.8 tags** | Platform branches in leaf recipes keep `PLATFORM: LINUX\|MACOS\|WINDOWS\|POSIX\|SHARED`. |

## What is already shell (not residual)

| Class | Owner shell | Notes |
|-------|-------------|-------|
| Cold step sequence | `bootstrap_driver_seed.sh` | Ordered §5b |
| Prereq **edges** | `driver_seed_ensure_prereqs.sh` | wave744; list = catalog |
| Rebuild leaf **orchestration + mode policy** | `bootstrap_driver_seed_rebuild_leaves.sh` | **wave747**: mode table + catalog KEY in shell |
| Rebuild leaf **pure-R1 bodies** | `ensure_host_cc_seed_o.sh try-r1` via rebuild_leaves | **wave756**: pure R1 leave make |
| Rebuild leaf **R3 cold-else bodies** | `ensure_host_cc_seed_o.sh try-r3-cold` via rebuild_leaves | **wave757**: cold pure host-cc leave make |
| **R3 PREFER thin+rest (R3_COLD nine)** | `ensure_host_cc_seed_o.sh try-r3-prefer` | **wave763**: Makefile thin-call · **wave764**: g05 `r3-prefer-family` (full→thin ladder) |
| **labi multi-slice PREFER** | `ensure_host_cc_seed_o.sh try-labi-prefer` | **wave765**: g05 + Makefile thin-call (L0..L9+L8b+L8c + rest) |
| **rt multi-slice PREFER** | `ensure_host_cc_seed_o.sh try-rt-prefer` | **wave766**: g05 + Makefile thin-call (`runtime_driver_no_c`; RT_SEED_SLICE external) |
| **pipeline_abi PREFER** | `ensure_host_cc_seed_o.sh try-pipeline-abi-prefer` | **wave767**: g05 + Makefile thin-call (`runtime_pipeline_abi`) |
| **ldpc PREFER** | `ensure_host_cc_seed_o.sh try-ldpc-prefer` | **wave767**: g05 + Makefile thin-call (`lsp_diag_pipeline_ctx`) |
| **target_cpu PREFER** | `ensure_host_cc_seed_o.sh try-target-cpu-prefer` | **wave768**: g05 + Makefile thin-call (`target_cpu`) |
| **L2 asm three PREFER** | `ensure_host_cc_seed_o.sh try-l2-asm-prefer` | **wave769**: g05 + Makefile thin-call (uasb/bxec/abcs) |
| **async three PREFER** | `ensure_host_cc_seed_o.sh try-async-prefer` | **wave770**: g05 + Makefile thin-call (liveness/cps/asm_pool) |
| **other L2 four PREFER** | `ensure_host_cc_seed_o.sh try-other-l2-prefer` | **wave771**: g05 + Makefile thin-call (slc/strict_glue/fmt_driver/lsp_diag) |
| **R2 panic PREFER** | `ensure_host_cc_seed_o.sh try-r2-prefer` | **wave776**: Makefile thin-call (runtime_panic; cold try-r2 twin) |
| **fmt_check_cmd.o dual (non-driver)** | `ensure_host_cc_seed_o.sh try-other-l2-prefer` | **wave775**: Makefile thin-call; `leaf_kind=fmt_core` (no `USE_X_PIPELINE`) |
| Phase1/final **link driver** | `bootstrap_driver_seed_link.sh` | **wave772 pure-ld** + **wave774 no silent fallback** (`SEED_LINK_LD`… via `pure_ld_shared`); named `SEED_LINK_CC` only FORCE_CC / PURE_OK=0 |
| g05 ensure / prepare / relink | `g05_*.sh` | **wave764**–**wave771** R3_COLD / labi / rt / pipeline_abi / ldpc / target_cpu / L2-asm / async / other-L2 via ensure try-*-prefer; **wave773** g05 final pure-ld (`pure_ld_shared`); **wave774** no silent CC fallback · **wave775** fmt dual · residual physical delete |
| migrate / `*_gen` ensure | `migrate_x_objs.sh` · `ensure_*_gen.sh` | wave735–740 |
| Host facts / linker policy map | `host_platform_linker.sh` | wave745 |
| **R1 pure host-cc body · eight families** | `ensure_host_cc_seed_o.sh` | **wave748**–**wave755**; residual non-catalog |
| **R3 cold-else pure host-cc** | `ensure_host_cc_seed_o.sh` try-r3-cold / r3-cold-seed | **wave757** catalog `R3_COLD_SEED_OBJS` |
| **R4 residual thin_glue pure host-cc** | `ensure_host_cc_seed_o.sh` seed-map / try-r1 | **wave758**: `parser_asm_thin_glue` → R1 seed-map (G.7 有则补全) |
| **R4 residual glue standalone pure host-cc** | `ensure_host_cc_seed_o.sh` seed-map / try-r1 | **wave759**: `pipeline_glue_standalone` → R1 seed-map (G.7 有则补全; was `cc_inc_tu`) |
| **R2 panic cold (UNAME stamp leaf)** | `ensure_host_cc_seed_o.sh` try-r2 / r2-panic | **wave760**: `runtime_panic.o` cold via catalog `DRIVER_SEED_PANIC_OBJS`; PREFER thin residual |
| **R2 typeck_f64 + crt0 (UNAME leaf)** | `ensure_host_cc_seed_o.sh` try-r2 / r2-typeck-f64 / r2-crt0 | **wave762**: catalog `DRIVER_SEED_TYPECK_F64_OBJS` + `DRIVER_SEED_CRT0_OBJS`; host pick `.s` / mingw seed |

## Named residual classes (Makefile still owns body)

| ID | Residual class | Typical Makefile surface | Endgame owner | Status |
|----|----------------|--------------------------|---------------|--------|
| **R1** | Host-cc seed/from_x → `.o` | `$(CC) … -c seeds/*.from_x.c -o …` recipes | shell ensure or product `-E`+cc body (stages 8–9); **one** body, multi family lists | **rt-slice ✅ wave748** · … · **seed-map ✅ wave755** (+ **thin_glue wave758** + **glue standalone wave759**); residual non-catalog |
| **R2** | Platform stamp / UNAME leaf | `runtime_panic.$(UNAME_S).$(UNAME_M).stamp` · `typeck_f64_bits` arch `.s` pick · crt0 | shell + host_platform_linker facts; lists stay mk | **panic cold ✅ wave760** · **typeck_f64/crt0 ✅ wave762** (try-r2) · **panic PREFER ✅ wave776** (try-r2-prefer) |
| **R3** | Thin+rest / PREFER_X_O host-cc rest | thin `.o` + `FROM_X=1` rest `cc -c` + `ld -r` | cold-else shell ensure; PREFER thin product path | **cold-else ✅ wave757** · **Makefile PREFER ✅ wave763** · **g05 R3_COLD ✅ wave764** · **labi multi-slice ✅ wave765** · **rt multi-slice ✅ wave766** · **pipeline_abi/ldpc ✅ wave767** · **target_cpu ✅ wave768**; residual other L2 |
| **R4** | Cold rebuild **pattern bodies** | sat/lsp/bridge/panic/user-asm/glue/pipeline-x | rebuild without make pattern graph | **mode+list shell wave747** · **pure-R1 wave756** · **R3 cold wave757** · **thin_glue seed-map wave758** · **glue standalone seed-map wave759** · **panic cold try-r2 wave760** · **gen try-gen-x wave761** · **typeck_f64/crt0 try-r2 wave762**; residual PREFER thin / sat non-R1 if any |
| **R5** | CI / `compiler-all` host-cc graph | Makefile `all` · OPT seed path | `scripts/compiler_all_ci.sh` (wave784); stage 12 = zero host-cc | **body ✅ wave784** · **B7D TARGET→g05 ✅ wave786** · **B7A cold residual_make=0 ✅ wave787** · **B7B shell catalog ✅ wave788** · **B7A heat try-heat ✅ wave789** · **B7A heat thin-unify ✅ wave790** · **B7A heat dep-thin pure seed+.x(+.h) 78 FORCE ✅ wave791–793** · residual twin/c multi/asm/gen dep / physical delete |
| **R6** | Cold **link** pure-ld + g05 pure-ld | `run_pure_ld_required` + `run_g05_pure_ld_required`; named CC residual FORCE_CC/ineligible only | 11.1.4 · **wave772** cold · **wave773** g05 · **wave774** drop silent fallback; residual physical delete · fmt dual | ~~silent CC after pure fail~~ · ~~residual CC primary~~ · ~~g05 CC-only~~ |

**R1–R5** are the 11.3.1 **leaf pattern** residual. **R6** is tracked under 11.1.4 (wave745).

### wave747 · R4 mode-policy swallow (not pattern endgame)

```text
Before (wave722–746):
  rebuild_leaves MODE
    → make export-*-leaf  → SEED_REBUILD_OBJS / ARGS / VARS
    → make $OBJS $VARS     (pattern bodies)

After (wave747 default):
  rebuild_leaves MODE
    → shell mode table (ARGS/VARS + catalog KEY)
    → driver_seed_obj_catalog.sh  (lists = mk only)
    → make $OBJS $VARS     (pattern bodies STILL residual)

Escape: XLANG_REBUILD_LEAVES_VIA_EXPORT=1 restores export-* leaf path.
```

| Swallowed | Still residual |
|-----------|----------------|
| Dual path of 7 export leaves vs catalog for the same lists | Non-R1 host-cc / UNAME / thin-rest **pattern recipes** (after wave756 pure-R1 split) |
| Mode policy (which KEY, `-B`, `PIPELINE_X_FORCE_COMPILE=1`, …) | Actual residual `$(CC) -c` / stamp / gen bodies in Makefile |

Makefile `bootstrap-driver-seed-export-*` rebuild targets remain as **inventory mirrors** (optional); cold rebuild default no longer depends on them.

### wave756 · R4 pure-R1 body swallow (not full pattern endgame)

```text
Before (wave747–755):
  rebuild_leaves MODE
    → shell mode table + catalog KEY
    → make $ALL_OBJS $VARS     (every leaf still make pattern)

After (wave756 default):
  rebuild_leaves MODE
    → shell mode table + catalog KEY
    → for each o in SEED_REBUILD_OBJS:
         ensure try-r1 o     # exit 0 if pure R1 catalog member
         else residual list
    → if residual: make $residual $VARS
      else: no make (bridge = pure-R1 only)

try-r1 (ensure_host_cc_seed_o.sh):
  membership = catalog KEY union of eight R1 families (lists = mk)
  seed/extras = existing family maps (same ensure_one body)
  exit 3 → not pure R1 (caller residual / wave757 try-r3-cold)
```

| Swallowed | Still residual |
|-----------|----------------|
| Pure R1 rebuild bodies in every mode (bridge full; sat/lsp/user-asm partial) | ~~R2 typeck_f64/crt0~~ (wave762) · R3 PREFER thin · ~~gen/pipeline_x~~ (wave761) · pure-ld |
| Dual path of make-for-pure-R1 vs thin ensure | Full R4 endgame · pure-ld · physical delete |

**Forbidden:** hardcoding product `.o` paths inside `rebuild_leaves` / `try-r1` as a second inventory (membership via catalog KEY only).

### wave757 · R3 cold-else body swallow (not PREFER thin endgame)

```text
After (wave757 default):
  rebuild_leaves MODE
    → for each o:
         try-r1 o           # pure R1 (wave756)
         else try-r3-cold o # R3_COLD_SEED_OBJS cold pure host-cc
         else residual make
    → sat: pure_r1 + r3_cold only (no make when residual empty)
      user-asm (pre-wave758): dispatch cold shell; parser_asm_thin_glue residual make

try-r3-cold (ensure_host_cc_seed_o.sh):
  membership = catalog R3_COLD_SEED_OBJS (lists = mk)
  seed = basename seeds/<leaf>.from_x.c (same ensure_one as R1)
  exit 3 → not R3 cold member

Makefile thin+rest recipes:
  PREFER_X_O=1 / xlang-c thin path unchanged
  cold-else branch thin-calls ensure one (G.7 single body)

R3_COLD_SEED_OBJS (9):
  runtime_io_abi · runtime_driver_abi · runtime_driver_diagnostic
  simd_enc · simd_loop
  backend_enc_dispatch · backend_arch_emit_dispatch
  backend_try_inline_dispatch · backend_call_dispatch
```

| Swallowed | Still residual |
|-----------|----------------|
| Cold pure host-cc for thin+rest leaves (rebuild + Makefile cold-else) | ~~PREFER Makefile thin for nine~~ (wave763) · ~~panic UNAME cold~~ (wave760) · ~~gen `*_x`/pipeline_x~~ (wave761) · ~~hybrid thin_glue~~ (wave758) · ~~glue standalone~~ (wave759) |
| Dual cold `$(CC) -c seed` vs ensure for the nine objs | g05 other PREFER hybrid · pure-ld · physical delete |

**Forbidden:** hardcoding the nine `.o` paths in shell as list authority (catalog KEY only); dual PREFER body outside try-r3-prefer.

### wave763 · R3 PREFER thin+rest for R3_COLD nine (try-r3-prefer · G.7 有则补全)

```text
Before (wave757–762):
  Makefile phase4 recipes for R3_COLD_SEED_OBJS:
    if PREFER_X_O=1 && xlang-c: thin.x -E → thin.o + seed rest -D → ld -r
    else: ensure one (cold)
  backend_* historically always-tried thin when xlang-c existed (no PREFER gate)

After (wave763):
  ensure try-r3-prefer OUT
    membership = catalog R3_COLD_SEED_OBJS (lists = mk; same KEY as cold)
    leaf map: x_src | rest -D list | optional nm symbol (not .o inventory)
    PREFER=1 + xlang-c → thin+rest+ld -r; nm gate (simd_enc/loop)
    else / fail → ensure_one cold (FORCE if prefer wrote bad OUT)
  Makefile nine leaves: thin-call try-r3-prefer only
  PREFER gate unified for all nine (cold-chain Darwin safety)
```

| Swallowed | Still residual |
|-----------|----------------|
| Makefile PREFER thin+rest body for R3_COLD nine | ~~g05 R3_COLD dual hybrid~~ (wave764) · ~~labi/rt multi-slice~~ (wave765/766) · pure-ld · physical delete |
| Dual inline phase4 thin recipes vs ensure cold | panic PREFER (if any) · R5 CI · fmt_check / async PREFER leaves outside R3_COLD |

**Forbidden:** second `.o` list; re-open inline `ld -r` thin+rest in Makefile for these nine; invent second prefer helper name.

### wave764 · g05 R3_COLD product PREFER → r3-prefer-family (G.7 有则补全)

```text
Before (wave763):
  Makefile R3_COLD nine → try-r3-prefer
  g05_ensure still had dual inline hybrid for same nine
    (rio/rdabi/rdd + simd full→thin + backend full→thin)

After (wave764):
  ensure try-r3-prefer leaf map gains optional full.x first ladder
    (simd/backend: full rest -D then thin rest -D then cold)
  g05_ensure thin-calls r3-prefer-family (catalog R3_COLD only)
  dual g05 hybrid bodies for R3_COLD nine deleted
```

| Swallowed | Still residual |
|-----------|----------------|
| g05 dual hybrid for R3_COLD nine (product daily path) | ~~labi multi-slice~~ (wave765) · ~~rt multi-slice~~ (wave766) · pipeline_abi · ldpc · target_cpu · pure-ld · physical delete |
| Second prefer body for rio/rdabi/rdd/simd/backend | panic PREFER (if any) · R5 CI · other L2 hybrid leaves |

**Forbidden:** re-open g05 inline hybrid for R3_COLD members; second `.o` list in g05; fork try-r3-prefer under a second name.


### wave765 · g05 labi multi-slice product PREFER → try-labi-prefer (G.7 有则补全)

```text
Before (wave764):
  g05_ensure inline L0..L9+L8b+L8c hybrid for runtime_link_abi.o
  Makefile thin-call ensure one (cold full seed only)

After (wave765):
  ensure try-labi-prefer owns multi-slice PREFER body
    (prefer .x per layer / seed fallback → rest FROM_X → $CC -r -nostdlib)
  g05_ensure + Makefile thin-call try-labi-prefer
  dual g05 labi hybrid body deleted
```

| Swallowed | Still residual |
|-----------|----------------|
| g05 labi multi-slice hybrid (product daily path) | ~~rt multi-slice~~ (wave766) · pipeline_abi · ldpc · target_cpu · pure-ld · physical delete |
| Second prefer body for runtime_link_abi.o | panic PREFER (if any) · R5 CI · other L2 hybrid leaves |

**Forbidden:** re-open g05 inline labi L0..L9 hybrid; second multi-slice body under a second name; hardcode a second product `.o` list for labi layers.

### wave766 · g05 rt multi-slice product PREFER → try-rt-prefer (G.7 有则补全)

```text
Before (wave765):
  g05_ensure inline content..dispatch multi-slice hybrid for runtime_driver_no_c.o
  Makefile thin-call ensure one (cold full seed + NO_C only)

After (wave766):
  ensure try-rt-prefer owns multi-slice PREFER body
    (prefer .x per layer / seed fallback → rest FROM_X + NO_C → $CC -r -nostdlib;
     RT_SEED_SLICE permanent .o stay external — Darwin multidef fix)
  g05_ensure + Makefile thin-call try-rt-prefer
  dual g05 rt hybrid body deleted
```

| Swallowed | Still residual |
|-----------|----------------|
| g05 rt multi-slice hybrid (product daily path) | ~~pipeline_abi/ldpc~~ (wave767) · target_cpu · pure-ld · physical delete |
| Second prefer body for runtime_driver_no_c.o | panic PREFER (if any) · R5 CI · other L2 hybrid leaves |

**Forbidden:** re-open g05 inline rt multi-slice hybrid; second multi-slice body under a second name; merge RT_SEED_SLICE permanent .o into no_c.

### wave767 · g05 pipeline_abi + ldpc product PREFER → try-*-prefer (G.7 有则补全)

```text
Before (wave766):
  g05_ensure inline full.x WEAK + rest FROM_X hybrid for runtime_pipeline_abi.o
  g05_ensure inline thin.x WEAK + rest L2_LSP_CTX hybrid for lsp_diag_pipeline_ctx.o
  Makefile thin-call ensure one (cold seed only)

After (wave767):
  ensure try-pipeline-abi-prefer owns pipeline_abi PREFER body
    (G05_X_O_WEAK=1 full .x via rt_prefer_try_x_to_o harness + rest FROM_X → $CC -r;
     cold ensure_one + USE_X_PIPELINE)
  ensure try-ldpc-prefer owns ldpc PREFER body
    (G05_X_O_WEAK=1 thin .x + rest L2_LSP_CTX → $CC -r; cold ensure_one)
  g05_ensure + Makefile thin-call both helpers
  dual g05 pipeline_abi / ldpc hybrid bodies deleted
```

| Swallowed | Still residual |
|-----------|----------------|
| g05 pipeline_abi PREFER hybrid (product daily path) | ~~target_cpu~~ (wave768) · other L2 hybrid · pure-ld · physical delete |
| g05 ldpc PREFER hybrid (product daily path) | panic PREFER (if any) · R5 CI |
| Second prefer body for runtime_pipeline_abi.o / lsp_diag_pipeline_ctx.o | |

**Forbidden:** re-open g05 inline pipeline_abi/ldpc hybrid; second prefer body under a second name; duplicate -E prologue (reuse rt_prefer_try_x_to_o).

### wave768 · g05 target_cpu product PREFER → try-target-cpu-prefer (G.7 有则补全)

```text
Before (wave767):
  g05_ensure inline flags.x + rest pure FROM_X hybrid for target_cpu.o
  Makefile thin-call ensure one (cold pure seed only)

After (wave768):
  ensure try-target-cpu-prefer owns target_cpu PREFER body
    (flags.x via rt_prefer_try_x_to_o + rest -DXLANG_L2_TARGET_CPU_FLAGS_FROM_X
     → $CC -r; cold ensure_one pure seed)
  g05_ensure + Makefile thin-call try-target-cpu-prefer
  dual g05 target_cpu hybrid body deleted
```

| Swallowed | Still residual |
|-----------|----------------|
| g05 target_cpu PREFER hybrid (product daily path) | ~~L2 asm / async / other L2~~ (wave769–771) · pure-ld · physical delete |
| Second prefer body for target_cpu.o | panic PREFER (if any) · R5 CI |

**Forbidden:** re-open g05 inline target_cpu flags hybrid; second prefer body under a second name; duplicate -E prologue (reuse rt_prefer_try_x_to_o).

### wave769 · g05 L2 asm three PREFER → try-l2-asm-prefer (G.7 有则补全)

Table body for `user_asm_seed_bridge` / `backend_x86_64_enc_c` / `asm_backend_compat_stubs`. g05 + Makefile thin-call. Residual after: ~~async~~ wave770 · ~~other L2~~ wave771.

### wave770 · g05 async three PREFER → try-async-prefer (G.7 有则补全)

Table body for `async_liveness` / `async_cps_codegen` / `async_asm_pool` (full .x + rest FROM_X). g05 + Makefile thin-call. Residual after: ~~other L2~~ wave771.

### wave771 · g05 other L2 four PREFER → try-other-l2-prefer (G.7 有则补全)

```text
Before (wave770):
  g05_ensure inline dual hybrid for:
    seed_link_compat (named-weak 6 stubs + special -E prologue)
    runtime_driver_strict_glue_stubs (WEAK thin + heap stale)
    fmt_check_cmd_driver (WEAK thin + USE_X_PIPELINE rest/cold)
    lsp_diag (WEAK thin runtime_lsp_glue.x + FULL_FROM_X rest)
  Makefile: ensure one cold (slc/strict/lsp) · dual hybrid (fmt driver)

After (wave771):
  ensure try-other-l2-prefer owns four PREFER bodies (table-driven)
    reuses rt_prefer_try_x_to_o; G05_X_O_WEAK_FUNCS for slc6
  g05_ensure + Makefile thin-call try-other-l2-prefer
  dual g05 four hybrid bodies deleted
```

| Swallowed | Still residual |
|-----------|----------------|
| g05 other L2 four PREFER hybrids (product daily path) | ~~pure-ld cold~~ (wave772) · ~~g05 pure-ld~~ (wave773) · ~~silent CC fallback~~ (wave774) · ~~`fmt_check_cmd.o` dual~~ (wave775) · physical delete |
| Second prefer body for the four leaves | panic PREFER (if any) · R5 CI |

**Forbidden:** re-open g05 inline slc/strict/fmt/lsp hybrid; second prefer body under a second name; dual -E prologue (reuse rt_prefer + WEAK_FUNCS).

### wave772 · 11.1.4 pure-ld cold phase1/final (G.7 有则补全)

```text
Before (wave771):
  bootstrap_driver_seed_link.sh:
    make export → SEED_LINK_CC + CFLAGS + OBJS → "$CC" … -o OUT
  residual named as R6 cold CC primary

After (wave772):
  Makefile export + SEED_LINK_LD / MULTIDEF / ENTRY / LD_TAIL / PURE_OK
  link body prefers pure-ld when PURE_OK=1 (Darwin syslibroot/arch in script)
  fallback SEED_LINK_CC residual (FORCE_CC / pure fail / PURE_OK=0)
  --self-test pure-ld smoke (tiny objs; no product list)
```

| Swallowed | Still residual |
|-----------|----------------|
| Cold phase1/final pure-ld + pure export keys | ~~g05 `CC -o` primary~~ (wave773) · ~~silent CC fallback~~ (wave774) · physical delete · `fmt_check_cmd.o` dual |
| R6 primary = pure-ld | Windows PE pure-ld; make export leaf itself |

**Forbidden:** second cold link body; hardcode `.o` list in shell; dual pure-ld argv tables outside Makefile export + platform prefix helper.

### wave773 · 11.1.4 g05 pure-ld prefer (G.7 有则补全 `pure_ld_shared`)

```text
Before (wave772):
  g05_relink_xlang.sh: $CC $CFLAGS -o OUT $OBJS only
  pure-ld platform helpers only inside bootstrap_driver_seed_link.sh

After (wave773):
  pure_ld_shared.sh — single pure-ld platform/entry/tail/try authority
  cold seed_link sources pure_ld_shared (no second platform table)
  g05_relink_xlang pure-ld via pure_ld_try_link
    freestanding host: pure-ld
    Linux nostdlib: -static --gc-sections (no -lc)
    else: -lSystem / -lc
  residual (pre-774): $CC $CFLAGS -o (FORCE_CC / pure fail / ineligible)
```

| Swallowed | Still residual |
|-----------|----------------|
| g05 product final pure-ld + shared pure_ld helpers | ~~silent CC fallback~~ (wave774) · physical delete · `fmt_check_cmd.o` dual |
| Dual pure-ld platform tables (cold vs g05) | Windows PE pure-ld |

**Forbidden:** second pure-ld platform table in g05; hardcode `.o` list in pure_ld_shared.

### wave774 · 11.1.4 drop silent CC residual fallback (G.7 有则补全)

```text
Before (wave773):
  pure-ld fail → silent fallthrough to $CC … -o (cold + g05)
  FORCE_CC / ineligible also → CC residual

After (wave774):
  pure-ld eligible + not FORCE_CC → pure-ld required (hard fail on miss)
  FORCE_CC=1 or pure-ld ineligible → named CC residual only
  Escape: XLANG_SEED_LINK_FORCE_CC=1 / XLANG_G05_FORCE_CC=1
  cold: run_pure_ld_required / run_cc_residual
  g05:  run_g05_pure_ld_required / run_g05_cc_residual
```

| Swallowed | Still residual |
|-----------|----------------|
| Silent CC after pure-ld fail (cold + g05) | Named CC residual FORCE_CC / ineligible · physical delete · ~~`fmt_check_cmd.o` dual~~ (wave775) |
| “prefer + silent fallback” dual success path | Windows PE pure-ld · make export leaf itself |

**Forbidden:** re-introduce silent CC after pure fail; drop FORCE_CC escape without map; second pure-ld platform table.

### wave775 · fmt_check_cmd.o Makefile dual → try-other-l2-prefer (G.7 有则补全)

```text
Before (wave774):
  Makefile src/driver/fmt_check_cmd.o: full dual hybrid body
    (xlang-c -E thin.x + prologue + seed-rest ld -r) else cold seed
  ensure try-other-l2-prefer only knew fmt_check_cmd_driver.o (leaf_kind=fmt)

After (wave775):
  other_l2_prefer_spec_for_out += fmt_check_cmd.o
    leaf_kind=fmt_core — same thin.x + seed; NO -DXLANG_USE_X_PIPELINE
  Makefile thin-call try-other-l2-prefer (same as driver leaf)
  Dual hybrid recipe deleted
```

| Swallowed | Still residual |
|-----------|----------------|
| `fmt_check_cmd.o` Makefile dual hybrid (OBJS_CORE / PIPELINE_X satellite) | physical delete · ~~panic PREFER~~ (wave776) |
| Second -E prologue for non-driver fmt leaf | Windows PE pure-ld · FORCE_CC named residual |

**Forbidden:** re-open Makefile dual hybrid for `fmt_check_cmd.o`; merge `fmt`/`fmt_core` flags (driver needs USE_X_PIPELINE); second prefer body name.

### wave758 · R4 residual thin_glue → R1 seed-map (G.7 有则补全)

```text
Before (wave757):
  user-asm residual make: parser_asm_thin_glue.o (pure host-cc monothin;
    basename mismatch + monothin -D/-I + many seeds/parser_asm/*.inc prereqs)

After (wave758):
  R1_SEED_MAP_OBJS += parser_asm_thin_glue.o
  seed map: parser_asm_thin_glue.o ← seeds/parser_asm_thin_c.from_x.c
  extras: -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE -Isrc/lexer -Isrc/asm -Iseeds/parser_asm
  ensure_one also refreshes when any seeds/parser_asm/*.inc is newer than .o
  rebuild_leaves try-r1 → pure_r1 (user-asm residual_make=0)
  Makefile leaf thin-calls ensure one (no inline $(CC) -c)
```

| Swallowed | Still residual |
|-----------|----------------|
| `parser_asm_thin_glue.o` pure host-cc monothin body (rebuild + Makefile thin) | ~~panic UNAME~~ · ~~gen/pipeline~~ · ~~glue standalone~~ · pure-ld · physical delete |
| Dual inline `$(CC) -c thin_c.from_x` vs ensure for this leaf | R3 PREFER thin product path · R5 CI |

**Forbidden:** second `.o` list in shell; drop `.inc` freshness (stale monothin → Ubuntu UNDEF history).

### wave759 · R4 residual glue standalone → R1 seed-map (G.7 有则补全)

```text
Before (wave758):
  glue residual make: build_asm/pipeline_glue_standalone.o
    (Makefile/g05 via cc_inc_tu wrap of seeds/pipeline_glue_standalone.from_x.c
     + -Wno-error=return-type -Ibuild_asm; prereqs pipeline_glue.c / ast_pool /
     pipeline_glue_types.inc)

After (wave759):
  R1_SEED_MAP_OBJS += build_asm/pipeline_glue_standalone.o
  seed map: build_asm/pipeline_glue_standalone.o ← seeds/pipeline_glue_standalone.from_x.c
  extras: -Wno-error=return-type -Ibuild_asm
  ensure_one body = direct cc -c (seed accepts cc -c; same TU as former wrap)
  ensure_one refreshes when pipeline_glue.c / ast_pool.c / types.inc newer
  rebuild_leaves try-r1 → pure_r1 (glue residual_make=0)
  Makefile leaf thin-calls ensure one (no cc_inc_tu residual body)
```

| Swallowed | Still residual |
|-----------|----------------|
| `build_asm/pipeline_glue_standalone.o` pure host-cc body (rebuild + Makefile thin) | ~~panic UNAME cold~~ · ~~gen/pipeline~~ (wave761) · pure-ld · physical delete |
| Dual `cc_inc_tu` vs ensure for this leaf | R3 PREFER thin product path · R5 CI |

**Forbidden:** second `.o` list in shell; drop glue/ast_pool/types.inc freshness (stale standalone → dual-def / missing symbols).

### wave760 · R2 panic cold body (try-r2 · not PREFER endgame)

```text
Before (wave759):
  panic residual make: runtime_panic.o
    (Makefile ifeq UNAME: Linux x86_64 .s | arm64 seed | from_x seed +
     platform stamp; PREFER thin+rest still inline)

After (wave760):
  rebuild_leaves: try-r1 → try-r3-cold → try-r2 → residual make
  try-r2 membership = catalog DRIVER_SEED_PANIC_OBJS (lists = mk)
  cold body:
    stamp build_asm/runtime_panic.$(uname -s).$(uname -m).stamp
    PLATFORM LINUX|x86_64 + .s → cc -c runtime_panic_x86_64.s
    arm64|aarch64 → seeds/runtime_panic_arm64.from_x.c (ensure_one)
    else → seeds/runtime_panic.from_x.c (ensure_one)
  Makefile cold-else thin-calls ensure try-r2; PREFER thin residual
  build_xlang_asm ensure_asm_link_objs → same try-r2 (G.7 single cold body)
  panic mode residual_make=0 (shell only: r2=1)
```

| Swallowed | Still residual |
|-----------|----------------|
| `runtime_panic.o` cold platform-stamp body (rebuild + Makefile cold-else + build_xlang_asm) | PREFER thin panic · ~~typeck_f64/crt0~~ (wave762) · ~~gen `*_x` / pipeline_x~~ (wave761) · pure-ld · physical delete |
| Dual inline cold `cc -c` panic vs ensure | R3 PREFER product path · R5 CI |

**Forbidden:** second `.o` list in shell; invent second platform table outside try-r2 host pick + host_platform_linker facts; drop stamp on platform switch.

### wave761 · R4 residual gen `*_x` + pipeline_x → try-gen-x (G.7 有则补全)

| 项 | 说明 |
|----|------|
| 触发 | lsp residual_make=3（`lsp_io_x`/`lsp_x`/`lsp_diag_x`）· pipeline-x residual_make=1 |
| 权威 | catalog **`DRIVER_SEED_LSP_X_OBJS`** / **`DRIVER_SEED_PIPELINE_X_OBJS`** 成员 + gen map；体 = **`scripts/ensure_gen_x_o.sh`**；入口 `ensure try-gen-x` |
| 链 | rebuild_leaves try-r1 → try-r3-cold → try-r2 → **try-gen-x** → residual make |
| Makefile | 四叶 thin 转调 `ensure_gen_x_o.sh one`（pipeline 传 `PIPELINE_X_DEPS` / FORCE） |
| 闸门 | leaf `--check` · host-cc-seed `--check` · lsp/pipeline-x residual_make=0 |
| 非本波 | ~~R2 typeck_f64/crt0~~ (wave762) · R3 PREFER thin · pure-ld · 物理删 |

### wave762 · R2 typeck_f64 + crt0 (try-r2 extend · G.7 有则补全)

```text
Before (wave760–761):
  typeck_f64_bits.o / crt0_*.o  — Makefile UNAME ifeq + inline $(CC) -c .s
  g05_ensure / build_xlang_asm  — second/third host-pick recipes (dual body)

After (wave762):
  catalog DRIVER_SEED_TYPECK_F64_OBJS + DRIVER_SEED_CRT0_OBJS (lists = mk)
  try-r2 OUT  → membership panic | typeck_f64 | crt0
  typeck_f64  → host pick platform .s (Linux/Darwin/Windows mingw)
  crt0        → fixed o→.s map; crt0_mingw → cc_inc_tu + WIN32_O_CFLAGS
  Makefile    → thin-call ensure try-r2 (UNAME ifeq only gates which target exists)
  g05 / build_xlang_asm → try-r2 (no inline dual recipe)
```

| Swallowed | Still residual |
|-----------|----------------|
| `src/typeck/typeck_f64_bits.o` host-pick body | PREFER thin panic · bootstrap_nostdlib_stubs (cc_inc_tu) · crt0_user.o `cp` wrappers |
| `src/asm/crt0_{x86_64,arm64,darwin_x86_64,mingw,user_x86_64}.o` · `freestanding_io_x86_64.o` | R3 PREFER thin product path · pure-ld · physical delete |

| 本波 | 非本波 |
|------|--------|
| R2 typeck_f64/crt0 shell body + catalog + Makefile thin + g05/build_xlang_asm converge | R3 PREFER thin · pure-ld · 物理删 · panic PREFER thin |

| LEAF | `SWALLOWED_R4_BODY_GEN_X=1` · `R4_BODY_GEN_X_SWALLOWED=1` |

| 已吞 | 仍 residual |
|------|-------------|
| lsp trio gen→.o + `pipeline_x.o`（rebuild + Makefile thin） | PREFER thin · typeck_f64/crt0 · pure-ld · physical delete · sat 等 non-R1 pattern 若仍 make |


### wave748 · R1 first family: RT_SEED_SLICE

```text
Family: RT_SEED_SLICE_OBJS (Makefile list authority)
  src/runtime/rt_arena_buf.o
  src/runtime/rt_emit_state.o
  src/runtime/rt_preamble.o
  src/runtime/rt_stack.o
  src/runtime/rt_parse_diag.o

Body (G.7 single):
  scripts/ensure_host_cc_seed_o.sh one OUT seeds/<leaf>.from_x.c
  scripts/ensure_host_cc_seed_o.sh rt-slice   # catalog list + seed convention

Makefile: thin leaves call the script (no inline $(CC) -c for these five).
Catalog: RT_SEED_SLICE_OBJS exported via bootstrap-driver-seed-export-obj-catalog.
```

| Swallowed | Still residual |
|-----------|----------------|
| Pure host-cc recipe body for the five Cap residual slices | All other R1 `$(CC) -c seeds/*.from_x.c` leaves (diag, bridge, …) |
| Dual list for this family (script uses catalog only) | R3 thin+rest / g05 PREFER_X_O path for same seeds (product path) |

**Forbidden:** re-listing the five `.o` paths inside `ensure_host_cc_seed_o.sh` as a second inventory.

### wave749 · R1 second family: CORE_SEED

```text
Family: R1_CORE_SEED_OBJS (Makefile list authority)
  src/diag.o
  src/runtime_link_abi.o
  src/runtime_c_import.o
  src/x_seed_bridge.o
  src/seed_link_compat.o

Body (G.7 same as rt-slice):
  scripts/ensure_host_cc_seed_o.sh one OUT seeds/<leaf>.from_x.c
  scripts/ensure_host_cc_seed_o.sh core-seed   # catalog list + basename convention
  scripts/ensure_host_cc_seed_o.sh all         # rt-slice + core-seed

Makefile: thin leaves call the script (no inline $(CC) -c for these five).
Catalog: R1_CORE_SEED_OBJS exported via bootstrap-driver-seed-export-obj-catalog.
```

| Swallowed | Still residual |
|-----------|----------------|
| Pure host-cc for diag / link_abi / c_import / bridge / seed_link_compat | Other R1 (extra cflags, main/runtime variants, …) |
| Dual list for this family (script uses catalog only) | R3 thin+rest / R4 pattern body / pure-ld |

**Forbidden:** re-listing core-seed `.o` paths inside `ensure_host_cc_seed_o.sh` as a second inventory.

### wave750 · R1 third family: FRONTEND_GLUE (basename mismatch)

```text
Family: R1_FRONTEND_GLUE_OBJS (Makefile list authority)
  src/lexer/lexer.o   ← seeds/runtime_lexer_glue.from_x.c
  src/ast/ast.o       ← seeds/runtime_ast_glue.from_x.c
  src/lsp/lsp_diag.o  ← seeds/runtime_lsp_glue.from_x.c

Body (G.7 same ensure_host_cc_seed_o.sh):
  scripts/ensure_host_cc_seed_o.sh one OUT SEED   # Makefile thin passes seed path
  scripts/ensure_host_cc_seed_o.sh frontend-glue  # catalog list + o→seed map
  scripts/ensure_host_cc_seed_o.sh all            # rt-slice + core-seed + frontend-glue

Seed map = path *convention* only (not a second .o inventory).
Unknown catalog members fail closed.
Makefile: thin leaves call the script (no inline $(CC) -c for these three).
Catalog: R1_FRONTEND_GLUE_OBJS exported via bootstrap-driver-seed-export-obj-catalog.
```

| Swallowed | Still residual |
|-----------|----------------|
| Pure host-cc for lexer/ast/lsp glue with basename-mismatch seeds | Other R1 (extra-cflags pure basename, alias stubs, …) |
| Dual list for this family (script uses catalog only) | R3 thin+rest / R4 pattern body / pure-ld |

**Forbidden:** re-listing frontend-glue `.o` paths inside `ensure_host_cc_seed_o.sh` as a second inventory (map keys only resolve catalog members).

### wave751 · R1 fourth family: MAIN_RUNTIME (multi-flag variants)

```text
Family: R1_MAIN_RUNTIME_OBJS (Makefile list authority)
  src/main.o              ← seeds/main.from_x.c          (no extra -D)
  src/main_x.o            ← seeds/main.from_x.c          (-DXLANG_USE_X_PIPELINE)
  src/main_driver.o       ← seeds/main.from_x.c          (-DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE)
  src/runtime.o           ← seeds/runtime.from_x.c       (no extra -D)
  src/runtime_x.o         ← seeds/runtime.from_x.c       (-DXLANG_USE_X_PIPELINE)
  src/runtime_driver.o    ← seeds/runtime.from_x.c       ($(RUNTIME_DRIVER_CFLAGS))
  src/runtime_driver_no_c.o ← seeds/runtime.from_x.c     ($(RUNTIME_DRIVER_NO_C_CFLAGS))

Body (G.7 same ensure_host_cc_seed_o.sh):
  scripts/ensure_host_cc_seed_o.sh one OUT SEED [extras...]
  scripts/ensure_host_cc_seed_o.sh main-runtime  # catalog list + o→seed + o→flag map
  scripts/ensure_host_cc_seed_o.sh all           # four families

Seed/flag maps = path *convention* only (not a second .o inventory).
Thin Makefile leaves pass make-expanded RUNTIME_DRIVER_*_CFLAGS as extras.
Family mode uses env or defaults aligned with Makefile base (no LEGACY_PREPROCESS).
Unknown catalog members fail closed.
Catalog: R1_MAIN_RUNTIME_OBJS exported via bootstrap-driver-seed-export-obj-catalog.
```

| Swallowed | Still residual |
|-----------|----------------|
| Pure host-cc for main/runtime multi-flag variants (shared seeds) | Other R1 (extra-cflags pure basename, pipeline_abi, -fPIE, …) |
| Dual list for this family (script uses catalog only) | R3 thin+rest / R4 pattern body / pure-ld |

**Forbidden:** re-listing main-runtime `.o` paths inside `ensure_host_cc_seed_o.sh` as a second inventory (map keys only resolve catalog members).

### wave752 · R1 fifth family: ALIAS_STUBS (pure basename link alias / stubs)

```text
Family: R1_ALIAS_STUBS_OBJS (Makefile list authority)
  x_frontend_link_alias.o
  ast_asm_bare_link_alias.o
  backend_asm_bare_link_alias.o
  backend_asm_strict_fallback_alias.o
  typeck_c_module_stubs.o
  src/asm/user_asm_seed_bridge.o
  src/asm/asm_backend_compat_stubs.o
  src/runtime_driver_strict_glue_stubs.o
  → seeds/<basename>.from_x.c  (no extra -D)

Body (G.7 same ensure_host_cc_seed_o.sh):
  scripts/ensure_host_cc_seed_o.sh one OUT SEED
  scripts/ensure_host_cc_seed_o.sh alias-stubs  # catalog list + basename convention
  scripts/ensure_host_cc_seed_o.sh all          # five families

Catalog: R1_ALIAS_STUBS_OBJS exported via bootstrap-driver-seed-export-obj-catalog.
```

| Swallowed | Still residual |
|-----------|----------------|
| Pure host-cc for link alias / bare / compat stubs (basename) | Other R1 (misc pure basename host-cc without special extras) |
| Dual list for this family (script uses catalog only) | R3 thin+rest / R4 pattern body / pure-ld |

**Forbidden:** re-listing alias-stubs `.o` paths inside `ensure_host_cc_seed_o.sh` as a second inventory.

### wave753 · R1 sixth family: EXTRA_CFLAGS (pipeline_abi / -fPIE / sqlite multi-flag / parser)

```text
Family: R1_EXTRA_CFLAGS_OBJS (Makefile list authority)
  src/runtime_pipeline_abi.o           ← seeds/runtime_pipeline_abi.from_x.c
                                         + $(RUNTIME_PIPELINE_ABI_CFLAGS)
  runtime_asm_io_stubs.o               ← seeds/runtime_asm_io_stubs.from_x.c + -fPIE
  runtime_sqlite_glue.o                ← seeds/runtime_sqlite_glue.from_x.c
                                         + -DXLANG_DB_USE_SQLITE3
  runtime_sqlite_glue_stub.o           ← seeds/runtime_sqlite_glue.from_x.c (no -D)
  src/asm/parser_asm_parse_expr_link.o ← seeds/parser_asm_parse_expr_link.from_x.c
                                         + $(PARSER_ASM_LINK_ALIAS_CFLAGS)

Body (G.7 same ensure_host_cc_seed_o.sh):
  scripts/ensure_host_cc_seed_o.sh one OUT SEED [extras...]
  scripts/ensure_host_cc_seed_o.sh extra-cflags  # catalog + o→seed + o→flag map
  scripts/ensure_host_cc_seed_o.sh all           # six families

Seed/flag maps = path *convention* only (not a second .o inventory).
Thin Makefile leaves pass make-expanded RUNTIME_PIPELINE_ABI_CFLAGS /
PARSER_ASM_LINK_ALIAS_CFLAGS as extras.
Family mode uses env or defaults aligned with Makefile base (no LEGACY).
Unknown catalog members fail closed.
Catalog: R1_EXTRA_CFLAGS_OBJS exported via bootstrap-driver-seed-export-obj-catalog.
```

| Swallowed | Still residual |
|-----------|----------------|
| Pure host-cc with extra flags for pipeline_abi / -fPIE stubs / sqlite multi-out / parser link-alias | Other R1 (misc pure basename host-cc without special extras) |
| Dual list for this family (script uses catalog only) | R3 thin+rest / R4 pattern body / pure-ld |

**Forbidden:** re-listing extra-cflags `.o` paths inside `ensure_host_cc_seed_o.sh` as a second inventory (map keys only resolve catalog members).

### wave754 · R1 seventh family: MISC_BASENAME (pure basename glue / enc / ctx / …)

```text
Family: R1_MISC_BASENAME_OBJS (Makefile list authority)
  runtime_link_abi_user_env.o
  runtime_channel_glue.o
  runtime_scheduler_glue.o          (thin may pass -Isrc/asm)
  runtime_kv_mmap_glue.o
  src/asm/backend_x86_64_enc_c.o
  src/asm/backend_arm64_enc_c.o
  src/lsp/lsp_diag_pipeline_ctx.o
  build_asm/pipeline_glue_strict_minimal.o
  src/asm/runtime_asm_build.o

Body (G.7 same ensure_host_cc_seed_o.sh):
  scripts/ensure_host_cc_seed_o.sh one OUT SEED [extras...]
  scripts/ensure_host_cc_seed_o.sh misc-basename  # catalog + basename seed map
  scripts/ensure_host_cc_seed_o.sh all            # seven families

Seed map = basename convention (seeds/<leaf>.from_x.c).
No special -D/-f family map (scheduler thin -Isrc/asm only for parity).
Catalog: R1_MISC_BASENAME_OBJS exported via bootstrap-driver-seed-export-obj-catalog.
```

| Swallowed | Still residual |
|-----------|----------------|
| Pure host-cc misc pure basename (glue/enc/ctx/pipeline_glue/asm_build) | R3 thin+rest cold fallback · R4 pattern body · pure-ld |
| Dual list for this family (script uses catalog only) | Physical Makefile delete |

**Forbidden:** re-listing misc-basename `.o` paths inside `ensure_host_cc_seed_o.sh` as a second inventory.

### wave755 · R1 eighth family: SEED_MAP (basename-mismatch + orch -D)

```text
Family: R1_SEED_MAP_OBJS (Makefile list authority)
  src/driver/target_cpu.o                 ← seeds/target_cpu_pure.from_x.c
  src/ast/ast_seed.o                      ← seeds/runtime_ast_glue.from_x.c
  pipeline_bootstrap_orchestration.o      ← seeds/pipeline_bootstrap_orchestration.from_x.c
                                            + -Ibuild_asm -DPIPELINE_BOOTSTRAP_ORCH_NO_PIPELINE_RUN_WRAPPER

Body (G.7 same ensure_host_cc_seed_o.sh):
  scripts/ensure_host_cc_seed_o.sh one OUT SEED [extras...]
  scripts/ensure_host_cc_seed_o.sh seed-map   # catalog + o→seed + extras map
  scripts/ensure_host_cc_seed_o.sh all        # eight families

Seed/flag maps live in ensure script (path convention only).
Catalog: R1_SEED_MAP_OBJS exported via bootstrap-driver-seed-export-obj-catalog.
Prereqs (pipeline_gen.c / pipeline_glue_types.inc) stay Makefile edge list.
```

| Swallowed | Still residual |
|-----------|----------------|
| Pure host-cc mismatch stems + orch extras | R3 thin+rest PREFER_X_O cold else · R4 non-R1 residual · pure-ld |
| Dual list for this family (script uses catalog only) | Physical Makefile delete |

**Forbidden:** re-listing seed-map `.o` paths inside `ensure_host_cc_seed_o.sh` as a second inventory (map keys only resolve catalog members).

## CLI

```text
./xbuild leaf-patterns                 # dump residual class inventory KEY=value
./xbuild leaf-patterns --check
./xbuild leaf-residual                 # alias
./xbuild host-cc-seed                  # all swallowed R1 families (wave755)
./xbuild rt-seed-slice | core-seed | frontend-glue | main-runtime | alias-stubs | extra-cflags | misc-basename | seed-map
./xbuild host-cc-seed --check
./xbuild host-cc-seed --force
bash compiler/scripts/leaf_pattern_residual.sh
bash compiler/scripts/leaf_pattern_residual.sh --check
bash compiler/scripts/leaf_pattern_residual.sh classes
# R1 live body (compiler/):
bash compiler/scripts/ensure_host_cc_seed_o.sh rt-slice
bash compiler/scripts/ensure_host_cc_seed_o.sh core-seed
bash compiler/scripts/ensure_host_cc_seed_o.sh frontend-glue
bash compiler/scripts/ensure_host_cc_seed_o.sh main-runtime
bash compiler/scripts/ensure_host_cc_seed_o.sh alias-stubs
bash compiler/scripts/ensure_host_cc_seed_o.sh extra-cflags
# R4 pure-R1 helper (wave756; used by rebuild_leaves):
bash compiler/scripts/ensure_host_cc_seed_o.sh try-r1 <out.o>
# R3 cold-else helper (wave757; used by rebuild_leaves residual path):
bash compiler/scripts/ensure_host_cc_seed_o.sh try-r3-cold <out.o>
./xbuild r3-cold-seed [--force]
bash compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh bridge   # pure-R1 only → no make
bash compiler/scripts/ensure_host_cc_seed_o.sh misc-basename
bash compiler/scripts/ensure_host_cc_seed_o.sh seed-map
bash compiler/scripts/ensure_host_cc_seed_o.sh all
bash compiler/scripts/ensure_host_cc_seed_o.sh --check
# R4 live body (compiler/):
bash compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh bridge
```

## Migration path (11.3.1 · not closed)

```text
1. Keep lists in mk/catalog (G.7)
2. For each residual class R1–R5:
     name single shell body → Makefile thin phony only
3. wave747: R4 mode policy + catalog list path ✅
4. wave748: R1 pure host-cc body for RT_SEED_SLICE family ✅
5. wave749: R1 pure host-cc body for CORE_SEED family ✅
6. wave750: R1 pure host-cc body for FRONTEND_GLUE family ✅
7. wave751: R1 pure host-cc body for MAIN_RUNTIME multi-flag family ✅
8. wave752: R1 pure host-cc body for ALIAS_STUBS family ✅
9. wave753: R1 pure host-cc body for EXTRA_CFLAGS family ✅
10. wave754: R1 pure host-cc body for MISC_BASENAME family ✅
11. wave755: R1 pure host-cc body for SEED_MAP family ✅
12. Next: R4 remaining residual (panic/gen/hybrid/glue/pipeline-x) · R3 PREFER thin · 11.1.4 pure-ld
13. When no recipe needs make pattern graph:
     delete compiler/Makefile (11.3.1) + root Makefile (11.3.2)
14. Zero host-cc product path → stage 12 (Docker unload gcc/make)
```

**Forbidden shortcuts:** bulk-copy every `$(CC) -c` into a mega shell list; dual `.o` tables; pure-ld rewrite under this inventory without 11.1.4 map.

## Acceptance

### wave746 (inventory)

- [x] `compiler/docs/LEAF_PATTERN_RESIDUAL.md` present (this file)
- [x] `leaf_pattern_residual.sh` dump/classes/check
- [x] `./xbuild leaf-patterns` / `leaf-residual` first-class
- [x] `build.x` §F documents 11.3.1 leaf residual path
- [x] `BUILD_DAG.md` residual section + wave746 checklist
- [x] 0-make gate hard-checks doc + script + xbuild + live `--check`

### wave747 (R4 mode-policy swallow)

- [x] `bootstrap_driver_seed_rebuild_leaves.sh` default = catalog KEY + shell mode table
- [x] No hardcoded `.o` paths in rebuild_leaves (G.7)
- [x] Pattern bodies still via `make` (honest residual)
- [x] `XLANG_REBUILD_LEAVES_VIA_EXPORT=1` legacy escape
- [x] leaf residual dump flags `R4_MODE_POLICY_SWALLOWED=1` / body residual

### wave748 (R1 rt-seed-slice family)

- [x] `ensure_host_cc_seed_o.sh` pure host-cc body (`one` + `rt-slice`)
- [x] List from catalog `RT_SEED_SLICE_OBJS` (no dual inventory in shell)
- [x] Makefile five `src/runtime/rt_*.o` thin-call the script
- [x] `./xbuild host-cc-seed` / `rt-seed-slice` + `--check`
- [x] leaf residual dump `SWALLOWED_R1_RT_SEED_SLICE=1` / `R1_OTHER_HOST_CC_STILL_MAKE=1`

### wave749 (R1 core-seed family)

- [x] Same body + `core-seed` / `all` modes
- [x] List from catalog `R1_CORE_SEED_OBJS` (no dual inventory in shell)
- [x] Makefile five core leaves thin-call the script (diag/link_abi/c_import/bridge/compat)
- [x] `./xbuild core-seed` · `host-cc-seed` umbrella = all swallowed families
- [x] leaf residual dump `SWALLOWED_R1_CORE_SEED=1` / `R1_CORE_SEED_SWALLOWED=1`

### wave750 (R1 frontend-glue family)

- [x] Same body + `frontend-glue` / `all` modes (basename-mismatch seed map)
- [x] List from catalog `R1_FRONTEND_GLUE_OBJS` (no dual inventory in shell)
- [x] Makefile three glue leaves thin-call the script (lexer/ast/lsp_diag; both lexer rule sites)
- [x] `./xbuild frontend-glue` · `host-cc-seed` umbrella = three families
- [x] leaf residual dump `SWALLOWED_R1_FRONTEND_GLUE=1` / `R1_FRONTEND_GLUE_SWALLOWED=1`

### wave751 (R1 main-runtime family)

- [x] Same body + `main-runtime` / `all` modes (multi-flag o→seed + o→-D map)
- [x] List from catalog `R1_MAIN_RUNTIME_OBJS` (no dual inventory in shell)
- [x] Makefile seven main/runtime leaves thin-call the script
- [x] `./xbuild main-runtime` · umbrella = four families
- [x] leaf residual dump `SWALLOWED_R1_MAIN_RUNTIME=1` / `R1_MAIN_RUNTIME_SWALLOWED=1`

### wave752 (R1 alias-stubs family)

- [x] Same body + `alias-stubs` / `all` modes (pure basename)
- [x] List from catalog `R1_ALIAS_STUBS_OBJS` (no dual inventory in shell)
- [x] Makefile eight alias/stub leaves thin-call the script
- [x] `./xbuild alias-stubs` · umbrella `host-cc-seed` = five families
- [x] leaf residual dump `SWALLOWED_R1_ALIAS_STUBS=1` / `R1_ALIAS_STUBS_SWALLOWED=1`

### wave753 (R1 extra-cflags family)

- [x] Same body + `extra-cflags` / `all` modes (o→seed + o→extra flag map)
- [x] List from catalog `R1_EXTRA_CFLAGS_OBJS` (no dual inventory in shell)
- [x] Makefile five leaves thin-call the script (pipeline_abi / -fPIE / sqlite×2 / parser)
- [x] `./xbuild extra-cflags` · umbrella `host-cc-seed` = six families
- [x] leaf residual dump `SWALLOWED_R1_EXTRA_CFLAGS=1` / `R1_EXTRA_CFLAGS_SWALLOWED=1`

### wave754 (R1 misc-basename family)

- [x] Same body + `misc-basename` / `all` modes (pure basename)
- [x] List from catalog `R1_MISC_BASENAME_OBJS` (no dual inventory in shell)
- [x] Makefile nine leaves thin-call the script (glue/enc/ctx/pipeline_glue/asm_build/…)
- [x] `./xbuild misc-basename` · umbrella `host-cc-seed` = seven families
- [x] leaf residual dump `SWALLOWED_R1_MISC_BASENAME=1` / `R1_MISC_BASENAME_SWALLOWED=1`

### wave755 (R1 seed-map family)

- [x] Same body + `seed-map` / `all` modes (o→seed + orch extras)
- [x] List from catalog `R1_SEED_MAP_OBJS` (no dual inventory in shell)
- [x] Makefile three leaves thin-call the script (target_cpu / ast_seed / orch)
- [x] `./xbuild seed-map` · umbrella `host-cc-seed` = eight families
- [x] leaf residual dump `SWALLOWED_R1_SEED_MAP=1` / `R1_SEED_MAP_SWALLOWED=1`

### wave756 (R4 pure-R1 body)

- [x] `rebuild_leaves` → `ensure try-r1` for catalog pure R1 members
- [x] bridge pure-R1 → no make; residual non-R1 still make
- [x] LEAF dump `SWALLOWED_R4_BODY_PURE_R1=1` · `R4_BODY_PURE_R1_SWALLOWED=1`

### wave757 (R3 cold-else body)

- [x] catalog `R3_COLD_SEED_OBJS` (9 thin+rest cold pure host-cc leaves)
- [x] `try-r3-cold` / `r3-cold-seed` same ensure_one body (basename seed)
- [x] `rebuild_leaves` residual path tries try-r3-cold before make
- [x] Makefile cold-else branches thin-call ensure (PREFER thin unchanged)
- [x] LEAF dump `SWALLOWED_R3_COLD_ELSE=1` · `R3_COLD_ELSE_SWALLOWED=1`
- [x] `./xbuild r3-cold-seed`

### wave758 (R4 residual thin_glue → R1 seed-map)

- [x] `parser_asm_thin_glue.o` on `R1_SEED_MAP_OBJS` (G.7 有则补全; no new family)
- [x] seed/extras map + ensure_one `*.inc` freshness twin of Makefile prereqs
- [x] Makefile thin-call ensure (no inline `$(CC) -c`)
- [x] user-asm rebuild shell-only (`pure_r1` includes thin_glue; residual_make=0)
- [x] LEAF dump `SWALLOWED_R4_BODY_THIN_GLUE=1`

### wave759 (R4 residual glue standalone → R1 seed-map)

- [x] `build_asm/pipeline_glue_standalone.o` on `R1_SEED_MAP_OBJS` (G.7 有则补全; no new family)
- [x] seed/extras map + ensure_one glue/ast_pool/types.inc freshness twin of Makefile prereqs
- [x] Makefile thin-call ensure (no residual `cc_inc_tu` body)
- [x] glue rebuild shell-only (`pure_r1=1`; residual_make=0)
- [x] LEAF dump `SWALLOWED_R4_BODY_GLUE_STANDALONE=1`
### wave760 (R2 panic cold)

- [x] catalog `DRIVER_SEED_PANIC_OBJS` + try-r2 cold body + stamp
- [x] Makefile cold thin-call try-r2; PREFER thin residual
- [x] LEAF dump `SWALLOWED_R2_PANIC_COLD=1`

### wave761 (R4 gen *_x + pipeline_x)

- [x] `ensure_gen_x_o.sh` + try-gen-x + Makefile thin
- [x] LEAF dump `SWALLOWED_R4_BODY_GEN_X=1`

### wave762 (R2 typeck_f64 + crt0)

- [x] catalog `DRIVER_SEED_TYPECK_F64_OBJS` + `DRIVER_SEED_CRT0_OBJS` (mk)
- [x] try-r2 membership extend (G.7 有则补全; no second helper name)
- [x] Makefile typeck_f64 + crt0 thin-call try-r2
- [x] g05_ensure + build_xlang_asm converge to try-r2
- [x] LEAF dump `SWALLOWED_R2_TYPECK_F64=1` · `SWALLOWED_R2_CRT0=1` · live metrics

### wave763 (R3 PREFER thin · R3_COLD nine)

- [x] `try-r3-prefer` membership = catalog `R3_COLD_SEED_OBJS` (G.7 有则补全; no new list)
- [x] `try-labi-prefer` single leaf `src/runtime_link_abi.o` multi-slice body (wave765)
- [x] g05 + Makefile thin-call try-labi-prefer; dual labi hybrid deleted
- [x] `try-rt-prefer` single leaf `src/runtime_driver_no_c.o` multi-slice body (wave766)
- [x] g05 + Makefile thin-call try-rt-prefer; dual rt hybrid deleted; RT_SEED_SLICE external
- [x] `try-pipeline-abi-prefer` single leaf `src/runtime_pipeline_abi.o` (wave767)
- [x] `try-ldpc-prefer` single leaf `src/lsp/lsp_diag_pipeline_ctx.o` (wave767)
- [x] `try-target-cpu-prefer` single leaf `src/driver/target_cpu.o` (wave768)
- [x] g05 + Makefile thin-call try-target-cpu-prefer; dual target_cpu hybrid deleted
- [x] g05 + Makefile thin-call pipeline_abi/ldpc; dual hybrid deleted
- [x] leaf map x/rest-defs/nm (not .o inventory); unified PREFER=1 gate
- [x] Makefile nine thin-call try-r3-prefer (no inline ld -r thin+rest)
- [x] LEAF dump `SWALLOWED_R3_PREFER_THIN=1` · `R3_PREFER_THIN_SWALLOWED=1`

### wave771 (g05 other L2 four PREFER)

- [x] `try-other-l2-prefer` table body + g05/Makefile thin-call
- [x] LEAF dump `SWALLOWED_G05_OTHER_L2_PREFER=1`

### wave772 (11.1.4 pure-ld cold prefer)

- [x] Makefile export `SEED_LINK_LD` / `MULTIDEF` / `ENTRY` / `LD_TAIL` / `PURE_OK`
- [x] `bootstrap_driver_seed_link.sh` try_pure_ld + CC residual + `--self-test`
- [x] LEAF dump `SWALLOWED_R6_PURE_LD=1` · `ENDGAME_COLD_PURE_LD=1`
- [x] `host_platform_linker` / `PLATFORM_LINKER.md` pure-ld prefer inventory

### wave773 (11.1.4 g05 pure-ld prefer)

- [x] `pure_ld_shared.sh` single pure-ld platform / try authority
- [x] cold seed_link sources pure_ld_shared (no second platform table)
- [x] `g05_relink_xlang.sh` try_g05_pure_ld + CC residual
- [x] LEAF dump `SWALLOWED_G05_PURE_LD=1` · `ENDGAME_G05_PURE_LD=1`
- [x] host/leaf `--check` + pure-ld `--self-test`

- [x] **wave774:** drop silent CC residual fallback (FORCE_CC / ineligible kept)
- [x] **wave775:** `fmt_check_cmd.o` Makefile dual → try-other-l2-prefer `fmt_core`
- [x] **wave776:** R2 panic PREFER → try-r2-prefer
- [x] **wave777:** physical-delete **prep inventory** (named buckets B1–B7; no body swallow; no Makefile delete)
- [x] **wave778:** **Windows gate** before Makefile physical delete + **dual-end** (mac + Ubuntu) verify policy
- [x] **wave779:** B1 runtime_* OS/glue dual hybrid → `try-runtime-os-prefer` (23 thin-call; not physical delete)
- [x] **wave780:** B2 std/core product hybrid → `try-std-core-prefer` (5 thin-call; not physical delete)
- [x] **wave781:** B3 LSP satellite hybrid → `try-lsp-sat-prefer` (2 thin-call; not physical delete)
- [x] **wave782:** B4 gen_c_to_o bootstrap → `try-gen-c-to-o` (5 thin-call; not physical delete)
- [x] **wave783:** B5 cfg_eval multi-ladder → `try-cfg-eval-ladder` (1 thin-call; not physical delete)
- [x] **wave784:** B6 R5 CI / `compiler-all` → `compiler_all_ci.sh` (Makefile thin-call; not physical delete)
- [x] **wave785:** B7 DAG residual **inventory** (B7A–B7D) + B7c archaeology `$(CC) -c` thin (not physical delete)
- [x] **wave786:** B7D host-cc product `xlang` link → g05
- [x] **wave787:** B7A cold rebuild residual_make=0 honesty + heat thin-edge inventory + B7B list-stays-mk honesty
- [x] **wave788:** B7B shell-primary catalog (mk parse 0-make; make export escape; lists stay mk)
- [x] **wave789:** B7A heat shell auto-dispatch `try-heat` / `./xbuild heat-o` (Makefile edges still residual)
- [x] **wave790:** B7A heat Makefile recipes unify → `try-heat` only (dep edges residual; mode names in comments)
- [x] **wave798:** physical-delete **preflight** readiness (named blockers; Windows min-gate cmd; NOT green; NOT delete)
- [x] **wave799:** physical-delete **execute gate** (`phys_del_makefile_gate.sh` refuse-delete + dry-run; NOT green; NOT delete)
- [x] **wave800:** Windows min-gate **proof stamp** harness (`--run-windows-gate` writes stamp; `--verify-windows-proof`; NOT STATUS green; NOT delete)
- [x] **wave805:** ENDGAME arm **prep/preview** (`--endgame-preview`; STATUS green plan only; TREE_ARMED=0; NOT arm; NOT delete)
- [x] **wave806:** ENDGAME arm **apply harness** (`--endgame-arm-apply`; STATUS+confirm; TREE_ARMED=0 on tree; NOT physical delete)
- [x] **wave807:** ENDGAME arm **commit honesty** (`--endgame-arm-commit-honesty`; pre_arm/post_arm; TREE_ARMED=0 on tree; NOT tree arm; NOT delete)
- [x] **wave808:** reviewed **TREE_ARMED arm** (`ENDGAME=1` + `TREE_ARMED=1`; honesty greps co-changed; Makefile still present; NOT physical delete)
- [x] **wave809:** delete-body **prep/preview** (`--delete-body-preview`; TREE_ARMED plan only; BODY_SHIPPED=0; NOT ship body; NOT physical delete)
- [x] **wave810:** delete-body **commit honesty** (`--delete-body-commit-honesty`; pre_ship inventory; BODY_SHIPPED=0; NOT ship body; NOT physical delete)
- [x] **wave811:** std_x product hybrid body thin (22 leaves → `xlang_compile_std_x` `auto|auto-soft|auto-soft-merge`; NOT physical delete)
- [ ] Physical delete of Makefile / all leaf pattern rules (11.3.1 endgame · **after shell-primary residual + explicit auth + ship delete body**)
- [ ] Leaf `.o` without host-cc residual (stages 8–9 / 12)
- [ ] B7 residual endgame: Makefile heat **dep** edges gone / physical delete (try-heat ✅ wave789; thin-unify ✅ wave790; source-prereq closed wave797; thin-call edges remain until phys del)


### wave790 · B7A heat thin-unify (Makefile recipes → try-heat)

> **G.7 有则补全 / NOT physical delete.** All 115 Makefile ensure *recipes* call
> `bash scripts/ensure_host_cc_seed_o.sh try-heat $@` only. Historical try-*/one
> mode names remain in comments for archaeology and residual greps.
> Dependency edges on `ensure_host_cc_seed_o.sh` stay residual (make graph).
> Body dispatch authority remains `try_heat_one` (wave789).

### wave789 · B7A heat shell auto-dispatch try-heat (G.7 有则补全)

> **Not this wave:** physical delete of `compiler/Makefile`; collapse/remove Makefile thin-call recipe edges.  
> **This wave:** `ensure_host_cc_seed_o.sh try-heat OUT` ladders **existing** membership helpers
> (prefer/hybrid first → pure R1 → R2 UNAME → gen-x). Heat can rebuild ensure-owned leaves
> without naming which Makefile recipe owns them.  
> **Entry:** `./xbuild heat-o OUT.o` · `bash scripts/ensure_host_cc_seed_o.sh try-heat OUT`.  
> **Exit 3** = not ensure-owned (honest residual make / non-catalog leaf).

```text
Before (wave788):
  heat = must know which try-* / Makefile recipe owns OUT
  B7A heat residual opaque

After (wave789):
  try-heat OUT = prefer ladder then R1/R2/gen (no second body)
  SWALLOWED_B7A_HEAT_SHELL_DISPATCH=1
  PHYS_DEL_BUCKET_B7A_HEAT_SHELL_DISPATCH=1
  PHYS_DEL_BUCKET_B7A_HEAT_RESIDUAL=1   # Makefile thin-call edges still residual
  PHYS_DEL_BUCKET_B7A_BODY_SWALLOWED=0  # edges remain → not full B7A
  PHYS_DEL_PREP_NEXT=B7_physical_delete_makefile_after_windows_not_this_wave
  ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
```

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **B7A heat shell dispatch** (`try-heat` / `xbuild heat-o`; prefer→R1→R2→gen) | **Makefile thin-call edges** · B7c typeck_x_x · physical delete (Windows) · make export escape |
| Prior B1–B6 / B7 inventory / B7c thin / B7D g05 / B7A cold / B7B catalog | FORCE_CC · Windows PE pure-ld |

**Forbidden:** second heat body / dual `.o` list; claim try-heat = physical delete / edges gone; mac-only wave green.

### wave788 · B7B shell-primary catalog (G.7 有则补全)

> **Not this wave:** physical delete of `compiler/Makefile`; heat B7A ensure thin-call edges.  
> **This wave:** `driver_seed_obj_catalog.sh` default path = **shell parse** of `compiler/mk/*.mk`
> (+ product-default host picks) — **0 make** for list expansion.  
> **Lists stay mk** (G.7): `user_asm_seed_objs.mk` · `driver_seed_r_lists.mk` (R1/R3/RT/ASM_GLUE) ·
> `driver_seed_export_lists.mk` · `driver_seed_composites.mk`.  
> **Escape:** `XLANG_CATALOG_VIA_MAKE=1` or LEGACY host flags → `make bootstrap-driver-seed-export-obj-catalog`.  
> **Parity:** `--check` requires shell==make under product-default flags.

```text
Before (wave787):
  catalog = make export-obj-catalog only
  B7B make-export residual

After (wave788):
  catalog default = shell mk parse (0 make)
  make export = escape / parity
  SWALLOWED_B7B_SHELL_CATALOG=1
  PHYS_DEL_BUCKET_B7B_SHELL_CATALOG=1
  PHYS_DEL_BUCKET_B7B_MAKE_EXPORT_ESCAPE=1
  PHYS_DEL_BUCKET_B7B_LIST_STAYS_MK=1
  PHYS_DEL_BUCKET_B7B_BODY_SWALLOWED=0
  PHYS_DEL_PREP_NEXT=B7_physical_delete_makefile_after_windows_not_this_wave
  ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
```

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **B7B make-export primary** (catalog shell mk parse; R1/R3/RT moved to `mk/driver_seed_r_lists.mk`) | **B7A heat** ensure thin-call edges · B7c typeck_x_x · physical delete (Windows) · make export escape/LEGACY |
| Prior B1–B6 / B7 inventory / B7c thin / B7D g05 / B7A cold | FORCE_CC · Windows PE pure-ld |

**Forbidden:** re-list `.o` in residual shells; claim shell catalog = physical delete / full B7 endgame; dual list authority; mac-only wave green.

### wave787 · B7A cold residual_make=0 + heat inventory + B7B list honesty (G.7)

> **Not this wave:** physical delete of `compiler/Makefile`; heat `make <obj>` ensure thin-call edges; B7B shell mk-parse 0-make.  
> **This wave:** honesty — cold `rebuild_leaves` seven modes already **shell-only** (`residual_make=0`); name heat B7A residual vs cold; B7B lists stay mk+catalog by design.

```text
Before (wave786):
  B7A = opaque “thin-call edges still make”
  B7B = mk lists (named only)
  cold rebuild residual_make not machine-named

After (wave787):
  SWALLOWED_B7A_COLD_REBUILD_0MAKE=1
  PHYS_DEL_BUCKET_B7A_COLD_0MAKE=1
  PHYS_DEL_BUCKET_B7A_HEAT_RESIDUAL=1   # ensure thin-call edges heat residual
  PHYS_DEL_BUCKET_B7A_BODY_SWALLOWED=0  # heat edges remain → not full B7A
  SWALLOWED_B7B_LIST_AUTHORITY_HONESTY=1
  PHYS_DEL_BUCKET_B7B_LIST_STAYS_MK=1
  PHYS_DEL_BUCKET_B7B_BODY_SWALLOWED=0
  PHYS_DEL_BUCKET_B7_BODY_SWALLOWED=0
  PHYS_DEL_PREP_NEXT=B7_physical_delete_makefile_after_windows_not_this_wave
  ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
```

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **B7A cold** (rebuild_leaves sat/lsp/bridge/panic/user-asm/glue/pipeline-x `residual_make=0`) | **B7A heat** ensure thin-call edges · **B7B** make export-obj-catalog · B7c typeck_x_x · physical delete (Windows) |
| Prior B1–B6 / B7 inventory / B7c thin / B7D g05 | FORCE_CC · Windows PE pure-ld |

**Forbidden:** claim cold residual_make=0 = physical delete / full B7A edge delete; re-list `.o` in residual shells; mac-only wave green.

### wave786 · B7D host-cc product `xlang` link → g05 (G.7 有则补全)

> **Not this wave:** physical delete of `compiler/Makefile`; ~~B7A cold residual_make honesty~~ → **wave787**; B7A heat / B7B mk lists endgame.  
> **This wave:** default `make xlang` / `$(TARGET)` no longer links incomplete `OBJS_CORE` (UNDEF residual).  
> **Authority:** existing `scripts/g05_prepare_and_relink.sh` (G05_OBJS mirror of DRIVER_SEED; pure-ld).  
> **Escape:** `XLANG_HOST_CC_OBJS_CORE=1` restores archaeology incomplete `OBJS_CORE` link (expect UNDEF; not product).

```text
Before (wave785):
  $(TARGET): $(OBJS)   # OBJS_CORE only → UNDEF vs product g05
  B7D = named residual only

After (wave786):
  default $(TARGET): bash scripts/g05_prepare_and_relink.sh
  XLANG_HOST_CC_OBJS_CORE=1 → historical OBJS_CORE link (archaeology)
  SWALLOWED_B7D_HOST_CC_PRODUCT_LINK=1
  PHYS_DEL_BUCKET_B7D_BODY_SWALLOWED=1
  PHYS_DEL_BUCKET_B7_BODY_SWALLOWED=0   # B7A/B still residual; NOT physical delete
  PHYS_DEL_PREP_NEXT=B7_physical_delete_makefile_after_windows_not_this_wave
  ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
```

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **B7D body** (default TARGET product link → g05; no second `.o` list) | ~~B7A cold~~ (wave787) · B7A heat thin-call · B7B mk lists · B7c typeck_x_x archaeology · physical delete (Windows) |
| Prior B1–B6 / B7 inventory / B7c thin | FORCE_CC · Windows PE pure-ld |

**Forbidden:** re-open incomplete `OBJS_CORE` as default product `xlang`; re-list G05_OBJS in Makefile; claim B7D = physical delete / full B7 endgame; mac-only wave green.

### wave785 · B7 DAG residual inventory + archaeology CC thin (G.7 有则补全)

> **Not this wave:** physical delete of `compiler/Makefile`; ~~host-cc `make OPT=1 xlang` complete link (B7D)~~ → **wave786**.  
> **This wave:** post B1–B6 honesty — **name B7 sub-buckets** and thin archaeology dual `$(CC) -c` into existing migrate/ensure/leaf authorities.

```text
Before (wave784):
  PHYS_DEL_PREP_NEXT=B7_makefile_dag_physical_delete_after_windows_not_delete
  B7 = one opaque “DAG thin-calls + lists” residual
  bootstrap-typeck/codegen: dual $(CC) -c typeck_gen/codegen_gen
  bootstrap-self: dual $(CC) -c lsp_io_gen/lsp_gen/lsp_io_std_heap_gen

After (wave785):
  SWALLOWED_B7_DAG_INVENTORY=1
  PHYS_DEL_BUCKET_B7_INVENTORY=1
  PHYS_DEL_BUCKET_B7_BODY_SWALLOWED=0   # NOT physical delete
  B7A thin_call_edges_only
  B7B mk_list_authority (mk + catalog)
  B7C archaeology_phony_cc
    → typeck/codegen .o via migrate_x_objs.sh (wave841 shell-primary)
    → bootstrap-self lsp_* via thin leaves (ensure_gen_x_o / driver_leaf)
      (cleared wave843: full body → bootstrap_self.sh; stage2 link bag still mk)
    → bootstrap-x-compiler typeck_x_x residual $(CC) -c kept (honesty)
      (cleared wave842: body → bootstrap_x_compiler.sh; still not migrate_x_objs)
  B7D host_cc_product_link_xlang (TARGET:OBJS incomplete vs g05; UNDEF residual)
  PHYS_DEL_PREP_NEXT=B7_physical_delete_makefile_after_windows_not_this_wave
  ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
```

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **B7 inventory** (named B7A–B7D + dump/`--check`) | Physical delete (Windows gate) |
| **B7c partial** (archaeology dual `-c` → migrate / thin leaves) | ~~B7c typeck/codegen~~ (wave841) · ~~x-compiler~~ (wave842) · ~~bootstrap-self~~ (wave843) · ~~bootstrap-parser smoke~~ (wave844) · ~~xlang-x-pipeline~~ (wave845) · ~~xlang-x~~ (wave846) · ~~xlang-no-c-frontend~~ (wave847) · ~~bootstrap-driver-seed-x-frontend~~ (wave848) · ~~relink-xlang-lexer~~ (wave849) · B7A edges · B7B lists · ~~**B7D host-cc xlang link**~~ (wave786) |

**Forbidden:** physical delete Makefile; claim B7 inventory = physical delete; re-open dual `$(CC) -c` on typeck/codegen/bootstrap-self lsp; mac-only wave green; treat B7D UNDEF as product g05 failure.

### wave784 · B6 R5 CI / compiler-all → compiler_all_ci.sh (G.7 有则补全)

> **Not this wave:** physical delete of `compiler/Makefile`; B7 leaf DAG endgame.  
> **This wave:** swallow **B6 / R5** CI orchestration body for historical `make OPT=1 all` into `scripts/compiler_all_ci.sh`. `./xbuild compiler-all` and Makefile `all` thin-call the same body.  
> **Why shell body:** policy (OPT default, bootstrap alternate, xlang+xlang-c goals) is orchestration, not a leaf `.o` recipe. Leaf host-cc graph remains B7 residual.

```text
Before (wave783):
  ./xbuild compiler-all → run_compiler_make OPT=1 all → Makefile all deps
  PHYS_DEL_PREP_NEXT=B6_r5_ci_compiler_all_body_swallow_not_delete

After (wave784):
  scripts/compiler_all_ci.sh
    OPT unset → 1; empty OPT preserved (bare make all)
    XLANG_RUN_ALL_BOOTSTRAP_XLANG=1 → make bootstrap-driver-seed
    else → make OPT=… xlang xlang-c   (B7 leaf graph residual)
  ./xbuild compiler-all → shell body directly
  Makefile all: thin-call compiler_all_ci.sh only
  SWALLOWED_B6_R5_CI_COMPILER_ALL=1
  PHYS_DEL_BUCKET_B6_BODY_SWALLOWED=1
  PHYS_DEL_PREP_NEXT=B7_makefile_dag_physical_delete_after_windows_not_delete
  ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
```

| Surface | Body |
|---------|------|
| `./xbuild compiler-all` / `ci-all` | `compiler/scripts/compiler_all_ci.sh` |
| `make -C compiler [OPT=1] all` | same (thin-call) |

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **B6 body** (R5 CI policy/sequence → compiler_all_ci.sh + Makefile/xbuild thin) | ~~B7 inventory~~ (wave785) · physical delete after Windows |
| Prior R1–R6 / prefer / pure-ld / prep / Windows+dual-end / B1–B5 | FORCE_CC · Windows PE pure-ld · stage 12 unload gcc |

**Forbidden:** physical delete Makefile; claim B6 swallow = physical delete / stage 12 done; re-open bare `run_compiler_make OPT=1 all` as dual authority; mac-only wave green.

### wave783 · B5 cfg_eval multi-ladder → try-cfg-eval-ladder (G.7 有则补全)

> **Not this wave:** physical delete of `compiler/Makefile`; B6 R5 body.  
> **This wave:** swallow **B5** Makefile multi-ladder body for `src/lexer/cfg_eval.o` into ensure `try-cfg-eval-ladder` (1 leaf). Makefile keeps thin-call edge only.  
> **Why dedicated:** multi-rung product ladder (-E-extern ±L → pin gen + alias ld -r → bootstrap stub); not catalog try-gen-x / not hybrid prefer.

```text
Before (wave782):
  Makefile src/lexer/cfg_eval.o multi-ladder (xlang-c -E-extern / pin / stub)
  PHYS_DEL_PREP_NEXT=B5_cfg_eval_multi_ladder_body_swallow_not_delete

After (wave783):
  ensure try-cfg-eval-ladder OUT
    rungs: -E-extern±L + PIPELINE_GEN_CFLAGS + link_alias ld -r
         → linux pin gen + alias
         → bootstrap stub cp
  Makefile: thin-call try-cfg-eval-ladder only
  SWALLOWED_B5_CFG_EVAL_LADDER=1
  PHYS_DEL_BUCKET_B5_BODY_SWALLOWED=1
  PHYS_DEL_PREP_NEXT=B6_r5_ci_compiler_all_body_swallow_not_delete
  ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
```

| Leaf | Rungs |
|------|-------|
| `src/lexer/cfg_eval.o` | live -E-extern (+/- `-L ..`) → pin `cfg_eval_gen.linux.x86_64.c` + alias → bootstrap stub |

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **B5 body** (cfg_eval multi-ladder → ensure try-cfg-eval-ladder + Makefile thin-call) | ~~B6~~ (wave784) · B7 DAG · physical delete |
| Prior R1–R6 / prefer / pure-ld / prep / Windows+dual-end / B1–B4 | FORCE_CC · Windows PE pure-ld body |

**Forbidden:** physical delete Makefile; claim B5 swallow = physical delete; re-open multi-ladder on this leaf; mac-only wave green.

### wave782 · B4 gen_c_to_o bootstrap → try-gen-c-to-o (G.7 有则补全)

> **Not this wave:** physical delete of `compiler/Makefile`; B5 body swallow.  
> **This wave:** swallow **B4** Makefile pure host-cc gen.c→.o bodies into ensure `try-gen-c-to-o` (5 leaves); body maps live in `ensure_gen_x_o.sh` (same authority as wave761 gen maps; **outside** try-gen-x catalog). Makefile keeps thin-call edges only.  
> **Why not fold into try-gen-x:** try-gen-x membership = catalog `DRIVER_SEED_LSP_X_OBJS` / `PIPELINE_X` only; B4 bootstrap leaves are not catalog members.

```text
Before (wave781):
  Makefile 5× gen.c → .o bootstrap (lexer_x · ast_gen2 · driver_x · preprocess_x · _x_stubs2)
  PHYS_DEL_PREP_NEXT=B4_gen_c_to_o_bootstrap_body_swallow_not_delete

After (wave782):
  ensure try-gen-c-to-o OUT
    table-driven 5 leaves → ensure_gen_x_o.sh one
  Makefile 5 leaves: thin-call try-gen-c-to-o only
  SWALLOWED_B4_GEN_C_TO_O=1
  PHYS_DEL_BUCKET_B4_BODY_SWALLOWED=1
  PHYS_DEL_PREP_NEXT=B5_cfg_eval_multi_ladder_body_swallow_not_delete
  ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
```

| Leaf | Gen / source | Behavior |
|------|--------------|----------|
| `lexer_x.o` | `lexer_gen.c` | token enum sync + `PIPELINE_GEN_CFLAGS` `-I` triad |
| `ast_gen2.o` | `ast_gen2.c` | `PIPELINE_GEN_CFLAGS` `-I` triad |
| `driver_x.o` | `driver_gen.c` | `-include x_stubs.h` + fs `-D` renames; MAIN_X_DEPS stale |
| `preprocess_x.o` | `preprocess_gen.c` | plain `CFLAGS -c` |
| `_x_stubs2.o` | `_x_stubs2.c` | plain `CFLAGS -c` (stage2 stubs) |

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **B4 body** (5 gen bootstrap → ensure try-gen-c-to-o + Makefile thin-call) | ~~B5~~ (wave783) · B6 R5 · B7 DAG · physical delete |
| Prior R1–R6 / prefer / pure-ld / prep / Windows+dual-end / B1–B3 | FORCE_CC · Windows PE pure-ld body |

**Forbidden:** physical delete Makefile; claim B4 swallow = physical delete; re-open inline `$(CC) -c` on B4 leaves; mac-only wave green; fold B4 into try-gen-x catalog without list authority.

### wave781 · B3 LSP satellite hybrid → try-lsp-sat-prefer (G.7 有则补全)

> **Not this wave:** physical delete of `compiler/Makefile`; B4–B5 body swallow.  
> **This wave:** swallow **B3** Makefile LSP satellite hybrid bodies into ensure `try-lsp-sat-prefer` (2 leaves); Makefile keeps thin-call edges only.  
> **Why dedicated (not try-other-l2-prefer):** sizes_nostub is `xlang-c -E → cc -c` direct (no WEAK thin+rest); stubs_no_c is `-E` thin + rest FROM_X + `ld -r` multidef (not `rt_prefer_try_x_to_o` / G05_X_O_WEAK). Extending other-l2 would fork that authority.

```text
Before (wave780):
  Makefile 2× LSP satellite hybrid (sizes_nostub · stubs_no_c)
  PHYS_DEL_PREP_NEXT=B3_lsp_satellite_hybrid_body_swallow_not_delete

After (wave781):
  ensure try-lsp-sat-prefer OUT
    table-driven 2 leaves
    leaf_kind: direct_e | thin_rest_e
  Makefile 2 leaves: thin-call try-lsp-sat-prefer only
  SWALLOWED_B3_LSP_SAT_PREFER=1
  PHYS_DEL_BUCKET_B3_BODY_SWALLOWED=1
  PHYS_DEL_PREP_NEXT=B4_gen_c_to_o_bootstrap_body_swallow_not_delete
  ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
```

| Leaf | leaf_kind | Behavior |
|------|-----------|----------|
| `src/lsp/lsp_diag_pipeline_sizes_nostub.o` | `direct_e` | xlang-c `-E` → host-cc `-x c -c` → OUT; else cold seed |
| `src/lsp/lsp_diag_stubs_no_c.o` | `thin_rest_e` | xlang-c `-E` thin + seed rest `-DXLANG_LSP_DIAG_STUBS_NO_C_FROM_X` → `ld -r` multidef; else cold seed |

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **B3 body** (2 LSP satellite hybrid → ensure try-lsp-sat-prefer + Makefile thin-call) | ~~B4~~ (wave782) · B5 hybrid bodies · B6 R5 · B7 DAG · physical delete |
| Prior R1–R6 / prefer / pure-ld / prep / Windows+dual-end / B1 / B2 | FORCE_CC · Windows PE pure-ld body |

**Forbidden:** physical delete Makefile; claim B3 swallow = physical delete; re-open dual hybrid body on B3 leaves; mac-only wave green (wave778 gate still holds); fold into try-other-l2 without matching shapes.

### wave780 · B2 std/core product hybrid → try-std-core-prefer (G.7 有则补全)

> **Not this wave:** physical delete of `compiler/Makefile`; B3–B5 body swallow.  
> **This wave:** swallow **B2** Makefile product hybrid bodies into ensure `try-std-core-prefer` (5 leaves); Makefile keeps thin-call edges only.

```text
Before (wave779):
  Makefile 5× std/core product hybrid (process/path/runtime/net + core/slice)
  PHYS_DEL_PREP_NEXT=B2_std_core_product_hybrid_body_swallow_not_delete

After (wave780):
  ensure try-std-core-prefer OUT
    table-driven 5 leaves
    leaf_kind: direct | process_merge | net_merge
  Makefile 5 leaves: thin-call try-std-core-prefer only
  SWALLOWED_B2_STD_CORE_PREFER=1
  PHYS_DEL_BUCKET_B2_BODY_SWALLOWED=1
  PHYS_DEL_PREP_NEXT=B3_lsp_satellite_hybrid_body_swallow_not_delete
  ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
```

| Leaf | leaf_kind | Behavior |
|------|-----------|----------|
| `../std/path/path.o` | `direct` | PREFER=1 xlang-c `-lib-name ""` → OUT; else cold seed |
| `../std/runtime/runtime.o` | `direct` | same R2 DIRECT |
| `../core/slice/slice.o` | `direct` | same R2 DIRECT (glue; formal API stays `mod.o` via xlang_compile) |
| `../std/process/process.o` | `process_merge` | cold: args seed + argv + os_glue `ld -r` |
| `../std/net/net.o` | `net_merge` | sub `.x` + five `net_*_fast` PREFER + final `ld -r`; **PLATFORM: MACOS** force xlang-c for net subs |

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **B2 body** (5 product hybrid → ensure try-std-core-prefer + Makefile thin-call) | ~~B3~~ (wave781) · B4–B5 hybrid bodies · B6 R5 · B7 DAG · physical delete |
| Prior R1–R6 / prefer / pure-ld / prep / Windows+dual-end / B1 | FORCE_CC · Windows PE pure-ld body |

**Forbidden:** physical delete Makefile; claim B2 swallow = physical delete; re-open dual hybrid body on B2 leaves; mac-only wave green (wave778 gate still holds).

### wave779 · B1 runtime_* OS/glue dual hybrid → try-runtime-os-prefer (G.7 有则补全)

> **Not this wave:** physical delete of `compiler/Makefile`; B2–B5 body swallow.  
> **This wave:** swallow **B1** Makefile dual hybrid bodies into ensure `try-runtime-os-prefer` (23 leaves); Makefile keeps thin-call edges only.

```text
Before (wave778):
  Makefile 23× runtime_*.o dual hybrid (PREFER thin+rest / cold seed)
  PHYS_DEL_PREP_NEXT=B1_runtime_os_hybrid_body_swallow_not_delete

After (wave779):
  ensure try-runtime-os-prefer OUT
    table-driven 23 leaves (reuses rt_prefer_try_x_to_o)
    leaf_kind: std | http | ed25519 | tls | net_udp (Linux-only PREFER)
  Makefile 23 leaves: thin-call try-runtime-os-prefer only
  SWALLOWED_B1_RUNTIME_OS_PREFER=1
  PHYS_DEL_BUCKET_B1_BODY_SWALLOWED=1
  PHYS_DEL_PREP_NEXT=B2_std_core_product_hybrid_body_swallow_not_delete
  ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
```

| Leaf specials | Behavior |
|---------------|----------|
| `runtime_http_glue.o` | x under `src/asm/http/`; rest/cold `-Iseeds/http` |
| `runtime_ed25519_ref10_glue.o` | rest/cold `-Isrc/asm` |
| `runtime_tls_mbedtls_bio.o` | rest/cold try homebrew mbedtls `-I` then plain |
| `runtime_net_udp_batch.o` | **PLATFORM: LINUX** PREFER only; macOS cold empty TU |

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **B1 body** (23 dual hybrid → ensure try-runtime-os-prefer + Makefile thin-call) | B2–B5 hybrid bodies · B6 R5 · B7 DAG · physical delete (B2 → wave780) |
| Prior R1–R6 / prefer / pure-ld / prep / Windows+dual-end keys | FORCE_CC · Windows PE pure-ld body |

**Forbidden:** physical delete Makefile; claim B1 swallow = physical delete; re-open dual hybrid body on B1 leaves; mac-only wave green (wave778 gate still holds).

### wave778 · Windows gate + dual-end verify (policy only · G.7 inventory)

> **Not this wave:** physical delete of `compiler/Makefile`; B1–B5 body swallow.  
> **This wave:** hard-gate documentation + dump keys so agents never claim wave green on mac only, and never delete Makefile before Windows hybrid is green.

#### Windows gate (before physical delete)

| Key | Value |
|-----|--------|
| `PHYS_DEL_WINDOWS_GATE` | `required_before_makefile_delete` |
| `PHYS_DEL_WINDOWS_GATE_SCOPE` | MSYS2 B-hybrid min-gate + PE pure-ld residual owned |
| `PHYS_DEL_WINDOWS_GATE_STATUS` | `not_reproven_this_tip` (re-run when dual-boot is Windows) |
| `PHYS_DEL_WINDOWS_GATE_DOC` | `analysis/Windows兼容时序-删种子前后.md` |
| `PHYS_DEL_WINDOWS_GATE_FORBIDDEN` | `physical_delete_makefile_before_windows_green` |

**Allowed without Windows re-prove:** B1–B5 **body swallow** (ensure try-*-prefer / thin-call edges stay; Makefile still present).  
**Forbidden without Windows green:** `rm` / empty / claim endgame delete of `compiler/Makefile`.

#### Dual-end verify (every SHARED MG wave)

| Key | Value |
|-----|--------|
| `MG_VERIFY_DUAL_END` | `mac_plus_ubuntu_required` |
| `MG_VERIFY_GOLD` | `ubuntu` |
| `MG_VERIFY_FORBIDDEN` | `mac_only_claim_wave_green` · `skip_ubuntu_sync_green` |

**Policy (skill G.8 · product gate):**

1. mac residual/matrix green alone is **not** wave green.  
2. After mac commit: `git push` → Ubuntu `git pull --ff-only` → **same** `leaf_pattern_residual.sh --check` (and product L2/L4 when product surface moves).  
3. Ubuntu is the **gold** host for link integrity (mac `-dead_strip` can hide UNDEF).  
4. Windows is **not** the daily MG gold host; it is the **hard gate only before Makefile physical delete**.

```text
PHYS_DEL_WINDOWS_GATE=required_before_makefile_delete
MG_VERIFY_DUAL_END=mac_plus_ubuntu_required
MG_VERIFY_GOLD=ubuntu
ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
PHYS_DEL_PREP_NEXT=B1_runtime_os_hybrid_body_swallow_not_delete
```

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **Policy keys** (Windows gate + dual-end; dump + LEAF + `--check`) | B1–B5 hybrid **bodies** · B6 R5 · B7 DAG · physical delete |
| Prior R1–R6 / prefer / pure-ld / prep inventory | FORCE_CC · Windows PE pure-ld body |

**Forbidden:** mac-only “本波绿”; physical delete before Windows min-gate; body swallow claimed as physical delete.

### wave777 · physical-delete prep inventory (named buckets · G.7 inventory only)

> **Not this wave:** physical delete of `compiler/Makefile`; body swallow of B1–B5 hybrids.  
> **This wave:** name residual **make-owned** host-cc classes that still block 11.3.1 endgame, with heat counts only (not a second `.o` list authority).

Live heat (mac tip · wave777 inventory; counts only):

| Signal | Heat |
|--------|------|
| `$(CC) … -c` recipe lines | ~94 |
| `.o` targets with ensure thin-call | ~79 |
| `.o` targets with inline `$(CC) -c` (no ensure) | **36** |
| of which dual/hybrid PREFER shape | ~25 |

#### PHYS_DEL buckets (leaf dump keys)

| Bucket | Key | Heat targets | Surface (scope names only) | Next swallow shape |
|--------|-----|--------------|----------------------------|--------------------|
| **B1** | `PHYS_DEL_BUCKET_B1` | **23** | `runtime_*` OS/glue dual hybrid (test_fn_invoke…process_os_glue) | ensure try-*-prefer / seed-map family (G.7 有则补全; catalog first) |
| **B2** | `PHYS_DEL_BUCKET_B2` | **5** | `std/{process,path,runtime,net}` + `core/slice` product hybrid | std module shell ensure / xlang_compile path |
| **B3** | `PHYS_DEL_BUCKET_B3` | **2** | `lsp_diag_pipeline_sizes_nostub` · `lsp_diag_stubs_no_c` | extend try-other-l2 / dedicated ensure |
| **B4** | `PHYS_DEL_BUCKET_B4` | **5** | `lexer_x` · `ast_gen2` · `driver_x` · `preprocess_x` · `_x_stubs2` | gen/bootstrap residual (outside try-gen-x catalog) |
| **B5** | `PHYS_DEL_BUCKET_B5` | **1** | `src/lexer/cfg_eval.o` multi-ladder | single-authority ensure ladder |
| **B6** | `PHYS_DEL_BUCKET_B6` | R5 | CI / `compiler-all` host-cc graph | ~~xbuild shell body~~ **wave784** `compiler_all_ci.sh` |
| **B7** | `PHYS_DEL_BUCKET_B7` | DAG | Makefile still owns thin-call edges + mk lists | delete only after B1–B6 + Windows gate + BC no forced `$(CC) -c` |

```text
PHYS_DEL_PREP_INVENTORY=1
PHYS_DEL_PREP_NEXT=B1_runtime_os_hybrid_body_swallow_not_delete
ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
R1_OTHER_HOST_CC_STILL_MAKE=1
```

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **Named prep inventory** (dump + LEAF doc + `--check`) | B1–B5 inline hybrid **bodies** still Makefile |
| Panic PREFER / fmt dual / pure-ld / R1–R4 shell (prior waves) | B6 R5 CI · B7 Makefile DAG · FORCE_CC · Windows PE pure-ld |

**Forbidden:** claim physical delete; treat heat target names as a second catalog; swallow a body without catalog KEY; batch-delete Makefile recipes before BC residual owned.

### wave776 · R2 panic PREFER thin+rest → try-r2-prefer (G.7 有则补全)

```text
Before (wave775):
  Makefile runtime_panic.o dual hybrid on non-pure-asm hosts:
    PREFER=1 + xlang-c → thin.x -o + seed rest FROM_X + ld -r
    else ensure try-r2 cold
  Linux x86_64 + .s: cold-only try-r2 (no PREFER)

After (wave776):
  ensure try-r2-prefer owns PREFER+cold for catalog DRIVER_SEED_PANIC_OBJS
    host PREFER pick mirrors Makefile ifeq (Darwin arm64 PREFER uses portable
    panic.x+from_x; cold still arm64 seed via try-r2 twin)
  Makefile all UNAME branches thin-call try-r2-prefer (no dual hybrid)
```

| Swallowed | Still residual |
|-----------|----------------|
| `runtime_panic.o` Makefile PREFER dual hybrid | ~~physical-delete prep~~ (wave777 named) · R5 CI · Windows PE pure-ld · FORCE_CC named residual |
| Second thin+rest body for panic | non-catalog host-cc leaves still make (B1–B5) |

**Forbidden:** re-open Makefile dual hybrid for `runtime_panic.o`; second prefer body name; hardcode panic `.o` list in shell (catalog KEY only).

## References

- `analysis/C迁移追踪.md` §11.3 · §11.3.1  
- `compiler/docs/BUILD_DAG.md` §5 residual make graph  
- `compiler/docs/PLATFORM_LINKER.md` (R6 / UNAME leaf cross-ref)  
- `compiler/scripts/driver_seed_obj_catalog.sh` (list authority)  
- `compiler/scripts/ensure_host_cc_seed_o.sh` (R1 families + try-r1 + R3 cold-else + thin_glue/glue-standalone + R2 panic/typeck_f64/crt0 try-r2)  
- skill G.7 single authority · G.8 platform tags

## wave793 B7A heat dep-edge thin pure seed+.x+.h residual (2026-07-30)

- **Not physical delete.** Pure seed+.x+.h residual (+19 → **78 FORCE** total): R1/core/frontend/labi/async/target_cpu/simd/lsp… → `FORCE` + ensure.
- Shell owns seed/.x/**project-header** mtime via `seed_project_hdrs_newer` (depth-capped #include BFS under `.|include|src`) in `ensure_one` + prefer skip paths.
- Residual after wave793: twin (scheduler·strict_glue_stubs) · multi-seed (cfg_eval) · Makefile-prereq · asm/gen · std merge · panic stamp.
- LEAF: `DEP_THIN_COUNT=78` · `HEAT_RESIDUAL=1` · `PHYS_DEL_PREP_NEXT=…windows…`.

## wave792 B7A heat dep-edge thin pure seed+.x residual (2026-07-30)

- **Not physical delete.** Pure seed+.x residual (+31 → **59 FORCE** total with wave791): R1/async/rt/alias/L2/lsp/`pipeline_glue_strict_minimal`/… → `FORCE` + ensure; shell mtime.
- **Excluded:** hdr leaves · twin (`runtime_scheduler_glue` · `runtime_driver_strict_glue_stubs`) · `cfg_eval` multi · asm/gen.
- Residual heat: hdr/c/asm/stamp/twin + full non-pilot graph.
- LEAF: `SWALLOWED_B7A_HEAT_DEP_THIN=1` · `DEP_THIN_COUNT=59` · `HEAT_RESIDUAL=1`.
- Next: Windows hybrid green → physical delete; or thin hdr (shell mirror) / asm / twin edges.

## wave791 B7A heat dep-edge thin (2026-07-30)

- **Not physical delete.** Pure `runtime_*` seed+.x leaves (28): Makefile prereqs → `FORCE` + `ensure_host_cc_seed_o.sh`; `try-heat` owns seed/.x mtime.
- Residual after wave791: non-runtime pure seed+.x + hdr/c/asm/stamp + twins.
- LEAF: `SWALLOWED_B7A_HEAT_DEP_THIN=1` · `PHYS_DEL_BUCKET_B7A_HEAT_DEP_THIN=1` · `PHYS_DEL_BUCKET_B7A_HEAT_RESIDUAL=1`.
- Superseded count by wave792 (59).


### wave796 · B7A heat dep-edge thin net multi-merge · panic stamp · gen_x/B4 (G.7 有则补全)

> **Not this wave:** physical delete of `compiler/Makefile`; orch residual edges.
> **This wave:** fold remaining heat dep edges → **FORCE + try-heat** (+11 → **112 FORCE**).

| Leaf class | Shell freshness |
|------------|-----------------|
| `../std/net/net.o` net_merge | multi `.x` + five `runtime_net_*_fast` seed/.x mtime |
| `runtime_panic.o` | try-r2 host pick + platform stamp (UNAME ifeq prereqs removed) |
| gen_x catalog + B4 | try-heat → try-gen-x / try-gen-c-to-o (`PIPELINE_X_DEPS` env; `lsp_io.x`) |

| Swallowed | Still residual |
|-----------|----------------|
| net multi-merge · panic stamp · gen_x/B4 FORCE thin | orch · physical delete after Windows |

LEAF: `PHYS_DEL_BUCKET_B7A_HEAT_DEP_THIN_COUNT=112` · `B7A_HEAT_DEP_THIN_WAVE=wave796`.

## wave797 B7A heat dep-edge thin orch (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile` (Windows hybrid min-gate still required).
> **This wave:** last heat source-prereq leaf → **FORCE + try-heat** (+1 → **113 FORCE**).

| Leaf class | Shell freshness |
|------------|-----------------|
| `pipeline_bootstrap_orchestration.o` | seed/.x + `pipeline_gen.c` + `build_asm/pipeline_glue_types.inc` (ensure_one twin) |

| Swallowed | Still residual |
|-----------|----------------|
| orch FORCE thin · all heat source-prereq edges | physical delete after Windows only |

LEAF: `PHYS_DEL_BUCKET_B7A_HEAT_DEP_THIN_COUNT=113` · `HEAT_RESIDUAL=0` · `B7A_HEAT_DEP_THIN_WAVE=wave797`.

## wave798 physical-delete preflight readiness (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; Windows hybrid min-gate re-prove.  
> **This wave:** G.7 **readiness inventory** after heat source-prereq closed (wave797). Names blockers
> and the Windows min-gate authority command. Does **not** flip `PHYS_DEL_WINDOWS_GATE_STATUS`
> (stays `not_reproven_this_tip`) and does **not** set `ENDGAME_PHYSICAL_DELETE_MAKEFILE=1`.

```text
Ready (prep closed):
  B1–B6 body swallowed · B7D g05 · B7A cold residual_make=0 · B7B shell catalog
  B7A heat try-heat / thin-unify / dep-thin FORCE 113 · HEAT_RESIDUAL=0

Blockers (PHYS_DEL_PREFLIGHT_BLOCKERS):
  windows_min_gate_not_reproven
  makefile_thin_call_edges          # intentional until phys del
  b7b_lists_in_mk                   # G.7 list authority stays mk
  std_core_product_make_graph       # std/core product .o still Makefile

Windows re-prove (dual-boot must be Windows / MSYS2):
  git pull --ff-only
  ./tests/run-bootstrap-bstrict-windows-gate.sh   # B-hybrid default
  # then flip PHYS_DEL_WINDOWS_GATE_STATUS + dual-end residual --check
  # only then physical delete of compiler/Makefile
```

| Key | Value |
|-----|--------|
| `PHYS_DEL_PREFLIGHT` | `1` |
| `PHYS_DEL_PREFLIGHT_WAVE` | `wave798` |
| `PHYS_DEL_PREFLIGHT_FORCE_DEP_THIN` | `113` |
| `PHYS_DEL_PREFLIGHT_NEXT` | `windows_hybrid_min_gate_on_msys2_then_physical_delete` |
| `PHYS_DEL_WINDOWS_GATE_STATUS` | `not_reproven_this_tip` (honest) |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `0` |

**Forbidden:** claim preflight = physical delete / Windows green; delete Makefile before Windows min-gate; mac-only wave green.

**Dual-end leaf `--check` portability (same wave):** GNU grep ERE does not treat `\t` as TAB
(mac BSD often does). Heat recipe counts use `$'\t'` + `grep -c … || true` (never
`|| echo 0`, which yields `0\n0` on no-match and breaks integer tests on Ubuntu).

## wave799 physical-delete execute gate (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; Windows hybrid min-gate re-prove.  
> **This wave:** G.7 **execute gate** body — `compiler/scripts/phys_del_makefile_gate.sh`.
> Hard-refuses `rm` of Makefile while `PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip`.
> Dry-run inventory + MSYS2 runbook. Does **not** flip Windows green; does **not** delete.

```text
Entry:
  ./xbuild phys-del-gate                 # status dump
  ./xbuild phys-del-gate --check         # refuse contract + preflight honesty
  ./xbuild phys-del-gate --dry-run-delete
  ./xbuild phys-del-gate --run-windows-gate   # MSYS2 only; non-MSYS skip 0
  ./xbuild phys-del-gate --delete        # always refuse this tip

After Windows green (human dual-boot reboot → MSYS2 min-gate):
  mac commit flips PHYS_DEL_WINDOWS_GATE_STATUS + physical delete wave
  (execute-gate still never auto-rm without reviewed ENDGAME=1 + confirm env)
```

| Key | Value |
|-----|--------|
| `PHYS_DEL_EXECUTE_GATE` | `1` |
| `PHYS_DEL_EXECUTE_GATE_WAVE` | `wave799` |
| `PHYS_DEL_EXECUTE_GATE_SCRIPT` | `compiler/scripts/phys_del_makefile_gate.sh` |
| `PHYS_DEL_EXECUTE_GATE_REFUSES_DELETE` | `1` |
| `PHYS_DEL_EXECUTE_GATE_DELETE_ALLOWED` | `0` |
| `PHYS_DEL_WINDOWS_GATE_STATUS` | `not_reproven_this_tip` (honest) |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `0` |

**Forbidden:** claim execute-gate = physical delete / Windows green; delete Makefile before Windows min-gate; mac-only wave green.

## wave800 Windows min-gate proof stamp harness (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; flip `PHYS_DEL_WINDOWS_GATE_STATUS` to green.  
> **This wave:** G.7 **有则补全** on `phys_del_makefile_gate.sh` — machine-checkable *evidence*
> stamp after MSYS2 hybrid min-gate green. Proof ≠ STATUS flip. Proof ≠ physical delete.
> Mac/Ubuntu can `--verify-windows-proof` a stamp scp'd from Windows (tip SHA must match HEAD).

```text
Entry:
  ./xbuild phys-del-gate --run-windows-gate
      # MSYS2 only: runs tests/run-bootstrap-bstrict-windows-gate.sh
      # on exit 0 writes /tmp/xlang_phys_del_windows_proof.txt (or XLANG_PHYS_DEL_WINDOWS_PROOF)
  # After Windows git pull --ff-only (NEVER scp source tree): transfer PROOF only
  scp windows-server:/tmp/xlang_phys_del_windows_proof.txt /tmp/
  ./xbuild phys-del-gate --verify-windows-proof
      # exit 0 = tip match + RC=0; exit 2 = missing/mismatch
      # does NOT flip PHYS_DEL_WINDOWS_GATE_STATUS

After verified evidence + human review:
  mac commit flips PHYS_DEL_WINDOWS_GATE_STATUS + physical delete wave
  (never auto-flip leaf keys from stamp alone)
```

| Key | Value |
|-----|--------|
| `PHYS_DEL_WINDOWS_PROOF_HARNESS` | `1` |
| `PHYS_DEL_WINDOWS_PROOF_HARNESS_WAVE` | `wave800` |
| `PHYS_DEL_WINDOWS_PROOF_DEFAULT_PATH` | `/tmp/xlang_phys_del_windows_proof.txt` |
| `PHYS_DEL_WINDOWS_PROOF_STATUS_FLIP` | `0` |
| `PHYS_DEL_WINDOWS_PROOF_DELETE_ALLOWED` | `0` |
| `PHYS_DEL_WINDOWS_GATE_STATUS` | `not_reproven_this_tip` (honest) |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `0` |

**Forbidden:** claim proof = STATUS green / physical delete; auto-flip leaf from stamp; delete Makefile from proof alone; mac-only wave green.

**Dual-end leaf `--check` portability (wave800b):** under `set -o pipefail`,
`printf large_dump | grep -q` can fail with SIGPIPE(141) even when the key
matches (grep exits early). Checks use `grep … <<<"$_out"` instead.
Same for `phys_del_makefile_gate.sh` status/leaf probes.

## wave805 ENDGAME arm prep / preview (2026-07-30)

> **Not this wave:** set `ENDGAME_PHYSICAL_DELETE_MAKEFILE=1`; physical delete of
> `compiler/Makefile`; claim delete allowed.  
> **This wave:** G.7 **有则补全** on `phys_del_makefile_gate.sh` —
> `--endgame-preview` after STATUS=`reproven_green` prints the machine-readable
> plan for a reviewed ENDGAME=1 arm commit. Preview never edits leaf. Preview ≠
> arm. Preview ≠ physical delete. Tree ENDGAME stays 0 · `TREE_ARMED=0` ·
> `--delete` still hard-refuses. Dual-end L2 required (mac + Ubuntu).

```text
Entry (STATUS already reproven_green after wave804):
  ./xbuild phys-del-gate --endgame-preview
      # exit 0 + PHYS_DEL_ENDGAME_PREVIEW_READY=1 when STATUS green
      # exit 2 when STATUS not_reproven (temp leaf / pre-flip)
      # APPLIED=0 always; TREE_ARMED=0 always; no leaf mutation

Then (later waves, not this tip):
  dual-end L2 → reviewed ENDGAME=1 arm → confirm --delete body
```

| Key | Value |
|-----|--------|
| `PHYS_DEL_ENDGAME_PREP` | `1` |
| `PHYS_DEL_ENDGAME_PREP_WAVE` | `wave805` |
| `PHYS_DEL_ENDGAME_PREP_MODE` | `--endgame-preview` |
| `PHYS_DEL_ENDGAME_PREP_APPLIED` | `0` |
| `PHYS_DEL_ENDGAME_PREP_TREE_ARMED` | `0` |
| `PHYS_DEL_ENDGAME_PREP_TARGET_ENDGAME` | `1` |
| `PHYS_DEL_ENDGAME_PREP_DELETE_ALLOWED` | `0` |
| `PHYS_DEL_WINDOWS_GATE_STATUS` | `reproven_green` (wave804) |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `0` |
| `PHYS_DEL_PREFLIGHT_NEXT` | `endgame_arm_apply_tree_then_confirm_delete_separate` (wave806) |

**Forbidden:** claim endgame-preview = ENDGAME arm / physical delete; set
ENDGAME=1 in this wave; `rm compiler/Makefile`; mac-only wave green.

## wave832 migrate companion FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on the three migrate companion object
> leaves that still listed gen as make-graph prereqs after gen FORCE
> (wave829) and src-edge FORCE (wave831):
>
> 1. **parser / typeck / codegen companion leaves** (3) — drop gen prereq;
>    target is `FORCE scripts/migrate_x_objs.sh` only; recipe stays
>    `sh scripts/migrate_x_objs.sh {parser|typeck|codegen}`.
> 2. **`migrate_x_objs.sh`** already owns gen freshness (`need_rebuild` +
>    `XLANG_MIGRATE_FORCE`) and may call `ensure_migrate_gen` (wave736) —
>    no second mtime body.
>
> Honesty COUNT = **3**. Residual after: ~~`pipeline_glue_types.inc`~~ (wave833) ·
> thin edges + B2 + mk lists. Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_MIGRATE_X_FORCE_THIN=1
    PHYS_DEL_MIGRATE_X_FORCE_THIN_WAVE=wave832
    PHYS_DEL_MIGRATE_X_FORCE_THIN_COUNT=3
    SWALLOWED_MIGRATE_X_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_MIGRATE_X_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: e04244dbf (Mac + Ubuntu leaf --check;
    migrate companion 3 FORCE; need_rebuild mtime; sample make OK)
  next: ~~pipeline_glue_types FORCE~~ (wave833) · thin edges / B2 or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_MIGRATE_X_FORCE_THIN` | `1` |
| `PHYS_DEL_MIGRATE_X_FORCE_THIN_COUNT` | `3` |
| `SWALLOWED_MIGRATE_X_FORCE_THIN` | `1` |
| `MIGRATE_X_FORCE_THIN_HELPER` | `migrate_x_objs.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim migrate FORCE thin = physical delete; re-list gen on
Makefile prereq lines for these 3 companion leaves; `rm compiler/Makefile`;
ship delete body; mac-only wave green.

## wave833 pipeline_glue_types FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **无才新增** shell body for the last extract make-graph
> edge — `build_asm/pipeline_glue_types.inc` drops `pipeline_gen.c` +
> `extract_pipeline_glue_types.pl` make prereqs; target is
> `FORCE scripts/ensure_pipeline_glue_types.sh` only; recipe thin-calls ensure
> (bash, dash-safe). Shell owns:
>
> - mtime skip (`pipeline_gen.c` / extract.pl vs types.inc; `-nt`)
> - `XLANG_GLUE_TYPES_FORCE=1` always re-extract
> - i64 ABI guard call (`check_pipeline_gen_expr_i64_abi.sh`) before extract
> - extract algorithm remains `extract_pipeline_glue_types.pl` (not reimplemented)
>
> Honesty COUNT = **1**. Residual after: ~~bootstrap-pipeline~~ (wave834) +
> thin-call edges + B2 + mk lists. Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_GLUE_TYPES_FORCE_THIN=1
    PHYS_DEL_GLUE_TYPES_FORCE_THIN_WAVE=wave833
    PHYS_DEL_GLUE_TYPES_FORCE_THIN_COUNT=1
    SWALLOWED_GLUE_TYPES_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_GLUE_TYPES_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 6d08997ad (Mac + Ubuntu leaf --check;
    glue_types FORCE; need_rebuild mtime; sample make OK)
  next: ~~bootstrap-pipeline~~ (wave834)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_GLUE_TYPES_FORCE_THIN` | `1` |
| `PHYS_DEL_GLUE_TYPES_FORCE_THIN_COUNT` | `1` |
| `SWALLOWED_GLUE_TYPES_FORCE_THIN` | `1` |
| `GLUE_TYPES_FORCE_THIN_HELPER` | `ensure_pipeline_glue_types.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim glue-types FORCE thin = physical delete; re-list
`pipeline_gen.c` / extract.pl on Makefile prereq for this leaf;
`rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave834 bootstrap-pipeline FORCE shell-primary (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** — `bootstrap-pipeline` phony drops
> make-graph prereq on `pipeline_gen.c` file; target is
> `FORCE scripts/ensure_lsp_pipeline_gen.sh` only; recipe thin-calls
> `bash scripts/ensure_lsp_pipeline_gen.sh pipeline` (dash-safe bash).
> Body authority remains wave739 `ensure_pipeline_gen` (pin / seed / force -E
> + i64 ABI). Always-run when the phony is requested (make file-prereq used to
> skip ensure when pin existed).
>
> Honesty COUNT = **1**. Residual after: ~~filtered.o~~ (wave835) + thin-call
> edges + B2 + mk lists (std_core_product_make_graph). Dual-end L2 required.
> Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN=1
    PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_WAVE=wave834
    PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_COUNT=1
    SWALLOWED_BOOTSTRAP_PIPELINE_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_BOOTSTRAP_PIPELINE_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 92536f727 (Mac + Ubuntu leaf --check;
    bootstrap-pipeline FORCE; sample make bootstrap-pipeline OK)
  next: ~~filtered.o FORCE~~ (wave835)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN` | `1` |
| `PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_COUNT` | `1` |
| `SWALLOWED_BOOTSTRAP_PIPELINE_FORCE_THIN` | `1` |
| `BOOTSTRAP_PIPELINE_FORCE_THIN_HELPER` | `ensure_lsp_pipeline_gen.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim bootstrap-pipeline FORCE thin = physical delete; re-list
`pipeline_gen.c` as make-graph prereq on `bootstrap-pipeline`;
`rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave835 bootstrap_seed filtered.o FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** — four class-G
> `build_asm/bootstrap_seed_*_filtered.o` leaves drop SRC / partial /
> strict_minimal make-graph prereqs; each target is
> `FORCE scripts/filter_bootstrap_seed_*.sh` only; recipe thin-calls
> `bash … ensure $@` (dash-safe bash).
>
> Shell authority (single body shared with g05):
> - **3×** `filter_bootstrap_seed_against_partial_o.sh ensure` — catalog
>   OUT→SRC|STEM; try-heat SRC; mtime vs SRC+partial; `XLANG_FILTER_FORCE`
> - **1×** `filter_bootstrap_seed_pipeline_o.sh ensure` — try-heat
>   `pipeline_x.o` + `pipeline_glue_strict_minimal.o`; mtime vs SRC+omits
> - Body remains `filter_o_export_against_deps.sh` (G.7 nm/ld -r)
>
> Honesty COUNT = **4**. Residual after: thin-call edges + B2 + mk lists
> (std_core_product_make_graph). Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_FILTERED_O_FORCE_THIN=1
    PHYS_DEL_FILTERED_O_FORCE_THIN_WAVE=wave835
    PHYS_DEL_FILTERED_O_FORCE_THIN_COUNT=4
    SWALLOWED_FILTERED_O_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_FILTERED_O_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: cd314928a (Mac + Ubuntu leaf --check;
    filter --check; XLANG_FILTER_FORCE ensure partial+pipeline OK)
  next: ~~cp-alias FORCE~~ (wave836) · thin edges / B2 or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body (explicit auth only)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_FILTERED_O_FORCE_THIN` | `1` |
| `PHYS_DEL_FILTERED_O_FORCE_THIN_COUNT` | `4` |
| `SWALLOWED_FILTERED_O_FORCE_THIN` | `1` |
| `FILTERED_O_FORCE_THIN_HELPER` | `filter_bootstrap_seed_against_partial_o+filter_bootstrap_seed_pipeline_o` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim filtered.o FORCE thin = physical delete; re-list SRC
`.o` / partial as make-graph prereq on filtered leaves; dual nm/ld filter body;
`rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave836 product object-path cp-alias FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **无才新增** — product object-path **cp-alias** leaves
> that still listed SRC `.o` as make-graph prereqs after heat FORCE (wave791–797)
> and freestanding heat thin:
>
> 1. `ast_x.o` ← `src/ast/ast_seed.o` (SHARED G-02a C ABI alias)
> 2. `crt0_user.o` ← `src/asm/crt0_user_x86_64.o` (x86_64 freestanding link name)
> 3. `freestanding_io.o` ← `src/asm/freestanding_io_x86_64.o`
>
> Target is `FORCE scripts/ensure_cp_alias_o.sh` only; recipe thin-calls
> `bash … ensure $@`. Shell owns catalog, try-heat SRC when missing, mtime skip
> (`SRC -nt OUT`; `XLANG_CP_ALIAS_FORCE=1` always recopy). Honesty COUNT = **3**.
> Residual after: thin-call edges + B2 + mk lists. Dual-end L2 required.
> Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_CP_ALIAS_FORCE_THIN=1
    PHYS_DEL_CP_ALIAS_FORCE_THIN_WAVE=wave836
    PHYS_DEL_CP_ALIAS_FORCE_THIN_COUNT=3
    SWALLOWED_CP_ALIAS_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_CP_ALIAS_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: bdeed8b98 (Mac + Ubuntu leaf --check;
    ensure_cp_alias --check; FORCE ensure ast+x86_64 wrappers OK)
  next: ~~pipeline_gen.c FORCE~~ (wave837) · thin edges / B2 or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_CP_ALIAS_FORCE_THIN` | `1` |
| `PHYS_DEL_CP_ALIAS_FORCE_THIN_COUNT` | `3` |
| `SWALLOWED_CP_ALIAS_FORCE_THIN` | `1` |
| `CP_ALIAS_FORCE_THIN_HELPER` | `ensure_cp_alias_o.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim cp-alias FORCE thin = physical delete; re-list SRC `.o` on
Makefile prereq lines for these 3 leaves; `rm compiler/Makefile`; ship delete
body; mac-only wave green.

## wave837 pipeline_gen.c FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** — the last empty-prereq **file target**
> gen leaf after wave829 (17 `*_gen.c` FORCE) and wave834 (`bootstrap-pipeline`
> FORCE phony). `pipeline_gen.c` drops empty prereq; target is
> `FORCE scripts/ensure_lsp_pipeline_gen.sh` only; recipe thin-calls
> `bash … pipeline` (dash-safe bash).
>
> Body authority remains wave739 `ensure_pipeline_gen` (pin / seed / force -E +
> always-run i64 ABI). FORCE means make no longer skips the recipe when the pin
> file exists — shell still cheap-skips regen unless `XLANG_FORCE_REGEN_GEN=1`.
>
> Honesty COUNT = **1**. Residual after: thin-call edges + B2 + mk lists
> (`std_core_product_make_graph`). Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_PIPELINE_GEN_FORCE_THIN=1
    PHYS_DEL_PIPELINE_GEN_FORCE_THIN_WAVE=wave837
    PHYS_DEL_PIPELINE_GEN_FORCE_THIN_COUNT=1
    SWALLOWED_PIPELINE_GEN_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_PIPELINE_GEN_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 22fbf5b47 (Mac + Ubuntu leaf --check;
    FORCE ensure pipeline pin + bootstrap-pipeline OK)
  next: ~~bootstrap_xlangc FORCE~~ (wave838) · thin edges / B2 or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body (explicit auth only)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_PIPELINE_GEN_FORCE_THIN` | `1` |
| `PHYS_DEL_PIPELINE_GEN_FORCE_THIN_COUNT` | `1` |
| `SWALLOWED_PIPELINE_GEN_FORCE_THIN` | `1` |
| `PIPELINE_GEN_FORCE_THIN_HELPER` | `ensure_lsp_pipeline_gen.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim pipeline_gen FORCE thin = physical delete; re-open empty
prereq on `pipeline_gen.c`; dual pin policy outside ensure; `rm compiler/Makefile`;
ship delete body; mac-only wave green.

## wave838 bootstrap_xlangc FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** — G-06 cold-egg **file target** residual
> after wave837 (pipeline_gen empty-prereq closed). `bootstrap_xlangc` drops
> `bootstrap_xlangc_create.sh` make-graph edge; target is
> `FORCE scripts/select_bootstrap_xlangc.sh` only; recipe thin-calls
> `bash … select_bootstrap_xlangc.sh` (dash-safe bash).
>
> Body authority remains `select_bootstrap_xlangc.sh` (host OS/arch seed pick /
> `can_run` skip / optional create via select when no runnable seed). FORCE means
> make always re-enters; shell still cheap-skips when current egg runs.
>
> Honesty COUNT = **1**. Residual after: thin-call edges + B2 + mk lists
> (`std_core_product_make_graph`). Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN=1
    PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN_WAVE=wave838
    PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN_COUNT=1
    SWALLOWED_BOOTSTRAP_XLANGC_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_BOOTSTRAP_XLANGC_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 6de346cf5 (Mac + Ubuntu leaf --check;
    make bootstrap_xlangc host seed pick OK)
  next: ~~archaeology host-pick FORCE~~ (wave839) · thin edges / B2 or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body (explicit auth only)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN` | `1` |
| `PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN_COUNT` | `1` |
| `SWALLOWED_BOOTSTRAP_XLANGC_FORCE_THIN` | `1` |
| `BOOTSTRAP_XLANGC_FORCE_THIN_HELPER` | `select_bootstrap_xlangc.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim bootstrap_xlangc FORCE thin = physical delete; re-list
`bootstrap_xlangc_create.sh` on Makefile prereq; dual host-pick outside select;
`rm compiler/Makefile`; ship delete body; mac-only wave green.


## wave864 B7B leaf-extra RUNTIME_*/PARSER_* CFLAGS hygiene (2026-07-30)

> **Why (G.7 有则补全 on wave753/794/862 residual):**
> Product try-heat thin-call still injected multi-token leaf-extra bags:
> `RUNTIME_PIPELINE_ABI_CFLAGS="$(…)"`, `RUNTIME_DRIVER_NO_C_CFLAGS="$(…)"`,
> `PARSER_ASM_THIN_GLUE_CFLAGS="$(…)"`. Shell already owns
> `_DEFAULT_RUNTIME_PIPELINE_ABI_CFLAGS` / `_DEFAULT_RUNTIME_DRIVER_NO_C_CFLAGS` /
> `_DEFAULT_PARSER_ASM_THIN_GLUE_CFLAGS` when env unset (same pattern as
> `runtime_driver.o` / wave862 try-heat CFLAGS). Recipe inject was residual
> make-escape noise + dual-authority with LEGACY ifeq bags (LEGACY preprocess path dead).
>
> **Leaves (COUNT=3):**
>   - `src/runtime_pipeline_abi.o` (R1_EXTRA_CFLAGS)
>   - `src/runtime_driver_no_c.o` (R1_MAIN_RUNTIME)
>   - `parser_asm_thin_glue.o` (R1 seed-map)
>
> Makefile thin-call: `CC=` (+ optional PREFER) only; ensure shell defaults are authority.
> Makefile may keep flag *variable definitions* for `force_thin_makefile_flags_newer` / docs.
> **NOT physical delete** — thin edges + B2 + remaining mk lists remain.
> Dual-end L2 required.
>
```text
    PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE=1
    PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE_WAVE=wave864
    PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE_COUNT=3
    SWALLOWED_B7B_LEAF_EXTRA_CFLAGS_HYGIENE=1
    PHYS_DEL_PREFLIGHT_B7B_LEAF_EXTRA_CFLAGS_HYGIENE=1
```
>
> next: ~~migrate/bootstrap CFLAGS~~ wave865 · residual thin/B2/lists or tip Windows → dual L4 → explicit auth ship

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE` | `1` |
| `PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE_COUNT` | `3` |
| `SWALLOWED_B7B_LEAF_EXTRA_CFLAGS_HYGIENE` | `1` |
| `B7B_LEAF_EXTRA_CFLAGS_HYGIENE_VIA` | `ensure_shell_defaults_no_recipe_inject` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim leaf-extra CFLAGS hygiene = physical delete; reintroduce multi-token
`RUNTIME_PIPELINE_ABI_CFLAGS="$(…)"` / `RUNTIME_DRIVER_NO_C_CFLAGS="$(…)"` /
`PARSER_ASM_THIN_GLUE_CFLAGS="$(…)"` on product try-heat recipes; drop shell `_DEFAULT_*`
without a single replacement authority; mac-only wave green.

## wave865 B7B migrate/bootstrap CFLAGS shell-load (2026-07-30)

> **Why (G.7 有则补全 on wave862 export-try-heat-cflags):**
> After wave862/863/864 try-heat + filter + leaf-extra hygiene, migrate companion
> and archaeology bootstrap shells still required multi-token
> `CFLAGS="$(CFLAGS)"` on Makefile thin-call recipes. Product CFLAGS need make
> expansion (`OPT += -O2`, `-I` bags); dual recipe inject was residual
> make-escape noise vs shell-load authority already used by try-heat.
>
> **Recipes (COUNT=8):**
>   - `parser_x.o` / `typeck_x.o` / `codegen_x.o` / `migrate-x-objs` → `migrate_x_objs.sh`
>   - `bootstrap-typeck` / `bootstrap-codegen` → `bootstrap_typeck_codegen.sh` (no empty `CFLAGS=` into migrate)
>   - `xlang-x-pipeline` / `bootstrap-x-compiler` → host-cc link base CFLAGS
>
> Shells load `export-try-heat-cflags` when `CFLAGS` / `PIPELINE_GEN_CFLAGS` unset.
> Makefile thin-call: `CC=` / `PYTHON=` / `MAKE=` / `TARGET=` only (no multi-token CFLAGS=).
> Residual: ~~build-tool / WIN32_O~~ wave866; thin·B2 + mk lists hybrid remain.
> **NOT physical delete** — thin edges + B2 + mk lists remain. Dual-end L2 required.
>
```text
    PHYS_DEL_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD=1
    PHYS_DEL_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD_WAVE=wave865
    PHYS_DEL_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD_COUNT=8
    SWALLOWED_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD=1
    PHYS_DEL_PREFLIGHT_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD=1
```
>
> next: ~~build-tool / WIN32 multi-token~~ wave866 · residual thin/B2 / mk lists hybrid
> or tip Windows → dual L4 → explicit auth ship

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD` | `1` |
| `PHYS_DEL_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD_COUNT` | `8` |
| `SWALLOWED_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD` | `1` |
| `B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD_VIA` | `export_try_heat_cflags_migrate_xxp_bxc_btc` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim migrate/bootstrap CFLAGS shell-load = physical delete; reintroduce
multi-token `CFLAGS="$(CFLAGS)"` on migrate/BTC/XXP/BXC recipes; pass empty
`CFLAGS=` into `migrate_x_objs` (blocks export leaf load); mac-only wave green.

## wave866 B7B build-tool CFLAGS shell-load + WIN32_O leaf drop (2026-07-30)

> **Why (G.7 有则补全 on wave862/865 export-try-heat-cflags):**
> After wave865 closed migrate/bootstrap multi-token `CFLAGS="$(CFLAGS)"`, residual
> multi-token env injects remained on:
>   - **build-tool** thin phony: `CFLAGS='$(CFLAGS)'` into `build_tool.sh`
>   - **crt0_mingw** Windows leaf: `WIN32_O_CFLAGS="$(WIN32_O_CFLAGS)"` (no Makefile
>     `?=` composition — always empty bag noise)
>
> Product CFLAGS still need make expansion (`OPT += -O2`, clang silence ifeq) for
> build_tool host-cc; shell loads `export-try-heat-cflags` when unset (same leaf
> as try-heat / migrate). WIN32_O has no make composition — env empty default
> `${WIN32_O_CFLAGS:-}` is the authority when caller does not set it.
>
> **Recipes (COUNT=2):**
>   - `build-tool` → `build_tool.sh` (shell-load CFLAGS; `--check` honesty)
>   - `src/asm/crt0_mingw.o` → `ensure try-heat` (CC= only; WINDOWS ifeq)
>
> Makefile thin-call: `CC=` / `XLANG_BUILD_TOOL_REGEN=` only on build-tool;
> crt0_mingw `CC=` only. Residual: thin·B2 / mk lists hybrid.
> **NOT physical delete** — thin edges + B2 + mk lists remain. Dual-end L2 required.
>
```text
    PHYS_DEL_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE=1
    PHYS_DEL_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE_WAVE=wave866
    PHYS_DEL_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE_COUNT=2
    SWALLOWED_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE=1
    PHYS_DEL_PREFLIGHT_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE=1
```
>
> next: residual thin/B2 / mk lists hybrid or tip Windows → dual L4 → explicit auth ship

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE` | `1` |
| `PHYS_DEL_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE_COUNT` | `2` |
| `SWALLOWED_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE` | `1` |
| `B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE_VIA` | `export_try_heat_cflags_build_tool_win32_empty_default` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim build-tool/WIN32 CFLAGS hygiene = physical delete; reintroduce
multi-token `CFLAGS='$(CFLAGS)'` on build-tool or `WIN32_O_CFLAGS="$(…)"` on
crt0_mingw; mac-only wave green.

## wave863 B7B filter CFLAGS shell-load hygiene (2026-07-30)

> **Why (G.7 有则补全 on wave835/862):**
> wave835 class-G four filtered.o leaves already FORCE+filter scripts, but Makefile
> still injected multi-token
> `CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)"`.
> wave862 try-heat shell-loads `export-try-heat-cflags` when unset — filter
> scripts must not pass empty `CFLAGS=` (set-but-empty blocks that load).
>
> **Leaves (COUNT=4):**
>   - `bootstrap_seed_backend_x86_64_enc_c_filtered.o`
>   - `bootstrap_seed_user_asm_seed_bridge_filtered.o`
>   - `bootstrap_seed_asm_backend_compat_stubs_filtered.o`
>   - `bootstrap_seed_pipeline_filtered.o`
>
> Makefile thin-call `CC=` only; filter scripts invoke try-heat with CC only.
> **NOT physical delete** — thin edges + B2 + leaf-extra + mk lists remain.
> Dual-end L2 required.
>
```text
    PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD=1
    PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD_WAVE=wave863
    PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD_COUNT=4
    SWALLOWED_B7B_FILTER_CFLAGS_SHELL_LOAD=1
    PHYS_DEL_PREFLIGHT_B7B_FILTER_CFLAGS_SHELL_LOAD=1
```
>
> next: ~~leaf-extra RUNTIME_*/PARSER_*~~ wave864 · residual thin/B2/lists or tip Windows → dual L4 → explicit auth ship

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD` | `1` |
| `PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD_COUNT` | `4` |
| `SWALLOWED_B7B_FILTER_CFLAGS_SHELL_LOAD` | `1` |
| `B7B_FILTER_CFLAGS_SHELL_LOAD_VIA` | `filter_try_heat_cc_only+export_try_heat_cflags` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim filter CFLAGS hygiene = physical delete; reintroduce multi-token
`CFLAGS="$(CFLAGS)"` on filter ensure recipes; pass empty `CFLAGS=` into try-heat
from filter scripts (blocks wave862 shell-load).

## wave861 B7B rt_* multi-token -I CFLAGS hygiene (2026-07-30)

> **Why (G.7 有则补全 on heat thin-call hygiene):**
> wave748/792 `RT_SEED_SLICE` five leaves (`rt_arena_buf` / `rt_emit_state` /
> `rt_preamble` / `rt_stack` / `rt_parse_diag`) already FORCE+try-heat, but
> Makefile still injected multi-token
> `CFLAGS="$(CFLAGS) -I. -Iinclude -Isrc"`. Product `-I` already lives in
> `CFLAGS ?=` and shell `BASE_CFLAGS` default — dual bag was make-escape noise
> vs sibling try-heat leaves (`runtime_x.o` etc. use plain `CFLAGS="$(CFLAGS)"`).
>
> **Leaves (COUNT=5):** drop multi-token `-I` append; plain
> `CFLAGS="$(CFLAGS)" PIPELINE_GEN_CFLAGS="$(PIPELINE_GEN_CFLAGS)"` only.
> **NOT physical delete** — thin edges + B2 try-heat + mk lists remain.
> Dual-end L2 required.
>
```text
    PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE=1
    PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE_WAVE=wave861
    PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE_COUNT=5
    SWALLOWED_B7B_RT_SLICE_I_CFLAGS_HYGIENE=1
    PHYS_DEL_PREFLIGHT_B7B_RT_SLICE_I_CFLAGS_HYGIENE=1
```
>
> next: ~~try-heat CFLAGS bulk~~ wave862 · ~~filter CFLAGS~~ wave863 · residual
> leaf-extra / lists or tip Windows → dual L4 → explicit auth ship

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE` | `1` |
| `PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE_COUNT` | `5` |
| `SWALLOWED_B7B_RT_SLICE_I_CFLAGS_HYGIENE` | `1` |
| `B7B_RT_SLICE_I_CFLAGS_HYGIENE_VIA` | `plain_cflags_try_heat` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim -I hygiene = physical delete; reintroduce multi-token
`CFLAGS="$(CFLAGS) -I…"` on heat recipes; dual product -I formula outside
`CFLAGS ?=` / shell `BASE_CFLAGS` default.

## wave860 B7B driver_leaf BASE_CFLAGS multi-token shell-load (2026-07-30)

> **Why (G.7 有则补全 on wave857/859 export-leaf pattern):**
> wave814/828 driver_leaf catalog already shell-primary (8 leaves FORCE+ensure),
> but Makefile still injected multi-token
> `BASE_CFLAGS="$(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc"`.
> Composition needs make expansion (`OPT` → `CFLAGS += -O2`;
> `PIPELINE_GEN_CFLAGS` CC_IS_CLANG ifeq) — not pure shell default.
>
> **Bags (1 export / 8 leaves):**
>   - **export-driver-leaf-base-cflags** → `BASE_CFLAGS=$(CFLAGS) $(PIPELINE_GEN_CFLAGS) -I. -Iinclude -Isrc`
>
> Shell loads when env unset; Makefile recipes drop multi-token `BASE_CFLAGS=` env
> (thin-call `MAKE= ensure` only). **NOT physical delete** — thin edges + B2 + mk
> lists remain. Dual-end L2 required.
>
```text
    PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD=1
    PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_WAVE=wave860
    PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_COUNT=8
    SWALLOWED_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD=1
    PHYS_DEL_PREFLIGHT_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD=1
```
>
> next: ~~rt_* multi-token -I~~ (wave861) · residual thin/B2/lists or tip Windows

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD` | `1` |
| `PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_COUNT` | `8` |
| `SWALLOWED_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD` | `1` |
| `B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_VIA` | `export_driver_leaf_base_cflags` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim BASE_CFLAGS shell-load = physical delete; dual multi-token
`BASE_CFLAGS=` recipe env; second CFLAGS formula authority in shell (export leaf only).

## wave859 B7B XXP/BXC multi-token bag shell-load (2026-07-30)

> **Why (G.7 有则补全 on wave856 export-leaf pattern):**
> wave845 `xlang-x-pipeline` / wave842 `bootstrap-x-compiler` already shell-primary
> bodies, but Makefile still injected multi-token `XXP_*=` / `BXC_LINK_OBJS=` bags.
> LINK needs make expansion (`$(USER_ASM_LINK)` nested + `PIPELINE_LIBS` platform
> ifeq; `OBJS` platform ifeq) — not pure mk text.
>
> **Bags (2 shells):**
>   - **XXP** — `export-xxp-link-bags` → BASE/FRONTEND/LINK/SATELLITE/LSP_DIAG/LIBS
>   - **BXC** — `export-bxc-link-objs` → `LINK_OBJS=$(OBJS)`
>
> Shell loads when env unset; Makefile recipes drop multi-token XXP_*/BXC_ env.
> **NOT physical delete** — thin edges + B2 + mk lists remain. Dual-end L2 required.
>
```text
    PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD=1
    PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD_WAVE=wave859
    PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD_COUNT=2
    SWALLOWED_B7B_XXP_BXC_SHELL_LOAD=1
    PHYS_DEL_PREFLIGHT_B7B_XXP_BXC_SHELL_LOAD=1
```
>
> next: ~~driver_leaf BASE_CFLAGS~~ (wave860) · residual thin/B2/lists or tip Windows

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD` | `1` |
| `PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD_COUNT` | `2` |
| `SWALLOWED_B7B_XXP_BXC_SHELL_LOAD` | `1` |
| `B7B_XXP_BXC_SHELL_LOAD_VIA` | `export_xxp_link_bags+export_bxc_link_objs` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim XXP/BXC shell-load = physical delete; dual multi-token
`XXP_*=` / `BXC_LINK_OBJS=` recipe env; second PIPELINE_X inventory in shell.

## wave858 B7B LEGACY xlang-c link shell-primary (2026-07-30)

> **Why (G.7 有则补全 on wave822 list + wave849/856/857 shell-primary pattern):**
> Archaeology `XLANG_LEGACY_C_FRONTEND=1` still had multi-token host-cc link body:
> `$(CC) $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) … $(LEGACY_XLANG_C_*)`.
> Lists already in `mk/driver_seed_composites.mk` (wave822). Body → shell.
>
> **Authority:**
>   - script: `scripts/legacy_xlang_c_link.sh`
>   - LINK_OBJS: `export-legacy-xlang-c-link-objs` → `$(LEGACY_XLANG_C_PREREQS)`
>   - LINK_CFLAGS: **reuse** `export-relink-product-link-cflags` (same formula;
>     no second flag inventory)
>
> Makefile LEGACY `$(XLANG_C)` thin-calls shell only. Default non-LEGACY path
> still `cp bootstrap_xlangc`. **NOT physical delete** — thin edges + B2 + mk
> lists remain. Dual-end L2 required.
>
```text
    PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY=1
    PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY_WAVE=wave858
    PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY_COUNT=1
    SWALLOWED_B7B_LEGACY_XLANG_C_SHELL_PRIMARY=1
    PHYS_DEL_PREFLIGHT_B7B_LEGACY_XLANG_C_SHELL_PRIMARY=1
```
>
> next: residual thin/B2/lists (hybrid) or tip Windows → dual L4 → explicit auth ship

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY` | `1` |
| `PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY_COUNT` | `1` |
| `SWALLOWED_B7B_LEGACY_XLANG_C_SHELL_PRIMARY` | `1` |
| `B7B_LEGACY_XLANG_C_SHELL_PRIMARY_VIA` | `legacy_xlang_c_link_sh+export_legacy_link_objs+reuse_relink_product_cflags` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim LEGACY shell-primary = physical delete; dual multi-token
`$(CC) … LEGACY_XLANG_C_*` recipe body; second CFLAGS inventory for LEGACY.

## wave857 B7B LINK_CFLAGS shell-load via make export leaves (2026-07-30)

> **Why (G.7 有则补全 on wave856 LINK_OBJS export-leaf pattern):**
> Archaeology shells still required multi-token `*_LINK_CFLAGS=` / `BTC_CFLAGS=` /
> `BS_LINK_FLAGS=` from Makefile thin-call. Composed flags need **make expansion**
> (`DRIVER_SEED_LINK_FLAGS` / `ASM_GLUE_DUP_LDFLAGS` / `MAIN_LINK_FLAGS` / platform ifeq)
> — not pure mk text.
>
> **Bags (4 formulas / 6 shells):**
>   - **relink-product** — RXL + XXL + BTC codegen via `export-relink-product-link-cflags`
>   - **btc-typeck** — BTC typeck only via `export-btc-typeck-link-cflags` (no `-DXLANG_USE_X_CODEGEN`)
>   - **xnc** — XNC + BS via `export-xnc-link-cflags` (no ASM_GLUE_DUP)
>   - **bxf** — BXF via `export-bxf-link-cflags`
>
> Shell loads `LINK_CFLAGS=` when env unset; Makefile recipes drop multi-token
> CFLAGS/FLAGS env. **NOT physical delete** — thin edges + B2 + mk lists remain.
>
```text
    PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD=1
    PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD_WAVE=wave857
    PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD_COUNT=4
    SWALLOWED_B7B_LINK_CFLAGS_SHELL_LOAD=1
    PHYS_DEL_PREFLIGHT_B7B_LINK_CFLAGS_SHELL_LOAD=1
```
>
> next: residual thin/B2/lists (hybrid) or tip Windows → dual L4 → explicit auth ship

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD` | `1` |
| `PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD_COUNT` | `4` bags / `6` shells |
| `SWALLOWED_B7B_LINK_CFLAGS_SHELL_LOAD` | `1` |
| `B7B_LINK_CFLAGS_SHELL_LOAD_VIA` | `export_relink_product+btc_typeck+xnc+bxf_link_cflags` |

**Forbidden:** claim LINK_CFLAGS export leaves = physical delete; dual multi-token
`*_LINK_CFLAGS="…"` recipe env re-list; second full flag inventory in shell.

## wave856 B7B LINK_OBJS shell-load via make export leaves (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on product archaeology **full LINK bag**
> multi-token env still exported on Makefile thin-call recipes after wave855
> (REQUIRED already shell-loads mk text; LINK bags need **make expansion** of
> nested `$(...)` / Darwin filtered pipeline picks — pure `_mk_assign_val` is
> wrong):
>   - **RXL / BTC** — `RELINK_PRODUCT_LINK_OBJS` via `export-relink-product-link-objs`
>   - **XXL** — `XLANG_X_LINK_OBJS` via `export-xlang-x-link-objs`
>   - **XNC** — `XLANG_NO_C_FRONTEND_LINK_OBJS` via `export-xnc-link-objs`
>   - **BXF** — `DRIVER_SEED_X_FRONTEND_LINK_OBJS` via `export-bxf-link-objs`
>   - **BS** — `BOOTSTRAP_SELF_LINK_OBJS` via `export-bs-link-objs`
>
> Authority pattern = same as `bootstrap_driver_seed_export-*-link` (wave721+):
> shell loads `LINK_OBJS=` when env unset; Makefile recipes drop multi-token
> `*_LINK_OBJS=` / `BTC_OBJS=` env. **CFLAGS / defines stay make thin-call env**
> (composed flags). Bags **COUNT=5** (RXL+BTC share one bag); shells **COUNT=6**.
>
> Residual after: thin edges + B2 + mk lists + LINK **CFLAGS** env residual.
> Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD=1
    PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD_WAVE=wave856
    PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD_COUNT=5
    SWALLOWED_B7B_LINK_OBJS_SHELL_LOAD=1
    PHYS_DEL_PREFLIGHT_B7B_LINK_OBJS_SHELL_LOAD=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 4f4e2cf9f (Mac + Ubuntu leaf residual CHECK + shell --check + export smoke + product rv42)
  next: residual thin/B2/lists (hybrid) or tip Windows (LINK CFLAGS → wave857)
    re-proof → ship delete body (explicit auth only; tip L4 wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD` | `1` |
| `PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD_COUNT` | `5` bags / `6` shells |
| `SWALLOWED_B7B_LINK_OBJS_SHELL_LOAD` | `1` |
| `B7B_LINK_OBJS_SHELL_LOAD_VIA` | `export_relink_product+xlang_x+xnc+bxf+bs_link_objs` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | tree arm; delete deferred |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim LINK_OBJS export leaves = physical delete; dual multi-token
`*_LINK_OBJS="…"` recipe env re-list; second full .o inventory in shell; pure
mk text-parse of nested LINK bags; mac-only wave green; `rm compiler/Makefile`;
ship delete without explicit auth.

## wave854 B7B seed-gate REQUIRED_OBJS bags → mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on product archaeology **seed-gate**
> multi-token lists still **inlined** as `*_REQUIRED_OBJS="..."` in Makefile
> thin-call exports after wave853 (full link bags already mk):
>   - **RXL** — `RELINK_XLANG_REQUIRED_OBJS` (fixed multi-token **COUNT=6**)
>   - **XXL** — `XLANG_X_REQUIRED_OBJS` (fixed multi-token **COUNT=12**)
>   - **XNC** — `XLANG_NO_C_FRONTEND_REQUIRED_OBJS` (fixed multi-token **COUNT=3**)
>
> Authority:
>   - `mk/driver_seed_composites.mk` — RXL + XXL
>   - `mk/archaeology_experiment_objs.mk` — XNC
>   - bags **COUNT=3**
>
> Makefile expands `$(RELINK_XLANG_REQUIRED_OBJS)` /
> `$(XLANG_X_REQUIRED_OBJS)` / `$(XLANG_NO_C_FRONTEND_REQUIRED_OBJS)` only.
> Residual after: thin edges + B2 + other mk lists (hybrid). Dual-end L2
> required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_B7B_SEED_GATE_REQUIRED=1
    PHYS_DEL_B7B_SEED_GATE_REQUIRED_WAVE=wave854
    PHYS_DEL_B7B_SEED_GATE_REQUIRED_COUNT=3
    SWALLOWED_B7B_SEED_GATE_REQUIRED=1
    PHYS_DEL_PREFLIGHT_B7B_SEED_GATE_REQUIRED=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 44f161811 (Mac + Ubuntu leaf residual CHECK +
    make -n RXL/XXL/XNC REQUIRED expand + product rv42)
  next: residual thin/B2/lists (hybrid) or tip Windows
    re-proof → ship delete body (explicit auth only; tip L4 wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_SEED_GATE_REQUIRED` | `1` |
| `PHYS_DEL_B7B_SEED_GATE_REQUIRED_COUNT` | `3` (RXL + XXL + XNC bags) |
| `SWALLOWED_B7B_SEED_GATE_REQUIRED` | `1` |
| `B7B_SEED_GATE_REQUIRED_MK` | `mk/driver_seed_composites.mk+mk/archaeology_experiment_objs.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | tree arm; delete deferred |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim seed-gate REQUIRED bags → mk = physical delete; dual inline
`*_REQUIRED_OBJS="a.o b.o ..."` re-list in Makefile; second inventory in shell;
mac-only wave green; `rm compiler/Makefile`; ship delete without explicit auth.

## wave853 B7B seed phase1/final full link bags → composites (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on the daily product seed phase1/final
> full host-cc link bags still **inlined** in Makefile `SEED_LINK_OBJS` export
> after wave852:
>   - **phase1** — glue prefix + `BOOTSTRAP_DRIVER_SEED_LINK_BASE` + filtered
>     user-asm + host stubs + seed_host partial + `RELINK_XLANG_GLUE_SUFFIX`
>   - **final** — glue prefix + `BOOTSTRAP_DRIVER_SEED_LINK_BASE` + host objs +
>     host stubs + filtered user-asm + `RELINK_XLANG_GLUE_SUFFIX`
>
> New authority in `mk/driver_seed_composites.mk`:
>   - `BOOTSTRAP_DRIVER_SEED_PHASE1_LINK_OBJS` · bags **COUNT=2**
>   - `BOOTSTRAP_DRIVER_SEED_FINAL_LINK_OBJS`
>   - Phase1 fixed multi-token path COUNT=1 (seed_host partial); final = all
>     `$(...)` expands. Glue is `RELINK_XLANG_GLUE_SUFFIX` (historic
>     target-specific `DRIVER_SEED_GLUE_SUFFIX` override retired with the bags).
>
> Makefile expands `$(BOOTSTRAP_DRIVER_SEED_{PHASE1,FINAL}_LINK_OBJS)` only.
> Residual after: ~~seed-gate REQUIRED~~ wave854 · thin edges + B2 + other mk
> lists (hybrid). Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK=1
    PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK_WAVE=wave853
    PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK_COUNT=2
    SWALLOWED_B7B_SEED_PHASE_FINAL_LINK=1
    PHYS_DEL_PREFLIGHT_B7B_SEED_PHASE_FINAL_LINK=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 3c67649c9 (Mac + Ubuntu leaf residual CHECK +
    make -n phase1/final expand + product rv42)
  next: residual thin/B2/lists (~~seed-gate REQUIRED~~ wave854 · hybrid) or tip
    Windows re-proof → ship delete body (explicit auth only; tip L4 wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK` | `1` |
| `PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK_COUNT` | `2` (phase1 + final bags) |
| `SWALLOWED_B7B_SEED_PHASE_FINAL_LINK` | `1` |
| `B7B_SEED_PHASE_FINAL_LINK_MK` | `mk/driver_seed_composites.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | tree arm; delete deferred |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim seed phase1/final bags → mk = physical delete; dual inline
`SEED_LINK_OBJS` re-list of `LINK_BASE` + user-asm + glue in Makefile; second
inventory in shell; mac-only wave green; `rm compiler/Makefile`; ship delete
without explicit auth.

## wave852 B7B BXF full link bag → archaeology_experiment (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on the remaining archaeology experiment
> full host-cc link bag still **inlined** in Makefile thin-call export after
> wave851:
>   - **BXF** (`bootstrap-driver-seed-x-frontend`) — `BXF_LINK_OBJS` re-listed
>     `DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS` + `driver_x.o` + `preprocess_x.o`
>     + subcmd / lsp_diag / `PIPELINE_LIBS`
>
> New authority in `mk/archaeology_experiment_objs.mk`:
>   - `DRIVER_SEED_X_FRONTEND_LINK_OBJS` · fixed multi-token **COUNT=2**
>     (`driver_x.o` `preprocess_x.o` beyond experiment base)
>
> Makefile expands `$(DRIVER_SEED_X_FRONTEND_LINK_OBJS)` only. Residual after:
> thin edges + B2 + other mk lists (~~seed phase1/final~~ wave853 · hybrid).
> Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_B7B_BXF_LINK=1
    PHYS_DEL_B7B_BXF_LINK_WAVE=wave852
    PHYS_DEL_B7B_BXF_LINK_COUNT=2
    SWALLOWED_B7B_BXF_LINK=1
    PHYS_DEL_PREFLIGHT_B7B_BXF_LINK=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 1ad1b9969 (Mac + Ubuntu leaf residual CHECK +
    make -n BXF expand bag + product rv42)
  next: residual thin/B2/lists (~~seed phase1/final bags~~ wave853 or hybrid)
    or tip Windows re-proof → ship delete body (explicit auth only; tip L4 wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_BXF_LINK` | `1` |
| `PHYS_DEL_B7B_BXF_LINK_COUNT` | `2` (fixed multi-token beyond experiment base) |
| `SWALLOWED_B7B_BXF_LINK` | `1` |
| `B7B_BXF_LINK_MK` | `mk/archaeology_experiment_objs.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | tree arm; delete deferred |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim BXF bag → mk = physical delete; dual inline
`BXF_LINK_OBJS` bag re-list in Makefile; second inventory in shell; mac-only
wave green; `rm compiler/Makefile`; ship delete without explicit auth.

## wave851 B7B XXL/BS/XNC full link bags → mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on remaining product-shaped archaeology
> full host-cc link bags that were still **inlined** in Makefile thin-call
> exports after wave850:
>   - **XXL** (`xlang-x`) — `XXL_LINK_OBJS` re-listed DRIVER_SEED_LINK_BASE-like
>     inventory with `XLANG_X_PIPELINE_LINK_O` (no `PIPELINE_LIBS`)
>   - **BS** (`bootstrap-self` stage2) — re-listed full `DRIVER_SEED_LINK_BASE`
>     + `USER_ASM_LINK`
>   - **XNC** (`xlang-no-c-frontend`) — re-listed `DRIVER_NO_C_FRONTEND_OBJS`
>     + weak sizes/stubs satellites
>
> New authority:
>   - `mk/driver_seed_composites.mk`:
>     - `XLANG_X_LINK_BASE` · fixed multi-token **COUNT=8**
>     - `XLANG_X_LINK_OBJS` · BASE + HOST_OBJS/STUBS + XLANG_X_USER_ASM + GLUE_SUFFIX
>     - `BOOTSTRAP_SELF_LINK_OBJS` · `$(DRIVER_SEED_LINK_BASE) $(USER_ASM_LINK)`
>   - `mk/archaeology_experiment_objs.mk`:
>     - `XLANG_NO_C_FRONTEND_LINK_OBJS` · fixed multi-token **COUNT=9**
>
> Makefile expands `$(XLANG_X_LINK_OBJS)` / `$(BOOTSTRAP_SELF_LINK_OBJS)` /
> `$(XLANG_NO_C_FRONTEND_LINK_OBJS)` only (**COUNT=3 bags**). Residual after:
> thin edges + B2 + other mk lists (~~BXF experiment bag~~ wave852). Dual-end L2
> required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_B7B_XXL_BS_XNC_LINK=1
    PHYS_DEL_B7B_XXL_BS_XNC_LINK_WAVE=wave851
    PHYS_DEL_B7B_XXL_BS_XNC_LINK_COUNT=3
    SWALLOWED_B7B_XXL_BS_XNC_LINK=1
    PHYS_DEL_PREFLIGHT_B7B_XXL_BS_XNC_LINK=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 038844e65 (Mac + Ubuntu leaf residual CHECK +
    make -n XXL/BS/XNC expand bag + product rv42)
  next: residual thin/B2/lists (~~BXF bag~~ wave852 or hybrid) or tip Windows
    re-proof → ship delete body (explicit auth only; tip L4 wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_XXL_BS_XNC_LINK` | `1` |
| `PHYS_DEL_B7B_XXL_BS_XNC_LINK_COUNT` | `3` (XXL + BS + XNC bags) |
| `SWALLOWED_B7B_XXL_BS_XNC_LINK` | `1` |
| `B7B_XXL_BS_XNC_LINK_MK` | `mk/driver_seed_composites.mk+mk/archaeology_experiment_objs.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | tree arm; delete deferred |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim XXL/BS/XNC bags → mk = physical delete; dual inline
`XXL_LINK_OBJS`/`BS_LINK_OBJS`/`XNC_LINK_OBJS` bag re-list in Makefile;
second inventory in shell; mac-only wave green; `rm compiler/Makefile`;
ship delete without explicit auth.

## wave850 B7B RELINK_PRODUCT_LINK bag → composites.mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7B list residual — the **same**
> product archaeology full host-cc link bag was inlined **3×** in Makefile
> thin-call exports (`BTC_OBJS` typeck + codegen, `RXL_LINK_OBJS`
> relink-xlang-lexer). That was dual (triple) inventory beside
> `DRIVER_SEED_LINK_BASE` shape.
>
> New authority in `mk/driver_seed_composites.mk`:
>   - `RELINK_PRODUCT_LINK_BASE` — LINK_BASE shape with
>     `RELINK_XLANG_PIPELINE_LINK_O` (Darwin filtered) · fixed multi-token
>     **COUNT=8**
>   - `RELINK_PRODUCT_LINK_OBJS` — `GLUE_PREFIX` + BASE +
>     `RELINK_XLANG_USER_ASM_LINK` + `RELINK_XLANG_GLUE_SUFFIX`
>
> Makefile consumers expand `$(RELINK_PRODUCT_LINK_OBJS)` only (no dual
> inline bag). Catalog parses composites.mk (wave728/788) — no second list.
> Residual after: thin edges + B2 + other mk lists. Dual-end L2 required.
> Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_B7B_RELINK_PRODUCT_LINK=1
    PHYS_DEL_B7B_RELINK_PRODUCT_LINK_WAVE=wave850
    PHYS_DEL_B7B_RELINK_PRODUCT_LINK_COUNT=8
    SWALLOWED_B7B_RELINK_PRODUCT_LINK=1
    PHYS_DEL_PREFLIGHT_B7B_RELINK_PRODUCT_LINK=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 50666351a (Mac + Ubuntu leaf residual CHECK +
    make -n BTC/RXL expand bag + product relink-xlang-lexer + rv42)
  next: residual thin/B2/lists (~~XXL/BS/XNC bags~~ wave851 or hybrid) or tip Windows
    re-proof → ship delete body (explicit auth only; tip L4 wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_RELINK_PRODUCT_LINK` | `1` |
| `PHYS_DEL_B7B_RELINK_PRODUCT_LINK_COUNT` | `8` (fixed BASE path tokens) |
| `SWALLOWED_B7B_RELINK_PRODUCT_LINK` | `1` |
| `B7B_RELINK_PRODUCT_LINK_MK` | `mk/driver_seed_composites.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | tree arm; delete deferred |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim product-link bag → mk = physical delete; dual inline
`BTC_OBJS`/`RXL_LINK_OBJS` bag re-list in Makefile; second inventory in shell;
mac-only wave green; `rm compiler/Makefile`; ship delete without explicit auth.

## wave849 relink-xlang-lexer shell-primary (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7C residual —
> `relink-xlang-lexer` still owned a fat Makefile body (seed `test -f` gate +
> `$(MAKE)` FILTERED/GLUE + fat `$(CC)` product link of `$(TARGET)` + `cp` sync
> to `XLANG_C` / `bootstrap_xlangc`). wave846 shelled `xlang-x`; this wave shells
> the lexer-only fast-relink product path (does **not** re-run g05 prepare).
>
> New authority: `scripts/relink_xlang_lexer.sh`
>   - seed gate via Makefile-exported `RXL_REQUIRED_OBJS`
>   - host-cc link with Makefile-exported `RXL_LINK_CFLAGS` / `RXL_LINK_OBJS`
>     (lists stay mk expansion; no second inventory in shell)
>   - product alias sync `TARGET` → `XLANG_C` + `bootstrap_xlangc`
>
> Makefile thin-call only (keeps `lexer_x.o` / `RELINK_XLANG_FILTERED_OBJS` /
> `RELINK_XLANG_GLUE_SUFFIX` make-graph prereqs). Honesty COUNT = **1**.
> Residual after: thin edges + B2 + mk lists (+ hybrid residual). Dual-end
> L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_RELINK_XLANG_LEXER_SHELL=1
    PHYS_DEL_RELINK_XLANG_LEXER_SHELL_WAVE=wave849
    PHYS_DEL_RELINK_XLANG_LEXER_SHELL_COUNT=1
    SWALLOWED_RELINK_XLANG_LEXER_SHELL=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT=11
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_WAVE=wave849
    PHYS_DEL_PREFLIGHT_RELINK_XLANG_LEXER_SHELL=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: f7bcc8b78 (Mac + Ubuntu leaf --check +
    relink_xlang_lexer.sh --check + phys-del --check +
    make -n thin-call; product relink + rv42 green both ends)
  next: residual thin/B2/lists (hybrid / lists) or tip Windows re-proof →
    ship delete body (explicit auth only; tip L4 wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_RELINK_XLANG_LEXER_SHELL` | `1` |
| `PHYS_DEL_RELINK_XLANG_LEXER_SHELL_COUNT` | `1` |
| `SWALLOWED_RELINK_XLANG_LEXER_SHELL` | `1` |
| `RELINK_XLANG_LEXER_SHELL_HELPER` | `relink_xlang_lexer.sh` |
| `PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT` | `11` (wave841–848 + wave849 relink-xlang-lexer) |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim relink-xlang-lexer shell-primary = physical delete;
dual `$(CC)` link / seed gate / `cp` sync body in Makefile recipe; dual full
link inventory in shell; mac-only wave green; `rm compiler/Makefile`; ship
delete body without explicit auth.

## wave848 bootstrap-driver-seed-x-frontend shell-primary (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7C archaeology residual —
> `bootstrap-driver-seed-x-frontend` still owned a fat Makefile `$(CC)` link
> of stage-10.4 experiment binary `$(TARGET)_x_frontend` (.x typeck/codegen,
> no `pipeline_x.o`). wave847 shelled `xlang-no-c-frontend`; this wave shells
> the sibling X-frontend experiment link path.
>
> New authority: `scripts/bootstrap_driver_seed_x_frontend.sh`
>   - host-cc link with Makefile-exported `BXF_LINK_CFLAGS` / `BXF_LINK_OBJS`
>     (lists stay mk expansion; no second inventory in shell)
>
> Makefile thin-call only (keeps `XLANG_C` / `migrate-x-objs` /
> `DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS` make-graph prereqs). Honesty COUNT = **1**.
> Residual after: thin edges + B2 + mk lists (+ ~~relink-xlang-lexer~~ wave849 /
> hybrid residual). Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL=1
    PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL_WAVE=wave848
    PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL_COUNT=1
    SWALLOWED_BOOTSTRAP_SEED_X_FRONTEND_SHELL=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT=10
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_WAVE=wave848
    PHYS_DEL_PREFLIGHT_BOOTSTRAP_SEED_X_FRONTEND_SHELL=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: b45455cd0 (Mac + Ubuntu leaf --check +
    bootstrap_driver_seed_x_frontend.sh --check + phys-del --check +
    make -n thin-call; product rv42 green both ends)
  next: residual thin/B2/lists (~~relink-xlang-lexer~~ wave849 / hybrid / lists) or tip
    Windows re-proof → ship delete body (explicit auth only; tip L4 wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL` | `1` |
| `PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL_COUNT` | `1` |
| `SWALLOWED_BOOTSTRAP_SEED_X_FRONTEND_SHELL` | `1` |
| `BOOTSTRAP_SEED_X_FRONTEND_SHELL_HELPER` | `bootstrap_driver_seed_x_frontend.sh` |
| `PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT` | `10` (wave841–847 + wave848 seed-x-frontend; **superseded COUNT=11** by wave849) |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim bootstrap-driver-seed-x-frontend shell-primary = physical delete;
dual `$(CC)` link body in Makefile recipe; dual full link inventory in shell;
mac-only wave green; `rm compiler/Makefile`; ship delete body without explicit auth.

## wave847 xlang-no-c-frontend shell-primary (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7C archaeology residual —
> `xlang-no-c-frontend` still owned a multi-step Makefile body
> (short `test -f` seed gate + fat `$(CC)` link of archaeology
> `./xlang-no-c-frontend`). wave846 shelled `xlang-x` (full-driver product);
> this wave shells the sibling no-C-frontend experiment binary link path.
>
> New authority: `scripts/xlang_no_c_frontend.sh`
>   - seed gate via Makefile-exported `XNC_REQUIRED_OBJS`
>   - host-cc link with Makefile-exported `XNC_LINK_CFLAGS` / `XNC_LINK_OBJS`
>     (lists stay mk expansion; no second inventory in shell)
>
> Makefile thin-call only (keeps `DRIVER_NO_C_FRONTEND_OBJS` /
> `lsp_diag_stubs_no_c.o` make-graph prereqs). Honesty COUNT = **1**. Residual after:
> thin edges + B2 + mk lists (+ ~~seed-x-frontend~~ wave848 / hybrid residual). Dual-end
> L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL=1
    PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL_WAVE=wave847
    PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL_COUNT=1
    SWALLOWED_XLANG_NO_C_FRONTEND_SHELL=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT=9
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_WAVE=wave847
    PHYS_DEL_PREFLIGHT_XLANG_NO_C_FRONTEND_SHELL=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 190d1a801 (Mac + Ubuntu leaf --check +
    xlang_no_c_frontend.sh --check + phys-del --check + make -n thin-call;
    Mac live make reaches shell link → pre-existing UNDEF archaeology bag
    vs pipeline_x, bag shape unchanged; product rv42 green both ends)
  next: residual thin/B2/lists (~~seed-x-frontend~~ wave848 / hybrid / lists) or tip
    Windows re-proof → ship delete body (explicit auth only; tip L4 wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL` | `1` |
| `PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL_COUNT` | `1` |
| `SWALLOWED_XLANG_NO_C_FRONTEND_SHELL` | `1` |
| `XLANG_NO_C_FRONTEND_SHELL_HELPER` | `xlang_no_c_frontend.sh` |
| `PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT` | `9` (wave841–846 + wave847 xlang-no-c-frontend; **superseded COUNT=10** by wave848) |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim xlang-no-c-frontend shell-primary = physical delete; dual `$(CC)` link /
`test -f` seed gate body in Makefile recipe; dual full link inventory in shell;
mac-only wave green; `rm compiler/Makefile`; ship delete body without explicit auth.

## wave846 xlang-x shell-primary (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7C archaeology residual —
> `xlang-x` still owned a multi-step Makefile body
> (long `test -f` seed gate + fat `$(CC)` link of product `./xlang-x`).
> wave845 shelled `xlang-x-pipeline` (`TARGET_x`); this wave shells the sibling
> full-driver product binary relink path.
>
> New authority: `scripts/xlang_x.sh`
>   - seed gate via Makefile-exported `XXL_REQUIRED_OBJS`
>   - host-cc link with Makefile-exported `XXL_LINK_CFLAGS` / `XXL_LINK_OBJS`
>     (lists stay mk expansion; no second inventory in shell)
>
> Makefile thin-call only (keeps `build-seed-asm-host` / `DRIVER_SEED_OBJS` /
> pipeline+user-asm make-graph prereqs). Honesty COUNT = **1**. Residual after:
> thin edges + B2 + mk lists (+ ~~`xlang-no-c-frontend`~~ wave847 / hybrid residual). Dual-end
> L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_XLANG_X_SHELL=1
    PHYS_DEL_XLANG_X_SHELL_WAVE=wave846
    PHYS_DEL_XLANG_X_SHELL_COUNT=1
    SWALLOWED_XLANG_X_SHELL=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT=8
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_WAVE=wave846
    PHYS_DEL_PREFLIGHT_XLANG_X_SHELL=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 9784e345a (Mac + Ubuntu leaf --check +
    xlang_x.sh --check + phys-del --check + Mac live make xlang-x + rv42)
  next: residual thin/B2/lists (xlang-no-c-frontend / hybrid / lists) or tip
    Windows re-proof → ship delete body (explicit auth only; tip L4 wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_XLANG_X_SHELL` | `1` |
| `PHYS_DEL_XLANG_X_SHELL_COUNT` | `1` |
| `SWALLOWED_XLANG_X_SHELL` | `1` |
| `XLANG_X_SHELL_HELPER` | `xlang_x.sh` |
| `PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT` | `8` (wave841–845 + wave846 xlang-x) |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim xlang-x shell-primary = physical delete; dual `$(CC)` link /
`test -f` seed gate body in Makefile recipe; dual full link inventory in shell;
mac-only wave green; `rm compiler/Makefile`; ship delete body without explicit auth.

## wave845 xlang-x-pipeline shell-primary (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7C archaeology residual —
> `xlang-x-pipeline` still owned a multi-step Makefile body
> (force `pipeline_x.o` + migrate/satellites/`build-seed-asm-host` + force
> `target_cpu`/`simd_enc`/`simd_loop` + fat `$(CC)` link of `TARGET_x`).
> wave842 shelled `bootstrap-x-compiler` but left this prereq body residual.
>
> New authority: `scripts/xlang_x_pipeline.sh`
>   - force rebuild ladder via residual make ensure edges
>   - host-cc link `TARGET_x` with Makefile-exported `XXP_*` bags
>     (lists = `pipeline_x_objs.mk`; no second inventory in shell)
>
> Makefile thin-call only (keeps `bootstrap-pipeline` / migrate / PIPELINE_X_*
> make-graph prereqs). Honesty COUNT = **1**. Residual after: thin edges + B2 +
> mk lists. Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_XLANG_X_PIPELINE_SHELL=1
    PHYS_DEL_XLANG_X_PIPELINE_SHELL_WAVE=wave845
    PHYS_DEL_XLANG_X_PIPELINE_SHELL_COUNT=1
    SWALLOWED_XLANG_X_PIPELINE_SHELL=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT=7
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_WAVE=wave845
    PHYS_DEL_PREFLIGHT_XLANG_X_PIPELINE_SHELL=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: cc9e732e0 (Mac + Ubuntu leaf --check +
    xlang_x_pipeline.sh --check + phys-del --check + rv42/hello)
  next: residual thin/B2/lists (incl. PIPELINE_X bag completeness for live
    TARGET_x link) or tip Windows re-proof → ship delete body
       (explicit auth only; tip L4 already wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_XLANG_X_PIPELINE_SHELL` | `1` |
| `PHYS_DEL_XLANG_X_PIPELINE_SHELL_COUNT` | `1` |
| `SWALLOWED_XLANG_X_PIPELINE_SHELL` | `1` |
| `XLANG_X_PIPELINE_SHELL_HELPER` | `xlang_x_pipeline.sh` |
| `PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT` | `7` (wave841–844 + wave845 xlang-x-pipeline) |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | product `cc9e732e0` |

**Forbidden:** claim xlang-x-pipeline shell-primary = physical delete; dual multi-make
ensure / `$(CC)` link body in Makefile recipe; dual `PIPELINE_X_*` list in shell;
mac-only wave green; `rm compiler/Makefile`; ship delete body without explicit auth.

## wave844 bootstrap-parser/parse-file shell-primary (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7C archaeology residual —
> `bootstrap-parser` / `bootstrap-parse-file` still owned multi-step Makefile
> smoke bodies (parser.x product `-o` + dual-path fixture "parse OK" checks).
> wave719 already shelled token/lexer smokes; parser smokes follow the same
> authority pattern (shell body; make keeps prereq graph).
>
> New authority: `scripts/bootstrap_parser_smoke.sh`
>   - `parser` — product host compiles `src/parser/parser.x` → run smoke
>   - `parse-file` — minimal + expr-chain fixtures; .x parser + host xlang
>     both emit "parse OK"
>
> Makefile thin-call only (keeps `relink-xlang` / `STD_AND_PANIC_O` /
> `bootstrap-parser` make-graph prereqs). Honesty COUNT = **2**. Residual after:
> thin edges + B2 + mk lists + ~~xlang-x-pipeline~~ (cleared wave845). Dual-end L2
> required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_BOOTSTRAP_PARSER_SMOKE=1
    PHYS_DEL_BOOTSTRAP_PARSER_SMOKE_WAVE=wave844
    PHYS_DEL_BOOTSTRAP_PARSER_SMOKE_COUNT=2
    SWALLOWED_BOOTSTRAP_PARSER_SMOKE=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT=6
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_WAVE=wave844
    PHYS_DEL_PREFLIGHT_BOOTSTRAP_PARSER_SMOKE=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: a7b026d49 product / f78a6381d docs (Mac + Ubuntu leaf
    --check + bootstrap_parser_smoke.sh --check + phys-del --check + rv42/hello)
  next: residual thin/B2/lists or tip Windows re-proof → ship delete body
       (explicit auth only; tip L4 already wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_BOOTSTRAP_PARSER_SMOKE` | `1` |
| `PHYS_DEL_BOOTSTRAP_PARSER_SMOKE_COUNT` | `2` |
| `SWALLOWED_BOOTSTRAP_PARSER_SMOKE` | `1` |
| `BOOTSTRAP_PARSER_SMOKE_HELPER` | `bootstrap_parser_smoke.sh` |
| `PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT` | `6` (wave841–843 + wave844 parser/parse-file; later 7 @ wave845) |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | product `a7b026d49` · docs `f78a6381d` |

**Forbidden:** claim bootstrap-parser smoke shell-primary = physical delete; dual
inline parser.x / parse-file fixture body in Makefile recipe; mac-only wave green;
`rm compiler/Makefile`; ship delete body without explicit auth.

## wave843 bootstrap-self shell-primary (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7C archaeology residual —
> `bootstrap-self` still owned a multi-step Makefile body
> (stage1 `cp` + best-effort satellite ensure + fat `$(CC)` stage2 link +
> `out_self` return-value smoke / file(1) re-cc). wave785 already closed dual
> `$(CC) -c` on lsp gens; stage2 link bag residual stays mk expansion.
>
> New authority: `scripts/bootstrap_self.sh`
>   - stage1 snapshot + residual make ensure for satellite leaves
>   - host-cc link stage2 with Makefile `BS_LINK_OBJS` / `BS_LINK_FLAGS`
>     (mk composites; no second product inventory in shell)
>   - out_self smoke (exit 42; Mach-O/ELF/PE32* or re-cc -x c)
>
> Makefile thin-call only (keeps `bootstrap-driver-seed` make-graph prereq).
> Honesty COUNT = **1**. Residual after: thin edges + B2 + mk lists +
> bootstrap-parser smoke body (cleared wave844). Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_BOOTSTRAP_SELF_SHELL=1
    PHYS_DEL_BOOTSTRAP_SELF_SHELL_WAVE=wave843
    PHYS_DEL_BOOTSTRAP_SELF_SHELL_COUNT=1
    SWALLOWED_BOOTSTRAP_SELF_SHELL=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT=4
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_WAVE=wave843
    PHYS_DEL_PREFLIGHT_BOOTSTRAP_SELF_SHELL=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: f8f2fb85c (Mac + Ubuntu leaf --check +
    bootstrap_self.sh --check + phys-del --check + rv42/hello)
  next: more shell-primary (bootstrap-parser smoke) or tip Windows
       re-proof → ship delete body (explicit auth only; tip L4 already wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_BOOTSTRAP_SELF_SHELL` | `1` |
| `PHYS_DEL_BOOTSTRAP_SELF_SHELL_COUNT` | `1` |
| `SWALLOWED_BOOTSTRAP_SELF_SHELL` | `1` |
| `BOOTSTRAP_SELF_SHELL_HELPER` | `bootstrap_self.sh` |
| `PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT` | `4` (wave841 typeck/codegen + wave842 x-compiler + wave843 self; later 6 @ wave844) |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `f8f2fb85c` |

**Forbidden:** claim bootstrap-self shell-primary = physical delete; dual inline
stage2 `$(CC)` link / out_self smoke / stage1 cp on this phony; hardcode second
product `.o` list in shell; `rm compiler/Makefile`; ship delete body; mac-only
wave green.

## wave842 bootstrap-x-compiler shell-primary (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7C archaeology residual —
> `bootstrap-x-compiler` still owned a multi-step Makefile body
> (`xlang_x -x -E` typeck/codegen → dual `$(CC) -c typeck_x_x` → fat link stage2).
> wave785 left this residual honest (not migrate_x_objs; different TU names).
>
> New authority: `scripts/bootstrap_x_compiler.sh`
>   - emit = `TARGET_x -x -E` typeck.x / codegen.x → typeck_x_x.c / codegen_x_x.c
>   - host-cc `-c` those gens (still not migrate_x_objs — archaeology TU names)
>   - link bag = Makefile `BXC_LINK_OBJS` (expands `$(OBJS)` from mk; no second
>     product inventory in shell)
>
> Makefile thin-call only (keeps `xlang-x-pipeline` make-graph prereq —
> wave719-style body shell-primary). Honesty COUNT = **1**. Residual after:
> thin edges + B2 + mk lists + bootstrap-self / bootstrap-parser smoke bodies
> (bootstrap-self cleared wave843). Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL=1
    PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL_WAVE=wave842
    PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL_COUNT=1
    SWALLOWED_BOOTSTRAP_X_COMPILER_SHELL=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT=3
    PHYS_DEL_PREFLIGHT_BOOTSTRAP_X_COMPILER_SHELL=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 610b627ac (Mac + Ubuntu leaf --check +
    bootstrap_x_compiler.sh --check + phys-del --check + rv42/hello)
  next: more shell-primary (bootstrap-self / parser smoke) or tip Windows
       re-proof → ship delete body (explicit auth only; tip L4 already wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL` | `1` |
| `PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL_COUNT` | `1` |
| `SWALLOWED_BOOTSTRAP_X_COMPILER_SHELL` | `1` |
| `BOOTSTRAP_X_COMPILER_SHELL_HELPER` | `bootstrap_x_compiler.sh` |
| `PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT` | `3` (wave841 typeck/codegen + wave842 x-compiler; later 4 @ wave843) |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `610b627ac` |

**Forbidden:** claim x-compiler shell-primary = physical delete; dual inline
`-x -E` / `$(CC) -c typeck_x_x` on this phony; hardcode second product `.o`
list in shell; `rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave841 bootstrap-typeck/codegen shell-primary (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7C archaeology residual —
> `bootstrap-typeck` / `bootstrap-codegen` still owned a multi-step Makefile body
> (inline `xlang-c -E-extern` → `migrate_x_objs` → fat `$(CC)` link). wave785 only
> thinned the migrate leaf; gen `-E` + link stayed dual.
>
> New authority: `scripts/bootstrap_typeck_codegen.sh`
>   - gen = `ensure_migrate_gen.sh` with `XLANG_FORCE_REGEN_GEN=1` (no dual `-E`)
>   - `.o` = `migrate_x_objs.sh` with `XLANG_MIGRATE_FORCE=1`
>   - link bag = Makefile `BTC_CFLAGS` / `BTC_OBJS` (expands mk composites; no
>     second `.o` inventory in shell)
>
> Makefile thin-call only (keeps `$(TARGET) $(XLANG_C) bootstrap_xlangc
> $(RELINK_XLANG_PREREQS)` make-graph prereqs — wave719-style body shell-primary).
> Honesty COUNT = **2**. Residual after: thin edges + B2 + mk lists +
> `bootstrap-x-compiler` typeck_x_x (cleared wave842). Dual-end L2 required.
> Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL=1
    PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL_WAVE=wave841
    PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL_COUNT=2
    SWALLOWED_BOOTSTRAP_TYPECK_CODEGEN_SHELL=1
    PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY=1
    PHYS_DEL_PREFLIGHT_BOOTSTRAP_TYPECK_CODEGEN_SHELL=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2: leaf --check + bootstrap_typeck_codegen.sh --check + phys-del --check
  next: more shell-primary (bootstrap-parser / self / x-compiler) or tip Windows
       re-proof → ship delete body (explicit auth only; tip L4 already wave840)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL` | `1` |
| `PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL_COUNT` | `2` |
| `SWALLOWED_BOOTSTRAP_TYPECK_CODEGEN_SHELL` | `1` |
| `BOOTSTRAP_TYPECK_CODEGEN_SHELL_HELPER` | `bootstrap_typeck_codegen.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim typeck/codegen shell-primary = physical delete; dual inline
`xlang-c -E-extern` / `$(CC) -c typeck_gen` on these phonies; hardcode second
link `.o` list in shell; `rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave839 archaeology host-pick FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** — wave815 archaeology host-pick phonies
> still listed **script-only** prereqs (no FORCE). Four catalog keys
> (`net-o-stub` / `net-o-openssl` / `net-o-mbedtls` / `sqlite-o-stub`) become
> `FORCE scripts/archaeology_host_pick_phony.sh` only; recipe stays
> `bash … ensure $@` (dash-safe bash).
>
> Body authority remains `archaeology_host_pick_phony.sh` (host pick / TLS
> openssl·mbedtls / sqlite stub merge). FORCE means make always re-enters;
> nested product `.o` still via make try-heat (thin edges remain).
>
> Honesty COUNT = **4**. Residual after: thin-call edges + B2 + mk lists
> (`std_core_product_make_graph`). Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN=1
    PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN_WAVE=wave839
    PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN_COUNT=4
    SWALLOWED_ARCH_HOST_PICK_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_ARCH_HOST_PICK_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 4a2ddc977 (Mac + Ubuntu leaf --check;
    make net-o-stub FORCE ensure → try-heat net.o skip OK)
  next: thin edges / B2 or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body (explicit auth only)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN` | `1` |
| `PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN_COUNT` | `4` |
| `SWALLOWED_ARCH_HOST_PICK_FORCE_THIN` | `1` |
| `ARCH_HOST_PICK_FORCE_THIN_HELPER` | `archaeology_host_pick_phony.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim archaeology host-pick FORCE thin = physical delete; re-list
host-pick if-ladder on Makefile; dual host-pick outside catalog shell;
`rm compiler/Makefile`; ship delete body; mac-only wave green.


## wave831 src-edge FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on leftover **source-prereq make-graph**
> edges that still listed seed / `.x` / `*.inc` on thin-call leaves after heat
> FORCE (wave791–797) and gen FORCE (wave829–830):
>
> 1. **`parser_asm_thin_glue.o`** (1) — drop 30+ seed/.x/*.inc prereqs; target is
>    `FORCE scripts/ensure_host_cc_seed_o.sh` only; recipe stays try-heat
>    (shell already owns slice mtime since wave758).
> 2. **cc_inc_tu residual** (6) — `bootstrap_nostdlib_stubs` ·
>    `asm_experimental_symbol_bridge` · `lsp_diag_pipeline_sizes` (weak) ·
>    `cfg_eval_bootstrap_stub` · `typeck_lsp_io_stub` · `build_tool_main` —
>    target `FORCE scripts/cc_inc_tu.sh`; recipe keeps seed path as script arg.
>    **`cc_inc_tu.sh`** gains mtime skip + optional `XLANG_CC_INC_TU_PEERS`
>    (cfg_eval `.x` peer) + `XLANG_CC_INC_TU_FORCE` (G.7 single body).
>
> Honesty COUNT = **7**. Residual after: ~~migrate `*_x.o` gen.c prereqs~~
> (wave832) · `pipeline_glue_types.inc` · thin edges + B2 + mk lists.
> Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_SRC_EDGE_FORCE_THIN=1
    PHYS_DEL_SRC_EDGE_FORCE_THIN_WAVE=wave831
    PHYS_DEL_SRC_EDGE_FORCE_THIN_COUNT=7
    PHYS_DEL_SRC_EDGE_FORCE_THIN_CC_INC=6
    PHYS_DEL_SRC_EDGE_FORCE_THIN_PARSER_ASM=1
    SWALLOWED_SRC_EDGE_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_SRC_EDGE_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: acc2a8fd1 (Mac + Ubuntu leaf --check;
    src-edge 7 FORCE; cc_inc_tu mtime/PEERS; sample pin OK)
  next: ~~migrate *_x.o FORCE~~ (wave832) · pipeline_glue_types or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_SRC_EDGE_FORCE_THIN` | `1` |
| `PHYS_DEL_SRC_EDGE_FORCE_THIN_COUNT` | `7` |
| `SWALLOWED_SRC_EDGE_FORCE_THIN` | `1` |
| `SRC_EDGE_FORCE_THIN_HELPER` | `cc_inc_tu.sh+ensure_host_cc_seed_o_try-heat` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim src-edge FORCE thin = physical delete; re-list seed/.inc on
Makefile prereq lines for these 7; `rm compiler/Makefile`; ship delete body;
mac-only wave green.

## wave830 ast_gen2.c FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **无才新增** on the last inline gen-C residual —
> `ast_gen2.c` (mirror wave829 FORCE dep-thin) — Makefile drops `src/ast/ast.x`
> make-graph prereq; target line is `FORCE scripts/ensure_ast_gen2.sh` only;
> recipe thin-calls ensure (bash, dash-safe). Shell owns pin /
> `XLANG_FORCE_REGEN_GEN` / `-E -E-extern` + `fix_slim_arena_gen_c.pl` policy.
> Honesty COUNT = **1**. Distinct from product `*_gen.c` (no linux.x86_64 seed
> pin; committed local pin authority). `.o` path remains try-heat /
> ensure_gen_x_o. Residual: thin edges + B2 + mk lists remain.
> Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_AST_GEN2_FORCE_THIN=1
    PHYS_DEL_AST_GEN2_FORCE_THIN_WAVE=wave830
    PHYS_DEL_AST_GEN2_FORCE_THIN_COUNT=1
    SWALLOWED_AST_GEN2_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_AST_GEN2_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 3cd6c3f81 (Mac + Ubuntu leaf + phys-del --check;
    ast_gen2 FORCE; ensure bash; sample pin OK)
  next: ~~src-edge FORCE thin~~ (wave831) · thin edges / B2 or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_AST_GEN2_FORCE_THIN` | `1` |
| `PHYS_DEL_AST_GEN2_FORCE_THIN_COUNT` | `1` |
| `SWALLOWED_AST_GEN2_FORCE_THIN` | `1` |
| `AST_GEN2_FORCE_THIN_HELPER` | `ensure_ast_gen2.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim ast_gen2 FORCE thin = physical delete; re-list `src/ast/ast.x`
on the Makefile gen prereq line; `rm compiler/Makefile`; ship delete body;
mac-only wave green.

## wave829 gen.c FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on product/archaeology `*_gen.c` residual
> (mirror wave826–828 FORCE dep-thin) — Makefile **17** gen leaves drop dual `.x`
> / `$(MAIN_X_DEPS)` / `$(PREPROCESS_X_DEPS)` prereqs; target lines are
> `FORCE scripts/ensure_{migrate,driver,lsp_pipeline,archaeology}_gen.sh` only;
> recipes remain thin-call ensure. Shell owns pin/seed/`XLANG_FORCE_REGEN_GEN`
> policy (not make source-edge graph). Honesty COUNT = **17** (migrate 4 + lsp 3 +
> archaeology 8 + driver/preprocess 2). Residual after wave829: ~~`ast_gen2.c`
> inline~~ (wave830); `pipeline_gen.c` already prereq-free; thin edges + B2 + mk
> lists remain. Dual-end L2 required. Blockers **remain**.

```text
  leaf dump:
    PHYS_DEL_GEN_C_FORCE_THIN=1
    PHYS_DEL_GEN_C_FORCE_THIN_WAVE=wave829
    PHYS_DEL_GEN_C_FORCE_THIN_COUNT=17
    SWALLOWED_GEN_C_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_GEN_C_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: bfa60f50b (Mac + Ubuntu leaf + phys-del --check;
    gen.c 17 FORCE; ensure recipes bash; sample pin/seed OK)
  next: ~~ast_gen2 FORCE thin~~ (wave830) · thin edges / B2 or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_GEN_C_FORCE_THIN` | `1` |
| `PHYS_DEL_GEN_C_FORCE_THIN_COUNT` | `17` |
| `SWALLOWED_GEN_C_FORCE_THIN` | `1` |
| `GEN_C_FORCE_THIN_HELPER` | `ensure_migrate_driver_lsp_archaeology_gen` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim gen.c FORCE thin = physical delete; re-list catalog `.x` /
`X_DEPS` on these Makefile gen prereq lines; `rm compiler/Makefile`; ship delete
body; mac-only wave green.

## wave828 driver_leaf FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on driver_leaf neighborhood residual
> (mirror wave826 formal_mod / wave827 std_x) — Makefile **8** driver/lsp product
> leaves drop dual catalog `.x` prereqs; target lines are
> `FORCE scripts/driver_leaf_x_to_o.sh` only; recipe remains `ensure $@` with
> `BASE_CFLAGS=…`. Shell owns catalog source mtime (skip up-to-date; `FORCE=1`
> rebuilds). Honesty COUNT = **8**. Dual-end L2 required. Blockers **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`) —
> thin edges + B2 try-heat + mk lists still form the product make graph.

```text
  leaf dump:
    PHYS_DEL_DRIVER_LEAF_FORCE_THIN=1
    PHYS_DEL_DRIVER_LEAF_FORCE_THIN_WAVE=wave828
    PHYS_DEL_DRIVER_LEAF_FORCE_THIN_COUNT=8
    SWALLOWED_DRIVER_LEAF_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_DRIVER_LEAF_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 02aee9417 (Mac + Ubuntu leaf + catalog + phys-del
    --check; driver_leaf --check 8 FORCE; sample ensure skip up-to-date)
  next: more shell-primary / thin edges / B2 residual or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_DRIVER_LEAF_FORCE_THIN` | `1` |
| `PHYS_DEL_DRIVER_LEAF_FORCE_THIN_COUNT` | `8` |
| `SWALLOWED_DRIVER_LEAF_FORCE_THIN` | `1` |
| `DRIVER_LEAF_FORCE_THIN_HELPER` | `driver_leaf_x_to_o.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `02aee9417` |

**Forbidden:** claim driver_leaf FORCE thin = physical delete; re-list catalog
`.x` on Makefile driver_leaf prereq lines; `rm compiler/Makefile`; ship delete
body; mac-only wave green.

## wave827 std_x FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on std_x neighborhood residual (mirror
> wave826 formal_mod) — Makefile **22** pure-.x std product leaves drop dual
> catalog `.x` prereqs (incl. uuid's historic `random.o`/`time.o` order deps);
> target lines are `FORCE scripts/xlang_compile_std_x.sh` only; recipe remains
> `ensure $@`. Shell owns catalog source mtime (skip up-to-date; `FORCE=1`
> rebuilds). Honesty COUNT = **22**. Dual-end L2 required. Blockers **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`) —
> thin edges + formal_mod FORCE + B2 try-heat + mk lists still form the product
> make graph.

```text
  leaf dump:
    PHYS_DEL_STD_X_FORCE_THIN=1
    PHYS_DEL_STD_X_FORCE_THIN_WAVE=wave827
    PHYS_DEL_STD_X_FORCE_THIN_COUNT=22
    SWALLOWED_STD_X_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_STD_X_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 3f29cb132 (Mac + Ubuntu leaf + catalog + phys-del
    --check; std_x --check 22 FORCE; sample ensure skip up-to-date)
  next: more shell-primary / thin edges / B2 residual or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_STD_X_FORCE_THIN` | `1` |
| `PHYS_DEL_STD_X_FORCE_THIN_COUNT` | `22` |
| `SWALLOWED_STD_X_FORCE_THIN` | `1` |
| `STD_X_FORCE_THIN_HELPER` | `xlang_compile_std_x.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `3f29cb132` |

**Forbidden:** claim std_x FORCE thin = physical delete; re-list catalog `.x` on
Makefile std_x prereq lines; `rm compiler/Makefile`; ship delete body; mac-only
wave green.

## wave826 formal_mod FORCE dep-thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on formal_mod neighborhood residual —
> Makefile **38** formal_mod leaves drop dual catalog `.x` prereqs; target lines
> are `FORCE scripts/xlang_compile_std_module.sh` only; recipe remains
> `ensure $@`. Shell owns catalog source mtime (skip up-to-date; `FORCE=1`
> rebuilds). `fs_formal` vehicle path also mtime-skips on `mod.x`/`posix.x`.
> Honesty COUNT = **38**. Dual-end L2 required. Blockers **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`) —
> thin edges + B2 try-heat + mk lists still form the product make graph.

```text
  leaf dump:
    PHYS_DEL_FORMAL_MOD_FORCE_THIN=1
    PHYS_DEL_FORMAL_MOD_FORCE_THIN_WAVE=wave826
    PHYS_DEL_FORMAL_MOD_FORCE_THIN_COUNT=38
    SWALLOWED_FORMAL_MOD_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_FORMAL_MOD_FORCE_THIN=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 3d7245ac1 (Mac + Ubuntu leaf + catalog + phys-del
    --check; formal_mod --check 38 FORCE; sample ensure skip up-to-date)
  next: more shell-primary / thin edges / B2 residual or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_FORMAL_MOD_FORCE_THIN` | `1` |
| `PHYS_DEL_FORMAL_MOD_FORCE_THIN_COUNT` | `38` |
| `SWALLOWED_FORMAL_MOD_FORCE_THIN` | `1` |
| `FORMAL_MOD_FORCE_THIN_HELPER` | `xlang_compile_std_module.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `3d7245ac1` |

**Forbidden:** claim formal_mod FORCE thin = physical delete; re-list catalog `.x`
on Makefile formal_mod prereq lines; `rm compiler/Makefile`; ship delete body;
mac-only wave green.

## wave825 std_x shell-primary catalog (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on std_core product graph residual —
> pure-.x std product leaves (wave811 **22**). Per-leaf `mode|x_path`
> (`auto` / `auto-soft` / `auto-soft-merge`) moves into
> `xlang_compile_std_x.sh` catalog (`std_x_spec_for_key`). Makefile **22**
> leaves thin-call `ensure $@` only (prereqs stay for mtime). Legacy
> three-arg `mode path out` still supported for manual/archaeology. Honesty
> COUNT = **22**. Dual-end L2 required. Blockers **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`) —
> formal_mod + B2 try-std-core-prefer + thin edges + mk lists still form the
> product make graph.

```text
  leaf dump:
    PHYS_DEL_STD_X_SHELL_PRIMARY=1
    PHYS_DEL_STD_X_SHELL_PRIMARY_WAVE=wave825
    PHYS_DEL_STD_X_SHELL_PRIMARY_COUNT=22
    SWALLOWED_STD_X_CATALOG=1
    PHYS_DEL_PREFLIGHT_STD_X_SHELL_PRIMARY=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 13a6ac026 (Mac + Ubuntu leaf + catalog + phys-del
    --check; std_x --check 22 ensure thin; Makefile still present)
  next: more shell-primary / thin edges / std_core graph residual or tip
       Windows re-proof → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_STD_X_SHELL_PRIMARY` | `1` |
| `PHYS_DEL_STD_X_SHELL_PRIMARY_COUNT` | `22` (catalog leaves) |
| `SWALLOWED_STD_X_CATALOG` | `1` |
| `STD_X_CATALOG_HELPER` | `xlang_compile_std_x.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `13a6ac026` |

**Forbidden:** claim std_x catalog = physical delete; dual mode|path inventory
in Makefile recipes; `rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave824 B7B E_DIRS lists → mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7B *-E module search root residual —
> `MAIN_X_E_DIRS` (dir-roots **9**, includes bare `-L src`), `LSP_X_E_DIRS`
> (**8**, no bare `-L src`), and `PIPELINE_X_E_DIRS` (**9**, includes
> `src/asm`) move into `compiler/mk/x_e_dirs.mk`. Makefile **include only**
> (early with source-deps). Catalog shell-parses the mk.
> `ensure_driver_gen.sh` / `ensure_lsp_pipeline_gen.sh` /
> `ensure_archaeology_gen.sh` load from the same mk (no dual bash arrays).
> `driver_leaf_x_to_o.sh` kind=`lsp` loads `LSP_X_E_DIRS` from mk; kind=`base`
> loads `DRIVER_SUBCMD_DIRS` from `mk/driver_subcmd_objs.mk` (wave816 有则补全).
> Honesty COUNT = fixed directory-root tokens **26** (9+8+9; excludes literal
> `-L` flag tokens). Dual-end L2 required. Blockers **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`).

```text
  leaf dump:
    PHYS_DEL_B7B_E_DIRS_LIST=1
    PHYS_DEL_B7B_E_DIRS_LIST_WAVE=wave824
    PHYS_DEL_B7B_E_DIRS_LIST_COUNT=26
    SWALLOWED_B7B_E_DIRS_LIST=1
    PHYS_DEL_PREFLIGHT_B7B_E_DIRS_LIST=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 341ac78d5 (Mac + Ubuntu leaf + catalog + phys-del
    --check; E_DIRS fixed 26; make words MAIN/LSP/PIPE 18/16/18;
    ensure_driver_gen MAIN_X_E_DIRS load 18 tokens from mk)
  next: more shell-primary / thin edges / std_core graph residual or tip
       Windows re-proof → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_E_DIRS_LIST` | `1` |
| `PHYS_DEL_B7B_E_DIRS_LIST_COUNT` | `26` (fixed dir-root authority) |
| `SWALLOWED_B7B_E_DIRS_LIST` | `1` |
| `B7B_E_DIRS_LIST_MK` | `mk/x_e_dirs.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `341ac78d5` |

**Forbidden:** claim E_DIRS list→mk = physical delete; dual inline
`MAIN_X_E_DIRS` / `LSP_X_E_DIRS` / `PIPELINE_X_E_DIRS` in Makefile or hardcode
in ensure_driver_gen / ensure_lsp_pipeline_gen / ensure_archaeology_gen /
driver_leaf kind=lsp; `rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave823 B7B SOURCE_DEPS lists → mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7B source-path list residual —
> `SRCS` (fixed **4** from_x `.c`), `MAIN_X_DEPS` (**4** `.x`),
> `PREPROCESS_X_DEPS` (**1**), `PIPELINE_ASM_X_DEPS` (wildcard), and
> `PIPELINE_X_DEPS` (fixed **10** path tokens + `$(PIPELINE_ASM_X_DEPS)`)
> move into `compiler/mk/x_source_deps.mk`. Makefile **include only** (early
> so `$(PIPELINE_X_DEPS)` is non-empty before pipeline rules). Catalog
> shell-parses the mk. `ensure_driver_gen.sh` loads `MAIN_X_DEPS` /
> `PREPROCESS_X_DEPS` from the same mk (no dual bash array inventory).
> Honesty COUNT = fixed multi-token authority **19** (4+4+1+10; excludes
> wildcard expansion). Dual-end L2 required. Blockers **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`).

```text
  leaf dump:
    PHYS_DEL_B7B_SOURCE_DEPS_LIST=1
    PHYS_DEL_B7B_SOURCE_DEPS_LIST_WAVE=wave823
    PHYS_DEL_B7B_SOURCE_DEPS_LIST_COUNT=19
    SWALLOWED_B7B_SOURCE_DEPS_LIST=1
    PHYS_DEL_PREFLIGHT_B7B_SOURCE_DEPS_LIST=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: ff2ab3f61 (Mac + Ubuntu leaf + catalog + phys-del
    --check; SOURCE_DEPS fixed 19; SRCS/MAIN/PREP expand 4/4/1; PIPE_N=116
    with asm wildcard OK; ensure_driver_gen MAIN load 4 from mk)
  next: more shell-primary / thin edges / std_core graph residual or tip
       Windows re-proof → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_SOURCE_DEPS_LIST` | `1` |
| `PHYS_DEL_B7B_SOURCE_DEPS_LIST_COUNT` | `19` (fixed multi-token authority) |
| `SWALLOWED_B7B_SOURCE_DEPS_LIST` | `1` |
| `B7B_SOURCE_DEPS_LIST_MK` | `mk/x_source_deps.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `ff2ab3f61` |

**Forbidden:** claim SOURCE_DEPS list→mk = physical delete; dual inline
`SRCS` / `MAIN_X_DEPS` / `PIPELINE_X_DEPS` in Makefile or hardcode in
`ensure_driver_gen.sh` / catalog; `rm compiler/Makefile`; ship delete body;
mac-only wave green.

## wave822 B7B RELINK + LEGACY lists → composites.mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7B composite residual —
> `RELINK_XLANG_PREREQS` (fixed multi-token authority **14**: 13 path `.o`/`.c`
> + `build-seed-asm-host` phony) and `LEGACY_XLANG_C_LINK_BASE` /
> `LEGACY_XLANG_C_USER_ASM_LINK` / `LEGACY_XLANG_C_PREREQS` move into
> `compiler/mk/driver_seed_composites.mk` (composites already claimed
> bootstrap/phase1/final/**relink**). Makefile **include only** (no dual
> inline re-list). Catalog already shell-parses composites (wave788).
> Consumers: `bootstrap-typeck` / `bootstrap-codegen` expand
> `$(RELINK_XLANG_PREREQS)`; `XLANG_LEGACY_C_FRONTEND=1` recipe expands
> `$(LEGACY_XLANG_C_*)`. Dual-end L2 required. Blockers **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`).

```text
  leaf dump:
    PHYS_DEL_B7B_RELINK_LEGACY_LIST=1
    PHYS_DEL_B7B_RELINK_LEGACY_LIST_WAVE=wave822
    PHYS_DEL_B7B_RELINK_LEGACY_LIST_COUNT=14
    SWALLOWED_B7B_RELINK_LEGACY_LIST=1
    PHYS_DEL_PREFLIGHT_B7B_RELINK_LEGACY_LIST=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 7c522e9d6 (Mac + Ubuntu leaf + catalog + phys-del
    --check; RELINK fixed 14; expand Mac 63 / Ubuntu 52 host-filtered OK;
    LEGACY_PREREQ Mac 60 / Ubuntu 61)
  next: more shell-primary / lists residual (SRCS/X_DEPS) or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_RELINK_LEGACY_LIST` | `1` |
| `PHYS_DEL_B7B_RELINK_LEGACY_LIST_COUNT` | `14` (RELINK fixed multi-token authority) |
| `SWALLOWED_B7B_RELINK_LEGACY_LIST` | `1` |
| `B7B_RELINK_LEGACY_LIST_MK` | `mk/driver_seed_composites.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `7c522e9d6` |

**Forbidden:** claim RELINK/LEGACY list→mk = physical delete; dual inline
`RELINK_XLANG_PREREQS` / `LEGACY_XLANG_C_*` in Makefile or catalog hardcode;
`rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave821 B7B archaeology experiment lists → mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7B archaeology list residual —
> `DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS` (fixed **7** .o stage-10.4 experiment)
> and `DRIVER_NO_C_FRONTEND_OBJS` (expands `MAIN_LINK`/`PREPROCESS`/`AST` +
> runtime picks) move into `compiler/mk/archaeology_experiment_objs.mk`.
> Makefile **include only** (no dual inline re-list). `driver_seed_obj_catalog.sh`
> shell-parses the mk after link_picks. Experiment phonies
> `bootstrap-driver-seed-x-frontend` / `xlang-no-c-frontend` still consume the
> vars. Dual-end L2 required. Blockers **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`).

```text
  leaf dump:
    PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST=1
    PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST_WAVE=wave821
    PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST_COUNT=7
    SWALLOWED_B7B_ARCH_EXPERIMENT_LIST=1
    PHYS_DEL_PREFLIGHT_B7B_ARCH_EXPERIMENT_LIST=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 70ecb71f7 (Mac + Ubuntu leaf + catalog + phys-del
    --check; EXPERIMENT 7 expand OK; NO_C MAIN_LINK crt0_arm64 / crt0_x86_64)
  next: more shell-primary / lists residual or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST` | `1` |
| `PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST_COUNT` | `7` (X_FRONTEND_EXPERIMENT fixed inventory) |
| `SWALLOWED_B7B_ARCH_EXPERIMENT_LIST` | `1` |
| `B7B_ARCH_EXPERIMENT_LIST_MK` | `mk/archaeology_experiment_objs.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `70ecb71f7` |

**Forbidden:** claim archaeology experiment list→mk = physical delete; dual inline
`DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS` / `DRIVER_NO_C_FRONTEND_OBJS` in
Makefile or catalog hardcode; `rm compiler/Makefile`; ship delete body;
mac-only wave green.

## wave820 B7B OBJS_CORE archaeology list → mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7B archaeology list residual —
> `OBJS_CORE` (product incomplete **16** .o + LEGACY C-frontend layout) and
> `OBJS` alias move into `compiler/mk/objs_core.mk`. Makefile **include only**
> (no dual inline re-list). `driver_seed_obj_catalog.sh` shell-parses the mk.
> Product `make xlang` remains g05 (wave786); `XLANG_HOST_CC_OBJS_CORE=1`
> escape still links `$(OBJS)` (expect UNDEF). Dual-end L2 required. Blockers
> **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`).

```text
  leaf dump:
    PHYS_DEL_B7B_OBJS_CORE_LIST=1
    PHYS_DEL_B7B_OBJS_CORE_LIST_WAVE=wave820
    PHYS_DEL_B7B_OBJS_CORE_LIST_COUNT=16
    SWALLOWED_B7B_OBJS_CORE_LIST=1
    PHYS_DEL_PREFLIGHT_B7B_OBJS_CORE_LIST=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: b3651b5aa (Mac + Ubuntu leaf + catalog + phys-del
    --check; product OBJS_CORE 16 expand OK; LEGACY main_driver layout OK)
  next: more shell-primary / lists residual or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_OBJS_CORE_LIST` | `1` |
| `PHYS_DEL_B7B_OBJS_CORE_LIST_COUNT` | `16` (product-default OBJS_CORE) |
| `SWALLOWED_B7B_OBJS_CORE_LIST` | `1` |
| `B7B_OBJS_CORE_LIST_MK` | `mk/objs_core.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `b3651b5aa` |

**Forbidden:** claim OBJS_CORE list→mk = physical delete; dual inline
`OBJS_CORE` inventory in Makefile or catalog hardcode; re-open incomplete
`OBJS_CORE` as default product `xlang`; `rm compiler/Makefile`; ship delete
body; mac-only wave green.

## wave819 B7B seed link picks → mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7B product list residual —
> seed **link picks** `MAIN_LINK_O` / `MAIN_LINK_REBUILD` / `MAIN_LINK_FLAGS`,
> `LEXER_LINK_O` / `AST_LINK_O`, `LSP_DIAG_LINK_O`, `PREPROCESS_LINK_O`,
> `RELINK_XLANG_GLUE_SUFFIX` / `DRIVER_SEED_GLUE_SUFFIX` (product GLUE **2**)
> move into `compiler/mk/driver_seed_link_picks.mk`. Makefile **include only**
> (no dual inline re-list). `driver_seed_obj_catalog.sh` shell-parses the mk
> (drops MAIN_LINK / LEXER / LSP hardcodes). Composites still expand
> `$(MAIN_LINK_O)` / `$(LSP_DIAG_LINK_O)` into `DRIVER_SEED_OBJS` / `PREREQS`.
> Dual-end L2 required. Blockers **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`).

```text
  leaf dump:
    PHYS_DEL_B7B_SEED_LINK_PICKS_LIST=1
    PHYS_DEL_B7B_SEED_LINK_PICKS_LIST_WAVE=wave819
    PHYS_DEL_B7B_SEED_LINK_PICKS_LIST_COUNT=2
    SWALLOWED_B7B_SEED_LINK_PICKS_LIST=1
    PHYS_DEL_PREFLIGHT_B7B_SEED_LINK_PICKS_LIST=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 02766b0b9 (Mac + Ubuntu leaf + catalog + phys-del
    --check; MAIN_LINK Mac crt0_arm64 / Ubuntu crt0_x86_64; GLUE 2 expand OK)
  next: more shell-primary / lists residual or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_SEED_LINK_PICKS_LIST` | `1` |
| `PHYS_DEL_B7B_SEED_LINK_PICKS_LIST_COUNT` | `2` (product RELINK_XLANG_GLUE_SUFFIX) |
| `SWALLOWED_B7B_SEED_LINK_PICKS_LIST` | `1` |
| `B7B_SEED_LINK_PICKS_LIST_MK` | `mk/driver_seed_link_picks.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `02766b0b9` |

**Forbidden:** claim SEED_LINK_PICKS list→mk = physical delete; dual inline
`MAIN_LINK_O` / `GLUE_SUFFIX` / `LSP_DIAG_LINK_O` inventory in Makefile or
catalog hardcode; `rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave818 B7B DRIVER_SEED mode list → mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7B product list residual —
> seed mode picks `DRIVER_SEED_RUNTIME_O` / `DRIVER_SEED_FRONTEND_EXTRA` /
> `DRIVER_SEED_SUPPORT_EXTRA` (product **3**) / `DRIVER_SEED_LINK_FLAGS` /
> `DRIVER_SEED_RUNTIME_REBUILD` + `DRIVER_SEED_C_FRONTEND_LEGACY` move into
> `compiler/mk/driver_seed_mode_objs.mk`. Makefile **include only** (no dual
> inline re-list). `driver_seed_obj_catalog.sh` shell-parses the mk (drops
> SUPPORT_EXTRA / RUNTIME_O hardcodes). Composites still expand
> `$(DRIVER_SEED_SUPPORT_EXTRA)` / `$(DRIVER_SEED_RUNTIME_O)` into
> `DRIVER_SEED_OBJS` / `PREREQS`. Dual-end L2 required. Blockers **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`).

```text
  leaf dump:
    PHYS_DEL_B7B_SEED_MODE_LIST=1
    PHYS_DEL_B7B_SEED_MODE_LIST_WAVE=wave818
    PHYS_DEL_B7B_SEED_MODE_LIST_COUNT=3
    SWALLOWED_B7B_SEED_MODE_LIST=1
    PHYS_DEL_PREFLIGHT_B7B_SEED_MODE_LIST=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 0e70c2a9d (Mac + Ubuntu leaf + catalog + phys-del
    --check; SUPPORT_EXTRA/RUNTIME_O expand via mk include; LEGACY 5-leaf OK)
  next: more shell-primary / lists residual or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_SEED_MODE_LIST` | `1` |
| `PHYS_DEL_B7B_SEED_MODE_LIST_COUNT` | `3` (product SUPPORT_EXTRA inventory) |
| `SWALLOWED_B7B_SEED_MODE_LIST` | `1` |
| `B7B_SEED_MODE_LIST_MK` | `mk/driver_seed_mode_objs.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `0e70c2a9d` |
**Forbidden:** claim SEED_MODE list→mk = physical delete; dual inline
`DRIVER_SEED_SUPPORT_EXTRA` / `RUNTIME_O` inventory in Makefile or catalog
hardcode; `rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave817 B7B PIPELINE_X list → mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7B product list residual —
> `PIPELINE_X_BASE_OBJS` / `PIPELINE_X_FRONTEND_OBJS` /
> `PIPELINE_X_SATELLITE_OBJS` (9) / `PIPELINE_X_LINK_OBJS` /
> `PIPELINE_X_SUPPORT_OBJS` + product `PIPELINE_LIBS` (Linux `-lpthread`) move
> into `compiler/mk/pipeline_x_objs.mk`. Makefile **include only** (no dual
> inline re-list). `driver_seed_obj_catalog.sh` shell-parses the mk (drops
> `PIPELINE_LIBS` hardcode). `xlang-x-pipeline` / seed link / composites still
> expand `$(PIPELINE_X_*)` / `$(PIPELINE_LIBS)`. Dual-end L2 required. Blockers
> **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`).

```text
  leaf dump:
    PHYS_DEL_B7B_PIPELINE_X_LIST=1
    PHYS_DEL_B7B_PIPELINE_X_LIST_WAVE=wave817
    PHYS_DEL_B7B_PIPELINE_X_LIST_COUNT=9
    SWALLOWED_B7B_PIPELINE_X_LIST=1
    PHYS_DEL_PREFLIGHT_B7B_PIPELINE_X_LIST=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 1090cc667 (Mac + Ubuntu leaf + catalog + phys-del
    --check; PIPELINE_X_* / PIPELINE_LIBS expand via mk include)
  next: more shell-primary / lists residual or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_PIPELINE_X_LIST` | `1` |
| `PHYS_DEL_B7B_PIPELINE_X_LIST_COUNT` | `9` (satellite multi-line inventory) |
| `SWALLOWED_B7B_PIPELINE_X_LIST` | `1` |
| `B7B_PIPELINE_X_LIST_MK` | `mk/pipeline_x_objs.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `1090cc667` |
**Forbidden:** claim PIPELINE_X list→mk = physical delete; dual inline
`PIPELINE_X_*` / `PIPELINE_LIBS` inventory in Makefile or catalog hardcode;
`rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave816 B7B DRIVER_SUBCMD list → mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7B product list residual —
> `DRIVER_SUBCMD_OBJS` (7 leaves) + `DRIVER_LEAF_OBJS` / `DRIVER_SUBCMD_GEN` /
> `DRIVER_SUBCMD_GEN_ALL` / `DRIVER_SUBCMD_DIRS` move into
> `compiler/mk/driver_subcmd_objs.mk`. Makefile **include only** (no dual inline
> re-list). `driver_seed_obj_catalog.sh` shell-parses the mk (drops hardcode).
> Composites / seed link / relink still expand `$(DRIVER_SUBCMD_OBJS)`. Dual-end
> L2 required. Blockers **remain**
> (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`).

```text
  leaf dump:
    PHYS_DEL_B7B_DRIVER_SUBCMD_LIST=1
    PHYS_DEL_B7B_DRIVER_SUBCMD_LIST_WAVE=wave816
    PHYS_DEL_B7B_DRIVER_SUBCMD_LIST_COUNT=7
    SWALLOWED_B7B_DRIVER_SUBCMD_LIST=1
    PHYS_DEL_PREFLIGHT_B7B_DRIVER_SUBCMD_LIST=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 36b2db731 (Mac + Ubuntu leaf + catalog + phys-del
    --check; DRIVER_SUBCMD_OBJS expands in make export)
  next: more shell-primary / lists residual or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_DRIVER_SUBCMD_LIST` | `1` |
| `PHYS_DEL_B7B_DRIVER_SUBCMD_LIST_COUNT` | `7` |
| `SWALLOWED_B7B_DRIVER_SUBCMD_LIST` | `1` |
| `B7B_DRIVER_SUBCMD_LIST_MK` | `mk/driver_subcmd_objs.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `36b2db731` |

**Forbidden:** claim DRIVER_SUBCMD list→mk = physical delete; dual inline
`DRIVER_SUBCMD_OBJS` inventory in Makefile or catalog hardcode;
`rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave815 archaeology host-pick phonies shell-primary (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on archaeology host-pick phonies —
> multi-line `xlang_asm → xlang → xlang-c` ladders for **4** opt-in phonies move
> into `scripts/archaeology_host_pick_phony.sh`. Modes: `ensure|auto <phony>` ·
> `list` · `--check`. Makefile thin-call only: `ensure $@`. Catalog keys:
> `net-o-stub` · `net-o-openssl` · `net-o-mbedtls` · `sqlite-o-stub`. Host
> compile reuses `xlang_compile_std_x.sh auto` (single host-pick authority);
> nested product `.o` still via make try-heat. Dual-end L2 required. Blockers
> **remain** (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`).

```text
  leaf dump:
    PHYS_DEL_ARCH_HOST_PICK_PHONY=1
    PHYS_DEL_ARCH_HOST_PICK_PHONY_WAVE=wave815
    PHYS_DEL_ARCH_HOST_PICK_PHONY_COUNT=4
    SWALLOWED_ARCH_HOST_PICK_PHONY=1
    PHYS_DEL_PREFLIGHT_ARCH_HOST_PICK_PHONY=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  dual-end L2 green tip: 3d7a76306 (Mac + Ubuntu leaf + phys-del --check
    + sample net-o-stub / sqlite-o-stub ensure)
  next: more shell-primary / lists residual or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_ARCH_HOST_PICK_PHONY` | `1` |
| `PHYS_DEL_ARCH_HOST_PICK_PHONY_COUNT` | `4` |
| `SWALLOWED_ARCH_HOST_PICK_PHONY` | `1` |
| `ARCH_HOST_PICK_PHONY_HELPER` | `archaeology_host_pick_phony.sh` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |
| dual-end L2 tip | `3d7a76306` |

**Forbidden:** claim archaeology host-pick catalog = physical delete; dual
host-pick if-ladder in Makefile; `rm compiler/Makefile`; ship delete body;
mac-only wave green.

## wave814 driver_leaf shell-primary catalog (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on `driver_leaf_x_to_o.sh` — product
> leaf table (src + rename + cold seed + `-L` roots) lives in the shell.
> Modes: `ensure|auto <out.o>` · `list` · `--check`. Makefile **8** leaves
> thin-call only: `ensure $@` (source prereqs stay for mtime):
> `driver_{fmt,check,test,build,run,compile,emit}_x.o` + `lsp_io_std_heap_x.o`.
> Removes inline `DRIVER_COMPILE_RENAME` / `DRIVER_EMIT_RENAME` /
> `LSP_IO_STD_HEAP_RENAME` from Makefile (single catalog authority). Legacy
> explicit-arg CLI remains for g05 / `build_xlang_asm`. Dual-end L2 required.
> Blockers **remain** (`makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph`).

```text
  leaf dump:
    PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY=1
    PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY_WAVE=wave814
    PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY_COUNT=8
    SWALLOWED_DRIVER_LEAF_CATALOG=1
    PHYS_DEL_PREFLIGHT_DRIVER_LEAF_SHELL_PRIMARY=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  next: more shell-primary / lists residual or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY` | `1` |
| `PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY_COUNT` | `8` |
| `SWALLOWED_DRIVER_LEAF_CATALOG` | `1` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim driver_leaf catalog = physical delete; dual rename maps in
Makefile; `rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave813 B7B STD_AND_PANIC_O list → mk (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on B7B product list residual —
> `STD_AND_PANIC_O` (65 base leaves + Linux x86_64 freestanding append) lives in
> `compiler/mk/std_and_panic_objs.mk`. Makefile **include only** (no dual inline
> inventory). Consumers (`std-objs` / `test_c` / bootstrap-token/lexer/parser)
> still expand `$(STD_AND_PANIC_O)`. Lists stay mk (G.7). Dual-end L2 required.
> `std_core_product_make_graph` blocker **remains** (thin edges + B2 ensure +
> other mk lists).

```text
  leaf dump:
    PHYS_DEL_B7B_STD_AND_PANIC_LIST=1
    PHYS_DEL_B7B_STD_AND_PANIC_LIST_WAVE=wave813
    PHYS_DEL_B7B_STD_AND_PANIC_LIST_COUNT=65
    SWALLOWED_B7B_STD_AND_PANIC_LIST=1
    PHYS_DEL_PREFLIGHT_B7B_STD_AND_PANIC_LIST=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  next: more shell-primary / lists residual or tip Windows re-proof
       → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_STD_AND_PANIC_LIST` | `1` |
| `PHYS_DEL_B7B_STD_AND_PANIC_LIST_COUNT` | `65` |
| `SWALLOWED_B7B_STD_AND_PANIC_LIST` | `1` |
| `B7B_STD_AND_PANIC_LIST_MK` | `mk/std_and_panic_objs.mk` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** re-list `STD_AND_PANIC_O` inline in Makefile; dual shell inventory;
claim list→mk = physical delete; `rm compiler/Makefile`; mac-only wave green.

## wave812 formal_mod shell-primary · wave813 B7B STD_AND_PANIC list→mk catalog (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on `xlang_compile_std_module.sh` —
> formal product table (bare flag + sources + `fs_formal` dispatch) lives in the
> shell. Modes: `ensure|auto <out.o>` · `list` · `--check`. Makefile **38**
> formal_mod leaves thin-call only: `ensure $@` (source prereqs stay for mtime).
> Historic string.o host-pick ladder removed (script XLANG ladder covers it).
> `std_core_product_make_graph` blocker **remains** (thin edges + B2 ensure +
> B7B lists). Dual-end L2 required.

```text
  leaf dump:
    PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY=1
    PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY_WAVE=wave812
    PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY_COUNT=38
    SWALLOWED_FORMAL_MOD_CATALOG=1
    PHYS_DEL_PREFLIGHT_FORMAL_MOD_SHELL_PRIMARY=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  next: B7B lists residual / tip Windows re-proof → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY` | `1` |
| `PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY_COUNT` | `38` |
| `SWALLOWED_FORMAL_MOD_CATALOG` | `1` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim formal_mod catalog = physical delete; `rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave811 std_x product hybrid thin (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; ship delete body.
>
> **What this wave is:** G.7 **有则补全** on `xlang_compile_std_x.sh` — host pick,
> soft-skip, and socketio `ld -r` merge live in the shell authority. Makefile
> **22** pure `.x` product leaves thin-call only:
> `auto` | `auto-soft` | `auto-soft-merge`. Removes the multi-line `if [ -x
> ./xlang_* ]` ladder from product leaf recipes (sqlite-o-stub archaeology may
> still pick host). `std_core_product_make_graph` blocker **remains** (formal_mod
> + B2 ensure + list graph). Dual-end L2 required.

```text
  leaf dump:
    PHYS_DEL_STD_X_HYBRID_THIN=1
    PHYS_DEL_STD_X_HYBRID_THIN_WAVE=wave811
    PHYS_DEL_STD_X_HYBRID_THIN_COUNT=22
    SWALLOWED_STD_X_HYBRID_BODY=1
    PHYS_DEL_PREFLIGHT_STD_X_HYBRID_BODY_SWALLOWED=1
    PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
  next: more shell-primary (formal_mod / lists) → tip Windows re-proof → Mac+Ubuntu L4 → ship delete body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_STD_X_HYBRID_THIN` | `1` |
| `PHYS_DEL_STD_X_HYBRID_THIN_COUNT` | `22` |
| `SWALLOWED_STD_X_HYBRID_BODY` | `1` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done; delete deferred) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `continue_shell_primary_then_explicit_auth_ship_delete_body` |

**Forbidden:** claim std_x thin = physical delete; `rm compiler/Makefile`; ship delete body; mac-only wave green.

## wave810 delete-body commit honesty (2026-07-30)

> **Not this wave:** ship real `rm compiler/Makefile` body; physical delete.
>
> **What this wave is:** G.7 **有则补全** on `phys_del_makefile_gate.sh` —
> `--delete-body-commit-honesty` prints pre_ship inventory (Makefile present +
> TREE_ARMED green → CO_CHANGE list + MUST_UPDATE/MUST_NOT) and post_ship contract
> (Makefile already absent on a future tip). Never edits leaf. Never rm Makefile.
> Tree keeps ENDGAME=1 · TREE_ARMED=1 · BODY_SHIPPED=0 · Makefile present ·
> `--delete` still never-rm. Dual-end L2 required.

```text
  ./xbuild phys-del-gate --delete-body-commit-honesty
      # PHASE=pre_ship READY=1 when TREE_ARMED green + Makefile present
      # BODY_SHIPPED=0 DELETE_ALLOWED=0 DELETE_STILL_REFUSED=1; no leaf mutation; no rm
  leaf dump:
    PHYS_DEL_DELETE_BODY_COMMIT_HONESTY=1
    PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_WAVE=wave810
    PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_MODE=--delete-body-commit-honesty
    PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_BODY_SHIPPED=0
    PHYS_DEL_PREFLIGHT_NEXT=explicit_user_auth_then_ship_delete_body
  next: explicit user auth → ship --delete body (separate wave)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_DELETE_BODY_COMMIT_HONESTY` | `1` |
| `PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_WAVE` | `wave810` |
| `PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_MODE` | `--delete-body-commit-honesty` |
| `PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_BODY_SHIPPED` | `0` |
| `PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_TARGET_ACTION` | `rm_compiler_Makefile` |
| `PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_DELETE_ALLOWED` | `0` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `explicit_user_auth_then_ship_delete_body` |

**Forbidden:** claim delete-body-commit-honesty = ship body / physical delete;
`rm compiler/Makefile` in this wave; ship body without explicit user auth;
mac-only wave green.

## wave809 delete-body prep / preview (2026-07-30)

> **Not this wave:** ship real `rm compiler/Makefile` body; physical delete.
>
> **What this wave is:** G.7 **有则补全** on `phys_del_makefile_gate.sh` —
> `--delete-body-preview` after STATUS green + ENDGAME=1 + TREE_ARMED=1 prints
> the *exact* delete-body plan (TARGET=`rm_compiler_Makefile`, confirm env,
> co-change list). Preview never edits leaf. Preview ≠ ship body. Preview ≠
> physical delete. Tree keeps ENDGAME=1 · TREE_ARMED=1 · Makefile present ·
> `--delete` still never-rm. Dual-end L2 required.

```text
  ./xbuild phys-del-gate --delete-body-preview
      # exit 0 + PHYS_DEL_DELETE_BODY_PREVIEW_READY=1 when TREE_ARMED green
      # APPLIED=0 BODY_SHIPPED=0 DELETE_ALLOWED=0 always; no leaf mutation; no rm
  leaf dump:
    PHYS_DEL_DELETE_BODY_PREP=1
    PHYS_DEL_DELETE_BODY_PREP_WAVE=wave809
    PHYS_DEL_DELETE_BODY_PREP_MODE=--delete-body-preview
    PHYS_DEL_DELETE_BODY_PREP_BODY_SHIPPED=0
    PHYS_DEL_PREFLIGHT_NEXT=delete_body_commit_honesty_then_confirm_rm_separate
  next: delete-body commit honesty → confirm ship --delete body (separate wave)
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_DELETE_BODY_PREP` | `1` |
| `PHYS_DEL_DELETE_BODY_PREP_WAVE` | `wave809` |
| `PHYS_DEL_DELETE_BODY_PREP_MODE` | `--delete-body-preview` |
| `PHYS_DEL_DELETE_BODY_PREP_APPLIED` | `0` |
| `PHYS_DEL_DELETE_BODY_PREP_BODY_SHIPPED` | `0` |
| `PHYS_DEL_DELETE_BODY_PREP_TARGET_ACTION` | `rm_compiler_Makefile` |
| `PHYS_DEL_DELETE_BODY_PREP_DELETE_ALLOWED` | `0` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` (tree; arm already done) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `delete_body_commit_honesty_then_confirm_rm_separate` |

**Forbidden:** claim delete-body-preview = ship body / physical delete; `rm
compiler/Makefile` in this wave; mac-only wave green.

## wave808 reviewed TREE_ARMED arm (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`.
>
> **What this wave is:** reviewed mac commit sets tree
> `ENDGAME_PHYSICAL_DELETE_MAKEFILE=1` and
> `PHYS_DEL_ENDGAME_ARM_APPLY_TREE_ARMED=1` (+ `PHYS_DEL_ENDGAME_TREE_ARMED=1`).
> Honesty `--check` greps expect ENDGAME=1 · TREE_ARMED=1. STATUS stays
> `reproven_green`. `--delete` still dies at never-rm body (even with
> `XLANG_PHYS_DEL_CONFIRM=DELETE_MAKEFILE_I_UNDERSTAND`). Makefile remains.
> Dual-end L2 required.

```text
  leaf dump:
    ENDGAME_PHYSICAL_DELETE_MAKEFILE=1
    PHYS_DEL_ENDGAME_ARM_APPLY_TREE_ARMED=1
    PHYS_DEL_ENDGAME_TREE_ARMED=1
    PHYS_DEL_ENDGAME_TREE_ARMED_WAVE=wave808
    PHYS_DEL_ENDGAME_TREE_ARMED_DELETE_ALLOWED=0
    PHYS_DEL_PREFLIGHT_NEXT=delete_body_commit_honesty_then_confirm_rm_separate
  # --delete (with or without confirm) still refuses; Makefile present
  next: wave809 delete-body-preview → honesty → confirm ship body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_ENDGAME_TREE_ARMED` | `1` |
| `PHYS_DEL_ENDGAME_TREE_ARMED_WAVE` | `wave808` |
| `PHYS_DEL_ENDGAME_ARM_APPLY_TREE_ARMED` | `1` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `1` |
| `PHYS_DEL_ENDGAME_TREE_ARMED_DELETE_ALLOWED` | `0` |
| `PHYS_DEL_PREFLIGHT_NEXT` | `delete_body_commit_honesty_then_confirm_rm_separate` |
| `PHYS_DEL_WINDOWS_GATE_STATUS` | `reproven_green` |

**Forbidden:** claim tree arm = physical delete; `rm compiler/Makefile` in this
wave; skip dual-end L2; mac-only wave green.

## wave807 ENDGAME arm commit honesty (2026-07-30)

> **Not this wave:** set tree `ENDGAME_PHYSICAL_DELETE_MAKEFILE=1`; set
> `TREE_ARMED=1`; physical delete of `compiler/Makefile`.
> **This wave:** G.7 **有则补全** on `phys_del_makefile_gate.sh` —
> `--endgame-arm-commit-honesty` prints pre_arm inventory (ENDGAME=0) and
> post_arm contract (temp leaf ENDGAME=1 → STATUS green + `--delete` still
> refused + Makefile present). Never edits leaf. Never rm Makefile.
> Tree this tip keeps ENDGAME=0 · TREE_ARMED=0. Dual-end L2 required.

```text
Entry:
  ./xbuild phys-del-gate --endgame-arm-commit-honesty
      # PHASE=pre_arm when tree ENDGAME=0; CO_CHANGE list + MUST_UPDATE
  # --check: pre_arm on tree + post_arm on temp leaf after arm-apply
```

| Key | Value |
|-----|--------|
| `PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY` | `1` |
| `PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_WAVE` | `wave807` |
| `PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_TARGET_ENDGAME` | `1` |
| `PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_TARGET_TREE_ARMED` | `1` |
| `PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_DELETE_ALLOWED` | `0` |
| `PHYS_DEL_ENDGAME_ARM_APPLY_TREE_ARMED` | `0` (tree; honesty ≠ tree arm) |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `0` (tree) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `endgame_arm_commit_honesty_then_tree_arm_then_confirm_delete_separate` |

**Forbidden:** claim honesty = tree arm / physical delete; set ENDGAME=1 in this
wave; `rm compiler/Makefile`; mac-only wave green.

## wave806 ENDGAME arm apply harness (2026-07-30)

> **Not this wave:** set tree `ENDGAME_PHYSICAL_DELETE_MAKEFILE=1`; set
> `TREE_ARMED=1`; physical delete of `compiler/Makefile`.
> **This wave:** G.7 **有则补全** on `phys_del_makefile_gate.sh` —
> `--endgame-arm-apply` requires STATUS=`reproven_green` +
> `XLANG_PHYS_DEL_ENDGAME_ARM_APPLY=ARM_ENDGAME_I_UNDERSTAND` to rewrite
> leaf `ENDGAME_PHYSICAL_DELETE_MAKEFILE` 0→1 (or temp leaf via
> `XLANG_PHYS_DEL_LEAF_FILE`). Without confirm → exit 2. Keep STATUS green.
> Never rm Makefile. Even after ENDGAME=1, `--delete` still refuses (delete
> body deferred). Tree this tip keeps ENDGAME=0 · TREE_ARMED=0.
> Dual-end L2 required (mac + Ubuntu).

```text
Entry (STATUS already reproven_green after wave804):
  # plan only:
  ./xbuild phys-del-gate --endgame-preview
  # confirm-gated arm on leaf (or temp leaf for harness):
  XLANG_PHYS_DEL_ENDGAME_ARM_APPLY=ARM_ENDGAME_I_UNDERSTAND \
    ./xbuild phys-del-gate --endgame-arm-apply
      # exit 0 + PHYS_DEL_ENDGAME_ARM_APPLY_APPLIED=1 on write path
      # exit 2 without confirm / STATUS not green
      # --check exercises temp leaf only; tree ENDGAME stays 0

Then (later waves, not this tip):
  --endgame-arm-commit-honesty → reviewed TREE_ARMED=1 commit → confirm --delete body
```

| Key | Value |
|-----|--------|
| `PHYS_DEL_ENDGAME_ARM_APPLY_HARNESS` | `1` |
| `PHYS_DEL_ENDGAME_ARM_APPLY_HARNESS_WAVE` | `wave806` |
| `PHYS_DEL_ENDGAME_ARM_APPLY_TREE_ARMED` | `0` |
| `PHYS_DEL_ENDGAME_ARM_APPLY_TARGET_ENDGAME` | `1` |
| `PHYS_DEL_ENDGAME_ARM_APPLY_DELETE_ALLOWED` | `0` |
| `PHYS_DEL_ENDGAME_ARM_APPLY_CONFIRM_ENV` | `XLANG_PHYS_DEL_ENDGAME_ARM_APPLY=ARM_ENDGAME_I_UNDERSTAND` |
| `PHYS_DEL_WINDOWS_GATE_STATUS` | `reproven_green` (wave804) |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `0` (tree; harness ≠ tree arm) |
| `PHYS_DEL_PREFLIGHT_NEXT` | `endgame_arm_commit_honesty_then_tree_arm_then_confirm_delete_separate` (wave807) |

**Forbidden:** claim arm-apply harness = tree arm / physical delete; auto-arm
from preview alone; apply without confirm; `rm compiler/Makefile`; mac-only
wave green.

## wave804 Windows min-gate proof + STATUS apply (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; set
> `ENDGAME_PHYSICAL_DELETE_MAKEFILE=1`.  
> **This wave:** MSYS2 B-hybrid min-gate green on tip `bb8f07263` (return-value 42
> + win32 write/read) · proof stamp verified on Mac · reviewed confirm apply →
> `PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green` · `TREE_APPLIED=1` · ENDGAME stays 0
> · honesty `--check` expects green · `--delete` still refused.

| Key | Value |
|-----|--------|
| `PHYS_DEL_WINDOWS_GATE_STATUS` | `reproven_green` |
| `PHYS_DEL_STATUS_FLIP_APPLY_TREE_APPLIED` | `1` |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `0` |
| `PHYS_DEL_PREFLIGHT_NEXT` | `physical_delete_makefile_separate_wave_after_status_flip` (superseded by wave805 next) |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` (after) | still `0` until delete wave |

**Forbidden:** claim STATUS flip = physical delete; set ENDGAME=1 in this wave;
`rm compiler/Makefile` in this commit; mac-only product L4 claim.

## wave802 STATUS flip apply harness (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; set
> `ENDGAME_PHYSICAL_DELETE_MAKEFILE=1`; claim Windows green without MSYS proof.  
> **This wave:** G.7 **有则补全** on `phys_del_makefile_gate.sh` —
> `--status-flip-apply` rewrites `PHYS_DEL_WINDOWS_GATE_STATUS` only when
> (1) proof tip+RC verified and (2) confirm env is set. Without confirm → exit 2.
> Harness `--check` applies only to a **temp leaf copy**; tree STATUS stays
> `not_reproven_this_tip` until a human runs apply after real Windows proof.

```text
Entry (after scp'd proof on mac):
  ./xbuild phys-del-gate --verify-windows-proof
  ./xbuild phys-del-gate --status-flip-preview
  XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND \
    ./xbuild phys-del-gate --status-flip-apply
      # exit 0 + PHYS_DEL_STATUS_FLIP_APPLY_APPLIED=1
      # only STATUS key → reproven_green; ENDGAME stays 0
      # missing confirm / bad proof → exit 2

Then: mac commit of leaf STATUS flip (honesty greps for not_reproven updated
in that commit) → SEPARATE physical delete wave
```

| Key | Value |
|-----|--------|
| `PHYS_DEL_STATUS_FLIP_APPLY_HARNESS` | `1` |
| `PHYS_DEL_STATUS_FLIP_APPLY_HARNESS_WAVE` | `wave802` |
| `PHYS_DEL_STATUS_FLIP_APPLY_TREE_APPLIED` | `0` (tree not flipped this tip) |
| `PHYS_DEL_STATUS_FLIP_APPLY_TARGET_STATUS` | `reproven_green` |
| `PHYS_DEL_STATUS_FLIP_APPLY_ENDGAME_AFTER` | `0` |
| `PHYS_DEL_STATUS_FLIP_APPLY_DELETE_ALLOWED` | `0` |
| `PHYS_DEL_WINDOWS_GATE_STATUS` | `not_reproven_this_tip` (honest) |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `0` |

**Forbidden:** apply without proof / without confirm; set ENDGAME=1; delete
Makefile from apply; claim apply = physical delete; auto-flip from proof alone;
mac-only wave green.

Env: `XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND` · optional
`XLANG_PHYS_DEL_LEAF_FILE=` (test override).

## wave803 STATUS flip commit honesty (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; flip tree
> `PHYS_DEL_WINDOWS_GATE_STATUS` to green; set `ENDGAME_PHYSICAL_DELETE_MAKEFILE=1`.  
> **This wave:** G.7 **有则补全** on `phys_del_makefile_gate.sh` — machine-readable
> **commit checklist** for the STATUS flip mac commit (`--status-flip-commit-honesty`).
> Pre-flip (tree `not_reproven`): inventory of co-change surfaces + MUST_UPDATE/MUST_NOT.
> Post-flip (temp leaf after apply / future tip): require `STATUS=reproven_green` +
> `ENDGAME=0` + `--delete` still refused. Honesty greps that hard-require
> `not_reproven` must co-change in the same flip commit. Honesty ≠ flip. Honesty ≠ delete.

```text
Entry:
  ./xbuild phys-del-gate --status-flip-commit-honesty
      # PHASE=pre_flip when tree STATUS=not_reproven_this_tip
      # PHASE=post_flip POST_OK=1 after apply (temp leaf / flipped tip)
      # always DELETE_ALLOWED=0; ENDGAME_REQUIRED=0; never edits leaf

After real Windows proof + apply (future flip commit):
  1) apply STATUS → reproven_green (ENDGAME stays 0)
  2) --status-flip-commit-honesty → POST_OK=1
  3) same commit: update honesty --check greps + TREE_APPLIED=1 + progress triad
  4) dual-end L2; then SEPARATE physical delete wave
```

| Key | Value |
|-----|--------|
| `PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY` | `1` |
| `PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_WAVE` | `wave803` |
| `PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_ENDGAME_REQUIRED` | `0` |
| `PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED` | `0` |
| `PHYS_DEL_WINDOWS_GATE_STATUS` | `not_reproven_this_tip` (honest this tip) |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `0` |

**Forbidden:** claim honesty = STATUS flip / physical delete; set ENDGAME=1 in flip
commit; delete Makefile in flip commit; skip co-change honesty greps; mac-only wave green.

## wave801 STATUS flip prep / preview (2026-07-30)

> **Not this wave:** physical delete of `compiler/Makefile`; flip
> `PHYS_DEL_WINDOWS_GATE_STATUS` to green; set `ENDGAME_PHYSICAL_DELETE_MAKEFILE=1`.  
> **This wave:** G.7 **有则补全** on `phys_del_makefile_gate.sh` — after a
> verified Windows min-gate proof stamp, print a machine-readable *plan* for the
> reviewed STATUS flip commit. Preview ≠ flip. Preview ≠ physical delete.
> Preview never edits leaf keys.

```text
Entry (after scp'd proof on mac/Ubuntu):
  ./xbuild phys-del-gate --verify-windows-proof
  ./xbuild phys-del-gate --status-flip-preview
      # exit 0 + PHYS_DEL_STATUS_FLIP_PREVIEW_READY=1 when tip+RC OK
      # exit 2 when proof missing/mismatch
      # APPLIED=0 always; ENDGAME=0 always; no leaf mutation

After preview + human review:
  XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND \
    ./xbuild phys-del-gate --status-flip-apply   # wave802 harness
  mac commit (ENDGAME stays 0; honesty --check greps updated in that flip wave)
  then SEPARATE physical delete wave
  (never auto-edit leaf from preview / proof alone)
```

| Key | Value |
|-----|--------|
| `PHYS_DEL_STATUS_FLIP_PREP` | `1` |
| `PHYS_DEL_STATUS_FLIP_PREP_WAVE` | `wave801` |
| `PHYS_DEL_STATUS_FLIP_PREP_APPLIED` | `0` |
| `PHYS_DEL_STATUS_FLIP_PREP_TARGET_STATUS` | `reproven_green` |
| `PHYS_DEL_STATUS_FLIP_PREP_ENDGAME_AFTER_FLIP` | `0` |
| `PHYS_DEL_STATUS_FLIP_PREP_DELETE_ALLOWED` | `0` |
| `PHYS_DEL_WINDOWS_GATE_STATUS` | `not_reproven_this_tip` (honest) |
| `ENDGAME_PHYSICAL_DELETE_MAKEFILE` | `0` |

**Forbidden:** claim preview = STATUS flip / physical delete; auto-edit leaf from
preview; set ENDGAME=1 in STATUS flip wave; delete Makefile from preview; mac-only
wave green.

## wave877 B7B gen ensure multi-token env inject hygiene (2026-07-30)

> **Why (G.7 有则补全 on wave829 FORCE + wave862–864 multi-token hygiene):**
> Product `*_gen.c` leaves already shell-primary (`ensure_migrate_gen` /
> `ensure_lsp_pipeline_gen` / `ensure_archaeology_gen` / `ensure_driver_gen` /
> `ensure_ast_gen2`). Recipes still re-injected multi-token
> `MAKE=/XLANG_C=/XLANG_X=/XLANG_FORCE_REGEN_GEN=/TIMEOUT=` although every
> ensure script already defaults those vars. Dual inject = second authority
> path for the same env surface.

**This wave:** drop multi-token env inject on **20** recipes; thin `@bash scripts/ensure_*_gen…` only.
Shell defaults remain authority. Command-line overrides still flow via make recipe env.
`bootstrap-pipeline` keeps post-echo OK. **NOT** physical delete.

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE` | `1` |
| `PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE_COUNT` | `20` |
| `PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE_WAVE` | `wave877` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim gen env hygiene = physical delete; re-add multi-token MAKE/XLANG inject on ensure gen leaves.

## wave878 B7B migrate_x_objs multi-token env inject hygiene (2026-07-30)

> **Why (G.7 有则补全 on wave865 CFLAGS shell-load + wave877 inject hygiene):**
> Companion migrate leaves (`parser_x.o` / `typeck_x.o` / `codegen_x.o` /
> `migrate-x-objs`) already shell-primary via `migrate_x_objs.sh`. Recipes still
> re-injected multi-token `CC=/PYTHON=/MAKE=` although the script already defaults
> `CC=cc` / auto-PYTHON / `MAKE=make`. Dual inject = second authority path.

**This wave:** drop multi-token env inject on **4** recipes; thin `@sh scripts/migrate_x_objs.sh …` only.
Shell defaults remain authority. Command-line overrides still flow via make recipe env.
Keep `sh` (not bash) for Ubuntu dash-safe leaves (G.8 PLATFORM: SHARED). **NOT** physical delete.

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE` | `1` |
| `PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE_COUNT` | `4` |
| `PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE_WAVE` | `wave878` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim migrate env hygiene = physical delete; re-add multi-token CC/PYTHON/MAKE inject on migrate leaves.


## wave879 B7B stage/bootstrap multi-token env inject hygiene (2026-07-30)

> **Why (G.7 有则补全 on wave877/878 inject hygiene):** Stage/bootstrap thin leaves
> still re-injected multi-token `TARGET=/CC=/MAKE=/XLANG_*/PYTHON=` although shells
> already default those vars. Dual inject = second authority path.

**This wave:** drop multi-token env inject on **13** recipes; thin `@sh`/`@bash`/`./scripts` only.
Shell defaults remain authority. **NOT** physical delete.

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE` | `1` |
| `PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_COUNT` | `13` |
| `PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_WAVE` | `wave879` |

**Forbidden:** claim stage/bootstrap env hygiene = physical delete; re-add multi-token TARGET/CC/MAKE inject on those leaves.

## wave880 B7B ENSURE=0 / OUT=$@ / all OPT inject hygiene (2026-07-30)

> **Why (G.7 有则补全 on wave879 deferred intentional residual):** After stage/bootstrap
> multi-token hygiene, residual multi-token injects remained on:
> - `all` — `OPT=/MAKE=/TARGET=/XLANG_C=/XLANG_RUN_ALL_*=/XLANG_SKIP_*=`
> - `test_c` / `test_x` — `TARGET=/XLANG_C=/XLANG_TEST_ENSURE=0`
> - `check-7.2-bstrict` — `MAKE=/TARGET=/XLANG_VERIFY_ENSURE_BSTRICT=0`
> - archaeology link phonies — `MAKE=/CC=/OUT=$@` (seed-x-frontend / legacy xlang-c / xnc)
>
> Shells already own product defaults; ENSURE/OPT need make-graph vs direct-call
> distinction. **Root cause:** default policy lives in Makefile injects instead of
> shell MAKELEVEL-aware defaults (second authority).

**This wave:** drop multi-token inject on **7** recipes; thin `@bash`/`@sh` only.
Shell authority:
- `run_compiler_tests` / `bootstrap_verify_bstrict`: unset ENSURE + MAKELEVEL → 0; else → 1
- `compiler_all_ci`: unset OPT + MAKELEVEL → empty (bare make all no -O2); else → 1 (CI)
- archaeology OUT shells: default OUT from TARGET / product name
Command-line `make OPT=1` / process env still honored (GNU make exports cmdline vars).
**NOT** physical delete — thin edges + B2 + mk lists remain.

```text
PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE=1
PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE_WAVE=wave880
PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE_COUNT=7
PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE` | `1` |
| `PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE_COUNT` | `7` |
| `PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE_WAVE` | `wave880` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim ENSURE/OUT/OPT hygiene = physical delete; re-add ENSURE=0 /
OUT=$@ / multi-token OPT inject on these leaves; claim multi-token fat exhausted
while thin edges / B2 / mk lists remain.

## wave883 B7B residual single-token MAKE= inject hygiene (2026-07-30)

> **Why (G.7 有则补全 on wave882 TARGET inject hygiene):** After TARGET= pure/multi
> hygiene, residual single-token `MAKE="$(MAKE)"` recipe injects remained on nested-make
> thin leaves. Shells already default `MAKE="${MAKE:-make}"`; GNU make **auto-exports**
> `MAKE` into recipe environments. Dual inject = second authority path.

**This wave:** drop `MAKE="$(MAKE)"` on **24** recipes:
- **22 pure** thin-calls: archaeology host-pick (4) · `driver_leaf_x_to_o` (8) ·
  `bootstrap_driver_seed_rebuild_leaves` (7) · host_stubs (2) · phase1-link (1)
- **2 multi-token** bags: `bootstrap-driver-bstrict` / `refresh-xlang-asm-gate` drop
  MAKE=; keep `XLANG_BSTRICT_ENSURE_SEED=0` / `XLANG_BSTRICT_NO_REPLACE` intentional overrides

Shell + GNU make auto-export remain authority. **NOT** physical delete — thin edges +
B2 + mk lists + residual CC passthrough / G05_SYNC / LD bags remain.

```text
PHYS_DEL_B7B_MAKE_INJECT_HYGIENE=1
PHYS_DEL_B7B_MAKE_INJECT_HYGIENE_WAVE=wave883
PHYS_DEL_B7B_MAKE_INJECT_HYGIENE_COUNT=24
PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_MAKE_INJECT_HYGIENE` | `1` |
| `PHYS_DEL_B7B_MAKE_INJECT_HYGIENE_COUNT` | `24` |
| `PHYS_DEL_B7B_MAKE_INJECT_HYGIENE_WAVE` | `wave883` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim MAKE inject hygiene = physical delete; re-add `MAKE="$(MAKE)"`
recipe inject on these leaves; claim residual single-token inject family exhausted
while CC passthrough / G05_SYNC / LD / pipeline bags / thin edges remain
(CC closed in wave884).

## wave884 B7B residual single-token CC= inject hygiene (2026-07-30)

> **Why (G.7 有则补全 on wave883 MAKE inject hygiene):** After MAKE= pure/multi
> hygiene, residual single-token `CC="$(CC)"` recipe injects remained on the full
> try-heat / filter-bootstrap family (~118). Shells already source
> `scripts/resolve_host_cc.sh` (honor env → `cc` → `gcc`). Make **CLI** `CC=…`
> auto-exports into recipe env; parent `export CC` is honored. Dual recipe inject
> = second default-CC path (Makefile `CC ?=` is not auto-exported — shell resolve
> is the unset authority).

**This wave:** drop `CC="$(CC)"` on **118** recipes:
- **116 pure** thin-calls: `ensure_host_cc_seed_o.sh try-heat` (112 multi-line +
  10 single-line family; net 112 unique try-heat leaves) +
  `filter_bootstrap_seed_against_partial_o` (3) +
  `filter_bootstrap_seed_pipeline_o` (1)
- **2 multi-token** bags: `src/lexer/cfg_eval.o` keeps `LD`/`LD_RELFLAGS`;
  `pipeline_x.o` keeps `PIPELINE_X_DEPS` / `PIPELINE_X_FORCE_COMPILE` /
  `XLANG_FORCE_REGEN_GEN` — strip CC= only

Shell `resolve_host_cc` + CLI/env remain authority. **NOT** physical delete — thin
edges + B2 + mk lists + residual G05_SYNC / LD / pipeline bags remain.

```text
PHYS_DEL_B7B_CC_INJECT_HYGIENE=1
PHYS_DEL_B7B_CC_INJECT_HYGIENE_WAVE=wave884
PHYS_DEL_B7B_CC_INJECT_HYGIENE_COUNT=118
PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_CC_INJECT_HYGIENE` | `1` |
| `PHYS_DEL_B7B_CC_INJECT_HYGIENE_COUNT` | `118` |
| `PHYS_DEL_B7B_CC_INJECT_HYGIENE_WAVE` | `wave884` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim CC inject hygiene = physical delete; re-add recipe-line
`CC="$(CC)"` on these leaves; claim residual inject family exhausted while
G05_SYNC / LD / pipeline bags / thin edges remain
(G05_SYNC closed in wave885).

## wave885 B7B residual G05_SYNC inject hygiene (2026-07-30)

> **Why (G.7 有则补全 on wave884 CC inject hygiene):** After CC= pure/multi
> hygiene, residual `G05_SYNC_ASM=0/1` recipe injects remained on the two g05
> compatibility phonies (`relink-xlang` / `xlang_asm`). Shell already defaults
> `SYNC_ASM="${G05_SYNC_ASM:-1}"`. Dual recipe inject = second sync-policy path.

**This wave:** drop `G05_SYNC_ASM=` on **2** recipes:
- **relink-xlang** → thin `@sh scripts/g05_prepare_and_relink.sh --no-sync`
  (intentional no-sync; was `G05_SYNC_ASM=0`)
- **xlang_asm** → thin `@sh scripts/g05_prepare_and_relink.sh` (default sync;
  was `G05_SYNC_ASM=1` redundant with shell default)

Shell CLI (`--no-sync` / `--sync`) + env `G05_SYNC_ASM` (xbuild / refresh /
probes) remain authority. **NOT** physical delete — thin edges + B2 + mk lists +
residual LD / pipeline bags remain.

```text
PHYS_DEL_B7B_G05_SYNC_INJECT_HYGIENE=1
PHYS_DEL_B7B_G05_SYNC_INJECT_HYGIENE_WAVE=wave885
PHYS_DEL_B7B_G05_SYNC_INJECT_HYGIENE_COUNT=2
PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
```

| Key | Value |
|-----|-------|
| `PHYS_DEL_B7B_G05_SYNC_INJECT_HYGIENE` | `1` |
| `PHYS_DEL_B7B_G05_SYNC_INJECT_HYGIENE_COUNT` | `2` |
| `PHYS_DEL_B7B_G05_SYNC_INJECT_HYGIENE_WAVE` | `wave885` |
| `PHYS_DEL_PREFLIGHT_BLOCKERS` | still `makefile_thin_call_edges\|b7b_lists_in_mk\|std_core_product_make_graph` |

**Forbidden:** claim G05_SYNC inject hygiene = physical delete; re-add recipe-line
`G05_SYNC_ASM=` on these phonies; claim residual inject family exhausted while
LD / pipeline bags / thin edges remain.

