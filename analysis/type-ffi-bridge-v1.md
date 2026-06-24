# TYPE-004 FFI 类型桥接规则 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与 `codegen.c` `c_type_to_buf`、`SAFE-004` 对齐  
> 关联：`LANG-005`（ABI）、`SAFE-002`（extern 清单）、`LANG-007`（unsafe extern）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 桥接层 F1–F6 |
| 2 | 打开 `tests/baseline/type-ffi-bridge-map.tsv`（**mapping** 权威表） |
| 3 | `./tests/run-type-ffi-bridge-gate.sh` |
| 4 | `./tests/run-ffi.sh` |

---

## 2. 桥接层 F1–F6（FFI type bridge）

权威：`tests/baseline/type-ffi-bridge.tsv`（**6** 条 `layer_*`）。

| 层级 | Shu 表面 | C / typeck | v1 |
|------|----------|------------|-----|
| **F1-scalar-map** | `i32`/`u64`/`f64`/`bool`… | `int32_t`/`uint64_t`/`double`/`int` | ✅ |
| **F2-pointer-bridge** | `*T` | `T*`（递归 `c_type_to_buf`） | ✅ |
| **F3-extern-syntax** | `extern function f(...)` | 无函数体；链接 C 符号 | ✅ |
| **F4-struct-by-value** | 具名 struct | `struct Name` 同布局按值传递 | ✅ |
| **F5-slice-codegen** | `T[]` | `struct shux_slice_<elem>` | ✅（**非**直接 extern 参数） |
| **F6-coercion** | `*T`→`*u8`、`T[N]`→`*T` | typeck 放宽（C `void*` / 衰减） | ✅ |

**interop 原则**：

1. **mapping** 以 `c_type_to_buf` 为准；变更须同步 TSV + gate。
2. `extern` 参数可用 `*u8` 表示 C 侧 **void\*** 语义（任意 `*T` 可传入）。
3. `T[]` 仅在 Shu 内部与 C 生成代码间桥接；跨语言边界优先 `*u8`+`len` 或 `*T`。

```su
extern function putchar(c: i32): i32;  // Shu i32 → C int32_t
```

---

## 3. 类型映射表（mapping）

机器可读：`tests/baseline/type-ffi-bridge-map.tsv`（**12+** 行）。

| shux_type | c_type | extern_ok | 说明 |
|----------|--------|-----------|------|
| `i32` | `int32_t` | yes | 标量 |
| `u32` | `uint32_t` | yes | |
| `i64` | `int64_t` | yes | |
| `u64` | `uint64_t` | yes | |
| `u8` | `uint8_t` | yes | |
| `bool` | `int` | yes | 0/1 |
| `f32` | `float` | yes | 见 LANG-005 f32 ABI |
| `f64` | `double` | yes | |
| `usize` | `size_t` | yes | |
| `isize` | `ptrdiff_t` | yes | |
| `*T` | `<T>*` | yes | 指针递归 |
| `*u8` | `uint8_t*` | yes | void\* 桥接目标 |
| `T[]` | `struct shux_slice_*` | no | 仅 codegen 内部 |

实现锚点：`compiler/src/codegen/codegen.c` `c_type_to_buf`；typeck 放宽见 `typeck.c` call 实参路径。

---

## 4. Golden 用例

| case_id | 文件 | 验证 |
|---------|------|------|
| `case_putchar` | `tests/ffi/putchar.sx` | `i32` 实参调 C `putchar` |
| `case_extern_abi` | `contract_extern_putchar.sx` | extern 声明 + 运行 |
| `case_cstr_u8` | `contract_null_cstr.sx` | `*u8` + `cstr_len` |
| `case_ffi_main` | `tests/ffi/main.sx` | `run-ffi.sh` 聚合 |

内存契约（owned/null）见 **SAFE-004**，不在此重复。

---

## 5. 非目标（v1）

- 自动生成 C 头文件
- `extern struct` 不透明类型全量规范
- C++ name mangling / `extern "C"` 块语法

---

## 6. 验证与门禁

```bash
./tests/run-type-ffi-bridge-gate.sh   # runnable：manifest + FFI bridge hooks
./tests/run-type-ffi-bridge.sh        # 标量/指针烟测
./tests/run-ffi.sh                    # 原 FFI 回归
```

**gate report**：stdout 须含 `type-ffi-bridge gate OK`；失败打印 `type-ffi-bridge FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/type-ffi-bridge-v1.md` |
| manifest | `tests/baseline/type-ffi-bridge.tsv` |
| mapping | `tests/baseline/type-ffi-bridge-map.tsv` |

**TYPE-004 状态：定版 ✅**
