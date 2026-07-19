/* unistd.h — Windows MinGW compatibility shim for <unistd.h>.
 * Why: MinGW <unistd.h> pulls in <io.h> which declares `int open(const char *,
 *      int, ...)` (deprecated POSIX alias of _open). This conflicts with
 *      SHUX-generated `extern int32_t open(uint8_t *, int32_t, int32_t)` in
 *      typeck_gen.c L84 / codegen_gen.c / parser_gen.c / seeds/<file>.from_x.c
 *      per C11 6.7.6.3p15 type incompatibility (uint8_t* vs const char*).
 *      Apple clang is lenient; MinGW gcc strictly aborts with
 *      "conflicting types for 'open'".
 *
 *      Earlier attempt used NO_OLDNAMES to suppress io.h's deprecated alias
 *      block, but that also removed off_t / unlink / rmdir / read / write /
 *      close / lseek declarations, breaking SHUX code that uses those.
 *
 *      The current fix: pull in MinGW <unistd.h> unchanged (keeping all
 *      deprecated aliases for read/write/close/lseek/unlink/rmdir/off_t),
 *      then macro-redirect SHUX's `open` identifier to `shux_posix_open`
 *      (a static inline wrapper calling MinGW `_open` with the SHUX-expected
 *      signature). The macro rewrites SHUX's L84 `extern int32_t open(...)`
 *      declaration too, turning it into an extern declaration for
 *      shux_posix_open — which is satisfied by the prior static inline
 *      definition (C99 6.2.2p4: prior internal linkage wins).
 *
 *      pread / pwrite (which MinGW lacks entirely) are emulated via
 *      _lseek + _read / _write.
 *
 * On macOS/Linux the system <unistd.h> (which already declares pread/pwrite
 * and does NOT declare `open` — POSIX puts `open` in <fcntl.h>) is used via
 * #include_next, so this shim is a no-op there.
 *
 * Invariant: pread/pwrite are non-atomic (save cur → seek → I/O →
 *            restore cur). For SHUX, shux_sys_pread/pwrite helpers are
 *            currently defined-but-unused static inline helpers (verified
 *            via grep), so non-atomicity is acceptable.
 * PLATFORM: WINDOWS | MSYS | MINGW (provides open macro + pread/pwrite);
 *           POSIX (delegates to system header via #include_next). */
#ifndef SHUX_UNISTD_H
#define SHUX_UNISTD_H

#if defined(_WIN32) || defined(_WIN64)

/* Pull in MinGW's own <unistd.h> unchanged — declares read/write/close/
 * lseek/unlink/rmdir/access and pulls in <io.h> (for _open/_read/etc.)
 * and <sys/types.h> (for off_t / ssize_t). This includes the deprecated
 * `open(const char *, int, ...)` alias that conflicts with SHUX's L84
 * extern declaration, but we redirect SHUX's `open` token to a wrapper
 * below before any SHUX code references `open`. */
#include_next <unistd.h>

/* ssize_t / off_t fallbacks — MinGW <unistd.h> should provide these via
 * <sys/types.h>, but guard for safety. */
#ifndef _SSIZE_T_DEFINED
#define _SSIZE_T_DEFINED
typedef intptr_t ssize_t;
#endif

#ifndef _OFF_T_DEFINED
#define _OFF_T_DEFINED
typedef long off_t;
#endif

#include <io.h>  /* _read / _write / _close / _lseek / _open */

/* shux_posix_open — SHUX-expected signature wrapper for MinGW _open.
 * Why: SHUX-generated code declares `extern int32_t open(uint8_t *,
 *      int32_t, int32_t)` (typeck_gen.c L84 et al.) and calls `open(path,
 *      flags, mode)` from fs_libc_open. The macro `#define open
 *      shux_posix_open` below redirects both the extern declaration and
 *      the call site to this wrapper, which calls MinGW `_open` (standard
 *      _-prefixed function, no signature conflict). */
static inline int32_t shux_posix_open(uint8_t *path, int32_t flags, int32_t mode) {
    return (int32_t)_open((const char *)path, (int)flags, (int)mode);
}

/* Redirect SHUX's `open` identifier to shux_posix_open.
 * Textual macro replacement applies to:
 *   - SHUX's L84 `extern int32_t open(uint8_t *, int32_t, int32_t);` →
 *     `extern int32_t shux_posix_open(uint8_t *, int32_t, int32_t);`
 *     (satisfied by the static inline above; C99 6.2.2p4 prior internal
 *     linkage wins, so no extern/static conflict).
 *   - SHUX's L85 `return open(path, flags, mode);` → calls shux_posix_open.
 * Does NOT affect MinGW io.h's `int open(const char *, int, ...)` alias
 * (already declared before this macro is defined). */
#define open shux_posix_open

/* pread — POSIX positional read; MinGW lacks it entirely.
 *         Non-atomic emulation: save cur → seek → read → restore cur.
 *         Returns bytes read, or -1 on error. */
static inline ssize_t pread(int fd, void *buf, size_t count, off_t offset) {
    off_t cur = _lseek(fd, 0, SEEK_CUR);
    if (cur < 0) return -1;
    if (_lseek(fd, offset, SEEK_SET) < 0) return -1;
    ssize_t n = (ssize_t)_read(fd, buf, (unsigned int)count);
    off_t restore = _lseek(fd, cur, SEEK_SET);
    (void)restore;  /* Best-effort restore; if it fails, fd offset is lost. */
    return n;
}

/* pwrite — POSIX positional write; MinGW lacks it entirely.
 *          Non-atomic emulation: save cur → seek → write → restore cur. */
static inline ssize_t pwrite(int fd, const void *buf, size_t count, off_t offset) {
    off_t cur = _lseek(fd, 0, SEEK_CUR);
    if (cur < 0) return -1;
    if (_lseek(fd, offset, SEEK_SET) < 0) return -1;
    ssize_t n = (ssize_t)_write(fd, buf, (unsigned int)count);
    off_t restore = _lseek(fd, cur, SEEK_SET);
    (void)restore;
    return n;
}

/* setenv — POSIX set environment variable; MinGW lacks it (has _putenv_s).
 *           Returns 0 on success, -1 on error (POSIX semantics).
 *           `overwrite == 0` and existing variable → no-op success.
 * Why: driver_gen.c:559 calls setenv("SHUX_RUN_QUIET", "1", 1) (generated
 *      from src/driver.x main_cmd_run). MinGW stdlib.h declares _putenv_s
 *      but not setenv, causing implicit-declaration errors. */
static inline int setenv(const char *name, const char *value, int overwrite) {
    if (!overwrite && getenv(name) != NULL) return 0;
    return _putenv_s(name, value) == 0 ? 0 : -1;
}

/* unsetenv — POSIX unset environment variable; MinGW lacks it (has _putenv_s).
 *             Returns 0 on success, -1 on error (POSIX semantics).
 *             POSIX requires unsetenv to remove the variable entirely; MinGW
 *             _putenv_s(name, "") sets it to empty string (different but
 *             close enough for SHUX usage which only checks getenv != NULL). */
static inline int unsetenv(const char *name) {
    return _putenv_s(name, "") == 0 ? 0 : -1;
}

#else
/* macOS / Linux: delegate to the system <unistd.h>. */
#include_next <unistd.h>
#endif

#endif /* SHUX_UNISTD_H */
