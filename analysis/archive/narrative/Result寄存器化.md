# Result 寄存器化 — ABI 约定与实现

> 本文档约定 Result 类型在 C 后端的返回方式，使满足条件时通过**双寄存器返回**（x86-64 SysV：rax/rdx），实现错误检查零内存访问，为自举与后续性能提供保证。

---

## 一、目标

- **ABI 约定**：Result\<T,E\> 或等价的「双槽」类型，在满足大小与布局约束时，由 C 编译器按**两寄存器返回**（不落内存）。
- **错误检查**：调用方通过第二槽（err）是否为 0 判断成功，无需额外内存访问。
- **与 C 互操作**：布局与 C 结构体一一对应，无隐藏指针，零成本。

---

## 二、x86-64 SysV ABI 简要

- 返回类型 **≤16 字节** 且可分解为两个 ≤8 字节的「槽」时，通过 **RAX**（第一 8 字节）与 **RDX**（第二 8 字节）返回。
- 返回类型 **>16 字节** 时，调用方分配内存并传入隐藏首参（RDI），返回值写入该内存，RAX 返回该指针。

因此：若 Result 类型总大小为 16 字节且布局为两个 8 字节槽，则 C 编译器会使用双寄存器返回。

---

## 三、当前实现：Result_i32（core.result）

### 3.1 布局约定

`core/result/mod.x` 中：

```text
allow(padding) struct Result_i32 {
  value: i32;   // 成功时的值
  _pad1: i32;   // 凑齐第一 8 字节槽
  err: i32;     // 错误码，0 表示成功
  _pad2: i32;   // 凑齐第二 8 字节槽
}
```

- 总大小：16 字节。
- 第一槽：`(value, _pad1)` — 成功时有效值在低 4 字节。
- 第二槽：`(err, _pad2)` — `err == 0` 表示成功，非 0 为错误码。

### 3.2 C 侧对应

编译器生成的 C 结构体（库模块带前缀，如 `core_resultResult_i32`）：

```c
struct core_resultResult_i32 {
  int32_t value;
  int32_t _pad1;
  int32_t err;
  int32_t _pad2;
};
```

该类型作为函数返回类型时，在 x86-64 上由 C 编译器按两寄存器（rax/rdx）返回，无需调用方分配缓冲区。

### 3.3 构造与使用

- **ok_i32(x)**：返回 `{ value: x, _pad1: 0, err: 0, _pad2: 0 }`，调用方从第一槽取 value。
- **err_i32(e)**：返回 `{ value: 0, _pad1: 0, err: e, _pad2: 0 }`，调用方通过 `err != 0` 判断错误。
- **unwrap_or_i32(r, default)**：`r.err == 0 ? r.value : default`，仅寄存器/栈上比较与选择，零内存访问。

### 3.4 代码生成

- 返回语句生成 `return (struct ...){ .value = ..., ._pad1 = 0, .err = ..., ._pad2 = 0 };`，无隐藏指针。
- 函数签名为 `struct core_resultResult_i32 f(...)`，与上述 ABI 一致。

---

## 四、验收与扩展

| 项 | 说明 | 状态 |
|----|------|------|
| ABI 文档 | 本文档约定双槽布局与双寄存器返回 | ✅ |
| Result_i32 实现 | core.result 中 16 字节双槽 + ok/err/unwrap_or | ✅ |
| 代码生成 | 返回类型与 return 表达式均为 struct 字面量，无隐藏参数 | ✅ |
| 测试 | tests/result 验证 ok_i32/err_i32/unwrap_or_i32 行为 | ✅ |
| 泛型 Result\<T,E\> | 待类型实参与泛型标准库完善后，可复用同一双槽约定（T/E 均为寄存器可容纳类型时） | 后续 |

---

## 五、参考

- 自举前置条件：`analysis/自举实现分析.md` §3.2（Result ABI 约定并实现或验证）。
- 实现文件：`core/result/mod.x`、`tests/result/main.x`。
- x86-64 System V ABI：返回类型 ≤16 字节时使用 RAX/RDX。
