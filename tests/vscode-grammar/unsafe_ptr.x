// read_u8: see function docblock below.
/** Internal function `read_u8`.
 * Read path helper `read_u8`.
 * @param p *u8
 * @return u8
 */
function read_u8(p: *u8): u8 {
  unsafe {
    return *p;
  }
}
