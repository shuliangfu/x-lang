# STD-114：std.unicode grapheme / case fold v1

> 更新时间：2026-08-28  
> 状态：**定版（v1 拉丁 + 组合附标子集）＋ honesty Gate**

## API

| 名称 | 说明 |
|------|------|
| `grapheme_next` | 下一字素簇字节数（基字符 + U+0300..036F 附标） |
| `case_fold_rune` | 单码点 fold（v1 委托 to_lower） |
| `case_fold_buf` | 缓冲 fold 输出 UTF-8 |
| `grapheme_case_smoke` | C 烟测 |

## 门禁

见 **## Gate**。化石报告 `c=`／`x=` 已退役。

## Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；拒 soft SKIP→OK／prefer-c／soft `ensure_std_c_o`／soft auto-make；host-C 仅 prebuilt `std/unicode/unicode.o`＝obs；check＝obs（暂停）；tip 产品 `-o` UNDEF／SEGV＝obs（产品另案）。报告 `run=`／`obs=`／`skip=`（退役 `c=`／`x=`）。STD-082 NFD／NFKC／NFKD API 面缺失＝产品另案。

```bash
./tests/run-std-unicode-grapheme-case-gate.sh
```

```
xlang: [XLANG_STD114_UNICODE_GC] status=ok run=N obs=M skip=K
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.
