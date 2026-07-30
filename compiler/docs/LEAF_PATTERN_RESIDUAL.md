# Leaf pattern residual (11.3.1 path · wave746 inventory · wave747 R4 mode · wave748–755 R1 families · wave756 R4 pure-R1 · wave757 R3 cold-else · wave758 thin_glue seed-map · wave759 glue-standalone seed-map · wave760 R2 panic cold try-r2 · wave761 gen try-gen-x · wave762 R2 typeck_f64/crt0 try-r2 · wave763 R3 PREFER thin try-r3-prefer · wave764 g05 R3_COLD r3-prefer-family · wave765 g05 labi try-labi-prefer · wave766 g05 rt try-rt-prefer · wave767 g05 pipeline_abi/ldpc try-*-prefer · wave768 g05 target_cpu try-target-cpu-prefer · wave769 g05 L2 asm try-l2-asm-prefer · wave770 g05 async try-async-prefer · wave771 g05 other L2 try-other-l2-prefer · wave772 11.1.4 pure-ld cold prefer · wave773 g05 pure-ld prefer · wave774 drop silent CC fallback · wave775 fmt_check_cmd.o dual · wave776 R2 panic PREFER try-r2-prefer · wave777 physical-delete prep inventory · wave778 Windows gate + dual-end verify · wave779 B1 runtime-os try-runtime-os-prefer · wave780 B2 std-core try-std-core-prefer · wave799 execute-gate · wave800 Windows proof harness · wave781 B3 lsp-sat try-lsp-sat-prefer · wave782 B4 gen-c-to-o · wave783 B5 cfg-eval-ladder · wave784 B6 R5 compiler_all_ci · wave785 B7 DAG inventory + archaeology CC thin · wave786 B7D host-cc product link g05 · wave787 B7A cold residual_make=0 + B7B list honesty · wave788 B7B shell-primary catalog · wave789 B7A heat try-heat shell dispatch · wave790 B7A heat thin-unify)

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
    → typeck/codegen .o via migrate_x_objs.sh
    → bootstrap-self lsp_* via thin leaves (ensure_gen_x_o / driver_leaf)
    → bootstrap-x-compiler typeck_x_x residual $(CC) -c kept (honesty)
  B7D host_cc_product_link_xlang (TARGET:OBJS incomplete vs g05; UNDEF residual)
  PHYS_DEL_PREP_NEXT=B7_physical_delete_makefile_after_windows_not_this_wave
  ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
```

| Swallowed this wave | Still residual |
|---------------------|----------------|
| **B7 inventory** (named B7A–B7D + dump/`--check`) | Physical delete (Windows gate) |
| **B7c partial** (archaeology dual `-c` → migrate / thin leaves) | B7c `bootstrap-x-compiler` typeck_x_x · B7A edges · B7B lists · ~~**B7D host-cc xlang link**~~ (wave786) |

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
  dual-end L2: (tip after commit)
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
