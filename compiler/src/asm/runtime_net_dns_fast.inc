#include <stdint.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <winsock2.h>
#include <ws2tcpip.h>
static int net_dns_wsa_ready = 0;
#else
#include <arpa/inet.h>
#include <netdb.h>
#include <netinet/in.h>
#endif

int32_t net_resolve_ipv4_ex_c(uint8_t *hostname, uint32_t *out_addr, int32_t *out_err);
int32_t net_resolve_ipv6_ex_c(uint8_t *hostname, uint8_t *out_addr_16, int32_t *out_err);

static int32_t net_dns_ai_addconfig_c(void) {
#if defined(__linux__)
    return 32;
#else
    return 1024;
#endif
}

static int32_t net_dns_map_gai_error_c(int err) {
#if defined(__linux__)
    if (err == EAI_NONAME)
        return 1;
#ifdef EAI_NODATA
    if (err == EAI_NODATA)
        return 2;
#endif
    if (err == EAI_AGAIN)
        return 3;
    return 4;
#elif defined(__APPLE__)
    if (err == EAI_NONAME)
        return 1;
#ifdef EAI_NODATA
    if (err == EAI_NODATA)
        return 2;
#endif
    if (err == EAI_AGAIN)
        return 3;
    return 4;
#elif defined(_WIN32) || defined(_WIN64)
    if (err == WSANO_DATA || err == WSAHOST_NOT_FOUND)
        return 1;
    if (err == WSANO_RECOVERY)
        return 2;
    if (err == WSATRY_AGAIN)
        return 3;
    return 4;
#else
    (void)err;
    return 4;
#endif
}

static int32_t net_dns_ensure_wsa_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    WSADATA data;
    if (net_dns_wsa_ready)
        return 0;
    if (WSAStartup(MAKEWORD(2, 2), &data) != 0)
        return -1;
    net_dns_wsa_ready = 1;
#endif
    return 0;
}

uint32_t net_resolve_ipv4_c(uint8_t *hostname) {
    uint32_t addr = 0;
    int32_t err = 0;
    if (net_resolve_ipv4_ex_c(hostname, &addr, &err) != 0)
        return 0;
    return addr;
}

int32_t net_resolve_ipv4_ex_c(uint8_t *hostname, uint32_t *out_addr, int32_t *out_err) {
    struct addrinfo hints;
    struct addrinfo *res = 0;
    struct sockaddr_in *sa = 0;
    int ga = 0;
    uint32_t addr_u32 = 0;
    if (net_dns_ensure_wsa_c() != 0) {
        if (out_addr)
            out_addr[0] = 0;
        if (out_err)
            out_err[0] = 4;
        return -1;
    }
    if (!hostname) {
        if (out_addr)
            out_addr[0] = 0;
        if (out_err)
            out_err[0] = 4;
        return -1;
    }
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = net_dns_ai_addconfig_c();
    ga = getaddrinfo((const char *)hostname, 0, &hints, &res);
    if (ga != 0 || !res) {
        if (out_addr)
            out_addr[0] = 0;
        if (out_err)
            out_err[0] = net_dns_map_gai_error_c(ga);
        if (res)
            freeaddrinfo(res);
        return -1;
    }
    if (res->ai_family == AF_INET && res->ai_addr && res->ai_addrlen >= (socklen_t)sizeof(struct sockaddr_in)) {
        sa = (struct sockaddr_in *)(void *)res->ai_addr;
        addr_u32 = ntohl(sa->sin_addr.s_addr);
    }
    freeaddrinfo(res);
    if (addr_u32 == 0) {
        if (out_addr)
            out_addr[0] = 0;
        if (out_err)
            out_err[0] = 2;
        return -1;
    }
    if (out_addr)
        out_addr[0] = addr_u32;
    if (out_err)
        out_err[0] = 0;
    return 0;
}

int32_t net_resolve_ipv6_ex_c(uint8_t *hostname, uint8_t *out_addr_16, int32_t *out_err) {
    struct addrinfo hints;
    struct addrinfo *res = 0;
    struct sockaddr_in6 *sa6 = 0;
    int ga = 0;
    if (net_dns_ensure_wsa_c() != 0) {
        if (out_err)
            out_err[0] = 4;
        return -1;
    }
    if (!hostname || !out_addr_16) {
        if (out_err)
            out_err[0] = 4;
        return -1;
    }
    memset(out_addr_16, 0, 16);
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET6;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = net_dns_ai_addconfig_c();
    ga = getaddrinfo((const char *)hostname, 0, &hints, &res);
    if (ga != 0 || !res) {
        if (out_err)
            out_err[0] = net_dns_map_gai_error_c(ga);
        if (res)
            freeaddrinfo(res);
        return -1;
    }
    if (res->ai_family != AF_INET6 || !res->ai_addr || res->ai_addrlen < (socklen_t)sizeof(struct sockaddr_in6)) {
        if (out_err)
            out_err[0] = 2;
        freeaddrinfo(res);
        return -1;
    }
    sa6 = (struct sockaddr_in6 *)(void *)res->ai_addr;
    memcpy(out_addr_16, &sa6->sin6_addr, 16);
    freeaddrinfo(res);
    if (out_err)
        out_err[0] = 0;
    return 0;
}
