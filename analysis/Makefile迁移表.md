# compiler/Makefile 迁移表（11.0.1）

> **日期**：2026-07-29 · wave714（Track MG / 阶段 11.0.1）  
> **来源**：`compiler/Makefile`（~3445 行）自动盘点 + 人工分类  
> **权威勾选**：本表「迁移状态」列；汇总摘要同步 [`C迁移追踪.md`](C迁移追踪.md) 附录 E / 阶段 11.0  
> **xbuild 目标名**：拟定 API；实现前禁止另开第三套编排（收敛 g05 / `xlang-build.sh` / `build.x`）  
> **终局**：物理删除 Makefile 前本表须 100% 有主（迁出 / 删除 / 白名单 residual 由 xbuild 编）

---

## 0. 怎么用

| 列 | 含义 |
|----|------|
| **类** | 迁移批次（A–O），与 xbuild 子系统对应 |
| **Makefile 目标** | 规则左侧名字（`.o` / phony / gen.c） |
| **行号** | `compiler/Makefile` 首次出现 |
| **今日落点** | 谁真正在干活（g05 shell / Makefile / 测试脚本） |
| **xbuild 目标** | 终局拟接管名 |
| **迁移状态** | 🟢 已 shell 权威 · 🟡 半路径 · ⬜ 仍 Makefile · 🗑 拟删除不迁 |

**迁移完成定义（单行）**：产品/冷启动/CI 不再依赖该 Makefile 规则；xbuild 或单一 shell 族可复现。

---

## 1. 类汇总（仪表盘）

| 类 | 主题 | 条数 | xbuild 拟目标 | 今日整体 | 优先波 |
|----|------|------|---------------|----------|--------|
| **A** | std / core 模块 .o | 65 | `xbuild std` | 🟡 部分 g05 ensure + xlang_compile_std_module.sh | 并行 11.0 |
| **B** | pinned *_gen.c 规则（cp/pin） | 18 | `xbuild pin-gen → 去 pin 后 frontend` | ⬜ Makefile 权威 | 阶段 7.4/8.2 |
| **C** | pipeline_glue / pipeline_x / strict_minimal | 3 | `xbuild glue` | ⬜ Makefile + g05 热路径 cc | 阶段 8.3 |
| **D** | 前端 *_x.o（parser/typeck/codegen/driver…） | 20 | `xbuild frontend` | 🟡 g05 ensure 热路径 | 阶段 7–8 |
| **E** | compiler/src 宿主 .o（runtime/driver/asm…） | 59 | `xbuild runtime-src` | 🟡 g05 ensure 热路径 | 11.0/BC |
| **F** | runtime_* residual 宿主 .o | 31 | `xbuild residual-c（白名单）` | 🟡 g05 ensure | 阶段 9 |
| **G** | build_asm/ 过滤 .o | 4 | `xbuild build-asm-filter` | 🟢 全 4 纯 shell（wave715/716） | 11.0.2/3 |
| **H** | bootstrap / 产品二进制 phony | 35 | `xbuild bootstrap / link-product` | 🟡 冷编排/链接体 shell（wave717–721）；OBJS 仍 make 导出；产品=g05 | 11.0.3 |
| **I** | g05 / relink / build-tool 入口 | 9 | `xbuild link-product` | 🟢 产品+build-tool shell（wave718） | 11.0.2/3 |
| **J** | test / check / verify / baseline | 12 | `xbuild test / cold-test / prove` | 🟡 test*/verify shell（wave720）；tests/lib 仍 make | 11.0.3/11.2.3 |
| **K** | seed 工具（asm host / regen） | 3 | `xbuild seed-tools` | ⬜ Makefile | 11.0.3 |
| **L** | std 变体（sqlite/net/compress stub） | 10 | `xbuild std-variant` | ⬜ Makefile | 并行 |
| **M** | clean / compile_commands / legacy | 6 | `xbuild util 或删除` | 🟡 clean→shell（wave718）；其余 make | 11.0.3/4 |
| **N** | link alias / 其它 .o | 11 | `xbuild stubs` | 🟡 g05 | BC |
| **O** | 未分类 / 死规则候选 | 2 | `删除或不迁` | ⬜ 人工确认 | 11.0 瘦身 |
| **Σ** | | **288** | | | |

### 1.1 依赖与并行策略（摘自 C迁移 §0.2 / 11.0）

```text
可立即迁（不挡产品 L4）：I 入口包装 · J 测试入口委托 · M clean 包装 · 根 Makefile 更薄
须与 g05 同语义：  D/E/F/C 的 .o 热路径（今日已有 shell cc，Makefile 为第二权威）
冷启动硬依赖：    H bootstrap-driver-seed · B pin gen · K seed-tools
删 make 前体积债：C glue ~40k · 阶段 8.3（与本表并行，非 11.0 独占）
11.3 物理删 make：A–O 全 🟢 或 🗑；BC 不再强制 host-cc 业务 C
```

---

## 2. 关键 phony / 产品链（优先填实）

