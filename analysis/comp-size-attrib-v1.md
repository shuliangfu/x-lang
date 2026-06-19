# COMP-010 编译产物体积归因 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与 `run-size-shux-asm-gate.sh`（B-SIZE advisory）、`ENG-002` 对齐  
> 关联：`COMP-009`（FE/BE 契约）、`PERF-004`（dogfood）、`tests/baseline/shux-asm-size.tsv`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 归因层 A1–A6 |
| 2 | 打开 `tests/baseline/comp-size-attrib-matrix.tsv` |
| 3 | `./tests/run-comp-size-attrib-gate.sh` |
| 4 | `./tests/run-comp-size-attrib.sh`（本地构建后看 distribution report） |

---

## 2. 归因层 A1–A6（size attribution）

权威：`tests/baseline/comp-size-attrib.tsv`（**6** 条 `layer_*`）。

| 层级 | 度量 | 说明 | 工具 |
|------|------|------|------|
| **A1-exec** | 可执行文件 `file_bytes` | `shux_asm` / `shux-c` / 用户样例 binary | `comp_size_attrib_file_bytes` |
| **A2-object** | `.o` 文件体积 | `build_asm/*.o` 逐项 | matrix `kind=object` |
| **A3-text** | 代码段 `text_bytes` | Mach-O `__text` / ELF `.text` | `comp_size_attrib_o_text_bytes` |
| **A4-strip** | strip 前后 delta | B-SIZE advisory 对标 | `run-size-shux-asm-gate.sh` |
| **A5-rollup** | 分类汇总 + Top 占比 | `build_asm` 合计 / 最大 .o | `comp_size_attrib_rollup` |
| **A6-baseline** | 与 TSV 基线 diff | `shux-asm-size.tsv` | `SHUX_PERF_UPDATE_SIZE_BASELINE` |

**attribution 原则**：

1. **每次构建可复现**：输出机器可读 TSV（`artifact_id` · `file_bytes` · `text_bytes` · `pct`）。
2. **缺失 SKIP**：`build_asm` 未生成时不 fail（Darwin / 未跑 bootstrap 时常见）。
3. **advisory 体积**：超 8MiB 仅 WARN（`SHUX_SIZE_FAIL=0`，ENG-002）；归因工具本身不 block CI。
4. **段级优先**：自举 .o 以 `text_bytes` 排序，比裸 `file_bytes` 更能反映 codegen 膨胀。

---

## 3. 产物矩阵（distribution report）

`tests/baseline/comp-size-attrib-matrix.tsv`（**8** 条 `art_*`）。

| artifact_id | kind | 路径 | policy |
|-------------|------|------|--------|
| `art_shux_asm` | exec | `compiler/shux_asm` | optional |
| `art_shu_c` | exec | `compiler/shux-c` | required |
| `art_pipeline_o` | object | `compiler/build_asm/pipeline.o` | optional |
| `art_parser_o` | object | `compiler/build_asm/parser.o` | optional |
| `art_typeck_o` | object | `compiler/build_asm/typeck.o` | optional |
| `art_backend_o` | object | `compiler/build_asm/backend.o` | optional |
| `art_driver_o` | object | `compiler/build_asm/driver_compile.o` | optional |
| `art_build_asm_rollup` | rollup | `compiler/build_asm` | optional |

---

## 4. 报告格式

```text
# comp-size-attrib report (TSV)
artifact_id	kind	file_bytes	text_bytes	pct_of_total	notes
art_shu_c	exec	12345678	0	45.2	stripped=0
art_pipeline_o	object	89012	45000	3.1	__text
...
```

人类可读 stderr：

```text
comp-size-attrib: distribution total=27345678B artifacts=5 top=art_shu_c:45.2%
```

---

## 5. Golden 联动

| case_id | 脚本 | 期望 |
|---------|------|------|
| `case_attrib_smoke` | `run-comp-size-attrib.sh` | ≥1 artifact；stdout `comp-size-attrib OK` |
| `case_bsize` | `run-size-shux-asm-gate.sh` | advisory ≤8MiB 或 SKIP |
| `case_hello` | `run-size-baseline.sh` | hello 样例体积行 |

---

## 6. 非目标（v1）

- 符号级 bloat 分析（需 llvm-bloat）
- 用户程序 LTO 前后 diff 自动化
- Windows PE 段归因

---

## 7. 验证与门禁

```bash
./tests/run-comp-size-attrib-gate.sh   # runnable：manifest + attribution smoke
./tests/run-comp-size-attrib.sh        # 生成本地 distribution report
./tests/run-size-shux-asm-gate.sh       # B-SIZE advisory 联动
```

**gate report**：stdout 须含 `comp-size-attrib gate OK`；失败打印 `comp-size-attrib FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/comp-size-attrib-v1.md` |
| manifest | `tests/baseline/comp-size-attrib.tsv` |
| matrix | `tests/baseline/comp-size-attrib-matrix.tsv` |

**COMP-010 状态：定版 ✅**
