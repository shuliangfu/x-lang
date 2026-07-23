/* sys/uio.h — Windows MinGW compatibility shim for <sys/uio.h>.
 * Why: MinGW does not provide <sys/uio.h>. Generated C files (parser_gen.c,
 *      codegen_gen.c, typeck_gen.c, seeds/runtime_driver_abi_thin.from_x.c,
 *      seeds/fmt_check_cmd_thin.from_x.c, etc.) include <sys/uio.h> for
 *      struct iovec / readv / writev used by xlang_sys_readv / xlang_sys_writev
 *      inline helpers. Without this shim, Windows MSYS/MinGW compilation
 *      fails at `#include <sys/uio.h>` with "No such file or directory".
 * On macOS/Linux the system <sys/uio.h> is used via #include_next.
 * Invariant: readv/writev on Windows loop over iovec entries calling
 *            _read/_write (MinGW <io.h>), matching POSIX semantics for
 *            short reads/writes (return on first partial I/O).
 * PLATFORM: WINDOWS | MSYS | MINGW (provides struct iovec/readv/writev);
 *           POSIX (delegates to system header via #include_next). */
#ifndef XLANG_SYS_UIO_H
#define XLANG_SYS_UIO_H

#if defined(_WIN32) || defined(_WIN64)

#include <stddef.h>
#include <stdint.h>
#include <io.h>

/* ssize_t — MinGW may not define it via <io.h> in all configurations. */
#ifndef _SSIZE_T_DEFINED
#define _SSIZE_T_DEFINED
typedef intptr_t ssize_t;
#endif

/* struct iovec — POSIX scatter/gather I/O vector. */
struct iovec {
    void  *iov_base;  /* Starting address. */
    size_t iov_len;   /* Number of bytes to transfer. */
};

/* readv — POSIX scatter read; MinGW lacks it. Loops over iovec entries
 *         calling _read (MinGW <io.h>), stopping on first short read. */
static inline ssize_t readv(int fd, const struct iovec *iov, int iovcnt) {
    ssize_t total = 0;
    int i;
    for (i = 0; i < iovcnt; i++) {
        ssize_t n = (ssize_t)_read(fd, iov[i].iov_base, (unsigned int)iov[i].iov_len);
        if (n < 0) return -1;
        total += n;
        if ((size_t)n < iov[i].iov_len) break;  /* short read */
    }
    return total;
}

/* writev — POSIX scatter write; MinGW lacks it. Loops over iovec entries
 *          calling _write (MinGW <io.h>), stopping on first short write. */
static inline ssize_t writev(int fd, const struct iovec *iov, int iovcnt) {
    ssize_t total = 0;
    int i;
    for (i = 0; i < iovcnt; i++) {
        ssize_t n = (ssize_t)_write(fd, iov[i].iov_base, (unsigned int)iov[i].iov_len);
        if (n < 0) return -1;
        total += n;
        if ((size_t)n < iov[i].iov_len) break;  /* short write */
    }
    return total;
}

#else
/* macOS / Linux: delegate to the system <sys/uio.h>. */
#include_next <sys/uio.h>
#endif

#endif /* XLANG_SYS_UIO_H */
