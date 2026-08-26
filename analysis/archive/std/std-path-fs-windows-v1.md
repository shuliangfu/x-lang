# STD-021/022 path/fs Windows 对齐 v1

> 更新时间：2026-08-26  
> 状态：**定版（v1）** · soft→硬绿 honesty（2026-08-26）  
> 关联：`tests/run-std-fs-crossplatform-gate.sh`；live roadmap = `analysis/自举进度.md`（勿复活顶层 NEXT.md）

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-021 | `std.path` 识别 Windows `\`、盘符 `C:\`、UNC `\\`；`path_is_absolute` 三平台规则 |
| STD-022 | `std.fs` 在 Windows 上用反斜杠路径走 CreateFile 句柄；扩展 crossplatform case |

---

## 2. STD-021：`std.path`

### 2.1 分隔符

| API | POSIX | Windows | v1 说明 |
|-----|-------|---------|---------|
| `path_is_sep(c)` | `/` `\` | 同左 | 解析时双分隔符均识别 |
| `path_sep()` | `47` `/` | `92` `\` | 由 `path_sep_c()`（`mod.x` cfg 内联，F-path v1 已删 path.c）返回本机主分隔符 |
| `path_join` 输出 | 本机 `path_sep()` | 同左 | 拼接时按需插入主分隔符 |

### 2.2 `path_is_absolute`（v1）

| 模式 | 示例 | 结果 |
|------|------|------|
| POSIX 根 | `/etc/passwd` | 1 |
| UNC | `\\server\share` | 1 |
| 盘符绝对 | `C:\Users` | 1 |
| 盘符相对 | `C:foo` | 0 |
| 相对 | `foo/bar` | 0 |

### 2.3 烟测

- `tests/path/windows_abs_join.x` — 盘符/UNC/反斜杠 basename（全平台 typeck + runnable）
- 既有 `tests/path/*.x` + `run-path.sh` 保持 POSIX 行为

---

## 3. STD-022：`std.fs`

Windows 分支（`fs.c`）已用 `CreateFileA`；Win32 接受 `/` 与 `\`。

| case | 脚本 | linux | macos | windows |
|------|------|-------|-------|---------|
| `win_path_smoke` | `windows_path_smoke.x` | skip | skip | must |

路径字面量使用 `tests\fs\.win_xplat_tmp`（反斜杠），验证 open/read/write/mmap 句柄路径。

Honesty 闸对 `windows_path_smoke.x` 在双端均可 runnable 硬绿（POSIX 将 `\` 当文件名字节；矩阵 skip 仍留给 fs-crossplatform 策略层）。

---

## 4. Gate

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin-arm64 asm→c 静默 remap）。
- `xlang check` **观测**（自举期暂停闸门 2026-08-05）；CHK002 等不得硬红。
- 产品烟测 `windows_abs_join.x` + `windows_path_smoke.x` **exit 0 硬失败**（有原生 xlang 时禁止 soft SKIP）。
- `run-std-fs-crossplatform-gate.sh` 委托仅观测（不顶硬绿）。
- 报告：`check=`／`path=`／`fs=`／`skip=`（`path=1`＋`fs=1` 为硬绿信号）。

```
xlang: [XLANG_STD_PATH_FS_WIN] status=ok check=0|1 path=1 fs=1 skip=0
std-path-fs-windows gate OK
```

---

## 5. 演进

- `path_clean` 输出规范化盘符大小写；`..` 跨盘符语义
- `fs` 长路径 `\\?\` 前缀
- `path` 与 `std.process` 参数路径互转
- soft residual：aes-gcm nist2／brotli ld／产品红／UNDEF 邻域仍跳；by-value `Set_i32`+MEMORY／asm ld `--export-dynamic` 非软；禁 mega
