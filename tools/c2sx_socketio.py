#!/usr/bin/env python3
"""c2sx_socketio.py — socketio_glue.c → socketio.sx（F-socketio v2）。"""
import re

SRC = "/home/shu/shux/std/socketio/socketio_glue.c"
DST = "/home/shu/shux/std/socketio/socketio.sx"

STRUCT_MAP = {
    "sio_ns_router_t": "SioNsRouterMem",
    "sio_ns_sessions_t": "SioNsSessionsMem",
    "sio_ws_hub_slot_t": "SioWsHubSlotMem",
    "sio_ws_hub_t": "SioWsHubMem",
    "sio_room_t": "SioRoomMem",
    "sio_room_registry_t": "SioRoomRegistryMem",
    "sio_ws_hub_snap_slot_t": "SioWsHubSnapSlotMem",
    "sio_ws_hub_snapshot_t": "SioWsHubSnapshotMem",
    "sio_room_registry_snapshot_t": "SioRoomRegistrySnapshotMem",
    "sio_session_bundle_t": "SioSessionBundleMem",
    "sio_cluster_adapter_msg_t": "SioClusterAdapterMsgMem",
    "sio_cluster_adapter_t": "SioClusterAdapterMem",
    "sio_cluster_adapter_snapshot_t": "SioClusterAdapterSnapshotMem",
}

STRUCTS_SX = """
/** 多 namespace 路由表（CONNECT 包 → slot_id；布局与 mod.sx SioNsRouter 一致）。 */
allow(padding) struct SioNsRouterMem {
  count: i32;
  ns_len: i32[4];
  slot_id: i32[4];
  ns: u8[4][24];
}

/** 多 namespace 并发会话表（布局与 mod.sx SioNsSessions 一致）。 */
allow(padding) struct SioNsSessionsMem {
  count: i32;
  slot_id: i32[4];
  active: i32[4];
}

/** WS hub 单槽（布局与 mod.sx SioWsHubSlot 一致，48 字节）。 */
allow(padding) struct SioWsHubSlotMem {
  in_use: i32;
  fd: i32;
  sid_len: i32;
  slot_id: i32;
  tls_ctx: i64;
  sid: u8[24];
}

/** WS hub（count + 对齐填充 + 4 槽；200 字节，与 mod.sx SioWsHub 一致）。 */
allow(padding) struct SioWsHubMem {
  count: i32;
  pad_count: i32;
  slot: SioWsHubSlotMem[4];
}

/** 单个 room（布局与 mod.sx SioRoom 一致）。 */
allow(padding) struct SioRoomMem {
  in_use: i32;
  name_len: i32;
  room_id: i32;
  member_count: i32;
  name: u8[16];
  members: i32[4];
}

/** room 注册表（布局与 mod.sx SioRoomRegistry 一致）。 */
allow(padding) struct SioRoomRegistryMem {
  count: i32;
  room: SioRoomMem[4];
}

/** hub 快照单槽。 */
allow(padding) struct SioWsHubSnapSlotMem {
  in_use: i32;
  sid_len: i32;
  slot_id: i32;
  sid: u8[24];
}

/** hub 二进制快照。 */
allow(padding) struct SioWsHubSnapshotMem {
  magic: i32;
  version: i32;
  slot: SioWsHubSnapSlotMem[4];
}

/** room 二进制快照。 */
allow(padding) struct SioRoomRegistrySnapshotMem {
  magic: i32;
  version: i32;
  count: i32;
  room: SioRoomMem[4];
}

/** hub + room 一体快照。 */
allow(padding) struct SioSessionBundleMem {
  magic: i32;
  version: i32;
  hub: SioWsHubSnapshotMem;
  room: SioRoomRegistrySnapshotMem;
}

/** cluster adapter 单条消息。 */
allow(padding) struct SioClusterAdapterMsgMem {
  in_use: i32;
  src_node_id: i32;
  room_id: i32;
  ns_len: i32;
  event_len: i32;
  data_len: i32;
  ns: u8[16];
  event: u8[16];
  data: u8[16];
}

/** 内存 cluster adapter。 */
allow(padding) struct SioClusterAdapterMem {
  count: i32;
  node_id: i32;
  msg: SioClusterAdapterMsgMem[4];
}

/** cluster adapter 二进制快照。 */
allow(padding) struct SioClusterAdapterSnapshotMem {
  magic: i32;
  version: i32;
  count: i32;
  node_id: i32;
  msg: SioClusterAdapterMsgMem[4];
}
"""

