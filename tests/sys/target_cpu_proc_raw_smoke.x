/**
 * Stage9 Cap residual 9.1.12 probe: host CPU detect via /proc/cpuinfo Cap read.
 *
 * Contract: xlang_target_cpu_detect_host returns non-zero feature mask on Linux.
 * PLATFORM: LINUX|x86_64|aarch64 gold.
 */

extern "C" function xlang_target_cpu_detect_host(): u32;

/**
 * Probe entry for Cap residual 9.1.12 proc/cpuinfo face.
 * @return i32 — 0 ok (features != 0); 1 detect returned 0
 */
export function main(): i32 {
  let feats: u32 = 0;
  unsafe {
    feats = xlang_target_cpu_detect_host();
  }
  if (feats == 0) {
    return 1;
  }
  return 0;
}
