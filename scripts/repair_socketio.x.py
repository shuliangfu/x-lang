#!/usr/bin/env python3
# 修复 migrate_bare_strings 破坏的 std/socketio/socketio.x：补 const、字符字面量、损坏函数体。

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "std/socketio/socketio.x"


def lit(name: str, s: str) -> str:
    arr = [ord(c) for c in s] + [0]
    return f"const {name}: u8[{len(arr)}] = [{', '.join(str(b) for b in arr)}];"


def char_u8(ch: str) -> str:
    if ch == "\\":
        return "92 as u8"
    if ch == "'":
        return "39 as u8"
    return f"{ord(ch)} as u8"


def replace_char_literals(text: str) -> str:
    text = re.sub(r"\('\\' as u8\)", "92 as u8", text)
    text = re.sub(r"\('\\0' as u8\)", "0 as u8", text)

    def repl(m: re.Match) -> str:
        inner = m.group(1)
        if len(inner) != 1:
            return m.group(0)
        return f"({char_u8(inner)})"

    text = re.sub(r"\('([^']*)' as u8\)", repl, text)
    return text


def fix_ptr_field(text: str) -> str:
    return re.sub(
        r"\(([a-z_]+) == 0\)\.([a-zA-Z0-9_\[\]]+)",
        r"\1.\2",
        text,
    )


def fix_const_block(text: str) -> str:
    # 清理重复/冲突的 SIO_LIT 命名，并补齐缺失常量。
    start = text.index("/** C 字符串常量")
    end = text.index("\n\n/** 多 namespace 路由表")
    extra = [
        lit("SIO_LIT_JSON_SID_PREFIX", '{"sid":"'),
        lit("SIO_LIT_JSON_SID_SUFFIX", '"}'),
        lit("SIO_LIT_SID_QUERY", "sid="),
        lit("SIO_LIT_NS_ROOT", "/"),
        lit("SIO_LIT_NULL", "null"),
        lit("SIO_LIT_OK", "ok"),
        lit("SIO_LIT_MSG", "msg"),
        lit("SIO_LIT_HI", "hi"),
        lit("SIO_LIT_X", "x"),
        lit("SIO_LIT_WORLD", "world"),
        lit("SIO_LIT_N40", "40"),
        lit("SIO_LIT_N3PROBE", "3probe"),
        lit(
            "SIO_LIT_HTTP_127_0_0_1_3000_SOCKET_IO_EIO_4_TRANSPORT_POLLING",
            "http://127.0.0.1:3000/socket.io/?EIO=4&transport=polling",
        ),
        lit("SIO_LIT_WS_127_0_0_1_3000", "ws://127.0.0.1:3000"),
        lit("SIO_LIT_WSS_EXAMPLE_COM_8443", "wss://example.com:8443"),
    ]
    block = "/** C 字符串常量（解析器不支持 \"...\" as *u8）。 */\n"
    block += "\n".join(extra) + "\n"
    # 保留原有非冲突常量（跳过旧 SIO_LIT_SID / SIO_LIT_EMPTY 重复定义段）
    old_lines = text[start:end].splitlines()
    keep = []
    skip_names = {
        "SIO_LIT_SID",
        "SIO_LIT_EMPTY",
        "SIO_LIT_JSON_SID_PREFIX",
        "SIO_LIT_JSON_SID_SUFFIX",
        "SIO_LIT_SID_QUERY",
        "SIO_LIT_NS_ROOT",
    }
    for line in old_lines[1:]:
        m = re.match(r"const (SIO_LIT_\w+):", line)
        if m and m.group(1) in skip_names:
            continue
        keep.append(line)
    block += "\n".join(keep) + "\n"
    return text[:start] + block + text[end + 1 :]


