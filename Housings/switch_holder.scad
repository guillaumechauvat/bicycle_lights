lx = 13;
ly = 13;
lz = 22;
thickness = 2.5;
hole_d = 6;
hole_h = 7.5;
hole2_d = 8;
hole2_h = 3;
gap = 0.2;
wire_d = 4;
fillet=2.0;

// handlebar interface
d_handlebar = 22.5;
w_handlebar = ly + 2*thickness;
t_handlebar = 5;
// opening angle
theta = 60;

$fn = 80;

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

module Holder() {
    translate([0, 0, 0])
    rotate([-90, 0, 0])
    difference() {
        union() {
            difference() {
                cube_h = d_handlebar/2 + lz + hole_h;
                translate([0, -cube_h/2+d_handlebar/2, 0])
                cube([lx+2*thickness, cube_h, w_handlebar], center=true);
                translate([ly/2 + thickness, -cube_h+d_handlebar/2, 0])
                Fillet(fillet);
                translate([-ly/2 - thickness, -cube_h+d_handlebar/2, 0])
                Fillet(fillet);
                rotate([0, 90, 0])
                translate([lx/2 + thickness, -cube_h+d_handlebar/2, 0])
                Fillet(fillet);
                rotate([0, 90, 0])
                translate([-lx/2 - thickness, -cube_h+d_handlebar/2, 0])
                Fillet(fillet);
                rotate([90, 0, 0])
                translate([-lx/2 - thickness, ly/2+thickness, 0])
                Fillet(fillet);
                rotate([90, 0, 0])
                translate([-lx/2 - thickness, -ly/2-thickness, 0])
                Fillet(fillet);
                rotate([90, 0, 0])
                translate([lx/2 + thickness, ly/2+thickness, 0])
                Fillet(fillet);
                rotate([90, 0, 0])
                translate([lx/2 + thickness, -ly/2-thickness, 0])
                Fillet(fillet);
            }
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

module SwitchHole() {
    translate([0, 0, 0])
    cube([lx+2*gap, ly+2*gap, 2*lz+2*gap], center = true);
    cylinder(d=hole_d, h=5*lz);
    translate([0, 0, lz])
    cylinder(d=hole2_d, h=hole2_h);
}

module WireHole() {
    rotate([90, 0, 0])
    cylinder(d=wire_d, h=3*ly);
}

module Full() {
    difference() {
        Holder();
        SwitchHole();
        WireHole();
    }
}

Full();