| Makefile 目标 | 行 | 今日落点 | xbuild 拟 | 状态 | 备注 |
|---------------|----|----------|-----------|------|------|
| `all` | 706 | xlang-build.sh → build_tool → g05_build_xlang_asm | `xbuild build` | 🟡 xlang-build→g05；依赖已有 .o | 默认产品入口；依赖已存在 .o |
| `xlang_asm` | 3093 | g05_prepare_and_relink（零 make 宣称） | `xbuild link-product` | 🟢 g05 shell | 金标准 relink 出口 |
| `relink-xlang` | 3089 | g05_relink_xlang.sh | `xbuild link-product` | 🟢 g05_relink_xlang.sh | 与 xlang_asm 同族 |
| `g05-ensure-relink-prereqs` | 3081 | g05_ensure_relink_prereqs.sh (~3.3k 行) | `xbuild ensure` | 🟢 g05_ensure_relink_prereqs.sh | 热路径 cc；filtered.o 已纯 shell（wave715） |
| `g05-export-relink` | 3085 | g05_relink_env.sh | `xbuild link-env` | 🟢 g05_relink_env.sh | 链接清单 |
| `refresh-xlang-asm-gate` | 3172 | Makefile 包装 g05 | `xbuild refresh-gate` | 🟡 仍 make 入口包装 | 应收编 g05 |
| `bootstrap-driver-seed` | ~2995 | **shell 编排** + Makefile prereq/薄叶子 | `xbuild bootstrap` | 🟡 wave717 编排 + wave721 链接 + wave722 sat/lsp shell | L4 必经；OBJS 仍 make 导出 |
| `bootstrap-driver-bstrict` | ~3107 | **shell** `bootstrap_driver_bstrict.sh`；FULL=1 仍 make 入口 | `xbuild bstrict-build` | 🟡 wave719 体 shell；refresh 仍 make | 非日常 |
| `test` / `test_c` / `test_x` | ~1685 | **shell** `run_compiler_tests.sh` | `xbuild test` | 🟢 wave720 体 shell；prereq 仍 make 图 | 嵌套 run-all 可 make |
| `bootstrap-verify` / `check-7.2-bstrict` | ~3320 | **shell** `bootstrap_verify_bstrict.sh` | `xbuild verify` | 🟢 wave720 体 shell；prereq bstrict 图 | 阶段2 仍脚本内 make |
| `bootstrap-driver-bstrict-relink` | 3179 | Makefile | `xbuild bstrict-relink` | ⬜ make |  |
| `bootstrap-driver` | 3193 | Makefile 历史 | `xbuild bootstrap-driver` | ⬜ make | 考古/过渡 |
| `bootstrap-driver-bstrict-windows` | 3196 | Makefile WINDOWS | `xbuild bootstrap-win` | ⬜ Makefile | PLATFORM: WINDOWS |
| `bootstrap-driver-crt0` | 3200 | Makefile | `xbuild crt0` | ⬜ Makefile | 阶段 9 residual 相关 |
| `bootstrap-driver-asm` | 3146 | Makefile | `xbuild bootstrap-asm` | ⬜ Makefile |  |
| `bootstrap-driver-asm-only` | 3151 | Makefile | `xbuild bootstrap-asm-only` | ⬜ Makefile |  |
| `bootstrap-pipeline` | 3359 | Makefile -E pipeline | `xbuild bootstrap-pipeline` | ⬜ Makefile | gen 路径 |
| `bootstrap_xlangc` | 716 | Makefile/预编译种子 | `xbuild bootstrap_xlangc` | ⬜ Makefile | 冷启动种子机 |
| `build-tool` | ~3190 | **shell** `scripts/build_tool.sh` | `xbuild build-tool` | 🟢 wave718 shell | Makefile 薄转调；xlang-build 直调 |
| `first-time` | 3181 | shell build-tool + g05 | `xbuild first-time` | 🟡 wave718 build-tool shell；g05 日常 |  |
| `build-via-tool` | 3262 | Makefile | `xbuild build` | ⬜ Makefile | 与 G-05 合并 |
| `xlang-x` | 3125 | Makefile 工程轨 | `xbuild xlang-x` | ⬜ Makefile | 非产品默认 |
| `xlang-no-c-frontend` | 3112 | Makefile | `xbuild product-frontend` | ⬜ Makefile | G-06 |
| `clean` | 1675 | **shell** `scripts/clean_compiler.sh` | `xbuild clean` | 🟢 wave718 shell | Makefile 薄转调；L4 全擦可直调脚本 |
| `test` | 1707 | Makefile → run-all | `xbuild test` | ⬜ make → tests | 11.2.3 |
| `test_c` | 1696 | Makefile | `xbuild test-c` | ⬜ Makefile | 考古 C 轨 |
| `test_x` | 1701 | Makefile | `xbuild test-x` | ⬜ Makefile |  |
| `std-objs` | 709 | Makefile 聚合 | `xbuild std` | ⬜ Makefile | g05 按需编 |
| `compile_commands.json` | 3418 | Makefile | `xbuild compile-commands 或删` | ⬜ Makefile | IDE 辅助 |
| `size-baseline` | 3422 | Makefile | `xbuild size-baseline 或删` | ⬜ Makefile | 可选 |
| `perf-baseline` | 3426 | Makefile | `xbuild perf-baseline 或删` | ⬜ Makefile | 可选 |
| `verify-selfhost-stage2` | 3131 | Makefile | `xbuild stage2` | ⬜ Makefile | 阶段 11.2.1 |
| `bootstrap-verify` | 3414 | Makefile | `xbuild bootstrap-verify` | ⬜ Makefile |  |
| `bootstrap-verify-seed` | 3410 | Makefile | `xbuild bootstrap-verify` | ⬜ Makefile |  |
| `bootstrap-verify-bstrict` | 3407 | Makefile | `xbuild bootstrap-verify` | ⬜ Makefile |  |
| `bootstrap-verify-stage2` | 3135 | Makefile | `xbuild stage2` | ⬜ Makefile |  |
| `bootstrap-verify-stage2-bstrict` | 3142 | Makefile | `xbuild stage2` | ⬜ Makefile |  |
| `check-7.2` | 3287 | Makefile | `xbuild check-7.2 或 tests/` | ⬜ Makefile | 历史 gate |
| `check-7.2-bstrict` | 3393 | Makefile | `同上` | ⬜ Makefile |  |
| `check-6.4` | 3225 | Makefile | `xbuild check-6.4 或 tests/` | ⬜ Makefile |  |
| `check-asm-o-quality` | 3220 | scripts/check_asm_o_quality.sh | `xbuild check-asm` | ⬜ Makefile | 已有脚本 |
| `check-pipeline-gen-expr-i64-abi` | 3340 | Makefile | `xbuild check-i64-abi` | ⬜ Makefile | P0-4 守卫 |
| `build-seed-asm-host` | 1948 | Makefile | `xbuild seed-asm-host` | ⬜ Makefile | 冷补依赖 |
| `build-user-asm-backend` | 3209 | Makefile | `xbuild user-asm` | ⬜ Makefile |  |
| `bootstrap-driver-seed-user-asm` | 3107 | Makefile | `xbuild bootstrap-user-asm` | ⬜ Makefile |  |
| `regen-lsp-gens-x` | 3118 | Makefile | `xbuild regen-lsp` | ⬜ Makefile | pin 面 |
| `migrate-x-objs` | 2145 | Makefile | `🗑 或 xbuild migrate` | ⬜ Makefile | 历史 |
| `legacy-xlang-c-ready` | 757 | Makefile | `🗑` | ⬜ Makefile | LEGACY 考古 |
| `FORCE` | 2841 | Makefile 强制重编 | `xbuild --force` | ⬜ Makefile | 机制非产品 |

