# Base64 Slowpath Probes

这个目录用于放置 `std/base64/base64.x` 的受控二分探针样例。

约定：

- 只放最小复现/最小对照样例，不放生成物。
- 不接入现有 `tests/run-*.sh` 默认回归链，避免无意放大构建与内存开销。
- 样例命名尽量直接反映二分维度，例如：
  - `enc_update_stub.x`
  - `dec_update_stub.x`
  - `emit_only.x`
- 目标是定位 `shux-c -E` 的慢路径，不是长期保留大量临时文件；结论稳定后可再清理或转正为正式回归。
