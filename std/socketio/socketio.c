/**
 * std/socketio/socketio.c — Engine.IO / Socket.IO 包编解码 v0（STD-SOCKETIO-001）
 *
 * 【文件职责】
 *   - Engine.IO 帧：单字符 type（0–6）+ 可选 payload（Engine.IO v4 文本传输）
 *   - Socket.IO 包：v0 支持 type=2 EVENT 文本事件 `2["event","data"]`
 *   - open 包 sid 提取（握手 JSON 子串）
 *   - v1：polling URL 构建、HTTP body 剥离、握手解析、HTTP GET/POST 传输（依赖 std.http）
 *   - v2：http→ws URL、SIO CONNECT 包、重连退避（connect 编排见 mod.sx + std.websocket）
 *   - v3：Node socket.io-client v4 金样向量、reconnect_once / emit_event_ws
 *   - v4：Engine.IO polling 服务端 open 响应 / 握手路径检测（server v2 骨架）
 *   - v5：服务端 EVENT emit / HTTP 推送响应；可选 socket.io npm live gate
 *   - v6：namespace CONNECT（`40/chat,`）、ACK / 带 id EVENT、SIO 包头解析
 *   - v7：多 namespace 路由表（CONNECT → slot）+ npm live namespace e2e
 *   - v8：多 namespace 并发会话计数 + WS 全链路 connect_ns / npm live WS e2e
 *   - v9：WS hub（sid 持久映射 + 按 slot 多路复用 server emit）
 *   - v10：room 注册/广播 + hub 快照 export/import（磁盘持久化由调用方写文件）
 *   - v11：hub rebind + room 快照 export/import + npm room live e2e
 *   - v12：session bundle 一体快照 + register_or_rebind + npm middleware live
 *   - v13：集群 session 合并 + npm plugin live
 *   - v14：内存 cluster adapter（Redis adapter 接口占位，无外部依赖）
 *   - v15：adapter SIOA 快照 export/import_merge + cluster ring 烟测
 *   - v16：P3 收口 p3_complete 烟测 + all-live 编排脚本
 *
 * 【所属模块】std.socketio（P3 可选，按需链入 socketio.o；非 core 默认 std）
 * 【依赖】v1 connect/polling 通过 extern 调用 std/http/http.c 的 http_get_timeout_c / http_post_timeout_c
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

/** Engine.IO：open。 */
#define SIO_EIO_OPEN 0
/** Engine.IO：close。 */
#define SIO_EIO_CLOSE 1
/** Engine.IO：ping。 */
#define SIO_EIO_PING 2
/** Engine.IO：pong。 */
#define SIO_EIO_PONG 3
/** Engine.IO：message（承载 Socket.IO 包）。 */
#define SIO_EIO_MESSAGE 4
/** Engine.IO：upgrade。 */
#define SIO_EIO_UPGRADE 5
/** Engine.IO：noop。 */
#define SIO_EIO_NOOP 6

/** Socket.IO：EVENT。 */
#define SIO_SIO_EVENT 2
/** Socket.IO：CONNECT（默认 namespace `/`）。 */
#define SIO_SIO_CONNECT 0
/** Socket.IO：ACK（带 packet id 的应答）。 */
#define SIO_SIO_ACK 3

/** Engine.IO 协议版本（v4）。 */
#define SIO_EIO_VERSION 4

/** 传输：HTTP long-polling。 */
#define SIO_TRANSPORT_POLLING 0
/** 传输：WebSocket upgrade。 */
#define SIO_TRANSPORT_WEBSOCKET 1

/** std.http 客户端（按需链入 http.o）。 */
extern int32_t http_get_timeout_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap,
                                  uint32_t timeout_ms);
extern int32_t http_post_timeout_c(const uint8_t *url, int32_t url_len, const uint8_t *body, int32_t body_len,
                                   uint8_t *out_buf, int32_t out_cap, uint32_t timeout_ms);

/** std.net WebSocket（按需链入 net.o；WS 升级 probe）。 */
extern int32_t net_ws_write_text_c(int32_t fd, int64_t tls_ctx, const uint8_t *payload, int32_t payload_len);
extern int32_t net_ws_write_server_text_c(int32_t fd, int64_t tls_ctx, const uint8_t *payload, int32_t payload_len);
extern int32_t net_ws_read_frame_c(int32_t fd, int64_t tls_ctx, int32_t *out_opcode, uint8_t *out_payload,
                                   int32_t out_cap, int32_t *out_payload_len, uint32_t timeout_ms);

/** 前向声明（polling v1 / connect v2 在包编解码函数之前引用）。 */
int32_t sio_eio_encode_packet_c(int32_t type, const uint8_t *payload, int32_t payload_len, uint8_t *out,
                                int32_t out_cap);
int32_t sio_eio_decode_packet_c(const uint8_t *buf, int32_t len, int32_t *out_type, uint8_t *out_payload,
                                int32_t out_cap, int32_t *out_payload_len);
int32_t sio_eio_extract_sid_c(const uint8_t *open_payload, int32_t len, uint8_t *out_sid, int32_t out_cap);
int32_t sio_encode_event_packet_c(const uint8_t *event, int32_t event_len, const uint8_t *data, int32_t data_len,
                                  uint8_t *out, int32_t out_cap);
int32_t sio_encode_event_ns_packet_c(const uint8_t *ns, int32_t ns_len, const uint8_t *event, int32_t event_len,
                                     const uint8_t *data, int32_t data_len, uint8_t *out, int32_t out_cap);
int32_t sio_decode_event_packet_c(const uint8_t *sio_pkt, int32_t len, uint8_t *out_event, int32_t out_event_cap,
                                  uint8_t *out_data, int32_t out_data_cap, int32_t *out_data_len);
int32_t sio_encode_connect_packet_c(uint8_t *out, int32_t out_cap);
int32_t sio_encode_connect_ns_packet_c(const uint8_t *ns, int32_t ns_len, uint8_t *out, int32_t out_cap);
int32_t sio_encode_event_ack_packet_c(int32_t ack_id, const uint8_t *event, int32_t event_len,
                                      const uint8_t *data, int32_t data_len, uint8_t *out, int32_t out_cap);
int32_t sio_encode_ack_packet_c(int32_t ack_id, const uint8_t *data, int32_t data_len, uint8_t *out,
                                int32_t out_cap);
int32_t sio_parse_sio_packet_head_c(const uint8_t *pkt, int32_t len, int32_t *out_type, int32_t *out_id,
                                    int32_t *out_payload_off);
int32_t sio_ns_ack_smoke_c(void);
int32_t sio_parse_connect_ns_packet_c(const uint8_t *pkt, int32_t len, uint8_t *out_ns, int32_t out_cap);
int32_t sio_ns_router_smoke_c(void);
int32_t sio_ns_sessions_smoke_c(void);
int32_t sio_ws_hub_smoke_c(void);
int32_t sio_room_smoke_c(void);
int32_t sio_hub_sync_smoke_c(void);
int32_t sio_session_sync_smoke_c(void);
int32_t sio_cluster_sync_smoke_c(void);
int32_t sio_cluster_adapter_smoke_c(void);
int32_t sio_cluster_ring_sync_smoke_c(void);
int32_t sio_p3_complete_smoke_c(void);

/** 路由表最大 namespace 条目数。 */
#define SIO_NS_ROUTER_MAX 4
/** 单条 namespace 路径最大字节数（含 `/` 前缀）。 */
#define SIO_NS_NAME_CAP 24
/** WS hub 最大并发连接数（与路由槽位同量级）。 */
#define SIO_WS_HUB_MAX 4
/** hub 内 EIO sid 最大字节数。 */
#define SIO_WS_SID_CAP 24
/** room 表最大条目数。 */
#define SIO_ROOM_MAX 4
/** room 名称最大字节数。 */
#define SIO_ROOM_NAME_CAP 16
/** 每个 room 最大成员数（hub conn_idx）。 */
#define SIO_ROOM_MEMBERS_MAX 4
/** hub 快照魔数（"SIOH"）。 */
#define SIO_HUB_SNAP_MAGIC 0x53494F48
/** hub 快照格式版本。 */
#define SIO_HUB_SNAP_VERSION 1
/** room 快照魔数（"SIOR"）。 */
#define SIO_ROOM_SNAP_MAGIC 0x53494F52
/** room 快照格式版本。 */
#define SIO_ROOM_SNAP_VERSION 1
/** session 一体快照魔数（"SIOS"）。 */
#define SIO_SESSION_SNAP_MAGIC 0x53494F53
/** session 一体快照格式版本。 */
#define SIO_SESSION_SNAP_VERSION 1
/** cluster adapter 队列最大消息数。 */
#define SIO_CLUSTER_ADAPTER_MAX 4
/** adapter 消息 ns 最大字节数。 */
#define SIO_CLUSTER_ADAPTER_NS_CAP 16
/** adapter 消息 event 最大字节数。 */
#define SIO_CLUSTER_ADAPTER_EVT_CAP 16
/** adapter 消息 data 最大字节数。 */
#define SIO_CLUSTER_ADAPTER_DATA_CAP 16
/** adapter 快照魔数（"SIOA"）。 */
#define SIO_ADAPTER_SNAP_MAGIC 0x53494F41
/** adapter 快照格式版本。 */
#define SIO_ADAPTER_SNAP_VERSION 1

/** 多 namespace 路由表（CONNECT 包 → slot_id）。 */
typedef struct {
    int32_t count;
    int32_t ns_len[SIO_NS_ROUTER_MAX];
    int32_t slot_id[SIO_NS_ROUTER_MAX];
    uint8_t ns[SIO_NS_ROUTER_MAX][SIO_NS_NAME_CAP];
} sio_ns_router_t;

/** 多 namespace 并发会话表（按 slot_id 计数 active 连接）。 */
typedef struct {
    int32_t count;
    int32_t slot_id[SIO_NS_ROUTER_MAX];
    int32_t active[SIO_NS_ROUTER_MAX];
} sio_ns_sessions_t;

/**
 * 单条 WS hub 槽位（fd/tls/sid/slot_id）。
 */
typedef struct {
    int32_t in_use;
    int32_t fd;
    int32_t sid_len;
    int32_t slot_id;
    int64_t tls_ctx;
    uint8_t sid[SIO_WS_SID_CAP];
} sio_ws_hub_slot_t;

/**
 * 多路复用 WS server hub：按 sid 持久映射 fd/tls，CONNECT 后绑定 router slot_id。
 */
typedef struct {
    int32_t count;
    sio_ws_hub_slot_t slot[SIO_WS_HUB_MAX];
} sio_ws_hub_t;

/** 单个 room（成员为 hub conn_idx）。 */
typedef struct {
    int32_t in_use;
    int32_t name_len;
    int32_t room_id;
    int32_t member_count;
    uint8_t name[SIO_ROOM_NAME_CAP];
    int32_t members[SIO_ROOM_MEMBERS_MAX];
} sio_room_t;

/** room 注册表（固定 4 room）。 */
typedef struct {
    int32_t count;
    sio_room_t room[SIO_ROOM_MAX];
} sio_room_registry_t;

/** hub 快照单槽（不含 fd/tls；import 后 fd=-1）。 */
typedef struct {
    int32_t in_use;
    int32_t sid_len;
    int32_t slot_id;
    uint8_t sid[SIO_WS_SID_CAP];
} sio_ws_hub_snap_slot_t;

/** hub 二进制快照（供 export/import / 磁盘持久化）。 */
typedef struct {
    int32_t magic;
    int32_t version;
    sio_ws_hub_snap_slot_t slot[SIO_WS_HUB_MAX];
} sio_ws_hub_snapshot_t;

/** room 二进制快照（供 export/import / 跨进程同步）。 */
typedef struct {
    int32_t magic;
    int32_t version;
    int32_t count;
    sio_room_t room[SIO_ROOM_MAX];
} sio_room_registry_snapshot_t;

/** hub + room 一体快照（跨进程 session 自动同步）。 */
typedef struct {
    int32_t magic;
    int32_t version;
    sio_ws_hub_snapshot_t hub;
    sio_room_registry_snapshot_t room;
} sio_session_bundle_t;

/** cluster adapter 跨节点 room 广播消息（内存队列，对标 Redis adapter pub/sub）。 */
typedef struct {
    int32_t in_use;
    int32_t src_node_id;
    int32_t room_id;
    int32_t ns_len;
    int32_t event_len;
    int32_t data_len;
    uint8_t ns[SIO_CLUSTER_ADAPTER_NS_CAP];
    uint8_t event[SIO_CLUSTER_ADAPTER_EVT_CAP];
    uint8_t data[SIO_CLUSTER_ADAPTER_DATA_CAP];
} sio_cluster_adapter_msg_t;

/** 内存 cluster adapter（轻量占位；生产可换 Redis backend）。 */
typedef struct {
    int32_t count;
    int32_t node_id;
    sio_cluster_adapter_msg_t msg[SIO_CLUSTER_ADAPTER_MAX];
} sio_cluster_adapter_t;

/** cluster adapter 二进制快照（跨节点 ring 同步；可写 std.fs 替代 Redis）。 */
typedef struct {
    int32_t magic;
    int32_t version;
    int32_t count;
    int32_t node_id;
    sio_cluster_adapter_msg_t msg[SIO_CLUSTER_ADAPTER_MAX];
} sio_cluster_adapter_snapshot_t;

/** 返回 Engine.IO 版本号（4）。 */
int32_t sio_eio_version_c(void) { return SIO_EIO_VERSION; }

/** 返回 polling 传输常量。 */
int32_t sio_transport_polling_c(void) { return SIO_TRANSPORT_POLLING; }

/** 返回 websocket 传输常量。 */
int32_t sio_transport_websocket_c(void) { return SIO_TRANSPORT_WEBSOCKET; }

/**
 * 向 out 追加字节串；*off 为当前写入偏移。
 * @return 0 成功，-1 缓冲不足
 */
static int32_t sio_append_bytes(uint8_t *out, int32_t cap, int32_t *off, const uint8_t *s, int32_t slen) {
    int32_t i;
    if (!out || !off || *off < 0)
        return -1;
    if (slen > 0 && !s)
        return -1;
    for (i = 0; i < slen; i++) {
        if (*off >= cap)
            return -1;
        out[(*off)++] = s[i];
    }
    return 0;
}

/**
 * 构建 Engine.IO URL：{base}/socket.io/?EIO=4&transport={polling|websocket}[&sid=...]。
 * base 为 scheme+host+port（可含路径前缀，不含 query）。
 * @return URL 字节数（不含 NUL），失败 -1
 */
int32_t sio_build_eio_url_c(const uint8_t *base, int32_t base_len, const uint8_t *sid, int32_t sid_len,
                            int32_t transport, uint8_t *out, int32_t out_cap) {
    static const uint8_t path_poll[] = "/socket.io/?EIO=4&transport=polling";
    static const uint8_t path_ws[] = "/socket.io/?EIO=4&transport=websocket";
    static const uint8_t sid_q[] = "&sid=";
    int32_t off = 0;
    int32_t i;
    int32_t has_slash = 0;
    const uint8_t *suffix;
    int32_t suffix_len;
    if (!base || base_len <= 0 || !out || out_cap < 32)
        return -1;
    if (sid_len < 0)
        return -1;
    if (sid_len > 0 && !sid)
        return -1;
    if (transport == SIO_TRANSPORT_WEBSOCKET) {
        suffix = path_ws;
        suffix_len = (int32_t)(sizeof(path_ws) - 1);
    } else {
        suffix = path_poll;
        suffix_len = (int32_t)(sizeof(path_poll) - 1);
    }
    for (i = base_len - 1; i >= 0; i--) {
        if (base[i] == (uint8_t)'/') {
            has_slash = 1;
            break;
        }
    }
    if (sio_append_bytes(out, out_cap, &off, base, base_len) != 0)
        return -1;
    if (!has_slash) {
        if (off >= out_cap)
            return -1;
        out[off++] = (uint8_t)'/';
    }
    if (sio_append_bytes(out, out_cap, &off, suffix, suffix_len) != 0)
        return -1;
    if (sid_len > 0) {
        if (sio_append_bytes(out, out_cap, &off, sid_q, (int32_t)(sizeof(sid_q) - 1)) != 0)
            return -1;
        if (sio_append_bytes(out, out_cap, &off, sid, sid_len) != 0)
            return -1;
    }
    return off;
}

