/**
 * LANG-001 golden：SHUX_FEATURE_MATCH_STMT 灰度；未定义时 exit 0，-D 时 exit 42。
 */
#if SHUX_FEATURE_MATCH_STMT
function main(): i32 {
  return 42;
}
#else
function main(): i32 {
  return 0;
}
#endif
