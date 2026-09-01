/* seeds/runtime_http_glue.from_x.c — G-02f-21 product TU
 * G-02f-119 true .x pure helpers.
 * G-02f-112 helper gates.
 * G-02f-111 helper gates.
 * G-02f-107 helper gates.
 * G-02f-106 helper gates.
 * G-02f-105 helper gates.
 * Logic still C until full .x port.
 *
 * wave252 G.7: XLANG_HTTPS_SMOKE_PORT via public face link_abi_getenv (not raw getenv).
 * wave253: face body in runtime_link_abi_user_env.o (declaration only here).
 * Weak user-domain twin; strong may come from runtime_panic C seed (wave251).
 * PLATFORM: SHARED — user/STD_AND_PANIC residual face; never g05 host bag.
 */
/**
 * runtime_http_glue.c — F-ZC：自 std/http/http_glue.c 迁入 — HTTP 客户端胶层（F-http v1）：最小 HTTP 客户端（P4 可选；对标 Zig std.http、Rust reqwest 最小子集）
 *
 * 【文件职责】GET/POST/HEAD/PUT/DELETE/PATCH/OPTIONS：解析 http(s)://host[:port][/path]，connect + 可选 TLS + send/recv。
 * 【所属模块/组件】std.http；经 ld -r 与 http.x 合并为 http.o；与 mod.x 同属一模块。
 * Cap residual 9.1.7 slice2：Linux dial via xlang_dns_cap + xlang_net_cap（无 getaddrinfo）；
 * Windows 仍 Winsock getaddrinfo／WSAStartup。
 * Cap residual 10.7.2：request／URL format via xlang_snprintf（无 libc snprintf）。
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/* wave253: declaration only — face body in runtime_link_abi_user_env.o (weak; panic C strong wins). */
#include <xlang_user_link_abi_getenv.h>
#include <xlang_fmt_cap.h> /* Cap residual 10.7.2: http format → xlang_snprintf */
/* G.7: single Cap authority for this TU + included seeds/http .inc files (after stdio). */
#undef snprintf
#define snprintf xlang_snprintf


#if defined(_WIN32) || defined(_WIN64)
#include <winsock2.h>
#include <ws2tcpip.h>
#pragma comment(lib, "ws2_32.lib")
#define XLANG_HTTP_CLOSE(fd) closesocket((SOCKET)(fd))
#define XLANG_HTTP_ERRNO WSAGetLastError()
/* MinGW 无 POSIX poll()；WSAPoll 签名兼容（WSAPOLLFD 与 struct pollfd 布局一致） */
#define poll WSAPoll
#else
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <fcntl.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            macOS/Linux delegate to system <unistd.h> via #include_next.
 *            Historical #ifndef _WIN32 guard removed — shim is a no-op
 *            on POSIX and provides needed declarations on Windows. */
#include <unistd.h>
#include <errno.h>
#include <poll.h>
#include <fcntl.h>
#include <xlang_dns_cap.h>
#include <xlang_net_cap.h>
#define XLANG_HTTP_CLOSE(fd) close(fd)
#define XLANG_HTTP_ERRNO errno

/*
 * Cap residual 9.1.7 slice3: redirect libc socket face to Cap for this TU
 * (pool / h2 server smokes / timeout dial). Function-like macros only.
 * PLATFORM: LINUX Cap (include path already gated !_WIN32).
 */
static inline int xlang_http_accept_cap(int fd, void *addr, socklen_t *alen) {
  unsigned int a = alen ? (unsigned int)(*alen) : 0;
  int r = xlang_net_accept(fd, addr, alen ? &a : 0);
  if (alen)
    *alen = (socklen_t)a;
  return r;
}
static inline int xlang_http_setsockopt_cap(int fd, int level, int optname, const void *optval,
                                           socklen_t optlen) {
  return xlang_net_setsockopt(fd, level, optname, optval, (unsigned int)optlen);
}
static inline int xlang_http_fcntl_cap(int fd, int cmd, ...) {
  long arg = 0;
  if (cmd == F_SETFL) {
    __builtin_va_list ap;
    __builtin_va_start(ap, cmd);
    arg = __builtin_va_arg(ap, long);
    __builtin_va_end(ap);
  }
  return xlang_net_fcntl(fd, cmd, arg);
}
#define socket(d, t, p) xlang_net_socket((d), (t), (p))
#define connect(fd, addr, len) xlang_net_connect((fd), (const void *)(addr), (unsigned int)(len))
#define bind(fd, addr, len) xlang_net_bind((fd), (const void *)(addr), (unsigned int)(len))
#define listen(fd, bl) xlang_net_listen((fd), (bl))
#define accept(fd, addr, alen) xlang_http_accept_cap((fd), (addr), (alen))
#define setsockopt(fd, l, o, v, n) xlang_http_setsockopt_cap((fd), (l), (o), (v), (n))
#define poll(fds, n, t) xlang_net_poll((void *)(fds), (unsigned int)(n), (int)(t))
#define fcntl xlang_http_fcntl_cap
#define close(fd) xlang_net_close((fd))
#define send(fd, buf, len, flags)                                                                  \
  xlang_net_sendto((fd), (buf), (size_t)(len), (int)(flags), 0, 0)
#define recv(fd, buf, len, flags)                                                                  \
  xlang_net_recvfrom((fd), (buf), (size_t)(len), (int)(flags), 0, 0)
#endif

#include "http_chunked.inc"
#include "http_tls_bridge.inc"

/** 解析 HTTP/1.x 状态行中的三位状态码；成功 0，失败 -1（STD-032）。 */
int32_t http_parse_status_line_c(const uint8_t *line, int32_t len, int32_t *out_code) {
  int32_t i = 0;
  int32_t code = 0;
  int32_t digits = 0;
  if (!line || !out_code || len < 12)
    return -1;
  if (line[0] != 'H' || line[1] != 'T' || line[2] != 'T' || line[3] != 'P')
    return -1;
  while (i < len && line[i] != ' ')
    i++;
  if (i >= len)
    return -1;
  i++;
  while (i < len && line[i] == ' ')
    i++;
  while (i < len && line[i] >= '0' && line[i] <= '9') {
    code = code * 10 + (line[i] - '0');
    digits++;
    i++;
  }
  if (digits != 3)
    return -1;
  *out_code = code;
  return 0;
}

