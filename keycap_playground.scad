// Riskable's Keycap Playground -- Use this tool to try out all your cool keycap ideas.

// AUTHOR: Riskable <riskable@youknowwhat.com>
// VERSION: 1.3 (Changelog is at the bottom)

/* NOTES
    * Want to understand how to use this file? See: https://youtu.be/WDlRZMvisA4
    * TIP: If preview is slow/laggy try setting VISUALIZE_LEGENDS=1
    * TIP: PRINT KEYCAPS ON THEIR SIDE!  They'll turn out nice and smooth right off the printer!  Use the KEY_ROTATION feature to take care of it BUT DON'T FORGET the STEM_SIDE_SUPPORTS feature to enable built-in supports for the stem(s).  BUILT-IN SUPPORTS MUST BE CUT OFF AFTER PRINTING.  Cut off the support where it meets the interior wall of the keycap (with flush cutters) and it should easily break away from the side that supports the stem.
    * The default rendering mode (["keycap", "stem"]) will include inset (non-multi-material) legends automatically.  Adding "legends" to RENDER is something you only want to do if you're making multi-material keycaps...
    * To make a multi-material print just render and export "keycap", "stem", and "legends" as separate .stl files.  To save time you can render ["keycap", "stem"] and then just ["legends"].
    * TIP: Want to make a keycap that works (looks cool) with backlit/RGB LED keyboards?  Print the stem and legends in a transparent material (clear PETG is a very effective light pipe!).  You can also render the stem and legends as a single file: ["stem", "legends"] which will save time importing into your slicer later.
    * Have a lot of different legends/keycaps to render?  You can add all your legends to the ROW variable and then render ["row", "row_stems"] and ["row_legends"].
    * Having trouble lining up your legends?  Try setting VISUALIZE_LEGENDS=1!  It'll show you where they all are, their angles, etc.
    * The part of the stem that goes under the top (STEM_TOP_THICKNESS) is colored purple so you can easily see where the keycap ends and the stem begins.
    * Removable supports are colored GREEN (in preview mode).
*/

// TODO: Make presets for things like, "spacebar6.25", "shift2.25", "tab1.5" etc
// TODO: Add support for adding a bevel/rounded edge to the top of keycaps.
// TODO: Finish whole-keyboard generation support.

use <keycaps.scad>
use <stems.scad>
use <legends.scad>
use <utils.scad>
use <profiles.scad>

// Pick what you want to render (you can put a '%' in front of the name to make it transparent)
RENDER = ["keycap", "stem"]; // Supported values: keycap, stem, legends, row, row_stems, row_legends, custom
//RENDER = ["%keycap", "stem"]; // Can be useful for visualizing the stem inside the keycap
//RENDER = ["keycap"];
//RENDER = ["legends"];
//RENDER = ["legends", "stem"];
//RENDER = ["stem"];
//RENDER = ["underset_mask"]; // A thin layer under the top of they keycap meant to be darkened for underset legends
// Want to render a whole row of keycaps/stems/legends at a time?  You can do that here:
//RENDER = ["row", "row_stems"]; // For making whole keyboards at a time (with whole-keyboard inlaid art!)
//RENDER = ["row"];
//RENDER = ["row_legends"];
//RENDER = ["row_stems"];

// CONSTANTS
KEY_UNIT = 19.05; // Square that makes up the entire space of a key
BETWEENSPACE = 0.8; // The Betweenspace:  The void between realms...  And keycaps (for an 18.25mm keycap)

