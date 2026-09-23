/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
const char *xlang_entry_lib_name_from_path_impl(const char *input_path) {
    static char stem_buf[128];
    const char *base;
    const char *dot;
    size_t stem_len;

    if (!input_path)
        return "typeck";
    if (strstr(input_path, "main") != NULL)
        return "main";
    if (strstr(input_path, "build") != NULL)
        return "build";
    if (strstr(input_path, "pipeline") != NULL)
        return "pipeline";
    if (strstr(input_path, "driver") != NULL)
        return "driver";
    if (strstr(input_path, "codegen") != NULL)
        return "codegen";
    if (strstr(input_path, "typeck") != NULL)
        return "typeck";
    if (strstr(input_path, "parser") != NULL)
        return "parser";
    if (strstr(input_path, "token") != NULL)
        return "token";
    if (strstr(input_path, "lexer") != NULL)
        return "lexer";
    if (strstr(input_path, "ast") != NULL)
        return "ast";
    /* std/xxx/mod.x → lib_prefix std_xxx；std/xxx/yyy.x → std_xxx_yyy.
     * Why: codegen mangles import("std.heap.libc") → std_heap_libc_; -E lib_prefix
     * must match. Segments after std/ joined by _; skip trailing mod; strip .x/.su.
     * PLATFORM: SHARED — compile-time path only. */
    {
        const char *std_seg = NULL;
        for (const char *s = input_path; *s; s++) {
            if ((s == input_path || s[-1] == '/' || s[-1] == '\\')
                && strncmp(s, "std/", 4) == 0) {
                std_seg = s + 4;
                break;
            }
        }
        if (std_seg) {
            size_t off = 4;  /* "std_" prefix */
            memcpy(stem_buf, "std_", 4);
            const char *p = std_seg;
            while (*p && off + 2 < sizeof(stem_buf)) {
                const char *seg_start = p;
                while (*p && *p != '/' && *p != '\\') p++;
                size_t seg_len = (size_t)(p - seg_start);
                if (seg_len >= 3 && memcmp(seg_start + seg_len - 3, ".su", 3) == 0)
                    seg_len -= 3;
                else if (seg_len >= 2 && memcmp(seg_start + seg_len - 2, ".x", 2) == 0)
                    seg_len -= 2;
                if (seg_len == 3 && memcmp(seg_start, "mod", 3) == 0) {
                    /* skip mod segment */
                } else if (seg_len > 0) {
                    if (off > 4 && off + seg_len + 1 < sizeof(stem_buf)) {
                        stem_buf[off++] = '_';
                    }
                    if (off + seg_len < sizeof(stem_buf)) {
                        memcpy(stem_buf + off, seg_start, seg_len);
                        off += seg_len;
                    }
                }
                if (*p) p++;
            }
            if (off > 4) {
                stem_buf[off] = '\0';
                return stem_buf;
            }
        }
    }
    /* core/xxx — symmetric with std/ for core_* prefix mangle. PLATFORM: SHARED. */
    {
        const char *core_seg = NULL;
        for (const char *s = input_path; *s; s++) {
            if ((s == input_path || s[-1] == '/' || s[-1] == '\\')
                && strncmp(s, "core/", 5) == 0) {
                core_seg = s + 5;
                break;
            }
        }
        if (core_seg) {
            size_t off = 5;  /* "core_" prefix */
            memcpy(stem_buf, "core_", 5);
            const char *p = core_seg;
            while (*p && off + 2 < sizeof(stem_buf)) {
                const char *seg_start = p;
                while (*p && *p != '/' && *p != '\\') p++;
                size_t seg_len = (size_t)(p - seg_start);
                if (seg_len >= 3 && memcmp(seg_start + seg_len - 3, ".su", 3) == 0)
                    seg_len -= 3;
                else if (seg_len >= 2 && memcmp(seg_start + seg_len - 2, ".x", 2) == 0)
                    seg_len -= 2;
                if (seg_len == 3 && memcmp(seg_start, "mod", 3) == 0) {
                    /* skip mod */
                } else if (seg_len > 0) {
                    if (off > 5 && off + seg_len + 1 < sizeof(stem_buf)) {
                        stem_buf[off++] = '_';
                    }
                    if (off + seg_len < sizeof(stem_buf)) {
                        memcpy(stem_buf + off, seg_start, seg_len);
                        off += seg_len;
                    }
                }
                if (*p) p++;
            }
            if (off > 5) {
                stem_buf[off] = '\0';
                return stem_buf;
            }
        }
    }
    /* basename without .x/.su as lib prefix. */
    base = strrchr(input_path, '/');
    if (!base)
        base = strrchr(input_path, '\\');
    base = base ? base + 1 : input_path;
    dot = strrchr(base, '.');
    if (dot && dot > base && (strcmp(dot, ".x") == 0 || strcmp(dot, ".su") == 0)) {
        stem_len = (size_t)(dot - base);
        if (stem_len > 0 && stem_len < sizeof(stem_buf)) {
            memcpy(stem_buf, base, stem_len);
            stem_buf[stem_len] = '\0';
            return stem_buf;
        }
    }
    return "typeck";
}

const char *xlang_cstr_typeck_lit(void) {
    return "typeck";
}

/* G-02f-226 / wave75 cold twin: entry_lib keyword lits (0=main..9=ast; else typeck). */
const char *xlang_entry_lib_keyword_lit(int32_t k) {
    if (k == 0) return "main";
    if (k == 1) return "build";
    if (k == 2) return "pipeline";
    if (k == 3) return "driver";
    if (k == 4) return "codegen";
    if (k == 5) return "typeck";
    if (k == 6) return "parser";
    if (k == 7) return "token";
    if (k == 8) return "lexer";
    if (k == 9) return "ast";
    return "typeck";
}

/* G-02f-226 / wave75 cold twin: thin gate → pure-matched impl. */
const char *xlang_entry_lib_name_from_path(const char *input_path) {
  if (input_path == NULL) {
    return xlang_cstr_typeck_lit();
  }
  {
    return xlang_entry_lib_name_from_path_impl(input_path);
  }
  return NULL;
}
