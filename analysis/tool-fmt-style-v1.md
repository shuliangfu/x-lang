# TOOL-001 formatter 稳定化与风格锁定 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`compiler/src/driver/fmt.sx`、`tests/run-fmt-wrap.sh`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 风格规则 S1–S6 |
| 2 | 打开 `tests/baseline/tool-fmt-style.tsv` |
| 3 | `./tests/run-tool-fmt-gate.sh` |
| 4 | 本地：`shux fmt` / `shux fmt --check` |

---

## 2. 风格规则 S1–S6

| 规则 | 说明 | 金样 |
|------|------|------|
| **semicolon_space** | `;` 后接标识符须有空格（排除 `for(;;)`） | `fmt_semicolon_space.sx` |
| **operator_space** | 二元运算符两侧空格一致 | `fmt_operator_space.sx` |
| **array_comma_space** | 数组字面量 `,` 后补空格 | `fmt_array_comma_space.sx` |
| **comment_preserve** | 折行不丢失 `//` / `*` 前缀 | `scan_fmt_damage.py`、`verify_comment_prefixes.py` |
| **fmt_idempotent** | `fmt` 后 `fmt --check` 静默成功（deno 语义） | `run-fmt-check-cmd.sh` |
| **check_after_fmt** | `fmt` 后 `check` 无诊断 | `run-fmt-wrap.sh` |

实现：`compiler/src/driver/fmt_check_cmd.c` + `driver_fmt_one_file`。

---

## 3. 金样用例矩阵

权威：`tests/baseline/tool-fmt-style.tsv`（**5** 个 `tests/fmt/*` 金样）。

| id | 文件 |
|----|------|
| `case_wrap` | `tests/fmt/fmt_wrap_cases.sx` |
| `case_comprehensive` | `tests/fmt/fmt_comprehensive.sx` |
| `case_semicolon` | `tests/fmt/fmt_semicolon_space.sx` |
| `case_operator` | `tests/fmt/fmt_operator_space.sx` |
| `case_array_comma` | `tests/fmt/fmt_array_comma_space.sx` |

全仓推广：新 `.sx` 须 `shux fmt` 后 `shux fmt --check` 通过再提交。

---

## 4. 幂等与 --check

```bash
shux fmt path.sx              # 写回；成功可打印 fmt OK
shux fmt --check path.sx      # 已格式化 → exit 0 无输出
```

门禁 hook：

- `tests/run-fmt-cmd.sh`
- `tests/run-fmt-check-cmd.sh`
- `tests/run-fmt-wrap.sh`

---

## 5. 非目标（v1）

- 不强制全仓库一次性 `fmt`（增量金样 + CI hook）。
- 不做 `.sx` 以外扩展名。

---

## 6. 验证与门禁

```bash
./tests/run-tool-fmt-gate.sh   # runnable：manifest + fmt hooks
```

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/tool-fmt-style-v1.md` |
| manifest | `tests/baseline/tool-fmt-style.tsv` |
| 库 | `tests/lib/tool-fmt.sh` |
| 门禁 | `tests/run-tool-fmt-gate.sh` |

**TOOL-001 状态：定版 ✅**