---

## 3. 全量目标清单（按类）

> 自动生成自 `compiler/Makefile` 规则头；变量展开目标（`$(TARGET)` 等）已过滤。  
> **唯一目标数**：288（约；phony 多规则重复计首次行号）。

### 类 A — std / core 模块 .o

- **xbuild**：`xbuild std`
- **今日**：🟡 部分 g05 ensure + xlang_compile_std_module.sh
- **优先**：并行 11.0
- **条数**：65

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 128 | `../std/process/process.o` | 🟡 |
| 135 | `../std/string/string.o` | 🟡 |
| 149 | `../std/path/path.o` | 🟡 |
| 161 | `../std/heap/heap.o` | 🟡 |
| 166 | `../std/heap/page_mmap.o` | 🟡 |
| 171 | `../std/sys/sys.o` | 🟡 |
| 176 | `../std/sys/linux.o` | 🟡 |
| 181 | `../core/mem/mem.o` | 🟡 |
| 186 | `../core/types/types.o` | 🟡 |
| 189 | `../core/option/option.o` | 🟡 |
| 192 | `../core/result/result.o` | 🟡 |
| 197 | `../core/debug/debug.o` | 🟡 |
| 203 | `../core/slice/mod.o` | 🟡 |
| 207 | `../std/map/map.o` | 🟡 |
| 211 | `../std/set/set.o` | 🟡 |
| 216 | `../std/vec/vec.o` | 🟡 |
| 227 | `../std/runtime/runtime.o` | 🟡 |
| 248 | `../std/net/net.o` | 🟡 |
| 353 | `../std/thread/thread.o` | 🟡 |
| 357 | `../std/async/scheduler.o` | 🟡 |
| 365 | `../std/async/future.o` | 🟡 |
| 374 | `../std/time/time.o` | 🟡 |
| 379 | `../std/random/random.o` | 🟡 |
| 386 | `../std/env/env.o` | 🟡 |
| 393 | `../std/fs/fs.o` | 🟡 |
| 398 | `../std/sync/sync.o` | 🟡 |
| 403 | `../std/queue/queue.o` | 🟡 |
| 407 | `../std/encoding/encoding.o` | 🟡 |
| 411 | `../std/base64/base64.o` | 🟡 |
| 416 | `../std/crypto/crypto.o` | 🟡 |
| 421 | `../std/log/log.o` | 🟡 |
| 427 | `../std/test/test.o` | 🟡 |
| 432 | `../std/atomic/atomic.o` | 🟡 |
| 436 | `../std/channel/channel.o` | 🟡 |
| 444 | `../std/backtrace/backtrace.o` | 🟡 |
| 452 | `../std/hash/hash.o` | 🟡 |
| 459 | `../std/math/math.o` | 🟡 |
| 466 | `../std/sort/sort.o` | 🟡 |
| 472 | `../std/ffi/ffi.o` | 🟡 |
| 478 | `../std/context/context.o` | 🟡 |
| 482 | `../std/error/error.o` | 🟡 |
| 487 | `../std/datetime/datetime.o` | 🟡 |
| 495 | `../std/uuid/uuid.o` | 🟡 |
| 505 | `../std/url/url.o` | 🟡 |
| 514 | `../std/cli/cli.o` | 🟡 |
| 523 | `../std/security/security.o` | 🟡 |
| 532 | `../std/config/config.o` | 🟡 |
| 540 | `../std/cache/cache.o` | 🟡 |
| 548 | `../std/trace/trace.o` | 🟡 |
| 557 | `../std/task/task.o` | 🟡 |
| 566 | `../std/schema/schema.o` | 🟡 |
| 574 | `../std/db/kv/kv.o` | 🟡 |
| 582 | `../std/db/arrow/arrow.o` | 🟡 |
| 607 | `../std/db/sqlite/sqlite.o` | 🟡 |
| 629 | `../std/elf/elf.o` | 🟡 |
| 638 | `../std/json/json.o` | 🟡 |
| 641 | `../std/csv/csv.o` | 🟡 |
| 644 | `../std/regex/regex.o` | 🟡 |
| 654 | `../std/unicode/unicode.o` | 🟡 |
| 662 | `../std/dynlib/dynlib.o` | 🟡 |
| 666 | `../std/http/http.o` | 🟡 |
| 670 | `../std/socketio/socketio.o` | 🟡 |
| 683 | `../std/tar/tar.o` | 🟡 |
| 686 | `../std/simd/simd.o` | 🟡 |
| 3436 | `../core/slice/slice.o` | 🟡 |

