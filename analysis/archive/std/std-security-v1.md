# STD-079 std.security v1

> 更新时间：2026-08-26  
> 状态：**可用** — CT 比较 / HKDF / secure_zero / mlock + gate honesty

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
| `hkdf` | RFC 5869 HKDF-SHA256（命名规范二次精简；C 实现仍 `security_hkdf_sha256_c`） |
| `secure_zero` | 密钥材料安全清零 |
| `sensitive_lock` / `sensitive_unlock` | 可选 mlock（不支持则回退 0） |
| `SensitiveBuf` + `sensitive_buf_*` | 敏感缓冲生命周期 |
| `err_ok` / `err_invalid` / `err_random` / `err_buffer` | 错误码 |

与 `std.crypto`：`ct_compare` 不重复实现，审计路径走 `mem_eq`。

---

## 3. Gate

**Honesty（2026-08-26）**：prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`；`check` 仅观测（自举期暂停）；`roundtrip.x` exit 0 硬失败（native xlang 在场时禁 soft SKIP）；C smoke 仅观测。报告 `check=`／`run=`／`skip=`。

formal_mod：`mod.x` 前缀 + `security.x` `--bare-impl`；fk0 k24×16 `std_security_*`。

```
xlang: [XLANG_STD_SECURITY] status=ok check=1 run=1 skip=0
std-security gate OK
```

向量：`tests/baseline/std-security-vectors.tsv`（RFC5869 HKDF TC1）。

### Changelog

- 2026-08-26：API 锚对齐产品 `hkdf`／`err_ok`；formal_mod＋fk0；闸 honesty（STD-076 模板）。
