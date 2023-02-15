#!/usr/bin/env python3

"""
Generates a whole keyboard's worth of keycaps (and a few extras). Best way
to use this script is from within the `keycap_playground` directory.

.. bash::

    $ ./scripts/riskeycap_full.py --out /tmp/output_dir

.. note::

    Make sure you add the correct path to colorscad.sh if you want
    multi-material keycaps!

Fonts used by this script:
--------------------------

 * Gotham Rounded:style=Bold
 * Arial Black:style=Regular
 * Aharoni
 * FontAwesome
 * Font Awesome 6 Free:style=Solid
 * Hack
 * Material Design Icons:style=Regular
 * Code2000
 * Agave
 * DejaVu Sans:style=Bold
 * Noto
"""

# stdlib imports
import os, sys
from pathlib import Path
import json
import argparse
from copy import deepcopy
from subprocess import getstatusoutput
# 3rd party stuff
from colorama import Fore, Back, Style
from colorama import init as color_init
color_init()
# Our own stuff
from keycap import Keycap

# Change these to the correct paths in your environment:
OPENSCAD_PATH = Path("/home/riskable/downloads/OpenSCAD-2022.12.06.ai12948-x86_64.AppImage")
COLORSCAD_PATH = Path("/home/riskable/downloads/colorscad/colorscad.sh")

KEY_UNIT = 19.05 # Square that makes up the entire space of a key
BETWEENSPACE = 0.8 # Space between keycaps
FILE_TYPE = "3mf" # 3mf or stl

class riskeycap_base(Keycap):
    """
    Base keycap definitions for the riskeycap profile + our personal prefs.
    """
    def __init__(self, **kwargs):
        self.openscad_path = OPENSCAD_PATH
        self.colorscad_path = COLORSCAD_PATH
        super().__init__(**kwargs,
            openscad_path=self.openscad_path,
            colorscad_path=self.colorscad_path)
        self.render = ["keycap", "stem"]
        self.file_type = FILE_TYPE
        self.key_profile = "riskeycap"
        self.key_rotation = [0,110.1,-90]
        self.wall_thickness = 0.45*2.25
        self.uniform_wall_thickness = True
        self.dish_thickness = 1.0 # Note: Not actually used
        self.dish_corner_fn = 40 # Save some rendering time
        self.polygon_layers = 4  # Ditto
        # self.stem_type = "alps"
        self.stem_type = "box_cherry"
        self.stem_walls_inset = 0
        self.stem_top_thickness = 0.65 # Note: Not actually used
        self.stem_inside_tolerance = 0.175
        self.stem_side_supports = [0,0,0,0]
        self.stem_locations = [[0,0,0]]
        self.stem_sides_wall_thickness = 0.8; # Thick (good sound/feel)
        # Because we do strange things we need legends bigger on the Z
        self.scale = [
            [1,1,3],
            [1,1.75,3], # For the pipe to make it taller/more of a divider
            [1,1,3],
        ]
        self.fonts = [
            "Gotham Rounded:style=Bold",
            "Gotham Rounded:style=Bold",
            "Arial Black:style=Regular",
        ]
        self.font_sizes = [
            5.5,
            4, # Gotham Rounded second legend (top right)
            4, # Front legend
        ]
        self.trans = [
            [-3,-2.6,2], # Lower left corner Gotham Rounded
            [3.5,3,1], # Top right Gotham Rounded
            [0.15,-3,2], # Front legend
        ]
        # Legend rotation
        self.rotation = [
            [0,-20,0],
            [0,-20,0],
            [68,0,0],
        ]
        # Disabled this check because you'd have to be crazy to NOT use fast-csg
        # at this point haha...
        # # Check the OpenSCAD version to see if we can enable fast-csg
        # self.openscad_version = 0
        # self.enable_fast_csg = ""
        # retcode, output = getstatusoutput(f"{self.openscad_path} --version")
        # if retcode > 0:
        #     raise OpenSCADException("Could not run OpenSCAD.")
        # else:
        #     # Examples of retcode, output:
        #     # (0, 'OpenSCAD version 2021.01')
        #     # (0, 'OpenSCAD version 2022.12.06.ai12948')
        #     openscad_full_version = output.split()[2]
        #     self.openscad_version = int(openscad_full_version.split('.')[0])
        #     if self.openscad_version < 2022:
        #         raise OpenSCADException("ERROR: This script requires OpenSCAD "
        #               "version 2022 or later (found version "
        #               f"{openscad_full_version})")
        #     if self.openscad_version >= 2022:
        #         self.enable_fast_csg = "--enable=fast-csg"
        self.postinit(**kwargs)

class riskeycap_alphas(riskeycap_base):
    """
    Basic alphanumeric characters (centered, big legend)
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes = [
            4.5, # Regular Gotham Rounded
            4,
            4, # Front legend
        ]
        self.trans = [
            [2.6,0,0], # Centered when angled -20°
            [3.5,3,1], # Top right Gotham Rounded
            [0.15,-3,2], # Front legend
        ]
        self.postinit(**kwargs)

class riskeycap_alphas_homing_dot(riskeycap_alphas):
    """
    Same as regular alpha but with a 3mm-wide homing "dot"
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.homing_dot_length = 3
        self.homing_dot_width = 1
        self.homing_dot_x = 0
        self.homing_dot_y = -3
        self.homing_dot_z = -0.45

