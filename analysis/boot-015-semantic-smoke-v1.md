# BOOT-015 语义自举 smoke 扩展 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`bootstrap-verify`、`check-7.2` / `check-7.2-bstrict`、BOOT-014 链接契约

---

## 1. 目标

将 **std.vec / std.map / std.heap** 纳入语义自举烟测子集：两代编译器（seed `shu_stage1/2` 或 B-strict `shux_asm_stage1/2`）均须对三模块 `check` 通过；链接可用时额外 `link+run`。

验收：`tests/run-boot-015-semantic-smoke-gate.sh` 绿；`make bootstrap-verify-seed` / `check-7.2-bstrict` 调用子集 runner。

---

## 2. bootstrap-verify 子集

| 模块 | 烟测 | 预期 |
|------|------|------|
| `std.vec` | `tests/vec/main.sx` | `vec_len_empty` + `vec_placeholder` → exit 0 |
| `std.map` | `tests/map/main.sx` | `map_empty_size` → exit 0 |
| `std.heap` | `tests/heap/main.sx` | `alloc_size_zero` → exit 0 |

Runner：`tests/run-bootstrap-semantic-smoke-vec-map-heap.sh`（`SHUX=` 指定代际）。  
全量回归：`tests/run-vec.sh`、`tests/run-map.sh`、`tests/run-heap.sh`。

---

## 3. Makefile 集成

| 路径 | 扩展 |
|------|------|
| `check-7.2` | seed 两代各跑 vec/map/heap 子集 |
| `check-7.2-bstrict` | shux_asm 两代各跑 vec/map/heap 子集 |
| `run-bootstrap-shux-gate.sh` | driver seed 链附加子集 |

链接失败（如缺 `libzstd`）时：**check 仍须绿**；`BOOT015_REQUIRE_LINK=1` 仅在全链接 CI 启用。

---

## 4. Gate 与 report

- manifest：`tests/baseline/boot-015-semantic-smoke.tsv`
- 门禁：`tests/run-boot-015-semantic-smoke-gate.sh`
- 便携回归：`tests/run-portable-suite.sh`

```
shux: [SHUX_BOOT015] status=ok check_ok=3 link_ok=N skip=M
```

---

## 5. 维护

vec/map/heap 主路径烟测变更时同步更新 manifest `smoke_*` 行与 `tests/run-vec.sh` 等回归脚本。
