# BOOT-019 Stage2 扩面 dogfood v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`bootstrap-verify`、`check-7.2` / `check-7.2-bstrict`、BOOT-015 语义子集

---

## 1. 目标

将 **parser / typeck 前端子集** 纳入 Stage2 自举 dogfood：两代编译器（seed `shu_stage1/2` 或 B-strict `shux_asm_stage1/2`）均须对六条烟测 `check` 通过；链接可用时额外 `link+run`。

验收：`tests/run-boot-019-stage2-dogfood-gate.sh` 绿；`make bootstrap-verify-seed` / `check-7.2-bstrict` 调用子集 runner。

---

## 2. bootstrap-verify 子集

| 领域 | 烟测 | 预期 |
|------|------|------|
| **parser** | `tests/parser/semicolon_required.x` | 分号正例 typeck OK |
| **parser** | `tests/parser/two_functions.x` | 多函数 parse/typeck |
| **parser** | `tests/parser/binary_expr_return.x` | 二元表达式返回 |
| **typeck** | `tests/option/main.x` | `Option_i32` 组合子 |
| **typeck** | `tests/result/main.x` | `Result_i32/u8` 组合子 |
| **typeck** | `tests/generic/main.x` | `id<i32>` 泛型单态化 |

Runner：`tests/run-bootstrap-stage2-dogfood-parser-typeck.sh`（`SHUX=` 指定代际）。  
全量回归：`tests/run-parser.sh`、`tests/run-typeck.sh`、`tests/run-option.sh`、`tests/run-result.sh`、`tests/run-generic.sh`。

---

## 3. Makefile 集成

| 路径 | 扩展 |
|------|------|
| `check-7.2` | seed 两代各跑 parser/typeck dogfood 子集 |
| `check-7.2-bstrict` | shux_asm 两代各跑 parser/typeck dogfood 子集 |
| `run-bootstrap-shux-gate.sh` | driver seed 链附加子集 |

链接失败（如缺 `libzstd`）时：**check 仍须绿**；`BOOT019_REQUIRE_LINK=1` 仅在全链接 CI 启用。

---

## 4. Gate 与 report

- manifest：`tests/baseline/boot-019-stage2-dogfood.tsv`
- 门禁：`tests/run-boot-019-stage2-dogfood-gate.sh`
- 便携回归：`tests/run-portable-suite.sh`
- 复现矩阵：`tests/baseline/bootstrap-repro.tsv` `boot019_stage2_dogfood`

```
shux: [SHUX_BOOT019] status=ok check_ok=6 link_ok=N skip=M
```

---

## 5. 维护

parser/typeck 主路径烟测变更时同步更新 manifest `smoke_*` 行与 `run-parser.sh` / `run-typeck.sh` 等回归脚本。
