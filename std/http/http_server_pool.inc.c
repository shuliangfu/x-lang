/**
 * std/http/http_server_pool.inc.c — STD-107 server 循环 + client 连接池
 *
 * 【文件职责】
 * http_listen_c / http_serve_one_c 最小 accept+respond 循环；
 * http_client_pool_* 同 host:port 的 keep-alive 连接复用；
 * http_server_pool_smoke_c 烟测（fork 本地 server）。
 *
 * 由 std/http/http.c 在 http_chunked.inc.c 之前 #include。
 */

#include <stdlib.h>

#if !defined(_WIN32) && !defined(_WIN64)
#include <poll.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#endif

/** STD-107：client 连接池最大 idle 连接数。 */
#define HTTP_POOL_MAX_CONNS 8

/** STD-107：client 连接池（同 host:port idle fd 栈）。 */
typedef struct http_client_pool {
  char host[SHU_HTTP_HOST_MAX];
  char port[8];
  int32_t max_conns;
  int32_t n_idle;
  int32_t connect_count;
  int32_t fds[HTTP_POOL_MAX_CONNS];
} http_client_pool_t;

/** 将 u32 主机序 IPv4 写入 sockaddr_in（与 std.net addr_to_u32 布局一致）。 */
static void http_sin_from_addr_u32(struct sockaddr_in *sin, uint32_t addr_u32, uint16_t port) {
  uint8_t a = (uint8_t)((addr_u32 >> 24) & 255u);
  uint8_t b = (uint8_t)((addr_u32 >> 16) & 255u);
  uint8_t c = (uint8_t)((addr_u32 >> 8) & 255u);
  uint8_t d = (uint8_t)(addr_u32 & 255u);
  memset(sin, 0, sizeof(*sin));
  sin->sin_family = AF_INET;
  sin->sin_port = htons(port);
#if defined(_WIN32) || defined(_WIN64)
  sin->sin_addr.S_un.S_un_b.s_b1 = a;
  sin->sin_addr.S_un.S_un_b.s_b2 = b;
  sin->sin_addr.S_un.S_un_b.s_b3 = c;
  sin->sin_addr.S_un.S_un_b.s_b4 = d;
#else
  sin->sin_addr.s_addr = htonl(((uint32_t)a << 24) | ((uint32_t)b << 16) | ((uint32_t)c << 8) | (uint32_t)d);
#endif
}

/**
 * STD-107：在 IPv4 addr:port 上 TCP listen。
 * @param addr_u32 主机序 IPv4（127.0.0.1 = 0x7f000001）
 * @return listener fd，失败 -1
 */
int32_t http_listen_c(uint32_t addr_u32, uint32_t port_u32, int32_t backlog) {
  struct sockaddr_in sin;
  int opt = 1;
#if defined(_WIN32) || defined(_WIN64)
  SOCKET fd;
#else
  int fd;
#endif
  if (backlog <= 0) backlog = 8;
  http_sin_from_addr_u32(&sin, addr_u32, (uint16_t)port_u32);
#if defined(_WIN32) || defined(_WIN64)
  fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (fd == INVALID_SOCKET) return -1;
  (void)setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (const char *)&opt, (int)sizeof(opt));
  if (bind(fd, (struct sockaddr *)&sin, (int)sizeof(sin)) != 0) {
    SHU_HTTP_CLOSE((int)fd);
    return -1;
  }
  if (listen(fd, backlog) != 0) {
    SHU_HTTP_CLOSE((int)fd);
    return -1;
  }
  return (int32_t)fd;
#else
  fd = (int)socket(AF_INET, SOCK_STREAM, 0);
  if (fd < 0) return -1;
  (void)setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &opt, (socklen_t)sizeof(opt));
  if (bind(fd, (struct sockaddr *)&sin, (socklen_t)sizeof(sin)) != 0) {
    SHU_HTTP_CLOSE(fd);
    return -1;
  }
  if (listen(fd, backlog) != 0) {
    SHU_HTTP_CLOSE(fd);
    return -1;
  }
  return (int32_t)fd;
#endif
}

