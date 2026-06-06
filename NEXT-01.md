# Shulang 下一步开发清单

> **北极星**：**自举**（B-strict 替代 seed）→ **完善功能**（语言/工具链/std 对标 Zig 可用性）→ **性能超越 Zig**（计算 + I/O + 网络 + 零拷贝，均有 bench 与 CI 门禁）。  
> 背景：`compiler/docs/SELFHOST.md`、`analysis/perf-vs-zig-baseline.md`、`std/fs/PERF-ASSESSMENT.md`、`std/README.md`。

---

## 零、综合诊断（2026-05）

### 0.1 三条主线现状


| 主线             | 已达成                                                                                        | 真实缺口                                                                                                                            | 相对 Zig                                  |
| -------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| **自举**         | B-strict 链通；**M7** 默认 bstrict；`check-asm-o-quality` **24/24**；Stage2 B-strict；**107 项** 白名单 | typeck 整颗 SU 直链（layout partial 已够用）；全量 run-all 白名单 **107/107 @ shu_asm**                                                        | Zig 已自举；我们 **M7 ✅、M8 ✅、M8-tail ✅、F6 ✅** |
| **功能**         | `check/fmt/test`、**107 项** bstrict（全量 run-all 白名单 @ shu_asm）                              | `std.simd` 占位；async 最小门面                                                                                                        | API 面接近 Zig                             |
| **性能（计算）**     | P0–P3：四 microbench ≤ C -O2；CI `SHU_PERF_FAIL_ON_ZIG` + compile dogfood                     | Linux CI 有 zig 时方可真正 **≤ Zig**；归纳变量/内联仍偏窄                                                                                       | **微基准同级**；未证明全面超越                       |
| **性能（I/O/网络）** | Linux **io_uring** + 批 readv/writev；**I1–I6/N1–N4** bench                                  | macOS：**P1 asm std 绿**（accept 0.214s、echo 0.148s、udp 0.163s ≈ C）；`SHU_PERF_FAIL_ON_NET_REGRESSION=1` 通过；sendfile **~0.17s ≈ C** | **L1/L0 macOS 已对齐 C**；Linux CI 主战场      |
| **性能（零拷贝）**    | 写路径直传 ptr；`read_ptr`；fs mmap/sendfile；**Z1/Z2** bench + 生命周期文档                             | —                                                                                                                               | 设计对齐，**已量化（I1/Z1）+ 文档化（Z2）**            |


### 0.2 性能超越 Zig：分层目标

```
┌─────────────────────────────────────────────────────────────┐
│  L4  生态默认：release shu = shu_asm，用户无感 B-strict       │
├─────────────────────────────────────────────────────────────┤
│  L3  编译器：compile dogfood 中位数不升（P3 ✅）               │
├─────────────────────────────────────────────────────────────┤
│  L2  计算：asm microbench ≤ Zig -O2（P2 ✅，待 Linux CI 实锤）│
├─────────────────────────────────────────────────────────────┤
│  L1  I/O：mmap/read_batch/sendfile 吞吐 ≥ Zig std+uring 同级  │  ← macOS 已对齐 C；Linux CI 待实锤
├─────────────────────────────────────────────────────────────┤
│  L0  网络：accept_many/connect_many 并发 ≥ Zig+libxev 同级   │  ← macOS accept/echo/udp 已对齐 C
└─────────────────────────────────────────────────────────────┘
```

**纪律**（不变）：

1. 自举阻塞项优先于 perf 微优化。
2. 改 **用户默认 `-backend asm -o`** 须对应 bench 用例。
3. 宣称「超越 Zig」的每一层须 **脚本 + 基线文件 + CI 可选 fail**（与 P2/P3 同模式）。

### 0.3 推荐排序（接下来 3 个季度）


