/*
 * xlang_net_cap.h — Cap residual 9.1.7: socket/connect/bind/listen/accept/poll/close
 * (slice0) + recvmmsg/sendmmsg (slice1) + sendto/recvfrom (slice2 DNS) without
 * libc those symbols on Linux (x86_64 + aarch64).
 * Cap residual 9.1.9: syscall asm via xlang_syscall_cap.h (G.7 single authority).
 *
 * Single authority for runtime_net_sock_fast, runtime_net_udp_batch,
 * xlang_dns_cap.h, and xlang_sys_* net symbols.
 *
 * Windows: not used — call sites keep Winsock.
 * Other POSIX: thin libc wrappers (Darwin residual until later; mmsg ENOSYS).
 *
 * PLATFORM: LINUX primary; POSIX fallback elsewhere (non-Win).
 */

#ifndef XLANG_NET_CAP_H
#define XLANG_NET_CAP_H

#if !defined(_WIN32) && !defined(_WIN64)

#include <errno.h>
#include <stddef.h>
#include <stdint.h>

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

#include <xlang_syscall_cap.h>

/** Cap residual 9.1.9: aliases → single syscall authority. */
#define xlang_net_syscall6 xlang_syscall6
#define xlang_net_syscall3 xlang_syscall3
#define xlang_net_syscall1 xlang_syscall1

/** Map negative kernel ret to -1 + errno. PLATFORM: LINUX. */
static inline int xlang_net_ret(long r) {
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return (int)r;
}

/**
 * Cap residual socket(2).
 * PLATFORM: LINUX
 */
static inline int xlang_net_socket(int domain, int type, int protocol) {
  long r;
#if defined(__x86_64__)
  /* socket = 41 */
  r = xlang_net_syscall3(41, (long)domain, (long)type, (long)protocol);
#elif defined(__aarch64__)
  /* socket = 198 */
  r = xlang_net_syscall3(198, (long)domain, (long)type, (long)protocol);
#endif
  return xlang_net_ret(r);
}

/**
 * Cap residual connect(2).
 * PLATFORM: LINUX
 */
static inline int xlang_net_connect(int sockfd, const void *addr, unsigned int addrlen) {
  long r;
  if (!addr && addrlen != 0)
    return -1;
#if defined(__x86_64__)
  /* connect = 42 */
  r = xlang_net_syscall3(42, (long)sockfd, (long)addr, (long)addrlen);
#elif defined(__aarch64__)
  /* connect = 203 */
  r = xlang_net_syscall3(203, (long)sockfd, (long)addr, (long)addrlen);
#endif
  return xlang_net_ret(r);
}

/**
 * Cap residual bind(2).
 * PLATFORM: LINUX
 */
static inline int xlang_net_bind(int sockfd, const void *addr, unsigned int addrlen) {
  long r;
  if (!addr && addrlen != 0)
    return -1;
#if defined(__x86_64__)
  /* bind = 49 */
  r = xlang_net_syscall3(49, (long)sockfd, (long)addr, (long)addrlen);
#elif defined(__aarch64__)
  /* bind = 200 */
  r = xlang_net_syscall3(200, (long)sockfd, (long)addr, (long)addrlen);
#endif
  return xlang_net_ret(r);
}

/**
 * Cap residual listen(2).
 * PLATFORM: LINUX
 */
static inline int xlang_net_listen(int sockfd, int backlog) {
  long r;
#if defined(__x86_64__)
  /* listen = 50 */
  r = xlang_net_syscall3(50, (long)sockfd, (long)backlog, 0);
#elif defined(__aarch64__)
  /* listen = 201 */
  r = xlang_net_syscall3(201, (long)sockfd, (long)backlog, 0);
#endif
  return xlang_net_ret(r);
}

/**
 * Cap residual accept(2) (addr/addrlen may be NULL).
 * PLATFORM: LINUX
 */
static inline int xlang_net_accept(int sockfd, void *addr, unsigned int *addrlen) {
  long r;
#if defined(__x86_64__)
  /* accept = 43 */
  r = xlang_net_syscall3(43, (long)sockfd, (long)addr, (long)addrlen);
#elif defined(__aarch64__)
  /* accept = 202 */
  r = xlang_net_syscall3(202, (long)sockfd, (long)addr, (long)addrlen);
#endif
  return xlang_net_ret(r);
}

/**
 * Cap residual setsockopt(2).
 * PLATFORM: LINUX
 */
static inline int xlang_net_setsockopt(int sockfd, int level, int optname, const void *optval,
                                      unsigned int optlen) {
  long r;
#if defined(__x86_64__)
  /* setsockopt = 54 */
  r = xlang_net_syscall6(54, (long)sockfd, (long)level, (long)optname, (long)optval, (long)optlen,
                         0);
#elif defined(__aarch64__)
  /* setsockopt = 208 */
  r = xlang_net_syscall6(208, (long)sockfd, (long)level, (long)optname, (long)optval, (long)optlen,
                         0);
#endif
  return xlang_net_ret(r);
}

/**
 * Cap residual close(2).
 * PLATFORM: LINUX
 */
