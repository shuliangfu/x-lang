#include <stdint.h>

#if defined(_WIN32) || defined(_WIN64)
#include <winsock2.h>
#include <ws2tcpip.h>
typedef int shux_socklen_t;
#else
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
typedef socklen_t shux_socklen_t;
#endif

static int64_t net_sockaddr_in_pack_addr_port_c(uint8_t *sin_ptr) {
    struct sockaddr_in *sa = (struct sockaddr_in *)(void *)sin_ptr;
    uint32_t addr = ntohl(sa->sin_addr.s_addr);
    uint32_t port = (uint32_t)ntohs(sa->sin_port);
    return ((int64_t)addr << 32) | (int64_t)(port & 0xffffu);
}

int64_t net_tcp_local_addr_c(int32_t fd) {
    struct sockaddr_in sa;
    shux_socklen_t len = (shux_socklen_t)sizeof(sa);
    if (getsockname(fd, (struct sockaddr *)(void *)&sa, &len) != 0)
        return (int64_t)-1;
    return net_sockaddr_in_pack_addr_port_c((uint8_t *)(void *)&sa);
}

int64_t net_tcp_peer_addr_c(int32_t fd) {
    struct sockaddr_in sa;
    shux_socklen_t len = (shux_socklen_t)sizeof(sa);
    if (getpeername(fd, (struct sockaddr *)(void *)&sa, &len) != 0)
        return (int64_t)-1;
    return net_sockaddr_in_pack_addr_port_c((uint8_t *)(void *)&sa);
}
