# BOOT-024：parser C2 139 函数全量 emit v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：BOOT-023 mega7 7/7 emit、`comp-parser-mega7-matrix.tsv` C 阶段  
> 关联：`boot-mega7-gap.md` 阶段 C2/C3、COMP-001

---

## 1. 目标

在 BOOT-023 mega7 全量 emit 基础上推进 **C2 bootstrap 全量 emit**：`SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1` 探测 parser.x 全量编译；**MINIMAL** 白名单须绿，**FULL** 139 函数为 Linux 达标目标。

验收：`tests/run-boot-024-parser-bootstrap-emit-gate.sh` 绿；`min_bootstrap_hooks=4`；Linux `bootstrap_minimal_ok=1`。

---

## 2. Bootstrap Emit 矩阵

| ID | 阶段 | hook | 说明 |
|----|------|------|------|
| `boot_c1` | C1 | `run-parser-parse-bootstrap-gate.sh` | C seed parse_into_buf TU |
| `boot_c2` | C2 | `run-parser-parse-bootstrap-link-smoke.sh` | experimental 链 smoke |
| `boot_bisect` | C2 | `run-parser-parse-bootstrap-bisect-gate.sh` | MINIMAL + FULL bisect |
| `boot_x_emit` | C3 | `run-parser-parse-bootstrap-x-emit-gate.sh` | X emit 轨道探测 |

环境变量：`SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1`（全量）；`SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL=1`（白名单）。

---

## 3. Bootstrap 波次

```bash
./tests/run-parser-parse-bootstrap-bisect-gate.sh
```

Linux + `compiler/shux` 时执行 bisect；Darwin / 无 seed 时 manifest 绿 + wave **SKIP**。

---

## 4. Gate

```bash
./tests/run-boot-024-parser-bootstrap-emit-gate.sh
```

```
shux: [SHUX_BOOT024] status=ok bootstrap_minimal_ok=1 bootstrap_full_emit=0 skip=1
```

- **bootstrap_minimal_ok**：MINIMAL 白名单 bisect 通过
- **bootstrap_full_emit**：FULL `ec=0` 且无 mega leak（v1 常为 0；达标后变 1）
- Darwin / 无 `shux`：manifest 绿 + wave **SKIP**

---

## 5. 联动

- manifest：`tests/baseline/boot-024-parser-bootstrap-emit.tsv`
- 波次表：`tests/baseline/parser-bootstrap-emit-wave.tsv`
- 父波次：`run-boot-023-mega7-full-emit-gate.sh`
- 矩阵：`comp-parser-mega7-matrix.tsv`（C3 `emit_target`）
- C TU：`compiler/seeds/parser_asm/parser_asm_parse_bootstrap_obj.c`

---

## 6. 非目标（v2）

- gen1 X 编 gen2 parser 三代一致性（C3 终态）
- Darwin nm 硬门禁
- 批量 safe_helper 全替换
