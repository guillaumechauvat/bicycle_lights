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
inter_r = 2.5;
wire_x_offset = 2;
oring = 2;
oring_hfact = 0.8;

// attach mechanism
z_attach = h - 2.5*thickness;
l_attach = 12;
w_attach = 4;
y_attach = 17;
gap = 0.2;

// wire hole size
w_wire = 3;

// O-ring protrusion
h_oring = 0.2;

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

module DShape(r, l) {
    union() {
        translate([r_tot, spacing, 0])
        cylinder(h=l, r=r);
        translate([r_tot, -spacing, 0])
        cylinder(h=l, r=r);
        translate([r_tot + x_spacing, y_spacing, 0])
        cylinder(h=l, r=r);
        translate([r_tot + x_spacing, -y_spacing, 0])
        cylinder(h=l, r=r);
        linear_extrude(l)
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
        DShape(r1, h);
        translate([0, 0, -h/2])
        DShape(r2, 2*h);
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
    translate([0, spacing, z_text])
    rotate([0, 0, -90])
    rotate([90, 0, 0])
    Text("+");
    translate([0, 0, z_text])
    rotate([0, 0, -90])
    rotate([90, 0, 0])
    Text("+");
    translate([0, -spacing, z_text])
    rotate([0, 0, -90])
    rotate([90, 0, 0])
    Text("???");
    translate([2*r_tot + x_spacing, -spacing/2, z_text])
    rotate([0, 0, 90])
    rotate([90, 0, 0])
    Text("+");
    translate([2*r_tot + x_spacing, spacing/2, z_text])
    rotate([0, 0, 90])
    rotate([90, 0, 0])
    Text("???");
}

module Box() {
    difference() {
        DShape(r_tot, h);
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
        AttachDip(0.95*l_attach, 0.3*thickness + gap, y_attach, z_attach, 0);
        AttachDip(0.95*l_attach, 0.3*thickness + gap, -y_attach, z_attach, 0);
        AttachDip(0.95*l_attach, 2*r_tot + x_spacing - 0.3*thickness - gap, 0, z_attach, 1);
    }
    Polarities();
}


module BottomConnectors() {
    translate([r_tot, spacing, -gap_h_bottom - connector_depth])
    cylinder(d=spring_d, h=thickness);
    translate([r_tot, 0, -gap_h_bottom - connector_depth])
    cylinder(d=spring_d, h=thickness);
    translate([r_tot, -spacing, -gap_h_bottom - connector_depth])
    cylinder(d=button_d, h=thickness);
    translate([r_tot + x_spacing, y_spacing, -gap_h_bottom - connector_depth])
    cylinder(d=button_d, h=thickness);
    translate([r_tot + x_spacing, -y_spacing, -gap_h_bottom - connector_depth])
    cylinder(d=spring_d, h=thickness);
}

module Lid() {
    difference() {
        translate([0, 0, h-thickness/2])
        DShape(r_tot + thickness/2, thickness + gap_h_top + thickness/2);
        DShape(r_tot - thickness, h + gap_h_top);
        DShape(r_tot + gap, h);
    }
    difference() {
        union() {
            rotate([0, 0, 90])
            LidSide(y_attach, 0, 0);
            rotate([0, 0, 90])
            LidSide(-y_attach, 0, 0);
            translate([2*r_tot + x_spacing, 0, 0])
            rotate([0, 0, -90])
            LidSide(0, 0, 0);
        }
        DShape(r_tot + gap, h + gap_h_top);
    }
    intersection() {
        AttachDip(0.95*l_attach, 0.3*thickness, y_attach, z_attach, 0);
        rotate([0, 0, 90])
        LidSide(y_attach, 0, 0);
    }
    intersection() {
        AttachDip(0.95*l_attach, 0.3*thickness, -y_attach, z_attach, 0);
        rotate([0, 0, 90])
        LidSide(-y_attach, 0, 0);
    }
    intersection() {
        AttachDip(0.95*l_attach, 2*r_tot + x_spacing - 0.3*thickness, 0, z_attach, 1);
        translate([2*r_tot + x_spacing, 0, 0])
        rotate([0, 0, -90])
        LidSide(0, 0, 0);
    }
}

module Bottom() {
    difference() {
        translate([0, 0, -thickness - gap_h_bottom])
        DShape(r_tot + thickness/2, 1.5*thickness + gap_h_bottom);
        // main hole
        translate([0, 0, -gap_h_bottom])
        DShape(r_tot - thickness, thickness + gap_h_bottom);
        // border
        DShape(r_tot + gap, thickness + gap_h_bottom);
        // place for wires
        translate([0, 0, w_wire/2])
        cube([3*thickness, w_wire, 2*w_wire], center=true);
        BottomConnectors();
    }
}

// actual O ring, printed in flexible plastic
module OringFill() {
    intersection() {
        r1 = d/2 + gap_side + thickness/2 + oring/2 - gap;
        r2 = d/2 + gap_side + thickness/2 - oring/2 + gap;
        translate([0, 0, h-oring_hfact*oring])
        difference() {
            DShape(r1, h);
            translate([0, 0, -h/2])
            DShape(r2, 2*h);
        }
        translate([-10*d, -10*d, 0])
        cube([20*d, 20*d, h + h_oring]);
    }
}

Box();
Lid();
Bottom();
OringFill();
