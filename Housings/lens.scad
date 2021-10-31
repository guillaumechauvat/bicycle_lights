rmax = 30.5;
// radius of the lens aperture
r_aperture = 20;
// radius of the spherical lens
r_sphere = 31;
// thickness of the flat part
thickness = 1.0;

module SphericalLens() {
    h = sqrt(r_sphere*r_sphere - r_aperture*r_aperture) - thickness;
    intersection() {
        translate([0, 0, -h])
        sphere(r_sphere, $fn=300);
        translate([0, 0, thickness/2])
        linear_extrude(2*r_sphere) {
            square(3*r_sphere, center=true);
        }
    }
};

union() {
    SphericalLens();
    linear_extrude(thickness) {
        circle(rmax, $fn=150);
    }
}