/* 最大 host/path 长度，请求行+头约 2K 足够 */
#define XLANG_HTTP_HOST_MAX  256
#define XLANG_HTTP_PATH_MAX  2048
#define XLANG_HTTP_REQ_MAX   (XLANG_HTTP_PATH_MAX + XLANG_HTTP_HOST_MAX + 64)

/** C 层 TLS 不可用错误码（map 到 std.net TLS_NOT_IMPL）。 */
#define HTTP_ERR_TLS_NOT_IMPL (-1221)
/** C 层 recv/connect 超时错误码（map 到 std.error http_err_timeout）。 */
#define HTTP_ERR_TIMEOUT (-1220)

/** 解析 http(s)://host[:port][/path]；*out_is_https=1 表示 https；默认端口 80/443。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int parse_http_url_impl(const uint8_t *url, int32_t url_len,
                         char *host_buf, int host_cap,
                         char *port_buf, int port_cap,
                         char *path_buf, int path_cap,
                         int32_t *out_is_https) {
  int32_t i = 0;
  int32_t default_port = 80;
  if (out_is_https) *out_is_https = 0;
  if (url_len < 7 || host_cap < 2 || port_cap < 6 || path_cap < 2) return -1;
  if (url_len >= 8 && url[0] == 'h' && url[1] == 't' && url[2] == 't' && url[3] == 'p' &&
      url[4] == 's' && url[5] == ':' && url[6] == '/' && url[7] == '/') {
    i = 8;
    default_port = 443;
    if (out_is_https) *out_is_https = 1;
  } else if (url_len >= 7 && url[0] == 'h' && url[1] == 't' && url[2] == 't' &&
             url[3] == 'p' && url[4] == ':' && url[5] == '/' && url[6] == '/') {
    i = 7;
  } else {
    return -1;
  }
  {
    int32_t host_start = i;
    while (i < url_len && url[i] != ':' && url[i] != '/') i++;
    int32_t host_len = i - host_start;
    if (host_len <= 0 || host_len >= host_cap) return -1;
    memcpy(host_buf, url + host_start, (size_t)host_len);
    host_buf[host_len] = '\0';
  }
  if (i < url_len && url[i] == ':') {
    i++;
    {
      int32_t port_start = i;
      while (i < url_len && url[i] != '/') i++;
      if (i > port_start && (i - port_start) < port_cap) {
        int plen = i - port_start;
        memcpy(port_buf, url + port_start, (size_t)plen);
        port_buf[plen] = '\0';
      } else {
        return -1;
      }
    }
  } else {
    if (default_port == 443) {
      port_buf[0] = '4'; port_buf[1] = '4'; port_buf[2] = '3'; port_buf[3] = '\0';
    } else {
      port_buf[0] = '8'; port_buf[1] = '0'; port_buf[2] = '\0';
    }
  }
  if (i < url_len && url[i] == '/') {
    int32_t path_start = i;
    while (i < url_len) i++;
    int32_t path_len = i - path_start;
    if (path_len >= path_cap) return -1;
    memcpy(path_buf, url + path_start, (size_t)path_len);
    path_buf[path_len] = '\0';
  } else {
    path_buf[0] = '/'; path_buf[1] = '\0';
  }
  return 0;
}

#ifndef XLANG_RUNTIME_HTTP_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int parse_http_url(const uint8_t *url, int32_t url_len, char *host_buf, int host_cap, char *port_buf, int port_cap, char *path_buf, int path_cap, int32_t *out_is_https) { return parse_http_url_impl(url, url_len, host_buf, host_cap, port_buf, port_cap, path_buf, path_cap, out_is_https); }
#endif /* XLANG_RUNTIME_HTTP_GLUE_FROM_X */




/** 客户端传输层：明文 fd 或 TLS ctx。 */
typedef struct {
  int fd;
  int64_t tls_ctx;
} http_transport_t;

/* thin+rest：thin 函数在 rest 模式下由 .x 提供，前向声明供 rest 函数调用 */
int parse_http_url(const uint8_t *url, int32_t url_len, char *host_buf, int host_cap,
                   char *port_buf, int port_cap, char *path_buf, int path_cap, int32_t *out_is_https);
void http_transport_close(http_transport_t *tr);
int32_t http_transport_start_tls(http_transport_t *tr, int32_t is_https, const char *host);
int32_t http_transport_send_all(http_transport_t *tr, const char *data, int len);
int32_t http_transport_recv_fill(http_transport_t *tr, uint8_t *out_buf, int32_t out_cap, uint32_t timeout_ms);
int http_method_has_body(const char *method);
int http_format_request(const char *method, const char *path_buf, const char *host_buf,
                        int32_t body_len, char *req, int req_cap);
int32_t http_set_timeouts(int fd, uint32_t timeout_ms);
int32_t http_connect_timeout(int fd, const struct addrinfo *res, uint32_t timeout_ms);
int32_t http_drain_request(int fd);
int32_t xlang_http_send_all(int fd, const char *buf, int len, int is_socket);

/** 关闭传输层（含 TLS 与 socket）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void http_transport_close_impl(http_transport_t *tr) {
  if (!tr) return;
  if (tr->tls_ctx != 0) {
    net_tls_close_c(tr->tls_ctx);
    tr->tls_ctx = 0;
  }
  if (tr->fd >= 0) {
    XLANG_HTTP_CLOSE(tr->fd);
    tr->fd = -1;
  }
}

#ifndef XLANG_RUNTIME_HTTP_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin（src/asm/http/runtime_http_glue.x）提供 wrapper 调用 _impl */
void http_transport_close(http_transport_t *tr) { http_transport_close_impl(tr); }
#endif /* XLANG_RUNTIME_HTTP_GLUE_FROM_X */




/** HTTPS 时在已连接 fd 上建立 TLS；明文时 tls_ctx 保持 0。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int32_t http_transport_start_tls_impl(http_transport_t *tr, int32_t is_https, const char *host) {
  if (!is_https) return 0;
  if (net_tls_is_available_c() == 0) return HTTP_ERR_TLS_NOT_IMPL;
  tr->tls_ctx = net_tls_connect_client_c(tr->fd, host);
  if (tr->tls_ctx == 0) return -1;
  return 0;
}

#ifndef XLANG_RUNTIME_HTTP_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int32_t http_transport_start_tls(http_transport_t *tr, int32_t is_https, const char *host) { return http_transport_start_tls_impl(tr, is_https, host); }
#endif /* XLANG_RUNTIME_HTTP_GLUE_FROM_X */




