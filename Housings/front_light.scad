// LED dimensions
w_led = 15;
h_led = 12;

// diameter of cooling / LED base where the parabola is cut
d0 = 17;
// total diameter
dmax = 55;

// wall thickness
thickness = 3;

// base size
w_base = 40;

// gaps for printing tolerance
gap = 0.2;

// wire holes diameter
d_wire_in = 2;
d_wire_out = 3;

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

outside_scale = (dmax + 2*thickness)/dmax;
eps=1e-3;
f = d0/4;
h = dmax*dmax/(16*f);
difference() {
    union() {
        // empirical value on z, I'm too lazy to do the math right now, it's midnight
        translate([0, 0, -1.62*thickness])
        scale([outside_scale, outside_scale, outside_scale])
        Paraboloid(f, dmax/2);
        difference() {
            linear_extrude(h-eps)
            square(w_base, center=true);
            translate([0, 0, -h])
            linear_extrude(2*h)
            square(w_base-2*thickness, center=true);
        }
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
    translate([d_wire_out, -w_base/2, f+0.7*d_wire_out])
    rotate([0, 0, 90])
    WireHole(d_wire_out, 2*thickness);
    translate([-d_wire_out, -w_base/2, f+0.7*d_wire_out])
    rotate([0, 0, 90])
    WireHole(d_wire_out, 2*thickness);
}