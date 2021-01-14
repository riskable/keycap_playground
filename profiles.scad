// Profiles -- Modules that generate keycaps and stems for various profile types (KAT, DSA, SA, etc).

use <keycaps.scad>
use <stems.scad>
use <utils.scad>

// CONSTANTS
KEY_UNIT = 19.05; // Standard spacing between keys

/* NOTES
    * These profile-specific modules allow you to override *most* values via arguments.  So if you want say, "DCS but with skinnier tops" you could override that via the top_difference argument.
    * The row numbering comes from historical values.  So don't assume "row 1" is the Fkeys or the spacebar.  In a lot of profiles it's all screwed up (e.g. DCS).
    * DSA Spec taken from https://pimpmykeyboard.com/template/images/DSAFamily.pdf
    * Neat little FYI:
        SA = Spherical All-rows
        SS = Spherical Sculptured
        DSA = DIN-compliant Spherical All-rows
        DSS = DIN-compliant Spherical Sculptured
        DCS = DIN-compliant Cylindrical Sculptured
    * Riskeycap profile is one I developed specifically for ease of 3D printing.  It's similar to DSA but has flat sides that make it easier to print on keycaps on their side (so the layer lines run like this: |||) and come off the printer nice and smooth with no sanding required (except maybe to get rid of first layer squish/elephant's foot on the top right and bottom right corners).
*/

// NOTE: Measured dish_depth in multiple DSA keycaps came out to ~.8
// NOTE: Spec says wall_thickness should be 1mm but the default here is 1.35 since this script will mostly be used in 3D printing.  Make sure to set it to 1mm if making an injection mold.
module DSA_keycap(row=1, length=18.41, height_extra=0, wall_thickness=1.35, dish_thickness=1, dish_fn=128, dish_depth=.8, dish_invert=false, top_difference=6.08, key_rotation=[0,0,0], corner_radius=0.5, corner_radius_curve=2, legends=[""], legend_font_sizes=[6], legend_fonts=["Roboto"], legend_trans=[[0,0,0]], legend_trans2=[[0,0,0]], legend_rotation=[[0,0,0]], legend_rotation2=[[0,0,0]], legend_scale=[[0,0,0]], legend_underset=[[0,0,0]], homing_dot_length=0, homing_dot_width=0, homing_dot_x=0, homing_dot_y=0, homing_dot_z=0, polygon_layers=10, visualize_legends=false, debug=false) {
    // NOTE: The 0-index values are ignored (there's no row 0 in DSA)
    row_height = dish_invert ? 6.3914+height_extra : 7.3914+height_extra; // One less if we're generating a spacebar
    // NOTE: 7.3914 is from the Signature Plastics DSA spec which has .291 inches
    if (row < 1) {
        warning("We only support rows 1 for DSA profile caps!");
    }
    if (row > 1) {
        warning("We only support row 1 for DSA profile caps!");
    }
    width = 18.41; // 0.725 inches
    dish_type = "sphere";
    dish_z = 0.111; // NOTE: Width of the top dish (at widest) should be ~12.7mm
    top_y = 0;
    poly_keycap(
        height=row_height, length=length, width=width, wall_thickness=wall_thickness,
        top_difference=top_difference, dish_tilt=0, dish_z=dish_z, dish_fn=dish_fn,
        dish_invert=dish_invert, top_y=top_y, dish_depth=dish_depth, dish_type=dish_type,
        dish_thickness=dish_thickness, corner_radius=corner_radius,
        corner_radius_curve=corner_radius_curve,
        legends=legends, legend_font_sizes=legend_font_sizes, legend_fonts=legend_fonts,
        legend_trans=legend_trans, legend_trans2=legend_trans2, legend_scale=legend_scale,
        legend_rotation=legend_rotation, legend_rotation2=legend_rotation2,
        legend_underset=legend_underset,
        polygon_layers=polygon_layers, polygon_layer_rotation=0, polygon_edges=4, polygon_curve=4.5,
        key_rotation=key_rotation,
        homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
        homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
        visualize_legends=visualize_legends, debug=debug);
}

