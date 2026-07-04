# STD-152：std.tar 目录/长路径/Pax v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：STD-038 `next_entry`/`append_entry` 基础遍历

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | 打开 `tests/baseline/std-tar-extended.tsv` |
| 3 | `./tests/run-std-tar-extended-gate.sh` |
| 4 | 金样：`tests/tar/long_path_dir.x` |

---

## 2. 长路径策略

| 路径长度 | 策略 |
|----------|------|
| ≤100 字节 | 仅 UStar `name` 字段 |
| 101–255 字节 | UStar `prefix` + `name` 拆分（末级 `/` 为界） |
| 256–512 字节 | Pax typeflag `'x'` + `path=` 记录 + 数据头 |

`read_header` / `next_entry` 输出 **完整路径**（prefix 已拼接）。  
`next_entry` 遇 Pax 块自动跳过并解析 `path` 键。

常量见 `std/tar/mod.x`：`TAR_TYPE_FILE` / `TAR_TYPE_DIR` / `TAR_TYPE_PAX`、`TAR_MAX_NAME`、`TAR_MAX_PATH_USTAR`、`path_max()`。

---

## 3. 目录遍历

`append_entry(..., is_dir=1)` 写 typeflag `'5'`，与 STD-038 一致。  
长目录名同样走 prefix / Pax 策略。

---

## 4. Gate

```bash
./tests/run-std-tar-extended-gate.sh
```

manifest：`tests/baseline/std-tar-extended.tsv`

**report** 示例：

```
shux: [SHUX_STD_TAR_EXTENDED] status=ok c=1 x=1 skip=0
```

回归：保留 `tests/run-std-tar-ustar-gate.sh`（短路径 round-trip 不破）。

---

## 5. 非目标（v1）

- GNU `@LongLink` / `@K` 键
- 符号链接、硬链接 typeflag
- 磁盘 `std.fs` 落盘提取
