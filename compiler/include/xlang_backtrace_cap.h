/*
 * xlang_backtrace_cap.h — Cap residual 9.1.11: stack capture without libc backtrace()
 * on Linux (x86_64 + aarch64).
 *
 * Frame-pointer walk via __builtin_frame_address; requires compilable frame pointers
 * (-fno-omit-frame-pointer on optimized builds for deep stacks).
 *
 * Symbol resolution (dladdr) remains POSIX fallback until slice1.
 *
 * PLATFORM: LINUX primary; other platforms use execinfo backtrace() at call sites.
 */

#ifndef XLANG_BACKTRACE_CAP_H
#define XLANG_BACKTRACE_CAP_H

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

#include <stddef.h>
#include <stdint.h>

/**
 * Capture return addresses by walking the frame-pointer chain.
 * Mirrors glibc backtrace() layout: array[i] = return IP of frame i above caller.
 *
 * @param array output pointer array (void*)
 * @param size  max entries
 * @return number of frames written (0 on failure)
 * PLATFORM: LINUX
 */
static inline int xlang_bt_backtrace(void **array, int size) {
  void **bp;
  int n = 0;
  if (!array || size <= 0)
    return 0;
  bp = (void **)(uintptr_t)__builtin_frame_address(0);
  while (n < size && bp != NULL) {
    void **next_bp;
    void *ret_addr;
    /* Guard: frame pointer must be aligned and above current on downward stack. */
    if (((uintptr_t)bp & (sizeof(void *) - 1)) != 0)
      break;
    next_bp = (void **)*bp;
    ret_addr = *(bp + 1);
    if (ret_addr == NULL)
      break;
    array[n++] = ret_addr;
    if (next_bp == NULL || next_bp <= bp)
      break;
    bp = next_bp;
  }
  return n;
}

#endif /* LINUX Cap */

#endif /* XLANG_BACKTRACE_CAP_H */