// DSA Stems are pretty simple (don't need anything special)
module DSA_stem(stem_type="box_cherry", key_height=7.3914, key_length=18.2, key_width=18.2, height_extra=0, dish_depth=1, dish_thickness=1, dish_invert=false, depth=4, top_difference=6, wall_thickness=1.35, key_corner_radius=0.5, top_x=0, top_y=0, outside_tolerance_x=0.2, outside_tolerance_y=0.2, inside_tolerance=0.25, inset=0, top_thickness=0.6, side_support_thickness=0.8, side_supports=[0,0,0,0], flat_support=true, locations=[[0,0,0]], key_rotation=[0,0,0]) {
    if (stem_type == "box_cherry") {
        stem_box_cherry(
            key_height=key_height+height_extra,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thickness,
            top_difference=top_difference,
            depth=depth, dish_tilt=0,
            top_thickness=top_thickness,
            key_corner_radius=key_corner_radius,
            wall_thickness=wall_thickness,
            top_x=top_x, top_y=top_y,
            outside_tolerance_x=outside_tolerance_x,
            outside_tolerance_y=outside_tolerance_y,
            inside_tolerance=inside_tolerance,
            inset=inset,
            flat_support=flat_support,
            locations=locations,
            key_rotation=key_rotation,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports);
    } else if (stem_type == "round_cherry") {
        stem_round_cherry(
            key_height=key_height+height_extra,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thickness,
            top_difference=top_difference,
            depth=depth, dish_tilt=0,
            top_thickness=top_thickness,
            key_corner_radius=key_corner_radius,
            wall_thickness=wall_thickness,
            top_x=top_x, top_y=top_y,
            outside_tolerance=outside_tolerance_x,
            inside_tolerance=inside_tolerance,
            inset=inset,
            flat_support=flat_support,
            locations=locations,
            key_rotation=key_rotation,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports);
    }
}

// NOTE: dish_thickness gets *added* to the default thickness of this profile which is approximately 1mm (depending on the keycap). This is to prevent a low dish_thickness value from making an unusable keycap
module DCS_keycap(row=2, length=18.15, height_extra=0, wall_thickness=1.35, dish_thickness=0.6, dish_fn=128, dish_invert=false, top_difference=6, key_rotation=[0,0,0], corner_radius=0.5, corner_radius_curve=0, legends=[""], legend_font_sizes=[6], legend_fonts=["Roboto"], legend_trans=[[0,0,0]], legend_trans2=[[0,0,0]], legend_rotation=[[0,0,0]], legend_rotation2=[[0,0,0]], legend_scale=[[0,0,0]], polygon_layers=20, legend_underset=[[0,0,0]], homing_dot_length=0, homing_dot_width=0, homing_dot_x=0, homing_dot_y=0, homing_dot_z=0, visualize_legends=false, debug=false) {
    // NOTE: The 0-index values are ignored (there's no row 0 in DCS)
    row_height = [
        0, 9.5, 7.39, 7.39, 9, 12.5
    ];
    dish_tilt = [
        0, -1, 3, 7, 16, -6
    ];
    dish_z = [ // Dish needs to cut into the top a unique amount depending on the height and angle
        0, -0.11, -0.38, -0.78, 0.6, -0.75
    ];
    dish_thicknesses = [
        0, 1.2, 1.6, 2, 3, 2
    ];
    adjusted_dish_thickness = dish_thicknesses[row] + dish_thickness;
    if (row < 1) {
        warning("We only support rows 1-5 for DCS profile caps!");
    }
    row = row < 6 ? row : 5; // We only support rows 0-4 (5 total rows)
    width = 18.15;
    dish_type = "cylinder";
    dish_depth = 1;
    top_y = -1.75;
    poly_keycap(
        height=row_height[row]+height_extra, length=length, width=width, wall_thickness=wall_thickness,
        top_difference=top_difference, dish_tilt=dish_tilt[row], dish_z=dish_z[row],
        top_y=top_y, dish_depth=dish_depth, dish_type=dish_type,
        dish_thickness=adjusted_dish_thickness, dish_fn=dish_fn, dish_invert=dish_invert,
        legends=legends, legend_font_sizes=legend_font_sizes, legend_fonts=legend_fonts,
        legend_trans=legend_trans, legend_trans2=legend_trans2, legend_scale=legend_scale,
        legend_rotation=legend_rotation, legend_rotation2=legend_rotation2,
        legend_underset=legend_underset,
        corner_radius=corner_radius, corner_radius_curve=corner_radius_curve,
        polygon_layers=polygon_layers, polygon_layer_rotation=0, polygon_edges=4,
        homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
        homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
        key_rotation=key_rotation, debug=debug);
}