class riskeycap_numrow(riskeycap_base):
    """
    Number row numbers are slightly different
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.fonts = [
            "Gotham Rounded:style=Bold", # Main char
            "Gotham Rounded:style=Bold", # Pipe character
            "Gotham Rounded:style=Bold", # Symbol
            "Arial Black:style=Regular", # F-key
        ]
        self.font_sizes = [
            4.5, # Regular character
            4.5, # Pipe
            4.5, # Regular Gotham Rounded symbols
            3.5, # Front legend
        ]
        self.trans = [
            [-0.3,0,0], # Left Gotham Rounded
            [2.6,0,0], # Center Gotham Rounded |
            [5,0,1], # Right-side Gotham symbols
            [0.15,-2,2], # F-key
        ]
        self.rotation = [
            [0,-20,0],
            [0,-20,0],
            [0,-20,0],
            [68,0,0],
        ]
        self.scale = [
            [1,1,3],
            [1,1.75,3], # For the pipe to make it taller/more of a divider
            [1,1,3],
            [1,1,3],
        ]
        self.postinit(**kwargs)

class riskeycap_tilde(riskeycap_numrow):
    """
    Tilde needs some changes because by default it's too small
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[0] = 6.5 # ` symbol
        self.font_sizes[2] = 5.5 # ~ symbol
        self.trans[0] = [-0.3,-2.7,0] # `
        self.trans[2] = [5.5,-1,1]    # ~

class riskeycap_2(riskeycap_numrow):
    """
    2 needs some changes based on the @ symbol
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.fonts[2] = "Aharoni"
        self.font_sizes[2] = 6.1 # @ symbol (Aharoni)
        self.trans[2] = [4.85,0,1]
        self.scale[2] = [0.75,1,3] # Squash it a bit

class riskeycap_3(riskeycap_numrow):
    """
    3 needs some changes based on the # symbol (slightly too big)
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[2] = 4.5 # # symbol (Gotham Rounded)
        self.trans[0] = [-0.35,0,0] # Just a smidge different so it prints better
        self.trans[2] = [5.3,0,1] # Move to the right a bit

class riskeycap_5(riskeycap_numrow):
    """
    5 needs some changes based on the % symbol (too big, too close to bar)
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[2] = 4 # % symbol
        self.trans[2] = [5.2,0,1]

class riskeycap_6(riskeycap_numrow):
    """
    6 needs some changes based on the ^ symbol (too small, should be up high)
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[2] = 5.8 # ^ symbol
        self.trans[2] = [5.3,1.5,1]

class riskeycap_7(riskeycap_numrow):
    """
    7 needs some changes based on the & symbol (it's too big)
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[2] = 4.5 # & symbol
        self.trans[2] = [5.2,0,1]

class riskeycap_8(riskeycap_numrow):
    """
    8 needs some changes based on the tiny * symbol
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[2] = 8.5 # * symbol (Gotham Rounded)
        self.trans[2] = [5.2,0,1] # * needs a smidge of repositioning

class riskeycap_equal(riskeycap_numrow):
    """
    = needs some changes because it and the + are a bit off center
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[0] = [-0.3,-0.5,0] # = sign adjustments
        self.trans[2] = [5,-0.3,1] # + sign adjustments

class riskeycap_dash(riskeycap_numrow):
    """
    The dash (-) is fine but the underscore (_) needs minor repositioning.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[2] = [5.2,-1,1] # _ needs to go down and to the right a bit
        self.scale[2] = [0.8,1,3] # Also needs to be squished a bit

class riskeycap_double_legends(riskeycap_base):
    """
    For regular keys that have two legends... ,./;'[]
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.fonts = [
            "Gotham Rounded:style=Bold", # Main legend
            "Gotham Rounded:style=Bold", # Pipe character
            "Gotham Rounded:style=Bold", # Second legend
        ]
        self.font_sizes = [
            4.5, # Regular Gotham Rounded character
            4.5, # Pipe
            4.5, # Regular Gotham Rounded character
        ]
        self.trans = [
            [-0.3,0,0], # Left Gotham Rounded
            [2.6,0,0], # Center Gotham Rounded |
            [5,0,1], # Right-side Gotham symbols
        ]
        self.rotation = [
            [0,-20,0],
            [0,-20,0],
            [0,-20,0],
        ]
        self.scale = [
            [1,1,3],
            [1,1.75,3], # For the pipe to make it taller/more of a divider
            [1,1,3],
        ]
        self.postinit(**kwargs)

class riskeycap_gt_lt(riskeycap_double_legends):
    """
    The greater than (>) and less than (<) signs need to be adjusted down a bit
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[0] = [-0.3,-0.1,0] # , and . are the tiniest bit too high
        self.trans[2] = [5.2,-0.35,1] # < and > are too high for some reason

class riskeycap_brackets(riskeycap_double_legends):
    """
    The curly braces `{}` needs to be moved to the right a smidge
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[2] = [5.2,0,1] # Just a smidge to the right

class riskeycap_semicolon(riskeycap_double_legends):
    """
    The semicolon ends up being slightly higher than the colon but it looks
    better if the top dot in both is aligned.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[0] = [0.2,-0.4,0]
        self.trans[2] = [4.7,0,1]

class riskeycap_1_U_text(riskeycap_alphas):
    """
    Ctrl, Del, and Ins need to be downsized and moved a smidge.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.font_sizes[0] = 4
        self.trans[0] = [2.5,0,0]
        self.postinit(**kwargs_copy)

class riskeycap_1_U_2_row_text(riskeycap_alphas):
    """
    Scroll Lock, Page Up, Page Down, etc need a bunch of changes.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.font_sizes[0] = 2.5
        self.font_sizes[1] = 2.5
        self.trans[0] = [2.6,2,0]
        self.trans[1] = [2.6,-2,0]
        self.scale = [
            [1,1,3],
            [1,1,3], # Back to normal
            [1,1,3],
        ]
        self.postinit(**kwargs_copy)

