# Shulang 下一步开发清单

> **北极星**：**自举**（B-strict 替代 seed）→ **完善功能**（语言/工具链/std 对标 Zig 可用性）→ **性能超越 Zig**（计算 + I/O + 网络 + 零拷贝，均有 bench 与 CI 门禁）。  
> 背景：`compiler/docs/SELFHOST.md`、`analysis/perf-vs-zig-baseline.md`、`std/fs/PERF-ASSESSMENT.md`、`std/README.md`。

---

## 零、综合诊断（2026-05）

### 0.1 三条主线现状

| 主线 | 已达成 | 真实缺口 | 相对 Zig |
|------|--------|----------|----------|
| **自举** | B-strict 链通；`shu_asm` gate + **52 项** bstrict 白名单；Stage2 B-strict；CI `run-bootstrap-bstrict-ci.sh` | 默认产物仍是 **seed `shu`**；大模块 **skip_heavy 桩**；全量 `run-all` 非白名单仍走 `shu-c`；macOS 生产链仍 **B-hybrid**（`-E pipeline_gen.c`） | Zig 已自举；我们 **M6 完成、M7 未开始** |
| **功能** | `check/fmt/test`、52 项 L5 白名单、按需 std（io/fs/net/thread…） | `run-io`/`run-http` 未进 bstrict；`std.async`/`std.simd` 占位；process spawn 未做；多数 std 仅 smoke 测 | API 面接近，**生态与测试深度**落后 |
| **性能（计算）** | P0–P3：四 microbench ≤ C -O2；CI `SHU_PERF_FAIL_ON_ZIG` + compile dogfood | Linux CI 有 zig 时方可真正 **≤ Zig**；归纳变量/内联仍偏窄 | **微基准同级**；未证明全面超越 |
| **性能（I/O/网络）** | Linux **io_uring** + 批 readv/writev；mmap/sendfile/copy_file_range；net accept/connect **批量** | **无 IO/网络 perf bench**；无 Zig 对照门禁；macOS 无 uring 级后端；同步 submit 模型 | **能力上 std 内建 uring**（Zig 需 libxev），但 **缺度量，不能宣称超越** |
| **性能（零拷贝）** | 写路径直传 ptr；`read_ptr`；fs mmap/sendfile | 读零拷贝生命周期文档化不足；**无吞吐 bench** | 设计对齐，**未量化** |

### 0.2 性能超越 Zig：分层目标

```
┌─────────────────────────────────────────────────────────────┐
│  L4  生态默认：release shu = shu_asm，用户无感 B-strict       │
├─────────────────────────────────────────────────────────────┤
│  L3  编译器：compile dogfood 中位数不升（P3 ✅）               │
├─────────────────────────────────────────────────────────────┤
│  L2  计算：asm microbench ≤ Zig -O2（P2 ✅，待 Linux CI 实锤）│
├─────────────────────────────────────────────────────────────┤
│  L1  I/O：mmap/read_batch/sendfile 吞吐 ≥ Zig std+uring 同级  │  ← 当前空白
├─────────────────────────────────────────────────────────────┤
│  L0  网络：accept_many/connect_many 并发 ≥ Zig+libxev 同级   │  ← 当前空白
└─────────────────────────────────────────────────────────────┘
```

**纪律**（不变）：

1. 自举阻塞项优先于 perf 微优化。  
2. 改 **用户默认 `-backend asm -o`** 须对应 bench 用例。  
3. 宣称「超越 Zig」的每一层须 **脚本 + 基线文件 + CI 可选 fail**（与 P2/P3 同模式）。

### 0.3 推荐排序（接下来 3 个季度）

| 优先级 | 方向 | 理由 |
|--------|------|------|
| **P0** | 自举 M7–M8：默认 `shu_asm`、缩小 skip_heavy | 不完成则 perf/io 优化无法 dogfood 到编译器自身 |
| **P1** | IO/网络 bench + Zig 门禁（L1/L0） | std 能力已具备，缺度量则无法证「超越」 |
| **P2** | 功能：bstrict 纳入 run-io、http 测试；async 最小运行时 | 与 Zig 用户态并发叙事对齐 |
| **P3** | asm 计算继续：SIMD 内联、更多 call 模式 | 在 L2 已绿前提下增量 |

