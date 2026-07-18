# EXC-003 错误码分层（语言 / 库 / 系统）v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`EXC-001`（Layer A/B/C）、`EXC-002`（panic 边界）、`STD-011`（std 统一）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **三层分离** | 语言语义 / 标准库逻辑 / 平台 errno 不混用 |
| **命名可 grep** | 全局 `error_code_*`，模块 `<mod>_err_*`，段起点 `error_base_*` |
| **区间不冲突** | 新模块从 manifest 分配 base，禁止硬编码侵占 |
| **与 Layer A/B/C 对齐** | Layer A/B 用负逻辑码；Layer C 标量 + 侧车 |

验收（NEXT EXC-003）：**错误码命名规范落地** + manifest + gate。

---

## 2. 三层模型

```
┌──────────────────────────────────────────────────────────────┐
│ L — Language（语言/全局语义）  -1 .. -99    error_code_*      │
├──────────────────────────────────────────────────────────────┤
│ R — Reserved（编译器/语言预留） -100 .. -999  （v1 勿占）       │
├──────────────────────────────────────────────────────────────┤
│ B — Library（标准库模块）      -1000 .. -1499  error_base_*   │
│                                + <mod>_err_*                  │
├──────────────────────────────────────────────────────────────┤
│ S — System（平台）             正整数 errno/GetLastError      │
│                                侧车：fs_last_error() 等       │
└──────────────────────────────────────────────────────────────┘
```

| 层 | 代号 | 数值 | 载体 | 查询方式 |
|----|------|------|------|----------|
| **Language** | L | `0`, `-1..-99` | `Result_i32.err` / `Error.code` | 直接读码 |
| **Reserved** | R | `-100..-999` | — | v1 未分配 |
| **Library** | B | `-1000..-1499` | `Result_i32.err` / `Error.code` | 直接读码 |
| **System** | S | `>0` | **不**写入 Layer A/B | `fs_last_error()` 等 |

**v1 铁律**：`Result_i32.err` 与 `Error.code` **不得**为正数（平台 errno 仅 Layer C 侧车）。

---

## 3. 命名规范

### 3.1 Language（L 层）

| 模式 | 示例 | 说明 |
|------|------|------|
| `error_ok()` | `0` | 成功 |
| `error_code_<semantic>()` | `error_code_invalid()` | 全局语义，`-1..-99` |
| 判定 | `error_code_in_global_range(c)` | gate / 测试用 |

### 3.2 Library（B 层）

| 模式 | 示例 | 说明 |
|------|------|------|
| `error_base_<module>()` | `error_base_io()` | 段起点（每段 100 码） |
| `<module>_err_<semantic>()` | `io_err_timeout()` | 段内偏移 |
| 判定 | `error_code_in_module_span(c, base)` | 段内校验 |

**新模块流程**：

1. 在 `tests/baseline/exc-error-code-layer.tsv` 登记 `base`  
2. 在 `std/error/mod.x` 增加 `error_base_*` 与首批 `<mod>_err_*`  
3. 模块 README 引用本文件 §4  

### 3.3 System（S 层）

| 模式 | 示例 | 说明 |
|------|------|------|
| 侧车 API | `fs_last_error()` | 上次 `fs_*` 失败的平台码 |
| 禁止 | `err_i32(errno)` | errno 不得进入 Layer A/B |
| 判定 | `error_code_is_platform_errno(c)` | `c > 0` |

Layer C 标量（`-1` 失败 + 侧车）在 v1 **保留**；迁移到 B 层时须性能评估（EXC-001 §11）。

---

## 4. 区间表（v1 定版）

| base 函数 | 区间 | 模块 | 首批语义码 |
|-----------|------|------|------------|
| — | `0` | 成功 | `error_ok()` |
| — | `-1..-99` | 全局 | `alloc_fail` / `invalid` / `not_found` |
| — | `-100..-999` | **Reserved** | 编译器/语言 v2 |
| `error_base_io()` | `-1000..-1099` | std.io | `io_err_generic/timeout/cancelled` |
| `error_base_fs()` | `-1100..-1199` | std.fs | `fs_err_generic/not_found` |
| `error_base_net()` | `-1200..-1299` | std.net | （v1 占位 base） |
| `error_base_async()` | `-1300..-1399` | std.async | （v1 占位 base） |
| `error_base_coll()` | `-1400..-1499` | vec/map/heap | `coll_err_generic`（STD-011） |

下一段起点：**-1500**（STD-011 扩展时登记）。

---

## 5. 与 EXC-001 Layer 映射

| EXC-001 Layer | 错误码层 | 典型 API |
|---------------|----------|----------|
| A `Result_i32` | L 或 B | `err_i32(error_code_invalid())` |
| B `Error` | L 或 B | `error_from_code(io_err_timeout())` |
| C 标量 + 侧车 | C + **S** | `fs_open` → `-1` + `fs_last_error()` |

---

## 6. 示例

```su
import("core.result");
import("std.error");

// Layer A + L 层全局码
let r: Result_i32 = err_i32(error_code_not_found());

// Layer A + B 层 io 码
let t: Result_i32 = err_i32(io_err_timeout());

// Layer C + S 层（不经过 Result.err 的正 errno）
// if (fs_open(...) == -1) { let e: i32 = fs_last_error(); ... }
```

---

## 7. 门禁

| 脚本 | 覆盖 |
|------|------|
| `tests/run-error.sh` | 全局 `error_ok` |
| `tests/run-exc-error-code-layer-gate.sh` | manifest + 区间烟测 |
| `tests/exc/error_code_layer.x` | base 顺序 + span  helper |

---

## 8. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/exc-error-code-layer.tsv` |
| 门禁 | `tests/run-exc-error-code-layer-gate.sh` |
| 实现 | `std/error/mod.x` |
| EXC-001 | `analysis/exc-result-error-v1-rfc.md` |

**EXC-003 状态：定版 ✅**（v1 登记五段 base；S 层仅侧车；R 层预留。）
