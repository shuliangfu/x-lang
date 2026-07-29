# Product + cold-start build DAG (11.1.1 · wave742 · 11.1.2 wave743 · 11.3 prereq edges wave744 · 11.1.3/4 wave745 · 11.3.1 path wave746 · R4 mode wave747 · R1 families wave748–752)

> **Authority (G.7):** this document is the **orchestration dependency map** for Track MG.  
> Object-list *definitions* stay in `compiler/mk/*.mk` (export via `driver_seed_obj_catalog.sh`).  
> **Do not** duplicate `.o` inventories here.  
> Machine-check: `compiler/scripts/product_build_dag.sh --check` · `./xbuild product-dag --check`.  
> Schedule execute (11.1.2): `./xbuild product-dag --dry-run` / `--run product`.  
> Prereq edges (wave744): `driver_seed_ensure_prereqs.sh` (catalog `DRIVER_SEED_PREREQS`).  
> Platform + linker policy (wave745 · 11.1.3/4): `compiler/docs/PLATFORM_LINKER.md` +  
> `host_platform_linker.sh` · `./xbuild host-platform` / `linker-policy`.  
> Leaf pattern residual (wave746 · 11.3.1 path · wave747 R4 mode · wave748–752 R1 families):  
> `compiler/docs/LEAF_PATTERN_RESIDUAL.md` + `leaf_pattern_residual.sh` ·  
> `./xbuild leaf-patterns` · `./xbuild host-cc-seed` / `core-seed` / `frontend-glue` / `main-runtime` / `alias-stubs` / `extra-cflags` / `misc-basename` / `seed-map`.

**PLATFORM: SHARED** — same node names on macOS / Ubuntu / Windows host shells; platform ABI lives inside leaf scripts and seed pins.

---

## 0. Scope (what this DAG is / is not)

| In scope | Out of scope (later) |
|----------|----------------------|
| Product daily path nodes + owners (11.1.1) | Full import-scan of user `.x` projects |
| Cold-start orchestration step order (11.1.1) | Parallel scheduler / ninja emit |
| Named schedules + dry-run / run (11.1.2) | Full pure-ld cold link without residual `CC -o` |
| Cold **prereq edge satisfaction** via shell (wave744) | Physical delete of Makefile (11.3 endgame) |
| Residual make *leaf* pattern rules **named** (wave746) | C `build_runtime` step table replace (11.1.5 endgame) |
| Host platform facts + linker residual inventory (wave745) | Makefile `UNAME` leaf rules fully swallowed |
| Leaf pattern residual inventory (wave746 · 11.3.1 path) | Physical delete of Makefile / leaf pattern rules |
| Single authority pointer per node | |

