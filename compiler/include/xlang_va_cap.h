/*
 * xlang_va_cap.h — Cap residual 10.7.1 slice0: va_list face without <stdarg.h>.
 *
 * G.7: single authority for Cap/reportf/vsnprintf consumers that must not
 * pull libc stdarg.h. Uses compiler builtins only (__builtin_va_*).
 *
 * Slice0: typedef + start/arg/end/copy macros (host-cc Cap face).
 * Slice7: language .x builtins rewrite to these macros (codegen Cap).
 * Residual: MSVC va_list layout. Asm Cap stack extras: slice17 (GP/FP ov).
 *
 * PLATFORM: SHARED — GCC/Clang builtins (Linux + Darwin + MinGW).
 *           MSVC va_list layout not covered in this slice.
 */

#ifndef XLANG_VA_CAP_H
#define XLANG_VA_CAP_H

/**
 * Cap va_list twin — compiler builtin storage (SysV / AAPCS / Win64 GNU).
 * PLATFORM: SHARED (GCC/Clang)
 */
typedef __builtin_va_list xlang_va_list;

/**
 * Cap va_start — initialize ap after named last parameter.
 * PLATFORM: SHARED
 */
#define xlang_va_start(ap, last) __builtin_va_start((ap), (last))

/**
 * Cap va_arg — fetch next argument of type.
 * PLATFORM: SHARED
 */
#define xlang_va_arg(ap, type) __builtin_va_arg((ap), type)

/**
 * Cap va_end — tear down ap.
 * PLATFORM: SHARED
 */
#define xlang_va_end(ap) __builtin_va_end((ap))

/**
 * Cap va_copy — duplicate ap into dst (caller must va_end both).
 * PLATFORM: SHARED
 */
#define xlang_va_copy(dst, src) __builtin_va_copy((dst), (src))

#endif /* XLANG_VA_CAP_H */
