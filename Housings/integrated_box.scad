// electronics box dimensions
lz = 92;
ly = 71;
lx = 30;

// dimensions of my "18650" batteries. In practice they're closer to 18700.
d = 18.5;
h = 70.5; // with the button top
h_body = 69.3;
d_button = 6.5;
gap_side = 0.5;
gap_h_bottom = 3;
gap_h_top = 5;
offset_top = 5;
offset_extra = 8;
thickness = 4;
int_thickness = 2.5;
inter_r = 2.5;
wire_x_offset = 2;
oring = 2;
oring_hfact = 1.5;

// attach mechanism
z_attach = h - 2.5*thickness;
l_attach = 12;
w_attach = 4;
y_attach = 17;
gap = 0.2;

// wire hole size
w_hole = 14;
h_hole = 6;
fillet_hole = 2;

// O-ring protrusion
h_oring = 0.3;

// text params
font = "Liberation Sans";
text_size = 9;
text_depth = 0.2;

// connector params
spring_d = 12;
button_d = 9;
connector_depth = 0.5;

// precision params
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
extra_x = lx + thickness;

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

// base shape, with an extra length dx
module DShape(r, l, dx) {
    union() {
        translate([r_tot, spacing, 0])
        cylinder(h=l, r=r);
        translate([r_tot, -spacing, 0])
        cylinder(h=l, r=r);
        translate([r_tot + x_spacing, y_spacing, 0])
        cylinder(h=l, r=r);
        translate([r_tot + x_spacing, -y_spacing, 0])
        cylinder(h=l, r=r);
        translate([r_tot - dx, spacing, 0])
        cylinder(h=l, r=r);
        translate([r_tot - dx, -spacing, 0])
        cylinder(h=l, r=r);
        linear_extrude(l)
        polygon([
            [r_tot-r-dx, -spacing],
            [r_tot-r-dx, spacing],
            [r_tot - dx, spacing + r],
            [r_tot, spacing + r],
            [r_tot + r*c2, spacing + r*c1],
            [r_tot + x_spacing + r*c2, y_spacing + r*c1],
            [r_tot + x_spacing + r, y_spacing],
            [r_tot + x_spacing + r, -y_spacing],
            [r_tot + x_spacing + r*c2, -y_spacing - r*c1],
            [r_tot + r*c2, -spacing - r*c1],
            [r_tot, -spacing - r],
            [r_tot - dx, -spacing - r],
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

module Oring() {
    r1 = d/2 + gap_side + thickness/2 + oring/2;
    r2 = d/2 + gap_side + thickness/2 - oring/2;
    translate([0, 0, h-oring_hfact*oring])
    difference() {
        DShape(r1, h, extra_x);
        translate([0, 0, -h/2])
        DShape(r2, 2*h, extra_x);
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

module Text(l) {
    translate([0, -text_size/2, -text_depth])
	linear_extrude(height = 2*text_depth) {
		text(l, size=text_size, font=font, halign="center", valign="bottom");
	}
}

module AttachDip(l, x, y, z, flip) {
    translate([x, y-l/2, z])
    rotate([0, 45 - 180*flip + 180, 0])
    cube(l);
}

module LidSide(x, y, flip) {
    z0 = z_attach-thickness/2;
    difference() {
        translate([x, y, z0])
        rotate([0, 0, 180*flip])
        linear_extrude(h + gap_h_top + thickness - z0)
        polygon([[-l_attach/2, -thickness+eps], [l_attach/2, -thickness+eps], [l_attach/2, w_attach], [-l_attach/2, w_attach]]);
        translate([x+l_attach/2, y+(1-2*flip)*w_attach, 0]) Fillet(w_attach);
        translate([x-l_attach/2, y+(1-2*flip)*w_attach, 0]) Fillet(w_attach);
    }
}

// display +/- battery signs
module Polarities() {
    z_text = z_attach-1.5*thickness;
    translate([thickness - int_thickness, spacing, z_text])
    rotate([0, 0, -90])
    rotate([90, 0, 0])
    Text("+");
    translate([thickness - int_thickness, 0, z_text])
    rotate([0, 0, -90])
    rotate([90, 0, 0])
    Text("+");
    translate([thickness - int_thickness, -spacing, z_text])
    rotate([0, 0, -90])
    rotate([90, 0, 0])
    Text("−");
    translate([2*r_tot + x_spacing, -spacing/2, z_text])
    rotate([0, 0, 90])
    rotate([90, 0, 0])
    Text("+");
    translate([2*r_tot + x_spacing, spacing/2, z_text])
    rotate([0, 0, 90])
    rotate([90, 0, 0])
    Text("−");
}

module BatteryWall() {
    difference() {
        dtot = d + 2*gap_side + 2*int_thickness;
        cylinder(h=h, d=dtot);
        BatteryHole();
    }
}

module Box() {
    color([0.7, 1, 0.7])
    union() {
        difference() {
            union() {
                // outside wall
                difference() {
                    DShape(r_tot, h, extra_x);
                    translate([0, 0, -h/2])
                    DShape(r_tot - thickness, 2*h, extra_x);
                }
                translate([r_tot, spacing, 0])
                BatteryWall();
                translate([r_tot, -spacing, 0])
                BatteryWall();
                translate([r_tot, 0, 0])
                BatteryWall();
                translate([r_tot + x_spacing, y_spacing, 0])
                BatteryWall();
                translate([r_tot + x_spacing, -y_spacing, 0])
                BatteryWall();
            }
            //TopGap();
            WireHole();
            Oring();
            AttachDip(0.95*l_attach, 0.3*thickness + gap, y_attach, z_attach, 0);
            AttachDip(0.95*l_attach, 0.3*thickness + gap, -y_attach, z_attach, 0);
            AttachDip(0.95*l_attach, 2*r_tot + x_spacing - 0.3*thickness - gap, 0, z_attach, 1);
        }
        Polarities();
    }
}


module BottomConnectors() {
    h_connector = -gap_h_bottom - connector_depth;
    translate([r_tot, spacing, ])
    cylinder(d=spring_d, h=thickness);
    translate([r_tot, 0, h_connector])
    cylinder(d=spring_d, h=thickness);
    translate([r_tot, -spacing, h_connector])
    cylinder(d=button_d, h=thickness);
    translate([r_tot + x_spacing, y_spacing, h_connector])
    cylinder(d=button_d, h=thickness);
    translate([r_tot + x_spacing, -y_spacing, h_connector])
    cylinder(d=spring_d, h=thickness);
}

module TopConnectors() {
    h_connector = h + gap_h_top - thickness + connector_depth;
    translate([r_tot, spacing, h_connector])
    cylinder(d=button_d, h=thickness);
    translate([r_tot, 0, h_connector])
    cylinder(d=button_d, h=thickness);
    translate([r_tot, -spacing, h_connector])
    cylinder(d=spring_d, h=thickness);
    translate([r_tot + x_spacing, y_spacing, h_connector])
    cylinder(d=spring_d, h=thickness);
    translate([r_tot + x_spacing, -y_spacing, h_connector])
    cylinder(d=button_d, h=thickness);
}

module WireHole() {
    difference() {
        translate([-lx, 0, h_hole/2 - gap_h_bottom])
        cube([4*thickness, w_hole, h_hole], center=true);
        translate([0, w_hole/2, h_hole/2])
        rotate([0, 90, 0])
        Fillet(fillet_hole);
        translate([0, w_hole/2, -h_hole/2])
        rotate([0, 90, 0])
        Fillet(fillet_hole);
        translate([0, -w_hole/2, h_hole/2])
        rotate([0, 90, 0])
        Fillet(fillet_hole);
        translate([0, -w_hole/2, -h_hole/2])
        rotate([0, 90, 0])
        Fillet(fillet_hole);
    }
}

module Lid() {
    color([0.7, 0.7, 1])
    union() {
        // main body
        difference() {
            // bulk
            translate([0, 0, h-thickness/2])
            DShape(r_tot + thickness/2, thickness + gap_h_top + thickness/2, extra_x);
            // main void
            DShape(r_tot - thickness, h + gap_h_top, extra_x);
            // border
            DShape(r_tot + gap, h, extra_x);
            // connectors shape
            TopConnectors();
        }
        // clips
        difference() {
            union() {
                rotate([0, 0, 90])
                LidSide(y_attach, extra_x, 0);
                rotate([0, 0, 90])
                LidSide(-y_attach, extra_x, 0);
                translate([2*r_tot + x_spacing, 0, 0])
                rotate([0, 0, -90])
                LidSide(0, 0, 0);
            }
            DShape(r_tot + gap, h + gap_h_top, extra_x);
        }
        // clips teeth
        intersection() {
            AttachDip(0.95*l_attach, 0.3*thickness - extra_x, y_attach, z_attach, 0);
            rotate([0, 0, 90])
            LidSide(y_attach, extra_x, 0);
        }
        intersection() {
            AttachDip(0.95*l_attach, 0.3*thickness - extra_x, -y_attach, z_attach, 0);
            rotate([0, 0, 90])
            LidSide(-y_attach, extra_x, 0);
        }
        intersection() {
            AttachDip(0.95*l_attach, 2*r_tot + x_spacing - 0.3*thickness, 0, z_attach, 1);
            translate([2*r_tot + x_spacing, 0, 0])
            rotate([0, 0, -90])
            LidSide(0, 0, 0);
        }
    }
}

module Bottom() {
    color([0.7, 0.7, 1])
    difference() {
        translate([0, 0, -thickness - gap_h_bottom])
        DShape(r_tot + thickness/2, 1.5*thickness + gap_h_bottom, extra_x);
        // main hole
        translate([0, 0, -gap_h_bottom])
        DShape(r_tot - thickness, thickness + gap_h_bottom, extra_x);
        // border
        DShape(r_tot + gap, thickness + gap_h_bottom, extra_x);
        // connectors location
        BottomConnectors();
        // hole for I/O wires
        WireHole();
    }
}

// actual O ring, printed in flexible plastic
module OringFill() {
    color([1, 0, 0])
    intersection() {
        r1 = d/2 + gap_side + thickness/2 + oring/2 - gap;
        r2 = d/2 + gap_side + thickness/2 - oring/2 + gap;
        translate([0, 0, h-oring_hfact*oring])
        difference() {
            DShape(r1, h, extra_x);
            translate([0, 0, -h/2])
            DShape(r2, 2*h, extra_x);
        }
        translate([-10*d, -10*d, -h])
        cube([20*d, 20*d, 2*h + h_oring]);
    }
}

Box();
Lid();
Bottom();
OringFill();
