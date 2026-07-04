// STD-150：KeyTag 稳定 key 排序烟测（相等 key 保序）
const sort = import("std.sort");
const debug = import("core.debug");

function main(): i32 {
  let items: sort.KeyTag[4] = [
    sort.KeyTag { key: 3, tag: 0 },
    sort.KeyTag { key: 1, tag: 1 },
    sort.KeyTag { key: 3, tag: 2 },
    sort.KeyTag { key: 2, tag: 3 },
  ];
  sort.stable_by_key(&items[0], 4);
  if (items[0].key != 1) { return 1; }
  if (items[1].key != 2) { return 2; }
  if (items[2].key != 3 || items[3].key != 3) { return 3; }
  if (items[2].tag != 0 || items[3].tag != 2) { return 4; }
  if (sort.cmp_key_fn() == 0) { return 5; }
  return 0;
}
