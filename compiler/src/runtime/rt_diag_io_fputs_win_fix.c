/* Win tip-cold: tip diag_io_fputs miscompiles / SEGV. Strong leaf first-wins.
 * Opaque stream `o` is tip/thin fd+1 (diag_stderr → 3 for fd 2), NOT a FILE*.
 * Prior leaf treated o as FILE* so fputs(…, (FILE*)0x3) SEGV in msvcrt.
 * Decode fd+1 and write(2); keep cstr readability guard. PLATFORM: WINDOWS. */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#ifdef _WIN32
#include <io.h>
#include <windows.h>
#else
#include <unistd.h>
#endif

static int win_readable_cstr(const char *s) {
  MEMORY_BASIC_INFORMATION mbi;
  const char *p;
  if (!s)
    return 0;
  if ((uintptr_t)s < 0x10000ull)
    return 0;
  p = s;
  for (size_t n = 0; n < 1048576u; n++) {
    if ((n % 4096u) == 0) {
      if (VirtualQuery(p, &mbi, sizeof mbi) == 0)
        return 0;
      if (mbi.State != MEM_COMMIT)
        return 0;
      if (!(mbi.Protect & (PAGE_READONLY | PAGE_READWRITE | PAGE_EXECUTE_READ |
                           PAGE_EXECUTE_READWRITE | PAGE_WRITECOPY |
                           PAGE_EXECUTE_WRITECOPY)))
        return 0;
      if (mbi.Protect & (PAGE_NOACCESS | PAGE_GUARD))
        return 0;
    }
    if (*p == 0)
      return 1;
    p++;
  }
  return 0;
}

static int win_diag_fd(uint8_t *o) {
  uintptr_t bits;
  int fd;
  if (!o)
    return -1;
  bits = (uintptr_t)o;
  /* Tip/thin: stderr=3, stdout=2, stdin=1 (fd + 1). */
  if (bits < 0x10000ull) {
    fd = (int)bits - 1;
    return fd >= 0 ? fd : -1;
  }
  /* Unexpected real pointer — map common std FILE* to fd. */
  if ((FILE *)o == stderr)
    return 2;
  if ((FILE *)o == stdout)
    return 1;
  if ((FILE *)o == stdin)
    return 0;
  return -1;
}

int diag_io_fputs(const char *s, uint8_t *o) {
  int fd;
  size_t n;
  int w;
  if (!s)
    s = "";
  if (!win_readable_cstr(s))
    return EOF;
  fd = win_diag_fd(o);
  if (fd < 0)
    return EOF;
  n = strlen(s);
  if (n == 0)
    return 0;
  if (n > 0x7fffffffu)
    n = 0x7fffffffu;
#ifdef _WIN32
  w = _write(fd, s, (unsigned int)n);
#else
  w = (int)write(fd, s, n);
#endif
  return (w == (int)n) ? 0 : EOF;
}