/**
 * 从 HTTP/1.x 原始响应中提取 body（\r\n\r\n 之后）。
 * @return 0 成功并写 *out_len
 */
int32_t sio_http_extract_body_c(const uint8_t *http, int32_t len, uint8_t *out, int32_t out_cap, int32_t *out_len) {
    int32_t i;
    int32_t body_off = -1;
    int32_t blen;
    if (!http || len <= 0 || !out || !out_len)
        return -1;
    for (i = 0; i + 3 < len; i++) {
        if (http[i] == (uint8_t)'\r' && http[i + 1] == (uint8_t)'\n' && http[i + 2] == (uint8_t)'\r' &&
            http[i + 3] == (uint8_t)'\n') {
            body_off = i + 4;
            break;
        }
    }
    if (body_off < 0 || body_off >= len)
        return -1;
    blen = len - body_off;
    if (blen > out_cap)
        return -1;
    if (blen > 0)
        memcpy(out, http + body_off, (size_t)blen);
    *out_len = blen;
    return 0;
}

/**
 * 检测 open JSON 是否声明 websocket upgrade（"upgrades":["websocket"]）。
 * @return 1 有 websocket，0 无，-1 参数错误
 */
int32_t sio_eio_open_has_websocket_c(const uint8_t *open_payload, int32_t len) {
    static const char needle[] = "\"websocket\"";
    int32_t i;
    if (!open_payload || len <= 0)
        return -1;
    for (i = 0; i + 11 <= len; i++) {
        if (memcmp(open_payload + i, needle, 11) == 0)
            return 1;
    }
    return 0;
}

/**
 * 解析 polling 握手 HTTP 响应：剥离 body → EIO open → sid + websocket 探测。
 * @return sid 长度（>0），失败 -1
 */
int32_t sio_polling_handshake_parse_c(const uint8_t *http, int32_t http_len, uint8_t *out_sid, int32_t sid_cap,
                                      int32_t *out_has_ws) {
    uint8_t body[512];
    uint8_t payload[480];
    int32_t blen = 0;
    int32_t etype = -1;
    int32_t plen = 0;
    int32_t sid_len;
    int32_t has_ws;
    if (!http || http_len <= 0 || !out_sid || sid_cap < 2)
        return -1;
    if (sio_http_extract_body_c(http, http_len, body, (int32_t)sizeof(body), &blen) != 0)
        return -1;
    if (sio_eio_decode_packet_c(body, blen, &etype, payload, (int32_t)sizeof(payload), &plen) != 0)
        return -1;
    if (etype != SIO_EIO_OPEN)
        return -1;
    sid_len = sio_eio_extract_sid_c(payload, plen, out_sid, sid_cap);
    if (sid_len <= 0)
        return -1;
    has_ws = sio_eio_open_has_websocket_c(payload, plen);
    if (out_has_ws)
        *out_has_ws = has_ws > 0 ? 1 : 0;
    return sid_len;
}

/**
 * Engine.IO polling 握手：HTTP GET open 包并解析 sid。
 * @return sid 长度，网络/解析失败 -1
 */
int32_t sio_polling_handshake_c(const uint8_t *base_url, int32_t base_len, uint8_t *out_sid, int32_t sid_cap,
                                uint32_t timeout_ms, int32_t *out_has_ws) {
    uint8_t url[384];
    uint8_t resp[4096];
    int32_t url_len;
    int32_t n;
    if (!base_url || base_len <= 0 || !out_sid || sid_cap < 2)
        return -1;
    url_len = sio_build_eio_url_c(base_url, base_len, (const uint8_t *)0, 0, SIO_TRANSPORT_POLLING, url,
                                  (int32_t)sizeof(url));
    if (url_len <= 0)
        return -1;
    n = http_get_timeout_c(url, url_len, resp, (int32_t)sizeof(resp), timeout_ms);
    if (n <= 0)
        return -1;
    return sio_polling_handshake_parse_c(resp, n, out_sid, sid_cap, out_has_ws);
}

/**
 * 经 polling POST 发送 Engine.IO 包（body 即 EIO 文本帧）。
 * @return HTTP 响应写入字节数，失败 -1
 */
int32_t sio_polling_post_packet_c(const uint8_t *base_url, int32_t base_len, const uint8_t *sid, int32_t sid_len,
                                  const uint8_t *packet, int32_t packet_len, uint8_t *out_resp, int32_t out_cap,
                                  uint32_t timeout_ms) {
    uint8_t url[384];
    int32_t url_len;
    int32_t n;
    if (!base_url || base_len <= 0 || sid_len <= 0 || !sid || packet_len <= 0 || !packet)
        return -1;
    if (!out_resp || out_cap <= 0)
        return -1;
    url_len = sio_build_eio_url_c(base_url, base_len, sid, sid_len, SIO_TRANSPORT_POLLING, url,
                                  (int32_t)sizeof(url));
    if (url_len <= 0)
        return -1;
    n = http_post_timeout_c(url, url_len, packet, packet_len, out_resp, out_cap, timeout_ms);
    return n;
}

/**
 * polling 传输层烟测（URL + HTTP 解析 + canned 握手；不依赖 live server）。
 * @return 0 通过
 */
int32_t sio_polling_smoke_c(void) {
    static const uint8_t base[] = "http://127.0.0.1:3000";
    static const uint8_t sid[] = "abc123";
    static const uint8_t http_ok[] =
        "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 52\r\n\r\n"
        "0{\"sid\":\"abc123\",\"upgrades\":[\"websocket\"],\"pingInterval\":25000}";
    uint8_t url[128];
    uint8_t url2[128];
    uint8_t sid_out[16];
    int32_t has_ws = 0;
    int32_t n;
    n = sio_build_eio_url_c(base, (int32_t)(sizeof(base) - 1), (const uint8_t *)0, 0, SIO_TRANSPORT_POLLING, url,
                            128);
    if (n <= 0)
        return 1;
    if (memcmp(url, "http://127.0.0.1:3000/socket.io/?EIO=4&transport=polling", (size_t)n) != 0)
        return 2;
    n = sio_build_eio_url_c(base, (int32_t)(sizeof(base) - 1), sid, 6, SIO_TRANSPORT_WEBSOCKET, url2, 128);
    if (n <= 0)
        return 3;
    if (url2[n - 1] != (uint8_t)'3' || url2[n - 2] != (uint8_t)'2')
        return 4;
    n = sio_polling_handshake_parse_c(http_ok, (int32_t)(sizeof(http_ok) - 1), sid_out, 16, &has_ws);
    if (n != 6 || has_ws != 1)
        return 5;
    if (memcmp(sid_out, sid, 6) != 0)
        return 6;
    if (sio_eio_version_c() != 4)
        return 7;
    return 0;
}

/** 返回 Socket.IO CONNECT 类型常量（0）。 */
int32_t sio_sio_type_connect_c(void) { return SIO_SIO_CONNECT; }

/** 返回 Socket.IO ACK 类型常量（3）。 */
int32_t sio_sio_type_ack_c(void) { return SIO_SIO_ACK; }

/**
 * 将 http(s):// base 转为 ws(s):// 前缀（不含 /socket.io path）。
 * @return 写入字节数，失败 -1
 */
int32_t sio_http_to_ws_base_c(const uint8_t *http_base, int32_t len, uint8_t *out, int32_t out_cap) {
    static const uint8_t https_p[] = "https://";
    static const uint8_t wss_p[] = "wss://";
    static const uint8_t http_p[] = "http://";
    static const uint8_t ws_p[] = "ws://";
    const uint8_t *src_suffix;
    int32_t suffix_len;
    const uint8_t *dst_p;
    int32_t dst_len;
    int32_t off = 0;
    if (!http_base || len <= 0 || !out || out_cap < 8)
        return -1;
    if (len >= 8 && memcmp(http_base, https_p, 8) == 0) {
        dst_p = wss_p;
        dst_len = 6;
        src_suffix = http_base + 8;
        suffix_len = len - 8;
    } else if (len >= 7 && memcmp(http_base, http_p, 7) == 0) {
        dst_p = ws_p;
        dst_len = 5;
        src_suffix = http_base + 7;
        suffix_len = len - 7;
    } else {
        return -1;
    }
    if (dst_len + suffix_len > out_cap)
        return -1;
    if (sio_append_bytes(out, out_cap, &off, dst_p, dst_len) != 0)
        return -1;
    if (sio_append_bytes(out, out_cap, &off, src_suffix, suffix_len) != 0)
        return -1;
    return off;
}

/**
 * 构建 WebSocket 升级 URL：ws(s)://host/socket.io/?EIO=4&transport=websocket&sid=...
 */
int32_t sio_build_ws_connect_url_c(const uint8_t *http_base, int32_t base_len, const uint8_t *sid, int32_t sid_len,
                                   uint8_t *out, int32_t out_cap) {
    uint8_t ws_base[384];
    int32_t wl;
    if (!http_base || base_len <= 0 || sid_len <= 0 || !sid || !out)
        return -1;
    wl = sio_http_to_ws_base_c(http_base, base_len, ws_base, (int32_t)sizeof(ws_base));
    if (wl <= 0)
        return -1;
    return sio_build_eio_url_c(ws_base, wl, sid, sid_len, SIO_TRANSPORT_WEBSOCKET, out, out_cap);
}

/**
 * 完成 polling→WebSocket 升级（Engine.IO v4：`2probe` / `3probe` / `5`）。
 * 须在 RFC6455 握手成功后、发送 Socket.IO CONNECT 前调用。
 * @return 0 成功，失败 -1
 */
int32_t sio_eio_ws_upgrade_c(int32_t fd, int64_t tls_ctx, uint32_t timeout_ms) {
    static const uint8_t probe[] = "2probe";
    static const uint8_t upgrade[] = "5";
    uint8_t buf[16];
    int32_t opcode = 0;
    int32_t plen = 0;
    if (fd < 0)
        return -1;
    if (net_ws_write_text_c(fd, tls_ctx, probe, 6) != 0)
        return -1;
    if (net_ws_read_frame_c(fd, tls_ctx, &opcode, buf, 16, &plen, timeout_ms) != 0)
        return -1;
    if (plen != 6 || memcmp(buf, "3probe", 6) != 0)
        return -1;
    if (net_ws_write_text_c(fd, tls_ctx, upgrade, 1) != 0)
        return -1;
    return 0;
}

/**
 * 编码 Socket.IO CONNECT 默认 namespace 包（Engine.IO message `40`）。
 * @return 写入字节数（2），失败 -1
 */
int32_t sio_encode_connect_packet_c(uint8_t *out, int32_t out_cap) {
    static const uint8_t sio_connect[] = "0";
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, sio_connect, 1, out, out_cap);
}

/**
 * 重连退避毫秒：1000 * (attempt + 1)，上限 cap_ms（默认 5000）。
 */
int32_t sio_reconnect_delay_ms_c(int32_t attempt, int32_t cap_ms) {
    int32_t delay;
    if (attempt < 0)
        attempt = 0;
    if (cap_ms <= 0)
        cap_ms = 5000;
    delay = 1000 * (attempt + 1);
    if (delay > cap_ms)
        delay = cap_ms;
    return delay;
}

/** connect v2 烟测（http→ws、CONNECT 包、退避；无 live server）。 */
int32_t sio_connect_smoke_c(void) {
    static const uint8_t http_base[] = "http://127.0.0.1:3000";
    static const uint8_t https_base[] = "https://example.com:8443";
    static const uint8_t sid[] = "sess42";
    uint8_t ws_base[64];
    uint8_t url[160];
    uint8_t pkt[8];
    int32_t n;
    n = sio_http_to_ws_base_c(http_base, (int32_t)(sizeof(http_base) - 1), ws_base, 64);
    if (n != 19 || memcmp(ws_base, "ws://127.0.0.1:3000", 19) != 0)
        return 1;
    n = sio_http_to_ws_base_c(https_base, (int32_t)(sizeof(https_base) - 1), ws_base, 64);
    if (n != 22 || memcmp(ws_base, "wss://example.com:8443", 22) != 0)
        return 2;
    n = sio_build_ws_connect_url_c(http_base, (int32_t)(sizeof(http_base) - 1), sid, 6, url, 160);
    if (n <= 0 || url[0] != (uint8_t)'w' || url[n - 1] != (uint8_t)'2')
        return 3;
    n = sio_encode_connect_packet_c(pkt, 8);
    if (n != 2 || pkt[0] != (uint8_t)'4' || pkt[1] != (uint8_t)'0')
        return 4;
    if (sio_reconnect_delay_ms_c(0, 5000) != 1000)
        return 5;
    if (sio_reconnect_delay_ms_c(10, 5000) != 5000)
        return 6;
    return 0;
}

/**
 * Node socket.io-client v4 互操作金样（canned HTTP open + WS EVENT；无 live Node）。
 * 对齐 engine.io v4 文本帧与 socket.io EVENT `42["event","data"]`。
 * @return 0 通过
 */
int32_t sio_node_interop_smoke_c(void) {
    static const uint8_t node_http_open[] =
        "HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=UTF-8\r\nConnection: keep-alive\r\n\r\n"
        "0{\"sid\":\"oXLMyi\",\"upgrades\":[\"websocket\"],\"pingInterval\":25000,\"pingTimeout\":20000,"
        "\"maxPayload\":1000000}";
    static const uint8_t node_sid[] = "oXLMyi";
    static const uint8_t node_ws_event[] = "42[\"chat message\",\"hello\"]";
    static const uint8_t evt_name[] = "chat message";
    static const uint8_t evt_data[] = "hello";
    uint8_t sid[16];
    uint8_t evt[32];
    uint8_t data[32];
    uint8_t enc[64];
    uint8_t eio_payload[32];
    uint8_t pong[4];
    int32_t has_ws = 0;
    int32_t dlen = 0;
    int32_t n;
    int32_t etype = -1;
    int32_t plen = 0;
    int32_t node_evt_len = (int32_t)(sizeof(node_ws_event) - 1);

    n = sio_polling_handshake_parse_c(node_http_open, (int32_t)(sizeof(node_http_open) - 1), sid, 16, &has_ws);
    if (n != 6 || has_ws != 1 || memcmp(sid, node_sid, 6) != 0)
        return 1;
    if (sio_eio_decode_packet_c(node_ws_event, node_evt_len, &etype, eio_payload, 32, &plen) != 0)
        return 2;
    if (etype != SIO_EIO_MESSAGE || plen != node_evt_len - 1)
        return 3;
    if (sio_decode_event_packet_c(node_ws_event + 1, node_evt_len - 1, evt, 32, data, 32, &dlen) != 0)
        return 4;
    if (dlen != 5 || data[0] != (uint8_t)'h' || evt[0] != (uint8_t)'c')
        return 5;
    n = sio_encode_event_packet_c(evt_name, 12, evt_data, 5, enc, 64);
    if (n != node_evt_len || memcmp(enc, node_ws_event, (size_t)n) != 0)
        return 6;
    n = sio_encode_connect_packet_c(enc, 64);
    if (n != 2 || enc[0] != (uint8_t)'4' || enc[1] != (uint8_t)'0')
        return 7;
    n = sio_eio_encode_packet_c(SIO_EIO_PONG, (const uint8_t *)0, 0, pong, 4);
    if (n != 1 || pong[0] != (uint8_t)('0' + SIO_EIO_PONG))
        return 8;
    return 0;
}

