# STD-038：std.tar 目录遍历与文件提取 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：既有 `read_header` / `write_header`（UStar 512 字节头）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | 打开 `tests/baseline/std-tar-ustar.tsv` |
| 3 | `./tests/run-std-tar-ustar-gate.sh` |
| 4 | 金样：`tests/tar/ustar_roundtrip.sx` |

---

## 2. 遍历 API

| API | 说明 |
|-----|------|
| `next_entry(buf, len, off_io, name_out, name_cap, size_out, type_out)` | 内存归档迭代；返回 **0** 有条目、**1** 零块结束、**-1** 失败 |
| `type_out` | ASCII typeflag：`'0'` 普通文件、`'5'` 目录 |

v1 **不**解析 GNU longname / pax；路径 ≤100 字节（UStar name 字段）。

---

## 3. 提取 API

| API | 说明 |
|-----|------|
| `read_entry_data(buf, len, entry_off, data_out, data_cap)` | 从 `entry_off`（头块起始）复制普通文件内容；目录返回 **0** |
| `append_entry(buf, buf_cap, off_io, name, name_len, data, data_len, is_dir)` | 向内存缓冲追加条目；`is_dir != 0` 写目录头且无数据块 |

数据块按 **512 字节** 对齐填充；归档结束须由调用方写入 **512 字节零块**（见 round-trip 金样）。

---

## 4. 构建 API

`append_entry` + 既有 `write_header` 覆盖 v1 内存 round-trip。  
后续波次可接 `std.fs` 落盘提取（非 v1 范围）。

---

## 5. 验证与门禁

```bash
./tests/run-std-tar-ustar-gate.sh
```

manifest：`tests/baseline/std-tar-ustar.tsv`

**report** 示例：

```
shux: [SHUX_STD_TAR_USTAR] status=ok rt=1 main=1 skip=0
```

回归：`tests/tar/main.sx`（头读写）、`tests/run-tar.sh`

---

## 6. 非目标（v1）

- 磁盘文件随机访问 / `std.fs` 集成
- pax / GNU 扩展长路径
- 硬链接、符号链接 typeflag