### 类 B — pinned *_gen.c 规则（cp/pin）

- **xbuild**：`xbuild pin-gen → 去 pin 后 frontend`
- **今日**：⬜ Makefile 权威
- **优先**：阶段 7.4/8.2
- **条数**：18

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 1737 | `parser_gen.c` | ⬜ |
| 1825 | `lexer_gen.c` | ⬜ |
| 2167 | `typeck_gen.c` | ⬜ |
| 2190 | `codegen_gen.c` | ⬜ |
| 2549 | `lsp_diag_gen.c` | ⬜ |
| 2572 | `lsp_io_gen.c` | ⬜ |
| 2611 | `lsp_gen.c` | ⬜ |
| 2648 | `lsp_io_std_heap_gen.c` | ⬜ |
| 2713 | `driver_fmt_gen.c` | ⬜ |
| 2726 | `driver_check_gen.c` | ⬜ |
| 2738 | `driver_test_gen.c` | ⬜ |
| 2750 | `driver_compile_gen.c` | ⬜ |
| 2763 | `driver_build_gen.c` | ⬜ |
| 2775 | `driver_run_gen.c` | ⬜ |
| 2787 | `driver_emit_gen.c` | ⬜ |
| 2855 | `driver_gen.c` | ⬜ |
| 2916 | `preprocess_gen.c` | ⬜ |
| 3319 | `pipeline_gen.c` | ⬜ |

### 类 C — pipeline_glue / pipeline_x / strict_minimal

- **xbuild**：`xbuild glue`
- **今日**：⬜ Makefile + g05 热路径 cc
- **优先**：阶段 8.3
- **条数**：3

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 2823 | `pipeline_x.o` | 🟡 g05 cc 热路径 + Makefile 规则 |
| 3042 | `build_asm/pipeline_glue_types.inc` | ⬜ |
| 3056 | `build_asm/pipeline_glue_strict_minimal.o` | ⬜ |

### 类 D — 前端 *_x.o（parser/typeck/codegen/driver…）

- **xbuild**：`xbuild frontend`
- **今日**：🟡 g05 ensure 热路径
- **优先**：阶段 7–8
- **条数**：20

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 986 | `src/runtime_x.o` | ⬜ |
| 1129 | `src/main_x.o` | ⬜ |
| 1819 | `parser_x.o` | 🟡 g05 / Makefile pin |
| 1888 | `lexer_x.o` | ⬜ |
| 2185 | `typeck_x.o` | 🟡 pin seed |
| 2210 | `codegen_x.o` | 🟡 pin seed |
| 2529 | `ast_x.o` | ⬜ |
| 2568 | `lsp_diag_x.o` | ⬜ |
| 2644 | `lsp_io_std_heap_x.o` | ⬜ |
| 2663 | `lsp_io_x.o` | ⬜ |
| 2671 | `lsp_x.o` | ⬜ |
| 2685 | `driver_fmt_x.o` | ⬜ |
| 2688 | `driver_check_x.o` | ⬜ |
| 2691 | `driver_test_x.o` | ⬜ |
| 2694 | `driver_build_x.o` | ⬜ |
| 2697 | `driver_run_x.o` | ⬜ |
| 2703 | `driver_compile_x.o` | ⬜ |
| 2707 | `driver_emit_x.o` | ⬜ |
| 2912 | `driver_x.o` | ⬜ |
| 2930 | `preprocess_x.o` | ⬜ |

### 类 E — compiler/src 宿主 .o（runtime/driver/asm…）