class riskeycap_arrows(riskeycap_alphas):
    """
    Arrow symbols (◀▶▲▼) needs a different font (Hack)
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.fonts[0] = "Hack"
        self.fonts[2] = "FontAwesome" # For next/prev track icons
        self.font_sizes[2] = 4 # FontAwesome prev/next icons
        self.trans[2] = [0,-2,2] # Ditto

class riskeycap_fontawesome(riskeycap_alphas):
    """
    For regular centered FontAwesome icon keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs) # Because self.trans[0] updates in place
        self.fonts[0] = "Font Awesome 6 Free:style=Solid"
        self.font_sizes[0] = 5
        self.trans[0] = [2.6,0.3,0]
        self.postinit(**kwargs_copy)

class riskeycap_material_icons(riskeycap_alphas):
    """
    For regular centered Material Design icon keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs) # Because self.trans[0] updates in place
        self.fonts[0] = "Material Design Icons:style=Regular"
        self.font_sizes[0] = 6
        self.trans[0] = [2.6,0.3,0]
        self.postinit(**kwargs_copy)

class riskeycap_1_25U(riskeycap_alphas):
    """
    The base for all 1.25U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs) # Because self.trans[0] updates in place
        self.key_length = KEY_UNIT*1.25-BETWEENSPACE
        self.key_rotation = [0,110.1,-90]
        self.trans[0] = [3,0.2,0]
        self.postinit(**kwargs_copy)
        if not self.name.startswith('1.25U_'):
            self.name = f"1.25U_{self.name}"

class riskeycap_1_5U(riskeycap_double_legends):
    """
    The base for all 1.5U keycaps.

    .. note:: Uses riskeycap_double_legends because of the \\| key.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs) # Because self.trans[0] updates in place
        self.key_length = KEY_UNIT*1.5-BETWEENSPACE
        self.key_rotation = [0,109.335,-90]
        self.trans[0] = [3,0.2,0]
        self.postinit(**kwargs_copy)
        if not self.name.startswith('1.5U_'):
            self.name = f"1.5U_{self.name}"


class riskeycap_bslash_1U(riskeycap_double_legends):
    """
    Backslash key needs a very minor adjustment to the backslash.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[0] = [-0.9,0,0] # Move \ to the left a bit more than normal

class riskeycap_bslash(riskeycap_1_5U):
    """
    Backslash key needs a very minor adjustment to the backslash.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[0] = [-0.9,0,0] # Move \ to the left a bit more than normal

class riskeycap_tab(riskeycap_1_5U):
    """
    "Tab" needs to be centered.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[0] = 4.5 # Regular Gotham Rounded
        self.trans[0] = [2.6,0,0] # Centered when angled -20°

class riskeycap_1_75U(riskeycap_alphas):
    """
    The base for all 1.75U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs) # Because self.trans[0] updates in place
        self.key_length = KEY_UNIT*1.75-BETWEENSPACE
        self.key_rotation = [0,109.335,-90]
        self.postinit(**kwargs_copy)
        if not self.name.startswith('1.75U_'):
            self.name = f"1.75U_{self.name}"

class riskeycap_2U(riskeycap_alphas):
    """
    The base for all 2U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs) # Because self.trans[0] updates in place
        self.key_length = KEY_UNIT*2-BETWEENSPACE
        self.key_rotation = [0,109.335,-90] # Same as 1.75U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,113.65,-90] # Spacebars are different
        self.stem_locations = [[0,0,0], [12,0,0], [-12,0,0]]
        self.postinit(**kwargs_copy)
        if not self.name.startswith('2U_'):
            self.name = f"2U_{self.name}"

class riskeycap_2UV(riskeycap_alphas):
    """
    The base for all 2U (vertical; for numpad) keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs) # Because self.trans[0] updates in place
        self.key_length = KEY_UNIT*1-BETWEENSPACE
        self.key_width = KEY_UNIT*2-BETWEENSPACE
        self.key_rotation = [0,109.335,-90] # Same as 1.75U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,113.65,-90] # Spacebars are different
        self.stem_locations = [[0,0,0], [0,12,0], [0,-12,0]]
        self.trans = [
            [0.1,-0.1,0], # Left Gotham Rounded
            [0,0,0], # Unused (so far)
            [0,0,0], # Ditto
        ]
        self.rotation = [
            [0,0,0],
            [0,0,0],
            [0,0,0],
        ]
        self.postinit(**kwargs_copy)
        if not self.name.startswith('2UV_'):
            self.name = f"2UV_{self.name}"

class riskeycap_2_25U(riskeycap_alphas):
    """
    The base for all 2.25U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.key_length = KEY_UNIT*2.25-BETWEENSPACE
        self.key_rotation = [0,109.335,-90] # Same as 1.75U and 2U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,113.65,-90] # Spacebars are different
        self.stem_locations = [[0,0,0], [12,0,0], [-12,0,0]]
        self.trans[0] = [3.1,0.2,0]
        self.font_sizes[0] = 4
        self.postinit(**kwargs_copy)
        if not self.name.startswith('2.25U_'):
            self.name = f"2.25U_{self.name}"

