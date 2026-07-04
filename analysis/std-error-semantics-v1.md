# STD-158 跨模块错误语义统一 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` STD-158、`STD-011`、`STD-020`

---

## 1. 目标

在模块码段（`error_base_*` / `<mod>_err_*`）之上，提供**跨模块可比较**的语义类，便于 io/net/http/async 统一处理超时、取消、未找到等路径。

| 语义类 | 常量 | 典型码 |
|--------|------|--------|
| 无/未知 | `error_sem_none()` | `0`、未登记负码 |
| 超时 | `error_sem_timeout()` | `io/net/http_err_timeout` |
| 取消 | `error_sem_cancelled()` | `io/net/http_err_cancelled` |
| 未找到 | `error_sem_not_found()` | `fs_err_not_found`、`error_code_not_found` |
| 资源 | `error_sem_resource()` | `error_code_alloc_fail` |
| 无效 | `error_sem_invalid()` | `error_code_invalid` |
| 通用 | `error_sem_generic()` | 各模块 `*_err_generic` |

---

## 2. API

- `error_semantic_class(code)` — 映射到语义类
- `error_is_timeout` / `error_is_cancelled` / `error_is_not_found` — 布尔探测（1/0）
- `error_recommend_retry(code)` — v1 仅超时返回 1

Cookbook **ERR-02**：`examples/cookbook/error_semantic_class.x`

---

## 3. manifest

- `tests/baseline/std-error-semantics.tsv`
- 与 `std-error-unify.tsv` 互补：unify 管码段注册，semantics 管跨模块语义

---

## 4. 验收

- 烟测：`tests/std/error_semantics_smoke.x`
- 门禁：`tests/run-std-error-semantics-gate.sh`
- 报告：`std-error-semantics gate OK`
