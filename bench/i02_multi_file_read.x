// i02_multi_file_read.x — multi-file concurrent read throughput benchmark (xlang)
// single-thread fallback: xlang thread API not yet available.
//
// Algorithm: write F=8 temp files of 1 MiB to /tmp, then read all 8
// sequentially (no concurrency). Total bytes read == 8*1024*1024.
// Logic mirrors the C/Zig versions minus the parallel read.
// Cleanup removes all temp files before return.

const fs = import("std.fs");

/** Internal function `main`.
 * Single-thread fallback for the multi-file read throughput benchmark.
 *
 * Phase 1 (write): create 8 files /tmp/i02_bench_file_{0..7}.dat, each
 *   FILE_BYTES = 1 MiB, filled with a repeating (offset & 255) pattern.
 * Phase 2 (read): open each file and read in CHUNK=4096-byte blocks,
 *   accumulating a byte-sum sink and the total bytes read.
 * Phase 3 (cleanup): remove_file all 8 temp files.
 *
 * The path buffer is reused across files; only the digit at index 20
 * changes ('0' + file_index). The path is "/tmp/i02_bench_file_0.dat\0"
 * (26 bytes including the null terminator).
 *
 * Contract: total bytes read == 8 * 1024 * 1024 == 8388608 on success.
 * The byte-sum sink has a deterministic value (sum & 0xFF == 0) due to
 * the regular fill pattern, so XORing it into the return preserves the
 * total-bytes contract.
 *
 * @return i32 — low byte of total bytes read (8*1024*1024 & 0xFF == 0)
 */
function main(): i32 {
  let f_count: i32 = 8;
  let file_bytes: i32 = 1048576;
  let chunk: i32 = 4096;
  let chunks_per_file: i32 = 256;

  // Path buffer: "/tmp/i02_bench_file_0.dat\0" — 26 bytes.
  // Index 20 is the per-file digit ('0'..'7'); modified per iteration.
  let path: u8[26] = [47, 116, 109, 112, 47, 105, 48, 50, 95, 98, 101, 110, 99, 104, 95, 102, 105, 108, 101, 95, 48, 46, 100, 97, 116, 0];

  // 4 KiB read/write buffer.
  let buf: u8[4096] = [];

  // ---- Phase 1: write 8 x 1 MiB temp files ----
  let fi: i32 = 0;
  while (fi < f_count) {
    path[20] = (48 + fi) as u8;
    let fd: i32 = fs.create(&path[0]);
    if (fd < 0) { return 1; }

    // Fill buffer with deterministic pattern (offset & 255).
    let bi: i32 = 0;
    while (bi < chunk) {
      buf[bi] = (bi & 255) as u8;
      bi = bi + 1;
    }

    let ci: i32 = 0;
    while (ci < chunks_per_file) {
      let nw: isize = fs.write(fd, &buf[0], chunk as usize);
      if (nw != chunk) {
        fs.close(fd);
        return 2;
      }
      ci = ci + 1;
    }
    if (fs.close(fd) != 0) { return 3; }
    fi = fi + 1;
  }

  // ---- Phase 2: read all 8 files sequentially ----
  let total_bytes: i64 = 0;
  let sum: i32 = 0;
  fi = 0;
  while (fi < f_count) {
    path[20] = (48 + fi) as u8;
    let fd: i32 = fs.open(&path[0]);
    if (fd < 0) {
      // Best-effort cleanup before failure.
      let cf: i32 = 0;
      while (cf < f_count) {
        path[20] = (48 + cf) as u8;
        fs.remove_file(&path[0]);
        cf = cf + 1;
      }
      return 4;
    }

    let remaining: i32 = file_bytes;
    while (remaining > 0) {
      let to_read: i32 = chunk;
      if (to_read > remaining) { to_read = remaining; }
      let nr: isize = fs.read(fd, &buf[0], to_read as usize);
      let nr_i: i32 = nr as i32;
      if (nr_i <= 0) {
        fs.close(fd);
        return 5;
      }
      // Accumulate byte-sum sink to defeat dead-store elimination.
      let bi2: i32 = 0;
      while (bi2 < nr_i) {
        sum = sum + (buf[bi2] as i32);
        bi2 = bi2 + 1;
      }
      total_bytes = total_bytes + (nr_i as i64);
      remaining = remaining - nr_i;
    }
    if (fs.close(fd) != 0) { return 6; }
    fi = fi + 1;
  }

  // ---- Phase 3: cleanup ----
  fi = 0;
  while (fi < f_count) {
    path[20] = (48 + fi) as u8;
    fs.remove_file(&path[0]);
    fi = fi + 1;
  }

  // sum is a read-side anti-dead-store sink. The deterministic buffer
  // pattern (offset & 255) makes sum & 0xFF == 0, so XOR preserves the
  // total-bytes return contract.
  let tb_byte: i32 = (total_bytes & 255) as i32;
  let sum_byte: i32 = sum & 255;
  return (tb_byte ^ sum_byte) as i32;
}
