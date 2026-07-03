// IST (Interrupt Stack Table) — x86_64 TSS + 64-bit IDT gate descriptor with IST field.

#[repr(C)]
struct TSS64 {
  reserved0: u32;
  rsp0_low: u32;
  rsp0_high: u32;
  rsp1_low: u32;
  rsp1_high: u32;
  rsp2_low: u32;
  rsp2_high: u32;
  reserved1: u32;
  reserved2: u32;
  ist1_low: u32;
  ist1_high: u32;
  ist2_low: u32;
  ist2_high: u32;
  ist3_low: u32;
  ist3_high: u32;
  ist4_low: u32;
  ist4_high: u32;
  ist5_low: u32;
  ist5_high: u32;
  ist6_low: u32;
  ist6_high: u32;
  ist7_low: u32;
  ist7_high: u32;
  reserved3: u32;
  reserved4: u32;
  iopb_offset: u32;
}

#[repr(C)]
struct IDTGate64 {
  offset_low: u32;
  selector: u32;
  ist: u32;
  type_attr: u32;
  offset_mid: u32;
  offset_high: u32;
  reserved: u32;
}

#[used]
function get_ist(gate: IDTGate64): i32 { return gate.ist as i32; }
#[used]
function get_selector(gate: IDTGate64): i32 { return gate.selector as i32; }
#[used]
function get_tss_ist1(tss: TSS64): i32 { return tss.ist1_low as i32; }

#[used]
function test_ist(): i32 {
  let handler: u64 = 0xFFFFFFFF80100000;
  let gate: IDTGate64 = {
    offset_low: (handler & 0xFFFF) as u32,
    selector: 0x08,
    ist: 1,
    type_attr: 0x8E,
    offset_mid: ((handler >> 16) & 0xFFFF) as u32,
    offset_high: ((handler >> 32) & 0xFFFFFFFF) as u32,
    reserved: 0
  };
  let tss: TSS64 = {
    reserved0: 0,
    rsp0_low: 0, rsp0_high: 0,
    rsp1_low: 0, rsp1_high: 0,
    rsp2_low: 0, rsp2_high: 0,
    reserved1: 0, reserved2: 0,
    ist1_low: 0, ist1_high: 0,
    ist2_low: 0, ist2_high: 0,
    ist3_low: 0, ist3_high: 0,
    ist4_low: 0, ist4_high: 0,
    ist5_low: 0, ist5_high: 0,
    ist6_low: 0, ist6_high: 0,
    ist7_low: 0, ist7_high: 0,
    reserved3: 0, reserved4: 0,
    iopb_offset: 0
  };
  if (get_ist(gate) != 1) { return 1; }
  if (get_selector(gate) != 8) { return 2; }
  if (gate.type_attr != 0x8E) { return 3; }
  if (get_tss_ist1(tss) != 0) { return 4; }
  return 0;
}

function main(): i32 { return test_ist(); }
