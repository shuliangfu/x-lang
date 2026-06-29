// std.db.arrow v2 烟测：F32 + null bitmap + adopt + SIMD 归约。
const dbarrow = import("std.db.arrow");

function main(): i32 {
  let col_i: ArrowColumn = dbarrow.new_i32(64);
  let col_f: ArrowColumn = dbarrow.new_f32(64);
  let nic: f32[4] = [1.0, 2.0, 3.0, 4.0];
  if (col_i.handle == 0 || col_f.handle == 0) {
    return 1;
  }
  if (dbarrow.append_null(col_i, 100, 1) != 0) {
    return 2;
  }
  if (dbarrow.append_null(col_i, 0, 0) != 0) {
    return 3;
  }
  if (dbarrow.valid(col_i, 1) != 0) {
    return 4;
  }
  if (dbarrow.null_bitmap(col_i) == 0) {
    return 41;
  }
  if (dbarrow.append(col_f, 2.718) != 0) {
    return 5;
  }
  let adopted: ArrowColumn = dbarrow.adopt(&nic[0], 4, 4);
  let fdata: *f32 = dbarrow.data_f32(adopted);
  if (adopted.handle == 0 || dbarrow.owned(adopted) != 0) {
    return 6;
  }
  if (fdata[2] != 3.0) {
    return 7;
  }
  if (dbarrow.sum_valid_i32(col_i, 2) != 100) {
    return 8;
  }
  let batch: ArrowBatch = dbarrow.batch(4);
  let fetched: ArrowColumn = ArrowColumn { handle: 0 };
  if (batch.handle == 0) {
    dbarrow.free(adopted);
    return 9;
  }
  if (dbarrow.add(batch, col_i) != 0 || dbarrow.add(batch, adopted) != 0) {
    dbarrow.free(batch);
    return 10;
  }
  if (dbarrow.len(batch) != 2) {
    dbarrow.free(batch);
    return 11;
  }
  fetched = dbarrow.get(batch, 1);
  if (fetched.handle != adopted.handle) {
    dbarrow.free(batch);
    return 12;
  }
  dbarrow.free(batch);
  dbarrow.free(col_f);
  return 0;
}
