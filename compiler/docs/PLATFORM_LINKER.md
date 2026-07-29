# Host platform + linker policy (11.1.3 · 11.1.4 · wave745)

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
| **2. Direct host `ld` / `lld` / `link.exe`** | Partial link (`ld -r`), filter export, pure-asm objects | Preferred for shell orchestration |
| **3. Residual host `$(CC) -o`** | Cold phase1/final driver link via `bootstrap_driver_seed_link.sh` reading `SEED_LINK_CC` | **Named residual** until pure-ld argv export exists |
| **Forbidden endgame** | Silent default “always `cc -o` because Makefile did” without inventory | Stage 11.1.4 endgame / stage 12 |

### Named residual `CC -o` sites (inventory · not dual implement)

| Site | Path | Notes |
|------|------|-------|
| Cold phase1 / final | `scripts/bootstrap_driver_seed_link.sh` | Evals Makefile export `SEED_LINK_CC` / `CFLAGS` / `OBJS` then `"$SEED_LINK_CC" … -o OUT` · flags still Makefile |
| CI `compiler-all` | Makefile `all` / host-cc seed path | Not product `./xbuild all` |
| Leaf host-cc `.o` | Makefile pattern rules | Compile, not link of product binaries |

### Preferred direct-ld sites (already exist · do not reimplement)

| Site | Role |
|------|------|
| `filter_bootstrap_seed_pipeline_o.sh` / class-G filter | `ld -r` + export list / version-script |
| Product runtime link ABI | `xlang_asm_invoke_ld_platform` · platform tail libs |
| g05 product relink of `xlang` | `g05_relink_xlang.sh` / prepare path (host-cc residual may still appear — track separately; do not open a second linker) |

### CLI

```text
./xbuild linker-policy              # dump residual + preferred inventory
./xbuild linker-policy --check
bash compiler/scripts/host_platform_linker.sh linker
bash compiler/scripts/host_platform_linker.sh --check
```

### Endgame (not this wave)

1. Export pure link argv from Makefile (or mk) without requiring `CC` as the driver for phase1/final.  
2. Invoke `ld` / `lld` / `link.exe` via `posix_spawn` / raw exec from shell (later: from `build.x` / xbuild).  
3. Keep **one** object-list authority; only change the **driver** of the final link line.

## Acceptance (wave745)

- [x] `compiler/docs/PLATFORM_LINKER.md` present (this file)
- [x] `host_platform_linker.sh` dump/platform/linker/check
- [x] `./xbuild host-platform` / `linker-policy` first-class
- [x] `build.x` §F documents 11.1.3–4
- [x] `BUILD_DAG.md` references platform/linker policy
- [x] 0-make gate hard-checks doc + script + xbuild + live `--check`
- [ ] Full leaf rules free of Makefile `UNAME` (11.3.1)
- [ ] Cold phase1/final without residual `CC -o` (11.1.4 endgame)

**wave746 path note:** leaf pattern residual classes (including UNAME leaf **R2**) are
named in `LEAF_PATTERN_RESIDUAL.md` / `./xbuild leaf-patterns` — inventory only;
swallowing still 11.3.1 endgame.

## References

- `analysis/C迁移追踪.md` §11.1.3 · §11.1.4 · §11.3.1  
- `compiler/docs/BUILD_DAG.md`  
- `compiler/docs/LEAF_PATTERN_RESIDUAL.md` (wave746 · leaf pattern path)  
- skill G.8 platform boundaries  
- `tests/HOST_CC_POLICY.md` (host-cc for tests/ only; orthogonal to product linker)
