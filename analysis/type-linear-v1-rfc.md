# 线性类型 v1 设计定版（TYPE-001）

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与当前 M-4 实现及 `tests/run-typeck-linear.sh` 对齐  
> 关联：`TYPE-002`（区域/生命周期 M-3）、`MEM-001`（内存安全）、零拷贝 ZC 路径

---

## 1. 目标与定位

| 目标 | 说明 |
|------|------|
| **唯一消费** | 每个 `Linear(T)` 值在函数体内**最多被消费一次**（move），防止 double-free / use-after-move 类错误 |
| **零运行时开销** | `Linear(T)` 与内层 `T` **同 ABI、同布局**；无引用计数、无 drop 表、无额外字段 |
| **显式边界** | 禁止对 linear 取址；move 在 typeck 编译期拒绝二次使用 |
| **与 region 分工** | linear 管**所有权转移**；`T[]<label>` + `region` 管**借用域**（见 §6） |

设计原则与《语法与类型设计-高性能与内存安全.md》一致：**关键处显式、默认安全、零成本抽象**。

---

## 2. 语法（v1）

### 2.1 类型写法

```su
Linear(T)
```

- `T`：内层类型，须为**可按值传递**的类型（见 §3.1）。
- 解析：标识符 `Linear` 后接 `(` 内层类型 `)`；否则 `Linear` 视为普通类型名（NAMED）。

### 2.2 合法使用形态（v1）

| 场景 | 示例 | 语义 |
|------|------|------|
| let 声明 + 字面量初值 | `let a: Linear(i32) = 1` | 从 `T` 字面量**包装**为 linear（非 move） |
| let move | `let b: Linear(i32) = a` | 读取 `a` 并 **move** 给 `b` |
| 实参 move | `take(a)` | 读取 `a` 并 **move** 入参 |
| return move | `return a` | 读取 `a` 并 **move** 作为返回值 |
| 形参 | `fn f(v: Linear(T))` |  callee 获得已 move 的所有权 |

### 2.3 非法使用（v1 必须 typeck 拒绝）

| 场景 | 错误文案（当前实现） |
|------|----------------------|
| 二次读取同一 binding | `linear value used after move` |
| 取址 | `cannot take address of linear value` |
| let 类型不匹配 | `let type mismatch: expected Linear(...), found ...` |

---

## 3. 语义规则

### 3.1 内层类型 `T`（v1 允许集）

| 类别 | 允许 | 说明 |
|------|------|------|
| 标量整型/浮点/bool | ✅ | `i32`、`u8`、`f64` 等 |
| 裸指针 `*T` | ✅ | 与 C 布局一致 |
| 具名 struct（按值） | ✅ | ABI 与 struct 相同；**字段级 linear 不在 v1** |
| 切片 `T[]` / 数组 | ⚪ 暂缓 | 与 region 组合语义未闭合，v1 **不建议**对外承诺 |
| 嵌套 `Linear(Linear(T))` | ❌ | v1 不支持 |
| `Linear` 作 struct 字段 | ❌ | v1 不支持（无字段 move 检查） |

**包装规则**：`let x: Linear(T) = <expr>` 当 `<expr>` 的 resolved 类型与 `T` **type_equal** 时合法（非 move）；否则须为同类型 linear 的 move（VAR 读取）。

### 3.2 Move 触发点

凡 **读取** 绑定名为 `Linear(T)` 的 `AST_EXPR_VAR`，即触发 move：

1. 表达式中的变量引用（含 call 实参、return 操作数、let 右值）
2. **不**在「仅作类型上下文」处触发（如 sizeof 若未来支持）

Move 后该 symtab 槽位置 **moved** 位；同函数内再次读取同一 binding → 报错。

### 3.3 作用域与重置

- Move 状态 **按函数体** 维护：进入每个函数（含 `main`）时 `typeck_linear_reset()`。
- **不**跨函数跟踪：callee 消费形参后，caller 侧 binding 已在传参时 move。
- **不**跨分支做可达性分析（v1 保守语义）：任一分支内 move 即视为 binding 已 move，合并点后不可再用（见 `return_branch.sx`）。

### 3.4 与赋值、mut 的关系

- v1 **无** `Linear(T)` 的 `=` 再赋值语义（须通过新 `let` move）。
- 普通 `T` 变量规则不变；linear 是独立 kind（`AST_TYPE_LINEAR`）。

### 3.5 与 `&` / 指针的关系

- **禁止** `&linear_var`（`AST_EXPR_ADDR_OF` 在 operand 为 linear binding 时报错）。
- `Linear(*T)` 允许，但 move 后指针语义与普通 `*T` 相同；**不**自动附带 region 标签。

---

## 4. 实现边界（typeck / codegen）