/**
 * 构建 Engine.IO open JSON（Node engine.io v4 兼容子集）。
 * @return JSON 字节数，失败 -1
 */
int32_t sio_server_build_open_json_c(const uint8_t *sid, int32_t sid_len, uint8_t *out, int32_t out_cap) {
    static const char prefix[] = "{\"sid\":\"";
    static const char suffix[] = "\",\"upgrades\":[\"websocket\"],\"pingInterval\":25000,\"pingTimeout\":20000}";
    int32_t need;
    if (!sid || sid_len <= 0 || sid_len > 64 || !out || out_cap < 32)
        return -1;
    need = (int32_t)(sizeof(prefix) - 1) + sid_len + (int32_t)(sizeof(suffix) - 1);
    if (need >= out_cap)
        return -1;
    memcpy(out, prefix, sizeof(prefix) - 1);
    memcpy(out + (sizeof(prefix) - 1), sid, (size_t)sid_len);
    memcpy(out + (sizeof(prefix) - 1) + (size_t)sid_len, suffix, sizeof(suffix));
    return need;
}

/** 构建 Engine.IO open 包（0 + JSON）。 */
int32_t sio_server_build_open_packet_c(const uint8_t *sid, int32_t sid_len, uint8_t *out, int32_t out_cap) {
    uint8_t json[128];
    int32_t jl;
    if (!out)
        return -1;
    jl = sio_server_build_open_json_c(sid, sid_len, json, (int32_t)sizeof(json));
    if (jl <= 0)
        return -1;
    return sio_eio_encode_packet_c(SIO_EIO_OPEN, json, jl, out, out_cap);
}

/**
 * 将 EIO body 封装为 HTTP/1.1 200 text/plain 响应。
 * @return 总字节数，失败 -1
 */
static int32_t sio_server_wrap_http_body_c(const uint8_t *body, int32_t blen, uint8_t *out, int32_t out_cap) {
    int32_t hdr_len;
    if (!body || blen <= 0 || !out || out_cap < blen + 64)
        return -1;
    hdr_len = snprintf((char *)out, (size_t)out_cap,
                       "HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=UTF-8\r\nConnection: keep-alive\r\n"
                       "Content-Length: %d\r\n\r\n",
                       blen);
    if (hdr_len <= 0 || hdr_len + blen > out_cap)
        return -1;
    memcpy(out + hdr_len, body, (size_t)blen);
    return hdr_len + blen;
}

/** 构建 polling 握手 HTTP/1.1 200 响应（body 为 open EIO 包）。 */
int32_t sio_server_build_http_open_response_c(const uint8_t *sid, int32_t sid_len, uint8_t *out, int32_t out_cap) {
    uint8_t body[160];
    int32_t blen;
    if (!out || out_cap < 64)
        return -1;
    blen = sio_server_build_open_packet_c(sid, sid_len, body, (int32_t)sizeof(body));
    if (blen <= 0)
        return -1;
    return sio_server_wrap_http_body_c(body, blen, out, out_cap);
}

/**
 * 检测 HTTP GET path/query 是否为 polling 初始握手（EIO=4、transport=polling、无 sid）。
 * @return 1 是，0 否，-1 参数错误
 */
int32_t sio_server_is_polling_handshake_c(const uint8_t *path, int32_t len) {
    static const char eio[] = "EIO=4";
    static const char tp[] = "transport=polling";
    static const char sid_q[] = "sid=";
    int32_t has_eio = 0;
    int32_t has_tp = 0;
    int32_t i;
    if (!path || len <= 0)
        return -1;
    for (i = 0; i + 4 <= len; i++) {
        if (memcmp(path + i, eio, 4) == 0)
            has_eio = 1;
    }
    for (i = 0; i + 17 <= len; i++) {
        if (memcmp(path + i, tp, 17) == 0)
            has_tp = 1;
    }
    for (i = 0; i + 4 <= len; i++) {
        if (memcmp(path + i, sid_q, 4) == 0)
            return 0;
    }
    return (has_eio && has_tp) ? 1 : 0;
}

/**
 * 检测客户端 Socket.IO CONNECT 包（`40` 或 EIO message + payload `0`）。
 * @return 1 是 CONNECT，0 否，-1 参数错误
 */
int32_t sio_server_is_connect_packet_c(const uint8_t *pkt, int32_t len) {
    int32_t etype = -1;
    int32_t plen = 0;
    uint8_t inner[128];
    if (!pkt || len <= 0)
        return -1;
    if (len == 2 && pkt[0] == (uint8_t)('0' + SIO_EIO_MESSAGE) && pkt[1] == (uint8_t)('0' + SIO_SIO_CONNECT))
        return 1;
    if (sio_eio_decode_packet_c(pkt, len, &etype, inner, (int32_t)sizeof(inner), &plen) != 0)
        return 0;
    if (etype != SIO_EIO_MESSAGE || plen < 1)
        return 0;
    return (inner[0] == (uint8_t)('0' + SIO_SIO_CONNECT)) ? 1 : 0;
}

/**
 * 服务端推送 Socket.IO EVENT（Engine.IO message 帧 `42["event","data"]`）。
 * @return 帧字节数，失败 -1
 */
int32_t sio_server_emit_event_c(const uint8_t *event, int32_t event_len, const uint8_t *data, int32_t data_len,
                                uint8_t *out, int32_t out_cap) {
    if (!event || event_len <= 0 || !out)
        return -1;
    if (data_len < 0)
        return -1;
    if (data_len > 0 && !data)
        return -1;
    return sio_encode_event_packet_c(event, event_len, data, data_len, out, out_cap);
}

/** 构建 polling 推送 EVENT 的 HTTP/1.1 200 响应。 */
int32_t sio_server_build_http_event_response_c(const uint8_t *event, int32_t event_len, const uint8_t *data,
                                               int32_t data_len, uint8_t *out, int32_t out_cap) {
    uint8_t body[512];
    int32_t blen;
    if (!out || out_cap < 64)
        return -1;
    blen = sio_server_emit_event_c(event, event_len, data, data_len, body, (int32_t)sizeof(body));
    if (blen <= 0)
        return -1;
    return sio_server_wrap_http_body_c(body, blen, out, out_cap);
}

/** server emit 烟测（EVENT 帧 + HTTP 封装 + 客户端解码）。 */
int32_t sio_server_emit_smoke_c(void) {
    static const uint8_t evt[] = "news";
    static const uint8_t payload[] = "update";
    static const uint8_t expect[] = "42[\"news\",\"update\"]";
    uint8_t frame[64];
    uint8_t http[256];
    uint8_t body[128];
    uint8_t out_evt[16];
    uint8_t out_data[16];
    int32_t body_len = 0;
    int32_t dlen = 0;
    int32_t n;
    n = sio_server_emit_event_c(evt, 4, payload, 6, frame, 64);
    if (n != (int32_t)(sizeof(expect) - 1) || memcmp(frame, expect, (size_t)n) != 0)
        return 1;
    n = sio_server_build_http_event_response_c(evt, 4, payload, 6, http, 256);
    if (n <= 0)
        return 2;
    if (sio_http_extract_body_c(http, n, body, 128, &body_len) != 0)
        return 3;
    if (body_len < 2 || body[0] != (uint8_t)('0' + SIO_EIO_MESSAGE))
        return 4;
    if (sio_decode_event_packet_c(body + 1, body_len - 1, out_evt, 16, out_data, 16, &dlen) != 0)
        return 5;
    if (dlen != 6 || out_evt[0] != (uint8_t)'n' || out_data[0] != (uint8_t)'u')
        return 6;
    return 0;
}

/** server v2 烟测（open 响应 + 路径/CONNECT 检测）。 */
int32_t sio_server_smoke_c(void) {
    static const uint8_t sid[] = "srv001";
    static const uint8_t path_ok[] = "/socket.io/?EIO=4&transport=polling&t=abc";
    static const uint8_t path_sid[] = "/socket.io/?EIO=4&transport=polling&sid=x";
    uint8_t body[160];
    uint8_t http[256];
    uint8_t sid_out[16];
    int32_t has_ws = 0;
    int32_t n;
    n = sio_server_build_open_packet_c(sid, 6, body, 160);
    if (n <= 0 || body[0] != (uint8_t)('0' + SIO_EIO_OPEN))
        return 1;
    n = sio_server_build_http_open_response_c(sid, 6, http, 256);
    if (n <= 0)
        return 2;
    if (sio_polling_handshake_parse_c(http, n, sid_out, 16, &has_ws) != 6)
        return 3;
    if (memcmp(sid_out, sid, 6) != 0 || has_ws != 1)
        return 4;
    if (sio_server_is_polling_handshake_c(path_ok, (int32_t)(sizeof(path_ok) - 1)) != 1)
        return 5;
    if (sio_server_is_polling_handshake_c(path_sid, (int32_t)(sizeof(path_sid) - 1)) != 0)
        return 6;
    if (sio_server_is_connect_packet_c((const uint8_t *)"40", 2) != 1)
        return 7;
    if (sio_server_emit_smoke_c() != 0)
        return 8;
    return 0;
}

/**
 * 向 out 追加无符号十进制数字（不含 NUL）。
 * @return 0 成功，-1 缓冲不足
 */
static int32_t sio_append_u32_dec(uint8_t *out, int32_t cap, int32_t *off, uint32_t v) {
    char tmp[12];
    int n;
    if (!out || !off || *off < 0)
        return -1;
    n = snprintf(tmp, sizeof(tmp), "%u", v);
    if (n <= 0 || n >= (int)sizeof(tmp))
        return -1;
    return sio_append_bytes(out, cap, off, (const uint8_t *)tmp, n);
}

/**
 * 编码 Socket.IO CONNECT 指定 namespace 包（例 `/chat` → `40/chat,`）。
 * ns 为空或 `/` 时等同默认 `40`。
 * @return 写入字节数，失败 -1
 */
int32_t sio_encode_connect_ns_packet_c(const uint8_t *ns, int32_t ns_len, uint8_t *out, int32_t out_cap) {
    uint8_t inner[128];
    int32_t off = 0;
    if (!out || out_cap < 2)
        return -1;
    if (ns_len < 0)
        return -1;
    if (!ns || ns_len == 0 || (ns_len == 1 && ns[0] == (uint8_t)'/'))
        return sio_encode_connect_packet_c(out, out_cap);
    if (ns[0] != (uint8_t)'/')
        return -1;
    inner[off++] = (uint8_t)('0' + SIO_SIO_CONNECT);
    if (sio_append_bytes(inner, (int32_t)sizeof(inner), &off, ns, ns_len) != 0)
        return -1;
    if (off + 1 >= (int32_t)sizeof(inner))
        return -1;
    inner[off++] = (uint8_t)',';
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}

/**
 * 解析 Socket.IO 包头部：type 数字 + 可选 packet id + payload 起始偏移。
 * out_id 无 id 时为 -1；out_payload_off 指向 `[` 或 namespace 后缀等。
 * @return 0 成功，-1 参数/格式错误
 */
int32_t sio_parse_sio_packet_head_c(const uint8_t *pkt, int32_t len, int32_t *out_type, int32_t *out_id,
                                    int32_t *out_payload_off) {
    int32_t i;
    int32_t type;
    int32_t id;
    if (!pkt || len <= 0 || !out_type || !out_payload_off)
        return -1;
    if (pkt[0] < (uint8_t)'0' || pkt[0] > (uint8_t)'9')
        return -1;
    type = (int32_t)(pkt[0] - (uint8_t)'0');
    i = 1;
    id = -1;
    if (i < len && pkt[i] >= (uint8_t)'0' && pkt[i] <= (uint8_t)'9') {
        id = 0;
        while (i < len && pkt[i] >= (uint8_t)'0' && pkt[i] <= (uint8_t)'9') {
            id = id * 10 + (int32_t)(pkt[i] - (uint8_t)'0');
            i++;
        }
    }
    *out_type = type;
    if (out_id)
        *out_id = id;
    *out_payload_off = i;
    return 0;
}

/**
 * 检测 CONNECT 包是否匹配指定 namespace（默认 `/` 仅接受 `40`）。
 * @return 1 匹配，0 否，-1 参数错误
 */
int32_t sio_server_is_connect_ns_packet_c(const uint8_t *pkt, int32_t len, const uint8_t *ns, int32_t ns_len) {
    int32_t etype = -1;
    int32_t plen = 0;
    uint8_t inner[128];
    int32_t expect_inner;
    if (!pkt || len <= 0)
        return -1;
    if (ns_len < 0)
        return -1;
    if (len == 2 && pkt[0] == (uint8_t)('0' + SIO_EIO_MESSAGE) && pkt[1] == (uint8_t)('0' + SIO_SIO_CONNECT))
        return (!ns || ns_len == 0 || (ns_len == 1 && ns[0] == (uint8_t)'/')) ? 1 : 0;
    if (sio_eio_decode_packet_c(pkt, len, &etype, inner, (int32_t)sizeof(inner), &plen) != 0)
        return 0;
    if (etype != SIO_EIO_MESSAGE || plen < 1 || inner[0] != (uint8_t)('0' + SIO_SIO_CONNECT))
        return 0;
    if (!ns || ns_len == 0 || (ns_len == 1 && ns[0] == (uint8_t)'/'))
        return (plen == 1) ? 1 : 0;
    expect_inner = 1 + ns_len + 1;
    if (plen != expect_inner)
        return 0;
    if (memcmp(inner + 1, ns, (size_t)ns_len) != 0)
        return 0;
    return (inner[plen - 1] == (uint8_t)',') ? 1 : 0;
}

/**
 * 从 CONNECT EIO 帧解析 namespace 路径（默认 `/` 长度 1）。
 * @return namespace 字节数，非 CONNECT -1
 */
int32_t sio_parse_connect_ns_packet_c(const uint8_t *pkt, int32_t len, uint8_t *out_ns, int32_t out_cap) {
    int32_t etype = -1;
    int32_t plen = 0;
    uint8_t inner[128];
    int32_t ns_len;
    if (!out_ns || out_cap < 2)
        return -1;
    if (!pkt || len <= 0)
        return -1;
    if (len == 2 && pkt[0] == (uint8_t)('0' + SIO_EIO_MESSAGE) && pkt[1] == (uint8_t)('0' + SIO_SIO_CONNECT)) {
        out_ns[0] = (uint8_t)'/';
        return 1;
    }
    if (sio_eio_decode_packet_c(pkt, len, &etype, inner, (int32_t)sizeof(inner), &plen) != 0)
        return -1;
    if (etype != SIO_EIO_MESSAGE || plen < 1 || inner[0] != (uint8_t)('0' + SIO_SIO_CONNECT))
        return -1;
    if (plen == 1) {
        out_ns[0] = (uint8_t)'/';
        return 1;
    }
    if (inner[plen - 1] != (uint8_t)',')
        return -1;
    ns_len = plen - 2;
    if (ns_len <= 0 || ns_len >= out_cap)
        return -1;
    memcpy(out_ns, inner + 1, (size_t)ns_len);
    return ns_len;
}

