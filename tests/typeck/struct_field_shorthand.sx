// STR-02：struct 字段同名简写 `{ fd }` 等价 `{ fd: fd }`；可与显式字段混写
struct PollFd { fd: i32; events: i32; revents: i32; }

function main(): i32 {
  let fd: i32 = 3;
  let events: i32 = 4;
  let p1: PollFd = PollFd { fd: fd, events: events, revents: 0 };
  let p2: PollFd = PollFd { fd, events, revents: 0 };
  let p3: PollFd = { fd, events: events, revents: 0 };
  if (p1.fd != 3 || p1.events != 4 || p1.revents != 0) {
    return 1;
  }
  if (p2.fd != 3 || p2.events != 4 || p2.revents != 0) {
    return 2;
  }
  if (p3.fd != 3 || p3.events != 4 || p3.revents != 0) {
    return 3;
  }
  return 0;
}