/** 发送全部字节；失败 -1。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int32_t http_transport_send_all_impl(http_transport_t *tr, const char *data, int len) {
  int sent = 0;
  if (!tr || !data || len <= 0) return -1;
  while (sent < len) {
    int n;
    if (tr->tls_ctx != 0)
      n = net_tls_write_c(tr->tls_ctx, (const uint8_t *)(data + sent), len - sent);
#if defined(_WIN32) || defined(_WIN64)
    else
      n = send((SOCKET)tr->fd, data + sent, len - sent, 0);
#else
    else
      n = (int)send(tr->fd, data + sent, (size_t)(len - sent), 0);
#endif
    if (n <= 0) return -1;
    sent += n;
  }
  return 0;
}

#ifndef XLANG_RUNTIME_HTTP_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int32_t http_transport_send_all(http_transport_t *tr, const char *data, int len) { return http_transport_send_all_impl(tr, data, len); }
#endif /* XLANG_RUNTIME_HTTP_GLUE_FROM_X */




/** 读取响应到 out_buf；返回总字节数。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int32_t http_transport_recv_fill_impl(http_transport_t *tr, uint8_t *out_buf, int32_t out_cap,
                                        uint32_t timeout_ms) {
  int32_t total = 0;
  if (!tr || !out_buf || out_cap <= 0) return -1;
  while (total < out_cap) {
    int n;
    if (tr->tls_ctx != 0)
      n = net_tls_read_c(tr->tls_ctx, out_buf + total, out_cap - total);
#if defined(_WIN32) || defined(_WIN64)
    else
      n = recv((SOCKET)tr->fd, (char *)out_buf + total, (int)(out_cap - total), 0);
#else
    else
      n = (int)recv(tr->fd, out_buf + total, (size_t)(out_cap - total), 0);
#endif
    if (n <= 0) {
      if (n < 0 && timeout_ms > 0) return HTTP_ERR_TIMEOUT;
      break;
    }
    total += (int32_t)n;
  }
  return total;
}

#ifndef XLANG_RUNTIME_HTTP_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int32_t http_transport_recv_fill(http_transport_t *tr, uint8_t *out_buf, int32_t out_cap, uint32_t timeout_ms) { return http_transport_recv_fill_impl(tr, out_buf, out_cap, timeout_ms); }
#endif /* XLANG_RUNTIME_HTTP_GLUE_FROM_X */




/** 判定 HTTP 方法是否携带请求体（POST/PUT/PATCH）。 */
#ifndef XLANG_RUNTIME_HTTP_GLUE_FROM_X
/* G-02f-119：逻辑源 .x（真迁）；DIRECT 模式，rest 模式下 seed 不提供 */
int http_method_has_body(const char *method) {
  if (!method)
    return 0;
  return (strcmp(method, "POST") == 0 || strcmp(method, "PUT") == 0 ||
          strcmp(method, "PATCH") == 0);
}
#endif /* XLANG_RUNTIME_HTTP_GLUE_FROM_X */




/** 构建 HTTP/1.0 请求行与 Host 头；带 body 的方法附加 Content-Length。返回 req_len，失败 -1。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int http_format_request_impl(const char *method, const char *path_buf, const char *host_buf,
                               int32_t body_len, char *req, int req_cap) {
  int req_len;
  if (http_method_has_body(method)) {
    req_len = snprintf(req, (size_t)req_cap,
                       "%s %s HTTP/1.0\r\nHost: %s\r\nContent-Length: %d\r\n\r\n",
                       method, path_buf, host_buf, (int)body_len);
  } else {
    req_len = snprintf(req, (size_t)req_cap, "%s %s HTTP/1.0\r\nHost: %s\r\n\r\n",
                       method, path_buf, host_buf);
  }
  if (req_len <= 0 || req_len >= req_cap)
    return -1;
  return req_len;
}

#ifndef XLANG_RUNTIME_HTTP_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int http_format_request(const char *method, const char *path_buf, const char *host_buf, int32_t body_len, char *req, int req_cap) { return http_format_request_impl(method, path_buf, host_buf, body_len, req, req_cap); }
#endif /* XLANG_RUNTIME_HTTP_GLUE_FROM_X */




/** u8 方法码 → C 字符串（0=GET … 6=OPTIONS，与 std.http.Method 一致）；非法返回 NULL。 */
static const char *http_method_from_u8(uint8_t method_u8) {
  static const char *names[] = { "GET", "POST", "HEAD", "PUT", "DELETE", "PATCH", "OPTIONS" };
  if (method_u8 > 6u)
    return NULL;
  return names[method_u8];
}

/** 前向声明：供 http_request_ex_c / http_*_timeout_c 委托。 */
int32_t http_request_timeout_ex_c(const char *method, const uint8_t *url, int32_t url_len,
                                         const uint8_t *body, int32_t body_len, uint8_t *out_buf,
                                         int32_t out_cap, uint32_t timeout_ms);

/** 向已连接 fd 发送 HTTP/1.1 200 OK + body；成功 0，失败 -1。 */
int32_t http_respond_get_ok_c(int fd, const uint8_t *body, int32_t body_len) {
  char hdr[160];
  int hdr_len;
  int sent;
  int total;
  if (fd < 0) return -1;
  if (body_len < 0) body_len = 0;
  if (!body && body_len > 0) return -1;
  hdr_len = snprintf(hdr, sizeof(hdr),
      "HTTP/1.1 200 OK\r\nContent-Length: %d\r\nConnection: close\r\n\r\n", body_len);
  if (hdr_len <= 0 || hdr_len >= (int)sizeof(hdr)) return -1;
  sent = 0;
  while (sent < hdr_len) {
#if defined(_WIN32) || defined(_WIN64)
    int n = send((SOCKET)fd, hdr + sent, hdr_len - sent, 0);
#else
    ssize_t n = send(fd, hdr + sent, (size_t)(hdr_len - sent), 0);
#endif
    if (n <= 0) return -1;
    sent += (int)n;
  }
  total = 0;
  while (total < body_len) {
#if defined(_WIN32) || defined(_WIN64)
    int n = send((SOCKET)fd, (const char *)body + total, body_len - total, 0);
#else
    ssize_t n = send(fd, body + total, (size_t)(body_len - total), 0);
#endif
    if (n <= 0) return -1;
    total += (int)n;
  }
  return 0;
}

