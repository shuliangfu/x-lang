# Host platform + linker policy (11.1.3 · 11.1.4 · wave745 · wave772 cold pure-ld · wave773 g05 pure-ld)

> **Authority (G.7):** this document is the **human map** for Track MG platform
> selection and linker policy. Machine check:
> `compiler/scripts/host_platform_linker.sh --check` ·
> `./xbuild host-platform --check` / `./xbuild linker-policy --check`.  
> **Status map:** `analysis/C迁移追踪.md` §11.1.3–4 (status only).  
> **Wave rows:** `analysis/自举进度.md` only.  
> **PLATFORM: SHARED** — host detection and policy tags are portable; ABI details
> stay inside leaf scripts, seed pins, and product `xlang_asm_invoke_ld_*`.

## Non-negotiables (G.7 + G.8)

| Rule | Meaning |
|------|---------|
| **Single host-facts shell** | Shell scripts that need OS/arch **must** use `host_platform_linker.sh` (dump/export), not invent a second uname matrix. |
| **Lists stay mk** | Object lists / Darwin filtered `.o` / crt0 selection remain `compiler/mk/*.mk` + Makefile expansions until 11.3.1. **Do not** re-list `.o` here. |
| **Seed pin is product pin** | Product seeds `*.linux.x86_64.c` are **host-portable generated C** (not machine code). Darwin/Windows cold start still pin the same files when local `-E` fails. |
| **No default `$(CC) -o` as linker** | Endgame forbids treating the C compiler as the product linker. Residual `CC -o` sites are **named** below; product user `-o` already goes through `xlang_asm_invoke_ld_platform` / host-ld helpers. |
| **G.8 tags** | Every platform branch in new code uses `PLATFORM: LINUX\|MACOS\|WINDOWS\|POSIX\|SHARED`. |

## 11.1.3 Platform handling

### Host tags (shell authority)

| Env / key | Values | Role |
|-----------|--------|------|
| `XLANG_HOST_OS` | `linux` · `darwin` · `windows` · `unknown` | Normalized OS family |
| `XLANG_HOST_ARCH` | `x86_64` · `arm64` · `aarch64` · … | Normalized arch |
| `XLANG_HOST_UNAME_S` | raw `uname -s` | Debug / stamp paths |
| `XLANG_HOST_UNAME_M` | raw `uname -m` | Debug / stamp paths |
| `XLANG_HOST_IS_LINUX` / `DARWIN` / `WINDOWS` | `0`/`1` | Branch gates |
| `XLANG_HOST_ALPINE` | `0`/`1` | Alpine musl host (`/etc/alpine-release`) |
| `XLANG_SEED_PIN_LINUX_X86_64_OK` | `0`/`1` | Product pin file present under `compiler/seeds/` |
| `XLANG_PLATFORM_TAG` | `LINUX` · `MACOS` · `WINDOWS` · `UNKNOWN` | G.8-style tag for logs |

**CLI:**

```text
./xbuild host-platform              # dump KEY=value
./xbuild host-platform --export     # shell-sourceable exports
./xbuild host-platform --check
bash compiler/scripts/host_platform_linker.sh platform
```

### What remains Makefile residual (not dual authority)

| Residual | Owner today | Why not swallowed this wave |
|----------|-------------|-----------------------------|
| `UNAME_S` / `UNAME_M` in `compiler/Makefile` | Make graph for leaf pattern rules | Leaf `.o` recipes still make until 11.3.1 |
| Darwin filtered USER_ASM / pipeline `.o` | `compiler/mk/user_asm_seed_objs.mk` | List authority is mk (G.7) |
| crt0 / panic stamp / typeck_f64_bits arch pick | Makefile | Host-cc residual pattern rules |
| Alpine flags if any | Makefile / scripts | Documented; shell key only |

**Shell may print suggested `LD_RELFLAGS` / filter export style for diagnostics.**  
**Makefile expansions remain authoritative for actual cold link flags** until leaf rules move fully to shell.

### Product pin (SHARED)

```text
seeds/parser_gen.linux.x86_64.c
seeds/codegen_gen.linux.x86_64.c
… (other *.linux.x86_64.c product pins)
```

- **Gold acceptance host:** Ubuntu x86_64.  
- **Dev hosts (macOS / Windows):** same pin when regenerating product front-ends fails; **do not** create host-local pin forks.

## 11.1.4 Linker invocation

### Policy

| Preference | Tool | When |
|------------|------|------|
| **1. Product user `-o`** | Product path: `xlang_asm_invoke_ld_platform` / `xlang_invoke_ld_*` (already not raw Makefile `$(CC) -o` for user programs) | Daily product |
| **2. Direct host `ld` / `lld` / `link.exe`** | Partial link (`ld -r`), filter export, pure-asm objects; **cold phase1/final pure-ld** (wave772); **g05 product pure-ld** (wave773) | Preferred for shell orchestration |
| **3. Named residual host `$(CC) -o`** | Cold / g05 **only** when pure-ld ineligible or `FORCE_CC=1` | Named residual (wave772/773; **wave774** no silent after pure fail) |
| **Forbidden** | Silent CC after pure-ld fail; default “always `cc -o` because Makefile did” without inventory | Stage 11.1.4 endgame / stage 12 |

### Cold phase1 / final (wave772 pure-ld)

