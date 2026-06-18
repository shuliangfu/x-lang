/**
 * http_bench_server.c — STD-009：最小 HTTP GET server sink（供 http_get_bench.su 驱动）
 * 用法：http_bench_server [port]  默认 38460
 */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

extern int32_t http_respond_get_ok_c(int fd, const uint8_t *body, int32_t body_len);

enum { HTTP_BENCH_PORT = 38460 };

int main(int argc, char **argv) {
  int listener;
  int client;
  uint16_t port = (uint16_t)HTTP_BENCH_PORT;
  struct sockaddr_in sin;
  socklen_t peer_len = sizeof(sin);
  int opt = 1;
  static const uint8_t body[] = "ok";

  if (argc >= 2)
    port = (uint16_t)atoi(argv[1]);
  listener = socket(AF_INET, SOCK_STREAM, 0);
  if (listener < 0) {
    perror("socket");
    return 1;
  }
  (void)setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
  memset(&sin, 0, sizeof(sin));
  sin.sin_family = AF_INET;
  sin.sin_port = htons(port);
  sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  if (bind(listener, (struct sockaddr *)&sin, sizeof(sin)) != 0) {
    perror("bind");
    (void)close(listener);
    return 1;
  }
  if (listen(listener, 16) != 0) {
    perror("listen");
    (void)close(listener);
    return 1;
  }
  for (;;) {
    client = accept(listener, (struct sockaddr *)&sin, &peer_len);
    if (client < 0)
      continue;
    (void)http_respond_get_ok_c(client, body, 2);
    (void)close(client);
  }
  return 0;
}
