// Keycap utility modules and functions

// MODULES

// Riskable's polygon: Kind of like a combo roundedCube()+cylinder() except you get also offset one of the diameters
module rpoly(d=0, h=0, d1=0, d2=0, r=1, edges=4, d2_offset=[0,0], center=true, $fn=64) {
    // Because we use a cylinder diameter instead of a cube for the length/width we need to correct for the fact that it will be undersized (fudge factor):
    fudge = 1/cos(180/edges);
    module rpoly_proper(d1, d2, h, r, edges, d2_offset) {
        fudged_d1 = d1 * fudge - r*2.82845; // Corner radius magic fix everything number! 2.82845
        fudged_d2 = d2 * fudge - r*2.82845; // Ditto!
        if (edges > 3) {
            hull() {
                linear_extrude(height=0.0001)
                    offset(r=r) rotate([0,0,45]) circle(d=fudged_d1, $fn=edges);
                translate([d2_offset[0],d2_offset[1],h])
                    linear_extrude(height=0.0001)
                        offset(r=r) rotate([0,0,45]) circle(d=fudged_d2, $fn=edges);
            }
        } else { // Triangles need a little special attention
            hull() {
                linear_extrude(height=0.0001)
                    offset(r=r) rotate([0,0,30]) circle(d=d1, $fn=edges);
                translate([d2_offset[0],d2_offset[1],h])
                    linear_extrude(height=0.0001)
                        offset(r=r) rotate([0,0,30]) circle(d=d2, $fn=edges);
            }
        }
    }
    if (d1) {
        if (center) {
            translate([0,0,-h/2])
                rpoly_proper(d1, d2, h, r, edges, d2_offset);
        } else {
            rpoly_proper(d1, d2, h, r, edges, d2_offset);
        }
    } else {
        fudged_diameter = d * fudge - r*2.82845; // Corner radius magic fix everything number! 2.82845
        if (center) {
            translate([0,0,-h/2])
                rpoly_proper(d, d, h, r, edges, d2_offset);
        } else {
            rpoly_proper(d, d, h, r, edges, d2_offset);
        }
    }
}

module squarish_rpoly(xy=[0,0], h=0, xy1=[0,0], xy2=[0,0], r=1, xy2_offset=[0,0], center=false, $fn=64) {
    module square_rpoly_proper(xy1, xy2, h, r, xy2_offset) {
        // Need to correct for the corner radius since we're using offset() and square()
        corrected_x1 = xy1[0] > r ? xy1[0] - r*2 : r/10;
        corrected_y1 = xy1[1] > r ? xy1[1] - r*2 : r/10;
        corrected_x2 = xy2[0] > r ? xy2[0] - r*2 : r/10;
        corrected_y2 = xy2[1] > r ? xy2[1] - r*2 : r/10;
        if (corrected_x1 <= 0 || corrected_x2 <= 0 || corrected_y1 <= 0 || corrected_y2 <= 0) {
            warning("Corner Radius (x2) is larger than this rpoly! Won't render properly.");
        }
        corrected_xy1 = [corrected_x1, corrected_y1];
        corrected_xy2 = [corrected_x2, corrected_y2];
        hull() {
            linear_extrude(height=0.0001)
                offset(r=r) square(corrected_xy1, center=true);
            translate([xy2_offset[0],xy2_offset[1],h])
                linear_extrude(height=0.0001)
                    offset(r=r) square(corrected_xy2, center=true);
        }
    }
    if (xy1[0]) {
        if (center) {
            translate([0,0,-h/2])
                square_rpoly_proper(xy1, xy2, h, r, xy2_offset);
        } else {
            square_rpoly_proper(xy1, xy2, h, r, xy2_offset);
        }
    } else {
        if (center) {
            translate([0,0,-h/2])
                square_rpoly_proper(xy, xy, h, r, xy2_offset);
        } else {
            square_rpoly_proper(xy, xy, h, r, xy2_offset);
        }
    }
}

module note(text) echo(str("<span style='color:yellow'><b>NOTE: </b>", text, "</span>"));
module warning(text) echo(str("<span style='color:orange'><b>WARNING: </b>", text, "</span>"));

// FUNCTIONS
function is_odd(x) = (x % 2) == 1;
// This function is used to generate curves given a total number of steps, step we're currently calculating, and the amplitude of the curve:
function polygon_slice(step, amplitude, total_steps=10) = (1 - step/total_steps) * amplitude;
function polygon_slice_reverse(step, amplitude, total_steps=10) = (1 - (total_steps-step)/total_steps) * amplitude;

// Examples:
//squarish_rpoly(xy1=[0.1,0.1], xy2=[40,40], h=10, r=0.2, center=true);
// Flat sides example:
//squarish_rpoly(xy1=[10,10], xy2=[18,18], h=10, r=1, center=true, $fn=4);