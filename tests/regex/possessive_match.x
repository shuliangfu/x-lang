// STD-099：占有型量词 *+ / ++ / ?+ 烟测
const regex = import("std.regex");

function main(): i32 {
  let pat_greedy: u8[3] = [46, 43, 33];
  let pat_poss: u8[4] = [46, 43, 43, 33];
  let hay: u8[6] = [104, 101, 108, 108, 111, 33];
  let re_g: *u8 = regex.compile(&pat_greedy[0], 3);
  let re_p: *u8 = regex.compile(&pat_poss[0], 4);
  if (re_g == 0 || re_p == 0) {
    return 1;
  }
  if (regex.match(re_g, &hay[0], 6) != 0) {
    regex.free(re_g);
    regex.free(re_p);
    return 2;
  }
  if (regex.match(re_p, &hay[0], 6) == 0) {
    regex.free(re_g);
    regex.free(re_p);
    return 3;
  }
  let pat_plus: u8[4] = [97, 43, 43, 98];
  regex.free(re_g);
  regex.free(re_p);
  re_g = regex.compile(&pat_plus[0], 4);
  if (re_g == 0) {
    return 4;
  }
  let hay_ab: u8[4] = [97, 97, 97, 98];
  if (regex.match(re_g, &hay_ab[0], 4) != 0) {
    regex.free(re_g);
    return 5;
  }
  let hay_b: u8[1] = [98];
  if (regex.match(re_g, &hay_b[0], 1) == 0) {
    regex.free(re_g);
    return 6;
  }
  regex.free(re_g);
  return 0;
}
