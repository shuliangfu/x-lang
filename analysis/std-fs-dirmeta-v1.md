# STD-123：std.fs 目录/元数据 API v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：STD-003 文件 IO、std.path 路径拼接

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-fs-dirmeta-manifest.tsv` |
| 3 | `./tests/run-std-fs-dirmeta-gate.sh` |
| 4 | 烟测：`tests/fs/dirmeta_roundtrip.sx` |

---

## 2. 目录/元数据 API（v1）

补齐 readdir/stat/chmod/mkdir 等目录级能力，与现有 open/read/write 路径互补。

| API | 说明 |
|-----|------|
| `FsStatOut` | size/mode/is_dir/is_file/mtime_sec |
| `stat` | 路径 stat；成功 0 |
| `chmod` | 修改权限；成功 0 |
| `mkdir` | 创建目录；mode 如 `mode_dir_default()` |
| `remove_file` / `remove_dir` | 删文件 / 空目录 |
| `dir_open` / `dir_read` / `dir_close` | 目录遍历；read 返回 1/0/-1 |

**权限常量**：`mode_file_default()` = 0644；`mode_dir_default()` = 0755。

v1 **不含**递归删除、watch、扩展属性；Windows chmod 为 `_chmod` 子集。

---

## 3. Gate

```bash
./tests/run-std-fs-dirmeta-gate.sh
```

```
shux: [SHUX_STD123_FS_DIRMETA] status=ok c=1 sx=1 skip=0
std-fs-dirmeta gate OK
```

烟测：mkdir → 写 inner.txt → stat → readdir → unlink → rmdir。

---

## 4. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | 初版：stat/chmod/mkdir/readdir + round-trip gate |