// DCS stems are a pain in the ass so they need their own special fidding...
module DCS_stem(row=2, stem_type="box_cherry", key_length=18.15, height_extra=0, depth=4, top_difference=6, wall_thickness=1.35, key_corner_radius=0.5, top_x=0, top_y=0, outside_tolerance_x=0.2, outside_tolerance_y=0.2, inside_tolerance=0.25, inset=0, dish_thickness=0.6, dish_invert=false, top_thickness=0.6, side_support_thickness=0.8, side_supports=[0,0,0,0], flat_support=true, locations=[[0,0,0]], key_rotation=[0,0,0]) {
    row_height = [
        0, 9.5, 7.39, 7.39, 9, 12.5
    ];
    dish_thicknesses = [
        0, 1.2, 1.6, 2, 4, 2
    ];
    dish_tilt = [
        0, -1, 3, 7, 16, -6
    ];
    if (row < 1) {
        warning("We only support rows 1-5 for DCS profile caps!");
    }
    row = row < 6 ? row : 5; // We only support rows 0-4 (5 total rows)
    adjusted_dish_thickness = dish_thicknesses[row] + dish_thickness;
    key_width = 18.15;
    dish_depth = 1;
    if (stem_type == "box_cherry") {
        stem_box_cherry(
            key_height=row_height[row]+height_extra,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thickness,
            top_difference=top_difference,
            depth=depth, dish_tilt=dish_tilt[row],
            top_thickness=top_thickness,
            key_corner_radius=key_corner_radius,
            wall_thickness=wall_thickness,
            top_x=top_x, top_y=top_y,
            outside_tolerance_x=outside_tolerance_x,
            outside_tolerance_y=outside_tolerance_y,
            inside_tolerance=inside_tolerance,
            inset=inset,
            flat_support=flat_support,
            locations=locations,
            key_rotation=key_rotation,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports);
    } else if (stem_type == "round_cherry") {
        stem_round_cherry(
            key_height=row_height[row]+height_extra,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thickness,
            top_difference=top_difference,
            depth=depth, dish_tilt=dish_tilt[row],
            top_thickness=top_thickness,
            key_corner_radius=key_corner_radius,
            wall_thickness=wall_thickness,
            top_x=top_x, top_y=top_y,
            outside_tolerance=outside_tolerance_x,
            inside_tolerance=inside_tolerance,
            inset=inset,
            flat_support=flat_support,
            locations=locations,
            key_rotation=key_rotation,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports);
    }
}

module DSS_keycap(row=1, length=18.24, height_extra=0, wall_thickness=1.35, dish_thickness=1.8, dish_fn=128, dish_invert=false, top_difference=5.54, key_rotation=[0,0,0], corner_radius=0.75, corner_radius_curve=1.5, legends=[""], legend_font_sizes=[6], legend_fonts=["Roboto"], legend_trans=[[0,0,0]], legend_trans2=[[0,0,0]], legend_rotation=[[0,0,0]], legend_rotation2=[[0,0,0]], legend_scale=[[0,0,0]], polygon_layers=20, legend_underset=[[0,0,0]], homing_dot_length=0, homing_dot_width=0, homing_dot_x=0, homing_dot_y=0, homing_dot_z=0, visualize_legends=false, debug=false) {
    // NOTE: The 0-index values are ignored (there's no row 0 in DSS)
    row_height = [
        0, 10.4, 8.7, 8.5, 10.6
    ];
    adjusted_row_height = dish_invert ? row_height[row]+height_extra-1 : row_height[row]+height_extra; // One less if we're generating a spacebar (which is always row 3 with DSS)
    dish_tilt = [
        0, -1, 3, 8, 16
    ];
    dish_y = [ // Dish needs to cut into the top a unique amount depending on the height and angle
        0, 1.2, -2.5, -5.7, -11.4
    ];
    dish_z = [ // Dish needs to cut into the top a unique amount depending on the height and angle
        0, 0, 0, 0, -1.1
    ];
    dish_thicknesses = [
        0, 2.5, 2.5, 2.5, 3.5
    ];
    if (row < 1) {
        warning("We only support rows 1-4 for DSS profile caps!");
    }
    row = row < 5 ? row : 4; // We only support rows 1-4 (4 total rows)
    width = 18.24;
    dish_type = "sphere";
    dish_depth = 1;
    top_y = 0;
    poly_keycap(
        height=adjusted_row_height, length=length, width=width, wall_thickness=wall_thickness,
        top_difference=top_difference, dish_tilt=dish_tilt[row], dish_z=dish_z[row], dish_y=dish_y[row],
        top_y=top_y, dish_depth=dish_depth, dish_type=dish_type,
        dish_thickness=dish_thicknesses[row], dish_fn=dish_fn, dish_invert=dish_invert,
        legends=legends, legend_font_sizes=legend_font_sizes, legend_fonts=legend_fonts,
        legend_trans=legend_trans, legend_trans2=legend_trans2, legend_scale=legend_scale,
        legend_rotation=legend_rotation, legend_rotation2=legend_rotation2,
        legend_underset=legend_underset,
        corner_radius=corner_radius, corner_radius_curve=corner_radius_curve,
        polygon_layers=polygon_layers, polygon_layer_rotation=0, polygon_edges=4,
        polygon_curve=4,
        homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
        homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
        key_rotation=key_rotation, debug=debug);
}

