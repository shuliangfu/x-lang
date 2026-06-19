# COMP-011 Windows 目标后端验证 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — COFF 写出 + 跨主机烟测；MSYS 全链 link+run 为 Tier B  
> 关联：`compiler/src/asm/README.md` §5、`tests/run-asm.sh`、`ci-platform-matrix.tsv`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 验证层 W1–W6 |
| 2 | 打开 `tests/baseline/comp-win-backend-matrix.tsv` |
| 3 | `./tests/run-comp-win-backend-gate.sh` |
| 4 | `./tests/run-comp-win-backend.sh` |

---

## 2. 验证层 W1–W6（windows backend）

权威：`tests/baseline/comp-win-backend.tsv`（**6** 条 `layer_*`）。

| 层级 | 能力 | 实现 | 验证 |
|------|------|------|------|
| **W1-coff-writer** | PE/COFF `.obj` 写出 | `platform/coff.sx` `write_coff_o_to_buf` | 非空 `.obj` |
| **W2-target-triple** | Windows triple 识别 | `-target x86_64-pc-windows-msvc` | driver `use_coff_o` |
| **W3-ctx-flag** | 流水线上下文 | `PipelineDepCtx.use_coff_o` | `ast.sx` |
| **W4-ld-link** | 链接器分派 | `runtime.c` `lld-link` / `link` | MSYS 全链 |
| **W5-cross-emit** | 非 Windows 主机交叉出 COFF | `run-asm.sh` / 本 gate | macOS/Linux 烟测 |
| **W6-min-sample** | 最小可编译样例 | `tests/asm/windows_min.sx` | exit **42**（MSYS） |

**windows backend 原则**：

1. **仅 x86_64**：`coff.sx` `e_machine == 62`；arm64-windows 为 v2。
2. **-o 后缀**：`.o` / `.obj` 触发 COFF；可执行 `-o prog.exe` 走 link 路径。
3. **跨主机**：Linux/macOS 只验证 **COFF 对象可生成**；link+run 在 **MSYS CI** 执行。
4. **最小样例**：`windows_min.sx` 单函数 `return 42`，与 `main.sx` 等价、专用于 manifest。

---

## 3. 验证矩阵（sample report）

`tests/baseline/comp-win-backend-matrix.tsv`（**6** 条 `case_*`）。

| case_id | 样例 | 命令 | 期望 |
|---------|------|------|------|
| `case_windows_min` | `windows_min.sx` | `-backend asm -target x86_64-pc-windows-msvc -o out.obj` | 非空 COFF |
| `case_main_compat` | `main.sx` | 同上 | 与 run-asm COFF 段一致 |
| `case_triple_msvc` | triple 字符串 | driver 解析 | `use_coff_o=1` |
| `case_ld_lld` | link 路径 | `lld-link /entry:_main` | MSYS optional |
| `case_cross_host` | 非 MSYS | 仅 emit | SKIP link |
| `case_ci_windows` | GHA windows-latest | `run-ci-full-suite.sh` lite | Tier B |

---

## 4. Golden 文件

| 锚点 | 路径 |
|------|------|
| COFF writer | `compiler/src/asm/platform/coff.sx` |
| 平台 README | `compiler/src/asm/platform/README.md` |
| driver link | `compiler/src/runtime.c`（`use_coff_o`） |
| 最小样例 | `tests/asm/windows_min.sx` |
| asm 回归 | `tests/run-asm.sh`（COFF 段） |

---

## 5. 非目标（v1）

- arm64-windows / MSVC ABI 全量
- PE 可执行直接写出（无 link）
- MinGW gcc 链替代 lld-link

---

## 6. 验证与门禁

```bash
./tests/run-comp-win-backend-gate.sh   # runnable：manifest + COFF emit
./tests/run-comp-win-backend.sh        # 最小样例 smoke
./tests/run-asm.sh                     # 含 COFF 交叉烟测（SHUX_CI_FORCE_ASM=1）
```

**gate report**：stdout 须含 `comp-win-backend gate OK`；失败打印 `comp-win-backend FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/comp-win-backend-v1.md` |
| manifest | `tests/baseline/comp-win-backend.tsv` |
| matrix | `tests/baseline/comp-win-backend-matrix.tsv` |

**COMP-011 状态：定版 ✅**