def rename_lit_refs(text: str) -> str:
    repls = [
        ("&SIO_LIT_SID_6483[0]", "&SIO_LIT_JSON_SID_PREFIX[0]"),
        ("let sid_q: *u8 = &SIO_LIT_SID[0]", "let sid_q: *u8 = &SIO_LIT_SID_QUERY[0]"),
        ("let prefix: *u8 = &SIO_LIT_SID[0]", "let prefix: *u8 = &SIO_LIT_JSON_SID_PREFIX[0]"),
        ("let needle: *u8 = &SIO_LIT_SID[0]", "let needle: *u8 = &SIO_LIT_JSON_SID_PREFIX[0]"),
        ("&SIO_LIT_EMPTY_47[0]", "&SIO_LIT_NS_ROOT[0]"),
        ("&SIO_LIT_N40_1660[0]", "&SIO_LIT_N40[0]"),
        ("&SIO_LIT_N3PROBE_7037[0]", "&SIO_LIT_N3PROBE[0]"),
        (
            "&SIO_LIT_HTTP_127_0_0_1_3000_SOCKET_IO_EIO_4_TRANSPORT_POLLING_7613[0]",
            "&SIO_LIT_HTTP_127_0_0_1_3000_SOCKET_IO_EIO_4_TRANSPORT_POLLING[0]",
        ),
        ("&SIO_LIT_WS_127_0_0_1_3000_6456[0]", "&SIO_LIT_WS_127_0_0_1_3000[0]"),
        ("&SIO_LIT_WSS_EXAMPLE_COM_8443_2443[0]", "&SIO_LIT_WSS_EXAMPLE_COM_8443[0]"),
        ("&SIO_LIT_PING_1010[0]", "&SIO_LIT_PING[0]"),
        ("&SIO_LIT_OK_3548[0]", "&SIO_LIT_OK[0]"),
        ("&SIO_LIT_MSG_8417[0]", "&SIO_LIT_MSG[0]"),
        ("&SIO_LIT_HI_3329[0]", "&SIO_LIT_HI[0]"),
        ("&SIO_LIT_HELLO_2322[0]", "&SIO_LIT_HELLO[0]"),
        ("&SIO_LIT_WORLD_8802[0]", "&SIO_LIT_WORLD[0]"),
        ("let js: *u8 = &SIO_LIT_EMPTY[0]", "let js: *u8 = &SIO_LIT_JSON_SID_SUFFIX[0]"),
    ]
    for a, b in repls:
        text = text.replace(a, b)
    return text


def fix_publish_ns(text: str) -> str:
    bad = re.compile(
        r"if \(sio_cluster_adapter_publish_ns_c\(([^;]+),\s*\{\s*\n\s*&SIO_LIT_HI\[0\], 2\) != 0\)\s*\n\s*\}\s*\n\s*return 4;",
        re.MULTILINE,
    )
    good = r"if (sio_cluster_adapter_publish_ns_c(\1, &SIO_LIT_HI[0], 2) != 0)\n        {\n          return 4;\n        }"
    return bad.sub(good, text)


def fix_count_typo(text: str) -> str:
    return text.replace("a.count = count + 1;", "a.count = a.count + 1;")


