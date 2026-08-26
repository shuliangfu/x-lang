# BOOT-015 语义自举 smoke 扩展 v1

> 更新时间：2026-06-18  
> 状态：**硬绿 ✅（soft→硬绿）** · **honesty 2026-08-26**  
> 关联：`bootstrap-verify`、`check-7.2` / `check-7.2-bstrict`、BOOT-014 链接契约  
> **honesty 2026-08-24**：archived; gate default = `analysis/archive/.../`; live roadmap = `analysis/自举进度.md` (`NEXT.md` left).  
> **honesty 2026-08-26**：gate prefer asm + `XLANG_LINK_XLANG`; check observational; vec/map/heap link+run hard-fail (no soft SKIP→OK); DOC `## 7. Gate`.

---

## 1. 目标

将 **std.vec / std.map / std.heap** 纳入语义自举烟测子集：产品 `xlang_asm` 对三模块 **link+run exit0**；`check` 仅观测（自举期暂停闸门）。

验收：`tests/run-boot-015-semantic-smoke-gate.sh` 绿；`make bootstrap-verify-seed` / `check-7.2-bstrict` 调用子集 runner。

---

## 2. bootstrap-verify 子集

| 模块 | 烟测 | 预期 |
|------|------|------|
| `std.vec` | `tests/vec/main.x` | `vec_len_empty` + `vec_placeholder` → exit 0 |
| `std.map` | `tests/map/main.x` | `map_empty_size` → exit 0 |
| `std.heap` | `tests/heap/main.x` | `alloc_size_zero` → exit 0 |

Runner：`tests/run-bootstrap-semantic-smoke-vec-map-heap.sh`（`XLANG=` 指定代际；prefer asm）。  
全量回归：`tests/run-vec.sh`、`tests/run-map.sh`、`tests/run-heap.sh`。

---

## 3. Makefile 集成（历史；MG 后权威入口 = `./xbuild`）

| 路径 | 扩展 |
|------|------|
| `check-7.2` | seed 两代各跑 vec/map/heap 子集 |
| `check-7.2-bstrict` | xlang_asm 两代各跑 vec/map/heap 子集 |
| `run-bootstrap-xlang-gate.sh` | driver seed 链附加子集 |

链接失败（如缺 `libzstd`）时：link 为硬信号；`BOOT015_SKIP_LINK=1` 仅在 typeck-only 调用方启用；`BOOT015_REQUIRE_LINK=1` 在全链接 CI 启用。

---

## 4. Gate（历史入口）

见 **§7 Gate**（honesty 权威）。历史口令仍可用：

```bash
./tests/run-boot-015-semantic-smoke-gate.sh
```

便携回归：`tests/run-portable-suite.sh`

---

## 5. 维护

vec/map/heap 主路径烟测变更时同步更新 manifest `smoke_*` 行与 `tests/run-vec.sh` 等回归脚本。

---

## 6. 变更流程

新增／改烟测时须 **同 PR** 更新：

1. `tests/{vec,map,heap}/main.x`（或全量 `run-*.sh`）  
2. `tests/baseline/boot-015-semantic-smoke.tsv`  
3. 本 DOC §2／§7  
4. 跑 `run-boot-015-semantic-smoke-gate.sh` 全绿  

---

## 7. Gate

| 脚本 | 覆盖 |
|------|------|
| `tests/run-boot-015-semantic-smoke-gate.sh` | manifest + honesty smoke（prefer asm） |
| `tests/baseline/boot-015-semantic-smoke.tsv` | section／smoke／hook／cross_ref + `doc_gate` |
| `tests/vec/main.x` · `tests/map/main.x` · `tests/heap/main.x` | link+run exit0 **hard** |
| `tests/run-bootstrap-semantic-smoke-vec-map-heap.sh` | subset runner（check 观测；link 硬） |

**Honesty contract（2026-08-26）**

| 项 | 规则 |
|----|------|
| compiler | prefer `./compiler/xlang_asm` then `xlang-c`／`xlang`；pin `XLANG_LINK_XLANG` |
| check | **observational**（自举期暂停；CHK 红不挡门） |
| link+run | vec／map／heap build+run exit0 **hard-fail**（须 3／3） |
| no native | **FAIL**（exit 2）— 禁止 soft SKIP→OK |
| report | `check=`／`link=`／`skip=` |
| DOC | refuse top-level resurrect；live = `analysis/archive/boot/` |

```bash
./tests/run-boot-015-semantic-smoke-gate.sh
```

矩阵：`tests/baseline/boot-015-semantic-smoke.tsv`

报告示例：`xlang: [XLANG_BOOT015] status=ok check=0|1|2|3 link=3 skip=0`

**BOOT-015 状态：硬绿 ✅（soft→硬绿）**

---

## 8. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/boot-015-semantic-smoke.tsv` |
| 门禁 | `tests/run-boot-015-semantic-smoke-gate.sh` |
| helpers | `tests/lib/boot-015-semantic-smoke.sh` |
| subset runner | `tests/run-bootstrap-semantic-smoke-vec-map-heap.sh` |
