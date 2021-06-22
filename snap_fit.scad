// This .scad demonstrates what you want to set/override in order to make a snap-fit keycap+stem.

// You *could* just use this to make your keycap but sometimes it's easier to just modify these values in keycap_playground.scad.

include <keycap_playground.scad>

// Pick what you want to render (you can put a '%' in front of the name to make it transparent)
RENDER = ["keycap", "stem"]; // Supported values: keycap, stem, legends, row, row_stems, row_legends, custom
// NOTE: You'll want to render the keycap and stem separately in reality

KEY_PROFILE = "riskeycap";
//KEY_ROTATION = [0,109.2,90]; // Use this amount of rotation for the stem (a little different than stock riskeycap rotation)
// Clip-in stems take up some space so we need slightly thinner outside walls in most cases:
WALL_THICKNESS = 0.45*1.85;
STEM_TOP_THICKNESS = 0.5; // This is the minimum you want for a 0.45mm nozzle
STEM_SNAP_FIT = true; // Tells poly_keycap() to add clips to the inside of the keycap
STEM_SIDES_WALL_THICKNESS = 0.65; // Any thinner than 0.65 is not recommended
STEM_WALLS_INSET = 1.15; // Makes it so the stem walls don't go all the way to the bottom of the keycap; works just like STEM_INSET but for the walls
// NOTE: The clips take up about 1mm of "inset space" so you need to set STEM_WALLS_INSET to some value greater than that.
STEM_WALLS_TOLERANCE = 0.2; // How much wiggle room the stem sides will get inside the keycap

render_keycap(RENDER);