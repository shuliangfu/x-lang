/**
 * Stage9 Cap residual 9.1.7 slice2 probe: resolve without libc getaddrinfo
 * (dns_fast → xlang_dns_cap.h literal/hosts/UDP).
 *
 * Contract: 127.0.0.1 and localhost → host-order 0x7f000001.
 * PLATFORM: LINUX|x86_64 gold.
 */

extern function xlang_dns_cap_resolve_ipv4(hostname: *u8, out_addr: *u32, out_err: *i32): i32;

/**
 * Probe entry for Cap residual DNS resolve face.
 * @return i32 — 0 ok; 1 literal fail; 2 localhost fail
 */
export function main(): i32 {
  let lit: u8[10] = [49, 50, 55, 46, 48, 46, 48, 46, 49, 0]; /* "127.0.0.1" */
  let loc: u8[10] = [108, 111, 99, 97, 108, 104, 111, 115, 116, 0]; /* "localhost" */
  let addr: u32 = 0;
  let err: i32 = 0;
  let rc: i32 = 0;
  unsafe {
    rc = xlang_dns_cap_resolve_ipv4(&lit[0], &addr, &err);
  }
  if (rc != 0 || addr != 0x7f000001) {
    return 1;
  }
  addr = 0;
  err = 0;
  unsafe {
    rc = xlang_dns_cap_resolve_ipv4(&loc[0], &addr, &err);
  }
  if (rc != 0 || addr != 0x7f000001) {
    return 2;
  }
  return 0;
}
