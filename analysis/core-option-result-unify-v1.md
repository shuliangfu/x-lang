# CORE-016：泛型 Option/Result 与 core 类型族统一 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：LANG-009 Option<T>、LANG-010 Result<T,E>、CORE-002/003 类型族  
> 关联：EXC-001（E=i32 Layer A）、CORE-002/003 combinator gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§5 |
| 2 | `tests/baseline/core-option-result-unify.tsv` |
| 3 | `./tests/run-core-option-result-unify-gate.sh` |

---

## 2. 统一规则（mangling + ABI）

| 泛型实例 | mangling | 既有类型族 | 说明 |
|----------|----------|------------|------|
| `Option<i32>` | `Option_i32` | `Option_i32` | LANG-009 起已一致 |
| `Option<u8>` | `Option_u8` | `Option_u8` | 同上 |
| `Option<*u8>` | `Option_ptr_u8` | `Option_ptr_u8` | 同上 |
| `Result<i32,i32>` | `Result_i32` | `Result_i32` | **CORE-016** E=i32 压缩 |
| `Result<u8,i32>` | `Result_u8` | `Result_u8` | 同上 |
| `Result<bool,i32>` | `Result_bool` | （物化） | 无既有族；模板物化 |

**压缩规则**：`Result<T, i32>` 仅追加 `_<T>` 后缀，与寄存器化 `Result_i32`/`Result_u8` 同名；typeck 在 demangle 时通过 `typeck_expand_result_e_i32_args` 将 `_i32` 展开为 `(i32,i32)`、`_u8` 为 `(u8,i32)`。

构造器路径：`ok_i32`/`err_i32`/`ok_u8` 等与泛型注解 `Result<i32,i32>` 可互赋。

---

## 3. 金样向量

| case | 文件 | 期望 |
|------|------|------|
| `unify_option` | `tests/core016/unify_option.sx` | `Option<i32>` ↔ `Option_i32` typeck OK |
| `unify_result` | `tests/core016/unify_result.sx` | `Result<T,i32>` ↔ `Result_*` + combinator |

联动：`tests/run-core-option-result-gate.sh`（CORE-002/003 回归）、`run-lang-option-generic-gate.sh`、`run-lang-result-generic-gate.sh`。

---

## 4. Gate

```bash
./tests/run-core-option-result-unify-gate.sh
```

```
shux: [SHUX_CORE016_OPTION_RESULT_UNIFY] status=ok golden=2 typeck=2 skip=0
```

---

## 5. 非目标（v2）

- `Result<T,E>` 非 i32 错误码（E≠i32）与类型族统一
- 泛型 struct 跨 crate 链接单态化 ABI 表
- `Result<bool,i32>` 寄存器化专用布局
