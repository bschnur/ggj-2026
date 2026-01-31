shader_type canvas_item;
render_mode blend_premul_alpha;
uniform sampler2D below_texture: filter_nearest;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 bottom_color = texture(below_texture, UV);
	vec4 top_color_raw = texture(TEXTURE, UV);
	vec4 top_color_premul = vec4(top_color_raw.rgb * top_color_raw.a, top_color_raw.a);
	//COLOR = mix(bottom_color, top_color_premul, 0.5);
	vec4 mixed_color;
    mixed_color.rgb = mix(bottom_color, top_color_premul, 0.5).rgb;
    // "Screen" formula (rather than simple sum) ensures we don't end up with alpha > 1.0:
	mixed_color.a = 1.0 - (1.0 - top_color_premul.a) * (1.0 - bottom_color.a);
	COLOR = mixed_color;
}