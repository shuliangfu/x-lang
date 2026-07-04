# LANG-007 unsafe 语法与边界 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**；**v2 语法与 typeck 已落地**（gate ✅ #88，2026-06-28）  
> 关联：`TYPE-002`（region）、`EXC-002`（panic 边界）、`SAFE-001`（M-1~M-6）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **默认安全** | 普通代码路径有编译期/运行时检查，不依赖程序员记忆 |
| **显式逃逸** | 绕过安全子集须**可识别**的语法/属性（`allow(padding)`、`extern`、裸指针等） |
| **规则可测** | 每种模式有文档 + 烟测 / hook |
| **与 SAFE-002 分工** | v1 定**模式与边界**；API 清单见 `safe-unsafe-api.tsv` |

验收（NEXT LANG-007）：**unsafe 模式具备明确规则** + 示例 + CI 门禁。

---

## 2. 安全分层（v1）

```
Layer S0 — 安全子集（默认）
  bounds / div-zero → panic（UB 收窄）
  region slice 域检查（TYPE-002）
  struct 零隐式 padding（除非 opt-in）

Layer U1 — 布局逃逸
  allow(padding) struct

Layer U2 — 裸指针
  *T（含 null；解引用责任在程序员）

Layer U3 — FFI 边界
  extern function / C 互操作

Layer U4 — 保留
  unsafe 关键字（lexer 已保留；unsafe { } 块 v2）
```

---

## 3. 模式规则（v1）

### 3.1 S0：默认安全

| 构造 | 规则 | 违反时 |
|------|------|--------|
| `a[i]` / `s[i]` | 运行时 bounds check | `shux_panic_`（见 `tests/ub/`） |
| `/` `%` 除零 | 运行时 check | panic |
| `T[]<label>` 域 | 编译期域匹配/防逃逸 | `typeck error` |
| struct 隐式 padding | 编译期拒绝 | `typeck error: implicit padding` |
| `Linear(T)` | 编译期线性检查 | `typeck error`（TYPE-001） |

**原则**：S0 内**不需要**也不允许 `unsafe` 块包裹。

### 3.2 U1：`allow(padding) struct`

```su
allow(padding)
struct WithGap {
  a: u8
  b: i32
}
```

| 规则 | 说明 |
|------|------|
| **须显式前缀** | 仅 `allow(padding)` 紧跟 `struct` 生效 |
| **ABI 责任** | 调用方/FFI 须自行保证布局与 C 一致 |
| **适用场景** | AST 节点、Lexer/Token、与 C 镜像 struct |

无 `allow(padding)` 且存在隐式 padding → **编译失败**（非运行时）。

### 3.3 U2：裸指针 `*T`

```su
let p: *i32 = 0;  // null 合法
```

| 规则 | 说明 |
|------|------|
| **类型** | `*T` 为裸地址；**无** lifetime/region 标注 |
| **null** | 字面量 `0` 可初始化 null |
| **解引用** | v1 无自动 null check；**解引用 null = 程序员责任**（未来 v2 可纳入 `unsafe` 块） |
| **与 slice** | `T[]` 为安全视图；`*T` + 长度须自行保证有效 |

### 3.4 U3：`extern function`（FFI）

```su
extern function putchar(c: i32): i32;
```

| 规则 | 说明 |
|------|------|
| **链接** | 符号由 C/平台提供；`.x` 仅声明 |
| **类型映射** | 参数/返回须与 C ABI 一致（见 TYPE-004 预留） |
| **内存** | 传入 `*u8` + len 时，缓冲区生命周期由调用方保证 |
| **panic** | C 侧 UB 不自动收窄；**边界外行为未定义** |

### 3.5 U4：`unsafe` 关键字（v2 已落地）

- lexer / parser **已保留** `unsafe` 为关键字。
- **v2**：`unsafe { ... }` 块语法已落地（C 前端 `parser.c` + x 路径）；块内允许 U2 `*T` 解引用与 U3 `extern` 调用。
- **v1 历史**：v1 无 `unsafe fn` / `unsafe { }`；S0 内裸解引用/裸 `extern` 由 typeck **硬拒**（`run-lang-unsafe-gate.sh` U4 case）。
- **未闭合**：~~`std/ffi`、`std/sys` 包裹~~ ✅（#89）；bstrict 业务层 / release CI → G-FFI-5 尾声。

---

## 4. 决策树（何时用哪种模式）

```
需要 C 布局/隐式 padding？
├─ 是 → U1 allow(padding) struct + 文档化 ABI
└─ 否 → 显式 padding 字段或 packed struct

需要地址算术 / null？
├─ 是 → U2 *T（须在 `unsafe { }` 内解引用；S0 硬拒）
└─ 否 → slice / 值类型

需要调用 C 函数？
└─ 是 → U3 extern（边界测试见 tests/ffi/）

仅业务逻辑 / IO？
└─ S0 + Result/Error（EXC-001），禁止 panic 可预期错误（EXC-002 R1）
```

---

## 5. 与相关任务衔接

| 任务 | 关系 |
|------|------|
| **SAFE-002** | ✅ API 清单：`tests/baseline/safe-unsafe-api.tsv` + extern drift |
| **SAFE-003** | 新增 U1~U3 构造须审计记录 |
| **TYPE-002** | region 为 S0 子机制，非 optional unsafe |
| **EXC-002** | panic 用于 S0 运行时检查失败，非库 API 默认 |

---

## 6. 烟测矩阵

| mode | 验证 |
|------|------|
| U1 opt-in | `tests/unsafe/allow_padding_ok.x` |
| U1 reject | `tests/unsafe/padding_rejected.x`（compile fail） |
| U2 null ptr | `tests/unsafe/raw_ptr_null.x` |
| U3 extern | `tests/unsafe/extern_putchar.x` |
| U4 unsafe block | `tests/unsafe/` U4 正/负例（S0 拒 / unsafe 内允许） |
| S0 bounds | hook `run-ub.sh` |
| S0 region | hook `run-typeck-region.sh` |
| U1 regression | hook `run-struct.sh` |

矩阵：`tests/baseline/lang-unsafe-api.tsv`  
门禁：`tests/run-lang-unsafe-gate.sh`

---

## 7. 变更流程（v1）

1. 新增 U1~U3 构造 → 更新本文 + 增烟测 + SAFE-003 审计（上线后）
2. ~~启用 `unsafe { }`~~ → **已完成（v2 #88）**；后续语义变更仍须 major bump + RFC 修订
3. 从 S0 移除检查 → **禁止**（须新 unsafe 模式编号）

---

## 8. 索引

| 资源 | 路径 |
|------|------|
| UB 收窄 | `tests/ub/`、`tests/run-ub.sh` |
| region | `analysis/type-region-v1-rfc.md` |
| 指针烟测 | `tests/run-pointer.sh` |
| FFI | `tests/ffi/`、`tests/run-ffi.sh`（若有） |

**LANG-007 状态：v1 定版 ✅；v2 gate ✅（#88）；G-FFI-5（std 包裹 / release CI）未闭合**
