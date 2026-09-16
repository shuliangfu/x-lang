# CORE-010 core.fmt usize/isize/指针格式化 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` CORE-010、`core/fmt/mod.x`、`std/fmt/mod.x`
> **Honesty 2026-08-24 #11:** top-level DOC retired; live = archive/core/.  
> **Hard-green 2026-08-25:** smoke uses live `fmt_*_to_buf` long names; gate runnable hard-fail (check still observational / paused).

---

## 1. 目标

补齐 64 位宽度类型与指针的 `fmt_*_to_buf` 写入路径，供调试输出、日志与 std.fmt 重导出使用。

| API | 格式 | 说明 |
|-----|------|------|
| `fmt_usize_to_buf` | 十进制 | 64 位环境下委托 `fmt_u64_to_buf` |
| `fmt_isize_to_buf` | 十进制 | 64 位环境下委托 `fmt_i64_to_buf` |
| `fmt_ptr_to_buf` | `0x` + 小写十六进制 | null → `"0x0"` |

---

## 2. 边界行为（金样）

| 场景 | 期望 |
|------|------|
| `fmt_usize_to_buf(buf, cap, 0)` | `"0"`，len=1 |
| `fmt_usize_to_buf(buf, cap, 42)` | `"42"`，len=2 |
| `fmt_usize_to_buf(buf, 1, 99)` | -1（容量不足） |
| `fmt_isize_to_buf(buf, cap, -7)` | `"-7"`，len=2 |
| `fmt_isize_to_buf(buf, cap, INT64_MIN)` | 20 字节 `"-9223372036854775808"` |
| `fmt_ptr_to_buf(buf, cap, null)` | `"0x0"`，len=3 |
| `fmt_ptr_to_buf(buf, cap, &x)` | `"0x"` + 地址十六进制 |
| `fmt_ptr_to_buf(buf, 2, p)` | -1（至少需 3 字节） |

---

## 3. 与 std.fmt 关系

- `std.fmt` 重导出上述三函数，无额外拷贝。
- 指针格式仅供调试；不保证跨进程可解析为有效地址。

---

## 4. 验收

- manifest：`tests/baseline/core-fmt-widths.tsv`
- typeck：`xlang check tests/fmt/widths.x`
- runnable：gate 内链接烟测
- 报告：`xlang: [XLANG_CORE_FMT_WIDTHS] status=ok`

---


## Gate

```bash
./tests/run-core-fmt-widths-gate.sh
```

**Honesty (2026-08-28)**：prefer asm + `XLANG_LINK_XLANG`；显式坏 XLANG／缺 native 硬 die；拒 soft SKIP→OK／soft auto-make／prefer-c；产品 `-o` 硬绿（或 tip 残＝obs）；`xlang check`＝obs（暂停闸）；报告 `run=`／`obs=`／`skip=`。

**gate report**：stdout 须含 `core-fmt-widths gate OK`；失败打印 `core-fmt-widths gate FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/archive/core/core-fmt-widths-v1.md` |
| manifest | `tests/baseline/core-fmt-widths.tsv` |

**状态：定版 ✅（honesty soft→硬绿）**

## 5. 演进

- CORE-011：f64 NaN/Inf 与精度策略。
