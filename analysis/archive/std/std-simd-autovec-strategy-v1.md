# STD-153：std.simd 自动向量化策略 v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）+ honesty**  
> 关联：STD-047 shuffle/select、STD-061 prod bench  
> PLATFORM: SHARED — Ubuntu gold for link/run; Darwin L2 same env rules

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | 打开 `tests/baseline/std-simd-autovec-strategy-manifest.tsv` |
| 3 | `./tests/run-std-simd-autovec-strategy-gate.sh` |
| 4 | 金样：`tests/std-simd/autovec_strategy.x` |

---

## 2. 策略表

产品 export 名是 **`recommend_path`**（mangle `std_simd_recommend_path`）。
**没有** `recommend_simd_path` 第二套 export（G.7：一功能一权威）。

| 场景 | API | 行为 |
|------|-----|------|
| 探测 HW | `hw_available()` | v1 在产品宿主（arm64 / x86_64 / riscv64）返回 1 |
| 默认推荐 | `recommend_path()` | auto：有 HW → `SIMD_PATH_HW`（1），否则标量 |
| 强制标量 | `XLANG_SIMD_HW=0` 或 `XLANG_SIMD_AUTovec=scalar`／`0` | 始终 `SIMD_PATH_SCALAR`（0） |
| 强制 HW | `XLANG_SIMD_AUTovec=hw`／`1` | 有 HW 则 HW，否则标量 |

常量：`SIMD_PATH_SCALAR`（0）、`SIMD_PATH_HW`（1）。

编译器 emit 仍由 `XLANG_SIMD_HW` / 内联 pass 控制；本模块提供**运行时策略查询**与 gate 验收锚点。

---

## 3. 跨平台性能验收

gate 在具备 native `xlang_asm` 时运行：

| Bench | 脚本 | 默认阈值 |
|-------|------|----------|
| Vec4f dot | `run-perf-simd-dot.sh` | Xlang ≥ 0.90× C `-O2 -msse2` |
| shuffle/select | `run-perf-simd-shuffle-select.sh` | stub/Xlang ≥ 1.0 |

平台向量见 `tests/baseline/std-simd-autovec-strategy.tsv`（可按 OS-ARCH 覆盖 `min_dot_ratio` / `min_ss_ratio`）。  
Perf soft residual：低于阈值／不可跑 → `perf=0` 观测，不硬红闸门。

---

## 4. Gate

```bash
./tests/run-std-simd-autovec-strategy-gate.sh
```

```
xlang: [XLANG_STD153_SIMD_AUTovec] status=ok check=0|1 c=0|1 x=1 perf=0|1 skip=0 host=…
```

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`
- `xlang check` 观测（自举期暂停闸门 2026-08-05）
- C smoke 观测（host-cc `simd.o` 可缺）
- `tests/std-simd/autovec_strategy.x` exit 0 硬失败（无 soft SKIP）
- Perf soft SKIP（ratio soft residual）

回归：保留 `run-std-simd-shuffle-select-gate.sh`、`run-std-simd-prod-gate.sh`。

---

## 5. Evolution

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | 初版策略表 + 跨平台 perf |
| honesty | 2026-08-26 | soft→硬绿：`## 4. Gate`；DOC 对齐 `recommend_path`；prefer asm；check 观测；x hard；C／perf soft；报告 `check=`／`c=`／`x=`／`perf=`／`skip=`；section 锚单权威 archive DOC |

---

## 6. 非目标（v1）

- 编译器 loop 自动向量化 pass 本身
- 第二套 `recommend_simd_path` export（会改 mangle，打坏 g18 针）
- SVE/AVX-512 动态分派表
- Windows MSYS perf 硬失败（向量表标记 skip）
