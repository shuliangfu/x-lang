// STD-083：runtime 自动 TLS 链入烟测（须 net-o-openssl + invoke_cc -lssl）
const net = import("std.net");

function main(): i32 {
  if (net.tls_is_available() == 0) {
    return 1;
  }
  let name: *u8 = net.tls_backend_name();
  if (name == 0) {
    return 2;
  }
  if (name[0] != 111 || name[1] != 112) {
    return 3;
  }
  return 0;
}
