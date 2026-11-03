# P1101 PROGRESS — softcap_xuban_10_4_build_x_eat_g05

Time: 2026-11-03 ~16:55 Asia/Shanghai · Mac.lan
HOLD Soft Cap **09fe181dbd0e**／nail ecdb／tiphead Prefer-M2 **9ecd26ea44ab**／Cap tip Prefer-M2b **10470224**／code tip Prefer-M2 SoftCap **13fec616d**
Never self-CLOSE. Day3 usage cap 60%. gate≠CLOSE.

## First grain — locate `build.x` vs g05 role

### Current roles (honest)
| Layer | Path | Role today |
|---|---|---|
| Policy facade | root `build.x` (238 lines) | Comments map xbuild→g05; **executable** surface＝only 3 ABI fns (`build_use_asm_only`／`build_get_step_count`／`build_get_step_at`) for C `build_runtime` step table |
| Product orchestration entry | `./xbuild` → `xlang-build.sh` | Dispatches ensure／link-env／link-product／product-dag to shell |
| Dep graph + schedule inventory | `compiler/scripts/product_build_dag.sh` | Owns `PRODUCT_NODES`／`PRODUCT_SCHEDULE`／`REFRESH_SCHEDULE`／`COLD_*` bash arrays; `--check`／`--dry-run`／`--run` |
| Platform + linker policy | `compiler/scripts/host_platform_linker.sh` + `PLATFORM_LINKER.md` | Host OS/arch facts + linker residual inventory |
| Product link／ensure bodies | `compiler/scripts/g05_*.sh` (~20k LOC; ensure≈5.4k／relink_env≈7.6k／relink_xlang≈1.5k／prepare≈0.2k) | **Real** dependency satisfaction／relink／platform ABI／linking |

### Gap for §6 10.4
`build.x` does **not** yet own dep graph／schedule／platform／link as data or executor. It documents them. Execution + node lists live in g05 shell + `product_build_dag.sh`. Full DAG-as-data after "g05 swallow" is still the stated endgame (`build.x` header F／`BUILD_DAG.md` "Not yet" rows).

### Fake-green banned
- Comment-only edits claiming "ate g05"
- SoftCap dig／tiphead DIG07／Cap tip poison／host-swap theater as this knife's primary
- Dual `.o`／dual schedule lists mid-flight (G.7)

## Propose smallest honest next plant (not done this grain)
**Plant candidate:** encode `PRODUCT_SCHEDULE` ordered node ids as `build.x` export ABI (count + `get_at` string／id table parallel to step table); extend `product_build_dag.sh --check` to **cross-check** bash `PRODUCT_SCHEDULE` against build.x exports and FAIL on mismatch.
- Does **not** rewrite g05 bodies into `.x` this knife
- Does **not** demote bash array yet in the same breath without a proven reader (avoid G.7 dual-authority theater)
- Next knife after green cross-check: demote bash schedule source → generated-from／read-from build.x (single authority)

If cross-check plant cannot land without inventing a second schedule authority or touching Soft Cap／nail／tiphead／Cap tip／code tip → HARD-STOP with that exact gap; ask parent CLOSE ruling. Do not invent fake green.

## Plant grain — PRODUCT_SCHEDULE export ABI + --check (2026-11-03 ~17:00 Asia/Shanghai)

### Landed
- `build.x`: `build_product_schedule_count(): i32` → 5; `build_product_schedule_id_at(i): *u8` ordered ids
  (`ensure_migrate_gen` → `ensure_driver_gen` → `ensure_lsp_pipeline_gen` → `migrate_x_objs` → `g05_prepare_and_relink`)
- `compiler/scripts/product_build_dag.sh --check`: source-parse ABI vs bash `PRODUCT_SCHEDULE`; FAIL on count/order/id mismatch
- Evidence: note `build.x PRODUCT_SCHEDULE ABI matches bash (5 nodes · 10.4/11.01)`
- Mismatch probe: bogus id → `FAIL: PRODUCT_SCHEDULE[0] mismatch: build.x=ENSURE_MIGRATE_GEN_BOGUS bash=ensure_migrate_gen` (restored)

### Not this grain
- No g05 body rewrite; bash `PRODUCT_SCHEDULE` still live runner authority (demote next)
- No Soft Cap／nail／tiphead／Cap tip／code tip raise
- Never self-CLOSE

### Residual gap (honest — blocks full CHECK OK)
`product_build_dag.sh --check` still **EXIT 1** on pre-existing `leaf_pattern_residual.sh --check` wave899:
`expected 4 R1_CORE_SEED_OBJS members, got 4` while gate is `-ne 5` (message／count disagree).
Not introduced by this plant. ABI cross-check itself greens. Full `CHECK OK` needs separate leaf residual knife or parent ruling — do not fake-green／weaken leaf gate here.

## Status
Plant grain＝**ABI + cross-check LANDED** (ACCEPT-path progress; gate≠CLOSE). OPEN stays open.
HOLD Soft Cap／nail／tiphead／Cap tip／code tip.