### 4.1 typeck（M-4，已实现）

| 模块 | 职责 |
|------|------|
| `typeck_linear_reset` | 函数入口清零 `g_linear_moved[]` |
| `typeck_linear_use_var` | VAR 读取时检查并标记 moved |
| `typeck_linear_accepts_inner` | let 初值从 `T` 包装 |
| `typeck_expr_sym` ADDR_OF | 拒绝 linear 取址 |
| `type_equal` | `Linear(T1)` 与 `Linear(T2)` 当且仅当 `T1`/`T2` equal |

SX/WPO 路径：`pipeline_typeck_linear_*_c`（`pipeline_glue.c`）与 C 侧措辞一致。

### 4.2 codegen（已实现）

- `Linear(T)` **大小、对齐、C 类型名**与内层 `T` 相同。
- Move **无额外指令**：按值拷贝/传参即语义上的 move；安全由 typeck 保证。

### 4.3 明确不在 v1 的 typeck

- match 臂 merge move 状态
- async 任务间 linear 传递
- 闭包捕获 linear
- 泛型/trait 约束 `Linear<T>`
- 跨 block 的精确 liveness（仅 conservative）

---

## 5. 验收用例（与 CI 对齐）

门禁脚本：`tests/run-typeck-linear.sh`

| 文件 | 预期 |
|------|------|
| `tests/typeck/linear/move_ok.sx` | ✅ typeck + emit |
| `tests/typeck/linear/double_move.sx` | ❌ `linear value used after move` |
| `tests/typeck/linear/call_double.sx` | ❌ 同上（call 消耗实参） |
| `tests/typeck/linear/addr_of.sx` | ❌ `cannot take address of linear value` |
| `tests/typeck/linear/return_branch.sx` | ❌ 分支 return 后合并点二次使用 |

**RFC 审阅通过条件**：本文档定版 + 上述 5 例 CI 绿 + 与 `compiler/src/typeck/typeck.c` M-4 注释一致。

---

## 6. 与区域/生命周期（M-3）、零拷贝的关系

```
┌─────────────────────────────────────────────────────────┐
│  Linear(T)          │  T[]<label> + region               │
├─────────────────────┼───────────────────────────────────┤
│  所有权：唯一消费    │  借用：域标签约束存储/传参          │
│  防 double-use      │  防 slice 逃逸 / UAF               │
│  值类型 / 小资源    │  缓冲区视图、read_ptr 返回值        │
└─────────────────────┴───────────────────────────────────┘
```

| 组合 | v1 策略 |
|------|---------|
| `Linear(u8[])` | **不推荐**；缓冲区所有权宜用 `Linear(*u8)` + len 分离，或 v2 专用 handle |
| `read_ptr` → `u8[]<io_read_ptr>` | 走 **region**（M-5），非 linear |
| 文件描述符 / socket handle | 未来可用 `Linear(i32)` 或具名 struct 包装 |

TYPE-002 实装范围见 M-3 测试集 `tests/run-typeck-region.sh`；linear 与 region **正交**，同一变量不同时具备两种包装。

---

## 7. v2 预留（不在 TYPE-001 范围）

| 项 | 说明 |
|----|------|
| 分支敏感 liveness | `if cond { return x } else { use(x) }` 精确合并 |
| struct 字段 linear | 需字段级 move 与 partial move |
| `drop` / scope guard | 若引入 RAII，须单独 RFC |
| 标准库 handle 类型 | `Linear(Fd)`、`Linear(OwnedBuffer)` 等别名与 API 规范 |
| 错误信息增强 | LANG-008：指出首次 move 位置 |

---

## 8. 文档与代码索引

| 资源 | 路径 |
|------|------|
| AST | `AST_TYPE_LINEAR`，`elem_type` 为内层 T |
| Parser | `compiler/src/parser/parser.c` — `Linear(` 解析 |
| Typeck | `compiler/src/typeck/typeck.c` — M-4 |
| Codegen | `compiler/src/codegen/codegen.c` — 同 T 布局 |
| 测试 | `tests/typeck/linear/*.sx` |
| 区域/生命周期 v1 | `analysis/type-region-v1-rfc.md` |
| 路线图 | `NEXT.md` TYPE-001 / TYPE-002 |

---

## 9. 审阅结论

- **语义**：v1 采用 **use-once move + 禁止取址 + 与 T 同布局**，满足内存安全子集内「防二次释放/误用」目标。
- **性能**：零 RT 开销，符合项目宗旨。
- **可演进**：v2 在不动 ABI 前提下可加强 liveness 与 struct 字段支持。

**TYPE-001 状态：定版 ✅**（待 TYPE-002 区域检查 v1 实装验收后，联合纳入 DOC-004 内存安全指南。）
