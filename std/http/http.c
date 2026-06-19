/**
 * std/http/http.c — 最小 HTTP 客户端（P4 可选；对标 Zig std.http、Rust reqwest 最小子集）
 *
 * 【文件职责】GET/POST/HEAD/PUT/DELETE/PATCH/OPTIONS：解析 http(s)://host[:port][/path]，connect + 可选 TLS + send/recv。
 * 【所属模块/组件】标准库 std.http；与 std/http/mod.sx 同属一模块。依赖 socket/getaddrinfo（Unix -lc；Windows ws2_32）。
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <winsock2.h>
#include <ws2tcpip.h>
#pragma comment(lib, "ws2_32.lib")
#define SHUX_HTTP_CLOSE(fd) closesocket((SOCKET)(fd))
#define SHUX_HTTP_ERRNO WSAGetLastError()
#else
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <errno.h>
#define SHUX_HTTP_CLOSE(fd) close(fd)
#define SHUX_HTTP_ERRNO errno
#endif

#include "http_chunked.inc.c"
#include "http_tls_bridge.inc.c"

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
#define SHUX_HTTP_HOST_MAX  256
#define SHUX_HTTP_PATH_MAX  2048
#define SHUX_HTTP_REQ_MAX   (SHUX_HTTP_PATH_MAX + SHUX_HTTP_HOST_MAX + 64)

/** C 层 TLS 不可用错误码（map 到 std.net TLS_NOT_IMPL）。 */
#define HTTP_ERR_TLS_NOT_IMPL (-1221)
/** C 层 recv/connect 超时错误码（map 到 std.error http_err_timeout）。 */
#define HTTP_ERR_TIMEOUT (-1220)