REPLACED_FUNCTIONS = r'''
function sio_eio_encode_packet_c(type: i32, payload: *u8, payload_len: i32, out: *u8, out_cap: i32): i32 {

    let n: i32 = 0;
    if ((out == 0) || out_cap < 1)
        {
          return -1;
        }
    if (type < 0 || type > 9)
        {
          return -1;
        }
    if (payload_len < 0)
        {
          return -1;
        }
    if (payload_len > 0 && (payload == 0))
        {
          return -1;
        }
    if (1 + payload_len > out_cap)
        {
          return -1;
        }
    out[0] = (48 + type) as u8;
    n = 1;
    if (payload_len > 0) {
        memcpy(out + 1, payload, (payload_len as usize));
        n = n + payload_len;
    }
    return n;
}

function sio_eio_decode_packet_c(buf: *u8, len: i32, out_type: *i32, out_payload: *u8, out_cap: i32, out_payload_len: *i32): i32 {

    let type: i32 = 0;
    let plen: i32 = 0;
    if ((buf == 0) || len <= 0 || (out_type == 0) || (out_payload_len == 0))
        {
          return -1;
        }
    if (buf[0] < (48 as u8) || buf[0] > (57 as u8))
        {
          return -1;
        }
    type = (buf[0] - (48 as u8)) as i32;
    plen = len - 1;
    if (plen < 0)
        {
          plen = 0;
        }
    if (plen > 0) {
        if ((out_payload == 0))
            {
              return -1;
            }
        if (plen > out_cap)
            {
              return -1;
            }
        memcpy(out_payload, buf + 1, (plen as usize));
    }
    out_type[0] = type;
    out_payload_len[0] = plen;
    return 0;
}

function sio_append_json_string(out: *u8, cap: i32, off: *i32, s: *u8, slen: i32): i32 {

    let i: i32 = 0;
    let c: u8 = 0;
    if ((out == 0) || (off == 0) || *off < 0)
        {
          return -1;
        }
    if (slen > 0 && (s == 0))
        {
          return -1;
        }
    if (*off + 1 >= cap)
        {
          return -1;
        }
    out[sio_bump_off(off)] = (34 as u8);
    for (i = 0; i < slen; i = i + 1) {
        c = s[i];
        if (c == (34 as u8) || c == (92 as u8)) {
            if (*off + 2 >= cap)
                {
                  return -1;
                }
            out[sio_bump_off(off)] = (92 as u8);
            out[sio_bump_off(off)] = c;
            continue;
        }
        if (*off >= cap)
            {
              return -1;
            }
        out[sio_bump_off(off)] = c;
    }
    if (*off >= cap)
        {
          return -1;
        }
    out[sio_bump_off(off)] = (34 as u8);
    return 0;
}

function sio_encode_event_packet_c(event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {

    let inner: u8[512] = [];
    let off: i32 = 0;
    if ((out == 0) || out_cap < 4)
        {
          return -1;
        }
    if (event_len <= 0 || (event == 0))
        {
          return -1;
        }
    if (data_len < 0)
        {
          return -1;
        }
    if (data_len > 0 && (data == 0))
        {
          return -1;
        }
    inner[off] = (48 + SIO_SIO_EVENT) as u8;
    off = off + 1;
    inner[off] = (91 as u8);
    off = off + 1;
    if (sio_append_json_string(inner, ((inner as usize) as i32), &off, event, event_len) != 0)
        {
          return -1;
        }
    if (off + 1 >= ((inner as usize) as i32))
        {
          return -1;
        }
    inner[off] = (44 as u8);
    off = off + 1;
    if (data_len == 0) {
        if (sio_append_bytes(inner, ((inner as usize) as i32), &off, &SIO_LIT_NULL[0], 4) != 0)
            {
              return -1;
            }
    } else if (sio_append_json_string(inner, ((inner as usize) as i32), &off, data, data_len) != 0) {
        return -1;
    }
    if (off >= ((inner as usize) as i32))
        {
          return -1;
        }
    inner[off] = (93 as u8);
    off = off + 1;
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}

function sio_encode_event_ns_packet_c(ns: *u8, ns_len: i32, event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {

    let inner: u8[512] = [];
    let off: i32 = 0;
    if ((out == 0) || out_cap < 4)
        {
          return -1;
        }
    if (ns_len < 0)
        {
          return -1;
        }
    if ((ns == 0) || ns_len == 0 || (ns_len == 1 && ns[0] == (47 as u8)))
        {
          return sio_encode_event_packet_c(event, event_len, data, data_len, out, out_cap);
        }
    if (ns[0] != (47 as u8))
        {
          return -1;
        }
    if (event_len <= 0 || (event == 0))
        {
          return -1;
        }
    if (data_len < 0)
        {
          return -1;
        }
    if (data_len > 0 && (data == 0))
        {
          return -1;
        }
    inner[off] = (48 + SIO_SIO_EVENT) as u8;
    off = off + 1;
    if (sio_append_bytes(inner, ((inner as usize) as i32), &off, ns, ns_len) != 0)
        {
          return -1;
        }
    inner[off] = (44 as u8);
    off = off + 1;
    inner[off] = (91 as u8);
    off = off + 1;
    if (sio_append_json_string(inner, ((inner as usize) as i32), &off, event, event_len) != 0)
        {
          return -1;
        }
    if (off + 1 >= ((inner as usize) as i32))
        {
          return -1;
        }
    inner[off] = (44 as u8);
    off = off + 1;
    if (data_len == 0) {
        if (sio_append_bytes(inner, ((inner as usize) as i32), &off, &SIO_LIT_NULL[0], 4) != 0)
            {
              return -1;
            }
    } else if (sio_append_json_string(inner, ((inner as usize) as i32), &off, data, data_len) != 0) {
        return -1;
    }
    if (off >= ((inner as usize) as i32))
        {
          return -1;
        }
    inner[off] = (93 as u8);
    off = off + 1;
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}

function sio_encode_event_ack_packet_c(ack_id: i32, event: *u8, event_len: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {

    let inner: u8[512] = [];
    let off: i32 = 0;
    if (ack_id < 0 || (out == 0))
        {
          return -1;
        }
    if (event_len <= 0 || (event == 0))
        {
          return -1;
        }
    if (data_len < 0)
        {
          return -1;
        }
    if (data_len > 0 && (data == 0))
        {
          return -1;
        }
    inner[off] = (48 + SIO_SIO_EVENT) as u8;
    off = off + 1;
    if (sio_append_u32_dec(inner, ((inner as usize) as i32), &off, ack_id as u32) != 0)
        {
          return -1;
        }
    inner[off] = (91 as u8);
    off = off + 1;
    if (sio_append_json_string(inner, ((inner as usize) as i32), &off, event, event_len) != 0)
        {
          return -1;
        }
    if (off + 1 >= ((inner as usize) as i32))
        {
          return -1;
        }
    inner[off] = (44 as u8);
    off = off + 1;
    if (data_len == 0) {
        if (sio_append_bytes(inner, ((inner as usize) as i32), &off, &SIO_LIT_NULL[0], 4) != 0)
            {
              return -1;
            }
    } else if (sio_append_json_string(inner, ((inner as usize) as i32), &off, data, data_len) != 0) {
        return -1;
    }
    if (off >= ((inner as usize) as i32))
        {
          return -1;
        }
    inner[off] = (93 as u8);
    off = off + 1;
    return sio_eio_encode_packet_c(SIO_EIO_MESSAGE, inner, off, out, out_cap);
}
'''


