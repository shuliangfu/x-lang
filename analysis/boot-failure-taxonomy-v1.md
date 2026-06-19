# BOOT-005 自举失败分类清单 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`BOOT-004`（stage-diag）、`BOOT-003`（repro）、`bootstrap-stage-patterns.tsv`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **历史失败类型清单** | 固定 taxonomy TSV，覆盖 CI/本地常见自举失败 |
| **95% 模式覆盖** | 每类型至少 1 条 `bootstrap-stage-patterns` 规则 + repro case |
| **与诊断衔接** | `run-bootstrap-stage-diag.sh` 输出 → taxonomy → `run-bootstrap-repro.sh` |
| **可扩展** | 新失败类型须增 taxonomy 行 + pattern + fixture |

验收（NEXT BOOT-005）：**至少覆盖 95% 历史失败类型** + 文档 + manifest gate。

---

## 2. 分类维度

| 维度 | 说明 |
|------|------|
| **stage** | 与 BOOT-004 一致（lexer/parser/typeck/…） |
| **category** | 更细粒度 ID（如 `parser_emit`、`link_symbol`） |
| **pattern_ids** | 逗号分隔，须存在于 `bootstrap-stage-patterns.tsv` |
| **repro_case** | BOOT-003 `bootstrap-repro.tsv` case_id |
| **fixture_id** | 可选；对应 `bootstrap-stage-diag-fixtures.tsv` |

---

## 3. 历史失败类型（v1 摘要）

| 域 | 类型数 | 代表 |
|----|--------|------|
| parser | 6 | second_pass、symbol、mega、parse_count、syntax |
| typeck/codegen | 2 | typeck error、emit fail |
| asm/link | 3 | asm-73、undefined symbol |
| build | 4 | B-strict 拓扑、strict smoke、make 失败 |
| selfhost/wpo | 4 | stage2、verify、WPO strict |
| 其它 | 5 | preprocess、lexer、import、run、shux_asm gate |

**v1 共 23 项**；门禁要求 pattern+repro 覆盖 ≥ **95%**（当前 100%）。

---

## 4. 用法

```bash
# 1) 诊断 log → stage + repro
./tests/run-bootstrap-stage-diag.sh ci.log

# 2) 查 taxonomy（按 stage 过滤）
awk -F'\t' '$4=="parser" && $1 !~ /^#/' tests/baseline/bootstrap-failure-taxonomy.tsv

# 3) 跑最小复现
./tests/run-bootstrap-repro.sh "$SHUX_BOOT_REPRO"

# 4) manifest 门禁
./tests/run-bootstrap-failure-taxonomy-gate.sh
```

---

## 5. 门禁

`tests/run-bootstrap-failure-taxonomy-gate.sh`：

1. manifest：RFC + taxonomy + patterns + repro + fixtures  
2. 每行 `pattern_ids` 须在 patterns 表存在  
3. 每行 `repro_case` 须在 repro 矩阵存在  
4. 覆盖率 ≥ `min_coverage_pct`（默认 95）  
5. hook：`run-bootstrap-stage-diag-gate.sh`  

---

## 6. 变更流程

1. 新 CI 失败模式 → taxonomy 行 + pattern + 可选 fixture  
2. 删 pattern → 同步删 taxonomy 引用  
3. `./tests/run-bootstrap-failure-taxonomy-gate.sh` 须绿  

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| 分类清单 | `tests/baseline/bootstrap-failure-taxonomy.tsv` |
| 门禁 | `tests/run-bootstrap-failure-taxonomy-gate.sh` |
| 模式表 | `tests/baseline/bootstrap-stage-patterns.tsv` |
| 阶段诊断 | `analysis/boot-stage-diag-v1.md` |

**BOOT-005 状态：定版 ✅**
