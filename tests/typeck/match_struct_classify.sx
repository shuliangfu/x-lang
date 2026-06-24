struct Point { x: i32; y: i32; }

function classify(p: Point): i32 {
  return match p {
    Point { x: 0, y: 0 } => 0;
    Point { x: 0, y: _ } => 1;
    Point { x, y } if x > y => 2;
    Point { x, y } => 3;
  };
}

function main(): i32 {
  return classify(Point { x: 1, y: 2 });
}
