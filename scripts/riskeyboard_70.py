#!/usr/bin/env python3

"""
Generates a whole Riskeyboard 70's worth of keycaps (and a few extras). Best way
to use this script is from within the `keycap_playground` directory.

.. bash::

    $ ./scripts/riskeyboard_70.py --out /tmp/output_dir
"""

# stdlib imports
import os, sys
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

KEY_UNIT = 19.05 # Square that makes up the entire space of a key
BETWEENSPACE = 0.8 # Space between keycaps

class riskeyboard70_base(Keycap):
    """
    Base keycap definitions for Gotham Rounded
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.key_profile = "gem"
        self.key_rotation = [0,108.6,90]
        self.wall_thickness = 0.45*2.25
        self.uniform_wall_thickness = True
        self.dish_thickness = 1.0 # Note: Not actually used
        self.stem_type = "box_cherry"
        self.stem_top_thickness = 0.65 # Note: Not actually used
        self.stem_inside_tolerance = 0.15
        # Disabled stem side support because it seems it is unnecessary @0.16mm
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
        self.rotation = [
            [0,-20,0],
            [0,-20,0],
            [68,0,0],
        ]
        self.postinit(**kwargs)

# KEY_ROTATION = [0,107.8,90]; // GEM profile rotation 1.5U

class riskeyboard70_alphas(riskeyboard70_base):
    """
    Tilde needs some changes because by default it's too small
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

class riskeyboard70_numrow(riskeyboard70_base):
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

class riskeyboard70_tilde(riskeyboard70_numrow):
    """
    Tilde needs some changes because by default it's too small
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[0] = 6.5 # ` symbol
        self.font_sizes[2] = 5.5 # ~ symbol
        self.trans[0] = [-0.3,-2.7,0] # `
        self.trans[2] = [5.5,-1,1]    # ~

class riskeyboard70_2(riskeyboard70_numrow):
    """
    2 needs some changes based on the @ symbol
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.fonts[2] = "Aharoni"
        self.font_sizes[2] = 4.5 # @ symbol (Aharoni)
        self.trans[2] = [5.4,0,1]

class riskeyboard70_3(riskeyboard70_numrow):
    """
    3 needs some changes based on the # symbol (slightly too big)
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[2] = 4 # # symbol (Gotham Rounded)
        self.trans[2] = [5.5,0,1] # Move to the right a bit

class riskeyboard70_5(riskeyboard70_numrow):
    """
    5 needs some changes based on the % symbol (too big, too close to bar)
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[2] = 3.75 # % symbol
        self.trans[2] = [5.2,0,1]

class riskeyboard70_7(riskeyboard70_numrow):
    """
    7 needs some changes based on the & symbol (it's too big)
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[2] = 3.85 # & symbol
        self.trans[2] = [5.2,0,1]

class riskeyboard70_8(riskeyboard70_numrow):
    """
    8 needs some changes based on the tiny * symbol
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[2] = 7.5 # * symbol (Gotham Rounded)
        self.trans[2] = [5.2,-1.9,1] # * needs a smidge of repositioning

class riskeyboard70_equal(riskeyboard70_numrow):
    """
    = needs some changes because it and the + are a bit off center
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[0] = [-0.3,-0.5,0] # = sign adjustments
        self.trans[2] = [5,-0.3,1] # + sign adjustments

class riskeyboard70_dash(riskeyboard70_numrow):
    """
    The dash (-) is fine but the underscore (_) needs minor repositioning.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[2] = [5.2,-1,1] # _ needs to go down and to the right a bit
        self.scale[2] = [0.8,1,3] # Also needs to be squished a bit

class riskeyboard70_double_legends(riskeyboard70_base):
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

class riskeyboard70_gt_lt(riskeyboard70_double_legends):
    """
    The greater than (>) and less than (<) signs need to be adjusted down a bit
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[0] = [-0.3,-0.1,0] # , and . are the tiniest bit too high
        self.trans[2] = [5.2,-0.35,1] # < and > are too high for some reason

class riskeyboard70_brackets(riskeyboard70_double_legends):
    """
    The curly braces `{}` needs to be moved to the right a smidge
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[2] = [5.2,0,1] # Just a smidge to the right

