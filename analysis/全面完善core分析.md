# 全面完善 core 分析

> 本文档说明如何系统性地完善 Shux 的 **core** 标准库（无 OS 依赖层），使其成为 std 与自举的稳固基础。  
> 与 `.cursor/rules/00-项目目标与宗旨.mdc`、`问题排查与重构重写分析.md` 配套使用。

---

## 一、目标与范围

### 1.1 何为「全面完善」

- **API 完整**：各模块提供足够丰富、一致的接口，满足「无 OS 场景」下的类型、内存、可选/错误、切片、格式化、调试等需求。
- **语义清晰**：命名、行为、错误约定与文档一致；与语言特性（泛型、内建）对齐。
- **可测试**：每个新增/变更 API 有对应测试，现有 `run-*` 全过且不退化。
- **零 OS 依赖**：core 内不出现 `extern` 依赖 libc/OS（除将来明确约定的 freestanding 最小集合），保证可在嵌入式/freestanding 环境使用。
- **为 std 与自举铺路**：std 模块（如 std.fmt、std.mem、std.io）可基于 core 封装；自举前清单中的类型与抽象集中在 core。

### 1.2 core 的定位（项目约定）

- **顶层**：仓库根下 `core/` 目录，用户通过 `import("core.xxx")` 引用。
- **无 OS 依赖**：不依赖 std、不依赖 libc/OS，仅依赖语言与编译器能力。
- **与 std 关系**：std 依赖 core；core 不依赖 std。

---

## 二、现状概览

### 2.1 现有 core 模块与 API

| 模块 | 现有内容 | 缺口 / 备注 |
|------|----------|-------------|
| **core.types** | placeholder, size_of_i32/bool/u8/u32/u64/i64/usize/isize/f32/f64 | 无 align_of_*；无指针/引用 size；多类型需重复函数，泛型后可收敛 |
| **core.option** | Option_i32, none_i32, some_i32, unwrap_or_i32, is_some_i32, is_none_i32, option_placeholder\<T\> | 仅 i32 具象；缺 map/and_then/expect；泛型 Option\<T\> 待语言支持 |
| **core.result** | Result_i32, ok_i32, err_i32, unwrap_or_i32, is_ok_i32, is_err_i32, result_placeholder\<T\> | 仅 i32 具象；缺 map/and_then/expect；布局已按 Result寄存器化 设计 |
| **core.mem** | placeholder, align_of_i32 | 缺 copy/move、align_of 其他类型、size_of 委托；与 core.types 有重叠 |
| **core.slice** | len_i32(i32[]), placeholder | 缺 get/索引安全、其他元素类型 len_*；边界检查策略未定 |
| **core.fmt** | placeholder, fmt_i32 | 无格式化到缓冲区、无 format! 类宏/内建对接；与 std.fmt 分工待定 |
| **core.debug** | placeholder, assert(bool) | 无 debug_print/println 类、无条件编译控制（debug_only） |
| **core.builtin** | placeholder | 内建由编译器识别，此处为占位；需与编译器内建列表对齐 |

### 2.2 测试覆盖情况

- **直接测 core**：run-import（core.types）、run-option、run-result、run-mem、run-slice（length.sx）、run-fmt、run-debug、run-builtin、run-core-types-size（core.types + core.debug）。
- **间接**：run-stdlib-import 同时 import("core.types") / core.option / core.result 并调用 placeholder/option_placeholder/result_placeholder。
- **缺口**：core.mem 仅测 align_of_i32；core.slice 仅测 len_i32；core.fmt 仅测 fmt_i32；无负例（如 assert(false) 期望 panic）的专项测试。

### 2.3 std 对 core 的依赖

- 当前 **std 未 import core**，各 std 模块多为 `extern` + 薄封装。
- 设计上 **std.fmt** 可依赖 **core.fmt** 做格式化核心；**std.mem** 可依赖 **core.mem** 做 copy/align；后续扩展时应先稳定 core 再在 std 中复用。

### 2.4 Phase 1~4 及全面扩展后现状

