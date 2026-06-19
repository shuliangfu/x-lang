# SAFE-004 FFI 边界内存契约 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
验收（NEXT SAFE-004）：**C 互操作回归集稳定通过** + manifest + runnable gate。

> 关联：`SAFE-002`（extern 清单）、`SAFE-003`（审计）、`LANG-007`（unsafe）、`std.ffi`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读 `std/ffi/mod.sx` 三个 API |
| 2 | 读本文 §2 契约 C1–C7 |
| 3 | 打开 `tests/baseline/safe-ffi-contract.tsv` |
| 4 | `./tests/run-safe-ffi-contract-gate.sh` |

---

## 2. 契约规则 C1–C7（FFI memory contract）

| 规则 | API | 调用方义务 | 库保证 |
|------|-----|------------|--------|
| **C1-null** | `cstr_len` | 若传 null，接受 -1 | 不解引用 null |
| **C2-empty** | `cstr_len` | 缓冲须 NUL 结尾 | 空串返回 0 |
| **C3-owned** | `cstring_new` | `len≥0`；`ptr` 可 null 当 len=0 | 分配 len+1 字节并写 NUL |
| **C4-copy** | `cstring_new` | `ptr[0..len)` 可读 | 复制后独立 owned |
| **C5-free** | `cstring_free` | 仅释放 `cstring_new` 指针 | `null` 为 no-op |
| **C6-lifetime** | new/free | 每条 owned 指针 **恰好 free 一次** | 不 double-free |
| **C7-extern** | `extern` C 符号 | 调用方保证 ABI/参数合法 | 编译器不校验 C 侧 |

Tier-E `ffi_*_c` 符号登记见 `tests/baseline/safe-unsafe-extern.tsv`；审计见 `safe-unsafe-audit.tsv`（SAFE-003）。

---

## 3. 回归矩阵

权威：`tests/baseline/safe-ffi-contract.tsv`（**8** 条 `case_*` + 聚合 `contract_smoke.sx`）。

| case_id | 规则 | 源文件 |
|---------|------|--------|
| `case_null_cstr` | C1-null | `tests/ffi/contract_null_cstr.sx` |
| `case_cstr_empty` | C2-empty | `tests/ffi/contract_cstr_empty.sx` |
| `case_cstring_null0` | C3-owned | `tests/ffi/contract_cstring_null_len0.sx` |
| `case_roundtrip` | C4-copy | `tests/ffi/contract_cstring_roundtrip.sx` |
| `case_free_null` | C5-free | `tests/ffi/contract_cstring_free_null.sx` |
| `case_owned` | C6-lifetime | `tests/ffi/contract_owned_lifetime.sx` |
| `case_putchar` | C7-extern | `tests/ffi/contract_extern_putchar.sx` |
| `case_smoke` | agg | `tests/ffi/contract_smoke.sx` |

另：`tests/ffi/main.sx` 由 `run-ffi.sh` 覆盖基础路径。

---

## 4. 非目标（v1）

- 不测试故意 UAF/double-free（须 sanitizer 夜跑 SAFE-005）。
- 不覆盖 `std/dynlib` 全量（仅 std.ffi + 最小 extern 样例）。

---

## 5. 验证与门禁

```bash
./tests/run-safe-ffi-contract-gate.sh
./tests/run-ffi.sh   # runnable 原回归
```

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/safe-ffi-contract-v1.md` |
| matrix | `tests/baseline/safe-ffi-contract.tsv` |
| 库 | `tests/lib/safe-ffi.sh` |
| 门禁 | `tests/run-safe-ffi-contract-gate.sh` |

**SAFE-004 状态：定版 ✅**
