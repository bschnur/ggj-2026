shader_type canvas_item;
render_mode blend_disabled;

global uniform vec2 mouse_pos;
global uniform int mouse_lens_color_id;
global uniform vec2 mouse_filtering_radius_vec;

uniform int color_id = 1;

void fragment() {
	// Check if we are filtering out this color with our spotlight.
	if (mouse_lens_color_id != color_id) {
		// Calculate the vector difference and normalize by the elliptical radius
        vec2 diff = (FRAGCOORD.xy - mouse_pos) / mouse_filtering_radius_vec;
		// Check whether we are inside the (perhaps elliptical) spotlight/circle.
		if (dot(diff, diff) < 1.0) {
	        discard; // Don't render this pixel.
		}
    }
	// Grab the texture pixel.
	vec4 tex = texture(TEXTURE, UV);
	// Premultiply alpha for correct blending.
	COLOR = vec4(tex.rgb * tex.a, tex.a);
}