**Not yet:** replacing C `build_runtime` step table (ABI still `build_get_step_*` · 11.1.5).  
**Not yet:** physical delete of Makefile (11.3.1).  
**wave745:** 11.1.3/4 **policy + shell inventory** (not pure-ld endgame; residual `SEED_LINK_CC -o` named).  
**wave746:** 11.3.1 **path + named residual classes R1–R6** (not physical delete; not pure-ld).  
**wave747:** R4 mode-policy + catalog list in `rebuild_leaves` (pattern bodies still make).  
**wave748:** R1 first family **RT_SEED_SLICE** pure host-cc body → `ensure_host_cc_seed_o.sh`.  
**wave749:** R1 second family **R1_CORE_SEED** (diag/link_abi/c_import/bridge/compat) same body.  
**wave750:** R1 third family **R1_FRONTEND_GLUE** (lexer/ast/lsp basename-mismatch map) same body.  
**wave751:** R1 fourth family **R1_MAIN_RUNTIME** (main/runtime multi-flag variants) same body.  
**wave752:** R1 fifth family **R1_ALIAS_STUBS** (link alias / bare / compat stubs; pure basename) same body.
**wave753:** R1 sixth family **R1_EXTRA_CFLAGS** (pipeline_abi / -fPIE / sqlite multi-flag / parser extras) same body (other R1 residual).
**wave754:** R1 seventh family **R1_MISC_BASENAME** (misc pure basename glue/enc/ctx/pipeline_glue/asm_build) same body.  
**wave755:** R1 eighth family **R1_SEED_MAP** (target_cpu/ast_seed mismatch + bootstrap orch -D) same body (residual R3/R4/pure-ld).  
**wave756:** R4 pure-R1 body — `rebuild_leaves` → `ensure try-r1` for catalog pure R1 members; non-R1 residual still make.  
**wave757:** R3 cold-else body — `rebuild_leaves` residual → `ensure try-r3-cold` (catalog `R3_COLD_SEED_OBJS`).  
**wave763:** R3 PREFER thin — Makefile nine leaves → `ensure try-r3-prefer` (same catalog).  
**wave764:** g05 R3_COLD → `r3-prefer-family` (full→thin ladder; dual hybrid deleted).  
**wave765:** g05 labi multi-slice → `try-labi-prefer` (g05/Makefile thin-call; dual hybrid deleted).  
**wave766:** g05 rt multi-slice → `try-rt-prefer` (g05/Makefile thin-call; dual hybrid deleted); residual pipeline_abi/ldpc.  
**wave767:** g05 pipeline_abi + ldpc → `try-pipeline-abi-prefer` / `try-ldpc-prefer` (g05/Makefile thin-call; dual hybrid deleted); residual target_cpu.  
**wave768:** g05 target_cpu → `try-target-cpu-prefer` (g05/Makefile thin-call; dual hybrid deleted); residual other L2 · pure-ld.  
**wave779:** B1 runtime_* OS/glue dual hybrid → `try-runtime-os-prefer` (23 Makefile thin-call; not physical delete).  
**wave780:** B2 std/core product hybrid → `try-std-core-prefer` (5 Makefile thin-call; not physical delete).  
**wave781:** B3 LSP satellite hybrid → `try-lsp-sat-prefer` (2 Makefile thin-call; not physical delete).  
**wave782:** B4 gen_c_to_o bootstrap → `try-gen-c-to-o` (5 Makefile thin-call; body `ensure_gen_x_o.sh`; not physical delete).  
**wave758:** R4 residual thin_glue → R1 seed-map (G.7 有则补全) — `parser_asm_thin_glue` pure host-cc; user-asm shell-only.  
**wave759:** R4 residual glue standalone → R1 seed-map (G.7 有则补全) — `pipeline_glue_standalone` pure host-cc; glue shell-only.

---

## 1. Product daily path (zero make for gen bodies + link)

Edges are **must-precede** (left → right). Outer entry is always `./xbuild`.

```text
[ensure_migrate_gen] ─┐
[ensure_driver_gen]  ─┼─→ [migrate_x_objs] ─→ [g05_ensure] ─→ [g05_prepare_and_relink]
[ensure_lsp_pipeline]─┘         │                    │
                                │                    ├─→ product xlang
                                │                    └─→ (SYNC_ASM=1) xlang_asm
                                └─→ [refresh_xlang_asm_gate] = migrate + g05 + overlay
```

| Node id | xbuild target | Body authority (G.7) | Residual make? |
|---------|---------------|----------------------|----------------|
| `ensure_migrate_gen` | `migrate-gen` / `lexer-gen` | `scripts/ensure_migrate_gen.sh` | only missing `xlang-c` for force -E |
| `ensure_driver_gen` | `driver-gen` / `preprocess-gen` | `scripts/ensure_driver_gen.sh` | same |
| `ensure_lsp_pipeline_gen` | `lsp-gen` / `pipeline-gen` | `scripts/ensure_lsp_pipeline_gen.sh` | same |
| `ensure_archaeology_gen` | `archaeology-gen` | `scripts/ensure_archaeology_gen.sh` | **off product link** (Track L) |
| `migrate_x_objs` | `migrate` | `scripts/migrate_x_objs.sh` | 0× for `_x.o` body |
| `g05_ensure` | `ensure` | `scripts/g05_ensure_relink_prereqs.sh` | leaf rebuild may touch make graph |
| `g05_link_env` | `link-env` | `scripts/g05_relink_env.sh` | 0 |
| `g05_prepare_and_relink` | `link-product` / `link-product-asm` | `scripts/g05_prepare_and_relink.sh` | 0 for product link |
| `refresh_gate` | `refresh-gate` | `scripts/refresh_xlang_asm_gate.sh` | 0× migrate body |
| `build_tool_product` | `all` / `build` / `xlang` | `build_tool` → `g05_build_xlang_asm.sh` | product path 0-make gate |

