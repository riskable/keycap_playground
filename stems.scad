// Stem-related modules

use <utils.scad>

/* NOTES
    * Some of the stem arguments are unused.  They're there in case we need to use them in the future (e.g. dish_tilt might be taken into account in the future if we need to make the underside of keycaps tilted).
*/

// Cherry constants (not all used; many are here "just in case")
CHERRY_SWITCH_LENGTH = 15.6;
CHERRY_SWITCH_WIDTH = 15.6;
CHERRY_CYLINDER_DIAMETER = 5.47;
CHERRY_STEM_HEIGHT = 4.5; // How far the underside of the keycap extends into the stem()
CHERRY_CROSS_X_THICKNESS = 1.3; // Width of the - in the +
CHERRY_CROSS_Y_THICKNESS = 1.1; // Width of the - in the |
CHERRY_CROSS_LENGTH = 4; // Length of the - and the | in the +
CHERRY_BOX_STEM_WIDTH = 6.5; // Outside dimensions of a box-style stem
CHERRY_BOX_STEM_LENGTH = 6.5;

/* This makes the + bit that slides *in* to a Cherry MX style keycap
    * depth: How long/tall the rendered cross stem will be (normally 4mm)
    * extra_tolerance: How much *thicker* the cross will be rendered (assuming use with difference())
    * flare_base: Whether or not the base of the cross should be flared outward (45° angle, 0.6mm outward) to make keycap insertion easier and also prevent any issues with first layer squish (aka elephant's foot)
*/
module cherry_cross(depth=4, tolerance=0.1, flare_base=true) {
    flare_height = 0.4;
    flare_width = 0.6;
    // NOTE: The 0.001 values sprinkled throughout (and translate() calls) are just to prevent rendering artifacts when previewing
    translate([0,0,-0.001]) linear_extrude(height=depth+0.002) {
        square([CHERRY_CROSS_Y_THICKNESS+tolerance*2, CHERRY_CROSS_LENGTH+tolerance/4], center=true);
        square([CHERRY_CROSS_LENGTH+tolerance, CHERRY_CROSS_X_THICKNESS+tolerance], center=true);
    }
    if (flare_base) {
        translate([0,0,-0.001]) linear_extrude(height=flare_height, scale=[0.5,0.825]) {
            square([CHERRY_CROSS_Y_THICKNESS+tolerance*2+flare_width, CHERRY_CROSS_LENGTH+tolerance+flare_width], center=true);
        }
        translate([0,0,-0.001]) linear_extrude(height=flare_height, scale=[0.825,0.5]) {
            square([CHERRY_CROSS_LENGTH+tolerance/4+flare_width, CHERRY_CROSS_X_THICKNESS+tolerance+flare_width], center=true);
        }
    }
}

// Generates *just* the top part of the stem that goes under the keycap (mostly for making underset legends)
module stem_top(key_height, key_length, key_width, dish_depth, dish_thickness, top_difference, dish_tilt=0, wall_thickness=1.35, key_corner_radius=0.5, top_x=0, top_y=0, top_thickness=0.6, key_rotation=[0,0,0]) {
    // Generate a top layer that spans the entire width of the keycap so we have something legends can print on
    // NOTE: We generate it similarly to poly_keycap()'s trapezoidal interior cutout so we have a precise fit
    // Give the "undershelf" a distinct color so you know it's there and not the same as the keycap:
    color("#620093") // Purple
    rotate(key_rotation) difference() {
        squarish_rpoly(
            xy1=[key_length-wall_thickness*2,key_width-wall_thickness*2],
            xy2=[key_length-wall_thickness*2-top_difference,key_width-wall_thickness*2-top_difference],
            xy2_offset=[top_x,top_y],
            h=key_height, r=key_corner_radius/2, center=false);
        translate([0,0,key_height/2+key_height-dish_depth-dish_thickness]) // Cut off top
            cube([key_length*2, key_width*2, key_height], center=true);
        translate([0,0,key_height/2-dish_depth-dish_thickness-top_thickness]) // Cut off bottom
            cube([key_length*2,key_width*2,key_height], center=true);
    }
}

