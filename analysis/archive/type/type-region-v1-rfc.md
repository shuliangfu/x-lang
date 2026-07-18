# 区域/生命周期检查 v1 设计定版（TYPE-002）

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与当前 M-3/M-5 实现及 `tests/run-typeck-region.sh` 对齐  
> 关联：`TYPE-001`（线性类型）、`MEM-001`（内存安全）、ZC-3 零拷贝 slice 路径

---

## 1. 目标与定位

| 目标 | 说明 |
|------|------|
| **编译期拒绝 UAF** | 域绑定 slice（`T[]<label>`）不得逃逸到未标注域或错误域，防止 use-after-free |
| **零运行时开销** | `region` 块 codegen 等价嵌套 `{ }`；域标签仅 typeck 存在，不进 ABI |
| **零拷贝协同** | `read_ptr` 系 API 自动绑 `io_read_ptr` 域（M-5），与 std.io TLS buf 契约一致 |
| **与 linear 分工** | region 管**借用域**；`Linear(T)` 管**所有权转移**（见 `type-linear-v1-rfc.md`） |

验收标准（NEXT TYPE-002）：**关键路径 UAF 在 compile-time 被拒绝**。

---

## 2. 语法（v1）

### 2.1 域标注 slice 类型

```su
T[]<label>
```

- `T`：元素类型（`i32`、`u8` 等）。
- `<label>`：域标签标识符（如 `ra`、`io_read_ptr`），编译期字符串，**不进运行时布局**。
- 未标注 `T[]`：表示**未绑定域**（可接收任意域 slice 的「宽」类型，但**不能**接收已绑定域 slice 赋值——防逃逸）。

### 2.2 region 块

```su
region ra {
  let s: i32[] = slice_src();  // 块内未标注 i32[] 自动继承 ra
}
```

- `region <label> { ... }`：块内 `let` 声明的未标注 `T[]` 由 typeck **stamp** 为 `T[]<label>`。
- 嵌套 region：内层 label 覆盖内层 stamp；**不**自动继承外层（v1 按块 label 显式）。

### 2.3 与 read_ptr（M-5）

下列 callee 的 **返回值** typeck 自动解析为 `u8[]<io_read_ptr>`：

- `read_ptr_slice`
- `shu_io_read_ptr_slice`
- `driver_read_ptr_slice`
- `io_read_ptr_slice`

用户侧应声明 `let s: u8[]<io_read_ptr> = read_ptr_slice()`；赋给未标注 `u8[]` 或错误域 → 报错。

---

## 3. 语义规则

### 3.1 两类检查

| 检查 | 条件 | 错误文案 |
|------|------|----------|
| **逃逸（escape）** | `src` 带 `region_label`，`expect` 无 label | `slice region escape: cannot assign <%s> slice to unbound T[]` |
| **域冲突（mismatch）** | 双方均带 label 且字符串不等 | `slice region mismatch: expected <%s>, found <%s>` |

return 路径措辞：`slice region escape: cannot return <%s> slice as unbound T[]` / `slice region mismatch in return: ...`

### 3.2 检查触发点（v1 已实装）

| 场景 | 检查函数 |
|------|----------|
| `let x: T[]<La> = y` | `typeck_check_slice_region_assign` |
| `x = y`（assign） | 同上（`AST_EXPR_ASSIGN`） |
| `return expr` | `typeck_check_return_slice_region` |
| `f(arg)` 实参与形参 | call 路径 `typeck_check_slice_region_assign` |
| region 块内 `let` | `typeck_stamp_slice_region` + 后续 assign 检查 |

### 3.3 type_equal 与域标签

- 两个 `T[]` 当且仅当元素类型 equal **且** 域标签一致（均有且同字符串，或均无 label）时 equal。
- 同元素类型、不同 label → **不等**（防 silent 跨域）。

### 3.4 运行时与 ABI

- Slice ABI 仍为 `(ptr, len)`（见《内存契约.md》），**无第三字段**存 label。
- `region` 块：codegen 展开为普通嵌套块，**零开销**。
- 域安全完全由 typeck 静态保证；违反则编译失败，不生成错误代码路径。

---

## 4. 关键 UAF 路径（v1 必须拒绝）