**CI distinct path (not product `all`):**

```text
./xbuild compiler-all  →  scripts/compiler_all_ci.sh  →  make xlang (g05 product · wave786 B7D) + xlang-c (seed · wave784 B6; heat try-heat wave789 · thin-unify wave790 · cold residual_make=0 wave787 · catalog shell wave788; Makefile dep edges residual)
```

---

## 2. Schedules (11.1.2 · wave743) — execute inventory without re-implementing bodies

Named schedules live in `product_build_dag.sh` (single authority with the inventory).  
`run` only `bash`es existing body scripts (cwd = `compiler/`). **No second compile/link path.**

### 2.1 Profile `product` (daily gen → migrate → link)

```text
ensure_migrate_gen
ensure_driver_gen
ensure_lsp_pipeline_gen
migrate_x_objs
g05_prepare_and_relink     # embeds g05_ensure + g05_link_env + link
```

| Intentionally **not** in `product` | Why |
|------------------------------------|-----|
| `ensure_archaeology_gen` | Track L; product PREFER_X_O does not consume |
| standalone `g05_ensure` / `g05_link_env` | Embedded inside `g05_prepare_and_relink` (G.7 no double) |
| `refresh_gate` | Separate P0 gate profile |

### 2.2 Profile `refresh`

```text
refresh_gate
```

### 2.3 Profile `cold`

Dry-run prints inventory order (starts with `cold_ensure_prereqs` · wave744).  
Live `--run cold` invokes **outer** `./xbuild bootstrap-driver-seed` once  
(orchestrator embeds `driver_seed_ensure_prereqs` + §5b sequence).  
Does **not** re-walk each cold leaf body.

### 2.4 CLI

```text
./xbuild product-dag --dry-run product   # or refresh | cold
./xbuild product-dag --run product
./xbuild dag-dry-run cold
./xbuild dag-run refresh
./xbuild driver-seed-prereqs             # dry-run/check/run ensure edges
bash compiler/scripts/product_build_dag.sh dry-run product
```

---

## 3. Cold-start path (`bootstrap-driver-seed`)

Two layers after wave744:

1. **Prereq edge satisfaction (shell)** — `driver_seed_ensure_prereqs.sh` expands  
   catalog `DRIVER_SEED_PREREQS` (+ glue companion) and invokes Make for those targets.  
   List authority remains `compiler/mk/driver_seed_composites.mk` (G.7 no dual list).  
2. **Shell orchestration** — `scripts/bootstrap_driver_seed.sh` (ordered steps below).  
3. **Leaf pattern rules (residual make)** — host-cc residual C until 11.3 / stage 8–9.

```text
driver_seed_ensure_prereqs.sh  ← catalog DRIVER_SEED_PREREQS + pipeline_glue_strict_minimal.o
        │
        ▼
bootstrap_driver_seed.sh (ordered):
  0  driver_seed_ensure_prereqs.sh --run     (wave744)
  1  check_pipeline_gen_expr_i64_abi.sh      (§5b #1 pure shell)
  2  bootstrap-driver-seed-pipeline-x        (export + rebuild_leaves)
  3  bootstrap-driver-seed-sat-rebuild
  4  bootstrap-driver-seed-lsp-x-objs
  5  bootstrap-driver-seed-bridge
  6  bootstrap-driver-seed-user-asm-seed-objs
  7  bootstrap-driver-seed-asm-glue-standalone
  8  bootstrap-driver-seed-asm-host          → build_seed_asm_host.sh
  9  bootstrap-driver-seed-host-stubs        → host_stubs.sh
 10  bootstrap-driver-seed-filtered-objs     (Darwin class-G; empty Linux)
 11a bootstrap-driver-seed-phase1-link       → link.sh phase1
 11b bootstrap-driver-seed-final-link        → link.sh final
 12  bootstrap-driver-seed-panic
 13  smoke + product binary aliases
```

