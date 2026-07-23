/* poll.h — Windows MinGW compatibility shim for <poll.h>.
 * Why: MinGW does not provide <poll.h>. Generated C files (parser_gen.c,
 *      codegen_gen.c, typeck_gen.c, seeds/runtime_driver_abi_thin.from_x.c,
 *      seeds/fmt_check_cmd_thin.from_x.c, etc.) include <poll.h> for
 *      struct pollfd / nfds_t / poll() used by xlang_sys_poll inline helpers.
 *      Without this shim, Windows MSYS/MinGW compilation fails at
 *      `#include <poll.h>` with "No such file or directory".
 * On macOS/Linux the system <poll.h> is used via #include_next.
 * Invariant: xlang_sys_poll is a static inline helper that is currently
 *            defined but never invoked (verified via grep — no callers).
 *            poll() therefore returns -1 (ENOSYS) on Windows, letting
 *            callers surface a clean error rather than link-time failure.
 *            WSAPoll (winsock2.h) is intentionally NOT used: winsock2.h
 *            pulls in windows.h → winnt.h, whose TOKEN_TYPE enum conflicts
 *            with xlang's own TOKEN_TYPE (see win32_compat.h L27-29 note).
 *            A real select()-based emulation can be added in a later wave
 *            if Windows LSP/server code actually calls xlang_sys_poll.
 * PLATFORM: WINDOWS | MSYS | MINGW (provides struct pollfd/nfds_t/poll);
 *           POSIX (delegates to system header via #include_next). */
#ifndef XLANG_POLL_H
#define XLANG_POLL_H

#if defined(_WIN32) || defined(_WIN64)

#include <stddef.h>
#include <stdint.h>

/* nfds_t — POSIX type for the number of pollfd entries. */
typedef unsigned long nfds_t;

/* Event bit flags — POSIX POLL* constants. Values chosen to match
 * Linux/macOS so any code inspecting revents after a (stub) call sees
 * consistent bit layout with the POSIX platforms. */
#define POLLIN   0x0001  /* Readable data available. */
#define POLLPRI  0x0002  /* Priority data available. */
#define POLLOUT  0x0004  /* Writable. */
#define POLLERR  0x0008  /* Error condition. */
#define POLLHUP  0x0010  /* Hang up. */
#define POLLNVAL 0x0020  /* Invalid fd. */
#define POLLRDNORM 0x0040  /* Normal data readable. */
#define POLLRDBAND  0x0080  /* Priority band data readable. */
#define POLLWRNORM  0x0100  /* Normal data writable (== POLLOUT). */
#define POLLWRBAND  0x0200  /* Priority band data writable. */

/* struct pollfd — POSIX poll file descriptor descriptor. */
struct pollfd {
    int   fd;        /* File descriptor. */
    short events;    /* Requested events. */
    short revents;   /* Returned events. */
};

/* poll — POSIX I/O multiplexing; MinGW lacks it. Returns -1 (ENOSYS)
 *         because xlang_sys_poll is currently defined-but-unused on
 *         Windows. A real select()-based emulation belongs here if any
 *         Windows code path ever actually invokes xlang_sys_poll. */
static inline int poll(struct pollfd *fds, nfds_t nfds, int timeout) {
    (void)fds; (void)nfds; (void)timeout;
    return -1;
}

#else
/* macOS / Linux: delegate to the system <poll.h>. */
#include_next <poll.h>
#endif

#endif /* XLANG_POLL_H */
