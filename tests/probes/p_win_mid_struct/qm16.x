allow(padding) struct OP { is_some: bool; value: *u8; }
export function some_p(p: *u8): OP { return { is_some: true, value: p }; }
export function none_p(): OP { return { is_some: false, value: 0 as *u8 }; }
export function is_some_p(o: OP): bool { return o.is_some; }
export function map_p(o: OP, m: *u8): OP { if (is_some_p(o)) { return some_p(m); } return none_p(); }
export function get_p(o: OP): *u8 { return o.value; }