| Layer | Authority | Status |
|-------|-----------|--------|
| `.o` / composite lists | `compiler/mk/*.mk` + `export-obj-catalog` | ✅ single (G.7) |
| Prereq **edge satisfaction** | `driver_seed_ensure_prereqs.sh` | ✅ wave744 (shell) |
| Step **sequence** | `bootstrap_driver_seed.sh` | ✅ shell (wave717+) |
| Leaf **bodies** | `*_rebuild_leaves` / `*_link` / `*_host_stubs` / … | ✅ shell (§5b) |
| Leaf **pattern rules** (how .o is built) | Makefile residual | 🟡 → 11.3 endgame |
| Outer entry | `./xbuild bootstrap-driver-seed` | ✅ thin Makefile phony |
| Schedule dry-run / outer run | `product_build_dag.sh` 11.1.2 | ✅ wave743+744 |

**Obj catalog (read-only, no second list):**

```text
./xbuild compiler-make bootstrap-driver-seed-export-obj-catalog
# or: (cd compiler && bash scripts/driver_seed_obj_catalog.sh --check)
# prereq edges dry-run:
./xbuild driver-seed-prereqs
```

---

## 4. Strategy facade vs execution DAG

| Layer | File / tool | Role |
|-------|-------------|------|
| Policy map | root `build.x` | Human strategy + pin-stable `build_get_step_*` ABI |
| Orchestration DAG | **this doc** + `product_build_dag.sh` | 11.1.1 inventory + 11.1.2 schedules + wave744 edges |
| Host platform + linker policy | `PLATFORM_LINKER.md` + `host_platform_linker.sh` | 11.1.3 facts · 11.1.4 residual inventory (wave745) |
| Leaf pattern residual map | `LEAF_PATTERN_RESIDUAL.md` + `leaf_pattern_residual.sh` | 11.3.1 path inventory (wave746) |
| Product entry | `./xbuild` → `xlang-build.sh` | First-class targets |
| Cold leaf pattern residual | `compiler/Makefile` | Until 11.3.1 physical delete |
| Step table (legacy) | C `build_runtime` + `build_get_step_at` | Domain B bootstrap; not user API |

---

## 5. Residual make graph (named · 11.3 endgame)

Do **not** grow new free-form recipes. Known residual classes:

| Residual | Notes |
|----------|--------|
| ~~`DRIVER_SEED_PREREQS` make-graph edges~~ | **swallowed wave744** → shell ensure (list still mk) |
| Leaf `.o` pattern rules (R1–R5) | **named inventory wave746** · … · **B7D TARGET→g05 wave786** · **B7A cold residual_make=0 wave787** · **B7B shell catalog wave788** · **B7A heat try-heat wave789** · **B7A heat thin-unify wave790** · residual Makefile dep edges + physical delete after Windows → 11.3.1 |
| `compiler-all` / Makefile `all` | CI path (R5 · wave784 shell body; `xlang` = g05 wave786; heat try-heat wave789 + thin-unify wave790; Makefile dep edges B7A residual) |
| FULL=1 bstrict make entry | Non-daily |
| Missing `xlang-c` for force -E | ensure_* gen scripts |
| Cold `SEED_LINK_CC -o` (R6) | **named wave745** · pure-ld endgame → 11.1.4 |

Human + machine map: `compiler/docs/LEAF_PATTERN_RESIDUAL.md` ·
`./xbuild leaf-patterns --check`.

---

## 6. Acceptance

### wave742 (11.1.1 inventory)