module DSS_stem(row=2, stem_type="box_cherry", key_length=18.24, height_extra=0, depth=4, top_difference=5.54, wall_thickness=1.35, key_corner_radius=0.5, top_x=0, top_y=0, outside_tolerance_x=0.2, outside_tolerance_y=0.2, inside_tolerance=0.25, inset=0, dish_thickness=0.6, dish_invert=false, top_thickness=0.6, side_support_thickness=0.8, side_supports=[0,0,0,0], flat_support=true, locations=[[0,0,0]], key_rotation=[0,0,0]) {
    row_height = [
        0, 10.4, 8.7, 8.5, 10.6
    ];
    dish_tilt = [
        0, -1, 3, 8, 16
    ];
    dish_thicknesses = [
        0, 2.5, 2.5, 2.5, 3.5
    ];
    if (row < 1) {
        warning("We only support rows 1-5 for DCS profile caps!");
    }
    row = row < 6 ? row : 5; // We only support rows 0-4 (5 total rows)
    key_width = 18.24;
    dish_depth = 1;
    if (stem_type == "box_cherry") {
        stem_box_cherry(
            key_height=row_height[row]+height_extra,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thicknesses[row],
            top_difference=top_difference,
            depth=depth, dish_tilt=dish_tilt[row],
            top_thickness=top_thickness,
            key_corner_radius=key_corner_radius,
            wall_thickness=wall_thickness,
            top_x=top_x, top_y=top_y,
            outside_tolerance_x=outside_tolerance_x,
            outside_tolerance_y=outside_tolerance_y,
            inside_tolerance=inside_tolerance,
            inset=inset,
            flat_support=flat_support,
            locations=locations,
            key_rotation=key_rotation,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports);
    } else if (stem_type == "round_cherry") {
        stem_round_cherry(
            key_height=row_height[row]+height_extra,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thicknesses[row],
            top_difference=top_difference,
            depth=depth, dish_tilt=dish_tilt[row],
            top_thickness=top_thickness,
            key_corner_radius=key_corner_radius,
            wall_thickness=wall_thickness,
            top_x=top_x, top_y=top_y,
            outside_tolerance=outside_tolerance_x,
            inside_tolerance=inside_tolerance,
            inset=inset,
            flat_support=flat_support,
            locations=locations,
            key_rotation=key_rotation,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports);
    }
}

