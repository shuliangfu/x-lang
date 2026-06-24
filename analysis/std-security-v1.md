# STD-079 std.security v1

> 更新时间：2026-06-18  
> 状态：**可用** — CT 比较 / HKDF / secure_zero / mlock + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-security-manifest.tsv` |
| 3 | `./tests/run-std-security-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `ct_compare` | 常量时间比较（委托 `std.crypto.mem_eq`） |
| `random_key` / `random_salt` | CSPRNG 填充（`std.random.fill_bytes`） |
| `hkdf_sha256` | RFC 5869 HKDF-SHA256 |
| `secure_zero` | 密钥材料安全清零 |
| `sensitive_lock` / `sensitive_unlock` | 可选 mlock（不支持则回退 0） |
| `SensitiveBuf` + `sensitive_buf_*` | 敏感缓冲生命周期 |
| `security_err_*` | 错误码 |

与 `std.crypto`：`ct_compare` 不重复实现，审计路径走 `mem_eq`。

---

## 3. Gate

```
shux: [SHUX_STD_SECURITY] status=ok c_smoke=1 sx=1 skip=0
std-security gate OK
```

向量：`tests/baseline/std-security-vectors.tsv`（RFC5869 HKDF TC1）。