- [x] This document present under `compiler/docs/BUILD_DAG.md`
- [x] `product_build_dag.sh dump` prints product + cold node ids
- [x] `product_build_dag.sh --check` verifies body scripts + xbuild wiring
- [x] 0-make gate hard-checks the above

### wave743 (11.1.2 schedule execute)

- [x] Named schedules `product` / `refresh` / `cold` in `product_build_dag.sh`
- [x] `--dry-run` prints ordered STEPs for each profile
- [x] `--run product` invokes existing bodies only (no dual .o / no second linker)
- [x] product schedule skips archaeology + standalone g05_ensure/link_env
- [x] cold live run = outer `bootstrap-driver-seed`
- [x] `--check` exercises dry-run all profiles
- [ ] Full .x import-scan incremental graph (later 11.1.2 endgame)
- [ ] 11.1.3/4 platform + linker nodes fully non-cc (future)

### wave744 (11.3 residual · DRIVER_SEED_PREREQS edge swallow)

- [x] `driver_seed_ensure_prereqs.sh` expands catalog + glue companion (no dual list)
- [x] `bootstrap_driver_seed.sh` step 0 calls ensure `--run`
- [x] Makefile `bootstrap-driver-seed` is thin phony (no `$(DRIVER_SEED_PREREQS)` make deps)
- [x] cold dry-run surfaces `cold_ensure_prereqs` + `PREREQ=` lines
- [x] `product_build_dag.sh --check` + 0-make gate hard-check ensure
- [ ] Physical delete of Makefile / leaf pattern rules (11.3.1 endgame)
- [ ] Leaf `.o` builds without host-cc residual (stages 8–9 / 12)

### wave745 (11.1.3 platform + 11.1.4 linker policy)

- [x] `compiler/docs/PLATFORM_LINKER.md` authority map
- [x] `host_platform_linker.sh` platform/linker dump + `--check`
- [x] `./xbuild host-platform` / `linker-policy` first-class
- [x] build.x §F + this doc cross-ref
- [x] 0-make gate hard-check + live `--check`
- [ ] Cold phase1/final without residual `SEED_LINK_CC -o` (11.1.4 endgame)
- [ ] Makefile `UNAME` leaf rules fully swallowed (with 11.3.1)

### wave746 (11.3.1 path · leaf pattern residual inventory)

- [x] `compiler/docs/LEAF_PATTERN_RESIDUAL.md` authority map (R1–R6)
- [x] `leaf_pattern_residual.sh` dump/classes/`--check`
- [x] `./xbuild leaf-patterns` / `leaf-residual` first-class
- [x] build.x §F + this doc residual section cross-ref
- [x] 0-make gate hard-check + live `--check` / dump
- [ ] Physical delete of Makefile / leaf pattern rules (11.3.1 endgame)
- [ ] Leaf `.o` builds without host-cc residual (stages 8–9 / 12)

### wave747 (11.3.1 · R4 mode-policy swallow)

- [x] `bootstrap_driver_seed_rebuild_leaves.sh` default = catalog KEY + shell mode table
- [x] Mode ARGS/VARS authority in shell (sat `-B` / PREFER_X_O / PIPELINE_X_FORCE)
- [x] Lists still mk via `driver_seed_obj_catalog.sh` (no dual `.o`)
- [x] Pattern bodies still `make` (honest R4 residual)
- [x] `XLANG_REBUILD_LEAVES_VIA_EXPORT=1` legacy escape
- [x] LEAF_PATTERN dump `SWALLOWED_R4_MODE_POLICY=1` / `R4_PATTERN_BODY_STILL_MAKE=1`
- [ ] Rebuild without make pattern graph (R4 endgame)
- [ ] Physical delete of Makefile (11.3.1 endgame)

### wave748 (11.3.1 · R1 first family rt-seed-slice)