/* NOTES
So here's the deal with the KAT profile:  The *dishes* are accurately-placed but the curve that goes up the side of the keycap (front and back) isn't *quite* right because whoever modeled the KAT profile probably started with DSA and then extruded/moved things up/down and forwards/backwards a bit until they had what they wanted.  This makes generating these keycaps via an algorithm difficult.  Having said that the curve is quite close to the original and you'd have to look *very* closely to be able to tell the difference in real life.  As long as the dishes are in the right place that's what matters most.
*/
module KAT_keycap(row=1, length=18.2, height_extra=0, wall_thickness=1.658, dish_thickness=1.658, dish_fn=128, dish_depth=0.75, dish_invert=false, top_difference=6.5, key_rotation=[0,0,0], corner_radius=0.35, corner_radius_curve=2.75, legends=[""], legend_font_sizes=[6], legend_fonts=["Roboto"], legend_trans=[[0,0,0]], legend_trans2=[[0,0,0]], legend_rotation=[[0,0,0]], legend_rotation2=[[0,0,0]], legend_scale=[[0,0,0]], legend_underset=[[0,0,0]], homing_dot_length=0, homing_dot_width=0, homing_dot_x=0, homing_dot_y=0, homing_dot_z=0, polygon_layers=10, visualize_legends=false, debug=false) {
    // FYI: I know that the curve up the side of the keycap is a little off...  If anyone knows how to calculate the correct curve for KAT profile let me know and I'll fix it!
    if (row < 1) {
        warning("We only support rows 1-5 for KAT profile caps!");
    }
    if (row > 5) {
        warning("We only support rows 1-5 for KAT profile caps!");
    }
    // NOTE: KAT profile actually mandates 1.658mm wall thickness but I'm not going to force the user to use that
    // NOTE: The 0-index values are ignored (there's no row 0 in KAT)
    row_height = [
        0, 10.95, 9.15, 10.9, 11.9, 13.8
    ]; //  R1     R2    R3    R4    R5
    dish_tilt = [
        0, -5, -0.5, 4.5, 1.95, 7.5
    ];
    dish_y = [
        0, 4, 0.25, -3.75, -1.65, -6
    ];
    top_y = [
        0, 0.75, 0.75, 0.75, 0.65, 0
    ];
    dish_z = [
        0, -0.25, 0, -0.25, -0.25, -0.5
    ];
    width = 18.2;
    // Official KAT keycaps have a cylindrical dish when inverted:
    dish_type = dish_invert ? "cylinder" : "sphere";
    poly_keycap(
        height=row_height[row]+height_extra, length=length, width=width, wall_thickness=wall_thickness,
        top_difference=top_difference, dish_tilt=dish_tilt[row],
        dish_y=dish_y[row], dish_z=dish_z[row], dish_fn=dish_fn,
        dish_invert=dish_invert, top_y=top_y[row], dish_depth=dish_depth, dish_type=dish_type,
        dish_thickness=dish_thickness, corner_radius=corner_radius,
        corner_radius_curve=corner_radius_curve,
        legends=legends, legend_font_sizes=legend_font_sizes, legend_fonts=legend_fonts,
        legend_trans=legend_trans, legend_trans2=legend_trans2, legend_scale=legend_scale,
        legend_rotation=legend_rotation, legend_rotation2=legend_rotation2,
        legend_underset=legend_underset,
        polygon_layers=polygon_layers, polygon_layer_rotation=0, polygon_edges=4, polygon_curve=7,
        key_rotation=key_rotation,
        homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
        homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
        visualize_legends=visualize_legends, debug=debug);
}

// NOTE: I double-checked and KAT profile stems really *do* go all the way to the floor!  They're not inset at all (which is different)!
module KAT_stem(row=1, stem_type="box_cherry", key_height=9.15, key_length=18.2, key_width=18.2, height_extra=0, dish_depth=0.75, dish_thickness=1, dish_invert=false, depth=4, top_difference=6, wall_thickness=1.658, key_corner_radius=0.35, top_x=0, top_y=0, outside_tolerance_x=0.2, outside_tolerance_y=0.2, inside_tolerance=0.25, inset=0, top_thickness=0.6, side_support_thickness=0.8, side_supports=[0,0,0,0], flat_support=true, locations=[[0,0,0]], key_rotation=[0,0,0]) {
    if (inset > 0) {
        warning("FYI: Official KAT profile keycaps don't have an inset stem.  The stems go all the way to the floor (but you don't have to do that if you don't want).");
    }
    // NOTE: These much match KAT_keycap()
    row_height = [
        0, 10.95, 9.15, 10.9, 11.9, 13.8
    ]; //  R1     R2    R3    R4    R5
    dish_tilt = [
        0, -5, -0.5, 4.5, 1.95, 7.5
    ];
    kat_top_y = [
        0, 0.75, 0.75, 0.75, 0.65, 0
    ];
    if (stem_type == "box_cherry") {
        stem_box_cherry(
            key_height=row_height[row]+height_extra,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thickness,
            top_difference=top_difference,
            depth=depth, dish_tilt=dish_tilt[row],
            top_thickness=top_thickness,
            key_corner_radius=key_corner_radius,
            wall_thickness=wall_thickness,
            top_x=top_x, top_y=kat_top_y[row],
            outside_tolerance_x=outside_tolerance_x,
            outside_tolerance_y=outside_tolerance_y,
            inside_tolerance=inside_tolerance,
            inset=inset,
            flat_support=flat_support,
            locations=locations,
            key_rotation=key_rotation,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports);
    } else if (stem_type == "round_cherry") {
        stem_round_cherry(
            key_height=row_height[row]+height_extra,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thickness,
            top_difference=top_difference,
            depth=depth, dish_tilt=dish_tilt[row],
            top_thickness=top_thickness,
            key_corner_radius=key_corner_radius,
            wall_thickness=wall_thickness,
            top_x=top_x, top_y=kat_top_y[row],
            outside_tolerance=outside_tolerance_x,
            inside_tolerance=inside_tolerance,
            inset=inset,
            flat_support=flat_support,
            locations=locations,
            key_rotation=key_rotation,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports);
    }
}

