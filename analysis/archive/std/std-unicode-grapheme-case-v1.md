# STD-114：std.unicode grapheme / case fold v1

> 状态：**定版（v1 拉丁 + 组合附标子集）**

## API

| 名称 | 说明 |
|------|------|
| `grapheme_next` | 下一字素簇字节数（基字符 + U+0300..036F 附标） |
| `case_fold_rune` | 单码点 fold（v1 委托 to_lower） |
| `case_fold_buf` | 缓冲 fold 输出 UTF-8 |
| `grapheme_case_smoke` | C 烟测 |

## 门禁

`./tests/run-std-unicode-grapheme-case-gate.sh`