class riskeycap_2_5U(riskeycap_alphas):
    """
    The base for all 2.5U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.key_length = KEY_UNIT*2.5-BETWEENSPACE
        self.key_rotation = [0,109.335,-90] # Same as 1.75U and 2U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,113.65,-90] # Spacebars are different
        self.stem_locations = [[0,0,0], [12,0,0], [-12,0,0]]
        self.trans[0] = [3.1,0.2,0]
        self.font_sizes[0] = 4
        self.postinit(**kwargs_copy)
        if not self.name.startswith('2.5U_'):
            self.name = f"2.5U_{self.name}"

class riskeycap_2_75U(riskeycap_alphas):
    """
    The base for all 2.75U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.key_length = KEY_UNIT*2.75-BETWEENSPACE
        self.key_rotation = [0,109.335,-90] # Same as 1.75U and 2U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,113.65,-90] # Spacebars are different
        self.stem_locations = [[0,0,0], [12,0,0], [-12,0,0]]
        self.trans[0] = [3.1,0.2,0]
        self.font_sizes[0] = 4
        self.postinit(**kwargs_copy)
        if not self.name.startswith('2.75U_'):
            self.name = f"2.75U_{self.name}"

class riskeycap_6_25U(riskeycap_alphas):
    """
    The base for all 6.25U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.key_length = KEY_UNIT*6.25-BETWEENSPACE
        self.key_rotation = [0,109.335,-90] # Same as 1.75U and 2U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,113.65,-90] # Spacebars are different
        self.stem_locations = [[0,0,0], [50,0,0], [-50,0,0]]
        self.trans[0] = [3.1,0.2,0]
        self.font_sizes[0] = 4
        self.postinit(**kwargs_copy)
        if not self.name.startswith('6.25U_'):
            self.name = f"6.25U_{self.name}"

class riskeycap_7U(riskeycap_alphas):
    """
    The base for all 7U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.key_length = KEY_UNIT*7-BETWEENSPACE
        self.key_rotation = [0,109.335,-90] # Same as 1.75U and 2U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,113.65,-90] # Spacebars are different
        self.stem_locations = [[0,0,0], [57,0,0], [-57,0,0]]
        self.trans[0] = [3.1,0.2,0]
        self.font_sizes[0] = 4
        self.postinit(**kwargs_copy)
        if not self.name.startswith('7U_'):
            self.name = f"7U_{self.name}"

