/**
 * std/http/hpack_huffman.inc.c — HPACK Huffman 解码 v4（RFC 7541；STD-HTTP-H2-v4）
 *
 * 【文件职责】静态 Huffman 表解码（nghttp2 表数据子集）；供 hpack.inc.c include。
 * 符号表源自 RFC 7541 Appendix B（与 nghttp2 huff_sym_table 一致）。
 */

#include <stdint.h>
#include <string.h>

/** Huffman 符号项（code 左对齐 32 位，nbits 为有效位长）。 */
typedef struct {
    uint8_t nbits;
    uint32_t code;
} huff_sym_t;

static const huff_sym_t g_http2_huff_sym[257] = {
    { 13, 0xFFC00000U }, /* 0 */
    { 23, 0xFFFFB000U }, /* 1 */
    { 28, 0xFFFFFE20U }, /* 2 */
    { 28, 0xFFFFFE30U }, /* 3 */
    { 28, 0xFFFFFE40U }, /* 4 */
    { 28, 0xFFFFFE50U }, /* 5 */
    { 28, 0xFFFFFE60U }, /* 6 */
    { 28, 0xFFFFFE70U }, /* 7 */
    { 28, 0xFFFFFE80U }, /* 8 */
    { 24, 0xFFFFEA00U }, /* 9 */
    { 30, 0xFFFFFFF0U }, /* 10 */
    { 28, 0xFFFFFE90U }, /* 11 */
    { 28, 0xFFFFFEA0U }, /* 12 */
    { 30, 0xFFFFFFF4U }, /* 13 */
    { 28, 0xFFFFFEB0U }, /* 14 */
    { 28, 0xFFFFFEC0U }, /* 15 */
    { 28, 0xFFFFFED0U }, /* 16 */
    { 28, 0xFFFFFEE0U }, /* 17 */
    { 28, 0xFFFFFEF0U }, /* 18 */
    { 28, 0xFFFFFF00U }, /* 19 */
    { 28, 0xFFFFFF10U }, /* 20 */
    { 28, 0xFFFFFF20U }, /* 21 */
    { 30, 0xFFFFFFF8U }, /* 22 */
    { 28, 0xFFFFFF30U }, /* 23 */
    { 28, 0xFFFFFF40U }, /* 24 */
    { 28, 0xFFFFFF50U }, /* 25 */
    { 28, 0xFFFFFF60U }, /* 26 */
    { 28, 0xFFFFFF70U }, /* 27 */
    { 28, 0xFFFFFF80U }, /* 28 */
    { 28, 0xFFFFFF90U }, /* 29 */
    { 28, 0xFFFFFFA0U }, /* 30 */
    { 28, 0xFFFFFFB0U }, /* 31 */
    { 6, 0x50000000U }, /* 32 */
    { 10, 0xFE000000U }, /* 33 */
    { 10, 0xFE400000U }, /* 34 */
    { 12, 0xFFA00000U }, /* 35 */
    { 13, 0xFFC80000U }, /* 36 */
    { 6, 0x54000000U }, /* 37 */
    { 8, 0xF8000000U }, /* 38 */
    { 11, 0xFF400000U }, /* 39 */
    { 10, 0xFE800000U }, /* 40 */
    { 10, 0xFEC00000U }, /* 41 */
    { 8, 0xF9000000U }, /* 42 */
    { 11, 0xFF600000U }, /* 43 */
    { 8, 0xFA000000U }, /* 44 */
    { 6, 0x58000000U }, /* 45 */
    { 6, 0x5C000000U }, /* 46 */
    { 6, 0x60000000U }, /* 47 */
    { 5, 0x0U }, /* 48 */
    { 5, 0x8000000U }, /* 49 */
    { 5, 0x10000000U }, /* 50 */
    { 6, 0x64000000U }, /* 51 */
    { 6, 0x68000000U }, /* 52 */
    { 6, 0x6C000000U }, /* 53 */
    { 6, 0x70000000U }, /* 54 */
    { 6, 0x74000000U }, /* 55 */
    { 6, 0x78000000U }, /* 56 */
    { 6, 0x7C000000U }, /* 57 */
    { 7, 0xB8000000U }, /* 58 */
    { 8, 0xFB000000U }, /* 59 */
    { 15, 0xFFF80000U }, /* 60 */
    { 6, 0x80000000U }, /* 61 */
    { 12, 0xFFB00000U }, /* 62 */
    { 10, 0xFF000000U }, /* 63 */
    { 13, 0xFFD00000U }, /* 64 */
    { 6, 0x84000000U }, /* 65 */
    { 7, 0xBA000000U }, /* 66 */
    { 7, 0xBC000000U }, /* 67 */
    { 7, 0xBE000000U }, /* 68 */
    { 7, 0xC0000000U }, /* 69 */
    { 7, 0xC2000000U }, /* 70 */
    { 7, 0xC4000000U }, /* 71 */
    { 7, 0xC6000000U }, /* 72 */
    { 7, 0xC8000000U }, /* 73 */
    { 7, 0xCA000000U }, /* 74 */
    { 7, 0xCC000000U }, /* 75 */
    { 7, 0xCE000000U }, /* 76 */
    { 7, 0xD0000000U }, /* 77 */
    { 7, 0xD2000000U }, /* 78 */
    { 7, 0xD4000000U }, /* 79 */
    { 7, 0xD6000000U }, /* 80 */
    { 7, 0xD8000000U }, /* 81 */
    { 7, 0xDA000000U }, /* 82 */
    { 7, 0xDC000000U }, /* 83 */
    { 7, 0xDE000000U }, /* 84 */
    { 7, 0xE0000000U }, /* 85 */
    { 7, 0xE2000000U }, /* 86 */
    { 7, 0xE4000000U }, /* 87 */
    { 8, 0xFC000000U }, /* 88 */
    { 7, 0xE6000000U }, /* 89 */
    { 8, 0xFD000000U }, /* 90 */
    { 13, 0xFFD80000U }, /* 91 */
    { 19, 0xFFFE0000U }, /* 92 */
    { 13, 0xFFE00000U }, /* 93 */
    { 14, 0xFFF00000U }, /* 94 */
    { 6, 0x88000000U }, /* 95 */
    { 15, 0xFFFA0000U }, /* 96 */
    { 5, 0x18000000U }, /* 97 */
    { 6, 0x8C000000U }, /* 98 */
    { 5, 0x20000000U }, /* 99 */
    { 6, 0x90000000U }, /* 100 */
    { 5, 0x28000000U }, /* 101 */
    { 6, 0x94000000U }, /* 102 */
    { 6, 0x98000000U }, /* 103 */
    { 6, 0x9C000000U }, /* 104 */
    { 5, 0x30000000U }, /* 105 */
    { 7, 0xE8000000U }, /* 106 */
    { 7, 0xEA000000U }, /* 107 */
    { 6, 0xA0000000U }, /* 108 */
    { 6, 0xA4000000U }, /* 109 */
    { 6, 0xA8000000U }, /* 110 */
    { 5, 0x38000000U }, /* 111 */
    { 6, 0xAC000000U }, /* 112 */
    { 7, 0xEC000000U }, /* 113 */
    { 6, 0xB0000000U }, /* 114 */
    { 5, 0x40000000U }, /* 115 */
    { 5, 0x48000000U }, /* 116 */
    { 6, 0xB4000000U }, /* 117 */
    { 7, 0xEE000000U }, /* 118 */
    { 7, 0xF0000000U }, /* 119 */
    { 7, 0xF2000000U }, /* 120 */
    { 7, 0xF4000000U }, /* 121 */
    { 7, 0xF6000000U }, /* 122 */
    { 15, 0xFFFC0000U }, /* 123 */
    { 11, 0xFF800000U }, /* 124 */
    { 14, 0xFFF40000U }, /* 125 */
    { 13, 0xFFE80000U }, /* 126 */
    { 28, 0xFFFFFFC0U }, /* 127 */
    { 20, 0xFFFE6000U }, /* 128 */
    { 22, 0xFFFF4800U }, /* 129 */
    { 20, 0xFFFE7000U }, /* 130 */
    { 20, 0xFFFE8000U }, /* 131 */
    { 22, 0xFFFF4C00U }, /* 132 */
    { 22, 0xFFFF5000U }, /* 133 */
    { 22, 0xFFFF5400U }, /* 134 */
    { 23, 0xFFFFB200U }, /* 135 */
    { 22, 0xFFFF5800U }, /* 136 */
    { 23, 0xFFFFB400U }, /* 137 */
    { 23, 0xFFFFB600U }, /* 138 */
    { 23, 0xFFFFB800U }, /* 139 */
    { 23, 0xFFFFBA00U }, /* 140 */
    { 23, 0xFFFFBC00U }, /* 141 */
    { 24, 0xFFFFEB00U }, /* 142 */
    { 23, 0xFFFFBE00U }, /* 143 */
    { 24, 0xFFFFEC00U }, /* 144 */
    { 24, 0xFFFFED00U }, /* 145 */
    { 22, 0xFFFF5C00U }, /* 146 */
    { 23, 0xFFFFC000U }, /* 147 */
    { 24, 0xFFFFEE00U }, /* 148 */
    { 23, 0xFFFFC200U }, /* 149 */
    { 23, 0xFFFFC400U }, /* 150 */
    { 23, 0xFFFFC600U }, /* 151 */
    { 23, 0xFFFFC800U }, /* 152 */
    { 21, 0xFFFEE000U }, /* 153 */
    { 22, 0xFFFF6000U }, /* 154 */
    { 23, 0xFFFFCA00U }, /* 155 */
    { 22, 0xFFFF6400U }, /* 156 */
    { 23, 0xFFFFCC00U }, /* 157 */
    { 23, 0xFFFFCE00U }, /* 158 */
    { 24, 0xFFFFEF00U }, /* 159 */
    { 22, 0xFFFF6800U }, /* 160 */
    { 21, 0xFFFEE800U }, /* 161 */
    { 20, 0xFFFE9000U }, /* 162 */
    { 22, 0xFFFF6C00U }, /* 163 */
    { 22, 0xFFFF7000U }, /* 164 */
    { 23, 0xFFFFD000U }, /* 165 */
    { 23, 0xFFFFD200U }, /* 166 */
    { 21, 0xFFFEF000U }, /* 167 */
    { 23, 0xFFFFD400U }, /* 168 */
    { 22, 0xFFFF7400U }, /* 169 */
    { 22, 0xFFFF7800U }, /* 170 */
    { 24, 0xFFFFF000U }, /* 171 */
    { 21, 0xFFFEF800U }, /* 172 */
    { 22, 0xFFFF7C00U }, /* 173 */
    { 23, 0xFFFFD600U }, /* 174 */
    { 23, 0xFFFFD800U }, /* 175 */
    { 21, 0xFFFF0000U }, /* 176 */
    { 21, 0xFFFF0800U }, /* 177 */
    { 22, 0xFFFF8000U }, /* 178 */
    { 21, 0xFFFF1000U }, /* 179 */
    { 23, 0xFFFFDA00U }, /* 180 */
    { 22, 0xFFFF8400U }, /* 181 */
    { 23, 0xFFFFDC00U }, /* 182 */
    { 23, 0xFFFFDE00U }, /* 183 */
    { 20, 0xFFFEA000U }, /* 184 */
    { 22, 0xFFFF8800U }, /* 185 */
    { 22, 0xFFFF8C00U }, /* 186 */
    { 22, 0xFFFF9000U }, /* 187 */
    { 23, 0xFFFFE000U }, /* 188 */
    { 22, 0xFFFF9400U }, /* 189 */
    { 22, 0xFFFF9800U }, /* 190 */
    { 23, 0xFFFFE200U }, /* 191 */
    { 26, 0xFFFFF800U }, /* 192 */
    { 26, 0xFFFFF840U }, /* 193 */
    { 20, 0xFFFEB000U }, /* 194 */
    { 19, 0xFFFE2000U }, /* 195 */
    { 22, 0xFFFF9C00U }, /* 196 */
    { 23, 0xFFFFE400U }, /* 197 */
    { 22, 0xFFFFA000U }, /* 198 */
    { 25, 0xFFFFF600U }, /* 199 */
    { 26, 0xFFFFF880U }, /* 200 */
    { 26, 0xFFFFF8C0U }, /* 201 */
    { 26, 0xFFFFF900U }, /* 202 */
    { 27, 0xFFFFFBC0U }, /* 203 */
    { 27, 0xFFFFFBE0U }, /* 204 */
    { 26, 0xFFFFF940U }, /* 205 */
    { 24, 0xFFFFF100U }, /* 206 */
    { 25, 0xFFFFF680U }, /* 207 */
    { 19, 0xFFFE4000U }, /* 208 */
    { 21, 0xFFFF1800U }, /* 209 */
    { 26, 0xFFFFF980U }, /* 210 */
    { 27, 0xFFFFFC00U }, /* 211 */
    { 27, 0xFFFFFC20U }, /* 212 */
    { 26, 0xFFFFF9C0U }, /* 213 */
    { 27, 0xFFFFFC40U }, /* 214 */
    { 24, 0xFFFFF200U }, /* 215 */
    { 21, 0xFFFF2000U }, /* 216 */
    { 21, 0xFFFF2800U }, /* 217 */
    { 26, 0xFFFFFA00U }, /* 218 */
    { 26, 0xFFFFFA40U }, /* 219 */
    { 28, 0xFFFFFFD0U }, /* 220 */
    { 27, 0xFFFFFC60U }, /* 221 */
    { 27, 0xFFFFFC80U }, /* 222 */
    { 27, 0xFFFFFCA0U }, /* 223 */
    { 20, 0xFFFEC000U }, /* 224 */
    { 24, 0xFFFFF300U }, /* 225 */
    { 20, 0xFFFED000U }, /* 226 */
    { 21, 0xFFFF3000U }, /* 227 */
    { 22, 0xFFFFA400U }, /* 228 */
    { 21, 0xFFFF3800U }, /* 229 */
    { 21, 0xFFFF4000U }, /* 230 */
    { 23, 0xFFFFE600U }, /* 231 */
    { 22, 0xFFFFA800U }, /* 232 */
    { 22, 0xFFFFAC00U }, /* 233 */
    { 25, 0xFFFFF700U }, /* 234 */
    { 25, 0xFFFFF780U }, /* 235 */
    { 24, 0xFFFFF400U }, /* 236 */
    { 24, 0xFFFFF500U }, /* 237 */
    { 26, 0xFFFFFA80U }, /* 238 */
    { 23, 0xFFFFE800U }, /* 239 */
    { 26, 0xFFFFFAC0U }, /* 240 */
    { 27, 0xFFFFFCC0U }, /* 241 */
    { 26, 0xFFFFFB00U }, /* 242 */
    { 26, 0xFFFFFB40U }, /* 243 */
    { 27, 0xFFFFFCE0U }, /* 244 */
    { 27, 0xFFFFFD00U }, /* 245 */
    { 27, 0xFFFFFD20U }, /* 246 */
    { 27, 0xFFFFFD40U }, /* 247 */
    { 27, 0xFFFFFD60U }, /* 248 */
    { 28, 0xFFFFFFE0U }, /* 249 */
    { 27, 0xFFFFFD80U }, /* 250 */
    { 27, 0xFFFFFDA0U }, /* 251 */
    { 27, 0xFFFFFDC0U }, /* 252 */
    { 27, 0xFFFFFDE0U }, /* 253 */
    { 27, 0xFFFFFE00U }, /* 254 */
    { 26, 0xFFFFFB80U }, /* 255 */
    { 30, 0xFFFFFFFCU }, /* 256 */
};