/** 返回 sio_ns_router_t 字节数（mod.sx SioNsRouter.blob 须匹配）。 */
int32_t sio_ns_router_bytes_c(void) { return (int32_t)sizeof(sio_ns_router_t); }

/** 清空路由表。 */
void sio_ns_router_init_c(sio_ns_router_t *r) {
    if (!r)
        return;
    memset(r, 0, sizeof(*r));
}

/**
 * 比较两 namespace 是否等价（空与 `/` 视为默认 namespace）。
 * @return 1 相同，0 不同
 */
static int32_t sio_ns_equal_c(const uint8_t *a, int32_t alen, const uint8_t *b, int32_t blen) {
    static const uint8_t root[] = "/";
    if (alen <= 0 || (alen == 1 && a[0] == (uint8_t)'/')) {
        alen = 1;
        a = root;
    }
    if (blen <= 0 || (blen == 1 && b[0] == (uint8_t)'/')) {
        blen = 1;
        b = root;
    }
    return (alen == blen && memcmp(a, b, (size_t)alen) == 0) ? 1 : 0;
}

/**
 * 注册 namespace → slot_id（满表或非法 ns 时 -1）。
 * @return 0 成功
 */
int32_t sio_ns_router_register_c(sio_ns_router_t *r, const uint8_t *ns, int32_t ns_len, int32_t slot_id) {
    static const uint8_t root[] = "/";
    if (!r || slot_id < 0)
        return -1;
    if (r->count >= SIO_NS_ROUTER_MAX)
        return -1;
    if (ns_len < 0)
        return -1;
    if (!ns || ns_len == 0 || (ns_len == 1 && ns[0] == (uint8_t)'/')) {
        ns = root;
        ns_len = 1;
    }
    if (ns_len <= 0 || ns_len >= SIO_NS_NAME_CAP)
        return -1;
    r->ns_len[r->count] = ns_len;
    r->slot_id[r->count] = slot_id;
    memcpy(r->ns[r->count], ns, (size_t)ns_len);
    r->count++;
    return 0;
}

/** 按 namespace 查 slot_id；未注册 -1。 */
int32_t sio_ns_router_lookup_c(const sio_ns_router_t *r, const uint8_t *ns, int32_t ns_len) {
    int32_t i;
    if (!r)
        return -1;
    for (i = 0; i < r->count; i++) {
        if (sio_ns_equal_c(r->ns[i], r->ns_len[i], ns, ns_len))
            return r->slot_id[i];
    }
    return -1;
}

/** 解析 CONNECT 包并查路由 slot_id；非 CONNECT 或未注册 -1。 */
int32_t sio_ns_router_route_connect_c(const sio_ns_router_t *r, const uint8_t *pkt, int32_t len) {
    uint8_t ns[SIO_NS_NAME_CAP];
    int32_t nl;
    if (!r)
        return -1;
    nl = sio_parse_connect_ns_packet_c(pkt, len, ns, SIO_NS_NAME_CAP);
    if (nl <= 0)
        return -1;
    return sio_ns_router_lookup_c(r, ns, nl);
}

/** 多 namespace 路由烟测（无 live server）。 */
int32_t sio_ns_router_smoke_c(void) {
    static const uint8_t ns_chat[] = "/chat";
    static const uint8_t ns_admin[] = "/admin";
    sio_ns_router_t router;
    uint8_t pkt_root[8];
    uint8_t pkt_chat[16];
    uint8_t pkt_admin[16];
    uint8_t ns_out[24];
    int32_t n;
    int32_t slot;
    sio_ns_router_init_c(&router);
    if (sio_ns_router_register_c(&router, (const uint8_t *)"/", 1, 0) != 0)
        return 1;
    if (sio_ns_router_register_c(&router, ns_chat, 5, 10) != 0)
        return 2;
    if (sio_ns_router_register_c(&router, ns_admin, 6, 20) != 0)
        return 3;
    n = sio_encode_connect_packet_c(pkt_root, 8);
    if (n <= 0)
        return 4;
    if (sio_parse_connect_ns_packet_c(pkt_root, n, ns_out, 24) != 1 || ns_out[0] != (uint8_t)'/')
        return 5;
    if (sio_ns_router_route_connect_c(&router, pkt_root, n) != 0)
        return 6;
    n = sio_encode_connect_ns_packet_c(ns_chat, 5, pkt_chat, 16);
    if (n <= 0)
        return 7;
    if (sio_parse_connect_ns_packet_c(pkt_chat, n, ns_out, 24) != 5)
        return 8;
    if (ns_out[0] != (uint8_t)'/' || ns_out[1] != (uint8_t)'c')
        return 9;
    slot = sio_ns_router_route_connect_c(&router, pkt_chat, n);
    if (slot != 10)
        return 10;
    n = sio_encode_connect_ns_packet_c(ns_admin, 6, pkt_admin, 16);
    if (n <= 0)
        return 11;
    slot = sio_ns_router_route_connect_c(&router, pkt_admin, n);
    if (slot != 20)
        return 12;
    if (sio_ns_router_lookup_c(&router, ns_chat, 5) != 10)
        return 13;
    if (sio_ns_router_lookup_c(&router, (const uint8_t *)"/unknown", 9) != -1)
        return 14;
    return 0;
}

/** 返回 sio_ns_sessions_t 字节数（mod.sx SioNsSessions 须匹配）。 */
int32_t sio_ns_sessions_bytes_c(void) { return (int32_t)sizeof(sio_ns_sessions_t); }

/** 清空并发会话表。 */
void sio_ns_sessions_init_c(sio_ns_sessions_t *s) {
    if (!s)
        return;
    memset(s, 0, sizeof(*s));
}

/**
 * 从路由表同步 slot_id 列表（active 清零）。
 * @return 0 成功
 */
int32_t sio_ns_sessions_sync_router_c(sio_ns_sessions_t *s, const sio_ns_router_t *r) {
    int32_t i;
    if (!s || !r)
        return -1;
    sio_ns_sessions_init_c(s);
    if (r->count > SIO_NS_ROUTER_MAX)
        return -1;
    s->count = r->count;
    for (i = 0; i < r->count; i++)
        s->slot_id[i] = r->slot_id[i];
    return 0;
}

/** 在 sessions 中查找 slot_id 下标；-1 未找到。 */
static int32_t sio_ns_sessions_slot_index_c(const sio_ns_sessions_t *s, int32_t slot_id) {
    int32_t i;
    if (!s || slot_id < 0)
        return -1;
    for (i = 0; i < s->count; i++) {
        if (s->slot_id[i] == slot_id)
            return i;
    }
    return -1;
}

/**
 * CONNECT 包路由并递增对应 slot 的 active 计数。
 * @return slot_id，失败 -1
 */
int32_t sio_ns_sessions_connect_c(sio_ns_sessions_t *s, const sio_ns_router_t *r, const uint8_t *pkt, int32_t len) {
    int32_t slot;
    int32_t idx;
    if (!s || !r)
        return -1;
    slot = sio_ns_router_route_connect_c(r, pkt, len);
    if (slot < 0)
        return -1;
    idx = sio_ns_sessions_slot_index_c(s, slot);
    if (idx < 0)
        return -1;
    s->active[idx]++;
    return slot;
}

/**
 * 递减 slot 的 active 计数（不低于 0）。
 * @return 0 成功，-1 未知 slot
 */
int32_t sio_ns_sessions_disconnect_c(sio_ns_sessions_t *s, int32_t slot_id) {
    int32_t idx;
    if (!s)
        return -1;
    idx = sio_ns_sessions_slot_index_c(s, slot_id);
    if (idx < 0)
        return -1;
    if (s->active[idx] > 0)
        s->active[idx]--;
    return 0;
}

/** 查询 slot 当前 active 连接数；-1 未知 slot。 */
int32_t sio_ns_sessions_active_c(const sio_ns_sessions_t *s, int32_t slot_id) {
    int32_t idx;
    if (!s)
        return -1;
    idx = sio_ns_sessions_slot_index_c(s, slot_id);
    if (idx < 0)
        return -1;
    return s->active[idx];
}

/** 全部 namespace 的 active 连接总数。 */
int32_t sio_ns_sessions_total_c(const sio_ns_sessions_t *s) {
    int32_t i;
    int32_t total = 0;
    if (!s)
        return -1;
    for (i = 0; i < s->count; i++)
        total += s->active[i];
    return total;
}

/** 多 namespace 并发会话烟测（无 live server）。 */
int32_t sio_ns_sessions_smoke_c(void) {
    static const uint8_t ns_chat[] = "/chat";
    static const uint8_t ns_admin[] = "/admin";
    sio_ns_router_t router;
    sio_ns_sessions_t sessions;
    uint8_t pkt_root[8];
    uint8_t pkt_chat[16];
    uint8_t pkt_admin[16];
    int32_t n;
    sio_ns_router_init_c(&router);
    if (sio_ns_router_register_c(&router, (const uint8_t *)"/", 1, 0) != 0)
        return 1;
    if (sio_ns_router_register_c(&router, ns_chat, 5, 10) != 0)
        return 2;
    if (sio_ns_router_register_c(&router, ns_admin, 6, 20) != 0)
        return 3;
    if (sio_ns_sessions_sync_router_c(&sessions, &router) != 0)
        return 4;
    n = sio_encode_connect_packet_c(pkt_root, 8);
    if (n <= 0 || sio_ns_sessions_connect_c(&sessions, &router, pkt_root, n) != 0)
        return 5;
    n = sio_encode_connect_ns_packet_c(ns_chat, 5, pkt_chat, 16);
    if (n <= 0 || sio_ns_sessions_connect_c(&sessions, &router, pkt_chat, n) != 10)
        return 6;
    n = sio_encode_connect_ns_packet_c(ns_admin, 6, pkt_admin, 16);
    if (n <= 0 || sio_ns_sessions_connect_c(&sessions, &router, pkt_admin, n) != 20)
        return 7;
    if (sio_ns_sessions_total_c(&sessions) != 3)
        return 8;
    if (sio_ns_sessions_active_c(&sessions, 10) != 1)
        return 9;
    n = sio_encode_connect_ns_packet_c(ns_chat, 5, pkt_chat, 16);
    if (n <= 0 || sio_ns_sessions_connect_c(&sessions, &router, pkt_chat, n) != 10)
        return 10;
    if (sio_ns_sessions_active_c(&sessions, 10) != 2)
        return 11;
    if (sio_ns_sessions_total_c(&sessions) != 4)
        return 12;
    if (sio_ns_sessions_disconnect_c(&sessions, 10) != 0)
        return 13;
    if (sio_ns_sessions_active_c(&sessions, 10) != 1 || sio_ns_sessions_total_c(&sessions) != 3)
        return 14;
    return 0;
}

/** 返回 sio_ws_hub_t 字节数（mod.sx 布局须匹配）。 */
int32_t sio_ws_hub_bytes_c(void) { return (int32_t)sizeof(sio_ws_hub_t); }

/** 清空 WS hub（全部槽位 in_use=0，fd=-1）。 */
void sio_ws_hub_init_c(sio_ws_hub_t *h) {
    int32_t i;
    if (!h)
        return;
    memset(h, 0, sizeof(*h));
    for (i = 0; i < SIO_WS_HUB_MAX; i++)
        h->slot[i].fd = -1;
}

/** 在 hub 中找第一个空闲槽位；-1 表示已满。 */
static int32_t sio_ws_hub_alloc_slot_c(sio_ws_hub_t *h) {
    int32_t i;
    if (!h)
        return -1;
    for (i = 0; i < SIO_WS_HUB_MAX; i++) {
        if (!h->slot[i].in_use)
            return i;
    }
    return -1;
}

/**
 * 注册 WS 连接并持久化 sid（内存映射；供重连查找）。
 * @return 槽位下标 0..3，失败 -1
 */
int32_t sio_ws_hub_register_c(sio_ws_hub_t *h, int32_t fd, int64_t tls_ctx, const uint8_t *sid, int32_t sid_len) {
    int32_t idx;
    sio_ws_hub_slot_t *sl;
    if (!h || fd < 0)
        return -1;
    if (sid_len <= 0 || sid_len > SIO_WS_SID_CAP || !sid)
        return -1;
    idx = sio_ws_hub_alloc_slot_c(h);
    if (idx < 0)
        return -1;
    sl = &h->slot[idx];
    sl->in_use = 1;
    sl->fd = fd;
    sl->tls_ctx = tls_ctx;
    sl->sid_len = sid_len;
    memcpy(sl->sid, sid, (size_t)sid_len);
    sl->slot_id = -1;
    h->count++;
    return idx;
}

/** 注销 hub 槽位；未知槽 -1。 */
int32_t sio_ws_hub_unregister_c(sio_ws_hub_t *h, int32_t conn_idx) {
    sio_ws_hub_slot_t *sl;
    if (!h || conn_idx < 0 || conn_idx >= SIO_WS_HUB_MAX)
        return -1;
    sl = &h->slot[conn_idx];
    if (!sl->in_use)
        return -1;
    sl->in_use = 0;
    sl->fd = -1;
    sl->tls_ctx = 0;
    sl->sid_len = 0;
    sl->slot_id = -1;
    if (h->count > 0)
        h->count--;
    return 0;
}

/** 按 sid 查 hub 槽位；未找到 -1。 */
int32_t sio_ws_hub_find_by_sid_c(const sio_ws_hub_t *h, const uint8_t *sid, int32_t sid_len) {
    int32_t i;
    if (!h || sid_len <= 0 || !sid)
        return -1;
    for (i = 0; i < SIO_WS_HUB_MAX; i++) {
        const sio_ws_hub_slot_t *sl = &h->slot[i];
        if (!sl->in_use)
            continue;
        if (sl->sid_len != sid_len)
            continue;
        if (memcmp(sl->sid, sid, (size_t)sid_len) == 0)
            return i;
    }
    return -1;
}

/**
 * 注册或按 sid 重绑（import 后客户端重连：保持 slot/room 成员不变）。
 * @return 槽位下标，失败 -1
 */
int32_t sio_ws_hub_register_or_rebind_c(sio_ws_hub_t *h, int32_t fd, int64_t tls_ctx, const uint8_t *sid,
                                        int32_t sid_len) {
    int32_t idx;
    sio_ws_hub_slot_t *sl;
    if (!h || fd < 0 || sid_len <= 0 || sid_len > SIO_WS_SID_CAP || !sid)
        return -1;
    idx = sio_ws_hub_find_by_sid_c(h, sid, sid_len);
    if (idx >= 0) {
        sl = &h->slot[idx];
        if (sl->in_use) {
            sl->fd = fd;
            sl->tls_ctx = tls_ctx;
            return idx;
        }
    }
    return sio_ws_hub_register_c(h, fd, tls_ctx, sid, sid_len);
}

/**
 * 处理 CONNECT 包：路由 → 更新 sessions → 绑定 hub.slot_id。
 * @return router slot_id，失败 -1
 */
