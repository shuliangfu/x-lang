# 阶段 5：多文件与 import 策略

> 策略文档，供 5.1 验收及后续实现参考。

---

## 策略选择：C 辅助

**采用 C 辅助策略**：由 C（main.c）负责 import 路径解析与预处理，对每个模块调用 .sx 流水线（`run_sx_pipeline`），再拼接 C 输出。

### 流程

1. **入口解析**：读取入口 .sx，预处理，调用 `parse_into` 得到 Module（含 `import_paths`）。
2. **路径解析**：C 用 `resolve_import_file_path_multi` 在 `-L` 与 `entry_dir` 下解析 import 路径，得到依赖文件列表。
3. **拓扑序**：递归加载依赖（与 C 路径一致），保证依赖先于被依赖模块。
4. **每模块流水线**：对每个模块（依赖 + 入口）依次执行：
   - `read_file` → `preprocess` → `pipeline_run_sx_pipeline(arena, module, source, out_buf)`
5. **输出拼接**：按拓扑序输出 dep 的 C，再输出入口的 C，形成单文件 C 源码。
6. **调用 cc**：与 `-o` 时相同，将生成的 C 传给 cc 链接。

---

## 与 C 路径的差异

| 项目 | C 路径 | .sx 路径（阶段 5） |
|------|--------|--------------------|
| 解析 | C parse | parser.sx parse_into |
| 类型检查 | C typeck_module | typeck.sx typeck_sx_ast |
| 代码生成 | C codegen | codegen.sx codegen_sx_ast |
| import 路径解析 | resolve_import_file_path_multi | 复用 C |
| 预处理 | preprocess | 复用 C |
| 多模块管理 | all_dep_mods / dep_mods | 每模块独立 arena/module |

---

## 依赖与限制

- **parser.sx**：需在 `parse_into` 中收集 import 路径到 `Module.import_paths`（当前 `skip_imports` 仅跳过）。
- **ast.sx Module**：需增加 `import_paths`、`num_imports` 字段。
- **跨模块调用**：当前 .sx codegen 对库模块符号不加前缀；多依赖同名时可能冲突，后续扩展。
- **单模块用例**：无 import 时仍走单文件 `run_sx_pipeline`，逻辑不变。

---

## 验收

- **5.1**：本文档已说明策略。
- **5.2**：`tests/run-multi-file.sh` 在 `-sx` 下可编译通过（main.sx import foo，main 调用 bar() 返回 42）。
