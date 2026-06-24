# STD-063：std.elf 只读解析深化 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：STD-058 `std-elf-parse-v1.md`  
> 关联：`elf64_min_reloc.bin`、COMP-001 工具链只读

---

## 1. 目标

在 STD-058 三 API 基础上深化 **节名查找** 与 **节体字节只读访问**，扩展 ELF64 头/section 烟测。

验收：`tests/run-std-elf-deep-gate.sh` 绿；`min_deep_apis=2`；金样 `.text` 首字节 **0x90**。

---

## 2. 深化 API

| API | 说明 |
|-----|------|
| `find_section_idx` | 按 NUL 结尾节名查找 Shdr 索引 |
| `read_sec_byte` | 读取节体内偏移 `at` 处单字节 |

新增错误码：`ELF_ERR_NOT_FOUND (-7)`。

---

## 3. 金样向量（深化）

金样：`tests/baseline/fixtures/elf64_min_reloc.bin`（275B）。

| 字段 | 期望 |
|------|------|
| `find_text_idx` | 1（`.text`） |
| `text_byte0` | 144（0x90） |
| `shstrtab_idx` | 2（`SHT_STRTAB`，金样按索引） |

烟测：`elf64_sections_deep_smoke_c`（C）、`parse_sections.sx`（.sx 可选）。

---

## 4. Gate

```bash
./tests/run-std-elf-deep-gate.sh
```

```
shux: [SHUX_STD063_ELF_DEEP] status=ok deep_c=1 deep_sx=0 skip=1
```

无 native `shux` 时 manifest 仍须绿；C 烟测须过。

---

## 5. 联动

- manifest：`tests/baseline/std-elf-deep.tsv`
- 向量：`tests/baseline/std-elf-deep-vectors.tsv`
- 父门禁：`run-std-elf-parse-gate.sh`
- CI：`tests/run-portable-suite.sh`

---

## 6. 非目标（v2）

- program header / 重定位解析
- 大端 / ELF32
- 写 ELF / 链接编辑