class riskeyboard70_semicolon(riskeyboard70_double_legends):
    """
    The semicolon ends up being slightly higher than the colon but it looks
    better if the top dot in both is aligned.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[0] = [0.2,-0.4,0]
        self.trans[2] = [4.7,0,1]

class riskeyboard70_1_U_text(riskeyboard70_alphas):
    """
    Ctrl, Del, and Ins need to be downsized and moved a smidge.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.font_sizes[0] = 4
        self.trans[0] = [2.5,0,0]
        self.postinit(**kwargs_copy)

class riskeyboard70_arrows(riskeyboard70_alphas):
    """
    Arrow symbols (◀▶▲▼) needs a different font (Hack)
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.fonts[0] = "Hack"
        self.fonts[2] = "FontAwesome" # For next/prev track icons
        self.font_sizes[2] = 4 # FontAwesome prev/next icons
        self.trans[2] = [0,-2,2] # Ditto

class riskeyboard70_fontawesome(riskeyboard70_alphas):
    """
    For regular centered FontAwesome icon keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.fonts[0] = "FontAwesome"
        self.font_sizes[0] = 5
        self.trans[0] = [2.6,0.3,0]

class riskeyboard70_1_25U(riskeyboard70_alphas):
    """
    The base for all 1.25U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs) # Because self.trans[0] updates in place
        self.key_length = KEY_UNIT*1.25-BETWEENSPACE
        self.key_rotation = [0,108.55,90]
        self.trans[0] = [3,0.2,0]
        self.postinit(**kwargs_copy)
        if not self.name.startswith('1.25U_'):
            self.name = f"1.25U_{self.name}"

class riskeyboard70_1_5U(riskeyboard70_double_legends):
    """
    The base for all 1.5U keycaps.

    .. note:: Uses riskeyboard70_double_legends because of the \\| key.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.key_length = KEY_UNIT*1.5-BETWEENSPACE
        self.key_rotation = [0,107.825,90]
        self.postinit(**kwargs)
        if not self.name.startswith('1.5U_'):
            self.name = f"1.5U_{self.name}"

class riskeyboard70_bslash(riskeyboard70_1_5U):
    """
    Backslash key needs a very minor adjustment to the backslash.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.trans[0] = [-0.9,0,0] # Move \ to the left a bit more than normal

class riskeyboard70_tab(riskeyboard70_1_5U):
    """
    "Tab" needs to be centered.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_sizes[0] = 4.5 # Regular Gotham Rounded
        self.trans[0] = [2.6,0,0] # Centered when angled -20°

class riskeyboard70_1_75U(riskeyboard70_alphas):
    """
    The base for all 1.75U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.key_length = KEY_UNIT*1.75-BETWEENSPACE
        self.key_rotation = [0,107.85,90]
        self.postinit(**kwargs)
        if not self.name.startswith('1.75U_'):
            self.name = f"1.75U_{self.name}"

class riskeyboard70_2U(riskeyboard70_alphas):
    """
    The base for all 2U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.key_length = KEY_UNIT*2-BETWEENSPACE
        self.key_rotation = [0,107.85,90] # Same as 1.75U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,111.88,90] # Spacebars are different
        self.stem_locations = [[0,0,0], [12,0,0], [-12,0,0]]
        self.postinit(**kwargs)
        if not self.name.startswith('2U_'):
            self.name = f"2U_{self.name}"

