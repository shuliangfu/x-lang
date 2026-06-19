# STD-064：std.elf program header 只读 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：STD-063 `std-elf-deep-v1.md`  
> 关联：`elf64_min_phdr.bin`、工具链只读

---

## 1. 目标

在 STD-063 基础上新增 **program header（Phdr）只读 API**，扩展 `Elf64Hdr.phoff` 字段。

验收：`tests/run-std-elf-phdr-gate.sh` 绿；`min_phdr_apis=2`；C 烟测 `deep_c=1`。

---

## 2. Phdr API

| API | 说明 |
|-----|------|
| `parse_hdr` | 扩展输出 `phoff` / `phnum` |
| `read_phdr` | 读取第 `idx` 个 Phdr |

常量：`ELF_TYPE_EXEC`、`ELF_PT_LOAD`。

---

## 3. 金样向量

金样：`tests/baseline/fixtures/elf64_min_phdr.bin`（120B ET_EXEC）。

| 字段 | 期望 |
|------|------|
| `type` | 2（ET_EXEC） |
| `phnum` | 1 |
| `phoff` | 64 |
| `p_type` | 1（PT_LOAD） |
| `p_offset` | 256（0x100） |

---

## 4. Gate

```bash
./tests/run-std-elf-phdr-gate.sh
```

```
shux: [SHUX_STD064_ELF_PHDR] status=ok phdr_c=1 phdr_su=0 skip=1
```

---

## 5. 联动

- manifest：`tests/baseline/std-elf-phdr.tsv`
- 父门禁：`run-std-elf-deep-gate.sh`
- CI：`tests/run-portable-suite.sh`

---

## 6. 非目标（v2）

- 动态段 / 重定位解析
- ELF32 / 大端
