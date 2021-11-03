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
$fn=80;


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
            union() {
                translate([r_tot, spacing, 0])
                cylinder(h=h, r=r1);
                translate([r_tot, -spacing, 0])
                cylinder(h=h, r=r1);
                translate([r_tot + x_spacing, y_spacing, 0])
                cylinder(h=h, r=r1);
                translate([r_tot + x_spacing, -y_spacing, 0])
                cylinder(h=h, r=r1);
                linear_extrude(h)
                polygon([
                    [r_tot-r1, -spacing],
                    [r_tot-r1, spacing],
                    [r_tot + r1*c2, spacing + r1*c1],
                    [r_tot + x_spacing + r1*c2, y_spacing + r1*c1],
                    [r_tot + x_spacing + r1, y_spacing],
                    [r_tot + x_spacing + r1, -y_spacing],
                    [r_tot + x_spacing + r1*c2, -y_spacing - r1*c1],
                    [r_tot + r1*c2, -spacing - r1*c1]
                ]);
        }
            union() {
                translate([r_tot, spacing, 0])
                cylinder(h=3*h, r=r2, center=true);
                translate([r_tot, -spacing, 0])
                cylinder(h=3*h, r=r2, center=true);
                translate([r_tot + x_spacing, y_spacing, 0])
                cylinder(h=3*h, r=r2, center=true);
                translate([r_tot + x_spacing, -y_spacing, 0])
                cylinder(h=3*h, r=r2, center=true);
                linear_extrude(3*h, center=true)
                polygon([
                    [r_tot-r2, -spacing],
                    [r_tot-r2, spacing],
                    [r_tot + r2*c2, spacing + r2*c1],
                    [r_tot + x_spacing + r2*c2, y_spacing + r2*c1],
                    [r_tot + x_spacing + r2, y_spacing],
                    [r_tot + x_spacing + r2, -y_spacing],
                    [r_tot + x_spacing + r2*c2, -y_spacing - r2*c1],
                    [r_tot + r2*c2, -spacing - r2*c1]
                ]);
            }
    }
}

module Box() {
    difference() {
        union() {
            translate([r_tot, spacing, 0])
            cylinder(h=h, r=r_tot);
            translate([r_tot, -spacing, 0])
            cylinder(h=h, r=r_tot);
            translate([r_tot + x_spacing, y_spacing, 0])
            cylinder(h=h, r=r_tot);
            translate([r_tot + x_spacing, -y_spacing, 0])
            cylinder(h=h, r=r_tot);
            linear_extrude(h)
            polygon([
                [0, -spacing],
                [0, spacing],
                [r_tot + r_tot*c2, spacing + r_tot*c1],
                [r_tot + x_spacing + r_tot*c2, y_spacing + r_tot*c1],
                [r_tot + x_spacing + r_tot, y_spacing],
                [r_tot + x_spacing + r_tot, -y_spacing],
                [r_tot + x_spacing + r_tot*c2, -y_spacing - r_tot*c1],
                [r_tot + r_tot*c2, -spacing - r_tot*c1]
            ]);
        }
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

Box();
//Oring();