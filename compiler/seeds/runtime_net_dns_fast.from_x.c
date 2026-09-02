/* seeds/runtime_net_dns_fast.from_x.c — G-02f-20 product TU
 * G-02f-103 helper gates.
 * Product: ../std/net/net_dns_fast.o; logic still C until full .x port.
 * Cap residual 9.1.7 slice2: resolve via xlang_dns_cap.h (no libc getaddrinfo).
 */
#include <stdint.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <winsock2.h>
#include <ws2tcpip.h>
static int net_dns_wsa_ready = 0;
#else
/* PLATFORM: POSIX — Darwin xlang_net_fcntl calls fcntl(2), which lives in
 * <fcntl.h> not <unistd.h>. ipv6_fast/sock_fast/http_glue already include
 * it; this seed did not, so cc of dns_fast failed undeclared-fcntl after
 * net/mod.x connect clash closed. Do NOT add <fcntl.h> to xlang_net_cap.h:
 * formal_mod KEEP_C (rt_preamble injects that header) already has X
 * `static open` / leftover 3-arg fcntl, and Darwin fcntl.h's open() +
 * variadic fcntl() conflict. G.7 complete this seed's include bag.
 */
#include <fcntl.h>
#include <xlang_dns_cap.h>
#endif

int32_t net_resolve_ipv4_ex_c(uint8_t *hostname, uint32_t *out_addr, int32_t *out_err);
int32_t net_resolve_ipv6_ex_c(uint8_t *hostname, uint8_t *out_addr_16, int32_t *out_err);
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-20 thin+rest：_impl 实现；thin（src/asm/runtime_net_dns_fast.x）提供 public wrapper */

int32_t net_dns_ai_addconfig_c_impl_c(void) {
#if defined(__linux__)
    return 32;
#else
    return 1024;
#endif
}

#ifndef XLANG_RUNTIME_NET_DNS_FAST_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
int32_t net_dns_ai_addconfig_c(void) {
    return net_dns_ai_addconfig_c_impl_c();
}
#endif

int32_t net_dns_map_gai_error_c_impl_c(int err) {
#if defined(__linux__)
    /* Cap residual errors already use product map 1/2/3/4. */
    if (err == 1)
        return 1;
    if (err == 2)
        return 2;
    if (err == 3)
        return 3;
    return 4;
#elif defined(__APPLE__)
    if (err == 8) /* EAI_NONAME Darwin */
        return 1;
    if (err == 7) /* EAI_NODATA */
        return 2;
    if (err == 2) /* EAI_AGAIN */
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

#ifndef XLANG_RUNTIME_NET_DNS_FAST_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
int32_t net_dns_map_gai_error_c(int err) {
    return net_dns_map_gai_error_c_impl_c(err);
}
#endif

int32_t net_dns_ensure_wsa_c_impl_c(void) {
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

#ifndef XLANG_RUNTIME_NET_DNS_FAST_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
int32_t net_dns_ensure_wsa_c(void) {
    return net_dns_ensure_wsa_c_impl_c();
}
#endif

uint32_t net_resolve_ipv4_c(uint8_t *hostname) {
    uint32_t addr = 0;
    int32_t err = 0;
    if (net_resolve_ipv4_ex_c(hostname, &addr, &err) != 0)
        return 0;
    return addr;
}

/**
 * Cap residual 9.1.7 slice2: IPv4 resolve via xlang_dns_cap.h.
 * Exported for dns.x / http_glue. PLATFORM: LINUX Cap; Win keeps Winsock.
 */
int32_t xlang_dns_cap_resolve_ipv4(uint8_t *hostname, uint32_t *out_addr, int32_t *out_err) {
#if defined(_WIN32) || defined(_WIN64)
    struct addrinfo hints;
    struct addrinfo *res = 0;
    struct sockaddr_in *sa = 0;
    int ga = 0;
    uint32_t addr_u32 = 0;
    if (net_dns_ensure_wsa_c_impl_c() != 0) {
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
    ga = getaddrinfo((const char *)hostname, 0, &hints, &res);
    if (ga != 0 || !res) {
        if (out_addr)
            out_addr[0] = 0;
        if (out_err)
            out_err[0] = net_dns_map_gai_error_c_impl_c(ga);
        if (res)
            freeaddrinfo(res);
        return -1;
    }
    if (res->ai_family == AF_INET && res->ai_addr &&
        res->ai_addrlen >= (socklen_t)sizeof(struct sockaddr_in)) {
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
#else
    return (int32_t)xlang_dns_resolve_ipv4((const char *)hostname, out_addr, out_err);
#endif
}

/**
 * Cap residual 9.1.7 slice2: IPv6 resolve via xlang_dns_cap.h.
 */
int32_t xlang_dns_cap_resolve_ipv6(uint8_t *hostname, uint8_t *out_addr_16, int32_t *out_err) {
#if defined(_WIN32) || defined(_WIN64)
    struct addrinfo hints;
    struct addrinfo *res = 0;
    struct sockaddr_in6 *sa6 = 0;
    int ga = 0;
    if (net_dns_ensure_wsa_c_impl_c() != 0) {
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
    ga = getaddrinfo((const char *)hostname, 0, &hints, &res);
    if (ga != 0 || !res) {
        if (out_err)
            out_err[0] = net_dns_map_gai_error_c_impl_c(ga);
        if (res)
            freeaddrinfo(res);
        return -1;
    }
    if (res->ai_family != AF_INET6 || !res->ai_addr ||
        res->ai_addrlen < (socklen_t)sizeof(struct sockaddr_in6)) {
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
#else
    return (int32_t)xlang_dns_resolve_ipv6((const char *)hostname, out_addr_16, out_err);
#endif
}

int32_t net_resolve_ipv4_ex_c(uint8_t *hostname, uint32_t *out_addr, int32_t *out_err) {
    return xlang_dns_cap_resolve_ipv4(hostname, out_addr, out_err);
}

int32_t net_resolve_ipv6_ex_c(uint8_t *hostname, uint8_t *out_addr_16, int32_t *out_err) {
    return xlang_dns_cap_resolve_ipv6(hostname, out_addr_16, out_err);
}
