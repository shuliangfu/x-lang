# LANG-009：Option<T> 泛型 struct 完整形态 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：LANG-003 函数泛型单态化；CORE-002 类型族  
> 关联：LANG-010 Result<T,E>、CORE-016 统一

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§5 |
| 2 | `tests/baseline/lang-option-generic.tsv` |
| 3 | `./tests/run-lang-option-generic-gate.sh` |

---

## 2. 闭环 M7–M9（generic struct monomorph）

| 层级 | 能力 | 锚点 |
|------|------|------|
| **M7-syntax** | `struct Option<T> { ... }` | `parser.c` |
| **M8-parse-inst** | `Option<i32>` / `Option<i32> { ... }` mangling | `parser_append_type_inst_mangle` |
| **M9-typeck** | 模板跳过布局 + 单态化物化 | `typeck_materialize_generic_structs` |

v1 支持的具体类型实参：`i32`、`u8`、`*u8`、`bool`。

与既有 `Option_i32` 等类型族 **ABI 兼容**（同名 mangling：`Option<i32>` → `Option_i32`）。

---

## 3. API（v1）

```su
allow(padding) struct Option<T> {
  is_some: bool;
  value: T;
}
```

既有 `some_i32` / `map_i32` 等保留；新代码可用 `Option<i32> { is_some: true, value: x }`。

---

## 4. 金样向量

| case | 文件 | 期望 |
|------|------|------|
| `option_three` | `tests/lang-option-generic/option_three.x` | typeck OK；run exit 0 |
| `with_core_import` | `tests/lang-option-generic/with_core_import.x` | 与 `Option_i32` API 并存 |

---

## 5. Gate

```bash
./tests/run-lang-option-generic-gate.sh
```

```
shux: [SHUX_LANG009_OPTION_GENERIC] status=ok golden=2 typeck=2 skip=0
```

---

## 6. 非目标（v2）

- 多类型参数 struct `Pair<A,B>`  
- 泛型函数返回 `Option<T>`（T 为函数类型参数交叉引用）  
- 跨模块 import 泛型 struct 单态化（仍走 shux-c 子集）
