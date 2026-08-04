/**
 * net_udp_many_client.c — N4 基线 client：批量 sendmmsg/sendto 发 UDP（供 run-perf-net.sh 驱动 server）
 * 用法：net_udp_many_client [port] [n_pkts]  默认 38458 / 4096
 */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#if defined(__linux__) && defined(__GLIBC__)
#include <sys/uio.h>
#endif

enum { UDP_PORT_DEFAULT = 38458, UDP_PKTS_DEFAULT = 4096, UDP_BATCH = 8, UDP_PKT_LEN = 64 };

int main(int argc, char **argv) {
  int fd;
  uint16_t port = (uint16_t)UDP_PORT_DEFAULT;
  int n_pkts = UDP_PKTS_DEFAULT;
  struct sockaddr_in dst;
  uint8_t payloads[UDP_BATCH][UDP_PKT_LEN];
  int sent_total = 0;
  int bi;
  if (argc >= 2)
    port = (uint16_t)atoi(argv[1]);
  if (argc >= 3)
    n_pkts = atoi(argv[2]);
  if (n_pkts <= 0) {
    fprintf(stderr, "net_udp_many_client: invalid n_pkts\n");
    return 1;
  }
  for (bi = 0; bi < UDP_BATCH; bi++) {
    int j;
    for (j = 0; j < UDP_PKT_LEN; j++)
      payloads[bi][j] = (uint8_t)((bi + j) & 255);
  }
  fd = socket(AF_INET, SOCK_DGRAM, 0);
  if (fd < 0) {
    perror("socket");
    return 1;
  }
  memset(&dst, 0, sizeof(dst));
  dst.sin_family = AF_INET;
  dst.sin_port = htons(port);
  dst.sin_addr.s_addr = htonl(0x7f000001u);
  while (sent_total < n_pkts) {
    int batch = n_pkts - sent_total;
    if (batch > UDP_BATCH)
      batch = UDP_BATCH;
#if defined(__linux__) && defined(__GLIBC__)
    {
      struct iovec iov[UDP_BATCH];
      struct mmsghdr msgvec[UDP_BATCH];
      unsigned int i;
      for (i = 0; i < (unsigned int)batch; i++) {
        iov[i].iov_base = payloads[i];
        iov[i].iov_len = UDP_PKT_LEN;
        msgvec[i].msg_hdr.msg_name = &dst;
        msgvec[i].msg_hdr.msg_namelen = sizeof(dst);
        msgvec[i].msg_hdr.msg_iov = &iov[i];
        msgvec[i].msg_hdr.msg_iovlen = 1;
        msgvec[i].msg_hdr.msg_control = NULL;
        msgvec[i].msg_hdr.msg_controllen = 0;
        msgvec[i].msg_hdr.msg_flags = 0;
      }
      if (sendmmsg(fd, msgvec, (unsigned int)batch, 0) != batch) {
        perror("sendmmsg");
        (void)close(fd);
        return 2;
      }
    }
#else
    {
      int i;
      for (i = 0; i < batch; i++) {
        if (sendto(fd, payloads[i], UDP_PKT_LEN, 0, (struct sockaddr *)&dst, sizeof(dst)) != UDP_PKT_LEN) {
          perror("sendto");
          (void)close(fd);
          return 2;
        }
      }
    }
#endif
    sent_total += batch;
  }
  if (close(fd) != 0) {
    perror("close");
    return 3;
  }
  return 0;
}