- [x] `ensure_host_cc_seed_o.sh` pure host-cc body (`one` + `rt-slice`)
- [x] List authority = catalog `RT_SEED_SLICE_OBJS` (export + REQUIRED_KEYS)
- [x] Makefile five `src/runtime/rt_*.o` thin-call the script
- [x] `./xbuild host-cc-seed` / `rt-seed-slice` + `--check`
- [x] LEAF_PATTERN dump `SWALLOWED_R1_RT_SEED_SLICE=1` / `R1_OTHER_HOST_CC_STILL_MAKE=1`

### wave749 (11.3.1 · R1 second family core-seed)

- [x] Same body + `core-seed` / `all` modes
- [x] List authority = catalog `R1_CORE_SEED_OBJS` (export + REQUIRED_KEYS)
- [x] Makefile five core leaves thin-call (diag / link_abi / c_import / bridge / compat)
- [x] `./xbuild core-seed` · umbrella `host-cc-seed` = all swallowed families
- [x] LEAF_PATTERN dump `SWALLOWED_R1_CORE_SEED=1` / `R1_CORE_SEED_SWALLOWED=1`

### wave750 (11.3.1 · R1 third family frontend-glue)

- [x] Same body + `frontend-glue` / `all` modes (basename-mismatch seed map)
- [x] List authority = catalog `R1_FRONTEND_GLUE_OBJS` (export + REQUIRED_KEYS)
- [x] Makefile three glue leaves thin-call (lexer / ast / lsp_diag)
- [x] `./xbuild frontend-glue` · umbrella `host-cc-seed` = three families
- [x] LEAF_PATTERN dump `SWALLOWED_R1_FRONTEND_GLUE=1` / `R1_FRONTEND_GLUE_SWALLOWED=1`

### wave751 (11.3.1 · R1 fourth family main-runtime)

- [x] Same body + `main-runtime` / `all` modes (multi-flag o→seed + o→-D map)
- [x] List authority = catalog `R1_MAIN_RUNTIME_OBJS` (export + REQUIRED_KEYS)
- [x] Makefile seven leaves thin-call (main / main_x / main_driver / runtime / runtime_x / runtime_driver / runtime_driver_no_c)
- [x] `./xbuild main-runtime` · umbrella `host-cc-seed` = four families
- [x] LEAF_PATTERN dump `SWALLOWED_R1_MAIN_RUNTIME=1` / `R1_MAIN_RUNTIME_SWALLOWED=1`

### wave752 (11.3.1 · R1 fifth family alias-stubs)

- [x] Same body + `alias-stubs` / `all` modes (pure basename)
- [x] List authority = catalog `R1_ALIAS_STUBS_OBJS` (export + REQUIRED_KEYS)
- [x] Makefile eight leaves thin-call (frontend/bare aliases + typeck stubs + user_asm bridge + backend compat + strict glue stubs)
- [x] `./xbuild alias-stubs` · umbrella `host-cc-seed` = five families
- [x] LEAF_PATTERN dump `SWALLOWED_R1_ALIAS_STUBS=1` / `R1_ALIAS_STUBS_SWALLOWED=1`

### wave753 (11.3.1 · R1 sixth family extra-cflags)

- [x] Same body + `extra-cflags` / `all` modes (o→seed + o→extra flag map)
- [x] List authority = catalog `R1_EXTRA_CFLAGS_OBJS` (export + REQUIRED_KEYS)
- [x] Makefile five leaves thin (pipeline_abi / -fPIE / sqlite×2 / parser)
- [x] `./xbuild extra-cflags` · umbrella `host-cc-seed` = six families
- [x] LEAF_PATTERN dump `SWALLOWED_R1_EXTRA_CFLAGS=1` / `R1_EXTRA_CFLAGS_SWALLOWED=1`

### wave754 (11.3.1 · R1 seventh family misc-basename)

- [x] Same body + `misc-basename` / `all` modes (pure basename)
- [x] List authority = catalog `R1_MISC_BASENAME_OBJS` (export + REQUIRED_KEYS)
- [x] Makefile nine leaves thin-call ensure (glue/enc/ctx/pipeline_glue/asm_build/…)
- [x] `./xbuild misc-basename` · umbrella `host-cc-seed` = seven families
- [x] LEAF_PATTERN dump `SWALLOWED_R1_MISC_BASENAME=1` / `R1_MISC_BASENAME_SWALLOWED=1`

