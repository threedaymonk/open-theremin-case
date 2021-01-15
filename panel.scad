$fs = 1;
$fa = 1;
$e = 0.01;

panel_cols = [18, 42];
knob_offsets = [54, 76];
led_button_offset = 32;

module panel_cuts() {
  translate([-board_width / 2, -board_length / 2]) {
    // function
    translate([panel_cols[0], led_button_offset]) circle(9.5/2);


    // LEDs
    translate([panel_cols[1], led_button_offset]) {
      translate([-2, -4.5]) square([4, 4]);
      translate([-2, 0.5]) square([4, 4]);
    }

    // knobs
    for (y = knob_offsets) for (x = panel_cols) {
      translate([x, y]) circle(7.5/2);
    }
  }
}

module panel_relief(thickness) {
  mount_thickness = 2;
  led_w = 7;
  led_h = 12;
  led_thickness = 1;

  // LEDs protrude slightly past the pots
  translate([-board_width / 2, -board_length / 2, 0]) {
    translate([panel_cols[1] - led_w/2, led_button_offset - led_h/2, led_thickness])
      cube([led_w, led_h, thickness]);
  }

  // slim panel overall where components pass through
  translate([-20, -30, mount_thickness])
    cube([40, 70, thickness]);
}

board_width = 60;
board_length = 100;
slack = 0.5;
sidewall = 6;
width = board_width + 2 * slack + 2 * sidewall;
length = board_length + 2 * slack + 2 * sidewall;
corner_r = 4;
m3_thread = 2.9;
m3_shaft = 3.2;
m3_cap = 6;
layer = 0.2;

module screws(d, h) {
  r = d / 2;
  for (ky = [-1, 1]) for (kx = [-1, 1]) {
    translate([kx * (width/2 - corner_r), ky * (length/2 - corner_r), 0])
      cylinder(r = r, h = h);
  }
}

module pcb() {
  bevel = 2;
  bite_y = 4.5;
  bite_x = 18;
  mirror ([1, 0]) translate([-board_width/2, -board_length/2]) {
    polygon([
      [bevel, 0], [board_width - bevel, 0],
      [board_width, bevel], [board_width, board_length - bite_y - bevel],
      [board_width - bevel, board_length - bite_y],
      [board_width - bite_x, board_length - bite_y],
      [board_width - bite_x - bite_y, board_length],
      [bevel, board_length], [0, board_length - bevel],
      [0, bevel]
    ]);
  }
}

module three_wall(depth) {
  loci = [[1, 1], [1, -1], [-1, -1], [-1, 1]];

  for (i = [0:2]) {
    hull() {
      for (ky = [loci[i].y, loci[i+1].y]) {
        for (kx = [loci[i].x, loci[i+1].x]) {
          translate([kx * (width / 2 - corner_r), ky * (length / 2 - corner_r), 0])
            cylinder(r = corner_r, h = depth);
        }
      }
    }
  }
}

module outset_pcb(amount) {
  kx = (width + 2 * amount) / width;
  ky = (length + 2 * amount) / length;
  scale([kx, ky]) pcb();
}

pcb_thickness = 1.6;
wall = 3;
sheet_thickness = 3;
component_height = 10;
arduino_depth = 16;
height = 2 * sheet_thickness + component_height + pcb_thickness
       + arduino_depth;
lid_height = height / 2;
base_height = height - lid_height;

module shell() {
  difference() {
    union() {
      // thick walls on three sides
      three_wall(height);
      // thin wall for connector side
      linear_extrude(height = height) outset_pcb(wall + slack);
      // rounded rectangle front panel
      translate([0, 0, height - sheet_thickness])
        hull() three_wall(sheet_thickness);
    }

    // volume for circuitry
    translate([0, 0, sheet_thickness])
      linear_extrude(height = height - 2 * sheet_thickness)
        outset_pcb(slack);

    // screw holes
    translate([0, 0, -$e]) screws(m3_thread, height - sheet_thickness - $e);
    translate([0, 0, -$e]) screws(m3_shaft, base_height + 2*$e);
    translate([0, 0, -$e]) screws(m3_cap, base_height + $e - 4);

    // cutouts for connectors
    // datum is bottom left centre of circuit board
    // because we just chop these out along the y axis
    translate([
      board_width / 2,
      0,
      height - sheet_thickness - component_height - pcb_thickness
    ]) {
      translate([-26, 0, -12]) cube([15, length, 13]);
      translate([-37, 0, -7]) cube([8, length, 8]);
      translate([-54.5, 0, -13]) cube([12, length, 14]);
    }

    // channel for antenna clips
    // these are mostly a 5mm cylinder, with a 5mm square section around the
    // screw hole. For simplicity of printing (because vertical holes never
    // come out round) and modelling, let's make these square channels.
    // Also need to allow about 1mm of height for the star washer so assume
    // 6mm down from pcb underside.
    translate([
      -width / 2 - $e,
      -board_length / 2 + 15 - 2.5,
      height - sheet_thickness - component_height - pcb_thickness - 6
    ]) cube([width + 2 * $e, 5, 6]);
  }
}

module base() {
  difference() {
    shell();
    translate([-width / 2 - $e, -length / 2 - $e, base_height])
      cube([width + 2 * $e, length + 2 * $e, height]);
  }
}

module lid() {
  difference() {
    translate([0, 0, height]) rotate([0, 180, 0]) shell();
    translate([-width / 2 - $e, -length / 2 - $e, lid_height])
      cube([width + 2 * $e, length + 2 * $e, height]);
    translate([0, 0, -$e]) linear_extrude(height = height) panel_cuts();
    panel_relief(height);
  }
}

base();
translate([width + 10, 0, 0]) lid();