- **xbuild**：`xbuild runtime-src`
- **今日**：🟡 g05 ensure 热路径
- **优先**：11.0/BC
- **条数**：59

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 724 | `src/lexer/lexer.o` | ⬜ |
| 730 | `src/ast/ast.o` | ⬜ |
| 745 | `src/diag.o` | ⬜ |
| 751 | `src/lsp/lsp_diag.o` | ⬜ |
| 765 | `src/main.o` | ⬜ |
| 773 | `src/runtime_io_abi.o` | ⬜ |
| 792 | `src/runtime_link_abi.o` | ⬜ |
| 801 | `src/runtime_driver_abi.o` | ⬜ |
| 819 | `src/runtime_pipeline_abi.o` | ⬜ |
| 823 | `src/runtime_c_import.o` | ⬜ |
| 830 | `src/async/async_liveness.o` | ⬜ |
| 859 | `src/async/async_cps_codegen.o` | ⬜ |
| 888 | `src/async/async_asm_pool.o` | ⬜ |
| 907 | `src/runtime_driver_diagnostic.o` | ⬜ |
| 926 | `src/runtime.o` | ⬜ |
| 961 | `src/runtime_driver.o` | ⬜ |
| 966 | `src/runtime/rt_arena_buf.o` | ⬜ |
| 969 | `src/runtime/rt_emit_state.o` | ⬜ |
| 972 | `src/runtime/rt_preamble.o` | ⬜ |
| 975 | `src/runtime/rt_stack.o` | ⬜ |
| 979 | `src/runtime/rt_parse_diag.o` | ⬜ |
| 993 | `src/driver/fmt_check_cmd.o` | ⬜ |
| 1028 | `src/driver/fmt_check_cmd_driver.o` | ⬜ |
| 1083 | `src/lexer/cfg_eval.o` | ⬜ |
| 1125 | `src/runtime_driver_no_c.o` | ⬜ |
| 1605 | `src/asm/crt0_x86_64.o` | ⬜ |
| 1608 | `src/asm/crt0_user_x86_64.o` | ⬜ |
| 1611 | `src/asm/freestanding_io_x86_64.o` | ⬜ |
| 1619 | `src/asm/bootstrap_nostdlib_stubs.o` | ⬜ |
| 1626 | `src/asm/crt0_arm64.o` | ⬜ |
| 1629 | `src/asm/crt0_darwin_x86_64.o` | ⬜ |
| 1635 | `src/asm/crt0_mingw.o` | ⬜ |
| 1642 | `src/typeck/typeck_f64_bits.o` | ⬜ |
| 1894 | `src/x_seed_bridge.o` | ⬜ |
| 1963 | `src/asm/user_asm_seed_bridge.o` | ⬜ |
| 1967 | `src/asm/asm_backend_compat_stubs.o` | ⬜ |
| 1971 | `src/asm/backend_enc_dispatch.o` | ⬜ |
| 1989 | `src/asm/backend_x86_64_enc_c.o` | ⬜ |
| 1994 | `src/asm/backend_arm64_enc_c.o` | ⬜ |
| 1997 | `src/asm/backend_arch_emit_dispatch.o` | ⬜ |
| 2014 | `src/asm/backend_try_inline_dispatch.o` | ⬜ |
| 2031 | `src/asm/backend_call_dispatch.o` | ⬜ |
| 2092 | `src/asm/parser_asm_parse_expr_link.o` | ⬜ |
| 2141 | `src/asm/asm_experimental_symbol_bridge.o` | ⬜ |
| 2238 | `src/main_driver.o` | ⬜ |
| 2242 | `src/driver/target_cpu.o` | ⬜ |
| 2251 | `src/asm/simd_enc.o` | ⬜ |
| 2271 | `src/asm/simd_loop.o` | ⬜ |
| 2490 | `src/lsp/lsp_diag_pipeline_sizes.o` | ⬜ |
| 2499 | `src/lsp/lsp_diag_pipeline_sizes_nostub.o` | ⬜ |
| 2515 | `src/lsp/lsp_diag_pipeline_ctx.o` | ⬜ |
| 2519 | `src/runtime_driver_strict_glue_stubs.o` | ⬜ |
| 2525 | `src/ast/ast_seed.o` | ⬜ |
| 2540 | `src/lexer/cfg_eval_bootstrap_stub.o` | ⬜ |
| 2604 | `src/lsp/typeck_lsp_io_stub.o` | ⬜ |
| 2608 | `src/seed_link_compat.o` | ⬜ |
| 2938 | `src/lsp/lsp_diag_stubs_no_c.o` | ⬜ |
| 3255 | `src/build_tool_main.o` | ⬜ |
| 3444 | `src/asm/runtime_asm_build.o` | ⬜ |

### 类 F — runtime_* residual 宿主 .o

- **xbuild**：`xbuild residual-c（白名单）`
- **今日**：🟡 g05 ensure
- **优先**：阶段 9
- **条数**：31

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 1160 | `runtime_panic.o` | ⬜ |
| 1204 | `runtime_asm_io_stubs.o` | ⬜ |
| 1210 | `runtime_test_fn_invoke.o` | ⬜ |
| 1223 | `runtime_random_fill.o` | ⬜ |
| 1244 | `runtime_compress_zlib_glue.o` | ⬜ |
| 1258 | `runtime_time_os.o` | ⬜ |
| 1276 | `runtime_queue_contention.o` | ⬜ |
| 1294 | `runtime_dynlib_os.o` | ⬜ |
| 1310 | `runtime_link_abi_user_env.o` | ⬜ |
| 1315 | `runtime_env_os.o` | ⬜ |
| 1331 | `runtime_backtrace_platform.o` | ⬜ |
| 1347 | `runtime_log_os.o` | ⬜ |
| 1363 | `runtime_math_libm.o` | ⬜ |
| 1379 | `runtime_atomic_glue.o` | ⬜ |
| 1395 | `runtime_channel_glue.o` | ⬜ |
| 1406 | `runtime_net_udp_batch.o` | ⬜ |
| 1419 | `runtime_net_workers.o` | ⬜ |
| 1431 | `runtime_sync_os.o` | ⬜ |
| 1451 | `runtime_sync_lock_diag_tls.o` | ⬜ |
| 1463 | `runtime_thread_glue.o` | ⬜ |
| 1479 | `runtime_scheduler_glue.o` | ⬜ |
| 1484 | `runtime_http_glue.o` | ⬜ |
| 1502 | `runtime_tls_mbedtls_bio.o` | ⬜ |
| 1516 | `runtime_kv_mmap_glue.o` | ⬜ |
| 1521 | `runtime_arrow_simd_glue.o` | ⬜ |
| 1533 | `runtime_sqlite_glue.o` | ⬜ |
| 1537 | `runtime_sqlite_glue_stub.o` | ⬜ |
| 1542 | `runtime_crypto_inc_glue.o` | ⬜ |
| 1559 | `runtime_ed25519_ref10_glue.o` | ⬜ |
| 1576 | `runtime_process_argv.o` | ⬜ |
| 1588 | `runtime_process_os_glue.o` | ⬜ |

### 类 G — build_asm/ 过滤 .o

- **xbuild**：`xbuild build-asm-filter`
- **今日**：🟢 **全 4 纯 shell**（wave715 pipeline · wave716 partial trio + 共用核心）
- **优先**：已闭；bstrict 路径 `ensure_bstrict_filtered_*` 仍为 build_xlang_asm 内副本（follow-up 可收敛）
- **条数**：4
- **权威（G.7）**：
  - 核心：`compiler/scripts/filter_o_export_against_deps.sh`
  - 命名包装：`filter_bootstrap_seed_pipeline_o.sh` · `filter_bootstrap_seed_against_partial_o.sh`
  - 调用方：Makefile 类 G 四目标 + `g05_ensure`（Darwin 产品卫生）

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 2095 | `build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o` | 🟢 against_partial（wave716） |
| 2105 | `build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o` | 🟢 against_partial（wave716） |
| 2115 | `build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o` | 🟢 against_partial（wave716） |
| 2125 | `build_asm/bootstrap_seed_pipeline_filtered.o` | 🟢 pipeline wrapper（wave715/716 转调核心） |

