# STD-058：std.elf ELF64 只读解析 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：编译器 `compiler/src/asm/platform/elf.x`（写出路径）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-elf-parse.tsv` |
| 3 | `./tests/run-std-elf-parse-gate.sh` |

---

## 2. API（只读）

| API | 说明 |
|-----|------|
| `parse_hdr` | 解析 ELF64 Ehdr 摘要 |
| `read_section` | 读取第 `idx` 个 Shdr |
| `sec_name` | 经 `.shstrtab` 取节名 |

**v1 边界**：仅小端 ELF64；不写 ELF；不解析 program header / 重定位内容。

---

## 3. 错误码

| 码 | 常量 |
|----|------|
| 0 | `ELF_OK` |
| -1 | `ELF_ERR_NULL` |
| -2 | `ELF_ERR_SHORT` |
| -3 | `ELF_ERR_MAGIC` |
| -4 | `ELF_ERR_CLASS` |
| -5 | `ELF_ERR_ENDIAN` |
| -6 | `ELF_ERR_INDEX` |

---

## 4. 金样向量

金样文件：`tests/baseline/fixtures/elf64_min_reloc.bin`（275B ET_REL x86_64）。

| 字段 | 期望 |
|------|------|
| `machine` | 62 (`ELF_MACHINE_X86_64`) |
| `type` | 1 (`ELF_TYPE_REL`) |
| `shnum` | 3 |
| `shoff` | 64 |
| section[1] | `.text`，`size=4` |
| section[2] | `.shstrtab`，`type=3` |

烟测：`tests/std-elf/parse_hdr.x`（Ehdr）、`parse_smoke_ok.c`（C 全路径）。

---

## 5. 门禁

```bash
./tests/run-std-elf-parse-gate.sh
```