/* NOTES:
    * if top_thickness > 0 then an area will be filled underneath the top of the keycap of the given thickness.  This is so legends have something they can print on/adhere to and also makes it easier to fill hollow legends with a material like wax after printing (so it doesn't just melt and drip all the way through the top of the keycap)
*/

module stem_box_cherry(key_height, key_length, key_width, dish_depth, dish_thickness, top_difference, depth=4, dish_tilt=0, wall_thickness=1.35, key_corner_radius=0.5, top_x=0, top_y=0, outside_tolerance_x=0.2, outside_tolerance_y=0.2, inside_tolerance=0.25, inset=0, top_thickness=0.6, side_support_thickness=0.8, side_supports=[0,0,0,0], flat_support=true, support_distance=0.2, locations=[[0,0,0]], key_rotation=[0,0,0]) {
    left_support = side_supports[0];
    right_support = side_supports[1];
    front_support = side_supports[2];
    back_support = side_supports[3];
    // Generate a top layer that spans the entire width of the keycap so we have something legends can print on
    // NOTE: We generate it similarly to poly_keycap()'s trapezoidal interior cutout so we have a precise fit
    // Give the "undershelf" a distinct color so you know it's there and not the same as the keycap:
    color("#620093") // Purple
    rotate(key_rotation) difference() {
        squarish_rpoly(
            xy1=[key_length-wall_thickness*2,key_width-wall_thickness*2],
            xy2=[key_length-wall_thickness*2-top_difference,key_width-wall_thickness*2-top_difference],
            xy2_offset=[top_x,top_y],
            h=key_height, r=key_corner_radius/2, center=false);
        translate([0,0,key_height/2+key_height-dish_depth-dish_thickness]) // Cut off top
            cube([key_length*2, key_width*2, key_height], center=true);
        translate([0,0,key_height/2-dish_depth-dish_thickness-top_thickness]) // Cut off bottom
            cube([key_length*2,key_width*2,key_height], center=true);
    }
    // Add some helpful messages:
    if (key_rotation[0] != 0 || key_rotation[1] != 0) {
        if (!side_support_thickness) {
            warning("Since your key is rotated on its side you probably want to set STEM_SIDE_SUPPORT_THICKNESS (side_support_thickness) to something like 0.8 so your stem doesn't have to print in mid-air. If you plan to use your slicer's supports feature then you can ignore this warning.");
        }
        if (!left_support && !right_support && !front_support && !back_support) {
            warning("Since your key is rotated on its side you probably want to enable one of the STEM_SIDE_SUPPORTS (side_supports)");
        }
    }
    // Generate stabilizer stems at their specified *locations*
    for (loc=[0:1:len(locations)-1]) {
        _stem_box_cherry( // Generate the normal stem
            key_height=key_height,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thickness,
            top_difference=top_difference,
            depth=depth, dish_tilt=dish_tilt,
            wall_thickness=wall_thickness,
            key_corner_radius=key_corner_radius,
            top_x=top_x, top_y=top_y,
            outside_tolerance_x=outside_tolerance_x,
            outside_tolerance_y=outside_tolerance_y,
            inside_tolerance=inside_tolerance,
            inset=inset,
            top_thickness=top_thickness,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports,
            flat_support=flat_support,
            support_distance=support_distance,
            location=locations[loc], // This stem's location
            locations=locations, // All stem locations (so we can cut them out of the side supports)
            key_rotation=key_rotation);
    }
}