### 类 H — bootstrap / 产品二进制 phony

- **xbuild**：`xbuild bootstrap / link-product`
- **今日**：🟡 冷=make；bstrict/verify 体 shell（wave719–720）；产品=g05
- **优先**：11.0.3
- **条数**：35

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 706 | `all` | 🟡 xlang-build→g05；依赖已有 .o |
| 716 | `bootstrap_xlangc` | ⬜ |
| 1699 | `bootstrap-token` | 🟢 wave719 shell |
| 1703 | `bootstrap-lexer` | 🟢 wave719 shell |
| 1720 | `bootstrap-parser` | ⬜ |
| 1725 | `bootstrap-parse-file` | ⬜ |
| 2215 | `bootstrap-typeck` | ⬜ |
| 2224 | `bootstrap-codegen` | ⬜ |
| 2479 | `bootstrap-driver-seed-x-frontend` | ⬜ |
| 2957 | `bootstrap-driver-seed` | ⬜ 冷启动 Makefile 权威 |
| 3093 | `xlang_asm` | 🟢 g05 shell（日常） |
| 3107 | `bootstrap-driver-seed-user-asm` | ⬜ |
| 3112 | `xlang-no-c-frontend` | ⬜ |
| 3125 | `xlang-x` | ⬜ |
| 3135 | `bootstrap-verify-stage2` | ⬜ |
| 3142 | `bootstrap-verify-stage2-bstrict` | ⬜ |
| 3146 | `bootstrap-driver-hybrid` | ⬜ |
| 3146 | `bootstrap-driver-asm` | ⬜ |
| 3151 | `bootstrap-driver-asm-only` | ⬜ |
| ~3107 | `bootstrap-driver-bstrict` | 🟡 wave719 体 shell；refresh 仍 make |
| 3179 | `bootstrap-driver-bstrict-relink` | ⬜ make |
| 3193 | `bootstrap-driver` | ⬜ make |
| 3196 | `bootstrap-driver-bstrict-windows` | ⬜ |
| 3200 | `bootstrap-driver-crt0` | ⬜ |
| 3209 | `build-user-asm-backend` | ⬜ |
| 3213 | `bootstrap-asm` | ⬜ |
| 3216 | `bootstrap-asm-full` | ⬜ |
| 3270 | `bootstrap-self` | ⬜ |
| 3359 | `bootstrap-pipeline` | ⬜ |
| 3370 | `xlang-x-pipeline` | ⬜ |
| 3380 | `bootstrap-x-compiler` | ⬜ |
| 3389 | `bootstrap-test` | ⬜ |
| 3407 | `bootstrap-verify-bstrict` | ⬜ |
| 3410 | `bootstrap-verify-seed` | ⬜ |
| 3414 | `bootstrap-verify` | ⬜ |

### 类 I — g05 / relink / build-tool 入口

- **xbuild**：`xbuild link-product`
- **今日**：🟢 产品已 shell；**build-tool shell（wave718）**
- **优先**：11.0.2
- **条数**：9

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 3081 | `g05-ensure-relink-prereqs` | 🟢 |
| 3085 | `g05-export-relink` | 🟢 |
| 3089 | `relink-xlang` | 🟢 |
| 3097 | `relink-xlang-lexer` | ⬜ |
| 3172 | `refresh-xlang-asm-gate` | 🟡 仍 make 入口包装 |
| 3181 | `first-time` | 🟡 shell build-tool + g05（wave718） |
| ~3190 | `build-tool` | 🟢 shell `build_tool.sh`（wave718） |
| ~3198 | `build-tool-x` | 🟢 别名 → build-tool |
| 3262 | `build-via-tool` | ⬜ |

### 类 J — test / check / verify / baseline

- **xbuild**：`xbuild test / cold-test / prove`
- **今日**：🟡 phase1/final 链接（wave721）+ sat/lsp rebuild（wave722）导出+shell；test*/verify shell（wave720）；tests/lib 仍 make
- **优先**：11.0.3 / 11.2.3
- **条数**：12

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| ~1685 | `test_c` | 🟢 wave720 shell `run_compiler_tests.sh c` |
| ~1690 | `test_x` | 🟢 wave720 shell `run_compiler_tests.sh x` |
| ~1694 | `test` | 🟢 wave720 → test_c+test_x（xlang-build: mode all） |
| 3131 | `verify-selfhost-stage2` | ⬜ |
| 3139 | `verify-selfhost-stage2-bstrict` | ⬜ 脚本仍内 make |
| 3220 | `check-asm-o-quality` | ⬜ |
| 3225 | `check-6.4` | ⬜ |
| 3287 | `check-7.2` | ⬜ seed 路径 |
| 3340 | `check-pipeline-gen-expr-i64-abi` | ⬜ |
| ~3320 | `check-7.2-bstrict` / `bootstrap-verify` | 🟢 wave720 shell `bootstrap_verify_bstrict.sh` |
| 3422 | `size-baseline` | ⬜ |
| 3426 | `perf-baseline` | ⬜ |

### 类 K — seed 工具（asm host / regen）

- **xbuild**：`xbuild seed-tools`
- **今日**：⬜ Makefile
- **优先**：11.0.3
- **条数**：3

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 1948 | `build-seed-asm-host` | ⬜ |
| 2145 | `migrate-x-objs` | ⬜ |
| 3118 | `regen-lsp-gens-x` | ⬜ |

### 类 L — std 变体（sqlite/net/compress stub）