// BASIC KEYCAP PARAMETERS
// If you want to make a keycap using a common profile set this to one of: dcs, dss, dsa, kat, kam, riskeycap:
KEY_PROFILE = "riskeycap"; // Any value other than a supported profile (e.g. "dsa") will use the globals specified below.  In other words, an empty KEY_PROFILE means "just use the values specified here in this file."
KEY_ROW = 1; // NOTE: For a spacebar make sure you also set DISH_INVERT=true
// Some settings override profile settings but most will be ignored (if using a profile)
KEY_HEIGHT = 9; // The Z (NOTE: Dish values may reduce this a bit as they carve themselves out)
KEY_HEIGHT_EXTRA = 0.0; // If you're planning on sanding the keycap you can use this to make up for lost material (normally this is only useful when using a profile e.g. DSA)
// NOTE: You *can* just set KEY_LENGTH/KEY_WIDTH to something simple e.g. 18
KEY_LENGTH = (KEY_UNIT-BETWEENSPACE); // The X (NOTE: Increase DISH_FN if you make this >1U!)
// NOTE: If using a profile make sure KEY_LENGTH matches the profile's KEY_WIDTH for 1U keycaps!
KEY_WIDTH = (KEY_UNIT-BETWEENSPACE); // The Y (NOTE: If using POLYGON_EGDES>4 this will be ignored)
// NOTE: Spacebars don't seem to use BETWEENSPACE (for whatever reason).  So to make a spacebar just use "KEY_UNIT*<spacebar unit length>" and omit the "-BETWEENSPACE" part.  Or just be precise and give it a value like 119.0625 (19.05*6.25)
// NOTE: When making longer keycaps you may need to increase KEY_HEIGHT slightly in order for the height to be accurate.  I recommend giving it an extra 0.3mm per extra unit of length so 2U would be +0.3, 3U would be +0.6, etc BUT DOUBLE CHECK IT.  Do a side profile view and look at the ruler or render it and double-check the height in your slicer.
//KEY_ROTATION = [0,0,0]; // I *highly* recommend 3D printing keycaps on their front/back/sides! Try this:
KEY_ROTATION = [0,110.1,0]; // An example of how you'd rotate a keycap on its side.  Make sure to zoom in on the bottom to make sure it's *actually* going to print flat! This should be the correct rotation for riskeycap profile.
// NOTE: If you rotate a keycap to print on its side don't forget to add a built-in support via STEM_SIDE_SUPPORTS! [0,1,0,0] is what you want if you rotated to print on the right side.
KEY_TOP_DIFFERENCE = 5; // How much skinnier the key is at the top VS the bottom [x,y]
KEY_TOP_X = 0; // Move the keycap's top on the X axis (controls skew left/right)
KEY_TOP_Y = 0; // Move the keycap's top on the Y axis (controls skew forward/backward)
WALL_THICKNESS = 0.45*3; // Default: 0.45 extrusion width * 3 (nice and thick; feels/sounds good)

// DO THE DISHES!
DISH_X = 0; // Move the dish left/right
DISH_Y = 0; // Move the dish forward/backward
DISH_Z = 0; // Controls how deep into the top of the keycap the dish goes (e.g. -0.25)
DISH_TYPE = "cylinder"; // "inv_pyramid", "cylinder", "sphere" (aka "domed"), anything else: flat top
// NOTE: inv_pyramid doesn't work for making spacbars (kinda, "duh")
DISH_DEPTH = 1; // Distance between the top sides and the bottommost point in the dish (set to 0 for flat top)
// NOTE: When DISH_INVERT is true DISH_DEPTH becomes more like, "how far dish protrudes upwards"
DISH_THICKNESS = 1.2; // Amount of material that will be placed under the bottommost part of the dish
// NOTE: If you make DISH_THICKNESS too small legends might not print properly--even with a tiny nozzle.  In other words, a thick keycap top makes for nice clean (3D printed) legends.
DISH_TILT = -6; // How to rotate() the dish of the key (on the Y axis)
DISH_TILT_CURVE = false; // If you want a more organic ("tentacle"!) shape set this to true
DISH_INVERT = false; // Set to true for things like spacebars
DISH_FN = 128; // If you want to increase or decrease the resolution of the shapes used to make the dish (Tip: Don't go <64 for "sphere" dish types and don't go <128 for "cylinder")
// NOTE: DISH_FN does not apply if DISH_INVERT==true (because it would be too much; inverted dish doesn't need as much resolution)

// POLYGON/SHAPE MANIPULATION
POLYGON_LAYERS = 10; // Number of layers we're going to extrude (set to 1 to get a boring keycap)
POLYGON_LAYER_ROTATION = 0; // How much to rotate per layer (set to 0 for boring keycap). Try messing with this!  It's fun!
POLYGON_EDGES = 4; // How many sides the keycap will have (normal keycap is 4). Try messing with this too!
POLYGON_ROTATION = false; // If you want the top of the key to be rotated
// NOTE: If you're using POLYGON_ROTATION and you end up with holes in your keycap walls you may just need to increase WALL_THICKNESS
POLYGON_CURVE = 0; // If you want a "bowed" keycap (e.g. like DSA), increase this value
CORNER_RADIUS = 1; // Radius of the outside corners of the keycap
CORNER_RADIUS_CURVE = 1.5; // If you want the corner radius to get bigger as it goes up (WARNING: Set this too high and you'll end up with missing bits of your keycap! Check the height when messing with this)