module _stem_box_cherry(key_height, key_length, key_width, dish_depth, dish_thickness, top_difference, depth=4, dish_tilt=0, wall_thickness=1.35, key_corner_radius=0.5, top_x=0, top_y=0, outside_tolerance_x=0.2, outside_tolerance_y=0.2, inside_tolerance=0.25, inset=0, top_thickness=0.6, side_support_thickness=0.8, side_supports=[0,0,0,0], flat_support=true, support_distance=0.2, location=[0,0,0], locations=[[0,0,0]], key_rotation=[0,0,0]) {
    extrusion_width = 0.45;
    length = CHERRY_CYLINDER_DIAMETER-outside_tolerance_x*2;
    width = CHERRY_CYLINDER_DIAMETER-outside_tolerance_y*2;
    corner_radius = 1; // Of the stem's exterior "box"
    support_dia = 7; // Size of the removable "flat thing" (bigger == easier to grab/remove with a tool)
    left_support = side_supports[0];
    right_support = side_supports[1];
    front_support = side_supports[2];
    back_support = side_supports[3];
    rotate(key_rotation) {
        translate(location) { // Move the stem to it's designated location
            difference() {
                translate([0,0,depth/2+inset])
                    squarish_rpoly(xy=[length,width], h=depth, r=corner_radius, center=true);
                translate([0,0,inset])
                    cherry_cross(tolerance=inside_tolerance, flare_base=true);
            }
            // Generate the top part of the stem that connects to the underside of the keycap
            translate([0,0,(key_height-dish_depth-dish_thickness-depth-inset)/2+depth+inset])
                squarish_rpoly(
                    xy=[length,width],
                    h=key_height-dish_depth-dish_thickness-depth-inset,
                    r=corner_radius, center=true);
          color("#005500") // Green
            if (flat_support && inset > 0) { // Generate the support bits that go under the stem
                if (key_rotation[0] != 0 || key_rotation[1] != 0) {
                    warning("If you're rotating the keycap you probably want STEM_SUPPORT=false (flat_support=false)");
                }
                translate([0,0,-support_distance]) difference() { // Generate the little corner bits
                    translate([0,0,inset/2+support_distance/2])
                        squarish_rpoly(xy=[length,width], h=inset-support_distance, r=corner_radius, center=true);
                    translate([0,0,inset/2])
                        squarish_rpoly(xy=[length-extrusion_width*2,width-extrusion_width*2], h=inset+1, r=corner_radius, center=true);
                    translate([0,0,inset/2])
                        cube([3,20,inset+1], center=true);
                    translate([0,0,inset/2])
                        cube([20,3,inset+1], center=true);
                }
                difference() { // Generate the center bit
                    cylinder(d=3.5, h=inset-support_distance, $fn=32);
                    cylinder(d=1.85, h=inset*4, center=true, $fn=32);
                }
                // Add a flat thing at the bottom that makes it easy to pull the supports off
                translate([0,0,0.3]) difference() {
                    cube([support_dia,support_dia,0.6], center=true);
                    cylinder(d=3, h=0.601, $fn=32, center=true); // Cut a hole out of the middle to ensure perimeters (strength)
                }
            }
        }
        // Add side supports so you can print the keycap on its left or right sides
        color("#005500") // Green
        if (left_support || right_support || front_support || back_support) {
                for (loc=[0:1:len(locations)-1]) {
                    if (locations[loc][1] != 0) {
                        // Only need to move them if they're Y (left/right) stems
                        translate([locations[loc][0],locations[loc][1],0])
                            stem_support(key_height, key_length, key_width, dish_depth, dish_thickness, top_difference, wall_thickness=wall_thickness, top_x=top_x, top_y=top_y, outside_tolerance_x=outside_tolerance_x, outside_tolerance_y=outside_tolerance_y, inset=inset, top_thickness=top_thickness, side_support_thickness=side_support_thickness, side_supports=side_supports, support_distance=support_distance, location=locations[loc], locations=locations);
                    } else {
                        stem_support(key_height, key_length, key_width, dish_depth, dish_thickness, top_difference, wall_thickness=wall_thickness, top_x=top_x, top_y=top_y, outside_tolerance_x=outside_tolerance_x, outside_tolerance_y=outside_tolerance_y, inset=inset, top_thickness=top_thickness, side_support_thickness=side_support_thickness, side_supports=side_supports, support_distance=support_distance, location=locations[loc], locations=locations);
                    }
                }
        }
    }
}