- **xbuild**：`xbuild std-variant`
- **今日**：⬜ Makefile
- **优先**：并行
- **条数**：10

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 313 | `net-o-stub` | ⬜ |
| 317 | `net-o-openssl` | ⬜ |
| 331 | `net-o-mbedtls` | ⬜ |
| 613 | `sqlite-o` | ⬜ |
| 614 | `sqlite-o-stub` | ⬜ |
| 651 | `compress-o-zlib` | ⬜ |
| 651 | `compress-o-zlib-zstd` | ⬜ |
| 651 | `compress-o-brotli` | ⬜ |
| 651 | `compress-o-zlib-zstd-brotli` | ⬜ |
| 709 | `std-objs` | ⬜ |

### 类 M — clean / compile_commands / legacy

- **xbuild**：`xbuild util 或删除`
- **今日**：🟡 clean→shell（wave718）；compile_commands 等仍 make
- **优先**：11.0.4
- **条数**：6

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 757 | `legacy-xlang-c-ready` | ⬜ |
| 1675 | `clean` | 🟢 shell `clean_compiler.sh`（wave718） |
| 1944 | `parser-legacy-text-o` | ⬜ |
| 2841 | `FORCE` | 🗑 机制 |
| 3362 | `gen-x-driver-objs` | ⬜ |
| 3418 | `compile_commands.json` | ⬜ |

### 类 N — link alias / 其它 .o

- **xbuild**：`xbuild stubs`
- **今日**：🟡 g05
- **优先**：BC
- **条数**：11

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 1614 | `crt0_user.o` | ⬜ |
| 1616 | `freestanding_io.o` | ⬜ |
| 1899 | `x_frontend_link_alias.o` | ⬜ |
| 1903 | `ast_asm_bare_link_alias.o` | ⬜ |
| 1906 | `backend_asm_bare_link_alias.o` | ⬜ |
| 1909 | `backend_asm_strict_fallback_alias.o` | ⬜ |
| 1912 | `typeck_c_module_stubs.o` | ⬜ |
| 2056 | `parser_asm_thin_glue.o` | ⬜ |
| 2164 | `ast_gen2.o` | ⬜ |
| 2808 | `_x_stubs2.o` | ⬜ |
| 3048 | `pipeline_bootstrap_orchestration.o` | ⬜ |

### 类 O — 未分类 / 死规则候选

- **xbuild**：`删除或不迁`
- **今日**：⬜ 人工确认
- **优先**：11.0 瘦身
- **条数**：2

| 行 | Makefile 目标 | 迁移状态 |
|----|---------------|----------|
| 1148 | `PIPELINE_LIBS` | ⬜ 待确认 |
| 2149 | `ast_gen2.c` | ⬜ 待确认 |

---

## 4. 根 `Makefile` / `xlang-build.sh` 对照

| 根入口 | 委托 | 是否仍 make | 终局 |
|--------|------|-------------|------|
| `make all/build/xlang` | `./xlang-build.sh build` | build-tool 缺失时 **shell**；日常 g05 | `xbuild build` |
| `make full/bstrict` | `xlang-build.sh full` | FULL→make bstrict | `xbuild cold-test` 子集 |
| `make build-tool` | xlang-build → `build_tool.sh` | **否**（wave718） | `xbuild build-tool` |
| `make test*` | xlang-build | **是** `make -C compiler test*` | `xbuild test` |
| `make kernel*` | tests/kernel/*.sh | 否（已 shell） | `xbuild kernel` |
| `make clean` | xlang-build → `clean_compiler.sh` | **否**（wave718） | `xbuild clean` |
| `./xlang-build.sh build` | build_tool → g05 | 产品链 0-make；**wave720** 入口 0× make -C | 收敛为 xbuild 唯一 |

---

## 5. 已知「产品路径仍碰 make」泄漏（11.0.2）

| 位置 | 现象 | 处置 |
|------|------|------|
| `g05_build_xlang_asm.sh` FULL=1 | `exec make bootstrap-driver-bstrict` | 标注非日常；迁 `xbuild bstrict-build` |
| ~~`g05_ensure` filtered.o~~ | ~~`make -s`~~ | ✅ wave715 pipeline · **wave716 class-G 全 4**（against_partial trio + 核心脚本） |
| `g05_ensure` 失败提示 | 建议用户 `make bootstrap-driver-seed` | 改提示为 `xbuild bootstrap`（实现后） |
| ~~`xlang-build.sh` build-tool/first-time/clean~~ | ~~`make -C`~~ | ✅ **wave718** → `build_tool.sh` / `clean_compiler.sh` |
| ~~`xlang-build.sh` bootstrap-token/lexer/bstrict~~ | ~~`make -C`~~ | ✅ **wave719** → `bootstrap_token_lexer_smoke.sh` / `bootstrap_driver_bstrict.sh` |
| ~~`xlang-build.sh` test*/bootstrap-verify~~ | ~~`make -C`~~ | ✅ **wave720** → `run_compiler_tests.sh` / `bootstrap_verify_bstrict.sh`（**0× make -C**） |
| `tests/lib/**` 等 ~31+ 文件 | `make -C compiler` | 阶段 11.2.3 |
| CI `.github/workflows` | make/cc | 阶段 11.2.5 |

---

## 5b. 冷启动 `bootstrap-driver-seed` recipe 内 `$(MAKE)` 白名单（11.0.3 · wave716–717）

> **用途**：冻结冷启动仍调用 make 的显式集合；新加 `$(MAKE)` 须先改本表。  
> **编排权威（wave717）**：`compiler/scripts/bootstrap_driver_seed.sh`（步序 / seed partial 选择 / smoke / 别名 cp）。  
> **Makefile 薄壳**：`bootstrap-driver-seed` = prereq 依赖图 + 转调 shell；OBJS/CFLAGS 仅 export leaves；phase1/final 链接体 `bootstrap_driver_seed_link.sh`（G.7 单权威，禁 shell 复制 OBJ 列表）。