module KAM_keycap(row=1, length=18.3, height_extra=0, wall_thickness=1.65, dish_thickness=1, dish_fn=128, dish_depth=1, dish_invert=false, top_difference=6.35, key_rotation=[0,0,0], corner_radius=0.5, corner_radius_curve=1.5, legends=[""], legend_font_sizes=[6], legend_fonts=["Roboto"], legend_trans=[[0,0,0]], legend_trans2=[[0,0,0]], legend_rotation=[[0,0,0]], legend_rotation2=[[0,0,0]], legend_scale=[[0,0,0]], legend_underset=[[0,0,0]], homing_dot_length=0, homing_dot_width=0, homing_dot_x=0, homing_dot_y=0, homing_dot_z=0, polygon_layers=10, visualize_legends=false, debug=false) {
    row_height = dish_invert ? 8.05 : 9.05; // One less if we're generating a spacebar
    if (row < 1) {
        warning("We only support rows 1 for DSA profile caps!");
    }
    if (row > 1) {
        warning("We only support row 1 for DSA profile caps!");
    }
    width = 18.3;
    dish_type = dish_invert ? "cylinder" : "sphere"; // KAM spacebars actually use cylindrical tops
    dish_z = 0;
    top_y = 0;
    poly_keycap(
        height=row_height+height_extra, length=length, width=width, wall_thickness=wall_thickness,
        top_difference=top_difference, dish_tilt=0, dish_z=dish_z, dish_fn=dish_fn,
        dish_invert=dish_invert, top_y=top_y, dish_depth=dish_depth, dish_type=dish_type,
        dish_thickness=dish_thickness, corner_radius=corner_radius,
        corner_radius_curve=corner_radius_curve,
        legends=legends, legend_font_sizes=legend_font_sizes, legend_fonts=legend_fonts,
        legend_trans=legend_trans, legend_trans2=legend_trans2, legend_scale=legend_scale,
        legend_rotation=legend_rotation, legend_rotation2=legend_rotation2,
        legend_underset=legend_underset,
        polygon_layers=polygon_layers, polygon_layer_rotation=0, polygon_edges=4, polygon_curve=4.5,
        homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
        homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
        key_rotation=key_rotation,
        visualize_legends=visualize_legends, debug=debug);
}

// KAM stems are pretty simple (don't need anything special)
module KAM_stem(stem_type="box_cherry", key_height=9.05, key_length=18.3, key_width=18.3, height_extra=0, dish_depth=1, dish_thickness=1, dish_invert=false, depth=4, top_difference=6, wall_thickness=1.65, key_corner_radius=0.35, top_x=0, top_y=0, outside_tolerance_x=0.2, outside_tolerance_y=0.2, inside_tolerance=0.25, inset=0, top_thickness=0.6, side_support_thickness=0.8, side_supports=[0,0,0,0], flat_support=true, locations=[[0,0,0]], key_rotation=[0,0,0]) {
    if (stem_type == "box_cherry") {
        stem_box_cherry(
            key_height=key_height+height_extra,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thickness,
            top_difference=top_difference,
            depth=depth, dish_tilt=0,
            top_thickness=top_thickness,
            key_corner_radius=key_corner_radius,
            wall_thickness=wall_thickness,
            top_x=top_x, top_y=top_y,
            outside_tolerance_x=outside_tolerance_x,
            outside_tolerance_y=outside_tolerance_y,
            inside_tolerance=inside_tolerance,
            inset=inset,
            flat_support=flat_support,
            locations=locations,
            key_rotation=key_rotation,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports);
    } else if (stem_type == "round_cherry") {
        stem_round_cherry(
            key_height=key_height+height_extra,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thickness,
            top_difference=top_difference,
            depth=depth, dish_tilt=0,
            top_thickness=top_thickness,
            key_corner_radius=key_corner_radius,
            wall_thickness=wall_thickness,
            top_x=top_x, top_y=top_y,
            outside_tolerance=outside_tolerance_x,
            inside_tolerance=inside_tolerance,
            inset=inset,
            flat_support=flat_support,
            locations=locations,
            key_rotation=key_rotation,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports);
    }
}

