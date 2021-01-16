$e = 0.1;

ot_screw_sep = 25;
ot_screw_dia = 3.2;
ot_thickness = 3;
clamp_thickness = 5.5;
clamp_screw_dia = 7;
clamp_outer_dia = 19;
clamp_length = 30;

module clamp_part() {
  difference() {
    hull() {
      translate([-clamp_thickness / 2, 0, 0]) {
        cube([clamp_thickness, clamp_outer_dia, clamp_outer_dia]);
      }

      translate([
        -clamp_thickness / 2,
        clamp_length - clamp_outer_dia / 2,
        clamp_outer_dia / 2
      ])
        rotate([0, 90, 0]) cylinder(r = clamp_outer_dia / 2, h = clamp_thickness);
    }
    translate([
      -clamp_thickness / 2 - $e,
      clamp_length - clamp_outer_dia / 2,
      clamp_outer_dia / 2
    ])
      rotate([0, 90, 0])
        cylinder(r = clamp_screw_dia / 2, h = clamp_thickness + 2*$e);
  }
}

module ot_mount_part() {
  difference() {
    hull() {
      for (m = [0, 1]) mirror([m, 0, 0]) {
        rotate([90, 0, 0])
          translate([
            ot_screw_sep / 2,
            clamp_outer_dia / 2,
            0
          ])
            cylinder(r = clamp_outer_dia / 2, h = ot_thickness);
      }
    }
    for (m = [0, 1]) mirror([m, 0, 0]) {
      rotate([90, 0, 0])
        translate([
          ot_screw_sep / 2,
          clamp_outer_dia / 2,
          -$e
        ])
          cylinder(r = ot_screw_dia / 2, h = ot_thickness + 2*$e);
    }
  }
}

module fillet() {
  w = 7;
  linear_extrude(height = clamp_outer_dia) {
    polygon([
      [-w, 0], [w, 0], [0, w]
    ]);
  }
}

clamp_part();
ot_mount_part();
fillet();
