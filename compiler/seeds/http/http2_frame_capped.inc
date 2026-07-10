/**
 * std/http/frame_capped.inc.c — MAX_FRAME_SIZE 帧 payload 限制（RFC 7540 §4.2；STD-HTTP-H2-v23）
 *
 * 【文件职责】按 SETTINGS MAX_FRAME_SIZE 计算单帧 payload 上限与分片数量。
 * 由 client.inc.c 末尾 #include。
 */

/** 返回有效单帧 payload 上限（RFC 7540 最小 16384）。 */
int32_t http2_frame_payload_limit_c(int32_t max_frame_size) {
    if (max_frame_size < HTTP2_DEFAULT_MAX_FRAME_SIZE)
        return HTTP2_DEFAULT_MAX_FRAME_SIZE;
    if (max_frame_size > 16777215)
        return 16777215;
    return max_frame_size;
}

/** 校验 payload_len 是否不超过 max_frame_size；合法 0，超限 -1。 */
int32_t http2_frame_check_payload_c(int32_t payload_len, int32_t max_frame_size) {
    if (payload_len < 0)
        return -1;
    if (payload_len > http2_frame_payload_limit_c(max_frame_size))
        return -1;
    return 0;
}

/** 计算 DATA 按 max_frame_size 分片后的帧数（0 长度返回 0）。 */
int32_t http2_frame_count_data_chunks_c(int32_t data_len, int32_t max_frame_size) {
    int32_t limit;
    if (data_len <= 0)
        return 0;
    limit = http2_frame_payload_limit_c(max_frame_size);
    return (data_len + limit - 1) / limit;
}

/** MAX_FRAME_SIZE 分片计算 C 烟测；0 通过。 */
int32_t http2_frame_capped_smoke_c(void) {
    if (http2_frame_payload_limit_c(4096) != HTTP2_DEFAULT_MAX_FRAME_SIZE)
        return 1;
    if (http2_frame_payload_limit_c(65536) != 65536)
        return 2;
    if (http2_frame_check_payload_c(16384, 16384) != 0)
        return 3;
    if (http2_frame_check_payload_c(16385, 16384) != -1)
        return 4;
    if (http2_frame_count_data_chunks_c(20000, 16384) != 2)
        return 5;
    if (http2_frame_count_data_chunks_c(16384, 16384) != 1)
        return 6;
    return 0;
}
