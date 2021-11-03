// dimensions of my "18650" batteries. In practice they're closer to 18700.
d = 18.5;
h = 70.5; // with the button top
h_body = 69.3;
d_button = 6.5;
gap_side = 0.5;
gap_h_bottom = 3;
gap_h_top = 2;
offset_top = 5;
offset_extra = 8;
thickness = 4;
inter_r = 2.5;
wire_x_offset = 2;
oring = 2;
oring_hfact = 0.8;

// attach mechanism
z_attach = h - thickness;
l_attach = 12;
w_attach = 4;

$fn=80;
eps = 1e-3;


// useful dimensions
h_tot = h + gap_h_bottom;
r_tot = d/2 + thickness + gap_side;
spacing = d + thickness + 2*gap_side;
c1 = sqrt(3)/2;
c2 = 0.5;
x_spacing = spacing*c1;
y_spacing = spacing*c2;

// just for displaying what it looks like
module Battery() {
    cylinder(h=h_body, d=d, $fn=80);
    translate([0, 0, h_body])
    cylinder(h=2*(h-h_body), d=d_button, $fn=80, center=true);
}

module BatteryHole() {
    dtot = d + 2*gap_side;
    cylinder(h=3*h, d=dtot, center=true);
}

module DShape(r) {
    union() {
        translate([r_tot, spacing, 0])
        cylinder(h=h, r=r);
        translate([r_tot, -spacing, 0])
        cylinder(h=h, r=r);
        translate([r_tot + x_spacing, y_spacing, 0])
        cylinder(h=h, r=r);
        translate([r_tot + x_spacing, -y_spacing, 0])
        cylinder(h=h, r=r);
        linear_extrude(h)
        polygon([
             [r_tot-r, -spacing],
             [r_tot-r, spacing],
             [r_tot + r*c2, spacing + r*c1],
             [r_tot + x_spacing + r*c2, y_spacing + r*c1],
             [r_tot + x_spacing + r, y_spacing],
             [r_tot + x_spacing + r, -y_spacing],
             [r_tot + x_spacing + r*c2, -y_spacing - r*c1],
             [r_tot + r*c2, -spacing - r*c1]
        ]);
    }
}

module TopGap() {
    c1 = sqrt(3)/2;
    c2 = 0.5;
    translate([0, 0, h-offset_top])
    linear_extrude(2*h)
    polygon([
        [r_tot - offset_extra, spacing],
        [r_tot - c1*offset_extra, spacing + c2*offset_extra],
        [r_tot + c2*offset_extra, spacing + c1*offset_extra],
        [r_tot + x_spacing + c1*offset_extra, y_spacing + c2*offset_extra],
        [r_tot + x_spacing + offset_extra, y_spacing],
        [r_tot + x_spacing + offset_extra, -y_spacing],
        [r_tot + x_spacing + c1*offset_extra, -y_spacing - c2*offset_extra],
        [r_tot + c2*offset_extra, -spacing - c1*offset_extra],
        [r_tot - c2*offset_extra, -spacing - c2*offset_extra],
        [r_tot - offset_extra, -spacing],
    ]);
}

module WireHole() {
    translate([-thickness/2+c2*r_tot + wire_x_offset, spacing - c1*r_tot, 0])
    cylinder(r=inter_r, h=3*h, center=true);
}

module Oring() {
    r1 = d/2 + gap_side + thickness/2 + oring/2;
    r2 = d/2 + gap_side + thickness/2 - oring/2;
    translate([0, 0, h-oring_hfact*oring])
    difference() {
            DShape(r1);
            DShape(r2);
    }
}


module Fillet(r) {
    difference() {
        linear_extrude(3*h, center=true) square(2*r, center=true);
        union() {
            translate([r, r, 0])
            linear_extrude(4*h, center=true)
            circle(r, $fn=40);
            translate([r, -r, 0])
            linear_extrude(4*h, center=true)
            circle(r, $fn=40);
            translate([-r, -r, 0])
            linear_extrude(4*h, center=true)
            circle(r, $fn=40);
            translate([-r, r, 0])
            linear_extrude(4*h, center=true)
            circle(r, $fn=40);
        }
    }
};

module AttachDip(l, x, y, z, flip) {
    translate([x - l/2, y, z])
    rotate([-45 + 180*flip, 0, 0])
    cube(l_attach);
}

module LidSide(x, y, flip) {
    difference() {
        translate([x, y, z_attach-thickness/2])
        rotate([0, 0, 180*flip])
        linear_extrude(h + 2*thickness - z_attach)
        polygon([[-l_attach/2, -thickness+eps], [l_attach/2, -thickness+eps], [l_attach/2, w_attach], [-l_attach/2, w_attach]]);
        translate([x+l_attach/2, y+(1-2*flip)*w_attach, 0]) Fillet(w_attach);
        translate([x-l_attach/2, y+(1-2*flip)*w_attach, 0]) Fillet(w_attach);
    }
}

module Box() {
    difference() {
        DShape(r_tot);
        translate([r_tot, spacing, 0])
        BatteryHole();
        translate([r_tot, -spacing, 0])
        BatteryHole();
        translate([r_tot, 0, 0])
        BatteryHole();
        translate([r_tot + x_spacing, y_spacing, 0])
        BatteryHole();
        translate([r_tot + x_spacing, -y_spacing, 0])
        BatteryHole();
        TopGap();
        WireHole();
        Oring();
    }
}

module Lid() {
    //offset_top
    
    rotate([0, 0, 90])
    LidSide(0, 0, 0);
    translate([2*r_tot + x_spacing, 0, 0])
    rotate([0, 0, -90])
    LidSide(0, 0, 0);
}

Box();
//Lid();