def replace_corrupted_tail(text: str) -> str:
    start = text.index("function sio_append_json_string(")
    end = text.index("function sio_p3_complete_smoke_c():")
    mid = text[start:end]
    # 保留 sio_encode_ack_packet_c 与 sio_ns_ack_smoke_c（后者需手工修一行）
    ack_start = mid.index("function sio_encode_ack_packet_c(")
    ack_block = mid[ack_start:]
    ns_start = ack_block.index("function sio_ns_ack_smoke_c():")
    decode_start = ack_block.index("function sio_decode_event_packet_c(")
    ack_only = ack_block[:ns_start]
    ns_block = ack_block[ns_start:decode_start]
    # 修复 ns_ack_smoke 损坏行
    ns_block = re.sub(
        r"n = sio_encode_event_ns_packet_c\(ns_chat, 5, evt, 4, \"[^\"]+\"\)[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*",
        """n = sio_encode_event_ns_packet_c(ns_chat, 5, evt, 4, &SIO_LIT_X[0], 1, enc, 64);
    if (n != 21 || memcmp(&enc[0], &expect_evt_ns[0], 21) != 0)
        {
          return 11;
        }
    if (sio_decode_event_packet_c(enc + 1, n - 1, evt_out, 16, data_out, 16, &dlen) != 0)
        {
          return 12;
        }
    if (dlen != 1 || data_out[0] != (120 as u8))
        {
          return 13;
        }""",
        ns_block,
        count=1,
        flags=re.DOTALL,
    )
    tail = r'''
function sio_decode_event_packet_c(sio_pkt: *u8, len: i32, out_event: *u8, out_event_cap: i32, out_data: *u8, out_data_cap: i32, out_data_len: *i32): i32 {

    let i: i32 = 0;
    let ei: i32 = 0;
    let di: i32 = 0;
    let c: u8 = 0;
    if ((sio_pkt == 0) || len < 5 || (out_event == 0) || (out_data == 0) || (out_data_len == 0))
        {
          return -1;
        }
    if (sio_pkt[0] != (48 + SIO_SIO_EVENT) as u8)
        {
          return -1;
        }
    i = 1;
    while (i < len && sio_pkt[i] >= (48 as u8) && sio_pkt[i] <= (57 as u8))
        i = i + 1;
    if (i < len && sio_pkt[i] == (47 as u8)) {
        while (i < len && sio_pkt[i] != (44 as u8))
            i = i + 1;
        if (i >= len)
            {
              return -1;
            }
        i = i + 1;
    }
    if (i + 3 >= len || sio_pkt[i] != (91 as u8) || sio_pkt[i + 1] != (34 as u8))
        {
          return -1;
        }
    i = i + 2;
    while (i < len) {
        c = sio_pkt[i];
        if (c == (34 as u8))
            {
              break;
            }
        if (c == (92 as u8) && i + 1 < len) {
            if (ei + 1 >= out_event_cap)
                {
                  return -1;
                }
            i = i + 1;
            out_event[ei] = sio_pkt[i];
            ei = ei + 1;
            continue;
        }
        if (ei + 1 >= out_event_cap)
            {
              return -1;
            }
        out_event[ei] = c;
        ei = ei + 1;
        i = i + 1;
    }
    if (i >= len || ei <= 0)
        {
          return -1;
        }
    out_event[ei] = (0 as u8);
    i = i + 2;
    if (i >= len)
        {
          return -1;
        }
    if (sio_pkt[i] == (110 as u8) && i + 3 < len && sio_pkt[i + 1] == (117 as u8)) {
        out_data_len[0] = 0;
        return 0;
    }
    if (sio_pkt[i] != (34 as u8))
        {
          return -1;
        }
    i = i + 1;
    while (i < len) {
        c = sio_pkt[i];
        if (c == (34 as u8))
            {
              break;
            }
        if (c == (92 as u8) && i + 1 < len) {
            if (di >= out_data_cap)
                {
                  return -1;
                }
            i = i + 1;
            out_data[di] = sio_pkt[i];
            di = di + 1;
            continue;
        }
        if (di >= out_data_cap)
            {
              return -1;
            }
        out_data[di] = c;
        di = di + 1;
        i = i + 1;
    }
    if (i >= len)
        {
          return -1;
        }
    out_data_len[0] = di;
    return 0;
}

function sio_eio_extract_sid_c(open_payload: *u8, len: i32, out_sid: *u8, out_cap: i32): i32 {

    let needle: *u8 = &SIO_LIT_JSON_SID_PREFIX[0];
    let i: i32 = 0;
    let j: i32 = 0;
    let sid_len: i32 = 0;
    if ((open_payload == 0) || len <= 0 || (out_sid == 0) || out_cap < 2)
        {
          return -1;
        }
    for (i = 0; i + 7 <= len; i = i + 1) {
        if (memcmp(open_payload + i, needle, 7) != 0)
            {
              continue;
            }
        j = i + 7;
        sid_len = 0;
        while (j < len && open_payload[j] != (34 as u8)) {
            if (sid_len + 1 >= out_cap)
                {
                  return -1;
                }
            out_sid[sid_len] = open_payload[j];
            sid_len = sid_len + 1;
            j = j + 1;
        }
        if (sid_len <= 0)
            {
              return -1;
            }
        return sid_len;
    }
    return -1;
}

function sio_packet_smoke_c(): i32 {

    let open_json: u8[128] = [];
    let enc: u8[64] = [];
    let dec_payload: u8[64] = [];
    let evt: u8[32] = [];
    let data: u8[32] = [];
    let sid: u8[16] = [];
    let sid_expect: *u8 = &SIO_LIT_ABC[0];
    let n: i32 = 0;
    let type: i32 = -1;
    let plen: i32 = 0;
    let dlen: i32 = 0;
    let jl: i32 = 0;
    jl = sio_server_build_open_json_c(sid_expect, 3, open_json, ((open_json as usize) as i32));
    if (jl <= 0)
        {
          return 1;
        }
    n = sio_eio_encode_packet_c(SIO_EIO_OPEN, open_json, jl, enc, 64);
    if (n <= 0)
        {
          return 1;
        }
    if (sio_eio_decode_packet_c(enc, n, &type, dec_payload, 64, &plen) != 0)
        {
          return 2;
        }
    if (type != SIO_EIO_OPEN || plen != jl)
        {
          return 3;
        }
    if (sio_eio_extract_sid_c(dec_payload, plen, sid, 16) != 3)
        {
          return 4;
        }
    if (memcmp(sid, sid_expect, 3) != 0)
        {
          return 5;
        }
    n = sio_encode_event_packet_c(&SIO_LIT_HELLO[0], 5, &SIO_LIT_WORLD[0], 5, enc, 64);
    if (n <= 0)
        {
          return 6;
        }
    if (enc[0] != (48 + SIO_EIO_MESSAGE) as u8)
        {
          return 7;
        }
    if (sio_decode_event_packet_c(enc + 1, n - 1, evt, 32, data, 32, &dlen) != 0)
        {
          return 8;
        }
    if (evt[0] != (104 as u8) || dlen != 5 || data[0] != (119 as u8))
        {
          return 9;
        }
    n = sio_eio_encode_packet_c(SIO_EIO_PING, 0, 0, enc, 64);
    if (n != 1 || enc[0] != (48 + SIO_EIO_PING) as u8)
        {
          return 10;
        }
    if (sio_polling_smoke_c() != 0)
        {
          return 11;
        }
    if (sio_connect_smoke_c() != 0)
        {
          return 12;
        }
    if (sio_node_interop_smoke_c() != 0)
        {
          return 13;
        }
    if (sio_server_smoke_c() != 0)
        {
          return 14;
        }
    if (sio_ns_ack_smoke_c() != 0)
        {
          return 15;
        }
    if (sio_ns_router_smoke_c() != 0)
        {
          return 16;
        }
    if (sio_ns_sessions_smoke_c() != 0)
        {
          return 17;
        }
    return 0;
}

'''
    new_mid = REPLACED_FUNCTIONS + ack_only + ns_block + tail
    return text[:start] + new_mid + text[end:]


def main() -> None:
    text = PATH.read_text()
    text = fix_const_block(text)
    text = rename_lit_refs(text)
    text = replace_char_literals(text)
    text = fix_ptr_field(text)
    text = fix_publish_ns(text)
    text = fix_count_typo(text)
    text = replace_corrupted_tail(text)
    # alloc 槽位：in_use==0 表示空闲
    text = re.sub(
        r"if \(([a-z_\.]+)\.in_use\)\s*\n\s*\{\s*\n\s*return i;",
        r"if (\1.in_use == 0)\n            {\n              return i;",
        text,
    )
    text = re.sub(
        r"if \(([a-z_\.]+)\.in_use\)\s*\n\s*\{\s*\n\s*continue;",
        r"if (\1.in_use == 0)\n            {\n              continue;",
        text,
    )
    PATH.write_text(text)
    print("repaired", PATH)


if __name__ == "__main__":
    main()