int32_t sio_ws_hub_handle_connect_c(sio_ws_hub_t *h, int32_t conn_idx, sio_ns_router_t *r, sio_ns_sessions_t *s,
                                    const uint8_t *pkt, int32_t len) {
    int32_t slot;
    sio_ws_hub_slot_t *sl;
    if (!h || !r || !s || !pkt || conn_idx < 0 || conn_idx >= SIO_WS_HUB_MAX)
        return -1;
    sl = &h->slot[conn_idx];
    if (!sl->in_use)
        return -1;
    slot = sio_ns_router_route_connect_c(r, pkt, len);
    if (slot < 0)
        return -1;
    if (sio_ns_sessions_connect_c(s, r, pkt, len) < 0)
        return -1;
    sl->slot_id = slot;
    return slot;
}

/**
 * 向 hub 内匹配 slot_id 的全部 WS 连接推送 namespace EVENT。
 * @return 成功写入的连接数（0 表示无匹配），编码/参数错误 -1
 */
int32_t sio_ws_hub_emit_event_ns_c(sio_ws_hub_t *h, int32_t slot_id, const uint8_t *ns, int32_t ns_len,
                                   const uint8_t *event, int32_t event_len, const uint8_t *data, int32_t data_len) {
    uint8_t frame[256];
    int32_t n;
    int32_t i;
    int32_t sent = 0;
    if (!h || slot_id < 0 || event_len <= 0 || !event)
        return -1;
    n = sio_encode_event_ns_packet_c(ns, ns_len, event, event_len, data, data_len, frame, (int32_t)sizeof(frame));
    if (n <= 0)
        return -1;
    for (i = 0; i < SIO_WS_HUB_MAX; i++) {
        sio_ws_hub_slot_t *sl = &h->slot[i];
        if (!sl->in_use || sl->slot_id != slot_id || sl->fd < 0)
            continue;
        if (net_ws_write_server_text_c(sl->fd, sl->tls_ctx, frame, n) == n)
            sent++;
    }
    return sent;
}

/**
 * 构建 namespace CONNECT ACK（例 `/chat` → `40/chat,{"sid":"sub"}`）。
 * @return EIO 帧字节数，失败 -1
 */
int32_t sio_server_build_connect_ns_ack_c(const uint8_t *ns, int32_t ns_len, const uint8_t *sid, int32_t sid_len,
                                          uint8_t *out, int32_t out_cap) {
    static const uint8_t jp[] = "{\"sid\":\"";
    static const uint8_t js[] = "\"}";
    uint8_t inner[128];
    int32_t off = 0;
    int32_t jl;
    if (!out || out_cap < 8)
        return -1;
    if (!sid || sid_len <= 0 || sid_len > 64)
        return -1;
    if (ns_len < 0)
        return -1;
    jl = (int32_t)(sizeof(jp) - 1) + sid_len + (int32_t)(sizeof(js) - 1);
    if (jl + 16 >= (int32_t)sizeof(inner))
        return -1;
    if (!ns || ns_len == 0 || (ns_len == 1 && ns[0] == (uint8_t)'/')) {
        inner[off++] = (uint8_t)('0' + SIO_SIO_CONNECT);
        if (sio_append_bytes(inner, (int32_t)sizeof(inner), &off, jp, (int32_t)(sizeof(jp) - 1)) != 0)
            return -1;
        if (sio_append_bytes(inner, (int32_t)sizeof(inner), &off, sid, sid_len) != 0)
            return -1;
        if (sio_append_bytes(inner, (int32_t)sizeof(inner), &off, js, (int32_t)(sizeof(js) - 1)) != 0)
            return -1;
        return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
    }
    if (ns[0] != (uint8_t)'/')
        return -1;
    inner[off++] = (uint8_t)('0' + SIO_SIO_CONNECT);
    if (sio_append_bytes(inner, (int32_t)sizeof(inner), &off, ns, ns_len) != 0)
        return -1;
    if (off + 1 >= (int32_t)sizeof(inner))
        return -1;
    inner[off++] = (uint8_t)',';
    if (sio_append_bytes(inner, (int32_t)sizeof(inner), &off, jp, (int32_t)(sizeof(jp) - 1)) != 0)
        return -1;
    if (sio_append_bytes(inner, (int32_t)sizeof(inner), &off, sid, sid_len) != 0)
        return -1;
    if (sio_append_bytes(inner, (int32_t)sizeof(inner), &off, js, (int32_t)(sizeof(js) - 1)) != 0)
        return -1;
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}

/** WS hub + CONNECT ACK 烟测（无 live server）。 */
int32_t sio_ws_hub_smoke_c(void) {
    static const uint8_t ns_chat[] = "/chat";
    static const uint8_t sid_a[] = "hubA";
    static const uint8_t sid_b[] = "hubB";
    static const uint8_t expect_ack[] = { '4', '0', '/', 'c', 'h', 'a', 't', ',', '{', '"', 's', 'i', 'd', '"', ':',
                                          '"', 's', 'u', 'b', '"', '}' };
    sio_ws_hub_t hub;
    sio_ns_router_t router;
    sio_ns_sessions_t sessions;
    uint8_t pkt_chat[16];
    uint8_t ack[64];
    int32_t pkt_len;
    int32_t ack_len;
    int32_t c0;
    int32_t c1;
    int32_t slot;
    int32_t sent;
    sio_ws_hub_init_c(&hub);
    sio_ns_router_init_c(&router);
    if (sio_ns_router_register_c(&router, ns_chat, 5, 10) != 0)
        return 1;
    if (sio_ns_sessions_sync_router_c(&sessions, &router) != 0)
        return 2;
    c0 = sio_ws_hub_register_c(&hub, 10, 0, sid_a, 4);
    c1 = sio_ws_hub_register_c(&hub, 11, 0, sid_b, 4);
    if (c0 != 0 || c1 != 1 || hub.count != 2)
        return 3;
    if (sio_ws_hub_find_by_sid_c(&hub, sid_b, 4) != 1)
        return 4;
    pkt_len = sio_encode_connect_ns_packet_c(ns_chat, 5, pkt_chat, 16);
    if (pkt_len <= 0)
        return 5;
    slot = sio_ws_hub_handle_connect_c(&hub, c0, &router, &sessions, pkt_chat, pkt_len);
    if (slot != 10 || hub.slot[c0].slot_id != 10)
        return 6;
    if (sio_ns_sessions_active_c(&sessions, 10) != 1)
        return 7;
    ack_len = sio_server_build_connect_ns_ack_c(ns_chat, 5, (const uint8_t *)"sub", 3, ack, 64);
    if (ack_len != (int32_t)sizeof(expect_ack) || memcmp(ack, expect_ack, (size_t)ack_len) != 0)
        return 8;
    if (sio_ws_hub_handle_connect_c(&hub, c1, &router, &sessions, pkt_chat, pkt_len) != 10)
        return 9;
    sent = sio_ws_hub_emit_event_ns_c(&hub, 10, ns_chat, 5, (const uint8_t *)"ping", 4, (const uint8_t *)"ok", 2);
    if (sent < 0)
        return 10;
    if (sio_ws_hub_unregister_c(&hub, c0) != 0 || hub.count != 1)
        return 11;
    return 0;
}

/**
 * 向单个 hub 连接推送 namespace EVENT。
 * @return 1 成功写入，0 未发送，-1 参数/编码错误
 */
static int32_t sio_ws_hub_emit_event_ns_conn_c(sio_ws_hub_t *h, int32_t conn_idx, const uint8_t *ns, int32_t ns_len,
                                               const uint8_t *event, int32_t event_len, const uint8_t *data,
                                               int32_t data_len) {
    uint8_t frame[256];
    int32_t n;
    sio_ws_hub_slot_t *sl;
    if (!h || conn_idx < 0 || conn_idx >= SIO_WS_HUB_MAX || event_len <= 0 || !event)
        return -1;
    sl = &h->slot[conn_idx];
    if (!sl->in_use || sl->fd < 0)
        return 0;
    n = sio_encode_event_ns_packet_c(ns, ns_len, event, event_len, data, data_len, frame, (int32_t)sizeof(frame));
    if (n <= 0)
        return -1;
    if (net_ws_write_server_text_c(sl->fd, sl->tls_ctx, frame, n) == n)
        return 1;
    return 0;
}

/** 返回 sio_ws_hub_snapshot_t 字节数。 */
int32_t sio_ws_hub_snapshot_bytes_c(void) { return (int32_t)sizeof(sio_ws_hub_snapshot_t); }

/**
 * 导出 hub 会话快照（sid + slot_id；不含 fd/tls）。
 * @return 写入字节数，失败 -1
 */
int32_t sio_ws_hub_export_c(const sio_ws_hub_t *h, uint8_t *out, int32_t out_cap) {
    sio_ws_hub_snapshot_t snap;
    int32_t i;
    if (!h || !out || out_cap < (int32_t)sizeof(snap))
        return -1;
    memset(&snap, 0, sizeof(snap));
    snap.magic = SIO_HUB_SNAP_MAGIC;
    snap.version = SIO_HUB_SNAP_VERSION;
    for (i = 0; i < SIO_WS_HUB_MAX; i++) {
        const sio_ws_hub_slot_t *sl = &h->slot[i];
        snap.slot[i].in_use = sl->in_use;
        snap.slot[i].sid_len = sl->sid_len;
        snap.slot[i].slot_id = sl->slot_id;
        if (sl->sid_len > 0)
            memcpy(snap.slot[i].sid, sl->sid, (size_t)sl->sid_len);
    }
    memcpy(out, &snap, sizeof(snap));
    return (int32_t)sizeof(snap);
}

/**
 * 从快照恢复 hub 元数据（fd=-1；须 ws_hub_register 重绑 fd 或 find_by_sid 后更新）。
 * @return 0 成功，-1 格式错误
 */
int32_t sio_ws_hub_import_c(sio_ws_hub_t *h, const uint8_t *buf, int32_t len) {
    const sio_ws_hub_snapshot_t *snap;
    int32_t i;
    int32_t active = 0;
    if (!h || !buf || len < (int32_t)sizeof(sio_ws_hub_snapshot_t))
        return -1;
    snap = (const sio_ws_hub_snapshot_t *)buf;
    if (snap->magic != SIO_HUB_SNAP_MAGIC || snap->version != SIO_HUB_SNAP_VERSION)
        return -1;
    sio_ws_hub_init_c(h);
    for (i = 0; i < SIO_WS_HUB_MAX; i++) {
        sio_ws_hub_slot_t *sl = &h->slot[i];
        const sio_ws_hub_snap_slot_t *ss = &snap->slot[i];
        if (!ss->in_use)
            continue;
        if (ss->sid_len <= 0 || ss->sid_len > SIO_WS_SID_CAP)
            return -1;
        sl->in_use = 1;
        sl->fd = -1;
        sl->tls_ctx = 0;
        sl->sid_len = ss->sid_len;
        sl->slot_id = ss->slot_id;
        memcpy(sl->sid, ss->sid, (size_t)ss->sid_len);
        active++;
    }
    h->count = active;
    return 0;
}

/** 返回 sio_room_registry_t 字节数（mod.sx 布局须匹配）。 */
int32_t sio_room_registry_bytes_c(void) { return (int32_t)sizeof(sio_room_registry_t); }

/** 清空 room 注册表。 */
void sio_room_registry_init_c(sio_room_registry_t *reg) {
    if (!reg)
        return;
    memset(reg, 0, sizeof(*reg));
}

/** 在 room 表中找空闲槽；-1 已满。 */
static int32_t sio_room_alloc_slot_c(sio_room_registry_t *reg) {
    int32_t i;
    if (!reg)
        return -1;
    for (i = 0; i < SIO_ROOM_MAX; i++) {
        if (!reg->room[i].in_use)
            return i;
    }
    return -1;
}

/** 按 room_id 查 room 下标；-1 未找到。 */
static int32_t sio_room_find_id_c(const sio_room_registry_t *reg, int32_t room_id) {
    int32_t i;
    if (!reg || room_id < 0)
        return -1;
    for (i = 0; i < SIO_ROOM_MAX; i++) {
        if (reg->room[i].in_use && reg->room[i].room_id == room_id)
            return i;
    }
    return -1;
}

/**
 * 注册 room 名称与 id（内存表；room_id 由调用方指定）。
 * @return 0 成功，-1 失败或 id 冲突
 */
int32_t sio_room_register_c(sio_room_registry_t *reg, const uint8_t *name, int32_t name_len, int32_t room_id) {
    int32_t idx;
    sio_room_t *rm;
    if (!reg || room_id < 0)
        return -1;
    if (name_len <= 0 || name_len > SIO_ROOM_NAME_CAP || !name)
        return -1;
    if (sio_room_find_id_c(reg, room_id) >= 0)
        return -1;
    idx = sio_room_alloc_slot_c(reg);
    if (idx < 0)
        return -1;
    rm = &reg->room[idx];
    rm->in_use = 1;
    rm->room_id = room_id;
    rm->name_len = name_len;
    rm->member_count = 0;
    memcpy(rm->name, name, (size_t)name_len);
    reg->count++;
    return 0;
}

/**
 * 将 hub 连接加入 room。
 * @return 0 成功，-1 失败或已满
 */
int32_t sio_room_join_c(sio_room_registry_t *reg, int32_t room_id, int32_t conn_idx) {
    int32_t idx;
    sio_room_t *rm;
    int32_t i;
    if (!reg || conn_idx < 0 || conn_idx >= SIO_WS_HUB_MAX)
        return -1;
    idx = sio_room_find_id_c(reg, room_id);
    if (idx < 0)
        return -1;
    rm = &reg->room[idx];
    for (i = 0; i < rm->member_count; i++) {
        if (rm->members[i] == conn_idx)
            return 0;
    }
    if (rm->member_count >= SIO_ROOM_MEMBERS_MAX)
        return -1;
    rm->members[rm->member_count++] = conn_idx;
    return 0;
}

/** 从 room 移除 hub 连接；不在 room 中返回 0。 */
int32_t sio_room_leave_c(sio_room_registry_t *reg, int32_t room_id, int32_t conn_idx) {
    int32_t idx;
    sio_room_t *rm;
    int32_t i;
    int32_t j;
    if (!reg || conn_idx < 0)
        return -1;
    idx = sio_room_find_id_c(reg, room_id);
    if (idx < 0)
        return -1;
    rm = &reg->room[idx];
    for (i = 0; i < rm->member_count; i++) {
        if (rm->members[i] != conn_idx)
            continue;
        for (j = i + 1; j < rm->member_count; j++)
            rm->members[j - 1] = rm->members[j];
        rm->member_count--;
        return 0;
    }
    return 0;
}

/** 从全部 room 移除指定 hub 连接（unregister 前调用）。 */
int32_t sio_room_leave_all_c(sio_room_registry_t *reg, int32_t conn_idx) {
    int32_t i;
    int32_t n = 0;
    if (!reg || conn_idx < 0)
        return -1;
    for (i = 0; i < SIO_ROOM_MAX; i++) {
        if (!reg->room[i].in_use)
            continue;
        if (sio_room_leave_c(reg, reg->room[i].room_id, conn_idx) == 0)
            n++;
    }
    return n;
}

/** 查询 room 成员数；-1 未知 room。 */
int32_t sio_room_member_count_c(const sio_room_registry_t *reg, int32_t room_id) {
    int32_t idx;
    if (!reg)
        return -1;
    idx = sio_room_find_id_c(reg, room_id);
    if (idx < 0)
        return -1;
    return reg->room[idx].member_count;
}

/**
 * 向 room 内全部成员广播 namespace EVENT。
 * @return 成功写入的连接数，编码/参数错误 -1
 */
