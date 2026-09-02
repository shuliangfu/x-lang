/* sys/wait.h — Windows MinGW compatibility shim for <sys/wait.h>.
 * Why: MinGW does not provide <sys/wait.h>. Cold seeds
 *      (rt_run_exec.from_x.c, rt_dispatch_thin.from_x.c,
 *      runtime_link_abi.from_x.c, runtime_driver_abi.from_x.c,
 *      fmt_check_cmd.from_x.c, runtime_process_os_glue.from_x.c, …)
 *      include it for waitpid / WIFEXITED / WNOHANG. Without this shim,
 *      rt-prefer of src/runtime_driver_no_c.o dies with
 *      "sys/wait.h: No such file or directory" and the 52-leaf min-gate
 *      refuses the incomplete multi-slice (monofile last-resort is retired).
 *
 * Authority: waitpid / WIF* live in win32_compat.h (G.7; do not duplicate
 *            the stub bodies here). This file is the include-path shim so
 *            `#include <sys/wait.h>` resolves under -Iinclude.
 * On macOS/Linux the system <sys/wait.h> is used via #include_next.
 *
 * PLATFORM: WINDOWS | MSYS | MINGW (shim → win32_compat waitpid);
 *           POSIX (delegates to system header via #include_next). */
#ifndef XLANG_SYS_WAIT_H
#define XLANG_SYS_WAIT_H

#if defined(_WIN32) || defined(_WIN64)

#include <win32_compat.h>

#else
/* macOS / Linux: delegate to the system <sys/wait.h>. */
#include_next <sys/wait.h>
#endif

#endif /* XLANG_SYS_WAIT_H */