| 优先级    | 方向                                               | 理由                                                                                                |
| ------ | ------------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| **P0** | Linux CI perf 实锤（L1/L2）+ bootstrap CI 门禁         | **`run-bootstrap-bstrict-ci.sh` 含 asm-73**；**Stage2 末 Step5** 恢复 `shu_asm`（gen2 留 `shu_asm2`）；**`run-pre-push-p0.sh`** 不再 `make -C compiler` 覆盖 seed；perf P1 偶发 `io_write` 超 cap（重跑可过）；**待 push 触发 GHA** |
| **P1** | IO/网络 bench + 回归门禁（L1/L0）                        | 本地 `SHU_PERF_FAIL_ON_*` 全绿 ✅；Linux CI 已加 `IO_REGRESSION`；`zero_copy`/`net_*` @ shu_asm 编译绿        |
| **P2** | 功能：async 最小运行时；run-json 等 std 扩 bstrict（F1–F2 ✅） | 与 Zig 用户态并发叙事对齐                                                                                   |
| **P3** | asm 计算继续：SIMD 内联、更多 call 模式                      | **call-inline 11 例**（vec add/sub/mul/**div**）；门禁脚本共用 `ensure-compiler-seed.sh`；`io_write` cap **0.032** |


---

## 一、主线 1：自举（M6 完成 → M9）

### 1.1 已达里程碑（摘要）


| 代号    | 验收                                                       |
| ----- | -------------------------------------------------------- |
| M2–M5 | B-strict 链通；gate；Linux crt0；Stage2 `shu_asm→shu_asm2`    |
| M6    | `run-all-bstrict.sh` **52/52**；CI bstrict-ci + stage2 预检 |


详见 `compiler/docs/SELFHOST.md` §4；白名单矩阵见 `tests/docs/run-all-l5-whitelist.md`。

### 1.2 下一步


| 状态  | 项                                       | 验收                                                                                                                                                             |
| --- | --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ✅   | **M7**：release 默认 B-strict              | `make bootstrap-driver` = bstrict；`shu_asm` 默认覆盖 `compiler/shu`；seed 仅 `bootstrap-driver-seed` / `make all`                                                    |
| ✅   | **M8**：消除 skip_heavy 桩                  | B-strict **88/88** + stage2 + M11 全绿；`asm_codegen_ast*` bl→C（seed_mega 全量）                                                                                     |
| ✅   | **M8-tail**：skip_heavy 清零               | pipeline **12** 项 mega **bl→C**；backend **32** 薄包装；`bootstrap-verify` 绿                                                                                        |
| ✅   | **M8-tail-bl**：backend 薄包装 bl 委托        | `pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c`；`backend.o` **32** 项 thin **bl** → `pipeline_asm_*_c`；`backend.o` __text **5040B**；`make bootstrap-verify` 绿 |
| ✅   | **M8-core**                             | gate + struct + assign/struct_lit @ `shu_asm`/`shu-su`；`pipeline_su.o` 勿 stale；`make shu-su` + `./tests/run-struct.sh` 绿                                       |
| ✅   | **M8-emit**                             | `emit_expr_elf` 薄包装；`run-all-bstrict` **88/88** + `bootstrap-verify` 绿                                                                                         |
| ✅   | **M8-link**                             | **默认直链** `build_asm/pipeline.o` + `glue_standalone`（**无 strict_core partial**）；编排全在 **C glue**；**pipeline.o ~1460B**；smoke + gate + stage2 全绿                  |
| ✅   | **M8-typeck**                           | **EMIT_HEAVY 9448B**；strict：**layout partial（build_asm）** + **typeck_su_no_layout**（while 60 绿）；整颗 typeck.o 直链待 SU emit 对齐                                     |
| ✅   | **M8a**：`arm64_enc` 限定类型名 + parser      | `consume_qualified_type_ident_name`；`arm64_enc.o` **1008B**；M8a 第二遍不覆盖非空 `__text`                                                                              |
| ✅   | **M8b**：`asm.su` 入口可 emit               | `let`+单条 `return` 累加 + `write_elf_o_to_buf`；`asm.o` **156B**（4 funcs）                                                                                          |
| ✅   | **M8b**：`lsp.su` / `pipeline.su`        | parser：`return` 不越过 `}` + 限定类型名；`lsp.o` **588B**；**pipeline.o ~1488B**（编排 C glue + path/load helper emit）                                                      |
| ✅   | **M8c**：`check-asm-o-quality` **24/24** | `SHU_ASM_QUALITY_STRICT=1` + `build_asm/.asm_text_quality=1`（含 `preprocess`/`macho`）                                                                           |
| ✅   | **M9**：语义自举迁 B-strict                   | `**make bootstrap-verify`** = `check-7.2-bstrict`（shu_asm→shu_asm2 + lexer/typeck **全绿**）；C glue `pipeline_glue_should_skip_su_typeck` 修复 stage2 SKIP          |
| ✅   | M10：全量 run-all @ shu_asm                | bstrict **107 项**；`run-pool-limits.sh` @ shu_asm（嵌套 while lazy base + 用户模块 skip_heavy 豁免）                                                                     |
| ✅   | M11：macOS 生产 B-strict                   | `full_asm` 拓扑（__text 24/24 自动选）+ `asm_only_strict`；B-strict 路径跳过 `ensure_asm_gen_driver_su_objs`；链接审计无 `cc -c pipeline_gen.c`                                  |


### 1.3 已知风险（须跟踪）

- `shu_asm -o` 偶发 SIGSEGV → `SHU_SKIP_PARSE_SMOKE=1`、import 重试（M3-b 文档）。  
- 改 `backend.su` 后须 `./scripts/build_seed_asm_host.sh` + `make shu-su` / `make relink-shu`（seed 路径；partial 导出须剔除 `backend_enc_dispatch.o` 已有符号；`fix_backend_enc_recursive_gen_c.pl` 剥离自递归桩）。  
- **C glue 与 `backend.su::AsmFuncCtx` 字段须一一对应**（勿多 `func_elf_label_scope` 等 phantom 字段，否则 `tail_join_label_len` 读错、`return` 全挂）。  
- **emit_expr_elf 薄包装勿与 slow 互调**：`backend_emit_expr_elf_slow` 须调 `backend_emit_expr_elf_full`（seed partial），否则 C glue↔薄包装无限递归 → 编译用户程序 SIGSEGV（如 `struct_add_pair_inline.su`）。
- 命名 struct：**块内 let** 按值落栈（field/index 基址 lea）；**形参** 槽存 8B 指针（field/index 基址 load）。CALL 实参 let struct 须 lea 传地址。
- assign 左值 field（VAR 基址）：arm64 rbx=x1，须**先 emit 右值→rax 再 lea 基址→x1**，避免 `i & 1` 等写 w1 覆盖基址。
- **while 内外层 let + CALL 内联**：`asm_ctx_local_find_offset_scoped` 子树未命中须回退 `asm_ctx_local_find_offset`（否则 `add_pair(外层 p)` 仍 `bl`）；改 `ast_pool_bootstrap_glue.c` 后须重编 `pipeline_su.o`（`touch ast_pool.c && make relink-shu`）。
- 改 `parser.su` 后须 `make parser_su.o` + `make relink-shu`；**`make refresh-shu-asm-gate`**（= relink-shu + cp shu→shu_asm）供 asm struct mk 门禁；纯 strict **shu_asm2** 常仍 `bl mk`（`typeck_su_no_layout` 与 seed `pipeline_su.o` 链差异，待收敛）。
- **B-strict strict 链接**：`parser_su.o` 置于链接线末尾（`ST_PARSER_SU_TAIL`），`ensure_parser_su_o_for_strict_link` 构建前刷新。
- **struct mk 内联**：`backend_try_inline_dispatch.c` 对 struct-lit fold 走 `pipeline_module_func_body_ref_at`（B-strict backend fold 桩不可靠）；`try_inline_struct_lit_return_call_to_slot` 已接。
- **`parse_into`/`parse_into_buf` 的 param-binop 重建**：须**嵌套 if**（`return_expr_ref==0` 再判 binop）；勿写 `a && b || c`（`-E` 成 C 后为 `(a&&b)||c`，会误覆盖 struct return）。  
- `asm_module_is_parser_selfhost` 上界须 ≥ parser.su 当前 func 数（~288）；否则 SKIP 第二遍 whitelist 会对 `parse_into_buf` 真 emit 并 elf patch 失败。
- 单模块 asm **无** `SKIP_TYPECK` 时：须 `pipeline_driver_su_pipeline_skip_typeck`（C 预检后跳过重复 .su typeck）；全量 emit 若 `write_elf_o_to_buf` 失败须查 `asm_codegen_elf_o`（非再降 SKIP 桩）。  
- `check` 后 `driver_dep_seeded_clear_all` 清 dep/typeck 槽。

---

## 二、主线 2：完善功能

### 2.1 已达（摘要）

- 工具链：`shu check/fmt/test` 纳入 gate；注释/fmt 折行门禁。  
- L5：`run-all` 白名单 **107 项** @ seed/shu_asm（见矩阵文档）。  
- std：io/fs/net/thread/time/json/csv… 已完善（`std/README.md` §一）。

### 2.2 下一步


| 状态  | 项                       | 验收                                                                                                                       |
| --- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| ✅   | **F1**：bstrict + run-io | `run-io.sh` 进 `run-all-bstrict.sh`（53 项）；M7 `compiler/shu` 下含 read_ptr 全绿                                                |
| ✅   | **F2**：http/tar/json 回归 | `run-http`/`run-tar`/`run-json` + `ensure_std_c_o`；进 bstrict 白名单（**56 项**）                                               |
| ✅   | **F3**：process spawn    | `std.process` spawn/exec/waitpid/pipe + `tests/run-process.sh` @ **shu_asm**（bstrict 白名单）                                |
| ✅   | **F4**：`std.async` 最小集  | `wait_completion` + `submit_read_sync`/`submit_write_sync`（`std/async/mod.su`）；对接 `std.io` wait_readable / io_uring      |
| ✅   | **F5**：std 边界测试         | 各 std 模块均有 `tests/run-*.sh` 或 `tests/<mod>/`（process/env/crypto/net…）；`run-pool-limits` / `run-boundary-encodings` 覆盖池上限 |
| ✅   | **F6**：全量 run-all 收敛    | **107 项** @ shu_asm；`run-pool-limits`（grow 池 / 嵌套 loop / many_locals / many_funcs）                                      |


---

## 三、主线 3：性能超越 Zig

### 3.1 计算路径（microbench）— 已完成基线


| 状态  | 项     | 验收                                                                                                                                       |
| --- | ----- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| ✅   | P0–P1 | loop/mem/struct/call；peephole ELF；while 折叠；call/struct 内联                                                                                |
| ✅   | P2    | `SHU_PERF_FAIL_ON_ZIG=1 ./tests/run-perf-baseline.sh --bench`（CI linux 已启用）                                                              |
| ✅   | P3    | `run-perf-compile-dogfood.sh` + `tests/baseline/compile-dogfood.tsv`（CI 已启用）                                                             |
| ✅   | P4    | Linux CI `SHU_PERF_FAIL_ON_ZIG=1` + io/net/compile dogfood 门禁（`.github/workflows/ci.yml`）；本地 median 填 `analysis/perf-vs-zig-baseline.md` |


### 3.2 I/O 吞吐（L1）— **下一性能主战场**


| 状态  | 项                                        | 验收                                                                                                             |
| --- | ---------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| ✅   | **I1**：`tests/bench/io_mmap_throughput`  | `.su/.c/.zig` + `run-perf-io.sh --bench`（16MiB mmap 扫描）                                                        |
| ✅   | **I2**：`tests/bench/io_write_throughput` | 16MiB write（4KiB×4096）；`.su/.c/.zig` + `run-perf-io.sh`                                                        |
| ✅   | **I3**：`tests/bench/io_batch_readv`      | 16MiB `read_batch_fd` 4×4KiB×1024 vs C/Zig readv                                                               |
| ✅   | I4                                       | `run-perf-io.sh` + `tests/baseline/io-perf.tsv`；`SHU_PERF_FAIL_ON_IO_REGRESSION=1` 可选门禁                        |
| ✅   | I5                                       | CI Linux：`SHU_PERF_FAIL_ON_IO_ZIG=1` + `**SHU_PERF_FAIL_ON_IO_REGRESSION=1`** `./tests/run-perf-io.sh --bench` |
| ✅   | I6                                       | fixed buffer read_batch→read_fixed；`SHU_IO_URING_RING_ENTRIES`（64..4096）；`run-perf-io-ring-ab.sh` A/B          |


依据：`std/fs/PERF-ASSESSMENT.md` §三（Linux 已接近内核上限，差 bench 与 async in-flight）。

### 3.3 网络并发（L0）


| 状态  | 项                                        | 验收                                                                                                     |
| --- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| ✅   | **N1**：`tests/bench/net_accept_many`     | 4096 conns + client/server C 驱动；Shu `accept_many` vs C accept 循环                                       |
| ✅   | **N2**：`tests/bench/net_echo_throughput` | 4×4KiB×1024 echo；Shu `stream_*_batch` vs C readv/writev                                                |
| ✅   | N3                                       | `run-perf-net.sh` + `net-perf.tsv`；**Linux CI** `SHU_PERF_FAIL_ON_NET_REGRESSION=1`；动态端口防 TIME_WAIT 回归 |
| ✅   | **N4**：`tests/bench/net_udp_many`        | 4096×64B `udp_recv_many_buf` vs C recvmmsg；并入 `run-perf-net.sh`                                        |


现有基础：`std/net` accept/connect_many（Linux io_uring）、`stream_*_batch`（`std/net/mod.su`）。

### 3.4 零拷贝（横切）


| 状态  | 项                                       | 验收                                                                                                                                                                                                                                   |
| --- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| ✅   | 写路径                                     | user ptr → 内核（无库内二次拷贝）                                                                                                                                                                                                               |
| ✅   | 读路径 API                                 | `read_ptr` / `fs_mmap_ro` / `fs_sendfile`                                                                                                                                                                                            |
| ✅   | **Z1**：`tests/bench/zero_copy_sendfile` | 16MiB `fs_sendfile`→socket vs C/Zig；并入 `run-perf-io.sh`（Linux/macOS）                                                                                                                                                                 |
| ✅   | Z2                                      | `read_ptr` 生命周期 + slice 互操作（`std/io/mod.su` 文件头 Z2 节）                                                                                                                                                                                |
| ✅   | **P1 asm std**                          | `-backend asm -o`：`zero_copy_sendfile` / `net_accept_many` / `net_echo_throughput` 全链绿；`run-perf-net.sh --bench` + `SHU_PERF_FAIL_ON_NET_REGRESSION=1` 通过；`stream_*_batch` 经 CALL redirect→`net.o`+`io.o`；CALL>6 实参栈传递（AAPCS64/SysV） |


### 3.5 asm 计算增量（长期，见 §五）


| 状态  | 项     | 验收                                                                                                                      |
| --- | ----- | ----------------------------------------------------------------------------------------------------------------------- |
| ✅   | 更多内联  | struct 按值返回：`get_a/add_pair(mk)` 嵌套 ✅；`let p = mk(...)` 直写 let 槽 ✅；while 体内 `let`+后续 stmt / if 嵌套 let（`run-struct.sh`）✅ |
| ✅   | SIMD  | asm let 向量 + `&vector`/`as *u8` + memcmp（`vec_add_verify`）；`run-vector.sh` 8 项 |
| ✅   | 7.3 / asm 计算门禁 | **8×** binop + vector-var + **call-inline 11 例**（含 vec div）；`run-asm-73-gate.sh` → **bstrict-ci**（CI） |


> P4+ 不阻塞自举/perf 门禁；有新 bench 绿后再迁入 §3.1。

---

## 四、固定验收命令

```bash
# ── asm 计算门禁（binop + vector-var + call-inline）──
SHU=./compiler/shu_asm ./tests/run-asm-73-gate.sh

# ── P0 push 前一键（bootstrap-ci + asm-73 + perf P1）──
SHU=./compiler/shu_asm ./tests/run-pre-push-p0.sh
# push 后（需 gh）：gh run list --limit 3 && gh run watch   # 看 linux / linux-arm64 绿

# ── 自举 ──
make -C compiler bootstrap-driver-bstrict
make -C compiler refresh-shu-asm-gate   # asm struct mk 门禁对齐（无需全量 bstrict）
./tests/run-shu-asm-gate.sh
./tests/run-all-bstrict.sh                    # 107 项（全量 run-all 白名单 @ shu_asm）
./tests/run-bootstrap-bstrict-ci.sh           # CI 同套：gate + 白名单 + crt0 + stage2
make -C compiler bootstrap-verify             # B-strict 主路径（shu_asm gen1/gen2）
make -C compiler bootstrap-verify-seed          # seed shu 语义自举（正交）
make -C compiler bootstrap-verify-stage2-bstrict

# ── 功能 ──
./tests/run-check.sh
./tests/run-check-compiler.sh
SHULANG_BSTRICT_RUN_ALL=1 SHU=./compiler/shu_asm ./tests/run-all.sh

# ── 性能：计算 ──
./tests/run-perf-baseline.sh --bench
SHU_PERF_FAIL_ON_ZIG=1 ./tests/run-perf-baseline.sh --bench

# ── 性能：编译器 dogfood ──
./tests/run-perf-compile-dogfood.sh
SHU_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh

# ── 性能：P1 门禁（对齐 Linux CI）──
./tests/run-perf-p1-gate.sh

# ── 性能：I/O / 网络（P1 门禁一键）──
SHU_PERF_FAIL_ON_IO_ZIG=1 SHU_PERF_FAIL_ON_IO_REGRESSION=1 ./tests/run-perf-io.sh --bench
SHU_PERF_FAIL_ON_NET_REGRESSION=1 ./tests/run-perf-net.sh --bench

# ── 性能：I/O / 网络（分项）──
./tests/run-perf-io.sh --bench
SHU_PERF_FAIL_ON_IO_ZIG=1 ./tests/run-perf-io.sh --bench
SHU_PERF_FAIL_ON_IO_REGRESSION=1 ./tests/run-perf-io.sh --bench
./tests/run-perf-io-ring-ab.sh

# ── 性能：网络（L0） ──
./tests/run-perf-net.sh --bench
SHU_PERF_FAIL_ON_NET_REGRESSION=1 ./tests/run-perf-net.sh --bench
```

---

## 五、归档（历史完成项）

自举 M2–M6、L5 白名单、asm 修复、std 按需、P0–P3 perf 等

- B-strict / skip_gen / strict 重链 / ast_pool_l5_bridge  
- while 折叠、`try_inline_x_plus_k_call_elf`、`try_inline_param0_field_sum_call_elf`、peephole_elf  
- fmt/check/comment 门禁；csv/boundary；run-enum + dual-chain 入 bstrict  
- seed `core.option`；CI perf + compile dogfood 严格门禁

完整勾选表见 git 历史或 `compiler/docs/SELFHOST.md`。



---

## 使用说明

- 新任务只挂在 **§1–§3** 对应主线；完成后 `⬜` → `✅`。  
- **性能项**须附 bench 数字；**自举项**须标明 B-strict / B-hybrid / seed。  
- 「超越 Zig」仅当 **L0–L2 对应 bench + CI 门禁** 绿时可写 ✅。  
- §五 仅查阅，不再追加。

