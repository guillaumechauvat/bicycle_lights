lx = 25;
ly = 40;
lz = 40;
lz_led = 17;
gap = 0.3;
thickness = 3;
bottom_thickness = 5;
hole_w = 3;
h_lens = 3;
h_extra = 1;
eps = 1e-3;
// handlebar interface
d_handlebar = 22.5;
w_handlebar = 15;
t_handlebar = 6;
// opening angle
theta = 60;

module Interior() {
    translate([-lx/2, 0, lz/2])
    rotate([0, 90, 0])
    translate([0, 0, -eps])
    cylinder(d1=lz_led, d2=lz-2*thickness, h=lx+2*eps, $fn=80);
    translate([-lx/2, 0, lz/2])
    cube([3*lx, lz_led, lz_led], center=true);
    translate([-lx/2, 0, lz/2])
    cube([2*hole_w, ly-2*bottom_thickness, lz-2*bottom_thickness], center=true);
    translate([lx/2, 0, lz/2])
    rotate([0, 90, 0])
    cylinder(h=2*(h_lens+h_extra), d=lz-thickness, center=true, $fn=80);
}

module WireHole() {
    translate([-lx/2, ly/2-bottom_thickness-hole_w, 0])
    cube([2*hole_w, 2*hole_w, 3*bottom_thickness], center=true);
}

module Holder() {
    difference() {
        union() {
            linear_extrude(w_handlebar)
            polygon([
                [-lx/2, ly/2],
                [lx/2, ly/2],
                [d_handlebar/2+t_handlebar*0.95, ly/2+d_handlebar/2],
                [-d_handlebar/2-t_handlebar*0.95, ly/2+d_handlebar/2],
            ]);
            translate([0, ly/2+thickness+d_handlebar/2+gap, w_handlebar/2])
            cylinder(d=d_handlebar+2*t_handlebar, h=w_handlebar, center=true, $fn=80);
        }
        translate([0, ly/2+thickness+d_handlebar/2+gap, w_handlebar/2]) {
            cylinder(d=d_handlebar, h=3*lz, center=true, $fn=80);
            linear_extrude(3*lz, center=true)
            polygon([[0, 0], [-2*w_handlebar*tan(theta), 2*w_handlebar], [2*w_handlebar*tan(theta), 2*w_handlebar]]);
        }
    }
}

module Bezel() {
    translate([-lx/2, 0, lz/2])
    rotate([0, 90, 0])
    difference() {
        cube(6*lz, center=true);
        cylinder(d1=lz*sqrt(2), d2=lz, h=lx+2*eps, $fn=80);
        translate([0, 0, -lx/2])
        cube([lz, 2*lz, 2*lx]);
    }
}

module Box() {
    intersection() {
        difference() {
            union() {
                translate([0, 0, lz/2])
                scale([lx, ly, lz])
                cube(1, center=true);
                Holder();
            }
            Interior();
            // remove the top
            translate([0, 0, lz+2*thickness + h_lens + h_extra])
            cube([2*lx, 2*ly, 2*thickness], center=true);
            WireHole();
            Bezel();
        }
    }
}

Box();