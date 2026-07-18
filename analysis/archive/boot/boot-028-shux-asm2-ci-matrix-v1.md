# BOOT-028：parser C6 shux_asm2 CI 矩阵 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：BOOT-027 C5 跨平台烟测、`eng-crossplatform-ci-v1.md` ENG-003  
> 关联：`boot-027-shux-asm2-cross-v1.md`、CI `ci-platform-matrix.tsv`

---

## 1. 目标

在 BOOT-027 C5 基础上登记 **C6 shux_asm2 CI 矩阵**：Linux/macOS 双平台 manifest 策略 + native `shux_asm2` 烟测 + 父波次 C5 + ENG-003 CI 平台矩阵承前。

验收：`tests/run-boot-028-shux-asm2-ci-matrix-gate.sh` 绿；`min_c6_hooks=4`；宿主 `c6_matrix_ok=1`。

---

## 2. C6 CI 矩阵

### 2.1 波次 hook（`shux-asm2-ci-matrix-wave.tsv`）

| ID | hook | 说明 |
|----|------|------|
| `c6_smoke` | `run-shux-asm2-cross-smoke.sh` | 双平台 native `shux_asm2` return 42 |
| `c6_boot027` | `run-boot-027-shux-asm2-cross-gate.sh` | C5 父波次 manifest |
| `c6_cross` | `run-bootstrap-crossplatform-gate.sh` | BOOT-011 跨平台承前 |
| `c6_eng_ci` | `run-eng-crossplatform-ci-gate.sh` | ENG-003 CI 平台矩阵 |

### 2.2 平台策略（`shux-asm2-ci-platform-matrix.tsv`）

| case_id | linux | macos | 说明 |
|---------|-------|-------|------|
| `shux_asm2_cross_smoke` | must | must | `shux-asm2-cross-smoke OK\|SKIP` |
| `boot027_parent` | manifest | manifest | C5 父波次 manifest 绿 |

复现矩阵：`tests/baseline/bootstrap-repro.tsv` `boot028_shux_asm2_ci_matrix`。

---

## 3. Gate

```bash
./tests/run-boot-028-shux-asm2-ci-matrix-gate.sh
```

```
shux: [SHUX_BOOT028] status=ok c6_matrix_ok=1 c6_smoke=1 skip=0
```

- **c6_matrix_ok**：当前宿主平台矩阵 must/manifest 行全部通过（烟测允许 `SKIP`）
- **c6_smoke**：`run-shux-asm2-cross-smoke.sh` 已执行且输出匹配 `OK|SKIP`
- Darwin / 无 native `shux_asm2`：manifest 绿 + 烟测 **SKIP**（macos `must` 匹配 `SKIP` 模式）

---

## 4. 联动

- manifest：`tests/baseline/boot-028-shux-asm2-ci-matrix.tsv`
- 波次表：`tests/baseline/shux-asm2-ci-matrix-wave.tsv`
- 平台矩阵：`tests/baseline/shux-asm2-ci-platform-matrix.tsv`
- 父波次：`run-boot-027-shux-asm2-cross-gate.sh`
- 矩阵：`comp-parser-mega7-matrix.tsv`（C7 `shux_asm2_ci_target`）
- CI：`tests/run-portable-suite.sh`、`ci-platform-matrix.tsv`（linux + mac job）

---

## 5. 非目标（v2）

- Windows native `shux_asm2` 硬门禁
- GHA 上自动构建并缓存 `shux_asm2` 制品
- nightly 每次 FULL Stage2 重跑