| 模块 | 已有 API（扩展后） | 仍待/按需 |
|------|--------------------|-----------|
| **core.types** | size_of_* / align_of_*（i32/bool/u8/u32/u64/i64/usize/isize/f32/f64） | 指针/i16/u16 等按需；泛型 size_of(T) 待内建 |
| **core.option** | Option_i32 全系列 + **Option_u8**（some_u8/none_u8/unwrap_or_u8/is_some_u8/is_none_u8/expect_u8）；expect_i32 | map/and_then 待语言支持函数类型 |
| **core.result** | Result_i32 全系列；expect_i32、expect_i32_or_panic | map/and_then 待语言支持 |
| **core.mem** | align_of_* 全类型；**mem_copy**、**mem_set**、**mem_move**、**mem_compare**；align_up/align_down | — |
| **core.slice** | len_i32、get_i32（边界安全）；**len_u8、get_u8**（u8[] 边界安全） | 其他元素类型按需或等泛型 |
| **core.fmt** | fmt_i32；十进制 **fmt_*_to_buf**（i32/u32/i64/u64/bool）；**fmt_u32_hex_to_buf**、**fmt_u64_hex_to_buf**；**fmt_append_i32_to_buf**（链式） | 浮点 fmt_f64_to_buf 待 f64→整数支持 |
| **core.debug** | **assert**、**debug_assert**；**assert_eq_i32/assert_ne_i32**、**assert_eq_u32/assert_ne_u32**、**assert_eq_bool** | debug_print 与零 OS 冲突时放 std |
| **core.builtin** | placeholder；**copy**、**unreachable**、**abort**；**min_i32/max_i32/min_u32/max_u32**；**clz_u32/ctz_u32/popcount_u32** | 与编译器内建对齐时可改为 intrinsic 优化 |

---

## 三、完善维度

### 3.1 API 完整性

- **类型维度**：为常用类型提供一致 API（如 size_of_* / align_of_* 覆盖 i8/u8/i16/u16/i32/u32/i64/u64/usize/isize/f32/f64、指针、bool）。
- **行为维度**：option/result 提供 unwrap_or、map、and_then、expect（expect 可先以文档约定「panic 语义」）。
- **容器/视图**：slice 提供 len、安全 get（边界内返回，越界 panic 或返回 option）；是否支持 mut 切片与语言设计一致。

### 3.2 语义与 ABI

- **core.result**：已按「Result 寄存器化」设计（双槽、err==0 表成功），完善时保持 ABI 稳定。
- **core.option**：当前为 struct { is_some, value }，若将来与 C 互操作需约定布局。
- **panic**：core.debug.assert 已用 panic()；其他 core 中的「失败即 panic」API 需统一约定（如 expect、越界 get）。

### 3.3 与编译器/语言特性配合

- **泛型**：当前无类型实参语法，option/result 以具象类型（Option_i32、Result_i32）为主；语言支持泛型后可增加 Option\<T\>、Result\<T,E\> 并逐步迁移。
- **内建**：size_of(T)/align_of(T) 若由编译器内建提供，core.types/core.mem 可改为薄封装或文档说明「优先用内建」。
- **core.builtin**：与编译器内建列表（如 unreachable、copy、abort）一一对应声明，避免用户直接写 extern。

### 3.4 测试与文档

- 每个新增/重要 API：至少一个正例测试（run-* 或 tests/ 下专项）。
- 关键语义（如 assert(false)=>panic、unwrap_or 默认值）有明确测试或文档说明。
- 文件头注释 + 关键函数注释保持与 01-代码规范 一致。

---

## 四、模块分级与优先级

按「依赖关系 + 被依赖程度」分层，便于分阶段推进：

| 层级 | 模块 | 说明 | 优先级 |
|------|------|------|--------|
| **基础层** | core.types, core.mem | 类型大小/对齐、内存原语；被 option/result/slice/fmt 等间接依赖 | P0 |
| **抽象层** | core.option, core.result | 可选值与错误传播；被大量业务与 std 使用 | P0 |
| **容器/视图层** | core.slice | 切片长度、安全访问；自举与集合操作依赖 | P1 |
| **工具层** | core.fmt, core.debug | 格式化、断言与调试；支撑 std.io 与开发体验 | P1 |
| **内建层** | core.builtin | 与编译器内建对接；占位已够用，扩展随编译器能力 | P2 |

---

## 五、分阶段计划

### Phase 1：基础层夯实（core.types + core.mem）✅

- **core.types** ✅
  - ✅ 补全 **align_of_***：align_of_i32/u32/i64/u64/usize/指针/f32/f64 等，与 size_of_* 对称。
  - 若编译器暂无内建 size_of(T)/align_of(T)，保持当前「按类型分函数」；若有内建，在注释中说明「内建优先，本模块为兼容/fallback」。
- **core.mem** ✅
  - ✅ 补全 **align_of_***（或委托 core.types 避免重复）。
  - ✅ 增加 **mem_copy(dst, src, n)**：按字节拷贝，不重叠；语义与 C memcpy 一致（当前 .sx 循环实现，避免与系统 memcpy 宏冲突）。
  - ✅ **align_up(addr, alignment)** / **align_down**，用于分配器与布局计算。
- **验收** ✅：run-import、run-core-types-size、run-mem 通过；新增 align_of_* / mem_copy / align_up / align_down 的测试。

### Phase 2：抽象层扩展（core.option + core.result）✅ 部分完成