int32_t sio_room_broadcast_ns_c(sio_room_registry_t *reg, sio_ws_hub_t *h, int32_t room_id, const uint8_t *ns,
                                int32_t ns_len, const uint8_t *event, int32_t event_len, const uint8_t *data,
                                int32_t data_len) {
    int32_t idx;
    const sio_room_t *rm;
    int32_t i;
    int32_t sent = 0;
    int32_t rc;
    if (!reg || !h || event_len <= 0 || !event)
        return -1;
    idx = sio_room_find_id_c(reg, room_id);
    if (idx < 0)
        return -1;
    rm = &reg->room[idx];
    for (i = 0; i < rm->member_count; i++) {
        rc = sio_ws_hub_emit_event_ns_conn_c(h, rm->members[i], ns, ns_len, event, event_len, data, data_len);
        if (rc < 0)
            return -1;
        if (rc > 0)
            sent++;
    }
    return sent;
}

/** room + hub 快照 烟测（无 live server）。 */
int32_t sio_room_smoke_c(void) {
    static const uint8_t ns_chat[] = "/chat";
    static const uint8_t room_name[] = "lobby";
    static const uint8_t sid_a[] = "snapA";
    static const uint8_t sid_b[] = "snapB";
    sio_ws_hub_t hub;
    sio_room_registry_t reg;
    uint8_t snap[256];
    int32_t snap_len;
    int32_t c0;
    int32_t c1;
    int32_t sent;
    sio_ws_hub_init_c(&hub);
    sio_room_registry_init_c(&reg);
    c0 = sio_ws_hub_register_c(&hub, 10, 0, sid_a, 5);
    c1 = sio_ws_hub_register_c(&hub, 11, 0, sid_b, 5);
    if (c0 != 0 || c1 != 1)
        return 1;
    if (sio_room_register_c(&reg, room_name, 5, 1) != 0)
        return 2;
    if (sio_room_join_c(&reg, 1, c0) != 0 || sio_room_join_c(&reg, 1, c1) != 0)
        return 3;
    if (sio_room_member_count_c(&reg, 1) != 2)
        return 4;
    sent = sio_room_broadcast_ns_c(&reg, &hub, 1, ns_chat, 5, (const uint8_t *)"msg", 3, (const uint8_t *)"hi", 2);
    if (sent < 0)
        return 5;
    snap_len = sio_ws_hub_export_c(&hub, snap, 256);
    if (snap_len != sio_ws_hub_snapshot_bytes_c())
        return 6;
    sio_ws_hub_init_c(&hub);
    if (sio_ws_hub_import_c(&hub, snap, snap_len) != 0)
        return 7;
    if (sio_ws_hub_find_by_sid_c(&hub, sid_b, 5) < 0 || hub.count != 2)
        return 8;
    if (hub.slot[0].fd != -1 || hub.slot[0].sid_len != 5)
        return 9;
    if (sio_room_leave_c(&reg, 1, c0) != 0 || sio_room_member_count_c(&reg, 1) != 1)
        return 10;
    if (sio_room_leave_all_c(&reg, c1) < 0 || sio_room_member_count_c(&reg, 1) != 0)
        return 11;
    return 0;
}

/**
 * import 后重绑 hub 槽位 fd/tls（跨进程恢复 WS 连接）。
 * @return 0 成功，-1 无效 conn_idx 或未使用槽
 */
int32_t sio_ws_hub_rebind_c(sio_ws_hub_t *h, int32_t conn_idx, int32_t fd, int64_t tls_ctx) {
    sio_ws_hub_slot_t *sl;
    if (!h || conn_idx < 0 || conn_idx >= SIO_WS_HUB_MAX || fd < 0)
        return -1;
    sl = &h->slot[conn_idx];
    if (!sl->in_use)
        return -1;
    sl->fd = fd;
    sl->tls_ctx = tls_ctx;
    return 0;
}

/** 返回 sio_room_registry_snapshot_t 字节数。 */
int32_t sio_room_registry_snapshot_bytes_c(void) { return (int32_t)sizeof(sio_room_registry_snapshot_t); }

/**
 * 导出 room 注册表快照（名称/成员 conn_idx）。
 * @return 写入字节数，失败 -1
 */
int32_t sio_room_registry_export_c(const sio_room_registry_t *reg, uint8_t *out, int32_t out_cap) {
    sio_room_registry_snapshot_t snap;
    if (!reg || !out || out_cap < (int32_t)sizeof(snap))
        return -1;
    memset(&snap, 0, sizeof(snap));
    snap.magic = SIO_ROOM_SNAP_MAGIC;
    snap.version = SIO_ROOM_SNAP_VERSION;
    snap.count = reg->count;
    memcpy(snap.room, reg->room, sizeof(reg->room));
    memcpy(out, &snap, sizeof(snap));
    return (int32_t)sizeof(snap);
}

/**
 * 从快照恢复 room 注册表。
 * @return 0 成功，-1 格式错误
 */
int32_t sio_room_registry_import_c(sio_room_registry_t *reg, const uint8_t *buf, int32_t len) {
    const sio_room_registry_snapshot_t *snap;
    if (!reg || !buf || len < (int32_t)sizeof(sio_room_registry_snapshot_t))
        return -1;
    snap = (const sio_room_registry_snapshot_t *)buf;
    if (snap->magic != SIO_ROOM_SNAP_MAGIC || snap->version != SIO_ROOM_SNAP_VERSION)
        return -1;
    sio_room_registry_init_c(reg);
    reg->count = snap->count;
    memcpy(reg->room, snap->room, sizeof(reg->room));
    return 0;
}

/**
 * hub + room 跨进程同步烟测：export → import → rebind fd。
 * @return 0 成功，非 0 失败码
 */
int32_t sio_hub_sync_smoke_c(void) {
    static const uint8_t sid[] = "sync1";
    static const uint8_t room_name[] = "lobby";
    sio_ws_hub_t hub_a;
    sio_ws_hub_t hub_b;
    sio_room_registry_t reg_a;
    sio_room_registry_t reg_b;
    uint8_t hub_snap[256];
    uint8_t room_snap[256];
    int32_t hl;
    int32_t rl;
    sio_ws_hub_init_c(&hub_a);
    sio_room_registry_init_c(&reg_a);
    if (sio_ws_hub_register_c(&hub_a, 20, 0, sid, 5) != 0)
        return 1;
    if (sio_room_register_c(&reg_a, room_name, 5, 1) != 0)
        return 2;
    if (sio_room_join_c(&reg_a, 1, 0) != 0)
        return 3;
    hl = sio_ws_hub_export_c(&hub_a, hub_snap, 256);
    rl = sio_room_registry_export_c(&reg_a, room_snap, 256);
    if (hl != sio_ws_hub_snapshot_bytes_c() || rl != sio_room_registry_snapshot_bytes_c())
        return 4;
    sio_ws_hub_init_c(&hub_b);
    sio_room_registry_init_c(&reg_b);
    if (sio_ws_hub_import_c(&hub_b, hub_snap, hl) != 0)
        return 5;
    if (sio_room_registry_import_c(&reg_b, room_snap, rl) != 0)
        return 6;
    if (sio_ws_hub_find_by_sid_c(&hub_b, sid, 5) != 0 || hub_b.count != 1)
        return 7;
    if (hub_b.slot[0].fd != -1)
        return 8;
    if (sio_room_member_count_c(&reg_b, 1) != 1)
        return 9;
    if (sio_ws_hub_rebind_c(&hub_b, 0, 99, 0) != 0 || hub_b.slot[0].fd != 99)
        return 10;
    return 0;
}

/** 返回 sio_session_bundle_t 字节数。 */
int32_t sio_session_bundle_bytes_c(void) { return (int32_t)sizeof(sio_session_bundle_t); }

/**
 * 导出 hub + room 一体快照（跨进程 session 自动同步）。
 * @return 写入字节数，失败 -1
 */
int32_t sio_session_bundle_export_c(const sio_ws_hub_t *h, const sio_room_registry_t *reg, uint8_t *out,
                                    int32_t out_cap) {
    sio_session_bundle_t bundle;
    int32_t i;
    if (!h || !reg || !out || out_cap < (int32_t)sizeof(bundle))
        return -1;
    memset(&bundle, 0, sizeof(bundle));
    bundle.magic = SIO_SESSION_SNAP_MAGIC;
    bundle.version = SIO_SESSION_SNAP_VERSION;
    bundle.hub.magic = SIO_HUB_SNAP_MAGIC;
    bundle.hub.version = SIO_HUB_SNAP_VERSION;
    for (i = 0; i < SIO_WS_HUB_MAX; i++) {
        const sio_ws_hub_slot_t *sl = &h->slot[i];
        bundle.hub.slot[i].in_use = sl->in_use;
        bundle.hub.slot[i].sid_len = sl->sid_len;
        bundle.hub.slot[i].slot_id = sl->slot_id;
        if (sl->sid_len > 0)
            memcpy(bundle.hub.slot[i].sid, sl->sid, (size_t)sl->sid_len);
    }
    bundle.room.magic = SIO_ROOM_SNAP_MAGIC;
    bundle.room.version = SIO_ROOM_SNAP_VERSION;
    bundle.room.count = reg->count;
    memcpy(bundle.room.room, reg->room, sizeof(reg->room));
    memcpy(out, &bundle, sizeof(bundle));
    return (int32_t)sizeof(bundle);
}

/**
 * 从一体快照恢复 hub + room。
 * @return 0 成功，-1 格式错误
 */
int32_t sio_session_bundle_import_c(sio_ws_hub_t *h, sio_room_registry_t *reg, const uint8_t *buf, int32_t len) {
    const sio_session_bundle_t *bundle;
    if (!h || !reg || !buf || len < (int32_t)sizeof(sio_session_bundle_t))
        return -1;
    bundle = (const sio_session_bundle_t *)buf;
    if (bundle->magic != SIO_SESSION_SNAP_MAGIC || bundle->version != SIO_SESSION_SNAP_VERSION)
        return -1;
    if (sio_ws_hub_import_c(h, (const uint8_t *)&bundle->hub, (int32_t)sizeof(bundle->hub)) != 0)
        return -1;
    if (sio_room_registry_import_c(reg, (const uint8_t *)&bundle->room, (int32_t)sizeof(bundle->room)) != 0)
        return -1;
    return 0;
}

/**
 * session 一体快照 + register_or_rebind 烟测（模拟多进程 room 自动同步）。
 * @return 0 成功，非 0 失败码
 */
int32_t sio_session_sync_smoke_c(void) {
    static const uint8_t sid[] = "sess1";
    static const uint8_t room_name[] = "lobby";
    static const uint8_t ns_chat[] = "/chat";
    sio_ws_hub_t hub_a;
    sio_ws_hub_t hub_b;
    sio_room_registry_t reg_a;
    sio_room_registry_t reg_b;
    uint8_t bundle_buf[512];
    int32_t blen;
    int32_t idx;
    int32_t sent;
    sio_ws_hub_init_c(&hub_a);
    sio_room_registry_init_c(&reg_a);
    if (sio_ws_hub_register_c(&hub_a, 30, 0, sid, 5) != 0)
        return 1;
    if (sio_room_register_c(&reg_a, room_name, 5, 1) != 0)
        return 2;
    if (sio_room_join_c(&reg_a, 1, 0) != 0)
        return 3;
    blen = sio_session_bundle_export_c(&hub_a, &reg_a, bundle_buf, 512);
    if (blen != sio_session_bundle_bytes_c())
        return 4;
    sio_ws_hub_init_c(&hub_b);
    sio_room_registry_init_c(&reg_b);
    if (sio_session_bundle_import_c(&hub_b, &reg_b, bundle_buf, blen) != 0)
        return 5;
    if (sio_room_member_count_c(&reg_b, 1) != 1)
        return 6;
    idx = sio_ws_hub_register_or_rebind_c(&hub_b, 88, 0, sid, 5);
    if (idx != 0 || hub_b.slot[0].fd != 88)
        return 7;
    if (sio_room_member_count_c(&reg_b, 1) != 1)
        return 8;
    sent = sio_room_broadcast_ns_c(&reg_b, &hub_b, 1, ns_chat, 5, (const uint8_t *)"msg", 3, (const uint8_t *)"hi", 2);
    if (sent < 0)
        return 9;
    return 0;
}

/** 重算 hub 活跃槽位数。 */
static void sio_ws_hub_recount_c(sio_ws_hub_t *h) {
    int32_t i;
    int32_t c = 0;
    if (!h)
        return;
    for (i = 0; i < SIO_WS_HUB_MAX; i++) {
        if (h->slot[i].in_use)
            c++;
    }
    h->count = c;
}

/**
 * 将 src hub 活跃槽追加到 dst（fd=-1；供集群节点 session 合并）。
 * @return 首个追加槽下标，无槽追加返回 0，失败 -1
 */
int32_t sio_ws_hub_append_from_c(sio_ws_hub_t *dst, const sio_ws_hub_t *src) {
    int32_t i;
    int32_t j;
    int32_t start = -1;
    if (!dst || !src)
        return -1;
    for (i = 0; i < SIO_WS_HUB_MAX; i++) {
        const sio_ws_hub_slot_t *sl = &src->slot[i];
        if (!sl->in_use)
            continue;
        j = sio_ws_hub_alloc_slot_c(dst);
        if (j < 0)
            return -1;
        if (start < 0)
            start = j;
        dst->slot[j] = *sl;
        dst->slot[j].fd = -1;
        dst->slot[j].tls_ctx = 0;
    }
    sio_ws_hub_recount_c(dst);
    return start >= 0 ? start : 0;
}

/**
 * 合并 src room 表到 dst（成员 conn_idx 加 offset，匹配 room_id）。
 * @return 0 成功，-1 失败
 */
int32_t sio_room_registry_merge_offset_c(sio_room_registry_t *dst, const sio_room_registry_t *src,
                                         int32_t conn_offset) {
    int32_t i;
    int32_t j;
    int32_t k;
    int32_t room_id;
    if (!dst || !src || conn_offset < 0)
        return -1;
    for (i = 0; i < SIO_ROOM_MAX; i++) {
        const sio_room_t *sr = &src->room[i];
        if (!sr->in_use)
            continue;
        room_id = sr->room_id;
        if (sio_room_find_id_c(dst, room_id) < 0) {
            if (sio_room_register_c(dst, sr->name, sr->name_len, room_id) != 0)
                return -1;
        }
        for (j = 0; j < sr->member_count; j++) {
            k = sr->members[j] + conn_offset;
            if (k < 0 || k >= SIO_WS_HUB_MAX)
                return -1;
            if (sio_room_join_c(dst, room_id, k) != 0)
                return -1;
        }
    }
    return 0;
}

/**
 * 集群合并两节点 session bundle（coordinator：import A + 追加 B hub/room）。
 * @return 0 成功，-1 失败
 */
int32_t sio_cluster_sync_c(sio_ws_hub_t *h, sio_room_registry_t *reg, const uint8_t *bundle_a, int32_t len_a,
                             const uint8_t *bundle_b, int32_t len_b) {
    sio_ws_hub_t hub_b;
    sio_room_registry_t reg_b;
    int32_t off;
    if (!h || !reg || !bundle_a || !bundle_b)
        return -1;
    if (sio_session_bundle_import_c(h, reg, bundle_a, len_a) != 0)
        return -1;
    sio_ws_hub_init_c(&hub_b);
    sio_room_registry_init_c(&reg_b);
    if (sio_session_bundle_import_c(&hub_b, &reg_b, bundle_b, len_b) != 0)
        return -1;
    off = sio_ws_hub_append_from_c(h, &hub_b);
    if (off < 0)
        return -1;
    return sio_room_registry_merge_offset_c(reg, &reg_b, off);
}