KEYCAPS = [
    # Basic 1U keys
    riskeycap_base(name="1U_blank"),
    riskeycap_tilde(name="tilde", legends=["`", "", "~"]),
    riskeycap_numrow(legends=["1", "", "!"]),
    riskeycap_2(legends=["2", "", "@"]),
    riskeycap_3(legends=["3", "", "#"]),
    riskeycap_numrow(legends=["4", "", "$"]),
    riskeycap_5(legends=["5", "", "%"]),
    riskeycap_6(legends=["6", "", "^"]),
    riskeycap_7(legends=["7", "", "&"]),
    riskeycap_8(legends=["8", "", "*"]),
    riskeycap_numrow(legends=["9", "", "("]),
    riskeycap_numrow(legends=["0", "", ")"]),
    riskeycap_dash(name="dash", legends=["-", "", "_"]),
    riskeycap_equal(name="equal", legends=["=", "", "+"]),
    # Alphas
    riskeycap_alphas(legends=["A"]),
    riskeycap_alphas(legends=["B"]),
    riskeycap_alphas(legends=["C"]),
    riskeycap_alphas(legends=["D"]),
    riskeycap_alphas(legends=["E"]),
    riskeycap_alphas(legends=["F"]),
    riskeycap_alphas_homing_dot(name="F_dot", legends=["F"]),
    riskeycap_alphas(legends=["G"]),
    riskeycap_alphas(legends=["H"]),
    riskeycap_alphas(legends=["I"]),
    riskeycap_alphas(legends=["J"]),
    riskeycap_alphas_homing_dot(name="J_dot", legends=["J"]),
    riskeycap_alphas(legends=["K"]),
    riskeycap_alphas(legends=["L"]),
    riskeycap_alphas(legends=["M"]),
    riskeycap_alphas(legends=["N"]),
    riskeycap_alphas(legends=["O"]),
    riskeycap_alphas(legends=["P"]),
    riskeycap_alphas(legends=["Q"]),
    riskeycap_alphas(legends=["R"]),
    riskeycap_alphas(legends=["S"]),
    riskeycap_alphas(legends=["T"]),
    riskeycap_alphas(legends=["U"]),
    riskeycap_alphas(legends=["V"]),
    riskeycap_alphas(legends=["W"]),
    riskeycap_alphas(legends=["X"]),
    riskeycap_alphas(legends=["Y"]),
    riskeycap_alphas(legends=["Z"]),
    riskeycap_alphas(legends=["Z"]),
    # Function keys
    riskeycap_alphas(legends=["F1"]),
    riskeycap_alphas(legends=["F2"]),
    riskeycap_alphas(legends=["F3"]),
    riskeycap_alphas(legends=["F4"]),
    riskeycap_alphas(legends=["F5"]),
    riskeycap_alphas(legends=["F6"]),
    riskeycap_alphas(legends=["F7"]),
    riskeycap_alphas(legends=["F8"]),
    riskeycap_alphas(legends=["F9"]),
    # F10 needs to be shifted to the left a bit so that when printing on its
    # side the 0 doesn't end up in the wall:
    riskeycap_alphas(legends=["F10"], font_sizes=[4.25], trans=[[2.4,0,0]]),
    riskeycap_alphas(legends=["F11"], font_sizes=[4.25]),
    riskeycap_alphas(legends=["F12"], font_sizes=[4.25]),
    # Bottom row(s) and sides 1U
    riskeycap_alphas(name="menu", legends=["☰"], fonts=["Code2000"]),
    riskeycap_alphas(name="option1U", legends=["⌥"],
        fonts=["JetBrainsMono Nerd Font"], font_sizes=[6]),
    riskeycap_arrows(name="left", legends=["◀", "", ""]),
    riskeycap_arrows(name="right", legends=["▶", "", ""]),
    riskeycap_arrows(name="left_rw", legends=["◀", "", ""]),
    riskeycap_arrows(name="right_ffw", legends=["▶", "", ""]),
    riskeycap_arrows(name="up", legends=["▲", "", ""]),
    riskeycap_arrows(name="down", legends=["▼", "", "", ""]),
    riskeycap_fontawesome(name="eject", legends=[""]), # Mostly for Macs
    riskeycap_fontawesome(name="bug", legends=[""]), # Just for fun
    riskeycap_fontawesome(name="camera", legends=[""]), # aka Screenshot aka Print Screen
    riskeycap_fontawesome(name="paws", legends=[""]), # Alternate "Paws" key (hehe)
    riskeycap_fontawesome(name="home_icon", legends=[""]), # Alternate "Home" key
    riskeycap_fontawesome(name="broom", legends=[""]),
    riskeycap_fontawesome(name="dragon", legends=[""]),
    riskeycap_fontawesome(name="baby", legends=[""]),
    riskeycap_fontawesome(name="dungeon", legends=[""]),
    riskeycap_fontawesome(name="wizard", legends=[""]),
    riskeycap_fontawesome(name="headset", legends=[""]),
    riskeycap_fontawesome(name="skull_n_bones", legends=[""]),
    riskeycap_fontawesome(name="bath", legends=[""]),
    riskeycap_fontawesome(name="keyboard", legends=[""]),
    riskeycap_fontawesome(name="terminal", legends=[""]),
    riskeycap_fontawesome(name="spy", legends=[""]),
    riskeycap_fontawesome(name="biohazard", legends=[""]),
    riskeycap_fontawesome(name="bandage", legends=[""]),
    riskeycap_fontawesome(name="bone", legends=[""]),
    riskeycap_fontawesome(name="cannabis", legends=[""]),
    riskeycap_fontawesome(name="radiation", legends=[""], font_sizes=[6]),
    riskeycap_fontawesome(name="crutch", legends=[""]),
    riskeycap_fontawesome(name="head_site_cough", legends=[""]),
    riskeycap_fontawesome(name="mortar_and_pestle", legends=[""]),
    riskeycap_fontawesome(name="poop", legends=[""]),
    riskeycap_fontawesome(name="bomb", legends=[""]),
    riskeycap_fontawesome(name="thunderstorm", legends=[""]),
    riskeycap_fontawesome(name="dumpster_fire", legends=[""]),
    riskeycap_fontawesome(name="flask", legends=[""]),
    riskeycap_fontawesome(name="middle_finger", legends=[""]),
    riskeycap_fontawesome(name="hurricane", legends=[""]),
    riskeycap_fontawesome(name="light_bulb", legends=[""]),
    riskeycap_fontawesome(name="male", legends=[""]),
    riskeycap_fontawesome(name="female", legends=[""]),
    riskeycap_fontawesome(name="microphone", legends=[""]),
    riskeycap_fontawesome(name="person_falling", legends=[""]),
    riskeycap_fontawesome(name="shitstorm", legends=[""]),
    riskeycap_fontawesome(name="toilet", legends=[""]),
    riskeycap_fontawesome(name="wifi", legends=[""]),
    riskeycap_fontawesome(name="yinyang", legends=[""]),
    riskeycap_fontawesome(name="ban", legends=[""]),
    riskeycap_fontawesome(name="lemon", legends=[""], font_sizes=[6]),
    riskeycap_material_icons(name="duck", legends=[""], font_sizes=[7]),
    riskeycap_alphas(name="die_1", legends=["⚀"], font_sizes=[7], fonts=["DejaVu Sans:style=Bold"]), # Dice (number alternate)
    riskeycap_alphas(name="die_2", legends=["⚁"], font_sizes=[7], fonts=["DejaVu Sans:style=Bold"]), # Dice (number alternate)
    riskeycap_alphas(name="die_3", legends=["⚂"], font_sizes=[7], fonts=["DejaVu Sans:style=Bold"]), # Dice (number alternate)
    riskeycap_alphas(name="die_4", legends=["⚃"], font_sizes=[7], fonts=["DejaVu Sans:style=Bold"]), # Dice (number alternate)
    riskeycap_alphas(name="die_5", legends=["⚄"], font_sizes=[7], fonts=["DejaVu Sans:style=Bold"]), # Dice (number alternate)
    riskeycap_alphas(name="die_6", legends=["⚅"], font_sizes=[7], fonts=["DejaVu Sans:style=Bold"]), # Dice (number alternate)
    riskeycap_1_U_text(name="RCtrl", legends=["Ctrl"]),
    riskeycap_1_U_text(legends=["Del"]),
    riskeycap_1_U_text(legends=["Ins"]),
    riskeycap_1_U_text(legends=["Esc"]),
    riskeycap_1_U_text(legends=["End"]),
    riskeycap_1_U_text(legends=["BRB"], scale=[[0.75,1,3]]),
    riskeycap_1_U_text(legends=["OMG"], font_sizes=[3.75], scale=[[0.75,1,3]]),
    riskeycap_1_U_text(legends=["WTF"], font_sizes=[3.75], scale=[[0.75,1,3]]),
    riskeycap_1_U_text(legends=["BBL"], scale=[[0.75,1,3]]),
    riskeycap_1_U_text(legends=["CYA"], scale=[[0.75,1,3]]),
    riskeycap_1_U_text(legends=["IDK"], scale=[[0.75,1,3]]),
    riskeycap_1_U_text(legends=["ASS"], scale=[[0.75,1,3]]),
    riskeycap_1_U_text(legends=["ANY", "", "KEY"], scale=[[0.75,1,3]], fonts = [
            "Gotham Rounded:style=Bold",
            "Gotham Rounded:style=Bold",
            "Gotham Rounded:style=Bold",
    ], font_sizes=[4, 4, 4.15]), # 4.15 here works around a minor slicing issue
    riskeycap_1_U_text(legends=["OK"]),
    riskeycap_1_U_text(legends=["NO"]),
    riskeycap_1_U_text(legends=["Yes"]),
    riskeycap_1_U_text(legends=["DO"]),
    riskeycap_1_U_2_row_text(name="DO_NOT", legends=["DO", "NOT"],
        trans=[[2.7,2.75,0],[2.7,-2,0]], font_sizes=[3.5, 3.5]),
    riskeycap_1_U_text(legends=["FUBAR"], font_sizes=[3.25], scale=[[0.55,1,3]]),
    riskeycap_1_U_text(legends=["Home"], font_sizes=[2.75]),
    riskeycap_1_U_2_row_text(name="PageUp",
        legends=["Page", "Up"], font_sizes=[2.75, 2.75]),
    riskeycap_1_U_2_row_text(name="PageDown",
        legends=["Page", "Down"], font_sizes=[2.75, 2.75]),
    riskeycap_1_U_text(legends=["Pause"], font_sizes=[2.5]),
    riskeycap_1_U_2_row_text(name="ScrollLock", legends=["Scroll", "Lock"]),
    riskeycap_1_U_text(legends=["Sup"]),
    riskeycap_brackets(name="lbracket", legends=["[", "", "{"]),
    riskeycap_brackets(name="rbracket", legends=["]", "", "}"]),
    riskeycap_semicolon(name="semicolon", legends=[";", "", ":"]),
    riskeycap_double_legends(name="quote", legends=["'", "", '\\u0022']),
    riskeycap_gt_lt(name="comma", legends=[",", "", "<"]),
    riskeycap_gt_lt(name="dot", legends=[".", "", ">"]),
    riskeycap_double_legends(name="slash", legends=["/", "", "?"]),
    # 60% and smaller numrow (with function key legends on the front)
    riskeycap_numrow(name="1_F1", legends=["1", "", "!", "F1"]),
    riskeycap_2(name="2_F2", legends=["2", "", "@", "F2"]),
    riskeycap_3(name="3_F3", legends=["3", "", "#", "F3"]),
    riskeycap_numrow(name="4_F4", legends=["4", "", "$", "F4"]),
    riskeycap_5(name="5_F5", legends=["5", "", "%", "F5"]),
    riskeycap_6(name="6_F6", legends=["6", "", "^", "F6"]),
    riskeycap_7(name="7_F7", legends=["7", "", "&", "F7"]),
    riskeycap_8(name="8_F8", legends=["8", "", "*", "F8"]),
    riskeycap_numrow(name="9_F9", legends=["9", "", "(", "F9"]),
    riskeycap_numrow(name="0_F10", legends=["0", "", ")", "F10"]),
    riskeycap_dash(name="dash_F11", legends=["-", "", "_", "F11"]),
    riskeycap_equal(name="equal_F12", legends=["=", "", "+", "F12"]),
    # 1.25U keys
    riskeycap_1_25U(name="blank"),
    riskeycap_1_25U(name="LCtrl", legends=["Ctrl"], font_sizes=[4]),
    riskeycap_1_25U(name="LAlt", legends=["Alt"], font_sizes=[4]),
    riskeycap_1_25U(name="RAlt", legends=["Alt Gr"], font_sizes=[3.25]),
    riskeycap_1_25U(name="Command", legends=["Cmd"], font_sizes=[4]),
    riskeycap_1_25U(name="CommandSymbol", legends=["⌘"], font_sizes=[7], fonts=["Agave"]),
    riskeycap_1_25U(name="OptionSymbol", legends=["⌥"], font_sizes=[6], fonts=["JetBrainsMono Nerd Font"]),
    riskeycap_1_25U(name="Option", legends=["Option"], font_sizes=[2.9]),
    riskeycap_1_25U(name="Fun", legends=["Fun"], font_sizes=[4]),
    riskeycap_1_25U(name="MoreFun",
        legends=["More", "Fun"],
        trans=[[3,2.5,0], [3,-2.5,0]],
        font_sizes=[4, 4],
        scale=[[1,1,3], [1,1,3]]),
    riskeycap_1_25U(legends=["Super", "Duper"],
        trans=[[3,2.25,0], [3,-2.25,0]], font_sizes=[3.25, 3.25],
        scale=[[1,1,3], [1,1,3]]),
    # 1.5U keys
    riskeycap_1_5U(name="blank"),
    riskeycap_bslash_1U(name="bslash", legends=["\\u005c", "", "|"]),
    riskeycap_bslash(name="bslash", legends=["\\u005c", "", "|"]),
    riskeycap_tab(name="Tab", legends=["Tab"]),
    riskeycap_1_5U(name="Ctrl", legends=["Ctrl"], font_sizes=[4]),
    riskeycap_1_5U(name="LAlt", legends=["Alt"], font_sizes=[4]),
    riskeycap_1_5U(name="RAlt", legends=["Alt Gr"], font_sizes=[4]),
    # 1.75U keys
    riskeycap_1_75U(name="blank"),
    riskeycap_1_75U(legends=["Compose"],
        trans=[[3.1,0.2,0]], font_sizes=[3.25]),
    riskeycap_1_75U(name="Caps",
        legends=["Caps Lock"], trans=[[3.1,0,0]], font_sizes=[3]),
    #riskeycap_1_75U(name="Laps",
        #legends=["Laps Cock"], trans=[[3.1,0,0]], font_sizes=[3]),
    riskeycap_1_75U(name="Laps",
        legends=["Laps", "Cock"], trans=[[3,2.5,0], [3,-2.5,0]],
        font_sizes=[4, 4], scale=[[1,1,3], [1,1,3]]),
    riskeycap_1_75U(name="RubOut",
        legends=["Rub Out"], trans=[[3.1,0,0]], font_sizes=[3]),
    riskeycap_1_75U(name="Rub1Out",
        legends=["Rub 1 Out"], trans=[[3.1,0,0]], font_sizes=[3]),
    riskeycap_1_75U(legends=["Chyros"],
        trans=[[3.1,0,0]], font_sizes=[4.35]),
    # 2U keys
    riskeycap_2U(name="blank"),
    riskeycap_2U(name="TOTALBS",
        legends=["TOTAL BS"], font_sizes=[3.75, 3.75]),
    riskeycap_2U(name="Backspace", font_sizes=[3.75, 3.75]),
    riskeycap_2U(name="Rub Out",
        legends=["Rub Out"], font_sizes=[4, 4]),
    riskeycap_2U(name="Rub 1 Out",
        legends=["Rub 1 Out"], font_sizes=[3.75, 3.75]),
    riskeycap_2U(name="2U_space",
        # Spacebars don't need to be as thick
        stem_sides_wall_thickness=0.0, dish_invert=True),
    # 2.25U keys
    riskeycap_2_25U(name="blank"),
    riskeycap_2_25U(name="Shift", legends=["Shift"]),
    riskeycap_2_25U(name="ShiftyShift",
        legends=["Shift"], trans=[[9.5,-2.8,0]]),
    riskeycap_2_25U(name="ShiftyShiftL",
        legends=["Shift"], trans=[[-4,-2.8,0]]),
    riskeycap_2_25U(name="TrueShift", legends=["True Shift"]),
    riskeycap_2_25U(legends=["Return"]),
    riskeycap_2_25U(legends=["Enter"]),
    # 2.5U keys
    riskeycap_2_5U(name="blank"),
    riskeycap_2_5U(name="Shift", legends=["Shift"]),
    riskeycap_2_5U(name="ShiftyShift",
        legends=["Shift"], trans=[[12,-2.8,0]]),
    riskeycap_2_5U(name="ShiftyShiftL",
        legends=["Shift"], trans=[[-6.5,-2.8,0]]),
    riskeycap_2_5U(name="TrueShift", legends=["True Shift"]),
    ## 2.75U keys
    riskeycap_2_75U(name="blank"),
    riskeycap_2_75U(name="Shift", legends=["Shift"]),
    riskeycap_2_75U(name="ShiftyShift",
        legends=["Shift"], trans=[[14,-2.8,0]]),
    riskeycap_2_75U(name="ShiftyShiftL",
        legends=["Shift"], trans=[[-8.5,-2.8,0]]),
    riskeycap_2_75U(name="TrueShift", legends=["True Shift"]),
    # Various spacebars
    riskeycap_6_25U(name="space",
        # Spacebars don't need to be as thick
        stem_sides_wall_thickness=0.0, dish_invert=True),
    riskeycap_7U(name="space",
        # Spacebars don't need to be as thick
        stem_sides_wall_thickness=0.0, dish_invert=True),
    # Numpad keycaps
    riskeycap_alphas(name="numpad1", legends=["1"]),
    riskeycap_alphas(name="numpad2", legends=["2"]),
    riskeycap_alphas(name="numpad3", legends=["3"]),
    riskeycap_alphas(name="numpad4", legends=["4"]),
    riskeycap_alphas(name="numpad5", legends=["5"]),
    riskeycap_alphas(name="numpad6", legends=["6"]),
    riskeycap_alphas(name="numpad7", legends=["7"]),
    riskeycap_alphas(name="numpad8", legends=["8"]),
    riskeycap_alphas(name="numpad9", legends=["9"]),
    riskeycap_alphas(name="numpad0", legends=["0"]),
    riskeycap_alphas(name="numpadplus", legends=["+"], font_sizes=[6]),
    riskeycap_2UV(name="2UV_numpadplus", legends=["+"], font_sizes=[6],
        trans=[[0.5,-0.1,0]]),
    riskeycap_2UV(name="2UV_numpadenter", legends=["↵"],
        fonts=["OverpassMono Nerd Font:style=Bold"], font_sizes=[6]),
    riskeycap_2U(name="2U_numpad0", legends=["0"],
        font_sizes=[4.5]),
    riskeycap_alphas(name="numpaddot", legends=["."], font_sizes=[6]),
    riskeycap_alphas(name="numlock", legends=["Num"], font_sizes=[3.25],),
    riskeycap_alphas(name="numpadslash", legends=["/"]),
    riskeycap_alphas(name="numpadstar", legends=["*"], font_sizes=[8.5]),
    # Default width of - is a bit too skinny so we scale/adjust it a bit:
    riskeycap_alphas(name="numpadminus", legends=["-"],
        font_sizes=[6], scale=[[1.4,1,3]], trans = [[2.9,0,0]]),
    riskeycap_2UV(name="2UV_numpadenter", legends=["↵",], font_sizes=[7],
        fonts=["Noto"]),
]