HEADER = """// std/socketio/socketio.sx — F-socketio v2：Engine.IO/SIO 协议逻辑（纯 .sx）
//
// 【文件职责】
// EIO/SIO 编解码、polling/WS URL、namespace 路由、WS hub、room、cluster adapter 与全部烟测。
// HTTP/WS IO 经 extern http_* / net_ws_*；经 ld -r 单独编译为 socketio_main.o 再合并 socketio.o。
// 对外 API 在 mod.sx（sio_*_c 符号供 mod extern 绑定）。

"""

CONST_DEFINES = """
const SIO_EIO_OPEN: i32 = 0;
const SIO_EIO_CLOSE: i32 = 1;
const SIO_EIO_PING: i32 = 2;
const SIO_EIO_PONG: i32 = 3;
const SIO_EIO_MESSAGE: i32 = 4;
const SIO_EIO_UPGRADE: i32 = 5;
const SIO_EIO_NOOP: i32 = 6;
const SIO_SIO_EVENT: i32 = 2;
const SIO_SIO_CONNECT: i32 = 0;
const SIO_SIO_ACK: i32 = 3;
const SIO_EIO_VERSION: i32 = 4;
const SIO_TRANSPORT_POLLING: i32 = 0;
const SIO_TRANSPORT_WEBSOCKET: i32 = 1;
const SIO_NS_ROUTER_MAX: i32 = 4;
const SIO_NS_NAME_CAP: i32 = 24;
const SIO_WS_HUB_MAX: i32 = 4;
const SIO_WS_SID_CAP: i32 = 24;
const SIO_ROOM_MAX: i32 = 4;
const SIO_ROOM_NAME_CAP: i32 = 16;
const SIO_ROOM_MEMBERS_MAX: i32 = 4;
const SIO_HUB_SNAP_MAGIC: u32 = 0x53494F48;
const SIO_HUB_SNAP_VERSION: i32 = 1;
const SIO_ROOM_SNAP_MAGIC: u32 = 0x53494F52;
const SIO_ROOM_SNAP_VERSION: i32 = 1;
const SIO_SESSION_SNAP_MAGIC: u32 = 0x53494F53;
const SIO_SESSION_SNAP_VERSION: i32 = 1;
const SIO_CLUSTER_ADAPTER_MAX: i32 = 4;
const SIO_CLUSTER_ADAPTER_NS_CAP: i32 = 16;
const SIO_CLUSTER_ADAPTER_EVT_CAP: i32 = 16;
const SIO_CLUSTER_ADAPTER_DATA_CAP: i32 = 16;
const SIO_ADAPTER_SNAP_MAGIC: u32 = 0x53494F41;
const SIO_ADAPTER_SNAP_VERSION: i32 = 1;
"""

EXTERNS = """
extern function http_get_timeout_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_post_timeout_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32,
  timeout_ms: u32): i32;
extern function net_ws_write_text_c(fd: i32, tls_ctx: i64, payload: *u8, payload_len: i32): i32;
extern function net_ws_write_server_text_c(fd: i32, tls_ctx: i64, payload: *u8, payload_len: i32): i32;
extern function net_ws_read_frame_c(fd: i32, tls_ctx: i64, out_opcode: *i32, out_payload: *u8, out_cap: i32,
  out_payload_len: *i32, timeout_ms: u32): i32;
extern function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern function memcmp(a: *u8, b: *u8, n: usize): i32;
extern function memset(s: *u8, c: i32, n: usize): *u8;
extern function strlen(s: *u8): usize;
"""

MARKERS = """
function socketio_f_socketio_v1_marker_c(): i32 { return 1; }
function socketio_f_socketio_v2_marker_c(): i32 { return 1; }
"""

