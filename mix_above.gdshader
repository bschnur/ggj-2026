shader_type canvas_item;
render_mode blend_premul_alpha;
uniform sampler2D below_texture: filter_nearest;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 bot_color = texture(below_texture, UV);
	vec4 top_color = texture(TEXTURE, UV);
	vec4 top_premul = vec4(top_color.rgb * top_color.a, top_color.a);
	COLOR = mix(bot_color, top_premul, 0.5);
	//COLOR = 0.5 * bot_color + 0.5 * top_premul;
}