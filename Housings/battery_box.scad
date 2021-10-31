lx = 63;
ly = 42;
lz = 80;
gap = 0.3;
thickness = 3;
fillet = 3;
eps = 1e-3;

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

module Interior() {
    scale([lx+2*gap, ly+2*gap, lz+2*gap])
    cube(1, center=true);
}

module Box() {
    difference() {
        translate([0, 0, lz/2 + thickness])
        scale([lx+2*thickness, ly+2*thickness, lz+2*thickness])
        cube(1, center=true);
        translate([0, 0, lz/2 + thickness])
        Interior();
        // remove the top
        translate([0, 0, lz+2*thickness])
        scale([2*lx, 2*ly, 2*thickness])
        cube(1, center=true);
        translate([-lx/2-thickness, -ly/2-thickness, 0])
        Fillet(fillet);
        translate([lx/2+thickness, -ly/2-thickness, 0])
        Fillet(fillet);
        translate([lx/2+thickness, ly/2+thickness, 0])
        Fillet(fillet);
        translate([-lx/2-thickness, ly/2+thickness, 0])
        Fillet(fillet);
    }
}

Box();