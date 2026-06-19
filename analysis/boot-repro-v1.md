# BOOT-003 自举失败最小复现 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`compiler/docs/SELFHOST.md`、`tests/run-bootstrap-bstrict-ci.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **1 命令复现** | CI / 本地任一自举阶段失败，可用单条命令隔离复现 |
| **阶段可映射** | 失败日志可对应到 lexer/parser/typeck/codegen/link/selfhost |
| **与 CI 对齐** | 复现命令与 `run-bootstrap-bstrict-ci.sh` 子段一一对应 |

验收（NEXT BOOT-003）：**任一失败可 1 命令复现** + 矩阵 + 门禁。

---

## 2. 统一入口

```bash
# 列出全部 case
./tests/run-bootstrap-repro.sh list

# 复现指定阶段（case_id 见 baseline TSV）
./tests/run-bootstrap-repro.sh verify_semantic
./tests/run-bootstrap-repro.sh bstrict_build
./tests/run-bootstrap-repro.sh parser_second_pass

# 跑当前平台适用的全部 case（不含 full_ci）
./tests/run-bootstrap-repro.sh all
```

矩阵：`tests/baseline/bootstrap-repro.tsv`  
门禁：`tests/run-bootstrap-repro-gate.sh`（manifest + hook 存在性）

---

## 3. 失败阶段 taxonomy

| stage | 典型症状 | case_id |
|-------|----------|---------|
| **build** | `make bootstrap-driver-bstrict` 失败；log 含 `pipeline_gen.c` | `bstrict_build` |
| **build** | experimental fallback / 无 `asm_only_strict` | `strict_smoke` |
| **compile** | `shux_asm` 编用户 .sx 失败 | `shux_asm_gate` |
| **compile** | asm binop/cfg-merge SIGSEGV | `asm_73` |
| **run** | B-strict 白名单 run-all 失败 | `run_all_bstrict` |
| **selfhost** | gen1→gen2 不一致 | `stage2_bstrict` |
| **parser** | second-pass emit 回归 | `parser_second_pass` |
| **parser** | thin glue 符号缺失 | `parser_symbol_integrity` |
| **parser** | mega 7 bisect delta | `parser_mega_bisect` |
| **parser** | parse func 计数不足 | `parser_parse_count` |
| **wpo** | strict_glue WPO 链接失败 | `wpo_strict_link` |
| **link/run** | 两代 shux 行为不一致 | `verify_semantic` |
| **all** | 完整 B-strict CI 链 | `full_ci` |

---

## 4. 使用流程

### 4.1 CI 失败 → 本地复现

1. 从 CI log 定位子段（如 `parser second pass gate`）
2. 查 §3 或 `./tests/run-bootstrap-repro.sh list`
3. 执行对应 case，例如：
   ```bash
   ./tests/run-bootstrap-repro.sh parser_second_pass
   ```
4. 若需完整链：`./tests/run-bootstrap-repro.sh full_ci`

### 4.2 前置条件

| 条件 | 说明 |
|------|------|
| `compiler/shux` 可执行 | 冷启动：`make -C compiler OPT=1 all` |
| Linux Stage2 / crt0 | 部分 case 仅 Linux；macOS 会 SKIP 并打印原因 |
| 栈限制 | 脚本内 `ulimit -s 65532`（与 bstrict-ci 一致） |

### 4.3 环境变量

| 变量 | 作用 |
|------|------|
| `SHU` | 覆盖编译器路径 |
| `SHUX_BOOTSTRAP_REPRO_SKIP_BUILD=1` | `bstrict_build` 跳过（已构建时） |
| `SHUX_CI_SKIP_STAGE2=1` | 跳过 stage2 case |

---

## 5. 与 BOOT-004 衔接

BOOT-004 已实现：`tests/run-bootstrap-stage-diag.sh` 从失败 log 输出 `SHUX_BOOT_STAGE` / `SHUX_BOOT_REPRO`；`--repro` 自动调用本脚本 case。

```bash
./tests/run-bootstrap-stage-diag.sh --repro /tmp/build_bstrict.log
```

详见 `analysis/boot-stage-diag-v1.md`。

---

## 6. 索引

| 资源 | 路径 |
|------|------|
| 复现入口 | `tests/run-bootstrap-repro.sh` |
| 矩阵 | `tests/baseline/bootstrap-repro.tsv` |
| 门禁 | `tests/run-bootstrap-repro-gate.sh` |
| 完整 CI | `tests/run-bootstrap-bstrict-ci.sh` |
| 自举文档 | `compiler/docs/SELFHOST.md` |

**BOOT-003 状态：定版 ✅**