class riskeyboard70_2_25U(riskeyboard70_alphas):
    """
    The base for all 2.25U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.key_length = KEY_UNIT*2.25-BETWEENSPACE
        self.key_rotation = [0,107.85,90] # Same as 1.75U and 2U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,111.88,90] # Spacebars are different
        self.stem_locations = [[0,0,0], [12,0,0], [-12,0,0]]
        self.trans[0] = [3.1,0.2,0]
        self.font_sizes[0] = 4
        self.postinit(**kwargs_copy)
        if not self.name.startswith('2.25U_'):
            self.name = f"2.25U_{self.name}"

class riskeyboard70_2_5U(riskeyboard70_alphas):
    """
    The base for all 2.5U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.key_length = KEY_UNIT*2.5-BETWEENSPACE
        self.key_rotation = [0,107.85,90] # Same as 1.75U and 2U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,111.88,90] # Spacebars are different
        self.stem_locations = [[0,0,0], [12,0,0], [-12,0,0]]
        self.trans[0] = [3.1,0.2,0]
        self.font_sizes[0] = 4
        self.postinit(**kwargs_copy)
        if not self.name.startswith('2.5U_'):
            self.name = f"2.5U_{self.name}"

class riskeyboard70_2_75U(riskeyboard70_alphas):
    """
    The base for all 2.75U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.key_length = KEY_UNIT*2.75-BETWEENSPACE
        self.key_rotation = [0,107.85,90] # Same as 1.75U and 2U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,111.88,90] # Spacebars are different
        self.stem_locations = [[0,0,0], [12,0,0], [-12,0,0]]
        self.trans[0] = [3.1,0.2,0]
        self.font_sizes[0] = 4
        self.postinit(**kwargs_copy)
        if not self.name.startswith('2.75U_'):
            self.name = f"2.75U_{self.name}"

class riskeyboard70_6_25U(riskeyboard70_alphas):
    """
    The base for all 6.25U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.key_length = KEY_UNIT*6.25-BETWEENSPACE
        self.key_rotation = [0,107.85,90] # Same as 1.75U and 2U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,111.88,90] # Spacebars are different
        self.stem_locations = [[0,0,0], [50,0,0], [-50,0,0]]
        self.trans[0] = [3.1,0.2,0]
        self.font_sizes[0] = 4
        self.postinit(**kwargs_copy)
        if not self.name.startswith('6.25U_'):
            self.name = f"6.25U_{self.name}"

class riskeyboard70_7U(riskeyboard70_alphas):
    """
    The base for all 7U keycaps.
    """
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        kwargs_copy = deepcopy(kwargs)
        self.key_length = KEY_UNIT*7-BETWEENSPACE
        self.key_rotation = [0,107.85,90] # Same as 1.75U and 2U
        if "dish_invert" in kwargs and kwargs["dish_invert"]:
            self.key_rotation = [0,111.88,90] # Spacebars are different
        self.stem_locations = [[0,0,0], [57,0,0], [-57,0,0]]
        self.trans[0] = [3.1,0.2,0]
        self.font_sizes[0] = 4
        self.postinit(**kwargs_copy)
        if not self.name.startswith('7U_'):
            self.name = f"7U_{self.name}"