### wave755 (11.3.1 · R1 eighth family seed-map)

- [x] Same body + `seed-map` / `all` modes (o→seed + orch extras)
- [x] List authority = catalog `R1_SEED_MAP_OBJS` (export + REQUIRED_KEYS)
- [x] Makefile three leaves thin-call ensure (target_cpu / ast_seed / orch)
- [x] `./xbuild seed-map` · umbrella `host-cc-seed` = eight families
- [x] LEAF_PATTERN dump `SWALLOWED_R1_SEED_MAP=1` / `R1_SEED_MAP_SWALLOWED=1`
- [x] residual after: R3 · R4 body · pure-ld · physical delete

### wave756 (11.3.1 · R4 pure-R1 body)

- [x] `rebuild_leaves` splits pure R1 (`ensure try-r1`) vs residual make
- [x] `try-r1` membership = catalog eight R1 KEY union (G.7 no dual list)
- [x] bridge mode pure-R1 only → no make pattern
- [x] LEAF dump `SWALLOWED_R4_BODY_PURE_R1=1` · `R4_BODY_PURE_R1_SWALLOWED=1`
- [x] `R4_PATTERN_BODY_STILL_MAKE=1` honest (non-R1 residual)

### wave757 (11.3.1 · R3 cold-else body)

- [x] catalog `R3_COLD_SEED_OBJS` (9 objs; G.7 list = mk)
- [x] `try-r3-cold` + rebuild residual path before make
- [x] Makefile cold-else thin-call ensure  
- [x] wave763: try-r3-prefer + Makefile nine thin-call (R3_COLD PREFER)
- [x] wave764: g05 r3-prefer-family + full→thin ladder (R3_COLD product daily)
- [x] LEAF dump `SWALLOWED_R3_COLD_ELSE=1` · `R3_COLD_ELSE_SWALLOWED=1`

### wave758 (11.3.1 · R4 residual thin_glue → seed-map)

- [x] `parser_asm_thin_glue.o` on `R1_SEED_MAP_OBJS` (G.7 有则补全)
- [x] seed/extras map + `*.inc` freshness; Makefile thin-call ensure
- [x] user-asm shell-only (residual_make=0)
- [x] LEAF dump `SWALLOWED_R4_BODY_THIN_GLUE=1`

### wave759 (11.3.1 · R4 residual glue standalone → seed-map)

- [x] `build_asm/pipeline_glue_standalone.o` on `R1_SEED_MAP_OBJS` (G.7 有则补全)
- [x] seed/extras map + glue/ast_pool/types.inc freshness; Makefile thin-call ensure
- [x] glue shell-only (residual_make=0)
- [x] LEAF dump `SWALLOWED_R4_BODY_GLUE_STANDALONE=1`
- [x] g05 labi multi-slice PREFER (wave765) · g05 rt multi-slice PREFER (wave766)
- [x] g05 pipeline_abi + ldpc PREFER (wave767 try-pipeline-abi-prefer / try-ldpc-prefer)
- [x] g05 target_cpu PREFER (wave768 try-target-cpu-prefer)
- [x] B1 runtime-os PREFER (wave779 try-runtime-os-prefer · 23 thin-call)
- [x] B2 std-core PREFER (wave780 try-std-core-prefer · 5 thin-call)
- [x] B3 lsp-sat PREFER (wave781 try-lsp-sat-prefer · 2 thin-call)
- [ ] B4–B5 body swallow · physical delete

---

## References

- `analysis/C迁移追踪.md` §11.1.1–4 · §11.3 · §11.3.1  
- `compiler/docs/LEAF_PATTERN_RESIDUAL.md`  

