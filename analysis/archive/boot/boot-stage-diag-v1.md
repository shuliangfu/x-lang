# BOOT-004 自举链路阶段化诊断 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`analysis/boot-repro-v1.md`（BOOT-003）、`tests/run-bootstrap-bstrict-ci.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **自动定位阶段** | 从 CI / 本地失败 log 识别 lexer/parser/typeck/codegen/asm/link 等阶段 |
| **联动复现** | 输出 `SHUX_BOOT_REPRO`，对接 BOOT-003 最小复现 case |
| **可回归** | 模式表 + fixture 门禁，新增失败类型须增 pattern |

验收（NEXT BOOT-004）：**失败日志自动定位阶段** + 文档 + 门禁。

---

## 2. 流水线阶段（v1）

| stage | 含义 | 典型 log 片段 |
|-------|------|---------------|
| **preprocess** | `#if` / `-D` 条件编译 | `preprocess error:`、`unclosed #if` |
| **lexer** | 词法 | `lexer error`、`lex error` |
| **parser** | 语法 / parser emit | `parse error at`、`parser second pass gate FAIL` |
| **typeck** | 类型检查 | `typeck error:` |
| **codegen** | IR / C / asm 发射 | `codegen error:`、`failed to emit function` |
| **asm** | asm 后端 / cfg-merge | `asm-73`、`SIGSEGV`、`__text.*EMPTY` |
| **link** | ld / 符号 | `undefined symbol`、`ld:` |
| **build** | B-strict 构建拓扑 | `pipeline_gen.c`、`experimental fallback` |
| **selfhost** | gen1→gen2 | `verify-selfhost-stage2`、`shux_asm2` |
| **wpo** | WPO strict_glue | `wpo strict link gate FAIL` |
| **run** | 编译后运行 / run-all | `run-.*FAIL`、`test FAILED` |
| **import** | 模块路径 | `cannot open import` |

---

## 3. 用法

### 3.1 诊断 log

```bash
# 从文件
./tests/run-bootstrap-stage-diag.sh /tmp/build_bstrict.log

# 从 stdin
curl ... | ./tests/run-bootstrap-stage-diag.sh --stdin

# 诊断并自动跑最小复现
./tests/run-bootstrap-stage-diag.sh --repro ci.log
```

输出示例：

```
SHUX_BOOT_STAGE=parser
SHUX_BOOT_REPRO=parser_second_pass
SHUX_BOOT_PATTERN=ci_banner_parser_second
SHUX_BOOT_CONFIDENCE=classified
```

### 3.2 库函数（脚本内嵌）

```bash
. tests/lib/bootstrap-stage-diag.sh
bootstrap_stage_classify "$(cat ci.log)"
```

### 3.3 CI 失败 → 复现（完整流程）

1. 保存 CI log
2. `./tests/run-bootstrap-stage-diag.sh --repro ci.log`
3. 或手动：`./tests/run-bootstrap-repro.sh <SHUX_BOOT_REPRO>`

---

## 4. 模式表

文件：`tests/baseline/bootstrap-stage-patterns.tsv`

| 列 | 说明 |
|----|------|
| `pattern_id` | 规则 ID |
| `regex` | ERE，对整段 log 匹配 |
| `stage` | 阶段名 |
| `repro_case_id` | BOOT-003 case |
| `priority` | 越小越优先（多匹配时取最优） |

**v1 规则**：CI banner（如 `parser second pass gate`）priority 5–15；通用错误串 priority 18–35。

---

## 5. 门禁

| 资源 | 路径 |
|------|------|
| 分类器 | `tests/lib/bootstrap-stage-diag.sh` |
| 入口 | `tests/run-bootstrap-stage-diag.sh` |
| fixture | `tests/fixtures/bootstrap-stage-diag/*.log` |
| 期望 | `tests/baseline/bootstrap-stage-diag-fixtures.tsv` |
| 门禁 | `tests/run-bootstrap-stage-diag-gate.sh` |

---

## 6. 变更流程

1. 新增自举 CI 子段 → 增 `ci_banner_*` pattern + 更新 BOOT-003 repro 矩阵
2. 新错误文案 → 增 `err_*` pattern + fixture
3. 运行 `./tests/run-bootstrap-stage-diag-gate.sh` 须全绿

---

## 7. 与 BOOT-005 衔接

BOOT-005 在 taxonomy 上固化 **23 项历史失败类型**（`bootstrap-failure-taxonomy.tsv`），门禁要求 pattern+repro 覆盖 ≥95%。v1 不做自动 log 聚类。

---

## 8. 索引

| 资源 | 路径 |
|------|------|
| 复现 | `tests/run-bootstrap-repro.sh` |
| 自举 CI | `tests/run-bootstrap-bstrict-ci.sh` |
| 文档 | `compiler/docs/SELFHOST.md` |

**BOOT-004 状态：定版 ✅**
