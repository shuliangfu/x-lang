// std.db.kv v2 烟测：WAL → flush → compact → SST 冻结 → 读回。
const dbkv = import("std.db.kv");

function main(): i32 {
  let path: u8[24] =
  [116, 101, 115, 116, 115, 47, 115, 116, 100, 45, 100, 98, 47, 46, 107, 118, 95, 115, 109, 111, 107, 101, 0, 0];
  let key: u8[4] = [116, 105, 99, 107];
  let val: u8[8] = [9, 8, 7, 6, 5, 4, 3, 2];
  let out: u8[16] = 0;
  let store: KvStore = dbkv.open(&path[0], 65536 as u64);
  if (store.handle == 0) {
    return 1;
  }
  if (dbkv.append_ts(store, &key[0], 4, &val[0], 8, 9876543210 as u64) != 0) {
    dbkv.close(store);
    return 2;
  }
  if (dbkv.wal_bytes(store) == 0) {
    dbkv.close(store);
    return 3;
  }
  let n: i32 = dbkv.get(store, &key[0], 4, &out[0], 16);
  if (n != 8) {
    dbkv.close(store);
    return 4;
  }
  if (dbkv.wal_flush(store) != 0) {
    dbkv.close(store);
    return 5;
  }
  if (dbkv.compact(store) != 0) {
    dbkv.close(store);
    return 6;
  }
  if (dbkv.compact_generation(store) == 0) {
    dbkv.close(store);
    return 7;
  }
  if (dbkv.sst_level_count(store) == 0) {
    dbkv.close(store);
    return 10;
  }
  n = dbkv.get(store, &key[0], 4, &out[0], 16);
  if (n != 8 || out[0] != 9 || out[7] != 2) {
    dbkv.close(store);
    return 8;
  }
  if (dbkv.sync(store) != 0) {
    dbkv.close(store);
    return 9;
  }
  dbkv.close(store);
  return 0;
}
