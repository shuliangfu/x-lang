# Leaf pattern residual (11.3.1 path · wave746 inventory · wave747 R4 mode · wave748–755 R1 families · wave756 R4 pure-R1 · wave757 R3 cold-else · wave758 thin_glue seed-map · wave759 glue-standalone seed-map · wave760 R2 panic cold try-r2 · wave761 gen try-gen-x · wave762 R2 typeck_f64/crt0 try-r2 · wave763 R3 PREFER thin try-r3-prefer · wave764 g05 R3_COLD r3-prefer-family · wave765 g05 labi try-labi-prefer · wave766 g05 rt try-rt-prefer)

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
| Phase1/final **link driver** | `bootstrap_driver_seed_link.sh` | residual is `SEED_LINK_CC -o` (11.1.4 · wave745) |
| g05 ensure / prepare / relink | `g05_*.sh` | **wave764** R3_COLD · **wave765** labi · **wave766** rt via ensure; residual pipeline_abi · ldpc · other L2 |
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
| **R2** | Platform stamp / UNAME leaf | `runtime_panic.$(UNAME_S).$(UNAME_M).stamp` · `typeck_f64_bits` arch `.s` pick · crt0 | shell + host_platform_linker facts; lists stay mk | **panic cold ✅ wave760** · **typeck_f64/crt0 ✅ wave762** (try-r2); PREFER panic thin residual |
| **R3** | Thin+rest / PREFER_X_O host-cc rest | thin `.o` + `FROM_X=1` rest `cc -c` + `ld -r` | cold-else shell ensure; PREFER thin product path | **cold-else ✅ wave757** · **Makefile PREFER ✅ wave763** · **g05 R3_COLD ✅ wave764** · **labi multi-slice ✅ wave765** · **rt multi-slice ✅ wave766**; residual pipeline_abi · ldpc · target_cpu |
| **R4** | Cold rebuild **pattern bodies** | sat/lsp/bridge/panic/user-asm/glue/pipeline-x | rebuild without make pattern graph | **mode+list shell wave747** · **pure-R1 wave756** · **R3 cold wave757** · **thin_glue seed-map wave758** · **glue standalone seed-map wave759** · **panic cold try-r2 wave760** · **gen try-gen-x wave761** · **typeck_f64/crt0 try-r2 wave762**; residual PREFER thin / sat non-R1 if any |
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
| g05 rt multi-slice hybrid (product daily path) | pipeline_abi · ldpc · target_cpu · pure-ld · physical delete |
| Second prefer body for runtime_driver_no_c.o | panic PREFER (if any) · R5 CI · other L2 hybrid leaves |

**Forbidden:** re-open g05 inline rt multi-slice hybrid; second multi-slice body under a second name; merge RT_SEED_SLICE permanent .o into no_c.

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
- [x] leaf map x/rest-defs/nm (not .o inventory); unified PREFER=1 gate
- [x] Makefile nine thin-call try-r3-prefer (no inline ld -r thin+rest)
- [x] LEAF dump `SWALLOWED_R3_PREFER_THIN=1` · `R3_PREFER_THIN_SWALLOWED=1`

- [ ] g05 other PREFER hybrid · panic PREFER (if any) · pure-ld · physical delete
- [ ] Physical delete of Makefile / all leaf pattern rules (11.3.1 endgame)
- [ ] Leaf `.o` without host-cc residual (stages 8–9 / 12)
- [ ] Cold phase1/final pure-ld without `SEED_LINK_CC -o` (11.1.4 · separate)

## References

- `analysis/C迁移追踪.md` §11.3 · §11.3.1  
- `compiler/docs/BUILD_DAG.md` §5 residual make graph  
- `compiler/docs/PLATFORM_LINKER.md` (R6 / UNAME leaf cross-ref)  
- `compiler/scripts/driver_seed_obj_catalog.sh` (list authority)  
- `compiler/scripts/ensure_host_cc_seed_o.sh` (R1 families + try-r1 + R3 cold-else + thin_glue/glue-standalone + R2 panic/typeck_f64/crt0 try-r2)  
- skill G.7 single authority · G.8 platform tags  
