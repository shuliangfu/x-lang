/* seeds/runtime_net_addr_fast.from_x.c — G-02f-20 product TU
 * Product: ../std/net/net_addr_fast.o; logic still C until full .x port.
 */
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

/* 【Why 根源】asm codegen 对 `p_family[0] = AF_INET as u16` 等 u16 间接 store 会错发 64 位 store；
 * TCP/UDP listen/bind 须走 C 实现以保证 sa_family/sin_port/sin_addr 正确。
 * 从 net_import_alias.c 迁入（F-闭合消除 *_import_alias.c 命名）。
 * 【Invariant】sin 指向至少 16 字节可写缓冲（sizeof(sockaddr_in)==16）；addr_u32 为主机序。
 * 【Asm/Perf】htonl/htons 编译为单条 bswap 指令（x86）或 rev（ARM）。 */
void net_tcp_set_addr_port_buf_c(uint8_t *sin, uint32_t addr_u32, uint32_t port_u32) {
    struct sockaddr_in *sa = (struct sockaddr_in *)(void *)sin;
    sa->sin_family = AF_INET;
    sa->sin_port = htons((uint16_t)(port_u32 & 0xffffu));
    sa->sin_addr.s_addr = htonl(addr_u32);
}

/* 【Why 根源】与 net_tcp_set_addr_port_buf_c 相同布局；UDP bind/sendto 共用。 */
void net_udp_set_addr_port_buf_c(uint8_t *sin, uint32_t addr_u32, uint32_t port_u32) {
    net_tcp_set_addr_port_buf_c(sin, addr_u32, port_u32);
}