HELPERS = """
function sio_bump_off(off: *i32): void { *off = *off + 1; }

function sio_append_bytes(out: *u8, cap: i32, off: *i32, s: *u8, slen: i32): i32 {
  let i: i32 = 0;
  if (out == 0 || off == 0 || *off < 0) { return -1; }
  if (slen > 0 && s == 0) { return -1; }
  while (i < slen) {
    if (*off >= cap) { return -1; }
    out[*off as usize] = s[i as usize];
    sio_bump_off(off);
    i = i + 1;
  }
  return 0;
}

function sio_append_u32_dec(out: *u8, cap: i32, off: *i32, v: u32): i32 {
  let tmp: u8[12] = [];
  let n: i32 = 0;
  let i: i32 = 0;
  let j: i32 = 0;
  let vv: u32 = v;
  if (out == 0 || off == 0 || *off < 0) { return -1; }
  if (vv == 0) { tmp[0] = 48; n = 1; }
  else {
    while (vv > 0 && n < 12) { tmp[n] = (48 + (vv % 10)) as u8; n = n + 1; vv = vv / 10; }
    i = 0;
    while (i < n / 2) {
      let t: u8 = tmp[i as usize];
      tmp[i as usize] = tmp[(n - 1 - i) as usize];
      tmp[(n - 1 - i) as usize] = t;
      i = i + 1;
    }
  }
  return sio_append_bytes(out, cap, off, &tmp[0], n);
}

function sio_server_wrap_http_body_c(body: *u8, blen: i32, out: *u8, out_cap: i32): i32 {
  let off: i32 = 0;
  let prefix: *u8 = "HTTP/1.1 200 OK\\r\\nContent-Type: text/plain; charset=UTF-8\\r\\nConnection: keep-alive\\r\\nContent-Length: " as *u8;
  let suffix: *u8 = "\\r\\n\\r\\n" as *u8;
  if (body == 0 || blen <= 0 || out == 0 || out_cap < blen + 64) { return -1; }
  if (sio_append_bytes(out, out_cap, &off, prefix, strlen(prefix) as i32) != 0) { return -1; }
  if (sio_append_u32_dec(out, out_cap, &off, blen as u32) != 0) { return -1; }
  if (sio_append_bytes(out, out_cap, &off, suffix, strlen(suffix) as i32) != 0) { return -1; }
  if (off + blen > out_cap) { return -1; }
  if (blen > 0) { memcpy(out + off as usize, body, blen as usize); }
  return off + blen;
}
"""

SKIP_FNS = {"sio_append_bytes", "sio_append_u32_dec", "sio_server_wrap_http_body_c"}


def c_type(t: str) -> str:
    t = re.sub(r"\bconst\b", "", t).strip()
    t = t.replace("int32_t", "i32").replace("int64_t", "i64").replace("uint32_t", "u32").replace("uint8_t", "u8")
    for c, s in STRUCT_MAP.items():
        t = t.replace(c, s)
    if "*" in t:
        base = t.replace("*", "").strip()
        return f"*{base}"
    return t


def extract_functions(text: str):
    pos = 0
    n = len(text)
    while pos < n:
        m = re.search(r"(?:^|\n)(?:static\s+)?(int32_t|void)\s+(\w+)\s*\(", text[pos:])
        if not m:
            break
        start = pos + m.start()
        if start < n and text[start] == "\n":
            start += 1
        i = pos + m.end()
        while i < n and text[i] != "{":
            i += 1
        if i >= n:
            break
        depth = 1
        i += 1
        while i < n and depth > 0:
            if text[i] == "{":
                depth += 1
            elif text[i] == "}":
                depth -= 1
            i += 1
        yield text[start:i]
        pos = i


def convert_params(params: str):
    out = []
    for p in params.split(","):
        p = p.strip()
        if not p or p == "void":
            continue
        pm = re.match(r"(.+?)\s*(\*?)(\w+)$", p)
        if not pm:
            continue
        typ = pm.group(1).strip()
        if pm.group(2):
            typ = typ + " *"
        name = pm.group(3)
        out.append(f"{name}: {c_type(typ)}")
    return ", ".join(out)


