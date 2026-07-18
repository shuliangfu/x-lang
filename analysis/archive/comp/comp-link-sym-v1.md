# COMP-008 链接符号冲突诊断 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 在 BOOT-004 粗粒度 `link` 阶段之上，细化 **undefined / duplicate** 归因  
> 关联：`analysis/boot-stage-diag-v1.md`、`compiler/scripts/relink_shux_asm_strict_glue.sh`、`tests/run-wpo-strict-link-gate.sh`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 归因层 L1–L6 |
| 2 | 打开 `tests/baseline/comp-link-sym-cases.tsv` |
| 3 | `./tests/run-comp-link-sym-gate.sh` |
| 4 | `./tests/run-comp-link-sym.sh tests/fixtures/comp-link-sym/undefined_parser.log` |

---

## 2. 归因层 L1–L6（link symbol conflict attribution）

权威：`tests/baseline/comp-link-sym.tsv`（**6** 条 `layer_*`）。

| 层级 | 冲突种类 | 解析策略 | 验证 |
|------|----------|----------|------|
| **L1-undefined** | 未定义符号 | `ld: undefined symbol` / `undefined reference to` | fixture `undefined_parser.log` |
| **L2-duplicate** | 重复定义 | `duplicate symbol` / `multiple definition of` | fixture `duplicate_glue_typeck.log` |
| **L3-platform** | Mach-O vs ELF 文案 | Darwin `_sym` / GNU `sym` 归一化 | `comp-link-sym-patterns.tsv` |
| **L4-object** | 冲突 .o 归因 | log 中 `build_asm/*.o` / `*_glue.o` 路径 | fixture `duplicate_glue_typeck.log` |
| **L5-known** | 已知拓扑模式 | typeck∩glue、parser_x 双链、WPO strict | `relink_shux_asm_strict_glue.sh` |
| **L6-repro** | 复现 case 建议 | 输出 `SHUX_LINK_REPRO` | `comp-link-sym-cases.tsv` |

**attribution 原则**：

1. **先分 kind**：`undefined` / `duplicate` / `link_failed`（无法解析符号时）。
2. **再提 symbol**：剥 Mach-O 前导 `_`，统一为小写比对。
3. **再挂 hint**：`typeck_glue_dup`、`wpo_orchestration`、`parser_double_link` 等已知模式。
4. **最后 repro**：对接 BOOT-003 `bstrict_build` / `wpo_strict_link` 等 case。

与 BOOT-004 关系：BOOT-004 将 log 标为 `stage=link`；本 RFC 在同一 log 上输出 **细粒度 conflict report**（`SHUX_LINK_*` 变量）。

---

## 3. 冲突用例矩阵（cases）

`tests/baseline/comp-link-sym-cases.tsv`（**6** 条 fixture）。

| case_id | fixture | kind | symbol | hint | repro |
|---------|---------|------|--------|------|-------|
| `case_undef_parser` | `undefined_parser.log` | undefined | `parser_parse_into_buf` | `missing_export` | `bstrict_build` |
| `case_dup_glue` | `duplicate_glue_typeck.log` | duplicate | `ast_pool_alloc` | `typeck_glue_dup` | `bstrict_build` |
| `case_dup_macho` | `duplicate_darwin.log` | duplicate | `main_entry` | `double_main` | `bstrict_build` |
| `case_wpo_undef` | `undefined_wpo.log` | undefined | `run_x_pipeline_impl` | `wpo_orchestration` | `wpo_strict_link` |
| `case_link_failed` | `linker_failed_generic.log` | link_failed | — | `generic_ld` | `bstrict_build` |
| `case_parser_dup` | `duplicate_parser_x.log` | duplicate | `parse_into_buf` | `parser_double_link` | `parser_second_pass` |

---

## 4. 分类器 API

```bash
. tests/lib/comp-link-sym.sh
comp_link_sym_classify "$(cat ci.log)"
# SHUX_LINK_KIND=undefined
# SHUX_LINK_SYMBOL=parser_parse_into_buf
# SHUX_LINK_HINT=missing_export
# SHUX_LINK_REPRO=bstrict_build
# SHUX_LINK_OBJECT=build_asm/typeck.o   # 若 log 含路径
```

**conflict report**（stderr 人类可读）：

```
comp-link-sym: kind=undefined symbol=parser_parse_into_buf hint=missing_export repro=bstrict_build
```

---

## 5. 非目标（v1）

- 自动修复 / 重链脚本生成
- 用户程序 C 互操作全量符号图
- Windows COFF 专用解析器

---

## 6. 验证与门禁

```bash
./tests/run-comp-link-sym-gate.sh   # runnable：manifest + fixture attribution
./tests/run-comp-link-sym.sh        # 全 fixture 烟测
./tests/run-bootstrap-stage-diag-gate.sh  # 粗粒度 link 阶段仍由 BOOT-004 覆盖
```

**gate report**：stdout 须含 `comp-link-sym gate OK`；失败打印 `comp-link-sym FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/comp-link-sym-v1.md` |
| manifest | `tests/baseline/comp-link-sym.tsv` |
| patterns | `tests/baseline/comp-link-sym-patterns.tsv` |
| cases | `tests/baseline/comp-link-sym-cases.tsv` |

**COMP-008 状态：定版 ✅**
