// Probe: void main + single-arg println("…") → exit 0 (product string-lit special).
// PLATFORM: SHARED — product entry contract.
const fmt = import("std.fmt");

function main(): void {
  fmt.println("Hello World");
}
