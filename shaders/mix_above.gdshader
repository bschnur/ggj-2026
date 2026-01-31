shader_type canvas_item;
render_mode blend_disabled;
uniform sampler2D buffer : hint_screen_texture;

void fragment() {
	vec4 base = texture(buffer, UV);
	
	vec4 blend = texture(TEXTURE, UV);
	blend.rgb *= blend.a;
	
	vec4 result;
	result.rgb = 1.0 - (1.0 - base.rgb) * (1.0 - blend.rgb); // "Screen" formula
	result.a = 1.0 - (1.0 - blend.a) * (1.0 - base.a); // "Screen" formula
	
	COLOR = result;
}