/**
 * STD-107：accept 一个连接并 respond_get_ok，然后关闭 client。
 * @param timeout_ms accept 等待毫秒（0=阻塞）
 */
int32_t http_serve_one_c(int32_t listener_fd, const uint8_t *body, int32_t body_len, uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
  (void)timeout_ms;
  {
    SOCKET client = accept((SOCKET)listener_fd, NULL, NULL);
    int32_t r;
    if (client == INVALID_SOCKET) return -1;
    r = http_respond_get_ok_c((int)client, body, body_len);
    SHU_HTTP_CLOSE((int)client);
    return r;
  }
#else
  struct pollfd pfd;
  int client;
  int32_t r;
  if (listener_fd < 0) return -1;
  if (timeout_ms > 0) {
    pfd.fd = listener_fd;
    pfd.events = POLLIN;
    pfd.revents = 0;
    if (poll(&pfd, 1, (int)timeout_ms) <= 0) return -1;
  }
  client = (int)accept(listener_fd, NULL, NULL);
  if (client < 0) return -1;
  r = http_respond_get_ok_c(client, body, body_len);
  SHU_HTTP_CLOSE(client);
  return r;
#endif
}

/**
 * 对已连接 fd 回 HTTP/1.1 200 OK + Connection: keep-alive（不关闭 fd）。
 */
static int32_t http_respond_get_ok_keepalive_c(int fd, const uint8_t *body, int32_t body_len) {
  char hdr[160];
  int hlen;
  int sent;
  if (fd < 0 || !body || body_len < 0) return -1;
  if (http_drain_request(fd) != 0) return -1;
  hlen = snprintf(hdr, sizeof(hdr),
                  "HTTP/1.1 200 OK\r\nContent-Length: %d\r\nConnection: keep-alive\r\n\r\n",
                  body_len);
  if (hlen <= 0 || hlen >= (int)sizeof(hdr)) return -1;
  sent = 0;
  while (sent < hlen) {
#if defined(_WIN32) || defined(_WIN64)
    int n = send((SOCKET)fd, hdr + sent, hlen - sent, 0);
#else
    ssize_t n = send(fd, hdr + sent, (size_t)(hlen - sent), 0);
#endif
    if (n <= 0) return -1;
    sent += (int)n;
  }
  sent = 0;
  while (sent < body_len) {
#if defined(_WIN32) || defined(_WIN64)
    int n = send((SOCKET)fd, (const char *)body + sent, body_len - sent, 0);
#else
    ssize_t n = send(fd, body + sent, (size_t)(body_len - sent), 0);
#endif
    if (n <= 0) return -1;
    sent += (int)n;
  }
  return 0;
}

/** 校验 url 的 host/port 与 pool 绑定一致。 */
static int http_pool_url_matches(const http_client_pool_t *p, const uint8_t *url, int32_t url_len) {
  char host_buf[SHU_HTTP_HOST_MAX];
  char port_buf[8];
  char path_buf[SHU_HTTP_PATH_MAX];
  if (!p || !url || url_len <= 0) return 0;
  if (parse_http_url(url, url_len, host_buf, SHU_HTTP_HOST_MAX, port_buf, (int)sizeof(port_buf),
                     path_buf, SHU_HTTP_PATH_MAX) != 0)
    return 0;
  if (strcmp(host_buf, p->host) != 0) return 0;
  if (strcmp(port_buf, p->port) != 0) return 0;
  return 1;
}

/** 新建 TCP 连接至 pool 绑定的 host:port。 */
static int http_pool_connect_new(http_client_pool_t *p) {
  struct addrinfo hints;
  struct addrinfo *res = NULL;
  int fd;
  if (!p) return -1;
#if defined(_WIN32) || defined(_WIN64)
  {
    WSADATA wsa;
    if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0) return -1;
  }
#endif
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  if (getaddrinfo(p->host, p->port, &hints, &res) != 0 || !res) {
#if defined(_WIN32) || defined(_WIN64)
    WSACleanup();
#endif
    return -1;
  }
