shader_type canvas_item;
render_mode blend_disabled;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex = texture(TEXTURE, UV);
	// Premultiply alpha.
	COLOR = vec4(tex.rgb * tex.a, tex.a);
}