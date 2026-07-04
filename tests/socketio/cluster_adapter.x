/**
 * STD-SOCKETIO-001 烟测：内存 cluster adapter v14（Redis adapter 接口占位）。
 */
const sio = import("std.socketio");

function main(): i32 {
  if (sio.cluster_adapter_smoke() != 0) {
    return 1;
  }
  if (sio.cluster_adapter_bytes() != 296) {
    return 2;
  }
  return 0;
}
