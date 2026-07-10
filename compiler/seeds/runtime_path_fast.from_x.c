/* seeds/runtime_path_fast.from_x.c — G-02f-21 product TU
 * Logic still C until full .x port.
 */
#include <stdint.h>

static uint8_t path_sep_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return (uint8_t)92;
#else
    return (uint8_t)47;
#endif
}

static int32_t path_is_sep_c(uint8_t c) {
    if (c == (uint8_t)47)
        return 1;
    if (c == (uint8_t)92)
        return 1;
    return 0;
}

static int32_t path_last_sep_c(uint8_t *path, int32_t path_len) {
    int32_t i;
    for (i = path_len - 1; i >= 0; i--) {
        if (path_is_sep_c(path[i]) != 0)
            return i;
    }
    return -1;
}

static int32_t path_last_dot_c(uint8_t *path, int32_t start, int32_t len) {
    int32_t i;
    for (i = start + len - 1; i >= start; i--) {
        if (path[i] == (uint8_t)46)
            return i - start;
    }
    return -1;
}

int32_t std_path_empty_len(void) { return 0; }

uint8_t std_path_sep(void) { return path_sep_c(); }

int32_t std_path_join(uint8_t *out, int32_t out_max, uint8_t *a, int32_t a_len, uint8_t *b, int32_t b_len) {
    int32_t need_sep = 0;
    int32_t total;
    int32_t k;
    int32_t i;
    if (a_len > 0 && path_is_sep_c(a[a_len - 1]) == 0)
        need_sep = 1;
    total = a_len + need_sep + b_len;
    if (total <= 0)
        return 0;
    if (total > out_max)
        return -1;
    k = 0;
    for (i = 0; i < a_len; i++)
        out[k++] = a[i];
    if (need_sep != 0)
        out[k++] = path_sep_c();
    for (i = 0; i < b_len; i++)
        out[k++] = b[i];
    return k;
}

int32_t std_path_dirname(uint8_t *path, int32_t path_len, uint8_t *out, int32_t out_max) {
    int32_t last = path_last_sep_c(path, path_len);
    int32_t i;
    if (last <= 0)
        return 0;
    if (last > out_max)
        return -1;
    for (i = 0; i < last && i < out_max; i++)
        out[i] = path[i];
    return i;
}

int32_t std_path_basename(uint8_t *path, int32_t path_len, uint8_t *out, int32_t out_max) {
    int32_t last = path_last_sep_c(path, path_len);
    int32_t start = last + 1;
    int32_t seg_len = path_len - start;
    int32_t i;
    if (seg_len <= 0)
        return 0;
    if (seg_len > out_max)
        return -1;
    for (i = 0; i < seg_len; i++)
        out[i] = path[start + i];
    return i;
}

int32_t std_path_is_absolute(uint8_t *path, int32_t path_len) {
    uint8_t c0;
    if (path_len <= 0)
        return 0;
    if (path[0] == (uint8_t)47)
        return 1;
    if (path_len >= 2 && path[0] == (uint8_t)92 && path[1] == (uint8_t)92)
        return 1;
    if (path_len >= 3 && path[1] == (uint8_t)58) {
        c0 = path[0];
        if (((c0 >= (uint8_t)65) && (c0 <= (uint8_t)90)) || ((c0 >= (uint8_t)97) && (c0 <= (uint8_t)122))) {
            if (path[2] == (uint8_t)92 || path[2] == (uint8_t)47)
                return 1;
        }
    }
    return 0;
}

int32_t std_path_is_sep(uint8_t c) { return path_is_sep_c(c); }

int32_t std_path_extension(uint8_t *path, int32_t path_len, uint8_t *out, int32_t out_max) {
    int32_t last_sl = path_last_sep_c(path, path_len);
    int32_t base_start = last_sl + 1;
    int32_t base_len = path_len - base_start;
    int32_t dot_rel;
    int32_t ext_len;
    int32_t i;
    if (base_len <= 0)
        return 0;
    dot_rel = path_last_dot_c(path, base_start, base_len);
    if (dot_rel < 0 || dot_rel == 0 || dot_rel >= base_len - 1)
        return 0;
    ext_len = base_len - dot_rel;
    if (ext_len > out_max)
        return -1;
    for (i = 0; i < ext_len; i++)
        out[i] = path[base_start + dot_rel + i];
    return i;
}

