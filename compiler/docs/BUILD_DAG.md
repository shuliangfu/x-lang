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
> `./xbuild leaf-patterns` · `./xbuild host-cc-seed` / `core-seed` / `frontend-glue` / `main-runtime` / `alias-stubs` / `extra-cflags`.

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
./xbuild compiler-all  →  tests/lib/compiler-make.sh  →  Makefile `all` (host-cc/seed)
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
| Leaf `.o` pattern rules (R1–R5) | **named inventory wave746** · **R4 mode+list shell wave747** · **R1 rt-slice wave748** · **R1 core-seed wave749** · **R1 frontend-glue wave750** · **R1 main-runtime wave751** · **R1 alias-stubs wave752** · **R1 extra-cflags wave753** · other pattern bodies still Makefile → 11.3.1 |
| `compiler-all` / Makefile `all` | CI host-cc path (R5) |
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
- [ ] Remaining R1 host-cc leaves (misc pure basename, …)
- [ ] Physical delete of Makefile (11.3.1 endgame)

---

## References

- `analysis/C迁移追踪.md` §11.1.1–4 · §11.3 · §11.3.1  
- `compiler/docs/LEAF_PATTERN_RESIDUAL.md`  

- `analysis/Makefile迁移表.md` §5b cold whitelist  
- `build.x` strategy map (11.1.5)  
- `compiler/docs/PLATFORM_LINKER.md` (11.1.3/4 · wave745)  
- `compiler/scripts/driver_seed_obj_catalog.sh` (lists)  
- `compiler/scripts/driver_seed_ensure_prereqs.sh` (edges · wave744)  
- `compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh` (R4 mode · wave747)  
- `compiler/scripts/ensure_host_cc_seed_o.sh` (R1 families wave748–753)  
- `compiler/scripts/host_platform_linker.sh` (platform + linker · wave745)