/** 通用 HTTP/1.0 客户端（GET/POST/HEAD/PUT/DELETE/PATCH/OPTIONS；支持 http/https）。 */
int32_t http_request_ex_c(const char *method, const uint8_t *url, int32_t url_len,
                          const uint8_t *body, int32_t body_len,
                          uint8_t *out_buf, int32_t out_cap) {
  return http_request_timeout_ex_c(method, url, url_len, body, body_len, out_buf, out_cap, 0u);
}

int32_t http_get_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap) {
  return http_request_ex_c("GET", url, url_len, NULL, 0, out_buf, out_cap);
}

int32_t http_post_c(const uint8_t *url, int32_t url_len, const uint8_t *body, int32_t body_len,
                    uint8_t *out_buf, int32_t out_cap) {
  return http_request_ex_c("POST", url, url_len, body, body_len, out_buf, out_cap);
}

int32_t http_head_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap) {
  return http_request_ex_c("HEAD", url, url_len, NULL, 0, out_buf, out_cap);
}

int32_t http_put_c(const uint8_t *url, int32_t url_len, const uint8_t *body, int32_t body_len,
                   uint8_t *out_buf, int32_t out_cap) {
  return http_request_ex_c("PUT", url, url_len, body, body_len, out_buf, out_cap);
}

int32_t http_delete_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap) {
  return http_request_ex_c("DELETE", url, url_len, NULL, 0, out_buf, out_cap);
}

int32_t http_patch_c(const uint8_t *url, int32_t url_len, const uint8_t *body, int32_t body_len,
                     uint8_t *out_buf, int32_t out_cap) {
  return http_request_ex_c("PATCH", url, url_len, body, body_len, out_buf, out_cap);
}

int32_t http_options_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap) {
  return http_request_ex_c("OPTIONS", url, url_len, NULL, 0, out_buf, out_cap);
}

/** 按 u8 方法码发请求（0=GET … 6=OPTIONS）。 */
int32_t http_request_method_c(uint8_t method_u8, const uint8_t *url, int32_t url_len,
                              const uint8_t *body, int32_t body_len, uint8_t *out_buf,
                              int32_t out_cap) {
  const char *m = http_method_from_u8(method_u8);
  if (!m)
    return -1;
  return http_request_ex_c(m, url, url_len, body, body_len, out_buf, out_cap);
}

#if !defined(_WIN32) && !defined(_WIN64)
#include <fcntl.h>
#include <poll.h>
#ifndef _WIN32
#include <sys/time.h>
#endif
#endif

/** 为 fd 设置收发超时（毫秒）；0 表示不设。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int32_t http_set_timeouts_impl(int fd, uint32_t timeout_ms) {
  if (timeout_ms == 0) return 0;
#if defined(_WIN32) || defined(_WIN64)
  DWORD ms = (DWORD)timeout_ms;
  if (setsockopt((SOCKET)fd, SOL_SOCKET, SO_RCVTIMEO, (const char *)&ms, (int)sizeof(ms)) != 0) return -1;
  if (setsockopt((SOCKET)fd, SOL_SOCKET, SO_SNDTIMEO, (const char *)&ms, (int)sizeof(ms)) != 0) return -1;
#else
  struct timeval tv;
  tv.tv_sec = (time_t)(timeout_ms / 1000u);
  tv.tv_usec = (suseconds_t)((timeout_ms % 1000u) * 1000u);
  if (setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) != 0) return -1;
  if (setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv)) != 0) return -1;
#endif
  return 0;
}

#ifndef XLANG_RUNTIME_HTTP_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int32_t http_set_timeouts(int fd, uint32_t timeout_ms) { return http_set_timeouts_impl(fd, timeout_ms); }
#endif /* XLANG_RUNTIME_HTTP_GLUE_FROM_X */




/** 带超时 connect（非阻塞 connect + poll）；超时返回 HTTP_ERR_TIMEOUT。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int32_t http_connect_timeout_impl(int fd, const struct addrinfo *res, uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
  u_long nb = 1;
  if (ioctlsocket((SOCKET)fd, FIONBIO, &nb) != 0) return -1;
#else
  int flags = fcntl(fd, F_GETFL, 0);
  if (flags < 0) return -1;
  if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) != 0) return -1;
#endif
  {
    int cr =
#if defined(_WIN32) || defined(_WIN64)
        connect((SOCKET)fd, res->ai_addr, (int)res->ai_addrlen);
#else
        connect(fd, res->ai_addr, res->ai_addrlen);
#endif
    if (cr == 0) goto done;
#if defined(_WIN32) || defined(_WIN64)
    if (WSAGetLastError() != WSAEWOULDBLOCK && WSAGetLastError() != WSAEINPROGRESS) return -1;
#else
    if (XLANG_HTTP_ERRNO != EINPROGRESS) return -1;
#endif
  }
  if (timeout_ms > 0) {
#if defined(_WIN32) || defined(_WIN64)
    WSAPOLLFD pfd;
#else
    struct pollfd pfd;
#endif
    pfd.fd = fd;
    pfd.events = POLLOUT;
    {
      int pr = poll(&pfd, 1, (int)timeout_ms);
      if (pr <= 0) return HTTP_ERR_TIMEOUT;
    }
  }
done:
#if defined(_WIN32) || defined(_WIN64)
  {
    u_long nb = 0;
    ioctlsocket((SOCKET)fd, FIONBIO, &nb);
  }
#else
  {
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags >= 0) (void)fcntl(fd, F_SETFL, flags & ~O_NONBLOCK);
  }
#endif
  return 0;
}

#ifndef XLANG_RUNTIME_HTTP_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int32_t http_connect_timeout(int fd, const struct addrinfo *res, uint32_t timeout_ms) { return http_connect_timeout_impl(fd, res, timeout_ms); }
#endif /* XLANG_RUNTIME_HTTP_GLUE_FROM_X */

#if !defined(_WIN32) && !defined(_WIN64)
/**
 * Cap residual 9.1.7 slice2: nonblock connect + poll on raw sockaddr (no addrinfo).
 * PLATFORM: POSIX (Linux Cap dial).
 */
