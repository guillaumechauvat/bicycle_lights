lx = 91;
ly = 70;
lz = 24;

// wall thickness
thickness = 4;

// hole size
w_hole = 16;
h_hole = 8;

// fillet radius
fillet = 3;


lxt = lx + 2*thickness;
lyt = ly + 2*thickness;

module Fillet(r) {
    difference() {
        linear_extrude(3*lz, center=true) square(2*r, center=true);
        union() {
            translate([r, r, 0])
            linear_extrude(4*lz, center=true)
            circle(r, $fn=40);
            translate([r, -r, 0])
            linear_extrude(4*lz, center=true)
            circle(r, $fn=40);
            translate([-r, -r, 0])
            linear_extrude(4*lz, center=true)
            circle(r, $fn=40);
            translate([-r, r, 0])
            linear_extrude(4*lz, center=true)
            circle(r, $fn=40);
        }
    }
};

module Hole() {
    translate([lx/2-thickness, 0, lz+h_hole/2])
    rotate([0, 90, 0])
    difference() {
        linear_extrude(3*thickness)
        polygon([[-h_hole, -w_hole/2], [-h_hole, w_hole/2], [h_hole, w_hole/2], [h_hole, -w_hole/2]]);
        translate([h_hole, w_hole/2])
        Fillet(fillet);
        translate([h_hole, -w_hole/2])
        Fillet(fillet);
    }
};

module Box() {
    difference() {
        linear_extrude(lz + thickness)
        polygon([[-lxt/2, -lyt/2], [lxt/2, -lyt/2], [lxt/2, lyt/2], [-lxt/2, lyt/2]]);
        translate([0, 0, thickness])
        linear_extrude(lz + thickness)
        polygon([[-lx/2, -ly/2], [lx/2, -ly/2], [lx/2, ly/2], [-lx/2, ly/2]]);
        Hole();
        translate([-lxt/2, -lyt/2, 0]) Fillet(fillet);
        translate([-lxt/2, lyt/2, 0]) Fillet(fillet);
        translate([lxt/2, lyt/2, 0]) Fillet(fillet);
        translate([lxt/2, -lyt/2, 0]) Fillet(fillet);
    }
};
//Hole();
Box();


