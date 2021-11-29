// electronics box dimensions
// in practice the batteries are slightly larger, so lx and ly will be unused
lx0 = 92;
ly0 = 71;
lz0 = 30;

// dimensions of my "18650" batteries. In practice they're closer to 18700.
d = 18.5;
h_bat = 70.5; // with the button top
d_button = 6.5;
h_body = 69.3;
bat_gap = 0.3;

// dimensions of battery connectors with battery mounted
d_plus = 1.5;
d_minus = 4;
connector_depth = 0.5;

thickness = 3;
int_thickness = 2.5;
inter_r = 2.5;
wire_x_offset = 2;
oring = 2;
oring_hfact = 2;

//
lxb = 5*d + 6*bat_gap;
lyb = h_bat + d_plus + d_minus - 2*connector_depth;
ly = max(lyb, ly0);
lx = max(lxb, lx0);
lz = d + 2*bat_gap + lz0;


module Battery() {
    color(c = [0.35, 0.45, 0.8])
    translate([0, -h_bat/2, 0])
    rotate([-90, 0, 0]) {
        cylinder(h=h_body, d=d, $fn=80);
        translate([0, 0, h_body])
        cylinder(h=2*(h_bat-h_body), d=d_button, $fn=80, center=true);
    }
}

module Batteries() {
    // all 5 batteries at the right location
    z0 = d/2 + bat_gap + thickness;
    dd = d + bat_gap;
    translate([-2*dd, 0, z0])
    Battery();
    translate([-dd, 0, z0])
    Battery();
    translate([0, 0, z0])
    Battery();
    translate([dd, 0, z0])
    Battery();
    translate([2*dd, 0, z0])
    Battery();
}

module MainBox() {
    difference() {
        translate([-lx/2-thickness, -ly/2-thickness, 0])
        cube([lx + 2*thickness, ly + 2*thickness, lz + thickness]);
        translate([-lx/2, -ly/2, thickness])
        cube([lx, ly, lz + thickness]);
    }
}

Batteries();
MainBox();