| Key (Makefile export) | Role |
|----------------------|------|
| `SEED_LINK_OBJS` | Single `.o` list authority (mk expansions only) |
| `SEED_LINK_LD` / `SEED_LINK_MULTIDEF` / `SEED_LINK_ENTRY` / `SEED_LINK_LD_TAIL` | Pure-ld argv pieces |
| `SEED_LINK_PURE_OK` | `1` when freestanding crt0 entry (Linux x86_64 / Darwin); else `0` |
| `SEED_LINK_CC` / `SEED_LINK_CFLAGS` | Residual CC driver path |

**Body:** `scripts/bootstrap_driver_seed_link.sh` **requires** pure-ld when `PURE_OK=1` (wave774 hard fail on pure miss).  
**G.7 platform helpers:** `scripts/pure_ld_shared.sh` (syslibroot/arch on Darwin; freestanding eligibility; `pure_ld_try_link`). Smoke: `./scripts/bootstrap_driver_seed_link.sh --self-test`.

### g05 product relink (wave773 pure-ld · wave774 no silent fallback)

| Authority | Role |
|-----------|------|
| `g05_relink_env.sh` | Single `G05_OBJS` / `G05_CFLAGS` list (shell mirror; not a second pure-ld argv table) |
| `pure_ld_shared.sh` | Same pure-ld platform prefix / freestanding facts as cold |
| `g05_relink_xlang.sh` | **Require** pure-ld when freestanding-eligible; Linux nostdlib → `-static --gc-sections` (no `-lc`); else `-lSystem`/`-lc`; hard fail on pure miss (wave774) |

Force residual: `XLANG_G05_FORCE_CC=1` or `XLANG_SEED_LINK_FORCE_CC=1`.

### Named residual `CC -o` sites (inventory · not dual implement)

| Site | Path | Notes |
|------|------|-------|
| Cold phase1 / final **named residual** | `scripts/bootstrap_driver_seed_link.sh` | Only `FORCE_CC=1` or `PURE_OK=0`; **not** after pure-ld fail (wave774) |
| g05 product relink **named residual** | `g05_relink_xlang.sh` | Only `FORCE_CC=1` or ineligible host; **not** after pure-ld fail (wave774) |
| CI `compiler-all` | Makefile `all` / host-cc seed path | Not product `./xbuild all` |
| Leaf host-cc `.o` | Makefile pattern rules | Compile, not link of product binaries |

### Preferred direct-ld sites (already exist · do not reimplement)

| Site | Role |
|------|------|
| `filter_bootstrap_seed_pipeline_o.sh` / class-G filter | `ld -r` + export list / version-script |
| Product runtime link ABI | `xlang_asm_invoke_ld_platform` · platform tail libs |
| Cold seed phase1/final | `bootstrap_driver_seed_link.sh` pure-ld prefer (wave772) via `pure_ld_shared` |
| g05 product relink of `xlang` | `g05_relink_xlang.sh` pure-ld prefer (wave773) via `pure_ld_shared` |

### CLI

```text
./xbuild linker-policy              # dump residual + preferred inventory
./xbuild linker-policy --check
bash compiler/scripts/host_platform_linker.sh linker
bash compiler/scripts/host_platform_linker.sh --check
```

### Endgame (remaining after wave775)

1. ~~Export pure link argv from Makefile without requiring `CC` as the primary driver~~ (**wave772**).  
2. ~~Invoke `ld` via shell for freestanding cold phase1/final~~ (**wave772** + self-test).  
3. ~~g05 product relink pure-ld~~ (**wave773** via `pure_ld_shared`).  
4. ~~Drop silent CC residual fallback after pure-ld fail~~ (**wave774**; FORCE_CC / ineligible kept).  
5. ~~`fmt_check_cmd.o` Makefile dual~~ (**wave775** → try-other-l2-prefer `fmt_core`).  
6. Physical delete Makefile residual leaves (11.3.1).  
7. Later: pure-ld from `build.x` / xbuild without make export leaf; Windows PE pure-ld.

## Acceptance (wave745 + wave772 + wave773 + wave774 + wave775)

- [x] `compiler/docs/PLATFORM_LINKER.md` present (this file)
- [x] `host_platform_linker.sh` dump/platform/linker/check
- [x] `./xbuild host-platform` / `linker-policy` first-class
- [x] `build.x` §F documents 11.1.3–4
- [x] `BUILD_DAG.md` references platform/linker policy
- [x] 0-make gate hard-checks doc + script + xbuild + live `--check`
- [x] **wave772:** cold phase1/final pure-ld + `SEED_LINK_*` pure export + `--self-test`
- [x] **wave773:** `pure_ld_shared.sh` + g05 pure-ld
- [x] **wave774:** drop silent CC fallback (cold+g05); FORCE_CC / ineligible named residual only
- [x] **wave775:** `fmt_check_cmd.o` dual → ensure try-other-l2-prefer (`fmt_core`)
- [ ] Full leaf rules free of Makefile `UNAME` (11.3.1)
- [ ] Physical delete Makefile (11.3.1 full endgame)

**wave746 path note:** leaf pattern residual classes (including UNAME leaf **R2**) are
named in `LEAF_PATTERN_RESIDUAL.md` / `./xbuild leaf-patterns` — inventory only;
swallowing still 11.3.1 endgame.

## References

- `analysis/C迁移追踪.md` §11.1.3 · §11.1.4 · §11.3.1  
- `compiler/docs/BUILD_DAG.md`  
- `compiler/docs/LEAF_PATTERN_RESIDUAL.md` (wave746 · leaf pattern path)  
- skill G.8 platform boundaries  
- `tests/HOST_CC_POLICY.md` (host-cc for tests/ only; orthogonal to product linker)
