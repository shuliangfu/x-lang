# LANG-004 trait / 接口约束语义 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与 `typeck.c` 阶段 7.2、`tests/run-trait.sh` 对齐  
> 关联：`LANG-003`（泛型）、`std/io` Reader/Writer **interface**、`TYPE-004`（FFI）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 语义层 T1–T6 |
| 2 | 打开 `tests/baseline/lang-trait.tsv` |
| 3 | `./tests/run-lang-trait-gate.sh` |
| 4 | `./tests/run-trait.sh`（`Double` trait + `i32` impl） |

---

## 2. 语义层 T1–T6（trait = interface 约束）

权威：`tests/baseline/lang-trait.tsv`（**6** 条 `layer_*`）。

| 层级 | 能力 | 实现锚点 | v1 状态 |
|------|------|----------|---------|
| **T1-syntax-trait** | `trait Name { function m(self): T; }` | `parser.c` `parse_one_trait` | ✅ |
| **T2-syntax-impl** | `impl Trait for Type { ... }` | `parser.c` impl 块 | ✅ |
| **T3-typeck-impl-block** | impl 须实现 trait 全部方法且返回类型一致 | `typeck.c` §impl 校验 | ✅ |
| **T4-method-resolution** | `expr.method(args)` 按接收者类型查 impl | `typeck.c` method_call | ✅ |
| **T5-error-no-impl** | 无 impl 时 `no impl for type` | `method_no_impl.x` | ✅ |
| **T6-self-dispatch** | impl 方法首参为 `self`，调用自动传入接收者 | codegen method_call | ✅ |

**术语**：源码关键字为 **trait**；标准库文档中的 **interface**（如 Reader/Writer）指同一套「方法表 + impl」模型，v1 不另设 `interface` 关键字。

```su
trait Double { function double(self): i32; }
impl Double for i32 {
  function double(self: i32): i32 { return self * 2; }
}
function main(): i32 { return 21.double(); }  // → exit 42
```

**constraint（约束）边界（v1 非目标）**：

- 无 trait 泛型参数 / 关联类型
- 无跨模块 trait 对象（vtable 动态派发）
- `.x` seed pipeline 不解析 trait（见 `runtime.c` `content_has_generic_or_trait`）→ 须 **shux / shux-c**

---

## 3. typeck 规则

目录：`tests/baseline/lang-trait-typeck.tsv`（**4** 条错误 **constraint**）。

| rule_id | 触发场景 | 错误子串 |
|---------|----------|----------|
| `no_impl` | 类型无对应 impl 却调用方法 | `no impl for type` |
| `unknown_trait` | `impl` 引用未定义 trait | `impl for unknown trait` |
| `missing_method` | impl 未实现 trait 某方法 | `missing method` |
| `return_mismatch` | impl 方法返回类型与 trait 不符 | `return type mismatch` |

实现：`find_trait_def`、`typeck` impl 块循环、`method_call` 解析（`resolved_impl_func`）。

---

## 4. Golden 用例

| case_id | 文件 | 期望 |
|---------|------|------|
| `case_method_call` | `tests/trait/main.x` | 编译运行 exit **42** |
| `case_no_impl` | `tests/trait/method_no_impl.x` | typeck `no impl for type` |
| `case_missing_method` | `tests/trait/impl_missing_method.x` | typeck `missing method` |

---

## 5. 非目标（v1）

- trait 作为类型约束（`fn f<T: Trait>`）— 见 LANG-003 + LANG-004 v1.1
- 默认 impl / 孤儿规则放宽
- trait 方法默认实现体

---

## 6. 验证与门禁

```bash
./tests/run-lang-trait-gate.sh   # runnable：manifest + trait hooks
./tests/run-lang-trait.sh        # trait 烟测矩阵
./tests/run-trait.sh             # Double/i32 最小回归
```

**gate report**：stdout 须含 `lang-trait gate OK`；失败打印 `lang-trait FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/lang-trait-v1.md` |
| manifest | `tests/baseline/lang-trait.tsv` |
| typeck 目录 | `tests/baseline/lang-trait-typeck.tsv` |

**LANG-004 状态：定版 ✅**
