# DOC-004 内存安全与异常处理指南 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 读者：编写 Shux 应用与标准库扩展的开发者  
> 深度 RFC：`LANG-007`、`EXC-001/002/003`、`SAFE-002/003`

---

## 1. 阅读路径（约 45 分钟）

| 时段 | 章节 | 产出 |
|------|------|------|
| **0–10 min** | §2 默认安全子集 | 知道 bounds/region/padding 由谁保证 |
| **10–20 min** | §3 何时用 unsafe | 能判断 U1/U2/U3 是否必要 |
| **20–30 min** | §4 错误处理决策 | 能选 Layer A/B/C 与 L/B/S 码 |
| **30–40 min** | §5 panic 边界 | 库代码不对 IO 失败 panic |
| **40–45 min** | §6 实践清单 + §9 自检 | 对照 DO/DON'T 改自己的 PR |

---

## 2. 默认安全子集（S0）

Shux **默认路径**在 S0 内运行，无需 `unsafe` 块（v1 尚无 `unsafe { }` 关键字块）。

| 构造 | 保证 | 违反时 |
|------|------|--------|
| `a[i]` / `s[i]` | 运行时 bounds check | `shux_panic_` |
| `/` `%` | 除零 check | panic |
| `T[]<label>` | 编译期域匹配（TYPE-002） | typeck error |
| struct 布局 | 无隐式 padding | typeck error |
| `Linear(T)` | 线性类型（TYPE-001） | typeck error |

**原则**：业务逻辑应留在 S0；只有 FFI、C 布局镜像、裸地址算术才考虑 U1–U3。

详见 `analysis/lang-unsafe-v1-rfc.md` §2–§3.1。

---

## 3. 何时使用 unsafe 逃逸（U1–U3）

### 3.1 决策树

```
需要与 C struct 布局逐字节一致？
├─ 是 → U1 allow(padding) struct（见 tests/unsafe/allow_padding_ok.sx）
└─ 否 → 需要裸地址 / null？
         ├─ 是 → U2 *T（解引用与长度自证，见 `tests/unsafe/raw_ptr_null.sx`）
         └─ 否 → 需要链接 C 符号？
                  └─ 是 → U3 extern function（见 extern_putchar.sx）
```

### 3.2 规则摘要

| 层 | 语法 | DO | DON'T |
|----|------|-----|-------|
| **U1** | `allow(padding) struct` | AST/C 镜像、文档化 ABI | 普通业务 struct 偷懒加 padding |
| **U2** | `*T` | null 检查后再解引用 | 假设指针永非 null |
| **U3** | `extern function` | 声明与 C 签名一致 | 在 extern 内做复杂业务 |

**清单治理**：新增 public unsafe 面须更新 `safe-unsafe-api.tsv` + `safe-unsafe-audit.tsv`（SAFE-002/003）。

---

## 4. 错误处理：Layer 与错误码

### 4.1 可恢复 vs 不可恢复

```
失败是否可预期且调用方能处理？
├─ 是 → 返回错误（§4.2）
└─ 否 → assert / unreachable / panic（§5）
```

决策树详 `analysis/exc-panic-abort-v1-rfc.md` §2。

### 4.2 返回风格（EXC-001）

| Layer | 类型 | 何时用 | 示例 |
|-------|------|--------|------|
| **A** | `Result_i32` | 新 API，成功值为 `i32` | `ok_i32(n)` / `err_i32(code)` |
| **B** | `Error` | 仅错误码 | `error_from_code(...)` |
| **C** | `i32` 标量 + 侧车 | IO/fs 热路径 | `fs_open` → `-1` + `fs_last_error()` |

**新公开 API 优先 Layer A**；Layer C 保留须有性能理由（EXC-001 §7）。

### 4.3 错误码分层（EXC-003）

| 层 | 区间 | 命名 | 示例 |
|----|------|------|------|
| **L** Language | `-1..-99` | `error_code_*` | `error_code_invalid()` |
| **B** Library | `-1000..-1499` | `error_base_*` / `<mod>_err_*` | `io_err_timeout()` |
| **S** System | 正 errno | 侧车 API | `fs_last_error()` |

**铁律**：`Result_i32.err` **不得**写入正数 errno；Layer C 查侧车。

详 `analysis/exc-error-code-layer-v1.md`。

### 4.4 代码片段

```su
import("core.result");
import("std.error");

// Layer A + 全局码
let r: Result_i32 = err_i32(error_code_not_found());
let v: i32 = unwrap_or_i32(r, 0);

// Layer A + 模块码
let t: Result_i32 = err_i32(io_err_timeout());

// Layer C（不 panic）
// if (fs_open(path, flags) == -1) { let e: i32 = fs_last_error(); ... }
```