---

## 一、主线 1：自举（M6 完成 → M9）

### 1.1 已达里程碑（摘要）

| 代号 | 验收 |
|------|------|
| M2–M5 | B-strict 链通；gate；Linux crt0；Stage2 `shu_asm→shu_asm2` |
| M6 | `run-all-bstrict.sh` **52/52**；CI bstrict-ci + stage2 预检 |

详见 `compiler/docs/SELFHOST.md` §4；白名单矩阵见 `tests/docs/run-all-l5-whitelist.md`。

### 1.2 下一步

| 状态 | 项 | 验收 |
|------|----|------|
| ⬜ | **M7**：release 默认 B-strict | 文档/CI/本地默认 `compiler/shu` 由 `bootstrap-driver-bstrict` 产出；seed 仅 bootstrap 冷启动 |
| ⬜ | **M8**：消除 skip_heavy 桩 | `backend.o`/`typeck.o`/`parser.o` 第二遍 __text 覆盖真实 emit；`check-asm-o-quality` 24/24 且 strict 链无 ret0 桩 |
| ⬜ | **M9**：语义自举迁 B-strict | `bootstrap-verify` / stage2 **主路径**走 `shu_asm`，`-su -E` 全模块仍 `shu-su`（与 SELFHOST 正交） |
| ⬜ | M10：全量 run-all @ shu_asm | `SHULANG_BSTRICT_RUN_ALL=1` 白名单扩至 run-io/run-http；非白名单显式 SKIP 清单收敛 |
| ⬜ | M11：macOS 生产 B-strict | `full_asm` 为默认拓扑，链接审计无 `cc -c pipeline_gen.c`（现仅 Linux crt0 / 实验链可达） |

### 1.3 已知风险（须跟踪）

- `shu_asm -o` 偶发 SIGSEGV → `SHU_SKIP_PARSE_SMOKE=1`、import 重试（M3-b 文档）。  
- 改 `backend.su` 后须 `./scripts/build_seed_asm_host.sh` + `make relink-shu`（seed 路径）。  
- `check` 后 `driver_dep_seeded_clear_all` 清 dep/typeck 槽。

---

## 二、主线 2：完善功能

### 2.1 已达（摘要）

- 工具链：`shu check/fmt/test` 纳入 gate；注释/fmt 折行门禁。  
- L5：`run-all` 白名单 **52 项** @ seed/shu_asm（见矩阵文档）。  
- std：io/fs/net/thread/time/json/csv… 已完善（`std/README.md` §一）。

### 2.2 下一步

| 状态 | 项 | 验收 |
|------|----|------|
| ⬜ | **F1**：bstrict + run-io | `run-io.sh` 进 bstrict；`shu_asm` 编 import std.io 全绿（除已知 read_ptr 边界） |
| ⬜ | F2：http/tar 回归 | `tests/run-http.sh`、`run-tar.sh` + run-all |
| ⬜ | F3：process spawn | `std.process` spawn/exec/管道（README P3 规划） |
| ⬜ | F4：`std.async` 最小集 | submit/wait 分离，对接现有 io_uring completion（非占位） |
| ⬜ | F5：std 边界测试 | 每已完善模块：round-trip + 空输入/溢出（`std/README.md` §4.4） |
| ⬜ | F6：全量 run-all 收敛 | 将仍走 `shu-c` 的脚本逐类迁入白名单或明确永久 C-only |

---

## 三、主线 3：性能超越 Zig

### 3.1 计算路径（microbench）— 已完成基线

| 状态 | 项 | 验收 |
|------|----|------|
| ✅ | P0–P1 | loop/mem/struct/call；peephole ELF；while 折叠；call/struct 内联 |
| ✅ | P2 | `SHU_PERF_FAIL_ON_ZIG=1 ./tests/run-perf-baseline.sh --bench`（CI linux 已启用） |
| ✅ | P3 | `run-perf-compile-dogfood.sh` + `tests/baseline/compile-dogfood.tsv`（CI 已启用） |
| ⬜ | P4 | Linux CI 稳定出现 Zig 列且全绿；记录 median 入 `analysis/perf-vs-zig-baseline.md` |

### 3.2 I/O 吞吐（L1）— **下一性能主战场**