KEYCAPS = [
    # 1U keys
    riskeyboard70_base(name="1U_blank"),
    riskeyboard70_tilde(name="tilde", legends=["`", "", "~"]),
    riskeyboard70_numrow(legends=["1", "", "!", "F1"]),
    riskeyboard70_2(legends=["2", "", "@", "F2"]),
    riskeyboard70_3(legends=["3", "", "#", "F3"]),
    riskeyboard70_numrow(legends=["4", "", "$", "F4"]),
    riskeyboard70_5(legends=["5", "", "%", "F5"]),
    riskeyboard70_numrow(legends=["6", "", "^", "F6"]),
    riskeyboard70_7(legends=["7", "", "&", "F7"]),
    riskeyboard70_8(legends=["8", "", "*", "F8"]),
    riskeyboard70_numrow(legends=["9", "", "(", "F9"]),
    riskeyboard70_numrow(legends=["0", "", ")", "F10"]),
    riskeyboard70_dash(name="dash", legends=["-", "", "_", "F11"]),
    riskeyboard70_equal(name="equal", legends=["=", "", "+", "F12"]),
    riskeyboard70_alphas(legends=["A"]),
    riskeyboard70_alphas(legends=["B"]),
    riskeyboard70_alphas(legends=["C"]),
    riskeyboard70_alphas(legends=["D"]),
    riskeyboard70_alphas(legends=["E"]),
    riskeyboard70_alphas(legends=["F"]),
    riskeyboard70_alphas(legends=["G"]),
    riskeyboard70_alphas(legends=["H"]),
    riskeyboard70_alphas(legends=["I"]),
    riskeyboard70_alphas(legends=["J"]),
    riskeyboard70_alphas(legends=["K"]),
    riskeyboard70_alphas(legends=["L"]),
    riskeyboard70_alphas(legends=["M"]),
    riskeyboard70_alphas(legends=["N"]),
    riskeyboard70_alphas(legends=["O"]),
    riskeyboard70_alphas(legends=["P"]),
    riskeyboard70_alphas(legends=["Q"]),
    riskeyboard70_alphas(legends=["R"]),
    riskeyboard70_alphas(legends=["S"]),
    riskeyboard70_alphas(legends=["T"]),
    riskeyboard70_alphas(legends=["U"]),
    riskeyboard70_alphas(legends=["V"]),
    riskeyboard70_alphas(legends=["W"]),
    riskeyboard70_alphas(legends=["X"]),
    riskeyboard70_alphas(legends=["Y"]),
    riskeyboard70_alphas(legends=["Z"]),
    riskeyboard70_alphas(legends=["Z"]),
    riskeyboard70_alphas(name="menu", legends=["☰"], fonts=["Code2000"]),
    riskeyboard70_alphas(name="Option1U", legends=["⌥"], fonts=["Code2000"]),
    riskeyboard70_arrows(name="left", legends=["◀", "", ""]),
    riskeyboard70_arrows(name="right", legends=["▶", "", ""]),
    riskeyboard70_arrows(name="up", legends=["▲", "", ""]),
    riskeyboard70_arrows(name="down", legends=["▼", "", "", ""]),
    riskeyboard70_arrows(name="eject", legends=[""]), # For Macs
    riskeyboard70_fontawesome(name="camera", legends=[""]), # aka screenshot
    riskeyboard70_fontawesome(name="bug", legends=[""]), # Just for fun
    riskeyboard70_1_U_text(name="RCtrl", legends=["Ctrl"]),
    riskeyboard70_1_U_text(legends=["Del"]),
    riskeyboard70_1_U_text(legends=["Ins"]),
    riskeyboard70_1_U_text(legends=["Esc"]),
    riskeyboard70_brackets(name="lbracket", legends=["[", "", "{"]),
    riskeyboard70_brackets(name="rbracket", legends=["]", "", "}"]),
    riskeyboard70_semicolon(name="semicolon", legends=[";", "", ":"]),
    riskeyboard70_double_legends(name="quote", legends=["'", "", '\"']),
    riskeyboard70_gt_lt(name="comma", legends=[",", "", "<"]),
    riskeyboard70_gt_lt(name="dot", legends=[".", "", ">"]),
    riskeyboard70_double_legends(name="slash", legends=["/", "", "?"]),
    # 1.25U keys
    riskeyboard70_1_25U(name="blank"),
    riskeyboard70_1_25U(name="LCtrl", legends=["Ctrl"], font_sizes=[4]),
    riskeyboard70_1_25U(name="LAlt", legends=["Alt"], font_sizes=[4]),
    riskeyboard70_1_25U(name="Command", legends=["Cmd"], font_sizes=[4]),
    riskeyboard70_1_25U(name="CommandSymbol", legends=["⌘"], font_sizes=[4], fonts=["Code2000"]),
    riskeyboard70_1_25U(name="OptionSymbol", legends=["⌥"], font_sizes=[4], fonts=["Code2000"]),
    riskeyboard70_1_25U(name="Option", legends=["Option"], font_sizes=[4]),
    riskeyboard70_1_25U(name="Fun", legends=["Fun"], font_sizes=[4]),
    riskeyboard70_1_25U(name="MoreFun",
        legends=["More", "Fun"],
        trans=[[3,2.5,0], [3,-2.5,0]],
        font_sizes=[4, 4],
        scale=[[1,1,3], [1,1,3]]),
    riskeyboard70_1_25U(legends=["Super", "Duper"],
        trans=[[3,2.25,0], [3,-2.25,0]], font_sizes=[3.25, 3.25],
        scale=[[1,1,3], [1,1,3]]),
    # 1.5U keys
    riskeyboard70_1_5U(name="blank"),
    riskeyboard70_bslash(name="bslash", legends=["\\", "", "|"]),
    riskeyboard70_tab(name="Tab", legends=["Tab"]),
    # 1.75U keys
    riskeyboard70_1_75U(name="blank"),
    riskeyboard70_1_75U(legends=["Compose"],
        trans=[[3.1,0.2,0]], font_sizes=[3.25]),
    riskeyboard70_1_75U(name="Caps",
        legends=["Caps Lock"], trans=[[3.1,0,0]], font_sizes=[3]),
    # 2U keys
    riskeyboard70_2U(name="blank"),
    riskeyboard70_2U(name="TOTALBS",
        legends=["TOTAL BS"], font_sizes=[3.75, 3.75]),
    riskeyboard70_2U(name="Backspace", font_sizes=[3.75, 3.75]),
    riskeyboard70_2U(name="2U_space",
        # Spacebars don't need to be as thick
        stem_sides_wall_thickness=0.0,
        key_rotation=[0,111.88,90], dish_invert=True),
    # 2.25U keys
    riskeyboard70_2_25U(name="blank"),
    riskeyboard70_2_25U(name="Shift", legends=["Shift"]),
    riskeyboard70_2_25U(name="ShiftyShift",
        legends=["Shift"], trans=[[9.5,-2.8,0]]),
    riskeyboard70_2_25U(name="TrueShift", legends=["True Shift"]),
    riskeyboard70_2_25U(legends=["Return"]),
    riskeyboard70_2_25U(legends=["Enter"]),
    # 2.5U keys
    riskeyboard70_2_5U(name="blank"),
    riskeyboard70_2_5U(name="Shift", legends=["Shift"]),
    riskeyboard70_2_5U(name="ShiftyShift",
        legends=["Shift"], trans=[[10,-2.8,0]]),
    riskeyboard70_2_5U(name="TrueShift", legends=["True Shift"]),
    # 2.75U keys
    riskeyboard70_2_75U(name="blank"),
    riskeyboard70_2_75U(name="Shift", legends=["Shift"]),
    riskeyboard70_2_75U(name="ShiftyShift",
        legends=["Shift"], trans=[[10.5,-2.8,0]]),
    riskeyboard70_2_75U(name="TrueShift", legends=["True Shift"]),
    # Various spacebars
    riskeyboard70_6_25U(name="space",
        # Spacebars don't need to be as thick
        stem_sides_wall_thickness=0.0, dish_invert=True),
    riskeyboard70_7U(name="space",
        # Spacebars don't need to be as thick
        stem_sides_wall_thickness=0.0, dish_invert=True),
    # Numpad keycaps
    riskeyboard70_alphas(name="numpad1", legends=["1"]),
    riskeyboard70_alphas(name="numpad2", legends=["2"]),
    riskeyboard70_alphas(name="numpad3", legends=["3"]),
    riskeyboard70_alphas(name="numpad4", legends=["4"]),
    riskeyboard70_alphas(name="numpad5", legends=["5"]),
    riskeyboard70_alphas(name="numpad6", legends=["6"]),
    riskeyboard70_alphas(name="numpad7", legends=["7"]),
    riskeyboard70_alphas(name="numpad8", legends=["8"]),
    riskeyboard70_alphas(name="numpad9", legends=["9"]),
    riskeyboard70_2U(name="numpad0", legends=["0"],
        font_sizes=[4.5]),
    riskeyboard70_alphas(name="numpaddot", legends=["."]),
    riskeyboard70_alphas(name="numlock", legends=["Num"]),
    riskeyboard70_alphas(name="numpadslash", legends=["/"]),
    riskeyboard70_alphas(name="numpadstar", legends=["*"]),
    riskeyboard70_alphas(name="numpadminus", legends=["-"]),
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
        description="Render keycap STLs for all the Riskeyboard 70's switches.")
    parser.add_argument('--out',
        metavar='<filepath>', type=str, default=".",
        help='Where the generated STL files will go.')
    parser.add_argument('--force',
        required=False, action='store_true',
        help='Forcibly re-render STL files even if they already exist.')
    parser.add_argument('--legends',
        required=False, action='store_true',
        help='If True, generate a separate set of STLs for legends.')
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
                        if os.path.exists(f"{args.out}/{keycap.name}.stl"):
                            print(Style.BRIGHT +
                                f"{args.out}/{keycap.name}.stl exists; "
                                f"skipping..."
                                + Style.RESET_ALL)
                            exists = True
                    if not exists:
                        print(Style.BRIGHT +
                            f"Rendering {args.out}/{keycap.name}.stl..."
                            + Style.RESET_ALL)
                        print(keycap)
                        retcode, output = getstatusoutput(str(keycap))
                        if retcode == 0: # Success!
                            print(
                                f"{args.out}/{keycap.name}.stl "
                                f"rendered successfully")
                    if args.legends:
                        keycap.name = f"{keycap.name}_legends"
                        if os.path.exists(f"{args.out}/{keycap.name}.stl"):
                            print(Style.BRIGHT +
                                f"{args.out}/{keycap.name}.stl exists; "
                                f"skipping..."
                                + Style.RESET_ALL)
                            continue
                        print(Style.BRIGHT +
                            f"Rendering {args.out}/{keycap.name}.stl..."
                            + Style.RESET_ALL)
                        print(keycap)
                        retcode, output = getstatusoutput(str(keycap))
                        if retcode == 0: # Success!
                            print(
                                f"{args.out}/{keycap.name}.stl "
                                f"rendered successfully")
        if not matched:
            print(f"Cound not find a keycap named {name}")
    else:
        # First render the keycaps
        for keycap in KEYCAPS:
            keycap.output_path = f"{args.out}"
            if not args.force:
                if os.path.exists(f"{args.out}/{keycap.name}.stl"):
                    print(Style.BRIGHT +
                        f"{args.out}/{keycap.name}.stl exists; skipping..."
                        + Style.RESET_ALL)
                    continue
            print(Style.BRIGHT +
                f"Rendering {args.out}/{keycap.name}.stl..."
                + Style.RESET_ALL)
            print(keycap)
            retcode, output = getstatusoutput(str(keycap))
            if retcode == 0: # Success!
                print(f"{args.out}/{keycap.name}.stl rendered successfully")
        # Next render the legends (for multi-material, non-transparent legends)
        if args.legends:
            for legend in KEYCAPS:
                if legend.legends == [""]:
                    continue # No actual legends
                legend.name = f"{legend.name}_legends"
                legend.output_path = f"{args.out}"
                legend.render = ["legends"]
                if not args.force:
                    if os.path.exists(f"{args.out}/{legend.name}.stl"):
                        print(Style.BRIGHT +
                            f"{args.out}/{legend.name}.stl exists; skipping..."
                            + Style.RESET_ALL)
                        continue
                print(Style.BRIGHT +
                    f"Rendering {args.out}/{legend.name}.stl..."
                    + Style.RESET_ALL)
                print(legend)
                retcode, output = getstatusoutput(str(legend))
                if retcode == 0: # Success!
                    print(f"{args.out}/{legend.name}.stl rendered successfully")