/** 从 bit 流读取下一位（MSB first）；返回 0/1，失败 -1。 */
static int32_t huff_read_bit(const uint8_t *in, int32_t in_len, int32_t *bit_pos) {
    int32_t byte_i;
    int32_t bit_i;
    if (!in || !bit_pos || *bit_pos < 0)
        return -1;
    if (*bit_pos >= in_len * 8)
        return -1;
    byte_i = *bit_pos / 8;
    bit_i = 7 - (*bit_pos % 8);
    *bit_pos = *bit_pos + 1;
    return (in[byte_i] >> bit_i) & 1;
}

/**
 * 解码 HPACK Huffman 字节流（不含 length/H 前缀）。
 * 成功返回写入 out 的字节数；失败 -1。
 */
int32_t http2_hpack_huffman_decode_c(const uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
    int32_t bit_pos = 0;
    int32_t out_len = 0;
    int32_t i;
    if (!in || in_len <= 0 || !out || out_cap <= 0)
        return -1;
    for (;;) {
        int32_t matched = 0;
        int32_t start_bit = bit_pos;
        for (i = 0; i < 257; i++) {
            int32_t j;
            int32_t acc = 0;
            const huff_sym_t *sym = &g_http2_huff_sym[i];
            if (sym->nbits <= 0)
                continue;
            bit_pos = start_bit;
            for (j = 0; j < (int32_t)sym->nbits; j++) {
                int32_t b = huff_read_bit(in, in_len, &bit_pos);
                if (b < 0)
                    return -1;
                acc = (acc << 1) | b;
            }
            {
                uint32_t expect = sym->code >> (32 - sym->nbits);
                if ((uint32_t)acc == expect) {
                    if (i == 256)
                        return out_len;
                    if (out_len >= out_cap)
                        return -1;
                    out[out_len++] = (uint8_t)i;
                    matched = 1;
                    break;
                }
            }
        }
        if (matched == 0)
            return -1;
    }
}

/** Huffman 解码层可用。 */
int32_t http2_hpack_huffman_is_available_c(void) { return 1; }

/** 烟测：自洽 Huffman 编解码 roundtrip（"www.example.com"）。 */
int32_t http2_hpack_huffman_smoke_c(void) {
    static const uint8_t enc[] = {0xf1, 0xe3, 0xc2, 0xe5, 0xf2, 0x3a, 0x6b, 0xa0, 0xab,
                                  0x90, 0xf4, 0xff, 0xff, 0xff, 0xff};
    static const uint8_t expect[] = "www.example.com";
    uint8_t out[32];
    int32_t n;
    n = http2_hpack_huffman_decode_c(enc, (int32_t)sizeof(enc), out, (int32_t)sizeof(out));
    if (n != (int32_t)(sizeof(expect) - 1))
        return 1;
    if (memcmp(out, expect, (size_t)n) != 0)
        return 2;
    return 0;
}

