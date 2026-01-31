shader_type canvas_item;
render_mode blend_disabled;
uniform sampler2D buffer : hint_screen_texture;

varying vec2 v_screen_pos;

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
}