// STEM STUFF
STEM_TYPE = "box_cherry"; // "box_cherry" (default), "round_cherry" (harder to print... strong)
STEM_HEIGHT = 4; // How far into the keycap's stem the switch's stem can go (4 is "normal keycap")
STEM_TOP_THICKNESS = 0.6; // The part that resides under the keycap, connecting stems and keycap together
STEM_INSIDE_TOLERANCE = 0.2; // Increases the size of the empty space(s) in the stem
STEM_OUTSIDE_TOLERANCE_X = 0.24; // Shrinks the stem a bit on the X axis (both axis for round_cherry)
STEM_OUTSIDE_TOLERANCE_Y = 0.24; // Shrinks the stem a bit on th Y axix (unused with round_cherry)
// For box stems (e.g. Kailh box) you want outside tolerances to be equal.  For Cherry stems you (usually) want the Y tolerance to be greater (since there's plenty of room on the sides).  In fact, you can go *negative* with STEM_OUTSIDE_TOLERANCE_X (e.g. -0.5) for extra strength!
// NOTE ABOUT STEM STRENGTH AND ACCURACY: Printing stems upright/flat with a 0.4mm nozzle is troublesome.  They work OK but they're usually quite tight.  It's better to print keys on their side (front or left/right) so that the layer lines run at an angle to the switch stem; they end up more accurate *and* much, much stronger.
STEM_INSET = 1; // How far to inset the stem (set to 0 to have the stem rest on the build plate which means you won't need supports when printing flat)
STEM_FLAT_SUPPORT = false; // Add built-in support for the stem when printing flat (if inset)
STEM_SIDE_SUPPORT_THICKNESS = 0.8; // 0.8 works well for most things
// This controls which sides get (internal, under-the-top) stem supports (for printing on the side):
STEM_SIDE_SUPPORTS = [0,1,0,0]; // Left, right, front, back
// NOTE: You can only enable left/right supports *or* front/back supports.  Not both at the same time. (TODO: Fix that...  Maybe?  Why would you ever need *both* say, a left support *and* a top support at the same time?)
STEM_SUPPORT_DISTANCE = 0.2; // Controls the air gap between the stem and its support
STEM_LOCATIONS = [ // Where to place stems/stabilizers
    [0,0,0], // Dead center (don't comment this out when uncommenting below)
    // Standard examples (uncomment to use them):
//    [12,0,0], [-12,0,0], // Standard 2U, 2.25U, and 2.5U shift key
//    [0,12,0], [0,-12,0], // Standard 2U Numpad + or Enter
//    [50,0,0], [-50,0,0], // Cherry style 6.25U spacebar (most common)
//    [57,0,0], [-57,0,0], // Cherry style 7U spacebar
];

// If you want "homing dots" for home row keys:
HOMING_DOT_LENGTH = 0; // Set to something like "3" for a good, easy-to-feel "dot"
HOMING_DOT_WIDTH = 1; // Default: 1
HOMING_DOT_X = 0; // 0 == Center
HOMING_DOT_Y = -KEY_WIDTH/4; // Default: Move it down towards the front a bit
HOMING_DOT_Z = -0.35; // 0 == Right at KEY_HEIGHT (dish type makes a big difference here)
// NOTE: ADA specifies 0.5mm as the ideal braille dot height so that's what I recommend for homing dots too!  Though, 0.3mm seems to be reasonably "feelable" in my testing.  Experiment!

// LEGENDARY!
LEGENDS = [ // As many legends as you want
//    "1", "!", // Just an example of multiple legends (uncomment to try it!)
//    "☺", // Unicode characters work too!
];
// NOTE: Legends might not look quite right until final render (F6)
LEGEND_FONTS = [ // Each legend can use its own font. If not specified the first font definition will be used
    "Arial Black:style=Regular", // Position/index must match the index in LEGENDS
//    "Franklin Gothic Medium:style=Regular" // Normal-ish keycap legend font
    // Favorite fonts for legends: Roboto, Aharoni, Ubuntu, Cabin, Noto, Code2000, Franklin Gothic Medium
]; // Tip: "Noto" and "Code2000" have nearly every emoji/special/funky unicode chars
LEGEND_FONT_SIZES = [ // Each legend can have its own font size
    5.5, // Position/index must match the index in LEGENDS (this is the first legend)
    4, // Second legend...  etc
];
/* NOTES ABOUT LEGEND TRANSLATION AND ROTATION
    * Legends are translated and rotated in the following order:
        translate(trans2) rotate(rotation2) translate(trans) rotate(rotation)
    * Normally you only need LEGEND_TRANS and LEGEND_ROTATION but if you want to put legends on the sides you need to rotate them twice (once for position and once for making them rightside up).
    * LEGEND_TRANS2 is probably unnecessary but may make a few folks lives easier by not having to think as much :)
*/
LEGEND_TRANS = [ // You can translate() legends around however you like.
    [-0.15,KEY_TOP_Y,0], // A good default (FYI: -0.15mm works around OpenSCAD's often-broken font centering)
    [4.15,3,1],
    [4.40,KEY_TOP_Y+2.25,0], // Top right (mostly)
];
LEGEND_ROTATION = [ // How to rotate each legend. If not specified defaults to [0,0,0]
    [0,0,0],
//    [60,0,0], // Example of how you'd put a legend on the front (try it!)
];
LEGEND_TRANS2 = [ // Second translate() call (see note above)
    [0,0,0],
];
LEGEND_ROTATION2 = [ // Sometimes you want to rotate again after translate(); that's what this is for
    [0,0,0],
];
LEGEND_SCALE = [ // Want to shrink/stretch your legends on a particular axis?  Do that here:
    [1,1,1],
];
LEGEND_UNDERSET = [ // This is a *very* special thing; see long note about it below...
    [0,0,0], // Normally only want to adjust the Z axis (3rd item) if you're using this feature
];
/* All about underset legends:

    So say you want your legend to be *completely invisible* unless your keycap is lit up (from underneath).  You can do that with LEGEND_UNDERSET!  It's kind of like a LEGEND_TRANS3 that gets applied *after* the legend has been put into place by LEGEND_TRANS, LEGEND_TRANS2, LEGEND_ROTATION, LEGEND_ROTATION2, and LEGEND_SCALE then interesction()'d but *before* it gets difference()'d against the keycap.  So if you set LEGEND_UNDERSET to something like [0,0,-0.5] your legend will be moved down (on the z axis) 0.5mm *while still retaining the exact shape of the keycap/dish*.
    
    In order for that to work properly though you'll need to make your legend and stem in a transparent material (so the light can make it all the way through).  You'll also probably want to apply a modifier mesh (or similar) in your slicer to make sure that at least one layer underneath the keycap gets printed in a *very* opaque material (e.g. black) so as to maximize the amount of contrast for your legend.
    
    Lastly, you'll want to set your DISH_THICKNESS to as thin as you can bear in order to minimize the amount of plastic that the light needs to pass through before it reaches the underside of the top of the keycap.
*/

