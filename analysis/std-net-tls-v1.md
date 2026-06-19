# STD-030/083：std.net TLS 封装 v1

> 更新时间：2026-06-18  
> 状态：**可用（OpenSSL STD-083 / mbedTLS STD-085 客户端）**  
> 关联：STD-002（std.net）、STD-031（WebSocket）、`std/http` HTTPS

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§5 |
| 2 | `tests/baseline/std-net-tls.tsv` |
| 3 | `./tests/run-std-net-tls-gate.sh` |
| 4 | 烟测：`tests/net/tls_stub.sx`（桩）、`tests/net/tls_openssl_smoke_ok.c`（OpenSSL）、`tests/net/tls_runtime_link_smoke.sx`（runtime 链入） |

---

## 2. 后端选型

| 维度 | **mbedTLS**（STD-085 已实现） | **OpenSSL**（STD-083 已实现） |
|------|-------------------------------|-------------------------------|
| 体积 | 小，可裁剪 | 较大 |
| v1 状态 | `make net-o-mbedtls` + gate 握手烟测 | `make net-o-openssl` + gate |
| 默认 `net.o` | 桩（轻量） | 桩（轻量） |

---

## 3. API 草案（v1）

| API | 说明 |
|-----|------|
| `TLS_OK` / `TLS_ERR_*` / `TLS_NOT_IMPL` | 错误码 |
| `TlsStream { fd, ctx_handle }` | 会话句柄 |
| `tls_backend_name()` | `"stub"` / `"mbedtls"` / `"openssl"` |
| `tls_is_available()` | 是否链入后端 |
| `tls_connect_client(stream, sni)` | 客户端握手 |
| `tls_read` / `tls_write` | 解密读写 |
| `tls_close` / `tls_last_error` | 生命周期与诊断 |

---

## 4. 可选链入

| 目标 | 命令 |
|------|------|
| 桩（默认） | `make net-o-stub` 或 `SHUX_NET_TLS=stub` |
| OpenSSL | `make net-o-openssl`（`-lssl -lcrypto`） |
| mbedTLS | `make net-o-mbedtls`（`-lmbedtls -lmbedx509 -lmbedcrypto`） |
| **runtime 自动** | `invoke_cc` 检测 `net.o` marker 并追加 TLS 库；`SHUX_NET_TLS=auto` 在无 marker 时尝试 `net-o-openssl`；默认不改动现有 `net.o` |

C 实现：`std/net/tls_mbedtls.inc.c`、`std/net/tls_openssl.inc.c`、`std/net/tls_stub.inc.c`。

---

## 5. 验证与门禁

```bash
./tests/run-std-net-tls-gate.sh
```

```
shux: [SHUX_STD_NET_TLS] status=ok stub=1 typeck=1 skip=0 openssl=1 mbedtls=1 runtime_link=1
```

OpenSSL 烟测：完整握手 + HTTP 读；mbedTLS 烟测：握手成功即可；runtime_link：shux-c 链 OpenSSL net.o 并运行 `tls_runtime_link_smoke.sx`。

---

## 6. 非目标（v1）

- 服务端 TLS / mTLS / 系统信任库
- 异步握手与 io_uring 整合

---

## 7. 演进

1. ~~runtime 按 net.o 后端自动 `-lssl` / `-lmbedtls`~~（已实现：`invoke_cc_append_net_tls_ld`）
2. `std.http` HTTPS 集成
3. ALPN（HTTP/2、WebSocket）
