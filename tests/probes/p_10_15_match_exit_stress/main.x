// 10.15 stress: name-match while then if(eq) must not jump to epilogue return 1
export function sink(x: i32): i32 { return x; }
function pad_0(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_1(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_2(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_3(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_4(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_5(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_6(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_7(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_8(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_9(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_10(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_11(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_12(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_13(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_14(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_15(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_16(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_17(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_18(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_19(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_20(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_21(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_22(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_23(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_24(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_25(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_26(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_27(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_28(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_29(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_30(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_31(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_32(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_33(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_34(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_35(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_36(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_37(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_38(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_39(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_40(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_41(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_42(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_43(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_44(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_45(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_46(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_47(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_48(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_49(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_50(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_51(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_52(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_53(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_54(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_55(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_56(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_57(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_58(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_59(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_60(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_61(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_62(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_63(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_64(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_65(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_66(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_67(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_68(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_69(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_70(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_71(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_72(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_73(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_74(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_75(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_76(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_77(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_78(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}
function pad_79(n: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let acc: i32 = 0;
  while (i < n) {
    eq = 1;
    j = 0;
    while (j < 4) {
      if (j == 3) { eq = 0; j = 4; } else { j = j + 1; }
    }
    if (eq != 0) { acc = acc + 1; }
    i = i + 1;
  }
  return acc;
}

export function match_then_size(nlen: i32, mismatch_at: i32): i32 {
  let j: i32 = 0;
  let eq: i32 = 0;
  let b: i32 = 0;
  eq = 1;
  j = 0;
  while (j < nlen) {
    b = j;
    if (b == mismatch_at) {
      eq = 0;
      j = nlen;
    } else {
      j = j + 1;
    }
  }
  if (eq != 0) {
    return 48;
  }
  return 0;
}

export function main(): i32 {
  let a: i32 = 0;
  let k: i32 = 0;
  while (k < 80) {
    k = k + 1;
  }
  a = match_then_size(5, 99);
  if (a != 48) { return 1; }
  a = match_then_size(5, 2);
  if (a != 0) { return 2; }
  a = match_then_size(1, 99);
  if (a != 48) { return 3; }
  return 0;
}