#if defined(_WIN32) || defined(_WIN64)
  {
    SOCKET s = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (s == INVALID_SOCKET) {
      freeaddrinfo(res);
      WSACleanup();
      return -1;
    }
    if (connect(s, res->ai_addr, (int)res->ai_addrlen) != 0) {
      SHU_HTTP_CLOSE((int)s);
      freeaddrinfo(res);
      WSACleanup();
      return -1;
    }
    fd = (int)s;
  }
#else
  fd = (int)socket(res->ai_family, res->ai_socktype, res->ai_protocol);
  if (fd < 0) {
    freeaddrinfo(res);
    return -1;
  }
  if (connect(fd, res->ai_addr, (socklen_t)res->ai_addrlen) != 0) {
    SHU_HTTP_CLOSE(fd);
    freeaddrinfo(res);
    return -1;
  }
#endif
  freeaddrinfo(res);
  p->connect_count++;
  return fd;
}

/** 从 pool 取 idle fd 或新建连接。 */
static int http_pool_acquire_fd(http_client_pool_t *p) {
  if (!p) return -1;
  if (p->n_idle > 0) return p->fds[--p->n_idle];
  return http_pool_connect_new(p);
}

/** 归还 fd 到 pool；池满则关闭。 */
static void http_pool_release_fd(http_client_pool_t *p, int fd) {
  if (!p || fd < 0) return;
  if (p->n_idle < p->max_conns) {
    p->fds[p->n_idle++] = fd;
    return;
  }
  SHU_HTTP_CLOSE(fd);
}

/** 在已连接 fd 上发 GET 并读完整响应（按 Content-Length，兼容 keep-alive）。 */
static int32_t http_get_on_fd_c(int fd, const char *host, const char *path,
                                uint8_t *out_buf, int32_t out_cap) {
  char req[SHU_HTTP_REQ_MAX];
  int req_len;
  int32_t total;
  int32_t hdr_end;
  int32_t body_len;
  int32_t need;
  if (fd < 0 || !host || !path || !out_buf || out_cap <= 0) return -1;
  req_len = snprintf(req, sizeof(req),
                     "GET %s HTTP/1.1\r\nHost: %s\r\nConnection: keep-alive\r\n\r\n",
                     path, host);
  if (req_len <= 0 || req_len >= (int)sizeof(req)) return -1;
  if (shu_http_send_all(fd, req, req_len, 0) != 0) return -1;
  total = 0;
  hdr_end = -1;
  body_len = -1;
  while (total < out_cap) {
#if defined(_WIN32) || defined(_WIN64)
    int n = recv((SOCKET)fd, (char *)out_buf + total, (int)(out_cap - total), 0);
#else
    ssize_t n = recv(fd, out_buf + total, (size_t)(out_cap - total), 0);
#endif
    if (n <= 0) return -1;
    total += (int32_t)n;
    if (hdr_end < 0) {
      int32_t i;
      for (i = 3; i < total; i++) {
        if (out_buf[i - 3] == '\r' && out_buf[i - 2] == '\n' &&
            out_buf[i - 1] == '\r' && out_buf[i] == '\n') {
          hdr_end = i + 1;
          break;
        }
      }
    }
    if (hdr_end > 0 && body_len < 0) {
      char saved;
      const char *cl;
      char *endp;
      long v;
      saved = out_buf[hdr_end];
      out_buf[hdr_end] = '\0';
      cl = strstr((char *)out_buf, "Content-Length:");
      if (!cl) cl = strstr((char *)out_buf, "content-length:");
      out_buf[hdr_end] = saved;
      if (!cl) return -1;
      cl += 15;
      while (*cl == ' ' || *cl == '\t') cl++;
      v = strtol(cl, &endp, 10);
      if (endp == cl || v < 0 || v > out_cap - hdr_end) return -1;
      body_len = (int32_t)v;
    }
    if (hdr_end > 0 && body_len >= 0) {
      need = hdr_end + body_len;
      if (total >= need) return need;
    }
  }
  return -1;
}

/**
 * STD-107：创建 HTTP client 连接池（绑定 host:port）。
 * @return 池句柄（i64），失败 0
 */