// TODO: This injection molding thing...
// If you want an internal support structure under the keycap (between stems) you can add them here:
RIBS = [ // Useful for injection molding
    // Not supported yet!
];

// When generating a whole row of keys at a time (e.g. on the command line) use this ROW variable:
//ROW = [];
/* Example: ROW=[["Q"],["W"],["E"],["R"],["T"],["Y"],["U"],["I"],["O"],["P"]];
   (It's an array of legend arrays like ROW=[LEGENDS1,LEGENDS2,LEGENDS3,...])
*/
ROW=[["`","~"],["1","!"],["2","@"],["3","#"],["4","$"],["5","%"],["6","^"],["7","&"],["8","*"],["9","("],["0",")"],["-","_"],["=","+"]];
ROW_SPACING = KEY_UNIT; // You can change this to something like "KEY_HEIGHT+3" if printing keycaps on their side...
//ROW_SPACING = KEY_HEIGHT+3;

/* NOTES ABOUT SCRIPTING/GENERATING KEYCAPS ON THE COMMAND LINE:
    * Here's an example (bash) where I generate the whole top row of regular keys (QWERTY):
        ROW='[["Q"],["W"],["E"],["R"],["T"],["Y"],["U"],["I"],["O"],["P"]];'; openscad -o qwertyuiop.stl -D "ROW=${ROW}" keycap_playground.scad
      That would generate all those keys and save them in a single .stl named qwertyiop.stl
*/

// DEBUGGING FEATURES
VISUALIZE_LEGENDS = 0; // Set to true to have the legends appear via %
DEBUG = false; // Set this to true if you want poly_keycap() to spit out all it's variables in the console

// YOU CAN IGNORE EVERYTHING BELOW THIS POINT (unless you're curious how it works)

