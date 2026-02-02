shader_type canvas_item;
render_mode blend_disabled;

global uniform vec2 mouse_pos;
global uniform int mouse_lens_color_id;
global uniform float mouse_filtering_radius;

uniform int color_id = 1;

void fragment() {
	// Check if we are filtering out this color with our spotlight.
	if (mouse_lens_color_id != color_id) {
		// Get the distance from the [ostensible] mouse position to this fragment.
		float dist = distance(FRAGCOORD.xy, mouse_pos);
		// Check whether we are inside the spotlight/circle.
		if (dist < mouse_filtering_radius) {
	        discard; // Don't render this pixel.
		}
    }
	// Grab the texture pixel.
	vec4 tex = texture(TEXTURE, UV);
	// Premultiply alpha for correct blending.
	COLOR = vec4(tex.rgb * tex.a, tex.a);
}