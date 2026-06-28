# 阶段 F-std-zero-c v1（std 标准库零 C/H 终局）

> **终局目标**：`std/` 下 **零手写 `.c` / `.h`**（**82 → 0**；当前 **47 `.c` + 11 `.h`**）。  
> **与 F §9.2 关系**：F-01～F-12 为流程与门禁；**F-std-zero-c** 为 std 清场总路线图。  
> **验收**：`SHUX_F_STD_ZERO_C_STRICT=1 ./tests/run-f-std-zero-c-track-gate.sh`（终局硬绿 = std 无 C/H）。

## 1. 能否全部去掉？

**能。** 这是阶段 F 的必达终局，与项目「完全自举 = D+E+F」一致。

| 形态 | 现状 | 终局 |
|------|------|------|
| 业务逻辑 `.c` | http inc、scheduler glue 等 | 全量 `.sx` |
| OS 胶层 `.c` | pthread/TLS/dlopen 等 | `.sx` 内 `asm {}` / `extern` + 极薄平台桩（或 `.s`，**不在 std/**） |
| ABI `.h` | fs/path/map/error_abi.h | **F-ZC Z9 ✅**：`compiler/include/shux_std_abi/` canonical + runtime preamble 内联 |
| crypto ref10 `.c/.h` | ed25519 7×`.c` + 6×`.h` | 保留算法纯 `.sx` 或 vendored 经 shux 编译的**单一**汇编对象（仍不保留 std 源 `.c`） |

**不能一夜删光**：当前 **~623KB** 手写 C 集中在 http（30 文件）、async scheduler、channel、ed25519。

## 2. 存量快照（2026-06）

| 类别 | 文件数 | 约字节 | 批次 |
|------|--------|--------|------|
| **http/** | 30 | ~420K | **Z1** |
| **async/** | 2 | ~34K | **Z2** |
| **channel + thread + process** | 5 | ~57K | **Z3** |
| **sync + atomic** | 4 | ~22K | **Z4** |
| **net/** | 3 | ~10K | **Z5** |
| **db/** | 3 | ~18K | **Z6** |
| **crypto/ed25519** | 7+2 glue | ~95K | **Z7** |
| **OS 小胶层** | ~21 | ~50K | **Z8** |
| **.h（abi + compress + ed25519）** | 12 | ~109K | **Z9** |

**v2 已闭合（纯 .sx 或逻辑下沉）**：cache / config / context / datetime / dynlib / elf / ffi / hash / json / queue / regex / schema / security / **simd（F-ZC）** / socketio / sync-lock-diag / tar / task / test / trace / unicode / async-future / backtrace / url 等 **21** 项。

## 3. 推荐推进顺序

1. **Z8 小胶层批量**（env/log/time/random/simd…）— 模式已验证：逻辑 `.sx` + `*_os_glue.c` → 再 os 桩 `.s`/syscall  
2. **Z2 async-scheduler** + **Z3 channel** — 解锁 task/net 测试面  
3. **Z1 http 分阶段** — 按 inc 依赖逆序：`test_tls_cert` → … → `server.inc.c`（85K 最大）→ `http_glue.c`  
4. **Z7 ed25519** — F-04 v20 可选项；或保留最小 ref10 单对象后删源  
5. **Z9 abi.h** — 依赖编译器 **不再对用户链出 C 后端**（阶段 E 收尾）  
6. **Z6 db** — sqlite/arrow SIMD 最后（外部库/SIMD intrinsics）

## 4. 每文件迁移 checklist

- [ ] 逻辑 → `.sx`（或已有 mod.sx 扩展）  
- [ ] OS 边界 → 最小胶层 / `std.sys` syscall  
- [ ] `compiler/Makefile`：`ld -r` 或纯 `.sx` 规则  
- [ ] `runtime.c` / `boot-std-link-contract.tsv` 按需链更新  
- [ ] v2 gate + closure tsv；v1 gate `absent` 旧 glue  
- [ ] `f-std-zero-c-track.tsv` 删行；`no-handwritten-c-whitelist` 刷新  
- [ ] `SHUX_F_STD_ZERO_C_STRICT=1` 仍红直到 total=0（预期）

## 5. 门禁

```bash
# 跟踪（默认：禁止新增未登记 std C/H）
./tests/run-f-std-zero-c-track-gate.sh

# 终局硬绿（当前必 FAIL，std>0 时）
SHUX_F_STD_ZERO_C_STRICT=1 ./tests/run-f-std-zero-c-track-gate.sh

# 迁移后刷新清单
SHUX_F_STD_ZERO_C_UPDATE=1 ./tests/run-f-std-zero-c-track-gate.sh

# 聚合
SHUX_F_STD_ZERO_C_FAIL=1 ./tests/run-f-std-zero-c-track-gate.sh
SHUX_F_PHASE_F_92_FAIL=1 ./tests/run-f-phase-f-92-batch-gate.sh
SHUX_F_STD_DE_C_BATCH_FAIL=1 ./tests/run-f-std-de-c-batch-gate.sh
```

## 6. 首项清场（v1）

| 项 | 说明 |
|----|------|
| `compress_common.h` | → **`std/compress/common.sx`**（已删 .h） |
