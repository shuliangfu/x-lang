# analysis/ — 文档地图

> 维护约定：日常只改 **活文档**；历史工单与过时设计文在 **`archive/`**。

## 活文档（根目录）

| 文档 | 用途 |
|------|------|
| [自举进度.md](./自举进度.md) | **长期仪表盘**（每波必改） |
| [当前进度.md](./当前进度.md) | **当天快照**（每波必改） |
| [自举方法.md](./自举方法.md) | Cap / R / L / M 方法 |
| [自举步骤.md](./自举步骤.md) | 可执行闸门 |
| [自举验证.md](./自举验证.md) | **验证手册**（日常 L2/L3、L4 真冷、双端、bstrict 照抄；防假绿） |
| [问题分析文档.md](./问题分析文档.md) | 产品/大债地图（默认不改） |
| [IR核心设计.md](./IR核心设计.md) | IR v4 架构冻结 |
| [安全路线.md](./安全路线.md) · [FFI隔离.md](./FFI隔离.md) · [lang-unsafe-v1-rfc.md](./lang-unsafe-v1-rfc.md) | 安全 / FFI |
| [std标准库全量清单与优先级.md](./std标准库全量清单与优先级.md) | std 总表 |
| [全面异步架构-分析与准备.md](./全面异步架构-分析与准备.md) | **Zig 级全面异步 / 无染色 / Io 注入**：现状差距、分阶段路径、自举期准备与禁令（2026-07-21） |
| [xlang-项目重命名重构分析.md](./xlang-项目重命名重构分析.md) | **Shux→Xlang 全库重命名**（文档/CLI/Env/ABI）；主域 **`xlang.dev`**；自举暂停至 R3 验收 |
| [build-x-强大配置能力分析.md](./build-x-强大配置能力分析.md) | **build.x + shux.toml**：正交架构、**现状校准**、强大且易写易用路径（M0–M6 / 域 A·B） |
| [shux-toml-实现分析.md](./shux-toml-实现分析.md) | shux.toml 实现阶段（配置层；与 build.x 互补；将随 xlang 重命名） |
| [G-02e-*.md](./G-02e-physical-zero-c.md) · [G-02f-*.md](./G-02f-L2-x-o-pilot.md) · [G-07-*.md](./G-07-selfhost-release.md) | 去 C / 自举发布闸门 |
| [ABI与布局.md](./ABI与布局.md) · [X-ABI-设计分析.md](./X-ABI-设计分析.md) · [内存契约.md](./内存契约.md) · [UB与未定义行为.md](./UB与未定义行为.md) · [零libc产品策略.md](./零libc产品策略.md) | ABI / 契约 |
| [doc-selfhost-architecture-v1.md](./doc-selfhost-architecture-v1.md) · [doc-memory-safety-error-v1.md](./doc-memory-safety-error-v1.md) · [comp-wpo-v1.md](./comp-wpo-v1.md) | 仍引用的专项 |

### 自举进度日归档（**保留，不删**）

- [自举进度-归档-2026-07-17.md](./自举进度-归档-2026-07-17.md)
- [自举进度-归档-2026-07-16.md](./自举进度-归档-2026-07-16.md)
- [自举进度-归档-2026-07-14.md](./自举进度-归档-2026-07-14.md)
- [自举进度-归档-2026-07-13.md](./自举进度-归档-2026-07-13.md)

## 归档 `archive/`（历史，只读）

已从根目录移入；**需要考古时再打开**，默认勿当现行真源。

| 子目录 | 内容 |
|--------|------|
| `archive/phase/` | phase-* 阶段完成票 |
| `archive/std/` | std-*-v1 模块票 |
| `archive/boot/` | boot-* 自举票 |
| `archive/comp/` `core/` `doc/` … | 编译器/core/文档等工单 |
| `archive/narrative/` | 过时/重叠设计长文 |
| `archive/other-tickets/` | 其它 `-vN` 票 |
| `archive/tu_contracts/` | thin/seed **TU 符号合同**（`.contract.md` + `.json`；G-02f 试点快照） |

## 清理策略（2026-07-18）

- **可删历史工单**：已迁入 `archive/`（约 550+ 篇）。
- **TU 合同**：`archive/tu_contracts/`（原根下 `tu_contracts/`）。
- **自举进度日归档**：按产品约定 **保留在 analysis 根目录**。
- 权威自举方法/步骤：analysis 内 `自举方法.md` / `自举步骤.md`。

### 为何归档后根目录又冒出一堆文件？

`.gitignore` 曾写：

```text
analysis/*
!analysis/*.md
```

含义是：**只跟踪 analysis 根下的 `*.md`**，**子目录（含 `archive/`）一律不进 git**。

因此当时「归档」只是本机 `mv` 到 `archive/`：

1. git 索引里仍认为那些文件应在 **根目录**；
2. 任意 `git checkout` / `git restore` / 换机器 pull 都会把根目录文件 **还原回来**；
3. `archive/` 又不被提交 → 看起来像「归档了又出来了」，且可能根目录与 archive **双份并存**。

**修复：** 已改 `.gitignore` 允许 `analysis/archive/**` 入库；根目录再次清成仅活文档。  
**你需要 commit 一次**：根目录删除 + `archive/` 新增，归档才对所有人/下次 clone 生效。