static int32_t http_connect_timeout_sa(int fd, const void *addr, unsigned int addrlen,
                                       uint32_t timeout_ms) {
  int flags = fcntl(fd, F_GETFL, 0);
  if (flags < 0)
    return -1;
  if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) != 0)
    return -1;
  if (xlang_net_connect(fd, addr, addrlen) != 0) {
    if (XLANG_HTTP_ERRNO != EINPROGRESS)
      return -1;
  } else {
    goto done;
  }
  if (timeout_ms > 0) {
    struct pollfd pfd;
    pfd.fd = fd;
    pfd.events = POLLOUT;
    if (xlang_net_poll(&pfd, 1, (int)timeout_ms) <= 0)
      return HTTP_ERR_TIMEOUT;
  }
done:
  flags = fcntl(fd, F_GETFL, 0);
  if (flags >= 0)
    (void)fcntl(fd, F_SETFL, flags & ~O_NONBLOCK);
  return 0;
}

/** Parse decimal port string → 1..65535. */
static int http_parse_port_u16(const char *port_str, uint16_t *out) {
  unsigned v = 0;
  if (!port_str || !out || !*port_str)
    return -1;
  while (*port_str) {
    if (*port_str < '0' || *port_str > '9')
      return -1;
    v = v * 10u + (unsigned)(*port_str - '0');
    if (v > 65535u)
      return -1;
    port_str++;
  }
  if (v == 0)
    return -1;
  *out = (uint16_t)v;
  return 0;
}

/**
 * Cap residual 9.1.7 slice2: dial host:port via Cap DNS + Cap socket/connect.
 * Prefers IPv4 then IPv6. Sets *out_fd. Returns 0 / HTTP_ERR_TIMEOUT / -1.
 * PLATFORM: LINUX Cap (POSIX Cap DNS fallback on Darwin).
 */
static int32_t http_dial_host_port(const char *host, const char *port_str, uint32_t timeout_ms,
                                   int *out_fd) {
  uint16_t port = 0;
  uint32_t a4 = 0;
  int32_t err = 0;
  uint8_t a6[16];
  uint8_t sa[28];
  int fd;
  int32_t cr;
  if (!host || !port_str || !out_fd)
    return -1;
  if (http_parse_port_u16(port_str, &port) != 0)
    return -1;
  if (xlang_dns_resolve_ipv4(host, &a4, &err) == 0) {
    uint32_t be;
    memset(sa, 0, sizeof(sa));
    sa[0] = (uint8_t)AF_INET;
    sa[2] = (uint8_t)(port >> 8);
    sa[3] = (uint8_t)(port & 0xff);
    be = ((a4 & 0xffu) << 24) | ((a4 & 0xff00u) << 8) | ((a4 & 0xff0000u) >> 8) |
         ((a4 & 0xff000000u) >> 24);
    memcpy(sa + 4, &be, 4);
    fd = xlang_net_socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0)
      return -1;
    if (timeout_ms > 0)
      cr = http_connect_timeout_sa(fd, sa, 16, timeout_ms);
    else
      cr = xlang_net_connect(fd, sa, 16) == 0 ? 0 : -1;
    if (cr == 0) {
      *out_fd = fd;
      return 0;
    }
    xlang_net_close(fd);
    if (cr == HTTP_ERR_TIMEOUT)
      return HTTP_ERR_TIMEOUT;
  }
  memset(a6, 0, 16);
  if (xlang_dns_resolve_ipv6(host, a6, &err) == 0) {
    memset(sa, 0, sizeof(sa));
    sa[0] = (uint8_t)AF_INET6;
    sa[2] = (uint8_t)(port >> 8);
    sa[3] = (uint8_t)(port & 0xff);
    memcpy(sa + 8, a6, 16);
    fd = xlang_net_socket(AF_INET6, SOCK_STREAM, 0);
    if (fd < 0)
      return -1;
    if (timeout_ms > 0)
      cr = http_connect_timeout_sa(fd, sa, 28, timeout_ms);
    else
      cr = xlang_net_connect(fd, sa, 28) == 0 ? 0 : -1;
    if (cr == 0) {
      *out_fd = fd;
      return 0;
    }
    xlang_net_close(fd);
    if (cr == HTTP_ERR_TIMEOUT)
      return HTTP_ERR_TIMEOUT;
  }
  return -1;
}
#endif /* !_WIN32 Cap dial */




/** 通用 HTTP 客户端（带 connect/recv 超时毫秒；0=阻塞；支持 http/https）。 */
int32_t http_request_timeout_ex_c_impl(const char *method, const uint8_t *url, int32_t url_len,
                                         const uint8_t *body, int32_t body_len, uint8_t *out_buf,
                                         int32_t out_cap, uint32_t timeout_ms) {
  char host_buf[XLANG_HTTP_HOST_MAX];
  char port_buf[8];
  char path_buf[XLANG_HTTP_PATH_MAX];
  char req[XLANG_HTTP_REQ_MAX];
  int req_len;
  int32_t is_https = 0;
  int32_t tls_rc;
  int32_t total;
  http_transport_t tr;
#if defined(_WIN32) || defined(_WIN64)
  SOCKET fd;
#else
  int fd;
#endif

  if (!method || !url || !out_buf || url_len <= 0 || out_cap <= 0) return -1;
  if (body_len < 0) body_len = 0;
  if (body_len > 0 && !body) return -1;
  if (parse_http_url(url, url_len, host_buf, XLANG_HTTP_HOST_MAX, port_buf, sizeof(port_buf),
                     path_buf, XLANG_HTTP_PATH_MAX, &is_https) != 0)
    return -1;

  tr.fd = -1;
  tr.tls_ctx = 0;

#if defined(_WIN32) || defined(_WIN64)
  {
    WSADATA wsa;
    if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0) return -1;
  }