module stem_round_cherry(key_height, key_length, key_width, dish_depth, dish_thickness, top_difference, depth=4, dish_tilt=0, wall_thickness=1.35, key_corner_radius=0.5, top_x=0, top_y=0, outside_tolerance=0.2, inside_tolerance=0.25, inset=0, top_thickness=0.6, side_support_thickness=0.8, side_supports=[0,0,0,0], flat_support=true, support_distance=0.2, locations=[[0,0,0]], key_rotation=[0,0,0]) {
    left_support = side_supports[0];
    right_support = side_supports[1];
    front_support = side_supports[2];
    back_support = side_supports[3];
    // Generate a top layer that spans the entire width of the keycap so we have something legends can print on
    // NOTE: We generate it similarly to poly_keycap()'s trapezoidal interior cutout so we have a precise fit
    color("#620093") rotate(key_rotation) difference() {
        squarish_rpoly(
            xy1=[key_length-wall_thickness*2,key_width-wall_thickness*2],
            xy2=[key_length-wall_thickness*2-top_difference,key_width-wall_thickness*2-top_difference],
            xy2_offset=[top_x,top_y],
            h=key_height, r=key_corner_radius/2, center=false);
        translate([0,0,key_height/2+key_height-dish_depth-dish_thickness]) // Cut off top
            cube([key_length*2, key_width*2, key_height], center=true);
        translate([0,0,key_height/2-dish_depth-dish_thickness-top_thickness]) // Cut off bottom
            cube([key_length*2,key_width*2,key_height], center=true);
    }
    // Add some helpful messages:
    if (key_rotation[0] != 0 || key_rotation[1] != 0) {
        if (!side_support_thickness) {
            warning("Since your key is rotated on its side you probably want to set STEM_SIDE_SUPPORT_THICKNESS (side_support_thickness) to something like 0.8 so your stem doesn't have to print in mid-air. If you plan to use your slicer's supports feature then you can ignore this warning.");
        }
        if (!left_support && !right_support && !front_support && !back_support) {
            warning("Since your key is rotated on its side you probably want to enable one of the STEM_SIDE_SUPPORTS (side_supports)");
        }
    }
    // Generate stems at their specified *locations*
    for (loc=[0:1:len(locations)-1]) {
        _stem_round_cherry( // Generate the normal stem
            key_height=key_height,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thickness,
            top_difference=top_difference,
            depth=depth, dish_tilt=dish_tilt,
            wall_thickness=wall_thickness,
            key_corner_radius=key_corner_radius,
            top_x=top_x, top_y=top_y,
            outside_tolerance=outside_tolerance,
            inside_tolerance=inside_tolerance,
            inset=inset,
            top_thickness=top_thickness,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports,
            flat_support=flat_support,
            support_distance=support_distance,
            location=locations[loc], // This stem's location
            locations=locations, // All stem locations (so we can cut them out of the side supports)
            key_rotation=key_rotation);
    }
}

