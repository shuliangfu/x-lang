# LANG-003 泛型/模板最小闭环 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与 `codegen.c` 单态化、`tests/run-generic.sh` 对齐  
> 关联：`COMP-001`（parser）、`TYPE-004`（FFI）、`LANG-004`（trait 约束）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 闭环层 M1–M6 |
| 2 | 打开 `tests/baseline/lang-generic.tsv` |
| 3 | `./tests/run-lang-generic-gate.sh` |
| 4 | `./tests/run-generic.sh`（单模块 `id<T>` prototype） |

---

## 2. 最小闭环 M1–M6（generic monomorph）

权威：`tests/baseline/lang-generic.tsv`（**6** 条 `layer_*`）。

| 层级 | 能力 | 实现锚点 | v1 状态 |
|------|------|----------|---------|
| **M1-syntax** | `function id<T>(x: T): T` | `parser.c` / `parser.x` | ✅ |
| **M2-typeck** | 类型实参数量与形参绑定 | `typeck.c` generic call | ✅ |
| **M3-monomorph** | 调用点单态化实例生成 | `codegen.c` `codegen_one_mono_instance` | ✅ |
| **M4-local-call** | 同模块 `id<i32>(42)` | `tests/generic/main.x` | ✅ |
| **M5-import-call** | 跨模块泛型 import 调用 | `tests/multi-file-generic/`（**shux-c**） | ✅ prototype |
| **M6-benchmark** | 单态化热路径 microbench | `tests/bench/generic_id_i32.x` | ✅ prototype |

**单态化（monomorph）模型**：编译期为每个 `(template, type_args)` 生成独立 C 函数；**零运行时泛型字典**，与 C++ 模板实例化同类。

```su
function id<T>(x: T): T { return x; }
function main(): i32 { return id<i32>(42); }  // → exit 42
```

**prototype 边界（v1 非目标）**：

- 无 trait / 接口约束（见 LANG-004）
- 无泛型 struct / enum（仅函数模板）
- `.x` seed pipeline 的跨模块泛型单态化仍走 **shux-c**（M5）

---

## 3. 原型目录

`tests/baseline/lang-generic-prototype.tsv` 登记已闭合能力。

| capability | pipeline | 说明 |
|------------|----------|------|
| `mono_local` | shux / shux-c | 单文件 `id<T>` |
| `typeck_arity` | shux / shux-c | 错误实参个数 → typeck error |
| `mono_import` | shux-c | `import` + `id<i32>` |
| `bench_loop` | shux / shux-c | `generic_id_i32.x` 循环调用 |

---

## 4. Golden 用例

| case_id | 文件 | 期望 |
|---------|------|------|
| `case_local_mono` | `tests/generic/main.x` | 编译运行 exit **42** |
| `case_type_args` | `tests/generic/wrong_type_args.x` | typeck 报 `type arguments` |
| `case_import_mono` | `tests/multi-file-generic/main.x` | shux-c 运行 exit **42** |

---

## 5. benchmark prototype

`tests/bench/generic_id_i32.x`：循环 `id<i32>(i)` 累加，用于对比单态化后是否与手写 `i32` 循环同量级（**benchmark** 仅作回归锚点，不绑定绝对耗时）。

```bash
# 本地 smoke（需 native shux）
./compiler/shux tests/bench/generic_id_i32.x -o /tmp/shux_gen_bench && /tmp/shux_gen_bench
```

---

## 6. 验证与门禁

```bash
./tests/run-lang-generic-gate.sh   # runnable：manifest + generic hooks
./tests/run-lang-generic.sh        # 单模块 + 跨模块烟测
./tests/run-generic.sh             # 最小 id<T> 回归
```

**gate report**：stdout 须含 `lang-generic gate OK`；失败打印 `lang-generic FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/lang-generic-v1.md` |
| manifest | `tests/baseline/lang-generic.tsv` |
| prototype | `tests/baseline/lang-generic-prototype.tsv` |

**LANG-003 状态：定版 ✅**