// Riskable's keycap profile specifically made for 3D printing, the Riskeycap!
/* NOTES about the Riskeycap:
    * It's a non-sculpted (aka "all the same height") profile with a 8.2mm height (similar to DSA).
    * To print on it's side use: KEY_ROTATION = [0,110.1,0];
    * 1.5mm spherical dish (because that's my favorite in terms of feel--like your finger is getting kissed with every keypress).
    * Sides are flat so that it can be easily printed on its side.  This ensures that stems end up strong and the top will feel smooth right off the printer (no sanding required).
    * Stem is not inset so it can be printed flat if needed.
*/
module riskeycap(row=1, length=18.25, width=18.25, height_extra=0, wall_thickness=1.8, dish_thickness=0.9, dish_fn=64, dish_depth=1.5, dish_invert=false, top_difference=6, key_rotation=[0,0,0], corner_radius=1.25, corner_radius_curve=1.5, legends=[""], legend_font_sizes=[6], legend_fonts=["Roboto"], legend_trans=[[0,0,0]], legend_trans2=[[0,0,0]], legend_rotation=[[0,0,0]], legend_rotation2=[[0,0,0]], legend_scale=[[0,0,0]], legend_underset=[[0,0,0]], homing_dot_length=0, homing_dot_width=0, homing_dot_x=0, homing_dot_y=0, homing_dot_z=0, polygon_layers=10, visualize_legends=false, debug=false) {
    adjusted_height = dish_invert ? 6.5+height_extra : 8.2+height_extra; // A bit less if we're generating a spacebar because the dish_depth is bigger than is typical
    adjusted_dish_depth = dish_invert ? 1 : dish_depth; // Make it a smaller for inverted dishes
    if (row < 1) {
        warning("We only support rows 1 for Riskeycap profile caps!");
    }
    if (row > 1) {
        warning("We only support row 1 for Riskeycap profile caps!");
    }
    dish_type = "sphere";
    dish_z = 0;
    top_y = 0;
    poly_keycap(
        height=adjusted_height, length=length, width=width, wall_thickness=wall_thickness,
        top_difference=top_difference, dish_tilt=0, dish_z=dish_z, dish_fn=dish_fn,
        dish_invert=dish_invert, top_y=top_y, dish_depth=adjusted_dish_depth, dish_type=dish_type,
        dish_thickness=dish_thickness, corner_radius=corner_radius,
        corner_radius_curve=corner_radius_curve,
        legends=legends, legend_font_sizes=legend_font_sizes, legend_fonts=legend_fonts,
        legend_trans=legend_trans, legend_trans2=legend_trans2, legend_scale=legend_scale,
        legend_rotation=legend_rotation, legend_rotation2=legend_rotation2,
        legend_underset=legend_underset,
        polygon_layers=polygon_layers, polygon_layer_rotation=0, polygon_edges=4, polygon_curve=0,
        key_rotation=key_rotation,
        homing_dot_length=homing_dot_length, homing_dot_width=homing_dot_width,
        homing_dot_x=homing_dot_x, homing_dot_y=homing_dot_y, homing_dot_z=homing_dot_z,
        visualize_legends=visualize_legends, debug=debug);
}

