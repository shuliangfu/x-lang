# Leaf pattern residual (11.3.1 path · wave746 inventory · wave747 R4 mode)

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
| **Lists stay mk** | Object lists / Darwin filtered `.o` / composite sets remain `compiler/mk/*.mk` + catalog. **Do not** re-list `.o` in this doc or in `leaf_pattern_residual.sh`. |
| **Orchestration already shell** | Cold step *sequence* and *export→rebuild* leaves are shell (waves 717–744). Residual here is **how individual `.o` files are still produced** (pattern / recipe in Makefile). |
| **No dual compile path** | Inventory **names** residual classes and existing shell owners. Do not open a second `cc -c` driver that copies Makefile recipes. |
| **Physical delete later** | 11.3.1 endgame deletes Makefile only after BC residual classes are 0 or owned by shell without make graph. This wave is inventory + path only. |
| **G.8 tags** | Platform branches in leaf recipes keep `PLATFORM: LINUX\|MACOS\|WINDOWS\|POSIX\|SHARED`. |

## What is already shell (not residual)

| Class | Owner shell | Notes |
|-------|-------------|-------|
| Cold step sequence | `bootstrap_driver_seed.sh` | Ordered §5b |
| Prereq **edges** | `driver_seed_ensure_prereqs.sh` | wave744; list = catalog |
| Rebuild leaf **orchestration + mode policy** | `bootstrap_driver_seed_rebuild_leaves.sh` | **wave747**: mode table + catalog KEY in shell; pattern bodies still `make` |
| Phase1/final **link driver** | `bootstrap_driver_seed_link.sh` | residual is `SEED_LINK_CC -o` (11.1.4 · wave745) |
| g05 ensure / prepare / relink | `g05_*.sh` | product daily path |
| migrate / `*_gen` ensure | `migrate_x_objs.sh` · `ensure_*_gen.sh` | wave735–740 |
| Host facts / linker policy map | `host_platform_linker.sh` | wave745 |

## Named residual classes (Makefile still owns body)

| ID | Residual class | Typical Makefile surface | Endgame owner | Status |
|----|----------------|--------------------------|---------------|--------|
| **R1** | Host-cc seed/from_x → `.o` | `$(CC) … -c seeds/*.from_x.c -o …` recipes | shell ensure or product `-E`+cc body (stages 8–9); **one** body per leaf family | residual |
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

## CLI

```text
./xbuild leaf-patterns                 # dump residual class inventory KEY=value
./xbuild leaf-patterns --check
./xbuild leaf-residual                 # alias
bash compiler/scripts/leaf_pattern_residual.sh
bash compiler/scripts/leaf_pattern_residual.sh --check
bash compiler/scripts/leaf_pattern_residual.sh classes
# R4 live body (compiler/):
bash compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh bridge
```

## Migration path (11.3.1 · not closed)

```text
1. Keep lists in mk/catalog (G.7)
2. For each residual class R1–R5:
     name single shell body → Makefile thin phony only
3. wave747: R4 mode policy + catalog list path ✅
4. When no recipe needs make pattern graph:
     delete compiler/Makefile (11.3.1) + root Makefile (11.3.2)
5. Zero host-cc product path → stage 12 (Docker unload gcc/make)
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
- [ ] Physical delete of Makefile / all leaf pattern rules (11.3.1 endgame)
- [ ] Leaf `.o` without host-cc residual (stages 8–9 / 12)
- [ ] Cold phase1/final pure-ld without `SEED_LINK_CC -o` (11.1.4 · separate)

## References

- `analysis/C迁移追踪.md` §11.3 · §11.3.1  
- `compiler/docs/BUILD_DAG.md` §5 residual make graph  
- `compiler/docs/PLATFORM_LINKER.md` (R6 / UNAME leaf cross-ref)  
- `compiler/scripts/driver_seed_obj_catalog.sh` (list authority)  
- skill G.7 single authority · G.8 platform tags  