/** 解析 http(s)://host[:port][/path]；*out_is_https=1 表示 https；默认端口 80/443。 */
static int parse_http_url(const uint8_t *url, int32_t url_len,
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

/** 客户端传输层：明文 fd 或 TLS ctx。 */
typedef struct {
  int fd;
  int64_t tls_ctx;
} http_transport_t;

/** 关闭传输层（含 TLS 与 socket）。 */
static void http_transport_close(http_transport_t *tr) {
  if (!tr) return;
  if (tr->tls_ctx != 0) {
    net_tls_close_c(tr->tls_ctx);
    tr->tls_ctx = 0;
  }
  if (tr->fd >= 0) {
    SHUX_HTTP_CLOSE(tr->fd);
    tr->fd = -1;
  }
}

/** HTTPS 时在已连接 fd 上建立 TLS；明文时 tls_ctx 保持 0。 */
static int32_t http_transport_start_tls(http_transport_t *tr, int32_t is_https, const char *host) {
  if (!is_https) return 0;
  if (net_tls_is_available_c() == 0) return HTTP_ERR_TLS_NOT_IMPL;
  tr->tls_ctx = net_tls_connect_client_c(tr->fd, host);
  if (tr->tls_ctx == 0) return -1;
  return 0;
}

/** 发送全部字节；失败 -1。 */
static int32_t http_transport_send_all(http_transport_t *tr, const char *data, int len) {
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

/** 读取响应到 out_buf；返回总字节数。 */
static int32_t http_transport_recv_fill(http_transport_t *tr, uint8_t *out_buf, int32_t out_cap,
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

/** 判定 HTTP 方法是否携带请求体（POST/PUT/PATCH）。 */
static int http_method_has_body(const char *method) {
  if (!method)
    return 0;
  return (strcmp(method, "POST") == 0 || strcmp(method, "PUT") == 0 ||
          strcmp(method, "PATCH") == 0);
}

/** 构建 HTTP/1.0 请求行与 Host 头；带 body 的方法附加 Content-Length。返回 req_len，失败 -1。 */
static int http_format_request(const char *method, const char *path_buf, const char *host_buf,
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

/** u8 方法码 → C 字符串（0=GET … 6=OPTIONS，与 std.http.Method 一致）；非法返回 NULL。 */
static const char *http_method_from_u8(uint8_t method_u8) {
  static const char *names[] = { "GET", "POST", "HEAD", "PUT", "DELETE", "PATCH", "OPTIONS" };
  if (method_u8 > 6u)
    return NULL;
  return names[method_u8];
}

/** 前向声明：供 http_request_ex_c / http_*_timeout_c 委托。 */
static int32_t http_request_timeout_ex_c(const char *method, const uint8_t *url, int32_t url_len,
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
#endif

/** 为 fd 设置收发超时（毫秒）；0 表示不设。 */
static int32_t http_set_timeouts(int fd, uint32_t timeout_ms) {
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

/** 带超时 connect（非阻塞 connect + poll）；超时返回 HTTP_ERR_TIMEOUT。 */
static int32_t http_connect_timeout(int fd, const struct addrinfo *res, uint32_t timeout_ms) {
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
    if (SHUX_HTTP_ERRNO != EINPROGRESS) return -1;
#endif
  }
  if (timeout_ms > 0) {
    struct pollfd pfd;
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

/** 通用 HTTP 客户端（带 connect/recv 超时毫秒；0=阻塞；支持 http/https）。 */
static int32_t http_request_timeout_ex_c(const char *method, const uint8_t *url, int32_t url_len,
                                         const uint8_t *body, int32_t body_len, uint8_t *out_buf,
                                         int32_t out_cap, uint32_t timeout_ms) {
  char host_buf[SHUX_HTTP_HOST_MAX];
  char port_buf[8];
  char path_buf[SHUX_HTTP_PATH_MAX];
  char req[SHUX_HTTP_REQ_MAX];
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
  if (parse_http_url(url, url_len, host_buf, SHUX_HTTP_HOST_MAX, port_buf, sizeof(port_buf),
                     path_buf, SHUX_HTTP_PATH_MAX, &is_https) != 0)
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
    struct addrinfo hints;
    struct addrinfo *res = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    if (getaddrinfo(host_buf, port_buf, &hints, &res) != 0 || !res) {
#if defined(_WIN32) || defined(_WIN64)
      WSACleanup();
#endif
      return -1;
    }
#if defined(_WIN32) || defined(_WIN64)
    fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (fd == INVALID_SOCKET) {
#else
    fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (fd < 0) {
#endif
      freeaddrinfo(res);
#if defined(_WIN32) || defined(_WIN64)
      WSACleanup();
#endif
      return -1;
    }
    tr.fd = (int)fd;
    if (timeout_ms > 0) {
      int32_t cr = http_connect_timeout(tr.fd, res, timeout_ms);
      if (cr == HTTP_ERR_TIMEOUT) {
        http_transport_close(&tr);
        freeaddrinfo(res);
#if defined(_WIN32) || defined(_WIN64)
        WSACleanup();
#endif
        return HTTP_ERR_TIMEOUT;
      }
      if (cr != 0) {
        http_transport_close(&tr);
        freeaddrinfo(res);
#if defined(_WIN32) || defined(_WIN64)
        WSACleanup();
#endif
        return -1;
      }
    } else {
#if defined(_WIN32) || defined(_WIN64)
      if (connect(fd, res->ai_addr, (int)res->ai_addrlen) != 0) {
#else
      if (connect(fd, res->ai_addr, res->ai_addrlen) != 0) {
#endif
        http_transport_close(&tr);
        freeaddrinfo(res);
#if defined(_WIN32) || defined(_WIN64)
        WSACleanup();
#endif
        return -1;
      }
    }
    freeaddrinfo(res);
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
  uint8_t buf[64];
  int32_t r = http_get_timeout_c(url, (int32_t)(sizeof(url) - 1), buf, (int32_t)sizeof(buf), 200u);
  return (r == HTTP_ERR_TIMEOUT) ? 0 : 1;
}

/** HTTPS 是否可用（链入 std.net TLS 后端时为 1）。 */
int32_t http_is_https_available_c(void) { return net_tls_is_available_c(); }

/** HTTPS GET 烟测：须 SHUX_HTTPS_SMOKE_PORT + net-o-openssl；桩后端返回 0（SKIP）。 */
int32_t http_https_smoke_c(void) {
  const char *port_env = getenv("SHUX_HTTPS_SMOKE_PORT");
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
#include <sys/wait.h>
#endif

/** 读并丢弃客户端请求头（至 \\r\\n\\r\\n）。 */
static int32_t http_drain_request(int fd) {
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

/** 循环 send 直至 len 字节发完。 */
static int32_t shu_http_send_all(int fd, const char *buf, int len, int is_socket) {
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

#include "http_server_pool.inc.c"
#include "http_reqresp.inc.c"
#include "http2.inc.c"
#include "http2_hpack.inc.c"
#include "http2_client.inc.c"
#include "http2_network.inc.c"

/** HTTP/2 over TLS 多 method 请求（https:// + ALPN h2）。 */
int32_t http_h2_request_c(uint8_t method_u8, const uint8_t *url, int32_t url_len,
                          const uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap,
                          uint32_t timeout_ms) {
  char host_buf[SHUX_HTTP_HOST_MAX];
  char port_buf[8];
  char path_buf[SHUX_HTTP_PATH_MAX];
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
  if (parse_http_url(url, url_len, host_buf, SHUX_HTTP_HOST_MAX, port_buf, sizeof(port_buf),
                     path_buf, SHUX_HTTP_PATH_MAX, &is_https) != 0)
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
    struct addrinfo hints;
    struct addrinfo *res = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    if (getaddrinfo(host_buf, port_buf, &hints, &res) != 0 || !res) {
#if defined(_WIN32) || defined(_WIN64)
      WSACleanup();
#endif
      return -1;
    }
#if defined(_WIN32) || defined(_WIN64)
    fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (fd == INVALID_SOCKET) {
#else
    fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (fd < 0) {
#endif
      freeaddrinfo(res);
#if defined(_WIN32) || defined(_WIN64)
      WSACleanup();
#endif
      return -1;
    }
    tr.fd = (int)fd;
    if (timeout_ms > 0) {
      int32_t cr = http_connect_timeout(tr.fd, res, timeout_ms);
      if (cr == HTTP_ERR_TIMEOUT) {
        http_transport_close(&tr);
        freeaddrinfo(res);
#if defined(_WIN32) || defined(_WIN64)
        WSACleanup();
#endif
        return HTTP_ERR_TIMEOUT;
      }
      if (cr != 0) {
        http_transport_close(&tr);
        freeaddrinfo(res);
#if defined(_WIN32) || defined(_WIN64)
        WSACleanup();
#endif
        return -1;
      }
    } else {
#if defined(_WIN32) || defined(_WIN64)
      if (connect(fd, res->ai_addr, (int)res->ai_addrlen) != 0) {
#else
      if (connect(fd, res->ai_addr, res->ai_addrlen) != 0) {
#endif
        http_transport_close(&tr);
        freeaddrinfo(res);
#if defined(_WIN32) || defined(_WIN64)
        WSACleanup();
#endif
        return -1;
      }
    }
    freeaddrinfo(res);
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
  char host_buf[SHUX_HTTP_HOST_MAX];
  char port_buf[8];
  char path_buf[SHUX_HTTP_PATH_MAX];
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
  if (parse_http_url(url, url_len, host_buf, SHUX_HTTP_HOST_MAX, port_buf, sizeof(port_buf),
                     path_buf, SHUX_HTTP_PATH_MAX, &is_https) != 0)
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
    struct addrinfo hints;
    struct addrinfo *res = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    if (getaddrinfo(host_buf, port_buf, &hints, &res) != 0 || !res) {
#if defined(_WIN32) || defined(_WIN64)
      WSACleanup();
#endif
      return -1;
    }
#if defined(_WIN32) || defined(_WIN64)
    fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (fd == INVALID_SOCKET) {
#else
    fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (fd < 0) {
#endif
      freeaddrinfo(res);
#if defined(_WIN32) || defined(_WIN64)
      WSACleanup();
#endif
      return -1;
    }
    tr.fd = (int)fd;
    if (timeout_ms > 0) {
      int32_t cr = http_connect_timeout(tr.fd, res, timeout_ms);
      if (cr == HTTP_ERR_TIMEOUT) {
        http_transport_close(&tr);
        freeaddrinfo(res);
#if defined(_WIN32) || defined(_WIN64)
        WSACleanup();
#endif
        return HTTP_ERR_TIMEOUT;
      }
      if (cr != 0) {
        http_transport_close(&tr);
        freeaddrinfo(res);
#if defined(_WIN32) || defined(_WIN64)
        WSACleanup();
#endif
        return -1;
      }
    } else {
#if defined(_WIN32) || defined(_WIN64)
      if (connect(fd, res->ai_addr, (int)res->ai_addrlen) != 0) {
#else
      if (connect(fd, res->ai_addr, res->ai_addrlen) != 0) {
#endif
        http_transport_close(&tr);
        freeaddrinfo(res);
#if defined(_WIN32) || defined(_WIN64)
        WSACleanup();
#endif
        return -1;
      }
    }
    freeaddrinfo(res);
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

#include "http2_conn_pool.inc.c"
#include "http2_global_pool.inc.c"

