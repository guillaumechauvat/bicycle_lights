// electronics box dimensions
// in practice the batteries are slightly larger, so lx and ly will be unused
lx0 = 92;
ly0 = 71;
lz0 = 34;

// dimensions of my "18650" batteries. In practice they're closer to 18700.
d = 18.5;
h_bat = 70.5; // with the button top
d_button = 6.5;
h_body = 69.3;
bat_gap = 0.3;

// dimensions of battery connectors with battery mounted
d_plus = 1.5;
d_minus = 4;
connector_depth = 0.5;
l_connector = 11.5;

// battery supports
support_width = 12;
support_height = 0.67*d;
// extra battery spacing
bat_spacing = 1.0;

thickness = 3;
oring = 2;
oring_hfact = 2;

//
lxb = 5*d + 6*bat_gap + 4*bat_spacing;
lyb = h_bat + d_plus + d_minus - 2*connector_depth;
ly = max(lyb, ly0);
lx = max(lxb, lx0);
lz = d + 2*bat_gap + lz0;


module Battery() {
    color(c = [0.35, 0.45, 0.8])
    translate([0, -h_bat/2, 0])
    rotate([-90, 0, 0]) {
        cylinder(h=h_body, d=d, $fn=80);
        translate([0, 0, h_body])
        cylinder(h=2*(h_bat-h_body), d=d_button, $fn=80, center=true);
    }
}

module BatterySpace() {
    z0 = d/2 + bat_gap/2 + thickness;
    translate([0, -h_bat/2, z0])
    rotate([-90, 0, 0])
    cylinder(h=h_body, d=d + bat_gap, $fn=120);
}

module Batteries() {
    // all 5 batteries at the right location
    z0 = d/2 + bat_gap/2 + thickness;
    dd = d + bat_gap + bat_spacing;
    translate([-2*dd, 0, z0])
    Battery();
    translate([-dd, 0, z0])
    Battery();
    translate([0, 0, z0])
    Battery();
    translate([dd, 0, z0])
    Battery();
    translate([2*dd, 0, z0])
    Battery();
}

module Contacts() {
    z0 = d/2 + bat_gap/2 + thickness;
    dd = d + bat_gap + bat_spacing;
    y0 = ly/2 + connector_depth;
    module Shape() {
        cube([l_connector, ly + 2*connector_depth, l_connector], center=true);
        rotate([0, -90, 0])
        linear_extrude(l_connector, center=true)
        polygon([
            [-l_connector/2, -y0],
            [l_connector/2, -y0],
            [l_connector, -y0 + l_connector/2],
            [l_connector, y0 - l_connector/2],
            [l_connector/2, y0],
            [-l_connector/2, y0],
        ]);
    }
    translate([-2*dd, 0, z0])
    Shape();
    translate([-dd, 0, z0])
    Shape();
    translate([0, 0, z0])
    Shape();
    translate([dd, 0, z0])
    Shape();
    translate([2*dd, 0, z0])
    Shape();
    translate([0, 0, z0])
    rotate([0, -90, 0])
        linear_extrude(4*dd, center=true)
        polygon([
            [l_connector/4, -y0],
            [l_connector/2, -y0],
            [l_connector, -y0 + l_connector/2],
            [l_connector, y0 - l_connector/2],
            [l_connector/2, y0],
            [l_connector/4, y0],
        ]);
}

module Support() {
    d2 = d + 2*bat_gap + bat_spacing;
    difference() {
        translate([0, 0, support_height/2 + 3*thickness/4])
        cube([d2, support_width + thickness/2, support_height + thickness/2], center=true); 
        BatterySpace();
        translate([0, 0, thickness + 0.7*d])
        cube([d-bat_gap, 2*support_width, d/2], center=true);
    }
}

module Supports() {
    dd = d + bat_gap + bat_spacing;
    y0 = ly/2 - support_width/2 + thickness/4;
    translate([-2*dd, y0, 0])
    Support();
    translate([-dd, y0, 0])
    Support();
    translate([0, y0, 0])
    Support();
    translate([dd, y0, 0])
    Support();
    translate([2*dd, y0, 0])
    Support();
    translate([-2*dd, -y0, 0])
    Support();
    translate([-dd, -y0, 0])
    Support();
    translate([0, -y0, 0])
    Support();
    translate([dd, -y0, 0])
    Support();
    translate([2*dd, -y0, 0])
    Support();
}

module BoardSupports() {
    dd = d + bat_gap + bat_spacing;
    height = d/2 + bat_spacing;
    width = 0.8*support_width;
    angle = 30;
    top = 1;
    module BoardSupport() {
        module SideSlope() {
            translate([0, -2*height, 0])
            rotate([0,-3, 0])
            cube(4*height);
        }
        difference() {
            translate([0, ly/2 - support_width + width/2, support_height + thickness + height/2])
            rotate([0, -90, 0])
            linear_extrude(2*bat_gap + bat_spacing, center=true)
            polygon([
                [-height/2, -width/2],
                [-height/2, width/2],
                [height/2, width/2 - height*tan(angle)],
                [height/2, -width/2 - (height-top)*tan(angle)],
                [height/2 - top, -width/2 - (height-top)*tan(angle)],
            ]);
            translate([bat_spacing/2 + bat_gap, ly/2 - 2*support_width, support_height + thickness])
            SideSlope();
            translate([-bat_spacing/2 - bat_gap, ly/2 - 2*support_width, support_height + thickness])
            rotate([0, 0, 180])
            SideSlope();
        }
    }
    module OneSide() {
        translate([-1.5*dd, 0, 0])
        BoardSupport();
        translate([-0.5*dd, 0, 0])
        BoardSupport();
        translate([0.5*dd, 0, 0])
        BoardSupport();
        translate([1.5*dd, 0, 0])
        BoardSupport();
    }
    OneSide();
    rotate([0, 0, 180])
    OneSide();
    
}

module MainBox() {
    difference() {
        translate([-lx/2-thickness, -ly/2-thickness, 0])
        cube([lx + 2*thickness, ly + 2*thickness, lz + thickness]);
        translate([-lx/2, -ly/2, thickness])
        cube([lx, ly, lz + thickness]);
        Contacts();
    }
    Supports();
    BoardSupports();
}

//Batteries();
MainBox();