def print_keycaps():
    """
    Prints the names of all keycaps in KEYCAPS.
    """
    print(Style.BRIGHT +
          f"Here's all the keycaps we can render:\n" + Style.RESET_ALL)
    keycap_names = ", ".join(a.name for a in KEYCAPS)
    print(f"{keycap_names}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Render a full set of riskeycap keycaps.")
    parser.add_argument('--out',
        metavar='<filepath>', type=str, default=".",
        help='Where the generated files will go.')
    parser.add_argument('--force',
        required=False, action='store_true',
        help='Forcibly re-render keycaps even if they already exist.')
    parser.add_argument('--legends',
        required=False, action='store_true',
        help=f'If True, generate a separate set of {FILE_TYPE} files for legends.')
    parser.add_argument('--keycaps',
        required=False, action='store_true',
        help='If True, prints out the names of all keycaps we can render.')
    parser.add_argument('names',
        nargs='*', metavar="name",
        help='Optional name of specific keycap you wish to render')
    args = parser.parse_args()
    #print(args)
    if len(sys.argv) == 1:
        parser.print_help()
        print("")
        print_keycaps()
        sys.exit(1)
    if args.keycaps:
        print_keycaps()
        sys.exit(1)
    if not os.path.exists(args.out):
        print(Style.BRIGHT +
              f"Output path, '{args.out}' does not exist; making it..."
              + Style.RESET_ALL)
        os.mkdir(args.out)
    print(Style.BRIGHT + f"Outputting to: {args.out}" + Style.RESET_ALL)
    if args.names: # Just render the specified keycaps
        matched = False
        for name in args.names:
            for keycap in KEYCAPS:
                if keycap.name.lower() == name.lower():
                    keycap.output_path = f"{args.out}"
                    matched = True
                    exists = False
                    if not args.force:
                        if os.path.exists(f"{args.out}/{keycap.name}.{keycap.file_type}"):
                            print(Style.BRIGHT +
                                f"{args.out}/{keycap.name}.{keycap.file_type} exists; "
                                f"skipping..."
                                + Style.RESET_ALL)
                            exists = True
                    if not exists:
                        print(Style.BRIGHT +
                            f"Rendering {args.out}/{keycap.name}.{keycap.file_type}..."
                            + Style.RESET_ALL)
                        print(keycap)
                        retcode, output = getstatusoutput(str(keycap))
                        if retcode == 0: # Success!
                            print(
                                f"{args.out}/{keycap.name}.{keycap.file_type} "
                                f"rendered successfully")
                    if args.legends:
                        keycap.name = f"{keycap.name}_legends"
                        # Change it to .stl since PrusaSlicer doesn't like .3mf
                        # for "parts" for unknown reasons...
                        keycap.file_type = "stl"
                        if os.path.exists(f"{args.out}/{keycap.name}.{keycap.file_type}"):
                            print(Style.BRIGHT +
                                f"{args.out}/{keycap.name}.{keycap.file_type} exists; "
                                f"skipping..."
                                + Style.RESET_ALL)
                            continue
                        print(Style.BRIGHT +
                            f"Rendering {args.out}/{keycap.name}.{keycap.file_type}..."
                            + Style.RESET_ALL)
                        print(keycap)
                        retcode, output = getstatusoutput(str(keycap))
                        if retcode == 0: # Success!
                            print(
                                f"{args.out}/{keycap.name}.{keycap.file_type} "
                                f"rendered successfully")
        if not matched:
            print(f"Cound not find a keycap named {name}")
    else:
        # First render the keycaps
        for keycap in KEYCAPS:
            keycap.output_path = f"{args.out}"
            if not args.force:
                if os.path.exists(f"{args.out}/{keycap.name}.{keycap.file_type}"):
                    print(Style.BRIGHT +
                        f"{args.out}/{keycap.name}.{keycap.file_type} exists; skipping..."
                        + Style.RESET_ALL)
                    continue
            print(Style.BRIGHT +
                f"Rendering {args.out}/{keycap.name}.{keycap.file_type}..."
                + Style.RESET_ALL)
            print(keycap)
            retcode, output = getstatusoutput(str(keycap))
            if retcode == 0: # Success!
                print(f"{args.out}/{keycap.name}.{keycap.file_type} rendered successfully")
        # Next render the legends (for multi-material, non-transparent legends)
        if args.legends:
            for legend in KEYCAPS:
                if legend.legends == [""]:
                    continue # No actual legends
                legend.name = f"{legend.name}_legends"
                legend.output_path = f"{args.out}"
                legend.render = ["legends"]
                # Change it to .stl since PrusaSlicer doesn't like .3mf
                # for "parts" for unknown reasons...
                legend.file_type = "stl"
                if not args.force:
                    if os.path.exists(f"{args.out}/{legend.name}.{legend.file_type}"):
                        print(Style.BRIGHT +
                            f"{args.out}/{legend.name}.{legend.file_type} exists; skipping..."
                            + Style.RESET_ALL)
                        continue
                print(Style.BRIGHT +
                    f"Rendering {args.out}/{legend.name}.{legend.file_type}..."
                    + Style.RESET_ALL)
                print(legend)
                retcode, output = getstatusoutput(str(legend))
                if retcode == 0: # Success!
                    print(f"{args.out}/{legend.name}.{legend.file_type} rendered successfully")