- `analysis/Makefile迁移表.md` §5b cold whitelist  
- `build.x` strategy map (11.1.5)  
- `compiler/docs/PLATFORM_LINKER.md` (11.1.3/4 · wave745)  
- `compiler/scripts/driver_seed_obj_catalog.sh` (lists)  
- `compiler/scripts/driver_seed_ensure_prereqs.sh` (edges · wave744)  
- `compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh` (R4 mode · pure-R1 · R3 cold · thin_glue · glue-standalone)  
- `compiler/scripts/ensure_host_cc_seed_o.sh` (R1 families · try-r1 · try-r3-cold · thin_glue/glue-standalone seed-map)  
- `compiler/scripts/host_platform_linker.sh` (platform + linker · wave745)

## wave796 B7A heat dep-edge thin net·panic·gen_x (2026-07-30)

- **Not physical delete.** net multi-merge · panic stamp · gen_x/B4 (+11 → **112 FORCE**).
- Shell: net_merge multi `.x`/seed mtime · panic host pick+stamp · try-heat → try-gen-x/c-to-o
  (`PIPELINE_X_DEPS` env; `lsp_io.x`).
- Residual: orch · physical delete after Windows.
- LEAF: `DEP_THIN_COUNT=112` · `HEAT_RESIDUAL=1`.

## wave795 B7A heat dep-edge thin cfg_eval·asm·std (2026-07-30)

- **Not physical delete.** cfg_eval multi · pure asm (crt0/freestanding/typeck_f64) ·
  std direct path/runtime · process merge (+15 → **101 FORCE**). Host ifeq for crt0/typeck kept.
- Shell: try-cfg-eval-ladder multi-seed mtime · try-r2 .s/seed · std-core-prefer seed/.x/peer ·
  `force_thin_makefile_flags_newer` includes `crt0_mingw`.
- Residual: net multi-merge · panic stamp · gen_x · orch.
- LEAF: `DEP_THIN_COUNT=101` · `HEAT_RESIDUAL=1`.

## wave794 B7A heat dep-edge thin twin·Makefile-flags·pure leftover (2026-07-30)

- **Not physical delete.** Twin / Makefile-flags / pure leftover residual (+8 → **86 FORCE**):
  `runtime_scheduler_glue` · `runtime_driver_strict_glue_stubs` · `pipeline_glue_standalone` ·
  `core/slice` · `main_driver` · `runtime_driver{,_no_c}` · `runtime_pipeline_abi`.
- Shell: `seed_project_hdrs_newer` (twin #include first-hop) + `force_thin_makefile_flags_newer`
  (Makefile mtime only for flag-sensitive leaves).
- Residual: cfg_eval multi · asm/gen · stamp · std merge · gen_x.
- LEAF: `DEP_THIN_COUNT=86` · `HEAT_RESIDUAL=1`.

## wave793 B7A heat dep-edge thin pure seed+.x+.h residual (2026-07-30)

- **Not physical delete.** Pure seed+.x+.h residual (+19 → **78 FORCE**): Makefile prereqs → FORCE + ensure; shell `seed_project_hdrs_newer` owns project-header mtime (with seed/.x).
- Residual: twin/c multi/asm/gen/Makefile/stamp leaves.

## wave792 B7A heat dep-edge thin pure seed+.x residual (2026-07-30)

- **Not physical delete.** Pure seed+.x residual (+31 → **59 FORCE** with wave791): R1/async/rt/alias/L2/lsp/… → FORCE + ensure; shell mtime.
- Residual heat: hdr/c/asm/stamp/twin (scheduler · strict_glue_stubs) / cfg_eval multi / gen.
- LEAF: `DEP_THIN_COUNT=59` · `HEAT_RESIDUAL=1`.

## wave791 B7A heat dep-edge thin (2026-07-30)

- **Not physical delete.** Pure `runtime_*` seed+.x leaves (28): Makefile prereqs → `FORCE` + `ensure_host_cc_seed_o.sh`; `try-heat` owns seed/.x mtime.
- Superseded count by wave792 (59 total FORCE pure seed+.x).