#endif

  {
#if defined(_WIN32) || defined(_WIN64)
    struct addrinfo hints;
    struct addrinfo *res = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    if (getaddrinfo(host_buf, port_buf, &hints, &res) != 0 || !res) {
      WSACleanup();
      return -1;
    }
    fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (fd == INVALID_SOCKET) {
      freeaddrinfo(res);
      WSACleanup();
      return -1;
    }
    tr.fd = (int)fd;
    if (timeout_ms > 0) {
      int32_t cr = http_connect_timeout(tr.fd, res, timeout_ms);
      if (cr == HTTP_ERR_TIMEOUT) {
        http_transport_close(&tr);
        freeaddrinfo(res);
        WSACleanup();
        return HTTP_ERR_TIMEOUT;
      }
      if (cr != 0) {
        http_transport_close(&tr);
        freeaddrinfo(res);
        WSACleanup();
        return -1;
      }
    } else {
      if (connect(fd, res->ai_addr, (int)res->ai_addrlen) != 0) {
        http_transport_close(&tr);
        freeaddrinfo(res);
        WSACleanup();
        return -1;
      }
    }
    freeaddrinfo(res);
#else
    /* Cap residual 9.1.7 slice2: Cap DNS + Cap dial (no libc getaddrinfo). */
    {
      int32_t dr;
      int cfd = -1;
      dr = http_dial_host_port(host_buf, port_buf, timeout_ms, &cfd);
      if (dr != 0)
        return dr;
      fd = cfd;
      tr.fd = cfd;
    }
#endif
  }

  if (http_set_timeouts(tr.fd, timeout_ms) != 0) {
    http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
    WSACleanup();
#endif
    return -1;
  }

  tls_rc = http_transport_start_tls(&tr, is_https, host_buf);
  if (tls_rc == HTTP_ERR_TLS_NOT_IMPL) {
    http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
    WSACleanup();
#endif
    return HTTP_ERR_TLS_NOT_IMPL;
  }
  if (tls_rc != 0) {
    http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
    WSACleanup();
#endif
    return -1;
  }

  if (http_format_request(method, path_buf, host_buf, body_len, req, (int)sizeof(req)) < 0) {
    http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
    WSACleanup();
#endif
    return -1;
  }
  req_len = (int)strlen(req);

  if (http_transport_send_all(&tr, req, req_len) != 0) {
    http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
    WSACleanup();
#endif
    return (timeout_ms > 0) ? HTTP_ERR_TIMEOUT : -1;
  }

  if (http_method_has_body(method) && body_len > 0) {
    if (http_transport_send_all(&tr, (const char *)body, body_len) != 0) {
      http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
      WSACleanup();
#endif
      return (timeout_ms > 0) ? HTTP_ERR_TIMEOUT : -1;
    }
  }

  total = http_transport_recv_fill(&tr, out_buf, out_cap, timeout_ms);
  http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
  WSACleanup();
#endif
  return total;
}
#ifndef XLANG_RUNTIME_HTTP_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int32_t http_request_timeout_ex_c(const char *method, const uint8_t *url, int32_t url_len,
                                         const uint8_t *body, int32_t body_len, uint8_t *out_buf,
                                         int32_t out_cap, uint32_t timeout_ms) {
  {
    return http_request_timeout_ex_c_impl(method, url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
  }
  return 0;
}
#endif /* XLANG_RUNTIME_HTTP_GLUE_FROM_X */


/** 带超时的 GET（STD-095）。 */
int32_t http_get_timeout_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap,
                           uint32_t timeout_ms) {
  return http_request_timeout_ex_c("GET", url, url_len, NULL, 0, out_buf, out_cap, timeout_ms);
}

int32_t http_post_timeout_c(const uint8_t *url, int32_t url_len, const uint8_t *body, int32_t body_len,
                            uint8_t *out_buf, int32_t out_cap, uint32_t timeout_ms) {
  return http_request_timeout_ex_c("POST", url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
}

int32_t http_head_timeout_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap,
                            uint32_t timeout_ms) {
  return http_request_timeout_ex_c("HEAD", url, url_len, NULL, 0, out_buf, out_cap, timeout_ms);
}

int32_t http_put_timeout_c(const uint8_t *url, int32_t url_len, const uint8_t *body, int32_t body_len,
                           uint8_t *out_buf, int32_t out_cap, uint32_t timeout_ms) {
  return http_request_timeout_ex_c("PUT", url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
}

int32_t http_delete_timeout_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap,
                              uint32_t timeout_ms) {
  return http_request_timeout_ex_c("DELETE", url, url_len, NULL, 0, out_buf, out_cap, timeout_ms);
}

int32_t http_patch_timeout_c(const uint8_t *url, int32_t url_len, const uint8_t *body, int32_t body_len,
                             uint8_t *out_buf, int32_t out_cap, uint32_t timeout_ms) {
  return http_request_timeout_ex_c("PATCH", url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
}

int32_t http_options_timeout_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap,
                               uint32_t timeout_ms) {
  return http_request_timeout_ex_c("OPTIONS", url, url_len, NULL, 0, out_buf, out_cap, timeout_ms);
}

