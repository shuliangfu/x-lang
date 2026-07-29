# Leaf pattern residual (11.3.1 path · wave746 inventory · wave747 R4 mode · wave748–753 R1 families)

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
| Rebuild leaf **orchestration + mode policy** | `bootstrap_driver_seed_rebuild_leaves.sh` | **wave747**: mode table + catalog KEY in shell; pattern bodies still `make` |
| Phase1/final **link driver** | `bootstrap_driver_seed_link.sh` | residual is `SEED_LINK_CC -o` (11.1.4 · wave745) |
| g05 ensure / prepare / relink | `g05_*.sh` | product daily path (R3 thin+rest still inside) |
| migrate / `*_gen` ensure | `migrate_x_objs.sh` · `ensure_*_gen.sh` | wave735–740 |
| Host facts / linker policy map | `host_platform_linker.sh` | wave745 |
| **R1 pure host-cc body · RT_SEED_SLICE + CORE_SEED + FRONTEND_GLUE + MAIN_RUNTIME + ALIAS_STUBS + EXTRA_CFLAGS** | `ensure_host_cc_seed_o.sh` | **wave748** rt-slice · **wave749** core-seed · **wave750** frontend-glue · **wave751** main-runtime · **wave752** alias-stubs · **wave753** extra-cflags; other R1 residual |

## Named residual classes (Makefile still owns body)

| ID | Residual class | Typical Makefile surface | Endgame owner | Status |
|----|----------------|--------------------------|---------------|--------|
| **R1** | Host-cc seed/from_x → `.o` | `$(CC) … -c seeds/*.from_x.c -o …` recipes | shell ensure or product `-E`+cc body (stages 8–9); **one** body, multi family lists | **rt-slice ✅ wave748** · **core-seed ✅ wave749** · **frontend-glue ✅ wave750** · **main-runtime ✅ wave751** · **alias-stubs ✅ wave752** · **extra-cflags ✅ wave753**; other leaves residual |
| **R2** | Platform stamp / UNAME leaf | `runtime_panic.$(UNAME_S).$(UNAME_M).stamp` · `typeck_f64_bits` arch `.s` pick · crt0 | shell + host_platform_linker facts; lists stay mk | residual |
| **R3** | Thin+rest / PREFER_X_O host-cc rest | thin `.o` + `FROM_X=1` rest `cc -c` + `ld -r` | g05_ensure / product path (already partial shell) | residual |
| **R4** | Cold rebuild **pattern bodies** | sat/lsp/bridge/panic/user-asm/glue/pipeline-x still invoke make for `.o` recipes | rebuild without make pattern graph | **mode+list shell wave747**; body residual |
| **R5** | CI / `compiler-all` host-cc graph | Makefile `all` · OPT seed path | CI entry stays `./xbuild compiler-all` until stage 12 | residual |
| **R6** | Residual cold **link** via CC | `SEED_LINK_CC -o` phase1/final | 11.1.4 pure-ld endgame (orthogonal inventory: PLATFORM_LINKER) | residual |

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
| Dual path of 7 export leaves vs catalog for the same lists | Host-cc / UNAME / thin-rest **pattern recipes** |
| Mode policy (which KEY, `-B`, `PIPELINE_X_FORCE_COMPILE=1`, …) | Actual `$(CC) -c` / stamp bodies in Makefile |

Makefile `bootstrap-driver-seed-export-*` rebuild targets remain as **inventory mirrors** (optional); cold rebuild default no longer depends on them.

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

## CLI

```text
./xbuild leaf-patterns                 # dump residual class inventory KEY=value
./xbuild leaf-patterns --check
./xbuild leaf-residual                 # alias
./xbuild host-cc-seed                  # all swallowed R1 families (wave753)
./xbuild rt-seed-slice | core-seed | frontend-glue | main-runtime | alias-stubs | extra-cflags
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
10. Next: more R1 (misc pure basename) / R4 pattern bodies off make / 11.1.4 pure-ld
11. When no recipe needs make pattern graph:
     delete compiler/Makefile (11.3.1) + root Makefile (11.3.2)
12. Zero host-cc product path → stage 12 (Docker unload gcc/make)
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
- [ ] All R1 families swallowed (misc pure basename host-cc, …)
- [ ] Physical delete of Makefile / all leaf pattern rules (11.3.1 endgame)
- [ ] Leaf `.o` without host-cc residual (stages 8–9 / 12)
- [ ] Cold phase1/final pure-ld without `SEED_LINK_CC -o` (11.1.4 · separate)

## References

- `analysis/C迁移追踪.md` §11.3 · §11.3.1  
- `compiler/docs/BUILD_DAG.md` §5 residual make graph  
- `compiler/docs/PLATFORM_LINKER.md` (R6 / UNAME leaf cross-ref)  
- `compiler/scripts/driver_seed_obj_catalog.sh` (list authority)  
- `compiler/scripts/ensure_host_cc_seed_o.sh` (R1 families wave748–753)  
- skill G.7 single authority · G.8 platform tags  
