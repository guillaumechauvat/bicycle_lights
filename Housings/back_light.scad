lx = 71;
ly = 27;
lz = 16;
h_acrylic = 3.3;
h_extra = 1;
indent = 1;
gap = 0.3;
thickness = 3;
hole_h = 3.5;
hole_w = 1.8;
fillet = 3;
eps = 1e-3;
// handlebar interface
d_handlebar = 22.5;
w_handlebar = 15;
t_handlebar = 6;
// opening angle
theta = 60;

module Fillet(r) {
    difference() {
        linear_extrude(10*lz, center=true) square(2*r, center=true);
        union() {
            translate([r, r, 0])
            linear_extrude(12*lz, center=true)
            circle(r, $fn=40);
            translate([r, -r, 0])
            linear_extrude(12*lz, center=true)
            circle(r, $fn=40);
            translate([-r, -r, 0])
            linear_extrude(12*lz, center=true)
            circle(r, $fn=40);
            translate([-r, r, 0])
            linear_extrude(12*lz, center=true)
            circle(r, $fn=40);
        }
    }
};

module Interior() {
    union() {
        translate([0, 0, lz+thickness-gap])
        cube([lx+2*gap, ly+2*gap, 2*lz], center=true);
        // place for acrylic
        translate([0, 0, lz + thickness + h_acrylic])
        cube([lx+2*gap+2*indent, ly+2*gap+2*indent, 2*h_acrylic], center=true);
    }
}

module WireHole() {
    translate([lx/2 - hole_h/2 + gap - thickness, ly/2, thickness + hole_w/2 - gap])
    cube([hole_h, 3*thickness, hole_w], center=true);
}

module Holder() {
    translate([0, ly/2 + thickness - w_handlebar/2, 0])
    rotate([-90, 0, 0])
    difference() {
        union() {
            cube([d_handlebar+2*t_handlebar, d_handlebar, w_handlebar], center=true);
            translate([0, d_handlebar/2, 0])
            cylinder(d=d_handlebar+2*t_handlebar, h=w_handlebar, center=true, $fn=80);
        }
        translate([0, d_handlebar/2, 0]) {
            cylinder(d=d_handlebar, h=3*lz, center=true, $fn=80);
            linear_extrude(3*lz, center=true)
            polygon([
                [0, 0],
                [-2*w_handlebar*tan(theta), 2*w_handlebar],
                [2*w_handlebar*tan(theta), 2*w_handlebar]
            ]);
        }
    }
}

module Box() {
    difference() {
        union() {
            translate([0, 0, lz/2 + thickness + h_acrylic/2 + h_extra/2])
            scale([lx+2*thickness, ly+2*thickness, lz+2*thickness + h_acrylic + h_extra])
            cube(1, center=true);
            Holder();
        }
        Interior();
        // remove the top
        translate([0, 0, lz+2*thickness + h_acrylic + h_extra])
        cube([2*lx, 2*ly, 2*thickness], center=true);
        translate([-lx/2-thickness, -ly/2-thickness, 0])
        Fillet(fillet);
        translate([lx/2+thickness, -ly/2-thickness, 0])
        Fillet(fillet);
        translate([lx/2+thickness, ly/2+thickness, 0])
        Fillet(fillet);
        translate([-lx/2-thickness, ly/2+thickness, 0])
        Fillet(fillet);
        WireHole();
    }
}

Box();