// Generates a keycap using global variables but you can override the legends (for generating whole rows at a time)
module key_using_globals(legends) {
    _legends = legends ? legends : LEGENDS;
    poly_keycap(
        height=KEY_HEIGHT, length=KEY_LENGTH, width=KEY_WIDTH, wall_thickness=WALL_THICKNESS,
        top_difference=KEY_TOP_DIFFERENCE, dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
        top_x=KEY_TOP_X, top_y=KEY_TOP_Y, dish_depth=DISH_DEPTH,
        dish_x=DISH_X, dish_y=DISH_Y, dish_z=DISH_Z, dish_thickness=DISH_THICKNESS, dish_fn=DISH_FN,
        legends=_legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
        legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
        legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2, legend_underset=LEGEND_UNDERSET,
        polygon_layers=POLYGON_LAYERS, polygon_layer_rotation=POLYGON_LAYER_ROTATION,
        polygon_edges=POLYGON_EDGES, polygon_curve=POLYGON_CURVE,
        dish_type=DISH_TYPE, corner_radius=CORNER_RADIUS, corner_radius_curve=CORNER_RADIUS_CURVE,
        visualize_legends=VISUALIZE_LEGENDS, polygon_rotation=POLYGON_ROTATION,
        homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
        homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
        key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
}

// Generates a keycap using global variables without legends so we can do an intersection() that generates the legends as an independent object
module key_without_legends() {
    // NOTE: Removed a few arguments that won't impact this module's purpose (just to save space)
    poly_keycap(
        height=KEY_HEIGHT, length=KEY_LENGTH, width=KEY_WIDTH, wall_thickness=WALL_THICKNESS,
        top_difference=KEY_TOP_DIFFERENCE, dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
        top_x=KEY_TOP_X, top_y=KEY_TOP_Y, dish_depth=DISH_DEPTH,
        dish_x=DISH_X, dish_y=DISH_Y, dish_z=DISH_Z, dish_thickness=DISH_THICKNESS, dish_fn=DISH_FN,
        polygon_layers=POLYGON_LAYERS, polygon_layer_rotation=POLYGON_LAYER_ROTATION,
        polygon_edges=POLYGON_EDGES, polygon_curve=POLYGON_CURVE,
        dish_type=DISH_TYPE, corner_radius=CORNER_RADIUS, corner_radius_curve=CORNER_RADIUS_CURVE,
        homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
        homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
        visualize_legends=VISUALIZE_LEGENDS, polygon_rotation=POLYGON_ROTATION,
        key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
}

// Renders a stem and stabilizers using global values
module stem_using_globals() {
    // TODO: Support more stem types
    if (STEM_TYPE == "box_cherry") {
        stem_box_cherry(
            key_height=KEY_HEIGHT+KEY_HEIGHT_EXTRA,
            key_length=KEY_LENGTH,
            key_width=KEY_WIDTH,
            dish_depth=DISH_DEPTH,
            dish_thickness=DISH_THICKNESS,
            top_difference=KEY_TOP_DIFFERENCE,
            depth=STEM_HEIGHT, dish_tilt=DISH_TILT,
            top_thickness=STEM_TOP_THICKNESS,
            key_corner_radius=CORNER_RADIUS,
            wall_thickness=WALL_THICKNESS,
            top_x=KEY_TOP_X, top_y=KEY_TOP_Y,
            outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
            outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
            inside_tolerance=STEM_INSIDE_TOLERANCE,
            inset=STEM_INSET,
            flat_support=STEM_FLAT_SUPPORT,
            side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
            side_supports=STEM_SIDE_SUPPORTS,
            support_distance=STEM_SUPPORT_DISTANCE,
            locations=STEM_LOCATIONS,
            key_rotation=KEY_ROTATION);
    } else if (STEM_TYPE == "round_cherry") {
        stem_round_cherry(
            key_height=KEY_HEIGHT+KEY_HEIGHT_EXTRA,
            key_length=KEY_LENGTH,
            key_width=KEY_WIDTH,
            dish_depth=DISH_DEPTH,
            dish_thickness=DISH_THICKNESS,
            top_difference=KEY_TOP_DIFFERENCE,
            depth=STEM_HEIGHT, dish_tilt=DISH_TILT,
            top_thickness=STEM_TOP_THICKNESS,
            key_corner_radius=CORNER_RADIUS,
            wall_thickness=WALL_THICKNESS,
            top_x=KEY_TOP_X, top_y=KEY_TOP_Y,
            outside_tolerance=STEM_OUTSIDE_TOLERANCE_X,
            inside_tolerance=STEM_INSIDE_TOLERANCE,
            inset=STEM_INSET,
            flat_support=STEM_FLAT_SUPPORT,
            side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
            side_supports=STEM_SIDE_SUPPORTS,
            support_distance=STEM_SUPPORT_DISTANCE,
            locations=STEM_LOCATIONS,
            key_rotation=KEY_ROTATION);
    }
}

module stem_top_using_globals() {
    stem_top(
        KEY_HEIGHT, KEY_LENGTH, KEY_WIDTH, DISH_DEPTH, DISH_THICKNESS, KEY_TOP_DIFFERENCE,
        dish_tilt=DISH_TILT, wall_thickness=WALL_THICKNESS, key_corner_radius=CORNER_RADIUS,
        top_x=KEY_TOP_X, top_y=KEY_TOP_Y, top_thickness=STEM_TOP_THICKNESS, key_rotation=KEY_ROTATION);
}

// This takes care of rendering whatever's configured via RENDER:
module handle_render(what, legends) {
    if (what=="legends") {
    // NOTE: just_legends() uses children() which is why there's no semicolon after it
        if (KEY_PROFILE == "dsa") {
            just_legends(height=KEY_HEIGHT+KEY_HEIGHT_EXTRA,
                legends=legends, polygon_layers=POLYGON_LAYERS,
                legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION)
                    DSA_keycap(row=KEY_ROW, wall_thickness=WALL_THICKNESS,
                        polygon_layers=POLYGON_LAYERS, dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                        visualize_legends=VISUALIZE_LEGENDS,
                        homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                        homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                        key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "dcs") {
            just_legends(height=KEY_HEIGHT+KEY_HEIGHT_EXTRA,
                dish_tilt=DISH_TILT, dish_tilt_curve=false, 
                polygon_layers=POLYGON_LAYERS, legends=legends,
                legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION)
                    DCS_keycap(row=KEY_ROW, wall_thickness=WALL_THICKNESS,
                        corner_radius=CORNER_RADIUS, polygon_layers=POLYGON_LAYERS,
                        dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                        visualize_legends=VISUALIZE_LEGENDS,
                        homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                        homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                        key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "kat") {
            just_legends(height=KEY_HEIGHT+KEY_HEIGHT_EXTRA,
                dish_tilt=DISH_TILT, dish_tilt_curve=false, 
                polygon_layers=POLYGON_LAYERS, legends=legends,
                legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION)
                    KAT_keycap(row=KEY_ROW, wall_thickness=WALL_THICKNESS,
                        polygon_layers=POLYGON_LAYERS,
                        dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                        visualize_legends=VISUALIZE_LEGENDS,
                        homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                        homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                        key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "kam") {
            just_legends(height=KEY_HEIGHT+KEY_HEIGHT_EXTRA,
                dish_tilt=DISH_TILT, dish_tilt_curve=false, 
                polygon_layers=POLYGON_LAYERS, legends=legends,
                legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION)
                    KAM_keycap(row=KEY_ROW, wall_thickness=WALL_THICKNESS,
                        polygon_layers=POLYGON_LAYERS, dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                        visualize_legends=VISUALIZE_LEGENDS,
                        homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                        homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                        key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "riskeycap") {
            just_legends(height=KEY_HEIGHT+KEY_HEIGHT_EXTRA,
                dish_tilt=DISH_TILT, dish_tilt_curve=false, 
                polygon_layers=POLYGON_LAYERS, legends=legends,
                legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION)
                    riskeycap(row=KEY_ROW, wall_thickness=WALL_THICKNESS,
                        polygon_layers=POLYGON_LAYERS, dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                        visualize_legends=VISUALIZE_LEGENDS,
                        homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                        homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                        key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else {
            just_legends(height=KEY_HEIGHT+KEY_HEIGHT_EXTRA,
                dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
                polygon_layers=POLYGON_LAYERS, legends=legends,
                legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION)
                    key_without_legends();
        }
    } else if (what=="underset_mask") {
        difference() {
            stem_top_using_globals();
            just_legends(height=KEY_HEIGHT+KEY_HEIGHT_EXTRA,
                dish_tilt=DISH_TILT, dish_tilt_curve=DISH_TILT_CURVE,
                polygon_layers=POLYGON_LAYERS, legends=legends,
                legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                legend_underset=LEGEND_UNDERSET, key_rotation=KEY_ROTATION);
        }
    } else if (what=="keycap") {
        if (KEY_PROFILE == "dsa") {
            DSA_keycap(row=KEY_ROW, length=KEY_LENGTH, height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                legends=legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                polygon_layers=POLYGON_LAYERS, dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
                homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "dcs") {
            DCS_keycap(row=KEY_ROW, length=KEY_LENGTH, height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                legends=legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                corner_radius=CORNER_RADIUS, polygon_layers=POLYGON_LAYERS,
                dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
                homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "dss") {
            DSS_keycap(row=KEY_ROW, length=KEY_LENGTH, height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                legends=legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                corner_radius=CORNER_RADIUS, polygon_layers=POLYGON_LAYERS,
                dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
                homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "kat") {
            KAT_keycap(row=KEY_ROW, length=KEY_LENGTH, height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                legends=legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                polygon_layers=POLYGON_LAYERS,
                dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
                homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "kam") {
            KAM_keycap(row=KEY_ROW, length=KEY_LENGTH, height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                legends=legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                polygon_layers=POLYGON_LAYERS,
                dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
                homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "riskeycap") {
            riskeycap(row=KEY_ROW, length=KEY_LENGTH, height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                legends=legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                polygon_layers=POLYGON_LAYERS,
                dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
                homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else {
            key_using_globals(legends=legends);
        }
    } else if (what=="%keycap") {
        if (KEY_PROFILE == "dsa") {
            %DSA_keycap(row=KEY_ROW, length=KEY_LENGTH, height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                legends=legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                polygon_layers=POLYGON_LAYERS, dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
                homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "dcs") {
            %DCS_keycap(row=KEY_ROW, length=KEY_LENGTH, height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                legends=legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                corner_radius=CORNER_RADIUS, polygon_layers=POLYGON_LAYERS,
                dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
                homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "dss") {
            %DSS_keycap(row=KEY_ROW, length=KEY_LENGTH, height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                legends=legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                corner_radius=CORNER_RADIUS, polygon_layers=POLYGON_LAYERS,
                dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
                homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "kat") {
            %KAT_keycap(row=KEY_ROW, length=KEY_LENGTH, height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                legends=legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                corner_radius=CORNER_RADIUS, polygon_layers=POLYGON_LAYERS,
                dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
                homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "kam") {
            %KAM_keycap(row=KEY_ROW, length=KEY_LENGTH, height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                legends=legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                corner_radius=CORNER_RADIUS, polygon_layers=POLYGON_LAYERS,
                dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
                homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else if (KEY_PROFILE == "riskeycap") {
            %riskeycap(row=KEY_ROW, length=KEY_LENGTH, height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                legends=legends, legend_font_sizes=LEGEND_FONT_SIZES, legend_fonts=LEGEND_FONTS,
                legend_trans=LEGEND_TRANS, legend_trans2=LEGEND_TRANS2, legend_scale=LEGEND_SCALE,
                legend_rotation=LEGEND_ROTATION, legend_rotation2=LEGEND_ROTATION2,
                corner_radius=CORNER_RADIUS, polygon_layers=POLYGON_LAYERS,
                dish_fn=DISH_FN, dish_thickness=DISH_THICKNESS,
                visualize_legends=VISUALIZE_LEGENDS, legend_underset=LEGEND_UNDERSET,
                homing_dot_length=HOMING_DOT_LENGTH, homing_dot_width=HOMING_DOT_WIDTH,
                homing_dot_x=HOMING_DOT_X, homing_dot_y=HOMING_DOT_Y, homing_dot_z=HOMING_DOT_Z,
                key_rotation=KEY_ROTATION, dish_invert=DISH_INVERT, debug=DEBUG);
        } else {
            %key_using_globals(legends=legends);
        }
    } else if (what=="stem") {
        if (KEY_PROFILE == "dsa") {
            DSA_stem(
                stem_type=STEM_TYPE,
                wall_thickness=WALL_THICKNESS,
                key_length=KEY_LENGTH,
                height_extra=KEY_HEIGHT_EXTRA,
                inset=STEM_INSET,
                dish_thickness=DISH_THICKNESS,
                dish_invert=DISH_INVERT,
                flat_support=STEM_FLAT_SUPPORT,
                side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
                side_supports=STEM_SIDE_SUPPORTS,
                outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
                outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
                inside_tolerance=STEM_INSIDE_TOLERANCE,
                locations=STEM_LOCATIONS,
                key_rotation=KEY_ROTATION);
        } else if (KEY_PROFILE == "dcs") {
            DCS_stem(
                row=KEY_ROW,
                stem_type=STEM_TYPE,
                key_length=KEY_LENGTH,
                height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                inset=STEM_INSET,
                dish_thickness=DISH_THICKNESS,
                dish_invert=DISH_INVERT,
                flat_support=STEM_FLAT_SUPPORT,
                side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
                side_supports=STEM_SIDE_SUPPORTS,
                outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
                outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
                inside_tolerance=STEM_INSIDE_TOLERANCE,
                locations=STEM_LOCATIONS,
                key_rotation=KEY_ROTATION);
        } else if (KEY_PROFILE == "dss") {
            DSS_stem(
                row=KEY_ROW,
                stem_type=STEM_TYPE,
                key_length=KEY_LENGTH,
                height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                inset=STEM_INSET,
                dish_thickness=DISH_THICKNESS,
                dish_invert=DISH_INVERT,
                flat_support=STEM_FLAT_SUPPORT,
                side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
                side_supports=STEM_SIDE_SUPPORTS,
                outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
                outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
                inside_tolerance=STEM_INSIDE_TOLERANCE,
                locations=STEM_LOCATIONS,
                key_rotation=KEY_ROTATION);
        } else if (KEY_PROFILE == "kat") {
            KAT_stem(
                row=KEY_ROW,
                stem_type=STEM_TYPE,
                key_length=KEY_LENGTH,
                height_extra=KEY_HEIGHT_EXTRA,
                wall_thickness=WALL_THICKNESS,
                inset=STEM_INSET,
                dish_thickness=DISH_THICKNESS,
                dish_invert=DISH_INVERT,
                flat_support=STEM_FLAT_SUPPORT,
                side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
                side_supports=STEM_SIDE_SUPPORTS,
                outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
                outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
                inside_tolerance=STEM_INSIDE_TOLERANCE,
                locations=STEM_LOCATIONS,
                key_rotation=KEY_ROTATION);
        } else if (KEY_PROFILE == "kam") {
            KAM_stem(
                stem_type=STEM_TYPE,
                wall_thickness=WALL_THICKNESS,
                key_length=KEY_LENGTH,
                height_extra=KEY_HEIGHT_EXTRA,
                inset=STEM_INSET,
                dish_thickness=DISH_THICKNESS,
                dish_invert=DISH_INVERT,
                flat_support=STEM_FLAT_SUPPORT,
                side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
                side_supports=STEM_SIDE_SUPPORTS,
                outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
                outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
                inside_tolerance=STEM_INSIDE_TOLERANCE,
                locations=STEM_LOCATIONS,
                key_rotation=KEY_ROTATION);
        } else if (KEY_PROFILE == "riskeycap") {
            riskeystem(
                stem_type=STEM_TYPE,
                wall_thickness=WALL_THICKNESS,
                key_length=KEY_LENGTH,
                height_extra=KEY_HEIGHT_EXTRA,
                inset=STEM_INSET,
                dish_thickness=DISH_THICKNESS,
                dish_invert=DISH_INVERT,
                flat_support=STEM_FLAT_SUPPORT,
                side_support_thickness=STEM_SIDE_SUPPORT_THICKNESS,
                side_supports=STEM_SIDE_SUPPORTS,
                outside_tolerance_x=STEM_OUTSIDE_TOLERANCE_X,
                outside_tolerance_y=STEM_OUTSIDE_TOLERANCE_Y,
                inside_tolerance=STEM_INSIDE_TOLERANCE,
                locations=STEM_LOCATIONS,
                key_rotation=KEY_ROTATION);
        } else { // Use globals
            stem_using_globals();
        }
    }
}

for (what_to_render=RENDER) {
    if (what_to_render=="row") { // For rendering a whole row of keys (use ROW variable)
        note("HAVE PATIENCE! Rendering all keycaps in ROW variable...");
        for (i=[0:1:len(ROW)-1]) {
            translate([ROW_SPACING*i,0,0]) handle_render("keycap", legends=ROW[i]);
        }
    } else if (what_to_render=="row_stems") { // For rendering a whole row of stems
        note("HAVE PATIENCE! Rendering all stems in ROW variable...");
        for (i=[0:1:len(ROW)-1]) {
            translate([ROW_SPACING*i,0,0]) handle_render("stem", legends=ROW[i]);
        }
    } else if (what_to_render=="row_legends") { // For rendering a whole row of legends
        note("HAVE PATIENCE! Rendering all legends in ROW variable...");
        for (i=[0:1:len(ROW)-1]) {
            translate([ROW_SPACING*i,0,0]) handle_render("legends", legends=ROW[i]);
        }
    } else if (what_to_render=="custom") { // This is a work-in-progress.  You can ignore it for now.
//        difference() {
        // Example of generating mutliple keycaps at once (typical staggered keyboard alphas and number row):
//            union() {
//                for (i=[1:12]) {
//                    translate([KEY_UNIT*i,0,0]) key_using_globals();
//                }
//                for (i=[1:11]) {
//                    translate([9+KEY_UNIT+KEY_UNIT*i,-KEY_UNIT,0]) key_using_globals();
//                }
//                for (i=[1:10]) {
//                    translate([18+KEY_UNIT+KEY_UNIT*i,-KEY_UNIT*2,0]) key_using_globals();
//                }
//                for (i=[1:9]) {
//                    translate([27+KEY_UNIT+KEY_UNIT*i,-KEY_UNIT*3,0]) key_using_globals();
//                }
//            }
            // Import an .svg and make a silhouette against the keycaps
//            svg_scale = 0.1;
//            translate([95,-66,KEY_HEIGHT-2]) linear_extrude(height=5, center=true, convexity=10)
//                scale([svg_scale,svg_scale,svg_scale]) rotate([0,0,0]) import(file="riskable_logo.dxf", scale=10);
        //    union() {
        //        translate([56,-60,KEY_HEIGHT-4.5]) linear_extrude(height=5)
        //            text("➤", size=70, font="DejaVu Sans");
        //        mirror([1,0,0]) translate([-210,-60,KEY_HEIGHT-4.5]) linear_extrude(height=5)
        //            text("➤", size=70, font="DejaVu Sans");
        //    }
//        }
    } else {
        handle_render(what_to_render, legends=LEGENDS); // Normal rendering of a single keycap
    }
}

/* CHANGELOG:
    1.3:
        * Fixed a bug where underset legends weren't working with keycap profiles.
    1.2:
        * Fixed a bug where legends weren't being rotated correctly if you were using a profile with DISH_TILT_CURVE set to true.
        * Added DSS keycap profile.
        * The default is now riskeycap profile rotated on its side with the correct side support enabled.  Seems like it's best to have a good 3D-printable example as the default =)
        * Modified a few default values to be more "normal".
        * Added/modified helpful comments.
    1.1:
        * Built-in supports for extra stems now work for vertically-long keycaps like numpad enter keys.
        * Added some more helpful comments.
        * Riskeycap profile has been updated to the latest version (5.0).  This is the result of much typing and experimentation.
    1.0:
        * Initial release of the Keycap Playgound.
*/