/**
 * 集群 session 合并烟测（两节点同 room → coordinator 2 成员）。
 * @return 0 成功，非 0 失败码
 */
int32_t sio_cluster_sync_smoke_c(void) {
    static const uint8_t sid_a[] = "nodeA";
    static const uint8_t sid_b[] = "nodeB";
    static const uint8_t room_name[] = "lobby";
    sio_ws_hub_t hub_a;
    sio_ws_hub_t hub_b;
    sio_ws_hub_t hub_c;
    sio_room_registry_t reg_a;
    sio_room_registry_t reg_b;
    sio_room_registry_t reg_c;
    uint8_t bundle_a[512];
    uint8_t bundle_b[512];
    int32_t len_a;
    int32_t len_b;
    sio_ws_hub_init_c(&hub_a);
    sio_room_registry_init_c(&reg_a);
    if (sio_ws_hub_register_c(&hub_a, 40, 0, sid_a, 5) != 0)
        return 1;
    if (sio_room_register_c(&reg_a, room_name, 5, 1) != 0)
        return 2;
    if (sio_room_join_c(&reg_a, 1, 0) != 0)
        return 3;
    sio_ws_hub_init_c(&hub_b);
    sio_room_registry_init_c(&reg_b);
    if (sio_ws_hub_register_c(&hub_b, 41, 0, sid_b, 5) != 0)
        return 4;
    if (sio_room_register_c(&reg_b, room_name, 5, 1) != 0)
        return 5;
    if (sio_room_join_c(&reg_b, 1, 0) != 0)
        return 6;
    len_a = sio_session_bundle_export_c(&hub_a, &reg_a, bundle_a, 512);
    len_b = sio_session_bundle_export_c(&hub_b, &reg_b, bundle_b, 512);
    if (len_a != sio_session_bundle_bytes_c() || len_b != sio_session_bundle_bytes_c())
        return 7;
    sio_ws_hub_init_c(&hub_c);
    sio_room_registry_init_c(&reg_c);
    if (sio_cluster_sync_c(&hub_c, &reg_c, bundle_a, len_a, bundle_b, len_b) != 0)
        return 8;
    if (hub_c.count != 2 || sio_room_member_count_c(&reg_c, 1) != 2)
        return 9;
    if (sio_ws_hub_find_by_sid_c(&hub_c, sid_a, 5) != 0 || sio_ws_hub_find_by_sid_c(&hub_c, sid_b, 5) != 1)
        return 10;
    if (hub_c.slot[0].fd != -1 || hub_c.slot[1].fd != -1)
        return 11;
    return 0;
}

/** 返回 sio_cluster_adapter_t 字节数（mod.sx 布局须匹配）。 */
int32_t sio_cluster_adapter_bytes_c(void) { return (int32_t)sizeof(sio_cluster_adapter_t); }

/** 初始化 cluster adapter。 */
void sio_cluster_adapter_init_c(sio_cluster_adapter_t *a, int32_t node_id) {
    if (!a)
        return;
    memset(a, 0, sizeof(*a));
    a->node_id = node_id;
}

/** 在 adapter 队列中找空闲槽；-1 已满。 */
static int32_t sio_cluster_adapter_alloc_c(sio_cluster_adapter_t *a) {
    int32_t i;
    if (!a)
        return -1;
    for (i = 0; i < SIO_CLUSTER_ADAPTER_MAX; i++) {
        if (!a->msg[i].in_use)
            return i;
    }
    return -1;
}

/**
 * 发布跨节点 room EVENT（模拟 Redis adapter publish）。
 * @return 0 成功，-1 失败或队列满
 */
int32_t sio_cluster_adapter_publish_ns_c(sio_cluster_adapter_t *a, int32_t src_node_id, int32_t room_id,
                                         const uint8_t *ns, int32_t ns_len, const uint8_t *event, int32_t event_len,
                                         const uint8_t *data, int32_t data_len) {
    int32_t idx;
    sio_cluster_adapter_msg_t *m;
    if (!a || src_node_id < 0 || room_id < 0 || event_len <= 0 || !event)
        return -1;
    if (ns_len < 0 || ns_len > SIO_CLUSTER_ADAPTER_NS_CAP)
        return -1;
    if (event_len > SIO_CLUSTER_ADAPTER_EVT_CAP)
        return -1;
    if (data_len < 0 || data_len > SIO_CLUSTER_ADAPTER_DATA_CAP)
        return -1;
    if (data_len > 0 && !data)
        return -1;
    idx = sio_cluster_adapter_alloc_c(a);
    if (idx < 0)
        return -1;
    m = &a->msg[idx];
    m->in_use = 1;
    m->src_node_id = src_node_id;
    m->room_id = room_id;
    m->ns_len = ns_len;
    m->event_len = event_len;
    m->data_len = data_len;
    if (ns_len > 0 && ns)
        memcpy(m->ns, ns, (size_t)ns_len);
    memcpy(m->event, event, (size_t)event_len);
    if (data_len > 0)
        memcpy(m->data, data, (size_t)data_len);
    a->count++;
    return 0;
}

/**
 * 消费 adapter 队列并本地 room 广播（跳过 src_node_id == local_node_id）。
 * @return 成功应用的消息数，参数错误 -1
 */
int32_t sio_cluster_adapter_drain_apply_c(sio_cluster_adapter_t *a, sio_ws_hub_t *h, sio_room_registry_t *reg,
                                          int32_t local_node_id) {
    int32_t i;
    int32_t applied = 0;
    int32_t sent;
    sio_cluster_adapter_msg_t *m;
    if (!a || !h || !reg || local_node_id < 0)
        return -1;
    for (i = 0; i < SIO_CLUSTER_ADAPTER_MAX; i++) {
        m = &a->msg[i];
        if (!m->in_use)
            continue;
        if (m->src_node_id == local_node_id)
            continue;
        sent = sio_room_broadcast_ns_c(reg, h, m->room_id, m->ns, m->ns_len, m->event, m->event_len, m->data,
                                       m->data_len);
        if (sent < 0)
            return -1;
        m->in_use = 0;
        if (a->count > 0)
            a->count--;
        applied++;
    }
    return applied;
}

/**
 * cluster adapter 烟测：node1 publish → node2 drain_apply。
 * @return 0 成功，非 0 失败码
 */
int32_t sio_cluster_adapter_smoke_c(void) {
    static const uint8_t ns_chat[] = "/chat";
    static const uint8_t room_name[] = "lobby";
    static const uint8_t sid[] = "nd2";
    sio_cluster_adapter_t adapter;
    sio_ws_hub_t hub;
    sio_room_registry_t reg;
    int32_t applied;
    sio_cluster_adapter_init_c(&adapter, 2);
    sio_ws_hub_init_c(&hub);
    sio_room_registry_init_c(&reg);
    if (sio_ws_hub_register_c(&hub, 50, 0, sid, 3) != 0)
        return 1;
    if (sio_room_register_c(&reg, room_name, 5, 1) != 0)
        return 2;
    if (sio_room_join_c(&reg, 1, 0) != 0)
        return 3;
    if (sio_cluster_adapter_publish_ns_c(&adapter, 1, 1, ns_chat, 5, (const uint8_t *)"msg", 3,
                                         (const uint8_t *)"hi", 2) != 0)
        return 4;
    applied = sio_cluster_adapter_drain_apply_c(&adapter, &hub, &reg, 2);
    if (applied != 1)
        return 5;
    if (adapter.count != 0)
        return 6;
    return 0;
}

/** 返回 sio_cluster_adapter_snapshot_t 字节数。 */
int32_t sio_cluster_adapter_snapshot_bytes_c(void) { return (int32_t)sizeof(sio_cluster_adapter_snapshot_t); }

/**
 * 导出 cluster adapter 快照（SIOA；供跨节点 ring 同步写文件）。
 * @return 写入字节数，失败 -1
 */
int32_t sio_cluster_adapter_export_c(const sio_cluster_adapter_t *a, uint8_t *out, int32_t out_cap) {
    sio_cluster_adapter_snapshot_t snap;
    if (!a || !out || out_cap < (int32_t)sizeof(snap))
        return -1;
    memset(&snap, 0, sizeof(snap));
    snap.magic = SIO_ADAPTER_SNAP_MAGIC;
    snap.version = SIO_ADAPTER_SNAP_VERSION;
    snap.count = a->count;
    snap.node_id = a->node_id;
    memcpy(snap.msg, a->msg, sizeof(a->msg));
    memcpy(out, &snap, sizeof(snap));
    return (int32_t)sizeof(snap);
}

/**
 * 从快照合并消息到 adapter（跳过已满；不覆盖 local node_id）。
 * @return 合并条数，格式错误 -1
 */
int32_t sio_cluster_adapter_import_merge_c(sio_cluster_adapter_t *a, const uint8_t *buf, int32_t len) {
    const sio_cluster_adapter_snapshot_t *snap;
    int32_t i;
    int32_t j;
    int32_t merged = 0;
    sio_cluster_adapter_msg_t *dst;
    const sio_cluster_adapter_msg_t *src;
    if (!a || !buf || len < (int32_t)sizeof(sio_cluster_adapter_snapshot_t))
        return -1;
    snap = (const sio_cluster_adapter_snapshot_t *)buf;
    if (snap->magic != SIO_ADAPTER_SNAP_MAGIC || snap->version != SIO_ADAPTER_SNAP_VERSION)
        return -1;
    for (i = 0; i < SIO_CLUSTER_ADAPTER_MAX; i++) {
        src = &snap->msg[i];
        if (!src->in_use)
            continue;
        j = sio_cluster_adapter_alloc_c(a);
        if (j < 0)
            return -1;
        dst = &a->msg[j];
        *dst = *src;
        merged++;
        a->count++;
    }
    return merged;
}

/**
 * cluster ring 烟测：node1 publish → export → node2 import_merge → drain_apply。
 * @return 0 成功，非 0 失败码
 */
int32_t sio_cluster_ring_sync_smoke_c(void) {
    static const uint8_t ns_chat[] = "/chat";
    static const uint8_t room_name[] = "lobby";
    static const uint8_t sid[] = "nd2";
    sio_cluster_adapter_t adapter_a;
    sio_cluster_adapter_t adapter_b;
    sio_ws_hub_t hub;
    sio_room_registry_t reg;
    uint8_t snap[512];
    int32_t slen;
    int32_t merged;
    int32_t applied;
    sio_cluster_adapter_init_c(&adapter_a, 1);
    sio_cluster_adapter_init_c(&adapter_b, 2);
    sio_ws_hub_init_c(&hub);
    sio_room_registry_init_c(&reg);
    if (sio_ws_hub_register_c(&hub, 60, 0, sid, 3) != 0)
        return 1;
    if (sio_room_register_c(&reg, room_name, 5, 1) != 0)
        return 2;
    if (sio_room_join_c(&reg, 1, 0) != 0)
        return 3;
    if (sio_cluster_adapter_publish_ns_c(&adapter_a, 1, 1, ns_chat, 5, (const uint8_t *)"msg", 3,
                                         (const uint8_t *)"hi", 2) != 0)
        return 4;
    slen = sio_cluster_adapter_export_c(&adapter_a, snap, 512);
    if (slen != sio_cluster_adapter_snapshot_bytes_c())
        return 5;
    merged = sio_cluster_adapter_import_merge_c(&adapter_b, snap, slen);
    if (merged != 1)
        return 6;
    applied = sio_cluster_adapter_drain_apply_c(&adapter_b, &hub, &reg, 2);
    if (applied != 1)
        return 7;
    return 0;
}

/**
 * 向 out 追加 JSON 字符串字面量（"..."，内部 " 与 \\ 转义）。
 * @return 0 成功，-1 缓冲不足
 */
static int32_t sio_append_json_string(uint8_t *out, int32_t cap, int32_t *off, const uint8_t *s, int32_t slen) {
    int32_t i;
    if (!out || !off || *off < 0)
        return -1;
    if (slen > 0 && !s)
        return -1;
    if (*off + 1 >= cap)
        return -1;
    out[(*off)++] = (uint8_t)'"';
    for (i = 0; i < slen; i++) {
        uint8_t c = s[i];
        if (c == (uint8_t)'"' || c == (uint8_t)'\\') {
            if (*off + 2 >= cap)
                return -1;
            out[(*off)++] = (uint8_t)'\\';
            out[(*off)++] = c;
            continue;
        }
        if (*off >= cap)
            return -1;
        out[(*off)++] = c;
    }
    if (*off >= cap)
        return -1;
    out[(*off)++] = (uint8_t)'"';
    return 0;
}

/**
 * 编码 Engine.IO 包：首位 type 字符 + payload。
 * @return 写入字节数（不含 NUL），失败 -1
 */
int32_t sio_eio_encode_packet_c(int32_t type, const uint8_t *payload, int32_t payload_len, uint8_t *out,
                                int32_t out_cap) {
    int32_t n = 0;
    if (!out || out_cap < 1)
        return -1;
    if (type < 0 || type > 9)
        return -1;
    if (payload_len < 0)
        return -1;
    if (payload_len > 0 && !payload)
        return -1;
    if (1 + payload_len > out_cap)
        return -1;
    out[n++] = (uint8_t)('0' + type);
    if (payload_len > 0) {
        memcpy(out + n, payload, (size_t)payload_len);
        n += payload_len;
    }
    return n;
}

/**
 * 解码 Engine.IO 包；成功 0 并写 *out_type / *out_payload_len。
 */
int32_t sio_eio_decode_packet_c(const uint8_t *buf, int32_t len, int32_t *out_type, uint8_t *out_payload,
                                int32_t out_cap, int32_t *out_payload_len) {
    int32_t type;
    int32_t plen;
    if (!buf || len <= 0 || !out_type || !out_payload_len)
        return -1;
    if (buf[0] < (uint8_t)'0' || buf[0] > (uint8_t)'9')
        return -1;
    type = (int32_t)(buf[0] - (uint8_t)'0');
    plen = len - 1;
    if (plen < 0)
        plen = 0;
    if (plen > 0 && !out_payload)
        return -1;
    if (plen > out_cap)
        return -1;
    *out_type = type;
    if (plen > 0)
        memcpy(out_payload, buf + 1, (size_t)plen);
    *out_payload_len = plen;
    return 0;
}

/**
 * 编码 Socket.IO EVENT 并封装为 Engine.IO message 包（type=4）。
 * 格式：42["event","data"]（data 为 UTF-8 文本）。
 */
int32_t sio_encode_event_packet_c(const uint8_t *event, int32_t event_len, const uint8_t *data, int32_t data_len,
                                  uint8_t *out, int32_t out_cap) {
    uint8_t inner[512];
    int32_t off = 0;
    int32_t inner_len;
    if (!out || out_cap < 4)
        return -1;
    if (event_len <= 0 || !event)
        return -1;
    if (data_len < 0)
        return -1;
    if (data_len > 0 && !data)
        return -1;
    if ((int32_t)sizeof(inner) < 8)
        return -1;
    inner[off++] = (uint8_t)('0' + SIO_SIO_EVENT);
    inner[off++] = (uint8_t)'[';
    if (sio_append_json_string(inner, (int32_t)sizeof(inner), &off, event, event_len) != 0)
        return -1;
    if (off + 1 >= (int32_t)sizeof(inner))
        return -1;
    inner[off++] = (uint8_t)',';
    if (data_len == 0) {
        if (sio_append_json_string(inner, (int32_t)sizeof(inner), &off, (const uint8_t *)"", 0) != 0)
            return -1;
    } else if (sio_append_json_string(inner, (int32_t)sizeof(inner), &off, data, data_len) != 0) {
        return -1;
    }
    if (off >= (int32_t)sizeof(inner))
        return -1;
    inner[off++] = (uint8_t)']';
    inner_len = off;
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, inner_len, out, out_cap);
}

