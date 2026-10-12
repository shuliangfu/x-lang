typedef struct { long long a, b; } P;
typedef struct { long long a; int b; } T;
P x_mk(long long x); long long x_sum(P s, long long k); T x_mk12(long long x);
P c_mk(long long x) { P p = { x, x + 1 }; return p; }
long long c_sum(P s) { return s.a * 10 + s.b; }
T c_mk12(long long x, int y) { T t = { x, y }; return t; }
long long c_sum12(long long k1, long long k2, long long k3, long long k4, T t) { return t.a * 100 + t.b + k1 + k2 + k3 + k4; }
int c_calls_x(void) {
  P p = x_mk(3); if (p.a != 3 || p.b != 6) return 1;
  if (x_sum(p, 1) != 307) return 2;
  T t = x_mk12(4); if (t.a != 4 || t.b != 77) return 3;
  return 0;
}
