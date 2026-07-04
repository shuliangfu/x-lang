# STD-082 std.unicode normalization v1

> 更新时间：2026-06-18  
> 状态：**可用** — NFD/NFKC/NFKD 基础集 + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-unicode-normalization-manifest.tsv` |
| 3 | `./tests/run-std-unicode-normalization-gate.sh` |
| 4 | 联动 `./tests/run-std-unicode-nfc-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `nfc_buf` | 规范组合（STD-037 已有） |
| `nfd_buf` | 规范分解（v1 拉丁子集） |
| `nfkc_buf` | 兼容组合（v1：NFKD + NFC） |
| `nfkd_buf` | 兼容分解（v1 同 NFD 子集） |
| `norm_form_*` | 形式常量 1..4 |

v1 覆盖与 STD-037 相同的拉丁预组合对（如 `é` ↔ `e`+U+0301）；非 BMP 直通。

---

## 3. Gate

```
shux: [SHUX_STD_UNICODE_NORM] status=ok c_smoke=1 x=1 skip=0
std-unicode-normalization gate OK
```
