// Legend-related modules

use <keycaps.scad>
use <stems.scad>
use <utils.scad>

// NOTE: Named 'draw_legend' and not just 'legend' to avoid confusion in variable naming

// Extrudes the legend characters the full height of the keycap so an intersection() and difference() can be performed (inside poly_keycap())
module draw_legend(chars, size, font, height) {
    linear_extrude(height=height)
        text(chars, size=size, font=font, valign="center", halign="center");
}

// For multi-material prints you can generate *just* the legends in their proper locations:
module just_legends(height=9.0,
    dish_tilt=0, dish_tilt_curve=false, polygon_layers=10,
    legends=[""], legend_font_sizes=[6], legend_fonts=["Roboto"],
    legend_trans=[[0,0,0]], legend_trans2=[[0,0,0]],
    legend_rotation=[[0,0,0]], legend_rotation2=[[0,0,0]],
    legend_underset=[[0,0,0]], legend_scale=[[1,1,1]], key_rotation=[0,0,0]) {
    layer_tilt_adjust = dish_tilt/polygon_layers;
    tilt_above_curved = dish_tilt_curve ? layer_tilt_adjust * polygon_layers : 0;
    if (legends[0]) {
        intersection() {
            rotate(key_rotation) union() {
                for (i=[0:1:len(legends)-1]) {
                    legend = legends[i] ? legends[i]: "";
                    rotation = legend_rotation[i] ? legend_rotation[i] : (legend_rotation[0] ? legend_rotation[0]: [0,0,0]);
                    rotation2 = legend_rotation2[i] ? legend_rotation2[i] : (legend_rotation2[0] ? legend_rotation2[0]: [0,0,0]);
                    trans = legend_trans[i] ? legend_trans[i] : (legend_trans[0] ? legend_trans[0]: [0,0,0]);
                    trans2 = legend_trans2[i] ? legend_trans2[i] : (legend_trans2[0] ? legend_trans2[0]: [0,0,0]);
                    font_size = legend_font_sizes[i] ? legend_font_sizes[i]: legend_font_sizes[0];
                    font = legend_fonts[i] ? legend_fonts[i] : (legend_fonts[0] ? legend_fonts[0]: "Roboto");
                    l_scale = legend_scale[i] ? legend_scale[i] : legend_scale[0];
                    underset = legend_underset[i] ? legend_underset[i] : (legend_underset[0] ? legend_underset[0]: [0,0,0]);
                    translate(underset) translate(trans2) rotate(rotation2) translate(trans) rotate(rotation)
                        scale(l_scale) rotate([tilt_above_curved,0,0])
                            draw_legend(legend, font_size, font, height);
                }
            }
            children();
        }
    } else {
        note("This keycap has no legends.");
    }
}