static inline int xlang_net_close(int fd) {
  long r;
#if defined(__x86_64__)
  /* close = 3 */
  r = xlang_net_syscall1(3, (long)fd);
#elif defined(__aarch64__)
  /* close = 57 */
  r = xlang_net_syscall1(57, (long)fd);
#endif
  return xlang_net_ret(r);
}

/**
 * Cap residual poll(2).
 * x86_64: SYS_poll; aarch64: SYS_ppoll (no poll syscall).
 * @param timeout_ms -1 infinite; >=0 milliseconds
 * PLATFORM: LINUX
 */
static inline int xlang_net_poll(void *fds, unsigned int nfds, int timeout_ms) {
  long r;
  if (!fds && nfds != 0)
    return -1;
#if defined(__x86_64__)
  /* poll = 7 */
  r = xlang_net_syscall3(7, (long)fds, (long)nfds, (long)timeout_ms);
#elif defined(__aarch64__)
  /* ppoll = 73; convert ms timeout to timespec or NULL */
  {
    struct {
      long tv_sec;
      long tv_nsec;
    } ts;
    long tsp = 0;
    if (timeout_ms >= 0) {
      ts.tv_sec = (long)(timeout_ms / 1000);
      ts.tv_nsec = (long)(timeout_ms % 1000) * 1000000L;
      tsp = (long)&ts;
    }
    r = xlang_net_syscall6(73, (long)fds, (long)nfds, tsp, 0, 0, 0);
  }
#endif
  return xlang_net_ret(r);
}


/**
 * Cap residual recvmmsg(2).
 * x86_64 SYS_recvmmsg=299; aarch64 SYS_recvmmsg=243.
 * @param msgvec  struct mmsghdr * (void* to avoid pulling mmsg into Cap)
 * @param timeout struct timespec * or NULL
 * PLATFORM: LINUX
 */
static inline int xlang_net_recvmmsg(int sockfd, void *msgvec, unsigned int vlen, int flags,
                                     void *timeout) {
  long r;
  if (!msgvec && vlen != 0)
    return -1;
#if defined(__x86_64__)
  /* recvmmsg = 299 */
  r = xlang_net_syscall6(299, (long)sockfd, (long)msgvec, (long)vlen, (long)flags, (long)timeout,
                         0);
#elif defined(__aarch64__)
  /* recvmmsg = 243 */
  r = xlang_net_syscall6(243, (long)sockfd, (long)msgvec, (long)vlen, (long)flags, (long)timeout,
                         0);
#endif
  return xlang_net_ret(r);
}

/**
 * Cap residual sendmmsg(2).
 * x86_64 SYS_sendmmsg=307; aarch64 SYS_sendmmsg=269.
 * @param msgvec struct mmsghdr *
 * PLATFORM: LINUX
 */
static inline int xlang_net_sendmmsg(int sockfd, void *msgvec, unsigned int vlen, int flags) {
  long r;
  if (!msgvec && vlen != 0)
    return -1;
#if defined(__x86_64__)
  /* sendmmsg = 307 */
  r = xlang_net_syscall6(307, (long)sockfd, (long)msgvec, (long)vlen, (long)flags, 0, 0);
#elif defined(__aarch64__)
  /* sendmmsg = 269 */
  r = xlang_net_syscall6(269, (long)sockfd, (long)msgvec, (long)vlen, (long)flags, 0, 0);
#endif
  return xlang_net_ret(r);
}

/**
 * Cap residual sendto(2) — DNS Cap (9.1.7 slice2) UDP query.
 * PLATFORM: LINUX
 */
static inline long xlang_net_sendto(int sockfd, const void *buf, size_t len, int flags,
                                   const void *addr, unsigned int addrlen) {
  long r;
  if (!buf && len != 0)
    return -1;
#if defined(__x86_64__)
  /* sendto = 44 */
  r = xlang_net_syscall6(44, (long)sockfd, (long)buf, (long)len, (long)flags, (long)addr,
                         (long)addrlen);
#elif defined(__aarch64__)
  /* sendto = 206 */
  r = xlang_net_syscall6(206, (long)sockfd, (long)buf, (long)len, (long)flags, (long)addr,
                         (long)addrlen);
#endif
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return r;
}

/**
 * Cap residual recvfrom(2) — DNS Cap (9.1.7 slice2) UDP reply.
 * PLATFORM: LINUX
 */
static inline long xlang_net_recvfrom(int sockfd, void *buf, size_t len, int flags, void *addr,
                                     unsigned int *addrlen) {
  long r;
  if (!buf && len != 0)
    return -1;
#if defined(__x86_64__)
  /* recvfrom = 45 */
  r = xlang_net_syscall6(45, (long)sockfd, (long)buf, (long)len, (long)flags, (long)addr,
                         (long)addrlen);
#elif defined(__aarch64__)
  /* recvfrom = 207 */
  r = xlang_net_syscall6(207, (long)sockfd, (long)buf, (long)len, (long)flags, (long)addr,
                         (long)addrlen);
#endif
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return r;
}

