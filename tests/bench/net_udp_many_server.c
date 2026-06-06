/**
 * net_udp_many_server.c — N4 基线 server：recvmmsg/recvfrom 循环收 UDP（C -O2 对照）
 * 用法：net_udp_many_server [port] [n_pkts]  默认 38458 / 4096
 */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>

#if defined(__linux__) && defined(__GLIBC__)
#include <sys/uio.h>
#endif

enum { UDP_PORT_DEFAULT = 38458, UDP_PKTS_DEFAULT = 4096, UDP_BATCH = 8, UDP_PKT_LEN = 64 };

#if defined(__linux__) && defined(__GLIBC__)
/** Linux：recvmmsg 批量收包，最多 UDP_BATCH 条。 */
static int recv_batch(int fd, uint8_t *bufs[UDP_BATCH], int n, int32_t *out_sizes) {
  struct iovec iov[UDP_BATCH];
  struct sockaddr_in addrs[UDP_BATCH];
  struct mmsghdr msgvec[UDP_BATCH];
  unsigned int i;
  for (i = 0; i < (unsigned int)n; i++) {
    socklen_t addrlen = sizeof(addrs[0]);
    iov[i].iov_base = bufs[i];
    iov[i].iov_len = UDP_PKT_LEN;
    msgvec[i].msg_hdr.msg_name = &addrs[i];
    msgvec[i].msg_hdr.msg_namelen = addrlen;
    msgvec[i].msg_hdr.msg_iov = &iov[i];
    msgvec[i].msg_hdr.msg_iovlen = 1;
    msgvec[i].msg_hdr.msg_control = NULL;
    msgvec[i].msg_hdr.msg_controllen = 0;
    msgvec[i].msg_hdr.msg_flags = 0;
  }
  {
    int r = recvmmsg(fd, msgvec, (unsigned int)n, 0, NULL);
    if (r < 0)
      return -1;
    for (i = 0; i < (unsigned int)r; i++)
      out_sizes[i] = (int32_t)msgvec[i].msg_len;
    return r;
  }
}
#endif

int main(int argc, char **argv) {
  int fd;
  uint16_t port = (uint16_t)UDP_PORT_DEFAULT;
  int target = UDP_PKTS_DEFAULT;
  int total = 0;
  int32_t sum = 0;
  struct sockaddr_in sin;
  int opt = 1;
  uint8_t b0[UDP_PKT_LEN];
  uint8_t b1[UDP_PKT_LEN];
  uint8_t b2[UDP_PKT_LEN];
  uint8_t b3[UDP_PKT_LEN];
  uint8_t b4[UDP_PKT_LEN];
  uint8_t b5[UDP_PKT_LEN];
  uint8_t b6[UDP_PKT_LEN];
  uint8_t b7[UDP_PKT_LEN];
  if (argc >= 2)
    port = (uint16_t)atoi(argv[1]);
  if (argc >= 3)
    target = atoi(argv[2]);
  if (target <= 0)
    target = UDP_PKTS_DEFAULT;
  fd = socket(AF_INET, SOCK_DGRAM, 0);
  if (fd < 0) {
    perror("socket");
    return 1;
  }
  (void)setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
  memset(&sin, 0, sizeof(sin));
  sin.sin_family = AF_INET;
  sin.sin_port = htons(port);
  sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  if (bind(fd, (struct sockaddr *)&sin, sizeof(sin)) != 0) {
    perror("bind");
    (void)close(fd);
    return 1;
  }
  {
    /** bench 用：避免 client 未就绪时 recvfrom 永久阻塞（CI/本地脚本）。 */
    struct timeval rcv_to;
    rcv_to.tv_sec = 2;
    rcv_to.tv_usec = 0;
    (void)setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &rcv_to, sizeof(rcv_to));
  }
  while (total < target) {
#if defined(__linux__) && defined(__GLIBC__)
    {
      uint8_t *bufs[UDP_BATCH] = { b0, b1, b2, b3, b4, b5, b6, b7 };
      int32_t sizes[UDP_BATCH];
      int n = recv_batch(fd, bufs, UDP_BATCH, sizes);
      int j;
      if (n <= 0) {
        perror("recvmmsg");
        (void)close(fd);
        return 2;
      }
      for (j = 0; j < n; j++)
        sum += sizes[j];
      total += n;
    }
#else
    {
      struct sockaddr_in peer;
      socklen_t peer_len = sizeof(peer);
      uint8_t buf[UDP_PKT_LEN];
      ssize_t got = recvfrom(fd, buf, sizeof(buf), 0, (struct sockaddr *)&peer, &peer_len);
      if (got < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK)
          continue;
        perror("recvfrom");
        (void)close(fd);
        return 2;
      }
      if (got == 0)
        continue;
      sum += (int32_t)got;
      total++;
    }
#endif
  }
  if (close(fd) != 0) {
    perror("close");
    return 3;
  }
  return sum & 255;
}
