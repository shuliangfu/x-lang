# std.unicode — Unicode 分类与大小写

**模块路径**：`std/unicode/mod.sx` + `std/unicode/unicode.sx`（F-unicode v2 纯 .sx）  
**对标**：Rust unicode-segmentation / `char` 分类（v1 拉丁 + 预组合 NFC 子集）。

## API 概览

| API | 说明 |
|-----|------|
| `category(rune)` | 字符类别（Letter/Digit/Punct 等，ASCII 表驱动） |
| `is_whitespace` / `is_ascii` | 空白与 ASCII 判定 |
| `to_lower` / `to_upper` | 单码点大小写（拉丁范围） |
| `is_supplementary(rune)` | 增补平面码点（U+10000+） |
| `rune_utf8_len(rune)` | rune 编码为 UTF-8 所需字节数 |
| `nfc_buf(in, in_len, out, cap)` | NFC 规范化（v1 拉丁预组合子集） |
| `grapheme_next(s, len, off)` | 下一字素簇字节数 |
| `case_fold_rune` / `case_fold_buf` | case fold（v1 委托 to_lower） |
| `grapheme_case_smoke()` | C 烟测入口（STD-114） |

## 限制（v1）

- NFC / case_fold 为拉丁子集，非全 Unicode 码表。
- 全量 Unicode 表与完整 NFC/NFD 见 NEXT.md §3 std.unicode 增强项。

## 测试

```bash
./tests/run-std-unicode-nfc-gate.sh
./tests/run-std-unicode-grapheme-case-gate.sh
bash tests/run-unicode.sh
```