def post_process(text: str) -> str:
    text = text.replace("ui32", "u32")
    text = re.sub(
        r'static const uint8_t (\w+)\[\]\s*=\s*\n\s*"([^"]*)"\s*\n\s*"([^"]*)"\s*;',
        r'let \1: *u8 = "\2\3" as *u8;',
        text,
        flags=re.S,
    )
    text = re.sub(
        r'static const uint8_t (\w+)\[\]\s*=\s*\n\s*"([^"]*)"\s*\n\s*"([^"]*)"\s*\n\s*"([^"]*)"\s*;',
        r'let \1: *u8 = "\2\3\4" as *u8;',
        text,
        flags=re.S,
    )
    text = re.sub(
        r'static const uint8_t (\w+)\[\]\s*=\s*"([^"]*)"\s*;',
        r'let \1: *u8 = "\2" as *u8;',
        text,
    )
    text = re.sub(
        r'static const char (\w+)\[\]\s*=\s*"((?:\\.|[^"\\])*)"\s*;',
        r'let \1: *u8 = "\2" as *u8;',
        text,
    )
    text = re.sub(r"\(uint8_t\)\('0' \+", r"(('0' as u8) + ", text)
    text = re.sub(r"uint8_t (\w+)\[(\w+)\]\s*;", r"let \1: [\2]u8 = [];", text)
    text = re.sub(
        r"const (\w+Mem) \*(\w+) = &(\w+)\.(\w+)\[(\w+)\];",
        r"let \2: *\1 = &\3.\4[\5 as usize];",
        text,
    )
    text = re.sub(
        r"const (\w+Mem) \*(\w+) = &(\w+)\.(\w+)\.(\w+)\[(\w+)\];",
        r"let \2: *\1 = &\3.\4.\5[\6 as usize];",
        text,
    )
    text = re.sub(
        r"const (\w+Mem) \*(\w+);",
        r"let \2: *\1 = 0;",
        text,
    )
    text = re.sub(
        r"(\w+) = \(const (\w+Mem) \*\)(buf);",
        r"\1 = \3 as *\2;",
        text,
    )
    text = re.sub(r"as usize\s+(\w+)", r"as usize \1", text)
    return text


def fix_expr(s: str) -> str:
    for c, mn in STRUCT_MAP.items():
        s = s.replace(c, mn)
    s = s.replace("->", ".")
    s = re.sub(r"\bNULL\b", "0", s)
    s = re.sub(r"\(const uint8_t \*\)", "", s)
    s = re.sub(r"\(const u8 \*\)", "", s)
    s = re.sub(r"\(uint8_t \*\)", "", s)
    s = re.sub(r"\(u8 \*\)", "", s)
    s = re.sub(r"\(void\)", "", s)
    s = re.sub(r"\(uint8_t\)\s*'([^']*)'", r"('\1' as u8)", s)
    s = re.sub(r"\(int32_t\)\s*'([^']*)'", r"(\1 as i32)", s)
    s = re.sub(r"\(int32_t\)\(", "(", s)
    s = re.sub(r"\(int32_t\)", " as i32", s)
    s = re.sub(r"\(size_t\)", " as usize", s)
    s = re.sub(r"sizeof\(([^)]+)\)\s*-\s*1", r"(strlen(\1) as i32)", s)
    s = re.sub(r"sizeof\(([^)]+)\)", r"(\1 as usize)", s)
    s = re.sub(r"!\s*([a-zA-Z_]\w*)(?![!=<>])", r"(\1 == 0)", s)
    s = s.replace("(*off)", "*off")
    s = re.sub(r"\*off\s*\+\+", "sio_bump_off(off)", s)
    s = re.sub(r"\bout\[off\+\+\]", "/*OFFINC*/", s)
    s = re.sub(r"as usize([a-zA-Z_])", r"as usize \1", s)
    s = re.sub(r"as i32\(\(", "as i32 (", s)
    return s


