shader_type spatial;
render_mode blend_mix,
depth_draw_opaque,
depth_test_default,
cull_back,
diffuse_lambert,
specular_schlick_ggx,
unshaded,
shadows_disabled;

uniform vec4 custom_color : source_color = vec4(1.000000, 1.000000, 1.000000, 1.000000);
uniform float alpha_mult = 1.0f;

void fragment() {
	vec2 uv = UV;
	
	float center_dist = length(vec2(uv.x*2.0f-1.0f,uv.y*2.0f-1.0f));
	
	ALBEDO = vec3(custom_color.xyz);
	ALPHA = center_dist * alpha_mult;
}
