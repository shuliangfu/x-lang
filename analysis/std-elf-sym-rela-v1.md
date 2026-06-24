# STD-103：std.elf symtab/rela 只读解析 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-elf-sym-rela.tsv`、`tests/baseline/fixtures/elf64_sym_rela.bin`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-elf-sym-rela.tsv` |
| 3 | `./tests/run-std-elf-sym-rela-gate.sh` |
| 4 | 烟测：`tests/std-elf/parse_sym_rela.sx` |

---

## 2. symtab/rela 语义

| API | 说明 |
|-----|------|
| `symtab_entry_count(symtab)` | symtab.size / 24 |
| `rela_entry_count(rela_sec)` | rela.size / 24 |
| `read_sym(ptr, len, symtab, idx, sym)` | 读第 idx 个 `Elf64_Sym` |
| `sym_name(ptr, len, strtab, name_off, buf, buf_len)` | 从 `.strtab` 取符号名 |
| `read_rela(ptr, len, rela_sec, idx, rela)` | 读第 idx 个 `Elf64_Rela`（`sym_idx`/`reloc_type` 自 `r_info` 拆分） |

**结构体**：

- `Elf64Sym`：`name_off`、`bind`、`sym_type`、`shndx`、`value`、`size`
- `Elf64Rela`：`offset`、`sym_idx`、`reloc_type`、`addend`

v1 仅 **x86-64 ET_REL 只读**；不写 ELF、不做链接。

**常量**：`ELF_SHT_SYMTAB`（2）、`ELF_SHT_RELA`（4）、`ELF_R_X86_64_64`（1）。

---

## 3. 实现要点

- C 层：`elf64_read_sym_c` / `elf64_read_rela_c`（`std/elf/elf.sx`）
- 金样：`elf64_sym_rela.bin`（`.text` + `.symtab` + `.strtab` + `.rela.text`，符号 `main`，`R_X86_64_64`）
- 依赖 STD-058/063：`parse_hdr` / `find_section_idx` / `read_section`

---

## 4. 验证与门禁

```bash
make -C compiler ../std/elf/elf.o
./tests/run-std-elf-sym-rela-gate.sh
```