def convert_line(line: str) -> str:
    line = line.rstrip()
    if not line.strip():
        return ""
    indent = line[: len(line) - len(line.lstrip())]
    s = line.strip()
    s = fix_expr(s)

    dm = re.match(
        r"(?:const\s+)?(?:uint8_t|int32_t|int64_t|uint32_t|u8|i32|i64|u32)\s+\*?\s*(\w+)\s*;",
        s,
    )
    if dm and "*suffix" not in s and "* " not in s.split()[0]:
        pass
    if re.match(r"const uint8_t \*(\w+)\s*;", s):
        nm = re.match(r"const uint8_t \*(\w+)\s*;", s).group(1)
        return f"{indent}let {nm}: *u8 = 0;"
    dm = re.match(
        r"(?:int32_t|int64_t|uint32_t|uint8_t)\s+(\w+)(\s*=\s*(.+))?\s*;",
        s,
    )
    if dm:
        typ = c_type(re.match(r"(\w+)", s).group(1))
        if dm.group(2):
            return f"{indent}let {dm.group(1)}: {typ} = {fix_expr(dm.group(3).strip())};"
        return f"{indent}let {dm.group(1)}: {typ} = 0;"

    sm = re.match(r"(\w+Mem)\s+(\w+)\s*;", s)
    if sm:
        return f"{indent}let {sm.group(2)}: {sm.group(1)};"

    sm = re.match(r"uint8_t\s+(\w+)\[(\d+)\]\s*;", s)
    if sm:
        return f"{indent}let {sm.group(1)}: [{sm.group(2)}]u8 = [];"

    if s.startswith("static const uint8_t ") and '="' in s:
        m = re.match(r'static const uint8_t (\w+)\[\]\s*=\s*"(.*)"\s*;', s)
        if m:
            return f'{indent}let {m.group(1)}: *u8 = "{m.group(2)}" as *u8;'
    if s.startswith("static const char ") and '="' in s:
        m = re.match(r'static const char (\w+)\[\]\s*=\s*"(.*)"\s*;', s)
        if m:
            return f'{indent}let {m.group(1)}: *u8 = "{m.group(2)}" as *u8;'
    if s.startswith("static const uint8_t ") and "{" in s:
        return f"{indent}let {s.replace('static const uint8_t ', '').replace('[]', '')}"

    if "/*OFFINC*/" in s:
        return f"{indent}out[*off as usize] = ('/' as u8); sio_bump_off(&off);"

    if s.startswith("return"):
        val = s[6:].strip().rstrip(";")
        if val == "":
            return f"{indent}return;"
        return f"{indent}return {val};"

    if s in ("{", "}"):
        return line

    if s.endswith(";") or s.startswith(("if ", "while ", "for ", "else")):
        return f"{indent}{s}"

    return f"{indent}{s}"


def convert_function(fn: str) -> str:
    m = re.match(r"(?:static\s+)?(int32_t|void)\s+(\w+)\s*\((.*?)\)\s*\{", fn, re.S)
    if not m:
        return ""
    ret, name, params, = m.group(1), m.group(2), m.group(3)
    body = fn[m.end() : -1]
    sx_ret = "void" if ret == "void" else "i32"
    lines = [convert_line(ln) for ln in body.splitlines()]
    lines = [ln for ln in lines if ln is not None]
    body_sx = "\n".join(lines)
    return f"function {name}({convert_params(params)}): {sx_ret} {{\n{body_sx}\n}}\n"


def main():
    with open(SRC) as f:
        text = f.read()

    # start at first exported function after typedefs
    start = text.find("int32_t sio_eio_version_c")
    func_text = text[start:]

    parts = [HEADER, CONST_DEFINES, STRUCTS_SX, EXTERNS, MARKERS, HELPERS]
    count = 0
    for fn in extract_functions(func_text):
        nm = re.search(r"(?:static\s+)?(?:int32_t|void)\s+(\w+)\s*\(", fn)
        if not nm:
            continue
        if nm.group(1) in SKIP_FNS:
            continue
        parts.append(convert_function(fn))
        count += 1

    with open(DST, "w") as f:
        f.write(post_process("\n".join(parts)))
    print(f"Wrote {DST} with {count} functions")


if __name__ == "__main__":
    main()