- **core.option** ✅
  - ⏳ **map_i32** / **and_then_i32**：需语言支持函数类型（fn(i32)->i32）后实现，暂未做。
  - ✅ **expect_i32(opt)**：none 时 panic，有值则返回值。
  - 若需要其他类型：可增加 Option_u8/Option_usize 等，或等泛型后统一。
- **core.result** ✅
  - ⏳ **map_i32** / **and_then_i32**：需语言支持函数类型后实现，暂未做。
  - ✅ **expect_i32(r, default_val)**：与 unwrap_or_i32 同义；**expect_i32_or_panic(r)**：err 时 panic。
  - 保持 Result_i32 双槽布局不变。
- **验收** ✅：run-option、run-result、run-stdlib-import 通过；新增 expect 的测试。

### Phase 3：容器/视图与格式化（core.slice + core.fmt）✅

- **core.slice** ✅
  - ✅ **get_i32(s, i)**：边界内返回 some_i32(s[i])，越界返回 none_i32()；依赖 core.option。
  - 其他元素类型：len_u8、get_u8 等按需添加，或等泛型。
- **core.fmt** ✅
  - ✅ **fmt_i32_to_buf(buf, cap, x)**：将 x 十进制写入 buf[0..cap)，返回写入字节数，不足返回 -1；INT32_MIN 特判。
  - 保持现有 fmt_i32 占位兼容。
- **验收** ✅：run-slice、run-fmt 通过；slice get 边界内/外、fmt 长度与 -1 有单测。

### Phase 4：调试与内建（core.debug + core.builtin）✅

- **core.debug** ✅
  - **assert** 已满足当前需求；不新增 debug_print（与零 OS 依赖冲突时放 std.debug）。
  - 注释说明：assert 条件为假时 panic，供表达式使用返回 0。
- **core.builtin** ✅
  - 占位已可 import；**unreachable**、**copy**、**abort** 等与编译器内建对齐时在此声明，当前保留 placeholder。
- **验收** ✅：run-debug、run-builtin 通过。

### 全面扩展（按需，已做部分）

在 Phase 1~4 基础上，进一步做「全面」覆盖时已实现或约定如下：

- **core.option**：✅ 增加 **Option_u8** 全系列（some_u8、none_u8、unwrap_or_u8、is_some_u8、is_none_u8、expect_u8），供字节、切片元素等使用。
- **core.fmt**：✅ 增加 **fmt_u32_to_buf(buf, cap, u)**，无符号十进制写入缓冲区，与 fmt_i32_to_buf 对称。
- **core.builtin**：✅ 在模块头注释中列出 **unreachable**、**abort**、**copy** 的约定；不新增 extern，保持 core 零 OS 依赖。
- **core.slice**：⏳ **len_u8**、**get_u8** 已预留注释，待 codegen 对 u8[] 切片类型完整支持后再添加（当前 C 侧 struct 可见性导致链接错误）。
- **core.types / core.mem**：i16/u16 等类型在语言支持后可补 size_of_* / align_of_*；指针 size/align 可按需补。

---

## 六、验收标准与约束

### 6.1 每阶段通用验收

