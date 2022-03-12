// This .scad demonstrates what you want to set/override in order to make a snap-fit keycap+stem.

// You *could* just use this to make your keycap but sometimes it's easier to just modify these values in keycap_playground.scad.

include <keycap_playground.scad>

// Pick what you want to render (you can put a '%' in front of the name to make it transparent)
RENDER = ["keycap", "stem"]; // Supported values: keycap, stem, legends, row, row_stems, row_legends, custom
// NOTE: You'll want to render the keycap and stem separately in reality like so:
//RENDER = ["stem"]; // Render the stem and print it upside down
//RENDER = ["keycap"]; // Render the stem and print it on its side (90% of the time)

KEY_PROFILE = "riskeycap";
//KEY_ROTATION = [0,109.2,90]; // Use this amount of rotation for the stem (a little different than stock riskeycap rotation)
KEY_LENGTH = (KEY_UNIT*1-BETWEENSPACE);
KEY_WIDTH = (KEY_UNIT*1-BETWEENSPACE);
// Neat little trick to print the stem upside down and the keycap on its side:
KEY_ROTATION = (RENDER==["stem"]) ? [180,0,0] : [0,109.2,90];
UNIFORM_WALL_THICKNESS = false;
// Clip-in stems take up some space so we need slightly thinner outside walls in most cases:
WALL_THICKNESS = 0.45*1.85;
STEM_TOP_THICKNESS = 0.5; // This is the minimum you want for a 0.45mm nozzle
STEM_SNAP_FIT = true; // Tells poly_keycap() to add clips to the inside of the keycap
STEM_SIDES_WALL_THICKNESS = 0.65; // Any thinner than 0.65 is not recommended
STEM_WALLS_INSET = 1.15; // Makes it so the stem walls don't go all the way to the bottom of the keycap; works just like STEM_INSET but for the walls
// NOTE: The clips take up about 1mm of "inset space" so you need to set STEM_WALLS_INSET to some value greater than that.  Consider values above 1 to be the tolerance..  So a value of 1.15 would be 0.15mm of tolerance/wiggle room (for the stem walls pressing against the clips).
// TIP: If you give STEM_WALLS_INSET a bit more room than necessary (like say, 1.3) and use silicone caulk/sealant between the stem and keycap it have a cushioning effect whenever you press that keycap (it feels nice!).
STEM_WALLS_TOLERANCE = 0.2; // How much wiggle room the stem sides will get inside the keycap
STEM_LOCATIONS = [ // Where to place stems/stabilizers
    [0,0,0], // Dead center (don't comment this out when uncommenting below)
    // Standard examples (uncomment to use them):
//    [12,0,0], [-12,0,0], // Standard 2U, 2.25U, and 2.5U shift key
//    [0,12,0], [0,-12,0], // Standard 2U Numpad + or Enter
//    [50,0,0], [-50,0,0], // Cherry style 6.25U spacebar (most common)
//    [57,0,0], [-57,0,0], // Cherry style 7U spacebar
];