// Riskeycap stems are very straightforward (nothing special required; mostly defaults)
module riskeystem(stem_type="box_cherry", key_height=8.2, key_length=18.41, key_width=18.41, height_extra=0, dish_depth=1.5, dish_thickness=0.9, dish_invert=false, depth=4, top_difference=5.25, wall_thickness=1.8, key_corner_radius=1.15, top_x=0, top_y=0, outside_tolerance_x=0.2, outside_tolerance_y=0.2, inside_tolerance=0.25, inset=1, top_thickness=0.6, side_support_thickness=0.8, side_supports=[0,0,0,0], flat_support=true, locations=[[0,0,0]], key_rotation=[0,0,0]) {
    adjusted_height = dish_invert ? 6.5+height_extra : 8.2+height_extra; // A bit less if we're generating a spacebar
    adjusted_dish_depth = dish_invert ? 1 : dish_depth; // Make it a smaller for inverted dishes
    if (stem_type == "box_cherry") {
        stem_box_cherry(
            key_height=adjusted_height+height_extra,
            key_length=key_length,
            key_width=key_width,
            dish_depth=adjusted_dish_depth,
            dish_thickness=dish_thickness,
            top_difference=top_difference,
            depth=depth, dish_tilt=0,
            top_thickness=top_thickness,
            key_corner_radius=key_corner_radius,
            wall_thickness=wall_thickness,
            top_x=top_x, top_y=top_y,
            outside_tolerance_x=outside_tolerance_x,
            outside_tolerance_y=outside_tolerance_y,
            inside_tolerance=inside_tolerance,
            inset=inset,
            flat_support=flat_support,
            locations=locations,
            key_rotation=key_rotation,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports);
    } else if (stem_type == "round_cherry") {
        stem_round_cherry(
            key_height=key_height+height_extra,
            key_length=key_length,
            key_width=key_width,
            dish_depth=dish_depth,
            dish_thickness=dish_thickness,
            top_difference=top_difference,
            depth=depth, dish_tilt=0,
            top_thickness=top_thickness,
            key_corner_radius=key_corner_radius,
            wall_thickness=wall_thickness,
            top_x=top_x, top_y=top_y,
            outside_tolerance=outside_tolerance_x,
            inside_tolerance=inside_tolerance,
            inset=inset,
            flat_support=flat_support,
            locations=locations,
            key_rotation=key_rotation,
            side_support_thickness=side_support_thickness,
            side_supports=side_supports);
    }
}

// Uncomment to test DCS:
//translate([0,9,0])
//    DCS_keycap(row=5);
//translate([0,9+KEY_UNIT,0])
//    DCS_keycap(row=1);
//translate([0,9+KEY_UNIT*2,0])
//    DCS_keycap(row=2);
//translate([0,9+KEY_UNIT*3,0])
//    DCS_keycap(row=3);
//translate([0,9+KEY_UNIT*4,0])
//    DCS_keycap(row=4);
//translate([0,9+KEY_UNIT*5,0])
//    DCS_keycap(row=4, dish_invert=true);

// Uncomment to test DSA
//translate([0,9,0])
//    DSA_keycap(row=1, dish_invert=true);
//translate([0,9+KEY_UNIT,0])
//    DSA_keycap(row=1);
//
//// Used this to verify the width of the dish:
//%translate([0,9+KEY_UNIT,7.3914/2]) cube([12.7,12.7,7.3914], center=true);

// Uncomment to test KAT
//translate([0,9,0])
//    KAT_keycap(row=1, dish_invert=true);
//translate([0,9+KEY_UNIT,0])
//    KAT_keycap(row=1);
//translate([0,9+KEY_UNIT*2,0])
//    KAT_keycap(row=2);
//translate([0,9+KEY_UNIT*3,0])
//    KAT_keycap(row=3);
//translate([0,9+KEY_UNIT*4,0])
//    KAT_keycap(row=4);
//translate([0,9+KEY_UNIT*5.45+0.2,0])
//    KAT_keycap(row=5);

// Uncomment to test KAM:
//translate([0,9,0])
//    KAM_keycap(row=5, length=19.05*6.25, dish_invert=true);
//translate([0,9+KEY_UNIT,0])
//    KAM_keycap(row=1);
//translate([0,9+KEY_UNIT*2,0])
//    KAM_keycap(row=2);
//translate([0,9+KEY_UNIT*3,0])
//    KAM_keycap(row=3);
//translate([0,9+KEY_UNIT*4,0])
//    KAM_keycap(row=4);
//translate([0,9+KEY_UNIT*5,0])
//    KAM_keycap(row=4);