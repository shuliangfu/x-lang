# Product + cold-start build DAG (11.1.1 · wave742 · 11.1.2 schedule wave743)

> **Authority (G.7):** this document is the **orchestration dependency map** for Track MG.  
> Object-list *definitions* stay in `compiler/mk/*.mk` (export via `driver_seed_obj_catalog.sh`).  
> **Do not** duplicate `.o` inventories here.  
> Machine-check: `compiler/scripts/product_build_dag.sh --check` · `./xbuild product-dag --check`.  
> Schedule execute (11.1.2): `./xbuild product-dag --dry-run` / `--run product`.

**PLATFORM: SHARED** — same node names on macOS / Ubuntu / Windows host shells; platform ABI lives inside leaf scripts and seed pins.

---

## 0. Scope (what this DAG is / is not)

| In scope | Out of scope (later) |
|----------|----------------------|
| Product daily path nodes + owners (11.1.1) | Full import-scan of user `.x` projects |
| Cold-start orchestration step order (11.1.1) | Parallel scheduler / ninja emit |
| Named schedules + dry-run / run (11.1.2) | 11.1.4 direct `ld` without host-cc |
| Residual make *graph* nodes named | Physical delete of Makefile (11.3) |
| Single authority pointer per node | C `build_runtime` step table replace (11.1.5 endgame) |

**Not yet:** replacing C `build_runtime` step table (ABI still `build_get_step_*` · 11.1.5).  
**Not yet:** physical delete of Makefile (11.3).  
**Not yet:** 11.1.3 platform selector nodes / 11.1.4 linker without `$(CC) -o`.

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

Dry-run prints inventory order (see §3). Live `--run cold` invokes **outer**  
`./xbuild bootstrap-driver-seed` once (Makefile `DRIVER_SEED_PREREQS` residual → **11.3**).  
Does **not** re-walk each cold leaf body (orchestrator already does).

### 2.4 CLI

```text
./xbuild product-dag --dry-run product   # or refresh | cold
./xbuild product-dag --run product
./xbuild dag-dry-run cold
./xbuild dag-run refresh
bash compiler/scripts/product_build_dag.sh dry-run product
```

---

## 3. Cold-start path (`bootstrap-driver-seed`)

Two layers until 11.3:

1. **Make prereq graph** — `DRIVER_SEED_PREREQS` + thin export leaves (lists in `compiler/mk/*.mk` only).  
2. **Shell orchestration** — `scripts/bootstrap_driver_seed.sh` (ordered steps below).

```text
Makefile: $(DRIVER_SEED_PREREQS) + pipeline_glue_strict_minimal.o
        │
        ▼
bootstrap_driver_seed.sh (ordered):
  1  check_pipeline_gen_expr_i64_abi.sh          (§5b #1 pure shell)
  2  bootstrap-driver-seed-pipeline-x            (export + rebuild_leaves)
  3  bootstrap-driver-seed-sat-rebuild
  4  bootstrap-driver-seed-lsp-x-objs
  5  bootstrap-driver-seed-bridge
  6  bootstrap-driver-seed-user-asm-seed-objs
  7  bootstrap-driver-seed-asm-glue-standalone
  8  bootstrap-driver-seed-asm-host              → build_seed_asm_host.sh
  9  bootstrap-driver-seed-host-stubs            → host_stubs.sh
 10  bootstrap-driver-seed-filtered-objs         (Darwin class-G; empty Linux)
 11a bootstrap-driver-seed-phase1-link           → link.sh phase1
 11b bootstrap-driver-seed-final-link            → link.sh final
 12  bootstrap-driver-seed-panic
 13  smoke + product binary aliases
```

| Layer | Authority | Status |
|-------|-----------|--------|
| `.o` / composite lists | `compiler/mk/*.mk` + `export-obj-catalog` | ✅ single (G.7) |
| Step **sequence** | `bootstrap_driver_seed.sh` | ✅ shell (wave717+) |
| Leaf **bodies** | `*_rebuild_leaves` / `*_link` / `*_host_stubs` / … | ✅ shell (§5b) |
| Prereq **edges** (what must exist before seed) | Makefile `DRIVER_SEED_PREREQS` | 🟡 residual → 11.3 |
| Outer entry | `./xbuild bootstrap-driver-seed` | ✅ (hub still make for graph) |
| Schedule dry-run / outer run | `product_build_dag.sh` 11.1.2 | ✅ wave743 |

**Obj catalog (read-only, no second list):**

```text
./xbuild compiler-make bootstrap-driver-seed-export-obj-catalog
# or: (cd compiler && bash scripts/driver_seed_obj_catalog.sh --check)
```

---

## 4. Strategy facade vs execution DAG

| Layer | File / tool | Role |
|-------|-------------|------|
| Policy map | root `build.x` | Human strategy + pin-stable `build_get_step_*` ABI |
| Orchestration DAG | **this doc** + `product_build_dag.sh` | 11.1.1 inventory + 11.1.2 schedules |
| Product entry | `./xbuild` → `xlang-build.sh` | First-class targets |
| Cold graph residual | `compiler/Makefile` | Until 11.3 |
| Step table (legacy) | C `build_runtime` + `build_get_step_at` | Domain B bootstrap; not user API |

---

## 5. Residual make graph (named only · 11.3 swallow)

Do **not** grow new free-form recipes. Known residual classes:

| Residual | Notes |
|----------|--------|
| `DRIVER_SEED_PREREQS` edge set | Cold start; lists in mk |
| Leaf `.o` pattern rules | host-cc residual C (stages 8.3/9) |
| `compiler-all` / Makefile `all` | CI host-cc path |
| FULL=1 bstrict make entry | Non-daily |
| Missing `xlang-c` for force -E | ensure_* gen scripts |

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
- [x] cold live run = outer `bootstrap-driver-seed` (prereq residual documented)
- [x] `--check` exercises dry-run all profiles
- [ ] Full .x import-scan incremental graph (later 11.1.2 endgame)
- [ ] 11.1.3/4 platform + linker nodes fully non-cc (future)
- [ ] 11.3 delete Makefile prereq graph (future)

---

## References

- `analysis/C迁移追踪.md` §11.1.1–4 · §11.3  
- `analysis/Makefile迁移表.md` §5b cold whitelist  
- `build.x` strategy map (11.1.5)  
- `compiler/scripts/driver_seed_obj_catalog.sh` (lists, not edges)
