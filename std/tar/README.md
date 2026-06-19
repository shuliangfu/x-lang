# std.tar — tar 归档

UStar 读写 + 长路径（prefix）+ Pax（STD-038/152）。

## API

| API | 说明 |
|-----|------|
| `read_header` / `write_header` | 512 字节 UStar 头 |
| `append_entry` | 追加文件/目录（`is_dir=1`） |
| `next_entry` / `read_entry_data` | 遍历与读内容 |
| `path_max()` | 最大路径 512 |

长路径：101–255 用 UStar `prefix`；256–512 用 Pax typeflag `'x'`。

## Gate

```bash
./tests/run-std-tar-ustar-gate.sh
./tests/run-std-tar-extended-gate.sh
```
