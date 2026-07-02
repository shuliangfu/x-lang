#include <stdint.h>
#include <stddef.h>
int32_t csv_next_field_c(uint8_t * ptr, int32_t len, int32_t offset, int32_t * out_start, int32_t * out_len) {
  int32_t start = 0;
  int32_t pos = 0;
  if ((((((ptr ==0) || (len < 0)) || (offset < 0)) || (out_start ==0)) || (out_len ==0))) {
    if (((offset >=0) && (offset <=len))) {
      return offset;
    }
    return len;
  }
  if ((offset >=len)) {
    (void)(((out_start)[0] = len));
    (void)(((out_len)[0] = 0));
    return len;
  }
  if (((ptr)[offset] ==34)) {
    (void)((start = (offset + 1)));
    (void)((pos = start));
    (void)((start = (offset + 1)));
    (void)((start = (offset + 1)));
    if (((offset < len) && ((((ptr)[offset] ==44) || ((ptr)[offset] ==10)) || ((ptr)[offset] ==13)))) {
      if (((ptr)[offset] ==44)) {
        (void)((offset = (offset + 1)));
      } else {
        if (((ptr)[offset] ==13)) {
          (void)((offset = (offset + 1)));
          (void)((offset = (offset + 1)));
        } else {
          (void)((offset = (offset + 1)));
        }
      }
    }
    if (((offset < len) && ((((ptr)[offset] ==44) || ((ptr)[offset] ==10)) || ((ptr)[offset] ==13)))) {
      if (((ptr)[offset] ==44)) {
        (void)((offset = (offset + 1)));
      } else {
        if (((ptr)[offset] ==13)) {
          (void)((offset = (offset + 1)));
          (void)((offset = (offset + 1)));
        } else {
          (void)((offset = (offset + 1)));
        }
      }
    }
    (void)((start = (offset + 1)));
    return offset;
  }
  (void)(((out_start)[0] = offset));
  while (((((offset < len) && ((ptr)[offset] !=44)) && ((ptr)[offset] !=10)) && ((ptr)[offset] !=13))) {
    (void)((offset = (offset + 1)));
  }
  (void)(((out_len)[0] = (offset - (out_start)[0])));
  if ((offset < len)) {
    if (((ptr)[offset] ==44)) {
      (void)((offset = (offset + 1)));
    } else {
      if (((ptr)[offset] ==13)) {
        (void)((offset = (offset + 1)));
        (void)((offset = (offset + 1)));
      } else {
        if (((ptr)[offset] ==10)) {
          (void)((offset = (offset + 1)));
        }
      }
    }
  }
  return offset;
}
int32_t std_csv_next_field(uint8_t * ptr, int32_t len, int32_t offset, int32_t * out_start, int32_t * out_len) {
  return csv_next_field_c(ptr, len, offset, out_start, out_len);
}
int32_t std_csv_csv_test_quoted_first(int32_t * out_start, int32_t * out_len) {
  uint8_t q[8] = { 0 };
  (void)(((q)[0] = 34));
  (void)(((q)[1] = 97));
  (void)(((q)[2] = 44));
  (void)(((q)[3] = 98));
  (void)(((q)[4] = 34));
  (void)(((q)[5] = 44));
  (void)(((q)[6] = 99));
  (void)(((q)[7] = 0));
  return csv_next_field_c(&((q)[0]), 8, 0, out_start, out_len);
}
int32_t std_csv_csv_test_quoted_second(int32_t offset, int32_t * out_start, int32_t * out_len) {
  uint8_t q[8] = { 0 };
  (void)(((q)[0] = 34));
  (void)(((q)[1] = 97));
  (void)(((q)[2] = 44));
  (void)(((q)[3] = 98));
  (void)(((q)[4] = 34));
  (void)(((q)[5] = 44));
  (void)(((q)[6] = 99));
  (void)(((q)[7] = 0));
  return csv_next_field_c(&((q)[0]), 8, offset, out_start, out_len);
}
int32_t csv_escape_c(uint8_t * ptr, int32_t len, uint8_t * buf, int32_t buf_cap) {
  int32_t i = 0;
  int32_t j = 0;
  if ((((ptr ==0) || (buf ==0)) || (buf_cap < 2))) {
    return -(1);
  }
  (void)(((buf)[i] = 34));
  (void)((i = (i + 1)));
  while (((j < len) && (i < (buf_cap - 1)))) {
    if (((ptr)[j] ==34)) {
      if (((i + 2) > buf_cap)) {
        return -(1);
      }
      (void)(((buf)[i] = 34));
      (void)((i = (i + 1)));
      (void)(((buf)[i] = 34));
      (void)((i = (i + 1)));
    } else {
      (void)(((buf)[i] = (ptr)[j]));
      (void)((i = (i + 1)));
    }
    (void)((j = (j + 1)));
  }
  if ((i >=(buf_cap - 1))) {
    return -(1);
  }
  (void)(((buf)[i] = 34));
  (void)((i = (i + 1)));
  return i;
}
int32_t std_csv_unescape(uint8_t * ptr, int32_t len, uint8_t * buf, int32_t buf_cap) {
  int32_t i = 0;
  int32_t j = 0;
  if ((((ptr ==0) || (buf ==0)) || (buf_cap < 0))) {
    return -(1);
  }
  while ((j < len)) {
    if (((((ptr)[j] ==34) && ((j + 1) < len)) && ((ptr)[(j + 1)] ==34))) {
      if ((i >=buf_cap)) {
        return -(1);
      }
      (void)(((buf)[i] = 34));
      (void)((i = (i + 1)));
      (void)((j = (j + 2)));
    } else {
      if ((i >=buf_cap)) {
        return -(1);
      }
      (void)(((buf)[i] = (ptr)[j]));
      (void)((i = (i + 1)));
      (void)((j = (j + 1)));
    }
  }
  return i;
}
int32_t std_csv_csv_test_unescape_ok(uint8_t * buf, int32_t buf_cap) {
  uint8_t raw[4] = { 0 };
  (void)(((raw)[0] = 34));
  (void)(((raw)[1] = 34));
  (void)(((raw)[2] = 97));
  (void)(((raw)[3] = 0));
  return std_csv_unescape(&((raw)[0]), 3, buf, buf_cap);
}
int32_t std_csv_csv_test_unescape_fail(void) {
  uint8_t tiny[1] = { 0 };
  uint8_t raw[4] = { 0 };
  (void)(((raw)[0] = 34));
  (void)(((raw)[1] = 34));
  (void)(((raw)[2] = 97));
  (void)(((raw)[3] = 0));
  return std_csv_unescape(&((raw)[0]), 3, &((tiny)[0]), 1);
}
int32_t next_field(uint8_t * ptr, int32_t len, int32_t offset, int32_t * out_start, int32_t * out_len) {
  return std_csv_next_field(ptr, len, offset, out_start, out_len);
}
int32_t csv_test_quoted_first(int32_t * out_start, int32_t * out_len) {
  return std_csv_csv_test_quoted_first(out_start, out_len);
}
int32_t csv_test_quoted_second(int32_t offset, int32_t * out_start, int32_t * out_len) {
  return std_csv_csv_test_quoted_second(offset, out_start, out_len);
}
int32_t csv_test_unescape_ok(uint8_t * buf, int32_t buf_cap) {
  return std_csv_csv_test_unescape_ok(buf, buf_cap);
}
int32_t csv_test_unescape_fail(void) {
  return std_csv_csv_test_unescape_fail();
}
int32_t csv_field_needs_quote(uint8_t * ptr, int32_t len) {
  int32_t j = 0;
  if ((ptr ==0)) {
    return 0;
  }
  while ((j < len)) {
    uint8_t c = (ptr)[j];
    if (((((c ==44) || (c ==34)) || (c ==10)) || (c ==13))) {
      return 1;
    }
    (void)((j = (j + 1)));
  }
  return 0;
}
int32_t csv_parse_row_c(uint8_t * ptr, int32_t len, int32_t offset, int32_t * field_starts, int32_t * field_lens, int32_t max_fields, int32_t * out_count) {
  int32_t pos = 0;
  int32_t start = 0;
  int32_t flen = 0;
  int32_t next = 0;
  if ((((((ptr ==0) || (field_starts ==0)) || (field_lens ==0)) || (out_count ==0)) || (max_fields <=0))) {
    return -(1);
  }
  (void)(((out_count)[0] = 0));
  if (((offset < 0) || (offset > len))) {
    return -(1);
  }
  if ((offset ==len)) {
    return len;
  }
  (void)((pos = offset));
  while ((((out_count)[0] < max_fields) && (pos <=len))) {
    (void)((start = 0));
    (void)((flen = 0));
    (void)((next = csv_next_field_c(ptr, len, pos, &(start), &(flen))));
    (void)(((field_starts)[(out_count)[0]] = start));
    (void)(((field_lens)[(out_count)[0]] = flen));
    (void)(((out_count)[0] = ((out_count)[0] + 1)));
    if ((next >=len)) {
      return len;
    }
    if (((next > 0) && ((ptr)[(next - 1)] ==10))) {
      return next;
    }
    if ((((next > 1) && ((ptr)[(next - 2)] ==13)) && ((ptr)[(next - 1)] ==10))) {
      return next;
    }
    (void)((pos = next));
  }
  return pos;
}
int32_t csv_write_row_c(uint8_t * blob, int32_t * starts, int32_t * lens, int32_t count, uint8_t * out, int32_t out_cap) {
  int32_t o = 0;
  int32_t i = 0;
  uint8_t * fp = ((uint8_t *)(0));
  int32_t fl = 0;
  int32_t ew = 0;
  int32_t k = 0;
  if ((((((blob ==0) || (starts ==0)) || (lens ==0)) || (out ==0)) || (count < 0))) {
    return -(1);
  }
  while ((i < count)) {
    (void)((fp = (blob + (starts)[i])));
    (void)((fl = (lens)[i]));
    if ((i > 0)) {
      if ((o >=out_cap)) {
        return -(1);
      }
      (void)(((out)[o] = 44));
      (void)((o = (o + 1)));
    }
    (void)((fp = (blob + (starts)[i])));
    (void)((fl = (lens)[i]));
  }
  return o;
}
int32_t parse_row(uint8_t * ptr, int32_t len, int32_t offset, int32_t * field_starts, int32_t * field_lens, int32_t max_fields, int32_t * out_count) {
  return csv_parse_row_c(ptr, len, offset, field_starts, field_lens, max_fields, out_count);
}
int32_t write_row(uint8_t * blob, int32_t * starts, int32_t * lens, int32_t count, uint8_t * out, int32_t out_cap) {
  return csv_write_row_c(blob, starts, lens, count, out, out_cap);
}
int32_t csv_stream_writer_append_row_c(uint8_t * out, int32_t out_cap, int32_t * out_len, uint8_t * blob, int32_t * starts, int32_t * lens, int32_t count) {
  int32_t n = 0;
  int32_t left = 0;
  if ((((((out ==0) || (out_len ==0)) || (blob ==0)) || (starts ==0)) || (lens ==0))) {
    return -(1);
  }
  if ((((out_len)[0] < 0) || ((out_len)[0] > out_cap))) {
    return -(1);
  }
  (void)((left = (out_cap - (out_len)[0])));
  if ((left <=1)) {
    return -(1);
  }
  (void)((n = csv_write_row_c(blob, starts, lens, count, (out + (out_len)[0]), (left - 1))));
  if ((n < 0)) {
    return -(1);
  }
  (void)(((out_len)[0] = ((out_len)[0] + n)));
  (void)(((out)[(out_len)[0]] = 10));
  (void)(((out_len)[0] = ((out_len)[0] + 1)));
  return 0;
}
int32_t csv_stream_smoke_c(void) {
  uint8_t blob[16] = { 0 };
  int32_t starts1[3] = { 0 };
  int32_t lens1[3] = { 0 };
  int32_t starts2[3] = { 0 };
  int32_t lens2[3] = { 0 };
  uint8_t out[128] = { 0 };
  int32_t out_len = 0;
  int32_t field_starts[4] = { 0 };
  int32_t field_lens[4] = { 0 };
  int32_t cnt = 0;
  int32_t off = 0;
  int32_t rc = 0;
  (void)(((blob)[0] = 97));
  (void)(((blob)[1] = 108));
  (void)(((blob)[2] = 105));
  (void)(((blob)[3] = 99));
  (void)(((blob)[4] = 101));
  (void)(((blob)[5] = 98));
  (void)(((blob)[6] = 111));
  (void)(((blob)[7] = 98));
  (void)(((blob)[8] = 49));
  (void)(((blob)[9] = 50));
  (void)(((blob)[10] = 51));
  (void)(((starts1)[0] = 0));
  (void)(((starts1)[1] = 5));
  (void)(((starts1)[2] = 8));
  (void)(((lens1)[0] = 5));
  (void)(((lens1)[1] = 3));
  (void)(((lens1)[2] = 3));
  (void)(((starts2)[0] = 10));
  (void)(((starts2)[1] = 11));
  (void)(((starts2)[2] = 12));
  (void)(((lens2)[0] = 1));
  (void)(((lens2)[1] = 0));
  (void)(((lens2)[2] = 1));
  if ((csv_stream_writer_append_row_c(&((out)[0]), 128, &(out_len), &((blob)[0]), &((starts1)[0]), &((lens1)[0]), 3) !=0)) {
    return 1;
  }
  if ((csv_stream_writer_append_row_c(&((out)[0]), 128, &(out_len), &((blob)[0]), &((starts2)[0]), &((lens2)[0]), 3) !=0)) {
    return 2;
  }
  if ((out_len <=0)) {
    return 3;
  }
  (void)((rc = csv_parse_row_c(&((out)[0]), out_len, 0, &((field_starts)[0]), &((field_lens)[0]), 4, &(cnt))));
  if ((((((rc < 0) || (cnt !=3)) || ((field_lens)[0] !=5)) || ((field_lens)[1] !=3)) || ((field_lens)[2] !=3))) {
    return 4;
  }
  (void)((off = rc));
  (void)((cnt = 0));
  (void)((rc = csv_parse_row_c(&((out)[0]), out_len, off, &((field_starts)[0]), &((field_lens)[0]), 4, &(cnt))));
  if ((((rc < 0) || (cnt !=3)) || ((field_lens)[1] !=0))) {
    return 5;
  }
  (void)((off = rc));
  (void)((cnt = 0));
  (void)((rc = csv_parse_row_c(&((out)[0]), out_len, off, &((field_starts)[0]), &((field_lens)[0]), 4, &(cnt))));
  if (((rc < out_len) || (cnt !=0))) {
    return 6;
  }
  return 0;
}
int32_t unescape(uint8_t * ptr, int32_t len, uint8_t * buf, int32_t buf_cap) {
  return std_csv_unescape(ptr, len, buf, buf_cap);
}