int64_t http_client_pool_create_c(const uint8_t *host, int32_t host_len,
                                  const uint8_t *port, int32_t port_len,
                                  int32_t max_conns) {
  http_client_pool_t *p;
  if (!host || host_len <= 0 || host_len >= SHU_HTTP_HOST_MAX) return 0;
  if (!port || port_len <= 0 || port_len >= 8) return 0;
  if (max_conns <= 0) max_conns = 1;
  if (max_conns > HTTP_POOL_MAX_CONNS) max_conns = HTTP_POOL_MAX_CONNS;
  p = (http_client_pool_t *)calloc(1, sizeof(*p));
  if (!p) return 0;
  memcpy(p->host, host, (size_t)host_len);
  p->host[host_len] = '\0';
  memcpy(p->port, port, (size_t)port_len);
  p->port[port_len] = '\0';
  p->max_conns = max_conns;
  return (int64_t)(intptr_t)p;
}

/** STD-107：关闭池内全部 idle 连接并释放池。 */
void http_client_pool_destroy_c(int64_t pool_h) {
  http_client_pool_t *p = (http_client_pool_t *)(intptr_t)pool_h;
  int i;
  if (!p) return;
  for (i = 0; i < p->n_idle; i++) SHU_HTTP_CLOSE(p->fds[i]);
  free(p);
}

/**
 * STD-107：经连接池发 GET；keep-alive 时归还 idle，否则关闭。
 * @return 响应字节数，失败 -1
 */
int32_t http_client_pool_get_c(int64_t pool_h, const uint8_t *url, int32_t url_len,
                               uint8_t *out_buf, int32_t out_cap) {
  http_client_pool_t *p = (http_client_pool_t *)(intptr_t)pool_h;
  char host_buf[SHU_HTTP_HOST_MAX];
  char port_buf[8];
  char path_buf[SHU_HTTP_PATH_MAX];
  int fd;
  int32_t n;
  if (!p || !url || !out_buf || url_len <= 0 || out_cap <= 0) return -1;
  if (!http_pool_url_matches(p, url, url_len)) return -1;
  if (parse_http_url(url, url_len, host_buf, SHU_HTTP_HOST_MAX, port_buf, (int)sizeof(port_buf),
                     path_buf, SHU_HTTP_PATH_MAX) != 0)
    return -1;
  fd = http_pool_acquire_fd(p);
  if (fd < 0) return -1;
  n = http_get_on_fd_c(fd, p->host, path_buf, out_buf, out_cap);
  if (n < 0) {
    SHU_HTTP_CLOSE(fd);
    return -1;
  }
  if (http_has_keep_alive_c(out_buf, n)) {
    http_pool_release_fd(p, fd);
  } else {
    SHU_HTTP_CLOSE(fd);
  }
  return n;
}

/** 烟测用：返回 pool 累计新建连接次数。 */
static int32_t http_client_pool_connect_count_c(int64_t pool_h) {
  http_client_pool_t *p = (http_client_pool_t *)(intptr_t)pool_h;
  if (!p) return -1;
  return p->connect_count;
}

/**
 * STD-107 C 烟测：serve_one + client pool keep-alive 复用（connect_count==1）。
 * Windows 跳过返回 0。
 */
int32_t http_server_pool_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
  return 0;
