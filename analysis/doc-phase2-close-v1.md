# DOC-008：Phase 2 收尾文档同步 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 触发：Phase 2 任务表（§2.1～§2.11）全部 ✅；STD-033 完成后 `std.http` 文档漂移  
> 读者：维护 `std/README.md`、`docs/07`、`examples/cookbook` 的贡献者

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 同步矩阵 |
| 2 | `./tests/run-doc-phase2-close-gate.sh` |
| 3 | 联动：`run-stbl-readme-sync-gate.sh`、`run-doc-07-stdlib-fulltable-gate.sh`、`run-doc-cookbook-expand-gate.sh` |

---

## 2. 同步矩阵（STD-033 / Phase 2 收官）

| 锚点 | 目标文件 | 期望内容 |
|------|----------|----------|
| `decode_chunked_body` | `std/http/README.md` | STD-033 API 表 |
| `STD-033` | `std/README.md` | std.http 行 gate 引用 |
| `STD-033` | `docs/07-内置与标准库.md` | std.http 已完善表 |
| `HTTP-02` | `analysis/doc-cookbook-expand-v1.md` | chunked 食谱 |
| `http_chunked_decode.sx` | `examples/cookbook/` | Cookbook 可 typeck |
| `Phase 2` | `NEXT.md` §3 | 审计快照与 STD-033 一致 |

---

## 3. Cookbook 增量

- **HTTP-02**：`examples/cookbook/http_chunked_decode.sx` — 离线 chunked 金样解码（与 `tests/http/chunked_keepalive.sx` 同向量，无 `build_get_keep_alive`）。

DOC-006 manifest 食谱数由 35 增至 **36**（`min_recipes` 仍为 35，gate 阈值不变）。

---

## 4. Gate

```bash
./tests/run-doc-phase2-close-gate.sh
```

```
shux: [SHUX_DOC08_PHASE2_CLOSE] status=ok anchors=6 cookbook=1 skip=0
```

---

## 5. 非目标

- 季度路线图刷新（DOC-005 Q3）— 独立发布节奏  
- `std/net` TLS/WebSocket README 扩写 — 已有专项 RFC/gate
