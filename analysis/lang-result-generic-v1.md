# LANG-010：Result<T,E> 泛型 struct 完整形态 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：LANG-009 Option<T>；CORE-003 Result 类型族；EXC-001 错误传播  
> 关联：CORE-016 统一、LANG-009 mangling 基础设施

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§5 |
| 2 | `tests/baseline/lang-result-generic.tsv` |
| 3 | `./tests/run-lang-result-generic-gate.sh` |

---

## 2. 闭环 M7–M9（双参 generic struct monomorph）

| 层级 | 能力 | 锚点 |
|------|------|------|
| **M7-syntax** | `struct Result<T, E> { ... }` | `parser.c` |
| **M8-parse-inst** | `Result<i32,i32>` / `Result<i32, i32> { ... }` mangling | `parser_append_type_inst_mangle` |
| **M9-typeck** | 模板跳过布局 + 双参单态化物化 | `typeck_materialize_generic_structs` |

v1 支持的具体类型实参：`i32`、`u8`、`bool`（T/E 各一，逗号分隔）。

mangling 规则：`Result<i32,i32>` → `Result_i32`（CORE-016 E=i32 压缩，与类型族同名）；非 i32 错误码仍为 `Result_<T>_<E>`。

与既有 `Result_i32`（寄存器化 16B 布局）在 **同名类型族** 下互操作；构造器 `ok_i32`/`err_i32` 优先于裸 struct 字面量。

---

## 3. API（v1）

```su
allow(padding) struct Result<T, E> {
  value: T;
  err: E;
}
```

既有 `ok_i32` / `map_i32` / `and_then_i32` 等保留；新代码可用 `Result<i32,i32> { value: x, err: 0 }`。

泛型辅助：`is_ok_gen<E>`、`unwrap_or_gen<T,E>`（按 `err==0` 判断，对齐 EXC-001 Layer A）。

---

## 4. 金样向量

| case | 文件 | 期望 |
|------|------|------|
| `result_three` | `tests/lang-result-generic/result_three.sx` | (i32,i32)/(u8,i32)/(bool,i32) typeck OK；run exit 0 |
| `with_core_import` | `tests/lang-result-generic/with_core_import.sx` | 与 `Result_i32` API 并存 |

---

## 5. Gate

```bash
./tests/run-lang-result-generic-gate.sh
```

```
shux: [SHUX_LANG010_RESULT_GENERIC] status=ok golden=2 typeck=2 skip=0
```

---

## 6. 非目标（v2）

- `Result<T,E>` E≠i32 与类型族统一（见 CORE-016 §5）
- 三参及以上 struct `Triple<A,B,C>`
- 泛型函数返回 `Result<T,E>` 跨模块链接单态化
