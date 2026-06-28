// STD-HTTP-H2-v11：单连接多请求复用烟测（离线）
const http = import("std.http");

function main(): i32 {
  if (http.conn_reuse_smoke() != 0) { return 1; }
  if (http.conn_reuse_is_available() == false) { return 2; }
  if (http.err_conn_not_ready() != -1237) { return 3; }

  let conn: Http2Conn = Http2Conn {
    fd: 0,
    tls_ctx: 0,
    ready: 0,
    goaway_seen: 0,
    is_https: 0,
    ms: Http2MultistreamClient {
      registry: Http2StreamRegistry { slots_blob: [], count: 0, next_id: 0 },
      peer: Http2PeerSettings { max_concurrent_streams: 0, initial_window_size: 0, settings_ack_sent: 0 },
      flow: Http2FlowState { conn_window: 0, stream_window: 0 },
      open_count: 0
    }
  };
  http.conn_init(&conn);
  if (http.conn_is_ready(&conn) == true) { return 4; }
  if (http.conn_attach_h2c(-1, &conn) != -1) { return 5; }

  http.conn_close(&conn);
  if (http.conn_is_ready(&conn) == true) { return 6; }

  return 0;
}
