# .sx 与 C 流水线同步状态

## 目标

所有 .sx 必须与 C 同步支持相同语法，否则自举无意义。需同步的语法包括：

1. **顶层 let/const** — `let global_x = 42;`、`const N = 7;`
2. **绑定 import** — `const xxx = import("std.xxxx");` → `xxx.fn()`
3. **解构 import** — `const { a, b, Buffer } = import("std.xxx");` → 裸名 `a()`、`Buffer`

> 旧语法 `import path;`、`const x = import std.xxx` 已移除；路径须写在 `import("...")` 字符串内。详见 `docs/05-函数与模块.md`。

---

## 当前状态（已全面同步）

| 语法 | C 流水线 | .sx 流水线 | 测试 |
|------|----------|------------|------|
| 顶层 let/const | ✅ | ✅ | `run-toplevel-let.sh`（main.sx、two_lets.sx），run-all 始终跑 |
| `const x = import("path");` | ✅ | ✅ | `tests/process/spawn_wait.sx`，run-process.sh 通过（shu_su） |
| `const { a,b } = import("path");` | ✅ | ✅ | run-import 的 const_select.sx、bind_type_smoke.sx 等 |

---

## 已实现（.sx）

- **ast.sx**：`ImportKind`、`Module` 的 `import_kinds` / `import_binding_name` / `import_select_*`、`top_level_let_*` 与 C 对齐。
- **parser.sx**：
  - 顶层 let/const：`parse_one_top_level_let_into` + `parse_into_buf` 中解析并写 `module.top_level_let_*`。
  - `collect_imports` / `collect_imports_buf`：仅 `import("path")`；绑定（`import_kinds[i]=1`，填 `import_binding_name`）、解构（`import_kinds[i]=2`，填 `import_select_count` / `import_select_names`）。
- **typeck.sx**：顶层 let 名字进作用域；`resolve_call_callee_return_type` 支持绑定（EXPR_FIELD_ACCESS base=VAR 按 `import_binding_name` 找 dep）、解构（EXPR_VAR 按 `import_select_names` 找 dep）。
- **codegen.sx**：顶层 let/const 生成 static/init_globals、main 内 `init_globals();`；EXPR_CALL 时对绑定形式（process.getenv）生成 `dep_prefix + field_name(...)`，对解构形式（裸 getenv）按 `import_select_names` 匹配 dep 后生成 `dep_prefix + name(...)`。

---

## 测试清单（与 C 同步相关）

- **run-toplevel-let.sh**：顶层 let/const，C 与 shu_su 均跑，已加入 run-all。
- **run-process.sh**：含 spawn_wait.sx（`const process = import("std.process");` + `process.getenv` / `process.spawn_simple`），C 与 shu_su 均通过。
- **run-import.sh**：const_select.sx、bind_type_smoke.sx 等覆盖绑定与解构，C 与 shu_su 均通过。

结论：**SU 已与 C 全面同步**；绑定与解构 import 均有实现与测试（run-toplevel-let、run-process、run-import）。
