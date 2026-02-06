shader_type canvas_item;
render_mode blend_disabled;
uniform sampler2D buffer : hint_screen_texture;

varying vec2 v_screen_pos;

global uniform vec2 mouse_pos;
global uniform int mouse_lens_color_id;
global uniform vec2 mouse_filtering_radius_vec;

uniform int color_id = 2;

void vertex() {
    // This calculates where this specific vertex sits in the viewport
    // It stays correct even as the node moves or rotates.
    v_screen_pos = (CANVAS_MATRIX * MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 v_screen_uv = v_screen_pos * SCREEN_PIXEL_SIZE;

	vec4 base = texture(buffer, v_screen_uv);

	vec4 blend = texture(TEXTURE, UV);
	blend.rgb *= blend.a;

	vec4 result;
	result.rgb = 1.0 - (1.0 - base.rgb) * (1.0 - blend.rgb); // "Screen" formula
	result.a = 1.0 - (1.0 - blend.a) * (1.0 - base.a); // "Screen" formula

	COLOR = result;

	// Check if we are filtering out this color with our spotlight.
	if (mouse_lens_color_id != color_id) {
		// Calculate the vector difference and normalize by the elliptical radius
        vec2 diff = (v_screen_pos - mouse_pos) / mouse_filtering_radius_vec;
		// Check whether we are inside the (perhaps elliptical) spotlight/circle.
		if (dot(diff, diff) < 1.0) {
	        COLOR = base;
		}
    }
}