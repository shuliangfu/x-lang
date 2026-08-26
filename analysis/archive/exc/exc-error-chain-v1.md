# EXC-004 错误链路追踪 v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）· soft→硬绿（假权威诚实）**  
> 关联：`EXC-001`（Result_i32）、`EXC-003`（码段）、`EXC-005`（CLI/LSP 展示）

> **Honesty 2026-08-24 #12:** top-level DOC retired; live = this archive path.  
> **Gate honesty 2026-08-26:** prefer `xlang_asm` + `XLANG_LINK_XLANG`; check observational (paused); `error_chain_smoke.x` exit0 hard-fail; no soft SKIP→OK when native present; report `check=`／`run=`／`skip=`. Ubuntu asm smoke already exit0 — gate was portable-false-red (prefer `xlang-c` / soft SKIP→OK).
---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **上下文链** | 包装错误时保留根因码（leaf）与外层码（root） |
| **零堆 v1** | `ErrorChain` 固定 4 深度，栈分配 |
| **与 Result 并存** | `Result_i32` 仍单码；链为可选伴随结构 |
| **可演进** | v2 字符串 context / `?` 传播糖 |

验收（NEXT EXC-004）：**错误可附上下文链** + API + 烟测 + gate。

---

## 2. 数据模型（v1）

```su
struct ErrorChain {
  depth: i32;   // 0..4
  c0: i32;      // root（最近 error_chain_wrap）
  c1, c2, c3;  // 向内层；leaf = c[depth-1]
}
```

| 术语 | 含义 |
|------|------|
| **root** | `c0` — 调用方包装码（如 `io_err_timeout`） |
| **leaf** | 最内层 — 根因（如 `fs_err_not_found`） |
| **wrap** | `error_chain_wrap(chain, wrapper)` — 在 root 侧追加 |

**顺序**：`root -> ... -> leaf`（外到内）。

---

## 3. API（std.error）

| 函数 | 说明 |
|------|------|
| `error_chain_empty()` | 空链 |
| `error_chain_from_code(c)` | 单节点 |
| `error_chain_from_result(r)` | 自 `Result_i32.err` |
| `error_chain_wrap(chain, wrapper)` | 包装；超深截断最旧 leaf |
| `error_chain_depth` / `root` / `leaf` / `code_at` | 访问 |

实现：`std/error/mod.x`（`import("core.result")`）。

---

## 4. 使用模式

### 4.1 手动 wrap（v1 推荐）

```su
import("core.result");
import("std.error");

// fs 层失败
let leaf: ErrorChain = error_chain_from_code(fs_err_not_found());
// io 层包装
let chain: ErrorChain = error_chain_wrap(leaf, io_err_timeout());
// 对外仍可用 root 作为 Result 码
let out: Result_i32 = err_i32(error_chain_root(chain));
// 诊断时读 leaf：error_chain_leaf(chain)
```

### 4.2 与 Layer C 侧车组合

```su
// Layer C: fs_open == -1 → plat = fs_last_error()（S 层）
let leaf: ErrorChain = error_chain_from_code(fs_err_generic());
let chain: ErrorChain = error_chain_wrap(leaf, io_err_generic());
// plat 不进 chain；日志单独打印 errno
```

---

## 5. 限制（v1）

| 项 | v1 | v2 预留 |
|----|-----|---------|
| 深度 | 4 | 可配置 / 堆链 |
| 消息 | 仅 i32 码 | 静态/arena 字符串 tag |
| 打印 | 调用方读 `code_at` | EXC-005 统一 stderr/LSP |
| 语法糖 | 无 `?` | try 自动 wrap |

---

## 6. Gate

| 脚本 | 覆盖 |
|------|------|
| `tests/run-exc-error-chain-gate.sh` | manifest + 符号 + honesty smoke |
| `tests/lib/exc-error-chain.sh` | symbols_ok／run_smoke／emit_report |
| `tests/exc/error_chain_smoke.x` | wrap 顺序 + depth（exit0 hard） |

**Honesty contract（2026-08-26）**

| 项 | 规则 |
|----|------|
| compiler | prefer `./compiler/xlang_asm` then `xlang-c`／`xlang`；pin `XLANG_LINK_XLANG` |
| check | observational only（check gate paused 2026-08-05） |
| runnable | `error_chain_smoke.x` exit0 **hard-fail**（native present → no soft SKIP→OK） |
| report | `check=`／`run=`／`skip=` |
| DOC | refuse top-level resurrect；live = `analysis/archive/exc/` |
| product API | short names in `std/error/mod.x`：`chain_empty`／`chain_from_code`／`chain_wrap`／`chain_root`／`chain_leaf`／`chain_depth`／`chain_code_at`／`chain_max_depth`（DOC narrative may still say `error_chain_*`） |

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/exc-error-chain.tsv` |
| 实现 | `std/error/mod.x` |
| EXC-003 码 | `analysis/archive/exc/exc-error-code-layer-v1.md` |

**EXC-004 状态：soft→硬绿 ✅（假权威诚实 · 2026-08-26）**
