# BOOT-019 Stage2 扩面 dogfood v1

> 更新时间：2026-06-18  
> 状态：**硬绿 ✅（soft→硬绿）** · **honesty 2026-08-26**  
> 关联：`bootstrap-verify`、`check-7.2` / `check-7.2-bstrict`、BOOT-015 语义子集  
> **honesty 2026-08-24**：archived; gate default = `analysis/archive/.../`; live roadmap = `analysis/自举进度.md` (`NEXT.md` left).  
> **honesty 2026-08-26**：gate prefer asm + `XLANG_LINK_XLANG`; check observational; 6 smoke link+run hard-fail (no soft SKIP→OK); DOC `## 7. Gate`.

---

## 1. 目标

将 **parser / typeck 前端子集** 纳入 Stage2 自举 dogfood：产品 `xlang_asm` 对六条烟测 **link+run**（约定 exit）；`check` 仅观测（自举期暂停闸门）。

验收：`tests/run-boot-019-stage2-dogfood-gate.sh` 绿；`make bootstrap-verify-seed` / `check-7.2-bstrict` 调用子集 runner。

---

## 2. bootstrap-verify 子集

| 领域 | 烟测 | 预期 |
|------|------|------|
| **parser** | `tests/parser/semicolon_required.x` | 分号正例 link+run exit 0 |
| **parser** | `tests/parser/two_functions.x` | 多函数 parse/typeck link+run exit 0 |
| **parser** | `tests/parser/binary_expr_return.x` | 二元表达式返回 exit 3 |
| **typeck** | `tests/option/main.x` | `Option_i32` 组合子 exit 102 |
| **typeck** | `tests/result/main.x` | `Result_i32/u8` 组合子 exit 173 |
| **typeck** | `tests/generic/main.x` | `id<i32>` 泛型单态化 exit 42 |

Runner：`tests/run-bootstrap-stage2-dogfood-parser-typeck.sh`（`XLANG=` 指定代际；prefer asm）。  
全量回归：`tests/run-parser.sh`、`tests/run-typeck.sh`、`tests/run-option.sh`、`tests/run-result.sh`、`tests/run-generic.sh`。

---

## 3. Makefile 集成（历史；MG 后权威入口 = `./xbuild`）

| 路径 | 扩展 |
|------|------|
| `check-7.2` | seed 两代各跑 parser/typeck dogfood 子集 |
| `check-7.2-bstrict` | xlang_asm 两代各跑 parser/typeck dogfood 子集 |
| `run-bootstrap-xlang-gate.sh` | driver seed 链附加子集 |

链接失败时：link 为硬信号；`BOOT019_SKIP_LINK=1` 仅在 typeck-only 调用方启用；`BOOT019_REQUIRE_LINK=1` 在全链接 CI 启用。

---

## 4. Gate（历史入口）

见 **§7 Gate**（honesty 权威）。历史口令仍可用：

```bash
./tests/run-boot-019-stage2-dogfood-gate.sh
```

便携回归：`tests/run-portable-suite.sh`  
复现矩阵：`tests/baseline/bootstrap-repro.tsv` `boot019_stage2_dogfood`

---

## 5. 维护

parser/typeck 主路径烟测变更时同步更新 manifest `smoke_*` 行与 `run-parser.sh` / `run-typeck.sh` 等回归脚本。

---

## 6. 变更流程

新增／改烟测时须 **同 PR** 更新：

1. 对应 `tests/parser|option|result|generic/*.x`（或全量 `run-*.sh`）  
2. `tests/baseline/boot-019-stage2-dogfood.tsv`  
3. 本 DOC §2／§7  
4. 跑 `run-boot-019-stage2-dogfood-gate.sh` 全绿  

---

## 7. Gate

| 脚本 | 覆盖 |
|------|------|
| `tests/run-boot-019-stage2-dogfood-gate.sh` | manifest + honesty smoke（prefer asm） |
| `tests/baseline/boot-019-stage2-dogfood.tsv` | section／smoke／hook／cross_ref + `doc_gate` |
| 六条 parser／typeck 烟测 | link+run 约定 exit **hard**（须 6／6） |
| `tests/run-bootstrap-stage2-dogfood-parser-typeck.sh` | subset runner（check 观测；link 硬） |

**Honesty contract（2026-08-26）**

| 项 | 规则 |
|----|------|
| compiler | prefer `./compiler/xlang_asm` then `xlang-c`／`xlang`；pin `XLANG_LINK_XLANG` |
| check | **observational**（自举期暂停；CHK 红不挡门） |
| link+run | 六条烟测 build+run 约定 exit **hard-fail**（须 6／6） |
| no native | **FAIL**（exit 2）— 禁止 soft SKIP→OK |
| report | `check=`／`link=`／`skip=` |
| DOC | refuse top-level resurrect；live = `analysis/archive/boot/` |

```bash
./tests/run-boot-019-stage2-dogfood-gate.sh
```

矩阵：`tests/baseline/boot-019-stage2-dogfood.tsv`

报告示例：`xlang: [XLANG_BOOT019] status=ok check=0|1|…|6 link=6 skip=0`

**BOOT-019 状态：硬绿 ✅（soft→硬绿）**

---

## 8. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/boot-019-stage2-dogfood.tsv` |
| 门禁 | `tests/run-boot-019-stage2-dogfood-gate.sh` |
| helpers | `tests/lib/boot-019-stage2-dogfood.sh` |
| subset runner | `tests/run-bootstrap-stage2-dogfood-parser-typeck.sh` |
