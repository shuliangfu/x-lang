# STD-121 std.elf 最小写入 v1

> 更新时间：2026-06-18  
> 状态：**可用** — ET_REL 最小对象写入 + round-trip gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-elf-write-manifest.tsv` |
| 3 | `./tests/run-std-elf-write-gate.sh` |

---

## 2. API（v1 范围）

| API | 说明 |
|-----|------|
| `write_min_reloc_size` | 计算输出缓冲需求 |
| `write_min_reloc` | 写入 Ehdr + 3 Shdr + `.shstrtab` + `.text` |
| `write_smoke` | 写入后 parse/find/read round-trip C 烟测 |

v1 **不含**完整链接器：无 symtab/rela/phdr 写入；仅最小 ET_REL 对象生成，供工具链/bootstrap 试验。

与只读 API 组合：`write_min_reloc` → `parse_hdr` / `find_section_idx` / `read_sec_byte`。

---

## 3. Gate

```
shux: [SHUX_STD121_ELF_WRITE] status=ok c=1 su=1 skip=0
std-elf-write gate OK
```

向量：`tests/baseline/std-elf-write-vectors.tsv`。
