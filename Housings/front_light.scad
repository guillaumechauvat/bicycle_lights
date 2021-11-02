// LED dimensions
w_led = 17;
h_led = 14;

// diameter of cooling / LED base where the parabola is cut
d0 = 18.5;
// total inside diameter
// The lens diameter will be dmax+thickness
dmax = 58;

// walls
thickness = 3;
fillet = 1;

// base size
w_base = 40;

// handlebar interface
d_handlebar = 22.5;
y_handlebar = -33.8;
z_handlebar = 20;
w_handlebar = 15;
t_handlebar = 4;
// opening angle
theta = 60;

// gaps for printing tolerance
gap = 0.2;

// lens depth/thickness
d_lens = 1.5;

// wire holes diameter
d_wire_in = 2;
d_wire_out = 3;

// automatic variables
outside_scale = (dmax + 2*thickness)/dmax;
eps=1e-3;
f = d0/4;
h = dmax*dmax/(16*f);

// generates a paraboloid of focal length f, limited to ratio r
module Paraboloid(f, r, n=40) {
    dx = r/n;
    h = r*r/(4*f);
    // use the trick to generate surfaces by functions from Parkinbot in https://forum.openscad.org/Computing-polygon-by-function-td1432.html
    rotate_extrude(angle=360, $fn=150)
    for (x = [0 : dx : r-dx]) {
        polygon([[x, x*x/(4*f)], [x+dx, (x+dx)*(x+dx)/(4*f)], [x+dx, h], [x, h]]);
    }
}

module WireHole(d, t) {
    rotate([0, 90, 0])
    linear_extrude(t, center=true) {
        circle(d/2, $fn=30);
        translate([d, 0, 0])
        scale([2, 1, 1])
        square(d, center=true);
    }
}

module DoubleWireHole(d, t) {
    translate([0, -d/2, 0])
    WireHole(d, t);
    translate([0, d/2, 0])
    WireHole(d, t);
    translate([0, 0, d/2])
    rotate([0, 90, 0])
    linear_extrude(t, center=true)
    translate([d, 0, 0])
    scale([2, 1, 1])
    square(d, center=true);
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

module CircleHolder() {
    translate([0, y_handlebar, z_handlebar])
    rotate([0, 90, 0])
    difference() {
        cylinder(h=w_handlebar, r=d_handlebar/2+t_handlebar, center=true, $fn=150);
        cylinder(h=2*w_handlebar, r=d_handlebar/2, center=true, $fn=150);
        linear_extrude(2*w_handlebar, center=true)
        polygon([[0, 0], [2*d_handlebar*tan(theta), -2*d_handlebar], [-2*d_handlebar*tan(theta), -2*d_handlebar]]);
    }
};

module BulkHolder() {
    difference() {
        rotate([0, 90, 0])
        rotate([0, 0, 90])
        linear_extrude(w_handlebar, center=true)
        polygon([[-45, f],
            [-w_base/2, f],
            [-w_base/2, h],
            [-dmax/2-thickness, h],
            [y_handlebar-d_handlebar/2, z_handlebar+d_handlebar/2]
        ]);
        translate([0, y_handlebar, z_handlebar])
        rotate([0, 90, 0]) {
            cylinder(h=2*w_handlebar, r=d_handlebar/2, center=true, $fn=150);
            linear_extrude(2*w_handlebar, center=true)
            polygon([[0, 0], [2*d_handlebar*tan(theta), -2*d_handlebar], [-2*d_handlebar*tan(theta), -2*d_handlebar]]);
        }
    }
}

difference() {
    union() {
        // empirical value on z, I'm too lazy to do the math right now, it's midnight
        translate([0, 0, -1.62*thickness])
        scale([outside_scale, outside_scale, outside_scale])
        Paraboloid(f, dmax/2);
        // box
        difference() {
            linear_extrude(h-eps)
            square(w_base, center=true);
            translate([0, 0, -h])
            linear_extrude(2*h)
            square(w_base-2*thickness, center=true);
            translate([w_base/2, w_base/2, 0])
            Fillet(fillet);
            translate([-w_base/2, w_base/2, 0])
            Fillet(fillet);
            translate([-w_base/2, -w_base/2, 0])
            Fillet(fillet);
            translate([w_base/2, -w_base/2, 0])
            Fillet(fillet);
        }
        // handlebar holder
        BulkHolder();
    }
    Paraboloid(f, dmax/2+eps);
    // cooling block plane
    translate([0, 0, -f])
    linear_extrude(2*f)
    square(2*w_base, center=true);
    // place for LED
    translate([0, 0, -2*f])
    scale([w_led+2*gap, h_led+2*gap, 1])
    linear_extrude(4*f)
    square(1, center=true);
    // wires
    translate([w_led/2-d_wire_in/2, -h_led/2, f+d_wire_in])
    rotate([0, 0, 90])
    WireHole(d_wire_in, 4*thickness);
    rotate([0, 0, 180])
    translate([w_led/2-d_wire_in/2, -h_led/2, f+d_wire_in])
    WireHole(d_wire_in, 4*thickness);
    
    // outside wire holes merged together
    translate([-0.55*w_base/2, -w_base/2, f+0.6*d_wire_out])
    rotate([0, 0, 90])
    DoubleWireHole(d_wire_out, 3*thickness);
    
    // place for inserting lens
    translate([0, 0, h-d_lens])
    cylinder(h=2*d_lens, r=dmax/2+thickness/2, $fn=150);
}