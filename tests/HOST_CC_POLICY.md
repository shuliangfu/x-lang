# tests/ host-cc policy (C迁移 11.5 · wave741)

> **Authority** for classifying `tests/**/*.c` under the zero host-cc endgame map.  
> **Status map**: `analysis/C迁移追踪.md` §11.5 (status only).  
> **Wave rows**: `analysis/自举进度.md` only.  
> **PLATFORM: SHARED** — policy is host-portable; sanitizer probes are Linux-primary in practice.

## Non-negotiables (G.7)

| Rule | Meaning |
|------|---------|
| **Not product** | These `.c` files are **never** inputs to g05, `./xbuild all`, product link of `xlang` / `xlang_asm` / `xlang-c`, or `compiler/Makefile` product OBJ lists. |
| **Not dual authority for std** | Product std is `std/**/*.x` (+ seed pin when required). C smokes only **drive** host-linked smoke of already-built `.o`. |
| **Explicit cc only** | Host `cc`/`gcc` may appear only inside `tests/lib/**`, `tests/bench/**`, or named probe scripts — never as a silent product step. |
| **Stage 12 re-review** | Permanent whitelist ≠ forever. Stage 12 (zero-cc cold start) may rewrite smokes to `.x` or drop host-cc; until then whitelist holds. |

## 11.5.1 `tests/bench/**/*.c` — permanent host-cc whitelist (diff baseline)

- **Ruling (wave734)**: permanent host-cc whitelist for **differential / throughput baselines only**.
- **Count (workspace, 2026-07-29)**: ~50–60 `.c` under `tests/bench/` (many untracked local); git-tracked subset is smaller.
- **Consumers**: bench scripts only; never g05 / product `all`.
- **Prefer**: when a `.x` twin exists, product side compiles `.x`; bare `.c` stays host-cc baseline.

## 11.5.2 `tests/std-*/*.c` — permanent host-cc whitelist (C smoke harness)

- **Ruling (wave741)**: permanent host-cc whitelist for **module smoke drivers** that `tests/lib/std-*.sh` links with host `cc` against product-built `std/**/*.o`.
- **Count (workspace, 2026-07-29)**: **50** tracked files under `tests/std-*/*.c`.
- **Why not rewrite this wave**: MG Track focus is Makefile/xbuild de-make; rewriting ~50 C harnesses is a separate std-test migration and does not unblock 11.3.
- **Product acceptance**: bstrict / `.x` gates where they exist remain the product green signal; C harness is **extra** std-module smoke, not a substitute for the product matrix.
- **Inventory (authoritative list for gate floor count ≥40)**:

```text
tests/std-base64/stream_smoke_ok.c
tests/std-cache/cache_smoke_ok.c
tests/std-cli/cli_smoke_ok.c
tests/std-compress/brotli_smoke_ok.c
tests/std-config/config_smoke_ok.c
tests/std-config/yaml_smoke_ok.c
tests/std-context/context_smoke_ok.c
tests/std-crypto/chacha_smoke_ok.c
tests/std-crypto/ed25519_smoke_ok.c
tests/std-datetime/datetime_smoke_ok.c
tests/std-datetime/timezone_smoke_ok.c
tests/std-elf/parse_phdr_smoke_ok.c
tests/std-elf/parse_sections_smoke_ok.c
tests/std-elf/parse_smoke_ok.c
tests/std-elf/parse_sym_rela_smoke_ok.c
tests/std-elf/write_smoke_ok.c
tests/std-ffi/cstring_lifecycle_ok.c
tests/std-ffi/struct_callback_ok.c
tests/std-hash/default_strategy_ok.c
tests/std-hash/hasher_switch_ok.c
tests/std-hash/xxhash64_smoke_ok.c
tests/std-log/multi_sink_ok.c
tests/std-log/rotate_async_smoke_ok.c
tests/std-math/fenv_capability_ok.c
tests/std-math/fenv_smoke_ok.c
tests/std-math/special_smoke_ok.c
tests/std-schema/schema_smoke_ok.c
tests/std-security/security_smoke_ok.c
tests/std-simd/autovec_strategy_ok.c
tests/std-sort/key_cmp_ok.c
tests/std-sort/stable_smoke_ok.c
tests/std-sqlite/blob_stream_roundtrip_ok.c
tests/std-sqlite/exec_roundtrip_ok.c
tests/std-sqlite/exec_tx_roundtrip_ok.c
tests/std-sqlite/next_row_roundtrip_ok.c
tests/std-sqlite/pool_roundtrip_ok.c
tests/std-sqlite/query_rows_roundtrip_ok.c
tests/std-sqlite/row_col_blob_roundtrip_ok.c
tests/std-sqlite/row_col_text_roundtrip_ok.c
tests/std-sqlite/stmt_bind_roundtrip_ok.c
tests/std-sqlite/stub_behavior_ok.c
tests/std-tar/extended_ok.c
tests/std-task/task_smoke_ok.c
tests/std-test/bench_fuzz_ok.c
tests/std-trace/hooks_smoke_ok.c
tests/std-trace/trace_smoke_ok.c
tests/std-unicode-normalization/normalization_smoke_ok.c
tests/std-url/ipv6_host_smoke_ok.c
tests/std-url/url_smoke_ok.c
tests/std-uuid/uuid_smoke_ok.c
```

## 11.5.3 `tests/abi|leak|safe|kernel/*.c` — permanent host-cc whitelist (host probes)

- **Ruling (wave741)**: permanent host-cc whitelist for **ABI / sanitizer / freestanding** probes that require host toolchain features unavailable or unsuitable on the pure product path.
- **Files**:
  - `tests/abi/layout_abi.c` — ABI layout smoke (host cc)
  - `tests/leak/leak_probe.c` — needs host ASan (`-fsanitize=address`)
  - `tests/safe/race_probe.c` — concurrency / race probe (host)
  - `tests/kernel/freestanding_stubs.c` — freestanding / kernel gate stubs (host)
- **Note**: `./xbuild` may *invoke* kernel gate **scripts** under `tests/kernel/`; that does not pull these `.c` into the product compiler link graph.

## 11.5.4 `tests/probes/**/*.c` — tool / generated artifacts (not product residual)

- **Ruling (wave741)**: **not** a host-cc product residual class. These are prove/seed/tool outputs (and a few checked-in bootstrap-parser probes).
- **Strategy**: do not expand tracked probe `.c` as product debt; as prove migrates to xbuild, generated trees shrink or stay workspace-local / gitignored.
- **Tracked examples (small)**: `tests/probes/bootstrap-parser/*_gen_probe*.c`.
- **Workspace local**: large `seed_optional/**` and `prove_x_o/**` trees may exist untracked — still **not product**.

## Gate contract (`tests/run-product-path-zero-make-gate.sh`)

Wave741 hard-checks (static):

1. This file exists and names 11.5.1–4 + permanent whitelist language.
2. Product g05 scripts do **not** reference `tests/std-*.c` / abi|leak|safe layout probes as compile inputs.
3. Floor inventory: `tests/std-*/*.c` count ≥ 40; the four 11.5.3 probe files exist.
4. `build.x` strategy map mentions tests host-cc policy (section E).

## Out of scope (follow-ups)

| Item | Track |
|------|--------|
| Rewrite std C harness → `.x` | post-11.3 / stage 12 re-review |
| Drop bench host-cc entirely | stage 12 |
| 11.1.1–4 DAG-as-data | Track MG next after policy close |
| Seed prereq Makefile residual | 11.3 |
