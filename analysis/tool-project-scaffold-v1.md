# TOOL-006 项目模板脚手架 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`shux build`/`shux run`、`tests/templates/`、TOOL-001（fmt）

---

## 1. 阅读路径（约 10 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 脚手架契约 S1–S5 |
| 2 | 打开 `tests/baseline/tool-project-scaffold.tsv` |
| 3 | `./tests/run-tool-scaffold-gate.sh` |
| 4 | 创建项目：`./scripts/shux-new.sh myapp && cd myapp && shux run main.sx` |

---

## 2. 脚手架契约 S1–S5

权威：`tests/baseline/tool-project-scaffold.tsv`（**5** 条 `rule_*`）。

| 规则 | 说明 | 路径 |
|------|------|------|
| **S1-main** | 模板含 `function main(): i32` 入口 | `tests/templates/project-hello/main.sx` |
| **S2-readme** | README 含 `shux run` / `shux build` 指引 | `tests/templates/project-hello/README.md` |
| **S3-template-dir** | 官方 hello 模板目录完整 | `tests/templates/project-hello/` |
| **S4-shux-new** | 一命令复制模板到目标目录 | `scripts/shux-new.sh` |
| **S5-runnable** | 模板 `main.sx` 可编译运行 exit 42 | `tests/run-tool-scaffold.sh` |

**用户工作流**：

```bash
./scripts/shux-new.sh myapp
cd myapp
shux run main.sx              # 编译并运行
shux build main.sx -o myapp   # 仅编译
./myapp; echo $?             # 期望 42
```

v1 **不**生成 `build.sx`（仓库根 `build.sx` 为编译器自举专用）；用户项目以单文件 `main.sx` 或后续自定义 `build.sx` 扩展。

---

## 3. 模板清单

| 文件 | 用途 |
|------|------|
| `main.sx` | 最小可运行入口（返回 42 供烟测） |
| `README.md` | 快速开始 |

---

## 4. report 与烟测

门禁 **report** 示例：

```
tool-scaffold report template=project-hello exit=42 runnable=OK
```

`tests/run-tool-scaffold.sh`：复制模板到临时目录 → `shux -L <repo> main.sx -o app` → 运行断言 exit 42。

---

## 5. 非目标（v1）

- 不交互式询问项目名/包名（仅 `shux-new.sh <dir>`）。
- 不生成 CI / VS Code 配置（v1.1）。
- 不替代编译器仓库根 `build.sx` + `build_tool` 流程。

---

## 6. 验证与门禁

```bash
./tests/run-tool-scaffold-gate.sh   # runnable：manifest + scaffold hooks
./tests/run-tool-scaffold.sh        # 模板编译运行烟测
./scripts/shux-new.sh /tmp/demo      # 手工创建（native shux）
```

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/tool-project-scaffold-v1.md` |
| matrix | `tests/baseline/tool-project-scaffold.tsv` |
| 模板 | `tests/templates/project-hello/` |
| 库 | `tests/lib/tool-scaffold.sh` |
| 门禁 | `tests/run-tool-scaffold-gate.sh` |
| 初始化 | `scripts/shux-new.sh` |

**TOOL-006 状态：定版 ✅**