/**
 * 编码指定 namespace 的 Socket.IO EVENT（例 `/chat` → `42/chat,["ping","x"]`）。
 * ns 为空或 `/` 时等同 sio_encode_event_packet_c。
 */
int32_t sio_encode_event_ns_packet_c(const uint8_t *ns, int32_t ns_len, const uint8_t *event, int32_t event_len,
                                     const uint8_t *data, int32_t data_len, uint8_t *out, int32_t out_cap) {
    uint8_t inner[512];
    int32_t off = 0;
    if (!out || out_cap < 4)
        return -1;
    if (ns_len < 0)
        return -1;
    if (!ns || ns_len == 0 || (ns_len == 1 && ns[0] == (uint8_t)'/'))
        return sio_encode_event_packet_c(event, event_len, data, data_len, out, out_cap);
    if (ns[0] != (uint8_t)'/')
        return -1;
    if (event_len <= 0 || !event)
        return -1;
    if (data_len < 0)
        return -1;
    if (data_len > 0 && !data)
        return -1;
    inner[off++] = (uint8_t)('0' + SIO_SIO_EVENT);
    if (sio_append_bytes(inner, (int32_t)sizeof(inner), &off, ns, ns_len) != 0)
        return -1;
    if (off + 1 >= (int32_t)sizeof(inner))
        return -1;
    inner[off++] = (uint8_t)',';
    inner[off++] = (uint8_t)'[';
    if (sio_append_json_string(inner, (int32_t)sizeof(inner), &off, event, event_len) != 0)
        return -1;
    if (off + 1 >= (int32_t)sizeof(inner))
        return -1;
    inner[off++] = (uint8_t)',';
    if (data_len == 0) {
        if (sio_append_json_string(inner, (int32_t)sizeof(inner), &off, (const uint8_t *)"", 0) != 0)
            return -1;
    } else if (sio_append_json_string(inner, (int32_t)sizeof(inner), &off, data, data_len) != 0) {
        return -1;
    }
    if (off >= (int32_t)sizeof(inner))
        return -1;
    inner[off++] = (uint8_t)']';
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}

/**
 * 编码带 packet id 的 Socket.IO EVENT（ack_id<0 时等同 sio_encode_event_packet_c）。
 * 例：42123["ping","pong"]。
 */
int32_t sio_encode_event_ack_packet_c(int32_t ack_id, const uint8_t *event, int32_t event_len,
                                      const uint8_t *data, int32_t data_len, uint8_t *out, int32_t out_cap) {
    uint8_t inner[512];
    int32_t off = 0;
    int32_t inner_len;
    if (!out || out_cap < 4)
        return -1;
    if (ack_id < 0)
        return sio_encode_event_packet_c(event, event_len, data, data_len, out, out_cap);
    if (event_len <= 0 || !event)
        return -1;
    if (data_len < 0)
        return -1;
    if (data_len > 0 && !data)
        return -1;
    inner[off++] = (uint8_t)('0' + SIO_SIO_EVENT);
    if (sio_append_u32_dec(inner, (int32_t)sizeof(inner), &off, (uint32_t)ack_id) != 0)
        return -1;
    inner[off++] = (uint8_t)'[';
    if (sio_append_json_string(inner, (int32_t)sizeof(inner), &off, event, event_len) != 0)
        return -1;
    if (off + 1 >= (int32_t)sizeof(inner))
        return -1;
    inner[off++] = (uint8_t)',';
    if (data_len == 0) {
        if (sio_append_json_string(inner, (int32_t)sizeof(inner), &off, (const uint8_t *)"", 0) != 0)
            return -1;
    } else if (sio_append_json_string(inner, (int32_t)sizeof(inner), &off, data, data_len) != 0) {
        return -1;
    }
    if (off >= (int32_t)sizeof(inner))
        return -1;
    inner[off++] = (uint8_t)']';
    inner_len = off;
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, inner_len, out, out_cap);
}

/**
 * 编码 Socket.IO ACK 包（type=3 + id + JSON 数组单字符串）。
 * 例：453["ok"]。
 */
int32_t sio_encode_ack_packet_c(int32_t ack_id, const uint8_t *data, int32_t data_len, uint8_t *out,
                                int32_t out_cap) {
    uint8_t inner[256];
    int32_t off = 0;
    if (ack_id < 0 || !out)
        return -1;
    if (data_len < 0)
        return -1;
    if (data_len > 0 && !data)
        return -1;
    inner[off++] = (uint8_t)('0' + SIO_SIO_ACK);
    if (sio_append_u32_dec(inner, (int32_t)sizeof(inner), &off, (uint32_t)ack_id) != 0)
        return -1;
    inner[off++] = (uint8_t)'[';
    if (sio_append_json_string(inner, (int32_t)sizeof(inner), &off, data, data_len) != 0)
        return -1;
    inner[off++] = (uint8_t)']';
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}

/** namespace / ACK / 带 id EVENT 烟测（无 live server）。 */
int32_t sio_ns_ack_smoke_c(void) {
    static const uint8_t ns_chat[] = "/chat";
    static const uint8_t expect_ns[] = "40/chat,";
    static const uint8_t evt[] = "ping";
    static const uint8_t data[] = "pong";
    static const uint8_t expect_evt_ack[] = { '4', '2', '1', '2', '3', '[', '"', 'p', 'i', 'n', 'g', '"', ',', '"',
                                              'p', 'o', 'n', 'g', '"', ']' };
    static const uint8_t expect_evt_ns[] = { '4', '2', '/', 'c', 'h', 'a', 't', ',', '[', '"', 'p', 'i', 'n', 'g',
                                             '"', ',', '"', 'x', '"', ']' };
    static const uint8_t expect_ack[] = { '4', '3', '5', '3', '[', '"', 'o', 'k', '"', ']' };
    uint8_t enc[64];
    uint8_t evt_out[16];
    uint8_t data_out[16];
    int32_t stype = -1;
    int32_t sid = -1;
    int32_t poff = 0;
    int32_t dlen = 0;
    int32_t n;
    n = sio_encode_connect_ns_packet_c(ns_chat, 5, enc, 64);
    if (n != (int32_t)(sizeof(expect_ns) - 1) || memcmp(enc, expect_ns, (size_t)n) != 0)
        return 1;
    if (sio_server_is_connect_ns_packet_c(enc, n, ns_chat, 5) != 1)
        return 2;
    if (sio_server_is_connect_ns_packet_c((const uint8_t *)"40", 2, (const uint8_t *)"/", 1) != 1)
        return 3;
    n = sio_encode_event_ack_packet_c(123, evt, 4, data, 4, enc, 64);
    if (n != (int32_t)sizeof(expect_evt_ack) || memcmp(enc, expect_evt_ack, (size_t)n) != 0)
        return 4;
    if (sio_parse_sio_packet_head_c(enc + 1, n - 1, &stype, &sid, &poff) != 0)
        return 5;
    if (stype != SIO_SIO_EVENT || sid != 123 || enc[1 + poff] != (uint8_t)'[')
        return 6;
    if (sio_decode_event_packet_c(enc + 1, n - 1, evt_out, 16, data_out, 16, &dlen) != 0)
        return 7;
    n = sio_encode_event_ns_packet_c(ns_chat, 5, evt, 4, (const uint8_t *)"x", 1, enc, 64);
    if (n != (int32_t)sizeof(expect_evt_ns) || memcmp(enc, expect_evt_ns, (size_t)n) != 0)
        return 11;
    if (sio_decode_event_packet_c((const uint8_t *)"2/chat,[\"pong\",\"ok\"]", 20, evt_out, 16, data_out, 16, &dlen) != 0)
        return 12;
    if (dlen != 2 || data_out[0] != (uint8_t)'o')
        return 13;
    n = sio_encode_ack_packet_c(53, (const uint8_t *)"ok", 2, enc, 64);
    if (n != (int32_t)sizeof(expect_ack) || memcmp(enc, expect_ack, (size_t)n) != 0)
        return 8;
    if (sio_parse_sio_packet_head_c(enc + 1, n - 1, &stype, &sid, &poff) != 0)
        return 9;
    if (stype != SIO_SIO_ACK || sid != 53)
        return 10;
    return 0;
}

/**
 * 从 Socket.IO 包（以 2 开头的 EVENT）解析 event 名与 data 文本。
 * 输入为 EIO message 内 payload（不含 leading '4'）；可选 packet id 已跳过。
 */
int32_t sio_decode_event_packet_c(const uint8_t *sio_pkt, int32_t len, uint8_t *out_event, int32_t out_event_cap,
                                  uint8_t *out_data, int32_t out_data_cap, int32_t *out_data_len) {
    int32_t i;
    int32_t ei;
    int32_t di;
    if (!sio_pkt || len < 5 || !out_event || !out_data || !out_data_len)
        return -1;
    if (sio_pkt[0] != (uint8_t)('0' + SIO_SIO_EVENT))
        return -1;
    i = 1;
    while (i < len && sio_pkt[i] >= (uint8_t)'0' && sio_pkt[i] <= (uint8_t)'9')
        i++;
    /* 跳过 namespace 前缀（例 `/chat,`）。 */
    if (i < len && sio_pkt[i] == (uint8_t)'/') {
        while (i < len && sio_pkt[i] != (uint8_t)',')
            i++;
        if (i >= len)
            return -1;
        i++;
    }
    if (i + 3 >= len || sio_pkt[i] != (uint8_t)'[' || sio_pkt[i + 1] != (uint8_t)'"')
        return -1;
    ei = 0;
    for (i = i + 2; i < len; i++) {
        uint8_t c = sio_pkt[i];
        if (c == (uint8_t)'"' && i + 1 < len && sio_pkt[i + 1] == (uint8_t)',')
            break;
        if (c == (uint8_t)'\\' && i + 1 < len) {
            if (ei + 1 >= out_event_cap)
                return -1;
            out_event[ei++] = sio_pkt[++i];
            continue;
        }
        if (ei + 1 >= out_event_cap)
            return -1;
        out_event[ei++] = c;
    }
    if (i >= len || ei <= 0)
        return -1;
    out_event[ei] = (uint8_t)'\0';
    i += 2;
    if (i >= len || sio_pkt[i] != (uint8_t)'"')
        return -1;
    i++;
    di = 0;
    for (; i < len; i++) {
        uint8_t c = sio_pkt[i];
        if (c == (uint8_t)'"' && i + 1 < len && sio_pkt[i + 1] == (uint8_t)']')
            break;
        if (c == (uint8_t)'\\' && i + 1 < len) {
            if (di >= out_data_cap)
                return -1;
            out_data[di++] = sio_pkt[++i];
            continue;
        }
        if (di >= out_data_cap)
            return -1;
        out_data[di++] = c;
    }
    *out_data_len = di;
    return 0;
}

/**
 * 从 Engine.IO open 包 JSON payload 提取 "sid" 字符串。
 * 例：{"sid":"abc123","upgrades":["websocket"],...}
 */
int32_t sio_eio_extract_sid_c(const uint8_t *open_payload, int32_t len, uint8_t *out_sid, int32_t out_cap) {
    static const char needle[] = "\"sid\":\"";
    int32_t i;
    int32_t sid_len = 0;
    if (!open_payload || len <= 0 || !out_sid || out_cap < 2)
        return -1;
    for (i = 0; i + 7 <= len; i++) {
        if (memcmp(open_payload + i, needle, 7) != 0)
            continue;
        {
            int32_t j = i + 7;
            sid_len = 0;
            while (j < len && open_payload[j] != (uint8_t)'"' && sid_len < out_cap - 1) {
                out_sid[sid_len++] = open_payload[j++];
            }
            out_sid[sid_len] = (uint8_t)'\0';
            return sid_len > 0 ? sid_len : -1;
        }
    }
    return -1;
}

/** 编解码金样烟测；0 通过。 */
int32_t sio_packet_smoke_c(void) {
    uint8_t enc[64];
    uint8_t dec_payload[64];
    uint8_t evt[32];
    uint8_t data[32];
    int32_t n;
    int32_t type = -1;
    int32_t plen = 0;
    int32_t dlen = 0;
    static const uint8_t open_json[] = "{\"sid\":\"abc\",\"upgrades\":[\"websocket\"]}";
    static const uint8_t sid_expect[] = "abc";
    uint8_t sid[16];

    n = sio_eio_encode_packet_c(SIO_EIO_OPEN, open_json, (int32_t)(sizeof(open_json) - 1), enc, 64);
    if (n <= 0)
        return 1;
    if (sio_eio_decode_packet_c(enc, n, &type, dec_payload, 64, &plen) != 0)
        return 2;
    if (type != SIO_EIO_OPEN || plen != (int32_t)(sizeof(open_json) - 1))
        return 3;
    if (sio_eio_extract_sid_c(dec_payload, plen, sid, 16) != 3)
        return 4;
    if (memcmp(sid, sid_expect, 4) != 0)
        return 5;

    n = sio_encode_event_packet_c((const uint8_t *)"hello", 5, (const uint8_t *)"world", 5, enc, 64);
    if (n <= 0)
        return 6;
    if (enc[0] != (uint8_t)('0' + SIO_EIO_MESSAGE))
        return 7;
    if (sio_decode_event_packet_c(enc + 1, n - 1, evt, 32, data, 32, &dlen) != 0)
        return 8;
    if (evt[0] != (uint8_t)'h' || dlen != 5 || data[0] != (uint8_t)'w')
        return 9;

    n = sio_eio_encode_packet_c(SIO_EIO_PING, (const uint8_t *)0, 0, enc, 64);
    if (n != 1 || enc[0] != (uint8_t)('0' + SIO_EIO_PING))
        return 10;
    if (sio_polling_smoke_c() != 0)
        return 11;
    if (sio_connect_smoke_c() != 0)
        return 12;
    if (sio_node_interop_smoke_c() != 0)
        return 13;
    if (sio_server_smoke_c() != 0)
        return 14;
    if (sio_ns_ack_smoke_c() != 0)
        return 15;
    if (sio_ns_router_smoke_c() != 0)
        return 16;
    if (sio_ns_sessions_smoke_c() != 0)
        return 17;
    return 0;
}

/**
 * P3 收口烟测：串联 v9–v15 server/hub/room/cluster 金样。
 * @return 0 通过，非 0 为首个失败层（1 hub … 7 ring）
 */
int32_t sio_p3_complete_smoke_c(void) {
    if (sio_ws_hub_smoke_c() != 0)
        return 1;
    if (sio_room_smoke_c() != 0)
        return 2;
    if (sio_hub_sync_smoke_c() != 0)
        return 3;
    if (sio_session_sync_smoke_c() != 0)
        return 4;
    if (sio_cluster_sync_smoke_c() != 0)
        return 5;
    if (sio_cluster_adapter_smoke_c() != 0)
        return 6;
    if (sio_cluster_ring_sync_smoke_c() != 0)
        return 7;
    return 0;
}
