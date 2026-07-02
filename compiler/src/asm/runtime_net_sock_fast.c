#include <stdint.h>

#if defined(_WIN32) || defined(_WIN64)
#include <winsock2.h>
#include <ws2tcpip.h>
#else
#include <fcntl.h>
#endif

int32_t net_set_blocking_c(int32_t fd, int32_t blocking) {
    if (fd < 0)
        return -1;
#if defined(_WIN32) || defined(_WIN64)
    u_long mode = blocking == 0 ? 1UL : 0UL;
    return ioctlsocket(fd, FIONBIO, &mode) == 0 ? 0 : -1;
#else
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags < 0)
        return -1;
    if (blocking != 0)
        flags &= ~O_NONBLOCK;
    else
        flags |= O_NONBLOCK;
    return fcntl(fd, F_SETFL, flags) == 0 ? 0 : -1;
#endif
}