module _stem_round_cherry(key_height, key_length, key_width, dish_depth, dish_thickness, top_difference, depth=4, dish_tilt=0, wall_thickness=1.35, key_corner_radius=0.5, top_x=0, top_y=0, outside_tolerance=0.2, inside_tolerance=0.25, inset=0, top_thickness=0.6, side_support_thickness=0.8, side_supports=[0,0,0,0], flat_support=true, support_distance=0.2, location=[0,0,0], locations=[[0,0,0]], key_rotation=[0,0,0]) {
    extrusion_width = 0.45;
    length = CHERRY_CYLINDER_DIAMETER-outside_tolerance;
    width = CHERRY_CYLINDER_DIAMETER-outside_tolerance;
    corner_radius = 1; // Of the stem's exterior "box"
    support_dia = 7; // Size of the removable "flat thing" (bigger == easier to grab/remove with a tool)
    left_support = side_supports[0];
    right_support = side_supports[1];
    front_support = side_supports[2];
    back_support = side_supports[3];
    $fn = 64;
    rotate(key_rotation) {
        translate(location) {
            difference() {
                translate([0,0,depth/2+inset])
                    cylinder(d=CHERRY_CYLINDER_DIAMETER-outside_tolerance, h=depth, center=true);
                translate([0,0,inset])
                    cherry_cross(tolerance=inside_tolerance, flare_base=true);
            }
            // Generate the top part of the stem that connects to the underside of the keycap
            translate([0,0,(key_height-dish_depth-dish_thickness-depth-inset)/2+depth+inset])
                cylinder(
                    d=CHERRY_CYLINDER_DIAMETER-outside_tolerance,
                    h=key_height-dish_depth-dish_thickness-depth-inset, center=true);
            // Generate the support bits that go under the stem (if flat_support):
            color("#005500") if (flat_support && inset > 0) { 
                if (key_rotation[0] != 0 || key_rotation[1] != 0) {
                    warning("If you're rotating the keycap you probably want STEM_SUPPORT=false (flat_support=false)");
                }
                translate([0,0,-support_distance]) difference() { // Generate the little corner bits
                    translate([0,0,inset/2+support_distance/2])
                        squarish_rpoly(xy=[length,width], h=inset-support_distance, r=corner_radius, center=true);
                    translate([0,0,inset/2])
                        squarish_rpoly(xy=[length-extrusion_width*3,width-extrusion_width*3], h=inset+1, r=corner_radius, center=true);
                    translate([0,0,inset/2])
                        cube([1,20,inset+1], center=true);
                    translate([0,0,inset/2])
                        cube([20,1,inset+1], center=true);
                    translate([0,0,inset/2])
                        rotate([0,0,45])
                            cube([20,1,inset+1], center=true);
                    translate([0,0,inset/2])
                        rotate([0,0,-45])
                            cube([20,1,inset+1], center=true);
                }
                difference() { // Generate the center bit
                    cylinder(d=3.5, h=inset-support_distance, $fn=32);
                    cylinder(d=1.85, h=inset*4, center=true, $fn=32);
                }
                // Add a flat thing at the bottom that makes it easy to pull the supports off
                translate([0,0,0.3]) difference() {
                    cube([support_dia,support_dia,0.6], center=true);
                    cylinder(d=3, h=0.601, $fn=32, center=true); // Cut a hole out of the middle to save plastic
                }
            }
        }
        // Add side supports so you can print the keycap on its left or right sides
        color("#005500") // Green
        if (left_support || right_support || front_support || back_support) {
                for (loc=[0:1:len(locations)-1]) {
                    if (locations[loc][1] != 0) {
                        // Only need to move them if they're Y (left/right) stems
                        translate([locations[loc][0],locations[loc][1],0])
                            stem_support(key_height, key_length, key_width, dish_depth, dish_thickness, top_difference, wall_thickness=wall_thickness, top_x=top_x, top_y=top_y, outside_tolerance=outside_tolerance, inset=inset, top_thickness=top_thickness, side_support_thickness=side_support_thickness, side_supports=side_supports, support_distance=support_distance, location=locations[loc], locations=locations);
                    } else {
                        stem_support(key_height, key_length, key_width, dish_depth, dish_thickness, top_difference, wall_thickness=wall_thickness, top_x=top_x, top_y=top_y, outside_tolerance=outside_tolerance, inset=inset, top_thickness=top_thickness, side_support_thickness=side_support_thickness, side_supports=side_supports, support_distance=support_distance, location=locations[loc], locations=locations);
                    }
                }
        }
    }
}