/** 带超时的 u8 方法码请求。 */
int32_t http_request_method_timeout_c(uint8_t method_u8, const uint8_t *url, int32_t url_len,
                                      const uint8_t *body, int32_t body_len, uint8_t *out_buf,
                                      int32_t out_cap, uint32_t timeout_ms) {
  const char *m = http_method_from_u8(method_u8);
  if (!m)
    return -1;
  return http_request_timeout_ex_c(m, url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
}

/** STD-095 C 烟测：短超时连接不可达主机应返回 HTTP_ERR_TIMEOUT。 */
int32_t http_timeout_smoke_c(void) {
  /* 240.0.0.0/4（Class E）通常无路由，connect poll 超时；TEST-NET 在部分环境会快速失败返回 0。 */
  static const uint8_t url[] = "http://240.0.0.1:1/";
  uint8_t buf[128];
  int32_t r = http_get_timeout_c(url, (int32_t)(sizeof(url) - 1), buf, (int32_t)sizeof(buf), 200u);
  return (r == HTTP_ERR_TIMEOUT) ? 0 : 1;
}

/** HTTPS 是否可用（链入 std.net TLS 后端时为 1）。 */
int32_t http_is_https_available_c(void) { return net_tls_is_available_c(); }

/** HTTPS GET 烟测：须 XLANG_HTTPS_SMOKE_PORT + net-o-openssl；桩后端返回 0（SKIP）。 */
int32_t http_https_smoke_c(void) {
  /* wave252 G.7: env via public face link_abi_getenv (not raw libc getenv). */
  const char *port_env = link_abi_getenv("XLANG_HTTPS_SMOKE_PORT");
  char url[128];
  uint8_t buf[512];
  int32_t n;
  if (net_tls_is_available_c() == 0) return 0;
  if (!port_env || !port_env[0]) return 1;
  if (snprintf(url, sizeof(url), "https://127.0.0.1:%s/", port_env) <= 0) return 1;
  n = http_get_c((const uint8_t *)url, (int32_t)strlen(url), buf, (int32_t)sizeof(buf));
  if (n <= 0) return 1;
  if (buf[0] != 'H' || buf[1] != 'T' || buf[2] != 'T' || buf[3] != 'P') return 1;
  return 0;
}

#if !defined(_WIN32) && !defined(_WIN64)
#include <signal.h>
#ifndef _WIN32
#include <sys/wait.h>
#endif
#endif

/** 读并丢弃客户端请求头（至 \\r\\n\\r\\n）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int32_t http_drain_request_impl(int fd) {
  uint8_t buf[4096];
  int32_t total = 0;
  int32_t off;
  while (total < (int32_t)sizeof(buf)) {
#if defined(_WIN32) || defined(_WIN64)
    int n = recv((SOCKET)fd, (char *)buf + total, (int)(sizeof(buf) - (size_t)total), 0);
#else
    ssize_t n = recv(fd, buf + total, sizeof(buf) - (size_t)total, 0);
#endif
    if (n <= 0) return (total > 0) ? 0 : -1;
    total += (int32_t)n;
    for (off = 3; off < total; off++) {
      if (buf[off - 3] == '\r' && buf[off - 2] == '\n' && buf[off - 1] == '\r' && buf[off] == '\n')
        return 0;
    }
  }
  return 0;
}

#ifndef XLANG_RUNTIME_HTTP_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int32_t http_drain_request(int fd) { return http_drain_request_impl(fd); }
#endif /* XLANG_RUNTIME_HTTP_GLUE_FROM_X */




/** 循环 send 直至 len 字节发完。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int32_t xlang_http_send_all_impl(int fd, const char *buf, int len, int is_socket) {
  int sent = 0;
  (void)is_socket;
  if (fd < 0 || !buf || len <= 0) return -1;
  while (sent < len) {
#if defined(_WIN32) || defined(_WIN64)
    int n = send((SOCKET)fd, buf + sent, len - sent, 0);
#else
    ssize_t n = send(fd, buf + sent, (size_t)(len - sent), 0);
#endif
    if (n <= 0) return -1;
    sent += (int)n;
  }
  return 0;
}

#ifndef XLANG_RUNTIME_HTTP_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int32_t xlang_http_send_all(int fd, const char *buf, int len, int is_socket) { return xlang_http_send_all_impl(fd, buf, len, is_socket); }
#endif /* XLANG_RUNTIME_HTTP_GLUE_FROM_X */




#include "http_server_pool.inc"
#include "http_reqresp.inc"
#include "http2.inc"
#include "http2_hpack.inc"
#include "http2_client.inc"
#include "http2_network.inc"

/** HTTP/2 over TLS 多 method 请求（https:// + ALPN h2）。 */
int32_t http_h2_request_c(uint8_t method_u8, const uint8_t *url, int32_t url_len,
                          const uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap,
                          uint32_t timeout_ms) {
  char host_buf[XLANG_HTTP_HOST_MAX];
  char port_buf[8];
  char path_buf[XLANG_HTTP_PATH_MAX];
  uint8_t alpn_wire[16];
  int32_t is_https = 0;
  int32_t alpn_len;
  int64_t tls_ctx = 0;
  int32_t rc;
  int32_t has_body;
  http_transport_t tr;
#if defined(_WIN32) || defined(_WIN64)
  SOCKET fd;
#else
  int fd;
#endif

  if (!url || !out_buf || url_len <= 0 || out_cap <= 0)
    return -1;
  if (http_method_from_u8(method_u8) == NULL)
    return -1;
  has_body = (method_u8 == 1 || method_u8 == 3 || method_u8 == 5) ? 1 : 0;
  if (has_body != 0) {
    if (body_len <= 0 || !body)
      return -1;
  } else if (body_len > 0) {
    return -1;
  }
  if (http2_network_is_available_c() == 0)
    return HTTP2_ERR_NETWORK;
  if (parse_http_url(url, url_len, host_buf, XLANG_HTTP_HOST_MAX, port_buf, sizeof(port_buf),
                     path_buf, XLANG_HTTP_PATH_MAX, &is_https) != 0)
    return -1;
  if (is_https == 0)
    return HTTP2_ERR_NETWORK;

  tr.fd = -1;
  tr.tls_ctx = 0;

#if defined(_WIN32) || defined(_WIN64)
  {
    WSADATA wsa;
    if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0)
      return -1;
  }
#endif

  {
#if defined(_WIN32) || defined(_WIN64)
    struct addrinfo hints;
    struct addrinfo *res = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    if (getaddrinfo(host_buf, port_buf, &hints, &res) != 0 || !res) {
      WSACleanup();
      return -1;
    }
    fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (fd == INVALID_SOCKET) {
      freeaddrinfo(res);
      WSACleanup();
      return -1;
    }
    tr.fd = (int)fd;
    if (timeout_ms > 0) {
      int32_t cr = http_connect_timeout(tr.fd, res, timeout_ms);
      if (cr == HTTP_ERR_TIMEOUT) {
        http_transport_close(&tr);
        freeaddrinfo(res);
        WSACleanup();
        return HTTP_ERR_TIMEOUT;
      }
      if (cr != 0) {
        http_transport_close(&tr);
        freeaddrinfo(res);
        WSACleanup();
        return -1;
      }
    } else {
      if (connect(fd, res->ai_addr, (int)res->ai_addrlen) != 0) {
        http_transport_close(&tr);
        freeaddrinfo(res);
        WSACleanup();
        return -1;
      }
    }
    freeaddrinfo(res);
#else
    /* Cap residual 9.1.7 slice2: Cap DNS + Cap dial (no libc getaddrinfo). */
    {
      int32_t dr;
      int cfd = -1;
      dr = http_dial_host_port(host_buf, port_buf, timeout_ms, &cfd);
      if (dr != 0)
        return dr;
      fd = cfd;
      tr.fd = cfd;
    }
#endif
  }

  if (http_set_timeouts(tr.fd, timeout_ms) != 0) {
    http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
    WSACleanup();
#endif
    return -1;
  }

  alpn_len = net_tls_alpn_h2_http1_wire_c(alpn_wire, (int32_t)sizeof(alpn_wire));
  if (alpn_len <= 0) {
    http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
    WSACleanup();
#endif
    return HTTP2_ERR_NETWORK;
  }

  tls_ctx = net_tls_connect_client_alpn_c(tr.fd, host_buf, alpn_wire, alpn_len);
  if (tls_ctx == 0) {
    http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
    WSACleanup();
#endif
    return -1;
  }
  tr.tls_ctx = tls_ctx;

  if (net_tls_alpn_is_h2_c(tls_ctx) == 0) {
    http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
    WSACleanup();
#endif
    return HTTP2_ERR_NETWORK;
  }

  rc = http2_session_request_tls_c(tls_ctx, method_u8, (const uint8_t *)host_buf,
                                   (int32_t)strlen(host_buf), (const uint8_t *)path_buf,
                                   (int32_t)strlen(path_buf), body, body_len, out_buf, out_cap);
  http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
  WSACleanup();
#endif
  return rc;
}

