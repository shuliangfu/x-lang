# STD-152：std.tar 目录/长路径/Pax v1

> 更新时间：2026-08-28（honesty residual XLANG fallthrough／auto-make →硬绿）· 原稿 2026-06-18  
> 状态：**定版（v1.2）** · Gate honesty residual XLANG fallthrough／auto-make →硬绿  
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

Honesty residual（2026-08-28）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- 显式坏 `XLANG`／缺 native **硬 die**（拒 XLANG fallthrough／soft auto-make／prefer-c／soft SKIP→OK／soft `ensure_std_c_o` 重建／extra CLI `.o`）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `long_path_dir.x` 产品 `-o` **exit 0 硬失败**（硬绿信号＝`run=`）
- Host-C archaeology **仅观测**（现成 `std/tar/tar.o` only；拒 ensure／auto-make 重建；不传 extra CLI `.o`；C smoke 文件存在仍 TSV 必有，compile/run 非绿）
- 报告行：`run=`／`obs=`／`skip=`（退役 `check=`／`c=`／`x=` 当硬绿）
- 禁顶层 DOC 复活（live = `analysis/archive/std/`）
- API 锚在 `mod.x`；C 符号在 `tar.x`（`MOD_X`／`TAR_X` 不得二次覆盖）
- 保留 `## 4. Gate`（Pax 在 §2；勿改成 `## 5. Gate`）

manifest：`tests/baseline/std-tar-extended.tsv`

```
xlang: [XLANG_STD_TAR_EXTENDED] status=ok run=1 obs=0|1|2 skip=0
std-tar-extended gate OK
```

烟测：`long_path_dir.x` — 内存 prefix／Pax／目录往返。

回归：保留 `tests/run-std-tar-ustar-gate.sh`（短路径 round-trip 不破）。F-tar v1／v2 仍硬委托本闸（须保持 exit 0）。

### 4.1 Changelog

- 2026-08-26：Honesty v1.1（prefer asm；check／C 观测；TSV section 对齐 `## 4. Gate`；报告 `check=`／`c=`／`x=`）。
- 2026-08-28：Honesty residual v1.2（拒 XLANG fallthrough／auto-make／bootstrap-link／ensure 重建／extra CLI `.o`；报告 `run=`／`obs=`／`skip=`；未啃产品 `std/tar`）。

---

## 5. 非目标（v1）

- GNU `@LongLink` / `@K` 键
- 符号链接、硬链接 typeflag
- 磁盘 `std.fs` 落盘提取
