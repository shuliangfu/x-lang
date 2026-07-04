// run_async_usize.x — run v4：usize 形参 seed 传参（IO handle / fd）
/** usize 形参 + await；run 时 push_usize / take_usize。 */
async function id_usize(x: usize): i32 {
  let v: usize = await x;
  return v as i32;
}

function main(): i32 {
  let seed: usize = 99 as usize;
  let r: i32 = run id_usize(seed);
  if (r != 99) {
    return 11;
  }
  return 0;
}
