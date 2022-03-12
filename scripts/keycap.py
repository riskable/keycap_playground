#!/usr/bin/env python3

"""
Contains the Keycap class which makes it easy to script the generation of
keycaps using the Keycap Playground.
"""

import json
from pathlib import Path

KEY_UNIT = 19.05 # Square that makes up the entire space of a key
BETWEENSPACE = 0.8 # Space between keycaps

class Keycap(object):
    """
    A convenient abstraction for specifying a keycap's details.  The most useful
    way to use this class is to subclass it to make your own "base" class
    containing our kecap's parameters.  Example::

        class KeycapBase(Keycap):
        '''
        Base keycap definitions for keycaps using Gotham Rounded.
        '''
        def __init__(self, **kwargs):
            super().__init__(**kwargs)
            self.key_profile = "gem"
            self.key_rotation = [0,108.6,90]
            self.wall_thickness = 0.45*2.25
            self.uniform_wall_thickness = True
            self.stem_inside_tolerance = 0.15
            self.stem_sides_wall_thickness = 0.8; # Thick (good sound/feel)
            self.fonts = [
                "Gotham Rounded:style=Bold", # Main legend
                "Gotham Rounded:style=Bold", # Secondary (top right)
                "Arial Black:style=Regular", # Front-facing
            ]
            self.font_sizes = [
                5.5, # Regular legend (lower left)
                4, # Gotham Rounded second legend (top right)
                4, # Front legend
            ]
            self.trans = [
                [-3,-2.6,2], # Lower left corner Gotham Rounded
                [3.5,3,1], # Top right Gotham Rounded
                [0.15,-3,2], # Front legend
            ]
            self.rotation = [
                [0,-20,0], # -20 here to match the layer lines when printing
                [0,-20,0],
                [68,0,0], # Front-facing legends need a lot of rotation
            ]
            self.postinit(**kwargs)

    The call to `self.postinit(**kwargs)` is important if you want to be able
    to override things in `KeycapBase()` by passing them via arguments like so::

        tilde = KeycapBase(name="tilde", legends=["`", "", "~"])

    To actually generate a keycap you can use something like this::

        from subprocess import getstatusoutput
        retcode, output = getstatusoutput(str(tilde))
    """
    def __init__(self,
            name=None, render=["keycap", "stem"],
            key_profile="riskeycap",
            key_length=KEY_UNIT-BETWEENSPACE,
            key_width=KEY_UNIT-BETWEENSPACE,
            key_rotation=[0,0,0],
            wall_thickness=0.45*2.5,
            dish_thickness=1.0,
            dish_invert=False,
            uniform_wall_thickness=True,
            stem_type="box_cherry", stem_top_thickness=0.5,
            stem_inside_tolerance=0.2, stem_side_supports=[0,0,0,0],
            stem_locations=[[0,0,0]],
            stem_sides_wall_thickness=0.6,
            legends=[""],
            fonts=[], font_sizes=[],
            trans=[[0,0,0]], trans2=[[0,0,0]],
            rotation=[[0,0,0]], rotation2=[[0,0,0]],
            scale=[[1,1,1]], underset=[[0,0,0]],
            keycap_playground_path=Path("."),
            openscad_path=Path("/usr/bin/openscad"),
            output_path=Path(".")):
        self.name = name
        self.output_path = output_path
        self.render = render
        self.key_length = key_length
        self.key_width = key_width
        self.key_profile = key_profile
        if not self.name:
            if legends and legends[0]:
                self.name = legends[0]
            else:
                self.name = "keycap"
        self.key_rotation = key_rotation
        self.wall_thickness = wall_thickness
        self.dish_thickness = dish_thickness
        self.dish_invert = dish_invert
        self.uniform_wall_thickness = uniform_wall_thickness
        self.stem_type = stem_type
        self.stem_top_thickness = stem_top_thickness
        self.stem_locations = stem_locations
        self.stem_side_supports = stem_side_supports
        self.stem_sides_wall_thickness = stem_sides_wall_thickness
        self.legends = legends
        self.fonts = fonts
        self.font_sizes = font_sizes
        self.trans = trans
        self.trans2 = trans2
        self.rotation = rotation
        self.rotation2 = rotation2
        self.scale = scale
        self.underset = underset
        self.keycap_playground_path = keycap_playground_path
        self.openscad_path = openscad_path

    # NOTE: This doesn't seem to work right for unknown reasons so you'll want
    #       to generate the quote keycap by hand on the command line.
    def quote(self, legends):
        """
        Checks for the edge case of a single quote (') legend and converts it
        into `"'"'"'"` so that bash will pass it correclty to OpenSCAD via
        `getstatusoutput()`.

        .. note::

            Example of what it should look like: `LEGENDS=["'"'"'", "", "\""];`
        """
        properly_escaped_quote = r'''"'"'"'"'''
        for i, legend in enumerate(legends):
            if legend == "'":
                legends[i] = properly_escaped_quote
        return json.dumps(legends)

    def __repr__(self):
        return f"""        name: {self.name}
        render: {self.render}
        key_profile: {self.key_profile}
        legends: {self.legends}
        trans: {self.trans}
        trans2: {self.trans2}
        rotation: {self.rotation}
        rotation2: {self.rotation2}
        scale: {self.scale}
        underset: {self.underset}"""

    def __str__(self):
        """
        Returns the OpenSCAD command line to use to generate this keycap.
        """
        # NOTE: Since OpenSCAD requires double quotes I'm using the json module
        #       to encode things that need it:
        return (
            f"openscad -o '{self.output_path}'/'{self.name}.stl' -D $'"
            f"RENDER={json.dumps(self.render)}; "
            f"KEY_PROFILE={json.dumps(self.key_profile)}; "
            f"KEY_LENGTH={self.key_length}; "
            f"KEY_WIDTH={self.key_width}; "
            f"KEY_ROTATION={self.key_rotation}; "
            f"WALL_THICKNESS={self.wall_thickness}; "
            f"UNIFORM_WALL_THICKNESS={json.dumps(self.uniform_wall_thickness)}; "
            f"DISH_THICKNESS={self.dish_thickness}; "
            f"DISH_INVERT={json.dumps(self.dish_invert)}; "
            f"STEM_TYPE={json.dumps(self.stem_type)}; "
            f"STEM_TOP_THICKNESS={self.stem_top_thickness}; "
            f"STEM_INSIDE_TOLERANCE={self.stem_inside_tolerance}; "
            f"STEM_SIDE_SUPPORTS={self.stem_side_supports}; "
            f"STEM_SIDES_WALL_THICKNESS={self.stem_sides_wall_thickness}; "
            f"STEM_LOCATIONS={self.stem_locations}; "
            f"LEGENDS={self.quote(self.legends)}; "
            f"LEGEND_FONTS={json.dumps(self.fonts)}; "
            f"LEGEND_FONT_SIZES={self.font_sizes}; "
            f"LEGEND_TRANS={self.trans}; "
            f"LEGEND_TRANS2={self.trans2}; "
            f"LEGEND_ROTATION={self.rotation}; "
            f"LEGEND_ROTATION2={self.rotation2}; "
            f"LEGEND_SCALE={self.scale}; "
            f"LEGEND_UNDERSET={self.underset}; "
# NOTE: For some reason I have to duplicate RENDER here for it to work properly:
            f"RENDER={json.dumps(self.render)};' "
            f"keycap_playground.scad"
        )

    def postinit(self, **kwargs):
        """
        Override anything passed in via kwargs
        """
        #print(f"postinit kwargs: {kwargs}")
        for k, v in kwargs.items():
            #print(f"Updating: {k}: {v}")
            self.__dict__.update({k: v})