#ifndef F_GETFL
#define F_GETFL 3
#endif
#ifndef F_SETFL
#define F_SETFL 4
#endif

/**
 * Cap residual fcntl F_GETFL / F_SETFL (nonblock dial).
 * Only cmd F_GETFL (arg ignored) and F_SETFL (arg = flags) are supported.
 * PLATFORM: LINUX
 */
static inline int xlang_net_fcntl(int fd, int cmd, long arg) {
  long r;
#if defined(__x86_64__)
  /* fcntl = 72 */
  r = xlang_net_syscall3(72, (long)fd, (long)cmd, arg);
#elif defined(__aarch64__)
  /* fcntl = 25 */
  r = xlang_net_syscall3(25, (long)fd, (long)cmd, arg);
#endif
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return (int)r;
}

#else /* !LINUX Cap — POSIX libc thin wrappers (Darwin residual) */

#include <poll.h>
#include <sys/socket.h>
#include <time.h>
#include <unistd.h>

/** PLATFORM: POSIX fallback — libc socket. */
static inline int xlang_net_socket(int domain, int type, int protocol) {
  return (int)socket(domain, type, protocol);
}

/** PLATFORM: POSIX fallback — libc connect. */
static inline int xlang_net_connect(int sockfd, const void *addr, unsigned int addrlen) {
  return connect(sockfd, (const struct sockaddr *)addr, (socklen_t)addrlen);
}

/** PLATFORM: POSIX fallback — libc bind. */
static inline int xlang_net_bind(int sockfd, const void *addr, unsigned int addrlen) {
  return bind(sockfd, (const struct sockaddr *)addr, (socklen_t)addrlen);
}

/** PLATFORM: POSIX fallback — libc listen. */
static inline int xlang_net_listen(int sockfd, int backlog) {
  return listen(sockfd, backlog);
}

/** PLATFORM: POSIX fallback — libc accept. */
static inline int xlang_net_accept(int sockfd, void *addr, unsigned int *addrlen) {
  return accept(sockfd, (struct sockaddr *)addr, (socklen_t *)addrlen);
}

/** PLATFORM: POSIX fallback — libc setsockopt. */
static inline int xlang_net_setsockopt(int sockfd, int level, int optname, const void *optval,
                                      unsigned int optlen) {
  return setsockopt(sockfd, level, optname, optval, (socklen_t)optlen);
}

/** PLATFORM: POSIX fallback — libc close. */
static inline int xlang_net_close(int fd) {
  return close(fd);
}

/** PLATFORM: POSIX fallback — libc poll. */
static inline int xlang_net_poll(void *fds, unsigned int nfds, int timeout_ms) {
  return poll((struct pollfd *)fds, (nfds_t)nfds, timeout_ms);
}


/**
 * Cap residual recvmmsg — libc on non-Apple POSIX; ENOSYS on Darwin.
 * PLATFORM: POSIX fallback
 */
static inline int xlang_net_recvmmsg(int sockfd, void *msgvec, unsigned int vlen, int flags,
                                     void *timeout) {
#if defined(__APPLE__)
  (void)sockfd;
  (void)msgvec;
  (void)vlen;
  (void)flags;
  (void)timeout;
  errno = ENOSYS;
  return -1;
#else
  return recvmmsg(sockfd, (struct mmsghdr *)msgvec, vlen, flags, (struct timespec *)timeout);
#endif
}

/**
 * Cap residual sendmmsg — libc on non-Apple POSIX; ENOSYS on Darwin.
 * PLATFORM: POSIX fallback
 */
static inline int xlang_net_sendmmsg(int sockfd, void *msgvec, unsigned int vlen, int flags) {
#if defined(__APPLE__)
  (void)sockfd;
  (void)msgvec;
  (void)vlen;
  (void)flags;
  errno = ENOSYS;
  return -1;
#else
  return sendmmsg(sockfd, (struct mmsghdr *)msgvec, vlen, flags);
#endif
}

/** PLATFORM: POSIX fallback — libc sendto. */
static inline long xlang_net_sendto(int sockfd, const void *buf, size_t len, int flags,
                                   const void *addr, unsigned int addrlen) {
  return (long)sendto(sockfd, buf, len, flags, (const struct sockaddr *)addr, (socklen_t)addrlen);
}

/** PLATFORM: POSIX fallback — libc recvfrom. */
static inline long xlang_net_recvfrom(int sockfd, void *buf, size_t len, int flags, void *addr,
                                     unsigned int *addrlen) {
  socklen_t al = addrlen ? (socklen_t)(*addrlen) : 0;
  long r = (long)recvfrom(sockfd, buf, len, flags, (struct sockaddr *)addr, addrlen ? &al : 0);
  if (addrlen)
    *addrlen = (unsigned int)al;
  return r;
}

/** PLATFORM: POSIX fallback — libc fcntl. */
static inline int xlang_net_fcntl(int fd, int cmd, long arg) {
  return fcntl(fd, cmd, arg);
}

#endif /* LINUX Cap vs POSIX fallback */

#endif /* !_WIN32 */

#endif /* XLANG_NET_CAP_H */
