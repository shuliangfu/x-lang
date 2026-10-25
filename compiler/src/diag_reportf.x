/**
 * 5.1 / 10.9: diag reportf family — pure .x via Cap 10.7.1 va_* (no host-cc .c).
 * PLATFORM: SHARED — Cap va + Cap fmt (xlang_vsnprintf); Darwin/Linux tip.
 * Seed rest under -DXLANG_L2_DIAG_REPORTF_FROM_X omits the four C bodies.
 * Cap tip -E rewrites va_start/va_end faces to xlang_va_* macros (L4 gold).
 */
export extern function va_start(ap: VaList, last: *u8): void;
export extern function va_end(ap: VaList): void;
export extern function xlang_vsnprintf(buf: *u8, size: i64, fmt: *u8, ap: VaList): i32;
export extern function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

#[no_mangle]
export function diag_vreportf_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, detail: *u8, fmt: *u8, ap: VaList
): void {
  unsafe {
    let buf: u8[1024] = [];
    let f: *u8 = fmt;
    if (f == 0 as *u8) {
      let empty: u8[1] = [0];
      f = &empty[0];
    }
    let _n: i32 = xlang_vsnprintf(&buf[0], 1024, f, ap);
    let d: *u8 = detail;
    if (d == 0 as *u8) {
      d = &buf[0];
    }
    diag_report_with_code(file, line, col, kind, code, &buf[0], d);
  }
}

#[no_mangle]
export function diag_vreportf(
  file: *u8, line: i32, col: i32, kind: *u8, detail: *u8, fmt: *u8, ap: VaList
): void {
  diag_vreportf_with_code(file, line, col, kind, 0 as *u8, detail, fmt, ap);
}

#[no_mangle]
export function diag_reportf_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, detail: *u8, fmt: *u8, ...
): void {
  unsafe {
    let ap: VaList;
    va_start(ap, fmt);
    diag_vreportf_with_code(file, line, col, kind, code, detail, fmt, ap);
    va_end(ap);
  }
}

#[no_mangle]
export function diag_reportf(
  file: *u8, line: i32, col: i32, kind: *u8, detail: *u8, fmt: *u8, ...
): void {
  unsafe {
    let ap: VaList;
    va_start(ap, fmt);
    diag_vreportf_with_code(file, line, col, kind, 0 as *u8, detail, fmt, ap);
    va_end(ap);
  }
}