| ID | 模式 | 测试文件 | 预期 |
|----|------|----------|------|
| UAF-1 | 域内 slice → 块外未标注变量 | `region_assign_escape.x` | escape |
| UAF-2 | 域内 slice → 块外不同域变量 | `region_block_escape.x` | mismatch |
| UAF-3 | 跨域 let 赋值 | `region_mismatch.x` | mismatch |
| UAF-4 | 域内 slice 作未标注返回值 | `region_return_escape.x` | escape |
| UAF-5 | 实参域 → 未标注形参 | `region_call_escape.x` | escape |
| UAF-6 | 实参域 ≠ 形参域 | `region_call_mismatch.x` | mismatch |
| UAF-7 | read_ptr → 未标注 `u8[]` | `read_ptr_region_escape.x` | escape |
| UAF-8 | read_ptr → 错误域 | `read_ptr_region_mismatch.x` | mismatch |

---

## 5. 正例（v1 必须通过）

| 文件 | 说明 |
|------|------|
| `region_same_ok.x` | 同域 `i32[]<ra>` 赋值 |
| `region_block_same.x` | region 块内 stamp + 同域 assign |
| `region_call_ok.x` | call 实参/形参同域 |
| `read_ptr_region_ok.x` | read_ptr + `u8[]<io_read_ptr>` |

---

## 6. 实现边界

### 6.1 typeck（M-3/M-5，已实现）

| 符号 | 路径 |
|------|------|
| `typeck_slice_region_escape` | `compiler/src/typeck/typeck.c` |
| `typeck_slice_region_conflict` | 同上 |
| `typeck_stamp_slice_region` | 同上 |
| `typeck_check_slice_region_assign` | 同上 |
| `typeck_check_return_slice_region` | 同上 |
| `typeck_is_read_ptr_slice_producer` | M-5 read_ptr 自动域 |
| X/WPO glue | `pipeline_typeck_check_slice_region_assign_c` 等 |

### 6.2 parser / AST

- `ASTBlock.regions[]`：`label` + `body`
- `ASTType.region_label`：slice 域字符串
- 类型解析：`T[]<label>`（`parser_asm_type_ref_slice.c` / `parser.x`）

### 6.3 codegen

- region → 嵌套块，无额外指令（`codegen.c` case 5 / `codegen.x`）

### 6.4 v1 明确不做

| 项 | 说明 |
|----|------|
| 指针 `*T` 域标注 | 仅 slice；裸指针生命周期另议 |
| 跨函数域推断 | 须显式标注形参/返回值 |
| 结构体字段 slice 域 | 无字段级 region stamp |
| 动态/表达式域标签 | label 须编译期常量标识符 |
| 与 async/await 特殊合并 | v1 按普通块规则 |

---

## 7. 验收与 CI

### 7.1 门禁脚本

| 脚本 | 范围 |
|------|------|
| `tests/run-typeck-region.sh` | 12 个 typeck 用例（§4 + §5 + read_ptr） |
| `tests/run-zc3-gate.sh` | region typeck + slice 字段 + read_ptr 运行时 + smoke |
| `tests/run-portable-suite.sh` | 含 region typeck |
| `tests/run-pre-push-p5.sh` | 经 `run-zc-gates.sh` → zc3 间接覆盖 |

### 7.2 审阅通过条件

- 本文档定版 ✅  
- `run-typeck-region.sh` 12/12 用例 CI 绿  
- 关键 UAF 路径 §4 全部 compile fail  

---

## 8. 与 TYPE-001、零拷贝的关系

```
read_ptr_slice()  ──► u8[]<io_read_ptr>  ──► 仅在同域变量/形参间传递
                              │
                              ▼
                    禁止 → u8[]（宽类型）= UAF 风险

Linear(T)  ──► 所有权唯一消费（与 slice 域正交，不组合 v1）
```

ZC-3 gate 将 **编译期域检查** 与 **数组→slice 运行时**、**read_ptr_slice** 链接，形成零拷贝 IO 路径的安全子集。

---

## 9. v2 预留

| 项 | 说明 |
|----|------|
| LANG-008 | 报错指向首次绑定域与逃逸站点 |
| TYPE-003 | 借用冲突诊断、误报率优化 |
| 嵌套 region 继承规则 | 外层 label 自动继承可选语法 |
| struct 内 slice 域 | 需 layout + assign 扩展 |

---

## 10. 文档索引

| 资源 | 路径 |
|------|------|
| 线性类型 v1 | `analysis/type-linear-v1-rfc.md` |
| 内存契约 Slice | `analysis/内存契约.md` §3 |
| 测试 | `tests/typeck/slice_lifetime/*.x` |
| 路线图 | `NEXT.md` TYPE-002 |

**TYPE-002 状态：定版 ✅**（M-3/M-5 实装 + 门禁已就绪；v2 见 TYPE-003 / LANG-008。）
