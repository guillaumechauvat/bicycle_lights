// gap for tolerances
gap = 0.3;

lx = 91 + 2*gap;
ly = 70 + 2*gap;
lz = 28;

// wall thickness
thickness = 4;

// hole size
w_hole = 14;
h_hole = 6;

// fillet radius
fillet = 3;

// attach points
x_attach = 30;
z_attach = lz - thickness;
l_attach = 12;
w_attach = 1.5;


lxt = lx + 2*thickness;
lyt = ly + 2*thickness;
eps=1e-3;

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

module WireHole() {
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

module AttachDip(l, x, y, z, flip) {
    translate([x - l/2, y, z])
    rotate([-45 + 180*flip, 0, 0])
    cube(l_attach);
}

module Box() {
    difference() {
        linear_extrude(lz + thickness)
        polygon([[-lxt/2, -lyt/2], [lxt/2, -lyt/2], [lxt/2, lyt/2], [-lxt/2, lyt/2]]);
        translate([0, 0, thickness])
        linear_extrude(lz + thickness)
        polygon([[-lx/2, -ly/2], [lx/2, -ly/2], [lx/2, ly/2], [-lx/2, ly/2]]);
        WireHole();
        
        // fillet
        translate([-lxt/2, -lyt/2, 0]) Fillet(fillet);
        translate([-lxt/2, lyt/2, 0]) Fillet(fillet);
        translate([lxt/2, lyt/2, 0]) Fillet(fillet);
        translate([lxt/2, -lyt/2, 0]) Fillet(fillet);
        
        // place for lid
        translate([0, 0, lz+thickness/2])
        linear_extrude(thickness)
        polygon([[-(lx+thickness)/2, -(ly+thickness)/2], [(lx+thickness)/2, -(ly+thickness)/2], [(lx+thickness)/2, (ly+thickness)/2], [-(lx+thickness)/2, (ly+thickness)/2]]);
        
        // lid attach points
        AttachDip(l_attach, x_attach, ly/2 + 0.7*thickness, z_attach, 0);
        AttachDip(l_attach, -x_attach, ly/2 + 0.7*thickness, z_attach, 0);
        AttachDip(l_attach, x_attach, -ly/2 - 0.7*thickness, z_attach, 1);
        AttachDip(l_attach, -x_attach, -ly/2 - 0.7*thickness, z_attach, 1);
    }
};

module WireHoleLid() {
    translate([lx/2+thickness+eps, 0, lz+thickness-eps])
    rotate([0, -90, 0])
    difference() {
        linear_extrude(3*thickness)
        polygon([[-h_hole-eps, -w_hole/2-eps], [-h_hole-eps, w_hole/2+eps], [eps, w_hole/2+eps], [eps, -w_hole/2-eps]]);
    }
};

module LidSide(x, y, flip) {
    difference() {
        translate([x, y, z_attach-thickness/2])
        rotate([0, 0, 180*flip])
        linear_extrude(lz + 2*thickness - z_attach)
        polygon([[-l_attach/2, -thickness+eps], [l_attach/2, -thickness+eps], [l_attach/2, w_attach], [-l_attach/2, w_attach]]);
        translate([x+l_attach/2, y+(1-2*flip)*w_attach, 0]) Fillet(w_attach);
        translate([x-l_attach/2, y+(1-2*flip)*w_attach, 0]) Fillet(w_attach);
    }
}

module Lid() {
    difference() {
        union() {
            // main body to be carved
            translate([0, 0, lz+thickness/2])
            linear_extrude(thickness)
            polygon([[-lxt/2+eps, -lyt/2+eps], [lxt/2-eps, -lyt/2+eps], [lxt/2-eps, lyt/2-eps], [-lxt/2+eps, lyt/2-eps]]);
            // protruding side stuff
            LidSide(x_attach, lyt/2, 0);
            LidSide(-x_attach, lyt/2, 0);
            LidSide(-x_attach, -lyt/2, 1);
            LidSide(x_attach, -lyt/2, 1);
        }
        // fillet
        translate([-lxt/2+eps, -lyt/2+eps, 0]) Fillet(fillet);
        translate([-lxt/2+eps, lyt/2-eps, 0]) Fillet(fillet);
        translate([lxt/2-eps, lyt/2-eps, 0]) Fillet(fillet);
        translate([lxt/2-eps, -lyt/2+eps, 0]) Fillet(fillet);
        WireHoleLid();
        // intersection with box
        difference() {
            // remove some extra width so the side attach thingies are not rubbing too much
            linear_extrude(lz + thickness)
            polygon([[-lxt/2-gap, -lyt/2-gap], [lxt/2+gap, -lyt/2-gap], [lxt/2+gap, lyt/2+gap], [-lxt/2-gap, lyt/2+gap]]);
            // leave material on the inside of the lid so it fits nicely
            translate([0, 0, -thickness])
            linear_extrude(lz + 3*thickness)
            polygon([[-lx/2+gap, -ly/2+gap], [lx/2-gap, -ly/2+gap], [lx/2-gap, ly/2-gap], [-lx/2+gap, ly/2-gap]]);
            AttachDip(l_attach-2*gap, x_attach, ly/2+gap + 0.7*thickness, z_attach, 0);
            AttachDip(l_attach-2*gap, -x_attach, ly/2+gap + 0.7*thickness, z_attach, 0);
            AttachDip(l_attach-2*gap, x_attach, -ly/2-gap - 0.7*thickness, z_attach, 1);
            AttachDip(l_attach-2*gap, -x_attach, -ly/2-gap - 0.7*thickness, z_attach, 1);
        }
   }
}

Box();
Lid();