| 状态 | 项 | 验收 |
|------|----|------|
| ⬜ | **I1**：`tests/bench/io_mmap_throughput` | 大文件 mmap 顺序读；Shu vs C -O2 vs Zig -O2 |
| ⬜ | **I2**：`tests/bench/io_write_throughput` | 大缓冲 write/sendfile；对比 Zig `std.fs` + `std.Io` |
| ⬜ | **I3**：`tests/bench/io_batch_readv` | `read_batch_fd` 4 段打满 vs Zig readv |
| ⬜ | I4 | `run-perf-io.sh --bench` + `tests/baseline/io-perf.tsv` |
| ⬜ | I5 | CI：`SHU_PERF_FAIL_ON_IO_ZIG=1`（Linux only） |
| ⬜ | I6 | fixed buffer 池默认启用路径；ring 512→2K A/B |

依据：`std/fs/PERF-ASSESSMENT.md` §三（Linux 已接近内核上限，差 bench 与 async in-flight）。

### 3.3 网络并发（L0）

| 状态 | 项 | 验收 |
|------|----|------|
| ⬜ | **N1**：`tests/bench/net_accept_many` | N worker × accept_many；对比 Zig + libxev / 裸 epoll |
| ⬜ | **N2**：`tests/bench/net_echo_throughput` | TcpStream batch read/write vs Zig |
| ⬜ | N3 | `run-perf-net.sh` + CI 可选门禁 |
| ⬜ | N4 | UDP recv_many/send_many buf 路径 bench |

现有基础：`std/net` accept/connect_many（Linux io_uring）、`stream_*_batch`（`std/net/mod.su`）。

### 3.4 零拷贝（横切）

| 状态 | 项 | 验收 |
|------|----|------|
| ✅ | 写路径 | user ptr → 内核（无库内二次拷贝） |
| ✅ | 读路径 API | `read_ptr` / `fs_mmap_ro` / `fs_sendfile` |
| ⬜ | Z1 | `tests/bench/zero_copy_sendfile`：文件→socket 吞吐 vs Zig |
| ⬜ | Z2 | 文档：`read_ptr` 生命周期 + 与 slice 互操作（`std/io/mod.su`） |

### 3.5 asm 计算增量（P4+）

| 状态 | 项 | 验收 |
|------|----|------|
| ⬜ | 更多内联 | 单字段 return、小 struct 按值返回 |
| ⬜ | SIMD | `std.simd` + backend vector emit（依赖语言） |
| ⬜ | 寄存器分配 | 活跃分析减少 push/pop（README 7.3 后续） |

---

## 四、固定验收命令

```bash
# ── 自举 ──
make -C compiler bootstrap-driver-bstrict
./tests/run-shu-asm-gate.sh
./tests/run-all-bstrict.sh                    # 52 项
./tests/run-bootstrap-bstrict-ci.sh           # CI 同套：gate + 白名单 + crt0 + stage2
make -C compiler bootstrap-verify-stage2-bstrict
make -C compiler bootstrap-verify             # 语义自举（shu-su 链，与 B-strict 正交）

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

# ── 性能：I/O / 网络（待 I4/N3 脚本落地后启用） ──
# ./tests/run-perf-io.sh --bench
# ./tests/run-perf-net.sh --bench
```

---

## 五、归档（历史完成项）

<details>
<summary>自举 M2–M6、L5 白名单、asm 修复、std 按需、P0–P3 perf 等</summary>

- B-strict / skip_gen / strict 重链 / ast_pool_l5_bridge  
- while 折叠、`try_inline_x_plus_k_call_elf`、`try_inline_param0_field_sum_call_elf`、peephole_elf  
- fmt/check/comment 门禁；csv/boundary；run-enum + dual-chain 入 bstrict  
- seed `core.option`；CI perf + compile dogfood 严格门禁  

完整勾选表见 git 历史或 `compiler/docs/SELFHOST.md`。

</details>

---

## 使用说明

- 新任务只挂在 **§1–§3** 对应主线；完成后 `⬜` → `✅`。  
- **性能项**须附 bench 数字；**自举项**须标明 B-strict / B-hybrid / seed。  
- 「超越 Zig」仅当 **L0–L2 对应 bench + CI 门禁** 绿时可写 ✅。  
- §五 仅查阅，不再追加。