int32_t std_path_stem(uint8_t *path, int32_t path_len, uint8_t *out, int32_t out_max) {
    int32_t last_sl = path_last_sep_c(path, path_len);
    int32_t base_start = last_sl + 1;
    int32_t base_len = path_len - base_start;
    int32_t dot_rel;
    int32_t stem_len;
    int32_t i;
    if (base_len <= 0)
        return 0;
    dot_rel = path_last_dot_c(path, base_start, base_len);
    stem_len = base_len;
    if (dot_rel >= 0 && dot_rel > 0 && dot_rel < base_len - 1)
        stem_len = dot_rel;
    if (stem_len > out_max)
        return -1;
    for (i = 0; i < stem_len; i++)
        out[i] = path[base_start + i];
    return i;
}

int32_t std_path_extension_and_stem(uint8_t *path, int32_t path_len, uint8_t *ext_out, int32_t ext_max,
                                    uint8_t *stem_out, int32_t stem_max) {
    int32_t last_sl = path_last_sep_c(path, path_len);
    int32_t base_start = last_sl + 1;
    int32_t base_len = path_len - base_start;
    int32_t dot_rel;
    int32_t stem_len;
    int32_t ext_len;
    int32_t i;
    if (base_len <= 0)
        return 0;
    dot_rel = path_last_dot_c(path, base_start, base_len);
    stem_len = base_len;
    ext_len = 0;
    if (dot_rel >= 0 && dot_rel > 0 && dot_rel < base_len - 1) {
        stem_len = dot_rel;
        ext_len = base_len - dot_rel;
    }
    if (stem_len > stem_max || ext_len > ext_max)
        return -1;
    for (i = 0; i < stem_len; i++)
        stem_out[i] = path[base_start + i];
    for (i = 0; i < ext_len; i++)
        ext_out[i] = path[base_start + dot_rel + i];
    return (stem_len << 16) | (ext_len & 65535);
}

int32_t std_path_clean(uint8_t *path, int32_t path_len, uint8_t *out, int32_t out_max) {
    int32_t seg_starts[64] = {0};
    int32_t nseg = 0;
    int32_t out_len = 0;
    int32_t i = 0;
    int32_t started_with_sep = 0;
    int32_t emit_double_sep_next = 0;
    uint8_t main_sep = path_sep_c();
    if (path_len <= 0 || out_max <= 0)
        return 0;
    if (path_is_sep_c(path[0]) != 0) {
        started_with_sep = 1;
        out[0] = main_sep;
        out_len = 1;
        while (i < path_len && path_is_sep_c(path[i]) != 0)
            i++;
    }
    while (i < path_len) {
        int32_t seg_begin;
        int32_t seg_len;
        int32_t k;
        while (i < path_len && path_is_sep_c(path[i]) != 0)
            i++;
        if (i >= path_len)
            break;
        seg_begin = i;
        while (i < path_len && path_is_sep_c(path[i]) == 0)
            i++;
        seg_len = i - seg_begin;
        if (seg_len == 1 && path[seg_begin] == (uint8_t)46)
            continue;
        if (seg_len == 2 && path[seg_begin] == (uint8_t)46 && path[seg_begin + 1] == (uint8_t)46) {
            if (nseg > 0) {
                out_len = seg_starts[nseg - 1];
                nseg--;
                if (started_with_sep == 0 && out_len > 0)
                    emit_double_sep_next = 1;
            }
            continue;
        }
        if (out_len > 0) {
            if (out[out_len - 1] != main_sep) {
                if (out_len >= out_max)
                    return -1;
                out[out_len++] = main_sep;
            } else if (emit_double_sep_next != 0) {
                if (out_len >= out_max)
                    return -1;
                out[out_len++] = main_sep;
            }
        }
        emit_double_sep_next = 0;
        if (nseg < 63) {
            seg_starts[nseg] = out_len;
            nseg++;
        }
        for (k = 0; k < seg_len; k++) {
            if (out_len >= out_max)
                return -1;
            out[out_len++] = path[seg_begin + k];
        }
    }
    if (out_len > 1 && out[out_len - 1] == main_sep)
        out_len--;
    return out_len;
}

int32_t std_path_resolve(uint8_t *out, int32_t out_max, uint8_t *base, int32_t base_len, uint8_t *ref, int32_t ref_len) {
    uint8_t dir_buf[256];
    uint8_t tmp[512];
    int32_t dir_len;
    int32_t jlen;
    if (ref_len > 0 && std_path_is_absolute(ref, ref_len) != 0)
        return std_path_clean(ref, ref_len, out, out_max);
    dir_len = std_path_dirname(base, base_len, &dir_buf[0], 256);
    jlen = std_path_join(&tmp[0], 512, &dir_buf[0], dir_len, ref, ref_len);
    if (jlen < 0)
        return -1;
    return std_path_clean(&tmp[0], jlen, out, out_max);
}