#else
  struct sockaddr_in sin;
  socklen_t slen = (socklen_t)sizeof(sin);
  char url[128];
  char host[] = "127.0.0.1";
  char port_dyn[8];
  uint8_t out[512];
  uint8_t client_buf[256];
  pid_t pid;
  int lfd;
  uint16_t bound_port;
  int64_t pool;
  int32_t cc;
  int32_t code;
  int32_t n1;
  int32_t n2;
  int status;
  static const uint8_t body[] = "ok";
  static const char get_req[] = "GET / HTTP/1.0\r\nHost: localhost\r\n\r\n";

  lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
  if (lfd < 0) return 1;
  slen = (socklen_t)sizeof(sin);
  if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
    SHU_HTTP_CLOSE(lfd);
    return 2;
  }
  bound_port = ntohs(sin.sin_port);
  if (snprintf(port_dyn, sizeof(port_dyn), "%u", (unsigned)bound_port) <= 0) {
    SHU_HTTP_CLOSE(lfd);
    return 3;
  }
  if (snprintf(url, sizeof(url), "http://127.0.0.1:%u/", (unsigned)bound_port) <= 0) {
    SHU_HTTP_CLOSE(lfd);
    return 4;
  }

  /* Part 1：serve_one — 子进程作 client */
  pid = fork();
  if (pid < 0) {
    SHU_HTTP_CLOSE(lfd);
    return 5;
  }
  if (pid == 0) {
    struct sockaddr_in cli;
    int cfd;
    int sent;
    memset(&cli, 0, sizeof(cli));
    cli.sin_family = AF_INET;
    cli.sin_port = htons(bound_port);
    cli.sin_addr.s_addr = htonl(0x7f000001u);
    cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
    if (cfd < 0) _exit(1);
    if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
      SHU_HTTP_CLOSE(cfd);
      _exit(2);
    }
    sent = 0;
    while (sent < (int)sizeof(get_req) - 1) {
      ssize_t n = send(cfd, get_req + sent, sizeof(get_req) - 1u - (size_t)sent, 0);
      if (n <= 0) {
        SHU_HTTP_CLOSE(cfd);
        _exit(3);
      }
      sent += (int)n;
    }
    {
      ssize_t nr = recv(cfd, client_buf, sizeof(client_buf) - 1u, 0);
      if (nr <= 0) {
        SHU_HTTP_CLOSE(cfd);
        _exit(4);
      }
      client_buf[nr] = '\0';
      if (strstr((char *)client_buf, "200 OK") == NULL) {
        SHU_HTTP_CLOSE(cfd);
        _exit(5);
      }
    }
    SHU_HTTP_CLOSE(cfd);
    _exit(0);
  }
  if (http_serve_one_c(lfd, body, 2, 3000u) != 0) {
    (void)kill(pid, SIGKILL);
    (void)waitpid(pid, NULL, 0);
    SHU_HTTP_CLOSE(lfd);
    return 6;
  }
  if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
    SHU_HTTP_CLOSE(lfd);
    return 7;
  }

  /* Part 2：client pool — 子进程同一连接处理两次 keep-alive */
  pid = fork();
  if (pid < 0) {
    SHU_HTTP_CLOSE(lfd);
    return 8;
  }
  if (pid == 0) {
    int client;
    int i;
    client = (int)accept(lfd, NULL, NULL);
    if (client >= 0) {
      for (i = 0; i < 2; i++) {
        if (http_respond_get_ok_keepalive_c(client, body, 2) != 0) break;
      }
      SHU_HTTP_CLOSE(client);
    }
    SHU_HTTP_CLOSE(lfd);
    _exit(0);
  }

  (void)usleep(80000);

  pool = http_client_pool_create_c((const uint8_t *)host, (int32_t)strlen(host),
                                   (const uint8_t *)port_dyn, (int32_t)strlen(port_dyn), 2);
  if (pool == 0) {
    (void)kill(pid, SIGKILL);
    (void)waitpid(pid, NULL, 0);
    SHU_HTTP_CLOSE(lfd);
    return 9;
  }
  n1 = http_client_pool_get_c(pool, (const uint8_t *)url, (int32_t)strlen(url), out, (int32_t)sizeof(out));
  n2 = http_client_pool_get_c(pool, (const uint8_t *)url, (int32_t)strlen(url), out, (int32_t)sizeof(out));
  cc = http_client_pool_connect_count_c(pool);
  http_client_pool_destroy_c(pool);
  SHU_HTTP_CLOSE(lfd);
  (void)kill(pid, SIGKILL);
  (void)waitpid(pid, NULL, 0);

  if (n1 <= 0 || n2 <= 0) return 10;
  if (cc != 1) return 11;
  if (http_parse_status_line_c(out, n2, &code) != 0 || code != 200) return 12;
  return 0;
#endif
}