/** HTTP/2 over TLS GET（https://；须 TLS + ALPN h2）。失败 HTTP2_ERR_NETWORK(-1231)。 */
int32_t http_h2_get_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap,
                      uint32_t timeout_ms) {
  return http_h2_request_c(0, url, url_len, NULL, 0, out_buf, out_cap, timeout_ms);
}

/** HTTP/2 统一入口（GET/POST/HEAD/PUT/DELETE/PATCH/OPTIONS + 动态 HPACK）。 */
int32_t http_request_method_h2_c(uint8_t method_u8, const uint8_t *url, int32_t url_len,
                                 const uint8_t *body, int32_t body_len, uint8_t *out_buf,
                                 int32_t out_cap, uint32_t timeout_ms) {
  return http_h2_request_c(method_u8, url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
}

/**
 * HTTP/2 cleartext h2c 多 method 请求（http:// + 直连 preface；无 TLS）。
 * https:// URL 返回 HTTP2_ERR_H2C_SCHEME(-1235)。
 */
int32_t http_h2c_request_c(uint8_t method_u8, const uint8_t *url, int32_t url_len,
                           const uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap,
                           uint32_t timeout_ms) {
  char host_buf[XLANG_HTTP_HOST_MAX];
  char port_buf[8];
  char path_buf[XLANG_HTTP_PATH_MAX];
  int32_t is_https = 0;
  int32_t rc;
  int32_t has_body;
  http_transport_t tr;
#if defined(_WIN32) || defined(_WIN64)
  SOCKET fd;
#else
  int fd;
#endif

  if (!url || !out_buf || url_len <= 0 || out_cap <= 0)
    return -1;
  if (http_method_from_u8(method_u8) == NULL)
    return -1;
  has_body = (method_u8 == 1 || method_u8 == 3 || method_u8 == 5) ? 1 : 0;
  if (has_body != 0) {
    if (body_len <= 0 || !body)
      return -1;
  } else if (body_len > 0) {
    return -1;
  }
  if (http2_h2c_is_available_c() == 0)
    return HTTP2_ERR_H2C_NOT_IMPL;
  if (parse_http_url(url, url_len, host_buf, XLANG_HTTP_HOST_MAX, port_buf, sizeof(port_buf),
                     path_buf, XLANG_HTTP_PATH_MAX, &is_https) != 0)
    return -1;
  if (is_https != 0)
    return HTTP2_ERR_H2C_SCHEME;

  tr.fd = -1;
  tr.tls_ctx = 0;

#if defined(_WIN32) || defined(_WIN64)
  {
    WSADATA wsa;
    if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0)
      return -1;
  }
#endif

  {
#if defined(_WIN32) || defined(_WIN64)
    struct addrinfo hints;
    struct addrinfo *res = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    if (getaddrinfo(host_buf, port_buf, &hints, &res) != 0 || !res) {
      WSACleanup();
      return -1;
    }
    fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (fd == INVALID_SOCKET) {
      freeaddrinfo(res);
      WSACleanup();
      return -1;
    }
    tr.fd = (int)fd;
    if (timeout_ms > 0) {
      int32_t cr = http_connect_timeout(tr.fd, res, timeout_ms);
      if (cr == HTTP_ERR_TIMEOUT) {
        http_transport_close(&tr);
        freeaddrinfo(res);
        WSACleanup();
        return HTTP_ERR_TIMEOUT;
      }
      if (cr != 0) {
        http_transport_close(&tr);
        freeaddrinfo(res);
        WSACleanup();
        return -1;
      }
    } else {
      if (connect(fd, res->ai_addr, (int)res->ai_addrlen) != 0) {
        http_transport_close(&tr);
        freeaddrinfo(res);
        WSACleanup();
        return -1;
      }
    }
    freeaddrinfo(res);
#else
    /* Cap residual 9.1.7 slice2: Cap DNS + Cap dial (no libc getaddrinfo). */
    {
      int32_t dr;
      int cfd = -1;
      dr = http_dial_host_port(host_buf, port_buf, timeout_ms, &cfd);
      if (dr != 0)
        return dr;
      fd = cfd;
      tr.fd = cfd;
    }
#endif
  }

  if (http_set_timeouts(tr.fd, timeout_ms) != 0) {
    http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
    WSACleanup();
#endif
    return -1;
  }

  rc = http2_session_request_h2c_c(tr.fd, method_u8, (const uint8_t *)host_buf,
                                 (int32_t)strlen(host_buf), (const uint8_t *)path_buf,
                                 (int32_t)strlen(path_buf), body, body_len, out_buf, out_cap);
  http_transport_close(&tr);
#if defined(_WIN32) || defined(_WIN64)
  WSACleanup();
#endif
  return rc;
}

/** h2c GET（http://）；https:// 返回 HTTP2_ERR_H2C_SCHEME(-1235)。 */
int32_t http_h2c_get_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap,
                       uint32_t timeout_ms) {
  return http_h2c_request_c(0, url, url_len, NULL, 0, out_buf, out_cap, timeout_ms);
}

/** h2c 统一入口（Method u8）。 */
int32_t http_request_method_h2c_c(uint8_t method_u8, const uint8_t *url, int32_t url_len,
                                  const uint8_t *body, int32_t body_len, uint8_t *out_buf,
                                  int32_t out_cap, uint32_t timeout_ms) {
  return http_h2c_request_c(method_u8, url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
}

/** h2c 客户端 C 烟测（https URL 须返回 SCHEME 错误）；0 通过。 */
int32_t http_h2c_client_smoke_c(void) {
  static const uint8_t https_url[] = "https://example.com/";
  if (http_h2c_get_c(https_url, (int32_t)(sizeof(https_url) - 1), (uint8_t *)https_url, 32, 0) !=
      HTTP2_ERR_H2C_SCHEME)
    return 1;
  if (http2_h2c_is_available_c() != 1)
    return 2;
  return 0;
}

#include "http2_conn_pool.inc"
#include "http2_global_pool.inc"