// Makes a single center support that we can duplicate under other stems:
module stem_support(key_height, key_length, key_width, dish_depth, dish_thickness, top_difference, wall_thickness=1.35, top_x=0, top_y=0, outside_tolerance=0, outside_tolerance_x=0, outside_tolerance_y=0, inset=0, top_thickness=0.6, side_support_thickness=0.8, side_supports=[0,0,0,0], support_distance=0.2, location=[0,0,0], locations=[[0,0,0]]) {
    extrusion_width = 0.45;
    length = CHERRY_CYLINDER_DIAMETER-outside_tolerance_x*2;
    width = CHERRY_CYLINDER_DIAMETER-outside_tolerance_y*2;
    corner_radius = 1; // Of the stem's exterior "box"
    left_support = side_supports[0];
    right_support = side_supports[1];
    front_support = side_supports[2];
    back_support = side_supports[3];
    difference() {
        // NOTE: The side supports are actually attached to the sides so they stay firm while printing... They're easy enough to cut off afterwards with flush cutters.
        translate([0,0,-0.01])
            // This fills in the entire area under the keycap:
            squarish_rpoly(
                xy1=[key_length-wall_thickness*2,key_width-wall_thickness*2],
                xy2=[key_length-wall_thickness*2-top_difference,
                    key_width-wall_thickness*2-top_difference],
                xy2_offset=[top_x,top_y],
                h=key_height, r=corner_radius/2, center=false);
        // Cut off the top (area just below the dish)
        translate([
            0,
            0,
            key_height/2+key_height-dish_depth-dish_thickness-top_thickness-support_distance])
                cube([key_length*2, key_width*2, key_height], center=true);
        // Cut off the bottom so the support will match the inset (if any)
        translate([0,0,-key_height/2+inset])
            cube([key_length*2,key_width*2,key_height], center=true);
        // Cut out holes around the stem locations
        if (outside_tolerance_x) { // This is a box_cherry stem
            for (loc=[0:1:len(locations)-1]) {
                translate([locations[loc][0],locations[loc][1],key_height/2+locations[loc][2]-0.01])
                    squarish_rpoly(
                        xy=[length+support_distance*2,width+support_distance*2],
                        h=key_height, r=corner_radius, center=true);
            }
        } else if (outside_tolerance) { // This is a round_cherry stem
            for (loc=[0:1:len(locations)-1]) {
                // Cut out the stem locations
                translate([locations[loc][0],locations[loc][1],key_height/2+locations[loc][2]-0.01])
                    cylinder(d=CHERRY_CYLINDER_DIAMETER+support_distance*2, h=key_height, center=true);
            }
        }
        // Cut out any side supports we don't want
        if (!left_support) {
            translate([
                -key_length-side_support_thickness/2+location[0],
                location[1],
                key_height/2-0.01])
                cube([key_length*2, key_width*2, key_height], center=true);
        }
        if (!right_support) {
            translate([
                key_length+side_support_thickness/2+location[0],
                location[1],
                key_height/2-0.01])
                cube([key_length*2, key_width*2, key_height], center=true);
        }
        if (!front_support) {
            translate([
              0,
             -key_width-side_support_thickness/2,
              key_height/2-0.01])
                cube([key_length*2, key_width*2, key_height], center=true);
        }
        if (!back_support) {
            translate([
              0,
              key_width+side_support_thickness/2,
              key_height/2-0.01])
                cube([key_length*2, key_width*2, key_height], center=true);
        }
    }
}

// For testing:
//key_height = 8;
//key_length = 18;
//key_width = 18;
//dish_depth = 1;
//dish_thickness = 1;
//top_difference = 0.8;
//depth = 4;
//dish_tilt = 0;
//wall_thickness = 1.8;
//key_corner_radius = 0.5;
//outside_tolerance_x = 0.15;
//outside_tolerance_y = 0.15;
//inside_tolerance = 0.2;
//inset = 0;
//top_thickness = -0.1;
//flat_support = false;


//_stem_box_cherry( // Generate the normal stem
//    key_height=key_height,
//    key_length=key_length,
//    key_width=key_width,
//    dish_depth=dish_depth,
//    dish_thickness=dish_thickness,
//    top_difference=top_difference,
//    depth=depth, dish_tilt=dish_tilt,
//    wall_thickness=wall_thickness,
//    key_corner_radius=key_corner_radius,
//    outside_tolerance_x=outside_tolerance_x,
//    outside_tolerance_y=outside_tolerance_y,
//    inside_tolerance=inside_tolerance,
//    inset=inset,
//    flat_support=flat_support,
//    top_thickness=top_thickness);
    
//stem_box_cherry_module( // Generate the normal stem
//    key_height=key_height,
//    key_length=key_length,
//    key_width=key_width,
//    dish_depth=dish_depth,
//    dish_thickness=dish_thickness,
//    top_difference=top_difference,
//    depth=depth, dish_tilt=dish_tilt,
//    wall_thickness=wall_thickness,
//    key_corner_radius=key_corner_radius,
//    outside_tolerance_x=outside_tolerance_x,
//    outside_tolerance_y=outside_tolerance_y,
//    inside_tolerance=inside_tolerance,
//    inset=inset);