烟测：`tests/exc/recoverable_result.sx`、`tests/exc/layer_c_recoverable.sx`、`tests/exc/error_code_layer.sx`。

---

## 5. panic 边界（库开发者必读）

| 规则 | 说明 |
|------|------|
| **R1** | `std.io` / `std.fs` / `std.net` 不对 ENOENT 等可预期失败 panic |
| **R2** | Layer C 失败用 `-1`/`0` + 文档化侧车 |
| **R3** | 仅 `*_or_panic`、`assert*`、`unreachable` 可终止 |
| **R4** | 新组合 API 优先 `Result_i32` |

| 场景 | 推荐 | 避免 |
|------|------|------|
| 文件不存在 | 返回 `-1` + `fs_last_error()` | `panic()` |
| 配置必存在 | `expect_i32_or_panic` / `assert` | 静默忽略 |
| 数组越界（用户输入） | S0 bounds → panic 可接受 | 裸指针绕过检查 |
| 内部不变量违反 | `core.debug.assert` | 返回随机错误码 |

**v1 无 recover**：panic = 进程终止。

---

## 6. 最佳实践清单

### 6.1 DO

- 默认写 S0 代码；slice 域标注清晰。
- IO/资源错误走 Result 或 Layer C + 侧车。
- 新增 `extern` / `allow(padding)` 时登记 SAFE-002/003。
- 错误码用 `error_code_*` 或 `<mod>_err_*`，禁止魔法数字。
- PR 描述写明「拷贝/unsafe/错误层」影响（ZC-007 预留）。

### 6.2 DON'T

- 在库函数里对可预期 IO 失败 `panic()`。
- 把 errno 塞进 `Result_i32.err`。
- 无 `allow(padding)` 依赖 C struct 布局。
- 解引用未验证的 `*T`。
- 删除 SAFE 清单符号而不更新 TSV。

---

## 7. 示例与门禁索引

| 主题 | 示例 | 门禁 |
|------|------|------|
| Result | `tests/result/main.sx` | `run-result.sh` |
| Error | `tests/error/main.sx` | `run-error.sh` |
| panic 边界 | `tests/exc/*.sx` | `run-exc-panic-abort-gate.sh` |
| 错误码分层 | `tests/exc/error_code_layer.sx` | `run-exc-error-code-layer-gate.sh` |
| unsafe 模式 | `tests/unsafe/*.sx` | `run-lang-unsafe-gate.sh` |
| unsafe 清单 | — | `run-safe-unsafe-api-gate.sh` |
| sanitizer | `tests/sanitize/` | `run-sanitize-gate.sh` |

---

## 8. 与 CI 的关系

| Tier | 相关门禁 |
|------|----------|
| Portable | 本文 manifest + EXC/LANG/SAFE hook |
| Full CI | + `run-sanitize-gate.sh`、bootstrap bstrict |

本地快速验收：

```bash
./tests/run-doc-memory-safety-error-gate.sh
./tests/run-exc-panic-abort-gate.sh
./tests/run-lang-unsafe-gate.sh
```

---

## 9. 自检（5 题）

1. 用户输入下标访问应用 S0 还是 U2？→ **S0**（bounds check）。
2. `fs_open` 失败应 panic 还是返回 `-1`？→ **返回 -1**（R1）。
3. `err_i32(2)` 其中 `2` 是 errno，是否正确？→ **否**（S 层走侧车）。
4. 新增 `extern function foo` 要改哪些文件？→ **safe-unsafe-extern.tsv + audit.tsv**。
5. 新 HTTP 客户端 API 优先哪种返回？→ **Layer A Result_i32**（R4）。

---

## 10. 深入阅读

| 主题 | 文档 |
|------|------|
| unsafe 模式 | `analysis/lang-unsafe-v1-rfc.md` |
| Result/Error | `analysis/exc-result-error-v1-rfc.md` |
| panic 边界 | `analysis/exc-panic-abort-v1-rfc.md` |
| 错误码分层 | `analysis/exc-error-code-layer-v1.md` |
| API 清单 | `analysis/safe-unsafe-api-v1.md` |
| 审计流程 | `analysis/safe-unsafe-audit-v1.md` |
| region/linear | `analysis/type-region-v1-rfc.md`、`analysis/type-linear-v1-rfc.md` |

**DOC-004 状态：定版 ✅**（实践指南；RFC 细节以各 EXC/LANG/SAFE 文档为准。）