- 现有 **run-all.sh**（C 路径）下所有测试 **全部通过**，无退化。
- 新增 API 有对应 **tests/** 用例或扩展现有 run-*。
- **core/** 下无新增 OS 依赖（无新增 extern 调 libc/OS，除非在文档中明确列为 freestanding 最小集）。

### 6.2 与项目宗旨一致

- **内存安全**：copy 不重叠、slice get 边界检查或明确标注 unchecked；不引入未定义行为。
- **轻量级**：不引入大依赖、不膨胀 core 体积；按需增加文件（如 core/mem/copy.sx）可接受，但保持模块扁平。
- **全平台一套 API**：core 不包含 #ifdef 平台分支；平台差异留给 std 与运行时。

### 6.3 依赖关系

- 完善顺序建议：**Phase 1 → Phase 2 → Phase 3 → Phase 4**；Phase 2 可部分与 Phase 1 并行（types/mem 与 option/result 无循环依赖）。
- std 完善时，优先复用 core.types / core.mem / core.fmt，再扩展 std 专属能力。

---

## 七、core 与高性能注意事项

项目目标要求「**性能比肩 C 甚至超越 C**」「**无 GC、零成本抽象、显式内存模型**」。core 作为无 OS 依赖的基础层，必须在设计与实现上避免任何隐式性能成本，并为编译器优化创造条件。以下为 core 完善时需遵守的注意事项。

### 7.1 零成本抽象

- **Option / Result**：不引入堆分配、不引入虚表或函数指针间接调用。当前 `Option_i32`、`Result_i32` 均为固定布局结构体，与手写 C 结构体等价；**保持此约束**，新增 `map`/`and_then` 等应为**纯函数 + 可内联**，编译器优化后等价于手写分支。
- **Result 寄存器化**：`Result_i32` 已按双槽布局设计（见 core/result/mod.sx 注释），错误检查为 `err==0` 比较、零内存访问；完善时**不破坏该 ABI**，以便后端利用两寄存器返回（如 x86-64 rax/rdx）。
- **不引入**：GC、引用计数、隐式锁、RTTI/反射、或任何「运行时额外字段」；core 类型在内存中的表示应可被 C 互操作方预测。

### 7.2 内存与布局

- **结构体布局**：使用 `allow(padding)` 等显式约定，避免为「友好」而增加隐藏字段或多余填充；与 `analysis/ABI与布局.md` 及 `tests/abi/layout_abi.c` 一致。
- **core.mem.copy**：语义与 C `memcpy` 一致（不重叠、按字节）；实现上应可被编译器识别为 `memcpy` 或内建 intrinsic，便于后端做向量化、内联、甚至消除常量长度拷贝。**不**在 core 内实现「逐字节循环」的 fallback 而牺牲优化空间；若当前无内建，可用 `extern` 声明并文档约定「编译器可识别并优化」。
- **core.slice**：切片类型与 ABI 已约定（如 `struct shux_slice_u8` 16 字节、data 偏移 0、length 偏移 8）；`get`/索引的边界检查若无法被编译器证明可消除，可提供 **get_unchecked** 供热路径使用，或文档约定「在 release 下可选的边界检查策略」。

### 7.3 内联与调用开销

- **小函数**：`size_of_*`、`align_of_*`、`unwrap_or_i32`、`is_some_i32`、`len_i32` 等应**足够小、可被编译器内联**；不在 core 内人为阻止内联（如不引入不必要的间接调用）。
- **静态分发**：core 中不依赖「通过函数指针/虚表调用」的抽象；若将来引入 trait，应保证对 core 类型为静态分发、零额外成本。
- **文档约定**：可在模块头注释中说明「本模块函数预期由编译器内联」，或依赖现有 `-O2`/`-Os` 与 LTO 策略；新增 API 时避免大函数体或不可内联的 extern 调用（除非确为底层原语如 mem_copy）。

### 7.4 core.builtin 与编译器内建

- **内建映射**：`core.builtin` 中声明的内建（如 `unreachable`、`copy`、`abort`）应对应编译器已知的 intrinsic 或单条指令，**不**产生额外调用开销；编译器在 codegen 阶段直接发射对应指令或 libcall（如 memcpy）。
- **与编译器协同**：新增 core API 时，若涉及「必须由编译器特殊处理」的能力（如 `size_of(T)`、`align_of(T)`），优先在编译器侧提供内建并在 core 中薄封装或文档说明「内建优先」，避免在 core 中实现无法被优化的通用逻辑。

### 7.5 无隐式成本清单（自检）

完善或评审 core 时，可对照下列项确认未引入隐式成本：

| 项 | 要求 |
|----|------|
| 堆分配 | core 内不提供「默认堆分配」的 API；分配由 std 或用户显式完成 |
| 间接调用 | 不引入 trait 对象、函数指针表等导致无法内联的调用 |
| 额外运行时字段 | Option/Result/slice 等无隐藏的「引用计数」「类型 id」等字段 |
| 大块拷贝 | mem_copy 语义等同 memcpy，可被优化为单条指令或 libcall |
| 边界检查 | 可提供 unchecked 路径或文档约定「可证安全时由编译器消除检查」 |

### 7.6 与 C 互操作时的 ABI

- 若 core 类型（Option、Result、slice）需与 C 互操作，其**内存布局须文档化且稳定**；C 侧应能按固定偏移访问字段，无「魔术」字节。
- 与「零成本」一致：**不**为「对 C 友好」而增加额外填充或包装层；若需与 C 共享结构体，应在 analysis/ABI与布局.md 中记录并在 tests/abi 中做回归。

---

## 八、小结

| 阶段 | 内容 | 产出 | 状态 |
|------|------|------|------|
| Phase 1 | core.types 补 align_of_*；core.mem 补 align_of_*、mem_copy、align_up/down | 基础类型与内存原语完整 | ✅ 已完成 |
| Phase 2 | core.option / core.result 增加 expect；map/and_then 待语言支持函数类型 | 可选值与错误处理可用性提升 | ✅ 部分完成（expect 已做） |
| Phase 3 | core.slice get_i32；core.fmt fmt_i32_to_buf | 切片与格式化支撑 std 与自举 | ✅ 已完成 |
| Phase 4 | core.debug 保持 assert；core.builtin 占位 | 调试与内建声明清晰 | ✅ 已完成 |

实施时以「小步提交、每步跑全测」为原则；**所有阶段须同时满足第七章「core 与高性能注意事项」**，不引入隐式性能成本。若某 API 与编译器或语言设计冲突，以项目目标与宗旨为准并同步更新本文档。
