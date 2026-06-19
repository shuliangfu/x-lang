# core 完善度与性能分析

> 基于当前代码与 `全面完善core分析.md` 的对照分析；结论与可优化项。

---

## 一、core 是否已「全部完善」

### 1.1 按模块完成度（当前实现 vs 分析文档）


| 模块               | 已完成                                                                                                                             | 仍待/按需                                       | 结论         |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- | ---------- |
| **core.types**   | size_of_* / align_of_*（i32/bool/u8/u32/u64/i64/usize/isize/f32/f64）；**size_of_pointer / align_of_pointer**（64 位为 8）             | i16/u16 待语言支持；泛型 size_of(T)/align_of(T) 待内建 | ✅ 在当前语言下已齐 |
| **core.mem**     | align_of_* 全类型（含 pointer）；mem_copy、mem_set、mem_zero、mem_move、mem_compare、mem_swap；is_alignment_power_of_two；align_up/align_down | —                                           | ✅ 已齐       |
| **core.option**  | Option_i32 / Option_u8 全系列（some/none/unwrap_or/is_some/is_none/expect、or/and）                                                   | map/and_then 待函数类型                          | ✅ 具象类型已齐   |
| **core.result**  | Result_i32 全系列（ok/err、unwrap_or、is_ok/is_err、expect、expect_i32_or_panic、or/and）                                                 | map/and_then 待函数类型                          | ✅ 具象类型已齐   |
| **core.slice**   | len_i32、get_i32；**len_u8、get_u8**（边界安全）                                                                                         | 其他元素类型按需或等泛型                                | ✅ 常用类型已齐   |
| **core.fmt**     | fmt_i32；十进制 fmt_*_to_buf（i32/u32/i64/u64/bool/f64）；十六进制 u32/u64；fmt_append_i32_to_buf、fmt_append_i64_to_buf                             | —                                               | ✅ 已齐（含浮点）  |
| **core.debug**   | assert、debug_assert；assert_eq/assert_ne（i32/u32/bool）                                                                           | debug_print 放 std                           | ✅ 已齐       |
| **core.builtin** | placeholder；copy、unreachable、abort；min/max（i32/u32）；clz_u32、ctz_u32、popcount_u32                                                | 与编译器内建对齐时可改为 intrinsic                      | ✅ 已齐       |


### 1.2 结论：在「当前语言与编译器能力」下已全部完善

- **必须依赖语言/编译器才能做的**（不算缺口）：
  - **map/and_then**（option/result）：需函数类型（如 `fn(i32)->i32`）。
  - **泛型 size_of(T)/align_of(T)**：需编译器内建或类型实参。
  - **i16/u16**：需词法 + AST + typeck + codegen 支持。
- **其余**：types、mem、option、result、slice、debug、builtin、fmt 的 API 与测试均已到位。

---

## 二、性能上可优化项

以下与 `全面完善core分析.md` 第七章「core 与高性能注意事项」一致，按优先级列出可做项。

### 2.1 编译器侧（codegen / 内建）


| 项                                 | 现状                                    | 建议                                                                                                                                                                | 收益                         |
| --------------------------------- | ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| **mem_copy / mem_set / mem_move** | .sx 循环；**codegen 已映射**为 __builtin_memcpy/memset/memmove | 同上 | ✅ 已实现 |
| **builtin_intrinsic_name**        | **已实现**：mem_* + core.builtin 的 copy→__builtin_memcpy、unreachable→__builtin_unreachable、abort→__builtin_abort | 同上 | ✅ 已实现；小函数零开销、冷路径不拖累热点 |
| **size_of_ / align_of_**         | **已实现**：core.types/core.mem 的 size_of_*、align_of_* 生成时加 inline，便于 cc 内联与常量折叠 | 同上 | ✅ 已实现 |


### 2.2 core 实现侧（保持零成本）


| 项                 | 现状                                    | 建议                                                                                     | 收益                 |
| ----------------- | ------------------------------------- | -------------------------------------------------------------------------------------- | ------------------ |
| **mem_copy 实现**   | .sx 内循环；**codegen 已映射**：对 core_mem_mem_copy/mem_set/mem_move 的调用改为 __builtin_memcpy/__builtin_memset/__builtin_memmove | ✅ 已实现（codegen 侧）；core 保持 .sx 实现 | 大块拷贝由 cc 优化/向量化      |
| **slice 热路径**     | 已有 get_i32 / get_u8（边界安全）；**已增加 get_i32_unchecked / get_u8_unchecked**（越界未定义，调用方保证 i < len） | ✅ 已实现；文档约定「仅在对索引已证明安全时使用」 | 热点循环可省边界检查           |
| **Option/Result** | 已为固定布局、无堆、无虚表；**codegen 已对 core.option/core.result 函数加 inline 提示** | ✅ 已实现（codegen 侧）；map/and_then 待函数类型                                                              | 小函数更易被 cc 内联       |


### 2.3 构建与链接

| 项            | 建议 / 现状 |
| ------------ | ---------------------------------------------- |
| **LTO**      | ✅ 已实现：shuc 支持 **-flto**，或环境变量 **SHUX_LTO=1**；非 -O0 时向 cc 传 -flto，便于跨模块内联。 |
| **优化级别**     | ✅ 已实现：默认 **-O2**（-O 0\|2\|s）；release 建议 `-O 2` 或 `-O 2 -flto`。 |
| **panic 路径** | 已用 __builtin_expect(!!(cond),0) 等；可保持，避免分支预测惩罚。 |


### 2.4 不做或慎做的

- **不在 core 内用 extern memcpy**：与部分环境（如 macOS）的 memcpy 宏冲突，已由 .sx 循环 + 后端替换解决。
- **不引入「可选」边界检查**：当前 get 返回 Option 已足够；unchecked 仅作为可选扩展、文档约束严格。
- **不为了「好内联」在 core 里加编译器魔法**：优先在 codegen 中统一处理内建/内联，core 保持纯 .sx 实现。

---

## 三、小结

- **完善度**：在现有语言与编译器下，core 已按分析文档**全部完善**；仅 map/and_then、泛型 size_of(T)、i16/u16 依赖后续语言/编译器能力。
- **性能**：零成本抽象与布局已满足；codegen 已实现 mem_*→builtin、core.builtin copy/unreachable/abort→builtin、core.types/core.mem 的 size_of_*/align_of_* 加 inline；slice 的 **get_*_unchecked** 已在 core 中实现。