| # | recipe 内 make 调用（语义） | 状态 | 备注 |
|---|------------------------------|------|------|
| 1 | `check-pipeline-gen-expr-i64-abi` | 🟡 shell 调 make | shell 白名单 `mk` |
| 2 | `pipeline_x.o` FORCE | 🟡 shell 调 make | `PIPELINE_X_FORCE_COMPILE=1` |
| 3 | `-B` 卫星 runtime/diag/simd… | 🟢 shell 体 + 导出 | wave722：`bootstrap_driver_seed_rebuild_leaves.sh sat` + `export-sat-rebuild`（`DRIVER_SEED_SAT_REBUILD_OBJS` 单权威） |
| 4 | `lsp_io_x.o` `lsp_x.o` … | 🟢 shell 体 + 导出 | wave722：`rebuild_leaves.sh lsp` + `export-lsp-x-objs`（`DRIVER_SEED_LSP_X_OBJS` 单权威） |
| 5 | `src/x_seed_bridge.o` | 🟡 shell 调 make | |
| 6 | `$(USER_ASM_SEED_OBJS)` | 🟡 薄目标 | `bootstrap-driver-seed-user-asm-seed-objs` |
| 7 | `$(ASM_GLUE_STANDALONE_O)` | 🟡 薄目标 | `bootstrap-driver-seed-asm-glue-standalone` |
| 8 | `build-seed-asm-host` | 🟡 半 shell | 已有 `build_seed_asm_host.sh` |
| 9 | `$(USER_ASM_SEED_HOST_STUBS)` | 🟡 薄目标 | `bootstrap-driver-seed-host-stubs` |
| 10 | `$(BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS)` | 🟢 shell 体 | wave716 配方纯 shell；wave717 经薄目标 |
| 11 | phase1/final `$(CC)` 链接 | 🟢 shell 体 + 导出 | wave721：`bootstrap_driver_seed_link.sh` + `export-phase1/final-link`（OBJS 仍 Makefile 单权威） |
| 12 | `runtime_panic.o` | 🟡 shell 调 make | |
| 13 | smoke / `bootstrap_xlangc_create` | 🟢 已 shell | smoke + create 由编排脚本转调 |

**wave716**：类 G 四目标无内联 nm/ld。  
**wave717**：编排主体迁 shell；Makefile 仅 prereq + 薄叶子 + 转调。

---

## 6. 建议迁移顺序（11.0 内）

1. **11.0.1** 本表 ✅（wave714）
2. **11.0.2** 产品路径 0-make 静态闸门 ✅ + class-G filtered 全 shell ✅（wave714–716）；运行时 PATH 无 make 探针仍可加
3. **11.0.3** `bootstrap-driver-seed` 规则白名单化 → shell/xbuild 逐步接管（**wave716**–**wave722**：类 G + 编排 + build-tool/clean + token/bstrict + test*/verify 0-make + phase1/final 链接 + **sat/lsp rebuild 导出+shell**；OBJS 变量仍 make）
4. **11.0.4** 根 Makefile 仅 help→xbuild；禁止新规则
5. 并行：**类 C glue 地图**（阶段 8.3）· **类 B/D 去 pin 烟**（7.4）
6. **11.1+** 填实 `build.x` / 吞并 g05 → **11.3 物理删**

---

## 7. 变更记录

| 日期 | 波次 | 变更 |
|------|------|------|
| 2026-07-29 | **wave722** | 11.0.3 续：`bootstrap_driver_seed_rebuild_leaves.sh` + export-sat/lsp；`DRIVER_SEED_SAT_REBUILD_OBJS` / `DRIVER_SEED_LSP_X_OBJS` 单权威；0-make 闸门硬检；dry-run 10+5 targets |
| 2026-07-29 | **wave721** | 11.0.3 续：`bootstrap_driver_seed_link.sh` + export-phase1/final-link；OBJS/CFLAGS Makefile 单权威；gen_g06 读 export；0-make 闸门硬检；mac phase1 59 objs 真链 |
| 2026-07-29 | **wave720** | 11.0.3 续：`run_compiler_tests.sh` + `bootstrap_verify_bstrict.sh`；Makefile 薄转调；xlang-build make -C **4→0**；0-make 闸门硬检 sites=0 |
| 2026-07-29 | **wave719** | 11.0.3 续：`bootstrap_token_lexer_smoke.sh` + `bootstrap_driver_bstrict.sh`；Makefile 薄转调；xlang-build make -C 7→4；0-make 闸门硬检 sites≤4 |
| 2026-07-29 | **wave718** | 11.0.3 续：`build_tool.sh` + `clean_compiler.sh`；Makefile 薄转调；xlang-build make -C 11→7；0-make 闸门硬检 sites≤7 |
| 2026-07-29 | **wave717** | 11.0.3 续：`bootstrap_driver_seed.sh` 编排权威；Makefile 薄壳 prereq + §5b 薄叶子（sat/lsp/user-asm/glue/filtered/host-stubs/phase1/final link）；0-make 闸门硬检 shell 转调；OBJS/CFLAGS 仍 make（防双权威） |
| 2026-07-29 | **wave716** | 11.0.3 起点：类 G 全 4 纯 shell（`filter_o_export_against_deps.sh` + against_partial 包装）；g05_ensure Darwin trio；§5b 冷启动 make 白名单；0-make 闸门硬检 Makefile 无内联 nm/ld |
| 2026-07-29 | **wave715** | 11.0.2 residual：`filter_bootstrap_seed_pipeline_o.sh` 为 pipeline filtered.o 唯一权威；g05_ensure 去 `make -s`；Makefile 同调；0-make 闸门 WARN 清零 |
| 2026-07-29 | wave714 | 11.0.1 初版：289 目标分类 A–O + 关键 phony 表 + 泄漏清单 |

